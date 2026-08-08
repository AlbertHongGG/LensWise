import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lens_wise/features/product_comparison/presentation/widgets/comparison_decision_card.dart';

class ProductComparisonResultPage extends StatelessWidget {
  final Map<String, dynamic> resultData;

  const ProductComparisonResultPage({
    super.key,
    required this.resultData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final List<dynamic> products = resultData['products'] ?? [];
    final Map<String, dynamic> differences = resultData['differences'] ?? {};
    final String? valueAnalysis = resultData['valueAnalysis']?.toString();
    final List<dynamic> decisionTree = resultData['decisionTree'] ?? [];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('AI 商品比對報告', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background decorative gradients
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blueAccent.withValues(alpha: 0.15),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purpleAccent.withValues(alpha: 0.15),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Product Cards Side-by-Side
                  if (products.isNotEmpty)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: products.map((p) {
                          return Container(
                            width: 280, // Fixed width for horizontal scrolling
                            margin: const EdgeInsets.only(right: 16),
                            child: _buildProductCard(p, isDark),
                          );
                        }).toList(),
                      ),
                    ),
                  
                  const SizedBox(height: 32),

                  // Differences Section
                  if (differences.isNotEmpty) ...[
                    _buildSectionTitle(Icons.difference, '關鍵差異分析', isDark),
                    const SizedBox(height: 16),
                    if (differences['featureDiff'] != null)
                      _buildDiffBox('特色差異', differences['featureDiff'].toString(), isDark),
                    const SizedBox(height: 12),
                    if (differences['specDiff'] != null)
                      _buildDiffBox('成分與規格差異', differences['specDiff'].toString(), isDark),
                    const SizedBox(height: 32),
                  ],

                  // Decision Tree & CP Value Card (Glassmorphism)
                  if (decisionTree.isNotEmpty || valueAnalysis != null)
                    ComparisonDecisionCard(
                      decisionTree: decisionTree,
                      valueAnalysis: valueAnalysis,
                    ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, bool isDark) {
    final String id = product['id']?.toString() ?? '?';
    final String originalName = product['originalName']?.toString() ?? '未知名稱';
    final String translatedName = product['translatedName']?.toString() ?? '';
    final String brand = product['brand']?.toString() ?? '未知品牌';
    final List<dynamic> features = product['features'] ?? [];
    final List<dynamic> ingredients = product['ingredients'] ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  id,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      translatedName.isNotEmpty ? translatedName : originalName,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      brand,
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (features.isNotEmpty) ...[
            Text('主打特色', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...features.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: Colors.blueAccent)),
                  Expanded(child: Text(f.toString(), style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 13))),
                ],
              ),
            )),
            const SizedBox(height: 12),
          ],
          if (ingredients.isNotEmpty) ...[
            Text('關鍵成分', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              ingredients.join(', '),
              style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 12),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title, bool isDark) {
    return Row(
      children: [
        Icon(icon, color: Colors.purpleAccent),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDiffBox(String label, String content, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purpleAccent.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.purpleAccent,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
