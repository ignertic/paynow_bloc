import 'package:test/test.dart';

import 'package:paynow_bloc/paynow_bloc.dart';

void main() {

  group('CartCubit', () {
    CartCubit cartCubit;
    List items;

    setUp(() {
        cartCubit = CartCubit();
        items = [PaynowCartItem(title: "P", price: 20), PaynowCartItem(title: "P", price: 10)];
    });

    test('cart add item to cart', () {
        expect(cartCubit.state.length, 0);
        expect(cartCubit.total, 0);
        cartCubit.addItemToCart(items[0]);
        expect(cartCubit.state.length, 1);
        expect(cartCubit.total, 20.00);


    });

    // blocTest(
    //   'emits [1] when CounterEvent.increment is added',
    //   build: () => paynowBloc,
    //   act: (bloc) => bloc.add(AddItemToCartEvent(paynowCartItem)),
    //   expect: () => [1],
    // );
  });






  // test("test cart implementation", (){
  //   final bloc = PaynowBloc();
  //   final items = [PaynowCartItem(title: "R", price: 30), PaynowCartItem(title: "P", price: 20)];
  //   print("${bloc.cartItems}");
  //   bloc.add(AddItemToCartEvent(items[0]));
  //   expect(bloc.total, 30);
  //   print("${bloc.cartItems}");
  //   bloc.add(ClearCartEvent());
  //   expect(bloc.total, 0.0);
  // });
}
