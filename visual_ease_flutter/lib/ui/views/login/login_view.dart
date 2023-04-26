import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'login_viewmodel.dart';

class LoginView extends StackedView<LoginViewModel> {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    LoginViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Image.asset(
                'assets/splash.png',
                height: 200,
              ),
            ),
            const Text(
              "Login/Signup",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 28.0),
              child: SizedBox(
                width: 220,
                height: 70,
                child: FormField(
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a user type';
                    }
                    return null;
                  },
                  builder: (FormFieldState<Object> field) {
                    return DropdownButtonFormField<String>(
                      items: viewModel.userTypes.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                              value == 'blind' ? "Blind User" : "Bystander"),
                        );
                      }).toList(),
                      onChanged: viewModel.setRole,
                      decoration: const InputDecoration(
                        labelText: 'Select User Type',
                        border: OutlineInputBorder(),
                      ),
                    );
                  },
                ),
              ),
            ),
            SignInButton(
              Buttons.Google,
              onPressed: viewModel.login,
            ),
            if (viewModel.isBusy)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
          ],
        ),
      ),
    );
  }

  @override
  LoginViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      LoginViewModel();
}
