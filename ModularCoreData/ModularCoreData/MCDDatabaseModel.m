//
//  MCDDatabaseModel.m
//  Created by Vladimir Ozerov on 28/07/16.
//  Copyright © 2016 SberTech. All rights reserved.
//

#import "MCDDatabaseModel+Private.h"
#import "MCDDatabaseModelConfiguration+Private.h"
#import <objc/runtime.h>


@implementation MCDDatabaseModel

- (id)init
{
	self = [super init];
	if (self)
	{
		_configs = [NSMutableDictionary dictionary];
	}
	return self;
}

- (void)applyConfigs
{
	if (self.configsApplied)
	{
		return;
	}
	self.configsApplied = YES;
	
	// Создаю сущности и добавляю в модель
	//                  <Конфиг>                     <Имя сущности>     <Сущность>
	NSMutableDictionary<NSString *, NSMutableDictionary<NSString *, NSEntityDescription *> *> *entitiesByConfigs = [NSMutableDictionary dictionary];
	NSMutableDictionary<NSString *, NSEntityDescription *> *allEntities = [NSMutableDictionary dictionary];
	for (NSString *configName in self.configs.allKeys)
	{
		entitiesByConfigs[configName] = [NSMutableDictionary dictionary];
		for (Class<MCDDatabaseEntityDataSource> dataSource in self.configs[configName].entitiesDS)
		{
			// Получаю список сущностей у каждого dataSource
			NSArray *dataSourceEntityList = nil;
			if ([self.class concreteClass:dataSource respondsToSelector:@selector(entityForDatabaseModel:withEntities:)])
			{
				NSEntityDescription *entity = [dataSource entityForDatabaseModel:self withEntities:[allEntities copy]];
				if (entity)
				{
					dataSourceEntityList = @[entity];
				}
			}
			else if ([self.class concreteClass:dataSource respondsToSelector:@selector(entityListForDatabaseModel:withEntities:)])
			{
				dataSourceEntityList = [dataSource entityListForDatabaseModel:self withEntities:[allEntities copy]];
			}
			// Запоминаю полученные сущности по конфигурациям
			for (NSEntityDescription *entity in dataSourceEntityList)
			{
				entitiesByConfigs[configName][entity.name] = entity;
				allEntities[entity.name] = entity;
			}
		}
	}

	self.entities = allEntities.allValues;
	for (NSString *configName in entitiesByConfigs.allKeys)
	{
		[self setEntities:entitiesByConfigs[configName].allValues forConfiguration:configName];
	}

	// Добавляю связи между сущностями
	for (NSString *configName in self.configs.allKeys)
	{
		for (Class<MCDDatabaseEntityDataSource> dataSource in self.configs[configName].entitiesDS)
		{
			if ([self.class concreteClass:dataSource respondsToSelector:@selector(databaseModel:addRelationsForEntities:)])
			{
				[dataSource databaseModel:self addRelationsForEntities:allEntities];
			}
		}
	}
	
	// Добавляю к суперсущностям подсущности
	for (NSString *configName in self.configs.allKeys)
	{
		for (Class<MCDDatabaseEntityDataSource> dataSource in self.configs[configName].entitiesDS)
		{
			if ([self.class concreteClass:dataSource respondsToSelector:@selector(databaseModel:bindSubentities:)])
			{
				[dataSource databaseModel:self bindSubentities:allEntities];
			}
		}
	}
	
	// Фиксирую начальные параметры конфигураций
	for (MCDDatabaseModelConfiguration *configuration in self.configs.allValues)
	{
		[configuration commitInitialParameters];
	}
}

/**
 Проверяем, что именно этот класс, а не родительский реализует метод протокола, а не его родитель
 @param clazz Класс
 @param selector Селектор метода
 @return YES, если класс реализует метод
 */
+ (BOOL)concreteClass:(Class)clazz respondsToSelector:(SEL)selector
{
	Class superClazz = class_getSuperclass(clazz);
	Method method = class_getClassMethod(clazz, selector);
	Method superMethod = class_getClassMethod(superClazz, selector);
	return (method && (method != superMethod));
}

- (instancetype)copyWithZone:(NSZone *)zone
{
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
	MCDDatabaseModel *copyOfModel = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	return copyOfModel;
}

- (NSString *)description
{
	NSString *entityListString = nil;
	if (self.entities.count)
	{
		NSMutableArray<NSString*> *entityStringList = [NSMutableArray array];
		for (NSEntityDescription *entity in self.entities)
		{
			NSString *entityString = [NSString stringWithFormat:@"%@<%i props.>", entity.name, (int)entity.properties.count];
			[entityStringList addObject:entityString];
		}
		entityListString = [entityStringList componentsJoinedByString:@", "];
	}
	else
	{
		entityListString = @"no entities";
	}
	return [NSString stringWithFormat:@"%@(0x%lx, %@)", NSStringFromClass(self.class), (unsigned long)self, entityListString];
}

@end
