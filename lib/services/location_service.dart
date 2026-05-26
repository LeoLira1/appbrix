import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<bool> verificarPermissao() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;
    return true;
  }

  static Future<Position> getPosicaoAtual() async {
    final ok = await verificarPermissao();
    if (!ok) {
      throw Exception(
          'Permissão de localização negada. Ative nas configurações do dispositivo.');
    }
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
