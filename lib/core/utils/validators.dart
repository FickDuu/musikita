//input validation utils - reusable for forms
import 'package:musikita/core/constants/app_strings.dart';
import 'package:musikita/core/constants/app_limits.dart';

class Validators {
  Validators._();

  //validate email
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return AppStrings.invalidEmail;
    }
    return null;
  }

  //validate password strength
  static String? password(String? value){
    if(value == null || value.isEmpty){
      return AppStrings.fieldRequired;
    }
    if(value.length < AppLimits.passwordMinLength){
      return 'Password must be at least ${AppLimits.passwordMinLength} characters';
    }
    return null;
  }

  //validate pw confirmation match
  static String? confirmPassword(String? value, String? password){
    if(value == null || value.isEmpty){
      return AppStrings.fieldRequired;
    }
    if(value != password){
      return AppStrings.passwordMismatch;
    }
    return null;
  }

  //validate username
  static String? username(String? value){
    if(value == null || value.isEmpty){
      return AppStrings.fieldRequired;
    }
    return null;
  }

  //generic required field
  static String? required(String? value){
    if(value == null || value.isEmpty){
      return AppStrings.fieldRequired;
    }
    return null;
  }

  //validate min length
  static String? minLength(String? value, int length){
    if(value == null || value.isEmpty){
      return AppStrings.fieldRequired;
    }
    if(value.length < length){
      return 'Must be at least $length characters';
    }
    return null;
  }
}