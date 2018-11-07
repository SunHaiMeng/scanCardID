//
//  ViewController.m
//  scanCardIDVC
//
//  Created by apple on 2018/11/7.
//  Copyright © 2018年 GXT. All rights reserved.
//

#import "ViewController.h"
#import "MSRegisterViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIButton *testBtn = [[UIButton alloc]init];
    testBtn.frame = CGRectMake(120, 200, 100, 40);
    
    [testBtn setTitle:@"扫描身份证" forState:(UIControlStateNormal)];
    [testBtn setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
    [testBtn addTarget:self action:@selector(onScan) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:testBtn];
}
-(void)onScan{
    [self presentViewController:[[MSRegisterViewController alloc]init] animated:YES completion:^{
        
    }];
}

@end
