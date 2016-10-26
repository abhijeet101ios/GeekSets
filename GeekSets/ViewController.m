//
//  ViewController.m
//  AmozonPracticeApp
//
//  Created by Abhijeet Mishra on 23/09/16.
//  Copyright © 2016 Abhijeet Mishra. All rights reserved.
//

#import "ViewController.h"
#import "AmazonSetTableViewCell.h"
#import "DZNWebViewController.h"
#import "GeekyWebViewController.h"
#import "ImageFloatingAnimationView.h"
#import "CommonConstants.h"
#import "MPCoachMarks.h"
#import "Utility.h"
#import "GSAnalytics.h"


@import GoogleMobileAds;
@import Firebase;

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, AmazonSetTableViewCellDelegate, UISearchResultsUpdating, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet GADBannerView *bannerView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (nonatomic) UISearchController* searchController;

@property (nonatomic) FIRDatabaseReference* databaseRef;
@property (nonatomic) NSArray* dataArray;
@property (nonatomic) NSArray* dataSourceArray;

@property (nonatomic)  GADInterstitial* interstitial;

@property (nonatomic) BOOL isInterstitialAdToBeStopped;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bannerAdHeight;

@property (nonatomic) NSDate* lastInterstitialAdDate;

@property (nonatomic) NSString* lastSelectedSet;

@property (nonatomic) NSDate* lastSelectedSetTimeStamp;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = APP_COLOR;
    self.databaseRef = [[FIRDatabase database] referenceFromURL:@"https://amazonsets-298b8.firebaseio.com/"];
  
    [self ab_addSearchFunctionality];
   // [self writeAmazonData];
    [self ab_updateSegmentedControlUI];
    
    self.title = self.topicName;
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self ab_fetchUpdatedData];
  
    BOOL isBannerAdDisabled = [[Utility sharedInsance] getIsAdDisabled:bannerAdSetList];
    
    if (isBannerAdDisabled) {
        self.bannerAdHeight.constant = 0;
    }
    else {
        [self createBannerAd];
    }
   
    if (!self.isMovingToParentViewController) {
        [self createInterstitialAd];
        if (self.lastInterstitialAdDate) {
            NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.lastInterstitialAdDate];
                self.isInterstitialAdToBeStopped = (timeInterval < 2*60);
          }
        self.lastInterstitialAdDate = [NSDate date];
    }
    
    self.navigationController.navigationBarHidden = NO;
    
    if (!self.isMovingToParentViewController) {
        
        BOOL isTickListCoachMarkSeen = [[NSUserDefaults standardUserDefaults] boolForKey:KEY_IS_TICK_LIST_COACH_MARK_SEEN];
        if (!isTickListCoachMarkSeen) {
            [self ab_createTickCoachMarks];
        }
    }
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void) viewDidAppear:(BOOL)animated {
    if (!self.isMovingToParentViewController) {
        [self ab_setEventName:EVENT_ANALYTICS_COMPANY_BACK_PRESSED forKeys:@{KEY_ANALYTICS_TIME_SPENT:[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSinceDate:self.lastSelectedSetTimeStamp]],KEY_ANALYTICS_SET_NAME:self.lastSelectedSet}];

    }
}

#pragma mark - Analytics Methods

- (void) ab_setEventName:(NSString*) eventName forKeys:(NSDictionary*) keys {
    [[GSAnalytics sharedInstance] setEventName:eventName withKeys:keys];
}

- (void) ab_createCoachMarks {
    // Setup coach marks
    
    CGRect rectInTableView = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    CGRect coachmark1 = [self.tableView convertRect:rectInTableView toView:[self.tableView superview]];
    
    // Setup coach marks
    NSArray *coachMarks = @[
                            @{
                                @"rect": [NSValue valueWithCGRect:coachmark1],
                                @"caption": @"Select the set",
                                @"position":[NSNumber numberWithInteger:LABEL_POSITION_BOTTOM],
                                @"alignment":[NSNumber numberWithInteger:LABEL_ALIGNMENT_CENTER],
                                @"showArrow":[NSNumber numberWithBool:YES]
                                }];
    
    MPCoachMarks *coachMarksView = [[MPCoachMarks alloc] initWithFrame:self.navigationController.view.bounds coachMarks:coachMarks];
    [self.navigationController.view addSubview:coachMarksView];
    [coachMarksView start];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KEY_IS_SET_LIST_COACH_MARK_SEEN];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) ab_createTickCoachMarks {
    // Setup coach marks
    
    AmazonSetTableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    CGRect superViewFrame = cell.actionButton.frame;
    
   // CGRect rectInTableView = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    CGRect coachmark1 = [self.tableView convertRect:superViewFrame toView:[self.tableView superview]];
    
    CGFloat coachMarkDimension = MAX(coachmark1.size.width, coachmark1.size.height);
    
    CGFloat offSetMargin = (IS_IPHONE_6_PLUS)?(37):((IS_IPHONE_6)?(([UIDevice currentDevice].systemVersion.floatValue >= 10)?(37):(52)):((IS_IPHONE_5)?(37):((IS_IPAD_PRO_12INCH)?(37):(-7.5))));
    
    coachmark1 = CGRectMake(coachmark1.origin.x, coachmark1.origin.y + offSetMargin, coachMarkDimension, coachMarkDimension);
    
    // Setup coach marks
    NSArray *coachMarks = @[
                            @{
                                @"rect": [NSValue valueWithCGRect:coachmark1],
                                @"caption": @"Mark set as completed once done",
                                @"shape": [NSNumber numberWithInteger:SHAPE_CIRCLE],
                                @"position":[NSNumber numberWithInteger:LABEL_POSITION_BOTTOM],
                                @"alignment":[NSNumber numberWithInteger:LABEL_ALIGNMENT_LEFT],
                                @"showArrow":[NSNumber numberWithBool:YES]
                                }];
    
    MPCoachMarks *coachMarksView = [[MPCoachMarks alloc] initWithFrame:self.navigationController.view.bounds coachMarks:coachMarks];
    [self.navigationController.view addSubview:coachMarksView];
    [coachMarksView start];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KEY_IS_TICK_LIST_COACH_MARK_SEEN];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) ab_updateSegmentedControlUI {
   // [self.segmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
}

- (IBAction)cancelButtonPressed:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)segmentedControlTapped:(UISegmentedControl *)sender {

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

#pragma mark - Search Controller methods

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = searchController.searchBar.text;
    [self searchForText:searchString scope:searchController.searchBar.selectedScopeButtonIndex];
    [self.tableView reloadData];
    if (self.dataSourceArray.count) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        BOOL isCoachMarkSeen = [[NSUserDefaults standardUserDefaults] boolForKey:KEY_IS_SET_LIST_COACH_MARK_SEEN];
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
    
    for (NSDictionary* dict in self.dataArray) {
        if ([dict[KEY_NAME] rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound) {
            //add to the result
            [mutableDataSource addObject:dict];
        }
    }
    self.dataSourceArray = [mutableDataSource copy];
}


//- (void) createInterstitialAd {
//        self.interstitial =
//        [[GADInterstitial alloc] initWithAdUnitID:@"ca-app-pub-3940256099942544/4411468910"];
//        
//        GADRequest *request = [GADRequest request];
//        // Request test ads on devices you specify. Your test device ID is printed to the console when
//        // an ad request is made.
//        request.testDevices = @[ kGADSimulatorID, @"2077ef9a63d2b398840261c8221a0c9b" ];
//        [self.interstitial loadRequest:request];
//}

- (void) createBannerAd {
    self.bannerView.adUnitID = @"ca-app-pub-3743202420941577/2951813244";
    self.bannerView.rootViewController = self;
    self.bannerView.adSize = kGADAdSizeSmartBannerPortrait ;
    [self.bannerView loadRequest:[GADRequest request]];
}

#pragma Data Write Methods

- (void) writeAngularJSData {
    
    //FIRDatabaseReference* dbWriteReference = [self.databaseRef child:KEY_SETS];
    
    // dbWriteReference = [self.databaseRef child:@"Amazon"];
    
    NSArray* inputArray = @[@{@"AngularJS - Home":@"https://www.tutorialspoint.com/angularjs/index.htm"},
                            @{@"Overview":@"https://www.tutorialspoint.com/angularjs/angularjs_overview.htm"},
                            @{@"Environment Setup":@"https://www.tutorialspoint.com/angularjs/angularjs_environment.htm"},
                            @{@"MVC Architecture":@"https://www.tutorialspoint.com/angularjs/angularjs_mvc_architecture.htm"},
                            @{@"First Application":@"https://www.tutorialspoint.com/angularjs/angularjs_first_application.htm"},
                            @{@"Directives":@"https://www.tutorialspoint.com/angularjs/angularjs_directives.htm"},
                            @{@"Expressions":@"https://www.tutorialspoint.com/angularjs/angularjs_expressions.htm"},
                            @{@"Controllers":@"https://www.tutorialspoint.com/angularjs/angularjs_controllers.htm"},
                            @{@"Filters":@"https://www.tutorialspoint.com/angularjs/angularjs_filters.htm"},
                            @{@"Tables":@"https://www.tutorialspoint.com/angularjs/angularjs_tables.htm"},
                            @{@"HTML DOM":@"https://www.tutorialspoint.com/angularjs/angularjs_html_dom.htm"},
                            @{@"Modules":@"https://www.tutorialspoint.com/angularjs/angularjs_modules.htm"},
                            @{@"Forms":@"https://www.tutorialspoint.com/angularjs/angularjs_forms.htm"},
                            @{@"Includes":@"https://www.tutorialspoint.com/angularjs/angularjs_includes.htm"},
                            @{@"Ajax":@"https://www.tutorialspoint.com/angularjs/angularjs_ajax.htm"},
                            @{@"Views":@"https://www.tutorialspoint.com/angularjs/angularjs_views.htm"},
                            @{@"Scopes":@"https://www.tutorialspoint.com/angularjs/angularjs_scopes.htm"},
                            @{@"Services":@"https://www.tutorialspoint.com/angularjs/angularjs_services.htm"},
                            @{@"Dependency Injection":@"https://www.tutorialspoint.com/angularjs/angularjs_dependency_injection.htm"},
                            @{@"Custom Directives":@"https://www.tutorialspoint.com/angularjs/angularjs_custom_directives.htm"},
                            @{@"Internalization":@"https://www.tutorialspoint.com/angularjs/angularjs_internationalization.htm"},
                            @{@"Notepad Application":@"https://www.tutorialspoint.com/angularjs/angularjs_notepad_application.htm"},
                            @{@"Bootstrap Application":@"https://www.tutorialspoint.com/angularjs/angularjs_bootstrap_application.htm"},
                            @{@"Login Application":@"https://www.tutorialspoint.com/angularjs/angularjs_login_application.htm"},
                            @{@"Upload File":@"https://www.tutorialspoint.com/angularjs/angularjs_upload_file.htm"},
                            @{@"Inline Application":@"https://www.tutorialspoint.com/angularjs/angularjs_in_line_application.htm"},
                            @{@"Nav Menu":@"https://www.tutorialspoint.com/angularjs/angularjs_nav_menu.htm"},
                            @{@"Switch Menu":@"https://www.tutorialspoint.com/angularjs/angularjs_switch_menu.htm"},
                            @{@"Order Form":@"https://www.tutorialspoint.com/angularjs/angularjs_order_form.htm"},
                            @{@"Search Tab":@"https://www.tutorialspoint.com/angularjs/angularjs_search_tab.htm"},
                            @{@"Drag Application":@"https://www.tutorialspoint.com/angularjs/angularjs_drag_application.htm"},
                            @{@"Cart Application":@"https://www.tutorialspoint.com/angularjs/angularjs_cart_application.htm"},
                            @{@"Translate Application":@"https://www.tutorialspoint.com/angularjs/angularjs_translate_application.htm"},
                            @{@"Chart Application":@"https://www.tutorialspoint.com/angularjs/angularjs_chart_application.htm"},
                            @{@"Maps Application":@"https://www.tutorialspoint.com/angularjs/angularjs_maps_application.htm"},
                            @{@"Share Application":@"https://www.tutorialspoint.com/angularjs/angularjs_share_application.htm"},
                            @{@"Weather Application":@"https://www.tutorialspoint.com/angularjs/angularjs_weather_application.htm"},
                            @{@"Timer Application":@"https://www.tutorialspoint.com/angularjs/angularjs_timer_application.htm"},
                            @{@"Leaflet Application":@"https://www.tutorialspoint.com/angularjs/angularjs_leaflet_application.htm"},
                            @{@"LastFm Application":@"https://www.tutorialspoint.com/angularjs/angularjs_lastfm_application.htm"},
                            @{@"Questions and Answers":@"https://www.tutorialspoint.com/angularjs/angularjs_questions_answers.htm"},
                            @{@"Quick Guide":@"https://www.tutorialspoint.com/angularjs/angularjs_quick_guide.htm"},
                            @{@"Useful Resources":@"https://www.tutorialspoint.com/angularjs/angularjs_useful_resources.htm"},
                            @{@"Discuss AngularJS":@"https://www.tutorialspoint.com/angularjs/angularjs_discussion.htm"}];
    
    NSMutableDictionary* dbDict = [@{} mutableCopy];
    
    for (NSDictionary* dict in inputArray) {
        NSDictionary* modifiedDict = @{
                                       KEY_NAME:[dict.allKeys firstObject],
                                       KEY_URL:[dict.allValues firstObject],
                                       KEY_COMPLETED:@NO,
                                       KEY_OPENED:@NO
                                       };
        [dbDict setValue:[modifiedDict copy] forKey:[[dict.allKeys firstObject] copy]];
    }
    
    NSMutableDictionary* amazonDict = [@{} mutableCopy];
    
    [amazonDict setValue:dbDict forKey:@"Angular JS"];
    
    //for first time db initialisation --> when entire db is empty
    //    NSMutableDictionary* setDict = [@{} mutableCopy];
    //    [setDict setValue:amazonDict forKey:KEY_SETS];
    //
    //    [self.databaseRef updateChildValues:setDict];
    
    [[self.databaseRef child:KEY_SETS] updateChildValues:amazonDict];
}
- (void) writeGoogleData {
    
    //FIRDatabaseReference* dbWriteReference = [self.databaseRef child:KEY_SETS];
    
    // dbWriteReference = [self.databaseRef child:@"Amazon"];
    
    NSArray* inputArray = @[@{@"Sum of bit differences among all pairs":@"http://www.geeksforgeeks.org/sum-of-bit-differences-among-all-pairs/"},
                            @{@"Minimum number of swaps required for arranging pairs adjacent to each other":@"http://www.geeksforgeeks.org/minimum-number-of-swaps-required-for-arranging-pairs-adjacent-to-each-other/"},
                            @{@"Google Interview Experience | Set 5 (for Java Position)":@"http://www.geeksforgeeks.org/google-interview-question-for-java-position/"},
                            @{@"TopTalent in Interview with Divanshu Whot Got Into Google, Mountain View":@"http://www.geeksforgeeks.org/toptalent-interview-divanshu-got-google-mountain-view/"},
                            @{@"Google Interview Experience | Set 4":@"http://www.geeksforgeeks.org/google-interview-experience/"},
                            @{@"TopTalent in “It’s the best feeling of my life” says Krunal after cracking Google, Mountain View":@"http://www.geeksforgeeks.org/toptalent-best-feeling-life-says-krunal-cracking-google-mountain-view/"},
                            @{@"TopTalent in Top College: No, Top Talent: Yes ; Anudeep cracks Google":@"http://www.geeksforgeeks.org/top-college-top-talent-yes-anudeep-cracks-google-1-44cr-package/"},
                            @{@"Google Interview Experience | Set 3 (Mountain View)":@"http://www.geeksforgeeks.org/google-mountain-view-interview/"},
                            @{@"TopTalent in What it takes to be a Googler? An Interview with Google’s recent hire Romal Thoppilan":@"http://www.geeksforgeeks.org/toptalent-takes-googler-interview-googles-recent-hire-romal-thoppilan/"},
                            @{@"Google Interview Experience | Set 2 (Placement Questions)":@"http://www.geeksforgeeks.org/google-placement-paper/"},
                            @{@"Google Interview Experience | Set 1 (for Technical Operations Specialist Adwords, Hyderabad, India)":@"http://www.geeksforgeeks.org/google-interview-experience-for-the-post-of-technical-operations-specialisttools-team-adwords-hyderabadindia/"},
                            @{@"TopTalent in Google, Facebook, Amazon, Walmart & PocketGems, All Fighting For Prasoon Mishra":@"http://www.geeksforgeeks.org/google-facebook-amazon-walmart-pocketgems-all-fighting-for-prasoon-mishra/"},
                            @{@"TopTalent in Interview with Sujeet Gholap, placed in Microsoft, Google, Samsung, Goldman Sachs & Tower Research":@"http://www.geeksforgeeks.org/toptalent-in-interview-with-sujeet-gholap-placed-in-microsoft-google-samsung-goldman-sachs-tower-research/"},
                            @{@"TopTalent in Exclusive Interview with Ravi Kiran from BITS, Pilani who got placed in Google, Microsoft and Facebook":@"http://www.geeksforgeeks.org/toptalent-in-exclusive-interview-with-ravi-kiran-from-bits-pilani-who-got-placed-in-google-microsoft-and-facebook/"},
                            @{@"TopTalent in Rushabh Agrawal from BITS Pilani talks about his Google interview experience":@"http://www.geeksforgeeks.org/toptalent-in-rushabh-agrawal-from-bits-pilani-talks-about-his-google-interview-experience/"}];
    
    NSMutableDictionary* dbDict = [@{} mutableCopy];
    
    for (NSDictionary* dict in inputArray) {
        NSDictionary* modifiedDict = @{
                                       KEY_NAME:[dict.allKeys firstObject],
                                       KEY_URL:[dict.allValues firstObject],
                                       KEY_COMPLETED:@NO,
                                       KEY_OPENED:@NO
                                       };
        [dbDict setValue:[modifiedDict copy] forKey:[[dict.allKeys firstObject] copy]];
    }
    
    NSMutableDictionary* amazonDict = [@{} mutableCopy];
    
    [amazonDict setValue:dbDict forKey:@"Google"];
    
    //for first time db initialisation --> when entire db is empty
    //    NSMutableDictionary* setDict = [@{} mutableCopy];
    //    [setDict setValue:amazonDict forKey:KEY_SETS];
    //
    //    [self.databaseRef updateChildValues:setDict];
    
    [[self.databaseRef child:KEY_SETS] updateChildValues:amazonDict];
}
- (void) writeAdobeData {
    
    //FIRDatabaseReference* dbWriteReference = [self.databaseRef child:KEY_SETS];
    
    // dbWriteReference = [self.databaseRef child:@"Amazon"];
    
    NSArray* inputArray = @[@{@"Adobe Interview Experience | Set 40 (On-Campus for MTS-1)":@"http://www.geeksforgeeks.org/adobe-interview-experience-set-40-on-campus/"},
                            @{@"Adobe Interview Experience | Set 39 (1 Years Experienced)":@"http://www.geeksforgeeks.org/adobe-interview-experience-set-39/"},
                            @{@"Adobe Interview Experience | Set 38 (4 Years Experienced)":@"http://www.geeksforgeeks.org/adobe-interview-experience-set-38-4-6-years-experienced/"},
                            @{@"Adobe Interview Experience | Set 37 (3 Years Experienced)":@"http://www.geeksforgeeks.org/adobe-interview-experience-set-37-3-5-years-experienced/"},
                            @{@"Adobe Interview Experience | Set 36 (Off-Campus Drive)":@"http://www.geeksforgeeks.org/adobe-interview-experience-set-36-off-campus-drive/"},
                            @{@"Adobe Interview Experience | Set 35 (Off-Campus Drive)":@"http://www.geeksforgeeks.org/adobe-interview-experience-set-35-off-campus-drive/"},
                            @{@"Adobe Interview Experience | Set 34 (For MTS-1)":@"http://www.geeksforgeeks.org/adobe-interview-experience-set-34-for-mts-1/"},
                            @{@"Adobe Interview Experience | Set 33 (On-Campus)":@"http://www.geeksforgeeks.org/adobe-interview-experience-set-33-on-campus/"},
                            @{@"Adobe Interview Experience | Set 32 (For MTS-1)":@"http://www.geeksforgeeks.org/adobe-interview-experience-set-32-for-mts-1/"},
                            @{@"Adobe Interview Experience | Set 31":@"http://www.geeksforgeeks.org/adobe-interview-experience-set-31/"},
                            @{@"Adobe Interview Experience | Set 30 (Off-Campus For Member Technical Staff)":@"http://www.geeksforgeeks.org/adobe-interview-experience-set-30-off-campus-for-member-technical-staff/"},
                            @{@"Adobe Interview Experience | Set 29 ( Off-Campus)":@"http://www.geeksforgeeks.org/adobe-interview-experience-set-29-off-campus/"},
                            @{@"Adobe Interview Experience | Set 28 (For MTS-2)":@"http://www.geeksforgeeks.org/adobe-interview-experience-set-28-for-mts-2/"},
                            @{@"Adobe Interview Experience | Set 27 (On-Campus for Internship)":@"http://www.geeksforgeeks.org/adobe-interview-experience-set-27-on-campus-for-internship/"},
                            @{@"Adobe Interview Experience | Set 26 (On-Campus for MTS-1)":@"http://www.geeksforgeeks.org/adobe-interview-experience-set-26-on-campus-for-mts-1/"},
                            @{@"Adobe Interview Experience | Set 25 (On-Campus for MTS-1)":@"http://www.geeksforgeeks.org/adobe-interview-experience-set-25-on-campus-for-mts-1/"},
                            @{@"Adobe Interview Experience | Set 24 (On-Campus for MTS)":@"http://www.geeksforgeeks.org/adobe-interview-experience-set-24-on-campus-for-mts/"},
                            @{@"Adobe Interview Experience | Set 23 (1 Year Experienced)":@"http://www.geeksforgeeks.org/adobe-interview-experience-set-23-1-year-experienced/"},
                            @{@"Adobe Interview Experience | Set 22 (On-Campus)":@"http://www.geeksforgeeks.org/adobe-interview-experience-set-22-on-campus/"},
                            @{@"Adobe Interview Experience | Set 21 for Software Engineer (Fresher)":@"http://www.geeksforgeeks.org/adobe-interview-experience-set-21-for-software-engineer-fresher/"},
                            @{@"Adobe Interview Experience for MTS-1 (1 Years Experience)":@"http://www.geeksforgeeks.org/adobe-interview-experience-mts-1-1-5-years-experience/"},
                            @{@"Adobe Interview Experience | Set 19 (For MTS)":@"http://www.geeksforgeeks.org/adobe-interview-experience-set-19-mts/"},
                            @{@"Adobe Interview Experience | Set 18 (For WBT Profile)":@"http://www.geeksforgeeks.org/adobe-interview-experience-set-18-wbt-profile/"},
                            @{@"Adobe Interview | Set 17 (For MTS-1)":@"http://www.geeksforgeeks.org/adobe-interview-set-17-mts-1/"},
                            @{@"Adobe Interview | Set 16 (For MTS-1)":@"http://www.geeksforgeeks.org/adobe-interview-set-16-mts-1/"},
                            @{@"Adobe Interview | Set 15 (For MTS-1)":@"http://www.geeksforgeeks.org/adobe-interview-set-15-mts-1/"},
                            @{@"Adobe Interview | Set 14 (On Campus for Full Time)":@"http://www.geeksforgeeks.org/adobe-interview-set-14-campus-full-time/"},
                            @{@"Adobe Interview | Set 13 (On Campus for Internship)":@"http://www.geeksforgeeks.org/adobe-interview-set-13-campus-internship/"},
                            @{@"Adobe Interview | Set 12 (On Campus for MTS-1)":@"http://www.geeksforgeeks.org/adobe-interview-set-12-campus-mts-1/"},
                            @{@"Adobe Interview | Set 11 (On-Campus)":@"http://www.geeksforgeeks.org/adobe-interview-set-11-campus/"},
                            @{@"Adobe Interview | Set 10 (Software Engineer)":@"http://www.geeksforgeeks.org/adobe-interview-set-10-software-engineer/"},
                            @{@"Adobe Interview | Set 9":@"http://www.geeksforgeeks.org/adobe-interview-set-9/"},
                            @{@"Adobe Interview | Set 8 (Off-Campus)":@"http://www.geeksforgeeks.org/adobe-interview-set-8-off-campus/"},
                            @{@"Adobe Interview | Set 7 (On-campus for MTS-1)":@"http://www.geeksforgeeks.org/adobe-interview-set-7-campus-mts-1/"},
                            @{@"Adobe Interview | Set 6 (On-campus for MTS-1)":@"http://www.geeksforgeeks.org/adobe-interview-set-6-campus-mts-1/"},
                            @{@"Adobe Interview | Set 5":@"http://www.geeksforgeeks.org/adobe-interview-experience/"},
                            @{@"Adobe Interview | Set 4":@"http://www.geeksforgeeks.org/adobe-interview-set-4/"},
                            @{@"Adobe Interview | Set 3":@"http://www.geeksforgeeks.org/adobe-testing-experience/"},
                            @{@"Adobe Interview | Set 2":@"http://www.geeksforgeeks.org/adobe-interview-set-1/"},
                            @{@"Adobe Interview | Set 1":@"http://www.geeksforgeeks.org/adobe-interview-questions-set-1/"}];
    
    NSMutableDictionary* dbDict = [@{} mutableCopy];
    
    for (NSDictionary* dict in inputArray) {
        NSDictionary* modifiedDict = @{
                                       KEY_NAME:[dict.allKeys firstObject],
                                       KEY_URL:[dict.allValues firstObject],
                                       KEY_COMPLETED:@NO,
                                       KEY_OPENED:@NO
                                       };
        [dbDict setValue:[modifiedDict copy] forKey:[[dict.allKeys firstObject] copy]];
    }
    
    NSMutableDictionary* amazonDict = [@{} mutableCopy];
    
    [amazonDict setValue:dbDict forKey:@"Adobe"];
    
    //for first time db initialisation --> when entire db is empty
    //    NSMutableDictionary* setDict = [@{} mutableCopy];
    //    [setDict setValue:amazonDict forKey:KEY_SETS];
    //
    //    [self.databaseRef updateChildValues:setDict];
    
    [[self.databaseRef child:KEY_SETS] updateChildValues:amazonDict];
}
- (void) writeFacebookData {
    
    //FIRDatabaseReference* dbWriteReference = [self.databaseRef child:KEY_SETS];
    
    // dbWriteReference = [self.databaseRef child:@"Amazon"];
    
    NSArray* inputArray = @[@{@"TopTalent in Exclusive Rapid Fire Interview with Deepali Who Got Into Facebook":@"http://www.geeksforgeeks.org/toptalent-exclusive-rapid-fire-interview-deepali-got-facebook/"},
                            @{@"Facebook Interview | Set 2 (On Campus for Internship)":@"http://www.geeksforgeeks.org/facebook-interview-set-2-campus-interview-internship/"},
                            @{@"Find all possible interpretations of an array of digits":@"http://www.geeksforgeeks.org/find-all-possible-interpretations/"},
                            @{@"TopTalent in Google, Facebook, Amazon, Walmart & PocketGems, All Fighting For Prasoon Mishra":@"http://www.geeksforgeeks.org/google-facebook-amazon-walmart-pocketgems-all-fighting-for-prasoon-mishra/"},
                            @{@"TopTalent in Exclusive Interview with Ravi Kiran from BITS, Pilani who got placed in Google, Microsoft and Facebook":@"http://www.geeksforgeeks.org/toptalent-in-exclusive-interview-with-ravi-kiran-from-bits-pilani-who-got-placed-in-google-microsoft-and-facebook/"},
                            @{@"Facebook Interview | Set 1":@"http://www.geeksforgeeks.org/facebook-interview-set-1/"}];
    
    NSMutableDictionary* dbDict = [@{} mutableCopy];
    
    for (NSDictionary* dict in inputArray) {
        NSDictionary* modifiedDict = @{
                                       KEY_NAME:[dict.allKeys firstObject],
                                       KEY_URL:[dict.allValues firstObject],
                                       KEY_COMPLETED:@NO,
                                       KEY_OPENED:@NO
                                       };
        [dbDict setValue:[modifiedDict copy] forKey:[[dict.allKeys firstObject] copy]];
    }
    
    NSMutableDictionary* amazonDict = [@{} mutableCopy];
    
    [amazonDict setValue:dbDict forKey:@"Facebook"];
    
    //for first time db initialisation --> when entire db is empty
    //    NSMutableDictionary* setDict = [@{} mutableCopy];
    //    [setDict setValue:amazonDict forKey:KEY_SETS];
    //
    //    [self.databaseRef updateChildValues:setDict];
    
    [[self.databaseRef child:KEY_SETS] updateChildValues:amazonDict];
}
- (void) writeFlipkartData {
    
    //FIRDatabaseReference* dbWriteReference = [self.databaseRef child:KEY_SETS];
    
    // dbWriteReference = [self.databaseRef child:@"Amazon"];
    
    NSArray* inputArray = @[@{@"Flipkart Interview Experience | Set 41 (For SDE 1)":@"http://www.geeksforgeeks.org/flipkart-interview-experience-set-41-for-sde-1/"},
                            @{@"Flipkart Interview Experience | Set 40 (For SDE 1)":@"http://www.geeksforgeeks.org/flipkart-interview-experience-set-40-for-sde-1/"},
                            @{@"Flipkart Interview Experience | Set 39":@"http://www.geeksforgeeks.org/flipkart-interview-experience-set-39/"},
                            @{@"Flipkart Interview Experience| Set 38 (On-Campus for SDE)":@"http://www.geeksforgeeks.org/flipkart-interview-experience-set-38-on-campus-for-sde/"},
                            @{@"Flipkart Interview Experience| Set 37 (On-Campus for SDE 1)":@"http://www.geeksforgeeks.org/flipkart-interview-experience-set-37-on-campus-for-sde-1/"},
                            @{@"Flipkart Interview Experience| Set 36 (On-Campus for SDE 1)":@"http://www.geeksforgeeks.org/flipkart-interview-experience-set-36-on-campus-for-sde-1/"},
                            @{@"Flipkart Interview Experience| Set 35 (On-Campus for SDE 1)":@"http://www.geeksforgeeks.org/flipkart-interview-experience-set-35-on-campus-for-sde-1/"},
                            @{@"Flipkart Interview Experience | Set 34 (On-Campus for SDE-1)":@"http://www.geeksforgeeks.org/flipkart-interview-experience-set-34-on-campus-for-sde-1/"},
                            @{@"Flipkart Interview Experience | Set 33 (For SDE-1)":@"http://www.geeksforgeeks.org/flipkart-interview-experience-set-33-for-sde-1/"},
                            @{@"Flipkart Interview Experience | Set 32 (For SDE-1)":@"http://www.geeksforgeeks.org/flipkart-interview-experience-set-32-for-sde-1/"},
                            @{@"Flipkart Interview Experience | Set 31 (For Fresher)":@"http://www.geeksforgeeks.org/flipkart-interview-experience-set-31-for-fresher/"},
                            @{@"Minimum steps to reach a destination":@"http://www.geeksforgeeks.org/minimum-steps-to-reach-a-destination/"},
                            @{@"Flipkart Interview Experience | Set 30 (For SDE 2)":@"http://www.geeksforgeeks.org/flipkart-interview-experience-set-30for-sde-2/"},
                            @{@"Flipkart Interview Experience | Set 29":@"http://www.geeksforgeeks.org/flipkart-interview-experience-set-29/"},
                            @{@"Flipkart Interview Experience | Set 28 (For SDE2)":@"http://www.geeksforgeeks.org/flipkart-interview-experience-set-28-for-sde2/"},
                            @{@"Flipkart Interview Experience | Set 27 (For SDE)":@"http://www.geeksforgeeks.org/flipkart-interview-experience-set-27-for-sde/"},
                            @{@"Flipkart Interview Experience | Set 26":@"http://www.geeksforgeeks.org/flipkart-interview-experience-set-26/"},
                            @{@"Flipkart Interview Experience | Set 25":@"http://www.geeksforgeeks.org/flipkart-interview-experience-set-25/"},
                            @{@"Flipkart Interview Experience | Set 24":@"http://www.geeksforgeeks.org/flipkart-interview-experience-set-24/"},
                            @{@"Flipkart Interview Experience | Set 23":@"http://www.geeksforgeeks.org/flipkart-interview-experience-set-23/"},
                            @{@"Flipkart Interview Experience | Set 22 (For SDE 2)":@"http://www.geeksforgeeks.org/flipkart-interview-experience-set-22-for-sde-2/"},
                            @{@"Flipkart Interview Experience | Set 21":@"http://www.geeksforgeeks.org/flipkart-interview-experience-set-21/"},
                            @{@"Flipkart Interview Experience | Set 20 (For SDE-II)":@"http://www.geeksforgeeks.org/flipkart-interview-experience-set-20-for-sde-ii/"},
                            @{@"Flipkart Interview Experience | Set 19 (For SDET)":@"http://www.geeksforgeeks.org/flipkart-interview-experience-set-19-sdet/"},
                            @{@"Flipkart Interview Experience | Set 18 (For SDE I)":@"http://www.geeksforgeeks.org/flipkart-interview-experience-set-18-for-sde-i/"},
                            @{@"Flipkart Interview Experience | Set 17 (For SDE II)":@"http://www.geeksforgeeks.org/flipkart-interview-experience-set-17-for-sde-ii/"},
                            @{@"Flipkart Interview | Set 16":@"http://www.geeksforgeeks.org/flipkart-interview-set-16/"},
                            @{@"TopTalent in Interview With Amit Who Got Into Flipkart":@"http://www.geeksforgeeks.org/toptalent-interview-amit-got-flipkart/"},
                            @{@"Flipkart Interview Experience | Set 15B":@"http://www.geeksforgeeks.org/flipkart-written-test-placements/"},
                            @{@"Flipkart Interview | Set 15 (For SDE-II)":@"http://www.geeksforgeeks.org/flipkart-interview-set-15-sde-ii/"},
                            @{@"TopTalent in Exclusive Interview with Arushi Who Got Into Flipkart":@"http://www.geeksforgeeks.org/toptalent-exclusive-interview-arushi-got-flipkart/"},
                            @{@"Flipkart Interview | Set 14 (For SDET-1)":@"http://www.geeksforgeeks.org/flipkart-interview-set-14-sde-1/"},
                            @{@"Flipkart Interview | Set 13":@"http://www.geeksforgeeks.org/flipkart-interview-set-13/"},
                            @{@"Flipkart Interview | Set 12 (On-Campus)":@"http://www.geeksforgeeks.org/flipkart-interview-set-12-campus/"},
                            @{@"Flipkart Interview | Set 11":@"http://www.geeksforgeeks.org/flipkart-interview-set-11/"},
                            @{@"Flipkart Interview | Set 10 (On-Campus For SDE-1)":@"http://www.geeksforgeeks.org/flipkart-interview-set-10-campus-sde-1/"},
                            @{@"Flipkart Interview | Set 9 (On-Campus)":@"http://www.geeksforgeeks.org/flipkart-interview-set-9-campus/"},
                            @{@"Flipkart Interview | Set 8 (For SDE 1)":@"http://www.geeksforgeeks.org/flipkart-interview-set-8-sde-1/"},
                            @{@"Flipkart Interview | Set 7 (For SDE II)":@"http://www.geeksforgeeks.org/flipkart-interview-set-7-sde-ii/"},
                            @{@"Flipkart Interview | Set 6":@"http://www.geeksforgeeks.org/flipkart-interview-set-6/"},
                            @{@"Flipkart Interview | Set 5 (Off-Campus for SDE-1)":@"http://www.geeksforgeeks.org/flipkart-interview-set-5-off-campus/"},
                            @{@"Flipkart Interview | Set 4 (For SDE-1)":@"http://www.geeksforgeeks.org/flipkart-interview-set-4-sde-1/"},
                            @{@"Flipkart Interview | Set 3":@"http://www.geeksforgeeks.org/flipkart-interview-set-3/"},
                            @{@"Flipkart Interview | Set 2 (For SDE 1)":@"http://www.geeksforgeeks.org/flipkart-interview-set-2-for-sde-1/"},
                            @{@"Flipkart Interview | Set 1 (For SDE 2)":@"http://www.geeksforgeeks.org/flipkart-interview-set-2-sde-2/"},
                            @{@"TopTalent in How Flipkart gets the best out of their applicants":@"http://www.geeksforgeeks.org/toptalent-in-how-flipkart-gets-the-best-out-of-their-applicants/"}];
    
    NSMutableDictionary* dbDict = [@{} mutableCopy];
    
    for (NSDictionary* dict in inputArray) {
        NSDictionary* modifiedDict = @{
                                       KEY_NAME:[dict.allKeys firstObject],
                                       KEY_URL:[dict.allValues firstObject],
                                       KEY_COMPLETED:@NO,
                                       KEY_OPENED:@NO
                                       };
        [dbDict setValue:[modifiedDict copy] forKey:[[dict.allKeys firstObject] copy]];
    }
    
    NSMutableDictionary* amazonDict = [@{} mutableCopy];
    
    [amazonDict setValue:dbDict forKey:@"Flipkart"];
    
    //for first time db initialisation --> when entire db is empty
    //    NSMutableDictionary* setDict = [@{} mutableCopy];
    //    [setDict setValue:amazonDict forKey:KEY_SETS];
    //
    //    [self.databaseRef updateChildValues:setDict];
    
    [[self.databaseRef child:KEY_SETS] updateChildValues:amazonDict];
}
- (void) writeMicrosoftData {
    
    //FIRDatabaseReference* dbWriteReference = [self.databaseRef child:KEY_SETS];
    
    // dbWriteReference = [self.databaseRef child:@"Amazon"];
    
    NSArray* inputArray = @[@{@"1":@"http://www.geeksforgeeks.org/microsoft-interview-set-1/"},
                            @{@"2":@"http://www.geeksforgeeks.org/microsoft-interview-set-2/"},
                            @{@"3":@"http://www.geeksforgeeks.org/microsoft-interview-set-3/"},
                            @{@"5":@"http://www.geeksforgeeks.org/microsoft-interview-set-5/"},
                            @{@"6":@"http://www.geeksforgeeks.org/microsoft-interview-set-6/"},
                            @{@"7":@"http://www.geeksforgeeks.org/microsoft-interview-set-7-3/"},
                            @{@"8":@"http://www.geeksforgeeks.org/microsoft-interview-set-8/"},
                            @{@"9":@"http://www.geeksforgeeks.org/microsoft-interview-set-9/"},
                            @{@"10":@"http://www.geeksforgeeks.org/microsoft-interview-set-10/"},
                            @{@"11":@"http://www.geeksforgeeks.org/microsoft-interview-set-11/"},
                            @{@"12":@"http://www.geeksforgeeks.org/mircosoft-interview-12/"},
                            @{@"13":@"http://www.geeksforgeeks.org/mircosoft-interview-13/"},
                            @{@"14":@"http://www.geeksforgeeks.org/mircosoft-interview-14/"},
                            @{@"15":@"http://www.geeksforgeeks.org/mircosoft-interview-15/"},
                            @{@"16":@"http://www.geeksforgeeks.org/microsoft-interview-16/"},
                            @{@"17":@"http://www.geeksforgeeks.org/microsoft-interview-17/"},
                            @{@"18":@"http://www.geeksforgeeks.org/microsoft-interview-178/"},
                            @{@"19":@"http://www.geeksforgeeks.org/microsoft-interview-19/"},
                            @{@"20":@"http://www.geeksforgeeks.org/microsoft-interview-set-20-campus-internship/"},
                            @{@"21":@"http://www.geeksforgeeks.org/microsoft-interview-set-21/"},
                            @{@"22":@"http://www.geeksforgeeks.org/microsoft-interview-set-22/"},
                            @{@"23":@"http://www.geeksforgeeks.org/microsoft-interview-set-23/"},
                            @{@"24":@"http://www.geeksforgeeks.org/microsoft-interview-set-24/"},
                            @{@"25":@"http://www.geeksforgeeks.org/microsoft-interview-set-25-on-campus-for-internship/"},
                            @{@"26":@"http://www.geeksforgeeks.org/mircosoft-interview-set/"},
                            @{@"27":@"http://www.geeksforgeeks.org/microsoft-interview-set-27/"},
                            @{@"28":@"http://www.geeksforgeeks.org/microsoft-interview-set-28-campus/"},
                            @{@"29":@"http://www.geeksforgeeks.org/microsoft-interview-set-29-campus-internship/"},
                            @{@"30":@"http://www.geeksforgeeks.org/microsoft-interview-set-30-campus/"},
                            @{@"31":@"http://www.geeksforgeeks.org/microsoft-interview-set-31-campus/"},
                            @{@"32":@"http://www.geeksforgeeks.org/microsoft-interview-set-32-campus-internship/"},
                            @{@"33":@"http://www.geeksforgeeks.org/microsoft-interview-set-33-campus-internship/"},
                            @{@"34":@"http://www.geeksforgeeks.org/microsoft-interview-set-34-campus-2/"},
                            @{@"35":@"http://www.geeksforgeeks.org/microsoft-interview-set-35-campus-internship/"},
                            @{@"36":@"http://www.geeksforgeeks.org/microsoft-research-india-interview-set-36-on-campus-for-internship/"},
                            @{@"37":@"http://www.geeksforgeeks.org/microsoft-interview-set-37-sde-1/"},
                            @{@"38":@"http://www.geeksforgeeks.org/microsoft-idc-interview-experience-set-138for-internship/"},
                            @{@"39":@"http://www.geeksforgeeks.org/microsoft-interview-experience-set-39-on-campus/"},
                            @{@"40":@"http://www.geeksforgeeks.org/microsoft-interview-experience-set-40-off-campus/"},
                            @{@"41":@"http://www.geeksforgeeks.org/microsoft-interview-experience-set-41-campus/"},
                            @{@"42":@"http://www.geeksforgeeks.org/microsoft-interview-experience-set-42-sde1/"},
                            @{@"43":@"http://www.geeksforgeeks.org/microsoft-interview-experience-set-43/"},
                            @{@"44":@"http://www.geeksforgeeks.org/microsoft-idc-interview-experience-set-44/"},
                            @{@"45":@"http://www.geeksforgeeks.org/microsoft-interview-experience-set-45/"},
                            @{@"46":@"http://www.geeksforgeeks.org/microsoft-interview-experience-set-46-onsite/"},
                            @{@"47":@"http://www.geeksforgeeks.org/microsoft-idc-interview-experience-set-47-1-7-years-experienced/"},
                            @{@"48":@"http://www.geeksforgeeks.org/microsoft-interview-experience-set-48-for-1-5-years-experienced/"},
                            @{@"49":@"http://www.geeksforgeeks.org/microsoft-interview-experience-set-49-internship/"},
                            @{@"50":@"http://www.geeksforgeeks.org/microsoft-interview-experience-set-50/"},
                            @{@"51":@"http://www.geeksforgeeks.org/microsoft-interview-experience-set-51-for-sde-intern/"},
                            @{@"52":@"http://www.geeksforgeeks.org/microsoft-interview-experience-set-52-fresher/"},
                            @{@"53":@"http://www.geeksforgeeks.org/microsoft-interview-experience-set-53/"},
                            @{@"54":@"http://www.geeksforgeeks.org/microsoft-interview-experience-set-54-for-sde/"},
                            @{@"55":@"http://www.geeksforgeeks.org/microsoft-interview-experience-set-55-for-software-engineer-2/"},
                            @{@"56":@"http://www.geeksforgeeks.org/microsoft-interview-experience-set-56-for-sde-2/"},
                            @{@"57":@"http://www.geeksforgeeks.org/microsoft-interview-experience-set-57-for-sde/"},
                            @{@"58":@"http://www.geeksforgeeks.org/microsoft-interview-experience-set-58-for-software-engineer/"},
                            @{@"59":@"http://www.geeksforgeeks.org/microsoft-interview-experience-set-59-on-campus/"},
                            @{@"60":@"http://www.geeksforgeeks.org/microsoft-interview-experience-set-60-on-campus-for-internship/"},
                            @{@"61":@"http://www.geeksforgeeks.org/microsoft-interview-experience-set-61-on-campus-for-idc/"},
                            @{@"62":@"http://www.geeksforgeeks.org/microsoft-interview-experience-set-62-on-campus-for-idc/"},
                            @{@"63":@"http://www.geeksforgeeks.org/microsoft-interview-experience-set-63-for-internship/"},
                            @{@"64":@"http://www.geeksforgeeks.org/microsoft-interview-experience-set-64-for-sde-2/"},
                            @{@"65":@"http://www.geeksforgeeks.org/microsoft-interview-experience-set-65-on-campus-for-internship-it-and-idc/"},
                            @{@"66":@"http://www.geeksforgeeks.org/microsoft-idc-interview-experience-set-66-on-campus-for-internship/"},
                            @{@"67":@"http://www.geeksforgeeks.org/microsoft-idc-interview-experience-set-67-on-campus-for-internship/"},
                            @{@"68":@"http://www.geeksforgeeks.org/microsoft-idc-interview-experience-set-68-off-campus-for-sde/"},
                            @{@"69":@"http://www.geeksforgeeks.org/microsoft-idc-interview-experience-set-69-for-sde/"},
                            @{@"70":@"http://www.geeksforgeeks.org/microsoft-interview-experience-set-70-on-campus-for-idc-and-it/"},
                            @{@"71":@"http://www.geeksforgeeks.org/microsoft-interview-experience-set-71-off-campus/"},
                            @{@"72":@"http://www.geeksforgeeks.org/microsoft-interview-experience-set-72-for-software-engineer/"},
                            @{@"73":@"http://www.geeksforgeeks.org/microsoft-interview-experience-set-73-on-campus-for-it-sde-intern/"},
                            @{@"74":@"http://www.geeksforgeeks.org/microsoft-interview-experience-set-74-for-software-engineer-in-it-team/"},
                            @{@"75":@"http://www.geeksforgeeks.org/microsoft-interview-experience-set-75-for-sde-ii/"},
                            @{@"76":@"http://www.geeksforgeeks.org/microsoft-interview-experience-set-76-on-campus/"},
                            @{@"77":@"http://www.geeksforgeeks.org/microsoft-interview-experience-set-77-for-idc-internship/"},
                            @{@"78":@"http://www.geeksforgeeks.org/microsoft-interview-experience-set-78-telephonic-for-it/"},
                            @{@"79":@"http://www.geeksforgeeks.org/microsoft-idc-interview-experience-set-79-for-internship/"},
                            @{@"80":@"http://www.geeksforgeeks.org/microsoft-idc-interview-experience-set-80-for-internship/"},
                            @{@"81":@"http://www.geeksforgeeks.org/microsoft-idc-interview-experience-set-81-for-internship/"},
                            @{@"82":@"http://www.geeksforgeeks.org/microsoft-idc-interview-experience-set-82-on-campus/"},
                            @{@"83":@"http://www.geeksforgeeks.org/microsoft-idc-interview-experience-set-83-on-campus/"},
                            @{@"84":@"http://www.geeksforgeeks.org/microsoft-msit-interview-experience-set-84-on-campus/"},
                            @{@"85":@"http://www.geeksforgeeks.org/microsoft-msit-interview-experience-set-85-campus/"},
                            @{@"86":@"http://www.geeksforgeeks.org/microsoft-interview-experience-set-86-on-campus/"},
                            @{@"87":@"http://www.geeksforgeeks.org/microsoft-interview-experience-set-87/"},
                            @{@"88":@"http://www.geeksforgeeks.org/microsoft-idc-interview-experience-set-88-for-sde-2/"},
                            @{@"89":@"http://www.geeksforgeeks.org/microsoft-interview-experience-set-89-for-sde-2/"},
                            @{@"90":@"http://www.geeksforgeeks.org/microsoft-interview-experience-set-90/"},
                            @{@"91":@"http://www.geeksforgeeks.org/microsoft-interview-experience-set-91-2-yrs-experienced-idc/"},
                            @{@"92":@"http://www.geeksforgeeks.org/microsoft-interview-experience-set-92-1-8-yrs-experienced-for-idc/"},
                            @{@"93":@"http://www.geeksforgeeks.org/microsoft-interview-experience-set-93-4-yrs-experienced-for-idc/"},
                            @{@"94":@"http://www.geeksforgeeks.org/microsoft-interview-experience-set-94-internship/"},
                            @{@"95":@"http://www.geeksforgeeks.org/microsoft-interview-experience-set-95-on-campus-for-idc/"},
                            @{@"96":@"http://www.geeksforgeeks.org/microsoft-interview-experience-set-96-on-campus-for-idc/"},
                            @{@"97":@"http://www.geeksforgeeks.org/microsoft-interview-experience-set-97-on-campus-for-it-internship/"},
                            @{@"98":@"http://www.geeksforgeeks.org/microsoft-interview-experience-set-98-on-campus-for-idc/"},
                            @{@"99":@"http://www.geeksforgeeks.org/microsoft-interview-experience-set-98-on-campus-for-idc-2/"},
                            @{@"100":@"http://www.geeksforgeeks.org/microsoft-interview-experience-set-99-on-campus-for-internship-on-idc-and-it/"},
                            @{@"101":@"http://www.geeksforgeeks.org/microsoft-interview-experience-set-101-campus-idc/"},
                            @{@"102":@"http://www.geeksforgeeks.org/microsoft-interview-experience-set-102-on-campus-for-idc/"},
                            @{@"103":@"http://www.geeksforgeeks.org/microsoft-interview-experience-set-103-on-campus-for-idc/"},
                            @{@"104":@"http://www.geeksforgeeks.org/microsoft-interview-experience-set-104-on-campus-for-idc/"},
                            @{@"105":@"http://www.geeksforgeeks.org/microsoft-interview-experience-set-105-global-delivery/"},
                            @{@"106":@"http://www.geeksforgeeks.org/microsoft-interview-experience-set-106/"},
                            @{@"107":@"http://www.geeksforgeeks.org/microsoft-interview-experience-set-107-on-campus-for-internship/"}];
    
    NSMutableDictionary* dbDict = [@{} mutableCopy];
    
    for (NSDictionary* dict in inputArray) {
        
        NSString* setPrefix = @"Set No. ";
        
        setPrefix = [setPrefix stringByAppendingString:dict.allKeys.firstObject];
        
        NSDictionary* modifiedDict = @{
                                       KEY_NAME:setPrefix,
                                       KEY_URL:[dict.allValues firstObject],
                                       KEY_COMPLETED:@NO,
                                       KEY_OPENED:@NO
                                       };
        [dbDict setValue:[modifiedDict copy] forKey:[[dict.allKeys firstObject] copy]];
    }
    
    NSMutableDictionary* amazonDict = [@{} mutableCopy];
    
    [amazonDict setValue:dbDict forKey:@"Microsoft"];
    
    //for first time db initialisation --> when entire db is empty
    //    NSMutableDictionary* setDict = [@{} mutableCopy];
    //    [setDict setValue:amazonDict forKey:KEY_SETS];
    //
    //    [self.databaseRef updateChildValues:setDict];
    
    [[self.databaseRef child:KEY_SETS] updateChildValues:amazonDict];
}
- (void) writeAmazonData {
    
    //FIRDatabaseReference* dbWriteReference = [self.databaseRef child:KEY_SETS];
    
   // dbWriteReference = [self.databaseRef child:@"Amazon"];
    
    NSArray* inputArray = @[
                            @{@"312":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-312-off-campus/"},
                            @{@"311":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-311-on-campus/"},
                            @{@"310":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-310-for-internship/"},
                            @{@"309":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-309/"},
                            @{@"308":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-308-on-campus-for-internship/"},
                            @{@"307":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-307-off-campus/"},
                            @{@"306":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-306-on-campus/"},
                            @{@"305":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-305-on-campus-for-internship/"},
                            @{@"304":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-304-on-campus-for-internship/"},
                            @{@"303":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-303-on-campus/"},
                            @{@"302":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-302-on-campus/"},
                            @{@"301":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-301on-campus-for-internship-fte/"},
                            @{@"300":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-300-on-campus-for-internship/"},
                            @{@"299":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-299-on-campus-for-internship/"},
                            @{@"298":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-298-on-campus-for-sde-1/"},
                            @{@"297":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-297-on-campus-for-sde/"},
                            @{@"296":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-296-on-campus/"},
                            @{@"295":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-295-on-campus/"},
                            @{@"294":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-294-experienced/"},
                            @{@"293":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-293-on-campus/"},
                            @{@"292":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-292-on-campus-for-internshp/"},
                            @{@"291":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-291-on-campus-for-sde1/"},
                            @{@"290":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-290-on-campus-for-internship/"},
                            @{@"289":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-289-on-campus-for-internship/"},
                            @{@"288":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-288-on-campus/"},
                            @{@"287":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-287-on-campus/"},
                            @{@"286":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-285-on-campus/"},
                            @{@"285":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-284-on-campus/"},
                            @{@"283":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-283-on-campus/"},
                            @{@"282":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-282-on-campus/"},
                            @{@"280":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-280-on-campus-for-internship/"},
                            @{@"201":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-201-on-campus-for-sde-1/"},
                            @{@"202":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-202/"},
                            @{@"203":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-203-recruit-drive/"},
                            @{@"204":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-204-on-campus-for-internship/"},
                            @{@"205":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-205-on-campus-for-internship/"},
                            @{@"206":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-206-on-campus-for-sde-1/"},
                            @{@"207":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-207-on-campus-for-internship/"},
                            @{@"208":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-208-on-campus-for-internship/"},
                            @{@"209":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-209-on-campus/"},
                            @{@"210":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-210-on-campus/"},
                            @{@"211":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-211-on-campus/"},
                            @{@"212":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-212-on-campus/"},
                            @{@"213":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-213-off-campus-for-sde1/"},
                            @{@"214":@"http://www.geeksforgeeks.org/amazon-interview-experience-214-on-campus/"},
                            @{@"215":@"http://www.geeksforgeeks.org/amazon-interview-experience-215-on-campus-for-internship/"},
                            @{@"216":@"http://www.geeksforgeeks.org/amazon-interview-experience-216-on-campus-for-internship/"},
                            @{@"217":@"http://www.geeksforgeeks.org/amazon-interview-experience-217-on-campus/"},
                            @{@"218":@"http://www.geeksforgeeks.org/amazon-interview-experience-218-on-campus/"},
                            @{@"219":@"http://www.geeksforgeeks.org/amazon-interview-experience-219-on-campus/"},
                            @{@"220":@"http://www.geeksforgeeks.org/amazon-interview-experience-220-on-campus/"},
                            @{@"221":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-221/"},
                            @{@"222":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-222/"},
                            @{@"223":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-223-on-campus/"},
                            @{@"224":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-224/"},
                            @{@"225":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-225-for-1-year-experienced/"},
                            @{@"226":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-226-on-campus/"},
                            @{@"227":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-227-on-campus-for-internship-and-full-time/"},
                            @{@"228":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-228-on-campus-for-internship/"},
                            @{@"229":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-229-on-campus-for-sde/"},
                            @{@"230":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-230-on-campus-for-sde/"},
                            @{@"231":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-231-on-campus/"},
                            @{@"232":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-232-sde-1-for-1-year-experienced/"},
                            @{@"233":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-233-1-year-experienced-for-sde-1/"},
                            @{@"234":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-234-for-sde-ii/"},
                            @{@"235":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-235-for-sde-ii/"},
                            @{@"236":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-236-round-2-and-3/"},
                            @{@"237":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-237-for-application-engineer/"},
                            @{@"238":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-238/"},
                            @{@"239":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-239/"},
                            @{@"240":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-240-1-5-year-experienced-for-sde-1/"},
                            @{@"241":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-241-1-5-years-experience/"},
                            @{@"242":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-242-1-year-experience/"},
                            @{@"243":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-243-2-5-years-experience/"},
                            @{@"244":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-244-for-sde-1-hyderabad/"},
                            @{@"245":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-245-for-2-5-years/"},
                            @{@"246":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-246-for-sde-2/"},
                            @{@"247":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-247-for-sde-2/"},
                            @{@"248":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-248-4-8-yrs-experience-for-sde-ii/"},
                            @{@"249":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-249-telephonic-interview/"},
                            @{@"250":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-250/"},
                            @{@"252":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-252-for-sdet/"},
                            @{@"253":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-253-for-sde1i/"},
                            @{@"254":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-254-off-campus-sde1/"},
                            @{@"255":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-255-on-campus/"},
                            @{@"256":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-256-written-test-for-sde1/"},
                            @{@"257":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-257-off-campus/"},
                            @{@"258":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-258-for-sde1/"},
                            @{@"259":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-259-1-yr-experienced-for-sde1/"},
                            @{@"260":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-260-for-sde2/"},
                            @{@"261":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-261-sde1/"},
                            @{@"262":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-262-for-sde1/"},
                            @{@"263":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-263-for-sdet/"},
                            @{@"264":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-264-experienced-for-sde1/"},
                            @{@"265":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-265-on-campus-internship/"},
                            @{@"266":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-266-off-campus/"},
                            @{@"267":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-267-8-months-experienced/"},
                            @{@"268":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-268-experienced/"},
                            @{@"269":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-269-1-year-experienced-for-sde-1/"},
                            @{@"272":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-272-on-campus/"},
                            @{@"273":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-273-on-campus/"},
                            @{@"274":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-274-on-campus/"},
                            @{@"275":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-275-offcampus-sde-i-experienced/"},
                            @{@"276":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-276-on-campus-sde-i/"},
                            @{@"277":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-277-for-internship/"},
                            @{@"278":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-278-on-campus/"},
                            @{@"279":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-279-on-campus-for-internship/"},
                            @{@"200":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-200/"},
                            @{@"199":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-199-on-campus-for-internship/"},
                            @{@"198":@"http://www.geeksforgeeks.org/amazon-interview-experience-198-for-sde1/"},
                            @{@"197":@"http://www.geeksforgeeks.org/amazon-interview-experience-197-on-campus-for-internship/"},
                            @{@"196":@"http://www.geeksforgeeks.org/amazon-interview-experience-196-on-campus/"},
                            @{@"195":@"http://www.geeksforgeeks.org/amazon-interview-experience-195-on-campus-for-sde-1/"},
                            @{@"194":@"http://www.geeksforgeeks.org/amazon-interview-experience-194-for-software-support-engineer/"},
                            @{@"193":@"http://www.geeksforgeeks.org/amazon-interview-experience-193-for-sde-1/"},
                            @{@"192":@"http://www.geeksforgeeks.org/amazon-interview-experience-192/"},
                            @{@"191":@"http://www.geeksforgeeks.org/amazon-interview-experience-191/"},
                            @{@"190":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-190-delhi-drive/"},
                            @{@"189":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-189-for-sde1/"},
                            @{@"188":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-188-for-sde1/"},
                            @{@"187":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-187-for-sde1/"},
                            @{@"186":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-186-for-sde1/"},
                            @{@"185":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-185-for-sde1/"},
                            @{@"184":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-184-off-campus-for-sde1/"},
                            @{@"183":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-183-sde-new-grad-position/"},
                            @{@"182":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-182-for-sdet-1/"},
                            @{@"181":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-181-for-sde-1/"},
                            @{@"180":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-180-telephonic-interview/"},
                            @{@"179":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-179-for-sde-1/"},
                            @{@"178":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-178-sde-1/"},
                            @{@"177":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-177-first-round-pool-campus/"},
                            @{@"176":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-176-sde-1/"},
                            @{@"175":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-175-sde/"},
                            @{@"174":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-174-sde/"},
                            @{@"173":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-173-campus/"},
                            @{@"171":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-171/"},
                            @{@"170":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-170/"},
                            @{@"169":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-169-sde-2/"},
                            @{@"168":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-168/"},
                            @{@"167":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-167-sde-1-year-6-months-experience/"},
                            @{@"166":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-166-sde/"},
                            @{@"165":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-165-sde-2/"},
                            @{@"164":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-164-sde/"},
                            @{@"163":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-163-sde-ii/"},
                            @{@"162":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-162/"},
                            @{@"161":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-161-off-campus-sde-1-banglore/"},
                            @{@"160":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-160-sde-2/"},
                            @{@"159":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-159-off-campus/"},
                            @{@"158":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-158-off-campus/"},
                            @{@"157":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-157-campus/"},
                            @{@"156":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-156-campus/"},
                            @{@"155":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-155-campus/"},
                            @{@"154":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-154-sde2/"},
                            @{@"153":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-153-sde1/"},
                            @{@"152":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-152-kindle-team-sde-1/"},
                            @{@"151":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-151-sde/"},
                            @{@"150":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-150-sde1-1-year-experienced/"},
                            @{@"149":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-149-campus-internship/"},
                            @{@"148":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-148/"},
                            @{@"147":@"http://www.geeksforgeeks.org/amazon-interview-questions-set-147/"},
                            @{@"146":@"http://www.geeksforgeeks.org/amazon-interview-questions-set-146/"},
                            @{@"145":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-145-campus/"},
                            @{@"144":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-144-campus-sde-1/"},
                            @{@"143":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-143-campus-sde-1/"},
                            @{@"142":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-142-campus-sde-1/"},
                            @{@"141":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-141-sde1/"},
                            @{@"140":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-140-experienced-sde/"},
                            @{@"139":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-139/"},
                            @{@"138":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-138-sde-1/"},
                            @{@"137":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-137-assessment-test-sde/"},
                            @{@"136":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-136-sde-t/"},
                            @{@"135":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-135-campus-sde/"},
                            @{@"134":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-134-campus-sde/"},
                            @{@"133":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-133/"},
                            @{@"132":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-132-for-sde-intern/"},
                            @{@"131":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-131-sdet-1/"},
                            @{@"130":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-130-sdet-1/"},
                            @{@"128":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-128-sdet/"},
                            @{@"126":@"http://www.geeksforgeeks.org/amazon-interview-experience-set-126-internship/"},
                            @{@"125":@"http://www.geeksforgeeks.org/amazon-interview-set-125-on-campus-for-internship/"},
                            @{@"124":@"http://www.geeksforgeeks.org/amazon-interview-set-124-campus/"},
                            @{@"123":@"http://www.geeksforgeeks.org/amazon-interview-set-123-campus-internship/"},
                            @{@"122":@"http://www.geeksforgeeks.org/amazon-interview-set-122-campus-internship/"},
                            @{@"121":@"http://www.geeksforgeeks.org/amazon-interview-set-121-campus-sde-1/"},
                            @{@"120":@"http://www.geeksforgeeks.org/amazon-interview-set-120-campus-internship/"},
                            @{@"119":@"http://www.geeksforgeeks.org/amazon-interview-set-119-campus-internship/"},
                            @{@"118":@"http://www.geeksforgeeks.org/amazon-interview-set-118-campus-internship/"},
                            @{@"117":@"http://www.geeksforgeeks.org/amazon-interview-set-117-campus-internship/"},
                            @{@"116":@"http://www.geeksforgeeks.org/amazon-interview-set-116-on-campus/"},
                            @{@"115":@"http://www.geeksforgeeks.org/amazon-interview-set-115-on-campus/"},
                            @{@"114":@"http://www.geeksforgeeks.org/amazon-interview-set-114-campus-internship/"},
                            @{@"113":@"http://www.geeksforgeeks.org/amazon-interview-set-113-campus-internship/"},
                            @{@"112":@"http://www.geeksforgeeks.org/amazon-interview-set-112-campus/"},
                            @{@"111":@"http://www.geeksforgeeks.org/amazon-interview-set-111-campus/"},
                            @{@"110":@"http://www.geeksforgeeks.org/amazon-interview-set-110-campus/"},
                            @{@"109":@"http://www.geeksforgeeks.org/amazon-interview-set-109-campus/"},
                            @{@"108":@"http://www.geeksforgeeks.org/amazon-interview-set-108-campus/"},
                            @{@"107":@"http://www.geeksforgeeks.org/amazon-interview-set-107/"},
                            @{@"106":@"http://www.geeksforgeeks.org/amazon-interview-set-106-campus-internship/"},
                            @{@"105":@"http://www.geeksforgeeks.org/amazon-interview-set-105-campus/"},
                            @{@"104":@"http://www.geeksforgeeks.org/amazon-interview-set-104/"},
                            @{@"103":@"http://www.geeksforgeeks.org/amazon-interview-set-103-campus/"},
                            @{@"102":@"http://www.geeksforgeeks.org/amazon-interview-set-102/"},
                            @{@"101":@"http://www.geeksforgeeks.org/amazon-interview-set-101-campus/"},
                            @{@"100":@"http://www.geeksforgeeks.org/amazon-interview-set-100-campus/"},
                            @{@"99":@"http://www.geeksforgeeks.org/amazon-interview-set-99-campus/"},
                            @{@"98":@"http://www.geeksforgeeks.org/amazon-interview-set-98-campus/"},
                            @{@"97":@"http://www.geeksforgeeks.org/amazon-interview-set-97-campus-sde1/"},
                            @{@"96":@"http://www.geeksforgeeks.org/amazon-interview-set-96-campus-internship/"},
                            @{@"95":@"http://www.geeksforgeeks.org/amazon-interview-set-95-sde/"},
                            @{@"93":@"http://www.geeksforgeeks.org/amazon-interview-set-93/"},
                            @{@"91":@"http://www.geeksforgeeks.org/amazon-interview-set-91/"},
                            @{@"90":@"http://www.geeksforgeeks.org/amazon-interview-set-90/"},
                            @{@"89":@"http://www.geeksforgeeks.org/amazon-interview-set-89/"},
                            @{@"88":@"http://www.geeksforgeeks.org/amazon-interview-set-88/"},
                            @{@"86":@"http://www.geeksforgeeks.org/amazon-interview-set-86-sde/"},
                            @{@"85":@"http://www.geeksforgeeks.org/amazon-interview-set-85/"},
                            @{@"84":@"http://www.geeksforgeeks.org/amazon-interview-set-84/"},
                            @{@"83":@"http://www.geeksforgeeks.org/amazon-interview-set-83/"},
                            @{@"82":@"http://www.geeksforgeeks.org/amazon-interview-set-82-for-sde-2/"},
                            @{@"81":@"http://www.geeksforgeeks.org/amazon-interview-set-81-for-sde-i/"},
                            @{@"80":@"http://www.geeksforgeeks.org/amazon-interview-set-80/"},
                            @{@"79":@"http://www.geeksforgeeks.org/amazon-interview-set-79-sde-1/"},
                            @{@"78":@"http://www.geeksforgeeks.org/amazon-interview-set-78-fresher-internship/"},
                            @{@"77":@"http://www.geeksforgeeks.org/amazon-interview-set-77-sde-1/"},
                            @{@"76":@"http://www.geeksforgeeks.org/amazon-interview-set-76-sde-1/"},
                            @{@"75":@"http://www.geeksforgeeks.org/amazon-interview-set-75-sde-1/"},
                            @{@"74":@"http://www.geeksforgeeks.org/amazon-interview-set-74/"},
                            @{@"73":@"http://www.geeksforgeeks.org/amazon-interview-set-73-for-sde-1/"},
                            @{@"72":@"http://www.geeksforgeeks.org/amazon-interview-set-72-campus-sde-1/"},
                            @{@"71":@"http://www.geeksforgeeks.org/amazon-interview-set-71-sde-2/"},
                            @{@"70":@"http://www.geeksforgeeks.org/amazon-interview-set-70-on-campus/"},
                            @{@"69":@"http://www.geeksforgeeks.org/amazon-interview-set-69-sde-1/"},
                            @{@"68":@"http://www.geeksforgeeks.org/amazon-interview-set-68-for-sde-1/"},
                            @{@"67":@"http://www.geeksforgeeks.org/amazon-interview-set-67-for-sde-1/"},
                            @{@"66":@"http://www.geeksforgeeks.org/amazon-interview-set-66-for-sde/"},
                            @{@"65":@"http://www.geeksforgeeks.org/amazon-interview-set-65-off-campus-for-sde-2amazon-interview-set-65-campus-sde/"},
                            @{@"64":@"http://www.geeksforgeeks.org/amazon-interview-set-64-campus-sde/"},
                            @{@"63":@"http://www.geeksforgeeks.org/amazon-interview-set-63-sde-1/"},
                            @{@"62":@"http://www.geeksforgeeks.org/amazon-interview-set-62-for-sde-1/"},
                            @{@"61":@"http://www.geeksforgeeks.org/amazon-interview-set-61-internship/"},
                            @{@"60":@"http://www.geeksforgeeks.org/amazon-interview-set-60-internship/"},
                            @{@"59":@"http://www.geeksforgeeks.org/amazon-interview-set-59-campus-sde-1/"},
                            @{@"58":@"http://www.geeksforgeeks.org/amazon-interview-set-58-campus-software-development-engineer/"},
                            @{@"57":@"http://www.geeksforgeeks.org/amazon-interview-set-57/"},
                            @{@"56":@"http://www.geeksforgeeks.org/amazon-interview-set-56-campus/"},
                            @{@"55":@"http://www.geeksforgeeks.org/amazon-interview-set-55-on-campus/"},
                            @{@"54":@"http://www.geeksforgeeks.org/amazon-interview-set-54-on-campus-for-sde/"},
                            @{@"53":@"http://www.geeksforgeeks.org/amazon-interview-set-53-sde-1/"},
                            @{@"52":@"http://www.geeksforgeeks.org/amazon-interview-set-52-internship/"},
                            @{@"51":@"http://www.geeksforgeeks.org/amazon-interview-set-51-campus-sdet/"},
                            @{@"50":@"http://www.geeksforgeeks.org/amazon-interview-set-50-campus-sde/"},
                            @{@"49":@"http://www.geeksforgeeks.org/amazon-interview-set-49-campus-sde-1/"},
                            @{@"48":@"http://www.geeksforgeeks.org/amazon-interview-set-48-campus-sde-1/"},
                            @{@"47":@"http://www.geeksforgeeks.org/amazon-interview-set-47-off-campus-for-sde-1/"},
                            @{@"46":@"http://www.geeksforgeeks.org/amazon-interview-set-46-campus-internship/"},
                            @{@"45":@"http://www.geeksforgeeks.org/amazon-interview-set-45-internship/"},
                            @{@"44":@"http://www.geeksforgeeks.org/amazon-interview-set-44-for-internship/"},
                            @{@"43":@"http://www.geeksforgeeks.org/amazon-interview-set-43-campus/"},
                            @{@"42":@"http://www.geeksforgeeks.org/amazon-interview-set-42-on-campus/"},
                            @{@"41":@"http://www.geeksforgeeks.org/amazon-interview-set-41-campus/"},
                            @{@"40":@"http://www.geeksforgeeks.org/amazon-interview-set-40-campus-round-1/"},
                            @{@"39":@"http://www.geeksforgeeks.org/amazon-interview-set-39/"},
                            @{@"38":@"http://www.geeksforgeeks.org/amazon-interview-set-38/"},
                            @{@"37":@"http://www.geeksforgeeks.org/amazon-interview-set-37/"},
                            @{@"36":@"http://www.geeksforgeeks.org/amazon-interview-set-36/"},
                            @{@"35":@"http://www.geeksforgeeks.org/amazon-interview-set-35/"},
                            @{@"34":@"http://www.geeksforgeeks.org/amazon-interview-set-34/"},
                            @{@"33":@"http://www.geeksforgeeks.org/amazon-interview-set-33-2/"},
                            @{@"32":@"http://www.geeksforgeeks.org/amazon-interview-set-32/"},
                            @{@"31":@"http://www.geeksforgeeks.org/amazon-interview-set-31/"},
                            @{@"30":@"http://www.geeksforgeeks.org/amazon-interview-set-30/"},
                            @{@"29":@"http://www.geeksforgeeks.org/amazon-interview-set-29/"},
                            @{@"27":@"http://www.geeksforgeeks.org/amazon-interview-set-27/"},
                            @{@"26":@"http://www.geeksforgeeks.org/amazon-interview-set-26/"},
                            @{@"25":@"http://www.geeksforgeeks.org/amazon-interview-set-25/"},
                            @{@"24":@"http://www.geeksforgeeks.org/amazon-interview-set-24/"},
                            @{@"23":@"http://www.geeksforgeeks.org/amazon-interview-set-23/"},
                            @{@"22":@"http://www.geeksforgeeks.org/amazon-interview-set-22/"},
                            @{@"21":@"http://www.geeksforgeeks.org/amazon-interview-set-21/"},
                            @{@"20":@"http://www.geeksforgeeks.org/amazon-interview-set-20/"},
                            @{@"19":@"http://www.geeksforgeeks.org/amazon-interview-set-19/"},
                            @{@"18":@"http://www.geeksforgeeks.org/amazon-interview-set-18/"},
                            @{@"17":@"http://www.geeksforgeeks.org/amazon-interview-set-17/"},
                            @{@"16":@"http://www.geeksforgeeks.org/amazon-interview-set-16/"},
                            @{@"14":@"http://www.geeksforgeeks.org/amazon-interview-set-14-2/"},
                            @{@"13":@"http://www.geeksforgeeks.org/amazon-interview-set-13/"},
                            @{@"12":@"http://www.geeksforgeeks.org/amazon-interview-set-12/"},
                            @{@"11":@"http://www.geeksforgeeks.org/amazon-interview-set-11/"},
                            @{@"10":@"http://www.geeksforgeeks.org/amazon-interview-set-10/"},
                            @{@"9":@"http://www.geeksforgeeks.org/amazon-interview-set-9-answers/"},
                            @{@"8":@"http://www.geeksforgeeks.org/amazon-interview-set-8-2/"},
                            @{@"6":@"http://www.geeksforgeeks.org/amazon-interview-2/"},
                            @{@"5":@"http://www.geeksforgeeks.org/amazon-interview-set-4-3/"},
                            @{@"4":@"http://www.geeksforgeeks.org/amazon-interview-set-4-2/"},
                            @{@"3":@"http://www.geeksforgeeks.org/amazon-interview-set-3/"},
                            @{@"2":@"http://www.geeksforgeeks.org/amazon-interview-set-2/"},
                            @{@"1":@"http://www.geeksforgeeks.org/amazon-interview/"}
                            ];
    
    NSMutableDictionary* dbDict = [@{} mutableCopy];
    
    for (NSDictionary* dict in inputArray) {
        
        NSString* setPrefix = @"Set No. ";
        
        setPrefix = [setPrefix stringByAppendingString:dict.allKeys.firstObject];
        
        NSDictionary* modifiedDict = @{
                                       KEY_NAME:setPrefix,
                                       KEY_URL:[dict.allValues firstObject],
                                       KEY_COMPLETED:@NO,
                                       KEY_OPENED:@NO
                                       };
        [dbDict setValue:[modifiedDict copy] forKey:[[dict.allKeys firstObject] copy]];
    }
    
    NSMutableDictionary* amazonDict = [@{} mutableCopy];
    
    [amazonDict setValue:dbDict forKey:@"Amazon"];

    //for first time db initialisation --> when entire db is empty
//    NSMutableDictionary* setDict = [@{} mutableCopy];
//    [setDict setValue:amazonDict forKey:KEY_SETS];
//    
//    [self.databaseRef updateChildValues:setDict];
    
    [[self.databaseRef child:KEY_SETS] updateChildValues:amazonDict];
}
- (void) writeDirectIData {
    
    //FIRDatabaseReference* dbWriteReference = [self.databaseRef child:KEY_SETS];
    
    // dbWriteReference = [self.databaseRef child:@"Amazon"];
    
    NSArray* inputArray = @[@{@"Directi Interview Experience | Set 15 (On-Campus)":@"http://www.geeksforgeeks.org/directi-interview-experience-set-15-on-campus-2/"},
                            @{@"Directi Interview Experience | Set 14 (On-Campus)":@"http://www.geeksforgeeks.org/directi-interview-experience-set-14-on-campus/"},
                            @{@"Directi Interview | Set 13":@"http://www.geeksforgeeks.org/directi-interview-set-13/"},
                            @{@"Directi Interview | Set 12 (On-Campus)":@"http://www.geeksforgeeks.org/directi-interview-set-12-on-campus/"},
                            @{@"Directi Interview | Set 11 (On-Campus)":@"http://www.geeksforgeeks.org/directi-interview-set-11-on-campus/"},
                            @{@"Directi Interview | Set 10 (On-Campus)":@"http://www.geeksforgeeks.org/directi-interview-set-10-on-campus/"},
                            @{@"Directi Interview | Set 9 (On-Campus)":@"http://www.geeksforgeeks.org/directi-interview-set-9-on-campus/"},
                            @{@"Directi Interview | Set 8 (Off-Campus)":@"http://www.geeksforgeeks.org/directi-interview-set-8-off-campus/"},
                            @{@"Directi Interview | Set 7 (Programming Questions)":@"http://www.geeksforgeeks.org/directi-programming-questions/"},
                            @{@"Directi Interview | Set 6 (On-Campus for Internship)":@"http://www.geeksforgeeks.org/directi-interview-set-6-campus-internship/"},
                            @{@"Directi Interview | Set 5 (On-Campus)":@"http://www.geeksforgeeks.org/directi-interview-set-5-campus/"},
                            @{@"Directi Interview Questions":@"http://www.geeksforgeeks.org/directi-interview-questions/"},
                            @{@"Directi Interview | Set 3":@"http://www.geeksforgeeks.org/directi-interview-set-3/"},
                            @{@"Directi Interview | Set 2":@"http://www.geeksforgeeks.org/directi-interview-set-2/"},
                            @{@"Directi Interview | Set 1":@"http://www.geeksforgeeks.org/directi-interview-set-1/"}];
    
    NSMutableDictionary* dbDict = [@{} mutableCopy];
    
    for (NSDictionary* dict in inputArray) {
        NSDictionary* modifiedDict = @{
                                       KEY_NAME:[dict.allKeys firstObject],
                                       KEY_URL:[dict.allValues firstObject],
                                       KEY_COMPLETED:@NO,
                                       KEY_OPENED:@NO
                                       };
        [dbDict setValue:[modifiedDict copy] forKey:[[dict.allKeys firstObject] copy]];
    }
    
    NSMutableDictionary* amazonDict = [@{} mutableCopy];
    
    [amazonDict setValue:dbDict forKey:@"Directi"];
    
    //for first time db initialisation --> when entire db is empty
    //    NSMutableDictionary* setDict = [@{} mutableCopy];
    //    [setDict setValue:amazonDict forKey:KEY_SETS];
    //
    //    [self.databaseRef updateChildValues:setDict];
    
    [[self.databaseRef child:KEY_SETS] updateChildValues:amazonDict];
}
- (void) writeCiscoData {
    
    //FIRDatabaseReference* dbWriteReference = [self.databaseRef child:KEY_SETS];
    
    // dbWriteReference = [self.databaseRef child:@"Amazon"];
    
    NSArray* inputArray = @[@{@"Cisco Interview Experience | Set 12":@"http://www.geeksforgeeks.org/cisco-interview-experience-set-12/"},
                            @{@"Cisco Interview Experience | Set 11 (Network Consultant Engineer)":@"http://www.geeksforgeeks.org/cisco-interview-experience-set-11-network-consultant-engineer/"},
                            @{@"Cisco Interview Experience | Set 10 (On-Campus for Internship)":@"http://www.geeksforgeeks.org/cisco-interview-experience-set-10-on-campus-for-internship/"},
                            @{@"Cisco Interview Experience | Set 9 (For Experienced)":@"http://www.geeksforgeeks.org/cisco-interview-experience-set-9-experienced/"},
                            @{@"Cisco Interview Experience | Set 8 (On-Campus)":@"http://www.geeksforgeeks.org/cisco-interview-experience-set-8on-campus/"},
                            @{@"Cisco Interview | Set 7(On-Campus)":@"http://www.geeksforgeeks.org/cisco-interview-set-7on-campus/"},
                            @{@"Cisco Interview | Set 6":@"http://www.geeksforgeeks.org/cisco-interview-set-6/"},
                            @{@"Cisco Interview | Set 5":@"http://www.geeksforgeeks.org/cisco-interview-set-5/"},
                            @{@"Cisco Interview | Set 4":@"http://www.geeksforgeeks.org/cisco-interview-set-4/"},
                            @{@"Cisco Interview | Set 3":@"http://www.geeksforgeeks.org/cisco-interview-set-3/"},
                            @{@"Cisco Interview | Set 2":@"http://www.geeksforgeeks.org/cisco-interview-set-2/"},
                            @{@"Cisco Interview | Set 1":@"http://www.geeksforgeeks.org/cisco-interview-set-1/"}];
    
    NSMutableDictionary* dbDict = [@{} mutableCopy];
    
    for (NSDictionary* dict in inputArray) {
        NSDictionary* modifiedDict = @{
                                       KEY_NAME:[dict.allKeys firstObject],
                                       KEY_URL:[dict.allValues firstObject],
                                       KEY_COMPLETED:@NO,
                                       KEY_OPENED:@NO
                                       };
        [dbDict setValue:[modifiedDict copy] forKey:[[dict.allKeys firstObject] copy]];
    }
    
    NSMutableDictionary* amazonDict = [@{} mutableCopy];
    
    [amazonDict setValue:dbDict forKey:@"Cisco"];
    
    //for first time db initialisation --> when entire db is empty
    //    NSMutableDictionary* setDict = [@{} mutableCopy];
    //    [setDict setValue:amazonDict forKey:KEY_SETS];
    //
    //    [self.databaseRef updateChildValues:setDict];
    
    [[self.databaseRef child:KEY_SETS] updateChildValues:amazonDict];
}
- (void) writeYahooData {
    
    //FIRDatabaseReference* dbWriteReference = [self.databaseRef child:KEY_SETS];
    
    // dbWriteReference = [self.databaseRef child:@"Amazon"];
    
    NSArray* inputArray = @[@{@"Yahoo Interview Experience | Set 4 (On-Campus for System Engineer)":@"http://www.geeksforgeeks.org/yahoo-interview-experience-set-4-on-campus-for-system-engineer/"},
                            @{@"TopTalent in Want to know how to get into Yahoo! ? Read our exclusive Interview with Prabha":@"http://www.geeksforgeeks.org/toptalent-want-know-get-yahoo-read-exclusive-interview-prabha/"},
                            @{@"Yahoo Interview | Set 3":@"http://www.geeksforgeeks.org/yahoo-interview-set-3-2/"},
                            @{@"Yahoo Interview | Set 3":@"http://www.geeksforgeeks.org/yahoo-interview-set-3/"},
                            @{@"Yahoo Interview | Set 2":@"http://www.geeksforgeeks.org/yahoo-interview-set-2/"},
                            @{@"Yahoo Interview | Set 1":@"http://www.geeksforgeeks.org/yahoo-interview-set-1/"}];
    
    NSMutableDictionary* dbDict = [@{} mutableCopy];
    
    for (NSDictionary* dict in inputArray) {
        NSDictionary* modifiedDict = @{
                                       KEY_NAME:[dict.allKeys firstObject],
                                       KEY_URL:[dict.allValues firstObject],
                                       KEY_COMPLETED:@NO,
                                       KEY_OPENED:@NO
                                       };
        [dbDict setValue:[modifiedDict copy] forKey:[[dict.allKeys firstObject] copy]];
    }
    
    NSMutableDictionary* amazonDict = [@{} mutableCopy];
    
    [amazonDict setValue:dbDict forKey:@"Yahoo"];
    
    //for first time db initialisation --> when entire db is empty
    //    NSMutableDictionary* setDict = [@{} mutableCopy];
    //    [setDict setValue:amazonDict forKey:KEY_SETS];
    //
    //    [self.databaseRef updateChildValues:setDict];
    
    [[self.databaseRef child:KEY_SETS] updateChildValues:amazonDict];
}
- (void) writeOracleData {
    
    //FIRDatabaseReference* dbWriteReference = [self.databaseRef child:KEY_SETS];
    
    // dbWriteReference = [self.databaseRef child:@"Amazon"];
    
    NSArray* inputArray = @[@{@"Oracle Interview Experience | Set 40 ( FSS Application Developer )":@"http://www.geeksforgeeks.org/oracle-interview-experience-set-40-fss-application-developer/"},
                            @{@"Oracle Interview Experience | Set 39 (Application Developer )":@"http://www.geeksforgeeks.org/oracle-interview-experience-set-39-application-developer/"},
                            @{@"Oracle Interview Experience | Set 38":@"http://www.geeksforgeeks.org/oracle-interview-experience-set-38/"},
                            @{@"Oracle Interview Experience | Set 37 (Application Developer )":@"http://www.geeksforgeeks.org/oracle-interview-experience-set-37-application-developer/"},
                            @{@"Oracle Interview Experience | Set 36 (Application Developer for OFSS)":@"http://www.geeksforgeeks.org/oracle-interview-experience-set-36-application-developer-for-ofss/"},
                            @{@"Oracle Interview Experience | Set 35 (On-campus)":@"http://www.geeksforgeeks.org/oracle-interview-experience-set-35-on-campus/"},
                            @{@"Oracle Interview Experience | Set 34 (On-campus for Application Developer)":@"http://www.geeksforgeeks.org/oracle-interview-experience-set-34-on-campus-for-application-developer/"},
                            @{@"Oracle Interview Experience | Set 33 (On-campus Application Development Engineer)":@"http://www.geeksforgeeks.org/oracle-interview-experience-set-33-on-campus-application-development-engineer/"},
                            @{@"Oracle Interview Experience | Set 32 (On-campus for Global Business Unit)":@"http://www.geeksforgeeks.org/oracle-interview-experience-set-32-on-campus-for-global-business-unit/"},
                            @{@"Oracle Interview Experience | Set 31 (On-campus for Global Business Unit)":@"http://www.geeksforgeeks.org/oracle-interview-experience-set-31-on-campus-for-global-business-unit/"},
                            @{@"Oracle Interview Experience | Set 30 (On-campus for Global Business Unit)":@"http://www.geeksforgeeks.org/oracle-interview-experience-set-30-on-campus-for-global-business-unit/"},
                            @{@"Oracle Interview Experience | Set 29 (On-Campus for Server Technology)":@"Oracle Interview Experience | Set 29 (On-Campus for Server Technology)"},
                            @{@"Oracle Interview Experience | Set 28 (Application Development Engineer)":@"http://www.geeksforgeeks.org/oracle-interview-experience-set-27-application-development-engineer/"},
                            @{@"Oracle Interview Experience | Set 27 (On-Campus)":@"http://www.geeksforgeeks.org/oracle-interview-experience-set-27-on-campus-for-st-full-time/"},
                            @{@"Oracle Interview Experience | Set 26 (On-Campus for ST Full Time)":@"http://www.geeksforgeeks.org/oracle-interview-experience-set-26-on-campus-for-st-full-time/"},
                            @{@"Oracle Interview Experience | Set 25 (On-Campus)":@"http://www.geeksforgeeks.org/oracle-interview-experience-set-25-on-campus/"},
                            @{@"Oracle Interview Experience | Set 24 (On-Campus for Global Business Unit)":@"http://www.geeksforgeeks.org/oracle-interview-experience-set-24-on-campus-for-global-business-unit/"},
                            @{@"Oracle Interview Experience | Set 23 (On-Campus)":@"http://www.geeksforgeeks.org/oracle-interview-experience-set-23-on-campus/"},
                            @{@"Oracle Interview Experience | Set 22 (On-Campus for Oracle Financial Services Software)":@"http://www.geeksforgeeks.org/oracle-interview-experience-set-22-on-campus-for-oracle-financial-services-software/"},
                            @{@"Oracle Interview Experience | Set 21 (On-Campus for Application Developer)":@"http://www.geeksforgeeks.org/oracle-interview-experience-set-21-on-campus-for-application-developer/"},
                            @{@"Oracle Interview Experience | Set 20 (On-Campus for Oracle Financial Services Software)":@"http://www.geeksforgeeks.org/oracle-interview-experience-set-20-on-campus-for-oracle-financial-services-software/"},
                            @{@"Oracle Interview Experience | Set 19 (On-Campus for App Development)":@"http://www.geeksforgeeks.org/oracle-interview-experience-set-19-on-campus-for-app-development/"},
                            @{@"Oracle Interview Experience | Set 18 (On-Campus for GBU App Development)":@"http://www.geeksforgeeks.org/oracle-interview-experience-set-18-on-campus-for-gbu-app-development/"},
                            @{@"Oracle Interview Experience | Set 17 (On-Campus)":@"http://www.geeksforgeeks.org/oracle-interview-experience-set-17-on-campus/"},
                            @{@"Oracle Interview Experience | Set 16 (On-Campus for GBU Developer Profile)":@"http://www.geeksforgeeks.org/oracle-interview-experience-set-16-on-campus-for-gbu-developer-profile/"},
                            @{@"Oracle Interview Experience | Set 15 (On-Campus)":@"http://www.geeksforgeeks.org/oracle-interview-experience-set-15-on-campus/"},
                            @{@"Oracle Interview Experience | Set 14 (On-Campus for Server Tech)":@"http://www.geeksforgeeks.org/oracle-interview-experience-set-14-on-campus-for-server-tech/"},
                            @{@"Oracle Interview Experience | Set 13 (On-Campus)":@"http://www.geeksforgeeks.org/oracle-interview-set-13-on-campus/"},
                            @{@"Oracle Interview | Set 12 (On Campus for Application Dev Profile)":@"http://www.geeksforgeeks.org/oracle-interview-set-12-on-campus-for-application-dev-profile/"},
                            @{@"Oracle Interview | Set 11 (For Server Technology)":@"http://www.geeksforgeeks.org/oracle-interview-set-11-server-technology/"},
                            @{@"Oracle Interview | Set 10 (For Server Technology)":@"http://www.geeksforgeeks.org/oracle-interview-set-10-server-technology/"},
                            @{@"Oracle Interview | Set 9 (On campus for Application Development profile)":@"http://www.geeksforgeeks.org/oracle-interview-set-9-campus-application-development-profile/"},
                            @{@"Oracle Interview | Set 8 (On Campus for Application Developer)":@"http://www.geeksforgeeks.org/oracle-interview-set-8-campus-application-developer-2/"},
                            @{@"Oracle Interview | Set 8":@"http://www.geeksforgeeks.org/oracle-interview-set-8/"},
                            @{@"Oracle Interview | Set 7":@"http://www.geeksforgeeks.org/oracle-interview-set-7/"},
                            @{@"Oracle Interview | Set 6":@"http://www.geeksforgeeks.org/oracle-interview-set-6/"},
                            @{@"Oracle Interview | Set 5 (For Server Technologies)":@"http://www.geeksforgeeks.org/oracle-interview-set-5-server-technologies/"},
                            @{@"Oracle Interview | Set 4 (On-Campus)":@"http://www.geeksforgeeks.org/oracle-interview-set-4-campus/"},
                            @{@"Oracle Interview | Set 3 (On-Campus)":@"http://www.geeksforgeeks.org/oracle-interview-set-3-campus/"},
                            @{@"Oracle Interview | Set 2 (On-Campus)":@"http://www.geeksforgeeks.org/oracle-interview-set-2-campus/"},
                            @{@"Oracle Interview | Set 1":@"http://www.geeksforgeeks.org/oracle-server-technology-interview-set-1/"}];
    
    NSMutableDictionary* dbDict = [@{} mutableCopy];
    
    for (NSDictionary* dict in inputArray) {
        NSDictionary* modifiedDict = @{
                                       KEY_NAME:[dict.allKeys firstObject],
                                       KEY_URL:[dict.allValues firstObject],
                                       KEY_COMPLETED:@NO,
                                       KEY_OPENED:@NO
                                       };
        [dbDict setValue:[modifiedDict copy] forKey:[[dict.allKeys firstObject] copy]];
    }
    
    NSMutableDictionary* amazonDict = [@{} mutableCopy];
    
    [amazonDict setValue:dbDict forKey:@"Oracle"];
    
    //for first time db initialisation --> when entire db is empty
    //    NSMutableDictionary* setDict = [@{} mutableCopy];
    //    [setDict setValue:amazonDict forKey:KEY_SETS];
    //
    //    [self.databaseRef updateChildValues:setDict];
    
    [[self.databaseRef child:KEY_SETS] updateChildValues:amazonDict];
}

#pragma mark - FIR update methods

- (void) ab_fetchUpdatedData {
    [self.databaseRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
        
        id data = snapshot.value[KEY_SETS][self.topicName];
        
        NSMutableArray* setArray = [@[] mutableCopy];
       
        if ([data isKindOfClass:[NSArray class]]) {
            NSArray* dataArray = (NSArray*)data;
            for (NSDictionary* dict in dataArray) {
                if ([dict isKindOfClass:[NSDictionary class]]) {
                    [setArray addObject:dict];
                }
            }
        }
        else if ([data isKindOfClass:[NSDictionary class]]) {
           
            NSDictionary* dataDict = (NSDictionary*)data;
            
            NSArray* keyArray = dataDict.allKeys;
            
            keyArray = [keyArray sortedArrayUsingSelector:@selector(compare:)];
            keyArray = [[keyArray reverseObjectEnumerator] allObjects];
            
            
            for (NSString* key in keyArray) {
                NSDictionary* valueDict = ([dataDict[key] isKindOfClass:[NSDictionary class]])?(dataDict[key]):(nil);
                NSMutableDictionary* nameDict = [valueDict mutableCopy];
                [nameDict setValue:key forKey:@"name"];
                if (nameDict) {
                    [setArray addObject:nameDict];
                }
            }
        }
        
        setArray = [[[setArray reverseObjectEnumerator] allObjects] mutableCopy];
        
        self.dataArray = [setArray copy];
        
        self.dataSourceArray = [setArray copy];
        
        [self.tableView reloadData];
        
        if (self.dataSourceArray.count) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            BOOL isCoachMarkSeen = [[NSUserDefaults standardUserDefaults] boolForKey:KEY_IS_SET_LIST_COACH_MARK_SEEN];
            if (!isCoachMarkSeen) {
                [self ab_createCoachMarks];
            }
        }
        
    } withCancelBlock:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
}

- (NSDictionary*) ab_unwrapNameDict:(NSDictionary*) nameDict {
    NSString* name = nameDict[KEY_NAME];
    
    NSDictionary* serverDict = @{name:nameDict};
    return serverDict;
}

- (void) ab_writeUpdateStatus {
  
    NSString* uniqueID =  [[Utility sharedInsance] ab_getUserID];
    
    NSString* userKey = @"users";
    
    NSDictionary* emptyDict = @{uniqueID:@{KEY_COMPLETED:self.completedArray.copy,KEY_OPENED:self.openedArray.copy}};
    
    [[self.databaseRef child:userKey] updateChildValues:emptyDict];
    
////    FIRDatabaseReference* dbWriteReference = [[self.databaseRef child:KEY_SETS] child:self.topicName];
////    [dbWriteReference updateChildValues:dict];
//    [self ab_fetchUpdatedData];
}

- (void) ab_updateCompletedStatusForDict:(NSDictionary*) dict isCompleted:(BOOL) completedStatus {
    if (completedStatus) {
         [self.completedArray addObject:dict[KEY_URL]];
        [self.openedArray addObject:dict[KEY_URL]];
    }
    else {
        [self.completedArray removeObject:dict[KEY_URL]];
    }
    [self ab_writeUpdateStatus];
}

- (void) ab_updateOpenedStatusForDict:(NSDictionary*) dict {
    [self.openedArray addObject:dict[KEY_URL]];
    [self ab_writeUpdateStatus];
}

#pragma mark - Delegate methods

- (void) actionButtonSelectedForSelectedState:(BOOL) isCompleted forIndexPath:(NSIndexPath*) indexPath {
    NSDictionary* dict = self.dataSourceArray[indexPath.row];
    [self ab_updateCompletedStatusForDict:dict isCompleted:isCompleted];
}

#pragma mark - Helper methods

- (BOOL) isValue:(NSString*) urlValue presentInArray:(NSArray*) array {
    return [array containsObject:urlValue];
    
    return NO;
}

#pragma  mark - UITableView methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSourceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AmazonSetTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:[AmazonSetTableViewCell reuseIdentifier]];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(AmazonSetTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *setDictionary = self.dataSourceArray[indexPath.row];
    BOOL isCompleted = [self isValue:self.dataSourceArray[indexPath.row][KEY_URL] presentInArray:self.completedArray];
    BOOL isOpened = [self isValue:self.dataSourceArray[indexPath.row][KEY_URL] presentInArray:self.openedArray];
    [cell setSetNoText:[NSString stringWithFormat:@"%@",setDictionary[KEY_NAME]] isCompleted:isCompleted isOpened:isOpened forIndexPath:indexPath];
    cell.setDelegate = self;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
    [self ab_updateOpenedStatusForDict:self.dataSourceArray[indexPath.row]];
    
    NSString* urlString = self.dataSourceArray[indexPath.row][KEY_URL];
    
    NSDictionary *setDictionary = self.dataSourceArray[indexPath.row];
    
   self.lastSelectedSet = [NSString stringWithFormat:@"%@",setDictionary[KEY_NAME]];
    
    GeekyWebViewController* webViewController = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([GeekyWebViewController class])];
    self.isInterstitialAdToBeStopped = NO;
    webViewController.url = urlString;
    
    int numberOfSetsOpened = (int)[[NSUserDefaults standardUserDefaults] integerForKey:KEY_NO_OF_SETS_OPENED];
    numberOfSetsOpened++;
    
    [[NSUserDefaults standardUserDefaults] setInteger:numberOfSetsOpened forKey:KEY_NO_OF_SETS_OPENED];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.lastSelectedSetTimeStamp = [NSDate date];
    
    [self.navigationController pushViewController:webViewController animated:YES];
}

#pragma mark - Interstitial Ad Methods

- (GADInterstitial *)createInterstitialAd {
    
    BOOL isInterstitialAdDisabled = [[Utility sharedInsance] getIsAdDisabled:interstitialAd];
    
    if (!isInterstitialAdDisabled && !self.isInterstitialAdToBeStopped) {
        
        self.interstitial =
        [[GADInterstitial alloc] initWithAdUnitID:@"ca-app-pub-3743202420941577/5605948044"];
        
        GADRequest *request = [GADRequest request];
        // Request test ads on devices you specify. Your test device ID is printed to the console when
        // an ad request is made.
        request.testDevices = @[ @"4979d821dabc9b7f43cb2f4dd7e3876c" ];
        [self.interstitial loadRequest:request];
        return self.interstitial;
    }
    return nil;
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)interstitial {
    self.interstitial = [self createInterstitialAd];
}

- (void) showInterstitialAd {
    BOOL isInterstitialAdDisabled = [[Utility sharedInsance] getIsAdDisabled:interstitialAd];
    
    if (!isInterstitialAdDisabled && !self.isInterstitialAdToBeStopped) {
        if ([self.interstitial isReady]) {
            self.isInterstitialAdToBeStopped = YES;
            [self.interstitial presentFromRootViewController:self];
        }
    }
}

#pragma mark - Interstitial delegate

- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error {
    // Retrying failed interstitial loads is a rudimentary way of handling these errors.
    // For more fine-grained error handling, take a look at the values in GADErrorCode.
    self.interstitial = [self createInterstitialAd];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
