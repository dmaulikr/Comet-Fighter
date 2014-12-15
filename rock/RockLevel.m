//
//  RockLevel.m
//  rock
//
//  Created by Ryan on 10/2/12.
//
//



/*
 managed by level class:
 
 points
 victory
 rock spawning
 lives
 death
 */


#import "RockLevel.h"
#import "Powerups.h"


int survivalRockCreater(int score,int rockcount){

    //make sure to use ifdef BETA_TEST when adding new equation
    //so the difficulty of the game is not changed

    dlog(@"on rock death score=%i,rockcount=%i",score,rockcount);
    int modby=1;
    
    if (score<16) {
        modby=4;
    }
    else if (score<31){
        modby=3;
    }
    else if (score<51){
        modby=2;
    }
    else if (score<71){
        modby=1;
    }
    else if (score>100 && score<121){
        return 1;
    }
    else if (score>150){
        //good luck if you reach here
        return 2;
    }
    
    if (score%modby==0) {
        return 1;
    }
    return 0;
}

void survivalPowerupCreater(int score,CCLayer <gamelayerProtocal> * gamelayer,CGPoint pos){
    
#ifndef BETA_TEST
    return;
#endif
    

    
    int ran=arc4random()%100;

    // 90% chance for nothing
    // 2% chance for a shield
    // 4% chance for a spikey shield
    // 4% chance for a multi shot powerup
    if (ran<90)
    {
        return;
    }
    
    switch (ran-90) {
            
        case 0:case 1:
        {
            [PowerupShield addtogamelayer:gamelayer atPos:pos];
            break;
        }
        case 2:case 3:case 4:case 5:{
            [PowerupSpikeyShield addtogamelayer:gamelayer atPos:pos];
            break;
        }
        case 6:case 7:case 8:case 9:{
            [PowerupMultishot addtogamelayer:gamelayer atPos:pos];
            break;
            
        }


        default:{
            elog(@"Error: invalid switch output in survivalPowerupCreater (%i)",ran-90);
        }
    }


    

    
}


@implementation RockLevel
@synthesize delegate,gameOverlay,lives,levelnumber,gamemode,score;
-(id)initWithDelegate:(CCLayer <gamelayerProtocal> *)thedelegate Overlay:(CCLayer <gameoverlayProtocal> *)theoverlay number:(int)number gamemode:(int)theGameMode score:(int)thescore{
    
    self = [super init];
    if (self) {
        delegate=thedelegate;
        gameOverlay=theoverlay;
        score=thescore;
        lives=klives;
        levelnumber=number;
        
        gamemode=theGameMode;
        
        
        
        if (delegate.worldwidth!=kSurvivalworldwidth) {
            
            
            delegate.worldwidth=kSurvivalworldwidth;
            delegate.worldheight=kSurvivalworldheight;
            delegate.worldboundry=kSurvivalworldboundry;
            [delegate updateFollowVar];
        }
        
        [self actualInit];
    }
    return self;
}


-(void)rockShot:(CCSprite *)rock{
    
}
-(void)rockKilled:(CCSprite *)rock{
    
}
-(void)actualInit{
    
}
-(void)restart{

    //This should never be called becasuse the level class is recreated on restart
    elog(@"Error: level -restart was called");
    score=0;
    lives=klives;
}
-(void)playerKilled{
    
    [delegate gameLostWithPoints:score];
}
-(BOOL)playerCrashed{
    lives--;
    dlog(@"lives=%i in playerCrashed (level var)",lives);
    if (lives==0) {
        return YES;
    }
    [gameOverlay removelife];
    return NO;
}
-(NSDictionary *)getLevelData{
    return @{@"title": [NSString stringWithFormat:@"wave %i",levelnumber],@"subtitle":[self getLevelGoal]};
}
-(NSString *)getLevelGoal{
    elog(@"get level goal in main rock level should be called!");
    return @"";
}
@end//general to-be-subclassed rockLevel




@implementation LevelInfinate
-(void)rockShot:(CCSprite *)rock{
    
    RockSprite * therock=(RockSprite *)rock;
    
    if (therock.health<=0) {
        score++;
        
        
        [gameOverlay setlabelto:score];
        
        
        //add more rocks as gameplay goes on
        for (int i=0; i<survivalRockCreater(score,delegate.rocks.count); i++) {
            [delegate makerock];
        }
        
        
        
        [delegate makerocksfromrock:rock];
        
        CCArray * rocks=delegate.rocks;
        
        //add rocks if user somehow manages to kill them all
        if (rocks.count==1 || (int)rocks.count<(score/3+3)) {
            [delegate makerock];
        }

        //run the logic for powerups
        survivalPowerupCreater(score,delegate,rock.position);


    }
}
-(NSDictionary *)getLevelData{

    //this is not shown - this is for survival mode, aka infinity level
    return @{@"title": @"Survival",@"subtitle":@""};
}
-(void)actualInit{
    //make some rocks to start the level
    for (int i=0; i<kRockCountAtStartOfInfinityLevel; i++) {
        
        [delegate makerock];
    }
}
@end//levelinfinate





//actual levels start here
@implementation LevelKillRocks
-(void)rockShot:(CCSprite *)rock{
    
    RockSprite * therock=(RockSprite *)rock;
    
    if (therock.health<=0) {
        score++;
        [gameOverlay setlabelto:score];
        
        if (score>=rockGoal) {
            delegate.goToNextLevel=YES;
            return;
        }
        
        //add more rocks as gameplay goes on - same equation as survival
        for (int i=0; i<survivalRockCreater(score,delegate.rocks.count); i++) {
            [delegate makerock];
        }
        
        
        [delegate makerocksfromrock:rock];
        
        CCArray * rocks=delegate.rocks;
        
        if (rocks.count==1 || (int)rocks.count<(score/3+3)) {
            [delegate makerock];
        }
    }
}
-(void)actualInit{
    //set rock goal
    rockGoal=25+levelnumber*25+CCRANDOM_MINUS1_1()*levelnumber*10+score;

    dlog(@"rock goal = %i",rockGoal);
    
    //make some rocks
    for (int i=0; i<kRockCountAtStartOfInfinityLevel; i++) {
        
        [delegate makerock];
    }
}
-(NSString *)getLevelGoal{
    return [NSString stringWithFormat:@"Destroy %i rocks",rockGoal];
}

@end





@implementation LevelTravel

@end



@implementation LevelSurvive

@end



@implementation LevelBoss

//This level has one giant rock that splits into smaller ones
-(void)rockShot:(CCSprite *)rock{
     
    RockSprite * therock=(RockSprite *)rock;
    
    if (therock.health<=0) {
        score++;
        [gameOverlay setlabelto:score];
        
        if (therock.scale/CC_CONTENT_SCALE_FACTOR()>1.1) {
            
            int rockstomake=(3+(arc4random()%3));
            for (int i=0; i<rockstomake; i++) {
                RockSprite * newrock=(RockSprite *)[delegate createrock];
                
                newrock.size=newrock.scale=.75+.25*CCRANDOM_MINUS1_1();
                
                
                newrock.health=newrock.size*320-60;
                
                if (CC_CONTENT_SCALE_FACTOR()==2)
                    newrock.scale=newrock.scale*2;
                
                
                newrock.position=therock.position;
                float angle=((float)i/(float)rockstomake)*360;
                
                angle+=(CCRANDOM_MINUS1_1()*50);
                
                angle=CC_DEGREES_TO_RADIANS(angle);
                [delegate makerockaction:CGPointMake(cos(angle), sin(angle)) withrock:newrock];
                
                [delegate makerockbody:newrock];
                
                [delegate.rocks addObject:newrock];
            }
            return;
        }
        
        [delegate makerocksfromrock:rock];
        

        
    }
}
-(void)actualInit{
    
    dlog(@"boss level init");
    RockSprite * rock=(RockSprite *)[delegate createrock];
    
    //size/scale and health
    rock.scale=rock.size=2;
    
    if (CC_CONTENT_SCALE_FACTOR()==2) {
        rock.scale=rock.scale*2;
    }
    rock.health=rock.size*320-60;
    
    //movement and spawn location
    [delegate randomizerock:rock];
    
    //box2d body
    [delegate makerockbody:rock];
    
    [delegate.rocks addObject:rock];
    
    
    
    //shrink the world
    if (delegate.worldwidth!=480) {
        
        delegate.worldwidth=480;
        delegate.worldheight=360;
        delegate.worldboundry=(CGRectMake(0, 0, 480, 360));
        [delegate updateFollowVar];
        
    }
    
    
}
-(NSString *)getLevelGoal{
    return @"Destroy all rocks";
}
-(void)rockKilled:(CCSprite *)rock{

    //user has to kill every last one to win
    if (delegate.rocks.count==0) {
        delegate.goToNextLevel=YES;
    }
}
@end


@implementation LevelBonus
-(void)rockShot:(CCSprite *)rock{
    
    RockSprite * therock=(RockSprite *)rock;
    
    if (therock.health<=0) {
        score++;
        [gameOverlay setlabelto:score];
        
        
        //add more rocks as gameplay goes on - same equation as survival
        for (int i=0; i<survivalRockCreater(score,delegate.rocks.count); i++) {
            [delegate makerock];
        }
        
       
        [delegate makerocksfromrock:rock];
        
        CCArray * rocks=delegate.rocks;
        
        if (rocks.count==1 || (int)rocks.count<(score/3+3)) {
            [delegate makerock];
        }
    }
}

-(void)actualInit{

    //make some rocks
    for (int i=0; i<kRockCountAtStartOfInfinityLevel*2; i++) {
        
        [delegate makerock];
    }
}
-(NSString *)getLevelGoal{
    return @"Bonus Level!";
}
-(BOOL)playerCrashed{
    
    delegate.goToNextLevel=YES;
    return NO;
}
@end






@implementation RockLevelGenerator

//generate the next level based on the number of levels completed and the game mode
+(RockLevel *)levelWithDelegate:(CCLayer<gamelayerProtocal> *)thedelegate Overlay:(CCLayer<gameoverlayProtocal> *)theoverlay Number:(int)thenumber gameMode:(int)theGameMode score:(int)thescore{
    
    dlog(@"generating level %i",thenumber);
    
    ifelog(theGameMode!=gameModeLevels && theGameMode!=gameModeSurvival, @"game mode (%i) is not levels or survival",theGameMode);
    
    RockLevel * retVal=nil;
    
    if (theGameMode==gameModeSurvival)
    {
        //on survival mode, allways use the infinate level
        retVal=[LevelInfinate alloc];
    }
    else{
        switch (thenumber%3) {
            case 0:
                retVal=[LevelBonus alloc];
                break;
            case 1:
                retVal=[LevelKillRocks alloc];
                break;
            case 2:
                retVal=[LevelBoss alloc];
                break;
            default:
                elog(@"wtf %i",thenumber);
                break;
        }
    }
      
   
    return [retVal initWithDelegate:thedelegate Overlay:theoverlay number:thenumber gamemode:theGameMode score:thescore];
}

@end
