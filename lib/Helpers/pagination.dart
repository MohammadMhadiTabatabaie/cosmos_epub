import 'dart:async';
import 'dart:typed_data';

import 'package:cosmos_epub/Model/chapter_model.dart';
import 'package:cosmos_epub/PageFlip/page_flip_widget.dart';
import 'package:epubx/epubx.dart' as epubx;
import 'package:flutter/material.dart';
import 'package:flutter_html_reborn/flutter_html_reborn.dart';
import 'package:html/parser.dart' as html_parser;

class PagingTextHandler {
  final Function paginate;

  PagingTextHandler({required this.paginate});
}

class PagingWidget extends StatefulWidget {
  // final List<String> textContents;
  final epubx.EpubBook document;
  final String textContent;
  final String textContentnumber;
  final String? innerHtmlContent;
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
  PagingWidget(this.textContent, this.textContentnumber, this.innerHtmlContent,
      {super.key,
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
      required this.chapters});

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
  late RenderBox _initializedRenderBox;

  final _pageKey = GlobalKey();
  final _pageController = GlobalKey<PageFlipWidgetState>();
  int totalPages = 0;
  int totalPageCount = 0; // مجموع کل صفحات
  List<int> titlePageNumbers = [];
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
      _loadMorePages(initialLoad: true);
      // print('initState');
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void _loadMorePages({required bool initialLoad}) async {
    setState(() {
      paginateFuture = _calculateTotalPages();
    });
    final newPages = await paginateFuture;

    setState(() {
      _pageTexts.addAll(newPages);
      pages = _buildPageWidgets(_pageTexts);
    });
  }

  rePaginate() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _initializedRenderBox = context.findRenderObject() as RenderBox;
        paginateFuture = _paginate();
      });
    });
  }

  @override
  void didUpdateWidget(covariant PagingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.style != widget.style ||
        oldWidget.textContent != widget.textContent) {
      _loadPages(initialLoad: false, oldWidget: oldWidget);
      // print('didUpdateWidget');
    }
  }

  int findLastHtmlTagIndex(String input) {
    // Regular expression pattern to match HTML tags
    RegExp regex = RegExp(r'<[^>]');

    // Find all matches
    Iterable<Match> matches = regex.allMatches(input);

    // If matches are found
    if (matches.isNotEmpty) {
      // Return the end index of the last match
      return matches.last.end;
    } else {
      // If no match is found, return -1
      return -1;
    }
  }

  void _loadPages(
      {required bool initialLoad,
      required covariant PagingWidget oldWidget}) async {
    setState(() {
      paginateFuture = _calculateTotalPages();
    });
    final newPages = await paginateFuture;

    setState(() {
      _pageTexts.addAll(newPages);
      pages = _buildPageWidgets(_pageTexts);
    });
  }

/*
  // Future<List<String>> _calculateTotalPages() async {
  //   List<String> newPages = [];
  //   double currentHeight = 0.0;
  //   String currentPageContent = '';

  //   var document = html_parser.parse(widget.innerHtmlContent);
  //   var body = document.body!;
  //   var elements = body.children;

  //   for (var element in elements) {
  //     String elementHtml = element.outerHtml;
  //     double elementHeight =200;

  //     if (currentHeight + elementHeight > _pageHeight) {
  //       newPages.add(currentPageContent);
  //       currentPageContent = '';
  //       currentHeight = 0.0;
  //     }

  //     currentPageContent += elementHtml;
  //     currentHeight += elementHeight;
  //   }

  //   if (currentPageContent.isNotEmpty) {
  //     newPages.add(currentPageContent);
  //   }

  //   return newPages;
  // }
  */
  Future<List<String>> _calculateTotalPages() async {
    double currentHeight = 0.0;
    String currentPageContent = '';
    List<String> newPages = [];
    //double maxPageHeight = _pageHeight - 320;
    int currentPage = 1;
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
        newPages.add('</br>$centeredTitle');
        titlePageNumbers.add(currentPage);
        currentPage++;
        currentPageContent = '';
        currentHeight = 0.0;
      }
      processDivElement(element, (String imageSrc) {
        currentPageContent += '<img src="$imageSrc" />';
        currentHeight += 200;

        if (currentHeight > _pageHeight) {
          newPages.add(currentPageContent);
          currentPage++;
          currentPageContent = '';
          //currentHeight = 0.0;
        }
      }, (String text) async {
        // پردازش متن
        final textSpan = TextSpan(text: text, style: widget.style);

        textPainter.text = textSpan;
        textPainter.layout(minWidth: 0, maxWidth: _pagewidth);
        final lines = textPainter.computeLineMetrics();
        int currentLine = 0;
        while (currentLine < lines.length) {
          // int start = textPainter
          //     .getPositionForOffset(Offset(0, lines[currentLine].baseline))
          //     .offset;
          int start = currentLine;
          int endLine = currentLine;

          while (endLine < lines.length &&
              lines[endLine].baseline <
                  lines[currentLine].baseline + _pageHeight) {
            endLine++;
          }
          int end = textPainter
              .getPositionForOffset(Offset(
                  0, lines[endLine - 1].baseline + lines[endLine - 1].height))
              .offset;
          final pageContent = text.substring(start, end);
          // final pageContent = text;

          currentPageContent += pageContent;
          currentHeight += textPainter.size.height;

          if (currentHeight > _pageHeight) {
            newPages.add(currentPageContent);
            currentPage++;
            currentPageContent = '';
            currentHeight = 0.0;
          }

          currentLine = endLine;
        }
      });
    }

    // افزودن محتوای باقی‌مانده صفحه آخر
    if (currentPageContent.isNotEmpty) {
      newPages.add(currentPageContent);
      currentPage++;
    }

    // بهینه‌سازی صفحات برای جلوگیری از صفحات خالی

    print('Pages generated: ${newPages.length}');
    print('Title page numbers: $titlePageNumbers');
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

          onTextFound(text + '\n <br>');
        }
      }
      if (child.children.isNotEmpty) {
        processDivElement(child, onImageFound, onTextFound);
      }
    }
  }

  Future<void> _paginate() async {
    final pageSize = _initializedRenderBox.size;

    _pageTexts.clear();

    final textSpan = TextSpan(
      text: widget.textContent,
      style: widget.style,
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: pageSize.width,
    );

    // https://medium.com/swlh/flutter-line-metrics-fd98ab180a64
    List<LineMetrics> lines = textPainter.computeLineMetrics();
    double currentPageBottom = pageSize.height;
    int currentPageStartIndex = 0;
    int currentPageEndIndex = 0;

    await Future.wait(lines.map((line) async {
      final left = line.left;
      final top = line.baseline - line.ascent;
      final bottom = line.baseline + line.descent;

      var innerHtml = widget.innerHtmlContent;

      // Current line overflow page
      if (currentPageBottom < bottom) {
        currentPageEndIndex = textPainter
            .getPositionForOffset(
                Offset(left, top - (innerHtml != null ? 0 : 100)))
            .offset;

        var pageText = widget.textContent
            .substring(currentPageStartIndex, currentPageEndIndex);

        var index = findLastHtmlTagIndex(pageText) + currentPageStartIndex;

        /// Offset to the left from last HTML tag
        if (index != -1) {
          int difference = currentPageEndIndex - index;
          if (difference < 4) {
            currentPageEndIndex = index - 2;
          }

          pageText = widget.textContent
              .substring(currentPageStartIndex, currentPageEndIndex);
          // print('start : $currentPageStartIndex');
          // print('end : $currentPageEndIndex');
          // print('last html tag : $index');
        }

        _pageTexts.add(pageText);

        currentPageStartIndex = currentPageEndIndex;
        currentPageBottom =
            top + pageSize.height - (innerHtml != null ? 120 : 150);
      }
    }));

    final lastPageText = widget.textContent.substring(currentPageStartIndex);
    _pageTexts.add(lastPageText);
  }

  List<Widget> _buildPageWidgets(List<String> pageTexts) {
    // print('_buildPageWidgets called');
    return pageTexts.map((text) {
      return GestureDetector(
        onTap: widget.onTextTap,
        child: Container(
          //   color: Colors.red[30],
          // height: _pageHeight,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: const EdgeInsets.only(
            top: 40,
          ),
          child: SingleChildScrollView(
              child: Html(
            data: text,
            style: {
              '*': Style(
                  textAlign: TextAlign.justify,
                  fontSize: FontSize(widget.style.fontSize!),
                  fontFamily: widget.style.fontFamily,
                  color: widget.style.color),
            },
            extensions: [
              TagExtension(
                tagsToExtend: {"img"},
                builder: (imageContext) {
                  final url =
                      imageContext.attributes['src']!.replaceAll('../', '');
                  var content = Uint8List.fromList(
                      widget.document.Content!.Images![url]!.Content!);
                  return Image.memory(
                    content,
                    width: 200,
                    height: 200,
                  );
                },
              ),
            ],
          )),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // print('FutureBuilder called');

    return FutureBuilder(
      future: paginateFuture,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
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
                          initialIndex: widget.starterPageIndex != 0
                              ? (pages.isNotEmpty &&
                                      widget.starterPageIndex < pages.length
                                  ? widget.starterPageIndex
                                  : 0)
                              : widget.starterPageIndex,
                          backgroundColor: widget.backColor,
                          onPageFlip: (index) {
                            setState(() {
                              _currentPageIndex = index;
                            });

                            if (_currentPageIndex == pages.length - 1) {
                              widget.onLastPage(index, pages.length);
                            }
                            widget.onPageFlip(index, pages.length);
                            if (_currentPageIndex == pages.length - 5) {}
                          }, //widget.starterPageIndex,
                          //initialIndex: initialPageIndex,
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

/*
Future<List<String>> _paginate(int pagesToLoad) async {
    _pageTexts.clear();
    List<String> newPages = [];
    print('_paginate start');
    final textSpan = TextSpan(
      text: widget.textContent,
      style: widget.style,
    );
    textPainter.text = textSpan;
    print('textPainter');
    textPainter.layout(
      minWidth: 0,
      maxWidth: _pagewidth,
    );
    print('mid');
    final lines = textPainter.computeLineMetrics();
    int currentLine = 0;
    while (currentLine < lines.length && newPages.length < pagesToLoad) {
      int start = textPainter
          .getPositionForOffset(Offset(0, lines[currentLine].baseline))
          .offset;
      int endLine = currentLine;
      // while (currentLine < lines.length) {
      //   int start = textPainter
      //       .getPositionForOffset(Offset(0, lines[currentLine].baseline))
      //       .offset;
      // int endLine = currentLine;
      double currentHeight = 0.0;
      // while (endLine < lines.length &&
      //     lines[endLine].baseline < lines[currentLine].baseline + _pageHeight) {
      //   endLine++;
      // }
      // محاسبه ارتفاع خطوط تا زمانی که به ارتفاع صفحه برسد
      // while (endLine < lines.length &&
      //     currentHeight + lines[endLine].height <= _pageHeight) {
      //   currentHeight += lines[endLine].height;
      //   endLine++;
      // }

      // تغییر: محاسبه ارتفاع خطوط تا زمانی که به ارتفاع صفحه برسد
      while (endLine < lines.length &&
          currentHeight + lines[endLine].height <= _pageHeight) {
        currentHeight += lines[endLine].height;
        endLine++;
      }
      // int end = textPainter
      //     .getPositionForOffset(Offset(0, lines[endLine - 1].baseline))
      //     .offset;
      // تغییر: پایان هر صفحه را با ارتفاع مناسب محاسبه کنید
      print('_paginate تغییر');
      int end = textPainter
          .getPositionForOffset(Offset(
              0, lines[endLine - 1].baseline + lines[endLine - 1].height))
          .offset;
      final pageContent = widget.textContent.substring(start, end);
      newPages.add(pageContent);
      currentLine = endLine;
      //   int end = textPainter.getPositionForOffset(Offset(0, lines[endLine - 1].baseline + lines[endLine - 1].height)).offset;
      // final pageContent = widget.textContent.substring(start, end);
      // newPages.add(pageContent);
      // currentLine = endLine;
    }
    print('_paginate end');
    return newPages;
  }
*/

/*
Future<int> _calculateTotalPagesnumbers() async {
    print('_pageHeight');
     print(_pageHeight);
  print(_pagewidth);
   print('ffffffffff');
    print( widget.style.fontSize);
    _pageTexts.clear();

    List<String> newPages = [];
    print('numbers start');
    final textSpan = TextSpan(
      text: widget.textContentnumber,
      style: widget.style,
    );

    textPainter.text = textSpan;
    print('numbers textPainter');
    textPainter.layout(
      minWidth: 0,
      maxWidth: MediaQuery.of(context).size.width - 20.0,
    );
    print('numbers mid');
    final lines = textPainter.computeLineMetrics();
    int currentLine = 0;
    while (currentLine < lines.length) {
      int start = textPainter
          .getPositionForOffset(Offset(0, lines[currentLine].baseline))
          .offset;
      int endLine = currentLine;

      while (endLine < lines.length &&
          lines[endLine].baseline < lines[currentLine].baseline + _pageHeight) {
        endLine++;
      }
      int end = textPainter
          .getPositionForOffset(Offset(
              0, lines[endLine - 1].baseline + lines[endLine - 1].height))
          .offset;
      final pageContent = widget.textContentnumber.substring(start, end);
      newPages.add(pageContent);
      currentLine = endLine;
    }
    print('numbers end');
    return newPages.length;
  }
*/

// Future<int> _calculateTotalPagess(
//   String chapterContent,
// ) async {
//   _pageTexts.clear();

//   List<String> newPages = [];
//   final textSpan = TextSpan(
//     text: chapterContent,
//     style: widget.style,
//   );

//   textPainter.text = textSpan;

//   textPainter.layout(
//     minWidth: 0,
//     maxWidth: MediaQuery.of(context).size.width - 20.0,
//   );

//   final lines = textPainter.computeLineMetrics();
//   int currentLine = 0;
//   while (currentLine < lines.length) {
//     int start = textPainter
//         .getPositionForOffset(Offset(0, lines[currentLine].baseline))
//         .offset;
//     int endLine = currentLine;

//     while (endLine < lines.length &&
//         lines[endLine].baseline <
//             lines[currentLine].baseline + _pageHeight - 320) {
//       endLine++;
//     }
//     int end = textPainter
//         .getPositionForOffset(Offset(
//             0, lines[endLine - 1].baseline + lines[endLine - 1].height))
//         .offset;
//     final pageContent = chapterContent.substring(start, end);
//     newPages.add(pageContent);
//     currentLine = endLine;
//   }
//   print('numbers end');
//   return newPages.length;
// }


/*
  // _pageTexts.clear();
    // print('ffffffffff');
    // print(widget.style.fontSize);
    // List<String> newPages = [];
    // print('_calculateTotalPages start');
    // final textSpan = TextSpan(
    //   text: widget.textContentnumber,
    //   style: widget.style,
    // );

    // textPainter.text = textSpan;
    // print('_calculateTotalPages textPainter');
    // textPainter.layout(
    //   minWidth: 0,
    //   maxWidth: MediaQuery.of(context).size.width - 20.0,
    // );
    // print('_calculateTotalPages mid');
    // final lines = textPainter.computeLineMetrics();
    // int currentLine = 0;
    // while (currentLine < lines.length) {
    //   int start = textPainter
    //       .getPositionForOffset(Offset(0, lines[currentLine].baseline))
    //       .offset;
    //   int endLine = currentLine;

    //   while (endLine < lines.length &&
    //       lines[endLine].baseline <
    //           lines[currentLine].baseline + _pageHeight - 320) {
    //     endLine++;
    //   }
    //   print('_calculateTotalPages mid 22');
    //   int end = textPainter
    //       .getPositionForOffset(Offset(
    //           0, lines[endLine - 1].baseline + lines[endLine - 1].height))
    //       .offset;
    //   final pageContent = widget.textContentnumber.substring(start, end);
    //   newPages.add(pageContent);
    //   currentLine = endLine;
    // }
    // print('_calculateTotalPages end');
    // return newPages; */


/////
///
///   epub سالم صفحه بندی ولی عمس نمیورذ
/*
Future<List<String>> _calculateTotalPages() async {
    _pageTexts.clear();
    double currentHeight = 0.0;
    String currentPageContent = '';
    List<String> newPages = [];
    double imageHeight = _pageHeight- 320;
    double textHeight = _pageHeight - 320;

    var document = html_parser.parse(widget.innerHtmlContent);
    print(widget.innerHtmlContent);
    var body = document.body!;
    var elements = body.children;

    for (var element in elements) {
      print("=================================== start element nodes ======================================");
      print(element.children);
      print("=================================== end element nodes ========================================");
      // var a = element.nodes ; 
      // print(element.text);
   if (element.outerHtml.contains('img')) {
  
        // print('///////////////////////////////////////');
        //RegExp regExp = RegExp(r'<img\s+[^>]*src=[\'"]([^\'"]+)[\'"][^>]*>')
        RegExp regExp = RegExp(
          r'<img\s+[^>]*src="([^"]+)"[^>]*>',
        );
        Iterable<RegExpMatch> matches = regExp.allMatches(element.outerHtml);

        for (var match in matches) {
          // print(match.group(1));

          currentPageContent +=
              // '<img src="${element.attributes['src']}" />'; // P
              '<img src="${match.group(1)}" />'; 
        }
        currentHeight += imageHeight;
        if (currentHeight > _pageHeight) {
          newPages.add(currentPageContent);
          currentPageContent = '';
          currentHeight = 0.0;
        }
      } else {
        var text = element.text;
        final textSpan = TextSpan(
          text: text,
          style: widget.style
        );

        textPainter.text = textSpan;
        textPainter.layout(
          minWidth: 0,
          maxWidth: MediaQuery.of(context).size.width - 20.0,
        );

        final lines = textPainter.computeLineMetrics();
        int currentLine = 0;
        while (currentLine < lines.length) {
          int start = textPainter
              .getPositionForOffset(Offset(0, lines[currentLine].baseline))
              .offset;
          int endLine = currentLine;

          while (endLine < lines.length &&
              lines[endLine].baseline <
                  lines[currentLine].baseline + _pageHeight - 320) {
            endLine++;
          }
          int end = textPainter
              .getPositionForOffset(Offset(
                  0, lines[endLine - 1].baseline + lines[endLine - 1].height))
              .offset;
          final pageContent = text.substring(start, end);
          currentPageContent += pageContent;
          currentHeight += textHeight;

          if (currentHeight > _pageHeight) {
            newPages.add(currentPageContent);
            currentPageContent = '';
            currentHeight = 0.0;
          }

          currentLine = endLine;
        }
      }
    }

    // اضافه کردن آخرین صفحه
    if (currentPageContent.isNotEmpty) {
      newPages.add(currentPageContent);
    }
    return newPages;
  }*/



  /*

  List<String> parseElementWithChildren1(element) {
    List<String> images = [];

    if (element.localName == 'img') {
      String src = element.attributes['src'] ?? 'No source';

      images.add(src);
    }

    for (var child in element.children) {
      images.addAll(parseElementWithChildren1(child));
    }

    return images;
  }
// بررسی تگ ها 
  String parseElementWithChildren(element, String tagName) {
    if (element.localName == tagName) {
      print(tagName);
      print(element.attributes['src']);
      String v = element.attributes['src'];
      return tagName;
    }

    for (var child in element.children) {
      var result = parseElementWithChildren(child, tagName);
      if (result != null) {
        print(result);
        return result;
      }
    }

    return 'null';
  }
  */
/*
 // int start = textPainter
  //     .getPositionForOffset(Offset(0, lines[currentLine].baseline))
  //     .offset;
  // int end = textPainter
  //     .getPositionForOffset(Offset(
  //         0, lines[endLine - 1].baseline + lines[endLine - 1].height))
  //     .offset;
  //    final pageContent = text.substring(start, end);*/
  
  /**
   *    // double currentHeight = 0.0;
    // String currentPageContent = '';
    // List<String> newPages = [];
    // double imageHeight = _pageHeight - 320;
    // double textHeight = _pageHeight - 320;

    // var document = html_parser.parse(widget.innerHtmlContent);
    // var body = document.body!;
    // var elements = body.children;

    // for (var element in elements) {
    //   if (element.localName == 'div') {
    //     List<String> images = parseElementWithChildren1(element);

    //     if (images.isNotEmpty) {
    //       for (var imageSrc in images) {
    //         print('Image information: $imageSrc');

    //         // فرض کنید ارتفاع هر تصویر 200 پیکسل باشد
    //         double imageHeight = 200;

    //         // اضافه کردن تصویر به محتوای صفحه

    //         // currentPageContent += '<img src="$imageSrc" />';
    //         currentPageContent += '<p > its here must shoud be image </p>';
    //         currentHeight += imageHeight;
    //         // بررسی ارتفاع فعلی و ایجاد صفحه جدید در صورت لزوم
    //         if (currentHeight > _pageHeight) {
    //           newPages.add(currentPageContent);
    //           currentPageContent = '';
    //           currentHeight = 0.0;
    //         }
    //       }
    //     }
    //   }
    //   //else if(true) {
    //   var text = element.text;
    //   if (text.isNotEmpty) {
    //     final textSpan = TextSpan(text: text, style: widget.style);

    //     textPainter.text = textSpan;
    //     textPainter.layout(
    //       minWidth: 0,
    //       maxWidth: MediaQuery.of(context).size.width - 20.0,
    //     );

    //     final lines = textPainter.computeLineMetrics();
    //     int currentLine = 0;
    //     while (currentLine < lines.length) {
    //       int start = textPainter
    //           .getPositionForOffset(Offset(0, lines[currentLine].baseline))
    //           .offset;
    //       int endLine = currentLine;

    //       while (endLine < lines.length &&
    //           lines[endLine].baseline <
    //               lines[currentLine].baseline + _pageHeight - 320) {
    //         endLine++;
    //       }
    //       int end = textPainter
    //           .getPositionForOffset(Offset(
    //               0, lines[endLine - 1].baseline + lines[endLine - 1].height))
    //           .offset;
    //       final pageContent = text.substring(start, end);
    //       currentPageContent += pageContent;
    //       currentHeight += textHeight;

    //       if (currentHeight > _pageHeight) {
    //         newPages.add(currentPageContent);
    //         currentPageContent = '';
    //         currentHeight = 0.0;
    //       }

    //       currentLine = endLine;
    //     }
    //   }
    // }
    // // }

    // if (currentPageContent.isNotEmpty) {
    //   newPages.add(currentPageContent);
    // }
    // return newPages;
   */