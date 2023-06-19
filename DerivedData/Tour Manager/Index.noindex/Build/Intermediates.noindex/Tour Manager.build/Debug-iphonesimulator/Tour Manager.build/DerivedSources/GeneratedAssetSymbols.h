#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The "background" asset catalog image resource.
static NSString * const ACImageNameBackground AC_SWIFT_PRIVATE = @"background";

/// The "iconImg" asset catalog image resource.
static NSString * const ACImageNameIconImg AC_SWIFT_PRIVATE = @"iconImg";

/// The "no profile photo" asset catalog image resource.
static NSString * const ACImageNameNoProfilePhoto AC_SWIFT_PRIVATE = @"no profile photo";

/// The "profiletestphoto" asset catalog image resource.
static NSString * const ACImageNameProfiletestphoto AC_SWIFT_PRIVATE = @"profiletestphoto";

/// The "testbackground" asset catalog image resource.
static NSString * const ACImageNameTestbackground AC_SWIFT_PRIVATE = @"testbackground";

#undef AC_SWIFT_PRIVATE