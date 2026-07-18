import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/openalex_config.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final _keyController = TextEditingController();
  bool _obscureKey = true;
  bool _saving = false;

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _saveKey(OpenAlexConfig config) async {
    setState(() => _saving = true);
    try {
      await config.saveKey(_keyController.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            config.hasSavedKey
                ? 'Đã lưu OpenAlex API key'
                : 'Đã xóa OpenAlex API key',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = context.watch<OpenAlexConfig>();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          const JournalAiAppBar(showBell: false),
          const SizedBox(height: 24),
          const Center(child: AppLogo(size: 72)),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'JournalAI',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Center(
            child: Text(
              'Research Intelligence Platform',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 28),
          MockupCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Journal Trend Analyzer helps researchers understand global publication trends, citation impact, and emerging topics using live data from OpenAlex.',
                  style: TextStyle(
                    height: 1.5,
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                const _AboutRow(label: 'Data Source', value: 'OpenAlex API'),
                _AboutRow(
                  label: 'Coverage',
                  value: '2015–${DateTime.now().year}',
                ),
                const _AboutRow(label: 'Total Records', value: '134M+ publications'),
                const _AboutRow(label: 'Version', value: '1.0.0'),
                const _AboutRow(label: 'Course', value: 'PRM393 Lab 3'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          MockupCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'OpenAlex API Key',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Nguồn: ${config.keySourceLabel}'
                  '${config.hasKey ? ' · đang dùng' : ' · chưa có key'}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _keyController,
                  obscureText: _obscureKey,
                  decoration: InputDecoration(
                    hintText: 'Dán API key từ openalex.org/settings/api',
                    border: const OutlineInputBorder(),
                    isDense: true,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureKey ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () =>
                          setState(() => _obscureKey = !_obscureKey),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: _saving ? null : () => _saveKey(config),
                        child: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Lưu key'),
                      ),
                    ),
                    if (config.hasSavedKey) ...[
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: _saving
                            ? null
                            : () {
                                _keyController.clear();
                                _saveKey(config);
                              },
                        child: const Text('Xóa'),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  final String label;
  final String value;

  const _AboutRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
