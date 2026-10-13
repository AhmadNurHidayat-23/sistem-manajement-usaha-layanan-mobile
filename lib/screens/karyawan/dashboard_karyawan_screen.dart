import 'package:flutter/material.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/session_manager.dart';
import '../../models/employee_task_model.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import 'detail_tugas_screen.dart';
import 'profil_karyawan_screen.dart';
import 'widgets/commission_card.dart';
import 'widgets/employee_task_card.dart';
import 'widgets/performance_metric_card.dart';
import 'widgets/shift_info_card.dart';
import 'widgets/shift_schedule_view.dart';

class DashboardKaryawanScreen extends StatefulWidget {
  const DashboardKaryawanScreen({super.key});

  @override
  State<DashboardKaryawanScreen> createState() => _DashboardKaryawanScreenState();
}

class _DashboardKaryawanScreenState extends State<DashboardKaryawanScreen> {
  int _currentIndex = 0;
  UserModel? _user;
  Map<String, dynamic>? _dashboardData;
  List<EmployeeTaskModel> _tasks = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _user = SessionManager.getUser();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final dashFuture = ApiService.get(ApiEndpoints.employeeDashboard);
    final taskFuture = ApiService.get(ApiEndpoints.employeeTasks);
    final results = await Future.wait([dashFuture, taskFuture]);

    if (!mounted) return;

    final dashRes = results[0];
    final tasksRes = results[1];

    if (dashRes.success && dashRes.data is Map<String, dynamic>) {
      _dashboardData = dashRes.data as Map<String, dynamic>;
    }
    if (tasksRes.success && tasksRes.data is List) {
      _tasks = (tasksRes.data as List).map((e) => EmployeeTaskModel.fromJson(e as Map<String, dynamic>)).toList();
    }

    setState(() {
      _isLoading = false;
      if (!dashRes.success && !tasksRes.success) _errorMessage = dashRes.message;
    });
  }

  Widget _buildHomeView() {
    final taskStats = _dashboardData?['task_stats'] as Map<String, dynamic>? ?? {};
    final todayShift = _dashboardData?['today_shift'] as Map<String, dynamic>?;
    final performance = _dashboardData?['performance'] as Map<String, dynamic>?;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShiftInfoCard(user: _user, todayShift: todayShift),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
            else if (_errorMessage != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 8),
                      ElevatedButton(onPressed: _loadData, child: const Text('Coba Lagi')),
                    ],
                  ),
                ),
              )
            else ...[
              CommissionCard(performance: performance),
              const SizedBox(height: 20),
              const Text('Statistik Tugas Hari Ini', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: PerformanceMetricCard(title: 'Jumlah Tugas', value: '${taskStats['total'] ?? 0}', icon: Icons.assignment_outlined, color: AppColors.primary)),
                  const SizedBox(width: 10),
                  Expanded(child: PerformanceMetricCard(title: 'Tugas Menunggu', value: '${taskStats['pending'] ?? 0}', icon: Icons.schedule_outlined, color: Colors.orange.shade800)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: PerformanceMetricCard(title: 'Sedang Dikerjakan', value: '${taskStats['in_progress'] ?? 0}', icon: Icons.engineering_outlined, color: AppColors.accent)),
                  const SizedBox(width: 10),
                  Expanded(child: PerformanceMetricCard(title: 'Tugas Selesai', value: '${taskStats['completed'] ?? 0}', icon: Icons.check_circle_outline, color: Colors.green.shade700)),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Antrian Pekerjaan Saya', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  TextButton(onPressed: () => setState(() => _currentIndex = 1), child: const Text('Lihat Semua')),
                ],
              ),
              const SizedBox(height: 8),
              if (_tasks.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: const Text('Tidak ada antrian pekerjaan saat ini.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _tasks.take(5).length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, index) => EmployeeTaskCard(
                    task: _tasks[index],
                    onTap: () async {
                      final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => DetailTugasScreen(task: _tasks[index])));
                      if (res == true) _loadData();
                    },
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTasksView() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: _tasks.isEmpty
          ? const Center(child: Text('Tidak ada daftar antrian tugas.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _tasks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, index) => EmployeeTaskCard(
                task: _tasks[index],
                onTap: () async {
                  final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => DetailTugasScreen(task: _tasks[index])));
                  if (res == true) _loadData();
                },
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todayShift = _dashboardData?['today_shift'] as Map<String, dynamic>?;
    final upcomingShifts = (_dashboardData?['upcoming_shifts'] as List<dynamic>?) ?? [];

    final pages = [
      _buildHomeView(),
      _buildTasksView(),
      ShiftScheduleView(
        todayShift: todayShift,
        upcomingShifts: upcomingShifts,
        onRefresh: _loadData,
      ),
      const ProfilKaryawanScreen(),
    ];

    final titles = ['SIMAUL Petugas', 'Antrean & Tugas', 'Jadwal Shift', 'Profil Petugas'];

    return Scaffold(
      appBar: AppBar(title: Text(titles[_currentIndex])),
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment_rounded), label: 'Tugas'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month_rounded), label: 'Shift'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person_rounded), label: 'Profil'),
        ],
      ),
    );
  }
}
