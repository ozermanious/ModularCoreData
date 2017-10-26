//
//  NSError+ModularCoreData.h
//  ModularCoreData
//
//  Created by Vladimir Ozerov on 07/07/2017.
//  Copyright © 2017 SberTech. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString *const MCDDatabaseErrorDomain; /**< Домен ошибок ДБД */

extern NSString *const MCDDatabaseErrorModelUserInfoKey; /**< В userInfo ключ для привязки модели */
extern NSString *const MCDDatabaseErrorStoreURLUserInfoKey; /**< В userInfo ключ для привязки URL хранилища */
extern NSString *const MCDDatabaseErrorConfigurationNameUserInfoKey; /**< В userInfo ключ для привязки имени хранилища */
extern NSString *const MCDDatabaseErrorExceptionUserInfoKey; /**< В userInfo ключ для привязки пойманного исключения */


/**
 Список кодов ошибок
 @discussion Описание ошибок см. в реализации
 */
typedef NS_ENUM(NSInteger, MCDDatabaseErrorCode) {
	MCDDatabaseUndefinedErrorCode = 0,
	MCDDatabaseModelNotFoundErrorCode,
	MCDDatabaseNoConfigurationErrorCode,
	MCDDatabaseAlreadyOpenedErrorCode,
	MCDDatabaseOpeningInProgressErrorCode,
	MCDDatabaseModelHasNoEntitiesErrorCode,
	MCDDatabasePersistentStoreCheckCompatibilityErrorCode,
	MCDDatabasePersistentStoreNotFoundErrorCode,
	MCDDatabaseMigrationErrorCode,
	MCDDatabaseCacheModelNotFoundErrorCode,
};


/**
 Категория NSError для MCDDatabase
 */
@interface NSError (ModularCoreData)

/**
 Создать ошибку БД с определенным кодом
 @param errorCode Код ошибки
 @return Ошибка
 */
+ (instancetype)errorWithMCDDatabaseErrorCode:(MCDDatabaseErrorCode)errorCode;

/**
 Создать ошибку БД с определенным кодом
 @param errorCode Код ошибки
 @param additionalUserInfo Параметры, которые будут добавлены к userInfo
 @return Ошибка
 */
+ (instancetype)errorWithMCDDatabaseErrorCode:(MCDDatabaseErrorCode)errorCode
						   additionalUserInfo:(NSDictionary *)additionalUserInfo;

- (NSError *)errorByAddingUserInfo:(NSDictionary *)userInfo;
- (NSError *)errorByAddingUnderlyingError:(NSError *)underlyingError;

@end
