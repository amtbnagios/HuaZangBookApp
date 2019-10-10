//
//  HZAppDelegate+Application.m
//  HuaZang
//
//  Created by BIN on 2019/4/23.
//  Copyright © 2019 Neusoft. All rights reserved.
//

#import "HZAppDelegate+Application.h"
#import "HZBaseNavigationViewController.h"
#import "HZBHomePage.h"
#import <AVFoundation/AVFoundation.h>
@implementation HZAppDelegate (Application)
- (void)initApplication {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = UIColor.whiteColor;
    HZBHomePage * homePage= [[HZBHomePage alloc] init];
    HZBaseNavigationViewController * rootNav = [[HZBaseNavigationViewController alloc] initWithRootViewController:homePage];
    [self.window setRootViewController:rootNav];
    [self.window makeKeyAndVisible];

    [self initDomain];
    [self initBackGroundPlay];
}

- (void)initDomain {
    RemoteUtil * util = [RemoteUtil new];
    util.hudType = RemoteHudTypeNone;
    NSString * URLString = [NSString stringWithFormat:@"%@%@",WapDomain,@"ibook_config"];
    [util remoteURL:URLString method:RemoteMehodTypeGet param:nil complete:^(BOOL success, NSDictionary * _Nonnull info) {
        NSString * domain = info[@"domain"];
        NSString * download = info[@"download"];
        [[NSUserDefaults standardUserDefaults] setObject:domain forKey:@"domainURLString"];
        [[NSUserDefaults standardUserDefaults] setObject:download forKey:@"downloadURLString"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
}

- (void)initBackGroundPlay {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [session setActive:YES error:nil];
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    if ([[window.rootViewController presentedViewController] isKindOfClass:NSClassFromString(@"AVFullScreenViewController")]) {
        return UIInterfaceOrientationMaskLandscape;
    }
    return   UIInterfaceOrientationMaskPortrait;
}

@end
