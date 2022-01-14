// TODO Implement this library.

import 'package:package_info/package_info.dart';

bool get isInDebugMode {
  bool inDebugMode = false;
  assert(inDebugMode = true);
  return inDebugMode;
}



// State of the deployment
class PackageInformation {

  PackageInformation() {
    initPackageInfo();
  }

  String _appName = '';
  String _packageName = '';
  String _version = '';
  String _buildNumber = '';

  String get appName => _appName;
  String get packageName => _packageName;
  String get version => _version;
  String get buildNumber => _buildNumber;

  Future<void> initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    _appName = info.appName;
    _packageName = info.packageName;
    _version = info.version;
    _buildNumber = info.buildNumber;
  }

}
