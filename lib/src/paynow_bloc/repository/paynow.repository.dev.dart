part of '../bloc/paynow_bloc.dart';

class PaynowDevRepository implements AbstractPaynowRepository {
  const PaynowDevRepository({
    required this.paynowConfig,
  });

  final PaynowConfig paynowConfig;

  @override
  Future<InitResponse> startWebCheckoutPayment(
      PaynowPaymentInfo paynowPaymentInfo) async {
    // create payment
    final paynow = Paynow(
      integrationId: paynowConfig.integrationId,
      integrationKey: paynowConfig.integrationKey,
      returnUrl: paynowPaymentInfo.returnUrl,
      resultUrl: paynowPaymentInfo.resultUrl,
    );

    final payment = paynow.createPayment(
        paynowConfig.reference, paynowConfig.authEmail);

    // mirror cart
    paynowPaymentInfo.
    cartItems.
    forEach((key, value) {
      final paynowCartItem = PaynowCartItem(
          title: key.title, amount: key.amount * value);
      payment.addToCart(paynowCartItem);
    });

    // initiate payment
    late InitResponse response;
    try {

      if (paynowPaymentInfo.paymentMethod == PaynowPaymentMethod.web) {
        response = await paynow.send(payment);
      } else {
        response = await paynow.sendMobile(
            payment,
            paynowPaymentInfo.phone!,
            paynowPaymentInfo.mobilePaymentMethod!)
        ;
      }

    } catch (e) {
      // Something went terribly wrong
      print(e.toString());
    }

    return response;
  }

  @override
  Future<StatusResponse> checkPaymentStatus(InitResponse initResponse) async{
    // TODO: implement checkPaymentStatus
    final paynow = Paynow(integrationId: 'integrationId', integrationKey: 'integrationKey', returnUrl: 'returnUrl', resultUrl: 'resultUrl');
    final statusResponse = await paynow.checkTransactionStatus(initResponse.pollUrl);
    return statusResponse;
  }
}