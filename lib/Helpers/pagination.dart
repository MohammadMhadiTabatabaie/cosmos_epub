import 'dart:typed_data';

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
      required this.chaptercount});

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _pageHeight = MediaQuery.sizeOf(context).height - 50;
      _pagewidth = MediaQuery.of(context).size.width - 20.0;
      textPainter = TextPainter(
        textDirection: TextDirection.rtl,
      );
      _loadMorePages(initialLoad: true);
      print('initState');
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
    //   totalPages = await _calculateTotalPagess(widget.textContentnumber);

    setState(() {
      _pageTexts.addAll(newPages);
      pages = _buildPageWidgets(_pageTexts);
      // chapterPages.add(newPages.length); // اضافه کردن تعداد صفحات فصل جدید
    });
  }

  @override
  void didUpdateWidget(covariant PagingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.style != widget.style ||
        oldWidget.textContent != widget.textContent) {
      _loadPages(initialLoad: false, oldWidget: oldWidget);
      print('didUpdateWidget');
    }
  }

  void _loadPages(
      {required bool initialLoad,
      required covariant PagingWidget oldWidget}) async {
    print('_loadPages');

    setState(() {
      paginateFuture = _calculateTotalPages();
    });
    final newPages = await paginateFuture;

    setState(() {
      _pageTexts.addAll(newPages);
      pages = _buildPageWidgets(_pageTexts);
    });
  }

  Future<List<String>> _calculateTotalPages() async {
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
    // return newPages;
    List<String> newPages = [];
    double currentHeight = 0.0;
    String currentPageContent = '';

    var document = html_parser.parse(widget.innerHtmlContent);
    var body = document.body!;
    var elements = body.children;

    for (var element in elements) {
      String elementHtml = element.outerHtml;
      double elementHeight = 500;

      if (currentHeight + elementHeight > _pageHeight) {
        newPages.add(currentPageContent);
        currentPageContent = '';
        currentHeight = 0.0;
      }

      currentPageContent += elementHtml;
      currentHeight += elementHeight;
    }

    if (currentPageContent.isNotEmpty) {
      newPages.add(currentPageContent);
    }

    return newPages;
  }

  List<Widget> _buildPageWidgets(List<String> pageTexts) {
    print('_buildPageWidgets called');

    return pageTexts.map((text) {
      return GestureDetector(
        onTap: widget.onTextTap,
        child: Container(
          //   color: Colors.red[30],
          //height: _pageHeight - 400,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          margin: const EdgeInsets.only(
            top: 40,
          ),
          child: SingleChildScrollView(
            child: widget.innerHtmlContent != null
                ? Html(
                    data: text,
                    // "<p>This is a sample text with an image.</p><img class='_idGenObjectAttribute-1' src='https://via.placeholder.com/150' alt='' />",
                    extensions: [
                      //TagExtension(
                      //   tagsToExtend: {"img"},
                      //   builder: (extensionContext) {
                      //     final attrs = extensionContext.attributes;
                      //     final src = attrs['src'] ?? '';
                      //     //   Decode the base64 string to bytes
                      //     // final base64Str = src.split(',').last;
                      //     // final bytes = Base64Decoder().convert(base64Str);
                      //     final imagePath = imagePaths[src];
                      //     return GestureDetector(
                      //       onTap: () {
                      //         // Handle image tap if needed
                      //         print('Image tapped: $src');
                      //       },
                      //       child: Image.file(
                      //         imagePath,
                      //         errorBuilder: (context, error, stackTrace) {
                      //           return Text('Image not found');
                      //         },
                      //       ),
                      //     );
                      //   },
                      // ),
                      TagExtension(
                        tagsToExtend: {"img"},
                        builder: (imageContext) {
                          final url = imageContext.attributes['src']!
                              .replaceAll('../', '');
                          print(url);
                          // print(widget.document.Content!.Images![url]!.Content!);
                          print(widget.document.Content!.Images!
                              .containsKey(url));
                        
                          var content = Uint8List.fromList(
                              widget.document.Content!.Images![url]!.Content!);

                          return Image.memory(content);
                        },
                      ),
                    ],
                    style: {
                      "*": Style(
                          textAlign: TextAlign.justify,
                          fontSize: FontSize(widget.style.fontSize ?? 0),
                          fontFamily: widget.style.fontFamily,
                          color: widget.style.color),
                    },
                  )
                : Container(
                    //color: widget.backColor,
                    child: Text(
                      'not  html $text',
                      style: widget.style
                          .copyWith(backgroundColor: widget.backColor),
                      textAlign: TextAlign.justify,
                    ),
                  ),
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    print('FutureBuilder called');

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
            ) // CircularProgressIndicator(),
                );
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
                          initialIndex: widget.starterPageIndex,
                          // initialIndex: initialPageIndex,
                          children: pages,
                          backgroundColor: widget.backColor,
                          onPageFlip: (index) {
                            setState(() {
                              _currentPageIndex = index;
                            });
                            print('onPageFlip called');
                            if (_currentPageIndex == pages.length - 1) {
                              widget.onLastPage(index, pages.length);
                              print('onLastPage called');
                            }
                            //   didUpdateWidget(widget);
                            widget.onPageFlip(index, pages.length);

                            if (_currentPageIndex == pages.length - 5) {
                              // _loadMorePages(initialLoad: false);
                            }
                          },
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
                                '${_currentPageIndex + 1} از ${_pageTexts.length} /// از ${totalPages}',
                                //    '${_currentPageIndex + 1}  از ${totalPages}',
                                style: widget.style.copyWith(fontSize: 12)),
                            // Text(
                            //     '${_calculateCurrentPage()} از ${totalPageCount}',

                            //     // '${_currentPageIndex + 1 + (widget.chapterCount > 1 ? chapterPages.sublist(0, widget.chapterCount - 1).fold(0, (sum, len) => sum + len) : 0)} از ${totalPageCount}',
                            //     // '${_currentPageIndex + 1+ chapterPages.first}  از ${totalPages}',
                            //     style: widget.style.copyWith(fontSize: 12)
                            //),
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