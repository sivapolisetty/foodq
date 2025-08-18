import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class NetworkLogger {
  static const String _tag = 'NETWORK';

  static void logRequest(
    String method,
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) {
    if (!kDebugMode) return;

    final logMessage = StringBuffer();
    logMessage.writeln('🚀 REQUEST: $method ${url.toString()}');
    
    if (headers != null && headers.isNotEmpty) {
      logMessage.writeln('📋 Headers:');
      headers.forEach((key, value) {
        // Hide sensitive information
        final displayValue = _sanitizeValue(key, value);
        logMessage.writeln('   $key: $displayValue');
      });
    }

    if (body != null) {
      logMessage.writeln('📦 Body:');
      logMessage.writeln(_formatBody(body));
    }

    developer.log(logMessage.toString(), name: _tag);
    print('${DateTime.now().toIso8601String()} | $_tag | ${logMessage.toString()}');
  }

  static void logResponse(
    http.Response response, {
    Duration? duration,
  }) {
    if (!kDebugMode) return;

    final logMessage = StringBuffer();
    logMessage.writeln('📥 RESPONSE: ${response.statusCode} ${response.request?.method} ${response.request?.url}');
    
    if (duration != null) {
      logMessage.writeln('⏱️ Duration: ${duration.inMilliseconds}ms');
    }

    logMessage.writeln('📋 Headers:');
    response.headers.forEach((key, value) {
      final displayValue = _sanitizeValue(key, value);
      logMessage.writeln('   $key: $displayValue');
    });

    if (response.body.isNotEmpty) {
      logMessage.writeln('📦 Body:');
      logMessage.writeln(_formatResponseBody(response.body));
    }

    developer.log(logMessage.toString(), name: _tag);
    print('${DateTime.now().toIso8601String()} | $_tag | ${logMessage.toString()}');
  }

  static void logError(
    String method,
    Uri url,
    Object error, {
    StackTrace? stackTrace,
    Duration? duration,
  }) {
    if (!kDebugMode) return;

    final logMessage = StringBuffer();
    logMessage.writeln('❌ ERROR: $method ${url.toString()}');
    
    if (duration != null) {
      logMessage.writeln('⏱️ Duration: ${duration.inMilliseconds}ms');
    }

    logMessage.writeln('🔥 Error: $error');
    
    if (stackTrace != null) {
      logMessage.writeln('📍 Stack trace:');
      logMessage.writeln(stackTrace.toString());
    }

    developer.log(logMessage.toString(), name: _tag, error: error, stackTrace: stackTrace);
    print('${DateTime.now().toIso8601String()} | $_tag | ${logMessage.toString()}');
  }

  static String _sanitizeValue(String key, String value) {
    final lowerKey = key.toLowerCase();
    if (lowerKey.contains('authorization') || 
        lowerKey.contains('apikey') || 
        lowerKey.contains('api-key') ||
        lowerKey.contains('bearer') ||
        lowerKey.contains('token')) {
      return '*' * 8; // Hide sensitive values
    }
    return value;
  }

  static String _formatBody(Object body) {
    try {
      if (body is String) {
        // Try to parse as JSON for pretty printing
        try {
          final json = jsonDecode(body);
          return const JsonEncoder.withIndent('  ').convert(json);
        } catch (_) {
          return body;
        }
      } else if (body is Map || body is List) {
        return const JsonEncoder.withIndent('  ').convert(body);
      } else {
        return body.toString();
      }
    } catch (e) {
      return 'Error formatting body: $e';
    }
  }

  static String _formatResponseBody(String body) {
    if (body.length > 1000) {
      // Truncate very long responses
      final truncated = body.substring(0, 1000);
      return _formatBody(truncated) + '\n... (truncated)';
    }
    return _formatBody(body);
  }
}

class LoggingHttpClient extends http.BaseClient {
  final http.Client _inner;

  LoggingHttpClient([http.Client? client]) : _inner = client ?? http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final stopwatch = Stopwatch()..start();
    
    // Log request
    NetworkLogger.logRequest(
      request.method,
      request.url,
      headers: request.headers,
      body: request is http.Request ? request.body : null,
    );

    try {
      final response = await _inner.send(request);
      stopwatch.stop();
      
      // Convert StreamedResponse to Response to log body
      final responseBody = await response.stream.bytesToString();
      final fullResponse = http.Response(
        responseBody,
        response.statusCode,
        headers: response.headers,
        request: request,
        reasonPhrase: response.reasonPhrase,
      );

      NetworkLogger.logResponse(fullResponse, duration: stopwatch.elapsed);
      
      // Return a new StreamedResponse with the same data
      return http.StreamedResponse(
        Stream.fromIterable([utf8.encode(responseBody)]),
        response.statusCode,
        headers: response.headers,
        request: request,
        reasonPhrase: response.reasonPhrase,
        contentLength: responseBody.length,
      );
    } catch (error, stackTrace) {
      stopwatch.stop();
      NetworkLogger.logError(
        request.method,
        request.url,
        error,
        stackTrace: stackTrace,
        duration: stopwatch.elapsed,
      );
      rethrow;
    }
  }

  @override
  void close() => _inner.close();
}