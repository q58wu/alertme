import 'dart:ffi';

const String tableAlert = 'tableAlert';

class AlertFields {
  static final List<String> values = [
    /// Add all fields
    id, title, status, isImportant, description,
    setTime, expireTime, repeatIntervalTimeInDays,
    repeatIntervalTimeInWeeks, repeatIntervalTimeInHours,
    repeatIntervalTimeInMinutes
  ];

  static const String id = '_id';
  static const String title = 'title';
  static const String status = 'status';
  static const String isImportant = 'isImportant';
  static const String description = 'description';
  static const String setTime = 'setTime';
  static const String expireTime = 'expireTime';
  static const String repeatIntervalTimeInDays = 'repeatIntervalTimeInDays';
  static const String repeatIntervalTimeInWeeks = 'repeatIntervalTimeInWeeks';
  static const String repeatIntervalTimeInHours = 'repeatIntervalTimeInHours';
  static const String repeatIntervalTimeInMinutes = 'repeatIntervalTimeInMinutes';
}

enum AlertStatus {
  disabled, // Alert is disabled
  dismissed, // Repeating alert which has been dismissed by the user
  pending, // Alert is scheduled and waiting to be triggered
  triggered, // Alert has already been triggered
}

class Alert {
  final int? id;
  final AlertStatus status;
  final bool isImportant;
  final String title;
  final String description;
  final DateTime setTime;
  final DateTime expireTime;
  final int repeatIntervalTimeInDays;
  final int repeatIntervalTimeInWeeks;
  final int repeatIntervalTimeInHours;
  final int repeatIntervalTimeInMinutes;

  const Alert(
      {this.id,
        required this.status,
        required this.isImportant,
        required this.title,
        required this.description,
        required this.setTime,
        required this.expireTime,
        required this.repeatIntervalTimeInDays,
        required this.repeatIntervalTimeInWeeks,
        required this.repeatIntervalTimeInHours,
        required this.repeatIntervalTimeInMinutes});

  Alert copy({
    int? id,
    AlertStatus? status,
    bool? isImportant,
    int? number,
    String? title,
    String? description,
    DateTime? setTime,
    DateTime? expireTime,
    int? repeatIntervalTimeInDays,
    int? repeatIntervalTimeInWeeks,
    int? repeatIntervalTimeInHours,
    int? repeatIntervalTimeInMinutes
  }) =>
      Alert(
          id: id ?? this.id,
          status: status ?? this.status,
          isImportant: isImportant ?? this.isImportant,
          title: title ?? this.title,
          description: description ?? this.description,
          setTime: setTime ?? this.setTime,
          expireTime: expireTime ?? this.expireTime,
          repeatIntervalTimeInDays: repeatIntervalTimeInDays ?? this.repeatIntervalTimeInDays,
          repeatIntervalTimeInWeeks: repeatIntervalTimeInWeeks ?? this.repeatIntervalTimeInWeeks,
          repeatIntervalTimeInHours: repeatIntervalTimeInHours ?? this.repeatIntervalTimeInHours,
          repeatIntervalTimeInMinutes: repeatIntervalTimeInMinutes ?? this.repeatIntervalTimeInMinutes,
      );

  static Alert fromJson(Map<String, Object?> json) => Alert(
      id: json[AlertFields.id] as int?,
      status: AlertStatus.values.firstWhere(
            (status) => status.toString().split('.').last == json[AlertFields.status],
            orElse: () => AlertStatus.disabled,
      ),
      isImportant: json[AlertFields.isImportant] == 1,
      title: json[AlertFields.title] as String,
      description: json[AlertFields.description] as String,
      setTime: DateTime.parse(json[AlertFields.setTime] as String),
      expireTime: DateTime.parse(json[AlertFields.expireTime] as String),
      repeatIntervalTimeInDays: json[AlertFields.repeatIntervalTimeInDays] as int,
      repeatIntervalTimeInWeeks: json[AlertFields.repeatIntervalTimeInWeeks] as int,
      repeatIntervalTimeInHours: json[AlertFields.repeatIntervalTimeInHours] as int,
      repeatIntervalTimeInMinutes: json[AlertFields.repeatIntervalTimeInMinutes] as int);

  Map<String, Object?> toMap() => {
    AlertFields.id: id,
    AlertFields.status: status.toString().split('.').last,
    AlertFields.title: title,
    AlertFields.isImportant: isImportant ? 1 : 0,
    AlertFields.description: description,
    AlertFields.setTime: setTime.toIso8601String(),
    AlertFields.expireTime: expireTime.toIso8601String(),
    AlertFields.repeatIntervalTimeInDays: repeatIntervalTimeInDays,
    AlertFields.repeatIntervalTimeInWeeks: repeatIntervalTimeInWeeks,
    AlertFields.repeatIntervalTimeInHours: repeatIntervalTimeInHours,
    AlertFields.repeatIntervalTimeInMinutes: repeatIntervalTimeInMinutes
  };

  bool isRepeating(){
    return repeatIntervalTimeInDays != 0 ||
        repeatIntervalTimeInWeeks != 0 ||
        repeatIntervalTimeInHours != 0 ||
        repeatIntervalTimeInMinutes != 0;
  }
}
