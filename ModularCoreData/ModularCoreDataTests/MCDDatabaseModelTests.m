//
//  MCDDatabaseModelTests.m
//  ModularCoreData
//
//  Created by Vladimir Ozerov on 10/07/2017.
//  Copyright © 2017 SberTech. All rights reserved.
//

#import "MCDDatabaseModel+Tests.h"
#import "MCDDatabaseModelConfigurationFamilyDataSource.h"
#import "MCDDatabaseModelConfigurationSuperHeroesDataSource.h"


@interface MCDDatabaseModelTests : XCTestCase

@end


@implementation MCDDatabaseModelTests

- (void)testModelCreation
{
	MCDDatabaseModel *modelMain = [MCDDatabaseModel testableModelWithType:MCDTestableDatabaseMain];
	expect([modelMain entitiesForConfiguration:MCDDatabaseTestFamilyConfiguration].count).to.equal(4);
	expect([modelMain entitiesForConfiguration:MCDDatabaseTestSuperHeroesConfiguration].count).to.equal(2);

	MCDDatabaseModel *modelMainParedDown = [MCDDatabaseModel testableModelWithType:MCDTestableDatabaseMainParedDown];
	expect([modelMainParedDown entitiesForConfiguration:MCDDatabaseTestFamilyConfiguration].count).to.equal(3);
	expect([modelMainParedDown entitiesForConfiguration:MCDDatabaseTestSuperHeroesConfiguration].count).to.equal(2);

	MCDDatabaseModel *modelMainExtended = [MCDDatabaseModel testableModelWithType:MCDTestableDatabaseMainExtended];
	expect([modelMainExtended entitiesForConfiguration:MCDDatabaseTestFamilyConfiguration].count).to.equal(5);
	expect([modelMainExtended entitiesForConfiguration:MCDDatabaseTestSuperHeroesConfiguration].count).to.equal(2);

	MCDDatabaseModel *modelMainModified = [MCDDatabaseModel testableModelWithType:MCDTestableDatabaseMainModified];
	expect([modelMainModified entitiesForConfiguration:MCDDatabaseTestFamilyConfiguration].count).to.equal(4);
	expect([modelMainModified entitiesForConfiguration:MCDDatabaseTestSuperHeroesConfiguration].count).to.equal(2);
	expect(modelMainModified).notTo.equal(modelMain);
}

/**
 Проверяю, что две модели, созданные с одинаковой конфигурацией равны (одинаково применимы к хранилищу БД)
 */
- (void)testModelEqual
{
	for (MCDTestableDatabaseType databaseType = MCDTestableDatabaseMain; databaseType < MCDTestableDatabaseSecondary; databaseType++)
	{
		MCDDatabaseModel *model1 = [MCDDatabaseModel testableModelWithType:databaseType];
		MCDDatabaseModel *model2 = [MCDDatabaseModel testableModelWithType:databaseType];

		expect(model1).toNot.beIdenticalTo(model2);
		expect(model1).to.equal(model2);
	}
}

/**
 Проверяю, что скопированная модель является валидной
 */
- (void)testModelNSCopying
{
	for (MCDTestableDatabaseType databaseType = MCDTestableDatabaseMain; databaseType < MCDTestableDatabaseSecondary; databaseType++)
	{
		MCDDatabaseModel *model = [MCDDatabaseModel testableModelWithType:databaseType];
		MCDDatabaseModel *copyOfModel = [model copy];
		
		expect(model).toNot.beIdenticalTo(copyOfModel);
		expect(model).to.equal(copyOfModel);
	}
}

@end
