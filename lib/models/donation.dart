class Donation {
  const Donation(
      {this.id,
      this.name,
      this.hiddenName,
      required this.amount,
      required this.date});

  factory Donation.fromMap(Map<String, dynamic> data) {
    return Donation(
        id: data['id'],
        name: data['donator'],
        hiddenName: data['donator_hidden'],
        amount: data['value'],
        date: data['donation_date']);
  }

  final int? id;
  final String? name;
  final String? hiddenName;
  final int amount;
  final String date;

  @override
  String toString() {
    return 'Donator{id: $id, name: $name, amount: $amount, createdAt: $date}';
  }
}
