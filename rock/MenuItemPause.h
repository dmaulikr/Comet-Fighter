//
//  MenuItemPause.h
//  rock
//
//  Created by Ryan on 8/30/12.
//
//

#import "cocos2d.h"
#import "GameLayersProtocals.h"
#import <GameKit/GameKit.h>

@interface MenuItemPause : CCMenuItemLabel
@end



@interface PauseLayer : CCLayerColor{
    //game layers
    CCLayer <gamelayerProtocal> * gamelayer;
    CCLayer <gameoverlayProtocal> * gameoverlay;
    
    //winsize
    CGSize winSize;
    
}
-(void)actualInit;
-(void)unpause;
-(void)tomenu;
@property (nonatomic) CCLayer <gamelayerProtocal> * gamelayer;
@property (nonatomic) CCLayer <gameoverlayProtocal> * gameoverlay;

@property (nonatomic) CGSize winSize;
@end