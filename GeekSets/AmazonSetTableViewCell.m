//
//  AmazonSetTableViewCell.m
//  AmozonPracticeApp
//
//  Created by Abhijeet Mishra on 23/09/16.
//  Copyright © 2016 Abhijeet Mishra. All rights reserved.
//

#import "AmazonSetTableViewCell.h"

@interface AmazonSetTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *setNoLabel;

@property (nonatomic) BOOL isCompleted;

@property (nonatomic) BOOL isOpened;

@property (nonatomic) NSIndexPath* indexPath;

@property (nonatomic) NSString* text;

@end

#define DARK_TEXT_COLOR [UIColor colorWithRed:1 green:61.0/255.0 blue:146.0/255.0 alpha:1.0]
#define LIGHT_TEXT_COLOR [UIColor colorWithRed:21.0/255.0 green:194.0/255.0 blue:127.0/255.0 alpha:1.0]

@implementation AmazonSetTableViewCell

+ (NSString*) reuseIdentifier {
    return NSStringFromClass([self class]);
}

- (void) awakeFromNib {
    [super awakeFromNib];
    self.actionButton.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.actionButton.layer.shadowOffset = CGSizeMake(1, 1);
    self.actionButton.layer.shadowOpacity = 0.2;
    self.actionButton.layer.shadowRadius = 1.0;
}

- (void) updateStrikeThrough {
    NSNumber* strikeThroughValue;
    
    if (self.isCompleted) {
        self.setNoLabel.text = nil;
        strikeThroughValue = @2;
        NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:self.text];
        [attributeString addAttribute:NSStrikethroughStyleAttributeName
                                value:strikeThroughValue
                                range:NSMakeRange(0, [attributeString length])];
        [attributeString addAttribute:NSStrikethroughColorAttributeName value:DARK_TEXT_COLOR range:NSMakeRange(0, [attributeString length])];
        self.setNoLabel.attributedText = attributeString;
    }
    else {
        self.setNoLabel.attributedText = nil;
        self.setNoLabel.text = self.text;
    }
}

- (void) setIsOpened:(BOOL)isOpened {
    
    _isOpened = isOpened;
    
    if (isOpened) {
        self.setNoLabel.textColor = LIGHT_TEXT_COLOR;
    }
    else {
        self.setNoLabel.textColor = DARK_TEXT_COLOR;
    }
}

- (void) setIsCompleted:(BOOL)isCompleted {
    _isCompleted = isCompleted;
    
    if (isCompleted) {
        [self.actionButton setImage:[UIImage imageNamed:@"reminder_selected"] forState:UIControlStateNormal];
         self.setNoLabel.textColor = LIGHT_TEXT_COLOR;
    }
    else {
        [self.actionButton setImage:[UIImage imageNamed:@"reminder_unselected"] forState:UIControlStateNormal];
        self.setNoLabel.textColor = DARK_TEXT_COLOR;
    }
}

- (IBAction)actionButtonPressed:(UIButton*) actionButton {
  
    self.isCompleted = !self.isCompleted;
    
    [self updateStrikeThrough];
    
    [self.setDelegate actionButtonSelectedForSelectedState:self.isCompleted forIndexPath:self.indexPath];
}

- (void) setSetNoText:(NSString*) setNoText isCompleted:(BOOL) isCompleted isOpened:(BOOL) isOpened forIndexPath:(NSIndexPath*) indexPath {
    self.text = setNoText;
    self.indexPath = indexPath;
    self.isCompleted = isCompleted;
    self.isOpened = isOpened;
    [self updateStrikeThrough];
}

@end
