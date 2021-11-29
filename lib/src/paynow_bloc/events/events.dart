import 'package:paynow/paynow.dart';
import 'package:paynow_bloc/src/models/payment_info.dart';

abstract class PaynowEvent {}

/// Event to begin checkout process
class PaynowCheckoutEvent extends PaynowEvent {
  final PaynowPaymentInfo paynowPaymentInfo;
  PaynowCheckoutEvent(this.paynowPaymentInfo);
}

/// Adding [PaynowCartItem] to cart
class PaynowAddItemToCartEvent extends PaynowEvent {
  PaynowAddItemToCartEvent(this.paynowCartItem, {this.quantity});

  /// The [PaynowCartItem] to add
  final PaynowCartItem paynowCartItem;

  /// The number of units to add
  final int? quantity;
}

/// Removing Item from cart
class RemoveItemFromCartEvent extends PaynowEvent {
  RemoveItemFromCartEvent(this.paynowCartItem, {this.quantity});

  /// The item to remove
  final PaynowCartItem paynowCartItem;

  /// The number of units to remove
  final int? quantity;
}

/// Deleting [PaynowCartItem]
class DeleteCartItemEvent extends PaynowEvent {
  DeleteCartItemEvent(this.paynowCartItem);
  final PaynowCartItem paynowCartItem;
}

/// Clearing the cart
class ClearCartEvent extends PaynowEvent {}
