part of 'cart_bloc.dart';

abstract class CartState extends Equatable {
  const CartState();
}

class CartInitialState extends CartState {
  @override
  List<Object> get props => [];
}

class CartLoadedState extends CartState{

  final List<CartItem> cartItems;

  @override
  // TODO: implement props
  List<Object?> get props => [cartItems];

  const CartLoadedState({
    required this.cartItems,
  });
}

class CartAddedItemState extends CartState{

  final CartItem cartItem;
  @override
  // TODO: implement props
  List<Object?> get props => [cartItem];

  const CartAddedItemState({
    required this.cartItem,
  });
}

class CartRemovedItemState extends CartState{

  final CartItem cartItem;
  @override
  // TODO: implement props
  List<Object?> get props => [cartItem];

  const CartRemovedItemState({
    required this.cartItem,
  });
}

class CartClearedItemsState extends CartState{
  @override
  // TODO: implement props
  List<Object?> get props => [];
}