import 'package:flutter/material.dart';

class FloatingActionBubble extends AnimatedWidget {
  const FloatingActionBubble({
    Key? key,
    required this.animationController,
    required this.title,
    required this.items,
    required this.onPress,
    required this.iconColor,
    required this.backGroundColor,
    required Animation animation,
    this.herotag,
    this.iconData,
    this.animatedIconData,
    this.alignment = FloatingActionAlignment.right, // Nueva propiedad
  })  : assert((iconData == null && animatedIconData != null) ||
      (iconData != null && animatedIconData == null)),
        super(listenable: animation, key: key);

  final Widget title;
  final List<Bubble> items;
  final void Function() onPress;
  final AnimatedIconData? animatedIconData;
  final Object? herotag;
  final IconData? iconData;
  final Color iconColor;
  final Color backGroundColor;
  final AnimationController animationController;
  final FloatingActionAlignment alignment; // Nueva propiedad

  get _animation => listenable;

  Widget buildItem(BuildContext context, int index, void Function() onPress) {
    final screenWidth = MediaQuery.of(context).size.width;

    TextDirection textDirection = Directionality.of(context);

    double animationDirection = textDirection == TextDirection.ltr ? -1 : 1;

    if (alignment == FloatingActionAlignment.left) {
      animationDirection *= -1; // Invierte la dirección si la alineación es izquierda
    }

    final transform = Matrix4.translationValues(
      animationDirection *
          (screenWidth - _animation.value * screenWidth) *
          ((items.length - index) / 4),
      0.0,
      0.0,
    );

    return Align(
      alignment: alignment == FloatingActionAlignment.left
          ? Alignment.centerLeft
          : Alignment.centerRight,
      child: Transform(
        transform: transform,
        child: Opacity(
          opacity: _animation.value,
          child: BubbleMenu(items[index], onPressParent: closeFloatingMenu),
        ),
      ),
    );
  }

  // Resto del código sin cambios...
  // Método que cierra el menú flotante
  void closeFloatingMenu() {
    if (animationController.isCompleted) {
      animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32.0, 0.0, 0.0, 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: alignment == FloatingActionAlignment.left
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          IgnorePointer(
            ignoring: _animation.value == 0,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (_, __) => const SizedBox(height: 12.0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: items.length,
              itemBuilder: (context, index) => buildItem(context, index, onPress),
            ),
          ),

          FloatingActionButton.extended(
            heroTag: herotag ?? const _DefaultHeroTag(),
            backgroundColor: backGroundColor,
            onPressed: onPress,
            icon: iconData == null
                ? AnimatedIcon(
              icon: animatedIconData!,
              progress: _animation,
              color: iconColor,
            )
                : Icon(
              iconData,
              color: iconColor,
            ),
            label: title,
          ),
        ],
      ),
    );
  }
}

enum FloatingActionAlignment {
  left,
  right,
}

class Bubble {
  const Bubble({
    required IconData icon,
    required Color iconColor,
    required String title,
    required TextStyle titleStyle,
    required Color bubbleColor,
    required this.onPress,
  })  : _icon = icon,
        _iconColor = iconColor,
        _title = title,
        _titleStyle = titleStyle,
        _bubbleColor = bubbleColor;

  final IconData _icon;
  final Color _iconColor;
  final String _title;
  final TextStyle _titleStyle;
  final Color _bubbleColor;
  final void Function() onPress;
}

class BubbleMenu extends StatelessWidget {
  const BubbleMenu(this.item, {Key? key, required this.onPressParent})
      : super(key: key);

  final Bubble item;
  final void Function() onPressParent;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      shape: const StadiumBorder(),
      padding: const EdgeInsets.only(top: 11, bottom: 13, left: 32, right: 32),
      color: item._bubbleColor,
      splashColor: Colors.grey.withOpacity(0.1),
      highlightColor: Colors.grey.withOpacity(0.1),
      elevation: 2,
      highlightElevation: 2,
      disabledColor: item._bubbleColor,
      onPressed: () {
        item.onPress();
        onPressParent();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            item._icon,
            color: item._iconColor,
          ),
          const SizedBox(
            width: 10.0,
          ),
          Text(
            item._title,
            style: item._titleStyle,
          ),
        ],
      ),
    );
  }
}

class _DefaultHeroTag {
  const _DefaultHeroTag();
  @override
  String toString() => '<default FloatingActionBubble tag>';
}