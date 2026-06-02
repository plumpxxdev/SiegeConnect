import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

import 'privacy.dart';

String userFacingErrorMessage(Object error) {
  if (error is DioException) {
    return _dioErrorMessage(error);
  }
  if (error is SocketException) {
    return _socketErrorMessage(error);
  }
  if (error is TimeoutException) {
    return 'Превышено время ожидания. Проверь интернет и попробуй еще раз.';
  }

  final text = error.toString().trim();
  if (_isFailedHostLookup(text)) {
    return 'Не удалось найти сервер. Проверь интернет, DNS или ссылку подписки.';
  }
  if (_isConnectionTimeout(text)) {
    return 'Сервер не ответил вовремя. Проверь интернет или попробуй другой сервер.';
  }
  if (_isConnectionRefused(text)) {
    return 'Подключение отклонено. Попробуй другой сервер или обнови подписку.';
  }

  return redactNetworkText(_stripCommonPrefixes(text));
}

String _dioErrorMessage(DioException error) {
  final text = '${error.message ?? ''}\n${error.error ?? ''}'.trim();
  if (_isFailedHostLookup(text)) {
    return 'Не удалось найти сервер. Проверь интернет, DNS или ссылку подписки.';
  }

  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return 'Сервер не ответил вовремя. Проверь интернет или попробуй позже.';
    case DioExceptionType.badCertificate:
      return 'Сертификат сервера не прошел проверку. Проверь ссылку подписки.';
    case DioExceptionType.badResponse:
      final status = error.response?.statusCode;
      if (status == 401 || status == 403) {
        return 'Ссылка подписки не принята сервером. Проверь доступ или обнови ссылку.';
      }
      if (status == 404) {
        return 'Ссылка подписки не найдена. Проверь, что ссылка скопирована полностью.';
      }
      if (status != null && status >= 500) {
        return 'Сервер подписки сейчас недоступен. Попробуй позже.';
      }
      return 'Сервер вернул ошибку. Проверь ссылку подписки.';
    case DioExceptionType.cancel:
      return 'Операция отменена.';
    case DioExceptionType.connectionError:
    case DioExceptionType.unknown:
      if (_isConnectionRefused(text)) {
        return 'Подключение отклонено. Попробуй другой сервер или обнови подписку.';
      }
      return 'Не удалось подключиться. Проверь интернет, DNS или ссылку подписки.';
  }
}

String _socketErrorMessage(SocketException error) {
  final text = error.message;
  if (_isFailedHostLookup(text)) {
    return 'Не удалось найти сервер. Проверь интернет, DNS или ссылку подписки.';
  }
  if (_isConnectionRefused(text)) {
    return 'Подключение отклонено. Попробуй другой сервер или обнови подписку.';
  }
  return 'Сетевая ошибка. Проверь интернет и попробуй еще раз.';
}

bool _isFailedHostLookup(String text) {
  final normalized = text.toLowerCase();
  return normalized.contains('failed host lookup') ||
      normalized.contains('host lookup') ||
      normalized.contains('этот хост неизвестен') ||
      normalized.contains('no address associated with hostname');
}

bool _isConnectionTimeout(String text) {
  final normalized = text.toLowerCase();
  return normalized.contains('timed out') ||
      normalized.contains('timeout') ||
      normalized.contains('время ожидания');
}

bool _isConnectionRefused(String text) {
  final normalized = text.toLowerCase();
  return normalized.contains('connection refused') ||
      normalized.contains('подключение не установлено') ||
      normalized.contains('actively refused');
}

String _stripCommonPrefixes(String text) {
  return text
      .replaceFirst(RegExp(r'^(Exception|StateError|Bad state):\s*'), '')
      .replaceFirst(RegExp(r'^DioException\s*\[[^\]]+\]:\s*'), '')
      .trim();
}
