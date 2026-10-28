import 'package:geolocator/geolocator.dart';

/// Stato dei permessi di posizione, come lo mostra la schermata.
enum LocationUiState {
  servicesOff,
  denied,
  deniedForever,
  whileInUseOnly,
  ready,
}

/// I servizi spenti hanno la precedenza sul permesso.
/// Solo `always` è «pronto»: in background `whileInUse` non basta.
LocationUiState describeLocationState({
  required bool serviceEnabled,
  required LocationPermission permission,
}) {
  if (!serviceEnabled) return LocationUiState.servicesOff;
  switch (permission) {
    case LocationPermission.always:
      return LocationUiState.ready;
    case LocationPermission.whileInUse:
      return LocationUiState.whileInUseOnly;
    case LocationPermission.deniedForever:
      return LocationUiState.deniedForever;
    case LocationPermission.denied:
    case LocationPermission.unableToDetermine:
      return LocationUiState.denied;
  }
}

/// Il tracciamento parte solo con servizi accesi e permesso concesso.
/// «Solo in uso» basta per provare in primo piano; la schermata avvisa che
/// in background non funziona.
bool canStartTracking(LocationUiState state) =>
    state == LocationUiState.ready || state == LocationUiState.whileInUseOnly;

/// `null` se il permesso notifiche è concesso, altrimenti il testo da mostrare.
String? notificationHint({required bool granted}) {
  if (granted) return null;
  return 'Le notifiche sono disattivate: attivale dalle Impostazioni di iOS.';
}
