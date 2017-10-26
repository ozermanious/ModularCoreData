//
//  FANMOUniverse.m
//  FANMultiuniverse
//
//  Created by Vladimir Ozerov on 06/10/2017.
//  Copyright © 2017 FANs. All rights reserved.
//

#import "FANMOUniverse.h"


@implementation FANMOUniverse

@dynamic name;
@dynamic isOriginal;
@dynamic characterSet;
@dynamic kingdomSet;
@dynamic dwellingSet;


#pragma mark - MCDDatabaseEntityDataSource

+ (NSEntityDescription *)entityForDatabaseModel:(MCDDatabaseModel *)model withEntities:(NSDictionary<NSString *, NSEntityDescription *> *)entities
{
	NSEntityDescription *partnerEntity = makeDbEntity(@"FANMOUniverse", @[
		makeDbAttr(@"name",       NSStringAttributeType,  nil),
		makeDbAttr(@"isOriginal", NSBooleanAttributeType, nil)
	]);
	return partnerEntity;
}

+ (void)databaseModel:(MCDDatabaseModel *)model addRelationsForEntities:(NSDictionary<NSString *,NSEntityDescription *> *)entities
{
	NSEntityDescription *universeEntity  = entities[@"FANMOUniverse"];
	NSEntityDescription *characterEntity = entities[@"ADVMOCharacter"];
	NSEntityDescription *kingdomEntity   = entities[@"ADVMOKingdom"];
	NSEntityDescription *dwellingEntity  = entities[@"ADVMODwelling"];

	appendDbRelationships(universeEntity, @[
		makeDbRelation(@"characterSet", characterEntity, DB_TO_MANY, nil),
		makeDbRelation(@"kingdomSet",   kingdomEntity,   DB_TO_MANY, nil),
		makeDbRelation(@"dwellingSet",  dwellingEntity,  DB_TO_MANY, nil)
	]);
	appendDbRelationships(characterEntity, @[
		makeDbRelation(@"universe", universeEntity, DB_TO_ONE, nil)
	]);
	appendDbRelationships(kingdomEntity, @[
		makeDbRelation(@"universe", universeEntity, DB_TO_ONE, nil)
	]);
	appendDbRelationships(dwellingEntity, @[
		makeDbRelation(@"universe", universeEntity, DB_TO_ONE, nil)
	]);

	pairDbRelationships(universeEntity, @"characterSet", characterEntity, @"universe");
	pairDbRelationships(universeEntity, @"kingdomSet",   kingdomEntity, @"universe");
	pairDbRelationships(universeEntity, @"dwellingSet",  dwellingEntity, @"universe");
}

@end
