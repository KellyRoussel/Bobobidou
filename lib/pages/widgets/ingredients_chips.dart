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
    final primaryLightColor = Theme.of(context).colorScheme.primary.withOpacity(0.08);
    final borderColor = Colors.grey[300];
    final hintColor = Theme.of(context).hintColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: borderColor ?? Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                          contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
                          isDense: true,
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
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      visualDensity: VisualDensity.compact,
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
                            // Lighter text color that matches the app's design
                            color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        backgroundColor: primaryLightColor,
                        // Use a lighter color for the delete icon
                        deleteIconColor: primaryColor.withOpacity(0.7),
                        onDeleted: () => _removeIngredient(ingredient),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        // Add custom shape to manage border color
                        shape: StadiumBorder(
                          side: BorderSide(
                            color: Colors.transparent, // Remove visible border
                          ),
                        ),
                        // Add elevation for a subtle shadow instead of a border
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
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