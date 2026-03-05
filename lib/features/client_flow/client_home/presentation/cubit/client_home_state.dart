import 'package:el7erafe/features/client_flow/client_home/data/models/service_item.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<ServiceItem> services;
  HomeLoaded(this.services);
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}

class HomeUnauthorized extends HomeState {
  final String message;
  HomeUnauthorized(this.message);
}

class HomeUnreadCountUpdated extends HomeState {
  final int count;
  HomeUnreadCountUpdated(this.count);
}