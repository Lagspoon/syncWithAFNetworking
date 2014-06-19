//
//  SYDetailTVC.h
//  syncWithAFNetworking
//
//  Created by Olivier Delecueillerie on 28/12/2013.
//  Copyright (c) 2013 Olivier Delecueillerie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface SYDetailTVC : UITableViewController
@property (nonatomic, strong) NSManagedObject *objectSelected;
@end
