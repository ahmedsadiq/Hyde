//
//  SVProgressHUDCustom.m
//  HydePark
//
//  Created by Apple on 29/12/2015.
//  Copyright (c) 2015 TxLabz. All rights reserved.
//


#import "SVProgressHUD.h"
#import "SVProgressHUDCustom.h"
#import "Constants.h"
@implementation SVProgressHUDCustom
-(void)customProgressHUD{
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
    //grey color
    [SVProgressHUD setBackgroundColor:BlueThemeColor(241,245,248)];
    //[SVProgressHUD setBackgroundColor:[UIColor clearColor]];
    [SVProgressHUD setRingThickness:4];
    [SVProgressHUD setRingRadius:16];
    //Blue Color
    [SVProgressHUD setForegroundColor:BlueThemeColor(54,78,141)];
}
@end