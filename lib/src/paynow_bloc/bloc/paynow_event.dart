part of 'paynow_bloc.dart';

abstract class PaynowEvent extends Equatable {
  const PaynowEvent();
}

class PaynowStartWebCheckoutEvent extends PaynowEvent{
  final PaynowPaymentInfo paynowPaymentInfo;

  const PaynowStartWebCheckoutEvent({
    required this.paynowPaymentInfo,
  });

  @override
  List<Object?> get props => [paynowPaymentInfo];
}

class PaynowCheckPaymentStatusEvent extends PaynowEvent{
  final InitResponse initResponse;

  @override
  // TODO: implement props
  List<Object?> get props => [initResponse];

  const PaynowCheckPaymentStatusEvent({
    required this.initResponse,
  });
}
