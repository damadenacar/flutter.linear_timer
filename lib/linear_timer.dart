library linear_timer;

import 'package:flutter/material.dart';

abstract class _Subscriber {
  void onStart();
  void onEnd();
  void onUpdate();
}

/// Class that enables controlling the timer from outside the LinearTimer
///   If provided a controller, it is possible to start, stop and reset the
///   timer from outside.
class LinearTimerController {

  // Calls to update the timers
  void _onUpdate() => _subscribers.forEach((element) { element.onUpdate(); });
  void _onEnd() => _subscribers.forEach((element) { element.onEnd(); });
  void _onStart() => _subscribers.forEach((element) { element.onStart(); });

  // The animation controller, that will be created later
  late final AnimationController _controller;

  // This is the value for the animation (between 0 and 1)
  double get value => _controller.value;

  /// We'll create an animation controller for this object, and we need a [tickerProvider] with implements the TickerProvider
  ///   The [tickerProvider] will usually be a StatefulWidget that implements the _TickerProviderStateMixin_. If only using 
  ///   a single animation (i.e. this one), it would be enough to use the _SingleTickerProviderStateMixin_, but if using multiple
  ///   animations in a widget, the _TickerProviderStateMixin_ will be needed.
  /// 
  /// The parent object needs to create the LinearTimerController that controls the behavior of the timer, but it also needs
  ///   to dispose it by calling _dispose_ function. So it is advisable to use it as in the example
  /// 
  /// ```
  /// class _LinearWidgetDemoState extends State<LinearWidgetDemo> with TickerProviderStateMixin {
  ///   @override
  ///   void initState() {
  ///     super.initState();
  ///     timerController = LinearTimerController(this);
  ///   }
  ///   @override
  ///   void dispose() {
  ///     timerController.dispose();
  ///     super.dispose();
  ///   }
  ///  ...
  /// }
  /// ```
  LinearTimerController(TickerProvider tickerProvider) {
    _controller = AnimationController(
      lowerBound: 0,
      upperBound: 1,
      vsync: tickerProvider
    );

    _controller
      ..addListener(() {
        _onUpdate();
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _onEnd();
        }
      });    
  }

  // Need to call to free resources
  void dispose() {
    _controller.dispose();
  }
  
  /// Resets the timer (it will continue running, if it was before calling reset)
  void reset() {
    if (_controller.isAnimating) {
      _controller.forward(from: 0);
    } else {
      _controller.value = 0;
    }
  }

  /// Starts the timer, if it has been stopped before
  void start({bool restart = false}) {
    _onStart();
    _controller.forward(from: restart?0:_controller.value);
  }

  /// Stops the timer, if it has been started before
  void stop() {
    _controller.stop();
  }

  // Sets the duration for the timer
  set _duration(Duration duration) {
    _controller.duration = duration;
  }

  final List<_Subscriber> _subscribers = [];
  void _subscribe(_Subscriber subscriber) {
    if (!_subscribers.contains(subscriber)) {
      _subscribers.add(subscriber);
    }
  }
  void _unsubscribe(_Subscriber subscriber) {
    _subscribers.remove(subscriber);
  }
}

/// Class that implements a linear progress indicator, as if it was a timer
class LinearTimer extends StatefulWidget {

  // The callback to call when the timer ends
  final VoidCallback? onTimerEnd;
  
  // The callback to call when the timer is started
  final VoidCallback? onTimerStart;

  // The callback to call whenever the timer is updated
  final VoidCallback? onUpdate;
  
  // The duration for the timer
  final Duration duration;

  // Wether to go forward or backwards (i.e. countdown)
  final bool forward;

  // The timer controller, to enable controlling start and stop from outside this widget
  final LinearTimerController? controller;

  // The foreground color (i.e. the color that represents the elapsed time)
  final Color? color;

  // The background color (i.e. the color that represents the whole time)
  final Color? backgroundColor;

  // The minimal height for the widget
  final double? minHeight;

  // The constructor
  const LinearTimer({
    required this.duration, 
    this.forward = true, 
    this.onTimerEnd, 
    this.onTimerStart,
    this.onUpdate,
    this.controller,
    this.color,
    this.backgroundColor,
    this.minHeight,
    super.key
  });

  @override
  State<LinearTimer> createState() => _LinearTimerState();
}

class _LinearTimerState extends State<LinearTimer> with SingleTickerProviderStateMixin implements _Subscriber {

  late LinearTimerController _timerController;

  @override
  void initState() {
    super.initState();

    // If the controller is provided, use it; otherwise, create a new one
    if (widget.controller == null) {
      _timerController = LinearTimerController(this);
    } else {
      _timerController = widget.controller!;
    }

    _timerController._duration = widget.duration;
    _timerController._subscribe(this);

    if (widget.controller == null) {
      _timerController.start();
    }
  }

  @override
  void dispose() {
    // Stop receiving notifications
    _timerController._unsubscribe(this);

    // If we created the controller, we need to dispose it    
    if (widget.controller == null) {
      _timerController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The easy part: generating the progress indicator, by setting the value in the controller and the settings
    return LinearProgressIndicator(
      value: widget.forward? _timerController.value : 1 - _timerController.value,
      backgroundColor: widget.backgroundColor,
      color: widget.color,
      minHeight: widget.minHeight,
    );
  }
  
  @override
  void onEnd() {
    if (widget.onTimerEnd != null) {
      widget.onTimerEnd!.call();
    }
  }
  
  @override
  void onStart() {
    if (widget.onTimerStart != null) {
      widget.onTimerStart!.call();
    }
  }
  
  @override
  void onUpdate() {
    setState(() {
    });
    if (widget.onUpdate != null) {
      widget.onUpdate!.call();
    }
  }
}