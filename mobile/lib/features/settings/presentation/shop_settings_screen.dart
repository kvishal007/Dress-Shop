import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_dress_shop_pos/core/constants/app_colors.dart';
import 'package:smart_dress_shop_pos/features/settings/presentation/providers/settings_provider.dart';

class ShopSettingsScreen extends ConsumerStatefulWidget {
  const ShopSettingsScreen({super.key});
  @override
  ConsumerState<ShopSettingsScreen> createState() => _ShopSettingsScreenState();
}

class _ShopSettingsScreenState extends ConsumerState<ShopSettingsScreen> {
  final _shopNameCtrl = TextEditingController();
  final _currencyCtrl = TextEditingController();
  final _taxCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _receiptFormat = 'THERMAL';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initFields();
    });
  }

  void _initFields() {
    final settings = ref.read(settingsProvider).settings;
    if (settings != null) {
      _shopNameCtrl.text = settings.shopName;
      _currencyCtrl.text = settings.currency;
      _taxCtrl.text = settings.taxRate.toString();
      _addressCtrl.text = settings.address;
      _phoneCtrl.text = settings.phone;
      setState(() {
        _receiptFormat = settings.receiptFormat;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(settingsProvider);

    if (state.isLoading && state.settings == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Shop Settings')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section('General Settings', [
            _textField(_shopNameCtrl, 'Shop Name', Icons.storefront_outlined),
            _textField(_currencyCtrl, 'Currency Code (e.g. INR, USD)', Icons.payments_outlined),
            _textField(_taxCtrl, 'Tax Rate (%)', Icons.percent, isNum: true),
          ]),
          const SizedBox(height: 16),
          _section('Contact Info', [
            _textField(_phoneCtrl, 'Phone Number', Icons.phone_outlined),
            _textField(_addressCtrl, 'Address', Icons.location_on_outlined, maxLines: 2),
          ]),
          const SizedBox(height: 16),
          _section('Receipt Settings', [
            ListTile(
              leading: const Icon(Icons.receipt_long, color: AppColors.textSecondary, size: 20),
              title: const Text('Receipt Format', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              trailing: DropdownButton<String>(
                value: _receiptFormat,
                items: ['STANDARD', 'THERMAL', 'A4'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) => setState(() => _receiptFormat = val!),
              ),
            ),
          ]),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isSaving ? null : () async {
              setState(() => _isSaving = true);
              try {
                await ref.read(settingsProvider.notifier).updateSettings({
                  'shopName': _shopNameCtrl.text,
                  'currency': _currencyCtrl.text,
                  'taxRate': double.tryParse(_taxCtrl.text) ?? 0.0,
                  'receiptFormat': _receiptFormat,
                  'address': _addressCtrl.text,
                  'phone': _phoneCtrl.text,
                });
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings saved successfully'), backgroundColor: AppColors.accent));
              } catch (e) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error));
              } finally {
                setState(() => _isSaving = false);
              }
            },
            child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text('Save Settings'),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted, letterSpacing: 0.8)),
        const SizedBox(height: 8),
        Card(child: Column(children: children)),
      ],
    );
  }

  Widget _textField(TextEditingController ctrl, String label, IconData icon, {bool isNum = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: ctrl,
        keyboardType: isNum ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          border: InputBorder.none,
          filled: true,
          fillColor: Colors.transparent,
        ),
      ),
    );
  }
}
