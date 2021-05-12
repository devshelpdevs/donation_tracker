import 'package:donation_tracker/constants.dart';

///We use the same table for already used money as well as for people waiting for help
/// if [date] is null it means that this is a waiting entry
class Usage {
  const Usage({
    this.id,
    required this.whatFor,
    required this.amount,
    this.date,
    this.name,
    this.hiddenName,
    this.image,
    this.imageReceiver,
  });

  factory Usage.fromMap(Map<String, dynamic> data) {
    return Usage(
        id: data['id'],
        whatFor: data['usage'],
        amount: data['value'],
        date: data['usage_date'],
        name: data['receivers_name'],
        hiddenName: data['receiver_hidden_name'],
        image: data['storage_image_name'],
        imageReceiver: data['storage_image_name_person']);
  }

  bool get isWaitingCause => date == null;

  final int? id;
  final String whatFor;
  final int amount;
  final String? date;
  final String? name;
  final String? hiddenName;
  final String? image;
  final String? imageReceiver;
  String? get imageLink =>
      image == null ? null : '$nhostBaseUrl/storage/o/public/$image';
  String? get imageReceiverLink => imageReceiver == null
      ? null
      : '$nhostBaseUrl/storage/o/public/$imageReceiver';

  Usage copyWith({
    int? id,
    String? whatFor,
    int? amount,
    String? date,
    String? name,
    String? hiddenName,
    String? image,
    String? imageReceiver,
  }) =>
      Usage(
        id: id ?? this.id,
        whatFor: whatFor ?? this.whatFor,
        amount: amount ?? this.amount,
        date: date ?? this.date,
        name: name ?? this.name,
        hiddenName: hiddenName ?? this.hiddenName,
        image: image ?? this.image,
        imageReceiver: imageReceiver ?? this.imageReceiver,
      );

  @override
  String toString() {
    return 'Usage{id: $id, whatFor: $whatFor, amount: $amount, createdAt: $date}';
  }
}
