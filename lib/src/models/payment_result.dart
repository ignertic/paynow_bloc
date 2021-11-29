import 'package:equatable/equatable.dart';
import 'package:paynow/paynow.dart';


/// A response returned by core containing summary of the payment
/// Is safe to use to validate payments
class PaynowPaymentResult extends Equatable{

PaynowPaymentResult({
    required this.paid,
    required this.statusResponse
  });

  /// Tells whether the user paid or not
  final bool paid;

  /// A response from Paynow with payment information
  /// such as reference
  final StatusResponse statusResponse;


  @override
  // TODO: implement props
  List<Object?> get props => [
    paid,
    statusResponse
  ];
}
