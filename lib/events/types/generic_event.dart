import '../event.dart';

class GenericEvent extends Event {
  const GenericEvent({required this.event, this.data}) : super(name: event);

  final String event;
  final Data? data;

  factory GenericEvent.from(Map<String, dynamic> json) {
    final data = Data(data: json['data'].toString());

    return GenericEvent(event: json['eventName'], data: data);
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'data': data?.toJson()};
  }
}

class Data {
  final String data;
  const Data({required this.data});

  Map<String, dynamic> toJson() => {'data': data};
}
