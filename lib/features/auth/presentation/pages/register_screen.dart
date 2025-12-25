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

  // --- Validation Logic ---
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) return 'please_enter_name'.tr();
    if (value.length < 3) return 'name_min_3_chars'.tr();
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'please_enter_email'.tr();
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'please_enter_valid_email'.tr();
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'please_enter_password'.tr();
    if (value.length < 6) return 'password_min_6_chars'.tr();
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'please_confirm_password'.tr();
    if (value != _passwordController.text) return 'passwords_not_match'.tr();
    return null;
  }

  // --- Actions ---
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

  void _handleAppleSignIn() {
    context.read<AuthCubit>().signInWithApple();
  }

  // 🟢 Navigation: Pop if coming from Login, otherwise go to Login
  void _navigateToLogin() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.authLogin);
    }
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
      // 🟢 Removed AppBar to use custom positioning
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
              // --- 1. Background Decoration ---
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

              // --- 2. Main Content ---
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
                  }
                },
                builder: (context, state) {
                  final isLoading = state is AuthLoading;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 60), // Space for top content
                          Text(
                            'create_new_account'.tr(),
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
                            'fill_info_to_register'.tr(),
                            style: TextStyle(
                              fontSize: 16,
                              color: theme.colorScheme.onSurfaceVariant,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 48),

                          CustomTextField(
                            controller: _nameController,
                            label: 'name'.tr(),
                            hint: 'enter_full_name'.tr(),
                            prefixIcon: Icons.person_outlined,
                            validator: _validateName,
                            enabled: !isLoading,
                          ),
                          const SizedBox(height: 16),

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

                          _buildPasswordContainer(
                            controller: _passwordController,
                            isConfirm: false,
                            isLoading: isLoading,
                            theme: theme,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 16),

                          _buildPasswordContainer(
                            controller: _confirmPasswordController,
                            isConfirm: true,
                            isLoading: isLoading,
                            theme: theme,
                            isDark: isDark,
                          ),

                          const SizedBox(height: 24),

                          AuthButton(
                            text: 'create_account'.tr(),
                            onPressed: _handleRegister,
                            isLoading: isLoading,
                          ),

                          const SizedBox(height: 24),

                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: theme.colorScheme.outlineVariant,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(
                                  'or'.tr(),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: theme.colorScheme.outlineVariant,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          GoogleSignInButton(
                            onPressed: _handleGoogleSignIn,
                            isLoading: isLoading,
                          ),

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
                                'already_have_account'.tr(),
                                style: theme.textTheme.bodyMedium,
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
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // --- 3. Custom Back Button (Floating on Top) ---
              Align(
                alignment: AlignmentDirectional
                    .topStart, // Auto-adjusts for Arabic/English
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: theme.colorScheme.onSurface,
                      size: 28,
                    ),
                    onPressed: _navigateToLogin,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordContainer({
    required TextEditingController controller,
    required bool isConfirm,
    required bool isLoading,
    required ThemeData theme,
    required bool isDark,
  }) {
    return FormField<String>(
      validator: (value) => isConfirm
          ? _validateConfirmPassword(controller.text)
          : _validatePassword(controller.text),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (formFieldState) {
        final isVisible = isConfirm
            ? _isConfirmPasswordVisible
            : _isPasswordVisible;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                            : Colors.white.withValues(alpha: .95))
                      : (isDark
                            ? theme.colorScheme.surface.withValues(alpha: .6)
                            : Colors.white.withValues(alpha: .6)),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TextField(
                  controller: controller,
                  obscureText: !isVisible,
                  enabled: !isLoading,
                  onChanged: (value) => formFieldState.didChange(value),
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    labelText: isConfirm
                        ? 'confirm_password'.tr()
                        : 'password'.tr(),
                    hintText: isConfirm
                        ? 'reenter_password'.tr()
                        : 'enter_password'.tr(),
                    labelStyle: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: .6,
                      ),
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    prefixIcon: const Icon(
                      Icons.lock_outlined,
                      color: AppColors.goldenPrimary,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.goldenPrimary,
                      ),
                      onPressed: () {
                        setState(() {
                          if (isConfirm) {
                            _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible;
                          } else {
                            _isPasswordVisible = !_isPasswordVisible;
                          }
                        });
                      },
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ),
            if (formFieldState.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 12),
                child: Text(
                  formFieldState.errorText!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }
}
