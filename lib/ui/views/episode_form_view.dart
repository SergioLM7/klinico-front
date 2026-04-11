import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/glass_container.dart';
import '../widgets/gradient_scaffold.dart';

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

    setState(() {
      _isLoading = true;
    });

    // TODO: Connect with ViewModel and Repository to send to backend
    // final viewModel = context.read<EpisodeViewModel>();
    // final success = await viewModel.createEpisode(...);
    
    // Simulating delay for now
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Episodio creado correctamente"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    }
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
          "Nuevo Episodio Clínico",
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
                      validator: (value) =>
                          value == null || value.isEmpty ? "Requerido" : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _diagnosisController,
                      label: "Diagnóstico*",
                      hint: "Indique el diagnóstico...",
                      maxLines: 2,
                      validator: (value) =>
                          value == null || value.isEmpty ? "Requerido" : null,
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
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _chads2ScoreController,
                            label: "CHADS2 Score",
                            hint: "Ej. 2",
                            keyboardType: TextInputType.number,
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
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<bool?>(
                          value: _camScore,
                          isExpanded: true,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          borderRadius: BorderRadius.circular(12),
                          hint: const Text("Seleccione resultado CAM"),
                          items: const [
                            DropdownMenuItem(value: null, child: Text("No evaluado")),
                            DropdownMenuItem(value: true, child: Text("Positivo")),
                            DropdownMenuItem(value: false, child: Text("Negativo")),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _camScore = value;
                            });
                          },
                        ),
                      ),
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
                        backgroundColor: AppTheme.primaryBlue,
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
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
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.8)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.8)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
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
