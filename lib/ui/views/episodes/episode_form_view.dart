import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../viewmodels/episode_viewmodel.dart';
import '../../viewmodels/login_viewmodel.dart';
import '../../widgets/braden_calculator_dialog.dart';
import '../../widgets/cam_calculator_dialog.dart';
import '../../widgets/chads2_calculator_dialog.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/gradient_scaffold.dart';
import '../../widgets/scale_button.dart';

class EpisodeFormView extends StatefulWidget {
  final String admissionId;

  const EpisodeFormView({super.key, required this.admissionId});

  @override
  State<EpisodeFormView> createState() => _EpisodeFormViewState();
}

class _EpisodeFormViewState extends State<EpisodeFormView> {
  final _formKey = GlobalKey<FormState>();
  final _clinicalProgressController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _bradenScoreController = TextEditingController();
  final _chads2ScoreController = TextEditingController();

  bool? _camScore;
  bool _isLoading = false;

  @override
  void dispose() {
    _clinicalProgressController.dispose();
    _diagnosisController.dispose();
    _bradenScoreController.dispose();
    _chads2ScoreController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus(); // Ocultar teclado

    setState(() {
      _isLoading = true;
    });

    final viewModel = context.read<EpisodeViewModel>();
    final loginVM = context.read<LoginViewModel>();
    final currentUserId = loginVM.userId ?? "";

    final success = await viewModel.createEpisode(
      admissionId: widget.admissionId,
      doctorId: currentUserId,
      clinicalProgress: _clinicalProgressController.text,
      diagnosis: _diagnosisController.text,
      bradenScore: int.tryParse(_bradenScoreController.text),
      chads2Score: int.tryParse(_chads2ScoreController.text),
      camScore: _camScore,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      showDialog(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.05),
        barrierDismissible: false,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 320),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      success
                          ? Icons.check_circle_outline_rounded
                          : Icons.error_outline_rounded,
                      color: success
                          ? const Color(0xFF4CAF50)
                          : Colors.redAccent,
                      size: 56,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      success ? "¡Excelente!" : "Error",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      success
                          ? "Episodio creado exitosamente"
                          : (viewModel.errorMessage ?? "Error desconocido"),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.gradientStart,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(); // Cierra el pop-up
                          if (success) {
                            Navigator.of(
                              context,
                            ).pop(success); // Vuelve a admission_detail_view
                          }
                        },
                        child: const Text(
                          "Aceptar",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
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
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      splashColor: AppTheme.primaryBlue.withValues(alpha: 0.3),
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
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    "Nuevo episodio clínico",
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
            SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GlassContainer(
                      blur: 15,
                      opacity: 0.2,
                      borderRadius: BorderRadius.circular(20),
                      padding: EdgeInsets.all(isMobile ? 16 : 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Información principal",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _clinicalProgressController,
                            label: "Progreso clínico*",
                            hint: "Describa la evolución del paciente...",
                            maxLines: 4,
                            validator: (value) => value == null || value.isEmpty
                                ? "Requerido"
                                : null,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _diagnosisController,
                            label: "Diagnóstico*",
                            hint: "Indique el diagnóstico...",
                            maxLines: 2,
                            validator: (value) => value == null || value.isEmpty
                                ? "Requerido"
                                : null,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    GlassContainer(
                      blur: 15,
                      opacity: 0.2,
                      borderRadius: BorderRadius.circular(20),
                      padding: EdgeInsets.all(isMobile ? 16 : 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Escalas (Opcional)",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _bradenScoreController,
                                  label: "Braden Score",
                                  hint: "Ej. 15",
                                  keyboardType: TextInputType.number,
                                  suffixIcon: IconButton(
                                    icon: const Icon(
                                      Icons.calculate_rounded,
                                      color: AppTheme.primaryBlue,
                                    ),
                                    tooltip: "Calcular escala Braden",
                                    onPressed: () async {
                                      final int? result = await showDialog<int>(
                                        context: context,
                                        barrierColor: Colors.black.withValues(
                                          alpha: 0.05,
                                        ),
                                        builder: (context) =>
                                            const BradenCalculatorDialog(),
                                      );
                                      if (result != null) {
                                        _bradenScoreController.text = result
                                            .toString();
                                      }
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  controller: _chads2ScoreController,
                                  label: "CHADS2 Score",
                                  hint: "Ej. 2",
                                  keyboardType: TextInputType.number,
                                  suffixIcon: IconButton(
                                    icon: const Icon(
                                      Icons.calculate_rounded,
                                      color: AppTheme.primaryBlue,
                                    ),
                                    tooltip: "Calcular CHADS2 Score",
                                    onPressed: () async {
                                      final int? result = await showDialog<int>(
                                        context: context,
                                        barrierColor: Colors.black.withValues(
                                          alpha: 0.05,
                                        ),
                                        builder: (context) =>
                                            const Chads2CalculatorDialog(),
                                      );
                                      if (result != null) {
                                        _chads2ScoreController.text = result
                                            .toString();
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "CAM Score",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<bool?>(
                                      value: _camScore,
                                      isExpanded: true,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      hint: const Text(
                                        "Seleccione resultado CAM",
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                          value: null,
                                          child: Text("No evaluado"),
                                        ),
                                        DropdownMenuItem(
                                          value: true,
                                          child: Text("Positivo"),
                                        ),
                                        DropdownMenuItem(
                                          value: false,
                                          child: Text("Negativo"),
                                        ),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          _camScore = value;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(
                                  Icons.calculate_rounded,
                                  color: AppTheme.primaryBlue,
                                  size: 32,
                                ),
                                tooltip: "Calcular escala CAM",
                                onPressed: () async {
                                  final bool? result = await showDialog<bool>(
                                    context: context,
                                    barrierColor: Colors.black.withValues(
                                      alpha: 0.05,
                                    ),
                                    builder: (context) =>
                                        const CamCalculatorDialog(),
                                  );
                                  if (result != null) {
                                    setState(() {
                                      _camScore = result;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.gradientStart,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Guardar Episodio",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.primaryBlue,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
