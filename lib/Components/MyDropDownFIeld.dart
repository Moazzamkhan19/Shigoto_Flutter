import 'package:flutter/material.dart';

class MyDropdownField extends StatelessWidget {
  final String? value;
  final Map<String, dynamic> itemDisplay;
  final String hint;
  final ValueChanged<String?> onChanged;

  const MyDropdownField({
    super.key,
    this.value,
    required this.itemDisplay,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Extract items from map keys
    final items = itemDisplay.keys.toList();
    return DropdownButtonFormField<String>(
      value: value,
      hint: Text(hint),
      isExpanded: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Row(
            children: [
              _buildIcon(itemDisplay[item]),
              SizedBox(width: 12),
              Expanded(child: Text(item, overflow: TextOverflow.ellipsis)),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
      menuMaxHeight: 300,
    );
  }

  Widget _buildIcon(dynamic displayItem) {
    if (displayItem is IconData) {
      return Icon(displayItem, size: 24, color: Colors.black);
    } else if (displayItem is String) {
      return CircleAvatar(
        radius: 18,
        backgroundImage: AssetImage(displayItem),
        backgroundColor: Colors.grey[200],
      );
    }
    return SizedBox.shrink();
  }
}