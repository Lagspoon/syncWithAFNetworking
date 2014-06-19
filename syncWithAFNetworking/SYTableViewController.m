//
//  SYTableViewController.m
//  syncWithAFNetworking
//
//  Created by Olivier Delecueillerie on 19/11/2013.
//  Copyright (c) 2013 Olivier Delecueillerie. All rights reserved.
//

#import "SYTableViewController.h"
#import "SYSoundCloudSyncEngine.h"
#import "SYCoreDataStackWithSyncStuff.h"
#import "Soundcloud.h"


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
    //[[SYSyncEngine sharedEngine] registerNSManagedObjectClassToSync:[Soundcloud class] withWebService:soundcloud];

    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
    NSError *error;
    
	if (![self.fetchedResultsController performFetch:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
}


- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    /*
    [self checkSyncStatus];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"SDSyncEngineSyncCompleted" object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self loadRecordsFromCoreDataAndReloadData];
        [self.tableView reloadData];
    }];
    [[SYSyncEngine sharedEngine] addObserver:self forKeyPath:@"syncInProgress" options:NSKeyValueObservingOptionNew context:nil];
     */
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
    if(!_managedOC) {
         SYCoreDataStackWithSyncStuff *coreDataWithSyncStuff= [SYCoreDataStackWithSyncStuff sharedInstance];
        _managedOC = coreDataWithSyncStuff.managedObjectContext;
    }
    return _managedOC;
}


///////////////////////////////////////////////////////////////////
//UI INTERACTION
#pragma mark - UI Interaction
///////////////////////////////////////////////////////////////////

- (IBAction)refreshButtonTouched:(id)sender {
    SYSoundCloudSyncEngine *soundCloudSyncEngine = [SYSoundCloudSyncEngine sharedEngine];
    soundCloudSyncEngine.delegate =self;
    [soundCloudSyncEngine downloadTracksFromPlaylist:@"39491884"];
    //@"152617555"
    
    //[[SYSoundCloudHTTPClient sharedSoundCloudHTTPClient] getTracksFromSet:[NSString stringWithFormat:@"%i",39491884]];
    
}

- (IBAction)addButton:(id)sender {

}
/*
- (void)checkSyncStatus {
    if ([[SYSyncEngine sharedEngine] syncInProgress]) {
        [self replaceRefreshButtonWithActivityIndicator];
    } else {
        [self removeActivityIndicatorFromRefreshButon];
    }
}
*/

- (void) objectsDownloadedThanksToUpdateUI {
    NSError *error =nil;
    [self.fetchedResultsController performFetch:&error];
    [self.tableView reloadData];
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

/*
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"syncInProgress"]) {
        [self checkSyncStatus];
    }
}
*/

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
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    Soundcloud *sound = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = sound.name;
    return cell;
}


- (NSFetchedResultsController *) fetchedResultsController {
    if (_fetchedResultsController) {
        return _fetchedResultsController;
    }
    
    NSArray *arrayOfEntities = [[[self.managedOC persistentStoreCoordinator] managedObjectModel] entities];
    for (NSEntityDescription *entity in arrayOfEntities) {
        NSLog(@"entityName : %@", [entity name]);
    }
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity =[NSEntityDescription entityForName:@"Soundcloud" inManagedObjectContext:self.managedOC];
    [fetchRequest setEntity:entity];
	[fetchRequest setFetchBatchSize:40];
    
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
	[fetchRequest setSortDescriptors:@[sortDescriptor]];

    //[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"syncStatus != %d", SDObjectDeleted]];

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
       /*
        Drink *drink = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self.managedOC performBlockAndWait:^{ */
            /*
             You are no longer just deleting the record from Core Data. In the new model, if the record does NOT have an objectId (meaning it does not exist on the server) the record is immediately deleted as it was before. Otherwise you set the syncStatus to SDObjectDeleted
             */
        /*    if ([[drink valueForKey:@"objectId"] isEqualToString:@""] || [drink valueForKey:@"objectId"] == nil) {
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
        }];*/
    }
}
@end
