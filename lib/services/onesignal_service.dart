import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter/foundation.dart';
import 'firestore_service.dart';
import 'auth_service.dart';

class OneSignalService {
  // OneSignal App ID
  static const String appId = '43b29bee-9325-4cdf-8441-ec75247245d7';

  static bool _isInitialized = false;

  /// Initialize OneSignal with the app ID
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Remove this method to stop OneSignal Debugging
      if (kDebugMode) {
        OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      }

      // OneSignal Initialization
      OneSignal.initialize(appId);

      // The promptForPushNotificationsWithUserResponse function will show the iOS or Android push notification prompt.
      // We recommend removing the following code and instead using an In-App Message to prompt for notification permission
      OneSignal.Notifications.requestPermission(true);

      _isInitialized = true;

      if (kDebugMode) {
        print('OneSignal initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing OneSignal: $e');
      }
    }
  }

  /// Request notification permissions and get device ID
  static Future<String?> requestPermissionAndGetDeviceId() async {
    try {
      // Request permission
      final permission = await OneSignal.Notifications.requestPermission(true);

      if (kDebugMode) {
        print('Notification permission granted: $permission');
      }

      if (permission) {
        // Wait for OneSignal to register the device
        await Future.delayed(const Duration(seconds: 2));

        // Try to get device ID with retries
        String? subscriptionId;
        for (int i = 0; i < 5; i++) {
          subscriptionId = OneSignal.User.pushSubscription.id;
          if (subscriptionId != null) break;

          if (kDebugMode) {
            print(
              'Waiting for OneSignal device registration... attempt ${i + 1}',
            );
          }
          await Future.delayed(const Duration(seconds: 1));
        }

        if (kDebugMode) {
          print('OneSignal Device ID: $subscriptionId');
        }

        return subscriptionId;
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error requesting notification permission: $e');
      }
      return null;
    }
  }

  /// Get current device ID
  static String? getCurrentDeviceId() {
    try {
      return OneSignal.User.pushSubscription.id;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting current device ID: $e');
      }
      return null;
    }
  }

  /// Save device ID to user's Firestore document
  static Future<void> saveDeviceIdToFirestore() async {
    try {
      final deviceId = getCurrentDeviceId();
      if (deviceId == null) {
        if (kDebugMode) {
          print('No device ID available to save');
        }
        return;
      }

      final tenant = await AuthService.getCurrentTenant();
      if (tenant == null) {
        if (kDebugMode) {
          print('No current tenant found');
        }
        return;
      }

      // Update tenant with OneSignal device ID
      await FirestoreService.updateTenantOneSignalId(tenant.id, deviceId);

      if (kDebugMode) {
        print('Device ID saved to Firestore: $deviceId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving device ID to Firestore: $e');
      }
    }
  }

  /// Set up notification handlers
  static void setupNotificationHandlers() {
    // Handle notification opened
    OneSignal.Notifications.addClickListener((event) {
      if (kDebugMode) {
        print('Notification clicked: ${event.notification.notificationId}');
        print('Notification data: ${event.notification.additionalData}');
      }

      // Handle notification tap - you can navigate to specific screens based on data
      _handleNotificationTap(event.notification);
    });

    // Handle notification received while app is in foreground
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      if (kDebugMode) {
        print(
          'Notification received in foreground: ${event.notification.title}',
        );
      }

      // You can modify the notification or prevent it from showing
      // For now, we'll let it display normally
      event.notification.display();
    });

    // Handle permission changes
    OneSignal.Notifications.addPermissionObserver((state) {
      if (kDebugMode) {
        print('Notification permission changed: $state');
      }
    });

    // Handle subscription changes
    OneSignal.User.pushSubscription.addObserver((state) {
      if (kDebugMode) {
        print('Push subscription changed: ${state.current.id}');
        print('Push subscription opted in: ${state.current.optedIn}');
      }

      // Save new device ID when subscription changes and user is opted in
      if (state.current.id != null && state.current.optedIn) {
        if (kDebugMode) {
          print('Device registered and opted in, saving to Firestore...');
        }
        saveDeviceIdToFirestore();
      }
    });
  }

  /// Manually trigger device registration (useful for debugging)
  static Future<void> manuallyRegisterDevice() async {
    try {
      if (kDebugMode) {
        print('Manually triggering device registration...');
      }

      // Request permission if not already granted
      await OneSignal.Notifications.requestPermission(true);

      // Wait a bit for registration
      await Future.delayed(const Duration(seconds: 3));

      // Get device ID
      final deviceId = getCurrentDeviceId();

      if (deviceId != null) {
        if (kDebugMode) {
          print('Manual registration successful. Device ID: $deviceId');
        }

        // Save to Firestore
        await saveDeviceIdToFirestore();

        // Set user tags
        await setTenantTags();

        if (kDebugMode) {
          print('Device registration and tagging complete');
        }
      } else {
        if (kDebugMode) {
          print('Manual registration failed - no device ID obtained');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in manual device registration: $e');
      }
    }
  }

  /// Handle notification tap
  static void _handleNotificationTap(OSNotification notification) {
    // Extract data from notification
    final data = notification.additionalData;

    if (data != null) {
      // Handle different notification types based on data
      final type = data['type'] as String?;

      switch (type) {
        case 'payment_reminder':
          // Navigate to payment screen
          break;
        case 'maintenance_update':
          // Navigate to maintenance screen
          break;
        case 'announcement':
          // Navigate to announcements
          break;
        case 'community_post':
          // Navigate to community post
          break;
        default:
          // Default action - maybe navigate to notifications screen
          break;
      }
    }
  }

  /// Send a tag to OneSignal for user segmentation
  static Future<void> setUserTags(Map<String, String> tags) async {
    try {
      OneSignal.User.addTags(tags);

      if (kDebugMode) {
        print('User tags set: $tags');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error setting user tags: $e');
      }
    }
  }

  /// Set user tags based on tenant information
  static Future<void> setTenantTags() async {
    try {
      final tenant = await AuthService.getCurrentTenant();
      if (tenant == null) return;

      final tags = {
        'tenant_id': tenant.id,
        'unit': tenant.unit,
        'tenant_status': tenant.status,
        'user_type': 'tenant',
      };

      await setUserTags(tags);
    } catch (e) {
      if (kDebugMode) {
        print('Error setting tenant tags: $e');
      }
    }
  }

  /// Check if notifications are enabled
  static Future<bool> areNotificationsEnabled() async {
    try {
      return OneSignal.User.pushSubscription.optedIn ?? false;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking notification status: $e');
      }
      return false;
    }
  }

  /// Opt user out of notifications
  static Future<void> optOut() async {
    try {
      OneSignal.User.pushSubscription.optOut();

      if (kDebugMode) {
        print('User opted out of notifications');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error opting out: $e');
      }
    }
  }

  /// Opt user back into notifications
  static Future<void> optIn() async {
    try {
      OneSignal.User.pushSubscription.optIn();

      if (kDebugMode) {
        print('User opted into notifications');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error opting in: $e');
      }
    }
  }
}
