import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class ApplicationDetailScreen extends StatefulWidget {
  final Map<String, dynamic> application;

  const ApplicationDetailScreen({super.key, required this.application});

  @override
  State<ApplicationDetailScreen> createState() =>
      _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState extends State<ApplicationDetailScreen> {
  bool _isEditing = false;
  late TextEditingController _companyCtrl;
  late TextEditingController _roleCtrl;
  late TextEditingController _locationCtrl;
  late TextEditingController _notesCtrl;
  late TextEditingController _jobLinkCtrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _companyCtrl = TextEditingController(text: widget.application['company']);
    _roleCtrl = TextEditingController(text: widget.application['role']);
    _locationCtrl = TextEditingController(
      text: widget.application['location'] ?? '',
    );
    _notesCtrl = TextEditingController(text: widget.application['notes'] ?? '');
    _jobLinkCtrl = TextEditingController(
      text: widget.application['jobLink'] ?? '',
    );
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    final appState = Provider.of<AppState>(context, listen: false);

    await appState.updateApplication(widget.application['id'], {
      'company': _companyCtrl.text.trim(),
      'role': _roleCtrl.text.trim(),
      'location': _locationCtrl.text.trim(),
      'notes': _notesCtrl.text.trim(),
      'jobLink': _jobLinkCtrl.text.trim(),
    });

    if (mounted) {
      setState(() {
        _isSaving = false;
        _isEditing = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Application updated!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Application' : 'Preview'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildField('Company', _companyCtrl, Icons.business),
            const SizedBox(height: 16),
            _buildField('Role', _roleCtrl, Icons.work_outline),
            const SizedBox(height: 16),
            _buildField('Location', _locationCtrl, Icons.location_on_outlined),
            const SizedBox(height: 16),
            _buildField('Job Link', _jobLinkCtrl, Icons.link),
            const SizedBox(height: 16),
            _buildField('Notes', _notesCtrl, Icons.notes, maxLines: 4),

            const SizedBox(height: 40),
            if (_isEditing)
              _isSaving
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      enabled: _isEditing,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: maxLines == 1 ? Icon(icon) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: _isEditing
            ? Theme.of(context).colorScheme.surface
            : Colors.grey.withOpacity(0.1),
      ),
    );
  }
}
