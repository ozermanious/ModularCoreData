//
//  MCDDatabaseModel.h
//  Created by Vladimir Ozerov on 28/07/16.
//  Copyright © 2016 SberTech. All rights reserved.
//

@class MCDDatabaseModelConfiguration;


/**
 Модель БД
 */
@interface MCDDatabaseModel : NSManagedObjectModel

@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, MCDDatabaseModelConfiguration *> *configs; /**< @brief <Имя конфигурации, Конфигурация> */

@end
