import 'package:flutter/material.dart';
import 'package:klinico_front/ui/viewmodels/workload_viewmodel.dart';
import 'package:provider/provider.dart';

import '../../widgets/glass_container.dart';

class ServiceWorkloadView extends StatefulWidget {
  const ServiceWorkloadView({super.key});

  @override
  State<ServiceWorkloadView> createState() => _ServiceWorkloadViewState();
}

class _ServiceWorkloadViewState extends State<ServiceWorkloadView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkloadViewmodel>().getServiceWorkload();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WorkloadViewmodel>();
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Padding(
      padding: EdgeInsets.all(isMobile ? 16.0 : 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Carga de trabajo del servicio",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GlassContainer(
              blur: 15,
              opacity: 0.25,
              borderRadius: BorderRadius.circular(20),
              child: vm.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : vm.errorMessage != null
                  ? Center(
                      child: Text(
                        vm.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                  : vm.workload.isEmpty
                  ? const Center(
                      child: Text(
                        "Actualmente, no hay médicos asignados al servicio.",
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    )
                  : _buildDesktopTable(context, vm),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopTable(BuildContext context, WorkloadViewmodel vm) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.resolveWith(
                    (states) => Colors.white.withValues(alpha: 0.4),
                  ),
                  dataRowColor: WidgetStateProperty.resolveWith(
                    (states) => Colors.transparent,
                  ),
                  columnSpacing: 40,
                  columns: const [
                    DataColumn(
                      label: Text(
                        'Médico',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Pacientes asignados',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  rows: vm.workload.map((workload) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            "${workload.name} ${workload.surname}",
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ),
                        DataCell(
                          Text(
                            workload.admissionsAssigned.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
