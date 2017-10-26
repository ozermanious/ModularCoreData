//
//  MCDDatabaseMigrationManager.m
//  ModularCoreData
//
//  Created by Vladimir Ozerov on 05/07/2017.
//  Copyright © 2017 SberTech. All rights reserved.
//

#import "MCDDatabaseMigrationManager.h"
#import "MCDDatabaseMappingModel.h"
#import "MCDDatabase+Private.h"
#import "NSError+ModularCoreData.h"


static NSString * const MCDDatabaseMigrationManagerTempStorePath = @"TempMigrationStore";


@interface MCDDatabaseMigrationManager ()

@property (nonatomic, strong) NSManagedObjectModel *fromModel;
@property (nonatomic, strong) NSManagedObjectModel *toModel;

@property (nonatomic, strong) NSMappingModel *mappingModel;
@property (nonatomic, strong) NSMigrationManager *migrationManager;

@end


@implementation MCDDatabaseMigrationManager

+ (instancetype)migrationFromModel:(NSManagedObjectModel *)fromModel toModel:(NSManagedObjectModel *)toModel
{
	if (!fromModel || !toModel)
	{
		return nil;
	}

	NSError *error = nil;
	NSMappingModel *mappingModel = [MCDDatabaseMappingModel simpleMappingModelWithSourceModel:fromModel
																			 destinationModel:toModel
																						error:&error];
	if (!mappingModel || error)
	{
		return nil;
	}
	
	MCDDatabaseMigrationManager *migration = [MCDDatabaseMigrationManager new];
	migration.fromModel = fromModel;
	migration.toModel = toModel;
	migration.mappingModel = mappingModel;
	migration.migrationManager = [[NSMigrationManager alloc] initWithSourceModel:fromModel destinationModel:toModel];
	return migration;
}

- (BOOL)updateStoreAtURL:(NSURL *)storeURL storeType:(NSString *)storeType options:(NSDictionary *)options returningError:(NSError **)outError
{
	[MCDDatabase deleteStoreFileWithName:MCDDatabaseMigrationManagerTempStorePath returningError:nil];
	NSURL *tempStoreURL = [MCDDatabase prepareFolderForStoreWithFilename:MCDDatabaseMigrationManagerTempStorePath error:outError];
	if (!tempStoreURL)
	{
		return NO;
	}
	
	BOOL migrationSucceed;
	@try
	{
		// Осуществляю миграцию
		migrationSucceed = [self.migrationManager migrateStoreFromURL:storeURL
																 type:storeType
															  options:options
													 withMappingModel:self.mappingModel
													 toDestinationURL:tempStoreURL
													  destinationType:storeType
												   destinationOptions:options
																error:outError];
	}
	@catch (NSException *exception)
	{
		if (outError)
		{
			*outError = [NSError errorWithMCDDatabaseErrorCode:MCDDatabaseMigrationErrorCode
											additionalUserInfo:@{ MCDDatabaseErrorExceptionUserInfoKey: exception }];
		}
	}
	@finally
	{
		if (!migrationSucceed)
		{
			return NO;
		}
		
		// Проверяю новое хранилище на валидность
		NSDictionary *metadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:storeType
																							URL:tempStoreURL
																						options:options
																						  error:outError];
		if (![self.toModel isConfiguration:nil compatibleWithStoreMetadata:metadata])
		{
			if (outError)
			{
				*outError = [NSError errorWithMCDDatabaseErrorCode:MCDDatabaseMigrationErrorCode
												additionalUserInfo:@{ NSLocalizedDescriptionKey: @"Мигрированное хранилище не совместимо с моделью данных" }];
			}
			[MCDDatabase deleteStoreFileWithName:MCDDatabaseMigrationManagerTempStorePath returningError:nil];
			return NO;
		}

		// Подменяю хранилище в ФС
		return [self replaceStore:storeURL withTempStore:tempStoreURL error:outError];
	}
}

- (BOOL)replaceStore:(NSURL *)storeURL withTempStore:(NSURL *)tempStoreURL error:(out NSError **)outError;
{
	NSString *storeFilename = storeURL.URLByDeletingPathExtension.lastPathComponent;
	if (![MCDDatabase deleteStoreFileWithName:storeFilename returningError:outError])
	{
		return NO;
	}
	if (![MCDDatabase prepareFolderForStoreWithFilename:storeFilename error:outError])
	{
		return NO;
	}
	if (![[NSFileManager defaultManager] copyItemAtURL:tempStoreURL toURL:storeURL error:outError])
	{
		return NO;
	}
	[MCDDatabase deleteStoreFileWithName:MCDDatabaseMigrationManagerTempStorePath returningError:nil];
	return YES;
}

@end
