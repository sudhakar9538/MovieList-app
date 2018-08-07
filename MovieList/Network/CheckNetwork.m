//
//  CheckNetwork.m
//  iphone.network1
//
//  Created by wangjun on 10-12-13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CheckNetwork.h"
#import "Reachability.h"
@implementation CheckNetwork
+(BOOL)isExistenceNetwork
{
	BOOL isExistenceNetwork;
	Reachability *r = [Reachability reachabilityWithHostName:@"www.apple.com"];
    switch ([r currentReachabilityStatus])
    {
        case NotReachable:
			isExistenceNetwork=FALSE;
            break;
        case ReachableViaWWAN:
			isExistenceNetwork=TRUE;
            break;
        case ReachableViaWiFi:
			isExistenceNetwork=TRUE;      
            break;
    }
	if (!isExistenceNetwork)
    {
        NSString *preferredLang = [[NSLocale preferredLanguages] objectAtIndex:0];
        
        NSString *title=@"Warning";
        NSString *msg=@"Network does not exist";
        NSString *button=@"OK";
        
        if([preferredLang isEqualToString:@"fr"]){
            title=@"Attention";
            msg=@"Réseau n'existe pas";
            button=@"OUI";
        }
        
//        UIAlertView *myalert =[[UIAlertView alloc]initWithTitle:title message:msg delegate:self cancelButtonTitle:button otherButtonTitles:nil];
//        [myalert show];
	}
	return isExistenceNetwork;
}
@end
