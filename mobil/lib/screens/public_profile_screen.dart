import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../api/user_api.dart';
import '../app/app_state.dart';

class PublicProfileScreen extends StatefulWidget {
  const PublicProfileScreen({
    super.key,
    required this.appState,
    required this.userId,
  });

  final AppState appState;
  final String userId;

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  PublicUserProfileDto? _profile;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final t = widget.appState.token;
    if (t == null || t.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Not signed in';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final p = await fetchPublicUserProfile(token: t, userId: widget.userId);
      if (!mounted) return;
      setState(() {
        _profile = p;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Member profile')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(_error!, textAlign: TextAlign.center),
              ),
            )
          : _profile == null
          ? const SizedBox.shrink()
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  CircleAvatar(
                    radius: 40,
                    child: Text(
                      _profile!.fullName.isNotEmpty
                          ? _profile!.fullName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _profile!.fullName,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (_profile!.location != null &&
                      _profile!.location!.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      _profile!.location!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    'Rating: ${_profile!.averageRating.toStringAsFixed(1)} (${_profile!.totalReviews} reviews)',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  if (_profile!.bio != null && _profile!.bio!.trim().isNotEmpty)
                    Text(
                      _profile!.bio!,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        height: 1.45,
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
