import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:paynow/paynow.dart';
import 'package:paynow_bloc/src/cart/bloc/cart.cubit.dart';
import 'package:paynow_bloc/src/models/payment_info.dart';
import 'package:paynow_bloc/src/models/payment_info.dart';
import 'package:paynow_bloc/src/paynow_bloc/events/events.dart';



class PaynowConfig{
  PaynowConfig({
    required this.integrationId,
    required this.integrationKey,
    required this.authEmail,
    required this.reference,

  });

  factory PaynowConfig.fromMap(map)=>PaynowConfig(
    integrationId: map['integrationId'],
    integrationKey: map['integrationKey'],
    authEmail: map['authEmail'],
    reference: map['reference']
  );

  PaynowConfig copyWith({
    String? integrationKey,
    String? integrationId,
    String? reference,
    String? authEmail
  }){
    return PaynowConfig(
      integrationId: integrationId ?? this.integrationId,
      integrationKey: integrationKey ?? this.integrationKey,
      authEmail: authEmail ?? this.authEmail,
      reference: reference ?? this.reference
    );
  }

  final String integrationId;
  final String integrationKey;
  final String authEmail;
  final String reference;
}

abstract class PaynowState{}
class PaynowInitialState extends PaynowState {}
class PaynowLoadingState extends PaynowState {}
class PaynowPendingState extends PaynowState {
  PaynowPendingState({
    required this.response,
    required this.currentStatus
  });
  final InitResponse response;
  final String currentStatus;
}

class PaynowSuccessState extends PaynowState {
  PaynowSuccessState({
    required this.statusResponse
  });

  final StatusResponse statusResponse;
}

class PaynowFailedState extends PaynowState {
  PaynowFailedState({
    required this.message
  });

  final String message;
}

class PaynowBloc extends Cubit<PaynowState> {
  final CartRepository cartRepository;
  final PaynowConfig config;
  PaynowBloc({
    required this.config,
    required this.cartRepository
  }) : super(PaynowInitialState());
  startPayment(PaynowPaymentInfo paymentInfo)async{
    emit(PaynowLoadingState());
    // create payment
    final paynow = Paynow(
      integrationId: config.integrationId,
      integrationKey: config.integrationKey,
      returnUrl: paymentInfo.returnUrl,
      resultUrl: paymentInfo.resultUrl,
    );

    final payment = paynow.createPayment(config.reference, config.authEmail);

    // mirror cart
    payment.items.addEntries(cartRepository.paynowCartItems.entries);
    // initiate payment
    try{
      late InitResponse response;
      if (paymentInfo.paymentMethod == PaynowPaymentMethod.web){
        response = await paynow.send(payment);
      }else{
        response = await paynow.sendMobile(payment, paymentInfo.phone!, paymentInfo.mobilePaymentMethod!);
      }

      // We got a response, let's send the pending state
      emit(
        PaynowPendingState(
          response: response,
          currentStatus: 'Initiating....',
        )
      );

      /// now let's listen for changes
      final transactionStatusStream = paynow.streamTransactionStatus(response.pollUrl)
        ..listen((statusResponse){
        /// use status.status instead of status.paid
        print(statusResponse.status);
          final Map<String, Function>responseHandlers = {
            "cancelled" : (){
              // Failed
              emit(PaynowFailedState(
                message: 'Transaction Cancelled',
              ));
              paynow.closeStream();
            },
            "paid" : (){
              emit(PaynowSuccessState(
                statusResponse: statusResponse
              ));
              paynow.closeStream();
            },
            'failed': (){
              emit(PaynowFailedState(
                message: 'Transaction Failed'
              ));
              paynow.closeStream();
            },
            "created" : (){
              emit(PaynowPendingState(
                response: response,
                currentStatus: statusResponse.status
              ));
            }

          };

          // call handler
          responseHandlers[statusResponse.status.toLowerCase()]!.call();

      });

    }catch (e){
      // Something went terribly wrong
      emit(PaynowFailedState(
        message: e.toString()
      ));
    }
  }
}
