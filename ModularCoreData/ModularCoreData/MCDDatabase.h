//
//  MCDDatabase.h
//  Created by Vladimir Ozerov on 27/07/16.
//  Copyright © 2016 SberTech. All rights reserved.
//

#import <CoreData/CoreData.h>


extern NSString *const MCDDatabaseDidLoadNotification;


@class MCDDatabaseConfiguration;
@class MCDDatabaseModel;
@class MCDDatabaseModelConfiguration;
@class MCDDatabaseContext;


/**
 Наш CoreData-стек
 */
@interface MCDDatabase : NSObject

@property (nonatomic, strong) MCDDatabaseConfiguration *databaseConfiguration; /**< Общие настройки БД */

@property (nonatomic, strong, readonly) dispatch_queue_t persistentStoreSyncQueue; /**< Очередь для синхронной работы с добавлением/удалением хранилищ */

@property (nonatomic, strong) MCDDatabaseModel *dbModel; /**< Модель данных */
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *coordinator; /**< Координатор */
@property (nonatomic, strong, readonly) MCDDatabaseContext *writeContext; /**< Контекст для записи (Background Thread) */
@property (nonatomic, strong, readonly) MCDDatabaseContext *readContext;  /**< Контекст для чтения (Main Thread) */

@property (nonatomic, readonly) BOOL ready; /**< БД готова к работе */

/**
 Открыть БД
 @discussion Перед выполнением необходимо сконфигурировать БД: настроить модель и хранилища. Выполняется асинхронно в фоне
 @param completion Блок по завершени
 */
- (void)open:(void (^)(NSError *error))completion;

/**
 Сбросить текущий стек CoreData
 @discussion Обнуляет ссылки на контексты и координатор.
			 Необходимо вызывать на persistentStoreSyncQueue
 */
- (void)resetCoreDataStack;

/**
 Проинициализировать NSPersistentStoreCoordinator
 @discussion Необходимо вызывать на persistentStoreSyncQueue
 @param error Ошибка, если не удалось настроить координатор
 @return YES, если завершилось успешно
 */
- (BOOL)setupPersistentStoreCoordinator:(out NSError **)error;

/**
 Удалить файл кэша БД
 @discussion Необходимо вызывать на persistentStoreSyncQueue
 @param storeFileName Имя файла хранилища
 @param error Указатель на ошибку, в который будет записана ошибка, в случае ошибки
 @return BOOL Результат удаления
 */
+ (BOOL)deleteStoreFileWithName:(NSString *)storeFileName
				 returningError:(NSError **)error;

@end
