class Event {
  String name;
  Map<String, dynamic> data;
  Event({data, name}) {
    this.name = name;
    this.data = data;
  }

  Event.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        data = json['data'];
}
