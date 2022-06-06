import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:paynow/models/init_response.dart';
import 'package:paynow/paynow.dart';
import 'package:paynow_bloc/paynow_bloc.dart';
import 'package:paynow_bloc/src/paynow_bloc/model/paynow_config.model.dart';

import '../model/paynow_payment_info.model.dart';
import '../model/paynow_payment_method.model.dart';

part 'paynow_event.dart';
part 'paynow_state.dart';
part '../repository/abstract.paynow.repository.dart';
part '../repository/paynow.repository.dev.dart';
part '../repository/paynow.repository.prod.dart';

class PaynowBloc extends Bloc<PaynowEvent, PaynowState> {
  final AbstractPaynowRepository paynowRepository;
  PaynowBloc(this.paynowRepository) : super(PaynowInitialState()) {


    on<PaynowStartWebCheckoutEvent>((event, emit)async{
      // start web checkout
      emit(PaynowLoadingState());
      late InitResponse initResponse;
      try{
        initResponse = await paynowRepository.startWebCheckoutPayment(event.paynowPaymentInfo);

        emit(
          PaynowPendingState(response: initResponse, currentStatus: 'Awaiting Payment')
        );
      }catch (e){
        initResponse = InitResponse(
          hasRedirect: false,
          error: e.toString(),
          redirectUrl: '',
          pollUrl: '',
          success: false,
          hash: '',
          instructions: ''
        );
        emit(PaynowFailedState(message: e.toString(), statusResponse: StatusResponse(
          amount: 44.2.toString(),
          hash: 'invalid',
          paid: false,
          reference: '',
          paynowreference: '',
          status: 'failed'
        )));
      }
    });

    on<PaynowCheckPaymentStatusEvent>((event, emit)async{
      emit(PaynowLoadingState());
      final statusResponse = await paynowRepository.checkPaymentStatus(event.initResponse);
      switch (statusResponse.status.toLowerCase().replaceAll('+', ' ')){
        case 'paid':
        case 'awaiting delivery':
          emit(PaynowSuccessState(statusResponse: statusResponse));
          break;

        case 'cancelled':
          emit(PaynowFailedState(
            message: 'Transaction cancelled by the user',
            statusResponse: statusResponse
          ));
          break;
        case 'created':
        case 'sent':
          emit(PaynowPendingState(
            response: event.initResponse,
            currentStatus: 'Awaiting Transaction'
          ));
      }

    });
  }
}
