import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:nariudyam/models/appointment.dart';
import 'package:nariudyam/services/api/schedule_service.dart';
import 'package:nariudyam/services/general/messenger.dart';

import '../components/add_appointment_form.dart';
import 'app_shell_layout.dart';

bool isSameMonth(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month;
}

enum ScheduleView { Day, Week, Month }

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  ScheduleView _scheduleView = ScheduleView.Month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(fabProvider.notifier).state = FloatingActionButton(
        onPressed: _showAddAppointmentDialog,
        child: const Icon(Icons.add),
      );
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(fabProvider.notifier).state = null;
    });
    super.dispose();
  }

  // Called when the Floating Action Button is tapped
  void _showAddAppointmentDialog() {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withAlpha((0.5*255).round()),
      barrierDismissible: true,
      barrierLabel: 'Add Appointment',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.bottomCenter,
          // child: SizedBox(
          //   height: MediaQuery.of(context).size.height * 0.6,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: AddAppointmentForm(
                  selectedDate: _selectedDay ?? DateTime.now(),
                ),
              ),
            ),
          // ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0))
              .animate(animation),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildScreenContent();
  }

  Widget _buildScreenContent() {
    final appointmentsAsyncValue = ref.watch(appointmentsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          _buildToggleButtons(),
          Expanded(
            child: appointmentsAsyncValue.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (allAppointments) {
                switch (_scheduleView) {
                  case ScheduleView.Month:
                    return _buildMonthView(allAppointments);
                  case ScheduleView.Week:
                    return _buildWeekAgendaView(allAppointments);
                  case ScheduleView.Day:
                    return _buildDayAgendaView(allAppointments);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButtons() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ToggleButtons(
        isSelected: [
          _scheduleView == ScheduleView.Day,
          _scheduleView == ScheduleView.Week,
          _scheduleView == ScheduleView.Month,
        ],
        onPressed: (int index) {
          setState(() {
            if (index == 0) _scheduleView = ScheduleView.Day;
            if (index == 1) _scheduleView = ScheduleView.Week;
            if (index == 2) _scheduleView = ScheduleView.Month;
          });
        },
        borderRadius: BorderRadius.circular(20.0),
        selectedBorderColor: theme.colorScheme.primary,
        selectedColor: Colors.white,
        fillColor: theme.colorScheme.primary,
        color: theme.colorScheme.primary,
        constraints: BoxConstraints(
          minHeight: 40.0,
          minWidth: (MediaQuery.of(context).size.width - 48) / 3,
        ),
        children: const [Text('Day'), Text('Week'), Text('Month')],
      ),
    );
  }

  Widget _buildMonthView(List<Appointment> allAppointments) {
    final theme = Theme.of(context);

    //Analyse event density for relatively sized bubbles
    final Map<DateTime, int> eventCountPerDay = {};
    for (final appointment in allAppointments) {
      final day = DateTime.utc(appointment.dateTime.year, appointment.dateTime.month, appointment.dateTime.day);
      eventCountPerDay[day] = (eventCountPerDay[day] ?? 0) + 1;
    }

    // Find the min and max number of events for any day in the map
    final eventCounts = eventCountPerDay.values;
    final minEvents = eventCounts.isNotEmpty ? eventCounts.reduce((a, b) => a < b ? a : b) : 1;
    final maxEvents = eventCounts.isNotEmpty ? eventCounts.reduce((a, b) => a > b ? a : b) : 1;
    final eventRange = (maxEvents - minEvents).toDouble();

    Widget buildDensityBubble(DateTime day, {required int eventCount}) {
      // Define our 5 levels of styling
      const List<double> sizes = [22.0, 25.0, 28.0, 31.0, 34.0];
      const List<double> opacities = [0.4, 0.55, 0.7, 0.85, 1.0];
      int level = 0; // Default to the smallest size

      // Calculate the relative level (0-4)
      if (eventRange > 0) {
        // Normalize the count to a 0.0-1.0 scale
        double normalized = (eventCount - minEvents) / eventRange;
        // Scale to our 5 levels and round to get an integer level
        level = (normalized * 4).round();
      }

      final color = theme.colorScheme.primary.withAlpha((opacities[level]*255).round());
      final size = sizes[level];

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
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          calendarFormat: CalendarFormat.month,
          eventLoader: (day) => allAppointments.where((a) => isSameDay(a.dateTime, day)).toList(),
          availableCalendarFormats: const {CalendarFormat.month: 'Month'},
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
              _scheduleView = ScheduleView.Day;
            });
          },
          onPageChanged: (focusedDay) {
            setState(() { _focusedDay = focusedDay; });
          },

          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            leftChevronIcon: Icon(
              Icons.arrow_back_ios,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            rightChevronIcon: Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: theme.colorScheme.primary,
            ),
          ),
          calendarStyle: const CalendarStyle(
            markersMaxCount: 0, //Hide dot markers
          ),

          calendarBuilders: CalendarBuilders(
            selectedBuilder: (context, day, focusedDay) {
              final utcDay = DateTime.utc(day.year, day.month, day.day);
              final count = eventCountPerDay[utcDay] ?? 0;
              Widget dayContent;
              if (count > 0) {
                // If the selected day has events, its content is the density bubble
                dayContent = buildDensityBubble(day, eventCount: count);
              } else {
                // If the selected day is empty, its content is just the number
                dayContent = Center(
                  child: Text(
                    '${day.day}',
                    style: TextStyle(color: theme.colorScheme.primary),
                  ),
                );
              }

              return Container(
                margin: const EdgeInsets.all(2.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha((0.15*255).round()),
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: dayContent,
              );
            },
            defaultBuilder: (context, day, focusedDay) {
              final utcDay = DateTime.utc(day.year, day.month, day.day);
              final count = eventCountPerDay[utcDay] ?? 0;
              if (count > 0) {
                return buildDensityBubble(day, eventCount: count);
              }
              return null;
            },
            todayBuilder: (context, day, focusedDay) {
              final utcDay = DateTime.utc(day.year, day.month, day.day);
              final count = eventCountPerDay[utcDay] ?? 0;
              if (count > 0) {
                return buildDensityBubble(day, eventCount: count);
              }
              return Center(child: Text('${day.day}', style: TextStyle(color: theme.colorScheme.primary)));
            },
            markerBuilder: (context, date, events) => null,
          ),
        ),
        const Divider(),
        Expanded(child: _buildDayAgendaView(allAppointments, showHeader: false)),
      ],
    );
  }
  Widget _buildWeekAgendaView(List<Appointment> allAppointments) {
    final weekStart = _focusedDay.subtract(Duration(days: _focusedDay.weekday - 1));
    final weekEnd = _focusedDay.add(Duration(days: 7 - _focusedDay.weekday));
    final weekAppointments = allAppointments
        .where((a) => a.dateTime.isAfter(weekStart.subtract(const Duration(seconds: 1))) && a.dateTime.isBefore(weekEnd.add(const Duration(seconds: 1))))
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    if (weekAppointments.isEmpty) {
      return const Center(child: Text("No appointments this week."));
    }

    return ListView.builder(
      itemCount: weekAppointments.length,
      itemBuilder: (context, index) {
        final appointment = weekAppointments[index];
        final bool showHeader = index == 0 || !isSameDay(weekAppointments[index - 1].dateTime, appointment.dateTime);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHeader)
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 8.0, left: 4.0),
                child: Text(DateFormat('EEEE, MMMM d').format(appointment.dateTime), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ListTile(
              leading: Text(DateFormat('h:mm a').format(appointment.dateTime), style: const TextStyle(fontWeight: FontWeight.w500)),
              title: Text(appointment.title),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDayAgendaView(List<Appointment> allAppointments, {bool showHeader = true}) {
    final dayAppointments = allAppointments
        .where((a) => isSameDay(a.dateTime, _selectedDay))
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    if (dayAppointments.isEmpty) {
      return const Center(child: Text("No appointments for this day."));
    }

    return Column(
      children: [
        if (showHeader)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(DateFormat('EEEE, MMMM d').format(_selectedDay!), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: dayAppointments.length,
            itemBuilder: (context, index) {
              final appointment = dayAppointments[index];
              return ListTile(
                leading: Text(DateFormat('h:mm a').format(appointment.dateTime), style: const TextStyle(fontWeight: FontWeight.w500)),
                title: Text(appointment.title),
              );
            },
          ),
        ),
      ],
    );
  }
}
