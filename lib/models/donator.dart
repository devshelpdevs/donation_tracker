class Donator {
  const Donator(this.id, this.name, this.amount, this.date);

  factory Donator.fromMap(Map<String, dynamic> data) {
    return Donator(
        data['id'], data['donator'], data['value'], data['donation_date']);
  }

  final int id;
  final String name;
  final int amount;
  final String date;

  @override
  String toString() {
    return 'Donator{id: $id, name: $name, amount: $amount, createdAt: $date}';
  }
}
