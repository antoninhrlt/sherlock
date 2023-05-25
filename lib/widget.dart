import 'package:flutter/material.dart';
import 'package:sherlock/completion.dart';
import 'package:sherlock/sherlock.dart';

class SherlockSearchBar extends StatefulWidget {
  final String? hintText;
  final bool? isFullScreen;
  final Color? dividerColor;

  final double? elevation;
  final Color? backgroundColor;
  final Color? overlayColor;
  final BorderSide? side;
  final OutlinedBorder? shape;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;

  final Sherlock sherlock;
  final SherlockCompletion sherlockCompletion;
  final int? sherlockCompletionMinResults;
  final int? sherlockCompletionMaxResults;
  final void Function(String input, Sherlock sherlock)? onSearch;

  final SherlockCompletionsBuilder Function(
    BuildContext context,
    List<String> completions,
  )? completionsBuilder;

  const SherlockSearchBar({
    super.key,
    this.hintText,
    this.isFullScreen,
    this.dividerColor,
    this.elevation,
    this.backgroundColor,
    this.overlayColor,
    this.side,
    this.shape,
    this.padding,
    this.textStyle,
    this.hintStyle,
    required this.sherlock,
    required this.sherlockCompletion,
    this.sherlockCompletionMinResults,
    this.sherlockCompletionMaxResults,
    this.onSearch,
    this.completionsBuilder,
  });

  @override
  State<StatefulWidget> createState() => _SherlockSearchBarState();
}

class _SherlockSearchBarState extends State<SherlockSearchBar> {
  SearchController controller = SearchController();

  @override
  void initState() {
    super.initState();

    controller.addListener(() {
      if (widget.onSearch != null) {
        widget.onSearch!(controller.text, widget.sherlock);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SearchAnchor.bar(
      dividerColor: widget.dividerColor,
      barHintText: widget.hintText,
      isFullScreen: widget.isFullScreen,
      barElevation: MaterialStatePropertyAll(widget.elevation),
      barBackgroundColor: MaterialStatePropertyAll(widget.backgroundColor),
      barOverlayColor: MaterialStatePropertyAll(widget.overlayColor),
      barSide: MaterialStatePropertyAll(widget.side),
      barShape: MaterialStatePropertyAll(widget.shape),
      barPadding: MaterialStatePropertyAll(widget.padding),
      barTextStyle: MaterialStatePropertyAll(widget.textStyle),
      barHintStyle: MaterialStatePropertyAll(widget.hintStyle),
      searchController: controller,
      suggestionsBuilder: (context, controller) {
        // Text inside the input field of the search bar.
        final input = controller.text;
        // SherlockCompletion's result for the input.
        final suggestions = widget.sherlockCompletion.input(
          input: input,
          minResults: widget.sherlockCompletionMinResults,
          maxResults: widget.sherlockCompletionMaxResults,
        );

        final SherlockCompletionsBuilder builder = (widget.completionsBuilder != null)
            ? widget.completionsBuilder!(context, suggestions)
            : SherlockCompletionsBuilder(
                completions: suggestions,
                buildCompletion: (suggestion) => Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(suggestion),
                ),
              );

        return builder.build();
      },
    );
  }
}

/// Creates a list of widget in order to be displayed below the search input to
/// show user completions on their search.
class SherlockCompletionsBuilder {
  final List<String> completions;
  final Widget Function(String completion) buildCompletion;

  /// [completions] is the list of strings given by [SherlockCompletion.input]
  /// or in the [SherlockSearchBar.suggestionsBuilder] field:
  /// ```
  /// SherlockSearchBar(
  ///   suggestionsBuilder: (context, suggestions) => SherlockSuggestionsBuilder(
  ///     suggestions: suggestions,
  ///     ...
  ///   ),
  ///   ...
  /// )
  /// ```
  ///
  /// [buildCompletion] builds a widget for the current completion
  /// ```
  /// SherlockCompletionsBuilder(
  ///   completions: completions,
  ///   buildCompletion: (completion) => Text(buildCompletion),
  /// ),
  /// ```
  SherlockCompletionsBuilder({
    required this.completions,
    required this.buildCompletion,
  });

  /// Builds all the completions into widgets.
  List<Widget> build() {
    return completions.map((completion) => buildCompletion(completion)).toList();
  }
}
