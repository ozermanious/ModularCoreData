//
//  MCDDatabase.m
//  Created by Vladimir Ozerov on 27/07/16.
//  Copyright © 2016 SberTech. All rights reserved.
//

#import "MCDDatabase+Private.h"
#import "MCDDatabaseConfiguration.h"
#import "MCDDatabaseModel+Private.h"
#import "MCDDatabaseModelConfiguration.h"
#import "MCDDatabaseContext.h"
#import "MCDDatabaseMigrationManager.h"
#import "NSError+ModularCoreData.h"
#import "NSFileManager+ModularCoreData.h"


NSString *const MCDDatabaseDidLoadNotification = @"MCDDatabaseDidLoadNotification";


@interface MCDDatabase ()

@property (nonatomic, strong) MCDDatabaseContext *writeContext;
@property (nonatomic, strong) MCDDatabaseContext *readContext;

@property (nonatomic, strong) NSPersistentStoreCoordinator *coordinator;
@property (nonatomic, strong) dispatch_queue_t persistentStoreSyncQueue; /**< Очередь для синхронной работы с добавлением/удалением хранилищ */
@property (nonatomic, assign) BOOL opened;
@property (nonatomic, assign) BOOL opening;

@property (nonatomic, strong) NSManagedObjectModel *cacheModel; /**< Модель данных, соответствующая данным в кэше */
@property (nonatomic, strong) MCDDatabaseMigrationManager *migrationManager; /**< Менеджер миграции */

@property (nonatomic, strong, readonly) dispatch_queue_t contextReadSyncQueue; /**< Очередь для синхронной работы с контекстом чтения */
@property (nonatomic, strong, readonly) dispatch_queue_t contextWriteSyncQueue; /**< Очередь для синхронной работы с контекстом записи */

@end


@implementation MCDDatabase

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _persistentStoreSyncQueue = dispatch_queue_create("ru.sberbank.onlinephone.db_persistent_store_sync", DISPATCH_QUEUE_SERIAL);
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextDidSaveNotification:) name:NSManagedObjectContextDidSaveNotification object:nil];
    }
    return self;
}

- (BOOL)ready
{
    return (
            self.dbModel &&
            self.coordinator
            );
}

- (BOOL)canOpen:(out NSError **)error
{
    NSAssert([NSThread isMainThread], @"Инициализация контектстов должна проводится на главном потоке.");
    
    MCDDatabaseErrorCode errorCode = MCDDatabaseUndefinedErrorCode;
    if (!self.dbModel)
    {
        errorCode = MCDDatabaseModelNotFoundErrorCode;
    }
    else if (!self.databaseConfiguration)
    {
        errorCode = MCDDatabaseNoConfigurationErrorCode;
    }
    else if (self.opened)
    {
        errorCode = MCDDatabaseAlreadyOpenedErrorCode;
    }
    else if (self.opening)
    {
        errorCode = MCDDatabaseOpeningInProgressErrorCode;
    }
    else if (!self.dbModel.configs.allKeys.count)
    {
        errorCode = MCDDatabaseModelHasNoEntitiesErrorCode;
    }
    
    if (errorCode != MCDDatabaseUndefinedErrorCode)
    {
        if (error)
        {
            *error = [NSError errorWithMCDDatabaseErrorCode:errorCode];
        }
        return NO;
    }
    return YES;
}

- (void)open:(void (^)(NSError *error))completion
{
    NSError *openError = nil;
    if (![self canOpen:&openError])
    {
        if (completion)
        {
            completion(openError);
        }
        return;
    }
    
    self.opening = YES;
    
    // Загружаю модель БД, соответствующую данным в кэше
    [self loadSourceManagedObjectModel];
    
    // Формирую новую модель данных в соответствие с конфигурацией, собранной со всех модулей
    [self.dbModel applyConfigs];
    
    __block NSError *setupError = nil;
    dispatch_sync(self.persistentStoreSyncQueue, ^{
        [self setupPersistentStoreCoordinator:&setupError];
    });
    if (setupError)
    {
        self.opening = NO;
        if (completion)
        {
            completion(setupError);
        }
        return;
    }
    
    // Сохраняю новую модель данных и удаляю объекты - помощники миграции
    [self saveDestinationManagedObjectModel];
    self.cacheModel = nil;
    self.migrationManager = nil;
    
    self.opening = NO;
    self.opened = YES;
    
    if (completion)
    {
        completion(nil);
    }
}


#pragma mark - NSNotification Observing

- (void)contextDidSaveNotification:(NSNotification *)notification
{
    void (^handlerBlock)(void) = ^{
        [_readContext performBlockAndWait:^{
            [_readContext mergeChangesFromContextDidSaveNotification:notification];
        }];
    };
    
    if (notification.object == _writeContext)
    {
        if (NSThread.isMainThread)
        {
            handlerBlock();
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                handlerBlock();
            });
        }
    }
}


#pragma mark - CoreData Stack

- (MCDDatabaseContext *)readContext
{
    if (!_readContext && self.coordinator)
    {
        // создаем контекст в главном потоке
        // (https://developer.apple.com/documentation/coredata/nsmanagedobjectcontext#1654001 раздел Concurrency)
        
        void (^creationBlock)(void) = ^{
            _readContext = [MCDDatabaseContext contextWithConcurrencyType:NSMainQueueConcurrencyType readonly:YES];
            _readContext.persistentStoreCoordinator = self.coordinator;
            _readContext.mergePolicy = NSRollbackMergePolicy;
        };
        
        if (NSThread.isMainThread)
        {
            creationBlock();
        }
        else
        {
            dispatch_sync(dispatch_get_main_queue(), ^(){
                creationBlock();
            });
        }
    }
    return _readContext;
}

- (MCDDatabaseContext *)writeContext
{
    if (!_writeContext && self.coordinator)
    {
        _writeContext = [MCDDatabaseContext contextWithConcurrencyType:NSPrivateQueueConcurrencyType readonly:NO];
        _writeContext.persistentStoreCoordinator = self.coordinator;
    }
    return _writeContext;
}

- (void)resetCoreDataStack
{
    _readContext = nil;
    _writeContext = nil;
    _coordinator = nil;
}

- (BOOL)setupPersistentStoreCoordinator:(out NSError **)outError
{
    self.coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.dbModel];
    
    // Подключем все хранилища, указанные в конфигурациях
    for (NSString *configName in self.dbModel.configs.allKeys)
    {
        NSError *error = nil;
        if (![self addPersistentStoreWithConfigName:configName config:self.dbModel.configs[configName] error:&error])
        {
            if (outError)
            {
                *outError = error;
            }
            return NO;
        }
    }
    return YES;
}

- (BOOL)addPersistentStoreWithConfigName:(NSString *)configName config:(MCDDatabaseModelConfiguration *)config error:(out NSError **)outError
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSURL *storeURL = [self.class prepareFolderForStoreWithFilename:config.storeFileName error:outError];
    if (config.storeFileName && !storeURL)
    {
        return NO;
    }
    
    /**
     Открываем хранилище.
     - Если не удалось открыть, пытаемся сделать миграцию данных
     - Если не удалось мигрировать, пытаемся удалить и создать новое хранилище
     */
    NSError *compoundError = nil;       /**< Последовательность ошибок, каждая следующая по ключу NSUnderlyingErrorKey */
    BOOL migrationAttempt = NO;         /**< Осуществлена попытка миграции */
    BOOL deletionAttempt = NO;          /**< Осуществлена попытка удаления старого невалидного хранилища */
    BOOL storeCorrectionPerformed = NO; /**< [В рамках текущего цикла] выполнено некоторое действие, направленное на исправление хранилища */
    do
    {
        storeCorrectionPerformed = NO;
        
        // Проверяю на совместимость хранилища с моделью БД
        BOOL storeFileExists = storeURL.path && [fileManager fileExistsAtPath:storeURL.path];
        BOOL modelIsCompatible = !storeFileExists;
        NSError *metadataReadError = nil;
        if (storeFileExists)
        {
            NSDictionary *storeMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:config.storeType
                                                                                                     URL:storeURL
																								 options:config.options
                                                                                                   error:&metadataReadError];
            if (!metadataReadError)
            {
                modelIsCompatible = [self.dbModel isConfiguration:configName compatibleWithStoreMetadata:storeMetadata];
            }
        }
        
        // Присоединяем хранилище
        NSError *openError = nil;
        if (modelIsCompatible)
        {
            [self.coordinator addPersistentStoreWithType:config.storeType
                                           configuration:configName
                                                     URL:storeURL
                                                 options:config.options
                                                   error:&openError];
        }
        else if (metadataReadError)
        {
            openError = metadataReadError;
        }
        else
        {
            openError = [NSError errorWithMCDDatabaseErrorCode:MCDDatabasePersistentStoreCheckCompatibilityErrorCode
                                            additionalUserInfo:@{ MCDDatabaseErrorStoreURLUserInfoKey: storeURL,
                                                                  MCDDatabaseErrorModelUserInfoKey: self.dbModel }];
        }
        
        if (!openError)
        {
            // Если открытие успешно, сбрасываем ошибку
            compoundError = nil;
        }
        else if (!compoundError)
        {
            // Здесь сохраняем корневую ошибку
            compoundError = openError;
        }
        
        // Пытаемся конвертировать данные в хранилище
        if (openError && !migrationAttempt && !storeCorrectionPerformed)
        {
            migrationAttempt = YES;
            if (!self.cacheModel)
            {
                NSError *modelError = [NSError errorWithMCDDatabaseErrorCode:MCDDatabaseCacheModelNotFoundErrorCode];
                compoundError = [modelError errorByAddingUnderlyingError:compoundError];
            }
            if (self.cacheModel && storeFileExists)
            {
                if (!self.migrationManager)
                {
                    self.migrationManager = [MCDDatabaseMigrationManager migrationFromModel:self.cacheModel toModel:self.coordinator.managedObjectModel];
                }
                
                NSError *updateError = nil;
                BOOL migrationSucceed = [self.migrationManager updateStoreAtURL:storeURL
                                                                      storeType:config.storeType
                                                                        options:config.options
                                                                 returningError:&updateError];
                if (migrationSucceed)
                {
                    storeCorrectionPerformed = YES;
                }
                else
                {
                    compoundError = [updateError errorByAddingUnderlyingError:compoundError];
                }
            }
        }
        
        // Пытаемся удалить старый файл хранилища и пробуем снова
        if (openError && !deletionAttempt && !storeCorrectionPerformed)
        {
            deletionAttempt = YES;
            if (storeFileExists)
            {
                NSError *deletionError = nil;
                if ([fileManager removeItemAtURL:storeURL error:&deletionError])
                {
                    storeCorrectionPerformed = YES;
                }
                else
                {
                    compoundError = [deletionError errorByAddingUnderlyingError:compoundError];
                }
            }
        }
    }
    while (storeCorrectionPerformed);
    
    if (outError && compoundError)
    {
        *outError = compoundError;
    }
    return !compoundError;
}

+ (BOOL)deleteStoreFileWithName:(NSString *)storeFileName returningError:(NSError **)error
{
    NSURL *storeFolderURL = [NSFileManager cacheFileURLWithFileName:storeFileName];
//    storeFolderURL = [NSURL fileURLWithPath:storeFolderURL.absoluteString isDirectory:YES];
    return [[NSFileManager defaultManager] removeItemAtURL:storeFolderURL error:error];
}


#pragma mark - Routine

+ (NSURL *)prepareFolderForStoreWithFilename:(NSString *)filename error:(out NSError **)outError
{
    if (filename)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *storeFolderURL = [NSFileManager cacheDirectoryURLWithDirectoryName:filename];
        // Директория, где хранятся все файлы БД
        if (![fileManager fileExistsAtPath:storeFolderURL.path])
        {
            NSError *error = nil;
            if (![fileManager createDirectoryAtPath:storeFolderURL.path withIntermediateDirectories:YES attributes:nil error:&error])
            {
                if (outError)
                {
                    *outError = error;
                    return nil;
                }
            }
        }
        NSString *filenamePathComponent = [filename stringByAppendingPathExtension:@"cache"];
        
        NSURL *storeURL = [NSURL fileURLWithPathComponents:@[storeFolderURL.path, filenamePathComponent]];
        return storeURL;
    }
    return nil;
}


#pragma mark - NSManagedObjectModel Storing

- (BOOL)loadSourceManagedObjectModel
{
	// Считываю из файла старую модель данных
	NSData *modelData = [NSData dataWithContentsOfURL:self.databaseConfiguration.modelFileURL];

	if (modelData)
	{
		NSManagedObjectModel *model = [NSKeyedUnarchiver unarchiveObjectWithData:modelData];
		if ([model isKindOfClass:[NSManagedObjectModel class]])
		{
			self.cacheModel = model;
			return YES;
		}
	}
	return NO;
}

- (void)saveDestinationManagedObjectModel
{
    NSData *modelData = [NSKeyedArchiver archivedDataWithRootObject:self.dbModel];
    if (modelData)
    {
		NSString *filePath = self.databaseConfiguration.modelFileURL.path;
		[modelData writeToFile:filePath atomically:NO];
    }
}

@end
