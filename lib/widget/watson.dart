import 'package:flutter/material.dart';
import 'package:sherlock/sherlock.dart';
import 'package:sherlock/widget/input.dart';

class WatsonSearchBar extends StatefulWidget {
  /// Decoration for the search bar.
  final BoxDecoration? decoration;

  /// Fixed width for the search bar.
  final double? width;

  /// Fixed height for the search bar.
  final double? height;

  /// Whether the search bar can be iconized.
  ///
  /// True by default.
  final bool iconize;

  /// Whether the search bar is iconized when created. Does not iconize the
  /// search bar if [iconize] is false.
  ///
  /// True by default.
  final bool initiallyIconized;

  /// The icon next to the search input.
  ///
  /// If [iconize] is `true`, it shows the search input. Otherwise, it only
  /// decorates the search bar.
  final Icon searchIcon;

  /// The icon used as a button to iconize the search.
  ///
  /// If [iconize] is `true`, it hides the search input. Otherwise, it is never
  /// displayed.
  final Icon closeIcon;

  /// Function called when the text written in the input has changed.
  final Function(String textChanged)? onTextChanged;

  /// Function called when the text written in the input is submitted.
  ///
  /// Returns a sherlock object which should have performed the search with
  /// the [submittedText] input.
  final Sherlock Function(String submittedText)? onSubmit;

  /// Function called when [onSubmit] returns. Builds the results in the widget
  /// but just under the search bar.
  final Widget Function(Sherlock sherlock)? buildResults;

  /// The text displayed in the input in order to help the user know what to
  /// write.
  final String? hintText;

  const WatsonSearchBar({
    super.key,
    this.decoration,
    this.width,
    this.height,
    this.iconize = true,
    this.initiallyIconized = true,
    this.onTextChanged,
    this.onSubmit,
    this.buildResults,
    this.searchIcon = const Icon(Icons.search),
    this.closeIcon = const Icon(Icons.arrow_back),
    this.hintText,
  });

  @override
  State<StatefulWidget> createState() => _SearchBarState();
}

class _SearchBarState extends State<WatsonSearchBar> {
  /// Input for the search bar.
  late WatsonSearchInput _input;
  late Widget results;

  bool _showInput = true;

  bool get isIconized => _showInput;

  set isIconized(bool value) {
    if (value == isIconized) return;

    if (widget.iconize) {
      _showInput = value;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.iconize) {
      _showInput = !widget.initiallyIconized;
    }

    _input = WatsonSearchInput(
      hintText: widget.hintText,
      onTextChanged: widget.onTextChanged,
      onSubmit: (submittedText) {
        if (widget.onSubmit == null) {
          return;
        }

        final sherlock = widget.onSubmit!(submittedText);

        debugPrint('oui');

        if (widget.buildResults == null) {
          debugPrint('oui2');

          return;
        }

        results = widget.buildResults!(sherlock);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: widget.decoration ??
          BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            color: Theme.of(context).focusColor,
          ),
      width: widget.width,
      height: widget.height,
      child: isIconized
          ? Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildIconButton(context),
                Expanded(
                  child: _input,
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
        // When the search bar is iconized, it shows the input and when the
        //search bar is not iconized, it hides the input.
        if (widget.iconize) {
          isIconized = !isIconized;
        }
      },
      icon: !_showInput ? widget.searchIcon : widget.closeIcon,
    );
  }
}
