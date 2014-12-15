//
//  GameLayer.m
//  rock
//
//  Created by Ryan on 7/29/12.
//
//


#import <math.h>

#import "GameLayer.h"
#import "MenuLayer.h"
#import "deathscene.h"
#import "GameIntroOverlay.h"
#import "powerups.h"


@implementation GameLayer
@synthesize gameoverlayvar,currjoystickpos,joysticktouch,player,rocks,rockbatch,userIsFiring,goToNextLevel,worldboundry,worldheight,worldwidth,shouldUpdatePowerUps,powerUps,shieldActive,contactvar,spikeyShieldActive,multiShotActive;
#pragma mark -
#pragma mark custom methods
-(void)restartWithLevel:(int)level{
    
    
    //undo changes made in become background
    int gamemode=levelvar.gamemode;
    int score= levelvar.score;
    int lives=levelvar.lives;
    dlog(@"in restart level gamemode=%i",gamemode);
    

    //When all of the rocks in the list below are removed, don't count that as kills for player
    //So set levelvar=nil; (so in [self removesprite] the kill is not counted)
    levelvar=nil;
    
    
    //if called from deathscene this will run
    //will not run if called from next level
    if (player==nil) {
        [self makeplayer];
        playerIsInvincible=NO;
        score=0;
        
        
        followvar=[CCFollow actionWithTarget:player worldBoundary:worldboundry];
        [self runAction:followvar ];
        [self unscheduleAllSelectors];
        [self scheduleUpdate];
    }
    
    
    
    //rocks
    dlog(@"THERE are %i rocks (%i)",rocks.count,rockcache.count);
    
    //move all rocks to rockcache so levelvar can use them    
    for (int i=rocks.count-1; i>=0; i--) {
        [contactvar removesprite:[rocks objectAtIndex:i]];
        [self removesprite:[rocks objectAtIndex:i]];
    }

    dlog(@"there are now %i rocks, to  %i",rocks.count,rockcache.count);
    
    
    //level var is set to nil above,level var will also recreate rocks
    levelvar=[RockLevelGenerator levelWithDelegate:self Overlay:gameoverlayvar Number:level gameMode:gamemode score:score];
    if (lives!=0) {
        levelvar.lives=lives;
    }
    
}
-(void)dealloc{
    dealloclog(@"gamelayer dealloc was called!");
}


//world size changed, move player to middle of world if not in world and update followvar
-(void)updateFollowVar{
    
    if (!CGRectContainsPoint(worldboundry, player.position)){
        player.position=CGPointMake(worldwidth/2, worldheight/2);
    }
    
    
    followvar=nil;
    followvar=[CCFollow actionWithTarget:player worldBoundary:worldboundry];
    [self runAction:followvar ];
    [self unscheduleAllSelectors];
    [self scheduleUpdate];
}

#pragma mark -
#pragma mark level mgr

-(void)nextLevel{
    [self pause];
    gameoverlayvar.menupause.touchEnabled=NO;
    gameoverlayvar.joysticktouch=nil;
    [self restartWithLevel:levelvar.levelnumber+1];
    goToNextLevel=NO;
    
    
    NSDictionary * dict=[levelvar getLevelData];
    levelIntroOverlay * levelIntroOverlayvar=[[levelIntroOverlay alloc] initWithTitle:[@"Campaign:" stringByAppendingString:[dict objectForKey:@"title"]] subtitle:[dict objectForKey:@"subtitle"]];
    
    levelIntroOverlayvar.runOnExit=^(void){
        
        //init
        [self unpause];
        gameoverlayvar.menupause.touchEnabled=YES;
    };
    
    
    
    [self.parent addChild:levelIntroOverlayvar z:2];
    
    
}
-(void)gameLostWithPoints:(int)score{
    

    // this function is called from the b2collision traceback so there will be a crash if sprites are removed
    //[contactvar removesprite:player];


    [self endGame];
    
    //send score to gamecenter
    GKScore *scoreReporter = [[GKScore alloc] initWithCategory:@"com.ryanhugh.rock1"];
	scoreReporter.value = score;
	[scoreReporter reportScoreWithCompletionHandler: ^(NSError *error)
	 {
         if (error) {
             dlog(@"score not reported %@",error);
             return;
         }
		 dlog(@"score reported!");
	 }];
    
    
    
    [[CCDirector sharedDirector] replaceScene:[deathlayer sceneWithGameLayer:self Score:score didWin:NO nextlevel:1]];
    gameoverlayvar=nil;
    levelvar.gameOverlay=nil;
}

-(void)endGame{

    ////self
    //become background
    [self removeFromParentAndCleanup:NO];
    
    //change timer to 20fps and only update game not gameoverlay
    [self unscheduleAllSelectors];
    [self schedule:@selector(updateGame:) interval:1.f/20.f];
    

    ////player
    //player b2 body is removed in removesprite function
    [player removeFromParentAndCleanup:YES];
    player=nil;
    
    //stop shooting bullets
    userIsFiring=NO;
    
    
    [self stopAction:followvar];
    followvar=nil;
    
    
}
-(NSDictionary *)getLevelData{
    return [levelvar getLevelData];
}
-(void)updateLevelvarOverlayPointer{
    levelvar.gameOverlay=gameoverlayvar;
}
#pragma mark -
#pragma mark pause
- (void) onEnter
{
    if(!m_paused)
    {
        [super onEnter];
    }
}
- (void) onExit
{
    if(!m_paused)
    {
        [super onExit];
    }
}

- (void) pause
{
    if(m_paused)
    {
        return;
    }
    
    [self onExit];
    m_paused = YES;
}

- (void) unpause
{
    if(!m_paused)
    {
        return;
    }
    
    m_paused = NO;
    [self onEnter];
}
#pragma mark -
#pragma mark rock helpers
-(RockSprite *)createrock{
    
    //rock
    RockSprite * rock;
    if (rockcache.count==0) {
        rock=[RockSprite spriteWithFile:@"rock.png"];
        [rockbatch addChild:rock];

    }
    else
    {

        rock=[rockcache lastObject];
        [rockcache removeLastObject];
        rock.visible=YES;
    }
    
    
    rock.rotation=360*ran();
    rock.tag=tagrock;
    return rock;
}

-(void)makerockbody:(CCSprite *)rock{
    
    float PTM_RATIO=(1.0f/rock.scale);
    
    PTM_RATIO*=CC_CONTENT_SCALE_FACTOR();
    
    int num = 18;
    b2Vec2 verts[] = {
        b2Vec2(-7.0f / PTM_RATIO, -109.5f / PTM_RATIO),
        b2Vec2(58.0f / PTM_RATIO, -96.5f / PTM_RATIO),
        b2Vec2(61.0f / PTM_RATIO, -93.5f / PTM_RATIO),
        b2Vec2(91.0f / PTM_RATIO, -35.5f / PTM_RATIO),
        b2Vec2(91.0f / PTM_RATIO, 35.5f / PTM_RATIO),
        b2Vec2(55.0f / PTM_RATIO, 92.5f / PTM_RATIO),
        b2Vec2(52.0f / PTM_RATIO, 95.5f / PTM_RATIO),
        b2Vec2(49.0f / PTM_RATIO, 96.5f / PTM_RATIO),
        b2Vec2(-11.0f / PTM_RATIO, 106.5f / PTM_RATIO),
        b2Vec2(-19.0f / PTM_RATIO, 106.5f / PTM_RATIO),
        b2Vec2(-21.0f / PTM_RATIO, 105.5f / PTM_RATIO),
        b2Vec2(-71.0f / PTM_RATIO, 67.5f / PTM_RATIO),
        b2Vec2(-75.0f / PTM_RATIO, 63.5f / PTM_RATIO),
        b2Vec2(-92.0f / PTM_RATIO, -3.5f / PTM_RATIO),
        b2Vec2(-92.0f / PTM_RATIO, -5.5f / PTM_RATIO),
        b2Vec2(-68.0f / PTM_RATIO, -70.5f / PTM_RATIO),
        b2Vec2(-67.0f / PTM_RATIO, -71.5f / PTM_RATIO),
        b2Vec2(-11.0f / PTM_RATIO, -109.5f / PTM_RATIO)
    };
    
    [contactvar addSprite:rock withVertexs:verts vertexCount:num];
    
}
-(void)makerockaction:(CGPoint)moveby withrock:(CCSprite *)rock{
    
#ifdef spawntestrocks
    id bothactions=[CCSpawn actions:
                    [CCMoveBy actionWithDuration:1.0f/60.0f position:moveby],
                    [CCRotateBy actionWithDuration:1.0f/60.0f angle:ran()*rockrotation-rockrotation/2],
                    nil];
#elif defined spawntestrocksangled
    id bothactions=[CCSpawn actions:
                    [CCMoveBy actionWithDuration:0.0002 position:moveby],
                    [CCRotateBy actionWithDuration:0.0002 angle:ran()*rockrotation-rockrotation/2],
                    nil];
#else
    id bothactions=[CCSpawn actions://at the same time
                    [CCMoveBy actionWithDuration:0.0002 position:moveby],
                    [CCRotateBy actionWithDuration:0.0002 angle:ran()*rockrotation-rockrotation/2],
                    nil];
#endif
    [rock runAction:[CCRepeatForever actionWithAction:bothactions]];
    
}

//Randomize movement direction and speed, and the spawn location
-(void)randomizerock:(CCSprite *)therock{
    CGPoint moveby;
    CGPoint center;
    int wall=arc4random()%4;
    
#ifdef spawntestrocks
    wall=0;
#endif
    
    switch (wall) {

        //left
        case 0:
            moveby=CGPointMake(ran3to7()*rockspeed/2, ran()*rockspeed-rockspeed/2);
            
            center=CGPointMake(-therock.boundingBox.size.width/2+1, arc4random()%(int)worldheight);
            break;
            
        //right
        case 2:
            moveby=CGPointMake(-(ran3to7()*rockspeed/2), ran()*rockspeed-rockspeed/2);
            
            center=CGPointMake((worldwidth+therock.boundingBox.size.width/2)-1, arc4random()%(int)worldheight);
            break;
            
        //top
        case 1:
            moveby=CGPointMake(ran()*rockspeed-rockspeed/2, -(ran3to7()*rockspeed/2));
            
            center=CGPointMake(arc4random()%(int)worldwidth, (worldheight+therock.boundingBox.size.height/2)-1);
            break;
            
        //bottom
        case 3:
            moveby=CGPointMake(ran()*rockspeed-rockspeed/2, ran3to7()*rockspeed/2);
            
            center=CGPointMake(arc4random()%(int)worldwidth, (-therock.boundingBox.size.height/2)+1);
            break;
            
        default:
            elog(@"ERROR: arc4random()%%4 returned %i",wall);
            break;
    }
    
    therock.position=center;
#ifdef spawntestrocks
    therock.position=ccp(player.position.x-200,player.position.y);
#endif
    [self makerockaction:moveby withrock:therock];
    
    
}
#pragma mark -
#pragma mark make stuff
-(void)makerocksfromrock:(CCSprite *)therock{
    float rockscale=therock.scale;
    
    rockscale/=CC_CONTENT_SCALE_FACTOR();
    
    
    //The number of new rocks is based off the size of the destroyed rock
    int rockstomake=((int)((rockscale*4-1)*4));
    
    if (rockstomake>0) {
        rockstomake++;
    }
    
    for (int i=0; i<rockstomake; i++) {
        
        
        float angle=((float)i/(float)rockstomake)*360;
        
        angle+=(CCRANDOM_MINUS1_1()*50);
        
        angle=CC_DEGREES_TO_RADIANS(angle);
        
        
        // Create the rock
        RockSprite * rock=[self createrock];
#ifdef BETA_TEST
        float newsize=rockscale/rockstomake;
        rock.size=rock.scale=newsize+(newsize*.5*CCRANDOM_MINUS1_1());
#else
        
        rock.size=rock.scale=rockscale/rockstomake;
#endif
        
        
        rock.health=rock.size*320-60;
        
        rock.scale*=CC_CONTENT_SCALE_FACTOR();
        
      
        rock.position=therock.position;
        [self makerockaction:CGPointMake(cos(angle), sin(angle)) withrock:rock];
        
        [self makerockbody:rock];
        
        [rocks addObject:rock];
    }
}
-(void)makerock{
    RockSprite * rock=[self createrock];    
    
    //Size, scale and health
    [rock reset];

    //Movement and spawn location
    [self randomizerock:rock];
    
    //box2d body
    [self makerockbody:rock];
    
    [rocks addObject:rock];
}
-(void)makebullet{
    [self makebulletwithAngle:player.rotation];
    
    if (multiShotActive) {
        [self makebulletwithAngle:player.rotation+10];
        [self makebulletwithAngle:player.rotation-10];
        
    }
}
-(void)makebulletwithAngle:(CGFloat)rotation{
    
    //Fire every 1/3 seconds
    timeToNextFire=1/3.0;
    
    
    float newdeg=CC_DEGREES_TO_RADIANS(rotation);
    float angy=cos(newdeg);
    float angx=sin(newdeg);
    
    
    float bulletscale=CC_CONTENT_SCALE_FACTOR()/2;
    
    
    
    //get bullet
    CCSprite * bullet;
    if (bulletcache.count==0) {
        bullet=[CCSprite spriteWithFile:@"bullet.png"];
        bullet.scale=bulletscale;
        dlog(@"made bullet");
        [bulletbatch addChild:bullet];
    }
    else
    {
        bullet=[bulletcache lastObject];
        bullet.visible=YES;
        
        [bulletcache removeLastObject];
        if (bullet.scale!=bulletscale) {
            bullet.scale=bulletscale;
        }
    }
    
    
    
    bullet.position=player.position;
    
    bullet.tag=tagbullet;
    
    //add it
    float PTM_RATIO=(1.0f/bullet.scale)*CC_CONTENT_SCALE_FACTOR();
    
    
    int num = 16;
    b2Vec2 verts[] = {
        b2Vec2(2.5f / PTM_RATIO, -10.5f / PTM_RATIO),
        b2Vec2(5.5f / PTM_RATIO, -9.5f / PTM_RATIO),
        b2Vec2(8.5f / PTM_RATIO, -6.5f / PTM_RATIO),
        b2Vec2(9.5f / PTM_RATIO, -3.5f / PTM_RATIO),
        b2Vec2(9.5f / PTM_RATIO, 2.5f / PTM_RATIO),
        b2Vec2(8.5f / PTM_RATIO, 4.5f / PTM_RATIO),
        b2Vec2(4.5f / PTM_RATIO, 8.5f / PTM_RATIO),
        b2Vec2(2.5f / PTM_RATIO, 9.5f / PTM_RATIO),
        b2Vec2(-2.5f / PTM_RATIO, 9.5f / PTM_RATIO),
        b2Vec2(-5.5f / PTM_RATIO, 8.5f / PTM_RATIO),
        b2Vec2(-9.5f / PTM_RATIO, 4.5f / PTM_RATIO),
        b2Vec2(-10.5f / PTM_RATIO, 1.5f / PTM_RATIO),
        b2Vec2(-10.5f / PTM_RATIO, -3.5f / PTM_RATIO),
        b2Vec2(-9.5f / PTM_RATIO, -5.5f / PTM_RATIO),
        b2Vec2(-5.5f / PTM_RATIO, -9.5f / PTM_RATIO),
        b2Vec2(-3.5f / PTM_RATIO, -10.5f / PTM_RATIO)
    };
    
    
    
    [contactvar addSprite:bullet withVertexs:verts vertexCount:num];
    [bullets addObject:bullet];
    
    id action=[CCSequence actions:[CCRepeat actionWithAction:[CCMoveBy actionWithDuration:1.f/60.f position:CGPointMake(angx*bulletspeed, angy*bulletspeed)] times:80],[CCCallBlock actionWithBlock:^{
        
        //cleanup
        [contactvar removesprite:bullet];
        
        
        [bulletcache addObject:bullet];
        [bullets fastRemoveObject:bullet];
        bullet.visible=NO;
        [bullet cleanup];
        
        dlog(@"added bullet %p to cache in max distance",bullet);
        
        
    }], nil];
    [bullet runAction:action];
    
}
-(void)makeplayer{


    //player
    player=[CCSprite spriteWithFile:@"player.png"];
    
    player.scale=.25*CC_CONTENT_SCALE_FACTOR();
    
    
    player.position = CGPointMake(winSize.width/2, winSize.height/2);
    player.tag=tagplayer;
    float PTM_RATIO=(1.0f/player.scale)*CC_CONTENT_SCALE_FACTOR();
    
   
    //Box2D body for player
    int num = 21;
    b2Vec2 verts[] = {
        b2Vec2(-56.0f / PTM_RATIO, -85.0f / PTM_RATIO),
        b2Vec2(-36.0f / PTM_RATIO, -32.0f / PTM_RATIO),
        b2Vec2(33.0f / PTM_RATIO, -30.0f / PTM_RATIO),
        b2Vec2(53.0f / PTM_RATIO, -85.0f / PTM_RATIO),
        b2Vec2(61.0f / PTM_RATIO, -88.0f / PTM_RATIO),
        b2Vec2(63.0f / PTM_RATIO, -86.0f / PTM_RATIO),
        b2Vec2(64.0f / PTM_RATIO, -84.0f / PTM_RATIO),
        b2Vec2(64.0f / PTM_RATIO, -82.0f / PTM_RATIO),
        b2Vec2(63.0f / PTM_RATIO, -77.0f / PTM_RATIO),
        b2Vec2(7.0f / PTM_RATIO, 77.0f / PTM_RATIO),
        b2Vec2(2.0f / PTM_RATIO, 86.0f / PTM_RATIO),
        b2Vec2(0.0f / PTM_RATIO, 87.0f / PTM_RATIO),
        b2Vec2(-1.0f / PTM_RATIO, 87.0f / PTM_RATIO),
        b2Vec2(-3.0f / PTM_RATIO, 86.0f / PTM_RATIO),
        b2Vec2(-6.0f / PTM_RATIO, 83.0f / PTM_RATIO),
        b2Vec2(-9.0f / PTM_RATIO, 77.0f / PTM_RATIO),
        b2Vec2(-65.0f / PTM_RATIO, -78.0f / PTM_RATIO),
        b2Vec2(-65.0f / PTM_RATIO, -82.0f / PTM_RATIO),
        b2Vec2(-64.0f / PTM_RATIO, -84.0f / PTM_RATIO),
        b2Vec2(-62.0f / PTM_RATIO, -86.0f / PTM_RATIO),
        b2Vec2(59.0f / PTM_RATIO, -88.0f / PTM_RATIO)
    };
    
    [contactvar addSprite:player withVertexs:verts vertexCount:num];
    [self addChild:player];
}
-(void)makeparticlesfrompoint:(CGPoint)thepoint withscale:(float)rockscale{
    
    CCParticleSystemQuad * emitter = [[CCParticleSystemQuad alloc] initWithTotalParticles:7];
    emitter.texture = [[CCTextureCache sharedTextureCache] addImage: @"bullet.png"];
    
    // duration
    emitter.duration = 0;
    
    // gravity
    emitter.gravity = CGPointZero;
    
    // angle
    emitter.angle = 0;
    emitter.angleVar = 360;
    
    
    // speed of particles
    emitter.speed = 120;
    emitter.speedVar = 20;
    
    
    // radial
    emitter.radialAccel = -120;
    emitter.radialAccelVar = 0;
    
    
    // tangential
    emitter.tangentialAccel = 30;
    emitter.tangentialAccelVar = 0;
    
    // life of particles
    emitter.life = .45f;
    emitter.lifeVar = .2f;
    
    
    // spin of particles
    emitter.startSpin = 0;
    emitter.startSpinVar = 0;
    emitter.endSpin = 0;
    emitter.endSpinVar = 0;
    
    
    
    // color of particles
    ccColor4F white = {1, 1, 1, 1};
    ccColor4F black = {0, 0, 0, 0};
    
    emitter.startColor = white;
    emitter.startColorVar = black;
    emitter.endColor = white;
    emitter.endColorVar = black;
    
    
    
    // size, in pixels
    emitter.startSize = 25*rockscale;
    
    emitter.startSizeVar = 10*rockscale;
    emitter.endSize = 20*rockscale;
    emitter.endSizeVar = 7*rockscale;

    // emits per second
    emitter.emissionRate = 99999;

    // additive
    emitter.blendAdditive = YES;
    emitter.position = thepoint;

    // adding the emitter
    [self addChild: emitter]; 

    emitter.autoRemoveOnFinish = YES;
    
    
}
#pragma mark -
#pragma mark cc Misc Methods
-(void)draw{
    [contactvar draw];
}
-(void) actualInitWithGameMode:(int)theGameMode{
    
    dlog(@"init called");
    
    
    // Get the dimensions of the window for calculation purposes
    winSize = [[CCDirector sharedDirector] winSize];
    contactvar=[[thecontactlistener alloc] initWithDebugMode:drawdebugmode andDelegate:self];
    

    //rockbatch
    rockbatch=[CCSpriteBatchNode batchNodeWithFile:@"rock.png"];
    [self addChild:rockbatch];
    
    //bulletbatch
    bulletbatch=[CCSpriteBatchNode batchNodeWithFile:@"bullet.png"];
    [self addChild:bulletbatch];
    timeToNextFire=0;
    
    //Initialize variables
    bullets=[CCArray array];
    rocks=[CCArray array];
    rockcache=[CCArray array];
    bulletcache=[CCArray array];
    powerUps=[CCArray array];
    
    //player
    [self makeplayer];
    
    
    //Add some rocks to the caches now to reduce any lag later in game
    for (int i=0; i<7; i++) {
        
        RockSprite * sprite=[RockSprite spriteWithFile:@"rock.png"];
        sprite.visible=NO;
        [rockcache addObject:sprite];
        [rockbatch addChild:sprite];
        
        CCSprite * sprite2=[CCSprite spriteWithFile:@"bullet.png"];
        sprite2.visible=NO;
        [bulletcache addObject:sprite2];
        [bulletbatch addChild:sprite2];
    }
    
    
    //logic
    [self scheduleUpdate];
    
    
	//paused
    m_paused=NO;
    goToNextLevel=NO;
    
    //powerups
    shouldUpdatePowerUps=NO;
    shieldActive=NO;
    spikeyShieldActive=NO;
    timeToNextSpikeHit=0;
    multiShotActive=NO;
    
    //level
    //use the rock level generator to generate levels
    levelvar=[RockLevelGenerator levelWithDelegate:self Overlay:gameoverlayvar Number:1 gameMode:theGameMode score:0];
    
    //bg
    CCSprite *bg= [CCSprite spriteWithFile:@"64x64new2.png"];
    ccTexParams tp = {GL_LINEAR,GL_LINEAR,GL_REPEAT,GL_REPEAT};
    [bg.texture setTexParameters:&tp];
    [bg setTextureRect:CGRectMake(0, 0, kSurvivalworldwidth*2, kSurvivalworldheight*2)];
    [self addChild:bg z:-1];
    
    
    //followvar
    followvar=[CCFollow actionWithTarget:player worldBoundary:worldboundry];
    [self runAction:followvar];
    
    
}
#pragma mark -
#pragma mark ccUpdateMethods
-(void)updateGame:(ccTime)dt{
    
    int i;
    int rockscount=[rocks count];
    
    //rock out of world
    for (i=0; i<rockscount; i++) {
        
        RockSprite * rock=[rocks objectAtIndex:i];
        CGRect box=rock.boundingBox;
        
        //if outside world
        if (box.origin.x>worldwidth || box.origin.x+box.size.width<0 || box.origin.y>worldheight || box.origin.y+box.size.height<0) {
            
            //cleanup
            [rock cleanup];
            [self randomizerock:rock];
            
        }
        
        //rocks that are not on screen are set to invisible -> faster
        if (CGRectIntersectsRect(box, CGRectMake(-self.boundingBox.origin.x, -self.boundingBox.origin.y, winSize.width, winSize.height))) {
            if (!rock.visible) {
                //just came on screen
                rock.visible=YES;
            }
        }
        else{
            if (rock.visible) {
                rock.visible=NO;
            }
        }
    }
    
    
    
    //bullet out of world
    int bulletcount=[bullets count];
    
    for (i=0; i<bulletcount; i++) {
        if (i<0) {
            elog(@"ERROR: trying to index %i of bullets array, rocks len=%i, rocks len count=%i,bullet len=%i, bullet len count=%i",i,[rocks count],rockscount,[bullets count],bulletcount);
        }
        
        CCSprite * bullet=[bullets objectAtIndex:i];
        if (bullet.position.x>worldwidth || bullet.position.x<0 || bullet.position.y>worldheight || bullet.position.y<0) {
            
            
            //cleanup
            [contactvar removesprite:bullet];
            [bullet cleanup];
            bullet.visible=NO;
            
            
            [bulletcache addObject:bullet];
            [bullets fastRemoveObject:bullet];
            
            
            //iter stuff
            bulletcount--;
            i--;
        }
    }


    if (!shouldUpdatePowerUps)
    {
        return;
    }
    for (Powerup *powerup in powerUps){
        if (powerup.callupdate)
        {
            [powerup update];
        }
    }
#ifdef DEBUG_MODE
    if (powerUps.count==0)
    {
        elog(@"power up count was 0!");
        shouldUpdatePowerUps=NO;
    }
#endif
}

//this is separate from updategame so at deathscreen gameoverlayvar and b2 contact are not run
-(void)update:(ccTime)dt {

    [gameoverlayvar updateMinimap];

    //contact var
    [contactvar tick:dt];
    if (goToNextLevel && gameoverlayvar!=nil) {
        [self nextLevel];
        return;
    }

    
    //bullet timer
    if (timeToNextFire>0) timeToNextFire-=dt;
    else if (userIsFiring) {
        [self makebullet];
    }
    
    //bullet timer
    if (spikeyShieldActive) {
        if (timeToNextSpikeHit>0) timeToNextSpikeHit-=dt;
    }


    [self updateplayer];

    [self updateGame:dt];
    
}

-(void)updateplayer{
    
    if (joysticktouch) {
        
        //trig for calculating the user input
        int x=currjoystickpos.x-joystickpointx;
        int y=currjoystickpos.y-joystickpointy;
        float h=sqrt(x*x+y*y);
        if (h>=joystickcircleradius) {
            h=joystickcircleradius;
        }
        //change h to percent of h
        h=h/joystickcircleradius;
        
        float deg=atan2(x,y);
        
        //this line makes it so player travels in direction of joystick
        deg-=CC_DEGREES_TO_RADIANS(player.rotation);
        
        
        player.rotation=fmod((sin(deg)*h*playerrotationspeed+player.rotation) , 360);
        
        
        float newdeg=player.rotation*M_PI/180;
        
        //get new pos
        CGPoint pos=player.position;
        pos=CGPointMake(pos.x+=sin(newdeg)*h*playerspeed*cos(deg), pos.y+=cos(newdeg)*h*playerspeed*cos(deg));
        
        
        //make sure its valid
        if (CGRectContainsPoint(worldboundry, pos)){
            player.position=pos;
        }
    }
}

#pragma mark -
#pragma mark Contact methods

//No sprites can be deallocated in this function because a future collision with the same sprite in the same frame will cause the game to crash
//They are saved and deallocated after the Box2D collision detection is finished
-(int)contactfound:(CCSprite *)s1 s2:(CCSprite *)s2{
    switch (s1.tag+s2.tag) {
            
        case tagplayer+tagplayer:
        {
            elog(@"ERROR: player crashed into itself?");
            return delneither;
        }
            
        case tagbullet+tagbullet:
            return delneither;
            
        case tagrock+tagrock:
            return delneither;
            
        case tagplayer+tagbullet:
            return delneither;
            
            
        case tagplayer+tagrock:
            dlog(@"Player Collided with rock!");
            return [self playerContact:s1 withRock:s2];
            
        case tagbullet+tagrock:
        {
            //if rock does not die only remove bullet sprite
            int retVal;
            
            RockSprite * rock;
            CCSprite * bullet;
            
            if ([rocks containsObject:s1]) 
            {
                rock=(RockSprite *)s1;
                bullet=s2;
                
                retVal=del2;
            }
            else
            {
                rock=(RockSprite *)s2;
                bullet=s1;
                
                retVal=del1;
            }
            dlog(@"health before hit: %f",rock.health);
            
            float rockscale=rock.scale/CC_CONTENT_SCALE_FACTOR();

            [self makeparticlesfrompoint:bullet.position withscale:rockscale];
            rock.health-=30;
            
            
            [levelvar rockShot:rock];
            
            //dead rock
            if (rock.health<=0) {
                dlog(@"rock %p has been destroyed",rock);
                
                return delboth;
            }
            else{
                dlog(@"rock %p was not destroyed",rock);
                
                return retVal;
            }
            
        }
           


        case tagplayer+tagfloatingpowerup:{

            if (player==s1)
            {
                if ([((Powerup *)s2) shouldPowerUpDieOnPlayerContact])
                {
                    return del2;
                }
                else
                {
                    return delneither;
                }
            }
            else
            {
                if ([((Powerup *)s1) shouldPowerUpDieOnPlayerContact])
                {
                    return del1;
                }
                else
                {
                    return delneither;
                }
            }
        }

        case tagbullet+tagfloatingpowerup:
            return delneither;

        case tagfloatingpowerup+tagfloatingpowerup:
            return delneither;
            
        case tagrock+tagfloatingpowerup:
            return delneither;

        case tagfloatingpowerup+tagshieldpowerup:
            return delneither;

        case tagbullet+tagshieldpowerup:
            return delneither;

        case tagshieldpowerup+tagshieldpowerup:
            dlog(@"warning: two shields collided?");
            return delneither;
            
        case tagrock+tagshieldpowerup:
        {
            ifelog(!shieldActive && !spikeyShieldActive, @"warning: shield not active and shield hit rock %@ %@ %@ %i %i",s1,s2,powerUps,shieldActive,spikeyShieldActive);
            if (!spikeyShieldActive) 
            {
                return delneither;
            }
            
            RockSprite * rock;
            
            
            if ([rocks containsObject:s1]) 
            {
                rock=(RockSprite *)s1;
            }
            else
            {
                rock=(RockSprite *)s2;
            }
            rock.health-=30;
            
            return savecollision;
        }

        default:
        {
            elog(@"Error: could not decode sum of tags: %i, %@ and %@",s1.tag+s2.tag,s1,s2);
            return delneither;
        }
            
    }//end of switch statement
    
    return delneither;
}

//Some types of contact need to be saved for later, such as
//Contact with player and rock when player is invincible
//Contact with player and rock when player has a shield
-(int)contactIsAliveWithSprite:(CCSprite *)s1 andSprite:(CCSprite *)s2{
    switch (s1.tag+s2.tag) {
        case tagplayer+tagrock:
            return [self playerContact:s1 withRock:s2];
        case tagshieldpowerup+tagrock:
            if (!spikeyShieldActive)
            {
                return delneither;
            }
            return [self playerContact:s1 withRock:s2];
        default:
            return delneither;
    }
    return delneither;
}


//This is a generic function for removing sprites from the Box2D collision detection engine
//However, this is not called when a sprite is moved into a sprite cache
-(void)removesprite:(CCSprite *)sprite{
    switch (sprite.tag) {
        case tagplayer:
            
            ifelog(levelvar.lives!=0, @"Error: was told to remove player and lives = %i",levelvar.lives);
            
            [levelvar playerKilled];
            
            [player removeFromParentAndCleanup:YES];
            return;

        case tagrock:

            dlog(@"cleanup rock %p",sprite);

            //cleanup
            [sprite cleanup];
            sprite.visible=NO;
            
            [rocks fastRemoveObject:sprite];
            [rockcache addObject:sprite];
            
            
            //levelvar is nil when rocks are cleaned up at the end of the game 
            //so this is only actually called when rocks are killed in game
            [levelvar rockKilled:sprite];
            return;
            
        case tagbullet:
            
            //cleanup
            [sprite cleanup];
            sprite.visible=NO;
            
            [bullets fastRemoveObject:sprite];
            [bulletcache addObject:sprite];
            
            return;


        case tagfloatingpowerup:

            //don't delete the power up sprite until the entire power up action is over
            //at this point the sprite is still alive but it does not have a b2 body
            [(Powerup *)sprite playerContact];

            return;
            
        case tagshieldpowerup:
            elog(@"Warning: found shield power up in removesprite?");
            return;

        default:
        {
            elog(@"Error: bad tag %i",sprite.tag);
            dlog(@"");
            return;
        }
    }
}

//Player contact with rock
//Called from both contactFound and contactIsAliveWithSprite
-(int)playerContact:(CCSprite *)s1 withRock:(CCSprite *)s2{
    
    
    if (playerIsInvincible || shieldActive || spikeyShieldActive) 
    {
        if (spikeyShieldActive)
        {
            if (timeToNextSpikeHit<=0) 
            {
                dlog(@"spiky hit!");

                RockSprite * rock;
                int retVal;

                if ([rocks containsObject:s1]) 
                {
                    rock=(RockSprite *)s1;
                    retVal=del1;
                }
                else
                {
                    rock=((RockSprite *)s2);
                    retVal=del2;
                }


                rock.health-=30;
                [levelvar rockShot:rock];
                
                timeToNextSpikeHit=1/3.0;


                //dead rock
                if (rock.health<=0)
                {
                    dlog(@"rock %p will die",rock);
                    return retVal;
                }
                else
                {
                    dlog(@"rock %p will NOT die",rock);
                    return savecollision;
                }
            }
        }
        return savecollision;
    }
    
    //One rock is removed at the end of this function and there should always be at least one rock on the screen
    //so if there are no rocks in the rocks list make another rock
    if (rocks.count<2) {
        [self makerock];
    }
    
    //reset player
    playerIsInvincible=YES;
    [gameoverlayvar freezePlayer];
    
    //Blink
    CCFiniteTimeAction * action=
    [CCRepeat actionWithAction:
        [CCSequence actions:
            [CCShow action],
            [CCDelayTime actionWithDuration:.4],
            [CCHide action],
            [CCDelayTime actionWithDuration:.2],
            nil] 
        times:4];
    
    
    //Wait a little before showing player again -> blink -> become vulnerable again after blinking is over
    action=[CCSequence actions:
        [CCHide action],
        [CCDelayTime actionWithDuration:1.7],
        [CCCallBlock actionWithBlock:^{[gameoverlayvar unFreezePlayer];}],
        action,
        [CCShow action],
        [CCCallBlock actionWithBlock:^{playerIsInvincible=NO;}],
        nil];

    [player runAction:action];
    

    //Make some particles
    [self makeparticlesfrompoint:player.position withscale:.5];
    
    


    
    
    //this function returns whether player should be removed or not
    if ([levelvar playerCrashed]) {
        return delboth;
    }
    
    
    if (player==s1) 
    {
        dlog(@"removed rock because it crashed into player");
        ((RockSprite *)s2).health=-10;
        [levelvar rockShot:s2];
        return del2;
    }

    else if(player==s2) 
    {
        
        //kill rock
        dlog(@"removed rock because it crashed into player");
        ((RockSprite *)s1).health=-10;
        [levelvar rockShot:s1];
        return del1;
    }

    // This should never happen, but if it does stay on the safe side and don't remove player
    elog(@"Error: player was not sprite 1 or sprite 2 in player contact function");
    return delneither;
}
@end
