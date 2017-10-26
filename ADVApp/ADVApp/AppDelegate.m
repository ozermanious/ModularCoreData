//
//  AppDelegate.m
//  ADVApp
//
//  Created by Vladimir Ozerov on 02/10/2017.
//  Copyright © 2017 Vladimir Ozerov. All rights reserved.
//

#import "AppDelegate.h"
#import "APPCoreDataModelAssembly.h"


@import ModularCoreData;
@import ADVCore;


@interface AppDelegate ()

@property (nonatomic, strong) MCDDatabase *database;

@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[self setupDatabase];
	[self setupWindow];
	return YES;
}


#pragma mark - User Interface

- (void)setupWindow
{
	self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	self.window.rootViewController = [[ADVCharacterListViewController alloc] initWithDatabase:self.database];
	[self.window makeKeyAndVisible];
}


#pragma mark - Core Data

- (void)setupDatabase
{
	self.database = [APPCoreDataModelAssembly assembleDatabase];
}

@end
