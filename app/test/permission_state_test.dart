import 'package:allerta_velox/permission_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  group('describeLocationState', () {
    test('servizi spenti hanno la precedenza sul permesso', () {
      expect(
        describeLocationState(
            serviceEnabled: false, permission: LocationPermission.always),
        LocationUiState.servicesOff,
      );
    });

    test('solo in uso viene riconosciuto, perche in background non basta', () {
      expect(
        describeLocationState(
            serviceEnabled: true, permission: LocationPermission.whileInUse),
        LocationUiState.whileInUseOnly,
      );
    });

    test('permesso non ancora chiesto risulta negato', () {
      expect(
        describeLocationState(
            serviceEnabled: true, permission: LocationPermission.denied),
        LocationUiState.denied,
      );
    });

    test('permesso non determinabile viene trattato come negato', () {
      expect(
        describeLocationState(
            serviceEnabled: true,
            permission: LocationPermission.unableToDetermine),
        LocationUiState.denied,
      );
    });

    test('negato per sempre manda alle Impostazioni', () {
      expect(
        describeLocationState(
            serviceEnabled: true, permission: LocationPermission.deniedForever),
        LocationUiState.deniedForever,
      );
    });

    test('Sempre con servizi accesi e pronto', () {
      expect(
        describeLocationState(
            serviceEnabled: true, permission: LocationPermission.always),
        LocationUiState.ready,
      );
    });
  });

  group('notificationHint', () {
    test('permesso concesso: nessun suggerimento', () {
      expect(notificationHint(granted: true), isNull);
    });

    test('permesso negato: rimanda alle Impostazioni', () {
      expect(notificationHint(granted: false), contains('Impostazioni'));
    });
  });

  group('canStartTracking', () {
    test('Sempre permette di partire', () {
      expect(canStartTracking(LocationUiState.ready), isTrue);
    });

    test('solo in uso permette di partire, per provare in primo piano', () {
      expect(canStartTracking(LocationUiState.whileInUseOnly), isTrue);
    });

    test('servizi spenti o permesso negato impediscono di partire', () {
      expect(canStartTracking(LocationUiState.servicesOff), isFalse);
      expect(canStartTracking(LocationUiState.denied), isFalse);
      expect(canStartTracking(LocationUiState.deniedForever), isFalse);
    });
  });
}
