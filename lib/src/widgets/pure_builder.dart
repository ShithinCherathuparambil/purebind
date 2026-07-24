import 'package:flutter/widgets.dart';
import '../core/dependency_graph.dart';

/// PureBuilder widget listens to changes in a `Pure<T>` or `PureNode<T>` state object or dynamically tracked states
/// and triggers targeted rebuilds.
class PureBuilder<T> extends StatefulWidget {
  /// The reactive node target to subscribe to explicitly.
  final PureNode<T>? pure;

  /// The builder closure function invoked when the signal updates.
  final Widget Function(BuildContext context, T value)? builder;

  /// The auto-tracking builder closure function invoked when dynamic auto-tracking is active.
  final Widget Function(BuildContext context)? autoBuilder;

  /// Creates a [PureBuilder] listening to an explicit [pure] signal or dynamic build context.
  const PureBuilder({
    super.key,
    this.pure,
    required Widget Function(BuildContext context, T value) this.builder,
  }) : autoBuilder = null;

  /// Creates a [PureBuilder.builder] with dynamic auto-tracking enabled.
  const PureBuilder.builder({
    super.key,
    required Widget Function(BuildContext context) builder,
  }) : pure = null,
       builder = null,
       autoBuilder = builder;

  @override
  State<PureBuilder<T>> createState() => _PureBuilderState<T>();
}

class _PureBuilderState<T> extends State<PureBuilder<T>>
    implements SubscriberNode {
  final Set<PureNode> _trackedDependencies = {};

  @override
  void initState() {
    super.initState();
    if (widget.pure != null) {
      widget.pure!.addSubscriber(this);
    }
  }

  @override
  void didUpdateWidget(PureBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pure != widget.pure) {
      oldWidget.pure?.removeSubscriber(this);
      widget.pure?.addSubscriber(this);
    }
  }

  @override
  void notifySubscriber() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.pure?.removeSubscriber(this);
    for (final dep in _trackedDependencies) {
      dep.removeSubscriber(this);
    }
    _trackedDependencies.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pure != null) {
      return widget.builder!(context, widget.pure!.value);
    }

    if (widget.autoBuilder != null) {
      GraphContext.pushSubscriber(this);
      try {
        return widget.autoBuilder!(context);
      } finally {
        GraphContext.popSubscriber();
      }
    }

    // Dynamic auto-tracking build scope
    GraphContext.pushSubscriber(this);
    try {
      return (widget.builder as dynamic)(context, null);
    } finally {
      GraphContext.popSubscriber();
    }
  }
}

/// PureConsumer for listening to state changes for side-effects (navigation, dialogs, snackbars).
class PureConsumer<T> extends StatefulWidget {
  /// The reactive node target to listen to for side-effects.
  final PureNode<T> pure;

  /// The listener callback invoked when state changes occur.
  final void Function(BuildContext context, T value) listener;

  /// The child widget to render.
  final Widget child;

  /// Creates a [PureConsumer] executing [listener] on state updates.
  const PureConsumer({
    super.key,
    required this.pure,
    required this.listener,
    required this.child,
  });

  @override
  State<PureConsumer<T>> createState() => _PureConsumerState<T>();
}

class _PureConsumerState<T> extends State<PureConsumer<T>>
    implements SubscriberNode {
  @override
  void initState() {
    super.initState();
    widget.pure.addSubscriber(this);
  }

  @override
  void didUpdateWidget(PureConsumer<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pure != widget.pure) {
      oldWidget.pure.removeSubscriber(this);
      widget.pure.addSubscriber(this);
    }
  }

  @override
  void notifySubscriber() {
    if (mounted) {
      widget.listener(context, widget.pure.value);
    }
  }

  @override
  void dispose() {
    widget.pure.removeSubscriber(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// PureSelect widget allowing custom state projections to prevent unnecessary rebuilds.
class PureSelect<T, R> extends StatefulWidget {
  /// The reactive node source.
  final PureNode<T> pure;

  /// The selector mapping function projecting [T] state to [R] selected value.
  final R Function(T value) selector;

  /// The builder closure rendering the projected [selectedValue].
  final Widget Function(BuildContext context, R selectedValue) builder;

  /// Creates a [PureSelect] filtering rebuilds by projected [selector] value.
  const PureSelect({
    super.key,
    required this.pure,
    required this.selector,
    required this.builder,
  });

  @override
  State<PureSelect<T, R>> createState() => _PureSelectState<T, R>();
}

class _PureSelectState<T, R> extends State<PureSelect<T, R>>
    implements SubscriberNode {
  late R _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.selector(widget.pure.value);
    widget.pure.addSubscriber(this);
  }

  @override
  void notifySubscriber() {
    final newValue = widget.selector(widget.pure.value);
    if (_selectedValue != newValue) {
      _selectedValue = newValue;
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    widget.pure.removeSubscriber(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _selectedValue);
  }
}
