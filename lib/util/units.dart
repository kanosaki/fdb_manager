
import 'dart:math';

String intToBytesStr(int size) {
  var tmpSize = size;
  const suffixes = ['B', 'KiB', 'MiB', 'GiB', 'TiB', 'EiB'];
  var i = 0;
  for (; i < suffixes.length; i++) {
    if (tmpSize < 1024) {
      break;
    }
    tmpSize ~/= 1024;
  }
  final fpSize = size / pow(1024, i);
  return '${fpSize.toStringAsPrecision(4)}${suffixes[i]}';
}
