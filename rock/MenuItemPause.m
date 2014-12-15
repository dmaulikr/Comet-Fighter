//
//  MenuItemPause.m
//  rock
//
//  Created by Ryan on 8/30/12.
//
//

#import "MenuLayer.h"
#import "MenuItemPause.h"
#import "AppDelegate.h"
#import "GCHelper.h"


#define kZoomActionTag 1
@implementation MenuItemPause


#define	kCCZoomActionTag 0xc0c05002

//was copied from [super selected]. Only thing changed was the zoom scale. 
-(void) selected
{
    // subclass to change the default action
	if(self.isEnabled) {
		[super selected];
        
		CCAction *action = [self getActionByTag:kCCZoomActionTag];
		if( action )
			[self stopAction:action];
        
		CCAction *zoomAction = [CCScaleTo actionWithDuration:0.1f scale:1.5f];
		zoomAction.tag = kCCZoomActionTag;
		[self runAction:zoomAction];
	}
}
@end

@implementation PauseLayer
@synthesize gamelayer,gameoverlay,winSize;
-(void)actualInit{
    dlog(@"pause layer");

    //pause game
    [gamelayer pause];
    [gameoverlay pause];
    
    //hide pause button
    gameoverlay.menupause.visible=NO;
    

    //load items on pause screen

    //paused label
    CCLabelTTF * labelpaused=[CCLabelTTF labelWithString:@"Paused" fontName:@"Marker Felt" fontSize:64*iPadScaleFactor];
    labelpaused.position=CGPointMake(winSize.width/2, winSize.height-40*iPadScaleFactor);
    [self addChild:labelpaused];
    
    
    //pause layer menu
    [CCMenuItemFont setFontSize:36*iPadScaleFactor];
    
    
    CCMenuItem *itemMenu = [CCMenuItemFont itemWithString:@"Menu" target:self selector:@selector(tomenu)];
    
    CCMenuItem *itemLeaderboard = [CCMenuItemFont itemWithString:@"Leaderboard" block:^(id sender){
        [GCHelper GCleaderboard];
        
    }];

    
    [CCMenuItemFont setFontSize:50*iPadScaleFactor];
    CCMenuItem *itemResume = [CCMenuItemFont itemWithString:@"Resume" target:self selector:@selector(unpause)];
    
    
    CCMenu * menu = [CCMenu menuWithItems:itemResume,itemMenu,itemLeaderboard, nil];

    if (TargetIsiPad) 
    {
        [menu alignItemsVertically];
        [menu setPosition:CGPointMake( winSize.width/2, winSize.height/2-100)];
        itemResume.position=CGPointMake(0, itemResume.position.y+ 50);
        
    }
    else
    {
        [menu alignItemsInColumns:@1,@2, nil];
        [menu setPosition:CGPointMake( winSize.width/2, winSize.height/2)];
        
        
        itemResume.position=CGPointMake(0, -35);
        
        itemMenu.position=CGPointMake(winSize.width/2-itemMenu.activeArea.size.width+25, -menu.position.y+30);
        itemLeaderboard.position=CGPointMake((-winSize.width/2)+itemLeaderboard.activeArea.size.width/2+20, -menu.position.y+30);
        
    }
    
    // Add the menu to the layer
    [self addChild:menu];
}
-(void)unpause{
    //cleanup pause layer
    [self cleanup];
    
    dlog(@"unpausing");
    gameoverlay.menupause.visible=YES;

    //unpause game
    [gamelayer unpause];
    [gameoverlay unpause];

    if (gameoverlay.joysticktouch.phase==UITouchPhaseEnded) {
        [gameoverlay setjoystickpos:joystickpoint];
        [gameoverlay setjoysticktouch:nil];
    }
    
    //remove pause layer
    [self removeFromParentAndCleanup:YES];
    
    gamelayer=nil;
    gameoverlay=nil;
}

-(void)tomenu{
    
    dlog(@"menu");
    
    [gamelayer.parent removeFromParentAndCleanup:YES];
    [gamelayer removeFromParentAndCleanup:YES];
    [gameoverlay removeFromParentAndCleanup:YES];
    gamelayer=nil;
    gameoverlay=nil;
    
    [[CCDirector sharedDirector] replaceScene:[MenuLayer scene]];
}

-(void)draw{
    CGPoint d[]={CGPointMake(0, 0),CGPointMake(winSize.width, 0),CGPointMake(winSize.width, winSize.height),CGPointMake(0, winSize.height)};
    ccDrawSolidPoly(d, 4, ccc4f(0, 0, 0, .8f));
}

-(void)dealloc{
    
    dealloclog2(@"pause scene dealloc was called");
}
@end