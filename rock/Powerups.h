#import "cocos2d.h"
#import "GameLayersProtocals.h"
@interface Powerup : CCSprite{
	//these have to be here and can't be made from the @synthesize properties to be accessed in the subclasses
    __unsafe_unretained CCLayer <gamelayerProtocal> * gamelayer_;
    BOOL callupdate_;
	
}

//should not be called directly
+(Powerup *)sprite;

//main method that is called when a power up is created. This calls [self sprite],
//configures the powerup, and adds it to gamelayer
+(void)addtogamelayer:(CCLayer <gamelayerProtocal> *)gamelayer atPos:(CGPoint)pos;


//called by the box2d contact detector, returns if sprite should be removed (but does not remove the sprite)
//override for shields, which should not be removed on contact
-(BOOL)shouldPowerUpDieOnPlayerContact;

//this must be implemented in each subclass
//this is called when the collision is detected, and could be called twice in one frame
-(void)playerContact;


-(void)update;
-(void)powerupEnded;

//returns whether the powerup should be removed
//Eg multi shot sprite does not need to stay, but the shield sprite does
-(BOOL)activatePowerup;

-(void)schedulePowerEnd;
@property (nonatomic) BOOL callupdate;
@property (unsafe_unretained,nonatomic) CCLayer <gamelayerProtocal> * gamelayer;

@end


//Current power ups
@interface PowerupShield : Powerup

@end

@interface PowerupSpikeyShield : Powerup

@end

@interface PowerupMultishot : Powerup

@end



//Ideas for future power ups
@interface PowerupFastfire : Powerup

@end

@interface PowerupLaser : Powerup

@end

@interface PowerupSpeed : Powerup

@end

