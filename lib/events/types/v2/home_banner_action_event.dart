import '../../event.dart';

class HomeBannerActionEvent extends Event {
  const HomeBannerActionEvent({required this.data})
      : super(name: Event.HOME_BANNER_ACTION);

  final Data data;

  factory HomeBannerActionEvent.from(Map<String, dynamic> json) {
    final data = Data(data: json['data']);

    return HomeBannerActionEvent(data: data);
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'data': data.toJson()};
  }
}

class Data {
  final String data;

  const Data({required this.data});

  Map<String, dynamic> toJson() => {'data': data};
}
