import 'package:flutter/material.dart';
import 'package:whatsapp_clone/theme/theme.dart';

class ScrollButton extends StatefulWidget {
  final ScrollController scrollController;
  final int unreadCount;

  const ScrollButton({
    super.key,
    required this.scrollController,
    required this.unreadCount,
  });

  @override
  State<ScrollButton> createState() => _ScrollButtonState();
}

class _ScrollButtonState extends State<ScrollButton> {
  bool showScrollBtn = false;

  @override
  void initState() {
    widget.scrollController.addListener(scrollListener);
    super.initState();
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(scrollListener);
    super.dispose();
  }

  void scrollListener() {
    final position = widget.scrollController.position;
    final diff = position.pixels - position.minScrollExtent;

    if (diff > 80 && !showScrollBtn) {
      setState(() {
        showScrollBtn = true;
      });
    } else if (diff <= 80 && showScrollBtn) {
      setState(() {
        showScrollBtn = false;
      });
    }
  }

  void handleScrollBtnClick() {
    widget.scrollController.animateTo(
      widget.scrollController.position.minScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );

    // Hide the button after it's clicked
    setState(() {
      showScrollBtn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return showScrollBtn
        ? GestureDetector(
            onTap: handleScrollBtnClick,
            child: Stack(
              alignment: Alignment.topLeft,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).custom.colorTheme.appBarColor,
                    boxShadow: const [
                      BoxShadow(
                        offset: Offset(0, 2),
                        blurRadius: 4,
                        color: Colors.black38,
                      )
                    ],
                  ),
                  child: const Icon(Icons.keyboard_double_arrow_down),
                ),
                if (widget.unreadCount > 0) ...[
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).custom.colorTheme.greenColor,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      widget.unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          )
        : Container();
  }
}
