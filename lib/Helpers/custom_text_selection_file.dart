import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/change_notifier.dart';

class CustomSelectionToolbar extends StatelessWidget {
  final TextSelectionDelegate delegate;

  CustomSelectionToolbar({required this.delegate});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 50,
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              color: Color(0xffffffff)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () {
                  final text = delegate.textEditingValue.text;
                  final selection = delegate.textEditingValue.selection;
                  Clipboard.setData(ClipboardData(
                      text: text.substring(
                    selection.start,
                    selection.end,
                  )));
                },
              ),
              const SizedBox(width: 5),
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(8),
                    ),
                    color: Color(0xffB0276D)),
              ),
              const SizedBox(width: 5),
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(8),
                    ),
                    color: Color(0xff3EB489)),
              ),
              const SizedBox(width: 5),
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(8),
                    ),
                    color: Color(0xff4430C2)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CustomTextSelectionControls extends TextSelectionControls {
  @override
  Widget buildHandle(
      BuildContext context, TextSelectionHandleType type, double textLineHeight,
      [VoidCallback? onTap]) {
    // TODO: implement buildHandle
    return SizedBox(
      width: 2,
      height: textLineHeight,
      child: Container(
        color: Colors.transparent,
      ),
    );
  }

  @override
  Widget buildToolbar(
      BuildContext context,
      Rect globalEditableRegion,
      double textLineHeight,
      Offset selectionMidpoint,
      List<TextSelectionPoint> endpoints,
      TextSelectionDelegate delegate,
      ValueListenable<ClipboardStatus>? clipboardStatus,
      Offset? lastSecondaryTapDownPosition) {
    // استفاده از موقعیت اولین نقطه انتخاب برای محاسبه مکان نوار ابزار
    final TextSelectionPoint startTextSelectionPoint = endpoints.last;

    // محاسبه مکان نوار ابزار در بالای متن انتخاب شده
    final Offset toolbarOffset = Offset(
        startTextSelectionPoint.point.dx - globalEditableRegion.left,
        startTextSelectionPoint.point.dy - globalEditableRegion.top - 100);

    return Transform.translate(
      offset: toolbarOffset,
      child: CustomSelectionToolbar(delegate: delegate),
    );
  }

  @override
  Offset getHandleAnchor(TextSelectionHandleType type, double textLineHeight) {
    // تعیین موقعیت دسته‌های انتخاب
    switch (type) {
      case TextSelectionHandleType.left:
        return Offset(-10, textLineHeight / 2);
      case TextSelectionHandleType.right:
        return Offset(10, textLineHeight / 2);
      case TextSelectionHandleType.collapsed:
        return Offset(0, textLineHeight / 2); // موقعیت برای انتخاب تکی
    }
  }

  @override
  Size getHandleSize(double textLineHeight) {
    // تعیین اندازه دسته‌های انتخاب
    return Size(50, textLineHeight);
  }
}
