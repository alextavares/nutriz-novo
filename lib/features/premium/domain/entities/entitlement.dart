import 'package:freezed_annotation/freezed_annotation.dart';

part 'entitlement.freezed.dart';

@freezed
class Entitlement with _$Entitlement {
  const factory Entitlement({
    required String id,
    required bool isActive,
    required DateTime? expirationDate,
  }) = _Entitlement;
}
