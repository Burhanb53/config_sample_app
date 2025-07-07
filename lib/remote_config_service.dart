import 'dart:convert';
import 'package:http/http.dart' as http;

class RemoteConfigService {
  static const String configUrl =
      'https://github.com/Burhanb53/config_sample_app/blob/main/remote/config.json';

  static Future<Map<String, dynamic>> fetchConfig() async {
    final response = await http.get(Uri.parse(configUrl));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch remote config');
    }
  }
}
