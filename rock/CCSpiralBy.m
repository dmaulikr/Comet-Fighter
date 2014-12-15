//
//  CCSpiralBy.m
//  rock
//
//  Created by Ryan on 9/5/13.
//
//

#import "CCSpiralBy.h"
#define powerUpRotateAroundSpotRand (CCRANDOM_MINUS1_1()*10)
@implementation CCSpiralBy
-(id)init{
    self=[super initWithDuration:4 position:ccp(0,0)];
    if (self) {
        time=0;
        rotateAround=ccp(_startPos.x+powerUpRotateAroundSpotRand,_startPos.y+powerUpRotateAroundSpotRand);
        
    }
    return self;
}
-(void)update:(ccTime)deltatime{

    time+=deltatime;

    //spiral code
    CGPoint d=CGPointMake(CC_DEGREES_TO_RADIANS(cos(time*.01))*.02, CC_DEGREES_TO_RADIANS(sin(time*.01))*.02);
    
    [_target setPosition:CGPointMake(rotateAround.x+d.x, rotateAround.y+d.y)];
    dlog(@"adding %f,%f, time=%i",d.x,d.y,time);
    if (time>250) {
        //make new rotate around
    }
    
}
@end