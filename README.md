ARNEventEmitter
======================

[![Build Status](https://travis-ci.org/xxxAIRINxxx/ARNEventEmitter.svg?branch=0.1.0)](https://travis-ci.org/xxxAIRINxxx/ARNEventEmitter)

I aimed at the implementation of Node.js EventEmmiter.

and KVO.


Respect
============

It was inspired by the following products.

* [jerolimov/EventEmitter](https://github.com/jerolimov/EventEmitter)

* [KXEventEmitter](https://github.com/keroxp/KXEventEmitter)

* [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa)


Requirements
============

ARNEventEmitter requires iOS 5.0 and above, and uses ARC.

How To Use
============

### emitterOn

object A (On)
```objectivec

    [[self class] arn_emitterOn:@"test" owner:self needMainThreadCall:YES callbackBlock:^(id resultObject){
        // called MianThread
        NSLog(@"A");
    }];

```

object B (On)
```objectivec

  [[self class] arn_emitterOn:@"test" owner:self needMainThreadCall:NO callbackBlock:^(id resultObject){
      // called  not MianThread
      NSLog(@"B");
  }];

```

object C (Emit)
```objectivec

  [[self class] arn_emitterEmit:@"test" resultObject:nil];
  // called objectA emitterOn
  // called objectB emitterOn

  [[self class] arn_emitterEmit:@"test" resultObject:nil];
  // called objectA emitterOn
  // called objectB emitterOn

```

### emitterOnce

object A (On)
```objectivec

    [[self class] arn_emitterOn:@"test" owner:self needMainThreadCall:YES callbackBlock:^(id resultObject){
        // called MianThread
        NSLog(@"A");
    }];

```

object B (Once)
```objectivec

  [[self class] arn_emitterOnce:@"test" owner:self needMainThreadCall:NO callbackBlock:^(id resultObject){
      // called  not MianThread
      NSLog(@"B");
  }];

```

object C (Emit)
```objectivec

  [[self class] arn_emitterEmit:@"test" resultObject:nil];
  // called objectA emitterOn
  // called objectB emitterOnce

  [[self class] arn_emitterEmit:@"test" resultObject:nil];
  // called objectA emitterOn

```

### emitterOff

object A (On)
```objectivec

    [[self class] arn_emitterOn:@"test" owner:self needMainThreadCall:YES callbackBlock:^(id resultObject){
        // called MianThread
        NSLog(@"A");
    }];

```

object B (Off)
```objectivec

  [[self class] arn_emitterOnce:@"test" owner:self needMainThreadCall:NO callbackBlock:^(id resultObject){
      // called  not MianThread
      NSLog(@"B");
      [self class] arn_emitterOff:@"test" owner:self];
  }];

```

object C (Emit)
```objectivec

  [[self class] arn_emitterEmit:@"test" resultObject:nil];
  // called objectA emitterOn
  // called objectB emitterOn

  [[self class] arn_emitterEmit:@"test" resultObject:nil];
  // called objectA emitterOn

```

### Key-Value Observing

Attention!!

Use exchange Implementations by the following

```objectivec

- (void)arn_observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context

```

KVO
```objectivec

  MyObject *objA = MyObject.new;
  MyObject *objB = MyObject.new;

  objA.count = 0;
  objB.count = 0;

  [objA arn_emitterObserve:objB keyPath:@"count" isOnce:NO needMainThreadCall:NO callbackBlock:^(id resutObject) {
        objA.count++;
  }];

  objB.count++;
  // call arn_emitterObserve

  objB.count++;
  // call arn_emitterObserve

  // objA.count == 2


```


Licensing
============

The source code is distributed under the nonviral MIT License.

 It's the simplest most permissive license available.


Japanese Note
============

Node.js界隈で広く使われているEventEmitterオブジェクトをObjective-Cで実装したものです。

（Node.jsのEventEmitterオブジェクトと同一の機能を有しているわけではありません）
