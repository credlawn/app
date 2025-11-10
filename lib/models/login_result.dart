import 'user.dart';

enum LoginErrorType {
  invalidCredentials,   
  unauthorizedAccess,    
  permissionDenied,      
  networkError,         
  unknownError           
}

class LoginResult {
  final bool success;
  final User? user;
  final String? errorMessage;
  final LoginErrorType? errorType;

  LoginResult.success(this.user)
      : success = true,
        errorMessage = null,
        errorType = null;

  LoginResult.error(this.errorType, this.errorMessage)
      : success = false,
        user = null;

  bool get isInvalidCredentials => errorType == LoginErrorType.invalidCredentials;
  bool get isUnauthorizedAccess => errorType == LoginErrorType.unauthorizedAccess;
  bool get isPermissionDenied => errorType == LoginErrorType.permissionDenied;
  bool get isNetworkError => errorType == LoginErrorType.networkError;
}
