import 'dart:typed_data';

class AppInfo {
  final String id;
  final String name;
  final String packageName;
  final Uint8List? iconBytes;
  final bool isBlocked;

  AppInfo({
    required this.id,
    required this.name,
    required this.packageName,
    this.iconBytes,
    this.isBlocked = false,
  });

  AppInfo copyWith({
    bool? isBlocked,
    Uint8List? iconBytes,
  }) {
    return AppInfo(
      id: id,
      name: name,
      packageName: packageName,
      iconBytes: iconBytes ?? this.iconBytes,
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }
}
