//
//  NSObject+ARNEventEmitter.h
//  NSObject+ARNEventEmitter
//
//  Created by Airin on 2014/04/23.
//  Copyright (c) 2014 Airin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ARNEventEmitterCallbackBlock)(id resutObject);

@interface NSObject (ARNEventEmitter)

+ (void)arn_emitterOn:(NSString *)eventName target:(id)target needMainThreadCall:(BOOL)needMainThreadCall callbackBlock:(ARNEventEmitterCallbackBlock)callbackBlock;
+ (void)arn_emitterOnce:(NSString *)eventName target:(id)target needMainThreadCall:(BOOL)needMainThreadCall callbackBlock:(ARNEventEmitterCallbackBlock)callbackBlock;

+ (void)arn_emitterEmit:(NSString *)eventName resultObject:(id)resultObject;
+ (void)arn_emitterEmit:(NSString *)eventName resultObject:(id)resultObject emitTarget:(id)emitTarget;

+ (void)arn_emitterReset;
+ (void)arn_emitterResetWithTarget:(id)target;
+ (void)arn_emitterAllOff:(NSString *)eventName;
+ (void)arn_emitterOff:(NSString *)eventName target:(id)target;

- (void)arn_emitterObserve:(id)object keyPath:(NSString *)keyPath isOnce:(BOOL)isOnce needMainThreadCall:(BOOL)needMainThreadCall callbackBlock:(ARNEventEmitterCallbackBlock)callbackBlock;
- (void)arn_emitterStopObsrving:(id)object;
- (void)arn_emitterStopObserving:(id)object forKeyPath:(NSString *)keyPath;
- (void)arn_emitterResetObserve;

@end
