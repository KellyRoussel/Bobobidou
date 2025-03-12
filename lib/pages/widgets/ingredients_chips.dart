import 'package:flutter/material.dart';

class IngredientInputWidget extends StatefulWidget {
  final List<String> initialIngredients;
  final Function(List<String>) onIngredientsChanged;

  const IngredientInputWidget({
    Key? key,
    this.initialIngredients = const [],
    required this.onIngredientsChanged,
  }) : super(key: key);

  @override
  State<IngredientInputWidget> createState() => _IngredientInputWidgetState();
}

class _IngredientInputWidgetState extends State<IngredientInputWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<String> _ingredients = [];

  @override
  void initState() {
    super.initState();
    _ingredients = List.from(widget.initialIngredients);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addIngredient(String ingredient) {
    if (ingredient.trim().isNotEmpty &&
        !_ingredients.contains(ingredient.trim())) {
      setState(() {
        _ingredients.add(ingredient.trim());
        _controller.clear();
      });
      widget.onIngredientsChanged(_ingredients);
    }
  }

  void _removeIngredient(String ingredient) {
    setState(() {
      _ingredients.remove(ingredient);
    });
    widget.onIngredientsChanged(_ingredients);
  }

  @override
  Widget build(BuildContext context) {
    // Get theme colors
    final primaryColor = Theme.of(context).primaryColor;
    final primaryLightColor = Theme.of(context).colorScheme.primary.withOpacity(0.1);
    final borderColor = Theme.of(context).dividerColor;
    final hintColor = Theme.of(context).hintColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
                child: Row(
                  children: [
                    Icon(Icons.food_bank, color: primaryColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        decoration: InputDecoration(
                          hintText: 'Add an ingredient...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: hintColor),
                        ),
                        onSubmitted: (value) {
                          _addIngredient(value);
                          _focusNode.requestFocus();
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add_circle, color: primaryColor),
                      onPressed: () {
                        _addIngredient(_controller.text);
                        _focusNode.requestFocus();
                      },
                    ),
                  ],
                ),
              ),
              if (_ingredients.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _ingredients.map((ingredient) {
                      return Chip(
                        label: Text(
                          ingredient,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        backgroundColor: primaryLightColor,
                        deleteIconColor: primaryColor,
                        onDeleted: () => _removeIngredient(ingredient),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Text(
            'Add each ingredient separately',
            style: TextStyle(color: hintColor, fontSize: 12),
          ),
        ),
      ],
    );
  }
}