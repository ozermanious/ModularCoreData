//
//  MCDDatabaseModelConfigurationSuperHeroesDataSource.m
//  ModularCoreData
//
//  Created by Vladimir Ozerov on 10/07/2017.
//  Copyright © 2017 SberTech. All rights reserved.
//

#import "MCDDatabaseModelConfigurationSuperHeroesDataSource.h"
#import "NSPredicate+DatabaseTests.h"
#import "NSManagedObject+DatabaseTests.h"
#import "MCDDatabaseModel+Tests.h"
#import "MCDDatabaseContext+Tests.h"


NSString *const MCDDatabaseTestSuperHeroesFilename = @"SuperHeroesTestDatabase";
NSString *const MCDDatabaseTestSuperHeroesConfiguration = @"Super Heroes";

static NSString *const MCDDatabaseTestEntityUniverse  = @"Universe";
static NSString *const MCDDatabaseTestEntitySuperHero = @"SuperHero";

static NSString *const MCDDatabaseTestAttributeName       = @"name";
static NSString *const MCDDatabaseTestAttributeStudio     = @"studio";
static NSString *const MCDDatabaseTestAttributeSuperpower = @"superpower";


@implementation MCDDatabaseModelConfigurationSuperHeroesDataSource

#pragma mark - MCDDatabaseEntityDataSource

+ (NSArray<NSEntityDescription*> *)entityListForDatabaseModel:(MCDDatabaseModel *)model withEntities:(NSDictionary<NSString *, NSEntityDescription *> *)entities
{
	NSEntityDescription *entityUniverse = makeDbEntity(MCDDatabaseTestEntityUniverse, @[
		makeDbAttr(MCDDatabaseTestAttributeName,   NSStringAttributeType, nil),
		makeDbAttr(MCDDatabaseTestAttributeStudio, NSStringAttributeType, nil)
	]);
	NSEntityDescription *entitySuperHero = makeDbEntity(MCDDatabaseTestEntitySuperHero, @[
		makeDbAttr(MCDDatabaseTestAttributeName,       NSStringAttributeType, nil),
		makeDbAttr(MCDDatabaseTestAttributeSuperpower, NSStringAttributeType, nil)
	]);

	return @[
		entityUniverse,
		entitySuperHero
	];
}

+ (void)databaseModel:(MCDDatabaseModel *)model addRelationsForEntities:(NSDictionary<NSString *, NSEntityDescription *> *)entities
{
	NSEntityDescription *entityUniverse  = entities[MCDDatabaseTestEntityUniverse];
	NSEntityDescription *entitySuperHero = entities[MCDDatabaseTestEntitySuperHero];

	NSRelationshipDescription *relationUniverseSuperHero = makeDbRelation(@"superHeroes", entitySuperHero, NO,  nil);
	NSRelationshipDescription *relationSuperHeroUniverse = makeDbRelation(@"universe",    entityUniverse,  YES, nil);
	appendDbRelationships(entityUniverse,  @[relationUniverseSuperHero]);
	appendDbRelationships(entitySuperHero, @[relationSuperHeroUniverse]);
	pairDbRelationships(entityUniverse, @"superHeroes", entitySuperHero, @"universe");
}

+ (void)databaseModel:(MCDDatabaseModel *)model bindSubentities:(NSDictionary<NSString *,NSEntityDescription *> *)entities
{
	NSEntityDescription *entityUniverse  = entities[MCDDatabaseTestEntityUniverse];
	NSEntityDescription *entitySuperHero = entities[MCDDatabaseTestEntitySuperHero];
	[NSManagedObject testMakeManagedObjectClassForEntity:entityUniverse];
	[NSManagedObject testMakeManagedObjectClassForEntity:entitySuperHero];
}


#pragma mark - MCDDatabaseModelConfigurationTestDataSource

+ (void)makeManagedObjectsInContext:(MCDDatabaseContext *)context
{
	NSManagedObject *DC = [NSManagedObject testManagedObjectWithEntityName:MCDDatabaseTestEntityUniverse
															mainParameters:@{ MCDDatabaseTestAttributeName: @"Gotham" }
														   otherParameters:@{ MCDDatabaseTestAttributeStudio: @"DC Comics" }
																 inContext:context];

	NSManagedObject *batman = [NSManagedObject testManagedObjectWithEntityName:MCDDatabaseTestEntitySuperHero
																mainParameters:@{ MCDDatabaseTestAttributeName: @"Bruce Wayne" }
															   otherParameters:@{ MCDDatabaseTestAttributeSuperpower: @"BatMoney" }
																	 inContext:context];
	[batman setValue:DC forKey:@"universe"];

	NSManagedObject *robin = [NSManagedObject testManagedObjectWithEntityName:MCDDatabaseTestEntitySuperHero
															   mainParameters:@{ MCDDatabaseTestAttributeName: @"Robin" }
															  otherParameters:@{ MCDDatabaseTestAttributeSuperpower: @"Batman's friend" }
																	inContext:context];
	[robin setValue:DC forKey:@"universe"];

	NSManagedObject *Marvel = [NSManagedObject testManagedObjectWithEntityName:MCDDatabaseTestEntityUniverse
																mainParameters:@{ MCDDatabaseTestAttributeName: @"Avengers" }
															   otherParameters:@{ MCDDatabaseTestAttributeStudio: @"Marvel" }
																	 inContext:context];

	NSManagedObject *manOfSteel = [NSManagedObject testManagedObjectWithEntityName:MCDDatabaseTestEntitySuperHero
																	mainParameters:@{ MCDDatabaseTestAttributeName: @"Clark Kent" }
																   otherParameters:@{ MCDDatabaseTestAttributeSuperpower: @"Eye-Flame" }
																		 inContext:context];
	[manOfSteel setValue:Marvel forKey:@"universe"];

	NSManagedObject *hulk = [NSManagedObject testManagedObjectWithEntityName:MCDDatabaseTestEntitySuperHero
															  mainParameters:@{ MCDDatabaseTestAttributeName: @"Hulk" }
															 otherParameters:@{ MCDDatabaseTestAttributeSuperpower: @"Hulk to break!!!" }
																   inContext:context];
	[hulk setValue:Marvel forKey:@"universe"];
}

+ (void)expectCompletenessInContext:(MCDDatabaseContext *)context
{
	MCDDatabaseModel *model = (id)context.persistentStoreCoordinator.managedObjectModel;
	[self expectCompletenessInContext:context afterMigrationFromModel:model];
}

+ (void)expectCompletenessInContext:(MCDDatabaseContext *)context afterMigrationFromModel:(MCDDatabaseModel *)migrationSourceModel
{
	NSManagedObject *DC         = [context entry:NSClassFromString(@"Universe")  withPredicate:[NSPredicate equalPredicateForKey:MCDDatabaseTestAttributeName value:@"Gotham"]];
	NSManagedObject *batman     = [context entry:NSClassFromString(@"SuperHero") withPredicate:[NSPredicate equalPredicateForKey:MCDDatabaseTestAttributeName value:@"Bruce Wayne"]];
	NSManagedObject *robin      = [context entry:NSClassFromString(@"SuperHero") withPredicate:[NSPredicate equalPredicateForKey:MCDDatabaseTestAttributeName value:@"Robin"]];
	NSManagedObject *Marvel     = [context entry:NSClassFromString(@"Universe")  withPredicate:[NSPredicate equalPredicateForKey:MCDDatabaseTestAttributeName value:@"Avengers"]];
	NSManagedObject *manOfSteel = [context entry:NSClassFromString(@"SuperHero") withPredicate:[NSPredicate equalPredicateForKey:MCDDatabaseTestAttributeName value:@"Clark Kent"]];
	NSManagedObject *hulk       = [context entry:NSClassFromString(@"SuperHero") withPredicate:[NSPredicate equalPredicateForKey:MCDDatabaseTestAttributeName value:@"Hulk"]];

	expect(DC).notTo.beNil();
	expect(batman).notTo.beNil();
	expect(robin).notTo.beNil();
	expect(Marvel).notTo.beNil();
	expect(manOfSteel).notTo.beNil();
	expect(hulk).notTo.beNil();
	
	[DC expectToPropertiesBeEqual:@{
		MCDDatabaseTestAttributeName: @"Gotham",
		MCDDatabaseTestAttributeStudio: @"DC Comics",
		@"superHeroes": [NSSet setWithObjects:batman, robin, nil]
	}];
	[batman expectToPropertiesBeEqual:@{
		MCDDatabaseTestAttributeName: @"Bruce Wayne",
		MCDDatabaseTestAttributeSuperpower: @"BatMoney",
		@"universe": DC
	}];
	[robin expectToPropertiesBeEqual:@{
		MCDDatabaseTestAttributeName: @"Robin",
		MCDDatabaseTestAttributeSuperpower: @"Batman's friend",
		@"universe": DC
	}];
	[Marvel expectToPropertiesBeEqual:@{
		MCDDatabaseTestAttributeName: @"Avengers",
		MCDDatabaseTestAttributeStudio: @"Marvel",
		@"superHeroes": [NSSet setWithObjects:manOfSteel, hulk, nil]
	}];
	[manOfSteel expectToPropertiesBeEqual:@{
		MCDDatabaseTestAttributeName: @"Clark Kent",
		MCDDatabaseTestAttributeSuperpower: @"Eye-Flame",
		@"universe": Marvel
	}];
	[hulk expectToPropertiesBeEqual:@{
		MCDDatabaseTestAttributeName: @"Hulk",
		MCDDatabaseTestAttributeSuperpower: @"Hulk to break!!!",
		@"universe": Marvel
	}];
}

+ (NSString *)JSONCacheNodeFormatSubstringWithModel:(MCDDatabaseModel *)model
{
	return @"Universe { superHeroes }";
}

@end
