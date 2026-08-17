// lib/features/onboarding/onboarding_page.dart
// 报家门页（仅首次启动）

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(currentUserProvider.notifier).save(
          _nameController.text.trim(),
          _cityController.text.trim(),
        );
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.riceWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                // 妈祖标识
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.mazuRed,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.mazuRed.withOpacity(0.2),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('🙏', style: TextStyle(fontSize: 44)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  '妈祖',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mazuRed,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '海外华人之日常仪式',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.gray,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 56),
                // 名字输入
                const Text(
                  '弟子如何称呼？',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.inkBlack,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  maxLength: 10,
                  decoration: const InputDecoration(
                    hintText: '请输入您的名字',
                    counterText: '',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return '请输入名字';
                    if (v.trim().length < 2) return '名字至少 2 个字';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                // 城市输入
                const Text(
                  '现居何处？',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.inkBlack,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _cityController,
                  maxLength: 30,
                  decoration: const InputDecoration(
                    hintText: '请输入城市',
                    counterText: '',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return '请输入城市';
                    if (v.trim().length < 2) return '城市至少 2 个字';
                    return null;
                  },
                ),
                const SizedBox(height: 48),
                // 提交按钮
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('入 殿 问 事'),
                ),
                const SizedBox(height: 16),
                const Text(
                  '名字与城市仅用于结果中称呼，可在设置中修改',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.gray,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
