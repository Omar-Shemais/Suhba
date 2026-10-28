class KhatmahModel {
  final String id;
  final String title;
  final int targetDays;
  final DateTime startDate;
  final List<int> completedJuz;
  final int currentJuz;
  final bool isCompleted;

  KhatmahModel({
    required this.id,
    required this.title,
    required this.targetDays,
    required this.startDate,
    this.completedJuz = const [],
    this.currentJuz = 1,
    this.isCompleted = false,
  });

  /// كم جزء في اليوم
  double get partsPerDay => 30.0 / targetDays;

  /// كم حزب في اليوم
  double get ahzabPerDay => 60.0 / targetDays;

  /// كم صفحة في اليوم (مصحف المدينة 604 صفحات)
  int get pagesPerDay => (604.0 / targetDays).ceil();

  /// المقدار المقترح بعد كل صلاة فريضة
  int get pagesPerPrayer => (pagesPerDay / 5.0).ceil();

  /// نسبة الإنجاز المئوية (0 - 100)
  int get percentage => ((completedJuz.length / 30.0) * 100).clamp(0, 100).toInt();

  /// نسبة الإنجاز كقيمة عشرية (0.0 - 1.0)
  double get progress => (completedJuz.length / 30.0).clamp(0.0, 1.0);

  /// عدد الأيام المنقضية
  int get daysPassed {
    final diff = DateTime.now().difference(startDate).inDays + 1;
    return diff < 1 ? 1 : diff;
  }

  /// الأيام المتبقية
  int get daysRemaining {
    final remaining = targetDays - daysPassed;
    return remaining < 0 ? 0 : remaining;
  }

  /// الجزء المستهدف لليوم الحالي
  int get targetJuzForToday {
    final target = (daysPassed * partsPerDay).ceil();
    return target.clamp(1, 30);
  }

  /// هل تم إنجاز ورد اليوم
  bool get isTodayPortionDone => completedJuz.contains(targetJuzForToday);

  KhatmahModel copyWith({
    String? id,
    String? title,
    int? targetDays,
    DateTime? startDate,
    List<int>? completedJuz,
    int? currentJuz,
    bool? isCompleted,
  }) {
    return KhatmahModel(
      id: id ?? this.id,
      title: title ?? this.title,
      targetDays: targetDays ?? this.targetDays,
      startDate: startDate ?? this.startDate,
      completedJuz: completedJuz ?? this.completedJuz,
      currentJuz: currentJuz ?? this.currentJuz,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'targetDays': targetDays,
      'startDate': startDate.toIso8601String(),
      'completedJuz': completedJuz,
      'currentJuz': currentJuz,
      'isCompleted': isCompleted,
    };
  }

  factory KhatmahModel.fromJson(Map<String, dynamic> json) {
    return KhatmahModel(
      id: json['id'] as String? ?? '1',
      title: json['title'] as String? ?? 'ختمتي المباركة',
      targetDays: json['targetDays'] as int? ?? 30,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : DateTime.now(),
      completedJuz: (json['completedJuz'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      currentJuz: json['currentJuz'] as int? ?? 1,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}
