//
//  TopicListingViewController.m
//  AmozonPracticeApp
//
//  Created by Abhijeet Mishra on 30/09/16.
//  Copyright © 2016 Abhijeet Mishra. All rights reserved.
//

#import "TopicListingViewController.h"
#import "TopicListingTableViewCell.h"
#import "ImageFloatingAnimationView.h"
#import <GoogleSignIn/GoogleSignIn.h>
#import "ViewController.h"
#import "CommonConstants.h"
#import "DragAndDropTableView.h"
#import "PagedViewController.h"
#import "MPCoachMarks.h"

@import Firebase;

@interface TopicListingViewController () <UITableViewDataSource, UITableViewDelegate, GIDSignInUIDelegate, UISearchResultsUpdating, UISearchBarDelegate, GADInterstitialDelegate>

@property (weak, nonatomic) IBOutlet DragAndDropTableView *tableView;

@property (nonatomic) FIRDatabaseReference* databaseRef;
@property (nonatomic) FIRDatabaseReference* userDatabaseRef;

@property (weak, nonatomic) IBOutlet UIImageView *blurImageView;
@property (weak, nonatomic) IBOutlet UIView *titleBackgroundView;
@property (weak, nonatomic) IBOutlet GADBannerView *bannerView;

@property (weak, nonatomic) IBOutlet UIView *loginView;

@property (weak, nonatomic) IBOutlet UIView *bubbleBackgroundView;

@property (nonatomic) NSMutableArray* dataArray;

@property (nonatomic) NSMutableArray* dataSourceArray;

@property (nonatomic) NSArray* openedArray;

@property (nonatomic) NSArray* completedArray;

@property (nonatomic) int removedBubblesCount;

@property (nonatomic) int totalBubblesCount;

@property(weak, nonatomic) IBOutlet GIDSignInButton *signInButton;

@property (nonatomic)  GADInterstitial* interstitial;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleViewHeightConstraints;

@property (strong, nonatomic) UISearchController *searchController;

@property (weak, nonatomic) ViewController* viewController;

@end

#define KEY_SETS @"sets"

#define IMAGE_ARRAY @[@"array",@"binary_tree",@"linked_list",@"queue",@"stack"]

@implementation TopicListingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = APP_COLOR;
    
    [GIDSignIn sharedInstance].uiDelegate = self;
    
    [FIRDatabase database].persistenceEnabled = YES;
    
    self.databaseRef = [[FIRDatabase database] referenceFromURL:@"https://amazonsets-298b8.firebaseio.com/"];
    
    self.userDatabaseRef = [[FIRDatabase database] referenceFromURL:@"https://amazonsets-298b8.firebaseio.com/"];
    
    [self createBubbles];
    
    [self ab_addSearchFunctionality];
    
    [self ab_customNavigationBar];
    
    [self ab_customRightBarButton];
    
    [self createInterstitialAd];
    
    self.title = @"All";
    self.navigationController.navigationBarHidden = YES;
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
     [self ab_checkForWalkthroughScreen];
    
    [self ab_fetchUserData];
}

- (void) viewDidAppear:(BOOL) animated {
    [self ab_fetchUpdatedData];
    [self showInterstitialAd];
}

- (void) ab_createCoachMarks {
    // Setup coach marks
    
    CGRect rectInTableView = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    CGRect coachmark1 = [self.tableView convertRect:rectInTableView toView:[self.tableView superview]];
    
    // Setup coach marks
    NSArray *coachMarks = @[
                            @{
                                @"rect": [NSValue valueWithCGRect:coachmark1],
                                @"caption": @"Select the company",
                                @"position":[NSNumber numberWithInteger:LABEL_POSITION_BOTTOM],
                                @"alignment":[NSNumber numberWithInteger:LABEL_ALIGNMENT_RIGHT],
                                @"showArrow":[NSNumber numberWithBool:YES]
                                }];
    
    MPCoachMarks *coachMarksView = [[MPCoachMarks alloc] initWithFrame:self.navigationController.view.bounds coachMarks:coachMarks];
    [self.navigationController.view addSubview:coachMarksView];
    [coachMarksView start];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KEY_IS_TOPIC_LIST_COACH_MARK_SEEN];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) ab_checkForWalkthroughScreen {
    BOOL isWalkthroughSeen = [[NSUserDefaults standardUserDefaults] boolForKey:KEY_IS_WALKTHROUGH_SEEN];
    if (!isWalkthroughSeen) {
        PagedViewController* onboardingViewController = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([PagedViewController class])];
        [self presentViewController:onboardingViewController animated:NO completion:nil];
    }
}

- (void) ab_customRightBarButton {
    UIButton* rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 30)];
    rightButton.backgroundColor = [UIColor clearColor];
    [rightButton setImage:[UIImage imageNamed:@"profile"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(leftBarPressed:) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem* barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.leftBarButtonItem = barButtonItem;
}

- (void) leftBarPressed:(UIButton*) button {
    [[FIRAuth auth] addAuthStateDidChangeListener:^(FIRAuth *_Nonnull auth,
                                                    FIRUser *_Nullable user) {
        if (user != nil) {
            // User is signed in.
        
            //TODO:: show logged in status
            
        }
        else {
       //show login view
            self.loginView.hidden = NO;
        }
    }];
}

- (void) ab_customNavigationBar {
    self.navigationController.navigationBar.barTintColor = APP_COLOR;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
}

- (void) ab_addSearchFunctionality {
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.barTintColor = APP_COLOR;
    self.searchController.searchBar.tintColor = [UIColor whiteColor];
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.delegate = self;
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSourceArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.dataSourceArray objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TopicListingTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TopicListingTableViewCell class])];
    NSString* dataTopic = self.dataSourceArray[indexPath.section][indexPath.row];
    [cell setTopic:dataTopic];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* dataTopic = self.dataSourceArray[indexPath.section][indexPath.row];
    ViewController* viewController = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([ViewController class])];
    viewController.topicName = dataTopic;
    viewController.completedArray = [self.completedArray mutableCopy];
    viewController.openedArray = [self.openedArray mutableCopy];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Search Controller methods

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = searchController.searchBar.text;
    [self searchForText:searchString scope:searchController.searchBar.selectedScopeButtonIndex];
    [self.tableView reloadData];
    
    BOOL isCoachMarkSeen = [[NSUserDefaults standardUserDefaults] boolForKey:KEY_IS_TOPIC_LIST_COACH_MARK_SEEN];
    
    if (self.dataSourceArray.count) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        if (!isCoachMarkSeen) {
            [self ab_createCoachMarks];
        }
    }
}

- (void) searchForText:(NSString*) searchString scope:(NSInteger) scopeIndex {
    if (!searchString.length) {
        //show all the results
        self.dataSourceArray = self.dataArray;
        return;
    }
    
    NSMutableArray* mutableDataSource = [@[] mutableCopy];
    
    for (NSArray* nameArray in self.dataArray) {
        for (NSString* name in nameArray) {
            if ([name rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound) {
                //add to the result
                [mutableDataSource addObject:name];
            }
        }
    }
    self.dataSourceArray = [@[[mutableDataSource copy]] mutableCopy];
}

#pragma mark - Bubble View methods
- (int) getRandomBubbleIndex {
    
    int max = (int)IMAGE_ARRAY.count;
    NSUInteger randomIndex = arc4random() % max;
    return (int)randomIndex;
}


- (int) getRandomBubbleTime {
    
    int max = 6;
    int min = 4;
    
    int randNum = rand() % (max - min) + min;
    return randNum;
}

- (UIImage*) getImageForBubbleIndex:(int) bubbleIndex {
    NSArray* imageArray = IMAGE_ARRAY;
    if (bubbleIndex < imageArray.count) {
        return [UIImage imageNamed:imageArray[bubbleIndex]];
    }
    return [UIImage imageNamed:imageArray[bubbleIndex%imageArray.count]];
}

- (void) createBubbles {
    
    self.totalBubblesCount = 1;
    
    for (int index = 0; index < self.totalBubblesCount; index++) {
        
        int randomIndex = [self getRandomBubbleIndex];
        
        ImageFloatingAnimationView* floatingView= [[ImageFloatingAnimationView alloc] initWithStartingPoint:CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height) image:[self getImageForBubbleIndex:randomIndex]];
        [floatingView addImage:[self getImageForBubbleIndex:randomIndex]];
        floatingView.minFloatObjectSize = floatingView.maxFloatObjectSize = 180;
        floatingView.animationDuration = [self getRandomBubbleTime];
        floatingView.imageViewAnimationCompleted = ^(UIImageView* imageView) {
            self.removedBubblesCount++;
            if (self.removedBubblesCount == self.totalBubblesCount) {
                [self removeIntroView];
            }
        };
        [self.bubbleBackgroundView addSubview:floatingView];
        [floatingView animateAfterDuration:index];
    }
}

- (void) removeIntroView {
    
    [[FIRAuth auth] addAuthStateDidChangeListener:^(FIRAuth *_Nonnull auth,
                                                    FIRUser *_Nullable user) {
        if (user != nil) {
            
            NSString* initialSubstring = [[user.email componentsSeparatedByString:@"@"] firstObject];
            
            [[NSUserDefaults standardUserDefaults] setValue:initialSubstring forKey:UNIQUE_ID];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            // User is signed in.
            self.loginView.hidden = YES;
            
            self.navigationItem.leftBarButtonItem = nil;
            
            self.navigationController.navigationBarHidden = NO;
            
            [self createBannerAd];
            
            [self showInterstitialAd];
        }
        else if (![[NSUserDefaults standardUserDefaults] valueForKey:KEY_IS_LOGIN_SCREEN_SHOWN] || ![[[NSUserDefaults standardUserDefaults] valueForKey:KEY_IS_LOGIN_SCREEN_SHOWN] boolValue]) {
            // No user is signed in.
            self.loginView.hidden = NO;
            
            [[NSUserDefaults standardUserDefaults] setValue:@YES forKey:KEY_IS_LOGIN_SCREEN_SHOWN];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }];
    
    [UIView animateWithDuration:1 animations:^{
        self.titleBackgroundView.hidden = YES;
        self.bubbleBackgroundView.hidden = YES;
    } completion:^(BOOL finished) {
        self.titleViewHeightConstraints.constant = 64;
    }];
}

#pragma mark - Login Callback methods

- (void) loginSuccessDone {
    self.loginView.hidden = YES;
    [self createBannerAd];
    [self createInterstitialAd];
    
    //TODO:: next version
    //show user profile status here
    self.navigationItem.leftBarButtonItem = nil;
}


- (void) loginFailed {
    self.loginView.hidden = NO;
}

#pragma mark - Ad methods

//- (void) createInterstitialAd {
//    self.interstitial =
//    [[GADInterstitial alloc] initWithAdUnitID:@"ca-app-pub-3743202420941577/5605948044"];
//    
//    GADRequest *request = [GADRequest request];
//    // Request test ads on devices you specify. Your test device ID is printed to the console when
//    // an ad request is made.
//    request.testDevices = @[ kGADSimulatorID, @"2077ef9a63d2b398840261c8221a0c9b" ];
//    [self.interstitial loadRequest:request];
//}

- (void) createBannerAd {
    self.bannerView.adUnitID = @"ca-app-pub-3743202420941577/2951813244";
    self.bannerView.rootViewController = self;
    [self.bannerView loadRequest:[GADRequest request]];
}

- (GADInterstitial *)createInterstitialAd {
    self.interstitial =
    [[GADInterstitial alloc] initWithAdUnitID:@"ca-app-pub-3743202420941577/5605948044"];
    
    GADRequest *request = [GADRequest request];
    // Request test ads on devices you specify. Your test device ID is printed to the console when
    // an ad request is made.
request.testDevices = @[ @"4979d821dabc9b7f43cb2f4dd7e3876c" ];
    [self.interstitial loadRequest:request];
    return self.interstitial;
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)interstitial {
    self.interstitial = [self createInterstitialAd];
}

- (void) showInterstitialAd {
    if ([self.interstitial isReady]) {
        [self.interstitial presentFromRootViewController:self];
    }
}

#pragma mark - Interstitial delegate

- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error {
    // Retrying failed interstitial loads is a rudimentary way of handling these errors.
    // For more fine-grained error handling, take a look at the values in GADErrorCode.
    self.interstitial = [self createInterstitialAd];
}

#pragma mark - FIR update methods

- (void) ab_fetchUserData {
    [self.userDatabaseRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        id data = snapshot.value;
        
        NSString* uniqueID = [[NSUserDefaults standardUserDefaults] valueForKey:UNIQUE_ID];
        
        NSString* userKey = @"users";
        
        NSDictionary* userDictionary = data[userKey][uniqueID];
        
        if (userDictionary) {
            //parse user data
            self.completedArray = userDictionary[KEY_COMPLETED];
            self.openedArray = userDictionary[KEY_OPENED];
            self.viewController.completedArray = [self.completedArray mutableCopy];
            self.viewController.openedArray = [self.openedArray mutableCopy];
            
            if (userDictionary[KEY_SET_ORDER] && ![userDictionary[KEY_SET_ORDER] isKindOfClass:[NSNull class]]) {
                
            }
        }
        else {
            //create user data
            
            NSDictionary* emptyDict = @{uniqueID:@{KEY_COMPLETED:@[DIVIDER_KEY],KEY_OPENED:@[DIVIDER_KEY]}};
            
            //check for 1st user state
            if (!data[userKey] || [data[userKey] isKindOfClass:[NSNull class]]) {
                //create the super set key
                
                NSDictionary* emptySuperDict = @{userKey:emptyDict};
                
                [self.userDatabaseRef updateChildValues:emptySuperDict];
            }
            else {
                [[self.userDatabaseRef child:userKey] updateChildValues:emptyDict];
            }
            self.completedArray = [@[DIVIDER_KEY,DIVIDER_KEY] copy];
            self.openedArray = [@[DIVIDER_KEY,DIVIDER_KEY] copy];
        }
        
        //fetch list data
        
        data = snapshot.value[KEY_SETS];
        
        self.dataArray = ([data isKindOfClass:[NSDictionary class]])?([@[([((NSDictionary*)data).allKeys mutableCopy])] mutableCopy]):(nil);
        
        self.dataSourceArray = [self.dataArray mutableCopy];
        
        [self.tableView reloadData];
        if (self.dataSourceArray.count) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            BOOL isCoachMarkSeen = [[NSUserDefaults standardUserDefaults] boolForKey:KEY_IS_TOPIC_LIST_COACH_MARK_SEEN];
            if (!isCoachMarkSeen) {
                [self ab_createCoachMarks];
            }
        }
    }];
}

- (void) ab_fetchUpdatedData {
    [self.databaseRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
        
        id data = snapshot.value[KEY_SETS];
        
        self.dataArray = ([data isKindOfClass:[NSDictionary class]])?([@[([((NSDictionary*)data).allKeys mutableCopy])] mutableCopy]):(nil);
        
        self.dataSourceArray = [self.dataArray mutableCopy];
        
        [self.tableView reloadData];
        if (self.dataSourceArray.count) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            BOOL isCoachMarkSeen = [[NSUserDefaults standardUserDefaults] boolForKey:KEY_IS_TOPIC_LIST_COACH_MARK_SEEN];
            if (!isCoachMarkSeen) {
                [self ab_createCoachMarks];
            }
        }
    } withCancelBlock:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
}

#pragma mark -DragAndDropTableView methods

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSObject *o = [[self.dataSourceArray objectAtIndex:sourceIndexPath.section] objectAtIndex:sourceIndexPath.row];
    [[self.dataSourceArray objectAtIndex:sourceIndexPath.section] removeObjectAtIndex:sourceIndexPath.row];
    [[self.dataSourceArray objectAtIndex:destinationIndexPath.section] insertObject:o atIndex:destinationIndexPath.row];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(UITableViewCellEditingStyleInsert == editingStyle)
    {
        // inserts are always done at the end
        
        [tableView beginUpdates];
        [self.dataSourceArray addObject:[NSMutableArray array]];
        [tableView insertSections:[NSIndexSet indexSetWithIndex:[self.dataSourceArray count]-1] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView endUpdates];
        
    }
    else if(UITableViewCellEditingStyleDelete == editingStyle)
    {
        // check if we are going to delete a row or a section
        [tableView beginUpdates];
        if([[self.dataSourceArray objectAtIndex:indexPath.section] count] == 0)
        {
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.dataSourceArray removeObjectAtIndex:indexPath.section];
        }
        else
        {
            // Delete the row from the table view.
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            // Delete the row from the data source.
            [[self.dataSourceArray objectAtIndex:indexPath.section] removeObjectAtIndex:indexPath.row];
        }
        [tableView endUpdates];
    }
}

#pragma mark UITableViewDelegate

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}


- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (IBAction)guestButtonPressed:(UIButton *)sender {
    self.loginView.hidden = YES;
}
#pragma mark -

#pragma mark DragAndDropTableViewDataSource

-(BOOL)canCreateNewSection:(NSInteger)section
{
    return YES;
}

#pragma mark -

#pragma mark DragAndDropTableViewDelegate

-(void)tableView:(UITableView *)tableView willBeginDraggingCellAtIndexPath:(NSIndexPath *)indexPath placeholderImageView:(UIImageView *)placeHolderImageView
{
    // this is the place to edit the snapshot of the moving cell
    // add a shadow
    placeHolderImageView.layer.shadowOpacity = .3;
    placeHolderImageView.layer.shadowRadius = 1;
}

-(void)tableView:(DragAndDropTableView *)tableView didEndDraggingCellAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)toIndexPath placeHolderView:(UIImageView *)placeholderImageView
{
    // The cell has been dropped. Remove all empty sections (if you want to)
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    for(int i = 0; i < self.dataSourceArray.count; i++)
    {
        NSArray *ary = [self.dataSourceArray objectAtIndex:i];
        if(ary.count == 0)
            [indexSet addIndex:i];
    }
    
    [tableView beginUpdates];
    [tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.dataSourceArray removeObjectsAtIndexes:indexSet];
    [tableView endUpdates];
}

-(CGFloat)tableView:tableView heightForEmptySection:(int)section
{
    return 10;
}

@end
