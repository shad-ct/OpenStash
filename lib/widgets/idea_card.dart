import 'dart:ui';
import 'package:flutter/material.dart';

import '../theme/tokens.dart';

class IdeaCard extends StatefulWidget {
  const IdeaCard({
    super.key,
    required this.text,
    required this.saved,
    required this.liked,
    required this.onShare,
    required this.onToggleSaved,
    required this.onToggleLiked,
    this.initialRead = false,
    this.onLongPress,
    this.onRead,
    this.isFullScreen = false,
    this.imageUrl,
  });

  final String text;
  final bool saved;
  final bool liked;
  final bool initialRead;
  final bool isFullScreen;
  final String? imageUrl;
  final VoidCallback onShare;
  final VoidCallback onToggleSaved;
  final VoidCallback onToggleLiked;
  final VoidCallback? onLongPress;
  final VoidCallback? onRead;

  @override
  State<IdeaCard> createState() => IdeaCardState();
}

class IdeaCardState extends State<IdeaCard> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late final AnimationController _controller;
  late bool _isRead;
  // True once 4s is done — never goes back to false (persists across scroll).
  bool _timerDone = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _isRead = widget.initialRead;
    _timerDone = _isRead;

    _controller = AnimationController(
      vsync: this,
      value: _isRead ? 1.0 : 0.0,
      duration: const Duration(seconds: 4),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_isRead && mounted) {
        // 4s done → auto-mark as read immediately.
        setState(() {
          _isRead = true;
          _timerDone = true;
        });
        widget.onRead?.call();
      }
    });
  }

  @override
  void didUpdateWidget(IdeaCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the parent updates the read status (e.g. after async load), sync internal state.
    if (widget.initialRead != oldWidget.initialRead) {
      setState(() {
        _isRead = widget.initialRead;
        _timerDone = _isRead;
        if (_isRead) {
          _controller.value = 1.0;
        } else {
          _controller.value = 0.0;
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void startReading() {
    if (!_isRead && mounted && !_controller.isAnimating) {
      _controller.forward();
    }
  }

  void cancelReading() {
    // Only pause if not yet read AND timer hasn't completed.
    // We do NOT reset _timerDone — once earned, it stays.
    if (!_isRead && !_timerDone && mounted) {
      _controller.stop();
    }
  }

  /// Manual mark: allowed any time (tick button tappable always).
  void markAsRead() {
    if (!_isRead && mounted) {
      _controller.stop();
      setState(() {
        _isRead = true;
        _timerDone = true;
      });
      widget.onRead?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final borderColor = Colors.white.withOpacity(0.06);
    final bg = AppTokens.card.withOpacity(0.6);

    return Container(
      decoration: BoxDecoration(
        color: widget.isFullScreen ? Colors.transparent : bg,
        borderRadius: widget.isFullScreen ? BorderRadius.zero : BorderRadius.circular(AppTokens.r16),
        border: widget.isFullScreen ? null : Border.all(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (widget.imageUrl != null)
            Positioned.fill(
              child: Image.network(
                widget.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: widget.isFullScreen ? _buildFullScreen(context) : _buildNormal(context),
          ),
        ],
      ),
    );
  }

  Widget _buildNormal(BuildContext context) {
    return Stack(
        children: [
          // Animated fill progress
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => FractionallySizedBox(
                alignment: Alignment.topCenter,
                heightFactor: _isRead ? 1.0 : _controller.value,
                child: Container(color: AppTokens.accent.withOpacity(0.08)),
              ),
            ),
          ),

          Material(
            color: Colors.transparent,
            child: InkWell(
              onLongPress: widget.onLongPress,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.format_quote_rounded,
                      size: 20,
                      color: AppTokens.textMuted.withOpacity(0.3),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.text,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.6,
                            fontSize: 15,
                          ),
                    ),
                    const SizedBox(height: 16),

                    // Toolbar
                    Row(
                      children: [
                        _buildTickButton(context),
                        const Spacer(),
                        _IconAction(
                          icon: Icons.ios_share,
                          isActive: false,
                          onTap: widget.onShare,
                        ),
                        const SizedBox(width: 4),
                        _IconAction(
                          icon: widget.saved
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          isActive: widget.saved,
                          activeColor: AppTokens.accent,
                          onTap: widget.onToggleSaved,
                        ),
                        const SizedBox(width: 4),
                        _IconAction(
                          icon: widget.liked
                              ? Icons.favorite
                              : Icons.favorite_border,
                          isActive: widget.liked,
                          activeColor: Colors.redAccent,
                          onTap: widget.onToggleLiked,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
  }

  Widget _buildFullScreen(BuildContext context) {
    return Stack(
      children: [
        // Background immersive gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.4),
                Colors.black.withOpacity(0.7),
                Colors.black.withOpacity(0.9),
              ],
            ),
          ),
        ),
        
        // Progress fill (subtle)
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => FractionallySizedBox(
              alignment: Alignment.topCenter,
              heightFactor: _isRead ? 1.0 : _controller.value,
              child: Container(color: AppTokens.accent.withOpacity(0.05)),
            ),
          ),
        ),

        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.format_quote_rounded,
                  size: 32,
                  color: AppTokens.accent.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Text(
                      widget.text,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            height: 1.6,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTickButton(context, large: true),
                    const SizedBox(width: 24),
                    _IconAction(
                      icon: Icons.ios_share,
                      isActive: false,
                      onTap: widget.onShare,
                    ),
                    const SizedBox(width: 8),
                    _IconAction(
                      icon: widget.saved ? Icons.bookmark : Icons.bookmark_border,
                      isActive: widget.saved,
                      activeColor: AppTokens.accent,
                      onTap: widget.onToggleSaved,
                    ),
                    const SizedBox(width: 8),
                    _IconAction(
                      icon: widget.liked ? Icons.favorite : Icons.favorite_border,
                      isActive: widget.liked,
                      activeColor: Colors.redAccent,
                      onTap: widget.onToggleLiked,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTickButton(BuildContext context, {bool large = false}) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return GestureDetector(
          onTap: markAsRead,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.all(large ? 12 : 5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isRead ? AppTokens.accent.withOpacity(0.15) : Colors.transparent,
              border: Border.all(
                color: _isRead ? AppTokens.accent : Theme.of(context).dividerColor.withOpacity(0.4),
                width: large ? 2.5 : 1.5,
              ),
            ),
            child: Icon(
              Icons.check,
              size: large ? 24 : 14,
              color: _isRead ? AppTokens.accent : AppTokens.textMuted.withOpacity(0.25),
            ),
          ),
        );
      },
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.onTap,
    this.isActive = false,
    this.activeColor,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final fg = isActive ? (activeColor ?? AppTokens.accent) : AppTokens.textMuted;

    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      color: fg,
      style: IconButton.styleFrom(
        hoverColor: fg.withOpacity(0.05),
        highlightColor: fg.withOpacity(0.1),
        padding: const EdgeInsets.all(8),
        minimumSize: const Size(32, 32),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}