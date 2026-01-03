import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../providers/game_provider.dart';
import '../widgets/resource_bar.dart';
import '../widgets/scenario_card.dart';
import '../utils/ad_helper.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  bool _isBannerLoaded = false;

  @override
  void initState() {
    super.initState();
    // We'll wrap safely.
    try {
      if (!AdHelper.isTestMode && (Platform.isAndroid || Platform.isIOS)) {
        _loadBannerAd();
        _loadInterstitialAd();
      }
    } catch (e) {
      debugPrint("Ad loading failed or unsupported platform: $e");
    }
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          setState(() {
            _isBannerLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('BannerAd failed to load: $err');
          ad.dispose();
        },
      ),
    )..load();
  }

  void _loadInterstitialAd() {
    if (AdHelper.isTestMode) return;
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
           debugPrint('$ad loaded.');
           _interstitialAd = ad;
           _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
             onAdDismissedFullScreenContent: (ad) {
               ad.dispose();
               _loadInterstitialAd(); // Load next one
             },
             onAdFailedToShowFullScreenContent: (ad, err) {
               ad.dispose();
               _loadInterstitialAd();
             }
           );
        },
        onAdFailedToLoad: (err) {
          debugPrint('InterstitialAd failed to load: $err');
        },
      ),
    );
  }
  
  void _showInterstitialAd(GameNotifier notifier) {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null; // Dispose handled in callback, but clear ref here or in callback logic
      notifier.adShown();
    } else {
      debugPrint("Interstitial ad not ready.");
      notifier.adShown(); // Skip ad if not ready so game continues
      _loadInterstitialAd(); // Try loading again
    }
  }
  
  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final gameNotifier = ref.read(gameProvider.notifier);
    
    // Listen for Ad Trigger
    ref.listen(gameProvider.select((s) => s.showAd), (previous, next) {
      if (next == true) {
        _showInterstitialAd(gameNotifier);
      }
    });
    
    // We need a key to force rebuild or controller to handle resets if needed, 
    // but flutter_card_swiper usually handles list changes well if key changes.
    // For now, let's keep it simple.

    if (gameState.isGameOver) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Vương Triều Sụp Đổ", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.red)),
                const SizedBox(height: 16),
                Text("Bạn đã trị vì được ${gameState.yearsReigned} năm.", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(gameState.gameOverReason ?? "", textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    gameNotifier.restartGame();
                  },
                  child: const Text("Trị vì lại"),
                )
              ],
            ),
          ),
        ),
      );
    }
    
    // Safety check for empty deck
    if (gameState.scenarioDeck.isEmpty) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC), // Beige background
      body: SafeArea(
        child: Column(
          children: [
            // Stats
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Năm trị vì: ${gameState.yearsReigned}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("Kỷ lục: ${gameState.highScore}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
                ],
              ),
            ),
            // Resource Bars
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
              child: Row(
                children: [
                  ResourceBar(value: gameState.money, icon: Icons.monetization_on, color: Colors.amber, label: "Tiền"),
                  const SizedBox(width: 8),
                  ResourceBar(value: gameState.people, icon: Icons.people, color: Colors.blue, label: "Dân"),
                  const SizedBox(width: 8),
                  ResourceBar(value: gameState.army, icon: Icons.shield, color: Colors.red, label: "Quân"),
                  const SizedBox(width: 8),
                  ResourceBar(value: gameState.religion, icon: Icons.wb_sunny, color: Colors.purple, label: "Đạo"),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Card Swiper
            Expanded(
              child: CardSwiper(
                cardsCount: gameState.scenarioDeck.length,
                initialIndex: gameState.currentScenarioIndex,
                onSwipe: (previousIndex, currentIndex, direction) {
                   final scenario = gameState.scenarioDeck[previousIndex];
                   if (direction == CardSwiperDirection.right) {
                     gameNotifier.makeChoice(scenario.rightChoice);
                   } else if (direction == CardSwiperDirection.left) {
                     gameNotifier.makeChoice(scenario.leftChoice);
                   }
                   return true; // Continue swipe
                },
                cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
                  return ScenarioCard(scenario: gameState.scenarioDeck[index]);
                },
                numberOfCardsDisplayed: 1, // Focus on one
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              ),
            ),
            
            // Hints/Action Text (Optional, shows when dragging)
            const SizedBox(height: 20),
             Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Text(
                "Vuốt Trái / Phải để ra quyết định",
                style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic),
              ),
            ),
            if (_isBannerLoaded && _bannerAd != null)
              SizedBox(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
