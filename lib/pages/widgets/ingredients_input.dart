import 'package:bobobidou/l10n/app_localizations.dart';
import 'package:bobobidou/pages/camera_page.dart';
import 'package:bobobidou/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  void _addMultipleIngredients(List<String> newIngredients) {
    if (newIngredients.isNotEmpty) {
      setState(() {
        for (final ingredient in newIngredients) {
          if (ingredient.trim().isNotEmpty &&
              !_ingredients.contains(ingredient.trim())) {
            _ingredients.add(ingredient.trim());
          }
        }
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

  void _openCamera() async {
    // Vérifier si l'utilisateur est authentifié
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Renouveler le token si besoin ; si la session est perdue, on repasse par le login
    final hasSession = await authProvider.ensureValidSession();
    if (!mounted) return;

    if (!hasSession) {
      // Si l'utilisateur n'est pas authentifié, lancer le flux d'authentification
      final bool success = await authProvider.login(context);
      if (!mounted) return;
      if (!success) {
        // Si l'authentification échoue, afficher un message et quitter
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).translate('auth_required')),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Si l'utilisateur est authentifié, ouvrir la page de la caméra
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CameraPage(
          onIngredientsDetected: _addMultipleIngredients,
        ),
      ),
    );
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
                          hintText: AppLocalizations.of(context).translate('add_ingredient'),
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
                    const SizedBox(width: 8),
                    // Camera button for taking pictures
                    IconButton(
                      icon: Icon(Icons.camera_alt, color: primaryColor),
                      onPressed: _openCamera,
                      tooltip: AppLocalizations.of(context).translate('take_photo_for_ingredients'),
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
                            color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        backgroundColor: primaryLightColor,
                        deleteIconColor: primaryColor.withOpacity(0.7),
                        onDeleted: () => _removeIngredient(ingredient),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: StadiumBorder(
                          side: BorderSide(
                            color: Colors.transparent,
                          ),
                        ),
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
          child: Row(
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(context).translate('add_separately'),
                  style: TextStyle(color: hintColor, fontSize: 12),
                ),
              ),
              /*Text(
                AppLocalizations.of(context).translate('or_take_photo'),
                style: TextStyle(color: hintColor, fontSize: 12),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.camera_alt,
                color: hintColor,
                size: 12,
              ),*/
            ],
          ),
        ),
      ],
    );
  }
}