///We use the same table for already used money as well as for people waiting for help
/// if [date] is null it means that this is a waiting entry
class Usage {
  const Usage(this.id, this.whatFor, this.amount, this.date, this.image);

  factory Usage.fromMap(Map<String, dynamic> data) {
    return Usage(data['id'], data['usage'], data['value'], data['usage_date'],
        data['storage_image_name']);
  }

  bool get isWaitingCause => date == null;

  final int id;
  final String whatFor;
  final int amount;
  final String? date;
  final String? image;
  String? get imageLink => image == null
      ? null
      : 'https://backend-3fad0791.nhost.app/storage/o/public/$image';

  @override
  String toString() {
    return 'Usage{id: $id, whatFor: $whatFor, amount: $amount, createdAt: $date}';
  }
}
