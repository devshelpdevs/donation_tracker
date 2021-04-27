class Donation {
  const Donation(this.id, this.name, this.amount, this.date);

  factory Donation.fromMap(Map<String, dynamic> data) {
    return Donation(data['id'], data['donator'] ?? 'anonymous', data['value'],
        data['donation_date']);
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
