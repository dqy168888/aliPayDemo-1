//
//  ViewController.m
//  aliPayDemo
//
//  Created by Cesare on 4/29/15.
//  Copyright (c) 2015 Hand. All rights reserved.
//

#import "ViewController.h"
#import "Order.h"
#import "DataSigner.h"
#import <AlipaySDK/AlipaySDK.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)aliPayTest:(id)sender {
    
    NSString *partner = @"2088901906075272";
    NSString *seller = @"hzztsmnokia@163.com";
    NSString *privateKey = @"MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAMBZFoNBIkRgGJ5maOix85H2RqSjQ6pW1VG6mV15l0RTxws/2gwFtSj96ufgMK9awDBJTmgBO+7Go/1xWuQp+2T6ytdlSeAD71Kyujx3Q5kj2FDcuLj0ccuo8gWrTEKPqot1MiHnvXb0vxo2YwQjLa/wtJbR4EnF1EFaCghoPbcbAgMBAAECgYAbmy2t/OUsJxahdVVNQG0S3+PXsU7+3aOULVHhppfdSKDirnFfFFqh3X+fc//Iyx+WTo8gQj0V0hCrSV+gK55W6frqxLOZMN6xmFX6tBehsEyqNhENGeMNSHIr0PP2hmA4l8O34hVy15hQeuDn/6DCO+GSAHUt83CRSGzGtBAlQQJBAPAMsmy/olL9U+3Vfdq2NvLvHPp9YNjFETA19Ss37NUroV+cVo6oWKwjq8fRMJN9CT3rT8MITRHOT5cMePRgwssCQQDNIPmZDc8tw5r2+9m3pqWG5+/Sd1o0mdzVLWM1WTUPLHnX2Wj+CKC7YCbD4iVqHEUHDevTsmrAJdKZSv0BCkLxAkEAn6Hx7XuquMGaVKkKnq1Z8Uet364M/1pdyc+4EFuKdWAkWm6e6RNulFrMW37zbMFTqgeX7TzR86tdJje3H9xQ7QJAfBjW56FTFXyg44q5zEElIthuXgWWrPvofY9X1Y6CawudKth8jDLsCm/BBABsYiV4HSxu30OxEU3QeqzDIz3yAQJAeA15PPWcwiGOlKyr68Q+2sHBQyWTmN1cESOImkMoZbQKrdEqXDYQLb3oHlqkLh16peaGncQgYmxQq2sBkxRh3g==";
    
    
    //partner和seller获取失败,提示
    if ([partner length] == 0 ||
        [seller length] == 0 ||
        [privateKey length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"缺少partner或者seller或者私钥。"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    Order *order = [[Order alloc] init];
    order.partner = partner;
    order.seller = seller;
    order.tradeNO = [self generateTradeNO]; //订单ID(由商家□自□行制定)
    order.productName = @"话费充值"; //商品标题
    order.productDescription = @"商品详细描述信息"; //商品描述
    order.amount = [NSString stringWithFormat:@"%.2f",0.01]; //商 品价格
    order.service = @"mobile.securitypay.pay";
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    order.itBPay = @"30m";
    order.showUrl = @"m.alipay.com";
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    NSString *appScheme = @"alisdkdemo";
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    NSLog(@"orderSpec = %@",orderSpec);
    
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(privateKey);
    NSString *signedString = [signer signString:orderSpec];
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"reslut = %@",resultDic);
        }];
    }
}



#pragma mark -
#pragma mark   ==============产生随机订单号==============


- (NSString *)generateTradeNO
{
    static int kNumber = 15;
    
    NSString *sourceStr = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    srand(time(0));
    for (int i = 0; i < kNumber; i++)
    {
        unsigned index = rand() % [sourceStr length];
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    return resultStr;
}



@end
