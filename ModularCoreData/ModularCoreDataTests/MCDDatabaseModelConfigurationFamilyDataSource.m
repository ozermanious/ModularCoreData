//
//  MCDDatabaseModelConfigurationFamilyDataSource.m
//  ModularCoreData
//
//  Created by Vladimir Ozerov on 10/07/2017.
//  Copyright © 2017 SberTech. All rights reserved.
//

#import "MCDDatabaseModelConfigurationFamilyDataSource.h"
#import "NSManagedObject+DatabaseTests.h"
#import "MCDDatabaseModel+Tests.h"
#import "MCDDatabaseContext+Tests.h"


NSString *const MCDDatabaseTestFamilyFilename = @"FamilyTestDatabase";
NSString *const MCDDatabaseTestFamilyConfiguration = @"Family";

static NSString *const MCDDatabaseTestEntityHuman    = @"Human";
static NSString *const MCDDatabaseTestEntityMother   = @"Mother";
static NSString *const MCDDatabaseTestEntityFather   = @"Father";
static NSString *const MCDDatabaseTestEntitySon      = @"Son";
static NSString *const MCDDatabaseTestEntityDaughter = @"Daughter";

static NSString *const MCDDatabaseTestAttributeUid       = @"uid";
static NSString *const MCDDatabaseTestAttributeName      = @"name";
static NSString *const MCDDatabaseTestAttributeHairColor = @"hairColor";
static NSString *const MCDDatabaseTestAttributeSalary    = @"salary";
static NSString *const MCDDatabaseTestAttributeToysCount = @"toysCount";


@implementation MCDDatabaseModelConfigurationFamilyDataSource

+ (BOOL)sonExistsWithDatabaseType:(MCDTestableDatabaseType)databaseType
{
	return (databaseType == MCDTestableDatabaseMainExtended || databaseType == MCDTestableDatabaseMain);
}

+ (BOOL)daughterExistsWithDatabaseType:(MCDTestableDatabaseType)databaseType
{
	return (databaseType == MCDTestableDatabaseMainExtended || databaseType == MCDTestableDatabaseMainModified);
}


#pragma mark - MCDDatabaseEntityDataSource

+ (NSArray<NSEntityDescription*> *)entityListForDatabaseModel:(MCDDatabaseModel *)model withEntities:(NSDictionary<NSString *, NSEntityDescription *> *)entities
{
	MCDTestableDatabaseType databaseType = model.testableDatabaseType;
	BOOL sonExists      = [self sonExistsWithDatabaseType:databaseType];
	BOOL daughterExists = [self daughterExistsWithDatabaseType:databaseType];

	NSMutableArray<NSEntityDescription*> *entityList = [NSMutableArray array];

	NSEntityDescription *humanEntity = makeDbEntity(MCDDatabaseTestEntityHuman, @[
		makeDbAttr(MCDDatabaseTestAttributeUid,  NSStringAttributeType, nil),
		makeDbAttr(MCDDatabaseTestAttributeName, NSStringAttributeType, nil)
	]);
	humanEntity.abstract = YES;
	[entityList addObject:humanEntity];
	
	[entityList addObject:makeDbEntity(MCDDatabaseTestEntityMother, @[
		makeDbAttr(MCDDatabaseTestAttributeHairColor, NSStringAttributeType, nil)
	])];
	[entityList addObject:makeDbEntity(MCDDatabaseTestEntityFather, @[
		makeDbAttr(MCDDatabaseTestAttributeSalary, NSDecimalAttributeType, nil)
	])];
	
	if (sonExists)
	{
		[entityList addObject:makeDbEntity(MCDDatabaseTestEntitySon, @[
			makeDbAttr(MCDDatabaseTestAttributeToysCount, NSDecimalAttributeType, nil)
		])];
	}
	if (daughterExists)
	{
		[entityList addObject:makeDbEntity(MCDDatabaseTestEntityDaughter, @[
			makeDbAttr(MCDDatabaseTestAttributeToysCount, NSDecimalAttributeType, nil)
		])];
	}
	
	return [entityList copy];
}

+ (void)databaseModel:(MCDDatabaseModel *)model addRelationsForEntities:(NSDictionary<NSString *, NSEntityDescription *> *)entities
{
	MCDTestableDatabaseType databaseType = model.testableDatabaseType;
	BOOL sonExists      = [self sonExistsWithDatabaseType:databaseType];
	BOOL daughterExists = [self daughterExistsWithDatabaseType:databaseType];

	NSEntityDescription *entityMother   = entities[MCDDatabaseTestEntityMother];
	NSEntityDescription *entityFather   = entities[MCDDatabaseTestEntityFather];
	NSEntityDescription *entitySon      = entities[MCDDatabaseTestEntitySon];
	NSEntityDescription *entityDaughter = entities[MCDDatabaseTestEntityDaughter];

	// Parents relationships
	NSRelationshipDescription *relationMotherFather = makeDbRelation(@"husband", entityFather, YES, nil);
	NSRelationshipDescription *relationFatherMother = makeDbRelation(@"wife",    entityMother, YES, nil);
	appendDbRelationships(entityMother, @[relationMotherFather]);
	appendDbRelationships(entityFather, @[relationFatherMother]);
	pairDbRelationships(entityMother, @"husband", entityFather, @"wife");

	// Parents/Son relationships
	if (sonExists)
	{
		NSRelationshipDescription *relationMotherSon = makeDbRelation(@"son",    entitySon,    YES, nil);
		NSRelationshipDescription *relationSonMother = makeDbRelation(@"mother", entityMother, YES, nil);
		appendDbRelationships(entityMother, @[relationMotherSon]);
		appendDbRelationships(entitySon,    @[relationSonMother]);
		pairDbRelationships(entityMother, @"son", entitySon, @"mother");

		NSRelationshipDescription *relationFatherSon      = makeDbRelation(@"son",      entitySon,      YES, nil);
		NSRelationshipDescription *relationSonFather      = makeDbRelation(@"father",   entityFather,   YES, nil);
		appendDbRelationships(entityFather, @[relationFatherSon]);
		appendDbRelationships(entitySon,    @[relationSonFather]);
		pairDbRelationships(entityFather, @"son", entitySon, @"father");
	}
	
	// Parents/Daughter relationships
	if (daughterExists)
	{
		NSRelationshipDescription *relationMotherDaughter = makeDbRelation(@"daughter", entityDaughter, YES, nil);
		NSRelationshipDescription *relationDaughterMother = makeDbRelation(@"mother",   entityMother,   YES, nil);
		appendDbRelationships(entityMother,   @[relationMotherDaughter]);
		appendDbRelationships(entityDaughter, @[relationDaughterMother]);
		pairDbRelationships(entityMother, @"daughter", entityDaughter, @"mother");

		NSRelationshipDescription *relationFatherDaughter = makeDbRelation(@"daughter", entityDaughter, YES, nil);
		NSRelationshipDescription *relationDaughterFather = makeDbRelation(@"father",   entityFather,   YES, nil);
		appendDbRelationships(entityFather,   @[relationFatherDaughter]);
		appendDbRelationships(entityDaughter, @[relationDaughterFather]);
		pairDbRelationships(entityFather, @"daughter", entityDaughter, @"father");
	}
	
	// Children relationships
	if (sonExists && daughterExists)
	{
		NSRelationshipDescription *relationSonDaughter = makeDbRelation(@"sister",  entityDaughter, YES, nil);
		NSRelationshipDescription *relationDaughterSon = makeDbRelation(@"brother", entitySon,      YES, nil);
		appendDbRelationships(entitySon,      @[relationSonDaughter]);
		appendDbRelationships(entityDaughter, @[relationDaughterSon]);
		pairDbRelationships(entitySon, @"sister", entityDaughter, @"brother");
	}
}

+ (void)databaseModel:(MCDDatabaseModel *)model bindSubentities:(NSDictionary<NSString *, NSEntityDescription *> *)entities
{
	NSEntityDescription *entityHuman    = entities[MCDDatabaseTestEntityHuman];
	NSEntityDescription *entityMother   = entities[MCDDatabaseTestEntityMother];
	NSEntityDescription *entityFather   = entities[MCDDatabaseTestEntityFather];
	NSEntityDescription *entitySon      = entities[MCDDatabaseTestEntitySon];
	NSEntityDescription *entityDaughter = entities[MCDDatabaseTestEntityDaughter];

	NSMutableArray *subEntities = [NSMutableArray array];
	[subEntities addObject:entityMother];
	[subEntities addObject:entityFather];
	if (entitySon)
	{
		[subEntities addObject:entitySon];
	}
	if (entityDaughter)
	{
		[subEntities addObject:entityDaughter];
	}
	entityHuman.subentities = [subEntities copy];
	
	[NSManagedObject testMakeManagedObjectClassForEntity:entityHuman];
	[NSManagedObject testMakeManagedObjectClassForEntity:entityMother];
	[NSManagedObject testMakeManagedObjectClassForEntity:entityFather];
	[NSManagedObject testMakeManagedObjectClassForEntity:entitySon];
	[NSManagedObject testMakeManagedObjectClassForEntity:entityDaughter];
}


#pragma mark - MCDDatabaseModelConfigurationTestDataSource

+ (void)makeManagedObjectsInContext:(MCDDatabaseContext *)context
{
	MCDDatabaseModel *model = (id)context.persistentStoreCoordinator.managedObjectModel;
	MCDTestableDatabaseType databaseType = model.testableDatabaseType;
	BOOL sonExists      = [self sonExistsWithDatabaseType:databaseType];
	BOOL daughterExists = [self daughterExistsWithDatabaseType:databaseType];

	NSManagedObject *mother = [NSManagedObject testManagedObjectWithEntityName:MCDDatabaseTestEntityMother
																mainParameters:@{ MCDDatabaseTestAttributeUid: @"mother:01" }
															   otherParameters:@{ MCDDatabaseTestAttributeName: @"Мама Галя",
																				  MCDDatabaseTestAttributeHairColor: @"Каштановый" }
																	 inContext:context];

	NSManagedObject *father = [NSManagedObject testManagedObjectWithEntityName:MCDDatabaseTestEntityFather
																mainParameters:@{ MCDDatabaseTestAttributeUid: @"father:01" }
															   otherParameters:@{ MCDDatabaseTestAttributeName: @"Папа Витя",
																				  MCDDatabaseTestAttributeSalary: @30000 }
																	 inContext:context];
	[mother setValue:father forKey:@"husband"];
	
	NSManagedObject *son = nil;
	if (sonExists)
	{
		son = [NSManagedObject testManagedObjectWithEntityName:MCDDatabaseTestEntitySon
												mainParameters:@{ MCDDatabaseTestAttributeUid: @"son:01" }
											   otherParameters:@{ MCDDatabaseTestAttributeName: @"Сын Леша",
																  MCDDatabaseTestAttributeToysCount: @4 }
													 inContext:context];
		[son setValue:mother forKey:@"mother"];
		[son setValue:father forKey:@"father"];
	}

	NSManagedObject *daughter = nil;
	if (daughterExists)
	{
		daughter = [NSManagedObject testManagedObjectWithEntityName:MCDDatabaseTestEntityDaughter
													 mainParameters:@{ MCDDatabaseTestAttributeUid: @"daughter:01" }
													otherParameters:@{ MCDDatabaseTestAttributeName: @"Дочь Таня",
																	   MCDDatabaseTestAttributeToysCount: @213 }
														  inContext:context];
		[daughter setValue:mother forKey:@"mother"];
		[daughter setValue:father forKey:@"father"];
	}
	
	if (sonExists && daughterExists)
	{
		[son setValue:daughter forKey:@"sister"];
	}
}

+ (void)expectCompletenessInContext:(MCDDatabaseContext *)context
{
	MCDDatabaseModel *model = (id)context.persistentStoreCoordinator.managedObjectModel;
	[self expectCompletenessInContext:context afterMigrationFromModel:model];
}

+ (void)expectCompletenessInContext:(MCDDatabaseContext *)context afterMigrationFromModel:(MCDDatabaseModel *)migrationSourceModel
{
	MCDDatabaseModel *model = (id)context.persistentStoreCoordinator.managedObjectModel;
	MCDTestableDatabaseType databaseType = model.testableDatabaseType;
	BOOL sonExists      = [self sonExistsWithDatabaseType:databaseType];
	BOOL daughterExists = [self daughterExistsWithDatabaseType:databaseType];

	MCDTestableDatabaseType migrationDatabaseType = migrationSourceModel.testableDatabaseType;
	BOOL sonWasExisted      = [self sonExistsWithDatabaseType:migrationDatabaseType];
	BOOL daughterWasExisted = [self daughterExistsWithDatabaseType:migrationDatabaseType];

	NSArray<NSManagedObject*> *allMothers = [context allEntries:NSClassFromString(MCDDatabaseTestEntityMother)];
	NSArray<NSManagedObject*> *allFathers = [context allEntries:NSClassFromString(MCDDatabaseTestEntityFather)];
	expect(allMothers).to.haveCount(1);
	expect(allFathers).to.haveCount(1);

	NSMutableDictionary *motherProperties = [@{
		MCDDatabaseTestAttributeUid: @"mother:01",
		MCDDatabaseTestAttributeName: @"Мама Галя",
		MCDDatabaseTestAttributeHairColor: @"Каштановый",
		@"husband": allFathers.firstObject
	} mutableCopy];
	NSMutableDictionary *fatherProperties = [@{
		MCDDatabaseTestAttributeUid: @"father:01",
		MCDDatabaseTestAttributeName: @"Папа Витя",
		MCDDatabaseTestAttributeSalary: @30000,
		@"wife": allMothers.firstObject
	} mutableCopy];
	NSMutableDictionary *sonProperties = [NSMutableDictionary dictionary];
	NSMutableDictionary *daughterProperties = [NSMutableDictionary dictionary];

	NSArray<NSManagedObject*> *allSons = nil;
	NSArray<NSManagedObject*> *allDaughters = nil;
	if (sonExists && sonWasExisted)
	{
		allSons = [context allEntries:NSClassFromString(MCDDatabaseTestEntitySon)];
		expect(allSons).to.haveCount(1);

		sonProperties[MCDDatabaseTestAttributeUid] = @"son:01";
		sonProperties[MCDDatabaseTestAttributeName] = @"Сын Леша";
		sonProperties[MCDDatabaseTestAttributeToysCount] = @4;
		sonProperties[@"mother"] = allMothers.firstObject;
		sonProperties[@"father"] = allFathers.firstObject;
		
		motherProperties[@"son"] = allSons.firstObject;
		fatherProperties[@"son"] = allSons.firstObject;
	}
	if (daughterExists && daughterWasExisted)
	{
		allDaughters = [context allEntries:NSClassFromString(MCDDatabaseTestEntityDaughter)];
		expect(allDaughters).to.haveCount(1);
		
		daughterProperties[MCDDatabaseTestAttributeUid] = @"daughter:01";
		daughterProperties[MCDDatabaseTestAttributeName] = @"Дочь Таня";
		daughterProperties[MCDDatabaseTestAttributeToysCount] = @213;
		daughterProperties[@"mother"] = allMothers.firstObject;
		daughterProperties[@"father"] = allFathers.firstObject;

		motherProperties[@"daughter"] = allDaughters.firstObject;
		fatherProperties[@"daughter"] = allDaughters.firstObject;
	}
	if (sonExists && daughterExists && sonWasExisted && daughterWasExisted)
	{
		sonProperties[@"sister"] = allDaughters.firstObject;
		daughterProperties[@"brother"] = allSons.firstObject;
	}

	[allMothers.firstObject expectToPropertiesBeEqual:[motherProperties copy]];
	[allFathers.firstObject expectToPropertiesBeEqual:[fatherProperties copy]];
	[allSons.firstObject expectToPropertiesBeEqual:[sonProperties copy]];
	[allDaughters.firstObject expectToPropertiesBeEqual:[daughterProperties copy]];
}

+ (NSString *)JSONCacheNodeFormatSubstringWithModel:(MCDDatabaseModel *)model
{
	MCDTestableDatabaseType databaseType = model.testableDatabaseType;
	BOOL sonExists      = [self sonExistsWithDatabaseType:databaseType];
	BOOL daughterExists = [self daughterExistsWithDatabaseType:databaseType];

	if (sonExists && daughterExists)
	{
		return @"Mother { husband, son, daughter }, Father { son, daughter }, Son { sister }";
	}
	else if (sonExists)
	{
		return @"Mother { husband, son }, Father { son }";
	}
	else if (daughterExists)
	{
		return @"Mother { husband, daughter }, Father { daughter }";
	}
	else
	{
		return @"Mother { husband }";
	}
}

@end
