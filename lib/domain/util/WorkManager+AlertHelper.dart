import 'package:workmanager/workmanager.dart';

import '../mapper/TimeUtil.dart';
import '../model/alert.dart';

class WorkManagerAlertHelper {
  static Future<void> cancelNotificationQueue(Alert alert) {
    return Workmanager().cancelByUniqueName(alert.id.toString());
  }

  static Future<void> createPeriodicNotificationQueue(Alert alert) {
    return Workmanager().registerPeriodicTask(alert.id.toString(), alert.title,
        initialDelay: TimeUtil.getDurationFromNowTo(alert.expireTime),
        frequency: Duration(
            days: alert.repeatIntervalTimeInDays +
                alert.repeatIntervalTimeInWeeks * 7,
            hours: alert.repeatIntervalTimeInHours,
            minutes: alert.repeatIntervalTimeInMinutes),
        inputData: {
          "title": alert.title,
          "body": alert.description,
          "id": alert.id
        });
  }

  static Future<void> createOneTimeNotification(Alert alert) {
    return Workmanager().registerOneOffTask(alert.id.toString(), alert.title,
        initialDelay: TimeUtil.getDurationFromNowTo(alert.expireTime),
        inputData: {
          "title": alert.title,
          "body": alert.description,
          "id": alert.id
        });
  }

  static Future<void> createNotification(Alert alert) {
    if (alert.isRepeating()) {
      return createPeriodicNotificationQueue(alert);
    } else {
      return createOneTimeNotification(alert);
    }
  }

  static Future<void> updateExistingNotification(Alert alert) {
    return cancelNotificationQueue(alert)
        .then((value) => createNotification(alert));
  }
}
