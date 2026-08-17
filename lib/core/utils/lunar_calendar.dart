// lib/core/utils/lunar_calendar.dart
// 农历工具 - lunar 1.7.8 API（Java 风格方法）

import 'package:lunar/lunar.dart';

class LunarCalendar {
  LunarCalendar._();

  /// 获取农历日期字符串
  /// 格式：农历六月十八
  static String getLunarDate(DateTime date) {
    try {
      final lunar = Lunar.fromDate(date);
      final monthCn = lunar.getMonthInChinese();
      final dayCn = lunar.getDayInChinese();
      return '农历$monthCn月$dayCn';
    } catch (e) {
      return '';
    }
  }

  /// 获取干支年
  static String getGanZhiYear(DateTime date) {
    try {
      final lunar = Lunar.fromDate(date);
      return '${lunar.getYearInChinese()}年';
    } catch (e) {
      return '';
    }
  }

  /// 获取节日（公历 + 农历）
  static String getFestivals(DateTime date) {
    try {
      final solar = Solar.fromDate(date);
      final lunar = Lunar.fromDate(date);
      final festivals = <String>[];
      festivals.addAll(solar.getFestivals());
      festivals.addAll(lunar.getFestivals());
      return festivals.join(' · ');
    } catch (e) {
      return '';
    }
  }
}
