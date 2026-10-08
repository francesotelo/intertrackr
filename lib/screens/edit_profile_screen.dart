import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/app_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _bioCtrl;
  late TextEditingController _courseCtrl;
  late TextEditingController _uniCtrl;
  late TextEditingController _yearCtrl;
  late TextEditingController _skillsCtrl;
  late TextEditingController _linkedInCtrl;
  late TextEditingController _githubCtrl;
  late TextEditingController _portfolioCtrl;

  File? _profileImage;
  String? _resumeFileName;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<AppState>(context, listen: false).userProfile;
    _nameCtrl = TextEditingController(text: profile['name'] ?? '');
    _bioCtrl = TextEditingController(text: profile['bio'] ?? '');
    _courseCtrl = TextEditingController(text: profile['course'] ?? '');
    _uniCtrl = TextEditingController(text: profile['university'] ?? '');
    _yearCtrl = TextEditingController(text: profile['yearLevel'] ?? '');
    _skillsCtrl = TextEditingController(text: profile['skills'] ?? '');
    _linkedInCtrl = TextEditingController(text: profile['linkedin'] ?? '');
    _githubCtrl = TextEditingController(text: profile['github'] ?? '');
    _portfolioCtrl = TextEditingController(text: profile['portfolio'] ?? '');
    _resumeFileName = profile['resumeName'];
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (pickedFile != null) {
      setState(() => _profileImage = File(pickedFile.path));
    }
  }

  Future<void> _pickResume() async {
    // In file_picker 13.x, pickFiles() returns a non-nullable List<PlatformFile>
    // (empty when the user cancels), so only the isEmpty check is needed.
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (result.isNotEmpty) {
      setState(() => _resumeFileName = result.first.name);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    final appState = Provider.of<AppState>(context, listen: false);
    final profile = appState.userProfile;

    String? base64Image;
    if (_profileImage != null) {
      final bytes = await _profileImage!.readAsBytes();
      base64Image = base64Encode(bytes);
    }

    await appState.updateProfileData({
      'name': _nameCtrl.text.trim(),
      'bio': _bioCtrl.text.trim(),
      'course': _courseCtrl.text.trim(),
      'university': _uniCtrl.text.trim(),
      'yearLevel': _yearCtrl.text.trim(),
      'skills': _skillsCtrl.text.trim(),
      'linkedin': _linkedInCtrl.text.trim(),
      'github': _githubCtrl.text.trim(),
      'portfolio': _portfolioCtrl.text.trim(),
      'resumeName': _resumeFileName,
      'profileImage': base64Image ?? profile['profileImage'],
    });

    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<AppState>(context).userProfile;
    ImageProvider? imageProvider;
    if (_profileImage != null) {
      imageProvider = FileImage(_profileImage!);
    } else if (profile['profileImage'] != null &&
        profile['profileImage'].isNotEmpty) {
      try {
        imageProvider = MemoryImage(base64Decode(profile['profileImage']));
      } catch (e) {
        // Fallback if decode fails
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFF673AB7).withValues(alpha: 0.1),
                backgroundImage: imageProvider,
                child: imageProvider == null
                    ? const Icon(
                        Icons.camera_alt,
                        size: 30,
                        color: Color(0xFF673AB7),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap to change picture',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 32),
            _buildField('Full Name', _nameCtrl),
            _buildField('Bio', _bioCtrl, maxLines: 3),
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.description, color: Color(0xFFE91E63)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      _resumeFileName ?? 'No resume uploaded yet.',
                      style: TextStyle(
                        color: _resumeFileName == null
                            ? Colors.grey
                            : Colors.black87,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _pickResume,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.black87,
                      elevation: 0,
                    ),
                    child: const Text('Upload'),
                  ),
                ],
              ),
            ),
            _buildField('Course / Degree', _courseCtrl),
            Row(
              children: [
                Expanded(child: _buildField('University', _uniCtrl)),
                const SizedBox(width: 16),
                Expanded(child: _buildField('Year Level', _yearCtrl)),
              ],
            ),
            _buildField('Skills (comma separated)', _skillsCtrl),
            _buildField('LinkedIn Profile', _linkedInCtrl),
            _buildField('GitHub Profile', _githubCtrl),
            _buildField('Website / Portfolio', _portfolioCtrl),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Save Profile',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
      ),
    );
  }
}
