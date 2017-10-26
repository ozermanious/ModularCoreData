//
//  ADVCharacterListViewController.m
//  ADVCore
//
//  Created by Vladimir Ozerov on 06/10/2017.
//  Copyright © 2017 Crutches Bicycles. All rights reserved.
//

#import "ADVCharacterListViewController.h"
#import "ADVMOCharacter.h"

@import CoreData;
@import ModularCoreData;
@import Masonry;


@interface ADVCharacterListViewController () <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) MCDDatabase *database;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end


@implementation ADVCharacterListViewController

- (void)dealloc
{
	_fetchedResultsController.delegate = nil;
}

- (instancetype)initWithDatabase:(nonnull MCDDatabase *)database
{
	self = [super init];
	if (self)
	{
		_database = database;
	}
	return self;
}

- (void)loadView
{
	[super loadView];
	
	[self setupFetchedResultsController];

	self.navigationItem.title = @"Adventure Time";

	self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
	self.tableView.backgroundColor = [UIColor whiteColor];
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	[self.view addSubview:self.tableView];
	
	[self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.edges.equalTo(self.view);
	}];
}


#pragma mark - Setup Fetched Results Controller

- (void)setupFetchedResultsController
{
	NSFetchRequest *fetchRequest = [NSFetchRequest new];
	fetchRequest.entity = [self.database.readContext entityForObjectClass:[ADVMOCharacter class]];
	fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
	
	self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
																		managedObjectContext:self.database.readContext
																		  sectionNameKeyPath:nil
																				   cacheName:nil];
	self.fetchedResultsController.delegate = self;
	[self.fetchedResultsController performFetch:nil];
}


#pragma mark - UITableViewDelegate / DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.fetchedResultsController.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *const CellIdentifier = @"CharacterCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
	if (!cell)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	ADVMOCharacter *character = self.fetchedResultsController.fetchedObjects[indexPath.row];
	
	NSDateFormatter *dateFormatter = [NSDateFormatter new];
	dateFormatter.calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
	dateFormatter.dateFormat = @"HH:mm";
	
	cell.textLabel.text = character.name;
}


#pragma mark - NSFetchedResultControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	[self.tableView reloadData];
}

@end
