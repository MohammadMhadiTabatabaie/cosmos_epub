// ignore_for_file: avoid_print

import 'package:epubx/epubx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_storage/get_storage.dart';
import 'package:screen_brightness/screen_brightness.dart';

import 'Component/constants.dart';
import 'Component/circle_button.dart';
import 'Component/theme_colors.dart';
import 'Helpers/chapters.dart';
import 'Helpers/custom_toast.dart';
import 'Helpers/pagination.dart';
import 'Helpers/progress_singleton.dart';
import 'Model/chapter_model.dart';
import 'package:html/parser.dart' as html_parser;

late BookProgressSingleton bookProgress;

// const double DESIGN_WIDTH = 375;
// const double DESIGN_HEIGHT = 812;

String selectedFont = 'BNazanin';
List<String> fontNames = [
  "BNazanin",
  "IRANSans",
  "Segoe",
  "Alegreya",
  "Amazon Ember",
  "Atkinson Hyperlegible",
  "Bitter Pro",
  "Bookerly",
  "Droid Sans",
  "EB Garamond",
  "Gentium Book Plus",
  "Halant",
  "IBM Plex Sans",
  "LinLibertine",
  "Literata",
  "Lora",
  "Ubuntu"
];

Color backColor = Colors.white;
Color fontColor = Colors.black;
int staticThemeId = 3;

// ignore: must_be_immutable
class ShowEpub extends StatefulWidget {
  EpubBook epubBook;
  bool shouldOpenDrawer;
  int starterChapter;
  final String bookId;
  final String chapterListTitle;

  final Function(int currentPage, int totalPages)? onPageFlip;
  final Function(int lastPageIndex)? onLastPage;
  final Color accentColor;
  bool isloading = false;

  ShowEpub({
    super.key,
    required this.epubBook,
    required this.accentColor,
    this.starterChapter = 0,
    this.shouldOpenDrawer = false,
    required this.bookId,
    required this.chapterListTitle,
    this.onPageFlip,
    this.onLastPage,
  });

  @override
  State<StatefulWidget> createState() => ShowEpubState();
}

class ShowEpubState extends State<ShowEpub> {
  String htmlContent = '';
  String? innerHtmlContent;
  String textContent = '';
  String textContentnumber = '';
  final List<String> pageText_show = [];
  bool showBrightnessWidget = false;
  final controller = ScrollController();
  Future<void> loadChapterFuture = Future.value(true);
  List<LocalChapterModel> chaptersList = [];
  double _fontSizeProgress = 17.0;
  double _fontSize = 17.0;

  late EpubBook epubBook;
  late String bookId;
  String bookTitle = '';
  String chapterTitle = '';
  double brightnessLevel = 0.5;

  // late Map<String, String> allFonts;

  // Initialize with the first font in the list
  late String selectedTextStyle;
  final List<String> _pageTexts = [];
  bool showHeader = true;
  bool isLastPage = false;
  int lastSwipe = 0;
  int prevSwipe = 0;
  bool showPrevious = false;
  bool showNext = false;
  List<String> pagesContent = [];
  // var dropDownFontItems;
  List<int> chapterPages = [];
  List<int> titlePageNumbers = [];
  GetStorage gs = GetStorage();

  PagingTextHandler controllerPaging = PagingTextHandler(paginate: () {});
  late TextPainter textPainter;
  late double maxWidth;
  late double maxHeight;

  @override
  void initState() {
    print('textPainter');
    super.initState();
    // textPainter = TextPainter(
    //   textDirection: TextDirection.rtl,
    // );
    // maxHeight = MediaQuery.of(context).size.height - 50;
    // maxWidth = MediaQuery.of(context).size.width - 20.0;

    // setState(() {
    // maxHeight = MediaQuery.of(context).size.height - 50;
    // maxWidth = MediaQuery.of(context).size.width - 20.0;
    // textPainter = TextPainter(
    //   textDirection: TextDirection.rtl,
    // );
    // });

    loadThemeSettings();

    bookId = widget.bookId;
    epubBook = widget.epubBook;
    // allFonts = GoogleFonts.asMap().cast<String, String>();
    // fontNames = allFonts.keys.toList();
    //selectedTextStyle = GoogleFonts.getFont(selectedFont).fontFamily!;
    //     selectedTextStyle =
    // fontNames.where((element) => element == selectedFont).first;
    selectedTextStyle = fontNames.firstWhere(
      (element) => element == selectedFont,
      orElse: () => 'BNazanin',
    );

    textPainter = TextPainter(
      textDirection: TextDirection.rtl,
    );
    //  maxWidth = MediaQuery.sizeOf(context).width;
    //    maxHeight = MediaQuery.sizeOf(context).height;
//didChangeDependencies();
    // getTitleFromXhtml();

    // reLoadChapter(init: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // استفاده از MediaQuery در didChangeDependencies
    maxHeight = MediaQuery.sizeOf(context).height - 50;
    maxWidth = MediaQuery.sizeOf(context).width - 20.0;

    // پس از مقداردهی به maxWidth، maxHeight و textPainter، می‌توانید متدهای دیگر را فراخوانی کنید
    getTitleFromXhtml();
    reLoadChapter(init: true);
  }

  loadThemeSettings() {
    selectedFont = gs.read(libFont) ?? selectedFont;
    var themeId = gs.read(libTheme) ?? staticThemeId;
    updateTheme(themeId, isInit: true);
    _fontSize = gs.read(libFontSize) ?? _fontSize;
    _fontSizeProgress = _fontSize;
  }

  getTitleFromXhtml() {
    // Listener for slider
    // controller.addListener(() {
    //   if (controller.position.userScrollDirection == ScrollDirection.forward &&
    //       showHeader == false) {
    //     showHeader = true;
    //     update();
    //   } else if (controller.position.userScrollDirection ==
    //           ScrollDirection.reverse &&
    //       showHeader) {
    //     showHeader = false;
    //     update();
    //   }
    // });

    if (epubBook.Title != null) {
      bookTitle = epubBook.Title!;
      updateUI();
    }
  }

  reLoadChapter({bool init = false, int index = -0, int page = 0}) async {
    print('reLoadChapter $index');
    int currentIndex =
        bookProgress.getBookProgress(bookId).currentChapterIndex ?? 0;
    var pagess = bookProgress.getBookProgress(bookId).currentPageIndex ?? 0;
    if (init) {
      setState(() {
        loadChapterFuture = loadChapter(
            index: init
                ? -1
                : index == -1
                    ? currentIndex
                    : index);
      });
    } else {
      setState(() {
        loadChapterFuture = bookProgress.setCurrentPageIndex(bookId, pagess);
      });
    }
  }

  loadChapter({int index = -1}) async {
    chaptersList = [];

    await Future.wait(epubBook.Chapters!.map((EpubChapter chapter) async {
      String? chapterTitle = chapter.Title;
      List<LocalChapterModel> subChapters = [];
      for (var element in chapter.SubChapters!) {
        subChapters.add(
            LocalChapterModel(chapter: element.Title!, isSubChapter: true));
      }

      chaptersList.add(LocalChapterModel(
          chapter: chapterTitle ?? '...', isSubChapter: false));

      chaptersList += subChapters;
    }));
    //Choose initial chapter
    if (widget.starterChapter >= 0 &&
        widget.starterChapter < chaptersList.length) {
      setupNavButtons();
      await updateContentAccordingChapter(
          index == -1 ? widget.starterChapter : index);
    } else {
      setupNavButtons();
      await updateContentAccordingChapter(0);
      CustomToast.showToast(
          "Invalid chapter number. Range [0-${chaptersList.length}]");
    }
  }

  updateContentAccordingChapter(int chapterIndex) async {
    ///Set current chapter index
    await bookProgress.setCurrentChapterIndex(bookId, chapterIndex, 0);
    String fullContent = '';

    await Future.wait(epubBook.Chapters!.map((EpubChapter chapter) async {
      String chapterContent = chapter.HtmlContent!;

      // اضافه کردن محتوای زیرفصل‌ها
      List<EpubChapter>? subChapters = chapter.SubChapters;
      if (subChapters != null && subChapters.isNotEmpty) {
        for (var subChapter in subChapters) {
          chapterContent += subChapter.HtmlContent!;
        }
      }

      fullContent += chapterContent;

      //  var textchapter = parse(chapterContent).documentElement!.text;
      var pageCount = await _calculateTotalPages(fullContent);

      print('Chapter "${chapterTitle.characters}" has $pageCount pages.');
      chapterPages.add(pageCount);
    }));
    //textContentnumber = parse(fullContent).documentElement!.text;

    if (isHTML(fullContent)) {
      innerHtmlContent = fullContent;
    } else {
      //  textContentnumber = textContentnumber.replaceAll('Unknown', '').trim();
    }

    controllerPaging.paginate();
    setupNavButtons();
  }

  bool isHTML(String str) {
    final RegExp htmlRegExp =
        RegExp('<[^>]*>', multiLine: true, caseSensitive: false);
    return htmlRegExp.hasMatch(str);
  }

  setupNavButtons() {
    int index = bookProgress.getBookProgress(bookId).currentChapterIndex ?? 0;

    setState(() {
      if (index == 0) {
        showPrevious = false;
      } else {
        showPrevious = true;
      }
      if (index == chaptersList.length - 1) {
        showNext = false;
      } else {
        showNext = true;
      }
    });
  }

  Future<bool> backPress() async {
    print('pop');
    //  Navigator.of(context).pop();
    return true;
  }

  void setBrightness(double brightness) async {
    await ScreenBrightness().setScreenBrightness(brightness);
    await Future.delayed(const Duration(seconds: 5));
    showBrightnessWidget = false;
    updateUI();
  }

  updateFontSettings() {
    return showModalBottomSheet(
        context: context,
        elevation: 10,
        clipBehavior: Clip.antiAlias,
        backgroundColor: backColor,
        enableDrag: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r))),
        builder: (context) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
                child: StatefulBuilder(
                    builder: (BuildContext context, setState) => SizedBox(
                          // height: 170.h,
                          height: 120.h,
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                margin: EdgeInsets.symmetric(
                                    horizontal: 10.h, vertical: 8.w),
                                height: 45.h,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'رنگ پس زمینه ',
                                      style: TextStyle(
                                          color: fontColor,
                                          fontSize: 18,
                                          fontFamily: 'IRANSans',
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        print('loading on ');
                                        updateTheme(1);
                                      },
                                      child: CircleButton(
                                        backColor: cVioletishColor,
                                        fontColor: Colors.white,
                                        id: 1,
                                        accentColor: widget.accentColor,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        updateTheme(2);
                                      },
                                      child: CircleButton(
                                        backColor: cBluishColor,
                                        fontColor: Colors.black,
                                        id: 2,
                                        accentColor: widget.accentColor,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        updateTheme(3);
                                      },
                                      child: CircleButton(
                                        id: 3,
                                        backColor: Colors.white,
                                        fontColor: Colors.black,
                                        accentColor: widget.accentColor,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        updateTheme(4);
                                      },
                                      child: CircleButton(
                                        id: 4,
                                        backColor: Colors.black,
                                        fontColor: Colors.white,
                                        accentColor: widget.accentColor,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        updateTheme(5);
                                      },
                                      child: CircleButton(
                                        id: 5,
                                        backColor: cPinkishColor,
                                        fontColor: Colors.black,
                                        accentColor: widget.accentColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(
                                thickness: 1.h,
                                height: 0,
                                indent: 0,
                                color: Colors.grey,
                              ),
                              Expanded(
                                child: Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20.h),
                                    child: Column(
                                      children: [
                                        //                                       StatefulBuilder(
                                        //                                         builder: (BuildContext context,
                                        //                                                 StateSetter setState) =>
                                        //                                             Theme(
                                        //                                           data: Theme.of(context).copyWith(
                                        //                                               canvasColor: backColor),
                                        //                                           child: DropdownButtonHideUnderline(
                                        //                                             child: DropdownButton<String>(
                                        //                                                 value: selectedFont,
                                        //                                                 isExpanded: true,
                                        //                                                 menuMaxHeight: 400.h,
                                        //                                                 onChanged: (newValue) {
                                        //                                                   selectedFont =
                                        //                                                       newValue ?? 'IRANSans';

                                        //                                                   selectedTextStyle = fontNames
                                        //                                                       .where((element) =>
                                        //                                                           element ==
                                        //                                                           selectedFont)
                                        //                                                       .first;
                                        // //                                                   selectedTextStyle = fontNames.firstWhere(
                                        // // (element) => element == selectedFont,
                                        // // orElse: () => 'IRANSans', );
                                        //                                                   gs.write(
                                        //                                                       libFont, selectedFont);

                                        //                                                   ///For updating inside
                                        //                                                   setState(() {});
                                        //                                                   controllerPaging.paginate();
                                        //                                                   updateUI();
                                        //                                                 },
                                        //                                                 items: fontNames.map<
                                        //                                                         DropdownMenuItem<
                                        //                                                             String>>(
                                        //                                                     (String font) {
                                        //                                                   return DropdownMenuItem<
                                        //                                                       String>(
                                        //                                                     value: font,
                                        //                                                     child: Text(
                                        //                                                       font,
                                        //                                                       style: TextStyle(
                                        //                                                           color:
                                        //                                                               selectedFont ==
                                        //                                                                       font
                                        //                                                                   ? widget
                                        //                                                                       .accentColor
                                        //                                                                   : fontColor,
                                        //                                                           package:
                                        //                                                               'cosmos_epub',
                                        //                                                           fontSize:
                                        //                                                               context.isTablet
                                        //                                                                   ? 10.sp
                                        //                                                                   : 15.sp,
                                        //                                                           fontWeight:
                                        //                                                               selectedFont ==
                                        //                                                                       font
                                        //                                                                   ? FontWeight
                                        //                                                                       .bold
                                        //                                                                   : FontWeight
                                        //                                                                       .normal,
                                        //                                                           fontFamily: font),
                                        //                                                     ),
                                        //                                                   );
                                        //                                                 }).toList()),
                                        //                                           ),
                                        //                                         ),
                                        //                                       ),
                                        Row(
                                          children: [
                                            Text(
                                              "ب",
                                              style: TextStyle(
                                                  fontSize: 15.sp,
                                                  color: fontColor,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            // code for devloper orginal
                                            // Expanded(
                                            //   child: Slider(
                                            //     activeColor: staticThemeId == 4
                                            //         ? Colors.grey
                                            //             .withOpacity(0.8)
                                            //         : Colors.blue,
                                            //     value: _fontSizeProgress,
                                            //     min: 15.0,
                                            //     max: 30.0,
                                            //     onChangeEnd: (double value) {
                                            //       _fontSize = value;

                                            //       gs.write(
                                            //           libFontSize, _fontSize);

                                            //       ///For updating outside
                                            //       updateUI();
                                            //       controllerPaging.paginate();
                                            //     },
                                            //     onChanged: (double value) {
                                            //       ///For updating widget's inside
                                            //       setState(() {
                                            //         _fontSizeProgress = value;
                                            //       });
                                            //     },
                                            //   ),
                                            // ),
                                            // Optimized code
                                            Expanded(
                                              child: Slider(
                                                activeColor: staticThemeId == 4
                                                    ? Colors.grey
                                                        .withOpacity(0.8)
                                                    : Colors.blue,
                                                value: _fontSizeProgress,
                                                min: 15.0,
                                                max: 30.0,
                                                onChangeEnd:
                                                    (double value) async {
                                                  _fontSize = value;

                                                  // ذخیره‌سازی مقدار فونت به صورت غیر همزمان
                                                  await gs.write(
                                                      libFontSize, _fontSize);
                                                  // به‌روزرسانی رابط کاربری و صفحه‌بندی
                                                  controllerPaging.paginate();

                                                  updateUI();

                                                  setState(() {
                                                    widget.isloading = false;
                                                  });
                                                },
                                                onChanged: (double value) {
                                                  setState(() {
                                                    _fontSizeProgress = value;
                                                    widget.isloading = true;
                                                  });
                                                },
                                              ),
                                            ),
                                            Text(
                                              "ب",
                                              style: TextStyle(
                                                  color: fontColor,
                                                  fontSize: 20.sp,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          ],
                                        )
                                      ],
                                    )),
                              ),
                            ],
                          ),
                        ))),
          );
        });
  }

  updateTheme(int id, {bool isInit = false}) async {
    staticThemeId = id;
    if (id == 1) {
      backColor = cVioletishColor;
      fontColor = Colors.white;
    } else if (id == 2) {
      backColor = cBluishColor;
      fontColor = Colors.black;
    } else if (id == 3) {
      backColor = Colors.white;
      fontColor = Colors.black;
    } else if (id == 4) {
      backColor = Colors.black;
      fontColor = Colors.white;
    } else {
      backColor = cPinkishColor;
      fontColor = Colors.black;
    }

    await gs.write(libTheme, id);

    if (!isInit) {
      print('updateTheme ');
      Navigator.of(context).pop();
      controllerPaging.paginate();
      updateUI();
    }
  }

  ///Update widget tree
  updateUI() {
    setState(() {});
  }

  Future<int> _calculateTotalPages(
    String chapterContent,
  ) async {
    double currentHeight = 0.0;
    String currentPageContent = '';
    List<String> newPages = [];
    double maxPageHeight = maxHeight - 320;
    int currentPage = 1;

    _pageTexts.clear();
    var document = html_parser.parse(chapterContent);
    var body = document.body!;
    var elements = body.children;
    var headElements = document.head?.children ?? [];
    var bodyElements = document.body?.children ?? [];
    var allElements = [...headElements, ...bodyElements];
    titlePageNumbers.clear();
    for (var element in elements) {
      if (element.localName == 'title') {
        // قبل از شروع فصل جدید، یک صفحه خالی اضافه کن

        String centeredTitle = '''
    <div style="display: flex; justify-content: center; align-items: center; height: 100vh; flex-direction: row;">
      <h1 style="font-size: 2em;">${element.text}</h1>
    </div>
    ''';
        currentHeight = 200;
        if (currentHeight < maxHeight) {
          newPages.add('</br>$centeredTitle');
          titlePageNumbers.add(currentPage);
          currentPage++;
          currentPageContent = '';
          currentHeight = 0.0;
        }
      }
      processDivElement(element, (String imageSrc) {
        currentPageContent += '<img src="$imageSrc" />';

        currentHeight += maxHeight;

        if (currentHeight > maxHeight - 300) {
          newPages.add(currentPageContent);
          currentPage++;
          currentPageContent = '';
          currentHeight = 0.0;
        }
      }, (String text) {
        final textSpan = TextSpan(
          text: text,
          style: TextStyle(
              backgroundColor: backColor,
              fontSize: _fontSize.sp,
              fontFamily: selectedTextStyle,
              package: 'cosmos_epub',
              color: fontColor),
        );
        textPainter.text = textSpan;
        textPainter.layout(maxWidth: maxWidth);

        final lines = textPainter.computeLineMetrics();
        int currentLine = 0;
        while (currentLine < lines.length) {
          int start = currentLine;
          int endLine = currentLine;

          // محاسبه خطوط تا جایی که به ارتفاع صفحه برسیم
          double totalHeight = 0.0;
          while (endLine < lines.length &&
              totalHeight + lines[endLine].height <= maxHeight) {
            totalHeight += lines[endLine].height;
            endLine++;
          }
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
          if (currentHeight >= maxHeight - 300) {
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

    if (currentPageContent.isNotEmpty) {
      newPages.add(currentPageContent);
      currentPage++;
      currentPageContent = '';
      currentHeight = 0.0;
    }
    print('wwwww');
    print(titlePageNumbers);
    return newPages.length;
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

          onTextFound(text + '\n ');
        }
      }
      if (child.children.isNotEmpty) {
        processDivElement(child, onImageFound, onTextFound);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(maxWidth, maxHeight));
    // designSize:  Size(size.width, size.height));

    return Scaffold(
      backgroundColor: backColor,
      body: PopScope(
        //   canPop: false,
        onPopInvoked: (didPop) {
          backPress();
        },

        child: Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                        child: Stack(
                      children: [
                        FutureBuilder<void>(
                            future: loadChapterFuture,
                            builder: (context, snapshot) {
                              switch (snapshot.connectionState) {
                                case ConnectionState.waiting:
                                  {
                                    return Center(
                                        child: Container(
                                      height: 100,
                                      width: MediaQuery.sizeOf(context).width /
                                          1.5,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        color: Colors.white,
                                      ),
                                      child: const Center(
                                          child: Text(
                                        'کتاب در حال اماده سازی میباشد ',
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.black),
                                      )),
                                    ) // CircularProgressIndicator(),
                                        );
                                  }
                                default:
                                  {
                                    if (widget.shouldOpenDrawer) {
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                        openTableOfContents();
                                      });

                                      widget.shouldOpenDrawer = false;
                                    }
                                    // print(
                                    //   bookProgress
                                    //           .getBookProgress(bookId)
                                    //           .currentPageIndex ??
                                    //       0,
                                    // );

                                    return PagingWidget(
                                      document: epubBook,
                                      chaptercount: chapterPages,
                                      textContents: const [],
                                      textContent,
                                      textContentnumber,
                                      chapters: chaptersList,
                                      innerHtmlContent,

                                      lastWidget: null,
                                      starterPageIndex: bookProgress
                                          .getBookProgress(bookId)
                                          .currentPageIndex!,

                                      style: TextStyle(
                                          backgroundColor: backColor,
                                          fontSize: _fontSize.sp,
                                          fontFamily: selectedTextStyle,
                                          package: 'cosmos_epub',
                                          color: fontColor),
                                      handlerCallback: (ctrl) {
                                        controllerPaging = ctrl;
                                      },
                                      onTextTap: () {
                                        if (showHeader) {
                                          showHeader = false;
                                        } else {
                                          showHeader = true;
                                        }
                                        updateUI();
                                      },
                                      onPageFlip: (currentPage, totalPages) {
                                        // if (widget.onPageFlip != null) {
                                        //   widget.onPageFlip!(
                                        //       currentPage, totalPages);
                                        // }

                                        // if (currentPage == totalPages - 1) {
                                        //   print(
                                        //       'currentPage == totalPages - 1');

                                        //   bookProgress.setCurrentPageIndex(
                                        //       bookId, 0);
                                        //   print('object');
                                        // } else {
                                        //   bookProgress.setCurrentPageIndex(
                                        //       bookId, currentPage);

                                        //   print('object');
                                        //   print(currentPage);
                                        // }

                                        // if (isLastPage) {
                                        //   if (isLastPage) {
                                        //     showHeader = true;
                                        //   } else {
                                        //     lastSwipe = 0;
                                        //   }
                                        //   isLastPage = false;
                                        //   updateUI();
                                        // }

                                        // if (currentPage == 0) {
                                        //   prevSwipe++;
                                        //   if (prevSwipe > 1) {
                                        //     //  prevChapter();
                                        //   }
                                        // } else {
                                        //   prevSwipe = 0;
                                        // }
                                      },
                                      onLastPage: (index, totalPages) async {
                                        if (widget.onLastPage != null) {
                                          widget.onLastPage!(index);
                                        }
                                        if (totalPages > 1) {
                                          lastSwipe++;
                                        } else {
                                          lastSwipe = 1;
                                        }
                                        if (lastSwipe > 1) {
                                          // nextChapter();
                                        }
                                        isLastPage = true;
                                        updateUI();
                                      },
                                      chapterTitle: chaptersList[bookProgress
                                                  .getBookProgress(bookId)
                                                  .currentChapterIndex ??
                                              0]
                                          .chapter,

                                      //  chapterTitle: '',
                                      totalChapters: chaptersList.length,
                                      backColor: backColor,
                                      indexpage: 5,
                                      totolepage: 0,
                                      onHighlightTap: (selectedTextModel) {
                                        debugPrint(
                                            'Highlighted Text: $selectedTextModel');
                                      },
                                    );
                                  }
                              }
                            }),
                        //)

                        // Align(
                        //   alignment: Alignment.bottomRight,
                        //   child: Visibility(
                        //     visible: showBrightnessWidget,
                        //     child: Container(
                        //         height: 150.h,
                        //         width: 30.w,
                        //         alignment: Alignment.bottomCenter,
                        //         margin: EdgeInsets.only(
                        //             bottom: 40.h, right: 15.w),
                        //         child: Column(
                        //           children: [
                        //             // Icon(
                        //             //   Icons.brightness_7,
                        //             //   size: 14.h,
                        //             //   color: fontColor,
                        //             // ),
                        //             SizedBox(
                        //               height: 120.h,
                        //               width: 30.w,
                        //               child: RotatedBox(
                        //                   quarterTurns: -1,
                        //                   child: SliderTheme(
                        //                       data: SliderThemeData(
                        //                         activeTrackColor:
                        //                             staticThemeId == 4
                        //                                 ? Colors.white
                        //                                 : Colors.blue,
                        //                         disabledThumbColor:
                        //                             Colors.transparent,
                        //                         inactiveTrackColor: Colors
                        //                             .grey
                        //                             .withOpacity(0.5),
                        //                         trackHeight: 5.0,

                        //                         thumbColor: staticThemeId == 4
                        //                             ? Colors.grey
                        //                                 .withOpacity(0.8)
                        //                             : Colors.blue,
                        //                         thumbShape:
                        //                             RoundSliderThumbShape(
                        //                                 enabledThumbRadius:
                        //                                     0.r),
                        //                         // Adjust the size of the thumb
                        //                         overlayShape:
                        //                             RoundSliderOverlayShape(
                        //                                 overlayRadius: 10
                        //                                     .r), // Adjust the size of the overlay
                        //                       ),
                        //                       child: Slider(
                        //                         value: brightnessLevel,
                        //                         min: 0.0,
                        //                         max: 1.0,
                        //                         onChangeEnd: (double value) {
                        //                           setBrightness(value);
                        //                         },
                        //                         onChanged: (double value) {
                        //                           setState(() {
                        //                             brightnessLevel = value;
                        //                           });
                        //                         },
                        //                       ))),
                        //             ),
                        //           ],
                        //         )),
                        //   ),
                        // )
                      ],
                    )),

                    // AnimatedContainer(
                    //   height: showHeader ? 40.h : 0,
                    //   duration: const Duration(milliseconds: 100),
                    //   color: backColor,
                    //   child: Container(
                    //     height: 40.h,
                    //     alignment: Alignment.center,
                    //     decoration: BoxDecoration(
                    //       color: backColor,
                    //       border: Border(
                    //         top: BorderSide(
                    //             width: 3.w, color: widget.accentColor),
                    //       ),
                    //     ),
                    //     child: Row(
                    //       mainAxisAlignment: MainAxisAlignment.spaceAround,
                    //       children: [
                    //         SizedBox(
                    //           width: 5.w,
                    //         ),
                    //         Visibility(
                    //           visible: showPrevious,
                    //           child: IconButton(
                    //               onPressed: () {
                    //                 prevChapter();
                    //               },
                    //               icon: Icon(
                    //                 Icons.arrow_back_ios,
                    //                 size: 15.h,
                    //                 color: fontColor,
                    //               )),
                    //         ),
                    //         SizedBox(
                    //           width: 5.w,
                    //         ),
                    //         Expanded(
                    //           flex: 10,
                    //           child: Text(
                    //             chaptersList.isNotEmpty
                    //                 ? chaptersList[bookProgress
                    //                             .getBookProgress(bookId)
                    //                             .currentChapterIndex ??
                    //                         0]
                    //                     .chapter
                    //                 : 'Loading...',
                    //             maxLines: 1,
                    //             textAlign: TextAlign.center,
                    //             style: TextStyle(
                    //                 fontSize: 13.sp,
                    //                 overflow: TextOverflow.ellipsis,
                    //                 fontFamily: selectedTextStyle,
                    //                 package: 'cosmos_epub',
                    //                 fontWeight: FontWeight.bold,
                    //                 color: fontColor),
                    //           ),
                    //         ),
                    //         SizedBox(
                    //           width: 5.w,
                    //         ),
                    //         Visibility(
                    //             visible: showNext,
                    //             child: IconButton(
                    //                 onPressed: () {
                    //                   nextChapter();
                    //                 },
                    //                 icon: Icon(
                    //                   Icons.arrow_forward_ios_rounded,
                    //                   size: 15.h,
                    //                   color: fontColor,
                    //                 ))),
                    //         SizedBox(
                    //           width: 5.w,
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
                AnimatedContainer(
                  // height: showHeader ? 50.h : 0,
                  height: 50,
                  duration: const Duration(milliseconds: 100),
                  color: backColor,
                  child: Padding(
                    padding: EdgeInsets.only(top: 3.h),
                    child: AppBar(
                      centerTitle: true,
                      title: Text(
                        bookTitle,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                            color: fontColor),
                      ),
                      backgroundColor: backColor,
                      shape: Border(
                          bottom: BorderSide(
                              color: widget.accentColor, width: 3.h)),
                      elevation: 0,
                      leading: IconButton(
                        onPressed: openTableOfContents,
                        icon: Icon(
                          Icons.menu,
                          color: fontColor,
                          size: 20.h,
                        ),
                      ),
                      actions: [
                        InkWell(
                            onTap: () {
                              updateFontSettings();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.settings,
                                color: fontColor,
                                size: 25,
                              ),
                            )
                            // Container(
                            //   width: 40.w,
                            //   alignment: Alignment.center,
                            //   child: Text(
                            //     "Aa",
                            //     style: TextStyle(
                            //         fontSize: 18.sp,
                            //         color: fontColor,
                            //         fontWeight: FontWeight.bold),
                            //   ),
                            // )
                            ),
                        // SizedBox(
                        //   width: 5.w,
                        // ),
                        // InkWell(
                        //     onTap: () async {
                        //       setState(() {
                        //         showBrightnessWidget = true;
                        //       });
                        //       await Future.delayed(const Duration(seconds: 7));
                        //       setState(() {
                        //         showBrightnessWidget = false;
                        //       });
                        //     },
                        //     child: Icon(
                        //       Icons.brightness_high_sharp,
                        //       size: 20.h,
                        //       color: fontColor,
                        //     )),
                        SizedBox(
                          width: 10.w,
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  openTableOfContents() async {
    bool? shouldUpdate = await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ChaptersList(
                  bookId: bookId,
                  chapters: chaptersList,
                  // leadingIcon: null,
                  accentColor: widget.accentColor,
                  chapterListTitle: widget.chapterListTitle,
                  chapterPages: chapterPages, //titlePageNumbers
                ))) ??
        false;
    if (shouldUpdate) {
      var index = bookProgress.getBookProgress(bookId).currentChapterIndex ?? 0;
      var page = bookProgress.getBookProgress(bookId).currentPageIndex ?? 0;

      ///Set page to initial and update chapter index with content
      // await bookProgress.setCurrentPageIndex(bookId, page);
      // await bookProgress.setCurrentChapterIndex(bookId, index, 0);

      reLoadChapter(init: false, index: index, page: page);
    }
  }
}
// ignore: must_be_immutable

//  Future<void> showExitPopup(
//       // BuildContext context,
//       ) async {
//     return await showDialog(
//       barrierDismissible: true,
//       context: context,
//       builder: (BuildContext context) {
//         Size size = MediaQuery.sizeOf(context);
//         // return AlertDialog(

//         //   backgroundColor: Colors.white,
//         //   content:
//         return Stack(
//           alignment: Alignment.bottomCenter,
//           children: [
//             Container(
//               padding:
//                   const EdgeInsets.only(bottom: 8, right: 16, left: 16, top: 8),
//               height: 160,
//               width: size.width,
//               decoration: const BoxDecoration(
//                   borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(24),
//                       topRight: Radius.circular(24)),
//                   color: Colors.white),
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 0),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     //    Text('000'),
//                     Text(
//                       'کتابخوان',
//                       // style: textTheme.labelSmall!.copyWith(
//                       //   fontFamily: 'Bold',
//                       // ),
//                       style: TextStyle(
//                           fontFamily: 'BNazanin',
//                           fontSize: 14,
//                           color: Colors.black),
//                     ),
//                     // SizedBox(height: 24),
//                     Text(
//                       'آیا میخواهید از کتابخوان  خارج شوید؟',
//                       // style: textTheme.displaySmall!.copyWith(
//                       //   fontFamily: 'Light',
//                       //   fontSize: 16,
//                       // ),
//                       style: TextStyle(
//                           //  fontFamily: selectedTextStyle,
//                           fontSize: 14,
//                           color: Colors.black),
//                       textAlign: TextAlign.center,
//                     ),
//                     // SizedBox(height: 24),
//                     Row(
//                       //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Expanded(
//                           child: SizedBox(
//                               height: 42,
//                               width: size.width / 3.5,
//                               child: ElevatedButton(
//                                   onPressed: () {
//                                     backPress();
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Color(0xffB0276D),
//                                     foregroundColor: Colors.white,
//                                     //   elevation: 10,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(8),
//                                     ),
//                                   ),
//                                   child: Text(
//                                     'خارج شدن',
//                                     style: const TextStyle(
//                                         fontFamily: 'BNazanin',
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w600),
//                                   ))),
//                         ),
//                         //   Spacer(),
//                         SizedBox(width: 16),
// nextChapter() async {
//   ///Set page to initial
//   await bookProgress.setCurrentPageIndex(bookId, 0);

//   var index = bookProgress.getBookProgress(bookId).currentChapterIndex!;

//   if (index != chaptersList.length - 1) {
//     //    reLoadChapter(index: index + 1);
//   }
// }

// prevChapter() async {
//   ///Set page to initial
//   await bookProgress.setCurrentPageIndex(bookId, 0);

//   var index = bookProgress.getBookProgress(bookId).currentChapterIndex ?? 0;

//   if (index != 0) {
//     //   reLoadChapter(index: index - 1);
//   }
// }
//                         Expanded(
//                           child: SizedBox(
//                               height: 42,
//                               width: size.width / 3.5,
//                               child: OutlinedButton(
//                                   onPressed: () {
//                                     Navigator.of(context).pop(false);
//                                   },
//                                   style: OutlinedButton.styleFrom(
//                                     foregroundColor: Color(0xff4430C2),
//                                     side: BorderSide(
//                                         color: Color(0xff4430C2), width: 2),
//                                     //   elevation: 10,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(8),
//                                     ),
//                                   ),
//                                   child: Text(
//                                     'بازگشت',
//                                     style: const TextStyle(
//                                         fontFamily: 'BNazanin',
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w600),
//                                   ))),
//                         ),
//                       ],
//                     )
//                   ],
//                 ),
//               ),
//               //  ),
//             ),
//           ],
//         );
//       },
//     );
//   }
