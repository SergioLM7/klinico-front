import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class CamCalculatorDialog extends StatefulWidget {
  const CamCalculatorDialog({super.key});

  @override
  State<CamCalculatorDialog> createState() => _CamCalculatorDialogState();
}

class _CamCalculatorDialogState extends State<CamCalculatorDialog> {
  // Estado de cada criterio (null = no contestado, true = sí, false = no)
  bool? _criterio1; // 1) Inicio agudo y fluctuante
  bool? _criterio2; // 2) Inatención
  bool? _criterio3; // 3) Pensamiento desorganizado
  int? _criterio4; // 4) Nivel de conciencia (1=Normal, 2-5=Anormal)

  bool get _isComplete {
    return _criterio1 != null &&
        _criterio2 != null &&
        _criterio3 != null &&
        _criterio4 != null;
  }

  bool get _calculateCamResult {
    // CAM requiere la presencia del 1 y el 2 MÁS el 3 o el 4
    final bool c1 = _criterio1 ?? false;
    final bool c2 = _criterio2 ?? false;
    final bool c3 = _criterio3 ?? false;

    // El criterio 4 es positivo si es diferente de 1 (Alerta Normal)
    final bool c4Positivo = (_criterio4 != null && _criterio4 != 1);

    return c1 && c2 && (c3 || c4Positivo);
  }

  @override
  Widget build(BuildContext context) {
    // Calculamos el resultado en vivo si está todo respondido
    final bool? isPositive = _isComplete ? _calculateCamResult : null;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      elevation: 0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 550, maxHeight: 750),
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
                        "Método CAM (Delirium)",
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
                        _buildYesNoQuestion(
                          title: "1. Inicio agudo y curso fluctuante",
                          description:
                              "¿Evidencia de un cambio agudo del estado mental? O ¿Han fluctuado sus cambios de conducta?",
                          value: _criterio1,
                          onChanged: (v) => setState(() => _criterio1 = v),
                        ),
                        const SizedBox(height: 16),
                        _buildYesNoQuestion(
                          title: "2. Inatención",
                          description:
                              "¿Dificultad para fijar atención, se distrae fácilmente, conversación difícil de mantener o irrelevante?",
                          value: _criterio2,
                          onChanged: (v) => setState(() => _criterio2 = v),
                        ),
                        const SizedBox(height: 16),
                        _buildYesNoQuestion(
                          title: "3. Pensamiento desorganizado",
                          description:
                              "¿Discurso incoherente, ideas ilógicas, o cambios de tema impredecibles?",
                          value: _criterio3,
                          onChanged: (v) => setState(() => _criterio3 = v),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "4. Nivel de Conciencia",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                "¿Qué nivel de conciencia presenta el paciente?",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildRadio<int>(
                                "Alerta (Normal)",
                                1,
                                _criterio4,
                                (v) => setState(() => _criterio4 = v),
                              ),
                              _buildRadio<int>(
                                "Vigilante (Hiperalerta)",
                                2,
                                _criterio4,
                                (v) => setState(() => _criterio4 = v),
                              ),
                              _buildRadio<int>(
                                "Letárgico (Inhibido, somnoliento)",
                                3,
                                _criterio4,
                                (v) => setState(() => _criterio4 = v),
                              ),
                              _buildRadio<int>(
                                "Estuporoso (Difícil despertarlo)",
                                4,
                                _criterio4,
                                (v) => setState(() => _criterio4 = v),
                              ),
                              _buildRadio<int>(
                                "Comatoso (No se despierta)",
                                5,
                                _criterio4,
                                (v) => setState(() => _criterio4 = v),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isPositive == null
                        ? Colors.grey.shade200.withValues(alpha: 0.5)
                        : (isPositive
                              ? Colors.redAccent.withValues(alpha: 0.15)
                              : Colors.green.withValues(alpha: 0.15)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isPositive == null
                          ? Colors.grey.shade400
                          : (isPositive ? Colors.redAccent : Colors.green),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isPositive == null
                            ? Icons.pending_actions
                            : (isPositive
                                  ? Icons.warning_rounded
                                  : Icons.check_circle_rounded),
                        color: isPositive == null
                            ? Colors.black54
                            : (isPositive ? Colors.redAccent : Colors.green),
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Resultado CAM:",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              isPositive == null
                                  ? "Rellene el test..."
                                  : (isPositive
                                        ? "Positivo (Sospecha de Delirium)"
                                        : "Negativo"),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isPositive == null
                                    ? Colors.black87
                                    : (isPositive
                                          ? Colors.redAccent
                                          : Colors.green),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isComplete
                      ? () => Navigator.of(context).pop(isPositive)
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

  Widget _buildYesNoQuestion({
    required String title,
    required String description,
    required bool? value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: RadioListTile<bool>(
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  title: const Text("Sí"),
                  value: true,
                  groupValue: value,
                  onChanged: onChanged,
                ),
              ),
              Expanded(
                child: RadioListTile<bool>(
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  title: const Text("No"),
                  value: false,
                  groupValue: value,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRadio<T>(
    String title,
    T value,
    T? groupValue,
    ValueChanged<T?> onChanged,
  ) {
    return RadioListTile<T>(
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      title: Text(title, style: const TextStyle(fontSize: 14)),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
    );
  }
}
