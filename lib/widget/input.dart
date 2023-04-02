import 'package:flutter/material.dart';

/// The [TextField] where the user will type their search.
class WatsonSearchInput extends StatefulWidget {
  const WatsonSearchInput({
    super.key,
    this.hintText,
    this.onTextChanged,
    this.onSubmit,
  });

  /// The text displayed in the input in order to help the user know what to
  /// write.
  final String? hintText;

  /// Function called when the text written in the input has changed.
  final Function(String textChanged)? onTextChanged;

  /// Function called when the text written in the input is submitted.
  final Function(String submittedText)? onSubmit;

  @override
  State<StatefulWidget> createState() => _WatsonSearchInputState();
}

class _WatsonSearchInputState extends State<WatsonSearchInput> {
  // Whether the close button is shown.
  bool showClose = false;

  // Text controller for the input.
  TextEditingController textArea = TextEditingController();

  /// Makes the close button displayed if the [textChanged] is not empty.
  void update(String textChanged) {
    // Saves the old [showClose] value to know if it has changed or not.
    bool oldShowClose = showClose;

    // Does not show the close button if the text is empty.
    showClose = textChanged.isNotEmpty;

    // Calls the listener
    widget.onTextChanged?.call(textChanged);

    // Avoids useless [setState] call if [showClose] did not changed.
    if (oldShowClose != showClose) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: textArea,
            decoration: InputDecoration.collapsed(
              hintText: widget.hintText,
            ),

            // Calls [onTextChanged] and define if the close button should be
            // shown or not.
            onChanged: (text) {
              update(text);
            },

            onSubmitted: (text) {
              widget.onSubmit?.call(text);
            },
          ),
        ),
        if (showClose)
          // Text reset button
          IconButton(
            onPressed: () => textArea.clear(),
            icon: const Icon(Icons.close),
          ),
      ],
    );
  }
}
