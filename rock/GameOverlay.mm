//
//  GameOverlay.m
//  rock
//
//  Created by Ryan on 7/19/12.
//  Copyright (c) 2014 Ryan Hughes. All rights reserved.
//

#import "GameOverlay.h"
#import "deathscene.h"

@implementation GameOverlay
@synthesize labelscore,gamelayervar,menupause,joysticktouch;

#pragma mark -
#pragma mark init & draw
- (void)actualInit {
    
    //touches
    [self setTouchEnabled:YES];
    
    winSize = [[CCDirector sharedDirector] winSize];
    
    //minimap sprites
    minimapplayer=[CCSprite spriteWithFile:@"player.png"];
    
    minimapplayer.scale=.25*kMinimapScaleFactor*CC_CONTENT_SCALE_FACTOR()*iPadScaleFactor;
    
    minimapplayer.position=CGPointMake(kMinimapPosX, kMinimapPosY);
    [self addChild:minimapplayer];
    
    

    //pause
    CCLabelTTF *label = [CCLabelTTF labelWithString:@"||" fontName:@"Marker Felt" fontSize:28*iPadScaleFactor];
    
    CCMenuItemLabel *pauseMenuItem = [MenuItemPause itemWithLabel:label target:self selector:@selector(pauseButtonClicked)];
    
    
    menupause=[CCMenu menuWithItems:pauseMenuItem, nil];
    
    [pauseMenuItem setContentSize:CGSizeMake(50, 50)];
    [label setAnchorPoint:ccp(0.5,0.5)];
    [label setPosition:ccp(pauseMenuItem.contentSize.width/2,pauseMenuItem.contentSize.height/2)];
        
    menupause.position=CGPointMake(winSize.width/2, winSize.height-20*iPadScaleFactor);
    menupause.opacity=190;
    
    //nsnotification center register is in gamescene so the game can't be paused while the gameoverlay is visible
    
    //this is changed when user exits introOverlay
    menupause.touchEnabled=NO;
    
    [self addChild:menupause];
    



    m_paused=NO;
    isFiring=NO;
    

    //score label
    labelscore = [CCLabelTTF labelWithString:@"0" fontName:@"Marker Felt" fontSize:28*iPadScaleFactor];
    labelscore.color=ccGRAY;
    CGSize box=labelscore.boundingBox.size;
    labelscore.position=CGPointMake(winSize.width-box.width/2, winSize.height-box.height/2);
    [self addChild:labelscore];
    


    //lives
    livesbatch=[CCSpriteBatchNode batchNodeWithFile:@"player.png"];
    lives=[CCArray array];
    
    for (int i=0; i<klives-1; i++) {
        CCSprite *life= [CCSprite spriteWithFile:@"player.png"];
        life.scale=.125*CC_CONTENT_SCALE_FACTOR()*iPadScaleFactor;
        
        
        
        
        life.position=CGPointMake(winSize.width-labelscore.boundingBox.size.width*3.5-i*(TargetIsiPad?40: 25), winSize.height-life.boundingBox.size.height/2-5);
        [livesbatch addChild:life];
        [lives addObject:life];
    }
    [self addChild:livesbatch];
    
    
    
    
    
    //joystick
    joystick=[CCSprite spriteWithFile:@"joystick.png"];
    
    joystick.scale=.1*CC_CONTENT_SCALE_FACTOR();
    
    
    joystick.opacity=127.5;
    joystick.position = joystickpoint;
    gamelayervar.currjoystickpos=joystickpoint;
    [self addChild:joystick];
    
    
    
    playerIsFrozen=NO;
    
}

-(void)draw{
    [super draw];
    
    
    
    //joystick circle
    ccDrawCircle(joystickpoint, joystickcircleradius, 0, 35, NO);
    
    
    
    ccDrawColor4F(1, 255, 1, .1);
    ccDrawCircle(CGPointMake(kMinimapPosX, kMinimapPosY), kMinimapheight/2, 360, 30, NO);
    ccDrawColor4F(255, 255, 255, 1);

    
    //vision
    CGPoint player_postion=gamelayervar.player.position;
    
    //rocks on minimap
    CCArray * rocks=gamelayervar.rocks;
    CGPoint pos;
    
    
    
    
    for (CCSprite * i in rocks){
        
        pos=i.position;
        if (isPointInCircle(pos, player_postion, kMinimapViewRadius)){
            
            double x=(i.position.x-player_postion.x)*kMinimapScaleFactor+kMinimapPosX;
            double y=(i.position.y-player_postion.y)*kMinimapScaleFactor+kMinimapPosY;
            
            CGPoint minipoint=CGPointMake(x,y);
            
            //rock.scale AND ccDrawCircle account for CC_CONTENT_SCALE_FACTOR() - must undo one of them
            ccDrawCircle(minipoint, (54.75*i.scale*kMinimapActualRatio/CC_CONTENT_SCALE_FACTOR()), 0, 8, NO);
            
        }
        
        
    }
}

#pragma mark -
#pragma mark pause

-(void)pauseButtonClicked{
    if (!m_paused) {
        PauseLayer * pauselayervar=[[PauseLayer alloc] init];
        pauselayervar.gamelayer=gamelayervar;
        pauselayervar.gameoverlay=self;
        pauselayervar.winSize=winSize;
        
        [pauselayervar actualInit];
        [self.parent addChild:pauselayervar z:1];
    }
    else{
        dlog(@"Warning:Paused button was clicked, but was already paused!");
    }
    
}

//This method is only used for NSNotification Center
-(void)pauseButtonClicked:(NSDictionary *)userinfo{
    [self pauseButtonClicked];
}

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
#pragma mark Custom label Methods
-(void)setlabelto:(int)thevalue{
    labelscore.string=[NSString stringWithFormat:@"%i",thevalue];
    
        if (thevalue%10==0) {
            [self resizelabel];
        }
}
-(void)resizelabel{
    CGSize box=labelscore.boundingBox.size;
    labelscore.position=CGPointMake(winSize.width-box.width/2, winSize.height-box.height/2);
    
}

-(void) updateMinimap {
    
    minimapplayer.rotation=gamelayervar.player.rotation;
    
   
}


#pragma mark -
#pragma mark Custom methods

-(void)removelife{
    dlog(@"player died in overlay view");
    CCSprite * life=[lives lastObject];
    [lives removeLastObject];
    [livesbatch removeChild:life cleanup:YES];
    life=nil;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    dealloclog(@"Game overlay deallocated");
}

#pragma mark -
#pragma mark cc Touch Methods
-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    //update joystick
    if ([touches containsObject:joysticktouch]) {
        
        CGPoint location=[joysticktouch locationInView:joysticktouch.view];
        
        location = [[CCDirector sharedDirector] convertToGL:location];
        
        [self updatejoystick:location];
    }
}


-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if (gamelayervar.rocks.count==0) {
        elog(@"Error: a rock was made in game overlay var on touches began!!");
        
        [gamelayervar makerock];
    }
    
    UITouch * bullettouchtotest=nil;
    
    for (UITouch * atouch in touches) {
        CGPoint location=[atouch locationInView:atouch.view];
        location = [[CCDirector sharedDirector] convertToGL:location];
        
        //joystick control
        if (isPointInCircle(location,joystickpoint,joystickcircleradius)){
            
            [self setjoystickpos:location];
            [self setjoysticktouch:atouch];
            continue;
        }

        //fire a bullet
        else {
            bullettouchtotest=atouch;
        }
    }
    if (bullettouchtotest) {
        if (!playerIsFrozen) {
            isFiring=!isFiring;
            gamelayervar.userIsFiring=isFiring;
        }
    }
}
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

    //update joystick
    if ([touches containsObject:joysticktouch]) {
        
        [self setjoystickpos:joystickpoint];
        [self setjoysticktouch:nil];
        return;
    }
}




#pragma mark -
#pragma mark Update Joystick Methods
-(void)updatejoystick:(CGPoint)location{
    
    int x=location.x-joystickpointx;
    int y=location.y-joystickpointy;
    float h=sqrt(x*x+y*y);
    
    if (h>=joystickcircleradius) {
        
        float deg=atan2(x,y);
        int newx=sin(deg)*joystickcircleradius+joystickpointx;
        int newy=cos(deg)*joystickcircleradius+joystickpointy;
        [self setjoystickpos:CGPointMake(newx, newy)];
        
    }
    else{
        [self setjoystickpos:location];
    }
}

-(void)setjoystickpos:(CGPoint)thepoint{

    //save local for actual joystick position
    joystick.position=thepoint;

    //tell gamelayer so it can update the player's position
    if (!playerIsFrozen) {
        gamelayervar.currjoystickpos=thepoint;
    }
}
-(void)setjoysticktouch:(UITouch *)thetouch{
    joysticktouch=thetouch;

    if (!playerIsFrozen) {
        gamelayervar.joysticktouch=thetouch;
    }
}

#pragma mark -
#pragma mark Player Control
-(void)freezePlayer{
    playerIsFrozen=YES;
    gamelayervar.joysticktouch=nil;
    gamelayervar.userIsFiring=NO;
    
    
}
-(void)unFreezePlayer{
    playerIsFrozen=NO;
    
    
    if (joysticktouch) {
        gamelayervar.joysticktouch=joysticktouch;
    }
    if (isFiring) {
        gamelayervar.userIsFiring=YES;
    }
}
@end
