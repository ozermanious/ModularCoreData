//
//  NSFileManager+ModularCoreData.m
//  ModularCoreData
//
//  Created by Vladimir Ozerov on 02/10/2017.
//  Copyright © 2017 Vladimir Ozerov. All rights reserved.
//

#import "NSFileManager+ModularCoreData.h"


@implementation NSFileManager (ModularCoreData)

+ (NSURL *)cacheFileURLWithFileName:(NSString *)fileName
{
	return [self cacheURLWithItemName:fileName isDirectory:NO];
}

+ (NSURL *)cacheDirectoryURLWithDirectoryName:(NSString *)directoryName
{
	return [self cacheURLWithItemName:directoryName isDirectory:YES];
}

+ (NSURL *)cacheURLWithItemName:(NSString *)itemName isDirectory:(BOOL)isDirectory
{
	NSArray *cacheURLList = [[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
	if (cacheURLList.count == 0)
	{
		NSAssert(0, @"Директория кэша не определена");
		return nil;
	}
	
	NSURL *cacheURL = cacheURLList[0];
	NSString *modularCoreDataPath = [cacheURL.path stringByAppendingPathComponent:@"ModularCoreData"];

	if (![[NSFileManager defaultManager] fileExistsAtPath:modularCoreDataPath])
	{
		NSError *error = nil;
		[[NSFileManager defaultManager] createDirectoryAtPath:modularCoreDataPath
								  withIntermediateDirectories:YES
												   attributes:nil
														error:&error];
		if (error)
		{
			NSAssert(0, @"Поддиректория кэша не создана");
		}
	}
	
	NSURL *cacheItemURL = [NSURL URLWithString:modularCoreDataPath];
	cacheItemURL = [cacheItemURL URLByAppendingPathComponent:itemName];
	cacheItemURL = [NSURL fileURLWithPath:cacheItemURL.path isDirectory:isDirectory];
	return cacheItemURL;
}

@end
