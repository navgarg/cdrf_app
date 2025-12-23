import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nariudyam/models/appointment.dart';
import 'package:nariudyam/services/api/auth_service.dart';
import 'package:nariudyam/services/general/messenger.dart';
import 'package:nariudyam/l10n/dynamic_localizations.dart';

class DayView extends ConsumerWidget {
  final List<Appointment> allAppointments;
  final DateTime? selectedDay;
  final bool showHeader;
  // Callback to notify the parent screen of a date change
  final Function(DateTime)? onDayNavigate;

  const DayView({
    super.key,
    required this.allAppointments,
    required this.selectedDay,
    this.showHeader = true,
    this.onDayNavigate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (selectedDay == null) {
      return Center(
          child: Text(context.tr("Select a day to see appointments.")));
    }

    final theme = Theme.of(context);
    final user = ref.watch(userProvider);

    final dayAppointments = allAppointments
        .where((a) =>
            a.dateTime.year == selectedDay!.year &&
            a.dateTime.month == selectedDay!.month &&
            a.dateTime.day == selectedDay!.day)
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    return Column(
      children: [
        if (showHeader)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios,
                      color: Colors.white, size: 18),
                  onPressed: () => onDayNavigate
                      ?.call(selectedDay!.subtract(const Duration(days: 1))),
                ),
                Text(
                  DateFormat('MMMM d, yyyy').format(selectedDay!),
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios,
                      color: Colors.white, size: 18),
                  onPressed: () => onDayNavigate
                      ?.call(selectedDay!.add(const Duration(days: 1))),
                ),
              ],
            ),
          ),
        Expanded(
          child: dayAppointments.isEmpty
              ? Center(child: Text(context.tr("No appointments for this day.")))
              : ListView.builder(
                  itemCount: dayAppointments.length,
                  itemBuilder: (context, index) {
                    final appointment = dayAppointments[index];
                    final bool isFavourite = user != null &&
                        appointment.customerId != null &&
                        user.favouriteCustomerIds
                            .contains(appointment.customerId);

                    return ListTile(
                      leading: Text(
                          DateFormat('h:mm a').format(appointment.dateTime),
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                      title: Text(appointment.title),
                      trailing: isFavourite
                          ? Icon(Icons.star_rounded,
                              color: Colors.amber.shade700)
                          : null,
                      onTap: () {
                        if (isFavourite) {
                          ref.read(messengerProvider).showInfo(context.tr(
                              'Tapped on favourite customer: ${appointment.customerId}'));
                        }
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
