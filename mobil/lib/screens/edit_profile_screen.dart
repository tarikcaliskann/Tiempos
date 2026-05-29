import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import '../api/api_exception.dart';
import '../api/user_api.dart';
import '../app/app_state.dart';
import '../data/profile_picklists.dart';
import '../language/profile_l10n.dart';
import '../widgets/searchable_profile_combobox.dart';
import '../widgets/app_chrome.dart';

const _maxAvatarBytes = 4 * 1024 * 1024;
const _jpegMaxSide = 512;
const _jpegQuality = 88;

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullName;
  late final TextEditingController _emailDisplay;
  late final TextEditingController _bio;
  late final TextEditingController _location;
  late final TextEditingController _phone;
  late final TextEditingController _languages;
  late final TextEditingController _website;
  late final TextEditingController _linkedin;
  late final TextEditingController _twitter;

  String? _avatarUrl;
  String? _avatarError;
  bool _loading = true;
  bool _saving = false;
  String? _loadError;
  ProfilePicklists? _picklists;

  @override
  void initState() {
    super.initState();
    _fullName = TextEditingController(text: widget.appState.fullName ?? '');
    _emailDisplay = TextEditingController(text: widget.appState.email ?? '');
    _bio = TextEditingController();
    _location = TextEditingController();
    _phone = TextEditingController();
    _languages = TextEditingController();
    _website = TextEditingController();
    _linkedin = TextEditingController();
    _twitter = TextEditingController();
    _load();
  }

  @override
  void dispose() {
    _fullName.dispose();
    _emailDisplay.dispose();
    _bio.dispose();
    _location.dispose();
    _phone.dispose();
    _languages.dispose();
    _website.dispose();
    _linkedin.dispose();
    _twitter.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final t = widget.appState.token;
    if (t == null) {
      setState(() => _loading = false);
      return;
    }
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final p = await fetchMyProfile(t);
      ProfilePicklists? pl;
      try {
        pl = await ProfilePicklists.load();
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        _picklists = pl;
        _fullName.text = p.fullName.trim().isNotEmpty ? p.fullName : (widget.appState.fullName ?? '');
        _emailDisplay.text = p.email.trim().isNotEmpty ? p.email : (widget.appState.email ?? '');
        _bio.text = p.bio?.trim() ?? '';
        _location.text = p.location?.trim() ?? '';
        _phone.text = p.phone?.trim() ?? '';
        _languages.text = p.languages?.trim() ?? '';
        _website.text = p.website?.trim() ?? '';
        _linkedin.text = p.linkedin?.trim() ?? '';
        _twitter.text = p.twitter?.trim() ?? '';
        _avatarUrl = p.avatarUrl?.trim().isNotEmpty == true ? p.avatarUrl : null;
        _avatarError = null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = '$e';
        _loading = false;
      });
    }
  }

  String? _bytesToJpegDataUrl(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return null;
    var out = decoded;
    final w = decoded.width;
    final h = decoded.height;
    if (w > _jpegMaxSide || h > _jpegMaxSide) {
      if (w >= h) {
        out = img.copyResize(decoded, width: _jpegMaxSide, interpolation: img.Interpolation.linear);
      } else {
        out = img.copyResize(decoded, height: _jpegMaxSide, interpolation: img.Interpolation.linear);
      }
    }
    final jpg = img.encodeJpg(out, quality: _jpegQuality);
    return 'data:image/jpeg;base64,${base64Encode(jpg)}';
  }

  Future<void> _pickPhoto(ProfileL10n l10n) async {
    setState(() => _avatarError = null);
    try {
      final x = await ImagePicker().pickImage(
        source: kIsWeb ? ImageSource.gallery : ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
      );
      if (x == null) return;
      final bytes = await x.readAsBytes();
      if (bytes.length > _maxAvatarBytes) {
        setState(() => _avatarError = l10n.photoTooLarge);
        return;
      }
      final dataUrl = _bytesToJpegDataUrl(bytes);
      if (!mounted) return;
      if (dataUrl == null) {
        setState(() => _avatarError = l10n.photoInvalid);
        return;
      }
      setState(() {
        _avatarUrl = dataUrl;
        _avatarError = null;
      });
    } catch (_) {
      if (mounted) setState(() => _avatarError = l10n.photoInvalid);
    }
  }

  void _removePhoto() {
    setState(() {
      _avatarUrl = null;
      _avatarError = null;
    });
  }

  Future<void> _save(ProfileL10n l10n) async {
    if (!_formKey.currentState!.validate()) return;
    final t = widget.appState.token;
    if (t == null) return;
    setState(() => _saving = true);
    try {
      final saved = await updateMyProfile(
        token: t,
        fullName: _fullName.text.trim(),
        bio: _bio.text.trim().isEmpty ? null : _bio.text.trim(),
        phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
        location: _location.text.trim().isEmpty ? null : _location.text.trim(),
        languages: _languages.text.trim().isEmpty ? null : _languages.text.trim(),
        website: _website.text.trim().isEmpty ? null : _website.text.trim(),
        linkedin: _linkedin.text.trim().isEmpty ? null : _linkedin.text.trim(),
        twitter: _twitter.text.trim().isEmpty ? null : _twitter.text.trim(),
        avatarUrl: _avatarUrl,
      );
      await widget.appState.applyProfileDisplayName(saved.fullName);
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.saveFailed)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _avatarPreview(ProfileL10n l10n, ThemeData theme) {
    final url = _avatarUrl?.trim();
    Widget child;
    if (url != null && url.isNotEmpty) {
      if (url.startsWith('data:')) {
        final comma = url.indexOf(',');
        if (comma > 0) {
          try {
            final b64 = url.substring(comma + 1);
            child = Image.memory(
              base64Decode(b64),
              fit: BoxFit.cover,
              gaplessPlayback: true,
            );
          } catch (_) {
            child = _initialsAvatar(theme);
          }
        } else {
          child = _initialsAvatar(theme);
        }
      } else {
        child = Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _initialsAvatar(theme),
        );
      }
    } else {
      child = _initialsAvatar(theme);
    }
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(64),
          child: SizedBox(
            width: 128,
            height: 128,
            child: child,
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: Material(
            color: theme.colorScheme.primary,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _saving ? null : () => _pickPhoto(l10n),
              child: SizedBox(
                width: 40,
                height: 40,
                child: Icon(Icons.photo_camera_rounded, color: theme.colorScheme.onPrimary, size: 22),
              ),
            ),
          ),
        ),
        if (url != null && url.isNotEmpty)
          Positioned(
            bottom: 0,
            right: 0,
            child: Material(
              color: theme.colorScheme.surface,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _saving ? null : _removePhoto,
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error, size: 22),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _initialsAvatar(ThemeData theme) {
    final name = _fullName.text.trim().isNotEmpty ? _fullName.text : (widget.appState.fullName ?? '?');
    final parts = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    final String initials;
    if (parts.length >= 2) {
      initials = '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    } else if (parts.isEmpty) {
      initials = '?';
    } else if (parts.first.length >= 2) {
      initials = parts.first.substring(0, 2).toUpperCase();
    } else {
      initials = parts.first[0].toUpperCase();
    }
    return ColoredBox(
      color: theme.colorScheme.primary.withValues(alpha: 0.85),
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.inter(
            fontSize: 40,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = ProfileL10n.of(context);
    final tr = Localizations.localeOf(context).languageCode.toLowerCase().startsWith('tr');

    return Scaffold(
      appBar: AppChrome.gradientAppBar(title: l10n.editProfileTitle),
      body: _loading
          ? Center(child: Text(l10n.loading))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.editProfileSubtitle,
                      style: GoogleFonts.inter(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                    if (_loadError != null) ...[
                      const SizedBox(height: 12),
                      Text(_loadError!, style: TextStyle(color: theme.colorScheme.error)),
                    ],
                    const SizedBox(height: 24),
                    Center(child: _avatarPreview(l10n, theme)),
                    if (_avatarError != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _avatarError!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: theme.colorScheme.error, fontSize: 13),
                      ),
                    ],
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _fullName,
                      decoration: InputDecoration(labelText: l10n.fullNameLabel, border: const OutlineInputBorder()),
                      textCapitalization: TextCapitalization.words,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return l10n.fullNameLabel;
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailDisplay,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: l10n.emailLabel,
                        border: const OutlineInputBorder(),
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _bio,
                      decoration: InputDecoration(
                        labelText: l10n.bioLabel,
                        hintText: l10n.bioHint,
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),
                    if (_picklists != null) ...[
                      SearchableProfileCombobox(
                        label: l10n.locationLabel,
                        value: _location.text,
                        onChanged: (v) => setState(() => _location.text = v),
                        options: mergeLegacyOption(_picklists!.locationOptions(), _location.text),
                        placeholder: l10n.locationHint,
                        searchPlaceholder: l10n.picklistSearch,
                        emptyText: l10n.picklistEmpty,
                      ),
                      const SizedBox(height: 16),
                    ] else ...[
                      TextFormField(
                        controller: _location,
                        decoration: InputDecoration(
                          labelText: l10n.locationLabel,
                          hintText: l10n.locationHint,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: _phone,
                      decoration: InputDecoration(
                        labelText: l10n.phoneLabel,
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    if (_picklists != null) ...[
                      SearchableProfileCombobox(
                        label: l10n.languagesLabel,
                        value: _languages.text,
                        onChanged: (v) => setState(() => _languages.text = v),
                        options: mergeLegacyOption(_picklists!.languageOptions(tr), _languages.text),
                        placeholder: l10n.languagesHint,
                        searchPlaceholder: l10n.picklistSearch,
                        emptyText: l10n.picklistEmpty,
                      ),
                      const SizedBox(height: 16),
                    ] else ...[
                      TextFormField(
                        controller: _languages,
                        decoration: InputDecoration(
                          labelText: l10n.languagesLabel,
                          hintText: l10n.languagesHint,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: _website,
                      decoration: InputDecoration(
                        labelText: l10n.websiteLabel,
                        hintText: l10n.websiteHint,
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _linkedin,
                      decoration: InputDecoration(
                        labelText: l10n.linkedinLabel,
                        hintText: l10n.linkedinHint,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _twitter,
                      decoration: InputDecoration(
                        labelText: l10n.twitterLabel,
                        hintText: l10n.twitterHint,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _saving ? null : () => Navigator.of(context).pop(false),
                            child: Text(l10n.cancel),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: FilledButton(
                            onPressed: _saving ? null : () => _save(l10n),
                            child: _saving
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Text(l10n.saveChanges),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
