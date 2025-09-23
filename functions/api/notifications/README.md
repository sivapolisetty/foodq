# Modular Notification System

This directory contains a refactored, modular notification system that separates concerns for better maintainability, testability, and scalability.

## 📁 Directory Structure

```
notifications/
├── types/
│   └── index.ts              # Type definitions and interfaces
├── services/
│   ├── database.ts           # Database operations and queries
│   ├── firebase.ts           # Firebase Cloud Messaging service
│   ├── notification.ts       # High-level notification orchestration
│   └── event-processor.ts    # Main event routing and processing
├── handlers/
│   ├── order-handlers.ts     # Order event handlers
│   └── deal-handlers.ts      # Deal and location-based event handlers
├── utils/
│   └── validation.ts         # Validation utilities
├── process-modular.ts        # New modular main entry point
├── process.ts                # Original monolithic file (kept for reference)
└── README.md                 # This documentation
```

## 🏗️ Architecture Overview

### Separation of Concerns

1. **Types** (`types/`): All TypeScript interfaces and type definitions
2. **Services** (`services/`): Business logic and external service integrations
3. **Handlers** (`handlers/`): Event-specific processing logic
4. **Utils** (`utils/`): Utility functions and validation
5. **Entry Point** (`process-modular.ts`): Clean request handling

### Service Layer

- **DatabaseService**: Handles all database operations (queries, inserts, updates)
- **FirebaseService**: Manages FCM initialization and message sending
- **NotificationService**: Orchestrates notification creation and delivery
- **EventProcessor**: Routes events to appropriate handlers

### Handler Layer

- **OrderHandlers**: Processes all order lifecycle events
- **DealHandlers**: Handles deal creation, expiration, and location-based notifications

## 🔄 Data Flow

```
Webhook Request → Validation → EventProcessor → Handler → NotificationService → Firebase/Database
```

1. **Request Validation**: Verify webhook secret and event structure
2. **Event Routing**: Route to appropriate handler based on event type
3. **Handler Processing**: Process event with business logic
4. **Notification Orchestration**: Coordinate FCM sending and database storage
5. **Delivery Tracking**: Log delivery attempts and token management

## 📋 Event Types Supported

### Order Events
- `ORDER_CREATED` / `ORDER_PAID` → Notify business owner
- `ORDER_CONFIRMED` → Notify customer with pickup details
- `ORDER_READY` → Urgent notification to customer
- `ORDER_COMPLETED` → Notify both customer and business
- `ORDER_CANCELLED` → Notify customer

### Deal Events
- `DEAL_CREATED` → Location-based notifications to nearby users
- `LOCATION_BASED_DEAL` → User location update with relevant deals
- `DEAL_EXPIRING` → Urgent notifications for expiring deals

### System Events
- `SYSTEM_ANNOUNCEMENT` → Broadcast notifications (future feature)

## 🧪 Testing Benefits

The modular structure makes unit testing much easier:

```typescript
// Example: Testing order handler
const mockNotificationService = new MockNotificationService();
const orderHandlers = new OrderHandlers(mockNotificationService);
const result = await orderHandlers.handleOrderCreated(mockEvent);
```

## 🔧 Configuration

The system expects these environment variables:

```
WEBHOOK_SECRET          # Webhook authentication
FIREBASE_PROJECT_ID     # Firebase project
FIREBASE_CLIENT_EMAIL   # Firebase service account
FIREBASE_PRIVATE_KEY    # Firebase private key
DB                      # Database connection (Cloudflare D1)
```

## 🚀 Deployment

To use the modular version:

1. Replace imports in your deployment configuration
2. Update `wrangler.toml` to point to `process-modular.ts`
3. Ensure all dependencies are included in the bundle

## 📊 Benefits of Modular Architecture

1. **Maintainability**: Each component has a single responsibility
2. **Testability**: Easy to mock dependencies and test individual components
3. **Scalability**: Easy to add new event types or notification channels
4. **Reusability**: Services can be reused across different handlers
5. **Debugging**: Easier to trace issues through specific components
6. **Code Quality**: Better separation of concerns and cleaner code

## 🔄 Migration Guide

To migrate from the monolithic `process.ts` to modular structure:

1. Update your Cloudflare Worker to use `process-modular.ts`
2. Test thoroughly with your existing events
3. Monitor for any behavioral differences
4. Once stable, remove the old `process.ts` file

## 🎯 Future Enhancements

- Add more notification channels (email, SMS, web push)
- Implement notification templates
- Add analytics and metrics collection
- Support for notification scheduling
- User preference management
- A/B testing capabilities