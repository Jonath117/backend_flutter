import 'package:dio/dio.dart';

String getFriendlyErrorMessage(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Se agotó el tiempo de conexión. Verifica tu internet e inténtalo de nuevo.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;
        String? serverMessage;
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          serverMessage = data['message'];
        }

        if (statusCode == 400) {
          return serverMessage ?? 'Solicitud incorrecta. Verifica los datos.';
        } else if (statusCode == 401) {
          return 'No estás autorizado. Tu sesión pudo haber expirado.';
        } else if (statusCode == 403) {
          return 'No tienes permisos para realizar esta acción.';
        } else if (statusCode == 404) {
          return 'No se encontró la información solicitada (404).';
        } else if (statusCode == 500) {
          return 'Error en el servidor. Inténtalo más tarde.';
        }
        return 'El servidor respondió con un error ($statusCode).';
      case DioExceptionType.cancel:
        return 'La solicitud fue cancelada.';
      case DioExceptionType.connectionError:
        return 'Error de conexión. Asegúrate de tener acceso a internet.';
      case DioExceptionType.unknown:
      default:
        return 'Ocurrió un error inesperado al conectar con el servidor.';
    }
  }
  
  // Para errores genéricos
  return 'Ha ocurrido un error inesperado. Por favor, intenta de nuevo.';
}
