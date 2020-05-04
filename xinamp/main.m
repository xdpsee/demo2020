//
//  main.m
//  xinamp
//
//  Created by chen zhenhui on 2020/3/30.
//  Copyright © 2020 chen zhenhui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "PlatformOSInit.h"

int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;

    @autoreleasepool {
        platformOSInit();
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }

    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
