import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:brotli/brotli.dart';
import 'package:logger/logger.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'auth.dart';
import 'consts.dart';
import 'header.dart';

final Logger _logger = Logger(filter: ProductionFilter());

/// Bililive's WebSocket client, which receives room messages from the server.
class BililiveSocket {
  final String host;
  final int port;
  final int roomId;
  final String token;

  late final WebSocketChannel ws;

  BililiveSocket({
    required this.host,
    required this.port,
    required this.roomId,
    required this.token,
  }) {
    ws = IOWebSocketChannel.connect(Uri(
      scheme: 'wss',
      host: host,
      port: port,
      path: '/sub',
    ));
  }

  /// Start receiving messages from the server.
  ///
  /// This should only be called once. If this function ever returns, this indicates
  /// that the connection is terminated (unexpectedly) and should be re-created.
  ///
  /// Items returned from this stream are raw JSON objects that require manual
  /// parsing.
  Stream<dynamic> run() async* {
    // Send handshake packet
    var data = utf8.encode(jsonEncode(AuthMessage(
      uid: 0,
      roomId: roomId,
      key: token,
    )));
    var header = PacketHeader(
      packetLen: PacketHeader.size + data.length,
      headerLen: PacketHeader.size,
      protoVer: HEADER_DEFAULT_VERSION,
      opcode: OP_USER_AUTHENTICATION,
      seq: HEADER_DEFAULT_SEQUENCE,
    ).pack();
    var packet = header.buffer.asUint8List() + data;
    ws.sink.add(packet);

    // Start ping timer
    var timer = Timer.periodic(
        const Duration(seconds: 30), ((timer) => _sendHeartbeat()));
    try {
      yield* _receivePackets();
    } finally {
      _logger.w('WebSocket disconnected! This should be an error');
      // Stop sending ping packets
      timer.cancel();
    }
  }

  Stream<dynamic> _receivePackets() async* {
    await for (var message in ws.stream) {
      var data = Uint8List.fromList(message as List<int>);
      // Unpack header
      var header = PacketHeader.unpackFrom(data);
      assert(data.length == header.packetLen);
      assert(header.headerLen == PacketHeader.size);

      switch (header.opcode) {
        case OP_MESSAGE:
          // Server message
          switch (header.protoVer) {
            case BODY_PROTOCOL_VERSION_NORMAL:
              // Non-compressed message
              yield jsonDecode(utf8.decode(data.sublist(header.headerLen)));
              break;

            case BODY_PROTOCOL_VERSION_BROTLI:
              // Brotli-compressed bundle of messages
              var decompressed = Uint8List.fromList(
                  brotliDecode(data.sublist(header.headerLen)));
              int offset = 0;
              while (offset < decompressed.length) {
                var header2 =
                    PacketHeader.unpackFrom(decompressed, offset: offset);
                var content2 = decompressed.sublist(
                    offset + header2.headerLen, offset + header2.packetLen);
                yield jsonDecode(utf8.decode(content2));
                offset += header2.packetLen;
              }
              break;

            default:
              _logger.w(
                'Unknown protocol version ${header.protoVer} from server',
              );
          }
          break;

        case OP_CONNECT_SUCCESS:
          _logger.d('Bililive WebSocket connection successful');
          // The packet content should be {"code":0}, but we simply ignore it here
          break;
        case OP_HEARTBEAT_REPLY:
          // _logger.d('Received heartbeat reply from server');
          // Similar to above
          break;
        default:
          _logger.w(
            'Bililive WebSocket: warning: unknown opcode ${header.opcode} from server',
          );
      }
    }
  }

  _sendHeartbeat() {
    // _logger.d('Send heartbeat');
    // Send a heartbeat packet with no content
    var header = PacketHeader(
      packetLen: PacketHeader.size,
      headerLen: PacketHeader.size,
      protoVer: HEADER_DEFAULT_VERSION,
      opcode: OP_HEARTBEAT,
      seq: HEADER_DEFAULT_SEQUENCE,
    ).pack();
    ws.sink.add(header.buffer.asUint8List());
  }
}
