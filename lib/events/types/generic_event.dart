import '../event.dart';

class GenericEvent extends Event {
  static const EVENT_NAME = "Generic";

  GenericEvent({required this.name, required this.data})
      : super(name: EVENT_NAME);

  final String name;
  final Data data;

  factory GenericEvent.from(Map<String, dynamic> json) {

    var data = Data(
        data: json['data'].toString()
    );

    return GenericEvent(
        name: json['eventName'],
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
