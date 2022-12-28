library linear_timer;

import 'package:flutter/material.dart';

/// Class that enables controlling the timer from outside the LinearTimer
///   If provided a controller, it is possible to start, stop and reset the
///   timer from outside.
class LinearTimerController {

  /// Resets the timer (it will continue running, if it was before calling reset)
  void reset() => _callHandlers(_onReset);

  /// Starts the timer, if it has been stopped before
  void start() => _callHandlers(_onStart);

  /// Stops the timer, if it has been started before
  void stop() => _callHandlers(_onStop);

  /// Function that calls a list of handlers, in the same order
  void _callHandlers(List<VoidCallback> handlerList) {
    if (handlerList.isNotEmpty) {
      for (VoidCallback handler in handlerList) {
        handler.call();
      }
    }
  }

  /// Function to add a handler to a list
  void _addHandler(List<VoidCallback> handlerList, VoidCallback handler) {
    handlerList.add(handler);
  }

  // Functions to add the handlers
  void _addOnResetHandler(VoidCallback handler) => _addHandler(_onReset, handler);
  void _addOnStopHandler(VoidCallback handler) => _addHandler(_onStop, handler);
  void _addOnStartHandler(VoidCallback handler) => _addHandler(_onStart, handler);

  /// Lists of handlers
  final List<VoidCallback> _onReset = [];
  final List<VoidCallback> _onStart = [];
  final List<VoidCallback> _onStop = [];
}

/// Class that implements a linear progress indicator, as if it was a timer
class LinearTimer extends StatefulWidget {

  // The callback to call when the timer ends
  final VoidCallback? onTimerEnd;
  
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
    this.controller,
    this.color,
    this.backgroundColor,
    this.minHeight,
    super.key
  });

  @override
  State<LinearTimer> createState() => _LinearTimerState();
}

class _LinearTimerState extends State<LinearTimer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  /// The start handler; depending on if we want to be a countdown or a time counter, it will go forward or backwards
  ///   [restart] forces a restart, even if the timer has arrived to a final state
  void start({bool restart = false}) {
    if (widget.forward) {
      _controller.forward(from: restart?0:_controller.value);
    } else {
      _controller.reverse(from: restart?1:_controller.value);
    }
  }

  /// Handler that stops the timer
  void stop() {
    _controller.stop();
  }

  /// Handler to reset the timer and continue running if it already was
  void reset() {
    bool doStart = _controller.isAnimating;
    if (widget.forward) {
      _controller.value = 0;
    } else {
      _controller.value = 1;
    }
    if (doStart) {
      start();
    } 
    setState(() {
    });
  }

  @override
  void initState() {
    super.initState();

    // We'll add the handlers to the controller, if provided
    if (widget.controller != null) {
      widget.controller!._addOnResetHandler(() => reset());
      widget.controller!._addOnStartHandler(() => start());
      widget.controller!._addOnStopHandler(() => stop());
    }

    // Prepare the animation controller in our bounds (0 to 1), as LinearProgress understands.
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      lowerBound: 0,
      upperBound: 1,
    );

    // We'll add a listener so that the value is updated, and a StatusListener, so that the onTimerEnd is properly called
    _controller
      ..addListener(() {
        setState(() {
        });
      })
      ..addStatusListener((status) {
        if ((status == AnimationStatus.completed) && (widget.forward)) {
          if (widget.onTimerEnd != null) {
            widget.onTimerEnd!.call();
          }
        }
        if ((status == AnimationStatus.dismissed) && (!widget.forward)) {
          if (widget.onTimerEnd != null) {
            widget.onTimerEnd!.call();
          }
        }
      });

      // Let's reset the timer so that anything starts as expected
      reset();

      // If there is no controller, let's start automatically
      if (widget.controller == null) {
        start();
      }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // The easy part: generating the progress indicator, by setting the value in the controller and the settings
    return LinearProgressIndicator(
      value: _controller.value,
      backgroundColor: widget.backgroundColor,
      color: widget.color,
      minHeight: widget.minHeight,
    );
  }
}