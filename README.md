>**接口**里边混合：`中文`、`空格`、`特殊字符...`项目很长时间了，代码量级很大，想要修改怕是几天几夜不能睡觉（稍微夸张）；
####那么有没有更高效更安全的解决办法，不用更改一点代码，答案是：肯定的！！！

```
解决思路：在执行URLWithString方法的时候，进行处理，那么就需要运用到runtime上无所不能的，交换方法接口:

引入run time专用头文件#import <objc/message.h>

method_exchangeImplementations(Method m1, Method m2) 
```

` eg:`

1.`www.baidu.com/中文`
```
NSURL *url = [NSURL URLWithString:@"www.baidu.com/中文"];
NSLog(@"url=%@",url);
打印出来：url=nill
```
2.`www.baidu.com`
```
NSURL *url = [NSURL URLWithString:@"www.baidu.com"];
NSLog(@"url=%@",url);
打印出来：url=www.baidu.com
```
>所以这样两种情况在项目中会很常见，下面我们用分类的方法来解决这件头痛的事情：
`cmd+N`
新建一个分类

![cateory.png](http://upload-images.jianshu.io/upload_images/3729815-ae91f0ef9fd777ec.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/640)


![url.png](http://upload-images.jianshu.io/upload_images/3729815-f78e6bdf7d8d8f0f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/640)


![(NSUrl + url).png](http://upload-images.jianshu.io/upload_images/3729815-a02f4fbd21066d89.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/640)


我们知道一个类Class调用的时候最先调用的方法是
##加载类的load方法
`+ (void)load`
>开始上代码：

```
//  NSURL+url.h
//
//  Created by 窦心东 on 2017/6/2.
//  Copyright © 2017年 窦心东. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (url)

+(instancetype)XD_URLWithString:(NSString *)URLString;

@end

```
```
//
//  NSURL+url.m
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
```
```
//
//  ViewController.m
//  Created by 窦心东 on 2017/6/2.
//  Copyright © 2017年 窦心东. All rights reserved.
//

#import "ViewController.h"
#import <objc/message.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.


    //创建一个URL 但是有可能为空
    //如果字符串有中文，这个URL就创建不成功，那么我们发送请求就会出错  oc中没有对URL为空的监测机制 Swift里面有可选项
    //我需要为URLWithString这个方法添加一个检测是否为空的功能 这个在持续好久的项目中作用特别大，不用改动原来的代码就可以实现
    NSURL *url = [NSURL URLWithString:@"www.baidu.com/中文"];
    NSLog(@"url=%@",url);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
#运行结果：
2017-06-08 11:27:18.051 06-02 [26223:7685365] 来到这+[NSURL(url) load]
2017-06-08 11:27:18.160 06-02[26223:7685365] url=www.baidu.com/%E4%B8%AD%E6%96%87
```
>over
有个方法值得注意：
```
[URLString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
```

.

>@interface NSString (NSURLUtilities)
//Returns a new string made from the receiver by replacing all characters not in the allowedCharacters set with percent encoded characters. 
UTF-8 encoding is used to determine the correct percent encoded characters. 
Entire URL strings cannot be percent-encoded. 
This method is intended to percent-encode an URL component or subcomponent string, NOT the entire URL string.
 Any characters in allowedCharacters outside of the 7-bit ASCII range are ignored.
返回一个新的字符串由接收方通过替换所有字符与百分比allowedCharacters集编码字符。utf - 8编码被用来确定正确的百分比编码字符。不能percent-encoded整个URL字符串。这种方法旨在percent-encode组件或子组件的URL字符串,而不是整个URL字符串。外的任何字符allowedCharacters 7位ASCII范围将被忽略。
#ios7.0及之后开始添加此方法
```
- (nullable NSString *)stringByAddingPercentEncodingWithAllowedCharacters:(NSCharacterSet *)allowedCharacters 
NS_AVAILABLE(10_9, 7_0);
```

.

>// Returns a new string made from the receiver by replacing all percent encoded sequences with the matching UTF-8 characters.
返回一个新的字符串由接收方通过替换所有百分比与匹配的utf - 8字符编码序列。
#ios7.0及之后开始添加此属性
```
@property (nullable, readonly, copy) NSString *stringByRemovingPercentEncoding NS_AVAILABLE(10_9, 7_0);
```

.

>```
- (nullable NSString *)stringByAddingPercentEscapesUsingEncoding:(NSStringEncoding)enc
```
 NS_DEPRECATED(10_0, 10_11, 2_0, 9_0, "Use -stringByAddingPercentEncodingWithAllowedCharacters: instead,
 which always uses the recommended UTF-8 encoding, 
and which encodes for a specific URL component or subcomponent
 since each URL component or subcomponent has different rules for what characters are valid.");
#ios9.0及之后开始弃用此方法
使用-stringByAddingPercentEncodingWithAllowedCharacters:相反,它总是使用推荐utf - 8编码,编码为一个特定的URL组件或子组件由于每个URL组件或子组件有不同的规则,什么角色都是有效的。

.

>```
- (nullable NSString *)stringByReplacingPercentEscapesUsingEncoding:(NSStringEncoding)enc 
```
NS_DEPRECATED(10_0, 10_11, 2_0, 9_0, "Use -stringByRemovingPercentEncoding instead,
 which always uses the recommended UTF-8 encoding.");
#ios9.0及之后开始弃用此方法
使用-stringByRemovingPercentEncoding相反,总是使用推荐的utf - 8编码。
@end

推荐文章：
http://www.jianshu.com/p/21a21866e379
http://nshipster.cn/nscharacterset/


![NSCharacterSet](http://upload-images.jianshu.io/upload_images/3729815-f5a608395b178370.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
