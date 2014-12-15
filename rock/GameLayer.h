//
//  GameLayer.h
//  rock
//
//  Created by Ryan on 7/29/12.
//
//

#import "cocos2d.h"
#import "contactListener.h"
#import "GameLayersProtocals.h"
#import "RockSprite.h"
#import "RockLevel.h"



@interface GameLayer : CCLayerColor <gamelayerProtocal> {
    //player
    CCSprite * player;

    // Could move this to a Sprite subclass for player, if one is made
    BOOL playerIsInvincible;
    
    //bullets
    ccTime timeToNextFire;
    CCArray * bullets;
    CCSpriteBatchNode * bulletbatch;
    CCArray * bulletcache;
    BOOL userIsFiring;
    
    //rocks
    CCArray * rocks;
    CCSpriteBatchNode * rockbatch;
    CCArray * rockcache;
    
    thecontactlistener*contactvar;
    
    //This is needed for speed of objects
    //It loads in init and assumes it doesn't change (no portrait mode)
    CGSize winSize;

    
    __unsafe_unretained CCLayer <gameoverlayProtocal> *gameoverlayvar;
    
    
    CGPoint currjoystickpos;
    UITouch * joysticktouch;
    
    CCFollow * followvar;
    
    //pause
    BOOL m_paused;
    
    
    //level, lives, and score management
    RockLevel * levelvar;
    BOOL goToNextLevel;//set in levelvar to get out of the b2 callback
    
    
    //world
    int worldheight;
    int worldwidth;
    CGRect worldboundry;
    
    //Power Ups
    ccTime timeToNextSpikeHit;
    
    
}
//init
-(void) actualInitWithGameMode:(int)theGameMode;

//update
-(void)update:(ccTime)dt;
-(void)updateGame:(ccTime)dt;
-(void)updateplayer;

//make
-(void)makerock;
-(void)makerocksfromrock:(CCSprite *)therock;
-(void)makerockaction:(CGPoint)moveby withrock:(CCSprite *)rock;
-(void)makerockbody:(CCSprite *)rock;
-(RockSprite *)createrock;
-(void)randomizerock:(CCSprite *)therock;

-(void)makebullet;
-(void)makebulletwithAngle:(CGFloat)rotation;
-(void)makeplayer;
-(void)makeparticlesfrompoint:(CGPoint)thepoint withscale:(float)rockscale;

//contact
-(int)contactfound:(CCSprite *)s1 s2:(CCSprite *)s2;
-(int)contactIsAliveWithSprite:(CCSprite *)s1 andSprite:(CCSprite *)s2;
-(void)removesprite:(CCSprite *)sprite;
-(int)playerContact:(CCSprite *)s1 withRock:(CCSprite *)s2;

//level
-(void)endGame;

-(void)updateFollowVar;
@property (nonatomic,unsafe_unretained)  CCLayer <gameoverlayProtocal> * gameoverlayvar;
@property (nonatomic) BOOL userIsFiring;


@property (retain,nonatomic) CCSprite * player;
@property (retain,nonatomic) CCArray * rocks;
@property (nonatomic) CGPoint currjoystickpos;
@property (retain,nonatomic) UITouch * joysticktouch;
@property (retain,nonatomic) CCSpriteBatchNode * rockbatch;
@property (nonatomic) BOOL goToNextLevel;
@property (retain,nonatomic) thecontactlistener*contactvar;

@end
