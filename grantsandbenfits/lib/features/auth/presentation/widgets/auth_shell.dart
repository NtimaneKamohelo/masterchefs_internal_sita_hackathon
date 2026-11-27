import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grantsandbenfits/core/theme/app_colors.dart';
import 'package:grantsandbenfits/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:grantsandbenfits/features/auth/presentation/bloc/auth_state.dart';

class AuthShell extends StatelessWidget {
  const AuthShell({
    required this.title,
    required this.subtitle,
    required this.child,
    super.key,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 960;
          final form = _FormPanel(title: title, subtitle: subtitle, child: child);
          if (!wide) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _BrandMark(onDark: false),
                    const SizedBox(height: 28),
                    form,
                  ],
                ),
              ),
            );
          }
          return Row(
            children: [
              const Expanded(child: _BrandPanel()),
              Expanded(
                child: SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 36,
                        vertical: 32,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: form,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FormPanel extends StatelessWidget {
  const _FormPanel({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(color: AppColors.muted, height: 1.4),
        ),
        const SizedBox(height: 16),
        const _DemoBanner(),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _DemoBanner extends StatelessWidget {
  const _DemoBanner();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previous, current) =>
          previous.issuesOutOfBandCodes != current.issuesOutOfBandCodes,
      builder: (context, state) {
        if (!state.issuesOutOfBandCodes) return const SizedBox.shrink();
        return const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: FormNotice(
            message:
                'Demo mode. Accounts stay on this device and passwords are bcrypt-hashed. Do not enter real personal information.',
          ),
        );
      },
    );
  }
}

class FormNotice extends StatelessWidget {
  const FormNotice({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE6D3A1)),
      ),
      child: Text(
        message,
        style: const TextStyle(color: AppColors.ink, height: 1.35),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.onDark});

  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final titleColor = onDark ? AppColors.white : AppColors.ink;
    final subtitleColor = onDark ? const Color(0xFFD5E6DF) : AppColors.muted;
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: onDark ? const Color(0xFF0C4A3C) : AppColors.forestDark,
            borderRadius: BorderRadius.circular(12),
            border: onDark ? Border.all(color: AppColors.gold) : null,
          ),
          alignment: Alignment.center,
          child: const Text(
            'GB',
            style: TextStyle(
              color: AppColors.gold,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Grants & Benefits',
                style: TextStyle(
                  color: titleColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              Text(
                'Eligibility Assistant',
                style: TextStyle(color: subtitleColor),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.forestDark,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _BrandMark(onDark: true),
              const Spacer(),
              const Text(
                'Faster checks.\nThe official still decides.',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 40,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'The assistant reads the rules, checks the evidence, and explains the recommendation. No application is declined automatically.',
                style: TextStyle(color: Color(0xFFD5E6DF), fontSize: 16, height: 1.45),
              ),
              const SizedBox(height: 28),
              const _BrandPoint(text: 'Rules the policy owner can see and update'),
              const _BrandPoint(text: 'Plain-language reasons for every outcome'),
              const _BrandPoint(text: 'A full audit trail of human decisions'),
              const Spacer(),
              Container(
                width: 72,
                height: 4,
                color: AppColors.gold,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandPoint extends StatelessWidget {
  const _BrandPoint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 8, color: AppColors.gold),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.white, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}
