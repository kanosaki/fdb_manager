import 'package:charts_flutter/flutter.dart' as charts;
import 'dart:math' as math;

import 'package:fdb_manager/util/format.dart';

final _upperPrefixes = ['', 'K', 'M', 'G', 'T', 'P', 'E', 'Z', 'Y'];
final _iPrefixes = ['', 'Ki', 'Mi', 'Gi', 'Ti', 'Pi', 'Ei', 'Zi', 'Yi'];

charts.MeasureFormatter formatterBaseFn(num? max, List<String> upperPrefixes,
    {String unit = '', int base = 1000}) {
  return (m) {
    if (m == null) {
      return '';
    }
    if (max == null) {
      return '$m';
    }
    var divider = 1.0;
    for (int i = 0; i < upperPrefixes.length; i++) {
      if (m / divider < base) {
        return '${(m.toDouble() / divider).toStringAsFixed(1)}${upperPrefixes[i]}$unit';
      }
      divider *= base;
    }
    return '${m / math.pow(base, upperPrefixes.length)}${upperPrefixes.last}$unit';
  };
}

charts.MeasureFormatter formatDurationSeconds(num? max) {
  return (m) {
    if (m == null) {
      return '';
    }
    if (m == 0) {
      return '0';
    } else if (m < 1e-6) {
      return '${m * 1e9}ns';
    } else if (m < 1e-3) {
      return '${m * 1e6}us';
    } else if (m < 1) {
      return '${m * 1e3}ms';
    } else {
      return formatDurations(m);
    }
  };
}

charts.MeasureFormatter formatDataRate(num? max) {
  return formatterBaseFn(max, _upperPrefixes, unit: 'bps', base: 1000);
}

charts.MeasureFormatter formatCapacity(num? max) {
  return formatterBaseFn(max, _iPrefixes, unit: 'B', base: 1024);
}
