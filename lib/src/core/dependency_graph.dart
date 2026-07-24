/// Global evaluation graph context managing active subscribers and batch processing.
class GraphContext {
  static final List<SubscriberNode> _activeSubscribers = [];

  /// Returns the currently active subscriber node participating in automatic dependency tracking.
  static SubscriberNode? get currentSubscriber =>
      _activeSubscribers.isNotEmpty ? _activeSubscribers.last : null;

  /// Pushes a subscriber node onto the evaluation stack during auto-tracking builds.
  static void pushSubscriber(SubscriberNode subscriber) {
    _activeSubscribers.add(subscriber);
  }

  /// Pops the active subscriber node from the evaluation stack after build completion.
  static void popSubscriber() {
    if (_activeSubscribers.isNotEmpty) {
      _activeSubscribers.removeLast();
    }
  }

  /// Batch update depth counter.
  static int _batchDepth = 0;
  static final Set<SubscriberNode> _pendingSubscribers = {};

  /// Whether updates are currently being executed within an atomic batch context.
  static bool get isBatching => _batchDepth > 0;

  /// Executes a block of code within an atomic batch context, deferring notifications until completion.
  static void batch(void Function() fn) {
    _batchDepth++;
    try {
      fn();
    } finally {
      _batchDepth--;
      if (_batchDepth == 0) {
        _flushPendingSubscribers();
      }
    }
  }

  /// Schedules a notification for a subscriber node, queueing it if batching is active.
  static void scheduleNotification(SubscriberNode subscriber) {
    if (isBatching) {
      _pendingSubscribers.add(subscriber);
    } else {
      subscriber.notifySubscriber();
    }
  }

  /// Flushes all pending queued subscriber notifications after an atomic batch completes.
  static void _flushPendingSubscribers() {
    final toNotify = List<SubscriberNode>.from(_pendingSubscribers);
    _pendingSubscribers.clear();
    for (final sub in toNotify) {
      sub.notifySubscriber();
    }
  }
}

/// Interface representing a node in the dependency graph that can receive update notifications.
abstract class SubscriberNode {
  /// Notifies the subscriber that a dependent reactive node's value has changed.
  void notifySubscriber();
}

/// Abstract base class for all reactive signal nodes in the dependency graph.
abstract class PureNode<T> {
  final Set<SubscriberNode> _subscribers = {};

  /// Returns the current value held by this node.
  T get value;

  /// Subscribes a [SubscriberNode] to receive change notifications from this node.
  void addSubscriber(SubscriberNode subscriber) {
    _subscribers.add(subscriber);
  }

  /// Unsubscribes a [SubscriberNode] from receiving change notifications from this node.
  void removeSubscriber(SubscriberNode subscriber) {
    _subscribers.remove(subscriber);
  }

  /// Clears all active subscribers attached to this node.
  void clearSubscribers() {
    _subscribers.clear();
  }

  /// Automatically registers access to this node if executed within an active build evaluation context.
  void trackAccess() {
    final active = GraphContext.currentSubscriber;
    if (active != null) {
      _subscribers.add(active);
    }
  }

  /// Notifies all active subscribers attached to this node that the value has updated.
  void notifySubscribers() {
    final list = List<SubscriberNode>.from(_subscribers);
    for (final subscriber in list) {
      GraphContext.scheduleNotification(subscriber);
    }
  }
}
