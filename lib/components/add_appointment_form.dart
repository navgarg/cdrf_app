import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nariudyam/providers/auth_providers.dart';
import 'package:intl/intl.dart';
import '../models/favourite_customer.dart';
import 'package:nariudyam/providers/fav_customer_providers.dart';
import 'package:nariudyam/providers/schedule_providers.dart';
import '../services/general/messenger.dart';
import '../l10n/dynamic_localizations.dart';

class AddAppointmentForm extends ConsumerStatefulWidget {
  final DateTime selectedDate;
  const AddAppointmentForm({super.key, required this.selectedDate});

  @override
  ConsumerState<AddAppointmentForm> createState() => _AddAppointmentFormState();
}

//todo: add customer id to track fav customers
class _AddAppointmentFormState extends ConsumerState<AddAppointmentForm> {
  FavouriteCustomer? _selectedFavouriteCustomer;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    _selectedTime = TimeOfDay.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final domain = ref.read(currentDomainProvider);
      if (domain == null) {
        ref
            .read(messengerProvider)
            .showError(context.tr('No business domain selected.'));
        return;
      }

      final success = await ref.read(scheduleServiceProvider).addAppointment(
            title: _titleController.text,
            date: _selectedDate,
            time: _selectedTime,
            businessDomain: domain,
            customerId: _selectedFavouriteCustomer?.id,
          );

      setState(() => _isLoading = false);

      if (success && mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(authServiceProvider).currentUserId;
    final favouriteCustomersAsync =
        ref.watch(favouriteCustomersProvider(userId));

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(context.tr('New Appointment'),
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration:
                    InputDecoration(labelText: context.tr('Appointment Title')),
                validator: (value) =>
                    value!.isEmpty ? context.tr('Please enter a title') : null,
              ),
              const SizedBox(height: 16),
              favouriteCustomersAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) =>
                    Text(context.tr('Could not load customers.')),
                data: (customerList) {
                  return DropdownButtonFormField<FavouriteCustomer?>(
                    value: _selectedFavouriteCustomer,
                    hint: Text(
                        context.tr('Link a Favourite Customer (Optional)')),
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: context.tr('Link Favourite Customer'),
                      border: const OutlineInputBorder(),
                    ),
                    // The items list includes a "None" option at the top
                    items: [
                      DropdownMenuItem<FavouriteCustomer?>(
                        value: null,
                        child: Text(context.tr('None')),
                      ),
                      ...customerList.map((customer) {
                        return DropdownMenuItem<FavouriteCustomer?>(
                          value: customer,
                          child: Text(customer.name),
                        );
                      }),
                    ],
                    onChanged: (FavouriteCustomer? newValue) {
                      setState(() {
                        _selectedFavouriteCustomer = newValue;
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: Text(context.tr(
                    'Date: ${DateFormat('MMMM d, yyyy').format(_selectedDate)}')),
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) setState(() => _selectedDate = date);
                },
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.access_time),
                label:
                    Text(context.tr('Time: ${_selectedTime.format(context)}')),
                onPressed: () async {
                  final time = await showTimePicker(
                      context: context, initialTime: _selectedTime);
                  if (time != null) setState(() => _selectedTime = time);
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white))
                    : Text(context.tr('Save Appointment')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
