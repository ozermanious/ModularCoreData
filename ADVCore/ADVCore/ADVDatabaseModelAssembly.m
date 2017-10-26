//
//  ADVDatabaseModelAssembly.m
//  ADVCore
//
//  Created by Vladimir Ozerov on 06/10/2017.
//  Copyright © 2017 Crutches Bicycles. All rights reserved.
//

#import "ADVDatabaseModelAssembly.h"
#import "ADVMOCharacter.h"
#import "ADVMOPrincess.h"
#import "ADVMOVillain.h"
#import "ADVMOHero.h"
#import "ADVMOKingdom.h"
#import "ADVMODwelling.h"


NSString *const ADVDatabaseModelAssemblyIdentifier = @"MainAssembly";
NSString *const MBLDatabaseMainConfigurationName = @"MainConfiguration";
static NSString *const MBLDatabaseMainFileName = @"MainStorage";


@implementation ADVDatabaseModelAssembly


#pragma mark - MCDDatabaseModelAssemblyProtocol

+ (NSString *)assemblyIdentifier
{
	return ADVDatabaseModelAssemblyIdentifier;
}

+ (void)appendEntitiesForDatabaseModel:(MCDDatabaseModel *)databaseModel
{
	NSArray<Class<MCDDatabaseEntityDataSource>> *entityList = @[
		[ADVMOCharacter class],
		[ADVMOPrincess class],
		[ADVMOVillain class],
		[ADVMOHero class],
		[ADVMOKingdom class],
		[ADVMODwelling class]
	];
	
	MCDDatabaseModelConfiguration *configuration = [MCDDatabaseModelConfiguration configWithType:NSSQLiteStoreType
																							file:MBLDatabaseMainFileName
																						 options:@{NSFileProtectionKey: NSFileProtectionComplete}
																						entities:entityList];
	databaseModel.configs[MBLDatabaseMainConfigurationName] = configuration;
}

+ (NSSet<NSString *> *)requiredAssemblyIdentifierSet
{
	return nil;
}

@end
