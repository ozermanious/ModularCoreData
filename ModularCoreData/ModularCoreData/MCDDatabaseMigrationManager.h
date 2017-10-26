//
//  MCDDatabaseMigrationManager.h
//  ModularCoreData
//
//  Created by Vladimir Ozerov on 05/07/2017.
//  Copyright © 2017 SberTech. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 Менеджер автоматической миграции БД
 */
@interface MCDDatabaseMigrationManager : NSObject

@property (nonatomic, strong, readonly) NSManagedObjectModel *fromModel; /**< Исходная модель */
@property (nonatomic, strong, readonly) NSManagedObjectModel *toModel;   /**< Целевая модель */

/**
 Создать менеджер автоматической миграции БД
 @param fromModel Исходная модель
 @param toModel Целевая модель
 @return Менеджер миграции
 */
+ (instancetype)migrationFromModel:(NSManagedObjectModel *)fromModel toModel:(NSManagedObjectModel *)toModel;

/**
 Обновить хранилище по указанному URL
 @param storeURL URL хранилища, которое необходимо обновить
 @param storeType Тип хранилище
 @param options Опции хранилища
 @param error Указатель на ошибку, которое вернет данный метод в случае провала
 @return YES, если хранилище успешно обновлено
 */
- (BOOL)updateStoreAtURL:(NSURL *)storeURL
			   storeType:(NSString *)storeType
				 options:(NSDictionary *)options
		  returningError:(out NSError **)error;

@end
