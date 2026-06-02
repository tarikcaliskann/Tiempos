// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../api/api_exception.dart';
import '../api/skills_api.dart';
import '../app/app_state.dart';
import '../data/profile_picklists.dart';
import '../language/profile_l10n.dart';
import '../language/skill_flow_l10n.dart';
import '../util/booking_utils.dart';
import '../util/skill_description.dart';
import '../widgets/app_chrome.dart';
import '../widgets/searchable_profile_combobox.dart';

const _categories = [
  'Sports',
  'Arts',
  'Languages',
  'Programming',
  'Music',
  'Cooking',
  'Photography',
  'Writing',
  'Design',
  'Other',
];

const _levels = ['Beginner', 'Intermediate', 'Advanced'];

const _dayApi = [
  'MONDAY',
  'TUESDAY',
  'WEDNESDAY',
  'THURSDAY',
  'FRIDAY',
  'SATURDAY',
  'SUNDAY',
];

class AddSkillScreen extends StatefulWidget {
  const AddSkillScreen({super.key, required this.appState, this.skillId});

  final AppState appState;
  final String? skillId;

  @override
  State<AddSkillScreen> createState() => _AddSkillScreenState();
}

class _AddSkillScreenState extends State<AddSkillScreen> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _customCategory = TextEditingController();
  final _locationText = TextEditingController();
  final _tags = TextEditingController();

  String _category = 'Programming';
  String _level = 'Beginner';
  int _durationMinutes = 60;
  final Set<String> _sessionTypes = {'online'};
  final Set<String> _selectedDays = {};
  String _startTime = '09:00';
  String _endTime = '17:00';

  bool _loadingSkill = false;
  bool _saving = false;
  String? _error;
  ProfilePicklists? _picklists;

  bool get _isEdit => widget.skillId != null && widget.skillId!.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    ProfilePicklists.load().then((p) {
      if (mounted) setState(() => _picklists = p);
    });
    if (_isEdit) {
      _loadSkill();
    } else {
      _selectedDays.addAll({
        'MONDAY',
        'TUESDAY',
        'WEDNESDAY',
        'THURSDAY',
        'FRIDAY',
      });
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _customCategory.dispose();
    _locationText.dispose();
    _tags.dispose();
    super.dispose();
  }

  String _descriptionMain(String desc) {
    const sep = '\n\n———\n';
    final i = desc.indexOf(sep);
    return (i >= 0 ? desc.substring(0, i) : desc).trim();
  }

  String _hhmm(String? raw) {
    if (raw == null || raw.isEmpty) return '09:00';
    final parts = raw.split(':');
    if (parts.length >= 2) {
      final h = (int.tryParse(parts[0]) ?? 9).clamp(0, 23);
      final m = (int.tryParse(parts[1]) ?? 0).clamp(0, 59);
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
    }
    return raw;
  }

  Future<void> _loadSkill() async {
    final id = widget.skillId!.trim();
    final t = widget.appState.token;
    if (t == null) return;
    setState(() {
      _loadingSkill = true;
      _error = null;
    });
    try {
      final s = await fetchSkillById(id);
      final cat = (s.category ?? '').trim();
      if (_categories.contains(cat) && cat != 'Other') {
        _category = cat;
      } else if (cat.isNotEmpty) {
        _category = 'Other';
        _customCategory.text = cat;
      }
      _title.text = s.title;
      _description.text = _descriptionMain(s.description);
      _level = (s.level ?? 'Beginner').trim().isEmpty ? 'Beginner' : s.level!.trim();
      if (_levels.contains(_level) == false) _level = 'Intermediate';
      _durationMinutes = s.durationMinutes > 0 ? s.durationMinutes : 60;
      _sessionTypes
        ..clear()
        ..addAll(s.sessionTypes.map((e) => e.toLowerCase()));
      if (_sessionTypes.isEmpty) _sessionTypes.add('online');
      _locationText.text = s.inPersonLocation?.trim() ?? '';
      _selectedDays
        ..clear()
        ..addAll(s.availableDays.map((e) => e.toUpperCase()));
      if (s.availableFrom != null && s.availableFrom!.isNotEmpty) {
        _startTime = _hhmm(s.availableFrom);
      }
      if (s.availableUntil != null && s.availableUntil!.isNotEmpty) {
        _endTime = _hhmm(s.availableUntil);
      }
      if (!mounted) return;
      setState(() => _loadingSkill = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loadingSkill = false;
      });
    }
  }

  List<String> _timeOptions() => buildHalfHourSlots('06:00', '23:30');

  Future<void> _submit() async {
    final sf = SkillFlowL10n.of(context);
    final t = widget.appState.token;
    if (t == null) {
      setState(() => _error = sf.errNotSignedIn);
      return;
    }
    if (_title.text.trim().isEmpty) {
      setState(() => _error = sf.errTitleRequired);
      return;
    }
    if (_sessionTypes.isEmpty) {
      setState(() => _error = sf.errSessionType);
      return;
    }
    if (_sessionTypes.any((e) => e.toLowerCase().contains('person')) &&
        _locationText.text.trim().isEmpty) {
      setState(() => _error = sf.errInPersonLocation);
      return;
    }
    if (_selectedDays.isEmpty) {
      setState(() => _error = sf.errPickDay);
      return;
    }
    if (_startTime.compareTo(_endTime) >= 0) {
      setState(() => _error = sf.errTimeOrder);
      return;
    }

    final resolvedCategory =
        _category == 'Other' ? _customCategory.text.trim() : _category;
    if (_category == 'Other' && resolvedCategory.isEmpty) {
      setState(() => _error = sf.errCustomCategory);
      return;
    }

    final tagList = _tags.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final fullDescription = buildSkillDescriptionForApi(
      baseDescription: _description.text,
      sessionTypes: _sessionTypes.toList(),
      inPersonLocation: _locationText.text,
      selectedDaysDisplay: _selectedDays.toList(),
      dayLabels: List.generate(_dayApi.length, (i) => sf.dayShort(i)),
      startTime: _startTime,
      endTime: _endTime,
      tags: tagList,
    );

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final payload = <String, dynamic>{
        'title': _title.text.trim(),
        'description': fullDescription,
        'durationMinutes': _durationMinutes,
        'category': resolvedCategory,
        'level': _level,
        'sessionTypes': _sessionTypes.toList(),
        'inPersonLocation': _sessionTypes.any((e) => e.toLowerCase().contains('person'))
            ? _locationText.text.trim()
            : null,
        'availableDays': _selectedDays.toList(),
        'availableFrom': _startTime,
        'availableUntil': _endTime,
      };

      if (_isEdit) {
        await updateSkill(t, widget.skillId!.trim(), payload);
      } else {
        await createSkill(t, payload);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sf = SkillFlowL10n.of(context);
    final pl = ProfileL10n.of(context);
    final times = _timeOptions();

    return Scaffold(
      appBar: AppChrome.gradientAppBar(
        title: _isEdit ? sf.editSkillTitle : sf.offerSkillTitle,
      ),
      body: _loadingSkill
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        _error!,
                        style: GoogleFonts.inter(color: theme.colorScheme.error),
                      ),
                    ),
                  TextField(
                    controller: _title,
                    decoration: InputDecoration(
                      labelText: sf.skillTitleLabel,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _description,
                    minLines: 4,
                    maxLines: 10,
                    decoration: InputDecoration(
                      labelText: sf.description,
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: sf.category,
                    ),
                    value: _categories.contains(_category) ? _category : 'Other',
                    items: _categories
                        .map(
                          (c) => DropdownMenuItem(
                            value: c,
                            child: Text(sf.categoryLabelForApiValue(c)),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _category = v);
                    },
                  ),
                  if (_category == 'Other') ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _customCategory,
                      decoration: InputDecoration(
                        labelText: sf.customCategory,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: sf.level,
                    ),
                    value: _levels.contains(_level) ? _level : 'Intermediate',
                    items: _levels
                        .map(
                          (c) => DropdownMenuItem(
                            value: c,
                            child: Text(sf.levelLabelForApiValue(c)),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _level = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      labelText: sf.sessionLengthMinutes,
                    ),
                    value: [30, 45, 60, 90, 120, 180].contains(_durationMinutes)
                        ? _durationMinutes
                        : 60,
                    items: const [30, 45, 60, 90, 120, 180]
                        .map(
                          (m) => DropdownMenuItem(
                            value: m,
                            child: Text(sf.minutesOption(m)),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _durationMinutes = v);
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    sf.sessionType,
                    style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: Text(sf.online),
                        selected: _sessionTypes.contains('online'),
                        onSelected: (v) {
                          setState(() {
                            if (v) {
                              _sessionTypes.add('online');
                            } else {
                              _sessionTypes.remove('online');
                            }
                          });
                        },
                      ),
                      FilterChip(
                        label: Text(sf.inPerson),
                        selected: _sessionTypes.any((e) => e.contains('person')),
                        onSelected: (v) {
                          setState(() {
                            if (v) {
                              _sessionTypes.add('in-person');
                            } else {
                              _sessionTypes.removeWhere(
                                (e) => e.toLowerCase().contains('person'),
                              );
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  if (_sessionTypes.any((e) => e.toLowerCase().contains('person'))) ...[
                    const SizedBox(height: 12),
                    if (_picklists != null) ...[
                      SearchableProfileCombobox(
                        label: sf.inPersonLocation,
                        value: _locationText.text,
                        onChanged: (v) => setState(() => _locationText.text = v),
                        options: mergeLegacyOption(
                          _picklists!.locationOptions(),
                          _locationText.text,
                        ),
                        placeholder: pl.locationHint,
                        searchPlaceholder: pl.picklistSearch,
                        emptyText: sf.locationEmpty,
                      ),
                    ] else ...[
                      TextField(
                        controller: _locationText,
                        decoration: InputDecoration(
                          labelText: sf.inPersonLocation,
                          hintText: sf.locationSearchHint,
                        ),
                      ),
                    ],
                  ],
                  const SizedBox(height: 16),
                  Text(
                    sf.availableDays,
                    style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                  ),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: List.generate(_dayApi.length, (i) {
                      final d = _dayApi[i];
                      final label = sf.dayShort(i);
                      return FilterChip(
                        label: Text(label),
                        selected: _selectedDays.contains(d),
                        onSelected: (v) {
                          setState(() {
                            if (v) {
                              _selectedDays.add(d);
                            } else {
                              _selectedDays.remove(d);
                            }
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: sf.availableFrom,
                          ),
                          value: times.contains(_startTime) ? _startTime : times.first,
                          items: times
                              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _startTime = v);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: sf.availableUntil,
                          ),
                          value: times.contains(_endTime) ? _endTime : times.last,
                          items: times
                              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _endTime = v);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _tags,
                    decoration: InputDecoration(
                      labelText: sf.tagsOptional,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _saving ? null : _submit,
                    child: _saving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_isEdit ? sf.saveChanges : sf.publishSkill),
                  ),
                ],
              ),
            ),
    );
  }
}
