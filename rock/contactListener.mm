//
//  MenuLayer.m
//  rock
//
//  Created by Ryan Hughes on 7/11/12.
//  Copyright Ryan Hughes 2014. All rights reserved.
//
//  Based on code from 
//  http://www.raywenderlich.com/28604/how-to-create-a-breakout-game-with-box2d-and-cocos2d-2-x-tutorial-part-1


#import "contactListener.h"


ContactListener::ContactListener() : _contacts() {
}

ContactListener::~ContactListener() {
}

void ContactListener::BeginContact(b2Contact* contact) {
    B2BodyContact theContact = { contact->GetFixtureA(), contact->GetFixtureB() };
    _contacts.push_back(theContact);
}
void ContactListener::EndContact(b2Contact* contact) {

    B2BodyContact theContact = { contact->GetFixtureA(), contact->GetFixtureB() };
    std::vector<B2BodyContact>::iterator pos;
    pos = std::find(_contacts.begin(), _contacts.end(), theContact);

    //each tick, _contacts is emptied and this contact should not be in _contacts
    if (pos != _contacts.end()) {
        dlog(@"ERROR: contact was in _contacts, (should have been erased in tick)");
        _contacts.erase(pos);
    }
    
    //if the contact is supposed to be kept until the sprites are not contacting, delete it here
    pos = std::find(keepToDieContacts.begin(), keepToDieContacts.end(), theContact);
    if (pos != keepToDieContacts.end()) {
        dlog(@"INFO: erased contact from keep to die contacts (%i elements left)",(int)keepToDieContacts.size());
        keepToDieContacts.erase(pos);
    }
}

void ContactListener::PreSolve(b2Contact* contact, const b2Manifold* oldManifold) {
}

void ContactListener::PostSolve(b2Contact* contact, const b2ContactImpulse* impulse) {
}




@implementation thecontactlistener

@synthesize delegate;
-(void)dealloc{
    dealloclog(@"the contact listener dealloc called");
}

-(id)initWithDebugMode:(BOOL)debugmode andDelegate:(id)thedelegate{
    self=[super init];
    if (self) {
        
        spritesToRemove=[CCArray array];
        delegate=thedelegate;
        
        // Create b2 world
        b2Vec2 gravity = b2Vec2(0.0f, 0.0f);
        bool doSleep = false;
        
        //create the box 2d world
        _world = new b2World(gravity);
        _world->SetAllowSleeping(doSleep);
        _debugmode=debugmode;
        

        if (debugmode) {
            dlog(@"enabling debug polygons");

            // Enable debug draw
            _debugDraw = new GLESDebugDraw( 1 );
            _world->SetDebugDraw(_debugDraw);
            uint32 flags = 0;
            flags += b2Draw::e_shapeBit;
            _debugDraw->SetFlags(flags);
        }
        
        
        // Create contact listener
        _contactListener = new ContactListener();
        _world->SetContactListener(_contactListener);
        
        
    }
    return self;
}

//add a sprite to the box 2d world
-(void)addSprite:(CCSprite *)sprite withVertexs:(const b2Vec2* )vertexes vertexCount:(int)count{
    
    b2BodyDef spriteBodyDef;
    spriteBodyDef.type = b2_dynamicBody;
    spriteBodyDef.position.Set(sprite.position.x, sprite.position.y);
    
    spriteBodyDef.userData = (__bridge void*) sprite;
    
    b2Body *spriteBody = _world->CreateBody(&spriteBodyDef);
    
    b2PolygonShape spriteShape;
    
    spriteShape.Set(vertexes, count);
    b2FixtureDef spriteShapeDef;
    spriteShapeDef.shape = &spriteShape;
    spriteShapeDef.density = 10.0;
    spriteShapeDef.isSensor = true;
    
    spriteBody->CreateFixture(&spriteShapeDef);
    spriteBody->SetAwake(false);
    
    
}

//remove a sprite from the box 2d world
-(void)removesprite:(CCSprite *)sprite{
    // Loop through all of the Box2D bodies in our Box2D world...
    // We're looking for the Box2D body corresponding to the sprite.
    for(b2Body *b =_world->GetBodyList(); b; b=b->GetNext()) {
        
        // We know that the user data is a sprite since we set
        // it that way, so cast it...
        CCSprite *curSprite = (__bridge CCSprite *) b->GetUserData();
        
        // If the sprite for this body is the same as our current
        // sprite, we've found the Box2D body we're looking for!
        if (sprite == curSprite) {
            _world->DestroyBody(b);
            return;
        }
    }
    dlog(@"ERROR: could not find sprite %@ in box2d world",sprite);
}



-(void)ifaddSprite:(CCSprite *)sprite toArray:(CCArray *)array{
    if (![array containsObject:sprite]) {
        [array addObject:sprite];
    }
}


-(void)tick:(ccTime)dt{
    // Updates the physics simulation for 10 iterations for velocity/position
    _world->Step(dt, 10, 10);
    
    // Loop through all of the Box2D bodies in our Box2D world..
    for(b2Body *b = _world->GetBodyList(); b; b=b->GetNext()) {          
            
        // We know that the user data is a sprite since we set
        // it that way, so cast it...
        CCSprite *sprite = (__bridge CCSprite *) b->GetUserData();
        
        // Convert the Cocos2D position/rotation of the sprite to the Box2D position/rotation
        b2Vec2 b2Position = b2Vec2(sprite.position.x,sprite.position.y);
        float32 b2Angle = -1 * CC_DEGREES_TO_RADIANS(sprite.rotation);
        
        // Update the Box2D position/rotation to match the Cocos2D position/rotation
        b->SetTransform(b2Position, b2Angle);
    }

    //If one body collided with two other bodies in the same frame, it will be in the _contacts list twice.
    //If the bodies (and the sprites) were removed and deallocated when they were discovered in this loop, any body that appeared twice would
    //cause the game to crash the second time it was processed. (Trying to access a deallocated sprite)
    //So save all the sprites to a list, and make sure they are only deallocated once. 
    [spritesToRemove removeAllObjects];
    std::vector<b2Body *>bodiesToRemove; 
    std::vector<B2BodyContact>::iterator pos;


    // Loop through all of the box2d bodies that are currently colliding, that we have
    // gathered with our custom contact listener...
    for(pos = _contactListener->_contacts.begin(); pos != _contactListener->_contacts.end(); ++pos) {
        B2BodyContact contact = *pos;
        
        // Get the box2d bodies for each object
        b2Body *bodyA = contact.fixtureA->GetBody();
        b2Body *bodyB = contact.fixtureB->GetBody();
            
        // Get the sprites that corrospond with the box 2d bodies
        CCSprite * spriteA = (__bridge CCSprite *) bodyA->GetUserData();
        CCSprite * spriteB = (__bridge CCSprite *) bodyB->GetUserData();


        //call the objective-c code to determine which (if any) sprites/bodies should be removed
        switch ([delegate contactfound:spriteA s2:spriteB]) {

            case delneither:
                break;

            case del1:
                ifaddtovector(bodyA, bodiesToRemove);
                [self ifaddSprite:spriteA toArray:spritesToRemove];                    
                break;

            case del2:
                ifaddtovector(bodyB, bodiesToRemove);
                [self ifaddSprite:spriteB toArray:spritesToRemove];
                
                break;

            case delboth:
                ifaddtovector(bodyA, bodiesToRemove);
                [self ifaddSprite:spriteA toArray:spritesToRemove];
                ifaddtovector(bodyB, bodiesToRemove);
                [self ifaddSprite:spriteB toArray:spritesToRemove];
                break;
            case savecollision:
                _contactListener->keepToDieContacts.push_back(contact);
            default:
                break;
        }

        if (bodiesToRemove.size()!=spritesToRemove.count) {
            dlog(@"ERROR: bodiesToRemove.size (%li)!=spritesToRemove.count (%i)",bodiesToRemove.size(),spritesToRemove.count);
        }
    }


    //loop through contacts that are kept until they end
    //Eg, player contact with rock when player has just re spawned and is invincible, etc
    for(pos = _contactListener->keepToDieContacts.begin(); pos != _contactListener->keepToDieContacts.end(); ++pos) {
        B2BodyContact contact = *pos;
        
        b2Body *bodyA = contact.fixtureA->GetBody();
        b2Body *bodyB = contact.fixtureB->GetBody();        
        
        CCSprite * spriteA = (__bridge CCSprite *) bodyA->GetUserData();
        CCSprite * spriteB = (__bridge CCSprite *) bodyB->GetUserData();
        
        
        switch ([delegate contactIsAliveWithSprite:spriteA andSprite:spriteB]) {
            case delneither:
                dlog(@"removed pos from keep to die contacts");
                _contactListener->keepToDieContacts.erase(pos);
                --pos;
                break;
            case del1:

                ifaddtovector(bodyA, bodiesToRemove);
                [self ifaddSprite:spriteA toArray:spritesToRemove];
                _contactListener->keepToDieContacts.erase(pos);
                --pos;
                
                break;
            case del2:

                ifaddtovector(bodyB, bodiesToRemove);
                [self ifaddSprite:spriteB toArray:spritesToRemove];
                
                _contactListener->keepToDieContacts.erase(pos);
                --pos;

                break;
            case delboth:

                ifaddtovector(bodyB, bodiesToRemove);
                [self ifaddSprite:spriteB toArray:spritesToRemove];
                

                ifaddtovector(bodyA, bodiesToRemove);
                [self ifaddSprite:spriteA toArray:spritesToRemove];
                
                _contactListener->keepToDieContacts.erase(pos);
                --pos;
                break;
            case savecollision:
                break;
            default:
                break;
        }
    
    }
    _contactListener->_contacts.clear();
    
    // Loop through all of the box2d bodies we want to remove
    std::vector<b2Body *>::iterator pos2;
    for(pos2 = bodiesToRemove.begin(); pos2 != bodiesToRemove.end(); ++pos2) {
        b2Body *body = *pos2;     
        
        // Destroy the Box2D body as well
        _world->DestroyBody(body);
    }

    //remove the sprites as well
    if (spritesToRemove.count!=0) {
        
        for (CCSprite * sprite in spritesToRemove) {
            [delegate removesprite:sprite];
        }
    }

}

-(void) draw {
    
    if (_debugmode) {
        _world->DrawDebugData();	
    }
}
@end