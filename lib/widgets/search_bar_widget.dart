import 'package:flutter/material.dart';
import '../theme/tokens.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({
    super.key,
    this.onTap,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: 'Search for articles, topics...',
        hintStyle: TextStyle(color: AppTokens.textSubtle),
        prefixIcon: const Icon(Icons.search, color: AppTokens.textMuted),
        filled: true,
        fillColor: AppTokens.card.withOpacity(0.5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide(color: AppTokens.accent.withOpacity(0.5)),
        ),
      ),
    );
  }
}
