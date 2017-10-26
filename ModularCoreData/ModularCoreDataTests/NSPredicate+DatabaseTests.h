//
//  NSPredicate+DatabaseTests.h
//  ModularCoreData
//
//  Created by Vladimir Ozerov on 14/07/2017.
//  Copyright © 2017 SberTech. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSPredicate (DatabaseTests)

/**
 Предикат равенства значения по ключу
 @param key Ключ
 @param value Значение
 @return Предикат формата "key == value"
 */
+ (NSPredicate *)equalPredicateForKey:(NSString *)key value:(NSString *)value;

@end
