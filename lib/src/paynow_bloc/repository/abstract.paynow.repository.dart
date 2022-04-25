part of '../bloc/paynow_bloc.dart';

abstract class AbstractPaynowRepository{

  final PaynowConfig paynowConfig;
  Future<InitResponse> startWebCheckoutPayment(PaynowPaymentInfo paynowPaymentInfo);

  Future<StatusResponse> checkPaymentStatus(InitResponse initResponse);

  const AbstractPaynowRepository({
    required this.paynowConfig,
  });
}