class FirebaseAuthExceptions {
  static const String userNotFound = 'user-not-found';
  static const String wrongPassword = 'wrong-password';
  static const String weakPassword = 'weak-password';
  static const String emailAlreadyInUse = 'email-already-in-use';
  static const String invalidEmail = 'invalid-email';
  static const String operationNotAllowed = 'operation-not-allowed';
  static const String userDisabled = 'user-disabled';
  static const String tooManyRequests = 'too-many-requests';
  static const String networkRequestFailed = 'network-request-failed';

  static String getErrorMessage(String code) {
    switch (code) {
      case userNotFound:
        return 'Usuario no encontrado.';
      case wrongPassword:
        return 'Contraseña incorrecta.';
      case weakPassword:
        return 'La contraseña es débil. Debe tener al menos 6 caracteres.';
      case emailAlreadyInUse:
        return 'El correo electrónico ya está en uso.';
      case invalidEmail:
        return 'El correo electrónico es inválido.';
      case operationNotAllowed:
        return 'Operación no permitida.';
      case userDisabled:
        return 'El usuario ha sido deshabilitado.';
      case tooManyRequests:
        return 'Demasiados intentos. Intente más tarde.';
      case networkRequestFailed:
        return 'Error de red. Por favor, revise su conexión a internet.';
      default:
        return 'Error desconocido al autenticar.';
    }
  }
}
