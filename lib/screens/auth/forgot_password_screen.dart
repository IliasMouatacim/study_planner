// lib/screens/auth/forgot_password_screen.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:email_validator/email_validator.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_app_bar.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendPasswordResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.sendPasswordResetEmail(_emailController.text.trim());
      
      if (mounted) {
        setState(() => _emailSent = true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Import CustomAppBar
    // ignore: unused_import
    return Scaffold(
      extendBody: true,
      appBar: const CustomAppBar(
        title: 'Mot de passe oublié',
        showBack: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.07),
              Theme.of(context).colorScheme.secondary.withOpacity(0.04),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
                child: _emailSent ? _buildSuccessView() : _buildFormView(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Icon
          Icon(
            FontAwesomeIcons.envelopeCircleCheck,
            size: 64,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 32),
          
          // Title
          Text(
            'Réinitialiser votre mot de passe',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Description
          Text(
            'Entrez votre adresse email et nous vous enverrons un lien pour réinitialiser votre mot de passe.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          
          // Email field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'votre@email.com',
              prefixIcon: const Icon(FontAwesomeIcons.envelope),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre email';
              }
              if (!EmailValidator.validate(value)) {
                return 'Email invalide';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          
          // Submit button
          ElevatedButton(
            onPressed: _isLoading ? null : _sendPasswordResetEmail,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Envoyer le lien',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Success icon
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            FontAwesomeIcons.circleCheck,
            size: 64,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 32),
        
        // Success title
        Text(
          'Email envoyé !',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Success message
        Text(
          'Nous avons envoyé un lien de réinitialisation à ${_emailController.text.trim()}',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Vérifiez votre boîte de réception et cliquez sur le lien pour réinitialiser votre mot de passe.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 32),
        
        // Return button
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Retour à la connexion',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Resend button
        TextButton(
          onPressed: () {
            setState(() => _emailSent = false);
          },
          child: const Text('Renvoyer l\'email'),
        ),
      ],
    );
  }
}