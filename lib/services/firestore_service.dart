import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment.dart';
import '../models/ticket.dart';
import '../models/announcement.dart';
import '../models/service.dart';
import '../models/tenant.dart';
import '../models/property.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // TENANT OPERATIONS
  static Future<Tenant?> getTenant(String tenantId) async {
    try {
      final doc = await _firestore.collection('tenants').doc(tenantId).get();
      if (doc.exists) {
        return Tenant.fromJson({'id': doc.id, ...doc.data()!});
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get tenant: $e');
    }
  }

  static Future<Tenant?> getTenantByFirebaseUid(String firebaseUid) async {
    try {
      final query =
          await _firestore
              .collection('tenants')
              .where('firebaseUid', isEqualTo: firebaseUid)
              .get();

      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        return Tenant.fromJson({'id': doc.id, ...doc.data()});
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get tenant by Firebase UID: $e');
    }
  }

  static Future<void> updateTenant(Tenant tenant) async {
    try {
      await _firestore.collection('tenants').doc(tenant.id).update({
        'name': tenant.name,
        'email': tenant.email,
        'phone': tenant.phone,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update tenant: $e');
    }
  }

  static Future<void> updateTenantOneSignalId(
    String tenantId,
    String oneSignalDeviceId,
  ) async {
    try {
      await _firestore.collection('tenants').doc(tenantId).update({
        'oneSignalDeviceId': oneSignalDeviceId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update tenant OneSignal ID: $e');
    }
  }

  static Stream<Tenant?> subscribeToTenant(String tenantId) {
    return _firestore.collection('tenants').doc(tenantId).snapshots().map((
      snapshot,
    ) {
      if (snapshot.exists) {
        return Tenant.fromJson({'id': snapshot.id, ...snapshot.data()!});
      }
      return null;
    });
  }

  // PAYMENT OPERATIONS
  static Future<List<Payment>> getTenantPayments(String tenantId) async {
    try {
      final query =
          await _firestore
              .collection('payments')
              .where('tenantId', isEqualTo: tenantId)
              .orderBy('createdAt', descending: true)
              .get();

      return query.docs.map((doc) {
        return Payment.fromJson({'id': doc.id, ...doc.data()});
      }).toList();
    } catch (e) {
      throw Exception('Failed to get tenant payments: $e');
    }
  }

  static Future<Payment?> getPayment(String paymentId) async {
    try {
      final doc = await _firestore.collection('payments').doc(paymentId).get();
      if (doc.exists) {
        return Payment.fromJson({'id': doc.id, ...doc.data()!});
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get payment: $e');
    }
  }

  static Future<String> addPayment(Payment payment) async {
    try {
      final docRef = await _firestore.collection('payments').add({
        ...payment.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add payment: $e');
    }
  }

  static Future<void> updatePayment(
    String paymentId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _firestore.collection('payments').doc(paymentId).update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update payment: $e');
    }
  }

  static Future<void> updatePaymentStatus(
    String paymentId,
    String status, {
    String? transactionId,
    String? paystackReference,
    String? paystackStatus,
    Map<String, dynamic>? paystackMetadata,
    String? paidDate,
  }) async {
    try {
      final updates = <String, dynamic>{
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (transactionId != null) updates['transactionId'] = transactionId;
      if (paystackReference != null)
        updates['paystackReference'] = paystackReference;
      if (paystackStatus != null) updates['paystackStatus'] = paystackStatus;
      if (paystackMetadata != null)
        updates['paystackMetadata'] = paystackMetadata;
      if (paidDate != null) updates['paidDate'] = paidDate;

      await _firestore.collection('payments').doc(paymentId).update(updates);
    } catch (e) {
      throw Exception('Failed to update payment status: $e');
    }
  }

  static Future<List<Payment>> getPaymentsByStatus(
    String tenantId,
    String status,
  ) async {
    try {
      final query =
          await _firestore
              .collection('payments')
              .where('tenantId', isEqualTo: tenantId)
              .where('status', isEqualTo: status)
              .orderBy('createdAt', descending: true)
              .get();

      return query.docs.map((doc) {
        return Payment.fromJson({'id': doc.id, ...doc.data()});
      }).toList();
    } catch (e) {
      throw Exception('Failed to get payments by status: $e');
    }
  }

  static Future<Payment?> getPaymentByReference(String reference) async {
    try {
      final query =
          await _firestore
              .collection('payments')
              .where('paystackReference', isEqualTo: reference)
              .limit(1)
              .get();

      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        return Payment.fromJson({'id': doc.id, ...doc.data()});
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get payment by reference: $e');
    }
  }

  static Future<double> getTenantOutstandingBalance(String tenantId) async {
    try {
      final query =
          await _firestore
              .collection('payments')
              .where('tenantId', isEqualTo: tenantId)
              .where('status', whereIn: ['Pending', 'Overdue'])
              .get();

      double outstanding = 0.0;
      for (final doc in query.docs) {
        final payment = Payment.fromJson({'id': doc.id, ...doc.data()});
        outstanding += payment.amount;
      }

      return outstanding;
    } catch (e) {
      throw Exception('Failed to get outstanding balance: $e');
    }
  }

  static Future<List<Payment>> getRecentPayments(
    String tenantId, {
    int limit = 10,
  }) async {
    try {
      final query =
          await _firestore
              .collection('payments')
              .where('tenantId', isEqualTo: tenantId)
              .orderBy('createdAt', descending: true)
              .limit(limit)
              .get();

      return query.docs.map((doc) {
        return Payment.fromJson({'id': doc.id, ...doc.data()});
      }).toList();
    } catch (e) {
      throw Exception('Failed to get recent payments: $e');
    }
  }

  // TICKET OPERATIONS
  static Future<List<Ticket>> getTenantTickets(String tenantId) async {
    try {
      final query =
          await _firestore
              .collection('tickets')
              .where('tenantId', isEqualTo: tenantId)
              .orderBy('createdAt', descending: true)
              .get();

      return query.docs.map((doc) {
        return Ticket.fromJson({'id': doc.id, ...doc.data()});
      }).toList();
    } catch (e) {
      throw Exception('Failed to get tenant tickets: $e');
    }
  }

  static Future<Ticket?> getTicket(String ticketId) async {
    try {
      final doc = await _firestore.collection('tickets').doc(ticketId).get();
      if (doc.exists) {
        return Ticket.fromJson({'id': doc.id, ...doc.data()!});
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get ticket: $e');
    }
  }

  static Future<String> submitTicket(Ticket ticket) async {
    try {
      final docRef = await _firestore.collection('tickets').add({
        ...ticket.toJson(),
        'status': 'Pending',
        'responses': [],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to submit ticket: $e');
    }
  }

  static Future<void> updateTicket(
    String ticketId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _firestore.collection('tickets').doc(ticketId).update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update ticket: $e');
    }
  }

  // ANNOUNCEMENT OPERATIONS
  static Future<List<Announcement>> getActiveAnnouncements() async {
    try {
      final query =
          await _firestore
              .collection('announcements')
              .where('isActive', isEqualTo: true)
              .orderBy('createdAt', descending: true)
              .get();

      return query.docs.map((doc) {
        return Announcement.fromJson({'id': doc.id, ...doc.data()});
      }).toList();
    } catch (e) {
      throw Exception('Failed to get announcements: $e');
    }
  }

  static Future<Announcement?> getAnnouncement(String announcementId) async {
    try {
      final doc =
          await _firestore
              .collection('announcements')
              .doc(announcementId)
              .get();
      if (doc.exists) {
        return Announcement.fromJson({'id': doc.id, ...doc.data()!});
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get announcement: $e');
    }
  }

  // SERVICE OPERATIONS (Marketplace)
  static Future<List<Service>> getServices({String? category}) async {
    try {
      Query query = _firestore
          .collection('services')
          .where('isActive', isEqualTo: true);

      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        return Service.fromJson({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to get services: $e');
    }
  }

  static Future<Service?> getService(String serviceId) async {
    try {
      final doc = await _firestore.collection('services').doc(serviceId).get();
      if (doc.exists) {
        return Service.fromJson({'id': doc.id, ...doc.data()!});
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get service: $e');
    }
  }

  // PROPERTY OPERATIONS
  static Future<List<Property>> getProperties() async {
    try {
      final query =
          await _firestore.collection('properties').orderBy('name').get();

      return query.docs.map((doc) {
        return Property.fromJson({'id': doc.id, ...doc.data()});
      }).toList();
    } catch (e) {
      throw Exception('Failed to get properties: $e');
    }
  }

  static Future<Property?> getProperty(String propertyId) async {
    try {
      final doc =
          await _firestore.collection('properties').doc(propertyId).get();
      if (doc.exists) {
        return Property.fromJson({'id': doc.id, ...doc.data()!});
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get property: $e');
    }
  }

  // REAL-TIME LISTENERS
  static Stream<List<Payment>> subscribeToTenantPayments(String tenantId) {
    return _firestore
        .collection('payments')
        .where('tenantId', isEqualTo: tenantId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Payment.fromJson({'id': doc.id, ...doc.data()});
          }).toList();
        });
  }

  static Stream<List<Ticket>> subscribeToTenantTickets(String tenantId) {
    return _firestore
        .collection('tickets')
        .where('tenantId', isEqualTo: tenantId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Ticket.fromJson({'id': doc.id, ...doc.data()});
          }).toList();
        });
  }

  static Stream<List<Announcement>> subscribeToAnnouncements() {
    return _firestore
        .collection('announcements')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Announcement.fromJson({'id': doc.id, ...doc.data()});
          }).toList();
        });
  }

  // UTILITY METHODS
  static Future<Map<String, dynamic>> getTenantDashboardData(
    String tenantId,
  ) async {
    try {
      // Get tenant info
      final tenant = await getTenant(tenantId);
      if (tenant == null) throw Exception('Tenant not found');

      // Get recent payments
      final paymentsQuery =
          await _firestore
              .collection('payments')
              .where('tenantId', isEqualTo: tenantId)
              .orderBy('createdAt', descending: true)
              .limit(5)
              .get();

      final payments =
          paymentsQuery.docs.map((doc) {
            return Payment.fromJson({'id': doc.id, ...doc.data()});
          }).toList();

      // Get pending tickets
      final ticketsQuery =
          await _firestore
              .collection('tickets')
              .where('tenantId', isEqualTo: tenantId)
              .where('status', whereIn: ['Pending', 'In Progress'])
              .orderBy('createdAt', descending: true)
              .limit(3)
              .get();

      final tickets =
          ticketsQuery.docs.map((doc) {
            return Ticket.fromJson({'id': doc.id, ...doc.data()});
          }).toList();

      // Get recent announcements
      final announcementsQuery =
          await _firestore
              .collection('announcements')
              .where('isActive', isEqualTo: true)
              .orderBy('createdAt', descending: true)
              .limit(3)
              .get();

      final announcements =
          announcementsQuery.docs.map((doc) {
            return Announcement.fromJson({'id': doc.id, ...doc.data()});
          }).toList();

      // Calculate outstanding balance
      double outstandingBalance = 0;
      for (final payment in payments) {
        if (payment.status == 'Pending' || payment.status == 'Overdue') {
          outstandingBalance += payment.amount;
        }
      }

      return {
        'tenant': tenant,
        'recentPayments': payments,
        'pendingTickets': tickets,
        'announcements': announcements,
        'outstandingBalance': outstandingBalance,
      };
    } catch (e) {
      throw Exception('Failed to get dashboard data: $e');
    }
  }
}
