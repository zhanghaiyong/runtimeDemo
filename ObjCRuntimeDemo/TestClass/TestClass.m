//
//  TestClass.m
//  ObjCRuntimeDemo
//
//  Created by Mr.LuDashi on 2017/1/4.
//  Copyright © 2017年 ZeluLi. All rights reserved.
//

#import "TestClass.h"
#import "RuntimeKit.h"

@interface SecondClass : NSObject
- (void)noThisMethod:(NSString *)value;
@end

@implementation SecondClass
- (void)noThisMethod:(NSString *)value {
    NSLog(@"SecondClass中的方法实现%@", value);
}
@end


@interface TestClass(){
    NSInteger _var1;
    int _var2;
    BOOL _var3;
    double _var4;
    float _var5;
}
@property (nonatomic, strong) NSMutableArray *privateProperty1;
@property (nonatomic, strong) NSNumber *privateProperty2;
@property (nonatomic, strong) NSDictionary *privateProperty3;
@end

@implementation TestClass

+ (void)classMethod: (NSString *)value {
    NSLog(@"publicTestMethod1");
}

- (void)publicTestMethod1: (NSString *)value1 Second: (NSString *)value2 {
    NSLog(@"publicTestMethod1");
}

- (void)publicTestMethod2 {
    NSLog(@"publicTestMethod2");
}

- (void)privateTestMethod1 {
    NSLog(@"privateTestMethod1");
}

- (void)privateTestMethod2 {
    NSLog(@"privateTestMethod2");
}

#pragma mark - 方法交换时使用
- (void)method1 {
    NSLog(@"我是Method1的实现");
}

//运行时方法拦截
- (void)dynamicAddMethod: (NSString *) value {
    NSLog(@"OC替换的方法：%@", value);
}

/**
 1.消息处理（Resolve Method）
 
 当在相应的类以及父类中找不到类方法实现时会执行+resolveInstanceMethod:这个类方法。该方法如果在类中不被重写的话，默认返回NO。如果返回NO就表明不做任何处理，走下一步。如果返回YES的话，就说明在该方法中对这个找不到实现的方法进行了处理。在该方法中，我们可以为找不到实现的SEL动态的添加一个方法实现，添加完毕后，就会执行我们添加的方法实现。这样，当一个类调用不存在的方法时，就不会崩溃了
 
 没有找到SEL的IML实现时会执行下方的方法
 @param sel 当前对象调用并且找不到IML的SEL
 @return 找到其他的执行方法，并返回yes
 */
+ (BOOL)resolveInstanceMethod:(SEL)sel {
    return NO;    //当返回NO时，会接着执行forwordingTargetForSelector:方法，
    [RuntimeKit addMethod:[self class] method:sel method:@selector(dynamicAddMethod:)];
    return YES;
}


/**
 2、消息快速转发
 
 如果不对上述消息进行处理的话，也就是+resolveInstanceMethod:返回NO时，会走下一步消息转发，即-forwardingTargetForSelector:。该方法会返回一个类的对象，这个类的对象有SEL对应的实现，当调用这个找不到的方法时，就会被转发到SecondClass中去进行处理。这也就是所谓的消息转发。当该方法返回self或者nil, 说明不对相应的方法进行转发，那么就该走下一步了。
 
 将当前对象不存在的SEL传给其他存在该SEL的对象
 @param aSelector 当前类中不存在的SEL
 @return 存在该SEL的对象
 */
- (id)forwardingTargetForSelector:(SEL)aSelector {
    return self;
    return [SecondClass new];   //让SecondClass中相应的SEL去执行该方法
}


/*
 
 如果不将消息转发给其他类的对象，那么就只能自己进行处理了。如果forwardingTargetForSelector返回self的话，会执行-methodSignatureForSelector:方法来获取方法的参数以及返回数据类型，也就是说该方法获取的是方法的签名并返回。如果上述方法返回nil的话，那么消息转发就结束，程序崩溃，报出找不到相应的方法实现的崩溃信息。
 */
- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    //查找父类的方法签名
    NSMethodSignature *signature = [super methodSignatureForSelector:selector];
    if(signature == nil) {
        signature = [NSMethodSignature signatureWithObjCTypes:"@@:"];

    }
    return signature;
}


/*
 在+resolveInstanceMethod:返回NO时就会执行下方的方法，下方也是讲该方法转发给SecondClass
 */
- (void)forwardInvocation:(NSInvocation *)invocation {
    SecondClass * forwardClass = [SecondClass new];
    SEL sel = invocation.selector;
    if ([forwardClass respondsToSelector:sel]) {
        [invocation invokeWithTarget:forwardClass];
    } else {
        [self doesNotRecognizeSelector:sel];
    }
}

@end
