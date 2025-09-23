/**
 * Notification service - orchestrates notification creation and delivery
 */

import { DatabaseService } from './database';
import { FirebaseService } from './firebase';
import { NotificationMessage, NotificationRecord, UserToken, NotificationPriority, ProcessingResult } from '../types';

export class NotificationService {
  private db: DatabaseService;
  private firebase: FirebaseService;

  constructor(db: DatabaseService, firebase: FirebaseService) {
    this.db = db;
    this.firebase = firebase;
  }

  /**
   * Send notification to a single user
   */
  async sendToUser(
    userId: string,
    message: NotificationMessage,
    notificationRecord: Omit<NotificationRecord, 'title' | 'body'>,
    priority: NotificationPriority = 'normal'
  ): Promise<ProcessingResult> {
    // Get user's FCM tokens
    const tokens = await this.db.getUserTokens(userId);
    
    let fcmResult = null;
    if (tokens.length > 0) {
      fcmResult = await this.firebase.sendNotification(tokens, message, priority);
      
      // Process FCM response
      await this.firebase.processFCMResponse(
        fcmResult,
        fcmResult.tokenStrings || tokens.map(t => t.fcm_token),
        (token, reason) => this.db.markTokenFailed(token, reason),
        (token) => this.db.markTokenSuccess(token)
      );
    }
    
    // Save notification to database
    const notificationId = await this.db.saveNotification({
      ...notificationRecord,
      title: message.title,
      body: message.body,
      data: message.data,
      image_url: message.image,
      action_url: message.actionUrl,
      priority,
    });
    
    // Log delivery attempt
    if (tokens.length > 0) {
      await this.db.logDeliveryAttempt(
        notificationId,
        'fcm',
        fcmResult.successCount > 0 ? 'sent' : 'failed',
        'firebase',
        null,
        fcmResult
      );
    }
    
    return {
      success: true,
      recipients: 1,
      fcmSent: tokens.length,
      fcmSuccess: fcmResult?.successCount || 0,
      notificationId,
    };
  }

  /**
   * Send notifications to multiple users (e.g., for location-based notifications)
   */
  async sendToMultipleUsers(
    userIds: string[],
    messageGenerator: (userId: string, userData?: any) => Promise<NotificationMessage>,
    notificationRecordGenerator: (userId: string, userData?: any) => Promise<Omit<NotificationRecord, 'title' | 'body'>>,
    priority: NotificationPriority = 'normal',
    userDataMap?: Map<string, any>
  ): Promise<ProcessingResult> {
    const notifications = [];
    let totalFcmSent = 0;
    let totalFcmSuccess = 0;

    for (const userId of userIds) {
      const userData = userDataMap?.get(userId);
      const message = await messageGenerator(userId, userData);
      const notificationRecord = await notificationRecordGenerator(userId, userData);

      const result = await this.sendToUser(userId, message, notificationRecord, priority);
      
      notifications.push({
        userId,
        notificationId: result.notificationId,
        fcmSent: result.fcmSent,
        fcmSuccess: result.fcmSuccess,
      });

      totalFcmSent += result.fcmSent || 0;
      totalFcmSuccess += result.fcmSuccess || 0;
    }

    return {
      success: true,
      recipients: notifications.length,
      fcmSent: totalFcmSent,
      fcmSuccess: totalFcmSuccess,
      notifications,
    };
  }

  /**
   * Send location-based notifications to nearby users
   */
  async sendLocationBasedNotifications(
    latitude: number,
    longitude: number,
    radiusKm: number,
    messageGenerator: (userId: string, userData: any) => Promise<NotificationMessage>,
    notificationRecordGenerator: (userId: string, userData: any) => Promise<Omit<NotificationRecord, 'title' | 'body'>>,
    priority: NotificationPriority = 'normal'
  ): Promise<ProcessingResult> {
    // Find nearby users
    const nearbyUsers = await this.db.findNearbyUsers(latitude, longitude, radiusKm);
    
    if (nearbyUsers.length === 0) {
      return { 
        success: true, 
        recipients: 0, 
        reason: 'No nearby users found',
        radiusKm,
      };
    }

    // Create user data map
    const userDataMap = new Map();
    nearbyUsers.forEach(user => {
      userDataMap.set(user.user_id, user);
    });

    const result = await this.sendToMultipleUsers(
      nearbyUsers.map(u => u.user_id),
      messageGenerator,
      notificationRecordGenerator,
      priority,
      userDataMap
    );

    return {
      ...result,
      radiusKm,
      nearbyUsersFound: nearbyUsers.length,
    };
  }
}