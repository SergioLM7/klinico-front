import 'package:flutter/material.dart';

import '../../data/models/episode_response.dart';
import '../widgets/glass_container.dart';
import '../widgets/gradient_scaffold.dart';

/// Vista de detalle de un episodio (evolución clínica).
class EpisodeDetailView extends StatelessWidget {
  final EpisodeResponse episode;

  const EpisodeDetailView({super.key, required this.episode});

  String _formatDate(DateTime dt) {
    return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
  }

  String _formatTime(DateTime dt) {
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return GradientScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
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
          top: MediaQuery.of(context).padding.top + kToolbarHeight + (isMobile ? 8 : 16),
          left: isMobile ? 16 : 24,
          right: isMobile ? 16 : 24,
          bottom: isMobile ? 24 : 32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Cabecera: Info básica del episodio ──
            _EpisodeInfoCard(episode: episode),
            
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
// Tarjeta de información principal del episodio
// ─────────────────────────────────────────────────────────────────────────────
class _EpisodeInfoCard extends StatelessWidget {
  final EpisodeResponse episode;

  const _EpisodeInfoCard({required this.episode});

  String _formatDate(DateTime dt) {
    return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
  }

  String _formatTime(DateTime dt) {
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return GlassContainer(
      blur: 15,
      opacity: 0.2,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: isMobile ? 24 : 32,
                  backgroundColor: const Color(0xFF4C56AF).withValues(alpha: 0.15),
                  child: Icon(
                    Icons.medical_information_rounded,
                    size: isMobile ? 28 : 36,
                    color: const Color(0xFF4C56AF),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Registro Médico",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Creado por: ${episode.createdBy}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _InfoChip(
                            icon: Icons.calendar_today_rounded,
                            label: _formatDate(episode.createdAt),
                          ),
                          _InfoChip(
                            icon: Icons.access_time_rounded,
                            label: _formatTime(episode.createdAt),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Divider(color: Colors.black12),
            const SizedBox(height: 16),

            // Grid de escalas clínicas
            _ScoresGrid(isMobile: isMobile, episode: episode),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Grid de escalas clínicas
// ─────────────────────────────────────────────────────────────────────────────
class _ScoresGrid extends StatelessWidget {
  final bool isMobile;
  final EpisodeResponse episode;

  const _ScoresGrid({required this.isMobile, required this.episode});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        if (episode.bradenScore != null)
          _DataTile(
            icon: Icons.health_and_safety_outlined,
            label: "Escala Braden",
            value: "${episode.bradenScore}",
          ),
        if (episode.camScore != null)
          _DataTile(
            icon: Icons.psychology_outlined,
            label: "CAM",
            value: episode.camScore == true ? "Positivo" : "Negativo",
          ),
        if (episode.chads2Score != null)
          _DataTile(
            icon: Icons.favorite_border_rounded,
            label: "CHADS2",
            value: "${episode.chads2Score}",
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tile compacto para escalas y datos numéricos
// ─────────────────────────────────────────────────────────────────────────────
class _DataTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DataTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF4C56AF)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Colors.black54),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chip informativo
// ─────────────────────────────────────────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.black54),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
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
