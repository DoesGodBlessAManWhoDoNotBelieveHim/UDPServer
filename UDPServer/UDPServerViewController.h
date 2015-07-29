//
//  ViewController.h
//  UDPServer
//
//  Created by wrt on 15/7/29.
//  Copyright (c) 2015年 wrtsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UDPServerTool.h"

#define key_CurtainsOpen            @"key_CurtainsOpen"
#define key_Brightness_Hall         @"key_Brightness_Hall"
#define key_Brightness_DinningRoom  @"key_Brightness_DinningRoom"
#define key_Pattern                 @"key_Pattern"

@interface UDPServerViewController : UIViewController<UDPServerToolDelegate>

- (IBAction)settings:(UIButton *)sender;

@property (strong, nonatomic) IBOutlet UITextField *portTextField;
@property (strong, nonatomic) IBOutlet UIView *bindingView;


- (IBAction)toBind:(UIButton *)sender;

@property (assign) BOOL curtainsOpen;
@property (assign) NSInteger brightnessOfLightInHall;
@property (assign) NSInteger brightnessOfLightInDinningRoom;
@property (assign) NSInteger pattern;

@property (strong, nonatomic) IBOutlet UIImageView *curtainsImageView;
@property (strong, nonatomic) IBOutlet UIImageView *hallLightImageView;
@property (strong, nonatomic) IBOutlet UIImageView *dinningRoomImageView;
@property (strong, nonatomic) IBOutlet UILabel *hallBrintness;
@property (strong, nonatomic) IBOutlet UILabel *dinningRoomBrightness;
@end

