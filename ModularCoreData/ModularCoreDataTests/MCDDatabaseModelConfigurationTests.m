//
//  MCDDatabaseModelConfigurationTests.m
//  ModularCoreData
//
//  Created by Vladimir Ozerov on 12/07/2017.
//  Copyright © 2017 SberTech. All rights reserved.
//

#import "MCDDatabaseModelConfiguration+Private.h"
#import "MCDDatabaseModelConfigurationFamilyDataSource.h"
#import "MCDDatabaseModelConfigurationSuperHeroesDataSource.h"


@interface MCDDatabaseModelConfigurationTests : XCTestCase

@property (nonatomic, strong) MCDDatabaseModelConfiguration *configuration;

@property (nonatomic, copy) NSString *storeType;
@property (nonatomic, copy) NSString *storeFileName;
@property (nonatomic, copy) NSDictionary *options;
@property (nonatomic, copy) NSArray *dataSourceList;

@end


@implementation MCDDatabaseModelConfigurationTests

- (void)setUp
{
	[super setUp];
	
	self.storeType = NSBinaryStoreType;
	self.storeFileName = @"BinaryStore";
	self.options = @{ NSFileProtectionKey: NSFileProtectionCompleteUntilFirstUserAuthentication };
	self.dataSourceList = @[
		[MCDDatabaseModelConfigurationFamilyDataSource class],
		[MCDDatabaseModelConfigurationSuperHeroesDataSource class],
	];
	
	self.configuration = [MCDDatabaseModelConfiguration configWithType:self.storeType
																  file:self.storeFileName
															   options:self.options
															  entities:self.dataSourceList];
	[self.configuration commitInitialParameters];
}

- (void)tearDown
{
	self.configuration = nil;

	self.storeType = nil;
	self.storeFileName = nil;
	self.options = nil;
	
	[super tearDown];
}

- (void)testConfiguration
{
	expect(self.configuration).notTo.beNil();
	expect(self.configuration.storeType).to.equal(self.storeType);
	expect(self.configuration.storeFileName).to.equal(self.storeFileName);
	expect(self.configuration.options).to.equal(self.options);
	expect(self.configuration.entitiesDS).to.equal(self.dataSourceList);
}

- (void)testRestoreInitialParameters
{
	NSString *newStoreType = NSSQLiteStoreType;
	NSString *newStoreFileName = @"SQLiteStore";
	NSDictionary *newOptions = @{ NSFileProtectionKey: NSFileProtectionComplete };

	self.configuration.storeType = newStoreType;
	self.configuration.storeFileName = newStoreFileName;
	self.configuration.options = newOptions;
	
	expect(self.configuration.storeType).to.equal(newStoreType);
	expect(self.configuration.storeFileName).to.equal(newStoreFileName);
	expect(self.configuration.options).to.equal(newOptions);
	
	[self.configuration restoreInitialParameters];

	expect(self.configuration.storeType).to.equal(self.storeType);
	expect(self.configuration.storeFileName).to.equal(self.storeFileName);
	expect(self.configuration.options).to.equal(self.options);
	expect(self.configuration.entitiesDS).to.equal(self.dataSourceList);
}

@end
