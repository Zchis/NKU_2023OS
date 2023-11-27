#include <defs.h>
#include <riscv.h>
#include <stdio.h>
#include <string.h>
#include <swap.h>
#include <swap_lru.h>


#include <list.h>

list_entry_t pra_list_head;
static int
_lru_init_mm(struct mm_struct *mm)
{     
    // 初始化
    list_init(&pra_list_head);
    // 将mm的私有成员指针指向pra_list_head，用于后续的页面替换算法操作
    mm->sm_priv = &pra_list_head;
    return 0;
}



static int
_lru_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
    cprintf("lru swappable done!\n");

    list_entry_t *head=(list_entry_t*) mm->sm_priv;
    list_entry_t *entry=&(page->pra_page_link);
    list_entry_t *cur=list_next(head);

    assert(entry != NULL && head!= NULL);

    list_add(head, entry);//如果本来存在，则移到最后

    // int num_bits = sizeof(uint_t) * 8;// 32位系统
    uint_t mask = (uint_t)1 << (31);// 将最高位设置为1

    page->visited |= mask;  // 以访问便按位或，将最高位设置为1

    while (cur != &pra_list_head) {
        struct Page *tmp_page = le2page(cur, pra_page_link);
        tmp_page->visited = tmp_page->visited >> 1;
        cur = list_next(cur);
    }

    cprintf("swappable page visited: %u\n", page->visited);

    return 0;

}


static int 
_lru_swap_out_victim(struct mm_struct *mm, struct Page **ptr_page, int in_tick)
{
    uint_t min_visited = 4294967295;
    cprintf("lru victim done!\n");
    list_entry_t *entry = list_next(&pra_list_head);
    struct Page *victim = NULL;
    list_entry_t *cur;
    // 如果链表为空，没有可供置换的页面
    if (entry == &pra_list_head) {
        *ptr_page = NULL;
        return 0;
    }

    while (entry != &pra_list_head) {
        struct Page *tmp_page = le2page(entry, pra_page_link);
        tmp_page->visited = tmp_page->visited >> 1;
        entry = list_next(entry);
    }
    entry = list_next(entry);
    cprintf("to find victim --------\n");
    while (entry != &pra_list_head) {
        cprintf("victim  min_visited: %u\n", min_visited);
        struct Page *page = le2page(entry, pra_page_link);
        if (page->visited < min_visited) {
            victim = page;
            min_visited = page->visited;
            cur = entry;
        }
        entry = list_next(entry);
    }
    cprintf("victim  min_visited end --------: %u\n", victim->visited);
    // 从链表中删除选中的页面
    list_del(cur);
    cprintf("victim  min_visited end --------: %u\n", le2page(cur, pra_page_link)->visited);
    // 将选中的页面返回给 caller
    *ptr_page = victim;
    return 0;
}

static int 
lru_write_memory(int maddr, int mdata){
    *(unsigned char *)maddr = mdata;
    list_entry_t *entry = list_next(&pra_list_head);
    while (entry != &pra_list_head) {
        struct Page *page = le2page(entry, pra_page_link);
        cprintf("write_visited: %u\n", page->visited);
        entry = list_next(entry);
    }
}

static int
_lru_check_swap(void) {
    cprintf("write Virt Page c in lru_check_swap\n");
    lru_write_memory(0x3000,0x0c);
    assert(pgfault_num==4);
    cprintf("write Virt Page a in lru_check_swap\n");
    lru_write_memory(0x1000,0x0a);
    assert(pgfault_num==4);
    cprintf("write Virt Page d in lru_check_swap\n");
    lru_write_memory(0x4000 ,0x0d);
    assert(pgfault_num==4);
    cprintf("write Virt Page b in lru_check_swap\n");
    lru_write_memory(0x2000 ,0x0b);
    assert(pgfault_num==4);
    cprintf("write Virt Page e in lru_check_swap\n");
    lru_write_memory(0x5000 ,0x0e);
    assert(pgfault_num==5);
    cprintf("write Virt Page b in lru_check_swap\n");
    lru_write_memory(0x2000 ,0x0b);
    assert(pgfault_num==5);
    cprintf("write Virt Page a in lru_check_swap\n");
    lru_write_memory(0x1000 ,0x0a);
    assert(pgfault_num==5);
    cprintf("write Virt Page b in lru_check_swap\n");
    lru_write_memory(0x2000 ,0x0b);
    assert(pgfault_num==5);
    cprintf("write Virt Page c in lru_check_swap\n");
    lru_write_memory(0x3000 ,0x0c);
    assert(pgfault_num==6);
    cprintf("write Virt Page d in lru_check_swap\n");
    lru_write_memory(0x4000 ,0x0d);
    assert(pgfault_num==7);
    cprintf("write Virt Page e in lru_check_swap\n");
    lru_write_memory(0x5000 ,0x0e);
    assert(pgfault_num==8);
    cprintf("write Virt Page a in lru_check_swap\n");
    assert(*(unsigned char *)0x1000 == 0x0a);
    lru_write_memory(0x1000 ,0x0a);
    assert(pgfault_num==9);
    return 0;
}


static int
_lru_init(void)
{
    return 0;
}

static int
_lru_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}

static int
_lru_tick_event(struct mm_struct *mm)
{ return 0; }


struct swap_manager swap_manager_lru =
{
     .name            = "lru swap manager",
     .init            = &_lru_init,
     .init_mm         = &_lru_init_mm,
     .tick_event      = &_lru_tick_event,
     .map_swappable   = &_lru_map_swappable,
     .set_unswappable = &_lru_set_unswappable,
     .swap_out_victim = &_lru_swap_out_victim,
     .check_swap      = &_lru_check_swap,
};