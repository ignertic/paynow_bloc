# paynow_bloc

## Paynow Bloc
An extension of the [Paynow Package](https://pub.dev/packages/paynow) implemented as a Bloc for easy payment integration with Paynow.

_This package aims to improve integration of Payments (Paynow) by handling all the [Paynow](https://pub.dev/packages/paynow) requests and cleaning up under the hood. Focus on the UI side of things_

*Bloc Knowledge Required. [Bloc package](https://pub.dev/packages/bloc)


All you have to do is:

1. Initialize PaynowBloc like any other Bloc
2. Stream the cart list using the StreamBuilder widget
3. As any other Bloc, stream the PaynowStates. Only 4 are available:

      * _PaynowPaymentSuccessfulState_
        - Emitted when transaction is successful

      * _PaynowPaymentFailureState_
        - Emitted when there is an error and also provides error information

      * _PaynowLoadingState_
        - Emitted when payment request is successful
        - Contains information of the pending payment request [InitResponse]

      * _PaynowInitialState_
        - The inittial state of the PaynowBloc
        - Can be used to display the PAY button

4. Add Items to cart [PaynowCartItem] via event `AddItemToCartEvent`
   * Remove item from cart by sending event `RemoveItemFromCartEvent`

5. Start checkout by sending event `PaynowCheckoutEvent`
   * _PaynowCheckoutEvent_ takes _PaynowPaymentInfo_ as an argument
   * _PaynowPaymentInfo_ will take the request information such as
    - Reference
    - Result Url (optional)
    - Return Url (optional)
    - Payment Method (web/express)

### That's all you need to do, no more manually handling urls.
### Every state contains information of the transaction and the cart items `Map<PaynowCartItem, int>` or simply (item, quantity)


### Features
    * Cart Implementation
    * Serverless Payment
    * Auto Transaction Status Checking -> only listen for state changes
    * Streamable Cart List -> (great for animations)

_if you decide to use this package, remove the paynow dependency in your project_

## Getting Started

### For a full example. Please refer to this functional e-commerce app example.

*NOTE:* The code below is an overview of this package.

```
    // create your Paynow Instance
    final Paynow paynow = Paynow(
            integrationId: "INTEGRATION_ID",
            integrationKey: "INTEGRATION_KEY",
            returnUrl: "https://server.url/return",
            resultUrl: "https://server.url/result"
            );

    // Create the PaynowBloc and paynow as an argument
    final PaynowBloc paynowBloc = PaynowBloc(paynow: paynow);

    // Stream your cart listing `Map<PaynowCartItem, int>`
    paynowBloc.cartStream.listen((cartItems){
        cartItems.forEach((cartItem, quantity){
            print("${cartItem.title}: ${cartItem.price} x$quantity = ${quantity * cartItem.price }")
        });
      });

    // listen for PaynowBloc state changes
    paynowBloc.stream.listen((state){
        if (state is PaynowInitialState){
            // PaynowBloc is ready.
        }else if (state is PaynowPaymentFailureState){
          // something went wrong, print the message from the bloc
          print(state.message);
        }else if (state is PaynowPaymentSuccessfulState){
          // transaction was successful
          // You can access the StatusResponse in this state
          // To be sure let's check

          if (state.statusResponse.paid){
            print("Great! You paid. Enjoy Premium");
          }else{
            print("This will never show");
          }
        }else if (state is PaynowLoadingState){
           // Transaction is now in process
           // Access the InitResponse in this state
           // print the instructions from Paynow
           print(state.initResponse.instructions);
        }
    });

    // Create PaynowCartItems
    final sampleCartItems = List.generate(3, (index)=> PaynowCartItem(title: "Item $index", price: 10);

    // Add Items to cart as an event
    sampleCartItems.forEach((cartItem){
        paynowBloc.add(AddItemToCartEvent(cartItem));
    })

    // Remove item in cart
    paynowBloc.add(RemoveItemFromCartEvent(sampleCartItems[0]));

    // Express Checkout
    paynowBloc.add(PaynowCheckoutEvent(
        paynowPaymentInfo: PaynowPaymentInfo(
          authEmail: "ignertic@icloud.com",
          reference: "SuperCode's Coffee",
          returnUrl: "https://google.com", // optional
          resultUrl: "https://google.com", // optional
          paymentMethod: PaynowPaymentMethod.express,
          phone: "0784442662" //
        )
    ));

    // Web checkout
    paynowBloc.add(PaynowCheckoutEvent(
            paynowPaymentInfo: PaynowPaymentInfo(
              authEmail: "ignertic@icloud.com",
              reference: "SuperCode's Coffee",
              returnUrl: "https://server.url/return/$userId",
              resultUrl: "https://server.url/result/$userId",
              paymentMethod: PaynowPaymentMethod.web,

            )
        ));

    // Clear Cart
    paynowBloc.add(ClearCartEvent();

```
