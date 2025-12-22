import 'package:flutter/material.dart';

import '../theme/tokens.dart';

class LibraryTile extends StatelessWidget {
  const LibraryTile({
    super.key,
    required this.label,
    required this.icon,
    required this.background,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final Color background;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTokens.r16),
      child: Material(
        color: background,
        child: InkWell(
          onTap: onTap,
          splashColor: Colors.white.withOpacity(0.06),
          child: SizedBox(
            height: 92,
            child: Stack(
              children: [
                Center(
                  child: Icon(icon, size: 28, color: Colors.white.withOpacity(0.9)),
                ),
                Positioned(
                  left: AppTokens.p12,
                  bottom: AppTokens.p12,
                  right: AppTokens.p12,
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
