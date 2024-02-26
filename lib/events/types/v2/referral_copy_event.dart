import '../../event.dart';

class ReferralCopyEvent extends Event {

  static const EVENT_NAME = "REFERRAL_COPY";

  ReferralCopyEvent({required this.data})
      : super(name: EVENT_NAME);

  final Data data;

  factory ReferralCopyEvent.from(Map<String, dynamic> json) {

    var data = Data(
        referralCode: json['data']['referralCode']
    );

    return ReferralCopyEvent(
        data: data
    );
  }

  Map toJson() {
    Map? data = this.data.toJson();
    return {'name': name, 'data': data};
  }

}

class Data {
  String referralCode;

  Data({required this.referralCode});

  Map toJson() => {
    'referralCode': referralCode
  };
}
