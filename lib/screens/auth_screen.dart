import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import '../widget/app_layout.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.service, required this.register});
  final ChatService service;
  final bool register;
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hidden = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading || !_form.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await widget.service.authenticate(
        _email.text,
        _password.text,
        register: widget.register,
      );
      if (!mounted) return;
      _password.clear();
      Navigator.pushNamedAndRemoveUntil(context, '/chat', (_) => false);
    } catch (error) {
      if (mounted) setState(() => _error = safeAuthError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: AppLayout(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: AutofillGroup(
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _loading
                        ? null
                        : () => Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/',
                            (_) => false,
                          ),
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text('Back to welcome'),
                  ),
                ),
                const SizedBox(height: 20),
                const Center(child: BrandMark()),
                const SizedBox(height: 28),
                Text(
                  widget.register ? 'Create your account' : 'Welcome back',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.register
                      ? 'Join the conversation. Make yourself at home.'
                      : 'Sign in and pick up the conversation.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF475569), height: 1.5),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _email,
                  enabled: !_loading,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  autocorrect: false,
                  validator: validateEmail,
                  decoration: const InputDecoration(
                    labelText: 'Email address',
                    hintText: 'you@example.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _password,
                  enabled: !_loading,
                  obscureText: _hidden,
                  autocorrect: false,
                  enableSuggestions: false,
                  autofillHints: [
                    widget.register
                        ? AutofillHints.newPassword
                        : AutofillHints.password,
                  ],
                  validator: (value) =>
                      validatePassword(value, register: widget.register),
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    helperText: widget.register
                        ? 'At least 6 characters. Keep it unique.'
                        : null,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      tooltip: _hidden ? 'Show password' : 'Hide password',
                      onPressed: () => setState(() => _hidden = !_hidden),
                      icon: Icon(
                        _hidden
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Semantics(
                      liveRegion: true,
                      child: Text(
                        _error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(widget.register ? 'Create account' : 'Sign In'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _loading
                      ? null
                      : () => Navigator.pushReplacementNamed(
                          context,
                          widget.register ? '/signin' : '/register',
                        ),
                  child: Text(
                    widget.register
                        ? 'Already a member? Sign In'
                        : 'New here? Create an account',
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Messages are shared with all signed-in members.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Color(0xFF475569)),
                ),
                if (widget.service.isDemo) const DemoNotice(),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
