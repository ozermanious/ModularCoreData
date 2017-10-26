//
//  MCDDatabaseContext+Tests.h
//  ModularCoreData
//
//  Created by Vladimir Ozerov on 13/07/2017.
//  Copyright © 2017 SberTech. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MCDDatabaseContext (Tests)

/**
 Заполнить контект тестовыми данными
 @discussion Выполняется синхронно
 */
- (void)testFillContextWithTestManagedObjects;

/**
 Проверить полноту и корректность тестовых данных в контексте БД
 */
- (void)expectToBeCompleteness;

/**
 Проверить полноту и корректность тестовых данных в контексте БД после миграции
 @param migrationSourceModel Исходная модель БД с которой происходила миграция
 */
- (void)expectToBeCompletenessAfterMigrationFromModel:(MCDDatabaseModel *)migrationSourceModel;

/**
 Зафетчить все объекты в контексте
 @discussion Выполняется синхронно
 @return Список объектов
 */
- (NSArray<NSManagedObject*> *)testGetAllManagedObjects;

@end
