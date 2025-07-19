import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../constants/colors.dart';
import '../../widgets/booking_time_slot.dart';
import '../../widgets/booking_calendar.dart';

class FacilityBookingScreen extends StatefulWidget {
  final String facilityName;

  const FacilityBookingScreen({super.key, required this.facilityName});

  @override
  State<FacilityBookingScreen> createState() => _FacilityBookingScreenState();
}

class _FacilityBookingScreenState extends State<FacilityBookingScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedTimeSlot;
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;

  final Map<String, List<String>> _availableSlots = {
    'Fitness Center': [
      '06:00 - 07:00',
      '07:00 - 08:00',
      '08:00 - 09:00',
      '09:00 - 10:00',
      '17:00 - 18:00',
      '18:00 - 19:00',
      '19:00 - 20:00',
      '20:00 - 21:00',
    ],
    'Swimming Pool': [
      '06:00 - 07:00',
      '07:00 - 08:00',
      '08:00 - 09:00',
      '18:00 - 19:00',
      '19:00 - 20:00',
    ],
    'Tennis Court': [
      '06:00 - 08:00',
      '08:00 - 10:00',
      '16:00 - 18:00',
      '18:00 - 20:00',
    ],
    'Clubhouse': [
      '09:00 - 12:00',
      '12:00 - 15:00',
      '15:00 - 18:00',
      '18:00 - 21:00',
    ],
    'BBQ Area': [
      '08:00 - 11:00',
      '11:00 - 14:00',
      '14:00 - 17:00',
      '17:00 - 20:00',
    ],
    'Guest Parking': [
      '00:00 - 24:00', // All day slots
    ],
  };

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

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
        title: Text(
          'Book ${widget.facilityName}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Facility Info Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getFacilityIcon(widget.facilityName),
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.facilityName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              _getFacilityDescription(widget.facilityName),
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Facility Rules
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Booking Rules',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._getFacilityRules(widget.facilityName).map(
                          (rule) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '• ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    rule,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Date Selection
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Date',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  BookingCalendar(
                    selectedDate: _selectedDate,
                    onDateSelected: (date) {
                      setState(() {
                        _selectedDate = date;
                        _selectedTimeSlot =
                            null; // Reset time slot when date changes
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Time Slot Selection
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available Time Slots - ${DateFormat('MMM dd, yyyy').format(_selectedDate)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        _availableSlots[widget.facilityName]
                            ?.map(
                              (slot) => BookingTimeSlot(
                                timeSlot: slot,
                                isSelected: _selectedTimeSlot == slot,
                                isAvailable: _isSlotAvailable(slot),
                                onTap: () {
                                  if (_isSlotAvailable(slot)) {
                                    setState(() {
                                      _selectedTimeSlot = slot;
                                    });
                                  }
                                },
                              ),
                            )
                            .toList() ??
                        [],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Additional Options
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Additional Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Notes
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Special Notes (Optional)',
                      hintText: 'Any special requirements or notes...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Book Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      _selectedTimeSlot != null && !_isLoading
                          ? _confirmBooking
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : Text(
                            'Confirm Booking',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  IconData _getFacilityIcon(String facilityName) {
    switch (facilityName) {
      case 'Fitness Center':
        return Icons.fitness_center;
      case 'Swimming Pool':
        return Icons.pool;
      case 'Tennis Court':
        return Icons.sports_tennis;
      case 'Clubhouse':
        return Icons.business;
      case 'BBQ Area':
        return Icons.outdoor_grill;
      case 'Guest Parking':
        return Icons.local_parking;
      default:
        return Icons.place;
    }
  }

  String _getFacilityDescription(String facilityName) {
    switch (facilityName) {
      case 'Fitness Center':
        return 'Fully equipped gym with modern equipment';
      case 'Swimming Pool':
        return 'Olympic-size pool with lifeguard on duty';
      case 'Tennis Court':
        return 'Professional tennis court with equipment rental';
      case 'Clubhouse':
        return 'Community hall for events and gatherings';
      case 'BBQ Area':
        return 'Outdoor grilling area with picnic tables';
      case 'Guest Parking':
        return 'Designated parking spots for visitors';
      default:
        return 'Estate facility available for booking';
    }
  }

  List<String> _getFacilityRules(String facilityName) {
    switch (facilityName) {
      case 'Fitness Center':
        return [
          'Maximum 2-hour booking per day',
          'Must bring own towel and water bottle',
          'Clean equipment after use',
          'No outside food or drinks allowed',
        ];
      case 'Swimming Pool':
        return [
          'Children under 12 must be supervised',
          'No diving in shallow end',
          'Maximum 20 people at a time',
          'Pool closes during thunderstorms',
        ];
      case 'Tennis Court':
        return [
          'Maximum 2-hour booking per day',
          'Proper tennis attire required',
          'Equipment rental available at reception',
          'Court must be cleaned after use',
        ];
      case 'Clubhouse':
        return [
          'Minimum 24-hour advance booking required',
          'Responsible for cleaning after event',
          'No loud music after 10 PM',
          'Maximum capacity 50 people',
        ];
      case 'BBQ Area':
        return [
          'Maximum 4-hour booking per day',
          'Must clean grill and area after use',
          'No glass containers allowed',
          'Fire extinguisher available on-site',
        ];
      case 'Guest Parking':
        return [
          'Maximum 48-hour parking',
          'Valid visitor pass required',
          'No commercial vehicles',
          'Report to security upon arrival',
        ];
      default:
        return [
          'Follow all estate rules and regulations',
          'Respect other residents',
          'Clean up after use',
        ];
    }
  }

  bool _isSlotAvailable(String slot) {
    // Simulate some slots being unavailable
    final unavailableSlots = ['09:00 - 10:00', '18:00 - 19:00'];
    return !unavailableSlots.contains(slot);
  }

  Future<void> _confirmBooking() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      _showBookingConfirmation();
    }
  }

  void _showBookingConfirmation() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Booking Confirmed'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Facility: ${widget.facilityName}'),
                Text(
                  'Date: ${DateFormat('MMM dd, yyyy').format(_selectedDate)}',
                ),
                Text('Time: $_selectedTimeSlot'),
                if (_notesController.text.isNotEmpty)
                  Text('Notes: ${_notesController.text}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}
