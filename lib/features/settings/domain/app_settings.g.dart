// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAppSettingsCollection on Isar {
  IsarCollection<AppSettings> get appSettings => this.collection();
}

const AppSettingsSchema = CollectionSchema(
  name: r'AppSettings',
  id: -5633561779022347008,
  properties: {
    r'autoUpdateHours': PropertySchema(
      id: 0,
      name: r'autoUpdateHours',
      type: IsarType.long,
    ),
    r'autoUpdateSubscription': PropertySchema(
      id: 1,
      name: r'autoUpdateSubscription',
      type: IsarType.bool,
    ),
    r'bypassRussia': PropertySchema(
      id: 2,
      name: r'bypassRussia',
      type: IsarType.bool,
    ),
    r'killSwitch': PropertySchema(
      id: 3,
      name: r'killSwitch',
      type: IsarType.bool,
    ),
    r'launchAtStartup': PropertySchema(
      id: 4,
      name: r'launchAtStartup',
      type: IsarType.bool,
    ),
    r'showAnnouncements': PropertySchema(
      id: 5,
      name: r'showAnnouncements',
      type: IsarType.bool,
    ),
    r'showConnectionMessages': PropertySchema(
      id: 6,
      name: r'showConnectionMessages',
      type: IsarType.bool,
    ),
    r'splitTunnelMode': PropertySchema(
      id: 7,
      name: r'splitTunnelMode',
      type: IsarType.string,
      enumMap: _AppSettingssplitTunnelModeEnumValueMap,
    ),
    r'splitTunnelPackages': PropertySchema(
      id: 8,
      name: r'splitTunnelPackages',
      type: IsarType.stringList,
    ),
    r'theme': PropertySchema(
      id: 9,
      name: r'theme',
      type: IsarType.string,
      enumMap: _AppSettingsthemeEnumValueMap,
    ),
    r'themeChosen': PropertySchema(
      id: 10,
      name: r'themeChosen',
      type: IsarType.bool,
    ),
    r'tunMode': PropertySchema(
      id: 11,
      name: r'tunMode',
      type: IsarType.bool,
    ),
    r'updatedAt': PropertySchema(
      id: 12,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _appSettingsEstimateSize,
  serialize: _appSettingsSerialize,
  deserialize: _appSettingsDeserialize,
  deserializeProp: _appSettingsDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _appSettingsGetId,
  getLinks: _appSettingsGetLinks,
  attach: _appSettingsAttach,
  version: '3.1.0+1',
);

int _appSettingsEstimateSize(
  AppSettings object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.splitTunnelMode.name.length * 3;
  bytesCount += 3 + object.splitTunnelPackages.length * 3;
  {
    for (var i = 0; i < object.splitTunnelPackages.length; i++) {
      final value = object.splitTunnelPackages[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.theme.name.length * 3;
  return bytesCount;
}

void _appSettingsSerialize(
  AppSettings object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.autoUpdateHours);
  writer.writeBool(offsets[1], object.autoUpdateSubscription);
  writer.writeBool(offsets[2], object.bypassRussia);
  writer.writeBool(offsets[3], object.killSwitch);
  writer.writeBool(offsets[4], object.launchAtStartup);
  writer.writeBool(offsets[5], object.showAnnouncements);
  writer.writeBool(offsets[6], object.showConnectionMessages);
  writer.writeString(offsets[7], object.splitTunnelMode.name);
  writer.writeStringList(offsets[8], object.splitTunnelPackages);
  writer.writeString(offsets[9], object.theme.name);
  writer.writeBool(offsets[10], object.themeChosen);
  writer.writeBool(offsets[11], object.tunMode);
  writer.writeDateTime(offsets[12], object.updatedAt);
}

AppSettings _appSettingsDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AppSettings();
  object.autoUpdateHours = reader.readLong(offsets[0]);
  object.autoUpdateSubscription = reader.readBool(offsets[1]);
  object.bypassRussia = reader.readBool(offsets[2]);
  object.id = id;
  object.killSwitch = reader.readBool(offsets[3]);
  object.launchAtStartup = reader.readBool(offsets[4]);
  object.showAnnouncements = reader.readBool(offsets[5]);
  object.showConnectionMessages = reader.readBool(offsets[6]);
  object.splitTunnelMode = _AppSettingssplitTunnelModeValueEnumMap[
          reader.readStringOrNull(offsets[7])] ??
      SplitTunnelMode.disabled;
  object.splitTunnelPackages = reader.readStringList(offsets[8]) ?? [];
  object.theme =
      _AppSettingsthemeValueEnumMap[reader.readStringOrNull(offsets[9])] ??
          ThemePreference.system;
  object.themeChosen = reader.readBool(offsets[10]);
  object.tunMode = reader.readBool(offsets[11]);
  object.updatedAt = reader.readDateTime(offsets[12]);
  return object;
}

P _appSettingsDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (_AppSettingssplitTunnelModeValueEnumMap[
              reader.readStringOrNull(offset)] ??
          SplitTunnelMode.disabled) as P;
    case 8:
      return (reader.readStringList(offset) ?? []) as P;
    case 9:
      return (_AppSettingsthemeValueEnumMap[reader.readStringOrNull(offset)] ??
          ThemePreference.system) as P;
    case 10:
      return (reader.readBool(offset)) as P;
    case 11:
      return (reader.readBool(offset)) as P;
    case 12:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _AppSettingssplitTunnelModeEnumValueMap = {
  r'disabled': r'disabled',
  r'onlySelectedApps': r'onlySelectedApps',
  r'excludeSelectedApps': r'excludeSelectedApps',
};
const _AppSettingssplitTunnelModeValueEnumMap = {
  r'disabled': SplitTunnelMode.disabled,
  r'onlySelectedApps': SplitTunnelMode.onlySelectedApps,
  r'excludeSelectedApps': SplitTunnelMode.excludeSelectedApps,
};
const _AppSettingsthemeEnumValueMap = {
  r'system': r'system',
  r'light': r'light',
  r'dark': r'dark',
};
const _AppSettingsthemeValueEnumMap = {
  r'system': ThemePreference.system,
  r'light': ThemePreference.light,
  r'dark': ThemePreference.dark,
};

Id _appSettingsGetId(AppSettings object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _appSettingsGetLinks(AppSettings object) {
  return [];
}

void _appSettingsAttach(
    IsarCollection<dynamic> col, Id id, AppSettings object) {
  object.id = id;
}

extension AppSettingsQueryWhereSort
    on QueryBuilder<AppSettings, AppSettings, QWhere> {
  QueryBuilder<AppSettings, AppSettings, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AppSettingsQueryWhere
    on QueryBuilder<AppSettings, AppSettings, QWhereClause> {
  QueryBuilder<AppSettings, AppSettings, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<AppSettings, AppSettings, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterWhereClause> idBetween(
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

extension AppSettingsQueryFilter
    on QueryBuilder<AppSettings, AppSettings, QFilterCondition> {
  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      autoUpdateHoursEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'autoUpdateHours',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      autoUpdateHoursGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'autoUpdateHours',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      autoUpdateHoursLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'autoUpdateHours',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      autoUpdateHoursBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'autoUpdateHours',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      autoUpdateSubscriptionEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'autoUpdateSubscription',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      bypassRussiaEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bypassRussia',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition> idBetween(
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

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      killSwitchEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'killSwitch',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      launchAtStartupEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'launchAtStartup',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      showAnnouncementsEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'showAnnouncements',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      showConnectionMessagesEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'showConnectionMessages',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      splitTunnelModeEqualTo(
    SplitTunnelMode value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'splitTunnelMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      splitTunnelModeGreaterThan(
    SplitTunnelMode value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'splitTunnelMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      splitTunnelModeLessThan(
    SplitTunnelMode value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'splitTunnelMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      splitTunnelModeBetween(
    SplitTunnelMode lower,
    SplitTunnelMode upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'splitTunnelMode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      splitTunnelModeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'splitTunnelMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      splitTunnelModeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'splitTunnelMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      splitTunnelModeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'splitTunnelMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      splitTunnelModeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'splitTunnelMode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      splitTunnelModeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'splitTunnelMode',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      splitTunnelModeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'splitTunnelMode',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      splitTunnelPackagesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'splitTunnelPackages',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      splitTunnelPackagesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'splitTunnelPackages',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      splitTunnelPackagesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'splitTunnelPackages',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      splitTunnelPackagesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'splitTunnelPackages',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      splitTunnelPackagesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'splitTunnelPackages',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      splitTunnelPackagesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'splitTunnelPackages',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      splitTunnelPackagesElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'splitTunnelPackages',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      splitTunnelPackagesElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'splitTunnelPackages',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      splitTunnelPackagesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'splitTunnelPackages',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      splitTunnelPackagesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'splitTunnelPackages',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      splitTunnelPackagesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'splitTunnelPackages',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      splitTunnelPackagesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'splitTunnelPackages',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      splitTunnelPackagesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'splitTunnelPackages',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      splitTunnelPackagesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'splitTunnelPackages',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      splitTunnelPackagesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'splitTunnelPackages',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      splitTunnelPackagesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'splitTunnelPackages',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition> themeEqualTo(
    ThemePreference value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'theme',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      themeGreaterThan(
    ThemePreference value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'theme',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition> themeLessThan(
    ThemePreference value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'theme',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition> themeBetween(
    ThemePreference lower,
    ThemePreference upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'theme',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition> themeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'theme',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition> themeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'theme',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition> themeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'theme',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition> themeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'theme',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition> themeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'theme',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      themeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'theme',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      themeChosenEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'themeChosen',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition> tunModeEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tunMode',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
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

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
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

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
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
}

extension AppSettingsQueryObject
    on QueryBuilder<AppSettings, AppSettings, QFilterCondition> {}

extension AppSettingsQueryLinks
    on QueryBuilder<AppSettings, AppSettings, QFilterCondition> {}

extension AppSettingsQuerySortBy
    on QueryBuilder<AppSettings, AppSettings, QSortBy> {
  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByAutoUpdateHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoUpdateHours', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByAutoUpdateHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoUpdateHours', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByAutoUpdateSubscription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoUpdateSubscription', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByAutoUpdateSubscriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoUpdateSubscription', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByBypassRussia() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bypassRussia', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByBypassRussiaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bypassRussia', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByKillSwitch() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'killSwitch', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByKillSwitchDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'killSwitch', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByLaunchAtStartup() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'launchAtStartup', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByLaunchAtStartupDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'launchAtStartup', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByShowAnnouncements() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showAnnouncements', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByShowAnnouncementsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showAnnouncements', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByShowConnectionMessages() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showConnectionMessages', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByShowConnectionMessagesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showConnectionMessages', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortBySplitTunnelMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'splitTunnelMode', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortBySplitTunnelModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'splitTunnelMode', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByTheme() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'theme', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByThemeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'theme', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByThemeChosen() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeChosen', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByThemeChosenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeChosen', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByTunMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tunMode', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByTunModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tunMode', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension AppSettingsQuerySortThenBy
    on QueryBuilder<AppSettings, AppSettings, QSortThenBy> {
  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByAutoUpdateHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoUpdateHours', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByAutoUpdateHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoUpdateHours', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByAutoUpdateSubscription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoUpdateSubscription', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByAutoUpdateSubscriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoUpdateSubscription', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByBypassRussia() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bypassRussia', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByBypassRussiaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bypassRussia', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByKillSwitch() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'killSwitch', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByKillSwitchDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'killSwitch', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByLaunchAtStartup() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'launchAtStartup', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByLaunchAtStartupDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'launchAtStartup', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByShowAnnouncements() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showAnnouncements', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByShowAnnouncementsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showAnnouncements', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByShowConnectionMessages() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showConnectionMessages', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByShowConnectionMessagesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showConnectionMessages', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenBySplitTunnelMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'splitTunnelMode', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenBySplitTunnelModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'splitTunnelMode', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByTheme() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'theme', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByThemeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'theme', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByThemeChosen() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeChosen', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByThemeChosenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeChosen', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByTunMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tunMode', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByTunModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tunMode', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension AppSettingsQueryWhereDistinct
    on QueryBuilder<AppSettings, AppSettings, QDistinct> {
  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByAutoUpdateHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'autoUpdateHours');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByAutoUpdateSubscription() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'autoUpdateSubscription');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByBypassRussia() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bypassRussia');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByKillSwitch() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'killSwitch');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByLaunchAtStartup() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'launchAtStartup');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByShowAnnouncements() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'showAnnouncements');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByShowConnectionMessages() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'showConnectionMessages');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctBySplitTunnelMode(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'splitTunnelMode',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctBySplitTunnelPackages() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'splitTunnelPackages');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByTheme(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'theme', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByThemeChosen() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'themeChosen');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByTunMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tunMode');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension AppSettingsQueryProperty
    on QueryBuilder<AppSettings, AppSettings, QQueryProperty> {
  QueryBuilder<AppSettings, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AppSettings, int, QQueryOperations> autoUpdateHoursProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'autoUpdateHours');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations>
      autoUpdateSubscriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'autoUpdateSubscription');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> bypassRussiaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bypassRussia');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> killSwitchProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'killSwitch');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> launchAtStartupProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'launchAtStartup');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations>
      showAnnouncementsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'showAnnouncements');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations>
      showConnectionMessagesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'showConnectionMessages');
    });
  }

  QueryBuilder<AppSettings, SplitTunnelMode, QQueryOperations>
      splitTunnelModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'splitTunnelMode');
    });
  }

  QueryBuilder<AppSettings, List<String>, QQueryOperations>
      splitTunnelPackagesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'splitTunnelPackages');
    });
  }

  QueryBuilder<AppSettings, ThemePreference, QQueryOperations> themeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'theme');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> themeChosenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'themeChosen');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> tunModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tunMode');
    });
  }

  QueryBuilder<AppSettings, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
