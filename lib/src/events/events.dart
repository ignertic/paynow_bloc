import 'package:paynow_bloc/src/models/payment_info.dart';
import 'package:paynow_bloc/src/models/paynow_cart_item.dart';

abstract class PaynowEvent {}
class PaynowCheckoutEvent extends PaynowEvent {
  final PaynowPaymentInfo paynowPaymentInfo;

  PaynowCheckoutEvent({this.paynowPaymentInfo});

}

class AddItemToCartEvent extends PaynowEvent {
  final PaynowCartItem paynowCartItem;

  AddItemToCartEvent(this.paynowCartItem);
}

class RemoveItemFromCartEvent extends PaynowEvent {
  final PaynowCartItem paynowCartItem;

  RemoveItemFromCartEvent(this.paynowCartItem);
}

class ClearCartEvent extends PaynowEvent {}
