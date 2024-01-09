import '../../event.dart';

class HomeBannerActionEvent extends Event {

  static const EVENT_NAME = "HOME_BANNER_ACTION";

  HomeBannerActionEvent({required this.data})
      : super(name: EVENT_NAME);

  final Data data;

  factory HomeBannerActionEvent.from(Map<String, dynamic> json) {

    var data = Data(
        data: json['data']
    );

    return HomeBannerActionEvent(
        data: data
    );
  }

  Map toJson() {
    Map? data = this.data.toJson();
    return {'name': name, 'data': data};
  }

}

class Data {
  String data;

  Data({required this.data});

  Map toJson() => {
    'data': data
  };
}
