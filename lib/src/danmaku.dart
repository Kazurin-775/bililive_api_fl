class DanmakuOptions {
  final DmPosition position;
  final DmFontSize fontSize;
  final int color;

  const DanmakuOptions({
    this.position = DmPosition.flying,
    this.fontSize = DmFontSize.normal,
    this.color = 0xFFFFFF,
  });
}

enum DmPosition {
  flying,
  onTop,
  onBottom,
  reversed,
  special,
}

extension DmPositionExt on DmPosition {
  int asInt() {
    switch (this) {
      case DmPosition.flying:
        return 1;
      case DmPosition.onTop:
        return 5;
      case DmPosition.onBottom:
        return 4;
      case DmPosition.reversed:
        return 6;
      case DmPosition.special:
        return 9;
    }
  }
}

enum DmFontSize {
  xxSmall,
  xSmall,
  small,
  normal,
  large,
  xLarge,
  xxLarge,
}

extension DmFontSizeExt on DmFontSize {
  int asInt() {
    switch (this) {
      case DmFontSize.xxSmall:
        return 13;
      case DmFontSize.xSmall:
        return 16;
      case DmFontSize.small:
        return 18;
      case DmFontSize.normal:
        return 25;
      case DmFontSize.large:
        return 36;
      case DmFontSize.xLarge:
        return 45;
      case DmFontSize.xxLarge:
        return 64;
    }
  }
}
