import 'package:flutter/material.dart';

class DuaaItem {
  final int id;
  final String arabic;
  final String translation;
  final String category;
  final String? reference;

  const DuaaItem({
    required this.id,
    required this.arabic,
    required this.translation,
    required this.category,
    this.reference,
  });

  factory DuaaItem.fromMap(Map<String, dynamic> map, {String? defaultCategory}) {
    return DuaaItem(
      id: map['id'] is int ? map['id'] : 1,
      arabic: (map['arabic'] ?? map['Arabic'] ?? '').toString().trim(),
      translation: (map['translation'] ?? map['English'] ?? '').toString().trim(),
      category: (map['category'] ?? defaultCategory ?? '').toString(),
      reference: map['reference']?.toString(),
    );
  }
}

class DuaaCategory {
  final String id;
  final String titleAr;
  final String titleEn;
  final String descriptionAr;
  final IconData icon;
  final Color accentColor;
  final List<DuaaItem> items;

  const DuaaCategory({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.descriptionAr,
    required this.icon,
    required this.accentColor,
    required this.items,
  });

  int get count => items.length;
}
