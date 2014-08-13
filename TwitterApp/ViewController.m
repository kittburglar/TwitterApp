//
//  ViewController.m
//  TwitterApp
//
//  Created by kittiphong xayasane on 2014-08-12.
//  Copyright (c) 2014 Kittiphong Xayasane. All rights reserved.
//

#import "ViewController.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
@interface ViewController ()

@property (strong, nonatomic) NSArray *array;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self twitterTimeline];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

#pragma mark Table View Data Source Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [_array count];
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Creates each cell for the table view.
    
    static NSString *cellID =  @"CELLID" ;
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        
    }
    
    NSDictionary *tweet = _array[indexPath.row];
    
    cell.textLabel.text = tweet[@"text"];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (void)twitterTimeline {
    
    ACAccountStore * account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [account requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError * error){
        if (granted == YES) {
            NSArray *arrayOfAccounts = [account accountsWithAccountType:accountType];
            if([arrayOfAccounts count] > 0){
                
                ACAccount *twitterAccount = [arrayOfAccounts lastObject];
                
                NSURL *requestAPI = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/user_timeline.json"];
                
                NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
                
                [parameters setObject:@"100" forKey:@"count"];
                
                [parameters setObject:@"1" forKey:@"include_entities"];
                
                SLRequest *posts = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:requestAPI parameters:parameters];
                
                posts.account = twitterAccount;
                
                [posts performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    
                    self.array = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                    
                    if (self.array.count != 0) {
                       
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.tableView reloadData];
                        });
                        
                    }
                    
                }];
            }
        }
        else {
            NSLog(@"%@", [error localizedDescription]);
        }
        
    }];
}




- (IBAction)postButton:(id)sender {
    NSLog(@"postButton Hit");
    //  Create an instance of the Tweet Sheet
    SLComposeViewController *tweetSheet = [SLComposeViewController
                                           composeViewControllerForServiceType:
                                           SLServiceTypeTwitter];
    
    // Sets the completion handler.  Note that we don't know which thread the
    // block will be called on, so we need to ensure that any required UI
    // updates occur on the main queue
    tweetSheet.completionHandler = ^(SLComposeViewControllerResult result) {
        switch(result) {
                //  This means the user cancelled without sending the Tweet
            case SLComposeViewControllerResultCancelled:
                break;
                //  This means the user hit 'Send'
            case SLComposeViewControllerResultDone:
                break;
        }
    };
    
    //  Set the initial body of the Tweet
    [tweetSheet setInitialText:@"just setting up my twttr"];
    
    //  Adds an image to the Tweet.  For demo purposes, assume we have an
    //  image named 'larry.png' that we wish to attach
    if (![tweetSheet addImage:[UIImage imageNamed:@"larry.png"]]) {
        NSLog(@"Unable to add the image!");
    }
    
    //  Add an URL to the Tweet.  You can add multiple URLs.
    if (![tweetSheet addURL:[NSURL URLWithString:@"http://twitter.com/"]]){
        NSLog(@"Unable to add the URL!");
    }
    
    //  Presents the Tweet Sheet to the user
    [self presentViewController:tweetSheet animated:NO completion:^{
        NSLog(@"Tweet sheet has been presented.");
    }];
}
@end
