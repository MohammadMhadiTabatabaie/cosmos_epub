// import 'package:cosmos_epub/PageFlip/page_flip_widget.dart';
// import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

// class PagingTextHandler {
//   final Function paginate;

//   PagingTextHandler(
//       {required this.paginate}); // will point to widget show method
// }

// class PagingWidget extends StatefulWidget {
//   final String textContent;
//   final String? innerHtmlContent;
//   final String chapterTitle;
//   final int totalChapters;
//   final int starterPageIndex;
//   final TextStyle style;
//   final Function handlerCallback;
//   final VoidCallback onTextTap;
//   final Function(int, int) onPageFlip;
//   final Function(int, int) onLastPage;
//   final Widget? lastWidget;
//   final Color backColor ;
//   const PagingWidget(
//     this.textContent,
//     this.innerHtmlContent, {
//     super.key,
//     this.style = const TextStyle(
//       color: Colors.black,
//       fontSize: 30,
//     ),
//     required this.handlerCallback(PagingTextHandler handler),
//     required this.onTextTap,
//     required this.onPageFlip,
//     required this.onLastPage,
//     this.starterPageIndex = 0,
//     required this.chapterTitle,
//     required this.totalChapters,
//     this.lastWidget,
//     required this.backColor
//   });

//   @override
//   _PagingWidgetState createState() => _PagingWidgetState();
// }

// class _PagingWidgetState extends State<PagingWidget> {
//   final List<String> _pageTexts = [];
//   List<Widget> pages = [];
//   int _currentPageIndex = 0;
//   Future<void> paginateFuture = Future.value(true);
//   late RenderBox _initializedRenderBox;
//   Widget? lastWidget;

//   final _pageKey = GlobalKey();
//   final _pageController = GlobalKey<PageFlipWidgetState>();
//   int _pagesLoaded = 0;
//   //static const int _pagesBatchSize = 10;
//   final int _pagesBatchSize = 10;
//   late double _pageHeight;
//   // int _pagesLoaded = 0;
//   @override
//   void initState() {
//     // rePaginate(initialLoad: true);
//     // // var handler = PagingTextHandler(paginate: rePaginate);
//     // var handler =
//     //     PagingTextHandler(paginate: () => rePaginate(initialLoad: false));
//     // widget.handlerCallback(handler); // callback call.
//     // super.initState();
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadMorePages(initialLoad: true);
//     });
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _pageHeight = MediaQuery.of(context).size.height -
//         34.0; // تنظیم ارتفاع صفحه با توجه به اندازه دستگاه
//   }

//   // @override
//   // void didUpdateWidget(covariant PagingWidget oldWidget) {
//   //   super.didUpdateWidget(oldWidget);
//   //   if (oldWidget.style != widget.style ||
//   //       oldWidget.textContent != widget.textContent) {
//   //     _reloadPages();
//   //   }
//   // }

//   void _loadMorePages({required bool initialLoad}) async {
//     final newPages = await _paginate(_pagesLoaded + _pagesBatchSize);
//     setState(() {
//       _pagesLoaded += _pagesBatchSize;
//       _pageTexts.addAll(newPages);
//       pages = _buildPageWidgets(_pageTexts);
//     });
//   }

//   // Future<void> _reloadPages() async {
//   //   final newPages = await _paginate(_pageTexts.length);
//   //   setState(() {
//   //     _pageTexts.clear();
//   //     _pageTexts.addAll(newPages);
//   //     pages = _buildPageWidgets(_pageTexts);
//   //   });
//   // }

//   rePaginate({required bool initialLoad}) {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       print('rePaginate');
//       if (!mounted) return;
//       setState(() {
//         // _initializedRenderBox = context.findRenderObject() as RenderBox;
//         // paginateFuture = _paginate();
//         _initializedRenderBox = context.findRenderObject() as RenderBox;
//         if (initialLoad) {
//           _pagesLoaded = _pagesBatchSize; // لود اولیه 10 صفحه
//         } else {
//           _pagesLoaded += _pagesBatchSize; // اضافه کردن صفحات جدید
//         }
//         paginateFuture = _paginate(_pagesLoaded);
//       });
//     });
//   }

//   int findLastHtmlTagIndex(String input) {
//     // Regular expression pattern to match HTML tags
//     RegExp regex = RegExp(r'<[^>]');

//     // Find all matches
//     Iterable<Match> matches = regex.allMatches(input);

//     // If matches are found
//     if (matches.isNotEmpty) {
//       // Return the end index of the last match
//       return matches.last.end;
//     } else {
//       // If no match is found, return -1
//       return -1;
//     }
//   }

//   Future<List<String>> _paginate(int pagesToLoad) async {
//     print('_pageTexts');
//     _pageTexts.clear();
//     List<String> newPages = [];

//     final textSpan = TextSpan(
//       text: widget.textContent,
//       style: widget.style,
//     );

//     final textPainter = TextPainter(
//       text: textSpan,
//       textDirection: TextDirection.rtl,
//     );

//     // Lay out the textPainter with a max width constraint
//     textPainter.layout(
//       minWidth: 0,
//       maxWidth: MediaQuery.of(context).size.width - 32.0,
//     );

//     final lines = textPainter.computeLineMetrics();
//     int currentLine = 0;
//     print('whileصص');
//     while (currentLine < lines.length && newPages.length < pagesToLoad) {
//       int start = textPainter
//           .getPositionForOffset(Offset(0, lines[currentLine].baseline))
//           .offset;
//       int endLine = currentLine;

//       while (endLine < lines.length &&
//           lines[endLine].baseline < lines[currentLine].baseline + _pageHeight) {
//         endLine++;
//       }
//       print('while');
//       int end = textPainter
//           .getPositionForOffset(Offset(0, lines[endLine - 1].baseline))
//           .offset;
//       final pageContent = widget.textContent.substring(start, end);
//       newPages.add(pageContent);
//       currentLine = endLine;
//     }
//     print('newPages');
//     return newPages;
//   }

//   List<Widget> _buildPageWidgets(List<String> pageTexts) {
//     print('_buildPageWidgets');

//     print(widget.style.backgroundColor);
//     print(widget.style.fontSize);
//     print(widget.style.color);
//     return pageTexts.map((text) {
//       return SingleChildScrollView(
//         child: GestureDetector(
//           onTap: widget.onTextTap,
//           child: Container(
//             // color: widget.style.backgroundColor,
//             height: _pageHeight,
//             padding: const EdgeInsets.all(16.0),
//             child:
//                 // widget.innerHtmlContent != null
//                 //     ? HtmlWidget(
//                 //         text,
//                 //         customStylesBuilder: (element) {
//                 //           return {
//                 //             'text-align': 'justify',
//                 //           };
//                 //         },
//                 //         onTapUrl: (String? s) async {
//                 //           if (s != null && s == "a") {
//                 //             if (s.contains("chapter")) {
//                 //               setState(() {
//                 //                 // Write logic for goto chapter
//                 //               });
//                 //             }
//                 //           }
//                 //           return true;
//                 //         },
//                 //         textStyle: widget.style,
//                 //       )
//                 //     :
//                 Text(
//               text,
//               style: TextStyle(
//                   fontSize: widget.style.fontSize ?? 16,
//                   fontFamily: widget.style.fontFamily,
//                   color: widget.style.color),
//               textAlign: TextAlign.justify,
//             ),
//           ),
//         ),
//       );
//     }).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     print('backcolor');
//     print(widget.backColor);
//     print(widget.style.backgroundColor);
//     return FutureBuilder<void>(
//         future: paginateFuture,
//         builder: (context, snapshot) {
//           switch (snapshot.connectionState) {
//             case ConnectionState.waiting:
//               {
//                 // Otherwise, display a loading indicator.
//                 return Center(
//                     child: CupertinoActivityIndicator(
//                   color: Theme.of(context).primaryColor,
//                   radius: 30.r,
//                 ));
//               }
//             default:
//               {
//                 return Stack(
//                   children: [
//                     Column(
//                       children: [
//                         Expanded(
//                           child: SizedBox.expand(
//                               key: _pageKey,
//                               child: PageFlipWidget(
//                                 isRightSwipe: true,
//                                 initialIndex: 0,
//                                 children: pages,
//                                 backgroundColor:
//                                     widget.backColor,
//                                 onPageFlip: (index) {
//                                   setState(() {
//                                     _currentPageIndex = index;
//                                   });
//                                   widget.onPageFlip(index, pages.length);
//                                   if (_currentPageIndex == pages.length - 1) {
//                                     widget.onLastPage(index, pages.length);
//                                   }
//                                   if (_currentPageIndex == 5) {
//                                     _loadMorePages(initialLoad: false);
//                                   }
//                                 },
//                               )),
//                         ),

//                         //  برای باتم هست که اسم فصل ها و جابه جای
//                         // Visibility(
//                         //   visible: false,
//                         //   child: Row(
//                         //     mainAxisAlignment: MainAxisAlignment.center,
//                         //     children: [
//                         //       IconButton(
//                         //         icon: Icon(Icons.first_page),
//                         //         onPressed: () {
//                         //           setState(() {
//                         //             _currentPageIndex = 0;
//                         //             _pageController.currentState
//                         //                 ?.goToPage(_currentPageIndex);
//                         //           });
//                         //         },
//                         //       ),
//                         //       IconButton(
//                         //         icon: Icon(Icons.navigate_before),
//                         //         onPressed: () {
//                         //           setState(() {
//                         //             if (_currentPageIndex > 0)
//                         //               _currentPageIndex--;
//                         //             _pageController.currentState
//                         //                 ?.goToPage(_currentPageIndex);
//                         //           });
//                         //         },
//                         //       ),
//                         //       Text(
//                         //         '${_currentPageIndex + 1}/${_pageTexts.length}',
//                         //       ),
//                         //       IconButton(
//                         //         icon: Icon(Icons.navigate_next),
//                         //         onPressed: () {
//                         //           setState(() {
//                         //             if (_currentPageIndex <
//                         //                 _pageTexts.length - 1)
//                         //               _currentPageIndex++;
//                         //             _pageController.currentState
//                         //                 ?.goToPage(_currentPageIndex);
//                         //           });
//                         //         },
//                         //       ),
//                         //       IconButton(
//                         //         icon: Icon(Icons.last_page),
//                         //         onPressed: () {
//                         //           setState(() {
//                         //             _currentPageIndex = _pageTexts.length - 1;
//                         //             _pageController.currentState
//                         //                 ?.goToPage(_currentPageIndex);
//                         //           });
//                         //         },
//                         //       ),
//                         //     ],
//                         //   ),
//                         // ),
//                       ],
//                     ),
//                   ],
//                 );
//               }
//           }
//         });
//   }
// }
//     /*  PageFlipWidget(
//                               key: _pageController,
//                               initialIndex: widget.starterPageIndex != 0
//                                   ? (pages.isNotEmpty &&
//                                           widget.starterPageIndex < pages.length
//                                       ? widget.starterPageIndex
//                                       : 0)
//                                   : widget.starterPageIndex,
//                               // onPageFlip: (pageIndex) {
//                               //   _currentPageIndex = pageIndex;
//                               //   widget.onPageFlip(pageIndex, pages.length);
//                               //   if (_currentPageIndex == pages.length - 1) {
//                               //     widget.onLastPage(pageIndex, pages.length);
//                               //   }
//                               // },
//                               onPageFlip: (pageIndex) {
//                                 _currentPageIndex = pageIndex;
//                                 widget.onPageFlip(pageIndex, pages.length);
//                                 if (_currentPageIndex == pages.length - 1) {
//                                   widget.onLastPage(pageIndex, pages.length);
//                                 }
//                                 if (_currentPageIndex == 5) {
//                                   rePaginate(
//                                       initialLoad: false); // لود 10 صفحه‌ی بعدی
//                                 }
//                               },
//                               backgroundColor:
//                                   widget.style.backgroundColor ?? Colors.white,
//                               lastPage: widget.lastWidget,
//                               isRightSwipe: true,
//                               children: pages,
//                             ),*/گ

import 'package:cosmos_epub/PageFlip/page_flip_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html_reborn/flutter_html_reborn.dart';

class PagingTextHandler {
  final Function paginate;

  PagingTextHandler({required this.paginate});
}

// class PagingWidget extends StatefulWidget {
//   final String textContent;
//   final String? innerHtmlContent;
//   final String chapterTitle;
//   final int totalChapters;
//   final int starterPageIndex;
//   final TextStyle style;
//   final Function handlerCallback;
//   final VoidCallback onTextTap;
//   final Function(int, int) onPageFlip;
//   final Function(int, int) onLastPage;
//   final Widget? lastWidget;
//   final Color backColor;

//   const PagingWidget(
//     this.textContent,
//     this.innerHtmlContent, {
//     super.key,
//     this.style = const TextStyle(
//       color: Colors.black,
//       fontSize: 30,
//     ),
//     required this.handlerCallback(PagingTextHandler handler),
//     required this.onTextTap,
//     required this.onPageFlip,
//     required this.onLastPage,
//     this.starterPageIndex = 0,
//     required this.chapterTitle,
//     required this.totalChapters,
//     this.lastWidget,
//     required this.backColor,
//   });

//   @override
//   _PagingWidgetState createState() => _PagingWidgetState();
// }

// class _PagingWidgetState extends State<PagingWidget> {
//   final List<String> _pageTexts = [];
//   List<Widget> pages = [];
//   int _currentPageIndex = 0;
//   Future<void> paginateFuture = Future.value(true);
//   late RenderBox _initializedRenderBox;
//   Widget? lastWidget;

//   final _pageKey = GlobalKey();
//   final _pageController = GlobalKey<PageFlipWidgetState>();
//   int _pagesLoaded = 0;
//   final int _pagesBatchSize = 10;
//   late double _pageHeight;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadMorePages(initialLoad: true);
//     });
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _pageHeight = MediaQuery.of(context).size.height - 34.0;
//   }

//   void _loadMorePages({required bool initialLoad}) async {
//     final newPages = await _paginate(_pagesLoaded + _pagesBatchSize);
//     setState(() {
//       _pagesLoaded += _pagesBatchSize;
//       _pageTexts.addAll(newPages);
//       pages = _buildPageWidgets(_pageTexts);
//     });
//   }

//   Future<List<String>> _paginate(int pagesToLoad) async {
//     List<String> newPages = [];

//     final textSpan = TextSpan(
//       text: widget.textContent,
//       style: widget.style,
//     );

//     final textPainter = TextPainter(
//       text: textSpan,
//       textDirection: TextDirection.rtl,
//     );

//     textPainter.layout(
//       minWidth: 0,
//       maxWidth: MediaQuery.of(context).size.width - 32.0,
//     );

//     final lines = textPainter.computeLineMetrics();
//     int currentLine = 0;
//     while (currentLine < lines.length && newPages.length < pagesToLoad) {
//       int start = textPainter
//           .getPositionForOffset(Offset(0, lines[currentLine].baseline))
//           .offset;
//       int endLine = currentLine;

//       while (endLine < lines.length &&
//           lines[endLine].baseline < lines[currentLine].baseline + _pageHeight) {
//         endLine++;
//       }

//       int end = textPainter
//           .getPositionForOffset(Offset(0, lines[endLine - 1].baseline))
//           .offset;
//       final pageContent = widget.textContent.substring(start, end);
//       newPages.add(pageContent);
//       currentLine = endLine;
//     }

//     return newPages;
//   }

//   List<Widget> _buildPageWidgets(List<String> pageTexts) {
//     print('_buildPageWidgets');
//     print(widget.style.background);
//     print(widget.style.color);
//     print(widget.style.fontSize);
//     print(widget.backColor);
//     return pageTexts.map((text) {
//       return SingleChildScrollView(
//         child: GestureDetector(
//           onTap: widget.onTextTap,
//           child: Container(
//             height: _pageHeight,
//             padding: const EdgeInsets.all(14.0),
//             child: Text(
//               text,
//               // style: TextStyle(
//               //   fontSize: widget.style.fontSize ?? 16,
//               //   fontFamily: widget.style.fontFamily,
//               //   color: widget.style.color,
//               // ),
//               style: TextStyle(
//                   backgroundColor: widget.backColor,
//                   color: widget.style.color,
//                   fontSize: widget.style.fontSize),

//               textAlign: TextAlign.justify,
//             ),
//           ),
//         ),
//       );
//     }).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     print('build');
//     print(widget.style.background);
//     print(widget.style.color);
//     // ساخت صفحات در هر بار فراخوانی build
//     if (_pageTexts.isNotEmpty) {
//       pages = _buildPageWidgets(_pageTexts);
//     }

//     return FutureBuilder<void>(
//       future: paginateFuture,
//       builder: (context, snapshot) {
//         switch (snapshot.connectionState) {
//           case ConnectionState.waiting:
//             return Center(
//               child: CircularProgressIndicator(),
//             );
//           default:
//             return Stack(
//               children: [
//                 Column(
//                   children: [
//                     Expanded(
//                       child: SizedBox.expand(
//                         key: _pageKey,
//                         child: PageFlipWidget(
//                           isRightSwipe: true,
//                           initialIndex: 0,
//                           children: pages,
//                           // backgroundColor: widget.backColor,
//                           onPageFlip: (index) {
//                             setState(() {
//                               _currentPageIndex = index;
//                             });
//                             widget.onPageFlip(index, pages.length);
//                             if (_currentPageIndex == pages.length - 1) {
//                               widget.onLastPage(index, pages.length);
//                             }
//                             if (_currentPageIndex == pages.length - 5) {
//                               _loadMorePages(initialLoad: false);
//                             }
//                           },
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             );
//         }
//       },
//     );
//   }
// }

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
  // final Function(int, int) onLastPage;
  final Widget? lastWidget;
  final Color backColor;

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
    // required this.onLastPage,
    this.starterPageIndex = 0,
    required this.chapterTitle,
    required this.totalChapters,
    this.lastWidget,
    required this.backColor,
  });

  @override
  _PagingWidgetState createState() => _PagingWidgetState();
}

class _PagingWidgetState extends State<PagingWidget> {
  final List<String> _pageTexts = [];
  List<Widget> pages = [];
  int _currentPageIndex = 0;
  Future<void> paginateFuture = Future.value(true);
  late double _pageHeight;
  late double _pagewidth;
  late TextPainter textPainter;
  int totalPages = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _pageHeight = MediaQuery.of(context).size.height;
      _pagewidth = MediaQuery.of(context).size.width - 20.0;
      textPainter = TextPainter(
        textDirection: TextDirection.rtl,
      );
      totalPages = await _calculateTotalPages();

      setstate() {}
      _loadMorePages(initialLoad: true);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void _loadMorePages({required bool initialLoad}) async {
    final newPages = await _paginate(_pageTexts.length + 10);
    setState(() {
      _pageTexts.addAll(newPages);
      pages = _buildPageWidgets(_pageTexts);
    });
  }

  @override
  void didUpdateWidget(covariant PagingWidget oldWidget)  {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.style != widget.style 
   // ||
    //    oldWidget.textContent != widget.textContent
        ) {
      _loadPages(initialLoad: true);
    }
    // if (oldWidget.style.fontSize != widget.style.fontSize) {
    //   totalPages =  _calculateTotalPages();
    // }
  }

  void _loadPages({required bool initialLoad}) async {
    final newPages = await _paginate(_pageTexts.length + 1);
    print('_loadPages');
    setState(() {
      _pageTexts.addAll(newPages);

      pages = _buildPageWidgets(_pageTexts);
    });
  }

  Future<int> _calculateTotalPages() async {
    _pageTexts.clear();
    List<String> newPages = [];
    print('_calculateTotalPages start');
    final textSpan = TextSpan(
      text: widget.textContent,
      style: widget.style,
    );

    textPainter.text = textSpan;
    print('_calculateTotalPages textPainter');
    textPainter.layout(
      minWidth: 0,
      maxWidth: MediaQuery.of(context).size.width - 20.0,
    );
    print('_calculateTotalPages mid');
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
          .getPositionForOffset(Offset(0, lines[endLine - 1].baseline))
          .offset;
      final pageContent = widget.textContent.substring(start, end);
      newPages.add(pageContent);
      currentLine = endLine;
    }
    print('_calculateTotalPages end');
    return newPages.length;
  }

  Future<List<String>> _paginate(int pagesToLoad) async {
    _pageTexts.clear();
    List<String> newPages = [];
    print('_paginate start');
    final textSpan = TextSpan(
      text: widget.textContent,
      style: widget.style,
    );
    textPainter.text = textSpan;
    // final textPainter = TextPainter(
    //   text: textSpan,
    //   textDirection: TextDirection.rtl,
    // );

    print('textPainter');
    textPainter.layout(
      minWidth: 0,
      maxWidth: MediaQuery.of(context).size.width - 40.0,
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
      while (endLine < lines.length &&
          currentHeight + lines[endLine].height <= _pageHeight  ) {
        currentHeight += lines[endLine].height;
        endLine++;
      }
      int end = textPainter
          .getPositionForOffset(Offset(0, lines[endLine - 1].baseline))
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

  List<Widget> _buildPageWidgets(List<String> pageTexts) {
    print('_buildPageWidgets called');
    print('object $_pageHeight');
    return pageTexts.map((text) {
    
      return GestureDetector(
        onTap: widget.onTextTap,
        child: Container(
          //color: Colors.red[30],
          //  height: _pageHeight-100,
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.only(top: 0, bottom: 0),
          child: widget.innerHtmlContent != null
              ? Html(
                  data: text,
                  style: {
                    "*": Style(
                        textAlign: TextAlign.justify,
                        fontSize: FontSize(widget.style.fontSize ?? 0),
                        fontFamily: widget.style.fontFamily,
                        color: widget.style.color),
                  },
                )
              : SingleChildScrollView(
                child: Container(
                    //    height: _pageHeight /2,
                    color: widget.backColor,
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Text(
                        text,
                        style: widget.style
                            .copyWith(backgroundColor: widget.backColor),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ),
              ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    print('build called');
    return FutureBuilder<void>(
      future: paginateFuture,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(
              child: CircularProgressIndicator(),
            );
          default:
            return Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: SizedBox(
                        //    color: Colors.green,
                        // height: _pageHeight,
                        child: PageFlipWidget(
                          isRightSwipe: true,
                          initialIndex: widget.starterPageIndex,
                          children: pages,
                          // backgroundColor: widget.backColor,
                          onPageFlip: (index) {
                            setState(() {
                              _currentPageIndex = index;
                            });
                            print('onPageFlip called');

                            //   didUpdateWidget(widget);
                            widget.onPageFlip(index, pages.length);

                            // if (_currentPageIndex == pages.length - 1) {
                            // //  widget.onLastPage(index, pages.length);
                            // }
                            if (_currentPageIndex == pages.length - 5) {
                              _loadMorePages(initialLoad: false);
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
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              // topLeft: Radius.circular(10),
                              // bottomLeft: Radius.circular(10)
                              ),
                     //     color: widget.backColor
                       color: Colors.black   ),
                      //   height: 40,
                      width: MediaQuery.of(context).size.width,
                      child: Center(
                          child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          //  '${_currentPageIndex + 1} از ${_pageTexts.length} /// از ${totalPages}',
                                '${_currentPageIndex + 1}  از ${totalPages}',
                            style: widget.style.copyWith(fontSize: 14)),
                      )),
                    )),
                // Visibility(
                //   visible: false,
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: [
                //       IconButton(
                //         icon: Icon(Icons.first_page),
                //         onPressed: () {},
                //       ),
                //       IconButton(
                //         icon: Icon(Icons.navigate_before),
                //         onPressed: () {},
                //       ),
                //       Text(
                //         '${_currentPageIndex + 1}/${_pageTexts.length}',
                //       ),
                //       IconButton(
                //         icon: Icon(Icons.navigate_next),
                //         onPressed: () {},
                //       ),
                //       IconButton(
                //         icon: Icon(Icons.last_page),
                //         onPressed: () {},
                //       ),
                //     ],
                //   ),
                // ),
              ],
            );
        }
      },
    );
  }
}
