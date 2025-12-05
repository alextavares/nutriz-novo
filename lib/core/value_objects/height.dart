import 'package:freezed_annotation/freezed_annotation.dart';

part 'height.freezed.dart';

@freezed
class Height with _$Height {
  const Height._();

  const factory Height({required double cm}) = _Height;

  factory Height.fromCm(double cm) => Height(cm: cm);

  factory Height.fromFtIn(int ft, int inches) {
    final totalInches = (ft * 12) + inches;
    final cm = totalInches * 2.54;
    return Height(cm: cm);
  }

  String formatCm() => '${cm.round()} cm';

  String formatFtIn() {
    final totalInches = cm / 2.54;
    final ft = totalInches ~/ 12;
    final inches = (totalInches % 12).round();
    return '$ft\' $inches"';
  }
}
