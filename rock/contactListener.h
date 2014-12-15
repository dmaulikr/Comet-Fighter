//
//  MenuLayer.m
//  rock
//
//  Created by Ryan Hughes on 7/11/12.
//  Copyright Ryan Hughes 2014. All rights reserved.
//
//  Based on code from 
//  http://www.raywenderlich.com/28604/how-to-create-a-breakout-game-with-box2d-and-cocos2d-2-x-tutorial-part-1



#import "Box2D/Box2D.h"
#import "cocos2d.h"
#import <vector>
#import <algorithm>
#import "GLES-Render.h"

//tags to define how to handle the collision
#define delneither 0
#define del1 1
#define del2 2
#define delboth 3
#define savecollision 4


//Adds the body to the vector if it does not already exist in the vector
#define ifaddtovector(body,vector)  if(std::find(vector.begin(), vector.end(), body)!=vector.end()){dlog(@"WARING: Body A will already be dealocated");}else {vector.push_back(body);}

struct B2BodyContact {
    b2Fixture *fixtureA;
    b2Fixture *fixtureB;
    bool operator==(const B2BodyContact& other) const
    {
        return (fixtureA == other.fixtureA) && (fixtureB == other.fixtureB);
    }
};

class ContactListener : public b2ContactListener {
    
public:
    
    std::vector<B2BodyContact>_contacts;
    std::vector<B2BodyContact>keepToDieContacts;
    
    ContactListener();
    ~ContactListener();
    
	virtual void BeginContact(b2Contact* contact);
	virtual void EndContact(b2Contact* contact);
	virtual void PreSolve(b2Contact* contact, const b2Manifold* oldManifold);    
	virtual void PostSolve(b2Contact* contact, const b2ContactImpulse* impulse);
    
};





@class thecontactlistener;
@protocol thecontactlistenerDelegate <NSObject>
@required
-(int)contactIsAliveWithSprite:(CCSprite *)s1 andSprite:(CCSprite *)s2;
-(int)contactfound:(CCSprite *)s1 s2:(CCSprite *)s2;
-(void)removesprite:(CCSprite *)sprite;
@end

@interface thecontactlistener : NSObject {
    b2World *_world;
    GLESDebugDraw *_debugDraw;
    ContactListener *_contactListener;
    BOOL _debugmode;
    CCArray * spritesToRemove;
    
    
    id  <thecontactlistenerDelegate> __unsafe_unretained delegate;
    
}

@property(nonatomic,unsafe_unretained) id <thecontactlistenerDelegate> delegate;

-(id)initWithDebugMode:(BOOL)debugmode andDelegate:(id)thedelegate;
-(void)addSprite:(CCSprite *)sprite withVertexs:(const b2Vec2* )vertexes vertexCount:(int)count;
-(void)removesprite:(CCSprite *)sprite;
-(void)tick:(ccTime)dt;
-(void)ifaddSprite:(CCSprite *)sprite toArray:(CCArray *)array;

-(void)draw;

@end