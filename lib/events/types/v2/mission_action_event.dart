import '../../event.dart';

class MissionActionEvent extends Event {
  const MissionActionEvent({required this.data})
      : super(name: Event.MISSION_ACTION);

  final Data data;

  factory MissionActionEvent.from(Map<String, dynamic> json) {
    final data = Data(
      missionType: json['data']['missionType'],
      missionEvent: json['data']['missionEvent'],
    );

    return MissionActionEvent(data: data);
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'data': data.toJson()};
  }
}

class Data {
  final String missionType;
  final String missionEvent;

  const Data({required this.missionType, required this.missionEvent});

  Map<String, dynamic> toJson() =>
      {'missionType': missionType, 'missionEvent': missionEvent};
}
