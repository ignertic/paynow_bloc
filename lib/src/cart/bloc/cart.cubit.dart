import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:paynow/models/models.dart';

class CartState extends Equatable{
  CartState({
    required this.cartItems,
    required this.total,
    required this.count
  });

  /// Genereate inital state
  factory CartState.initial()=>CartState(
    cartItems: <PaynowCartItem, int>{},
    total: 0,
    count: 0
  );


  final Map<PaynowCartItem, int> cartItems;
  final double total;
  final int count;
  List<PaynowCartItem> get cartItemsList => cartItems.keys.toList().cast<PaynowCartItem>();

  CartState copyWith({
    Map<PaynowCartItem, int>? cartItems,
    int? count,
    double? total,
  }) => CartState(
    cartItems: cartItems ?? this.cartItems,
    total: total ?? this.total,
    count: count ?? this.count
  );

  @override
  // TODO: implement props
  List<Object?> get props => [
    cartItems,
    count,
    total,
  ];
}

class CartRepository{
  CartRepository({
    required this.paynowCartItems
  });

  final Map<PaynowCartItem, int> paynowCartItems;

  /// Get List of current paynowCartItems
  List<PaynowCartItem> get currentPaynowItems => paynowCartItems.keys.toList().cast<PaynowCartItem>();
  /// Return Info of items in cart.
  String get info => this.paynowCartItems.keys.fold<String>('', (previous, item)=>previous+item.title);

  /// Total amount of items in cart.

  double get total => this.paynowCartItems.entries.fold<double>(
    0.0, (previous, item)
      => double.parse(
        (previous+item.key.amount * item.value).toStringAsExponential(2)
      ) );

  /// Clear the cart
  void clearCart(){
    this.paynowCartItems.clear();
  }

  /// Get Quantity
  int getQuantity (PaynowCartItem paynowCartItem) => this.paynowCartItems[paynowCartItem]!;

  /// Delete Item from cart
  void deleteCartItem(PaynowCartItem cartItem){
    this.paynowCartItems.remove(cartItem);
  }

  /// Adding [PaynowCartItems] to [Payment.items]
  /// [quantity]
  void addToCart(PaynowCartItem cartItem, { int? quantity }) {
    if (this.paynowCartItems.containsKey(cartItem)){
      /// then increment quantity by 1 if [quantity] is null
      this.paynowCartItems[cartItem] = this.paynowCartItems[cartItem]! + (quantity ?? 1);
    }else{
      /// Add new item to cart with initial quantity of 1 if [quantity] is null
      this.paynowCartItems[cartItem] = quantity ?? 1;
    }
  }

  /// Remove [PaynowCartItem]s from [Payment.items]
  void removeFromCart(PaynowCartItem cartItem, { int? quantity }) {
    if (this.paynowCartItems.containsKey(cartItem)){

      /// then decreement quantity by 1 if [quantity] is null
      this.paynowCartItems[cartItem] = this.paynowCartItems[cartItem]! - (quantity ?? 1);
      // remove map if it has reached 0 or below
      if (this.paynowCartItems[cartItem]! <= 0){
        this.paynowCartItems.remove(cartItem);
      }
    }
  }


}

class CartCubit extends Cubit<CartState>{
  CartCubit({
    required this.cartRepository
  }) : super(CartState.initial());
  final CartRepository cartRepository;

  void _reloadCart(){
    emit(state.copyWith(
      cartItems: cartRepository.paynowCartItems,
      count: cartRepository.paynowCartItems.length,
      total: cartRepository.total
    ));
  }

  /// Add Item to cart
  /// Optionally Specify quantity
  void addToCart(paynowCartItem, {int? quantity}){
    cartRepository.addToCart(paynowCartItem, quantity: quantity);
    _reloadCart();
  }

  /// Remove an item from cart
  /// If [quantity] is greater than current quantity, item will be removed
  void removeFromCart(paynowCartItem, {int? quantity}){
    cartRepository.removeFromCart(paynowCartItem, quantity: quantity);
    _reloadCart();
  }

  /// Delete cart item and it's quantity
  void deleteFromCart(PaynowCartItem paynowCartItem){
    cartRepository.deleteCartItem(paynowCartItem);
    _reloadCart();
  }
}
