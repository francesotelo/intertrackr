import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'application_detail_screen.dart';

class StatusListScreen extends StatefulWidget {
  final String status;
  final Color themeColor;

  const StatusListScreen({
    super.key,
    required this.status,
    required this.themeColor,
  });

  @override
  State<StatusListScreen> createState() => _StatusListScreenState();
}

class _StatusListScreenState extends State<StatusListScreen> {
  bool _newestFirst = true;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    // 1. Filter by Status
    var filteredApps = widget.status == 'Total Apps'
        ? List.from(appState.applications)
        : appState.applications
              .where((a) => a['status'] == widget.status)
              .toList();

    // 2. Sort by Date (createdAt)
    filteredApps.sort((a, b) {
      final dateA = DateTime.tryParse(a['createdAt'] ?? '') ?? DateTime.now();
      final dateB = DateTime.tryParse(b['createdAt'] ?? '') ?? DateTime.now();
      return _newestFirst ? dateB.compareTo(dateA) : dateA.compareTo(dateB);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.status} (${filteredApps.length})'),
        backgroundColor: widget.themeColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              _newestFirst ? Icons.arrow_downward : Icons.arrow_upward,
            ),
            tooltip: 'Sort by Date',
            onPressed: () => setState(() => _newestFirst = !_newestFirst),
          ),
        ],
      ),
      body: filteredApps.isEmpty
          ? const Center(child: Text('No applications in this stage yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredApps.length,
              itemBuilder: (context, index) {
                final app = filteredApps[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    onTap: () {
                      // Open the Preview Screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ApplicationDetailScreen(application: app),
                        ),
                      );
                    },
                    leading: CircleAvatar(
                      backgroundColor: widget.themeColor.withOpacity(0.2),
                      child: Icon(Icons.business, color: widget.themeColor),
                    ),
                    title: Text(
                      app['company'] ?? 'Company',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(app['role'] ?? 'Role'),

                    // INLINE DROPDOWN to change status directly from the folder
                    trailing: PopupMenuButton<String>(
                      icon: const Icon(Icons.swap_horiz, color: Colors.grey),
                      tooltip: 'Change Status',
                      onSelected: (newStatus) {
                        appState.updateApplication(app['id'], {
                          'status': newStatus,
                        });
                      },
                      itemBuilder: (context) =>
                          [
                                'Wishlist',
                                'Applied',
                                'Interview',
                                'Offer',
                                'Rejected',
                              ]
                              .map(
                                (s) => PopupMenuItem(
                                  value: s,
                                  child: Text(
                                    s,
                                    style: TextStyle(
                                      fontWeight: app['status'] == s
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: app['status'] == s
                                          ? widget.themeColor
                                          : null,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
