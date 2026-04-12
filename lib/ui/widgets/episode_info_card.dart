import 'package:flutter/material.dart';

import '../../data/models/episode_response.dart';
import 'glass_container.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Tarjeta de información principal del episodio
// ─────────────────────────────────────────────────────────────────────────────
class EpisodeInfoCard extends StatelessWidget {
  final EpisodeResponse episode;

  const EpisodeInfoCard({super.key, required this.episode});

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
                  backgroundColor: const Color(
                    0xFF4C56AF,
                  ).withValues(alpha: 0.15),
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
        _DataTile(
          icon: Icons.health_and_safety_outlined,
          label: "Escala Braden",
          value: "${episode.bradenScore ?? "No realizado"}",
        ),
        if (episode.camScore != null)
          _DataTile(
            icon: Icons.psychology_outlined,
            label: "CAM",
            value: episode.camScore == true ? "Positivo" : "Negativo",
          )
        else
          _DataTile(
            icon: Icons.psychology_outlined,
            label: "CAM",
            value: "No realizado",
          ),
        _DataTile(
          icon: Icons.favorite_border_rounded,
          label: "CHADS2",
          value: "${episode.chads2Score ?? "No realizado"}",
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
