import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:nariudyam/models/appointment.dart';
import 'package:nariudyam/services/api/schedule_service.dart';
import 'package:nariudyam/services/general/messenger.dart';

import '../components/add_appointment_form.dart';
import 'app_shell_layout.dart';
// Helper function to check for the same month, as it's not in the package
bool isSameMonth(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month;
}

// Enum to manage which of the three distinct views is active
enum ScheduleView { Day, Week, Month }

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  // State for the main view control
  ScheduleView _scheduleView = ScheduleView.Month;

  // State for the calendar's data and selection
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

  // This function is called when the Floating Action Button is tapped
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

  // Builder for the Top Toggle Buttons
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

  // Builder for the "Month" view, which contains the calendar and a preview list
  Widget _buildMonthView(List<Appointment> allAppointments) {
    List<Appointment> getAppointmentsForDay(DateTime day) {
      return allAppointments.where((a) => isSameDay(a.dateTime, day)).toList();
    }

    return Column(
      children: [
        TableCalendar<Appointment>(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          calendarFormat: CalendarFormat.month,
          eventLoader: getAppointmentsForDay,
          availableCalendarFormats: const {CalendarFormat.month: 'Month'},
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
              _scheduleView = ScheduleView.Day;
            });
          },
          onPageChanged: (focusedDay) {
            setState(() {
              _focusedDay = focusedDay;
            });
          },
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            leftChevronIcon: Icon(Icons.arrow_back_ios, size: 18, color: Theme.of(context).colorScheme.primary),
            rightChevronIcon: Icon(Icons.arrow_forward_ios, size: 18, color: Theme.of(context).colorScheme.primary),
          ),
          calendarStyle: CalendarStyle(
            selectedDecoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle),
            selectedTextStyle: const TextStyle(color: Colors.white),
            todayDecoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withAlpha((0.3*255).round()), shape: BoxShape.circle),
            todayTextStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              if (events.isNotEmpty) {
                return Positioned(
                  right: 1, bottom: 1,
                  child: Container(
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).colorScheme.primary.withOpacity(0.8)),
                    width: 8.0, height: 8.0,
                  ),
                );
              }
              return null;
            },
          ),
        ),
        const Divider(),
        Expanded(child: _buildDayAgendaView(allAppointments, showHeader: false)),
      ],
    );
  }

  // Builder for the "Week" agenda (a vertical list for the whole week)
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

  // Builder for the "Day" agenda (a vertical list for a single day)
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
