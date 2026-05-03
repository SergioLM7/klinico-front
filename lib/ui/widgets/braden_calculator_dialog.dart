import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class BradenCalculatorDialog extends StatefulWidget {
  const BradenCalculatorDialog({super.key});

  @override
  State<BradenCalculatorDialog> createState() => _BradenCalculatorDialogState();
}

class _BradenCalculatorDialogState extends State<BradenCalculatorDialog> {
  // Inicializamos todas a null para forzar la selección
  int? _sensory;
  int? _moisture;
  int? _activity;
  int? _mobility;
  int? _nutrition;
  int? _friction;

  int get _score {
    return (_sensory ?? 0) +
        (_moisture ?? 0) +
        (_activity ?? 0) +
        (_mobility ?? 0) +
        (_nutrition ?? 0) +
        (_friction ?? 0);
  }

  bool get _isComplete {
    return _sensory != null &&
        _moisture != null &&
        _activity != null &&
        _mobility != null &&
        _nutrition != null &&
        _friction != null;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      elevation: 0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 750),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        "Escala de Braden",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black54),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCategory(
                          title: "1. Percepción sensorial",
                          value: _sensory,
                          onChanged: (v) => setState(() => _sensory = v),
                          options: [
                            _Option(
                              4,
                              "Sin alteración",
                              "Responde a órdenes verbales, siente y expresa dolor.",
                            ),
                            _Option(
                              3,
                              "Ligeramente limitada",
                              "Responde pero no siempre comunica malestar, o tiene alteración en 1-2 extremidades.",
                            ),
                            _Option(
                              2,
                              "Muy limitada",
                              "Responde solo al dolor o quejidos, o alteración en la mitad del cuerpo.",
                            ),
                            _Option(
                              1,
                              "Completamente limitada",
                              "No responde a estímulos dolorosos; muy limitada o inconsciente.",
                            ),
                          ],
                        ),
                        _buildCategory(
                          title: "2. Humedad",
                          value: _moisture,
                          onChanged: (v) => setState(() => _moisture = v),
                          options: [
                            _Option(
                              4,
                              "Raramente húmeda",
                              "Piel seca, cambio de ropa habitual.",
                            ),
                            _Option(
                              3,
                              "Ocasionalmente húmeda",
                              "Requiere cambio extra ~1 vez/día.",
                            ),
                            _Option(
                              2,
                              "Muy húmeda",
                              "A menudo húmeda; cambio al menos una vez por turno.",
                            ),
                            _Option(
                              1,
                              "Constantemente húmeda",
                              "Húmeda casi siempre por sudor, orina, etc.",
                            ),
                          ],
                        ),
                        _buildCategory(
                          title: "3. Actividad",
                          value: _activity,
                          onChanged: (v) => setState(() => _activity = v),
                          options: [
                            _Option(
                              4,
                              "Camina con frecuencia",
                              "Camina fuera de habitación ≥2 veces/día y dentro cada 2 horas.",
                            ),
                            _Option(
                              3,
                              "Camina ocasionalmente",
                              "Distancias cortas; pasa mayor parte del turno en cama o silla.",
                            ),
                            _Option(
                              2,
                              "Confinado a la silla",
                              "Incapaz de soportar peso; necesita ayuda para la silla.",
                            ),
                            _Option(
                              1,
                              "Encamado",
                              "Confinado a la cama permanentemente.",
                            ),
                          ],
                        ),
                        _buildCategory(
                          title: "4. Movilidad",
                          value: _mobility,
                          onChanged: (v) => setState(() => _mobility = v),
                          options: [
                            _Option(
                              4,
                              "Sin limitación",
                              "Cambios frecuentes e importantes de cuerpo sin ayuda.",
                            ),
                            _Option(
                              3,
                              "Ligeramente limitada",
                              "Cambios leves pero frecuentes de forma independiente.",
                            ),
                            _Option(
                              2,
                              "Muy limitada",
                              "Cambios ocasionales y leves; no puede por sí solo de forma significativa.",
                            ),
                            _Option(
                              1,
                              "Completamente inmóvil",
                              "Ni siquiera cambios leves sin ayuda.",
                            ),
                          ],
                        ),
                        _buildCategory(
                          title: "5. Nutrición",
                          value: _nutrition,
                          onChanged: (v) => setState(() => _nutrition = v),
                          options: [
                            _Option(
                              4,
                              "Excelente",
                              "Come casi todas las comidas completas. No rechaza, ≥4 raciones proteínas.",
                            ),
                            _Option(
                              3,
                              "Adecuada",
                              "Come más de la mitad; 4 raciones de proteínas. Acepta suplementos / NPT.",
                            ),
                            _Option(
                              2,
                              "Probablemente inadecuada",
                              "Come la mitad; 3 raciones de proteína o fluidoterapia subóptima.",
                            ),
                            _Option(
                              1,
                              "Muy deficiente",
                              "Nunca come comida completa; ≤2 raciones de proteína; ayuno o fluidoterapia >5 días.",
                            ),
                          ],
                        ),
                        _buildCategory(
                          title: "6. Fricción y cizallamiento",
                          value: _friction,
                          onChanged: (v) => setState(() => _friction = v),
                          options: [
                            _Option(
                              3,
                              "Sin problema aparente",
                              "Se mueve en cama/silla independiente con fuerza muscular.",
                            ),
                            _Option(
                              2,
                              "Problema potencial",
                              "Mínima ayuda, la piel resbala poco. Mantiene buena posición.",
                            ),
                            _Option(
                              1,
                              "Problema",
                              "Ayuda moderada a máxima. Imposible sin resbalar piel. Espasticidad.",
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Puntuación total:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      Text(
                        "$_score",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isComplete
                      ? () => Navigator.of(context).pop(_score)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.gradientStart,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade400,
                    disabledForegroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Aplicar Puntuación",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategory({
    required String title,
    required int? value,
    required ValueChanged<int?> onChanged,
    required List<_Option> options,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: value == null,
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
          subtitle: value != null
              ? Text(
                  "Puntuación: $value",
                  style: const TextStyle(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : const Text(
                  "Pendiente",
                  style: TextStyle(color: Colors.redAccent),
                ),
          children: options.map((opt) {
            return RadioListTile<int>(
              contentPadding: const EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 8,
              ),
              title: Text(
                "${opt.points} - ${opt.title}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              subtitle: Text(
                opt.description,
                style: const TextStyle(fontSize: 12, color: Colors.black87),
              ),
              value: opt.points,
              groupValue: value,
              onChanged: (val) {
                onChanged(val);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _Option {
  final int points;
  final String title;
  final String description;
  _Option(this.points, this.title, this.description);
}
