import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/episode_response.dart';
import '../../widgets/episode_info_card.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/gradient_scaffold.dart';
import '../../widgets/scale_button.dart';

/// Vista de detalle de un episodio (evolución clínica).
class EpisodeDetailView extends StatefulWidget {
  final EpisodeResponse episode;

  const EpisodeDetailView({super.key, required this.episode});

  @override
  State<EpisodeDetailView> createState() => _EpisodeDetailViewState();
}

class _EpisodeDetailViewState extends State<EpisodeDetailView> {
  late bool _canEdit;
  late EpisodeResponse _episode;

  @override
  void initState() {
    super.initState();
    _episode = widget.episode;
    // El episodio es editable solo si se creó hace menos de 2 horas.
    final now = DateTime.now();
    final diff = now.difference(_episode.createdAt);
    _canEdit = diff.inMinutes < 120;
  }

  void _onEpisodeUpdated(EpisodeResponse updated) {
    setState(() {
      _episode = updated;
      final now = DateTime.now();
      final diff = now.difference(_episode.createdAt);
      _canEdit = diff.inMinutes < 120;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return GradientScaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + (isMobile ? 16.0 : 32.0),
          left: isMobile ? 16.0 : 32.0,
          right: isMobile ? 16.0 : 32.0,
          bottom: isMobile ? 24.0 : 32.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom Header with Back Button
            Row(
              children: [
                ScaleButton(
                  onTap: () => Navigator.of(context).pop(),
                  child: GlassContainer(
                    blur: 10,
                    opacity: 0.2,
                    borderRadius: BorderRadius.circular(50),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(50),
                        splashColor: AppTheme.primaryBlue.withValues(
                          alpha: 0.3,
                        ),
                        highlightColor: AppTheme.primaryBlue.withValues(
                          alpha: 0.1,
                        ),
                        child: const Tooltip(
                          message: "Volver",
                          child: Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    "Detalle de evolución",
                    style: TextStyle(
                      fontSize: isMobile ? 20 : 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),

            SingleChildScrollView(
              padding: EdgeInsets.only(
                top: 16,
                left: isMobile ? 16 : 24,
                right: isMobile ? 16 : 24,
                bottom: isMobile ? 24 : 32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Cabecera: Info básica del episodio ──
                  EpisodeInfoCard(
                    episode: _episode,
                    canEdit: _canEdit,
                    onEpisodeUpdated: _onEpisodeUpdated,
                  ),

                  const SizedBox(height: 24),

                  //Evolución clínica
                  const Text(
                    "Evolución clínica",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GlassContainer(
                    blur: 15,
                    opacity: 0.2,
                    borderRadius: BorderRadius.circular(20),
                    padding: EdgeInsets.all(isMobile ? 16 : 24),
                    child: _LongTextField(
                      label: "Descripción del progreso",
                      value: _episode.clinicalProgress,
                    ),
                  ),

                  const SizedBox(height: 24),

                  //Diagnóstico
                  const Text(
                    "Diagnóstico",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GlassContainer(
                    blur: 15,
                    opacity: 0.2,
                    borderRadius: BorderRadius.circular(20),
                    padding: EdgeInsets.all(isMobile ? 16 : 24),
                    child: _LongTextField(
                      label: "Diagnóstico médico",
                      value: _episode.diagnosis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Campo de texto largo
// ─────────────────────────────────────────────────────────────────────────────
class _LongTextField extends StatelessWidget {
  final String label;
  final String value;

  const _LongTextField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value.isEmpty ? "Sin información" : value,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            height: 1.5, // Mejor legibilidad para textos largos
          ),
        ),
      ],
    );
  }
}
