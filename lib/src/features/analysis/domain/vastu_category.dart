import 'package:flutter/material.dart';

enum DirectionScheme { directions16, entrance32 }

class VastuCategory {
  const VastuCategory({
    required this.id,
    required this.name,
    required this.hindiName,
    required this.icon,
    this.scheme = DirectionScheme.directions16,
  });

  final String id;
  final String name;
  final String hindiName;
  final IconData icon;
  final DirectionScheme scheme;
}

