import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weatherapp/bloc/weather_bloc.dart';
import 'package:weatherapp/screens/home_screen.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final futurePosition = _determinePosition();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<Position>(
        future: futurePosition,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snap.hasError) {
            return Scaffold(
              body: Center(
                child: Text(
                  'Error: ${snap.error}',
                  style: const TextStyle(fontSize: 18, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          } else if (snap.hasData) {
            return BlocProvider(
              create: (context) => WeatherBlocBloc()
                ..add(FetchWeather(snap.data as Position)),
              child: const HomeScreen(),
            );
          } else {
            return const Scaffold(
              body: Center(
                child: Text('Unexpected error occurred.'),
              ),
            );
          }
        },
      ),
    );
  }
}

/// Service for determining the current position of the device.
///
/// When the location services are not enabled or permissions
/// are denied, the `Future` will return an error.
Future<Position> _determinePosition() async {
  if (!await Geolocator.isLocationServiceEnabled()) {
    return Future.error('Location services are disabled.');
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied.');
    }
  }
  if (permission == LocationPermission.deniedForever) {
    return Future.error(
      'Location permissions are permanently denied. Enable permissions from settings.',
    );
  }

  return await Geolocator.getCurrentPosition();
}
