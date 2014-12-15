//
//  GameScene.m
//  
//
//  Created by Ryan Hughes on 7/12/12.
//  Copyright 2012 Ryan Hughes. All rights reserved.
//


#import "GameScene.h"
#import "GameOverlay.h"
#import "GameLayer.h"
#import "deathscene.h"
#import "GameIntroOverlay.h"

@implementation GameScene
- (id)initWithGameMode:(int)theGameMode {
    self=[super init];
	if (self) {
        BOOL isretina;
        if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
            ([UIScreen mainScreen].scale == 2.0)) {
            isretina=YES;
        } else {
            isretina=NO;
        }
        
        
        GameLayer * gamelayervar=[[GameLayer alloc] initWithColor:ccc4(0, 0, 0, 0)];
        GameOverlay * gameoverlayvar=[GameOverlay node];
        
        //delegate variables
        gamelayervar.gameoverlayvar=gameoverlayvar;
        gameoverlayvar.gamelayervar=gamelayervar;
        
		[self addChild:gamelayervar z:0];
        [self addChild:gameoverlayvar z:1];
        
        
        [gameoverlayvar actualInit];
        [gamelayervar actualInitWithGameMode:theGameMode];

        //game is paused until user clicks out of the intro overlay
        [gamelayervar pause];
        
        
        
        helpOverlay * introoverlayvar=nil;
#ifndef BETA_TEST
        introoverlayvar=[[helpOverlay alloc] initWithTitle:@"" subtitle:@""];
#else
        if (theGameMode==gameModeSurvival) {
            introoverlayvar=[[helpOverlay alloc] initWithTitle:@"Survival" subtitle:@""];
        }
        else if (theGameMode==gameModeLevels){

            introoverlayvar=[[helpOverlay alloc] initWithTitle:@"Campaign" subtitle:@""];
        }
        else{
            elog(@"in gamescene game mode was %i",theGameMode);
        }
#endif
        
        
        introoverlayvar.runOnExit=^(void){
            
            //init
            [gamelayervar unpause];
            gameoverlayvar.menupause.touchEnabled=YES;
            
            //pauses game when user opens notification center, gets txts, etc..
            [[NSNotificationCenter defaultCenter] addObserver:gameoverlayvar selector:@selector(pauseButtonClicked) name:@"AppResigned" object:nil];
        };

        

        [self addChild:introoverlayvar z:2];
	}
	return self;
}

//called from restart on death screen
-(id)initWithGameLayer:(CCLayer *)gamelayer{
    self=[super init];
	if (self) {
        BOOL isretina;
        if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
            ([UIScreen mainScreen].scale == 2.0)) {
            isretina=YES;
        } else {
            isretina=NO;
        }
        GameLayer * gamelayervar=(GameLayer *)gamelayer;
        
        GameOverlay * gameoverlayvar=[GameOverlay node];
        
        //delegate vars
        gamelayervar.gameoverlayvar=gameoverlayvar;
        gameoverlayvar.gamelayervar=gamelayervar;
        
        //init
        [gameoverlayvar actualInit];
        gameoverlayvar.menupause.touchEnabled=YES;
        
		[self addChild:gamelayer z:0];
        [self addChild:gameoverlayvar z:1];
	}
	return self;
}
-(id)init{
    elog(@"Error: Game scene init was called from neither game selection nor death scene!");
    return nil;
}
-(void)dealloc{
    dealloclog(@"Game scene deallocated");
}
@end


