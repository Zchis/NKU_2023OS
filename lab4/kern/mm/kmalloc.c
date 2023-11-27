#include <defs.h>
#include <list.h>
#include <memlayout.h>
#include <assert.h>
#include <kmalloc.h>
#include <sync.h>
#include <pmm.h>
#include <stdio.h>

/*
 * SLOB Allocator: Simple List Of Blocks
 *
 * Matt Mackall <mpm@selenic.com> 12/30/03
 *
 * How SLOB works:
 *
 * The core of SLOB is a traditional K&R style heap allocator, with
 * support for returning aligned objects. The granularity of this
 * allocator is 8 bytes on x86, though it's perhaps possible to reduce
 * this to 4 if it's deemed worth the effort. The slob heap is a
 * singly-linked list of pages from __get_free_page, grown on demand
 * and allocation from the heap is currently first-fit.
 *
 * Above this is an implementation of kmalloc/kfree. Blocks returned
 * from kmalloc are 8-byte aligned and prepended with a 8-byte header.
 * If kmalloc is asked for objects of PAGE_SIZE or larger, it calls
 * __get_free_pages directly so that it can return page-aligned blocks
 * and keeps a linked list of such pages and their orders. These
 * objects are detected in kfree() by their page alignment.
 *
 * SLAB is emulated on top of SLOB by simply calling constructors and
 * destructors for every SLAB allocation. Objects are returned with
 * the 8-byte alignment unless the SLAB_MUST_HWCACHE_ALIGN flag is
 * set, in which case the low-level allocator will fragment blocks to
 * create the proper alignment. Again, objects of page-size or greater
 * are allocated by calling __get_free_pages. As SLAB objects know
 * their size, no separate size bookkeeping is necessary and there is
 * essentially no allocation space overhead.
 */
// SLOB分配器是一种传统的K&R风格堆内存分配器，它支持返回对齐的对象。
// 该分配器的粒度在x86上是8字节，尽管可能可以减少到4字节，如果认为值得这样做的话。
// SLOB堆是由__get_free_page函数返回的页面的单向链表，它在需求增长时增长，而从堆分配的实现是首次适配（first-fit）的。

// 在SLOB上方，实现了kmalloc/kfree的功能。从kmalloc返回的块具有8字节的对齐，并在前面附加了8字节的头部。
// 如果kmalloc要求分配大小为PAGE_SIZE或更大的对象，它会直接调用__get_free_pages，以便返回页面对齐的块，并保持这些页面及其顺序的链表。
// 这些对象在kfree()中通过它们的页面对齐方式来识别。

// SLOB在SLOB上模拟了SLAB分配器，简单地调用了每个SLAB分配的构造函数和析构函数。
// 返回的对象具有8字节的对齐，除非设置了SLAB_MUST_HWCACHE_ALIGN标志，此时底层分配器将分裂块以创建正确的对齐。
// 再次强调，分配大小为页面大小或更大的对象是通过调用__get_free_pages来完成的。
// 由于SLAB对象知道它们的大小，因此不需要额外的大小管理，几乎没有分配空间开销。

//some helper
//保存和恢复中断状态的宏，保存和恢复中断状态
#define spin_lock_irqsave(l, f) local_intr_save(f)
#define spin_unlock_irqrestore(l, f) local_intr_restore(f)
typedef unsigned int gfp_t;
#ifndef PAGE_SIZE
#define PAGE_SIZE PGSIZE
#endif

#ifndef L1_CACHE_BYTES
#define L1_CACHE_BYTES 64// L1 4字节
#endif

#ifndef ALIGN
#define ALIGN(addr,size)   (((addr)+(size)-1)&(~((size)-1))) 
#endif
// 地址对齐

struct slob_block {
	int units;
	struct slob_block *next;
};
typedef struct slob_block slob_t;

#define SLOB_UNIT sizeof(slob_t)
#define SLOB_UNITS(size) (((size) + SLOB_UNIT - 1)/SLOB_UNIT)// 所需的块单位数量，用来计算序号
#define SLOB_ALIGN L1_CACHE_BYTES// 提高性能

struct bigblock {// 管理大块内存
	int order;
	void *pages;
	struct bigblock *next;
};
typedef struct bigblock bigblock_t;

static slob_t arena = { .next = &arena, .units = 1 };
static slob_t *slobfree = &arena;// SLOB 分配器中可用块链表，小于 4KB 大小
static bigblock_t *bigblocks;// 大块内存的链表，大于 4KB 

static void* __slob_get_free_pages(gfp_t gfp, int order)
{
  struct Page * page = alloc_pages(1 << order);// 分配连续的物理页， 2 的 order 次方
  if(!page)
    return NULL;
  return page2kva(page);// 转换为虚拟地址
}

#define __slob_get_free_page(gfp) __slob_get_free_pages(gfp, 0)// 分配一个页面

static inline void __slob_free_pages(unsigned long kva, int order)// 释放大块内存
{
  free_pages(kva2page(kva), 1 << order);
}

static void slob_free(void *b, int size);

static void *slob_alloc(size_t size, gfp_t gfp, int align)
{
	assert( (size + SLOB_UNIT) < PAGE_SIZE );

	slob_t *prev, *cur, *aligned = 0;
	int delta = 0, units = SLOB_UNITS(size);
	unsigned long flags;

	spin_lock_irqsave(&slob_lock, flags);// 自旋锁 
	prev = slobfree;
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
		if (align) {
			aligned = (slob_t *)ALIGN((unsigned long)cur, align);
			delta = aligned - cur;
		}
		if (cur->units >= units + delta) { /* room enough? */
			if (delta) { /* need to fragment head to align? */ //如果需要对块进行对齐操作，会分割出一个对齐后的块，将其余的部分链接到链表中。
				aligned->units = cur->units - delta;
				aligned->next = cur->next;
				cur->next = aligned;
				cur->units = delta;
				prev = cur;
				cur = aligned;
			}

			if (cur->units == units) /* exact fit? */ // 如果找到的块大小与请求的大小相等，将其从链表中分离。
				prev->next = cur->next; /* unlink */
			else { /* fragment */ //如果找到的块大于请求的大小，会分割出一个符合大小的块，将剩余的部分链接到链表中。
				prev->next = cur + units;
				prev->next->units = cur->units - units;
				prev->next->next = cur->next;
				cur->units = units;
			}

			slobfree = prev;
			spin_unlock_irqrestore(&slob_lock, flags);// 释放自旋锁
			return cur;
		}
		if (cur == slobfree) {// 如果遍历完没找到，请求一页来分配，内存池的大小得到了扩充
			spin_unlock_irqrestore(&slob_lock, flags);

			if (size == PAGE_SIZE) /* trying to shrink arena? */
				return 0;

			cur = (slob_t *)__slob_get_free_page(gfp);
			if (!cur)// 如果申请不到就直接返回
				return 0;

			slob_free(cur, PAGE_SIZE);
			spin_lock_irqsave(&slob_lock, flags);
			cur = slobfree;
		}
	}
}

static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
		return;

	if (size)
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
		if (cur >= cur->next && (b > cur || b < cur->next))// 环形链表
			break;

	if (b + b->units == cur->next) {// 相邻则合并，不相邻就直接连接
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;

	slobfree = cur;

	spin_unlock_irqrestore(&slob_lock, flags);
}



void
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}

size_t
slob_allocated(void) {
  return 0;
}

size_t
kallocated(void) {
   return slob_allocated();
}

static int find_order(int size)
{
	int order = 0;
	for ( ; size > 4096 ; size >>=1)
		order++;
	return order;
}// size的2的幂

static void *__kmalloc(size_t size, gfp_t gfp)// gfp表示内存分配的策略
{
	slob_t *m;
	bigblock_t *bb;
	unsigned long flags;

	if (size < PAGE_SIZE - SLOB_UNIT) {// 小块管理结构
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
		return m ? (void *)(m + 1) : 0;
	}

	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);// 否则大块管理结构
	if (!bb)
		return 0;

	bb->order = find_order(size);
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);// 实际的虚拟内存地址入口

	if (bb->pages) {// 插入链表
		spin_lock_irqsave(&block_lock, flags);
		bb->next = bigblocks;
		bigblocks = bb;
		spin_unlock_irqrestore(&block_lock, flags);
		return bb->pages;
	}

	slob_free(bb, sizeof(bigblock_t));
	return 0;
}

void *
kmalloc(size_t size)
{
  return __kmalloc(size, 0);
}


void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {// 首先在大块链表中寻找并释放
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
			if (bb->pages == block) {
				*last = bb->next;
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
				slob_free(bb, sizeof(bigblock_t));
				return;
			}
		}
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);// 小块链表就寻找并释放
	return;
}


unsigned int ksize(const void *block)// 返回块的内存大小
{
	bigblock_t *bb;
	unsigned long flags;

	if (!block)
		return 0;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; bb = bb->next)
			if (bb->pages == block) {
				spin_unlock_irqrestore(&slob_lock, flags);
				return PAGE_SIZE << bb->order;
			}
		spin_unlock_irqrestore(&block_lock, flags);
	}

	return ((slob_t *)block - 1)->units * SLOB_UNIT;
}



