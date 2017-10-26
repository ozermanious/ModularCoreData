//
//  MCDDatabaseModelConfigurationTestDataSource.h
//  ModularCoreData
//
//  Created by Vladimir Ozerov on 13/07/2017.
//  Copyright © 2017 SberTech. All rights reserved.
//


@protocol MCDDatabaseModelConfigurationTestDataSource <NSObject>

/**
 Создать сущности в контексте БД
 @param context Контекст БД
 */
+ (void)makeManagedObjectsInContext:(MCDDatabaseContext *)context;

/**
 Проверить полноту и корректность данных в контексте БД
 @discussion Проверка осуществляется с помощью Expecta
 @param context Контекст БД
 */
+ (void)expectCompletenessInContext:(MCDDatabaseContext *)context;

/**
 Проверить полноту и корректность данных в контексте БД после миграции
 @discussion Проверка осуществляется с помощью Expecta
 @param context Контекст БД
 @param migrationSourceModel Исходная модель БД с которой происходила миграция
 */
+ (void)expectCompletenessInContext:(MCDDatabaseContext *)context afterMigrationFromModel:(MCDDatabaseModel *)migrationSourceModel;

/**
 Подстрока формата конфигурации JSON-кэша
 @param model Модель БД
 @return Подстрока
 */
+ (NSString *)JSONCacheNodeFormatSubstringWithModel:(MCDDatabaseModel *)model;

@end
