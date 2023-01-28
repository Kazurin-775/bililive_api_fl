import 'dart:typed_data';

/// Bililive's WebSocket packet header type.
class PacketHeader {
  static const int size = 16;

  int packetLen;
  int headerLen;
  int protoVer;
  int opcode;
  int seq;

  PacketHeader({
    required this.packetLen,
    required this.headerLen,
    required this.protoVer,
    required this.opcode,
    required this.seq,
  });

  static PacketHeader unpackFrom(Uint8List data, {int offset = 0}) {
    assert(data.length >= offset + size);
    var byteData = ByteData.sublistView(data, offset, offset + size);
    return PacketHeader(
      packetLen: byteData.getInt32(0),
      headerLen: byteData.getInt16(4),
      protoVer: byteData.getInt16(6),
      opcode: byteData.getInt32(8),
      seq: byteData.getInt32(12),
    );
  }

  ByteData pack() {
    var data = ByteData(size);
    data.setUint32(0, packetLen);
    data.setUint16(4, headerLen);
    data.setUint16(6, protoVer);
    data.setUint32(8, opcode);
    data.setUint32(12, seq);
    return data;
  }
}
