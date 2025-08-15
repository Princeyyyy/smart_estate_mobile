import '../models/tenant.dart';
import '../models/payment.dart';
import 'firestore_service.dart';

class RentCalculationService {
  /// Calculate the next rent due date based on move-in date
  static DateTime calculateNextRentDueDate(String moveInDateStr) {
    try {
      final moveInDate = DateTime.parse(moveInDateStr);
      final now = DateTime.now();

      // Start from move-in date
      DateTime nextDue = DateTime(
        moveInDate.year,
        moveInDate.month,
        moveInDate.day,
      );

      // Keep adding months until we find the next due date after today
      while (nextDue.isBefore(now) || nextDue.isAtSameMomentAs(now)) {
        // Add one month
        if (nextDue.month == 12) {
          nextDue = DateTime(nextDue.year + 1, 1, nextDue.day);
        } else {
          nextDue = DateTime(nextDue.year, nextDue.month + 1, nextDue.day);
        }
      }

      return nextDue;
    } catch (e) {
      // Fallback to first of next month if parsing fails
      final now = DateTime.now();
      return DateTime(now.year, now.month + 1, 1);
    }
  }

  /// Calculate the current rent due date (the most recent due date that has passed or is today)
  static DateTime calculateCurrentRentDueDate(String moveInDateStr) {
    try {
      final moveInDate = DateTime.parse(moveInDateStr);
      final now = DateTime.now();

      // Start from move-in date
      DateTime currentDue = DateTime(
        moveInDate.year,
        moveInDate.month,
        moveInDate.day,
      );

      // Keep adding months until we find the current period
      while (true) {
        // Calculate next month's due date
        DateTime nextDue;
        if (currentDue.month == 12) {
          nextDue = DateTime(currentDue.year + 1, 1, currentDue.day);
        } else {
          nextDue = DateTime(
            currentDue.year,
            currentDue.month + 1,
            currentDue.day,
          );
        }

        // If next due date is in the future, current due date is what we want
        if (nextDue.isAfter(now)) {
          break;
        }

        currentDue = nextDue;
      }

      return currentDue;
    } catch (e) {
      // Fallback to first of current month if parsing fails
      final now = DateTime.now();
      return DateTime(now.year, now.month, 1);
    }
  }

  /// Check if rent is overdue based on move-in date
  static bool isRentOverdue(String moveInDateStr) {
    final currentDueDate = calculateCurrentRentDueDate(moveInDateStr);
    final now = DateTime.now();

    // Rent is overdue if current due date has passed
    return now.isAfter(currentDueDate);
  }

  /// Get days until next rent is due
  static int daysUntilNextRent(String moveInDateStr) {
    final nextDueDate = calculateNextRentDueDate(moveInDateStr);
    final now = DateTime.now();

    return nextDueDate.difference(now).inDays;
  }

  /// Get days since rent was due (if overdue)
  static int daysSinceRentDue(String moveInDateStr) {
    final currentDueDate = calculateCurrentRentDueDate(moveInDateStr);
    final now = DateTime.now();

    if (now.isAfter(currentDueDate)) {
      return now.difference(currentDueDate).inDays;
    }
    return 0;
  }

  /// Generate rent payment record for current period if it doesn't exist
  static Future<Payment?> generateCurrentRentPayment(Tenant tenant) async {
    try {
      final currentDueDate = calculateCurrentRentDueDate(tenant.moveInDate);
      final now = DateTime.now();

      // Check if payment already exists for this period
      final existingPayments = await FirestoreService.getTenantPayments(
        tenant.id,
      );

      // Look for rent payment for current period
      final currentPeriodPayment =
          existingPayments.where((payment) {
            if (payment.type != 'Rent') return false;

            try {
              final paymentDueDate = DateTime.parse(payment.dueDate);
              // Check if payment is for the same month and year as current due date
              return paymentDueDate.year == currentDueDate.year &&
                  paymentDueDate.month == currentDueDate.month;
            } catch (e) {
              return false;
            }
          }).toList();

      // If payment already exists, return null (no need to generate)
      if (currentPeriodPayment.isNotEmpty) {
        return currentPeriodPayment.first;
      }

      // Generate new rent payment
      final payment = Payment(
        id: '', // Will be set by Firestore
        tenantId: tenant.id,
        tenant: tenant.name,
        unit: tenant.unit,
        amount: tenant.rent,
        type: 'Rent',
        status: now.isAfter(currentDueDate) ? 'Overdue' : 'Pending',
        paymentMethod: 'Pending', // Will be set when payment is made
        dueDate: currentDueDate.toIso8601String(),
        paidDate: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Add to Firestore
      final paymentId = await FirestoreService.addPayment(payment);

      return payment.copyWith(id: paymentId);
    } catch (e) {
      print('Error generating rent payment: $e');
      return null;
    }
  }

  /// Get current rent status for tenant
  static Future<Map<String, dynamic>> getCurrentRentStatus(
    Tenant tenant,
  ) async {
    try {
      final currentDueDate = calculateCurrentRentDueDate(tenant.moveInDate);
      final nextDueDate = calculateNextRentDueDate(tenant.moveInDate);
      final now = DateTime.now();

      // Get existing payments
      final payments = await FirestoreService.getTenantPayments(tenant.id);

      // Look for current period rent payment
      Payment? currentRentPayment;
      for (final payment in payments) {
        if (payment.type == 'Rent') {
          try {
            final paymentDueDate = DateTime.parse(payment.dueDate);
            if (paymentDueDate.year == currentDueDate.year &&
                paymentDueDate.month == currentDueDate.month) {
              currentRentPayment = payment;
              break;
            }
          } catch (e) {
            continue;
          }
        }
      }

      // If no current rent payment exists, generate one
      if (currentRentPayment == null) {
        currentRentPayment = await generateCurrentRentPayment(tenant);
      }

      // Calculate outstanding amount (only unpaid rent)
      double outstandingAmount = 0.0;
      String status = 'Paid';

      if (currentRentPayment != null &&
          (currentRentPayment.status == 'Pending' ||
              currentRentPayment.status == 'Overdue')) {
        outstandingAmount = currentRentPayment.amount;
        status = now.isAfter(currentDueDate) ? 'Overdue' : 'Pending';
      }

      return {
        'currentRentPayment': currentRentPayment,
        'outstandingAmount': outstandingAmount,
        'status': status,
        'currentDueDate': currentDueDate,
        'nextDueDate': nextDueDate,
        'isOverdue': now.isAfter(currentDueDate) && outstandingAmount > 0,
        'daysUntilDue': nextDueDate.difference(now).inDays,
        'daysSinceDue':
            now.isAfter(currentDueDate)
                ? now.difference(currentDueDate).inDays
                : 0,
      };
    } catch (e) {
      print('Error getting rent status: $e');
      return {
        'currentRentPayment': null,
        'outstandingAmount': 0.0,
        'status': 'Error',
        'currentDueDate': DateTime.now(),
        'nextDueDate': DateTime.now(),
        'isOverdue': false,
        'daysUntilDue': 0,
        'daysSinceDue': 0,
      };
    }
  }

  /// Format date for display
  static String formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// Get rent period description
  static String getRentPeriodDescription(DateTime dueDate) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[dueDate.month - 1]} ${dueDate.year}';
  }
}
