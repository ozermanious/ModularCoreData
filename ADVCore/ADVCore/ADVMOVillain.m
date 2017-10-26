//
//  ADVMOVillain.m
//  ADVCore
//
//  Created by Vladimir Ozerov on 06/10/2017.
//  Copyright © 2017 Crutches Bicycles. All rights reserved.
//

#import "ADVMOVillain.h"


@implementation ADVMOVillain

@dynamic superPower;
@dynamic lair;


#pragma mark - MCDDatabaseEntityDataSource

+ (NSEntityDescription *)entityForDatabaseModel:(MCDDatabaseModel *)model withEntities:(NSDictionary<NSString *, NSEntityDescription *> *)entities
{
	NSEntityDescription *villainEntity = makeDbEntity(@"ADVMOVillain", @[
		makeDbAttr(@"superPower", NSStringAttributeType, nil)
	]);
	return villainEntity;
}

@end
