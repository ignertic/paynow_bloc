import 'package:paynow/paynow.dart';
import 'package:paynow_bloc/paynow_bloc.dart';


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

  final cart = CartBloc(CartRepository());
  final bloc = PaynowBloc(PaynowDevRepository(
    paynowConfig: PaynowConfig(
      integrationId: PAYNOW_INTEGRATION_ID,
      integrationKey: PAYNOW_INTEGRATION_KEY,
      authEmail: 'ignertic@icloud.com',
      reference: 'Some Test',

    )
  ));

  bloc.stream.listen((state) {
    if (state is PaynowFailedState){
      print(state.message);
    }else if (state is PaynowPendingState){
      print(state.response.redirectUrl);
    }else if(state is PaynowLoadingState){
      print('Processing...');
    }
  });

}
