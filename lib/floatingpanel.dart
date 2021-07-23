import 'package:flutter/material.dart';

enum PanelShape { rectangle, rounded }

enum DockType { inside, outside }

enum PanelState { open, closed }

class FloatBoxPanel extends StatefulWidget {
  final double positionTop;
  final double positionLeft;
  final Color borderColor;
  final double borderWidth;
  final double size;
  final double iconSize;
  final IconData panelIcon;
  final BorderRadius borderRadius;
  final Color backgroundColor;
  final Color contentColor;
  final PanelShape panelShape;
  final PanelState panelState;
  final double panelOpenOffset;
  final int panelAnimDuration;
  final Curve panelAnimCurve;
  final DockType dockType;
  final double dockOffset;
  final int dockAnimDuration;
  final Curve dockAnimCurve;
  final List<IconData> buttons;
  final void Function(int)? onPressed;

  FloatBoxPanel({
    this.buttons = const [],
    this.positionTop = 0,
    this.positionLeft = 0,
    this.borderColor = const Color(0xFF333333),
    this.borderWidth = 0,
    this.iconSize = 24,
    this.panelIcon = Icons.add,
    this.size = 70,
    BorderRadius? borderRadius,
    this.panelState = PanelState.closed,
    this.panelOpenOffset = 30.0,
    this.panelAnimDuration = 600,
    this.panelAnimCurve = Curves.fastLinearToSlowEaseIn,
    this.backgroundColor = const Color(0xFF333333),
    this.contentColor = Colors.white,
    this.panelShape = PanelShape.rounded,
    this.dockType = DockType.outside,
    this.dockOffset = 20,
    this.dockAnimCurve = Curves.fastLinearToSlowEaseIn,
    this.dockAnimDuration = 300,
    this.onPressed,
  }) : this.borderRadius = borderRadius ?? BorderRadius.circular(0);

  @override
  _FloatBoxState createState() => _FloatBoxState();
}

class _FloatBoxState extends State<FloatBoxPanel> {
  // Required to set the default state to closed when the widget gets initialized;
  PanelState _panelState = PanelState.closed;

  // Default positions for the panel;
  double _positionTop = 0.0;
  double _positionLeft = 0.0;

  // ** PanOffset ** is used to calculate the distance from the edge of the panel
  // to the cursor, to calculate the position when being dragged;
  double _panOffsetTop = 0.0;
  double _panOffsetLeft = 0.0;

  // This is the animation duration for the panel movement, it's required to
  // dynamically change the speed depending on what the panel is being used for.
  // e.g: When panel opened or closed, the position should change in a different
  // speed than when the panel is being dragged;
  int _movementSpeed = 0;

  @override
  void initState() {
    _positionTop = widget.positionTop;
    _positionLeft = widget.positionLeft;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Width and height of page is required for the dragging the panel;
    double _pageWidth = MediaQuery.of(context).size.width;
    double _pageHeight = MediaQuery.of(context).size.height;

    // All Buttons;
    List<IconData> _buttons = widget.buttons;

    // Dock offset creates the boundary for the page depending on the DockType;
    double _dockOffset = widget.dockOffset;

    // Widget size if the width of the panel;
    double _widgetSize = widget.size;

    // **** METHODS ****

    // Dock boundary is calculated according to the dock offset and dock type.
    double _dockBoundary() {
      if (widget.dockType == DockType.inside) {
        // If it's an 'inside' type dock, dock offset will remain the same;
        return _dockOffset;
      }

      // If it's an 'outside' type dock, dock offset will be inverted, hence
      // negative value;
      return -_dockOffset;
    }

    // If panel shape is set to rectangle, the border radius will be set to custom
    // border radius property of the WIDGET, else it will be set to the size of
    // widget to make all corners rounded.
    BorderRadius _borderRadius() {
      if (widget.panelShape == PanelShape.rectangle) {
        // If panel shape is 'rectangle', border radius can be set to custom or 0;
        return widget.borderRadius;
      }

      // If panel shape is 'rounded', border radius will be the size of widget
      // to make it rounded;
      return BorderRadius.circular(_widgetSize);
    }

    // Total buttons are required to calculate the height of the panel;
    double _totalButtons() {
      return widget.buttons.length.toDouble();
    }

    // Height of the panel according to the panel state;
    double _panelHeight() {
      if (_panelState == PanelState.open) {
        // Panel height will be in multiple of total buttons, I have added "1"
        // digit height for each button to fix the overflow issue. Don't know
        // what's causing this, but adding "1" fixed the problem for now.
        return (_widgetSize + (_widgetSize + 1) * _totalButtons()) +
            (widget.borderWidth);
      }

      return _widgetSize + (widget.borderWidth) * 2;
    }

    // Panel top needs to be recalculated while opening the panel, to make sure
    // the height doesn't exceed the bottom of the page;
    void _calcPanelTop() {
      if (_positionTop + _panelHeight() > _pageHeight + _dockBoundary()) {
        _positionTop = _pageHeight - _panelHeight() + _dockBoundary();
      }
    }

    // Dock Left position when open;
    double _openDockLeft() {
      if (_positionLeft < (_pageWidth / 2)) {
        // If panel is docked to the left;
        return widget.panelOpenOffset;
      }

      // If panel is docked to the right;
      return ((_pageWidth - _widgetSize)) - (widget.panelOpenOffset);
    }

    // Panel border is only enabled if the border width is greater than 0;
    Border? _panelBorder() {
      if (widget.borderWidth > 0) {
        return Border.all(
          color: widget.borderColor,
          width: widget.borderWidth,
        );
      }

      return null;
    }

    // Force dock will dock the panel to it's nearest edge of the screen;
    void _forceDock() {
      // Calculate the center of the panel;
      double center = _positionLeft + (_widgetSize / 2);

      // Set movement speed to the custom duration property or '300' default;
      _movementSpeed = widget.dockAnimDuration;

      // Check if the position of center of the panel is less than half of the
      // page;
      if (center < _pageWidth / 2) {
        // Dock to the left edge;
        _positionLeft = 0.0 + _dockBoundary();
      } else {
        // Dock to the right edge;
        _positionLeft = (_pageWidth - _widgetSize) - _dockBoundary();
      }
    }

    // Animated positioned widget can be moved to any part of the screen with
    // animation;
    return AnimatedPositioned(
      duration: Duration(milliseconds: _movementSpeed),
      top: _positionTop,
      left: _positionLeft,
      curve: widget.dockAnimCurve,

      // Animated Container is used for easier animation of container height;
      child: AnimatedContainer(
        duration: Duration(milliseconds: widget.panelAnimDuration),
        width: _widgetSize,
        height: _panelHeight(),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: _borderRadius(),
          border: _panelBorder(),
        ),
        curve: widget.panelAnimCurve,
        child: Wrap(
          direction: Axis.horizontal,
          children: [
            // Gesture detector is required to detect the tap and drag on the panel;
            GestureDetector(
              onPanEnd: (event) {
                setState(
                  () {
                    _forceDock();
                  },
                );
              },
              onPanStart: (event) {
                // Detect the offset between the top and left side of the panel and
                // x and y position of the touch(click) event;
                _panOffsetTop = event.globalPosition.dy - _positionTop;
                _panOffsetLeft = event.globalPosition.dx - _positionLeft;
              },
              onPanUpdate: (event) {
                setState(
                  () {
                    // Close Panel if opened;
                    _panelState = PanelState.closed;

                    // Reset Movement Speed;
                    _movementSpeed = 0;

                    // Calculate the top position of the panel according to pan;
                    _positionTop = event.globalPosition.dy - _panOffsetTop;

                    // Check if the top position is exceeding the dock boundaries;
                    if (_positionTop < 0 + _dockBoundary()) {
                      _positionTop = 0 + _dockBoundary();
                    }
                    if (_positionTop >
                        (_pageHeight - _panelHeight()) - _dockBoundary()) {
                      _positionTop =
                          (_pageHeight - _panelHeight()) - _dockBoundary();
                    }

                    // Calculate the Left position of the panel according to pan;
                    _positionLeft = event.globalPosition.dx - _panOffsetLeft;

                    // Check if the left position is exceeding the dock boundaries;
                    if (_positionLeft < 0 + _dockBoundary()) {
                      _positionLeft = 0 + _dockBoundary();
                    }
                    if (_positionLeft >
                        (_pageWidth - _widgetSize) - _dockBoundary()) {
                      _positionLeft =
                          (_pageWidth - _widgetSize) - _dockBoundary();
                    }
                  },
                );
              },
              onTap: () {
                setState(
                  () {
                    // Set the animation speed to custom duration;
                    _movementSpeed = widget.panelAnimDuration;

                    if (_panelState == PanelState.open) {
                      // If panel state is "open", set it to "closed";
                      _panelState = PanelState.closed;

                      // Reset panel position, dock it to nearest edge;
                      _forceDock();

                      print("Float panel closed.");
                    } else {
                      // If panel state is "closed", set it to "open";
                      _panelState = PanelState.open;

                      // Set the left side position;
                      _positionLeft = _openDockLeft();

                      _calcPanelTop();

                      print("Float Panel Open.");
                    }
                  },
                );
              },
              child: _FloatButton(
                size: widget.size,
                icon: widget.panelIcon,
                color: widget.contentColor,
                iconSize: widget.iconSize,
              ),
            ),
            Visibility(
              visible: true, // TODO:: _contentVisibility,
              child: Container(
                child: Column(
                  children: List.generate(
                    _buttons.length,
                    (index) {
                      return GestureDetector(
                        onTap: () {
                          if (widget.onPressed != null) {
                            widget.onPressed!(index);
                          }
                        },
                        child: _FloatButton(
                          size: widget.size,
                          icon: _buttons[index],
                          color: widget.contentColor,
                          iconSize: widget.iconSize,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatButton extends StatelessWidget {
  final double size;
  final Color color;
  final IconData icon;
  final double iconSize;

  _FloatButton({
    this.size = 70,
    this.color = Colors.white,
    this.icon = Icons.add,
    this.iconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withOpacity(0.0),
      width: size,
      height: size,
      child: Icon(
        icon,
        color: color,
        size: iconSize,
      ),
    );
  }
}
