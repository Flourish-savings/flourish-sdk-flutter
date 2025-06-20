import '../event.dart';

class BackEvent extends Event {
  const BackEvent({required this.data}) : super(name: Event.GO_BACK);

  final Data data;

  factory BackEvent.from(Map<String, dynamic> json) {
    final data = Data(route: json['data']['route']);

    return BackEvent(data: data);
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'data': data.toJson()};
  }
}

class Data {
  final String route;

  const Data({required this.route});

  Map<String, dynamic> toJson() => {'route': route};
}
