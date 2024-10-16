import 'package:cosmos_epub/Model/book_progress_model.dart';
import 'package:cosmos_epub/Model/selection_model.dart';
import 'package:isar/isar.dart';

class BookProgressSingleton {
  final Isar isar;

  BookProgressSingleton({required this.isar});

  Future<bool> setCurrentChapterIndex(
      String bookId, int chapterIndex, int currentPageIndex) async {
    try {
      BookProgressModel? oldBookProgressModel = await isar.bookProgressModels
          .where()
          .filter()
          .bookIdEqualTo(bookId)
          .findFirst();

      if (oldBookProgressModel != null) {
        oldBookProgressModel.currentChapterIndex = chapterIndex;
        await isar.writeTxn(() async {
          isar.bookProgressModels.put(oldBookProgressModel);
        });
      } else {
        var newBookProgressModel = BookProgressModel(
            currentPageIndex: 0,
            currentChapterIndex: chapterIndex,
            bookId: bookId);
        await isar.writeTxn(() async {
          isar.bookProgressModels.put(newBookProgressModel);
        });
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> setHighlight(
    int paragraphIndex,
    String bookid,
    String tag,
    String paragraphText,
    String selectedText,
  ) async {
    try {
      print('ذخیره سازی در دیتابیس');
      SelectedTextModel? oldSelectedTextModel = await isar.selectedTextModels
          .where()
          .filter()
          .bookidEqualTo(bookid)
          .and()
          .paragraphIndexEqualTo(paragraphIndex)
          .findFirst();

      if (oldSelectedTextModel != null) {
        oldSelectedTextModel.bookid = bookid;
        oldSelectedTextModel.tag = tag;
        oldSelectedTextModel.selectedText = selectedText;
        oldSelectedTextModel.paragraphText = paragraphText;
        await isar.writeTxn(() async {
          isar.selectedTextModels.put(oldSelectedTextModel);
        });
      } else {
        var newSelectedTextModel = SelectedTextModel(
            paragraphIndex: paragraphIndex,
            bookid: bookid,
            tag: tag,
            selectedText: selectedText,
            paragraphText: paragraphText);
        await isar.writeTxn(() async {
          isar.selectedTextModels.put(newSelectedTextModel);
        });
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<SelectedTextModel>> getHighlightsByBook(String bookid) async {
    try {
      List<SelectedTextModel> highlights = await isar.selectedTextModels
          .where()
          .filter()
          .bookidEqualTo(bookid)
          .findAll();
      return highlights;
    } catch (e) {
      print('Error fetching highlights for book $bookid: $e');
      return [];
    }
  }

  Future<bool> setCurrentPageIndex(String bookId, int pageIndex) async {
    try {
      BookProgressModel? oldBookProgressModel = await isar.bookProgressModels
          .where()
          .filter()
          .bookIdEqualTo(bookId)
          .findFirst();

      if (oldBookProgressModel != null) {
        oldBookProgressModel.currentPageIndex = pageIndex;
        await isar.writeTxn(() async {
          isar.bookProgressModels.put(oldBookProgressModel);
        });
      } else {
        var newBookProgressModel = BookProgressModel(
            currentPageIndex: pageIndex,
            currentChapterIndex: 0,
            bookId: bookId);
        await isar.writeTxn(() async {
          isar.bookProgressModels.put(newBookProgressModel);
        });
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> deleteHighlight(int id) async {
    try {
      // حذف رکورد با شناسه id
      await isar.writeTxn(() async {
        bool success = await isar.selectedTextModels.delete(id);
        if (!success) {
          print('Failed to delete highlight with id $id');
        }
      });
    } catch (e) {
      print('Error deleting highlight with id $id: $e');
    }
  }

  BookProgressModel getBookProgress(String bookId) {
    var newBookProgressModel =
        BookProgressModel(currentPageIndex: 0, currentChapterIndex: 0);

    try {
      BookProgressModel? oldBookProgressModel = isar.bookProgressModels
          .where()
          .filter()
          .bookIdEqualTo(bookId)
          .findFirstSync();
      if (oldBookProgressModel != null) {
        return oldBookProgressModel;
      } else {
        return newBookProgressModel;
      }
    } on Exception {
      return newBookProgressModel;
    }
  }

  Future<bool> deleteBookProgress(String bookId) async {
    try {
      await isar.writeTxn(() async {
        await isar.bookProgressModels
            .where()
            .filter()
            .bookIdEqualTo(bookId)
            .deleteAll();
      });
      return true;
    } on Exception {
      return false;
    }
  }

  Future<bool> deleteAllBooksProgress() async {
    try {
      await isar.writeTxn(() async {
        await isar.bookProgressModels.where().deleteAll();
      });
      return true;
    } on Exception {
      return false;
    }
  }
}
