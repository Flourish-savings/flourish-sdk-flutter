import '../../event.dart';

class GiftCardCopyEvent extends Event {

  static const EVENT_NAME = "GIFT_CARD_COPY";

  GiftCardCopyEvent({required this.data})
      : super(name: EVENT_NAME);

  final Data data;

  factory GiftCardCopyEvent.from(Map<String, dynamic> json) {

    var data = Data(
        giftCardCode: json['data']
    );

    return GiftCardCopyEvent(
        data: data
    );
  }

  Map toJson() {
    Map? data = this.data.toJson();
    return {'name': name, 'data': data};
  }

}

class Data {
  String giftCardCode;

  Data({required this.giftCardCode});

  Map toJson() => {
    'giftCardCode': giftCardCode
  };
}

