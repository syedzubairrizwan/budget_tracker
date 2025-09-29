import 'package:budget_tracker/features/manage_categories/category_bloc.dart';
import 'package:budget_tracker/models/category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
//import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:uuid/uuid.dart';

class AddCategoryScreen extends StatefulWidget {
  final Category? category;
  const AddCategoryScreen({super.key, this.category});

  @override
  AddCategoryScreenState createState() => AddCategoryScreenState();
}

class AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  IconData? _icon;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name);
    if (widget.category != null) {
      _icon =
          IconData(int.parse(widget.category!.icon), fontFamily: 'MaterialIcons');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category == null ? 'Add Category' : 'Edit Category'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickIcon,
                child: const Text('Pick Icon'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (_icon == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please pick an icon'),
                        ),
                      );
                      return;
                    }
                    final category = Category(
                      id: widget.category?.id ?? const Uuid().v4(),
                      name: _nameController.text,
                      icon: _icon!.codePoint.toString(),
                    );
                    if (widget.category == null) {
                      context
                          .read<CategoryBloc>()
                          .add(AddCategory(category: category));
                    } else {
                      context
                          .read<CategoryBloc>()
                          .add(UpdateCategory(category: category));
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text(widget.category == null ? 'Add' : 'Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _pickIcon() async {
    // TODO:Replace with your icon picker implementation or use a supported package.
    // For now, show a simple dialog with a few icons to pick from.
    IconData? icon = await showDialog<IconData>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Pick an Icon'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, Icons.shopping_cart),
            child: Row(
              children: const [
                Icon(Icons.shopping_cart),
                SizedBox(width: 8),
                Text('Shopping Cart'),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, Icons.fastfood),
            child: Row(
              children: const [
                Icon(Icons.fastfood),
                SizedBox(width: 8),
                Text('Fast Food'),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, Icons.directions_car),
            child: Row(
              children: const [
                Icon(Icons.directions_car),
                SizedBox(width: 8),
                Text('Car'),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, Icons.home),
            child: Row(
              children: const [
                Icon(Icons.home),
                SizedBox(width: 8),
                Text('Home'),
              ],
            ),
          ),
        ],
      ),
    );

    setState(() {
      _icon = icon;
    });
  }
}
