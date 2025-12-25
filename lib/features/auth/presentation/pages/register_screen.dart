import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../../../../../core/routes/app_routes.dart';
import '../../../../../core/constants/app_colors.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/auth_button.dart';
import '../widgets/google_sign_in_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'please_enter_name'.tr();
    }
    if (value.length < 3) {
      return 'name_min_3_chars'.tr();
    }
    return null;
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

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'please_confirm_password'.tr();
    }
    if (value != _passwordController.text) {
      return 'passwords_not_match'.tr();
    }
    return null;
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        displayName: _nameController.text.trim(),
      );
    }
  }

  void _handleGoogleSignIn() {
    context.read<AuthCubit>().signInWithGoogle();
  }

  void _navigateToLogin() {
    context.go(AppRoutes.authLogin);
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
              // Islamic Pattern Background - Top Right
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
              // Islamic Pattern Background - Bottom Left
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
                      'register_success'.tr(),
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
                          SizedBox(height: 60.h),
                          Text(
                            'create_new_account'.tr(),
                            style: TextStyle(
                              fontSize: 34.sp,
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
                          SizedBox(height: 12.h),
                          Text(
                            'fill_info_to_register'.tr(),
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: theme.colorScheme.onSurfaceVariant,
                              height: 1.5.h,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 48.h),
                          CustomTextField(
                            controller: _nameController,
                            label: 'name'.tr(),
                            hint: 'enter_full_name'.tr(),
                            prefixIcon: Icons.person_outlined,
                            validator: _validateName,
                            enabled: !isLoading,
                          ),
                          SizedBox(height: 16.h),
                          CustomTextField(
                            controller: _emailController,
                            label: 'email'.tr(),
                            hint: 'enter_email'.tr(),
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: _validateEmail,
                            enabled: !isLoading,
                          ),
                          SizedBox(height: 16.h),
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
                                      borderRadius: BorderRadius.circular(16.r),
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
                                        borderRadius: BorderRadius.circular(
                                          14.r,
                                        ),
                                      ),
                                      child: TextField(
                                        controller: _passwordController,
                                        obscureText: !_isPasswordVisible,
                                        enabled: !isLoading,
                                        onChanged: (value) =>
                                            formFieldState.didChange(value),
                                        style: TextStyle(
                                          color: theme.colorScheme.onSurface,
                                          fontSize: 16.sp,
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
                                            borderSide: BorderSide(
                                              color: Colors.red,
                                              width: 2.w,
                                            ),
                                          ),
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(14.r),
                                                borderSide: BorderSide(
                                                  color: Colors.red,
                                                  width: 2.w,
                                                ),
                                              ),
                                          filled: false,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 16,
                                              ),
                                          errorStyle: TextStyle(
                                            height: 0.h,
                                            fontSize: 0.sp,
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
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                          SizedBox(height: 16.h),
                          FormField<String>(
                            validator: (value) => _validateConfirmPassword(
                              _confirmPasswordController.text,
                            ),
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
                                      borderRadius: BorderRadius.circular(16.r),
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
                                        borderRadius: BorderRadius.circular(
                                          14.r,
                                        ),
                                      ),
                                      child: TextField(
                                        controller: _confirmPasswordController,
                                        obscureText: !_isConfirmPasswordVisible,
                                        enabled: !isLoading,
                                        onChanged: (value) =>
                                            formFieldState.didChange(value),
                                        style: TextStyle(
                                          color: theme.colorScheme.onSurface,
                                          fontSize: 16.sp,
                                        ),
                                        decoration: InputDecoration(
                                          labelText: 'confirm_password'.tr(),
                                          hintText: 'reenter_password'.tr(),
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
                                              _isConfirmPasswordVisible
                                                  ? Icons
                                                        .visibility_off_outlined
                                                  : Icons.visibility_outlined,
                                              color: AppColors.goldenPrimary,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _isConfirmPasswordVisible =
                                                    !_isConfirmPasswordVisible;
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
                                            borderSide: BorderSide(
                                              color: Colors.red,
                                              width: 2.w,
                                            ),
                                          ),
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(14.r),
                                                borderSide: BorderSide(
                                                  color: Colors.red,
                                                  width: 2.w,
                                                ),
                                              ),
                                          filled: false,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 16,
                                              ),
                                          errorStyle: TextStyle(
                                            height: 0.h,
                                            fontSize: 0.sp,
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
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                          SizedBox(height: 24.h),
                          AuthButton(
                            text: 'create_account'.tr(),
                            onPressed: _handleRegister,
                            isLoading: isLoading,
                          ),
                          SizedBox(height: 24.h),
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
                          SizedBox(height: 24.h),
                          GoogleSignInButton(
                            onPressed: _handleGoogleSignIn,
                            isLoading: isLoading,
                          ),
                          SizedBox(height: 32.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'already_have_account'.tr(),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              TextButton(
                                onPressed: isLoading ? null : _navigateToLogin,
                                child: Text(
                                  'sign_in'.tr(),
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
