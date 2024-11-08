class Task {
  final int id;
  final String content;
  final int status;

  Task({
    required this.id,
    required this.content,
    required this.status,
  });

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['Id'],
      content: map['Content'],
      status: map['Stats'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'Id': id,
      'Content': content,
      'Stats': status,
    };
  }
}

