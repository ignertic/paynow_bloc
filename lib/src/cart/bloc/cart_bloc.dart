import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:paynow/models/models.dart';
import '../../models/models.dart' show CartItem;

part 'cart_event.dart';
part 'cart_state.dart';
part '../repository/abstract.cart.repository.dart';
part '../repository/cart.repository.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final AbstractCartRepository cartRepository;
  CartBloc(this.cartRepository) : super(CartInitialState()) {

    on<CartAddItemEvent>((event, emit) {
      cartRepository.addCartItem(event.cartItem, quantity: event.quantity);
      emit(CartAddedItemState(cartItem: event.cartItem));
    });

    on<CartRemoveItemEvent>((event, emit) {
      cartRepository.removeCartItem(event.cartItem, quantity: event.quantity);
      emit(CartRemovedItemState(cartItem: event.cartItem));
    });

    on<CartClearItemsEvent>((event, emit) {
      cartRepository.clearCartItems();
      emit(CartClearedItemsState());
    });
  }
}
