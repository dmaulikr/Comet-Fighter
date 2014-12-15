//
//  MenuLayer.m
//  rock
//
//  Created by Ryan Hughes on 7/11/12.
//  Copyright Ryan Hughes 2014. All rights reserved.
//



#import "MenuLayer.h"
#import "GameScene.h"
#import "gameSelector.h"
#import "GCHelper.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#pragma mark - MenuLayer

@implementation MenuLayer

+(CCScene *) scene{
    
	CCScene *scene = [CCScene node];
	
	MenuLayer *layer = [MenuLayer node];
	
	[scene addChild: layer];
	
	return scene;
}

-(id)init {
    
    self=[super init];
	if (self) {
          dlog(@"init called");
        
        
        
		// ask director for the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
        
		
		// create and initialize a Label
        CCLabelTTF * gameTitle = [CCLabelTTF labelWithString:@"Comet Fighter" fontName:@"Marker Felt" fontSize:64*iPadScaleFactor];
            
        
        
        
        // create and initialize a Label
        CCMenuItemLabel * startgame = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:@"Start Game" fontName:@"Marker Felt" fontSize:TargetIsiPad?64:32] block:^(id sender){
            
            
            [[CCDirector sharedDirector] replaceScene:[[GameScene alloc] initWithGameMode:gameModeSurvival]];
        }];
        
        
        
		//
		// Leaderboards and Achievements
		//
        
        
        // Leaderboard Menu Item using blocks
		CCMenuItemLabel *itemLeaderboard = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:@"Leaderboard" fontName:@"Marker Felt" fontSize:TargetIsiPad?64:32] block:^(id sender){
			[GCHelper GCleaderboard];
			
		}];
		
        
		CCMenu *menu = [CCMenu menuWithItems:startgame,itemLeaderboard, nil];
        
        [menu alignItemsInColumns:@2, nil];
		[menu setPosition:CGPointMake( size.width/2, size.height/2 )];
        
        //set positions of menu items
		gameTitle.position=CGPointMake(size.width/2+gameTitle.position.x, size.height/2 +gameTitle.position.y+50*iPadScaleFactor);
		startgame.position=CGPointMake(startgame.position.x, startgame.position.y-50*iPadScaleFactor);
		itemLeaderboard.position=CGPointMake(itemLeaderboard.position.x, itemLeaderboard.position.y-50*iPadScaleFactor);
        
		// Add the menu to the layer
		[self addChild:menu];
		[self addChild:gameTitle];
        

	}
	return self;
}

#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController {
    
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissViewControllerAnimated:YES completion:nil];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController {
    
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissViewControllerAnimated:YES completion:nil];
}
-(void)dealloc{
    dealloclog(@"menu dealloc called");
}
@end
