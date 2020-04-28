#include <stdlib.h>

void *bsearch(const void *__key, const void *__base, size_t __nmemb,
              size_t __size, int (*__compar)(const void *, const void *)) {
  for (size_t n = 0; n < __nmemb; n++) {
    void * p = __base + n*__size;
    int c = __compar(__key, p);
    if (c == 0)
      return p;
    if (c > 0)
      break;
  }
  return NULL;
}

