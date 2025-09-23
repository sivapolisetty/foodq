/**
 * Firebase Cloud Messaging service
 * Uses Firebase REST API for Cloudflare Workers compatibility
 */

import { NotificationMessage, UserToken, NotificationPriority } from '../types';

export class FirebaseService {
  private env: any;

  constructor(env: any) {
    this.env = env;
  }

  /**
   * Get Firebase access token using service account
   */
  private async getAccessToken(): Promise<string> {
    // For Cloudflare Workers, we'll use the service account key directly
    // In production, this should be stored as a secret
    const serviceAccount = {
      projectId: this.env.FIREBASE_PROJECT_ID,
      clientEmail: this.env.FIREBASE_CLIENT_EMAIL,
      privateKey: this.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
    };

    // Create JWT for Firebase auth
    const now = Math.floor(Date.now() / 1000);
    const header = {
      alg: 'RS256',
      typ: 'JWT'
    };

    const payload = {
      iss: serviceAccount.clientEmail,
      scope: 'https://www.googleapis.com/auth/firebase.messaging',
      aud: 'https://oauth2.googleapis.com/token',
      exp: now + 3600,
      iat: now
    };

    // For now, return a placeholder - in production this would use proper JWT signing
    // This is a simplified version for demo purposes
    return 'mock_access_token';
  }

  /**
   * Send multicast FCM notification using REST API
   */
  async sendNotification(
    tokens: UserToken[], 
    message: NotificationMessage, 
    priority: NotificationPriority = 'normal'
  ): Promise<any> {
    if (tokens.length === 0) {
      return { successCount: 0, failureCount: 0, responses: [] };
    }

    console.log(`📱 Sending FCM notifications to ${tokens.length} tokens`);
    console.log(`📋 Message: ${message.title} - ${message.body}`);
    
    // For demo purposes, simulate successful FCM sending
    // In production, this would make actual HTTP calls to Firebase
    const simulatedResponse = {
      successCount: tokens.length,
      failureCount: 0,
      responses: tokens.map(() => ({ success: true })),
      tokenStrings: tokens.map(t => t.fcm_token)
    };

    // Log what would be sent
    console.log('🔥 FCM Message (simulated):');
    console.log(`   📱 Title: ${message.title}`);
    console.log(`   📝 Body: ${message.body}`);
    console.log(`   🎯 Priority: ${priority}`);
    console.log(`   📊 Tokens: ${tokens.length}`);
    
    return simulatedResponse;
  }

  /**
   * Process FCM response and handle token failures
   */
  async processFCMResponse(
    response: any, 
    tokenStrings: string[],
    onTokenFailed: (token: string, reason: string) => Promise<void>,
    onTokenSuccess: (token: string) => Promise<void>
  ): Promise<void> {
    if (response.failureCount > 0) {
      for (let i = 0; i < response.responses.length; i++) {
        const resp = response.responses[i];
        if (!resp.success) {
          const token = tokenStrings[i];
          console.error(`FCM failure for token ${token}`);
          await onTokenFailed(token, 'FCM delivery failed');
        } else {
          await onTokenSuccess(tokenStrings[i]);
        }
      }
    } else {
      // Mark all tokens as successful
      for (const token of tokenStrings) {
        await onTokenSuccess(token);
      }
    }
    
    console.log(`✅ FCM processing complete: ${response.successCount} successful, ${response.failureCount} failed`);
  }
}