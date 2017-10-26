//
//  MCDDatabaseTests.m
//  ModularCoreData
//
//  Created by Vladimir Ozerov on 13/07/2017.
//  Copyright © 2017 SberTech. All rights reserved.
//

#import "MCDDatabase+Private.h"
#import "MCDDatabaseConfiguration.h"
#import "MCDDatabaseModel+Tests.h"
#import "MCDDatabaseContext+Tests.h"
#import "MCDDatabaseModelConfigurationFamilyDataSource.h"
#import "MCDDatabaseModelConfigurationSuperHeroesDataSource.h"
#import "NSFileManager+ModularCoreData.h"


@interface MCDDatabaseTests : XCTestCase

@property (nonatomic, strong) MCDDatabase *database;

@end


@implementation MCDDatabaseTests

- (void)setUp
{
	[super setUp];
	
	// Конфигурируем стек CoreData
	self.database = [MCDDatabase new];
	self.database.databaseConfiguration = [MCDDatabaseConfiguration configurationWithModelFileURL:[NSFileManager cacheFileURLWithFileName:MCDDatabaseTestModelPath]];
	self.database.dbModel = [MCDDatabaseModel testableModelWithType:MCDTestableDatabaseMainExtended];

	XCTestExpectation *openExpectation = [[XCTestExpectation alloc] initWithDescription:@"Database open expectation"];
	[self.database open:^(NSError *error) {
		[openExpectation fulfill];
	}];
	[self waitForExpectations:@[openExpectation] timeout:1];
}

- (void)tearDown
{
	self.database = nil;
	[MCDDatabase deleteStoreFileWithName:MCDDatabaseTestFamilyFilename returningError:nil];
	[MCDDatabase deleteStoreFileWithName:MCDDatabaseTestSuperHeroesFilename returningError:nil];
	[[NSFileManager defaultManager] removeItemAtURL:[NSFileManager cacheFileURLWithFileName:MCDDatabaseTestModelPath] error:nil];
	
	[super tearDown];
}

- (void)testOpen
{
	expect(self.database.ready).to.beTruthy();
	expect(self.database.persistentStoreSyncQueue).notTo.beNil();

	NSArray *allEntries = [self.database.readContext testGetAllManagedObjects];
	expect(allEntries).to.haveCount(0);
}

- (void)testResetCoreDataStack
{
	expect(self.database.coordinator).notTo.beNil();
	expect(self.database.readContext).notTo.beNil();
	expect(self.database.writeContext).notTo.beNil();
	
	[self.database resetCoreDataStack];
	expect(self.database.coordinator).to.beNil();
	expect(self.database.readContext).to.beNil();
	expect(self.database.writeContext).to.beNil();
	
	NSError *error = nil;
	[self.database setupPersistentStoreCoordinator:&error];
	expect(error).to.beNil();
	expect(self.database.coordinator).notTo.beNil();
	expect(self.database.readContext).notTo.beNil();
	expect(self.database.writeContext).notTo.beNil();
}

- (void)testWriteEntries
{
	[self.database.writeContext testFillContextWithTestManagedObjects];
	
	NSArray *allEntries = [self.database.readContext testGetAllManagedObjects];
	expect(allEntries).to.haveCount(10);
	
	[self.database.readContext expectToBeCompleteness];
}

- (void)testDeleteStoreFile
{
	[self.database.writeContext testFillContextWithTestManagedObjects];

	BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:[NSFileManager cacheFileURLWithFileName:MCDDatabaseTestFamilyFilename].path];
	expect(fileExist).to.beTruthy();
	
	NSError *error = nil;
	[MCDDatabase deleteStoreFileWithName:MCDDatabaseTestFamilyFilename returningError:&error];
	expect(error).to.beNil();
	
	fileExist = [[NSFileManager defaultManager] fileExistsAtPath:[NSFileManager cacheFileURLWithFileName:MCDDatabaseTestFamilyFilename].path];
	expect(fileExist).to.beFalsy();
}

@end
