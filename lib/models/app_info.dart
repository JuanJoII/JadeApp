class AppInfo {
  final String id;
  final String name;
  final String iconPath;
  final bool isBlocked;

  AppInfo({
    required this.id,
    required this.name,
    required this.iconPath,
    this.isBlocked = false,
  });

  AppInfo copyWith({bool? isBlocked}) {
    return AppInfo(
      id: id,
      name: name,
      iconPath: iconPath,
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }
}
