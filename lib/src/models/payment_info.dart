import 'package:paynow/models/models.dart';

/// Options for Payment method
enum PaynowPaymentMethod {

  /// For Web checkouts
  web,

  /// For all expressh checkouts (Ecocash etc)
  express
}

/// Containing Payment Information required during transaction
class PaynowPaymentInfo{

  /// Valid ZW Phone number of client
  /// Required if payment method is PaynowPaymentMethod.express
  final String? phone;

  /// This is where Paynow redirects the user after a payment whether cancelled or successful
  /// You can also use this to automatically return your users back to the app after payment
  final String? returnUrl;

  /// This the url Paynow will post the results of a payment to
  /// e.g https://yourserver.com/payments/user_id
  final String? resultUrl;

  /// Express or Web
  final PaynowPaymentMethod paymentMethod;

  /// Only use in cases of express checkout
  final MobilePaymentMethod? mobilePaymentMethod;

  PaynowPaymentInfo({
    required this.paymentMethod,
    this.phone,
    this.returnUrl,
    this.resultUrl,
    this.mobilePaymentMethod
  });
}
