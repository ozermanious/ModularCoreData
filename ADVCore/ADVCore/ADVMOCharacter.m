//
//  ADVMOCharacter.m
//  ADVCore
//
//  Created by Vladimir Ozerov on 06/10/2017.
//  Copyright © 2017 Crutches Bicycles. All rights reserved.
//

#import "ADVMOCharacter.h"


@implementation ADVMOCharacter

@dynamic name;
@dynamic portrait;


#pragma mark - MCDDatabaseEntityDataSource

+ (NSEntityDescription *)entityForDatabaseModel:(MCDDatabaseModel *)model withEntities:(NSDictionary<NSString *, NSEntityDescription *> *)entities
{
	NSEntityDescription *characterEntity = makeDbEntity(@"ADVMOCharacter", @[
		makeDbAttr(@"name",     NSStringAttributeType,        nil),
		makeDbAttr(@"portrait", NSTransformableAttributeType, nil)
	]);
	characterEntity.abstract = YES;
	return characterEntity;
}

+ (void)databaseModel:(MCDDatabaseModel *)model bindSubentities:(NSDictionary<NSString *, NSEntityDescription *> *)entities
{
	NSEntityDescription *characterEntity = entities[@"ADVMOCharacter"];
	NSEntityDescription *visitorEntity   = entities[@"ADVMOVillain"];
	NSEntityDescription *speakerEntity   = entities[@"ADVMOHero"];
	characterEntity.subentities = @[
		visitorEntity,
		speakerEntity
	];
}

@end
