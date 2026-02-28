// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diet_plan_schema.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDietPlanWeekEntityCollection on Isar {
  IsarCollection<DietPlanWeekEntity> get dietPlanWeekEntitys =>
      this.collection();
}

const DietPlanWeekEntitySchema = CollectionSchema(
  name: r'DietPlanWeekEntity',
  id: -6970397006575998306,
  properties: {
    r'planJson': PropertySchema(
      id: 0,
      name: r'planJson',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 1,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'weekStart': PropertySchema(
      id: 2,
      name: r'weekStart',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _dietPlanWeekEntityEstimateSize,
  serialize: _dietPlanWeekEntitySerialize,
  deserialize: _dietPlanWeekEntityDeserialize,
  deserializeProp: _dietPlanWeekEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'weekStart': IndexSchema(
      id: 6730028936290595099,
      name: r'weekStart',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'weekStart',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _dietPlanWeekEntityGetId,
  getLinks: _dietPlanWeekEntityGetLinks,
  attach: _dietPlanWeekEntityAttach,
  version: '3.1.0+1',
);

int _dietPlanWeekEntityEstimateSize(
  DietPlanWeekEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.planJson.length * 3;
  return bytesCount;
}

void _dietPlanWeekEntitySerialize(
  DietPlanWeekEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.planJson);
  writer.writeDateTime(offsets[1], object.updatedAt);
  writer.writeDateTime(offsets[2], object.weekStart);
}

DietPlanWeekEntity _dietPlanWeekEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DietPlanWeekEntity();
  object.id = id;
  object.planJson = reader.readString(offsets[0]);
  object.updatedAt = reader.readDateTime(offsets[1]);
  object.weekStart = reader.readDateTime(offsets[2]);
  return object;
}

P _dietPlanWeekEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _dietPlanWeekEntityGetId(DietPlanWeekEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _dietPlanWeekEntityGetLinks(
    DietPlanWeekEntity object) {
  return [];
}

void _dietPlanWeekEntityAttach(
    IsarCollection<dynamic> col, Id id, DietPlanWeekEntity object) {
  object.id = id;
}

extension DietPlanWeekEntityByIndex on IsarCollection<DietPlanWeekEntity> {
  Future<DietPlanWeekEntity?> getByWeekStart(DateTime weekStart) {
    return getByIndex(r'weekStart', [weekStart]);
  }

  DietPlanWeekEntity? getByWeekStartSync(DateTime weekStart) {
    return getByIndexSync(r'weekStart', [weekStart]);
  }

  Future<bool> deleteByWeekStart(DateTime weekStart) {
    return deleteByIndex(r'weekStart', [weekStart]);
  }

  bool deleteByWeekStartSync(DateTime weekStart) {
    return deleteByIndexSync(r'weekStart', [weekStart]);
  }

  Future<List<DietPlanWeekEntity?>> getAllByWeekStart(
      List<DateTime> weekStartValues) {
    final values = weekStartValues.map((e) => [e]).toList();
    return getAllByIndex(r'weekStart', values);
  }

  List<DietPlanWeekEntity?> getAllByWeekStartSync(
      List<DateTime> weekStartValues) {
    final values = weekStartValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'weekStart', values);
  }

  Future<int> deleteAllByWeekStart(List<DateTime> weekStartValues) {
    final values = weekStartValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'weekStart', values);
  }

  int deleteAllByWeekStartSync(List<DateTime> weekStartValues) {
    final values = weekStartValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'weekStart', values);
  }

  Future<Id> putByWeekStart(DietPlanWeekEntity object) {
    return putByIndex(r'weekStart', object);
  }

  Id putByWeekStartSync(DietPlanWeekEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'weekStart', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByWeekStart(List<DietPlanWeekEntity> objects) {
    return putAllByIndex(r'weekStart', objects);
  }

  List<Id> putAllByWeekStartSync(List<DietPlanWeekEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'weekStart', objects, saveLinks: saveLinks);
  }
}

extension DietPlanWeekEntityQueryWhereSort
    on QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QWhere> {
  QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QAfterWhere>
      anyWeekStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'weekStart'),
      );
    });
  }
}

extension DietPlanWeekEntityQueryWhere
    on QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QWhereClause> {
  QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QAfterWhereClause>
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

  QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QAfterWhereClause>
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

  QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QAfterWhereClause>
      weekStartEqualTo(DateTime weekStart) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'weekStart',
        value: [weekStart],
      ));
    });
  }

  QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QAfterWhereClause>
      weekStartNotEqualTo(DateTime weekStart) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'weekStart',
              lower: [],
              upper: [weekStart],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'weekStart',
              lower: [weekStart],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'weekStart',
              lower: [weekStart],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'weekStart',
              lower: [],
              upper: [weekStart],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QAfterWhereClause>
      weekStartGreaterThan(
    DateTime weekStart, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'weekStart',
        lower: [weekStart],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QAfterWhereClause>
      weekStartLessThan(
    DateTime weekStart, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'weekStart',
        lower: [],
        upper: [weekStart],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QAfterWhereClause>
      weekStartBetween(
    DateTime lowerWeekStart,
    DateTime upperWeekStart, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'weekStart',
        lower: [lowerWeekStart],
        includeLower: includeLower,
        upper: [upperWeekStart],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension DietPlanWeekEntityQueryFilter
    on QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QFilterCondition> {
  QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QAfterFilterCondition>
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

  QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QAfterFilterCondition>
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

  QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QAfterFilterCondition>
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

  QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QAfterFilterCondition>
      planJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'planJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QAfterFilterCondition>
      planJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'planJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QAfterFilterCondition>
      planJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'planJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QAfterFilterCondition>
      planJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'planJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QAfterFilterCondition>
      planJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'planJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QAfterFilterCondition>
      planJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'planJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QAfterFilterCondition>
      planJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'planJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QAfterFilterCondition>
      planJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'planJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QAfterFilterCondition>
      planJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'planJson',
        value: '',
      ));
    });
  }

  QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QAfterFilterCondition>
      planJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'planJson',
        value: '',
      ));
    });
  }

  QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QAfterFilterCondition>
      updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QAfterFilterCondition>
      weekStartEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weekStart',
        value: value,
      ));
    });
  }

  QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QAfterFilterCondition>
      weekStartGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'weekStart',
        value: value,
      ));
    });
  }

  QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QAfterFilterCondition>
      weekStartLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'weekStart',
        value: value,
      ));
    });
  }

  QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QAfterFilterCondition>
      weekStartBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'weekStart',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension DietPlanWeekEntityQueryObject
    on QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QFilterCondition> {}

extension DietPlanWeekEntityQueryLinks
    on QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QFilterCondition> {}

extension DietPlanWeekEntityQuerySortBy
    on QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QSortBy> {
  QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QAfterSortBy>
      sortByPlanJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'planJson', Sort.asc);
    });
  }

  QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QAfterSortBy>
      sortByPlanJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'planJson', Sort.desc);
    });
  }

  QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QAfterSortBy>
      sortByWeekStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weekStart', Sort.asc);
    });
  }

  QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QAfterSortBy>
      sortByWeekStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weekStart', Sort.desc);
    });
  }
}

extension DietPlanWeekEntityQuerySortThenBy
    on QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QSortThenBy> {
  QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QAfterSortBy>
      thenByPlanJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'planJson', Sort.asc);
    });
  }

  QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QAfterSortBy>
      thenByPlanJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'planJson', Sort.desc);
    });
  }

  QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QAfterSortBy>
      thenByWeekStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weekStart', Sort.asc);
    });
  }

  QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QAfterSortBy>
      thenByWeekStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weekStart', Sort.desc);
    });
  }
}

extension DietPlanWeekEntityQueryWhereDistinct
    on QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QDistinct> {
  QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QDistinct>
      distinctByPlanJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'planJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QDistinct>
      distinctByWeekStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weekStart');
    });
  }
}

extension DietPlanWeekEntityQueryProperty
    on QueryBuilder<DietPlanWeekEntity, DietPlanWeekEntity, QQueryProperty> {
  QueryBuilder<DietPlanWeekEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DietPlanWeekEntity, String, QQueryOperations>
      planJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'planJson');
    });
  }

  QueryBuilder<DietPlanWeekEntity, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<DietPlanWeekEntity, DateTime, QQueryOperations>
      weekStartProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weekStart');
    });
  }
}
