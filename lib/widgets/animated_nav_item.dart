import 'package:flutter/material.dart';

class AnimatedNavItem extends StatefulWidget {
  final String icon;
  final String activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const AnimatedNavItem({
    Key? key,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  State<AnimatedNavItem> createState() => _AnimatedNavItemState();
}

class _AnimatedNavItemState extends State<AnimatedNavItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _widthAnimation;
  late Animation<double> _iconSlideAnimation;
  late Animation<double> _textSlideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500), // Increased duration for smoother animation
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );

    _widthAnimation = Tween<double>(begin: 40, end: 120).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _iconSlideAnimation = Tween<double>(begin: 0, end: -30).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _textSlideAnimation = Tween<double>(begin: 0, end: 20).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(AnimatedNavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Base container for icon (always visible)
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              child: FadeTransition(
                opacity: ReverseAnimation(_fadeAnimation), // Fade in when deselected
                child: Image.asset(
                  widget.icon,
                  width: 24,
                  height: 24,
                ),
              ),
            ),
            // Animated container that expands from center
            if (widget.isSelected)
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: _widthAnimation.value,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF46BE5C),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Transform.translate(
                        offset: Offset(_iconSlideAnimation.value, 0),
                        child: Image.asset(
                          widget.activeIcon,
                          width: 24,
                          height: 24,
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(_textSlideAnimation.value, 0),
                        child: Text(
                          widget.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}