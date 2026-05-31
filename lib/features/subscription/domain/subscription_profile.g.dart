// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_profile.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSubscriptionProfileCollection on Isar {
  IsarCollection<SubscriptionProfile> get subscriptionProfiles =>
      this.collection();
}

const SubscriptionProfileSchema = CollectionSchema(
  name: r'SubscriptionProfile',
  id: -4892505781459233091,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'downloadBytes': PropertySchema(
      id: 1,
      name: r'downloadBytes',
      type: IsarType.long,
    ),
    r'expireAtSeconds': PropertySchema(
      id: 2,
      name: r'expireAtSeconds',
      type: IsarType.long,
    ),
    r'lastUsedAt': PropertySchema(
      id: 3,
      name: r'lastUsedAt',
      type: IsarType.dateTime,
    ),
    r'mergedYamlPath': PropertySchema(
      id: 4,
      name: r'mergedYamlPath',
      type: IsarType.string,
    ),
    r'originalYaml': PropertySchema(
      id: 5,
      name: r'originalYaml',
      type: IsarType.string,
    ),
    r'subscriptionUrl': PropertySchema(
      id: 6,
      name: r'subscriptionUrl',
      type: IsarType.string,
    ),
    r'title': PropertySchema(
      id: 7,
      name: r'title',
      type: IsarType.string,
    ),
    r'totalBytes': PropertySchema(
      id: 8,
      name: r'totalBytes',
      type: IsarType.long,
    ),
    r'updateIntervalHours': PropertySchema(
      id: 9,
      name: r'updateIntervalHours',
      type: IsarType.long,
    ),
    r'updatedAt': PropertySchema(
      id: 10,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'uploadBytes': PropertySchema(
      id: 11,
      name: r'uploadBytes',
      type: IsarType.long,
    )
  },
  estimateSize: _subscriptionProfileEstimateSize,
  serialize: _subscriptionProfileSerialize,
  deserialize: _subscriptionProfileDeserialize,
  deserializeProp: _subscriptionProfileDeserializeProp,
  idName: r'id',
  indexes: {
    r'subscriptionUrl': IndexSchema(
      id: -8371850946433992053,
      name: r'subscriptionUrl',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'subscriptionUrl',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _subscriptionProfileGetId,
  getLinks: _subscriptionProfileGetLinks,
  attach: _subscriptionProfileAttach,
  version: '3.1.0+1',
);

int _subscriptionProfileEstimateSize(
  SubscriptionProfile object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.mergedYamlPath.length * 3;
  bytesCount += 3 + object.originalYaml.length * 3;
  bytesCount += 3 + object.subscriptionUrl.length * 3;
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _subscriptionProfileSerialize(
  SubscriptionProfile object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeLong(offsets[1], object.downloadBytes);
  writer.writeLong(offsets[2], object.expireAtSeconds);
  writer.writeDateTime(offsets[3], object.lastUsedAt);
  writer.writeString(offsets[4], object.mergedYamlPath);
  writer.writeString(offsets[5], object.originalYaml);
  writer.writeString(offsets[6], object.subscriptionUrl);
  writer.writeString(offsets[7], object.title);
  writer.writeLong(offsets[8], object.totalBytes);
  writer.writeLong(offsets[9], object.updateIntervalHours);
  writer.writeDateTime(offsets[10], object.updatedAt);
  writer.writeLong(offsets[11], object.uploadBytes);
}

SubscriptionProfile _subscriptionProfileDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SubscriptionProfile();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.downloadBytes = reader.readLong(offsets[1]);
  object.expireAtSeconds = reader.readLong(offsets[2]);
  object.id = id;
  object.lastUsedAt = reader.readDateTimeOrNull(offsets[3]);
  object.mergedYamlPath = reader.readString(offsets[4]);
  object.originalYaml = reader.readString(offsets[5]);
  object.subscriptionUrl = reader.readString(offsets[6]);
  object.title = reader.readString(offsets[7]);
  object.totalBytes = reader.readLong(offsets[8]);
  object.updateIntervalHours = reader.readLong(offsets[9]);
  object.updatedAt = reader.readDateTime(offsets[10]);
  object.uploadBytes = reader.readLong(offsets[11]);
  return object;
}

P _subscriptionProfileDeserializeProp<P>(
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
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readDateTime(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _subscriptionProfileGetId(SubscriptionProfile object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _subscriptionProfileGetLinks(
    SubscriptionProfile object) {
  return [];
}

void _subscriptionProfileAttach(
    IsarCollection<dynamic> col, Id id, SubscriptionProfile object) {
  object.id = id;
}

extension SubscriptionProfileByIndex on IsarCollection<SubscriptionProfile> {
  Future<SubscriptionProfile?> getBySubscriptionUrl(String subscriptionUrl) {
    return getByIndex(r'subscriptionUrl', [subscriptionUrl]);
  }

  SubscriptionProfile? getBySubscriptionUrlSync(String subscriptionUrl) {
    return getByIndexSync(r'subscriptionUrl', [subscriptionUrl]);
  }

  Future<bool> deleteBySubscriptionUrl(String subscriptionUrl) {
    return deleteByIndex(r'subscriptionUrl', [subscriptionUrl]);
  }

  bool deleteBySubscriptionUrlSync(String subscriptionUrl) {
    return deleteByIndexSync(r'subscriptionUrl', [subscriptionUrl]);
  }

  Future<List<SubscriptionProfile?>> getAllBySubscriptionUrl(
      List<String> subscriptionUrlValues) {
    final values = subscriptionUrlValues.map((e) => [e]).toList();
    return getAllByIndex(r'subscriptionUrl', values);
  }

  List<SubscriptionProfile?> getAllBySubscriptionUrlSync(
      List<String> subscriptionUrlValues) {
    final values = subscriptionUrlValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'subscriptionUrl', values);
  }

  Future<int> deleteAllBySubscriptionUrl(List<String> subscriptionUrlValues) {
    final values = subscriptionUrlValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'subscriptionUrl', values);
  }

  int deleteAllBySubscriptionUrlSync(List<String> subscriptionUrlValues) {
    final values = subscriptionUrlValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'subscriptionUrl', values);
  }

  Future<Id> putBySubscriptionUrl(SubscriptionProfile object) {
    return putByIndex(r'subscriptionUrl', object);
  }

  Id putBySubscriptionUrlSync(SubscriptionProfile object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'subscriptionUrl', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllBySubscriptionUrl(List<SubscriptionProfile> objects) {
    return putAllByIndex(r'subscriptionUrl', objects);
  }

  List<Id> putAllBySubscriptionUrlSync(List<SubscriptionProfile> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'subscriptionUrl', objects, saveLinks: saveLinks);
  }
}

extension SubscriptionProfileQueryWhereSort
    on QueryBuilder<SubscriptionProfile, SubscriptionProfile, QWhere> {
  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SubscriptionProfileQueryWhere
    on QueryBuilder<SubscriptionProfile, SubscriptionProfile, QWhereClause> {
  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterWhereClause>
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

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterWhereClause>
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

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterWhereClause>
      subscriptionUrlEqualTo(String subscriptionUrl) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'subscriptionUrl',
        value: [subscriptionUrl],
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterWhereClause>
      subscriptionUrlNotEqualTo(String subscriptionUrl) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'subscriptionUrl',
              lower: [],
              upper: [subscriptionUrl],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'subscriptionUrl',
              lower: [subscriptionUrl],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'subscriptionUrl',
              lower: [subscriptionUrl],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'subscriptionUrl',
              lower: [],
              upper: [subscriptionUrl],
              includeUpper: false,
            ));
      }
    });
  }
}

extension SubscriptionProfileQueryFilter on QueryBuilder<SubscriptionProfile,
    SubscriptionProfile, QFilterCondition> {
  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
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

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
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

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
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

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      downloadBytesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'downloadBytes',
        value: value,
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      downloadBytesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'downloadBytes',
        value: value,
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      downloadBytesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'downloadBytes',
        value: value,
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      downloadBytesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'downloadBytes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      expireAtSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'expireAtSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      expireAtSecondsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'expireAtSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      expireAtSecondsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'expireAtSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      expireAtSecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'expireAtSeconds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
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

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
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

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
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

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      lastUsedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastUsedAt',
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      lastUsedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastUsedAt',
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      lastUsedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUsedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      lastUsedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastUsedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      lastUsedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastUsedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      lastUsedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastUsedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      mergedYamlPathEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mergedYamlPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      mergedYamlPathGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mergedYamlPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      mergedYamlPathLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mergedYamlPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      mergedYamlPathBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mergedYamlPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      mergedYamlPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'mergedYamlPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      mergedYamlPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'mergedYamlPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      mergedYamlPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'mergedYamlPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      mergedYamlPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'mergedYamlPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      mergedYamlPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mergedYamlPath',
        value: '',
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      mergedYamlPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'mergedYamlPath',
        value: '',
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      originalYamlEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'originalYaml',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      originalYamlGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'originalYaml',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      originalYamlLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'originalYaml',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      originalYamlBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'originalYaml',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      originalYamlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'originalYaml',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      originalYamlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'originalYaml',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      originalYamlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'originalYaml',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      originalYamlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'originalYaml',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      originalYamlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'originalYaml',
        value: '',
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      originalYamlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'originalYaml',
        value: '',
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      subscriptionUrlEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subscriptionUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      subscriptionUrlGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'subscriptionUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      subscriptionUrlLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'subscriptionUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      subscriptionUrlBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'subscriptionUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      subscriptionUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'subscriptionUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      subscriptionUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'subscriptionUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      subscriptionUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'subscriptionUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      subscriptionUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'subscriptionUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      subscriptionUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subscriptionUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      subscriptionUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'subscriptionUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
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

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
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

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
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

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
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

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
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

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
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

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      totalBytesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalBytes',
        value: value,
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      totalBytesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalBytes',
        value: value,
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      totalBytesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalBytes',
        value: value,
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      totalBytesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalBytes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      updateIntervalHoursEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updateIntervalHours',
        value: value,
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      updateIntervalHoursGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updateIntervalHours',
        value: value,
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      updateIntervalHoursLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updateIntervalHours',
        value: value,
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      updateIntervalHoursBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updateIntervalHours',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
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

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
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

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
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

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      uploadBytesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uploadBytes',
        value: value,
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      uploadBytesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'uploadBytes',
        value: value,
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      uploadBytesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'uploadBytes',
        value: value,
      ));
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterFilterCondition>
      uploadBytesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'uploadBytes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SubscriptionProfileQueryObject on QueryBuilder<SubscriptionProfile,
    SubscriptionProfile, QFilterCondition> {}

extension SubscriptionProfileQueryLinks on QueryBuilder<SubscriptionProfile,
    SubscriptionProfile, QFilterCondition> {}

extension SubscriptionProfileQuerySortBy
    on QueryBuilder<SubscriptionProfile, SubscriptionProfile, QSortBy> {
  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterSortBy>
      sortByDownloadBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadBytes', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterSortBy>
      sortByDownloadBytesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadBytes', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterSortBy>
      sortByExpireAtSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expireAtSeconds', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterSortBy>
      sortByExpireAtSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expireAtSeconds', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterSortBy>
      sortByLastUsedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUsedAt', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterSortBy>
      sortByLastUsedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUsedAt', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterSortBy>
      sortByMergedYamlPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mergedYamlPath', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterSortBy>
      sortByMergedYamlPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mergedYamlPath', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterSortBy>
      sortByOriginalYaml() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalYaml', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterSortBy>
      sortByOriginalYamlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalYaml', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterSortBy>
      sortBySubscriptionUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subscriptionUrl', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterSortBy>
      sortBySubscriptionUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subscriptionUrl', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterSortBy>
      sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterSortBy>
      sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterSortBy>
      sortByTotalBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalBytes', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterSortBy>
      sortByTotalBytesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalBytes', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterSortBy>
      sortByUpdateIntervalHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updateIntervalHours', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterSortBy>
      sortByUpdateIntervalHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updateIntervalHours', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterSortBy>
      sortByUploadBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uploadBytes', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterSortBy>
      sortByUploadBytesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uploadBytes', Sort.desc);
    });
  }
}

extension SubscriptionProfileQuerySortThenBy
    on QueryBuilder<SubscriptionProfile, SubscriptionProfile, QSortThenBy> {
  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterSortBy>
      thenByDownloadBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadBytes', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterSortBy>
      thenByDownloadBytesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadBytes', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterSortBy>
      thenByExpireAtSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expireAtSeconds', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterSortBy>
      thenByExpireAtSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expireAtSeconds', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterSortBy>
      thenByLastUsedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUsedAt', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterSortBy>
      thenByLastUsedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUsedAt', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterSortBy>
      thenByMergedYamlPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mergedYamlPath', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterSortBy>
      thenByMergedYamlPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mergedYamlPath', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterSortBy>
      thenByOriginalYaml() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalYaml', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterSortBy>
      thenByOriginalYamlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalYaml', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterSortBy>
      thenBySubscriptionUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subscriptionUrl', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterSortBy>
      thenBySubscriptionUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subscriptionUrl', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterSortBy>
      thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterSortBy>
      thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterSortBy>
      thenByTotalBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalBytes', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterSortBy>
      thenByTotalBytesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalBytes', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterSortBy>
      thenByUpdateIntervalHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updateIntervalHours', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterSortBy>
      thenByUpdateIntervalHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updateIntervalHours', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterSortBy>
      thenByUploadBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uploadBytes', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QAfterSortBy>
      thenByUploadBytesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uploadBytes', Sort.desc);
    });
  }
}

extension SubscriptionProfileQueryWhereDistinct
    on QueryBuilder<SubscriptionProfile, SubscriptionProfile, QDistinct> {
  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QDistinct>
      distinctByDownloadBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'downloadBytes');
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QDistinct>
      distinctByExpireAtSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expireAtSeconds');
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QDistinct>
      distinctByLastUsedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUsedAt');
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QDistinct>
      distinctByMergedYamlPath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mergedYamlPath',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QDistinct>
      distinctByOriginalYaml({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'originalYaml', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QDistinct>
      distinctBySubscriptionUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subscriptionUrl',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QDistinct>
      distinctByTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QDistinct>
      distinctByTotalBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalBytes');
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QDistinct>
      distinctByUpdateIntervalHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updateIntervalHours');
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<SubscriptionProfile, SubscriptionProfile, QDistinct>
      distinctByUploadBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uploadBytes');
    });
  }
}

extension SubscriptionProfileQueryProperty
    on QueryBuilder<SubscriptionProfile, SubscriptionProfile, QQueryProperty> {
  QueryBuilder<SubscriptionProfile, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SubscriptionProfile, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<SubscriptionProfile, int, QQueryOperations>
      downloadBytesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'downloadBytes');
    });
  }

  QueryBuilder<SubscriptionProfile, int, QQueryOperations>
      expireAtSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expireAtSeconds');
    });
  }

  QueryBuilder<SubscriptionProfile, DateTime?, QQueryOperations>
      lastUsedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUsedAt');
    });
  }

  QueryBuilder<SubscriptionProfile, String, QQueryOperations>
      mergedYamlPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mergedYamlPath');
    });
  }

  QueryBuilder<SubscriptionProfile, String, QQueryOperations>
      originalYamlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'originalYaml');
    });
  }

  QueryBuilder<SubscriptionProfile, String, QQueryOperations>
      subscriptionUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subscriptionUrl');
    });
  }

  QueryBuilder<SubscriptionProfile, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<SubscriptionProfile, int, QQueryOperations>
      totalBytesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalBytes');
    });
  }

  QueryBuilder<SubscriptionProfile, int, QQueryOperations>
      updateIntervalHoursProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updateIntervalHours');
    });
  }

  QueryBuilder<SubscriptionProfile, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<SubscriptionProfile, int, QQueryOperations>
      uploadBytesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uploadBytes');
    });
  }
}
