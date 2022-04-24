part of '../bloc/paynow_bloc.dart';

class PaynowProdRepository implements AbstractPaynowRepository{

  @override
  Future<InitResponse> startWebCheckoutPayment(paynowPaymentInfo) {
    // TODO: implement startWebCheckoutPayment
    throw UnimplementedError();
  }

  @override
  // TODO: implement paynowConfig
  PaynowConfig get paynowConfig => throw UnimplementedError();

  @override
  Future<StatusResponse> checkPaymentStatus(InitResponse initResponse) {
    // TODO: implement checkPaymentStatus
    throw UnimplementedError();
  }
}