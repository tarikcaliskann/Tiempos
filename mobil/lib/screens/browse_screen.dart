import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../api/skills_api.dart';
import '../app/app_state.dart';
import '../language/shell_l10n.dart';
import '../widgets/app_chrome.dart';
import 'public_profile_screen.dart';
import 'skill_detail_screen.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

enum _SortOption { newest, title }

class _BrowseScreenState extends State<BrowseScreen> {
  final _search = TextEditingController();
  List<SkillDto> _catalog = [];
  bool _loading = true;
  String? _error;
  _SortOption _sort = _SortOption.newest;

  @override
  void initState() {
    super.initState();
    _search.addListener(_onSearchChanged);
    _load();
  }

  @override
  void dispose() {
    _search.removeListener(_onSearchChanged);
    _search.dispose();
    super.dispose();
  }

  void _onSearchChanged() => setState(() {});

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rows = await fetchPublicSkills();
      if (!mounted) return;
      setState(() {
        _catalog = rows;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _catalog = [];
        _loading = false;
      });
    }
  }

  List<SkillDto> _filteredSorted() {
    final q = _search.text.trim().toLowerCase();
    var list = List<SkillDto>.from(_catalog);
    final myId = widget.appState.userId?.trim();
    if (myId != null && myId.isNotEmpty) {
      list = list.where((s) => s.ownerId.trim().toLowerCase() != myId.toLowerCase()).toList();
    }
    if (q.isNotEmpty) {
      list = list.where((s) {
        final cat = (s.category ?? '').toLowerCase();
        return s.title.toLowerCase().contains(q) ||
            s.ownerName.toLowerCase().contains(q) ||
            cat.contains(q) ||
            s.description.toLowerCase().contains(q);
      }).toList();
    }
    switch (_sort) {
      case _SortOption.newest:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case _SortOption.title:
        list.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
    }
    return list;
  }

  void _openSkill(String id) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (ctx) => SkillDetailScreen(
          appState: widget.appState,
          skillId: id,
        ),
      ),
    );
  }

  void _openInstructor(String userId) {
    final t = widget.appState.token;
    if (t == null || t.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (ctx) => PublicProfileScreen(
          appState: widget.appState,
          userId: userId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sh = ShellL10n.of(context);
    final items = _filteredSorted();
    final myId = widget.appState.userId?.trim();
    final onlyOwnInCatalog = myId != null &&
        myId.isNotEmpty &&
        _catalog.isNotEmpty &&
        _catalog.every((s) => s.ownerId.trim().toLowerCase() == myId.toLowerCase());
    final isDark = theme.brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: _load,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          AppChrome.gradientSliverHeader(
            context: context,
            title: sh.browseTitle,
            subtitle: sh.browseSubtitle,
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _search,
                    decoration: AppChrome.searchDecoration(
                      context,
                      hintText: sh.browseSearchHint,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Text(
                        sh.browseSortBy,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SegmentedButton<_SortOption>(
                          segments: [
                            ButtonSegment(
                              value: _SortOption.newest,
                              label: Text(sh.browseNewest),
                            ),
                            ButtonSegment(
                              value: _SortOption.title,
                              label: Text(sh.browseSortTitle),
                            ),
                          ],
                          selected: {_sort},
                          onSelectionChanged: (s) {
                            setState(() => _sort = s.first);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_error != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Text(
                  _error!,
                  style: GoogleFonts.inter(
                    color: theme.colorScheme.error,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          if (_loading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (items.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    _catalog.isEmpty
                        ? sh.browseEmptyCatalog
                        : onlyOwnInCatalog
                            ? sh.browseOnlyOwnSkills
                            : sh.browseEmptySearch,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      height: 1.45,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final s = items[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _BrowseSkillListTile(
                        skill: s,
                        onOpen: () => _openSkill(s.id),
                        onInstructor: () => _openInstructor(s.ownerId),
                        l10n: sh,
                        isDark: isDark,
                      ),
                    );
                  },
                  childCount: items.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BrowseSkillListTile extends StatelessWidget {
  const _BrowseSkillListTile({
    required this.skill,
    required this.onOpen,
    required this.onInstructor,
    required this.l10n,
    required this.isDark,
  });

  final SkillDto skill;
  final VoidCallback onOpen;
  final VoidCallback onInstructor;
  final ShellL10n l10n;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final coverUrl = skillCoverProxyUrl(skill.id);
    final types = skill.sessionTypes;
    final online = types.any((e) => e.toLowerCase() == 'online');
    final inPerson = types.any((e) => e.toLowerCase().contains('person'));

    final borderColor = theme.colorScheme.outline.withValues(
      alpha: isDark ? 0.22 : 0.45,
    );

    return Material(
      color: theme.colorScheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 88,
                  height: 88,
                  child: Image.network(
                    coverUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => ColoredBox(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 32,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      skill.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: onInstructor,
                      child: Text(
                        skill.ownerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (skill.category != null && skill.category!.trim().isNotEmpty)
                          Chip(
                            label: Text(
                              skill.category!,
                              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            backgroundColor: theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: isDark ? 0.55 : 0.85),
                            side: BorderSide(
                              color: theme.colorScheme.outline.withValues(alpha: 0.35),
                            ),
                          ),
                        if (online)
                          Chip(
                            label: Text(
                              l10n.browseOnline,
                              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            backgroundColor: theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: isDark ? 0.55 : 0.85),
                            side: BorderSide(
                              color: theme.colorScheme.outline.withValues(alpha: 0.35),
                            ),
                          ),
                        if (inPerson)
                          Chip(
                            label: Text(
                              l10n.browseInPerson,
                              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            backgroundColor: theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: isDark ? 0.55 : 0.85),
                            side: BorderSide(
                              color: theme.colorScheme.outline.withValues(alpha: 0.35),
                            ),
                          ),
                        Chip(
                          label: Text(
                            l10n.browseMinutesPerSession(skill.durationMinutes),
                            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          backgroundColor: theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: isDark ? 0.55 : 0.85),
                          side: BorderSide(
                            color: theme.colorScheme.outline.withValues(alpha: 0.35),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: onOpen,
                        icon: const Icon(Icons.event_available_rounded, size: 20),
                        label: Text(
                          l10n.browseBookNow,
                          style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 14),
                        ),
                        style: FilledButton.styleFrom(
                          elevation: isDark ? 0 : 1,
                          shadowColor: Colors.black.withValues(alpha: 0.12),
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
