import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'remote_config_service.dart';

void main() => runApp(ConfigSampleApp());

class ConfigSampleApp extends StatefulWidget {
  @override
  State<ConfigSampleApp> createState() => _ConfigSampleAppState();
}

class _ConfigSampleAppState extends State<ConfigSampleApp> {
  Map<String, dynamic>? config;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    try {
      config = await RemoteConfigService.fetchConfig();
      _checkForUpdate();
    } catch (e) {
      print('Config load failed: $e');
    }
    setState(() => isLoading = false);
  }

  Future<void> _checkForUpdate() async {
    final info = await PackageInfo.fromPlatform();
    final current = info.version;
    final remote = config?['app_version'] ?? current;

    if (_isNewer(remote, current)) {
      final force = config?['force_update'] ?? false;
      final message = config?['update_message'] ?? 'Update available';
      final apkUrl = config?['apk_url'];

      Future.delayed(Duration.zero, () {
        showDialog(
          context: context,
          barrierDismissible: !force,
          builder: (_) => AlertDialog(
            title: Text("Update Available"),
            content: Text(message),
            actions: [
              if (!force)
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Later")),
              ElevatedButton(
                onPressed: () async {
                  if (apkUrl != null) {
                    final uri = Uri.parse(apkUrl);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  }
                },
                child: Text("Update Now"),
              )
            ],
          ),
        );
      });
    }
  }

  bool _isNewer(String remote, String current) {
    final r = remote.split('.').map(int.parse).toList();
    final c = current.split('.').map(int.parse).toList();
    for (int i = 0; i < r.length; i++) {
      if (r[i] > c[i]) return true;
      if (r[i] < c[i]) return false;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return MaterialApp(home: Scaffold(body: Center(child: CircularProgressIndicator())));
    }

    final colorStr = config?['theme_color'] ?? '#2196F3';
    final color = Color(int.parse(colorStr.replaceFirst('#', '0xff')));
    final font = config?['font_family'] ?? 'Roboto';
    final showBanner = config?['show_banner'] ?? false;
    final bannerMsg = config?['banner_message'] ?? '';

    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.deepPurple, fontFamily: font),
      home: Scaffold(
        appBar: AppBar(title: Text("Remote Config App")),
        body: Column(
          children: [
            if (showBanner)
              Container(
                padding: EdgeInsets.all(12),
                color: color.withOpacity(0.1),
                child: Text(
                  bannerMsg,
                  style: TextStyle(color: color),
                ),
              ),
            Expanded(
              child: Center(
                child: Text(
                  "🎉 Config Loaded Successfully!",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
