import 'package:flutter/material.dart';

void main() {
  runApp(Main());
}

/// {@template main}
/// Main widget.
/// {@endtemplate}
class Main extends StatefulWidget {
  /// {@macro main}
  const Main({
    super.key, // ignore: unused_element_parameter
  });

  @override
  State<Main> createState() => _MainState();
}

/// State for widget Main.
class _MainState extends State<Main> {
  @override
  Widget build(BuildContext context) => MaterialApp(home: FormValidation());
}

/// {@template main}
/// FormValidation widget.
/// {@endtemplate}
class FormValidation extends StatefulWidget {
  /// {@macro main}
  const FormValidation({
    super.key, // ignore: unused_element_parameter
  });

  @override
  State<FormValidation> createState() => _FormValidationState();
}

/// State for widget FormValidation.
class _FormValidationState extends State<FormValidation> {
  //
  //
  // --- field controllers ---
  final tags = {'flutter', 'dart'};
  final username = TextEditingController();
  final selectedTags = ValueNotifier<Set<String>>({});
  final agreed = ValueNotifier<bool>(false);
  final custom = MyCustomFieldController();
  late final controllers = [username, selectedTags, agreed, custom];

  // --- form-level state
  late final ValueNotifier<bool> formValid;
  late final ValueNotifier<String?> formError;

  // --- The merged Listeners ---
  late final Listenable formController;

  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    // Initial state initialization
    formValid = ValueNotifier(false);
    formError = ValueNotifier(null);

    formController = Listenable.merge(controllers);
    formController.addListener(_onFormChanged);

    _onFormChanged(); // run once to set initial state
  }

  @override
  void dispose() {
    formController.removeListener(_onFormChanged);

    // Dispose everything that is a ChangeNotifier
    controllers.whereType<ChangeNotifier>().forEach((item) => item.dispose());

    formValid.dispose();
    formError.dispose();

    // Permanent removal of a tree stent
    super.dispose();
  }
  /* #endregion */

  void _onFormChanged() {
    final name = username.text.trim();

    if (name.isEmpty) {
      formValid.value = false;
      formError.value = 'Username is required';
      return;
    }

    if (name.length < 3) {
      formValid.value = false;
      formError.value = 'Username must be at least 3 characters';
      return;
    }

    selectedTags.value.clear();
    if (tags.contains(name)) {
      selectedTags.value.add(name);
    }

    if (!agreed.value) {
      formError.value = 'You must accept the terms';
      formValid.value = false;
      return;
    }

    formValid.value = true;
    formError.value = null;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Form Validation')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: username,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  hintText: 'Enter username',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Tags',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 8),

              ListenableBuilder(
                listenable: formController,
                builder: (context, _) {
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tags
                        .map(
                          (tag) => Chip(
                            label: Text(
                              tag,
                              style: TextStyle(
                                color: selectedTags.value.contains(tag)
                                    ? Colors.red
                                    : null,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),

              const SizedBox(height: 24),

              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('I agree'),
                value: agreed.value,
                onChanged: (value) {
                  setState(() {
                    agreed.value = value ?? false;
                  });
                },
              ),

              const SizedBox(height: 24),

              TextField(
                decoration: const InputDecoration(
                  labelText: 'Custom field',
                  hintText: 'Custom value',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 32),

              ListenableBuilder(
                listenable: formError,
                builder: (context, child) {
                  if (formError.value != null) {
                    return Text(
                      formError.value!,
                      style: TextStyle(color: Colors.red),
                    );
                  }
                  return SizedBox.shrink();
                },
              ),

              ListenableBuilder(
                listenable: formValid,
                builder: (context, child) {
                  return FilledButton(
                    onPressed: formValid.value ? () {} : null,
                    child: const Text('Submit'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class MyCustomFieldController extends ChangeNotifier {}
