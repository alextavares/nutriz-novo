// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gamification_schemas.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUserLevelSchemaCollection on Isar {
  IsarCollection<UserLevelSchema> get userLevelSchemas => this.collection();
}

const UserLevelSchemaSchema = CollectionSchema(
  name: r'UserLevelSchema',
  id: 6007561669503343416,
  properties: {
    r'currentLevel': PropertySchema(
      id: 0,
      name: r'currentLevel',
      type: IsarType.long,
    ),
    r'currentXp': PropertySchema(
      id: 1,
      name: r'currentXp',
      type: IsarType.long,
    ),
    r'title': PropertySchema(
      id: 2,
      name: r'title',
      type: IsarType.string,
    ),
    r'xpToNextLevel': PropertySchema(
      id: 3,
      name: r'xpToNextLevel',
      type: IsarType.long,
    )
  },
  estimateSize: _userLevelSchemaEstimateSize,
  serialize: _userLevelSchemaSerialize,
  deserialize: _userLevelSchemaDeserialize,
  deserializeProp: _userLevelSchemaDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _userLevelSchemaGetId,
  getLinks: _userLevelSchemaGetLinks,
  attach: _userLevelSchemaAttach,
  version: '3.1.0+1',
);

int _userLevelSchemaEstimateSize(
  UserLevelSchema object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _userLevelSchemaSerialize(
  UserLevelSchema object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.currentLevel);
  writer.writeLong(offsets[1], object.currentXp);
  writer.writeString(offsets[2], object.title);
  writer.writeLong(offsets[3], object.xpToNextLevel);
}

UserLevelSchema _userLevelSchemaDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UserLevelSchema();
  object.currentLevel = reader.readLong(offsets[0]);
  object.currentXp = reader.readLong(offsets[1]);
  object.id = id;
  object.title = reader.readString(offsets[2]);
  object.xpToNextLevel = reader.readLong(offsets[3]);
  return object;
}

P _userLevelSchemaDeserializeProp<P>(
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
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _userLevelSchemaGetId(UserLevelSchema object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _userLevelSchemaGetLinks(UserLevelSchema object) {
  return [];
}

void _userLevelSchemaAttach(
    IsarCollection<dynamic> col, Id id, UserLevelSchema object) {
  object.id = id;
}

extension UserLevelSchemaQueryWhereSort
    on QueryBuilder<UserLevelSchema, UserLevelSchema, QWhere> {
  QueryBuilder<UserLevelSchema, UserLevelSchema, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension UserLevelSchemaQueryWhere
    on QueryBuilder<UserLevelSchema, UserLevelSchema, QWhereClause> {
  QueryBuilder<UserLevelSchema, UserLevelSchema, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<UserLevelSchema, UserLevelSchema, QAfterWhereClause>
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

  QueryBuilder<UserLevelSchema, UserLevelSchema, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UserLevelSchema, UserLevelSchema, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UserLevelSchema, UserLevelSchema, QAfterWhereClause> idBetween(
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

extension UserLevelSchemaQueryFilter
    on QueryBuilder<UserLevelSchema, UserLevelSchema, QFilterCondition> {
  QueryBuilder<UserLevelSchema, UserLevelSchema, QAfterFilterCondition>
      currentLevelEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<UserLevelSchema, UserLevelSchema, QAfterFilterCondition>
      currentLevelGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<UserLevelSchema, UserLevelSchema, QAfterFilterCondition>
      currentLevelLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<UserLevelSchema, UserLevelSchema, QAfterFilterCondition>
      currentLevelBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentLevel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserLevelSchema, UserLevelSchema, QAfterFilterCondition>
      currentXpEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentXp',
        value: value,
      ));
    });
  }

  QueryBuilder<UserLevelSchema, UserLevelSchema, QAfterFilterCondition>
      currentXpGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentXp',
        value: value,
      ));
    });
  }

  QueryBuilder<UserLevelSchema, UserLevelSchema, QAfterFilterCondition>
      currentXpLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentXp',
        value: value,
      ));
    });
  }

  QueryBuilder<UserLevelSchema, UserLevelSchema, QAfterFilterCondition>
      currentXpBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentXp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserLevelSchema, UserLevelSchema, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UserLevelSchema, UserLevelSchema, QAfterFilterCondition>
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

  QueryBuilder<UserLevelSchema, UserLevelSchema, QAfterFilterCondition>
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

  QueryBuilder<UserLevelSchema, UserLevelSchema, QAfterFilterCondition>
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

  QueryBuilder<UserLevelSchema, UserLevelSchema, QAfterFilterCondition>
      titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserLevelSchema, UserLevelSchema, QAfterFilterCondition>
      titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserLevelSchema, UserLevelSchema, QAfterFilterCondition>
      titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserLevelSchema, UserLevelSchema, QAfterFilterCondition>
      titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserLevelSchema, UserLevelSchema, QAfterFilterCondition>
      titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserLevelSchema, UserLevelSchema, QAfterFilterCondition>
      titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserLevelSchema, UserLevelSchema, QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserLevelSchema, UserLevelSchema, QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserLevelSchema, UserLevelSchema, QAfterFilterCondition>
      titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<UserLevelSchema, UserLevelSchema, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<UserLevelSchema, UserLevelSchema, QAfterFilterCondition>
      xpToNextLevelEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'xpToNextLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<UserLevelSchema, UserLevelSchema, QAfterFilterCondition>
      xpToNextLevelGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'xpToNextLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<UserLevelSchema, UserLevelSchema, QAfterFilterCondition>
      xpToNextLevelLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'xpToNextLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<UserLevelSchema, UserLevelSchema, QAfterFilterCondition>
      xpToNextLevelBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'xpToNextLevel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension UserLevelSchemaQueryObject
    on QueryBuilder<UserLevelSchema, UserLevelSchema, QFilterCondition> {}

extension UserLevelSchemaQueryLinks
    on QueryBuilder<UserLevelSchema, UserLevelSchema, QFilterCondition> {}

extension UserLevelSchemaQuerySortBy
    on QueryBuilder<UserLevelSchema, UserLevelSchema, QSortBy> {
  QueryBuilder<UserLevelSchema, UserLevelSchema, QAfterSortBy>
      sortByCurrentLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentLevel', Sort.asc);
    });
  }

  QueryBuilder<UserLevelSchema, UserLevelSchema, QAfterSortBy>
      sortByCurrentLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentLevel', Sort.desc);
    });
  }

  QueryBuilder<UserLevelSchema, UserLevelSchema, QAfterSortBy>
      sortByCurrentXp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentXp', Sort.asc);
    });
  }

  QueryBuilder<UserLevelSchema, UserLevelSchema, QAfterSortBy>
      sortByCurrentXpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentXp', Sort.desc);
    });
  }

  QueryBuilder<UserLevelSchema, UserLevelSchema, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<UserLevelSchema, UserLevelSchema, QAfterSortBy>
      sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<UserLevelSchema, UserLevelSchema, QAfterSortBy>
      sortByXpToNextLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xpToNextLevel', Sort.asc);
    });
  }

  QueryBuilder<UserLevelSchema, UserLevelSchema, QAfterSortBy>
      sortByXpToNextLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xpToNextLevel', Sort.desc);
    });
  }
}

extension UserLevelSchemaQuerySortThenBy
    on QueryBuilder<UserLevelSchema, UserLevelSchema, QSortThenBy> {
  QueryBuilder<UserLevelSchema, UserLevelSchema, QAfterSortBy>
      thenByCurrentLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentLevel', Sort.asc);
    });
  }

  QueryBuilder<UserLevelSchema, UserLevelSchema, QAfterSortBy>
      thenByCurrentLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentLevel', Sort.desc);
    });
  }

  QueryBuilder<UserLevelSchema, UserLevelSchema, QAfterSortBy>
      thenByCurrentXp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentXp', Sort.asc);
    });
  }

  QueryBuilder<UserLevelSchema, UserLevelSchema, QAfterSortBy>
      thenByCurrentXpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentXp', Sort.desc);
    });
  }

  QueryBuilder<UserLevelSchema, UserLevelSchema, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UserLevelSchema, UserLevelSchema, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UserLevelSchema, UserLevelSchema, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<UserLevelSchema, UserLevelSchema, QAfterSortBy>
      thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<UserLevelSchema, UserLevelSchema, QAfterSortBy>
      thenByXpToNextLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xpToNextLevel', Sort.asc);
    });
  }

  QueryBuilder<UserLevelSchema, UserLevelSchema, QAfterSortBy>
      thenByXpToNextLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xpToNextLevel', Sort.desc);
    });
  }
}

extension UserLevelSchemaQueryWhereDistinct
    on QueryBuilder<UserLevelSchema, UserLevelSchema, QDistinct> {
  QueryBuilder<UserLevelSchema, UserLevelSchema, QDistinct>
      distinctByCurrentLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentLevel');
    });
  }

  QueryBuilder<UserLevelSchema, UserLevelSchema, QDistinct>
      distinctByCurrentXp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentXp');
    });
  }

  QueryBuilder<UserLevelSchema, UserLevelSchema, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserLevelSchema, UserLevelSchema, QDistinct>
      distinctByXpToNextLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'xpToNextLevel');
    });
  }
}

extension UserLevelSchemaQueryProperty
    on QueryBuilder<UserLevelSchema, UserLevelSchema, QQueryProperty> {
  QueryBuilder<UserLevelSchema, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UserLevelSchema, int, QQueryOperations> currentLevelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentLevel');
    });
  }

  QueryBuilder<UserLevelSchema, int, QQueryOperations> currentXpProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentXp');
    });
  }

  QueryBuilder<UserLevelSchema, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<UserLevelSchema, int, QQueryOperations> xpToNextLevelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'xpToNextLevel');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetStreakSchemaCollection on Isar {
  IsarCollection<StreakSchema> get streakSchemas => this.collection();
}

const StreakSchemaSchema = CollectionSchema(
  name: r'StreakSchema',
  id: -8368118499045038877,
  properties: {
    r'bestStreak': PropertySchema(
      id: 0,
      name: r'bestStreak',
      type: IsarType.long,
    ),
    r'currentStreak': PropertySchema(
      id: 1,
      name: r'currentStreak',
      type: IsarType.long,
    ),
    r'frozenDays': PropertySchema(
      id: 2,
      name: r'frozenDays',
      type: IsarType.dateTimeList,
    ),
    r'lastActivityDate': PropertySchema(
      id: 3,
      name: r'lastActivityDate',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _streakSchemaEstimateSize,
  serialize: _streakSchemaSerialize,
  deserialize: _streakSchemaDeserialize,
  deserializeProp: _streakSchemaDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _streakSchemaGetId,
  getLinks: _streakSchemaGetLinks,
  attach: _streakSchemaAttach,
  version: '3.1.0+1',
);

int _streakSchemaEstimateSize(
  StreakSchema object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.frozenDays.length * 8;
  return bytesCount;
}

void _streakSchemaSerialize(
  StreakSchema object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.bestStreak);
  writer.writeLong(offsets[1], object.currentStreak);
  writer.writeDateTimeList(offsets[2], object.frozenDays);
  writer.writeDateTime(offsets[3], object.lastActivityDate);
}

StreakSchema _streakSchemaDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = StreakSchema();
  object.bestStreak = reader.readLong(offsets[0]);
  object.currentStreak = reader.readLong(offsets[1]);
  object.frozenDays = reader.readDateTimeList(offsets[2]) ?? [];
  object.id = id;
  object.lastActivityDate = reader.readDateTime(offsets[3]);
  return object;
}

P _streakSchemaDeserializeProp<P>(
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
      return (reader.readDateTimeList(offset) ?? []) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _streakSchemaGetId(StreakSchema object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _streakSchemaGetLinks(StreakSchema object) {
  return [];
}

void _streakSchemaAttach(
    IsarCollection<dynamic> col, Id id, StreakSchema object) {
  object.id = id;
}

extension StreakSchemaQueryWhereSort
    on QueryBuilder<StreakSchema, StreakSchema, QWhere> {
  QueryBuilder<StreakSchema, StreakSchema, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension StreakSchemaQueryWhere
    on QueryBuilder<StreakSchema, StreakSchema, QWhereClause> {
  QueryBuilder<StreakSchema, StreakSchema, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<StreakSchema, StreakSchema, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<StreakSchema, StreakSchema, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<StreakSchema, StreakSchema, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<StreakSchema, StreakSchema, QAfterWhereClause> idBetween(
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

extension StreakSchemaQueryFilter
    on QueryBuilder<StreakSchema, StreakSchema, QFilterCondition> {
  QueryBuilder<StreakSchema, StreakSchema, QAfterFilterCondition>
      bestStreakEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bestStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<StreakSchema, StreakSchema, QAfterFilterCondition>
      bestStreakGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bestStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<StreakSchema, StreakSchema, QAfterFilterCondition>
      bestStreakLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bestStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<StreakSchema, StreakSchema, QAfterFilterCondition>
      bestStreakBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bestStreak',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<StreakSchema, StreakSchema, QAfterFilterCondition>
      currentStreakEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<StreakSchema, StreakSchema, QAfterFilterCondition>
      currentStreakGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<StreakSchema, StreakSchema, QAfterFilterCondition>
      currentStreakLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<StreakSchema, StreakSchema, QAfterFilterCondition>
      currentStreakBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentStreak',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<StreakSchema, StreakSchema, QAfterFilterCondition>
      frozenDaysElementEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'frozenDays',
        value: value,
      ));
    });
  }

  QueryBuilder<StreakSchema, StreakSchema, QAfterFilterCondition>
      frozenDaysElementGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'frozenDays',
        value: value,
      ));
    });
  }

  QueryBuilder<StreakSchema, StreakSchema, QAfterFilterCondition>
      frozenDaysElementLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'frozenDays',
        value: value,
      ));
    });
  }

  QueryBuilder<StreakSchema, StreakSchema, QAfterFilterCondition>
      frozenDaysElementBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'frozenDays',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<StreakSchema, StreakSchema, QAfterFilterCondition>
      frozenDaysLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'frozenDays',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<StreakSchema, StreakSchema, QAfterFilterCondition>
      frozenDaysIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'frozenDays',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<StreakSchema, StreakSchema, QAfterFilterCondition>
      frozenDaysIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'frozenDays',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<StreakSchema, StreakSchema, QAfterFilterCondition>
      frozenDaysLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'frozenDays',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<StreakSchema, StreakSchema, QAfterFilterCondition>
      frozenDaysLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'frozenDays',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<StreakSchema, StreakSchema, QAfterFilterCondition>
      frozenDaysLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'frozenDays',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<StreakSchema, StreakSchema, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<StreakSchema, StreakSchema, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<StreakSchema, StreakSchema, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<StreakSchema, StreakSchema, QAfterFilterCondition> idBetween(
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

  QueryBuilder<StreakSchema, StreakSchema, QAfterFilterCondition>
      lastActivityDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastActivityDate',
        value: value,
      ));
    });
  }

  QueryBuilder<StreakSchema, StreakSchema, QAfterFilterCondition>
      lastActivityDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastActivityDate',
        value: value,
      ));
    });
  }

  QueryBuilder<StreakSchema, StreakSchema, QAfterFilterCondition>
      lastActivityDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastActivityDate',
        value: value,
      ));
    });
  }

  QueryBuilder<StreakSchema, StreakSchema, QAfterFilterCondition>
      lastActivityDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastActivityDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension StreakSchemaQueryObject
    on QueryBuilder<StreakSchema, StreakSchema, QFilterCondition> {}

extension StreakSchemaQueryLinks
    on QueryBuilder<StreakSchema, StreakSchema, QFilterCondition> {}

extension StreakSchemaQuerySortBy
    on QueryBuilder<StreakSchema, StreakSchema, QSortBy> {
  QueryBuilder<StreakSchema, StreakSchema, QAfterSortBy> sortByBestStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bestStreak', Sort.asc);
    });
  }

  QueryBuilder<StreakSchema, StreakSchema, QAfterSortBy>
      sortByBestStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bestStreak', Sort.desc);
    });
  }

  QueryBuilder<StreakSchema, StreakSchema, QAfterSortBy> sortByCurrentStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreak', Sort.asc);
    });
  }

  QueryBuilder<StreakSchema, StreakSchema, QAfterSortBy>
      sortByCurrentStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreak', Sort.desc);
    });
  }

  QueryBuilder<StreakSchema, StreakSchema, QAfterSortBy>
      sortByLastActivityDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastActivityDate', Sort.asc);
    });
  }

  QueryBuilder<StreakSchema, StreakSchema, QAfterSortBy>
      sortByLastActivityDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastActivityDate', Sort.desc);
    });
  }
}

extension StreakSchemaQuerySortThenBy
    on QueryBuilder<StreakSchema, StreakSchema, QSortThenBy> {
  QueryBuilder<StreakSchema, StreakSchema, QAfterSortBy> thenByBestStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bestStreak', Sort.asc);
    });
  }

  QueryBuilder<StreakSchema, StreakSchema, QAfterSortBy>
      thenByBestStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bestStreak', Sort.desc);
    });
  }

  QueryBuilder<StreakSchema, StreakSchema, QAfterSortBy> thenByCurrentStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreak', Sort.asc);
    });
  }

  QueryBuilder<StreakSchema, StreakSchema, QAfterSortBy>
      thenByCurrentStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreak', Sort.desc);
    });
  }

  QueryBuilder<StreakSchema, StreakSchema, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<StreakSchema, StreakSchema, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<StreakSchema, StreakSchema, QAfterSortBy>
      thenByLastActivityDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastActivityDate', Sort.asc);
    });
  }

  QueryBuilder<StreakSchema, StreakSchema, QAfterSortBy>
      thenByLastActivityDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastActivityDate', Sort.desc);
    });
  }
}

extension StreakSchemaQueryWhereDistinct
    on QueryBuilder<StreakSchema, StreakSchema, QDistinct> {
  QueryBuilder<StreakSchema, StreakSchema, QDistinct> distinctByBestStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bestStreak');
    });
  }

  QueryBuilder<StreakSchema, StreakSchema, QDistinct>
      distinctByCurrentStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentStreak');
    });
  }

  QueryBuilder<StreakSchema, StreakSchema, QDistinct> distinctByFrozenDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'frozenDays');
    });
  }

  QueryBuilder<StreakSchema, StreakSchema, QDistinct>
      distinctByLastActivityDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastActivityDate');
    });
  }
}

extension StreakSchemaQueryProperty
    on QueryBuilder<StreakSchema, StreakSchema, QQueryProperty> {
  QueryBuilder<StreakSchema, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<StreakSchema, int, QQueryOperations> bestStreakProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bestStreak');
    });
  }

  QueryBuilder<StreakSchema, int, QQueryOperations> currentStreakProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentStreak');
    });
  }

  QueryBuilder<StreakSchema, List<DateTime>, QQueryOperations>
      frozenDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'frozenDays');
    });
  }

  QueryBuilder<StreakSchema, DateTime, QQueryOperations>
      lastActivityDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastActivityDate');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAchievementSchemaCollection on Isar {
  IsarCollection<AchievementSchema> get achievementSchemas => this.collection();
}

const AchievementSchemaSchema = CollectionSchema(
  name: r'AchievementSchema',
  id: 7698302722180940375,
  properties: {
    r'achievementId': PropertySchema(
      id: 0,
      name: r'achievementId',
      type: IsarType.string,
    ),
    r'description': PropertySchema(
      id: 1,
      name: r'description',
      type: IsarType.string,
    ),
    r'iconPath': PropertySchema(
      id: 2,
      name: r'iconPath',
      type: IsarType.string,
    ),
    r'isSecret': PropertySchema(
      id: 3,
      name: r'isSecret',
      type: IsarType.bool,
    ),
    r'isUnlocked': PropertySchema(
      id: 4,
      name: r'isUnlocked',
      type: IsarType.bool,
    ),
    r'maxProgress': PropertySchema(
      id: 5,
      name: r'maxProgress',
      type: IsarType.long,
    ),
    r'progress': PropertySchema(
      id: 6,
      name: r'progress',
      type: IsarType.long,
    ),
    r'title': PropertySchema(
      id: 7,
      name: r'title',
      type: IsarType.string,
    ),
    r'unlockedAt': PropertySchema(
      id: 8,
      name: r'unlockedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _achievementSchemaEstimateSize,
  serialize: _achievementSchemaSerialize,
  deserialize: _achievementSchemaDeserialize,
  deserializeProp: _achievementSchemaDeserializeProp,
  idName: r'id',
  indexes: {
    r'achievementId': IndexSchema(
      id: 547487615361511857,
      name: r'achievementId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'achievementId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _achievementSchemaGetId,
  getLinks: _achievementSchemaGetLinks,
  attach: _achievementSchemaAttach,
  version: '3.1.0+1',
);

int _achievementSchemaEstimateSize(
  AchievementSchema object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.achievementId.length * 3;
  bytesCount += 3 + object.description.length * 3;
  bytesCount += 3 + object.iconPath.length * 3;
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _achievementSchemaSerialize(
  AchievementSchema object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.achievementId);
  writer.writeString(offsets[1], object.description);
  writer.writeString(offsets[2], object.iconPath);
  writer.writeBool(offsets[3], object.isSecret);
  writer.writeBool(offsets[4], object.isUnlocked);
  writer.writeLong(offsets[5], object.maxProgress);
  writer.writeLong(offsets[6], object.progress);
  writer.writeString(offsets[7], object.title);
  writer.writeDateTime(offsets[8], object.unlockedAt);
}

AchievementSchema _achievementSchemaDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AchievementSchema();
  object.achievementId = reader.readString(offsets[0]);
  object.description = reader.readString(offsets[1]);
  object.iconPath = reader.readString(offsets[2]);
  object.id = id;
  object.isSecret = reader.readBool(offsets[3]);
  object.isUnlocked = reader.readBool(offsets[4]);
  object.maxProgress = reader.readLong(offsets[5]);
  object.progress = reader.readLong(offsets[6]);
  object.title = reader.readString(offsets[7]);
  object.unlockedAt = reader.readDateTimeOrNull(offsets[8]);
  return object;
}

P _achievementSchemaDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _achievementSchemaGetId(AchievementSchema object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _achievementSchemaGetLinks(
    AchievementSchema object) {
  return [];
}

void _achievementSchemaAttach(
    IsarCollection<dynamic> col, Id id, AchievementSchema object) {
  object.id = id;
}

extension AchievementSchemaByIndex on IsarCollection<AchievementSchema> {
  Future<AchievementSchema?> getByAchievementId(String achievementId) {
    return getByIndex(r'achievementId', [achievementId]);
  }

  AchievementSchema? getByAchievementIdSync(String achievementId) {
    return getByIndexSync(r'achievementId', [achievementId]);
  }

  Future<bool> deleteByAchievementId(String achievementId) {
    return deleteByIndex(r'achievementId', [achievementId]);
  }

  bool deleteByAchievementIdSync(String achievementId) {
    return deleteByIndexSync(r'achievementId', [achievementId]);
  }

  Future<List<AchievementSchema?>> getAllByAchievementId(
      List<String> achievementIdValues) {
    final values = achievementIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'achievementId', values);
  }

  List<AchievementSchema?> getAllByAchievementIdSync(
      List<String> achievementIdValues) {
    final values = achievementIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'achievementId', values);
  }

  Future<int> deleteAllByAchievementId(List<String> achievementIdValues) {
    final values = achievementIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'achievementId', values);
  }

  int deleteAllByAchievementIdSync(List<String> achievementIdValues) {
    final values = achievementIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'achievementId', values);
  }

  Future<Id> putByAchievementId(AchievementSchema object) {
    return putByIndex(r'achievementId', object);
  }

  Id putByAchievementIdSync(AchievementSchema object, {bool saveLinks = true}) {
    return putByIndexSync(r'achievementId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByAchievementId(List<AchievementSchema> objects) {
    return putAllByIndex(r'achievementId', objects);
  }

  List<Id> putAllByAchievementIdSync(List<AchievementSchema> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'achievementId', objects, saveLinks: saveLinks);
  }
}

extension AchievementSchemaQueryWhereSort
    on QueryBuilder<AchievementSchema, AchievementSchema, QWhere> {
  QueryBuilder<AchievementSchema, AchievementSchema, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AchievementSchemaQueryWhere
    on QueryBuilder<AchievementSchema, AchievementSchema, QWhereClause> {
  QueryBuilder<AchievementSchema, AchievementSchema, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterWhereClause>
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

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterWhereClause>
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

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterWhereClause>
      achievementIdEqualTo(String achievementId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'achievementId',
        value: [achievementId],
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterWhereClause>
      achievementIdNotEqualTo(String achievementId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'achievementId',
              lower: [],
              upper: [achievementId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'achievementId',
              lower: [achievementId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'achievementId',
              lower: [achievementId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'achievementId',
              lower: [],
              upper: [achievementId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension AchievementSchemaQueryFilter
    on QueryBuilder<AchievementSchema, AchievementSchema, QFilterCondition> {
  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      achievementIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'achievementId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      achievementIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'achievementId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      achievementIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'achievementId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      achievementIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'achievementId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      achievementIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'achievementId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      achievementIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'achievementId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      achievementIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'achievementId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      achievementIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'achievementId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      achievementIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'achievementId',
        value: '',
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      achievementIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'achievementId',
        value: '',
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      descriptionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      descriptionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      descriptionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      descriptionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      iconPathEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'iconPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      iconPathGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'iconPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      iconPathLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'iconPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      iconPathBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'iconPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      iconPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'iconPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      iconPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'iconPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      iconPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'iconPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      iconPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'iconPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      iconPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'iconPath',
        value: '',
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      iconPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'iconPath',
        value: '',
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
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

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
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

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
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

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      isSecretEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSecret',
        value: value,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      isUnlockedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isUnlocked',
        value: value,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      maxProgressEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maxProgress',
        value: value,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      maxProgressGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'maxProgress',
        value: value,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      maxProgressLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'maxProgress',
        value: value,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      maxProgressBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'maxProgress',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      progressEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'progress',
        value: value,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      progressGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'progress',
        value: value,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      progressLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'progress',
        value: value,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      progressBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'progress',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      unlockedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'unlockedAt',
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      unlockedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'unlockedAt',
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      unlockedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unlockedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      unlockedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'unlockedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      unlockedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'unlockedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      unlockedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'unlockedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AchievementSchemaQueryObject
    on QueryBuilder<AchievementSchema, AchievementSchema, QFilterCondition> {}

extension AchievementSchemaQueryLinks
    on QueryBuilder<AchievementSchema, AchievementSchema, QFilterCondition> {}

extension AchievementSchemaQuerySortBy
    on QueryBuilder<AchievementSchema, AchievementSchema, QSortBy> {
  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      sortByAchievementId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'achievementId', Sort.asc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      sortByAchievementIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'achievementId', Sort.desc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      sortByIconPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconPath', Sort.asc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      sortByIconPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconPath', Sort.desc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      sortByIsSecret() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSecret', Sort.asc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      sortByIsSecretDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSecret', Sort.desc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      sortByIsUnlocked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isUnlocked', Sort.asc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      sortByIsUnlockedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isUnlocked', Sort.desc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      sortByMaxProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxProgress', Sort.asc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      sortByMaxProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxProgress', Sort.desc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      sortByProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.asc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      sortByProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.desc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      sortByUnlockedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockedAt', Sort.asc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      sortByUnlockedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockedAt', Sort.desc);
    });
  }
}

extension AchievementSchemaQuerySortThenBy
    on QueryBuilder<AchievementSchema, AchievementSchema, QSortThenBy> {
  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      thenByAchievementId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'achievementId', Sort.asc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      thenByAchievementIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'achievementId', Sort.desc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      thenByIconPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconPath', Sort.asc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      thenByIconPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconPath', Sort.desc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      thenByIsSecret() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSecret', Sort.asc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      thenByIsSecretDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSecret', Sort.desc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      thenByIsUnlocked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isUnlocked', Sort.asc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      thenByIsUnlockedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isUnlocked', Sort.desc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      thenByMaxProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxProgress', Sort.asc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      thenByMaxProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxProgress', Sort.desc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      thenByProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.asc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      thenByProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.desc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      thenByUnlockedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockedAt', Sort.asc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      thenByUnlockedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockedAt', Sort.desc);
    });
  }
}

extension AchievementSchemaQueryWhereDistinct
    on QueryBuilder<AchievementSchema, AchievementSchema, QDistinct> {
  QueryBuilder<AchievementSchema, AchievementSchema, QDistinct>
      distinctByAchievementId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'achievementId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QDistinct>
      distinctByDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QDistinct>
      distinctByIconPath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'iconPath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QDistinct>
      distinctByIsSecret() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSecret');
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QDistinct>
      distinctByIsUnlocked() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isUnlocked');
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QDistinct>
      distinctByMaxProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maxProgress');
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QDistinct>
      distinctByProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'progress');
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QDistinct>
      distinctByUnlockedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unlockedAt');
    });
  }
}

extension AchievementSchemaQueryProperty
    on QueryBuilder<AchievementSchema, AchievementSchema, QQueryProperty> {
  QueryBuilder<AchievementSchema, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AchievementSchema, String, QQueryOperations>
      achievementIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'achievementId');
    });
  }

  QueryBuilder<AchievementSchema, String, QQueryOperations>
      descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<AchievementSchema, String, QQueryOperations> iconPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'iconPath');
    });
  }

  QueryBuilder<AchievementSchema, bool, QQueryOperations> isSecretProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSecret');
    });
  }

  QueryBuilder<AchievementSchema, bool, QQueryOperations> isUnlockedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isUnlocked');
    });
  }

  QueryBuilder<AchievementSchema, int, QQueryOperations> maxProgressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maxProgress');
    });
  }

  QueryBuilder<AchievementSchema, int, QQueryOperations> progressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'progress');
    });
  }

  QueryBuilder<AchievementSchema, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<AchievementSchema, DateTime?, QQueryOperations>
      unlockedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unlockedAt');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUserPointsSchemaCollection on Isar {
  IsarCollection<UserPointsSchema> get userPointsSchemas => this.collection();
}

const UserPointsSchemaSchema = CollectionSchema(
  name: r'UserPointsSchema',
  id: 1201156529044905282,
  properties: {
    r'history': PropertySchema(
      id: 0,
      name: r'history',
      type: IsarType.objectList,
      target: r'PointHistoryEmbedded',
    ),
    r'totalPoints': PropertySchema(
      id: 1,
      name: r'totalPoints',
      type: IsarType.long,
    ),
    r'weeklyPoints': PropertySchema(
      id: 2,
      name: r'weeklyPoints',
      type: IsarType.long,
    )
  },
  estimateSize: _userPointsSchemaEstimateSize,
  serialize: _userPointsSchemaSerialize,
  deserialize: _userPointsSchemaDeserialize,
  deserializeProp: _userPointsSchemaDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {r'PointHistoryEmbedded': PointHistoryEmbeddedSchema},
  getId: _userPointsSchemaGetId,
  getLinks: _userPointsSchemaGetLinks,
  attach: _userPointsSchemaAttach,
  version: '3.1.0+1',
);

int _userPointsSchemaEstimateSize(
  UserPointsSchema object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.history.length * 3;
  {
    final offsets = allOffsets[PointHistoryEmbedded]!;
    for (var i = 0; i < object.history.length; i++) {
      final value = object.history[i];
      bytesCount +=
          PointHistoryEmbeddedSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  return bytesCount;
}

void _userPointsSchemaSerialize(
  UserPointsSchema object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeObjectList<PointHistoryEmbedded>(
    offsets[0],
    allOffsets,
    PointHistoryEmbeddedSchema.serialize,
    object.history,
  );
  writer.writeLong(offsets[1], object.totalPoints);
  writer.writeLong(offsets[2], object.weeklyPoints);
}

UserPointsSchema _userPointsSchemaDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UserPointsSchema();
  object.history = reader.readObjectList<PointHistoryEmbedded>(
        offsets[0],
        PointHistoryEmbeddedSchema.deserialize,
        allOffsets,
        PointHistoryEmbedded(),
      ) ??
      [];
  object.id = id;
  object.totalPoints = reader.readLong(offsets[1]);
  object.weeklyPoints = reader.readLong(offsets[2]);
  return object;
}

P _userPointsSchemaDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readObjectList<PointHistoryEmbedded>(
            offset,
            PointHistoryEmbeddedSchema.deserialize,
            allOffsets,
            PointHistoryEmbedded(),
          ) ??
          []) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _userPointsSchemaGetId(UserPointsSchema object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _userPointsSchemaGetLinks(UserPointsSchema object) {
  return [];
}

void _userPointsSchemaAttach(
    IsarCollection<dynamic> col, Id id, UserPointsSchema object) {
  object.id = id;
}

extension UserPointsSchemaQueryWhereSort
    on QueryBuilder<UserPointsSchema, UserPointsSchema, QWhere> {
  QueryBuilder<UserPointsSchema, UserPointsSchema, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension UserPointsSchemaQueryWhere
    on QueryBuilder<UserPointsSchema, UserPointsSchema, QWhereClause> {
  QueryBuilder<UserPointsSchema, UserPointsSchema, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<UserPointsSchema, UserPointsSchema, QAfterWhereClause>
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

  QueryBuilder<UserPointsSchema, UserPointsSchema, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UserPointsSchema, UserPointsSchema, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UserPointsSchema, UserPointsSchema, QAfterWhereClause> idBetween(
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

extension UserPointsSchemaQueryFilter
    on QueryBuilder<UserPointsSchema, UserPointsSchema, QFilterCondition> {
  QueryBuilder<UserPointsSchema, UserPointsSchema, QAfterFilterCondition>
      historyLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'history',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<UserPointsSchema, UserPointsSchema, QAfterFilterCondition>
      historyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'history',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<UserPointsSchema, UserPointsSchema, QAfterFilterCondition>
      historyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'history',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<UserPointsSchema, UserPointsSchema, QAfterFilterCondition>
      historyLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'history',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<UserPointsSchema, UserPointsSchema, QAfterFilterCondition>
      historyLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'history',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<UserPointsSchema, UserPointsSchema, QAfterFilterCondition>
      historyLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'history',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<UserPointsSchema, UserPointsSchema, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPointsSchema, UserPointsSchema, QAfterFilterCondition>
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

  QueryBuilder<UserPointsSchema, UserPointsSchema, QAfterFilterCondition>
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

  QueryBuilder<UserPointsSchema, UserPointsSchema, QAfterFilterCondition>
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

  QueryBuilder<UserPointsSchema, UserPointsSchema, QAfterFilterCondition>
      totalPointsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalPoints',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPointsSchema, UserPointsSchema, QAfterFilterCondition>
      totalPointsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalPoints',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPointsSchema, UserPointsSchema, QAfterFilterCondition>
      totalPointsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalPoints',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPointsSchema, UserPointsSchema, QAfterFilterCondition>
      totalPointsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalPoints',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserPointsSchema, UserPointsSchema, QAfterFilterCondition>
      weeklyPointsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weeklyPoints',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPointsSchema, UserPointsSchema, QAfterFilterCondition>
      weeklyPointsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'weeklyPoints',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPointsSchema, UserPointsSchema, QAfterFilterCondition>
      weeklyPointsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'weeklyPoints',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPointsSchema, UserPointsSchema, QAfterFilterCondition>
      weeklyPointsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'weeklyPoints',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension UserPointsSchemaQueryObject
    on QueryBuilder<UserPointsSchema, UserPointsSchema, QFilterCondition> {
  QueryBuilder<UserPointsSchema, UserPointsSchema, QAfterFilterCondition>
      historyElement(FilterQuery<PointHistoryEmbedded> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'history');
    });
  }
}

extension UserPointsSchemaQueryLinks
    on QueryBuilder<UserPointsSchema, UserPointsSchema, QFilterCondition> {}

extension UserPointsSchemaQuerySortBy
    on QueryBuilder<UserPointsSchema, UserPointsSchema, QSortBy> {
  QueryBuilder<UserPointsSchema, UserPointsSchema, QAfterSortBy>
      sortByTotalPoints() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPoints', Sort.asc);
    });
  }

  QueryBuilder<UserPointsSchema, UserPointsSchema, QAfterSortBy>
      sortByTotalPointsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPoints', Sort.desc);
    });
  }

  QueryBuilder<UserPointsSchema, UserPointsSchema, QAfterSortBy>
      sortByWeeklyPoints() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weeklyPoints', Sort.asc);
    });
  }

  QueryBuilder<UserPointsSchema, UserPointsSchema, QAfterSortBy>
      sortByWeeklyPointsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weeklyPoints', Sort.desc);
    });
  }
}

extension UserPointsSchemaQuerySortThenBy
    on QueryBuilder<UserPointsSchema, UserPointsSchema, QSortThenBy> {
  QueryBuilder<UserPointsSchema, UserPointsSchema, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UserPointsSchema, UserPointsSchema, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UserPointsSchema, UserPointsSchema, QAfterSortBy>
      thenByTotalPoints() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPoints', Sort.asc);
    });
  }

  QueryBuilder<UserPointsSchema, UserPointsSchema, QAfterSortBy>
      thenByTotalPointsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPoints', Sort.desc);
    });
  }

  QueryBuilder<UserPointsSchema, UserPointsSchema, QAfterSortBy>
      thenByWeeklyPoints() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weeklyPoints', Sort.asc);
    });
  }

  QueryBuilder<UserPointsSchema, UserPointsSchema, QAfterSortBy>
      thenByWeeklyPointsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weeklyPoints', Sort.desc);
    });
  }
}

extension UserPointsSchemaQueryWhereDistinct
    on QueryBuilder<UserPointsSchema, UserPointsSchema, QDistinct> {
  QueryBuilder<UserPointsSchema, UserPointsSchema, QDistinct>
      distinctByTotalPoints() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalPoints');
    });
  }

  QueryBuilder<UserPointsSchema, UserPointsSchema, QDistinct>
      distinctByWeeklyPoints() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weeklyPoints');
    });
  }
}

extension UserPointsSchemaQueryProperty
    on QueryBuilder<UserPointsSchema, UserPointsSchema, QQueryProperty> {
  QueryBuilder<UserPointsSchema, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UserPointsSchema, List<PointHistoryEmbedded>, QQueryOperations>
      historyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'history');
    });
  }

  QueryBuilder<UserPointsSchema, int, QQueryOperations> totalPointsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalPoints');
    });
  }

  QueryBuilder<UserPointsSchema, int, QQueryOperations> weeklyPointsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weeklyPoints');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDailyChallengeSchemaCollection on Isar {
  IsarCollection<DailyChallengeSchema> get dailyChallengeSchemas =>
      this.collection();
}

const DailyChallengeSchemaSchema = CollectionSchema(
  name: r'DailyChallengeSchema',
  id: -8949166174127575993,
  properties: {
    r'challengeId': PropertySchema(
      id: 0,
      name: r'challengeId',
      type: IsarType.string,
    ),
    r'date': PropertySchema(
      id: 1,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'description': PropertySchema(
      id: 2,
      name: r'description',
      type: IsarType.string,
    ),
    r'isCompleted': PropertySchema(
      id: 3,
      name: r'isCompleted',
      type: IsarType.bool,
    ),
    r'rewardPoints': PropertySchema(
      id: 4,
      name: r'rewardPoints',
      type: IsarType.long,
    ),
    r'title': PropertySchema(
      id: 5,
      name: r'title',
      type: IsarType.string,
    )
  },
  estimateSize: _dailyChallengeSchemaEstimateSize,
  serialize: _dailyChallengeSchemaSerialize,
  deserialize: _dailyChallengeSchemaDeserialize,
  deserializeProp: _dailyChallengeSchemaDeserializeProp,
  idName: r'id',
  indexes: {
    r'challengeId': IndexSchema(
      id: 4483557487511118379,
      name: r'challengeId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'challengeId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _dailyChallengeSchemaGetId,
  getLinks: _dailyChallengeSchemaGetLinks,
  attach: _dailyChallengeSchemaAttach,
  version: '3.1.0+1',
);

int _dailyChallengeSchemaEstimateSize(
  DailyChallengeSchema object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.challengeId.length * 3;
  bytesCount += 3 + object.description.length * 3;
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _dailyChallengeSchemaSerialize(
  DailyChallengeSchema object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.challengeId);
  writer.writeDateTime(offsets[1], object.date);
  writer.writeString(offsets[2], object.description);
  writer.writeBool(offsets[3], object.isCompleted);
  writer.writeLong(offsets[4], object.rewardPoints);
  writer.writeString(offsets[5], object.title);
}

DailyChallengeSchema _dailyChallengeSchemaDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DailyChallengeSchema();
  object.challengeId = reader.readString(offsets[0]);
  object.date = reader.readDateTime(offsets[1]);
  object.description = reader.readString(offsets[2]);
  object.id = id;
  object.isCompleted = reader.readBool(offsets[3]);
  object.rewardPoints = reader.readLong(offsets[4]);
  object.title = reader.readString(offsets[5]);
  return object;
}

P _dailyChallengeSchemaDeserializeProp<P>(
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
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _dailyChallengeSchemaGetId(DailyChallengeSchema object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _dailyChallengeSchemaGetLinks(
    DailyChallengeSchema object) {
  return [];
}

void _dailyChallengeSchemaAttach(
    IsarCollection<dynamic> col, Id id, DailyChallengeSchema object) {
  object.id = id;
}

extension DailyChallengeSchemaByIndex on IsarCollection<DailyChallengeSchema> {
  Future<DailyChallengeSchema?> getByChallengeId(String challengeId) {
    return getByIndex(r'challengeId', [challengeId]);
  }

  DailyChallengeSchema? getByChallengeIdSync(String challengeId) {
    return getByIndexSync(r'challengeId', [challengeId]);
  }

  Future<bool> deleteByChallengeId(String challengeId) {
    return deleteByIndex(r'challengeId', [challengeId]);
  }

  bool deleteByChallengeIdSync(String challengeId) {
    return deleteByIndexSync(r'challengeId', [challengeId]);
  }

  Future<List<DailyChallengeSchema?>> getAllByChallengeId(
      List<String> challengeIdValues) {
    final values = challengeIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'challengeId', values);
  }

  List<DailyChallengeSchema?> getAllByChallengeIdSync(
      List<String> challengeIdValues) {
    final values = challengeIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'challengeId', values);
  }

  Future<int> deleteAllByChallengeId(List<String> challengeIdValues) {
    final values = challengeIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'challengeId', values);
  }

  int deleteAllByChallengeIdSync(List<String> challengeIdValues) {
    final values = challengeIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'challengeId', values);
  }

  Future<Id> putByChallengeId(DailyChallengeSchema object) {
    return putByIndex(r'challengeId', object);
  }

  Id putByChallengeIdSync(DailyChallengeSchema object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'challengeId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByChallengeId(List<DailyChallengeSchema> objects) {
    return putAllByIndex(r'challengeId', objects);
  }

  List<Id> putAllByChallengeIdSync(List<DailyChallengeSchema> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'challengeId', objects, saveLinks: saveLinks);
  }
}

extension DailyChallengeSchemaQueryWhereSort
    on QueryBuilder<DailyChallengeSchema, DailyChallengeSchema, QWhere> {
  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension DailyChallengeSchemaQueryWhere
    on QueryBuilder<DailyChallengeSchema, DailyChallengeSchema, QWhereClause> {
  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema, QAfterWhereClause>
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

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema, QAfterWhereClause>
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

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema, QAfterWhereClause>
      challengeIdEqualTo(String challengeId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'challengeId',
        value: [challengeId],
      ));
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema, QAfterWhereClause>
      challengeIdNotEqualTo(String challengeId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'challengeId',
              lower: [],
              upper: [challengeId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'challengeId',
              lower: [challengeId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'challengeId',
              lower: [challengeId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'challengeId',
              lower: [],
              upper: [challengeId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension DailyChallengeSchemaQueryFilter on QueryBuilder<DailyChallengeSchema,
    DailyChallengeSchema, QFilterCondition> {
  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema,
      QAfterFilterCondition> challengeIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'challengeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema,
      QAfterFilterCondition> challengeIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'challengeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema,
      QAfterFilterCondition> challengeIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'challengeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema,
      QAfterFilterCondition> challengeIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'challengeId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema,
      QAfterFilterCondition> challengeIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'challengeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema,
      QAfterFilterCondition> challengeIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'challengeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema,
          QAfterFilterCondition>
      challengeIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'challengeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema,
          QAfterFilterCondition>
      challengeIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'challengeId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema,
      QAfterFilterCondition> challengeIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'challengeId',
        value: '',
      ));
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema,
      QAfterFilterCondition> challengeIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'challengeId',
        value: '',
      ));
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema,
      QAfterFilterCondition> dateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema,
      QAfterFilterCondition> dateGreaterThan(
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

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema,
      QAfterFilterCondition> dateLessThan(
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

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema,
      QAfterFilterCondition> dateBetween(
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

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema,
      QAfterFilterCondition> descriptionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema,
      QAfterFilterCondition> descriptionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema,
      QAfterFilterCondition> descriptionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema,
      QAfterFilterCondition> descriptionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema,
      QAfterFilterCondition> descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema,
      QAfterFilterCondition> descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema,
          QAfterFilterCondition>
      descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema,
          QAfterFilterCondition>
      descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema,
      QAfterFilterCondition> descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema,
      QAfterFilterCondition> descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema,
      QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema,
      QAfterFilterCondition> idLessThan(
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

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema,
      QAfterFilterCondition> idBetween(
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

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema,
      QAfterFilterCondition> isCompletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isCompleted',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema,
      QAfterFilterCondition> rewardPointsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rewardPoints',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema,
      QAfterFilterCondition> rewardPointsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rewardPoints',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema,
      QAfterFilterCondition> rewardPointsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rewardPoints',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema,
      QAfterFilterCondition> rewardPointsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rewardPoints',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema,
      QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema,
      QAfterFilterCondition> titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema,
      QAfterFilterCondition> titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema,
      QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema,
      QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema,
      QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema,
          QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema,
          QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema,
      QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema,
      QAfterFilterCondition> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }
}

extension DailyChallengeSchemaQueryObject on QueryBuilder<DailyChallengeSchema,
    DailyChallengeSchema, QFilterCondition> {}

extension DailyChallengeSchemaQueryLinks on QueryBuilder<DailyChallengeSchema,
    DailyChallengeSchema, QFilterCondition> {}

extension DailyChallengeSchemaQuerySortBy
    on QueryBuilder<DailyChallengeSchema, DailyChallengeSchema, QSortBy> {
  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema, QAfterSortBy>
      sortByChallengeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'challengeId', Sort.asc);
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema, QAfterSortBy>
      sortByChallengeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'challengeId', Sort.desc);
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema, QAfterSortBy>
      sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema, QAfterSortBy>
      sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema, QAfterSortBy>
      sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema, QAfterSortBy>
      sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema, QAfterSortBy>
      sortByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema, QAfterSortBy>
      sortByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema, QAfterSortBy>
      sortByRewardPoints() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rewardPoints', Sort.asc);
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema, QAfterSortBy>
      sortByRewardPointsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rewardPoints', Sort.desc);
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema, QAfterSortBy>
      sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema, QAfterSortBy>
      sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension DailyChallengeSchemaQuerySortThenBy
    on QueryBuilder<DailyChallengeSchema, DailyChallengeSchema, QSortThenBy> {
  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema, QAfterSortBy>
      thenByChallengeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'challengeId', Sort.asc);
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema, QAfterSortBy>
      thenByChallengeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'challengeId', Sort.desc);
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema, QAfterSortBy>
      thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema, QAfterSortBy>
      thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema, QAfterSortBy>
      thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema, QAfterSortBy>
      thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema, QAfterSortBy>
      thenByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema, QAfterSortBy>
      thenByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema, QAfterSortBy>
      thenByRewardPoints() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rewardPoints', Sort.asc);
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema, QAfterSortBy>
      thenByRewardPointsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rewardPoints', Sort.desc);
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema, QAfterSortBy>
      thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema, QAfterSortBy>
      thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension DailyChallengeSchemaQueryWhereDistinct
    on QueryBuilder<DailyChallengeSchema, DailyChallengeSchema, QDistinct> {
  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema, QDistinct>
      distinctByChallengeId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'challengeId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema, QDistinct>
      distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema, QDistinct>
      distinctByDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema, QDistinct>
      distinctByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isCompleted');
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema, QDistinct>
      distinctByRewardPoints() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rewardPoints');
    });
  }

  QueryBuilder<DailyChallengeSchema, DailyChallengeSchema, QDistinct>
      distinctByTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }
}

extension DailyChallengeSchemaQueryProperty on QueryBuilder<
    DailyChallengeSchema, DailyChallengeSchema, QQueryProperty> {
  QueryBuilder<DailyChallengeSchema, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DailyChallengeSchema, String, QQueryOperations>
      challengeIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'challengeId');
    });
  }

  QueryBuilder<DailyChallengeSchema, DateTime, QQueryOperations>
      dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<DailyChallengeSchema, String, QQueryOperations>
      descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<DailyChallengeSchema, bool, QQueryOperations>
      isCompletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isCompleted');
    });
  }

  QueryBuilder<DailyChallengeSchema, int, QQueryOperations>
      rewardPointsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rewardPoints');
    });
  }

  QueryBuilder<DailyChallengeSchema, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const PointHistoryEmbeddedSchema = Schema(
  name: r'PointHistoryEmbedded',
  id: 6258576570613855661,
  properties: {
    r'date': PropertySchema(
      id: 0,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'points': PropertySchema(
      id: 1,
      name: r'points',
      type: IsarType.long,
    ),
    r'reason': PropertySchema(
      id: 2,
      name: r'reason',
      type: IsarType.string,
    )
  },
  estimateSize: _pointHistoryEmbeddedEstimateSize,
  serialize: _pointHistoryEmbeddedSerialize,
  deserialize: _pointHistoryEmbeddedDeserialize,
  deserializeProp: _pointHistoryEmbeddedDeserializeProp,
);

int _pointHistoryEmbeddedEstimateSize(
  PointHistoryEmbedded object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.reason.length * 3;
  return bytesCount;
}

void _pointHistoryEmbeddedSerialize(
  PointHistoryEmbedded object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.date);
  writer.writeLong(offsets[1], object.points);
  writer.writeString(offsets[2], object.reason);
}

PointHistoryEmbedded _pointHistoryEmbeddedDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PointHistoryEmbedded();
  object.date = reader.readDateTime(offsets[0]);
  object.points = reader.readLong(offsets[1]);
  object.reason = reader.readString(offsets[2]);
  return object;
}

P _pointHistoryEmbeddedDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension PointHistoryEmbeddedQueryFilter on QueryBuilder<PointHistoryEmbedded,
    PointHistoryEmbedded, QFilterCondition> {
  QueryBuilder<PointHistoryEmbedded, PointHistoryEmbedded,
      QAfterFilterCondition> dateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<PointHistoryEmbedded, PointHistoryEmbedded,
      QAfterFilterCondition> dateGreaterThan(
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

  QueryBuilder<PointHistoryEmbedded, PointHistoryEmbedded,
      QAfterFilterCondition> dateLessThan(
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

  QueryBuilder<PointHistoryEmbedded, PointHistoryEmbedded,
      QAfterFilterCondition> dateBetween(
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

  QueryBuilder<PointHistoryEmbedded, PointHistoryEmbedded,
      QAfterFilterCondition> pointsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'points',
        value: value,
      ));
    });
  }

  QueryBuilder<PointHistoryEmbedded, PointHistoryEmbedded,
      QAfterFilterCondition> pointsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'points',
        value: value,
      ));
    });
  }

  QueryBuilder<PointHistoryEmbedded, PointHistoryEmbedded,
      QAfterFilterCondition> pointsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'points',
        value: value,
      ));
    });
  }

  QueryBuilder<PointHistoryEmbedded, PointHistoryEmbedded,
      QAfterFilterCondition> pointsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'points',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PointHistoryEmbedded, PointHistoryEmbedded,
      QAfterFilterCondition> reasonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PointHistoryEmbedded, PointHistoryEmbedded,
      QAfterFilterCondition> reasonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PointHistoryEmbedded, PointHistoryEmbedded,
      QAfterFilterCondition> reasonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PointHistoryEmbedded, PointHistoryEmbedded,
      QAfterFilterCondition> reasonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reason',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PointHistoryEmbedded, PointHistoryEmbedded,
      QAfterFilterCondition> reasonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PointHistoryEmbedded, PointHistoryEmbedded,
      QAfterFilterCondition> reasonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PointHistoryEmbedded, PointHistoryEmbedded,
          QAfterFilterCondition>
      reasonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PointHistoryEmbedded, PointHistoryEmbedded,
          QAfterFilterCondition>
      reasonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reason',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PointHistoryEmbedded, PointHistoryEmbedded,
      QAfterFilterCondition> reasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reason',
        value: '',
      ));
    });
  }

  QueryBuilder<PointHistoryEmbedded, PointHistoryEmbedded,
      QAfterFilterCondition> reasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reason',
        value: '',
      ));
    });
  }
}

extension PointHistoryEmbeddedQueryObject on QueryBuilder<PointHistoryEmbedded,
    PointHistoryEmbedded, QFilterCondition> {}
