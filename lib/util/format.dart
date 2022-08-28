// formatDurationsObj converts duration value in status.json into duration string like "<hour>h<minute>m<seconds>s"
String formatDurationsObj(Object secondsObj) {
  double seconds = 0.0;
  if (secondsObj is num) {
    seconds = secondsObj.toDouble();
  } else {
    throw Exception('invalid duration type ${secondsObj.runtimeType}');
  }
  return formatDurations(seconds);
}

String formatDurationsFixed(num seconds) {
  final duration = Duration(milliseconds: (seconds * 1000).round());
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  return "${twoDigits(duration.inHours)}h${twoDigitMinutes}m${twoDigitSeconds}s";
}

String formatDurations(num seconds) {
  final duration = Duration(milliseconds: (seconds * 1000).round());
  int m = duration.inMinutes.remainder(60);
  int s = duration.inSeconds.remainder(60);
  if (duration.inHours > 0) {
    return "${duration.inHours}h${m}m${s}s";
  }
  if (duration.inMinutes > 0) {
    return "${m}m${s}s";
  }
  final ms = duration.inMilliseconds.remainder(60*1000).toDouble();
  return "${(ms / 1000.0).toStringAsFixed(1)}s";
}

String formatPercentage(double value) {
  return '${(value * 100).toStringAsFixed(2)}%';
}
