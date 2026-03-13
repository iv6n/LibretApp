import 'package:equatable/equatable.dart';

enum DynamicAttributeType { number, integer, boolean, text }

class DynamicAttribute extends Equatable {
  const DynamicAttribute({
    required this.key,
    required this.label,
    required this.type,
    this.unit,
    this.numberValue,
    this.boolValue,
    this.textValue,
    required this.updatedAt,
    this.source,
  }) : assert(
         type != DynamicAttributeType.number || numberValue != null,
         'numberValue required for number type',
       ),
       assert(
         type != DynamicAttributeType.integer || numberValue != null,
         'numberValue required for integer type',
       ),
       assert(
         type != DynamicAttributeType.boolean || boolValue != null,
         'boolValue required for boolean type',
       ),
       assert(
         type != DynamicAttributeType.text || textValue != null,
         'textValue required for text type',
       );

  factory DynamicAttribute.number({
    required String key,
    required String label,
    required num value,
    String? unit,
    DateTime? updatedAt,
    String? source,
  }) {
    return DynamicAttribute(
      key: key,
      label: label,
      type: DynamicAttributeType.number,
      unit: unit,
      numberValue: value,
      updatedAt: updatedAt ?? DateTime.now(),
      source: source,
    );
  }

  factory DynamicAttribute.integer({
    required String key,
    required String label,
    required int value,
    String? unit,
    DateTime? updatedAt,
    String? source,
  }) {
    return DynamicAttribute(
      key: key,
      label: label,
      type: DynamicAttributeType.integer,
      unit: unit,
      numberValue: value,
      updatedAt: updatedAt ?? DateTime.now(),
      source: source,
    );
  }

  factory DynamicAttribute.boolean({
    required String key,
    required String label,
    required bool value,
    DateTime? updatedAt,
    String? source,
  }) {
    return DynamicAttribute(
      key: key,
      label: label,
      type: DynamicAttributeType.boolean,
      boolValue: value,
      updatedAt: updatedAt ?? DateTime.now(),
      source: source,
    );
  }

  factory DynamicAttribute.text({
    required String key,
    required String label,
    required String value,
    String? unit,
    DateTime? updatedAt,
    String? source,
  }) {
    return DynamicAttribute(
      key: key,
      label: label,
      type: DynamicAttributeType.text,
      unit: unit,
      textValue: value,
      updatedAt: updatedAt ?? DateTime.now(),
      source: source,
    );
  }
  final String key;
  final String label;
  final DynamicAttributeType type;
  final String? unit;
  final num? numberValue;
  final bool? boolValue;
  final String? textValue;
  final DateTime updatedAt;
  final String? source;

  Object? get value {
    switch (type) {
      case DynamicAttributeType.number:
      case DynamicAttributeType.integer:
        return numberValue;
      case DynamicAttributeType.boolean:
        return boolValue;
      case DynamicAttributeType.text:
        return textValue;
    }
  }

  DynamicAttribute copyWith({
    String? key,
    String? label,
    DynamicAttributeType? type,
    String? unit,
    num? numberValue,
    bool? boolValue,
    String? textValue,
    DateTime? updatedAt,
    String? source,
  }) {
    return DynamicAttribute(
      key: key ?? this.key,
      label: label ?? this.label,
      type: type ?? this.type,
      unit: unit ?? this.unit,
      numberValue: numberValue ?? this.numberValue,
      boolValue: boolValue ?? this.boolValue,
      textValue: textValue ?? this.textValue,
      updatedAt: updatedAt ?? this.updatedAt,
      source: source ?? this.source,
    );
  }

  @override
  List<Object?> get props => [
    key,
    label,
    type,
    unit,
    numberValue,
    boolValue,
    textValue,
    updatedAt,
    source,
  ];
}
