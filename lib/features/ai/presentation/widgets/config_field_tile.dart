import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lens_wise/core/utils/debouncer.dart';
import 'package:lens_wise/features/ai/domain/models/ai_provider_config.dart';
import 'package:lens_wise/features/ai/presentation/widgets/config_option_bottom_sheet.dart';

class ConfigFieldTile extends StatelessWidget {
  final AIProviderConfig activeConfig;
  final ConfigField field;
  final bool isDark;
  final ValueChanged<String> onChanged;

  const ConfigFieldTile({
    super.key,
    required this.activeConfig,
    required this.field,
    required this.isDark,
    required this.onChanged,
  });

  IconData _getFieldIcon() {
    final k = field.key.toLowerCase();
    if (k.contains('model')) return Icons.smart_toy_rounded;
    if (k.contains('url')) return Icons.dns_rounded;
    if (k.contains('key')) return Icons.vpn_key_rounded;
    if (k.contains('id')) return Icons.fingerprint_rounded;
    if (k.contains('location')) return Icons.location_on_rounded;
    if (k.contains('thinking')) return Icons.tune_rounded;
    return Icons.tune_rounded;
  }

  @override
  Widget build(BuildContext context) {
    if (field is SelectConfigField) {
      final selectField = field as SelectConfigField;
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
        leading: Icon(_getFieldIcon(), color: isDark ? Colors.white54 : Colors.black54),
        title: Text(
          selectField.displayLabel,
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        trailing: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: isDark ? Colors.white54 : Colors.black54,
        ),
        onTap: () {
          ConfigOptionBottomSheet.show(
            context: context,
            title: '選擇${selectField.label}',
            options: selectField.options,
            selectedValue: selectField.value,
            onSelected: onChanged,
          );
        },
      );
    }

    final textField = field as TextConfigField;
    return _ConfigTextField(
      field: textField,
      isDark: isDark,
      icon: _getFieldIcon(),
      onChanged: onChanged,
    );
  }
}

class _ConfigTextField extends HookWidget {
  final TextConfigField field;
  final bool isDark;
  final IconData icon;
  final ValueChanged<String> onChanged;

  const _ConfigTextField({
    required this.field,
    required this.isDark,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController(text: field.value);
    final debouncer = useMemoized(() => Debouncer(milliseconds: 500));

    useEffect(() {
      if (controller.text != field.value) {
        controller.text = field.value;
      }
      return null;
    }, [field.value]);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: Icon(icon, color: isDark ? Colors.white54 : Colors.black54),
      title: TextField(
        controller: controller,
        obscureText: field.isSecret,
        style: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: field.label,
          hintStyle: TextStyle(
            fontFamily: 'Outfit',
            color: isDark ? Colors.white30 : Colors.black38,
            fontWeight: FontWeight.normal,
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onChanged: (val) {
          debouncer.run(() {
            onChanged(val);
          });
        },
      ),
    );
  }
}
