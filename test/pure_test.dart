import 'package:flutter_test/flutter_test.dart';
import 'package:purebind/purebind.dart';

void main() {
  group('Pure State Primitive Tests', () {
    test('Initial value and mutation updates state', () {
      final counter = Pure<int>(0);
      expect(counter.value, equals(0));

      counter.value = 5;
      expect(counter.value, equals(5));

      counter.update((c) => c + 10);
      expect(counter.value, equals(15));
    });

    test('Computed state auto-calculates dependent values', () {
      final count = Pure<int>(2);
      final multiplier = Pure<int>(3);
      final total = Pure.computed(() => count.value * multiplier.value);

      expect(total.value, equals(6));

      count.value = 5;
      expect(total.value, equals(15));

      multiplier.value = 4;
      expect(total.value, equals(20));
    });

    test('Batching updates delays notification until batch completion', () {
      final a = Pure<int>(1);
      final b = Pure<int>(2);
      int updates = 0;

      final sum = Pure.computed(() {
        updates++;
        return a.value + b.value;
      });

      expect(sum.value, equals(3));
      expect(updates, equals(1));

      Pure.batch(() {
        a.value = 10;
        b.value = 20;
      });

      expect(sum.value, equals(30));
      // Re-computed only once after batch completes
      expect(updates, equals(2));
    });

    test('Undo and Redo history functionality', () {
      final name = Pure<String>('Initial', enableHistory: true);
      name.value = 'Step 1';
      name.value = 'Step 2';

      expect(name.value, equals('Step 2'));
      expect(name.canUndo, isTrue);

      name.undo();
      expect(name.value, equals('Step 1'));

      name.undo();
      expect(name.value, equals('Initial'));

      expect(name.canUndo, isFalse);
      expect(name.canRedo, isTrue);

      name.redo();
      expect(name.value, equals('Step 1'));
    });
  });

  group('Reactive Collections Tests', () {
    test('PureList triggers updates on mutation', () {
      final items = PureList<String>(['Apple']);
      final count = Pure.computed(() => items.length);

      expect(count.value, equals(1));

      items.add('Banana');
      expect(count.value, equals(2));

      items.remove('Apple');
      expect(count.value, equals(1));
    });
  });
}
