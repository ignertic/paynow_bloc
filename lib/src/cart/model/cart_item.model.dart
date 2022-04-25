import 'package:equatable/equatable.dart';

class CartItem extends Equatable{

  final String title;
  final double amount;

  @override
  // TODO: implement props
  List<Object?> get props => [title, amount];

  const CartItem({
    required this.title,
    required this.amount,
  });
}