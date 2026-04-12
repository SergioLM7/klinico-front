import 'package:flutter/material.dart';

import '../../data/models/episode_response.dart';
import '../widgets/episode_info_card.dart';
import '../widgets/glass_container.dart';
import '../widgets/gradient_scaffold.dart';

/// Vista de detalle de un episodio (evolución clínica).
class EpisodeDetailView extends StatelessWidget {
  final EpisodeResponse episode;

  const EpisodeDetailView({super.key, required this.episode});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return GradientScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black87,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Detalle de Evolución",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          top:
              MediaQuery.of(context).padding.top +
              kToolbarHeight +
              (isMobile ? 8 : 16),
          left: isMobile ? 16 : 24,
          right: isMobile ? 16 : 24,
          bottom: isMobile ? 24 : 32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Cabecera: Info básica del episodio ──
            EpisodeInfoCard(episode: episode),

            const SizedBox(height: 24),

            // ── Progreso Clínico ──
            const Text(
              "Evolución Clínica",
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
                value: episode.clinicalProgress,
              ),
            ),

            const SizedBox(height: 24),

            // ── Diagnóstico ──
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
                value: episode.diagnosis,
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
