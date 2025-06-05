import 'package:flutter/material.dart';

class CustomSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  
  const CustomSearchBar({super.key, required this.onSearch});

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final TextEditingController _controller = TextEditingController();
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _controller,
        onChanged: widget.onSearch,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Buscar aplicaciones...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          prefixIcon: const Icon(Icons.search, color: Colors.white),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _controller.clear();
                    widget.onSearch('');
                  },
                  icon: const Icon(Icons.clear, color: Colors.white),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
        ),
      ),
    );
  }
}