import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sherlock/widget/input.dart';

class WatsonSearchBar extends StatefulWidget {
  /// The icon next to the search input.
  ///
  /// If [iconized] is `true`, shows the search input. Otherwise, it only
  /// decorates the search bar.
  final Icon searchIcon;

  /// The icon used as a button to cancel the search.
  ///
  /// If [iconized] is `true`, hides the search input. Otherwise, it is never
  /// displayed.
  final Icon closeIcon;

  /// The width of the box containing the whole search bar.
  final double? width;

  /// The height of the box containing the whole search bar.
  final double? height;

  /// The margin of the box containing the whole search bar.
  final EdgeInsets? margin;

  /// The decoration of the box containing the whole search bar.
  final BoxDecoration? decoration;

  /// The controller to programmatically show or hide the input.
  final SearchBarController? controller;

  /// The input inside the search bar where the user types their search.
  final SearchInput searchInput;

  /// Whether the search bar is iconized or not.
  ///
  /// When the search bar is iconized, the input is hidden and the only thing
  /// that appears in the search bar is the search button to make the search
  /// input appears.
  final bool iconized;

  const WatsonSearchBar({
    super.key,
    required this.searchInput,
    this.searchIcon = const Icon(Icons.search),
    this.closeIcon = const Icon(Icons.arrow_back),
    this.iconized = false,
    this.width,
    this.height,
    this.margin,
    this.decoration,
    this.controller,
  });

  @override
  State<StatefulWidget> createState() => _SearchBarState();
}

class _SearchBarState extends State<WatsonSearchBar> {
  /// Whether the input inside the search bar is shown or hidden.
  bool _showInput = false;

  /// Gets the visibility of the input in the search bar.
  bool get isInputVisible => _showInput;

  /// Defines if the input is going to be shown or hidden.
  ///
  /// On change, it updates the widget.
  void changeInputVisibility(bool value) {
    // Nothing to change
    if (value == isInputVisible) return;

    if (widget.iconized) {
      // Updates the visibility value.
      _showInput = value;
      // Updates the widget.
      setState(() {});
    }
  }

  /// Makes the input shown.
  void showInput() => changeInputVisibility(true);

  /// Makes the input hidden.
  void hideInput() => changeInputVisibility(false);

  @override
  void initState() {
    super.initState();

    // Initial state of show/hide of the input is defined by the widget.
    _showInput = (!widget.iconized);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin ?? const EdgeInsets.all(10.0),
      padding: const EdgeInsets.all(5),
      width: widget.width,
      height: widget.height,
      decoration: widget.decoration ??
          BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            color: Theme.of(context).focusColor,
          ),
      child: _showInput
          ? Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildIconButton(context),
                Expanded(
                  child: widget.searchInput,
                ),
              ],
            )
          : buildIconButton(context),
    );
  }

  /// The icon next to the input.
  Widget buildIconButton(BuildContext context) {
    return IconButton(
      onPressed: () {
        if (widget.iconized) {
          isInputVisible ? hideInput() : showInput();
        }
      },
      icon: !_showInput ? widget.searchIcon : widget.closeIcon,
    );
  }
}

class SearchBarController {
  /// Creates a controller to show or hide the search bar's input.
  SearchBarController();

  _SearchBarState? _state;

  /// Disposes this controller.
  void dispose() => _state = null;

  /// Shows the search bar's input when it was previously hidden via [hide].
  void show() => _state?.showInput();

  /// Hides the search bar's input when it was previously shown via [show].
  void hide() => _state?.hideInput();
}
