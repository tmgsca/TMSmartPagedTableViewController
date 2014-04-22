//
//  TMTableViewController.h
//  PagedTableview
//
//  Created by Thiago Magalhães on 09/04/14.
//  Copyright (c) 2014 Thiago Magalhães. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TMUserClickedLoadMoreCellNotification @"userClickedLoadMoreCellsNotification"
#define TMLoadMoreCellsNotification @"loadMoreCellsNotification"
#define TMAddNewCellsNotification @"addNewCellsNotification"


@interface TMSmartPagedTableViewController : UIViewController <UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray * data;
@property (strong, nonatomic) NSArray * searchResults;

@property BOOL isPaginated;
@property BOOL isAutoLoadingEnabled;

@property (strong, nonatomic) NSString * defaultCellIdentifier;
@property (strong, nonatomic) NSString * defaultCellXibName;

@property (strong, nonatomic) NSString * loadingCellIdentifier;
@property (strong, nonatomic) NSString * loadingCellXibName;

@property (strong, nonatomic) NSString * clickToLoadMoreCellIdentifier;
@property (strong, nonatomic) NSString * clickToLoadMoreCellXibName;

@property (strong, nonatomic) NSString * searchPredicate;

- (void) registerNibs;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void) addNewCells;

@end
