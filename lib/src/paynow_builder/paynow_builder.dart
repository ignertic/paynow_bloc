import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paynow/paynow.dart';
import 'package:paynow_bloc/src/cart/bloc/cart_bloc.dart';
import 'package:paynow_bloc/src/models/payment_result.dart';
import '../paynow_bloc/bloc/paynow_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../paynow_bloc.dart';
import '../paynow_bloc/model/paynow_config.model.dart';
import '../paynow_bloc/model/paynow_payment_info.model.dart';


/// Widget using the [PaynowBloc] to gracefully handle the payment workflow.
/// It handles all the logic behind the scenes
/// You are only required to plug in your UI.
/// Each Builder provides ready to use information about your cart.
class PaynowBuilder extends StatefulWidget{

  PaynowBuilder({
    Key? key,
    required this.paynowConfig,
    required this.paynowPaymentInfo,
    required this.cartRepository,
    required this.onInitial,
    required this.onLoading,
    required this.onPending,
    required this.onSuccess,
    required this.onFailed,
    required this.checkoutButtonBuilder,
    this.forceWebView = true,
    this.forceSafariVC = false,
  }) : super(key: key);

  /// Paynow Configurations
  late final PaynowConfig paynowConfig;

  /// Cart repository for managing your cart
  late final CartRepository cartRepository;

  /// Information about the payment which includes the payment method
  late final PaynowPaymentInfo paynowPaymentInfo;

  /// This is the initial widget. Use case would be to use this as a checkout confirmation
  late final Widget Function(BuildContext context, PaynowInitialState initialState, List<PaynowCartItem> cart) onInitial;

  /// Showm when waiting for the user to complete the payment
  late final Widget Function(BuildContext context, PaynowPendingState pendingState, List<PaynowCartItem> cart) onPending;

  /// Shown when there is work being done under the hood.
  /// Place your fancy loaders here
  late final Widget Function(BuildContext context, PaynowLoadingState loadingState, List<PaynowCartItem> cart) onLoading;

  /// Shown when user has successfully paid.
  /// Place your success widgets here confirming transaction
  late final Widget Function(BuildContext context, PaynowSuccessState successState, List<PaynowCartItem> cart) onSuccess;

  /// Shown when something goes wrong
  late final Widget Function(BuildContext context, PaynowFailedState failedState, List<PaynowCartItem> cart) onFailed;

  /// This is the button for starting the payment
  /// Decorate it as you like but do not forget to call paynowBloc.startPayment
  final Widget Function(BuildContext context, PaynowBloc paynowBloc, CartRepository cartRepository) checkoutButtonBuilder;

  /// WIP
  late final bool forceWebView;
  late final bool forceSafariVC;



  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return PaynowBuilderState();
  }
}
class PaynowBuilderState extends State<PaynowBuilder>{
  late final PaynowBloc paynowBloc;

  @override
  void initState(){
    paynowBloc = PaynowBloc(
      PaynowDevRepository(paynowConfig: widget.paynowConfig)
    );

    super.initState();
  }

  @override
  void dispose(){
    paynowBloc.close();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
         title: Text('PAYNOW'),
      ),
      floatingActionButton: widget.checkoutButtonBuilder(context, paynowBloc, widget.cartRepository),
      body: RepositoryProvider(
        create: (_)=>widget.cartRepository,
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_)
                =>CartBloc(
                  widget.cartRepository
                ),
            ),
            BlocProvider.value(
              value: paynowBloc,
            ),
          ],
          child: BlocConsumer<PaynowBloc, PaynowState>(
            listener: (context, state)async{
              if (state is PaynowFailedState){
                ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(
                    backgroundColor: Colors.red,
                    content: Text('${state.message}'),
                  ));

                await Future.delayed(Duration(seconds: 8));
                Navigator.pop(context, PaynowPaymentResult(
                  paid: false,
                  statusResponse: state.statusResponse
                ));
              }else if (state is PaynowSuccessState){
                ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(
                    backgroundColor: Colors.greenAccent,
                    content: Text('${state.statusResponse}'),
                  ));


                await Future.delayed(Duration(seconds: 8));
                Navigator.pop(context, PaynowPaymentResult(
                  paid: true,
                  statusResponse: state.statusResponse
                ));

              }else if (state is PaynowPendingState){
                if (state.currentStatus.toLowerCase() == 'initiating'){

                  if (state.response.hasRedirect){
                    // launch
                    launch(

                      state.response.redirectUrl!,
                      enableJavaScript: true,
                      enableDomStorage: true,
                    );
                  }else{
                    ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(
                      backgroundColor: Colors.amber,
                      content: Text(state.response.instructions ?? 'Waiting for user action'),
                    ));
                  }
                }
              }
            },
            builder: (context, paynowState){
              late Widget returnWidget;

              if (paynowState is PaynowInitialState){
                // show initial widget
                returnWidget =  widget.onInitial(context, paynowState, widget.cartRepository.currentPaynowItems.toPaynowCartItems);
              }else if (paynowState is PaynowLoadingState){
                returnWidget =  widget.onLoading(context, paynowState, widget.cartRepository.currentPaynowItems.toPaynowCartItems);
              }else if (paynowState is PaynowPendingState){
                returnWidget =  widget.onPending(context, paynowState, widget.cartRepository.currentPaynowItems.toPaynowCartItems);
              }else if (paynowState is PaynowSuccessState){
                returnWidget =  widget.onSuccess(context, paynowState, widget.cartRepository.currentPaynowItems.toPaynowCartItems);
              }else if (paynowState is PaynowFailedState){
                returnWidget =  widget.onFailed(context, paynowState, widget.cartRepository.currentPaynowItems.toPaynowCartItems);
              }else{
                returnWidget =  Text('UnImplemented state $paynowState');
              }

              return AnimatedSwitcher(
                child: returnWidget,
                duration: Duration(milliseconds: 700),
              );
            },
          ),
        ),

      ),
    );
  }

}


/// A simplfied function to start the payment from UI layer
Future<PaynowPaymentResult> startPaynowPayment<E>(
  BuildContext context,
  {
    required PaynowConfig paynowConfig,
    required CartRepository cartRepository,
    required PaynowPaymentInfo paynowPaymentInfo,
    required Widget Function(BuildContext context, PaynowInitialState initialState, List<PaynowCartItem> cart) onInitial,
    required Widget Function(BuildContext context, PaynowPendingState pendingState, List<PaynowCartItem> cart) onPending,
    required Widget Function(BuildContext context, PaynowLoadingState loadingState, List<PaynowCartItem> cart) onLoading,
    required Widget Function(BuildContext context, PaynowSuccessState successState, List<PaynowCartItem> cart) onSuccess,
    required Widget Function(BuildContext context, PaynowFailedState failedState, List<PaynowCartItem> cart) onFailed,
    // required Widget Function(BuildContext context, PaynowBloc paynowBloc, CartRepository cartRepository) checkoutButtonBuilder,
    bool? forceWebView,
    bool? forceSafariVC,
  }
)async{
  final result = await Navigator.of(context).push(MaterialPageRoute(
    builder: (_)=>PaynowBuilder(
      cartRepository: cartRepository,
      paynowConfig: paynowConfig,
      paynowPaymentInfo: paynowPaymentInfo,
      onInitial: onInitial,
      onLoading: onLoading,
      onPending: onPending,
      onSuccess: onSuccess,
      onFailed: onFailed,
      checkoutButtonBuilder: (context, bloc, cart){
        return ElevatedButton(
            onPressed: (){
              bloc.add(PaynowStartWebCheckoutEvent(paynowPaymentInfo: paynowPaymentInfo));
            },
            child: Text('PAY')
        );
      },
    )
  ));

  return result;

}
