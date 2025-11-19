import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:zero/appModules/auth/auth_controller.dart';
import 'package:zero/appModules/profile/profile_controller.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/customWidgets/page_view.dart';
import 'package:pinput/pinput.dart';

class LoginPage extends GetView<AuthController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(children: [
              const SizedBox(height: 50),
              _pageview(),
              Obx(
                () => controller.onboarded.value
                    ? const SizedBox()
                    : Padding(
                        padding: const EdgeInsets.all(20),
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: ColorConst.primaryColor,
                                foregroundColor: Colors.black,
                                fixedSize: Size.fromWidth(w)),
                            onPressed: () => controller.onboarded.value = true,
                            child: const Text('Get started')),
                      ),
              ),
            ]),
          ),
          Obx(() {
            if (controller.onboarded.value) {
              return _buildSignIn(
                h: h,
                w: w,
              );
            }
            return const SizedBox.shrink();
          })
        ],
      ),
    );
  }

  Widget _pageview() {
    List<Map<String, String>> items = [
      {
        'title': 'Join or Create Fleets',
        'subTitle':
            'Sign up as a driver, connect with nearby fleets or start your own when you\'re ready to grow.',
        'image': 'assets/images/1.jpg',
      },
      {
        'title': 'Losing money?',
        'subTitle':
            'No more losses. No more spreadsheets. Your entire fleet powered by one app.',
        'image': 'assets/images/2.png',
      },
      {
        'title': 'Track Earnings & Expenses',
        'subTitle':
            'View every trip, expense, and payment in one place. Stay clear about your true balance.',
        'image': 'assets/images/3.png',
      },
      {
        'title': 'Manage Duties Effortlessly',
        'subTitle':
            'Start and complete duties with real-time updates for trips, shifts, and vehicle details.',
        'image': 'assets/images/4.jpg',
      },
      {
        'title': 'Get Paid Instantly',
        'subTitle':
            'Send and receive payments directly through the app quick, simple, and secure.',
        'image': 'assets/images/5.png',
      },
    ];

    return EnhancedPageView(items: items);
  }

  Widget _buildSignIn({
    required double h,
    required double w,
  }) {
    if (controller.authStatus.value == AuthStatus.initial) {
      controller.otpController.clear();
      controller.authError.value = '';
    }
    return Form(
      key: controller.loginFormkey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            width: w,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Get.theme.cardColor,
                  Colors.black.withValues(alpha: 0.75),
                ],
              ),
            ),
            child: Obx(
              () => SingleChildScrollView(
                child: Column(
                  children: [
                    // Align(
                    //   alignment: Alignment.topRight,
                    //   child: IconButton(
                    //       onPressed: () => controller.onboarded.value = false,
                    //       icon: const Icon(Icons.close)),
                    // ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                          child: Image.asset(
                        'assets/icons/logo.png',
                        width: 150,
                        fit: BoxFit.fill,
                      )),
                    ),
                    const SizedBox(height: 20),
                    _phoneNumberField(),
                    const SizedBox(height: 20),
                    controller.authStatus.value == AuthStatus.otpSent ||
                            controller.authStatus.value ==
                                AuthStatus.verifyingOTP
                        ? otpField()
                        : const SizedBox.shrink(),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: ColorConst.primaryColor,
                            foregroundColor: Colors.black,
                            fixedSize: Size(w, 40)),
                        onPressed: controller.authStatus.value ==
                                    AuthStatus.sendingOTP ||
                                controller.authStatus.value ==
                                    AuthStatus.verifyingOTP
                            ? null
                            : () {
                                if (controller.loginFormkey.currentState!
                                    .validate()) {
                                  if (controller.authStatus.value ==
                                      AuthStatus.initial) {
                                    controller.verifyPhoneNumber();
                                  } else if (controller.authStatus.value ==
                                      AuthStatus.otpSent) {
                                    controller.verifyOtp();
                                  }
                                }
                              },
                        child: controller.authStatus.value ==
                                    AuthStatus.sendingOTP ||
                                controller.authStatus.value ==
                                    AuthStatus.verifyingOTP
                            ? const Center(child: CupertinoActivityIndicator())
                            : Text(controller.authStatus.value ==
                                    AuthStatus.initial
                                ? 'Send OTP'
                                : 'Verify OTP')),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Center(
                        child: Text(
                          controller.authError.value,
                          textAlign: TextAlign.center,
                          style: Get.textTheme.bodySmall!
                              .copyWith(color: Colors.red),
                        ),
                      ),
                    ),
                    _buildFooterSection()
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _phoneNumberField() {
    return TextFormField(
      controller: controller.phonenumberController,
      autofocus: true,
      readOnly: controller.authStatus.value != AuthStatus.initial,
      style: Get.textTheme.bodyMedium!.copyWith(color: Colors.white),
      cursorColor: Colors.white,
      maxLength: 10,
      textInputAction: TextInputAction.done,
      keyboardType: TextInputType.number,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onFieldSubmitted: (value) => controller.verifyPhoneNumber(),
      onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
      onChanged: (value) async {
        if (value.length == 10) {
          FocusManager.instance.primaryFocus?.unfocus();
          await controller.verifyPhoneNumber();
        } else {
          null;
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your Mobile number';
        }
        if (value.length != 10) {
          return 'Enter a valid Mobile number';
        }
        return null;
      },
      decoration: InputDecoration(
        counterText: '',
        fillColor: Colors.white12,
        suffixIcon: controller.authStatus.value == AuthStatus.otpSent
            ? TextButton(
                onPressed: () {
                  controller.authStatus.value = AuthStatus.initial;
                },
                child: const Text('Edit'))
            : null,
        prefixIcon: Padding(
          padding: const EdgeInsets.all(15),
          child: Text(
            '+91',
            style: Get.textTheme.bodyMedium!,
          ),
        ),
        hintText: 'Enter your phone number*',
      ),
    );
  }

  Widget otpField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Enter OTP'),
        const SizedBox(
          height: 10,
        ),
        FractionallySizedBox(
            child: Pinput(
          autofocus: true,
          controller: controller.otpController,
          onTapOutside: (event) =>
              FocusManager.instance.primaryFocus?.unfocus(),
          errorTextStyle: Get.textTheme.bodySmall!.copyWith(color: Colors.red),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the OTP';
            }
            if (value.length != 6) {
              return 'OTP must be 6 digits';
            }
            if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
              return 'OTP must contain only digits';
            }
            return null;
          },
          defaultPinTheme: PinTheme(
              height: 45,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                  color: Get.theme.cardColor,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.white.withValues(alpha: 0.25),
                        blurRadius: 4,
                        spreadRadius: 2),
                  ])),
          length: 6,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          onCompleted: (otp) {
            controller.verifyOtp();
          },
        )),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildFooterSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () =>
              Get.put(ProfileController()).openLink(urlSuffix: 'terms'),
          child: const Text(
            'Terms & Conditions',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ),
        const Text(
          ' • ',
          style: TextStyle(color: Colors.white54),
        ),
        TextButton(
          onPressed: () =>
              Get.put(ProfileController()).openLink(urlSuffix: 'privacy'),
          child: const Text(
            'Privacy Policy',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
