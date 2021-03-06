//
//  PHGameStore.m
//  PuzzleHunt
//
//  Created by Nick Troccoli on 1/25/14.
//  Copyright (c) 2014 Trancos. All rights reserved.
//

#import "PHGameStore.h"
#import "PHGame.h"
#import <Parse/Parse.h>
#import <CoreLocation/CoreLocation.h>
#import "PHAppDelegate.h"

#define DEBUG 0

@interface PHGameStore() <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locManager;
@property (nonatomic, strong) NSString *teamID;
@end

@implementation PHGameStore
@synthesize locManager = _locManager;
@synthesize currLocation = _currLocation;



- (void)startUpdatingLocation
{
    [self.locManager startUpdatingLocation];

}


- (void)stopUpdatingLocation
{
    [self.locManager stopUpdatingLocation];
}


- (CLLocationManager *)locManager
{
    if (!_locManager) {
        _locManager = [[CLLocationManager alloc] init];
        [_locManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
        [_locManager setDelegate:self];
    }
    
    return _locManager;
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [self setCurrLocation:[locations lastObject]];
    
    if (self.teamID) {
        PFObject *team = [PFObject objectWithoutDataWithClassName:@"Team" objectId:self.teamID];
        [team refreshInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            PFGeoPoint *pt = [PFGeoPoint geoPointWithLocation:self.currLocation];
            team[@"currLocation"] = pt;
            [team saveInBackground];
            
            PFPush *push = [[PFPush alloc] init];
            NSString *gameName = self.currGame[@"gameName"];
            [push setChannel:gameName];
            [push setData:@{PuzzleHuntNotificationTypeKey: PuzzleHuntNotificationTypeLocation}];
            [push sendPushInBackground];
        }];
        
        
    }
}


+ (PHGameStore *)sharedStore
{
    static PHGameStore *sharedStore;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStore = [[PHGameStore alloc] init];
        [sharedStore startUpdatingLocation];
    });
    
    return sharedStore;
}

- (PFObject *)createPFObjectFromClue:(PHClue *)clue {
    PFObject *pfClue = [PFObject objectWithClassName:@"Clue"];
    pfClue[@"clueName"] = [clue clueName];
    pfClue[@"clueText"] = [clue clueDescription];
    pfClue[@"hints"] = [clue hints];
    pfClue[@"duration"] = [[NSNumber alloc] initWithInteger:[clue time]];
    pfClue[@"location"] = [PFGeoPoint geoPointWithLatitude:[clue latitude].doubleValue
                                                 longitude:[clue longitude].doubleValue];
    
    return pfClue;
}

- (void)uploadGame:(PHGame *)game {
    
    NSMutableArray *pfClueMutableArray = [[NSMutableArray alloc]init];
    for (PHClue *clue in [game gameClues]) {
        [pfClueMutableArray addObject:[self createPFObjectFromClue:clue]];
    }
    
    PFObject *pfGame = [PFObject objectWithClassName:@"Game"];
    pfGame[@"gameName"] = [game gameName];
    pfGame[@"clues"] = pfClueMutableArray;
    pfGame[@"gameDescription"] = [game gameDescription];
    pfGame[@"totalTime"] = [[NSNumber alloc] initWithInteger:[game totalTime]];
    pfGame[@"teams"] = @[];
    [self setCurrGame:pfGame];
    [pfGame saveInBackground];
}

- (void)fetchLiveGamesWithCompletionBlock:(void (^)(NSArray *liveGames, NSError *err))completionBlock {
#if DEBUG == 0
    PFQuery *query = [PFQuery queryWithClassName:@"Game"];
    [query orderByAscending:@"gameName"];
    //[query includeKey:@"teams"];
    [query findObjectsInBackgroundWithBlock:completionBlock];
#endif

#if DEBUG == 1
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSArray *names = @[@"Nick", @"Kristen", @"Bharad", @"Avi"];
    
    for (int i = 0; i < 4; i++) {
        PHGame *game = [[PHGame alloc] initWithName:[names objectAtIndex:i]
                                        Description:@"This is a puzzlehunt game for the ages!"
                                              Clues:nil];
        
        [array addObject:game];
    }
    
    completionBlock(array, nil);
#endif
}


- (void)fetchAllCluesWithCompletionBlock:(void (^)(NSArray *clues, NSError *err))completionBlock
{
    PFQuery *query = [PFQuery queryWithClassName:@"Clue"];
    [query orderByAscending:@"duration"];
    [query findObjectsInBackgroundWithBlock:completionBlock];
}


- (void)addTeamWithName:(NSString *)name toGame:(PFObject *)game
{
    [self setCurrGame:game];
    
    // Make a new PFObject for the team
    PFObject *team = [PFObject objectWithClassName:@"Team"];
    team[@"currentClueNum"] = [[NSNumber alloc] initWithInteger:1];
    team[@"currClueHintsUsed"] = [[NSNumber alloc] initWithInteger:0];
    team[@"score"] = [[NSNumber alloc] initWithInteger:0];
    team[@"game"] = game;
    team[@"rank"] = [[NSNumber alloc] initWithInteger:1];
    team[@"teamName"] = name;
    
    PFGeoPoint *pt = [PFGeoPoint geoPointWithLocation:[self currLocation]];
                      
                      
    team[@"currLocation"] = pt;
    
    [team saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        [self setTeamID:[team objectId]];
        // Update the game object to have this team associated with it
        [game addObject:name forKey:@"teams"];
        
        [game saveInBackground];
    }];
}

- (void)fetchTeamsByRankWithCompletionBlock:(void (^)(NSArray *teams, NSError *err))completionBlock
{
    PFQuery *query = [PFQuery queryWithClassName:@"Team"];
    //[query whereKey:@"game" equalTo:[self currGame]];
    [query orderByAscending:@"rank"];
    [query findObjectsInBackgroundWithBlock:completionBlock];
}

@end
