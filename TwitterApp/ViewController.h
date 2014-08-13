//
//  ViewController.h
//  TwitterApp
//
//  Created by kittiphong xayasane on 2014-08-12.
//  Copyright (c) 2014 Kittiphong Xayasane. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController < UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)postButton:(id)sender;


@end
