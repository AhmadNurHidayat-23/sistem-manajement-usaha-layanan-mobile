import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/api_endpoints.dart';
import '../../models/branch_model.dart';
import '../../models/service_model.dart';
import '../../services/api_service.dart';
import 'widgets/booking_promo_selector.dart';
import 'widgets/drop_off_pickup_tile.dart';
import 'widgets/order_pricing_info_card.dart';

class BuatPesananScreen extends StatefulWidget {
  final int? initialBranchId;
  final int? initialServiceId;

  const BuatPesananScreen({super.key, this.initialBranchId, this.initialServiceId});

  @override
  State<BuatPesananScreen> createState() => _BuatPesananScreenState();
}

class _BuatPesananScreenState extends State<BuatPesananScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  List<BranchModel> _branches = [];
  List<ServiceModel> _services = [];
  List<Map<String, dynamic>> _promos = [];

  int? _selectedBranchId;
  ServiceModel? _selectedService;
  Map<String, dynamic>? _selectedPromo;
  bool _pickupOption = false;
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
          .where((s) => s.serviceType == 'drop_off' || s.isWeightBased)
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

  Future<void> _submitOrder() async {
    if (_selectedBranchId == null || _selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih cabang dan layanan drop-off.')));
      return;
    }
    setState(() => _isSubmitting = true);

    final body = <String, dynamic>{
      'branch_id': _selectedBranchId,
      'service_id': _selectedService!.id,
      'pickup_option': _pickupOption,
      'notes': _notesController.text.trim(),
    };
    if (_selectedPromo != null && _selectedPromo!['code'] != null) {
      body['promo_code'] = _selectedPromo!['code'];
    }

    final res = await ApiService.post(ApiEndpoints.customerOrders, body: body);
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (res.success) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Row(children: [Icon(Icons.check_circle, color: Colors.green), SizedBox(width: 8), Text('Pesanan Dibuat')]),
          content: Text('Pesanan ${_selectedService!.name} berhasil dibuat. Silakan serahkan barang Anda ke cabang pilihan.'),
          actions: [ElevatedButton(onPressed: () { Navigator.pop(ctx); Navigator.pop(context, true); }, child: const Text('OK'))],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.message), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Pesanan Drop-off')),
      body: _isLoadingBranches
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('1. Pilih Unit Usaha Drop-off', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
                    const Text('2. Pilih Layanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    if (_isLoadingServices)
                      const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
                    else if (_services.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(8)),
                        child: const Text('Tidak ada layanan drop-off pada cabang ini.', style: TextStyle(fontSize: 12, color: Colors.orange)),
                      )
                    else
                      DropdownButtonFormField<ServiceModel>(
                        initialValue: _selectedService,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Pilih Layanan'),
                        items: _services
                            .map((s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(
                                    '${s.name} (${_currency.format(s.price)}/${s.unit})',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ))
                            .toList(),
                        onChanged: (val) => setState(() => _selectedService = val),
                      ),
                    const SizedBox(height: 12),
                    if (_selectedService != null) ...[
                      OrderPricingInfoCard(service: _selectedService!),
                      const SizedBox(height: 16),
                    ],
                    BookingPromoSelector(promos: _promos, selectedPromo: _selectedPromo, onChanged: (v) => setState(() => _selectedPromo = v)),
                    DropOffPickupTile(value: _pickupOption, onChanged: (v) => setState(() => _pickupOption = v)),
                    const SizedBox(height: 16),
                    const Text('Catatan & Instruksi Khusus', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    TextField(controller: _notesController, maxLines: 2, decoration: const InputDecoration(hintText: 'Misal: tolong pisahkan baju putih')),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitOrder,
                      child: _isSubmitting
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Kirim Pesanan Drop-off'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
