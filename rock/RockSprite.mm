//
//  RockSprite.m
//  rock
//
//  Created by Ryan on 7/29/12.
//  Copyright (c) 2014 Ryan Hughes. All rights reserved.
//

#import "RockSprite.h"

@implementation RockSprite
@synthesize health,size;


-(void)reset{
    size=rockscaleformula;
    
    self.scale=rockscaleformula*CC_CONTENT_SCALE_FACTOR();
    
    health=size*320-60;
}
@end
