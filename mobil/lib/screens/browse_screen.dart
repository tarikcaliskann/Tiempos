import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../api/skills_api.dart';
import '../app/app_state.dart';
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
    final items = _filteredSorted();
    final myId = widget.appState.userId;

    return RefreshIndicator(
      onRefresh: _load,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverAppBar.large(
            title: const Text('Explore Skills'),
            pinned: true,
            backgroundColor: theme.colorScheme.surface,
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _search,
                    decoration: InputDecoration(
                      hintText: 'Search skills, instructors, categories…',
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        'Sort by',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SegmentedButton<_SortOption>(
                          segments: const [
                            ButtonSegment(
                              value: _SortOption.newest,
                              label: Text('Newest'),
                            ),
                            ButtonSegment(
                              value: _SortOption.title,
                              label: Text('A–Z'),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        ? 'No skills are listed yet. Offer one from Home!'
                        : 'No matches for your search.',
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
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final s = items[i];
                    final own = myId != null && myId == s.ownerId;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _BrowseSkillCard(
                        skill: s,
                        isOwnListing: own,
                        onOpen: () => _openSkill(s.id),
                        onInstructor: () => _openInstructor(s.ownerId),
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

class _BrowseSkillCard extends StatelessWidget {
  const _BrowseSkillCard({
    required this.skill,
    required this.isOwnListing,
    required this.onOpen,
    required this.onInstructor,
  });

  final SkillDto skill;
  final bool isOwnListing;
  final VoidCallback onOpen;
  final VoidCallback onInstructor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final coverUrl = skillCoverProxyUrl(skill.id);
    final types = skill.sessionTypes;
    final online = types.any((e) => e.toLowerCase() == 'online');
    final inPerson = types.any((e) => e.toLowerCase().contains('person'));

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                coverUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => ColoredBox(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    size: 40,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    skill.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: onInstructor,
                    child: Text(
                      skill.ownerName,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
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
                          label: Text(skill.category!, style: const TextStyle(fontSize: 12)),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                        ),
                      if (online)
                        const Chip(
                          label: Text('Online', style: TextStyle(fontSize: 12)),
                          visualDensity: VisualDensity.compact,
                        ),
                      if (inPerson)
                        const Chip(
                          label: Text('In-person', style: TextStyle(fontSize: 12)),
                          visualDensity: VisualDensity.compact,
                        ),
                      Chip(
                        label: Text(
                          '${skill.durationMinutes} min / session',
                          style: const TextStyle(fontSize: 12),
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  if (!isOwnListing) ...[
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: onOpen,
                      child: const Text('Book now'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
