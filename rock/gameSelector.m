#import "gameSelector.h"
#import "GameLayersProtocals.h"
#import "GameScene.h"
#import "MenuLayer.h"

@implementation gameSelector

-(id)init{
   self = [super init];
   if (self) {
	   	dlog(@"game selector inited");

       
       CGSize size = [[CCDirector sharedDirector] winSize];

	   		// create and initialize a Label
        CCLabelTTF *menuTitle=[CCLabelTTF labelWithString:@"Select Mode" fontName:@"Marker Felt" fontSize:64] ;
            
  
        // create and initialize a Label
        CCMenuItemLabel * survival = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:@"Survival" fontName:@"Marker Felt" fontSize:32] block:^(id sender){
            
            [[CCDirector sharedDirector] replaceScene:[[GameScene alloc] initWithGameMode:gameModeSurvival]];
        }];

        CCMenuItemLabel * waves = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:@"Campaign" fontName:@"Marker Felt" fontSize:32] block:^(id sender){
            
            [[CCDirector sharedDirector] replaceScene:[[GameScene alloc] initWithGameMode:gameModeLevels]];
        }];
        

        [CCMenuItemFont setFontSize:28];
        

       
       
       
       CCMenuItemLabel * menuitem = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:@"Menu" fontName:@"Marker Felt" fontSize:32] block:^(id sender){
           
           [[CCDirector sharedDirector] replaceScene:[MenuLayer scene]];
       }];
       
       

       CCMenu *menu = [CCMenu menuWithItems:survival,waves,menuitem, nil];

       [menu alignItemsInColumns:@2,@1, nil];

       [menu setPosition:CGPointMake( size.width/2, size.height/2-50 )];

       dlog(@"putting menu at %f,%f,%f,%f",size.height,menuitem.activeArea.size.height,menu.contentSize.height,menuitem.position.y);

       dlog(@"new y pos %f",-menu.position.y+menuitem.activeArea.size.height);

       menuitem.position=CGPointMake(size.width/2-menuitem.activeArea.size.width+25, -menu.position.y+menuitem.activeArea.size.height);

       menuTitle.position=CGPointMake(size.width/2,  size.height/2+50);

       // Add the menu to the layer
       [self addChild:menuTitle];
       [self addChild:menu];

   }
   return self;
}


-(void)dealloc{
    dealloclog(@"game selector dealloc");
}
@end
