import 'package:flutter/material.dart';
import '../utils/icon_utils.dart';
import '../utils/color_utils.dart';

class IconPickerWidget extends StatelessWidget {
  final Function(String) onIconSelected;
  final String? selectedIcon;
  final String? selectedColor;

  const IconPickerWidget({
    Key? key,
    required this.onIconSelected,
    this.selectedIcon,
    this.selectedColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seleziona Icona',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: IconUtils.availableIcons.length,
          itemBuilder: (context, index) {
            final iconName = IconUtils.availableIcons[index];
            final isSelected = selectedIcon == iconName;
            final color = selectedColor != null 
                ? ColorUtils.hexToColor(selectedColor!)
                : ColorUtils.getVibrantColor(index);

            return GestureDetector(
              onTap: () => onIconSelected(iconName),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected 
                      ? color.withOpacity(0.2)
                      : color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? color : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      IconUtils.getIconFromName(iconName),
                      color: color,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      iconName,
                      style: TextStyle(
                        fontSize: 10,
                        color: color,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
