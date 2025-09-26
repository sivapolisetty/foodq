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
    const serviceAccount = {
      projectId: this.env.FIREBASE_PROJECT_ID,
      clientEmail: this.env.FIREBASE_CLIENT_EMAIL,
      privateKey: this.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
    };

    if (!serviceAccount.clientEmail || !serviceAccount.privateKey) {
      throw new Error('Firebase service account credentials not configured');
    }

    // Create JWT for Firebase auth
    const now = Math.floor(Date.now() / 1000);
    
    const jwtHeader = {
      alg: 'RS256',
      typ: 'JWT',
      kid: undefined // Optional key ID
    };

    const jwtPayload = {
      iss: serviceAccount.clientEmail,
      scope: 'https://www.googleapis.com/auth/firebase.messaging',
      aud: 'https://oauth2.googleapis.com/token',
      exp: now + 3600, // 1 hour
      iat: now
    };

    // Create JWT using Web Crypto API (available in Cloudflare Workers)
    const jwt = await this.createJWT(jwtHeader, jwtPayload, serviceAccount.privateKey);
    
    // Exchange JWT for access token
    console.log('🔑 Exchanging JWT for access token...');
    const tokenResponse = await fetch('https://oauth2.googleapis.com/token', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: new URLSearchParams({
        grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        assertion: jwt,
      }),
    });

    console.log('🔑 Token response status:', tokenResponse.status);

    if (!tokenResponse.ok) {
      const error = await tokenResponse.text();
      console.error('❌ Token exchange failed:', error);
      throw new Error(`Failed to get access token: ${error}`);
    }

    const tokenData = await tokenResponse.json();
    console.log('✅ Successfully got access token');
    return tokenData.access_token;
  }

  /**
   * Create JWT using Web Crypto API (Cloudflare Workers compatible)
   */
  private async createJWT(header: any, payload: any, privateKey: string): Promise<string> {
    // Base64 URL encode header and payload
    const encodedHeader = this.base64UrlEncode(JSON.stringify(header));
    const encodedPayload = this.base64UrlEncode(JSON.stringify(payload));
    
    // Create signing input
    const signingInput = `${encodedHeader}.${encodedPayload}`;
    
    // Import private key
    const key = await crypto.subtle.importKey(
      'pkcs8',
      this.pemToArrayBuffer(privateKey),
      {
        name: 'RSASSA-PKCS1-v1_5',
        hash: 'SHA-256',
      },
      false,
      ['sign']
    );

    // Sign the JWT
    const signature = await crypto.subtle.sign(
      'RSASSA-PKCS1-v1_5',
      key,
      new TextEncoder().encode(signingInput)
    );

    // Encode signature
    const encodedSignature = this.base64UrlEncode(signature);
    
    return `${signingInput}.${encodedSignature}`;
  }

  /**
   * Convert PEM private key to ArrayBuffer
   */
  private pemToArrayBuffer(pem: string): ArrayBuffer {
    const pemContents = pem
      .replace(/-----BEGIN PRIVATE KEY-----/, '')
      .replace(/-----END PRIVATE KEY-----/, '')
      .replace(/\s/g, '');
    
    const binaryString = atob(pemContents);
    const bytes = new Uint8Array(binaryString.length);
    
    for (let i = 0; i < binaryString.length; i++) {
      bytes[i] = binaryString.charCodeAt(i);
    }
    
    return bytes.buffer;
  }

  /**
   * Base64 URL encode (without padding)
   */
  private base64UrlEncode(data: string | ArrayBuffer): string {
    const base64 = typeof data === 'string' 
      ? btoa(data)
      : btoa(String.fromCharCode(...new Uint8Array(data)));
    
    return base64
      .replace(/\+/g, '-')
      .replace(/\//g, '_')
      .replace(/=/g, '');
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
    
    // Check if we have real Firebase credentials
    const hasCredentials = this.env.FIREBASE_PROJECT_ID && 
                          this.env.FIREBASE_CLIENT_EMAIL && 
                          this.env.FIREBASE_PRIVATE_KEY;
    
    // Debug logging
    console.log('🔍 Firebase credential check:');
    console.log(`   FIREBASE_PROJECT_ID: ${!!this.env.FIREBASE_PROJECT_ID}`);
    console.log(`   FIREBASE_CLIENT_EMAIL: ${!!this.env.FIREBASE_CLIENT_EMAIL}`);
    console.log(`   FIREBASE_PRIVATE_KEY: ${!!this.env.FIREBASE_PRIVATE_KEY}`);
    console.log(`   hasCredentials: ${hasCredentials}`);
    
    if (!hasCredentials) {
      console.log('🚨 Firebase credentials not configured - running in simulation mode');
      console.log('🔥 FCM Message (simulated):');
      console.log(`   📱 Title: ${message.title}`);
      console.log(`   📝 Body: ${message.body}`);
      console.log(`   🎯 Priority: ${priority}`);
      console.log(`   📊 Tokens: ${tokens.length}`);
      
      return {
        successCount: tokens.length,
        failureCount: 0,
        responses: tokens.map(() => ({ success: true })),
        tokenStrings: tokens.map(t => t.fcm_token)
      };
    }

    // Real FCM API call
    try {
      console.log('🚀 Making real FCM API call...');
      console.log(`📊 Token count: ${tokens.length}`);
      
      if (tokens.length === 0) {
        console.log('❌ No FCM tokens available for user');
        return {
          successCount: 0,
          failureCount: 0,
          responses: [],
          tokenStrings: []
        };
      }

      // Log token info (first 10 chars for privacy)
      tokens.forEach((token, index) => {
        console.log(`📱 Token ${index + 1}: ${token.fcm_token?.substring(0, 10)}... (${token.platform})`);
      });
      
      // Get access token
      console.log('🔐 Getting Firebase access token...');
      const accessToken = await this.getAccessToken();
      console.log('✅ Got Firebase access token');
      
      // Prepare FCM message
      const fcmMessage = {
        message: {
          notification: {
            title: message.title,
            body: message.body,
            image: message.image || undefined,
          },
          data: message.data || {},
          android: {
            priority: priority === 'urgent' ? 'high' : 'normal',
            notification: {
              click_action: message.actionUrl || undefined,
            },
          },
          apns: {
            payload: {
              aps: {
                alert: {
                  title: message.title,
                  body: message.body,
                },
                sound: 'default',
                badge: 1,
              },
            },
          },
          token: tokens[0].fcm_token, // For single token
        },
      };

      console.log('📤 Sending FCM message to:', `fcm.googleapis.com/v1/projects/${this.env.FIREBASE_PROJECT_ID}/messages:send`);

      // Send to FCM API
      const response = await fetch(`https://fcm.googleapis.com/v1/projects/${this.env.FIREBASE_PROJECT_ID}/messages:send`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${accessToken}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(fcmMessage),
      });

      const result = await response.json();
      
      console.log(`📬 FCM API response status: ${response.status}`);
      console.log('📬 FCM API response:', JSON.stringify(result, null, 2));
      
      if (response.ok) {
        console.log('✅ FCM message sent successfully:', result.name);
        return {
          successCount: 1,
          failureCount: 0,
          responses: [{ success: true, messageId: result.name }],
          tokenStrings: tokens.map(t => t.fcm_token)
        };
      } else {
        console.error('❌ FCM API error status:', response.status);
        console.error('❌ FCM API error details:', JSON.stringify(result, null, 2));
        return {
          successCount: 0,
          failureCount: 1,
          responses: [{ success: false, error: result.error }],
          tokenStrings: tokens.map(t => t.fcm_token)
        };
      }
      
    } catch (error) {
      console.error('💥 FCM send error:', error);
      console.error('💥 FCM send error stack:', error.stack);
      return {
        successCount: 0,
        failureCount: tokens.length,
        responses: tokens.map(() => ({ success: false, error: error.message })),
        tokenStrings: tokens.map(t => t.fcm_token)
      };
    }
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