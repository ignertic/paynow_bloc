import 'package:paynow/paynow.dart' show PaynowCartItem;

class CartItem extends PaynowCartItem{
  CartItem({required String title, required double amount}) : super(title: title, amount: amount);
}