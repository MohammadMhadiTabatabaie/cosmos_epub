import 'package:cosmos_epub/PageFlip/page_flip_widget.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

class PagingTextHandler {
  final Function paginate;

  PagingTextHandler(
      {required this.paginate}); // will point to widget show method
}

class PagingWidget extends StatefulWidget {
  final String textContent;
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

  const PagingWidget(
    this.textContent,
    this.innerHtmlContent, {
    super.key,
    this.style = const TextStyle(
      color: Colors.black,
      fontSize: 30,
    ),
    required this.handlerCallback(PagingTextHandler handler),
    required this.onTextTap,
    required this.onPageFlip,
    required this.onLastPage,
    this.starterPageIndex = 0,
    required this.chapterTitle,
    required this.totalChapters,
    this.lastWidget,
  });

  @override
  _PagingWidgetState createState() => _PagingWidgetState();
}

class _PagingWidgetState extends State<PagingWidget> {
  final List<String> _pageTexts = [];
  List<Widget> pages = [];
  int _currentPageIndex = 0;
  Future<void> paginateFuture = Future.value(true);
  late RenderBox _initializedRenderBox;
  Widget? lastWidget;

  final _pageKey = GlobalKey();
  final _pageController = GlobalKey<PageFlipWidgetState>();
  int _pagesLoaded = 0;
  //static const int _pagesBatchSize = 10;
  final int _pagesBatchSize = 10;
  late double _pageHeight;
  // int _pagesLoaded = 0;
  @override
  void initState() {
    // rePaginate(initialLoad: true);
    // // var handler = PagingTextHandler(paginate: rePaginate);
    // var handler =
    //     PagingTextHandler(paginate: () => rePaginate(initialLoad: false));
    // widget.handlerCallback(handler); // callback call.
    // super.initState();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMorePages(initialLoad: true);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pageHeight = MediaQuery.of(context).size.height -
        34.0; // تنظیم ارتفاع صفحه با توجه به اندازه دستگاه
  }

  @override
  void didUpdateWidget(covariant PagingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.style != widget.style ||
        oldWidget.textContent != widget.textContent) {
      _reloadPages();
    }
  }

  void _loadMorePages({required bool initialLoad}) async {
    final newPages = await _paginate(_pagesLoaded + _pagesBatchSize);
    setState(() {
      _pagesLoaded += _pagesBatchSize;
      _pageTexts.addAll(newPages);
      pages = _buildPageWidgets(_pageTexts);
    });
  }

  Future<void> _reloadPages() async {
    final newPages = await _paginate(_pageTexts.length);
    setState(() {
      _pageTexts.clear();
      _pageTexts.addAll(newPages);
      pages = _buildPageWidgets(_pageTexts);
    });
  }

  rePaginate({required bool initialLoad}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('rePaginate');
      if (!mounted) return;
      setState(() {
        // _initializedRenderBox = context.findRenderObject() as RenderBox;
        // paginateFuture = _paginate();
        _initializedRenderBox = context.findRenderObject() as RenderBox;
        if (initialLoad) {
          _pagesLoaded = _pagesBatchSize; // لود اولیه 10 صفحه
        } else {
          _pagesLoaded += _pagesBatchSize; // اضافه کردن صفحات جدید
        }
        paginateFuture = _paginate(_pagesLoaded);
      });
    });
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

/*
  Future<void> _paginate(int pagesToLoad) async {
    print('_paginate');
    final pageSize = _initializedRenderBox.size;

    _pageTexts.clear();

    final textSpan = TextSpan(
      text: widget.textContent,
      style: widget.style,
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.rtl,
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
      if (_pageTexts.length >= pagesToLoad) {
        return; // متوقف کردن لود بیشتر اگر به تعداد صفحات مورد نظر رسیدیم
      }
      // Current line overflow page
      if (currentPageBottom < bottom) {
        currentPageEndIndex =
            textPainter.getPositionForOffset(Offset(left, top - 100.h)).offset;

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

        var innerHtml = widget.innerHtmlContent;

        currentPageStartIndex = currentPageEndIndex;
        currentPageBottom =
            top + pageSize.height - (innerHtml != null ? 200.h : 100.h);
      }
    }));

    final lastPageText = widget.textContent.substring(currentPageStartIndex);
    _pageTexts.add(lastPageText);

    // Assuming each operation within the loop is asynchronous and returns a Future
    List<Future<Widget>> futures = _pageTexts.map((text) async {
      final _scrollController = ScrollController();
      return InkWell(
        onTap: widget.onTextTap,
        child: Container(
          // color: widget.style.backgroundColor,
          child: FadingEdgeScrollView.fromSingleChildScrollView(
            gradientFractionOnEnd: 0.2,
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: 40.h, top: 60.h, left: 16.w, right: 16.w),
                child: widget.innerHtmlContent != null
                    ? HtmlWidget(
                        text,
                        customStylesBuilder: (element) {
                          return {
                            'text-align': 'justify',
                          };
                        },
                        onTapUrl: (String? s) async {
                          if (s != null && s == "a") {
                            if (s.contains("chapter")) {
                              setState(() {
                                ///Write logic for goto chapter
                                // var s1 = s.split("-0");
                                // String break1 =
                                //     s1.toList().last.split(".xhtml").first;
                                // int number = int.parse(break1);
                              });
                            }
                          }
                          return true;
                        },
                        textStyle: widget.style,
                      )
                    : Text(
                        text,
                        textAlign: TextAlign.justify,
                        // Assuming _isPaging and _currentIndex are handled elsewhere
                        style: widget.style,
                        overflow: TextOverflow.visible,
                      ),
              ),
            ),
          ),
        ),
      );
    }).toList();

    pages = await Future.wait(futures);
  }
*/
  Future<List<String>> _paginate(int pagesToLoad) async {
    //   final page_Size = _initializedRenderBox.size;
    //   _pageTexts.clear();
    //   // محاسبه اندازه صفحه
    //   final textPainter = TextPainter(
    //     textDirection: TextDirection.rtl,
    //     text: TextSpan(
    //       text: widget.textContent,
    //       style: widget.style,
    //     ),
    //   );
    //   textPainter.layout(
    //     minWidth: 0,
    //     maxWidth: page_Size.width,
    //   );
    //   final textSpan = TextSpan(
    //     text: widget.textContent,
    //     style: widget.style,
    //   );
    //   double currentPageBottom = page_Size.height;
    //   int currentPageStartIndex = 0;
    //   int currentPageEndIndex = 0;
    //   // final left = line.left;
    //   // final top = line.baseline - line.ascent;
    //   // final bottom = line.baseline + line.descent;
    //   var innerHtml = widget.innerHtmlContent;

    //   currentPageStartIndex = currentPageEndIndex;
    //   currentPageBottom =
    //       //top +
    //        page_Size.height - (innerHtml != null ? 200.h : 100.h);
    //   // final textHeight = textPainter.size.height;
    //   // final pageHeight = MediaQuery.of(context).size.height;
    //   // final linesPerPage =
    //   //     (pageHeight / textHeight * textPainter.computeLineMetrics().length)
    //   //         .ceil();

    //   //final textHeight = textPainter.size.height;
    //   // final linesPerPage = (_pageHeight / textHeight * textPainter.computeLineMetrics().length).ceil();
    //   // محاسبه صفحات بر اساس تعداد کاراکترها یا اندازه متن و صفحه
    //   // در اینجا فرض می‌کنیم متن را به قسمت‌های ۱۰ صفحه‌ای تقسیم می‌کنیم
    //   final textLength = widget.textContent.length;
    //   final pageSize = (textLength / _pagesBatchSize).ceil();
    //   List<String> newPages = [];
    //   for (int i = 0; i < pagesToLoad && i < _pagesBatchSize; i++) {
    //     final start = i * pageSize;
    //     final end = (i + 1) * pageSize;
    //     final pageContent = widget.textContent
    //         .substring(start.toInt(), end.toInt().clamp(0, textLength));
    //     newPages.add(pageContent);
    //   }
    //   return newPages;
    // }
    _pageTexts.clear();
    List<String> newPages = [];

    final textSpan = TextSpan(
      text: widget.textContent,
      style: widget.style,
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.rtl,
    );

    // Lay out the textPainter with a max width constraint
    textPainter.layout(
      minWidth: 0,
      maxWidth: MediaQuery.of(context).size.width - 32.0,
    );

    final lines = textPainter.computeLineMetrics();
    int currentLine = 0;
    while (currentLine < lines.length && newPages.length < pagesToLoad) {
      int start = textPainter
          .getPositionForOffset(Offset(0, lines[currentLine].baseline))
          .offset;
      int endLine = currentLine;

      while (endLine < lines.length &&
          lines[endLine].baseline < lines[currentLine].baseline + _pageHeight) {
        endLine++;
      }

      int end = textPainter
          .getPositionForOffset(Offset(0, lines[endLine - 1].baseline))
          .offset;
      final pageContent = widget.textContent.substring(start, end);
      newPages.add(pageContent);
      currentLine = endLine;
    }

    return newPages;
  }

  List<Widget> _buildPageWidgets(List<String> pageTexts) {
    print('widget.style.backgroundColor');

    print(widget.style.backgroundColor);
    print(widget.style.fontSize);
    print(widget.style.color);
    return pageTexts.map((text) {
      return SingleChildScrollView(
        child: GestureDetector(
          onTap: widget.onTextTap,
          child: Container(
            color: widget.style.backgroundColor,
            height: _pageHeight,
            padding: const EdgeInsets.all(16.0),
            child:
                // widget.innerHtmlContent != null
                //     ? HtmlWidget(
                //         text,
                //         customStylesBuilder: (element) {
                //           return {
                //             'text-align': 'justify',
                //           };
                //         },
                //         onTapUrl: (String? s) async {
                //           if (s != null && s == "a") {
                //             if (s.contains("chapter")) {
                //               setState(() {
                //                 // Write logic for goto chapter
                //               });
                //             }
                //           }
                //           return true;
                //         },
                //         textStyle: widget.style,
                //       )
                //     :
                Text(
              text,
              style: TextStyle(
                  fontSize: widget.style.fontSize ?? 0,
                  fontFamily: widget.style.fontFamily,
                  color: widget.style.color),
              textAlign: TextAlign.justify,
            ),
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.style.backgroundColor);
    return FutureBuilder<void>(
        future: paginateFuture,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              {
                // Otherwise, display a loading indicator.
                return Center(
                    child: CupertinoActivityIndicator(
                  color: Theme.of(context).primaryColor,
                  radius: 30.r,
                ));
              }
            default:
              {
                return Stack(
                  children: [
                    Column(
                      children: [
                        Expanded(
                          child: SizedBox.expand(
                              key: _pageKey,
                              child: PageFlipWidget(
                                isRightSwipe: true,
                                initialIndex: 0,
                                children: pages,
                                backgroundColor:
                                    widget.style.backgroundColor ?? Colors.red,
                                onPageFlip: (index) {
                                  setState(() {
                                    _currentPageIndex = index;
                                  });
                                  widget.onPageFlip(index, pages.length);
                                  if (_currentPageIndex == pages.length - 1) {
                                    widget.onLastPage(index, pages.length);
                                  }
                                  if (_currentPageIndex == 5) {
                                    _loadMorePages(initialLoad: false);
                                  }
                                },
                              )),
                        ),

                        //  برای باتم هست که اسم فصل ها و جابه جای
                        // Visibility(
                        //   visible: false,
                        //   child: Row(
                        //     mainAxisAlignment: MainAxisAlignment.center,
                        //     children: [
                        //       IconButton(
                        //         icon: Icon(Icons.first_page),
                        //         onPressed: () {
                        //           setState(() {
                        //             _currentPageIndex = 0;
                        //             _pageController.currentState
                        //                 ?.goToPage(_currentPageIndex);
                        //           });
                        //         },
                        //       ),
                        //       IconButton(
                        //         icon: Icon(Icons.navigate_before),
                        //         onPressed: () {
                        //           setState(() {
                        //             if (_currentPageIndex > 0)
                        //               _currentPageIndex--;
                        //             _pageController.currentState
                        //                 ?.goToPage(_currentPageIndex);
                        //           });
                        //         },
                        //       ),
                        //       Text(
                        //         '${_currentPageIndex + 1}/${_pageTexts.length}',
                        //       ),
                        //       IconButton(
                        //         icon: Icon(Icons.navigate_next),
                        //         onPressed: () {
                        //           setState(() {
                        //             if (_currentPageIndex <
                        //                 _pageTexts.length - 1)
                        //               _currentPageIndex++;
                        //             _pageController.currentState
                        //                 ?.goToPage(_currentPageIndex);
                        //           });
                        //         },
                        //       ),
                        //       IconButton(
                        //         icon: Icon(Icons.last_page),
                        //         onPressed: () {
                        //           setState(() {
                        //             _currentPageIndex = _pageTexts.length - 1;
                        //             _pageController.currentState
                        //                 ?.goToPage(_currentPageIndex);
                        //           });
                        //         },
                        //       ),
                        //     ],
                        //   ),
                        // ),
                      ],
                    ),
                  ],
                );
              }
          }
        });
  }
}
    /*  PageFlipWidget(
                              key: _pageController,
                              initialIndex: widget.starterPageIndex != 0
                                  ? (pages.isNotEmpty &&
                                          widget.starterPageIndex < pages.length
                                      ? widget.starterPageIndex
                                      : 0)
                                  : widget.starterPageIndex,
                              // onPageFlip: (pageIndex) {
                              //   _currentPageIndex = pageIndex;
                              //   widget.onPageFlip(pageIndex, pages.length);
                              //   if (_currentPageIndex == pages.length - 1) {
                              //     widget.onLastPage(pageIndex, pages.length);
                              //   }
                              // },
                              onPageFlip: (pageIndex) {
                                _currentPageIndex = pageIndex;
                                widget.onPageFlip(pageIndex, pages.length);
                                if (_currentPageIndex == pages.length - 1) {
                                  widget.onLastPage(pageIndex, pages.length);
                                }
                                if (_currentPageIndex == 5) {
                                  rePaginate(
                                      initialLoad: false); // لود 10 صفحه‌ی بعدی
                                }
                              },
                              backgroundColor:
                                  widget.style.backgroundColor ?? Colors.white,
                              lastPage: widget.lastWidget,
                              isRightSwipe: true,
                              children: pages,
                            ),*/