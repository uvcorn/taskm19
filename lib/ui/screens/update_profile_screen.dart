// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taskm/data/models/user_model.dart';
import 'package:taskm/data/service/network_client.dart';
import 'package:taskm/data/utils/urls.dart';
import 'package:taskm/ui/controllers/auth_controller.dart';
import 'package:taskm/ui/widgets/centered_circular_progress_indicator.dart';
import 'package:taskm/ui/widgets/screen_background.dart';
import 'package:taskm/ui/widgets/snack_bar_message.dart';
import 'package:taskm/ui/widgets/tm_appbar.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  XFile? _selectedPhoto;
  final TextEditingController _firstNameTEControler = TextEditingController();
  final TextEditingController _lastNameTEControler = TextEditingController();
  final TextEditingController _mailTEControler = TextEditingController();
  final TextEditingController _mobileTEControler = TextEditingController();
  final TextEditingController _passwordTEControler = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _updateProfileInProgress = false;

  @override
  void initState() {
    super.initState();
    UserModel userModel = AuthController.userModel!;
    _mailTEControler.text = userModel.email;
    _firstNameTEControler.text = userModel.firstName;
    _lastNameTEControler.text = userModel.lastName;
    _mobileTEControler.text = userModel.mobile;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TMAppbar(fromProfileScreen: true),
      body: ScreenBackground(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              autovalidateMode: AutovalidateMode.disabled,
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  Text(
                    'Update Profile',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  _photoPickerWidget(),
                  const SizedBox(height: 8),
                  _mailField(),
                  const SizedBox(height: 8),
                  _firstNameField(),
                  const SizedBox(height: 8),
                  _lastNameField(),
                  const SizedBox(height: 8),
                  _mobileField(),
                  const SizedBox(height: 8),
                  _passwordField(),
                  const SizedBox(height: 16),
                  Visibility(
                    visible: _updateProfileInProgress == false,
                    replacement: const CenteredCircularProgressIndicator(),
                    child: ElevatedButton(
                      onPressed: _onTapSubmitButton,
                      child: const Icon(Icons.arrow_circle_right_outlined),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _mailField() {
    return TextFormField(
      // textInputAction: TextInputAction.next,
      // keyboardType: TextInputType.emailAddress,
      controller: _mailTEControler,
      enabled: false, // Email is not editable
      decoration: const InputDecoration(hintText: 'Email'),
    );
  }

  Widget _firstNameField() {
    return TextFormField(
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.name,
      controller: _firstNameTEControler,
      decoration: const InputDecoration(hintText: 'First Name'),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter First Name';
        }
        return null;
      },
    );
  }

  Widget _lastNameField() {
    return TextFormField(
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.name,
      controller: _lastNameTEControler,
      decoration: const InputDecoration(hintText: 'Last Name'),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter Last Name';
        }
        return null;
      },
    );
  }

  Widget _mobileField() {
    return TextFormField(
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.number,
      controller: _mobileTEControler,
      decoration: const InputDecoration(hintText: 'Mobile'),
      validator: (String? value) {
        String phone = value?.trim() ?? '';
        RegExp regExp = RegExp(r'^(?:\+88|0088)?01[13-9]\d{8}$');
        if (regExp.hasMatch(phone) == false) {
          return 'Enter your valid phone';
        }
        return null;
      },
    );
  }

  Widget _passwordField() {
    return TextFormField(
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.visiblePassword,
      controller: _passwordTEControler,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        hintText: 'Password',
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
      ),
    );
  }

  Widget _photoPickerWidget() {
    return GestureDetector(
      onTap: _onTapPhotopicker,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              height: 50,
              width: 80,
              decoration: const BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
              alignment: Alignment.center,
              child: const Text('Photo', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(width: 8),
            Text(_selectedPhoto?.name ?? 'Select your photo'),
          ],
        ),
      ),
    );
  }

  Future<void> _onTapPhotopicker() async {
    XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _selectedPhoto = image;
      setState(() {});
    }
  }

  void _onTapSubmitButton() {
    if (_formKey.currentState?.validate() ?? false) {
      _updateProfile();
    }
  }

  Future<void> _updateProfile() async {
    _updateProfileInProgress = true;
    setState(() {});
    Map<String, dynamic> requestBody = {
      "email": _mailTEControler.text.trim(),
      "firstName": _firstNameTEControler.text.trim(),
      "lastName": _lastNameTEControler.text.trim(),
      "mobile": _mobileTEControler.text.trim(),
    };
    if (_passwordTEControler.text.isNotEmpty) {
      requestBody['password'] = _passwordTEControler.text;
    }

    if (_selectedPhoto != null) {
      List<int> imageBytes = await _selectedPhoto!.readAsBytes();
      String encodedImage = base64Encode(imageBytes);
      requestBody['photo'] = encodedImage;
    }
    NetworkResponse response = await NetworkClient.postRequest(
      url: Urls.updateProfileUrl,
      body: requestBody,
    );
    _updateProfileInProgress = false;
    setState(() {});
    if (response.isSuccess) {
      _passwordTEControler.clear();
      showSnackBarMessage(context, 'Updated successfully!');
    } else {
      showSnackBarMessage(context, response.errorMessage, true);
    }
  }
}
