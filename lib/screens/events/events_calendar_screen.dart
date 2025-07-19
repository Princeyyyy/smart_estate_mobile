import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../constants/colors.dart';
import '../../widgets/event_card.dart';
import '../../widgets/calendar_widget.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final String type;
  final bool isAttending;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.type,
    required this.isAttending,
  });
}

class EventsCalendarScreen extends StatefulWidget {
  const EventsCalendarScreen({super.key});

  @override
  State<EventsCalendarScreen> createState() => _EventsCalendarScreenState();
}

class _EventsCalendarScreenState extends State<EventsCalendarScreen> {
  DateTime _selectedDate = DateTime.now();

  final List<Event> _events = [
    Event(
      id: '1',
      title: 'Community Meeting',
      description:
          'Monthly community meeting to discuss estate matters and upcoming projects.',
      startTime: DateTime.now().add(const Duration(days: 2, hours: 10)),
      endTime: DateTime.now().add(const Duration(days: 2, hours: 12)),
      location: 'Clubhouse',
      type: 'Meeting',
      isAttending: false,
    ),
    Event(
      id: '2',
      title: 'Yoga Class',
      description: 'Weekly yoga session for all residents. Bring your own mat.',
      startTime: DateTime.now().add(const Duration(days: 1, hours: 18)),
      endTime: DateTime.now().add(const Duration(days: 1, hours: 19)),
      location: 'Recreation Center',
      type: 'Fitness',
      isAttending: true,
    ),
    Event(
      id: '3',
      title: 'Kids\' Movie Night',
      description: 'Family-friendly movie screening in the community hall.',
      startTime: DateTime.now().add(const Duration(days: 5, hours: 19)),
      endTime: DateTime.now().add(const Duration(days: 5, hours: 21)),
      location: 'Clubhouse',
      type: 'Entertainment',
      isAttending: false,
    ),
    Event(
      id: '4',
      title: 'Pool Maintenance',
      description: 'Swimming pool will be closed for cleaning and maintenance.',
      startTime: DateTime.now().add(const Duration(days: 7, hours: 8)),
      endTime: DateTime.now().add(const Duration(days: 7, hours: 16)),
      location: 'Swimming Pool',
      type: 'Maintenance',
      isAttending: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Events Calendar',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.textPrimary),
            onPressed: () {
              _showCreateEventDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar Widget
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.cardShadow,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CalendarWidget(
              selectedDate: _selectedDate,
              events: _events,
              onDateSelected: (date) {
                setState(() {
                  _selectedDate = date;
                });
              },
            ),
          ),

          // Events for selected date
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Events on ${DateFormat('EEEE, MMM dd').format(_selectedDate)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(child: _buildEventsList()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList() {
    final eventsOnSelectedDate =
        _events.where((event) {
          return event.startTime.year == _selectedDate.year &&
              event.startTime.month == _selectedDate.month &&
              event.startTime.day == _selectedDate.day;
        }).toList();

    if (eventsOnSelectedDate.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_note,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No events on this date',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: eventsOnSelectedDate.length,
      itemBuilder: (context, index) {
        final event = eventsOnSelectedDate[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: EventCard(
            event: event,
            onToggleAttendance: () => _toggleAttendance(event.id),
            onEdit: () => _editEvent(event),
            onDelete: () => _deleteEvent(event.id),
          ),
        );
      },
    );
  }

  void _showCreateEventDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Create Event'),
            content: const Text(
              'Event creation form would open here with fields for title, description, date, time, and location.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _createEvent();
                },
                child: const Text('Create'),
              ),
            ],
          ),
    );
  }

  void _toggleAttendance(String eventId) {
    // TODO: Toggle event attendance
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Attendance updated')));
  }

  void _editEvent(Event event) {
    // TODO: Open edit event dialog
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Edit ${event.title}')));
  }

  void _deleteEvent(String eventId) {
    // TODO: Delete event
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Event deleted')));
  }

  void _createEvent() {
    // TODO: Create new event
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Event created successfully')));
  }
}
