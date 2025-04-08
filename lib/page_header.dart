import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.bottom,
    this.bottomMode = BottomMode.pinned,
  });

  final String title;
  final PreferredSizeWidget? bottom;
  final BottomMode bottomMode;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        return _TextPainterSize(
          textDirection: Directionality.of(context),
          text: title,
          maxWidth: constraints.crossAxisExtent - 32,
          textStyle: Theme.of(context).textTheme.headlineLarge,
          builder: (context, size) {
            return _PageHeader(
              collapsedHeight: kToolbarHeight,
              title: PreferredSize(preferredSize: size, child: Text(title)),
              bottom: bottom,
              bottomMode: bottomMode,
            );
          },
        );
      },
    );
  }
}

class _PageHeader extends StatefulWidget {
  const _PageHeader({
    super.key,
    required this.collapsedHeight,
    required this.title,
    this.bottom,
    this.bottomMode = BottomMode.pinned,
  });

  final double collapsedHeight;
  final PreferredSizeWidget title;
  final PreferredSizeWidget? bottom;
  final BottomMode bottomMode;

  @override
  State<_PageHeader> createState() => __PageHeaderState();
}

class __PageHeaderState extends State<_PageHeader> {
  ScrollableState? _scrollableState;

  double get bottomHeight => widget.bottom != null ? widget.bottom!.preferredSize.height : 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollableState?.position.isScrollingNotifier.removeListener(_handleScrollChange);
    _scrollableState = Scrollable.maybeOf(context);
    _scrollableState?.position.isScrollingNotifier.addListener(_handleScrollChange);
  }

  void _handleScrollChange() {
    final ScrollPosition? position = _scrollableState?.position;
    if (position == null || !position.hasPixels || position.pixels <= 0.0) {
      return;
    }

    double? target;

    final fullHeight = kToolbarHeight + widget.title.preferredSize.height;

    print(widget.title.preferredSize.height);

    if (position.pixels < fullHeight) {
      target = position.pixels > (fullHeight / 2) ? fullHeight : 0;
    }

    // Snap the scroll view to a target determined by the navigation bar's
    // position.
    if (target != null) {
      position.animateTo(
        target,
        // Eyeballed on an iPhone 16 simulator running iOS 18.
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastEaseInToSlowEaseOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _HeaderDelegate(
        collapsedHeight: widget.collapsedHeight,
        title: widget.title,
        bottom: widget.bottom,
        bottomMode: widget.bottomMode,
      ),
    );
  }
}

class _TextPainterSize extends StatefulWidget {
  const _TextPainterSize({
    required this.builder,
    required this.text,
    required this.maxWidth,
    required this.textDirection,
    required this.textStyle,
  });

  final String text;
  final TextStyle? textStyle;
  final TextDirection textDirection;
  final Widget Function(BuildContext context, Size size) builder;
  final double maxWidth;

  @override
  State<_TextPainterSize> createState() => __TextPainterSizeState();
}

class __TextPainterSizeState extends State<_TextPainterSize> {
  final _textPainter = TextPainter();

  @override
  void initState() {
    super.initState();
    _textPainter.text = TextSpan(
      text: widget.text,
      style: widget.textStyle,
    );

    _textPainter.textDirection = widget.textDirection;
    _textPainter.layout(maxWidth: widget.maxWidth);
  }

  @override
  void didUpdateWidget(covariant _TextPainterSize oldWidget) {
    if (oldWidget.text != widget.text ||
        oldWidget.maxWidth != widget.maxWidth ||
        oldWidget.textDirection != widget.textDirection) {
      _textPainter.text = TextSpan(
        text: widget.text,
        style: Theme.of(context).textTheme.headlineLarge,
      );

      _textPainter.textDirection = widget.textDirection;
      _textPainter.layout(maxWidth: widget.maxWidth);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, Size(_textPainter.width, _textPainter.height));
  }
}

enum BottomMode { pinned, floating }

class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  const _HeaderDelegate({
    required this.collapsedHeight,
    required this.title,
    required this.bottom,
    required this.bottomMode,
  });

  final double collapsedHeight;
  final PreferredSizeWidget title;
  final PreferredSizeWidget? bottom;
  final BottomMode bottomMode;

  double get bottomHeight {
    if (bottom == null) {
      return 0;
    }

    return bottom!.preferredSize.height;
  }

  @override
  double get maxExtent =>
      math.max(collapsedHeight + title.preferredSize.height + bottomHeight, collapsedHeight);

  @override
  double get minExtent => collapsedHeight + (bottomMode == BottomMode.pinned ? bottomHeight : 0);

  @override
  bool shouldRebuild(covariant _HeaderDelegate oldDelegate) {
    print(oldDelegate.title.preferredSize.height);
    return true;
  }

  @override
  FloatingHeaderSnapConfiguration? get snapConfiguration => FloatingHeaderSnapConfiguration();

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final titleThresold = maxExtent - collapsedHeight - bottomHeight;
    final visibleLargeTitleFraction = (shrinkOffset) / titleThresold;

    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned(
                  top: collapsedHeight,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: ClipRect(
                    child: DefaultTextStyle(
                      style: Theme.of(context).textTheme.headlineLarge!,
                      child: _LargeTitle(
                        child: Column(
                          children: [
                            SizedBox(
                              height: title.preferredSize.height,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 16, right: 16),
                                child: title,
                              ),
                            ),
                            if (bottomMode == BottomMode.floating) bottom!,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    height: kToolbarHeight + MediaQuery.paddingOf(context).top,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      child: ColoredBox(
                        color: Theme.of(context).colorScheme.surface,
                        child: NavigationToolbar(
                          middle: DefaultTextStyle(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge!,
                            child: Opacity(
                              opacity: visibleLargeTitleFraction.clamp(0, 1),
                              child: title,
                            ),
                          ),
                          centerMiddle: false,
                          leading: Icon(Icons.menu),
                        ),
                      ),
                    ),
                  ),
                ),
                // if (bottomMode == BottomMode.floating)
                //   Positioned(
                //     left: 0.0,
                //     right: 0.0,
                //     bottom: 0.0,
                //     child: ClipRect(
                //       child: SizedBox(
                //         height: bottomHeight * (1 - bottomShrinkFactor),
                //         child: bottom,
                //       ),
                //     ),
                //   ),
              ],
            ),
          ),
          if (bottom != null && bottomMode == BottomMode.pinned)
            SizedBox(height: bottom!.preferredSize.height, child: bottom!),
        ],
      ),
    );
  }
}

/// The large title of the navigation bar.
///
/// Magnifies on over-scroll when [CupertinoSliverNavigationBar.stretch]
/// parameter is true.
class _LargeTitle extends SingleChildRenderObjectWidget {
  const _LargeTitle({super.child});

  @override
  _RenderLargeTitle createRenderObject(BuildContext context) {
    return _RenderLargeTitle(
      alignment: AlignmentDirectional.bottomStart.resolve(Directionality.of(context)),
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderLargeTitle renderObject) {
    renderObject.alignment = AlignmentDirectional.bottomStart.resolve(Directionality.of(context));
  }
}

class _RenderLargeTitle extends RenderShiftedBox {
  _RenderLargeTitle({required Alignment alignment}) : _alignment = alignment, super(null);

  Alignment get alignment => _alignment;
  Alignment _alignment;
  set alignment(Alignment value) {
    if (_alignment == value) {
      return;
    }
    _alignment = value;

    markNeedsLayout();
  }

  double _scale = 1.0;

  static double _computeTitleScale(Size childSize, BoxConstraints constraints) {
    const double maxHeight = kToolbarHeight;
    final double scale = 1.0 + 0.03 * (constraints.maxHeight - maxHeight) / maxHeight;
    final double maxScale =
        childSize.width != 0.0
            ? clampDouble(constraints.maxWidth / childSize.width, 1.0, 1.1)
            : 1.1;
    return clampDouble(scale, 1.0, maxScale);
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    final double? distance = child?.getDistanceToActualBaseline(baseline);
    if (distance == null) {
      return null;
    }
    final BoxParentData childParentData = child!.parentData! as BoxParentData;
    return childParentData.offset.dy + distance * _scale;
  }

  @override
  double? computeDryBaseline(covariant BoxConstraints constraints, TextBaseline baseline) {
    final RenderBox? child = this.child;
    if (child == null) {
      return null;
    }
    final BoxConstraints childConstraints = constraints.widthConstraints().loosen();
    final double? result = child.getDryBaseline(childConstraints, baseline);
    if (result == null) {
      return null;
    }
    final Size childSize = child.getDryLayout(childConstraints);
    final double scale = _computeTitleScale(childSize, constraints);
    final Size scaledChildSize = childSize * scale;
    return result * scale +
        alignment.alongOffset(constraints.biggest - scaledChildSize as Offset).dy;
  }

  @override
  void performLayout() {
    final RenderBox? child = this.child;
    size = constraints.biggest;

    if (child == null) {
      return;
    }

    final BoxConstraints childConstraints = constraints.widthConstraints().loosen();
    child.layout(childConstraints, parentUsesSize: true);
    _scale = _computeTitleScale(child.size, constraints);
    final BoxParentData childParentData = child.parentData! as BoxParentData;
    childParentData.offset = alignment.alongOffset(size - (child.size * _scale) as Offset);
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    assert(child == this.child);

    super.applyPaintTransform(child, transform);

    transform.scale(_scale, _scale);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final RenderBox? child = this.child;

    if (child == null) {
      layer = null;
    } else {
      final BoxParentData childParentData = child.parentData! as BoxParentData;

      layer = context.pushTransform(
        needsCompositing,
        offset + childParentData.offset,
        Matrix4.diagonal3Values(_scale, _scale, 1.0),
        (PaintingContext context, Offset offset) => context.paintChild(child, offset),
        oldLayer: layer as TransformLayer?,
      );
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final RenderBox? child = this.child;

    if (child == null) {
      return false;
    }

    final Offset childOffset = (child.parentData! as BoxParentData).offset;

    final Matrix4 transform =
        Matrix4.identity()
          ..scale(1.0 / _scale, 1.0 / _scale, 1.0)
          ..translate(-childOffset.dx, -childOffset.dy);

    return result.addWithRawTransform(
      transform: transform,
      position: position,
      hitTest: (BoxHitTestResult result, Offset transformed) {
        return child.hitTest(result, position: transformed);
      },
    );
  }
}
