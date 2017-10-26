//
//  NSPredicate+DatabaseTests.m
//  ModularCoreData
//
//  Created by Vladimir Ozerov on 14/07/2017.
//  Copyright © 2017 SberTech. All rights reserved.
//

#import "NSPredicate+DatabaseTests.h"


@implementation NSPredicate (DatabaseTests)

+ (NSPredicate *)equalPredicateForKey:(NSString *)key value:(NSString *)value
{
	NSString *predicateFormat = [key stringByAppendingFormat:@" == \"%@\"", value];
	return [NSPredicate predicateWithFormat:predicateFormat];
}

@end
