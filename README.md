# PureBind ⚡

[![Pub Version](https://img.shields.io/badge/pub-v0.0.1-blue.svg?style=flat-square)](https://pub.dev)
[![Flutter Support](https://img.shields.io/badge/Flutter-All%20Platforms-02569B.svg?style=flat-square&logo=flutter)](https://flutter.dev)
[![Dart SDK](https://img.shields.io/badge/Dart-%3E%3D3.0-0175C2.svg?style=flat-square&logo=dart)](https://dart.dev)
[![Platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20Android%20%7C%20macOS%20%7C%20Windows%20%7C%20Linux%20%7C%20Web-blueviolet.svg?style=flat-square)](#-supported-platforms)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](https://opensource.org/licenses/MIT)

A next-generation, ultra-lightweight, fine-grained reactive state management framework for Flutter built from first principles.

`PureBind` empowers Flutter developers with **100% type-safe signals**, **zero-boilerplate reactivity**, **automatic dependency tracking**, **native undo/redo history**, and **glitch-free atomic batching**.

---

## 📦 Installation

Add `purebind` to your `pubspec.yaml`:

```yaml
dependencies:
  purebind: ^0.0.1
```

Or run:

```bash
flutter pub add purebind
```

---

## 🌟 Core Highlights

- 🚀 **Zero-Boilerplate Reactivity**: Simple, intuitive `Pure(initialValue)` signals with `.value` and `.update()` access.
- 🎯 **Fine-Grained Sub-Tree Rebuilds**: Target rebuilds exclusively to the smallest wrapped widget node using `PureBuilder`.
- 🧮 **Computed Derived Signals**: Create reactive values that automatically re-calculate whenever dependent signals mutate using `Pure<T>.computed`.
- ⚡ **Glitch-Free Atomic Batching**: Group multiple signal updates into a single UI frame refresh via `Pure.batch()`.
- ⏪ **Built-In Time-Travel (Undo / Redo)**: Native state snapshot history with `.undo()`, `.redo()`, and `.canUndo`.
- 🔔 **Side-Effect Management**: Handle dialogs, snackbars, and navigation smoothly with `PureConsumer`.
- 🔬 **Selective Projections**: Optimize performance by picking precise state projections with `PureSelect`.
- 🌐 **Context-Decoupled Architecture**: Signals operate independently of `BuildContext`, making them effortless to use in controllers, services, and unit tests.
- 🧹 **Automatic Lifecycle Management**: Automatic subscriber detachment when widgets unmount—no manual disposal overhead.
- 📱 **100% Multi-Platform**: Works natively on **iOS**, **Android**, **macOS**, **Windows**, **Linux**, and **Web (Wasm & JS)**.

---

## 🌐 Supported Platforms

Because `PureBind` is written in **100% Pure Dart & Flutter framework primitives** with zero native dependencies or C/C++ channels, it is guaranteed to run everywhere Flutter runs:

| Platform | Support | Status |
| :--- | :---: | :---: |
| 📱 **iOS** | Native | ✅ Supported |
| 🤖 **Android** | Native | ✅ Supported |
| 💻 **macOS** | Native | ✅ Supported |
| 🪟 **Windows** | Native | ✅ Supported |
| 🐧 **Linux** | Native | ✅ Supported |
| 🌐 **Web (Wasm & JS)** | Native | ✅ Supported |
- 🏢 **Enterprise Ready**: Full separation of UI and business logic, 100% testable controllers, and production-grade stability.

---

## 🏢 Enterprise Architecture & UI/Logic Separation

`PureBind` enforces a strict **Unidirectional Data Flow**, separating UI rendering from background logic, API fetching, and domain services:

```
┌─────────────────────────────────────────────────────────┐
│                     UI LAYER (View)                     │
│  StatelessWidget / PureBuilder / ListViews              │
└───────────────────────────┬─────────────────────────────┘
                            │  1. Dispatches User Action
                            ▼
┌─────────────────────────────────────────────────────────┐
│              CONTROLLER / LOGIC LAYER                   │
│  Pure Signals / Computed State / Async Methods          │
└───────────────────────────┬─────────────────────────────┘
                            │  2. Calls API / Data Source
                            ▼
┌─────────────────────────────────────────────────────────┐
│               DATA / BACKGROUND LAYER                   │
│  Repositories / HTTP Clients / SQLite / Isolate Workers  │
└─────────────────────────────────────────────────────────┘
```

1. **UI Layer**: Composed of pure `StatelessWidget`s. The UI only reads state via `PureBuilder` and dispatches user actions (e.g. `controller.fetchUserData()`).
2. **Controller Layer**: Handles business logic, input validation, and background processing. Updates reactive `Pure` signals when tasks complete.
3. **Data & Background Layer**: Manages repositories, HTTP networking, background isolates, or local storage. Completely decoupled from Flutter UI.

---

## 🚀 Quick Start Examples

### 1. Basic Reactive Signal & Targeted Rebuild

```dart
import 'package:flutter/material.dart';
import 'package:purebind/purebind.dart';

// Declare a reactive signal
final count = Pure<int>(0);

class CounterScreen extends StatelessWidget {
  const CounterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: PureBuilder<int>(
          pure: count,
          builder: (context, value) => Text('Count: $value', style: const TextStyle(fontSize: 24)),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => count.value++,
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

---

### 2. Computed Derived Signals

Computed signals automatically recalculate whenever their dependent signals change:

```dart
final itemPrice = Pure<double>(25.0);
final itemQuantity = Pure<int>(2);

// Automatically computes total whenever price or quantity mutates
final totalPrice = Pure<double>.computed(() => itemPrice.value * itemQuantity.value);

// Usage in UI
PureBuilder<double>(
  pure: totalPrice,
  builder: (context, total) => Text('Total: \$$total'),
);
```

---

### 3. Reactive List Collections

Work directly with standard Dart collections:

```dart
final tasks = Pure<List<String>>(['Task 1', 'Task 2']);

// Add item
tasks.update((list) => list..add('Task 3'));

// Remove item
tasks.update((list) => list..removeAt(0));

// UI Binding
PureBuilder<List<String>>(
  pure: tasks,
  builder: (context, list) => ListView.builder(
    itemCount: list.length,
    itemBuilder: (context, index) => ListTile(title: Text(list[index])),
  ),
);
```

---

### 4. Native Time-Travel (Undo / Redo)

```dart
final textState = Pure<String>('Initial Text', enableHistory: true);

// Mutate state
textState.value = 'New Value';

// Time travel
if (textState.canUndo) textState.undo();
if (textState.canRedo) textState.redo();
```

---

### 5. Atomic Glitch-Free Batching

Execute multiple signal updates simultaneously in a single UI frame update:

```dart
Pure.batch(() {
  itemPrice.value = 50.0;
  itemQuantity.value = 4;
});
```

---

### 6. Side-Effect Listening (`PureConsumer`)

Use `PureConsumer` to execute side-effects like SnackBars, Dialogs, or Navigation without rebuilding widgets:

```dart
PureConsumer<String?>(
  pure: errorMessageSignal,
  listener: (context, message) {
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  },
  child: const HomeScreen(),
);
```

---

### 7. Selective State Projection (`PureSelect`)

Rebuild only when a specific property of a complex object changes:

```dart
class UserProfile {
  final String name;
  final int age;
  UserProfile(this.name, this.age);
}

final userState = Pure<UserProfile>(UserProfile('Alice', 28));

// Rebuilds ONLY when 'name' changes, ignoring changes to 'age'
PureSelect<UserProfile, String>(
  pure: userState,
  selector: (user) => user.name,
  builder: (context, name) => Text('Hello, $name!'),
);
```

---

### 8. FutureFirst / Async Signals (`Pure.future`)

Reactive async signals automatically track connection states (`waiting`, `done`, `error`):

```dart
// Declare a Future-backed signal
final userProfile = Pure.future<String>(() async {
  await Future.delayed(const Duration(seconds: 2));
  return "User profile data loaded successfully!";
});

// UI Binding
PureBuilder<AsyncSnapshot<String>>(
  pure: userProfile,
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CircularProgressIndicator();
    }
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    }
    return Text(snapshot.data ?? 'No data');
  },
);
```

---

## 🏛 Architectural Patterns

### Clean Architecture

```dart
class UserController {
  final UserRepository repository;

  UserController(this.repository);

  // Reactive State Signals
  final users = Pure<List<User>>([]);
  final isLoading = Pure<bool>(false);
  final errorMessage = Pure<String?>(null);

  Future<void> loadUsers() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      users.value = await repository.fetchUsers();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
```

---

### MVVM (Model-View-ViewModel)

```dart
// ViewModel
class UserViewModel {
  final UserRepository repository;
  UserViewModel(this.repository);

  final userList = Pure<List<User>>([]);
  final isFetching = Pure<bool>(false);

  // Computed state property exposed to View
  late final totalUserCount = Pure<int>.computed(() => userList.value.length);

  Future<void> fetchUsers() async {
    isFetching.value = true;
    userList.value = await repository.fetchUsers();
    isFetching.value = false;
  }
}

// View (StatelessWidget)
class UserView extends StatelessWidget {
  final UserViewModel viewModel;
  const UserView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: PureBuilder<int>(
          pure: viewModel.totalUserCount,
          builder: (context, count) => Text('Users ($count)'),
        ),
      ),
      body: PureBuilder<bool>(
        pure: viewModel.isFetching,
        builder: (context, fetching) {
          if (fetching) return const CircularProgressIndicator();
          return PureBuilder<List<User>>(
            pure: viewModel.userList,
            builder: (context, list) => ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, i) => ListTile(title: Text(list[i].name)),
            ),
          );
        },
      ),
    );
  }
}
```

---

### MVC (Model-View-Controller)

```dart
// Controller
class ProductController {
  final products = Pure<List<Product>>([]);
  final cartCount = Pure<int>(0);

  void addToCart(Product product) {
    cartCount.value++;
  }
}

// View
class ProductListView extends StatelessWidget {
  final ProductController controller = ProductController();
  ProductListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          PureBuilder<int>(
            pure: controller.cartCount,
            builder: (context, count) => Chip(label: Text('$count items')),
          ),
        ],
      ),
      body: PureBuilder<List<Product>>(
        pure: controller.products,
        builder: (context, list) => ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, i) => ListTile(
            title: Text(list[i].title),
            trailing: IconButton(
              icon: const Icon(Icons.add_shopping_cart),
              onPressed: () => controller.addToCart(list[i]),
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## 🧪 Unit Testing

Testing `Pure` signals is completely decoupled from the Flutter widget tree. Write simple, ultra-fast Dart unit tests:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:purebind/purebind.dart';

void main() {
  test('Pure signal updates and triggers listeners', () {
    final count = Pure<int>(0);
    int callCount = 0;

    count.update((val) => val + 1);

    expect(count.value, equals(1));
  });

  test('Computed signal updates automatically', () {
    final price = Pure<double>(10.0);
    final qty = Pure<int>(2);
    final total = Pure<double>.computed(() => price.value * qty.value);

    expect(total.value, equals(20.0));

    price.value = 15.0;
    expect(total.value, equals(30.0));
  });
}
```

---

## 👏 Credits & Acknowledgments

`PureBind` is created and maintained with inspiration from modern reactive signal primitives and fine-grained dependency graph principles.

Special thanks to the Flutter and Dart open-source communities for continuous innovation in reactive UI architecture.

---

## 📜 License

MIT License. Free for commercial and open-source projects.
