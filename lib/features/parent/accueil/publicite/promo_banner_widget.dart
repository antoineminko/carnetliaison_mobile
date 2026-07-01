import 'dart:async';
import 'package:flutter/material.dart';

class PromoBannerWidget extends StatefulWidget {
  const PromoBannerWidget({super.key});

  @override
  State<PromoBannerWidget> createState() => _PromoBannerWidgetState();
}

class _PromoBannerWidgetState extends State<PromoBannerWidget> {
  final PageController _pubPageController = PageController();
  Timer? _timer;
  int _currentPubIndex = 0;

  final List<String> pubImages = [
    'https://i.pinimg.com/736x/46/c9/7f/46c97fda08fb8c284e70704de113fa1a.jpg',
    'https://i.pinimg.com/736x/70/84/85/7084854f0a3841d6cfda063c0ad64ccc.jpg',
    'https://www.aciafrica.org/images/gabon_1642722311.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _startPubTimer();
  }

  void _startPubTimer() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pubPageController.hasClients) {
        _currentPubIndex = (_currentPubIndex + 1) % pubImages.length;
        _pubPageController.animateToPage(
          _currentPubIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pubPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: PageView.builder(
          controller: _pubPageController,
          itemCount: pubImages.length,
          onPageChanged: (index) => _currentPubIndex = index,
          itemBuilder: (context, index) {
            return Image.network(
              pubImages[index],
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[200],
                child: const Icon(
                  Icons.broken_image_outlined,
                  color: Colors.grey,
                  size: 40,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
