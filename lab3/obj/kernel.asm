
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02092b7          	lui	t0,0xc0209
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	01e31313          	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000c:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc0200010:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200014:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200018:	03f31313          	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc020001c:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc0200020:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200024:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200028:	c0209137          	lui	sp,0xc0209

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc020002c:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200030:	03628293          	addi	t0,t0,54 # ffffffffc0200036 <kern_init>
    jr t0
ffffffffc0200034:	8282                	jr	t0

ffffffffc0200036 <kern_init>:


int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	0000a517          	auipc	a0,0xa
ffffffffc020003a:	00a50513          	addi	a0,a0,10 # ffffffffc020a040 <edata>
ffffffffc020003e:	00011617          	auipc	a2,0x11
ffffffffc0200042:	56260613          	addi	a2,a2,1378 # ffffffffc02115a0 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	5f9030ef          	jal	ra,ffffffffc0203e46 <memset>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200052:	00004597          	auipc	a1,0x4
ffffffffc0200056:	2d658593          	addi	a1,a1,726 # ffffffffc0204328 <etext+0x2>
ffffffffc020005a:	00004517          	auipc	a0,0x4
ffffffffc020005e:	2ee50513          	addi	a0,a0,750 # ffffffffc0204348 <etext+0x22>
ffffffffc0200062:	05c000ef          	jal	ra,ffffffffc02000be <cprintf>

    print_kerninfo();
ffffffffc0200066:	100000ef          	jal	ra,ffffffffc0200166 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006a:	6c5020ef          	jal	ra,ffffffffc0202f2e <pmm_init>

    idt_init();                 // init interrupt descriptor table
ffffffffc020006e:	504000ef          	jal	ra,ffffffffc0200572 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc0200072:	43f000ef          	jal	ra,ffffffffc0200cb0 <vmm_init>

    ide_init();                 // init ide devices
ffffffffc0200076:	35e000ef          	jal	ra,ffffffffc02003d4 <ide_init>
    swap_init();                // init swap
ffffffffc020007a:	266010ef          	jal	ra,ffffffffc02012e0 <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020007e:	3ae000ef          	jal	ra,ffffffffc020042c <clock_init>
    // intr_enable();              // enable irq interrupt



    /* do nothing */
    while (1);
ffffffffc0200082:	a001                	j	ffffffffc0200082 <kern_init+0x4c>

ffffffffc0200084 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200084:	1141                	addi	sp,sp,-16
ffffffffc0200086:	e022                	sd	s0,0(sp)
ffffffffc0200088:	e406                	sd	ra,8(sp)
ffffffffc020008a:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020008c:	3f6000ef          	jal	ra,ffffffffc0200482 <cons_putc>
    (*cnt) ++;
ffffffffc0200090:	401c                	lw	a5,0(s0)
}
ffffffffc0200092:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200094:	2785                	addiw	a5,a5,1
ffffffffc0200096:	c01c                	sw	a5,0(s0)
}
ffffffffc0200098:	6402                	ld	s0,0(sp)
ffffffffc020009a:	0141                	addi	sp,sp,16
ffffffffc020009c:	8082                	ret

ffffffffc020009e <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc020009e:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a0:	86ae                	mv	a3,a1
ffffffffc02000a2:	862a                	mv	a2,a0
ffffffffc02000a4:	006c                	addi	a1,sp,12
ffffffffc02000a6:	00000517          	auipc	a0,0x0
ffffffffc02000aa:	fde50513          	addi	a0,a0,-34 # ffffffffc0200084 <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000ae:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000b0:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000b2:	62b030ef          	jal	ra,ffffffffc0203edc <vprintfmt>
    return cnt;
}
ffffffffc02000b6:	60e2                	ld	ra,24(sp)
ffffffffc02000b8:	4532                	lw	a0,12(sp)
ffffffffc02000ba:	6105                	addi	sp,sp,32
ffffffffc02000bc:	8082                	ret

ffffffffc02000be <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000be:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000c0:	02810313          	addi	t1,sp,40 # ffffffffc0209028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000c4:	f42e                	sd	a1,40(sp)
ffffffffc02000c6:	f832                	sd	a2,48(sp)
ffffffffc02000c8:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000ca:	862a                	mv	a2,a0
ffffffffc02000cc:	004c                	addi	a1,sp,4
ffffffffc02000ce:	00000517          	auipc	a0,0x0
ffffffffc02000d2:	fb650513          	addi	a0,a0,-74 # ffffffffc0200084 <cputch>
ffffffffc02000d6:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000d8:	ec06                	sd	ra,24(sp)
ffffffffc02000da:	e0ba                	sd	a4,64(sp)
ffffffffc02000dc:	e4be                	sd	a5,72(sp)
ffffffffc02000de:	e8c2                	sd	a6,80(sp)
ffffffffc02000e0:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000e2:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000e4:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000e6:	5f7030ef          	jal	ra,ffffffffc0203edc <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000ea:	60e2                	ld	ra,24(sp)
ffffffffc02000ec:	4512                	lw	a0,4(sp)
ffffffffc02000ee:	6125                	addi	sp,sp,96
ffffffffc02000f0:	8082                	ret

ffffffffc02000f2 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000f2:	3900006f          	j	ffffffffc0200482 <cons_putc>

ffffffffc02000f6 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc02000f6:	1141                	addi	sp,sp,-16
ffffffffc02000f8:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02000fa:	3be000ef          	jal	ra,ffffffffc02004b8 <cons_getc>
ffffffffc02000fe:	dd75                	beqz	a0,ffffffffc02000fa <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200100:	60a2                	ld	ra,8(sp)
ffffffffc0200102:	0141                	addi	sp,sp,16
ffffffffc0200104:	8082                	ret

ffffffffc0200106 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200106:	00011317          	auipc	t1,0x11
ffffffffc020010a:	33a30313          	addi	t1,t1,826 # ffffffffc0211440 <is_panic>
ffffffffc020010e:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200112:	715d                	addi	sp,sp,-80
ffffffffc0200114:	ec06                	sd	ra,24(sp)
ffffffffc0200116:	e822                	sd	s0,16(sp)
ffffffffc0200118:	f436                	sd	a3,40(sp)
ffffffffc020011a:	f83a                	sd	a4,48(sp)
ffffffffc020011c:	fc3e                	sd	a5,56(sp)
ffffffffc020011e:	e0c2                	sd	a6,64(sp)
ffffffffc0200120:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200122:	02031c63          	bnez	t1,ffffffffc020015a <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200126:	4785                	li	a5,1
ffffffffc0200128:	8432                	mv	s0,a2
ffffffffc020012a:	00011717          	auipc	a4,0x11
ffffffffc020012e:	30f72b23          	sw	a5,790(a4) # ffffffffc0211440 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200132:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc0200134:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200136:	85aa                	mv	a1,a0
ffffffffc0200138:	00004517          	auipc	a0,0x4
ffffffffc020013c:	21850513          	addi	a0,a0,536 # ffffffffc0204350 <etext+0x2a>
    va_start(ap, fmt);
ffffffffc0200140:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200142:	f7dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200146:	65a2                	ld	a1,8(sp)
ffffffffc0200148:	8522                	mv	a0,s0
ffffffffc020014a:	f55ff0ef          	jal	ra,ffffffffc020009e <vcprintf>
    cprintf("\n");
ffffffffc020014e:	00006517          	auipc	a0,0x6
ffffffffc0200152:	bba50513          	addi	a0,a0,-1094 # ffffffffc0205d08 <default_pmm_manager+0x598>
ffffffffc0200156:	f69ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc020015a:	3a0000ef          	jal	ra,ffffffffc02004fa <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc020015e:	4501                	li	a0,0
ffffffffc0200160:	132000ef          	jal	ra,ffffffffc0200292 <kmonitor>
ffffffffc0200164:	bfed                	j	ffffffffc020015e <__panic+0x58>

ffffffffc0200166 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200166:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200168:	00004517          	auipc	a0,0x4
ffffffffc020016c:	23850513          	addi	a0,a0,568 # ffffffffc02043a0 <etext+0x7a>
void print_kerninfo(void) {
ffffffffc0200170:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200172:	f4dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200176:	00000597          	auipc	a1,0x0
ffffffffc020017a:	ec058593          	addi	a1,a1,-320 # ffffffffc0200036 <kern_init>
ffffffffc020017e:	00004517          	auipc	a0,0x4
ffffffffc0200182:	24250513          	addi	a0,a0,578 # ffffffffc02043c0 <etext+0x9a>
ffffffffc0200186:	f39ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc020018a:	00004597          	auipc	a1,0x4
ffffffffc020018e:	19c58593          	addi	a1,a1,412 # ffffffffc0204326 <etext>
ffffffffc0200192:	00004517          	auipc	a0,0x4
ffffffffc0200196:	24e50513          	addi	a0,a0,590 # ffffffffc02043e0 <etext+0xba>
ffffffffc020019a:	f25ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020019e:	0000a597          	auipc	a1,0xa
ffffffffc02001a2:	ea258593          	addi	a1,a1,-350 # ffffffffc020a040 <edata>
ffffffffc02001a6:	00004517          	auipc	a0,0x4
ffffffffc02001aa:	25a50513          	addi	a0,a0,602 # ffffffffc0204400 <etext+0xda>
ffffffffc02001ae:	f11ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc02001b2:	00011597          	auipc	a1,0x11
ffffffffc02001b6:	3ee58593          	addi	a1,a1,1006 # ffffffffc02115a0 <end>
ffffffffc02001ba:	00004517          	auipc	a0,0x4
ffffffffc02001be:	26650513          	addi	a0,a0,614 # ffffffffc0204420 <etext+0xfa>
ffffffffc02001c2:	efdff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc02001c6:	00011597          	auipc	a1,0x11
ffffffffc02001ca:	7d958593          	addi	a1,a1,2009 # ffffffffc021199f <end+0x3ff>
ffffffffc02001ce:	00000797          	auipc	a5,0x0
ffffffffc02001d2:	e6878793          	addi	a5,a5,-408 # ffffffffc0200036 <kern_init>
ffffffffc02001d6:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001da:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001de:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001e0:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001e4:	95be                	add	a1,a1,a5
ffffffffc02001e6:	85a9                	srai	a1,a1,0xa
ffffffffc02001e8:	00004517          	auipc	a0,0x4
ffffffffc02001ec:	25850513          	addi	a0,a0,600 # ffffffffc0204440 <etext+0x11a>
}
ffffffffc02001f0:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001f2:	ecdff06f          	j	ffffffffc02000be <cprintf>

ffffffffc02001f6 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001f6:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001f8:	00004617          	auipc	a2,0x4
ffffffffc02001fc:	17860613          	addi	a2,a2,376 # ffffffffc0204370 <etext+0x4a>
ffffffffc0200200:	04e00593          	li	a1,78
ffffffffc0200204:	00004517          	auipc	a0,0x4
ffffffffc0200208:	18450513          	addi	a0,a0,388 # ffffffffc0204388 <etext+0x62>
void print_stackframe(void) {
ffffffffc020020c:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc020020e:	ef9ff0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0200212 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200212:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200214:	00004617          	auipc	a2,0x4
ffffffffc0200218:	33460613          	addi	a2,a2,820 # ffffffffc0204548 <commands+0xd8>
ffffffffc020021c:	00004597          	auipc	a1,0x4
ffffffffc0200220:	34c58593          	addi	a1,a1,844 # ffffffffc0204568 <commands+0xf8>
ffffffffc0200224:	00004517          	auipc	a0,0x4
ffffffffc0200228:	34c50513          	addi	a0,a0,844 # ffffffffc0204570 <commands+0x100>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020022c:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020022e:	e91ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0200232:	00004617          	auipc	a2,0x4
ffffffffc0200236:	34e60613          	addi	a2,a2,846 # ffffffffc0204580 <commands+0x110>
ffffffffc020023a:	00004597          	auipc	a1,0x4
ffffffffc020023e:	36e58593          	addi	a1,a1,878 # ffffffffc02045a8 <commands+0x138>
ffffffffc0200242:	00004517          	auipc	a0,0x4
ffffffffc0200246:	32e50513          	addi	a0,a0,814 # ffffffffc0204570 <commands+0x100>
ffffffffc020024a:	e75ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc020024e:	00004617          	auipc	a2,0x4
ffffffffc0200252:	36a60613          	addi	a2,a2,874 # ffffffffc02045b8 <commands+0x148>
ffffffffc0200256:	00004597          	auipc	a1,0x4
ffffffffc020025a:	38258593          	addi	a1,a1,898 # ffffffffc02045d8 <commands+0x168>
ffffffffc020025e:	00004517          	auipc	a0,0x4
ffffffffc0200262:	31250513          	addi	a0,a0,786 # ffffffffc0204570 <commands+0x100>
ffffffffc0200266:	e59ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    }
    return 0;
}
ffffffffc020026a:	60a2                	ld	ra,8(sp)
ffffffffc020026c:	4501                	li	a0,0
ffffffffc020026e:	0141                	addi	sp,sp,16
ffffffffc0200270:	8082                	ret

ffffffffc0200272 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200272:	1141                	addi	sp,sp,-16
ffffffffc0200274:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200276:	ef1ff0ef          	jal	ra,ffffffffc0200166 <print_kerninfo>
    return 0;
}
ffffffffc020027a:	60a2                	ld	ra,8(sp)
ffffffffc020027c:	4501                	li	a0,0
ffffffffc020027e:	0141                	addi	sp,sp,16
ffffffffc0200280:	8082                	ret

ffffffffc0200282 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200282:	1141                	addi	sp,sp,-16
ffffffffc0200284:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200286:	f71ff0ef          	jal	ra,ffffffffc02001f6 <print_stackframe>
    return 0;
}
ffffffffc020028a:	60a2                	ld	ra,8(sp)
ffffffffc020028c:	4501                	li	a0,0
ffffffffc020028e:	0141                	addi	sp,sp,16
ffffffffc0200290:	8082                	ret

ffffffffc0200292 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200292:	7115                	addi	sp,sp,-224
ffffffffc0200294:	e962                	sd	s8,144(sp)
ffffffffc0200296:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200298:	00004517          	auipc	a0,0x4
ffffffffc020029c:	22050513          	addi	a0,a0,544 # ffffffffc02044b8 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc02002a0:	ed86                	sd	ra,216(sp)
ffffffffc02002a2:	e9a2                	sd	s0,208(sp)
ffffffffc02002a4:	e5a6                	sd	s1,200(sp)
ffffffffc02002a6:	e1ca                	sd	s2,192(sp)
ffffffffc02002a8:	fd4e                	sd	s3,184(sp)
ffffffffc02002aa:	f952                	sd	s4,176(sp)
ffffffffc02002ac:	f556                	sd	s5,168(sp)
ffffffffc02002ae:	f15a                	sd	s6,160(sp)
ffffffffc02002b0:	ed5e                	sd	s7,152(sp)
ffffffffc02002b2:	e566                	sd	s9,136(sp)
ffffffffc02002b4:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002b6:	e09ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc02002ba:	00004517          	auipc	a0,0x4
ffffffffc02002be:	22650513          	addi	a0,a0,550 # ffffffffc02044e0 <commands+0x70>
ffffffffc02002c2:	dfdff0ef          	jal	ra,ffffffffc02000be <cprintf>
    if (tf != NULL) {
ffffffffc02002c6:	000c0563          	beqz	s8,ffffffffc02002d0 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002ca:	8562                	mv	a0,s8
ffffffffc02002cc:	492000ef          	jal	ra,ffffffffc020075e <print_trapframe>
ffffffffc02002d0:	00004c97          	auipc	s9,0x4
ffffffffc02002d4:	1a0c8c93          	addi	s9,s9,416 # ffffffffc0204470 <commands>
        if ((buf = readline("")) != NULL) {
ffffffffc02002d8:	00005997          	auipc	s3,0x5
ffffffffc02002dc:	09898993          	addi	s3,s3,152 # ffffffffc0205370 <commands+0xf00>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002e0:	00004917          	auipc	s2,0x4
ffffffffc02002e4:	22890913          	addi	s2,s2,552 # ffffffffc0204508 <commands+0x98>
        if (argc == MAXARGS - 1) {
ffffffffc02002e8:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002ea:	00004b17          	auipc	s6,0x4
ffffffffc02002ee:	226b0b13          	addi	s6,s6,550 # ffffffffc0204510 <commands+0xa0>
    if (argc == 0) {
ffffffffc02002f2:	00004a97          	auipc	s5,0x4
ffffffffc02002f6:	276a8a93          	addi	s5,s5,630 # ffffffffc0204568 <commands+0xf8>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002fa:	4b8d                	li	s7,3
        if ((buf = readline("")) != NULL) {
ffffffffc02002fc:	854e                	mv	a0,s3
ffffffffc02002fe:	76b030ef          	jal	ra,ffffffffc0204268 <readline>
ffffffffc0200302:	842a                	mv	s0,a0
ffffffffc0200304:	dd65                	beqz	a0,ffffffffc02002fc <kmonitor+0x6a>
ffffffffc0200306:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc020030a:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020030c:	c999                	beqz	a1,ffffffffc0200322 <kmonitor+0x90>
ffffffffc020030e:	854a                	mv	a0,s2
ffffffffc0200310:	319030ef          	jal	ra,ffffffffc0203e28 <strchr>
ffffffffc0200314:	c925                	beqz	a0,ffffffffc0200384 <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc0200316:	00144583          	lbu	a1,1(s0)
ffffffffc020031a:	00040023          	sb	zero,0(s0)
ffffffffc020031e:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200320:	f5fd                	bnez	a1,ffffffffc020030e <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc0200322:	dce9                	beqz	s1,ffffffffc02002fc <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200324:	6582                	ld	a1,0(sp)
ffffffffc0200326:	00004d17          	auipc	s10,0x4
ffffffffc020032a:	14ad0d13          	addi	s10,s10,330 # ffffffffc0204470 <commands>
    if (argc == 0) {
ffffffffc020032e:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200330:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200332:	0d61                	addi	s10,s10,24
ffffffffc0200334:	2cb030ef          	jal	ra,ffffffffc0203dfe <strcmp>
ffffffffc0200338:	c919                	beqz	a0,ffffffffc020034e <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020033a:	2405                	addiw	s0,s0,1
ffffffffc020033c:	09740463          	beq	s0,s7,ffffffffc02003c4 <kmonitor+0x132>
ffffffffc0200340:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200344:	6582                	ld	a1,0(sp)
ffffffffc0200346:	0d61                	addi	s10,s10,24
ffffffffc0200348:	2b7030ef          	jal	ra,ffffffffc0203dfe <strcmp>
ffffffffc020034c:	f57d                	bnez	a0,ffffffffc020033a <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc020034e:	00141793          	slli	a5,s0,0x1
ffffffffc0200352:	97a2                	add	a5,a5,s0
ffffffffc0200354:	078e                	slli	a5,a5,0x3
ffffffffc0200356:	97e6                	add	a5,a5,s9
ffffffffc0200358:	6b9c                	ld	a5,16(a5)
ffffffffc020035a:	8662                	mv	a2,s8
ffffffffc020035c:	002c                	addi	a1,sp,8
ffffffffc020035e:	fff4851b          	addiw	a0,s1,-1
ffffffffc0200362:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200364:	f8055ce3          	bgez	a0,ffffffffc02002fc <kmonitor+0x6a>
}
ffffffffc0200368:	60ee                	ld	ra,216(sp)
ffffffffc020036a:	644e                	ld	s0,208(sp)
ffffffffc020036c:	64ae                	ld	s1,200(sp)
ffffffffc020036e:	690e                	ld	s2,192(sp)
ffffffffc0200370:	79ea                	ld	s3,184(sp)
ffffffffc0200372:	7a4a                	ld	s4,176(sp)
ffffffffc0200374:	7aaa                	ld	s5,168(sp)
ffffffffc0200376:	7b0a                	ld	s6,160(sp)
ffffffffc0200378:	6bea                	ld	s7,152(sp)
ffffffffc020037a:	6c4a                	ld	s8,144(sp)
ffffffffc020037c:	6caa                	ld	s9,136(sp)
ffffffffc020037e:	6d0a                	ld	s10,128(sp)
ffffffffc0200380:	612d                	addi	sp,sp,224
ffffffffc0200382:	8082                	ret
        if (*buf == '\0') {
ffffffffc0200384:	00044783          	lbu	a5,0(s0)
ffffffffc0200388:	dfc9                	beqz	a5,ffffffffc0200322 <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc020038a:	03448863          	beq	s1,s4,ffffffffc02003ba <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc020038e:	00349793          	slli	a5,s1,0x3
ffffffffc0200392:	0118                	addi	a4,sp,128
ffffffffc0200394:	97ba                	add	a5,a5,a4
ffffffffc0200396:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020039a:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc020039e:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003a0:	e591                	bnez	a1,ffffffffc02003ac <kmonitor+0x11a>
ffffffffc02003a2:	b749                	j	ffffffffc0200324 <kmonitor+0x92>
            buf ++;
ffffffffc02003a4:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003a6:	00044583          	lbu	a1,0(s0)
ffffffffc02003aa:	ddad                	beqz	a1,ffffffffc0200324 <kmonitor+0x92>
ffffffffc02003ac:	854a                	mv	a0,s2
ffffffffc02003ae:	27b030ef          	jal	ra,ffffffffc0203e28 <strchr>
ffffffffc02003b2:	d96d                	beqz	a0,ffffffffc02003a4 <kmonitor+0x112>
ffffffffc02003b4:	00044583          	lbu	a1,0(s0)
ffffffffc02003b8:	bf91                	j	ffffffffc020030c <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02003ba:	45c1                	li	a1,16
ffffffffc02003bc:	855a                	mv	a0,s6
ffffffffc02003be:	d01ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02003c2:	b7f1                	j	ffffffffc020038e <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc02003c4:	6582                	ld	a1,0(sp)
ffffffffc02003c6:	00004517          	auipc	a0,0x4
ffffffffc02003ca:	16a50513          	addi	a0,a0,362 # ffffffffc0204530 <commands+0xc0>
ffffffffc02003ce:	cf1ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    return 0;
ffffffffc02003d2:	b72d                	j	ffffffffc02002fc <kmonitor+0x6a>

ffffffffc02003d4 <ide_init>:
#include <string.h>
#include <trap.h>
#include <riscv.h>

// 模拟硬盘
void ide_init(void) {}
ffffffffc02003d4:	8082                	ret

ffffffffc02003d6 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];// 56 * 512

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc02003d6:	00253513          	sltiu	a0,a0,2
ffffffffc02003da:	8082                	ret

ffffffffc02003dc <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc02003dc:	03800513          	li	a0,56
ffffffffc02003e0:	8082                	ret

ffffffffc02003e2 <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {// 取数据
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02003e2:	0000a797          	auipc	a5,0xa
ffffffffc02003e6:	c5e78793          	addi	a5,a5,-930 # ffffffffc020a040 <edata>
ffffffffc02003ea:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {// 取数据
ffffffffc02003ee:	1141                	addi	sp,sp,-16
ffffffffc02003f0:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02003f2:	95be                	add	a1,a1,a5
ffffffffc02003f4:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {// 取数据
ffffffffc02003f8:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02003fa:	25f030ef          	jal	ra,ffffffffc0203e58 <memcpy>
    return 0;
}
ffffffffc02003fe:	60a2                	ld	ra,8(sp)
ffffffffc0200400:	4501                	li	a0,0
ffffffffc0200402:	0141                	addi	sp,sp,16
ffffffffc0200404:	8082                	ret

ffffffffc0200406 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {// 写数据
ffffffffc0200406:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200408:	0095979b          	slliw	a5,a1,0x9
ffffffffc020040c:	0000a517          	auipc	a0,0xa
ffffffffc0200410:	c3450513          	addi	a0,a0,-972 # ffffffffc020a040 <edata>
                   size_t nsecs) {// 写数据
ffffffffc0200414:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200416:	00969613          	slli	a2,a3,0x9
ffffffffc020041a:	85ba                	mv	a1,a4
ffffffffc020041c:	953e                	add	a0,a0,a5
                   size_t nsecs) {// 写数据
ffffffffc020041e:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200420:	239030ef          	jal	ra,ffffffffc0203e58 <memcpy>
    return 0;
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
ffffffffc0200426:	4501                	li	a0,0
ffffffffc0200428:	0141                	addi	sp,sp,16
ffffffffc020042a:	8082                	ret

ffffffffc020042c <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc020042c:	67e1                	lui	a5,0x18
ffffffffc020042e:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc0200432:	00011717          	auipc	a4,0x11
ffffffffc0200436:	00f73b23          	sd	a5,22(a4) # ffffffffc0211448 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020043a:	c0102573          	rdtime	a0
static inline void sbi_set_timer(uint64_t stime_value)
{
#if __riscv_xlen == 32
	SBI_CALL_2(SBI_SET_TIMER, stime_value, stime_value >> 32);
#else
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc020043e:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200440:	953e                	add	a0,a0,a5
ffffffffc0200442:	4601                	li	a2,0
ffffffffc0200444:	4881                	li	a7,0
ffffffffc0200446:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc020044a:	02000793          	li	a5,32
ffffffffc020044e:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc0200452:	00004517          	auipc	a0,0x4
ffffffffc0200456:	19650513          	addi	a0,a0,406 # ffffffffc02045e8 <commands+0x178>
    ticks = 0;
ffffffffc020045a:	00011797          	auipc	a5,0x11
ffffffffc020045e:	0007bf23          	sd	zero,30(a5) # ffffffffc0211478 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200462:	c5dff06f          	j	ffffffffc02000be <cprintf>

ffffffffc0200466 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200466:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020046a:	00011797          	auipc	a5,0x11
ffffffffc020046e:	fde78793          	addi	a5,a5,-34 # ffffffffc0211448 <timebase>
ffffffffc0200472:	639c                	ld	a5,0(a5)
ffffffffc0200474:	4581                	li	a1,0
ffffffffc0200476:	4601                	li	a2,0
ffffffffc0200478:	953e                	add	a0,a0,a5
ffffffffc020047a:	4881                	li	a7,0
ffffffffc020047c:	00000073          	ecall
ffffffffc0200480:	8082                	ret

ffffffffc0200482 <cons_putc>:
#include <intr.h>
#include <mmu.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200482:	100027f3          	csrr	a5,sstatus
ffffffffc0200486:	8b89                	andi	a5,a5,2
ffffffffc0200488:	0ff57513          	andi	a0,a0,255
ffffffffc020048c:	e799                	bnez	a5,ffffffffc020049a <cons_putc+0x18>
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc020048e:	4581                	li	a1,0
ffffffffc0200490:	4601                	li	a2,0
ffffffffc0200492:	4885                	li	a7,1
ffffffffc0200494:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc0200498:	8082                	ret

/* cons_init - initializes the console devices */
void cons_init(void) {}

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc020049a:	1101                	addi	sp,sp,-32
ffffffffc020049c:	ec06                	sd	ra,24(sp)
ffffffffc020049e:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02004a0:	05a000ef          	jal	ra,ffffffffc02004fa <intr_disable>
ffffffffc02004a4:	6522                	ld	a0,8(sp)
ffffffffc02004a6:	4581                	li	a1,0
ffffffffc02004a8:	4601                	li	a2,0
ffffffffc02004aa:	4885                	li	a7,1
ffffffffc02004ac:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc02004b0:	60e2                	ld	ra,24(sp)
ffffffffc02004b2:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02004b4:	0400006f          	j	ffffffffc02004f4 <intr_enable>

ffffffffc02004b8 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02004b8:	100027f3          	csrr	a5,sstatus
ffffffffc02004bc:	8b89                	andi	a5,a5,2
ffffffffc02004be:	eb89                	bnez	a5,ffffffffc02004d0 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc02004c0:	4501                	li	a0,0
ffffffffc02004c2:	4581                	li	a1,0
ffffffffc02004c4:	4601                	li	a2,0
ffffffffc02004c6:	4889                	li	a7,2
ffffffffc02004c8:	00000073          	ecall
ffffffffc02004cc:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc02004ce:	8082                	ret
int cons_getc(void) {
ffffffffc02004d0:	1101                	addi	sp,sp,-32
ffffffffc02004d2:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02004d4:	026000ef          	jal	ra,ffffffffc02004fa <intr_disable>
ffffffffc02004d8:	4501                	li	a0,0
ffffffffc02004da:	4581                	li	a1,0
ffffffffc02004dc:	4601                	li	a2,0
ffffffffc02004de:	4889                	li	a7,2
ffffffffc02004e0:	00000073          	ecall
ffffffffc02004e4:	2501                	sext.w	a0,a0
ffffffffc02004e6:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02004e8:	00c000ef          	jal	ra,ffffffffc02004f4 <intr_enable>
}
ffffffffc02004ec:	60e2                	ld	ra,24(sp)
ffffffffc02004ee:	6522                	ld	a0,8(sp)
ffffffffc02004f0:	6105                	addi	sp,sp,32
ffffffffc02004f2:	8082                	ret

ffffffffc02004f4 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004f4:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02004f8:	8082                	ret

ffffffffc02004fa <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004fa:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02004fe:	8082                	ret

ffffffffc0200500 <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200500:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc0200504:	1141                	addi	sp,sp,-16
ffffffffc0200506:	e022                	sd	s0,0(sp)
ffffffffc0200508:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc020050a:	1007f793          	andi	a5,a5,256
static int pgfault_handler(struct trapframe *tf) {
ffffffffc020050e:	842a                	mv	s0,a0
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc0200510:	11053583          	ld	a1,272(a0)
ffffffffc0200514:	05500613          	li	a2,85
ffffffffc0200518:	c399                	beqz	a5,ffffffffc020051e <pgfault_handler+0x1e>
ffffffffc020051a:	04b00613          	li	a2,75
ffffffffc020051e:	11843703          	ld	a4,280(s0)
ffffffffc0200522:	47bd                	li	a5,15
ffffffffc0200524:	05700693          	li	a3,87
ffffffffc0200528:	00f70463          	beq	a4,a5,ffffffffc0200530 <pgfault_handler+0x30>
ffffffffc020052c:	05200693          	li	a3,82
ffffffffc0200530:	00004517          	auipc	a0,0x4
ffffffffc0200534:	3b050513          	addi	a0,a0,944 # ffffffffc02048e0 <commands+0x470>
ffffffffc0200538:	b87ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc020053c:	00011797          	auipc	a5,0x11
ffffffffc0200540:	f5478793          	addi	a5,a5,-172 # ffffffffc0211490 <check_mm_struct>
ffffffffc0200544:	6388                	ld	a0,0(a5)
ffffffffc0200546:	c911                	beqz	a0,ffffffffc020055a <pgfault_handler+0x5a>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200548:	11043603          	ld	a2,272(s0)
ffffffffc020054c:	11843583          	ld	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc0200550:	6402                	ld	s0,0(sp)
ffffffffc0200552:	60a2                	ld	ra,8(sp)
ffffffffc0200554:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200556:	4990006f          	j	ffffffffc02011ee <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc020055a:	00004617          	auipc	a2,0x4
ffffffffc020055e:	3a660613          	addi	a2,a2,934 # ffffffffc0204900 <commands+0x490>
ffffffffc0200562:	07800593          	li	a1,120
ffffffffc0200566:	00004517          	auipc	a0,0x4
ffffffffc020056a:	3b250513          	addi	a0,a0,946 # ffffffffc0204918 <commands+0x4a8>
ffffffffc020056e:	b99ff0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0200572 <idt_init>:
    write_csr(sscratch, 0);
ffffffffc0200572:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc0200576:	00000797          	auipc	a5,0x0
ffffffffc020057a:	49a78793          	addi	a5,a5,1178 # ffffffffc0200a10 <__alltraps>
ffffffffc020057e:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SIE);
ffffffffc0200582:	100167f3          	csrrsi	a5,sstatus,2
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200586:	000407b7          	lui	a5,0x40
ffffffffc020058a:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc020058e:	8082                	ret

ffffffffc0200590 <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200590:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200592:	1141                	addi	sp,sp,-16
ffffffffc0200594:	e022                	sd	s0,0(sp)
ffffffffc0200596:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200598:	00004517          	auipc	a0,0x4
ffffffffc020059c:	39850513          	addi	a0,a0,920 # ffffffffc0204930 <commands+0x4c0>
void print_regs(struct pushregs *gpr) {
ffffffffc02005a0:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02005a2:	b1dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc02005a6:	640c                	ld	a1,8(s0)
ffffffffc02005a8:	00004517          	auipc	a0,0x4
ffffffffc02005ac:	3a050513          	addi	a0,a0,928 # ffffffffc0204948 <commands+0x4d8>
ffffffffc02005b0:	b0fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02005b4:	680c                	ld	a1,16(s0)
ffffffffc02005b6:	00004517          	auipc	a0,0x4
ffffffffc02005ba:	3aa50513          	addi	a0,a0,938 # ffffffffc0204960 <commands+0x4f0>
ffffffffc02005be:	b01ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02005c2:	6c0c                	ld	a1,24(s0)
ffffffffc02005c4:	00004517          	auipc	a0,0x4
ffffffffc02005c8:	3b450513          	addi	a0,a0,948 # ffffffffc0204978 <commands+0x508>
ffffffffc02005cc:	af3ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02005d0:	700c                	ld	a1,32(s0)
ffffffffc02005d2:	00004517          	auipc	a0,0x4
ffffffffc02005d6:	3be50513          	addi	a0,a0,958 # ffffffffc0204990 <commands+0x520>
ffffffffc02005da:	ae5ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02005de:	740c                	ld	a1,40(s0)
ffffffffc02005e0:	00004517          	auipc	a0,0x4
ffffffffc02005e4:	3c850513          	addi	a0,a0,968 # ffffffffc02049a8 <commands+0x538>
ffffffffc02005e8:	ad7ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02005ec:	780c                	ld	a1,48(s0)
ffffffffc02005ee:	00004517          	auipc	a0,0x4
ffffffffc02005f2:	3d250513          	addi	a0,a0,978 # ffffffffc02049c0 <commands+0x550>
ffffffffc02005f6:	ac9ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02005fa:	7c0c                	ld	a1,56(s0)
ffffffffc02005fc:	00004517          	auipc	a0,0x4
ffffffffc0200600:	3dc50513          	addi	a0,a0,988 # ffffffffc02049d8 <commands+0x568>
ffffffffc0200604:	abbff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc0200608:	602c                	ld	a1,64(s0)
ffffffffc020060a:	00004517          	auipc	a0,0x4
ffffffffc020060e:	3e650513          	addi	a0,a0,998 # ffffffffc02049f0 <commands+0x580>
ffffffffc0200612:	aadff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200616:	642c                	ld	a1,72(s0)
ffffffffc0200618:	00004517          	auipc	a0,0x4
ffffffffc020061c:	3f050513          	addi	a0,a0,1008 # ffffffffc0204a08 <commands+0x598>
ffffffffc0200620:	a9fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200624:	682c                	ld	a1,80(s0)
ffffffffc0200626:	00004517          	auipc	a0,0x4
ffffffffc020062a:	3fa50513          	addi	a0,a0,1018 # ffffffffc0204a20 <commands+0x5b0>
ffffffffc020062e:	a91ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200632:	6c2c                	ld	a1,88(s0)
ffffffffc0200634:	00004517          	auipc	a0,0x4
ffffffffc0200638:	40450513          	addi	a0,a0,1028 # ffffffffc0204a38 <commands+0x5c8>
ffffffffc020063c:	a83ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200640:	702c                	ld	a1,96(s0)
ffffffffc0200642:	00004517          	auipc	a0,0x4
ffffffffc0200646:	40e50513          	addi	a0,a0,1038 # ffffffffc0204a50 <commands+0x5e0>
ffffffffc020064a:	a75ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020064e:	742c                	ld	a1,104(s0)
ffffffffc0200650:	00004517          	auipc	a0,0x4
ffffffffc0200654:	41850513          	addi	a0,a0,1048 # ffffffffc0204a68 <commands+0x5f8>
ffffffffc0200658:	a67ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020065c:	782c                	ld	a1,112(s0)
ffffffffc020065e:	00004517          	auipc	a0,0x4
ffffffffc0200662:	42250513          	addi	a0,a0,1058 # ffffffffc0204a80 <commands+0x610>
ffffffffc0200666:	a59ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020066a:	7c2c                	ld	a1,120(s0)
ffffffffc020066c:	00004517          	auipc	a0,0x4
ffffffffc0200670:	42c50513          	addi	a0,a0,1068 # ffffffffc0204a98 <commands+0x628>
ffffffffc0200674:	a4bff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200678:	604c                	ld	a1,128(s0)
ffffffffc020067a:	00004517          	auipc	a0,0x4
ffffffffc020067e:	43650513          	addi	a0,a0,1078 # ffffffffc0204ab0 <commands+0x640>
ffffffffc0200682:	a3dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200686:	644c                	ld	a1,136(s0)
ffffffffc0200688:	00004517          	auipc	a0,0x4
ffffffffc020068c:	44050513          	addi	a0,a0,1088 # ffffffffc0204ac8 <commands+0x658>
ffffffffc0200690:	a2fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200694:	684c                	ld	a1,144(s0)
ffffffffc0200696:	00004517          	auipc	a0,0x4
ffffffffc020069a:	44a50513          	addi	a0,a0,1098 # ffffffffc0204ae0 <commands+0x670>
ffffffffc020069e:	a21ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc02006a2:	6c4c                	ld	a1,152(s0)
ffffffffc02006a4:	00004517          	auipc	a0,0x4
ffffffffc02006a8:	45450513          	addi	a0,a0,1108 # ffffffffc0204af8 <commands+0x688>
ffffffffc02006ac:	a13ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc02006b0:	704c                	ld	a1,160(s0)
ffffffffc02006b2:	00004517          	auipc	a0,0x4
ffffffffc02006b6:	45e50513          	addi	a0,a0,1118 # ffffffffc0204b10 <commands+0x6a0>
ffffffffc02006ba:	a05ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02006be:	744c                	ld	a1,168(s0)
ffffffffc02006c0:	00004517          	auipc	a0,0x4
ffffffffc02006c4:	46850513          	addi	a0,a0,1128 # ffffffffc0204b28 <commands+0x6b8>
ffffffffc02006c8:	9f7ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02006cc:	784c                	ld	a1,176(s0)
ffffffffc02006ce:	00004517          	auipc	a0,0x4
ffffffffc02006d2:	47250513          	addi	a0,a0,1138 # ffffffffc0204b40 <commands+0x6d0>
ffffffffc02006d6:	9e9ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02006da:	7c4c                	ld	a1,184(s0)
ffffffffc02006dc:	00004517          	auipc	a0,0x4
ffffffffc02006e0:	47c50513          	addi	a0,a0,1148 # ffffffffc0204b58 <commands+0x6e8>
ffffffffc02006e4:	9dbff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02006e8:	606c                	ld	a1,192(s0)
ffffffffc02006ea:	00004517          	auipc	a0,0x4
ffffffffc02006ee:	48650513          	addi	a0,a0,1158 # ffffffffc0204b70 <commands+0x700>
ffffffffc02006f2:	9cdff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02006f6:	646c                	ld	a1,200(s0)
ffffffffc02006f8:	00004517          	auipc	a0,0x4
ffffffffc02006fc:	49050513          	addi	a0,a0,1168 # ffffffffc0204b88 <commands+0x718>
ffffffffc0200700:	9bfff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc0200704:	686c                	ld	a1,208(s0)
ffffffffc0200706:	00004517          	auipc	a0,0x4
ffffffffc020070a:	49a50513          	addi	a0,a0,1178 # ffffffffc0204ba0 <commands+0x730>
ffffffffc020070e:	9b1ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200712:	6c6c                	ld	a1,216(s0)
ffffffffc0200714:	00004517          	auipc	a0,0x4
ffffffffc0200718:	4a450513          	addi	a0,a0,1188 # ffffffffc0204bb8 <commands+0x748>
ffffffffc020071c:	9a3ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200720:	706c                	ld	a1,224(s0)
ffffffffc0200722:	00004517          	auipc	a0,0x4
ffffffffc0200726:	4ae50513          	addi	a0,a0,1198 # ffffffffc0204bd0 <commands+0x760>
ffffffffc020072a:	995ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020072e:	746c                	ld	a1,232(s0)
ffffffffc0200730:	00004517          	auipc	a0,0x4
ffffffffc0200734:	4b850513          	addi	a0,a0,1208 # ffffffffc0204be8 <commands+0x778>
ffffffffc0200738:	987ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc020073c:	786c                	ld	a1,240(s0)
ffffffffc020073e:	00004517          	auipc	a0,0x4
ffffffffc0200742:	4c250513          	addi	a0,a0,1218 # ffffffffc0204c00 <commands+0x790>
ffffffffc0200746:	979ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020074a:	7c6c                	ld	a1,248(s0)
}
ffffffffc020074c:	6402                	ld	s0,0(sp)
ffffffffc020074e:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200750:	00004517          	auipc	a0,0x4
ffffffffc0200754:	4c850513          	addi	a0,a0,1224 # ffffffffc0204c18 <commands+0x7a8>
}
ffffffffc0200758:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020075a:	965ff06f          	j	ffffffffc02000be <cprintf>

ffffffffc020075e <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020075e:	1141                	addi	sp,sp,-16
ffffffffc0200760:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200762:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200764:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200766:	00004517          	auipc	a0,0x4
ffffffffc020076a:	4ca50513          	addi	a0,a0,1226 # ffffffffc0204c30 <commands+0x7c0>
void print_trapframe(struct trapframe *tf) {
ffffffffc020076e:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200770:	94fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200774:	8522                	mv	a0,s0
ffffffffc0200776:	e1bff0ef          	jal	ra,ffffffffc0200590 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020077a:	10043583          	ld	a1,256(s0)
ffffffffc020077e:	00004517          	auipc	a0,0x4
ffffffffc0200782:	4ca50513          	addi	a0,a0,1226 # ffffffffc0204c48 <commands+0x7d8>
ffffffffc0200786:	939ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020078a:	10843583          	ld	a1,264(s0)
ffffffffc020078e:	00004517          	auipc	a0,0x4
ffffffffc0200792:	4d250513          	addi	a0,a0,1234 # ffffffffc0204c60 <commands+0x7f0>
ffffffffc0200796:	929ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020079a:	11043583          	ld	a1,272(s0)
ffffffffc020079e:	00004517          	auipc	a0,0x4
ffffffffc02007a2:	4da50513          	addi	a0,a0,1242 # ffffffffc0204c78 <commands+0x808>
ffffffffc02007a6:	919ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007aa:	11843583          	ld	a1,280(s0)
}
ffffffffc02007ae:	6402                	ld	s0,0(sp)
ffffffffc02007b0:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007b2:	00004517          	auipc	a0,0x4
ffffffffc02007b6:	4de50513          	addi	a0,a0,1246 # ffffffffc0204c90 <commands+0x820>
}
ffffffffc02007ba:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007bc:	903ff06f          	j	ffffffffc02000be <cprintf>

ffffffffc02007c0 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02007c0:	11853783          	ld	a5,280(a0)
ffffffffc02007c4:	577d                	li	a4,-1
ffffffffc02007c6:	8305                	srli	a4,a4,0x1
ffffffffc02007c8:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02007ca:	472d                	li	a4,11
ffffffffc02007cc:	06f76f63          	bltu	a4,a5,ffffffffc020084a <interrupt_handler+0x8a>
ffffffffc02007d0:	00004717          	auipc	a4,0x4
ffffffffc02007d4:	e3470713          	addi	a4,a4,-460 # ffffffffc0204604 <commands+0x194>
ffffffffc02007d8:	078a                	slli	a5,a5,0x2
ffffffffc02007da:	97ba                	add	a5,a5,a4
ffffffffc02007dc:	439c                	lw	a5,0(a5)
ffffffffc02007de:	97ba                	add	a5,a5,a4
ffffffffc02007e0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02007e2:	00004517          	auipc	a0,0x4
ffffffffc02007e6:	0ae50513          	addi	a0,a0,174 # ffffffffc0204890 <commands+0x420>
ffffffffc02007ea:	8d5ff06f          	j	ffffffffc02000be <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02007ee:	00004517          	auipc	a0,0x4
ffffffffc02007f2:	08250513          	addi	a0,a0,130 # ffffffffc0204870 <commands+0x400>
ffffffffc02007f6:	8c9ff06f          	j	ffffffffc02000be <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02007fa:	00004517          	auipc	a0,0x4
ffffffffc02007fe:	03650513          	addi	a0,a0,54 # ffffffffc0204830 <commands+0x3c0>
ffffffffc0200802:	8bdff06f          	j	ffffffffc02000be <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200806:	00004517          	auipc	a0,0x4
ffffffffc020080a:	04a50513          	addi	a0,a0,74 # ffffffffc0204850 <commands+0x3e0>
ffffffffc020080e:	8b1ff06f          	j	ffffffffc02000be <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc0200812:	00004517          	auipc	a0,0x4
ffffffffc0200816:	0ae50513          	addi	a0,a0,174 # ffffffffc02048c0 <commands+0x450>
ffffffffc020081a:	8a5ff06f          	j	ffffffffc02000be <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc020081e:	1141                	addi	sp,sp,-16
ffffffffc0200820:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc0200822:	c45ff0ef          	jal	ra,ffffffffc0200466 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc0200826:	00011797          	auipc	a5,0x11
ffffffffc020082a:	c5278793          	addi	a5,a5,-942 # ffffffffc0211478 <ticks>
ffffffffc020082e:	639c                	ld	a5,0(a5)
ffffffffc0200830:	06400713          	li	a4,100
ffffffffc0200834:	0785                	addi	a5,a5,1
ffffffffc0200836:	02e7f733          	remu	a4,a5,a4
ffffffffc020083a:	00011697          	auipc	a3,0x11
ffffffffc020083e:	c2f6bf23          	sd	a5,-962(a3) # ffffffffc0211478 <ticks>
ffffffffc0200842:	c711                	beqz	a4,ffffffffc020084e <interrupt_handler+0x8e>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200844:	60a2                	ld	ra,8(sp)
ffffffffc0200846:	0141                	addi	sp,sp,16
ffffffffc0200848:	8082                	ret
            print_trapframe(tf);
ffffffffc020084a:	f15ff06f          	j	ffffffffc020075e <print_trapframe>
}
ffffffffc020084e:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200850:	06400593          	li	a1,100
ffffffffc0200854:	00004517          	auipc	a0,0x4
ffffffffc0200858:	05c50513          	addi	a0,a0,92 # ffffffffc02048b0 <commands+0x440>
}
ffffffffc020085c:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020085e:	861ff06f          	j	ffffffffc02000be <cprintf>

ffffffffc0200862 <exception_handler>:


void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200862:	11853783          	ld	a5,280(a0)
ffffffffc0200866:	473d                	li	a4,15
ffffffffc0200868:	16f76563          	bltu	a4,a5,ffffffffc02009d2 <exception_handler+0x170>
ffffffffc020086c:	00004717          	auipc	a4,0x4
ffffffffc0200870:	dc870713          	addi	a4,a4,-568 # ffffffffc0204634 <commands+0x1c4>
ffffffffc0200874:	078a                	slli	a5,a5,0x2
ffffffffc0200876:	97ba                	add	a5,a5,a4
ffffffffc0200878:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc020087a:	1101                	addi	sp,sp,-32
ffffffffc020087c:	e822                	sd	s0,16(sp)
ffffffffc020087e:	ec06                	sd	ra,24(sp)
ffffffffc0200880:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc0200882:	97ba                	add	a5,a5,a4
ffffffffc0200884:	842a                	mv	s0,a0
ffffffffc0200886:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc0200888:	00004517          	auipc	a0,0x4
ffffffffc020088c:	f9050513          	addi	a0,a0,-112 # ffffffffc0204818 <commands+0x3a8>
ffffffffc0200890:	82fff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200894:	8522                	mv	a0,s0
ffffffffc0200896:	c6bff0ef          	jal	ra,ffffffffc0200500 <pgfault_handler>
ffffffffc020089a:	84aa                	mv	s1,a0
ffffffffc020089c:	12051d63          	bnez	a0,ffffffffc02009d6 <exception_handler+0x174>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc02008a0:	60e2                	ld	ra,24(sp)
ffffffffc02008a2:	6442                	ld	s0,16(sp)
ffffffffc02008a4:	64a2                	ld	s1,8(sp)
ffffffffc02008a6:	6105                	addi	sp,sp,32
ffffffffc02008a8:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc02008aa:	00004517          	auipc	a0,0x4
ffffffffc02008ae:	dce50513          	addi	a0,a0,-562 # ffffffffc0204678 <commands+0x208>
}
ffffffffc02008b2:	6442                	ld	s0,16(sp)
ffffffffc02008b4:	60e2                	ld	ra,24(sp)
ffffffffc02008b6:	64a2                	ld	s1,8(sp)
ffffffffc02008b8:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc02008ba:	805ff06f          	j	ffffffffc02000be <cprintf>
ffffffffc02008be:	00004517          	auipc	a0,0x4
ffffffffc02008c2:	dda50513          	addi	a0,a0,-550 # ffffffffc0204698 <commands+0x228>
ffffffffc02008c6:	b7f5                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc02008c8:	00004517          	auipc	a0,0x4
ffffffffc02008cc:	df050513          	addi	a0,a0,-528 # ffffffffc02046b8 <commands+0x248>
ffffffffc02008d0:	b7cd                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc02008d2:	00004517          	auipc	a0,0x4
ffffffffc02008d6:	dfe50513          	addi	a0,a0,-514 # ffffffffc02046d0 <commands+0x260>
ffffffffc02008da:	bfe1                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Load address misaligned\n");
ffffffffc02008dc:	00004517          	auipc	a0,0x4
ffffffffc02008e0:	e0450513          	addi	a0,a0,-508 # ffffffffc02046e0 <commands+0x270>
ffffffffc02008e4:	b7f9                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc02008e6:	00004517          	auipc	a0,0x4
ffffffffc02008ea:	e1a50513          	addi	a0,a0,-486 # ffffffffc0204700 <commands+0x290>
ffffffffc02008ee:	fd0ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02008f2:	8522                	mv	a0,s0
ffffffffc02008f4:	c0dff0ef          	jal	ra,ffffffffc0200500 <pgfault_handler>
ffffffffc02008f8:	84aa                	mv	s1,a0
ffffffffc02008fa:	d15d                	beqz	a0,ffffffffc02008a0 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02008fc:	8522                	mv	a0,s0
ffffffffc02008fe:	e61ff0ef          	jal	ra,ffffffffc020075e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200902:	86a6                	mv	a3,s1
ffffffffc0200904:	00004617          	auipc	a2,0x4
ffffffffc0200908:	e1460613          	addi	a2,a2,-492 # ffffffffc0204718 <commands+0x2a8>
ffffffffc020090c:	0ca00593          	li	a1,202
ffffffffc0200910:	00004517          	auipc	a0,0x4
ffffffffc0200914:	00850513          	addi	a0,a0,8 # ffffffffc0204918 <commands+0x4a8>
ffffffffc0200918:	feeff0ef          	jal	ra,ffffffffc0200106 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc020091c:	00004517          	auipc	a0,0x4
ffffffffc0200920:	e1c50513          	addi	a0,a0,-484 # ffffffffc0204738 <commands+0x2c8>
ffffffffc0200924:	b779                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc0200926:	00004517          	auipc	a0,0x4
ffffffffc020092a:	e2a50513          	addi	a0,a0,-470 # ffffffffc0204750 <commands+0x2e0>
ffffffffc020092e:	f90ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200932:	8522                	mv	a0,s0
ffffffffc0200934:	bcdff0ef          	jal	ra,ffffffffc0200500 <pgfault_handler>
ffffffffc0200938:	84aa                	mv	s1,a0
ffffffffc020093a:	d13d                	beqz	a0,ffffffffc02008a0 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc020093c:	8522                	mv	a0,s0
ffffffffc020093e:	e21ff0ef          	jal	ra,ffffffffc020075e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200942:	86a6                	mv	a3,s1
ffffffffc0200944:	00004617          	auipc	a2,0x4
ffffffffc0200948:	dd460613          	addi	a2,a2,-556 # ffffffffc0204718 <commands+0x2a8>
ffffffffc020094c:	0d400593          	li	a1,212
ffffffffc0200950:	00004517          	auipc	a0,0x4
ffffffffc0200954:	fc850513          	addi	a0,a0,-56 # ffffffffc0204918 <commands+0x4a8>
ffffffffc0200958:	faeff0ef          	jal	ra,ffffffffc0200106 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc020095c:	00004517          	auipc	a0,0x4
ffffffffc0200960:	e0c50513          	addi	a0,a0,-500 # ffffffffc0204768 <commands+0x2f8>
ffffffffc0200964:	b7b9                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc0200966:	00004517          	auipc	a0,0x4
ffffffffc020096a:	e2250513          	addi	a0,a0,-478 # ffffffffc0204788 <commands+0x318>
ffffffffc020096e:	b791                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc0200970:	00004517          	auipc	a0,0x4
ffffffffc0200974:	e3850513          	addi	a0,a0,-456 # ffffffffc02047a8 <commands+0x338>
ffffffffc0200978:	bf2d                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc020097a:	00004517          	auipc	a0,0x4
ffffffffc020097e:	e4e50513          	addi	a0,a0,-434 # ffffffffc02047c8 <commands+0x358>
ffffffffc0200982:	bf05                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200984:	00004517          	auipc	a0,0x4
ffffffffc0200988:	e6450513          	addi	a0,a0,-412 # ffffffffc02047e8 <commands+0x378>
ffffffffc020098c:	b71d                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc020098e:	00004517          	auipc	a0,0x4
ffffffffc0200992:	e7250513          	addi	a0,a0,-398 # ffffffffc0204800 <commands+0x390>
ffffffffc0200996:	f28ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc020099a:	8522                	mv	a0,s0
ffffffffc020099c:	b65ff0ef          	jal	ra,ffffffffc0200500 <pgfault_handler>
ffffffffc02009a0:	84aa                	mv	s1,a0
ffffffffc02009a2:	ee050fe3          	beqz	a0,ffffffffc02008a0 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02009a6:	8522                	mv	a0,s0
ffffffffc02009a8:	db7ff0ef          	jal	ra,ffffffffc020075e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009ac:	86a6                	mv	a3,s1
ffffffffc02009ae:	00004617          	auipc	a2,0x4
ffffffffc02009b2:	d6a60613          	addi	a2,a2,-662 # ffffffffc0204718 <commands+0x2a8>
ffffffffc02009b6:	0ea00593          	li	a1,234
ffffffffc02009ba:	00004517          	auipc	a0,0x4
ffffffffc02009be:	f5e50513          	addi	a0,a0,-162 # ffffffffc0204918 <commands+0x4a8>
ffffffffc02009c2:	f44ff0ef          	jal	ra,ffffffffc0200106 <__panic>
}
ffffffffc02009c6:	6442                	ld	s0,16(sp)
ffffffffc02009c8:	60e2                	ld	ra,24(sp)
ffffffffc02009ca:	64a2                	ld	s1,8(sp)
ffffffffc02009cc:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc02009ce:	d91ff06f          	j	ffffffffc020075e <print_trapframe>
ffffffffc02009d2:	d8dff06f          	j	ffffffffc020075e <print_trapframe>
                print_trapframe(tf);
ffffffffc02009d6:	8522                	mv	a0,s0
ffffffffc02009d8:	d87ff0ef          	jal	ra,ffffffffc020075e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009dc:	86a6                	mv	a3,s1
ffffffffc02009de:	00004617          	auipc	a2,0x4
ffffffffc02009e2:	d3a60613          	addi	a2,a2,-710 # ffffffffc0204718 <commands+0x2a8>
ffffffffc02009e6:	0f100593          	li	a1,241
ffffffffc02009ea:	00004517          	auipc	a0,0x4
ffffffffc02009ee:	f2e50513          	addi	a0,a0,-210 # ffffffffc0204918 <commands+0x4a8>
ffffffffc02009f2:	f14ff0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc02009f6 <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc02009f6:	11853783          	ld	a5,280(a0)
ffffffffc02009fa:	0007c463          	bltz	a5,ffffffffc0200a02 <trap+0xc>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc02009fe:	e65ff06f          	j	ffffffffc0200862 <exception_handler>
        interrupt_handler(tf);
ffffffffc0200a02:	dbfff06f          	j	ffffffffc02007c0 <interrupt_handler>
	...

ffffffffc0200a10 <__alltraps>:
    .endm

    .align 4
    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200a10:	14011073          	csrw	sscratch,sp
ffffffffc0200a14:	712d                	addi	sp,sp,-288
ffffffffc0200a16:	e406                	sd	ra,8(sp)
ffffffffc0200a18:	ec0e                	sd	gp,24(sp)
ffffffffc0200a1a:	f012                	sd	tp,32(sp)
ffffffffc0200a1c:	f416                	sd	t0,40(sp)
ffffffffc0200a1e:	f81a                	sd	t1,48(sp)
ffffffffc0200a20:	fc1e                	sd	t2,56(sp)
ffffffffc0200a22:	e0a2                	sd	s0,64(sp)
ffffffffc0200a24:	e4a6                	sd	s1,72(sp)
ffffffffc0200a26:	e8aa                	sd	a0,80(sp)
ffffffffc0200a28:	ecae                	sd	a1,88(sp)
ffffffffc0200a2a:	f0b2                	sd	a2,96(sp)
ffffffffc0200a2c:	f4b6                	sd	a3,104(sp)
ffffffffc0200a2e:	f8ba                	sd	a4,112(sp)
ffffffffc0200a30:	fcbe                	sd	a5,120(sp)
ffffffffc0200a32:	e142                	sd	a6,128(sp)
ffffffffc0200a34:	e546                	sd	a7,136(sp)
ffffffffc0200a36:	e94a                	sd	s2,144(sp)
ffffffffc0200a38:	ed4e                	sd	s3,152(sp)
ffffffffc0200a3a:	f152                	sd	s4,160(sp)
ffffffffc0200a3c:	f556                	sd	s5,168(sp)
ffffffffc0200a3e:	f95a                	sd	s6,176(sp)
ffffffffc0200a40:	fd5e                	sd	s7,184(sp)
ffffffffc0200a42:	e1e2                	sd	s8,192(sp)
ffffffffc0200a44:	e5e6                	sd	s9,200(sp)
ffffffffc0200a46:	e9ea                	sd	s10,208(sp)
ffffffffc0200a48:	edee                	sd	s11,216(sp)
ffffffffc0200a4a:	f1f2                	sd	t3,224(sp)
ffffffffc0200a4c:	f5f6                	sd	t4,232(sp)
ffffffffc0200a4e:	f9fa                	sd	t5,240(sp)
ffffffffc0200a50:	fdfe                	sd	t6,248(sp)
ffffffffc0200a52:	14002473          	csrr	s0,sscratch
ffffffffc0200a56:	100024f3          	csrr	s1,sstatus
ffffffffc0200a5a:	14102973          	csrr	s2,sepc
ffffffffc0200a5e:	143029f3          	csrr	s3,stval
ffffffffc0200a62:	14202a73          	csrr	s4,scause
ffffffffc0200a66:	e822                	sd	s0,16(sp)
ffffffffc0200a68:	e226                	sd	s1,256(sp)
ffffffffc0200a6a:	e64a                	sd	s2,264(sp)
ffffffffc0200a6c:	ea4e                	sd	s3,272(sp)
ffffffffc0200a6e:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200a70:	850a                	mv	a0,sp
    jal trap
ffffffffc0200a72:	f85ff0ef          	jal	ra,ffffffffc02009f6 <trap>

ffffffffc0200a76 <__trapret>:
    // sp should be the same as before "jal trap"
    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200a76:	6492                	ld	s1,256(sp)
ffffffffc0200a78:	6932                	ld	s2,264(sp)
ffffffffc0200a7a:	10049073          	csrw	sstatus,s1
ffffffffc0200a7e:	14191073          	csrw	sepc,s2
ffffffffc0200a82:	60a2                	ld	ra,8(sp)
ffffffffc0200a84:	61e2                	ld	gp,24(sp)
ffffffffc0200a86:	7202                	ld	tp,32(sp)
ffffffffc0200a88:	72a2                	ld	t0,40(sp)
ffffffffc0200a8a:	7342                	ld	t1,48(sp)
ffffffffc0200a8c:	73e2                	ld	t2,56(sp)
ffffffffc0200a8e:	6406                	ld	s0,64(sp)
ffffffffc0200a90:	64a6                	ld	s1,72(sp)
ffffffffc0200a92:	6546                	ld	a0,80(sp)
ffffffffc0200a94:	65e6                	ld	a1,88(sp)
ffffffffc0200a96:	7606                	ld	a2,96(sp)
ffffffffc0200a98:	76a6                	ld	a3,104(sp)
ffffffffc0200a9a:	7746                	ld	a4,112(sp)
ffffffffc0200a9c:	77e6                	ld	a5,120(sp)
ffffffffc0200a9e:	680a                	ld	a6,128(sp)
ffffffffc0200aa0:	68aa                	ld	a7,136(sp)
ffffffffc0200aa2:	694a                	ld	s2,144(sp)
ffffffffc0200aa4:	69ea                	ld	s3,152(sp)
ffffffffc0200aa6:	7a0a                	ld	s4,160(sp)
ffffffffc0200aa8:	7aaa                	ld	s5,168(sp)
ffffffffc0200aaa:	7b4a                	ld	s6,176(sp)
ffffffffc0200aac:	7bea                	ld	s7,184(sp)
ffffffffc0200aae:	6c0e                	ld	s8,192(sp)
ffffffffc0200ab0:	6cae                	ld	s9,200(sp)
ffffffffc0200ab2:	6d4e                	ld	s10,208(sp)
ffffffffc0200ab4:	6dee                	ld	s11,216(sp)
ffffffffc0200ab6:	7e0e                	ld	t3,224(sp)
ffffffffc0200ab8:	7eae                	ld	t4,232(sp)
ffffffffc0200aba:	7f4e                	ld	t5,240(sp)
ffffffffc0200abc:	7fee                	ld	t6,248(sp)
ffffffffc0200abe:	6142                	ld	sp,16(sp)
    // go back from supervisor call
    sret
ffffffffc0200ac0:	10200073          	sret
	...

ffffffffc0200ad0 <check_vma_overlap.isra.0.part.1>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {// 检查是否覆盖
ffffffffc0200ad0:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0200ad2:	00004697          	auipc	a3,0x4
ffffffffc0200ad6:	1d668693          	addi	a3,a3,470 # ffffffffc0204ca8 <commands+0x838>
ffffffffc0200ada:	00004617          	auipc	a2,0x4
ffffffffc0200ade:	1ee60613          	addi	a2,a2,494 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0200ae2:	07d00593          	li	a1,125
ffffffffc0200ae6:	00004517          	auipc	a0,0x4
ffffffffc0200aea:	1fa50513          	addi	a0,a0,506 # ffffffffc0204ce0 <commands+0x870>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {// 检查是否覆盖
ffffffffc0200aee:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0200af0:	e16ff0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0200af4 <mm_create>:
mm_create(void) {
ffffffffc0200af4:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200af6:	03000513          	li	a0,48
mm_create(void) {
ffffffffc0200afa:	e022                	sd	s0,0(sp)
ffffffffc0200afc:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200afe:	7a5020ef          	jal	ra,ffffffffc0203aa2 <kmalloc>
ffffffffc0200b02:	842a                	mv	s0,a0
    if (mm != NULL) {// 初始化
ffffffffc0200b04:	c115                	beqz	a0,ffffffffc0200b28 <mm_create+0x34>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200b06:	00011797          	auipc	a5,0x11
ffffffffc0200b0a:	95a78793          	addi	a5,a5,-1702 # ffffffffc0211460 <swap_init_ok>
ffffffffc0200b0e:	439c                	lw	a5,0(a5)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200b10:	e408                	sd	a0,8(s0)
ffffffffc0200b12:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0200b14:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0200b18:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0200b1c:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200b20:	2781                	sext.w	a5,a5
ffffffffc0200b22:	eb81                	bnez	a5,ffffffffc0200b32 <mm_create+0x3e>
        else mm->sm_priv = NULL;
ffffffffc0200b24:	02053423          	sd	zero,40(a0)
}
ffffffffc0200b28:	8522                	mv	a0,s0
ffffffffc0200b2a:	60a2                	ld	ra,8(sp)
ffffffffc0200b2c:	6402                	ld	s0,0(sp)
ffffffffc0200b2e:	0141                	addi	sp,sp,16
ffffffffc0200b30:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200b32:	64f000ef          	jal	ra,ffffffffc0201980 <swap_init_mm>
}
ffffffffc0200b36:	8522                	mv	a0,s0
ffffffffc0200b38:	60a2                	ld	ra,8(sp)
ffffffffc0200b3a:	6402                	ld	s0,0(sp)
ffffffffc0200b3c:	0141                	addi	sp,sp,16
ffffffffc0200b3e:	8082                	ret

ffffffffc0200b40 <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc0200b40:	1101                	addi	sp,sp,-32
ffffffffc0200b42:	e04a                	sd	s2,0(sp)
ffffffffc0200b44:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200b46:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc0200b4a:	e822                	sd	s0,16(sp)
ffffffffc0200b4c:	e426                	sd	s1,8(sp)
ffffffffc0200b4e:	ec06                	sd	ra,24(sp)
ffffffffc0200b50:	84ae                	mv	s1,a1
ffffffffc0200b52:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200b54:	74f020ef          	jal	ra,ffffffffc0203aa2 <kmalloc>
    if (vma != NULL) {
ffffffffc0200b58:	c509                	beqz	a0,ffffffffc0200b62 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0200b5a:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0200b5e:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0200b60:	ed00                	sd	s0,24(a0)
}
ffffffffc0200b62:	60e2                	ld	ra,24(sp)
ffffffffc0200b64:	6442                	ld	s0,16(sp)
ffffffffc0200b66:	64a2                	ld	s1,8(sp)
ffffffffc0200b68:	6902                	ld	s2,0(sp)
ffffffffc0200b6a:	6105                	addi	sp,sp,32
ffffffffc0200b6c:	8082                	ret

ffffffffc0200b6e <find_vma>:
    if (mm != NULL) {
ffffffffc0200b6e:	c51d                	beqz	a0,ffffffffc0200b9c <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc0200b70:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0200b72:	c781                	beqz	a5,ffffffffc0200b7a <find_vma+0xc>
ffffffffc0200b74:	6798                	ld	a4,8(a5)
ffffffffc0200b76:	02e5f663          	bleu	a4,a1,ffffffffc0200ba2 <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc0200b7a:	87aa                	mv	a5,a0
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200b7c:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0200b7e:	00f50f63          	beq	a0,a5,ffffffffc0200b9c <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0200b82:	fe87b703          	ld	a4,-24(a5)
ffffffffc0200b86:	fee5ebe3          	bltu	a1,a4,ffffffffc0200b7c <find_vma+0xe>
ffffffffc0200b8a:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200b8e:	fee5f7e3          	bleu	a4,a1,ffffffffc0200b7c <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc0200b92:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc0200b94:	c781                	beqz	a5,ffffffffc0200b9c <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc0200b96:	e91c                	sd	a5,16(a0)
}
ffffffffc0200b98:	853e                	mv	a0,a5
ffffffffc0200b9a:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc0200b9c:	4781                	li	a5,0
}
ffffffffc0200b9e:	853e                	mv	a0,a5
ffffffffc0200ba0:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0200ba2:	6b98                	ld	a4,16(a5)
ffffffffc0200ba4:	fce5fbe3          	bleu	a4,a1,ffffffffc0200b7a <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc0200ba8:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc0200baa:	b7fd                	j	ffffffffc0200b98 <find_vma+0x2a>

ffffffffc0200bac <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {// 插入vma
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200bac:	6590                	ld	a2,8(a1)
ffffffffc0200bae:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {// 插入vma
ffffffffc0200bb2:	1141                	addi	sp,sp,-16
ffffffffc0200bb4:	e406                	sd	ra,8(sp)
ffffffffc0200bb6:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200bb8:	01066863          	bltu	a2,a6,ffffffffc0200bc8 <insert_vma_struct+0x1c>
ffffffffc0200bbc:	a8b9                	j	ffffffffc0200c1a <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {// 比较vma的start地址，按地址排序
ffffffffc0200bbe:	fe87b683          	ld	a3,-24(a5)
ffffffffc0200bc2:	04d66763          	bltu	a2,a3,ffffffffc0200c10 <insert_vma_struct+0x64>
ffffffffc0200bc6:	873e                	mv	a4,a5
ffffffffc0200bc8:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc0200bca:	fef51ae3          	bne	a0,a5,ffffffffc0200bbe <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0200bce:	02a70463          	beq	a4,a0,ffffffffc0200bf6 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0200bd2:	ff073683          	ld	a3,-16(a4)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0200bd6:	fe873883          	ld	a7,-24(a4)
ffffffffc0200bda:	08d8f063          	bleu	a3,a7,ffffffffc0200c5a <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200bde:	04d66e63          	bltu	a2,a3,ffffffffc0200c3a <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc0200be2:	00f50a63          	beq	a0,a5,ffffffffc0200bf6 <insert_vma_struct+0x4a>
ffffffffc0200be6:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200bea:	0506e863          	bltu	a3,a6,ffffffffc0200c3a <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc0200bee:	ff07b603          	ld	a2,-16(a5)
ffffffffc0200bf2:	02c6f263          	bleu	a2,a3,ffffffffc0200c16 <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0200bf6:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc0200bf8:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0200bfa:	02058613          	addi	a2,a1,32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0200bfe:	e390                	sd	a2,0(a5)
ffffffffc0200c00:	e710                	sd	a2,8(a4)
}
ffffffffc0200c02:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0200c04:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0200c06:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc0200c08:	2685                	addiw	a3,a3,1
ffffffffc0200c0a:	d114                	sw	a3,32(a0)
}
ffffffffc0200c0c:	0141                	addi	sp,sp,16
ffffffffc0200c0e:	8082                	ret
    if (le_prev != list) {
ffffffffc0200c10:	fca711e3          	bne	a4,a0,ffffffffc0200bd2 <insert_vma_struct+0x26>
ffffffffc0200c14:	bfd9                	j	ffffffffc0200bea <insert_vma_struct+0x3e>
ffffffffc0200c16:	ebbff0ef          	jal	ra,ffffffffc0200ad0 <check_vma_overlap.isra.0.part.1>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200c1a:	00004697          	auipc	a3,0x4
ffffffffc0200c1e:	16668693          	addi	a3,a3,358 # ffffffffc0204d80 <commands+0x910>
ffffffffc0200c22:	00004617          	auipc	a2,0x4
ffffffffc0200c26:	0a660613          	addi	a2,a2,166 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0200c2a:	08400593          	li	a1,132
ffffffffc0200c2e:	00004517          	auipc	a0,0x4
ffffffffc0200c32:	0b250513          	addi	a0,a0,178 # ffffffffc0204ce0 <commands+0x870>
ffffffffc0200c36:	cd0ff0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200c3a:	00004697          	auipc	a3,0x4
ffffffffc0200c3e:	18668693          	addi	a3,a3,390 # ffffffffc0204dc0 <commands+0x950>
ffffffffc0200c42:	00004617          	auipc	a2,0x4
ffffffffc0200c46:	08660613          	addi	a2,a2,134 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0200c4a:	07c00593          	li	a1,124
ffffffffc0200c4e:	00004517          	auipc	a0,0x4
ffffffffc0200c52:	09250513          	addi	a0,a0,146 # ffffffffc0204ce0 <commands+0x870>
ffffffffc0200c56:	cb0ff0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0200c5a:	00004697          	auipc	a3,0x4
ffffffffc0200c5e:	14668693          	addi	a3,a3,326 # ffffffffc0204da0 <commands+0x930>
ffffffffc0200c62:	00004617          	auipc	a2,0x4
ffffffffc0200c66:	06660613          	addi	a2,a2,102 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0200c6a:	07b00593          	li	a1,123
ffffffffc0200c6e:	00004517          	auipc	a0,0x4
ffffffffc0200c72:	07250513          	addi	a0,a0,114 # ffffffffc0204ce0 <commands+0x870>
ffffffffc0200c76:	c90ff0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0200c7a <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc0200c7a:	1141                	addi	sp,sp,-16
ffffffffc0200c7c:	e022                	sd	s0,0(sp)
ffffffffc0200c7e:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0200c80:	6508                	ld	a0,8(a0)
ffffffffc0200c82:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0200c84:	00a40e63          	beq	s0,a0,ffffffffc0200ca0 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200c88:	6118                	ld	a4,0(a0)
ffffffffc0200c8a:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc0200c8c:	03000593          	li	a1,48
ffffffffc0200c90:	1501                	addi	a0,a0,-32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200c92:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200c94:	e398                	sd	a4,0(a5)
ffffffffc0200c96:	6cf020ef          	jal	ra,ffffffffc0203b64 <kfree>
    return listelm->next;
ffffffffc0200c9a:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0200c9c:	fea416e3          	bne	s0,a0,ffffffffc0200c88 <mm_destroy+0xe>
    }
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0200ca0:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0200ca2:	6402                	ld	s0,0(sp)
ffffffffc0200ca4:	60a2                	ld	ra,8(sp)
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0200ca6:	03000593          	li	a1,48
}
ffffffffc0200caa:	0141                	addi	sp,sp,16
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0200cac:	6b90206f          	j	ffffffffc0203b64 <kfree>

ffffffffc0200cb0 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0200cb0:	715d                	addi	sp,sp,-80
ffffffffc0200cb2:	e486                	sd	ra,72(sp)
ffffffffc0200cb4:	e0a2                	sd	s0,64(sp)
ffffffffc0200cb6:	fc26                	sd	s1,56(sp)
ffffffffc0200cb8:	f84a                	sd	s2,48(sp)
ffffffffc0200cba:	f052                	sd	s4,32(sp)
ffffffffc0200cbc:	f44e                	sd	s3,40(sp)
ffffffffc0200cbe:	ec56                	sd	s5,24(sp)
ffffffffc0200cc0:	e85a                	sd	s6,16(sp)
ffffffffc0200cc2:	e45e                	sd	s7,8(sp)
}

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0200cc4:	681010ef          	jal	ra,ffffffffc0202b44 <nr_free_pages>
ffffffffc0200cc8:	892a                	mv	s2,a0
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0200cca:	67b010ef          	jal	ra,ffffffffc0202b44 <nr_free_pages>
ffffffffc0200cce:	8a2a                	mv	s4,a0

    struct mm_struct *mm = mm_create();
ffffffffc0200cd0:	e25ff0ef          	jal	ra,ffffffffc0200af4 <mm_create>
    assert(mm != NULL);
ffffffffc0200cd4:	842a                	mv	s0,a0
ffffffffc0200cd6:	03200493          	li	s1,50
ffffffffc0200cda:	e919                	bnez	a0,ffffffffc0200cf0 <vmm_init+0x40>
ffffffffc0200cdc:	aeed                	j	ffffffffc02010d6 <vmm_init+0x426>
        vma->vm_start = vm_start;
ffffffffc0200cde:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0200ce0:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0200ce2:	00053c23          	sd	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0200ce6:	14ed                	addi	s1,s1,-5
ffffffffc0200ce8:	8522                	mv	a0,s0
ffffffffc0200cea:	ec3ff0ef          	jal	ra,ffffffffc0200bac <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0200cee:	c88d                	beqz	s1,ffffffffc0200d20 <vmm_init+0x70>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200cf0:	03000513          	li	a0,48
ffffffffc0200cf4:	5af020ef          	jal	ra,ffffffffc0203aa2 <kmalloc>
ffffffffc0200cf8:	85aa                	mv	a1,a0
ffffffffc0200cfa:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0200cfe:	f165                	bnez	a0,ffffffffc0200cde <vmm_init+0x2e>
        assert(vma != NULL);
ffffffffc0200d00:	00004697          	auipc	a3,0x4
ffffffffc0200d04:	33868693          	addi	a3,a3,824 # ffffffffc0205038 <commands+0xbc8>
ffffffffc0200d08:	00004617          	auipc	a2,0x4
ffffffffc0200d0c:	fc060613          	addi	a2,a2,-64 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0200d10:	0ce00593          	li	a1,206
ffffffffc0200d14:	00004517          	auipc	a0,0x4
ffffffffc0200d18:	fcc50513          	addi	a0,a0,-52 # ffffffffc0204ce0 <commands+0x870>
ffffffffc0200d1c:	beaff0ef          	jal	ra,ffffffffc0200106 <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc0200d20:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0200d24:	1f900993          	li	s3,505
ffffffffc0200d28:	a819                	j	ffffffffc0200d3e <vmm_init+0x8e>
        vma->vm_start = vm_start;
ffffffffc0200d2a:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0200d2c:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0200d2e:	00053c23          	sd	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0200d32:	0495                	addi	s1,s1,5
ffffffffc0200d34:	8522                	mv	a0,s0
ffffffffc0200d36:	e77ff0ef          	jal	ra,ffffffffc0200bac <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0200d3a:	03348a63          	beq	s1,s3,ffffffffc0200d6e <vmm_init+0xbe>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200d3e:	03000513          	li	a0,48
ffffffffc0200d42:	561020ef          	jal	ra,ffffffffc0203aa2 <kmalloc>
ffffffffc0200d46:	85aa                	mv	a1,a0
ffffffffc0200d48:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0200d4c:	fd79                	bnez	a0,ffffffffc0200d2a <vmm_init+0x7a>
        assert(vma != NULL);
ffffffffc0200d4e:	00004697          	auipc	a3,0x4
ffffffffc0200d52:	2ea68693          	addi	a3,a3,746 # ffffffffc0205038 <commands+0xbc8>
ffffffffc0200d56:	00004617          	auipc	a2,0x4
ffffffffc0200d5a:	f7260613          	addi	a2,a2,-142 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0200d5e:	0d400593          	li	a1,212
ffffffffc0200d62:	00004517          	auipc	a0,0x4
ffffffffc0200d66:	f7e50513          	addi	a0,a0,-130 # ffffffffc0204ce0 <commands+0x870>
ffffffffc0200d6a:	b9cff0ef          	jal	ra,ffffffffc0200106 <__panic>
ffffffffc0200d6e:	6418                	ld	a4,8(s0)
ffffffffc0200d70:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0200d72:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0200d76:	2ae40063          	beq	s0,a4,ffffffffc0201016 <vmm_init+0x366>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0200d7a:	fe873603          	ld	a2,-24(a4)
ffffffffc0200d7e:	ffe78693          	addi	a3,a5,-2
ffffffffc0200d82:	20d61a63          	bne	a2,a3,ffffffffc0200f96 <vmm_init+0x2e6>
ffffffffc0200d86:	ff073683          	ld	a3,-16(a4)
ffffffffc0200d8a:	20d79663          	bne	a5,a3,ffffffffc0200f96 <vmm_init+0x2e6>
ffffffffc0200d8e:	0795                	addi	a5,a5,5
ffffffffc0200d90:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc0200d92:	feb792e3          	bne	a5,a1,ffffffffc0200d76 <vmm_init+0xc6>
ffffffffc0200d96:	499d                	li	s3,7
ffffffffc0200d98:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0200d9a:	1f900b93          	li	s7,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0200d9e:	85a6                	mv	a1,s1
ffffffffc0200da0:	8522                	mv	a0,s0
ffffffffc0200da2:	dcdff0ef          	jal	ra,ffffffffc0200b6e <find_vma>
ffffffffc0200da6:	8b2a                	mv	s6,a0
        assert(vma1 != NULL);
ffffffffc0200da8:	2e050763          	beqz	a0,ffffffffc0201096 <vmm_init+0x3e6>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0200dac:	00148593          	addi	a1,s1,1
ffffffffc0200db0:	8522                	mv	a0,s0
ffffffffc0200db2:	dbdff0ef          	jal	ra,ffffffffc0200b6e <find_vma>
ffffffffc0200db6:	8aaa                	mv	s5,a0
        assert(vma2 != NULL);
ffffffffc0200db8:	2a050f63          	beqz	a0,ffffffffc0201076 <vmm_init+0x3c6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0200dbc:	85ce                	mv	a1,s3
ffffffffc0200dbe:	8522                	mv	a0,s0
ffffffffc0200dc0:	dafff0ef          	jal	ra,ffffffffc0200b6e <find_vma>
        assert(vma3 == NULL);
ffffffffc0200dc4:	28051963          	bnez	a0,ffffffffc0201056 <vmm_init+0x3a6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0200dc8:	00348593          	addi	a1,s1,3
ffffffffc0200dcc:	8522                	mv	a0,s0
ffffffffc0200dce:	da1ff0ef          	jal	ra,ffffffffc0200b6e <find_vma>
        assert(vma4 == NULL);
ffffffffc0200dd2:	26051263          	bnez	a0,ffffffffc0201036 <vmm_init+0x386>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0200dd6:	00448593          	addi	a1,s1,4
ffffffffc0200dda:	8522                	mv	a0,s0
ffffffffc0200ddc:	d93ff0ef          	jal	ra,ffffffffc0200b6e <find_vma>
        assert(vma5 == NULL);
ffffffffc0200de0:	2c051b63          	bnez	a0,ffffffffc02010b6 <vmm_init+0x406>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0200de4:	008b3783          	ld	a5,8(s6)
ffffffffc0200de8:	1c979763          	bne	a5,s1,ffffffffc0200fb6 <vmm_init+0x306>
ffffffffc0200dec:	010b3783          	ld	a5,16(s6)
ffffffffc0200df0:	1d379363          	bne	a5,s3,ffffffffc0200fb6 <vmm_init+0x306>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0200df4:	008ab783          	ld	a5,8(s5)
ffffffffc0200df8:	1c979f63          	bne	a5,s1,ffffffffc0200fd6 <vmm_init+0x326>
ffffffffc0200dfc:	010ab783          	ld	a5,16(s5)
ffffffffc0200e00:	1d379b63          	bne	a5,s3,ffffffffc0200fd6 <vmm_init+0x326>
ffffffffc0200e04:	0495                	addi	s1,s1,5
ffffffffc0200e06:	0995                	addi	s3,s3,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0200e08:	f9749be3          	bne	s1,s7,ffffffffc0200d9e <vmm_init+0xee>
ffffffffc0200e0c:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0200e0e:	59fd                	li	s3,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0200e10:	85a6                	mv	a1,s1
ffffffffc0200e12:	8522                	mv	a0,s0
ffffffffc0200e14:	d5bff0ef          	jal	ra,ffffffffc0200b6e <find_vma>
ffffffffc0200e18:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc0200e1c:	c90d                	beqz	a0,ffffffffc0200e4e <vmm_init+0x19e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0200e1e:	6914                	ld	a3,16(a0)
ffffffffc0200e20:	6510                	ld	a2,8(a0)
ffffffffc0200e22:	00004517          	auipc	a0,0x4
ffffffffc0200e26:	0ce50513          	addi	a0,a0,206 # ffffffffc0204ef0 <commands+0xa80>
ffffffffc0200e2a:	a94ff0ef          	jal	ra,ffffffffc02000be <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0200e2e:	00004697          	auipc	a3,0x4
ffffffffc0200e32:	0ea68693          	addi	a3,a3,234 # ffffffffc0204f18 <commands+0xaa8>
ffffffffc0200e36:	00004617          	auipc	a2,0x4
ffffffffc0200e3a:	e9260613          	addi	a2,a2,-366 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0200e3e:	0f600593          	li	a1,246
ffffffffc0200e42:	00004517          	auipc	a0,0x4
ffffffffc0200e46:	e9e50513          	addi	a0,a0,-354 # ffffffffc0204ce0 <commands+0x870>
ffffffffc0200e4a:	abcff0ef          	jal	ra,ffffffffc0200106 <__panic>
ffffffffc0200e4e:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc0200e50:	fd3490e3          	bne	s1,s3,ffffffffc0200e10 <vmm_init+0x160>
    }

    mm_destroy(mm);
ffffffffc0200e54:	8522                	mv	a0,s0
ffffffffc0200e56:	e25ff0ef          	jal	ra,ffffffffc0200c7a <mm_destroy>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0200e5a:	4eb010ef          	jal	ra,ffffffffc0202b44 <nr_free_pages>
ffffffffc0200e5e:	28aa1c63          	bne	s4,a0,ffffffffc02010f6 <vmm_init+0x446>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0200e62:	00004517          	auipc	a0,0x4
ffffffffc0200e66:	0f650513          	addi	a0,a0,246 # ffffffffc0204f58 <commands+0xae8>
ffffffffc0200e6a:	a54ff0ef          	jal	ra,ffffffffc02000be <cprintf>

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
	// char *name = "check_pgfault";
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0200e6e:	4d7010ef          	jal	ra,ffffffffc0202b44 <nr_free_pages>
ffffffffc0200e72:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc0200e74:	c81ff0ef          	jal	ra,ffffffffc0200af4 <mm_create>
ffffffffc0200e78:	00010797          	auipc	a5,0x10
ffffffffc0200e7c:	60a7bc23          	sd	a0,1560(a5) # ffffffffc0211490 <check_mm_struct>
ffffffffc0200e80:	842a                	mv	s0,a0

    assert(check_mm_struct != NULL);
ffffffffc0200e82:	2a050a63          	beqz	a0,ffffffffc0201136 <vmm_init+0x486>
    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0200e86:	00010797          	auipc	a5,0x10
ffffffffc0200e8a:	5e278793          	addi	a5,a5,1506 # ffffffffc0211468 <boot_pgdir>
ffffffffc0200e8e:	6384                	ld	s1,0(a5)
    assert(pgdir[0] == 0);
ffffffffc0200e90:	609c                	ld	a5,0(s1)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0200e92:	ed04                	sd	s1,24(a0)
    assert(pgdir[0] == 0);
ffffffffc0200e94:	32079d63          	bnez	a5,ffffffffc02011ce <vmm_init+0x51e>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200e98:	03000513          	li	a0,48
ffffffffc0200e9c:	407020ef          	jal	ra,ffffffffc0203aa2 <kmalloc>
ffffffffc0200ea0:	8a2a                	mv	s4,a0
    if (vma != NULL) {
ffffffffc0200ea2:	14050a63          	beqz	a0,ffffffffc0200ff6 <vmm_init+0x346>
        vma->vm_end = vm_end;
ffffffffc0200ea6:	002007b7          	lui	a5,0x200
ffffffffc0200eaa:	00fa3823          	sd	a5,16(s4)
        vma->vm_flags = vm_flags;
ffffffffc0200eae:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);

    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0200eb0:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0200eb2:	00fa3c23          	sd	a5,24(s4)
    insert_vma_struct(mm, vma);
ffffffffc0200eb6:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc0200eb8:	000a3423          	sd	zero,8(s4)
    insert_vma_struct(mm, vma);
ffffffffc0200ebc:	cf1ff0ef          	jal	ra,ffffffffc0200bac <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0200ec0:	10000593          	li	a1,256
ffffffffc0200ec4:	8522                	mv	a0,s0
ffffffffc0200ec6:	ca9ff0ef          	jal	ra,ffffffffc0200b6e <find_vma>
ffffffffc0200eca:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc0200ece:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0200ed2:	2aaa1263          	bne	s4,a0,ffffffffc0201176 <vmm_init+0x4c6>
        *(char *)(addr + i) = i;
ffffffffc0200ed6:	00f78023          	sb	a5,0(a5) # 200000 <BASE_ADDRESS-0xffffffffc0000000>
        sum += i;
ffffffffc0200eda:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc0200edc:	fee79de3          	bne	a5,a4,ffffffffc0200ed6 <vmm_init+0x226>
        sum += i;
ffffffffc0200ee0:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc0200ee2:	10000793          	li	a5,256
        sum += i;
ffffffffc0200ee6:	35670713          	addi	a4,a4,854 # 1356 <BASE_ADDRESS-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0200eea:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0200eee:	0007c683          	lbu	a3,0(a5)
ffffffffc0200ef2:	0785                	addi	a5,a5,1
ffffffffc0200ef4:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0200ef6:	fec79ce3          	bne	a5,a2,ffffffffc0200eee <vmm_init+0x23e>
    }
    assert(sum == 0);
ffffffffc0200efa:	2a071a63          	bnez	a4,ffffffffc02011ae <vmm_init+0x4fe>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0200efe:	4581                	li	a1,0
ffffffffc0200f00:	8526                	mv	a0,s1
ffffffffc0200f02:	6e9010ef          	jal	ra,ffffffffc0202dea <page_remove>
    }
    return pa2page(PTE_ADDR(pte));
}

static inline struct Page *pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
ffffffffc0200f06:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc0200f08:	00010717          	auipc	a4,0x10
ffffffffc0200f0c:	56870713          	addi	a4,a4,1384 # ffffffffc0211470 <npage>
ffffffffc0200f10:	6318                	ld	a4,0(a4)
    return pa2page(PDE_ADDR(pde));
ffffffffc0200f12:	078a                	slli	a5,a5,0x2
ffffffffc0200f14:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0200f16:	28e7f063          	bleu	a4,a5,ffffffffc0201196 <vmm_init+0x4e6>
    return &pages[PPN(pa) - nbase];
ffffffffc0200f1a:	00005717          	auipc	a4,0x5
ffffffffc0200f1e:	24670713          	addi	a4,a4,582 # ffffffffc0206160 <nbase>
ffffffffc0200f22:	6318                	ld	a4,0(a4)
ffffffffc0200f24:	00010697          	auipc	a3,0x10
ffffffffc0200f28:	67468693          	addi	a3,a3,1652 # ffffffffc0211598 <pages>
ffffffffc0200f2c:	6288                	ld	a0,0(a3)
ffffffffc0200f2e:	8f99                	sub	a5,a5,a4
ffffffffc0200f30:	00379713          	slli	a4,a5,0x3
ffffffffc0200f34:	97ba                	add	a5,a5,a4
ffffffffc0200f36:	078e                	slli	a5,a5,0x3

    free_page(pde2page(pgdir[0]));
ffffffffc0200f38:	953e                	add	a0,a0,a5
ffffffffc0200f3a:	4585                	li	a1,1
ffffffffc0200f3c:	3c3010ef          	jal	ra,ffffffffc0202afe <free_pages>

    pgdir[0] = 0;
ffffffffc0200f40:	0004b023          	sd	zero,0(s1)

    mm->pgdir = NULL;
    mm_destroy(mm);
ffffffffc0200f44:	8522                	mv	a0,s0
    mm->pgdir = NULL;
ffffffffc0200f46:	00043c23          	sd	zero,24(s0)
    mm_destroy(mm);
ffffffffc0200f4a:	d31ff0ef          	jal	ra,ffffffffc0200c7a <mm_destroy>

    check_mm_struct = NULL;
    nr_free_pages_store--;	// szx : Sv39第二级页表多占了一个内存页，所以执行此操作
ffffffffc0200f4e:	19fd                	addi	s3,s3,-1
    check_mm_struct = NULL;
ffffffffc0200f50:	00010797          	auipc	a5,0x10
ffffffffc0200f54:	5407b023          	sd	zero,1344(a5) # ffffffffc0211490 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0200f58:	3ed010ef          	jal	ra,ffffffffc0202b44 <nr_free_pages>
ffffffffc0200f5c:	1aa99d63          	bne	s3,a0,ffffffffc0201116 <vmm_init+0x466>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0200f60:	00004517          	auipc	a0,0x4
ffffffffc0200f64:	0a050513          	addi	a0,a0,160 # ffffffffc0205000 <commands+0xb90>
ffffffffc0200f68:	956ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0200f6c:	3d9010ef          	jal	ra,ffffffffc0202b44 <nr_free_pages>
    nr_free_pages_store--;	// szx : Sv39三级页表多占一个内存页，所以执行此操作
ffffffffc0200f70:	197d                	addi	s2,s2,-1
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0200f72:	1ea91263          	bne	s2,a0,ffffffffc0201156 <vmm_init+0x4a6>
}
ffffffffc0200f76:	6406                	ld	s0,64(sp)
ffffffffc0200f78:	60a6                	ld	ra,72(sp)
ffffffffc0200f7a:	74e2                	ld	s1,56(sp)
ffffffffc0200f7c:	7942                	ld	s2,48(sp)
ffffffffc0200f7e:	79a2                	ld	s3,40(sp)
ffffffffc0200f80:	7a02                	ld	s4,32(sp)
ffffffffc0200f82:	6ae2                	ld	s5,24(sp)
ffffffffc0200f84:	6b42                	ld	s6,16(sp)
ffffffffc0200f86:	6ba2                	ld	s7,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0200f88:	00004517          	auipc	a0,0x4
ffffffffc0200f8c:	09850513          	addi	a0,a0,152 # ffffffffc0205020 <commands+0xbb0>
}
ffffffffc0200f90:	6161                	addi	sp,sp,80
    cprintf("check_vmm() succeeded.\n");
ffffffffc0200f92:	92cff06f          	j	ffffffffc02000be <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0200f96:	00004697          	auipc	a3,0x4
ffffffffc0200f9a:	e7268693          	addi	a3,a3,-398 # ffffffffc0204e08 <commands+0x998>
ffffffffc0200f9e:	00004617          	auipc	a2,0x4
ffffffffc0200fa2:	d2a60613          	addi	a2,a2,-726 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0200fa6:	0dd00593          	li	a1,221
ffffffffc0200faa:	00004517          	auipc	a0,0x4
ffffffffc0200fae:	d3650513          	addi	a0,a0,-714 # ffffffffc0204ce0 <commands+0x870>
ffffffffc0200fb2:	954ff0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0200fb6:	00004697          	auipc	a3,0x4
ffffffffc0200fba:	eda68693          	addi	a3,a3,-294 # ffffffffc0204e90 <commands+0xa20>
ffffffffc0200fbe:	00004617          	auipc	a2,0x4
ffffffffc0200fc2:	d0a60613          	addi	a2,a2,-758 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0200fc6:	0ed00593          	li	a1,237
ffffffffc0200fca:	00004517          	auipc	a0,0x4
ffffffffc0200fce:	d1650513          	addi	a0,a0,-746 # ffffffffc0204ce0 <commands+0x870>
ffffffffc0200fd2:	934ff0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0200fd6:	00004697          	auipc	a3,0x4
ffffffffc0200fda:	eea68693          	addi	a3,a3,-278 # ffffffffc0204ec0 <commands+0xa50>
ffffffffc0200fde:	00004617          	auipc	a2,0x4
ffffffffc0200fe2:	cea60613          	addi	a2,a2,-790 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0200fe6:	0ee00593          	li	a1,238
ffffffffc0200fea:	00004517          	auipc	a0,0x4
ffffffffc0200fee:	cf650513          	addi	a0,a0,-778 # ffffffffc0204ce0 <commands+0x870>
ffffffffc0200ff2:	914ff0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(vma != NULL);
ffffffffc0200ff6:	00004697          	auipc	a3,0x4
ffffffffc0200ffa:	04268693          	addi	a3,a3,66 # ffffffffc0205038 <commands+0xbc8>
ffffffffc0200ffe:	00004617          	auipc	a2,0x4
ffffffffc0201002:	cca60613          	addi	a2,a2,-822 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0201006:	11100593          	li	a1,273
ffffffffc020100a:	00004517          	auipc	a0,0x4
ffffffffc020100e:	cd650513          	addi	a0,a0,-810 # ffffffffc0204ce0 <commands+0x870>
ffffffffc0201012:	8f4ff0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0201016:	00004697          	auipc	a3,0x4
ffffffffc020101a:	dda68693          	addi	a3,a3,-550 # ffffffffc0204df0 <commands+0x980>
ffffffffc020101e:	00004617          	auipc	a2,0x4
ffffffffc0201022:	caa60613          	addi	a2,a2,-854 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0201026:	0db00593          	li	a1,219
ffffffffc020102a:	00004517          	auipc	a0,0x4
ffffffffc020102e:	cb650513          	addi	a0,a0,-842 # ffffffffc0204ce0 <commands+0x870>
ffffffffc0201032:	8d4ff0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(vma4 == NULL);
ffffffffc0201036:	00004697          	auipc	a3,0x4
ffffffffc020103a:	e3a68693          	addi	a3,a3,-454 # ffffffffc0204e70 <commands+0xa00>
ffffffffc020103e:	00004617          	auipc	a2,0x4
ffffffffc0201042:	c8a60613          	addi	a2,a2,-886 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0201046:	0e900593          	li	a1,233
ffffffffc020104a:	00004517          	auipc	a0,0x4
ffffffffc020104e:	c9650513          	addi	a0,a0,-874 # ffffffffc0204ce0 <commands+0x870>
ffffffffc0201052:	8b4ff0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(vma3 == NULL);
ffffffffc0201056:	00004697          	auipc	a3,0x4
ffffffffc020105a:	e0a68693          	addi	a3,a3,-502 # ffffffffc0204e60 <commands+0x9f0>
ffffffffc020105e:	00004617          	auipc	a2,0x4
ffffffffc0201062:	c6a60613          	addi	a2,a2,-918 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0201066:	0e700593          	li	a1,231
ffffffffc020106a:	00004517          	auipc	a0,0x4
ffffffffc020106e:	c7650513          	addi	a0,a0,-906 # ffffffffc0204ce0 <commands+0x870>
ffffffffc0201072:	894ff0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(vma2 != NULL);
ffffffffc0201076:	00004697          	auipc	a3,0x4
ffffffffc020107a:	dda68693          	addi	a3,a3,-550 # ffffffffc0204e50 <commands+0x9e0>
ffffffffc020107e:	00004617          	auipc	a2,0x4
ffffffffc0201082:	c4a60613          	addi	a2,a2,-950 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0201086:	0e500593          	li	a1,229
ffffffffc020108a:	00004517          	auipc	a0,0x4
ffffffffc020108e:	c5650513          	addi	a0,a0,-938 # ffffffffc0204ce0 <commands+0x870>
ffffffffc0201092:	874ff0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(vma1 != NULL);
ffffffffc0201096:	00004697          	auipc	a3,0x4
ffffffffc020109a:	daa68693          	addi	a3,a3,-598 # ffffffffc0204e40 <commands+0x9d0>
ffffffffc020109e:	00004617          	auipc	a2,0x4
ffffffffc02010a2:	c2a60613          	addi	a2,a2,-982 # ffffffffc0204cc8 <commands+0x858>
ffffffffc02010a6:	0e300593          	li	a1,227
ffffffffc02010aa:	00004517          	auipc	a0,0x4
ffffffffc02010ae:	c3650513          	addi	a0,a0,-970 # ffffffffc0204ce0 <commands+0x870>
ffffffffc02010b2:	854ff0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(vma5 == NULL);
ffffffffc02010b6:	00004697          	auipc	a3,0x4
ffffffffc02010ba:	dca68693          	addi	a3,a3,-566 # ffffffffc0204e80 <commands+0xa10>
ffffffffc02010be:	00004617          	auipc	a2,0x4
ffffffffc02010c2:	c0a60613          	addi	a2,a2,-1014 # ffffffffc0204cc8 <commands+0x858>
ffffffffc02010c6:	0eb00593          	li	a1,235
ffffffffc02010ca:	00004517          	auipc	a0,0x4
ffffffffc02010ce:	c1650513          	addi	a0,a0,-1002 # ffffffffc0204ce0 <commands+0x870>
ffffffffc02010d2:	834ff0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(mm != NULL);
ffffffffc02010d6:	00004697          	auipc	a3,0x4
ffffffffc02010da:	d0a68693          	addi	a3,a3,-758 # ffffffffc0204de0 <commands+0x970>
ffffffffc02010de:	00004617          	auipc	a2,0x4
ffffffffc02010e2:	bea60613          	addi	a2,a2,-1046 # ffffffffc0204cc8 <commands+0x858>
ffffffffc02010e6:	0c700593          	li	a1,199
ffffffffc02010ea:	00004517          	auipc	a0,0x4
ffffffffc02010ee:	bf650513          	addi	a0,a0,-1034 # ffffffffc0204ce0 <commands+0x870>
ffffffffc02010f2:	814ff0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02010f6:	00004697          	auipc	a3,0x4
ffffffffc02010fa:	e3a68693          	addi	a3,a3,-454 # ffffffffc0204f30 <commands+0xac0>
ffffffffc02010fe:	00004617          	auipc	a2,0x4
ffffffffc0201102:	bca60613          	addi	a2,a2,-1078 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0201106:	0fb00593          	li	a1,251
ffffffffc020110a:	00004517          	auipc	a0,0x4
ffffffffc020110e:	bd650513          	addi	a0,a0,-1066 # ffffffffc0204ce0 <commands+0x870>
ffffffffc0201112:	ff5fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0201116:	00004697          	auipc	a3,0x4
ffffffffc020111a:	e1a68693          	addi	a3,a3,-486 # ffffffffc0204f30 <commands+0xac0>
ffffffffc020111e:	00004617          	auipc	a2,0x4
ffffffffc0201122:	baa60613          	addi	a2,a2,-1110 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0201126:	12e00593          	li	a1,302
ffffffffc020112a:	00004517          	auipc	a0,0x4
ffffffffc020112e:	bb650513          	addi	a0,a0,-1098 # ffffffffc0204ce0 <commands+0x870>
ffffffffc0201132:	fd5fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0201136:	00004697          	auipc	a3,0x4
ffffffffc020113a:	e4268693          	addi	a3,a3,-446 # ffffffffc0204f78 <commands+0xb08>
ffffffffc020113e:	00004617          	auipc	a2,0x4
ffffffffc0201142:	b8a60613          	addi	a2,a2,-1142 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0201146:	10a00593          	li	a1,266
ffffffffc020114a:	00004517          	auipc	a0,0x4
ffffffffc020114e:	b9650513          	addi	a0,a0,-1130 # ffffffffc0204ce0 <commands+0x870>
ffffffffc0201152:	fb5fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0201156:	00004697          	auipc	a3,0x4
ffffffffc020115a:	dda68693          	addi	a3,a3,-550 # ffffffffc0204f30 <commands+0xac0>
ffffffffc020115e:	00004617          	auipc	a2,0x4
ffffffffc0201162:	b6a60613          	addi	a2,a2,-1174 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0201166:	0bd00593          	li	a1,189
ffffffffc020116a:	00004517          	auipc	a0,0x4
ffffffffc020116e:	b7650513          	addi	a0,a0,-1162 # ffffffffc0204ce0 <commands+0x870>
ffffffffc0201172:	f95fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0201176:	00004697          	auipc	a3,0x4
ffffffffc020117a:	e2a68693          	addi	a3,a3,-470 # ffffffffc0204fa0 <commands+0xb30>
ffffffffc020117e:	00004617          	auipc	a2,0x4
ffffffffc0201182:	b4a60613          	addi	a2,a2,-1206 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0201186:	11600593          	li	a1,278
ffffffffc020118a:	00004517          	auipc	a0,0x4
ffffffffc020118e:	b5650513          	addi	a0,a0,-1194 # ffffffffc0204ce0 <commands+0x870>
ffffffffc0201192:	f75fe0ef          	jal	ra,ffffffffc0200106 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0201196:	00004617          	auipc	a2,0x4
ffffffffc020119a:	e3a60613          	addi	a2,a2,-454 # ffffffffc0204fd0 <commands+0xb60>
ffffffffc020119e:	06500593          	li	a1,101
ffffffffc02011a2:	00004517          	auipc	a0,0x4
ffffffffc02011a6:	e4e50513          	addi	a0,a0,-434 # ffffffffc0204ff0 <commands+0xb80>
ffffffffc02011aa:	f5dfe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(sum == 0);
ffffffffc02011ae:	00004697          	auipc	a3,0x4
ffffffffc02011b2:	e1268693          	addi	a3,a3,-494 # ffffffffc0204fc0 <commands+0xb50>
ffffffffc02011b6:	00004617          	auipc	a2,0x4
ffffffffc02011ba:	b1260613          	addi	a2,a2,-1262 # ffffffffc0204cc8 <commands+0x858>
ffffffffc02011be:	12000593          	li	a1,288
ffffffffc02011c2:	00004517          	auipc	a0,0x4
ffffffffc02011c6:	b1e50513          	addi	a0,a0,-1250 # ffffffffc0204ce0 <commands+0x870>
ffffffffc02011ca:	f3dfe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgdir[0] == 0);
ffffffffc02011ce:	00004697          	auipc	a3,0x4
ffffffffc02011d2:	dc268693          	addi	a3,a3,-574 # ffffffffc0204f90 <commands+0xb20>
ffffffffc02011d6:	00004617          	auipc	a2,0x4
ffffffffc02011da:	af260613          	addi	a2,a2,-1294 # ffffffffc0204cc8 <commands+0x858>
ffffffffc02011de:	10d00593          	li	a1,269
ffffffffc02011e2:	00004517          	auipc	a0,0x4
ffffffffc02011e6:	afe50513          	addi	a0,a0,-1282 # ffffffffc0204ce0 <commands+0x870>
ffffffffc02011ea:	f1dfe0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc02011ee <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc02011ee:	7139                	addi	sp,sp,-64
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02011f0:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc02011f2:	f822                	sd	s0,48(sp)
ffffffffc02011f4:	f426                	sd	s1,40(sp)
ffffffffc02011f6:	fc06                	sd	ra,56(sp)
ffffffffc02011f8:	f04a                	sd	s2,32(sp)
ffffffffc02011fa:	ec4e                	sd	s3,24(sp)
ffffffffc02011fc:	8432                	mv	s0,a2
ffffffffc02011fe:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0201200:	96fff0ef          	jal	ra,ffffffffc0200b6e <find_vma>

    pgfault_num++;
ffffffffc0201204:	00010797          	auipc	a5,0x10
ffffffffc0201208:	24c78793          	addi	a5,a5,588 # ffffffffc0211450 <pgfault_num>
ffffffffc020120c:	439c                	lw	a5,0(a5)
ffffffffc020120e:	2785                	addiw	a5,a5,1
ffffffffc0201210:	00010717          	auipc	a4,0x10
ffffffffc0201214:	24f72023          	sw	a5,576(a4) # ffffffffc0211450 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0201218:	c15d                	beqz	a0,ffffffffc02012be <do_pgfault+0xd0>
ffffffffc020121a:	651c                	ld	a5,8(a0)
ffffffffc020121c:	0af46163          	bltu	s0,a5,ffffffffc02012be <do_pgfault+0xd0>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0201220:	6d1c                	ld	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0201222:	49c1                	li	s3,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0201224:	8b89                	andi	a5,a5,2
ffffffffc0201226:	efa9                	bnez	a5,ffffffffc0201280 <do_pgfault+0x92>
        perm |= (PTE_R | PTE_W);// 可写那就可读
    }
    addr = ROUNDDOWN(addr, PGSIZE);// 取整对齐
ffffffffc0201228:	767d                	lui	a2,0xfffff
    *   mm->pgdir : the PDT of these vma
    *
    */


    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc020122a:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);// 取整对齐
ffffffffc020122c:	8c71                	and	s0,s0,a2
    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc020122e:	85a2                	mv	a1,s0
ffffffffc0201230:	4605                	li	a2,1
ffffffffc0201232:	153010ef          	jal	ra,ffffffffc0202b84 <get_pte>
                                         //PT(Page Table) isn't existed, then
                                         //create a PT.
    if (*ptep == 0) {
ffffffffc0201236:	610c                	ld	a1,0(a0)
ffffffffc0201238:	c5a5                	beqz	a1,ffffffffc02012a0 <do_pgfault+0xb2>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc020123a:	00010797          	auipc	a5,0x10
ffffffffc020123e:	22678793          	addi	a5,a5,550 # ffffffffc0211460 <swap_init_ok>
ffffffffc0201242:	439c                	lw	a5,0(a5)
ffffffffc0201244:	2781                	sext.w	a5,a5
ffffffffc0201246:	c7c9                	beqz	a5,ffffffffc02012d0 <do_pgfault+0xe2>
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            
            ret = swap_in(mm, addr, &page);// 将addr对应的在磁盘上的数据换到page上  
ffffffffc0201248:	0030                	addi	a2,sp,8
ffffffffc020124a:	85a2                	mv	a1,s0
ffffffffc020124c:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc020124e:	e402                	sd	zero,8(sp)
            ret = swap_in(mm, addr, &page);// 将addr对应的在磁盘上的数据换到page上  
ffffffffc0201250:	065000ef          	jal	ra,ffffffffc0201ab4 <swap_in>
ffffffffc0201254:	892a                	mv	s2,a0
            if(ret!=0){
ffffffffc0201256:	e51d                	bnez	a0,ffffffffc0201284 <do_pgfault+0x96>
                cprintf("swap_in failed\n");
                goto failed;
            }
            page_insert(mm->pgdir, page, addr, perm);// 建立索引：addr到page的映射关系，设置page的权限为perm
ffffffffc0201258:	65a2                	ld	a1,8(sp)
ffffffffc020125a:	6c88                	ld	a0,24(s1)
ffffffffc020125c:	86ce                	mv	a3,s3
ffffffffc020125e:	8622                	mv	a2,s0
ffffffffc0201260:	3fd010ef          	jal	ra,ffffffffc0202e5c <page_insert>
            swap_map_swappable(mm, addr, page, 1);// 标记为可替换
ffffffffc0201264:	6622                	ld	a2,8(sp)
ffffffffc0201266:	4685                	li	a3,1
ffffffffc0201268:	85a2                	mv	a1,s0
ffffffffc020126a:	8526                	mv	a0,s1
ffffffffc020126c:	724000ef          	jal	ra,ffffffffc0201990 <swap_map_swappable>
   }

   ret = 0;
failed:
    return ret;
}
ffffffffc0201270:	70e2                	ld	ra,56(sp)
ffffffffc0201272:	7442                	ld	s0,48(sp)
ffffffffc0201274:	854a                	mv	a0,s2
ffffffffc0201276:	74a2                	ld	s1,40(sp)
ffffffffc0201278:	7902                	ld	s2,32(sp)
ffffffffc020127a:	69e2                	ld	s3,24(sp)
ffffffffc020127c:	6121                	addi	sp,sp,64
ffffffffc020127e:	8082                	ret
        perm |= (PTE_R | PTE_W);// 可写那就可读
ffffffffc0201280:	49d9                	li	s3,22
ffffffffc0201282:	b75d                	j	ffffffffc0201228 <do_pgfault+0x3a>
                cprintf("swap_in failed\n");
ffffffffc0201284:	00004517          	auipc	a0,0x4
ffffffffc0201288:	ac450513          	addi	a0,a0,-1340 # ffffffffc0204d48 <commands+0x8d8>
ffffffffc020128c:	e33fe0ef          	jal	ra,ffffffffc02000be <cprintf>
}
ffffffffc0201290:	70e2                	ld	ra,56(sp)
ffffffffc0201292:	7442                	ld	s0,48(sp)
ffffffffc0201294:	854a                	mv	a0,s2
ffffffffc0201296:	74a2                	ld	s1,40(sp)
ffffffffc0201298:	7902                	ld	s2,32(sp)
ffffffffc020129a:	69e2                	ld	s3,24(sp)
ffffffffc020129c:	6121                	addi	sp,sp,64
ffffffffc020129e:	8082                	ret
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc02012a0:	6c88                	ld	a0,24(s1)
ffffffffc02012a2:	864e                	mv	a2,s3
ffffffffc02012a4:	85a2                	mv	a1,s0
ffffffffc02012a6:	76a020ef          	jal	ra,ffffffffc0203a10 <pgdir_alloc_page>
   ret = 0;
ffffffffc02012aa:	4901                	li	s2,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc02012ac:	f171                	bnez	a0,ffffffffc0201270 <do_pgfault+0x82>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc02012ae:	00004517          	auipc	a0,0x4
ffffffffc02012b2:	a7250513          	addi	a0,a0,-1422 # ffffffffc0204d20 <commands+0x8b0>
ffffffffc02012b6:	e09fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    ret = -E_NO_MEM;
ffffffffc02012ba:	5971                	li	s2,-4
            goto failed;
ffffffffc02012bc:	bf55                	j	ffffffffc0201270 <do_pgfault+0x82>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc02012be:	85a2                	mv	a1,s0
ffffffffc02012c0:	00004517          	auipc	a0,0x4
ffffffffc02012c4:	a3050513          	addi	a0,a0,-1488 # ffffffffc0204cf0 <commands+0x880>
ffffffffc02012c8:	df7fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    int ret = -E_INVAL;
ffffffffc02012cc:	5975                	li	s2,-3
        goto failed;
ffffffffc02012ce:	b74d                	j	ffffffffc0201270 <do_pgfault+0x82>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc02012d0:	00004517          	auipc	a0,0x4
ffffffffc02012d4:	a8850513          	addi	a0,a0,-1400 # ffffffffc0204d58 <commands+0x8e8>
ffffffffc02012d8:	de7fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    ret = -E_NO_MEM;
ffffffffc02012dc:	5971                	li	s2,-4
            goto failed;
ffffffffc02012de:	bf49                	j	ffffffffc0201270 <do_pgfault+0x82>

ffffffffc02012e0 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc02012e0:	7135                	addi	sp,sp,-160
ffffffffc02012e2:	ed06                	sd	ra,152(sp)
ffffffffc02012e4:	e922                	sd	s0,144(sp)
ffffffffc02012e6:	e526                	sd	s1,136(sp)
ffffffffc02012e8:	e14a                	sd	s2,128(sp)
ffffffffc02012ea:	fcce                	sd	s3,120(sp)
ffffffffc02012ec:	f8d2                	sd	s4,112(sp)
ffffffffc02012ee:	f4d6                	sd	s5,104(sp)
ffffffffc02012f0:	f0da                	sd	s6,96(sp)
ffffffffc02012f2:	ecde                	sd	s7,88(sp)
ffffffffc02012f4:	e8e2                	sd	s8,80(sp)
ffffffffc02012f6:	e4e6                	sd	s9,72(sp)
ffffffffc02012f8:	e0ea                	sd	s10,64(sp)
ffffffffc02012fa:	fc6e                	sd	s11,56(sp)
     swapfs_init();// 初始化硬盘和一些检查
ffffffffc02012fc:	129020ef          	jal	ra,ffffffffc0203c24 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test// 56/8
     if (!(7 <= max_swap_offset &&
ffffffffc0201300:	00010797          	auipc	a5,0x10
ffffffffc0201304:	22078793          	addi	a5,a5,544 # ffffffffc0211520 <max_swap_offset>
ffffffffc0201308:	6394                	ld	a3,0(a5)
ffffffffc020130a:	010007b7          	lui	a5,0x1000
ffffffffc020130e:	17e1                	addi	a5,a5,-8
ffffffffc0201310:	ff968713          	addi	a4,a3,-7
ffffffffc0201314:	42e7ea63          	bltu	a5,a4,ffffffffc0201748 <swap_init+0x468>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }
     sm = &swap_manager_clock;// 切换sm
ffffffffc0201318:	00009797          	auipc	a5,0x9
ffffffffc020131c:	ce878793          	addi	a5,a5,-792 # ffffffffc020a000 <swap_manager_clock>
     int r = sm->init();
ffffffffc0201320:	6798                	ld	a4,8(a5)
     sm = &swap_manager_clock;// 切换sm
ffffffffc0201322:	00010697          	auipc	a3,0x10
ffffffffc0201326:	12f6bb23          	sd	a5,310(a3) # ffffffffc0211458 <sm>
     int r = sm->init();
ffffffffc020132a:	9702                	jalr	a4
ffffffffc020132c:	8b2a                	mv	s6,a0
     
     if (r == 0)
ffffffffc020132e:	c10d                	beqz	a0,ffffffffc0201350 <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc0201330:	60ea                	ld	ra,152(sp)
ffffffffc0201332:	644a                	ld	s0,144(sp)
ffffffffc0201334:	855a                	mv	a0,s6
ffffffffc0201336:	64aa                	ld	s1,136(sp)
ffffffffc0201338:	690a                	ld	s2,128(sp)
ffffffffc020133a:	79e6                	ld	s3,120(sp)
ffffffffc020133c:	7a46                	ld	s4,112(sp)
ffffffffc020133e:	7aa6                	ld	s5,104(sp)
ffffffffc0201340:	7b06                	ld	s6,96(sp)
ffffffffc0201342:	6be6                	ld	s7,88(sp)
ffffffffc0201344:	6c46                	ld	s8,80(sp)
ffffffffc0201346:	6ca6                	ld	s9,72(sp)
ffffffffc0201348:	6d06                	ld	s10,64(sp)
ffffffffc020134a:	7de2                	ld	s11,56(sp)
ffffffffc020134c:	610d                	addi	sp,sp,160
ffffffffc020134e:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0201350:	00010797          	auipc	a5,0x10
ffffffffc0201354:	10878793          	addi	a5,a5,264 # ffffffffc0211458 <sm>
ffffffffc0201358:	639c                	ld	a5,0(a5)
ffffffffc020135a:	00004517          	auipc	a0,0x4
ffffffffc020135e:	d6e50513          	addi	a0,a0,-658 # ffffffffc02050c8 <commands+0xc58>
ffffffffc0201362:	00010417          	auipc	s0,0x10
ffffffffc0201366:	1fe40413          	addi	s0,s0,510 # ffffffffc0211560 <free_area>
ffffffffc020136a:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;// 初始化成功
ffffffffc020136c:	4785                	li	a5,1
ffffffffc020136e:	00010717          	auipc	a4,0x10
ffffffffc0201372:	0ef72923          	sw	a5,242(a4) # ffffffffc0211460 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0201376:	d49fe0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc020137a:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc020137c:	2e878a63          	beq	a5,s0,ffffffffc0201670 <swap_init+0x390>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201380:	fe87b703          	ld	a4,-24(a5)
ffffffffc0201384:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0201386:	8b05                	andi	a4,a4,1
ffffffffc0201388:	2e070863          	beqz	a4,ffffffffc0201678 <swap_init+0x398>
     int ret, count = 0, total = 0, i;
ffffffffc020138c:	4481                	li	s1,0
ffffffffc020138e:	4901                	li	s2,0
ffffffffc0201390:	a031                	j	ffffffffc020139c <swap_init+0xbc>
ffffffffc0201392:	fe87b703          	ld	a4,-24(a5)
        assert(PageProperty(p));
ffffffffc0201396:	8b09                	andi	a4,a4,2
ffffffffc0201398:	2e070063          	beqz	a4,ffffffffc0201678 <swap_init+0x398>
        count ++, total += p->property;
ffffffffc020139c:	ff87a703          	lw	a4,-8(a5)
ffffffffc02013a0:	679c                	ld	a5,8(a5)
ffffffffc02013a2:	2905                	addiw	s2,s2,1
ffffffffc02013a4:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc02013a6:	fe8796e3          	bne	a5,s0,ffffffffc0201392 <swap_init+0xb2>
ffffffffc02013aa:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc02013ac:	798010ef          	jal	ra,ffffffffc0202b44 <nr_free_pages>
ffffffffc02013b0:	5b351863          	bne	a0,s3,ffffffffc0201960 <swap_init+0x680>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc02013b4:	8626                	mv	a2,s1
ffffffffc02013b6:	85ca                	mv	a1,s2
ffffffffc02013b8:	00004517          	auipc	a0,0x4
ffffffffc02013bc:	d5850513          	addi	a0,a0,-680 # ffffffffc0205110 <commands+0xca0>
ffffffffc02013c0:	cfffe0ef          	jal	ra,ffffffffc02000be <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc02013c4:	f30ff0ef          	jal	ra,ffffffffc0200af4 <mm_create>
ffffffffc02013c8:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc02013ca:	50050b63          	beqz	a0,ffffffffc02018e0 <swap_init+0x600>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc02013ce:	00010797          	auipc	a5,0x10
ffffffffc02013d2:	0c278793          	addi	a5,a5,194 # ffffffffc0211490 <check_mm_struct>
ffffffffc02013d6:	639c                	ld	a5,0(a5)
ffffffffc02013d8:	52079463          	bnez	a5,ffffffffc0201900 <swap_init+0x620>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02013dc:	00010797          	auipc	a5,0x10
ffffffffc02013e0:	08c78793          	addi	a5,a5,140 # ffffffffc0211468 <boot_pgdir>
ffffffffc02013e4:	6398                	ld	a4,0(a5)
     check_mm_struct = mm;
ffffffffc02013e6:	00010797          	auipc	a5,0x10
ffffffffc02013ea:	0aa7b523          	sd	a0,170(a5) # ffffffffc0211490 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc02013ee:	631c                	ld	a5,0(a4)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02013f0:	ec3a                	sd	a4,24(sp)
ffffffffc02013f2:	ed18                	sd	a4,24(a0)
     assert(pgdir[0] == 0);
ffffffffc02013f4:	52079663          	bnez	a5,ffffffffc0201920 <swap_init+0x640>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc02013f8:	6599                	lui	a1,0x6
ffffffffc02013fa:	460d                	li	a2,3
ffffffffc02013fc:	6505                	lui	a0,0x1
ffffffffc02013fe:	f42ff0ef          	jal	ra,ffffffffc0200b40 <vma_create>
ffffffffc0201402:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0201404:	52050e63          	beqz	a0,ffffffffc0201940 <swap_init+0x660>

     insert_vma_struct(mm, vma);
ffffffffc0201408:	855e                	mv	a0,s7
ffffffffc020140a:	fa2ff0ef          	jal	ra,ffffffffc0200bac <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc020140e:	00004517          	auipc	a0,0x4
ffffffffc0201412:	d4250513          	addi	a0,a0,-702 # ffffffffc0205150 <commands+0xce0>
ffffffffc0201416:	ca9fe0ef          	jal	ra,ffffffffc02000be <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc020141a:	018bb503          	ld	a0,24(s7)
ffffffffc020141e:	4605                	li	a2,1
ffffffffc0201420:	6585                	lui	a1,0x1
ffffffffc0201422:	762010ef          	jal	ra,ffffffffc0202b84 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0201426:	40050d63          	beqz	a0,ffffffffc0201840 <swap_init+0x560>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc020142a:	00004517          	auipc	a0,0x4
ffffffffc020142e:	d7650513          	addi	a0,a0,-650 # ffffffffc02051a0 <commands+0xd30>
ffffffffc0201432:	00010a17          	auipc	s4,0x10
ffffffffc0201436:	066a0a13          	addi	s4,s4,102 # ffffffffc0211498 <check_rp>
ffffffffc020143a:	c85fe0ef          	jal	ra,ffffffffc02000be <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020143e:	00010a97          	auipc	s5,0x10
ffffffffc0201442:	07aa8a93          	addi	s5,s5,122 # ffffffffc02114b8 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0201446:	89d2                	mv	s3,s4
          check_rp[i] = alloc_page();
ffffffffc0201448:	4505                	li	a0,1
ffffffffc020144a:	62c010ef          	jal	ra,ffffffffc0202a76 <alloc_pages>
ffffffffc020144e:	00a9b023          	sd	a0,0(s3)
          assert(check_rp[i] != NULL );
ffffffffc0201452:	2a050b63          	beqz	a0,ffffffffc0201708 <swap_init+0x428>
ffffffffc0201456:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0201458:	8b89                	andi	a5,a5,2
ffffffffc020145a:	28079763          	bnez	a5,ffffffffc02016e8 <swap_init+0x408>
ffffffffc020145e:	09a1                	addi	s3,s3,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201460:	ff5994e3          	bne	s3,s5,ffffffffc0201448 <swap_init+0x168>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0201464:	601c                	ld	a5,0(s0)
ffffffffc0201466:	00843983          	ld	s3,8(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc020146a:	00010d17          	auipc	s10,0x10
ffffffffc020146e:	02ed0d13          	addi	s10,s10,46 # ffffffffc0211498 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc0201472:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0201474:	481c                	lw	a5,16(s0)
ffffffffc0201476:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc0201478:	00010797          	auipc	a5,0x10
ffffffffc020147c:	0e87b823          	sd	s0,240(a5) # ffffffffc0211568 <free_area+0x8>
ffffffffc0201480:	00010797          	auipc	a5,0x10
ffffffffc0201484:	0e87b023          	sd	s0,224(a5) # ffffffffc0211560 <free_area>
     nr_free = 0;
ffffffffc0201488:	00010797          	auipc	a5,0x10
ffffffffc020148c:	0e07a423          	sw	zero,232(a5) # ffffffffc0211570 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0201490:	000d3503          	ld	a0,0(s10)
ffffffffc0201494:	4585                	li	a1,1
ffffffffc0201496:	0d21                	addi	s10,s10,8
ffffffffc0201498:	666010ef          	jal	ra,ffffffffc0202afe <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020149c:	ff5d1ae3          	bne	s10,s5,ffffffffc0201490 <swap_init+0x1b0>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc02014a0:	01042d03          	lw	s10,16(s0)
ffffffffc02014a4:	4791                	li	a5,4
ffffffffc02014a6:	36fd1d63          	bne	s10,a5,ffffffffc0201820 <swap_init+0x540>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc02014aa:	00004517          	auipc	a0,0x4
ffffffffc02014ae:	d7e50513          	addi	a0,a0,-642 # ffffffffc0205228 <commands+0xdb8>
ffffffffc02014b2:	c0dfe0ef          	jal	ra,ffffffffc02000be <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02014b6:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc02014b8:	00010797          	auipc	a5,0x10
ffffffffc02014bc:	f807ac23          	sw	zero,-104(a5) # ffffffffc0211450 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02014c0:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc02014c2:	00010797          	auipc	a5,0x10
ffffffffc02014c6:	f8e78793          	addi	a5,a5,-114 # ffffffffc0211450 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02014ca:	00c68023          	sb	a2,0(a3) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc02014ce:	4398                	lw	a4,0(a5)
ffffffffc02014d0:	4585                	li	a1,1
ffffffffc02014d2:	2701                	sext.w	a4,a4
ffffffffc02014d4:	30b71663          	bne	a4,a1,ffffffffc02017e0 <swap_init+0x500>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc02014d8:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc02014dc:	4394                	lw	a3,0(a5)
ffffffffc02014de:	2681                	sext.w	a3,a3
ffffffffc02014e0:	32e69063          	bne	a3,a4,ffffffffc0201800 <swap_init+0x520>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc02014e4:	6689                	lui	a3,0x2
ffffffffc02014e6:	462d                	li	a2,11
ffffffffc02014e8:	00c68023          	sb	a2,0(a3) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc02014ec:	4398                	lw	a4,0(a5)
ffffffffc02014ee:	4589                	li	a1,2
ffffffffc02014f0:	2701                	sext.w	a4,a4
ffffffffc02014f2:	26b71763          	bne	a4,a1,ffffffffc0201760 <swap_init+0x480>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc02014f6:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc02014fa:	4394                	lw	a3,0(a5)
ffffffffc02014fc:	2681                	sext.w	a3,a3
ffffffffc02014fe:	28e69163          	bne	a3,a4,ffffffffc0201780 <swap_init+0x4a0>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0201502:	668d                	lui	a3,0x3
ffffffffc0201504:	4631                	li	a2,12
ffffffffc0201506:	00c68023          	sb	a2,0(a3) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc020150a:	4398                	lw	a4,0(a5)
ffffffffc020150c:	458d                	li	a1,3
ffffffffc020150e:	2701                	sext.w	a4,a4
ffffffffc0201510:	28b71863          	bne	a4,a1,ffffffffc02017a0 <swap_init+0x4c0>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0201514:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc0201518:	4394                	lw	a3,0(a5)
ffffffffc020151a:	2681                	sext.w	a3,a3
ffffffffc020151c:	2ae69263          	bne	a3,a4,ffffffffc02017c0 <swap_init+0x4e0>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0201520:	6691                	lui	a3,0x4
ffffffffc0201522:	4635                	li	a2,13
ffffffffc0201524:	00c68023          	sb	a2,0(a3) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc0201528:	4398                	lw	a4,0(a5)
ffffffffc020152a:	2701                	sext.w	a4,a4
ffffffffc020152c:	33a71a63          	bne	a4,s10,ffffffffc0201860 <swap_init+0x580>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0201530:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0201534:	439c                	lw	a5,0(a5)
ffffffffc0201536:	2781                	sext.w	a5,a5
ffffffffc0201538:	34e79463          	bne	a5,a4,ffffffffc0201880 <swap_init+0x5a0>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc020153c:	481c                	lw	a5,16(s0)
ffffffffc020153e:	36079163          	bnez	a5,ffffffffc02018a0 <swap_init+0x5c0>
ffffffffc0201542:	00010797          	auipc	a5,0x10
ffffffffc0201546:	f7678793          	addi	a5,a5,-138 # ffffffffc02114b8 <swap_in_seq_no>
ffffffffc020154a:	00010717          	auipc	a4,0x10
ffffffffc020154e:	f9670713          	addi	a4,a4,-106 # ffffffffc02114e0 <swap_out_seq_no>
ffffffffc0201552:	00010617          	auipc	a2,0x10
ffffffffc0201556:	f8e60613          	addi	a2,a2,-114 # ffffffffc02114e0 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc020155a:	56fd                	li	a3,-1
ffffffffc020155c:	c394                	sw	a3,0(a5)
ffffffffc020155e:	c314                	sw	a3,0(a4)
ffffffffc0201560:	0791                	addi	a5,a5,4
ffffffffc0201562:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0201564:	fec79ce3          	bne	a5,a2,ffffffffc020155c <swap_init+0x27c>
ffffffffc0201568:	00010697          	auipc	a3,0x10
ffffffffc020156c:	fd868693          	addi	a3,a3,-40 # ffffffffc0211540 <check_ptep>
ffffffffc0201570:	00010817          	auipc	a6,0x10
ffffffffc0201574:	f2880813          	addi	a6,a6,-216 # ffffffffc0211498 <check_rp>
ffffffffc0201578:	6c05                	lui	s8,0x1
    if (PPN(pa) >= npage) {
ffffffffc020157a:	00010c97          	auipc	s9,0x10
ffffffffc020157e:	ef6c8c93          	addi	s9,s9,-266 # ffffffffc0211470 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0201582:	00010d97          	auipc	s11,0x10
ffffffffc0201586:	016d8d93          	addi	s11,s11,22 # ffffffffc0211598 <pages>
ffffffffc020158a:	00005d17          	auipc	s10,0x5
ffffffffc020158e:	bd6d0d13          	addi	s10,s10,-1066 # ffffffffc0206160 <nbase>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0201592:	6562                	ld	a0,24(sp)
         check_ptep[i]=0;
ffffffffc0201594:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0201598:	4601                	li	a2,0
ffffffffc020159a:	85e2                	mv	a1,s8
ffffffffc020159c:	e842                	sd	a6,16(sp)
         check_ptep[i]=0;
ffffffffc020159e:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc02015a0:	5e4010ef          	jal	ra,ffffffffc0202b84 <get_pte>
ffffffffc02015a4:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc02015a6:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc02015a8:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc02015aa:	16050f63          	beqz	a0,ffffffffc0201728 <swap_init+0x448>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc02015ae:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02015b0:	0017f613          	andi	a2,a5,1
ffffffffc02015b4:	10060263          	beqz	a2,ffffffffc02016b8 <swap_init+0x3d8>
    if (PPN(pa) >= npage) {
ffffffffc02015b8:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc02015bc:	078a                	slli	a5,a5,0x2
ffffffffc02015be:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02015c0:	10c7f863          	bleu	a2,a5,ffffffffc02016d0 <swap_init+0x3f0>
    return &pages[PPN(pa) - nbase];
ffffffffc02015c4:	000d3603          	ld	a2,0(s10)
ffffffffc02015c8:	000db583          	ld	a1,0(s11)
ffffffffc02015cc:	00083503          	ld	a0,0(a6)
ffffffffc02015d0:	8f91                	sub	a5,a5,a2
ffffffffc02015d2:	00379613          	slli	a2,a5,0x3
ffffffffc02015d6:	97b2                	add	a5,a5,a2
ffffffffc02015d8:	078e                	slli	a5,a5,0x3
ffffffffc02015da:	97ae                	add	a5,a5,a1
ffffffffc02015dc:	0af51e63          	bne	a0,a5,ffffffffc0201698 <swap_init+0x3b8>
ffffffffc02015e0:	6785                	lui	a5,0x1
ffffffffc02015e2:	9c3e                	add	s8,s8,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02015e4:	6795                	lui	a5,0x5
ffffffffc02015e6:	06a1                	addi	a3,a3,8
ffffffffc02015e8:	0821                	addi	a6,a6,8
ffffffffc02015ea:	fafc14e3          	bne	s8,a5,ffffffffc0201592 <swap_init+0x2b2>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc02015ee:	00004517          	auipc	a0,0x4
ffffffffc02015f2:	d1a50513          	addi	a0,a0,-742 # ffffffffc0205308 <commands+0xe98>
ffffffffc02015f6:	ac9fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    int ret = sm->check_swap();
ffffffffc02015fa:	00010797          	auipc	a5,0x10
ffffffffc02015fe:	e5e78793          	addi	a5,a5,-418 # ffffffffc0211458 <sm>
ffffffffc0201602:	639c                	ld	a5,0(a5)
ffffffffc0201604:	7f9c                	ld	a5,56(a5)
ffffffffc0201606:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0201608:	2a051c63          	bnez	a0,ffffffffc02018c0 <swap_init+0x5e0>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc020160c:	000a3503          	ld	a0,0(s4)
ffffffffc0201610:	4585                	li	a1,1
ffffffffc0201612:	0a21                	addi	s4,s4,8
ffffffffc0201614:	4ea010ef          	jal	ra,ffffffffc0202afe <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201618:	ff5a1ae3          	bne	s4,s5,ffffffffc020160c <swap_init+0x32c>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc020161c:	855e                	mv	a0,s7
ffffffffc020161e:	e5cff0ef          	jal	ra,ffffffffc0200c7a <mm_destroy>
         
     nr_free = nr_free_store;
ffffffffc0201622:	77a2                	ld	a5,40(sp)
ffffffffc0201624:	00010717          	auipc	a4,0x10
ffffffffc0201628:	f4f72623          	sw	a5,-180(a4) # ffffffffc0211570 <free_area+0x10>
     free_list = free_list_store;
ffffffffc020162c:	7782                	ld	a5,32(sp)
ffffffffc020162e:	00010717          	auipc	a4,0x10
ffffffffc0201632:	f2f73923          	sd	a5,-206(a4) # ffffffffc0211560 <free_area>
ffffffffc0201636:	00010797          	auipc	a5,0x10
ffffffffc020163a:	f337b923          	sd	s3,-206(a5) # ffffffffc0211568 <free_area+0x8>

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc020163e:	00898a63          	beq	s3,s0,ffffffffc0201652 <swap_init+0x372>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0201642:	ff89a783          	lw	a5,-8(s3)
    return listelm->next;
ffffffffc0201646:	0089b983          	ld	s3,8(s3)
ffffffffc020164a:	397d                	addiw	s2,s2,-1
ffffffffc020164c:	9c9d                	subw	s1,s1,a5
     while ((le = list_next(le)) != &free_list) {
ffffffffc020164e:	fe899ae3          	bne	s3,s0,ffffffffc0201642 <swap_init+0x362>
     }
     cprintf("count is %d, total is %d\n",count,total);
ffffffffc0201652:	8626                	mv	a2,s1
ffffffffc0201654:	85ca                	mv	a1,s2
ffffffffc0201656:	00004517          	auipc	a0,0x4
ffffffffc020165a:	ce250513          	addi	a0,a0,-798 # ffffffffc0205338 <commands+0xec8>
ffffffffc020165e:	a61fe0ef          	jal	ra,ffffffffc02000be <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
ffffffffc0201662:	00004517          	auipc	a0,0x4
ffffffffc0201666:	cf650513          	addi	a0,a0,-778 # ffffffffc0205358 <commands+0xee8>
ffffffffc020166a:	a55fe0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc020166e:	b1c9                	j	ffffffffc0201330 <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc0201670:	4481                	li	s1,0
ffffffffc0201672:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201674:	4981                	li	s3,0
ffffffffc0201676:	bb1d                	j	ffffffffc02013ac <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc0201678:	00004697          	auipc	a3,0x4
ffffffffc020167c:	a6868693          	addi	a3,a3,-1432 # ffffffffc02050e0 <commands+0xc70>
ffffffffc0201680:	00003617          	auipc	a2,0x3
ffffffffc0201684:	64860613          	addi	a2,a2,1608 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0201688:	0d500593          	li	a1,213
ffffffffc020168c:	00004517          	auipc	a0,0x4
ffffffffc0201690:	a2c50513          	addi	a0,a0,-1492 # ffffffffc02050b8 <commands+0xc48>
ffffffffc0201694:	a73fe0ef          	jal	ra,ffffffffc0200106 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0201698:	00004697          	auipc	a3,0x4
ffffffffc020169c:	c4868693          	addi	a3,a3,-952 # ffffffffc02052e0 <commands+0xe70>
ffffffffc02016a0:	00003617          	auipc	a2,0x3
ffffffffc02016a4:	62860613          	addi	a2,a2,1576 # ffffffffc0204cc8 <commands+0x858>
ffffffffc02016a8:	11500593          	li	a1,277
ffffffffc02016ac:	00004517          	auipc	a0,0x4
ffffffffc02016b0:	a0c50513          	addi	a0,a0,-1524 # ffffffffc02050b8 <commands+0xc48>
ffffffffc02016b4:	a53fe0ef          	jal	ra,ffffffffc0200106 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02016b8:	00004617          	auipc	a2,0x4
ffffffffc02016bc:	c0060613          	addi	a2,a2,-1024 # ffffffffc02052b8 <commands+0xe48>
ffffffffc02016c0:	07000593          	li	a1,112
ffffffffc02016c4:	00004517          	auipc	a0,0x4
ffffffffc02016c8:	92c50513          	addi	a0,a0,-1748 # ffffffffc0204ff0 <commands+0xb80>
ffffffffc02016cc:	a3bfe0ef          	jal	ra,ffffffffc0200106 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02016d0:	00004617          	auipc	a2,0x4
ffffffffc02016d4:	90060613          	addi	a2,a2,-1792 # ffffffffc0204fd0 <commands+0xb60>
ffffffffc02016d8:	06500593          	li	a1,101
ffffffffc02016dc:	00004517          	auipc	a0,0x4
ffffffffc02016e0:	91450513          	addi	a0,a0,-1772 # ffffffffc0204ff0 <commands+0xb80>
ffffffffc02016e4:	a23fe0ef          	jal	ra,ffffffffc0200106 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc02016e8:	00004697          	auipc	a3,0x4
ffffffffc02016ec:	af868693          	addi	a3,a3,-1288 # ffffffffc02051e0 <commands+0xd70>
ffffffffc02016f0:	00003617          	auipc	a2,0x3
ffffffffc02016f4:	5d860613          	addi	a2,a2,1496 # ffffffffc0204cc8 <commands+0x858>
ffffffffc02016f8:	0f600593          	li	a1,246
ffffffffc02016fc:	00004517          	auipc	a0,0x4
ffffffffc0201700:	9bc50513          	addi	a0,a0,-1604 # ffffffffc02050b8 <commands+0xc48>
ffffffffc0201704:	a03fe0ef          	jal	ra,ffffffffc0200106 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0201708:	00004697          	auipc	a3,0x4
ffffffffc020170c:	ac068693          	addi	a3,a3,-1344 # ffffffffc02051c8 <commands+0xd58>
ffffffffc0201710:	00003617          	auipc	a2,0x3
ffffffffc0201714:	5b860613          	addi	a2,a2,1464 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0201718:	0f500593          	li	a1,245
ffffffffc020171c:	00004517          	auipc	a0,0x4
ffffffffc0201720:	99c50513          	addi	a0,a0,-1636 # ffffffffc02050b8 <commands+0xc48>
ffffffffc0201724:	9e3fe0ef          	jal	ra,ffffffffc0200106 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0201728:	00004697          	auipc	a3,0x4
ffffffffc020172c:	b7868693          	addi	a3,a3,-1160 # ffffffffc02052a0 <commands+0xe30>
ffffffffc0201730:	00003617          	auipc	a2,0x3
ffffffffc0201734:	59860613          	addi	a2,a2,1432 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0201738:	11400593          	li	a1,276
ffffffffc020173c:	00004517          	auipc	a0,0x4
ffffffffc0201740:	97c50513          	addi	a0,a0,-1668 # ffffffffc02050b8 <commands+0xc48>
ffffffffc0201744:	9c3fe0ef          	jal	ra,ffffffffc0200106 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0201748:	00004617          	auipc	a2,0x4
ffffffffc020174c:	95060613          	addi	a2,a2,-1712 # ffffffffc0205098 <commands+0xc28>
ffffffffc0201750:	02900593          	li	a1,41
ffffffffc0201754:	00004517          	auipc	a0,0x4
ffffffffc0201758:	96450513          	addi	a0,a0,-1692 # ffffffffc02050b8 <commands+0xc48>
ffffffffc020175c:	9abfe0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==2);
ffffffffc0201760:	00004697          	auipc	a3,0x4
ffffffffc0201764:	b0068693          	addi	a3,a3,-1280 # ffffffffc0205260 <commands+0xdf0>
ffffffffc0201768:	00003617          	auipc	a2,0x3
ffffffffc020176c:	56060613          	addi	a2,a2,1376 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0201770:	0b000593          	li	a1,176
ffffffffc0201774:	00004517          	auipc	a0,0x4
ffffffffc0201778:	94450513          	addi	a0,a0,-1724 # ffffffffc02050b8 <commands+0xc48>
ffffffffc020177c:	98bfe0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==2);
ffffffffc0201780:	00004697          	auipc	a3,0x4
ffffffffc0201784:	ae068693          	addi	a3,a3,-1312 # ffffffffc0205260 <commands+0xdf0>
ffffffffc0201788:	00003617          	auipc	a2,0x3
ffffffffc020178c:	54060613          	addi	a2,a2,1344 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0201790:	0b200593          	li	a1,178
ffffffffc0201794:	00004517          	auipc	a0,0x4
ffffffffc0201798:	92450513          	addi	a0,a0,-1756 # ffffffffc02050b8 <commands+0xc48>
ffffffffc020179c:	96bfe0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==3);
ffffffffc02017a0:	00004697          	auipc	a3,0x4
ffffffffc02017a4:	ad068693          	addi	a3,a3,-1328 # ffffffffc0205270 <commands+0xe00>
ffffffffc02017a8:	00003617          	auipc	a2,0x3
ffffffffc02017ac:	52060613          	addi	a2,a2,1312 # ffffffffc0204cc8 <commands+0x858>
ffffffffc02017b0:	0b400593          	li	a1,180
ffffffffc02017b4:	00004517          	auipc	a0,0x4
ffffffffc02017b8:	90450513          	addi	a0,a0,-1788 # ffffffffc02050b8 <commands+0xc48>
ffffffffc02017bc:	94bfe0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==3);
ffffffffc02017c0:	00004697          	auipc	a3,0x4
ffffffffc02017c4:	ab068693          	addi	a3,a3,-1360 # ffffffffc0205270 <commands+0xe00>
ffffffffc02017c8:	00003617          	auipc	a2,0x3
ffffffffc02017cc:	50060613          	addi	a2,a2,1280 # ffffffffc0204cc8 <commands+0x858>
ffffffffc02017d0:	0b600593          	li	a1,182
ffffffffc02017d4:	00004517          	auipc	a0,0x4
ffffffffc02017d8:	8e450513          	addi	a0,a0,-1820 # ffffffffc02050b8 <commands+0xc48>
ffffffffc02017dc:	92bfe0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==1);
ffffffffc02017e0:	00004697          	auipc	a3,0x4
ffffffffc02017e4:	a7068693          	addi	a3,a3,-1424 # ffffffffc0205250 <commands+0xde0>
ffffffffc02017e8:	00003617          	auipc	a2,0x3
ffffffffc02017ec:	4e060613          	addi	a2,a2,1248 # ffffffffc0204cc8 <commands+0x858>
ffffffffc02017f0:	0ac00593          	li	a1,172
ffffffffc02017f4:	00004517          	auipc	a0,0x4
ffffffffc02017f8:	8c450513          	addi	a0,a0,-1852 # ffffffffc02050b8 <commands+0xc48>
ffffffffc02017fc:	90bfe0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==1);
ffffffffc0201800:	00004697          	auipc	a3,0x4
ffffffffc0201804:	a5068693          	addi	a3,a3,-1456 # ffffffffc0205250 <commands+0xde0>
ffffffffc0201808:	00003617          	auipc	a2,0x3
ffffffffc020180c:	4c060613          	addi	a2,a2,1216 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0201810:	0ae00593          	li	a1,174
ffffffffc0201814:	00004517          	auipc	a0,0x4
ffffffffc0201818:	8a450513          	addi	a0,a0,-1884 # ffffffffc02050b8 <commands+0xc48>
ffffffffc020181c:	8ebfe0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0201820:	00004697          	auipc	a3,0x4
ffffffffc0201824:	9e068693          	addi	a3,a3,-1568 # ffffffffc0205200 <commands+0xd90>
ffffffffc0201828:	00003617          	auipc	a2,0x3
ffffffffc020182c:	4a060613          	addi	a2,a2,1184 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0201830:	10300593          	li	a1,259
ffffffffc0201834:	00004517          	auipc	a0,0x4
ffffffffc0201838:	88450513          	addi	a0,a0,-1916 # ffffffffc02050b8 <commands+0xc48>
ffffffffc020183c:	8cbfe0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0201840:	00004697          	auipc	a3,0x4
ffffffffc0201844:	94868693          	addi	a3,a3,-1720 # ffffffffc0205188 <commands+0xd18>
ffffffffc0201848:	00003617          	auipc	a2,0x3
ffffffffc020184c:	48060613          	addi	a2,a2,1152 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0201850:	0f000593          	li	a1,240
ffffffffc0201854:	00004517          	auipc	a0,0x4
ffffffffc0201858:	86450513          	addi	a0,a0,-1948 # ffffffffc02050b8 <commands+0xc48>
ffffffffc020185c:	8abfe0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==4);
ffffffffc0201860:	00004697          	auipc	a3,0x4
ffffffffc0201864:	a2068693          	addi	a3,a3,-1504 # ffffffffc0205280 <commands+0xe10>
ffffffffc0201868:	00003617          	auipc	a2,0x3
ffffffffc020186c:	46060613          	addi	a2,a2,1120 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0201870:	0b800593          	li	a1,184
ffffffffc0201874:	00004517          	auipc	a0,0x4
ffffffffc0201878:	84450513          	addi	a0,a0,-1980 # ffffffffc02050b8 <commands+0xc48>
ffffffffc020187c:	88bfe0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==4);
ffffffffc0201880:	00004697          	auipc	a3,0x4
ffffffffc0201884:	a0068693          	addi	a3,a3,-1536 # ffffffffc0205280 <commands+0xe10>
ffffffffc0201888:	00003617          	auipc	a2,0x3
ffffffffc020188c:	44060613          	addi	a2,a2,1088 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0201890:	0ba00593          	li	a1,186
ffffffffc0201894:	00004517          	auipc	a0,0x4
ffffffffc0201898:	82450513          	addi	a0,a0,-2012 # ffffffffc02050b8 <commands+0xc48>
ffffffffc020189c:	86bfe0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert( nr_free == 0);         
ffffffffc02018a0:	00004697          	auipc	a3,0x4
ffffffffc02018a4:	9f068693          	addi	a3,a3,-1552 # ffffffffc0205290 <commands+0xe20>
ffffffffc02018a8:	00003617          	auipc	a2,0x3
ffffffffc02018ac:	42060613          	addi	a2,a2,1056 # ffffffffc0204cc8 <commands+0x858>
ffffffffc02018b0:	10c00593          	li	a1,268
ffffffffc02018b4:	00004517          	auipc	a0,0x4
ffffffffc02018b8:	80450513          	addi	a0,a0,-2044 # ffffffffc02050b8 <commands+0xc48>
ffffffffc02018bc:	84bfe0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(ret==0);
ffffffffc02018c0:	00004697          	auipc	a3,0x4
ffffffffc02018c4:	a7068693          	addi	a3,a3,-1424 # ffffffffc0205330 <commands+0xec0>
ffffffffc02018c8:	00003617          	auipc	a2,0x3
ffffffffc02018cc:	40060613          	addi	a2,a2,1024 # ffffffffc0204cc8 <commands+0x858>
ffffffffc02018d0:	11b00593          	li	a1,283
ffffffffc02018d4:	00003517          	auipc	a0,0x3
ffffffffc02018d8:	7e450513          	addi	a0,a0,2020 # ffffffffc02050b8 <commands+0xc48>
ffffffffc02018dc:	82bfe0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(mm != NULL);
ffffffffc02018e0:	00003697          	auipc	a3,0x3
ffffffffc02018e4:	50068693          	addi	a3,a3,1280 # ffffffffc0204de0 <commands+0x970>
ffffffffc02018e8:	00003617          	auipc	a2,0x3
ffffffffc02018ec:	3e060613          	addi	a2,a2,992 # ffffffffc0204cc8 <commands+0x858>
ffffffffc02018f0:	0dd00593          	li	a1,221
ffffffffc02018f4:	00003517          	auipc	a0,0x3
ffffffffc02018f8:	7c450513          	addi	a0,a0,1988 # ffffffffc02050b8 <commands+0xc48>
ffffffffc02018fc:	80bfe0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0201900:	00004697          	auipc	a3,0x4
ffffffffc0201904:	83868693          	addi	a3,a3,-1992 # ffffffffc0205138 <commands+0xcc8>
ffffffffc0201908:	00003617          	auipc	a2,0x3
ffffffffc020190c:	3c060613          	addi	a2,a2,960 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0201910:	0e000593          	li	a1,224
ffffffffc0201914:	00003517          	auipc	a0,0x3
ffffffffc0201918:	7a450513          	addi	a0,a0,1956 # ffffffffc02050b8 <commands+0xc48>
ffffffffc020191c:	feafe0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0201920:	00003697          	auipc	a3,0x3
ffffffffc0201924:	67068693          	addi	a3,a3,1648 # ffffffffc0204f90 <commands+0xb20>
ffffffffc0201928:	00003617          	auipc	a2,0x3
ffffffffc020192c:	3a060613          	addi	a2,a2,928 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0201930:	0e500593          	li	a1,229
ffffffffc0201934:	00003517          	auipc	a0,0x3
ffffffffc0201938:	78450513          	addi	a0,a0,1924 # ffffffffc02050b8 <commands+0xc48>
ffffffffc020193c:	fcafe0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(vma != NULL);
ffffffffc0201940:	00003697          	auipc	a3,0x3
ffffffffc0201944:	6f868693          	addi	a3,a3,1784 # ffffffffc0205038 <commands+0xbc8>
ffffffffc0201948:	00003617          	auipc	a2,0x3
ffffffffc020194c:	38060613          	addi	a2,a2,896 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0201950:	0e800593          	li	a1,232
ffffffffc0201954:	00003517          	auipc	a0,0x3
ffffffffc0201958:	76450513          	addi	a0,a0,1892 # ffffffffc02050b8 <commands+0xc48>
ffffffffc020195c:	faafe0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(total == nr_free_pages());
ffffffffc0201960:	00003697          	auipc	a3,0x3
ffffffffc0201964:	79068693          	addi	a3,a3,1936 # ffffffffc02050f0 <commands+0xc80>
ffffffffc0201968:	00003617          	auipc	a2,0x3
ffffffffc020196c:	36060613          	addi	a2,a2,864 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0201970:	0d800593          	li	a1,216
ffffffffc0201974:	00003517          	auipc	a0,0x3
ffffffffc0201978:	74450513          	addi	a0,a0,1860 # ffffffffc02050b8 <commands+0xc48>
ffffffffc020197c:	f8afe0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0201980 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0201980:	00010797          	auipc	a5,0x10
ffffffffc0201984:	ad878793          	addi	a5,a5,-1320 # ffffffffc0211458 <sm>
ffffffffc0201988:	639c                	ld	a5,0(a5)
ffffffffc020198a:	0107b303          	ld	t1,16(a5)
ffffffffc020198e:	8302                	jr	t1

ffffffffc0201990 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0201990:	00010797          	auipc	a5,0x10
ffffffffc0201994:	ac878793          	addi	a5,a5,-1336 # ffffffffc0211458 <sm>
ffffffffc0201998:	639c                	ld	a5,0(a5)
ffffffffc020199a:	0207b303          	ld	t1,32(a5)
ffffffffc020199e:	8302                	jr	t1

ffffffffc02019a0 <swap_out>:
{
ffffffffc02019a0:	711d                	addi	sp,sp,-96
ffffffffc02019a2:	ec86                	sd	ra,88(sp)
ffffffffc02019a4:	e8a2                	sd	s0,80(sp)
ffffffffc02019a6:	e4a6                	sd	s1,72(sp)
ffffffffc02019a8:	e0ca                	sd	s2,64(sp)
ffffffffc02019aa:	fc4e                	sd	s3,56(sp)
ffffffffc02019ac:	f852                	sd	s4,48(sp)
ffffffffc02019ae:	f456                	sd	s5,40(sp)
ffffffffc02019b0:	f05a                	sd	s6,32(sp)
ffffffffc02019b2:	ec5e                	sd	s7,24(sp)
ffffffffc02019b4:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc02019b6:	cde9                	beqz	a1,ffffffffc0201a90 <swap_out+0xf0>
ffffffffc02019b8:	8ab2                	mv	s5,a2
ffffffffc02019ba:	892a                	mv	s2,a0
ffffffffc02019bc:	8a2e                	mv	s4,a1
ffffffffc02019be:	4401                	li	s0,0
ffffffffc02019c0:	00010997          	auipc	s3,0x10
ffffffffc02019c4:	a9898993          	addi	s3,s3,-1384 # ffffffffc0211458 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc02019c8:	00004b17          	auipc	s6,0x4
ffffffffc02019cc:	a10b0b13          	addi	s6,s6,-1520 # ffffffffc02053d8 <commands+0xf68>
                    cprintf("SWAP: failed to save\n");
ffffffffc02019d0:	00004b97          	auipc	s7,0x4
ffffffffc02019d4:	9f0b8b93          	addi	s7,s7,-1552 # ffffffffc02053c0 <commands+0xf50>
ffffffffc02019d8:	a825                	j	ffffffffc0201a10 <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc02019da:	67a2                	ld	a5,8(sp)
ffffffffc02019dc:	8626                	mv	a2,s1
ffffffffc02019de:	85a2                	mv	a1,s0
ffffffffc02019e0:	63b4                	ld	a3,64(a5)
ffffffffc02019e2:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc02019e4:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc02019e6:	82b1                	srli	a3,a3,0xc
ffffffffc02019e8:	0685                	addi	a3,a3,1
ffffffffc02019ea:	ed4fe0ef          	jal	ra,ffffffffc02000be <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc02019ee:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc02019f0:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc02019f2:	613c                	ld	a5,64(a0)
ffffffffc02019f4:	83b1                	srli	a5,a5,0xc
ffffffffc02019f6:	0785                	addi	a5,a5,1
ffffffffc02019f8:	07a2                	slli	a5,a5,0x8
ffffffffc02019fa:	00fc3023          	sd	a5,0(s8) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
                    free_page(page);
ffffffffc02019fe:	100010ef          	jal	ra,ffffffffc0202afe <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0201a02:	01893503          	ld	a0,24(s2)
ffffffffc0201a06:	85a6                	mv	a1,s1
ffffffffc0201a08:	002020ef          	jal	ra,ffffffffc0203a0a <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0201a0c:	048a0d63          	beq	s4,s0,ffffffffc0201a66 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0201a10:	0009b783          	ld	a5,0(s3)
ffffffffc0201a14:	8656                	mv	a2,s5
ffffffffc0201a16:	002c                	addi	a1,sp,8
ffffffffc0201a18:	7b9c                	ld	a5,48(a5)
ffffffffc0201a1a:	854a                	mv	a0,s2
ffffffffc0201a1c:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0201a1e:	e12d                	bnez	a0,ffffffffc0201a80 <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0201a20:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0201a22:	01893503          	ld	a0,24(s2)
ffffffffc0201a26:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0201a28:	63a4                	ld	s1,64(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0201a2a:	85a6                	mv	a1,s1
ffffffffc0201a2c:	158010ef          	jal	ra,ffffffffc0202b84 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0201a30:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0201a32:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0201a34:	8b85                	andi	a5,a5,1
ffffffffc0201a36:	cfb9                	beqz	a5,ffffffffc0201a94 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0201a38:	65a2                	ld	a1,8(sp)
ffffffffc0201a3a:	61bc                	ld	a5,64(a1)
ffffffffc0201a3c:	83b1                	srli	a5,a5,0xc
ffffffffc0201a3e:	00178513          	addi	a0,a5,1
ffffffffc0201a42:	0522                	slli	a0,a0,0x8
ffffffffc0201a44:	2be020ef          	jal	ra,ffffffffc0203d02 <swapfs_write>
ffffffffc0201a48:	d949                	beqz	a0,ffffffffc02019da <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0201a4a:	855e                	mv	a0,s7
ffffffffc0201a4c:	e72fe0ef          	jal	ra,ffffffffc02000be <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0201a50:	0009b783          	ld	a5,0(s3)
ffffffffc0201a54:	6622                	ld	a2,8(sp)
ffffffffc0201a56:	4681                	li	a3,0
ffffffffc0201a58:	739c                	ld	a5,32(a5)
ffffffffc0201a5a:	85a6                	mv	a1,s1
ffffffffc0201a5c:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0201a5e:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0201a60:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0201a62:	fa8a17e3          	bne	s4,s0,ffffffffc0201a10 <swap_out+0x70>
}
ffffffffc0201a66:	8522                	mv	a0,s0
ffffffffc0201a68:	60e6                	ld	ra,88(sp)
ffffffffc0201a6a:	6446                	ld	s0,80(sp)
ffffffffc0201a6c:	64a6                	ld	s1,72(sp)
ffffffffc0201a6e:	6906                	ld	s2,64(sp)
ffffffffc0201a70:	79e2                	ld	s3,56(sp)
ffffffffc0201a72:	7a42                	ld	s4,48(sp)
ffffffffc0201a74:	7aa2                	ld	s5,40(sp)
ffffffffc0201a76:	7b02                	ld	s6,32(sp)
ffffffffc0201a78:	6be2                	ld	s7,24(sp)
ffffffffc0201a7a:	6c42                	ld	s8,16(sp)
ffffffffc0201a7c:	6125                	addi	sp,sp,96
ffffffffc0201a7e:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0201a80:	85a2                	mv	a1,s0
ffffffffc0201a82:	00004517          	auipc	a0,0x4
ffffffffc0201a86:	8f650513          	addi	a0,a0,-1802 # ffffffffc0205378 <commands+0xf08>
ffffffffc0201a8a:	e34fe0ef          	jal	ra,ffffffffc02000be <cprintf>
                  break;
ffffffffc0201a8e:	bfe1                	j	ffffffffc0201a66 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0201a90:	4401                	li	s0,0
ffffffffc0201a92:	bfd1                	j	ffffffffc0201a66 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0201a94:	00004697          	auipc	a3,0x4
ffffffffc0201a98:	91468693          	addi	a3,a3,-1772 # ffffffffc02053a8 <commands+0xf38>
ffffffffc0201a9c:	00003617          	auipc	a2,0x3
ffffffffc0201aa0:	22c60613          	addi	a2,a2,556 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0201aa4:	08100593          	li	a1,129
ffffffffc0201aa8:	00003517          	auipc	a0,0x3
ffffffffc0201aac:	61050513          	addi	a0,a0,1552 # ffffffffc02050b8 <commands+0xc48>
ffffffffc0201ab0:	e56fe0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0201ab4 <swap_in>:
{
ffffffffc0201ab4:	7179                	addi	sp,sp,-48
ffffffffc0201ab6:	e84a                	sd	s2,16(sp)
ffffffffc0201ab8:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0201aba:	4505                	li	a0,1
{
ffffffffc0201abc:	ec26                	sd	s1,24(sp)
ffffffffc0201abe:	e44e                	sd	s3,8(sp)
ffffffffc0201ac0:	f406                	sd	ra,40(sp)
ffffffffc0201ac2:	f022                	sd	s0,32(sp)
ffffffffc0201ac4:	84ae                	mv	s1,a1
ffffffffc0201ac6:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0201ac8:	7af000ef          	jal	ra,ffffffffc0202a76 <alloc_pages>
     assert(result!=NULL);
ffffffffc0201acc:	c129                	beqz	a0,ffffffffc0201b0e <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0201ace:	842a                	mv	s0,a0
ffffffffc0201ad0:	01893503          	ld	a0,24(s2)
ffffffffc0201ad4:	4601                	li	a2,0
ffffffffc0201ad6:	85a6                	mv	a1,s1
ffffffffc0201ad8:	0ac010ef          	jal	ra,ffffffffc0202b84 <get_pte>
ffffffffc0201adc:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0201ade:	6108                	ld	a0,0(a0)
ffffffffc0201ae0:	85a2                	mv	a1,s0
ffffffffc0201ae2:	17a020ef          	jal	ra,ffffffffc0203c5c <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0201ae6:	00093583          	ld	a1,0(s2)
ffffffffc0201aea:	8626                	mv	a2,s1
ffffffffc0201aec:	00003517          	auipc	a0,0x3
ffffffffc0201af0:	56c50513          	addi	a0,a0,1388 # ffffffffc0205058 <commands+0xbe8>
ffffffffc0201af4:	81a1                	srli	a1,a1,0x8
ffffffffc0201af6:	dc8fe0ef          	jal	ra,ffffffffc02000be <cprintf>
}
ffffffffc0201afa:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0201afc:	0089b023          	sd	s0,0(s3)
}
ffffffffc0201b00:	7402                	ld	s0,32(sp)
ffffffffc0201b02:	64e2                	ld	s1,24(sp)
ffffffffc0201b04:	6942                	ld	s2,16(sp)
ffffffffc0201b06:	69a2                	ld	s3,8(sp)
ffffffffc0201b08:	4501                	li	a0,0
ffffffffc0201b0a:	6145                	addi	sp,sp,48
ffffffffc0201b0c:	8082                	ret
     assert(result!=NULL);
ffffffffc0201b0e:	00003697          	auipc	a3,0x3
ffffffffc0201b12:	53a68693          	addi	a3,a3,1338 # ffffffffc0205048 <commands+0xbd8>
ffffffffc0201b16:	00003617          	auipc	a2,0x3
ffffffffc0201b1a:	1b260613          	addi	a2,a2,434 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0201b1e:	09700593          	li	a1,151
ffffffffc0201b22:	00003517          	auipc	a0,0x3
ffffffffc0201b26:	59650513          	addi	a0,a0,1430 # ffffffffc02050b8 <commands+0xc48>
ffffffffc0201b2a:	ddcfe0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0201b2e <default_init>:
    elm->prev = elm->next = elm;
ffffffffc0201b2e:	00010797          	auipc	a5,0x10
ffffffffc0201b32:	a3278793          	addi	a5,a5,-1486 # ffffffffc0211560 <free_area>
ffffffffc0201b36:	e79c                	sd	a5,8(a5)
ffffffffc0201b38:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0201b3a:	0007a823          	sw	zero,16(a5)
}
ffffffffc0201b3e:	8082                	ret

ffffffffc0201b40 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0201b40:	00010517          	auipc	a0,0x10
ffffffffc0201b44:	a3056503          	lwu	a0,-1488(a0) # ffffffffc0211570 <free_area+0x10>
ffffffffc0201b48:	8082                	ret

ffffffffc0201b4a <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0201b4a:	715d                	addi	sp,sp,-80
ffffffffc0201b4c:	f84a                	sd	s2,48(sp)
    return listelm->next;
ffffffffc0201b4e:	00010917          	auipc	s2,0x10
ffffffffc0201b52:	a1290913          	addi	s2,s2,-1518 # ffffffffc0211560 <free_area>
ffffffffc0201b56:	00893783          	ld	a5,8(s2)
ffffffffc0201b5a:	e486                	sd	ra,72(sp)
ffffffffc0201b5c:	e0a2                	sd	s0,64(sp)
ffffffffc0201b5e:	fc26                	sd	s1,56(sp)
ffffffffc0201b60:	f44e                	sd	s3,40(sp)
ffffffffc0201b62:	f052                	sd	s4,32(sp)
ffffffffc0201b64:	ec56                	sd	s5,24(sp)
ffffffffc0201b66:	e85a                	sd	s6,16(sp)
ffffffffc0201b68:	e45e                	sd	s7,8(sp)
ffffffffc0201b6a:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201b6c:	31278f63          	beq	a5,s2,ffffffffc0201e8a <default_check+0x340>
ffffffffc0201b70:	fe87b703          	ld	a4,-24(a5)
ffffffffc0201b74:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0201b76:	8b05                	andi	a4,a4,1
ffffffffc0201b78:	30070d63          	beqz	a4,ffffffffc0201e92 <default_check+0x348>
    int count = 0, total = 0;
ffffffffc0201b7c:	4401                	li	s0,0
ffffffffc0201b7e:	4481                	li	s1,0
ffffffffc0201b80:	a031                	j	ffffffffc0201b8c <default_check+0x42>
ffffffffc0201b82:	fe87b703          	ld	a4,-24(a5)
        assert(PageProperty(p));
ffffffffc0201b86:	8b09                	andi	a4,a4,2
ffffffffc0201b88:	30070563          	beqz	a4,ffffffffc0201e92 <default_check+0x348>
        count ++, total += p->property;
ffffffffc0201b8c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201b90:	679c                	ld	a5,8(a5)
ffffffffc0201b92:	2485                	addiw	s1,s1,1
ffffffffc0201b94:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201b96:	ff2796e3          	bne	a5,s2,ffffffffc0201b82 <default_check+0x38>
ffffffffc0201b9a:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0201b9c:	7a9000ef          	jal	ra,ffffffffc0202b44 <nr_free_pages>
ffffffffc0201ba0:	75351963          	bne	a0,s3,ffffffffc02022f2 <default_check+0x7a8>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201ba4:	4505                	li	a0,1
ffffffffc0201ba6:	6d1000ef          	jal	ra,ffffffffc0202a76 <alloc_pages>
ffffffffc0201baa:	8a2a                	mv	s4,a0
ffffffffc0201bac:	48050363          	beqz	a0,ffffffffc0202032 <default_check+0x4e8>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201bb0:	4505                	li	a0,1
ffffffffc0201bb2:	6c5000ef          	jal	ra,ffffffffc0202a76 <alloc_pages>
ffffffffc0201bb6:	89aa                	mv	s3,a0
ffffffffc0201bb8:	74050d63          	beqz	a0,ffffffffc0202312 <default_check+0x7c8>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201bbc:	4505                	li	a0,1
ffffffffc0201bbe:	6b9000ef          	jal	ra,ffffffffc0202a76 <alloc_pages>
ffffffffc0201bc2:	8aaa                	mv	s5,a0
ffffffffc0201bc4:	4e050763          	beqz	a0,ffffffffc02020b2 <default_check+0x568>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0201bc8:	2f3a0563          	beq	s4,s3,ffffffffc0201eb2 <default_check+0x368>
ffffffffc0201bcc:	2eaa0363          	beq	s4,a0,ffffffffc0201eb2 <default_check+0x368>
ffffffffc0201bd0:	2ea98163          	beq	s3,a0,ffffffffc0201eb2 <default_check+0x368>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0201bd4:	000a2783          	lw	a5,0(s4)
ffffffffc0201bd8:	2e079d63          	bnez	a5,ffffffffc0201ed2 <default_check+0x388>
ffffffffc0201bdc:	0009a783          	lw	a5,0(s3)
ffffffffc0201be0:	2e079963          	bnez	a5,ffffffffc0201ed2 <default_check+0x388>
ffffffffc0201be4:	411c                	lw	a5,0(a0)
ffffffffc0201be6:	2e079663          	bnez	a5,ffffffffc0201ed2 <default_check+0x388>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201bea:	00010797          	auipc	a5,0x10
ffffffffc0201bee:	9ae78793          	addi	a5,a5,-1618 # ffffffffc0211598 <pages>
ffffffffc0201bf2:	639c                	ld	a5,0(a5)
ffffffffc0201bf4:	00004717          	auipc	a4,0x4
ffffffffc0201bf8:	82470713          	addi	a4,a4,-2012 # ffffffffc0205418 <commands+0xfa8>
ffffffffc0201bfc:	630c                	ld	a1,0(a4)
ffffffffc0201bfe:	40fa0733          	sub	a4,s4,a5
ffffffffc0201c02:	870d                	srai	a4,a4,0x3
ffffffffc0201c04:	02b70733          	mul	a4,a4,a1
ffffffffc0201c08:	00004697          	auipc	a3,0x4
ffffffffc0201c0c:	55868693          	addi	a3,a3,1368 # ffffffffc0206160 <nbase>
ffffffffc0201c10:	6290                	ld	a2,0(a3)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0201c12:	00010697          	auipc	a3,0x10
ffffffffc0201c16:	85e68693          	addi	a3,a3,-1954 # ffffffffc0211470 <npage>
ffffffffc0201c1a:	6294                	ld	a3,0(a3)
ffffffffc0201c1c:	06b2                	slli	a3,a3,0xc
ffffffffc0201c1e:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201c20:	0732                	slli	a4,a4,0xc
ffffffffc0201c22:	2cd77863          	bleu	a3,a4,ffffffffc0201ef2 <default_check+0x3a8>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201c26:	40f98733          	sub	a4,s3,a5
ffffffffc0201c2a:	870d                	srai	a4,a4,0x3
ffffffffc0201c2c:	02b70733          	mul	a4,a4,a1
ffffffffc0201c30:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201c32:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201c34:	4ed77f63          	bleu	a3,a4,ffffffffc0202132 <default_check+0x5e8>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201c38:	40f507b3          	sub	a5,a0,a5
ffffffffc0201c3c:	878d                	srai	a5,a5,0x3
ffffffffc0201c3e:	02b787b3          	mul	a5,a5,a1
ffffffffc0201c42:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201c44:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201c46:	34d7f663          	bleu	a3,a5,ffffffffc0201f92 <default_check+0x448>
    assert(alloc_page() == NULL);
ffffffffc0201c4a:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0201c4c:	00093c03          	ld	s8,0(s2)
ffffffffc0201c50:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0201c54:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0201c58:	00010797          	auipc	a5,0x10
ffffffffc0201c5c:	9127b823          	sd	s2,-1776(a5) # ffffffffc0211568 <free_area+0x8>
ffffffffc0201c60:	00010797          	auipc	a5,0x10
ffffffffc0201c64:	9127b023          	sd	s2,-1792(a5) # ffffffffc0211560 <free_area>
    nr_free = 0;
ffffffffc0201c68:	00010797          	auipc	a5,0x10
ffffffffc0201c6c:	9007a423          	sw	zero,-1784(a5) # ffffffffc0211570 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0201c70:	607000ef          	jal	ra,ffffffffc0202a76 <alloc_pages>
ffffffffc0201c74:	2e051f63          	bnez	a0,ffffffffc0201f72 <default_check+0x428>
    free_page(p0);
ffffffffc0201c78:	4585                	li	a1,1
ffffffffc0201c7a:	8552                	mv	a0,s4
ffffffffc0201c7c:	683000ef          	jal	ra,ffffffffc0202afe <free_pages>
    free_page(p1);
ffffffffc0201c80:	4585                	li	a1,1
ffffffffc0201c82:	854e                	mv	a0,s3
ffffffffc0201c84:	67b000ef          	jal	ra,ffffffffc0202afe <free_pages>
    free_page(p2);
ffffffffc0201c88:	4585                	li	a1,1
ffffffffc0201c8a:	8556                	mv	a0,s5
ffffffffc0201c8c:	673000ef          	jal	ra,ffffffffc0202afe <free_pages>
    assert(nr_free == 3);
ffffffffc0201c90:	01092703          	lw	a4,16(s2)
ffffffffc0201c94:	478d                	li	a5,3
ffffffffc0201c96:	2af71e63          	bne	a4,a5,ffffffffc0201f52 <default_check+0x408>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201c9a:	4505                	li	a0,1
ffffffffc0201c9c:	5db000ef          	jal	ra,ffffffffc0202a76 <alloc_pages>
ffffffffc0201ca0:	89aa                	mv	s3,a0
ffffffffc0201ca2:	28050863          	beqz	a0,ffffffffc0201f32 <default_check+0x3e8>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201ca6:	4505                	li	a0,1
ffffffffc0201ca8:	5cf000ef          	jal	ra,ffffffffc0202a76 <alloc_pages>
ffffffffc0201cac:	8aaa                	mv	s5,a0
ffffffffc0201cae:	3e050263          	beqz	a0,ffffffffc0202092 <default_check+0x548>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201cb2:	4505                	li	a0,1
ffffffffc0201cb4:	5c3000ef          	jal	ra,ffffffffc0202a76 <alloc_pages>
ffffffffc0201cb8:	8a2a                	mv	s4,a0
ffffffffc0201cba:	3a050c63          	beqz	a0,ffffffffc0202072 <default_check+0x528>
    assert(alloc_page() == NULL);
ffffffffc0201cbe:	4505                	li	a0,1
ffffffffc0201cc0:	5b7000ef          	jal	ra,ffffffffc0202a76 <alloc_pages>
ffffffffc0201cc4:	38051763          	bnez	a0,ffffffffc0202052 <default_check+0x508>
    free_page(p0);
ffffffffc0201cc8:	4585                	li	a1,1
ffffffffc0201cca:	854e                	mv	a0,s3
ffffffffc0201ccc:	633000ef          	jal	ra,ffffffffc0202afe <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0201cd0:	00893783          	ld	a5,8(s2)
ffffffffc0201cd4:	23278f63          	beq	a5,s2,ffffffffc0201f12 <default_check+0x3c8>
    assert((p = alloc_page()) == p0);
ffffffffc0201cd8:	4505                	li	a0,1
ffffffffc0201cda:	59d000ef          	jal	ra,ffffffffc0202a76 <alloc_pages>
ffffffffc0201cde:	32a99a63          	bne	s3,a0,ffffffffc0202012 <default_check+0x4c8>
    assert(alloc_page() == NULL);
ffffffffc0201ce2:	4505                	li	a0,1
ffffffffc0201ce4:	593000ef          	jal	ra,ffffffffc0202a76 <alloc_pages>
ffffffffc0201ce8:	30051563          	bnez	a0,ffffffffc0201ff2 <default_check+0x4a8>
    assert(nr_free == 0);
ffffffffc0201cec:	01092783          	lw	a5,16(s2)
ffffffffc0201cf0:	2e079163          	bnez	a5,ffffffffc0201fd2 <default_check+0x488>
    free_page(p);
ffffffffc0201cf4:	854e                	mv	a0,s3
ffffffffc0201cf6:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0201cf8:	00010797          	auipc	a5,0x10
ffffffffc0201cfc:	8787b423          	sd	s8,-1944(a5) # ffffffffc0211560 <free_area>
ffffffffc0201d00:	00010797          	auipc	a5,0x10
ffffffffc0201d04:	8777b423          	sd	s7,-1944(a5) # ffffffffc0211568 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0201d08:	00010797          	auipc	a5,0x10
ffffffffc0201d0c:	8767a423          	sw	s6,-1944(a5) # ffffffffc0211570 <free_area+0x10>
    free_page(p);
ffffffffc0201d10:	5ef000ef          	jal	ra,ffffffffc0202afe <free_pages>
    free_page(p1);
ffffffffc0201d14:	4585                	li	a1,1
ffffffffc0201d16:	8556                	mv	a0,s5
ffffffffc0201d18:	5e7000ef          	jal	ra,ffffffffc0202afe <free_pages>
    free_page(p2);
ffffffffc0201d1c:	4585                	li	a1,1
ffffffffc0201d1e:	8552                	mv	a0,s4
ffffffffc0201d20:	5df000ef          	jal	ra,ffffffffc0202afe <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0201d24:	4515                	li	a0,5
ffffffffc0201d26:	551000ef          	jal	ra,ffffffffc0202a76 <alloc_pages>
ffffffffc0201d2a:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0201d2c:	28050363          	beqz	a0,ffffffffc0201fb2 <default_check+0x468>
ffffffffc0201d30:	651c                	ld	a5,8(a0)
ffffffffc0201d32:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0201d34:	8b85                	andi	a5,a5,1
ffffffffc0201d36:	54079e63          	bnez	a5,ffffffffc0202292 <default_check+0x748>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0201d3a:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0201d3c:	00093b03          	ld	s6,0(s2)
ffffffffc0201d40:	00893a83          	ld	s5,8(s2)
ffffffffc0201d44:	00010797          	auipc	a5,0x10
ffffffffc0201d48:	8127be23          	sd	s2,-2020(a5) # ffffffffc0211560 <free_area>
ffffffffc0201d4c:	00010797          	auipc	a5,0x10
ffffffffc0201d50:	8127be23          	sd	s2,-2020(a5) # ffffffffc0211568 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0201d54:	523000ef          	jal	ra,ffffffffc0202a76 <alloc_pages>
ffffffffc0201d58:	50051d63          	bnez	a0,ffffffffc0202272 <default_check+0x728>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0201d5c:	09098a13          	addi	s4,s3,144
ffffffffc0201d60:	8552                	mv	a0,s4
ffffffffc0201d62:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0201d64:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc0201d68:	00010797          	auipc	a5,0x10
ffffffffc0201d6c:	8007a423          	sw	zero,-2040(a5) # ffffffffc0211570 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0201d70:	58f000ef          	jal	ra,ffffffffc0202afe <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0201d74:	4511                	li	a0,4
ffffffffc0201d76:	501000ef          	jal	ra,ffffffffc0202a76 <alloc_pages>
ffffffffc0201d7a:	4c051c63          	bnez	a0,ffffffffc0202252 <default_check+0x708>
ffffffffc0201d7e:	0989b783          	ld	a5,152(s3)
ffffffffc0201d82:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201d84:	8b85                	andi	a5,a5,1
ffffffffc0201d86:	4a078663          	beqz	a5,ffffffffc0202232 <default_check+0x6e8>
ffffffffc0201d8a:	0a89a703          	lw	a4,168(s3)
ffffffffc0201d8e:	478d                	li	a5,3
ffffffffc0201d90:	4af71163          	bne	a4,a5,ffffffffc0202232 <default_check+0x6e8>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201d94:	450d                	li	a0,3
ffffffffc0201d96:	4e1000ef          	jal	ra,ffffffffc0202a76 <alloc_pages>
ffffffffc0201d9a:	8c2a                	mv	s8,a0
ffffffffc0201d9c:	46050b63          	beqz	a0,ffffffffc0202212 <default_check+0x6c8>
    assert(alloc_page() == NULL);
ffffffffc0201da0:	4505                	li	a0,1
ffffffffc0201da2:	4d5000ef          	jal	ra,ffffffffc0202a76 <alloc_pages>
ffffffffc0201da6:	44051663          	bnez	a0,ffffffffc02021f2 <default_check+0x6a8>
    assert(p0 + 2 == p1);
ffffffffc0201daa:	438a1463          	bne	s4,s8,ffffffffc02021d2 <default_check+0x688>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0201dae:	4585                	li	a1,1
ffffffffc0201db0:	854e                	mv	a0,s3
ffffffffc0201db2:	54d000ef          	jal	ra,ffffffffc0202afe <free_pages>
    free_pages(p1, 3);
ffffffffc0201db6:	458d                	li	a1,3
ffffffffc0201db8:	8552                	mv	a0,s4
ffffffffc0201dba:	545000ef          	jal	ra,ffffffffc0202afe <free_pages>
ffffffffc0201dbe:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0201dc2:	04898c13          	addi	s8,s3,72
ffffffffc0201dc6:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201dc8:	8b85                	andi	a5,a5,1
ffffffffc0201dca:	3e078463          	beqz	a5,ffffffffc02021b2 <default_check+0x668>
ffffffffc0201dce:	0189a703          	lw	a4,24(s3)
ffffffffc0201dd2:	4785                	li	a5,1
ffffffffc0201dd4:	3cf71f63          	bne	a4,a5,ffffffffc02021b2 <default_check+0x668>
ffffffffc0201dd8:	008a3783          	ld	a5,8(s4)
ffffffffc0201ddc:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201dde:	8b85                	andi	a5,a5,1
ffffffffc0201de0:	3a078963          	beqz	a5,ffffffffc0202192 <default_check+0x648>
ffffffffc0201de4:	018a2703          	lw	a4,24(s4)
ffffffffc0201de8:	478d                	li	a5,3
ffffffffc0201dea:	3af71463          	bne	a4,a5,ffffffffc0202192 <default_check+0x648>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201dee:	4505                	li	a0,1
ffffffffc0201df0:	487000ef          	jal	ra,ffffffffc0202a76 <alloc_pages>
ffffffffc0201df4:	36a99f63          	bne	s3,a0,ffffffffc0202172 <default_check+0x628>
    free_page(p0);
ffffffffc0201df8:	4585                	li	a1,1
ffffffffc0201dfa:	505000ef          	jal	ra,ffffffffc0202afe <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201dfe:	4509                	li	a0,2
ffffffffc0201e00:	477000ef          	jal	ra,ffffffffc0202a76 <alloc_pages>
ffffffffc0201e04:	34aa1763          	bne	s4,a0,ffffffffc0202152 <default_check+0x608>

    free_pages(p0, 2);
ffffffffc0201e08:	4589                	li	a1,2
ffffffffc0201e0a:	4f5000ef          	jal	ra,ffffffffc0202afe <free_pages>
    free_page(p2);
ffffffffc0201e0e:	4585                	li	a1,1
ffffffffc0201e10:	8562                	mv	a0,s8
ffffffffc0201e12:	4ed000ef          	jal	ra,ffffffffc0202afe <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201e16:	4515                	li	a0,5
ffffffffc0201e18:	45f000ef          	jal	ra,ffffffffc0202a76 <alloc_pages>
ffffffffc0201e1c:	89aa                	mv	s3,a0
ffffffffc0201e1e:	48050a63          	beqz	a0,ffffffffc02022b2 <default_check+0x768>
    assert(alloc_page() == NULL);
ffffffffc0201e22:	4505                	li	a0,1
ffffffffc0201e24:	453000ef          	jal	ra,ffffffffc0202a76 <alloc_pages>
ffffffffc0201e28:	2e051563          	bnez	a0,ffffffffc0202112 <default_check+0x5c8>

    assert(nr_free == 0);
ffffffffc0201e2c:	01092783          	lw	a5,16(s2)
ffffffffc0201e30:	2c079163          	bnez	a5,ffffffffc02020f2 <default_check+0x5a8>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0201e34:	4595                	li	a1,5
ffffffffc0201e36:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0201e38:	0000f797          	auipc	a5,0xf
ffffffffc0201e3c:	7377ac23          	sw	s7,1848(a5) # ffffffffc0211570 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0201e40:	0000f797          	auipc	a5,0xf
ffffffffc0201e44:	7367b023          	sd	s6,1824(a5) # ffffffffc0211560 <free_area>
ffffffffc0201e48:	0000f797          	auipc	a5,0xf
ffffffffc0201e4c:	7357b023          	sd	s5,1824(a5) # ffffffffc0211568 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0201e50:	4af000ef          	jal	ra,ffffffffc0202afe <free_pages>
    return listelm->next;
ffffffffc0201e54:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201e58:	01278963          	beq	a5,s2,ffffffffc0201e6a <default_check+0x320>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0201e5c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201e60:	679c                	ld	a5,8(a5)
ffffffffc0201e62:	34fd                	addiw	s1,s1,-1
ffffffffc0201e64:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201e66:	ff279be3          	bne	a5,s2,ffffffffc0201e5c <default_check+0x312>
    }
    assert(count == 0);
ffffffffc0201e6a:	26049463          	bnez	s1,ffffffffc02020d2 <default_check+0x588>
    assert(total == 0);
ffffffffc0201e6e:	46041263          	bnez	s0,ffffffffc02022d2 <default_check+0x788>
}
ffffffffc0201e72:	60a6                	ld	ra,72(sp)
ffffffffc0201e74:	6406                	ld	s0,64(sp)
ffffffffc0201e76:	74e2                	ld	s1,56(sp)
ffffffffc0201e78:	7942                	ld	s2,48(sp)
ffffffffc0201e7a:	79a2                	ld	s3,40(sp)
ffffffffc0201e7c:	7a02                	ld	s4,32(sp)
ffffffffc0201e7e:	6ae2                	ld	s5,24(sp)
ffffffffc0201e80:	6b42                	ld	s6,16(sp)
ffffffffc0201e82:	6ba2                	ld	s7,8(sp)
ffffffffc0201e84:	6c02                	ld	s8,0(sp)
ffffffffc0201e86:	6161                	addi	sp,sp,80
ffffffffc0201e88:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201e8a:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0201e8c:	4401                	li	s0,0
ffffffffc0201e8e:	4481                	li	s1,0
ffffffffc0201e90:	b331                	j	ffffffffc0201b9c <default_check+0x52>
        assert(PageProperty(p));
ffffffffc0201e92:	00003697          	auipc	a3,0x3
ffffffffc0201e96:	24e68693          	addi	a3,a3,590 # ffffffffc02050e0 <commands+0xc70>
ffffffffc0201e9a:	00003617          	auipc	a2,0x3
ffffffffc0201e9e:	e2e60613          	addi	a2,a2,-466 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0201ea2:	0f000593          	li	a1,240
ffffffffc0201ea6:	00003517          	auipc	a0,0x3
ffffffffc0201eaa:	57a50513          	addi	a0,a0,1402 # ffffffffc0205420 <commands+0xfb0>
ffffffffc0201eae:	a58fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0201eb2:	00003697          	auipc	a3,0x3
ffffffffc0201eb6:	5e668693          	addi	a3,a3,1510 # ffffffffc0205498 <commands+0x1028>
ffffffffc0201eba:	00003617          	auipc	a2,0x3
ffffffffc0201ebe:	e0e60613          	addi	a2,a2,-498 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0201ec2:	0bd00593          	li	a1,189
ffffffffc0201ec6:	00003517          	auipc	a0,0x3
ffffffffc0201eca:	55a50513          	addi	a0,a0,1370 # ffffffffc0205420 <commands+0xfb0>
ffffffffc0201ece:	a38fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0201ed2:	00003697          	auipc	a3,0x3
ffffffffc0201ed6:	5ee68693          	addi	a3,a3,1518 # ffffffffc02054c0 <commands+0x1050>
ffffffffc0201eda:	00003617          	auipc	a2,0x3
ffffffffc0201ede:	dee60613          	addi	a2,a2,-530 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0201ee2:	0be00593          	li	a1,190
ffffffffc0201ee6:	00003517          	auipc	a0,0x3
ffffffffc0201eea:	53a50513          	addi	a0,a0,1338 # ffffffffc0205420 <commands+0xfb0>
ffffffffc0201eee:	a18fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0201ef2:	00003697          	auipc	a3,0x3
ffffffffc0201ef6:	60e68693          	addi	a3,a3,1550 # ffffffffc0205500 <commands+0x1090>
ffffffffc0201efa:	00003617          	auipc	a2,0x3
ffffffffc0201efe:	dce60613          	addi	a2,a2,-562 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0201f02:	0c000593          	li	a1,192
ffffffffc0201f06:	00003517          	auipc	a0,0x3
ffffffffc0201f0a:	51a50513          	addi	a0,a0,1306 # ffffffffc0205420 <commands+0xfb0>
ffffffffc0201f0e:	9f8fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0201f12:	00003697          	auipc	a3,0x3
ffffffffc0201f16:	67668693          	addi	a3,a3,1654 # ffffffffc0205588 <commands+0x1118>
ffffffffc0201f1a:	00003617          	auipc	a2,0x3
ffffffffc0201f1e:	dae60613          	addi	a2,a2,-594 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0201f22:	0d900593          	li	a1,217
ffffffffc0201f26:	00003517          	auipc	a0,0x3
ffffffffc0201f2a:	4fa50513          	addi	a0,a0,1274 # ffffffffc0205420 <commands+0xfb0>
ffffffffc0201f2e:	9d8fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201f32:	00003697          	auipc	a3,0x3
ffffffffc0201f36:	50668693          	addi	a3,a3,1286 # ffffffffc0205438 <commands+0xfc8>
ffffffffc0201f3a:	00003617          	auipc	a2,0x3
ffffffffc0201f3e:	d8e60613          	addi	a2,a2,-626 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0201f42:	0d200593          	li	a1,210
ffffffffc0201f46:	00003517          	auipc	a0,0x3
ffffffffc0201f4a:	4da50513          	addi	a0,a0,1242 # ffffffffc0205420 <commands+0xfb0>
ffffffffc0201f4e:	9b8fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(nr_free == 3);
ffffffffc0201f52:	00003697          	auipc	a3,0x3
ffffffffc0201f56:	62668693          	addi	a3,a3,1574 # ffffffffc0205578 <commands+0x1108>
ffffffffc0201f5a:	00003617          	auipc	a2,0x3
ffffffffc0201f5e:	d6e60613          	addi	a2,a2,-658 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0201f62:	0d000593          	li	a1,208
ffffffffc0201f66:	00003517          	auipc	a0,0x3
ffffffffc0201f6a:	4ba50513          	addi	a0,a0,1210 # ffffffffc0205420 <commands+0xfb0>
ffffffffc0201f6e:	998fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201f72:	00003697          	auipc	a3,0x3
ffffffffc0201f76:	5ee68693          	addi	a3,a3,1518 # ffffffffc0205560 <commands+0x10f0>
ffffffffc0201f7a:	00003617          	auipc	a2,0x3
ffffffffc0201f7e:	d4e60613          	addi	a2,a2,-690 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0201f82:	0cb00593          	li	a1,203
ffffffffc0201f86:	00003517          	auipc	a0,0x3
ffffffffc0201f8a:	49a50513          	addi	a0,a0,1178 # ffffffffc0205420 <commands+0xfb0>
ffffffffc0201f8e:	978fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201f92:	00003697          	auipc	a3,0x3
ffffffffc0201f96:	5ae68693          	addi	a3,a3,1454 # ffffffffc0205540 <commands+0x10d0>
ffffffffc0201f9a:	00003617          	auipc	a2,0x3
ffffffffc0201f9e:	d2e60613          	addi	a2,a2,-722 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0201fa2:	0c200593          	li	a1,194
ffffffffc0201fa6:	00003517          	auipc	a0,0x3
ffffffffc0201faa:	47a50513          	addi	a0,a0,1146 # ffffffffc0205420 <commands+0xfb0>
ffffffffc0201fae:	958fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(p0 != NULL);
ffffffffc0201fb2:	00003697          	auipc	a3,0x3
ffffffffc0201fb6:	60e68693          	addi	a3,a3,1550 # ffffffffc02055c0 <commands+0x1150>
ffffffffc0201fba:	00003617          	auipc	a2,0x3
ffffffffc0201fbe:	d0e60613          	addi	a2,a2,-754 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0201fc2:	0f800593          	li	a1,248
ffffffffc0201fc6:	00003517          	auipc	a0,0x3
ffffffffc0201fca:	45a50513          	addi	a0,a0,1114 # ffffffffc0205420 <commands+0xfb0>
ffffffffc0201fce:	938fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(nr_free == 0);
ffffffffc0201fd2:	00003697          	auipc	a3,0x3
ffffffffc0201fd6:	2be68693          	addi	a3,a3,702 # ffffffffc0205290 <commands+0xe20>
ffffffffc0201fda:	00003617          	auipc	a2,0x3
ffffffffc0201fde:	cee60613          	addi	a2,a2,-786 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0201fe2:	0df00593          	li	a1,223
ffffffffc0201fe6:	00003517          	auipc	a0,0x3
ffffffffc0201fea:	43a50513          	addi	a0,a0,1082 # ffffffffc0205420 <commands+0xfb0>
ffffffffc0201fee:	918fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201ff2:	00003697          	auipc	a3,0x3
ffffffffc0201ff6:	56e68693          	addi	a3,a3,1390 # ffffffffc0205560 <commands+0x10f0>
ffffffffc0201ffa:	00003617          	auipc	a2,0x3
ffffffffc0201ffe:	cce60613          	addi	a2,a2,-818 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0202002:	0dd00593          	li	a1,221
ffffffffc0202006:	00003517          	auipc	a0,0x3
ffffffffc020200a:	41a50513          	addi	a0,a0,1050 # ffffffffc0205420 <commands+0xfb0>
ffffffffc020200e:	8f8fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0202012:	00003697          	auipc	a3,0x3
ffffffffc0202016:	58e68693          	addi	a3,a3,1422 # ffffffffc02055a0 <commands+0x1130>
ffffffffc020201a:	00003617          	auipc	a2,0x3
ffffffffc020201e:	cae60613          	addi	a2,a2,-850 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0202022:	0dc00593          	li	a1,220
ffffffffc0202026:	00003517          	auipc	a0,0x3
ffffffffc020202a:	3fa50513          	addi	a0,a0,1018 # ffffffffc0205420 <commands+0xfb0>
ffffffffc020202e:	8d8fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202032:	00003697          	auipc	a3,0x3
ffffffffc0202036:	40668693          	addi	a3,a3,1030 # ffffffffc0205438 <commands+0xfc8>
ffffffffc020203a:	00003617          	auipc	a2,0x3
ffffffffc020203e:	c8e60613          	addi	a2,a2,-882 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0202042:	0b900593          	li	a1,185
ffffffffc0202046:	00003517          	auipc	a0,0x3
ffffffffc020204a:	3da50513          	addi	a0,a0,986 # ffffffffc0205420 <commands+0xfb0>
ffffffffc020204e:	8b8fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202052:	00003697          	auipc	a3,0x3
ffffffffc0202056:	50e68693          	addi	a3,a3,1294 # ffffffffc0205560 <commands+0x10f0>
ffffffffc020205a:	00003617          	auipc	a2,0x3
ffffffffc020205e:	c6e60613          	addi	a2,a2,-914 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0202062:	0d600593          	li	a1,214
ffffffffc0202066:	00003517          	auipc	a0,0x3
ffffffffc020206a:	3ba50513          	addi	a0,a0,954 # ffffffffc0205420 <commands+0xfb0>
ffffffffc020206e:	898fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202072:	00003697          	auipc	a3,0x3
ffffffffc0202076:	40668693          	addi	a3,a3,1030 # ffffffffc0205478 <commands+0x1008>
ffffffffc020207a:	00003617          	auipc	a2,0x3
ffffffffc020207e:	c4e60613          	addi	a2,a2,-946 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0202082:	0d400593          	li	a1,212
ffffffffc0202086:	00003517          	auipc	a0,0x3
ffffffffc020208a:	39a50513          	addi	a0,a0,922 # ffffffffc0205420 <commands+0xfb0>
ffffffffc020208e:	878fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202092:	00003697          	auipc	a3,0x3
ffffffffc0202096:	3c668693          	addi	a3,a3,966 # ffffffffc0205458 <commands+0xfe8>
ffffffffc020209a:	00003617          	auipc	a2,0x3
ffffffffc020209e:	c2e60613          	addi	a2,a2,-978 # ffffffffc0204cc8 <commands+0x858>
ffffffffc02020a2:	0d300593          	li	a1,211
ffffffffc02020a6:	00003517          	auipc	a0,0x3
ffffffffc02020aa:	37a50513          	addi	a0,a0,890 # ffffffffc0205420 <commands+0xfb0>
ffffffffc02020ae:	858fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02020b2:	00003697          	auipc	a3,0x3
ffffffffc02020b6:	3c668693          	addi	a3,a3,966 # ffffffffc0205478 <commands+0x1008>
ffffffffc02020ba:	00003617          	auipc	a2,0x3
ffffffffc02020be:	c0e60613          	addi	a2,a2,-1010 # ffffffffc0204cc8 <commands+0x858>
ffffffffc02020c2:	0bb00593          	li	a1,187
ffffffffc02020c6:	00003517          	auipc	a0,0x3
ffffffffc02020ca:	35a50513          	addi	a0,a0,858 # ffffffffc0205420 <commands+0xfb0>
ffffffffc02020ce:	838fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(count == 0);
ffffffffc02020d2:	00003697          	auipc	a3,0x3
ffffffffc02020d6:	63e68693          	addi	a3,a3,1598 # ffffffffc0205710 <commands+0x12a0>
ffffffffc02020da:	00003617          	auipc	a2,0x3
ffffffffc02020de:	bee60613          	addi	a2,a2,-1042 # ffffffffc0204cc8 <commands+0x858>
ffffffffc02020e2:	12500593          	li	a1,293
ffffffffc02020e6:	00003517          	auipc	a0,0x3
ffffffffc02020ea:	33a50513          	addi	a0,a0,826 # ffffffffc0205420 <commands+0xfb0>
ffffffffc02020ee:	818fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(nr_free == 0);
ffffffffc02020f2:	00003697          	auipc	a3,0x3
ffffffffc02020f6:	19e68693          	addi	a3,a3,414 # ffffffffc0205290 <commands+0xe20>
ffffffffc02020fa:	00003617          	auipc	a2,0x3
ffffffffc02020fe:	bce60613          	addi	a2,a2,-1074 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0202102:	11a00593          	li	a1,282
ffffffffc0202106:	00003517          	auipc	a0,0x3
ffffffffc020210a:	31a50513          	addi	a0,a0,794 # ffffffffc0205420 <commands+0xfb0>
ffffffffc020210e:	ff9fd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202112:	00003697          	auipc	a3,0x3
ffffffffc0202116:	44e68693          	addi	a3,a3,1102 # ffffffffc0205560 <commands+0x10f0>
ffffffffc020211a:	00003617          	auipc	a2,0x3
ffffffffc020211e:	bae60613          	addi	a2,a2,-1106 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0202122:	11800593          	li	a1,280
ffffffffc0202126:	00003517          	auipc	a0,0x3
ffffffffc020212a:	2fa50513          	addi	a0,a0,762 # ffffffffc0205420 <commands+0xfb0>
ffffffffc020212e:	fd9fd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0202132:	00003697          	auipc	a3,0x3
ffffffffc0202136:	3ee68693          	addi	a3,a3,1006 # ffffffffc0205520 <commands+0x10b0>
ffffffffc020213a:	00003617          	auipc	a2,0x3
ffffffffc020213e:	b8e60613          	addi	a2,a2,-1138 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0202142:	0c100593          	li	a1,193
ffffffffc0202146:	00003517          	auipc	a0,0x3
ffffffffc020214a:	2da50513          	addi	a0,a0,730 # ffffffffc0205420 <commands+0xfb0>
ffffffffc020214e:	fb9fd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0202152:	00003697          	auipc	a3,0x3
ffffffffc0202156:	57e68693          	addi	a3,a3,1406 # ffffffffc02056d0 <commands+0x1260>
ffffffffc020215a:	00003617          	auipc	a2,0x3
ffffffffc020215e:	b6e60613          	addi	a2,a2,-1170 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0202162:	11200593          	li	a1,274
ffffffffc0202166:	00003517          	auipc	a0,0x3
ffffffffc020216a:	2ba50513          	addi	a0,a0,698 # ffffffffc0205420 <commands+0xfb0>
ffffffffc020216e:	f99fd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0202172:	00003697          	auipc	a3,0x3
ffffffffc0202176:	53e68693          	addi	a3,a3,1342 # ffffffffc02056b0 <commands+0x1240>
ffffffffc020217a:	00003617          	auipc	a2,0x3
ffffffffc020217e:	b4e60613          	addi	a2,a2,-1202 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0202182:	11000593          	li	a1,272
ffffffffc0202186:	00003517          	auipc	a0,0x3
ffffffffc020218a:	29a50513          	addi	a0,a0,666 # ffffffffc0205420 <commands+0xfb0>
ffffffffc020218e:	f79fd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0202192:	00003697          	auipc	a3,0x3
ffffffffc0202196:	4f668693          	addi	a3,a3,1270 # ffffffffc0205688 <commands+0x1218>
ffffffffc020219a:	00003617          	auipc	a2,0x3
ffffffffc020219e:	b2e60613          	addi	a2,a2,-1234 # ffffffffc0204cc8 <commands+0x858>
ffffffffc02021a2:	10e00593          	li	a1,270
ffffffffc02021a6:	00003517          	auipc	a0,0x3
ffffffffc02021aa:	27a50513          	addi	a0,a0,634 # ffffffffc0205420 <commands+0xfb0>
ffffffffc02021ae:	f59fd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02021b2:	00003697          	auipc	a3,0x3
ffffffffc02021b6:	4ae68693          	addi	a3,a3,1198 # ffffffffc0205660 <commands+0x11f0>
ffffffffc02021ba:	00003617          	auipc	a2,0x3
ffffffffc02021be:	b0e60613          	addi	a2,a2,-1266 # ffffffffc0204cc8 <commands+0x858>
ffffffffc02021c2:	10d00593          	li	a1,269
ffffffffc02021c6:	00003517          	auipc	a0,0x3
ffffffffc02021ca:	25a50513          	addi	a0,a0,602 # ffffffffc0205420 <commands+0xfb0>
ffffffffc02021ce:	f39fd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(p0 + 2 == p1);
ffffffffc02021d2:	00003697          	auipc	a3,0x3
ffffffffc02021d6:	47e68693          	addi	a3,a3,1150 # ffffffffc0205650 <commands+0x11e0>
ffffffffc02021da:	00003617          	auipc	a2,0x3
ffffffffc02021de:	aee60613          	addi	a2,a2,-1298 # ffffffffc0204cc8 <commands+0x858>
ffffffffc02021e2:	10800593          	li	a1,264
ffffffffc02021e6:	00003517          	auipc	a0,0x3
ffffffffc02021ea:	23a50513          	addi	a0,a0,570 # ffffffffc0205420 <commands+0xfb0>
ffffffffc02021ee:	f19fd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02021f2:	00003697          	auipc	a3,0x3
ffffffffc02021f6:	36e68693          	addi	a3,a3,878 # ffffffffc0205560 <commands+0x10f0>
ffffffffc02021fa:	00003617          	auipc	a2,0x3
ffffffffc02021fe:	ace60613          	addi	a2,a2,-1330 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0202202:	10700593          	li	a1,263
ffffffffc0202206:	00003517          	auipc	a0,0x3
ffffffffc020220a:	21a50513          	addi	a0,a0,538 # ffffffffc0205420 <commands+0xfb0>
ffffffffc020220e:	ef9fd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0202212:	00003697          	auipc	a3,0x3
ffffffffc0202216:	41e68693          	addi	a3,a3,1054 # ffffffffc0205630 <commands+0x11c0>
ffffffffc020221a:	00003617          	auipc	a2,0x3
ffffffffc020221e:	aae60613          	addi	a2,a2,-1362 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0202222:	10600593          	li	a1,262
ffffffffc0202226:	00003517          	auipc	a0,0x3
ffffffffc020222a:	1fa50513          	addi	a0,a0,506 # ffffffffc0205420 <commands+0xfb0>
ffffffffc020222e:	ed9fd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0202232:	00003697          	auipc	a3,0x3
ffffffffc0202236:	3ce68693          	addi	a3,a3,974 # ffffffffc0205600 <commands+0x1190>
ffffffffc020223a:	00003617          	auipc	a2,0x3
ffffffffc020223e:	a8e60613          	addi	a2,a2,-1394 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0202242:	10500593          	li	a1,261
ffffffffc0202246:	00003517          	auipc	a0,0x3
ffffffffc020224a:	1da50513          	addi	a0,a0,474 # ffffffffc0205420 <commands+0xfb0>
ffffffffc020224e:	eb9fd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0202252:	00003697          	auipc	a3,0x3
ffffffffc0202256:	39668693          	addi	a3,a3,918 # ffffffffc02055e8 <commands+0x1178>
ffffffffc020225a:	00003617          	auipc	a2,0x3
ffffffffc020225e:	a6e60613          	addi	a2,a2,-1426 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0202262:	10400593          	li	a1,260
ffffffffc0202266:	00003517          	auipc	a0,0x3
ffffffffc020226a:	1ba50513          	addi	a0,a0,442 # ffffffffc0205420 <commands+0xfb0>
ffffffffc020226e:	e99fd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202272:	00003697          	auipc	a3,0x3
ffffffffc0202276:	2ee68693          	addi	a3,a3,750 # ffffffffc0205560 <commands+0x10f0>
ffffffffc020227a:	00003617          	auipc	a2,0x3
ffffffffc020227e:	a4e60613          	addi	a2,a2,-1458 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0202282:	0fe00593          	li	a1,254
ffffffffc0202286:	00003517          	auipc	a0,0x3
ffffffffc020228a:	19a50513          	addi	a0,a0,410 # ffffffffc0205420 <commands+0xfb0>
ffffffffc020228e:	e79fd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(!PageProperty(p0));
ffffffffc0202292:	00003697          	auipc	a3,0x3
ffffffffc0202296:	33e68693          	addi	a3,a3,830 # ffffffffc02055d0 <commands+0x1160>
ffffffffc020229a:	00003617          	auipc	a2,0x3
ffffffffc020229e:	a2e60613          	addi	a2,a2,-1490 # ffffffffc0204cc8 <commands+0x858>
ffffffffc02022a2:	0f900593          	li	a1,249
ffffffffc02022a6:	00003517          	auipc	a0,0x3
ffffffffc02022aa:	17a50513          	addi	a0,a0,378 # ffffffffc0205420 <commands+0xfb0>
ffffffffc02022ae:	e59fd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02022b2:	00003697          	auipc	a3,0x3
ffffffffc02022b6:	43e68693          	addi	a3,a3,1086 # ffffffffc02056f0 <commands+0x1280>
ffffffffc02022ba:	00003617          	auipc	a2,0x3
ffffffffc02022be:	a0e60613          	addi	a2,a2,-1522 # ffffffffc0204cc8 <commands+0x858>
ffffffffc02022c2:	11700593          	li	a1,279
ffffffffc02022c6:	00003517          	auipc	a0,0x3
ffffffffc02022ca:	15a50513          	addi	a0,a0,346 # ffffffffc0205420 <commands+0xfb0>
ffffffffc02022ce:	e39fd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(total == 0);
ffffffffc02022d2:	00003697          	auipc	a3,0x3
ffffffffc02022d6:	44e68693          	addi	a3,a3,1102 # ffffffffc0205720 <commands+0x12b0>
ffffffffc02022da:	00003617          	auipc	a2,0x3
ffffffffc02022de:	9ee60613          	addi	a2,a2,-1554 # ffffffffc0204cc8 <commands+0x858>
ffffffffc02022e2:	12600593          	li	a1,294
ffffffffc02022e6:	00003517          	auipc	a0,0x3
ffffffffc02022ea:	13a50513          	addi	a0,a0,314 # ffffffffc0205420 <commands+0xfb0>
ffffffffc02022ee:	e19fd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(total == nr_free_pages());
ffffffffc02022f2:	00003697          	auipc	a3,0x3
ffffffffc02022f6:	dfe68693          	addi	a3,a3,-514 # ffffffffc02050f0 <commands+0xc80>
ffffffffc02022fa:	00003617          	auipc	a2,0x3
ffffffffc02022fe:	9ce60613          	addi	a2,a2,-1586 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0202302:	0f300593          	li	a1,243
ffffffffc0202306:	00003517          	auipc	a0,0x3
ffffffffc020230a:	11a50513          	addi	a0,a0,282 # ffffffffc0205420 <commands+0xfb0>
ffffffffc020230e:	df9fd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202312:	00003697          	auipc	a3,0x3
ffffffffc0202316:	14668693          	addi	a3,a3,326 # ffffffffc0205458 <commands+0xfe8>
ffffffffc020231a:	00003617          	auipc	a2,0x3
ffffffffc020231e:	9ae60613          	addi	a2,a2,-1618 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0202322:	0ba00593          	li	a1,186
ffffffffc0202326:	00003517          	auipc	a0,0x3
ffffffffc020232a:	0fa50513          	addi	a0,a0,250 # ffffffffc0205420 <commands+0xfb0>
ffffffffc020232e:	dd9fd0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0202332 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0202332:	1141                	addi	sp,sp,-16
ffffffffc0202334:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0202336:	18058063          	beqz	a1,ffffffffc02024b6 <default_free_pages+0x184>
    for (; p != base + n; p ++) {
ffffffffc020233a:	00359693          	slli	a3,a1,0x3
ffffffffc020233e:	96ae                	add	a3,a3,a1
ffffffffc0202340:	068e                	slli	a3,a3,0x3
ffffffffc0202342:	96aa                	add	a3,a3,a0
ffffffffc0202344:	02d50d63          	beq	a0,a3,ffffffffc020237e <default_free_pages+0x4c>
ffffffffc0202348:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020234a:	8b85                	andi	a5,a5,1
ffffffffc020234c:	14079563          	bnez	a5,ffffffffc0202496 <default_free_pages+0x164>
ffffffffc0202350:	651c                	ld	a5,8(a0)
ffffffffc0202352:	8385                	srli	a5,a5,0x1
ffffffffc0202354:	8b85                	andi	a5,a5,1
ffffffffc0202356:	14079063          	bnez	a5,ffffffffc0202496 <default_free_pages+0x164>
ffffffffc020235a:	87aa                	mv	a5,a0
ffffffffc020235c:	a809                	j	ffffffffc020236e <default_free_pages+0x3c>
ffffffffc020235e:	6798                	ld	a4,8(a5)
ffffffffc0202360:	8b05                	andi	a4,a4,1
ffffffffc0202362:	12071a63          	bnez	a4,ffffffffc0202496 <default_free_pages+0x164>
ffffffffc0202366:	6798                	ld	a4,8(a5)
ffffffffc0202368:	8b09                	andi	a4,a4,2
ffffffffc020236a:	12071663          	bnez	a4,ffffffffc0202496 <default_free_pages+0x164>
        p->flags = 0;
ffffffffc020236e:	0007b423          	sd	zero,8(a5)
}

static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0202372:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0202376:	04878793          	addi	a5,a5,72
ffffffffc020237a:	fed792e3          	bne	a5,a3,ffffffffc020235e <default_free_pages+0x2c>
    base->property = n;
ffffffffc020237e:	2581                	sext.w	a1,a1
ffffffffc0202380:	cd0c                	sw	a1,24(a0)
    SetPageProperty(base);
ffffffffc0202382:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0202386:	4789                	li	a5,2
ffffffffc0202388:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc020238c:	0000f697          	auipc	a3,0xf
ffffffffc0202390:	1d468693          	addi	a3,a3,468 # ffffffffc0211560 <free_area>
ffffffffc0202394:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0202396:	669c                	ld	a5,8(a3)
ffffffffc0202398:	9db9                	addw	a1,a1,a4
ffffffffc020239a:	0000f717          	auipc	a4,0xf
ffffffffc020239e:	1cb72b23          	sw	a1,470(a4) # ffffffffc0211570 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc02023a2:	08d78f63          	beq	a5,a3,ffffffffc0202440 <default_free_pages+0x10e>
            struct Page* page = le2page(le, page_link);
ffffffffc02023a6:	fe078713          	addi	a4,a5,-32
ffffffffc02023aa:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02023ac:	4801                	li	a6,0
ffffffffc02023ae:	02050613          	addi	a2,a0,32
            if (base < page) {
ffffffffc02023b2:	00e56a63          	bltu	a0,a4,ffffffffc02023c6 <default_free_pages+0x94>
    return listelm->next;
ffffffffc02023b6:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02023b8:	02d70563          	beq	a4,a3,ffffffffc02023e2 <default_free_pages+0xb0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc02023bc:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02023be:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc02023c2:	fee57ae3          	bleu	a4,a0,ffffffffc02023b6 <default_free_pages+0x84>
ffffffffc02023c6:	00080663          	beqz	a6,ffffffffc02023d2 <default_free_pages+0xa0>
ffffffffc02023ca:	0000f817          	auipc	a6,0xf
ffffffffc02023ce:	18b83b23          	sd	a1,406(a6) # ffffffffc0211560 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02023d2:	638c                	ld	a1,0(a5)
    prev->next = next->prev = elm;
ffffffffc02023d4:	e390                	sd	a2,0(a5)
ffffffffc02023d6:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc02023d8:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02023da:	f10c                	sd	a1,32(a0)
    if (le != &free_list) {
ffffffffc02023dc:	02d59163          	bne	a1,a3,ffffffffc02023fe <default_free_pages+0xcc>
ffffffffc02023e0:	a091                	j	ffffffffc0202424 <default_free_pages+0xf2>
    prev->next = next->prev = elm;
ffffffffc02023e2:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02023e4:	f514                	sd	a3,40(a0)
ffffffffc02023e6:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02023e8:	f11c                	sd	a5,32(a0)
                list_add(le, &(base->page_link));
ffffffffc02023ea:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc02023ec:	00d70563          	beq	a4,a3,ffffffffc02023f6 <default_free_pages+0xc4>
ffffffffc02023f0:	4805                	li	a6,1
ffffffffc02023f2:	87ba                	mv	a5,a4
ffffffffc02023f4:	b7e9                	j	ffffffffc02023be <default_free_pages+0x8c>
ffffffffc02023f6:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc02023f8:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc02023fa:	02d78163          	beq	a5,a3,ffffffffc020241c <default_free_pages+0xea>
        if (p + p->property == base) {
ffffffffc02023fe:	ff85a803          	lw	a6,-8(a1) # ff8 <BASE_ADDRESS-0xffffffffc01ff008>
        p = le2page(le, page_link);
ffffffffc0202402:	fe058613          	addi	a2,a1,-32
        if (p + p->property == base) {
ffffffffc0202406:	02081713          	slli	a4,a6,0x20
ffffffffc020240a:	9301                	srli	a4,a4,0x20
ffffffffc020240c:	00371793          	slli	a5,a4,0x3
ffffffffc0202410:	97ba                	add	a5,a5,a4
ffffffffc0202412:	078e                	slli	a5,a5,0x3
ffffffffc0202414:	97b2                	add	a5,a5,a2
ffffffffc0202416:	02f50e63          	beq	a0,a5,ffffffffc0202452 <default_free_pages+0x120>
ffffffffc020241a:	751c                	ld	a5,40(a0)
    if (le != &free_list) {
ffffffffc020241c:	fe078713          	addi	a4,a5,-32
ffffffffc0202420:	00d78d63          	beq	a5,a3,ffffffffc020243a <default_free_pages+0x108>
        if (base + base->property == p) {
ffffffffc0202424:	4d0c                	lw	a1,24(a0)
ffffffffc0202426:	02059613          	slli	a2,a1,0x20
ffffffffc020242a:	9201                	srli	a2,a2,0x20
ffffffffc020242c:	00361693          	slli	a3,a2,0x3
ffffffffc0202430:	96b2                	add	a3,a3,a2
ffffffffc0202432:	068e                	slli	a3,a3,0x3
ffffffffc0202434:	96aa                	add	a3,a3,a0
ffffffffc0202436:	04d70063          	beq	a4,a3,ffffffffc0202476 <default_free_pages+0x144>
}
ffffffffc020243a:	60a2                	ld	ra,8(sp)
ffffffffc020243c:	0141                	addi	sp,sp,16
ffffffffc020243e:	8082                	ret
ffffffffc0202440:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0202442:	02050713          	addi	a4,a0,32
    prev->next = next->prev = elm;
ffffffffc0202446:	e398                	sd	a4,0(a5)
ffffffffc0202448:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc020244a:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc020244c:	f11c                	sd	a5,32(a0)
}
ffffffffc020244e:	0141                	addi	sp,sp,16
ffffffffc0202450:	8082                	ret
            p->property += base->property;
ffffffffc0202452:	4d1c                	lw	a5,24(a0)
ffffffffc0202454:	0107883b          	addw	a6,a5,a6
ffffffffc0202458:	ff05ac23          	sw	a6,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020245c:	57f5                	li	a5,-3
ffffffffc020245e:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0202462:	02053803          	ld	a6,32(a0)
ffffffffc0202466:	7518                	ld	a4,40(a0)
            base = p;
ffffffffc0202468:	8532                	mv	a0,a2
    prev->next = next;
ffffffffc020246a:	00e83423          	sd	a4,8(a6)
    next->prev = prev;
ffffffffc020246e:	659c                	ld	a5,8(a1)
ffffffffc0202470:	01073023          	sd	a6,0(a4)
ffffffffc0202474:	b765                	j	ffffffffc020241c <default_free_pages+0xea>
            base->property += p->property;
ffffffffc0202476:	ff87a703          	lw	a4,-8(a5)
ffffffffc020247a:	fe878693          	addi	a3,a5,-24
ffffffffc020247e:	9db9                	addw	a1,a1,a4
ffffffffc0202480:	cd0c                	sw	a1,24(a0)
ffffffffc0202482:	5775                	li	a4,-3
ffffffffc0202484:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0202488:	6398                	ld	a4,0(a5)
ffffffffc020248a:	679c                	ld	a5,8(a5)
}
ffffffffc020248c:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc020248e:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0202490:	e398                	sd	a4,0(a5)
ffffffffc0202492:	0141                	addi	sp,sp,16
ffffffffc0202494:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0202496:	00003697          	auipc	a3,0x3
ffffffffc020249a:	29a68693          	addi	a3,a3,666 # ffffffffc0205730 <commands+0x12c0>
ffffffffc020249e:	00003617          	auipc	a2,0x3
ffffffffc02024a2:	82a60613          	addi	a2,a2,-2006 # ffffffffc0204cc8 <commands+0x858>
ffffffffc02024a6:	08300593          	li	a1,131
ffffffffc02024aa:	00003517          	auipc	a0,0x3
ffffffffc02024ae:	f7650513          	addi	a0,a0,-138 # ffffffffc0205420 <commands+0xfb0>
ffffffffc02024b2:	c55fd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(n > 0);
ffffffffc02024b6:	00003697          	auipc	a3,0x3
ffffffffc02024ba:	2a268693          	addi	a3,a3,674 # ffffffffc0205758 <commands+0x12e8>
ffffffffc02024be:	00003617          	auipc	a2,0x3
ffffffffc02024c2:	80a60613          	addi	a2,a2,-2038 # ffffffffc0204cc8 <commands+0x858>
ffffffffc02024c6:	08000593          	li	a1,128
ffffffffc02024ca:	00003517          	auipc	a0,0x3
ffffffffc02024ce:	f5650513          	addi	a0,a0,-170 # ffffffffc0205420 <commands+0xfb0>
ffffffffc02024d2:	c35fd0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc02024d6 <default_alloc_pages>:
    assert(n > 0);
ffffffffc02024d6:	cd51                	beqz	a0,ffffffffc0202572 <default_alloc_pages+0x9c>
    if (n > nr_free) {
ffffffffc02024d8:	0000f597          	auipc	a1,0xf
ffffffffc02024dc:	08858593          	addi	a1,a1,136 # ffffffffc0211560 <free_area>
ffffffffc02024e0:	0105a803          	lw	a6,16(a1)
ffffffffc02024e4:	862a                	mv	a2,a0
ffffffffc02024e6:	02081793          	slli	a5,a6,0x20
ffffffffc02024ea:	9381                	srli	a5,a5,0x20
ffffffffc02024ec:	00a7ee63          	bltu	a5,a0,ffffffffc0202508 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc02024f0:	87ae                	mv	a5,a1
ffffffffc02024f2:	a801                	j	ffffffffc0202502 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc02024f4:	ff87a703          	lw	a4,-8(a5)
ffffffffc02024f8:	02071693          	slli	a3,a4,0x20
ffffffffc02024fc:	9281                	srli	a3,a3,0x20
ffffffffc02024fe:	00c6f763          	bleu	a2,a3,ffffffffc020250c <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0202502:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202504:	feb798e3          	bne	a5,a1,ffffffffc02024f4 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc0202508:	4501                	li	a0,0
}
ffffffffc020250a:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc020250c:	fe078513          	addi	a0,a5,-32
    if (page != NULL) {
ffffffffc0202510:	dd6d                	beqz	a0,ffffffffc020250a <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc0202512:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0202516:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc020251a:	00060e1b          	sext.w	t3,a2
ffffffffc020251e:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0202522:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0202526:	02d67b63          	bleu	a3,a2,ffffffffc020255c <default_alloc_pages+0x86>
            struct Page *p = page + n;
ffffffffc020252a:	00361693          	slli	a3,a2,0x3
ffffffffc020252e:	96b2                	add	a3,a3,a2
ffffffffc0202530:	068e                	slli	a3,a3,0x3
ffffffffc0202532:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc0202534:	41c7073b          	subw	a4,a4,t3
ffffffffc0202538:	ce98                	sw	a4,24(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020253a:	00868613          	addi	a2,a3,8
ffffffffc020253e:	4709                	li	a4,2
ffffffffc0202540:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0202544:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0202548:	02068613          	addi	a2,a3,32
    prev->next = next->prev = elm;
ffffffffc020254c:	0105a803          	lw	a6,16(a1)
ffffffffc0202550:	e310                	sd	a2,0(a4)
ffffffffc0202552:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0202556:	f698                	sd	a4,40(a3)
    elm->prev = prev;
ffffffffc0202558:	0316b023          	sd	a7,32(a3)
        nr_free -= n;
ffffffffc020255c:	41c8083b          	subw	a6,a6,t3
ffffffffc0202560:	0000f717          	auipc	a4,0xf
ffffffffc0202564:	01072823          	sw	a6,16(a4) # ffffffffc0211570 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0202568:	5775                	li	a4,-3
ffffffffc020256a:	17a1                	addi	a5,a5,-24
ffffffffc020256c:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc0202570:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0202572:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0202574:	00003697          	auipc	a3,0x3
ffffffffc0202578:	1e468693          	addi	a3,a3,484 # ffffffffc0205758 <commands+0x12e8>
ffffffffc020257c:	00002617          	auipc	a2,0x2
ffffffffc0202580:	74c60613          	addi	a2,a2,1868 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0202584:	06200593          	li	a1,98
ffffffffc0202588:	00003517          	auipc	a0,0x3
ffffffffc020258c:	e9850513          	addi	a0,a0,-360 # ffffffffc0205420 <commands+0xfb0>
default_alloc_pages(size_t n) {
ffffffffc0202590:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0202592:	b75fd0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0202596 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0202596:	1141                	addi	sp,sp,-16
ffffffffc0202598:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020259a:	c1fd                	beqz	a1,ffffffffc0202680 <default_init_memmap+0xea>
    for (; p != base + n; p ++) {
ffffffffc020259c:	00359693          	slli	a3,a1,0x3
ffffffffc02025a0:	96ae                	add	a3,a3,a1
ffffffffc02025a2:	068e                	slli	a3,a3,0x3
ffffffffc02025a4:	96aa                	add	a3,a3,a0
ffffffffc02025a6:	02d50463          	beq	a0,a3,ffffffffc02025ce <default_init_memmap+0x38>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02025aa:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc02025ac:	87aa                	mv	a5,a0
ffffffffc02025ae:	8b05                	andi	a4,a4,1
ffffffffc02025b0:	e709                	bnez	a4,ffffffffc02025ba <default_init_memmap+0x24>
ffffffffc02025b2:	a07d                	j	ffffffffc0202660 <default_init_memmap+0xca>
ffffffffc02025b4:	6798                	ld	a4,8(a5)
ffffffffc02025b6:	8b05                	andi	a4,a4,1
ffffffffc02025b8:	c745                	beqz	a4,ffffffffc0202660 <default_init_memmap+0xca>
        p->flags = p->property = 0;
ffffffffc02025ba:	0007ac23          	sw	zero,24(a5)
ffffffffc02025be:	0007b423          	sd	zero,8(a5)
ffffffffc02025c2:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02025c6:	04878793          	addi	a5,a5,72
ffffffffc02025ca:	fed795e3          	bne	a5,a3,ffffffffc02025b4 <default_init_memmap+0x1e>
    base->property = n;
ffffffffc02025ce:	2581                	sext.w	a1,a1
ffffffffc02025d0:	cd0c                	sw	a1,24(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02025d2:	4789                	li	a5,2
ffffffffc02025d4:	00850713          	addi	a4,a0,8
ffffffffc02025d8:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02025dc:	0000f697          	auipc	a3,0xf
ffffffffc02025e0:	f8468693          	addi	a3,a3,-124 # ffffffffc0211560 <free_area>
ffffffffc02025e4:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02025e6:	669c                	ld	a5,8(a3)
ffffffffc02025e8:	9db9                	addw	a1,a1,a4
ffffffffc02025ea:	0000f717          	auipc	a4,0xf
ffffffffc02025ee:	f8b72323          	sw	a1,-122(a4) # ffffffffc0211570 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc02025f2:	04d78a63          	beq	a5,a3,ffffffffc0202646 <default_init_memmap+0xb0>
            struct Page* page = le2page(le, page_link);
ffffffffc02025f6:	fe078713          	addi	a4,a5,-32
ffffffffc02025fa:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02025fc:	4801                	li	a6,0
ffffffffc02025fe:	02050613          	addi	a2,a0,32
            if (base < page) {
ffffffffc0202602:	00e56a63          	bltu	a0,a4,ffffffffc0202616 <default_init_memmap+0x80>
    return listelm->next;
ffffffffc0202606:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0202608:	02d70563          	beq	a4,a3,ffffffffc0202632 <default_init_memmap+0x9c>
        while ((le = list_next(le)) != &free_list) {
ffffffffc020260c:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020260e:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc0202612:	fee57ae3          	bleu	a4,a0,ffffffffc0202606 <default_init_memmap+0x70>
ffffffffc0202616:	00080663          	beqz	a6,ffffffffc0202622 <default_init_memmap+0x8c>
ffffffffc020261a:	0000f717          	auipc	a4,0xf
ffffffffc020261e:	f4b73323          	sd	a1,-186(a4) # ffffffffc0211560 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0202622:	6398                	ld	a4,0(a5)
}
ffffffffc0202624:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0202626:	e390                	sd	a2,0(a5)
ffffffffc0202628:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020262a:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc020262c:	f118                	sd	a4,32(a0)
ffffffffc020262e:	0141                	addi	sp,sp,16
ffffffffc0202630:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0202632:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0202634:	f514                	sd	a3,40(a0)
ffffffffc0202636:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0202638:	f11c                	sd	a5,32(a0)
                list_add(le, &(base->page_link));
ffffffffc020263a:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc020263c:	00d70e63          	beq	a4,a3,ffffffffc0202658 <default_init_memmap+0xc2>
ffffffffc0202640:	4805                	li	a6,1
ffffffffc0202642:	87ba                	mv	a5,a4
ffffffffc0202644:	b7e9                	j	ffffffffc020260e <default_init_memmap+0x78>
}
ffffffffc0202646:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0202648:	02050713          	addi	a4,a0,32
    prev->next = next->prev = elm;
ffffffffc020264c:	e398                	sd	a4,0(a5)
ffffffffc020264e:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0202650:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0202652:	f11c                	sd	a5,32(a0)
}
ffffffffc0202654:	0141                	addi	sp,sp,16
ffffffffc0202656:	8082                	ret
ffffffffc0202658:	60a2                	ld	ra,8(sp)
ffffffffc020265a:	e290                	sd	a2,0(a3)
ffffffffc020265c:	0141                	addi	sp,sp,16
ffffffffc020265e:	8082                	ret
        assert(PageReserved(p));
ffffffffc0202660:	00003697          	auipc	a3,0x3
ffffffffc0202664:	10068693          	addi	a3,a3,256 # ffffffffc0205760 <commands+0x12f0>
ffffffffc0202668:	00002617          	auipc	a2,0x2
ffffffffc020266c:	66060613          	addi	a2,a2,1632 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0202670:	04900593          	li	a1,73
ffffffffc0202674:	00003517          	auipc	a0,0x3
ffffffffc0202678:	dac50513          	addi	a0,a0,-596 # ffffffffc0205420 <commands+0xfb0>
ffffffffc020267c:	a8bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(n > 0);
ffffffffc0202680:	00003697          	auipc	a3,0x3
ffffffffc0202684:	0d868693          	addi	a3,a3,216 # ffffffffc0205758 <commands+0x12e8>
ffffffffc0202688:	00002617          	auipc	a2,0x2
ffffffffc020268c:	64060613          	addi	a2,a2,1600 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0202690:	04600593          	li	a1,70
ffffffffc0202694:	00003517          	auipc	a0,0x3
ffffffffc0202698:	d8c50513          	addi	a0,a0,-628 # ffffffffc0205420 <commands+0xfb0>
ffffffffc020269c:	a6bfd0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc02026a0 <_clock_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc02026a0:	0000f797          	auipc	a5,0xf
ffffffffc02026a4:	de078793          	addi	a5,a5,-544 # ffffffffc0211480 <pra_list_head>
static int
_clock_init_mm(struct mm_struct *mm)//初始化
{    
     list_init(&pra_list_head);
     curr_ptr=&pra_list_head;
     mm->sm_priv = &pra_list_head; 
ffffffffc02026a8:	f51c                	sd	a5,40(a0)
ffffffffc02026aa:	e79c                	sd	a5,8(a5)
ffffffffc02026ac:	e39c                	sd	a5,0(a5)
     curr_ptr=&pra_list_head;
ffffffffc02026ae:	0000f717          	auipc	a4,0xf
ffffffffc02026b2:	ecf73523          	sd	a5,-310(a4) # ffffffffc0211578 <curr_ptr>
     // 初始化pra_list_head为空链表
     // 初始化当前指针curr_ptr指向pra_list_head，表示当前页面替换位置为链表头
     // 将mm的私有成员指针指向pra_list_head，用于后续的页面替换算法操作
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc02026b6:	4501                	li	a0,0
ffffffffc02026b8:	8082                	ret

ffffffffc02026ba <_clock_init>:

static int
_clock_init(void)
{
    return 0;
}
ffffffffc02026ba:	4501                	li	a0,0
ffffffffc02026bc:	8082                	ret

ffffffffc02026be <_clock_set_unswappable>:

static int
_clock_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc02026be:	4501                	li	a0,0
ffffffffc02026c0:	8082                	ret

ffffffffc02026c2 <_clock_tick_event>:

static int
_clock_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc02026c2:	4501                	li	a0,0
ffffffffc02026c4:	8082                	ret

ffffffffc02026c6 <_clock_check_swap>:
_clock_check_swap(void) {
ffffffffc02026c6:	1141                	addi	sp,sp,-16
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02026c8:	678d                	lui	a5,0x3
ffffffffc02026ca:	4731                	li	a4,12
_clock_check_swap(void) {
ffffffffc02026cc:	e406                	sd	ra,8(sp)
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02026ce:	00e78023          	sb	a4,0(a5) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc02026d2:	0000f797          	auipc	a5,0xf
ffffffffc02026d6:	d7e78793          	addi	a5,a5,-642 # ffffffffc0211450 <pgfault_num>
ffffffffc02026da:	4398                	lw	a4,0(a5)
ffffffffc02026dc:	4691                	li	a3,4
ffffffffc02026de:	2701                	sext.w	a4,a4
ffffffffc02026e0:	08d71f63          	bne	a4,a3,ffffffffc020277e <_clock_check_swap+0xb8>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02026e4:	6685                	lui	a3,0x1
ffffffffc02026e6:	4629                	li	a2,10
ffffffffc02026e8:	00c68023          	sb	a2,0(a3) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc02026ec:	4394                	lw	a3,0(a5)
ffffffffc02026ee:	2681                	sext.w	a3,a3
ffffffffc02026f0:	20e69763          	bne	a3,a4,ffffffffc02028fe <_clock_check_swap+0x238>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02026f4:	6711                	lui	a4,0x4
ffffffffc02026f6:	4635                	li	a2,13
ffffffffc02026f8:	00c70023          	sb	a2,0(a4) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc02026fc:	4398                	lw	a4,0(a5)
ffffffffc02026fe:	2701                	sext.w	a4,a4
ffffffffc0202700:	1cd71f63          	bne	a4,a3,ffffffffc02028de <_clock_check_swap+0x218>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202704:	6689                	lui	a3,0x2
ffffffffc0202706:	462d                	li	a2,11
ffffffffc0202708:	00c68023          	sb	a2,0(a3) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc020270c:	4394                	lw	a3,0(a5)
ffffffffc020270e:	2681                	sext.w	a3,a3
ffffffffc0202710:	1ae69763          	bne	a3,a4,ffffffffc02028be <_clock_check_swap+0x1f8>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0202714:	6715                	lui	a4,0x5
ffffffffc0202716:	46b9                	li	a3,14
ffffffffc0202718:	00d70023          	sb	a3,0(a4) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc020271c:	4398                	lw	a4,0(a5)
ffffffffc020271e:	4695                	li	a3,5
ffffffffc0202720:	2701                	sext.w	a4,a4
ffffffffc0202722:	16d71e63          	bne	a4,a3,ffffffffc020289e <_clock_check_swap+0x1d8>
    assert(pgfault_num==5);
ffffffffc0202726:	4394                	lw	a3,0(a5)
ffffffffc0202728:	2681                	sext.w	a3,a3
ffffffffc020272a:	14e69a63          	bne	a3,a4,ffffffffc020287e <_clock_check_swap+0x1b8>
    assert(pgfault_num==5);
ffffffffc020272e:	4398                	lw	a4,0(a5)
ffffffffc0202730:	2701                	sext.w	a4,a4
ffffffffc0202732:	12d71663          	bne	a4,a3,ffffffffc020285e <_clock_check_swap+0x198>
    assert(pgfault_num==5);
ffffffffc0202736:	4394                	lw	a3,0(a5)
ffffffffc0202738:	2681                	sext.w	a3,a3
ffffffffc020273a:	10e69263          	bne	a3,a4,ffffffffc020283e <_clock_check_swap+0x178>
    assert(pgfault_num==5);
ffffffffc020273e:	4398                	lw	a4,0(a5)
ffffffffc0202740:	2701                	sext.w	a4,a4
ffffffffc0202742:	0cd71e63          	bne	a4,a3,ffffffffc020281e <_clock_check_swap+0x158>
    assert(pgfault_num==5);
ffffffffc0202746:	4394                	lw	a3,0(a5)
ffffffffc0202748:	2681                	sext.w	a3,a3
ffffffffc020274a:	0ae69a63          	bne	a3,a4,ffffffffc02027fe <_clock_check_swap+0x138>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc020274e:	6715                	lui	a4,0x5
ffffffffc0202750:	46b9                	li	a3,14
ffffffffc0202752:	00d70023          	sb	a3,0(a4) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc0202756:	4398                	lw	a4,0(a5)
ffffffffc0202758:	4695                	li	a3,5
ffffffffc020275a:	2701                	sext.w	a4,a4
ffffffffc020275c:	08d71163          	bne	a4,a3,ffffffffc02027de <_clock_check_swap+0x118>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0202760:	6705                	lui	a4,0x1
ffffffffc0202762:	00074683          	lbu	a3,0(a4) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc0202766:	4729                	li	a4,10
ffffffffc0202768:	04e69b63          	bne	a3,a4,ffffffffc02027be <_clock_check_swap+0xf8>
    assert(pgfault_num==6);
ffffffffc020276c:	439c                	lw	a5,0(a5)
ffffffffc020276e:	4719                	li	a4,6
ffffffffc0202770:	2781                	sext.w	a5,a5
ffffffffc0202772:	02e79663          	bne	a5,a4,ffffffffc020279e <_clock_check_swap+0xd8>
}
ffffffffc0202776:	60a2                	ld	ra,8(sp)
ffffffffc0202778:	4501                	li	a0,0
ffffffffc020277a:	0141                	addi	sp,sp,16
ffffffffc020277c:	8082                	ret
    assert(pgfault_num==4);
ffffffffc020277e:	00003697          	auipc	a3,0x3
ffffffffc0202782:	b0268693          	addi	a3,a3,-1278 # ffffffffc0205280 <commands+0xe10>
ffffffffc0202786:	00002617          	auipc	a2,0x2
ffffffffc020278a:	54260613          	addi	a2,a2,1346 # ffffffffc0204cc8 <commands+0x858>
ffffffffc020278e:	07b00593          	li	a1,123
ffffffffc0202792:	00003517          	auipc	a0,0x3
ffffffffc0202796:	02e50513          	addi	a0,a0,46 # ffffffffc02057c0 <default_pmm_manager+0x50>
ffffffffc020279a:	96dfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==6);
ffffffffc020279e:	00003697          	auipc	a3,0x3
ffffffffc02027a2:	07268693          	addi	a3,a3,114 # ffffffffc0205810 <default_pmm_manager+0xa0>
ffffffffc02027a6:	00002617          	auipc	a2,0x2
ffffffffc02027aa:	52260613          	addi	a2,a2,1314 # ffffffffc0204cc8 <commands+0x858>
ffffffffc02027ae:	09200593          	li	a1,146
ffffffffc02027b2:	00003517          	auipc	a0,0x3
ffffffffc02027b6:	00e50513          	addi	a0,a0,14 # ffffffffc02057c0 <default_pmm_manager+0x50>
ffffffffc02027ba:	94dfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc02027be:	00003697          	auipc	a3,0x3
ffffffffc02027c2:	02a68693          	addi	a3,a3,42 # ffffffffc02057e8 <default_pmm_manager+0x78>
ffffffffc02027c6:	00002617          	auipc	a2,0x2
ffffffffc02027ca:	50260613          	addi	a2,a2,1282 # ffffffffc0204cc8 <commands+0x858>
ffffffffc02027ce:	09000593          	li	a1,144
ffffffffc02027d2:	00003517          	auipc	a0,0x3
ffffffffc02027d6:	fee50513          	addi	a0,a0,-18 # ffffffffc02057c0 <default_pmm_manager+0x50>
ffffffffc02027da:	92dfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==5);
ffffffffc02027de:	00003697          	auipc	a3,0x3
ffffffffc02027e2:	ffa68693          	addi	a3,a3,-6 # ffffffffc02057d8 <default_pmm_manager+0x68>
ffffffffc02027e6:	00002617          	auipc	a2,0x2
ffffffffc02027ea:	4e260613          	addi	a2,a2,1250 # ffffffffc0204cc8 <commands+0x858>
ffffffffc02027ee:	08f00593          	li	a1,143
ffffffffc02027f2:	00003517          	auipc	a0,0x3
ffffffffc02027f6:	fce50513          	addi	a0,a0,-50 # ffffffffc02057c0 <default_pmm_manager+0x50>
ffffffffc02027fa:	90dfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==5);
ffffffffc02027fe:	00003697          	auipc	a3,0x3
ffffffffc0202802:	fda68693          	addi	a3,a3,-38 # ffffffffc02057d8 <default_pmm_manager+0x68>
ffffffffc0202806:	00002617          	auipc	a2,0x2
ffffffffc020280a:	4c260613          	addi	a2,a2,1218 # ffffffffc0204cc8 <commands+0x858>
ffffffffc020280e:	08d00593          	li	a1,141
ffffffffc0202812:	00003517          	auipc	a0,0x3
ffffffffc0202816:	fae50513          	addi	a0,a0,-82 # ffffffffc02057c0 <default_pmm_manager+0x50>
ffffffffc020281a:	8edfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==5);
ffffffffc020281e:	00003697          	auipc	a3,0x3
ffffffffc0202822:	fba68693          	addi	a3,a3,-70 # ffffffffc02057d8 <default_pmm_manager+0x68>
ffffffffc0202826:	00002617          	auipc	a2,0x2
ffffffffc020282a:	4a260613          	addi	a2,a2,1186 # ffffffffc0204cc8 <commands+0x858>
ffffffffc020282e:	08b00593          	li	a1,139
ffffffffc0202832:	00003517          	auipc	a0,0x3
ffffffffc0202836:	f8e50513          	addi	a0,a0,-114 # ffffffffc02057c0 <default_pmm_manager+0x50>
ffffffffc020283a:	8cdfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==5);
ffffffffc020283e:	00003697          	auipc	a3,0x3
ffffffffc0202842:	f9a68693          	addi	a3,a3,-102 # ffffffffc02057d8 <default_pmm_manager+0x68>
ffffffffc0202846:	00002617          	auipc	a2,0x2
ffffffffc020284a:	48260613          	addi	a2,a2,1154 # ffffffffc0204cc8 <commands+0x858>
ffffffffc020284e:	08900593          	li	a1,137
ffffffffc0202852:	00003517          	auipc	a0,0x3
ffffffffc0202856:	f6e50513          	addi	a0,a0,-146 # ffffffffc02057c0 <default_pmm_manager+0x50>
ffffffffc020285a:	8adfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==5);
ffffffffc020285e:	00003697          	auipc	a3,0x3
ffffffffc0202862:	f7a68693          	addi	a3,a3,-134 # ffffffffc02057d8 <default_pmm_manager+0x68>
ffffffffc0202866:	00002617          	auipc	a2,0x2
ffffffffc020286a:	46260613          	addi	a2,a2,1122 # ffffffffc0204cc8 <commands+0x858>
ffffffffc020286e:	08700593          	li	a1,135
ffffffffc0202872:	00003517          	auipc	a0,0x3
ffffffffc0202876:	f4e50513          	addi	a0,a0,-178 # ffffffffc02057c0 <default_pmm_manager+0x50>
ffffffffc020287a:	88dfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==5);
ffffffffc020287e:	00003697          	auipc	a3,0x3
ffffffffc0202882:	f5a68693          	addi	a3,a3,-166 # ffffffffc02057d8 <default_pmm_manager+0x68>
ffffffffc0202886:	00002617          	auipc	a2,0x2
ffffffffc020288a:	44260613          	addi	a2,a2,1090 # ffffffffc0204cc8 <commands+0x858>
ffffffffc020288e:	08500593          	li	a1,133
ffffffffc0202892:	00003517          	auipc	a0,0x3
ffffffffc0202896:	f2e50513          	addi	a0,a0,-210 # ffffffffc02057c0 <default_pmm_manager+0x50>
ffffffffc020289a:	86dfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==5);
ffffffffc020289e:	00003697          	auipc	a3,0x3
ffffffffc02028a2:	f3a68693          	addi	a3,a3,-198 # ffffffffc02057d8 <default_pmm_manager+0x68>
ffffffffc02028a6:	00002617          	auipc	a2,0x2
ffffffffc02028aa:	42260613          	addi	a2,a2,1058 # ffffffffc0204cc8 <commands+0x858>
ffffffffc02028ae:	08300593          	li	a1,131
ffffffffc02028b2:	00003517          	auipc	a0,0x3
ffffffffc02028b6:	f0e50513          	addi	a0,a0,-242 # ffffffffc02057c0 <default_pmm_manager+0x50>
ffffffffc02028ba:	84dfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==4);
ffffffffc02028be:	00003697          	auipc	a3,0x3
ffffffffc02028c2:	9c268693          	addi	a3,a3,-1598 # ffffffffc0205280 <commands+0xe10>
ffffffffc02028c6:	00002617          	auipc	a2,0x2
ffffffffc02028ca:	40260613          	addi	a2,a2,1026 # ffffffffc0204cc8 <commands+0x858>
ffffffffc02028ce:	08100593          	li	a1,129
ffffffffc02028d2:	00003517          	auipc	a0,0x3
ffffffffc02028d6:	eee50513          	addi	a0,a0,-274 # ffffffffc02057c0 <default_pmm_manager+0x50>
ffffffffc02028da:	82dfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==4);
ffffffffc02028de:	00003697          	auipc	a3,0x3
ffffffffc02028e2:	9a268693          	addi	a3,a3,-1630 # ffffffffc0205280 <commands+0xe10>
ffffffffc02028e6:	00002617          	auipc	a2,0x2
ffffffffc02028ea:	3e260613          	addi	a2,a2,994 # ffffffffc0204cc8 <commands+0x858>
ffffffffc02028ee:	07f00593          	li	a1,127
ffffffffc02028f2:	00003517          	auipc	a0,0x3
ffffffffc02028f6:	ece50513          	addi	a0,a0,-306 # ffffffffc02057c0 <default_pmm_manager+0x50>
ffffffffc02028fa:	80dfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==4);
ffffffffc02028fe:	00003697          	auipc	a3,0x3
ffffffffc0202902:	98268693          	addi	a3,a3,-1662 # ffffffffc0205280 <commands+0xe10>
ffffffffc0202906:	00002617          	auipc	a2,0x2
ffffffffc020290a:	3c260613          	addi	a2,a2,962 # ffffffffc0204cc8 <commands+0x858>
ffffffffc020290e:	07d00593          	li	a1,125
ffffffffc0202912:	00003517          	auipc	a0,0x3
ffffffffc0202916:	eae50513          	addi	a0,a0,-338 # ffffffffc02057c0 <default_pmm_manager+0x50>
ffffffffc020291a:	fecfd0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc020291e <_clock_swap_out_victim>:
{
ffffffffc020291e:	7179                	addi	sp,sp,-48
ffffffffc0202920:	f022                	sd	s0,32(sp)
ffffffffc0202922:	842a                	mv	s0,a0
    cprintf("clock swapout done!");
ffffffffc0202924:	00003517          	auipc	a0,0x3
ffffffffc0202928:	f3c50513          	addi	a0,a0,-196 # ffffffffc0205860 <default_pmm_manager+0xf0>
{
ffffffffc020292c:	e44e                	sd	s3,8(sp)
ffffffffc020292e:	e052                	sd	s4,0(sp)
ffffffffc0202930:	f406                	sd	ra,40(sp)
ffffffffc0202932:	ec26                	sd	s1,24(sp)
ffffffffc0202934:	e84a                	sd	s2,16(sp)
ffffffffc0202936:	89ae                	mv	s3,a1
ffffffffc0202938:	8a32                	mv	s4,a2
    cprintf("clock swapout done!");
ffffffffc020293a:	f84fd0ef          	jal	ra,ffffffffc02000be <cprintf>
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc020293e:	7400                	ld	s0,40(s0)
         assert(head != NULL);
ffffffffc0202940:	c851                	beqz	s0,ffffffffc02029d4 <_clock_swap_out_victim+0xb6>
        cprintf("loop");
ffffffffc0202942:	00003497          	auipc	s1,0x3
ffffffffc0202946:	f5648493          	addi	s1,s1,-170 # ffffffffc0205898 <default_pmm_manager+0x128>
        if(p->visited==1)//为1置为0
ffffffffc020294a:	4905                	li	s2,1
     assert(in_tick==0);
ffffffffc020294c:	000a0863          	beqz	s4,ffffffffc020295c <_clock_swap_out_victim+0x3e>
ffffffffc0202950:	a095                	j	ffffffffc02029b4 <_clock_swap_out_victim+0x96>
        if(p->visited==0)// 为0挑出来
ffffffffc0202952:	fe07b703          	ld	a4,-32(a5)
ffffffffc0202956:	c705                	beqz	a4,ffffffffc020297e <_clock_swap_out_victim+0x60>
        if(p->visited==1)//为1置为0
ffffffffc0202958:	05270763          	beq	a4,s2,ffffffffc02029a6 <_clock_swap_out_victim+0x88>
        cprintf("loop");
ffffffffc020295c:	8526                	mv	a0,s1
ffffffffc020295e:	f60fd0ef          	jal	ra,ffffffffc02000be <cprintf>
    return listelm->prev;
ffffffffc0202962:	601c                	ld	a5,0(s0)
        if (entry == head) {
ffffffffc0202964:	fef417e3          	bne	s0,a5,ffffffffc0202952 <_clock_swap_out_victim+0x34>
            *ptr_page = NULL;
ffffffffc0202968:	0009b023          	sd	zero,0(s3)
}
ffffffffc020296c:	70a2                	ld	ra,40(sp)
ffffffffc020296e:	7402                	ld	s0,32(sp)
ffffffffc0202970:	64e2                	ld	s1,24(sp)
ffffffffc0202972:	6942                	ld	s2,16(sp)
ffffffffc0202974:	69a2                	ld	s3,8(sp)
ffffffffc0202976:	6a02                	ld	s4,0(sp)
ffffffffc0202978:	4501                	li	a0,0
ffffffffc020297a:	6145                	addi	sp,sp,48
ffffffffc020297c:	8082                	ret
    __list_del(listelm->prev, listelm->next);
ffffffffc020297e:	6394                	ld	a3,0(a5)
ffffffffc0202980:	6798                	ld	a4,8(a5)
            cprintf("curr_ptr %p\n", curr_ptr);
ffffffffc0202982:	0000f617          	auipc	a2,0xf
ffffffffc0202986:	bf660613          	addi	a2,a2,-1034 # ffffffffc0211578 <curr_ptr>
ffffffffc020298a:	620c                	ld	a1,0(a2)
    prev->next = next;
ffffffffc020298c:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc020298e:	e314                	sd	a3,0(a4)
        struct Page *p = le2page(entry, pra_page_link);
ffffffffc0202990:	fd078793          	addi	a5,a5,-48
            *ptr_page = le2page(entry, pra_page_link); 
ffffffffc0202994:	00f9b023          	sd	a5,0(s3)
            cprintf("curr_ptr %p\n", curr_ptr);
ffffffffc0202998:	00003517          	auipc	a0,0x3
ffffffffc020299c:	f0850513          	addi	a0,a0,-248 # ffffffffc02058a0 <default_pmm_manager+0x130>
ffffffffc02029a0:	f1efd0ef          	jal	ra,ffffffffc02000be <cprintf>
            break;
ffffffffc02029a4:	b7e1                	j	ffffffffc020296c <_clock_swap_out_victim+0x4e>
            p->visited=0;
ffffffffc02029a6:	fe07b023          	sd	zero,-32(a5)
            curr_ptr = entry;
ffffffffc02029aa:	0000f717          	auipc	a4,0xf
ffffffffc02029ae:	bcf73723          	sd	a5,-1074(a4) # ffffffffc0211578 <curr_ptr>
    return listelm->prev;
ffffffffc02029b2:	b76d                	j	ffffffffc020295c <_clock_swap_out_victim+0x3e>
     assert(in_tick==0);
ffffffffc02029b4:	00003697          	auipc	a3,0x3
ffffffffc02029b8:	ed468693          	addi	a3,a3,-300 # ffffffffc0205888 <default_pmm_manager+0x118>
ffffffffc02029bc:	00002617          	auipc	a2,0x2
ffffffffc02029c0:	30c60613          	addi	a2,a2,780 # ffffffffc0204cc8 <commands+0x858>
ffffffffc02029c4:	03000593          	li	a1,48
ffffffffc02029c8:	00003517          	auipc	a0,0x3
ffffffffc02029cc:	df850513          	addi	a0,a0,-520 # ffffffffc02057c0 <default_pmm_manager+0x50>
ffffffffc02029d0:	f36fd0ef          	jal	ra,ffffffffc0200106 <__panic>
         assert(head != NULL);
ffffffffc02029d4:	00003697          	auipc	a3,0x3
ffffffffc02029d8:	ea468693          	addi	a3,a3,-348 # ffffffffc0205878 <default_pmm_manager+0x108>
ffffffffc02029dc:	00002617          	auipc	a2,0x2
ffffffffc02029e0:	2ec60613          	addi	a2,a2,748 # ffffffffc0204cc8 <commands+0x858>
ffffffffc02029e4:	02f00593          	li	a1,47
ffffffffc02029e8:	00003517          	auipc	a0,0x3
ffffffffc02029ec:	dd850513          	addi	a0,a0,-552 # ffffffffc02057c0 <default_pmm_manager+0x50>
ffffffffc02029f0:	f16fd0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc02029f4 <_clock_map_swappable>:
{
ffffffffc02029f4:	1101                	addi	sp,sp,-32
ffffffffc02029f6:	e426                	sd	s1,8(sp)
ffffffffc02029f8:	84aa                	mv	s1,a0
    cprintf("clock swappable done!");
ffffffffc02029fa:	00003517          	auipc	a0,0x3
ffffffffc02029fe:	e2650513          	addi	a0,a0,-474 # ffffffffc0205820 <default_pmm_manager+0xb0>
{
ffffffffc0202a02:	e822                	sd	s0,16(sp)
ffffffffc0202a04:	ec06                	sd	ra,24(sp)
ffffffffc0202a06:	8432                	mv	s0,a2
    cprintf("clock swappable done!");
ffffffffc0202a08:	eb6fd0ef          	jal	ra,ffffffffc02000be <cprintf>
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc0202a0c:	03040793          	addi	a5,s0,48
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0202a10:	7498                	ld	a4,40(s1)
    assert(entry != NULL && curr_ptr!= NULL);
ffffffffc0202a12:	c785                	beqz	a5,ffffffffc0202a3a <_clock_map_swappable+0x46>
ffffffffc0202a14:	0000f697          	auipc	a3,0xf
ffffffffc0202a18:	b6468693          	addi	a3,a3,-1180 # ffffffffc0211578 <curr_ptr>
ffffffffc0202a1c:	6294                	ld	a3,0(a3)
ffffffffc0202a1e:	ce91                	beqz	a3,ffffffffc0202a3a <_clock_map_swappable+0x46>
    __list_add(elm, listelm, listelm->next);
ffffffffc0202a20:	6714                	ld	a3,8(a4)
}
ffffffffc0202a22:	60e2                	ld	ra,24(sp)
ffffffffc0202a24:	64a2                	ld	s1,8(sp)
    prev->next = next->prev = elm;
ffffffffc0202a26:	e29c                	sd	a5,0(a3)
ffffffffc0202a28:	e71c                	sd	a5,8(a4)
    page->visited=1;//设置标记
ffffffffc0202a2a:	4785                	li	a5,1
    elm->next = next;
ffffffffc0202a2c:	fc14                	sd	a3,56(s0)
    elm->prev = prev;
ffffffffc0202a2e:	f818                	sd	a4,48(s0)
ffffffffc0202a30:	e81c                	sd	a5,16(s0)
}
ffffffffc0202a32:	6442                	ld	s0,16(sp)
ffffffffc0202a34:	4501                	li	a0,0
ffffffffc0202a36:	6105                	addi	sp,sp,32
ffffffffc0202a38:	8082                	ret
    assert(entry != NULL && curr_ptr!= NULL);
ffffffffc0202a3a:	00003697          	auipc	a3,0x3
ffffffffc0202a3e:	dfe68693          	addi	a3,a3,-514 # ffffffffc0205838 <default_pmm_manager+0xc8>
ffffffffc0202a42:	00002617          	auipc	a2,0x2
ffffffffc0202a46:	28660613          	addi	a2,a2,646 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0202a4a:	02100593          	li	a1,33
ffffffffc0202a4e:	00003517          	auipc	a0,0x3
ffffffffc0202a52:	d7250513          	addi	a0,a0,-654 # ffffffffc02057c0 <default_pmm_manager+0x50>
ffffffffc0202a56:	eb0fd0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0202a5a <pa2page.part.4>:
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc0202a5a:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0202a5c:	00002617          	auipc	a2,0x2
ffffffffc0202a60:	57460613          	addi	a2,a2,1396 # ffffffffc0204fd0 <commands+0xb60>
ffffffffc0202a64:	06500593          	li	a1,101
ffffffffc0202a68:	00002517          	auipc	a0,0x2
ffffffffc0202a6c:	58850513          	addi	a0,a0,1416 # ffffffffc0204ff0 <commands+0xb80>
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc0202a70:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0202a72:	e94fd0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0202a76 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0202a76:	715d                	addi	sp,sp,-80
ffffffffc0202a78:	e0a2                	sd	s0,64(sp)
ffffffffc0202a7a:	fc26                	sd	s1,56(sp)
ffffffffc0202a7c:	f84a                	sd	s2,48(sp)
ffffffffc0202a7e:	f44e                	sd	s3,40(sp)
ffffffffc0202a80:	f052                	sd	s4,32(sp)
ffffffffc0202a82:	ec56                	sd	s5,24(sp)
ffffffffc0202a84:	e486                	sd	ra,72(sp)
ffffffffc0202a86:	842a                	mv	s0,a0
ffffffffc0202a88:	0000f497          	auipc	s1,0xf
ffffffffc0202a8c:	af848493          	addi	s1,s1,-1288 # ffffffffc0211580 <pmm_manager>
    while (1) {
        local_intr_save(intr_flag);
        { page = pmm_manager->alloc_pages(n); }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0202a90:	4985                	li	s3,1
ffffffffc0202a92:	0000fa17          	auipc	s4,0xf
ffffffffc0202a96:	9cea0a13          	addi	s4,s4,-1586 # ffffffffc0211460 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0202a9a:	0005091b          	sext.w	s2,a0
ffffffffc0202a9e:	0000fa97          	auipc	s5,0xf
ffffffffc0202aa2:	9f2a8a93          	addi	s5,s5,-1550 # ffffffffc0211490 <check_mm_struct>
ffffffffc0202aa6:	a00d                	j	ffffffffc0202ac8 <alloc_pages+0x52>
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0202aa8:	609c                	ld	a5,0(s1)
ffffffffc0202aaa:	6f9c                	ld	a5,24(a5)
ffffffffc0202aac:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc0202aae:	4601                	li	a2,0
ffffffffc0202ab0:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0202ab2:	ed0d                	bnez	a0,ffffffffc0202aec <alloc_pages+0x76>
ffffffffc0202ab4:	0289ec63          	bltu	s3,s0,ffffffffc0202aec <alloc_pages+0x76>
ffffffffc0202ab8:	000a2783          	lw	a5,0(s4)
ffffffffc0202abc:	2781                	sext.w	a5,a5
ffffffffc0202abe:	c79d                	beqz	a5,ffffffffc0202aec <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc0202ac0:	000ab503          	ld	a0,0(s5)
ffffffffc0202ac4:	eddfe0ef          	jal	ra,ffffffffc02019a0 <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202ac8:	100027f3          	csrr	a5,sstatus
ffffffffc0202acc:	8b89                	andi	a5,a5,2
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0202ace:	8522                	mv	a0,s0
ffffffffc0202ad0:	dfe1                	beqz	a5,ffffffffc0202aa8 <alloc_pages+0x32>
        intr_disable();
ffffffffc0202ad2:	a29fd0ef          	jal	ra,ffffffffc02004fa <intr_disable>
ffffffffc0202ad6:	609c                	ld	a5,0(s1)
ffffffffc0202ad8:	8522                	mv	a0,s0
ffffffffc0202ada:	6f9c                	ld	a5,24(a5)
ffffffffc0202adc:	9782                	jalr	a5
ffffffffc0202ade:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0202ae0:	a15fd0ef          	jal	ra,ffffffffc02004f4 <intr_enable>
ffffffffc0202ae4:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc0202ae6:	4601                	li	a2,0
ffffffffc0202ae8:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0202aea:	d569                	beqz	a0,ffffffffc0202ab4 <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0202aec:	60a6                	ld	ra,72(sp)
ffffffffc0202aee:	6406                	ld	s0,64(sp)
ffffffffc0202af0:	74e2                	ld	s1,56(sp)
ffffffffc0202af2:	7942                	ld	s2,48(sp)
ffffffffc0202af4:	79a2                	ld	s3,40(sp)
ffffffffc0202af6:	7a02                	ld	s4,32(sp)
ffffffffc0202af8:	6ae2                	ld	s5,24(sp)
ffffffffc0202afa:	6161                	addi	sp,sp,80
ffffffffc0202afc:	8082                	ret

ffffffffc0202afe <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202afe:	100027f3          	csrr	a5,sstatus
ffffffffc0202b02:	8b89                	andi	a5,a5,2
ffffffffc0202b04:	eb89                	bnez	a5,ffffffffc0202b16 <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;

    local_intr_save(intr_flag);
    { pmm_manager->free_pages(base, n); }
ffffffffc0202b06:	0000f797          	auipc	a5,0xf
ffffffffc0202b0a:	a7a78793          	addi	a5,a5,-1414 # ffffffffc0211580 <pmm_manager>
ffffffffc0202b0e:	639c                	ld	a5,0(a5)
ffffffffc0202b10:	0207b303          	ld	t1,32(a5)
ffffffffc0202b14:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0202b16:	1101                	addi	sp,sp,-32
ffffffffc0202b18:	ec06                	sd	ra,24(sp)
ffffffffc0202b1a:	e822                	sd	s0,16(sp)
ffffffffc0202b1c:	e426                	sd	s1,8(sp)
ffffffffc0202b1e:	842a                	mv	s0,a0
ffffffffc0202b20:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0202b22:	9d9fd0ef          	jal	ra,ffffffffc02004fa <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0202b26:	0000f797          	auipc	a5,0xf
ffffffffc0202b2a:	a5a78793          	addi	a5,a5,-1446 # ffffffffc0211580 <pmm_manager>
ffffffffc0202b2e:	639c                	ld	a5,0(a5)
ffffffffc0202b30:	85a6                	mv	a1,s1
ffffffffc0202b32:	8522                	mv	a0,s0
ffffffffc0202b34:	739c                	ld	a5,32(a5)
ffffffffc0202b36:	9782                	jalr	a5
    local_intr_restore(intr_flag);
}
ffffffffc0202b38:	6442                	ld	s0,16(sp)
ffffffffc0202b3a:	60e2                	ld	ra,24(sp)
ffffffffc0202b3c:	64a2                	ld	s1,8(sp)
ffffffffc0202b3e:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0202b40:	9b5fd06f          	j	ffffffffc02004f4 <intr_enable>

ffffffffc0202b44 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202b44:	100027f3          	csrr	a5,sstatus
ffffffffc0202b48:	8b89                	andi	a5,a5,2
ffffffffc0202b4a:	eb89                	bnez	a5,ffffffffc0202b5c <nr_free_pages+0x18>
// of current free memory
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0202b4c:	0000f797          	auipc	a5,0xf
ffffffffc0202b50:	a3478793          	addi	a5,a5,-1484 # ffffffffc0211580 <pmm_manager>
ffffffffc0202b54:	639c                	ld	a5,0(a5)
ffffffffc0202b56:	0287b303          	ld	t1,40(a5)
ffffffffc0202b5a:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0202b5c:	1141                	addi	sp,sp,-16
ffffffffc0202b5e:	e406                	sd	ra,8(sp)
ffffffffc0202b60:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0202b62:	999fd0ef          	jal	ra,ffffffffc02004fa <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0202b66:	0000f797          	auipc	a5,0xf
ffffffffc0202b6a:	a1a78793          	addi	a5,a5,-1510 # ffffffffc0211580 <pmm_manager>
ffffffffc0202b6e:	639c                	ld	a5,0(a5)
ffffffffc0202b70:	779c                	ld	a5,40(a5)
ffffffffc0202b72:	9782                	jalr	a5
ffffffffc0202b74:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202b76:	97ffd0ef          	jal	ra,ffffffffc02004f4 <intr_enable>
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0202b7a:	8522                	mv	a0,s0
ffffffffc0202b7c:	60a2                	ld	ra,8(sp)
ffffffffc0202b7e:	6402                	ld	s0,0(sp)
ffffffffc0202b80:	0141                	addi	sp,sp,16
ffffffffc0202b82:	8082                	ret

ffffffffc0202b84 <get_pte>:
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0202b84:	715d                	addi	sp,sp,-80
ffffffffc0202b86:	fc26                	sd	s1,56(sp)
     *   PTE_W           0x002                   // page table/directory entry
     * flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry
     * flags bit : User can access
     */
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0202b88:	01e5d493          	srli	s1,a1,0x1e
ffffffffc0202b8c:	1ff4f493          	andi	s1,s1,511
ffffffffc0202b90:	048e                	slli	s1,s1,0x3
ffffffffc0202b92:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V)) {
ffffffffc0202b94:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0202b96:	f84a                	sd	s2,48(sp)
ffffffffc0202b98:	f44e                	sd	s3,40(sp)
ffffffffc0202b9a:	f052                	sd	s4,32(sp)
ffffffffc0202b9c:	e486                	sd	ra,72(sp)
ffffffffc0202b9e:	e0a2                	sd	s0,64(sp)
ffffffffc0202ba0:	ec56                	sd	s5,24(sp)
ffffffffc0202ba2:	e85a                	sd	s6,16(sp)
ffffffffc0202ba4:	e45e                	sd	s7,8(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0202ba6:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0202baa:	892e                	mv	s2,a1
ffffffffc0202bac:	8a32                	mv	s4,a2
ffffffffc0202bae:	0000f997          	auipc	s3,0xf
ffffffffc0202bb2:	8c298993          	addi	s3,s3,-1854 # ffffffffc0211470 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0202bb6:	e3c9                	bnez	a5,ffffffffc0202c38 <get_pte+0xb4>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0202bb8:	16060163          	beqz	a2,ffffffffc0202d1a <get_pte+0x196>
ffffffffc0202bbc:	4505                	li	a0,1
ffffffffc0202bbe:	eb9ff0ef          	jal	ra,ffffffffc0202a76 <alloc_pages>
ffffffffc0202bc2:	842a                	mv	s0,a0
ffffffffc0202bc4:	14050b63          	beqz	a0,ffffffffc0202d1a <get_pte+0x196>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202bc8:	0000fb97          	auipc	s7,0xf
ffffffffc0202bcc:	9d0b8b93          	addi	s7,s7,-1584 # ffffffffc0211598 <pages>
ffffffffc0202bd0:	000bb503          	ld	a0,0(s7)
ffffffffc0202bd4:	00003797          	auipc	a5,0x3
ffffffffc0202bd8:	84478793          	addi	a5,a5,-1980 # ffffffffc0205418 <commands+0xfa8>
ffffffffc0202bdc:	0007bb03          	ld	s6,0(a5)
ffffffffc0202be0:	40a40533          	sub	a0,s0,a0
ffffffffc0202be4:	850d                	srai	a0,a0,0x3
ffffffffc0202be6:	03650533          	mul	a0,a0,s6
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0202bea:	4785                	li	a5,1
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202bec:	0000f997          	auipc	s3,0xf
ffffffffc0202bf0:	88498993          	addi	s3,s3,-1916 # ffffffffc0211470 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202bf4:	00080ab7          	lui	s5,0x80
ffffffffc0202bf8:	0009b703          	ld	a4,0(s3)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0202bfc:	c01c                	sw	a5,0(s0)
ffffffffc0202bfe:	57fd                	li	a5,-1
ffffffffc0202c00:	83b1                	srli	a5,a5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202c02:	9556                	add	a0,a0,s5
ffffffffc0202c04:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0202c06:	0532                	slli	a0,a0,0xc
ffffffffc0202c08:	16e7f063          	bleu	a4,a5,ffffffffc0202d68 <get_pte+0x1e4>
ffffffffc0202c0c:	0000f797          	auipc	a5,0xf
ffffffffc0202c10:	97c78793          	addi	a5,a5,-1668 # ffffffffc0211588 <va_pa_offset>
ffffffffc0202c14:	639c                	ld	a5,0(a5)
ffffffffc0202c16:	6605                	lui	a2,0x1
ffffffffc0202c18:	4581                	li	a1,0
ffffffffc0202c1a:	953e                	add	a0,a0,a5
ffffffffc0202c1c:	22a010ef          	jal	ra,ffffffffc0203e46 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202c20:	000bb683          	ld	a3,0(s7)
ffffffffc0202c24:	40d406b3          	sub	a3,s0,a3
ffffffffc0202c28:	868d                	srai	a3,a3,0x3
ffffffffc0202c2a:	036686b3          	mul	a3,a3,s6
ffffffffc0202c2e:	96d6                	add	a3,a3,s5

static inline void flush_tlb() { asm volatile("sfence.vma"); }

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202c30:	06aa                	slli	a3,a3,0xa
ffffffffc0202c32:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0202c36:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0202c38:	77fd                	lui	a5,0xfffff
ffffffffc0202c3a:	068a                	slli	a3,a3,0x2
ffffffffc0202c3c:	0009b703          	ld	a4,0(s3)
ffffffffc0202c40:	8efd                	and	a3,a3,a5
ffffffffc0202c42:	00c6d793          	srli	a5,a3,0xc
ffffffffc0202c46:	0ce7fc63          	bleu	a4,a5,ffffffffc0202d1e <get_pte+0x19a>
ffffffffc0202c4a:	0000fa97          	auipc	s5,0xf
ffffffffc0202c4e:	93ea8a93          	addi	s5,s5,-1730 # ffffffffc0211588 <va_pa_offset>
ffffffffc0202c52:	000ab403          	ld	s0,0(s5)
ffffffffc0202c56:	01595793          	srli	a5,s2,0x15
ffffffffc0202c5a:	1ff7f793          	andi	a5,a5,511
ffffffffc0202c5e:	96a2                	add	a3,a3,s0
ffffffffc0202c60:	00379413          	slli	s0,a5,0x3
ffffffffc0202c64:	9436                	add	s0,s0,a3
//    pde_t *pdep0 = &((pde_t *)(PDE_ADDR(*pdep1)))[PDX0(la)];
    if (!(*pdep0 & PTE_V)) {
ffffffffc0202c66:	6014                	ld	a3,0(s0)
ffffffffc0202c68:	0016f793          	andi	a5,a3,1
ffffffffc0202c6c:	ebbd                	bnez	a5,ffffffffc0202ce2 <get_pte+0x15e>
    	struct Page *page;
    	if (!create || (page = alloc_page()) == NULL) {
ffffffffc0202c6e:	0a0a0663          	beqz	s4,ffffffffc0202d1a <get_pte+0x196>
ffffffffc0202c72:	4505                	li	a0,1
ffffffffc0202c74:	e03ff0ef          	jal	ra,ffffffffc0202a76 <alloc_pages>
ffffffffc0202c78:	84aa                	mv	s1,a0
ffffffffc0202c7a:	c145                	beqz	a0,ffffffffc0202d1a <get_pte+0x196>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202c7c:	0000fb97          	auipc	s7,0xf
ffffffffc0202c80:	91cb8b93          	addi	s7,s7,-1764 # ffffffffc0211598 <pages>
ffffffffc0202c84:	000bb503          	ld	a0,0(s7)
ffffffffc0202c88:	00002797          	auipc	a5,0x2
ffffffffc0202c8c:	79078793          	addi	a5,a5,1936 # ffffffffc0205418 <commands+0xfa8>
ffffffffc0202c90:	0007bb03          	ld	s6,0(a5)
ffffffffc0202c94:	40a48533          	sub	a0,s1,a0
ffffffffc0202c98:	850d                	srai	a0,a0,0x3
ffffffffc0202c9a:	03650533          	mul	a0,a0,s6
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0202c9e:	4785                	li	a5,1
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202ca0:	00080a37          	lui	s4,0x80
    		return NULL;
    	}
    	set_page_ref(page, 1);
    	uintptr_t pa = page2pa(page);
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202ca4:	0009b703          	ld	a4,0(s3)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0202ca8:	c09c                	sw	a5,0(s1)
ffffffffc0202caa:	57fd                	li	a5,-1
ffffffffc0202cac:	83b1                	srli	a5,a5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202cae:	9552                	add	a0,a0,s4
ffffffffc0202cb0:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0202cb2:	0532                	slli	a0,a0,0xc
ffffffffc0202cb4:	08e7fd63          	bleu	a4,a5,ffffffffc0202d4e <get_pte+0x1ca>
ffffffffc0202cb8:	000ab783          	ld	a5,0(s5)
ffffffffc0202cbc:	6605                	lui	a2,0x1
ffffffffc0202cbe:	4581                	li	a1,0
ffffffffc0202cc0:	953e                	add	a0,a0,a5
ffffffffc0202cc2:	184010ef          	jal	ra,ffffffffc0203e46 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202cc6:	000bb683          	ld	a3,0(s7)
ffffffffc0202cca:	40d486b3          	sub	a3,s1,a3
ffffffffc0202cce:	868d                	srai	a3,a3,0x3
ffffffffc0202cd0:	036686b3          	mul	a3,a3,s6
ffffffffc0202cd4:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202cd6:	06aa                	slli	a3,a3,0xa
ffffffffc0202cd8:	0116e693          	ori	a3,a3,17
 //   	memset(pa, 0, PGSIZE);
    	*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0202cdc:	e014                	sd	a3,0(s0)
ffffffffc0202cde:	0009b703          	ld	a4,0(s3)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202ce2:	068a                	slli	a3,a3,0x2
ffffffffc0202ce4:	757d                	lui	a0,0xfffff
ffffffffc0202ce6:	8ee9                	and	a3,a3,a0
ffffffffc0202ce8:	00c6d793          	srli	a5,a3,0xc
ffffffffc0202cec:	04e7f563          	bleu	a4,a5,ffffffffc0202d36 <get_pte+0x1b2>
ffffffffc0202cf0:	000ab503          	ld	a0,0(s5)
ffffffffc0202cf4:	00c95793          	srli	a5,s2,0xc
ffffffffc0202cf8:	1ff7f793          	andi	a5,a5,511
ffffffffc0202cfc:	96aa                	add	a3,a3,a0
ffffffffc0202cfe:	00379513          	slli	a0,a5,0x3
ffffffffc0202d02:	9536                	add	a0,a0,a3
}
ffffffffc0202d04:	60a6                	ld	ra,72(sp)
ffffffffc0202d06:	6406                	ld	s0,64(sp)
ffffffffc0202d08:	74e2                	ld	s1,56(sp)
ffffffffc0202d0a:	7942                	ld	s2,48(sp)
ffffffffc0202d0c:	79a2                	ld	s3,40(sp)
ffffffffc0202d0e:	7a02                	ld	s4,32(sp)
ffffffffc0202d10:	6ae2                	ld	s5,24(sp)
ffffffffc0202d12:	6b42                	ld	s6,16(sp)
ffffffffc0202d14:	6ba2                	ld	s7,8(sp)
ffffffffc0202d16:	6161                	addi	sp,sp,80
ffffffffc0202d18:	8082                	ret
            return NULL;
ffffffffc0202d1a:	4501                	li	a0,0
ffffffffc0202d1c:	b7e5                	j	ffffffffc0202d04 <get_pte+0x180>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0202d1e:	00003617          	auipc	a2,0x3
ffffffffc0202d22:	baa60613          	addi	a2,a2,-1110 # ffffffffc02058c8 <default_pmm_manager+0x158>
ffffffffc0202d26:	10200593          	li	a1,258
ffffffffc0202d2a:	00003517          	auipc	a0,0x3
ffffffffc0202d2e:	bc650513          	addi	a0,a0,-1082 # ffffffffc02058f0 <default_pmm_manager+0x180>
ffffffffc0202d32:	bd4fd0ef          	jal	ra,ffffffffc0200106 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202d36:	00003617          	auipc	a2,0x3
ffffffffc0202d3a:	b9260613          	addi	a2,a2,-1134 # ffffffffc02058c8 <default_pmm_manager+0x158>
ffffffffc0202d3e:	10f00593          	li	a1,271
ffffffffc0202d42:	00003517          	auipc	a0,0x3
ffffffffc0202d46:	bae50513          	addi	a0,a0,-1106 # ffffffffc02058f0 <default_pmm_manager+0x180>
ffffffffc0202d4a:	bbcfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202d4e:	86aa                	mv	a3,a0
ffffffffc0202d50:	00003617          	auipc	a2,0x3
ffffffffc0202d54:	b7860613          	addi	a2,a2,-1160 # ffffffffc02058c8 <default_pmm_manager+0x158>
ffffffffc0202d58:	10b00593          	li	a1,267
ffffffffc0202d5c:	00003517          	auipc	a0,0x3
ffffffffc0202d60:	b9450513          	addi	a0,a0,-1132 # ffffffffc02058f0 <default_pmm_manager+0x180>
ffffffffc0202d64:	ba2fd0ef          	jal	ra,ffffffffc0200106 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202d68:	86aa                	mv	a3,a0
ffffffffc0202d6a:	00003617          	auipc	a2,0x3
ffffffffc0202d6e:	b5e60613          	addi	a2,a2,-1186 # ffffffffc02058c8 <default_pmm_manager+0x158>
ffffffffc0202d72:	0ff00593          	li	a1,255
ffffffffc0202d76:	00003517          	auipc	a0,0x3
ffffffffc0202d7a:	b7a50513          	addi	a0,a0,-1158 # ffffffffc02058f0 <default_pmm_manager+0x180>
ffffffffc0202d7e:	b88fd0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0202d82 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0202d82:	1141                	addi	sp,sp,-16
ffffffffc0202d84:	e022                	sd	s0,0(sp)
ffffffffc0202d86:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202d88:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0202d8a:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202d8c:	df9ff0ef          	jal	ra,ffffffffc0202b84 <get_pte>
    if (ptep_store != NULL) {
ffffffffc0202d90:	c011                	beqz	s0,ffffffffc0202d94 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0202d92:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0202d94:	c521                	beqz	a0,ffffffffc0202ddc <get_page+0x5a>
ffffffffc0202d96:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0202d98:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0202d9a:	0017f713          	andi	a4,a5,1
ffffffffc0202d9e:	e709                	bnez	a4,ffffffffc0202da8 <get_page+0x26>
}
ffffffffc0202da0:	60a2                	ld	ra,8(sp)
ffffffffc0202da2:	6402                	ld	s0,0(sp)
ffffffffc0202da4:	0141                	addi	sp,sp,16
ffffffffc0202da6:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0202da8:	0000e717          	auipc	a4,0xe
ffffffffc0202dac:	6c870713          	addi	a4,a4,1736 # ffffffffc0211470 <npage>
ffffffffc0202db0:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202db2:	078a                	slli	a5,a5,0x2
ffffffffc0202db4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202db6:	02e7f863          	bleu	a4,a5,ffffffffc0202de6 <get_page+0x64>
    return &pages[PPN(pa) - nbase];
ffffffffc0202dba:	fff80537          	lui	a0,0xfff80
ffffffffc0202dbe:	97aa                	add	a5,a5,a0
ffffffffc0202dc0:	0000e697          	auipc	a3,0xe
ffffffffc0202dc4:	7d868693          	addi	a3,a3,2008 # ffffffffc0211598 <pages>
ffffffffc0202dc8:	6288                	ld	a0,0(a3)
ffffffffc0202dca:	60a2                	ld	ra,8(sp)
ffffffffc0202dcc:	6402                	ld	s0,0(sp)
ffffffffc0202dce:	00379713          	slli	a4,a5,0x3
ffffffffc0202dd2:	97ba                	add	a5,a5,a4
ffffffffc0202dd4:	078e                	slli	a5,a5,0x3
ffffffffc0202dd6:	953e                	add	a0,a0,a5
ffffffffc0202dd8:	0141                	addi	sp,sp,16
ffffffffc0202dda:	8082                	ret
ffffffffc0202ddc:	60a2                	ld	ra,8(sp)
ffffffffc0202dde:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc0202de0:	4501                	li	a0,0
}
ffffffffc0202de2:	0141                	addi	sp,sp,16
ffffffffc0202de4:	8082                	ret
ffffffffc0202de6:	c75ff0ef          	jal	ra,ffffffffc0202a5a <pa2page.part.4>

ffffffffc0202dea <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0202dea:	1141                	addi	sp,sp,-16
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202dec:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0202dee:	e406                	sd	ra,8(sp)
ffffffffc0202df0:	e022                	sd	s0,0(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202df2:	d93ff0ef          	jal	ra,ffffffffc0202b84 <get_pte>
    if (ptep != NULL) {
ffffffffc0202df6:	c511                	beqz	a0,ffffffffc0202e02 <page_remove+0x18>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0202df8:	611c                	ld	a5,0(a0)
ffffffffc0202dfa:	842a                	mv	s0,a0
ffffffffc0202dfc:	0017f713          	andi	a4,a5,1
ffffffffc0202e00:	e709                	bnez	a4,ffffffffc0202e0a <page_remove+0x20>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0202e02:	60a2                	ld	ra,8(sp)
ffffffffc0202e04:	6402                	ld	s0,0(sp)
ffffffffc0202e06:	0141                	addi	sp,sp,16
ffffffffc0202e08:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0202e0a:	0000e717          	auipc	a4,0xe
ffffffffc0202e0e:	66670713          	addi	a4,a4,1638 # ffffffffc0211470 <npage>
ffffffffc0202e12:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202e14:	078a                	slli	a5,a5,0x2
ffffffffc0202e16:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202e18:	04e7f063          	bleu	a4,a5,ffffffffc0202e58 <page_remove+0x6e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202e1c:	fff80737          	lui	a4,0xfff80
ffffffffc0202e20:	97ba                	add	a5,a5,a4
ffffffffc0202e22:	0000e717          	auipc	a4,0xe
ffffffffc0202e26:	77670713          	addi	a4,a4,1910 # ffffffffc0211598 <pages>
ffffffffc0202e2a:	6308                	ld	a0,0(a4)
ffffffffc0202e2c:	00379713          	slli	a4,a5,0x3
ffffffffc0202e30:	97ba                	add	a5,a5,a4
ffffffffc0202e32:	078e                	slli	a5,a5,0x3
ffffffffc0202e34:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0202e36:	411c                	lw	a5,0(a0)
ffffffffc0202e38:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202e3c:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0202e3e:	cb09                	beqz	a4,ffffffffc0202e50 <page_remove+0x66>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0202e40:	00043023          	sd	zero,0(s0)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0202e44:	12000073          	sfence.vma
}
ffffffffc0202e48:	60a2                	ld	ra,8(sp)
ffffffffc0202e4a:	6402                	ld	s0,0(sp)
ffffffffc0202e4c:	0141                	addi	sp,sp,16
ffffffffc0202e4e:	8082                	ret
            free_page(page);
ffffffffc0202e50:	4585                	li	a1,1
ffffffffc0202e52:	cadff0ef          	jal	ra,ffffffffc0202afe <free_pages>
ffffffffc0202e56:	b7ed                	j	ffffffffc0202e40 <page_remove+0x56>
ffffffffc0202e58:	c03ff0ef          	jal	ra,ffffffffc0202a5a <pa2page.part.4>

ffffffffc0202e5c <page_insert>:
//  page:  the Page which need to map
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
// note: PT is changed, so the TLB need to be invalidate
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202e5c:	7179                	addi	sp,sp,-48
ffffffffc0202e5e:	87b2                	mv	a5,a2
ffffffffc0202e60:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202e62:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202e64:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202e66:	85be                	mv	a1,a5
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202e68:	ec26                	sd	s1,24(sp)
ffffffffc0202e6a:	f406                	sd	ra,40(sp)
ffffffffc0202e6c:	e84a                	sd	s2,16(sp)
ffffffffc0202e6e:	e44e                	sd	s3,8(sp)
ffffffffc0202e70:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202e72:	d13ff0ef          	jal	ra,ffffffffc0202b84 <get_pte>
    if (ptep == NULL) {
ffffffffc0202e76:	c945                	beqz	a0,ffffffffc0202f26 <page_insert+0xca>
    page->ref += 1;
ffffffffc0202e78:	4014                	lw	a3,0(s0)
        return -E_NO_MEM;
    }
    page_ref_inc(page);
    if (*ptep & PTE_V) {
ffffffffc0202e7a:	611c                	ld	a5,0(a0)
ffffffffc0202e7c:	892a                	mv	s2,a0
ffffffffc0202e7e:	0016871b          	addiw	a4,a3,1
ffffffffc0202e82:	c018                	sw	a4,0(s0)
ffffffffc0202e84:	0017f713          	andi	a4,a5,1
ffffffffc0202e88:	e339                	bnez	a4,ffffffffc0202ece <page_insert+0x72>
ffffffffc0202e8a:	0000e797          	auipc	a5,0xe
ffffffffc0202e8e:	70e78793          	addi	a5,a5,1806 # ffffffffc0211598 <pages>
ffffffffc0202e92:	639c                	ld	a5,0(a5)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202e94:	00002717          	auipc	a4,0x2
ffffffffc0202e98:	58470713          	addi	a4,a4,1412 # ffffffffc0205418 <commands+0xfa8>
ffffffffc0202e9c:	40f407b3          	sub	a5,s0,a5
ffffffffc0202ea0:	6300                	ld	s0,0(a4)
ffffffffc0202ea2:	878d                	srai	a5,a5,0x3
ffffffffc0202ea4:	000806b7          	lui	a3,0x80
ffffffffc0202ea8:	028787b3          	mul	a5,a5,s0
ffffffffc0202eac:	97b6                	add	a5,a5,a3
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202eae:	07aa                	slli	a5,a5,0xa
ffffffffc0202eb0:	8fc5                	or	a5,a5,s1
ffffffffc0202eb2:	0017e793          	ori	a5,a5,1
            page_ref_dec(page);
        } else {
            page_remove_pte(pgdir, la, ptep);
        }
    }
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0202eb6:	00f93023          	sd	a5,0(s2)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0202eba:	12000073          	sfence.vma
    tlb_invalidate(pgdir, la);
    return 0;
ffffffffc0202ebe:	4501                	li	a0,0
}
ffffffffc0202ec0:	70a2                	ld	ra,40(sp)
ffffffffc0202ec2:	7402                	ld	s0,32(sp)
ffffffffc0202ec4:	64e2                	ld	s1,24(sp)
ffffffffc0202ec6:	6942                	ld	s2,16(sp)
ffffffffc0202ec8:	69a2                	ld	s3,8(sp)
ffffffffc0202eca:	6145                	addi	sp,sp,48
ffffffffc0202ecc:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0202ece:	0000e717          	auipc	a4,0xe
ffffffffc0202ed2:	5a270713          	addi	a4,a4,1442 # ffffffffc0211470 <npage>
ffffffffc0202ed6:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202ed8:	00279513          	slli	a0,a5,0x2
ffffffffc0202edc:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202ede:	04e57663          	bleu	a4,a0,ffffffffc0202f2a <page_insert+0xce>
    return &pages[PPN(pa) - nbase];
ffffffffc0202ee2:	fff807b7          	lui	a5,0xfff80
ffffffffc0202ee6:	953e                	add	a0,a0,a5
ffffffffc0202ee8:	0000e997          	auipc	s3,0xe
ffffffffc0202eec:	6b098993          	addi	s3,s3,1712 # ffffffffc0211598 <pages>
ffffffffc0202ef0:	0009b783          	ld	a5,0(s3)
ffffffffc0202ef4:	00351713          	slli	a4,a0,0x3
ffffffffc0202ef8:	953a                	add	a0,a0,a4
ffffffffc0202efa:	050e                	slli	a0,a0,0x3
ffffffffc0202efc:	953e                	add	a0,a0,a5
        if (p == page) {
ffffffffc0202efe:	00a40e63          	beq	s0,a0,ffffffffc0202f1a <page_insert+0xbe>
    page->ref -= 1;
ffffffffc0202f02:	411c                	lw	a5,0(a0)
ffffffffc0202f04:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202f08:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0202f0a:	cb11                	beqz	a4,ffffffffc0202f1e <page_insert+0xc2>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0202f0c:	00093023          	sd	zero,0(s2)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0202f10:	12000073          	sfence.vma
ffffffffc0202f14:	0009b783          	ld	a5,0(s3)
ffffffffc0202f18:	bfb5                	j	ffffffffc0202e94 <page_insert+0x38>
    page->ref -= 1;
ffffffffc0202f1a:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0202f1c:	bfa5                	j	ffffffffc0202e94 <page_insert+0x38>
            free_page(page);
ffffffffc0202f1e:	4585                	li	a1,1
ffffffffc0202f20:	bdfff0ef          	jal	ra,ffffffffc0202afe <free_pages>
ffffffffc0202f24:	b7e5                	j	ffffffffc0202f0c <page_insert+0xb0>
        return -E_NO_MEM;
ffffffffc0202f26:	5571                	li	a0,-4
ffffffffc0202f28:	bf61                	j	ffffffffc0202ec0 <page_insert+0x64>
ffffffffc0202f2a:	b31ff0ef          	jal	ra,ffffffffc0202a5a <pa2page.part.4>

ffffffffc0202f2e <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0202f2e:	00003797          	auipc	a5,0x3
ffffffffc0202f32:	84278793          	addi	a5,a5,-1982 # ffffffffc0205770 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202f36:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0202f38:	711d                	addi	sp,sp,-96
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202f3a:	00003517          	auipc	a0,0x3
ffffffffc0202f3e:	a1e50513          	addi	a0,a0,-1506 # ffffffffc0205958 <default_pmm_manager+0x1e8>
void pmm_init(void) {
ffffffffc0202f42:	ec86                	sd	ra,88(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0202f44:	0000e717          	auipc	a4,0xe
ffffffffc0202f48:	62f73e23          	sd	a5,1596(a4) # ffffffffc0211580 <pmm_manager>
void pmm_init(void) {
ffffffffc0202f4c:	e8a2                	sd	s0,80(sp)
ffffffffc0202f4e:	e4a6                	sd	s1,72(sp)
ffffffffc0202f50:	e0ca                	sd	s2,64(sp)
ffffffffc0202f52:	fc4e                	sd	s3,56(sp)
ffffffffc0202f54:	f852                	sd	s4,48(sp)
ffffffffc0202f56:	f456                	sd	s5,40(sp)
ffffffffc0202f58:	f05a                	sd	s6,32(sp)
ffffffffc0202f5a:	ec5e                	sd	s7,24(sp)
ffffffffc0202f5c:	e862                	sd	s8,16(sp)
ffffffffc0202f5e:	e466                	sd	s9,8(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0202f60:	0000e417          	auipc	s0,0xe
ffffffffc0202f64:	62040413          	addi	s0,s0,1568 # ffffffffc0211580 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202f68:	956fd0ef          	jal	ra,ffffffffc02000be <cprintf>
    pmm_manager->init();
ffffffffc0202f6c:	601c                	ld	a5,0(s0)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0202f6e:	49c5                	li	s3,17
ffffffffc0202f70:	40100a13          	li	s4,1025
    pmm_manager->init();
ffffffffc0202f74:	679c                	ld	a5,8(a5)
ffffffffc0202f76:	0000e497          	auipc	s1,0xe
ffffffffc0202f7a:	4fa48493          	addi	s1,s1,1274 # ffffffffc0211470 <npage>
ffffffffc0202f7e:	0000e917          	auipc	s2,0xe
ffffffffc0202f82:	61a90913          	addi	s2,s2,1562 # ffffffffc0211598 <pages>
ffffffffc0202f86:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202f88:	57f5                	li	a5,-3
ffffffffc0202f8a:	07fa                	slli	a5,a5,0x1e
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0202f8c:	07e006b7          	lui	a3,0x7e00
ffffffffc0202f90:	01b99613          	slli	a2,s3,0x1b
ffffffffc0202f94:	015a1593          	slli	a1,s4,0x15
ffffffffc0202f98:	00003517          	auipc	a0,0x3
ffffffffc0202f9c:	9d850513          	addi	a0,a0,-1576 # ffffffffc0205970 <default_pmm_manager+0x200>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202fa0:	0000e717          	auipc	a4,0xe
ffffffffc0202fa4:	5ef73423          	sd	a5,1512(a4) # ffffffffc0211588 <va_pa_offset>
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0202fa8:	916fd0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("physcial memory map:\n");
ffffffffc0202fac:	00003517          	auipc	a0,0x3
ffffffffc0202fb0:	9f450513          	addi	a0,a0,-1548 # ffffffffc02059a0 <default_pmm_manager+0x230>
ffffffffc0202fb4:	90afd0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0202fb8:	01b99693          	slli	a3,s3,0x1b
ffffffffc0202fbc:	16fd                	addi	a3,a3,-1
ffffffffc0202fbe:	015a1613          	slli	a2,s4,0x15
ffffffffc0202fc2:	07e005b7          	lui	a1,0x7e00
ffffffffc0202fc6:	00003517          	auipc	a0,0x3
ffffffffc0202fca:	9f250513          	addi	a0,a0,-1550 # ffffffffc02059b8 <default_pmm_manager+0x248>
ffffffffc0202fce:	8f0fd0ef          	jal	ra,ffffffffc02000be <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202fd2:	777d                	lui	a4,0xfffff
ffffffffc0202fd4:	0000f797          	auipc	a5,0xf
ffffffffc0202fd8:	5cb78793          	addi	a5,a5,1483 # ffffffffc021259f <end+0xfff>
ffffffffc0202fdc:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0202fde:	00088737          	lui	a4,0x88
ffffffffc0202fe2:	0000e697          	auipc	a3,0xe
ffffffffc0202fe6:	48e6b723          	sd	a4,1166(a3) # ffffffffc0211470 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202fea:	0000e717          	auipc	a4,0xe
ffffffffc0202fee:	5af73723          	sd	a5,1454(a4) # ffffffffc0211598 <pages>
ffffffffc0202ff2:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0202ff4:	4701                	li	a4,0
ffffffffc0202ff6:	4585                	li	a1,1
ffffffffc0202ff8:	fff80637          	lui	a2,0xfff80
ffffffffc0202ffc:	a019                	j	ffffffffc0203002 <pmm_init+0xd4>
ffffffffc0202ffe:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc0203002:	97b6                	add	a5,a5,a3
ffffffffc0203004:	07a1                	addi	a5,a5,8
ffffffffc0203006:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020300a:	609c                	ld	a5,0(s1)
ffffffffc020300c:	0705                	addi	a4,a4,1
ffffffffc020300e:	04868693          	addi	a3,a3,72
ffffffffc0203012:	00c78533          	add	a0,a5,a2
ffffffffc0203016:	fea764e3          	bltu	a4,a0,ffffffffc0202ffe <pmm_init+0xd0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020301a:	00093503          	ld	a0,0(s2)
ffffffffc020301e:	00379693          	slli	a3,a5,0x3
ffffffffc0203022:	96be                	add	a3,a3,a5
ffffffffc0203024:	fdc00737          	lui	a4,0xfdc00
ffffffffc0203028:	972a                	add	a4,a4,a0
ffffffffc020302a:	068e                	slli	a3,a3,0x3
ffffffffc020302c:	96ba                	add	a3,a3,a4
ffffffffc020302e:	c0200737          	lui	a4,0xc0200
ffffffffc0203032:	58e6ea63          	bltu	a3,a4,ffffffffc02035c6 <pmm_init+0x698>
ffffffffc0203036:	0000e997          	auipc	s3,0xe
ffffffffc020303a:	55298993          	addi	s3,s3,1362 # ffffffffc0211588 <va_pa_offset>
ffffffffc020303e:	0009b703          	ld	a4,0(s3)
    if (freemem < mem_end) {
ffffffffc0203042:	45c5                	li	a1,17
ffffffffc0203044:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203046:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0203048:	44b6ef63          	bltu	a3,a1,ffffffffc02034a6 <pmm_init+0x578>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc020304c:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc020304e:	0000e417          	auipc	s0,0xe
ffffffffc0203052:	41a40413          	addi	s0,s0,1050 # ffffffffc0211468 <boot_pgdir>
    pmm_manager->check();
ffffffffc0203056:	7b9c                	ld	a5,48(a5)
ffffffffc0203058:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc020305a:	00003517          	auipc	a0,0x3
ffffffffc020305e:	9ae50513          	addi	a0,a0,-1618 # ffffffffc0205a08 <default_pmm_manager+0x298>
ffffffffc0203062:	85cfd0ef          	jal	ra,ffffffffc02000be <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0203066:	00006697          	auipc	a3,0x6
ffffffffc020306a:	f9a68693          	addi	a3,a3,-102 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc020306e:	0000e797          	auipc	a5,0xe
ffffffffc0203072:	3ed7bd23          	sd	a3,1018(a5) # ffffffffc0211468 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0203076:	c02007b7          	lui	a5,0xc0200
ffffffffc020307a:	0ef6ece3          	bltu	a3,a5,ffffffffc0203972 <pmm_init+0xa44>
ffffffffc020307e:	0009b783          	ld	a5,0(s3)
ffffffffc0203082:	8e9d                	sub	a3,a3,a5
ffffffffc0203084:	0000e797          	auipc	a5,0xe
ffffffffc0203088:	50d7b623          	sd	a3,1292(a5) # ffffffffc0211590 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc020308c:	ab9ff0ef          	jal	ra,ffffffffc0202b44 <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0203090:	6098                	ld	a4,0(s1)
ffffffffc0203092:	c80007b7          	lui	a5,0xc8000
ffffffffc0203096:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc0203098:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020309a:	0ae7ece3          	bltu	a5,a4,ffffffffc0203952 <pmm_init+0xa24>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc020309e:	6008                	ld	a0,0(s0)
ffffffffc02030a0:	4c050363          	beqz	a0,ffffffffc0203566 <pmm_init+0x638>
ffffffffc02030a4:	6785                	lui	a5,0x1
ffffffffc02030a6:	17fd                	addi	a5,a5,-1
ffffffffc02030a8:	8fe9                	and	a5,a5,a0
ffffffffc02030aa:	2781                	sext.w	a5,a5
ffffffffc02030ac:	4a079d63          	bnez	a5,ffffffffc0203566 <pmm_init+0x638>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02030b0:	4601                	li	a2,0
ffffffffc02030b2:	4581                	li	a1,0
ffffffffc02030b4:	ccfff0ef          	jal	ra,ffffffffc0202d82 <get_page>
ffffffffc02030b8:	4c051763          	bnez	a0,ffffffffc0203586 <pmm_init+0x658>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc02030bc:	4505                	li	a0,1
ffffffffc02030be:	9b9ff0ef          	jal	ra,ffffffffc0202a76 <alloc_pages>
ffffffffc02030c2:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02030c4:	6008                	ld	a0,0(s0)
ffffffffc02030c6:	4681                	li	a3,0
ffffffffc02030c8:	4601                	li	a2,0
ffffffffc02030ca:	85d6                	mv	a1,s5
ffffffffc02030cc:	d91ff0ef          	jal	ra,ffffffffc0202e5c <page_insert>
ffffffffc02030d0:	52051763          	bnez	a0,ffffffffc02035fe <pmm_init+0x6d0>
    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02030d4:	6008                	ld	a0,0(s0)
ffffffffc02030d6:	4601                	li	a2,0
ffffffffc02030d8:	4581                	li	a1,0
ffffffffc02030da:	aabff0ef          	jal	ra,ffffffffc0202b84 <get_pte>
ffffffffc02030de:	50050063          	beqz	a0,ffffffffc02035de <pmm_init+0x6b0>
    assert(pte2page(*ptep) == p1);
ffffffffc02030e2:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02030e4:	0017f713          	andi	a4,a5,1
ffffffffc02030e8:	46070363          	beqz	a4,ffffffffc020354e <pmm_init+0x620>
    if (PPN(pa) >= npage) {
ffffffffc02030ec:	6090                	ld	a2,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02030ee:	078a                	slli	a5,a5,0x2
ffffffffc02030f0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02030f2:	44c7f063          	bleu	a2,a5,ffffffffc0203532 <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc02030f6:	fff80737          	lui	a4,0xfff80
ffffffffc02030fa:	97ba                	add	a5,a5,a4
ffffffffc02030fc:	00379713          	slli	a4,a5,0x3
ffffffffc0203100:	00093683          	ld	a3,0(s2)
ffffffffc0203104:	97ba                	add	a5,a5,a4
ffffffffc0203106:	078e                	slli	a5,a5,0x3
ffffffffc0203108:	97b6                	add	a5,a5,a3
ffffffffc020310a:	5efa9463          	bne	s5,a5,ffffffffc02036f2 <pmm_init+0x7c4>
    assert(page_ref(p1) == 1);
ffffffffc020310e:	000aab83          	lw	s7,0(s5)
ffffffffc0203112:	4785                	li	a5,1
ffffffffc0203114:	5afb9f63          	bne	s7,a5,ffffffffc02036d2 <pmm_init+0x7a4>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0203118:	6008                	ld	a0,0(s0)
ffffffffc020311a:	76fd                	lui	a3,0xfffff
ffffffffc020311c:	611c                	ld	a5,0(a0)
ffffffffc020311e:	078a                	slli	a5,a5,0x2
ffffffffc0203120:	8ff5                	and	a5,a5,a3
ffffffffc0203122:	00c7d713          	srli	a4,a5,0xc
ffffffffc0203126:	58c77963          	bleu	a2,a4,ffffffffc02036b8 <pmm_init+0x78a>
ffffffffc020312a:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020312e:	97e2                	add	a5,a5,s8
ffffffffc0203130:	0007bb03          	ld	s6,0(a5) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc0203134:	0b0a                	slli	s6,s6,0x2
ffffffffc0203136:	00db7b33          	and	s6,s6,a3
ffffffffc020313a:	00cb5793          	srli	a5,s6,0xc
ffffffffc020313e:	56c7f063          	bleu	a2,a5,ffffffffc020369e <pmm_init+0x770>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0203142:	4601                	li	a2,0
ffffffffc0203144:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203146:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0203148:	a3dff0ef          	jal	ra,ffffffffc0202b84 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020314c:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020314e:	53651863          	bne	a0,s6,ffffffffc020367e <pmm_init+0x750>

    p2 = alloc_page();
ffffffffc0203152:	4505                	li	a0,1
ffffffffc0203154:	923ff0ef          	jal	ra,ffffffffc0202a76 <alloc_pages>
ffffffffc0203158:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc020315a:	6008                	ld	a0,0(s0)
ffffffffc020315c:	46d1                	li	a3,20
ffffffffc020315e:	6605                	lui	a2,0x1
ffffffffc0203160:	85da                	mv	a1,s6
ffffffffc0203162:	cfbff0ef          	jal	ra,ffffffffc0202e5c <page_insert>
ffffffffc0203166:	4e051c63          	bnez	a0,ffffffffc020365e <pmm_init+0x730>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020316a:	6008                	ld	a0,0(s0)
ffffffffc020316c:	4601                	li	a2,0
ffffffffc020316e:	6585                	lui	a1,0x1
ffffffffc0203170:	a15ff0ef          	jal	ra,ffffffffc0202b84 <get_pte>
ffffffffc0203174:	4c050563          	beqz	a0,ffffffffc020363e <pmm_init+0x710>
    assert(*ptep & PTE_U);
ffffffffc0203178:	611c                	ld	a5,0(a0)
ffffffffc020317a:	0107f713          	andi	a4,a5,16
ffffffffc020317e:	4a070063          	beqz	a4,ffffffffc020361e <pmm_init+0x6f0>
    assert(*ptep & PTE_W);
ffffffffc0203182:	8b91                	andi	a5,a5,4
ffffffffc0203184:	66078763          	beqz	a5,ffffffffc02037f2 <pmm_init+0x8c4>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0203188:	6008                	ld	a0,0(s0)
ffffffffc020318a:	611c                	ld	a5,0(a0)
ffffffffc020318c:	8bc1                	andi	a5,a5,16
ffffffffc020318e:	64078263          	beqz	a5,ffffffffc02037d2 <pmm_init+0x8a4>
    assert(page_ref(p2) == 1);
ffffffffc0203192:	000b2783          	lw	a5,0(s6)
ffffffffc0203196:	61779e63          	bne	a5,s7,ffffffffc02037b2 <pmm_init+0x884>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc020319a:	4681                	li	a3,0
ffffffffc020319c:	6605                	lui	a2,0x1
ffffffffc020319e:	85d6                	mv	a1,s5
ffffffffc02031a0:	cbdff0ef          	jal	ra,ffffffffc0202e5c <page_insert>
ffffffffc02031a4:	5e051763          	bnez	a0,ffffffffc0203792 <pmm_init+0x864>
    assert(page_ref(p1) == 2);
ffffffffc02031a8:	000aa703          	lw	a4,0(s5)
ffffffffc02031ac:	4789                	li	a5,2
ffffffffc02031ae:	5cf71263          	bne	a4,a5,ffffffffc0203772 <pmm_init+0x844>
    assert(page_ref(p2) == 0);
ffffffffc02031b2:	000b2783          	lw	a5,0(s6)
ffffffffc02031b6:	58079e63          	bnez	a5,ffffffffc0203752 <pmm_init+0x824>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02031ba:	6008                	ld	a0,0(s0)
ffffffffc02031bc:	4601                	li	a2,0
ffffffffc02031be:	6585                	lui	a1,0x1
ffffffffc02031c0:	9c5ff0ef          	jal	ra,ffffffffc0202b84 <get_pte>
ffffffffc02031c4:	56050763          	beqz	a0,ffffffffc0203732 <pmm_init+0x804>
    assert(pte2page(*ptep) == p1);
ffffffffc02031c8:	6114                	ld	a3,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02031ca:	0016f793          	andi	a5,a3,1
ffffffffc02031ce:	38078063          	beqz	a5,ffffffffc020354e <pmm_init+0x620>
    if (PPN(pa) >= npage) {
ffffffffc02031d2:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02031d4:	00269793          	slli	a5,a3,0x2
ffffffffc02031d8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02031da:	34e7fc63          	bleu	a4,a5,ffffffffc0203532 <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc02031de:	fff80737          	lui	a4,0xfff80
ffffffffc02031e2:	97ba                	add	a5,a5,a4
ffffffffc02031e4:	00379713          	slli	a4,a5,0x3
ffffffffc02031e8:	00093603          	ld	a2,0(s2)
ffffffffc02031ec:	97ba                	add	a5,a5,a4
ffffffffc02031ee:	078e                	slli	a5,a5,0x3
ffffffffc02031f0:	97b2                	add	a5,a5,a2
ffffffffc02031f2:	52fa9063          	bne	s5,a5,ffffffffc0203712 <pmm_init+0x7e4>
    assert((*ptep & PTE_U) == 0);
ffffffffc02031f6:	8ac1                	andi	a3,a3,16
ffffffffc02031f8:	6e069d63          	bnez	a3,ffffffffc02038f2 <pmm_init+0x9c4>

    page_remove(boot_pgdir, 0x0);
ffffffffc02031fc:	6008                	ld	a0,0(s0)
ffffffffc02031fe:	4581                	li	a1,0
ffffffffc0203200:	bebff0ef          	jal	ra,ffffffffc0202dea <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0203204:	000aa703          	lw	a4,0(s5)
ffffffffc0203208:	4785                	li	a5,1
ffffffffc020320a:	6cf71463          	bne	a4,a5,ffffffffc02038d2 <pmm_init+0x9a4>
    assert(page_ref(p2) == 0);
ffffffffc020320e:	000b2783          	lw	a5,0(s6)
ffffffffc0203212:	6a079063          	bnez	a5,ffffffffc02038b2 <pmm_init+0x984>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0203216:	6008                	ld	a0,0(s0)
ffffffffc0203218:	6585                	lui	a1,0x1
ffffffffc020321a:	bd1ff0ef          	jal	ra,ffffffffc0202dea <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc020321e:	000aa783          	lw	a5,0(s5)
ffffffffc0203222:	66079863          	bnez	a5,ffffffffc0203892 <pmm_init+0x964>
    assert(page_ref(p2) == 0);
ffffffffc0203226:	000b2783          	lw	a5,0(s6)
ffffffffc020322a:	70079463          	bnez	a5,ffffffffc0203932 <pmm_init+0xa04>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc020322e:	00043b03          	ld	s6,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0203232:	608c                	ld	a1,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203234:	000b3783          	ld	a5,0(s6)
ffffffffc0203238:	078a                	slli	a5,a5,0x2
ffffffffc020323a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020323c:	2eb7fb63          	bleu	a1,a5,ffffffffc0203532 <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0203240:	fff80737          	lui	a4,0xfff80
ffffffffc0203244:	973e                	add	a4,a4,a5
ffffffffc0203246:	00371793          	slli	a5,a4,0x3
ffffffffc020324a:	00093603          	ld	a2,0(s2)
ffffffffc020324e:	97ba                	add	a5,a5,a4
ffffffffc0203250:	078e                	slli	a5,a5,0x3
ffffffffc0203252:	00f60733          	add	a4,a2,a5
ffffffffc0203256:	4314                	lw	a3,0(a4)
ffffffffc0203258:	4705                	li	a4,1
ffffffffc020325a:	6ae69c63          	bne	a3,a4,ffffffffc0203912 <pmm_init+0x9e4>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020325e:	00002a97          	auipc	s5,0x2
ffffffffc0203262:	1baa8a93          	addi	s5,s5,442 # ffffffffc0205418 <commands+0xfa8>
ffffffffc0203266:	000ab703          	ld	a4,0(s5)
ffffffffc020326a:	4037d693          	srai	a3,a5,0x3
ffffffffc020326e:	00080bb7          	lui	s7,0x80
ffffffffc0203272:	02e686b3          	mul	a3,a3,a4
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203276:	577d                	li	a4,-1
ffffffffc0203278:	8331                	srli	a4,a4,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020327a:	96de                	add	a3,a3,s7
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020327c:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc020327e:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203280:	2ab77b63          	bleu	a1,a4,ffffffffc0203536 <pmm_init+0x608>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0203284:	0009b783          	ld	a5,0(s3)
ffffffffc0203288:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc020328a:	629c                	ld	a5,0(a3)
ffffffffc020328c:	078a                	slli	a5,a5,0x2
ffffffffc020328e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203290:	2ab7f163          	bleu	a1,a5,ffffffffc0203532 <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0203294:	417787b3          	sub	a5,a5,s7
ffffffffc0203298:	00379513          	slli	a0,a5,0x3
ffffffffc020329c:	97aa                	add	a5,a5,a0
ffffffffc020329e:	00379513          	slli	a0,a5,0x3
ffffffffc02032a2:	9532                	add	a0,a0,a2
ffffffffc02032a4:	4585                	li	a1,1
ffffffffc02032a6:	859ff0ef          	jal	ra,ffffffffc0202afe <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02032aa:	000b3503          	ld	a0,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc02032ae:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02032b0:	050a                	slli	a0,a0,0x2
ffffffffc02032b2:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc02032b4:	26f57f63          	bleu	a5,a0,ffffffffc0203532 <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc02032b8:	417507b3          	sub	a5,a0,s7
ffffffffc02032bc:	00379513          	slli	a0,a5,0x3
ffffffffc02032c0:	00093703          	ld	a4,0(s2)
ffffffffc02032c4:	953e                	add	a0,a0,a5
ffffffffc02032c6:	050e                	slli	a0,a0,0x3
    free_page(pde2page(pd1[0]));
ffffffffc02032c8:	4585                	li	a1,1
ffffffffc02032ca:	953a                	add	a0,a0,a4
ffffffffc02032cc:	833ff0ef          	jal	ra,ffffffffc0202afe <free_pages>
    boot_pgdir[0] = 0;
ffffffffc02032d0:	601c                	ld	a5,0(s0)
ffffffffc02032d2:	0007b023          	sd	zero,0(a5)

    assert(nr_free_store==nr_free_pages());
ffffffffc02032d6:	86fff0ef          	jal	ra,ffffffffc0202b44 <nr_free_pages>
ffffffffc02032da:	2caa1663          	bne	s4,a0,ffffffffc02035a6 <pmm_init+0x678>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc02032de:	00003517          	auipc	a0,0x3
ffffffffc02032e2:	a1250513          	addi	a0,a0,-1518 # ffffffffc0205cf0 <default_pmm_manager+0x580>
ffffffffc02032e6:	dd9fc0ef          	jal	ra,ffffffffc02000be <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc02032ea:	85bff0ef          	jal	ra,ffffffffc0202b44 <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02032ee:	6098                	ld	a4,0(s1)
ffffffffc02032f0:	c02007b7          	lui	a5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc02032f4:	8b2a                	mv	s6,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02032f6:	00c71693          	slli	a3,a4,0xc
ffffffffc02032fa:	1cd7fd63          	bleu	a3,a5,ffffffffc02034d4 <pmm_init+0x5a6>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02032fe:	83b1                	srli	a5,a5,0xc
ffffffffc0203300:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0203302:	c0200a37          	lui	s4,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0203306:	1ce7f963          	bleu	a4,a5,ffffffffc02034d8 <pmm_init+0x5aa>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020330a:	7c7d                	lui	s8,0xfffff
ffffffffc020330c:	6b85                	lui	s7,0x1
ffffffffc020330e:	a029                	j	ffffffffc0203318 <pmm_init+0x3ea>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0203310:	00ca5713          	srli	a4,s4,0xc
ffffffffc0203314:	1cf77263          	bleu	a5,a4,ffffffffc02034d8 <pmm_init+0x5aa>
ffffffffc0203318:	0009b583          	ld	a1,0(s3)
ffffffffc020331c:	4601                	li	a2,0
ffffffffc020331e:	95d2                	add	a1,a1,s4
ffffffffc0203320:	865ff0ef          	jal	ra,ffffffffc0202b84 <get_pte>
ffffffffc0203324:	1c050763          	beqz	a0,ffffffffc02034f2 <pmm_init+0x5c4>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0203328:	611c                	ld	a5,0(a0)
ffffffffc020332a:	078a                	slli	a5,a5,0x2
ffffffffc020332c:	0187f7b3          	and	a5,a5,s8
ffffffffc0203330:	1f479163          	bne	a5,s4,ffffffffc0203512 <pmm_init+0x5e4>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0203334:	609c                	ld	a5,0(s1)
ffffffffc0203336:	9a5e                	add	s4,s4,s7
ffffffffc0203338:	6008                	ld	a0,0(s0)
ffffffffc020333a:	00c79713          	slli	a4,a5,0xc
ffffffffc020333e:	fcea69e3          	bltu	s4,a4,ffffffffc0203310 <pmm_init+0x3e2>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0203342:	611c                	ld	a5,0(a0)
ffffffffc0203344:	6a079363          	bnez	a5,ffffffffc02039ea <pmm_init+0xabc>

    struct Page *p;
    p = alloc_page();
ffffffffc0203348:	4505                	li	a0,1
ffffffffc020334a:	f2cff0ef          	jal	ra,ffffffffc0202a76 <alloc_pages>
ffffffffc020334e:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0203350:	6008                	ld	a0,0(s0)
ffffffffc0203352:	4699                	li	a3,6
ffffffffc0203354:	10000613          	li	a2,256
ffffffffc0203358:	85d2                	mv	a1,s4
ffffffffc020335a:	b03ff0ef          	jal	ra,ffffffffc0202e5c <page_insert>
ffffffffc020335e:	66051663          	bnez	a0,ffffffffc02039ca <pmm_init+0xa9c>
    assert(page_ref(p) == 1);
ffffffffc0203362:	000a2703          	lw	a4,0(s4) # ffffffffc0200000 <kern_entry>
ffffffffc0203366:	4785                	li	a5,1
ffffffffc0203368:	64f71163          	bne	a4,a5,ffffffffc02039aa <pmm_init+0xa7c>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc020336c:	6008                	ld	a0,0(s0)
ffffffffc020336e:	6b85                	lui	s7,0x1
ffffffffc0203370:	4699                	li	a3,6
ffffffffc0203372:	100b8613          	addi	a2,s7,256 # 1100 <BASE_ADDRESS-0xffffffffc01fef00>
ffffffffc0203376:	85d2                	mv	a1,s4
ffffffffc0203378:	ae5ff0ef          	jal	ra,ffffffffc0202e5c <page_insert>
ffffffffc020337c:	60051763          	bnez	a0,ffffffffc020398a <pmm_init+0xa5c>
    assert(page_ref(p) == 2);
ffffffffc0203380:	000a2703          	lw	a4,0(s4)
ffffffffc0203384:	4789                	li	a5,2
ffffffffc0203386:	4ef71663          	bne	a4,a5,ffffffffc0203872 <pmm_init+0x944>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc020338a:	00003597          	auipc	a1,0x3
ffffffffc020338e:	a9e58593          	addi	a1,a1,-1378 # ffffffffc0205e28 <default_pmm_manager+0x6b8>
ffffffffc0203392:	10000513          	li	a0,256
ffffffffc0203396:	257000ef          	jal	ra,ffffffffc0203dec <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc020339a:	100b8593          	addi	a1,s7,256
ffffffffc020339e:	10000513          	li	a0,256
ffffffffc02033a2:	25d000ef          	jal	ra,ffffffffc0203dfe <strcmp>
ffffffffc02033a6:	4a051663          	bnez	a0,ffffffffc0203852 <pmm_init+0x924>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02033aa:	00093683          	ld	a3,0(s2)
ffffffffc02033ae:	000abc83          	ld	s9,0(s5)
ffffffffc02033b2:	00080c37          	lui	s8,0x80
ffffffffc02033b6:	40da06b3          	sub	a3,s4,a3
ffffffffc02033ba:	868d                	srai	a3,a3,0x3
ffffffffc02033bc:	039686b3          	mul	a3,a3,s9
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02033c0:	5afd                	li	s5,-1
ffffffffc02033c2:	609c                	ld	a5,0(s1)
ffffffffc02033c4:	00cada93          	srli	s5,s5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02033c8:	96e2                	add	a3,a3,s8
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02033ca:	0156f733          	and	a4,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc02033ce:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02033d0:	16f77363          	bleu	a5,a4,ffffffffc0203536 <pmm_init+0x608>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc02033d4:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc02033d8:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc02033dc:	96be                	add	a3,a3,a5
ffffffffc02033de:	10068023          	sb	zero,256(a3) # fffffffffffff100 <end+0x3fdedb60>
    assert(strlen((const char *)0x100) == 0);
ffffffffc02033e2:	1c7000ef          	jal	ra,ffffffffc0203da8 <strlen>
ffffffffc02033e6:	44051663          	bnez	a0,ffffffffc0203832 <pmm_init+0x904>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc02033ea:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc02033ee:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02033f0:	000bb783          	ld	a5,0(s7)
ffffffffc02033f4:	078a                	slli	a5,a5,0x2
ffffffffc02033f6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02033f8:	12e7fd63          	bleu	a4,a5,ffffffffc0203532 <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc02033fc:	418787b3          	sub	a5,a5,s8
ffffffffc0203400:	00379693          	slli	a3,a5,0x3
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203404:	96be                	add	a3,a3,a5
ffffffffc0203406:	039686b3          	mul	a3,a3,s9
ffffffffc020340a:	96e2                	add	a3,a3,s8
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020340c:	0156fab3          	and	s5,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc0203410:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203412:	12eaf263          	bleu	a4,s5,ffffffffc0203536 <pmm_init+0x608>
ffffffffc0203416:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc020341a:	4585                	li	a1,1
ffffffffc020341c:	8552                	mv	a0,s4
ffffffffc020341e:	99b6                	add	s3,s3,a3
ffffffffc0203420:	edeff0ef          	jal	ra,ffffffffc0202afe <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203424:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0203428:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020342a:	078a                	slli	a5,a5,0x2
ffffffffc020342c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020342e:	10e7f263          	bleu	a4,a5,ffffffffc0203532 <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0203432:	fff809b7          	lui	s3,0xfff80
ffffffffc0203436:	97ce                	add	a5,a5,s3
ffffffffc0203438:	00379513          	slli	a0,a5,0x3
ffffffffc020343c:	00093703          	ld	a4,0(s2)
ffffffffc0203440:	97aa                	add	a5,a5,a0
ffffffffc0203442:	00379513          	slli	a0,a5,0x3
    free_page(pde2page(pd0[0]));
ffffffffc0203446:	953a                	add	a0,a0,a4
ffffffffc0203448:	4585                	li	a1,1
ffffffffc020344a:	eb4ff0ef          	jal	ra,ffffffffc0202afe <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc020344e:	000bb503          	ld	a0,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc0203452:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203454:	050a                	slli	a0,a0,0x2
ffffffffc0203456:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203458:	0cf57d63          	bleu	a5,a0,ffffffffc0203532 <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc020345c:	013507b3          	add	a5,a0,s3
ffffffffc0203460:	00379513          	slli	a0,a5,0x3
ffffffffc0203464:	00093703          	ld	a4,0(s2)
ffffffffc0203468:	953e                	add	a0,a0,a5
ffffffffc020346a:	050e                	slli	a0,a0,0x3
    free_page(pde2page(pd1[0]));
ffffffffc020346c:	4585                	li	a1,1
ffffffffc020346e:	953a                	add	a0,a0,a4
ffffffffc0203470:	e8eff0ef          	jal	ra,ffffffffc0202afe <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0203474:	601c                	ld	a5,0(s0)
ffffffffc0203476:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>

    assert(nr_free_store==nr_free_pages());
ffffffffc020347a:	ecaff0ef          	jal	ra,ffffffffc0202b44 <nr_free_pages>
ffffffffc020347e:	38ab1a63          	bne	s6,a0,ffffffffc0203812 <pmm_init+0x8e4>
}
ffffffffc0203482:	6446                	ld	s0,80(sp)
ffffffffc0203484:	60e6                	ld	ra,88(sp)
ffffffffc0203486:	64a6                	ld	s1,72(sp)
ffffffffc0203488:	6906                	ld	s2,64(sp)
ffffffffc020348a:	79e2                	ld	s3,56(sp)
ffffffffc020348c:	7a42                	ld	s4,48(sp)
ffffffffc020348e:	7aa2                	ld	s5,40(sp)
ffffffffc0203490:	7b02                	ld	s6,32(sp)
ffffffffc0203492:	6be2                	ld	s7,24(sp)
ffffffffc0203494:	6c42                	ld	s8,16(sp)
ffffffffc0203496:	6ca2                	ld	s9,8(sp)

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0203498:	00003517          	auipc	a0,0x3
ffffffffc020349c:	a0850513          	addi	a0,a0,-1528 # ffffffffc0205ea0 <default_pmm_manager+0x730>
}
ffffffffc02034a0:	6125                	addi	sp,sp,96
    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02034a2:	c1dfc06f          	j	ffffffffc02000be <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02034a6:	6705                	lui	a4,0x1
ffffffffc02034a8:	177d                	addi	a4,a4,-1
ffffffffc02034aa:	96ba                	add	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc02034ac:	00c6d713          	srli	a4,a3,0xc
ffffffffc02034b0:	08f77163          	bleu	a5,a4,ffffffffc0203532 <pmm_init+0x604>
    pmm_manager->init_memmap(base, n);
ffffffffc02034b4:	00043803          	ld	a6,0(s0)
    return &pages[PPN(pa) - nbase];
ffffffffc02034b8:	9732                	add	a4,a4,a2
ffffffffc02034ba:	00371793          	slli	a5,a4,0x3
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02034be:	767d                	lui	a2,0xfffff
ffffffffc02034c0:	8ef1                	and	a3,a3,a2
ffffffffc02034c2:	97ba                	add	a5,a5,a4
    pmm_manager->init_memmap(base, n);
ffffffffc02034c4:	01083703          	ld	a4,16(a6)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02034c8:	8d95                	sub	a1,a1,a3
ffffffffc02034ca:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02034cc:	81b1                	srli	a1,a1,0xc
ffffffffc02034ce:	953e                	add	a0,a0,a5
ffffffffc02034d0:	9702                	jalr	a4
ffffffffc02034d2:	bead                	j	ffffffffc020304c <pmm_init+0x11e>
ffffffffc02034d4:	6008                	ld	a0,0(s0)
ffffffffc02034d6:	b5b5                	j	ffffffffc0203342 <pmm_init+0x414>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02034d8:	86d2                	mv	a3,s4
ffffffffc02034da:	00002617          	auipc	a2,0x2
ffffffffc02034de:	3ee60613          	addi	a2,a2,1006 # ffffffffc02058c8 <default_pmm_manager+0x158>
ffffffffc02034e2:	1cd00593          	li	a1,461
ffffffffc02034e6:	00002517          	auipc	a0,0x2
ffffffffc02034ea:	40a50513          	addi	a0,a0,1034 # ffffffffc02058f0 <default_pmm_manager+0x180>
ffffffffc02034ee:	c19fc0ef          	jal	ra,ffffffffc0200106 <__panic>
ffffffffc02034f2:	00003697          	auipc	a3,0x3
ffffffffc02034f6:	81e68693          	addi	a3,a3,-2018 # ffffffffc0205d10 <default_pmm_manager+0x5a0>
ffffffffc02034fa:	00001617          	auipc	a2,0x1
ffffffffc02034fe:	7ce60613          	addi	a2,a2,1998 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0203502:	1cd00593          	li	a1,461
ffffffffc0203506:	00002517          	auipc	a0,0x2
ffffffffc020350a:	3ea50513          	addi	a0,a0,1002 # ffffffffc02058f0 <default_pmm_manager+0x180>
ffffffffc020350e:	bf9fc0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0203512:	00003697          	auipc	a3,0x3
ffffffffc0203516:	83e68693          	addi	a3,a3,-1986 # ffffffffc0205d50 <default_pmm_manager+0x5e0>
ffffffffc020351a:	00001617          	auipc	a2,0x1
ffffffffc020351e:	7ae60613          	addi	a2,a2,1966 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0203522:	1ce00593          	li	a1,462
ffffffffc0203526:	00002517          	auipc	a0,0x2
ffffffffc020352a:	3ca50513          	addi	a0,a0,970 # ffffffffc02058f0 <default_pmm_manager+0x180>
ffffffffc020352e:	bd9fc0ef          	jal	ra,ffffffffc0200106 <__panic>
ffffffffc0203532:	d28ff0ef          	jal	ra,ffffffffc0202a5a <pa2page.part.4>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203536:	00002617          	auipc	a2,0x2
ffffffffc020353a:	39260613          	addi	a2,a2,914 # ffffffffc02058c8 <default_pmm_manager+0x158>
ffffffffc020353e:	06a00593          	li	a1,106
ffffffffc0203542:	00002517          	auipc	a0,0x2
ffffffffc0203546:	aae50513          	addi	a0,a0,-1362 # ffffffffc0204ff0 <commands+0xb80>
ffffffffc020354a:	bbdfc0ef          	jal	ra,ffffffffc0200106 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc020354e:	00002617          	auipc	a2,0x2
ffffffffc0203552:	d6a60613          	addi	a2,a2,-662 # ffffffffc02052b8 <commands+0xe48>
ffffffffc0203556:	07000593          	li	a1,112
ffffffffc020355a:	00002517          	auipc	a0,0x2
ffffffffc020355e:	a9650513          	addi	a0,a0,-1386 # ffffffffc0204ff0 <commands+0xb80>
ffffffffc0203562:	ba5fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0203566:	00002697          	auipc	a3,0x2
ffffffffc020356a:	4e268693          	addi	a3,a3,1250 # ffffffffc0205a48 <default_pmm_manager+0x2d8>
ffffffffc020356e:	00001617          	auipc	a2,0x1
ffffffffc0203572:	75a60613          	addi	a2,a2,1882 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0203576:	19300593          	li	a1,403
ffffffffc020357a:	00002517          	auipc	a0,0x2
ffffffffc020357e:	37650513          	addi	a0,a0,886 # ffffffffc02058f0 <default_pmm_manager+0x180>
ffffffffc0203582:	b85fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0203586:	00002697          	auipc	a3,0x2
ffffffffc020358a:	4fa68693          	addi	a3,a3,1274 # ffffffffc0205a80 <default_pmm_manager+0x310>
ffffffffc020358e:	00001617          	auipc	a2,0x1
ffffffffc0203592:	73a60613          	addi	a2,a2,1850 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0203596:	19400593          	li	a1,404
ffffffffc020359a:	00002517          	auipc	a0,0x2
ffffffffc020359e:	35650513          	addi	a0,a0,854 # ffffffffc02058f0 <default_pmm_manager+0x180>
ffffffffc02035a2:	b65fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02035a6:	00002697          	auipc	a3,0x2
ffffffffc02035aa:	72a68693          	addi	a3,a3,1834 # ffffffffc0205cd0 <default_pmm_manager+0x560>
ffffffffc02035ae:	00001617          	auipc	a2,0x1
ffffffffc02035b2:	71a60613          	addi	a2,a2,1818 # ffffffffc0204cc8 <commands+0x858>
ffffffffc02035b6:	1c000593          	li	a1,448
ffffffffc02035ba:	00002517          	auipc	a0,0x2
ffffffffc02035be:	33650513          	addi	a0,a0,822 # ffffffffc02058f0 <default_pmm_manager+0x180>
ffffffffc02035c2:	b45fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02035c6:	00002617          	auipc	a2,0x2
ffffffffc02035ca:	41a60613          	addi	a2,a2,1050 # ffffffffc02059e0 <default_pmm_manager+0x270>
ffffffffc02035ce:	07700593          	li	a1,119
ffffffffc02035d2:	00002517          	auipc	a0,0x2
ffffffffc02035d6:	31e50513          	addi	a0,a0,798 # ffffffffc02058f0 <default_pmm_manager+0x180>
ffffffffc02035da:	b2dfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02035de:	00002697          	auipc	a3,0x2
ffffffffc02035e2:	4fa68693          	addi	a3,a3,1274 # ffffffffc0205ad8 <default_pmm_manager+0x368>
ffffffffc02035e6:	00001617          	auipc	a2,0x1
ffffffffc02035ea:	6e260613          	addi	a2,a2,1762 # ffffffffc0204cc8 <commands+0x858>
ffffffffc02035ee:	19a00593          	li	a1,410
ffffffffc02035f2:	00002517          	auipc	a0,0x2
ffffffffc02035f6:	2fe50513          	addi	a0,a0,766 # ffffffffc02058f0 <default_pmm_manager+0x180>
ffffffffc02035fa:	b0dfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02035fe:	00002697          	auipc	a3,0x2
ffffffffc0203602:	4aa68693          	addi	a3,a3,1194 # ffffffffc0205aa8 <default_pmm_manager+0x338>
ffffffffc0203606:	00001617          	auipc	a2,0x1
ffffffffc020360a:	6c260613          	addi	a2,a2,1730 # ffffffffc0204cc8 <commands+0x858>
ffffffffc020360e:	19800593          	li	a1,408
ffffffffc0203612:	00002517          	auipc	a0,0x2
ffffffffc0203616:	2de50513          	addi	a0,a0,734 # ffffffffc02058f0 <default_pmm_manager+0x180>
ffffffffc020361a:	aedfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(*ptep & PTE_U);
ffffffffc020361e:	00002697          	auipc	a3,0x2
ffffffffc0203622:	5aa68693          	addi	a3,a3,1450 # ffffffffc0205bc8 <default_pmm_manager+0x458>
ffffffffc0203626:	00001617          	auipc	a2,0x1
ffffffffc020362a:	6a260613          	addi	a2,a2,1698 # ffffffffc0204cc8 <commands+0x858>
ffffffffc020362e:	1a500593          	li	a1,421
ffffffffc0203632:	00002517          	auipc	a0,0x2
ffffffffc0203636:	2be50513          	addi	a0,a0,702 # ffffffffc02058f0 <default_pmm_manager+0x180>
ffffffffc020363a:	acdfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020363e:	00002697          	auipc	a3,0x2
ffffffffc0203642:	55a68693          	addi	a3,a3,1370 # ffffffffc0205b98 <default_pmm_manager+0x428>
ffffffffc0203646:	00001617          	auipc	a2,0x1
ffffffffc020364a:	68260613          	addi	a2,a2,1666 # ffffffffc0204cc8 <commands+0x858>
ffffffffc020364e:	1a400593          	li	a1,420
ffffffffc0203652:	00002517          	auipc	a0,0x2
ffffffffc0203656:	29e50513          	addi	a0,a0,670 # ffffffffc02058f0 <default_pmm_manager+0x180>
ffffffffc020365a:	aadfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc020365e:	00002697          	auipc	a3,0x2
ffffffffc0203662:	50268693          	addi	a3,a3,1282 # ffffffffc0205b60 <default_pmm_manager+0x3f0>
ffffffffc0203666:	00001617          	auipc	a2,0x1
ffffffffc020366a:	66260613          	addi	a2,a2,1634 # ffffffffc0204cc8 <commands+0x858>
ffffffffc020366e:	1a300593          	li	a1,419
ffffffffc0203672:	00002517          	auipc	a0,0x2
ffffffffc0203676:	27e50513          	addi	a0,a0,638 # ffffffffc02058f0 <default_pmm_manager+0x180>
ffffffffc020367a:	a8dfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020367e:	00002697          	auipc	a3,0x2
ffffffffc0203682:	4ba68693          	addi	a3,a3,1210 # ffffffffc0205b38 <default_pmm_manager+0x3c8>
ffffffffc0203686:	00001617          	auipc	a2,0x1
ffffffffc020368a:	64260613          	addi	a2,a2,1602 # ffffffffc0204cc8 <commands+0x858>
ffffffffc020368e:	1a000593          	li	a1,416
ffffffffc0203692:	00002517          	auipc	a0,0x2
ffffffffc0203696:	25e50513          	addi	a0,a0,606 # ffffffffc02058f0 <default_pmm_manager+0x180>
ffffffffc020369a:	a6dfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020369e:	86da                	mv	a3,s6
ffffffffc02036a0:	00002617          	auipc	a2,0x2
ffffffffc02036a4:	22860613          	addi	a2,a2,552 # ffffffffc02058c8 <default_pmm_manager+0x158>
ffffffffc02036a8:	19f00593          	li	a1,415
ffffffffc02036ac:	00002517          	auipc	a0,0x2
ffffffffc02036b0:	24450513          	addi	a0,a0,580 # ffffffffc02058f0 <default_pmm_manager+0x180>
ffffffffc02036b4:	a53fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc02036b8:	86be                	mv	a3,a5
ffffffffc02036ba:	00002617          	auipc	a2,0x2
ffffffffc02036be:	20e60613          	addi	a2,a2,526 # ffffffffc02058c8 <default_pmm_manager+0x158>
ffffffffc02036c2:	19e00593          	li	a1,414
ffffffffc02036c6:	00002517          	auipc	a0,0x2
ffffffffc02036ca:	22a50513          	addi	a0,a0,554 # ffffffffc02058f0 <default_pmm_manager+0x180>
ffffffffc02036ce:	a39fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02036d2:	00002697          	auipc	a3,0x2
ffffffffc02036d6:	44e68693          	addi	a3,a3,1102 # ffffffffc0205b20 <default_pmm_manager+0x3b0>
ffffffffc02036da:	00001617          	auipc	a2,0x1
ffffffffc02036de:	5ee60613          	addi	a2,a2,1518 # ffffffffc0204cc8 <commands+0x858>
ffffffffc02036e2:	19c00593          	li	a1,412
ffffffffc02036e6:	00002517          	auipc	a0,0x2
ffffffffc02036ea:	20a50513          	addi	a0,a0,522 # ffffffffc02058f0 <default_pmm_manager+0x180>
ffffffffc02036ee:	a19fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02036f2:	00002697          	auipc	a3,0x2
ffffffffc02036f6:	41668693          	addi	a3,a3,1046 # ffffffffc0205b08 <default_pmm_manager+0x398>
ffffffffc02036fa:	00001617          	auipc	a2,0x1
ffffffffc02036fe:	5ce60613          	addi	a2,a2,1486 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0203702:	19b00593          	li	a1,411
ffffffffc0203706:	00002517          	auipc	a0,0x2
ffffffffc020370a:	1ea50513          	addi	a0,a0,490 # ffffffffc02058f0 <default_pmm_manager+0x180>
ffffffffc020370e:	9f9fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203712:	00002697          	auipc	a3,0x2
ffffffffc0203716:	3f668693          	addi	a3,a3,1014 # ffffffffc0205b08 <default_pmm_manager+0x398>
ffffffffc020371a:	00001617          	auipc	a2,0x1
ffffffffc020371e:	5ae60613          	addi	a2,a2,1454 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0203722:	1ae00593          	li	a1,430
ffffffffc0203726:	00002517          	auipc	a0,0x2
ffffffffc020372a:	1ca50513          	addi	a0,a0,458 # ffffffffc02058f0 <default_pmm_manager+0x180>
ffffffffc020372e:	9d9fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0203732:	00002697          	auipc	a3,0x2
ffffffffc0203736:	46668693          	addi	a3,a3,1126 # ffffffffc0205b98 <default_pmm_manager+0x428>
ffffffffc020373a:	00001617          	auipc	a2,0x1
ffffffffc020373e:	58e60613          	addi	a2,a2,1422 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0203742:	1ad00593          	li	a1,429
ffffffffc0203746:	00002517          	auipc	a0,0x2
ffffffffc020374a:	1aa50513          	addi	a0,a0,426 # ffffffffc02058f0 <default_pmm_manager+0x180>
ffffffffc020374e:	9b9fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203752:	00002697          	auipc	a3,0x2
ffffffffc0203756:	50e68693          	addi	a3,a3,1294 # ffffffffc0205c60 <default_pmm_manager+0x4f0>
ffffffffc020375a:	00001617          	auipc	a2,0x1
ffffffffc020375e:	56e60613          	addi	a2,a2,1390 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0203762:	1ac00593          	li	a1,428
ffffffffc0203766:	00002517          	auipc	a0,0x2
ffffffffc020376a:	18a50513          	addi	a0,a0,394 # ffffffffc02058f0 <default_pmm_manager+0x180>
ffffffffc020376e:	999fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0203772:	00002697          	auipc	a3,0x2
ffffffffc0203776:	4d668693          	addi	a3,a3,1238 # ffffffffc0205c48 <default_pmm_manager+0x4d8>
ffffffffc020377a:	00001617          	auipc	a2,0x1
ffffffffc020377e:	54e60613          	addi	a2,a2,1358 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0203782:	1ab00593          	li	a1,427
ffffffffc0203786:	00002517          	auipc	a0,0x2
ffffffffc020378a:	16a50513          	addi	a0,a0,362 # ffffffffc02058f0 <default_pmm_manager+0x180>
ffffffffc020378e:	979fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0203792:	00002697          	auipc	a3,0x2
ffffffffc0203796:	48668693          	addi	a3,a3,1158 # ffffffffc0205c18 <default_pmm_manager+0x4a8>
ffffffffc020379a:	00001617          	auipc	a2,0x1
ffffffffc020379e:	52e60613          	addi	a2,a2,1326 # ffffffffc0204cc8 <commands+0x858>
ffffffffc02037a2:	1aa00593          	li	a1,426
ffffffffc02037a6:	00002517          	auipc	a0,0x2
ffffffffc02037aa:	14a50513          	addi	a0,a0,330 # ffffffffc02058f0 <default_pmm_manager+0x180>
ffffffffc02037ae:	959fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc02037b2:	00002697          	auipc	a3,0x2
ffffffffc02037b6:	44e68693          	addi	a3,a3,1102 # ffffffffc0205c00 <default_pmm_manager+0x490>
ffffffffc02037ba:	00001617          	auipc	a2,0x1
ffffffffc02037be:	50e60613          	addi	a2,a2,1294 # ffffffffc0204cc8 <commands+0x858>
ffffffffc02037c2:	1a800593          	li	a1,424
ffffffffc02037c6:	00002517          	auipc	a0,0x2
ffffffffc02037ca:	12a50513          	addi	a0,a0,298 # ffffffffc02058f0 <default_pmm_manager+0x180>
ffffffffc02037ce:	939fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02037d2:	00002697          	auipc	a3,0x2
ffffffffc02037d6:	41668693          	addi	a3,a3,1046 # ffffffffc0205be8 <default_pmm_manager+0x478>
ffffffffc02037da:	00001617          	auipc	a2,0x1
ffffffffc02037de:	4ee60613          	addi	a2,a2,1262 # ffffffffc0204cc8 <commands+0x858>
ffffffffc02037e2:	1a700593          	li	a1,423
ffffffffc02037e6:	00002517          	auipc	a0,0x2
ffffffffc02037ea:	10a50513          	addi	a0,a0,266 # ffffffffc02058f0 <default_pmm_manager+0x180>
ffffffffc02037ee:	919fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(*ptep & PTE_W);
ffffffffc02037f2:	00002697          	auipc	a3,0x2
ffffffffc02037f6:	3e668693          	addi	a3,a3,998 # ffffffffc0205bd8 <default_pmm_manager+0x468>
ffffffffc02037fa:	00001617          	auipc	a2,0x1
ffffffffc02037fe:	4ce60613          	addi	a2,a2,1230 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0203802:	1a600593          	li	a1,422
ffffffffc0203806:	00002517          	auipc	a0,0x2
ffffffffc020380a:	0ea50513          	addi	a0,a0,234 # ffffffffc02058f0 <default_pmm_manager+0x180>
ffffffffc020380e:	8f9fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0203812:	00002697          	auipc	a3,0x2
ffffffffc0203816:	4be68693          	addi	a3,a3,1214 # ffffffffc0205cd0 <default_pmm_manager+0x560>
ffffffffc020381a:	00001617          	auipc	a2,0x1
ffffffffc020381e:	4ae60613          	addi	a2,a2,1198 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0203822:	1e800593          	li	a1,488
ffffffffc0203826:	00002517          	auipc	a0,0x2
ffffffffc020382a:	0ca50513          	addi	a0,a0,202 # ffffffffc02058f0 <default_pmm_manager+0x180>
ffffffffc020382e:	8d9fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203832:	00002697          	auipc	a3,0x2
ffffffffc0203836:	64668693          	addi	a3,a3,1606 # ffffffffc0205e78 <default_pmm_manager+0x708>
ffffffffc020383a:	00001617          	auipc	a2,0x1
ffffffffc020383e:	48e60613          	addi	a2,a2,1166 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0203842:	1e000593          	li	a1,480
ffffffffc0203846:	00002517          	auipc	a0,0x2
ffffffffc020384a:	0aa50513          	addi	a0,a0,170 # ffffffffc02058f0 <default_pmm_manager+0x180>
ffffffffc020384e:	8b9fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0203852:	00002697          	auipc	a3,0x2
ffffffffc0203856:	5ee68693          	addi	a3,a3,1518 # ffffffffc0205e40 <default_pmm_manager+0x6d0>
ffffffffc020385a:	00001617          	auipc	a2,0x1
ffffffffc020385e:	46e60613          	addi	a2,a2,1134 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0203862:	1dd00593          	li	a1,477
ffffffffc0203866:	00002517          	auipc	a0,0x2
ffffffffc020386a:	08a50513          	addi	a0,a0,138 # ffffffffc02058f0 <default_pmm_manager+0x180>
ffffffffc020386e:	899fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0203872:	00002697          	auipc	a3,0x2
ffffffffc0203876:	59e68693          	addi	a3,a3,1438 # ffffffffc0205e10 <default_pmm_manager+0x6a0>
ffffffffc020387a:	00001617          	auipc	a2,0x1
ffffffffc020387e:	44e60613          	addi	a2,a2,1102 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0203882:	1d900593          	li	a1,473
ffffffffc0203886:	00002517          	auipc	a0,0x2
ffffffffc020388a:	06a50513          	addi	a0,a0,106 # ffffffffc02058f0 <default_pmm_manager+0x180>
ffffffffc020388e:	879fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0203892:	00002697          	auipc	a3,0x2
ffffffffc0203896:	3fe68693          	addi	a3,a3,1022 # ffffffffc0205c90 <default_pmm_manager+0x520>
ffffffffc020389a:	00001617          	auipc	a2,0x1
ffffffffc020389e:	42e60613          	addi	a2,a2,1070 # ffffffffc0204cc8 <commands+0x858>
ffffffffc02038a2:	1b600593          	li	a1,438
ffffffffc02038a6:	00002517          	auipc	a0,0x2
ffffffffc02038aa:	04a50513          	addi	a0,a0,74 # ffffffffc02058f0 <default_pmm_manager+0x180>
ffffffffc02038ae:	859fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02038b2:	00002697          	auipc	a3,0x2
ffffffffc02038b6:	3ae68693          	addi	a3,a3,942 # ffffffffc0205c60 <default_pmm_manager+0x4f0>
ffffffffc02038ba:	00001617          	auipc	a2,0x1
ffffffffc02038be:	40e60613          	addi	a2,a2,1038 # ffffffffc0204cc8 <commands+0x858>
ffffffffc02038c2:	1b300593          	li	a1,435
ffffffffc02038c6:	00002517          	auipc	a0,0x2
ffffffffc02038ca:	02a50513          	addi	a0,a0,42 # ffffffffc02058f0 <default_pmm_manager+0x180>
ffffffffc02038ce:	839fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02038d2:	00002697          	auipc	a3,0x2
ffffffffc02038d6:	24e68693          	addi	a3,a3,590 # ffffffffc0205b20 <default_pmm_manager+0x3b0>
ffffffffc02038da:	00001617          	auipc	a2,0x1
ffffffffc02038de:	3ee60613          	addi	a2,a2,1006 # ffffffffc0204cc8 <commands+0x858>
ffffffffc02038e2:	1b200593          	li	a1,434
ffffffffc02038e6:	00002517          	auipc	a0,0x2
ffffffffc02038ea:	00a50513          	addi	a0,a0,10 # ffffffffc02058f0 <default_pmm_manager+0x180>
ffffffffc02038ee:	819fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc02038f2:	00002697          	auipc	a3,0x2
ffffffffc02038f6:	38668693          	addi	a3,a3,902 # ffffffffc0205c78 <default_pmm_manager+0x508>
ffffffffc02038fa:	00001617          	auipc	a2,0x1
ffffffffc02038fe:	3ce60613          	addi	a2,a2,974 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0203902:	1af00593          	li	a1,431
ffffffffc0203906:	00002517          	auipc	a0,0x2
ffffffffc020390a:	fea50513          	addi	a0,a0,-22 # ffffffffc02058f0 <default_pmm_manager+0x180>
ffffffffc020390e:	ff8fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0203912:	00002697          	auipc	a3,0x2
ffffffffc0203916:	39668693          	addi	a3,a3,918 # ffffffffc0205ca8 <default_pmm_manager+0x538>
ffffffffc020391a:	00001617          	auipc	a2,0x1
ffffffffc020391e:	3ae60613          	addi	a2,a2,942 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0203922:	1b900593          	li	a1,441
ffffffffc0203926:	00002517          	auipc	a0,0x2
ffffffffc020392a:	fca50513          	addi	a0,a0,-54 # ffffffffc02058f0 <default_pmm_manager+0x180>
ffffffffc020392e:	fd8fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203932:	00002697          	auipc	a3,0x2
ffffffffc0203936:	32e68693          	addi	a3,a3,814 # ffffffffc0205c60 <default_pmm_manager+0x4f0>
ffffffffc020393a:	00001617          	auipc	a2,0x1
ffffffffc020393e:	38e60613          	addi	a2,a2,910 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0203942:	1b700593          	li	a1,439
ffffffffc0203946:	00002517          	auipc	a0,0x2
ffffffffc020394a:	faa50513          	addi	a0,a0,-86 # ffffffffc02058f0 <default_pmm_manager+0x180>
ffffffffc020394e:	fb8fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0203952:	00002697          	auipc	a3,0x2
ffffffffc0203956:	0d668693          	addi	a3,a3,214 # ffffffffc0205a28 <default_pmm_manager+0x2b8>
ffffffffc020395a:	00001617          	auipc	a2,0x1
ffffffffc020395e:	36e60613          	addi	a2,a2,878 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0203962:	19200593          	li	a1,402
ffffffffc0203966:	00002517          	auipc	a0,0x2
ffffffffc020396a:	f8a50513          	addi	a0,a0,-118 # ffffffffc02058f0 <default_pmm_manager+0x180>
ffffffffc020396e:	f98fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0203972:	00002617          	auipc	a2,0x2
ffffffffc0203976:	06e60613          	addi	a2,a2,110 # ffffffffc02059e0 <default_pmm_manager+0x270>
ffffffffc020397a:	0bd00593          	li	a1,189
ffffffffc020397e:	00002517          	auipc	a0,0x2
ffffffffc0203982:	f7250513          	addi	a0,a0,-142 # ffffffffc02058f0 <default_pmm_manager+0x180>
ffffffffc0203986:	f80fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc020398a:	00002697          	auipc	a3,0x2
ffffffffc020398e:	44668693          	addi	a3,a3,1094 # ffffffffc0205dd0 <default_pmm_manager+0x660>
ffffffffc0203992:	00001617          	auipc	a2,0x1
ffffffffc0203996:	33660613          	addi	a2,a2,822 # ffffffffc0204cc8 <commands+0x858>
ffffffffc020399a:	1d800593          	li	a1,472
ffffffffc020399e:	00002517          	auipc	a0,0x2
ffffffffc02039a2:	f5250513          	addi	a0,a0,-174 # ffffffffc02058f0 <default_pmm_manager+0x180>
ffffffffc02039a6:	f60fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p) == 1);
ffffffffc02039aa:	00002697          	auipc	a3,0x2
ffffffffc02039ae:	40e68693          	addi	a3,a3,1038 # ffffffffc0205db8 <default_pmm_manager+0x648>
ffffffffc02039b2:	00001617          	auipc	a2,0x1
ffffffffc02039b6:	31660613          	addi	a2,a2,790 # ffffffffc0204cc8 <commands+0x858>
ffffffffc02039ba:	1d700593          	li	a1,471
ffffffffc02039be:	00002517          	auipc	a0,0x2
ffffffffc02039c2:	f3250513          	addi	a0,a0,-206 # ffffffffc02058f0 <default_pmm_manager+0x180>
ffffffffc02039c6:	f40fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02039ca:	00002697          	auipc	a3,0x2
ffffffffc02039ce:	3b668693          	addi	a3,a3,950 # ffffffffc0205d80 <default_pmm_manager+0x610>
ffffffffc02039d2:	00001617          	auipc	a2,0x1
ffffffffc02039d6:	2f660613          	addi	a2,a2,758 # ffffffffc0204cc8 <commands+0x858>
ffffffffc02039da:	1d600593          	li	a1,470
ffffffffc02039de:	00002517          	auipc	a0,0x2
ffffffffc02039e2:	f1250513          	addi	a0,a0,-238 # ffffffffc02058f0 <default_pmm_manager+0x180>
ffffffffc02039e6:	f20fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc02039ea:	00002697          	auipc	a3,0x2
ffffffffc02039ee:	37e68693          	addi	a3,a3,894 # ffffffffc0205d68 <default_pmm_manager+0x5f8>
ffffffffc02039f2:	00001617          	auipc	a2,0x1
ffffffffc02039f6:	2d660613          	addi	a2,a2,726 # ffffffffc0204cc8 <commands+0x858>
ffffffffc02039fa:	1d200593          	li	a1,466
ffffffffc02039fe:	00002517          	auipc	a0,0x2
ffffffffc0203a02:	ef250513          	addi	a0,a0,-270 # ffffffffc02058f0 <default_pmm_manager+0x180>
ffffffffc0203a06:	f00fc0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0203a0a <tlb_invalidate>:
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0203a0a:	12000073          	sfence.vma
void tlb_invalidate(pde_t *pgdir, uintptr_t la) { flush_tlb(); }
ffffffffc0203a0e:	8082                	ret

ffffffffc0203a10 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0203a10:	7179                	addi	sp,sp,-48
ffffffffc0203a12:	e84a                	sd	s2,16(sp)
ffffffffc0203a14:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0203a16:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0203a18:	f022                	sd	s0,32(sp)
ffffffffc0203a1a:	ec26                	sd	s1,24(sp)
ffffffffc0203a1c:	e44e                	sd	s3,8(sp)
ffffffffc0203a1e:	f406                	sd	ra,40(sp)
ffffffffc0203a20:	84ae                	mv	s1,a1
ffffffffc0203a22:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0203a24:	852ff0ef          	jal	ra,ffffffffc0202a76 <alloc_pages>
ffffffffc0203a28:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0203a2a:	cd19                	beqz	a0,ffffffffc0203a48 <pgdir_alloc_page+0x38>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0203a2c:	85aa                	mv	a1,a0
ffffffffc0203a2e:	86ce                	mv	a3,s3
ffffffffc0203a30:	8626                	mv	a2,s1
ffffffffc0203a32:	854a                	mv	a0,s2
ffffffffc0203a34:	c28ff0ef          	jal	ra,ffffffffc0202e5c <page_insert>
ffffffffc0203a38:	ed39                	bnez	a0,ffffffffc0203a96 <pgdir_alloc_page+0x86>
        if (swap_init_ok) {
ffffffffc0203a3a:	0000e797          	auipc	a5,0xe
ffffffffc0203a3e:	a2678793          	addi	a5,a5,-1498 # ffffffffc0211460 <swap_init_ok>
ffffffffc0203a42:	439c                	lw	a5,0(a5)
ffffffffc0203a44:	2781                	sext.w	a5,a5
ffffffffc0203a46:	eb89                	bnez	a5,ffffffffc0203a58 <pgdir_alloc_page+0x48>
}
ffffffffc0203a48:	8522                	mv	a0,s0
ffffffffc0203a4a:	70a2                	ld	ra,40(sp)
ffffffffc0203a4c:	7402                	ld	s0,32(sp)
ffffffffc0203a4e:	64e2                	ld	s1,24(sp)
ffffffffc0203a50:	6942                	ld	s2,16(sp)
ffffffffc0203a52:	69a2                	ld	s3,8(sp)
ffffffffc0203a54:	6145                	addi	sp,sp,48
ffffffffc0203a56:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0203a58:	0000e797          	auipc	a5,0xe
ffffffffc0203a5c:	a3878793          	addi	a5,a5,-1480 # ffffffffc0211490 <check_mm_struct>
ffffffffc0203a60:	6388                	ld	a0,0(a5)
ffffffffc0203a62:	4681                	li	a3,0
ffffffffc0203a64:	8622                	mv	a2,s0
ffffffffc0203a66:	85a6                	mv	a1,s1
ffffffffc0203a68:	f29fd0ef          	jal	ra,ffffffffc0201990 <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0203a6c:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0203a6e:	e024                	sd	s1,64(s0)
            assert(page_ref(page) == 1);
ffffffffc0203a70:	4785                	li	a5,1
ffffffffc0203a72:	fcf70be3          	beq	a4,a5,ffffffffc0203a48 <pgdir_alloc_page+0x38>
ffffffffc0203a76:	00002697          	auipc	a3,0x2
ffffffffc0203a7a:	eca68693          	addi	a3,a3,-310 # ffffffffc0205940 <default_pmm_manager+0x1d0>
ffffffffc0203a7e:	00001617          	auipc	a2,0x1
ffffffffc0203a82:	24a60613          	addi	a2,a2,586 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0203a86:	17a00593          	li	a1,378
ffffffffc0203a8a:	00002517          	auipc	a0,0x2
ffffffffc0203a8e:	e6650513          	addi	a0,a0,-410 # ffffffffc02058f0 <default_pmm_manager+0x180>
ffffffffc0203a92:	e74fc0ef          	jal	ra,ffffffffc0200106 <__panic>
            free_page(page);
ffffffffc0203a96:	8522                	mv	a0,s0
ffffffffc0203a98:	4585                	li	a1,1
ffffffffc0203a9a:	864ff0ef          	jal	ra,ffffffffc0202afe <free_pages>
            return NULL;
ffffffffc0203a9e:	4401                	li	s0,0
ffffffffc0203aa0:	b765                	j	ffffffffc0203a48 <pgdir_alloc_page+0x38>

ffffffffc0203aa2 <kmalloc>:
}

void *kmalloc(size_t n) {
ffffffffc0203aa2:	1141                	addi	sp,sp,-16
    void *ptr = NULL;
    struct Page *base = NULL;
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203aa4:	67d5                	lui	a5,0x15
void *kmalloc(size_t n) {
ffffffffc0203aa6:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203aa8:	fff50713          	addi	a4,a0,-1
ffffffffc0203aac:	17f9                	addi	a5,a5,-2
ffffffffc0203aae:	04e7ee63          	bltu	a5,a4,ffffffffc0203b0a <kmalloc+0x68>
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc0203ab2:	6785                	lui	a5,0x1
ffffffffc0203ab4:	17fd                	addi	a5,a5,-1
ffffffffc0203ab6:	953e                	add	a0,a0,a5
    base = alloc_pages(num_pages);
ffffffffc0203ab8:	8131                	srli	a0,a0,0xc
ffffffffc0203aba:	fbdfe0ef          	jal	ra,ffffffffc0202a76 <alloc_pages>
    assert(base != NULL);
ffffffffc0203abe:	c159                	beqz	a0,ffffffffc0203b44 <kmalloc+0xa2>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203ac0:	0000e797          	auipc	a5,0xe
ffffffffc0203ac4:	ad878793          	addi	a5,a5,-1320 # ffffffffc0211598 <pages>
ffffffffc0203ac8:	639c                	ld	a5,0(a5)
ffffffffc0203aca:	8d1d                	sub	a0,a0,a5
ffffffffc0203acc:	00002797          	auipc	a5,0x2
ffffffffc0203ad0:	94c78793          	addi	a5,a5,-1716 # ffffffffc0205418 <commands+0xfa8>
ffffffffc0203ad4:	6394                	ld	a3,0(a5)
ffffffffc0203ad6:	850d                	srai	a0,a0,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203ad8:	0000e797          	auipc	a5,0xe
ffffffffc0203adc:	99878793          	addi	a5,a5,-1640 # ffffffffc0211470 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203ae0:	02d50533          	mul	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203ae4:	6398                	ld	a4,0(a5)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203ae6:	000806b7          	lui	a3,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203aea:	57fd                	li	a5,-1
ffffffffc0203aec:	83b1                	srli	a5,a5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203aee:	9536                	add	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203af0:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0203af2:	0532                	slli	a0,a0,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203af4:	02e7fb63          	bleu	a4,a5,ffffffffc0203b2a <kmalloc+0x88>
ffffffffc0203af8:	0000e797          	auipc	a5,0xe
ffffffffc0203afc:	a9078793          	addi	a5,a5,-1392 # ffffffffc0211588 <va_pa_offset>
ffffffffc0203b00:	639c                	ld	a5,0(a5)
    ptr = page2kva(base);
    return ptr;
}
ffffffffc0203b02:	60a2                	ld	ra,8(sp)
ffffffffc0203b04:	953e                	add	a0,a0,a5
ffffffffc0203b06:	0141                	addi	sp,sp,16
ffffffffc0203b08:	8082                	ret
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203b0a:	00002697          	auipc	a3,0x2
ffffffffc0203b0e:	e0668693          	addi	a3,a3,-506 # ffffffffc0205910 <default_pmm_manager+0x1a0>
ffffffffc0203b12:	00001617          	auipc	a2,0x1
ffffffffc0203b16:	1b660613          	addi	a2,a2,438 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0203b1a:	1f000593          	li	a1,496
ffffffffc0203b1e:	00002517          	auipc	a0,0x2
ffffffffc0203b22:	dd250513          	addi	a0,a0,-558 # ffffffffc02058f0 <default_pmm_manager+0x180>
ffffffffc0203b26:	de0fc0ef          	jal	ra,ffffffffc0200106 <__panic>
ffffffffc0203b2a:	86aa                	mv	a3,a0
ffffffffc0203b2c:	00002617          	auipc	a2,0x2
ffffffffc0203b30:	d9c60613          	addi	a2,a2,-612 # ffffffffc02058c8 <default_pmm_manager+0x158>
ffffffffc0203b34:	06a00593          	li	a1,106
ffffffffc0203b38:	00001517          	auipc	a0,0x1
ffffffffc0203b3c:	4b850513          	addi	a0,a0,1208 # ffffffffc0204ff0 <commands+0xb80>
ffffffffc0203b40:	dc6fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(base != NULL);
ffffffffc0203b44:	00002697          	auipc	a3,0x2
ffffffffc0203b48:	dec68693          	addi	a3,a3,-532 # ffffffffc0205930 <default_pmm_manager+0x1c0>
ffffffffc0203b4c:	00001617          	auipc	a2,0x1
ffffffffc0203b50:	17c60613          	addi	a2,a2,380 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0203b54:	1f300593          	li	a1,499
ffffffffc0203b58:	00002517          	auipc	a0,0x2
ffffffffc0203b5c:	d9850513          	addi	a0,a0,-616 # ffffffffc02058f0 <default_pmm_manager+0x180>
ffffffffc0203b60:	da6fc0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0203b64 <kfree>:

void kfree(void *ptr, size_t n) {
ffffffffc0203b64:	1141                	addi	sp,sp,-16
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203b66:	67d5                	lui	a5,0x15
void kfree(void *ptr, size_t n) {
ffffffffc0203b68:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203b6a:	fff58713          	addi	a4,a1,-1
ffffffffc0203b6e:	17f9                	addi	a5,a5,-2
ffffffffc0203b70:	04e7eb63          	bltu	a5,a4,ffffffffc0203bc6 <kfree+0x62>
    assert(ptr != NULL);
ffffffffc0203b74:	c941                	beqz	a0,ffffffffc0203c04 <kfree+0xa0>
    struct Page *base = NULL;
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc0203b76:	6785                	lui	a5,0x1
ffffffffc0203b78:	17fd                	addi	a5,a5,-1
ffffffffc0203b7a:	95be                	add	a1,a1,a5
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0203b7c:	c02007b7          	lui	a5,0xc0200
ffffffffc0203b80:	81b1                	srli	a1,a1,0xc
ffffffffc0203b82:	06f56463          	bltu	a0,a5,ffffffffc0203bea <kfree+0x86>
ffffffffc0203b86:	0000e797          	auipc	a5,0xe
ffffffffc0203b8a:	a0278793          	addi	a5,a5,-1534 # ffffffffc0211588 <va_pa_offset>
ffffffffc0203b8e:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0203b90:	0000e717          	auipc	a4,0xe
ffffffffc0203b94:	8e070713          	addi	a4,a4,-1824 # ffffffffc0211470 <npage>
ffffffffc0203b98:	6318                	ld	a4,0(a4)
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0203b9a:	40f507b3          	sub	a5,a0,a5
    if (PPN(pa) >= npage) {
ffffffffc0203b9e:	83b1                	srli	a5,a5,0xc
ffffffffc0203ba0:	04e7f363          	bleu	a4,a5,ffffffffc0203be6 <kfree+0x82>
    return &pages[PPN(pa) - nbase];
ffffffffc0203ba4:	fff80537          	lui	a0,0xfff80
ffffffffc0203ba8:	97aa                	add	a5,a5,a0
ffffffffc0203baa:	0000e697          	auipc	a3,0xe
ffffffffc0203bae:	9ee68693          	addi	a3,a3,-1554 # ffffffffc0211598 <pages>
ffffffffc0203bb2:	6288                	ld	a0,0(a3)
ffffffffc0203bb4:	00379713          	slli	a4,a5,0x3
    base = kva2page(ptr);
    free_pages(base, num_pages);
}
ffffffffc0203bb8:	60a2                	ld	ra,8(sp)
ffffffffc0203bba:	97ba                	add	a5,a5,a4
ffffffffc0203bbc:	078e                	slli	a5,a5,0x3
    free_pages(base, num_pages);
ffffffffc0203bbe:	953e                	add	a0,a0,a5
}
ffffffffc0203bc0:	0141                	addi	sp,sp,16
    free_pages(base, num_pages);
ffffffffc0203bc2:	f3dfe06f          	j	ffffffffc0202afe <free_pages>
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203bc6:	00002697          	auipc	a3,0x2
ffffffffc0203bca:	d4a68693          	addi	a3,a3,-694 # ffffffffc0205910 <default_pmm_manager+0x1a0>
ffffffffc0203bce:	00001617          	auipc	a2,0x1
ffffffffc0203bd2:	0fa60613          	addi	a2,a2,250 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0203bd6:	1f900593          	li	a1,505
ffffffffc0203bda:	00002517          	auipc	a0,0x2
ffffffffc0203bde:	d1650513          	addi	a0,a0,-746 # ffffffffc02058f0 <default_pmm_manager+0x180>
ffffffffc0203be2:	d24fc0ef          	jal	ra,ffffffffc0200106 <__panic>
ffffffffc0203be6:	e75fe0ef          	jal	ra,ffffffffc0202a5a <pa2page.part.4>
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0203bea:	86aa                	mv	a3,a0
ffffffffc0203bec:	00002617          	auipc	a2,0x2
ffffffffc0203bf0:	df460613          	addi	a2,a2,-524 # ffffffffc02059e0 <default_pmm_manager+0x270>
ffffffffc0203bf4:	06c00593          	li	a1,108
ffffffffc0203bf8:	00001517          	auipc	a0,0x1
ffffffffc0203bfc:	3f850513          	addi	a0,a0,1016 # ffffffffc0204ff0 <commands+0xb80>
ffffffffc0203c00:	d06fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(ptr != NULL);
ffffffffc0203c04:	00002697          	auipc	a3,0x2
ffffffffc0203c08:	cfc68693          	addi	a3,a3,-772 # ffffffffc0205900 <default_pmm_manager+0x190>
ffffffffc0203c0c:	00001617          	auipc	a2,0x1
ffffffffc0203c10:	0bc60613          	addi	a2,a2,188 # ffffffffc0204cc8 <commands+0x858>
ffffffffc0203c14:	1fa00593          	li	a1,506
ffffffffc0203c18:	00002517          	auipc	a0,0x2
ffffffffc0203c1c:	cd850513          	addi	a0,a0,-808 # ffffffffc02058f0 <default_pmm_manager+0x180>
ffffffffc0203c20:	ce6fc0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0203c24 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0203c24:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);// 以SECTSIZE的整数倍读写，确保对齐
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203c26:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0203c28:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203c2a:	facfc0ef          	jal	ra,ffffffffc02003d6 <ide_device_valid>
ffffffffc0203c2e:	cd01                	beqz	a0,ffffffffc0203c46 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);// 按页存，可以存多少页
ffffffffc0203c30:	4505                	li	a0,1
ffffffffc0203c32:	faafc0ef          	jal	ra,ffffffffc02003dc <ide_device_size>
}
ffffffffc0203c36:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);// 按页存，可以存多少页
ffffffffc0203c38:	810d                	srli	a0,a0,0x3
ffffffffc0203c3a:	0000e797          	auipc	a5,0xe
ffffffffc0203c3e:	8ea7b323          	sd	a0,-1818(a5) # ffffffffc0211520 <max_swap_offset>
}
ffffffffc0203c42:	0141                	addi	sp,sp,16
ffffffffc0203c44:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0203c46:	00002617          	auipc	a2,0x2
ffffffffc0203c4a:	27a60613          	addi	a2,a2,634 # ffffffffc0205ec0 <default_pmm_manager+0x750>
ffffffffc0203c4e:	45b5                	li	a1,13
ffffffffc0203c50:	00002517          	auipc	a0,0x2
ffffffffc0203c54:	29050513          	addi	a0,a0,656 # ffffffffc0205ee0 <default_pmm_manager+0x770>
ffffffffc0203c58:	caefc0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0203c5c <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {// 读
ffffffffc0203c5c:	1141                	addi	sp,sp,-16
ffffffffc0203c5e:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203c60:	00855793          	srli	a5,a0,0x8
ffffffffc0203c64:	c7b5                	beqz	a5,ffffffffc0203cd0 <swapfs_read+0x74>
ffffffffc0203c66:	0000e717          	auipc	a4,0xe
ffffffffc0203c6a:	8ba70713          	addi	a4,a4,-1862 # ffffffffc0211520 <max_swap_offset>
ffffffffc0203c6e:	6318                	ld	a4,0(a4)
ffffffffc0203c70:	06e7f063          	bleu	a4,a5,ffffffffc0203cd0 <swapfs_read+0x74>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203c74:	0000e717          	auipc	a4,0xe
ffffffffc0203c78:	92470713          	addi	a4,a4,-1756 # ffffffffc0211598 <pages>
ffffffffc0203c7c:	6310                	ld	a2,0(a4)
ffffffffc0203c7e:	00001717          	auipc	a4,0x1
ffffffffc0203c82:	79a70713          	addi	a4,a4,1946 # ffffffffc0205418 <commands+0xfa8>
ffffffffc0203c86:	00002697          	auipc	a3,0x2
ffffffffc0203c8a:	4da68693          	addi	a3,a3,1242 # ffffffffc0206160 <nbase>
ffffffffc0203c8e:	40c58633          	sub	a2,a1,a2
ffffffffc0203c92:	630c                	ld	a1,0(a4)
ffffffffc0203c94:	860d                	srai	a2,a2,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203c96:	0000d717          	auipc	a4,0xd
ffffffffc0203c9a:	7da70713          	addi	a4,a4,2010 # ffffffffc0211470 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203c9e:	02b60633          	mul	a2,a2,a1
ffffffffc0203ca2:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203ca6:	629c                	ld	a5,0(a3)
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203ca8:	6318                	ld	a4,0(a4)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203caa:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203cac:	57fd                	li	a5,-1
ffffffffc0203cae:	83b1                	srli	a5,a5,0xc
ffffffffc0203cb0:	8ff1                	and	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0203cb2:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203cb4:	02e7fa63          	bleu	a4,a5,ffffffffc0203ce8 <swapfs_read+0x8c>
ffffffffc0203cb8:	0000e797          	auipc	a5,0xe
ffffffffc0203cbc:	8d078793          	addi	a5,a5,-1840 # ffffffffc0211588 <va_pa_offset>
ffffffffc0203cc0:	639c                	ld	a5,0(a5)
}
ffffffffc0203cc2:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203cc4:	46a1                	li	a3,8
ffffffffc0203cc6:	963e                	add	a2,a2,a5
ffffffffc0203cc8:	4505                	li	a0,1
}
ffffffffc0203cca:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203ccc:	f16fc06f          	j	ffffffffc02003e2 <ide_read_secs>
ffffffffc0203cd0:	86aa                	mv	a3,a0
ffffffffc0203cd2:	00002617          	auipc	a2,0x2
ffffffffc0203cd6:	22660613          	addi	a2,a2,550 # ffffffffc0205ef8 <default_pmm_manager+0x788>
ffffffffc0203cda:	45d1                	li	a1,20
ffffffffc0203cdc:	00002517          	auipc	a0,0x2
ffffffffc0203ce0:	20450513          	addi	a0,a0,516 # ffffffffc0205ee0 <default_pmm_manager+0x770>
ffffffffc0203ce4:	c22fc0ef          	jal	ra,ffffffffc0200106 <__panic>
ffffffffc0203ce8:	86b2                	mv	a3,a2
ffffffffc0203cea:	06a00593          	li	a1,106
ffffffffc0203cee:	00002617          	auipc	a2,0x2
ffffffffc0203cf2:	bda60613          	addi	a2,a2,-1062 # ffffffffc02058c8 <default_pmm_manager+0x158>
ffffffffc0203cf6:	00001517          	auipc	a0,0x1
ffffffffc0203cfa:	2fa50513          	addi	a0,a0,762 # ffffffffc0204ff0 <commands+0xb80>
ffffffffc0203cfe:	c08fc0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0203d02 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {// 写
ffffffffc0203d02:	1141                	addi	sp,sp,-16
ffffffffc0203d04:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203d06:	00855793          	srli	a5,a0,0x8
ffffffffc0203d0a:	c7b5                	beqz	a5,ffffffffc0203d76 <swapfs_write+0x74>
ffffffffc0203d0c:	0000e717          	auipc	a4,0xe
ffffffffc0203d10:	81470713          	addi	a4,a4,-2028 # ffffffffc0211520 <max_swap_offset>
ffffffffc0203d14:	6318                	ld	a4,0(a4)
ffffffffc0203d16:	06e7f063          	bleu	a4,a5,ffffffffc0203d76 <swapfs_write+0x74>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203d1a:	0000e717          	auipc	a4,0xe
ffffffffc0203d1e:	87e70713          	addi	a4,a4,-1922 # ffffffffc0211598 <pages>
ffffffffc0203d22:	6310                	ld	a2,0(a4)
ffffffffc0203d24:	00001717          	auipc	a4,0x1
ffffffffc0203d28:	6f470713          	addi	a4,a4,1780 # ffffffffc0205418 <commands+0xfa8>
ffffffffc0203d2c:	00002697          	auipc	a3,0x2
ffffffffc0203d30:	43468693          	addi	a3,a3,1076 # ffffffffc0206160 <nbase>
ffffffffc0203d34:	40c58633          	sub	a2,a1,a2
ffffffffc0203d38:	630c                	ld	a1,0(a4)
ffffffffc0203d3a:	860d                	srai	a2,a2,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d3c:	0000d717          	auipc	a4,0xd
ffffffffc0203d40:	73470713          	addi	a4,a4,1844 # ffffffffc0211470 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203d44:	02b60633          	mul	a2,a2,a1
ffffffffc0203d48:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203d4c:	629c                	ld	a5,0(a3)
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d4e:	6318                	ld	a4,0(a4)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203d50:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d52:	57fd                	li	a5,-1
ffffffffc0203d54:	83b1                	srli	a5,a5,0xc
ffffffffc0203d56:	8ff1                	and	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0203d58:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d5a:	02e7fa63          	bleu	a4,a5,ffffffffc0203d8e <swapfs_write+0x8c>
ffffffffc0203d5e:	0000e797          	auipc	a5,0xe
ffffffffc0203d62:	82a78793          	addi	a5,a5,-2006 # ffffffffc0211588 <va_pa_offset>
ffffffffc0203d66:	639c                	ld	a5,0(a5)
}
ffffffffc0203d68:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203d6a:	46a1                	li	a3,8
ffffffffc0203d6c:	963e                	add	a2,a2,a5
ffffffffc0203d6e:	4505                	li	a0,1
}
ffffffffc0203d70:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203d72:	e94fc06f          	j	ffffffffc0200406 <ide_write_secs>
ffffffffc0203d76:	86aa                	mv	a3,a0
ffffffffc0203d78:	00002617          	auipc	a2,0x2
ffffffffc0203d7c:	18060613          	addi	a2,a2,384 # ffffffffc0205ef8 <default_pmm_manager+0x788>
ffffffffc0203d80:	45e5                	li	a1,25
ffffffffc0203d82:	00002517          	auipc	a0,0x2
ffffffffc0203d86:	15e50513          	addi	a0,a0,350 # ffffffffc0205ee0 <default_pmm_manager+0x770>
ffffffffc0203d8a:	b7cfc0ef          	jal	ra,ffffffffc0200106 <__panic>
ffffffffc0203d8e:	86b2                	mv	a3,a2
ffffffffc0203d90:	06a00593          	li	a1,106
ffffffffc0203d94:	00002617          	auipc	a2,0x2
ffffffffc0203d98:	b3460613          	addi	a2,a2,-1228 # ffffffffc02058c8 <default_pmm_manager+0x158>
ffffffffc0203d9c:	00001517          	auipc	a0,0x1
ffffffffc0203da0:	25450513          	addi	a0,a0,596 # ffffffffc0204ff0 <commands+0xb80>
ffffffffc0203da4:	b62fc0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0203da8 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0203da8:	00054783          	lbu	a5,0(a0)
ffffffffc0203dac:	cb91                	beqz	a5,ffffffffc0203dc0 <strlen+0x18>
    size_t cnt = 0;
ffffffffc0203dae:	4781                	li	a5,0
        cnt ++;
ffffffffc0203db0:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc0203db2:	00f50733          	add	a4,a0,a5
ffffffffc0203db6:	00074703          	lbu	a4,0(a4)
ffffffffc0203dba:	fb7d                	bnez	a4,ffffffffc0203db0 <strlen+0x8>
    }
    return cnt;
}
ffffffffc0203dbc:	853e                	mv	a0,a5
ffffffffc0203dbe:	8082                	ret
    size_t cnt = 0;
ffffffffc0203dc0:	4781                	li	a5,0
}
ffffffffc0203dc2:	853e                	mv	a0,a5
ffffffffc0203dc4:	8082                	ret

ffffffffc0203dc6 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0203dc6:	c185                	beqz	a1,ffffffffc0203de6 <strnlen+0x20>
ffffffffc0203dc8:	00054783          	lbu	a5,0(a0)
ffffffffc0203dcc:	cf89                	beqz	a5,ffffffffc0203de6 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0203dce:	4781                	li	a5,0
ffffffffc0203dd0:	a021                	j	ffffffffc0203dd8 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0203dd2:	00074703          	lbu	a4,0(a4)
ffffffffc0203dd6:	c711                	beqz	a4,ffffffffc0203de2 <strnlen+0x1c>
        cnt ++;
ffffffffc0203dd8:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0203dda:	00f50733          	add	a4,a0,a5
ffffffffc0203dde:	fef59ae3          	bne	a1,a5,ffffffffc0203dd2 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0203de2:	853e                	mv	a0,a5
ffffffffc0203de4:	8082                	ret
    size_t cnt = 0;
ffffffffc0203de6:	4781                	li	a5,0
}
ffffffffc0203de8:	853e                	mv	a0,a5
ffffffffc0203dea:	8082                	ret

ffffffffc0203dec <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0203dec:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0203dee:	0585                	addi	a1,a1,1
ffffffffc0203df0:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0203df4:	0785                	addi	a5,a5,1
ffffffffc0203df6:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0203dfa:	fb75                	bnez	a4,ffffffffc0203dee <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0203dfc:	8082                	ret

ffffffffc0203dfe <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203dfe:	00054783          	lbu	a5,0(a0)
ffffffffc0203e02:	0005c703          	lbu	a4,0(a1)
ffffffffc0203e06:	cb91                	beqz	a5,ffffffffc0203e1a <strcmp+0x1c>
ffffffffc0203e08:	00e79c63          	bne	a5,a4,ffffffffc0203e20 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0203e0c:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203e0e:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0203e12:	0585                	addi	a1,a1,1
ffffffffc0203e14:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203e18:	fbe5                	bnez	a5,ffffffffc0203e08 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0203e1a:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0203e1c:	9d19                	subw	a0,a0,a4
ffffffffc0203e1e:	8082                	ret
ffffffffc0203e20:	0007851b          	sext.w	a0,a5
ffffffffc0203e24:	9d19                	subw	a0,a0,a4
ffffffffc0203e26:	8082                	ret

ffffffffc0203e28 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0203e28:	00054783          	lbu	a5,0(a0)
ffffffffc0203e2c:	cb91                	beqz	a5,ffffffffc0203e40 <strchr+0x18>
        if (*s == c) {
ffffffffc0203e2e:	00b79563          	bne	a5,a1,ffffffffc0203e38 <strchr+0x10>
ffffffffc0203e32:	a809                	j	ffffffffc0203e44 <strchr+0x1c>
ffffffffc0203e34:	00b78763          	beq	a5,a1,ffffffffc0203e42 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0203e38:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0203e3a:	00054783          	lbu	a5,0(a0)
ffffffffc0203e3e:	fbfd                	bnez	a5,ffffffffc0203e34 <strchr+0xc>
    }
    return NULL;
ffffffffc0203e40:	4501                	li	a0,0
}
ffffffffc0203e42:	8082                	ret
ffffffffc0203e44:	8082                	ret

ffffffffc0203e46 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0203e46:	ca01                	beqz	a2,ffffffffc0203e56 <memset+0x10>
ffffffffc0203e48:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0203e4a:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0203e4c:	0785                	addi	a5,a5,1
ffffffffc0203e4e:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0203e52:	fec79de3          	bne	a5,a2,ffffffffc0203e4c <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0203e56:	8082                	ret

ffffffffc0203e58 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0203e58:	ca19                	beqz	a2,ffffffffc0203e6e <memcpy+0x16>
ffffffffc0203e5a:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0203e5c:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0203e5e:	0585                	addi	a1,a1,1
ffffffffc0203e60:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0203e64:	0785                	addi	a5,a5,1
ffffffffc0203e66:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0203e6a:	fec59ae3          	bne	a1,a2,ffffffffc0203e5e <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0203e6e:	8082                	ret

ffffffffc0203e70 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0203e70:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203e74:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0203e76:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203e7a:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0203e7c:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203e80:	f022                	sd	s0,32(sp)
ffffffffc0203e82:	ec26                	sd	s1,24(sp)
ffffffffc0203e84:	e84a                	sd	s2,16(sp)
ffffffffc0203e86:	f406                	sd	ra,40(sp)
ffffffffc0203e88:	e44e                	sd	s3,8(sp)
ffffffffc0203e8a:	84aa                	mv	s1,a0
ffffffffc0203e8c:	892e                	mv	s2,a1
ffffffffc0203e8e:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0203e92:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0203e94:	03067e63          	bleu	a6,a2,ffffffffc0203ed0 <printnum+0x60>
ffffffffc0203e98:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0203e9a:	00805763          	blez	s0,ffffffffc0203ea8 <printnum+0x38>
ffffffffc0203e9e:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0203ea0:	85ca                	mv	a1,s2
ffffffffc0203ea2:	854e                	mv	a0,s3
ffffffffc0203ea4:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0203ea6:	fc65                	bnez	s0,ffffffffc0203e9e <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203ea8:	1a02                	slli	s4,s4,0x20
ffffffffc0203eaa:	020a5a13          	srli	s4,s4,0x20
ffffffffc0203eae:	00002797          	auipc	a5,0x2
ffffffffc0203eb2:	1fa78793          	addi	a5,a5,506 # ffffffffc02060a8 <error_string+0x38>
ffffffffc0203eb6:	9a3e                	add	s4,s4,a5
}
ffffffffc0203eb8:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203eba:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0203ebe:	70a2                	ld	ra,40(sp)
ffffffffc0203ec0:	69a2                	ld	s3,8(sp)
ffffffffc0203ec2:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203ec4:	85ca                	mv	a1,s2
ffffffffc0203ec6:	8326                	mv	t1,s1
}
ffffffffc0203ec8:	6942                	ld	s2,16(sp)
ffffffffc0203eca:	64e2                	ld	s1,24(sp)
ffffffffc0203ecc:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203ece:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0203ed0:	03065633          	divu	a2,a2,a6
ffffffffc0203ed4:	8722                	mv	a4,s0
ffffffffc0203ed6:	f9bff0ef          	jal	ra,ffffffffc0203e70 <printnum>
ffffffffc0203eda:	b7f9                	j	ffffffffc0203ea8 <printnum+0x38>

ffffffffc0203edc <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0203edc:	7119                	addi	sp,sp,-128
ffffffffc0203ede:	f4a6                	sd	s1,104(sp)
ffffffffc0203ee0:	f0ca                	sd	s2,96(sp)
ffffffffc0203ee2:	e8d2                	sd	s4,80(sp)
ffffffffc0203ee4:	e4d6                	sd	s5,72(sp)
ffffffffc0203ee6:	e0da                	sd	s6,64(sp)
ffffffffc0203ee8:	fc5e                	sd	s7,56(sp)
ffffffffc0203eea:	f862                	sd	s8,48(sp)
ffffffffc0203eec:	f06a                	sd	s10,32(sp)
ffffffffc0203eee:	fc86                	sd	ra,120(sp)
ffffffffc0203ef0:	f8a2                	sd	s0,112(sp)
ffffffffc0203ef2:	ecce                	sd	s3,88(sp)
ffffffffc0203ef4:	f466                	sd	s9,40(sp)
ffffffffc0203ef6:	ec6e                	sd	s11,24(sp)
ffffffffc0203ef8:	892a                	mv	s2,a0
ffffffffc0203efa:	84ae                	mv	s1,a1
ffffffffc0203efc:	8d32                	mv	s10,a2
ffffffffc0203efe:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0203f00:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203f02:	00002a17          	auipc	s4,0x2
ffffffffc0203f06:	016a0a13          	addi	s4,s4,22 # ffffffffc0205f18 <default_pmm_manager+0x7a8>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203f0a:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203f0e:	00002c17          	auipc	s8,0x2
ffffffffc0203f12:	162c0c13          	addi	s8,s8,354 # ffffffffc0206070 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203f16:	000d4503          	lbu	a0,0(s10)
ffffffffc0203f1a:	02500793          	li	a5,37
ffffffffc0203f1e:	001d0413          	addi	s0,s10,1
ffffffffc0203f22:	00f50e63          	beq	a0,a5,ffffffffc0203f3e <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0203f26:	c521                	beqz	a0,ffffffffc0203f6e <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203f28:	02500993          	li	s3,37
ffffffffc0203f2c:	a011                	j	ffffffffc0203f30 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0203f2e:	c121                	beqz	a0,ffffffffc0203f6e <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0203f30:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203f32:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0203f34:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203f36:	fff44503          	lbu	a0,-1(s0)
ffffffffc0203f3a:	ff351ae3          	bne	a0,s3,ffffffffc0203f2e <vprintfmt+0x52>
ffffffffc0203f3e:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0203f42:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0203f46:	4981                	li	s3,0
ffffffffc0203f48:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0203f4a:	5cfd                	li	s9,-1
ffffffffc0203f4c:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203f4e:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0203f52:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203f54:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0203f58:	0ff6f693          	andi	a3,a3,255
ffffffffc0203f5c:	00140d13          	addi	s10,s0,1
ffffffffc0203f60:	20d5e563          	bltu	a1,a3,ffffffffc020416a <vprintfmt+0x28e>
ffffffffc0203f64:	068a                	slli	a3,a3,0x2
ffffffffc0203f66:	96d2                	add	a3,a3,s4
ffffffffc0203f68:	4294                	lw	a3,0(a3)
ffffffffc0203f6a:	96d2                	add	a3,a3,s4
ffffffffc0203f6c:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0203f6e:	70e6                	ld	ra,120(sp)
ffffffffc0203f70:	7446                	ld	s0,112(sp)
ffffffffc0203f72:	74a6                	ld	s1,104(sp)
ffffffffc0203f74:	7906                	ld	s2,96(sp)
ffffffffc0203f76:	69e6                	ld	s3,88(sp)
ffffffffc0203f78:	6a46                	ld	s4,80(sp)
ffffffffc0203f7a:	6aa6                	ld	s5,72(sp)
ffffffffc0203f7c:	6b06                	ld	s6,64(sp)
ffffffffc0203f7e:	7be2                	ld	s7,56(sp)
ffffffffc0203f80:	7c42                	ld	s8,48(sp)
ffffffffc0203f82:	7ca2                	ld	s9,40(sp)
ffffffffc0203f84:	7d02                	ld	s10,32(sp)
ffffffffc0203f86:	6de2                	ld	s11,24(sp)
ffffffffc0203f88:	6109                	addi	sp,sp,128
ffffffffc0203f8a:	8082                	ret
    if (lflag >= 2) {
ffffffffc0203f8c:	4705                	li	a4,1
ffffffffc0203f8e:	008a8593          	addi	a1,s5,8
ffffffffc0203f92:	01074463          	blt	a4,a6,ffffffffc0203f9a <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc0203f96:	26080363          	beqz	a6,ffffffffc02041fc <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc0203f9a:	000ab603          	ld	a2,0(s5)
ffffffffc0203f9e:	46c1                	li	a3,16
ffffffffc0203fa0:	8aae                	mv	s5,a1
ffffffffc0203fa2:	a06d                	j	ffffffffc020404c <vprintfmt+0x170>
            goto reswitch;
ffffffffc0203fa4:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0203fa8:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203faa:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0203fac:	b765                	j	ffffffffc0203f54 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc0203fae:	000aa503          	lw	a0,0(s5)
ffffffffc0203fb2:	85a6                	mv	a1,s1
ffffffffc0203fb4:	0aa1                	addi	s5,s5,8
ffffffffc0203fb6:	9902                	jalr	s2
            break;
ffffffffc0203fb8:	bfb9                	j	ffffffffc0203f16 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0203fba:	4705                	li	a4,1
ffffffffc0203fbc:	008a8993          	addi	s3,s5,8
ffffffffc0203fc0:	01074463          	blt	a4,a6,ffffffffc0203fc8 <vprintfmt+0xec>
    else if (lflag) {
ffffffffc0203fc4:	22080463          	beqz	a6,ffffffffc02041ec <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc0203fc8:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc0203fcc:	24044463          	bltz	s0,ffffffffc0204214 <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc0203fd0:	8622                	mv	a2,s0
ffffffffc0203fd2:	8ace                	mv	s5,s3
ffffffffc0203fd4:	46a9                	li	a3,10
ffffffffc0203fd6:	a89d                	j	ffffffffc020404c <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc0203fd8:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203fdc:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0203fde:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc0203fe0:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0203fe4:	8fb5                	xor	a5,a5,a3
ffffffffc0203fe6:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203fea:	1ad74363          	blt	a4,a3,ffffffffc0204190 <vprintfmt+0x2b4>
ffffffffc0203fee:	00369793          	slli	a5,a3,0x3
ffffffffc0203ff2:	97e2                	add	a5,a5,s8
ffffffffc0203ff4:	639c                	ld	a5,0(a5)
ffffffffc0203ff6:	18078d63          	beqz	a5,ffffffffc0204190 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc0203ffa:	86be                	mv	a3,a5
ffffffffc0203ffc:	00002617          	auipc	a2,0x2
ffffffffc0204000:	15c60613          	addi	a2,a2,348 # ffffffffc0206158 <error_string+0xe8>
ffffffffc0204004:	85a6                	mv	a1,s1
ffffffffc0204006:	854a                	mv	a0,s2
ffffffffc0204008:	240000ef          	jal	ra,ffffffffc0204248 <printfmt>
ffffffffc020400c:	b729                	j	ffffffffc0203f16 <vprintfmt+0x3a>
            lflag ++;
ffffffffc020400e:	00144603          	lbu	a2,1(s0)
ffffffffc0204012:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204014:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204016:	bf3d                	j	ffffffffc0203f54 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0204018:	4705                	li	a4,1
ffffffffc020401a:	008a8593          	addi	a1,s5,8
ffffffffc020401e:	01074463          	blt	a4,a6,ffffffffc0204026 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0204022:	1e080263          	beqz	a6,ffffffffc0204206 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc0204026:	000ab603          	ld	a2,0(s5)
ffffffffc020402a:	46a1                	li	a3,8
ffffffffc020402c:	8aae                	mv	s5,a1
ffffffffc020402e:	a839                	j	ffffffffc020404c <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc0204030:	03000513          	li	a0,48
ffffffffc0204034:	85a6                	mv	a1,s1
ffffffffc0204036:	e03e                	sd	a5,0(sp)
ffffffffc0204038:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc020403a:	85a6                	mv	a1,s1
ffffffffc020403c:	07800513          	li	a0,120
ffffffffc0204040:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0204042:	0aa1                	addi	s5,s5,8
ffffffffc0204044:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0204048:	6782                	ld	a5,0(sp)
ffffffffc020404a:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc020404c:	876e                	mv	a4,s11
ffffffffc020404e:	85a6                	mv	a1,s1
ffffffffc0204050:	854a                	mv	a0,s2
ffffffffc0204052:	e1fff0ef          	jal	ra,ffffffffc0203e70 <printnum>
            break;
ffffffffc0204056:	b5c1                	j	ffffffffc0203f16 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204058:	000ab603          	ld	a2,0(s5)
ffffffffc020405c:	0aa1                	addi	s5,s5,8
ffffffffc020405e:	1c060663          	beqz	a2,ffffffffc020422a <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc0204062:	00160413          	addi	s0,a2,1
ffffffffc0204066:	17b05c63          	blez	s11,ffffffffc02041de <vprintfmt+0x302>
ffffffffc020406a:	02d00593          	li	a1,45
ffffffffc020406e:	14b79263          	bne	a5,a1,ffffffffc02041b2 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204072:	00064783          	lbu	a5,0(a2)
ffffffffc0204076:	0007851b          	sext.w	a0,a5
ffffffffc020407a:	c905                	beqz	a0,ffffffffc02040aa <vprintfmt+0x1ce>
ffffffffc020407c:	000cc563          	bltz	s9,ffffffffc0204086 <vprintfmt+0x1aa>
ffffffffc0204080:	3cfd                	addiw	s9,s9,-1
ffffffffc0204082:	036c8263          	beq	s9,s6,ffffffffc02040a6 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc0204086:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204088:	18098463          	beqz	s3,ffffffffc0204210 <vprintfmt+0x334>
ffffffffc020408c:	3781                	addiw	a5,a5,-32
ffffffffc020408e:	18fbf163          	bleu	a5,s7,ffffffffc0204210 <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc0204092:	03f00513          	li	a0,63
ffffffffc0204096:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204098:	0405                	addi	s0,s0,1
ffffffffc020409a:	fff44783          	lbu	a5,-1(s0)
ffffffffc020409e:	3dfd                	addiw	s11,s11,-1
ffffffffc02040a0:	0007851b          	sext.w	a0,a5
ffffffffc02040a4:	fd61                	bnez	a0,ffffffffc020407c <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc02040a6:	e7b058e3          	blez	s11,ffffffffc0203f16 <vprintfmt+0x3a>
ffffffffc02040aa:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02040ac:	85a6                	mv	a1,s1
ffffffffc02040ae:	02000513          	li	a0,32
ffffffffc02040b2:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02040b4:	e60d81e3          	beqz	s11,ffffffffc0203f16 <vprintfmt+0x3a>
ffffffffc02040b8:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02040ba:	85a6                	mv	a1,s1
ffffffffc02040bc:	02000513          	li	a0,32
ffffffffc02040c0:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02040c2:	fe0d94e3          	bnez	s11,ffffffffc02040aa <vprintfmt+0x1ce>
ffffffffc02040c6:	bd81                	j	ffffffffc0203f16 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02040c8:	4705                	li	a4,1
ffffffffc02040ca:	008a8593          	addi	a1,s5,8
ffffffffc02040ce:	01074463          	blt	a4,a6,ffffffffc02040d6 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc02040d2:	12080063          	beqz	a6,ffffffffc02041f2 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc02040d6:	000ab603          	ld	a2,0(s5)
ffffffffc02040da:	46a9                	li	a3,10
ffffffffc02040dc:	8aae                	mv	s5,a1
ffffffffc02040de:	b7bd                	j	ffffffffc020404c <vprintfmt+0x170>
ffffffffc02040e0:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc02040e4:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02040e8:	846a                	mv	s0,s10
ffffffffc02040ea:	b5ad                	j	ffffffffc0203f54 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc02040ec:	85a6                	mv	a1,s1
ffffffffc02040ee:	02500513          	li	a0,37
ffffffffc02040f2:	9902                	jalr	s2
            break;
ffffffffc02040f4:	b50d                	j	ffffffffc0203f16 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc02040f6:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc02040fa:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02040fe:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204100:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0204102:	e40dd9e3          	bgez	s11,ffffffffc0203f54 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0204106:	8de6                	mv	s11,s9
ffffffffc0204108:	5cfd                	li	s9,-1
ffffffffc020410a:	b5a9                	j	ffffffffc0203f54 <vprintfmt+0x78>
            goto reswitch;
ffffffffc020410c:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc0204110:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204114:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204116:	bd3d                	j	ffffffffc0203f54 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc0204118:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc020411c:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204120:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0204122:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0204126:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc020412a:	fcd56ce3          	bltu	a0,a3,ffffffffc0204102 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc020412e:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0204130:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0204134:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0204138:	0196873b          	addw	a4,a3,s9
ffffffffc020413c:	0017171b          	slliw	a4,a4,0x1
ffffffffc0204140:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0204144:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0204148:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc020414c:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204150:	fcd57fe3          	bleu	a3,a0,ffffffffc020412e <vprintfmt+0x252>
ffffffffc0204154:	b77d                	j	ffffffffc0204102 <vprintfmt+0x226>
            if (width < 0)
ffffffffc0204156:	fffdc693          	not	a3,s11
ffffffffc020415a:	96fd                	srai	a3,a3,0x3f
ffffffffc020415c:	00ddfdb3          	and	s11,s11,a3
ffffffffc0204160:	00144603          	lbu	a2,1(s0)
ffffffffc0204164:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204166:	846a                	mv	s0,s10
ffffffffc0204168:	b3f5                	j	ffffffffc0203f54 <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc020416a:	85a6                	mv	a1,s1
ffffffffc020416c:	02500513          	li	a0,37
ffffffffc0204170:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0204172:	fff44703          	lbu	a4,-1(s0)
ffffffffc0204176:	02500793          	li	a5,37
ffffffffc020417a:	8d22                	mv	s10,s0
ffffffffc020417c:	d8f70de3          	beq	a4,a5,ffffffffc0203f16 <vprintfmt+0x3a>
ffffffffc0204180:	02500713          	li	a4,37
ffffffffc0204184:	1d7d                	addi	s10,s10,-1
ffffffffc0204186:	fffd4783          	lbu	a5,-1(s10)
ffffffffc020418a:	fee79de3          	bne	a5,a4,ffffffffc0204184 <vprintfmt+0x2a8>
ffffffffc020418e:	b361                	j	ffffffffc0203f16 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0204190:	00002617          	auipc	a2,0x2
ffffffffc0204194:	fb860613          	addi	a2,a2,-72 # ffffffffc0206148 <error_string+0xd8>
ffffffffc0204198:	85a6                	mv	a1,s1
ffffffffc020419a:	854a                	mv	a0,s2
ffffffffc020419c:	0ac000ef          	jal	ra,ffffffffc0204248 <printfmt>
ffffffffc02041a0:	bb9d                	j	ffffffffc0203f16 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02041a2:	00002617          	auipc	a2,0x2
ffffffffc02041a6:	f9e60613          	addi	a2,a2,-98 # ffffffffc0206140 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc02041aa:	00002417          	auipc	s0,0x2
ffffffffc02041ae:	f9740413          	addi	s0,s0,-105 # ffffffffc0206141 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02041b2:	8532                	mv	a0,a2
ffffffffc02041b4:	85e6                	mv	a1,s9
ffffffffc02041b6:	e032                	sd	a2,0(sp)
ffffffffc02041b8:	e43e                	sd	a5,8(sp)
ffffffffc02041ba:	c0dff0ef          	jal	ra,ffffffffc0203dc6 <strnlen>
ffffffffc02041be:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02041c2:	6602                	ld	a2,0(sp)
ffffffffc02041c4:	01b05d63          	blez	s11,ffffffffc02041de <vprintfmt+0x302>
ffffffffc02041c8:	67a2                	ld	a5,8(sp)
ffffffffc02041ca:	2781                	sext.w	a5,a5
ffffffffc02041cc:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc02041ce:	6522                	ld	a0,8(sp)
ffffffffc02041d0:	85a6                	mv	a1,s1
ffffffffc02041d2:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02041d4:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02041d6:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02041d8:	6602                	ld	a2,0(sp)
ffffffffc02041da:	fe0d9ae3          	bnez	s11,ffffffffc02041ce <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02041de:	00064783          	lbu	a5,0(a2)
ffffffffc02041e2:	0007851b          	sext.w	a0,a5
ffffffffc02041e6:	e8051be3          	bnez	a0,ffffffffc020407c <vprintfmt+0x1a0>
ffffffffc02041ea:	b335                	j	ffffffffc0203f16 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc02041ec:	000aa403          	lw	s0,0(s5)
ffffffffc02041f0:	bbf1                	j	ffffffffc0203fcc <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc02041f2:	000ae603          	lwu	a2,0(s5)
ffffffffc02041f6:	46a9                	li	a3,10
ffffffffc02041f8:	8aae                	mv	s5,a1
ffffffffc02041fa:	bd89                	j	ffffffffc020404c <vprintfmt+0x170>
ffffffffc02041fc:	000ae603          	lwu	a2,0(s5)
ffffffffc0204200:	46c1                	li	a3,16
ffffffffc0204202:	8aae                	mv	s5,a1
ffffffffc0204204:	b5a1                	j	ffffffffc020404c <vprintfmt+0x170>
ffffffffc0204206:	000ae603          	lwu	a2,0(s5)
ffffffffc020420a:	46a1                	li	a3,8
ffffffffc020420c:	8aae                	mv	s5,a1
ffffffffc020420e:	bd3d                	j	ffffffffc020404c <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc0204210:	9902                	jalr	s2
ffffffffc0204212:	b559                	j	ffffffffc0204098 <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc0204214:	85a6                	mv	a1,s1
ffffffffc0204216:	02d00513          	li	a0,45
ffffffffc020421a:	e03e                	sd	a5,0(sp)
ffffffffc020421c:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc020421e:	8ace                	mv	s5,s3
ffffffffc0204220:	40800633          	neg	a2,s0
ffffffffc0204224:	46a9                	li	a3,10
ffffffffc0204226:	6782                	ld	a5,0(sp)
ffffffffc0204228:	b515                	j	ffffffffc020404c <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc020422a:	01b05663          	blez	s11,ffffffffc0204236 <vprintfmt+0x35a>
ffffffffc020422e:	02d00693          	li	a3,45
ffffffffc0204232:	f6d798e3          	bne	a5,a3,ffffffffc02041a2 <vprintfmt+0x2c6>
ffffffffc0204236:	00002417          	auipc	s0,0x2
ffffffffc020423a:	f0b40413          	addi	s0,s0,-245 # ffffffffc0206141 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020423e:	02800513          	li	a0,40
ffffffffc0204242:	02800793          	li	a5,40
ffffffffc0204246:	bd1d                	j	ffffffffc020407c <vprintfmt+0x1a0>

ffffffffc0204248 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204248:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc020424a:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020424e:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204250:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204252:	ec06                	sd	ra,24(sp)
ffffffffc0204254:	f83a                	sd	a4,48(sp)
ffffffffc0204256:	fc3e                	sd	a5,56(sp)
ffffffffc0204258:	e0c2                	sd	a6,64(sp)
ffffffffc020425a:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc020425c:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020425e:	c7fff0ef          	jal	ra,ffffffffc0203edc <vprintfmt>
}
ffffffffc0204262:	60e2                	ld	ra,24(sp)
ffffffffc0204264:	6161                	addi	sp,sp,80
ffffffffc0204266:	8082                	ret

ffffffffc0204268 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0204268:	715d                	addi	sp,sp,-80
ffffffffc020426a:	e486                	sd	ra,72(sp)
ffffffffc020426c:	e0a2                	sd	s0,64(sp)
ffffffffc020426e:	fc26                	sd	s1,56(sp)
ffffffffc0204270:	f84a                	sd	s2,48(sp)
ffffffffc0204272:	f44e                	sd	s3,40(sp)
ffffffffc0204274:	f052                	sd	s4,32(sp)
ffffffffc0204276:	ec56                	sd	s5,24(sp)
ffffffffc0204278:	e85a                	sd	s6,16(sp)
ffffffffc020427a:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc020427c:	c901                	beqz	a0,ffffffffc020428c <readline+0x24>
        cprintf("%s", prompt);
ffffffffc020427e:	85aa                	mv	a1,a0
ffffffffc0204280:	00002517          	auipc	a0,0x2
ffffffffc0204284:	ed850513          	addi	a0,a0,-296 # ffffffffc0206158 <error_string+0xe8>
ffffffffc0204288:	e37fb0ef          	jal	ra,ffffffffc02000be <cprintf>
readline(const char *prompt) {
ffffffffc020428c:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020428e:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0204290:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0204292:	4aa9                	li	s5,10
ffffffffc0204294:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0204296:	0000db97          	auipc	s7,0xd
ffffffffc020429a:	daab8b93          	addi	s7,s7,-598 # ffffffffc0211040 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020429e:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02042a2:	e55fb0ef          	jal	ra,ffffffffc02000f6 <getchar>
ffffffffc02042a6:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02042a8:	00054b63          	bltz	a0,ffffffffc02042be <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02042ac:	00a95b63          	ble	a0,s2,ffffffffc02042c2 <readline+0x5a>
ffffffffc02042b0:	029a5463          	ble	s1,s4,ffffffffc02042d8 <readline+0x70>
        c = getchar();
ffffffffc02042b4:	e43fb0ef          	jal	ra,ffffffffc02000f6 <getchar>
ffffffffc02042b8:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02042ba:	fe0559e3          	bgez	a0,ffffffffc02042ac <readline+0x44>
            return NULL;
ffffffffc02042be:	4501                	li	a0,0
ffffffffc02042c0:	a099                	j	ffffffffc0204306 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc02042c2:	03341463          	bne	s0,s3,ffffffffc02042ea <readline+0x82>
ffffffffc02042c6:	e8b9                	bnez	s1,ffffffffc020431c <readline+0xb4>
        c = getchar();
ffffffffc02042c8:	e2ffb0ef          	jal	ra,ffffffffc02000f6 <getchar>
ffffffffc02042cc:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02042ce:	fe0548e3          	bltz	a0,ffffffffc02042be <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02042d2:	fea958e3          	ble	a0,s2,ffffffffc02042c2 <readline+0x5a>
ffffffffc02042d6:	4481                	li	s1,0
            cputchar(c);
ffffffffc02042d8:	8522                	mv	a0,s0
ffffffffc02042da:	e19fb0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            buf[i ++] = c;
ffffffffc02042de:	009b87b3          	add	a5,s7,s1
ffffffffc02042e2:	00878023          	sb	s0,0(a5)
ffffffffc02042e6:	2485                	addiw	s1,s1,1
ffffffffc02042e8:	bf6d                	j	ffffffffc02042a2 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc02042ea:	01540463          	beq	s0,s5,ffffffffc02042f2 <readline+0x8a>
ffffffffc02042ee:	fb641ae3          	bne	s0,s6,ffffffffc02042a2 <readline+0x3a>
            cputchar(c);
ffffffffc02042f2:	8522                	mv	a0,s0
ffffffffc02042f4:	dfffb0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            buf[i] = '\0';
ffffffffc02042f8:	0000d517          	auipc	a0,0xd
ffffffffc02042fc:	d4850513          	addi	a0,a0,-696 # ffffffffc0211040 <buf>
ffffffffc0204300:	94aa                	add	s1,s1,a0
ffffffffc0204302:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0204306:	60a6                	ld	ra,72(sp)
ffffffffc0204308:	6406                	ld	s0,64(sp)
ffffffffc020430a:	74e2                	ld	s1,56(sp)
ffffffffc020430c:	7942                	ld	s2,48(sp)
ffffffffc020430e:	79a2                	ld	s3,40(sp)
ffffffffc0204310:	7a02                	ld	s4,32(sp)
ffffffffc0204312:	6ae2                	ld	s5,24(sp)
ffffffffc0204314:	6b42                	ld	s6,16(sp)
ffffffffc0204316:	6ba2                	ld	s7,8(sp)
ffffffffc0204318:	6161                	addi	sp,sp,80
ffffffffc020431a:	8082                	ret
            cputchar(c);
ffffffffc020431c:	4521                	li	a0,8
ffffffffc020431e:	dd5fb0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            i --;
ffffffffc0204322:	34fd                	addiw	s1,s1,-1
ffffffffc0204324:	bfbd                	j	ffffffffc02042a2 <readline+0x3a>
