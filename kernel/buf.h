#ifndef BUF_H
#define BUF_H

#include "types.h"
#include "sleeplock.h"
#include "fs.h"

struct buf {
  int valid; // has data been read from disk? i.e.: does this buffer contain
             // actual disk data (vs garbage)
  int disk;
  uint dev;     // device number (which disk this block belongs to)
  uint blockno; // block number on that device
  struct sleeplock
      lock;         // protects this buffer's contents from concurrent access
  uint refcnt;      // how many processes are using this buffer
  struct buf *prev; // LRU cache list
  struct buf *next;
  uchar data[BSIZE]; // the actual 1024 bytes of cached disk block data
};

#endif // BUF_H
