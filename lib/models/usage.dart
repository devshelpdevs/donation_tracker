
class Usage {
  const Usage(this.id, this.whatFor, this.amount, this.createdAt);

  factory Usage.fromMap(Map<String, dynamic> data) {
    return Usage(data['id'], data['usage'], data['value'], data['created_at']);
  }

  final int id;
  final String whatFor;
  final String amount;
  final String createdAt;

  @override
  String toString() {
    return 'Usage{id: $id, whatFor: $whatFor, amount: $amount, createdAt: $createdAt}';
  }
}