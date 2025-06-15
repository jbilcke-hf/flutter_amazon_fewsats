import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class FewsatsMarketplaceConfig {
  String priv;

  FewsatsMarketplaceConfig({this.priv = ''});

  Map<String, dynamic> toJson() => {'priv': priv};

  factory FewsatsMarketplaceConfig.fromJson(Map<String, dynamic> json) {
    return FewsatsMarketplaceConfig(priv: json['priv'] ?? '');
  }
}

/// Get the config file path
Future<String> _getConfigPath() async {
  final directory = await getApplicationSupportDirectory();
  final configDir = Directory('${directory.path}/fewsats');
  if (!await configDir.exists()) {
    await configDir.create(recursive: true);
  }
  return '${configDir.path}/marketplace.conf';
}

/// Get config from storage, creating if needed
Future<FewsatsMarketplaceConfig> getConfig() async {
  final configPath = await _getConfigPath();
  final configFile = File(configPath);
  
  if (await configFile.exists()) {
    try {
      final contents = await configFile.readAsString();
      final jsonData = jsonDecode(contents);
      return FewsatsMarketplaceConfig.fromJson(jsonData);
    } catch (e) {
      // If file is corrupted, return default config
      return FewsatsMarketplaceConfig();
    }
  } else {
    // Create default config file
    final defaultConfig = FewsatsMarketplaceConfig();
    await saveConfig(defaultConfig);
    return defaultConfig;
  }
}

/// Save config to file
Future<void> saveConfig(FewsatsMarketplaceConfig config) async {
  final configPath = await _getConfigPath();
  final configFile = File(configPath);
  final jsonString = jsonEncode(config.toJson());
  await configFile.writeAsString(jsonString);
}

/// Save config from a map
Future<void> saveConfigFromMap(Map<String, dynamic> configMap) async {
  final config = FewsatsMarketplaceConfig.fromJson(configMap);
  await saveConfig(config);
}