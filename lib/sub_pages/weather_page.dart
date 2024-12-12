import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class WeatherPage extends StatefulWidget {
  final String suggestion;

  const WeatherPage({Key? key, required this.suggestion}) : super(key: key);

  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  late String apiKey = '4fced7a67b33b80d79c969d67cab9205';
  late String apiUrl;
  late String errorMessage = '';
  late String cityName = '';
  late String weatherCondition = '';
  late String weatherDescription = '';
  late double temperature = 0;
  late TextEditingController searchController;
  bool isLoading = false;
  bool isLocationWeatherFetched =
      false; // New variable to track location weather fetch

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();

    if (!isLocationWeatherFetched) {
      _getCurrentLocation().then((position) {
        double latitude = position.latitude;
        double longitude = position.longitude;
        apiUrl =
            'http://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric';
        fetchWeather(apiUrl);
        isLocationWeatherFetched = true; // Update flag
      }).catchError((error) {
        setState(() {
          errorMessage = 'Error getting location: $error';
        });
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> fetchWeather(String query) async {
    setState(() {
      errorMessage = '';
      isLoading = true;
    });

    if (query.isEmpty) {
      // If the query is empty, fetch the current location weather
      _getCurrentLocation().then((position) {
        double latitude = position.latitude;
        double longitude = position.longitude;
        apiUrl =
            'http://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric';
        _fetchWeatherData(apiUrl);
      }).catchError((error) {
        setState(() {
          errorMessage = 'Error getting location: $error';
          isLoading = false;
        });
      });
    } else {
      // If the query is not empty, search for the city
      apiUrl =
          'http://api.openweathermap.org/data/2.5/weather?q=$query&appid=$apiKey&units=metric';
      _fetchWeatherData(apiUrl);
    }
  }

  Future<void> _fetchWeatherData(String apiUrl) async {
    try {
      final response = await http
          .get(Uri.parse(apiUrl))
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          cityName = jsonData['name'];
          weatherCondition = jsonData['weather'][0]['main'];
          weatherDescription = jsonData['weather'][0]['description'];
          temperature = jsonData['main']['temp'].toDouble();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              'Failed to fetch weather data. Please try again later.';
          isLoading = false;
        });
      }
    } on TimeoutException catch (_) {
      setState(() {
        errorMessage = 'Request timed out. Please try again later.';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching weather: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather Details',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Enter City Name',
                labelStyle: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w600,
                  fontSize: 14.0,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    fetchWeather(searchController.text);
                  },
                ),
              ),
              onSubmitted: (value) {
                fetchWeather(value);
              },
            ),
            const SizedBox(height: 16.0),
            isLoading
                ? const CircularProgressIndicator()
                : errorMessage.isNotEmpty
                    ? Text(
                        errorMessage,
                        style: const TextStyle(color: Colors.red),
                      )
                    : Column(
                        children: [
                          Icon(
                            _getWeatherIcon(weatherCondition),
                            size: 72.0,
                            color: Colors.blue, // Use your desired color
                          ),
                          const SizedBox(height: 16.0),
                          Text(
                            '$temperature°C',
                            style: const TextStyle(
                              fontSize: 36.0,
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            cityName,
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            weatherDescription,
                            style: const TextStyle(
                              fontSize: 24.0,
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16.0),
                        ],
                      ),
          ],
        ),
      ),
    );
  }

  IconData _getWeatherIcon(String condition) {
    switch (condition) {
      case 'Clear':
        return Icons.wb_sunny;
      case 'Clouds':
        return Icons.cloud;
      case 'Rain':
        return Icons.beach_access; // Change to appropriate rain icon
      case 'Snow':
        return Icons.ac_unit; // Change to appropriate snow icon
      default:
        return Icons.wb_sunny;
    }
  }
}
