import 'user_model.dart';

class LoginModel {
  late final String status;
  late final String token;
  late final UserModel userModel;
  LoginModel.fromJson(Map<String, dynamic> jsondata) {
    status = jsondata['status'] ?? '';
    userModel = UserModel.fromJson(jsondata['data'] ?? {});
    token = jsondata['token'] ?? '';
  }
}
