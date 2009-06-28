
#include <sys/cachectl.h>

int cacheflush (void *addr, const int nbytes, const int op)
{
	return _flush_cache (addr, nbytes, op);
}

