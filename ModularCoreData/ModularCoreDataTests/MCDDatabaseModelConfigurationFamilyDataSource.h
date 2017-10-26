//
//  MCDDatabaseModelConfigurationFamilyDataSource.h
//  ModularCoreData
//
//  Created by Vladimir Ozerov on 10/07/2017.
//  Copyright © 2017 SberTech. All rights reserved.
//

#import "MCDDatabaseModelConfigurationTestDataSource.h"


extern NSString *const MCDDatabaseTestFamilyFilename;
extern NSString *const MCDDatabaseTestFamilyConfiguration;


/**
 Генерация тестовой конфигурации модели БД (тематика: семья)
 */
@interface MCDDatabaseModelConfigurationFamilyDataSource : NSObject <MCDDatabaseEntityDataSource, MCDDatabaseModelConfigurationTestDataSource>

@end
