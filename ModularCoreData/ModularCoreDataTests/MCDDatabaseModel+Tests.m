//
//  MCDDatabaseModel+Tests.m
//  ModularCoreData
//
//  Created by Vladimir Ozerov on 10/07/2017.
//  Copyright © 2017 SberTech. All rights reserved.
//

#import "MCDDatabaseModel+Tests.h"
#import "MCDDatabaseModel+Private.h"
#import "MCDDatabaseModelConfigurationFamilyDataSource.h"
#import "MCDDatabaseModelConfigurationSuperHeroesDataSource.h"
#import <objc/runtime.h>


NSString *const MCDDatabaseTestModelPath = @"TestModel.bin";


@implementation MCDDatabaseModel (Tests)

static char typeKey;

- (void)setTestableDatabaseType:(MCDTestableDatabaseType)testableDatabaseType
{
	objc_setAssociatedObject(self, &typeKey, @(testableDatabaseType), OBJC_ASSOCIATION_ASSIGN);
}

- (MCDTestableDatabaseType)testableDatabaseType
{
	NSNumber *databaseTypeNumber = objc_getAssociatedObject(self, &typeKey);
	return (MCDTestableDatabaseType)databaseTypeNumber.unsignedIntegerValue;
}

+ (instancetype)testableModelWithType:(MCDTestableDatabaseType)databaseType
{
	MCDDatabaseModel *model = [MCDDatabaseModel new];

	MCDDatabaseModelConfiguration *familyConfig = [MCDDatabaseModelConfiguration configWithType:NSSQLiteStoreType
																				 file:MCDDatabaseTestFamilyFilename
																			  options:@{ NSFileProtectionKey: NSFileProtectionComplete }
																			 entities:@[ [MCDDatabaseModelConfigurationFamilyDataSource class] ]];
	model.configs[MCDDatabaseTestFamilyConfiguration] = familyConfig;
	
	MCDDatabaseModelConfiguration *familySuperHeroes = [MCDDatabaseModelConfiguration configWithType:NSSQLiteStoreType
																				 file:MCDDatabaseTestSuperHeroesFilename
																			  options:@{ NSFileProtectionKey: NSFileProtectionComplete }
																			 entities:@[ [MCDDatabaseModelConfigurationSuperHeroesDataSource class] ]];
	model.configs[MCDDatabaseTestSuperHeroesConfiguration] = familySuperHeroes;
	
	[model setTestableDatabaseType:databaseType];
	[model applyConfigs];
	return model;
}

- (NSString *)JSONCacheConfigString
{
	NSMutableArray *configSubstringList = [NSMutableArray array];
	for (MCDDatabaseModelConfiguration *configuration in self.configs.allValues)
	{
		for (Class<MCDDatabaseModelConfigurationTestDataSource> dataSource in configuration.entitiesDS)
		{
			NSString *configSubstring = [dataSource JSONCacheNodeFormatSubstringWithModel:self];
			if (configSubstring)
			{
				[configSubstringList addObject:configSubstring];
			}
		}
	}

	if (!configSubstringList.count)
	{
		return nil;
	}

	NSString *configString = [NSString stringWithFormat:@"{ %@ }", [configSubstringList componentsJoinedByString:@", "]];
	return configString;
}

@end
