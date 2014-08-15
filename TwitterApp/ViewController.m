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
#import "STTwitter.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *array;
@property (strong, nonatomic) NSDictionary *queryData;
@property (strong, nonatomic) ACAccountStore *account;
@property (strong, nonatomic) ACAccountType *accountType;
@property (strong, nonatomic) NSMutableArray *twitterFeed;
@property (strong, nonatomic) NSDictionary *t;

@end

@implementation ViewController



- (void)viewDidLoad
{
    _account = [[ACAccountStore alloc] init];
    _accountType = [_account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [super viewDidLoad];
    
    //[self twitterTimeline2];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

#pragma mark Table View Data Source Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.twitterFeed.count;
    
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellID =  @"CELLID" ;
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        
    }
    
    NSInteger idx = indexPath.row;
    NSDictionary *t = self.twitterFeed[idx];
    
    cell.textLabel.text = t[@"text"];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}



- (void)twitterTimeline {
    NSLog(@"Twitter timeline");
    
    
    //ACAccountStore * account = [[ACAccountStore alloc] init];
    //ACAccountType *accountType = [_account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [_account requestAccessToAccountsWithType:_accountType options:nil completion:^(BOOL granted, NSError * error){
        if (granted == YES) {
            NSArray *arrayOfAccounts = [_account accountsWithAccountType:_accountType];
            if([arrayOfAccounts count] > 0){
                
                ACAccount *twitterAccount = [arrayOfAccounts lastObject];
                
                NSURL *requestAPI = [NSURL URLWithString:@" "];
                
                NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
                
                SLRequest *posts = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:requestAPI parameters:parameters];
                
                posts.account = twitterAccount;
                
                [posts performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    
                    self.array = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                    
                    NSLog(@"Timeline Response: %@\n", self.array);
                    if (self.array.count != 0) {
                        if(self.tableView != nil){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                                [self.tableView reloadData];
                            
                        });
                        }
                        
                    }
                    
                }];
            }
        }
        else {
            NSLog(@"%@", [error localizedDescription]);
        }
        
    }];
}

- (void) twitterTimeline2 {
    @autoreleasepool {
    STTwitterAPI *twitter = [STTwitterAPI twitterAPIOSWithFirstAccount];
    
    [twitter verifyCredentialsWithSuccessBlock:^(NSString *username) {
        NSLog(@"-- Account: %@", username);
        
        /*
            [twitter getUser:username count:20 successBlock:^(NSArray *statuses) {
                self.twitterFeed = [NSMutableArray arrayWithArray:statuses];
                
                [self.tableView reloadData];
                
            } errorBlock:^(NSError *error) {
                NSLog(@"%@",error.debugDescription);
            }];
        */
            [twitter getHomeTimelineSinceID:nil count:20 successBlock:^(NSArray *statuses) {
                self.twitterFeed = [NSMutableArray arrayWithArray:statuses];
                
                [self.tableView reloadData];
            } errorBlock:^(NSError *error) {
                NSLog(@"%@",error.debugDescription);
            }];
        
        [twitter postStatusesFilterUserIDs:nil                             keywordsToTrack:@[@"Apple"] 
                     locationBoundingBoxes:nil
                                 delimited:@20
                             stallWarnings:nil
                             progressBlock:^(NSDictionary *response) {
                                 
                                 if ([response isKindOfClass:[NSDictionary class]] == NO) {
                                     NSLog(@"Invalid tweet (class %@): %@", [response class], response);
                                     
                                     exit(1);
                                     return;
                                 }
                                 
                                 printf("-----------------------------------------------------------------\n");
                                 printf("-- user: @%s\n", [[response valueForKeyPath:@"user.screen_name"] cStringUsingEncoding:NSUTF8StringEncoding]);
                                 printf("-- text: %s\n", [[response objectForKey:@"text"] cStringUsingEncoding:NSUTF8StringEncoding]);
                                 
                                 
                                 
                                 //_t = [response objectForKey:@"text"];
                                 //[self.tableView reloadData];
                             } stallWarningBlock:nil errorBlock:^(NSError *error) {
                                 NSLog(@"Stream error: %@", error);
                                 exit(1);
                             }];
        
        
    } errorBlock:^(NSError *error) {
        NSLog(@"-- %@", [error localizedDescription]);
        exit(1);
    }];
    
    /**/
    
    [[NSRunLoop currentRunLoop] run];
    
}


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
    [tweetSheet setInitialText:@""];
    
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

-(void) updateLoop{
    
    

    


}

- (IBAction)updateButton:(id)sender {
    /*
    [self performSelectorInBackground:@selector(updateLoop) withObject:nil];
     */
    NSTimer *timer = [NSTimer timerWithTimeInterval:1.0
                                             target:self
                                           selector:@selector(twitterTimeline2)
                                           userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    

}

@end
