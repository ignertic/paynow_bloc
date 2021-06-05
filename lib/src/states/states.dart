import 'package:paynow_bloc/src/models/paynow_cart_item.dart';
import 'package:paynow/paynow.dart' show StatusResponse, InitResponse;

class PaynowState {
  final Map<PaynowCartItem, int> cartItems;
  double get total => _total();

  PaynowState(this.cartItems);

  PaynowState copyWith(instance, {
    Map<PaynowCartItem, int> cartItems
  }){
    return instance(
        cartItems ?? this.cartItems
    );
  }

  addItemToCart(PaynowCartItem item){
    if (this.cartItems.containsKey(item)){
      this.cartItems[item] += 1;

    }else{
      this.cartItems[item] = 1;
    }
  }

  removeItemToCart(PaynowCartItem item){
    if (this.cartItems.containsKey(item)){
      this.cartItems[item] -= 1;
    }else{
      this.cartItems.remove(item);
    }
  }

  clearCart(){
    this.cartItems.clear();
  }

  double _total(){
    double total = 0.0;
    this.cartItems.forEach((item, quantity){
      total += item.price * quantity;
    });

    return double.parse(total.toStringAsExponential(2));
  }
}

class PaynowLoadingState extends PaynowState {
  final InitResponse initResponse;
  PaynowLoadingState(cartItems,this.initResponse) : super(cartItems);
}

class PaynowPaymentFailureState extends PaynowState {
  final InitResponse initResponse;
  final String message;

  PaynowPaymentFailureState(cartItems, this.message, this.initResponse) : super(cartItems);
}

class PaynowPaymentSuccessfulState extends PaynowState{

  final StatusResponse statusResponse;
  PaynowPaymentSuccessfulState(Map cartItems, this.statusResponse) : super(cartItems??{});
}
class PaynowInitialState extends PaynowState {

  PaynowInitialState(Map<PaynowCartItem, int> cartItems) : super(cartItems);
}
