import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'package:core/websocket/ws_message.dart';
import 'package:dio/dio.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketClient {
  final String _baseUrl;
  final Dio _dio;

  WebSocketChannel? _channel;
  final _controller = StreamController<WsMessage>.broadcast();
  Timer? _reconnectTimer;
  bool _disposed = false;

  /// True between [connect] and [disconnect]: only then does it reconnect.
  bool _active = false;

  Stream<WsMessage> get messages => _controller.stream;

  WebSocketClient({required String baseUrl, required Dio dio})
    : _baseUrl = baseUrl,
      _dio = dio;

  /// Connects and keeps reconnecting until [disconnect]. Without a session
  /// (the ticket is refused with 401) it stops until the next [connect].
  Future<void> connect() async {
    if (_disposed) return;
    _active = true;
    _reconnectTimer?.cancel();

    try {
      final nonce = await _exchangeTokenForNonce();
      if (!_active) return;
      if (nonce == null) {
        _scheduleReconnect();
        return;
      }
      await _closeChannel();

      final httpUri = Uri.parse(_baseUrl);
      final wsScheme = httpUri.scheme == 'https' ? 'wss' : 'ws';
      final wsUri = Uri(
        scheme: wsScheme,
        host: httpUri.host,
        port: httpUri.port,
        path: '/api/v1/ws',
      );

      dev.log('[ProfileWS] Connecting to $wsUri');

      final channel = IOWebSocketChannel.connect(
        wsUri,
        headers: {'Authorization': nonce},
      );
      _channel = channel;
      await channel.ready;

      channel.stream.listen(
        (data) {
          if (_disposed || !_active || _channel != channel) return;
          try {
            final json = jsonDecode(data as String) as Map<String, dynamic>;
            final wsMessage = WsMessage.fromJson(json);
            dev.log('[ProfileWS] Parsed message: type=${wsMessage.type}');
            _controller.add(wsMessage);
          } catch (e) {
            dev.log('[ProfileWS] Failed to parse message: $e');
          }
        },
        onDone: () {
          if (_channel == channel) _scheduleReconnect();
        },
        onError: (e) {
          if (_channel == channel) _scheduleReconnect();
        },
      );
    } catch (e) {
      dev.log('[ProfileWS] Connection failed: $e');
      _scheduleReconnect();
    }
  }

  Future<String?> _exchangeTokenForNonce() async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/ws/token',
      );
      return response.data?['token'] as String?;
    } on DioException catch (e) {
      // No session: nothing to listen to until someone signs in.
      if (e.response?.statusCode == 401) _active = false;
      dev.log('[ProfileWS] Token exchange failed: $e');
      return null;
    } catch (e) {
      dev.log('[ProfileWS] Token exchange failed: $e');
      return null;
    }
  }

  void _scheduleReconnect() {
    if (_disposed || !_active) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), connect);
  }

  /// Closes the connection and stops reconnecting, e.g. on logout, so the
  /// previous user's events stop arriving.
  Future<void> disconnect() async {
    _active = false;
    _reconnectTimer?.cancel();
    await _closeChannel();
  }

  Future<void> _closeChannel() async {
    final channel = _channel;
    _channel = null;
    await channel?.sink.close();
  }

  Future<void> dispose() async {
    _disposed = true;
    await disconnect();
    await _controller.close();
  }
}
