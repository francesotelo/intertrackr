import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../services/api_service.dart';

class AddApplicationScreen extends StatefulWidget {
  const AddApplicationScreen({super.key});

  @override
  State<AddApplicationScreen> createState() => _AddApplicationScreenState();
}

class _AddApplicationScreenState extends State<AddApplicationScreen> {
  // Form Controllers
  final _companyController = TextEditingController();
  final _roleController = TextEditingController();
  final _locationController = TextEditingController();
  final _jobLinkController = TextEditingController();
  final _notesController = TextEditingController();

  // State Variables
  String _selectedStatus = 'Wishlist';
  DateTime? _dateApplied;
  DateTime? _deadline;
  bool _isLoading = false;

  final List<String> _statusOptions = [
    'Wishlist',
    'Applied',
    'Interview',
    'Offer',
    'Rejected',
  ];

  Future<void> _selectDate(BuildContext context, bool isDateApplied) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isDateApplied) {
          _dateApplied = picked;
        } else {
          _deadline = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (_companyController.text.trim().isEmpty ||
        _roleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Company and Role are required')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final token = Provider.of<AppState>(context, listen: false).token;
      if (token == null) return;

      // Compile data matching your Express API structure
      final payload = {
        'company': _companyController.text.trim(),
        'role': _roleController.text.trim(),
        'location': _locationController.text.trim(),
        'status': _selectedStatus,
        'jobLink': _jobLinkController.text.trim(),
        'dateApplied': _dateApplied?.toIso8601String(),
        'deadline': _deadline?.toIso8601String(),
        'notes': _notesController.text.trim(),
      };

      await ApiService.addApplication(token, payload);

      if (mounted) {
        Provider.of<AppState>(context, listen: false).loadApplications();
        Navigator.pop(context); // Close the modal
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add application')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    final fieldBgColor = isDark
        ? Colors.grey.shade800
        : const Color(0xFFF3F4F6);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Hides default back arrow
        title: Text(
          'Add Application',
          style: TextStyle(
            color: textColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: Colors.grey.shade600),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Row 1: Company & Role
            Row(
              children: [
                Expanded(
                  child: _buildLabeledInput(
                    'COMPANY *',
                    'e.g. Google',
                    _companyController,
                    fieldBgColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildLabeledInput(
                    'ROLE *',
                    'e.g. SWE Intern',
                    _roleController,
                    fieldBgColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Row 2: Location & Status
            Row(
              children: [
                Expanded(
                  child: _buildLabeledInput(
                    'LOCATION',
                    'e.g. Remote, NYC',
                    _locationController,
                    fieldBgColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildLabeledWrapper(
                    'STATUS',
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: fieldBgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedStatus,
                          isExpanded: true,
                          dropdownColor: Theme.of(context).colorScheme.surface,
                          items: _statusOptions.map((String status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null)
                              setState(() => _selectedStatus = newValue);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Row 3: Job Link
            _buildLabeledInput(
              'JOB LINK',
              'https://...',
              _jobLinkController,
              fieldBgColor,
            ),
            const SizedBox(height: 20),

            // Row 4: Dates
            Row(
              children: [
                Expanded(
                  child: _buildDatePicker(
                    'DATE APPLIED',
                    _dateApplied,
                    () => _selectDate(context, true),
                    fieldBgColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDatePicker(
                    'DEADLINE',
                    _deadline,
                    () => _selectDate(context, false),
                    fieldBgColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Row 5: Notes
            _buildLabeledWrapper(
              'NOTES',
              TextField(
                controller: _notesController,
                maxLines: 4,
                decoration: _getCustomDecoration(
                  'Referral, interview tips, etc.',
                  fieldBgColor,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Submission Button
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB), // Vibrant Blue
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Add Application',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- UI Helper Methods ---

  Widget _buildLabeledWrapper(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildLabeledInput(
    String label,
    String hint,
    TextEditingController controller,
    Color bgColor,
  ) {
    return _buildLabeledWrapper(
      label,
      TextField(
        controller: controller,
        decoration: _getCustomDecoration(hint, bgColor),
      ),
    );
  }

  Widget _buildDatePicker(
    String label,
    DateTime? date,
    VoidCallback onTap,
    Color bgColor,
  ) {
    final displayDate = date == null
        ? 'mm/dd/yyyy'
        : DateFormat('MM/dd/yyyy').format(date);
    return _buildLabeledWrapper(
      label,
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                displayDate,
                style: TextStyle(
                  color: date == null ? Colors.grey.shade500 : null,
                  fontSize: 16,
                ),
              ),
              Icon(
                Icons.calendar_today_outlined,
                size: 20,
                color: Colors.grey.shade600,
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _getCustomDecoration(String hint, Color bgColor) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
      filled: true,
      fillColor: bgColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
      ),
    );
  }
}
