import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/ai/domain/models/ai_agent_type.dart';
import 'package:lens_wise/features/ai/domain/models/ai_provider_config.dart';
import 'package:lens_wise/features/ai/presentation/controllers/ai_config_controller.dart';
import 'package:lens_wise/core/theme/app_colors.dart';
import 'package:lens_wise/core/widgets/immersive_scaffold.dart';

class AgentConfigScreen extends ConsumerStatefulWidget {
  final AiAgentType agentType;

  const AgentConfigScreen({super.key, required this.agentType});

  @override
  ConsumerState<AgentConfigScreen> createState() => _AgentConfigScreenState();
}

class _AgentConfigScreenState extends ConsumerState<AgentConfigScreen> {
  late TextEditingController _modelNameController;
  late TextEditingController _baseUrlController;
  late TextEditingController _projectIdController;
  late TextEditingController _regionController;
  late TextEditingController _accessTokenController;

  AIProviderType? _lastProviderType;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _modelNameController = TextEditingController();
    _baseUrlController = TextEditingController();
    _projectIdController = TextEditingController();
    _regionController = TextEditingController();
    _accessTokenController = TextEditingController();
  }

  @override
  void dispose() {
    _modelNameController.dispose();
    _baseUrlController.dispose();
    _projectIdController.dispose();
    _regionController.dispose();
    _accessTokenController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _syncControllers(AIConfigState state) {
    final agentConfig = state.getConfigFor(widget.agentType);
    
    if (_lastProviderType == agentConfig.activeProviderType) return;
    _lastProviderType = agentConfig.activeProviderType;

    final config = agentConfig.activeConfig;

    if (_modelNameController.text != config.modelName) {
      _modelNameController.text = config.modelName;
    }

    if (config is GeminiFlowConfig) {
      if (_baseUrlController.text != config.baseUrl)
        _baseUrlController.text = config.baseUrl;
    } else if (config is OllamaConfig) {
      if (_baseUrlController.text != config.baseUrl)
        _baseUrlController.text = config.baseUrl;
    } else if (config is VertexAIConfig) {
      if (_projectIdController.text != config.projectId)
        _projectIdController.text = config.projectId;
      if (_regionController.text != config.region)
        _regionController.text = config.region;
      if (_accessTokenController.text != config.accessToken)
        _accessTokenController.text = config.accessToken;
    }
  }

  void _onFieldChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      final state = ref.read(aiConfigControllerProvider);
      final agentConfig = state.getConfigFor(widget.agentType);
      final config = agentConfig.activeConfig;

      AIProviderConfig newConfig = config;
      if (config is GeminiFlowConfig) {
        newConfig = config.copyWith(
          modelName: _modelNameController.text,
          baseUrl: _baseUrlController.text,
        );
      } else if (config is OllamaConfig) {
        newConfig = config.copyWith(
          modelName: _modelNameController.text,
          baseUrl: _baseUrlController.text,
        );
      } else if (config is VertexAIConfig) {
        newConfig = config.copyWith(
          modelName: _modelNameController.text,
          projectId: _projectIdController.text,
          region: _regionController.text,
          accessToken: _accessTokenController.text,
        );
      }

      ref
          .read(aiConfigControllerProvider.notifier)
          .saveAgentConfig(widget.agentType, activeProviderConfig: newConfig);
    });
  }

  IconData _getProviderIcon(AIProviderType type) {
    if (type == AIProviderType.geminiflow) return Icons.auto_awesome;
    if (type == AIProviderType.ollama) return Icons.memory_rounded;
    return Icons.cloud_done_rounded;
  }
  


  void _showProviderSelectorBottomSheet(AIProviderType activeType, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '選擇 AI 提供者',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              ...AIProviderType.values.map((type) {
                final isSelected = activeType == type;
                return ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  tileColor: isSelected
                      ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                      : null,
                  leading: Icon(
                    _getProviderIcon(type),
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : (isDark ? Colors.white54 : Colors.black54),
                  ),
                  title: Text(
                    type.name.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : (isDark ? Colors.white : Colors.black),
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(
                          Icons.check_circle_rounded,
                          color: Theme.of(context).primaryColor,
                        )
                      : null,
                  onTap: () {
                    _lastProviderType = null;
                    ref
                        .read(aiConfigControllerProvider.notifier)
                        .saveAgentConfig(widget.agentType, providerType: type);
                    Navigator.pop(context);
                  },
                );
              }),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSmartSelectorCard(AIProviderType type, bool isDark) {
    return GestureDetector(
      onTap: () => _showProviderSelectorBottomSheet(type, isDark),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        color: Colors.transparent,
        child: Row(
          children: [
            Container(
              constraints: const BoxConstraints(minWidth: 50),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Icon(
                _getProviderIcon(type),
                color: Theme.of(context).primaryColor,
                size: 22,
              ),
            ),
            Expanded(
              child: Text(
                type.name.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    String hint,
    IconData icon,
    TextEditingController controller,
    bool isDark, {
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      onChanged: (_) => _onFieldChanged(),
      obscureText: obscureText,
      style: TextStyle(
        fontFamily: 'Outfit',
        fontSize: 16,
        color: isDark ? Colors.white : Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontFamily: 'Outfit',
          color: isDark ? Colors.white30 : Colors.black38,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Icon(icon, color: Theme.of(context).primaryColor, size: 22),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 50,
          minHeight: 50,
        ),
        filled: true,
        fillColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 60),
      child: Divider(
        height: 1,
        thickness: 0.5,
        color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05),
      ),
    );
  }

  List<Widget> _buildParameterFields(AIProviderConfig config, bool isDark) {
    final List<Widget> fields = [];

    fields.add(_buildDivider(isDark));
    fields.add(
      _buildSettingsTile(
        'Model Name',
        Icons.smart_toy_rounded,
        _modelNameController,
        isDark,
      ),
    );

    if (config is VertexAIConfig) {
      fields.add(_buildDivider(isDark));
      fields.add(
        _buildSettingsTile(
          'Project ID',
          Icons.business_rounded,
          _projectIdController,
          isDark,
        ),
      );
      fields.add(_buildDivider(isDark));
      fields.add(
        _buildSettingsTile(
          'Region',
          Icons.public_rounded,
          _regionController,
          isDark,
        ),
      );
      fields.add(_buildDivider(isDark));
      fields.add(
        _buildSettingsTile(
          'Access Token',
          Icons.key_rounded,
          _accessTokenController,
          isDark,
          obscureText: true,
        ),
      );
    } else {
      fields.add(_buildDivider(isDark));
      fields.add(
        _buildSettingsTile(
          'Base URL',
          Icons.dns_rounded,
          _baseUrlController,
          isDark,
        ),
      );
    }

    return fields;
  }

  Widget _buildAnimatedParametersGroup(AIProviderConfig config, bool isDark) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutQuart,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.05),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: Column(
          key: ValueKey(config.runtimeType),
          children: _buildParameterFields(config, isDark),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiConfigControllerProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    _syncControllers(state);

    final agentConfig = state.getConfigFor(widget.agentType);

    return ImmersiveScaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              widget.agentType.displayName,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black26
                          : Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildSmartSelectorCard(agentConfig.activeProviderType, isDark),
                    _buildAnimatedParametersGroup(agentConfig.activeConfig, isDark),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
