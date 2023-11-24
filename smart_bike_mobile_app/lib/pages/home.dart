import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:smart_bike_mobile_app/pages/login.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Timer variables
  int numH = 0, numM = 0, numS = 0;
  String strH = '00', strM = '00', strS = '00';
  Timer? timer;
  bool isRunning = false;

  // Bike variables
  //TODO: Get data from MQTT when available
  num power = 0, speed = 11, rpm = 0;
  num distance = 0;
  MqttServerClient? mqttServerClient;

  void stopTimer() {
    timer!.cancel();
    setState(() {
      numH = 0;
      numM = 0;
      numS = 0;
      distance = 0;
      strH = '00';
      strM = '00';
      strS = '00';
      isRunning = false;
    });
  }

  void pauseTimer() {
    timer!.cancel();
    setState(() {
      isRunning = false;
    });
  }

  void startTimer() {
    isRunning = true;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      int s = numS + 1;
      int sec = numS + 1;
      int m = numM;
      int h = numH;

      // Set timer minutes and hours
      if (s >= 60) {
        if (m >= 60) {
          h += 1;
          m = 0;
        } else {
          m += 1;
          s = 0;
        }
      }

      setState(() {
        numS = s;
        numM = m;
        numH = h;
        strS = (numS >= 10) ? '$numS' : '0$numS';
        strM = (numM >= 10) ? '$numM' : '0$numM';
        strH = (numH >= 10) ? '$numH' : '0$numH';
        distance = speed * sec;
      });
    });
  }

  Future<void> connectMqtt() async {
    //TODO: Implement subscribe method
    MqttServerClient client = MqttServerClient.withPort(dotenv.get('MQTT_HOST'), 'redbacksmartbikemobileapp', 8883);
    client.secure = true;

    client.onConnected = () {
      //print('Connected');
    };

    client.onDisconnected = () {
      //print('Disconnected');
    };

    try {
      await client.connect(dotenv.get('MQTT_USERNAME'), dotenv.get('MQTT_PASSWORD'));
      //print('connected');
    } catch (e) {
      Fluttertoast.showToast(msg: '$e');
      client.disconnect();
    }

    mqttServerClient = client;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF370E4A),
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF553265),
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'Welcome ${FirebaseAuth.instance.currentUser?.displayName}!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(
              height: 500,
            ),
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE3E3E3), width: 2),
                borderRadius: BorderRadius.circular(5),
              ),
              child: GestureDetector(
                onTap: () {
                  logout(context);
                },
                behavior: HitTestBehavior.translucent,
                child: Container(
                  width: 150,
                  alignment: Alignment.center,
                  child: const Text(
                    'Log out',
                    style: TextStyle(
                      color: Color(0xFFE3E3E3),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF6E2D51),
              Color(0xFFE97462),
              Color.fromRGBO(55, 14, 74, 0.94),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Center(
          child: (mqttServerClient != null)
              ? Column(
                  children: [
                    // Timer Header
                    const SizedBox(
                      height: 50,
                    ),
                    const Text(
                      'Current Session',
                      style: TextStyle(
                        color: Color(0xFFE3E3E3),
                        fontSize: 24,
                      ),
                    ),

                    // Timer display
                    const SizedBox(
                      height: 30,
                    ),
                    Center(
                      child: Text(
                        '$strH:$strM:$strS',
                        style: const TextStyle(
                          color: Color(0xFFE3E3E3),
                          fontSize: 20,
                        ),
                      ),
                    ),

                    // Bike data display
                    const SizedBox(
                      height: 50,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: Column(
                              children: [
                                const Text(
                                  'Speed',
                                  style: TextStyle(
                                    color: Color(0xFFE3E3E3),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  '${speed.toString()} m/s',
                                  style: const TextStyle(
                                    color: Color(0xFFE3E3E3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: Column(
                              children: [
                                const Text(
                                  'RPM',
                                  style: TextStyle(
                                    color: Color(0xFFE3E3E3),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  '${rpm.toString()} RPM',
                                  style: const TextStyle(
                                    color: Color(0xFFE3E3E3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 50,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: Column(
                              children: [
                                const Text(
                                  'Power',
                                  style: TextStyle(
                                    color: Color(0xFFE3E3E3),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  '${power.toString()} Watts',
                                  style: const TextStyle(
                                    color: Color(0xFFE3E3E3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: Column(
                              children: [
                                const Text(
                                  'Distance',
                                  style: TextStyle(
                                    color: Color(0xFFE3E3E3),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  '${distance.toString()} m',
                                  style: const TextStyle(
                                    color: Color(0xFFE3E3E3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // temp placeholder for Incline and Resistance setters
                    const SizedBox(
                      height: 200,
                    ),

                    // Start, Pause and Reset Session
                    ElevatedButton(
                        onPressed: () {
                          (!isRunning) ? startTimer() : pauseTimer();
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              (!isRunning)
                                  ? const Color(0xFFA8E898)
                                  : const Color(0xFFDF8D42)),
                        ),
                        child: Text(
                          (!isRunning) ? 'Start Session' : 'Pause Session',
                          style: const TextStyle(
                            color: Color(0xFF370E4A),
                          ),
                        )),

                    ElevatedButton(
                      onPressed: () {
                        stopTimer();
                      },
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              const Color(0xFFE64036))),
                      child: const Text(
                        'Reset Session',
                        style: TextStyle(
                          color: Color(0xFFE3E3E3),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    const Image(
                      image: AssetImage('lib/assets/redbacklogo.png'),
                      height: 150,
                    ),

                    // App Name
                    const Text("Redback Smart Bike",
                      style: TextStyle(
                        color: Color(0xFFE3E3E3),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                        ),
                      child: Text(
                        'Welcome ${FirebaseAuth.instance.currentUser?.displayName}, thank you for using the Redback Smart Bike mobile application! Before you continue, here is one last thing to do: as this application requires a Redback Smart Bike to get started, please connect with your smart bike by scanning the QR code under the bike seat.',
                        textAlign: TextAlign.justify,
                        style: const TextStyle(
                          color: Color(0xFFE3E3E3),
                          fontSize: 16,
                          wordSpacing: 2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 50,),

                    ElevatedButton(
                      onPressed: () {
                        //TODO: connectMqtt() method should not be invoked here, instead, let user connect to the bike first (get bike id), and then connect to mqtt (sub to topics)
                        //connectMqtt();
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          const Color(0xFF370E4A),
                        ),
                      ),
                      child: const Text('Connect with Smart Bike'),
                    ),

                    ElevatedButton(
                      onPressed: () {
                        //mqttServerClient?.disconnect();
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          const Color(0xFF370E4A),
                        ),
                      ),
                      child: const Text('Disconnect with Smart Bike'),)
                  ],
                ),
        ),
      ),
    );
  }
}

Future<void> logout(BuildContext context) async {
  final auth = FirebaseAuth.instance;
  try {
    await auth.signOut().then((auth) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => Login(),
          ),
          (route) => false);
    });
  } catch (e) {
    Fluttertoast.showToast(msg: 'Error: $e');
  }
}


