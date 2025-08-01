import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSearch;
  final String hintText;

  const CustomSearchBar({
    Key? key,
    required this.controller,
    required this.onSearch,
    this.hintText = '搜索歌曲、歌手...',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            Color(0xFF6A1B9A).withOpacity(0.1),
            Color(0xFF1A237E).withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey[300],
            fontSize: 16,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey[300],
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    controller.clear();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Color(0xFF4B5563),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onSubmitted: onSearch,
        textInputAction: TextInputAction.search,
      ),
    );
  }
}