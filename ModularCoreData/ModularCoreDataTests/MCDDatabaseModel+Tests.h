//
//  MCDDatabaseModel+Tests.h
//  ModularCoreData
//
//  Created by Vladimir Ozerov on 10/07/2017.
//  Copyright © 2017 SberTech. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString *const MCDDatabaseTestModelPath;


/**
 Тип тестовой модели БД
 */
typedef NS_ENUM(NSUInteger, MCDTestableDatabaseType) {
	MCDTestableDatabaseMain = 0,      /**< Базовая версия модели БД */
	MCDTestableDatabaseMainParedDown, /**< Урезанная версия базовой модели */
	MCDTestableDatabaseMainExtended,  /**< Расширенная версия базовой модели */
	MCDTestableDatabaseMainModified,  /**< Что-то удалено, что-то добавлено в базовой модели */
	MCDTestableDatabaseSecondary,     /**< Полностью другая модель БД */
};


/**
 Категория-помощник тестирования модели БД
 */
@interface MCDDatabaseModel (Tests)

@property (nonatomic, readonly) MCDTestableDatabaseType testableDatabaseType; /**< Тип тестируемой модели */

/**
 Создать тестовую модель БД
 @param databaseType Тип модели
 @return Модель БД
 */
+ (instancetype)testableModelWithType:(MCDTestableDatabaseType)databaseType;

/**
 Полная строка конфигурации JSON-кэша
 @return Строка
 */
- (NSString *)JSONCacheConfigString;

@end
