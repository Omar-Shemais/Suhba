import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:islamic_app/features/auth/presentation/widgets/apple_sign_In_button.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../../../../../core/routes/app_routes.dart';
import '../../../../../core/constants/app_colors.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/auth_button.dart';
import '../widgets/google_sign_in_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'please_enter_email'.tr();
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'please_enter_valid_email'.tr();
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'please_enter_password'.tr();
    }
    if (value.length < 6) {
      return 'password_min_6_chars'.tr();
    }
    return null;
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
  }

  void _handleGoogleSignIn() {
    context.read<AuthCubit>().signInWithGoogle();
  }

  void _handleAppleSignIn() {
    context.read<AuthCubit>().signInWithApple();
  }

  void _navigateToRegister() {
    context.go(AppRoutes.authRegister);
  }

  void _showSnackBar(
    BuildContext context,
    String title,
    String message,
    ContentType contentType,
  ) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: contentType,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: isDark
              ? null
              : const BoxDecoration(
                  gradient: AppColors.backgroundGradient,
                ).gradient,
          color: isDark ? theme.scaffoldBackgroundColor : null,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: -80,
                right: -80,
                child: Opacity(
                  opacity: isDark ? 0.04 : 0.08,
                  child: Icon(
                    Icons.mosque,
                    size: 220,
                    color: isDark ? theme.colorScheme.onSurface : Colors.white,
                  ),
                ),
              ),
              Positioned(
                bottom: -50,
                left: -50,
                child: Opacity(
                  opacity: isDark ? 0.04 : 0.08,
                  child: Icon(
                    Icons.mosque,
                    size: 180,
                    color: isDark ? theme.colorScheme.onSurface : Colors.white,
                  ),
                ),
              ),

              BlocConsumer<AuthCubit, AuthState>(
                listener: (context, state) {
                  if (state is AuthError) {
                    _showSnackBar(
                      context,
                      'error'.tr(),
                      state.message,
                      ContentType.failure,
                    );
                  } else if (state is AuthAuthenticated) {
                    _showSnackBar(
                      context,
                      'success'.tr(),
                      'login_success'.tr(),
                      ContentType.success,
                    );
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (context.mounted) {
                        context.go(AppRoutes.home);
                      }
                    });
                  }
                },
                builder: (context, state) {
                  final isLoading = state is AuthLoading;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 60),
                          Text(
                            'welcome_back'.tr(),
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                              shadows: isDark
                                  ? null
                                  : [
                                      Shadow(
                                        color: Colors.white.withValues(
                                          alpha: .6,
                                        ),
                                        offset: const Offset(0, 2),
                                        blurRadius: 4,
                                      ),
                                    ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'sign_in_to_continue'.tr(),
                            style: TextStyle(
                              fontSize: 16,
                              color: theme.colorScheme.onSurfaceVariant,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 48),
                          CustomTextField(
                            controller: _emailController,
                            label: 'email'.tr(),
                            hint: 'enter_email'.tr(),
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: _validateEmail,
                            enabled: !isLoading,
                          ),
                          const SizedBox(height: 16),
                          FormField<String>(
                            validator: (value) =>
                                _validatePassword(_passwordController.text),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            builder: (formFieldState) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: AppColors.goldenTripleGradient,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Container(
                                      margin: const EdgeInsets.all(1),
                                      decoration: BoxDecoration(
                                        color: !isLoading
                                            ? (isDark
                                                  ? theme.colorScheme.surface
                                                  : Colors.white.withValues(
                                                      alpha: .95,
                                                    ))
                                            : (isDark
                                                  ? theme.colorScheme.surface
                                                        .withValues(alpha: .6)
                                                  : Colors.white.withValues(
                                                      alpha: .6,
                                                    )),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: TextField(
                                        controller: _passwordController,
                                        obscureText: !_isPasswordVisible,
                                        enabled: !isLoading,
                                        onChanged: (value) =>
                                            formFieldState.didChange(value),
                                        style: TextStyle(
                                          color: theme.colorScheme.onSurface,
                                          fontSize: 16,
                                        ),
                                        decoration: InputDecoration(
                                          labelText: 'password'.tr(),
                                          hintText: 'enter_password'.tr(),
                                          labelStyle: TextStyle(
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                          hintStyle: TextStyle(
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant
                                                .withValues(alpha: .6),
                                          ),
                                          floatingLabelBehavior:
                                              FloatingLabelBehavior.never,
                                          prefixIcon: const Icon(
                                            Icons.lock_outlined,
                                            color: AppColors.goldenPrimary,
                                          ),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _isPasswordVisible
                                                  ? Icons
                                                        .visibility_off_outlined
                                                  : Icons.visibility_outlined,
                                              color: AppColors.goldenPrimary,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _isPasswordVisible =
                                                    !_isPasswordVisible;
                                              });
                                            },
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Colors.red,
                                              width: 2,
                                            ),
                                          ),
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                borderSide: const BorderSide(
                                                  color: Colors.red,
                                                  width: 2,
                                                ),
                                              ),
                                          filled: false,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 16,
                                              ),
                                          errorStyle: const TextStyle(
                                            height: 0,
                                            fontSize: 0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (formFieldState.hasError)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 6,
                                        left: 12,
                                      ),
                                      child: Text(
                                        formFieldState.errorText!,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          AuthButton(
                            text: 'sign_in'.tr(),
                            onPressed: _handleLogin,
                            isLoading: isLoading,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outlineVariant,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(
                                  'or'.tr(),
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outlineVariant,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          GoogleSignInButton(
                            onPressed: _handleGoogleSignIn,
                            isLoading: isLoading,
                          ),
                          // Show Apple Sign In only on iOS
                          if (Platform.isIOS) ...[
                            const SizedBox(height: 16),
                            AppleSignInButton(
                              onPressed: _handleAppleSignIn,
                              isLoading: isLoading,
                            ),
                          ],
                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'dont_have_account'.tr(),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              TextButton(
                                onPressed: isLoading
                                    ? null
                                    : _navigateToRegister,
                                child: Text(
                                  'sign_up_now'.tr(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
