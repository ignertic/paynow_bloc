import 'package:bloc/bloc.dart';
import 'package:paynow_bloc/src/models/paynow_cart_item.dart';



class CartCubit extends Cubit<Map<PaynowCartItem, int>>{
  double get total => _total();

  CartCubit({Map<PaynowCartItem, int> restoreState}) : super(restoreState??{});

  addItemToCart(PaynowCartItem item){
    if (state.containsKey(item)){
      state[item] += 1;
    }else{
      state[item] = 1;
    }
    emit(state);
  }

  removeItemToCart(PaynowCartItem item){
    if (state.containsKey(item)){
      state[item] += 1;

    }else{
      state[item] = 1;
    }

    emit(state);
  }

  clearCart(){
    this.state.clear();
    emit(state);
  }

  double _total(){
    double total = 0.0;
    this.state.forEach((item, quantity){
      total += item.price * quantity;
    });

    return double.parse(total.toString());
  }

}
