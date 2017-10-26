//
//  NSError+MCDDatabaseTests.m
//  ModularCoreData
//
//  Created by Vladimir Ozerov on 12/07/2017.
//  Copyright © 2017 SberTech. All rights reserved.
//

@interface NSError (Tests)

+ (NSString *)localizedDescriptionForMCDDatabaseErrorCode:(MCDDatabaseErrorCode)errorCode;

@end


@interface NSError_MCDDatabaseTests : XCTestCase

@end


@implementation NSError_MCDDatabaseTests

- (void)testErrorCodes
{
	NSDictionary *userInfo = @{
		@"key1": @"value1",
		@"key2": @"value2",
		@"key3": @"value3",
	};
	
	for (MCDDatabaseErrorCode errorCode = MCDDatabaseUndefinedErrorCode; errorCode < MCDDatabaseCacheModelNotFoundErrorCode; errorCode++)
	{
		NSString *localizedDescription = [NSError localizedDescriptionForMCDDatabaseErrorCode:errorCode];
		
		NSError *error = [NSError errorWithMCDDatabaseErrorCode:errorCode additionalUserInfo:userInfo];
		expect(error).notTo.beNil();
		expect(error.domain).to.equal(MCDDatabaseErrorDomain);
		expect(error.code).to.equal(errorCode);
		expect(error.userInfo[NSLocalizedDescriptionKey]).to.equal(localizedDescription);
		
		NSInteger keysCount = userInfo.allKeys.count + (localizedDescription ? 1 : 0);
		expect(error.userInfo.allKeys.count).to.equal(keysCount);
		
		NSMutableDictionary *errorUserInfo = [error.userInfo mutableCopy];
		[errorUserInfo removeObjectForKey:NSLocalizedDescriptionKey];
		expect(errorUserInfo).to.equal(userInfo);
	}
}

@end
