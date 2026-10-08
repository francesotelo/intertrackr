import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';

class ResumePreviewScreen extends StatelessWidget {
  final String resumeUrl; // In a real app, this is the Firebase/Cloudinary URL
  final String resumeName;

  const ResumePreviewScreen({
    super.key,
    required this.resumeUrl,
    required this.resumeName,
  });

  Future<void> _launchExternalUrl() async {
    final Uri url = Uri.parse(resumeUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $resumeUrl');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPdf = resumeName.toLowerCase().endsWith('.pdf');

    return Scaffold(
      appBar: AppBar(
        title: Text(resumeName, style: const TextStyle(fontSize: 16)),
        backgroundColor: const Color(0xFF673AB7),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            tooltip: 'Open Externally',
            onPressed: _launchExternalUrl,
          ),
        ],
      ),
      body: isPdf
          ? SfPdfViewer.network(
              resumeUrl,
              canShowScrollHead: false,
              canShowScrollStatus: false,
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.description, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Preview not supported for non-PDF files.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _launchExternalUrl,
                    icon: const Icon(Icons.download),
                    label: const Text('Download / Open File'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
