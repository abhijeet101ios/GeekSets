//
//  AmazonSetTableViewCell.h
//  AmozonPracticeApp
//
//  Created by Abhijeet Mishra on 23/09/16.
//  Copyright © 2016 Abhijeet Mishra. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AmazonSetTableViewCellDelegate <NSObject>

- (void) actionButtonSelectedForSelectedState:(BOOL) isCompleted forIndexPath:(NSIndexPath*) indexPath;

@end

@interface AmazonSetTableViewCell : UITableViewCell

@property (nonatomic, weak) id<AmazonSetTableViewCellDelegate> setDelegate;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;

+ (NSString*) reuseIdentifier;

- (void) setSetNoText:(NSString*) setNoText isCompleted:(BOOL) isCompleted isOpened:(BOOL) isOpened forIndexPath:(NSIndexPath*) indexPath;

@end
