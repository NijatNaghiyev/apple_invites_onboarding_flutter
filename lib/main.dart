import 'dart:async';
import 'dart:developer';

import 'package:apple_invites_onboarding_flutter/data/dummy_data.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: const MyHomeScreen());
  }
}

class MyHomeScreen extends StatefulWidget {
  const MyHomeScreen({super.key});

  @override
  State<MyHomeScreen> createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<MyHomeScreen> {
  late final PageController _pageController;
  final ValueNotifier<double> _currentPageNotifier = ValueNotifier(
    DummyData.dummyData.length * 99999 + 1,
  );

  Timer? _timer;
  bool _isUserInteracting = false;

  Future<void> _startAutoScroll() async {
    _timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      if (!_isUserInteracting) {
        _pageController.animateTo(
          _pageController.offset + 30,
          duration: Duration(milliseconds: 500),
          curve: Curves.linear,
        );
      }
    });
  }

  void _stopAutoScroll() {
    _timer?.cancel();
    _timer = null;
  }

  void _onUserInteractionStart() {
    _isUserInteracting = true;
    _stopAutoScroll();
    log("_onUserInteractionStart");
  }

  void _onUserInteractionEnd() {
    _isUserInteracting = false;
    _startAutoScroll();
    log("_onUserInteractionEnd");
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: DummyData.dummyData.length * 99999,
      viewportFraction: 0.6,
    )..addListener(() {
      final page = _pageController.page!;
      if (page != _currentPageNotifier.value) {
        _currentPageNotifier.value = page + 0.4;
      }
    });

    _startAutoScroll();
  }

  @override
  void dispose() {
    _stopAutoScroll();
    _pageController.dispose();
    _currentPageNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder(
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.decelerate,
            duration: const Duration(milliseconds: 800),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, -300 * (1 - value)),
                child: child!,
              );
            },
            child: GestureDetector(
              onPanDown: (_) => _onUserInteractionStart(),
              onPanUpdate: (_) => _onUserInteractionStart(),
              onPanCancel: _onUserInteractionEnd,
              onPanEnd: (_) => _onUserInteractionEnd(),
              onLongPressStart: (_) => _onUserInteractionStart(),
              onLongPressEnd: (_) => _onUserInteractionEnd(),
              onHorizontalDragUpdate: (details) {
                _onUserInteractionStart();
                _pageController.position.jumpTo(
                  _pageController.position.pixels - details.primaryDelta!,
                );
              },
              onHorizontalDragEnd: (details) {
                _pageController.position.animateTo(
                  _pageController.position.pixels +
                      -details.velocity.pixelsPerSecond.dx * .1,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.decelerate,
                );
                _onUserInteractionEnd();
              },
              child: SizedBox(
                height: 400,
                child: ValueListenableBuilder(
                  valueListenable: _currentPageNotifier,
                  builder: (context, currentPage, _) {
                    return PageView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      controller: _pageController,
                      padEnds: false,
                      pageSnapping: false,
                      itemBuilder: (context, index) {
                        double difference = index - currentPage;
                        // if (difference == -1) {
                        //   difference = -0.5;
                        // }
                        // if (difference == 0) {
                        //   difference = -.5;
                        // }

                        difference = difference.clamp(-1.0, 1.0);

                        return AnimatedContainer(
                          clipBehavior: Clip.hardEdge,
                          duration: const Duration(milliseconds: 50),
                          transform:
                              Matrix4.identity()
                                ..setEntry(3, 2, 0.001)
                                ..rotateZ((index - currentPage) * 0.1)
                                ..translate(0.0, (difference).abs() * 15, 0.0),
                          transformAlignment: Alignment.bottomCenter,
                          key: ValueKey(index),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 32,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: .2),
                                blurRadius: 16,
                                spreadRadius: 4,
                              ),
                            ],
                          ),

                          child: Image.asset(
                            DummyData.dummyData[index %
                                DummyData.dummyData.length],
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
