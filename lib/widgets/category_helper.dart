import 'package:flutter/material.dart';
class CategoryHelper {
  static String getEmoji(String category) {
    switch (category.toLowerCase().trim()) {
      case 'salary':
        return '💰';
      case 'business':
        return '🏢';
      case 'freelancing':
        return '💻';
      case 'investment':
        return '📈';
      case 'gift':
        return '🎁';
        case 'food':
        return '🍔';
      case 'shopping':
        return '🛍️';
      case 'transport':
        return '🚗';
      case 'bills':
      case 'bill':
        return '💡';
      case 'health':
        return '🏥';
      case 'education':
        return '📚';
      case 'entertainment':
        return '🎬';
      case 'rent':
        return '🏠';
      default:
        return '📦';
    }
  }
  static Color getBackgroundColor(String category) {
    switch (category.toLowerCase().trim()) {case 'salary':
        return const Color(0xFFE8F5E9);
      case 'business':
        return const Color(0xFFE3F2FD);
      case 'freelancing':
        return const Color(0xFFEDE7F6);
      case 'investment':
        return const Color(0xFFE0F2F1);
      case 'gift':
        return const Color(0xFFFCE4EC);
        case 'food':
        return const Color(0xFFFFF0D9);
      case 'shopping':
        return const Color(0xFFFCE4EC);
      case 'transport':
        return const Color(0xFFE3F2FD);
      case 'bills':
      case 'bill':
        return const Color(0xFFFFF8E1);
      case 'health':
        return const Color(0xFFFFEBEE);
      case 'education':
        return const Color(0xFFEDE7F6);
      case 'entertainment':
        return const Color(0xFFF3E5F5);
      case 'rent':
        return const Color(0xFFEFEBE9);

      default:
        return const Color(0xFFEDE7F6);
    }
  }
}