//
//  ADVMODwelling.m
//  ADVCore
//
//  Created by Vladimir Ozerov on 06/10/2017.
//  Copyright © 2017 Crutches Bicycles. All rights reserved.
//

#import "ADVMODwelling.h"


@implementation ADVMODwelling

@dynamic name;
@dynamic location;
@dynamic heroSet;
@dynamic villain;


#pragma mark - MCDDatabaseEntityDataSource

+ (NSEntityDescription *)entityForDatabaseModel:(MCDDatabaseModel *)model withEntities:(NSDictionary<NSString *, NSEntityDescription *> *)entities
{
	NSEntityDescription *dwellingEntity = makeDbEntity(@"ADVMODwelling", @[
		makeDbAttr(@"name",     NSStringAttributeType, nil),
		makeDbAttr(@"location", NSStringAttributeType, nil)
	]);
	return dwellingEntity;
}

+ (void)databaseModel:(MCDDatabaseModel *)model addRelationsForEntities:(NSDictionary<NSString *,NSEntityDescription *> *)entities
{
	NSEntityDescription *dwellingEntity = entities[@"ADVMODwelling"];
	NSEntityDescription *heroEntity     = entities[@"ADVMOHero"];
	NSEntityDescription *villainEntity  = entities[@"ADVMOVillain"];
	
	appendDbRelationships(dwellingEntity, @[
		makeDbRelation(@"heroSet", heroEntity,    DB_TO_MANY, nil),
		makeDbRelation(@"villain", villainEntity, DB_TO_ONE,  nil)
	]);
	appendDbRelationships(villainEntity, @[
		makeDbRelation(@"lair", dwellingEntity, DB_TO_ONE, nil)
	]);
	appendDbRelationships(heroEntity, @[
		makeDbRelation(@"home", dwellingEntity, DB_TO_ONE, nil)
	]);

	pairDbRelationships(dwellingEntity, @"heroSet", heroEntity,    @"home");
	pairDbRelationships(dwellingEntity, @"villain", villainEntity, @"lair");
}

@end
