// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track_session.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetTrackSessionCollection on Isar {
  IsarCollection<int, TrackSession> get trackSessions => this.collection();
}

const TrackSessionSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'TrackSession',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(
        name: 'siteId',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'url',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'tracks',
        type: IsarType.stringList,
      ),
      IsarPropertySchema(
        name: 'chrId',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'chrName',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'speciesName',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'speciesId',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'autoSave',
        type: IsarType.bool,
      ),
      IsarPropertySchema(
        name: 'saveTime',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'updateTime',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'rangeList',
        type: IsarType.doubleList,
      ),
    ],
    indexes: [],
  ),
  converter: IsarObjectConverter<int, TrackSession>(
    serialize: serializeTrackSession,
    deserialize: deserializeTrackSession,
    deserializeProperty: deserializeTrackSessionProp,
  ),
  embeddedSchemas: [],
);

@isarProtected
int serializeTrackSession(IsarWriter writer, TrackSession object) {
  IsarCore.writeLong(writer, 1, object.siteId);
  IsarCore.writeString(writer, 2, object.url);
  {
    final list = object.tracks;
    if (list == null) {
      IsarCore.writeNull(writer, 3);
    } else {
      final listWriter = IsarCore.beginList(writer, 3, list.length);
      for (var i = 0; i < list.length; i++) {
        IsarCore.writeString(listWriter, i, list[i]);
      }
      IsarCore.endList(writer, listWriter);
    }
  }
  {
    final value = object.chrId;
    if (value == null) {
      IsarCore.writeNull(writer, 4);
    } else {
      IsarCore.writeString(writer, 4, value);
    }
  }
  {
    final value = object.chrName;
    if (value == null) {
      IsarCore.writeNull(writer, 5);
    } else {
      IsarCore.writeString(writer, 5, value);
    }
  }
  {
    final value = object.speciesName;
    if (value == null) {
      IsarCore.writeNull(writer, 6);
    } else {
      IsarCore.writeString(writer, 6, value);
    }
  }
  IsarCore.writeString(writer, 7, object.speciesId);
  IsarCore.writeBool(writer, 8, object.autoSave);
  IsarCore.writeLong(writer, 9, object.saveTime ?? -9223372036854775808);
  IsarCore.writeLong(writer, 10, object.updateTime ?? -9223372036854775808);
  {
    final list = object.rangeList;
    if (list == null) {
      IsarCore.writeNull(writer, 11);
    } else {
      final listWriter = IsarCore.beginList(writer, 11, list.length);
      for (var i = 0; i < list.length; i++) {
        IsarCore.writeDouble(listWriter, i, list[i]);
      }
      IsarCore.endList(writer, listWriter);
    }
  }
  return object.id;
}

@isarProtected
TrackSession deserializeTrackSession(IsarReader reader) {
  final int _siteId;
  _siteId = IsarCore.readLong(reader, 1);
  final String _url;
  _url = IsarCore.readString(reader, 2) ?? '';
  final List<String>? _tracks;
  {
    final length = IsarCore.readList(reader, 3, IsarCore.readerPtrPtr);
    {
      final reader = IsarCore.readerPtr;
      if (reader.isNull) {
        _tracks = null;
      } else {
        final list = List<String>.filled(length, '', growable: true);
        for (var i = 0; i < length; i++) {
          list[i] = IsarCore.readString(reader, i) ?? '';
        }
        IsarCore.freeReader(reader);
        _tracks = list;
      }
    }
  }
  final String? _chrId;
  _chrId = IsarCore.readString(reader, 4);
  final String? _chrName;
  _chrName = IsarCore.readString(reader, 5);
  final String? _speciesName;
  _speciesName = IsarCore.readString(reader, 6);
  final String _speciesId;
  _speciesId = IsarCore.readString(reader, 7) ?? '';
  final bool _autoSave;
  {
    if (IsarCore.readNull(reader, 8)) {
      _autoSave = true;
    } else {
      _autoSave = IsarCore.readBool(reader, 8);
    }
  }
  final object = TrackSession(
    siteId: _siteId,
    url: _url,
    tracks: _tracks,
    chrId: _chrId,
    chrName: _chrName,
    speciesName: _speciesName,
    speciesId: _speciesId,
    autoSave: _autoSave,
  );
  object.id = IsarCore.readId(reader);
  {
    final value = IsarCore.readLong(reader, 9);
    if (value == -9223372036854775808) {
      object.saveTime = null;
    } else {
      object.saveTime = value;
    }
  }
  {
    final value = IsarCore.readLong(reader, 10);
    if (value == -9223372036854775808) {
      object.updateTime = null;
    } else {
      object.updateTime = value;
    }
  }
  {
    final length = IsarCore.readList(reader, 11, IsarCore.readerPtrPtr);
    {
      final reader = IsarCore.readerPtr;
      if (reader.isNull) {
        object.rangeList = null;
      } else {
        final list = List<double>.filled(length, double.nan, growable: true);
        for (var i = 0; i < length; i++) {
          list[i] = IsarCore.readDouble(reader, i);
        }
        IsarCore.freeReader(reader);
        object.rangeList = list;
      }
    }
  }
  return object;
}

@isarProtected
dynamic deserializeTrackSessionProp(IsarReader reader, int property) {
  switch (property) {
    case 0:
      return IsarCore.readId(reader);
    case 1:
      return IsarCore.readLong(reader, 1);
    case 2:
      return IsarCore.readString(reader, 2) ?? '';
    case 3:
      {
        final length = IsarCore.readList(reader, 3, IsarCore.readerPtrPtr);
        {
          final reader = IsarCore.readerPtr;
          if (reader.isNull) {
            return null;
          } else {
            final list = List<String>.filled(length, '', growable: true);
            for (var i = 0; i < length; i++) {
              list[i] = IsarCore.readString(reader, i) ?? '';
            }
            IsarCore.freeReader(reader);
            return list;
          }
        }
      }
    case 4:
      return IsarCore.readString(reader, 4);
    case 5:
      return IsarCore.readString(reader, 5);
    case 6:
      return IsarCore.readString(reader, 6);
    case 7:
      return IsarCore.readString(reader, 7) ?? '';
    case 8:
      {
        if (IsarCore.readNull(reader, 8)) {
          return true;
        } else {
          return IsarCore.readBool(reader, 8);
        }
      }
    case 9:
      {
        final value = IsarCore.readLong(reader, 9);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return value;
        }
      }
    case 10:
      {
        final value = IsarCore.readLong(reader, 10);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return value;
        }
      }
    case 11:
      {
        final length = IsarCore.readList(reader, 11, IsarCore.readerPtrPtr);
        {
          final reader = IsarCore.readerPtr;
          if (reader.isNull) {
            return null;
          } else {
            final list =
                List<double>.filled(length, double.nan, growable: true);
            for (var i = 0; i < length; i++) {
              list[i] = IsarCore.readDouble(reader, i);
            }
            IsarCore.freeReader(reader);
            return list;
          }
        }
      }
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _TrackSessionUpdate {
  bool call({
    required int id,
    int? siteId,
    String? url,
    String? chrId,
    String? chrName,
    String? speciesName,
    String? speciesId,
    bool? autoSave,
    int? saveTime,
    int? updateTime,
  });
}

class _TrackSessionUpdateImpl implements _TrackSessionUpdate {
  const _TrackSessionUpdateImpl(this.collection);

  final IsarCollection<int, TrackSession> collection;

  @override
  bool call({
    required int id,
    Object? siteId = ignore,
    Object? url = ignore,
    Object? chrId = ignore,
    Object? chrName = ignore,
    Object? speciesName = ignore,
    Object? speciesId = ignore,
    Object? autoSave = ignore,
    Object? saveTime = ignore,
    Object? updateTime = ignore,
  }) {
    return collection.updateProperties([
          id
        ], {
          if (siteId != ignore) 1: siteId as int?,
          if (url != ignore) 2: url as String?,
          if (chrId != ignore) 4: chrId as String?,
          if (chrName != ignore) 5: chrName as String?,
          if (speciesName != ignore) 6: speciesName as String?,
          if (speciesId != ignore) 7: speciesId as String?,
          if (autoSave != ignore) 8: autoSave as bool?,
          if (saveTime != ignore) 9: saveTime as int?,
          if (updateTime != ignore) 10: updateTime as int?,
        }) >
        0;
  }
}

sealed class _TrackSessionUpdateAll {
  int call({
    required List<int> id,
    int? siteId,
    String? url,
    String? chrId,
    String? chrName,
    String? speciesName,
    String? speciesId,
    bool? autoSave,
    int? saveTime,
    int? updateTime,
  });
}

class _TrackSessionUpdateAllImpl implements _TrackSessionUpdateAll {
  const _TrackSessionUpdateAllImpl(this.collection);

  final IsarCollection<int, TrackSession> collection;

  @override
  int call({
    required List<int> id,
    Object? siteId = ignore,
    Object? url = ignore,
    Object? chrId = ignore,
    Object? chrName = ignore,
    Object? speciesName = ignore,
    Object? speciesId = ignore,
    Object? autoSave = ignore,
    Object? saveTime = ignore,
    Object? updateTime = ignore,
  }) {
    return collection.updateProperties(id, {
      if (siteId != ignore) 1: siteId as int?,
      if (url != ignore) 2: url as String?,
      if (chrId != ignore) 4: chrId as String?,
      if (chrName != ignore) 5: chrName as String?,
      if (speciesName != ignore) 6: speciesName as String?,
      if (speciesId != ignore) 7: speciesId as String?,
      if (autoSave != ignore) 8: autoSave as bool?,
      if (saveTime != ignore) 9: saveTime as int?,
      if (updateTime != ignore) 10: updateTime as int?,
    });
  }
}

extension TrackSessionUpdate on IsarCollection<int, TrackSession> {
  _TrackSessionUpdate get update => _TrackSessionUpdateImpl(this);

  _TrackSessionUpdateAll get updateAll => _TrackSessionUpdateAllImpl(this);
}

sealed class _TrackSessionQueryUpdate {
  int call({
    int? siteId,
    String? url,
    String? chrId,
    String? chrName,
    String? speciesName,
    String? speciesId,
    bool? autoSave,
    int? saveTime,
    int? updateTime,
  });
}

class _TrackSessionQueryUpdateImpl implements _TrackSessionQueryUpdate {
  const _TrackSessionQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<TrackSession> query;
  final int? limit;

  @override
  int call({
    Object? siteId = ignore,
    Object? url = ignore,
    Object? chrId = ignore,
    Object? chrName = ignore,
    Object? speciesName = ignore,
    Object? speciesId = ignore,
    Object? autoSave = ignore,
    Object? saveTime = ignore,
    Object? updateTime = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (siteId != ignore) 1: siteId as int?,
      if (url != ignore) 2: url as String?,
      if (chrId != ignore) 4: chrId as String?,
      if (chrName != ignore) 5: chrName as String?,
      if (speciesName != ignore) 6: speciesName as String?,
      if (speciesId != ignore) 7: speciesId as String?,
      if (autoSave != ignore) 8: autoSave as bool?,
      if (saveTime != ignore) 9: saveTime as int?,
      if (updateTime != ignore) 10: updateTime as int?,
    });
  }
}

extension TrackSessionQueryUpdate on IsarQuery<TrackSession> {
  _TrackSessionQueryUpdate get updateFirst =>
      _TrackSessionQueryUpdateImpl(this, limit: 1);

  _TrackSessionQueryUpdate get updateAll => _TrackSessionQueryUpdateImpl(this);
}

class _TrackSessionQueryBuilderUpdateImpl implements _TrackSessionQueryUpdate {
  const _TrackSessionQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<TrackSession, TrackSession, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? siteId = ignore,
    Object? url = ignore,
    Object? chrId = ignore,
    Object? chrName = ignore,
    Object? speciesName = ignore,
    Object? speciesId = ignore,
    Object? autoSave = ignore,
    Object? saveTime = ignore,
    Object? updateTime = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (siteId != ignore) 1: siteId as int?,
        if (url != ignore) 2: url as String?,
        if (chrId != ignore) 4: chrId as String?,
        if (chrName != ignore) 5: chrName as String?,
        if (speciesName != ignore) 6: speciesName as String?,
        if (speciesId != ignore) 7: speciesId as String?,
        if (autoSave != ignore) 8: autoSave as bool?,
        if (saveTime != ignore) 9: saveTime as int?,
        if (updateTime != ignore) 10: updateTime as int?,
      });
    } finally {
      q.close();
    }
  }
}

extension TrackSessionQueryBuilderUpdate
    on QueryBuilder<TrackSession, TrackSession, QOperations> {
  _TrackSessionQueryUpdate get updateFirst =>
      _TrackSessionQueryBuilderUpdateImpl(this, limit: 1);

  _TrackSessionQueryUpdate get updateAll =>
      _TrackSessionQueryBuilderUpdateImpl(this);
}

extension TrackSessionQueryFilter
    on QueryBuilder<TrackSession, TrackSession, QFilterCondition> {
  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition> idEqualTo(
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

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
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

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      idLessThanOrEqualTo(
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

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition> idBetween(
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

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition> siteIdEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 1,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      siteIdGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 1,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      siteIdGreaterThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 1,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      siteIdLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 1,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      siteIdLessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 1,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition> siteIdBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 1,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition> urlEqualTo(
    String value, {
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

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      urlGreaterThan(
    String value, {
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

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      urlGreaterThanOrEqualTo(
    String value, {
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

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition> urlLessThan(
    String value, {
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

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      urlLessThanOrEqualTo(
    String value, {
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

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition> urlBetween(
    String lower,
    String upper, {
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

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition> urlStartsWith(
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

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition> urlEndsWith(
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

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition> urlContains(
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

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition> urlMatches(
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

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition> urlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      urlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      tracksIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 3));
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      tracksIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 3));
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      tracksElementEqualTo(
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

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      tracksElementGreaterThan(
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

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      tracksElementGreaterThanOrEqualTo(
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

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      tracksElementLessThan(
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

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      tracksElementLessThanOrEqualTo(
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

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      tracksElementBetween(
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

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      tracksElementStartsWith(
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

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      tracksElementEndsWith(
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

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      tracksElementContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      tracksElementMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      tracksElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 3,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      tracksElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 3,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      tracksIsEmpty() {
    return not().group(
      (q) => q.tracksIsNull().or().tracksIsNotEmpty(),
    );
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      tracksIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterOrEqualCondition(property: 3, value: null),
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      chrIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 4));
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      chrIdIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 4));
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition> chrIdEqualTo(
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

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      chrIdGreaterThan(
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

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      chrIdGreaterThanOrEqualTo(
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

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition> chrIdLessThan(
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

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      chrIdLessThanOrEqualTo(
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

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition> chrIdBetween(
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

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      chrIdStartsWith(
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

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition> chrIdEndsWith(
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

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition> chrIdContains(
      String value,
      {bool caseSensitive = true}) {
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

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition> chrIdMatches(
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

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      chrIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 4,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      chrIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 4,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      chrNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 5));
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      chrNameIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 5));
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      chrNameEqualTo(
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

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      chrNameGreaterThan(
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

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      chrNameGreaterThanOrEqualTo(
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

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      chrNameLessThan(
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

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      chrNameLessThanOrEqualTo(
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

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      chrNameBetween(
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

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      chrNameStartsWith(
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

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      chrNameEndsWith(
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

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      chrNameContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      chrNameMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      chrNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 5,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      chrNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 5,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      speciesNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 6));
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      speciesNameIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 6));
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      speciesNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      speciesNameGreaterThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      speciesNameGreaterThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      speciesNameLessThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      speciesNameLessThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      speciesNameBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 6,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      speciesNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      speciesNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      speciesNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      speciesNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 6,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      speciesNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 6,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      speciesNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 6,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      speciesIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      speciesIdGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      speciesIdGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      speciesIdLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      speciesIdLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      speciesIdBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 7,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      speciesIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      speciesIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      speciesIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      speciesIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 7,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      speciesIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 7,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      speciesIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 7,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      autoSaveEqualTo(
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

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      saveTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 9));
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      saveTimeIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 9));
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      saveTimeEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 9,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      saveTimeGreaterThan(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 9,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      saveTimeGreaterThanOrEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 9,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      saveTimeLessThan(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 9,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      saveTimeLessThanOrEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 9,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      saveTimeBetween(
    int? lower,
    int? upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 9,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      updateTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 10));
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      updateTimeIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 10));
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      updateTimeEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 10,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      updateTimeGreaterThan(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 10,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      updateTimeGreaterThanOrEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 10,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      updateTimeLessThan(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 10,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      updateTimeLessThanOrEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 10,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      updateTimeBetween(
    int? lower,
    int? upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 10,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      rangeListIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 11));
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      rangeListIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 11));
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      rangeListElementEqualTo(
    double value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 11,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      rangeListElementGreaterThan(
    double value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 11,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      rangeListElementGreaterThanOrEqualTo(
    double value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 11,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      rangeListElementLessThan(
    double value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 11,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      rangeListElementLessThanOrEqualTo(
    double value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 11,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      rangeListElementBetween(
    double lower,
    double upper, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 11,
          lower: lower,
          upper: upper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      rangeListIsEmpty() {
    return not().group(
      (q) => q.rangeListIsNull().or().rangeListIsNotEmpty(),
    );
  }

  QueryBuilder<TrackSession, TrackSession, QAfterFilterCondition>
      rangeListIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterOrEqualCondition(property: 11, value: null),
      );
    });
  }
}

extension TrackSessionQueryObject
    on QueryBuilder<TrackSession, TrackSession, QFilterCondition> {}

extension TrackSessionQuerySortBy
    on QueryBuilder<TrackSession, TrackSession, QSortBy> {
  QueryBuilder<TrackSession, TrackSession, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterSortBy> sortBySiteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1);
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterSortBy> sortBySiteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc);
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterSortBy> sortByUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterSortBy> sortByUrlDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterSortBy> sortByChrId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        4,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterSortBy> sortByChrIdDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        4,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterSortBy> sortByChrName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        5,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterSortBy> sortByChrNameDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        5,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterSortBy> sortBySpeciesName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        6,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterSortBy> sortBySpeciesNameDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        6,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterSortBy> sortBySpeciesId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        7,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterSortBy> sortBySpeciesIdDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        7,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterSortBy> sortByAutoSave() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8);
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterSortBy> sortByAutoSaveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc);
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterSortBy> sortBySaveTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9);
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterSortBy> sortBySaveTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, sort: Sort.desc);
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterSortBy> sortByUpdateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10);
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterSortBy>
      sortByUpdateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10, sort: Sort.desc);
    });
  }
}

extension TrackSessionQuerySortThenBy
    on QueryBuilder<TrackSession, TrackSession, QSortThenBy> {
  QueryBuilder<TrackSession, TrackSession, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterSortBy> thenBySiteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1);
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterSortBy> thenBySiteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc);
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterSortBy> thenByUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterSortBy> thenByUrlDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterSortBy> thenByChrId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterSortBy> thenByChrIdDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterSortBy> thenByChrName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterSortBy> thenByChrNameDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterSortBy> thenBySpeciesName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterSortBy> thenBySpeciesNameDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterSortBy> thenBySpeciesId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterSortBy> thenBySpeciesIdDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterSortBy> thenByAutoSave() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8);
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterSortBy> thenByAutoSaveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc);
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterSortBy> thenBySaveTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9);
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterSortBy> thenBySaveTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, sort: Sort.desc);
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterSortBy> thenByUpdateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10);
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterSortBy>
      thenByUpdateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10, sort: Sort.desc);
    });
  }
}

extension TrackSessionQueryWhereDistinct
    on QueryBuilder<TrackSession, TrackSession, QDistinct> {
  QueryBuilder<TrackSession, TrackSession, QAfterDistinct> distinctBySiteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1);
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterDistinct> distinctByUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterDistinct> distinctByTracks() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3);
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterDistinct> distinctByChrId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterDistinct> distinctByChrName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(5, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterDistinct>
      distinctBySpeciesName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(6, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterDistinct> distinctBySpeciesId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(7, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterDistinct>
      distinctByAutoSave() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(8);
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterDistinct>
      distinctBySaveTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(9);
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterDistinct>
      distinctByUpdateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(10);
    });
  }

  QueryBuilder<TrackSession, TrackSession, QAfterDistinct>
      distinctByRangeList() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(11);
    });
  }
}

extension TrackSessionQueryProperty1
    on QueryBuilder<TrackSession, TrackSession, QProperty> {
  QueryBuilder<TrackSession, int, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<TrackSession, int, QAfterProperty> siteIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<TrackSession, String, QAfterProperty> urlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<TrackSession, List<String>?, QAfterProperty> tracksProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<TrackSession, String?, QAfterProperty> chrIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<TrackSession, String?, QAfterProperty> chrNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<TrackSession, String?, QAfterProperty> speciesNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<TrackSession, String, QAfterProperty> speciesIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<TrackSession, bool, QAfterProperty> autoSaveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<TrackSession, int?, QAfterProperty> saveTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<TrackSession, int?, QAfterProperty> updateTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<TrackSession, List<double>?, QAfterProperty>
      rangeListProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }
}

extension TrackSessionQueryProperty2<R>
    on QueryBuilder<TrackSession, R, QAfterProperty> {
  QueryBuilder<TrackSession, (R, int), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<TrackSession, (R, int), QAfterProperty> siteIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<TrackSession, (R, String), QAfterProperty> urlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<TrackSession, (R, List<String>?), QAfterProperty>
      tracksProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<TrackSession, (R, String?), QAfterProperty> chrIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<TrackSession, (R, String?), QAfterProperty> chrNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<TrackSession, (R, String?), QAfterProperty>
      speciesNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<TrackSession, (R, String), QAfterProperty> speciesIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<TrackSession, (R, bool), QAfterProperty> autoSaveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<TrackSession, (R, int?), QAfterProperty> saveTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<TrackSession, (R, int?), QAfterProperty> updateTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<TrackSession, (R, List<double>?), QAfterProperty>
      rangeListProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }
}

extension TrackSessionQueryProperty3<R1, R2>
    on QueryBuilder<TrackSession, (R1, R2), QAfterProperty> {
  QueryBuilder<TrackSession, (R1, R2, int), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<TrackSession, (R1, R2, int), QOperations> siteIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<TrackSession, (R1, R2, String), QOperations> urlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<TrackSession, (R1, R2, List<String>?), QOperations>
      tracksProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<TrackSession, (R1, R2, String?), QOperations> chrIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<TrackSession, (R1, R2, String?), QOperations> chrNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<TrackSession, (R1, R2, String?), QOperations>
      speciesNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<TrackSession, (R1, R2, String), QOperations>
      speciesIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<TrackSession, (R1, R2, bool), QOperations> autoSaveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<TrackSession, (R1, R2, int?), QOperations> saveTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<TrackSession, (R1, R2, int?), QOperations> updateTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<TrackSession, (R1, R2, List<double>?), QOperations>
      rangeListProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }
}
