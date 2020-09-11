class Event {
  String name;
  Map<String, dynamic> data;

  Event.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        data = json['data'];
}
