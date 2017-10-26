//
//  MCDDatabaseConfigurationTests.m
//  ModularCoreData
//
//  Created by Vladimir Ozerov on 12/07/2017.
//  Copyright © 2017 SberTech. All rights reserved.
//

#import "MCDDatabaseConfiguration.h"
#import "NSFileManager+ModularCoreData.h"


@interface MCDDatabaseConfigurationTests : XCTestCase

@end


@implementation MCDDatabaseConfigurationTests

- (void)testConfiguration
{
	NSURL *modelURL = [NSURL URLWithString:@"path/to/model"];
	MCDDatabaseConfiguration *configuration = [MCDDatabaseConfiguration configurationWithModelFileURL:modelURL];
	expect(configuration).notTo.beNil();
	expect(configuration.modelFileURL).to.equal(modelURL);
}

/**
 Данный тест фиксирует пути до важных файлов, чтобы случайно не поменять
 */
- (void)testDefaultConfiguration
{
	MCDDatabaseConfiguration *configuration = [MCDDatabaseConfiguration defaultConfiguration];
	expect(configuration).notTo.beNil();
	
	NSURL *expectedFileURL = [NSFileManager cacheFileURLWithFileName:@"CurrentModel.bin"];
	expect(configuration.modelFileURL).to.equal(expectedFileURL);
}

@end
