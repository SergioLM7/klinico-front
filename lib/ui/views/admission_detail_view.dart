import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/admission_response.dart';
import '../../data/models/episode_response.dart';
import '../../data/repositories/episode_repository.dart';
import '../viewmodels/episode_viewmodel.dart';
import '../widgets/glass_container.dart';
import '../widgets/gradient_scaffold.dart';

/// Vista de detalle de un ingreso.
/// Recibe el [AdmissionResponse] directamente del dashboard (sin fetch extra).
/// Hace un fetch secundario a /episodes/{admissionId} para los episodios.
class AdmissionDetailView extends StatelessWidget {
  final AdmissionResponse admission;

  const AdmissionDetailView({super.key, required this.admission});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) =>
          EpisodeViewModel(repository: ctx.read<EpisodeRepository>())
            ..loadEpisodes(admission.admissionId),
      child: _AdmissionDetailContent(admission: admission),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Scaffold principal
// ─────────────────────────────────────────────────────────────────────────────
class _AdmissionDetailContent extends StatelessWidget {
  final AdmissionResponse admission;

  const _AdmissionDetailContent({required this.admission});

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
        title: Text(
          "${admission.patient.surname}, ${admission.patient.name}",
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          // Compensa AppBar (altura fija) + notch del sistema
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
            // ── Datos principales del ingreso ──
            _PatientInfoCard(admission: admission),

            const SizedBox(height: 24),

            // ── Sección episodios ──
            const Text(
              "Episodios clínicos",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            const _EpisodeList(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bloque de datos principales del ingreso
// ─────────────────────────────────────────────────────────────────────────────
class _PatientInfoCard extends StatelessWidget {
  final AdmissionResponse admission;

  const _PatientInfoCard({required this.admission});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    final patient = admission.patient;
    final bool isFemale = patient.sex.toUpperCase() == 'F';

    return GlassContainer(
      blur: 15,
      opacity: 0.2,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera: Avatar + nombre + chips
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: isMobile ? 28 : 36,
                  backgroundColor: (isFemale ? Colors.pink : Colors.blue)
                      .withValues(alpha: 0.2),
                  child: Icon(
                    isFemale ? Icons.face_3_rounded : Icons.face_rounded,
                    size: isMobile ? 32 : 40,
                    color: isFemale ? Colors.pink : Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${patient.surname}, ${patient.name}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 18 : 22,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _DiagnosisChip(
                            admission.principalDiagnosis ?? "Sin diagnóstico",
                          ),
                          if (admission.roomNumber != null)
                            _InfoChip(
                              icon: Icons.door_front_door_outlined,
                              label: "Hab. ${admission.roomNumber}",
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

            // Grid de datos clínicos
            _InfoGrid(isMobile: isMobile, admission: admission),

            // Campos de texto largo
            if (admission.medicalHistory != null) ...[
              const SizedBox(height: 16),
              _LongTextField(
                label: "Antecedentes clínicos",
                value: admission.medicalHistory!,
              ),
            ],
            if (admission.chronicTreatment != null) ...[
              const SizedBox(height: 12),
              _LongTextField(
                label: "Tratamiento crónico",
                value: admission.chronicTreatment!,
              ),
            ],
            if (admission.allergies != null) ...[
              const SizedBox(height: 12),
              _LongTextField(label: "Alergias", value: admission.allergies!),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Grid de datos clínicos (Wrap de tiles)
// ─────────────────────────────────────────────────────────────────────────────
class _InfoGrid extends StatelessWidget {
  final bool isMobile;
  final AdmissionResponse admission;

  const _InfoGrid({required this.isMobile, required this.admission});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _DataTile(
          icon: Icons.cake_outlined,
          label: "Edad",
          value: "${admission.patient.age} años",
        ),
        _DataTile(
          icon: Icons.wc_rounded,
          label: "Sexo",
          value: admission.patient.sex.toUpperCase() == 'F'
              ? "Femenino"
              : "Masculino",
        ),
        if (admission.basalBarthel != null)
          _DataTile(
            icon: Icons.accessibility_new_rounded,
            label: "Barthel basal",
            value: "${admission.basalBarthel}",
          ),
        if (admission.hospitalizationLength != null)
          _DataTile(
            icon: Icons.hotel_rounded,
            label: "Días ingresado",
            value: "${admission.hospitalizationLength}",
          ),
        _DataTile(
          icon: Icons.calendar_today_rounded,
          label: "Ingresado el",
          value: _formatDate(admission.createdAt),
        ),
        if (admission.dischargeDate != null)
          _DataTile(
            icon: Icons.exit_to_app_rounded,
            label: "Alta el",
            value: _formatDate(admission.dischargeDate!),
          ),
      ],
    );
  }

  String _formatDate(DateTime dt) =>
      "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
}

// ─────────────────────────────────────────────────────────────────────────────
// Tile compacto de dato clínico
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
// Campo de texto largo (antecedentes, tratamiento, alergias)
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
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chips decorativos
// ─────────────────────────────────────────────────────────────────────────────
class _DiagnosisChip extends StatelessWidget {
  final String label;

  const _DiagnosisChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF4C56AF).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF4C56AF).withValues(alpha: 0.35),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF4C56AF),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

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
// Lista de tarjetas de episodios
// ─────────────────────────────────────────────────────────────────────────────
class _EpisodeList extends StatelessWidget {
  const _EpisodeList();

  @override
  Widget build(BuildContext context) {
    return Consumer<EpisodeViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (vm.errorMessage != null) {
          return Center(
            child: Text(
              vm.errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        if (vm.episodes.isEmpty) {
          return const Center(
            child: Text(
              "No hay episodios registrados.",
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
          );
        }

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: vm.episodes
              .map((episode) => _EpisodeCard(episode: episode))
              .toList(),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mini-tarjeta de episodio (solo muestra la fecha del createdAt)
// ─────────────────────────────────────────────────────────────────────────────
class _EpisodeCard extends StatelessWidget {
  final EpisodeResponse episode;

  const _EpisodeCard({required this.episode});

  @override
  Widget build(BuildContext context) {
    final dt = episode.createdAt;
    final dateStr =
        "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
    final timeStr =
        "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";

    return GlassContainer(
      blur: 10,
      opacity: 0.15,
      borderRadius: BorderRadius.circular(14),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            // TODO: Navegar al detalle del episodio
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4C56AF).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.medical_services_outlined,
                    size: 20,
                    color: Color(0xFF4C56AF),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Evolución",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      "$dateStr · $timeStr",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: Colors.black38,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
