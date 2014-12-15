//
//  globalheader.h
//  rock
//
//  Created by Ryan on 7/19/12.
//  Copyright (c) 2014 Ryan Hughes. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG_MODE
#define _log( formatString, ... ) [NSString stringWithFormat:@"<%@:(%d)> %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(formatString), ##__VA_ARGS__] ]

#define dlog( formatString, ... ) NSLog(@"%@", _log(formatString, ##__VA_ARGS__) )

#define elog( formatString, ... ) NSLog(@"%@", _log(formatString, ##__VA_ARGS__) );\
[[[UIAlertView alloc] initWithTitle:@"Error" message:_log(formatString, ##__VA_ARGS__) delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] show]

#define ifelog(condition,formatString, ...) if(condition){elog(formatString, ##__VA_ARGS__);}

//this is used in location like main.c where logging to file and UIAlertView will not work
#define elog2( s, ... ) dlog( s, ##__VA_ARGS__ )

#define dealloclog( s, ... ) dlog( s, ##__VA_ARGS__ )
#define dealloclog2( s, ... ) dlog( s, ##__VA_ARGS__ )

#else
#define dealloclog( s, ... )
#define dealloclog2( s, ... )
#define dlog( s, ... )
#define elog( s, ... )
#define elog2( s, ... )
#define ifelog(condition,_s, ...)
#endif

#undef COCOS2D_DEBUG

