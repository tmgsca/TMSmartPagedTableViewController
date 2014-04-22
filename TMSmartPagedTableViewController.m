//
//  TMTableViewController.m
//  PagedTableview
//
//  Created by Thiago Magalhães on 09/04/14.
//  Copyright (c) 2014 Thiago Magalhães. All rights reserved.
//

#import "TMSmartPagedTableViewController.h"

@interface TMSmartPagedTableViewController ()

@end

NSInteger numberOfRowsBeforeUpdate;

@implementation TMSmartPagedTableViewController

BOOL isLoading;

- (void)viewDidLoad
{
   [super viewDidLoad];
   
   self.isAutoLoadingEnabled = YES;
   self.isPaginated = YES;
   
   self.defaultCellIdentifier = @"defaultCell";
   self.defaultCellXibName = @"DefaultCell";
   
   self.loadingCellIdentifier = @"loadingCell";
   self.loadingCellXibName = @"LoadingCell";
   
   self.clickToLoadMoreCellIdentifier = @"clickToLoadMoreCell";
   self.clickToLoadMoreCellXibName = @"ClickToLoadMoreCell";
   
}

- (void) registerNibs
{
   UINib * clickToLoadMoreCellNib = [UINib nibWithNibName:self.clickToLoadMoreCellXibName bundle:nil];
   UINib * loadingCellNib = [UINib nibWithNibName:self.loadingCellXibName bundle:nil];
   UINib * defaultCellNib = [UINib nibWithNibName:self.defaultCellXibName bundle:nil];
   
   
   [[self tableView] registerNib:clickToLoadMoreCellNib forCellReuseIdentifier:self.clickToLoadMoreCellIdentifier];
   [[self tableView] registerNib:loadingCellNib forCellReuseIdentifier:self.loadingCellIdentifier];
   [[self tableView] registerNib:defaultCellNib forCellReuseIdentifier:self.defaultCellIdentifier];
   
   [self.searchDisplayController.searchResultsTableView registerNib:clickToLoadMoreCellNib forCellReuseIdentifier:self.clickToLoadMoreCellIdentifier];
   [self.searchDisplayController.searchResultsTableView registerNib:loadingCellNib forCellReuseIdentifier:self.loadingCellIdentifier];
   [self.searchDisplayController.searchResultsTableView registerNib:defaultCellNib forCellReuseIdentifier:self.defaultCellIdentifier];
   
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
   if([self isSectionedArray]) {
      
      return self.data.count;
      
   }
   
   return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   NSInteger numberOfRowsInSection;
   
   
   
   if([self isSectionedArray]) {
      
      if(self.isPaginated) {
         
         numberOfRowsInSection = ((NSArray *)[self.data objectAtIndex:section]).count + 1;
         
      } else {
         
         numberOfRowsInSection = ((NSArray *)[self.data objectAtIndex:section]).count;
         
      }
      
   } else {
      
      if(self.isPaginated) {
         
         numberOfRowsInSection = self.data.count + 1;
         
      } else {
         
         numberOfRowsInSection = self.data.count;
      }
      
   }
   
   numberOfRowsBeforeUpdate = numberOfRowsInSection;
   
   return numberOfRowsInSection;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   NSString * identifier = self.defaultCellIdentifier;
   
   if(self.isPaginated){
      
      if(indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1 && tableView != self.searchDisplayController.searchResultsTableView) {
         
         if(self.isAutoLoadingEnabled){
            
            identifier = @"loadingCell";
            isLoading = NO;
            
         } else {
            
            if(isLoading){
               
               identifier = @"loadingCell";
               
               isLoading = NO;
               
            } else {
               
               identifier = @"clickToLoadMoreCell";
               
            }
            
            
         }
      }
   }
   UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
   
   return cell;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
   if(self.isAutoLoadingEnabled){
      
      if(self.tableView.contentOffset.y >= (self.tableView.contentSize.height - (self.tableView.bounds.size.height + 20)))
      {
         
         if(!isLoading) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:TMLoadMoreCellsNotification object:nil];
            
            isLoading = YES;
         }
         
      }
      
   }
   
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   if(self.isPaginated){
      
      if(indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1) {
         
         isLoading = YES;
         
         [self.tableView beginUpdates];
         
         [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
         
         [self.tableView endUpdates];
         
         if(!self.isAutoLoadingEnabled){
            
            [[NSNotificationCenter defaultCenter] postNotificationName:TMUserClickedLoadMoreCellNotification object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:TMLoadMoreCellsNotification object:nil];
            
         }
      }
   }
   
   [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) addNewCells
{
   NSMutableArray * rowsToUpdate = [[NSMutableArray alloc] init];
   
   if([self isSectionedArray]) {
      
      [self.tableView reloadData];
      
   } else {
      
      for (int i = numberOfRowsBeforeUpdate; i == self.data.count ; i++) {
         
         NSIndexPath * indexPath = [NSIndexPath indexPathForRow:i inSection:0];
         
         [rowsToUpdate addObject:indexPath];
         
      }
      
   }
   
   [self.tableView reloadData];
   
   isLoading = NO;
}

- (BOOL) isSectionedArray
{
   if([self.data.lastObject superclass] == [NSArray class] || [self.data.lastObject class] == [NSArray class]) {
      
      return YES;
      
   }
   
   return NO;
}

#pragma Search Methods

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
   NSString * searchPredicate = [NSString stringWithFormat:@"%@ '%@'", self.searchPredicate, searchText];
   
   NSPredicate *predicate = [NSPredicate predicateWithFormat:searchPredicate];
   
   self.searchResults = [self.data filteredArrayUsingPredicate:predicate];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
   [self filterContentForSearchText:searchString
                              scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                     objectAtIndex:[self.searchDisplayController.searchBar
                                                    selectedScopeButtonIndex]]];
   
   return YES;
}


@end
