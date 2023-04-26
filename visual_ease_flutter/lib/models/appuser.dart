class AppUser {
  final String id;
  final String fullName;
  final String photoUrl;
  final String? imgString;
  final String email;
  final String userRole;
  final DateTime regTime;

  AppUser({
    required this.id,
    required this.fullName,
    required this.photoUrl,
    this.imgString,
    required this.email,
    required this.userRole,
    required this.regTime,
  });

  AppUser.fromMap(Map<String, dynamic> data)
      : id = data['id'] ?? "",
        fullName = data['fullName'] ?? "nil",
        photoUrl = data['photoUrl'] ?? "nil",
        imgString = data['imgString'] ?? "nil",
        email = data['email'] ?? "nil",
        userRole = data['userRole'] ?? "blind",
        regTime =
            data['regTime'] != null ? data['regTime'].toDate() : DateTime.now();

  Map<String, dynamic> toJson(keyword) {
    Map<String, dynamic> map = {
      'id': id,
      'fullName': fullName,
      'photoUrl': photoUrl,
      'keyword': keyword,
      'email': email,
      'userRole': userRole,
      'regTime': regTime,
    };
    if (imgString != null) map['imgString'] = imgString!;
    return map;
  }

  AppUser copyWith({
    String? id,
    String? fullName,
    String? photoUrl,
    String? imgString,
    String? email,
    String? userRole,
    DateTime? regTime,
  }) {
    return AppUser(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      photoUrl: photoUrl ?? this.photoUrl,
      imgString: imgString ?? this.imgString,
      email: email ?? this.email,
      userRole: userRole ?? this.userRole,
      regTime: regTime ?? this.regTime,
    );
  }
}
