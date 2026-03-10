import 'dart:async';
import 'package:flutter/material.dart';

class PreLoginOnboarding extends StatefulWidget {
  const PreLoginOnboarding({super.key});

  @override
  State<PreLoginOnboarding> createState() => _PreLoginOnboardingState();
}

class _PreLoginOnboardingState extends State<PreLoginOnboarding> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'BUILD',
      'subtitle': 'Cranes, Footings, Columns',
      'image': 'https://images.unsplash.com/photo-1541888946425-d81bb19480c5?q=80&w=1000&auto=format&fit=crop',
    },
    {
      'title': 'STRUCTURE',
      'subtitle': 'Pillars & Sentring',
      'image': 'https://images.unsplash.com/photo-1503387762-592dea58ef23?q=80&w=1000&auto=format&fit=crop',
    },
    {
      'title': 'POWER',
      'subtitle': 'Mains, Wiring, Motors',
      'image': 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?q=80&w=1000&auto=format&fit=crop',
    },
    {
      'title': 'FINISH',
      'subtitle': 'Painting & Carpentry',
      'image': 'https://images.unsplash.com/photo-1589939705384-5185137a7f0f?q=80&w=1000&auto=format&fit=crop',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentPage < _onboardingData.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 800),
          curve: Curves.fastOutSlowIn,
        );
      } else {
        _timer?.cancel();
        _navigateToLogin();
      }
    });
  }

  void _navigateToLogin() {
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(), // Auto-move only
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _onboardingData.length,
            itemBuilder: (context, index) => _buildPage(index),
          ),
          
          // Progress bar at top
          Positioned(
            top: 60,
            left: 20,
            right: 20,
            child: Row(
              children: List.generate(
                _onboardingData.length,
                (index) => Expanded(
                  child: Container(
                    height: 3,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: index <= _currentPage ? Colors.orange : Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // High-impact text overlay
          Positioned(
            bottom: 80,
            left: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _onboardingData[_currentPage]['title']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 64,
                    fontWeight: FontWeight.w900, // Corrected from .black
                    letterSpacing: -2,
                  ),
                ),
                Text(
                  _onboardingData[_currentPage]['subtitle']!,
                  style: TextStyle(
                    color: Colors.orange.shade400,
                    fontSize: 24,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),

          // Skip button
          Positioned(
            top: 80,
            right: 20,
            child: TextButton(
              onPressed: _navigateToLogin,
              child: const Text('SKIP', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(int index) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Image.network(
        _onboardingData[index]['image']!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[900],
            child: const Center(child: CircularProgressIndicator(color: Colors.orange)),
          );
        },
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[900],
          child: const Center(child: Icon(Icons.construction, color: Colors.orange, size: 50)),
        ),
      ),
    );
  }
}
