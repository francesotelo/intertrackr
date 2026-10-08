import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../providers/app_state.dart';
import 'status_list_screen.dart';
import 'application_detail_screen.dart';
import 'edit_profile_screen.dart';
import 'resume_preview_screen.dart';
import 'settings_screen.dart'; // NEW
import 'help_support_screen.dart'; // NEW

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  Map<String, dynamic>? _selectedMapApp;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppState>(context, listen: false).loadApplications();
    });
  }

  int _countStatus(List apps, String status) {
    return apps.where((a) => a['status'] == status).length;
  }

  void _showStatusUpdateSheet(
    BuildContext context,
    AppState appState,
    dynamic app,
  ) {
    final statuses = ['Wishlist', 'Applied', 'Interview', 'Offer', 'Rejected'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Update Status for ${app['company']}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...statuses.map(
                  (status) => ListTile(
                    title: Text(status),
                    trailing: app['status'] == status
                        ? const Icon(Icons.check, color: Color(0xFF673AB7))
                        : null,
                    onTap: () {
                      appState.updateApplication(app['id'], {'status': status});
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserAvatar(
    AppState appState, {
    double radius = 20,
    double fontSize = 16,
  }) {
    final profile = appState.userProfile;
    final String initial = appState.userName.isNotEmpty
        ? appState.userName[0].toUpperCase()
        : 'M';
    final String? imageStr = profile['profileImage'];

    if (imageStr != null && imageStr.isNotEmpty) {
      try {
        if (imageStr.startsWith('http')) {
          return CircleAvatar(
            radius: radius,
            backgroundImage: NetworkImage(imageStr),
          );
        } else {
          Uint8List bytes = base64Decode(imageStr);
          return CircleAvatar(
            radius: radius,
            backgroundImage: MemoryImage(bytes),
          );
        }
      } catch (e) {
        // Fallback
      }
    }

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF673AB7), Color(0xFFFFB300)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isDark = appState.isDarkMode;
    final textColor = isDark ? Colors.white : Colors.black87;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            // THE UPDATED DROPDOWN MENU
            child: PopupMenuButton<String>(
              offset: const Offset(0, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: _buildUserAvatar(appState, radius: 18, fontSize: 16),
              onSelected: (value) {
                if (value == 'theme') appState.toggleTheme();
                if (value == 'settings') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                }
                if (value == 'help') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HelpSupportScreen(),
                    ),
                  );
                }
                if (value == 'logout') {
                  appState.logout();
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  enabled: false,
                  child: Text(
                    appState.userName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      fontSize: 16,
                    ),
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'theme',
                  child: ListTile(
                    leading: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                    title: Text(isDark ? 'Light Mode' : 'Dark Mode'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'settings',
                  child: ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('Settings'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'help',
                  child: ListTile(
                    leading: Icon(Icons.help_outline),
                    title: Text('Help & Support'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'logout',
                  child: ListTile(
                    leading: Icon(Icons.logout, color: Colors.red),
                    title: Text('Logout', style: TextStyle(color: Colors.red)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _buildBody(_currentIndex, appState, textColor),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFE91E63),
        elevation: 4,
        onPressed: () => Navigator.pushNamed(context, '/add_application'),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildBody(int index, AppState appState, Color textColor) {
    switch (index) {
      case 0:
        return _buildDashboardBody(appState, textColor);
      case 1:
        return _buildAnalyticsBody(appState, textColor);
      case 2:
        return _buildMapBody(appState);
      case 3:
        return _buildProfileBody(appState, textColor);
      default:
        return _buildDashboardBody(appState, textColor);
    }
  }

  // --- DASHBOARD TAB ---
  Widget _buildDashboardBody(AppState appState, Color textColor) {
    return RefreshIndicator(
      onRefresh: appState.loadApplications,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('Hello!', style: TextStyle(fontSize: 28, color: textColor)),
            Text(
              appState.userName,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Let's manage your applications.",
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),

            const SizedBox(height: 24),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _buildGridCard(
                  'Wishlist',
                  _countStatus(appState.applications, 'Wishlist').toString(),
                  const Color(0xFF673AB7),
                  Icons.bookmark_border,
                ),
                _buildGridCard(
                  'Applied',
                  _countStatus(appState.applications, 'Applied').toString(),
                  const Color(0xFFFFB300),
                  Icons.send_outlined,
                ),
                _buildGridCard(
                  'Interviews',
                  _countStatus(appState.applications, 'Interview').toString(),
                  const Color(0xFF03A9F4),
                  Icons.calendar_today,
                ),
                _buildGridCard(
                  'Offers',
                  _countStatus(appState.applications, 'Offer').toString(),
                  const Color(0xFFE91E63),
                  Icons.check_circle_outline,
                ),
                _buildGridCard(
                  'Rejected',
                  _countStatus(appState.applications, 'Rejected').toString(),
                  Colors.redAccent,
                  Icons.cancel_outlined,
                ),
                _buildGridCard(
                  'Total Apps',
                  appState.applications.length.toString(),
                  Colors.blueGrey,
                  Icons.folder_outlined,
                ),
              ],
            ),
            const SizedBox(height: 32),

            Text(
              'Activity Logs',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),

            appState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : appState.applications.isEmpty
                ? const Text("No activity logged yet.")
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: appState.applications.length > 5
                        ? 5
                        : appState.applications.length,
                    itemBuilder: (context, index) {
                      var sortedApps = List.from(appState.applications);
                      sortedApps.sort(
                        (a, b) => (b['createdAt'] ?? '').compareTo(
                          a['createdAt'] ?? '',
                        ),
                      );
                      final app = sortedApps[index];

                      final dateString = app['createdAt'] != null
                          ? "${DateTime.parse(app['createdAt']).month}/${DateTime.parse(app['createdAt']).day}/${DateTime.parse(app['createdAt']).year}"
                          : "Recently";

                      String actionText = '';
                      if (app['status'] == 'Wishlist')
                        actionText = 'Saved to Wishlist: ';
                      else if (app['status'] == 'Applied')
                        actionText = 'Submitted application for ';
                      else if (app['status'] == 'Interview')
                        actionText = 'Interviewing for ';
                      else if (app['status'] == 'Offer')
                        actionText = 'Received an offer for ';
                      else if (app['status'] == 'Rejected')
                        actionText = 'Rejected for ';
                      else
                        actionText = 'Tracked ';

                      return GestureDetector(
                        onTap: () =>
                            _showStatusUpdateSheet(context, appState, app),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: const Color(
                                  0xFF673AB7,
                                ).withOpacity(0.1),
                                child: const Icon(
                                  Icons.history,
                                  size: 16,
                                  color: Color(0xFF673AB7),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text.rich(
                                      TextSpan(
                                        text: actionText,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 13,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: '${app['role']}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: textColor,
                                            ),
                                          ),
                                          const TextSpan(text: ' at '),
                                          TextSpan(
                                            text: '${app['company']}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: textColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      dateString,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCard(
    String title,
    String count,
    Color color,
    IconData icon,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  StatusListScreen(status: title, themeColor: color),
            ),
          );
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: Colors.white, size: 32),
                  const Icon(Icons.more_vert, color: Colors.white70),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    count,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- ANALYTICS TAB ---
  Widget _buildAnalyticsBody(AppState appState, Color textColor) {
    final total = appState.applications.length;
    final wishlist = _countStatus(appState.applications, 'Wishlist');
    final applied = _countStatus(appState.applications, 'Applied');
    final interviews = _countStatus(appState.applications, 'Interview');
    final offers = _countStatus(appState.applications, 'Offer');
    final rejected = _countStatus(appState.applications, 'Rejected');

    final responseRate = total == 0
        ? 0.0
        : ((interviews + offers + rejected) / total) * 100;
    final interviewRate = total == 0 ? 0.0 : (interviews / total) * 100;
    final offerRate = total == 0 ? 0.0 : (offers / total) * 100;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Application Report',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Total Apps',
                  total.toString(),
                  Icons.folder,
                  const Color(0xFF673AB7),
                  Theme.of(context).colorScheme.surface,
                  textColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Response Rate',
                  '${responseRate.toStringAsFixed(1)}%',
                  Icons.feedback,
                  const Color(0xFFFFB300),
                  Theme.of(context).colorScheme.surface,
                  textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Interview Rate',
                  '${interviewRate.toStringAsFixed(1)}%',
                  Icons.calendar_today,
                  const Color(0xFF03A9F4),
                  Theme.of(context).colorScheme.surface,
                  textColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Offer Rate',
                  '${offerRate.toStringAsFixed(1)}%',
                  Icons.check_circle,
                  const Color(0xFFE91E63),
                  Theme.of(context).colorScheme.surface,
                  textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Text(
            'Application Distribution',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SizedBox(
              height: 220,
              child: total == 0
                  ? Center(
                      child: Text(
                        "Not enough data to graph.",
                        style: TextStyle(color: textColor),
                      ),
                    )
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              total.toString(),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                        PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 65,
                            sections: [
                              if (wishlist > 0)
                                PieChartSectionData(
                                  color: const Color(0xFF673AB7),
                                  value: wishlist.toDouble(),
                                  showTitle: false,
                                  radius: 25,
                                ),
                              if (applied > 0)
                                PieChartSectionData(
                                  color: const Color(0xFFFFB300),
                                  value: applied.toDouble(),
                                  showTitle: false,
                                  radius: 25,
                                ),
                              if (interviews > 0)
                                PieChartSectionData(
                                  color: const Color(0xFF03A9F4),
                                  value: interviews.toDouble(),
                                  showTitle: false,
                                  radius: 25,
                                ),
                              if (offers > 0)
                                PieChartSectionData(
                                  color: const Color(0xFFE91E63),
                                  value: offers.toDouble(),
                                  showTitle: false,
                                  radius: 25,
                                ),
                              if (rejected > 0)
                                PieChartSectionData(
                                  color: Colors.redAccent,
                                  value: rejected.toDouble(),
                                  showTitle: false,
                                  radius: 25,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Pipeline Drop-off',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                _buildStageProgress(
                  'Wishlist',
                  wishlist,
                  total,
                  const Color(0xFF673AB7),
                  textColor,
                ),
                _buildStageProgress(
                  'Applied',
                  applied,
                  total,
                  const Color(0xFFFFB300),
                  textColor,
                ),
                _buildStageProgress(
                  'Interviewing',
                  interviews,
                  total,
                  const Color(0xFF03A9F4),
                  textColor,
                ),
                _buildStageProgress(
                  'Offers',
                  offers,
                  total,
                  const Color(0xFFE91E63),
                  textColor,
                ),
                _buildStageProgress(
                  'Rejected',
                  rejected,
                  total,
                  Colors.redAccent,
                  textColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color iconColor,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildStageProgress(
    String title,
    int count,
    int total,
    Color color,
    Color textColor,
  ) {
    double percentage = total == 0 ? 0.0 : count / total;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
              ),
              Text(
                '$count (${(percentage * 100).toStringAsFixed(1)}%)',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: color.withOpacity(0.1),
            color: color,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  // --- MAP TAB ---
  Widget _buildMapBody(AppState appState) {
    final dummyApp = {
      'id': 'demo-pin',
      'company': 'Sample Tech Co.',
      'role': 'Mobile Developer',
      'location': 'Sampaloc, Manila',
      'status': 'Interview',
    };

    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: const LatLng(14.5995, 120.9842),
            initialZoom: 12.0,
            onTap: (tapPosition, point) {
              if (_selectedMapApp != null)
                setState(() => _selectedMapApp = null);
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.interntrackr.app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: const LatLng(14.6042, 120.9822),
                  width: 50,
                  height: 50,
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedMapApp = dummyApp),
                    child: const Icon(
                      Icons.location_on,
                      color: Color(0xFFE91E63),
                      size: 45,
                    ),
                  ),
                ),
                ...appState.applications
                    .where((app) => app['lat'] != null && app['lng'] != null)
                    .map((app) {
                      final isSelected =
                          _selectedMapApp != null &&
                          _selectedMapApp!['id'] == app['id'];
                      return Marker(
                        point: LatLng(app['lat'], app['lng']),
                        width: isSelected ? 60 : 40,
                        height: isSelected ? 60 : 40,
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedMapApp = app),
                          child: Icon(
                            Icons.location_on,
                            color: isSelected
                                ? const Color(0xFFE91E63)
                                : const Color(0xFF673AB7),
                            size: isSelected ? 50 : 40,
                          ),
                        ),
                      );
                    }),
              ],
            ),
          ],
        ),
        if (_selectedMapApp != null)
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ApplicationDetailScreen(application: _selectedMapApp!),
                  ),
                );
              },
              child: Card(
                elevation: 12,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(
                          0xFF673AB7,
                        ).withOpacity(0.1),
                        radius: 24,
                        child: const Icon(
                          Icons.business,
                          color: Color(0xFF673AB7),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _selectedMapApp!['company'] ?? 'Company',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_selectedMapApp!['role']} • ${_selectedMapApp!['location'] ?? 'Remote'}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFF673AB7),
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // --- PROFILE TAB ---
  Widget _buildProfileBody(AppState appState, Color textColor) {
    final profile = appState.userProfile;
    final String email = profile['email'] ?? 'Configured in Web App';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Header Card
          _buildProfileCard(
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  _buildUserAvatar(appState, radius: 35, fontSize: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appState.userName,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        Text(
                          email,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      foregroundColor: textColor,
                      elevation: 0,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Edit Profile'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 2. About Card
          _buildProfileCard(
            _buildSectionLayout(
              'ABOUT',
              profile['bio']?.isNotEmpty == true
                  ? profile['bio']
                  : 'No bio added yet.',
              textColor,
            ),
          ),
          const SizedBox(height: 16),

          // 3. Resume Card
          _buildProfileCard(
            InkWell(
              onTap: () {
                if (profile['resumeName']?.isNotEmpty == true) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResumePreviewScreen(
                        resumeName: profile['resumeName'],
                        resumeUrl:
                            'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No resume to preview.')),
                  );
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'RESUME',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                            letterSpacing: 1.2,
                          ),
                        ),
                        if (profile['resumeName']?.isNotEmpty == true)
                          const Icon(
                            Icons.visibility,
                            size: 16,
                            color: Color(0xFF673AB7),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      profile['resumeName']?.isNotEmpty == true
                          ? profile['resumeName']
                          : 'No resume uploaded yet.',
                      style: TextStyle(
                        fontSize: 15,
                        color: profile['resumeName']?.isNotEmpty == true
                            ? const Color(0xFF2563EB)
                            : Colors.grey.shade500,
                        fontStyle: profile['resumeName']?.isNotEmpty == true
                            ? FontStyle.normal
                            : FontStyle.italic,
                        decoration: profile['resumeName']?.isNotEmpty == true
                            ? TextDecoration.underline
                            : TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 4. Academic Info Card
          _buildProfileCard(
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ACADEMIC INFO',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildInfoUnit(
                          'Full Name',
                          appState.userName,
                          textColor,
                        ),
                      ),
                      Expanded(
                        child: _buildInfoUnit(
                          'Course / Degree',
                          profile['course']?.isNotEmpty == true
                              ? profile['course']
                              : '—',
                          textColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildInfoUnit(
                          'University',
                          profile['university']?.isNotEmpty == true
                              ? profile['university']
                              : '—',
                          textColor,
                        ),
                      ),
                      Expanded(
                        child: _buildInfoUnit(
                          'Year Level',
                          profile['yearLevel']?.isNotEmpty == true
                              ? profile['yearLevel']
                              : '—',
                          textColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 5. Skills Card
          _buildProfileCard(
            _buildSectionLayout(
              'SKILLS',
              profile['skills']?.isNotEmpty == true
                  ? profile['skills']
                  : 'No skills added yet.',
              textColor,
            ),
          ),
          const SizedBox(height: 16),

          // 6. Links Card
          _buildProfileCard(
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LINKS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildLinkUnit(
                    Icons.business_center,
                    profile['linkedin'],
                    textColor,
                  ),
                  const SizedBox(height: 12),
                  _buildLinkUnit(Icons.code, profile['github'], textColor),
                  const SizedBox(height: 12),
                  _buildLinkUnit(
                    Icons.language,
                    profile['portfolio'],
                    textColor,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 7. Account Info Card
          _buildProfileCard(
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ACCOUNT INFO',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Member Since',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      Text('October 2026', style: TextStyle(color: textColor)),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Email',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      Text(email, style: TextStyle(color: textColor)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildProfileCard(Widget child) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Theme.of(context).colorScheme.surface,
      child: child,
    );
  }

  Widget _buildSectionLayout(String title, String content, Color textColor) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              color: content.contains('yet') ? Colors.grey.shade500 : textColor,
              fontStyle: content.contains('yet')
                  ? FontStyle.italic
                  : FontStyle.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoUnit(String label, String value, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 15, color: textColor)),
      ],
    );
  }

  Widget _buildLinkUnit(IconData icon, String? value, Color textColor) {
    final bool hasValue = value != null && value.isNotEmpty;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: Colors.grey.shade600),
        ),
        const SizedBox(width: 12),
        Text(
          hasValue ? value : 'Not added',
          style: TextStyle(
            color: hasValue ? textColor : Colors.grey.shade500,
            fontStyle: hasValue ? FontStyle.normal : FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
