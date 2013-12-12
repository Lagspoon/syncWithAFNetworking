//
//  SYTableViewController.m
//  syncWithAFNetworking
//
//  Created by Olivier Delecueillerie on 19/11/2013.
//  Copyright (c) 2013 Olivier Delecueillerie. All rights reserved.
//

#import "SYTableViewController.h"
#import "SYCoreDataStackWithSyncStuff.h"
#import "SYSyncEngine.h"
#import "SYAddObject.h"
#import "Drink.h"


@interface SYTableViewController ()
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext *managedOC;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@end

@implementation SYTableViewController


///////////////////////////////////////////////////////////////////
//VIEW CONTROLLER LIFECYCLE
# pragma mark - VC LifeCycle
///////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSError *error;
    
	if (![self.fetchedResultsController performFetch:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self checkSyncStatus];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"SDSyncEngineSyncCompleted" object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self loadRecordsFromCoreDataAndReloadData];
        [self.tableView reloadData];
    }];
    [[SYSyncEngine sharedEngine] addObserver:self forKeyPath:@"syncInProgress" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewDidUnload {
    [self setRefreshButton:nil];
    [super viewDidUnload];
}

///////////////////////////////////////////////////////////////////
//LAZY INSTANTIATION
#pragma mark - Lazy Instantiation
///////////////////////////////////////////////////////////////////
-(NSManagedObjectContext *) managedOC {
    if(!_managedOC) _managedOC = [[SYCoreDataStackWithSyncStuff sharedInstance] backgroundManagedObjectContext];
    return _managedOC;
}


///////////////////////////////////////////////////////////////////
//UI INTERACTION
#pragma mark - UI Interaction
///////////////////////////////////////////////////////////////////

- (IBAction)refreshButtonTouched:(id)sender {
    [[SYSyncEngine sharedEngine] startSync];
}

- (IBAction)addButton:(id)sender {
    SYAddObject *addObject = [[SYAddObject alloc]init];
    [addObject saveButtonTouched];
}




- (void)checkSyncStatus {
    if ([[SYSyncEngine sharedEngine] syncInProgress]) {
        [self replaceRefreshButtonWithActivityIndicator];
    } else {
        [self removeActivityIndicatorFromRefreshButon];
    }
}

- (void)replaceRefreshButtonWithActivityIndicator {
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityIndicator setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin)];
    [activityIndicator startAnimating];
    UIBarButtonItem *activityItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    self.navigationItem.leftBarButtonItem = activityItem;
}

- (void)removeActivityIndicatorFromRefreshButon {
    self.navigationItem.leftBarButtonItem = self.refreshButton;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"syncInProgress"]) {
        [self checkSyncStatus];
    }
}

- (void)loadRecordsFromCoreDataAndReloadData {
    [self.managedOC performBlockAndWait:^{
        [self.managedOC reset];
        NSError *error = nil;
        [self.fetchedResultsController performFetch:&error];
        [self.tableView reloadData];
    }];
}


///////////////////////////////////////////////////////////////////
//TABLE VIEW DATA SOURCE
#pragma mark - Table view data source
///////////////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    Drink *drink = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = drink.name;
    cell.detailTextLabel.text=@"putain de detail";
    return cell;
}


- (NSFetchedResultsController *) fetchedResultsController {
    if (_fetchedResultsController) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity =[NSEntityDescription entityForName:@"Drink" inManagedObjectContext:self.managedOC];
    [fetchRequest setEntity:entity];
	[fetchRequest setFetchBatchSize:40];
    
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
	[fetchRequest setSortDescriptors:@[sortDescriptor]];

    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"syncStatus != %d", SDObjectDeleted]];

    // Use the sectionIdentifier property to group into sections.
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedOC sectionNameKeyPath:nil cacheName:nil];
    _fetchedResultsController.delegate = self;
    
	return _fetchedResultsController;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Drink *drink = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self.managedOC performBlockAndWait:^{
            /*
             You are no longer just deleting the record from Core Data. In the new model, if the record does NOT have an objectId (meaning it does not exist on the server) the record is immediately deleted as it was before. Otherwise you set the syncStatus to SDObjectDeleted
             */
            if ([[drink valueForKey:@"objectId"] isEqualToString:@""] || [drink valueForKey:@"objectId"] == nil) {
                [self.managedOC deleteObject:drink];
            } else {
                [drink setValue:[NSNumber numberWithInt:SDObjectDeleted] forKey:@"syncStatus"];
            }
            NSError *error = nil;
            BOOL saved = [self.managedOC save:&error];
            if (!saved) {
                NSLog(@"Error saving main context: %@", error);
            }

            [[SYCoreDataStackWithSyncStuff sharedInstance] saveBackgroundContext];
            [self loadRecordsFromCoreDataAndReloadData];
        }];
    }
}
@end