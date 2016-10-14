//
//  ImageFloatingAnimationView.h
//  FloatingBubbleTest
//
//  Created by Abhijeet Mishra on 27/09/16.
//  Copyright © 2016 Abhijeet Mishra. All rights reserved.
//

#import "JRMFloatingAnimationView.h"

@protocol ImageFloatingAnimationViewProtocol <NSObject>



@end

@interface ImageFloatingAnimationView : JRMFloatingAnimationView

- (id)initWithStartingPoint:(CGPoint)startingPoint image:(UIImage*) image;

- (void) animateAfterDuration:(int) seconds;

@end
