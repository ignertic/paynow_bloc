part of 'paynow_bloc.dart';


/// PaynowState for [PaynowBloc]
abstract class PaynowState{}

/// Initial State of PaynowBloc
class PaynowInitialState extends PaynowState {
  @override
  String toString() => "initial";
}

/// Triggered when processing payment
class PaynowLoadingState extends PaynowState {
  @override
  String toString() => "loading";
}

/// Triggered when waiting for user to complete payment
class PaynowPendingState extends PaynowState {
  PaynowPendingState({
    required this.response,
    required this.currentStatus
  });

  /// Response from paynow after payment initiation
  final InitResponse response;

  /// Readable message for current state of transactions
  final String currentStatus;

  @override
  String toString() => "pending";
}


/// Triggered when user has successfully paid
class PaynowSuccessState extends PaynowState {
  PaynowSuccessState({
    required this.statusResponse
  });

  /// Response from Paynow with payment informations
  final StatusResponse statusResponse;

  @override
  String toString() => "success";
}


/// Triggered when payment completes unsuccessfully
class PaynowFailedState extends PaynowState {
  PaynowFailedState({
    required this.message,
    required this.statusResponse
  });

  /// Message describing the error
  final String message;

  /// Will contain invalid values from the error
  final StatusResponse statusResponse;

  @override
  String toString() => "failed";
}
