abstract class TechHomeState {}

class TechHomeInitial extends TechHomeState {}

class TechHomeLoading extends TechHomeState {}

class TechHomeError extends TechHomeState {
  final String message;
  TechHomeError(this.message);
}

class TechHomeUnauthorized extends TechHomeState {
  final String message;
  TechHomeUnauthorized(this.message);
}

class TechHomeUnreadCountUpdated extends TechHomeState {
  final int count;
  TechHomeUnreadCountUpdated(this.count);
}
