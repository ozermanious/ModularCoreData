//
//  MCDDatabaseConfiguration.m
//  ModularCoreData
//
//  Created by Vladimir Ozerov on 12/07/2017.
//  Copyright © 2017 SberTech. All rights reserved.
//

#import "MCDDatabaseConfiguration.h"
#import "NSFileManager+ModularCoreData.h"


@interface MCDDatabaseConfiguration ()

@property (nonatomic, copy) NSURL *modelFileURL;

@end


@implementation MCDDatabaseConfiguration

+ (instancetype)defaultConfiguration
{
	NSURL *fileURL = [NSFileManager cacheFileURLWithFileName:@"CurrentModel.bin"];
	return [self configurationWithModelFileURL:fileURL];
}

+ (instancetype)configurationWithModelFileURL:(NSURL *)modelFileURL
{
	MCDDatabaseConfiguration *configuration = [MCDDatabaseConfiguration new];
	configuration.modelFileURL = modelFileURL;
	return configuration;
}

@end
