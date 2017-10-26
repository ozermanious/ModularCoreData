//
//  MCDDatabaseMigrationManagerTests.m
//  ModularCoreData
//
//  Created by Vladimir Ozerov on 17/07/2017.
//  Copyright © 2017 SberTech. All rights reserved.
//

#import "MCDDatabase+Private.h"
#import "MCDDatabaseModel+Tests.h"
#import "MCDDatabaseContext+Tests.h"
#import "MCDDatabaseConfiguration.h"
#import "MCDDatabaseModelConfigurationFamilyDataSource.h"
#import "MCDDatabaseModelConfigurationSuperHeroesDataSource.h"
#import "NSFileManager+ModularCoreData.h"


@interface MCDDatabaseMigrationManagerTests : XCTestCase

@end


@implementation MCDDatabaseMigrationManagerTests

- (void)testMigration
{
	for (MCDTestableDatabaseType sourceModelType = MCDTestableDatabaseMain; sourceModelType < MCDTestableDatabaseSecondary; sourceModelType++)
	{
		for (MCDTestableDatabaseType destinationModelType = MCDTestableDatabaseMain; destinationModelType < MCDTestableDatabaseSecondary; destinationModelType++)
		{
			if (sourceModelType == destinationModelType)
			{
				continue;
			}
			
			// Для строгости теста удаляю старый кэш
			[MCDDatabase deleteStoreFileWithName:MCDDatabaseTestFamilyFilename returningError:nil];
			[MCDDatabase deleteStoreFileWithName:MCDDatabaseTestSuperHeroesFilename returningError:nil];
			[[NSFileManager defaultManager] removeItemAtURL:[NSFileManager cacheFileURLWithFileName:MCDDatabaseTestModelPath] error:nil];
			
			// Записываю данные с исходной моделю БД
			MCDDatabase *initialDatabase = [self openDatabaseWithDatabaseType:sourceModelType];
			MCDDatabaseModel *migrationSourceModel = initialDatabase.dbModel;
			[initialDatabase.writeContext testFillContextWithTestManagedObjects];
			[initialDatabase resetCoreDataStack];
			
			// Пытаюсь открыть хранилище с измененной моделью БД (здесь должна выполниться миграция)
			MCDDatabase *updatedDatabase = [self openDatabaseWithDatabaseType:destinationModelType];
			[updatedDatabase.readContext expectToBeCompletenessAfterMigrationFromModel:migrationSourceModel];
			[updatedDatabase resetCoreDataStack];
		}
	}
}

- (MCDDatabase *)openDatabaseWithDatabaseType:(MCDTestableDatabaseType)databaseType
{
	// Конфигурация БД
	MCDDatabaseModel *model = [MCDDatabaseModel testableModelWithType:databaseType];

	MCDDatabaseConfiguration *configuration = [MCDDatabaseConfiguration configurationWithModelFileURL:[NSFileManager cacheFileURLWithFileName:MCDDatabaseTestModelPath]];
	
	// Создание и открытие БД
	MCDDatabase *database = [MCDDatabase new];
	database.databaseConfiguration = configuration;
	database.dbModel = model;
	XCTestExpectation *openExpectation = [[XCTestExpectation alloc] initWithDescription:@"Database open expectation"];
	[database open:^(NSError *error) {
		[openExpectation fulfill];
	}];
	[self waitForExpectations:@[openExpectation] timeout:1];
	
	return database;
}

@end
