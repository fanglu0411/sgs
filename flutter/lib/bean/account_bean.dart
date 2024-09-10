import 'package:isar/isar.dart';

part 'account_bean.g.dart';

@collection
class AccountBean {
  @Id()
  late int id;

  late String url;
  late String username;
  String? nick;
  String? email;
  String? token;
  String? lastDataPath;

  AccountBean({
    required this.url,
    required this.username,
    this.nick,
    this.email,
    this.token,
    this.lastDataPath,
  });

  AccountBean.fromMap(Map map) {
    username = map['username'];
    email = map['email'];
    nick = map['nick'];
    url = map['url'];
    token = map['token'];
    lastDataPath = map['last_data_path'];
  }

  Map toJson() {
    return {
      'username': username,
      'nick': nick,
      'email': email,
      'url': url,
      'token': token,
      'last_data_path': lastDataPath,
    };
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is AccountBean && runtimeType == other.runtimeType && url == other.url && username == other.username && token == other.token;

  @override
  int get hashCode => url.hashCode ^ username.hashCode ^ token.hashCode;
}
