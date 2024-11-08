import 'package:equatable/equatable.dart';

class SelectFieldItem<T> extends Equatable {
  late final String label;
  late final T value;

  SelectFieldItem({
    required this.label,
    required value,
  }) {
    this.value = value;
  }

  @override
  List<dynamic> get props => [label, value];
}
