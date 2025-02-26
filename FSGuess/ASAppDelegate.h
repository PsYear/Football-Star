//
//  ASAppDelegate.h
//  FootballStar
//
//  Created by CarlHwang on 13-9-23.
//  Copyright (c) 2013年 AfroStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXApi.h"
#import "MobClick.h"
#import "WeiboSDK.h"

#if __QQAPI_ENABLE__
#import "TencentOpenAPI/QQApiInterface.h"
#endif

@interface ASAppDelegate : UIResponder <UIApplicationDelegate, WXApiDelegate, QQApiInterfaceDelegate, UIAlertViewDelegate, WeiboSDKDelegate>
@property (nonatomic,retain) UIWindow *window;
@property (nonatomic,retain) UINavigationController *navigationController;
@end
