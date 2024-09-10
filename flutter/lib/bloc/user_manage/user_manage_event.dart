import 'package:meta/meta.dart';

@immutable
abstract class UserManageEvent {}

class LoadUserEvent extends UserManageEvent {}
