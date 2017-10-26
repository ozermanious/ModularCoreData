//
//  MCDDatabaseModelConfiguration.m
//  ModularCoreData
//
//  Created by Vladimir Ozerov on 07/07/2017.
//  Copyright © 2017 SberTech. All rights reserved.
//

#import "MCDDatabaseModelConfiguration.h"


@interface MCDDatabaseModelConfiguration ()

@property (nonatomic, copy) NSString *initialStoreType;
@property (nonatomic, copy) NSString *initialStoreFileName;
@property (nonatomic, copy) NSDictionary *initialOptions;

@end


@implementation MCDDatabaseModelConfiguration

+ (instancetype)configWithType:(NSString *)storeType file:(NSString *)storeFileName options:(NSDictionary *)options entities:(NSArray<id<MCDDatabaseEntityDataSource>> *)entities
{
	MCDDatabaseModelConfiguration *config = [MCDDatabaseModelConfiguration new];
	config.storeType = storeType;
	config.storeFileName = storeFileName;
	config.options = options;
	[config.entitiesDS addObjectsFromArray:entities];
	return config;
}

- (id)init
{
	self = [super init];
	if (self)
	{
		_entitiesDS = [NSMutableArray array];
	}
	return self;
}

- (void)commitInitialParameters
{
	self.initialStoreType = self.storeType;
	self.initialStoreFileName = self.storeFileName;
	self.initialOptions = self.options;
}

- (void)restoreInitialParameters
{
	self.storeType = self.initialStoreType;
	self.storeFileName = self.initialStoreFileName;
	self.options = self.initialOptions;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"MCDDatabaseConfig(%@, %@, options: %@, entities: %i)", _storeType, _storeFileName, (_options ? @"+" : @"-"), (int)_entitiesDS.count];
}

@end
