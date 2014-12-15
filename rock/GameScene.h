//
//  GameOverScene.h
//  Cocos2DSimpleGame
//
//  Created by Ryan Hughes on 7/12/12.
//  Copyright 2012 Ryan Hughes. All rights reserved.
//

#import "cocos2d.h"
#import "GameLayersProtocals.h"




@interface GameScene : CCScene
- (id)initWithGameMode:(int)theGameMode;
-(id)initWithGameLayer:(CCLayer *)gamelayer;
@end

