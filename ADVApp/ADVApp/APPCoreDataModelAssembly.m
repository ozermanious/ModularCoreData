//
//  APPCoreDataModelAssembly.m
//  ADVApp
//
//  Created by Vladimir Ozerov on 06/10/2017.
//  Copyright © 2017 Vladimir Ozerov. All rights reserved.
//

#import "APPCoreDataModelAssembly.h"
#import <objc/runtime.h>


@implementation APPCoreDataModelAssembly

+ (MCDDatabase *)assembleDatabase
{
	MCDDatabase *database = [MCDDatabase new];
	database.databaseConfiguration = [MCDDatabaseConfiguration defaultConfiguration];
	database.dbModel = [self assembleDatabaseModel];
	
	[database open:nil];

	return database;
}

+ (MCDDatabaseModel *)assembleDatabaseModel
{
	NSArray<Class<MCDDatabaseModelAssemblyProtocol>> *modelAssemblyClassList = [self modelAssemblyClassList];
	NSArray<Class<MCDDatabaseModelAssemblyProtocol>> *sortedAssemblyClassList = [self sortedModelAssemblyClassList:modelAssemblyClassList];
	
	MCDDatabaseModel *model = [MCDDatabaseModel new];
	for (Class<MCDDatabaseModelAssemblyProtocol> modelAssemblyClass in sortedAssemblyClassList)
	{
		[modelAssemblyClass appendEntitiesForDatabaseModel:model];
	}
	return model;
}

/**
 Через runtime определяем, какие классы реализуют протокол MCDDatabaseModelAssemblyProtocol
 */
+ (NSArray<Class<MCDDatabaseModelAssemblyProtocol>> *)modelAssemblyClassList
{
	int classListCount = objc_getClassList(NULL, 0);
	Class *classListPointer = NULL;
	
	classListPointer = (__unsafe_unretained Class *)malloc(sizeof(Class) * classListCount);
	classListCount = objc_getClassList(classListPointer, classListCount);
	
	NSMutableArray<Class<MCDDatabaseModelAssemblyProtocol>> *modelAssemblyClassList = [NSMutableArray array];
	for (NSInteger classIndex = 0; classIndex < classListCount; classIndex += 1)
	{
		Class modelAssemblyClass = classListPointer[classIndex];
		if (class_conformsToProtocol(modelAssemblyClass, @protocol(MCDDatabaseModelAssemblyProtocol)))
		{
			[modelAssemblyClassList addObject:(id)modelAssemblyClass];
		}
	}
	free(classListPointer);

	return [modelAssemblyClassList copy];
}

/**
 Сортируем сборщики в соответствие с зависимостями, полученными через
 метод протокола MCDDatabaseModelAssemblyProtocol:
 + (NSSet<NSString *> *)requiredAssemblyIdentifierSet
 */
+ (NSArray<Class<MCDDatabaseModelAssemblyProtocol>> *)sortedModelAssemblyClassList:(NSArray<Class<MCDDatabaseModelAssemblyProtocol>> *)modelAssemblyClassList
{
	NSMutableArray<Class<MCDDatabaseModelAssemblyProtocol>> *sortedModelAssemblyClassList = [NSMutableArray array];
	NSMutableSet<NSString *> *finishedModelAssemblyIdentifierSet = [NSMutableSet set];
	
	while (modelAssemblyClassList.count > sortedModelAssemblyClassList.count)
	{
		NSUInteger filteredModulesCount = 0;
		for (Class<MCDDatabaseModelAssemblyProtocol> modelAssemblyClass in modelAssemblyClassList)
		{
			if ([sortedModelAssemblyClassList containsObject:modelAssemblyClass])
			{
				continue;
			}
			
			NSSet *requiredModelAssemblyIdentifierSet = [modelAssemblyClass requiredAssemblyIdentifierSet] ?: [NSSet set];
			// Если необходимые сборщики уже в списке, значит можно добавить этот сборщик в конец списка
			if ([requiredModelAssemblyIdentifierSet isSubsetOfSet:finishedModelAssemblyIdentifierSet])
			{
				[sortedModelAssemblyClassList addObject:modelAssemblyClass];
				[finishedModelAssemblyIdentifierSet addObject:[modelAssemblyClass assemblyIdentifier]];
				filteredModulesCount++;
			}
		}
		NSAssert(filteredModulesCount, @"Не удалось определить зависимости модулей");
	}
	
	return [sortedModelAssemblyClassList copy];
}

@end
