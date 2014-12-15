//
//  GameLayersProtocals.h
//  rock
//
//  Created by Ryan on 7/29/12.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"


#define BETA_TEST
extern BOOL TargetIsiPad;
extern float iPadScaleFactor;


@protocol gameoverlayProtocal <NSObject>
-(void)setlabelto:(int)thevalue;
-(void)resizelabel;
-(void)updateMinimap;
-(void)removelife;
-(void)pause;
-(void)unpause;

-(void)freezePlayer;
-(void)unFreezePlayer;


-(void)setjoysticktouch:(UITouch *)thetouch;
-(void)setjoystickpos:(CGPoint)thepoint;

@property (retain,nonatomic) CCMenu * menupause;
@property (retain,nonatomic) UITouch * joysticktouch;
@end





@protocol gamelayerProtocal <NSObject>
-(void)makebullet;
-(void)makerock;
-(void)makerocksfromrock:(CCSprite *)therock;
-(void)restartWithLevel:(int)level;
-(void)updateLevelvarOverlayPointer;
-(void)pause;
-(void)unpause;
-(void)nextLevel;
-(void)gameLostWithPoints:(int)score;
-(NSDictionary *)getLevelData;
-(void)makerockbody:(CCSprite *)rock;
-(CCSprite *)createrock;
-(void)randomizerock:(CCSprite *)therock;
-(void)updateFollowVar;
-(void)makerockaction:(CGPoint)moveby withrock:(CCSprite *)rock;
@property (nonatomic) BOOL userIsFiring;
@property (retain,nonatomic) CCSprite * player;
@property (retain,nonatomic) CCArray * rocks;
@property (nonatomic) CGPoint currjoystickpos;
@property (retain,nonatomic) UITouch * joysticktouch;
@property (retain,nonatomic) CCSpriteBatchNode * rockbatch;

@property (nonatomic) BOOL goToNextLevel;

//world
@property (nonatomic) int worldheight;
@property (nonatomic) int worldwidth;
@property (nonatomic) CGRect worldboundry;

//only power ups that need [-update] to be called are added here
@property (nonatomic) BOOL shouldUpdatePowerUps;
@property (retain,nonatomic) CCArray * powerUps;


@property (nonatomic) BOOL shieldActive;
@property (nonatomic) BOOL spikeyShieldActive;
@property (nonatomic) BOOL multiShotActive;


@end


// Determine if a point within the boundaries of the joystick.
static bool isPointInCircle(CGPoint point, CGPoint center, float radius) {
	float dx = (point.x - center.x);
	float dy = (point.y - center.y);
	return (radius >= sqrt( (dx * dx) + (dy * dy) ));
}


#define joystickpointx (394+(int)winSize.width-480)
#define joystickpointy 90
#define joystickpoint CGPointMake(joystickpointx,joystickpointy)
#define joystickcircleradius 57


#define kMinimapPosX (53*iPadScaleFactor)
#define kMinimapPosY (winSize.height-37*iPadScaleFactor)
#define kMinimapScaleFactor .1
#define kMinimapActualRatio .2
#define kMinimapwidth (48*2*iPadScaleFactor)
#define kMinimapheight (32*2*iPadScaleFactor)
#define kMinimapViewRadius (300*iPadScaleFactor)



#define kSurvivalworldheight (1000)
#define kSurvivalworldwidth (568*2)
#define kSurvivalworldboundry (CGRectMake(0, 0, kSurvivalworldwidth, kSurvivalworldheight))


#ifdef DEBUG_MODE

//comment for NO	
//#define spawntestrocks YES

#endif

#define drawdebugmode NO

#define ran() (arc4random() % 10000)/10000.0f
#define ran3to7() (.3+ran()*.7)

#define playerspeed 1.9
#define playerrotationspeed 4
#define tagplayer 1
#define klives 4

#define bulletspeed 4
#define tagbullet 2

#define rockspeed 2.34375
#define rockrotation 4
#define rockscaleformula (.25+.25*ran()) //doubled if retina
#define tagrock 4


#define tagfloatingpowerup 8

#define tagshieldpowerup 16



#define kRockCountAtStartOfInfinityLevel 21

#define gameModeSurvival 1
#define gameModeLevels 2