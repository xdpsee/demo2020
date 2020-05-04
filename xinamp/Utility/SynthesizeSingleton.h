//
//  SynthesizeSingleton.h
//  xinamp
//
//  Created by chen zhenhui on 2020/4/18.
//  Copyright © 2020 chen zhenhui. All rights reserved.
//

#ifndef SynthesizeSingleton_h
#define SynthesizeSingleton_h

#define DEFINE_SINGLETON(className) \
\
+ (className *)sharedInstance;





#define IMPLEMENT_SINGLETON( name )                                     \
                                                                        \
static name * __sharedInstance = nil;                                   \
                                                                        \
+ ( id )sharedInstance                                                  \
{                                                                       \
    static dispatch_once_t token;                                       \
                                                                        \
    dispatch_once                                                       \
    (                                                                   \
        &token,                                                         \
        ^                                                               \
        {                                                               \
            __sharedInstance = [ [ name alloc ] init ];                 \
        }                                                               \
    );                                                                  \
                                                                        \
    return __sharedInstance;                                            \
}                                                                       \
                                                                        \
- ( id )copy                                                            \
{                                                                       \
    return __sharedInstance;                                            \
}                                                                       \


#endif /* SynthesizeSingleton_h */
