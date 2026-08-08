import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lens_wise/core/widgets/thinking_orb.dart';
import 'package:lens_wise/features/product_lens/presentation/controllers/product_lens_controller.dart';

class ProductResultPage extends ConsumerStatefulWidget {
  const ProductResultPage({super.key});

  @override
  ConsumerState<ProductResultPage> createState() => _ProductResultPageState();
}

class _ProductResultPageState extends ConsumerState<ProductResultPage> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productLensControllerProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: _buildBody(context, ref, state),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, ProductLensState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (state.status) {
      case ProductLensStatus.loading:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ThinkingOrb(size: 100, isDark: isDark),
              const SizedBox(height: 32),
              const Text(
                'AI 深度萃取中...',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.purpleAccent),
              ),
              const SizedBox(height: 16),
              Text(
                '正在為您解析成份與特徵\n這可能需要幾秒鐘的時間',
                textAlign: TextAlign.center,
                style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14),
              ),
            ],
          ),
        );

      case ProductLensStatus.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.redAccent.withValues(alpha: 0.8)),
                const SizedBox(height: 16),
                Text('解析失敗', style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(
                  state.errorMessage ?? '發生未知的系統錯誤，請稍後再試。',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(productLensControllerProvider.notifier).reset();
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/');
                    }
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('返回相機'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white10,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        );

      case ProductLensStatus.success:
        if (state.result == null) {
          return Center(
            child: ElevatedButton(
              onPressed: () {
                ref.read(productLensControllerProvider.notifier).reset();
                if (context.canPop()) context.pop();
                else context.go('/');
              },
              child: const Text('無效的資料 (返回)'),
            ),
          );
        }
        
        final res = state.result!;
        if (res.status != 'success') {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.orangeAccent.withValues(alpha: 0.8)),
                const SizedBox(height: 16),
                Text(res.message ?? '圖片不清晰，無法識別商品。', style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 18)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    ref.read(productLensControllerProvider.notifier).reset();
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/');
                    }
                  },
                  child: const Text('重新拍攝'),
                ),
              ],
            ),
          );
        }

        final data = res.data ?? {};
        final productName = data['productName'] as String?;
        final originalName = data['originalName'] as String?;
        final brand = data['brand'] as String?;
        final origin = data['origin'] as String?;
        final summary = data['summary'] as String?;
        final ingredients = (data['ingredients'] as List?)?.map((e) => e.toString()).toList();
        final allergens = (data['allergens'] as List?)?.map((e) => e.toString()).toList();
        final dietaryFlags = (data['dietaryFlags'] as List?)?.map((e) => e.toString()).toList();
        final recommendedFor = (data['recommendedFor'] as List?)?.map((e) => e.toString()).toList();
        final notRecommendedFor = (data['notRecommendedFor'] as List?)?.map((e) => e.toString()).toList();

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.black,
              title: const Text('解析結果'),
              floating: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  ref.read(productLensControllerProvider.notifier).reset();
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/');
                  }
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 100, left: 16, right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Header (Name & Brand)
                    Text(
                      productName ?? '未知商品',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                        height: 1.2,
                      ),
                    ),
                    if (originalName != null && originalName != productName)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          originalName,
                          style: const TextStyle(fontSize: 16, color: Colors.grey, fontStyle: FontStyle.italic),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.storefront, size: 18, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          '${brand ?? "未知品牌"} ${origin != null ? "· $origin" : ""}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // 2. Summary
                    if (summary != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.lightbulb_outline, color: Theme.of(context).primaryColor),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                summary,
                                style: TextStyle(
                                  fontSize: 15,
                                  height: 1.5,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),

                    // 3. Ingredients & Allergens
                    _buildSectionTitle(context, '成分與過敏原提醒', Icons.science),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...?allergens?.map((a) => _buildBadge(a, isDark, isAlert: true)),
                        ...?dietaryFlags?.map((d) => _buildBadge(d, isDark, isAlert: false)),
                      ],
                    ),
                    if (ingredients != null && ingredients.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        '主要成分: ${ingredients.join(', ')}',
                        style: TextStyle(fontSize: 13, color: isDark ? Colors.white54 : Colors.black54, height: 1.5),
                      ),
                    ],
                    const SizedBox(height: 32),

                    // 4. Pros & Cons (Recommended For)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildProsConsCard(
                            context,
                            title: '推薦情境',
                            icon: Icons.check_circle_outline,
                            color: Colors.green,
                            items: recommendedFor ?? [],
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildProsConsCard(
                            context,
                            title: '不推薦情境',
                            icon: Icons.cancel_outlined,
                            color: Colors.redAccent,
                            items: notRecommendedFor ?? [],
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 40),
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          ref.read(productLensControllerProvider.notifier).reset();
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/');
                          }
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('掃描其他商品'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );

      case ProductLensStatus.idle:
      default:
        // Fallback for idle state (when user just lands on page without analysis)
        return Center(
          child: ElevatedButton.icon(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('返回相機'),
          ),
        );
    }
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(icon, size: 20, color: isDark ? Colors.white70 : Colors.black54),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(String text, bool isDark, {required bool isAlert}) {
    final color = isAlert ? Colors.redAccent : Colors.blueAccent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isAlert ? (isDark ? Colors.redAccent[200] : Colors.red[700]) : (isDark ? Colors.blueAccent[200] : Colors.blue[700]),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildProsConsCard(BuildContext context, {required String title, required IconData icon, required Color color, required List<String> items, required bool isDark}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            Text('無特別說明', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 13))
          else
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
            )),
        ],
      ),
    );
  }
}
