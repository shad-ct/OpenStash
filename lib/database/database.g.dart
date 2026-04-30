// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $UserHabitsTable extends UserHabits
    with TableInfo<$UserHabitsTable, UserHabit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserHabitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _articlesCompletedMeta = const VerificationMeta(
    'articlesCompleted',
  );
  @override
  late final GeneratedColumn<int> articlesCompleted = GeneratedColumn<int>(
    'articles_completed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [date, articlesCompleted];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_habits';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserHabit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('articles_completed')) {
      context.handle(
        _articlesCompletedMeta,
        articlesCompleted.isAcceptableOrUnknown(
          data['articles_completed']!,
          _articlesCompletedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date};
  @override
  UserHabit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserHabit(
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      articlesCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}articles_completed'],
      )!,
    );
  }

  @override
  $UserHabitsTable createAlias(String alias) {
    return $UserHabitsTable(attachedDatabase, alias);
  }
}

class UserHabit extends DataClass implements Insertable<UserHabit> {
  final DateTime date;
  final int articlesCompleted;
  const UserHabit({required this.date, required this.articlesCompleted});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date'] = Variable<DateTime>(date);
    map['articles_completed'] = Variable<int>(articlesCompleted);
    return map;
  }

  UserHabitsCompanion toCompanion(bool nullToAbsent) {
    return UserHabitsCompanion(
      date: Value(date),
      articlesCompleted: Value(articlesCompleted),
    );
  }

  factory UserHabit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserHabit(
      date: serializer.fromJson<DateTime>(json['date']),
      articlesCompleted: serializer.fromJson<int>(json['articlesCompleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<DateTime>(date),
      'articlesCompleted': serializer.toJson<int>(articlesCompleted),
    };
  }

  UserHabit copyWith({DateTime? date, int? articlesCompleted}) => UserHabit(
    date: date ?? this.date,
    articlesCompleted: articlesCompleted ?? this.articlesCompleted,
  );
  UserHabit copyWithCompanion(UserHabitsCompanion data) {
    return UserHabit(
      date: data.date.present ? data.date.value : this.date,
      articlesCompleted: data.articlesCompleted.present
          ? data.articlesCompleted.value
          : this.articlesCompleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserHabit(')
          ..write('date: $date, ')
          ..write('articlesCompleted: $articlesCompleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(date, articlesCompleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserHabit &&
          other.date == this.date &&
          other.articlesCompleted == this.articlesCompleted);
}

class UserHabitsCompanion extends UpdateCompanion<UserHabit> {
  final Value<DateTime> date;
  final Value<int> articlesCompleted;
  final Value<int> rowid;
  const UserHabitsCompanion({
    this.date = const Value.absent(),
    this.articlesCompleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserHabitsCompanion.insert({
    required DateTime date,
    this.articlesCompleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : date = Value(date);
  static Insertable<UserHabit> custom({
    Expression<DateTime>? date,
    Expression<int>? articlesCompleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (articlesCompleted != null) 'articles_completed': articlesCompleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserHabitsCompanion copyWith({
    Value<DateTime>? date,
    Value<int>? articlesCompleted,
    Value<int>? rowid,
  }) {
    return UserHabitsCompanion(
      date: date ?? this.date,
      articlesCompleted: articlesCompleted ?? this.articlesCompleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (articlesCompleted.present) {
      map['articles_completed'] = Variable<int>(articlesCompleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserHabitsCompanion(')
          ..write('date: $date, ')
          ..write('articlesCompleted: $articlesCompleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FoldersTable extends Folders with TableInfo<$FoldersTable, Folder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoldersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, isDefault, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'folders';
  @override
  VerificationContext validateIntegrity(
    Insertable<Folder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Folder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Folder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $FoldersTable createAlias(String alias) {
    return $FoldersTable(attachedDatabase, alias);
  }
}

class Folder extends DataClass implements Insertable<Folder> {
  final int id;
  final String name;
  final bool isDefault;
  final DateTime createdAt;
  const Folder({
    required this.id,
    required this.name,
    required this.isDefault,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['is_default'] = Variable<bool>(isDefault);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FoldersCompanion toCompanion(bool nullToAbsent) {
    return FoldersCompanion(
      id: Value(id),
      name: Value(name),
      isDefault: Value(isDefault),
      createdAt: Value(createdAt),
    );
  }

  factory Folder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Folder(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'isDefault': serializer.toJson<bool>(isDefault),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Folder copyWith({
    int? id,
    String? name,
    bool? isDefault,
    DateTime? createdAt,
  }) => Folder(
    id: id ?? this.id,
    name: name ?? this.name,
    isDefault: isDefault ?? this.isDefault,
    createdAt: createdAt ?? this.createdAt,
  );
  Folder copyWithCompanion(FoldersCompanion data) {
    return Folder(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Folder(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isDefault: $isDefault, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, isDefault, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Folder &&
          other.id == this.id &&
          other.name == this.name &&
          other.isDefault == this.isDefault &&
          other.createdAt == this.createdAt);
}

class FoldersCompanion extends UpdateCompanion<Folder> {
  final Value<int> id;
  final Value<String> name;
  final Value<bool> isDefault;
  final Value<DateTime> createdAt;
  const FoldersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  FoldersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.isDefault = const Value.absent(),
    required DateTime createdAt,
  }) : name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<Folder> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<bool>? isDefault,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (isDefault != null) 'is_default': isDefault,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  FoldersCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<bool>? isDefault,
    Value<DateTime>? createdAt,
  }) {
    return FoldersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoldersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isDefault: $isDefault, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SavedIdeasTable extends SavedIdeas
    with TableInfo<$SavedIdeasTable, SavedIdea> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedIdeasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ideaIdMeta = const VerificationMeta('ideaId');
  @override
  late final GeneratedColumn<String> ideaId = GeneratedColumn<String>(
    'idea_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _articleIdMeta = const VerificationMeta(
    'articleId',
  );
  @override
  late final GeneratedColumn<String> articleId = GeneratedColumn<String>(
    'article_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _articleTitleMeta = const VerificationMeta(
    'articleTitle',
  );
  @override
  late final GeneratedColumn<String> articleTitle = GeneratedColumn<String>(
    'article_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _articleUrlMeta = const VerificationMeta(
    'articleUrl',
  );
  @override
  late final GeneratedColumn<String> articleUrl = GeneratedColumn<String>(
    'article_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _textContentMeta = const VerificationMeta(
    'textContent',
  );
  @override
  late final GeneratedColumn<String> textContent = GeneratedColumn<String>(
    'text_content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _folderIdMeta = const VerificationMeta(
    'folderId',
  );
  @override
  late final GeneratedColumn<int> folderId = GeneratedColumn<int>(
    'folder_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES folders (id)',
    ),
  );
  static const VerificationMeta _savedAtMeta = const VerificationMeta(
    'savedAt',
  );
  @override
  late final GeneratedColumn<DateTime> savedAt = GeneratedColumn<DateTime>(
    'saved_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ideaId,
    articleId,
    articleTitle,
    articleUrl,
    textContent,
    imageUrl,
    folderId,
    savedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_ideas';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavedIdea> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('idea_id')) {
      context.handle(
        _ideaIdMeta,
        ideaId.isAcceptableOrUnknown(data['idea_id']!, _ideaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ideaIdMeta);
    }
    if (data.containsKey('article_id')) {
      context.handle(
        _articleIdMeta,
        articleId.isAcceptableOrUnknown(data['article_id']!, _articleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_articleIdMeta);
    }
    if (data.containsKey('article_title')) {
      context.handle(
        _articleTitleMeta,
        articleTitle.isAcceptableOrUnknown(
          data['article_title']!,
          _articleTitleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_articleTitleMeta);
    }
    if (data.containsKey('article_url')) {
      context.handle(
        _articleUrlMeta,
        articleUrl.isAcceptableOrUnknown(data['article_url']!, _articleUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_articleUrlMeta);
    }
    if (data.containsKey('text_content')) {
      context.handle(
        _textContentMeta,
        textContent.isAcceptableOrUnknown(
          data['text_content']!,
          _textContentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_textContentMeta);
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('folder_id')) {
      context.handle(
        _folderIdMeta,
        folderId.isAcceptableOrUnknown(data['folder_id']!, _folderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_folderIdMeta);
    }
    if (data.containsKey('saved_at')) {
      context.handle(
        _savedAtMeta,
        savedAt.isAcceptableOrUnknown(data['saved_at']!, _savedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_savedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavedIdea map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedIdea(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ideaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idea_id'],
      )!,
      articleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}article_id'],
      )!,
      articleTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}article_title'],
      )!,
      articleUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}article_url'],
      )!,
      textContent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_content'],
      )!,
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      folderId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}folder_id'],
      )!,
      savedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}saved_at'],
      )!,
    );
  }

  @override
  $SavedIdeasTable createAlias(String alias) {
    return $SavedIdeasTable(attachedDatabase, alias);
  }
}

class SavedIdea extends DataClass implements Insertable<SavedIdea> {
  final String id;
  final String ideaId;
  final String articleId;
  final String articleTitle;
  final String articleUrl;
  final String textContent;
  final String? imageUrl;
  final int folderId;
  final DateTime savedAt;
  const SavedIdea({
    required this.id,
    required this.ideaId,
    required this.articleId,
    required this.articleTitle,
    required this.articleUrl,
    required this.textContent,
    this.imageUrl,
    required this.folderId,
    required this.savedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['idea_id'] = Variable<String>(ideaId);
    map['article_id'] = Variable<String>(articleId);
    map['article_title'] = Variable<String>(articleTitle);
    map['article_url'] = Variable<String>(articleUrl);
    map['text_content'] = Variable<String>(textContent);
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    map['folder_id'] = Variable<int>(folderId);
    map['saved_at'] = Variable<DateTime>(savedAt);
    return map;
  }

  SavedIdeasCompanion toCompanion(bool nullToAbsent) {
    return SavedIdeasCompanion(
      id: Value(id),
      ideaId: Value(ideaId),
      articleId: Value(articleId),
      articleTitle: Value(articleTitle),
      articleUrl: Value(articleUrl),
      textContent: Value(textContent),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      folderId: Value(folderId),
      savedAt: Value(savedAt),
    );
  }

  factory SavedIdea.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedIdea(
      id: serializer.fromJson<String>(json['id']),
      ideaId: serializer.fromJson<String>(json['ideaId']),
      articleId: serializer.fromJson<String>(json['articleId']),
      articleTitle: serializer.fromJson<String>(json['articleTitle']),
      articleUrl: serializer.fromJson<String>(json['articleUrl']),
      textContent: serializer.fromJson<String>(json['textContent']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      folderId: serializer.fromJson<int>(json['folderId']),
      savedAt: serializer.fromJson<DateTime>(json['savedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ideaId': serializer.toJson<String>(ideaId),
      'articleId': serializer.toJson<String>(articleId),
      'articleTitle': serializer.toJson<String>(articleTitle),
      'articleUrl': serializer.toJson<String>(articleUrl),
      'textContent': serializer.toJson<String>(textContent),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'folderId': serializer.toJson<int>(folderId),
      'savedAt': serializer.toJson<DateTime>(savedAt),
    };
  }

  SavedIdea copyWith({
    String? id,
    String? ideaId,
    String? articleId,
    String? articleTitle,
    String? articleUrl,
    String? textContent,
    Value<String?> imageUrl = const Value.absent(),
    int? folderId,
    DateTime? savedAt,
  }) => SavedIdea(
    id: id ?? this.id,
    ideaId: ideaId ?? this.ideaId,
    articleId: articleId ?? this.articleId,
    articleTitle: articleTitle ?? this.articleTitle,
    articleUrl: articleUrl ?? this.articleUrl,
    textContent: textContent ?? this.textContent,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    folderId: folderId ?? this.folderId,
    savedAt: savedAt ?? this.savedAt,
  );
  SavedIdea copyWithCompanion(SavedIdeasCompanion data) {
    return SavedIdea(
      id: data.id.present ? data.id.value : this.id,
      ideaId: data.ideaId.present ? data.ideaId.value : this.ideaId,
      articleId: data.articleId.present ? data.articleId.value : this.articleId,
      articleTitle: data.articleTitle.present
          ? data.articleTitle.value
          : this.articleTitle,
      articleUrl: data.articleUrl.present
          ? data.articleUrl.value
          : this.articleUrl,
      textContent: data.textContent.present
          ? data.textContent.value
          : this.textContent,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      folderId: data.folderId.present ? data.folderId.value : this.folderId,
      savedAt: data.savedAt.present ? data.savedAt.value : this.savedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedIdea(')
          ..write('id: $id, ')
          ..write('ideaId: $ideaId, ')
          ..write('articleId: $articleId, ')
          ..write('articleTitle: $articleTitle, ')
          ..write('articleUrl: $articleUrl, ')
          ..write('textContent: $textContent, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('folderId: $folderId, ')
          ..write('savedAt: $savedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ideaId,
    articleId,
    articleTitle,
    articleUrl,
    textContent,
    imageUrl,
    folderId,
    savedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedIdea &&
          other.id == this.id &&
          other.ideaId == this.ideaId &&
          other.articleId == this.articleId &&
          other.articleTitle == this.articleTitle &&
          other.articleUrl == this.articleUrl &&
          other.textContent == this.textContent &&
          other.imageUrl == this.imageUrl &&
          other.folderId == this.folderId &&
          other.savedAt == this.savedAt);
}

class SavedIdeasCompanion extends UpdateCompanion<SavedIdea> {
  final Value<String> id;
  final Value<String> ideaId;
  final Value<String> articleId;
  final Value<String> articleTitle;
  final Value<String> articleUrl;
  final Value<String> textContent;
  final Value<String?> imageUrl;
  final Value<int> folderId;
  final Value<DateTime> savedAt;
  final Value<int> rowid;
  const SavedIdeasCompanion({
    this.id = const Value.absent(),
    this.ideaId = const Value.absent(),
    this.articleId = const Value.absent(),
    this.articleTitle = const Value.absent(),
    this.articleUrl = const Value.absent(),
    this.textContent = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.folderId = const Value.absent(),
    this.savedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavedIdeasCompanion.insert({
    required String id,
    required String ideaId,
    required String articleId,
    required String articleTitle,
    required String articleUrl,
    required String textContent,
    this.imageUrl = const Value.absent(),
    required int folderId,
    required DateTime savedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ideaId = Value(ideaId),
       articleId = Value(articleId),
       articleTitle = Value(articleTitle),
       articleUrl = Value(articleUrl),
       textContent = Value(textContent),
       folderId = Value(folderId),
       savedAt = Value(savedAt);
  static Insertable<SavedIdea> custom({
    Expression<String>? id,
    Expression<String>? ideaId,
    Expression<String>? articleId,
    Expression<String>? articleTitle,
    Expression<String>? articleUrl,
    Expression<String>? textContent,
    Expression<String>? imageUrl,
    Expression<int>? folderId,
    Expression<DateTime>? savedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ideaId != null) 'idea_id': ideaId,
      if (articleId != null) 'article_id': articleId,
      if (articleTitle != null) 'article_title': articleTitle,
      if (articleUrl != null) 'article_url': articleUrl,
      if (textContent != null) 'text_content': textContent,
      if (imageUrl != null) 'image_url': imageUrl,
      if (folderId != null) 'folder_id': folderId,
      if (savedAt != null) 'saved_at': savedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavedIdeasCompanion copyWith({
    Value<String>? id,
    Value<String>? ideaId,
    Value<String>? articleId,
    Value<String>? articleTitle,
    Value<String>? articleUrl,
    Value<String>? textContent,
    Value<String?>? imageUrl,
    Value<int>? folderId,
    Value<DateTime>? savedAt,
    Value<int>? rowid,
  }) {
    return SavedIdeasCompanion(
      id: id ?? this.id,
      ideaId: ideaId ?? this.ideaId,
      articleId: articleId ?? this.articleId,
      articleTitle: articleTitle ?? this.articleTitle,
      articleUrl: articleUrl ?? this.articleUrl,
      textContent: textContent ?? this.textContent,
      imageUrl: imageUrl ?? this.imageUrl,
      folderId: folderId ?? this.folderId,
      savedAt: savedAt ?? this.savedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ideaId.present) {
      map['idea_id'] = Variable<String>(ideaId.value);
    }
    if (articleId.present) {
      map['article_id'] = Variable<String>(articleId.value);
    }
    if (articleTitle.present) {
      map['article_title'] = Variable<String>(articleTitle.value);
    }
    if (articleUrl.present) {
      map['article_url'] = Variable<String>(articleUrl.value);
    }
    if (textContent.present) {
      map['text_content'] = Variable<String>(textContent.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (folderId.present) {
      map['folder_id'] = Variable<int>(folderId.value);
    }
    if (savedAt.present) {
      map['saved_at'] = Variable<DateTime>(savedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedIdeasCompanion(')
          ..write('id: $id, ')
          ..write('ideaId: $ideaId, ')
          ..write('articleId: $articleId, ')
          ..write('articleTitle: $articleTitle, ')
          ..write('articleUrl: $articleUrl, ')
          ..write('textContent: $textContent, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('folderId: $folderId, ')
          ..write('savedAt: $savedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LikedIdeasTable extends LikedIdeas
    with TableInfo<$LikedIdeasTable, LikedIdea> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LikedIdeasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ideaIdMeta = const VerificationMeta('ideaId');
  @override
  late final GeneratedColumn<String> ideaId = GeneratedColumn<String>(
    'idea_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _articleIdMeta = const VerificationMeta(
    'articleId',
  );
  @override
  late final GeneratedColumn<String> articleId = GeneratedColumn<String>(
    'article_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _articleTitleMeta = const VerificationMeta(
    'articleTitle',
  );
  @override
  late final GeneratedColumn<String> articleTitle = GeneratedColumn<String>(
    'article_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _articleUrlMeta = const VerificationMeta(
    'articleUrl',
  );
  @override
  late final GeneratedColumn<String> articleUrl = GeneratedColumn<String>(
    'article_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _textContentMeta = const VerificationMeta(
    'textContent',
  );
  @override
  late final GeneratedColumn<String> textContent = GeneratedColumn<String>(
    'text_content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _likedAtMeta = const VerificationMeta(
    'likedAt',
  );
  @override
  late final GeneratedColumn<DateTime> likedAt = GeneratedColumn<DateTime>(
    'liked_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ideaId,
    articleId,
    articleTitle,
    articleUrl,
    textContent,
    imageUrl,
    likedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'liked_ideas';
  @override
  VerificationContext validateIntegrity(
    Insertable<LikedIdea> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('idea_id')) {
      context.handle(
        _ideaIdMeta,
        ideaId.isAcceptableOrUnknown(data['idea_id']!, _ideaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ideaIdMeta);
    }
    if (data.containsKey('article_id')) {
      context.handle(
        _articleIdMeta,
        articleId.isAcceptableOrUnknown(data['article_id']!, _articleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_articleIdMeta);
    }
    if (data.containsKey('article_title')) {
      context.handle(
        _articleTitleMeta,
        articleTitle.isAcceptableOrUnknown(
          data['article_title']!,
          _articleTitleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_articleTitleMeta);
    }
    if (data.containsKey('article_url')) {
      context.handle(
        _articleUrlMeta,
        articleUrl.isAcceptableOrUnknown(data['article_url']!, _articleUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_articleUrlMeta);
    }
    if (data.containsKey('text_content')) {
      context.handle(
        _textContentMeta,
        textContent.isAcceptableOrUnknown(
          data['text_content']!,
          _textContentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_textContentMeta);
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('liked_at')) {
      context.handle(
        _likedAtMeta,
        likedAt.isAcceptableOrUnknown(data['liked_at']!, _likedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_likedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LikedIdea map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LikedIdea(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ideaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idea_id'],
      )!,
      articleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}article_id'],
      )!,
      articleTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}article_title'],
      )!,
      articleUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}article_url'],
      )!,
      textContent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_content'],
      )!,
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      likedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}liked_at'],
      )!,
    );
  }

  @override
  $LikedIdeasTable createAlias(String alias) {
    return $LikedIdeasTable(attachedDatabase, alias);
  }
}

class LikedIdea extends DataClass implements Insertable<LikedIdea> {
  final String id;
  final String ideaId;
  final String articleId;
  final String articleTitle;
  final String articleUrl;
  final String textContent;
  final String? imageUrl;
  final DateTime likedAt;
  const LikedIdea({
    required this.id,
    required this.ideaId,
    required this.articleId,
    required this.articleTitle,
    required this.articleUrl,
    required this.textContent,
    this.imageUrl,
    required this.likedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['idea_id'] = Variable<String>(ideaId);
    map['article_id'] = Variable<String>(articleId);
    map['article_title'] = Variable<String>(articleTitle);
    map['article_url'] = Variable<String>(articleUrl);
    map['text_content'] = Variable<String>(textContent);
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    map['liked_at'] = Variable<DateTime>(likedAt);
    return map;
  }

  LikedIdeasCompanion toCompanion(bool nullToAbsent) {
    return LikedIdeasCompanion(
      id: Value(id),
      ideaId: Value(ideaId),
      articleId: Value(articleId),
      articleTitle: Value(articleTitle),
      articleUrl: Value(articleUrl),
      textContent: Value(textContent),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      likedAt: Value(likedAt),
    );
  }

  factory LikedIdea.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LikedIdea(
      id: serializer.fromJson<String>(json['id']),
      ideaId: serializer.fromJson<String>(json['ideaId']),
      articleId: serializer.fromJson<String>(json['articleId']),
      articleTitle: serializer.fromJson<String>(json['articleTitle']),
      articleUrl: serializer.fromJson<String>(json['articleUrl']),
      textContent: serializer.fromJson<String>(json['textContent']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      likedAt: serializer.fromJson<DateTime>(json['likedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ideaId': serializer.toJson<String>(ideaId),
      'articleId': serializer.toJson<String>(articleId),
      'articleTitle': serializer.toJson<String>(articleTitle),
      'articleUrl': serializer.toJson<String>(articleUrl),
      'textContent': serializer.toJson<String>(textContent),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'likedAt': serializer.toJson<DateTime>(likedAt),
    };
  }

  LikedIdea copyWith({
    String? id,
    String? ideaId,
    String? articleId,
    String? articleTitle,
    String? articleUrl,
    String? textContent,
    Value<String?> imageUrl = const Value.absent(),
    DateTime? likedAt,
  }) => LikedIdea(
    id: id ?? this.id,
    ideaId: ideaId ?? this.ideaId,
    articleId: articleId ?? this.articleId,
    articleTitle: articleTitle ?? this.articleTitle,
    articleUrl: articleUrl ?? this.articleUrl,
    textContent: textContent ?? this.textContent,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    likedAt: likedAt ?? this.likedAt,
  );
  LikedIdea copyWithCompanion(LikedIdeasCompanion data) {
    return LikedIdea(
      id: data.id.present ? data.id.value : this.id,
      ideaId: data.ideaId.present ? data.ideaId.value : this.ideaId,
      articleId: data.articleId.present ? data.articleId.value : this.articleId,
      articleTitle: data.articleTitle.present
          ? data.articleTitle.value
          : this.articleTitle,
      articleUrl: data.articleUrl.present
          ? data.articleUrl.value
          : this.articleUrl,
      textContent: data.textContent.present
          ? data.textContent.value
          : this.textContent,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      likedAt: data.likedAt.present ? data.likedAt.value : this.likedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LikedIdea(')
          ..write('id: $id, ')
          ..write('ideaId: $ideaId, ')
          ..write('articleId: $articleId, ')
          ..write('articleTitle: $articleTitle, ')
          ..write('articleUrl: $articleUrl, ')
          ..write('textContent: $textContent, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('likedAt: $likedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ideaId,
    articleId,
    articleTitle,
    articleUrl,
    textContent,
    imageUrl,
    likedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LikedIdea &&
          other.id == this.id &&
          other.ideaId == this.ideaId &&
          other.articleId == this.articleId &&
          other.articleTitle == this.articleTitle &&
          other.articleUrl == this.articleUrl &&
          other.textContent == this.textContent &&
          other.imageUrl == this.imageUrl &&
          other.likedAt == this.likedAt);
}

class LikedIdeasCompanion extends UpdateCompanion<LikedIdea> {
  final Value<String> id;
  final Value<String> ideaId;
  final Value<String> articleId;
  final Value<String> articleTitle;
  final Value<String> articleUrl;
  final Value<String> textContent;
  final Value<String?> imageUrl;
  final Value<DateTime> likedAt;
  final Value<int> rowid;
  const LikedIdeasCompanion({
    this.id = const Value.absent(),
    this.ideaId = const Value.absent(),
    this.articleId = const Value.absent(),
    this.articleTitle = const Value.absent(),
    this.articleUrl = const Value.absent(),
    this.textContent = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.likedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LikedIdeasCompanion.insert({
    required String id,
    required String ideaId,
    required String articleId,
    required String articleTitle,
    required String articleUrl,
    required String textContent,
    this.imageUrl = const Value.absent(),
    required DateTime likedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ideaId = Value(ideaId),
       articleId = Value(articleId),
       articleTitle = Value(articleTitle),
       articleUrl = Value(articleUrl),
       textContent = Value(textContent),
       likedAt = Value(likedAt);
  static Insertable<LikedIdea> custom({
    Expression<String>? id,
    Expression<String>? ideaId,
    Expression<String>? articleId,
    Expression<String>? articleTitle,
    Expression<String>? articleUrl,
    Expression<String>? textContent,
    Expression<String>? imageUrl,
    Expression<DateTime>? likedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ideaId != null) 'idea_id': ideaId,
      if (articleId != null) 'article_id': articleId,
      if (articleTitle != null) 'article_title': articleTitle,
      if (articleUrl != null) 'article_url': articleUrl,
      if (textContent != null) 'text_content': textContent,
      if (imageUrl != null) 'image_url': imageUrl,
      if (likedAt != null) 'liked_at': likedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LikedIdeasCompanion copyWith({
    Value<String>? id,
    Value<String>? ideaId,
    Value<String>? articleId,
    Value<String>? articleTitle,
    Value<String>? articleUrl,
    Value<String>? textContent,
    Value<String?>? imageUrl,
    Value<DateTime>? likedAt,
    Value<int>? rowid,
  }) {
    return LikedIdeasCompanion(
      id: id ?? this.id,
      ideaId: ideaId ?? this.ideaId,
      articleId: articleId ?? this.articleId,
      articleTitle: articleTitle ?? this.articleTitle,
      articleUrl: articleUrl ?? this.articleUrl,
      textContent: textContent ?? this.textContent,
      imageUrl: imageUrl ?? this.imageUrl,
      likedAt: likedAt ?? this.likedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ideaId.present) {
      map['idea_id'] = Variable<String>(ideaId.value);
    }
    if (articleId.present) {
      map['article_id'] = Variable<String>(articleId.value);
    }
    if (articleTitle.present) {
      map['article_title'] = Variable<String>(articleTitle.value);
    }
    if (articleUrl.present) {
      map['article_url'] = Variable<String>(articleUrl.value);
    }
    if (textContent.present) {
      map['text_content'] = Variable<String>(textContent.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (likedAt.present) {
      map['liked_at'] = Variable<DateTime>(likedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LikedIdeasCompanion(')
          ..write('id: $id, ')
          ..write('ideaId: $ideaId, ')
          ..write('articleId: $articleId, ')
          ..write('articleTitle: $articleTitle, ')
          ..write('articleUrl: $articleUrl, ')
          ..write('textContent: $textContent, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('likedAt: $likedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UserHabitsTable userHabits = $UserHabitsTable(this);
  late final $FoldersTable folders = $FoldersTable(this);
  late final $SavedIdeasTable savedIdeas = $SavedIdeasTable(this);
  late final $LikedIdeasTable likedIdeas = $LikedIdeasTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    userHabits,
    folders,
    savedIdeas,
    likedIdeas,
  ];
}

typedef $$UserHabitsTableCreateCompanionBuilder =
    UserHabitsCompanion Function({
      required DateTime date,
      Value<int> articlesCompleted,
      Value<int> rowid,
    });
typedef $$UserHabitsTableUpdateCompanionBuilder =
    UserHabitsCompanion Function({
      Value<DateTime> date,
      Value<int> articlesCompleted,
      Value<int> rowid,
    });

class $$UserHabitsTableFilterComposer
    extends Composer<_$AppDatabase, $UserHabitsTable> {
  $$UserHabitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get articlesCompleted => $composableBuilder(
    column: $table.articlesCompleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserHabitsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserHabitsTable> {
  $$UserHabitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get articlesCompleted => $composableBuilder(
    column: $table.articlesCompleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserHabitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserHabitsTable> {
  $$UserHabitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get articlesCompleted => $composableBuilder(
    column: $table.articlesCompleted,
    builder: (column) => column,
  );
}

class $$UserHabitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserHabitsTable,
          UserHabit,
          $$UserHabitsTableFilterComposer,
          $$UserHabitsTableOrderingComposer,
          $$UserHabitsTableAnnotationComposer,
          $$UserHabitsTableCreateCompanionBuilder,
          $$UserHabitsTableUpdateCompanionBuilder,
          (
            UserHabit,
            BaseReferences<_$AppDatabase, $UserHabitsTable, UserHabit>,
          ),
          UserHabit,
          PrefetchHooks Function()
        > {
  $$UserHabitsTableTableManager(_$AppDatabase db, $UserHabitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserHabitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserHabitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserHabitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> date = const Value.absent(),
                Value<int> articlesCompleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserHabitsCompanion(
                date: date,
                articlesCompleted: articlesCompleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required DateTime date,
                Value<int> articlesCompleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserHabitsCompanion.insert(
                date: date,
                articlesCompleted: articlesCompleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserHabitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserHabitsTable,
      UserHabit,
      $$UserHabitsTableFilterComposer,
      $$UserHabitsTableOrderingComposer,
      $$UserHabitsTableAnnotationComposer,
      $$UserHabitsTableCreateCompanionBuilder,
      $$UserHabitsTableUpdateCompanionBuilder,
      (UserHabit, BaseReferences<_$AppDatabase, $UserHabitsTable, UserHabit>),
      UserHabit,
      PrefetchHooks Function()
    >;
typedef $$FoldersTableCreateCompanionBuilder =
    FoldersCompanion Function({
      Value<int> id,
      required String name,
      Value<bool> isDefault,
      required DateTime createdAt,
    });
typedef $$FoldersTableUpdateCompanionBuilder =
    FoldersCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<bool> isDefault,
      Value<DateTime> createdAt,
    });

final class $$FoldersTableReferences
    extends BaseReferences<_$AppDatabase, $FoldersTable, Folder> {
  $$FoldersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SavedIdeasTable, List<SavedIdea>>
  _savedIdeasRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.savedIdeas,
    aliasName: $_aliasNameGenerator(db.folders.id, db.savedIdeas.folderId),
  );

  $$SavedIdeasTableProcessedTableManager get savedIdeasRefs {
    final manager = $$SavedIdeasTableTableManager(
      $_db,
      $_db.savedIdeas,
    ).filter((f) => f.folderId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_savedIdeasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FoldersTableFilterComposer
    extends Composer<_$AppDatabase, $FoldersTable> {
  $$FoldersTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> savedIdeasRefs(
    Expression<bool> Function($$SavedIdeasTableFilterComposer f) f,
  ) {
    final $$SavedIdeasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.savedIdeas,
      getReferencedColumn: (t) => t.folderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavedIdeasTableFilterComposer(
            $db: $db,
            $table: $db.savedIdeas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FoldersTableOrderingComposer
    extends Composer<_$AppDatabase, $FoldersTable> {
  $$FoldersTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FoldersTableAnnotationComposer
    extends Composer<_$AppDatabase, $FoldersTable> {
  $$FoldersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> savedIdeasRefs<T extends Object>(
    Expression<T> Function($$SavedIdeasTableAnnotationComposer a) f,
  ) {
    final $$SavedIdeasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.savedIdeas,
      getReferencedColumn: (t) => t.folderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavedIdeasTableAnnotationComposer(
            $db: $db,
            $table: $db.savedIdeas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FoldersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FoldersTable,
          Folder,
          $$FoldersTableFilterComposer,
          $$FoldersTableOrderingComposer,
          $$FoldersTableAnnotationComposer,
          $$FoldersTableCreateCompanionBuilder,
          $$FoldersTableUpdateCompanionBuilder,
          (Folder, $$FoldersTableReferences),
          Folder,
          PrefetchHooks Function({bool savedIdeasRefs})
        > {
  $$FoldersTableTableManager(_$AppDatabase db, $FoldersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoldersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoldersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoldersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => FoldersCompanion(
                id: id,
                name: name,
                isDefault: isDefault,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<bool> isDefault = const Value.absent(),
                required DateTime createdAt,
              }) => FoldersCompanion.insert(
                id: id,
                name: name,
                isDefault: isDefault,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FoldersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({savedIdeasRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (savedIdeasRefs) db.savedIdeas],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (savedIdeasRefs)
                    await $_getPrefetchedData<Folder, $FoldersTable, SavedIdea>(
                      currentTable: table,
                      referencedTable: $$FoldersTableReferences
                          ._savedIdeasRefsTable(db),
                      managerFromTypedResult: (p0) => $$FoldersTableReferences(
                        db,
                        table,
                        p0,
                      ).savedIdeasRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.folderId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$FoldersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FoldersTable,
      Folder,
      $$FoldersTableFilterComposer,
      $$FoldersTableOrderingComposer,
      $$FoldersTableAnnotationComposer,
      $$FoldersTableCreateCompanionBuilder,
      $$FoldersTableUpdateCompanionBuilder,
      (Folder, $$FoldersTableReferences),
      Folder,
      PrefetchHooks Function({bool savedIdeasRefs})
    >;
typedef $$SavedIdeasTableCreateCompanionBuilder =
    SavedIdeasCompanion Function({
      required String id,
      required String ideaId,
      required String articleId,
      required String articleTitle,
      required String articleUrl,
      required String textContent,
      Value<String?> imageUrl,
      required int folderId,
      required DateTime savedAt,
      Value<int> rowid,
    });
typedef $$SavedIdeasTableUpdateCompanionBuilder =
    SavedIdeasCompanion Function({
      Value<String> id,
      Value<String> ideaId,
      Value<String> articleId,
      Value<String> articleTitle,
      Value<String> articleUrl,
      Value<String> textContent,
      Value<String?> imageUrl,
      Value<int> folderId,
      Value<DateTime> savedAt,
      Value<int> rowid,
    });

final class $$SavedIdeasTableReferences
    extends BaseReferences<_$AppDatabase, $SavedIdeasTable, SavedIdea> {
  $$SavedIdeasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FoldersTable _folderIdTable(_$AppDatabase db) => db.folders
      .createAlias($_aliasNameGenerator(db.savedIdeas.folderId, db.folders.id));

  $$FoldersTableProcessedTableManager get folderId {
    final $_column = $_itemColumn<int>('folder_id')!;

    final manager = $$FoldersTableTableManager(
      $_db,
      $_db.folders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_folderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SavedIdeasTableFilterComposer
    extends Composer<_$AppDatabase, $SavedIdeasTable> {
  $$SavedIdeasTableFilterComposer({
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

  ColumnFilters<String> get ideaId => $composableBuilder(
    column: $table.ideaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get articleId => $composableBuilder(
    column: $table.articleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get articleTitle => $composableBuilder(
    column: $table.articleTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get articleUrl => $composableBuilder(
    column: $table.articleUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$FoldersTableFilterComposer get folderId {
    final $$FoldersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.folders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoldersTableFilterComposer(
            $db: $db,
            $table: $db.folders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SavedIdeasTableOrderingComposer
    extends Composer<_$AppDatabase, $SavedIdeasTable> {
  $$SavedIdeasTableOrderingComposer({
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

  ColumnOrderings<String> get ideaId => $composableBuilder(
    column: $table.ideaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get articleId => $composableBuilder(
    column: $table.articleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get articleTitle => $composableBuilder(
    column: $table.articleTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get articleUrl => $composableBuilder(
    column: $table.articleUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$FoldersTableOrderingComposer get folderId {
    final $$FoldersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.folders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoldersTableOrderingComposer(
            $db: $db,
            $table: $db.folders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SavedIdeasTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavedIdeasTable> {
  $$SavedIdeasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ideaId =>
      $composableBuilder(column: $table.ideaId, builder: (column) => column);

  GeneratedColumn<String> get articleId =>
      $composableBuilder(column: $table.articleId, builder: (column) => column);

  GeneratedColumn<String> get articleTitle => $composableBuilder(
    column: $table.articleTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get articleUrl => $composableBuilder(
    column: $table.articleUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get savedAt =>
      $composableBuilder(column: $table.savedAt, builder: (column) => column);

  $$FoldersTableAnnotationComposer get folderId {
    final $$FoldersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.folders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoldersTableAnnotationComposer(
            $db: $db,
            $table: $db.folders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SavedIdeasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavedIdeasTable,
          SavedIdea,
          $$SavedIdeasTableFilterComposer,
          $$SavedIdeasTableOrderingComposer,
          $$SavedIdeasTableAnnotationComposer,
          $$SavedIdeasTableCreateCompanionBuilder,
          $$SavedIdeasTableUpdateCompanionBuilder,
          (SavedIdea, $$SavedIdeasTableReferences),
          SavedIdea,
          PrefetchHooks Function({bool folderId})
        > {
  $$SavedIdeasTableTableManager(_$AppDatabase db, $SavedIdeasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavedIdeasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavedIdeasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavedIdeasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ideaId = const Value.absent(),
                Value<String> articleId = const Value.absent(),
                Value<String> articleTitle = const Value.absent(),
                Value<String> articleUrl = const Value.absent(),
                Value<String> textContent = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<int> folderId = const Value.absent(),
                Value<DateTime> savedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavedIdeasCompanion(
                id: id,
                ideaId: ideaId,
                articleId: articleId,
                articleTitle: articleTitle,
                articleUrl: articleUrl,
                textContent: textContent,
                imageUrl: imageUrl,
                folderId: folderId,
                savedAt: savedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ideaId,
                required String articleId,
                required String articleTitle,
                required String articleUrl,
                required String textContent,
                Value<String?> imageUrl = const Value.absent(),
                required int folderId,
                required DateTime savedAt,
                Value<int> rowid = const Value.absent(),
              }) => SavedIdeasCompanion.insert(
                id: id,
                ideaId: ideaId,
                articleId: articleId,
                articleTitle: articleTitle,
                articleUrl: articleUrl,
                textContent: textContent,
                imageUrl: imageUrl,
                folderId: folderId,
                savedAt: savedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SavedIdeasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({folderId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (folderId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.folderId,
                                referencedTable: $$SavedIdeasTableReferences
                                    ._folderIdTable(db),
                                referencedColumn: $$SavedIdeasTableReferences
                                    ._folderIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SavedIdeasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavedIdeasTable,
      SavedIdea,
      $$SavedIdeasTableFilterComposer,
      $$SavedIdeasTableOrderingComposer,
      $$SavedIdeasTableAnnotationComposer,
      $$SavedIdeasTableCreateCompanionBuilder,
      $$SavedIdeasTableUpdateCompanionBuilder,
      (SavedIdea, $$SavedIdeasTableReferences),
      SavedIdea,
      PrefetchHooks Function({bool folderId})
    >;
typedef $$LikedIdeasTableCreateCompanionBuilder =
    LikedIdeasCompanion Function({
      required String id,
      required String ideaId,
      required String articleId,
      required String articleTitle,
      required String articleUrl,
      required String textContent,
      Value<String?> imageUrl,
      required DateTime likedAt,
      Value<int> rowid,
    });
typedef $$LikedIdeasTableUpdateCompanionBuilder =
    LikedIdeasCompanion Function({
      Value<String> id,
      Value<String> ideaId,
      Value<String> articleId,
      Value<String> articleTitle,
      Value<String> articleUrl,
      Value<String> textContent,
      Value<String?> imageUrl,
      Value<DateTime> likedAt,
      Value<int> rowid,
    });

class $$LikedIdeasTableFilterComposer
    extends Composer<_$AppDatabase, $LikedIdeasTable> {
  $$LikedIdeasTableFilterComposer({
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

  ColumnFilters<String> get ideaId => $composableBuilder(
    column: $table.ideaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get articleId => $composableBuilder(
    column: $table.articleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get articleTitle => $composableBuilder(
    column: $table.articleTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get articleUrl => $composableBuilder(
    column: $table.articleUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get likedAt => $composableBuilder(
    column: $table.likedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LikedIdeasTableOrderingComposer
    extends Composer<_$AppDatabase, $LikedIdeasTable> {
  $$LikedIdeasTableOrderingComposer({
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

  ColumnOrderings<String> get ideaId => $composableBuilder(
    column: $table.ideaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get articleId => $composableBuilder(
    column: $table.articleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get articleTitle => $composableBuilder(
    column: $table.articleTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get articleUrl => $composableBuilder(
    column: $table.articleUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get likedAt => $composableBuilder(
    column: $table.likedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LikedIdeasTableAnnotationComposer
    extends Composer<_$AppDatabase, $LikedIdeasTable> {
  $$LikedIdeasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ideaId =>
      $composableBuilder(column: $table.ideaId, builder: (column) => column);

  GeneratedColumn<String> get articleId =>
      $composableBuilder(column: $table.articleId, builder: (column) => column);

  GeneratedColumn<String> get articleTitle => $composableBuilder(
    column: $table.articleTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get articleUrl => $composableBuilder(
    column: $table.articleUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get likedAt =>
      $composableBuilder(column: $table.likedAt, builder: (column) => column);
}

class $$LikedIdeasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LikedIdeasTable,
          LikedIdea,
          $$LikedIdeasTableFilterComposer,
          $$LikedIdeasTableOrderingComposer,
          $$LikedIdeasTableAnnotationComposer,
          $$LikedIdeasTableCreateCompanionBuilder,
          $$LikedIdeasTableUpdateCompanionBuilder,
          (
            LikedIdea,
            BaseReferences<_$AppDatabase, $LikedIdeasTable, LikedIdea>,
          ),
          LikedIdea,
          PrefetchHooks Function()
        > {
  $$LikedIdeasTableTableManager(_$AppDatabase db, $LikedIdeasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LikedIdeasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LikedIdeasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LikedIdeasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ideaId = const Value.absent(),
                Value<String> articleId = const Value.absent(),
                Value<String> articleTitle = const Value.absent(),
                Value<String> articleUrl = const Value.absent(),
                Value<String> textContent = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<DateTime> likedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LikedIdeasCompanion(
                id: id,
                ideaId: ideaId,
                articleId: articleId,
                articleTitle: articleTitle,
                articleUrl: articleUrl,
                textContent: textContent,
                imageUrl: imageUrl,
                likedAt: likedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ideaId,
                required String articleId,
                required String articleTitle,
                required String articleUrl,
                required String textContent,
                Value<String?> imageUrl = const Value.absent(),
                required DateTime likedAt,
                Value<int> rowid = const Value.absent(),
              }) => LikedIdeasCompanion.insert(
                id: id,
                ideaId: ideaId,
                articleId: articleId,
                articleTitle: articleTitle,
                articleUrl: articleUrl,
                textContent: textContent,
                imageUrl: imageUrl,
                likedAt: likedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LikedIdeasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LikedIdeasTable,
      LikedIdea,
      $$LikedIdeasTableFilterComposer,
      $$LikedIdeasTableOrderingComposer,
      $$LikedIdeasTableAnnotationComposer,
      $$LikedIdeasTableCreateCompanionBuilder,
      $$LikedIdeasTableUpdateCompanionBuilder,
      (LikedIdea, BaseReferences<_$AppDatabase, $LikedIdeasTable, LikedIdea>),
      LikedIdea,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UserHabitsTableTableManager get userHabits =>
      $$UserHabitsTableTableManager(_db, _db.userHabits);
  $$FoldersTableTableManager get folders =>
      $$FoldersTableTableManager(_db, _db.folders);
  $$SavedIdeasTableTableManager get savedIdeas =>
      $$SavedIdeasTableTableManager(_db, _db.savedIdeas);
  $$LikedIdeasTableTableManager get likedIdeas =>
      $$LikedIdeasTableTableManager(_db, _db.likedIdeas);
}
