//
//  ImageFloatingAnimationView.m
//  FloatingBubbleTest
//
//  Created by Abhijeet Mishra on 27/09/16.
//  Copyright © 2016 Abhijeet Mishra. All rights reserved.
//

#import "ImageFloatingAnimationView.h"

@interface ImageFloatingAnimationView ()

@property (nonatomic) UIImageView* imageView;

@end

@implementation ImageFloatingAnimationView

- (id)initWithStartingPoint:(CGPoint)startingPoint image:(UIImage*) image {
    if (self = [super initWithStartingPoint:startingPoint]) {
//        _imageView = [[UIImageView alloc] initWithImage:image];
//        _imageView.contentMode = UIViewContentModeScaleAspectFit;
//            [self addSubview:_imageView];
//        _imageView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    }
    return self;
}


- (void) animateAfterDuration:(int) seconds {
    [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(animate) userInfo:nil repeats:NO];
}
@end
