//
//  MCDDatabaseModelFunctions.h
//  ModularCoreData
//
//  Created by Vladimir Ozerov on 07/07/2017.
//  Copyright © 2017 SberTech. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 Безопасно установить в свойство NSManagedObject'а новое значение
 @discussion Функция производит валидацию на совпадение типа значения, а также на равенство уже имеющегося значения
 @param object Объект Core Data
 @param propertyKey Имя свойства
 @param newValue Значение
 @return YES, если значение установлено
 */
extern BOOL MCDCheckAndSet(NSManagedObject *object, NSString *propertyKey, id newValue);

/**
 Безопасно установить набор значений в свойства NSManagedObject 
 Под капотом для каждого свойства вызывается MCDCheckAndSet
 @param object Объект Core Data
 @param keyedValues Словарь со значениями свойств
 @return YES, если хотя бы одно свойство установилось
 */
extern BOOL MCDCheckAndSetDictionary(NSManagedObject *object, NSDictionary *keyedValues);


#define DB_TO_ONE 1
#define DB_TO_MANY 0


/**
 Создать сущность БД
 @param name Имя
 @param properties Свойства
 @return Сущность БД
 */
extern NSEntityDescription *makeDbEntity(NSString *name, NSArray<NSPropertyDescription *> *properties);

/**
 Создать атрибут сущности БД
 @param name Имя
 @param type Тип атрибута
 @param options Блок с параметрами
 @return Атрибут сущности БД
 */
extern NSAttributeDescription *makeDbAttr(NSString *name, NSAttributeType type, void (^options)(NSAttributeDescription *attribute));

/**
 Создать связь с сущностью БД
 @param name Имя
 @param destination Сущность назначения
 @param toOne Признак связи один к одному/ко многим
 @param options Блок с параметрами
 @return Связь с сущностью БД
 */
extern NSRelationshipDescription *makeDbRelation(NSString *name, NSEntityDescription *destination, BOOL toOne, void (^options)(NSRelationshipDescription *r));

/**
 Добавить к сущности БД связи
 @param entity Сущность БД
 @param relationships Набор связей
 */
extern void appendDbRelationships(NSEntityDescription *entity, NSArray<NSRelationshipDescription *> *relationships);

/**
 Сформировать пару из двух сущностей
 @param firstEntity Первая сущность БД
 @param firstName Имя связи в первой сущности
 @param secondEntity Вторая сущность
 @param secondName Имя связи во второй сущности
 */
extern void pairDbRelationships(NSEntityDescription *firstEntity, NSString *firstName, NSEntityDescription *secondEntity, NSString *secondName);
