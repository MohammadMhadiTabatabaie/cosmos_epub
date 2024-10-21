import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:cosmos_epub/Helpers/html_stylist.dart';
import 'package:cosmos_epub/Model/chapter_model.dart';
import 'package:cosmos_epub/Model/selection_model.dart';
import 'package:cosmos_epub/PageFlip/page_flip_widget.dart';
import 'package:cosmos_epub/show_epub.dart';
import 'package:epubx/epubx.dart' as epubx;
import 'package:flutter/material.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:flutter_html/flutter_html.dart';

class PagingTextHandler {
  final Function paginate;

  PagingTextHandler({required this.paginate});
}

class PagingWidget extends StatefulWidget {
  // final List<String> textContents;
  final epubx.EpubBook document;
  final String textContent;
  final String textContentnumber;
  String? innerHtmlContent;
  final String chapterTitle;
  final int totalChapters;
  final int starterPageIndex;
  final TextStyle style;
  final Function handlerCallback;
  final VoidCallback onTextTap;
  final Function(int, int) onPageFlip;
  final Function(int, int) onLastPage;
  final Widget? lastWidget;
  final Color backColor;
  final int indexpage;
  final int totolepage;
  final List<List<String>> textContents; // اضافه شده: لیست صفحات فصول
  final List<int> chaptercount; // اضافه شده: لیست صفحات فصول
  List<LocalChapterModel> chapters = [];
  final Function(SelectedTextModel selectedTextModel)? onHighlightTap;
  final String bookId;

  PagingWidget(
    this.textContent,
    this.textContentnumber,
    this.innerHtmlContent, {
    super.key,
    this.style = const TextStyle(
      color: Colors.black,
      fontSize: 30,
    ),
    required this.document,
    required this.handlerCallback(PagingTextHandler handler),
    required this.onTextTap,
    required this.onPageFlip,
    required this.onLastPage,
    this.starterPageIndex = 0,
    required this.chapterTitle,
    required this.totalChapters,
    this.lastWidget,
    required this.backColor,
    required this.textContents,
    required this.indexpage,
    required this.totolepage,
    required this.chaptercount,
    required this.chapters,
    this.onHighlightTap,
    required this.bookId,
  });

  @override
  _PagingWidgetState createState() => _PagingWidgetState();
}

class _PagingWidgetState extends State<PagingWidget> {
  Future paginateFuture = Future.value(true);
  final List<String> _pageTexts = [];
  List<Widget> pages = [];
  int _currentPageIndex = 0;
  late double _pageHeight;
  late double _pagewidth;
  late TextPainter textPainter;
  final _pageKey = GlobalKey();
  final _pageController = GlobalKey<PageFlipWidgetState>();
  int totalPages = 0;
  int totalPageCount = 0; // مجموع کل صفحات
  List<int> titlePageNumbers = [];
  // List<SelectedContent> selectedTexts = []; // لیستی از انتخاب‌ها
  int? selectedStartIndex;
  int? selectedEndIndex;
  String selectedText = '';
  String combinedText = '';
  static var paragraphList = ValueNotifier<List<String>>([]);
  static final highlightedStream = ValueNotifier<SelectedTextModel?>(null);
  //late EditableTextState state1;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _pageHeight = MediaQuery.sizeOf(context).height - 50;
      _pagewidth = MediaQuery.of(context).size.width - 20.0;
      textPainter = TextPainter(
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
      );
      _currentPageIndex = widget.starterPageIndex;

      _loadMorePages(initialLoad: true);
      highlightedStream.addListener(() {
        if (widget.onHighlightTap != null && highlightedStream.value != null) {
          widget.onHighlightTap!(highlightedStream.value!);
        }
      });
    });
  }

  // void displayAllHighlights() async {
  //   print('نمایش دیتابیس');
  //   List<SelectedTextModel> highlights =
  //       await bookProgress.getHighlightsByBook('5');

  //   for (var highlight in highlights) {
  //     print('Paragraph Index: ${highlight.paragraphIndex}');
  //     print('Selected Text: ${highlight.selectedText}');
  //     print('Book ID: ${highlight.bookid}');
  //     print('paragraphText: ${highlight.paragraphText}');
  //     print('--------------------------------');
  //   }
  // }
  Future<void> displayAllHighlights() async {
    try {
      // فرض کنیم bookid مربوط به کتاب جاری است

      // دریافت هایلایت‌ها از دیتابیس
      List<SelectedTextModel> highlights =
          await bookProgress.getHighlightsByBook(widget.bookId);

      // پردازش هایلایت‌ها و اعمال آن‌ها به پاراگراف‌ها
      for (var highlight in highlights) {
        int paragraphIndex = highlight.paragraphIndex;
        String formattedParagraph = highlight.paragraphText;

        // اعمال متن هایلایت‌شده به لیست پاراگراف‌ها
        if (paragraphIndex < paragraphList.value.length) {
          paragraphList.value[paragraphIndex] = formattedParagraph;
        }
      }

      // نوتیفای کردن تغییرات به لیسنرها
      paragraphList.notifyListeners();
      highlightedStream.notifyListeners();
    } catch (e) {
      print("Error displaying highlights: $e");
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void _loadMorePages({required bool initialLoad}) async {
    setState(() {
      paginateFuture = _calculateTotalPages();
    });
    var newPages = await paginateFuture;

    setState(() {
      _pageTexts.addAll(newPages);
      pages = _buildPageWidgets(_pageTexts);
    });
    paragraphList.value = _pageTexts.map(
      (e) {
        return e.trim();
      },
    ).toList();
    displayAllHighlights();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PagingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.style != widget.style ||
        oldWidget.textContent != widget.textContent) {
      // _loadPages(initialLoad: false, oldWidget: oldWidget);
      _loadPages();
    }
  }

  void _loadPages() async {
    setState(() {
      paginateFuture = _calculateTotalPages();
    });
    final newPages = await paginateFuture;

    setState(() {
      _pageTexts.addAll(newPages);
      pages = _buildPageWidgets(_pageTexts);
    });
  }

  void _load() async {
    paragraphList.notifyListeners();
  }

  void update() async {
    paginateFuture = _calculateTotalPages();
    final newPages = await paginateFuture;

    setState(() {
      _pageTexts.addAll(newPages);
      pages = _buildPageWidgets(_pageTexts);
    });
  }

  Future<List<String>> _calculateTotalPages() async {
    double currentHeight = 0.0;
    String currentPageContent = '';
    List<String> newPages = [];
    //double maxPageHeight = _pageHeight - 320;

    _pageTexts.clear();
    var document = html_parser.parse(widget.innerHtmlContent);
    var body = document.body!;
    var elements = body.children;
    var headElements = document.head?.children ?? [];
    var bodyElements = document.body?.children ?? [];
    var allElements = [...headElements, ...bodyElements];
    titlePageNumbers.clear();

    for (var element in elements) {
      if (element.localName == 'title') {
        String centeredTitle = '''
        <div style="display: flex; justify-content: center; align-items: center; height: 100vh; flex-direction: row;">
          <h1 style="font-size: 2em;">${element.text}</h1>
        </div>
      ''';
        currentHeight = 200;
        if (currentHeight < _pageHeight) {
          newPages.add('</br>$centeredTitle');
          titlePageNumbers.add(currentPage);
          currentPage++;
          currentPageContent = '';
          currentHeight = 0.0;
        }
      }

      processDivElement(element, (String imageSrc) {
        currentPageContent += '<img src="$imageSrc" />';
        currentHeight += _pageHeight;

        if (currentHeight > _pageHeight - 300) {
          newPages.add(currentPageContent);
          currentPage++;
          currentPageContent = '';
          currentHeight = 0.0;
        }
      }, (String text) async {
        // پردازش متن
        final textSpan = TextSpan(text: text, style: widget.style);
        textPainter.text = textSpan;
        textPainter.layout(minWidth: 0, maxWidth: _pagewidth);
        final lines = textPainter.computeLineMetrics();
        int currentLine = 0;

        while (currentLine < lines.length) {
          int start = currentLine;
          int endLine = currentLine;

          // محاسبه خطوط تا جایی که به ارتفاع صفحه برسیم
          double totalHeight = 0.0;
          while (endLine < lines.length &&
              totalHeight + lines[endLine].height <= _pageHeight) {
            totalHeight += lines[endLine].height;
            endLine++;
          }

          // محاسبه نقطه پایان متن برای این صفحه
          int end = textPainter
              .getPositionForOffset(Offset(
                  0, lines[endLine - 1].baseline + lines[endLine - 1].height))
              .offset;

          // متن مربوط به این صفحه را بگیرید
          final pageContent = text.substring(start, end);

          // اضافه کردن متن به محتوای صفحه فعلی
          currentPageContent += pageContent;
          currentHeight += totalHeight;

          // اگر ارتفاع فعلی بیشتر از ارتفاع صفحه شد، صفحه جدید ایجاد کنید
          if (currentHeight >= _pageHeight - 300) {
            newPages.add(currentPageContent);
            currentPage++;
            currentPageContent = '';
            currentHeight = 0.0;
          }
          // به خط بعدی بروید
          currentLine = endLine;
        }
      });
    }

// افزودن محتوای باقی‌مانده صفحه آخر
    if (currentPageContent.isNotEmpty) {
      newPages.add(currentPageContent);
      currentPage++;
      currentPageContent = '';
      currentHeight = 0.0;
    }

    return newPages;
  }

  void processDivElement(
      divElement,
      void Function(String imageSrc) onImageFound,
      void Function(
        String text,
      ) onTextFound) {
    var children = divElement.children;

    for (var child in children) {
      if (child.localName == 'img') {
        String? src = child.attributes['src'];
        if (src != null) {
          onImageFound(src);
        }
      } else if (child.localName == 'p' //|| child.localName == 'span'
          //  ||
          // child.localName == 'title'
          ) {
        String text = child.text;

        if (text.isNotEmpty) {
          //onTextFound('$text\n ');
          //  onTextFound(text);
          //onTextFound('$text ss');

          //       onTextFound(text + '\n<br>');
          onTextFound('$text <br>');
        }
      }
      if (child.children.isNotEmpty) {
        processDivElement(child, onImageFound, onTextFound);
      }
    }
  }

  List<Widget> _buildPageWidgets(List<String> pageTexts) {
    // paragraphList.value = _pageTexts.toList();
    return pageTexts.map((text) {
      final hasText = text.isNotEmpty;
      final hasImage = text.contains('<img');

      // ScrollController برای هر صفحه مجزا
      final ScrollController pageScrollController = ScrollController();
      return GestureDetector(
        onTap: () {
          setState(() {});
        },
        //   onTap: widget.onTextTap,
        child: Scrollbar(
          scrollbarOrientation: ScrollbarOrientation.right,
          interactive: true,
          controller: pageScrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  margin: const EdgeInsets.only(top: 40),
                  child: ListView(
                    controller: pageScrollController,
                    //  physics: BouncingScrollPhysics(),
                    primary: false,
                    shrinkWrap: true,
                    children: [
                      if (hasText && !hasImage)
                        ValueListenableBuilder(
                            valueListenable: paragraphList,
                            builder: (context, value, child) {
                              var htmlText = HTML.toRichText(
                                  context,
                                  value[_currentPageIndex],
                                  widget.style.color!);

                              return SelectableText.rich(
                                textAlign: TextAlign.justify,
                                TextSpan(
                                  children: [htmlText.text],
                                  style: TextStyle(
                                    leadingDistribution:
                                        TextLeadingDistribution.proportional,
                                    fontSize: widget.style.fontSize,
                                    fontFamily: widget.style.fontFamily,
                                    color: widget.style.color,
                                  ),
                                ),
                                contextMenuBuilder:
                                    (_, EditableTextState state) {
                                  //  state1 = state;
                                  return AdaptiveTextSelectionToolbar(
                                    anchors: state.contextMenuAnchors,
                                    children: (!state.textEditingValue.selection
                                            .isCollapsed)
                                        ? toolbarSelectionActions(state, colors)
                                        : _toolbarActions(state),
                                  );
                                },
                              );
                            })
                      else
                        Html(
                          data: text,
                          style: {
                            'html': Style(
                              textAlign: TextAlign.justify,
                              fontSize: FontSize(widget.style.fontSize!),
                              fontFamily: widget.style.fontFamily,
                              color: widget.style.color,
                            ),
                          },
                          extensions: [
                            TagExtension(
                              tagsToExtend: {"img"},
                              builder: (imageContext) {
                                final url = imageContext.attributes['src']!
                                    .replaceAll('../', '');
                                var content = Uint8List.fromList(widget
                                    .document.Content!.Images![url]!.Content!);
                                return Image.memory(
                                  content,
                                );
                              },
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Color> colors = [
    const Color(0xFFFFFF00),
    const Color(0xFF00FFFF),
    const Color(0xFFFF69B4),
    const Color(0xFF90EE90),
    const Color(0xFFFFA07A),
    const Color(0xFFDDA0DD),
  ];
  List<Widget> toolbarSelectionActions(
      EditableTextState state, List<Color> options) {
    return [
      Padding(
        padding: const EdgeInsets.all(6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Material(
              borderRadius: BorderRadius.circular(50),
              child: InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: () {
                  applyHighlight(
                    state: state,
                    index: _currentPageIndex - 1,
                    tag: 'tgYellow',
                    bookid: widget.bookId,
                  );
                },
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFFF00),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            Material(
              borderRadius: BorderRadius.circular(50),
              child: InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: () {
                  applyHighlight(
                    state: state,
                    index: _currentPageIndex,
                    tag: 'tgCyan',
                    bookid: widget.bookId,
                  );
                },
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00FFFF),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            Material(
              borderRadius: BorderRadius.circular(50),
              child: InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: () {
                  applyHighlight(
                    state: state,
                    index: _currentPageIndex,
                    tag: 'tgPink',
                    bookid: widget.bookId,
                  );
                },
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF69B4),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            Material(
              borderRadius: BorderRadius.circular(50),
              child: InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: () {
                  applyHighlight(
                    state: state,
                    index: _currentPageIndex,
                    bookid: widget.bookId,
                    tag: 'tgGreen',
                  );
                },
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFF90EE90),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            Material(
              borderRadius: BorderRadius.circular(50),
              child: InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: () {
                  applyHighlight(
                    state: state,
                    index: _currentPageIndex,
                    bookid: widget.bookId,
                    tag: 'tgOrange',
                  );
                },
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFA07A),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            Material(
              borderRadius: BorderRadius.circular(50),
              child: InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: () {
                  applyHighlight(
                    state: state,
                    index: _currentPageIndex,
                    bookid: widget.bookId,
                    tag: 'tgLilac',
                  );
                },
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDDA0DD),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            Material(
              borderRadius: BorderRadius.circular(50),
              child: InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: () {
                  applyHighlight(
                    state: state,
                    index: _currentPageIndex,
                    tag: null,
                    bookid: widget.bookId,
                  );
                },
                child: const Icon(Icons.close),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  static List<Widget> _toolbarActions(EditableTextState state) {
    return [
      const Material(
        color: Colors.transparent,
      ),
    ];
  }

  static void applyHighlight({
    required EditableTextState state,
    required String? tag,
    required int index,
    required String bookid,
  }) {
    String paragraphText = paragraphList.value[index];
    final selectedStartIndex = state.textEditingValue.selection.start;
    final selectedEndIndex = state.textEditingValue.selection.end;

    final initialTagRegExp = RegExp(r'^<[^>]+>');
    final lastTagRegExp = RegExp(r'</[^>]+>$');

    final initialTagMatch = initialTagRegExp.firstMatch(paragraphText);
    final lastTagMatch = lastTagRegExp.firstMatch(paragraphText);

    final initialTag = initialTagMatch != null ? initialTagMatch.group(0)! : '';
    final lastTag = lastTagMatch != null ? lastTagMatch.group(0)! : '';

    paragraphText =
        paragraphText.replaceAll(initialTag, '').replaceAll(lastTag, '');

    final spanStartTagRegExp = RegExp(r'^<span [^>]+>');
    final spanEndTagRegExp = RegExp(r'</span>$');

    final spanStartTagMatch = spanStartTagRegExp.firstMatch(paragraphText);
    final spanEndTagMatch = spanEndTagRegExp.firstMatch(paragraphText);

    final spanStartTag =
        spanStartTagMatch != null ? spanStartTagMatch.group(0)! : '';
    final spanEndTag = spanEndTagMatch != null ? spanEndTagMatch.group(0)! : '';

    paragraphText =
        paragraphText.replaceAll(spanStartTag, '').replaceAll(spanEndTag, '');

    final htmlStartIndex = mapPlainTextIndexToHtmlIndex(
      paragraphText,
      selectedStartIndex,
    );
    final htmlEndIndex = mapPlainTextIndexToHtmlIndex(
      paragraphText,
      selectedEndIndex,
    );

    final formattedText = existingColorTagFormat(
      beforeSelectedText: paragraphText.substring(0, htmlStartIndex),
      selectedText: paragraphText.substring(htmlStartIndex, htmlEndIndex),
      afterSelectedText: paragraphText.substring(htmlEndIndex),
      tag: tag,
    );

    final formattedParagraph = '$initialTag'
        '$spanStartTag'
        '$formattedText'
        '$spanEndTag'
        '$lastTag';
    if (html_parser.parse(formattedParagraph).outerHtml.isNotEmpty) {
      paragraphList.value[index] = formattedParagraph;

      // highlightedStream.value = SelectedTextModel(
      //   paragraphIndex: index,
      //   bookid: '5',
      //   tag: tag,
      //   paragraphText: formattedParagraph,
      //   selectedText: state.textEditingValue.selection.textInside(
      //     state.textEditingValue.text,
      //   ),
      // );
      print(' dsdad');
      print(tag);
      bookProgress.setHighlight(
          index,
          bookid,
          tag ?? 'null',
          formattedParagraph,
          state.textEditingValue.selection.textInside(
            state.textEditingValue.text,
          ));
      paragraphList.notifyListeners();
      highlightedStream.notifyListeners();
    }
  }

  static int mapPlainTextIndexToHtmlIndex(String html, int plainTextIndex) {
    int plainIndex = 0;
    int htmlIndex = 0;

    while (htmlIndex < html.length && plainIndex < plainTextIndex) {
      if (html[htmlIndex] == '<') {
        while (html[htmlIndex] != '>') {
          htmlIndex++;
        }
        htmlIndex++;
      } else {
        plainIndex++;
        htmlIndex++;
      }
    }

    return htmlIndex;
  }

  static String existingColorTagFormat({
    required String beforeSelectedText,
    required String selectedText,
    required String afterSelectedText,
    required String? tag,
  }) {
    String before = beforeSelectedText;
    String selected = selectedText;
    String after = afterSelectedText;

    final openTagRegExp =
        RegExp(r'<(tg(?:Yellow|Cyan|Pink|Green|Orange|Lilac))>');
    final closeTagRegExp =
        RegExp(r'</(tg(?:Yellow|Cyan|Pink|Green|Orange|Lilac))>');
    final fullTagRegExp =
        RegExp(r'<(tg(?:Yellow|Cyan|Pink|Green|Orange|Lilac))>(.*?)</\1>');

    while (after.startsWith(closeTagRegExp)) {
      final match = closeTagRegExp.firstMatch(after);
      if (match != null) {
        final tag = match.group(1);
        if (tag != null) {
          final closingTag = '</$tag>';
          after = after.substring(closingTag.length);
          selected = '$selected$closingTag';
        }
      }
    }

    while (fullTagRegExp.hasMatch(selected)) {
      final match = openTagRegExp.allMatches(selected).toList();
      for (var element in match) {
        final tag = element.group(1);
        if (tag != null) {
          selected =
              selected.replaceAll('<$tag>', '').replaceAll('</$tag>', '');
        }
      }
    }

    if (openTagRegExp.hasMatch(selected)) {
      final match = openTagRegExp.firstMatch(selected);
      final tag = match?.group(1);
      if (tag != null) {
        after = '<$tag>$after';
        selected = selected.replaceAll(match?.group(0) ?? '', '');
      }
    }

    if (closeTagRegExp.hasMatch(selected)) {
      final match = closeTagRegExp.firstMatch(selected);
      final tag = match?.group(1);
      if (tag != null) {
        before = '$before</$tag>';
        selected = selected.replaceAll(match?.group(0) ?? '', '');
      }
    }

    return tag != null
        ? '$before<$tag>$selected</$tag>$after'
        : '$before$selected$after';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: paginateFuture,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            //   return const SizedBox();
            return Center(
                child: Container(
              height: 100,
              width: MediaQuery.sizeOf(context).width / 1.5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
              ),
              child: const Center(
                  child: Text(
                'کتاب در حال اماده سازی میباشد ',
                style: TextStyle(fontSize: 16, color: Colors.black),
              )),
            ));
          default:
            return Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: SizedBox(
                        key: _pageKey,
                        //  color: widget.backColor,
                        //   height: _pageHeight,
                        child: PageFlipWidget(
                          key: _pageController,
                          isRightSwipe: true,
                          backgroundColor: widget.backColor,
                          initialIndex: widget.starterPageIndex != 0
                              ? (pages.isNotEmpty &&
                                      widget.starterPageIndex < pages.length
                                  ? widget.starterPageIndex
                                  : 0)
                              : widget.starterPageIndex,
                          onPageFlip: (index) {
                            _load();
                            setState(() {
                              _currentPageIndex = index;
                            });
                            widget.onPageFlip(_currentPageIndex, pages.length);
                            if (_currentPageIndex == pages.length - 1) {
                              widget.onLastPage(
                                  _currentPageIndex, pages.length);
                            }
                          },
                          children: pages,
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      color: widget.backColor,
                      //   height: 40,
                      width: MediaQuery.of(context).size.width,
                      child: Center(
                          child: Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: Column(
                          children: [
                            Text(
                                '${_currentPageIndex + 1} از ${_pageTexts.length}',
                                style: widget.style.copyWith(fontSize: 14)),
                          ],
                        ),
                      )),
                    )),
              ],
            );
        }
      },
    );
  }
}
