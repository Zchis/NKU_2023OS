#include <proc.h>
#include <kmalloc.h>
#include <string.h>
#include <sync.h>
#include <pmm.h>
#include <error.h>
#include <sched.h>
#include <elf.h>
#include <vmm.h>
#include <trap.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

/* ------------- process/thread mechanism design&implementation -------------
(an simplified Linux process/thread mechanism )
introduction:
  ucore implements a simple process/thread mechanism. process contains the independent memory sapce, at least one threads
for execution, the kernel data(for management), processor state (for context switch), files(in lab6), etc. ucore needs to
manage all these details efficiently. In ucore, a thread is just a special kind of process(share process's memory).

-------------进程/线程机制设计与实现-------------
（简化的 Linux 进程/线程机制）
介绍：
  UCore实现了一个简单的进程/线程机制。进程包含独立的内存 SAPCE、至少一个用于执行的线程、内核数据（用于管理）、处理器状态（用于上下文切换）、文件（在 Lab6 中）等。
在ucore中，线程只是一种特殊的进程（共享进程的内存）。

------------------------------
process state       :     meaning               -- reason
    PROC_UNINIT     :   uninitialized           -- alloc_proc
    PROC_SLEEPING   :   sleeping                -- try_free_pages, do_wait, do_sleep
    PROC_RUNNABLE   :   runnable(maybe running) -- proc_init, wakeup_proc, 
    PROC_ZOMBIE     :   almost dead             -- do_exit

-----------------------------
process state changing:
                                            
  alloc_proc                                 RUNNING
      +                                   +--<----<--+
      +                                   + proc_run +
      V                                   +-->---->--+ 
PROC_UNINIT -- proc_init/wakeup_proc --> PROC_RUNNABLE -- try_free_pages/do_wait/do_sleep --> PROC_SLEEPING --
                                           A      +                                                           +
                                           |      +--- do_exit --> PROC_ZOMBIE                                +
                                           +                                                                  + 
                                           -----------------------wakeup_proc----------------------------------
-----------------------------
process relations
parent:           proc->parent  (proc is children)
children:         proc->cptr    (proc is parent)
older sibling:    proc->optr    (proc is younger sibling)
younger sibling:  proc->yptr    (proc is older sibling)

-----------------------------
related syscall for process:
SYS_exit        : process exit,                           -->do_exit
SYS_fork        : create child process, dup mm            -->do_fork-->wakeup_proc
SYS_wait        : wait process                            -->do_wait
SYS_exec        : after fork, process execute a program   -->load a program and refresh the mm
SYS_clone       : create child thread                     -->do_fork-->wakeup_proc
SYS_yield       : process flag itself need resecheduling, -- proc->need_sched=1, then scheduler will rescheule this process
SYS_sleep       : process sleep                           -->do_sleep 
SYS_kill        : kill process                            -->do_kill-->proc->flags |= PF_EXITING
                                                                 -->wakeup_proc-->do_wait-->do_exit   
SYS_getpid      : get the process's pid

进程的相关系统调用：
SYS_exit：进程退出，-->do_exit
SYS_fork：创建子进程，dup mm -->do_fork-->wakeup_proc
SYS_wait：等待进程-->do_wait
SYS_exec：fork 后，进程执行程序 -->加载程序并刷新 mm
SYS_clone：创建子线程 -->do_fork-->wakeup_proc
SYS_yield ： 进程标志本身需要重新调度， -- proc->need_sched=1，那么调度器将重新调度这个进程
SYS_sleep：进程休眠 -->do_sleep
SYS_kill：终止进程 -->do_kill-->proc->flags |= PF_EXITING

*/

// the process set's list
list_entry_t proc_list;

#define HASH_SHIFT          10
#define HASH_LIST_SIZE      (1 << HASH_SHIFT)
#define pid_hashfn(x)       (hash32(x, HASH_SHIFT))

// has list for process set based on pid
static list_entry_t hash_list[HASH_LIST_SIZE];

// idle proc
struct proc_struct *idleproc = NULL;
// init proc
struct proc_struct *initproc = NULL;
// current proc
struct proc_struct *current = NULL;

static int nr_process = 0;

void kernel_thread_entry(void);// 函数调用/跳转到指定的函数
void forkrets(struct trapframe *tf);// 设置堆栈指针并跳转到一个特定的函数以进行上下文切换
void switch_to(struct context *from, struct context *to);// 切换到新进程


// struct proc_struct {
//     enum proc_state state;                      // Process state
//     int pid;                                    // Process ID
//     int runs;                                   // the running times of Proces
//     uintptr_t kstack;                           // Process kernel stack
//     volatile bool need_resched;                 // bool value: need to be rescheduled to release CPU?
//     struct proc_struct *parent;                 // the parent process
//     struct mm_struct *mm;                       // Process's memory management field
//     struct context context;                     // Switch here to run process
//     struct trapframe *tf;                       // Trap frame for current interrupt
//     uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
//     uint32_t flags;                             // Process flag
//     char name[PROC_NAME_LEN + 1];               // Process name
//     list_entry_t list_link;                     // Process link list 
//     list_entry_t hash_link;                     // Process hash list
// };

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
    //cprintf("alloc_proc begin!\n");
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));// 分配空间
    if (proc != NULL) {
            //LAB4:EXERCISE1 YOUR CODE
    /*
     * below fields in proc_struct need to be initialized
     *       enum proc_state state;                      // Process state
     *       int pid;                                    // Process ID
     *       int runs;                                   // the running times of Proces
     *       uintptr_t kstack;                           // Process kernel stack
     *       volatile bool need_resched;                 // bool value: need to be rescheduled to release CPU?
     *       struct proc_struct *parent;                 // the parent process
     *       struct mm_struct *mm;                       // Process's memory management field
     *       struct context context;                     // Switch here to run process
     *       struct trapframe *tf;                       // Trap frame for current interrupt
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */
        // 初始化进程状态为 PROC_UNINIT，设置进程为“初始”态
        proc->state = PROC_UNINIT;
        // 初始化进程 ID 为 -1，设置进程pid的未初始化值
        proc->pid = -1;
        // 初始化运行次数为 0
        proc->runs = 0;
        // 初始化内核栈指针为 0
        proc->kstack = 0;
        // 初始化是否需要重新调度为 false
        proc->need_resched = 0;
        // 初始化父进程指针为 NULL
        proc->parent = NULL;
        // 初始化内存管理结构为 NULL
        proc->mm = NULL;
        // 初始化上下文结构
        memset(&proc->context, 0, sizeof(struct context));
        // 初始化中断帧指针为 NULL
        proc->tf = NULL;
        // 初始化 CR3 寄存器值为 boot_cr3?
        proc->cr3 = boot_cr3;
        // 初始化进程标志位为 0
        proc->flags = 0;
        // 初始化进程名字为空字符串，set_proc_name中以实现
        memset(proc->name, 0, PROC_NAME_LEN);
    }
    return proc;
}


// set_proc_name - set the name of proc
char *
set_proc_name(struct proc_struct *proc, const char *name) {
    memset(proc->name, 0, sizeof(proc->name));
    return memcpy(proc->name, name, PROC_NAME_LEN);
}

// get_proc_name - get the name of proc
char *
get_proc_name(struct proc_struct *proc) {
    static char name[PROC_NAME_LEN + 1];
    memset(name, 0, sizeof(name));
    return memcpy(name, proc->name, PROC_NAME_LEN);
}

// get_pid - alloc a unique pid for process
static int
get_pid(void) {
    static_assert(MAX_PID > MAX_PROCESS);// PID 的范围应该大于最大进程数
    struct proc_struct *proc;
    list_entry_t *list = &proc_list, *le;
    static int next_safe = MAX_PID, last_pid = MAX_PID;
    if (++ last_pid >= MAX_PID) {
        last_pid = 1;
        goto inside;
    }
    if (last_pid >= next_safe) {
    inside:
        next_safe = MAX_PID;
    repeat:
        le = list;
        while ((le = list_next(le)) != list) {
            proc = le2proc(le, list_link);
            if (proc->pid == last_pid) {
                if (++ last_pid >= next_safe) {
                    if (last_pid >= MAX_PID) {
                        last_pid = 1;
                    }
                    next_safe = MAX_PID;
                    goto repeat;
                }
            }
            else if (proc->pid > last_pid && next_safe > proc->pid) {
                next_safe = proc->pid;
            }
        }
    }
    return last_pid;
}

// proc_run - make process "proc" running on cpu
// NOTE: before call switch_to, should load  base addr of "proc"'s new PDT
void proc_run(struct proc_struct *proc) {
    // if (proc != current) {
    //     cprintf("proc_run begin cur_thread pid: %d! \n", current->pid);
    //     cprintf("proc_run begin able_thread pid: %d, addr: %x, ra: %x, s0: %x!, sp:%x \n", proc->pid, proc, proc->context.ra, proc->context.s0, proc->context.sp);

    //     // LAB4:EXERCISE3 YOUR CODE
    //     /*
    //     * Some Useful MACROs, Functions and DEFINEs, you can use them in below implementation.
    //     * MACROs or Functions:
    //     *   local_intr_save():        Disable interrupts
    //     *   local_intr_restore():     Enable Interrupts
    //     *   lcr3():                   Modify the value of CR3 register
    //     *   switch_to():              Context switching between two processes
    //     */
    //     unsigned long flags;
    //     local_intr_save(flags);  // 禁用中断

    //     // 修改 CR3 寄存器以加载新的页表
    //     cprintf("proc_run pid:%d  lcr3 : %x! \n",proc->pid, (proc->cr3));
    //     lcr3((proc->cr3));
    //     cprintf("proc_run begin switch from pid:%d to pid:%d ! \n", current->pid, proc->pid);
    //     // 执行上下文切换，将控制权切换到新的进程
    //     switch_to(&(current->context), &(proc->context));// 为什么会缺页异常
    //     cprintf("proc_run over ! \n");
    //     local_intr_restore(flags);  // 恢复中断

    // }
    // 只有当proc不是当前执行的线程时，才需要执行
    if (proc != current) {
        bool intr_flag;
        struct proc_struct *prev = current, *next = proc;

        // 切换时新线程任务时需要暂时关闭中断，避免出现嵌套中断
        local_intr_save(intr_flag);
        {
            current = proc;
            // 设置cr3寄存器的值，令其指向新线程的页表
            lcr3(next->cr3);
            // switch_to用于完整的进程上下文切换，定义在统一目录下的switch.S中
            // 由于涉及到大量的寄存器的存取操作，因此使用汇编实现
            switch_to(&(prev->context), &(next->context));
        }
        local_intr_restore(intr_flag);
    }
}


// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);// 恢复当前进程的上下文
}

// hash_proc - add proc into proc hash_list
static void
hash_proc(struct proc_struct *proc) {
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
}

// find_proc - find proc frome proc hash_list according to pid
struct proc_struct *
find_proc(int pid) {// 哈希查找
    if (0 < pid && pid < MAX_PID) {
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
        while ((le = list_next(le)) != list) {
            struct proc_struct *proc = le2proc(le, hash_link);
            if (proc->pid == pid) {
                return proc;
            }
        }
    }
    return NULL;
}

// kernel_thread - create a kernel thread using "fn" function
// NOTE: the contents of temp trapframe tf will be copied to 
//       proc->tf in do_fork-->copy_thread function
int
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
    cprintf("THIS MY: kernel_thread bigin!\n");
    struct trapframe tf;
    memset(&tf, 0, sizeof(struct trapframe));
    tf.gpr.s0 = (uintptr_t)fn;
    tf.gpr.s1 = (uintptr_t)arg;
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;// 确保内核线程在 Supervisor 模式下运行，允许中断响应但不响应中断。
    tf.epc = (uintptr_t)kernel_thread_entry;
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
}

// setup_kstack - alloc pages with size KSTACKPAGE as process kernel stack
static int
setup_kstack(struct proc_struct *proc) {
    struct Page *page = alloc_pages(KSTACKPAGE);// 分配内存页作为内核栈
    if (page != NULL) {
        proc->kstack = (uintptr_t)page2kva(page);
        return 0;
    }
    return -E_NO_MEM;// 内存不足
}

// put_kstack - free the memory space of process kernel stack
static void
put_kstack(struct proc_struct *proc) {// 释放内核栈
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
}

// copy_mm - process "proc" duplicate OR share process "current"'s mm according clone_flags
//         - if clone_flags & CLONE_VM, then "share" ; else "duplicate"
static int
copy_mm(uint32_t clone_flags, struct proc_struct *proc) {// 内核线程或者用户进程
    assert(current->mm == NULL);
    /* do nothing in this project */
    return 0;
}

// copy_thread - setup the trapframe on the  process's kernel stack top and
//             - setup the kernel entry point and stack of process
static void
copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf) {
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));// 指向新进程的tf，被放置在内核栈的顶部
    *(proc->tf) = *tf;// 传递

    // Set a0 to 0 so a child process knows it's just forked
    proc->tf->gpr.a0 = 0;// 子进程
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;// 是否使用esp，子进程栈顶

    proc->context.ra = (uintptr_t)forkret;// 返回用户态
    proc->context.sp = (uintptr_t)(proc->tf);
}

/* do_fork -     parent process for a new child process
 * @clone_flags: used to guide how to clone the child process
 * @stack:       the parent's user stack pointer. if stack==0, It means to fork a kernel thread.
 * @tf:          the trapframe info, which will be copied to child process's proc->tf
 */
int
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
    cprintf("THIS MY: do_fork begin! \n");
    int ret = -E_NO_FREE_PROC;
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS) {// 进程数达到最大
        goto fork_out;
    }
    ret = -E_NO_MEM;
    //LAB4:EXERCISE2 YOUR CODE
    /*
     * Some Useful MACROs, Functions and DEFINEs, you can use them in below implementation.
     * MACROs or Functions:
     *   alloc_proc:   create a proc struct and init fields (lab4:exercise1)
     *   setup_kstack: alloc pages with size KSTACKPAGE as process kernel stack
     *   copy_mm:      process "proc" duplicate OR share process "current"'s mm according clone_flags
     *                 if clone_flags & CLONE_VM, then "share" ; else "duplicate"
     *   copy_thread:  setup the trapframe on the  process's kernel stack top and
     *                 setup the kernel entry point and stack of process
     *   hash_proc:    add proc into proc hash_list
     *   get_pid:      alloc a unique pid for process
     *   wakeup_proc:  set proc->state = PROC_RUNNABLE
     * VARIABLES:
     *   proc_list:    the process set's list
     *   nr_process:   the number of process set
     */

    //    1. call alloc_proc to allocate a proc_struct
    //    2. call setup_kstack to allocate a kernel stack for child process
    //    3. call copy_mm to dup OR share mm according clone_flag
    //    4. call copy_thread to setup tf & context in proc_struct
    //    5. insert proc_struct into hash_list && proc_list
    //    6. call wakeup_proc to make the new child process RUNNABLE
    //    7. set ret vaule using child proc's pid

// 分配并初始化进程控制块（alloc_proc函数）
// 分配并初始化内核栈（setup_stack函数）
// 根据clone_flags决定是复制还是共享内存管理系统（copy_mm函数）
// 设置进程的中断帧和上下文（copy_thread函数）
// 把设置好的进程加入链表
// 将新建的进程设为就绪态
// 将返回值设为线程id
    // Step 1: Call alloc_proc to allocate a proc_struct
    if ((proc = alloc_proc()) == NULL) {
        goto bad_fork_cleanup_proc;
    }
    // Step 2: Call setup_kstack to allocate a kernel stack for the child process
    if (setup_kstack(proc) != 0) {
        goto bad_fork_cleanup_kstack;
    }

    // Step 3: Call copy_mm to duplicate or share memory management
    if (copy_mm(clone_flags, proc) != 0) {// 本实验没有用
        goto bad_fork_cleanup_kstack;
    }

    // Step 4: Call copy_thread to set up the trapframe and context
    copy_thread(proc, stack, tf);

    // Step 5: Call hash_proc to add the child process to the hash list
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        // 生成并设置新的pid
        proc->pid = get_pid();
        // 把proc加入全局线程控制块哈希表
        hash_proc(proc);
        // 把proc加入全局线程控制块双向链表
        list_add(&proc_list, &(proc->list_link));
        nr_process ++;
    }
    local_intr_restore(intr_flag);
    // Step 6: Call wakeup_proc to mark the new child process as RUNNABLE
    wakeup_proc(proc);// PROC_RUNNABLE

    // Step 7: Set the return value using the child process's PID
    cprintf("THIS MY: do_fork proc create over thread: %d! isNULL:%d \n", proc->pid, proc == NULL);
    ret = proc->pid;
    goto fork_out;

fork_out:
    return ret;

bad_fork_cleanup_kstack:// 保证没有内存泄漏
    put_kstack(proc);
bad_fork_cleanup_proc:// 新进程分配进程结构时出现错误
    kfree(proc);
    goto fork_out;
}



// do_exit - called by sys_exit
//   1. call exit_mmap & put_pgdir & mm_destroy to free the almost all memory space of process
//   2. set process' state as PROC_ZOMBIE, then call wakeup_proc(parent) to ask parent reclaim itself.
//   3. call scheduler to switch to other process
int
do_exit(int error_code) {
    panic("process exit!!.\n");
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
    cprintf("To U: \"%s\".\n", (const char *)arg);
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
    return 0;
}

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {

    cprintf("proc_init begin! \n");

    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
        panic("cannot alloc idleproc.\n");
    }

    // check the proc structure
    int *context_mem = (int*) kmalloc(sizeof(struct context));
    memset(context_mem, 0, sizeof(struct context));
    int context_init_flag = memcmp(&(idleproc->context), context_mem, sizeof(struct context));

    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);
    memset(proc_name_mem, 0, PROC_NAME_LEN);
    int proc_name_flag = memcmp(&(idleproc->name), proc_name_mem, PROC_NAME_LEN);

    //cprintf("proc_init idleproc structure is created! \n");
    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
        && idleproc->state == PROC_UNINIT && idleproc->pid == -1 && idleproc->runs == 0
        && idleproc->kstack == 0 && idleproc->need_resched == 0 && idleproc->parent == NULL 
        && idleproc->mm == NULL && idleproc->flags == 0 && !proc_name_flag
    ){
        cprintf("alloc_proc() correct!\n");
    }
    else{
        cprintf("proc_init idleproc structure init wrong! cr3:%d, tf:%d, context_init_flag:%d, \
        state:%d, pid:%d, runs:%d, kstack:%d, need_resched:%d, parent:%d, mm:%d, flags:%d, \
        proc_name_flag:%d\n",idleproc->cr3 == boot_cr3 , idleproc->tf == NULL , !context_init_flag
        , idleproc->state == PROC_UNINIT , idleproc->pid == -1 , idleproc->runs == 0
        , idleproc->kstack == 0 , idleproc->need_resched == 0 , idleproc->parent == NULL 
        , idleproc->mm == NULL , idleproc->flags == 0 , !proc_name_flag);
    }
    //cprintf("proc_init idleproc structure begin setting! \n");
    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
    idleproc->kstack = (uintptr_t)bootstack;
    idleproc->need_resched = 1;
    set_proc_name(idleproc, "idle");
    nr_process ++;
    //cprintf("proc_init idleproc structure end setting! \n");
    current = idleproc;// 

    int pid = kernel_thread(init_main, "Hello world!!", 0);// 创建线程并返回pid
    if (pid <= 0) {
        panic("create init_main failed.\n");
    }
    cprintf("proc_init created thread: %d! \n", pid);
    initproc = find_proc(pid);
    cprintf("proc_init find thread: %d, isnull?= %d! \n", pid, initproc == NULL);
    set_proc_name(initproc, "init");
    //cprintf("proc_init set name thread: %d! \n", pid);
    assert(idleproc != NULL && idleproc->pid == 0);
    assert(initproc != NULL && initproc->pid == 1);
    cprintf("proc_init end! \n");
    cpu_idle();
}

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {// 不断调用schedule
    cprintf("cpu_idle begin! \n");
    while (1) {
        if (current->need_resched) {
            schedule();
        }
    }
}

