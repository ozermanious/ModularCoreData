//
//  MCDDatabaseModelAssemblyProtocol.h
//  ModularCoreData
//
//  Created by Vladimir Ozerov on 06/10/2017.
//  Copyright © 2017 Vladimir Ozerov. All rights reserved.
//

@protocol MCDDatabaseModelAssemblyProtocol <NSObject>

@required

@property (nonnull, class, readonly) NSString *assemblyIdentifier; /**< Идентификатор сборщика модели БД */

/**
 Добавить сущности в существующую модель БД
 @param databaseModel Модель БД
 */
+ (void)appendEntitiesForDatabaseModel:(nonnull MCDDatabaseModel *)databaseModel;

/**
 Определяет зависимости между сборщиками модели
 @return Список идентификаторов сборщика модели БД, которые должны выполнится
		 до данного сборщика
 */
+ (nullable NSSet<NSString *> *)requiredAssemblyIdentifierSet;

@end

