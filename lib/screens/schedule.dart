import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nariudyam/screens/schedule/day_view.dart';
import 'package:nariudyam/screens/schedule/month_view.dart';
import 'package:nariudyam/screens/schedule/week_view.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:nariudyam/models/appointment.dart';
import 'package:nariudyam/services/api/schedule_service.dart';
import 'package:nariudyam/services/general/messenger.dart';

import '../components/add_appointment_form.dart';
import '../services/api/auth_service.dart';
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
                    return MonthView(
                      allAppointments: allAppointments,
                      focusedDay: _focusedDay,
                      selectedDay: _selectedDay,
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
                    );
                  case ScheduleView.Week:
                    return WeekView(
                      allAppointments: allAppointments,
                      focusedDay: _focusedDay,
                      onWeekNavigate: (newFocusedDay) {
                        setState(() { _focusedDay = newFocusedDay; });
                      },
                    );
                  case ScheduleView.Day:
                    return DayView(
                      allAppointments: allAppointments,
                      selectedDay: _selectedDay,
                      onDayNavigate: (newSelectedDay) {
                        setState(() { _selectedDay = newSelectedDay; });
                      },
                    );
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
}
