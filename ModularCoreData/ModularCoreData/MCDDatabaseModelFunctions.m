//
//  MCDDatabaseModelFunctions.m
//  ModularCoreData
//
//  Created by Vladimir Ozerov on 07/07/2017.
//  Copyright © 2017 SberTech. All rights reserved.
//

#import "MCDDatabaseModelFunctions.h"


#define CHECKANDSET_LOG_ENABLED 0


BOOL MCDCheckAndSet(NSManagedObject *object, NSString *propertyKey, id newValue)
{
	if (![object isKindOfClass:[NSManagedObject class]])
	{
		return NO;
	}
	
	// Если newValue является значением [NSNull null]
	if (newValue == [NSNull null])
	{
		newValue = nil;
	}
	
	// Проверяем новое значение на совпадение типа
	BOOL newValueIsSameType = NO;

	NSAttributeDescription *attribute = object.entity.propertiesByName[propertyKey];
	if ([attribute isKindOfClass:[NSAttributeDescription class]])
	{
		if ([newValue isKindOfClass:NSClassFromString(attribute.attributeValueClassName)] || attribute.attributeType == NSTransformableAttributeType)
		{
			newValueIsSameType = YES;
		}
	}
	else
	{
		// Для relationship считаем, что типы совпадают
		newValueIsSameType = YES;
	}

	if (!newValueIsSameType)
	{
#if CHECKANDSET_LOG_ENABLED
		NSLog(@"(!!!) [checkAndSet:] [%@.%@] [Тип поля в кэше не соответствует типу поля в БД!]", NSStringFromClass([object class]), propertyKey);
#endif
		return NO;
	}
	
	NSError *error = nil;
	if (![object validateValue:&newValue forKey:propertyKey error:&error])
	{
#if CHECKANDSET_LOG_ENABLED
		NSLog(@"(!!!) [checkAndSet:] [%@.%@] [ERROR: %@]", NSStringFromClass([object class]), propertyKey, error);
#endif
	}
	
	NSDictionary *allProperties = object.entity.propertiesByName;
	if (!allProperties[propertyKey])
	{
#if CHECKANDSET_LOG_ENABLED
		NSLog(@"(!!!) [checkAndSet:] [%@.%@] [Нет такого ключа в данной сущности!]", NSStringFromClass([object class]), propertyKey);
#endif
		return NO;
	}
	
	id oldValue = [object valueForKey:propertyKey];
	if ((oldValue && newValue && ![oldValue isEqual:newValue]) || ((!!oldValue) != (!!newValue) /* либо old == nil, либо new == nil */))
	{
		@try
		{
			[object setValue:newValue forKey:propertyKey];
			return YES;
		}
		@catch(NSException *exception1)
		{
#if CHECKANDSET_LOG_ENABLED
			NSLog(@"(!!!) [checkAndSet:] Exception \"%@\", reason: \"%@\"", [exception1 name], [exception1 reason]);
#endif
		}
		@catch(NSException *exception2)
		{
#if CHECKANDSET_LOG_ENABLED
			NSLog(@"(!!!) [checkAndSet:] Exception (2) \"%@\", reason: \"%@\"", [exception2 name], [exception2 reason]);
#endif
		}
	}
	return NO;
}

BOOL MCDCheckAndSetDictionary(NSManagedObject *object, NSDictionary *keyedValues)
{
	BOOL anyChanged = NO;
	for (NSString *propertyKey in keyedValues)
	{
		BOOL changed = MCDCheckAndSet(object, propertyKey, [keyedValues objectForKey:propertyKey]);
		anyChanged = anyChanged || changed;
	}
	return anyChanged;
}

NSEntityDescription *makeDbEntity(NSString *name, NSArray<NSPropertyDescription *> *properties)
{
	NSEntityDescription *entity = [NSEntityDescription new];
	entity.name = name;
	entity.managedObjectClassName = name;
	entity.properties = properties;
	return entity;
}

NSAttributeDescription *makeDbAttr(NSString *name, NSAttributeType type, void (^options)(NSAttributeDescription *a))
{
	NSAttributeDescription *attribute = [NSAttributeDescription new];
	attribute.name = name;
	attribute.attributeType = type;
	attribute.optional = YES;
	if (options)
	{
		options(attribute);
	}
	return attribute;
}

NSRelationshipDescription *makeDbRelation(NSString *name, NSEntityDescription *destination, BOOL toOne, void (^options)(NSRelationshipDescription *r))
{
	NSRelationshipDescription *relationship = [NSRelationshipDescription new];
	relationship.name = name;
	relationship.destinationEntity = destination;
	relationship.optional = YES;
	relationship.ordered = NO;
	relationship.minCount = 0;
	relationship.maxCount = toOne ? 1 : 0;
	if (options)
	{
		options(relationship);
	}
	return relationship;
}

void appendDbRelationships(NSEntityDescription *entity, NSArray<NSRelationshipDescription *> *relationships)
{
	if (!relationships.count)
	{
		return;
	}
	NSMutableArray *propertyList = [entity.properties mutableCopy];
	[propertyList addObjectsFromArray:relationships];
	entity.properties = [propertyList copy];
}

void pairDbRelationships(NSEntityDescription *firstEntity, NSString *firstName, NSEntityDescription *secondEntity, NSString *secondName)
{
	NSRelationshipDescription *firstRelationship = firstEntity.relationshipsByName[firstName];
	NSRelationshipDescription *secondRelationship = secondEntity.relationshipsByName[secondName];
	if (firstRelationship && secondRelationship)
	{
		firstRelationship.inverseRelationship = secondRelationship;
		secondRelationship.inverseRelationship = firstRelationship;
	}
}
