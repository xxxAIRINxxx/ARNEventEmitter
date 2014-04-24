//
//  NSObject+ARNEventEmitter.m
//  NSObject+ARNEventEmitter
//
//  Created by Airin on 2014/04/23.
//  Copyright (c) 2014 Airin. All rights reserved.
//

#import "NSObject+ARNEventEmitter.h"
#import <objc/runtime.h>

#if !__has_feature(objc_arc)
#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

static const char *ARN_EventEmitter_EventListeners = "ARN_EventEmitter_EventListeners";
static const char *ARN_ObserveSwizzledKey          = "airin.ARNEventEmitterListener.ObserveSwizzledKey";

static NSString *const ARN_EventEmitter_ObservingKey = @"ARN_EventEmitter_ObservingKey";

static dispatch_queue_t serialQueue_;

typedef void (^ARNEventEmitterBlock)(NSMutableDictionary *eventListeners, NSMutableArray *eventListener);

// -------------------------------------------------------------------------------------------------------------------------------//
#pragma mark - ARNEventEmitterListener

@protocol ARNEventEmitterListener <NSObject>

@property (nonatomic, assign) BOOL needMainThreadCall;
@property (nonatomic, assign) BOOL isOnce;
@property (nonatomic, weak) id     target;
@property (nonatomic, copy) id     callbackBlock;

- (void)fire:(id)resultObject;

@end

@interface ARNEventEmitterListenerObject : NSObject <ARNEventEmitterListener>
@end

@implementation ARNEventEmitterListenerObject

@synthesize needMainThreadCall;
@synthesize isOnce;
@synthesize target;
@synthesize callbackBlock;

- (void)fire:(id)resultObject
{
    if (!callbackBlock) { return; }
    
    if (needMainThreadCall) {
        dispatch_async(dispatch_get_main_queue(), ^{
            ((ARNEventEmitterCallbackBlock)callbackBlock)(resultObject);
        });
    } else {
        ((ARNEventEmitterCallbackBlock)callbackBlock)(resultObject);
    }
}

@end

// -------------------------------------------------------------------------------------------------------------------------------//
#pragma mark - NSObject ARNEventEmitter Category

@implementation NSObject (ARNEventEmitter)

+ (dispatch_queue_t)arn_emitterSerialQueue
{
    if (!serialQueue_) {
        serialQueue_ = dispatch_queue_create("ARNEventEmitterQueue", DISPATCH_QUEUE_SERIAL);
    }
    return serialQueue_;
}

+ (NSMutableDictionary *)arn_eventListeners
{
    NSMutableDictionary *eventListeners = objc_getAssociatedObject([NSObject class], &ARN_EventEmitter_EventListeners);
    if (!eventListeners) {
        eventListeners = [NSMutableDictionary dictionary];
        objc_setAssociatedObject([NSObject class], &ARN_EventEmitter_EventListeners, eventListeners, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return eventListeners;
}

+ (void)arn_emitterOn:(NSString *)eventName target:(id)target needMainThreadCall:(BOOL)needMainThreadCall callbackBlock:(ARNEventEmitterCallbackBlock)callbackBlock
{
    [NSObject arn_emitterAddListener:ARNEventEmitterListenerObject.new target:target callbackBlock:callbackBlock eventName:eventName isOnce:NO needMainThreadCall:needMainThreadCall];
}

+ (void)arn_emitterOnce:(NSString *)eventName target:(id)target needMainThreadCall:(BOOL)needMainThreadCall callbackBlock:(ARNEventEmitterCallbackBlock)callbackBlock
{
    [NSObject arn_emitterAddListener:ARNEventEmitterListenerObject.new target:target callbackBlock:callbackBlock eventName:eventName isOnce:YES needMainThreadCall:needMainThreadCall];
}

+ (void)arn_emitterAddListener:(NSObject <ARNEventEmitterListener> *)listener
                        target:(id)target
                 callbackBlock:(ARNEventEmitterCallbackBlock)callbackBlock
                     eventName:(NSString *)eventName
                        isOnce:(BOOL)isOnce
            needMainThreadCall:(BOOL)needMainThreadCall
{
    dispatch_async([NSObject arn_emitterSerialQueue], ^{
        NSMutableDictionary *eventListeners = [NSObject arn_eventListeners];
        
        NSMutableArray *eventListener = [eventListeners objectForKey:eventName];
        if (!eventListener) {
            eventListener = [NSMutableArray array];
            [eventListeners setValue:eventListener forKey:eventName];
        }
        listener.isOnce        = isOnce;
        listener.callbackBlock = callbackBlock;
        listener.target         = target;
        listener.needMainThreadCall = needMainThreadCall;
        [eventListener addObject:listener];
    });
}

+ (void)arn_emitterEmit:(NSString *)eventName resultObject:(id)resultObject
{
    if (!eventName) { return; }
    
    [NSObject arn_emitterEmit:eventName resultObject:resultObject target:nil isObserve:NO];
}

+ (void)arn_emitterEmit:(NSString *)eventName resultObject:(id)resultObject emitTarget:(id)emitTarget
{
    if (!eventName) { return; }
    if (!emitTarget) { return; }
    
    [NSObject arn_emitterEmit:eventName resultObject:resultObject target:emitTarget isObserve:NO];
}

+ (void)arn_emitterEmit:(NSString *)eventName resultObject:(id)resultObject target:(id)target isObserve:(BOOL)isObserve
{
    __weak typeof(target) weakTarget = target;
    
    [NSObject arn_emitterBlockWithEventName:eventName block: ^(NSMutableDictionary *eventListeners, NSMutableArray *eventListener) {
        NSMutableIndexSet *discardedItems = [NSMutableIndexSet indexSet];
        NSInteger index = 0;
        
        for (NSObject <ARNEventEmitterListener> *listener in eventListener) {
            if (listener.target) {
                if (target) {
                    if (listener.target == weakTarget) {
                        [listener fire:resultObject];
                        if (listener.isOnce) {
                            [discardedItems addIndex:index];
                            if (isObserve) {
                                [resultObject removeObserver:weakTarget forKeyPath:[eventName stringByReplacingOccurrencesOfString:ARN_EventEmitter_ObservingKey withString:@""]];
                            }
                        }
                    }
                } else {
                    [listener fire:resultObject];
                    if (listener.isOnce) {
                        [discardedItems addIndex:index];
                    }
                }
            } else {
                [discardedItems addIndex:index];
            }
            index++;
        }
        
        if (discardedItems.count > 0) {
            if (eventListener.count == discardedItems.count) {
                [eventListeners removeObjectForKey:eventName];
                if (eventListeners.count == 0) {
                    [NSObject arn_emitterReset];
                }
            } else {
                [eventListener removeObjectsAtIndexes:discardedItems];
            }
        }
    }];
}

+ (void)arn_emitterReset
{
    objc_setAssociatedObject([NSObject class], &ARN_EventEmitter_EventListeners, nil, OBJC_ASSOCIATION_ASSIGN);
}

+ (void)arn_emitterResetWithTarget:(id)target
{
    if (!target) { return; }
    dispatch_async([NSObject arn_emitterSerialQueue], ^{
        [NSObject arn_emitterResetWithTarget:target observingObject:nil];
    });
}

+ (void)arn_emitterResetWithTarget:(id)target observingObject:(NSObject *)observingObject
{
    NSMutableDictionary    *eventListeners = [NSObject arn_eventListeners];
    __block NSMutableArray *eventNameArray = [NSMutableArray array];
    
    [eventListeners enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
        NSMutableIndexSet *discardedItems = [NSMutableIndexSet indexSet];
        NSInteger index = 0;
        
        NSMutableArray *eventListener  = (NSMutableArray *)obj;
        for (NSObject <ARNEventEmitterListener> *listener in eventListener) {
            if (listener.target) {
                if (listener.target == target) {
                    [discardedItems addIndex:index];
                    if (observingObject) {
                        [observingObject removeObserver:target forKeyPath:[key stringByReplacingOccurrencesOfString:ARN_EventEmitter_ObservingKey withString:@""]];
                    }
                }
            } else {
                [discardedItems addIndex:index];
            }
            index++;
        }
        
        if (discardedItems.count > 0) {
            if (eventListener.count == discardedItems.count) {
                [eventNameArray addObject:[key copy]];
            } else {
                [eventListener removeObjectsAtIndexes:discardedItems];
            }
        }
    }];
    
    for (NSString *eventName in eventNameArray) {
        [eventListeners removeObjectForKey:eventName];
    }
    if (eventListeners.count == 0) {
        [NSObject arn_emitterReset];
    }
}

+ (void)arn_emitterAllOff:(NSString *)eventName
{
    [NSObject arn_emitterBlockWithEventName:eventName block: ^(NSMutableDictionary *eventListeners, NSMutableArray *eventListener) {
        [eventListener removeAllObjects];
        [eventListeners removeObjectForKey:eventName];
        
        if (eventListeners.count == 0) {
            [NSObject arn_emitterReset];
        }
    }];
}

+ (void)arn_emitterOff:(NSString *)eventName target:(id)target
{
    if (!target) { return; }
    
    __weak typeof(target) weakTarget = target;
    
    [NSObject arn_emitterBlockWithEventName:eventName block: ^(NSMutableDictionary *eventListeners, NSMutableArray *eventListener) {
        NSMutableIndexSet *discardedItems = [NSMutableIndexSet indexSet];
        NSInteger index = 0;
        
        for (NSObject <ARNEventEmitterListener> *listener in eventListener) {
            if (listener.target) {
                if (listener.target == weakTarget) {
                    [discardedItems addIndex:index];
                }
            } else {
                [discardedItems addIndex:index];
            }
            index++;
        }
        
        if (discardedItems.count > 0) {
            if (eventListener.count == discardedItems.count) {
                [eventListeners removeObjectForKey:eventName];
                if (eventListeners.count == 0) {
                    [NSObject arn_emitterReset];
                }
            } else {
                [eventListener removeObjectsAtIndexes:discardedItems];
            }
        }
    }];
}

+ (void)arn_emitterBlockWithEventName:(NSString *)eventName block:(ARNEventEmitterBlock)block
{
    dispatch_async([NSObject arn_emitterSerialQueue], ^{
        NSMutableDictionary *blockEventListeners = [NSObject arn_eventListeners];
        NSMutableArray      *blockEventListener  = [blockEventListeners valueForKey:eventName];
        if (!blockEventListener) { return; }
        
        ((ARNEventEmitterBlock)block)(blockEventListeners, blockEventListener);
    });
}

// -------------------------------------------------------------------------------------------------------------------------------//
#pragma mark - Key-Value Observing

- (void)arn_emitterObserveValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    @synchronized(self)
    {
        __block BOOL isEmitterObserve = YES;
        NSString    *newKeyPath       = [keyPath stringByAppendingString:ARN_EventEmitter_ObservingKey];
        
        // Sync !! Not Async!!
        dispatch_sync([NSObject arn_emitterSerialQueue], ^{
            NSMutableDictionary *blockEventListeners = [NSObject arn_eventListeners];
            NSMutableArray      *blockEventListener  = [blockEventListeners valueForKey:newKeyPath];
            if (!blockEventListener) {
                isEmitterObserve = NO;
            }
        });
        
        if (isEmitterObserve) {
            [NSObject arn_emitterEmit:newKeyPath resultObject:object target:self isObserve:YES];
        } else {
            // Call Original Method
            [self arn_emitterObserveValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }
}

- (void)arn_emitterObserve:(id)object keyPath:(NSString *)keyPath isOnce:(BOOL)isOnce needMainThreadCall:(BOOL)needMainThreadCall callbackBlock:(ARNEventEmitterCallbackBlock)callbackBlock
{
    if (![objc_getAssociatedObject([self class], &ARN_ObserveSwizzledKey) boolValue]) {
        [self arn_switchObservingMethod];
    }
    
    NSString *newKeyPath = [keyPath stringByAppendingString:ARN_EventEmitter_ObservingKey];
    
    [NSObject arn_emitterAddListener:ARNEventEmitterListenerObject.new target:self callbackBlock:callbackBlock eventName:newKeyPath isOnce:isOnce needMainThreadCall:needMainThreadCall];
    [object addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)arn_emitterStopObsrving:(id)object
{
    __weak typeof(self) weakSelf = self;
    
    // Sync !! Not Async!!
    dispatch_sync([NSObject arn_emitterSerialQueue], ^{
        [NSObject arn_emitterResetWithTarget:weakSelf observingObject:object];
    });
}

- (void)arn_emitterStopObserving:(id)object forKeyPath:(NSString *)keyPath
{
    NSString *newKeyPath = [keyPath stringByAppendingString:ARN_EventEmitter_ObservingKey];
    [object removeObserver:self forKeyPath:keyPath];
    [NSObject arn_emitterOff:newKeyPath target:self];
}

- (void)arn_emitterResetObserve
{
    [self arn_switchObservingMethod];
}

- (void)arn_switchObservingMethod
{
    Method originMethod = class_getInstanceMethod([self class], @selector(observeValueForKeyPath:ofObject:change:context:));
    Method emitMethod   = class_getInstanceMethod([self class], @selector(arn_emitterObserveValueForKeyPath:ofObject:change:context:));
    
    if (![objc_getAssociatedObject([self class], &ARN_ObserveSwizzledKey) boolValue]) {
        method_exchangeImplementations(originMethod, emitMethod);
        objc_setAssociatedObject([self class], &ARN_ObserveSwizzledKey, @YES, OBJC_ASSOCIATION_COPY);
    } else {
        method_exchangeImplementations(emitMethod, originMethod);
        objc_setAssociatedObject([self class], &ARN_ObserveSwizzledKey, @NO, OBJC_ASSOCIATION_COPY);
    }
}

@end
