//
//  MCDDatabaseContextTests.m
//  ModularCoreData
//
//  Created by Vladimir Ozerov on 14/07/2017.
//  Copyright © 2017 SberTech. All rights reserved.
//

#import "NSManagedObject+DatabaseTests.h"


@interface MCDDatabaseContextTests : XCTestCase

@property (nonatomic, strong) MCDDatabaseContext *context;

@property (nonatomic, strong) NSEntityDescription *testEntity;
@property (nonatomic, strong) Class testEntityClass;
@property (nonatomic, strong) NSArray *managedObjectList;

@property (nonatomic, strong) id NSEntityDescriptionClassMock;

@end


@implementation MCDDatabaseContextTests

- (void)setUp
{
	[super setUp];

	// Сущность
	self.testEntity = OCMPartialMock([NSEntityDescription new]);
	OCMStub([self.testEntity name]).andReturn(@"MOTestObject");
	OCMStub([self.testEntity managedObjectClassName]).andReturn(@"MOTestObject");

	// Моки объектов в БД
	self.testEntityClass = [NSManagedObject testMakeManagedObjectClassForEntity:self.testEntity];
	NSManagedObject *object1 = OCMPartialMock([self.testEntityClass new]);
	NSManagedObject *object2 = OCMPartialMock([self.testEntityClass new]);
	self.managedObjectList = @[object1, object2];

	// Мок стека БД
	MCDDatabaseModel *model = OCMPartialMock([MCDDatabaseModel new]);
	OCMStub([model entities]).andReturn(@[self.testEntity]);
	OCMStub([model entitiesByName]).andReturn(@{@"MOTestObject": self.testEntity});
	
	NSPersistentStoreCoordinator *coordinator = OCMPartialMock([NSPersistentStoreCoordinator new]);
	OCMStub([coordinator managedObjectModel]).andReturn(model);
	
	self.context = OCMPartialMock([MCDDatabaseContext contextWithConcurrencyType:NSMainQueueConcurrencyType readonly:NO]);
	OCMStub([self.context persistentStoreCoordinator]).andReturn(coordinator);
	OCMStub([self.context executeFetchRequest:[OCMArg any] error:[OCMArg anyObjectRef]]).andCall(self, @selector(mockedExecuteFetchRequest:error:));
	OCMStub([self.context deleteObject:[OCMArg any]]).andCall(self, @selector(mockedDeleteObject:));
	
	self.NSEntityDescriptionClassMock = OCMClassMock([NSEntityDescription class]);
	OCMStub([self.NSEntityDescriptionClassMock entityForName:[OCMArg any] inManagedObjectContext:[OCMArg any]]).andReturn(self.testEntity);
}

- (void)tearDown
{
	self.context = nil;
	self.testEntity = nil;
	self.testEntityClass = nil;
	self.managedObjectList = nil;
	
	[self.NSEntityDescriptionClassMock stopMocking];
	self.NSEntityDescriptionClassMock = nil;
	
	[super tearDown];
}

- (void)testFetchingEntries
{
	NSPredicate *testPredicate = [NSPredicate predicateWithFormat:@"uid == \"001\""];
	NSSortDescriptor *testSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
	
	id item = [self.context entry:self.testEntityClass
			   withPredicate:testPredicate];
	OCMVerify([self.context entries:self.testEntityClass
					  withPredicate:testPredicate]);
	expect(item).to.equal(self.managedObjectList.firstObject);
	
	NSArray *entriesList = [self.context allEntries:self.testEntityClass];
	OCMVerify([self.context entries:self.testEntityClass
					  withPredicate:nil]);
	expect(entriesList).to.equal(self.managedObjectList);
	
	entriesList = [self.context entries:self.testEntityClass
						  withPredicate:testPredicate];
	OCMVerify([self.context entries:self.testEntityClass
					  withPredicate:testPredicate
					sortDescriptors:nil]);
	expect(entriesList).to.equal(self.managedObjectList);
	
	entriesList = [self.context entries:self.testEntityClass
						  withPredicate:testPredicate
						sortDescriptors:@[testSortDescriptor]];
	OCMVerify([self.context entries:self.testEntityClass
					  withPredicate:testPredicate
					sortDescriptors:@[testSortDescriptor]
						 resultType:NSManagedObjectResultType]);
	expect(entriesList).to.equal(self.managedObjectList);
	
	entriesList = [self.context entries:self.testEntityClass
						  withPredicate:testPredicate
						sortDescriptors:@[testSortDescriptor]
							 resultType:NSDictionaryResultType];
	NSFetchRequest *request = [NSFetchRequest new];
	request.entity = self.testEntity;
	request.predicate = testPredicate;
	request.sortDescriptors = @[testSortDescriptor];
	request.resultType = NSDictionaryResultType;
	OCMVerify([self mockedExecuteFetchRequest:request error:nil]);
	expect(entriesList).to.equal(self.managedObjectList);
}

- (void)testDeletingEntries
{
	NSInteger count = [self.context deleteAllEntries:self.testEntityClass];
	expect(count).to.equal(self.managedObjectList.count);
	OCMVerify([self.context deleteEntries:self.testEntityClass withPredicate:nil]);
	OCMVerify([self.context entries:self.testEntityClass withPredicate:nil]);
	OCMVerify([self.context deleteObject:self.managedObjectList[0]]);
	OCMVerify([self.context deleteObject:self.managedObjectList[1]]);
}


#pragma mark - Mocks

- (NSArray *)mockedExecuteFetchRequest:(NSFetchRequest *)request error:(NSError **)error
{
	return self.managedObjectList;
}

- (void)mockedDeleteObject:(NSManagedObject *)object
{

}

@end
