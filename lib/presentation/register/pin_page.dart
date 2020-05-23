import 'dart:async';

import 'package:LaCoro/core/bloc/base_bloc.dart';
import 'package:LaCoro/core/localization/app_localizations.dart';
import 'package:LaCoro/core/ui_utils/custom_widgets/primary_button.dart';
import 'package:LaCoro/presentation/order_detail/order_detail_page.dart';
import 'package:LaCoro/presentation/register/register_bloc.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class PinPage extends StatefulWidget {
  static const PIN_REGISTER_ROUTE = '/pin_register';

  @override
  _PinPageState createState() => _PinPageState(Injector.getInjector().get());
}

class _PinPageState extends State<PinPage> {
  final RegisterBloc _bloc;

  _PinPageState(this._bloc);

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  StreamController<ErrorAnimationType> errorController = StreamController<ErrorAnimationType>();
  TextEditingController _textEditingController = TextEditingController();
  bool hasError = false;
  bool isLoading = false;

  @override
  void dispose() {
    errorController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(elevation: 0),
      backgroundColor: Theme.of(context).backgroundColor,
      key: scaffoldKey,
      body: BlocListener(
        bloc: _bloc,
        listener: (BuildContext context, state) => handleState(state, context),
        child: Column(
          children: <Widget>[
            Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                strings.authorizationCode,
                style: Theme.of(context).textTheme.headline1,
                textAlign: TextAlign.center,
              ),
            ),
            Text(
              strings.enterTheCodeSentToTheCellPhone,
              style: Theme.of(context).textTheme.bodyText1,
            ),
            Text(
              _bloc.getProfileInfo().phone,
              style: Theme.of(context).textTheme.bodyText2,
            ),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: PinCodeTextField(
                  length: 5,
                  obsecureText: false,
                  animationType: AnimationType.fade,
                  shape: PinCodeFieldShape.box,
                  animationDuration: Duration(milliseconds: 300),
                  borderRadius: BorderRadius.circular(5),
                  fieldHeight: 52,
                  fieldWidth: 52,
                  backgroundColor: Theme.of(context).backgroundColor,
                  inactiveColor: Theme.of(context).disabledColor,
                  activeColor: Theme.of(context).disabledColor,
                  errorAnimationController: errorController,
                  controller: _textEditingController,
                  onCompleted: (v) {
                    print(strings.processing);
                  },
                  onChanged: (String value) {},
                )),
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                hasError ? strings.wrongCode : "",
                style: Theme.of(context).textTheme.caption,
              ),
            ),
            PrimaryButton(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                isLoading: isLoading,
                buttonText: strings.continu,
                onPressed: () {
                  if (_textEditingController.text.length != 5) {
                    errorController.add(ErrorAnimationType.shake); // Triggering error shake animation
                    setState(() {
                      hasError = true;
                    });
                  } else {
                    setState(() {
                      hasError = false;
                      _bloc.add(SubmitVerificationCodeEvent(_textEditingController.text));
                    });
                  }
                }),
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 45),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(text: strings.didntYouGetTheMessage, style: Theme.of(context).textTheme.bodyText1, children: [
                  TextSpan(
                      text: strings.resend,
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.pop(context);
                        },
                      style: TextStyle(color: Theme.of(context).accentColor, fontWeight: FontWeight.bold, fontSize: 16))
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void handleState(state, BuildContext context) {
    setState(() => isLoading = state is LoadingState);

    if (state is SuccessState) {
      Navigator.popUntil(context, ModalRoute.withName(OrderDetailPage.ORDER_DETAIL_ROUTE));
    }

    if (state is ErrorState) {
      setState(() => hasError = true);
      errorController.add(ErrorAnimationType.shake);
      scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(state.message), duration: Duration(seconds: 3)));
    }
  }
}