import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(WeatherApp());
}

class WeatherApp extends StatefulWidget {
  @override
  _WeatherAppState createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  final WeatherFactory _wf = WeatherFactory('6d107eb4918816370bf9b547326b9879');
  Weather? _currentWeather;
  List<Weather>? _forecast;
  final TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  void _fetchWeatherData() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (position != null) {
        Weather weather = await _wf.currentWeatherByLocation(
          position.latitude,
          position.longitude,
        );
        List<Weather> forecast = await _wf.fiveDayForecastByLocation(
          position.latitude,
          position.longitude,
        );

        setState(() {
          _currentWeather = weather;
          _forecast = forecast;
        });
      } else {
        print('Failed to get device location.');
      }
    } catch (e) {
      print('Error fetching weather data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(brightness: Brightness.light),
      home: Scaffold(
        body: _buildUI(),
      ),
    );
  }

  Widget _buildUI() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.5], // Adjust the position of the gradient colors
          tileMode: TileMode.clamp,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _locationController,
            decoration: InputDecoration(
              labelText: 'Enter Location',
              filled: true, // Set to true to enable filling
              fillColor: Colors.white,
              suffixIcon: IconButton(
                icon: Icon(Icons.search),
                padding: const EdgeInsets.only(right: 20.0),
                onPressed: () {
                  // Fetch weather data based on location entered in TextField
                  _fetchWeatherByLocation();
                },
              ),
            ),
          ),
          SizedBox(height: 20.0),
          if (_currentWeather != null && _forecast != null)
            _buildWeatherInfo()
          else
            Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  void _fetchWeatherByLocation() {
    String location = _locationController.text;
    if (location.isNotEmpty) {
      _wf.currentWeatherByCityName(location).then((weather) {
        setState(() {
          _currentWeather = weather;
        });
      });

      _wf.fiveDayForecastByCityName(location).then((forecast) {
        setState(() {
          _forecast = forecast;
        });
      });
    }
  }

  Widget _buildWeatherInfo() {
    return Column(
      children: [
        SizedBox(height: 50.0),
        Text(
          _currentWeather?.areaName ?? '',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 20.0),
        Text(
          DateFormat("h:mm a").format(_currentWeather!.date!),
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),

        Image.network(
          "http://openweathermap.org/img/wn/${_currentWeather?.weatherIcon}@4x.png",
          height: 250,
        ),

        Text(
          _currentWeather?.weatherDescription ?? '',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        SizedBox(height: 10.0),
        Text(
          "${_currentWeather?.temperature?.celsius?.toStringAsFixed(0) ?? ""}°C",
          style: TextStyle(
            color: Colors.black,
            fontSize: 90,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 20.0), // Spacer between weather info and additional details
        Container(
          width: 300,
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.orange[200]!,
                Colors.white,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Humidity: ${_currentWeather?.humidity.toString() ?? ""}%",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                "Cloudiness: ${_currentWeather?.cloudiness.toString() ?? ""}%",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                "Wind Speed: ${_currentWeather?.windSpeed.toString() ?? ""} m/s",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10.0),
              _forecastTemperature(), // Display tomorrow's forecast temperature
            ],
          ),
        ),
      ],
    );
  }



  Widget _forecastTemperature() {
    if (_forecast != null && _forecast!.isNotEmpty) {
      // Get tomorrow's date
      DateTime tomorrow = DateTime.now().add(Duration(days: 1));

      // Search for tomorrow's forecast in the list
      Weather? tomorrowForecast;
      for (Weather forecast in _forecast!) {
        if (forecast.date!.day == tomorrow.day &&
            forecast.date!.month == tomorrow.month &&
            forecast.date!.year == tomorrow.year) {
          tomorrowForecast = forecast;
          break;
        }
      }

      if (tomorrowForecast != null) {
        return Text(
          "Tomorrow's Forecast: ${tomorrowForecast.temperature?.celsius?.toStringAsFixed(0) ?? ""}°C",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        );
      } else {
        return Text(
          "Tomorrow's Forecast: N/A",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        );
      }
    } else {
      return SizedBox(); // Return an empty SizedBox if forecast data is not available
    }
  }
}
