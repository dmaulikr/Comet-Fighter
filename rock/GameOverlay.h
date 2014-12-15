//
//  GameOverlay.h
//  rock
//
//  Created by Ryan on 7/19/12.
//  Copyright (c) 2014 Ryan Hughes. All rights reserved.
//

#import "cocos2d.h"
#import "GameLayersProtocals.h"
#import "MenuItemPause.h"

@interface GameOverlay : CCLayerColor <gameoverlayProtocal> {
    
    CCLabelTTF * labelscore;
    CGSize winSize;
    
    CCArray * lives;
    CCSpriteBatchNode * livesbatch;

    //joystick
    CCSprite * joystick;
    UITouch * joysticktouch;
    
    BOOL isFiring;
    
    
    
    //main game
    __unsafe_unretained CCLayer <gamelayerProtocal> * gamelayervar;
    
    
    //minimap
    CCSpriteBatchNode * minimapbatch;
    
    CCSprite * minimapplayer;
    
    BOOL playerIsFrozen;
    
    
    //pause button
    CCMenu * menupause;
    CCSprite * btnpause;
    BOOL m_paused;
}
//init
-(void)actualInit;



//score
-(void)setlabelto:(int)thevalue;
-(void)resizelabel;

-(void)updatejoystick:(CGPoint)location;
-(void)setjoysticktouch:(UITouch *)thetouch;
-(void)setjoystickpos:(CGPoint)thepoint;
-(void) updateMinimap;
-(void)pauseButtonClicked;
-(void)pauseButtonClicked:(NSDictionary *)userinfo;

@property (nonatomic) CCLabelTTF *labelscore;
@property (nonatomic,unsafe_unretained) CCLayer <gamelayerProtocal> *   gamelayervar;
@property (retain,nonatomic) CCMenu * menupause;
@end
