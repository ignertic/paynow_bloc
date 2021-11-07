import 'package:paynow/paynow.dart';
import 'package:paynow_bloc/src/models/payment_info.dart';

abstract class PaynowEvent {}

/// Event to begin checkout process
class PaynowCheckoutEvent extends PaynowEvent {
  final PaynowPaymentInfo paynowPaymentInfo;
  PaynowCheckoutEvent(this.paynowPaymentInfo);
}

class PaynowAddItemToCartEvent extends PaynowEvent {
  PaynowAddItemToCartEvent(this.paynowCartItem, {this.quantity});
  final PaynowCartItem paynowCartItem;
  final int? quantity;
}

class RemoveItemFromCartEvent extends PaynowEvent {


  RemoveItemFromCartEvent(this.paynowCartItem, {this.quantity});
  final PaynowCartItem paynowCartItem;
  final int? quantity;

}

class DeleteCartItemEvent extends PaynowEvent {
  DeleteCartItemEvent(this.paynowCartItem);
  final PaynowCartItem paynowCartItem;
}

class ClearCartEvent extends PaynowEvent {}
