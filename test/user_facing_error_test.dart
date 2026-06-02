import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siegeconnect/shared/user_facing_error.dart';

void main() {
  test('turns failed host lookup dio error into a short message', () {
    final error = DioException.connectionError(
      requestOptions: RequestOptions(path: 'https://example.invalid/sub'),
      reason:
          "SocketException: Failed host lookup: 'example.invalid' (OS Error: Этот хост неизвестен, errno = 11001)",
    );

    expect(
      userFacingErrorMessage(error),
      'Не удалось найти сервер. Проверь интернет, DNS или ссылку подписки.',
    );
  });
}
