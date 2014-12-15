//
//  main.m
//  rock
//
//  Created by Ryan Hughes on 7/11/12.
//  Copyright Ryan Hughes 2014. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TargetConditionals.h"
#define currVer @"1.0"

//Create random string with given length
NSString * randomStringWithLen(int thelen){
    NSMutableString *randomString= [NSMutableString stringWithCapacity: thelen];
    for (int i=0; i<thelen; i++) {
        [randomString appendFormat: @"%C", [@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789" characterAtIndex: arc4random()%62]];
    }
    return randomString;
}

// Catch Exceptions and send them to a Google App Engine server. The exception submitted in the URL to the server as query parameters.
// Now, I would use a server in the cloud, such as Amazon EC2, and submit the Exceptions through a tcp connection.


// Internal error reporting. 
// This does not catch all exceptions - it only catches ones that were thrown (eg. dosen't catch EXC_BAD_ACCESS)
void uncaughtExceptionHandler(NSException *exception) {
    
    NSArray * stackSymbols=[exception callStackSymbols];
    NSArray * stackAddrs=[exception callStackReturnAddresses];
    
    NSString * fullcrash=[NSString stringWithFormat:@"%@:%@\n\n%@\nAddrs:\n%@",[exception name],[exception reason],[stackSymbols componentsJoinedByString:@"\n"],[stackAddrs description]];
    
    NSLog(@"CRASH: %@", fullcrash);
    
#if !(TARGET_IPHONE_SIMULATOR)
    
    //read file
    NSString * path=[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"ERROR.txt"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //load more log from file
    NSString * moredata=@"";
    if ([fileManager fileExistsAtPath:path]) {
        moredata=[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    }
    
    if ((![moredata isEqualToString:@""]) && moredata!=nil) {
        fullcrash=[fullcrash stringByAppendingFormat:@"\n\nERROR.txt:\n%@",moredata];
    }
    
    //compress crash attempt
    fullcrash=[fullcrash stringByReplacingOccurrencesOfString:@"     " withString:@"\t"];
    
    NSMutableArray * reportlist=[NSMutableArray arrayWithObjects:fullcrash, nil];
    
    NSString * crashId=nil;
    
    for (int i=0; i<(int)[reportlist count]; i++) {
        NSString * aCrash=[reportlist objectAtIndex:i];
        NSString * urlcrash=[aCrash stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];

        // Limit urls at 2000 characters
        // If over, send as multiple requests
        if (urlcrash.length>1900) {
            
            //make a request uuid so the server can piece them together
            if (!crashId) {
                crashId=randomStringWithLen(40);
            }
            
            
            NSString * cutcrash1=[aCrash substringToIndex:aCrash.length/2];
            NSString * cutcrash2=[aCrash substringFromIndex:aCrash.length/2];
            
            [reportlist replaceObjectAtIndex:i withObject:cutcrash1];
            [reportlist insertObject:cutcrash2 atIndex:i+1];
            
            //retest the new string that was just created in case it needs to be cut again
            i--;
        }
        
    }
    int count=0;
    for (NSString * reportPart in reportlist) {
        count++;
        
        
        NSString * crashPart=[reportPart stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
        
        NSString * sendstring;
        if (crashId==nil) {
            sendstring=[NSString stringWithFormat:@"http://rysquash-server.appspot.com/rock/%@/?error=%@",currVer, crashPart];
        }
        else{
            sendstring=[NSString stringWithFormat:@"http://rysquash-server.appspot.com/rock/%@/?part=%i&crashId=%@&error=%@",currVer,count,crashId,crashPart];
            
        }
        dlog(@"%@", sendstring);
        dlog(@"sendsting.len= %i\n",sendstring.length);
        
        
        NSError * er;
        NSMutableURLRequest * thereq=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:sendstring]];
        thereq.timeoutInterval=4.6;

       
        //cant use asynchronous because main thread must be blocked
        [NSURLConnection sendSynchronousRequest:thereq returningResponse:nil error:&er];
        dlog(@"Done.");
        if (er==nil) {
            elog2(@"%@",er);
            

            //write error to file for debugging
            NSString * path2=[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"ERROR2.txt"];
            NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:path2];
            if(fileHandle == nil) {
                [[NSFileManager defaultManager] createFileAtPath:path2 contents:nil attributes:nil];
                fileHandle = [NSFileHandle fileHandleForWritingAtPath:path2];
            }
            [fileHandle seekToEndOfFile];
            [fileHandle writeData:[[NSString stringWithFormat:@"-----CRASH (%f)---- \n %@\n----CRASH END ----",[[NSDate date] timeIntervalSince1970], fullcrash] dataUsingEncoding:NSUTF8StringEncoding]];
            [fileHandle closeFile];


            //clear file
            [fileManager removeItemAtPath:path error:nil];
            

        }
        else{
            
            //write error to file
            NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:path];
            if(fileHandle == nil) {
                [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
                fileHandle = [NSFileHandle fileHandleForWritingAtPath:path];
            }
            [fileHandle seekToEndOfFile];
            [fileHandle writeData:[[NSString stringWithFormat:@"-----CRASH (%f)---- \n %@\n----CRASH END ----",[[NSDate date] timeIntervalSince1970], fullcrash] dataUsingEncoding:NSUTF8StringEncoding]];
            [fileHandle closeFile];
            
        }
    }
#endif
}


int main(int argc, char *argv[]) {
    
    @autoreleasepool {
        
#if !(TARGET_IPHONE_SIMULATOR)
        if (YES) {
            NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
        }
#endif
        return UIApplicationMain(argc, argv, nil, @"AppController");
        
    }
}
