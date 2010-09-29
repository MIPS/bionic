#include <unistd.h>

#ifdef DEBUG
#include <logd.h>
#define  XLOG(...)   \
	__libc_android_log_print(ANDROID_LOG_DEBUG,"libc-cacheflush",__VA_ARGS__)
#endif

/*
 * Linux historically defines a cacheflush(3) routine for MIPS
 * with this signature:
 * int cacheflush(char *addr, int nbytes, int cache);
 *
 * Android defines an alternate cacheflush routine which exposes the
 * ARM system call interface:
 * int cacheflush (long start, long end, long flags)
 *
 * This is an attempt to maintain compatibility between the historical MIPS
 * usage for software previously ported to MIPS and Android specific
 * uses of cacheflush()
 *
 */

/* This is the Android signature */
int cacheflush (long start, long end, long flags)
{
	/*
	 * Use the gcc __clear_cache builtin. This will generate synci
	 * if supported or call __flush_cache directly
	 */
	if (end < start) {
		/*
		 * It looks like this is really MIPS style cacheflush call
		 * start => addr
		 * end => nbytes
		 */
#ifdef DEBUG
		static int warned = 0;
		if (!warned) {
			XLOG("called with (start,len) instead of (start,end)");
			warned = 1;
		}
#endif
		end += start;
	}
	__clear_cache((void *)start, (void *)end);
	return 0;
}
