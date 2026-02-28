// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fasting_repository.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetFastingStateEntityCollection on Isar {
  IsarCollection<FastingStateEntity> get fastingStateEntitys =>
      this.collection();
}

const FastingStateEntitySchema = CollectionSchema(
  name: r'FastingStateEntity',
  id: -667495577100898282,
  properties: {
    r'elapsedMilliseconds': PropertySchema(
      id: 0,
      name: r'elapsedMilliseconds',
      type: IsarType.long,
    ),
    r'goalMilliseconds': PropertySchema(
      id: 1,
      name: r'goalMilliseconds',
      type: IsarType.long,
    ),
    r'isFasting': PropertySchema(
      id: 2,
      name: r'isFasting',
      type: IsarType.bool,
    ),
    r'singletonKey': PropertySchema(
      id: 3,
      name: r'singletonKey',
      type: IsarType.string,
    ),
    r'startTime': PropertySchema(
      id: 4,
      name: r'startTime',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _fastingStateEntityEstimateSize,
  serialize: _fastingStateEntitySerialize,
  deserialize: _fastingStateEntityDeserialize,
  deserializeProp: _fastingStateEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'singletonKey': IndexSchema(
      id: -5792767127485174674,
      name: r'singletonKey',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'singletonKey',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _fastingStateEntityGetId,
  getLinks: _fastingStateEntityGetLinks,
  attach: _fastingStateEntityAttach,
  version: '3.1.0+1',
);

int _fastingStateEntityEstimateSize(
  FastingStateEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.singletonKey.length * 3;
  return bytesCount;
}

void _fastingStateEntitySerialize(
  FastingStateEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.elapsedMilliseconds);
  writer.writeLong(offsets[1], object.goalMilliseconds);
  writer.writeBool(offsets[2], object.isFasting);
  writer.writeString(offsets[3], object.singletonKey);
  writer.writeDateTime(offsets[4], object.startTime);
}

FastingStateEntity _fastingStateEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FastingStateEntity();
  object.elapsedMilliseconds = reader.readLong(offsets[0]);
  object.goalMilliseconds = reader.readLong(offsets[1]);
  object.id = id;
  object.isFasting = reader.readBool(offsets[2]);
  object.singletonKey = reader.readString(offsets[3]);
  object.startTime = reader.readDateTimeOrNull(offsets[4]);
  return object;
}

P _fastingStateEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _fastingStateEntityGetId(FastingStateEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _fastingStateEntityGetLinks(
    FastingStateEntity object) {
  return [];
}

void _fastingStateEntityAttach(
    IsarCollection<dynamic> col, Id id, FastingStateEntity object) {
  object.id = id;
}

extension FastingStateEntityByIndex on IsarCollection<FastingStateEntity> {
  Future<FastingStateEntity?> getBySingletonKey(String singletonKey) {
    return getByIndex(r'singletonKey', [singletonKey]);
  }

  FastingStateEntity? getBySingletonKeySync(String singletonKey) {
    return getByIndexSync(r'singletonKey', [singletonKey]);
  }

  Future<bool> deleteBySingletonKey(String singletonKey) {
    return deleteByIndex(r'singletonKey', [singletonKey]);
  }

  bool deleteBySingletonKeySync(String singletonKey) {
    return deleteByIndexSync(r'singletonKey', [singletonKey]);
  }

  Future<List<FastingStateEntity?>> getAllBySingletonKey(
      List<String> singletonKeyValues) {
    final values = singletonKeyValues.map((e) => [e]).toList();
    return getAllByIndex(r'singletonKey', values);
  }

  List<FastingStateEntity?> getAllBySingletonKeySync(
      List<String> singletonKeyValues) {
    final values = singletonKeyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'singletonKey', values);
  }

  Future<int> deleteAllBySingletonKey(List<String> singletonKeyValues) {
    final values = singletonKeyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'singletonKey', values);
  }

  int deleteAllBySingletonKeySync(List<String> singletonKeyValues) {
    final values = singletonKeyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'singletonKey', values);
  }

  Future<Id> putBySingletonKey(FastingStateEntity object) {
    return putByIndex(r'singletonKey', object);
  }

  Id putBySingletonKeySync(FastingStateEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'singletonKey', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllBySingletonKey(List<FastingStateEntity> objects) {
    return putAllByIndex(r'singletonKey', objects);
  }

  List<Id> putAllBySingletonKeySync(List<FastingStateEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'singletonKey', objects, saveLinks: saveLinks);
  }
}

extension FastingStateEntityQueryWhereSort
    on QueryBuilder<FastingStateEntity, FastingStateEntity, QWhere> {
  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension FastingStateEntityQueryWhere
    on QueryBuilder<FastingStateEntity, FastingStateEntity, QWhereClause> {
  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterWhereClause>
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

  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterWhereClause>
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

  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterWhereClause>
      singletonKeyEqualTo(String singletonKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'singletonKey',
        value: [singletonKey],
      ));
    });
  }

  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterWhereClause>
      singletonKeyNotEqualTo(String singletonKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'singletonKey',
              lower: [],
              upper: [singletonKey],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'singletonKey',
              lower: [singletonKey],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'singletonKey',
              lower: [singletonKey],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'singletonKey',
              lower: [],
              upper: [singletonKey],
              includeUpper: false,
            ));
      }
    });
  }
}

extension FastingStateEntityQueryFilter
    on QueryBuilder<FastingStateEntity, FastingStateEntity, QFilterCondition> {
  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterFilterCondition>
      elapsedMillisecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'elapsedMilliseconds',
        value: value,
      ));
    });
  }

  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterFilterCondition>
      elapsedMillisecondsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'elapsedMilliseconds',
        value: value,
      ));
    });
  }

  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterFilterCondition>
      elapsedMillisecondsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'elapsedMilliseconds',
        value: value,
      ));
    });
  }

  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterFilterCondition>
      elapsedMillisecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'elapsedMilliseconds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterFilterCondition>
      goalMillisecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'goalMilliseconds',
        value: value,
      ));
    });
  }

  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterFilterCondition>
      goalMillisecondsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'goalMilliseconds',
        value: value,
      ));
    });
  }

  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterFilterCondition>
      goalMillisecondsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'goalMilliseconds',
        value: value,
      ));
    });
  }

  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterFilterCondition>
      goalMillisecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'goalMilliseconds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterFilterCondition>
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

  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterFilterCondition>
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

  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterFilterCondition>
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

  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterFilterCondition>
      isFastingEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isFasting',
        value: value,
      ));
    });
  }

  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterFilterCondition>
      singletonKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'singletonKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterFilterCondition>
      singletonKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'singletonKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterFilterCondition>
      singletonKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'singletonKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterFilterCondition>
      singletonKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'singletonKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterFilterCondition>
      singletonKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'singletonKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterFilterCondition>
      singletonKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'singletonKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterFilterCondition>
      singletonKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'singletonKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterFilterCondition>
      singletonKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'singletonKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterFilterCondition>
      singletonKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'singletonKey',
        value: '',
      ));
    });
  }

  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterFilterCondition>
      singletonKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'singletonKey',
        value: '',
      ));
    });
  }

  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterFilterCondition>
      startTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'startTime',
      ));
    });
  }

  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterFilterCondition>
      startTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'startTime',
      ));
    });
  }

  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterFilterCondition>
      startTimeEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startTime',
        value: value,
      ));
    });
  }

  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterFilterCondition>
      startTimeGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startTime',
        value: value,
      ));
    });
  }

  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterFilterCondition>
      startTimeLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startTime',
        value: value,
      ));
    });
  }

  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterFilterCondition>
      startTimeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension FastingStateEntityQueryObject
    on QueryBuilder<FastingStateEntity, FastingStateEntity, QFilterCondition> {}

extension FastingStateEntityQueryLinks
    on QueryBuilder<FastingStateEntity, FastingStateEntity, QFilterCondition> {}

extension FastingStateEntityQuerySortBy
    on QueryBuilder<FastingStateEntity, FastingStateEntity, QSortBy> {
  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterSortBy>
      sortByElapsedMilliseconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'elapsedMilliseconds', Sort.asc);
    });
  }

  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterSortBy>
      sortByElapsedMillisecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'elapsedMilliseconds', Sort.desc);
    });
  }

  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterSortBy>
      sortByGoalMilliseconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalMilliseconds', Sort.asc);
    });
  }

  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterSortBy>
      sortByGoalMillisecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalMilliseconds', Sort.desc);
    });
  }

  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterSortBy>
      sortByIsFasting() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFasting', Sort.asc);
    });
  }

  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterSortBy>
      sortByIsFastingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFasting', Sort.desc);
    });
  }

  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterSortBy>
      sortBySingletonKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'singletonKey', Sort.asc);
    });
  }

  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterSortBy>
      sortBySingletonKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'singletonKey', Sort.desc);
    });
  }

  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterSortBy>
      sortByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.asc);
    });
  }

  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterSortBy>
      sortByStartTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.desc);
    });
  }
}

extension FastingStateEntityQuerySortThenBy
    on QueryBuilder<FastingStateEntity, FastingStateEntity, QSortThenBy> {
  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterSortBy>
      thenByElapsedMilliseconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'elapsedMilliseconds', Sort.asc);
    });
  }

  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterSortBy>
      thenByElapsedMillisecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'elapsedMilliseconds', Sort.desc);
    });
  }

  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterSortBy>
      thenByGoalMilliseconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalMilliseconds', Sort.asc);
    });
  }

  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterSortBy>
      thenByGoalMillisecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalMilliseconds', Sort.desc);
    });
  }

  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterSortBy>
      thenByIsFasting() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFasting', Sort.asc);
    });
  }

  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterSortBy>
      thenByIsFastingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFasting', Sort.desc);
    });
  }

  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterSortBy>
      thenBySingletonKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'singletonKey', Sort.asc);
    });
  }

  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterSortBy>
      thenBySingletonKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'singletonKey', Sort.desc);
    });
  }

  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterSortBy>
      thenByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.asc);
    });
  }

  QueryBuilder<FastingStateEntity, FastingStateEntity, QAfterSortBy>
      thenByStartTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.desc);
    });
  }
}

extension FastingStateEntityQueryWhereDistinct
    on QueryBuilder<FastingStateEntity, FastingStateEntity, QDistinct> {
  QueryBuilder<FastingStateEntity, FastingStateEntity, QDistinct>
      distinctByElapsedMilliseconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'elapsedMilliseconds');
    });
  }

  QueryBuilder<FastingStateEntity, FastingStateEntity, QDistinct>
      distinctByGoalMilliseconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'goalMilliseconds');
    });
  }

  QueryBuilder<FastingStateEntity, FastingStateEntity, QDistinct>
      distinctByIsFasting() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isFasting');
    });
  }

  QueryBuilder<FastingStateEntity, FastingStateEntity, QDistinct>
      distinctBySingletonKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'singletonKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FastingStateEntity, FastingStateEntity, QDistinct>
      distinctByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startTime');
    });
  }
}

extension FastingStateEntityQueryProperty
    on QueryBuilder<FastingStateEntity, FastingStateEntity, QQueryProperty> {
  QueryBuilder<FastingStateEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<FastingStateEntity, int, QQueryOperations>
      elapsedMillisecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'elapsedMilliseconds');
    });
  }

  QueryBuilder<FastingStateEntity, int, QQueryOperations>
      goalMillisecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'goalMilliseconds');
    });
  }

  QueryBuilder<FastingStateEntity, bool, QQueryOperations> isFastingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isFasting');
    });
  }

  QueryBuilder<FastingStateEntity, String, QQueryOperations>
      singletonKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'singletonKey');
    });
  }

  QueryBuilder<FastingStateEntity, DateTime?, QQueryOperations>
      startTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startTime');
    });
  }
}
