import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:purebind/purebind.dart';

class UserViewModel {
  final isLoading = Pure<bool>(false);
  final userName = Pure<String>('');

  Future<void> fetchUser() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 50));
    userName.value = "Shithin CP";
    isLoading.value = false;
  }
}

void main() {
  testWidgets('UserScreen renders loading and user data with PureBuilder', (
    tester,
  ) async {
    final viewModel = UserViewModel();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PureBuilder<bool>(
            pure: viewModel.isLoading,
            builder: (context, isLoading) {
              if (isLoading) {
                return const CircularProgressIndicator();
              }

              return PureBuilder<String>(
                pure: viewModel.userName,
                builder: (context, name) {
                  if (name.isEmpty) {
                    return const Text("No user data");
                  }
                  return Text("Welcome, $name");
                },
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => viewModel.fetchUser(),
            child: const Icon(Icons.download),
          ),
        ),
      ),
    );

    expect(find.text("No user data"), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump(); // rebuild loading indicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 100)); // finish fetch
    expect(find.text("Welcome, Shithin CP"), findsOneWidget);
  });
}
