part of 'home_bloc.dart';

class HomeState extends Equatable {
  final int activeTabIndex;

  const HomeState({this.activeTabIndex = 0});

  @override
  List<Object> get props => [activeTabIndex];

  HomeState copyWith({
    final int? activeTabIndex,
  }) =>
      HomeState(
        activeTabIndex: activeTabIndex ?? this.activeTabIndex,
      );
}
