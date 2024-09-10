// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'site_item.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetSiteItemCollection on Isar {
  IsarCollection<int, SiteItem> get siteItems => this.collection();
}

const SiteItemSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'SiteItem',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(
        name: 'source',
        type: IsarType.byte,
        enumMap: {"sgs": 0, "jbrowse": 1, "locale": 2},
      ),
      IsarPropertySchema(
        name: 'name',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'url',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'currentSpecies',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'currentSpeciesId',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'createTime',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'updateTime',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'isDemoServer',
        type: IsarType.bool,
      ),
    ],
    indexes: [],
  ),
  converter: IsarObjectConverter<int, SiteItem>(
    serialize: serializeSiteItem,
    deserialize: deserializeSiteItem,
    deserializeProperty: deserializeSiteItemProp,
  ),
  embeddedSchemas: [],
);

@isarProtected
int serializeSiteItem(IsarWriter writer, SiteItem object) {
  IsarCore.writeByte(writer, 1, object.source.index);
  {
    final value = object.name;
    if (value == null) {
      IsarCore.writeNull(writer, 2);
    } else {
      IsarCore.writeString(writer, 2, value);
    }
  }
  IsarCore.writeString(writer, 3, object.url);
  {
    final value = object.currentSpecies;
    if (value == null) {
      IsarCore.writeNull(writer, 4);
    } else {
      IsarCore.writeString(writer, 4, value);
    }
  }
  {
    final value = object.currentSpeciesId;
    if (value == null) {
      IsarCore.writeNull(writer, 5);
    } else {
      IsarCore.writeString(writer, 5, value);
    }
  }
  IsarCore.writeLong(writer, 6, object.createTime ?? -9223372036854775808);
  IsarCore.writeLong(writer, 7, object.updateTime ?? -9223372036854775808);
  IsarCore.writeBool(writer, 8, object.isDemoServer);
  return object.id;
}

@isarProtected
SiteItem deserializeSiteItem(IsarReader reader) {
  final SiteSource _source;
  {
    if (IsarCore.readNull(reader, 1)) {
      _source = SiteSource.sgs;
    } else {
      _source = _siteItemSource[IsarCore.readByte(reader, 1)] ?? SiteSource.sgs;
    }
  }
  final String? _name;
  _name = IsarCore.readString(reader, 2);
  final String _url;
  _url = IsarCore.readString(reader, 3) ?? '';
  final bool _isDemoServer;
  _isDemoServer = IsarCore.readBool(reader, 8);
  final object = SiteItem(
    source: _source,
    name: _name,
    url: _url,
    isDemoServer: _isDemoServer,
  );
  object.id = IsarCore.readId(reader);
  object.currentSpecies = IsarCore.readString(reader, 4);
  object.currentSpeciesId = IsarCore.readString(reader, 5);
  {
    final value = IsarCore.readLong(reader, 6);
    if (value == -9223372036854775808) {
      object.createTime = null;
    } else {
      object.createTime = value;
    }
  }
  {
    final value = IsarCore.readLong(reader, 7);
    if (value == -9223372036854775808) {
      object.updateTime = null;
    } else {
      object.updateTime = value;
    }
  }
  return object;
}

@isarProtected
dynamic deserializeSiteItemProp(IsarReader reader, int property) {
  switch (property) {
    case 0:
      return IsarCore.readId(reader);
    case 1:
      {
        if (IsarCore.readNull(reader, 1)) {
          return SiteSource.sgs;
        } else {
          return _siteItemSource[IsarCore.readByte(reader, 1)] ??
              SiteSource.sgs;
        }
      }
    case 2:
      return IsarCore.readString(reader, 2);
    case 3:
      return IsarCore.readString(reader, 3) ?? '';
    case 4:
      return IsarCore.readString(reader, 4);
    case 5:
      return IsarCore.readString(reader, 5);
    case 6:
      {
        final value = IsarCore.readLong(reader, 6);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return value;
        }
      }
    case 7:
      {
        final value = IsarCore.readLong(reader, 7);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return value;
        }
      }
    case 8:
      return IsarCore.readBool(reader, 8);
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _SiteItemUpdate {
  bool call({
    required int id,
    SiteSource? source,
    String? name,
    String? url,
    String? currentSpecies,
    String? currentSpeciesId,
    int? createTime,
    int? updateTime,
    bool? isDemoServer,
  });
}

class _SiteItemUpdateImpl implements _SiteItemUpdate {
  const _SiteItemUpdateImpl(this.collection);

  final IsarCollection<int, SiteItem> collection;

  @override
  bool call({
    required int id,
    Object? source = ignore,
    Object? name = ignore,
    Object? url = ignore,
    Object? currentSpecies = ignore,
    Object? currentSpeciesId = ignore,
    Object? createTime = ignore,
    Object? updateTime = ignore,
    Object? isDemoServer = ignore,
  }) {
    return collection.updateProperties([
          id
        ], {
          if (source != ignore) 1: source as SiteSource?,
          if (name != ignore) 2: name as String?,
          if (url != ignore) 3: url as String?,
          if (currentSpecies != ignore) 4: currentSpecies as String?,
          if (currentSpeciesId != ignore) 5: currentSpeciesId as String?,
          if (createTime != ignore) 6: createTime as int?,
          if (updateTime != ignore) 7: updateTime as int?,
          if (isDemoServer != ignore) 8: isDemoServer as bool?,
        }) >
        0;
  }
}

sealed class _SiteItemUpdateAll {
  int call({
    required List<int> id,
    SiteSource? source,
    String? name,
    String? url,
    String? currentSpecies,
    String? currentSpeciesId,
    int? createTime,
    int? updateTime,
    bool? isDemoServer,
  });
}

class _SiteItemUpdateAllImpl implements _SiteItemUpdateAll {
  const _SiteItemUpdateAllImpl(this.collection);

  final IsarCollection<int, SiteItem> collection;

  @override
  int call({
    required List<int> id,
    Object? source = ignore,
    Object? name = ignore,
    Object? url = ignore,
    Object? currentSpecies = ignore,
    Object? currentSpeciesId = ignore,
    Object? createTime = ignore,
    Object? updateTime = ignore,
    Object? isDemoServer = ignore,
  }) {
    return collection.updateProperties(id, {
      if (source != ignore) 1: source as SiteSource?,
      if (name != ignore) 2: name as String?,
      if (url != ignore) 3: url as String?,
      if (currentSpecies != ignore) 4: currentSpecies as String?,
      if (currentSpeciesId != ignore) 5: currentSpeciesId as String?,
      if (createTime != ignore) 6: createTime as int?,
      if (updateTime != ignore) 7: updateTime as int?,
      if (isDemoServer != ignore) 8: isDemoServer as bool?,
    });
  }
}

extension SiteItemUpdate on IsarCollection<int, SiteItem> {
  _SiteItemUpdate get update => _SiteItemUpdateImpl(this);

  _SiteItemUpdateAll get updateAll => _SiteItemUpdateAllImpl(this);
}

sealed class _SiteItemQueryUpdate {
  int call({
    SiteSource? source,
    String? name,
    String? url,
    String? currentSpecies,
    String? currentSpeciesId,
    int? createTime,
    int? updateTime,
    bool? isDemoServer,
  });
}

class _SiteItemQueryUpdateImpl implements _SiteItemQueryUpdate {
  const _SiteItemQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<SiteItem> query;
  final int? limit;

  @override
  int call({
    Object? source = ignore,
    Object? name = ignore,
    Object? url = ignore,
    Object? currentSpecies = ignore,
    Object? currentSpeciesId = ignore,
    Object? createTime = ignore,
    Object? updateTime = ignore,
    Object? isDemoServer = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (source != ignore) 1: source as SiteSource?,
      if (name != ignore) 2: name as String?,
      if (url != ignore) 3: url as String?,
      if (currentSpecies != ignore) 4: currentSpecies as String?,
      if (currentSpeciesId != ignore) 5: currentSpeciesId as String?,
      if (createTime != ignore) 6: createTime as int?,
      if (updateTime != ignore) 7: updateTime as int?,
      if (isDemoServer != ignore) 8: isDemoServer as bool?,
    });
  }
}

extension SiteItemQueryUpdate on IsarQuery<SiteItem> {
  _SiteItemQueryUpdate get updateFirst =>
      _SiteItemQueryUpdateImpl(this, limit: 1);

  _SiteItemQueryUpdate get updateAll => _SiteItemQueryUpdateImpl(this);
}

class _SiteItemQueryBuilderUpdateImpl implements _SiteItemQueryUpdate {
  const _SiteItemQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<SiteItem, SiteItem, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? source = ignore,
    Object? name = ignore,
    Object? url = ignore,
    Object? currentSpecies = ignore,
    Object? currentSpeciesId = ignore,
    Object? createTime = ignore,
    Object? updateTime = ignore,
    Object? isDemoServer = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (source != ignore) 1: source as SiteSource?,
        if (name != ignore) 2: name as String?,
        if (url != ignore) 3: url as String?,
        if (currentSpecies != ignore) 4: currentSpecies as String?,
        if (currentSpeciesId != ignore) 5: currentSpeciesId as String?,
        if (createTime != ignore) 6: createTime as int?,
        if (updateTime != ignore) 7: updateTime as int?,
        if (isDemoServer != ignore) 8: isDemoServer as bool?,
      });
    } finally {
      q.close();
    }
  }
}

extension SiteItemQueryBuilderUpdate
    on QueryBuilder<SiteItem, SiteItem, QOperations> {
  _SiteItemQueryUpdate get updateFirst =>
      _SiteItemQueryBuilderUpdateImpl(this, limit: 1);

  _SiteItemQueryUpdate get updateAll => _SiteItemQueryBuilderUpdateImpl(this);
}

const _siteItemSource = {
  0: SiteSource.sgs,
  1: SiteSource.jbrowse,
  2: SiteSource.locale,
};

extension SiteItemQueryFilter
    on QueryBuilder<SiteItem, SiteItem, QFilterCondition> {
  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition> idEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition> idGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition>
      idGreaterThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition> idLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition> idLessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition> idBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 0,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition> sourceEqualTo(
    SiteSource value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 1,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition> sourceGreaterThan(
    SiteSource value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 1,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition>
      sourceGreaterThanOrEqualTo(
    SiteSource value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 1,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition> sourceLessThan(
    SiteSource value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 1,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition>
      sourceLessThanOrEqualTo(
    SiteSource value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 1,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition> sourceBetween(
    SiteSource lower,
    SiteSource upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 1,
          lower: lower.index,
          upper: upper.index,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition> nameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 2));
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition> nameIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 2));
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition> nameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition> nameGreaterThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition>
      nameGreaterThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition> nameLessThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition> nameLessThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition> nameBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 2,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 2,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition> urlEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition> urlGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition>
      urlGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition> urlLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition> urlLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition> urlBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 3,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition> urlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition> urlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition> urlContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition> urlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 3,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition> urlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 3,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition> urlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 3,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition>
      currentSpeciesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 4));
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition>
      currentSpeciesIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 4));
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition> currentSpeciesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition>
      currentSpeciesGreaterThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition>
      currentSpeciesGreaterThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition>
      currentSpeciesLessThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition>
      currentSpeciesLessThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition> currentSpeciesBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 4,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition>
      currentSpeciesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition>
      currentSpeciesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition>
      currentSpeciesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition> currentSpeciesMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 4,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition>
      currentSpeciesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 4,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition>
      currentSpeciesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 4,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition>
      currentSpeciesIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 5));
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition>
      currentSpeciesIdIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 5));
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition>
      currentSpeciesIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition>
      currentSpeciesIdGreaterThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition>
      currentSpeciesIdGreaterThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition>
      currentSpeciesIdLessThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition>
      currentSpeciesIdLessThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition>
      currentSpeciesIdBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 5,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition>
      currentSpeciesIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition>
      currentSpeciesIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition>
      currentSpeciesIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition>
      currentSpeciesIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 5,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition>
      currentSpeciesIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 5,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition>
      currentSpeciesIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 5,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition> createTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 6));
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition>
      createTimeIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 6));
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition> createTimeEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 6,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition> createTimeGreaterThan(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 6,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition>
      createTimeGreaterThanOrEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 6,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition> createTimeLessThan(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 6,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition>
      createTimeLessThanOrEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 6,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition> createTimeBetween(
    int? lower,
    int? upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 6,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition> updateTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 7));
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition>
      updateTimeIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 7));
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition> updateTimeEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 7,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition> updateTimeGreaterThan(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 7,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition>
      updateTimeGreaterThanOrEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 7,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition> updateTimeLessThan(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 7,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition>
      updateTimeLessThanOrEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 7,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition> updateTimeBetween(
    int? lower,
    int? upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 7,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterFilterCondition> isDemoServerEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 8,
          value: value,
        ),
      );
    });
  }
}

extension SiteItemQueryObject
    on QueryBuilder<SiteItem, SiteItem, QFilterCondition> {}

extension SiteItemQuerySortBy on QueryBuilder<SiteItem, SiteItem, QSortBy> {
  QueryBuilder<SiteItem, SiteItem, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterSortBy> sortBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1);
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterSortBy> sortBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc);
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterSortBy> sortByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterSortBy> sortByNameDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterSortBy> sortByUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        3,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterSortBy> sortByUrlDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        3,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterSortBy> sortByCurrentSpecies(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        4,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterSortBy> sortByCurrentSpeciesDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        4,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterSortBy> sortByCurrentSpeciesId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        5,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterSortBy> sortByCurrentSpeciesIdDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        5,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterSortBy> sortByCreateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterSortBy> sortByCreateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterSortBy> sortByUpdateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7);
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterSortBy> sortByUpdateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc);
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterSortBy> sortByIsDemoServer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8);
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterSortBy> sortByIsDemoServerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc);
    });
  }
}

extension SiteItemQuerySortThenBy
    on QueryBuilder<SiteItem, SiteItem, QSortThenBy> {
  QueryBuilder<SiteItem, SiteItem, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterSortBy> thenBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1);
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterSortBy> thenBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc);
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterSortBy> thenByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterSortBy> thenByNameDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterSortBy> thenByUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterSortBy> thenByUrlDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterSortBy> thenByCurrentSpecies(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterSortBy> thenByCurrentSpeciesDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterSortBy> thenByCurrentSpeciesId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterSortBy> thenByCurrentSpeciesIdDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterSortBy> thenByCreateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterSortBy> thenByCreateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterSortBy> thenByUpdateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7);
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterSortBy> thenByUpdateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc);
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterSortBy> thenByIsDemoServer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8);
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterSortBy> thenByIsDemoServerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc);
    });
  }
}

extension SiteItemQueryWhereDistinct
    on QueryBuilder<SiteItem, SiteItem, QDistinct> {
  QueryBuilder<SiteItem, SiteItem, QAfterDistinct> distinctBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1);
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterDistinct> distinctByUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterDistinct> distinctByCurrentSpecies(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterDistinct> distinctByCurrentSpeciesId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(5, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterDistinct> distinctByCreateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(6);
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterDistinct> distinctByUpdateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(7);
    });
  }

  QueryBuilder<SiteItem, SiteItem, QAfterDistinct> distinctByIsDemoServer() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(8);
    });
  }
}

extension SiteItemQueryProperty1
    on QueryBuilder<SiteItem, SiteItem, QProperty> {
  QueryBuilder<SiteItem, int, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<SiteItem, SiteSource, QAfterProperty> sourceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<SiteItem, String?, QAfterProperty> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<SiteItem, String, QAfterProperty> urlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<SiteItem, String?, QAfterProperty> currentSpeciesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<SiteItem, String?, QAfterProperty> currentSpeciesIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<SiteItem, int?, QAfterProperty> createTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<SiteItem, int?, QAfterProperty> updateTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<SiteItem, bool, QAfterProperty> isDemoServerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }
}

extension SiteItemQueryProperty2<R>
    on QueryBuilder<SiteItem, R, QAfterProperty> {
  QueryBuilder<SiteItem, (R, int), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<SiteItem, (R, SiteSource), QAfterProperty> sourceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<SiteItem, (R, String?), QAfterProperty> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<SiteItem, (R, String), QAfterProperty> urlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<SiteItem, (R, String?), QAfterProperty>
      currentSpeciesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<SiteItem, (R, String?), QAfterProperty>
      currentSpeciesIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<SiteItem, (R, int?), QAfterProperty> createTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<SiteItem, (R, int?), QAfterProperty> updateTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<SiteItem, (R, bool), QAfterProperty> isDemoServerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }
}

extension SiteItemQueryProperty3<R1, R2>
    on QueryBuilder<SiteItem, (R1, R2), QAfterProperty> {
  QueryBuilder<SiteItem, (R1, R2, int), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<SiteItem, (R1, R2, SiteSource), QOperations> sourceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<SiteItem, (R1, R2, String?), QOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<SiteItem, (R1, R2, String), QOperations> urlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<SiteItem, (R1, R2, String?), QOperations>
      currentSpeciesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<SiteItem, (R1, R2, String?), QOperations>
      currentSpeciesIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<SiteItem, (R1, R2, int?), QOperations> createTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<SiteItem, (R1, R2, int?), QOperations> updateTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<SiteItem, (R1, R2, bool), QOperations> isDemoServerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }
}
