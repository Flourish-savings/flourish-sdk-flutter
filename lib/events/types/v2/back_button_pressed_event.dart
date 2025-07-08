import '../../event.dart';

class BackButtonPressedEvent extends Event {
  const BackButtonPressedEvent({required this.data})
      : super(name: Event.BACK_BUTTON_PRESSED);

  final Data data;

  factory BackButtonPressedEvent.from(Map<String, dynamic> json) {
    final data = Data(path: json['data']['path']);

    return BackButtonPressedEvent(data: data);
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'data': data.toJson()};
  }
}

class Data {
  final String path;

  const Data({required this.path});

  Map<String, dynamic> toJson() => {'path': path};
}
