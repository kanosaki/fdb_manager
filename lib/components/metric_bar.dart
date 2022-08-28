import 'package:flutter/material.dart';

class MetricBar extends StatelessWidget {
  const MetricBar({Key? key, this.text = '', this.palette, required this.ratio, this.watermark}) : super(key: key);

  final double ratio;
  final double? watermark;
  final String text;
  final MetricBarPalette? palette;

  @override
  Widget build(BuildContext context) {
    final pal = palette ?? MetricBarPalette();
    return CustomPaint(
        painter: MetricBarPainter(pal.ok, text, ratio,
            watermark: watermark, watermarkColor: pal.warn));
  }
}

class MetricBarPainter extends CustomPainter {
  MetricBarPainter(this.color, this.text, this.ratio,
      {this.watermark, this.watermarkColor, this.watermarkThickness = 2.0});

  final MetricBarColor color;
  final MetricBarColor? watermarkColor;
  final String text;
  final double ratio;
  final double? watermark;
  final double watermarkThickness;

  @override
  void paint(Canvas canvas, Size size) {
    const frameWidth = 1.0;
    final splitPoint = size.width * ratio;
    // Start painting content
    {
      final paint = Paint();
      paint.color = color.mainColor;
      canvas.drawRect(Rect.fromLTWH(0, 0, splitPoint, size.height), paint);
    }
    if (watermark != null) {
      final wm = watermark!;
      final wmc = watermarkColor ?? color;
      final paint = Paint();
      paint.color = wmc.mainColor;
      paint.strokeWidth = watermarkThickness;
      canvas.drawLine(Offset(size.width * wm, 0),
          Offset(size.width * wm, size.height), paint);
    }
    // Draw off-bar texts
    {
      canvas.save();
      canvas.clipRect(Rect.fromLTWH(splitPoint, 0, size.width, size.height));
      final tp = TextPainter(
        textAlign: TextAlign.right,
        text: TextSpan(
          text: text,
          style: TextStyle(color: color.mainTextColor),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(size.width - tp.width - frameWidth, 0));
      canvas.restore();
    }
    // Draw on-bar texts
    {
      canvas.save();
      canvas.clipRect(Rect.fromLTWH(0, 0, splitPoint, size.height));
      final tp = TextPainter(
        textAlign: TextAlign.right,
        text: TextSpan(
          text: text,
          style: TextStyle(color: color.subTextColor),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(size.width - tp.width - frameWidth, 0));
      canvas.restore();
    }
    {
      final paint = Paint();
      paint.color = color.frameColor;
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = frameWidth;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class MetricBarColor {
  const MetricBarColor(
      this.mainColor, this.frameColor, this.mainTextColor, this.subTextColor);

  final Color mainColor;
  final Color frameColor;
  final Color mainTextColor;
  final Color subTextColor;
}

class MetricBarPalette {
  final MetricBarColor error = const MetricBarColor(
    Color.fromRGBO(180, 93, 67, 1.0),
    Color.fromRGBO(117, 0, 0, 1.0),
    Color.fromRGBO(117, 0, 0, 1.0),
    Color.fromRGBO(255, 255, 255, 1),
  );

  final MetricBarColor warn = const MetricBarColor(
    Color.fromRGBO(182, 135, 47, 1.0),
    Color.fromRGBO(124, 85, 0, 1.0),
    Color.fromRGBO(124, 85, 0, 1.0),
    Color.fromRGBO(255, 255, 255, 1),
  );

  final MetricBarColor ok = const MetricBarColor(
    Color.fromRGBO(68, 131, 51, 1.0),
    Color.fromRGBO(21, 101, 0, 1.0),
    Color.fromRGBO(21, 101, 0, 1.0),
    Color.fromRGBO(255, 255, 255, 1),
  );

  final MetricBarColor noChecked = const MetricBarColor(
    Color.fromRGBO(75, 134, 192, 1.0),
    Color.fromRGBO(0, 68, 133, 1.0),
    Color.fromRGBO(0, 68, 133, 1.0),
    Color.fromRGBO(255, 255, 255, 1),
  );
}
