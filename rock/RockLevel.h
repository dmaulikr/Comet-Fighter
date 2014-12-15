//
//  RockLevel.h
//  rock
//
//  Created by Ryan on 10/2/12.
//
//

#import <Foundation/Foundation.h>
#import "GameLayersProtocals.h"
#import "cocos2d.h"
#import "RockSprite.h"


@interface RockLevel : NSObject{
    //delegates
    __unsafe_unretained CCLayer <gamelayerProtocal> * delegate;
    __unsafe_unretained CCLayer <gameoverlayProtocal> * gameOverlay;
    
    //points
    int score;
    int lives;
    
    int levelnumber;
    
    int gamemode;
}
-(void)restart;

//This is called when the collision is detected, so the sprite cannot be deallocated here
-(void)rockShot:(CCSprite * )rock;


//called at any time a rock needs to exit box2d engine
//Deallocate the sprite here
-(void)rockKilled:(CCSprite *)rock;

//returns whether all four lives have been used
//this is also called from the collision detection code
-(BOOL)playerCrashed;

//Deallocate the sprite here
-(void)playerKilled;



-(void)actualInit;
-(id)initWithDelegate:(CCLayer <gamelayerProtocal> *)thedelegate Overlay:(CCLayer <gameoverlayProtocal> *)theoverlay number:(int)number gamemode:(int)theGameMode score:(int)thescore;

-(NSDictionary *)getLevelData;
-(NSString *)getLevelGoal;

@property (nonatomic,unsafe_unretained) NSObject <gamelayerProtocal> * delegate;
@property (nonatomic,unsafe_unretained) CCLayer <gameoverlayProtocal> * gameOverlay;
@property (nonatomic) int lives;
@property (nonatomic) int levelnumber;

//these are both carried over to next level in campaign
@property (nonatomic) int gamemode;
@property (nonatomic) int score;
@end


//One possible expansion to Comet Fighter is to add levels, instead of a simple endless style game
//Some possble types of levels
//For now, only infinate is used
@interface LevelKillRocks : RockLevel{
    int rockGoal;
}

@end



@interface LevelInfinate : RockLevel

@end

@interface LevelTravel : RockLevel

@end



//time based
@interface LevelSurvive : RockLevel

@end



@interface LevelBoss : RockLevel

@end


@interface LevelBonus : RockLevel

@end






@interface RockLevelGenerator : NSObject

+(RockLevel *)levelWithDelegate:(CCLayer<gamelayerProtocal> *)thedelegate Overlay:(CCLayer<gameoverlayProtocal> *)theoverlay Number:(int)thenumber gameMode:(int)theGameMode score:(int)thescore;

@end