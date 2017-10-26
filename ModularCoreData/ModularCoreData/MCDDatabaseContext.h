//
//  MCDDatabaseContext.h
//  Created by Vladimir Ozerov on 27/07/16.
//  Copyright © 2016 SberTech. All rights reserved.
//

#import <CoreData/CoreData.h>


/**
 Сабкласс контекста БД
 @discussion Содержит вспомогательные методы для работы с сущностями БД
 */
@interface MCDDatabaseContext : NSManagedObjectContext

@property (nonatomic, readonly) BOOL readonly; /**< Признак запрета на запись изменений */

/**
 Создание контекста БД
 @param concurrencyType Тип контекста
 @param readonly Признак запрета на запись
 @return Контекст БД
 */
+ (instancetype)contextWithConcurrencyType:(NSManagedObjectContextConcurrencyType)concurrencyType
								  readonly:(BOOL)readonly;


#pragma mark - NSManagedObject Creating

/**
 Создать сущность и добавить в контекст
 @param managedObjectClass Класс для определения NSEntityDescription
 @return Новая сущность
 */
- (id)newEntry:(Class)managedObjectClass;

/**
 Создать сущность вне контекста
 @param managedObjectClass Класс для определения NSEntityDescription
 @return Новая сущность
 */
- (id)newEntryOutOfContext:(Class)managedObjectClass;

/**
 Определение NSEntityDescription, соответствующей сабклассу NSManagedObject
 @param managedObjectClass Класс для определения NSEntityDescription
 @return NSEntityDescription
 */
- (NSEntityDescription *)entityForObjectClass:(Class)managedObjectClass;


#pragma mark - NSManagedObject Fetching

/**
 Найти сущность
 @discussion Возвращается первый элемент из списка всех найденных
 @param managedObjectClass Класс для определения NSEntityDescription
 @param predicate Предикат фильтрации
 @return NSManagedObject, если найден
 */
- (id)entry:(Class)managedObjectClass withPredicate:(NSPredicate *)predicate;

/**
 Найти все сущности
 @param managedObjectClass Класс для определения NSEntityDescription
 @return Список NSManagedObject-ов
 */
- (NSArray *)allEntries:(Class)managedObjectClass;

/**
 Найти сущности
 @param managedObjectClass Класс для определения NSEntityDescription
 @param predicate Предикат фильтрации
 @return Список NSManagedObject-ов
 */
- (NSArray *)entries:(Class)managedObjectClass
	   withPredicate:(NSPredicate *)predicate;

/**
 Найти сущности
 @param managedObjectClass Класс для определения NSEntityDescription
 @param predicate Предикат фильтрации
 @param sortDescriptors Список дескрипторов сортировки
 @return Список NSManagedObject-ов
 */
- (NSArray *)entries:(Class)managedObjectClass
	   withPredicate:(NSPredicate *)predicate
	 sortDescriptors:(NSArray *)sortDescriptors;

/**
 Найти сущности
 @param managedObjectClass Класс для определения NSEntityDescription
 @param predicate Предикат фильтрации
 @param sortDescriptors Список дескрипторов сортировки
 @param resultType Тип возвращаемого результата
 @return Список объектов указанного типа
 */
- (NSArray *)entries:(Class)managedObjectClass
	   withPredicate:(NSPredicate *)predicate
	 sortDescriptors:(NSArray *)sortDescriptors
		  resultType:(NSFetchRequestResultType)resultType;


#pragma mark - NSManagedObject Deleting

/**
 Удалить все сущности
 @param managedObjectClass Класс для определения NSEntityDescription
 @return Кол-во удаленных сущностей
 */
- (NSInteger)deleteAllEntries:(Class)managedObjectClass;

/**
 Удалить сущности
 @param managedObjectClass Класс для определения NSEntityDescription
 @param predicate Предикат фильтрации
 @return Кол-во удаленных сущностей
 */
- (NSInteger)deleteEntries:(Class)managedObjectClass
			 withPredicate:(NSPredicate *)predicate;

@end
