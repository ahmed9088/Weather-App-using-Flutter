// lib/core/utils/app_date_utils.dart
import 'package:intl/intl.dart';

class AppDateUtils {
  static String formatTime(DateTime dateTime) {
    return DateFormat.jm().format(dateTime);
  }
  
  static String formatDate(DateTime dateTime) {
    return DateFormat.yMMMd().format(dateTime);
  }
  
  static String formatLastUpdated(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return DateFormat.yMMMd().add_jm().format(dateTime);
    }
  }
  
  static String formatWeekday(DateTime dateTime) {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    
    if (dateTime.day == now.day && dateTime.month == now.month && dateTime.year == now.year) {
      return 'Today';
    } else if (dateTime.day == tomorrow.day && dateTime.month == tomorrow.month && dateTime.year == tomorrow.year) {
      return 'Tomorrow';
    } else {
      return DateFormat.E().format(dateTime);
    }
  }
}