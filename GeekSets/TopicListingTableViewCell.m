//
//  TopicListingTableViewCell.m
//  AmozonPracticeApp
//
//  Created by Abhijeet Mishra on 30/09/16.
//  Copyright © 2016 Abhijeet Mishra. All rights reserved.
//

#import "TopicListingTableViewCell.h"

@interface TopicListingTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *topicLabel;

@end

@implementation TopicListingTableViewCell

- (void) setTopic:(NSString*) topic {
    self.topicLabel.text = topic;
}
@end
