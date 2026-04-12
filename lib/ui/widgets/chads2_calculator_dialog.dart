import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class Chads2CalculatorDialog extends StatefulWidget {
  const Chads2CalculatorDialog({super.key});

  @override
  State<Chads2CalculatorDialog> createState() => _Chads2CalculatorDialogState();
}

class _Chads2CalculatorDialogState extends State<Chads2CalculatorDialog> {
  // Checkboxes state
  bool _chf = false; // Insuficiencia cardiaca congestiva (1)
  bool _htn = false; // Hipertensión arterial (1)
  bool _dm = false; // Diabetes mellitus (1)
  bool _stroke = false; // Antecedentes de ictus, AIT o tromboembolismo (2)
  bool _vascular = false; // Enfermedad vascular (1)

  // Edad (0, 1, 2)
  int _ageScore = 0;

  // Sexo (Hombre 0, Mujer 1)
  int _sexScore = 0;

  int _calculateScore() {
    int score = 0;
    if (_chf) score += 1;
    if (_htn) score += 1;
    if (_dm) score += 1;
    if (_stroke) score += 2;
    if (_vascular) score += 1;
    score += _ageScore;
    score += _sexScore;
    return score;
  }

  @override
  Widget build(BuildContext context) {
    final score = _calculateScore();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      elevation: 0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450, maxHeight: 650),
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
                        "Calculadora CHA2DS2-VASc",
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
                        const SizedBox(height: 8),
                        _buildSectionTitle("Características Clínicas"),
                        _buildCheckbox(
                          "Insuficiencia cardiaca / Disfunción del VI",
                          _chf,
                          1,
                          (v) => setState(() => _chf = v!),
                        ),
                        _buildCheckbox(
                          "Hipertensión arterial",
                          _htn,
                          1,
                          (v) => setState(() => _htn = v!),
                        ),
                        _buildCheckbox(
                          "Diabetes mellitus",
                          _dm,
                          1,
                          (v) => setState(() => _dm = v!),
                        ),
                        _buildCheckbox(
                          "Antecedentes de ictus, AIT o tromboembolismo",
                          _stroke,
                          2,
                          (v) => setState(() => _stroke = v!),
                        ),
                        _buildCheckbox(
                          "Enfermedad vascular",
                          _vascular,
                          1,
                          (v) => setState(() => _vascular = v!),
                        ),

                        const SizedBox(height: 16),
                        _buildSectionTitle("Edad"),
                        _buildRadio<int>(
                          "Menor de 65 años",
                          0,
                          _ageScore,
                          (v) => setState(() => _ageScore = v!),
                        ),
                        _buildRadio<int>(
                          "Entre 65 y 74 años (1 punto)",
                          1,
                          _ageScore,
                          (v) => setState(() => _ageScore = v!),
                        ),
                        _buildRadio<int>(
                          "Mayor o igual a 75 años (2 puntos)",
                          2,
                          _ageScore,
                          (v) => setState(() => _ageScore = v!),
                        ),

                        const SizedBox(height: 16),
                        _buildSectionTitle("Sexo"),
                        _buildRadio<int>(
                          "Hombre (0 puntos)",
                          0,
                          _sexScore,
                          (v) => setState(() => _sexScore = v!),
                        ),
                        _buildRadio<int>(
                          "Mujer (1 punto)",
                          1,
                          _sexScore,
                          (v) => setState(() => _sexScore = v!),
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
                        "$score",
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
                  onPressed: () => Navigator.of(context).pop(score),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget _buildCheckbox(
    String title,
    bool value,
    int points,
    ValueChanged<bool?> onChanged,
  ) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(title, style: const TextStyle(fontSize: 14)),
      subtitle: Text(
        "+$points punto${points > 1 ? 's' : ''}",
        style: TextStyle(
          fontSize: 12,
          color: AppTheme.primaryBlue.withValues(alpha: 0.7),
        ),
      ),
      value: value,
      onChanged: onChanged,
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
