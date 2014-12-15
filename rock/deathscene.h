//
//  deathscene.h
//  rock
//
//  Created by Ryan on 8/22/12.
//
//

#import "cocos2d.h"
#import "GameLayersProtocals.h"
#import <GameKit/GameKit.h>

@interface deathlayer : CCLayerColor  <GKLeaderboardViewControllerDelegate>{
    CGSize winSize;
    CCLabelTTF * labelscore;
}
@property CGSize winSize;
+(CCScene *)sceneWithGameLayer:(CCLayer <gamelayerProtocal> *)gamelayer  Score:(int)thescore didWin:(BOOL)didwin nextlevel:(int)nextlevel;
-(id)initWithGameLayer:(CCLayer <gamelayerProtocal> *)gamelayer Score:(int)thescore didWin:(BOOL)didwin nextlevel:(int)nextlevel;
@end
