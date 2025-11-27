import 'package:flutter/material.dart';

class Gap extends StatelessWidget {
  final double size;

  const Gap(this.size, {super.key});

  const Gap.xs({super.key}) : size = 4;
  const Gap.s({super.key}) : size = 8;
  const Gap.m({super.key}) : size = 16;
  const Gap.l({super.key}) : size = 24;
  const Gap.xl({super.key}) : size = 32;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: size, width: size);
  }
}
