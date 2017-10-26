//
//  MCDDatabaseConfiguration.h
//  ModularCoreData
//
//  Created by Vladimir Ozerov on 12/07/2017.
//  Copyright © 2017 SberTech. All rights reserved.
//

#import <Foundation/Foundation.h>


@class MCDDatabaseJSONCacheNode;


/**
 Общие настройки БД
 */
@interface MCDDatabaseConfiguration : NSObject

@property (nonatomic, copy, readonly) NSURL *modelFileURL; /**< URL файла с текущей моделью БД (для нужд миграции) */

/**
 Настройки БД по умолчанию
 @return Настройки
 */
+ (instancetype)defaultConfiguration;

/**
 Кастомные настройки БД
 @param modelFileURL Путь до файла с текущей моделью БД
 @return Настройки
 */
+ (instancetype)configurationWithModelFileURL:(NSURL *)modelFileURL;

@end
