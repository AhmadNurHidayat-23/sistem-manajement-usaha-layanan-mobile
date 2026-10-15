import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../models/branch_model.dart';
import '../../../models/service_model.dart';
import '../../../services/api_service.dart';
import 'widgets/booking_promo_selector.dart';
import 'widgets/booking_schedule_picker.dart';
import 'widgets/booking_service_dropdown.dart';
import 'widgets/booking_summary_card.dart';

class BuatBookingScreen extends StatefulWidget {
  final int? initialBranchId;
  final int? initialServiceId;

  const BuatBookingScreen({super.key, this.initialBranchId, this.initialServiceId});

  @override
  State<BuatBookingScreen> createState() => _BuatBookingScreenState();
}

class _BuatBookingScreenState extends State<BuatBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  List<BranchModel> _branches = [];
  List<ServiceModel> _services = [];
  List<Map<String, dynamic>> _promos = [];

  int? _selectedBranchId;
  ServiceModel? _selectedService;
  Map<String, dynamic>? _selectedPromo;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);

  bool _isLoadingBranches = true;
  bool _isLoadingServices = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadBranches();
    _loadPromos();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadBranches() async {
    final res = await ApiService.get(ApiEndpoints.branches);
    if (!mounted) return;
    if (res.success && res.data is List) {
      final list = (res.data as List).map((e) => BranchModel.fromJson(e as Map<String, dynamic>)).toList();
      setState(() {
        _branches = list;
        _isLoadingBranches = false;
        final targetId = (widget.initialBranchId != null && list.any((b) => b.id == widget.initialBranchId))
            ? widget.initialBranchId
            : list.firstOrNull?.id;
        if (targetId != null) {
          _selectedBranchId = targetId;
          _loadBranchServices(targetId);
        }
      });
    } else {
      setState(() => _isLoadingBranches = false);
    }
  }

  Future<void> _loadPromos() async {
    final res = await ApiService.get(ApiEndpoints.customerPromos);
    if (res.success && res.data is List && mounted) {
      setState(() => _promos = (res.data as List).cast<Map<String, dynamic>>());
    }
  }

  Future<void> _loadBranchServices(int branchId) async {
    setState(() {
      _isLoadingServices = true;
      _services = [];
      _selectedService = null;
    });
    final res = await ApiService.get('${ApiEndpoints.services}?branch_id=$branchId');
    if (!mounted) return;
    List<ServiceModel> loaded = [];
    if (res.success && res.data is List) {
      loaded = (res.data as List)
          .map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
          .where((s) => s.serviceType != 'drop_off' && !s.isWeightBased)
          .toList();
    }
    setState(() {
      _services = loaded;
      _isLoadingServices = false;
      _selectedService = (widget.initialServiceId != null)
          ? loaded.where((s) => s.id == widget.initialServiceId).firstOrNull ?? loaded.firstOrNull
          : loaded.firstOrNull;
    });
  }

  Future<void> _submitBooking() async {
    if (_selectedBranchId == null || _selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih cabang dan layanan.')));
      return;
    }
    setState(() => _isSubmitting = true);
    final timeStr = '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

    final body = <String, dynamic>{
      'branch_id': _selectedBranchId,
      'service_id': _selectedService!.id,
      'booking_date': dateStr,
      'booking_time': timeStr,
      'notes': _notesController.text.trim(),
    };
    if (_selectedPromo != null && _selectedPromo!['code'] != null) {
      body['promo_code'] = _selectedPromo!['code'];
    }

    final res = await ApiService.post(ApiEndpoints.customerBookings, body: body);
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (res.success) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Row(children: [Icon(Icons.check_circle, color: Colors.green), SizedBox(width: 8), Text('Booking Berhasil')]),
          content: Text('Booking ${_selectedService!.name} tanggal $dateStr jam $timeStr berhasil dibuat.'),
          actions: [ElevatedButton(onPressed: () { Navigator.pop(ctx); Navigator.pop(context, true); }, child: const Text('OK'))],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.message), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';
    final dateStr = DateFormat('dd/MM/yyyy').format(_selectedDate);

    return Scaffold(
      appBar: AppBar(title: const Text('Buat Booking Janji Temu')),
      body: _isLoadingBranches
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('1. Pilih Unit Usaha', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      initialValue: _selectedBranchId,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Pilih Usaha'),
                      items: _branches
                          .map((b) => DropdownMenuItem(
                                value: b.id,
                                child: Text(
                                  b.displayName,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null && val != _selectedBranchId) {
                          setState(() => _selectedBranchId = val);
                          _loadBranchServices(val);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('2. Pilih Layanan Cabang', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    BookingServiceDropdown(
                      isLoading: _isLoadingServices,
                      services: _services,
                      selectedService: _selectedService,
                      onChanged: (val) => setState(() => _selectedService = val),
                    ),
                    const SizedBox(height: 16),
                    const Text('3. Jadwal Waktu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    BookingSchedulePicker(
                      dateText: dateStr,
                      timeText: timeStr,
                      onPickDate: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 30)),
                        );
                        if (picked != null) setState(() => _selectedDate = picked);
                      },
                      onPickTime: () async {
                        final picked = await showTimePicker(context: context, initialTime: _selectedTime);
                        if (picked != null) setState(() => _selectedTime = picked);
                      },
                    ),
                    const SizedBox(height: 16),
                    BookingPromoSelector(promos: _promos, selectedPromo: _selectedPromo, onChanged: (v) => setState(() => _selectedPromo = v)),
                    const Text('Catatan Tambahan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    TextField(controller: _notesController, maxLines: 2, decoration: const InputDecoration(hintText: 'Keluhan / instruksi khusus')),
                    const SizedBox(height: 20),
                    BookingSummaryCard(service: _selectedService, dateFormatted: dateStr, timeFormatted: timeStr),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitBooking,
                      child: _isSubmitting
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Kirim Booking Sekarang'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
