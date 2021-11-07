import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paynow/models/models.dart';
import 'package:paynow_bloc/src/cart/bloc/cart.cubit.dart';
import 'package:paynow_bloc/src/paynow_bloc/bloc/core.dart';


class PaynowBuilder extends StatelessWidget{
  PaynowBuilder({
    Key? key,
    required this.paynowConfig,
    required this.onInitial,
    required this.onLoading,
    required this.onPending,
    required this.onSuccess,
    required this.onFailed
  }) : super(key: key);

  final PaynowConfig paynowConfig;

  final Widget Function(BuildContext context, PaynowInitialState initialState, CartState cart) onInitial;
  final Widget Function(BuildContext context, PaynowPendingState pendingState, CartState cart) onPending;
  final Widget Function(BuildContext context, PaynowLoadingState loadingState, CartState cart) onLoading;
  final Widget Function(BuildContext context, PaynowSuccessState successState, CartState cart) onSuccess;
  final Widget Function(BuildContext context, PaynowFailedState failedState, CartState cart) onFailed;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return RepositoryProvider(
      create: (_)=>CartRepository(
        paynowCartItems: <PaynowCartItem, int>{}
      ),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_)
              =>CartCubit(
                cartRepository: context.read<CartRepository>()
              ),
          ),
          BlocProvider(
            create: (_)=>PaynowBloc(
              config: paynowConfig,
              cartRepository: context.read<CartRepository>()
            ),
          ),
          // PaynowBloc(
          //   config:
          // )
        ],
        child: BlocBuilder<PaynowBloc, PaynowState>(
          builder: (context, paynowState){

            if (paynowState is PaynowInitialState){
              // show initial widget
              return onInitial(context, paynowState, context.watch<CartCubit>().state);
            }else if (paynowState is PaynowLoadingState){
              return onLoading(context, paynowState, context.watch<CartCubit>().state);
            }else if (paynowState is PaynowPendingState){
              return onPending(context, paynowState, context.watch<CartCubit>().state);
            }else if (paynowState is PaynowSuccessState){
              return onSuccess(context, paynowState, context.watch<CartCubit>().state);
            }else if (paynowState is PaynowFailedState){
              return onFailed(context, paynowState, context.watch<CartCubit>().state);
            }else{
              return Text('UnImplemented state $paynowState');
            }
          },
        ),
      ),

    );
  }

}
