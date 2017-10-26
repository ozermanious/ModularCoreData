//
//  NSManagedObject+DatabaseTests.m
//  ModularCoreData
//
//  Created by Vladimir Ozerov on 13/07/2017.
//  Copyright © 2017 SberTech. All rights reserved.
//

#import "NSManagedObject+DatabaseTests.h"
#import "NSPredicate+DatabaseTests.h"


@implementation NSManagedObject (DatabaseTests)

+ (Class)testMakeManagedObjectClassForEntity:(NSEntityDescription *)entity
{
	if (entity)
	{
		// Если класс уже создан, возвращаем его
		Class managedObjectClass = NSClassFromString(entity.managedObjectClassName);
		if (managedObjectClass)
		{
			return managedObjectClass;
		}
		
		// Создаем новый класс
		managedObjectClass = objc_allocateClassPair([NSManagedObject class], entity.managedObjectClassName.UTF8String, 0);
		
		for (NSAttributeDescription *attribute in entity.attributesByName.allValues)
		{
			objc_property_attribute_t attr_nonatomic = { "N", "" }; // N = nonatomic
			objc_property_attribute_t attr_retain    = { "&", "" }; // & = retain
			objc_property_attribute_t attr_dynamic   = { "D", "" }; // D = dynamic
			objc_property_attribute_t attr_type      = { "T", 0  }; // T = type
			switch (attribute.attributeType)
			{
				case NSUndefinedAttributeType:
					break;
				case NSBooleanAttributeType:
				case NSInteger16AttributeType:
				case NSInteger32AttributeType:
				case NSInteger64AttributeType:
				case NSDecimalAttributeType:
				case NSDoubleAttributeType:
				case NSFloatAttributeType:
					attr_type.value = "@\"NSNumber\"";
					break;
				case NSStringAttributeType:
					attr_type.value = "@\"NSString\"";
					break;
				case NSDateAttributeType:
					attr_type.value = "@\"NSDate\"";
					break;
				case NSBinaryDataAttributeType:
				case NSTransformableAttributeType:
					attr_type.value = "@\"NSData\"";
					break;
				case NSObjectIDAttributeType:
					attr_type.value = "@\"NSManagedObjectID\"";
					break;
			}
			if (attr_type.value)
			{
				objc_property_attribute_t attrList[] = {
					attr_nonatomic,
					attr_retain,
					attr_dynamic,
					attr_type
				};
				class_addProperty(managedObjectClass, attribute.name.UTF8String, attrList, 4);
			}
		}
		for (NSRelationshipDescription *reltionship in entity.relationshipsByName.allValues)
		{
			objc_property_attribute_t attr_nonatomic = { "N", "" }; // N = nonatomic
			objc_property_attribute_t attr_retain    = { "&", "" }; // & = retain
			objc_property_attribute_t attr_dynamic   = { "D", "" }; // D = dynamic
			objc_property_attribute_t attr_type      = { "T", (reltionship.isToMany ? "@\"NSSet\"" : "@\"NSManagedObject\"")  }; // T = type
			objc_property_attribute_t attrList[] = {
				attr_nonatomic,
				attr_retain,
				attr_dynamic,
				attr_type
			};
			class_addProperty(managedObjectClass, reltionship.name.UTF8String, attrList, 4);
		}
		
		// Регистрируем созданный класс
		objc_registerClassPair(managedObjectClass);
		return managedObjectClass;
	}
	return nil;
}

+ (NSManagedObject *)testManagedObjectWithEntityName:(NSString *)entityName mainParameters:(NSDictionary *)mainParameters otherParameters:(NSDictionary *)otherParameters inContext:(MCDDatabaseContext *)context
{
	NSPredicate *predicate = nil;
	if (mainParameters.allKeys.count)
	{
		NSMutableArray<NSPredicate*> *subpredicateList = [NSMutableArray array];
		for (NSString *key in mainParameters.allKeys)
		{
			NSPredicate *subpredicate = [NSPredicate equalPredicateForKey:key value:mainParameters[key]];
			[subpredicateList addObject:subpredicate];
		}

		if (subpredicateList.count == 1)
		{
			predicate = subpredicateList.firstObject;
		}
		else
		{
			predicate = [NSCompoundPredicate andPredicateWithSubpredicates:subpredicateList];
		}
	}
	
	NSManagedObject *managedObject = nil;
	if (predicate)
	{
		managedObject = [context entry:NSClassFromString(entityName) withPredicate:predicate];
	}
	if (!managedObject)
	{
		managedObject = [context newEntry:NSClassFromString(entityName)];
		for (NSString *key in mainParameters.allKeys)
		{
			[managedObject setValue:mainParameters[key] forKey:key];
		}
	}
	for (NSString *key in otherParameters.allKeys)
	{
		[managedObject setValue:otherParameters[key] forKey:key];
	}
	return managedObject;
}

- (void)expectToPropertiesBeEqual:(NSDictionary *)expectedPropertyValues
{
	NSMutableDictionary *managedObjectValues = [NSMutableDictionary dictionary];
	for (NSPropertyDescription *property in self.entity.properties)
	{
		id value = [self valueForKey:property.name];
		if (value)
		{
			managedObjectValues[property.name] = value;
		}
	}
	expect([managedObjectValues copy]).to.equal(expectedPropertyValues);
}

@end
