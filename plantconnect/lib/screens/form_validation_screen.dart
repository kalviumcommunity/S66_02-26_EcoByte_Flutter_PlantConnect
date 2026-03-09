import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Module 3.44 — Building and Validating Complex Forms with Input Checks
///
/// Demonstrates:
///   - Form + GlobalKey<FormState>
///   - Required, email, password, phone, confirm-password validators
///   - Cross-field validation (password ↔ confirm)
///   - Real-time field validation (autovalidateMode)
///   - Submit button disabled until form is valid
///   - Input formatters (phone number digits only)
///   - Success screen after valid submit
class FormValidationScreen extends StatefulWidget {
  const FormValidationScreen({super.key});

  @override
  State<FormValidationScreen> createState() => _FormValidationScreenState();
}

class _FormValidationScreenState extends State<FormValidationScreen> {
  // ─── Form key — the bridge between Form and its state ─────────────────────
  final _formKey = GlobalKey<FormState>();

  // ─── Controllers ──────────────────────────────────────────────────────────
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _bioController = TextEditingController();

  // ─── State ────────────────────────────────────────────────────────────────
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _submitted = false;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  // ─── VALIDATORS ───────────────────────────────────────────────────────────

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    final phoneRegex = RegExp(r'^[0-9]{10}$');
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Must contain at least one uppercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Must contain at least one number';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    // Cross-field validation — compare against the password field
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? _validateBio(String? value) {
    if (value != null && value.length > 200) {
      return 'Bio must be under 200 characters';
    }
    return null;
  }

  // ─── SUBMIT ───────────────────────────────────────────────────────────────
  Future<void> _submitForm() async {
    // Validate all fields — shows all errors at once
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please agree to the Terms & Conditions'),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Simulate network save (1.5 s)
    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _submitted = true;
      });
    }
  }

  // ─── RESET ────────────────────────────────────────────────────────────────
  void _resetForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _bioController.clear();
    setState(() {
      _submitted = false;
      _agreedToTerms = false;
    });
  }

  // ─── BUILD ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Validation'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: _submitted ? _buildSuccessView() : _buildForm(),
    );
  }

  // ─── Success screen ───────────────────────────────────────────────────────
  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.green[50],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle, size: 60, color: Colors.green[600]),
            ),
            const SizedBox(height: 24),
            Text(
              'Form Submitted!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'All fields passed validation.\nWelcome, ${_nameController.text}! 👋',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5),
            ),
            const SizedBox(height: 12),
            _InfoRow(label: 'Email', value: _emailController.text),
            _InfoRow(label: 'Phone', value: _phoneController.text),
            if (_bioController.text.isNotEmpty)
              _InfoRow(label: 'Bio', value: _bioController.text),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _resetForm,
              icon: const Icon(Icons.refresh),
              label: const Text('Fill Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Form ─────────────────────────────────────────────────────────────────
  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        // autovalidateMode: validates each field as the user types (after first interaction)
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ───────────────────────────────────────────────────
            _SectionHeader(
              icon: Icons.person_add_outlined,
              title: 'Create Plant Profile',
              subtitle: 'All fields with * are required',
            ),
            const SizedBox(height: 20),

            // ─────────────────────────────────────────────────────────────
            // SECTION 1: Personal Details
            // ─────────────────────────────────────────────────────────────
            _SectionLabel('Personal Details'),
            const SizedBox(height: 12),

            // Full Name
            TextFormField(
              controller: _nameController,
              validator: _validateName,
              textCapitalization: TextCapitalization.words,
              decoration: _inputDecoration(
                label: 'Full Name *',
                hint: 'e.g. Jane Doe',
                icon: Icons.badge_outlined,
              ),
            ),
            const SizedBox(height: 16),

            // Email
            TextFormField(
              controller: _emailController,
              validator: _validateEmail,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputDecoration(
                label: 'Email Address *',
                hint: 'e.g. jane@example.com',
                icon: Icons.email_outlined,
              ),
            ),
            const SizedBox(height: 16),

            // Phone — input formatter restricts to digits, max 10
            TextFormField(
              controller: _phoneController,
              validator: _validatePhone,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              decoration: _inputDecoration(
                label: 'Phone Number *',
                hint: '10-digit number',
                icon: Icons.phone_outlined,
              ),
            ),
            const SizedBox(height: 16),

            // Bio (optional, 200 char max)
            TextFormField(
              controller: _bioController,
              validator: _validateBio,
              maxLines: 3,
              maxLength: 200,
              textCapitalization: TextCapitalization.sentences,
              decoration: _inputDecoration(
                label: 'Bio (optional)',
                hint: 'Tell us a little about yourself…',
                icon: Icons.info_outline,
              ),
            ),

            const SizedBox(height: 24),

            // ─────────────────────────────────────────────────────────────
            // SECTION 2: Security
            // ─────────────────────────────────────────────────────────────
            _SectionLabel('Security'),
            const SizedBox(height: 12),

            // Password
            TextFormField(
              controller: _passwordController,
              validator: _validatePassword,
              obscureText: _obscurePassword,
              decoration: _inputDecoration(
                label: 'Password *',
                hint: 'Min 8 chars, 1 uppercase, 1 number',
                icon: Icons.lock_outline,
              ).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Password strength hint
            _PasswordStrengthHints(password: _passwordController.text),
            const SizedBox(height: 16),

            // Confirm Password — cross-field validation
            TextFormField(
              controller: _confirmPasswordController,
              validator: _validateConfirmPassword,
              obscureText: _obscureConfirm,
              decoration: _inputDecoration(
                label: 'Confirm Password *',
                hint: 'Re-enter your password',
                icon: Icons.lock_person_outlined,
              ).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ─────────────────────────────────────────────────────────────
            // Terms checkbox
            // ─────────────────────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _agreedToTerms,
                  onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
                  activeColor: Colors.green[700],
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _agreedToTerms = !_agreedToTerms),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        'I agree to the Terms & Conditions and Privacy Policy',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ─────────────────────────────────────────────────────────────
            // Submit button — shows spinner when loading
            // ─────────────────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.green[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Submit Profile',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ─── Helper: shared InputDecoration ───────────────────────────────────────
  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.green[700]),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.green[700]!, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[700]!, Colors.green[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 36),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              Text(subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: Colors.green[700],
              borderRadius: BorderRadius.circular(2),
            )),
        const SizedBox(width: 8),
        Text(label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.grey[800],
            )),
      ],
    );
  }
}

/// Live password strength hints that update as the user types
class _PasswordStrengthHints extends StatelessWidget {
  final String password;
  const _PasswordStrengthHints({required this.password});

  @override
  Widget build(BuildContext context) {
    final has8 = password.length >= 8;
    final hasUpper = RegExp(r'[A-Z]').hasMatch(password);
    final hasDigit = RegExp(r'[0-9]').hasMatch(password);

    if (password.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HintRow(met: has8, text: 'At least 8 characters'),
          _HintRow(met: hasUpper, text: 'Contains uppercase letter'),
          _HintRow(met: hasDigit, text: 'Contains a number'),
        ],
      ),
    );
  }
}

class _HintRow extends StatelessWidget {
  final bool met;
  final String text;
  const _HintRow({required this.met, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 14,
            color: met ? Colors.green[600] : Colors.grey,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: met ? Colors.green[700] : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.grey)),
          Expanded(
            child: Text(value,
                style: TextStyle(color: Colors.green[800]),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
