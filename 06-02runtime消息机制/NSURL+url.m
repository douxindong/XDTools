//
//  NSURL+url.m
//  06-02runtime消息机制
//
//  Created by 窦心东 on 2017/6/2.
//  Copyright © 2017年 窦心东. All rights reserved.
//

#import "NSURL+url.h"
#import <objc/message.h>
@implementation NSURL (url)
//加载类的load方法

+ (void)load{
    NSLog(@"来到这%s",__func__);
    //1.拿到两个方法 苹果原来的URLWithString 和XD_URLWithString 交换两个方法
    //class_getClassMethod获取类方法   class_getInstanceMethod获取对象方法
    Method URLWithStr = class_getClassMethod([NSURL class], @selector(URLWithString:));
    Method XD_URLWithStr = class_getClassMethod([NSURL class], @selector(XD_URLWithString:));
    //2.交换这两个方法 调用A执行B
    method_exchangeImplementations(URLWithStr, XD_URLWithStr);
    
}
+(instancetype)XD_URLWithString:(NSString *)URLString{
    //NSURL *url = [NSURL URLWithString:URLString];
    //上边这一句会出现死循环，因为交换机制调用URLWithString执行XD_URLWithString那么
    //直接调用XD_URLWithString，因为刚才通过了交换，就相当于调用URLWithString，就像大话西游上移神换影大法😄
    NSURL *url = [NSURL XD_URLWithString:URLString];
    if (url == nil) {
       NSString * urlstr = [URLString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
        url = [NSURL URLWithString:urlstr];
        //        NSLog(@"该URL为空") ;
        return url;
    }else{
        return url;
    }
    
}
@end
