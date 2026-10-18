import 'package:flutter/material.dart';

import 'summary_card.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
    home: const SignUpScreen(),
  );
}

const groups = ['IT-2301', 'IT-2302', 'IT-2303', 'IT-2304', 'IT-2305'];

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _birthText = TextEditingController();

  final _emailFocus = FocusNode();

  int _passwordLength = 0;
  String? _group;
  DateTime? _birth;
  bool _agreed = false;
  bool _done = false;

  @override
  void dispose() {
    for (final c in [_name, _email, _password, _confirm, _birthText]) {
      c.dispose();
    }
    _emailFocus.dispose();
    super.dispose();
  }

  void _hideKeyboard(PointerDownEvent event) {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  // ---------- validators: text in, error or null out ----------

  String? _validateName(String? v) {
    return (v ?? '').trim().length < 2 ? 'At least 2 characters' : null;
  }

  String? _validateEmail(String? v) {
    final text = (v ?? '').trim();
    final at = text.indexOf('@');
    if (at == -1 || !text.substring(at + 1).contains('.')) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? v) {
    return (v ?? '').length < 8 ? 'At least 8 characters' : null;
  }

  String? _validateConfirm(String? v) {
    return v != _password.text ? 'Passwords do not match' : null;
  }

  String? _validateGroup(String? g) {
    return g == null ? 'Choose a group' : null;
  }

  String? _validateBirth(String? v) {
    return _birth == null ? 'Pick your date of birth' : null;
  }

  // ---------- date picker ----------

  String _formatDate(DateTime d) {
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    return '$day.$month.${d.year}';
  }

  Future<void> _pickBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birth ?? DateTime(2006, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked == null || !mounted) return; // Cancel keeps the old date
    setState(() {
      _birth = picked;
      _birthText.text = _formatDate(picked);
    });
  }

  // ---------- buttons ----------

  void _signUp() {
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Account created')));
    setState(() => _done = true);
  }

  void _startOver() {
    // No _formKey.currentState here: the Form is not on screen now.
    setState(() {
      for (final c in [_name, _email, _password, _confirm, _birthText]) {
        c.clear();
      }
      _passwordLength = 0;
      _group = null;
      _birth = null;
      _agreed = false;
      _done = false;
    });
  }

  // ---------- screens ----------

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name'),
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _emailFocus.requestFocus(),
              onTapOutside: _hideKeyboard,
              validator: _validateName,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _email,
              focusNode: _emailFocus,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'name@kbtu.kz',
              ),
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              textInputAction: TextInputAction.next,
              onTapOutside: _hideKeyboard,
              validator: _validateEmail,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _password,
              decoration: const InputDecoration(
                labelText: 'Password',
                helperText: 'At least 8 characters',
              ),
              obscureText: true,
              textInputAction: TextInputAction.next,
              onChanged: (v) => setState(() => _passwordLength = v.length),
              onTapOutside: _hideKeyboard,
              validator: _validatePassword,
            ),
            Text('$_passwordLength of 8'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _confirm,
              decoration: const InputDecoration(labelText: 'Confirm password'),
              obscureText: true,
              textInputAction: TextInputAction.done,
              // Same as the button: null while the rules are not accepted.
              onFieldSubmitted: _agreed ? (_) => _signUp() : null,
              onTapOutside: _hideKeyboard,
              validator: _validateConfirm,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _group,
              decoration: const InputDecoration(labelText: 'Group'),
              items: [
                for (final g in groups)
                  DropdownMenuItem(value: g, child: Text(g)),
              ],
              onChanged: (g) => setState(() => _group = g),
              validator: _validateGroup,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _birthText,
              readOnly: true, // no keyboard, a tap opens the picker
              onTap: _pickBirth,
              decoration: const InputDecoration(
                labelText: 'Date of birth',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              validator: _validateBirth,
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('I agree to the rules'),
              value: _agreed,
              onChanged: (v) => setState(() => _agreed = v ?? false),
            ),
            const SizedBox(height: 24), // not a Spacer: we are in a scroll view
            FilledButton(
              onPressed: _agreed ? _signUp : null, // null = grey, disabled
              child: const Text('Sign up'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    final birth = _birth;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SummaryCard(
            name: _name.text.trim(),
            email: _email.text.trim(),
            group: _group ?? '',
            birthDate: birth == null ? '' : _formatDate(birth),
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: _startOver, child: const Text('Start over')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sign up')),
    body: _done ? _buildSummary() : _buildForm(),
  );
}
