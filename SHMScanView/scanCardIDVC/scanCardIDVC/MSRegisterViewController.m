//
//  MSRegisterViewController.m
//  MinSu
//
//  Created by apple on 2017/2/7.
//  Copyright © 2017年 GXT. All rights reserved.
//

#import "MSRegisterViewController.h"
#import <AVFoundation/AVFoundation.h>//原生二维码扫描必须导入这个框架
////判断iPhoneX
//#define IS_IPHONE_X ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)
////判断iPHoneXr
//#define IS_IPHONE_Xr ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)
////判断iPhoneXs
//#define IS_IPHONE_Xs ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)
////判断iPhoneXs Max
//#define IS_IPHONE_Xs_Max ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)
//
//#define k_Height_NavBar ((IS_IPHONE_X==YES || IS_IPHONE_Xr ==YES || IS_IPHONE_Xs== YES || IS_IPHONE_Xs_Max== YES) ? 88.0 : 64.0)
//默认字体颜色
#define defaultTextBtnColor [UIColor colorWithRed:24/255.0 green:74/255.0 blue:93/255.0 alpha:1.0]
#define SCREENWidth  [UIScreen mainScreen].bounds.size.width
//设备屏幕的宽度
#define SCREENHeight [UIScreen mainScreen].bounds.size.height
//设备屏幕的高度
#define UIBackColor [UIColor colorWithRed:135/255.f green:187/255.f blue:201/255.f alpha:1.f]
#define AUTOSCAN YES
@interface MSRegisterViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate,AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic,strong)AVCaptureSession *session;
@end

@implementation MSRegisterViewController{
    BOOL scanI;
    BOOL autoScanI;
    UIButton *scanBtn;
    
    NSString* result;
    UIView *scanWindow;
   
}
-(void)viewWillAppear:(BOOL)animated{
    
    [self setupScanWindowView];//设置扫描区域的视图
    //开始捕获
    [_session startRunning];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIBackColor;
    
   
    // Do any additional setup after loading the view.
    //标识扫描获取的状态
    if (AUTOSCAN) {
        autoScanI = YES;
    }else{
       scanI = NO;
    }
    
   
    
    
    [self setupMaskView];//设置扫描区域之外的阴影视图
   
    [self beginScanning];//开始扫

    
}
- (void)setupMaskView
{
    //设置统一的视图颜色和视图的透明度
    UIColor *color = [UIColor blackColor];
    float alpha = 0.7;
    
    //设置扫描区域外部上部的视图
    UIView *topView = [[UIView alloc]init];
    topView.frame = CGRectMake(0, 0, SCREENWidth,32);
    topView.backgroundColor = color;
    topView.alpha = alpha;
    
    //设置扫描区域外部左边的视图
    UIView *leftView = [[UIView alloc]init];
    leftView.frame = CGRectMake(0, topView.frame.size.height, 32,SCREENHeight-188);
    leftView.backgroundColor = color;
    leftView.alpha = alpha;
    
    //设置扫描区域外部右边的视图
    UIView *rightView = [[UIView alloc]init];
    rightView.frame = CGRectMake(SCREENWidth-32,topView.frame.size.height, 32,SCREENHeight-188);
    rightView.backgroundColor = color;
    rightView.alpha = alpha;
    
    //设置扫描区域外部底部的视图
    UIView *botView = [[UIView alloc]init];
    botView.frame = CGRectMake(0, SCREENHeight-156,SCREENWidth,42);
    botView.backgroundColor = color;
    botView.alpha = alpha;
    
    //将设置好的扫描二维码区域之外的视图添加到视图图层上
    [self.view addSubview:topView];
    [self.view addSubview:leftView];
    [self.view addSubview:rightView];
    [self.view addSubview:botView];
    
    UILabel *showLabel = [[UILabel alloc]init];
    showLabel.frame = CGRectMake(0, self.view.frame.size.height-40, SCREENWidth, 20);
    showLabel.text = @"扫描身份证";
    showLabel.textColor = defaultTextBtnColor;
    showLabel.font = [UIFont boldSystemFontOfSize:16];
    showLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:showLabel];
//    [showLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(self.view.mas_left);
//        make.right.mas_equalTo(self.view.mas_right);
//        make.top.mas_equalTo(self.view.mas_bottom).offset(-40);
//        make.height.mas_equalTo(@20);
//    }];
}



- (void)setupScanWindowView
{
    //设置扫描区域的位置(考虑导航栏和电池条的高度为64)
    scanWindow = [[UIView alloc]initWithFrame:CGRectMake(30,30,SCREENWidth-60,SCREENHeight-120-64)];
    scanWindow.clipsToBounds = YES;
    [self.view addSubview:scanWindow];
    //设置扫描背景图
    UIImageView *scanBackImage = [[UIImageView alloc]init];
    scanBackImage.image = [UIImage imageNamed:@"scanbackimage"];
    scanBackImage.frame = CGRectMake(0, 0, scanWindow.frame.size.width, scanWindow.frame.size.height);
    [scanWindow addSubview:scanBackImage];
    //设置扫描区域的动画效果
    CGFloat scanNetImageViewH = scanWindow.frame.size.height-20;
    CGFloat scanNetImageViewW = scanWindow.frame.size.width;
    UIImageView *scanNetImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"scan_net"]];
    scanNetImageView.frame = CGRectMake(0, -scanNetImageViewH, scanNetImageViewW, scanNetImageViewH);
    CABasicAnimation *scanNetAnimation = [CABasicAnimation animation];
    scanNetAnimation.keyPath =@"transform.translation.y";
    scanNetAnimation.byValue = @(scanWindow.frame.size.height-20);
    scanNetAnimation.duration = 1.0;
    scanNetAnimation.repeatCount = MAXFLOAT;
    [scanNetImageView.layer addAnimation:scanNetAnimation forKey:nil];
    [scanWindow addSubview:scanNetImageView];
    
    //设置扫描区域的四个角的边框
    CGFloat buttonWH = 25;
    UIButton *topLeft = [[UIButton alloc]initWithFrame:CGRectMake(0,0, buttonWH, buttonWH)];
    [topLeft setImage:[UIImage imageNamed:@"scan_1"]forState:UIControlStateNormal];
    [scanWindow addSubview:topLeft];
    
    UIButton *topRight = [[UIButton alloc]initWithFrame:CGRectMake(scanWindow.frame.size.width - buttonWH,0, buttonWH, buttonWH)];
    [topRight setImage:[UIImage imageNamed:@"scan_2"]forState:UIControlStateNormal];
    [scanWindow addSubview:topRight];
    
    UIButton *bottomLeft = [[UIButton alloc]initWithFrame:CGRectMake(0,scanWindow.frame.size.height - buttonWH, buttonWH, buttonWH)];
    [bottomLeft setImage:[UIImage imageNamed:@"scan_3"]forState:UIControlStateNormal];
    [scanWindow addSubview:bottomLeft];
    
    UIButton *bottomRight = [[UIButton alloc]initWithFrame:CGRectMake(scanWindow.frame.size.width-buttonWH,scanWindow.frame.size.height-buttonWH, buttonWH, buttonWH)];
    [bottomRight setImage:[UIImage imageNamed:@"scan_4"]forState:UIControlStateNormal];
    [scanWindow addSubview:bottomRight];
    if (AUTOSCAN) {
        
    }else{
    scanBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    scanBtn.frame = CGRectMake((scanWindow.frame.size.width-80)/2, scanWindow.frame.size.height-90, 80, 80);
    [scanBtn setImage:[UIImage imageNamed:@"MSscanning_selected"] forState:(UIControlStateNormal)];
    [scanBtn setImage:[UIImage imageNamed:@"MSscanning"] forState:(UIControlStateSelected)];
    [scanBtn setImage:[UIImage imageNamed:@"MSscanning"] forState:(UIControlStateHighlighted)];
    [scanBtn addTarget:self action:@selector(onScanCardID:) forControlEvents:(UIControlEventTouchUpInside)];
    [scanWindow addSubview:scanBtn];
    }
    
}
-(void)onScanCardID:(UIButton *)btn{
    scanI = YES;
}
- (void)beginScanning
{
    //获取摄像设备
    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //创建输入流
    AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    if (!input) return;
    
   
    //视频输出则创建输出流
    AVCaptureVideoDataOutput * output = [[AVCaptureVideoDataOutput alloc]init];
    dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
    [output setSampleBufferDelegate:self queue:queue];
    //人脸输出则创建输出流
//        AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc]init];
//        [output setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeFace]];
//        dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
//        [output setMetadataObjectsDelegate:self queue:queue];
//
    //初始化链接对象
    _session = [[AVCaptureSession alloc]init];
    //高质量采集率
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    //自动对焦代码***************
    [device lockForConfiguration:nil];
    //设置闪光灯为自动
    [device setFlashMode:AVCaptureFlashModeAuto];
    
    [_session beginConfiguration];
    if ([device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
        [device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
    }
    [device unlockForConfiguration];
    [_session commitConfiguration];
    //*************************
    [_session addInput:input];
    [_session addOutput:output];
//    if ([_session canAddOutput:output]) {
//        [_session addOutput:output];
//        output.metadataObjectTypes = @[AVMetadataObjectTypeFace];
//    }
   output.videoSettings = [NSDictionary dictionaryWithObject: [NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey: (id)kCVPixelBufferPixelFormatTypeKey];
    AVCaptureVideoPreviewLayer * layer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    layer.videoGravity=AVLayerVideoGravityResizeAspectFill;
//    layer.frame=self.view.layer.bounds;
    layer.frame = CGRectMake(0, 0, SCREENWidth, SCREENHeight-114);
    [self.view.layer insertSublayer:layer atIndex:0];
    
    
}
//-(void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context {
//    if([keyPath isEqualToString:@"adjustingFocus"]){
//        BOOL adjustingFocus =[[change objectForKey:NSKeyValueChangeNewKey] isEqualToNumber:[NSNumber numberWithInt:1]];
//        NSLog(@"Is adjusting focus? %@", adjustingFocus ?@"YES":@"NO");
//        NSLog(@"Change dictionary: %@", change);
//    }
//}



- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{

    if (AUTOSCAN) {
        
        if (autoScanI) {
            autoScanI = NO;
            UIImage *imageCap = [self convertSampleBufferToUIImageSampleBuffer:sampleBuffer];
            BOOL face =  [self identifyFaces:imageCap];
            if (face) {
                char * data = (char *)[self convertUIImageToBitmapRGBA8:imageCap];
            NSLog(@"=======进入扫描");
                int t = 1;
                //注：不要忘记释放malloc的内存
                free(data);
            NSLog(@"t:========%d",t);
            if (t == 0)
            {

                
              }else{

                    autoScanI = YES;
              }

           
            }else{

                autoScanI = YES;
            }
            
        }
        
    }else{
        

    }

    
}
- (UIImage *)convertSampleBufferToUIImageSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    // Get the number of bytes per row for the plane pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
    // Get the number of bytes per row for the plane pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer,0);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    // Create a device-dependent gray color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    // Release the Quartz image
    CGImageRelease(quartzImage);
    return (image);
    
}
-(char *)uiImageSwitchChar:(UIImage *)imageCap{
    char * image;
    CGImageRef imageCG = [imageCap CGImage];
    CFDataRef data = CGDataProviderCopyData(CGImageGetDataProvider(imageCG));
    image = (char *)CFDataGetBytePtr(data);
    
    return (image);
}
- (unsigned char *) convertUIImageToBitmapRGBA8:(UIImage *) image {
    
    CGImageRef imageRef = image.CGImage;
    
    // Create a bitmap context to draw the uiimage into
    CGContextRef context = [self newBitmapRGBA8ContextFromImage:imageRef];
    
    if(!context) {
        return NULL;
    }
    
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    CGRect rect = CGRectMake(0, 0, width, height);
    
    // Draw image into the context to get the raw image data
    CGContextDrawImage(context, rect, imageRef);
    
    // Get a pointer to the data
    unsigned char *bitmapData = (unsigned char*)CGBitmapContextGetData(context);
    
    // Copy the data and release the memory (return memory allocated with new)
    size_t bytesPerRow = CGBitmapContextGetBytesPerRow(context);
    size_t bufferLength = bytesPerRow * height;
    
    unsigned char *newBitmap = NULL;
    
    if(bitmapData) {
        newBitmap = (unsigned char *)malloc(sizeof(unsigned char) * bytesPerRow * height);
        
        if(newBitmap) {    // Copy the data
            for(int i = 0; i < bufferLength; ++i) {
                newBitmap[i] = bitmapData[i];
            }
        }
        
        free(bitmapData);
        
    } else {
        NSLog(@"Error getting bitmap pixel data\n");
    }
    
    CGContextRelease(context);
    
    return newBitmap;
}
- (CGContextRef) newBitmapRGBA8ContextFromImage:(CGImageRef) image {
    CGContextRef context = NULL;
    CGColorSpaceRef colorSpace;
    uint32_t *bitmapData;
    
    size_t bitsPerPixel = 32;
    size_t bitsPerComponent = 8;
    size_t bytesPerPixel = bitsPerPixel / bitsPerComponent;
    
    size_t width = CGImageGetWidth(image);
    size_t height = CGImageGetHeight(image);
    
    size_t bytesPerRow = width * bytesPerPixel;
    size_t bufferLength = bytesPerRow * height;
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    if(!colorSpace) {
        NSLog(@"Error allocating color space RGB\n");
        return NULL;
    }
    
    // Allocate memory for image data
    bitmapData = (uint32_t *)malloc(bufferLength);
    
    if(!bitmapData) {
        NSLog(@"Error allocating memory for bitmap\n");
        CGColorSpaceRelease(colorSpace);
        return NULL;
    }
    
    //Create bitmap context
    
    context = CGBitmapContextCreate(bitmapData,
                                    width,
                                    height,
                                    bitsPerComponent,
                                    bytesPerRow,
                                    colorSpace,
                                    kCGImageAlphaPremultipliedLast);    // RGBA
    if(!context) {
        free(bitmapData);
        NSLog(@"Bitmap context not created");
    }
    
    CGColorSpaceRelease(colorSpace);
    
    return context;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [_session stopRunning];
    [scanWindow removeFromSuperview];
}

// 截取字符串方法封装//

- (NSString*)subStringFrom:(NSString*)initialString Start:(NSString*)startString toEnd:(NSString*)endString{
 
    NSRange startRange = [initialString rangeOfString:startString];
    
    NSRange endRange = [initialString rangeOfString:endString];
    
    NSRange range = NSMakeRange(startRange.location
                                + startRange.length,
                                endRange.location
                                - startRange.location
                                - startRange.length);
    
    NSString *result = [initialString substringWithRange:range];
    
    NSLog(@"%@",result);
    
    return result;
  
}
// 人脸识别方法
-(BOOL)identifyFaces:(UIImage *)myImage{
    
    //此处是CIDetectorAccuracyHigh，若用于real-time的人脸检测，则用CIDetectorAccuracyLow，更快
    @autoreleasepool {
    CIImage *ciImage = [CIImage imageWithCGImage:myImage.CGImage];
    NSDictionary *dic = [NSDictionary dictionaryWithObject:CIDetectorAccuracy forKey:CIDetectorAccuracyHigh];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:dic];

    NSArray *array = [detector featuresInImage:ciImage];
    //图片中只有一个人脸
    if (array.count==1) {
        
        return YES;
    }else{
        
        return NO;
    }

 }
}
//判断身份证格式
- (BOOL)judgeIdentityStringValid:(NSString *)identityString {

    if (identityString.length != 18)return NO;
    // 正则表达式判断基本 身份证号是否满足格式
    NSString *regex = @"^[1-9]\\d{5}[1-9]\\d{3}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])\\d{3}([0-9]|X)$";
    NSPredicate *identityStringPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    //如果通过该验证，说明身份证格式正确，但准确性还需计算
    if(![identityStringPredicate evaluateWithObject:identityString]) return NO;
    
    //** 开始进行校验 *//
    
    //将前17位加权因子保存在数组里
    NSArray *idCardWiArray = @[@"7", @"9", @"10", @"5", @"8", @"4", @"2", @"1", @"6", @"3", @"7", @"9", @"10", @"5", @"8", @"4", @"2"];
    
    //这是除以11后，可能产生的11位余数、验证码，也保存成数组
    NSArray *idCardYArray = @[@"1", @"0", @"10", @"9", @"8", @"7", @"6", @"5", @"4", @"3", @"2"];
    
    //用来保存前17位各自乖以加权因子后的总和
    NSInteger idCardWiSum = 0;
    for(int i = 0;i < 17;i++) {
        @autoreleasepool {
        NSInteger subStrIndex = [[identityString substringWithRange:NSMakeRange(i, 1)] integerValue];
        NSInteger idCardWiIndex = [[idCardWiArray objectAtIndex:i] integerValue];
        idCardWiSum+= subStrIndex * idCardWiIndex;
        }
    }
    
    //计算出校验码所在数组的位置
    NSInteger idCardMod=idCardWiSum%11;
    //得到最后一位身份证号码
    NSString *idCardLast= [identityString substringWithRange:NSMakeRange(17, 1)];
    //如果等于2，则说明校验码是10，身份证号码最后一位应该是X
    if(idCardMod==2) {
        if(![idCardLast isEqualToString:@"X"]|| ![idCardLast isEqualToString:@"x"]) {
            return NO;
        }
    }
    else{
        //用计算出的验证码与最后一位身份证号码匹配，如果一致，说明通过，否则是无效的身份证号码
        if(![idCardLast isEqualToString: [idCardYArray objectAtIndex:idCardMod]]) {
            return NO;
        }
    }
    return YES;

}


@end
