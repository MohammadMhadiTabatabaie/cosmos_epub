// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../Model/chapter_model.dart';
import '../show_epub.dart';

// ignore: must_be_immutable
class ChaptersList extends StatelessWidget {
  List<LocalChapterModel> chapters = [];
  final String bookId;
  final Widget? leadingIcon;
  final Color accentColor;
  final String chapterListTitle;
  final List<int> chapterPages;
  ChaptersList(
      {super.key,
      required this.chapters,
      required this.bookId,
      this.leadingIcon,
      required this.accentColor,
      required this.chapterListTitle,
      required this.chapterPages});

  @override
  Widget build(BuildContext context) {
    List<int> removeDuplicates(List<int> chapterPages) {
      List<int> uniquePages = [];
      //   uniquePages.add(chapterPages[0]);

      for (int i = 1; i < chapterPages.length; i++) {
        if (chapterPages[i] != chapterPages[i - 1]) {
          uniquePages.add(chapterPages[i]);
        }
      }

      return uniquePages;
    }

   // int cumulativePages = 0;
    // if (chapters.length == chapterPages.length) {
    //   return Scaffold(
    //     appBar: AppBar(
    //       title: Text('Error'),
    //     ),
    //     body: Center(
    //       child: Text('Mismatch between chapters and pages count'),
    //     ),
    //   );
    // }
    
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 40.h,
          backgroundColor: backColor,
          leading: InkWell(
              onTap: () {
                Navigator.of(context).pop(false);
              },
              child: Icon(
                Icons.close,
                color: fontColor,
                size: 20.h,
              )),
          centerTitle: true,
          title: Text(
            'فهرست',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: accentColor,
                fontSize: 15.sp),
          ),
        ),
        body: SafeArea(
          child: Container(
            color: backColor,
            padding: EdgeInsets.all(10.h),
            child: ListView.builder(
                itemCount: chapters.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, i) {
                
                  int startPage = 1;
                  for (int j = 0; j < i; j++) {
                    startPage += chapterPages[j];
                  }

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        onTap: () async {
                          print('bookId $bookId  i $i  startPage $startPage  ');

                          await bookProgress.setCurrentChapterIndex(
                              bookId, i, startPage);
                          await bookProgress.setCurrentPageIndex(
                              bookId, startPage);
                          Navigator.of(context).pop(true);
                        },
                        subtitle: Text(
                          'شروع از صفحه: $startPage',
                          style: TextStyle(color: Colors.black),
                        ),
                        leading: leadingIcon,
                        minLeadingWidth: 20.w,
                        title: Padding(
                          padding: EdgeInsets.only(
                              left: chapters[i].isSubChapter ? 15.w :0
                              ),
                          child: Text(
                            chapters[i].chapter,
                            style: TextStyle(
                                color: bookProgress
                                            .getBookProgress(bookId)
                                            .currentChapterIndex ==
                                        i
                                    ? accentColor
                                    : fontColor,
                                // fontFamily: fontNames
                                //     .where((element) => element == selectedFont)
                                //     .first,

                                package: 'cosmos_epub',
                                fontSize: 15.sp,
                                // fontWeight: chapters[i].isSubChapter
                                //     ? FontWeight.w400
                                //     : FontWeight.w600
                                    ),
                          ),
                        ),
                        dense: true,
                      ),
                      Divider(height: 0, thickness: 1.h),
                    ],
                  );
                }),
          ),
        ),
      ),
    );
  }
}
