// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppNotificationImpl _$$AppNotificationImplFromJson(
        Map<String, dynamic> json) =>
    _$AppNotificationImpl(
      id: json['id'] as String,
      recipientId: json['recipient_id'] as String,
      type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
      title: json['title'] as String,
      message: json['message'] as String,
      actionUrl: json['action_url'] as String?,
      relatedId: json['related_id'] as String?,
      imageUrl: json['image_url'] as String?,
      priority: $enumDecodeNullable(
              _$NotificationPriorityEnumMap, json['priority']) ??
          NotificationPriority.normal,
      isRead: json['is_read'] as bool? ?? false,
      readAt: json['read_at'] == null
          ? null
          : DateTime.parse(json['read_at'] as String),
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.parse(json['expires_at'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$AppNotificationImplToJson(
        _$AppNotificationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'recipient_id': instance.recipientId,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'title': instance.title,
      'message': instance.message,
      'action_url': instance.actionUrl,
      'related_id': instance.relatedId,
      'image_url': instance.imageUrl,
      'priority': _$NotificationPriorityEnumMap[instance.priority]!,
      'is_read': instance.isRead,
      'read_at': instance.readAt?.toIso8601String(),
      'expires_at': instance.expiresAt?.toIso8601String(),
      'metadata': instance.metadata,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$NotificationTypeEnumMap = {
  NotificationType.orderConfirmed: 'order_confirmed',
  NotificationType.orderPreparing: 'order_preparing',
  NotificationType.orderReady: 'order_ready',
  NotificationType.orderCompleted: 'order_completed',
  NotificationType.orderCancelled: 'order_cancelled',
  NotificationType.newDeal: 'new_deal',
  NotificationType.dealExpiring: 'deal_expiring',
  NotificationType.dealSoldOut: 'deal_sold_out',
  NotificationType.paymentSuccessful: 'payment_successful',
  NotificationType.paymentFailed: 'payment_failed',
  NotificationType.systemAnnouncement: 'system_announcement',
  NotificationType.restaurantUpdate: 'restaurant_update',
};

const _$NotificationPriorityEnumMap = {
  NotificationPriority.low: 'low',
  NotificationPriority.normal: 'normal',
  NotificationPriority.high: 'high',
  NotificationPriority.urgent: 'urgent',
};
