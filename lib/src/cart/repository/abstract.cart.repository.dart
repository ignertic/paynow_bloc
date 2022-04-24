
part of '../bloc/cart_bloc.dart';

abstract class AbstractCartRepository{
  void addCartItem(CartItem cartItem, {int quantity = 1});

  void removeCartItem(CartItem cartItem, {int quantity = 1});

  void clearCartItems();
}