import 'package:bobobidou/l10n/app_localizations.dart';
import 'package:bobobidou/pages/camera_page.dart';
import 'package:bobobidou/providers/auth_provider.dart';
import 'package:bobobidou/theme/bobo_tokens.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class IngredientInputWidget extends StatefulWidget {
  final List<String> initialIngredients;
  final Function(List<String>) onIngredientsChanged;

  const IngredientInputWidget({
    super.key,
    this.initialIngredients = const [],
    required this.onIngredientsChanged,
  });

  @override
  State<IngredientInputWidget> createState() => _IngredientInputWidgetState();
}

class _IngredientInputWidgetState extends State<IngredientInputWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<String> _ingredients = [];
  // True while the session is checked before opening the camera: renewing the
  // token can take a while when the backend wakes up from a cold start
  bool _isOpeningCamera = false;

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
    if (_isOpeningCamera) return;

    // Vérifier si l'utilisateur est authentifié
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Renouveler le token si besoin ; si la session est perdue, on repasse par le login
    setState(() {
      _isOpeningCamera = true;
    });
    final bool hasSession;
    try {
      hasSession = await authProvider.ensureValidSession();
    } finally {
      if (mounted) {
        setState(() {
          _isOpeningCamera = false;
        });
      }
    }
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
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: BoboSpace.xs, bottom: BoboSpace.sm),
          child: Text(
            localizations.translate('what_did_you_eat'),
            style: theme.textTheme.titleSmall,
          ),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  hintText: localizations.translate('add_ingredient'),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add_circle_rounded),
                    color: theme.colorScheme.onPrimaryContainer,
                    tooltip: localizations.translate('add'),
                    onPressed: () {
                      _addIngredient(_controller.text);
                      _focusNode.requestFocus();
                    },
                  ),
                ),
                onSubmitted: (value) {
                  _addIngredient(value);
                  _focusNode.requestFocus();
                },
              ),
            ),
            const SizedBox(width: BoboSpace.sm),
            // Camera button: detect the ingredients from a photo
            IconButton.filledTonal(
              icon: _isOpeningCamera
                  ? SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    )
                  : const Icon(Icons.photo_camera_rounded),
              iconSize: 26,
              style: IconButton.styleFrom(
                backgroundColor: theme.colorScheme.primaryContainer,
                foregroundColor: theme.colorScheme.onPrimaryContainer,
                fixedSize: const Size(52, 52),
                shape: const RoundedRectangleBorder(borderRadius: BoboRadius.mdAll),
              ),
              // Not disabled while loading: it would grey out the spinner
              onPressed: _isOpeningCamera ? () {} : _openCamera,
              tooltip: localizations.translate('take_photo_for_ingredients'),
            ),
          ],
        ),
        const SizedBox(height: BoboSpace.sm),
        if (_ingredients.isEmpty)
          Padding(
            padding: const EdgeInsets.only(left: BoboSpace.xs),
            child: Text(
              localizations.translate('add_separately'),
              style: theme.textTheme.bodySmall,
            ),
          )
        else
          Wrap(
            spacing: BoboSpace.sm,
            runSpacing: BoboSpace.sm,
            children: _ingredients.map((ingredient) {
              return Chip(
                label: Text(ingredient),
                onDeleted: () => _removeIngredient(ingredient),
                deleteIcon: const Icon(Icons.close_rounded, size: 18),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              );
            }).toList(),
          ),
      ],
    );
  }
}
