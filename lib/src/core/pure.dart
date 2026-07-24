import 'dart:async';
import 'package:flutter/widgets.dart';
import 'dependency_graph.dart';

/// Representation of a single state history snapshot for undo/redo history tracking.
class StateSnapshot<T> {
  /// The state value captured at this history snapshot.
  final T value;

  /// The exact timestamp when this history snapshot was recorded.
  final DateTime timestamp;

  /// Creates a [StateSnapshot] wrapping [value].
  StateSnapshot(this.value) : timestamp = DateTime.now();
}

/// Abstract contract for Pure reactive signals.
abstract class Pure<T> extends PureNode<T> {
  /// Creates a standard reactive value signal wrapping [initialValue].
  factory Pure(T initialValue, {bool enableHistory, int maxHistory}) =
      PureImpl<T>;

  /// Creates a computed / derived reactive signal derived from [compute].
  factory Pure.computed(T Function() compute) = ComputedPure<T>;

  /// Creates a reactive signal from a [Future] function [futureFn].
  static Pure<AsyncSnapshot<T>> future<T>(
    Future<T> Function() futureFn, {
    T? initialData,
  }) => AsyncFuturePure<T>(futureFn, initialData: initialData);

  /// Creates a reactive signal from a [Stream] function [streamFn].
  static Pure<AsyncSnapshot<T>> stream<T>(
    Stream<T> Function() streamFn, {
    T? initialData,
  }) => AsyncStreamPure<T>(streamFn, initialData: initialData);

  /// Current value getter for this reactive signal.
  @override
  T get value;

  /// Current value setter for updating this reactive signal.
  set value(T newValue);

  /// Mutates state directly using an [updater] callback function.
  void update(T Function(T current) updater);

  /// Executes a block of code within an atomic batch context, deferring notifications until completion.
  static void batch(void Function() fn) {
    GraphContext.batch(fn);
  }

  /// Whether an undo operation is available in history.
  bool get canUndo;

  /// Whether a redo operation is available in history.
  bool get canRedo;

  /// Reverts the signal value to the previous history snapshot.
  void undo();

  /// Advances the signal value to the next redo history snapshot.
  void redo();

  /// Returns an unmodifiable view of the recorded state history snapshots.
  List<StateSnapshot<T>> get history;

  /// Purges subscribers and clears internal history allocations.
  void dispose();
}

/// Standard reactive signal implementation storing state value [T].
class PureImpl<T> extends PureNode<T> implements Pure<T> {
  T _value;
  final bool _enableHistory;
  final int _maxHistory;

  final List<StateSnapshot<T>> _historyList = [];
  int _historyIndex = -1;

  /// Creates a [PureImpl] signal initialized with [_value].
  PureImpl(this._value, {this._enableHistory = false, this._maxHistory = 50}) {
    if (_enableHistory) {
      _recordHistory(_value);
    }
  }

  @override
  T get value {
    trackAccess();
    return _value;
  }

  @override
  set value(T newValue) {
    if (_value == newValue) return;
    _value = newValue;
    if (_enableHistory) {
      _recordHistory(newValue);
    }
    notifySubscribers();
  }

  @override
  void update(T Function(T current) updater) {
    _value = updater(_value);
    if (_enableHistory) {
      _recordHistory(_value);
    }
    notifySubscribers();
  }

  /// Manually triggers subscriber notifications.
  void notify() {
    notifySubscribers();
  }

  void _recordHistory(T snapshotValue) {
    if (_historyIndex >= 0 && _historyIndex < _historyList.length - 1) {
      _historyList.removeRange(_historyIndex + 1, _historyList.length);
    }

    _historyList.add(StateSnapshot<T>(snapshotValue));
    if (_historyList.length > _maxHistory) {
      _historyList.removeAt(0);
    } else {
      _historyIndex++;
    }
  }

  @override
  bool get canUndo => _enableHistory && _historyIndex > 0;

  @override
  bool get canRedo => _enableHistory && _historyIndex < _historyList.length - 1;

  @override
  void undo() {
    if (!canUndo) return;
    _historyIndex--;
    _value = _historyList[_historyIndex].value;
    notifySubscribers();
  }

  @override
  void redo() {
    if (!canRedo) return;
    _historyIndex++;
    _value = _historyList[_historyIndex].value;
    notifySubscribers();
  }

  @override
  List<StateSnapshot<T>> get history => List.unmodifiable(_historyList);

  @override
  void dispose() {
    clearSubscribers();
    _historyList.clear();
  }
}

/// Derived / Computed state signal implementation automatically updating on dependency changes.
class ComputedPure<T> extends PureNode<T> implements SubscriberNode, Pure<T> {
  final T Function() _compute;
  T? _cachedValue;
  bool _isDirty = true;
  final Set<PureNode> _dependencies = {};

  /// Creates a [ComputedPure] signal computed by [_compute].
  ComputedPure(this._compute);

  @override
  T get value {
    trackAccess();
    if (_isDirty) {
      _recompute();
    }
    return _cachedValue as T;
  }

  void _recompute() {
    for (final dep in _dependencies) {
      dep.removeSubscriber(this);
    }
    _dependencies.clear();

    GraphContext.pushSubscriber(this);
    try {
      _cachedValue = _compute();
      _isDirty = false;
    } finally {
      GraphContext.popSubscriber();
    }
  }

  @override
  void notifySubscriber() {
    _isDirty = true;
    notifySubscribers();
  }

  @override
  set value(T newValue) {
    throw UnsupportedError('Computed state cannot be directly mutated.');
  }

  @override
  void update(T Function(T current) updater) {
    throw UnsupportedError('Computed state cannot be updated.');
  }

  @override
  bool get canUndo => false;

  @override
  bool get canRedo => false;

  @override
  void undo() {}

  @override
  void redo() {}

  @override
  List<StateSnapshot<T>> get history => const [];

  @override
  void dispose() {
    for (final dep in _dependencies) {
      dep.removeSubscriber(this);
    }
    _dependencies.clear();
    clearSubscribers();
  }
}

/// Async Future-backed signal implementation wrapping [AsyncSnapshot].
class AsyncFuturePure<T> extends PureImpl<AsyncSnapshot<T>> {
  /// Creates an [AsyncFuturePure] signal executing [futureFn].
  AsyncFuturePure(Future<T> Function() futureFn, {T? initialData})
    : super(
        initialData != null
            ? AsyncSnapshot<T>.withData(ConnectionState.waiting, initialData)
            : AsyncSnapshot<T>.waiting(),
      ) {
    _fetch(futureFn);
  }

  void _fetch(Future<T> Function() futureFn) async {
    if (value.hasData) {
      value = AsyncSnapshot<T>.withData(
        ConnectionState.waiting,
        value.data as T,
      );
    } else {
      value = AsyncSnapshot<T>.waiting();
    }
    try {
      final res = await futureFn();
      value = AsyncSnapshot<T>.withData(ConnectionState.done, res);
    } catch (e, stack) {
      value = AsyncSnapshot<T>.withError(ConnectionState.done, e, stack);
    }
  }
}

/// Async Stream-backed signal implementation wrapping [AsyncSnapshot].
class AsyncStreamPure<T> extends PureImpl<AsyncSnapshot<T>> {
  StreamSubscription<T>? _subscription;

  /// Creates an [AsyncStreamPure] signal listening to [streamFn].
  AsyncStreamPure(Stream<T> Function() streamFn, {T? initialData})
    : super(
        initialData != null
            ? AsyncSnapshot<T>.withData(ConnectionState.waiting, initialData)
            : AsyncSnapshot<T>.waiting(),
      ) {
    _subscription = streamFn().listen(
      (data) {
        value = AsyncSnapshot<T>.withData(ConnectionState.active, data);
      },
      onError: (err, stack) {
        value = AsyncSnapshot<T>.withError(ConnectionState.active, err, stack);
      },
      onDone: () {
        if (value.hasData) {
          value = AsyncSnapshot<T>.withData(
            ConnectionState.done,
            value.data as T,
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
