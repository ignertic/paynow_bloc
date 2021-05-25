enum PaynowPaymentMethod {
  web,
  express
}

class PaynowPaymentInfo{
  final String authEmail;
  final String reference;
  final String phone;
  final String returnUrl;
  final String resultUrl;
  final PaynowPaymentMethod paymentMethod;

  PaynowPaymentInfo({
    this.authEmail,
    this.reference,
    this.paymentMethod,
    this.phone,
    this.returnUrl,
    this.resultUrl
  });
}