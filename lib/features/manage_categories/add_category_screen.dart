import 'package:budget_tracker/features/manage_categories/category_bloc.dart';
import 'package:budget_tracker/models/category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  String? _emoji;
  String _color = '#1E88E5'; // Default blue

  final List<String> _commonEmojis = [
    '🍔', '🚗', '🛍️', '🍿', '💡', '💊', '🎓', '✈️', '💰', '💻', '📈', '📌',
    '🏠', '📱', '🎮', '⚽', '👗', '🎁', '🐶', '🔧', '⛽', '📚', '☕', '👶',
    '💵', '🎉', '❤️', '😢'
  ];

  final List<String> _colors = [
    '#F44336', '#E91E63', '#9C27B0', '#673AB7', '#3F51B5', '#2196F3',
    '#03A9F4', '#00BCD4', '#009688', '#4CAF50', '#8BC34A', '#CDDC39',
    '#FFEB3B', '#FFC107', '#FF9800', '#FF5722', '#795548', '#9E9E9E'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name);
    if (widget.category != null) {
      _emoji = widget.category!.icon;
      _color = widget.category!.color;
    }
  }

  Color _hexToColor(String hex) {
    return Color(int.parse(hex.replaceAll('#', ''), radix: 16) + 0xFF000000);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category == null ? 'Add Category' : 'Edit Category'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                const Text('Select Emoji', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _commonEmojis.map((emoji) {
                    final isSelected = _emoji == emoji;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _emoji = emoji;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.grey.withValues(alpha: 0.3) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected ? Border.all(color: Colors.blue, width: 2) : Border.all(color: Colors.transparent),
                        ),
                        child: Text(emoji, style: const TextStyle(fontSize: 24)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                const Text('Select Color', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _colors.map((colorHex) {
                    final isSelected = _color == colorHex;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _color = colorHex;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _hexToColor(colorHex),
                          shape: BoxShape.circle,
                          border: isSelected ? Border.all(color: Colors.grey, width: 3) : null,
                          boxShadow: isSelected ? [const BoxShadow(color: Colors.black26, blurRadius: 4, spreadRadius: 1)] : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (_emoji == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select an emoji')),
                        );
                        return;
                      }
                      final category = Category(
                        id: widget.category?.id ?? const Uuid().v4(),
                        name: _nameController.text,
                        icon: _emoji!,
                        color: _color,
                      );
                      if (widget.category == null) {
                        context.read<CategoryBloc>().add(
                          AddCategory(category: category),
                        );
                      } else {
                        context.read<CategoryBloc>().add(
                          UpdateCategory(category: category),
                        );
                      }
                      Navigator.pop(context);
                    }
                  },
                  child: Text(widget.category == null ? 'Save Category' : 'Update Category'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
