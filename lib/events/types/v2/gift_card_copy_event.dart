import '../../event.dart';

class GiftCardCopyEvent extends Event {
  const GiftCardCopyEvent({required this.data})
      : super(name: Event.GIFT_CARD_COPY);

  final Data data;

  factory GiftCardCopyEvent.from(Map<String, dynamic> json) {
    final data = Data(giftCardCode: json['data']);

    return GiftCardCopyEvent(data: data);
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'data': data.toJson()};
  }
}

class Data {
  final String giftCardCode;

  const Data({required this.giftCardCode});

  Map<String, dynamic> toJson() => {'giftCardCode': giftCardCode};
}
