/* The symbol getrandom() may not be available on Android.
 * Confer: https://github.com/briansmith/ring/issues/852
 *
 * DkSDK should bundle this or something similar into the DkSDKOCaml's
 * Foundation target. */

/* Confer API level and recommendations for other levels at:
 * <sys/random.h>.
 * Ex. ndk/23.1.7779620/toolchains/llvm/prebuilt/windows-x86_64/sysroot/usr/include/sys/random.h */
#if __ANDROID_API__ < 28
#include	<stdlib.h>

extern ssize_t getrandom(void *buf, size_t buflen, unsigned int flags) {
    (void) flags;
    arc4random_buf(buf, buflen);
    return (ssize_t) buflen;
}
#endif
