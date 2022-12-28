import 'package:flutter/material.dart';
import 'package:linear_timer/linear_timer.dart';

void main() {
  runApp(const MyApp());
}

void showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 2),
      action: SnackBarAction(
        label: 'dismiss', onPressed: () {
        } 
      ),
      content: Text(text),
      behavior: SnackBarBehavior.floating,
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'LinearTimer Demo',
      home: LinearWidgetDemo(),
    );
  }
}

class LinearWidgetDemo extends StatefulWidget {
  const LinearWidgetDemo({super.key});

  @override
  State<LinearWidgetDemo> createState() => _LinearWidgetDemoState();
}

class _LinearWidgetDemoState extends State<LinearWidgetDemo> {

  LinearTimerController timerController1 = LinearTimerController();
  LinearTimerController timerController2 = LinearTimerController();
  LinearTimerController timerControllerShared = LinearTimerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text("simple linear timer (5 seconds forward)"),
            ),
            LinearTimer(
              duration: const Duration(seconds: 5),
              color: Colors.green,
              backgroundColor: Colors.grey[200],
              controller: timerController1,
              onTimerEnd: () {
                showSnackBar(context, "Timer 1 ended");
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(onPressed: () {
                  timerController1.start();
                }, icon: const Icon(Icons.play_arrow)),
                IconButton(onPressed: () {
                  timerController1.stop();
                }, icon: const Icon(Icons.stop)),
                IconButton(onPressed: () {
                  timerController1.reset();
                }, icon: const Icon(Icons.restart_alt))
              ],
            ),
            const SizedBox(height: 32,),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text("simple linear timer (5 seconds countdown)"),
            ),
            LinearTimer(
              duration: const Duration(seconds: 5),
              color: Colors.orange,
              backgroundColor: Colors.yellow,
              controller: timerController2,
              forward: false,
              onTimerEnd: () {
                showSnackBar(context, "Timer 2 ended");
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(onPressed: () {
                  timerController2.start();
                }, icon: const Icon(Icons.play_arrow)),
                IconButton(onPressed: () {
                  timerController2.stop();
                }, icon: const Icon(Icons.stop)),
                IconButton(onPressed: () {
                  timerController2.reset();
                }, icon: const Icon(Icons.restart_alt))
              ],
            ),            
            const SizedBox(height: 32,),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text("two linear timers using the same controller"),
            ),
            LinearTimer(
              duration: const Duration(seconds: 5),
              controller: timerControllerShared,
              onTimerEnd: () {
                showSnackBar(context, "Timer 3 ended");
              },
            ),
            const SizedBox(height: 8,),
            LinearTimer(
              duration: const Duration(seconds: 5),
              controller: timerControllerShared,
              forward: false,
              onTimerEnd: () {
                showSnackBar(context, "Timer 4 ended");
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(onPressed: () {
                  timerControllerShared.start();
                }, icon: const Icon(Icons.play_arrow)),
                IconButton(onPressed: () {
                  timerControllerShared.stop();
                }, icon: const Icon(Icons.stop)),
                IconButton(onPressed: () {
                  timerControllerShared.reset();
                }, icon: const Icon(Icons.restart_alt))
              ],
            ),               
          ],
        ),
      ),
    );
  }
}
