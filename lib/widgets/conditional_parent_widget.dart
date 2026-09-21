library;

import 'package:flutter/widgets.dart';

typedef ParentBuilder = Widget Function(Widget child);

class ConditionalParentWidget extends StatelessWidget {
  const ConditionalParentWidget({
    super.key,
    required this.condition,
    required this.parentBuilder,
    this.parentBuilderElse,
    required this.child,
  });

  final bool condition;

  final Widget child;

  final ParentBuilder? parentBuilder;

  final ParentBuilder? parentBuilderElse;

  @override
  Widget build(BuildContext context) {
    return condition
        ? parentBuilder?.call(child) ?? child
        : parentBuilderElse?.call(child) ?? child;
  }
}