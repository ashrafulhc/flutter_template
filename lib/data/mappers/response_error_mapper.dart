import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_template/domain/common/errors/response_error.dart';

/// Converts any raw exception thrown by Dio, the OS, or other infrastructure
/// into a [ResponseError] — the project's unified error vocabulary.
///
/// Call this only at the repository boundary (inside catch blocks in
/// repository implementations). Never call this from domain or presentation.
ResponseError mapToResponseError(Object error) {
  if (error is ResponseError) {
    return error;
  } else if (error is SocketException) {
    return const ResponseError.noInternetConnection();
  } else if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.sendTimeout:
        return const ResponseError.sendTimeout();
      case DioExceptionType.connectionTimeout:
        return const ResponseError.connectTimeout();
      case DioExceptionType.receiveTimeout:
        return const ResponseError.receiveTimeout();
      case DioExceptionType.unknown:
        return const ResponseError.unexpectedError();
      case DioExceptionType.cancel:
        return const ResponseError.requestCancelled();
      case DioExceptionType.badCertificate:
        return const ResponseError.badCertificate();
      case DioExceptionType.connectionError:
        return const ResponseError.connectionError();
      case DioExceptionType.badResponse:
        switch (error.response!.statusCode) {
          case 400:
            return const ResponseError.badRequest();
          case 401:
            return const ResponseError.unauthorized();
          case 404:
            return const ResponseError.notFound();
          case 409:
            return const ResponseError.conflict();
          case 422:
            return const ResponseError.unprocessableEntity();
          case 429:
            return const ResponseError.tooManyRequests();
          case 500:
          case 502:
            return const ResponseError.internalServerError();
          default:
            final statusCode = error.response!.statusCode;
            throw Exception('Received invalid status code: $statusCode');
        }
    }
  } else if (error is TypeError) {
    // TODO: Log it
  }
  return const ResponseError.unexpectedError();
}
