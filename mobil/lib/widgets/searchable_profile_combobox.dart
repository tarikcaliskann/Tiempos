import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/profile_picklists.dart';

/// Web `SearchableCombobox` — alt sayfa + arama + liste.
class SearchableProfileCombobox extends StatelessWidget {
  const SearchableProfileCombobox({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.options,
    required this.placeholder,
    required this.searchPlaceholder,
    required this.emptyText,
    this.enabled = true,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final List<ProfilePicklistOption> options;
  final String placeholder;
  final String searchPlaceholder;
  final String emptyText;
  final bool enabled;

  String _displayLabel() {
    final v = value.trim();
    if (v.isEmpty) return '';
    for (final o in options) {
      if (o.value == v || o.label == v) return o.label;
    }
    return v;
  }

  Future<void> _open(BuildContext context) async {
    if (!enabled) return;
    var query = '';
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        final bottom = MediaQuery.of(ctx).viewInsets.bottom;
        final h = MediaQuery.of(ctx).size.height * 0.58;
        return Padding(
          padding: EdgeInsets.only(bottom: bottom),
          child: StatefulBuilder(
            builder: (ctx, setS) {
              final q = query.trim().toLowerCase();
              final filtered = q.isEmpty
                  ? options
                  : options
                      .where(
                        (o) =>
                            o.label.toLowerCase().contains(q) ||
                            o.value.toLowerCase().contains(q),
                      )
                      .toList();

              return SafeArea(
                child: SizedBox(
                  height: h,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: TextField(
                          autofocus: true,
                          onChanged: (v) => setS(() => query = v),
                          decoration: InputDecoration(
                            hintText: searchPlaceholder,
                            prefixIcon: const Icon(Icons.search_rounded),
                            border: const OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      Expanded(
                        child: filtered.isEmpty
                            ? Center(
                                child: Text(
                                  emptyText,
                                  style: GoogleFonts.inter(
                                    color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.55),
                                  ),
                                ),
                              )
                            : ListView.separated(
                                itemCount: filtered.length,
                                separatorBuilder: (_, i) => const Divider(height: 1),
                                itemBuilder: (_, i) {
                                  final o = filtered[i];
                                  return ListTile(
                                    title: Text(
                                      o.label,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    onTap: () {
                                      onChanged(o.value);
                                      Navigator.pop(ctx);
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final display = _displayLabel();
    final showPlaceholder = display.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
          ),
        ),
        const SizedBox(height: 6),
        Material(
          color: theme.colorScheme.surface,
          child: InkWell(
            onTap: enabled ? () => _open(context) : null,
            borderRadius: BorderRadius.circular(8),
            child: InputDecorator(
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: theme.colorScheme.outline),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      showPlaceholder ? placeholder : display,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: showPlaceholder
                            ? theme.colorScheme.onSurface.withValues(alpha: 0.45)
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
