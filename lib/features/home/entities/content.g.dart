// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetContentCollection on Isar {
  IsarCollection<Content> get contents => this.collection();
}

const ContentSchema = CollectionSchema(
  name: r'Content',
  id: 2749874844035024652,
  properties: {
    r'hasVoice': PropertySchema(id: 0, name: r'hasVoice', type: IsarType.bool),
    r'headerId': PropertySchema(id: 1, name: r'headerId', type: IsarType.long),
    r'isLiked': PropertySchema(id: 2, name: r'isLiked', type: IsarType.bool),
    r'text': PropertySchema(id: 3, name: r'text', type: IsarType.string),
    r'voiceFile': PropertySchema(
      id: 4,
      name: r'voiceFile',
      type: IsarType.string,
    ),
  },

  estimateSize: _contentEstimateSize,
  serialize: _contentSerialize,
  deserialize: _contentDeserialize,
  deserializeProp: _contentDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _contentGetId,
  getLinks: _contentGetLinks,
  attach: _contentAttach,
  version: '3.3.0',
);

int _contentEstimateSize(
  Content object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.text.length * 3;
  {
    final value = object.voiceFile;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _contentSerialize(
  Content object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.hasVoice);
  writer.writeLong(offsets[1], object.headerId);
  writer.writeBool(offsets[2], object.isLiked);
  writer.writeString(offsets[3], object.text);
  writer.writeString(offsets[4], object.voiceFile);
}

Content _contentDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Content(
    id,
    reader.readString(offsets[3]),
    reader.readBool(offsets[2]),
    reader.readLong(offsets[1]),
    hasVoice: reader.readBoolOrNull(offsets[0]) ?? false,
    voiceFile: reader.readStringOrNull(offsets[4]),
  );
  return object;
}

P _contentDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _contentGetId(Content object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _contentGetLinks(Content object) {
  return [];
}

void _contentAttach(IsarCollection<dynamic> col, Id id, Content object) {}

extension ContentQueryWhereSort on QueryBuilder<Content, Content, QWhere> {
  QueryBuilder<Content, Content, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ContentQueryWhere on QueryBuilder<Content, Content, QWhereClause> {
  QueryBuilder<Content, Content, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<Content, Content, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Content, Content, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Content, Content, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Content, Content, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension ContentQueryFilter
    on QueryBuilder<Content, Content, QFilterCondition> {
  QueryBuilder<Content, Content, QAfterFilterCondition> hasVoiceEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'hasVoice', value: value),
      );
    });
  }

  QueryBuilder<Content, Content, QAfterFilterCondition> headerIdEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'headerId', value: value),
      );
    });
  }

  QueryBuilder<Content, Content, QAfterFilterCondition> headerIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'headerId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Content, Content, QAfterFilterCondition> headerIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'headerId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Content, Content, QAfterFilterCondition> headerIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'headerId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Content, Content, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<Content, Content, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Content, Content, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Content, Content, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Content, Content, QAfterFilterCondition> isLikedEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isLiked', value: value),
      );
    });
  }

  QueryBuilder<Content, Content, QAfterFilterCondition> textEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'text',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Content, Content, QAfterFilterCondition> textGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'text',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Content, Content, QAfterFilterCondition> textLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'text',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Content, Content, QAfterFilterCondition> textBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'text',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Content, Content, QAfterFilterCondition> textStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'text',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Content, Content, QAfterFilterCondition> textEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'text',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Content, Content, QAfterFilterCondition> textContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'text',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Content, Content, QAfterFilterCondition> textMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'text',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Content, Content, QAfterFilterCondition> textIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'text', value: ''),
      );
    });
  }

  QueryBuilder<Content, Content, QAfterFilterCondition> textIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'text', value: ''),
      );
    });
  }

  QueryBuilder<Content, Content, QAfterFilterCondition> voiceFileIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'voiceFile'),
      );
    });
  }

  QueryBuilder<Content, Content, QAfterFilterCondition> voiceFileIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'voiceFile'),
      );
    });
  }

  QueryBuilder<Content, Content, QAfterFilterCondition> voiceFileEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'voiceFile',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Content, Content, QAfterFilterCondition> voiceFileGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'voiceFile',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Content, Content, QAfterFilterCondition> voiceFileLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'voiceFile',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Content, Content, QAfterFilterCondition> voiceFileBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'voiceFile',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Content, Content, QAfterFilterCondition> voiceFileStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'voiceFile',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Content, Content, QAfterFilterCondition> voiceFileEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'voiceFile',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Content, Content, QAfterFilterCondition> voiceFileContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'voiceFile',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Content, Content, QAfterFilterCondition> voiceFileMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'voiceFile',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Content, Content, QAfterFilterCondition> voiceFileIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'voiceFile', value: ''),
      );
    });
  }

  QueryBuilder<Content, Content, QAfterFilterCondition> voiceFileIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'voiceFile', value: ''),
      );
    });
  }
}

extension ContentQueryObject
    on QueryBuilder<Content, Content, QFilterCondition> {}

extension ContentQueryLinks
    on QueryBuilder<Content, Content, QFilterCondition> {}

extension ContentQuerySortBy on QueryBuilder<Content, Content, QSortBy> {
  QueryBuilder<Content, Content, QAfterSortBy> sortByHasVoice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasVoice', Sort.asc);
    });
  }

  QueryBuilder<Content, Content, QAfterSortBy> sortByHasVoiceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasVoice', Sort.desc);
    });
  }

  QueryBuilder<Content, Content, QAfterSortBy> sortByHeaderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'headerId', Sort.asc);
    });
  }

  QueryBuilder<Content, Content, QAfterSortBy> sortByHeaderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'headerId', Sort.desc);
    });
  }

  QueryBuilder<Content, Content, QAfterSortBy> sortByIsLiked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLiked', Sort.asc);
    });
  }

  QueryBuilder<Content, Content, QAfterSortBy> sortByIsLikedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLiked', Sort.desc);
    });
  }

  QueryBuilder<Content, Content, QAfterSortBy> sortByText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.asc);
    });
  }

  QueryBuilder<Content, Content, QAfterSortBy> sortByTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.desc);
    });
  }

  QueryBuilder<Content, Content, QAfterSortBy> sortByVoiceFile() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voiceFile', Sort.asc);
    });
  }

  QueryBuilder<Content, Content, QAfterSortBy> sortByVoiceFileDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voiceFile', Sort.desc);
    });
  }
}

extension ContentQuerySortThenBy
    on QueryBuilder<Content, Content, QSortThenBy> {
  QueryBuilder<Content, Content, QAfterSortBy> thenByHasVoice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasVoice', Sort.asc);
    });
  }

  QueryBuilder<Content, Content, QAfterSortBy> thenByHasVoiceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasVoice', Sort.desc);
    });
  }

  QueryBuilder<Content, Content, QAfterSortBy> thenByHeaderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'headerId', Sort.asc);
    });
  }

  QueryBuilder<Content, Content, QAfterSortBy> thenByHeaderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'headerId', Sort.desc);
    });
  }

  QueryBuilder<Content, Content, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Content, Content, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Content, Content, QAfterSortBy> thenByIsLiked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLiked', Sort.asc);
    });
  }

  QueryBuilder<Content, Content, QAfterSortBy> thenByIsLikedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLiked', Sort.desc);
    });
  }

  QueryBuilder<Content, Content, QAfterSortBy> thenByText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.asc);
    });
  }

  QueryBuilder<Content, Content, QAfterSortBy> thenByTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.desc);
    });
  }

  QueryBuilder<Content, Content, QAfterSortBy> thenByVoiceFile() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voiceFile', Sort.asc);
    });
  }

  QueryBuilder<Content, Content, QAfterSortBy> thenByVoiceFileDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voiceFile', Sort.desc);
    });
  }
}

extension ContentQueryWhereDistinct
    on QueryBuilder<Content, Content, QDistinct> {
  QueryBuilder<Content, Content, QDistinct> distinctByHasVoice() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasVoice');
    });
  }

  QueryBuilder<Content, Content, QDistinct> distinctByHeaderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'headerId');
    });
  }

  QueryBuilder<Content, Content, QDistinct> distinctByIsLiked() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isLiked');
    });
  }

  QueryBuilder<Content, Content, QDistinct> distinctByText({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'text', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Content, Content, QDistinct> distinctByVoiceFile({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'voiceFile', caseSensitive: caseSensitive);
    });
  }
}

extension ContentQueryProperty
    on QueryBuilder<Content, Content, QQueryProperty> {
  QueryBuilder<Content, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Content, bool, QQueryOperations> hasVoiceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasVoice');
    });
  }

  QueryBuilder<Content, int, QQueryOperations> headerIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'headerId');
    });
  }

  QueryBuilder<Content, bool, QQueryOperations> isLikedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isLiked');
    });
  }

  QueryBuilder<Content, String, QQueryOperations> textProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'text');
    });
  }

  QueryBuilder<Content, String?, QQueryOperations> voiceFileProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'voiceFile');
    });
  }
}
