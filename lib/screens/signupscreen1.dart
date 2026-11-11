import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../theme/palette.dart';
import 'homescreen.dart';
import 'legalcontent.dart';
import 'legalscreen.dart';
import 'loginscreen2.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _dob = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _kinName = TextEditingController();
  final _kinPhone = TextEditingController();

  DateTime? _dobValue;
  bool _hidePassword = true;
  bool _agreed = false;
  bool _termsError = false;

  late final TapGestureRecognizer _termsTap = TapGestureRecognizer()
    ..onTap = () => _openLegal('Terms of use', termsSections);
  late final TapGestureRecognizer _privacyTap = TapGestureRecognizer()
    ..onTap = () => _openLegal('Privacy policy', privacySections);

  @override
  void dispose() {
    _name.dispose();
    _dob.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _kinName.dispose();
    _kinPhone.dispose();
    _termsTap.dispose();
    _privacyTap.dispose();
    super.dispose();
  }

  void _openLegal(String title, List<LegalSection> sections) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LegalScreen(title: title, sections: sections),
      ),
    );
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dobValue ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Date of birth',
    );
    if (picked == null) return;
    setState(() {
      _dobValue = picked;
      _dob.text = '${picked.day.toString().padLeft(2, '0')}/'
          '${picked.month.toString().padLeft(2, '0')}/'
          '${picked.year}';
    });
  }

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color),
      );

  InputDecoration _decoration(String label, {String? hint, Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixIcon: suffix,
      filled: true,
      fillColor: Palette.surface,
      labelStyle: const TextStyle(color: Palette.muted),
      hintStyle: const TextStyle(color: Palette.line),
      border: _border(Palette.line),
      enabledBorder: _border(Palette.line),
      focusedBorder: _border(Palette.marigold),
      errorBorder: _border(Palette.rose),
      focusedErrorBorder: _border(Palette.rose),
      errorStyle: const TextStyle(color: Palette.rose),
    );
  }

  String? _validatePhone(String? v) {
    final digits = (v ?? '').replaceAll(RegExp(r'\D'), '');
    return digits.length >= 7 ? null : 'Enter a valid phone number';
  }

  String? _validateDob(String? _) {
    final d = _dobValue;
    if (d == null) return 'Select your date of birth';
    final now = DateTime.now();
    var age = now.year - d.year;
    if (now.month < d.month || (now.month == d.month && now.day < d.day)) {
      age--;
    }
    return age >= 18 ? null : 'You must be 18 or older to use ABCardsPro';
  }

  void _submit() {
    final formOk = _formKey.currentState!.validate();
    setState(() => _termsError = !_agreed);
    if (!formOk || !_agreed) return;

    // TODO: create the account on your backend, then go to ID verification.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    const linkStyle = TextStyle(
      color: Palette.marigold,
      decoration: TextDecoration.underline,
      fontWeight: FontWeight.w600,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create your account',
                      style: text.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add your details to start buying, selling and trading.',
                      style: text.bodyLarge?.copyWith(color: Palette.muted),
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.name],
                      decoration: _decoration('Full name'),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Enter your full name'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _dob,
                      readOnly: true,
                      onTap: _pickDob,
                      decoration: _decoration(
                        'Date of birth',
                        hint: 'DD/MM/YYYY',
                        suffix: const Icon(
                          Icons.calendar_today_outlined,
                          color: Palette.muted,
                        ),
                      ),
                      validator: _validateDob,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      decoration:
                          _decoration('Email', hint: 'name@company.com'),
                      validator: (v) {
                        final value = v?.trim() ?? '';
                        final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                            .hasMatch(value);
                        return ok ? null : 'Enter a valid email address';
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.telephoneNumber],
                      decoration: _decoration('Phone number'),
                      validator: _validatePhone,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _password,
                      obscureText: _hidePassword,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.newPassword],
                      decoration: _decoration(
                        'Password',
                        suffix: IconButton(
                          tooltip: _hidePassword
                              ? 'Show password'
                              : 'Hide password',
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Palette.muted,
                          ),
                          onPressed: () =>
                              setState(() => _hidePassword = !_hidePassword),
                        ),
                      ),
                      validator: (v) => (v ?? '').length >= 8
                          ? null
                          : 'Use at least 8 characters',
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Next of kin',
                      style: text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Someone we can contact if we can't reach you.",
                      style: text.bodyMedium?.copyWith(color: Palette.muted),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _kinName,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: _decoration('Next of kin full name'),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? "Enter your next of kin's full name"
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _kinPhone,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      decoration: _decoration('Next of kin phone number'),
                      validator: _validatePhone,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _agreed,
                          activeColor: Palette.marigold,
                          checkColor: Palette.night,
                          side: BorderSide(
                            color: _termsError ? Palette.rose : Palette.muted,
                            width: 1.5,
                          ),
                          onChanged: (v) => setState(() {
                            _agreed = v ?? false;
                            if (_agreed) _termsError = false;
                          }),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text.rich(
                              TextSpan(
                                style: TextStyle(
                                  color: _termsError
                                      ? Palette.rose
                                      : Palette.muted,
                                ),
                                children: [
                                  const TextSpan(text: 'I agree to the '),
                                  TextSpan(
                                    text: 'terms',
                                    style: linkStyle,
                                    recognizer: _termsTap,
                                  ),
                                  const TextSpan(text: ' and '),
                                  TextSpan(
                                    text: 'privacy policy',
                                    style: linkStyle,
                                    recognizer: _privacyTap,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_termsError)
                      const Padding(
                        padding: EdgeInsets.only(left: 12),
                        child: Text(
                          'Agree to the terms to continue',
                          style: TextStyle(color: Palette.rose, fontSize: 12),
                        ),
                      ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Palette.marigold,
                          foregroundColor: Palette.night,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _submit,
                        child: const Text(
                          'Create account',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                     SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>  LoginScreen(),
                          ),
                        ),
                        child: Text(
                          'Already have an account? Log in',
                          style: TextStyle(color: Palette.marigold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}