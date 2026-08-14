import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SplashAnimationPage extends HookConsumerWidget {
  const SplashAnimationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Controller for the entrance animation sequence
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 2000),
    );

    // 1. Logo fade & scale
    final logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller, 
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );
    final logoScale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: controller, 
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    // 2. Unfold Text (controls heightFactor and slide)
    final unfold = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.4, 0.9, curve: Curves.easeOutCubic),
    );
    
    // Text slides from slightly above (hidden by ClipRect) to normal position
    final textSlide = Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero).animate(unfold);
    
    // Text fade lags slightly behind the unfold for elegance
    final textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller, 
        curve: const Interval(0.5, 0.9, curve: Curves.easeOut),
      ),
    );

    useEffect(() {
      void startAnimations() async {
        await controller.forward();
        
        // Wait briefly after animation completes before routing
        await Future.delayed(const Duration(milliseconds: 400));
        
        if (context.mounted) {
          context.go('/scanner');
        }
      }
      startAnimations();
      return null;
    }, []);

    return Scaffold(
      backgroundColor: Colors.white, // Pure white for a professional look
      body: Center(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo 
                FadeTransition(
                  opacity: logoFade,
                  child: ScaleTransition(
                    scale: logoScale,
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 140, // Nice and prominent
                      height: 140,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.camera,
                          size: 100,
                          color: Color(0xFF1D1D1F),
                        );
                      },
                    ),
                  ),
                ),
                
                // Cinematic Unfold for the text
                ClipRect(
                  child: Align(
                    alignment: Alignment.topCenter,
                    heightFactor: unfold.value, // Height dynamically expands from 0 to 1
                    child: SlideTransition(
                      position: textSlide,
                      child: FadeTransition(
                        opacity: textFade,
                        child: const Padding(
                          padding: EdgeInsets.only(top: 24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'LensWise',
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1D1D1F), // Deep iron grey
                                  letterSpacing: 2.0,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'AI VISION ASSISTANT',
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF86868B), // Subtle secondary grey
                                  letterSpacing: 6.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
