//
//  ADVMOPrincess.m
//  ADVCore
//
//  Created by Vladimir Ozerov on 12/10/2017.
//  Copyright © 2017 Crutches Bicycles. All rights reserved.
//

#import "ADVMOPrincess.h"


@implementation ADVMOPrincess

@dynamic consistsOf;
@dynamic kingdom;


#pragma mark - MCDDatabaseEntityDataSource

+ (NSEntityDescription *)entityForDatabaseModel:(MCDDatabaseModel *)model withEntities:(NSDictionary<NSString *, NSEntityDescription *> *)entities
{
	NSEntityDescription *princessEntity = makeDbEntity(@"ADVMOPrincess", @[
		makeDbAttr(@"consistsOf", NSStringAttributeType, nil)
	]);
	return princessEntity;
}

@end
