
class TxEntry {
  final String id;
  final String challengeId;
  final String categoryId;
  final double amount;
  final String note;
  final int tsMs;

  TxEntry({
    required this.id,
    required this.challengeId,
    required this.categoryId,
    required this.amount,
    required this.note,
    required this.tsMs,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'challengeId': challengeId,
        'categoryId': categoryId,
        'amount': amount,
        'note': note,
        'tsMs': tsMs,
      };

  static TxEntry fromMap(Map<String, dynamic> m) => TxEntry(
        id: m['id'],
        challengeId: m['challengeId'],
        categoryId: m['categoryId'],
        amount: (m['amount'] as num).toDouble(),
        note: m['note'],
        tsMs: (m['tsMs'] as num).toInt(),
      );
}
