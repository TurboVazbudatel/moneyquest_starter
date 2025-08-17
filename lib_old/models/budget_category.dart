
class BudgetCategory {
  final String id;
  final String name;
  final String icon; // emoji
  BudgetCategory({required this.id, required this.name, required this.icon});

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'icon': icon};
  static BudgetCategory fromMap(Map<String, dynamic> m) =>
      BudgetCategory(id: m['id'], name: m['name'], icon: m['icon']);
}
