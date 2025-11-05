import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AutoPageView extends StatefulWidget {
  const AutoPageView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.interval = const Duration(seconds: 3),
    this.transitionDuration = const Duration(milliseconds: 400),
    this.curve = Curves.easeInOut,
    this.controller,
    this.onPageChanged,
    this.loop = true,
    this.physics,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final Duration interval;
  final Duration transitionDuration;
  final Curve curve;
  final PageController? controller;
  final ValueChanged<int>? onPageChanged;
  final bool loop;
  final ScrollPhysics? physics;

  @override
  State<AutoPageView> createState() => _AutoPageViewState();
}

class _AutoPageViewState extends State<AutoPageView> {
  late final PageController _controller = widget.controller ?? PageController();

  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(widget.interval, (_) {
      if (!_controller.hasClients || widget.itemCount == 0) return;

      final int current = _controller.page?.round() ?? _controller.initialPage;
      int next = current + 1;

      if (next >= widget.itemCount) {
        if (!widget.loop) return;
        next = 0; // wrap
      }

      _controller.animateToPage(
        next,
        duration: widget.transitionDuration,
        curve: widget.curve,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _controller,
      itemCount: widget.itemCount,
      physics: widget.physics,
      onPageChanged: widget.onPageChanged,
      itemBuilder: widget.itemBuilder,
    );
  }
}

class EnhancedPageView extends StatefulWidget {
  final List<Map<String, String>> items;

  const EnhancedPageView({super.key, required this.items});

  @override
  State<EnhancedPageView> createState() => _EnhancedPageViewState();
}

class _EnhancedPageViewState extends State<EnhancedPageView>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    // Auto-scroll
    Future.delayed(const Duration(seconds: 2), _autoScroll);
  }

  void _autoScroll() {
    if (!mounted) return;
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      int nextPage = (_currentPage + 1) % widget.items.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
      _autoScroll();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        SizedBox(
          height: 480,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
              _animationController.reset();
              _animationController.forward();
            },
            itemCount: widget.items.length,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_pageController.position.haveDimensions) {
                    value = _pageController.page! - index;
                    value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                  }
                  return Center(
                    child: Transform.scale(
                      scale: Curves.easeOut.transform(value),
                      child: Opacity(
                        opacity: value,
                        child: child,
                      ),
                    ),
                  );
                },
                child: _buildSlide(index),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        _buildPageIndicator(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSlide(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image container with rounded corners and shadow
          Container(
            height: 320,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    widget.items[index]['image']!,
                    fit: BoxFit.cover,
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                        stops: const [0.5, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Title with animation
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeOut,
            )),
            child: Text(
              widget.items[index]['title']!,
              textAlign: TextAlign.center,
              style: Get.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Subtitle with animation
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.5),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeOut,
            )),
            child: Text(
              widget.items[index]['subTitle']!,
              textAlign: TextAlign.center,
              style: Get.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.items.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: _currentPage == index ? 24 : 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? Colors.white
                : Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
