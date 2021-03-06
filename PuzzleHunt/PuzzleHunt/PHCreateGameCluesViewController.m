//
//  PHCreateGameCluesViewController.m
//  PuzzleHunt
//
//  Created by Nick Troccoli on 1/25/14.
//  Copyright (c) 2014 Trancos. All rights reserved.
//

#import "PHCreateGameCluesViewController.h"
#import "PHClueCell.h"
#import "PHClueLibraryViewController.h"
#import "PHCreateClueViewController.h"
#import "PHClue.h"
#import "PHGame.h"


@interface PHCreateGameCluesViewController ()
@property (nonatomic, strong) NSMutableArray *cluesArray;
@end

@implementation PHCreateGameCluesViewController
@synthesize cluesArray = _cluesArray;


- (NSMutableArray *)cluesArray
{
    if (!_cluesArray) {
        _cluesArray = [[NSMutableArray alloc] init];
    }
    
    return _cluesArray;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:YES];
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Save Game"
                                                               style:UIBarButtonItemStyleBordered target:self action:@selector(saveGame:)];
    
    UIBarButtonItem *space1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem *space2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                            target:self action:nil];
    [self.navigationController.toolbar setItems:@[space1, button, space2]];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:YES animated:YES];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIColor *offWhite = [UIColor colorWithRed:246.0f/255.0f green:246.0f/255.0f blue:246.0f/255.0f alpha:1.0];
    
    NSMutableDictionary *navBarTextAttributes = [NSMutableDictionary dictionaryWithCapacity:1];
    
    [navBarTextAttributes setObject:offWhite forKey:NSForegroundColorAttributeName ];
    
    self.navigationController.navigationBar.titleTextAttributes = navBarTextAttributes;
    
    // Add an edit button
    [self.navigationItem setRightBarButtonItem:[self editButtonItem]];
    
    // Set the table background to blue
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor colorWithRed:99.0/255.0
                                                     green:218.0/255.0
                                                      blue:255.0/255.0
                                                     alpha:1.0];
}


- (void)saveGame:(UIBarButtonItem *)sender
{
    [self.game setGameClues:[self cluesArray]];
    [self.delegate userCreatedGame:self.game];
}


#pragma mark - Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cluesArray.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        static NSString *CellIdentifier = @"addClueCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                
        return cell;
    } else {
        // Make a new Clue Cell and configure it for the clue
        static NSString *CellIdentifier = @"clueCell";
        PHClueCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        [cell bindClue:[self.cluesArray objectAtIndex:[indexPath row] - 1]
                forRow:indexPath.row - 1];
        
        return cell;
    }
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Delete the row from the data source
        [self.cluesArray removeObjectAtIndex:[indexPath row] - 1];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The user can't edit the "add clue" row
    if ([indexPath row] == 0) return false;
    return true;
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // the user shouldn't be able to move the "add clue" row
    if ([indexPath row] == 0) return false;
    return true;
}


- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    // Make sure we can't move clues past the "add clue" row
    if ([proposedDestinationIndexPath row] == 0) {
        NSIndexPath *modifiedIP = [NSIndexPath indexPathForRow:1
                                                     inSection:proposedDestinationIndexPath.section];
        
        return modifiedIP;
    }
    
    return proposedDestinationIndexPath;
}



- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    [self.cluesArray exchangeObjectAtIndex:[fromIndexPath row]
                         withObjectAtIndex:[toIndexPath row]];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row] == 0) return 44.0;
    return 100.0;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // You cannot select already-made clues
    if ([indexPath row] != 0) [tableView deselectRowAtIndexPath:indexPath
                                                       animated:NO];
    
    else {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:@"Create New Clue", @"Browse Clue Library", nil];
        
        [sheet showInView:self.view];
    }
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // The cancel button
    if (buttonIndex == 2) {
        [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                      animated:YES];
        
    // The "Create new clue" button
    } else if (buttonIndex == 0) {
        [self performSegueWithIdentifier:@"createClue"
                                  sender:self];
    
    // The "library" button
    } else if (buttonIndex == 1) {
        [self performSegueWithIdentifier:@"browseClueLibrary"
                                  sender:self];
    }
}


- (void)clueCreated:(PHClue *)clue
{
    [[self cluesArray] addObject:clue];
    [self.tableView reloadData];
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"createClue"]) {
        PHCreateClueViewController *createVC = [[(UINavigationController *)[segue destinationViewController] viewControllers] objectAtIndex:0];
        
        [createVC setClueDelegate:self];
        [createVC setClue:[[PHClue alloc] init]];
    } else if ([[segue identifier] isEqualToString:@"browseClueLibrary"]) {
        PHClueLibraryViewController *libraryVC = [[(UINavigationController *)[segue destinationViewController] viewControllers] objectAtIndex:0];
        
        [libraryVC setClueDelegate:self];
    }
}


@end
