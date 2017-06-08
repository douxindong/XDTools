//
//  ViewController.m
//  06-02runtime消息机制
//
//  Created by 窦心东 on 2017/6/2.
//  Copyright © 2017年 窦心东. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"
#import <objc/message.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //1.
//    [self objectDemo];
    //2.
//    [self classDemo];
    //3.
    [self exchange_method];
    //4.
//    [self methodLazy];
}
- (void)objectDemo{
        Person *p = [[Person alloc] init];
//        [p run];
    //在Xode 5.0之后，苹果不建议使用底层函数
    //给p发送run消息
//        objc_msgSend(p, @selector(run));//相当于[p run]
        objc_msgSend(p, @selector(eatWithFood:),@"香蕉🍌");
}
- (void)classDemo{
    //OC 调用类方法 Class也是一个特殊的对象
    //    [Person run];
    Class personClass = [Person class];
//    [personClass performSelector:@selector(run)];//performSelector方法选择器 oc和js互调用处大
    objc_msgSend(personClass, @selector(run));
}
- (void)exchange_method{

    //创建一个URL 但是有可能为空
    //如果字符串有中文，这个URL就创建不成功，那么我们发送请求就会出错  oc中没有对URL为空的监测机制 Swift里面有可选项
    //我需要为URLWithString这个方法添加一个检测是否为空的功能 这个在持续好久的项目中作用特别大，不用改动原来的代码就可以实现
    NSURL *url = [NSURL URLWithString:@"www.baidu.com/   中文"];
    NSLog(@"url=%@",url);
}
- (void)methodLazy{

    //懒加载方法
    
    Person *p = [[Person alloc] init];
    //用到的时候再加载方法，
    [p performSelector:@selector(eat)];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
