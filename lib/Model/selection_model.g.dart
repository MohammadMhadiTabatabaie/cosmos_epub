// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selection_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSelectedTextModelCollection on Isar {
  IsarCollection<SelectedTextModel> get selectedTextModels => this.collection();
}

const SelectedTextModelSchema = CollectionSchema(
  name: r'SelectedTextModel',
  id: 4864414128025723723,
  properties: {
    r'bookid': PropertySchema(
      id: 0,
      name: r'bookid',
      type: IsarType.string,
    ),
    r'paragraphIndex': PropertySchema(
      id: 1,
      name: r'paragraphIndex',
      type: IsarType.long,
    ),
    r'paragraphText': PropertySchema(
      id: 2,
      name: r'paragraphText',
      type: IsarType.string,
    ),
    r'selectedText': PropertySchema(
      id: 3,
      name: r'selectedText',
      type: IsarType.string,
    ),
    r'tag': PropertySchema(
      id: 4,
      name: r'tag',
      type: IsarType.string,
    )
  },
  estimateSize: _selectedTextModelEstimateSize,
  serialize: _selectedTextModelSerialize,
  deserialize: _selectedTextModelDeserialize,
  deserializeProp: _selectedTextModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _selectedTextModelGetId,
  getLinks: _selectedTextModelGetLinks,
  attach: _selectedTextModelAttach,
  version: '3.1.0+1',
);

int _selectedTextModelEstimateSize(
  SelectedTextModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.bookid.length * 3;
  bytesCount += 3 + object.paragraphText.length * 3;
  bytesCount += 3 + object.selectedText.length * 3;
  {
    final value = object.tag;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _selectedTextModelSerialize(
  SelectedTextModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.bookid);
  writer.writeLong(offsets[1], object.paragraphIndex);
  writer.writeString(offsets[2], object.paragraphText);
  writer.writeString(offsets[3], object.selectedText);
  writer.writeString(offsets[4], object.tag);
}

SelectedTextModel _selectedTextModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SelectedTextModel(
    bookid: reader.readString(offsets[0]),
    paragraphIndex: reader.readLong(offsets[1]),
    paragraphText: reader.readString(offsets[2]),
    selectedText: reader.readString(offsets[3]),
    tag: reader.readStringOrNull(offsets[4]),
  );
  object.id = id;
  return object;
}

P _selectedTextModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _selectedTextModelGetId(SelectedTextModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _selectedTextModelGetLinks(
    SelectedTextModel object) {
  return [];
}

void _selectedTextModelAttach(
    IsarCollection<dynamic> col, Id id, SelectedTextModel object) {
  object.id = id;
}

extension SelectedTextModelQueryWhereSort
    on QueryBuilder<SelectedTextModel, SelectedTextModel, QWhere> {
  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SelectedTextModelQueryWhere
    on QueryBuilder<SelectedTextModel, SelectedTextModel, QWhereClause> {
  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SelectedTextModelQueryFilter
    on QueryBuilder<SelectedTextModel, SelectedTextModel, QFilterCondition> {
  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterFilterCondition>
      bookidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bookid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterFilterCondition>
      bookidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bookid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterFilterCondition>
      bookidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bookid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterFilterCondition>
      bookidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bookid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterFilterCondition>
      bookidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'bookid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterFilterCondition>
      bookidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'bookid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterFilterCondition>
      bookidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'bookid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterFilterCondition>
      bookidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'bookid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterFilterCondition>
      bookidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bookid',
        value: '',
      ));
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterFilterCondition>
      bookidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'bookid',
        value: '',
      ));
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterFilterCondition>
      paragraphIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paragraphIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterFilterCondition>
      paragraphIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'paragraphIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterFilterCondition>
      paragraphIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'paragraphIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterFilterCondition>
      paragraphIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'paragraphIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterFilterCondition>
      paragraphTextEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paragraphText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterFilterCondition>
      paragraphTextGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'paragraphText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterFilterCondition>
      paragraphTextLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'paragraphText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterFilterCondition>
      paragraphTextBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'paragraphText',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterFilterCondition>
      paragraphTextStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'paragraphText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterFilterCondition>
      paragraphTextEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'paragraphText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterFilterCondition>
      paragraphTextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'paragraphText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterFilterCondition>
      paragraphTextMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'paragraphText',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterFilterCondition>
      paragraphTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paragraphText',
        value: '',
      ));
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterFilterCondition>
      paragraphTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'paragraphText',
        value: '',
      ));
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterFilterCondition>
      selectedTextEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'selectedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterFilterCondition>
      selectedTextGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'selectedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterFilterCondition>
      selectedTextLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'selectedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterFilterCondition>
      selectedTextBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'selectedText',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterFilterCondition>
      selectedTextStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'selectedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterFilterCondition>
      selectedTextEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'selectedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterFilterCondition>
      selectedTextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'selectedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterFilterCondition>
      selectedTextMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'selectedText',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterFilterCondition>
      selectedTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'selectedText',
        value: '',
      ));
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterFilterCondition>
      selectedTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'selectedText',
        value: '',
      ));
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterFilterCondition>
      tagIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tag',
      ));
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterFilterCondition>
      tagIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tag',
      ));
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterFilterCondition>
      tagEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tag',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterFilterCondition>
      tagGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tag',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterFilterCondition>
      tagLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tag',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterFilterCondition>
      tagBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tag',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterFilterCondition>
      tagStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tag',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterFilterCondition>
      tagEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tag',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterFilterCondition>
      tagContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tag',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterFilterCondition>
      tagMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tag',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterFilterCondition>
      tagIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tag',
        value: '',
      ));
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterFilterCondition>
      tagIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tag',
        value: '',
      ));
    });
  }
}

extension SelectedTextModelQueryObject
    on QueryBuilder<SelectedTextModel, SelectedTextModel, QFilterCondition> {}

extension SelectedTextModelQueryLinks
    on QueryBuilder<SelectedTextModel, SelectedTextModel, QFilterCondition> {}

extension SelectedTextModelQuerySortBy
    on QueryBuilder<SelectedTextModel, SelectedTextModel, QSortBy> {
  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterSortBy>
      sortByBookid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookid', Sort.asc);
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterSortBy>
      sortByBookidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookid', Sort.desc);
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterSortBy>
      sortByParagraphIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paragraphIndex', Sort.asc);
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterSortBy>
      sortByParagraphIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paragraphIndex', Sort.desc);
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterSortBy>
      sortByParagraphText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paragraphText', Sort.asc);
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterSortBy>
      sortByParagraphTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paragraphText', Sort.desc);
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterSortBy>
      sortBySelectedText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'selectedText', Sort.asc);
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterSortBy>
      sortBySelectedTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'selectedText', Sort.desc);
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterSortBy> sortByTag() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tag', Sort.asc);
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterSortBy>
      sortByTagDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tag', Sort.desc);
    });
  }
}

extension SelectedTextModelQuerySortThenBy
    on QueryBuilder<SelectedTextModel, SelectedTextModel, QSortThenBy> {
  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterSortBy>
      thenByBookid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookid', Sort.asc);
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterSortBy>
      thenByBookidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookid', Sort.desc);
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterSortBy>
      thenByParagraphIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paragraphIndex', Sort.asc);
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterSortBy>
      thenByParagraphIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paragraphIndex', Sort.desc);
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterSortBy>
      thenByParagraphText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paragraphText', Sort.asc);
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterSortBy>
      thenByParagraphTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paragraphText', Sort.desc);
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterSortBy>
      thenBySelectedText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'selectedText', Sort.asc);
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterSortBy>
      thenBySelectedTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'selectedText', Sort.desc);
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterSortBy> thenByTag() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tag', Sort.asc);
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QAfterSortBy>
      thenByTagDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tag', Sort.desc);
    });
  }
}

extension SelectedTextModelQueryWhereDistinct
    on QueryBuilder<SelectedTextModel, SelectedTextModel, QDistinct> {
  QueryBuilder<SelectedTextModel, SelectedTextModel, QDistinct>
      distinctByBookid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bookid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QDistinct>
      distinctByParagraphIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'paragraphIndex');
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QDistinct>
      distinctByParagraphText({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'paragraphText',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QDistinct>
      distinctBySelectedText({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'selectedText', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SelectedTextModel, SelectedTextModel, QDistinct> distinctByTag(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tag', caseSensitive: caseSensitive);
    });
  }
}

extension SelectedTextModelQueryProperty
    on QueryBuilder<SelectedTextModel, SelectedTextModel, QQueryProperty> {
  QueryBuilder<SelectedTextModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SelectedTextModel, String, QQueryOperations> bookidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bookid');
    });
  }

  QueryBuilder<SelectedTextModel, int, QQueryOperations>
      paragraphIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'paragraphIndex');
    });
  }

  QueryBuilder<SelectedTextModel, String, QQueryOperations>
      paragraphTextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'paragraphText');
    });
  }

  QueryBuilder<SelectedTextModel, String, QQueryOperations>
      selectedTextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'selectedText');
    });
  }

  QueryBuilder<SelectedTextModel, String?, QQueryOperations> tagProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tag');
    });
  }
}
