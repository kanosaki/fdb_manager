import 'dart:math';

String numToBytesStr(num size,
    {int? precision, int? underPointDigits, bool padSuffix = false}) {
  var tmpSize = size;
  final suffixes = padSuffix ? ['  B', 'KiB', 'MiB', 'GiB', 'TiB', 'EiB'] : ['B', 'KiB', 'MiB', 'GiB', 'TiB', 'EiB'];
  var i = 0;
  for (; i < suffixes.length; i++) {
    if (tmpSize < 1024) {
      break;
    }
    tmpSize ~/= 1024;
  }
  final fpSize = size / pow(1024, i);
  if (underPointDigits != null) {
    return '${fpSize.toStringAsFixed(underPointDigits)}${suffixes[i]}';
  }
  if (precision != null) {
    return '${fpSize.toStringAsPrecision(precision)}${suffixes[i]}';
  }
  return '${fpSize.toStringAsPrecision(4)}${suffixes[i]}';
}

String intToSuffixedStr(num size) {
  var tmpSize = size;
  const suffixes = ['', 'K', 'M', 'G', 'T', 'E'];
  var i = 0;
  for (; i < suffixes.length; i++) {
    if (tmpSize < 1000) {
      break;
    }
    tmpSize ~/= 1000;
  }
  final fpSize = size / pow(1000, i);
  return '${fpSize.toStringAsPrecision(4)}${suffixes[i]}';
}
