import 'package:flutter/material.dart';
import 'package:service_manager_front/src/domain/models/servins.dart';

extension ServinTypeVisuals on ServinType {
  MaterialColor get color {
    switch (this) {
      case ServinType.neptuno:
        return Colors.indigo;
      case ServinType.mercury:
        return Colors.deepPurple;
      case ServinType.serum:
        return Colors.teal;
    }
  }

  Color get backgroundColor => color.shade50;
  Color get darkTextColor => color.shade800;
}
