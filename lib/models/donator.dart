
class Donator {
  const Donator(this.id, this.name, this.amount, this.createdAt);

  factory Donator.fromMap(Map<String, dynamic> data) {
    return Donator(data['id'], data['donator'], data['value'], data['created_at']);
  }

  final int id;
  final String name;
  final int amount;
  final String createdAt;

  @override
  String toString() {
    return 'Donator{id: $id, name: $name, amount: $amount, createdAt: $createdAt}';
  }
}