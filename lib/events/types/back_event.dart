import '../event.dart';

class BackEvent extends Event {

  static const EVENT_NAME = "GoBack";

  BackEvent({required this.data})
      : super(name: EVENT_NAME);

  final Data data;

  factory BackEvent.from(Map<String, dynamic> json) {

    var data = Data(
        route: json['data']['route']
    );

    return BackEvent(
        data: data
    );
  }

  Map toJson() {
    Map? data = this.data.toJson();
    return {'name': name, 'data': data};
  }

}

class Data {
  String route;

  Data({required this.route});

  Map toJson() => {
    'route': route
  };
}
