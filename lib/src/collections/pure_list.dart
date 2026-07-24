import 'dart:collection';
import '../core/dependency_graph.dart';

/// Reactive List wrapper seamlessly integrating collection mutations into PureBind graph notifications.
class PureList<E> extends PureNode<List<E>> implements List<E> {
  final List<E> _list;

  /// Creates a [PureList] optionally initialized with [initial] elements.
  PureList([List<E>? initial]) : _list = initial ?? [];

  @override
  List<E> get value {
    trackAccess();
    return UnmodifiableListView(_list);
  }

  @override
  E operator [](int index) {
    trackAccess();
    return _list[index];
  }

  @override
  void operator []=(int index, E value) {
    _list[index] = value;
    notifySubscribers();
  }

  @override
  void add(E element) {
    _list.add(element);
    notifySubscribers();
  }

  @override
  void addAll(Iterable<E> iterable) {
    _list.addAll(iterable);
    notifySubscribers();
  }

  @override
  bool remove(Object? value) {
    final removed = _list.remove(value);
    if (removed) notifySubscribers();
    return removed;
  }

  @override
  E removeAt(int index) {
    final item = _list.removeAt(index);
    notifySubscribers();
    return item;
  }

  @override
  void clear() {
    if (_list.isNotEmpty) {
      _list.clear();
      notifySubscribers();
    }
  }

  @override
  int get length {
    trackAccess();
    return _list.length;
  }

  @override
  set length(int newLength) {
    _list.length = newLength;
    notifySubscribers();
  }

  @override
  List<E> operator +(List<E> other) => _list + other;

  @override
  Map<int, E> asMap() => _list.asMap();

  @override
  List<R> cast<R>() => _list.cast<R>();

  @override
  void fillRange(int start, int end, [E? fillValue]) {
    _list.fillRange(start, end, fillValue);
    notifySubscribers();
  }

  @override
  void setRange(int start, int end, Iterable<E> iterable, [int skipCount = 0]) {
    _list.setRange(start, end, iterable, skipCount);
    notifySubscribers();
  }

  @override
  void replaceRange(int start, int end, Iterable<E> replacements) {
    _list.replaceRange(start, end, replacements);
    notifySubscribers();
  }

  @override
  void sort([int Function(E a, E b)? compare]) {
    _list.sort(compare);
    notifySubscribers();
  }

  @override
  void shuffle([dynamic random]) {
    _list.shuffle(random);
    notifySubscribers();
  }

  @override
  bool contains(Object? element) {
    trackAccess();
    return _list.contains(element);
  }

  @override
  E get first {
    trackAccess();
    return _list.first;
  }

  @override
  E get last {
    trackAccess();
    return _list.last;
  }

  @override
  bool get isEmpty {
    trackAccess();
    return _list.isEmpty;
  }

  @override
  bool get isNotEmpty {
    trackAccess();
    return _list.isNotEmpty;
  }

  @override
  Iterator<E> get iterator {
    trackAccess();
    return _list.iterator;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
