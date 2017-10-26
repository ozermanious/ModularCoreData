//
//  MCDDatabaseContext+Tests.m
//  ModularCoreData
//
//  Created by Vladimir Ozerov on 13/07/2017.
//  Copyright © 2017 SberTech. All rights reserved.
//

#import "MCDDatabaseContext+Tests.h"
#import "MCDDatabaseModel+Tests.h"
#import "MCDDatabaseModelConfigurationTestDataSource.h"


@implementation MCDDatabaseContext (Tests)

- (void)testFillContextWithTestManagedObjects
{
	[self performBlockAndWait:^{
		MCDDatabaseModel *model = (id)self.persistentStoreCoordinator.managedObjectModel;
		for (MCDDatabaseModelConfiguration *configuration in model.configs.allValues)
		{
			for (Class<MCDDatabaseModelConfigurationTestDataSource> dataSource in configuration.entitiesDS)
			{
				[dataSource makeManagedObjectsInContext:self];
			}
		}
		[self save:nil];
	}];
}

- (void)expectToBeCompleteness
{
	MCDDatabaseModel *model = (id)self.persistentStoreCoordinator.managedObjectModel;
	[self expectToBeCompletenessAfterMigrationFromModel:model];
}

- (void)expectToBeCompletenessAfterMigrationFromModel:(MCDDatabaseModel *)migrationSourceModel
{
	MCDDatabaseModel *model = (id)self.persistentStoreCoordinator.managedObjectModel;
	for (MCDDatabaseModelConfiguration *configuration in model.configs.allValues)
	{
		for (Class<MCDDatabaseModelConfigurationTestDataSource> dataSource in configuration.entitiesDS)
		{
			[dataSource expectCompletenessInContext:self afterMigrationFromModel:migrationSourceModel];
		}
	}
}

- (NSArray<NSManagedObject*> *)testGetAllManagedObjects
{
	NSMutableArray<NSManagedObject*> *managedObjectList = [NSMutableArray array];
	[self performBlockAndWait:^{
		for (NSEntityDescription *entity in self.persistentStoreCoordinator.managedObjectModel.entities)
		{
			if (entity.isAbstract)
			{
				continue;
			}
			NSArray *entries = [self allEntries:NSClassFromString(entity.managedObjectClassName)];
			[managedObjectList addObjectsFromArray:entries];
		}
	}];
	return [managedObjectList copy];
}

@end
