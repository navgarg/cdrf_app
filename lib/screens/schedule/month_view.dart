import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:nariudyam/models/appointment.dart';
import 'day_view.dart';

class MonthView extends ConsumerWidget {
  final List<Appointment> allAppointments;
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(DateTime) onPageChanged;

  const MonthView({
    super.key,
    required this.allAppointments,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final Map<DateTime, int> eventCountPerDay = {};
    for (final appointment in allAppointments) {
      final day = DateTime.utc(appointment.dateTime.year, appointment.dateTime.month, appointment.dateTime.day);
      eventCountPerDay[day] = (eventCountPerDay[day] ?? 0) + 1;
    }

    final eventCounts = eventCountPerDay.values;
    final minEvents = eventCounts.isNotEmpty ? eventCounts.reduce((a, b) => a < b ? a : b) : 1;
    final maxEvents = eventCounts.isNotEmpty ? eventCounts.reduce((a, b) => a > b ? a : b) : 1;
    final eventRange = (maxEvents - minEvents).toDouble();

    Widget buildDensityBubble(DateTime day, {required int eventCount}) {
      const List<double> opacities = [0.4, 0.55, 0.7, 0.85, 1.0];
      const List<double> sizes = [22.0, 25.0, 28.0, 31.0, 34.0];
      int level = 0;

      if (eventRange > 0) {
        double normalized = (eventCount - minEvents) / eventRange;
        level = (normalized * 4).round();
      }

      final int alpha = (opacities[level] * 255).round();
      final Color color = theme.colorScheme.primary.withAlpha(alpha);
      final double size = sizes[level];

      return Container(
        width: size,
        height: size,
        margin: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Center(child: Text('${day.day}', style: const TextStyle(color: Colors.white, fontSize: 12))),
      );
    }

    return Column(
      children: [
        TableCalendar<Appointment>(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: focusedDay,
          selectedDayPredicate: (day) => isSameDay(selectedDay, day),
          calendarFormat: CalendarFormat.month,
          availableCalendarFormats: const {CalendarFormat.month: 'Month'},
          onDaySelected: onDaySelected,
          onPageChanged: onPageChanged,
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            leftChevronIcon: Icon(Icons.arrow_back_ios, size: 18, color: theme.colorScheme.primary),
            rightChevronIcon: Icon(Icons.arrow_forward_ios, size: 18, color: theme.colorScheme.primary),
          ),
          calendarStyle: const CalendarStyle(markersMaxCount: 0),
          calendarBuilders: CalendarBuilders(
            selectedBuilder: (context, day, focusedDay) {
              final utcDay = DateTime.utc(day.year, day.month, day.day);
              final count = eventCountPerDay[utcDay] ?? 0;
              Widget dayContent = (count > 0)
                  ? buildDensityBubble(day, eventCount: count)
                  : Center(child: Text('${day.day}', style: TextStyle(color: theme.colorScheme.primary)));

              return Container(
                margin: const EdgeInsets.all(2.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha((0.15 * 255).round()),
                  border: Border.all(color: theme.colorScheme.primary, width: 1.5),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: dayContent,
              );
            },
            defaultBuilder: (context, day, focusedDay) {
              final utcDay = DateTime.utc(day.year, day.month, day.day);
              final count = eventCountPerDay[utcDay] ?? 0;
              return (count > 0) ? buildDensityBubble(day, eventCount: count) : null;
            },
            todayBuilder: (context, day, focusedDay) {
              final utcDay = DateTime.utc(day.year, day.month, day.day);
              final count = eventCountPerDay[utcDay] ?? 0;
              return (count > 0)
                  ? buildDensityBubble(day, eventCount: count)
                  : Center(child: Text('${day.day}', style: TextStyle(color: theme.colorScheme.primary)));
            },
            markerBuilder: (context, date, events) => null,
          ),
        ),
        const Divider(),
        Expanded(
          child: DayView(
            allAppointments: allAppointments,
            selectedDay: selectedDay,
            showHeader: false,
          ),
        ),
      ],
    );
  }
}