//
//  RockSprite.h
//  rock
//
//  Created by Ryan on 7/29/12.
//  Copyright (c) 2014 Ryan Hughes. All rights reserved.
//

#import "CCSprite.h"
#import "GameLayersProtocals.h"

@interface RockSprite : CCSprite
    
-(void)reset;
@property (nonatomic) float health;
@property (nonatomic) float size;
@end
