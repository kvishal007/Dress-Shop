import 'package:flutter/material.dart';
import 'package:smart_dress_shop_pos/core/constants/app_colors.dart';

class ShopSettingsScreen extends StatelessWidget {
  const ShopSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shop Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section('Shop Information', [
            _settingTile('Shop Name', 'Smart Dress Shop', Icons.storefront_outlined),
            _settingTile('Phone Number', 'Not set', Icons.phone_outlined),
            _settingTile('Email', 'Not set', Icons.email_outlined),
            _settingTile('Address', 'Not set', Icons.location_on_outlined),
          ]),
          const SizedBox(height: 16),
          _section('Receipt Settings', [
            _settingTile('Shop Logo', 'Not uploaded', Icons.image_outlined),
            _settingTile('Receipt Footer', 'Thank you for shopping!', Icons.receipt_outlined),
            _settingTile('Invoice Prefix', 'INV-', Icons.tag),
          ]),
          const SizedBox(height: 16),
          _section('Payment Methods', [
            _switchTile('Cash', true),
            _switchTile('UPI / GPay / PhonePe', true),
            _switchTile('Card / POS Machine', true),
            _switchTile('Bank Transfer', false),
            _switchTile('Credit (Khata)', true),
          ]),
          const SizedBox(height: 16),
          _section('Tax Settings', [
            _settingTile('GST Number', 'Not configured', Icons.calculate_outlined),
            _settingTile('Default Tax Rate', '0% (No Tax)', Icons.percent),
          ]),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Save Settings'),
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

  Widget _settingTile(String label, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary, size: 20),
      title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: Text(value, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
      onTap: () {},
    );
  }

  Widget _switchTile(String label, bool enabled) {
    return ListTile(
      title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: Switch(value: enabled, onChanged: (_) {}, activeColor: AppColors.accent),
    );
  }
}
