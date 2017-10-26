//
//  NSManagedObject+DatabaseTests.h
//  ModularCoreData
//
//  Created by Vladimir Ozerov on 13/07/2017.
//  Copyright © 2017 SberTech. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSManagedObject (DatabaseTests)

/**
 С помощью runtime создать класс для сущности БД
 @param entity Сущность БД
 @return Класс
 */
+ (Class)testMakeManagedObjectClassForEntity:(NSEntityDescription *)entity;

/**
 Создать (либо зафетчить) объект в контексте
 @param entityName Имя сущности
 @param mainParameters Параметры, по которым будет создан предикат поиска уже созданной сущности
 @param otherParameters Остальные параметры
 @param context Контекст БД
 @return Объект
 */
+ (NSManagedObject *)testManagedObjectWithEntityName:(NSString *)entityName
									  mainParameters:(NSDictionary *)mainParameters
									 otherParameters:(NSDictionary *)otherParameters
										   inContext:(MCDDatabaseContext *)context;

/**
 Проверить соответствие значений свойств объекта в БД
 @discussion Проверка осуществляется с помощью Expecta
 @param expectedPropertyValues Ожидаемые значениям
 */
- (void)expectToPropertiesBeEqual:(NSDictionary *)expectedPropertyValues;

@end
