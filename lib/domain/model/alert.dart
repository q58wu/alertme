const String tableAlert = 'tableAlert';

class AlertFields {
  static final List<String> values = [
    /// Add all fields
    id, title, isImportant, description, setTime, expireTime
  ];

  static const String id = '_id';
  static const String title = 'title';
  static const String isImportant = 'isImportant';
  static const String description = 'description';
  static const String setTime = 'tim:wqe';
  static const String expireTime = 'expireTime';
}

class Alert {
  final int? id;
  final bool isImportant;
  final String title;
  final String description;
  final DateTime setTime;
  final DateTime expireTime;

  const Alert(
      {this.id,
        required this.isImportant,
        required this.title,
        required this.description,
        required this.setTime,
        required this.expireTime});

  Alert copy({
    int? id,
    bool? isImportant,
    int? number,
    String? title,
    String? description,
    DateTime? setTime,
    DateTime? expireTime,
  }) =>
      Alert(
          id: id ?? this.id,
          isImportant: isImportant ?? this.isImportant,
          title: title ?? this.title,
          description: description ?? this.description,
          setTime: setTime ?? this.setTime,
          expireTime: expireTime ?? this.expireTime);

  static Alert fromJson(Map<String, Object?> json) => Alert(
      id: json[AlertFields.id] as int?,
      isImportant: json[AlertFields.isImportant] == 1,
      title: json[AlertFields.title] as String,
      description: json[AlertFields.description] as String,
      setTime: DateTime.parse(json[AlertFields.setTime] as String),
      expireTime: DateTime.parse(json[AlertFields.expireTime] as String));

  Map<String, Object?> toJson() => {
    AlertFields.id: id,
    AlertFields.title: title,
    AlertFields.isImportant: isImportant ? 1 : 0,
    AlertFields.description: description,
    AlertFields.setTime: setTime.toIso8601String(),
    AlertFields.expireTime: expireTime.toIso8601String(),
  };
}
