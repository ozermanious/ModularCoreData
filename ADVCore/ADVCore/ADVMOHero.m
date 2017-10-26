//
//  ADVMOHero.m
//  ADVCore
//
//  Created by Vladimir Ozerov on 06/10/2017.
//  Copyright © 2017 Crutches Bicycles. All rights reserved.
//

#import "ADVMOHero.h"


@implementation ADVMOHero

@dynamic feature;
@dynamic home;


#pragma mark - MCDDatabaseEntityDataSource

+ (NSEntityDescription *)entityForDatabaseModel:(MCDDatabaseModel *)model withEntities:(NSDictionary<NSString *, NSEntityDescription *> *)entities
{
	NSEntityDescription *heroEntity = makeDbEntity(@"ADVMOHero", @[
		makeDbAttr(@"feature", NSStringAttributeType, nil)
	]);
	return heroEntity;
}

@end
