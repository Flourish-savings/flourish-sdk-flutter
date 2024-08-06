import '../event.dart';

class GenericEvent extends Event {

  GenericEvent({required this.event, this.data})
      : super(name: event);

  final String event;
  final Data? data;

  factory GenericEvent.from(Map<String, dynamic> json) {

    var data = Data(
        data: json['data'].toString()
    );

    return GenericEvent(
        event: json['eventName'],
        data: data
    );
  }

  Map toJson() {
    Map? data = this.data?.toJson();
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
