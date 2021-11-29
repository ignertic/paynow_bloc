
import 'package:paynow/models/models.dart';
import 'package:paynow/paynow.dart';

import 'src/cart/bloc/cart.cubit.dart';
import 'src/models/payment_info.dart';
import 'src/paynow_bloc/bloc/core.dart';
const String PAYNOW_INTEGRATION_ID = "INTEGRATION_ID";
const String PAYNOW_INTEGRATION_KEY = "INTEGRATION_KEY";
const String PAYNOW_EMAIL = 'ignertic@icloud.com';
const String RESULT_URL = 'http:/google.com/q=yoursite';
const String RETURN_URL = 'http://google.com/q=yoursite';

final paynow = Paynow(
  integrationId: PAYNOW_INTEGRATION_ID,
  integrationKey: PAYNOW_INTEGRATION_KEY,
  returnUrl: RETURN_URL,
  resultUrl: RESULT_URL
);

main()async{
  final repo = CartRepository(paynowCartItems: <PaynowCartItem, int>{});
  final cart = CartCubit(
    cartRepository: repo
  );
  final bloc = PaynowBloc(
    config: PaynowConfig(
      integrationId: PAYNOW_INTEGRATION_ID,
      integrationKey: PAYNOW_INTEGRATION_KEY,
      authEmail: 'ignertic@icloud.com',
      reference: 'Some Test',
    ),
    cartRepository: repo,
  );

  bloc.stream.listen((state) {
    if (state is PaynowFailedState){
      print(state.message);
    }else if (state is PaynowPendingState){
      print(state.response.redirectUrl);
    }else if(state is PaynowLoadingState){
      print('Processing...');
    }
  });

  final item = PaynowCartItem(amount: 3,title: 'sf');
  cart.addToCart(item, quantity: 5);
  bloc.startPayment(PaynowPaymentInfo(
    paymentMethod: PaynowPaymentMethod.web,
    returnUrl: 'google.com',
    resultUrl: 'google.com/res',
  ));


}
