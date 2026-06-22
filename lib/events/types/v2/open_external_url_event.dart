import '../../event.dart';

/// Emitted when the web app asks the native host to open an absolute URL in
/// the device's default browser (escaping the WebView sandbox).
///
/// Event: [Event.OPEN_EXTERNAL_URL]. The SDK opens the URL itself via
/// `url_launcher` with `LaunchMode.externalApplication`; this event is also
/// published on the stream so integrators can observe the navigation.
class OpenExternalUrlEvent extends Event {
  const OpenExternalUrlEvent({required this.data})
      : super(name: Event.OPEN_EXTERNAL_URL);

  final Data data;

  factory OpenExternalUrlEvent.from(Map<String, dynamic> json) {
    final rawData = json['data'];
    final data = rawData is Map<String, dynamic> ? rawData : <String, dynamic>{};
    return OpenExternalUrlEvent(
      data: Data(url: data['url']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'data': data.toJson()};
  }
}

class Data {
  final String url;

  const Data({required this.url});

  Map<String, dynamic> toJson() => {'url': url};
}
