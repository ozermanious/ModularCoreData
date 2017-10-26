//
//  ADVMOKingdom.m
//  ADVCore
//
//  Created by Vladimir Ozerov on 12/10/2017.
//  Copyright © 2017 Crutches Bicycles. All rights reserved.
//

#import "ADVMOKingdom.h"


@implementation ADVMOKingdom

@dynamic name;
@dynamic population;
@dynamic princess;


#pragma mark - MCDDatabaseEntityDataSource

+ (NSEntityDescription *)entityForDatabaseModel:(MCDDatabaseModel *)model withEntities:(NSDictionary<NSString *, NSEntityDescription *> *)entities
{
	NSEntityDescription *kingdomEntity = makeDbEntity(@"ADVMOKingdom", @[
		makeDbAttr(@"name", NSStringAttributeType, nil),
		makeDbAttr(@"population", NSDecimalAttributeType, nil)
	]);
	return kingdomEntity;
}

+ (void)databaseModel:(MCDDatabaseModel *)model addRelationsForEntities:(NSDictionary<NSString *,NSEntityDescription *> *)entities
{
	NSEntityDescription *kingdomEntity  = entities[@"ADVMOKingdom"];
	NSEntityDescription *princessEntity = entities[@"ADVMOPrincess"];
	
	appendDbRelationships(kingdomEntity, @[
		makeDbRelation(@"princess", princessEntity, DB_TO_ONE, nil)
	]);
	appendDbRelationships(princessEntity, @[
		makeDbRelation(@"kingdom", kingdomEntity, DB_TO_ONE, nil)
	]);

	pairDbRelationships(kingdomEntity, @"princess", princessEntity, @"kingdom");
}

@end
