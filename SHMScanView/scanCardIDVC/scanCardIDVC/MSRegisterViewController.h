//
//  MSRegisterViewController.h
//  MinSu
//
//  Created by apple on 2017/2/7.
//  Copyright © 2017年 GXT. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef  void (^ReturnCardBlock)(NSString *str,NSData *cardI);
@interface MSRegisterViewController : UIViewController
@property (nonatomic,copy)ReturnCardBlock returnBlock;


@end
