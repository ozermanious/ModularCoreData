//
//  MCDDatabaseMappingModel.h
//  ModularCoreData
//
//  Created by Vladimir Ozerov on 06/07/2017.
//  Copyright © 2017 SberTech. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 Кастомная модель маппинга моделей БД
 */
@interface MCDDatabaseMappingModel : NSObject

/**
 Создать простую модель маппинга одной модели БД в другую
 @discussion Формируются простые правила маппинга сущностей на основе проверки их различий
 @param sourceModel Исходная модель данных
 @param destinationModel Новая модель данных
 @param error Ошибка формирования модели
 @return Модель маппинга, если нет ошибки
 */
+ (NSMappingModel *)simpleMappingModelWithSourceModel:(NSManagedObjectModel *)sourceModel
									 destinationModel:(NSManagedObjectModel *)destinationModel
												error:(out NSError **)error;

@end
