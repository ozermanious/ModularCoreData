//
//  MCDDatabaseModelConfiguration.h
//  ModularCoreData
//
//  Created by Vladimir Ozerov on 07/07/2017.
//  Copyright © 2017 SberTech. All rights reserved.
//

#import <Foundation/Foundation.h>


@class MCDDatabaseModel;


/**
 Протокол, позволяющий добавлять сущности в модель извне
 @discussion Сначала со всех модулей собираются все сущности, и только после
			 этого добавляются связи. Это сделано, чтобы гарантировать полноту
			 набора сущностей на этапе создания связей.
 */
@protocol MCDDatabaseEntityDataSource <NSObject>

@optional

/**
 Добавить сущность к модели БД
 @param model Модель БД
 @param entities Список уже созданных сущностей БД
 @return Сущность БД
 */
+ (NSEntityDescription *)entityForDatabaseModel:(MCDDatabaseModel *)model withEntities:(NSDictionary<NSString *, NSEntityDescription *> *)entities;

/**
 Добавить список сущностей к модели БД
 @param model Модель БД
 @param entities Список уже созданных сущностей БД
 @return Список сущностей БД
 */
+ (NSArray<NSEntityDescription*> *)entityListForDatabaseModel:(MCDDatabaseModel *)model withEntities:(NSDictionary<NSString *, NSEntityDescription *> *)entities;

/**
 Добавить связи к созданным сущностям
 @param model Модель БД
 @param entities Список сущностей БД
 */
+ (void)databaseModel:(MCDDatabaseModel *)model addRelationsForEntities:(NSDictionary<NSString *, NSEntityDescription *> *)entities;

/**
 Привязать подсущности к суперсущности
 @param model Модель БД
 @param entities Список сущностей БД
 */
+ (void)databaseModel:(MCDDatabaseModel *)model bindSubentities:(NSDictionary<NSString *, NSEntityDescription *> *)entities;

@end



/** @brief Конфигурация БД
 *  @discussion Содержит набор сущностей, которые будут сохранены в отдельном NSPersistentStore.
 */
@interface MCDDatabaseModelConfiguration : NSObject

@property (nonatomic, copy) NSString *storeType;     /**< Тип хранилища */
@property (nonatomic, copy) NSString *storeFileName; /**< Имя файла */
@property (nonatomic, copy) NSDictionary *options; /**< Параметры */
@property (nonatomic, strong, readonly) NSMutableArray<id<MCDDatabaseEntityDataSource>> *entitiesDS; /**< Набор сущностей */

/**
 Создать конфигурацию с параметрами
 @param storeType Тип хранилища
 @param storeFileName Имя файла
 @param options Параметры
 @param entities Набор сущностей
 @return Конфигурация
 */
+ (instancetype)configWithType:(NSString *)storeType
						  file:(NSString *)storeFileName
					   options:(NSDictionary *)options
					  entities:(NSArray<id<MCDDatabaseEntityDataSource>> *)entities;

/**
 Восстановить исходные параметры
 */
- (void)restoreInitialParameters;

@end
