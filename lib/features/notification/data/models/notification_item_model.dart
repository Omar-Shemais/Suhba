import 'package:flutter/material.dart';

enum NotificationDotColor {
  red,
  green,
  amber,
}

enum NotificationIconStyle {
  green,
  bronze,
}

class NotificationItemModel {
  final String id;
  final String title;
  final String subtitle;
  final String time;
  final NotificationDotColor dotColor;
  final IconData icon;
  final NotificationIconStyle iconStyle;
  final String? route;
  final VoidCallback? customAction;
  final bool isPriority;
  final bool isRead;

  const NotificationItemModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.dotColor,
    required this.icon,
    this.iconStyle = NotificationIconStyle.green,
    this.route,
    this.customAction,
    this.isPriority = false,
    this.isRead = false,
  });

  NotificationItemModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? time,
    NotificationDotColor? dotColor,
    IconData? icon,
    NotificationIconStyle? iconStyle,
    String? route,
    VoidCallback? customAction,
    bool? isPriority,
    bool? isRead,
  }) {
    return NotificationItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      time: time ?? this.time,
      dotColor: dotColor ?? this.dotColor,
      icon: icon ?? this.icon,
      iconStyle: iconStyle ?? this.iconStyle,
      route: route ?? this.route,
      customAction: customAction ?? this.customAction,
      isPriority: isPriority ?? this.isPriority,
      isRead: isRead ?? this.isRead,
    );
  }
}
