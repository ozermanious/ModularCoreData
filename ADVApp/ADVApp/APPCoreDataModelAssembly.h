//
//  APPCoreDataModelAssembly.h
//  ADVApp
//
//  Created by Vladimir Ozerov on 06/10/2017.
//  Copyright © 2017 Vladimir Ozerov. All rights reserved.
//

@import ModularCoreData;


/**
 Данный класс занимается сбором и компоновкой модели БД
 */
@interface APPCoreDataModelAssembly : NSObject

/**
 Выполнить сбор сущностей и создать инстанс БД
 @return инстанс MCDDatabase, если выполнилось успешно
 */
+ (nullable MCDDatabase *)assembleDatabase;

@end
