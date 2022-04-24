part of '../bloc/cart_bloc.dart';

class CartRepository implements AbstractCartRepository{
  CartRepository({
    this.cartItems = const <CartItem, int>{}
  });

  final Map<CartItem, int> cartItems;

  /// Get List of current cartItems
  List<CartItem> get currentPaynowItems => cartItems.keys.toList().cast<CartItem>();

  /// Return Info of items in cart.
  String get info => this.cartItems.keys.fold<String>('', (previous, item)=>previous+item.title);

  /// Total amount of items in cart.
  double get total => this.cartItems.entries.fold<double>(
      0.0, (previous, item)
  => double.parse(
      (previous+item.key.amount * item.value).toStringAsExponential(2)
  ) );

  /// Clear the cart
  void clearCart(){
    this.cartItems.clear();
  }

  /// Get Quantity
  int getQuantity (CartItem cartItems) => this.cartItems[cartItems]!;

  /// Delete Item from cart
  void deleteCartItem(CartItem cartItem){
    this.cartItems.remove(cartItem);
  }

  /// Adding [PaynowCartItem] to [Payment.items]
  /// [quantity]
  void addToCart(CartItem cartItem, { int? quantity }) {
    if (this.cartItems.containsKey(cartItem)){
      /// then increment quantity by 1 if [quantity] is null
      this.cartItems[cartItem] = this.cartItems[cartItem]! + (quantity ?? 1);
    }else{
      /// Add new item to cart with initial quantity of 1 if [quantity] is null
      this.cartItems[cartItem] = quantity ?? 1;
    }
  }

  /// Remove [PaynowCartItem]s from [Payment.items]
  void removeFromCart(CartItem cartItem, { int? quantity }) {
    if (this.cartItems.containsKey(cartItem)){

      /// then decreement quantity by 1 if [quantity] is null
      this.cartItems[cartItem] = this.cartItems[cartItem]! - (quantity ?? 1);
      // remove map if it has reached 0 or below
      if (this.cartItems[cartItem]! <= 0){
        this.cartItems.remove(cartItem);
      }
    }
  }

  @override
  void addCartItem(CartItem cartItem, {int quantity = 1}) {
    addToCart(cartItem, quantity: quantity);
  }

  @override
  void clearCartItems() {
    clearCart();
  }

  @override
  void removeCartItem(CartItem cartItem, {int quantity = 1}) {
    removeFromCart(cartItem, quantity: quantity);
  }
}

extension ToPaynowCartItem on List<CartItem>{
  List<PaynowCartItem> get toPaynowCartItems => this.map((e){
    return PaynowCartItem(title: e.title, amount: e.amount);
  } ).toList();
}