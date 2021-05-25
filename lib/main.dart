import 'package:paynow_bloc/paynow_bloc.dart';

main()async{
  const String PAYNOW_INTEGRATION_ID = "";
  const String PAYNOW_INTEGRATION_KEY = "";
  const String PAYNOW_EMAIL = 'ignertic@icloud.com';
  const String RESULT_URL = 'http:/google.com/q=yoursite';
  const String RETURN_URL = 'http://google.com/q=yoursite';

  final paynow = Paynow(
    integrationId: PAYNOW_INTEGRATION_ID,
    integrationKey: PAYNOW_INTEGRATION_KEY,
    returnUrl: RETURN_URL,
    resultUrl: RESULT_URL
  );

  // Initialize PaynowBloc
  PaynowBloc paynowBloc = PaynowBloc(paynow: paynow);

  // listen to Cart Stream
  paynowBloc.cartStream.listen((state){
    state.forEach((cartItem, quantity){
      print("------------Item Added---------");
      print(cartItem.title);
      print(cartItem.price * quantity);
    });
  });

  // listen for Paynow Changles
  paynowBloc.stream.listen((state){
    if (state is PaynowPaymentFailureState){
      print(state.message);
      print(state.initResponse);

    }else if (state is PaynowLoadingState){
      // payment pending
      print(state.initResponse);
    }else if (state is PaynowPaymentSuccessfulState){
      // payment successful
      print(state.statusResponse);
    }else if (state is PaynowInitialState){
      print("PaynoBloc Ready");
    }
  });

  // Sample Items
  final sampleItems = [
    PaynowCartItem(title: "Banana", price: 20, imageUrl: "https://image.com/image.png"),
    PaynowCartItem(title: "SuperCode's Coffee", price: 22, imageUrl: "https://image.com/image.png")
  ];
  // add item to cart
  paynowBloc.add(AddItemToCartEvent(sampleItems[0]));
  paynowBloc.add(AddItemToCartEvent(sampleItems[1]));
  // remove item from cart
  paynowBloc.add(RemoveItemFromCartEvent(sampleItems[1]));
  await Future.delayed(Duration(seconds: 3));
  print("Checking out............");
  // checkout
  paynowBloc.add(PaynowCheckoutEvent(
    paynowPaymentInfo: PaynowPaymentInfo(
      authEmail: "ignertic@icloud.com",
      reference: "SuperCode",
      returnUrl: "https://google.com",
      resultUrl: "https://google.com",
      paymentMethod: PaynowPaymentMethod.web,
      phone: "0784442662"
    )
  ));
  print("Delay to clear cart");
  await Future.delayed(Duration(seconds: 10));
  // Clear Cart
  paynowBloc.add(ClearCartEvent());
  // close bloc
  paynowBloc.close();
}
