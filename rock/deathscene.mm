//
//  deathscene.m
//  rock
//
//  Created by Ryan on 8/22/12.
//
//

#import "deathscene.h"
#import "MenuLayer.h"
#import "GameScene.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"
#import "GCHelper.h"

@implementation deathlayer
@synthesize winSize;
+(CCScene *)sceneWithGameLayer:(CCLayer <gamelayerProtocal> *)gamelayer Score:(int)thescore didWin:(BOOL)didwin nextlevel:(int)nextlevel{
    //make a scene and add the gamelayer and the death layer to it
    CCScene * deathscene=[CCScene node];
    [deathscene addChild:gamelayer];
    [deathscene addChild:[[deathlayer alloc] initWithGameLayer:gamelayer Score:thescore didWin:didwin nextlevel:nextlevel]];
    dlog(@"END of death scene creation");
    return deathscene;
    
}
-(id)initWithGameLayer:(CCLayer <gamelayerProtocal> *)gamelayer Score:(int)thescore didWin:(BOOL)didwin nextlevel:(int)nextlevel{
    self = [super init];
    if (self) {
        dlog(@"next level is %i",nextlevel);
        
        //winsize
        winSize=[[CCDirector sharedDirector] winSize];
        
        
        
        NSString * titlestring;
        NSString * nextstring;
        if (didwin) {
            titlestring=@"Victory!";
            nextstring=@"Next Level";
        }
        else{
            titlestring=@"Game Over";
            nextstring=@"Restart";
        }
        
        
        CCLabelTTF *label = [CCLabelTTF labelWithString:titlestring fontName:@"Marker Felt" fontSize:64];
        label.position=CGPointMake(winSize.width/2, winSize.height/2);
        [self addChild:label];
        
        
        
        //font size
        [CCMenuItemFont setFontSize:32];
        
        
        
        
        //restart label
        CCMenuItem * itemRestart = [CCMenuItemFont itemWithString:nextstring block:^(id sender) {
			dlog(@"Restart");
            //this is first so game can advance level then tell layer ui
            [gamelayer restartWithLevel:nextlevel];
            //remove death screen as its parent
            [gamelayer removeFromParentAndCleanup:NO];
            CCScene * thegamescene=[[GameScene alloc] initWithGameLayer:gamelayer];
            [gamelayer updateLevelvarOverlayPointer];
            
            [[CCDirector sharedDirector] replaceScene:thegamescene];
            
		}
                                    ];
        
        
        //menu label
        CCMenuItem * itemMenu = [CCMenuItemFont itemWithString:@"Menu" block:^(id sender) {
			dlog(@"menu");
            
            [[CCDirector sharedDirector] replaceScene:[MenuLayer scene]];
		}
                                 ];
        
        
        
        // Leaderboard Menu Item using blocks
        CCMenuItem *itemLeaderboard = [CCMenuItemFont itemWithString:@"Leaderboard" block:^(id sender) {
           
            [GCHelper GCleaderboard];
            
        }
                                       ];
        
        
        //make the menu
        CCMenu *menu = [CCMenu menuWithItems:itemRestart,itemMenu,itemLeaderboard, nil];
        
        [menu alignItemsInColumns:@2,@1, nil];
		[menu setPosition:CGPointMake( winSize.width/2, winSize.height/2 - 70)];
        
        
		// Add the menu to the layer
		[self addChild:menu];
        
        
        
        //score label (copied from gameoverlay)
        labelscore = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%i",thescore] fontName:@"Marker Felt" fontSize:28*iPadScaleFactor];
        labelscore.color=ccGRAY;
        CGSize box=labelscore.boundingBox.size;
        labelscore.position=CGPointMake(winSize.width-box.width/2, winSize.height-box.height/2);
        [self addChild:labelscore];
        
    }
    return self;
}
-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController {
    
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissViewControllerAnimated:YES completion:nil];
}
-(void)dealloc{
    dealloclog(@"death scene dealloc was called");
}
@end
