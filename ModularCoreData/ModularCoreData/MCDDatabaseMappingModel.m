//
//  MCDDatabaseMappingModel.m
//  ModularCoreData
//
//  Created by Vladimir Ozerov on 06/07/2017.
//  Copyright © 2017 SberTech. All rights reserved.
//

#import "MCDDatabaseMappingModel.h"


@implementation MCDDatabaseMappingModel

+ (NSMappingModel *)simpleMappingModelWithSourceModel:(NSManagedObjectModel *)sourceModel destinationModel:(NSManagedObjectModel *)destinationModel error:(out NSError **)error
{
	NSError *createError = nil;
	NSMappingModel *mappingModel = [NSMappingModel inferredMappingModelForSourceModel:sourceModel
																	 destinationModel:destinationModel
																				error:&createError];
	if (createError)
	{
		if (error)
		{
			*error = createError;
		}
		return nil;
	}
	
	NSMutableArray<NSEntityMapping*> *entityMappingList = [NSMutableArray array];
	for (NSEntityDescription *sourceEntity in sourceModel.entities)
	{
		NSEntityDescription *destinationEntity = destinationModel.entitiesByName[sourceEntity.name];
		[entityMappingList addObject:[self entityMappingWithSourceEntity:sourceEntity destinationEntity:destinationEntity]];
	}
	// Добавляю пропущенные в предыдущем цикле сущности
	for (NSEntityDescription *destinationEntity in destinationModel.entities)
	{
		NSEntityDescription *sourceEntity = sourceModel.entitiesByName[destinationEntity.name];
		if (!sourceEntity)
		{
			[entityMappingList addObject:[self entityMappingWithSourceEntity:nil destinationEntity:destinationEntity]];
		}
	}
	
	return mappingModel;
}

/**
 Формирование простого маппинга сущности
 @param sourceEntity Исходная модель сущности
 @param destinationEntity Новая модель сущности
 @return Маппинг сущности
 */
+ (NSEntityMapping *)entityMappingWithSourceEntity:(NSEntityDescription *)sourceEntity destinationEntity:(NSEntityDescription *)destinationEntity
{
	// Определяю тип маппинга на основе различий в моделях сущностей
	NSEntityMappingType mappingType = NSUndefinedEntityMappingType;
	if (!sourceEntity)
	{
		mappingType = NSAddEntityMappingType;
	}
	else if (!destinationEntity)
	{
		mappingType = NSRemoveEntityMappingType;
	}
	else if ([sourceEntity.versionHash isEqual:destinationEntity.versionHash])
	{
		mappingType = NSCopyEntityMappingType;
	}
	else
	{
		mappingType = NSTransformEntityMappingType;
	}
	
	NSEntityMapping *entityMapping = [NSEntityMapping new];
	entityMapping.mappingType = mappingType;
	entityMapping.sourceEntityName = sourceEntity.name;
	entityMapping.sourceEntityVersionHash = sourceEntity.versionHash;
	entityMapping.destinationEntityName = destinationEntity.name;
	entityMapping.destinationEntityVersionHash = destinationEntity.versionHash;

	if (mappingType == NSCopyEntityMappingType || mappingType == NSTransformEntityMappingType)
	{
		// Формирую массив маппингов атрибутов
		NSMutableArray<NSPropertyMapping*> *attributeMappingList = [NSMutableArray array];
		for (NSAttributeDescription *destinationAttribute in destinationEntity.attributesByName.allValues)
		{
			NSAttributeDescription *sourceAttribute = sourceEntity.attributesByName[destinationAttribute.name];
			NSPropertyMapping *attributeMapping = [self propertyMappingWithSourceProperty:sourceAttribute destinationProperty:destinationAttribute];
			[attributeMappingList addObject:attributeMapping];
		}
		entityMapping.attributeMappings = [attributeMappingList copy];

		// Формирую массив маппингов связей
		NSMutableArray<NSPropertyMapping*> *relationshipMappingList = [NSMutableArray array];
		for (NSRelationshipDescription *destinationRelationship in destinationEntity.relationshipsByName.allValues)
		{
			NSRelationshipDescription *sourceRelationship = sourceEntity.relationshipsByName[destinationRelationship.name];
			NSPropertyMapping *relationshipMapping = [self propertyMappingWithSourceProperty:sourceRelationship destinationProperty:destinationRelationship];
			[relationshipMappingList addObject:relationshipMapping];
		}
		entityMapping.relationshipMappings = [relationshipMappingList copy];
	}
	
	return entityMapping;
}

/**
 Формирование простого маппинга свойства
 @discussion Если модель свойства изменилась, то оно будет обнулено. Если осталось без изменения, то просто скопировано
 @param sourceProperty Исходная модель свойства
 @param destinationProperty Новая модель свойства
 @return Маппинг свойства
 */
+ (NSPropertyMapping *)propertyMappingWithSourceProperty:(NSPropertyDescription *)sourceProperty destinationProperty:(NSPropertyDescription *)destinationProperty
{
	NSExpression *expression = nil;
	BOOL propertyChanged = ![sourceProperty isEqual:destinationProperty];
	if (!propertyChanged)
	{
		expression = [NSExpression expressionForKeyPath:sourceProperty.name];
	}
	else
	{
		expression = [NSExpression expressionForConstantValue:nil];
	}
	
	NSPropertyMapping *propertyMapping = [NSPropertyMapping new];
	propertyMapping.name = destinationProperty.name;
	propertyMapping.valueExpression = expression;
	return propertyMapping;
}

@end
