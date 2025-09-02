import 'package:flutter/material.dart';
import '../utils/color_utils.dart';

class ColorPickerWidget extends StatelessWidget {
  final Function(String) onColorSelected;
  final String? selectedColor;

  const ColorPickerWidget({
    Key? key,
    required this.onColorSelected,
    this.selectedColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seleziona Colore',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: ColorUtils.vibrantColors.map((color) {
            final isSelected = selectedColor != null && 
                ColorUtils.hexToColor(selectedColor!) == color;
            
            return GestureDetector(
              onTap: () => onColorSelected(ColorUtils.colorToHex(color)),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.transparent,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 24,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
