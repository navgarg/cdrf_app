import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nariudyam/models/appointment.dart';
import 'package:nariudyam/services/general/messenger.dart';
import 'package:nariudyam/providers/fav_customer_providers.dart';
import 'package:collection/collection.dart';
import '../../l10n/dynamic_localizations.dart';

// firebase (previous implementation)
// import 'package:nariudyam/services/api/auth_service.dart';
// import 'package:nariudyam/services/api/fav_customer_service.dart';
// import 'package:nariudyam/models/favourite_customer.dart';

class WeekView extends ConsumerWidget {
  final List<Appointment> allAppointments;
  final DateTime focusedDay;
  final Function(DateTime) onWeekNavigate;

  const WeekView({
    super.key,
    required this.allAppointments,
    required this.focusedDay,
    required this.onWeekNavigate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final favouriteCustomersAsync = ref.watch(favCustomerServiceProvider);

    return favouriteCustomersAsync.when(
      data: (favouriteCustomers) {
        final weekStart =
            focusedDay.subtract(Duration(days: focusedDay.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6));

        final weekAppointments = allAppointments
            .where((a) =>
                a.dateTime
                    .isAfter(weekStart.subtract(const Duration(seconds: 1))) &&
                a.dateTime.isBefore(weekEnd.add(const Duration(days: 1))))
            .toList()
          ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

        return Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
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
                    onPressed: () => onWeekNavigate(
                        focusedDay.subtract(const Duration(days: 7))),
                  ),
                  Text(
                    '${DateFormat('MMM d').format(weekStart)} - ${DateFormat('d, yyyy').format(weekEnd)}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios,
                        color: Colors.white, size: 18),
                    onPressed: () =>
                        onWeekNavigate(focusedDay.add(const Duration(days: 7))),
                  ),
                ],
              ),
            ),
            Expanded(
              child: weekAppointments.isEmpty
                  ? Center(
                      child: Text(context.tr("No appointments this week.")))
                  : ListView.builder(
                      itemCount: weekAppointments.length,
                      itemBuilder: (context, index) {
                        final appointment = weekAppointments[index];
                        final bool showHeader = index == 0 ||
                            (appointment.dateTime.year !=
                                    weekAppointments[index - 1].dateTime.year ||
                                appointment.dateTime.month !=
                                    weekAppointments[index - 1]
                                        .dateTime
                                        .month ||
                                appointment.dateTime.day !=
                                    weekAppointments[index - 1].dateTime.day);

                        final isFavourite = favouriteCustomers.firstWhereOrNull(
                                (fav) => fav.id == appointment.customerId) !=
                            null;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (showHeader)
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 16.0, bottom: 8.0, left: 4.0),
                                child: Text(
                                    DateFormat('EEEE, MMMM d')
                                        .format(appointment.dateTime),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                              ),
                            ListTile(
                              leading: Text(
                                  DateFormat('h:mm a')
                                      .format(appointment.dateTime),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500)),
                              title: Text(appointment.title),
                              trailing: isFavourite
                                  ? Icon(Icons.star_rounded,
                                      color: Colors.amber.shade700)
                                  : null,
                              onTap: () {
                                ref.read(messengerProvider).showInfo(context.tr(
                                    'Tapped on appointment: ${appointment.title}'));
                              },
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}
