// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'water_intake_schema.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetWaterIntakeSchemaCollection on Isar {
  IsarCollection<WaterIntakeSchema> get waterIntakeSchemas => this.collection();
}

const WaterIntakeSchemaSchema = CollectionSchema(
  name: r'WaterIntakeSchema',
  id: -2300759216554877403,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'date': PropertySchema(
      id: 1,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'goalMl': PropertySchema(
      id: 2,
      name: r'goalMl',
      type: IsarType.long,
    ),
    r'updatedAt': PropertySchema(
      id: 3,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'volumeMl': PropertySchema(
      id: 4,
      name: r'volumeMl',
      type: IsarType.long,
    )
  },
  estimateSize: _waterIntakeSchemaEstimateSize,
  serialize: _waterIntakeSchemaSerialize,
  deserialize: _waterIntakeSchemaDeserialize,
  deserializeProp: _waterIntakeSchemaDeserializeProp,
  idName: r'id',
  indexes: {
    r'date': IndexSchema(
      id: -7552997827385218417,
      name: r'date',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'date',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _waterIntakeSchemaGetId,
  getLinks: _waterIntakeSchemaGetLinks,
  attach: _waterIntakeSchemaAttach,
  version: '3.1.0+1',
);

int _waterIntakeSchemaEstimateSize(
  WaterIntakeSchema object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _waterIntakeSchemaSerialize(
  WaterIntakeSchema object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeDateTime(offsets[1], object.date);
  writer.writeLong(offsets[2], object.goalMl);
  writer.writeDateTime(offsets[3], object.updatedAt);
  writer.writeLong(offsets[4], object.volumeMl);
}

WaterIntakeSchema _waterIntakeSchemaDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = WaterIntakeSchema();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.date = reader.readDateTime(offsets[1]);
  object.goalMl = reader.readLong(offsets[2]);
  object.id = id;
  object.updatedAt = reader.readDateTime(offsets[3]);
  object.volumeMl = reader.readLong(offsets[4]);
  return object;
}

P _waterIntakeSchemaDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _waterIntakeSchemaGetId(WaterIntakeSchema object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _waterIntakeSchemaGetLinks(
    WaterIntakeSchema object) {
  return [];
}

void _waterIntakeSchemaAttach(
    IsarCollection<dynamic> col, Id id, WaterIntakeSchema object) {
  object.id = id;
}

extension WaterIntakeSchemaByIndex on IsarCollection<WaterIntakeSchema> {
  Future<WaterIntakeSchema?> getByDate(DateTime date) {
    return getByIndex(r'date', [date]);
  }

  WaterIntakeSchema? getByDateSync(DateTime date) {
    return getByIndexSync(r'date', [date]);
  }

  Future<bool> deleteByDate(DateTime date) {
    return deleteByIndex(r'date', [date]);
  }

  bool deleteByDateSync(DateTime date) {
    return deleteByIndexSync(r'date', [date]);
  }

  Future<List<WaterIntakeSchema?>> getAllByDate(List<DateTime> dateValues) {
    final values = dateValues.map((e) => [e]).toList();
    return getAllByIndex(r'date', values);
  }

  List<WaterIntakeSchema?> getAllByDateSync(List<DateTime> dateValues) {
    final values = dateValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'date', values);
  }

  Future<int> deleteAllByDate(List<DateTime> dateValues) {
    final values = dateValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'date', values);
  }

  int deleteAllByDateSync(List<DateTime> dateValues) {
    final values = dateValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'date', values);
  }

  Future<Id> putByDate(WaterIntakeSchema object) {
    return putByIndex(r'date', object);
  }

  Id putByDateSync(WaterIntakeSchema object, {bool saveLinks = true}) {
    return putByIndexSync(r'date', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByDate(List<WaterIntakeSchema> objects) {
    return putAllByIndex(r'date', objects);
  }

  List<Id> putAllByDateSync(List<WaterIntakeSchema> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'date', objects, saveLinks: saveLinks);
  }
}

extension WaterIntakeSchemaQueryWhereSort
    on QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QWhere> {
  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterWhere> anyDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'date'),
      );
    });
  }
}

extension WaterIntakeSchemaQueryWhere
    on QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QWhereClause> {
  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterWhereClause>
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

  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterWhereClause>
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

  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterWhereClause>
      dateEqualTo(DateTime date) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'date',
        value: [date],
      ));
    });
  }

  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterWhereClause>
      dateNotEqualTo(DateTime date) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterWhereClause>
      dateGreaterThan(
    DateTime date, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [date],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterWhereClause>
      dateLessThan(
    DateTime date, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [],
        upper: [date],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterWhereClause>
      dateBetween(
    DateTime lowerDate,
    DateTime upperDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [lowerDate],
        includeLower: includeLower,
        upper: [upperDate],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension WaterIntakeSchemaQueryFilter
    on QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QFilterCondition> {
  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterFilterCondition>
      dateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterFilterCondition>
      dateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterFilterCondition>
      dateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterFilterCondition>
      dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterFilterCondition>
      goalMlEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'goalMl',
        value: value,
      ));
    });
  }

  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterFilterCondition>
      goalMlGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'goalMl',
        value: value,
      ));
    });
  }

  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterFilterCondition>
      goalMlLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'goalMl',
        value: value,
      ));
    });
  }

  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterFilterCondition>
      goalMlBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'goalMl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterFilterCondition>
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

  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterFilterCondition>
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

  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterFilterCondition>
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

  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterFilterCondition>
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

  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterFilterCondition>
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

  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterFilterCondition>
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

  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterFilterCondition>
      volumeMlEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'volumeMl',
        value: value,
      ));
    });
  }

  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterFilterCondition>
      volumeMlGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'volumeMl',
        value: value,
      ));
    });
  }

  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterFilterCondition>
      volumeMlLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'volumeMl',
        value: value,
      ));
    });
  }

  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterFilterCondition>
      volumeMlBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'volumeMl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension WaterIntakeSchemaQueryObject
    on QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QFilterCondition> {}

extension WaterIntakeSchemaQueryLinks
    on QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QFilterCondition> {}

extension WaterIntakeSchemaQuerySortBy
    on QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QSortBy> {
  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterSortBy>
      sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterSortBy>
      sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterSortBy>
      sortByGoalMl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalMl', Sort.asc);
    });
  }

  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterSortBy>
      sortByGoalMlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalMl', Sort.desc);
    });
  }

  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterSortBy>
      sortByVolumeMl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'volumeMl', Sort.asc);
    });
  }

  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterSortBy>
      sortByVolumeMlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'volumeMl', Sort.desc);
    });
  }
}

extension WaterIntakeSchemaQuerySortThenBy
    on QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QSortThenBy> {
  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterSortBy>
      thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterSortBy>
      thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterSortBy>
      thenByGoalMl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalMl', Sort.asc);
    });
  }

  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterSortBy>
      thenByGoalMlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalMl', Sort.desc);
    });
  }

  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterSortBy>
      thenByVolumeMl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'volumeMl', Sort.asc);
    });
  }

  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QAfterSortBy>
      thenByVolumeMlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'volumeMl', Sort.desc);
    });
  }
}

extension WaterIntakeSchemaQueryWhereDistinct
    on QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QDistinct> {
  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QDistinct>
      distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QDistinct>
      distinctByGoalMl() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'goalMl');
    });
  }

  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QDistinct>
      distinctByVolumeMl() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'volumeMl');
    });
  }
}

extension WaterIntakeSchemaQueryProperty
    on QueryBuilder<WaterIntakeSchema, WaterIntakeSchema, QQueryProperty> {
  QueryBuilder<WaterIntakeSchema, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<WaterIntakeSchema, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<WaterIntakeSchema, DateTime, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<WaterIntakeSchema, int, QQueryOperations> goalMlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'goalMl');
    });
  }

  QueryBuilder<WaterIntakeSchema, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<WaterIntakeSchema, int, QQueryOperations> volumeMlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'volumeMl');
    });
  }
}
