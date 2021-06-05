import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:paynow/paynow.dart';
import 'package:paynow_bloc/src/events/events.dart';
import 'package:paynow_bloc/src/models/payment_info.dart';
import 'package:paynow_bloc/src/models/paynow_cart_item.dart';
import 'package:paynow_bloc/src/states/states.dart';
import 'package:url_launcher/url_launcher.dart';

class PaynowBloc extends Bloc<PaynowEvent, PaynowState>{
  final Paynow paynow;

  final cartBroadcast = StreamController<Map<PaynowCartItem, int>>.broadcast();
  get cartStream => cartBroadcast.stream;
  double get total => state.total;

  PaynowBloc({
    this.paynow,
    PaynowState initialState
  }) : super(initialState??PaynowInitialState({}));



  @override
  Future<Function> close() {
    // close the cartCubit
    this.cartBroadcast.close();
    return super.close();
  }

  @override
  Stream<PaynowState> mapEventToState(PaynowEvent event) async*{
    // TODO: implement mapEventToState

    if (event is AddItemToCartEvent){
      // add item to cart
      state.addItemToCart(event.paynowCartItem);
      yield PaynowInitialState(
        state.cartItems
      );
    }else if (event is RemoveItemFromCartEvent){
      state.removeItemToCart(event.paynowCartItem);
      yield PaynowInitialState(
        state.cartItems
      );
    }else if (event is ClearCartEvent){
      state.clearCart();
      yield PaynowInitialState(
        state.cartItems
      );
    }else if (event is PaynowCheckoutEvent){
      // loading state
      paynow.returnUrl = event.paynowPaymentInfo.returnUrl??paynow.returnUrl;
      paynow.resultUrl = event.paynowPaymentInfo.resultUrl??paynow.resultUrl;
      final payment = paynow.createPayment(event.paynowPaymentInfo.reference, event.paynowPaymentInfo.authEmail);
      state.cartItems.forEach((item, quantity){
        payment.add(item.title, double.parse((quantity * item.price).toStringAsFixed(2)));
      });

      switch (event.paynowPaymentInfo.paymentMethod){
        case PaynowPaymentMethod.web:
        // go on to checkout web
          InitResponse initResponse;
          // yield loading
          yield PaynowLoadingState(state.cartItems, initResponse);
          final response = await paynow.send(payment);
          // yield state with instructions and other data
          yield PaynowLoadingState(state.cartItems, response);
          // open web with launch module
          if (response.hasRedirect){
            final String redirectUrl = Paynow.notQuotePlus(response.redirectUrl);
            // launch browser here
            launch(redirectUrl);
            final statusTransactionStream = paynow.streamTransactionStatus(response.pollUrl);
            Future.delayed(Duration(seconds: 120), (){
              print("Closing Transaction Stream");
              paynow.closeStream();
            });
            await for (StatusResponse statusResponse in statusTransactionStream){
              print(statusResponse);
              if (statusResponse.status == "Paid"){
                // send event that transaction is compete
                yield PaynowPaymentSuccessfulState(state.cartItems, statusResponse);
                paynow.closeStream();
              }else if (statusResponse.status == "Cancelled"){
                yield PaynowPaymentFailureState(state.cartItems, "Transaction was cancelled by the user", response);
                paynow.closeStream();
              }else if (statusResponse.status == "Failed"){
                yield PaynowPaymentFailureState(state.cartItems, "Transaction Failed", response);
                paynow.closeStream();
              }
            }
          }else{
            yield PaynowPaymentFailureState(state.cartItems, response.instructions, response);
          }

          break;
        case PaynowPaymentMethod.express:
        // start express checkout
          InitResponse response;
          try{
            response = await paynow.sendMobile(payment, event.paynowPaymentInfo.phone);
            if (response.success){
              final statusTransactionStream = paynow.streamTransactionStatus(response.pollUrl);
              // TODO:// allow timeout parameter
              Future.delayed(Duration(seconds: 120), (){
                print("Closing Transaction Stream");
                paynow.closeStream();
              });
              await for (StatusResponse statusResponse in statusTransactionStream){
                print(statusResponse);
                if (statusResponse.paid){
                  // send event that transaction is compete
                  yield PaynowPaymentSuccessfulState(state.cartItems, statusResponse);
                  paynow.closeStream();
                }else if (statusResponse.status == "Cancelled"){
                  yield PaynowPaymentFailureState(state.cartItems, "Transaction was cancelled", response);
                  paynow.closeStream();
                  break;
                }
              }
            }else{
              yield PaynowPaymentFailureState(state.cartItems, response.instructions, response);
            }

          }catch (e){
            yield PaynowPaymentFailureState(state.cartItems, e.toString(), response);
          }
          // send request
          break;
      }
    }


  }
}
