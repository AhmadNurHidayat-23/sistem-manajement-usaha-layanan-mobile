import 'package:flutter/material.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/business_name_formatter.dart';
import '../../../models/employee_task_model.dart';
import '../../../services/api_service.dart';
import '../../../widgets/status_badge.dart';

class DetailTugasScreen extends StatefulWidget {
  final EmployeeTaskModel task;

  const DetailTugasScreen({super.key, required this.task});

  @override
  State<DetailTugasScreen> createState() => _DetailTugasScreenState();
}

class _DetailTugasScreenState extends State<DetailTugasScreen> {
  late EmployeeTaskModel _task;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
    _loadTaskDetail();
  }

  Future<void> _loadTaskDetail() async {
    final res = await ApiService.get(ApiEndpoints.employeeTaskDetail(_task.id));
    if (!mounted) return;

    if (res.success && res.data is Map<String, dynamic>) {
      setState(() {
        _task = EmployeeTaskModel.fromJson(res.data as Map<String, dynamic>);
      });
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isUpdating = true);

    final res = await ApiService.patch(
      ApiEndpoints.employeeTaskStatus(_task.id),
      body: {'status': newStatus},
    );

    if (!mounted) return;
    setState(() => _isUpdating = false);

    if (res.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status tugas berhasil diperbarui'), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final durationText = _task.durationFormatted ?? _task.serviceDuration;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Tugas'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadTaskDetail),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadTaskDetail,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Status Saat Ini', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      StatusBadge(status: _task.status, label: _task.statusLabel),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Informasi Pekerjaan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      _buildRow('Pelanggan', _task.customerName),
                      if (_task.customerPhone != null) ...[
                        const Divider(height: 20),
                        _buildRow('Nomor Telepon', _task.customerPhone!),
                      ],
                      const Divider(height: 20),
                      _buildRow('Layanan', _task.serviceName),
                      if (durationText != null && durationText.isNotEmpty) ...[
                        const Divider(height: 20),
                        _buildRow('Durasi', durationText),
                      ],
                      const Divider(height: 20),
                      _buildRow('Tanggal', _task.bookingDate),
                      if (_task.bookingTime != null) ...[
                        const Divider(height: 20),
                        _buildRow('Jam Jadwal', _task.bookingTime!),
                      ],
                      if (_task.branchName != null) ...[
                        const Divider(height: 20),
                        _buildRow('Cabang', BusinessNameFormatter.format(_task.branchName)),
                      ],
                    ],
                  ),
                ),
              ),
              if (_task.notes != null && _task.notes!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Catatan Pelanggan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(_task.notes!, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    if (_isUpdating) return const Center(child: CircularProgressIndicator());

    if (_task.status == 'confirmed') {
      return ElevatedButton.icon(
        icon: const Icon(Icons.play_arrow),
        label: const Text('Mulai Kerjakan'),
        onPressed: () => _updateStatus('in_progress'),
      );
    } else if (_task.status == 'in_progress') {
      return ElevatedButton.icon(
        icon: const Icon(Icons.check),
        label: const Text('Selesaikan Pekerjaan'),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        onPressed: () => _updateStatus('completed'),
      );
    }
    return const SizedBox.shrink();
  }
}
