import 'package:flutter/material.dart';

import '../../data/models/admission_response.dart';
import '../views/admission_detail_view.dart';
import 'glass_container.dart';

class AdmissionCard extends StatelessWidget {
  final AdmissionResponse admission;

  const AdmissionCard({super.key, required this.admission});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      opacity: 0.15,
      blur: 15.0,
      borderRadius: BorderRadius.circular(20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AdmissionDetailView(admission: admission),
              ),
            );
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool isSmallCard = constraints.maxWidth < 300;
              final patient = admission.patient;
              final bool isFemale = patient.sex.toUpperCase() == 'F';

              return Padding(
                padding: EdgeInsets.all(isSmallCard ? 8.0 : 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor:
                              (isFemale ? Colors.pink : Colors.blue).withValues(
                                alpha: 0.2,
                              ),
                          radius: isSmallCard ? 16 : 20,
                          child: Icon(
                            isFemale
                                ? Icons.face_3_rounded
                                : Icons.face_rounded,
                            size: isSmallCard ? 18 : 24,
                            color: isFemale ? Colors.pink : Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${patient.surname}, ${patient.name}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallCard ? 14 : 16,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Edad: ${patient.age}",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: isSmallCard ? 11 : 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      admission.roomNumber != null
                          ? "Habitación: ${admission.roomNumber}"
                          : "Pend. habitación",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: isSmallCard ? 11 : 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Nº HC: ${patient.patientId}",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: isSmallCard ? 11 : 13,
                      ),
                      maxLines: isSmallCard ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(
                              255,
                              76,
                              86,
                              175,
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color.fromARGB(
                                255,
                                76,
                                86,
                                175,
                              ).withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            admission.principalDiagnosis ?? "Sin diagnóstico",
                            maxLines: 1,
                            style: TextStyle(
                              color: const Color.fromARGB(255, 76, 86, 175),
                              fontSize: isSmallCard ? 10 : 12,
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
