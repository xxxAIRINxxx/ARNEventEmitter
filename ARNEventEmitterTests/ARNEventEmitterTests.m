//
//  ARNEventEmitterTests.m
//  ARNEventEmitterTests
//
//  Created by Airin on 2014/04/23.
//  Copyright (c) 2014 Airin. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "ARNTestObject.h"

dispatch_semaphore_t semaphore_ = nil;

@interface ARNEventEmitterTests : XCTestCase

@end

@implementation ARNEventEmitterTests

- (void)setUp
{
    [super setUp];
    
    semaphore_ = dispatch_semaphore_create(0);
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testEmitterOn
{
    ARNTestObject *objA = [[ARNTestObject alloc] initWithOn];
    ARNTestObject *objB = [[ARNTestObject alloc] initWithOn];
    
    XCTAssertTrue(objA.count == 0, @"testEmitterOn error");
    XCTAssertTrue(objB.count == 0, @"testEmitterOn error");
    
    [NSObject arn_emitterEmit:@"test" resultObject:nil];
    
    [self waitTest];
    XCTAssertTrue(objA.count == 1, @"testEmitterOn error");
    XCTAssertTrue(objB.count == 1, @"testEmitterOn error");
    
    [NSObject arn_emitterEmit:@"test" resultObject:nil];
    
    [self waitTest];
    XCTAssertTrue(objA.count == 2, @"testEmitterOn error");
    XCTAssertTrue(objB.count == 2, @"testEmitterOn error");
    
    [NSObject arn_emitterEmit:@"test" resultObject:nil emitTarget:nil];
    
    [self waitTest];
    XCTAssertTrue(objA.count == 2, @"testEmitterOn error");
    XCTAssertTrue(objB.count == 2, @"testEmitterOn error");
    
    [NSObject arn_emitterEmit:@"test" resultObject:nil emitTarget:objA];
    
    [self waitTest];
    XCTAssertTrue(objA.count == 3, @"testEmitterOn error");
    XCTAssertTrue(objB.count == 2, @"testEmitterOn error");
    
    [NSObject arn_emitterEmit:@"test" resultObject:nil emitTarget:objB];
    
    [self waitTest];
    XCTAssertTrue(objA.count == 3, @"testEmitterOn error");
    XCTAssertTrue(objB.count == 3, @"testEmitterOn error");
    
    [NSObject arn_emitterReset];
}

- (void)testemitterOnce
{
    ARNTestObject *objA = [[ARNTestObject alloc] initWithOnce];
    ARNTestObject *objB = [[ARNTestObject alloc] initWithOnce];
    
    XCTAssertTrue(objA.count == 0, @"testemitterOnce error");
    XCTAssertTrue(objB.count == 0, @"testemitterOnce error");
    
    [NSObject arn_emitterEmit:@"test" resultObject:nil];
    
    [self waitTest];
    XCTAssertTrue(objA.count == 1, @"testemitterOnce error");
    XCTAssertTrue(objB.count == 1, @"testemitterOnce error");
    
    [NSObject arn_emitterEmit:@"test" resultObject:nil];
    
    [self waitTest];
    XCTAssertTrue(objA.count == 1, @"testemitterOnce error");
    XCTAssertTrue(objB.count == 1, @"testemitterOnce error");
    
    [NSObject arn_emitterReset];
}

- (void)testEmitterOff
{
    ARNTestObject *objA = [[ARNTestObject alloc] initWithOn];
    ARNTestObject *objB = [[ARNTestObject alloc] initWithOn];
    
    XCTAssertTrue(objA.count == 0, @"testEmitterOff error");
    XCTAssertTrue(objB.count == 0, @"testEmitterOff error");
    
    [NSObject arn_emitterEmit:@"test" resultObject:nil];
    
    [self waitTest];
    XCTAssertTrue(objA.count == 1, @"testEmitterOff error");
    XCTAssertTrue(objB.count == 1, @"testEmitterOff error");
    
    [objA emitterOff];
    
    [NSObject arn_emitterEmit:@"test" resultObject:nil];
    
    [self waitTest];
    XCTAssertTrue(objA.count == 1, @"testEmitterOff error");
    XCTAssertTrue(objB.count == 2, @"testEmitterOff error");
    
    [objB emitterOff];
    
    [NSObject arn_emitterEmit:@"test" resultObject:nil];
    
    [self waitTest];
    XCTAssertTrue(objA.count == 1, @"testEmitterOff error");
    XCTAssertTrue(objB.count == 2, @"testEmitterOff error");
    
    [NSObject arn_emitterReset];
}

- (void)testEmitterAllOff
{
    ARNTestObject *objA = [[ARNTestObject alloc] initWithOn];
    ARNTestObject *objB = [[ARNTestObject alloc] initWithOn];
    
    XCTAssertTrue(objA.count == 0, @"testEmitterOff error");
    XCTAssertTrue(objB.count == 0, @"testEmitterOff error");
    
    [NSObject arn_emitterEmit:@"test" resultObject:nil];
    
    [self waitTest];
    XCTAssertTrue(objA.count == 1, @"testEmitterOff error");
    XCTAssertTrue(objB.count == 1, @"testEmitterOff error");
    
    [NSObject arn_emitterAllOff:@"test"];
    
    [NSObject arn_emitterEmit:@"test" resultObject:nil];
    
    [self waitTest];
    XCTAssertTrue(objA.count == 1, @"testEmitterOff error");
    XCTAssertTrue(objB.count == 1, @"testEmitterOff error");
    
    [NSObject arn_emitterReset];
}

- (void)testEmitterReset
{
    ARNTestObject *objA = [[ARNTestObject alloc] initWithOn];
    ARNTestObject *objB = [[ARNTestObject alloc] initWithOn];
    
    XCTAssertTrue(objA.count == 0, @"testEmitterReset error");
    XCTAssertTrue(objB.count == 0, @"testEmitterReset error");
    
    [NSObject arn_emitterEmit:@"test" resultObject:nil];
    
    [self waitTest];
    XCTAssertTrue(objA.count == 1, @"testEmitterReset error");
    XCTAssertTrue(objB.count == 1, @"testEmitterReset error");
    
    [NSObject arn_emitterReset];
    
    [NSObject arn_emitterEmit:@"test" resultObject:nil];
    
    [self waitTest];
    XCTAssertTrue(objA.count == 1, @"testEmitterReset error");
    XCTAssertTrue(objB.count == 1, @"testEmitterReset error");
}

- (void)testEmitterResetTWithTarget
{
    ARNTestObject *objA = [[ARNTestObject alloc] initWithOn];
    ARNTestObject *objB = [[ARNTestObject alloc] initWithOn];
    
    XCTAssertTrue(objA.count == 0, @"testEmitterReset error");
    XCTAssertTrue(objB.count == 0, @"testEmitterReset error");
    
    [NSObject arn_emitterEmit:@"test" resultObject:nil];
    
    [self waitTest];
    XCTAssertTrue(objA.count == 1, @"testEmitterReset error");
    XCTAssertTrue(objB.count == 1, @"testEmitterReset error");
    
    [NSObject arn_emitterResetWithTarget:objA];
    
    [NSObject arn_emitterEmit:@"test" resultObject:nil];
    
    [self waitTest];
    XCTAssertTrue(objA.count == 1, @"testEmitterReset error");
    XCTAssertTrue(objB.count == 2, @"testEmitterReset error");
    
    [NSObject arn_emitterResetWithTarget:objB];
    
    [NSObject arn_emitterEmit:@"test" resultObject:nil];
    
    [self waitTest];
    XCTAssertTrue(objA.count == 1, @"testEmitterReset error");
    XCTAssertTrue(objB.count == 2, @"testEmitterReset error");
    
    [NSObject arn_emitterReset];
}

- (void)testThread
{
    ARNTestObject *objA = [[ARNTestObject alloc] init];
    ARNTestObject *objB = [[ARNTestObject alloc] init];
    
    [NSObject arn_emitterEmit:@"test" resultObject:nil];
    
    XCTAssertTrue(objA.count == 0, @"testEmitterReset error");
    XCTAssertTrue(objB.count == 0, @"testEmitterReset error");
    
    [objA emitterOff];
    [objB emitterOff];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [objA addOn];
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [objB addOn];
    });
    
    [self waitTest];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSObject arn_emitterEmit:@"test" resultObject:nil];
    });
    
    [self waitTest];
    XCTAssertTrue(objA.count == 1, @"testEmitterReset error");
    XCTAssertTrue(objB.count == 1, @"testEmitterReset error");
    
    [NSObject arn_emitterReset];
}

- (void)testObserveOn
{
    ARNTestObject *objA = [[ARNTestObject alloc] init];
    ARNTestObject *objB = [[ARNTestObject alloc] init];
    
    XCTAssertTrue(objA.count == 0, @"testObserveOn error");
    XCTAssertTrue(objB.count == 0, @"testObserveOn error");
    
    [objA arn_emitterObserve:objB keyPath:@"count" isOnce:NO needMainThreadCall:YES callbackBlock:^(id resutObject) {
        objA.count++;
    }];
    [objB addObserver:objA forKeyPath:@"testString" options:NSKeyValueObservingOptionNew context:NULL];
    
    [objB upCount];
    [objB changeString];
    
    [self waitTest];
    XCTAssertTrue(objA.count == 1, @"testObserve error");
    XCTAssertTrue([objA.testString isEqualToString:@"OK"], @"testObserveOn error");
    
    [objB removeObserver:objA forKeyPath:@"testString"];
    
    [objA arn_emitterObserve:objB keyPath:@"testString" isOnce:NO needMainThreadCall:NO callbackBlock:^(id resutObject) {
        objA.count++;
    }];
    
    objB.count++;
    objA.testString = @"test";
    objB.testString = @"test";
    
    [self waitTest];
    XCTAssertTrue(objA.count == 3, @"testObserveOn error");
    XCTAssertTrue([objA.testString isEqualToString:@"test"], @"testObserveOn error");
    
    [objA arn_emitterStopObsrving:objB];
    [objA arn_emitterResetObserve];
    
    [NSObject arn_emitterReset];
}

- (void)testObserveOnce
{
    ARNTestObject *objA = [[ARNTestObject alloc] init];
    ARNTestObject *objB = [[ARNTestObject alloc] init];
    
    XCTAssertTrue(objA.count == 0, @"testObserveOnce error");
    XCTAssertTrue(objB.count == 0, @"testObserveOnce error");
    
    [objA arn_emitterObserve:objB keyPath:@"count" isOnce:YES needMainThreadCall:NO callbackBlock:^(id resutObject) {
        objA.count++;
    }];
    
    [objA arn_emitterObserve:objB keyPath:@"testString" isOnce:YES needMainThreadCall:NO callbackBlock:^(id resutObject) {
        objA.count++;
    }];
    
    [objB upCount];
    [objB changeString];
    
    [self waitTest];
    XCTAssertTrue(objA.count == 2, @"testObserveOnce error");
    
    [objB upCount];
    [objB changeString];
    
    [self waitTest];
    XCTAssertTrue(objA.count == 2, @"testObserveOnce error");
    
    [objA arn_emitterStopObsrving:objB];
    [objA arn_emitterResetObserve];
    
    [NSObject arn_emitterReset];
}

- (void)testObserveStop
{
    ARNTestObject *objA = [[ARNTestObject alloc] init];
    ARNTestObject *objB = [[ARNTestObject alloc] init];
    
    XCTAssertTrue(objA.count == 0, @"testObserveStop error");
    XCTAssertTrue(objB.count == 0, @"testObserveStop error");
    
    [objA arn_emitterObserve:objB keyPath:@"count" isOnce:NO needMainThreadCall:NO callbackBlock:^(id resutObject) {
        ARNTestObject *obj = (ARNTestObject *)resutObject;
        objA.testString = [NSString stringWithFormat:@"%d", (unsigned int) obj.count];
    }];
    
    
    [objB arn_emitterObserve:objA keyPath:@"count" isOnce:NO needMainThreadCall:NO callbackBlock:^(id resutObject) {
        ARNTestObject *obj = (ARNTestObject *)resutObject;
        objB.testString = [NSString stringWithFormat:@"%d", (unsigned int) obj.count];
    }];
    
    [objA upCount];
    [objB upCount];
    
    [self waitTest];
    XCTAssertTrue(objA.testString.integerValue == 1, @"testObserveStop error");
    XCTAssertTrue(objB.testString.integerValue == 1, @"testObserveStop error");
    
    [objA arn_emitterStopObserving:objB forKeyPath:@"count"];
    
    [objA upCount];
    [objB upCount];
    
    [self waitTest];
    XCTAssertTrue(objA.testString.integerValue == 1, @"testObserveStop error");
    XCTAssertTrue(objB.testString.integerValue == 2, @"testObserveStop error");
    
    [objA arn_emitterStopObsrving:objB];
    [objB arn_emitterStopObsrving:objA];
    
    [objA upCount];
    [objB upCount];
    
    [self waitTest];
    XCTAssertTrue(objA.testString.integerValue == 1, @"testObserveStop error");
    XCTAssertTrue(objB.testString.integerValue == 2, @"testObserveStop error");
    
    [objA arn_emitterResetObserve];
    
    [NSObject arn_emitterReset];
}

- (void)waitTest
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSThread sleepForTimeInterval:0.2];
        dispatch_semaphore_signal(semaphore_);
    });
    while(dispatch_semaphore_wait(semaphore_, DISPATCH_TIME_NOW)){ [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]]; };
}

@end
