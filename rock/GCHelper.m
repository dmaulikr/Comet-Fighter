//
//  GCHelper.m
//  CatRace
//
//  Created by Ray Wenderlich on 4/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GCHelper.h"

#import "AppDelegate.h"
@implementation GCHelper
@synthesize gameCenterAvailable;
@synthesize presentingViewController;
@synthesize match;
@synthesize delegate;

#pragma mark Initialization

static GCHelper *sharedHelper = nil;
+ (GCHelper *) sharedInstance {
    if (!sharedHelper) {
        sharedHelper = [[GCHelper alloc] init];
    }
    return sharedHelper;
}

- (BOOL)isGameCenterAvailable {
	// check for presence of GKLocalPlayer API
	Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
	
	// check if the device is running iOS 4.1 or later
	NSString *reqSysVer = @"4.1";
	NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
	BOOL osVersionSupported = ([currSysVer compare:reqSysVer 
                                           options:NSNumericSearch] != NSOrderedAscending);
	
	return (gcClass && osVersionSupported);
}

- (id)init {
    if ((self = [super init])) {
        gameCenterAvailable = [self isGameCenterAvailable];
        if (gameCenterAvailable) {
            NSNotificationCenter *nc = 
            [NSNotificationCenter defaultCenter];
            [nc addObserver:self 
                   selector:@selector(authenticationChanged) 
                       name:GKPlayerAuthenticationDidChangeNotificationName 
                     object:nil];
        }
    }
    return self;
}

#pragma mark Internal functions

- (void)authenticationChanged {    
    
    if ([GKLocalPlayer localPlayer].isAuthenticated && !userAuthenticated) {
       dlog(@"Authentication changed: player authenticated.");
       userAuthenticated = TRUE;           
    } else if (![GKLocalPlayer localPlayer].isAuthenticated && userAuthenticated) {
       dlog(@"Authentication changed: player not authenticated");
       userAuthenticated = FALSE;
    }
                   
}

#pragma mark User functions

- (void)authenticateLocalUser {
    
    if (!gameCenterAvailable) return;
    
    dlog(@"Authenticating local user...");
    if ([GKLocalPlayer localPlayer].authenticated == NO) {
        
        GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
        
        if ([localPlayer respondsToSelector:@selector(setAuthenticateHandler:)]) {
            dlog(@"User is running iOS 6");
            [localPlayer setAuthenticateHandler:(^(UIViewController* viewcontroller, NSError *error) {
                
                
                if([GKLocalPlayer localPlayer].isAuthenticated)
                {
                    dlog(@"auto authentication");
                }
                else if(viewcontroller) {
                    dlog(@"manaul authentication!");

                    //present the login form
                    [[CCDirector sharedDirector] presentViewController:viewcontroller animated:NO completion:nil];
                }
                else{
                    
                    // not logged in
                    dlog(@"no authentication!");
                    
                }
                
                
            })];
        }
        else if ([localPlayer respondsToSelector:@selector(authenticateWithCompletionHandler:)]){
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError * e){
                dlog(@"old authentication = %@",e);
            }];
            #pragma clang diagnostic pop
        }
        else{
            elog(@"Error: Can't find authentication method");
        }
        
        
    } else {
        dlog(@"Already authenticated");
    }
}


- (void)findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers viewController:(UIViewController *)viewController delegate:(id<GCHelperDelegate>)theDelegate {
    
    if (!gameCenterAvailable) return;
    
    matchStarted = NO;
    self.match = nil;
    self.presentingViewController = viewController;
    delegate = theDelegate;
    [presentingViewController dismissViewControllerAnimated:NO completion:nil];
    
    GKMatchRequest *request = [[GKMatchRequest alloc] init] ;
    request.minPlayers = minPlayers;     
    request.maxPlayers = maxPlayers;
    
    GKMatchmakerViewController *mmvc = [[GKMatchmakerViewController alloc] initWithMatchRequest:request];    
    mmvc.matchmakerDelegate = self;
    
    //This will not work for iOS < 6
    [presentingViewController presentViewController:mmvc animated:YES completion:nil];
        
}

#pragma mark GKMatchmakerViewControllerDelegate

// The user has cancelled matchmaking
- (void)matchmakerViewControllerWasCancelled:(GKMatchmakerViewController *)viewController {
    [presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

// Matchmaking has failed with an error
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFailWithError:(NSError *)error {
    [presentingViewController dismissViewControllerAnimated:YES completion:nil];
    dlog(@"Error finding match: %@", error.localizedDescription);    
}

// A peer-to-peer match has been found, the game should start
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindMatch:(GKMatch *)theMatch {
    [presentingViewController dismissViewControllerAnimated:YES completion:nil];
    self.match = theMatch;
    match.delegate = self;
    if (!matchStarted && match.expectedPlayerCount == 0) {
        dlog(@"Ready to start match!");
    }
}

#pragma mark GKMatchDelegate

// The match received data sent from the player.
- (void)match:(GKMatch *)theMatch didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID {
    
    if (match != theMatch) return;
    
    [delegate match:theMatch didReceiveData:data fromPlayer:playerID];
}

// The player state changed (eg. connected or disconnected)
- (void)match:(GKMatch *)theMatch player:(NSString *)playerID didChangeState:(GKPlayerConnectionState)state {
    
    if (match != theMatch) return;
    
    switch (state) {
        case GKPlayerStateConnected: 
            // handle a new player connection.
            dlog(@"Player connected!");
            
            if (!matchStarted && theMatch.expectedPlayerCount == 0) {
                dlog(@"Ready to start match!");
            }
            
            break; 
        case GKPlayerStateDisconnected:
            // a player just disconnected. 
            dlog(@"Player disconnected!");
            matchStarted = NO;
            [delegate matchEnded];
            break;
    }                 
    
}

// The match was unable to connect with the player due to an error.
- (void)match:(GKMatch *)theMatch connectionWithPlayerFailed:(NSString *)playerID withError:(NSError *)error {
    
    if (match != theMatch) return;
    
    dlog(@"Failed to connect to player with error: %@", error.localizedDescription);
    matchStarted = NO;
    [delegate matchEnded];
}

// The match was unable to be established with any players due to an error.
- (void)match:(GKMatch *)theMatch didFailWithError:(NSError *)error {
    
    if (match != theMatch) return;
    
    dlog(@"Match failed with error: %@", error.localizedDescription);
    matchStarted = NO;
    [delegate matchEnded];
}





+(void)GCleaderboard{
    
    //this has a check in it so it only authenticates if ur not already authenticated
    [[GCHelper sharedInstance] authenticateLocalUser];
    
    
    if (![GKLocalPlayer localPlayer].isAuthenticated) {
        //user is not logged into game center
        [[[UIAlertView alloc] initWithTitle:@"Not Logged into Game Center" message:@"You must log into Game Center to use the leaderboard." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] show];
        return;
    }
    
    
    //load leaderboard
    GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
    leaderboardViewController.leaderboardDelegate = [GCHelper sharedInstance];
    
    [GCHelper safePresentViewController:leaderboardViewController animated:YES completion:nil];
}

+(void)safePresentViewController:(UIViewController *)viewControllerToPresent animated: (BOOL)flag completion:(void (^)(void))completion{
    
    UINavigationController *app = [(AppController*) [[UIApplication sharedApplication] delegate] navController];
    
    if ([app respondsToSelector:@selector(presentViewController:animated:completion:)]) {
        dlog(@"preseting new view controller");
        [app presentViewController:viewControllerToPresent animated:flag completion:completion];
    }
    else if ([app respondsToSelector:@selector(presentModalViewController:animated:)]){
        dlog(@"preseting old view controller");
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [app presentModalViewController:viewControllerToPresent animated:flag];
#pragma clang diagnostic pop

        
    }
    else{
        elog(@"Error: Can't find view controller");
    }
    
}
-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController {
    
    UINavigationController *app = [(AppController*) [[UIApplication sharedApplication] delegate] navController];
    
    if ([app respondsToSelector:@selector(presentViewController:animated:completion:)]) {
        [app dismissViewControllerAnimated:YES completion:nil];
    }
    else if ([app respondsToSelector:@selector(dismissModalViewControllerAnimated:)]){
        dlog(@"Error: Can't find view controller");
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [app dismissModalViewControllerAnimated:YES];
#pragma clang diagnostic pop
    }
    else{
        elog(@"Error: Can't find view controller");
    }
    
}
@end
