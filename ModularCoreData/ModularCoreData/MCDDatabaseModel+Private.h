//
//  MCDDatabaseModel+Private.h
//  Created by Vladimir Ozerov on 29/07/16.
//  Copyright © 2016 SberTech. All rights reserved.
//

#import "MCDDatabaseModel.h"


@interface MCDDatabaseModel ()

@property (nonatomic, assign) BOOL configsApplied; /**< Модель сконфигурирована */

/**
 Сконфигурировать модель в соответствие с задынными config-ами
 */
- (void)applyConfigs;

@end
