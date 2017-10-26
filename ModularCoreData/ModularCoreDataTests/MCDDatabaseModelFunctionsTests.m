//
//  MCDDatabaseModelFunctionsTests.m
//  ModularCoreData
//
//  Created by Vladimir Ozerov on 12/07/2017.
//  Copyright © 2017 SberTech. All rights reserved.
//


@interface MCDDatabaseModelFunctionsTests : XCTestCase

@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSEntityDescription *firstObjectEntity;
@property (nonatomic, strong) NSEntityDescription *secondObjectEntity;

@end


@implementation MCDDatabaseModelFunctionsTests

- (void)setUp
{
	[super setUp];
	
	self.context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
	
	self.firstObjectEntity = OCMPartialMock([NSEntityDescription new]);
	self.firstObjectEntity.name = @"FirstObject";
	
	self.secondObjectEntity = OCMPartialMock([NSEntityDescription new]);
	self.secondObjectEntity.name = @"SecondObject";
}

- (void)tearDown
{
	[super tearDown];
}

- (NSArray<NSManagedObject*> *)mockedManagedObjectsPair
{
	// Создаю атрибуты
	NSDictionary *attributesByName = @{
		@"string": makeDbAttr(@"string", NSStringAttributeType, nil),
		@"number": makeDbAttr(@"number", NSInteger16AttributeType, nil),
		@"data"  : makeDbAttr(@"data",   NSBinaryDataAttributeType, nil)
	};
	OCMStub([self.firstObjectEntity attributesByName]).andReturn(attributesByName);
	
	// Создаю связи
	NSDictionary *relationshipsByName = @{
		@"relationship": makeDbRelation(@"relationship", self.secondObjectEntity, YES, nil)
	};
	OCMStub([self.firstObjectEntity relationshipsByName]).andReturn(relationshipsByName);
	
	// Список всех свойств
	NSMutableDictionary *propertiesByName = [attributesByName mutableCopy];
	propertiesByName[relationshipsByName.allKeys.firstObject] = relationshipsByName.allValues.firstObject;
	OCMStub([self.firstObjectEntity propertiesByName]).andReturn([propertiesByName copy]);
	OCMStub([self.firstObjectEntity properties]).andReturn(propertiesByName.allValues);
	
	NSManagedObject *firstObject = OCMPartialMock([NSManagedObject new]);
	OCMStub([firstObject entity]).andReturn(self.firstObjectEntity);
	OCMStub([firstObject setValue:[OCMArg any] forKey:[OCMArg any]]).andDo(^(NSInvocation *invocation) {});
	OCMStub([firstObject valueForKey:[OCMArg any]]).andReturn(nil);
	OCMStub([firstObject validateValue:[OCMArg anyObjectRef] forKey:[OCMArg any] error:[OCMArg anyObjectRef]]).andReturn(YES);
	
	NSManagedObject *secondObject = OCMPartialMock([NSManagedObject new]);
	OCMStub([secondObject entity]).andReturn(self.secondObjectEntity);
	OCMStub([secondObject setValue:[OCMArg any] forKey:[OCMArg any]]).andDo(^(NSInvocation *invocation) {});
	OCMStub([secondObject valueForKey:[OCMArg any]]).andReturn(nil);
	OCMStub([secondObject validateValue:[OCMArg anyObjectRef] forKey:[OCMArg any] error:[OCMArg anyObjectRef]]).andReturn(YES);
	
	return @[firstObject, secondObject];
}

- (void)testMCDCheckAndSet
{
	NSArray<NSManagedObject*> *managedObjectPair = [self mockedManagedObjectsPair];

	expect(MCDCheckAndSet(nil, @"string", @"text")).to.beFalsy();
	expect(MCDCheckAndSet(managedObjectPair[0], nil, nil)).to.beFalsy();
	expect(MCDCheckAndSet(managedObjectPair[0], nil, @"value")).to.beFalsy();
	expect(MCDCheckAndSet(managedObjectPair[0], @"nonExistendProperty", @"value")).to.beFalsy();
	expect(MCDCheckAndSet(managedObjectPair[0], @"string", @0)).to.beFalsy();
	expect(MCDCheckAndSet(managedObjectPair[0], @"number", @"text")).to.beFalsy();
	expect(MCDCheckAndSet(managedObjectPair[1], @"string", @"text")).to.beFalsy();
	expect(MCDCheckAndSet(managedObjectPair[1], @"relationship", managedObjectPair[0])).to.beFalsy();

	expect(MCDCheckAndSet(managedObjectPair[0], @"string", @"text")).to.beTruthy();
	OCMVerify([managedObjectPair[0] setValue:@"text" forKey:@"string"]);
	
	expect(MCDCheckAndSet(managedObjectPair[0], @"number", @256)).to.beTruthy();
	OCMVerify([managedObjectPair[0] setValue:@256 forKey:@"number"]);
	
	NSData *data = [[NSData alloc] initWithBase64EncodedString:@"SomeData" options:0];
	expect(MCDCheckAndSet(managedObjectPair[0], @"data", data)).to.beTruthy();
	OCMVerify([managedObjectPair[0] setValue:data forKey:@"data"]);

	expect(MCDCheckAndSet(managedObjectPair[0], @"relationship", managedObjectPair[1])).to.beTruthy();
	OCMVerify([managedObjectPair[0] setValue:managedObjectPair[1] forKey:@"relationship"]);
}

- (void)testMCDCheckAndSetDictionary
{
	NSArray<NSManagedObject*> *managedObjectPair = [self mockedManagedObjectsPair];
	
	expect(MCDCheckAndSetDictionary(managedObjectPair[0], @{
		@"nonExistendProperty": @"value",
		@"string": @0,
		@"number": @"text"
	})).to.beFalsy();

	expect(MCDCheckAndSetDictionary(managedObjectPair[0], @{
		@"nonExistendProperty": @"value",
		@"string": @"text",
		@"number": @13,
		@"relationship": managedObjectPair[1]
	})).to.beTruthy();
	OCMVerify([managedObjectPair[0] setValue:@"text" forKey:@"string"]);
	OCMVerify([managedObjectPair[0] setValue:@13 forKey:@"number"]);
	OCMVerify([managedObjectPair[0] setValue:managedObjectPair[1] forKey:@"relationship"]);
}

- (void)testMakeDbEntity
{
	NSArray<NSPropertyDescription*> *propertyList = @[
		makeDbAttr(@"uid", NSStringAttributeType, nil),
		makeDbAttr(@"name", NSStringAttributeType, nil),
		makeDbAttr(@"order", NSInteger16AttributeType, nil)
	];
	NSEntityDescription *entity = makeDbEntity(@"TestEntity", propertyList);
	expect(entity.name).to.equal(@"TestEntity");
	expect(entity.managedObjectClassName).to.equal(@"TestEntity");
	expect(entity.properties).to.equal(propertyList);
}

- (void)testMakeDbAttr
{
	NSAttributeDescription *attribute = makeDbAttr(@"TestAttribute", NSInteger16AttributeType, ^(NSAttributeDescription *localAttribute) {
		localAttribute.defaultValue = @13;
	});
	expect(attribute.name).to.equal(@"TestAttribute");
	expect(attribute.attributeType).to.equal(NSInteger16AttributeType);
	expect(attribute.optional).to.beTruthy();
	expect(attribute.defaultValue).to.equal(@13);
}

- (void)testMakeDbRelation
{
	NSEntityDescription *toEntity = makeDbEntity(@"ToEntity", nil);
	NSRelationshipDescription *relation = makeDbRelation(@"to", toEntity, NO, ^(NSRelationshipDescription *localRelation) {
		localRelation.maxCount = 13;
	});
	expect(relation.name).to.equal(@"to");
	expect(relation.destinationEntity).to.equal(toEntity);
	expect(relation.optional).to.equal(YES);
	expect(relation.ordered).to.equal(NO);
	expect(relation.maxCount).to.equal(13);
}

- (void)testAppendDbRelationships
{
	NSEntityDescription *fromEntity = makeDbEntity(@"FromEntity", nil);
	NSEntityDescription *toEntityOne = makeDbEntity(@"ToEntityOne", nil);
	NSEntityDescription *toEntityTwo = makeDbEntity(@"ToEntityTwo", nil);
	
	NSRelationshipDescription *relationshipOne = makeDbRelation(@"toEntityOne", toEntityOne, YES, nil);
	NSRelationshipDescription *relationshipTwo = makeDbRelation(@"toEntityTwo", toEntityTwo, NO, nil);
	
	NSArray *relationshipList = @[
		relationshipOne,
		relationshipTwo
	];
	appendDbRelationships(fromEntity, relationshipList);
	expect(fromEntity.relationshipsByName.allValues).to.contain(relationshipOne);
	expect(fromEntity.relationshipsByName.allValues).to.contain(relationshipTwo);
}

- (void)testPairDbRelationships
{
	NSEntityDescription *fromEntity = makeDbEntity(@"FromEntity", nil);
	NSEntityDescription *toEntity = makeDbEntity(@"ToEntity", nil);
	NSRelationshipDescription *relationshipFromTo = makeDbRelation(@"to", toEntity, YES, nil);
	NSRelationshipDescription *relationshipToFrom = makeDbRelation(@"from", fromEntity, NO, nil);
	appendDbRelationships(fromEntity, @[relationshipFromTo]);
	appendDbRelationships(toEntity, @[relationshipToFrom]);

	pairDbRelationships(fromEntity, @"to", toEntity, @"from");
	expect(fromEntity.relationshipsByName[@"to"].inverseRelationship).to.equal(relationshipToFrom);
	expect(toEntity.relationshipsByName[@"from"].inverseRelationship).to.equal(relationshipFromTo);
}

@end
