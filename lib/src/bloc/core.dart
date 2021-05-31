import 'package:bloc/bloc.dart';
import 'package:paynow/paynow.dart';
import 'package:paynow_bloc/src/events/events.dart';
import 'package:paynow_bloc/src/models/payment_info.dart';
import 'package:paynow_bloc/src/models/paynow_cart_item.dart';
import 'package:paynow_bloc/src/repository/repository.dart';
import 'package:paynow_bloc/src/states/states.dart';
import 'package:url_launcher/url_launcher.dart';

class PaynowBloc extends Bloc<PaynowEvent, PaynowState>{
  final Repository repository = Repository();
  final Paynow paynow;


  Stream<Map<PaynowCartItem, int>> get cartStream => repository.cartCubit.stream;
  Map<PaynowCartItem, int> get cartItems => state.cartItems;
  double get total => repository.cartCubit.total;

  PaynowBloc({
    this.paynow,
    PaynowState initialState
  }) : super(initialState??PaynowInitialState({}));


  @override
  Future<Function> close() {
    // close the cartCubit
    this.repository.cartCubit.close();
    return super.close();
  }

  @override
  Stream<PaynowState> mapEventToState(PaynowEvent event) async*{
    // TODO: implement mapEventToState

    if (event is AddItemToCartEvent){
      // add item to cart
      repository.cartCubit.addItemToCart(event.paynowCartItem);
      state.addItemToCart(event.paynowCartItem);
      yield state;
    }else if (event is RemoveItemFromCartEvent){
      repository.cartCubit.removeItemToCart(event.paynowCartItem);
      state.removeItemToCart(event.paynowCartItem);
      yield state;
    }else if (event is ClearCartEvent){
      repository.cartCubit.clearCart();
      state.clearCart();
      yield state;
    }else if (event is PaynowCheckoutEvent){

      paynow.returnUrl = event.paynowPaymentInfo.returnUrl??paynow.returnUrl;
      paynow.resultUrl = event.paynowPaymentInfo.resultUrl??paynow.resultUrl;
      final payment = paynow.createPayment(event.paynowPaymentInfo.reference, event.paynowPaymentInfo.authEmail);
      state.cartItems.forEach((item, quantity){
        payment.add(item.title, double.parse((quantity * item.price).toStringAsFixed(2)));
      });

      switch (event.paynowPaymentInfo.paymentMethod){
        case PaynowPaymentMethod.web:
        // go on to checkout web
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
                yield PaynowPaymentSuccessfulState(cartItems, statusResponse);
                paynow.closeStream();
              }else if (statusResponse.status == "Cancelled"){
                yield PaynowPaymentFailureState(cartItems, "Transaction was cancelled by the user", response);
                paynow.closeStream();
              }else if (statusResponse.status == "Failed"){
                yield PaynowPaymentFailureState(cartItems, "Transaction Failed", response);
                paynow.closeStream();
              }
            }
          }else{
            yield PaynowPaymentFailureState(cartItems, response.instructions, response);
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
                  yield PaynowPaymentSuccessfulState(cartItems, statusResponse);
                  paynow.closeStream();
                }else if (statusResponse.status == "Cancelled"){
                  yield PaynowPaymentFailureState(cartItems, "Transaction was cancelled", response);
                  paynow.closeStream();
                  break;
                }
              }
            }else{
              yield PaynowPaymentFailureState(cartItems, response.instructions, response);
            }

          }catch (e){
            yield PaynowPaymentFailureState(cartItems, e.toString(), response);
          }
          // send request
          break;
      }
    }


  }
}
