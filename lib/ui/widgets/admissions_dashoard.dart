import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'admission_card.dart';
import '../viewmodels/admission_viewmodel.dart';
import '../viewmodels/login_viewmodel.dart';

class AdmissionDashboard extends StatefulWidget {
  const AdmissionDashboard({super.key});

  @override
  State<AdmissionDashboard> createState() => _AdmissionDashboardState();
}

class _AdmissionDashboardState extends State<AdmissionDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final String? doctorId = context.read<LoginViewModel>().userId;
      if (doctorId != null) {
        context.read<AdmissionViewModel>().getUserAdmissions(doctorId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdmissionViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.errorMessage != null) {
          return Center(child: Text(viewModel.errorMessage!));
        }

        if (viewModel.admissions.isEmpty) {
          return const Center(
            child: Text(
              "No hay ingresos asignados.",
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ),
          );
        }

        final width = MediaQuery.of(context).size.width;

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: width < 600 ? 500 : 300,
            childAspectRatio: width < 600 ? 1.6 : 1.2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: viewModel.admissions.length,
          itemBuilder: (context, index) {
            final admission = viewModel.admissions[index];
            return AdmissionCard(admission: admission);
          },
        );
      },
    );
  }
}
