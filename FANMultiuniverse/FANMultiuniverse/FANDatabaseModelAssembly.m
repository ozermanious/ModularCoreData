//
//  FANDatabaseModelAssembly.m
//  FANMultiuniverse
//
//  Created by Vladimir Ozerov on 06/10/2017.
//  Copyright © 2017 FANs. All rights reserved.
//

#import "FANDatabaseModelAssembly.h"
#import "ADVMOVillain+Multiuniverse.h"
#import "FANMOUniverse.h"

@import ADVCore;


NSString *const FANDatabaseModelAssemblyIdentifier = @"AdminAssembly";


@implementation FANDatabaseModelAssembly

#pragma mark - MCDDatabaseModelAssemblyProtocol


+ (NSString *)assemblyIdentifier
{
	return FANDatabaseModelAssemblyIdentifier;
}

+ (void)appendEntitiesForDatabaseModel:(MCDDatabaseModel *)databaseModel
{
	NSArray<Class<MCDDatabaseEntityDataSource>> *entityList = @[
		[ADVMOVillainMultiuniverseExtension class],
		[FANMOUniverse class]
	];

	MCDDatabaseModelConfiguration *configuration = databaseModel.configs[MBLDatabaseMainConfigurationName];
	[configuration.entitiesDS addObjectsFromArray:entityList];
}

+ (NSSet<NSString *> *)requiredAssemblyIdentifierSet
{
	return [NSSet setWithObject:ADVDatabaseModelAssemblyIdentifier];
}

@end
