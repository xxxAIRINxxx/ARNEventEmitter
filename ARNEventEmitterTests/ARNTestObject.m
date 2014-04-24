//
//  ARNTestObject.m
//  ARNEventEmitter
//
//  Created by Airin on 2014/04/23.
//  Copyright (c) 2014 Airin. All rights reserved.
//

#import "ARNTestObject.h"

@implementation ARNTestObject

- (void)dealloc
{
    NSLog(@"dealloc : %@ ////////////////////////", NSStringFromClass([self class]));
}

- (instancetype)init
{
    if (!(self = [super init])) { return nil; }
    
    _count = 0;
    
    return self;
}

- (instancetype)initWithOn
{
    if (!(self = [super init])) { return nil; }
    
    _count = 0;
    
    __block __weak typeof(self) weakSelf = self;
    [[self class] arn_emitterOn:@"test" target:self needMainThreadCall:NO callbackBlock:^(id resltObject) {
        weakSelf.count++;
    }];
    
    return self;
}

- (instancetype)initWithOnce
{
    if (!(self = [super init])) { return nil; }
    
    _count = 0;
    
    __block __weak typeof(self) weakSelf = self;
    [[self class] arn_emitterOnce:@"test" target:self needMainThreadCall:NO callbackBlock:^(id resltObject) {
        weakSelf.count++;
    }];
    
    return self;
}

- (void)emitterOff
{
    [[self class] arn_emitterOff:@"test" target:self];
}

- (void)addOn
{
    __block __weak typeof(self) weakSelf = self;
    [[self class] arn_emitterOn:@"test" target:self needMainThreadCall:NO callbackBlock:^(id resltObject) {
        weakSelf.count++;
    }];
}

- (void)upCount
{
    self.count++;
}

- (void)changeString
{
    self.testString = @"change";
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"call observeValueForKeyPath");
    self.testString = @"OK";
}

@end
