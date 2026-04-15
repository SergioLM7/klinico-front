import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class BarthelCalculatorDialog extends StatefulWidget {
  const BarthelCalculatorDialog({super.key});

  @override
  State<BarthelCalculatorDialog> createState() =>
      _BarthelCalculatorDialogState();
}

class _BarthelCalculatorDialogState extends State<BarthelCalculatorDialog> {
  // Inicializamos todas a null para forzar la selección
  int? _feeding;
  int? _bathing;
  int? _grooming;
  int? _dressing;
  int? _bowels;
  int? _bladder;
  int? _toileting;
  int? _transfers;
  int? _mobility;
  int? _stairs;

  int get _score {
    return (_feeding ?? 0) +
        (_bathing ?? 0) +
        (_grooming ?? 0) +
        (_dressing ?? 0) +
        (_bowels ?? 0) +
        (_bladder ?? 0) +
        (_toileting ?? 0) +
        (_transfers ?? 0) +
        (_mobility ?? 0) +
        (_stairs ?? 0);
  }

  bool get _isComplete {
    return _feeding != null &&
        _bathing != null &&
        _grooming != null &&
        _dressing != null &&
        _bowels != null &&
        _bladder != null &&
        _toileting != null &&
        _transfers != null &&
        _mobility != null &&
        _stairs != null;
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
                        "Escala de Barthel",
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
                          title: "1. Comer",
                          value: _feeding,
                          onChanged: (v) => setState(() => _feeding = v),
                          options: [
                            _Option(
                              10,
                              "Independiente (la comida está al alcance de la mano)",
                            ),
                            _Option(
                              5,
                              "Necesita ayuda para cortar, extender mantequilla, usar condimentos, etc.",
                            ),
                            _Option(0, "Incapaz"),
                          ],
                        ),
                        _buildCategory(
                          title: "2. Traslados silla-cama",
                          value: _transfers,
                          onChanged: (v) => setState(() => _transfers = v),
                          options: [
                            _Option(15, "Independiente"),
                            _Option(
                              10,
                              "Necesita algo de ayuda (una pequeña ayuda física o ayuda verbal)",
                            ),
                            _Option(
                              5,
                              "Necesita ayuda importante (1 persona entrenada o 2 personas), puede estar sentado",
                            ),
                            _Option(0, "Incapaz, no se mantiene sentado"),
                          ],
                        ),
                        _buildCategory(
                          title: "3. Aseo personal",
                          value: _grooming,
                          onChanged: (v) => setState(() => _grooming = v),
                          options: [
                            _Option(
                              5,
                              "Independiente para lavarse la cara, las manos y los dientes, peinarse y afeitarse",
                            ),
                            _Option(0, "Necesita ayuda con el aseo personal"),
                          ],
                        ),
                        _buildCategory(
                          title: "4. Uso del retrete",
                          value: _toileting,
                          onChanged: (v) => setState(() => _toileting = v),
                          options: [
                            _Option(
                              10,
                              "Independiente (entrar y salir, limpiarse y vestirse)",
                            ),
                            _Option(
                              5,
                              "Necesita alguna ayuda, pero puede hacer algo solo",
                            ),
                            _Option(0, "Dependiente"),
                          ],
                        ),
                        _buildCategory(
                          title: "5. Bañarse y ducharse",
                          value: _bathing,
                          onChanged: (v) => setState(() => _bathing = v),
                          options: [
                            _Option(5, "Independiente para bañarse o ducharse"),
                            _Option(0, "Dependiente"),
                          ],
                        ),
                        _buildCategory(
                          title: "6. Desplazarse",
                          value: _mobility,
                          onChanged: (v) => setState(() => _mobility = v),
                          options: [
                            _Option(
                              15,
                              "Independiente al menos 50m, con cualquier tipo de muleta, excepto andador",
                            ),
                            _Option(
                              10,
                              "Anda con pequeña ayuda de una persona (física o verbal)",
                            ),
                            _Option(
                              5,
                              "Independiente en silla de ruedas en 50m",
                            ),
                            _Option(0, "Inmóvil"),
                          ],
                        ),
                        _buildCategory(
                          title: "7. Escaleras",
                          value: _stairs,
                          onChanged: (v) => setState(() => _stairs = v),
                          options: [
                            _Option(10, "Independiente para subir y bajar"),
                            _Option(
                              5,
                              "Necesita ayuda física o verbal, puede llevar cualquier tipo de muleta",
                            ),
                            _Option(0, "Incapaz"),
                          ],
                        ),
                        _buildCategory(
                          title: "8. Vestirse y desvestirse",
                          value: _dressing,
                          onChanged: (v) => setState(() => _dressing = v),
                          options: [
                            _Option(
                              10,
                              "Independiente, incluyendo botones, cremalleras, cordones, etc",
                            ),
                            _Option(
                              5,
                              "Necesita ayuda, pero puede hacer la mitad aproximadamente, sin ayuda",
                            ),
                            _Option(0, "Dependiente"),
                          ],
                        ),
                        _buildCategory(
                          title: "9. Control de heces",
                          value: _bowels,
                          onChanged: (v) => setState(() => _bowels = v),
                          options: [
                            _Option(10, "Continente"),
                            _Option(5, "Accidente excepcional (uno/semana)"),
                            _Option(
                              0,
                              "Incontinente (o necesita que le suministren enema)",
                            ),
                          ],
                        ),
                        _buildCategory(
                          title: "10. Control de orina",
                          value: _bladder,
                          onChanged: (v) => setState(() => _bladder = v),
                          options: [
                            _Option(10, "Continente, durante al menos 7 días"),
                            _Option(
                              5,
                              "Accidente excepcional (máximo uno/24 horas)",
                            ),
                            _Option(
                              0,
                              "Incontinente, o sondado incapaz de cambiarse la bolsa",
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
                    backgroundColor: AppTheme.primaryBlue,
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
                "${opt.points} - ",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              subtitle: Text(
                opt.title,
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
  _Option(this.points, this.title);
}
