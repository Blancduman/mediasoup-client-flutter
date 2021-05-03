enum Priority {
  VeryLow,
  Low,
  Medium,
  High,
}

extension PriorityExtension on Priority {
  static const Map<String, Priority> types = {
    'very-low': Priority.VeryLow,
    'low': Priority.Low,
    'medium': Priority.Medium,
    'high': Priority.High,
  };

  static const Map<Priority, String> values = {
    Priority.VeryLow: 'very-low',
    Priority.Low: 'low',
    Priority.Medium: 'medium',
    Priority.High: 'high',
  };

  static Priority fromString(String i) => types[i];
  String get value => values[this];
}