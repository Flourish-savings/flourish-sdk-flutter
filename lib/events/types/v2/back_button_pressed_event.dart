import '../../event.dart';

class BackButtonPressedEvent extends Event {

  static const EVENT_NAME = "BACK_BUTTON_PRESSED";

  BackButtonPressedEvent({required this.data})
      : super(name: EVENT_NAME);

  final Data data;

  factory BackButtonPressedEvent.from(Map<String, dynamic> json) {

    var data = Data(
        path: json['data']['path']
    );

    return BackButtonPressedEvent(
        data: data
    );
  }

  Map toJson() {
    Map? data = this.data.toJson();
    return {'name': name, 'data': data};
  }

}

class Data {
  String path;

  Data({required this.path});

  Map toJson() => {
    'path': path
  };
}
