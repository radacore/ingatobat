// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $FamilyGroupsTable extends FamilyGroups
    with TableInfo<$FamilyGroupsTable, FamilyGroup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FamilyGroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerEmailMeta = const VerificationMeta(
    'ownerEmail',
  );
  @override
  late final GeneratedColumn<String> ownerEmail = GeneratedColumn<String>(
    'owner_email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> serverUpdatedAt = GeneratedColumn<int>(
    'server_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    ownerEmail,
    createdAt,
    updatedAt,
    serverUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'family_groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<FamilyGroup> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('owner_email')) {
      context.handle(
        _ownerEmailMeta,
        ownerEmail.isAcceptableOrUnknown(data['owner_email']!, _ownerEmailMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerEmailMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FamilyGroup map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FamilyGroup(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      ownerEmail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_email'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_updated_at'],
      ),
    );
  }

  @override
  $FamilyGroupsTable createAlias(String alias) {
    return $FamilyGroupsTable(attachedDatabase, alias);
  }
}

class FamilyGroup extends DataClass implements Insertable<FamilyGroup> {
  final String id;
  final String name;
  final String ownerEmail;
  final int createdAt;
  final int updatedAt;
  final int? serverUpdatedAt;
  const FamilyGroup({
    required this.id,
    required this.name,
    required this.ownerEmail,
    required this.createdAt,
    required this.updatedAt,
    this.serverUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['owner_email'] = Variable<String>(ownerEmail);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt);
    }
    return map;
  }

  FamilyGroupsCompanion toCompanion(bool nullToAbsent) {
    return FamilyGroupsCompanion(
      id: Value(id),
      name: Value(name),
      ownerEmail: Value(ownerEmail),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
    );
  }

  factory FamilyGroup.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FamilyGroup(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      ownerEmail: serializer.fromJson<String>(json['ownerEmail']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      serverUpdatedAt: serializer.fromJson<int?>(json['serverUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'ownerEmail': serializer.toJson<String>(ownerEmail),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'serverUpdatedAt': serializer.toJson<int?>(serverUpdatedAt),
    };
  }

  FamilyGroup copyWith({
    String? id,
    String? name,
    String? ownerEmail,
    int? createdAt,
    int? updatedAt,
    Value<int?> serverUpdatedAt = const Value.absent(),
  }) => FamilyGroup(
    id: id ?? this.id,
    name: name ?? this.name,
    ownerEmail: ownerEmail ?? this.ownerEmail,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
  );
  FamilyGroup copyWithCompanion(FamilyGroupsCompanion data) {
    return FamilyGroup(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      ownerEmail: data.ownerEmail.present
          ? data.ownerEmail.value
          : this.ownerEmail,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FamilyGroup(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('ownerEmail: $ownerEmail, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, ownerEmail, createdAt, updatedAt, serverUpdatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FamilyGroup &&
          other.id == this.id &&
          other.name == this.name &&
          other.ownerEmail == this.ownerEmail &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt);
}

class FamilyGroupsCompanion extends UpdateCompanion<FamilyGroup> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> ownerEmail;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> serverUpdatedAt;
  final Value<int> rowid;
  const FamilyGroupsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.ownerEmail = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FamilyGroupsCompanion.insert({
    required String id,
    required String name,
    required String ownerEmail,
    required int createdAt,
    required int updatedAt,
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       ownerEmail = Value(ownerEmail),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<FamilyGroup> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? ownerEmail,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? serverUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (ownerEmail != null) 'owner_email': ownerEmail,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FamilyGroupsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? ownerEmail,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? serverUpdatedAt,
    Value<int>? rowid,
  }) {
    return FamilyGroupsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (ownerEmail.present) {
      map['owner_email'] = Variable<String>(ownerEmail.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FamilyGroupsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('ownerEmail: $ownerEmail, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FamilyMemberAccessesTable extends FamilyMemberAccesses
    with TableInfo<$FamilyMemberAccessesTable, FamilyMemberAccessesData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FamilyMemberAccessesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _familyIdMeta = const VerificationMeta(
    'familyId',
  );
  @override
  late final GeneratedColumn<String> familyId = GeneratedColumn<String>(
    'family_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('member'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('invited'),
  );
  static const VerificationMeta _joinedAtMeta = const VerificationMeta(
    'joinedAt',
  );
  @override
  late final GeneratedColumn<int> joinedAt = GeneratedColumn<int>(
    'joined_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> serverUpdatedAt = GeneratedColumn<int>(
    'server_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    familyId,
    email,
    role,
    status,
    joinedAt,
    updatedAt,
    serverUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'family_member_accesses';
  @override
  VerificationContext validateIntegrity(
    Insertable<FamilyMemberAccessesData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('family_id')) {
      context.handle(
        _familyIdMeta,
        familyId.isAcceptableOrUnknown(data['family_id']!, _familyIdMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('joined_at')) {
      context.handle(
        _joinedAtMeta,
        joinedAt.isAcceptableOrUnknown(data['joined_at']!, _joinedAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FamilyMemberAccessesData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FamilyMemberAccessesData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      familyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family_id'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      joinedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}joined_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_updated_at'],
      ),
    );
  }

  @override
  $FamilyMemberAccessesTable createAlias(String alias) {
    return $FamilyMemberAccessesTable(attachedDatabase, alias);
  }
}

class FamilyMemberAccessesData extends DataClass
    implements Insertable<FamilyMemberAccessesData> {
  final String id;
  final String? familyId;
  final String email;
  final String role;
  final String status;
  final int? joinedAt;
  final int updatedAt;
  final int? serverUpdatedAt;
  const FamilyMemberAccessesData({
    required this.id,
    this.familyId,
    required this.email,
    required this.role,
    required this.status,
    this.joinedAt,
    required this.updatedAt,
    this.serverUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || familyId != null) {
      map['family_id'] = Variable<String>(familyId);
    }
    map['email'] = Variable<String>(email);
    map['role'] = Variable<String>(role);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || joinedAt != null) {
      map['joined_at'] = Variable<int>(joinedAt);
    }
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt);
    }
    return map;
  }

  FamilyMemberAccessesCompanion toCompanion(bool nullToAbsent) {
    return FamilyMemberAccessesCompanion(
      id: Value(id),
      familyId: familyId == null && nullToAbsent
          ? const Value.absent()
          : Value(familyId),
      email: Value(email),
      role: Value(role),
      status: Value(status),
      joinedAt: joinedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(joinedAt),
      updatedAt: Value(updatedAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
    );
  }

  factory FamilyMemberAccessesData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FamilyMemberAccessesData(
      id: serializer.fromJson<String>(json['id']),
      familyId: serializer.fromJson<String?>(json['familyId']),
      email: serializer.fromJson<String>(json['email']),
      role: serializer.fromJson<String>(json['role']),
      status: serializer.fromJson<String>(json['status']),
      joinedAt: serializer.fromJson<int?>(json['joinedAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      serverUpdatedAt: serializer.fromJson<int?>(json['serverUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'familyId': serializer.toJson<String?>(familyId),
      'email': serializer.toJson<String>(email),
      'role': serializer.toJson<String>(role),
      'status': serializer.toJson<String>(status),
      'joinedAt': serializer.toJson<int?>(joinedAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'serverUpdatedAt': serializer.toJson<int?>(serverUpdatedAt),
    };
  }

  FamilyMemberAccessesData copyWith({
    String? id,
    Value<String?> familyId = const Value.absent(),
    String? email,
    String? role,
    String? status,
    Value<int?> joinedAt = const Value.absent(),
    int? updatedAt,
    Value<int?> serverUpdatedAt = const Value.absent(),
  }) => FamilyMemberAccessesData(
    id: id ?? this.id,
    familyId: familyId.present ? familyId.value : this.familyId,
    email: email ?? this.email,
    role: role ?? this.role,
    status: status ?? this.status,
    joinedAt: joinedAt.present ? joinedAt.value : this.joinedAt,
    updatedAt: updatedAt ?? this.updatedAt,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
  );
  FamilyMemberAccessesData copyWithCompanion(
    FamilyMemberAccessesCompanion data,
  ) {
    return FamilyMemberAccessesData(
      id: data.id.present ? data.id.value : this.id,
      familyId: data.familyId.present ? data.familyId.value : this.familyId,
      email: data.email.present ? data.email.value : this.email,
      role: data.role.present ? data.role.value : this.role,
      status: data.status.present ? data.status.value : this.status,
      joinedAt: data.joinedAt.present ? data.joinedAt.value : this.joinedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FamilyMemberAccessesData(')
          ..write('id: $id, ')
          ..write('familyId: $familyId, ')
          ..write('email: $email, ')
          ..write('role: $role, ')
          ..write('status: $status, ')
          ..write('joinedAt: $joinedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    familyId,
    email,
    role,
    status,
    joinedAt,
    updatedAt,
    serverUpdatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FamilyMemberAccessesData &&
          other.id == this.id &&
          other.familyId == this.familyId &&
          other.email == this.email &&
          other.role == this.role &&
          other.status == this.status &&
          other.joinedAt == this.joinedAt &&
          other.updatedAt == this.updatedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt);
}

class FamilyMemberAccessesCompanion
    extends UpdateCompanion<FamilyMemberAccessesData> {
  final Value<String> id;
  final Value<String?> familyId;
  final Value<String> email;
  final Value<String> role;
  final Value<String> status;
  final Value<int?> joinedAt;
  final Value<int> updatedAt;
  final Value<int?> serverUpdatedAt;
  final Value<int> rowid;
  const FamilyMemberAccessesCompanion({
    this.id = const Value.absent(),
    this.familyId = const Value.absent(),
    this.email = const Value.absent(),
    this.role = const Value.absent(),
    this.status = const Value.absent(),
    this.joinedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FamilyMemberAccessesCompanion.insert({
    required String id,
    this.familyId = const Value.absent(),
    required String email,
    this.role = const Value.absent(),
    this.status = const Value.absent(),
    this.joinedAt = const Value.absent(),
    required int updatedAt,
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       email = Value(email),
       updatedAt = Value(updatedAt);
  static Insertable<FamilyMemberAccessesData> custom({
    Expression<String>? id,
    Expression<String>? familyId,
    Expression<String>? email,
    Expression<String>? role,
    Expression<String>? status,
    Expression<int>? joinedAt,
    Expression<int>? updatedAt,
    Expression<int>? serverUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (familyId != null) 'family_id': familyId,
      if (email != null) 'email': email,
      if (role != null) 'role': role,
      if (status != null) 'status': status,
      if (joinedAt != null) 'joined_at': joinedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FamilyMemberAccessesCompanion copyWith({
    Value<String>? id,
    Value<String?>? familyId,
    Value<String>? email,
    Value<String>? role,
    Value<String>? status,
    Value<int?>? joinedAt,
    Value<int>? updatedAt,
    Value<int?>? serverUpdatedAt,
    Value<int>? rowid,
  }) {
    return FamilyMemberAccessesCompanion(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      email: email ?? this.email,
      role: role ?? this.role,
      status: status ?? this.status,
      joinedAt: joinedAt ?? this.joinedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (familyId.present) {
      map['family_id'] = Variable<String>(familyId.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (joinedAt.present) {
      map['joined_at'] = Variable<int>(joinedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FamilyMemberAccessesCompanion(')
          ..write('id: $id, ')
          ..write('familyId: $familyId, ')
          ..write('email: $email, ')
          ..write('role: $role, ')
          ..write('status: $status, ')
          ..write('joinedAt: $joinedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DevicesTable extends Devices with TableInfo<$DevicesTable, Device> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DevicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _familyIdMeta = const VerificationMeta(
    'familyId',
  );
  @override
  late final GeneratedColumn<String> familyId = GeneratedColumn<String>(
    'family_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fcmTokenMeta = const VerificationMeta(
    'fcmToken',
  );
  @override
  late final GeneratedColumn<String> fcmToken = GeneratedColumn<String>(
    'fcm_token',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _platformMeta = const VerificationMeta(
    'platform',
  );
  @override
  late final GeneratedColumn<String> platform = GeneratedColumn<String>(
    'platform',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('android'),
  );
  static const VerificationMeta _lastSeenAtMeta = const VerificationMeta(
    'lastSeenAt',
  );
  @override
  late final GeneratedColumn<int> lastSeenAt = GeneratedColumn<int>(
    'last_seen_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    familyId,
    email,
    fcmToken,
    platform,
    lastSeenAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'devices';
  @override
  VerificationContext validateIntegrity(
    Insertable<Device> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('family_id')) {
      context.handle(
        _familyIdMeta,
        familyId.isAcceptableOrUnknown(data['family_id']!, _familyIdMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('fcm_token')) {
      context.handle(
        _fcmTokenMeta,
        fcmToken.isAcceptableOrUnknown(data['fcm_token']!, _fcmTokenMeta),
      );
    }
    if (data.containsKey('platform')) {
      context.handle(
        _platformMeta,
        platform.isAcceptableOrUnknown(data['platform']!, _platformMeta),
      );
    }
    if (data.containsKey('last_seen_at')) {
      context.handle(
        _lastSeenAtMeta,
        lastSeenAt.isAcceptableOrUnknown(
          data['last_seen_at']!,
          _lastSeenAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastSeenAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Device map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Device(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      familyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family_id'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      fcmToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fcm_token'],
      ),
      platform: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}platform'],
      )!,
      lastSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_seen_at'],
      )!,
    );
  }

  @override
  $DevicesTable createAlias(String alias) {
    return $DevicesTable(attachedDatabase, alias);
  }
}

class Device extends DataClass implements Insertable<Device> {
  final String id;
  final String? familyId;
  final String email;
  final String? fcmToken;
  final String platform;
  final int lastSeenAt;
  const Device({
    required this.id,
    this.familyId,
    required this.email,
    this.fcmToken,
    required this.platform,
    required this.lastSeenAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || familyId != null) {
      map['family_id'] = Variable<String>(familyId);
    }
    map['email'] = Variable<String>(email);
    if (!nullToAbsent || fcmToken != null) {
      map['fcm_token'] = Variable<String>(fcmToken);
    }
    map['platform'] = Variable<String>(platform);
    map['last_seen_at'] = Variable<int>(lastSeenAt);
    return map;
  }

  DevicesCompanion toCompanion(bool nullToAbsent) {
    return DevicesCompanion(
      id: Value(id),
      familyId: familyId == null && nullToAbsent
          ? const Value.absent()
          : Value(familyId),
      email: Value(email),
      fcmToken: fcmToken == null && nullToAbsent
          ? const Value.absent()
          : Value(fcmToken),
      platform: Value(platform),
      lastSeenAt: Value(lastSeenAt),
    );
  }

  factory Device.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Device(
      id: serializer.fromJson<String>(json['id']),
      familyId: serializer.fromJson<String?>(json['familyId']),
      email: serializer.fromJson<String>(json['email']),
      fcmToken: serializer.fromJson<String?>(json['fcmToken']),
      platform: serializer.fromJson<String>(json['platform']),
      lastSeenAt: serializer.fromJson<int>(json['lastSeenAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'familyId': serializer.toJson<String?>(familyId),
      'email': serializer.toJson<String>(email),
      'fcmToken': serializer.toJson<String?>(fcmToken),
      'platform': serializer.toJson<String>(platform),
      'lastSeenAt': serializer.toJson<int>(lastSeenAt),
    };
  }

  Device copyWith({
    String? id,
    Value<String?> familyId = const Value.absent(),
    String? email,
    Value<String?> fcmToken = const Value.absent(),
    String? platform,
    int? lastSeenAt,
  }) => Device(
    id: id ?? this.id,
    familyId: familyId.present ? familyId.value : this.familyId,
    email: email ?? this.email,
    fcmToken: fcmToken.present ? fcmToken.value : this.fcmToken,
    platform: platform ?? this.platform,
    lastSeenAt: lastSeenAt ?? this.lastSeenAt,
  );
  Device copyWithCompanion(DevicesCompanion data) {
    return Device(
      id: data.id.present ? data.id.value : this.id,
      familyId: data.familyId.present ? data.familyId.value : this.familyId,
      email: data.email.present ? data.email.value : this.email,
      fcmToken: data.fcmToken.present ? data.fcmToken.value : this.fcmToken,
      platform: data.platform.present ? data.platform.value : this.platform,
      lastSeenAt: data.lastSeenAt.present
          ? data.lastSeenAt.value
          : this.lastSeenAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Device(')
          ..write('id: $id, ')
          ..write('familyId: $familyId, ')
          ..write('email: $email, ')
          ..write('fcmToken: $fcmToken, ')
          ..write('platform: $platform, ')
          ..write('lastSeenAt: $lastSeenAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, familyId, email, fcmToken, platform, lastSeenAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Device &&
          other.id == this.id &&
          other.familyId == this.familyId &&
          other.email == this.email &&
          other.fcmToken == this.fcmToken &&
          other.platform == this.platform &&
          other.lastSeenAt == this.lastSeenAt);
}

class DevicesCompanion extends UpdateCompanion<Device> {
  final Value<String> id;
  final Value<String?> familyId;
  final Value<String> email;
  final Value<String?> fcmToken;
  final Value<String> platform;
  final Value<int> lastSeenAt;
  final Value<int> rowid;
  const DevicesCompanion({
    this.id = const Value.absent(),
    this.familyId = const Value.absent(),
    this.email = const Value.absent(),
    this.fcmToken = const Value.absent(),
    this.platform = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DevicesCompanion.insert({
    required String id,
    this.familyId = const Value.absent(),
    required String email,
    this.fcmToken = const Value.absent(),
    this.platform = const Value.absent(),
    required int lastSeenAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       email = Value(email),
       lastSeenAt = Value(lastSeenAt);
  static Insertable<Device> custom({
    Expression<String>? id,
    Expression<String>? familyId,
    Expression<String>? email,
    Expression<String>? fcmToken,
    Expression<String>? platform,
    Expression<int>? lastSeenAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (familyId != null) 'family_id': familyId,
      if (email != null) 'email': email,
      if (fcmToken != null) 'fcm_token': fcmToken,
      if (platform != null) 'platform': platform,
      if (lastSeenAt != null) 'last_seen_at': lastSeenAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DevicesCompanion copyWith({
    Value<String>? id,
    Value<String?>? familyId,
    Value<String>? email,
    Value<String?>? fcmToken,
    Value<String>? platform,
    Value<int>? lastSeenAt,
    Value<int>? rowid,
  }) {
    return DevicesCompanion(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      email: email ?? this.email,
      fcmToken: fcmToken ?? this.fcmToken,
      platform: platform ?? this.platform,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (familyId.present) {
      map['family_id'] = Variable<String>(familyId.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (fcmToken.present) {
      map['fcm_token'] = Variable<String>(fcmToken.value);
    }
    if (platform.present) {
      map['platform'] = Variable<String>(platform.value);
    }
    if (lastSeenAt.present) {
      map['last_seen_at'] = Variable<int>(lastSeenAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DevicesCompanion(')
          ..write('id: $id, ')
          ..write('familyId: $familyId, ')
          ..write('email: $email, ')
          ..write('fcmToken: $fcmToken, ')
          ..write('platform: $platform, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DeviceMemberPrefsTable extends DeviceMemberPrefs
    with TableInfo<$DeviceMemberPrefsTable, DeviceMemberPref> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeviceMemberPrefsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _memberIdMeta = const VerificationMeta(
    'memberId',
  );
  @override
  late final GeneratedColumn<String> memberId = GeneratedColumn<String>(
    'member_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _alarmModeMeta = const VerificationMeta(
    'alarmMode',
  );
  @override
  late final GeneratedColumn<String> alarmMode = GeneratedColumn<String>(
    'alarm_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('monitor_only'),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [memberId, alarmMode, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'device_member_prefs';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeviceMemberPref> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('member_id')) {
      context.handle(
        _memberIdMeta,
        memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta),
      );
    } else if (isInserting) {
      context.missing(_memberIdMeta);
    }
    if (data.containsKey('alarm_mode')) {
      context.handle(
        _alarmModeMeta,
        alarmMode.isAcceptableOrUnknown(data['alarm_mode']!, _alarmModeMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {memberId};
  @override
  DeviceMemberPref map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeviceMemberPref(
      memberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}member_id'],
      )!,
      alarmMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alarm_mode'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DeviceMemberPrefsTable createAlias(String alias) {
    return $DeviceMemberPrefsTable(attachedDatabase, alias);
  }
}

class DeviceMemberPref extends DataClass
    implements Insertable<DeviceMemberPref> {
  final String memberId;
  final String alarmMode;
  final int updatedAt;
  const DeviceMemberPref({
    required this.memberId,
    required this.alarmMode,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['member_id'] = Variable<String>(memberId);
    map['alarm_mode'] = Variable<String>(alarmMode);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  DeviceMemberPrefsCompanion toCompanion(bool nullToAbsent) {
    return DeviceMemberPrefsCompanion(
      memberId: Value(memberId),
      alarmMode: Value(alarmMode),
      updatedAt: Value(updatedAt),
    );
  }

  factory DeviceMemberPref.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeviceMemberPref(
      memberId: serializer.fromJson<String>(json['memberId']),
      alarmMode: serializer.fromJson<String>(json['alarmMode']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'memberId': serializer.toJson<String>(memberId),
      'alarmMode': serializer.toJson<String>(alarmMode),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  DeviceMemberPref copyWith({
    String? memberId,
    String? alarmMode,
    int? updatedAt,
  }) => DeviceMemberPref(
    memberId: memberId ?? this.memberId,
    alarmMode: alarmMode ?? this.alarmMode,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DeviceMemberPref copyWithCompanion(DeviceMemberPrefsCompanion data) {
    return DeviceMemberPref(
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
      alarmMode: data.alarmMode.present ? data.alarmMode.value : this.alarmMode,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeviceMemberPref(')
          ..write('memberId: $memberId, ')
          ..write('alarmMode: $alarmMode, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(memberId, alarmMode, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeviceMemberPref &&
          other.memberId == this.memberId &&
          other.alarmMode == this.alarmMode &&
          other.updatedAt == this.updatedAt);
}

class DeviceMemberPrefsCompanion extends UpdateCompanion<DeviceMemberPref> {
  final Value<String> memberId;
  final Value<String> alarmMode;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const DeviceMemberPrefsCompanion({
    this.memberId = const Value.absent(),
    this.alarmMode = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DeviceMemberPrefsCompanion.insert({
    required String memberId,
    this.alarmMode = const Value.absent(),
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : memberId = Value(memberId),
       updatedAt = Value(updatedAt);
  static Insertable<DeviceMemberPref> custom({
    Expression<String>? memberId,
    Expression<String>? alarmMode,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (memberId != null) 'member_id': memberId,
      if (alarmMode != null) 'alarm_mode': alarmMode,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DeviceMemberPrefsCompanion copyWith({
    Value<String>? memberId,
    Value<String>? alarmMode,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return DeviceMemberPrefsCompanion(
      memberId: memberId ?? this.memberId,
      alarmMode: alarmMode ?? this.alarmMode,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (memberId.present) {
      map['member_id'] = Variable<String>(memberId.value);
    }
    if (alarmMode.present) {
      map['alarm_mode'] = Variable<String>(alarmMode.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeviceMemberPrefsCompanion(')
          ..write('memberId: $memberId, ')
          ..write('alarmMode: $alarmMode, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MembersTable extends Members with TableInfo<$MembersTable, Member> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _familyIdMeta = const VerificationMeta(
    'familyId',
  );
  @override
  late final GeneratedColumn<String> familyId = GeneratedColumn<String>(
    'family_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarPathMeta = const VerificationMeta(
    'avatarPath',
  );
  @override
  late final GeneratedColumn<String> avatarPath = GeneratedColumn<String>(
    'avatar_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _avatarThumbB64Meta = const VerificationMeta(
    'avatarThumbB64',
  );
  @override
  late final GeneratedColumn<String> avatarThumbB64 = GeneratedColumn<String>(
    'avatar_thumb_b64',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> serverUpdatedAt = GeneratedColumn<int>(
    'server_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    familyId,
    name,
    avatarPath,
    avatarThumbB64,
    notes,
    isArchived,
    deletedAt,
    createdAt,
    updatedAt,
    serverUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'members';
  @override
  VerificationContext validateIntegrity(
    Insertable<Member> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('family_id')) {
      context.handle(
        _familyIdMeta,
        familyId.isAcceptableOrUnknown(data['family_id']!, _familyIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('avatar_path')) {
      context.handle(
        _avatarPathMeta,
        avatarPath.isAcceptableOrUnknown(data['avatar_path']!, _avatarPathMeta),
      );
    }
    if (data.containsKey('avatar_thumb_b64')) {
      context.handle(
        _avatarThumbB64Meta,
        avatarThumbB64.isAcceptableOrUnknown(
          data['avatar_thumb_b64']!,
          _avatarThumbB64Meta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Member map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Member(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      familyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      avatarPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_path'],
      ),
      avatarThumbB64: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_thumb_b64'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_updated_at'],
      ),
    );
  }

  @override
  $MembersTable createAlias(String alias) {
    return $MembersTable(attachedDatabase, alias);
  }
}

class Member extends DataClass implements Insertable<Member> {
  final String id;
  final String? familyId;
  final String name;
  final String? avatarPath;
  final String? avatarThumbB64;
  final String? notes;
  final bool isArchived;
  final int? deletedAt;
  final int createdAt;
  final int updatedAt;
  final int? serverUpdatedAt;
  const Member({
    required this.id,
    this.familyId,
    required this.name,
    this.avatarPath,
    this.avatarThumbB64,
    this.notes,
    required this.isArchived,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    this.serverUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || familyId != null) {
      map['family_id'] = Variable<String>(familyId);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || avatarPath != null) {
      map['avatar_path'] = Variable<String>(avatarPath);
    }
    if (!nullToAbsent || avatarThumbB64 != null) {
      map['avatar_thumb_b64'] = Variable<String>(avatarThumbB64);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_archived'] = Variable<bool>(isArchived);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt);
    }
    return map;
  }

  MembersCompanion toCompanion(bool nullToAbsent) {
    return MembersCompanion(
      id: Value(id),
      familyId: familyId == null && nullToAbsent
          ? const Value.absent()
          : Value(familyId),
      name: Value(name),
      avatarPath: avatarPath == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarPath),
      avatarThumbB64: avatarThumbB64 == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarThumbB64),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      isArchived: Value(isArchived),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
    );
  }

  factory Member.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Member(
      id: serializer.fromJson<String>(json['id']),
      familyId: serializer.fromJson<String?>(json['familyId']),
      name: serializer.fromJson<String>(json['name']),
      avatarPath: serializer.fromJson<String?>(json['avatarPath']),
      avatarThumbB64: serializer.fromJson<String?>(json['avatarThumbB64']),
      notes: serializer.fromJson<String?>(json['notes']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      serverUpdatedAt: serializer.fromJson<int?>(json['serverUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'familyId': serializer.toJson<String?>(familyId),
      'name': serializer.toJson<String>(name),
      'avatarPath': serializer.toJson<String?>(avatarPath),
      'avatarThumbB64': serializer.toJson<String?>(avatarThumbB64),
      'notes': serializer.toJson<String?>(notes),
      'isArchived': serializer.toJson<bool>(isArchived),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'serverUpdatedAt': serializer.toJson<int?>(serverUpdatedAt),
    };
  }

  Member copyWith({
    String? id,
    Value<String?> familyId = const Value.absent(),
    String? name,
    Value<String?> avatarPath = const Value.absent(),
    Value<String?> avatarThumbB64 = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    bool? isArchived,
    Value<int?> deletedAt = const Value.absent(),
    int? createdAt,
    int? updatedAt,
    Value<int?> serverUpdatedAt = const Value.absent(),
  }) => Member(
    id: id ?? this.id,
    familyId: familyId.present ? familyId.value : this.familyId,
    name: name ?? this.name,
    avatarPath: avatarPath.present ? avatarPath.value : this.avatarPath,
    avatarThumbB64: avatarThumbB64.present
        ? avatarThumbB64.value
        : this.avatarThumbB64,
    notes: notes.present ? notes.value : this.notes,
    isArchived: isArchived ?? this.isArchived,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
  );
  Member copyWithCompanion(MembersCompanion data) {
    return Member(
      id: data.id.present ? data.id.value : this.id,
      familyId: data.familyId.present ? data.familyId.value : this.familyId,
      name: data.name.present ? data.name.value : this.name,
      avatarPath: data.avatarPath.present
          ? data.avatarPath.value
          : this.avatarPath,
      avatarThumbB64: data.avatarThumbB64.present
          ? data.avatarThumbB64.value
          : this.avatarThumbB64,
      notes: data.notes.present ? data.notes.value : this.notes,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Member(')
          ..write('id: $id, ')
          ..write('familyId: $familyId, ')
          ..write('name: $name, ')
          ..write('avatarPath: $avatarPath, ')
          ..write('avatarThumbB64: $avatarThumbB64, ')
          ..write('notes: $notes, ')
          ..write('isArchived: $isArchived, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    familyId,
    name,
    avatarPath,
    avatarThumbB64,
    notes,
    isArchived,
    deletedAt,
    createdAt,
    updatedAt,
    serverUpdatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Member &&
          other.id == this.id &&
          other.familyId == this.familyId &&
          other.name == this.name &&
          other.avatarPath == this.avatarPath &&
          other.avatarThumbB64 == this.avatarThumbB64 &&
          other.notes == this.notes &&
          other.isArchived == this.isArchived &&
          other.deletedAt == this.deletedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt);
}

class MembersCompanion extends UpdateCompanion<Member> {
  final Value<String> id;
  final Value<String?> familyId;
  final Value<String> name;
  final Value<String?> avatarPath;
  final Value<String?> avatarThumbB64;
  final Value<String?> notes;
  final Value<bool> isArchived;
  final Value<int?> deletedAt;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> serverUpdatedAt;
  final Value<int> rowid;
  const MembersCompanion({
    this.id = const Value.absent(),
    this.familyId = const Value.absent(),
    this.name = const Value.absent(),
    this.avatarPath = const Value.absent(),
    this.avatarThumbB64 = const Value.absent(),
    this.notes = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MembersCompanion.insert({
    required String id,
    this.familyId = const Value.absent(),
    required String name,
    this.avatarPath = const Value.absent(),
    this.avatarThumbB64 = const Value.absent(),
    this.notes = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Member> custom({
    Expression<String>? id,
    Expression<String>? familyId,
    Expression<String>? name,
    Expression<String>? avatarPath,
    Expression<String>? avatarThumbB64,
    Expression<String>? notes,
    Expression<bool>? isArchived,
    Expression<int>? deletedAt,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? serverUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (familyId != null) 'family_id': familyId,
      if (name != null) 'name': name,
      if (avatarPath != null) 'avatar_path': avatarPath,
      if (avatarThumbB64 != null) 'avatar_thumb_b64': avatarThumbB64,
      if (notes != null) 'notes': notes,
      if (isArchived != null) 'is_archived': isArchived,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MembersCompanion copyWith({
    Value<String>? id,
    Value<String?>? familyId,
    Value<String>? name,
    Value<String?>? avatarPath,
    Value<String?>? avatarThumbB64,
    Value<String?>? notes,
    Value<bool>? isArchived,
    Value<int?>? deletedAt,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? serverUpdatedAt,
    Value<int>? rowid,
  }) {
    return MembersCompanion(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      name: name ?? this.name,
      avatarPath: avatarPath ?? this.avatarPath,
      avatarThumbB64: avatarThumbB64 ?? this.avatarThumbB64,
      notes: notes ?? this.notes,
      isArchived: isArchived ?? this.isArchived,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (familyId.present) {
      map['family_id'] = Variable<String>(familyId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (avatarPath.present) {
      map['avatar_path'] = Variable<String>(avatarPath.value);
    }
    if (avatarThumbB64.present) {
      map['avatar_thumb_b64'] = Variable<String>(avatarThumbB64.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MembersCompanion(')
          ..write('id: $id, ')
          ..write('familyId: $familyId, ')
          ..write('name: $name, ')
          ..write('avatarPath: $avatarPath, ')
          ..write('avatarThumbB64: $avatarThumbB64, ')
          ..write('notes: $notes, ')
          ..write('isArchived: $isArchived, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MedicinesTable extends Medicines
    with TableInfo<$MedicinesTable, Medicine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _familyIdMeta = const VerificationMeta(
    'familyId',
  );
  @override
  late final GeneratedColumn<String> familyId = GeneratedColumn<String>(
    'family_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _memberIdMeta = const VerificationMeta(
    'memberId',
  );
  @override
  late final GeneratedColumn<String> memberId = GeneratedColumn<String>(
    'member_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dosageMeta = const VerificationMeta('dosage');
  @override
  late final GeneratedColumn<String> dosage = GeneratedColumn<String>(
    'dosage',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _doseQtyMeta = const VerificationMeta(
    'doseQty',
  );
  @override
  late final GeneratedColumn<double> doseQty = GeneratedColumn<double>(
    'dose_qty',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mealRelationMeta = const VerificationMeta(
    'mealRelation',
  );
  @override
  late final GeneratedColumn<String> mealRelation = GeneratedColumn<String>(
    'meal_relation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none'),
  );
  static const VerificationMeta _photoPathMeta = const VerificationMeta(
    'photoPath',
  );
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoThumbB64Meta = const VerificationMeta(
    'photoThumbB64',
  );
  @override
  late final GeneratedColumn<String> photoThumbB64 = GeneratedColumn<String>(
    'photo_thumb_b64',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stockQtyMeta = const VerificationMeta(
    'stockQty',
  );
  @override
  late final GeneratedColumn<double> stockQty = GeneratedColumn<double>(
    'stock_qty',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _lowStockThresholdMeta = const VerificationMeta(
    'lowStockThreshold',
  );
  @override
  late final GeneratedColumn<double> lowStockThreshold =
      GeneratedColumn<double>(
        'low_stock_threshold',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(3.0),
      );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> serverUpdatedAt = GeneratedColumn<int>(
    'server_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    familyId,
    memberId,
    name,
    dosage,
    doseQty,
    unit,
    mealRelation,
    photoPath,
    photoThumbB64,
    stockQty,
    lowStockThreshold,
    notes,
    isArchived,
    deletedAt,
    createdAt,
    updatedAt,
    serverUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medicines';
  @override
  VerificationContext validateIntegrity(
    Insertable<Medicine> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('family_id')) {
      context.handle(
        _familyIdMeta,
        familyId.isAcceptableOrUnknown(data['family_id']!, _familyIdMeta),
      );
    }
    if (data.containsKey('member_id')) {
      context.handle(
        _memberIdMeta,
        memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta),
      );
    } else if (isInserting) {
      context.missing(_memberIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('dosage')) {
      context.handle(
        _dosageMeta,
        dosage.isAcceptableOrUnknown(data['dosage']!, _dosageMeta),
      );
    } else if (isInserting) {
      context.missing(_dosageMeta);
    }
    if (data.containsKey('dose_qty')) {
      context.handle(
        _doseQtyMeta,
        doseQty.isAcceptableOrUnknown(data['dose_qty']!, _doseQtyMeta),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('meal_relation')) {
      context.handle(
        _mealRelationMeta,
        mealRelation.isAcceptableOrUnknown(
          data['meal_relation']!,
          _mealRelationMeta,
        ),
      );
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
      );
    }
    if (data.containsKey('photo_thumb_b64')) {
      context.handle(
        _photoThumbB64Meta,
        photoThumbB64.isAcceptableOrUnknown(
          data['photo_thumb_b64']!,
          _photoThumbB64Meta,
        ),
      );
    }
    if (data.containsKey('stock_qty')) {
      context.handle(
        _stockQtyMeta,
        stockQty.isAcceptableOrUnknown(data['stock_qty']!, _stockQtyMeta),
      );
    }
    if (data.containsKey('low_stock_threshold')) {
      context.handle(
        _lowStockThresholdMeta,
        lowStockThreshold.isAcceptableOrUnknown(
          data['low_stock_threshold']!,
          _lowStockThresholdMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Medicine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Medicine(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      familyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family_id'],
      ),
      memberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}member_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      dosage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dosage'],
      )!,
      doseQty: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}dose_qty'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      mealRelation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meal_relation'],
      )!,
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      ),
      photoThumbB64: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_thumb_b64'],
      ),
      stockQty: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stock_qty'],
      )!,
      lowStockThreshold: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}low_stock_threshold'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_updated_at'],
      ),
    );
  }

  @override
  $MedicinesTable createAlias(String alias) {
    return $MedicinesTable(attachedDatabase, alias);
  }
}

class Medicine extends DataClass implements Insertable<Medicine> {
  final String id;
  final String? familyId;
  final String memberId;
  final String name;
  final String dosage;
  final double doseQty;
  final String unit;
  final String mealRelation;
  final String? photoPath;
  final String? photoThumbB64;
  final double stockQty;
  final double lowStockThreshold;
  final String? notes;
  final bool isArchived;
  final int? deletedAt;
  final int createdAt;
  final int updatedAt;
  final int? serverUpdatedAt;
  const Medicine({
    required this.id,
    this.familyId,
    required this.memberId,
    required this.name,
    required this.dosage,
    required this.doseQty,
    required this.unit,
    required this.mealRelation,
    this.photoPath,
    this.photoThumbB64,
    required this.stockQty,
    required this.lowStockThreshold,
    this.notes,
    required this.isArchived,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    this.serverUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || familyId != null) {
      map['family_id'] = Variable<String>(familyId);
    }
    map['member_id'] = Variable<String>(memberId);
    map['name'] = Variable<String>(name);
    map['dosage'] = Variable<String>(dosage);
    map['dose_qty'] = Variable<double>(doseQty);
    map['unit'] = Variable<String>(unit);
    map['meal_relation'] = Variable<String>(mealRelation);
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    if (!nullToAbsent || photoThumbB64 != null) {
      map['photo_thumb_b64'] = Variable<String>(photoThumbB64);
    }
    map['stock_qty'] = Variable<double>(stockQty);
    map['low_stock_threshold'] = Variable<double>(lowStockThreshold);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_archived'] = Variable<bool>(isArchived);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt);
    }
    return map;
  }

  MedicinesCompanion toCompanion(bool nullToAbsent) {
    return MedicinesCompanion(
      id: Value(id),
      familyId: familyId == null && nullToAbsent
          ? const Value.absent()
          : Value(familyId),
      memberId: Value(memberId),
      name: Value(name),
      dosage: Value(dosage),
      doseQty: Value(doseQty),
      unit: Value(unit),
      mealRelation: Value(mealRelation),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      photoThumbB64: photoThumbB64 == null && nullToAbsent
          ? const Value.absent()
          : Value(photoThumbB64),
      stockQty: Value(stockQty),
      lowStockThreshold: Value(lowStockThreshold),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      isArchived: Value(isArchived),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
    );
  }

  factory Medicine.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Medicine(
      id: serializer.fromJson<String>(json['id']),
      familyId: serializer.fromJson<String?>(json['familyId']),
      memberId: serializer.fromJson<String>(json['memberId']),
      name: serializer.fromJson<String>(json['name']),
      dosage: serializer.fromJson<String>(json['dosage']),
      doseQty: serializer.fromJson<double>(json['doseQty']),
      unit: serializer.fromJson<String>(json['unit']),
      mealRelation: serializer.fromJson<String>(json['mealRelation']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      photoThumbB64: serializer.fromJson<String?>(json['photoThumbB64']),
      stockQty: serializer.fromJson<double>(json['stockQty']),
      lowStockThreshold: serializer.fromJson<double>(json['lowStockThreshold']),
      notes: serializer.fromJson<String?>(json['notes']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      serverUpdatedAt: serializer.fromJson<int?>(json['serverUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'familyId': serializer.toJson<String?>(familyId),
      'memberId': serializer.toJson<String>(memberId),
      'name': serializer.toJson<String>(name),
      'dosage': serializer.toJson<String>(dosage),
      'doseQty': serializer.toJson<double>(doseQty),
      'unit': serializer.toJson<String>(unit),
      'mealRelation': serializer.toJson<String>(mealRelation),
      'photoPath': serializer.toJson<String?>(photoPath),
      'photoThumbB64': serializer.toJson<String?>(photoThumbB64),
      'stockQty': serializer.toJson<double>(stockQty),
      'lowStockThreshold': serializer.toJson<double>(lowStockThreshold),
      'notes': serializer.toJson<String?>(notes),
      'isArchived': serializer.toJson<bool>(isArchived),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'serverUpdatedAt': serializer.toJson<int?>(serverUpdatedAt),
    };
  }

  Medicine copyWith({
    String? id,
    Value<String?> familyId = const Value.absent(),
    String? memberId,
    String? name,
    String? dosage,
    double? doseQty,
    String? unit,
    String? mealRelation,
    Value<String?> photoPath = const Value.absent(),
    Value<String?> photoThumbB64 = const Value.absent(),
    double? stockQty,
    double? lowStockThreshold,
    Value<String?> notes = const Value.absent(),
    bool? isArchived,
    Value<int?> deletedAt = const Value.absent(),
    int? createdAt,
    int? updatedAt,
    Value<int?> serverUpdatedAt = const Value.absent(),
  }) => Medicine(
    id: id ?? this.id,
    familyId: familyId.present ? familyId.value : this.familyId,
    memberId: memberId ?? this.memberId,
    name: name ?? this.name,
    dosage: dosage ?? this.dosage,
    doseQty: doseQty ?? this.doseQty,
    unit: unit ?? this.unit,
    mealRelation: mealRelation ?? this.mealRelation,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
    photoThumbB64: photoThumbB64.present
        ? photoThumbB64.value
        : this.photoThumbB64,
    stockQty: stockQty ?? this.stockQty,
    lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
    notes: notes.present ? notes.value : this.notes,
    isArchived: isArchived ?? this.isArchived,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
  );
  Medicine copyWithCompanion(MedicinesCompanion data) {
    return Medicine(
      id: data.id.present ? data.id.value : this.id,
      familyId: data.familyId.present ? data.familyId.value : this.familyId,
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
      name: data.name.present ? data.name.value : this.name,
      dosage: data.dosage.present ? data.dosage.value : this.dosage,
      doseQty: data.doseQty.present ? data.doseQty.value : this.doseQty,
      unit: data.unit.present ? data.unit.value : this.unit,
      mealRelation: data.mealRelation.present
          ? data.mealRelation.value
          : this.mealRelation,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      photoThumbB64: data.photoThumbB64.present
          ? data.photoThumbB64.value
          : this.photoThumbB64,
      stockQty: data.stockQty.present ? data.stockQty.value : this.stockQty,
      lowStockThreshold: data.lowStockThreshold.present
          ? data.lowStockThreshold.value
          : this.lowStockThreshold,
      notes: data.notes.present ? data.notes.value : this.notes,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Medicine(')
          ..write('id: $id, ')
          ..write('familyId: $familyId, ')
          ..write('memberId: $memberId, ')
          ..write('name: $name, ')
          ..write('dosage: $dosage, ')
          ..write('doseQty: $doseQty, ')
          ..write('unit: $unit, ')
          ..write('mealRelation: $mealRelation, ')
          ..write('photoPath: $photoPath, ')
          ..write('photoThumbB64: $photoThumbB64, ')
          ..write('stockQty: $stockQty, ')
          ..write('lowStockThreshold: $lowStockThreshold, ')
          ..write('notes: $notes, ')
          ..write('isArchived: $isArchived, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    familyId,
    memberId,
    name,
    dosage,
    doseQty,
    unit,
    mealRelation,
    photoPath,
    photoThumbB64,
    stockQty,
    lowStockThreshold,
    notes,
    isArchived,
    deletedAt,
    createdAt,
    updatedAt,
    serverUpdatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Medicine &&
          other.id == this.id &&
          other.familyId == this.familyId &&
          other.memberId == this.memberId &&
          other.name == this.name &&
          other.dosage == this.dosage &&
          other.doseQty == this.doseQty &&
          other.unit == this.unit &&
          other.mealRelation == this.mealRelation &&
          other.photoPath == this.photoPath &&
          other.photoThumbB64 == this.photoThumbB64 &&
          other.stockQty == this.stockQty &&
          other.lowStockThreshold == this.lowStockThreshold &&
          other.notes == this.notes &&
          other.isArchived == this.isArchived &&
          other.deletedAt == this.deletedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt);
}

class MedicinesCompanion extends UpdateCompanion<Medicine> {
  final Value<String> id;
  final Value<String?> familyId;
  final Value<String> memberId;
  final Value<String> name;
  final Value<String> dosage;
  final Value<double> doseQty;
  final Value<String> unit;
  final Value<String> mealRelation;
  final Value<String?> photoPath;
  final Value<String?> photoThumbB64;
  final Value<double> stockQty;
  final Value<double> lowStockThreshold;
  final Value<String?> notes;
  final Value<bool> isArchived;
  final Value<int?> deletedAt;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> serverUpdatedAt;
  final Value<int> rowid;
  const MedicinesCompanion({
    this.id = const Value.absent(),
    this.familyId = const Value.absent(),
    this.memberId = const Value.absent(),
    this.name = const Value.absent(),
    this.dosage = const Value.absent(),
    this.doseQty = const Value.absent(),
    this.unit = const Value.absent(),
    this.mealRelation = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.photoThumbB64 = const Value.absent(),
    this.stockQty = const Value.absent(),
    this.lowStockThreshold = const Value.absent(),
    this.notes = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MedicinesCompanion.insert({
    required String id,
    this.familyId = const Value.absent(),
    required String memberId,
    required String name,
    required String dosage,
    this.doseQty = const Value.absent(),
    required String unit,
    this.mealRelation = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.photoThumbB64 = const Value.absent(),
    this.stockQty = const Value.absent(),
    this.lowStockThreshold = const Value.absent(),
    this.notes = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       memberId = Value(memberId),
       name = Value(name),
       dosage = Value(dosage),
       unit = Value(unit),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Medicine> custom({
    Expression<String>? id,
    Expression<String>? familyId,
    Expression<String>? memberId,
    Expression<String>? name,
    Expression<String>? dosage,
    Expression<double>? doseQty,
    Expression<String>? unit,
    Expression<String>? mealRelation,
    Expression<String>? photoPath,
    Expression<String>? photoThumbB64,
    Expression<double>? stockQty,
    Expression<double>? lowStockThreshold,
    Expression<String>? notes,
    Expression<bool>? isArchived,
    Expression<int>? deletedAt,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? serverUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (familyId != null) 'family_id': familyId,
      if (memberId != null) 'member_id': memberId,
      if (name != null) 'name': name,
      if (dosage != null) 'dosage': dosage,
      if (doseQty != null) 'dose_qty': doseQty,
      if (unit != null) 'unit': unit,
      if (mealRelation != null) 'meal_relation': mealRelation,
      if (photoPath != null) 'photo_path': photoPath,
      if (photoThumbB64 != null) 'photo_thumb_b64': photoThumbB64,
      if (stockQty != null) 'stock_qty': stockQty,
      if (lowStockThreshold != null) 'low_stock_threshold': lowStockThreshold,
      if (notes != null) 'notes': notes,
      if (isArchived != null) 'is_archived': isArchived,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MedicinesCompanion copyWith({
    Value<String>? id,
    Value<String?>? familyId,
    Value<String>? memberId,
    Value<String>? name,
    Value<String>? dosage,
    Value<double>? doseQty,
    Value<String>? unit,
    Value<String>? mealRelation,
    Value<String?>? photoPath,
    Value<String?>? photoThumbB64,
    Value<double>? stockQty,
    Value<double>? lowStockThreshold,
    Value<String?>? notes,
    Value<bool>? isArchived,
    Value<int?>? deletedAt,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? serverUpdatedAt,
    Value<int>? rowid,
  }) {
    return MedicinesCompanion(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      memberId: memberId ?? this.memberId,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      doseQty: doseQty ?? this.doseQty,
      unit: unit ?? this.unit,
      mealRelation: mealRelation ?? this.mealRelation,
      photoPath: photoPath ?? this.photoPath,
      photoThumbB64: photoThumbB64 ?? this.photoThumbB64,
      stockQty: stockQty ?? this.stockQty,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      notes: notes ?? this.notes,
      isArchived: isArchived ?? this.isArchived,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (familyId.present) {
      map['family_id'] = Variable<String>(familyId.value);
    }
    if (memberId.present) {
      map['member_id'] = Variable<String>(memberId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (dosage.present) {
      map['dosage'] = Variable<String>(dosage.value);
    }
    if (doseQty.present) {
      map['dose_qty'] = Variable<double>(doseQty.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (mealRelation.present) {
      map['meal_relation'] = Variable<String>(mealRelation.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (photoThumbB64.present) {
      map['photo_thumb_b64'] = Variable<String>(photoThumbB64.value);
    }
    if (stockQty.present) {
      map['stock_qty'] = Variable<double>(stockQty.value);
    }
    if (lowStockThreshold.present) {
      map['low_stock_threshold'] = Variable<double>(lowStockThreshold.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicinesCompanion(')
          ..write('id: $id, ')
          ..write('familyId: $familyId, ')
          ..write('memberId: $memberId, ')
          ..write('name: $name, ')
          ..write('dosage: $dosage, ')
          ..write('doseQty: $doseQty, ')
          ..write('unit: $unit, ')
          ..write('mealRelation: $mealRelation, ')
          ..write('photoPath: $photoPath, ')
          ..write('photoThumbB64: $photoThumbB64, ')
          ..write('stockQty: $stockQty, ')
          ..write('lowStockThreshold: $lowStockThreshold, ')
          ..write('notes: $notes, ')
          ..write('isArchived: $isArchived, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StockLedgersTable extends StockLedgers
    with TableInfo<$StockLedgersTable, StockLedger> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockLedgersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _familyIdMeta = const VerificationMeta(
    'familyId',
  );
  @override
  late final GeneratedColumn<String> familyId = GeneratedColumn<String>(
    'family_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _medicineIdMeta = const VerificationMeta(
    'medicineId',
  );
  @override
  late final GeneratedColumn<String> medicineId = GeneratedColumn<String>(
    'medicine_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _doseLogIdMeta = const VerificationMeta(
    'doseLogId',
  );
  @override
  late final GeneratedColumn<String> doseLogId = GeneratedColumn<String>(
    'dose_log_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deltaMeta = const VerificationMeta('delta');
  @override
  late final GeneratedColumn<double> delta = GeneratedColumn<double>(
    'delta',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _balanceAfterMeta = const VerificationMeta(
    'balanceAfter',
  );
  @override
  late final GeneratedColumn<double> balanceAfter = GeneratedColumn<double>(
    'balance_after',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> serverUpdatedAt = GeneratedColumn<int>(
    'server_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    familyId,
    medicineId,
    doseLogId,
    delta,
    balanceAfter,
    reason,
    createdAt,
    serverUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_ledgers';
  @override
  VerificationContext validateIntegrity(
    Insertable<StockLedger> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('family_id')) {
      context.handle(
        _familyIdMeta,
        familyId.isAcceptableOrUnknown(data['family_id']!, _familyIdMeta),
      );
    }
    if (data.containsKey('medicine_id')) {
      context.handle(
        _medicineIdMeta,
        medicineId.isAcceptableOrUnknown(data['medicine_id']!, _medicineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_medicineIdMeta);
    }
    if (data.containsKey('dose_log_id')) {
      context.handle(
        _doseLogIdMeta,
        doseLogId.isAcceptableOrUnknown(data['dose_log_id']!, _doseLogIdMeta),
      );
    }
    if (data.containsKey('delta')) {
      context.handle(
        _deltaMeta,
        delta.isAcceptableOrUnknown(data['delta']!, _deltaMeta),
      );
    } else if (isInserting) {
      context.missing(_deltaMeta);
    }
    if (data.containsKey('balance_after')) {
      context.handle(
        _balanceAfterMeta,
        balanceAfter.isAcceptableOrUnknown(
          data['balance_after']!,
          _balanceAfterMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_balanceAfterMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockLedger map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockLedger(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      familyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family_id'],
      ),
      medicineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medicine_id'],
      )!,
      doseLogId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dose_log_id'],
      ),
      delta: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}delta'],
      )!,
      balanceAfter: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}balance_after'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_updated_at'],
      ),
    );
  }

  @override
  $StockLedgersTable createAlias(String alias) {
    return $StockLedgersTable(attachedDatabase, alias);
  }
}

class StockLedger extends DataClass implements Insertable<StockLedger> {
  final String id;
  final String? familyId;
  final String medicineId;
  final String? doseLogId;
  final double delta;
  final double balanceAfter;
  final String reason;
  final int createdAt;
  final int? serverUpdatedAt;
  const StockLedger({
    required this.id,
    this.familyId,
    required this.medicineId,
    this.doseLogId,
    required this.delta,
    required this.balanceAfter,
    required this.reason,
    required this.createdAt,
    this.serverUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || familyId != null) {
      map['family_id'] = Variable<String>(familyId);
    }
    map['medicine_id'] = Variable<String>(medicineId);
    if (!nullToAbsent || doseLogId != null) {
      map['dose_log_id'] = Variable<String>(doseLogId);
    }
    map['delta'] = Variable<double>(delta);
    map['balance_after'] = Variable<double>(balanceAfter);
    map['reason'] = Variable<String>(reason);
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt);
    }
    return map;
  }

  StockLedgersCompanion toCompanion(bool nullToAbsent) {
    return StockLedgersCompanion(
      id: Value(id),
      familyId: familyId == null && nullToAbsent
          ? const Value.absent()
          : Value(familyId),
      medicineId: Value(medicineId),
      doseLogId: doseLogId == null && nullToAbsent
          ? const Value.absent()
          : Value(doseLogId),
      delta: Value(delta),
      balanceAfter: Value(balanceAfter),
      reason: Value(reason),
      createdAt: Value(createdAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
    );
  }

  factory StockLedger.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockLedger(
      id: serializer.fromJson<String>(json['id']),
      familyId: serializer.fromJson<String?>(json['familyId']),
      medicineId: serializer.fromJson<String>(json['medicineId']),
      doseLogId: serializer.fromJson<String?>(json['doseLogId']),
      delta: serializer.fromJson<double>(json['delta']),
      balanceAfter: serializer.fromJson<double>(json['balanceAfter']),
      reason: serializer.fromJson<String>(json['reason']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      serverUpdatedAt: serializer.fromJson<int?>(json['serverUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'familyId': serializer.toJson<String?>(familyId),
      'medicineId': serializer.toJson<String>(medicineId),
      'doseLogId': serializer.toJson<String?>(doseLogId),
      'delta': serializer.toJson<double>(delta),
      'balanceAfter': serializer.toJson<double>(balanceAfter),
      'reason': serializer.toJson<String>(reason),
      'createdAt': serializer.toJson<int>(createdAt),
      'serverUpdatedAt': serializer.toJson<int?>(serverUpdatedAt),
    };
  }

  StockLedger copyWith({
    String? id,
    Value<String?> familyId = const Value.absent(),
    String? medicineId,
    Value<String?> doseLogId = const Value.absent(),
    double? delta,
    double? balanceAfter,
    String? reason,
    int? createdAt,
    Value<int?> serverUpdatedAt = const Value.absent(),
  }) => StockLedger(
    id: id ?? this.id,
    familyId: familyId.present ? familyId.value : this.familyId,
    medicineId: medicineId ?? this.medicineId,
    doseLogId: doseLogId.present ? doseLogId.value : this.doseLogId,
    delta: delta ?? this.delta,
    balanceAfter: balanceAfter ?? this.balanceAfter,
    reason: reason ?? this.reason,
    createdAt: createdAt ?? this.createdAt,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
  );
  StockLedger copyWithCompanion(StockLedgersCompanion data) {
    return StockLedger(
      id: data.id.present ? data.id.value : this.id,
      familyId: data.familyId.present ? data.familyId.value : this.familyId,
      medicineId: data.medicineId.present
          ? data.medicineId.value
          : this.medicineId,
      doseLogId: data.doseLogId.present ? data.doseLogId.value : this.doseLogId,
      delta: data.delta.present ? data.delta.value : this.delta,
      balanceAfter: data.balanceAfter.present
          ? data.balanceAfter.value
          : this.balanceAfter,
      reason: data.reason.present ? data.reason.value : this.reason,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockLedger(')
          ..write('id: $id, ')
          ..write('familyId: $familyId, ')
          ..write('medicineId: $medicineId, ')
          ..write('doseLogId: $doseLogId, ')
          ..write('delta: $delta, ')
          ..write('balanceAfter: $balanceAfter, ')
          ..write('reason: $reason, ')
          ..write('createdAt: $createdAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    familyId,
    medicineId,
    doseLogId,
    delta,
    balanceAfter,
    reason,
    createdAt,
    serverUpdatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockLedger &&
          other.id == this.id &&
          other.familyId == this.familyId &&
          other.medicineId == this.medicineId &&
          other.doseLogId == this.doseLogId &&
          other.delta == this.delta &&
          other.balanceAfter == this.balanceAfter &&
          other.reason == this.reason &&
          other.createdAt == this.createdAt &&
          other.serverUpdatedAt == this.serverUpdatedAt);
}

class StockLedgersCompanion extends UpdateCompanion<StockLedger> {
  final Value<String> id;
  final Value<String?> familyId;
  final Value<String> medicineId;
  final Value<String?> doseLogId;
  final Value<double> delta;
  final Value<double> balanceAfter;
  final Value<String> reason;
  final Value<int> createdAt;
  final Value<int?> serverUpdatedAt;
  final Value<int> rowid;
  const StockLedgersCompanion({
    this.id = const Value.absent(),
    this.familyId = const Value.absent(),
    this.medicineId = const Value.absent(),
    this.doseLogId = const Value.absent(),
    this.delta = const Value.absent(),
    this.balanceAfter = const Value.absent(),
    this.reason = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StockLedgersCompanion.insert({
    required String id,
    this.familyId = const Value.absent(),
    required String medicineId,
    this.doseLogId = const Value.absent(),
    required double delta,
    required double balanceAfter,
    required String reason,
    required int createdAt,
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       medicineId = Value(medicineId),
       delta = Value(delta),
       balanceAfter = Value(balanceAfter),
       reason = Value(reason),
       createdAt = Value(createdAt);
  static Insertable<StockLedger> custom({
    Expression<String>? id,
    Expression<String>? familyId,
    Expression<String>? medicineId,
    Expression<String>? doseLogId,
    Expression<double>? delta,
    Expression<double>? balanceAfter,
    Expression<String>? reason,
    Expression<int>? createdAt,
    Expression<int>? serverUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (familyId != null) 'family_id': familyId,
      if (medicineId != null) 'medicine_id': medicineId,
      if (doseLogId != null) 'dose_log_id': doseLogId,
      if (delta != null) 'delta': delta,
      if (balanceAfter != null) 'balance_after': balanceAfter,
      if (reason != null) 'reason': reason,
      if (createdAt != null) 'created_at': createdAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StockLedgersCompanion copyWith({
    Value<String>? id,
    Value<String?>? familyId,
    Value<String>? medicineId,
    Value<String?>? doseLogId,
    Value<double>? delta,
    Value<double>? balanceAfter,
    Value<String>? reason,
    Value<int>? createdAt,
    Value<int?>? serverUpdatedAt,
    Value<int>? rowid,
  }) {
    return StockLedgersCompanion(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      medicineId: medicineId ?? this.medicineId,
      doseLogId: doseLogId ?? this.doseLogId,
      delta: delta ?? this.delta,
      balanceAfter: balanceAfter ?? this.balanceAfter,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (familyId.present) {
      map['family_id'] = Variable<String>(familyId.value);
    }
    if (medicineId.present) {
      map['medicine_id'] = Variable<String>(medicineId.value);
    }
    if (doseLogId.present) {
      map['dose_log_id'] = Variable<String>(doseLogId.value);
    }
    if (delta.present) {
      map['delta'] = Variable<double>(delta.value);
    }
    if (balanceAfter.present) {
      map['balance_after'] = Variable<double>(balanceAfter.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockLedgersCompanion(')
          ..write('id: $id, ')
          ..write('familyId: $familyId, ')
          ..write('medicineId: $medicineId, ')
          ..write('doseLogId: $doseLogId, ')
          ..write('delta: $delta, ')
          ..write('balanceAfter: $balanceAfter, ')
          ..write('reason: $reason, ')
          ..write('createdAt: $createdAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SchedulesTable extends Schedules
    with TableInfo<$SchedulesTable, Schedule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SchedulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _familyIdMeta = const VerificationMeta(
    'familyId',
  );
  @override
  late final GeneratedColumn<String> familyId = GeneratedColumn<String>(
    'family_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _memberIdMeta = const VerificationMeta(
    'memberId',
  );
  @override
  late final GeneratedColumn<String> memberId = GeneratedColumn<String>(
    'member_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _medicineIdMeta = const VerificationMeta(
    'medicineId',
  );
  @override
  late final GeneratedColumn<String> medicineId = GeneratedColumn<String>(
    'medicine_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recurrenceTypeMeta = const VerificationMeta(
    'recurrenceType',
  );
  @override
  late final GeneratedColumn<String> recurrenceType = GeneratedColumn<String>(
    'recurrence_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timesJsonMeta = const VerificationMeta(
    'timesJson',
  );
  @override
  late final GeneratedColumn<String> timesJson = GeneratedColumn<String>(
    'times_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _intervalHoursMeta = const VerificationMeta(
    'intervalHours',
  );
  @override
  late final GeneratedColumn<int> intervalHours = GeneratedColumn<int>(
    'interval_hours',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _daysOfWeekMeta = const VerificationMeta(
    'daysOfWeek',
  );
  @override
  late final GeneratedColumn<String> daysOfWeek = GeneratedColumn<String>(
    'days_of_week',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _doseQtyMeta = const VerificationMeta(
    'doseQty',
  );
  @override
  late final GeneratedColumn<double> doseQty = GeneratedColumn<double>(
    'dose_qty',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mealRelationMeta = const VerificationMeta(
    'mealRelation',
  );
  @override
  late final GeneratedColumn<String> mealRelation = GeneratedColumn<String>(
    'meal_relation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ttsEnabledMeta = const VerificationMeta(
    'ttsEnabled',
  );
  @override
  late final GeneratedColumn<bool> ttsEnabled = GeneratedColumn<bool>(
    'tts_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("tts_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<int> startDate = GeneratedColumn<int>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<int> endDate = GeneratedColumn<int>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> serverUpdatedAt = GeneratedColumn<int>(
    'server_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    familyId,
    memberId,
    medicineId,
    recurrenceType,
    timesJson,
    intervalHours,
    daysOfWeek,
    doseQty,
    mealRelation,
    ttsEnabled,
    startDate,
    endDate,
    isActive,
    createdAt,
    updatedAt,
    serverUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schedules';
  @override
  VerificationContext validateIntegrity(
    Insertable<Schedule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('family_id')) {
      context.handle(
        _familyIdMeta,
        familyId.isAcceptableOrUnknown(data['family_id']!, _familyIdMeta),
      );
    }
    if (data.containsKey('member_id')) {
      context.handle(
        _memberIdMeta,
        memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta),
      );
    } else if (isInserting) {
      context.missing(_memberIdMeta);
    }
    if (data.containsKey('medicine_id')) {
      context.handle(
        _medicineIdMeta,
        medicineId.isAcceptableOrUnknown(data['medicine_id']!, _medicineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_medicineIdMeta);
    }
    if (data.containsKey('recurrence_type')) {
      context.handle(
        _recurrenceTypeMeta,
        recurrenceType.isAcceptableOrUnknown(
          data['recurrence_type']!,
          _recurrenceTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recurrenceTypeMeta);
    }
    if (data.containsKey('times_json')) {
      context.handle(
        _timesJsonMeta,
        timesJson.isAcceptableOrUnknown(data['times_json']!, _timesJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_timesJsonMeta);
    }
    if (data.containsKey('interval_hours')) {
      context.handle(
        _intervalHoursMeta,
        intervalHours.isAcceptableOrUnknown(
          data['interval_hours']!,
          _intervalHoursMeta,
        ),
      );
    }
    if (data.containsKey('days_of_week')) {
      context.handle(
        _daysOfWeekMeta,
        daysOfWeek.isAcceptableOrUnknown(
          data['days_of_week']!,
          _daysOfWeekMeta,
        ),
      );
    }
    if (data.containsKey('dose_qty')) {
      context.handle(
        _doseQtyMeta,
        doseQty.isAcceptableOrUnknown(data['dose_qty']!, _doseQtyMeta),
      );
    }
    if (data.containsKey('meal_relation')) {
      context.handle(
        _mealRelationMeta,
        mealRelation.isAcceptableOrUnknown(
          data['meal_relation']!,
          _mealRelationMeta,
        ),
      );
    }
    if (data.containsKey('tts_enabled')) {
      context.handle(
        _ttsEnabledMeta,
        ttsEnabled.isAcceptableOrUnknown(data['tts_enabled']!, _ttsEnabledMeta),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Schedule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Schedule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      familyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family_id'],
      ),
      memberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}member_id'],
      )!,
      medicineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medicine_id'],
      )!,
      recurrenceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurrence_type'],
      )!,
      timesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}times_json'],
      )!,
      intervalHours: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_hours'],
      ),
      daysOfWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}days_of_week'],
      ),
      doseQty: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}dose_qty'],
      ),
      mealRelation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meal_relation'],
      ),
      ttsEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}tts_enabled'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_date'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_updated_at'],
      ),
    );
  }

  @override
  $SchedulesTable createAlias(String alias) {
    return $SchedulesTable(attachedDatabase, alias);
  }
}

class Schedule extends DataClass implements Insertable<Schedule> {
  final String id;
  final String? familyId;
  final String memberId;
  final String medicineId;
  final String recurrenceType;
  final String timesJson;
  final int? intervalHours;
  final String? daysOfWeek;
  final double? doseQty;
  final String? mealRelation;
  final bool ttsEnabled;
  final int startDate;
  final int? endDate;
  final bool isActive;
  final int createdAt;
  final int updatedAt;
  final int? serverUpdatedAt;
  const Schedule({
    required this.id,
    this.familyId,
    required this.memberId,
    required this.medicineId,
    required this.recurrenceType,
    required this.timesJson,
    this.intervalHours,
    this.daysOfWeek,
    this.doseQty,
    this.mealRelation,
    required this.ttsEnabled,
    required this.startDate,
    this.endDate,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.serverUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || familyId != null) {
      map['family_id'] = Variable<String>(familyId);
    }
    map['member_id'] = Variable<String>(memberId);
    map['medicine_id'] = Variable<String>(medicineId);
    map['recurrence_type'] = Variable<String>(recurrenceType);
    map['times_json'] = Variable<String>(timesJson);
    if (!nullToAbsent || intervalHours != null) {
      map['interval_hours'] = Variable<int>(intervalHours);
    }
    if (!nullToAbsent || daysOfWeek != null) {
      map['days_of_week'] = Variable<String>(daysOfWeek);
    }
    if (!nullToAbsent || doseQty != null) {
      map['dose_qty'] = Variable<double>(doseQty);
    }
    if (!nullToAbsent || mealRelation != null) {
      map['meal_relation'] = Variable<String>(mealRelation);
    }
    map['tts_enabled'] = Variable<bool>(ttsEnabled);
    map['start_date'] = Variable<int>(startDate);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<int>(endDate);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt);
    }
    return map;
  }

  SchedulesCompanion toCompanion(bool nullToAbsent) {
    return SchedulesCompanion(
      id: Value(id),
      familyId: familyId == null && nullToAbsent
          ? const Value.absent()
          : Value(familyId),
      memberId: Value(memberId),
      medicineId: Value(medicineId),
      recurrenceType: Value(recurrenceType),
      timesJson: Value(timesJson),
      intervalHours: intervalHours == null && nullToAbsent
          ? const Value.absent()
          : Value(intervalHours),
      daysOfWeek: daysOfWeek == null && nullToAbsent
          ? const Value.absent()
          : Value(daysOfWeek),
      doseQty: doseQty == null && nullToAbsent
          ? const Value.absent()
          : Value(doseQty),
      mealRelation: mealRelation == null && nullToAbsent
          ? const Value.absent()
          : Value(mealRelation),
      ttsEnabled: Value(ttsEnabled),
      startDate: Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
    );
  }

  factory Schedule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Schedule(
      id: serializer.fromJson<String>(json['id']),
      familyId: serializer.fromJson<String?>(json['familyId']),
      memberId: serializer.fromJson<String>(json['memberId']),
      medicineId: serializer.fromJson<String>(json['medicineId']),
      recurrenceType: serializer.fromJson<String>(json['recurrenceType']),
      timesJson: serializer.fromJson<String>(json['timesJson']),
      intervalHours: serializer.fromJson<int?>(json['intervalHours']),
      daysOfWeek: serializer.fromJson<String?>(json['daysOfWeek']),
      doseQty: serializer.fromJson<double?>(json['doseQty']),
      mealRelation: serializer.fromJson<String?>(json['mealRelation']),
      ttsEnabled: serializer.fromJson<bool>(json['ttsEnabled']),
      startDate: serializer.fromJson<int>(json['startDate']),
      endDate: serializer.fromJson<int?>(json['endDate']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      serverUpdatedAt: serializer.fromJson<int?>(json['serverUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'familyId': serializer.toJson<String?>(familyId),
      'memberId': serializer.toJson<String>(memberId),
      'medicineId': serializer.toJson<String>(medicineId),
      'recurrenceType': serializer.toJson<String>(recurrenceType),
      'timesJson': serializer.toJson<String>(timesJson),
      'intervalHours': serializer.toJson<int?>(intervalHours),
      'daysOfWeek': serializer.toJson<String?>(daysOfWeek),
      'doseQty': serializer.toJson<double?>(doseQty),
      'mealRelation': serializer.toJson<String?>(mealRelation),
      'ttsEnabled': serializer.toJson<bool>(ttsEnabled),
      'startDate': serializer.toJson<int>(startDate),
      'endDate': serializer.toJson<int?>(endDate),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'serverUpdatedAt': serializer.toJson<int?>(serverUpdatedAt),
    };
  }

  Schedule copyWith({
    String? id,
    Value<String?> familyId = const Value.absent(),
    String? memberId,
    String? medicineId,
    String? recurrenceType,
    String? timesJson,
    Value<int?> intervalHours = const Value.absent(),
    Value<String?> daysOfWeek = const Value.absent(),
    Value<double?> doseQty = const Value.absent(),
    Value<String?> mealRelation = const Value.absent(),
    bool? ttsEnabled,
    int? startDate,
    Value<int?> endDate = const Value.absent(),
    bool? isActive,
    int? createdAt,
    int? updatedAt,
    Value<int?> serverUpdatedAt = const Value.absent(),
  }) => Schedule(
    id: id ?? this.id,
    familyId: familyId.present ? familyId.value : this.familyId,
    memberId: memberId ?? this.memberId,
    medicineId: medicineId ?? this.medicineId,
    recurrenceType: recurrenceType ?? this.recurrenceType,
    timesJson: timesJson ?? this.timesJson,
    intervalHours: intervalHours.present
        ? intervalHours.value
        : this.intervalHours,
    daysOfWeek: daysOfWeek.present ? daysOfWeek.value : this.daysOfWeek,
    doseQty: doseQty.present ? doseQty.value : this.doseQty,
    mealRelation: mealRelation.present ? mealRelation.value : this.mealRelation,
    ttsEnabled: ttsEnabled ?? this.ttsEnabled,
    startDate: startDate ?? this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
  );
  Schedule copyWithCompanion(SchedulesCompanion data) {
    return Schedule(
      id: data.id.present ? data.id.value : this.id,
      familyId: data.familyId.present ? data.familyId.value : this.familyId,
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
      medicineId: data.medicineId.present
          ? data.medicineId.value
          : this.medicineId,
      recurrenceType: data.recurrenceType.present
          ? data.recurrenceType.value
          : this.recurrenceType,
      timesJson: data.timesJson.present ? data.timesJson.value : this.timesJson,
      intervalHours: data.intervalHours.present
          ? data.intervalHours.value
          : this.intervalHours,
      daysOfWeek: data.daysOfWeek.present
          ? data.daysOfWeek.value
          : this.daysOfWeek,
      doseQty: data.doseQty.present ? data.doseQty.value : this.doseQty,
      mealRelation: data.mealRelation.present
          ? data.mealRelation.value
          : this.mealRelation,
      ttsEnabled: data.ttsEnabled.present
          ? data.ttsEnabled.value
          : this.ttsEnabled,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Schedule(')
          ..write('id: $id, ')
          ..write('familyId: $familyId, ')
          ..write('memberId: $memberId, ')
          ..write('medicineId: $medicineId, ')
          ..write('recurrenceType: $recurrenceType, ')
          ..write('timesJson: $timesJson, ')
          ..write('intervalHours: $intervalHours, ')
          ..write('daysOfWeek: $daysOfWeek, ')
          ..write('doseQty: $doseQty, ')
          ..write('mealRelation: $mealRelation, ')
          ..write('ttsEnabled: $ttsEnabled, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    familyId,
    memberId,
    medicineId,
    recurrenceType,
    timesJson,
    intervalHours,
    daysOfWeek,
    doseQty,
    mealRelation,
    ttsEnabled,
    startDate,
    endDate,
    isActive,
    createdAt,
    updatedAt,
    serverUpdatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Schedule &&
          other.id == this.id &&
          other.familyId == this.familyId &&
          other.memberId == this.memberId &&
          other.medicineId == this.medicineId &&
          other.recurrenceType == this.recurrenceType &&
          other.timesJson == this.timesJson &&
          other.intervalHours == this.intervalHours &&
          other.daysOfWeek == this.daysOfWeek &&
          other.doseQty == this.doseQty &&
          other.mealRelation == this.mealRelation &&
          other.ttsEnabled == this.ttsEnabled &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt);
}

class SchedulesCompanion extends UpdateCompanion<Schedule> {
  final Value<String> id;
  final Value<String?> familyId;
  final Value<String> memberId;
  final Value<String> medicineId;
  final Value<String> recurrenceType;
  final Value<String> timesJson;
  final Value<int?> intervalHours;
  final Value<String?> daysOfWeek;
  final Value<double?> doseQty;
  final Value<String?> mealRelation;
  final Value<bool> ttsEnabled;
  final Value<int> startDate;
  final Value<int?> endDate;
  final Value<bool> isActive;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> serverUpdatedAt;
  final Value<int> rowid;
  const SchedulesCompanion({
    this.id = const Value.absent(),
    this.familyId = const Value.absent(),
    this.memberId = const Value.absent(),
    this.medicineId = const Value.absent(),
    this.recurrenceType = const Value.absent(),
    this.timesJson = const Value.absent(),
    this.intervalHours = const Value.absent(),
    this.daysOfWeek = const Value.absent(),
    this.doseQty = const Value.absent(),
    this.mealRelation = const Value.absent(),
    this.ttsEnabled = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SchedulesCompanion.insert({
    required String id,
    this.familyId = const Value.absent(),
    required String memberId,
    required String medicineId,
    required String recurrenceType,
    required String timesJson,
    this.intervalHours = const Value.absent(),
    this.daysOfWeek = const Value.absent(),
    this.doseQty = const Value.absent(),
    this.mealRelation = const Value.absent(),
    this.ttsEnabled = const Value.absent(),
    required int startDate,
    this.endDate = const Value.absent(),
    this.isActive = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       memberId = Value(memberId),
       medicineId = Value(medicineId),
       recurrenceType = Value(recurrenceType),
       timesJson = Value(timesJson),
       startDate = Value(startDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Schedule> custom({
    Expression<String>? id,
    Expression<String>? familyId,
    Expression<String>? memberId,
    Expression<String>? medicineId,
    Expression<String>? recurrenceType,
    Expression<String>? timesJson,
    Expression<int>? intervalHours,
    Expression<String>? daysOfWeek,
    Expression<double>? doseQty,
    Expression<String>? mealRelation,
    Expression<bool>? ttsEnabled,
    Expression<int>? startDate,
    Expression<int>? endDate,
    Expression<bool>? isActive,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? serverUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (familyId != null) 'family_id': familyId,
      if (memberId != null) 'member_id': memberId,
      if (medicineId != null) 'medicine_id': medicineId,
      if (recurrenceType != null) 'recurrence_type': recurrenceType,
      if (timesJson != null) 'times_json': timesJson,
      if (intervalHours != null) 'interval_hours': intervalHours,
      if (daysOfWeek != null) 'days_of_week': daysOfWeek,
      if (doseQty != null) 'dose_qty': doseQty,
      if (mealRelation != null) 'meal_relation': mealRelation,
      if (ttsEnabled != null) 'tts_enabled': ttsEnabled,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SchedulesCompanion copyWith({
    Value<String>? id,
    Value<String?>? familyId,
    Value<String>? memberId,
    Value<String>? medicineId,
    Value<String>? recurrenceType,
    Value<String>? timesJson,
    Value<int?>? intervalHours,
    Value<String?>? daysOfWeek,
    Value<double?>? doseQty,
    Value<String?>? mealRelation,
    Value<bool>? ttsEnabled,
    Value<int>? startDate,
    Value<int?>? endDate,
    Value<bool>? isActive,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? serverUpdatedAt,
    Value<int>? rowid,
  }) {
    return SchedulesCompanion(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      memberId: memberId ?? this.memberId,
      medicineId: medicineId ?? this.medicineId,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      timesJson: timesJson ?? this.timesJson,
      intervalHours: intervalHours ?? this.intervalHours,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      doseQty: doseQty ?? this.doseQty,
      mealRelation: mealRelation ?? this.mealRelation,
      ttsEnabled: ttsEnabled ?? this.ttsEnabled,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (familyId.present) {
      map['family_id'] = Variable<String>(familyId.value);
    }
    if (memberId.present) {
      map['member_id'] = Variable<String>(memberId.value);
    }
    if (medicineId.present) {
      map['medicine_id'] = Variable<String>(medicineId.value);
    }
    if (recurrenceType.present) {
      map['recurrence_type'] = Variable<String>(recurrenceType.value);
    }
    if (timesJson.present) {
      map['times_json'] = Variable<String>(timesJson.value);
    }
    if (intervalHours.present) {
      map['interval_hours'] = Variable<int>(intervalHours.value);
    }
    if (daysOfWeek.present) {
      map['days_of_week'] = Variable<String>(daysOfWeek.value);
    }
    if (doseQty.present) {
      map['dose_qty'] = Variable<double>(doseQty.value);
    }
    if (mealRelation.present) {
      map['meal_relation'] = Variable<String>(mealRelation.value);
    }
    if (ttsEnabled.present) {
      map['tts_enabled'] = Variable<bool>(ttsEnabled.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<int>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<int>(endDate.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SchedulesCompanion(')
          ..write('id: $id, ')
          ..write('familyId: $familyId, ')
          ..write('memberId: $memberId, ')
          ..write('medicineId: $medicineId, ')
          ..write('recurrenceType: $recurrenceType, ')
          ..write('timesJson: $timesJson, ')
          ..write('intervalHours: $intervalHours, ')
          ..write('daysOfWeek: $daysOfWeek, ')
          ..write('doseQty: $doseQty, ')
          ..write('mealRelation: $mealRelation, ')
          ..write('ttsEnabled: $ttsEnabled, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DoseLogsTable extends DoseLogs with TableInfo<$DoseLogsTable, DoseLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DoseLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _familyIdMeta = const VerificationMeta(
    'familyId',
  );
  @override
  late final GeneratedColumn<String> familyId = GeneratedColumn<String>(
    'family_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scheduleIdMeta = const VerificationMeta(
    'scheduleId',
  );
  @override
  late final GeneratedColumn<String> scheduleId = GeneratedColumn<String>(
    'schedule_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _memberIdMeta = const VerificationMeta(
    'memberId',
  );
  @override
  late final GeneratedColumn<String> memberId = GeneratedColumn<String>(
    'member_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _medicineIdMeta = const VerificationMeta(
    'medicineId',
  );
  @override
  late final GeneratedColumn<String> medicineId = GeneratedColumn<String>(
    'medicine_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduledAtMeta = const VerificationMeta(
    'scheduledAt',
  );
  @override
  late final GeneratedColumn<int> scheduledAt = GeneratedColumn<int>(
    'scheduled_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _effectiveScheduledAtMeta =
      const VerificationMeta('effectiveScheduledAt');
  @override
  late final GeneratedColumn<int> effectiveScheduledAt = GeneratedColumn<int>(
    'effective_scheduled_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _snoozeCountMeta = const VerificationMeta(
    'snoozeCount',
  );
  @override
  late final GeneratedColumn<int> snoozeCount = GeneratedColumn<int>(
    'snooze_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stockAppliedMeta = const VerificationMeta(
    'stockApplied',
  );
  @override
  late final GeneratedColumn<bool> stockApplied = GeneratedColumn<bool>(
    'stock_applied',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("stock_applied" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _actionByEmailMeta = const VerificationMeta(
    'actionByEmail',
  );
  @override
  late final GeneratedColumn<String> actionByEmail = GeneratedColumn<String>(
    'action_by_email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actionAtMeta = const VerificationMeta(
    'actionAt',
  );
  @override
  late final GeneratedColumn<int> actionAt = GeneratedColumn<int>(
    'action_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> serverUpdatedAt = GeneratedColumn<int>(
    'server_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    familyId,
    scheduleId,
    memberId,
    medicineId,
    scheduledAt,
    effectiveScheduledAt,
    snoozeCount,
    status,
    stockApplied,
    actionByEmail,
    actionAt,
    note,
    updatedAt,
    serverUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dose_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<DoseLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('family_id')) {
      context.handle(
        _familyIdMeta,
        familyId.isAcceptableOrUnknown(data['family_id']!, _familyIdMeta),
      );
    }
    if (data.containsKey('schedule_id')) {
      context.handle(
        _scheduleIdMeta,
        scheduleId.isAcceptableOrUnknown(data['schedule_id']!, _scheduleIdMeta),
      );
    }
    if (data.containsKey('member_id')) {
      context.handle(
        _memberIdMeta,
        memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta),
      );
    } else if (isInserting) {
      context.missing(_memberIdMeta);
    }
    if (data.containsKey('medicine_id')) {
      context.handle(
        _medicineIdMeta,
        medicineId.isAcceptableOrUnknown(data['medicine_id']!, _medicineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_medicineIdMeta);
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
        _scheduledAtMeta,
        scheduledAt.isAcceptableOrUnknown(
          data['scheduled_at']!,
          _scheduledAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledAtMeta);
    }
    if (data.containsKey('effective_scheduled_at')) {
      context.handle(
        _effectiveScheduledAtMeta,
        effectiveScheduledAt.isAcceptableOrUnknown(
          data['effective_scheduled_at']!,
          _effectiveScheduledAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_effectiveScheduledAtMeta);
    }
    if (data.containsKey('snooze_count')) {
      context.handle(
        _snoozeCountMeta,
        snoozeCount.isAcceptableOrUnknown(
          data['snooze_count']!,
          _snoozeCountMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('stock_applied')) {
      context.handle(
        _stockAppliedMeta,
        stockApplied.isAcceptableOrUnknown(
          data['stock_applied']!,
          _stockAppliedMeta,
        ),
      );
    }
    if (data.containsKey('action_by_email')) {
      context.handle(
        _actionByEmailMeta,
        actionByEmail.isAcceptableOrUnknown(
          data['action_by_email']!,
          _actionByEmailMeta,
        ),
      );
    }
    if (data.containsKey('action_at')) {
      context.handle(
        _actionAtMeta,
        actionAt.isAcceptableOrUnknown(data['action_at']!, _actionAtMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {scheduleId, scheduledAt},
  ];
  @override
  DoseLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DoseLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      familyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family_id'],
      ),
      scheduleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}schedule_id'],
      ),
      memberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}member_id'],
      )!,
      medicineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medicine_id'],
      )!,
      scheduledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}scheduled_at'],
      )!,
      effectiveScheduledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}effective_scheduled_at'],
      )!,
      snoozeCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}snooze_count'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      stockApplied: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}stock_applied'],
      )!,
      actionByEmail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action_by_email'],
      ),
      actionAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}action_at'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_updated_at'],
      ),
    );
  }

  @override
  $DoseLogsTable createAlias(String alias) {
    return $DoseLogsTable(attachedDatabase, alias);
  }
}

class DoseLog extends DataClass implements Insertable<DoseLog> {
  final String id;
  final String? familyId;
  final String? scheduleId;
  final String memberId;
  final String medicineId;
  final int scheduledAt;
  final int effectiveScheduledAt;
  final int snoozeCount;
  final String status;
  final bool stockApplied;
  final String? actionByEmail;
  final int? actionAt;
  final String? note;
  final int updatedAt;
  final int? serverUpdatedAt;
  const DoseLog({
    required this.id,
    this.familyId,
    this.scheduleId,
    required this.memberId,
    required this.medicineId,
    required this.scheduledAt,
    required this.effectiveScheduledAt,
    required this.snoozeCount,
    required this.status,
    required this.stockApplied,
    this.actionByEmail,
    this.actionAt,
    this.note,
    required this.updatedAt,
    this.serverUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || familyId != null) {
      map['family_id'] = Variable<String>(familyId);
    }
    if (!nullToAbsent || scheduleId != null) {
      map['schedule_id'] = Variable<String>(scheduleId);
    }
    map['member_id'] = Variable<String>(memberId);
    map['medicine_id'] = Variable<String>(medicineId);
    map['scheduled_at'] = Variable<int>(scheduledAt);
    map['effective_scheduled_at'] = Variable<int>(effectiveScheduledAt);
    map['snooze_count'] = Variable<int>(snoozeCount);
    map['status'] = Variable<String>(status);
    map['stock_applied'] = Variable<bool>(stockApplied);
    if (!nullToAbsent || actionByEmail != null) {
      map['action_by_email'] = Variable<String>(actionByEmail);
    }
    if (!nullToAbsent || actionAt != null) {
      map['action_at'] = Variable<int>(actionAt);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt);
    }
    return map;
  }

  DoseLogsCompanion toCompanion(bool nullToAbsent) {
    return DoseLogsCompanion(
      id: Value(id),
      familyId: familyId == null && nullToAbsent
          ? const Value.absent()
          : Value(familyId),
      scheduleId: scheduleId == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduleId),
      memberId: Value(memberId),
      medicineId: Value(medicineId),
      scheduledAt: Value(scheduledAt),
      effectiveScheduledAt: Value(effectiveScheduledAt),
      snoozeCount: Value(snoozeCount),
      status: Value(status),
      stockApplied: Value(stockApplied),
      actionByEmail: actionByEmail == null && nullToAbsent
          ? const Value.absent()
          : Value(actionByEmail),
      actionAt: actionAt == null && nullToAbsent
          ? const Value.absent()
          : Value(actionAt),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      updatedAt: Value(updatedAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
    );
  }

  factory DoseLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DoseLog(
      id: serializer.fromJson<String>(json['id']),
      familyId: serializer.fromJson<String?>(json['familyId']),
      scheduleId: serializer.fromJson<String?>(json['scheduleId']),
      memberId: serializer.fromJson<String>(json['memberId']),
      medicineId: serializer.fromJson<String>(json['medicineId']),
      scheduledAt: serializer.fromJson<int>(json['scheduledAt']),
      effectiveScheduledAt: serializer.fromJson<int>(
        json['effectiveScheduledAt'],
      ),
      snoozeCount: serializer.fromJson<int>(json['snoozeCount']),
      status: serializer.fromJson<String>(json['status']),
      stockApplied: serializer.fromJson<bool>(json['stockApplied']),
      actionByEmail: serializer.fromJson<String?>(json['actionByEmail']),
      actionAt: serializer.fromJson<int?>(json['actionAt']),
      note: serializer.fromJson<String?>(json['note']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      serverUpdatedAt: serializer.fromJson<int?>(json['serverUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'familyId': serializer.toJson<String?>(familyId),
      'scheduleId': serializer.toJson<String?>(scheduleId),
      'memberId': serializer.toJson<String>(memberId),
      'medicineId': serializer.toJson<String>(medicineId),
      'scheduledAt': serializer.toJson<int>(scheduledAt),
      'effectiveScheduledAt': serializer.toJson<int>(effectiveScheduledAt),
      'snoozeCount': serializer.toJson<int>(snoozeCount),
      'status': serializer.toJson<String>(status),
      'stockApplied': serializer.toJson<bool>(stockApplied),
      'actionByEmail': serializer.toJson<String?>(actionByEmail),
      'actionAt': serializer.toJson<int?>(actionAt),
      'note': serializer.toJson<String?>(note),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'serverUpdatedAt': serializer.toJson<int?>(serverUpdatedAt),
    };
  }

  DoseLog copyWith({
    String? id,
    Value<String?> familyId = const Value.absent(),
    Value<String?> scheduleId = const Value.absent(),
    String? memberId,
    String? medicineId,
    int? scheduledAt,
    int? effectiveScheduledAt,
    int? snoozeCount,
    String? status,
    bool? stockApplied,
    Value<String?> actionByEmail = const Value.absent(),
    Value<int?> actionAt = const Value.absent(),
    Value<String?> note = const Value.absent(),
    int? updatedAt,
    Value<int?> serverUpdatedAt = const Value.absent(),
  }) => DoseLog(
    id: id ?? this.id,
    familyId: familyId.present ? familyId.value : this.familyId,
    scheduleId: scheduleId.present ? scheduleId.value : this.scheduleId,
    memberId: memberId ?? this.memberId,
    medicineId: medicineId ?? this.medicineId,
    scheduledAt: scheduledAt ?? this.scheduledAt,
    effectiveScheduledAt: effectiveScheduledAt ?? this.effectiveScheduledAt,
    snoozeCount: snoozeCount ?? this.snoozeCount,
    status: status ?? this.status,
    stockApplied: stockApplied ?? this.stockApplied,
    actionByEmail: actionByEmail.present
        ? actionByEmail.value
        : this.actionByEmail,
    actionAt: actionAt.present ? actionAt.value : this.actionAt,
    note: note.present ? note.value : this.note,
    updatedAt: updatedAt ?? this.updatedAt,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
  );
  DoseLog copyWithCompanion(DoseLogsCompanion data) {
    return DoseLog(
      id: data.id.present ? data.id.value : this.id,
      familyId: data.familyId.present ? data.familyId.value : this.familyId,
      scheduleId: data.scheduleId.present
          ? data.scheduleId.value
          : this.scheduleId,
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
      medicineId: data.medicineId.present
          ? data.medicineId.value
          : this.medicineId,
      scheduledAt: data.scheduledAt.present
          ? data.scheduledAt.value
          : this.scheduledAt,
      effectiveScheduledAt: data.effectiveScheduledAt.present
          ? data.effectiveScheduledAt.value
          : this.effectiveScheduledAt,
      snoozeCount: data.snoozeCount.present
          ? data.snoozeCount.value
          : this.snoozeCount,
      status: data.status.present ? data.status.value : this.status,
      stockApplied: data.stockApplied.present
          ? data.stockApplied.value
          : this.stockApplied,
      actionByEmail: data.actionByEmail.present
          ? data.actionByEmail.value
          : this.actionByEmail,
      actionAt: data.actionAt.present ? data.actionAt.value : this.actionAt,
      note: data.note.present ? data.note.value : this.note,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DoseLog(')
          ..write('id: $id, ')
          ..write('familyId: $familyId, ')
          ..write('scheduleId: $scheduleId, ')
          ..write('memberId: $memberId, ')
          ..write('medicineId: $medicineId, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('effectiveScheduledAt: $effectiveScheduledAt, ')
          ..write('snoozeCount: $snoozeCount, ')
          ..write('status: $status, ')
          ..write('stockApplied: $stockApplied, ')
          ..write('actionByEmail: $actionByEmail, ')
          ..write('actionAt: $actionAt, ')
          ..write('note: $note, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    familyId,
    scheduleId,
    memberId,
    medicineId,
    scheduledAt,
    effectiveScheduledAt,
    snoozeCount,
    status,
    stockApplied,
    actionByEmail,
    actionAt,
    note,
    updatedAt,
    serverUpdatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DoseLog &&
          other.id == this.id &&
          other.familyId == this.familyId &&
          other.scheduleId == this.scheduleId &&
          other.memberId == this.memberId &&
          other.medicineId == this.medicineId &&
          other.scheduledAt == this.scheduledAt &&
          other.effectiveScheduledAt == this.effectiveScheduledAt &&
          other.snoozeCount == this.snoozeCount &&
          other.status == this.status &&
          other.stockApplied == this.stockApplied &&
          other.actionByEmail == this.actionByEmail &&
          other.actionAt == this.actionAt &&
          other.note == this.note &&
          other.updatedAt == this.updatedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt);
}

class DoseLogsCompanion extends UpdateCompanion<DoseLog> {
  final Value<String> id;
  final Value<String?> familyId;
  final Value<String?> scheduleId;
  final Value<String> memberId;
  final Value<String> medicineId;
  final Value<int> scheduledAt;
  final Value<int> effectiveScheduledAt;
  final Value<int> snoozeCount;
  final Value<String> status;
  final Value<bool> stockApplied;
  final Value<String?> actionByEmail;
  final Value<int?> actionAt;
  final Value<String?> note;
  final Value<int> updatedAt;
  final Value<int?> serverUpdatedAt;
  final Value<int> rowid;
  const DoseLogsCompanion({
    this.id = const Value.absent(),
    this.familyId = const Value.absent(),
    this.scheduleId = const Value.absent(),
    this.memberId = const Value.absent(),
    this.medicineId = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.effectiveScheduledAt = const Value.absent(),
    this.snoozeCount = const Value.absent(),
    this.status = const Value.absent(),
    this.stockApplied = const Value.absent(),
    this.actionByEmail = const Value.absent(),
    this.actionAt = const Value.absent(),
    this.note = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DoseLogsCompanion.insert({
    required String id,
    this.familyId = const Value.absent(),
    this.scheduleId = const Value.absent(),
    required String memberId,
    required String medicineId,
    required int scheduledAt,
    required int effectiveScheduledAt,
    this.snoozeCount = const Value.absent(),
    required String status,
    this.stockApplied = const Value.absent(),
    this.actionByEmail = const Value.absent(),
    this.actionAt = const Value.absent(),
    this.note = const Value.absent(),
    required int updatedAt,
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       memberId = Value(memberId),
       medicineId = Value(medicineId),
       scheduledAt = Value(scheduledAt),
       effectiveScheduledAt = Value(effectiveScheduledAt),
       status = Value(status),
       updatedAt = Value(updatedAt);
  static Insertable<DoseLog> custom({
    Expression<String>? id,
    Expression<String>? familyId,
    Expression<String>? scheduleId,
    Expression<String>? memberId,
    Expression<String>? medicineId,
    Expression<int>? scheduledAt,
    Expression<int>? effectiveScheduledAt,
    Expression<int>? snoozeCount,
    Expression<String>? status,
    Expression<bool>? stockApplied,
    Expression<String>? actionByEmail,
    Expression<int>? actionAt,
    Expression<String>? note,
    Expression<int>? updatedAt,
    Expression<int>? serverUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (familyId != null) 'family_id': familyId,
      if (scheduleId != null) 'schedule_id': scheduleId,
      if (memberId != null) 'member_id': memberId,
      if (medicineId != null) 'medicine_id': medicineId,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (effectiveScheduledAt != null)
        'effective_scheduled_at': effectiveScheduledAt,
      if (snoozeCount != null) 'snooze_count': snoozeCount,
      if (status != null) 'status': status,
      if (stockApplied != null) 'stock_applied': stockApplied,
      if (actionByEmail != null) 'action_by_email': actionByEmail,
      if (actionAt != null) 'action_at': actionAt,
      if (note != null) 'note': note,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DoseLogsCompanion copyWith({
    Value<String>? id,
    Value<String?>? familyId,
    Value<String?>? scheduleId,
    Value<String>? memberId,
    Value<String>? medicineId,
    Value<int>? scheduledAt,
    Value<int>? effectiveScheduledAt,
    Value<int>? snoozeCount,
    Value<String>? status,
    Value<bool>? stockApplied,
    Value<String?>? actionByEmail,
    Value<int?>? actionAt,
    Value<String?>? note,
    Value<int>? updatedAt,
    Value<int?>? serverUpdatedAt,
    Value<int>? rowid,
  }) {
    return DoseLogsCompanion(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      scheduleId: scheduleId ?? this.scheduleId,
      memberId: memberId ?? this.memberId,
      medicineId: medicineId ?? this.medicineId,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      effectiveScheduledAt: effectiveScheduledAt ?? this.effectiveScheduledAt,
      snoozeCount: snoozeCount ?? this.snoozeCount,
      status: status ?? this.status,
      stockApplied: stockApplied ?? this.stockApplied,
      actionByEmail: actionByEmail ?? this.actionByEmail,
      actionAt: actionAt ?? this.actionAt,
      note: note ?? this.note,
      updatedAt: updatedAt ?? this.updatedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (familyId.present) {
      map['family_id'] = Variable<String>(familyId.value);
    }
    if (scheduleId.present) {
      map['schedule_id'] = Variable<String>(scheduleId.value);
    }
    if (memberId.present) {
      map['member_id'] = Variable<String>(memberId.value);
    }
    if (medicineId.present) {
      map['medicine_id'] = Variable<String>(medicineId.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<int>(scheduledAt.value);
    }
    if (effectiveScheduledAt.present) {
      map['effective_scheduled_at'] = Variable<int>(effectiveScheduledAt.value);
    }
    if (snoozeCount.present) {
      map['snooze_count'] = Variable<int>(snoozeCount.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (stockApplied.present) {
      map['stock_applied'] = Variable<bool>(stockApplied.value);
    }
    if (actionByEmail.present) {
      map['action_by_email'] = Variable<String>(actionByEmail.value);
    }
    if (actionAt.present) {
      map['action_at'] = Variable<int>(actionAt.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DoseLogsCompanion(')
          ..write('id: $id, ')
          ..write('familyId: $familyId, ')
          ..write('scheduleId: $scheduleId, ')
          ..write('memberId: $memberId, ')
          ..write('medicineId: $medicineId, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('effectiveScheduledAt: $effectiveScheduledAt, ')
          ..write('snoozeCount: $snoozeCount, ')
          ..write('status: $status, ')
          ..write('stockApplied: $stockApplied, ')
          ..write('actionByEmail: $actionByEmail, ')
          ..write('actionAt: $actionAt, ')
          ..write('note: $note, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ControlVisitsTable extends ControlVisits
    with TableInfo<$ControlVisitsTable, ControlVisit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ControlVisitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _familyIdMeta = const VerificationMeta(
    'familyId',
  );
  @override
  late final GeneratedColumn<String> familyId = GeneratedColumn<String>(
    'family_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _memberIdMeta = const VerificationMeta(
    'memberId',
  );
  @override
  late final GeneratedColumn<String> memberId = GeneratedColumn<String>(
    'member_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hospitalMeta = const VerificationMeta(
    'hospital',
  );
  @override
  late final GeneratedColumn<String> hospital = GeneratedColumn<String>(
    'hospital',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _doctorMeta = const VerificationMeta('doctor');
  @override
  late final GeneratedColumn<String> doctor = GeneratedColumn<String>(
    'doctor',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _visitAtMeta = const VerificationMeta(
    'visitAt',
  );
  @override
  late final GeneratedColumn<int> visitAt = GeneratedColumn<int>(
    'visit_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reminderH2AtMeta = const VerificationMeta(
    'reminderH2At',
  );
  @override
  late final GeneratedColumn<int> reminderH2At = GeneratedColumn<int>(
    'reminder_h2_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reminderH1AtMeta = const VerificationMeta(
    'reminderH1At',
  );
  @override
  late final GeneratedColumn<int> reminderH1At = GeneratedColumn<int>(
    'reminder_h1_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('upcoming'),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> serverUpdatedAt = GeneratedColumn<int>(
    'server_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    familyId,
    memberId,
    hospital,
    doctor,
    visitAt,
    reminderH2At,
    reminderH1At,
    status,
    notes,
    updatedAt,
    serverUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'control_visits';
  @override
  VerificationContext validateIntegrity(
    Insertable<ControlVisit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('family_id')) {
      context.handle(
        _familyIdMeta,
        familyId.isAcceptableOrUnknown(data['family_id']!, _familyIdMeta),
      );
    }
    if (data.containsKey('member_id')) {
      context.handle(
        _memberIdMeta,
        memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta),
      );
    } else if (isInserting) {
      context.missing(_memberIdMeta);
    }
    if (data.containsKey('hospital')) {
      context.handle(
        _hospitalMeta,
        hospital.isAcceptableOrUnknown(data['hospital']!, _hospitalMeta),
      );
    } else if (isInserting) {
      context.missing(_hospitalMeta);
    }
    if (data.containsKey('doctor')) {
      context.handle(
        _doctorMeta,
        doctor.isAcceptableOrUnknown(data['doctor']!, _doctorMeta),
      );
    }
    if (data.containsKey('visit_at')) {
      context.handle(
        _visitAtMeta,
        visitAt.isAcceptableOrUnknown(data['visit_at']!, _visitAtMeta),
      );
    } else if (isInserting) {
      context.missing(_visitAtMeta);
    }
    if (data.containsKey('reminder_h2_at')) {
      context.handle(
        _reminderH2AtMeta,
        reminderH2At.isAcceptableOrUnknown(
          data['reminder_h2_at']!,
          _reminderH2AtMeta,
        ),
      );
    }
    if (data.containsKey('reminder_h1_at')) {
      context.handle(
        _reminderH1AtMeta,
        reminderH1At.isAcceptableOrUnknown(
          data['reminder_h1_at']!,
          _reminderH1AtMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ControlVisit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ControlVisit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      familyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family_id'],
      ),
      memberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}member_id'],
      )!,
      hospital: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hospital'],
      )!,
      doctor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}doctor'],
      ),
      visitAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}visit_at'],
      )!,
      reminderH2At: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_h2_at'],
      ),
      reminderH1At: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_h1_at'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_updated_at'],
      ),
    );
  }

  @override
  $ControlVisitsTable createAlias(String alias) {
    return $ControlVisitsTable(attachedDatabase, alias);
  }
}

class ControlVisit extends DataClass implements Insertable<ControlVisit> {
  final String id;
  final String? familyId;
  final String memberId;
  final String hospital;
  final String? doctor;
  final int visitAt;
  final int? reminderH2At;
  final int? reminderH1At;
  final String status;
  final String? notes;
  final int updatedAt;
  final int? serverUpdatedAt;
  const ControlVisit({
    required this.id,
    this.familyId,
    required this.memberId,
    required this.hospital,
    this.doctor,
    required this.visitAt,
    this.reminderH2At,
    this.reminderH1At,
    required this.status,
    this.notes,
    required this.updatedAt,
    this.serverUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || familyId != null) {
      map['family_id'] = Variable<String>(familyId);
    }
    map['member_id'] = Variable<String>(memberId);
    map['hospital'] = Variable<String>(hospital);
    if (!nullToAbsent || doctor != null) {
      map['doctor'] = Variable<String>(doctor);
    }
    map['visit_at'] = Variable<int>(visitAt);
    if (!nullToAbsent || reminderH2At != null) {
      map['reminder_h2_at'] = Variable<int>(reminderH2At);
    }
    if (!nullToAbsent || reminderH1At != null) {
      map['reminder_h1_at'] = Variable<int>(reminderH1At);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt);
    }
    return map;
  }

  ControlVisitsCompanion toCompanion(bool nullToAbsent) {
    return ControlVisitsCompanion(
      id: Value(id),
      familyId: familyId == null && nullToAbsent
          ? const Value.absent()
          : Value(familyId),
      memberId: Value(memberId),
      hospital: Value(hospital),
      doctor: doctor == null && nullToAbsent
          ? const Value.absent()
          : Value(doctor),
      visitAt: Value(visitAt),
      reminderH2At: reminderH2At == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderH2At),
      reminderH1At: reminderH1At == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderH1At),
      status: Value(status),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      updatedAt: Value(updatedAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
    );
  }

  factory ControlVisit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ControlVisit(
      id: serializer.fromJson<String>(json['id']),
      familyId: serializer.fromJson<String?>(json['familyId']),
      memberId: serializer.fromJson<String>(json['memberId']),
      hospital: serializer.fromJson<String>(json['hospital']),
      doctor: serializer.fromJson<String?>(json['doctor']),
      visitAt: serializer.fromJson<int>(json['visitAt']),
      reminderH2At: serializer.fromJson<int?>(json['reminderH2At']),
      reminderH1At: serializer.fromJson<int?>(json['reminderH1At']),
      status: serializer.fromJson<String>(json['status']),
      notes: serializer.fromJson<String?>(json['notes']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      serverUpdatedAt: serializer.fromJson<int?>(json['serverUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'familyId': serializer.toJson<String?>(familyId),
      'memberId': serializer.toJson<String>(memberId),
      'hospital': serializer.toJson<String>(hospital),
      'doctor': serializer.toJson<String?>(doctor),
      'visitAt': serializer.toJson<int>(visitAt),
      'reminderH2At': serializer.toJson<int?>(reminderH2At),
      'reminderH1At': serializer.toJson<int?>(reminderH1At),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String?>(notes),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'serverUpdatedAt': serializer.toJson<int?>(serverUpdatedAt),
    };
  }

  ControlVisit copyWith({
    String? id,
    Value<String?> familyId = const Value.absent(),
    String? memberId,
    String? hospital,
    Value<String?> doctor = const Value.absent(),
    int? visitAt,
    Value<int?> reminderH2At = const Value.absent(),
    Value<int?> reminderH1At = const Value.absent(),
    String? status,
    Value<String?> notes = const Value.absent(),
    int? updatedAt,
    Value<int?> serverUpdatedAt = const Value.absent(),
  }) => ControlVisit(
    id: id ?? this.id,
    familyId: familyId.present ? familyId.value : this.familyId,
    memberId: memberId ?? this.memberId,
    hospital: hospital ?? this.hospital,
    doctor: doctor.present ? doctor.value : this.doctor,
    visitAt: visitAt ?? this.visitAt,
    reminderH2At: reminderH2At.present ? reminderH2At.value : this.reminderH2At,
    reminderH1At: reminderH1At.present ? reminderH1At.value : this.reminderH1At,
    status: status ?? this.status,
    notes: notes.present ? notes.value : this.notes,
    updatedAt: updatedAt ?? this.updatedAt,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
  );
  ControlVisit copyWithCompanion(ControlVisitsCompanion data) {
    return ControlVisit(
      id: data.id.present ? data.id.value : this.id,
      familyId: data.familyId.present ? data.familyId.value : this.familyId,
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
      hospital: data.hospital.present ? data.hospital.value : this.hospital,
      doctor: data.doctor.present ? data.doctor.value : this.doctor,
      visitAt: data.visitAt.present ? data.visitAt.value : this.visitAt,
      reminderH2At: data.reminderH2At.present
          ? data.reminderH2At.value
          : this.reminderH2At,
      reminderH1At: data.reminderH1At.present
          ? data.reminderH1At.value
          : this.reminderH1At,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ControlVisit(')
          ..write('id: $id, ')
          ..write('familyId: $familyId, ')
          ..write('memberId: $memberId, ')
          ..write('hospital: $hospital, ')
          ..write('doctor: $doctor, ')
          ..write('visitAt: $visitAt, ')
          ..write('reminderH2At: $reminderH2At, ')
          ..write('reminderH1At: $reminderH1At, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    familyId,
    memberId,
    hospital,
    doctor,
    visitAt,
    reminderH2At,
    reminderH1At,
    status,
    notes,
    updatedAt,
    serverUpdatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ControlVisit &&
          other.id == this.id &&
          other.familyId == this.familyId &&
          other.memberId == this.memberId &&
          other.hospital == this.hospital &&
          other.doctor == this.doctor &&
          other.visitAt == this.visitAt &&
          other.reminderH2At == this.reminderH2At &&
          other.reminderH1At == this.reminderH1At &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.updatedAt == this.updatedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt);
}

class ControlVisitsCompanion extends UpdateCompanion<ControlVisit> {
  final Value<String> id;
  final Value<String?> familyId;
  final Value<String> memberId;
  final Value<String> hospital;
  final Value<String?> doctor;
  final Value<int> visitAt;
  final Value<int?> reminderH2At;
  final Value<int?> reminderH1At;
  final Value<String> status;
  final Value<String?> notes;
  final Value<int> updatedAt;
  final Value<int?> serverUpdatedAt;
  final Value<int> rowid;
  const ControlVisitsCompanion({
    this.id = const Value.absent(),
    this.familyId = const Value.absent(),
    this.memberId = const Value.absent(),
    this.hospital = const Value.absent(),
    this.doctor = const Value.absent(),
    this.visitAt = const Value.absent(),
    this.reminderH2At = const Value.absent(),
    this.reminderH1At = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ControlVisitsCompanion.insert({
    required String id,
    this.familyId = const Value.absent(),
    required String memberId,
    required String hospital,
    this.doctor = const Value.absent(),
    required int visitAt,
    this.reminderH2At = const Value.absent(),
    this.reminderH1At = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    required int updatedAt,
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       memberId = Value(memberId),
       hospital = Value(hospital),
       visitAt = Value(visitAt),
       updatedAt = Value(updatedAt);
  static Insertable<ControlVisit> custom({
    Expression<String>? id,
    Expression<String>? familyId,
    Expression<String>? memberId,
    Expression<String>? hospital,
    Expression<String>? doctor,
    Expression<int>? visitAt,
    Expression<int>? reminderH2At,
    Expression<int>? reminderH1At,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<int>? updatedAt,
    Expression<int>? serverUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (familyId != null) 'family_id': familyId,
      if (memberId != null) 'member_id': memberId,
      if (hospital != null) 'hospital': hospital,
      if (doctor != null) 'doctor': doctor,
      if (visitAt != null) 'visit_at': visitAt,
      if (reminderH2At != null) 'reminder_h2_at': reminderH2At,
      if (reminderH1At != null) 'reminder_h1_at': reminderH1At,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ControlVisitsCompanion copyWith({
    Value<String>? id,
    Value<String?>? familyId,
    Value<String>? memberId,
    Value<String>? hospital,
    Value<String?>? doctor,
    Value<int>? visitAt,
    Value<int?>? reminderH2At,
    Value<int?>? reminderH1At,
    Value<String>? status,
    Value<String?>? notes,
    Value<int>? updatedAt,
    Value<int?>? serverUpdatedAt,
    Value<int>? rowid,
  }) {
    return ControlVisitsCompanion(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      memberId: memberId ?? this.memberId,
      hospital: hospital ?? this.hospital,
      doctor: doctor ?? this.doctor,
      visitAt: visitAt ?? this.visitAt,
      reminderH2At: reminderH2At ?? this.reminderH2At,
      reminderH1At: reminderH1At ?? this.reminderH1At,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      updatedAt: updatedAt ?? this.updatedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (familyId.present) {
      map['family_id'] = Variable<String>(familyId.value);
    }
    if (memberId.present) {
      map['member_id'] = Variable<String>(memberId.value);
    }
    if (hospital.present) {
      map['hospital'] = Variable<String>(hospital.value);
    }
    if (doctor.present) {
      map['doctor'] = Variable<String>(doctor.value);
    }
    if (visitAt.present) {
      map['visit_at'] = Variable<int>(visitAt.value);
    }
    if (reminderH2At.present) {
      map['reminder_h2_at'] = Variable<int>(reminderH2At.value);
    }
    if (reminderH1At.present) {
      map['reminder_h1_at'] = Variable<int>(reminderH1At.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ControlVisitsCompanion(')
          ..write('id: $id, ')
          ..write('familyId: $familyId, ')
          ..write('memberId: $memberId, ')
          ..write('hospital: $hospital, ')
          ..write('doctor: $doctor, ')
          ..write('visitAt: $visitAt, ')
          ..write('reminderH2At: $reminderH2At, ')
          ..write('reminderH1At: $reminderH1At, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SideEffectsTable extends SideEffects
    with TableInfo<$SideEffectsTable, SideEffect> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SideEffectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _familyIdMeta = const VerificationMeta(
    'familyId',
  );
  @override
  late final GeneratedColumn<String> familyId = GeneratedColumn<String>(
    'family_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _memberIdMeta = const VerificationMeta(
    'memberId',
  );
  @override
  late final GeneratedColumn<String> memberId = GeneratedColumn<String>(
    'member_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _medicineIdMeta = const VerificationMeta(
    'medicineId',
  );
  @override
  late final GeneratedColumn<String> medicineId = GeneratedColumn<String>(
    'medicine_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<int> occurredAt = GeneratedColumn<int>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customKindMeta = const VerificationMeta(
    'customKind',
  );
  @override
  late final GeneratedColumn<String> customKind = GeneratedColumn<String>(
    'custom_kind',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _severityMeta = const VerificationMeta(
    'severity',
  );
  @override
  late final GeneratedColumn<String> severity = GeneratedColumn<String>(
    'severity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> serverUpdatedAt = GeneratedColumn<int>(
    'server_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    familyId,
    memberId,
    medicineId,
    occurredAt,
    kind,
    customKind,
    severity,
    note,
    updatedAt,
    serverUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'side_effects';
  @override
  VerificationContext validateIntegrity(
    Insertable<SideEffect> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('family_id')) {
      context.handle(
        _familyIdMeta,
        familyId.isAcceptableOrUnknown(data['family_id']!, _familyIdMeta),
      );
    }
    if (data.containsKey('member_id')) {
      context.handle(
        _memberIdMeta,
        memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta),
      );
    } else if (isInserting) {
      context.missing(_memberIdMeta);
    }
    if (data.containsKey('medicine_id')) {
      context.handle(
        _medicineIdMeta,
        medicineId.isAcceptableOrUnknown(data['medicine_id']!, _medicineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_medicineIdMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('custom_kind')) {
      context.handle(
        _customKindMeta,
        customKind.isAcceptableOrUnknown(data['custom_kind']!, _customKindMeta),
      );
    }
    if (data.containsKey('severity')) {
      context.handle(
        _severityMeta,
        severity.isAcceptableOrUnknown(data['severity']!, _severityMeta),
      );
    } else if (isInserting) {
      context.missing(_severityMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SideEffect map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SideEffect(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      familyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family_id'],
      ),
      memberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}member_id'],
      )!,
      medicineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medicine_id'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}occurred_at'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      customKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_kind'],
      ),
      severity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}severity'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_updated_at'],
      ),
    );
  }

  @override
  $SideEffectsTable createAlias(String alias) {
    return $SideEffectsTable(attachedDatabase, alias);
  }
}

class SideEffect extends DataClass implements Insertable<SideEffect> {
  final String id;
  final String? familyId;
  final String memberId;
  final String medicineId;
  final int occurredAt;
  final String kind;
  final String? customKind;
  final String severity;
  final String? note;
  final int updatedAt;
  final int? serverUpdatedAt;
  const SideEffect({
    required this.id,
    this.familyId,
    required this.memberId,
    required this.medicineId,
    required this.occurredAt,
    required this.kind,
    this.customKind,
    required this.severity,
    this.note,
    required this.updatedAt,
    this.serverUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || familyId != null) {
      map['family_id'] = Variable<String>(familyId);
    }
    map['member_id'] = Variable<String>(memberId);
    map['medicine_id'] = Variable<String>(medicineId);
    map['occurred_at'] = Variable<int>(occurredAt);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || customKind != null) {
      map['custom_kind'] = Variable<String>(customKind);
    }
    map['severity'] = Variable<String>(severity);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt);
    }
    return map;
  }

  SideEffectsCompanion toCompanion(bool nullToAbsent) {
    return SideEffectsCompanion(
      id: Value(id),
      familyId: familyId == null && nullToAbsent
          ? const Value.absent()
          : Value(familyId),
      memberId: Value(memberId),
      medicineId: Value(medicineId),
      occurredAt: Value(occurredAt),
      kind: Value(kind),
      customKind: customKind == null && nullToAbsent
          ? const Value.absent()
          : Value(customKind),
      severity: Value(severity),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      updatedAt: Value(updatedAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
    );
  }

  factory SideEffect.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SideEffect(
      id: serializer.fromJson<String>(json['id']),
      familyId: serializer.fromJson<String?>(json['familyId']),
      memberId: serializer.fromJson<String>(json['memberId']),
      medicineId: serializer.fromJson<String>(json['medicineId']),
      occurredAt: serializer.fromJson<int>(json['occurredAt']),
      kind: serializer.fromJson<String>(json['kind']),
      customKind: serializer.fromJson<String?>(json['customKind']),
      severity: serializer.fromJson<String>(json['severity']),
      note: serializer.fromJson<String?>(json['note']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      serverUpdatedAt: serializer.fromJson<int?>(json['serverUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'familyId': serializer.toJson<String?>(familyId),
      'memberId': serializer.toJson<String>(memberId),
      'medicineId': serializer.toJson<String>(medicineId),
      'occurredAt': serializer.toJson<int>(occurredAt),
      'kind': serializer.toJson<String>(kind),
      'customKind': serializer.toJson<String?>(customKind),
      'severity': serializer.toJson<String>(severity),
      'note': serializer.toJson<String?>(note),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'serverUpdatedAt': serializer.toJson<int?>(serverUpdatedAt),
    };
  }

  SideEffect copyWith({
    String? id,
    Value<String?> familyId = const Value.absent(),
    String? memberId,
    String? medicineId,
    int? occurredAt,
    String? kind,
    Value<String?> customKind = const Value.absent(),
    String? severity,
    Value<String?> note = const Value.absent(),
    int? updatedAt,
    Value<int?> serverUpdatedAt = const Value.absent(),
  }) => SideEffect(
    id: id ?? this.id,
    familyId: familyId.present ? familyId.value : this.familyId,
    memberId: memberId ?? this.memberId,
    medicineId: medicineId ?? this.medicineId,
    occurredAt: occurredAt ?? this.occurredAt,
    kind: kind ?? this.kind,
    customKind: customKind.present ? customKind.value : this.customKind,
    severity: severity ?? this.severity,
    note: note.present ? note.value : this.note,
    updatedAt: updatedAt ?? this.updatedAt,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
  );
  SideEffect copyWithCompanion(SideEffectsCompanion data) {
    return SideEffect(
      id: data.id.present ? data.id.value : this.id,
      familyId: data.familyId.present ? data.familyId.value : this.familyId,
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
      medicineId: data.medicineId.present
          ? data.medicineId.value
          : this.medicineId,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      kind: data.kind.present ? data.kind.value : this.kind,
      customKind: data.customKind.present
          ? data.customKind.value
          : this.customKind,
      severity: data.severity.present ? data.severity.value : this.severity,
      note: data.note.present ? data.note.value : this.note,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SideEffect(')
          ..write('id: $id, ')
          ..write('familyId: $familyId, ')
          ..write('memberId: $memberId, ')
          ..write('medicineId: $medicineId, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('kind: $kind, ')
          ..write('customKind: $customKind, ')
          ..write('severity: $severity, ')
          ..write('note: $note, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    familyId,
    memberId,
    medicineId,
    occurredAt,
    kind,
    customKind,
    severity,
    note,
    updatedAt,
    serverUpdatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SideEffect &&
          other.id == this.id &&
          other.familyId == this.familyId &&
          other.memberId == this.memberId &&
          other.medicineId == this.medicineId &&
          other.occurredAt == this.occurredAt &&
          other.kind == this.kind &&
          other.customKind == this.customKind &&
          other.severity == this.severity &&
          other.note == this.note &&
          other.updatedAt == this.updatedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt);
}

class SideEffectsCompanion extends UpdateCompanion<SideEffect> {
  final Value<String> id;
  final Value<String?> familyId;
  final Value<String> memberId;
  final Value<String> medicineId;
  final Value<int> occurredAt;
  final Value<String> kind;
  final Value<String?> customKind;
  final Value<String> severity;
  final Value<String?> note;
  final Value<int> updatedAt;
  final Value<int?> serverUpdatedAt;
  final Value<int> rowid;
  const SideEffectsCompanion({
    this.id = const Value.absent(),
    this.familyId = const Value.absent(),
    this.memberId = const Value.absent(),
    this.medicineId = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.kind = const Value.absent(),
    this.customKind = const Value.absent(),
    this.severity = const Value.absent(),
    this.note = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SideEffectsCompanion.insert({
    required String id,
    this.familyId = const Value.absent(),
    required String memberId,
    required String medicineId,
    required int occurredAt,
    required String kind,
    this.customKind = const Value.absent(),
    required String severity,
    this.note = const Value.absent(),
    required int updatedAt,
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       memberId = Value(memberId),
       medicineId = Value(medicineId),
       occurredAt = Value(occurredAt),
       kind = Value(kind),
       severity = Value(severity),
       updatedAt = Value(updatedAt);
  static Insertable<SideEffect> custom({
    Expression<String>? id,
    Expression<String>? familyId,
    Expression<String>? memberId,
    Expression<String>? medicineId,
    Expression<int>? occurredAt,
    Expression<String>? kind,
    Expression<String>? customKind,
    Expression<String>? severity,
    Expression<String>? note,
    Expression<int>? updatedAt,
    Expression<int>? serverUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (familyId != null) 'family_id': familyId,
      if (memberId != null) 'member_id': memberId,
      if (medicineId != null) 'medicine_id': medicineId,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (kind != null) 'kind': kind,
      if (customKind != null) 'custom_kind': customKind,
      if (severity != null) 'severity': severity,
      if (note != null) 'note': note,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SideEffectsCompanion copyWith({
    Value<String>? id,
    Value<String?>? familyId,
    Value<String>? memberId,
    Value<String>? medicineId,
    Value<int>? occurredAt,
    Value<String>? kind,
    Value<String?>? customKind,
    Value<String>? severity,
    Value<String?>? note,
    Value<int>? updatedAt,
    Value<int?>? serverUpdatedAt,
    Value<int>? rowid,
  }) {
    return SideEffectsCompanion(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      memberId: memberId ?? this.memberId,
      medicineId: medicineId ?? this.medicineId,
      occurredAt: occurredAt ?? this.occurredAt,
      kind: kind ?? this.kind,
      customKind: customKind ?? this.customKind,
      severity: severity ?? this.severity,
      note: note ?? this.note,
      updatedAt: updatedAt ?? this.updatedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (familyId.present) {
      map['family_id'] = Variable<String>(familyId.value);
    }
    if (memberId.present) {
      map['member_id'] = Variable<String>(memberId.value);
    }
    if (medicineId.present) {
      map['medicine_id'] = Variable<String>(medicineId.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<int>(occurredAt.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (customKind.present) {
      map['custom_kind'] = Variable<String>(customKind.value);
    }
    if (severity.present) {
      map['severity'] = Variable<String>(severity.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SideEffectsCompanion(')
          ..write('id: $id, ')
          ..write('familyId: $familyId, ')
          ..write('memberId: $memberId, ')
          ..write('medicineId: $medicineId, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('kind: $kind, ')
          ..write('customKind: $customKind, ')
          ..write('severity: $severity, ')
          ..write('note: $note, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _settingKeyMeta = const VerificationMeta(
    'settingKey',
  );
  @override
  late final GeneratedColumn<String> settingKey = GeneratedColumn<String>(
    'setting_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _settingValueMeta = const VerificationMeta(
    'settingValue',
  );
  @override
  late final GeneratedColumn<String> settingValue = GeneratedColumn<String>(
    'setting_value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, settingKey, settingValue];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('setting_key')) {
      context.handle(
        _settingKeyMeta,
        settingKey.isAcceptableOrUnknown(data['setting_key']!, _settingKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_settingKeyMeta);
    }
    if (data.containsKey('setting_value')) {
      context.handle(
        _settingValueMeta,
        settingValue.isAcceptableOrUnknown(
          data['setting_value']!,
          _settingValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_settingValueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      settingKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}setting_key'],
      )!,
      settingValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}setting_value'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final int id;
  final String settingKey;
  final String settingValue;
  const Setting({
    required this.id,
    required this.settingKey,
    required this.settingValue,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['setting_key'] = Variable<String>(settingKey);
    map['setting_value'] = Variable<String>(settingValue);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      id: Value(id),
      settingKey: Value(settingKey),
      settingValue: Value(settingValue),
    );
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      id: serializer.fromJson<int>(json['id']),
      settingKey: serializer.fromJson<String>(json['settingKey']),
      settingValue: serializer.fromJson<String>(json['settingValue']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'settingKey': serializer.toJson<String>(settingKey),
      'settingValue': serializer.toJson<String>(settingValue),
    };
  }

  Setting copyWith({int? id, String? settingKey, String? settingValue}) =>
      Setting(
        id: id ?? this.id,
        settingKey: settingKey ?? this.settingKey,
        settingValue: settingValue ?? this.settingValue,
      );
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      id: data.id.present ? data.id.value : this.id,
      settingKey: data.settingKey.present
          ? data.settingKey.value
          : this.settingKey,
      settingValue: data.settingValue.present
          ? data.settingValue.value
          : this.settingValue,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('id: $id, ')
          ..write('settingKey: $settingKey, ')
          ..write('settingValue: $settingValue')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, settingKey, settingValue);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting &&
          other.id == this.id &&
          other.settingKey == this.settingKey &&
          other.settingValue == this.settingValue);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<int> id;
  final Value<String> settingKey;
  final Value<String> settingValue;
  const SettingsCompanion({
    this.id = const Value.absent(),
    this.settingKey = const Value.absent(),
    this.settingValue = const Value.absent(),
  });
  SettingsCompanion.insert({
    this.id = const Value.absent(),
    required String settingKey,
    required String settingValue,
  }) : settingKey = Value(settingKey),
       settingValue = Value(settingValue);
  static Insertable<Setting> custom({
    Expression<int>? id,
    Expression<String>? settingKey,
    Expression<String>? settingValue,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (settingKey != null) 'setting_key': settingKey,
      if (settingValue != null) 'setting_value': settingValue,
    });
  }

  SettingsCompanion copyWith({
    Value<int>? id,
    Value<String>? settingKey,
    Value<String>? settingValue,
  }) {
    return SettingsCompanion(
      id: id ?? this.id,
      settingKey: settingKey ?? this.settingKey,
      settingValue: settingValue ?? this.settingValue,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (settingKey.present) {
      map['setting_key'] = Variable<String>(settingKey.value);
    }
    if (settingValue.present) {
      map['setting_value'] = Variable<String>(settingValue.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('id: $id, ')
          ..write('settingKey: $settingKey, ')
          ..write('settingValue: $settingValue')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FamilyGroupsTable familyGroups = $FamilyGroupsTable(this);
  late final $FamilyMemberAccessesTable familyMemberAccesses =
      $FamilyMemberAccessesTable(this);
  late final $DevicesTable devices = $DevicesTable(this);
  late final $DeviceMemberPrefsTable deviceMemberPrefs =
      $DeviceMemberPrefsTable(this);
  late final $MembersTable members = $MembersTable(this);
  late final $MedicinesTable medicines = $MedicinesTable(this);
  late final $StockLedgersTable stockLedgers = $StockLedgersTable(this);
  late final $SchedulesTable schedules = $SchedulesTable(this);
  late final $DoseLogsTable doseLogs = $DoseLogsTable(this);
  late final $ControlVisitsTable controlVisits = $ControlVisitsTable(this);
  late final $SideEffectsTable sideEffects = $SideEffectsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    familyGroups,
    familyMemberAccesses,
    devices,
    deviceMemberPrefs,
    members,
    medicines,
    stockLedgers,
    schedules,
    doseLogs,
    controlVisits,
    sideEffects,
    settings,
  ];
}

typedef $$FamilyGroupsTableCreateCompanionBuilder =
    FamilyGroupsCompanion Function({
      required String id,
      required String name,
      required String ownerEmail,
      required int createdAt,
      required int updatedAt,
      Value<int?> serverUpdatedAt,
      Value<int> rowid,
    });
typedef $$FamilyGroupsTableUpdateCompanionBuilder =
    FamilyGroupsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> ownerEmail,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> serverUpdatedAt,
      Value<int> rowid,
    });

class $$FamilyGroupsTableFilterComposer
    extends Composer<_$AppDatabase, $FamilyGroupsTable> {
  $$FamilyGroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerEmail => $composableBuilder(
    column: $table.ownerEmail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FamilyGroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $FamilyGroupsTable> {
  $$FamilyGroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerEmail => $composableBuilder(
    column: $table.ownerEmail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FamilyGroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FamilyGroupsTable> {
  $$FamilyGroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get ownerEmail => $composableBuilder(
    column: $table.ownerEmail,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );
}

class $$FamilyGroupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FamilyGroupsTable,
          FamilyGroup,
          $$FamilyGroupsTableFilterComposer,
          $$FamilyGroupsTableOrderingComposer,
          $$FamilyGroupsTableAnnotationComposer,
          $$FamilyGroupsTableCreateCompanionBuilder,
          $$FamilyGroupsTableUpdateCompanionBuilder,
          (
            FamilyGroup,
            BaseReferences<_$AppDatabase, $FamilyGroupsTable, FamilyGroup>,
          ),
          FamilyGroup,
          PrefetchHooks Function()
        > {
  $$FamilyGroupsTableTableManager(_$AppDatabase db, $FamilyGroupsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FamilyGroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FamilyGroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FamilyGroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> ownerEmail = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FamilyGroupsCompanion(
                id: id,
                name: name,
                ownerEmail: ownerEmail,
                createdAt: createdAt,
                updatedAt: updatedAt,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String ownerEmail,
                required int createdAt,
                required int updatedAt,
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FamilyGroupsCompanion.insert(
                id: id,
                name: name,
                ownerEmail: ownerEmail,
                createdAt: createdAt,
                updatedAt: updatedAt,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FamilyGroupsTable, FamilyGroup>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $FamilyGroupsTable,
                    FamilyGroup
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FamilyGroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FamilyGroupsTable,
      FamilyGroup,
      $$FamilyGroupsTableFilterComposer,
      $$FamilyGroupsTableOrderingComposer,
      $$FamilyGroupsTableAnnotationComposer,
      $$FamilyGroupsTableCreateCompanionBuilder,
      $$FamilyGroupsTableUpdateCompanionBuilder,
      (
        FamilyGroup,
        BaseReferences<_$AppDatabase, $FamilyGroupsTable, FamilyGroup>,
      ),
      FamilyGroup,
      PrefetchHooks Function()
    >;
typedef $$FamilyMemberAccessesTableCreateCompanionBuilder =
    FamilyMemberAccessesCompanion Function({
      required String id,
      Value<String?> familyId,
      required String email,
      Value<String> role,
      Value<String> status,
      Value<int?> joinedAt,
      required int updatedAt,
      Value<int?> serverUpdatedAt,
      Value<int> rowid,
    });
typedef $$FamilyMemberAccessesTableUpdateCompanionBuilder =
    FamilyMemberAccessesCompanion Function({
      Value<String> id,
      Value<String?> familyId,
      Value<String> email,
      Value<String> role,
      Value<String> status,
      Value<int?> joinedAt,
      Value<int> updatedAt,
      Value<int?> serverUpdatedAt,
      Value<int> rowid,
    });

class $$FamilyMemberAccessesTableFilterComposer
    extends Composer<_$AppDatabase, $FamilyMemberAccessesTable> {
  $$FamilyMemberAccessesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get familyId => $composableBuilder(
    column: $table.familyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get joinedAt => $composableBuilder(
    column: $table.joinedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FamilyMemberAccessesTableOrderingComposer
    extends Composer<_$AppDatabase, $FamilyMemberAccessesTable> {
  $$FamilyMemberAccessesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get familyId => $composableBuilder(
    column: $table.familyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get joinedAt => $composableBuilder(
    column: $table.joinedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FamilyMemberAccessesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FamilyMemberAccessesTable> {
  $$FamilyMemberAccessesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get familyId =>
      $composableBuilder(column: $table.familyId, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get joinedAt =>
      $composableBuilder(column: $table.joinedAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );
}

class $$FamilyMemberAccessesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FamilyMemberAccessesTable,
          FamilyMemberAccessesData,
          $$FamilyMemberAccessesTableFilterComposer,
          $$FamilyMemberAccessesTableOrderingComposer,
          $$FamilyMemberAccessesTableAnnotationComposer,
          $$FamilyMemberAccessesTableCreateCompanionBuilder,
          $$FamilyMemberAccessesTableUpdateCompanionBuilder,
          (
            FamilyMemberAccessesData,
            BaseReferences<
              _$AppDatabase,
              $FamilyMemberAccessesTable,
              FamilyMemberAccessesData
            >,
          ),
          FamilyMemberAccessesData,
          PrefetchHooks Function()
        > {
  $$FamilyMemberAccessesTableTableManager(
    _$AppDatabase db,
    $FamilyMemberAccessesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FamilyMemberAccessesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FamilyMemberAccessesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$FamilyMemberAccessesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> familyId = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> joinedAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FamilyMemberAccessesCompanion(
                id: id,
                familyId: familyId,
                email: email,
                role: role,
                status: status,
                joinedAt: joinedAt,
                updatedAt: updatedAt,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> familyId = const Value.absent(),
                required String email,
                Value<String> role = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> joinedAt = const Value.absent(),
                required int updatedAt,
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FamilyMemberAccessesCompanion.insert(
                id: id,
                familyId: familyId,
                email: email,
                role: role,
                status: status,
                joinedAt: joinedAt,
                updatedAt: updatedAt,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $FamilyMemberAccessesTable,
                    FamilyMemberAccessesData
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $FamilyMemberAccessesTable,
                    FamilyMemberAccessesData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FamilyMemberAccessesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FamilyMemberAccessesTable,
      FamilyMemberAccessesData,
      $$FamilyMemberAccessesTableFilterComposer,
      $$FamilyMemberAccessesTableOrderingComposer,
      $$FamilyMemberAccessesTableAnnotationComposer,
      $$FamilyMemberAccessesTableCreateCompanionBuilder,
      $$FamilyMemberAccessesTableUpdateCompanionBuilder,
      (
        FamilyMemberAccessesData,
        BaseReferences<
          _$AppDatabase,
          $FamilyMemberAccessesTable,
          FamilyMemberAccessesData
        >,
      ),
      FamilyMemberAccessesData,
      PrefetchHooks Function()
    >;
typedef $$DevicesTableCreateCompanionBuilder = DevicesCompanion Function({
  required String id,
  Value<String?> familyId,
  required String email,
  Value<String?> fcmToken,
  Value<String> platform,
  required int lastSeenAt,
  Value<int> rowid,
});
typedef $$DevicesTableUpdateCompanionBuilder = DevicesCompanion Function({
  Value<String> id,
  Value<String?> familyId,
  Value<String> email,
  Value<String?> fcmToken,
  Value<String> platform,
  Value<int> lastSeenAt,
  Value<int> rowid,
});

class $$DevicesTableFilterComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get familyId => $composableBuilder(
    column: $table.familyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fcmToken => $composableBuilder(
    column: $table.fcmToken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DevicesTableOrderingComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get familyId => $composableBuilder(
    column: $table.familyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fcmToken => $composableBuilder(
    column: $table.fcmToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DevicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get familyId =>
      $composableBuilder(column: $table.familyId, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get fcmToken =>
      $composableBuilder(column: $table.fcmToken, builder: (column) => column);

  GeneratedColumn<String> get platform =>
      $composableBuilder(column: $table.platform, builder: (column) => column);

  GeneratedColumn<int> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => column,
  );
}

class $$DevicesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DevicesTable,
          Device,
          $$DevicesTableFilterComposer,
          $$DevicesTableOrderingComposer,
          $$DevicesTableAnnotationComposer,
          $$DevicesTableCreateCompanionBuilder,
          $$DevicesTableUpdateCompanionBuilder,
          (Device, BaseReferences<_$AppDatabase, $DevicesTable, Device>),
          Device,
          PrefetchHooks Function()
        > {
  $$DevicesTableTableManager(_$AppDatabase db, $DevicesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DevicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DevicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DevicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> familyId = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String?> fcmToken = const Value.absent(),
                Value<String> platform = const Value.absent(),
                Value<int> lastSeenAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DevicesCompanion(
                id: id,
                familyId: familyId,
                email: email,
                fcmToken: fcmToken,
                platform: platform,
                lastSeenAt: lastSeenAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> familyId = const Value.absent(),
                required String email,
                Value<String?> fcmToken = const Value.absent(),
                Value<String> platform = const Value.absent(),
                required int lastSeenAt,
                Value<int> rowid = const Value.absent(),
              }) => DevicesCompanion.insert(
                id: id,
                familyId: familyId,
                email: email,
                fcmToken: fcmToken,
                platform: platform,
                lastSeenAt: lastSeenAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DevicesTable, Device>(table),
                  BaseReferences<_$AppDatabase, $DevicesTable, Device>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DevicesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DevicesTable,
      Device,
      $$DevicesTableFilterComposer,
      $$DevicesTableOrderingComposer,
      $$DevicesTableAnnotationComposer,
      $$DevicesTableCreateCompanionBuilder,
      $$DevicesTableUpdateCompanionBuilder,
      (Device, BaseReferences<_$AppDatabase, $DevicesTable, Device>),
      Device,
      PrefetchHooks Function()
    >;
typedef $$DeviceMemberPrefsTableCreateCompanionBuilder =
    DeviceMemberPrefsCompanion Function({
      required String memberId,
      Value<String> alarmMode,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$DeviceMemberPrefsTableUpdateCompanionBuilder =
    DeviceMemberPrefsCompanion Function({
      Value<String> memberId,
      Value<String> alarmMode,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$DeviceMemberPrefsTableFilterComposer
    extends Composer<_$AppDatabase, $DeviceMemberPrefsTable> {
  $$DeviceMemberPrefsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alarmMode => $composableBuilder(
    column: $table.alarmMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DeviceMemberPrefsTableOrderingComposer
    extends Composer<_$AppDatabase, $DeviceMemberPrefsTable> {
  $$DeviceMemberPrefsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alarmMode => $composableBuilder(
    column: $table.alarmMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DeviceMemberPrefsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DeviceMemberPrefsTable> {
  $$DeviceMemberPrefsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get memberId =>
      $composableBuilder(column: $table.memberId, builder: (column) => column);

  GeneratedColumn<String> get alarmMode =>
      $composableBuilder(column: $table.alarmMode, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DeviceMemberPrefsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DeviceMemberPrefsTable,
          DeviceMemberPref,
          $$DeviceMemberPrefsTableFilterComposer,
          $$DeviceMemberPrefsTableOrderingComposer,
          $$DeviceMemberPrefsTableAnnotationComposer,
          $$DeviceMemberPrefsTableCreateCompanionBuilder,
          $$DeviceMemberPrefsTableUpdateCompanionBuilder,
          (
            DeviceMemberPref,
            BaseReferences<
              _$AppDatabase,
              $DeviceMemberPrefsTable,
              DeviceMemberPref
            >,
          ),
          DeviceMemberPref,
          PrefetchHooks Function()
        > {
  $$DeviceMemberPrefsTableTableManager(
    _$AppDatabase db,
    $DeviceMemberPrefsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeviceMemberPrefsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeviceMemberPrefsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DeviceMemberPrefsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> memberId = const Value.absent(),
                Value<String> alarmMode = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DeviceMemberPrefsCompanion(
                memberId: memberId,
                alarmMode: alarmMode,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String memberId,
                Value<String> alarmMode = const Value.absent(),
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => DeviceMemberPrefsCompanion.insert(
                memberId: memberId,
                alarmMode: alarmMode,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DeviceMemberPrefsTable, DeviceMemberPref>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $DeviceMemberPrefsTable,
                    DeviceMemberPref
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DeviceMemberPrefsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DeviceMemberPrefsTable,
      DeviceMemberPref,
      $$DeviceMemberPrefsTableFilterComposer,
      $$DeviceMemberPrefsTableOrderingComposer,
      $$DeviceMemberPrefsTableAnnotationComposer,
      $$DeviceMemberPrefsTableCreateCompanionBuilder,
      $$DeviceMemberPrefsTableUpdateCompanionBuilder,
      (
        DeviceMemberPref,
        BaseReferences<
          _$AppDatabase,
          $DeviceMemberPrefsTable,
          DeviceMemberPref
        >,
      ),
      DeviceMemberPref,
      PrefetchHooks Function()
    >;
typedef $$MembersTableCreateCompanionBuilder = MembersCompanion Function({
  required String id,
  Value<String?> familyId,
  required String name,
  Value<String?> avatarPath,
  Value<String?> avatarThumbB64,
  Value<String?> notes,
  Value<bool> isArchived,
  Value<int?> deletedAt,
  required int createdAt,
  required int updatedAt,
  Value<int?> serverUpdatedAt,
  Value<int> rowid,
});
typedef $$MembersTableUpdateCompanionBuilder = MembersCompanion Function({
  Value<String> id,
  Value<String?> familyId,
  Value<String> name,
  Value<String?> avatarPath,
  Value<String?> avatarThumbB64,
  Value<String?> notes,
  Value<bool> isArchived,
  Value<int?> deletedAt,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> serverUpdatedAt,
  Value<int> rowid,
});

class $$MembersTableFilterComposer
    extends Composer<_$AppDatabase, $MembersTable> {
  $$MembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get familyId => $composableBuilder(
    column: $table.familyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarThumbB64 => $composableBuilder(
    column: $table.avatarThumbB64,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MembersTableOrderingComposer
    extends Composer<_$AppDatabase, $MembersTable> {
  $$MembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get familyId => $composableBuilder(
    column: $table.familyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarThumbB64 => $composableBuilder(
    column: $table.avatarThumbB64,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $MembersTable> {
  $$MembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get familyId =>
      $composableBuilder(column: $table.familyId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get avatarThumbB64 => $composableBuilder(
    column: $table.avatarThumbB64,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );
}

class $$MembersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MembersTable,
          Member,
          $$MembersTableFilterComposer,
          $$MembersTableOrderingComposer,
          $$MembersTableAnnotationComposer,
          $$MembersTableCreateCompanionBuilder,
          $$MembersTableUpdateCompanionBuilder,
          (Member, BaseReferences<_$AppDatabase, $MembersTable, Member>),
          Member,
          PrefetchHooks Function()
        > {
  $$MembersTableTableManager(_$AppDatabase db, $MembersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> familyId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> avatarPath = const Value.absent(),
                Value<String?> avatarThumbB64 = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MembersCompanion(
                id: id,
                familyId: familyId,
                name: name,
                avatarPath: avatarPath,
                avatarThumbB64: avatarThumbB64,
                notes: notes,
                isArchived: isArchived,
                deletedAt: deletedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> familyId = const Value.absent(),
                required String name,
                Value<String?> avatarPath = const Value.absent(),
                Value<String?> avatarThumbB64 = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MembersCompanion.insert(
                id: id,
                familyId: familyId,
                name: name,
                avatarPath: avatarPath,
                avatarThumbB64: avatarThumbB64,
                notes: notes,
                isArchived: isArchived,
                deletedAt: deletedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MembersTable, Member>(table),
                  BaseReferences<_$AppDatabase, $MembersTable, Member>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MembersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MembersTable,
      Member,
      $$MembersTableFilterComposer,
      $$MembersTableOrderingComposer,
      $$MembersTableAnnotationComposer,
      $$MembersTableCreateCompanionBuilder,
      $$MembersTableUpdateCompanionBuilder,
      (Member, BaseReferences<_$AppDatabase, $MembersTable, Member>),
      Member,
      PrefetchHooks Function()
    >;
typedef $$MedicinesTableCreateCompanionBuilder = MedicinesCompanion Function({
  required String id,
  Value<String?> familyId,
  required String memberId,
  required String name,
  required String dosage,
  Value<double> doseQty,
  required String unit,
  Value<String> mealRelation,
  Value<String?> photoPath,
  Value<String?> photoThumbB64,
  Value<double> stockQty,
  Value<double> lowStockThreshold,
  Value<String?> notes,
  Value<bool> isArchived,
  Value<int?> deletedAt,
  required int createdAt,
  required int updatedAt,
  Value<int?> serverUpdatedAt,
  Value<int> rowid,
});
typedef $$MedicinesTableUpdateCompanionBuilder = MedicinesCompanion Function({
  Value<String> id,
  Value<String?> familyId,
  Value<String> memberId,
  Value<String> name,
  Value<String> dosage,
  Value<double> doseQty,
  Value<String> unit,
  Value<String> mealRelation,
  Value<String?> photoPath,
  Value<String?> photoThumbB64,
  Value<double> stockQty,
  Value<double> lowStockThreshold,
  Value<String?> notes,
  Value<bool> isArchived,
  Value<int?> deletedAt,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> serverUpdatedAt,
  Value<int> rowid,
});

class $$MedicinesTableFilterComposer
    extends Composer<_$AppDatabase, $MedicinesTable> {
  $$MedicinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get familyId => $composableBuilder(
    column: $table.familyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dosage => $composableBuilder(
    column: $table.dosage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get doseQty => $composableBuilder(
    column: $table.doseQty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mealRelation => $composableBuilder(
    column: $table.mealRelation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoThumbB64 => $composableBuilder(
    column: $table.photoThumbB64,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stockQty => $composableBuilder(
    column: $table.stockQty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lowStockThreshold => $composableBuilder(
    column: $table.lowStockThreshold,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MedicinesTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicinesTable> {
  $$MedicinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get familyId => $composableBuilder(
    column: $table.familyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dosage => $composableBuilder(
    column: $table.dosage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get doseQty => $composableBuilder(
    column: $table.doseQty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mealRelation => $composableBuilder(
    column: $table.mealRelation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoThumbB64 => $composableBuilder(
    column: $table.photoThumbB64,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stockQty => $composableBuilder(
    column: $table.stockQty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lowStockThreshold => $composableBuilder(
    column: $table.lowStockThreshold,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MedicinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicinesTable> {
  $$MedicinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get familyId =>
      $composableBuilder(column: $table.familyId, builder: (column) => column);

  GeneratedColumn<String> get memberId =>
      $composableBuilder(column: $table.memberId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get dosage =>
      $composableBuilder(column: $table.dosage, builder: (column) => column);

  GeneratedColumn<double> get doseQty =>
      $composableBuilder(column: $table.doseQty, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get mealRelation => $composableBuilder(
    column: $table.mealRelation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<String> get photoThumbB64 => $composableBuilder(
    column: $table.photoThumbB64,
    builder: (column) => column,
  );

  GeneratedColumn<double> get stockQty =>
      $composableBuilder(column: $table.stockQty, builder: (column) => column);

  GeneratedColumn<double> get lowStockThreshold => $composableBuilder(
    column: $table.lowStockThreshold,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );
}

class $$MedicinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MedicinesTable,
          Medicine,
          $$MedicinesTableFilterComposer,
          $$MedicinesTableOrderingComposer,
          $$MedicinesTableAnnotationComposer,
          $$MedicinesTableCreateCompanionBuilder,
          $$MedicinesTableUpdateCompanionBuilder,
          (Medicine, BaseReferences<_$AppDatabase, $MedicinesTable, Medicine>),
          Medicine,
          PrefetchHooks Function()
        > {
  $$MedicinesTableTableManager(_$AppDatabase db, $MedicinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> familyId = const Value.absent(),
                Value<String> memberId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> dosage = const Value.absent(),
                Value<double> doseQty = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<String> mealRelation = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<String?> photoThumbB64 = const Value.absent(),
                Value<double> stockQty = const Value.absent(),
                Value<double> lowStockThreshold = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MedicinesCompanion(
                id: id,
                familyId: familyId,
                memberId: memberId,
                name: name,
                dosage: dosage,
                doseQty: doseQty,
                unit: unit,
                mealRelation: mealRelation,
                photoPath: photoPath,
                photoThumbB64: photoThumbB64,
                stockQty: stockQty,
                lowStockThreshold: lowStockThreshold,
                notes: notes,
                isArchived: isArchived,
                deletedAt: deletedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> familyId = const Value.absent(),
                required String memberId,
                required String name,
                required String dosage,
                Value<double> doseQty = const Value.absent(),
                required String unit,
                Value<String> mealRelation = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<String?> photoThumbB64 = const Value.absent(),
                Value<double> stockQty = const Value.absent(),
                Value<double> lowStockThreshold = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MedicinesCompanion.insert(
                id: id,
                familyId: familyId,
                memberId: memberId,
                name: name,
                dosage: dosage,
                doseQty: doseQty,
                unit: unit,
                mealRelation: mealRelation,
                photoPath: photoPath,
                photoThumbB64: photoThumbB64,
                stockQty: stockQty,
                lowStockThreshold: lowStockThreshold,
                notes: notes,
                isArchived: isArchived,
                deletedAt: deletedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MedicinesTable, Medicine>(table),
                  BaseReferences<_$AppDatabase, $MedicinesTable, Medicine>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MedicinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MedicinesTable,
      Medicine,
      $$MedicinesTableFilterComposer,
      $$MedicinesTableOrderingComposer,
      $$MedicinesTableAnnotationComposer,
      $$MedicinesTableCreateCompanionBuilder,
      $$MedicinesTableUpdateCompanionBuilder,
      (Medicine, BaseReferences<_$AppDatabase, $MedicinesTable, Medicine>),
      Medicine,
      PrefetchHooks Function()
    >;
typedef $$StockLedgersTableCreateCompanionBuilder =
    StockLedgersCompanion Function({
      required String id,
      Value<String?> familyId,
      required String medicineId,
      Value<String?> doseLogId,
      required double delta,
      required double balanceAfter,
      required String reason,
      required int createdAt,
      Value<int?> serverUpdatedAt,
      Value<int> rowid,
    });
typedef $$StockLedgersTableUpdateCompanionBuilder =
    StockLedgersCompanion Function({
      Value<String> id,
      Value<String?> familyId,
      Value<String> medicineId,
      Value<String?> doseLogId,
      Value<double> delta,
      Value<double> balanceAfter,
      Value<String> reason,
      Value<int> createdAt,
      Value<int?> serverUpdatedAt,
      Value<int> rowid,
    });

class $$StockLedgersTableFilterComposer
    extends Composer<_$AppDatabase, $StockLedgersTable> {
  $$StockLedgersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get familyId => $composableBuilder(
    column: $table.familyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get medicineId => $composableBuilder(
    column: $table.medicineId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get doseLogId => $composableBuilder(
    column: $table.doseLogId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get delta => $composableBuilder(
    column: $table.delta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get balanceAfter => $composableBuilder(
    column: $table.balanceAfter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StockLedgersTableOrderingComposer
    extends Composer<_$AppDatabase, $StockLedgersTable> {
  $$StockLedgersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get familyId => $composableBuilder(
    column: $table.familyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get medicineId => $composableBuilder(
    column: $table.medicineId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get doseLogId => $composableBuilder(
    column: $table.doseLogId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get delta => $composableBuilder(
    column: $table.delta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get balanceAfter => $composableBuilder(
    column: $table.balanceAfter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StockLedgersTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockLedgersTable> {
  $$StockLedgersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get familyId =>
      $composableBuilder(column: $table.familyId, builder: (column) => column);

  GeneratedColumn<String> get medicineId => $composableBuilder(
    column: $table.medicineId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get doseLogId =>
      $composableBuilder(column: $table.doseLogId, builder: (column) => column);

  GeneratedColumn<double> get delta =>
      $composableBuilder(column: $table.delta, builder: (column) => column);

  GeneratedColumn<double> get balanceAfter => $composableBuilder(
    column: $table.balanceAfter,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );
}

class $$StockLedgersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StockLedgersTable,
          StockLedger,
          $$StockLedgersTableFilterComposer,
          $$StockLedgersTableOrderingComposer,
          $$StockLedgersTableAnnotationComposer,
          $$StockLedgersTableCreateCompanionBuilder,
          $$StockLedgersTableUpdateCompanionBuilder,
          (
            StockLedger,
            BaseReferences<_$AppDatabase, $StockLedgersTable, StockLedger>,
          ),
          StockLedger,
          PrefetchHooks Function()
        > {
  $$StockLedgersTableTableManager(_$AppDatabase db, $StockLedgersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockLedgersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockLedgersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockLedgersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> familyId = const Value.absent(),
                Value<String> medicineId = const Value.absent(),
                Value<String?> doseLogId = const Value.absent(),
                Value<double> delta = const Value.absent(),
                Value<double> balanceAfter = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StockLedgersCompanion(
                id: id,
                familyId: familyId,
                medicineId: medicineId,
                doseLogId: doseLogId,
                delta: delta,
                balanceAfter: balanceAfter,
                reason: reason,
                createdAt: createdAt,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> familyId = const Value.absent(),
                required String medicineId,
                Value<String?> doseLogId = const Value.absent(),
                required double delta,
                required double balanceAfter,
                required String reason,
                required int createdAt,
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StockLedgersCompanion.insert(
                id: id,
                familyId: familyId,
                medicineId: medicineId,
                doseLogId: doseLogId,
                delta: delta,
                balanceAfter: balanceAfter,
                reason: reason,
                createdAt: createdAt,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StockLedgersTable, StockLedger>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $StockLedgersTable,
                    StockLedger
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StockLedgersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StockLedgersTable,
      StockLedger,
      $$StockLedgersTableFilterComposer,
      $$StockLedgersTableOrderingComposer,
      $$StockLedgersTableAnnotationComposer,
      $$StockLedgersTableCreateCompanionBuilder,
      $$StockLedgersTableUpdateCompanionBuilder,
      (
        StockLedger,
        BaseReferences<_$AppDatabase, $StockLedgersTable, StockLedger>,
      ),
      StockLedger,
      PrefetchHooks Function()
    >;
typedef $$SchedulesTableCreateCompanionBuilder = SchedulesCompanion Function({
  required String id,
  Value<String?> familyId,
  required String memberId,
  required String medicineId,
  required String recurrenceType,
  required String timesJson,
  Value<int?> intervalHours,
  Value<String?> daysOfWeek,
  Value<double?> doseQty,
  Value<String?> mealRelation,
  Value<bool> ttsEnabled,
  required int startDate,
  Value<int?> endDate,
  Value<bool> isActive,
  required int createdAt,
  required int updatedAt,
  Value<int?> serverUpdatedAt,
  Value<int> rowid,
});
typedef $$SchedulesTableUpdateCompanionBuilder = SchedulesCompanion Function({
  Value<String> id,
  Value<String?> familyId,
  Value<String> memberId,
  Value<String> medicineId,
  Value<String> recurrenceType,
  Value<String> timesJson,
  Value<int?> intervalHours,
  Value<String?> daysOfWeek,
  Value<double?> doseQty,
  Value<String?> mealRelation,
  Value<bool> ttsEnabled,
  Value<int> startDate,
  Value<int?> endDate,
  Value<bool> isActive,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> serverUpdatedAt,
  Value<int> rowid,
});

class $$SchedulesTableFilterComposer
    extends Composer<_$AppDatabase, $SchedulesTable> {
  $$SchedulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get familyId => $composableBuilder(
    column: $table.familyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get medicineId => $composableBuilder(
    column: $table.medicineId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurrenceType => $composableBuilder(
    column: $table.recurrenceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timesJson => $composableBuilder(
    column: $table.timesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intervalHours => $composableBuilder(
    column: $table.intervalHours,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get daysOfWeek => $composableBuilder(
    column: $table.daysOfWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get doseQty => $composableBuilder(
    column: $table.doseQty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mealRelation => $composableBuilder(
    column: $table.mealRelation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get ttsEnabled => $composableBuilder(
    column: $table.ttsEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SchedulesTableOrderingComposer
    extends Composer<_$AppDatabase, $SchedulesTable> {
  $$SchedulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get familyId => $composableBuilder(
    column: $table.familyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get medicineId => $composableBuilder(
    column: $table.medicineId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrenceType => $composableBuilder(
    column: $table.recurrenceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timesJson => $composableBuilder(
    column: $table.timesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalHours => $composableBuilder(
    column: $table.intervalHours,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get daysOfWeek => $composableBuilder(
    column: $table.daysOfWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get doseQty => $composableBuilder(
    column: $table.doseQty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mealRelation => $composableBuilder(
    column: $table.mealRelation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get ttsEnabled => $composableBuilder(
    column: $table.ttsEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SchedulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SchedulesTable> {
  $$SchedulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get familyId =>
      $composableBuilder(column: $table.familyId, builder: (column) => column);

  GeneratedColumn<String> get memberId =>
      $composableBuilder(column: $table.memberId, builder: (column) => column);

  GeneratedColumn<String> get medicineId => $composableBuilder(
    column: $table.medicineId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recurrenceType => $composableBuilder(
    column: $table.recurrenceType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get timesJson =>
      $composableBuilder(column: $table.timesJson, builder: (column) => column);

  GeneratedColumn<int> get intervalHours => $composableBuilder(
    column: $table.intervalHours,
    builder: (column) => column,
  );

  GeneratedColumn<String> get daysOfWeek => $composableBuilder(
    column: $table.daysOfWeek,
    builder: (column) => column,
  );

  GeneratedColumn<double> get doseQty =>
      $composableBuilder(column: $table.doseQty, builder: (column) => column);

  GeneratedColumn<String> get mealRelation => $composableBuilder(
    column: $table.mealRelation,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get ttsEnabled => $composableBuilder(
    column: $table.ttsEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<int> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );
}

class $$SchedulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SchedulesTable,
          Schedule,
          $$SchedulesTableFilterComposer,
          $$SchedulesTableOrderingComposer,
          $$SchedulesTableAnnotationComposer,
          $$SchedulesTableCreateCompanionBuilder,
          $$SchedulesTableUpdateCompanionBuilder,
          (Schedule, BaseReferences<_$AppDatabase, $SchedulesTable, Schedule>),
          Schedule,
          PrefetchHooks Function()
        > {
  $$SchedulesTableTableManager(_$AppDatabase db, $SchedulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SchedulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SchedulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SchedulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> familyId = const Value.absent(),
                Value<String> memberId = const Value.absent(),
                Value<String> medicineId = const Value.absent(),
                Value<String> recurrenceType = const Value.absent(),
                Value<String> timesJson = const Value.absent(),
                Value<int?> intervalHours = const Value.absent(),
                Value<String?> daysOfWeek = const Value.absent(),
                Value<double?> doseQty = const Value.absent(),
                Value<String?> mealRelation = const Value.absent(),
                Value<bool> ttsEnabled = const Value.absent(),
                Value<int> startDate = const Value.absent(),
                Value<int?> endDate = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SchedulesCompanion(
                id: id,
                familyId: familyId,
                memberId: memberId,
                medicineId: medicineId,
                recurrenceType: recurrenceType,
                timesJson: timesJson,
                intervalHours: intervalHours,
                daysOfWeek: daysOfWeek,
                doseQty: doseQty,
                mealRelation: mealRelation,
                ttsEnabled: ttsEnabled,
                startDate: startDate,
                endDate: endDate,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> familyId = const Value.absent(),
                required String memberId,
                required String medicineId,
                required String recurrenceType,
                required String timesJson,
                Value<int?> intervalHours = const Value.absent(),
                Value<String?> daysOfWeek = const Value.absent(),
                Value<double?> doseQty = const Value.absent(),
                Value<String?> mealRelation = const Value.absent(),
                Value<bool> ttsEnabled = const Value.absent(),
                required int startDate,
                Value<int?> endDate = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SchedulesCompanion.insert(
                id: id,
                familyId: familyId,
                memberId: memberId,
                medicineId: medicineId,
                recurrenceType: recurrenceType,
                timesJson: timesJson,
                intervalHours: intervalHours,
                daysOfWeek: daysOfWeek,
                doseQty: doseQty,
                mealRelation: mealRelation,
                ttsEnabled: ttsEnabled,
                startDate: startDate,
                endDate: endDate,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SchedulesTable, Schedule>(table),
                  BaseReferences<_$AppDatabase, $SchedulesTable, Schedule>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SchedulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SchedulesTable,
      Schedule,
      $$SchedulesTableFilterComposer,
      $$SchedulesTableOrderingComposer,
      $$SchedulesTableAnnotationComposer,
      $$SchedulesTableCreateCompanionBuilder,
      $$SchedulesTableUpdateCompanionBuilder,
      (Schedule, BaseReferences<_$AppDatabase, $SchedulesTable, Schedule>),
      Schedule,
      PrefetchHooks Function()
    >;
typedef $$DoseLogsTableCreateCompanionBuilder = DoseLogsCompanion Function({
  required String id,
  Value<String?> familyId,
  Value<String?> scheduleId,
  required String memberId,
  required String medicineId,
  required int scheduledAt,
  required int effectiveScheduledAt,
  Value<int> snoozeCount,
  required String status,
  Value<bool> stockApplied,
  Value<String?> actionByEmail,
  Value<int?> actionAt,
  Value<String?> note,
  required int updatedAt,
  Value<int?> serverUpdatedAt,
  Value<int> rowid,
});
typedef $$DoseLogsTableUpdateCompanionBuilder = DoseLogsCompanion Function({
  Value<String> id,
  Value<String?> familyId,
  Value<String?> scheduleId,
  Value<String> memberId,
  Value<String> medicineId,
  Value<int> scheduledAt,
  Value<int> effectiveScheduledAt,
  Value<int> snoozeCount,
  Value<String> status,
  Value<bool> stockApplied,
  Value<String?> actionByEmail,
  Value<int?> actionAt,
  Value<String?> note,
  Value<int> updatedAt,
  Value<int?> serverUpdatedAt,
  Value<int> rowid,
});

class $$DoseLogsTableFilterComposer
    extends Composer<_$AppDatabase, $DoseLogsTable> {
  $$DoseLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get familyId => $composableBuilder(
    column: $table.familyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scheduleId => $composableBuilder(
    column: $table.scheduleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get medicineId => $composableBuilder(
    column: $table.medicineId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get effectiveScheduledAt => $composableBuilder(
    column: $table.effectiveScheduledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get snoozeCount => $composableBuilder(
    column: $table.snoozeCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get stockApplied => $composableBuilder(
    column: $table.stockApplied,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actionByEmail => $composableBuilder(
    column: $table.actionByEmail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actionAt => $composableBuilder(
    column: $table.actionAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DoseLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $DoseLogsTable> {
  $$DoseLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get familyId => $composableBuilder(
    column: $table.familyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scheduleId => $composableBuilder(
    column: $table.scheduleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get medicineId => $composableBuilder(
    column: $table.medicineId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get effectiveScheduledAt => $composableBuilder(
    column: $table.effectiveScheduledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get snoozeCount => $composableBuilder(
    column: $table.snoozeCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get stockApplied => $composableBuilder(
    column: $table.stockApplied,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actionByEmail => $composableBuilder(
    column: $table.actionByEmail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actionAt => $composableBuilder(
    column: $table.actionAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DoseLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DoseLogsTable> {
  $$DoseLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get familyId =>
      $composableBuilder(column: $table.familyId, builder: (column) => column);

  GeneratedColumn<String> get scheduleId => $composableBuilder(
    column: $table.scheduleId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get memberId =>
      $composableBuilder(column: $table.memberId, builder: (column) => column);

  GeneratedColumn<String> get medicineId => $composableBuilder(
    column: $table.medicineId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get effectiveScheduledAt => $composableBuilder(
    column: $table.effectiveScheduledAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get snoozeCount => $composableBuilder(
    column: $table.snoozeCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get stockApplied => $composableBuilder(
    column: $table.stockApplied,
    builder: (column) => column,
  );

  GeneratedColumn<String> get actionByEmail => $composableBuilder(
    column: $table.actionByEmail,
    builder: (column) => column,
  );

  GeneratedColumn<int> get actionAt =>
      $composableBuilder(column: $table.actionAt, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );
}

class $$DoseLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DoseLogsTable,
          DoseLog,
          $$DoseLogsTableFilterComposer,
          $$DoseLogsTableOrderingComposer,
          $$DoseLogsTableAnnotationComposer,
          $$DoseLogsTableCreateCompanionBuilder,
          $$DoseLogsTableUpdateCompanionBuilder,
          (DoseLog, BaseReferences<_$AppDatabase, $DoseLogsTable, DoseLog>),
          DoseLog,
          PrefetchHooks Function()
        > {
  $$DoseLogsTableTableManager(_$AppDatabase db, $DoseLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DoseLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DoseLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DoseLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> familyId = const Value.absent(),
                Value<String?> scheduleId = const Value.absent(),
                Value<String> memberId = const Value.absent(),
                Value<String> medicineId = const Value.absent(),
                Value<int> scheduledAt = const Value.absent(),
                Value<int> effectiveScheduledAt = const Value.absent(),
                Value<int> snoozeCount = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<bool> stockApplied = const Value.absent(),
                Value<String?> actionByEmail = const Value.absent(),
                Value<int?> actionAt = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DoseLogsCompanion(
                id: id,
                familyId: familyId,
                scheduleId: scheduleId,
                memberId: memberId,
                medicineId: medicineId,
                scheduledAt: scheduledAt,
                effectiveScheduledAt: effectiveScheduledAt,
                snoozeCount: snoozeCount,
                status: status,
                stockApplied: stockApplied,
                actionByEmail: actionByEmail,
                actionAt: actionAt,
                note: note,
                updatedAt: updatedAt,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> familyId = const Value.absent(),
                Value<String?> scheduleId = const Value.absent(),
                required String memberId,
                required String medicineId,
                required int scheduledAt,
                required int effectiveScheduledAt,
                Value<int> snoozeCount = const Value.absent(),
                required String status,
                Value<bool> stockApplied = const Value.absent(),
                Value<String?> actionByEmail = const Value.absent(),
                Value<int?> actionAt = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required int updatedAt,
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DoseLogsCompanion.insert(
                id: id,
                familyId: familyId,
                scheduleId: scheduleId,
                memberId: memberId,
                medicineId: medicineId,
                scheduledAt: scheduledAt,
                effectiveScheduledAt: effectiveScheduledAt,
                snoozeCount: snoozeCount,
                status: status,
                stockApplied: stockApplied,
                actionByEmail: actionByEmail,
                actionAt: actionAt,
                note: note,
                updatedAt: updatedAt,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DoseLogsTable, DoseLog>(table),
                  BaseReferences<_$AppDatabase, $DoseLogsTable, DoseLog>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DoseLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DoseLogsTable,
      DoseLog,
      $$DoseLogsTableFilterComposer,
      $$DoseLogsTableOrderingComposer,
      $$DoseLogsTableAnnotationComposer,
      $$DoseLogsTableCreateCompanionBuilder,
      $$DoseLogsTableUpdateCompanionBuilder,
      (DoseLog, BaseReferences<_$AppDatabase, $DoseLogsTable, DoseLog>),
      DoseLog,
      PrefetchHooks Function()
    >;
typedef $$ControlVisitsTableCreateCompanionBuilder =
    ControlVisitsCompanion Function({
      required String id,
      Value<String?> familyId,
      required String memberId,
      required String hospital,
      Value<String?> doctor,
      required int visitAt,
      Value<int?> reminderH2At,
      Value<int?> reminderH1At,
      Value<String> status,
      Value<String?> notes,
      required int updatedAt,
      Value<int?> serverUpdatedAt,
      Value<int> rowid,
    });
typedef $$ControlVisitsTableUpdateCompanionBuilder =
    ControlVisitsCompanion Function({
      Value<String> id,
      Value<String?> familyId,
      Value<String> memberId,
      Value<String> hospital,
      Value<String?> doctor,
      Value<int> visitAt,
      Value<int?> reminderH2At,
      Value<int?> reminderH1At,
      Value<String> status,
      Value<String?> notes,
      Value<int> updatedAt,
      Value<int?> serverUpdatedAt,
      Value<int> rowid,
    });

class $$ControlVisitsTableFilterComposer
    extends Composer<_$AppDatabase, $ControlVisitsTable> {
  $$ControlVisitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get familyId => $composableBuilder(
    column: $table.familyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hospital => $composableBuilder(
    column: $table.hospital,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get doctor => $composableBuilder(
    column: $table.doctor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get visitAt => $composableBuilder(
    column: $table.visitAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderH2At => $composableBuilder(
    column: $table.reminderH2At,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderH1At => $composableBuilder(
    column: $table.reminderH1At,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ControlVisitsTableOrderingComposer
    extends Composer<_$AppDatabase, $ControlVisitsTable> {
  $$ControlVisitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get familyId => $composableBuilder(
    column: $table.familyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hospital => $composableBuilder(
    column: $table.hospital,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get doctor => $composableBuilder(
    column: $table.doctor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get visitAt => $composableBuilder(
    column: $table.visitAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderH2At => $composableBuilder(
    column: $table.reminderH2At,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderH1At => $composableBuilder(
    column: $table.reminderH1At,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ControlVisitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ControlVisitsTable> {
  $$ControlVisitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get familyId =>
      $composableBuilder(column: $table.familyId, builder: (column) => column);

  GeneratedColumn<String> get memberId =>
      $composableBuilder(column: $table.memberId, builder: (column) => column);

  GeneratedColumn<String> get hospital =>
      $composableBuilder(column: $table.hospital, builder: (column) => column);

  GeneratedColumn<String> get doctor =>
      $composableBuilder(column: $table.doctor, builder: (column) => column);

  GeneratedColumn<int> get visitAt =>
      $composableBuilder(column: $table.visitAt, builder: (column) => column);

  GeneratedColumn<int> get reminderH2At => $composableBuilder(
    column: $table.reminderH2At,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reminderH1At => $composableBuilder(
    column: $table.reminderH1At,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );
}

class $$ControlVisitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ControlVisitsTable,
          ControlVisit,
          $$ControlVisitsTableFilterComposer,
          $$ControlVisitsTableOrderingComposer,
          $$ControlVisitsTableAnnotationComposer,
          $$ControlVisitsTableCreateCompanionBuilder,
          $$ControlVisitsTableUpdateCompanionBuilder,
          (
            ControlVisit,
            BaseReferences<_$AppDatabase, $ControlVisitsTable, ControlVisit>,
          ),
          ControlVisit,
          PrefetchHooks Function()
        > {
  $$ControlVisitsTableTableManager(_$AppDatabase db, $ControlVisitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ControlVisitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ControlVisitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ControlVisitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> familyId = const Value.absent(),
                Value<String> memberId = const Value.absent(),
                Value<String> hospital = const Value.absent(),
                Value<String?> doctor = const Value.absent(),
                Value<int> visitAt = const Value.absent(),
                Value<int?> reminderH2At = const Value.absent(),
                Value<int?> reminderH1At = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ControlVisitsCompanion(
                id: id,
                familyId: familyId,
                memberId: memberId,
                hospital: hospital,
                doctor: doctor,
                visitAt: visitAt,
                reminderH2At: reminderH2At,
                reminderH1At: reminderH1At,
                status: status,
                notes: notes,
                updatedAt: updatedAt,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> familyId = const Value.absent(),
                required String memberId,
                required String hospital,
                Value<String?> doctor = const Value.absent(),
                required int visitAt,
                Value<int?> reminderH2At = const Value.absent(),
                Value<int?> reminderH1At = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required int updatedAt,
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ControlVisitsCompanion.insert(
                id: id,
                familyId: familyId,
                memberId: memberId,
                hospital: hospital,
                doctor: doctor,
                visitAt: visitAt,
                reminderH2At: reminderH2At,
                reminderH1At: reminderH1At,
                status: status,
                notes: notes,
                updatedAt: updatedAt,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ControlVisitsTable, ControlVisit>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ControlVisitsTable,
                    ControlVisit
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ControlVisitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ControlVisitsTable,
      ControlVisit,
      $$ControlVisitsTableFilterComposer,
      $$ControlVisitsTableOrderingComposer,
      $$ControlVisitsTableAnnotationComposer,
      $$ControlVisitsTableCreateCompanionBuilder,
      $$ControlVisitsTableUpdateCompanionBuilder,
      (
        ControlVisit,
        BaseReferences<_$AppDatabase, $ControlVisitsTable, ControlVisit>,
      ),
      ControlVisit,
      PrefetchHooks Function()
    >;
typedef $$SideEffectsTableCreateCompanionBuilder =
    SideEffectsCompanion Function({
      required String id,
      Value<String?> familyId,
      required String memberId,
      required String medicineId,
      required int occurredAt,
      required String kind,
      Value<String?> customKind,
      required String severity,
      Value<String?> note,
      required int updatedAt,
      Value<int?> serverUpdatedAt,
      Value<int> rowid,
    });
typedef $$SideEffectsTableUpdateCompanionBuilder =
    SideEffectsCompanion Function({
      Value<String> id,
      Value<String?> familyId,
      Value<String> memberId,
      Value<String> medicineId,
      Value<int> occurredAt,
      Value<String> kind,
      Value<String?> customKind,
      Value<String> severity,
      Value<String?> note,
      Value<int> updatedAt,
      Value<int?> serverUpdatedAt,
      Value<int> rowid,
    });

class $$SideEffectsTableFilterComposer
    extends Composer<_$AppDatabase, $SideEffectsTable> {
  $$SideEffectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get familyId => $composableBuilder(
    column: $table.familyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get medicineId => $composableBuilder(
    column: $table.medicineId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customKind => $composableBuilder(
    column: $table.customKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SideEffectsTableOrderingComposer
    extends Composer<_$AppDatabase, $SideEffectsTable> {
  $$SideEffectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get familyId => $composableBuilder(
    column: $table.familyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get medicineId => $composableBuilder(
    column: $table.medicineId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customKind => $composableBuilder(
    column: $table.customKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SideEffectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SideEffectsTable> {
  $$SideEffectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get familyId =>
      $composableBuilder(column: $table.familyId, builder: (column) => column);

  GeneratedColumn<String> get memberId =>
      $composableBuilder(column: $table.memberId, builder: (column) => column);

  GeneratedColumn<String> get medicineId => $composableBuilder(
    column: $table.medicineId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get customKind => $composableBuilder(
    column: $table.customKind,
    builder: (column) => column,
  );

  GeneratedColumn<String> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );
}

class $$SideEffectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SideEffectsTable,
          SideEffect,
          $$SideEffectsTableFilterComposer,
          $$SideEffectsTableOrderingComposer,
          $$SideEffectsTableAnnotationComposer,
          $$SideEffectsTableCreateCompanionBuilder,
          $$SideEffectsTableUpdateCompanionBuilder,
          (
            SideEffect,
            BaseReferences<_$AppDatabase, $SideEffectsTable, SideEffect>,
          ),
          SideEffect,
          PrefetchHooks Function()
        > {
  $$SideEffectsTableTableManager(_$AppDatabase db, $SideEffectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SideEffectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SideEffectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SideEffectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> familyId = const Value.absent(),
                Value<String> memberId = const Value.absent(),
                Value<String> medicineId = const Value.absent(),
                Value<int> occurredAt = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String?> customKind = const Value.absent(),
                Value<String> severity = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SideEffectsCompanion(
                id: id,
                familyId: familyId,
                memberId: memberId,
                medicineId: medicineId,
                occurredAt: occurredAt,
                kind: kind,
                customKind: customKind,
                severity: severity,
                note: note,
                updatedAt: updatedAt,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> familyId = const Value.absent(),
                required String memberId,
                required String medicineId,
                required int occurredAt,
                required String kind,
                Value<String?> customKind = const Value.absent(),
                required String severity,
                Value<String?> note = const Value.absent(),
                required int updatedAt,
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SideEffectsCompanion.insert(
                id: id,
                familyId: familyId,
                memberId: memberId,
                medicineId: medicineId,
                occurredAt: occurredAt,
                kind: kind,
                customKind: customKind,
                severity: severity,
                note: note,
                updatedAt: updatedAt,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SideEffectsTable, SideEffect>(table),
                  BaseReferences<_$AppDatabase, $SideEffectsTable, SideEffect>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SideEffectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SideEffectsTable,
      SideEffect,
      $$SideEffectsTableFilterComposer,
      $$SideEffectsTableOrderingComposer,
      $$SideEffectsTableAnnotationComposer,
      $$SideEffectsTableCreateCompanionBuilder,
      $$SideEffectsTableUpdateCompanionBuilder,
      (
        SideEffect,
        BaseReferences<_$AppDatabase, $SideEffectsTable, SideEffect>,
      ),
      SideEffect,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  Value<int> id,
  required String settingKey,
  required String settingValue,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<int> id,
  Value<String> settingKey,
  Value<String> settingValue,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get settingKey => $composableBuilder(
    column: $table.settingKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get settingValue => $composableBuilder(
    column: $table.settingValue,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get settingKey => $composableBuilder(
    column: $table.settingKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get settingValue => $composableBuilder(
    column: $table.settingValue,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get settingKey => $composableBuilder(
    column: $table.settingKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get settingValue => $composableBuilder(
    column: $table.settingValue,
    builder: (column) => column,
  );
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> settingKey = const Value.absent(),
                Value<String> settingValue = const Value.absent(),
              }) => SettingsCompanion(
                id: id,
                settingKey: settingKey,
                settingValue: settingValue,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String settingKey,
                required String settingValue,
              }) => SettingsCompanion.insert(
                id: id,
                settingKey: settingKey,
                settingValue: settingValue,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTable, Setting>(table),
                  BaseReferences<_$AppDatabase, $SettingsTable, Setting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FamilyGroupsTableTableManager get familyGroups =>
      $$FamilyGroupsTableTableManager(_db, _db.familyGroups);
  $$FamilyMemberAccessesTableTableManager get familyMemberAccesses =>
      $$FamilyMemberAccessesTableTableManager(_db, _db.familyMemberAccesses);
  $$DevicesTableTableManager get devices =>
      $$DevicesTableTableManager(_db, _db.devices);
  $$DeviceMemberPrefsTableTableManager get deviceMemberPrefs =>
      $$DeviceMemberPrefsTableTableManager(_db, _db.deviceMemberPrefs);
  $$MembersTableTableManager get members =>
      $$MembersTableTableManager(_db, _db.members);
  $$MedicinesTableTableManager get medicines =>
      $$MedicinesTableTableManager(_db, _db.medicines);
  $$StockLedgersTableTableManager get stockLedgers =>
      $$StockLedgersTableTableManager(_db, _db.stockLedgers);
  $$SchedulesTableTableManager get schedules =>
      $$SchedulesTableTableManager(_db, _db.schedules);
  $$DoseLogsTableTableManager get doseLogs =>
      $$DoseLogsTableTableManager(_db, _db.doseLogs);
  $$ControlVisitsTableTableManager get controlVisits =>
      $$ControlVisitsTableTableManager(_db, _db.controlVisits);
  $$SideEffectsTableTableManager get sideEffects =>
      $$SideEffectsTableTableManager(_db, _db.sideEffects);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
