//
//  LevelUI.m
//  rock
//
//  Created by Ryan on 10/13/12.
//
//

#import "GameIntroOverlay.h"
#import "GameLayersProtocals.h"

@implementation GameInfoOverlay
@synthesize runOnExit;
-(id)initWithTitle:(NSString *)thetitle subtitle:(NSString *)thesubtitle{
    self = [super init];
    if (self) {
        
    
        winSize=[[CCDirector sharedDirector] winSize];
        
        
        // title label
		CCLabelTTF * titlelabel = [CCLabelTTF labelWithString:thetitle fontName:@"Marker Felt" fontSize:36];
        titlelabel.position=CGPointMake(winSize.width/2, winSize.height-30);
        [self addChild:titlelabel];
        
        //subtitle
        CCLabelTTF * subtitlelabel = [CCLabelTTF labelWithString:thesubtitle fontName:@"Marker Felt" fontSize:26];
        subtitlelabel.position=CGPointMake(winSize.width/2, winSize.height-60);
        [self addChild:subtitlelabel];
        
        
        CCLabelTTF * continuelabel = [CCLabelTTF labelWithString:@"Click to Continue" fontName:@"Marker Felt" fontSize:18];
        continuelabel.position=CGPointMake(winSize.width/2, 20);
        [self addChild:continuelabel];
        
        
        self.touchEnabled=YES;
        self.opacity=100;
        
        CGPoint d[]={CGPointMake(0, 0),CGPointMake(winSize.width, 0),CGPointMake(winSize.width, winSize.height),CGPointMake(0, winSize.height)};
        ccDrawSolidPoly(d, 4, ccc4f(0, 0, 0, self.opacity/255.0f));
        
    }
    return self;
}

-(void)draw{
    [super draw];
    CGPoint d[]={CGPointMake(0, 0),CGPointMake(winSize.width, 0),CGPointMake(winSize.width, winSize.height),CGPointMake(0, winSize.height)};
    ccDrawSolidPoly(d, 4, ccc4f(0, 0, 0, self.opacity/255.0f));
}
-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    self.touchEnabled=NO;
    runOnExit();
    runOnExit=nil;
    [self removeFromParentAndCleanup:YES];
    
}
-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    [self ccTouchesBegan:[NSSet setWithObject:touch] withEvent:event];
    return YES;
}

-(id)init{
    elog(@"gameintro overlay init should not be called!");
    return nil;
}
@end






@implementation helpOverlay

-(id)initWithTitle:(NSString *)thetitle subtitle:(NSString *)thesubtitle{
    self=[super initWithTitle:thetitle subtitle:thesubtitle];
    if (self) {
        // joystick label
		CCLabelTTF * label = [CCLabelTTF labelWithString:@"Joystick\nMove & Aim" fontName:@"Marker Felt" fontSize:18];
        label.position=CGPointMake(joystickpointx, (TargetIsiPad?joystickpointy*2+10:winSize.height/2));
        [self addChild:label];
        
        
        // fire label
		CCLabelTTF * goallabel = [CCLabelTTF labelWithString:@"Tap anywhere\nto toggle firing\n\nDon't tap repetitively!" fontName:@"Marker Felt" fontSize:18];
        goallabel.position=CGPointMake(winSize.width/4, 100*iPadScaleFactor);
        [self addChild:goallabel];
        
    }
    return self;
}


@end






@implementation levelIntroOverlay

-(id)initWithTitle:(NSString *)thetitle subtitle:(NSString *)thesubtitle{
    self=[super initWithTitle:thetitle subtitle:thesubtitle];
    if (self) {
        dlog(@"%@",thesubtitle);
        
        
    }
    return self;
    
}

@end

