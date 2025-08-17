
class Challenge {
  final String id;
  final String theme;
  final int days;
  final double planned;
  final double spend;
  final int tx;
  final int createdAtMs;

  Challenge({
    required this.id,
    required this.theme,
    required this.days,
    required this.planned,
    required this.spend,
    required this.tx,
    required this.createdAtMs,
  });

  Challenge copyWith({String? id, String? theme, int? days, double? planned, double? spend, int? tx, int? createdAtMs}) {
    return Challenge(
      id: id ?? this.id,
      theme: theme ?? this.theme,
      days: days ?? this.days,
      planned: planned ?? this.planned,
      spend: spend ?? this.spend,
      tx: tx ?? this.tx,
      createdAtMs: createdAtMs ?? this.createdAtMs,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'theme': theme,
        'days': days,
        'planned': planned,
        'spend': spend,
        'tx': tx,
        'createdAtMs': createdAtMs,
      };

  static Challenge fromMap(Map<String, dynamic> m) => Challenge(
        id: m['id'] as String,
        theme: m['theme'] as String,
        days: (m['days'] as num).toInt(),
        planned: (m['planned'] as num).toDouble(),
        spend: (m['spend'] as num).toDouble(),
        tx: (m['tx'] as num).toInt(),
        createdAtMs: (m['createdAtMs'] as num).toInt(),
      );

  double get score {
    if (planned <= 0) return 0;
    final raw = (planned - spend) / planned;
    final s = (raw < 0 ? 0 : raw) * 100.0;
    return double.parse(s.toStringAsFixed(1));
  }
}
