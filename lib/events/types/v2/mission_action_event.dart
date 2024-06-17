import '../../event.dart';

class MissionActionEvent extends Event {

  static const EVENT_NAME = "MISSION_ACTION";

  MissionActionEvent({required this.data})
      : super(name: EVENT_NAME);

  final Data data;

  factory MissionActionEvent.from(Map<String, dynamic> json) {

    var data = Data(
        missionType: json['data']['missionType'],
        missionEvent: json['data']['missionEvent']
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
  String missionType;
  String missionEvent;

  Data({required this.missionType, required this.missionEvent});

  Map toJson() => {
    'missionType': missionType,
    'missionEvent': missionEvent
  };
}
