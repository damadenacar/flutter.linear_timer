# Linear Timer

This package provides a widget that enables to use a Linear Progress Indicator as a timer.

## Features

Use a Linear Progress Indicator as a timer (for a forward timer, or a countdown timer). The animation shows multiple examples

![Examples](https://github.com/damadenacar/flutter.linear_timer/raw/main/img/demo.gif)

Some features are:

- control start, stop and restart from the parent widget (by using the `LinearTimerController`).
- use the same controller for multiple timers
- allow an `onTimerEnd` callback, called whenever the timer reaches the end.

## Getting started

To start using this package, add it to your `pubspec.yaml` file:

```yaml
dependencies:
    linear_timer:
```

Then get the dependencies (e.g. `flutter pub get`) and import them into your application:

```dart
import 'package:linear_timer/linear_timer.dart';
```

## Usage

In the most simple case, use the widget in your application:

```dart
class _LinearWidgetDemoState extends State<LinearWidgetDemo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: LinearTimer(
          duration: const Duration(seconds: 5),
          onTimerEnd: () {
            print("timer ended");
          },
        )
      )
    );
  }
}
```

If wanted to have full control over the timer (when it starts, stops, etc.), you'll need to add a `LinearTimerController` (in this case, the timer will not start by itself). The `LinearTimerController` needs a `TickerProvider`, but it will be enough to use the mixin `TickerProviderStateMixin` for the Widget that will hold the timer. The only caveat is that the controller must be disposed by using the `dispose()` function, as in the example.

```dart
class _LinearWidgetDemoState extends State<LinearWidgetDemo> with TickerProviderStateMixin {

  late LinearTimerController timerController = LinearTimerController(this);
  bool timerRunning = false;

  @override
  void dispose() {
    timerController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (timerRunning) {
            timerController.stop();
            setState(() {
              timerRunning = false;
            });
          } else {
            timerController.reset();
            timerController.start();
            setState(() {
              timerRunning = true;
            });
          }
        },
        child: timerRunning?const Icon(Icons.stop):const Icon(Icons.timer),
      ),
      body: Center(
        child: LinearTimer(
          duration: const Duration(seconds: 5),
          controller: timerController,
          onTimerEnd: () {
            setState(() {
              timerRunning = false;
            });
          },
        )
      )
    );
  }
}
```

## Additional information

### The LinearTimer widget

The constructor for the widget is the next:

```dart
LinearTimer({
    required Duration duration, 
    bool forward = true,
    VoidCallback onTimerEnd, 
    LinearController? controller,
    Color? color,
    Color? backgroundColor,
    double minHeight = 4,
    super.key
});
```

The basic information is:
- __onTimerEnd__: A callback to call when the timer ends
- __duration__: The duration for the timer
- __forward__: Whether to go forward or backward (i.e. countdown).
- __controller__: The timer controller, enables controlling start and stop from outside this widget.
- __color__: The foreground color (i.e. the color that represents the elapsed time).
- __backgroundColor__: The background color (i.e. the color that represents the whole time).
- __minHeight__: The minimal height for the widget.

### The LinearTimerController to control the timer

The controller is used to control when the timer starts, stop the timer, the current value, etc. Moreover, if used as part of the state in a `StatefulWidget`, it keeps the values between rebuilds.

If offers the attribute:
- __value__: used to get the percentage value for the animation (between 0 and 1).

It also offers the next methods:
- __dispose()__: Used to free resources.
- __reset()__: Resets the timer (it will continue running if it was before calling reset).
- __start({bool restart = false})__: Starts the timer if it has been stopped before. If _restart_ is set to `true`, it will restart the timer from the beginning.
- __stop()__: Stops the timer if it has been started before.
