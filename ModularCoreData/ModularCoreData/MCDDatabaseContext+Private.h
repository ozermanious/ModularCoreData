//
//  MCDDatabaseContext+Private.h
//  ModularCoreData
//
//  Created by Vladimir Ozerov on 14/07/2017.
//  Copyright © 2017 SberTech. All rights reserved.
//

#import "MCDDatabaseContext.h"


@interface MCDDatabaseContext ()

@property (nonatomic, assign) BOOL readonly;

@property (nonatomic, strong) NSMutableDictionary *toUpdatePacks; /**< Блоки сущностей для обновления */
@property (nonatomic, strong) NSMutableDictionary *fetchedPacks;  /**< Блоки зафетченых сущностей */

@end
