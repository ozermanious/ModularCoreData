//
//  MCDDatabaseMappingModelTests.m
//  ModularCoreData
//
//  Created by Vladimir Ozerov on 17/07/2017.
//  Copyright © 2017 SberTech. All rights reserved.
//

#import "MCDDatabaseModel+Tests.h"
#import "MCDDatabaseMappingModel.h"


@interface MCDDatabaseMappingModelTests : XCTestCase

@end


@implementation MCDDatabaseMappingModelTests

- (void)testCreatingMappingModel
{
	for (MCDTestableDatabaseType sourceModelType = MCDTestableDatabaseMain; sourceModelType < MCDTestableDatabaseSecondary; sourceModelType++)
	{
		MCDDatabaseModel *sourceModel = [MCDDatabaseModel testableModelWithType:sourceModelType];
		
		for (MCDTestableDatabaseType destinationModelType = MCDTestableDatabaseMain; destinationModelType < MCDTestableDatabaseSecondary; destinationModelType++)
		{
			MCDDatabaseModel *destinationModel = [MCDDatabaseModel testableModelWithType:destinationModelType];
			
			NSError *error = nil;
			NSMappingModel *mappingModel = [MCDDatabaseMappingModel simpleMappingModelWithSourceModel:sourceModel
																					 destinationModel:destinationModel
																								error:&error];
			
			expect(error).to.beNil();
			expect(mappingModel).notTo.beNil();
			
			NSInteger maxEntitiesCount = MAX(sourceModel.entities.count, destinationModel.entities.count);
			expect(mappingModel.entityMappings.count >= maxEntitiesCount).to.beTruthy();
			
			for (NSEntityMapping *entityMapping in mappingModel.entityMappings)
			{
				[self expectCorrectEntityMapping:entityMapping
								 withSourceModel:sourceModel
								destinationModel:destinationModel];
			}
		}
	}
}

- (void)expectCorrectEntityMapping:(NSEntityMapping *)entityMapping withSourceModel:(MCDDatabaseModel *)sourceModel destinationModel:(MCDDatabaseModel *)destinationModel
{
	NSEntityDescription *sourceEntity = sourceModel.entitiesByName[entityMapping.sourceEntityName];
	NSEntityDescription *destinationEntity = destinationModel.entitiesByName[entityMapping.destinationEntityName];
	NSInteger attributeMappingsCount = entityMapping.attributeMappings.count;
	NSInteger relationshipMappingsCount = entityMapping.relationshipMappings.count;
	
	switch (entityMapping.mappingType)
	{
		case NSAddEntityMappingType:
		{
			expect(sourceEntity).to.beNil();
			expect(destinationEntity).notTo.beNil();
			expect(attributeMappingsCount).to.equal(0);
			expect(relationshipMappingsCount).to.equal(0);
			break;
		}
		case NSRemoveEntityMappingType:
		{
			expect(sourceEntity).notTo.beNil();
			expect(destinationEntity).to.beNil();
			expect(attributeMappingsCount).to.equal(0);
			expect(relationshipMappingsCount).to.equal(0);
			break;
		}
		case NSCopyEntityMappingType:
		case NSTransformEntityMappingType:
		{
			expect(sourceEntity).notTo.beNil();
			expect(destinationEntity).notTo.beNil();
			expect(attributeMappingsCount).to.equal(destinationEntity.attributesByName.allKeys.count);
			expect(relationshipMappingsCount).to.equal(destinationEntity.relationshipsByName.allKeys.count);
			break;
		}
		case NSUndefinedEntityMappingType:
		case NSCustomEntityMappingType:
		{
			failure(@"Недопустимое значение NSEntityMappingType");
			break;
		}
	}
}

@end
