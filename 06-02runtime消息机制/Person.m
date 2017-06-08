//
//  Person.m
//  06-02runtime消息机制
//
//  Created by 窦心东 on 2017/6/2.
//  Copyright © 2017年 窦心东. All rights reserved.
//

#import "Person.h"
#import <objc/message.h>
@implementation Person


- (void)run{
    NSLog(@"对象方法跑起来");
}
- (void)eatWithFood:(NSString *)food{

    NSLog(@"吃%@",food);
}
+ (void)run{
NSLog(@"类方法跑起来");
}

//这个方法在程序运行时没有在内存中
void eat(){
    NSLog(@"吃");
}

//当这个类被调用了没有实现的方法就会来到这里
+(BOOL)resolveInstanceMethod:(SEL)sel{
    NSLog(@"没有实现这个方法sel == %@",NSStringFromSelector(sel));
    
    //需要动态添加方法
    if (sel == @selector(eat)) {
        /*
         1. class
         2. name 方法编号
         3. imp 方法的实现 （本应为一段代码，函数指针）
         4. types 函数类型 C字符串（代码）比如 void === "v"
         
         */
//        class_addMethod(<#__unsafe_unretained Class cls#>, <#SEL name#>, <#IMP imp#>, <#const char *types#>)
    }
    return [super resolveInstanceMethod:sel];
}
@end
