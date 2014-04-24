//
//  ARNTestObject.h
//  ARNEventEmitter
//
//  Created by Airin on 2014/04/23.
//  Copyright (c) 2014 Airin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ARNTestObject : NSObject

@property (nonatomic, assign) NSInteger count;
@property (nonatomic, copy) NSString *testString;

- (instancetype)initWithOn;

- (instancetype)initWithOnce;

- (void)emitterOff;

- (void)addOn;

- (void)upCount;

- (void)changeString;

@end
