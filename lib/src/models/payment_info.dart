import 'package:paynow/models/models.dart';

enum PaynowPaymentMethod {
  web,
  express
}

class PaynowPaymentInfo{
  final String? phone;
  final String? returnUrl;
  final String? resultUrl;
  final PaynowPaymentMethod paymentMethod;
  final MobilePaymentMethod? mobilePaymentMethod;

  PaynowPaymentInfo({
    required this.paymentMethod,
    this.phone,
    this.returnUrl,
    this.resultUrl,
    this.mobilePaymentMethod
  });
}
