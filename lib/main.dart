import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),

      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  TextEditingController usernameController =
      TextEditingController();

  String selectedRole = "Passenger";

  void login() {

    if (usernameController.text.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(
          content: Text("Please enter username"),
        ),
      );

    } else {

      Navigator.push(

        context,

        MaterialPageRoute(

          builder: (context) => CheckInPage(
            username: usernameController.text,
            role: selectedRole,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.indigo.shade50,

      body: Center(

        child: SingleChildScrollView(

          child: Padding(

            padding: EdgeInsets.all(25),

            child: Card(

              elevation: 10,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),

              child: Padding(

                padding: EdgeInsets.all(25),

                child: Column(

                  mainAxisSize: MainAxisSize.min,

                  children: [

                    Icon(
                      Icons.location_on,
                      size: 100,
                      color: Colors.indigo,
                    ),

                    SizedBox(height: 20),

                    Text(
                      "Ride Hailing System",

                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),

                    SizedBox(height: 10),

                    Text(
                      "GPS Check-In Application",

                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),

                    SizedBox(height: 30),

                    TextField(

                      controller: usernameController,

                      decoration: InputDecoration(

                        labelText: "Username",

                        prefixIcon: Icon(Icons.person),

                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(15),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    DropdownButtonFormField<String>(

                      value: selectedRole,

                      decoration: InputDecoration(

                        labelText: "Select Role",

                        prefixIcon: Icon(Icons.work),

                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(15),
                        ),
                      ),

                      items: [

                        DropdownMenuItem(
                          value: "Passenger",
                          child: Text("Passenger"),
                        ),

                        DropdownMenuItem(
                          value: "Driver",
                          child: Text("Driver"),
                        ),
                      ],

                      onChanged: (value) {

                        setState(() {
                          selectedRole = value!;
                        });
                      },
                    ),

                    SizedBox(height: 30),

                    SizedBox(

                      width: double.infinity,
                      height: 50,

                      child: ElevatedButton(

                        onPressed: login,

                        style: ElevatedButton.styleFrom(

                          backgroundColor: Colors.indigo,

                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(15),
                          ),
                        ),

                        child: Text(
                          "LOGIN",

                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CheckInPage extends StatefulWidget {

  final String username;
  final String role;

  CheckInPage({
    required this.username,
    required this.role,
  });

  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {

  String locationText = "Location not captured";
  String timeText = "Time not captured";
  String statusText = "";

  Future<void> checkInLocation() async {

    try {

      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {

        setState(() {
          statusText = "Please enable GPS";
        });

        return;
      }

      permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {

        permission =
            await Geolocator.requestPermission();
      }

      Position position =
          await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(
        Duration(seconds: 10),
      );

      String currentTime =
          DateFormat('dd/MM/yyyy HH:mm:ss')
              .format(DateTime.now());

      setState(() {

        locationText =
            "Latitude: ${position.latitude}\nLongitude: ${position.longitude}";

        timeText = currentTime;

        statusText = "Check-In Successful!";
        
      });
      await http.post(

      Uri.parse('https://example.com/checkin'),

      body: {

      'username': widget.username,
      'role': widget.role,
      'location': locationText,
      'time': timeText,
      },
    );

print("Data sent successfully");
      

      showDialog(

        context: context,

        builder: (context) {

          return AlertDialog(

            title: Text("Check-In Successful"),

            content: Column(

              mainAxisSize: MainAxisSize.min,

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text("Username: ${widget.username}"),

                SizedBox(height: 10),

                Text("Role: ${widget.role}"),

                SizedBox(height: 10),

                Text(locationText),

                SizedBox(height: 10),

                Text("Time: $timeText"),
              ],
            ),

            actions: [

              TextButton(

                onPressed: () {
                  Navigator.pop(context);
                },

                child: Text("OK"),
              ),
            ],
          );
        },
      );

    } catch (e) {

      setState(() {
        statusText = "Unable to capture GPS";
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: Text("Check-In Dashboard"),

        backgroundColor: Colors.indigo,
      ),

      backgroundColor: Colors.indigo.shade50,

      body: Padding(

        padding: EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.stretch,

          children: [

            Card(

              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(15),
              ),

              child: Padding(

                padding: EdgeInsets.all(20),

                child: Column(

                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Text(
                      "Welcome ${widget.username}",

                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),

                    SizedBox(height: 10),

                    Text(
                      "Role: ${widget.role}",

                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            Card(

              child: Padding(

                padding: EdgeInsets.all(20),

                child: Column(

                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Text(
                      "GPS Location",

                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    SizedBox(height: 10),

                    Text(locationText),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            Card(

              child: Padding(

                padding: EdgeInsets.all(20),

                child: Column(

                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Text(
                      "Check-In Time",

                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    SizedBox(height: 10),

                    Text(timeText),
                  ],
                ),
              ),
            ),

            SizedBox(height: 30),

            SizedBox(

              height: 55,

              child: ElevatedButton.icon(

                onPressed: checkInLocation,

                icon: Icon(Icons.location_on),

                label: Text(
                  "CHECK-IN LOCATION",

                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),

                style: ElevatedButton.styleFrom(

                  backgroundColor: Colors.indigo,

                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),

            Text(
              statusText,

              textAlign: TextAlign.center,

              style: TextStyle(
                color: Colors.green,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}