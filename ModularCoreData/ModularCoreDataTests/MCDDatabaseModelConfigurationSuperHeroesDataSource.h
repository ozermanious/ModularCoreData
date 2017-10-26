//
//  MCDDatabaseModelConfigurationSuperHeroesDataSource.h
//  ModularCoreData
//
//  Created by Vladimir Ozerov on 10/07/2017.
//  Copyright © 2017 SberTech. All rights reserved.
//

#import "MCDDatabaseModelConfigurationTestDataSource.h"


extern NSString *const MCDDatabaseTestSuperHeroesFilename;
extern NSString *const MCDDatabaseTestSuperHeroesConfiguration;


/**
 Генерация тестовой конфигурации модели БД (тематика: супер-герои)
 */
@interface MCDDatabaseModelConfigurationSuperHeroesDataSource : NSObject <MCDDatabaseEntityDataSource, MCDDatabaseModelConfigurationTestDataSource>

@end
