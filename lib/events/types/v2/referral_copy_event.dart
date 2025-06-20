import '../../event.dart';

class ReferralCopyEvent extends Event {
  const ReferralCopyEvent({required this.data})
      : super(name: Event.REFERRAL_COPY);

  final Data data;

  factory ReferralCopyEvent.from(Map<String, dynamic> json) {
    final data = Data(referralCode: json['data']['referralCode']);

    return ReferralCopyEvent(data: data);
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'data': data.toJson()};
  }
}

class Data {
  final String referralCode;

  const Data({required this.referralCode});

  Map<String, dynamic> toJson() => {'referralCode': referralCode};
}
