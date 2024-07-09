import 'package:flutter/material.dart';

class DropdownStyle {
  final Color? backgroundColor;
  final BoxBorder? border;
  final BorderRadiusGeometry? borderRadius;

  const DropdownStyle({
    this.backgroundColor,
    this.border,
    this.borderRadius,
  });
}

class ContainerStyle {
  final BoxConstraints? constraints;
  final Color? backgroundColor;
  final BoxBorder? border;
  final BorderRadiusGeometry? borderRadius;
  final EdgeInsetsGeometry? padding;

  const ContainerStyle({
    this.constraints,
    this.backgroundColor,
    this.border,
    this.borderRadius,
    this.padding,
  });
}

class DropdownValueWithChildren<T, U> {
  final T? value;
  final List<U>? children;
  U? chosenChild;

  DropdownValueWithChildren({
    this.value,
    this.children,
    this.chosenChild,
  });
}

class TortugaGroupedDropdown<T, U> extends StatefulWidget {
  const TortugaGroupedDropdown({
    required this.onChanged,
    required this.items,
    this.itemBuilder,
    this.builder,
    this.childBuilder,
    this.value,
    this.hint,
    this.arrowIcon,
    this.enabled = true,
    this.dropdownStyle,
    this.containerStyle = const ContainerStyle(
      backgroundColor: Colors.white,
      border: Border(
        top: BorderSide(color: Colors.grey),
        bottom: BorderSide(color: Colors.grey),
        left: BorderSide(color: Colors.grey),
        right: BorderSide(color: Colors.grey),
      ),
    ),
    super.key,
  });

  final List<DropdownValueWithChildren<T, U>> items;
  final DropdownValueWithChildren<T, U>? value;
  final Widget? hint;
  final Widget Function(DropdownValueWithChildren<T, U> item)? builder;
  final Widget Function(DropdownValueWithChildren<T, U> item, bool isSelected)?
      itemBuilder;
  final Widget Function(U child)? childBuilder;
  final bool enabled;
  final Icon? arrowIcon;
  final ValueChanged<DropdownValueWithChildren<T, U>?>? onChanged;
  final DropdownStyle? dropdownStyle;
  final ContainerStyle? containerStyle;

  @override
  State<TortugaGroupedDropdown<T, U>> createState() =>
      _TortugaGroupedDropdownState<T, U>();
}

class _TortugaGroupedDropdownState<T, U>
    extends State<TortugaGroupedDropdown<T, U>>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  late bool _isOverlayVisible;
  late AnimationController _controller;
  late Animation<double> _arrowAnimation;
  DropdownValueWithChildren<T, U>? _selectedItem;

  @override
  void initState() {
    super.initState();

    _isOverlayVisible = false;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _arrowAnimation = Tween<double>(begin: 0.0, end: 0.25).animate(_controller);

    if (widget.value?.value != null) _selectedItem = widget.value;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => widget.enabled ? _showOverlay(context) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: widget.containerStyle?.padding ??
            const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: widget.containerStyle?.backgroundColor ?? Colors.transparent,
          border: widget.containerStyle?.border ??
              Border.all(color: Colors.grey.withOpacity(0.3)),
          borderRadius:
              widget.containerStyle?.borderRadius ?? BorderRadius.circular(15),
        ),
        constraints: widget.containerStyle?.constraints ??
            const BoxConstraints(
              minWidth: 200,
              minHeight: 60,
              maxWidth: double.infinity,
              maxHeight: double.infinity,
            ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_selectedItem != null)
              Expanded(
                child: widget.builder != null
                    ? widget.builder!(_selectedItem!)
                    : Text(_selectedItem!.toString()),
              )
            else
              widget.hint ?? const Text('Select a value'),
            if (widget.enabled)
              RotationTransition(
                turns: _arrowAnimation,
                child:
                    widget.arrowIcon ?? const Icon(Icons.keyboard_arrow_right),
              )
          ],
        ),
      ),
    );
  }

  void _showOverlay(BuildContext context) {
    if (_isOverlayVisible) {
      _closeOverlay();
    } else {
      final overlay = Overlay.of(context);
      final renderBox = context.findRenderObject() as RenderBox;
      final position = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;

      _overlayEntry = OverlayEntry(
        builder: (context) => Stack(
          children: [
            GestureDetector(
              onTap: () {
                _closeOverlay();
              },
              child: Container(
                color: Colors.transparent,
              ),
            ),
            Positioned(
              top: position.dy + size.height,
              left: position.dx,
              width: size.width,
              child: DropdownOverlay<T, U>(
                items: widget.items,
                overlayEntry: _overlayEntry!,
                itemBuilder: widget.itemBuilder,
                onItemSelected: (item) {
                  setState(() {
                    _selectedItem = _selectedItem?.value == item.value &&
                            _selectedItem?.chosenChild == item.chosenChild
                        ? null
                        : item;
                    if (widget.onChanged != null) {
                      widget.onChanged!(_selectedItem);
                    }
                  });
                  _closeOverlay();
                },
                selectedItem: _selectedItem,
                animationController: _controller,
                dropdownStyle: widget.dropdownStyle,
                childBuilder: widget.childBuilder,
              ),
            ),
          ],
        ),
      );

      overlay.insert(_overlayEntry!);
      setState(() {
        _isOverlayVisible = true;
        _controller.forward();
      });
    }
  }

  void _closeOverlay() {
    if (_overlayEntry != null) {
      _controller.reverse().then((_) {
        _overlayEntry?.remove();
        setState(() {
          _isOverlayVisible = false;
        });
      });
    }
  }
}

class DropdownOverlay<T, U> extends StatefulWidget {
  const DropdownOverlay({
    required this.overlayEntry,
    required this.itemBuilder,
    required this.onItemSelected,
    required this.items,
    required this.selectedItem,
    required this.animationController,
    required this.dropdownStyle,
    this.childBuilder,
    super.key,
  });

  final List<DropdownValueWithChildren<T, U>> items;
  final OverlayEntry overlayEntry;
  final Widget Function(DropdownValueWithChildren<T, U> item, bool isSelected)?
      itemBuilder;
  final ValueChanged<DropdownValueWithChildren<T, U>> onItemSelected;
  final DropdownValueWithChildren<T, U>? selectedItem;
  final AnimationController animationController;
  final DropdownStyle? dropdownStyle;
  final Widget Function(U child)? childBuilder;

  @override
  State<DropdownOverlay<T, U>> createState() => _DropdownOverlayState<T, U>();
}

class _DropdownOverlayState<T, U> extends State<DropdownOverlay<T, U>> {
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animation = CurvedAnimation(
      parent: widget.animationController,
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: FadeTransition(
        opacity: _animation,
        child: SizeTransition(
          sizeFactor: _animation,
          child: Container(
            decoration: BoxDecoration(
              color: widget.dropdownStyle?.backgroundColor ?? Colors.white,
              border: widget.dropdownStyle?.border ??
                  const Border(
                    bottom: BorderSide(color: Colors.grey),
                    left: BorderSide(color: Colors.grey),
                    right: BorderSide(color: Colors.grey),
                  ),
              borderRadius: widget.dropdownStyle?.borderRadius,
            ),
            constraints: const BoxConstraints(
              maxHeight: 400,
              minWidth: double.infinity,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                final item = widget.items[index];
                item.chosenChild = widget.selectedItem?.chosenChild;

                final isSelected = (item.value == widget.selectedItem?.value) &&
                    (item.chosenChild == null &&
                        widget.selectedItem?.chosenChild == null);

                return TortugaDropdownItemWidget<T, U>(
                  item: item,
                  isSelected: isSelected,
                  onTap: () {
                    item.chosenChild = null;
                    widget.onItemSelected(item);
                  },
                  onChildTap: (child) {
                    var updatedItem = item..chosenChild = child;
                    widget.onItemSelected(updatedItem);
                  },
                  childBuilder: widget.childBuilder,
                  child: widget.itemBuilder != null
                      ? widget.itemBuilder!(item, isSelected)
                      : null,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class TortugaDropdownItemWidget<T, U> extends StatefulWidget {
  const TortugaDropdownItemWidget({
    required this.item,
    required this.isSelected,
    required this.onTap,
    this.onChildTap,
    this.child,
    this.childBuilder,
    this.height = 70,
    this.padding = const EdgeInsets.all(8.0),
    this.selectedColor,
    super.key,
  });

  final DropdownValueWithChildren<T, U> item;
  final bool isSelected;
  final void Function()? onTap;
  final Function(U child)? onChildTap;
  final Widget? child;
  final Widget Function(U child)? childBuilder;
  final double? height;
  final EdgeInsets? padding;
  final Color? selectedColor;

  @override
  State<TortugaDropdownItemWidget<T, U>> createState() =>
      _TortugaDropdownItemWidgetState<T, U>();
}

class _TortugaDropdownItemWidgetState<T, U>
    extends State<TortugaDropdownItemWidget<T, U>> {
  //* Вариант с открывашкой
  // bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final itemChildren = item.children;

    return InkWell(
      //* Вариант с открывашкой
      // onTap: () {
      //   setState(() {
      //     _isExpanded = !_isExpanded;
      //   });
      // },
      child: Material(
        color: Colors.white,
        child: Column(
          children: [
            InkWell(
              onTap: widget.onTap,
              child: Container(
                color: widget.isSelected
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                    : Theme.of(context).listTileTheme.tileColor,
                height: widget.height,
                padding: widget.padding,
                child: widget.child ??
                    Row(children: [Text(widget.item.value.toString())]),
              ),
            ),
            //* Вариант с открывашкой
            // if (_isExpanded)
            Column(
              children: [
                //* Вариант с открывашкой
                // ListTile(
                //   onTap: widget.onTap,
                //   tileColor: widget.isSelected
                //       ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                //       : Theme.of(context).listTileTheme.tileColor,
                //   textColor: Colors.blue,
                //   title: widget.isSelected
                //       ? const Center(
                //           child: Text('Selected without an account'),
                //         )
                //       : const Center(
                //           child: Text('Select without an account'),
                //         ),
                // ),
                if (itemChildren != null && itemChildren.isNotEmpty)
                  ...itemChildren.map(
                    (child) {
                      return ListTile(
                        tileColor: item.chosenChild == child
                            ? Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.2)
                            : Theme.of(context).listTileTheme.tileColor,
                        onTap: widget.onChildTap != null
                            ? () => widget.onChildTap!(child)
                            : null,
                        title: widget.childBuilder != null
                            ? widget.childBuilder!(child)
                            : Text(child.toString()),
                      );
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
