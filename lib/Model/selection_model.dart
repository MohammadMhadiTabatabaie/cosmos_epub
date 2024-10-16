import 'package:isar/isar.dart';

part 'selection_model.g.dart';

@collection
@Name("SelectedTextModel")
class SelectedTextModel {
  SelectedTextModel({
    required this.paragraphIndex,
    required this.bookid,
    required this.tag,
    required this.selectedText,
    required this.paragraphText,
  });

  Id id = Isar.autoIncrement; // ID خودکار

  int paragraphIndex;
  String bookid;
  String? tag;
  String paragraphText;
  String selectedText;

  @override
  String toString() {
    return 'SelectedTextModel{paragraphIndex: $paragraphIndex, tag: $tag, '
        'paragraphText: $paragraphText, selectedText: $selectedText}';
  }
}
