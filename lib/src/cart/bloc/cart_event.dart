part of 'cart_bloc.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();
}

class CartAddItemEvent extends CartEvent {

  final CartItem cartItem;
  final int quantity;

  @override
  // TODO: implement props
  List<Object?> get props => [cartItem, quantity];

  const CartAddItemEvent({
    required this.cartItem,
    required this.quantity
  });
}


class CartRemoveItemEvent extends CartEvent{

  final CartItem cartItem;
  final int quantity;

  @override
  List<Object?> get props => [quantity, cartItem];

  const CartRemoveItemEvent({
    required this.cartItem,
    required this.quantity
  });
}


class CartClearItemsEvent extends CartEvent{
  @override
  List<Object?> get props => [];
}