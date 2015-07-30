//
//  ViewController.m
//  UDPServer
//
//  Created by wrt on 15/7/29.
//  Copyright (c) 2015年 wrtsoft. All rights reserved.
//

#import "UDPServerViewController.h"

@interface UDPServerViewController ()

@end

@implementation UDPServerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [UDPServerTool shareInstance].delegate = self;
    
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self updateView];
}


- (IBAction)toBind:(UIButton *)sender {
    
    NSError *error;
    [[UDPServerTool shareInstance]startStop:_portTextField.text.integerValue withError:&error];
    
    if (error) {
//        NSAlert *alert = [NSAlert alertWithError:error];
//        [alert beginSheetModalForWindow:self.view.window completionHandler:nil];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"绑定失败" message:[NSString stringWithFormat:@"%@",error.description] delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles: nil];
        [alert show];
    }
    
    _portTextField.enabled = ![[UDPServerTool shareInstance] isRunning];
}
- (void)updateView{
    _curtainsOpen = [[[NSUserDefaults standardUserDefaults]objectForKey:key_CurtainsOpen] integerValue]==1;
    NSString *brightnessOfLightInHall = [[NSUserDefaults standardUserDefaults]objectForKey:key_Brightness_Hall];
    if (!brightnessOfLightInHall || [brightnessOfLightInHall isEqualToString:@""]) {
        brightnessOfLightInHall = @"0";
    }
    if (![brightnessOfLightInHall isEqualToString:@"0"]) {
        brightnessOfLightInHall = [brightnessOfLightInHall stringByAppendingString:@"0"];
    }
    NSString *brightnessOfLightInDinningRoom = [[NSUserDefaults standardUserDefaults]objectForKey:key_Brightness_DinningRoom];
    if (!brightnessOfLightInDinningRoom || [brightnessOfLightInDinningRoom isEqualToString:@""]) {
        brightnessOfLightInDinningRoom = @"0";
    }
    if (![brightnessOfLightInDinningRoom isEqualToString:@"0"]) {
        brightnessOfLightInDinningRoom = [brightnessOfLightInDinningRoom stringByAppendingString:@"0"];
    }
    
    _hallBrintness.text =brightnessOfLightInHall;
    _dinningRoomBrightness.text = brightnessOfLightInDinningRoom;
    
    [_hallLightImageView setImage:[UIImage imageNamed:brightnessOfLightInHall]];
    [_dinningRoomImageView setImage:[UIImage imageNamed:brightnessOfLightInDinningRoom]];
    
    [_curtainsImageView setImage:[UIImage imageNamed:_curtainsOpen?@"0-100":@"0-0"]];
    
}

#pragma mark =======TCPServer Delegate=========
- (void)didReceivedCurtainsOpenOrder:(BOOL)openOrder withBuilding:(NSString *)bulding floor:(NSString *)floor room:(NSString *)room number:(NSString *)number{
    if (openOrder) {
        NSLog(@"开启窗帘");
        [_curtainsImageView setImage:[UIImage imageNamed:@"0-100.png"]];
        [[NSUserDefaults standardUserDefaults]setObject:@(1) forKey:key_CurtainsOpen];
    }
    else{
        NSLog(@"关闭窗帘");
        [[NSUserDefaults standardUserDefaults]setObject:@(0) forKey:key_CurtainsOpen];
        [_curtainsImageView setImage:[UIImage imageNamed:@"0-0.png"]];
        
    }
    [[NSUserDefaults standardUserDefaults]synchronize];
    //发送成功回馈
    [[UDPServerTool shareInstance] sendResultOfCurtainsOpen:openOrder Success:YES WithBuilding:bulding floor:floor room:room number:number];
}

- (void)didReceivedCurtainsStatusSearchOrder{
    NSLog(@"查询窗帘");
    _curtainsOpen = [[[NSUserDefaults standardUserDefaults]objectForKey:key_CurtainsOpen] integerValue]==1;
    //发送状态回馈
    [[UDPServerTool shareInstance] sendResultOfCurtainsSearch:@[[NSNumber numberWithBool:_curtainsOpen]]];
}
//
- (void)didReceivedLightsCtrolOrderWithBrightness:(NSString *)brightness building:(NSString *)bulding floor:(NSString *)floor room:(NSString *)room number:(NSString *)number{
    NSLog(@"控制灯光");
    if ([number integerValue]==1) {
        _hallBrintness.text = [NSString stringWithFormat:@"%li",(long)brightness.integerValue*10];
        [_hallLightImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",_hallBrintness.text]]];
        [[NSUserDefaults standardUserDefaults]setObject:brightness forKey:key_Brightness_Hall];
        
    }
    else{
        _dinningRoomBrightness.text = [NSString stringWithFormat:@"%li",brightness.integerValue*10];
        [_dinningRoomImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",_dinningRoomBrightness.text]]];
        [[NSUserDefaults standardUserDefaults]setObject:brightness forKey:key_Brightness_DinningRoom];
    }
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    //发送成功回馈
    if (brightness.integerValue==10) {
        brightness = @"0A";
    }
    [[UDPServerTool shareInstance]sendResultOfLightsCtrolSuccess:YES WithBrightness:brightness building:bulding floor:floor room:room number:number];
    
}
- (void)didReceivedLightsStatusSearchOrder{
    NSLog(@"查询扥光");
    
    _brightnessOfLightInHall = [[[NSUserDefaults standardUserDefaults]objectForKey:key_Brightness_Hall] integerValue];
    _brightnessOfLightInDinningRoom = [[[NSUserDefaults standardUserDefaults]objectForKey:key_Brightness_DinningRoom] integerValue];
    //发送灯光信息回馈
    [[UDPServerTool shareInstance]sendResultOfLightsSearch:@[@(_brightnessOfLightInHall),@(_brightnessOfLightInDinningRoom)]];
}
//
- (void)didReceivedStoryEnabelOrderWithPattern:(NSString *)pattern building:(NSString *)bulding floor:(NSString *)floor room:(NSString *)room{
    NSLog(@"开启模式");
    //在家，全开，外出，全关
    if (pattern.integerValue==1) {//在家
        NSString *str = @"100";
        _hallBrintness.text = str;
        _hallLightImageView.image = [UIImage imageNamed:str];
        [[NSUserDefaults standardUserDefaults]setObject:@"10" forKey:key_Brightness_Hall];
        
        _dinningRoomBrightness.text = str;
        _dinningRoomImageView.image = [UIImage imageNamed:str];
        [[NSUserDefaults standardUserDefaults]setObject:@"10" forKey:key_Brightness_DinningRoom];
        
        NSString *iamgeName = [NSString stringWithFormat:@"0-100"];
        _curtainsImageView.image = [UIImage imageNamed:iamgeName];
        [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:key_CurtainsOpen];
        [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:key_Pattern];
    }
    else if (pattern.integerValue==2){//外出
        NSString *str = @"0";
        _hallBrintness.text = str;
        _hallLightImageView.image = [UIImage imageNamed:str];
        [[NSUserDefaults standardUserDefaults]setObject:str forKey:key_Brightness_Hall];
        
        _dinningRoomBrightness.text = str;
        _dinningRoomImageView.image = [UIImage imageNamed:str];
        [[NSUserDefaults standardUserDefaults]setObject:str forKey:key_Brightness_DinningRoom];
        
        NSString *iamgeName = [NSString stringWithFormat:@"0-0"];
        _curtainsImageView.image = [UIImage imageNamed:iamgeName];
        [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:key_CurtainsOpen];
        [[NSUserDefaults standardUserDefaults]setObject:@"2" forKey:key_Pattern];
    }
    
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    //反馈信息
    [[UDPServerTool shareInstance]sendResultOfStoryEnabelSuccess:YES WithPattern:pattern building:bulding floor:floor room:room];
}
- (void)didReceivedStoriesSearchOrder{
    NSLog(@"模式查询");
    _pattern = [[[NSUserDefaults standardUserDefaults]objectForKey:key_Pattern] integerValue];
    //
    [[UDPServerTool shareInstance]sendResultOfStorySearch:[[NSUserDefaults standardUserDefaults]objectForKey:key_Pattern]];
}




- (IBAction)settings:(UIButton *)sender {
    
    _bindingView.hidden = !_bindingView.hidden;
}


@end
