//
//  NSError+ModularCoreData.m
//  ModularCoreData
//
//  Created by Vladimir Ozerov on 07/07/2017.
//  Copyright © 2017 SberTech. All rights reserved.
//

#import "NSError+ModularCoreData.h"


NSString *const MCDDatabaseErrorDomain = @"MCDDatabase";

NSString *const MCDDatabaseErrorModelUserInfoKey = @"Model";
NSString *const MCDDatabaseErrorStoreURLUserInfoKey = @"Store URL";
NSString *const MCDDatabaseErrorConfigurationNameUserInfoKey = @"Configuration Name";
NSString *const MCDDatabaseErrorExceptionUserInfoKey = @"NSException";


@implementation NSError (ModularCoreData)

+ (NSString *)localizedDescriptionForMCDDatabaseErrorCode:(MCDDatabaseErrorCode)errorCode
{
	switch (errorCode)
	{
		case MCDDatabaseUndefinedErrorCode:
			return nil;
		case MCDDatabaseModelNotFoundErrorCode:
			return @"Не задана модель БД";
		case MCDDatabaseNoConfigurationErrorCode:
			return @"Для БД не заданы общие настройки";
		case MCDDatabaseAlreadyOpenedErrorCode:
			return @"БД уже открыта";
		case MCDDatabaseOpeningInProgressErrorCode:
			return @"БД в процессе открытия";
		case MCDDatabaseModelHasNoEntitiesErrorCode:
			return @"Модель БД не содержит сущностей";
		case MCDDatabasePersistentStoreCheckCompatibilityErrorCode:
			return @"Хранилище не соответствует модели БД";
		case MCDDatabasePersistentStoreNotFoundErrorCode:
			return @"Не удалось найти NSPersistentStore";
		case MCDDatabaseMigrationErrorCode:
			return @"Ошибка миграции хранилища";
		case MCDDatabaseCacheModelNotFoundErrorCode:
			return @"Не найден файл модели данных, соответствующей кэшу";
	}
}

+ (instancetype)errorWithMCDDatabaseErrorCode:(MCDDatabaseErrorCode)errorCode
{
	return [self errorWithMCDDatabaseErrorCode:errorCode additionalUserInfo:nil];
}

+ (instancetype)errorWithMCDDatabaseErrorCode:(MCDDatabaseErrorCode)errorCode additionalUserInfo:(NSDictionary *)additionalUserInfo;
{
	NSString *errorDescription = [self localizedDescriptionForMCDDatabaseErrorCode:errorCode];
	
	NSMutableDictionary *userInfoMutable = additionalUserInfo ? [additionalUserInfo mutableCopy] : [NSMutableDictionary dictionary];
	if (errorDescription && !userInfoMutable[NSLocalizedDescriptionKey])
	{
		userInfoMutable[NSLocalizedDescriptionKey] = errorDescription;
	}
	NSDictionary *userInfo = userInfoMutable.allKeys.count ? [userInfoMutable copy] : nil;
	
	NSError *error = [NSError errorWithDomain:MCDDatabaseErrorDomain
										 code:errorCode
									 userInfo:userInfo];
	return error;
}

- (NSError *)errorByAddingUserInfo:(NSDictionary *)userInfo
{
	if (userInfo.allKeys.count)
	{
		NSMutableDictionary *extendedUserInfo = [NSMutableDictionary dictionaryWithDictionary:self.userInfo];
		[extendedUserInfo addEntriesFromDictionary:userInfo];
		return [NSError errorWithDomain:self.domain code:self.code userInfo:[extendedUserInfo copy]];
	}
	return self;
	
}

- (NSError *)errorByAddingUnderlyingError:(NSError *)underlyingError
{
	if (underlyingError)
	{
		return [self errorByAddingUserInfo:@{NSUnderlyingErrorKey: underlyingError}];
	}
	return self;
}

@end
