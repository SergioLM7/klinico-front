import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/kpi_doctor_data.dart';
import '../../../data/models/kpi_month_value.dart';
import '../../viewmodels/kpis_viewmodel.dart';
import '../../widgets/glass_container.dart';

// ─── Paleta de colores para las líneas por médico ──────────────────────────
const List<Color> _doctorColors = [
  Color(0xFF0A1B96),
  Color(0xFF0EA5E9),
  Color(0xFF10B981),
  Color(0xFFF59E0B),
  Color(0xFFEC4899),
  Color(0xFF8B5CF6),
  Color(0xFFEF4444),
  Color(0xFF14B8A6),
];

const List<String> _monthNames = [
  '',
  'Ene',
  'Feb',
  'Mar',
  'Abr',
  'May',
  'Jun',
  'Jul',
  'Ago',
  'Sep',
  'Oct',
  'Nov',
  'Dic',
];

// ════════════════════════════════════════════════════════
//  VISTA PRINCIPAL
// ════════════════════════════════════════════════════════
class ServiceKpisDashboard extends StatefulWidget {
  const ServiceKpisDashboard({super.key});

  @override
  State<ServiceKpisDashboard> createState() => _ServiceKpisDashboardState();
}

class _ServiceKpisDashboardState extends State<ServiceKpisDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KpisViewModel>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<KpisViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FiltersHeader(vm: vm),
        Expanded(
          child: vm.isLoading
              ? const Center(child: CircularProgressIndicator())
              : vm.errorMessage != null
              ? Center(
                  child: Text(
                    vm.errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                )
              : vm.isMonthlyView
              ? _MonthlyContent(vm: vm)
              : _AnnualContent(vm: vm),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════
//  CABECERA CON FILTROS
// ════════════════════════════════════════════════════════
class _FiltersHeader extends StatelessWidget {
  final KpisViewModel vm;
  const _FiltersHeader({required this.vm});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 32,
        isMobile ? 16 : 32,
        isMobile ? 16 : 32,
        16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título + selector de año
          Row(
            children: [
              Text(
                'KPIs',
                style: TextStyle(
                  fontSize: isMobile ? 24 : 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              // Selector de año
              GlassContainer(
                blur: 10,
                opacity: 0.3,
                borderRadius: BorderRadius.circular(12),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: isMobile
                          ? const BoxConstraints(minWidth: 32, minHeight: 32)
                          : null,
                      iconSize: isMobile ? 20 : 24,
                      icon: const Icon(
                        Icons.chevron_left,
                        color: AppTheme.primaryBlue,
                      ),
                      onPressed: () => vm.changeFilters(
                        year: vm.selectedYear - 1,
                        month: vm.selectedMonth,
                      ),
                    ),
                    Text(
                      '${vm.selectedYear}',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: isMobile
                          ? const BoxConstraints(minWidth: 32, minHeight: 32)
                          : null,
                      iconSize: isMobile ? 20 : 24,
                      icon: const Icon(
                        Icons.chevron_right,
                        color: AppTheme.primaryBlue,
                      ),
                      onPressed: vm.selectedYear < DateTime.now().year
                          ? () => vm.changeFilters(
                              year: vm.selectedYear + 1,
                              month: vm.selectedMonth,
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Chips de mes
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _MonthChip(
                  label: 'Anual',
                  selected: vm.selectedMonth == null,
                  onTap: () => vm.changeFilters(year: vm.selectedYear),
                ),
                const SizedBox(width: 8),
                ...List.generate(12, (i) {
                  final month = i + 1;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _MonthChip(
                      label: _monthNames[month],
                      selected: vm.selectedMonth == month,
                      onTap: () =>
                          vm.changeFilters(year: vm.selectedYear, month: month),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _MonthChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primaryBlue
              : Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppTheme.primaryBlue : Colors.black12,
            width: 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  VISTA MENSUAL - KPI CARDS + BARRAS POR MÉDICO
// ════════════════════════════════════════════════════════
class _MonthlyContent extends StatelessWidget {
  final KpisViewModel vm;
  const _MonthlyContent({required this.vm});

  @override
  Widget build(BuildContext context) {
    final monthName = _monthNames[vm.selectedMonth!];
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Datos de $monthName ${vm.selectedYear}',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          // KPI Cards top
          LayoutBuilder(
            builder: (context, constraints) {
              final crossCount = constraints.maxWidth > 800 ? 3 : 1;
              return GridView.count(
                crossAxisCount: crossCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: constraints.maxWidth > 800 ? 2.0 : 3.5,
                children: [
                  _KpiCard(
                    icon: Icons.local_hospital_rounded,
                    label: 'Ingresos',
                    value: vm
                        .singleValue(vm.admissionsByService)
                        .toInt()
                        .toString(),
                    unit: 'pacientes',
                    color: AppTheme.primaryBlue,
                  ),
                  _KpiCard(
                    icon: Icons.monitor_heart_rounded,
                    label: 'Éxitus',
                    value: vm.singleValue(vm.exitus).toInt().toString(),
                    unit: 'pacientes',
                    color: const Color(0xFFEF4444),
                  ),
                  _KpiCard(
                    icon: Icons.hotel_rounded,
                    label: 'Estancia media',
                    value: vm.singleValue(vm.avgStay).toStringAsFixed(1),
                    unit: 'días',
                    color: const Color(0xFF10B981),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          // Ingresos por médico (BarChart horizontal)
          if (vm.admissionsByDoctor.isNotEmpty) ...[
            _ChartCard(
              title: 'Ingresos por médico',
              subtitle: monthName,
              child: _DoctorBarChart(
                items: vm.admissionsByDoctor
                    .map(
                      (d) => _DoctorBarItem(
                        name: d.fullName,
                        value: vm.doctorSingleValue(d),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],
          // Estancia media por médico (BarChart horizontal)
          if (vm.avgStayByDoctor.isNotEmpty) ...[
            _ChartCard(
              title: 'Estancia media por médico',
              subtitle: '$monthName (días)',
              child: _DoctorBarChart(
                items: vm.avgStayByDoctor
                    .map(
                      (d) => _DoctorBarItem(
                        name: d.fullName,
                        value: vm.doctorSingleValue(d),
                        isDecimal: true,
                      ),
                    )
                    .toList(),
                isDecimal: true,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  VISTA ANUAL - LINE CHARTS
// ════════════════════════════════════════════════════════
class _AnnualContent extends StatelessWidget {
  final KpisViewModel vm;
  const _AnnualContent({required this.vm});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
      child: Column(
        children: [
          // Ingresos del servicio
          _ChartCard(
            title: 'Ingresos del servicio',
            subtitle: 'Evolución mensual ${vm.selectedYear}',
            child: _ServiceLineChart(
              data: vm.admissionsByService,
              color: AppTheme.primaryBlue,
              isDecimal: false,
            ),
          ),
          const SizedBox(height: 16),
          // Ingresos por médico
          _ChartCard(
            title: 'Ingresos por médico',
            subtitle: 'Evolución mensual ${vm.selectedYear}',
            child: _DoctorMultiLineChart(
              doctors: vm.admissionsByDoctor,
              isDecimal: false,
            ),
          ),
          const SizedBox(height: 16),
          // Éxitus
          _ChartCard(
            title: 'Éxitus del servicio',
            subtitle: 'Evolución mensual ${vm.selectedYear}',
            child: _ServiceLineChart(
              data: vm.exitus,
              color: const Color(0xFFEF4444),
              isDecimal: false,
            ),
          ),
          const SizedBox(height: 16),
          // Estancia media
          _ChartCard(
            title: 'Estancia media del servicio',
            subtitle: 'Días por mes · ${vm.selectedYear}',
            child: _ServiceLineChart(
              data: vm.avgStay,
              color: const Color(0xFF10B981),
              isDecimal: true,
            ),
          ),
          const SizedBox(height: 16),
          // Estancia media por médico
          _ChartCard(
            title: 'Estancia media por médico',
            subtitle: 'Días por mes · ${vm.selectedYear}',
            child: _DoctorMultiLineChart(
              doctors: vm.avgStayByDoctor,
              isDecimal: true,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  WIDGETS REUTILIZABLES
// ════════════════════════════════════════════════════════

class _KpiCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _KpiCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      blur: 15,
      opacity: 0.25,
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: color,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        unit,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black45,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      blur: 15,
      opacity: 0.25,
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 13, color: Colors.black45),
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────
//  LINE CHART para datos de servicio (1 línea)
// ────────────────────────────────────────────────────────
class _ServiceLineChart extends StatelessWidget {
  final List<KpiMonthValue> data;
  final Color color;
  final bool isDecimal;

  const _ServiceLineChart({
    required this.data,
    required this.color,
    required this.isDecimal,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'Sin datos para este período',
            style: TextStyle(color: Colors.black38),
          ),
        ),
      );
    }

    final maxY = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final spots = data.map((e) => FlSpot(e.month.toDouble(), e.value)).toList();

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          minX: 1,
          maxX: 12,
          minY: 0,
          maxY: maxY == 0 ? 1 : maxY * 1.2,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: Colors.black.withValues(alpha: 0.06),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  if (value == meta.max) return const SizedBox.shrink();
                  final label = isDecimal
                      ? value.toStringAsFixed(1)
                      : value.toInt().toString();
                  return Text(
                    label,
                    style: const TextStyle(fontSize: 11, color: Colors.black45),
                    textAlign: TextAlign.right,
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 1 || idx > 12) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      _monthNames[idx],
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black45,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) =>
                  AppTheme.primaryBlue.withValues(alpha: 0.85),
              getTooltipItems: (spots) => spots
                  .map(
                    (s) => LineTooltipItem(
                      isDecimal
                          ? '${s.y.toStringAsFixed(1)} días'
                          : '${s.y.toInt()} pac.',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: color,
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, _, _, _) => FlDotCirclePainter(
                  radius: 4,
                  color: color,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    color.withValues(alpha: 0.2),
                    color.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────
//  LINE CHART multi-línea para datos por médico
// ────────────────────────────────────────────────────────
class _DoctorMultiLineChart extends StatelessWidget {
  final List<KpiDoctorData> doctors;
  final bool isDecimal;

  const _DoctorMultiLineChart({required this.doctors, required this.isDecimal});

  @override
  Widget build(BuildContext context) {
    if (doctors.isEmpty) {
      return const SizedBox(
        height: 220,
        child: Center(
          child: Text(
            'Sin datos para este período',
            style: TextStyle(color: Colors.black38),
          ),
        ),
      );
    }

    double maxY = 0;
    for (final doc in doctors) {
      for (final mv in doc.data) {
        if (mv.value > maxY) maxY = mv.value;
      }
    }

    final bars = doctors.asMap().entries.map((entry) {
      final color = _doctorColors[entry.key % _doctorColors.length];
      final spots = entry.value.data
          .map((e) => FlSpot(e.month.toDouble(), e.value))
          .toList();
      return LineChartBarData(
        spots: spots,
        isCurved: true,
        color: color,
        barWidth: 2.5,
        dotData: FlDotData(
          show: true,
          getDotPainter: (s, _, _, _) => FlDotCirclePainter(
            radius: 3,
            color: color,
            strokeWidth: 1.5,
            strokeColor: Colors.white,
          ),
        ),
        belowBarData: BarAreaData(show: false),
      );
    }).toList();

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              minX: 1,
              maxX: 12,
              minY: 0,
              maxY: maxY == 0 ? 1 : maxY * 1.2,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: Colors.black.withValues(alpha: 0.06),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      if (value == meta.max) return const SizedBox.shrink();
                      final label = isDecimal
                          ? value.toStringAsFixed(1)
                          : value.toInt().toString();
                      return Text(
                        label,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black45,
                        ),
                        textAlign: TextAlign.right,
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 1 || idx > 12) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          _monthNames[idx],
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black45,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => const Color.fromARGB(
                    0,
                    255,
                    255,
                    255,
                  ).withValues(alpha: 0.35),
                  getTooltipItems: (touchedSpots) =>
                      touchedSpots.asMap().entries.map((entry) {
                        final s = entry.value;
                        final doc = doctors[s.barIndex % doctors.length];
                        final label = isDecimal
                            ? '${s.y.toStringAsFixed(1)} días'
                            : '${s.y.toInt()} pac.';
                        return LineTooltipItem(
                          '${doc.doctorSurname}: $label',
                          TextStyle(
                            color:
                                _doctorColors[s.barIndex %
                                    _doctorColors.length],
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }).toList(),
                ),
              ),
              lineBarsData: bars,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Leyenda
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: doctors.asMap().entries.map((entry) {
            final color = _doctorColors[entry.key % _doctorColors.length];
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  entry.value.fullName,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────
//  BAR CHART horizontal para datos por médico (vista mensual)
// ────────────────────────────────────────────────────────
class _DoctorBarItem {
  final String name;
  final double value;
  final bool isDecimal;

  _DoctorBarItem({
    required this.name,
    required this.value,
    this.isDecimal = false,
  });
}

class _DoctorBarChart extends StatelessWidget {
  final List<_DoctorBarItem> items;
  final bool isDecimal;

  const _DoctorBarChart({required this.items, this.isDecimal = false});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox(
        height: 150,
        child: Center(
          child: Text(
            'Sin datos para este período',
            style: TextStyle(color: Colors.black38),
          ),
        ),
      );
    }

    final maxVal = items.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final barHeight = 36.0;
    final chartHeight = items.length * (barHeight + 12) + 16;

    return SizedBox(
      height: chartHeight,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceEvenly,
          maxY: maxVal == 0 ? 1 : maxVal * 1.25,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) =>
                  AppTheme.primaryBlue.withValues(alpha: 0.85),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final val = isDecimal
                    ? '${rod.toY.toStringAsFixed(1)} días'
                    : '${rod.toY.toInt()} pac.';
                return BarTooltipItem(
                  val,
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 130,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= items.length) {
                    return const SizedBox.shrink();
                  }
                  final parts = items[idx].name.split(' ');
                  final shortName = parts.length >= 2
                      ? '${parts[0]} ${parts[1]}'
                      : items[idx].name;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      shortName,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                    ),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value == meta.max) return const SizedBox.shrink();
                  final label = isDecimal
                      ? value.toStringAsFixed(1)
                      : value.toInt().toString();
                  return Text(
                    label,
                    style: const TextStyle(fontSize: 11, color: Colors.black45),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: false,
            getDrawingVerticalLine: (_) => FlLine(
              color: Colors.black.withValues(alpha: 0.06),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: items.asMap().entries.map((entry) {
            final color = _doctorColors[entry.key % _doctorColors.length];
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  fromY: 0,
                  toY: entry.value.value,
                  color: color,
                  width: barHeight,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(6),
                    bottomRight: Radius.circular(6),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
        duration: const Duration(milliseconds: 300),
      ),
    );
  }
}
