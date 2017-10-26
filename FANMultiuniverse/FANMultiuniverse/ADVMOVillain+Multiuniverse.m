//
//  ADVMOVillain+Admin.m
//  FANMultiuniverse
//
//  Created by Vladimir Ozerov on 06/10/2017.
//  Copyright © 2017 FANs. All rights reserved.
//

#import "ADVMOVillain+Multiuniverse.h"


@implementation ADVMOVillain (Multiuniverse)

@dynamic isAlterHero;

@end


@implementation ADVMOVillainMultiuniverseExtension


#pragma mark - MCDDatabaseEntityDataSource

+ (NSEntityDescription *)entityForDatabaseModel:(MCDDatabaseModel *)model withEntities:(NSDictionary<NSString *, NSEntityDescription *> *)entities
{
	NSArray<NSPropertyDescription *> *addPropertyList = @[
		makeDbAttr(@"isAlterHero", NSBooleanAttributeType, nil)
	];

	NSEntityDescription *villainEntity = entities[@"ADVMOVillain"];
	villainEntity.properties = [villainEntity.properties arrayByAddingObjectsFromArray:addPropertyList];

	return nil;
}

@end
