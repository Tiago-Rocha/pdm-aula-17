import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/session_notifier.dart';
import '../state/settings.dart';

/// Log in, or create an account with the same form plus a name.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  late final _email = TextEditingController(
    text: context.read<Settings>().lastEmail, // filled in from the last time
  );
  final _password = TextEditingController();
  bool _creating = false; // false: log in, true: create an account

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    final session = context.read<SessionNotifier>();
    final email = _email.text.trim();
    context.read<Settings>().saveLastEmail(email);
    if (_creating) {
      session.register(_name.text.trim(), email, _password.text);
    } else {
      session.login(email, _password.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionNotifier>();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _creating ? 'Criar conta' : 'Entrar',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 24),
                    if (_creating) ...[
                      TextFormField(
                        controller: _name,
                        decoration: const InputDecoration(labelText: 'Nome'),
                        textInputAction: TextInputAction.next,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Escreve o teu nome.'
                            : null,
                      ),
                      const SizedBox(height: 12),
                    ],
                    TextFormField(
                      controller: _email,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
                      validator: (v) => (v == null || !v.contains('@'))
                          ? 'O email não é válido.'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _password,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      autofillHints: const [AutofillHints.password],
                      onFieldSubmitted: (_) => _submit(),
                      validator: (v) => (v == null || v.length < 8)
                          ? 'Pelo menos 8 caracteres.'
                          : null,
                    ),
                    if (session.error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        session.error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: session.isLoading ? null : _submit,
                      child: session.isLoading
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_creating ? 'Criar conta' : 'Entrar'),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _creating = !_creating),
                      child: Text(
                        _creating
                            ? 'Já tenho conta. Entrar'
                            : 'Ainda não tenho conta. Criar conta',
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
