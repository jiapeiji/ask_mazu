// lib/services/physics/block_physics.dart
// 杯筊物理模拟

import 'dart:math';
import 'package:flutter/material.dart';

import '../../core/utils/result_templates.dart';

enum BlockFace { flat, curved }  // 平、凸

class Block {
  BlockFace face;
  Offset position;       // 屏幕坐标
  double angle;          // 当前角度（弧度）
  double angularVelocity;
  Offset velocity;
  bool isLanded = false;
  int flipCount = 0;     // 翻转次数

  Block({
    required this.face,
    required this.position,
    this.angle = 0,
    this.angularVelocity = 0,
    this.velocity = Offset.zero,
  });
}

class BlockPhysics {
  final Random _random = Random();

  late Block blockA;
  late Block blockB;

  Size screenSize = const Size(390, 844);  // iPhone 14 默认
  static const double gravity = 9.8;
  static const double blockSize = 80;      // 杯筊大小
  double groundY = 700;                    // 地面 Y 坐标（可变）

  bool isFlying = false;
  bool _isFlipping = false;
  bool _isDone = false;
  int _frameCount = 0;

  void init({required Size size}) {
    screenSize = size;
    groundY = size.height * 0.78;

    // 初始化两块杯筊
    final startX = size.width / 2;
    final startY = size.height * 0.45;

    blockA = Block(
      face: BlockFace.flat,
      position: Offset(startX - 30, startY),
      angle: 0,
    );
    blockB = Block(
      face: BlockFace.curved,
      position: Offset(startX + 30, startY),
      angle: 0,
    );

    isFlying = true;
    _isFlipping = false;
    _isDone = false;
    _frameCount = 0;

    // 抛出初速度
    _throwBlock(blockA);
    _throwBlock(blockB);
  }

  void _throwBlock(Block block) {
    final speed = 8.0 + _random.nextDouble() * 4.0;
    final angle = -pi / 2 + (_random.nextDouble() - 0.5) * 0.4;  // 主要向上
    block.velocity = Offset(
      cos(angle) * speed * 0.4 * (_random.nextDouble() - 0.5),
      sin(angle) * speed,
    );
    block.angularVelocity = 4.0 + _random.nextDouble() * 4.0;
    if (_random.nextBool()) block.angularVelocity = -block.angularVelocity;
  }

  /// 更新物理（每帧调用）
  /// 返回 true 表示已完成
  bool update(double dt) {
    if (_isDone) return true;
    _frameCount++;

    if (isFlying) {
      // 抛物线更新
      for (final block in [blockA, blockB]) {
        block.position = block.position + block.velocity * dt * 60;
        block.velocity = block.velocity + Offset(0, gravity * dt * 30);
        block.angle += block.angularVelocity * dt;

        // 检测落地
        if (block.position.dy >= groundY) {
          block.position = Offset(block.position.dx, groundY);
          block.isLanded = true;
          isFlying = false;
          _isFlipping = true;
        }
      }
    } else if (_isFlipping) {
      // 翻转衰减
      for (final block in [blockA, blockB]) {
        block.angularVelocity *= 0.92;  // 阻尼
        block.angle += block.angularVelocity * dt * 5;
        if (block.angularVelocity.abs() < 0.5) {
          block.angularVelocity = 0;
        }
        if (block.flipCount < 3 && _random.nextDouble() < 0.3) {
          block.flipCount++;
          block.angularVelocity += (_random.nextBool() ? 1 : -1) * 2.0;
        }
      }

      // 判定是否全部静止
      final allStopped = blockA.angularVelocity.abs() < 0.1 &&
                         blockB.angularVelocity.abs() < 0.1;
      if (allStopped && _frameCount > 60) {
        _isFlipping = false;
        _isDone = true;
        return true;
      }
    }

    return false;
  }

  /// 获取最终结果
  ThrowResultType getResult() {
    // 根据物理角度判定最终姿态
    final aFace = _determineFace(blockA.angle);
    final bFace = _determineFace(blockB.angle);

    if (aFace == BlockFace.flat && bFace == BlockFace.flat) {
      return ThrowResultType.laugh;  // 两平 = 笑杯
    }
    if (aFace == BlockFace.curved && bFace == BlockFace.curved) {
      return ThrowResultType.yin;    // 两凸 = 阴杯
    }
    return ThrowResultType.saint;    // 一平一凸 = 圣杯
  }

  BlockFace _determineFace(double angle) {
    // 简化：角度在 -π/2 到 π/2 范围内是平（朝上），其他是凸
    final normalized = angle % (2 * pi);
    final adjusted = normalized < 0 ? normalized + 2 * pi : normalized;
    return (adjusted < pi / 2 || adjusted > 3 * pi / 2) ? BlockFace.flat : BlockFace.curved;
  }
}
