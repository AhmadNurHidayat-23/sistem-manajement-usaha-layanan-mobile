import 'package:flutter/material.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/membership_model.dart';
import '../../../services/api_service.dart';
import 'widgets/membership_summary_card.dart';
import 'widgets/point_history_card.dart';

class MembershipScreen extends StatefulWidget {
  const MembershipScreen({super.key});

  @override
  State<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen> {
  bool _isLoading = true;
  bool _isRegistering = false;
  String? _errorMessage;
  MembershipModel? _membership;

  @override
  void initState() {
    super.initState();
    _loadMembership();
  }

  Future<void> _loadMembership() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await ApiService.get(ApiEndpoints.customerMembership);
    if (!mounted) return;

    if (response.success) {
      if (response.data != null && response.data is Map<String, dynamic>) {
        setState(() {
          _membership = MembershipModel.fromJson(response.data as Map<String, dynamic>);
          _isLoading = false;
        });
      } else {
        setState(() {
          _membership = null;
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _errorMessage = response.message;
        _isLoading = false;
      });
    }
  }

  Future<void> _registerMembership() async {
    setState(() {
      _isRegistering = true;
    });

    final response = await ApiService.post(ApiEndpoints.customerMembershipRegister);
    if (!mounted) return;

    setState(() {
      _isRegistering = false;
    });

    if (response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message.isNotEmpty ? response.message : 'Berhasil mendaftar member!'),
          backgroundColor: Colors.green,
        ),
      );
      _loadMembership();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Membership & Poin'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadMembership,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadMembership,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final txs = _membership?.recentTransactions ?? [];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        MembershipSummaryCard(
          membership: _membership,
          onRegister: _registerMembership,
          isRegistering: _isRegistering,
        ),
        if (_membership != null) ...[
          const SizedBox(height: 24),
          const Text(
            'Riwayat Transaksi Poin',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          if (txs.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Center(
                child: Column(
                  children: [
                    Icon(Icons.history, size: 40, color: AppColors.textSecondary),
                    SizedBox(height: 8),
                    Text(
                      'Belum ada riwayat transaksi poin',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
          else
            ...txs.map((tx) => PointHistoryCard(transaction: tx)),
        ],
      ],
    );
  }
}
