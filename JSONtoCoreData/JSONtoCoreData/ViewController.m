//
//  ViewController.m
//  JSONtoCoreData
//
//  Created by Parag Dulam on 30/12/15.
//  Copyright (c) 2015 Parag Dulam. All rights reserved.
//

#import "ViewController.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "JsonInfo.h"
#import "JsonViewController.h"

@interface ViewController ()<NSFetchedResultsControllerDelegate>
{

    NSArray *array;
    AppDelegate *aDel;
    
    

}
@end


@implementation ViewController
@synthesize fetchedResultsController= _fetchedResultsController;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.fetchedResultsController = nil;
    
    aDel=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)download:(id)sender
{

    
    NSURLRequest *myReq=[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.dropbox.com/s/4pushjbzex09txf/countries.json?dl=1"]];
    //@"http://api.sba.gov/geodata/city_links_for_state_of/ca.json"]];
    
    //https://www.dropbox.com/s/4pushjbzex09txf/countries.json?dl=0
    
    [NSURLConnection sendAsynchronousRequest:myReq queue:[NSOperationQueue mainQueue] completionHandler:
     ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
         
//         array=[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

    NSDictionary *parsedObject=[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
         
         NSArray *con_name = [parsedObject valueForKey:@"name"];
         NSArray *sta_name= [parsedObject valueForKey:@"status"];
         aDel=(AppDelegate *)[[UIApplication sharedApplication]delegate];
         
    
      // JsonInfo *jsonData=(JsonInfo *)[NSEntityDescription insertNewObjectForEntityForName:@"JsonInfo" inManagedObjectContext:aDel.managedObjectContext];
         
         
         NSFetchRequest *req=[[NSFetchRequest alloc]initWithEntityName:@"JsonInfo"];
         NSMutableArray *ar=[[aDel.managedObjectContext executeFetchRequest:req error:nil]mutableCopy];

         
         JsonInfo *jsonData;
         
         
          int  i=0;
         for(;i<parsedObject.count;i++)
         {
             
             if ([[ar valueForKey:@"country_name"]containsObject:con_name[i]])
             {
                 //notify duplicates
                
             }
             else
             {
                
                             jsonData=(JsonInfo *)[NSEntityDescription insertNewObjectForEntityForName:@"JsonInfo" inManagedObjectContext:aDel.managedObjectContext];

                              jsonData.country_name=con_name[i];
                              jsonData.state_name=sta_name[i];
             
             
             }
             
             
         }
        [aDel.managedObjectContext save:nil];
         NSLog(@"%d",i);
         
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Yo..!" message:@"Data Saved" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
         [alert show];
     }];
}




- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id  sectionInfo =[[_fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
    
    
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Set up the cell...
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
    
}



- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"JsonInfo" inManagedObjectContext:aDel.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"country_name" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:aDel.managedObjectContext sectionNameKeyPath:nil
                                                   cacheName:nil];
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
    
}



- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    JsonInfo *info = [_fetchedResultsController objectAtIndexPath:indexPath];
   cell.textLabel.text = info.country_name;
//    cell.detailTextLabel.text=info.state_name;
    
   // NSString *label=[NSString stringWithFormat:@"%@ %@",info.country_name,info.state_name];
   // cell.textLabel.text=label;
    //cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@",
      //                           info.company, info.version];
}



- (IBAction)display:(id)sender
{
 //   JsonViewController *my=[self.storyboard instantiateViewControllerWithIdentifier:@"abc"];
   // [self.navigationController pushViewController:my animated:YES];
    
[self.fetchedResultsController performFetch:nil];
  [self.tableView reloadData];

}


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}


@end

