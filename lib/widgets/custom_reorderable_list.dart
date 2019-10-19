import 'package:flutter/widgets.dart';
import 'package:flutter_reorderable_list/flutter_reorderable_list.dart';

class CustomReorderableList extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final bool Function(int oldPosition, int newPosition) onReorder;

  final Map<Key, int> keyIndices = new Map<Key, int>();

  CustomReorderableList({@required this.itemCount, @required this.itemBuilder, @required this.onReorder});

  @override
  Widget build(BuildContext context) {
    return ReorderableList(
      child: ListView.builder(
        itemCount: itemCount,
        itemBuilder: (context, index) {
          var widget = itemBuilder(context, index);
          return widget.key != null ? _wrapItem(widget, index) : widget;
        },
      ),
      onReorder: (Key draggedItem, Key newPosition) {
        return onReorder(keyIndices[draggedItem], keyIndices[newPosition]);
      },
    );
  }

  ReorderableItem _wrapItem(Widget widget, int index) {
    keyIndices[widget.key] = index;
    return ReorderableItem(
      key: widget.key,
      childBuilder: (context, ReorderableItemState state) {
        return DelayedReorderableListener(
          child: Opacity(
            opacity: state == ReorderableItemState.placeholder ? 0.0 : 1.0,
            child: widget,
          ),
        );
      },
    );
  }
}
