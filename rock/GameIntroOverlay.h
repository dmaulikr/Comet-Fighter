//
//  LevelUI.h
//  rock
//
//  Created by Ryan on 10/13/12.
//
//

#import "cocos2d.h"
typedef void (^VoidBlock)(void);

@interface GameInfoOverlay : CCLayerColor{
    CGSize winSize;
}
@property (copy,nonatomic) VoidBlock runOnExit;

-(id)initWithTitle:(NSString *)thetitle subtitle:(NSString *)thesubtitle;
@end




@interface helpOverlay : GameInfoOverlay

@end


@interface levelIntroOverlay : GameInfoOverlay


@end


