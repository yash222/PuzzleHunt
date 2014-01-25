//
//  PHBeginGameViewController.h
//  PuzzleHunt
//
//  Created by Nick Troccoli on 1/25/14.
//  Copyright (c) 2014 Trancos. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PHGame;
@interface PHBeginGameViewController : UIViewController
@property (nonatomic, strong) PHGame *game;

- (IBAction)beginGame:(id)sender;

@end