#import "powerups.h"
#import "GameLayersProtocals.h"
#import "GameLayer.h"
#import "CCSpiralBy.h"



//prevent user from getting two of the same powerup
NSMutableDictionary * globalpowerups=[NSMutableDictionary dictionary];

#define randomfactor 100
id makePowerUpBiezer(void){
    
    //when the powerups spawns from a rock, randomly move around until it either times out, or the player touches it
    ccBezierConfig bezier;
    bezier.controlPoint_1 = ccp(CCRANDOM_MINUS1_1()*randomfactor, CCRANDOM_MINUS1_1()*randomfactor);
    bezier.controlPoint_2 = ccp(CCRANDOM_MINUS1_1()*randomfactor, CCRANDOM_MINUS1_1()*randomfactor);
    bezier.endPosition =    ccp(CCRANDOM_MINUS1_1()*randomfactor, CCRANDOM_MINUS1_1()*randomfactor);
    
    id bezierForward = [CCBezierBy actionWithDuration:6.4 bezier:bezier];
    
    
	//run these actions at the same time
    return [CCSpawn actions:
                      bezierForward,
                      [CCRotateBy actionWithDuration:0.0002 angle:ran()*rockrotation-rockrotation/2],
                      nil];
}




@implementation Powerup
@synthesize callupdate=callupdate_,gamelayer=gamelayer_;


#pragma mark -
#pragma mark floating init

+(void)addtogamelayer:(CCLayer <gamelayerProtocal> *)gamelayer atPos:(CGPoint)pos{

	Powerup * powerup=[self sprite];

	powerup.gamelayer=gamelayer;
	powerup.callupdate=NO;


	if (CC_CONTENT_SCALE_FACTOR()==1) {
        powerup.scale=.25;
    }
    else {
        powerup.scale=.5;
    }


	powerup.tag=tagfloatingpowerup;
    powerup.position=pos;



    //same blink as the player death blink
    CCFiniteTimeAction * blinkaction=
    [CCRepeat actionWithAction:
        [CCSequence actions:
            [CCShow action],
            [CCDelayTime actionWithDuration:.4],
            [CCHide action],
            [CCDelayTime actionWithDuration:.2],
            nil]
        times:4];
    

    //float around for 4 seconds, and then blink, and then the power up disappears   
     id action=
     [CCSequence actions:
        [CCSpawn actionOne:makePowerUpBiezer() two:[CCSequence actionOne:[CCDelayTime actionWithDuration:4] two:blinkaction]],
        [CCCallBlock actionWithBlock:^{

            //cleanup
            [((GameLayer *) gamelayer).contactvar removesprite:powerup];
             [powerup removeFromParentAndCleanup:YES];
            }],

        nil];
    
     [powerup runAction:action];


    //create the b2 body
    float PTM_RATIO;
    if (CC_CONTENT_SCALE_FACTOR()==1) {
        PTM_RATIO=(1.0f/powerup.scale);
    }
    else {
        PTM_RATIO=(1.0f/powerup.scale)*2;
    }

    
    int num = 41;
    b2Vec2 verts[] = {
        b2Vec2(6.0f / PTM_RATIO, -70.0f / PTM_RATIO),
        b2Vec2(18.0f / PTM_RATIO, -68.0f / PTM_RATIO),
        b2Vec2(27.0f / PTM_RATIO, -65.0f / PTM_RATIO),
        b2Vec2(38.0f / PTM_RATIO, -59.0f / PTM_RATIO),
        b2Vec2(47.0f / PTM_RATIO, -52.0f / PTM_RATIO),
        b2Vec2(51.0f / PTM_RATIO, -48.0f / PTM_RATIO),
        b2Vec2(56.0f / PTM_RATIO, -42.0f / PTM_RATIO),
        b2Vec2(60.0f / PTM_RATIO, -36.0f / PTM_RATIO),
        b2Vec2(64.0f / PTM_RATIO, -28.0f / PTM_RATIO),
        b2Vec2(67.0f / PTM_RATIO, -20.0f / PTM_RATIO),
        b2Vec2(69.0f / PTM_RATIO, -9.0f / PTM_RATIO),
        b2Vec2(69.0f / PTM_RATIO, 9.0f / PTM_RATIO),
        b2Vec2(67.0f / PTM_RATIO, 19.0f / PTM_RATIO),
        b2Vec2(66.0f / PTM_RATIO, 22.0f / PTM_RATIO),
        b2Vec2(60.0f / PTM_RATIO, 35.0f / PTM_RATIO),
        b2Vec2(54.0f / PTM_RATIO, 44.0f / PTM_RATIO),
        b2Vec2(45.0f / PTM_RATIO, 53.0f / PTM_RATIO),
        b2Vec2(35.0f / PTM_RATIO, 60.0f / PTM_RATIO),
        b2Vec2(27.0f / PTM_RATIO, 64.0f / PTM_RATIO),
        b2Vec2(19.0f / PTM_RATIO, 67.0f / PTM_RATIO),
        b2Vec2(7.0f / PTM_RATIO, 69.0f / PTM_RATIO),
        b2Vec2(-8.0f / PTM_RATIO, 69.0f / PTM_RATIO),
        b2Vec2(-19.0f / PTM_RATIO, 67.0f / PTM_RATIO),
        b2Vec2(-28.0f / PTM_RATIO, 64.0f / PTM_RATIO),
        b2Vec2(-39.0f / PTM_RATIO, 58.0f / PTM_RATIO),
        b2Vec2(-48.0f / PTM_RATIO, 51.0f / PTM_RATIO),
        b2Vec2(-52.0f / PTM_RATIO, 47.0f / PTM_RATIO),
        b2Vec2(-61.0f / PTM_RATIO, 35.0f / PTM_RATIO),
        b2Vec2(-65.0f / PTM_RATIO, 27.0f / PTM_RATIO),
        b2Vec2(-68.0f / PTM_RATIO, 19.0f / PTM_RATIO),
        b2Vec2(-70.0f / PTM_RATIO, 7.0f / PTM_RATIO),
        b2Vec2(-70.0f / PTM_RATIO, -8.0f / PTM_RATIO),
        b2Vec2(-68.0f / PTM_RATIO, -19.0f / PTM_RATIO),
        b2Vec2(-65.0f / PTM_RATIO, -28.0f / PTM_RATIO),
        b2Vec2(-59.0f / PTM_RATIO, -39.0f / PTM_RATIO),
        b2Vec2(-51.0f / PTM_RATIO, -49.0f / PTM_RATIO),
        b2Vec2(-49.0f / PTM_RATIO, -51.0f / PTM_RATIO),
        b2Vec2(-39.0f / PTM_RATIO, -59.0f / PTM_RATIO),
        b2Vec2(-27.0f / PTM_RATIO, -65.0f / PTM_RATIO),
        b2Vec2(-19.0f / PTM_RATIO, -68.0f / PTM_RATIO),
        b2Vec2(-7.0f / PTM_RATIO, -70.0f / PTM_RATIO)
    };


    [((GameLayer *) gamelayer).contactvar addSprite:powerup withVertexs:verts vertexCount:num];

	[gamelayer addChild:powerup];
    
    
    
    
}

#pragma mark -
#pragma mark power init
-(BOOL)shouldPowerUpDieOnPlayerContact{
    return YES;
}



-(void)playerContact{
    
    
    //player already has power up of this type
    Powerup * prevpowerup=[globalpowerups objectForKey:[self class]];

    //if the player already has this powerup, reset the timers on the power up
    if (prevpowerup!=nil) {
        dlog(@"player already has a %@",[self class]);
        
        //re schedule end
        [prevpowerup stopAllActions];
        
        prevpowerup.visible=YES;
        [NSObject cancelPreviousPerformRequestsWithTarget:prevpowerup];
        [prevpowerup schedulePowerEnd];
        
        //delete self
        [self removeFromParentAndCleanup:YES];
        return;
        
    }
    //stop spin and move
	[self stopAllActions];
    
    
    
    
    //if the sprite should be removed from the game
    if ([self activatePowerup]) {

        //remove floating sprite (note that its not being dealloc until powerup power is over)
        self.visible=NO;
        [self removeFromParentAndCleanup:NO];
    }
    
    //schedule end - shield powerups will override this
    [self schedulePowerEnd];
    
    
    
    
    [globalpowerups setObject:self forKey:[self class]];
    dlog(@"added power up %@ to global power ups(%@)",self,globalpowerups);
    

}
-(void)schedulePowerEnd{
    [self performSelector:@selector(powerupEnded) withObject:nil afterDelay:7];
}

#pragma mark -
#pragma mark shield only

-(void)blinkAndEndPowerup{
    [self runAction:[CCSequence actionOne:[CCBlink actionWithDuration:2 blinks:3] two:[CCCallFunc actionWithTarget:self selector:@selector(powerupEnded)]]];
}
-(void)activateShieldPowerup{
    float duration = .25;
    
    //move the shield onto the player, and then follow the player
    //TODO: currently, the power up moves to the position of the player when he got the power up, and does not update if the player moves
	id moveAction = [CCMoveTo actionWithDuration:duration position:gamelayer_.player.position];
	id scaleAction = [CCScaleBy actionWithDuration:duration scale:1.75];
    
	id followPlayerAction =[CCCallBlock actionWithBlock:^{
		dlog(@"shield power up is now following player");
		
        self.callupdate=YES;
        gamelayer_.shouldUpdatePowerUps=YES;
        [gamelayer_.powerUps addObject:self];
        
	}];
    
	[self runAction:[CCSequence actions:[CCSpawn actions:moveAction,scaleAction,nil],followPlayerAction,nil]];
    
    
    self.tag=tagshieldpowerup;
    
    
}
#pragma mark -
#pragma mark power end

-(void)powerupEnded{


    dlog(@"%i removing powerup %@ from gamelayer powerups %@ :%i",callupdate_,self,gamelayer_.powerUps,[gamelayer_.powerUps containsObject:self]);
    [globalpowerups removeObjectForKey:[self class]];

    //if callupdate_ was ON, powerup is in gamelayer array
    if (callupdate_)
    {
        [gamelayer_.powerUps removeObject:self];
        if (gamelayer_.powerUps.count==0)
        {
            gamelayer_.shouldUpdatePowerUps=NO;
        }
    }
    [self removeFromParentAndCleanup:YES];


}
-(void)dealloc{
    dlog(@"power up %@ was dealloc",self);
}
#pragma mark -
#pragma mark to-be subclassed stuff

//None of these functions should be called
-(BOOL)activatePowerup{
    elog(@"default activate powerup called %@",[self class]);
    return YES;
}
+(Powerup *)sprite{
	elog(@"to be subclassed powerup sprite called %@",self);
	return nil;
}
-(void)update{
    elog(@"powerup update was called!(%@)",self);
}
@end


#pragma mark -
#pragma mark actual powerups

@implementation PowerupShield
+(Powerup *)sprite{
	return [self spriteWithFile:@"PowerupShield.png"];
}
-(BOOL)activatePowerup{
    
	[self activateShieldPowerup];
    
    //activate shield
    gamelayer_.shieldActive=YES;
    
    return NO;
}



-(void)update{
	self.position=gamelayer_.player.position;

}
-(void)schedulePowerEnd{
    [self performSelector:@selector(blinkAndEndPowerup) withObject:nil afterDelay:5];
}
-(void)powerupEnded{
    [super powerupEnded];
    gamelayer_.shieldActive=NO;
}
@end




@implementation PowerupSpikeyShield
+(Powerup *)sprite{
	return [self spriteWithFile:@"PowerupSpikeyShield.png"];
}
-(BOOL)activatePowerup{
    
    [self activateShieldPowerup];
    
    //activate shield
    gamelayer_.spikeyShieldActive=YES;
    return NO;
}
-(void)update{
	self.position=gamelayer_.player.position;
    self.rotation=gamelayer_.player.rotation;
}
-(void)schedulePowerEnd{
    [self performSelector:@selector(blinkAndEndPowerup) withObject:nil afterDelay:3];
}
-(void)powerupEnded{
    [super powerupEnded];
    gamelayer_.spikeyShieldActive=NO;
}
@end

@implementation PowerupMultishot
+(Powerup *)sprite{
	return [self spriteWithFile:@"PowerupMultishot.png"];
}
-(BOOL)activatePowerup{
    gamelayer_.multiShotActive=YES;
    return YES;
}
-(void)powerupEnded{
    [super powerupEnded];
    gamelayer_.multiShotActive=NO;
}
@end

#pragma mark -
#pragma mark not done


@implementation PowerupFastfire
+(Powerup *)sprite{
	return [self spriteWithFile:@"PowerupFastfire.png"];
}
@end

@implementation PowerupLaser
+(Powerup *)sprite{
	return [self spriteWithFile:@"PowerupLaser.png"];
}
@end

@implementation PowerupSpeed
+(Powerup *)sprite{
	return [self spriteWithFile:@"PowerupSpeed.png"];
}
@end
