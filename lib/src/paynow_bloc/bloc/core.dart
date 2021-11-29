import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:paynow/paynow.dart';
import 'package:paynow_bloc/src/cart/bloc/cart.cubit.dart';
import 'package:paynow_bloc/src/models/payment_info.dart';



/// Paynow Configuration
class PaynowConfig extends Equatable{
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

  /// Integration ID obtained from Paynow
  final String integrationId;

  /// Integration Key obtained from Paynow
  final String integrationKey;

  /// Auth Email
  final String authEmail;

  /// Reference for current payment
  final String reference;

  @override
  // TODO: implement props
  List<Object?> get props => [
    integrationId,
    integrationKey,
    authEmail,
    reference
  ];
}

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


/// Bloc for creating and managing Paynow payment requests
class PaynowBloc extends Cubit<PaynowState> {

  /// [CartRepository]
  final CartRepository cartRepository;

  /// [PaynowConfig]
  final PaynowConfig config;
  PaynowBloc({
    required this.config,
    required this.cartRepository
  }) : super(PaynowInitialState(

  ));

  /// Start a Paynow Payment process
  /// input: [PaynowPaymentInfo]
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
          currentStatus: 'Initiating',
        )
      );


      /// now let's listen for changes
      paynow.streamTransactionStatus(response.pollUrl)
        ..listen((statusResponse){
        /// use status.status instead of status.paid
        print(statusResponse.status);
          final Map<String, Function>responseHandlers = {
            "cancelled" : (){
              // Failed
              emit(PaynowFailedState(
                message: 'Transaction Cancelled',
                statusResponse: statusResponse
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
                statusResponse: statusResponse,
                message: 'Transaction Failed'
              ));
              paynow.closeStream();
            },
            "created" : (){
              emit(PaynowPendingState(
                response: response,
                currentStatus: statusResponse.status
              ));
            },
            "sent" : (){
              emit(PaynowPendingState(
                response: response,
                currentStatus: statusResponse.status
              ));
            }

          };

          // call handler
          print(statusResponse.status.toLowerCase());
          responseHandlers[statusResponse.status.toLowerCase()]!.call();

      });

    }catch (e){
      // Something went terribly wrong

      emit(PaynowFailedState(
        statusResponse: StatusResponse(
          paid: false,
          status: 'failed',
          reference: 'invalid',
          amount: 'invalid',
          paynowreference: 'invalid',
          hash: 'invalid'
        ),
        message: e.toString()
      ));
    }
  }
}
