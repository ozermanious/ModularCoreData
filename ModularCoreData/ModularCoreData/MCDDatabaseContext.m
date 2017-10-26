//
//  MCDDatabaseContext.m
//  Created by Vladimir Ozerov on 27/07/16.
//  Copyright © 2016 SberTech. All rights reserved.
//

#import "MCDDatabaseContext.h"
#import "MCDDatabaseContext+Private.h"


@implementation MCDDatabaseContext

+ (instancetype)contextWithConcurrencyType:(NSManagedObjectContextConcurrencyType)concurrencyType readonly:(BOOL)readonly
{
	MCDDatabaseContext *ctx = [[MCDDatabaseContext alloc] initWithConcurrencyType:concurrencyType];
	ctx.readonly = readonly;
	return ctx;
}


#pragma mark - NSManagedObject management

- (NSEntityDescription *)entityForObjectClass:(Class)MOClass
{
	return [NSEntityDescription entityForName:NSStringFromClass(MOClass) inManagedObjectContext:self];
}

- (id)entry:(Class)MOClass withPredicate:(NSPredicate *)predicate
{
	NSArray *entries = [self entries:MOClass withPredicate:predicate];
	return entries.firstObject;
}

- (NSArray *)allEntries:(Class)MOClass
{
	return [self entries:MOClass withPredicate:nil];
}

- (NSArray *)entries:(Class)MOClass withPredicate:(NSPredicate *)predicate
{
	return [self entries:MOClass withPredicate:predicate sortDescriptors:nil];
}

- (NSArray *)entries:(Class)MOClass withPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors
{
	return [self entries:MOClass withPredicate:predicate sortDescriptors:sortDescriptors resultType:NSManagedObjectResultType];
}

- (NSArray *)entries:(Class)MOClass withPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors resultType:(NSFetchRequestResultType)resultType
{
	NSFetchRequest *request = [NSFetchRequest new];
	request.entity = [NSEntityDescription entityForName:NSStringFromClass(MOClass) inManagedObjectContext:self];
	request.resultType = resultType;
	if (predicate)
		request.predicate = predicate;
	if (sortDescriptors)
		request.sortDescriptors = sortDescriptors;
	
	return [self executeFetchRequest:request error:nil];
}

- (id)newEntry:(Class)MOClassName
{
	NSAssert(!_readonly, @"MCDDatabaseContext: attempt to create object in readonly context.");
	
	// Определяем сущность создаваемой записи в БД
	NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass(MOClassName) inManagedObjectContext:self];
	// Если указанной сущности нет в модели данного контекста, выдаем ошибку
	NSAssert(entity, @"MCDDatabaseContext: can't create NSEntityDescription");
	
	return [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:self];
}

- (id)newEntryOutOfContext:(Class)MOClassName
{
	NSAssert(!_readonly, @"MCDDatabaseContext: attempt to create object in readonly context.");
	// Определяем сущность создаваемой записи в БД
	NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass(MOClassName) inManagedObjectContext:self];
	// Если указанной сущности нет в модели данного контекста, выдаем ошибку
	
	NSAssert(entity, @"MCDDatabaseContext: can't create NSEntityDescription");
	return [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
}

- (NSInteger)deleteAllEntries:(Class)MOClass
{
	return [self deleteEntries:MOClass withPredicate:nil];
}

- (NSInteger)deleteEntries:(Class)MOClass withPredicate:(NSPredicate *)predicate
{
	NSArray *entries = [self entries:MOClass withPredicate:predicate];
	NSInteger count = 0;
	for (NSManagedObject *entry in entries)
	{
		[self deleteObject:entry];
		count += 1;
	}
	return count;
}

- (BOOL)save:(NSError * _Nullable __autoreleasing *)error
{
	if (self.persistentStoreCoordinator.persistentStores.count)
	{
		return [super save:error];
	}
	return NO;
}

@end
