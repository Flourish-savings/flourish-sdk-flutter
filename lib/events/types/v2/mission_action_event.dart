import '../../event.dart';

class MissionActionEvent extends Event {

  static const EVENT_NAME = "MISSION_ACTION";

  MissionActionEvent({required this.data})
      : super(name: EVENT_NAME);

  final Data data;

  factory MissionActionEvent.from(Map<String, dynamic> json) {

    var data = Data(
        type: json['data']
    );

    return MissionActionEvent(
        data: data
    );
  }

  Map toJson() {
    Map? data = this.data.toJson();
    return {'name': name, 'data': data};
  }

}

class Data {
  String type;

  Data({required this.type});

  Map toJson() => {
    'type': type
  };
}