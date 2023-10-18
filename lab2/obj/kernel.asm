
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02052b7          	lui	t0,0xc0205
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
ffffffffc0200028:	c0205137          	lui	sp,0xc0205

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc020002c:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200030:	03628293          	addi	t0,t0,54 # ffffffffc0200036 <kern_init>
    jr t0
ffffffffc0200034:	8282                	jr	t0

ffffffffc0200036 <kern_init>:
void grade_backtrace(void);


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	00006517          	auipc	a0,0x6
ffffffffc020003a:	fda50513          	addi	a0,a0,-38 # ffffffffc0206010 <edata>
ffffffffc020003e:	00277617          	auipc	a2,0x277
ffffffffc0200042:	43a60613          	addi	a2,a2,1082 # ffffffffc0477478 <end>
int kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
int kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	2da010ef          	jal	ra,ffffffffc0201328 <memset>
    cons_init();  // init the console
ffffffffc0200052:	3fe000ef          	jal	ra,ffffffffc0200450 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200056:	00001517          	auipc	a0,0x1
ffffffffc020005a:	7f250513          	addi	a0,a0,2034 # ffffffffc0201848 <etext+0x2>
ffffffffc020005e:	090000ef          	jal	ra,ffffffffc02000ee <cputs>

    print_kerninfo();
ffffffffc0200062:	13c000ef          	jal	ra,ffffffffc020019e <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200066:	404000ef          	jal	ra,ffffffffc020046a <idt_init>

    pmm_init();  // init physical memory management
ffffffffc020006a:	04b000ef          	jal	ra,ffffffffc02008b4 <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006e:	3fc000ef          	jal	ra,ffffffffc020046a <idt_init>

    clock_init();   // init clock interrupt
ffffffffc0200072:	39a000ef          	jal	ra,ffffffffc020040c <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200076:	3e8000ef          	jal	ra,ffffffffc020045e <intr_enable>



    /* do nothing */
    while (1)
        ;
ffffffffc020007a:	a001                	j	ffffffffc020007a <kern_init+0x44>

ffffffffc020007c <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc020007c:	1141                	addi	sp,sp,-16
ffffffffc020007e:	e022                	sd	s0,0(sp)
ffffffffc0200080:	e406                	sd	ra,8(sp)
ffffffffc0200082:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200084:	3ce000ef          	jal	ra,ffffffffc0200452 <cons_putc>
    (*cnt) ++;
ffffffffc0200088:	401c                	lw	a5,0(s0)
}
ffffffffc020008a:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc020008c:	2785                	addiw	a5,a5,1
ffffffffc020008e:	c01c                	sw	a5,0(s0)
}
ffffffffc0200090:	6402                	ld	s0,0(sp)
ffffffffc0200092:	0141                	addi	sp,sp,16
ffffffffc0200094:	8082                	ret

ffffffffc0200096 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200096:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200098:	86ae                	mv	a3,a1
ffffffffc020009a:	862a                	mv	a2,a0
ffffffffc020009c:	006c                	addi	a1,sp,12
ffffffffc020009e:	00000517          	auipc	a0,0x0
ffffffffc02000a2:	fde50513          	addi	a0,a0,-34 # ffffffffc020007c <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000a6:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000a8:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000aa:	2fc010ef          	jal	ra,ffffffffc02013a6 <vprintfmt>
    return cnt;
}
ffffffffc02000ae:	60e2                	ld	ra,24(sp)
ffffffffc02000b0:	4532                	lw	a0,12(sp)
ffffffffc02000b2:	6105                	addi	sp,sp,32
ffffffffc02000b4:	8082                	ret

ffffffffc02000b6 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000b6:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000b8:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000bc:	f42e                	sd	a1,40(sp)
ffffffffc02000be:	f832                	sd	a2,48(sp)
ffffffffc02000c0:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c2:	862a                	mv	a2,a0
ffffffffc02000c4:	004c                	addi	a1,sp,4
ffffffffc02000c6:	00000517          	auipc	a0,0x0
ffffffffc02000ca:	fb650513          	addi	a0,a0,-74 # ffffffffc020007c <cputch>
ffffffffc02000ce:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000d0:	ec06                	sd	ra,24(sp)
ffffffffc02000d2:	e0ba                	sd	a4,64(sp)
ffffffffc02000d4:	e4be                	sd	a5,72(sp)
ffffffffc02000d6:	e8c2                	sd	a6,80(sp)
ffffffffc02000d8:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000da:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000dc:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000de:	2c8010ef          	jal	ra,ffffffffc02013a6 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e2:	60e2                	ld	ra,24(sp)
ffffffffc02000e4:	4512                	lw	a0,4(sp)
ffffffffc02000e6:	6125                	addi	sp,sp,96
ffffffffc02000e8:	8082                	ret

ffffffffc02000ea <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000ea:	3680006f          	j	ffffffffc0200452 <cons_putc>

ffffffffc02000ee <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000ee:	1101                	addi	sp,sp,-32
ffffffffc02000f0:	e822                	sd	s0,16(sp)
ffffffffc02000f2:	ec06                	sd	ra,24(sp)
ffffffffc02000f4:	e426                	sd	s1,8(sp)
ffffffffc02000f6:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000f8:	00054503          	lbu	a0,0(a0)
ffffffffc02000fc:	c51d                	beqz	a0,ffffffffc020012a <cputs+0x3c>
ffffffffc02000fe:	0405                	addi	s0,s0,1
ffffffffc0200100:	4485                	li	s1,1
ffffffffc0200102:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200104:	34e000ef          	jal	ra,ffffffffc0200452 <cons_putc>
    (*cnt) ++;
ffffffffc0200108:	008487bb          	addw	a5,s1,s0
    while ((c = *str ++) != '\0') {
ffffffffc020010c:	0405                	addi	s0,s0,1
ffffffffc020010e:	fff44503          	lbu	a0,-1(s0)
ffffffffc0200112:	f96d                	bnez	a0,ffffffffc0200104 <cputs+0x16>
ffffffffc0200114:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200118:	4529                	li	a0,10
ffffffffc020011a:	338000ef          	jal	ra,ffffffffc0200452 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020011e:	8522                	mv	a0,s0
ffffffffc0200120:	60e2                	ld	ra,24(sp)
ffffffffc0200122:	6442                	ld	s0,16(sp)
ffffffffc0200124:	64a2                	ld	s1,8(sp)
ffffffffc0200126:	6105                	addi	sp,sp,32
ffffffffc0200128:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc020012a:	4405                	li	s0,1
ffffffffc020012c:	b7f5                	j	ffffffffc0200118 <cputs+0x2a>

ffffffffc020012e <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020012e:	1141                	addi	sp,sp,-16
ffffffffc0200130:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200132:	328000ef          	jal	ra,ffffffffc020045a <cons_getc>
ffffffffc0200136:	dd75                	beqz	a0,ffffffffc0200132 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200138:	60a2                	ld	ra,8(sp)
ffffffffc020013a:	0141                	addi	sp,sp,16
ffffffffc020013c:	8082                	ret

ffffffffc020013e <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc020013e:	00006317          	auipc	t1,0x6
ffffffffc0200142:	2d230313          	addi	t1,t1,722 # ffffffffc0206410 <is_panic>
ffffffffc0200146:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc020014a:	715d                	addi	sp,sp,-80
ffffffffc020014c:	ec06                	sd	ra,24(sp)
ffffffffc020014e:	e822                	sd	s0,16(sp)
ffffffffc0200150:	f436                	sd	a3,40(sp)
ffffffffc0200152:	f83a                	sd	a4,48(sp)
ffffffffc0200154:	fc3e                	sd	a5,56(sp)
ffffffffc0200156:	e0c2                	sd	a6,64(sp)
ffffffffc0200158:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc020015a:	02031c63          	bnez	t1,ffffffffc0200192 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc020015e:	4785                	li	a5,1
ffffffffc0200160:	8432                	mv	s0,a2
ffffffffc0200162:	00006717          	auipc	a4,0x6
ffffffffc0200166:	2af72723          	sw	a5,686(a4) # ffffffffc0206410 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020016a:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc020016c:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020016e:	85aa                	mv	a1,a0
ffffffffc0200170:	00001517          	auipc	a0,0x1
ffffffffc0200174:	6f850513          	addi	a0,a0,1784 # ffffffffc0201868 <etext+0x22>
    va_start(ap, fmt);
ffffffffc0200178:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020017a:	f3dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    vcprintf(fmt, ap);
ffffffffc020017e:	65a2                	ld	a1,8(sp)
ffffffffc0200180:	8522                	mv	a0,s0
ffffffffc0200182:	f15ff0ef          	jal	ra,ffffffffc0200096 <vcprintf>
    cprintf("\n");
ffffffffc0200186:	00001517          	auipc	a0,0x1
ffffffffc020018a:	7fa50513          	addi	a0,a0,2042 # ffffffffc0201980 <etext+0x13a>
ffffffffc020018e:	f29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc0200192:	2d2000ef          	jal	ra,ffffffffc0200464 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200196:	4501                	li	a0,0
ffffffffc0200198:	132000ef          	jal	ra,ffffffffc02002ca <kmonitor>
ffffffffc020019c:	bfed                	j	ffffffffc0200196 <__panic+0x58>

ffffffffc020019e <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020019e:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc02001a0:	00001517          	auipc	a0,0x1
ffffffffc02001a4:	71850513          	addi	a0,a0,1816 # ffffffffc02018b8 <etext+0x72>
void print_kerninfo(void) {
ffffffffc02001a8:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02001aa:	f0dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc02001ae:	00000597          	auipc	a1,0x0
ffffffffc02001b2:	e8858593          	addi	a1,a1,-376 # ffffffffc0200036 <kern_init>
ffffffffc02001b6:	00001517          	auipc	a0,0x1
ffffffffc02001ba:	72250513          	addi	a0,a0,1826 # ffffffffc02018d8 <etext+0x92>
ffffffffc02001be:	ef9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc02001c2:	00001597          	auipc	a1,0x1
ffffffffc02001c6:	68458593          	addi	a1,a1,1668 # ffffffffc0201846 <etext>
ffffffffc02001ca:	00001517          	auipc	a0,0x1
ffffffffc02001ce:	72e50513          	addi	a0,a0,1838 # ffffffffc02018f8 <etext+0xb2>
ffffffffc02001d2:	ee5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc02001d6:	00006597          	auipc	a1,0x6
ffffffffc02001da:	e3a58593          	addi	a1,a1,-454 # ffffffffc0206010 <edata>
ffffffffc02001de:	00001517          	auipc	a0,0x1
ffffffffc02001e2:	73a50513          	addi	a0,a0,1850 # ffffffffc0201918 <etext+0xd2>
ffffffffc02001e6:	ed1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc02001ea:	00277597          	auipc	a1,0x277
ffffffffc02001ee:	28e58593          	addi	a1,a1,654 # ffffffffc0477478 <end>
ffffffffc02001f2:	00001517          	auipc	a0,0x1
ffffffffc02001f6:	74650513          	addi	a0,a0,1862 # ffffffffc0201938 <etext+0xf2>
ffffffffc02001fa:	ebdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc02001fe:	00277597          	auipc	a1,0x277
ffffffffc0200202:	67958593          	addi	a1,a1,1657 # ffffffffc0477877 <end+0x3ff>
ffffffffc0200206:	00000797          	auipc	a5,0x0
ffffffffc020020a:	e3078793          	addi	a5,a5,-464 # ffffffffc0200036 <kern_init>
ffffffffc020020e:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200212:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc0200216:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200218:	3ff5f593          	andi	a1,a1,1023
ffffffffc020021c:	95be                	add	a1,a1,a5
ffffffffc020021e:	85a9                	srai	a1,a1,0xa
ffffffffc0200220:	00001517          	auipc	a0,0x1
ffffffffc0200224:	73850513          	addi	a0,a0,1848 # ffffffffc0201958 <etext+0x112>
}
ffffffffc0200228:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020022a:	e8dff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc020022e <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc020022e:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc0200230:	00001617          	auipc	a2,0x1
ffffffffc0200234:	65860613          	addi	a2,a2,1624 # ffffffffc0201888 <etext+0x42>
ffffffffc0200238:	04e00593          	li	a1,78
ffffffffc020023c:	00001517          	auipc	a0,0x1
ffffffffc0200240:	66450513          	addi	a0,a0,1636 # ffffffffc02018a0 <etext+0x5a>
void print_stackframe(void) {
ffffffffc0200244:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc0200246:	ef9ff0ef          	jal	ra,ffffffffc020013e <__panic>

ffffffffc020024a <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020024a:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020024c:	00002617          	auipc	a2,0x2
ffffffffc0200250:	81c60613          	addi	a2,a2,-2020 # ffffffffc0201a68 <commands+0xe0>
ffffffffc0200254:	00002597          	auipc	a1,0x2
ffffffffc0200258:	83458593          	addi	a1,a1,-1996 # ffffffffc0201a88 <commands+0x100>
ffffffffc020025c:	00002517          	auipc	a0,0x2
ffffffffc0200260:	83450513          	addi	a0,a0,-1996 # ffffffffc0201a90 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200264:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200266:	e51ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020026a:	00002617          	auipc	a2,0x2
ffffffffc020026e:	83660613          	addi	a2,a2,-1994 # ffffffffc0201aa0 <commands+0x118>
ffffffffc0200272:	00002597          	auipc	a1,0x2
ffffffffc0200276:	85658593          	addi	a1,a1,-1962 # ffffffffc0201ac8 <commands+0x140>
ffffffffc020027a:	00002517          	auipc	a0,0x2
ffffffffc020027e:	81650513          	addi	a0,a0,-2026 # ffffffffc0201a90 <commands+0x108>
ffffffffc0200282:	e35ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200286:	00002617          	auipc	a2,0x2
ffffffffc020028a:	85260613          	addi	a2,a2,-1966 # ffffffffc0201ad8 <commands+0x150>
ffffffffc020028e:	00002597          	auipc	a1,0x2
ffffffffc0200292:	86a58593          	addi	a1,a1,-1942 # ffffffffc0201af8 <commands+0x170>
ffffffffc0200296:	00001517          	auipc	a0,0x1
ffffffffc020029a:	7fa50513          	addi	a0,a0,2042 # ffffffffc0201a90 <commands+0x108>
ffffffffc020029e:	e19ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    }
    return 0;
}
ffffffffc02002a2:	60a2                	ld	ra,8(sp)
ffffffffc02002a4:	4501                	li	a0,0
ffffffffc02002a6:	0141                	addi	sp,sp,16
ffffffffc02002a8:	8082                	ret

ffffffffc02002aa <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002aa:	1141                	addi	sp,sp,-16
ffffffffc02002ac:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02002ae:	ef1ff0ef          	jal	ra,ffffffffc020019e <print_kerninfo>
    return 0;
}
ffffffffc02002b2:	60a2                	ld	ra,8(sp)
ffffffffc02002b4:	4501                	li	a0,0
ffffffffc02002b6:	0141                	addi	sp,sp,16
ffffffffc02002b8:	8082                	ret

ffffffffc02002ba <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002ba:	1141                	addi	sp,sp,-16
ffffffffc02002bc:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02002be:	f71ff0ef          	jal	ra,ffffffffc020022e <print_stackframe>
    return 0;
}
ffffffffc02002c2:	60a2                	ld	ra,8(sp)
ffffffffc02002c4:	4501                	li	a0,0
ffffffffc02002c6:	0141                	addi	sp,sp,16
ffffffffc02002c8:	8082                	ret

ffffffffc02002ca <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc02002ca:	7115                	addi	sp,sp,-224
ffffffffc02002cc:	e962                	sd	s8,144(sp)
ffffffffc02002ce:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002d0:	00001517          	auipc	a0,0x1
ffffffffc02002d4:	70050513          	addi	a0,a0,1792 # ffffffffc02019d0 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc02002d8:	ed86                	sd	ra,216(sp)
ffffffffc02002da:	e9a2                	sd	s0,208(sp)
ffffffffc02002dc:	e5a6                	sd	s1,200(sp)
ffffffffc02002de:	e1ca                	sd	s2,192(sp)
ffffffffc02002e0:	fd4e                	sd	s3,184(sp)
ffffffffc02002e2:	f952                	sd	s4,176(sp)
ffffffffc02002e4:	f556                	sd	s5,168(sp)
ffffffffc02002e6:	f15a                	sd	s6,160(sp)
ffffffffc02002e8:	ed5e                	sd	s7,152(sp)
ffffffffc02002ea:	e566                	sd	s9,136(sp)
ffffffffc02002ec:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002ee:	dc9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc02002f2:	00001517          	auipc	a0,0x1
ffffffffc02002f6:	70650513          	addi	a0,a0,1798 # ffffffffc02019f8 <commands+0x70>
ffffffffc02002fa:	dbdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    if (tf != NULL) {
ffffffffc02002fe:	000c0563          	beqz	s8,ffffffffc0200308 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200302:	8562                	mv	a0,s8
ffffffffc0200304:	346000ef          	jal	ra,ffffffffc020064a <print_trapframe>
ffffffffc0200308:	00001c97          	auipc	s9,0x1
ffffffffc020030c:	680c8c93          	addi	s9,s9,1664 # ffffffffc0201988 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200310:	00001997          	auipc	s3,0x1
ffffffffc0200314:	71098993          	addi	s3,s3,1808 # ffffffffc0201a20 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200318:	00001917          	auipc	s2,0x1
ffffffffc020031c:	71090913          	addi	s2,s2,1808 # ffffffffc0201a28 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc0200320:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200322:	00001b17          	auipc	s6,0x1
ffffffffc0200326:	70eb0b13          	addi	s6,s6,1806 # ffffffffc0201a30 <commands+0xa8>
    if (argc == 0) {
ffffffffc020032a:	00001a97          	auipc	s5,0x1
ffffffffc020032e:	75ea8a93          	addi	s5,s5,1886 # ffffffffc0201a88 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200332:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200334:	854e                	mv	a0,s3
ffffffffc0200336:	3fc010ef          	jal	ra,ffffffffc0201732 <readline>
ffffffffc020033a:	842a                	mv	s0,a0
ffffffffc020033c:	dd65                	beqz	a0,ffffffffc0200334 <kmonitor+0x6a>
ffffffffc020033e:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200342:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200344:	c999                	beqz	a1,ffffffffc020035a <kmonitor+0x90>
ffffffffc0200346:	854a                	mv	a0,s2
ffffffffc0200348:	7c3000ef          	jal	ra,ffffffffc020130a <strchr>
ffffffffc020034c:	c925                	beqz	a0,ffffffffc02003bc <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc020034e:	00144583          	lbu	a1,1(s0)
ffffffffc0200352:	00040023          	sb	zero,0(s0)
ffffffffc0200356:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200358:	f5fd                	bnez	a1,ffffffffc0200346 <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc020035a:	dce9                	beqz	s1,ffffffffc0200334 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020035c:	6582                	ld	a1,0(sp)
ffffffffc020035e:	00001d17          	auipc	s10,0x1
ffffffffc0200362:	62ad0d13          	addi	s10,s10,1578 # ffffffffc0201988 <commands>
    if (argc == 0) {
ffffffffc0200366:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200368:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020036a:	0d61                	addi	s10,s10,24
ffffffffc020036c:	775000ef          	jal	ra,ffffffffc02012e0 <strcmp>
ffffffffc0200370:	c919                	beqz	a0,ffffffffc0200386 <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200372:	2405                	addiw	s0,s0,1
ffffffffc0200374:	09740463          	beq	s0,s7,ffffffffc02003fc <kmonitor+0x132>
ffffffffc0200378:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020037c:	6582                	ld	a1,0(sp)
ffffffffc020037e:	0d61                	addi	s10,s10,24
ffffffffc0200380:	761000ef          	jal	ra,ffffffffc02012e0 <strcmp>
ffffffffc0200384:	f57d                	bnez	a0,ffffffffc0200372 <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200386:	00141793          	slli	a5,s0,0x1
ffffffffc020038a:	97a2                	add	a5,a5,s0
ffffffffc020038c:	078e                	slli	a5,a5,0x3
ffffffffc020038e:	97e6                	add	a5,a5,s9
ffffffffc0200390:	6b9c                	ld	a5,16(a5)
ffffffffc0200392:	8662                	mv	a2,s8
ffffffffc0200394:	002c                	addi	a1,sp,8
ffffffffc0200396:	fff4851b          	addiw	a0,s1,-1
ffffffffc020039a:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc020039c:	f8055ce3          	bgez	a0,ffffffffc0200334 <kmonitor+0x6a>
}
ffffffffc02003a0:	60ee                	ld	ra,216(sp)
ffffffffc02003a2:	644e                	ld	s0,208(sp)
ffffffffc02003a4:	64ae                	ld	s1,200(sp)
ffffffffc02003a6:	690e                	ld	s2,192(sp)
ffffffffc02003a8:	79ea                	ld	s3,184(sp)
ffffffffc02003aa:	7a4a                	ld	s4,176(sp)
ffffffffc02003ac:	7aaa                	ld	s5,168(sp)
ffffffffc02003ae:	7b0a                	ld	s6,160(sp)
ffffffffc02003b0:	6bea                	ld	s7,152(sp)
ffffffffc02003b2:	6c4a                	ld	s8,144(sp)
ffffffffc02003b4:	6caa                	ld	s9,136(sp)
ffffffffc02003b6:	6d0a                	ld	s10,128(sp)
ffffffffc02003b8:	612d                	addi	sp,sp,224
ffffffffc02003ba:	8082                	ret
        if (*buf == '\0') {
ffffffffc02003bc:	00044783          	lbu	a5,0(s0)
ffffffffc02003c0:	dfc9                	beqz	a5,ffffffffc020035a <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc02003c2:	03448863          	beq	s1,s4,ffffffffc02003f2 <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc02003c6:	00349793          	slli	a5,s1,0x3
ffffffffc02003ca:	0118                	addi	a4,sp,128
ffffffffc02003cc:	97ba                	add	a5,a5,a4
ffffffffc02003ce:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003d2:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc02003d6:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003d8:	e591                	bnez	a1,ffffffffc02003e4 <kmonitor+0x11a>
ffffffffc02003da:	b749                	j	ffffffffc020035c <kmonitor+0x92>
            buf ++;
ffffffffc02003dc:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003de:	00044583          	lbu	a1,0(s0)
ffffffffc02003e2:	ddad                	beqz	a1,ffffffffc020035c <kmonitor+0x92>
ffffffffc02003e4:	854a                	mv	a0,s2
ffffffffc02003e6:	725000ef          	jal	ra,ffffffffc020130a <strchr>
ffffffffc02003ea:	d96d                	beqz	a0,ffffffffc02003dc <kmonitor+0x112>
ffffffffc02003ec:	00044583          	lbu	a1,0(s0)
ffffffffc02003f0:	bf91                	j	ffffffffc0200344 <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02003f2:	45c1                	li	a1,16
ffffffffc02003f4:	855a                	mv	a0,s6
ffffffffc02003f6:	cc1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02003fa:	b7f1                	j	ffffffffc02003c6 <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc02003fc:	6582                	ld	a1,0(sp)
ffffffffc02003fe:	00001517          	auipc	a0,0x1
ffffffffc0200402:	65250513          	addi	a0,a0,1618 # ffffffffc0201a50 <commands+0xc8>
ffffffffc0200406:	cb1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    return 0;
ffffffffc020040a:	b72d                	j	ffffffffc0200334 <kmonitor+0x6a>

ffffffffc020040c <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc020040c:	1141                	addi	sp,sp,-16
ffffffffc020040e:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc0200410:	02000793          	li	a5,32
ffffffffc0200414:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200418:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020041c:	67e1                	lui	a5,0x18
ffffffffc020041e:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc0200422:	953e                	add	a0,a0,a5
ffffffffc0200424:	3e8010ef          	jal	ra,ffffffffc020180c <sbi_set_timer>
}
ffffffffc0200428:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc020042a:	00006797          	auipc	a5,0x6
ffffffffc020042e:	0007b323          	sd	zero,6(a5) # ffffffffc0206430 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200432:	00001517          	auipc	a0,0x1
ffffffffc0200436:	6d650513          	addi	a0,a0,1750 # ffffffffc0201b08 <commands+0x180>
}
ffffffffc020043a:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc020043c:	c7bff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc0200440 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200440:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200444:	67e1                	lui	a5,0x18
ffffffffc0200446:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc020044a:	953e                	add	a0,a0,a5
ffffffffc020044c:	3c00106f          	j	ffffffffc020180c <sbi_set_timer>

ffffffffc0200450 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200450:	8082                	ret

ffffffffc0200452 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc0200452:	0ff57513          	andi	a0,a0,255
ffffffffc0200456:	39a0106f          	j	ffffffffc02017f0 <sbi_console_putchar>

ffffffffc020045a <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc020045a:	3ce0106f          	j	ffffffffc0201828 <sbi_console_getchar>

ffffffffc020045e <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc020045e:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200462:	8082                	ret

ffffffffc0200464 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200464:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200468:	8082                	ret

ffffffffc020046a <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020046a:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc020046e:	00000797          	auipc	a5,0x0
ffffffffc0200472:	30678793          	addi	a5,a5,774 # ffffffffc0200774 <__alltraps>
ffffffffc0200476:	10579073          	csrw	stvec,a5
}
ffffffffc020047a:	8082                	ret

ffffffffc020047c <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020047c:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc020047e:	1141                	addi	sp,sp,-16
ffffffffc0200480:	e022                	sd	s0,0(sp)
ffffffffc0200482:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200484:	00001517          	auipc	a0,0x1
ffffffffc0200488:	79c50513          	addi	a0,a0,1948 # ffffffffc0201c20 <commands+0x298>
void print_regs(struct pushregs *gpr) {
ffffffffc020048c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020048e:	c29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200492:	640c                	ld	a1,8(s0)
ffffffffc0200494:	00001517          	auipc	a0,0x1
ffffffffc0200498:	7a450513          	addi	a0,a0,1956 # ffffffffc0201c38 <commands+0x2b0>
ffffffffc020049c:	c1bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02004a0:	680c                	ld	a1,16(s0)
ffffffffc02004a2:	00001517          	auipc	a0,0x1
ffffffffc02004a6:	7ae50513          	addi	a0,a0,1966 # ffffffffc0201c50 <commands+0x2c8>
ffffffffc02004aa:	c0dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004ae:	6c0c                	ld	a1,24(s0)
ffffffffc02004b0:	00001517          	auipc	a0,0x1
ffffffffc02004b4:	7b850513          	addi	a0,a0,1976 # ffffffffc0201c68 <commands+0x2e0>
ffffffffc02004b8:	bffff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004bc:	700c                	ld	a1,32(s0)
ffffffffc02004be:	00001517          	auipc	a0,0x1
ffffffffc02004c2:	7c250513          	addi	a0,a0,1986 # ffffffffc0201c80 <commands+0x2f8>
ffffffffc02004c6:	bf1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004ca:	740c                	ld	a1,40(s0)
ffffffffc02004cc:	00001517          	auipc	a0,0x1
ffffffffc02004d0:	7cc50513          	addi	a0,a0,1996 # ffffffffc0201c98 <commands+0x310>
ffffffffc02004d4:	be3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d8:	780c                	ld	a1,48(s0)
ffffffffc02004da:	00001517          	auipc	a0,0x1
ffffffffc02004de:	7d650513          	addi	a0,a0,2006 # ffffffffc0201cb0 <commands+0x328>
ffffffffc02004e2:	bd5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e6:	7c0c                	ld	a1,56(s0)
ffffffffc02004e8:	00001517          	auipc	a0,0x1
ffffffffc02004ec:	7e050513          	addi	a0,a0,2016 # ffffffffc0201cc8 <commands+0x340>
ffffffffc02004f0:	bc7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004f4:	602c                	ld	a1,64(s0)
ffffffffc02004f6:	00001517          	auipc	a0,0x1
ffffffffc02004fa:	7ea50513          	addi	a0,a0,2026 # ffffffffc0201ce0 <commands+0x358>
ffffffffc02004fe:	bb9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200502:	642c                	ld	a1,72(s0)
ffffffffc0200504:	00001517          	auipc	a0,0x1
ffffffffc0200508:	7f450513          	addi	a0,a0,2036 # ffffffffc0201cf8 <commands+0x370>
ffffffffc020050c:	babff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200510:	682c                	ld	a1,80(s0)
ffffffffc0200512:	00001517          	auipc	a0,0x1
ffffffffc0200516:	7fe50513          	addi	a0,a0,2046 # ffffffffc0201d10 <commands+0x388>
ffffffffc020051a:	b9dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020051e:	6c2c                	ld	a1,88(s0)
ffffffffc0200520:	00002517          	auipc	a0,0x2
ffffffffc0200524:	80850513          	addi	a0,a0,-2040 # ffffffffc0201d28 <commands+0x3a0>
ffffffffc0200528:	b8fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020052c:	702c                	ld	a1,96(s0)
ffffffffc020052e:	00002517          	auipc	a0,0x2
ffffffffc0200532:	81250513          	addi	a0,a0,-2030 # ffffffffc0201d40 <commands+0x3b8>
ffffffffc0200536:	b81ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020053a:	742c                	ld	a1,104(s0)
ffffffffc020053c:	00002517          	auipc	a0,0x2
ffffffffc0200540:	81c50513          	addi	a0,a0,-2020 # ffffffffc0201d58 <commands+0x3d0>
ffffffffc0200544:	b73ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200548:	782c                	ld	a1,112(s0)
ffffffffc020054a:	00002517          	auipc	a0,0x2
ffffffffc020054e:	82650513          	addi	a0,a0,-2010 # ffffffffc0201d70 <commands+0x3e8>
ffffffffc0200552:	b65ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200556:	7c2c                	ld	a1,120(s0)
ffffffffc0200558:	00002517          	auipc	a0,0x2
ffffffffc020055c:	83050513          	addi	a0,a0,-2000 # ffffffffc0201d88 <commands+0x400>
ffffffffc0200560:	b57ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200564:	604c                	ld	a1,128(s0)
ffffffffc0200566:	00002517          	auipc	a0,0x2
ffffffffc020056a:	83a50513          	addi	a0,a0,-1990 # ffffffffc0201da0 <commands+0x418>
ffffffffc020056e:	b49ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200572:	644c                	ld	a1,136(s0)
ffffffffc0200574:	00002517          	auipc	a0,0x2
ffffffffc0200578:	84450513          	addi	a0,a0,-1980 # ffffffffc0201db8 <commands+0x430>
ffffffffc020057c:	b3bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200580:	684c                	ld	a1,144(s0)
ffffffffc0200582:	00002517          	auipc	a0,0x2
ffffffffc0200586:	84e50513          	addi	a0,a0,-1970 # ffffffffc0201dd0 <commands+0x448>
ffffffffc020058a:	b2dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020058e:	6c4c                	ld	a1,152(s0)
ffffffffc0200590:	00002517          	auipc	a0,0x2
ffffffffc0200594:	85850513          	addi	a0,a0,-1960 # ffffffffc0201de8 <commands+0x460>
ffffffffc0200598:	b1fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020059c:	704c                	ld	a1,160(s0)
ffffffffc020059e:	00002517          	auipc	a0,0x2
ffffffffc02005a2:	86250513          	addi	a0,a0,-1950 # ffffffffc0201e00 <commands+0x478>
ffffffffc02005a6:	b11ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005aa:	744c                	ld	a1,168(s0)
ffffffffc02005ac:	00002517          	auipc	a0,0x2
ffffffffc02005b0:	86c50513          	addi	a0,a0,-1940 # ffffffffc0201e18 <commands+0x490>
ffffffffc02005b4:	b03ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b8:	784c                	ld	a1,176(s0)
ffffffffc02005ba:	00002517          	auipc	a0,0x2
ffffffffc02005be:	87650513          	addi	a0,a0,-1930 # ffffffffc0201e30 <commands+0x4a8>
ffffffffc02005c2:	af5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c6:	7c4c                	ld	a1,184(s0)
ffffffffc02005c8:	00002517          	auipc	a0,0x2
ffffffffc02005cc:	88050513          	addi	a0,a0,-1920 # ffffffffc0201e48 <commands+0x4c0>
ffffffffc02005d0:	ae7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005d4:	606c                	ld	a1,192(s0)
ffffffffc02005d6:	00002517          	auipc	a0,0x2
ffffffffc02005da:	88a50513          	addi	a0,a0,-1910 # ffffffffc0201e60 <commands+0x4d8>
ffffffffc02005de:	ad9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005e2:	646c                	ld	a1,200(s0)
ffffffffc02005e4:	00002517          	auipc	a0,0x2
ffffffffc02005e8:	89450513          	addi	a0,a0,-1900 # ffffffffc0201e78 <commands+0x4f0>
ffffffffc02005ec:	acbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005f0:	686c                	ld	a1,208(s0)
ffffffffc02005f2:	00002517          	auipc	a0,0x2
ffffffffc02005f6:	89e50513          	addi	a0,a0,-1890 # ffffffffc0201e90 <commands+0x508>
ffffffffc02005fa:	abdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005fe:	6c6c                	ld	a1,216(s0)
ffffffffc0200600:	00002517          	auipc	a0,0x2
ffffffffc0200604:	8a850513          	addi	a0,a0,-1880 # ffffffffc0201ea8 <commands+0x520>
ffffffffc0200608:	aafff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc020060c:	706c                	ld	a1,224(s0)
ffffffffc020060e:	00002517          	auipc	a0,0x2
ffffffffc0200612:	8b250513          	addi	a0,a0,-1870 # ffffffffc0201ec0 <commands+0x538>
ffffffffc0200616:	aa1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020061a:	746c                	ld	a1,232(s0)
ffffffffc020061c:	00002517          	auipc	a0,0x2
ffffffffc0200620:	8bc50513          	addi	a0,a0,-1860 # ffffffffc0201ed8 <commands+0x550>
ffffffffc0200624:	a93ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200628:	786c                	ld	a1,240(s0)
ffffffffc020062a:	00002517          	auipc	a0,0x2
ffffffffc020062e:	8c650513          	addi	a0,a0,-1850 # ffffffffc0201ef0 <commands+0x568>
ffffffffc0200632:	a85ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200638:	6402                	ld	s0,0(sp)
ffffffffc020063a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020063c:	00002517          	auipc	a0,0x2
ffffffffc0200640:	8cc50513          	addi	a0,a0,-1844 # ffffffffc0201f08 <commands+0x580>
}
ffffffffc0200644:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200646:	a71ff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc020064a <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020064a:	1141                	addi	sp,sp,-16
ffffffffc020064c:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020064e:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200650:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200652:	00002517          	auipc	a0,0x2
ffffffffc0200656:	8ce50513          	addi	a0,a0,-1842 # ffffffffc0201f20 <commands+0x598>
void print_trapframe(struct trapframe *tf) {
ffffffffc020065a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020065c:	a5bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200660:	8522                	mv	a0,s0
ffffffffc0200662:	e1bff0ef          	jal	ra,ffffffffc020047c <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200666:	10043583          	ld	a1,256(s0)
ffffffffc020066a:	00002517          	auipc	a0,0x2
ffffffffc020066e:	8ce50513          	addi	a0,a0,-1842 # ffffffffc0201f38 <commands+0x5b0>
ffffffffc0200672:	a45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200676:	10843583          	ld	a1,264(s0)
ffffffffc020067a:	00002517          	auipc	a0,0x2
ffffffffc020067e:	8d650513          	addi	a0,a0,-1834 # ffffffffc0201f50 <commands+0x5c8>
ffffffffc0200682:	a35ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200686:	11043583          	ld	a1,272(s0)
ffffffffc020068a:	00002517          	auipc	a0,0x2
ffffffffc020068e:	8de50513          	addi	a0,a0,-1826 # ffffffffc0201f68 <commands+0x5e0>
ffffffffc0200692:	a25ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	11843583          	ld	a1,280(s0)
}
ffffffffc020069a:	6402                	ld	s0,0(sp)
ffffffffc020069c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020069e:	00002517          	auipc	a0,0x2
ffffffffc02006a2:	8e250513          	addi	a0,a0,-1822 # ffffffffc0201f80 <commands+0x5f8>
}
ffffffffc02006a6:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006a8:	a0fff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc02006ac <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006ac:	11853783          	ld	a5,280(a0)
ffffffffc02006b0:	577d                	li	a4,-1
ffffffffc02006b2:	8305                	srli	a4,a4,0x1
ffffffffc02006b4:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02006b6:	472d                	li	a4,11
ffffffffc02006b8:	08f76563          	bltu	a4,a5,ffffffffc0200742 <interrupt_handler+0x96>
ffffffffc02006bc:	00001717          	auipc	a4,0x1
ffffffffc02006c0:	46870713          	addi	a4,a4,1128 # ffffffffc0201b24 <commands+0x19c>
ffffffffc02006c4:	078a                	slli	a5,a5,0x2
ffffffffc02006c6:	97ba                	add	a5,a5,a4
ffffffffc02006c8:	439c                	lw	a5,0(a5)
ffffffffc02006ca:	97ba                	add	a5,a5,a4
ffffffffc02006cc:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02006ce:	00001517          	auipc	a0,0x1
ffffffffc02006d2:	4ea50513          	addi	a0,a0,1258 # ffffffffc0201bb8 <commands+0x230>
ffffffffc02006d6:	9e1ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006da:	00001517          	auipc	a0,0x1
ffffffffc02006de:	4be50513          	addi	a0,a0,1214 # ffffffffc0201b98 <commands+0x210>
ffffffffc02006e2:	9d5ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006e6:	00001517          	auipc	a0,0x1
ffffffffc02006ea:	47250513          	addi	a0,a0,1138 # ffffffffc0201b58 <commands+0x1d0>
ffffffffc02006ee:	9c9ff06f          	j	ffffffffc02000b6 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006f2:	00001517          	auipc	a0,0x1
ffffffffc02006f6:	4e650513          	addi	a0,a0,1254 # ffffffffc0201bd8 <commands+0x250>
ffffffffc02006fa:	9bdff06f          	j	ffffffffc02000b6 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02006fe:	1141                	addi	sp,sp,-16
ffffffffc0200700:	e406                	sd	ra,8(sp)
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc0200702:	d3fff0ef          	jal	ra,ffffffffc0200440 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc0200706:	00006797          	auipc	a5,0x6
ffffffffc020070a:	d2a78793          	addi	a5,a5,-726 # ffffffffc0206430 <ticks>
ffffffffc020070e:	639c                	ld	a5,0(a5)
ffffffffc0200710:	06400713          	li	a4,100
ffffffffc0200714:	0785                	addi	a5,a5,1
ffffffffc0200716:	02e7f733          	remu	a4,a5,a4
ffffffffc020071a:	00006697          	auipc	a3,0x6
ffffffffc020071e:	d0f6bb23          	sd	a5,-746(a3) # ffffffffc0206430 <ticks>
ffffffffc0200722:	c315                	beqz	a4,ffffffffc0200746 <interrupt_handler+0x9a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200724:	60a2                	ld	ra,8(sp)
ffffffffc0200726:	0141                	addi	sp,sp,16
ffffffffc0200728:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc020072a:	00001517          	auipc	a0,0x1
ffffffffc020072e:	4d650513          	addi	a0,a0,1238 # ffffffffc0201c00 <commands+0x278>
ffffffffc0200732:	985ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200736:	00001517          	auipc	a0,0x1
ffffffffc020073a:	44250513          	addi	a0,a0,1090 # ffffffffc0201b78 <commands+0x1f0>
ffffffffc020073e:	979ff06f          	j	ffffffffc02000b6 <cprintf>
            print_trapframe(tf);
ffffffffc0200742:	f09ff06f          	j	ffffffffc020064a <print_trapframe>
}
ffffffffc0200746:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200748:	06400593          	li	a1,100
ffffffffc020074c:	00001517          	auipc	a0,0x1
ffffffffc0200750:	4a450513          	addi	a0,a0,1188 # ffffffffc0201bf0 <commands+0x268>
}
ffffffffc0200754:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200756:	961ff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc020075a <trap>:
            break;
    }
}

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc020075a:	11853783          	ld	a5,280(a0)
ffffffffc020075e:	0007c863          	bltz	a5,ffffffffc020076e <trap+0x14>
    switch (tf->cause) {
ffffffffc0200762:	472d                	li	a4,11
ffffffffc0200764:	00f76363          	bltu	a4,a5,ffffffffc020076a <trap+0x10>
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
}
ffffffffc0200768:	8082                	ret
            print_trapframe(tf);
ffffffffc020076a:	ee1ff06f          	j	ffffffffc020064a <print_trapframe>
        interrupt_handler(tf);
ffffffffc020076e:	f3fff06f          	j	ffffffffc02006ac <interrupt_handler>
	...

ffffffffc0200774 <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc0200774:	14011073          	csrw	sscratch,sp
ffffffffc0200778:	712d                	addi	sp,sp,-288
ffffffffc020077a:	e002                	sd	zero,0(sp)
ffffffffc020077c:	e406                	sd	ra,8(sp)
ffffffffc020077e:	ec0e                	sd	gp,24(sp)
ffffffffc0200780:	f012                	sd	tp,32(sp)
ffffffffc0200782:	f416                	sd	t0,40(sp)
ffffffffc0200784:	f81a                	sd	t1,48(sp)
ffffffffc0200786:	fc1e                	sd	t2,56(sp)
ffffffffc0200788:	e0a2                	sd	s0,64(sp)
ffffffffc020078a:	e4a6                	sd	s1,72(sp)
ffffffffc020078c:	e8aa                	sd	a0,80(sp)
ffffffffc020078e:	ecae                	sd	a1,88(sp)
ffffffffc0200790:	f0b2                	sd	a2,96(sp)
ffffffffc0200792:	f4b6                	sd	a3,104(sp)
ffffffffc0200794:	f8ba                	sd	a4,112(sp)
ffffffffc0200796:	fcbe                	sd	a5,120(sp)
ffffffffc0200798:	e142                	sd	a6,128(sp)
ffffffffc020079a:	e546                	sd	a7,136(sp)
ffffffffc020079c:	e94a                	sd	s2,144(sp)
ffffffffc020079e:	ed4e                	sd	s3,152(sp)
ffffffffc02007a0:	f152                	sd	s4,160(sp)
ffffffffc02007a2:	f556                	sd	s5,168(sp)
ffffffffc02007a4:	f95a                	sd	s6,176(sp)
ffffffffc02007a6:	fd5e                	sd	s7,184(sp)
ffffffffc02007a8:	e1e2                	sd	s8,192(sp)
ffffffffc02007aa:	e5e6                	sd	s9,200(sp)
ffffffffc02007ac:	e9ea                	sd	s10,208(sp)
ffffffffc02007ae:	edee                	sd	s11,216(sp)
ffffffffc02007b0:	f1f2                	sd	t3,224(sp)
ffffffffc02007b2:	f5f6                	sd	t4,232(sp)
ffffffffc02007b4:	f9fa                	sd	t5,240(sp)
ffffffffc02007b6:	fdfe                	sd	t6,248(sp)
ffffffffc02007b8:	14001473          	csrrw	s0,sscratch,zero
ffffffffc02007bc:	100024f3          	csrr	s1,sstatus
ffffffffc02007c0:	14102973          	csrr	s2,sepc
ffffffffc02007c4:	143029f3          	csrr	s3,stval
ffffffffc02007c8:	14202a73          	csrr	s4,scause
ffffffffc02007cc:	e822                	sd	s0,16(sp)
ffffffffc02007ce:	e226                	sd	s1,256(sp)
ffffffffc02007d0:	e64a                	sd	s2,264(sp)
ffffffffc02007d2:	ea4e                	sd	s3,272(sp)
ffffffffc02007d4:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc02007d6:	850a                	mv	a0,sp
    jal trap
ffffffffc02007d8:	f83ff0ef          	jal	ra,ffffffffc020075a <trap>

ffffffffc02007dc <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc02007dc:	6492                	ld	s1,256(sp)
ffffffffc02007de:	6932                	ld	s2,264(sp)
ffffffffc02007e0:	10049073          	csrw	sstatus,s1
ffffffffc02007e4:	14191073          	csrw	sepc,s2
ffffffffc02007e8:	60a2                	ld	ra,8(sp)
ffffffffc02007ea:	61e2                	ld	gp,24(sp)
ffffffffc02007ec:	7202                	ld	tp,32(sp)
ffffffffc02007ee:	72a2                	ld	t0,40(sp)
ffffffffc02007f0:	7342                	ld	t1,48(sp)
ffffffffc02007f2:	73e2                	ld	t2,56(sp)
ffffffffc02007f4:	6406                	ld	s0,64(sp)
ffffffffc02007f6:	64a6                	ld	s1,72(sp)
ffffffffc02007f8:	6546                	ld	a0,80(sp)
ffffffffc02007fa:	65e6                	ld	a1,88(sp)
ffffffffc02007fc:	7606                	ld	a2,96(sp)
ffffffffc02007fe:	76a6                	ld	a3,104(sp)
ffffffffc0200800:	7746                	ld	a4,112(sp)
ffffffffc0200802:	77e6                	ld	a5,120(sp)
ffffffffc0200804:	680a                	ld	a6,128(sp)
ffffffffc0200806:	68aa                	ld	a7,136(sp)
ffffffffc0200808:	694a                	ld	s2,144(sp)
ffffffffc020080a:	69ea                	ld	s3,152(sp)
ffffffffc020080c:	7a0a                	ld	s4,160(sp)
ffffffffc020080e:	7aaa                	ld	s5,168(sp)
ffffffffc0200810:	7b4a                	ld	s6,176(sp)
ffffffffc0200812:	7bea                	ld	s7,184(sp)
ffffffffc0200814:	6c0e                	ld	s8,192(sp)
ffffffffc0200816:	6cae                	ld	s9,200(sp)
ffffffffc0200818:	6d4e                	ld	s10,208(sp)
ffffffffc020081a:	6dee                	ld	s11,216(sp)
ffffffffc020081c:	7e0e                	ld	t3,224(sp)
ffffffffc020081e:	7eae                	ld	t4,232(sp)
ffffffffc0200820:	7f4e                	ld	t5,240(sp)
ffffffffc0200822:	7fee                	ld	t6,248(sp)
ffffffffc0200824:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200826:	10200073          	sret

ffffffffc020082a <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020082a:	100027f3          	csrr	a5,sstatus
ffffffffc020082e:	8b89                	andi	a5,a5,2
ffffffffc0200830:	eb89                	bnez	a5,ffffffffc0200842 <alloc_pages+0x18>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0200832:	00006797          	auipc	a5,0x6
ffffffffc0200836:	c0e78793          	addi	a5,a5,-1010 # ffffffffc0206440 <pmm_manager>
ffffffffc020083a:	639c                	ld	a5,0(a5)
ffffffffc020083c:	0187b303          	ld	t1,24(a5)
ffffffffc0200840:	8302                	jr	t1
struct Page *alloc_pages(size_t n) {
ffffffffc0200842:	1141                	addi	sp,sp,-16
ffffffffc0200844:	e406                	sd	ra,8(sp)
ffffffffc0200846:	e022                	sd	s0,0(sp)
ffffffffc0200848:	842a                	mv	s0,a0
        intr_disable();
ffffffffc020084a:	c1bff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc020084e:	00006797          	auipc	a5,0x6
ffffffffc0200852:	bf278793          	addi	a5,a5,-1038 # ffffffffc0206440 <pmm_manager>
ffffffffc0200856:	639c                	ld	a5,0(a5)
ffffffffc0200858:	8522                	mv	a0,s0
ffffffffc020085a:	6f9c                	ld	a5,24(a5)
ffffffffc020085c:	9782                	jalr	a5
ffffffffc020085e:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0200860:	bffff0ef          	jal	ra,ffffffffc020045e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0200864:	8522                	mv	a0,s0
ffffffffc0200866:	60a2                	ld	ra,8(sp)
ffffffffc0200868:	6402                	ld	s0,0(sp)
ffffffffc020086a:	0141                	addi	sp,sp,16
ffffffffc020086c:	8082                	ret

ffffffffc020086e <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020086e:	100027f3          	csrr	a5,sstatus
ffffffffc0200872:	8b89                	andi	a5,a5,2
ffffffffc0200874:	eb89                	bnez	a5,ffffffffc0200886 <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0200876:	00006797          	auipc	a5,0x6
ffffffffc020087a:	bca78793          	addi	a5,a5,-1078 # ffffffffc0206440 <pmm_manager>
ffffffffc020087e:	639c                	ld	a5,0(a5)
ffffffffc0200880:	0207b303          	ld	t1,32(a5)
ffffffffc0200884:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0200886:	1101                	addi	sp,sp,-32
ffffffffc0200888:	ec06                	sd	ra,24(sp)
ffffffffc020088a:	e822                	sd	s0,16(sp)
ffffffffc020088c:	e426                	sd	s1,8(sp)
ffffffffc020088e:	842a                	mv	s0,a0
ffffffffc0200890:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200892:	bd3ff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0200896:	00006797          	auipc	a5,0x6
ffffffffc020089a:	baa78793          	addi	a5,a5,-1110 # ffffffffc0206440 <pmm_manager>
ffffffffc020089e:	639c                	ld	a5,0(a5)
ffffffffc02008a0:	85a6                	mv	a1,s1
ffffffffc02008a2:	8522                	mv	a0,s0
ffffffffc02008a4:	739c                	ld	a5,32(a5)
ffffffffc02008a6:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc02008a8:	6442                	ld	s0,16(sp)
ffffffffc02008aa:	60e2                	ld	ra,24(sp)
ffffffffc02008ac:	64a2                	ld	s1,8(sp)
ffffffffc02008ae:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02008b0:	bafff06f          	j	ffffffffc020045e <intr_enable>

ffffffffc02008b4 <pmm_init>:
    pmm_manager = &buddy_pmm_manager;
ffffffffc02008b4:	00002797          	auipc	a5,0x2
ffffffffc02008b8:	99c78793          	addi	a5,a5,-1636 # ffffffffc0202250 <buddy_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02008bc:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc02008be:	1101                	addi	sp,sp,-32
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02008c0:	00001517          	auipc	a0,0x1
ffffffffc02008c4:	6d850513          	addi	a0,a0,1752 # ffffffffc0201f98 <commands+0x610>
void pmm_init(void) {
ffffffffc02008c8:	ec06                	sd	ra,24(sp)
    pmm_manager = &buddy_pmm_manager;
ffffffffc02008ca:	00006717          	auipc	a4,0x6
ffffffffc02008ce:	b6f73b23          	sd	a5,-1162(a4) # ffffffffc0206440 <pmm_manager>
void pmm_init(void) {
ffffffffc02008d2:	e822                	sd	s0,16(sp)
ffffffffc02008d4:	e426                	sd	s1,8(sp)
    pmm_manager = &buddy_pmm_manager;
ffffffffc02008d6:	00006417          	auipc	s0,0x6
ffffffffc02008da:	b6a40413          	addi	s0,s0,-1174 # ffffffffc0206440 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02008de:	fd8ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pmm_manager->init();
ffffffffc02008e2:	601c                	ld	a5,0(s0)
ffffffffc02008e4:	679c                	ld	a5,8(a5)
ffffffffc02008e6:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02008e8:	57f5                	li	a5,-3
ffffffffc02008ea:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc02008ec:	00001517          	auipc	a0,0x1
ffffffffc02008f0:	6c450513          	addi	a0,a0,1732 # ffffffffc0201fb0 <commands+0x628>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02008f4:	00006717          	auipc	a4,0x6
ffffffffc02008f8:	b4f73a23          	sd	a5,-1196(a4) # ffffffffc0206448 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc02008fc:	fbaff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0200900:	46c5                	li	a3,17
ffffffffc0200902:	06ee                	slli	a3,a3,0x1b
ffffffffc0200904:	40100613          	li	a2,1025
ffffffffc0200908:	16fd                	addi	a3,a3,-1
ffffffffc020090a:	0656                	slli	a2,a2,0x15
ffffffffc020090c:	07e005b7          	lui	a1,0x7e00
ffffffffc0200910:	00001517          	auipc	a0,0x1
ffffffffc0200914:	6b850513          	addi	a0,a0,1720 # ffffffffc0201fc8 <commands+0x640>
ffffffffc0200918:	f9eff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020091c:	777d                	lui	a4,0xfffff
ffffffffc020091e:	00278797          	auipc	a5,0x278
ffffffffc0200922:	b5978793          	addi	a5,a5,-1191 # ffffffffc0478477 <end+0xfff>
ffffffffc0200926:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0200928:	00088737          	lui	a4,0x88
ffffffffc020092c:	00006697          	auipc	a3,0x6
ffffffffc0200930:	aee6b623          	sd	a4,-1300(a3) # ffffffffc0206418 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200934:	4601                	li	a2,0
ffffffffc0200936:	00006717          	auipc	a4,0x6
ffffffffc020093a:	b0f73d23          	sd	a5,-1254(a4) # ffffffffc0206450 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020093e:	4681                	li	a3,0
ffffffffc0200940:	00006897          	auipc	a7,0x6
ffffffffc0200944:	ad888893          	addi	a7,a7,-1320 # ffffffffc0206418 <npage>
ffffffffc0200948:	00006597          	auipc	a1,0x6
ffffffffc020094c:	b0858593          	addi	a1,a1,-1272 # ffffffffc0206450 <pages>
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200950:	4805                	li	a6,1
ffffffffc0200952:	fff80537          	lui	a0,0xfff80
ffffffffc0200956:	a011                	j	ffffffffc020095a <pmm_init+0xa6>
ffffffffc0200958:	619c                	ld	a5,0(a1)
        SetPageReserved(pages + i);
ffffffffc020095a:	97b2                	add	a5,a5,a2
ffffffffc020095c:	07a1                	addi	a5,a5,8
ffffffffc020095e:	4107b02f          	amoor.d	zero,a6,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200962:	0008b703          	ld	a4,0(a7)
ffffffffc0200966:	0685                	addi	a3,a3,1
ffffffffc0200968:	02860613          	addi	a2,a2,40
ffffffffc020096c:	00a707b3          	add	a5,a4,a0
ffffffffc0200970:	fef6e4e3          	bltu	a3,a5,ffffffffc0200958 <pmm_init+0xa4>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200974:	6190                	ld	a2,0(a1)
ffffffffc0200976:	00271793          	slli	a5,a4,0x2
ffffffffc020097a:	97ba                	add	a5,a5,a4
ffffffffc020097c:	fec006b7          	lui	a3,0xfec00
ffffffffc0200980:	078e                	slli	a5,a5,0x3
ffffffffc0200982:	96b2                	add	a3,a3,a2
ffffffffc0200984:	96be                	add	a3,a3,a5
ffffffffc0200986:	c02007b7          	lui	a5,0xc0200
ffffffffc020098a:	08f6e863          	bltu	a3,a5,ffffffffc0200a1a <pmm_init+0x166>
ffffffffc020098e:	00006497          	auipc	s1,0x6
ffffffffc0200992:	aba48493          	addi	s1,s1,-1350 # ffffffffc0206448 <va_pa_offset>
ffffffffc0200996:	609c                	ld	a5,0(s1)
    if (freemem < mem_end) {
ffffffffc0200998:	45c5                	li	a1,17
ffffffffc020099a:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020099c:	8e9d                	sub	a3,a3,a5
    if (freemem < mem_end) {
ffffffffc020099e:	04b6e963          	bltu	a3,a1,ffffffffc02009f0 <pmm_init+0x13c>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc02009a2:	601c                	ld	a5,0(s0)
ffffffffc02009a4:	7b9c                	ld	a5,48(a5)
ffffffffc02009a6:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02009a8:	00001517          	auipc	a0,0x1
ffffffffc02009ac:	6b850513          	addi	a0,a0,1720 # ffffffffc0202060 <commands+0x6d8>
ffffffffc02009b0:	f06ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc02009b4:	00004697          	auipc	a3,0x4
ffffffffc02009b8:	64c68693          	addi	a3,a3,1612 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc02009bc:	00006797          	auipc	a5,0x6
ffffffffc02009c0:	a6d7b223          	sd	a3,-1436(a5) # ffffffffc0206420 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc02009c4:	c02007b7          	lui	a5,0xc0200
ffffffffc02009c8:	06f6e563          	bltu	a3,a5,ffffffffc0200a32 <pmm_init+0x17e>
ffffffffc02009cc:	609c                	ld	a5,0(s1)
}
ffffffffc02009ce:	6442                	ld	s0,16(sp)
ffffffffc02009d0:	60e2                	ld	ra,24(sp)
ffffffffc02009d2:	64a2                	ld	s1,8(sp)
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02009d4:	85b6                	mv	a1,a3
    satp_physical = PADDR(satp_virtual);
ffffffffc02009d6:	8e9d                	sub	a3,a3,a5
ffffffffc02009d8:	00006797          	auipc	a5,0x6
ffffffffc02009dc:	a6d7b023          	sd	a3,-1440(a5) # ffffffffc0206438 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02009e0:	00001517          	auipc	a0,0x1
ffffffffc02009e4:	6a050513          	addi	a0,a0,1696 # ffffffffc0202080 <commands+0x6f8>
ffffffffc02009e8:	8636                	mv	a2,a3
}
ffffffffc02009ea:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02009ec:	ecaff06f          	j	ffffffffc02000b6 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02009f0:	6785                	lui	a5,0x1
ffffffffc02009f2:	17fd                	addi	a5,a5,-1
ffffffffc02009f4:	96be                	add	a3,a3,a5
ffffffffc02009f6:	77fd                	lui	a5,0xfffff
ffffffffc02009f8:	8efd                	and	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc02009fa:	00c6d793          	srli	a5,a3,0xc
ffffffffc02009fe:	04e7f663          	bleu	a4,a5,ffffffffc0200a4a <pmm_init+0x196>
    pmm_manager->init_memmap(base, n);
ffffffffc0200a02:	6018                	ld	a4,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0200a04:	97aa                	add	a5,a5,a0
ffffffffc0200a06:	00279513          	slli	a0,a5,0x2
ffffffffc0200a0a:	953e                	add	a0,a0,a5
ffffffffc0200a0c:	6b1c                	ld	a5,16(a4)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0200a0e:	8d95                	sub	a1,a1,a3
ffffffffc0200a10:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0200a12:	81b1                	srli	a1,a1,0xc
ffffffffc0200a14:	9532                	add	a0,a0,a2
ffffffffc0200a16:	9782                	jalr	a5
ffffffffc0200a18:	b769                	j	ffffffffc02009a2 <pmm_init+0xee>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200a1a:	00001617          	auipc	a2,0x1
ffffffffc0200a1e:	5de60613          	addi	a2,a2,1502 # ffffffffc0201ff8 <commands+0x670>
ffffffffc0200a22:	07100593          	li	a1,113
ffffffffc0200a26:	00001517          	auipc	a0,0x1
ffffffffc0200a2a:	5fa50513          	addi	a0,a0,1530 # ffffffffc0202020 <commands+0x698>
ffffffffc0200a2e:	f10ff0ef          	jal	ra,ffffffffc020013e <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200a32:	00001617          	auipc	a2,0x1
ffffffffc0200a36:	5c660613          	addi	a2,a2,1478 # ffffffffc0201ff8 <commands+0x670>
ffffffffc0200a3a:	08c00593          	li	a1,140
ffffffffc0200a3e:	00001517          	auipc	a0,0x1
ffffffffc0200a42:	5e250513          	addi	a0,a0,1506 # ffffffffc0202020 <commands+0x698>
ffffffffc0200a46:	ef8ff0ef          	jal	ra,ffffffffc020013e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0200a4a:	00001617          	auipc	a2,0x1
ffffffffc0200a4e:	5e660613          	addi	a2,a2,1510 # ffffffffc0202030 <commands+0x6a8>
ffffffffc0200a52:	06b00593          	li	a1,107
ffffffffc0200a56:	00001517          	auipc	a0,0x1
ffffffffc0200a5a:	5fa50513          	addi	a0,a0,1530 # ffffffffc0202050 <commands+0x6c8>
ffffffffc0200a5e:	ee0ff0ef          	jal	ra,ffffffffc020013e <__panic>

ffffffffc0200a62 <buddy_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200a62:	00006797          	auipc	a5,0x6
ffffffffc0200a66:	9f678793          	addi	a5,a5,-1546 # ffffffffc0206458 <free_area>
ffffffffc0200a6a:	e79c                	sd	a5,8(a5)
ffffffffc0200a6c:	e39c                	sd	a5,0(a5)
int nr_block;//已分配的块数

static void buddy_init()
{
    list_init(&free_list);
    nr_free=0;
ffffffffc0200a6e:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200a72:	8082                	ret

ffffffffc0200a74 <buddy_nr_free_pages>:
}

static size_t
buddy_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200a74:	00006517          	auipc	a0,0x6
ffffffffc0200a78:	9f456503          	lwu	a0,-1548(a0) # ffffffffc0206468 <free_area+0x10>
ffffffffc0200a7c:	8082                	ret

ffffffffc0200a7e <buddy_free_pages>:
  for(i=0;i<nr_block;i++)//找到块
ffffffffc0200a7e:	00006897          	auipc	a7,0x6
ffffffffc0200a82:	9f288893          	addi	a7,a7,-1550 # ffffffffc0206470 <nr_block>
ffffffffc0200a86:	0008a803          	lw	a6,0(a7)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200a8a:	00006e17          	auipc	t3,0x6
ffffffffc0200a8e:	9cee0e13          	addi	t3,t3,-1586 # ffffffffc0206458 <free_area>
ffffffffc0200a92:	008e3683          	ld	a3,8(t3)
ffffffffc0200a96:	19005863          	blez	a6,ffffffffc0200c26 <buddy_free_pages+0x1a8>
    if(rec[i].base==base)
ffffffffc0200a9a:	000a2617          	auipc	a2,0xa2
ffffffffc0200a9e:	dde60613          	addi	a2,a2,-546 # ffffffffc02a2878 <rec>
ffffffffc0200aa2:	621c                	ld	a5,0(a2)
ffffffffc0200aa4:	18f50763          	beq	a0,a5,ffffffffc0200c32 <buddy_free_pages+0x1b4>
ffffffffc0200aa8:	000a2717          	auipc	a4,0xa2
ffffffffc0200aac:	de870713          	addi	a4,a4,-536 # ffffffffc02a2890 <rec+0x18>
  for(i=0;i<nr_block;i++)//找到块
ffffffffc0200ab0:	4781                	li	a5,0
ffffffffc0200ab2:	a031                	j	ffffffffc0200abe <buddy_free_pages+0x40>
    if(rec[i].base==base)
ffffffffc0200ab4:	0761                	addi	a4,a4,24
ffffffffc0200ab6:	fe873303          	ld	t1,-24(a4)
ffffffffc0200aba:	16a30463          	beq	t1,a0,ffffffffc0200c22 <buddy_free_pages+0x1a4>
  for(i=0;i<nr_block;i++)//找到块
ffffffffc0200abe:	2785                	addiw	a5,a5,1
ffffffffc0200ac0:	ff079ae3          	bne	a5,a6,ffffffffc0200ab4 <buddy_free_pages+0x36>
  int offset=rec[i].offset;
ffffffffc0200ac4:	00181513          	slli	a0,a6,0x1
ffffffffc0200ac8:	010507b3          	add	a5,a0,a6
ffffffffc0200acc:	078e                	slli	a5,a5,0x3
ffffffffc0200ace:	97b2                	add	a5,a5,a2
ffffffffc0200ad0:	479c                	lw	a5,8(a5)
  while(i<offset)
ffffffffc0200ad2:	00f05763          	blez	a5,ffffffffc0200ae0 <buddy_free_pages+0x62>
  i=0;
ffffffffc0200ad6:	4701                	li	a4,0
    i++;
ffffffffc0200ad8:	2705                	addiw	a4,a4,1
ffffffffc0200ada:	6694                	ld	a3,8(a3)
  while(i<offset)
ffffffffc0200adc:	fee79ee3          	bne	a5,a4,ffffffffc0200ad8 <buddy_free_pages+0x5a>
  if(!IS_POWER_OF_2(n))
ffffffffc0200ae0:	fff58713          	addi	a4,a1,-1
ffffffffc0200ae4:	8f6d                	and	a4,a4,a1
     allocpages=n;
ffffffffc0200ae6:	2581                	sext.w	a1,a1
  if(!IS_POWER_OF_2(n))
ffffffffc0200ae8:	c70d                	beqz	a4,ffffffffc0200b12 <buddy_free_pages+0x94>
  size |= size >> 1;
ffffffffc0200aea:	0015d71b          	srliw	a4,a1,0x1
ffffffffc0200aee:	8dd9                	or	a1,a1,a4
ffffffffc0200af0:	2581                	sext.w	a1,a1
  size |= size >> 2;
ffffffffc0200af2:	0025d71b          	srliw	a4,a1,0x2
ffffffffc0200af6:	8dd9                	or	a1,a1,a4
ffffffffc0200af8:	2581                	sext.w	a1,a1
  size |= size >> 4;
ffffffffc0200afa:	0045d71b          	srliw	a4,a1,0x4
ffffffffc0200afe:	8dd9                	or	a1,a1,a4
ffffffffc0200b00:	2581                	sext.w	a1,a1
  size |= size >> 8;
ffffffffc0200b02:	0085d71b          	srliw	a4,a1,0x8
ffffffffc0200b06:	8dd9                	or	a1,a1,a4
ffffffffc0200b08:	2581                	sext.w	a1,a1
  size |= size >> 16;
ffffffffc0200b0a:	0105d71b          	srliw	a4,a1,0x10
ffffffffc0200b0e:	8dd9                	or	a1,a1,a4
   allocpages=fixsize(n);
ffffffffc0200b10:	2585                	addiw	a1,a1,1
  assert(self && offset >= 0 && offset < self->size);//是否合法
ffffffffc0200b12:	1207c263          	bltz	a5,ffffffffc0200c36 <buddy_free_pages+0x1b8>
ffffffffc0200b16:	00006317          	auipc	t1,0x6
ffffffffc0200b1a:	96230313          	addi	t1,t1,-1694 # ffffffffc0206478 <root>
ffffffffc0200b1e:	00032703          	lw	a4,0(t1)
ffffffffc0200b22:	00078e9b          	sext.w	t4,a5
ffffffffc0200b26:	10eef863          	bleu	a4,t4,ffffffffc0200c36 <buddy_free_pages+0x1b8>
  index = offset + self->size - 1;
ffffffffc0200b2a:	fff7079b          	addiw	a5,a4,-1
ffffffffc0200b2e:	01d787bb          	addw	a5,a5,t4
  self[index].longest = allocpages;
ffffffffc0200b32:	02079713          	slli	a4,a5,0x20
  nr_free+=allocpages;//更新空闲页的数量
ffffffffc0200b36:	010e2e83          	lw	t4,16(t3)
  self[index].longest = allocpages;
ffffffffc0200b3a:	9301                	srli	a4,a4,0x20
  nr_free+=allocpages;//更新空闲页的数量
ffffffffc0200b3c:	00058e1b          	sext.w	t3,a1
  self[index].longest = allocpages;
ffffffffc0200b40:	070e                	slli	a4,a4,0x3
  nr_free+=allocpages;//更新空闲页的数量
ffffffffc0200b42:	01ce8ebb          	addw	t4,t4,t3
  self[index].longest = allocpages;
ffffffffc0200b46:	971a                	add	a4,a4,t1
ffffffffc0200b48:	01c72223          	sw	t3,4(a4)
  nr_free+=allocpages;//更新空闲页的数量
ffffffffc0200b4c:	00006f17          	auipc	t5,0x6
ffffffffc0200b50:	91df2e23          	sw	t4,-1764(t5) # ffffffffc0206468 <free_area+0x10>
  for(i=0;i<allocpages;i++)//回收已分配的页
ffffffffc0200b54:	4701                	li	a4,0
     p->property=1;
ffffffffc0200b56:	4e85                	li	t4,1
ffffffffc0200b58:	4e09                	li	t3,2
  for(i=0;i<allocpages;i++)//回收已分配的页
ffffffffc0200b5a:	00b05e63          	blez	a1,ffffffffc0200b76 <buddy_free_pages+0xf8>
     p->flags=0;
ffffffffc0200b5e:	fe06b823          	sd	zero,-16(a3)
     p->property=1;
ffffffffc0200b62:	ffd6ac23          	sw	t4,-8(a3)
ffffffffc0200b66:	ff068f13          	addi	t5,a3,-16
ffffffffc0200b6a:	41cf302f          	amoor.d	zero,t3,(t5)
  for(i=0;i<allocpages;i++)//回收已分配的页
ffffffffc0200b6e:	2705                	addiw	a4,a4,1
ffffffffc0200b70:	6694                	ld	a3,8(a3)
ffffffffc0200b72:	fee596e3          	bne	a1,a4,ffffffffc0200b5e <buddy_free_pages+0xe0>
  node_size = 1;
ffffffffc0200b76:	4e05                	li	t3,1
  while (index) {//向上合并，修改先祖节点的记录值
ffffffffc0200b78:	c7b9                	beqz	a5,ffffffffc0200bc6 <buddy_free_pages+0x148>
    index = PARENT(index);
ffffffffc0200b7a:	2785                	addiw	a5,a5,1
ffffffffc0200b7c:	0017d59b          	srliw	a1,a5,0x1
ffffffffc0200b80:	35fd                	addiw	a1,a1,-1
    left_longest = self[LEFT_LEAF(index)].longest;
ffffffffc0200b82:	0015969b          	slliw	a3,a1,0x1
    right_longest = self[RIGHT_LEAF(index)].longest;
ffffffffc0200b86:	ffe7f713          	andi	a4,a5,-2
    left_longest = self[LEFT_LEAF(index)].longest;
ffffffffc0200b8a:	2685                	addiw	a3,a3,1
ffffffffc0200b8c:	1682                	slli	a3,a3,0x20
    right_longest = self[RIGHT_LEAF(index)].longest;
ffffffffc0200b8e:	1702                	slli	a4,a4,0x20
    left_longest = self[LEFT_LEAF(index)].longest;
ffffffffc0200b90:	9281                	srli	a3,a3,0x20
    right_longest = self[RIGHT_LEAF(index)].longest;
ffffffffc0200b92:	9301                	srli	a4,a4,0x20
    left_longest = self[LEFT_LEAF(index)].longest;
ffffffffc0200b94:	068e                	slli	a3,a3,0x3
    right_longest = self[RIGHT_LEAF(index)].longest;
ffffffffc0200b96:	070e                	slli	a4,a4,0x3
ffffffffc0200b98:	971a                	add	a4,a4,t1
    left_longest = self[LEFT_LEAF(index)].longest;
ffffffffc0200b9a:	969a                	add	a3,a3,t1
    right_longest = self[RIGHT_LEAF(index)].longest;
ffffffffc0200b9c:	00472e83          	lw	t4,4(a4)
    left_longest = self[LEFT_LEAF(index)].longest;
ffffffffc0200ba0:	42d4                	lw	a3,4(a3)
ffffffffc0200ba2:	02059713          	slli	a4,a1,0x20
ffffffffc0200ba6:	8375                	srli	a4,a4,0x1d
    node_size *= 2;
ffffffffc0200ba8:	001e1e1b          	slliw	t3,t3,0x1
    if (left_longest + right_longest == node_size) 
ffffffffc0200bac:	01d68fbb          	addw	t6,a3,t4
    index = PARENT(index);
ffffffffc0200bb0:	0005879b          	sext.w	a5,a1
    if (left_longest + right_longest == node_size) 
ffffffffc0200bb4:	971a                	add	a4,a4,t1
ffffffffc0200bb6:	07cf8263          	beq	t6,t3,ffffffffc0200c1a <buddy_free_pages+0x19c>
      self[index].longest = MAX(left_longest, right_longest);
ffffffffc0200bba:	85b6                	mv	a1,a3
ffffffffc0200bbc:	01d6f363          	bleu	t4,a3,ffffffffc0200bc2 <buddy_free_pages+0x144>
ffffffffc0200bc0:	85f6                	mv	a1,t4
ffffffffc0200bc2:	c34c                	sw	a1,4(a4)
  while (index) {//向上合并，修改先祖节点的记录值
ffffffffc0200bc4:	fbdd                	bnez	a5,ffffffffc0200b7a <buddy_free_pages+0xfc>
  for(i=pos;i<nr_block-1;i++)//清除此次的分配记录
ffffffffc0200bc6:	0008a783          	lw	a5,0(a7)
ffffffffc0200bca:	fff7871b          	addiw	a4,a5,-1
ffffffffc0200bce:	88ba                	mv	a7,a4
ffffffffc0200bd0:	04e85063          	ble	a4,a6,ffffffffc0200c10 <buddy_free_pages+0x192>
ffffffffc0200bd4:	ffe7859b          	addiw	a1,a5,-2
ffffffffc0200bd8:	410585bb          	subw	a1,a1,a6
ffffffffc0200bdc:	1582                	slli	a1,a1,0x20
ffffffffc0200bde:	9181                	srli	a1,a1,0x20
ffffffffc0200be0:	01058733          	add	a4,a1,a6
ffffffffc0200be4:	00171593          	slli	a1,a4,0x1
ffffffffc0200be8:	95ba                	add	a1,a1,a4
ffffffffc0200bea:	010507b3          	add	a5,a0,a6
ffffffffc0200bee:	078e                	slli	a5,a5,0x3
ffffffffc0200bf0:	058e                	slli	a1,a1,0x3
ffffffffc0200bf2:	000a2717          	auipc	a4,0xa2
ffffffffc0200bf6:	c9e70713          	addi	a4,a4,-866 # ffffffffc02a2890 <rec+0x18>
ffffffffc0200bfa:	97b2                	add	a5,a5,a2
ffffffffc0200bfc:	95ba                	add	a1,a1,a4
    rec[i]=rec[i+1];
ffffffffc0200bfe:	6f90                	ld	a2,24(a5)
ffffffffc0200c00:	7394                	ld	a3,32(a5)
ffffffffc0200c02:	7798                	ld	a4,40(a5)
ffffffffc0200c04:	e390                	sd	a2,0(a5)
ffffffffc0200c06:	e794                	sd	a3,8(a5)
ffffffffc0200c08:	eb98                	sd	a4,16(a5)
ffffffffc0200c0a:	07e1                	addi	a5,a5,24
  for(i=pos;i<nr_block-1;i++)//清除此次的分配记录
ffffffffc0200c0c:	fef599e3          	bne	a1,a5,ffffffffc0200bfe <buddy_free_pages+0x180>
  nr_block--;//更新分配块数的值
ffffffffc0200c10:	00006797          	auipc	a5,0x6
ffffffffc0200c14:	8717a023          	sw	a7,-1952(a5) # ffffffffc0206470 <nr_block>
ffffffffc0200c18:	8082                	ret
      self[index].longest = node_size;
ffffffffc0200c1a:	01c72223          	sw	t3,4(a4)
  while (index) {//向上合并，修改先祖节点的记录值
ffffffffc0200c1e:	ffb1                	bnez	a5,ffffffffc0200b7a <buddy_free_pages+0xfc>
ffffffffc0200c20:	b75d                	j	ffffffffc0200bc6 <buddy_free_pages+0x148>
  for(i=0;i<nr_block;i++)//找到块
ffffffffc0200c22:	883e                	mv	a6,a5
ffffffffc0200c24:	b545                	j	ffffffffc0200ac4 <buddy_free_pages+0x46>
ffffffffc0200c26:	4801                	li	a6,0
ffffffffc0200c28:	000a2617          	auipc	a2,0xa2
ffffffffc0200c2c:	c5060613          	addi	a2,a2,-944 # ffffffffc02a2878 <rec>
ffffffffc0200c30:	bd51                	j	ffffffffc0200ac4 <buddy_free_pages+0x46>
ffffffffc0200c32:	4801                	li	a6,0
ffffffffc0200c34:	bd41                	j	ffffffffc0200ac4 <buddy_free_pages+0x46>
void buddy_free_pages(struct Page* base, size_t n) {
ffffffffc0200c36:	1141                	addi	sp,sp,-16
  assert(self && offset >= 0 && offset < self->size);//是否合法
ffffffffc0200c38:	00001697          	auipc	a3,0x1
ffffffffc0200c3c:	5a068693          	addi	a3,a3,1440 # ffffffffc02021d8 <commands+0x850>
ffffffffc0200c40:	00001617          	auipc	a2,0x1
ffffffffc0200c44:	5c860613          	addi	a2,a2,1480 # ffffffffc0202208 <commands+0x880>
ffffffffc0200c48:	0ce00593          	li	a1,206
ffffffffc0200c4c:	00001517          	auipc	a0,0x1
ffffffffc0200c50:	5d450513          	addi	a0,a0,1492 # ffffffffc0202220 <commands+0x898>
void buddy_free_pages(struct Page* base, size_t n) {
ffffffffc0200c54:	e406                	sd	ra,8(sp)
  assert(self && offset >= 0 && offset < self->size);//是否合法
ffffffffc0200c56:	ce8ff0ef          	jal	ra,ffffffffc020013e <__panic>

ffffffffc0200c5a <buddy_check>:

//以下是一个测试函数
static void

buddy_check(void) {
ffffffffc0200c5a:	7179                	addi	sp,sp,-48
    struct Page *p0, *A, *B,*C,*D;
    p0 = A = B = C = D =NULL;

    assert((p0 = alloc_page()) != NULL);
ffffffffc0200c5c:	4505                	li	a0,1
buddy_check(void) {
ffffffffc0200c5e:	f406                	sd	ra,40(sp)
ffffffffc0200c60:	f022                	sd	s0,32(sp)
ffffffffc0200c62:	ec26                	sd	s1,24(sp)
ffffffffc0200c64:	e84a                	sd	s2,16(sp)
ffffffffc0200c66:	e44e                	sd	s3,8(sp)
ffffffffc0200c68:	e052                	sd	s4,0(sp)
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200c6a:	bc1ff0ef          	jal	ra,ffffffffc020082a <alloc_pages>
ffffffffc0200c6e:	28050863          	beqz	a0,ffffffffc0200efe <buddy_check+0x2a4>
ffffffffc0200c72:	842a                	mv	s0,a0
    assert((A = alloc_page()) != NULL);
ffffffffc0200c74:	4505                	li	a0,1
ffffffffc0200c76:	bb5ff0ef          	jal	ra,ffffffffc020082a <alloc_pages>
ffffffffc0200c7a:	84aa                	mv	s1,a0
ffffffffc0200c7c:	26050163          	beqz	a0,ffffffffc0200ede <buddy_check+0x284>
    assert((B = alloc_page()) != NULL);
ffffffffc0200c80:	4505                	li	a0,1
ffffffffc0200c82:	ba9ff0ef          	jal	ra,ffffffffc020082a <alloc_pages>
ffffffffc0200c86:	892a                	mv	s2,a0
ffffffffc0200c88:	22050b63          	beqz	a0,ffffffffc0200ebe <buddy_check+0x264>

    assert(p0 != A && p0 != B && A != B);
ffffffffc0200c8c:	18940963          	beq	s0,s1,ffffffffc0200e1e <buddy_check+0x1c4>
ffffffffc0200c90:	18a40763          	beq	s0,a0,ffffffffc0200e1e <buddy_check+0x1c4>
ffffffffc0200c94:	18a48563          	beq	s1,a0,ffffffffc0200e1e <buddy_check+0x1c4>
    assert(page_ref(p0) == 0 && page_ref(A) == 0 && page_ref(B) == 0);
ffffffffc0200c98:	401c                	lw	a5,0(s0)
ffffffffc0200c9a:	1a079263          	bnez	a5,ffffffffc0200e3e <buddy_check+0x1e4>
ffffffffc0200c9e:	409c                	lw	a5,0(s1)
ffffffffc0200ca0:	18079f63          	bnez	a5,ffffffffc0200e3e <buddy_check+0x1e4>
ffffffffc0200ca4:	411c                	lw	a5,0(a0)
ffffffffc0200ca6:	18079c63          	bnez	a5,ffffffffc0200e3e <buddy_check+0x1e4>
    free_page(p0);
ffffffffc0200caa:	8522                	mv	a0,s0
ffffffffc0200cac:	4585                	li	a1,1
ffffffffc0200cae:	bc1ff0ef          	jal	ra,ffffffffc020086e <free_pages>
    free_page(A);
ffffffffc0200cb2:	8526                	mv	a0,s1
ffffffffc0200cb4:	4585                	li	a1,1
ffffffffc0200cb6:	bb9ff0ef          	jal	ra,ffffffffc020086e <free_pages>
    free_page(B);
ffffffffc0200cba:	4585                	li	a1,1
ffffffffc0200cbc:	854a                	mv	a0,s2
ffffffffc0200cbe:	bb1ff0ef          	jal	ra,ffffffffc020086e <free_pages>
    
    A=alloc_pages(500);
ffffffffc0200cc2:	1f400513          	li	a0,500
ffffffffc0200cc6:	b65ff0ef          	jal	ra,ffffffffc020082a <alloc_pages>
ffffffffc0200cca:	842a                	mv	s0,a0
    B=alloc_pages(500);
ffffffffc0200ccc:	1f400513          	li	a0,500
ffffffffc0200cd0:	b5bff0ef          	jal	ra,ffffffffc020082a <alloc_pages>
ffffffffc0200cd4:	84aa                	mv	s1,a0
    cprintf("A %p\n",A);
ffffffffc0200cd6:	85a2                	mv	a1,s0
ffffffffc0200cd8:	00001517          	auipc	a0,0x1
ffffffffc0200cdc:	4a850513          	addi	a0,a0,1192 # ffffffffc0202180 <commands+0x7f8>
ffffffffc0200ce0:	bd6ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("B %p\n",B);
ffffffffc0200ce4:	85a6                	mv	a1,s1
ffffffffc0200ce6:	00001517          	auipc	a0,0x1
ffffffffc0200cea:	4a250513          	addi	a0,a0,1186 # ffffffffc0202188 <commands+0x800>
ffffffffc0200cee:	bc8ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    free_pages(A,250);
ffffffffc0200cf2:	0fa00593          	li	a1,250
ffffffffc0200cf6:	8522                	mv	a0,s0
ffffffffc0200cf8:	b77ff0ef          	jal	ra,ffffffffc020086e <free_pages>
    free_pages(B,500);
ffffffffc0200cfc:	1f400593          	li	a1,500
ffffffffc0200d00:	8526                	mv	a0,s1
ffffffffc0200d02:	b6dff0ef          	jal	ra,ffffffffc020086e <free_pages>
    free_pages(A+250,250);
ffffffffc0200d06:	6509                	lui	a0,0x2
ffffffffc0200d08:	71050513          	addi	a0,a0,1808 # 2710 <BASE_ADDRESS-0xffffffffc01fd8f0>
ffffffffc0200d0c:	0fa00593          	li	a1,250
ffffffffc0200d10:	9522                	add	a0,a0,s0
ffffffffc0200d12:	b5dff0ef          	jal	ra,ffffffffc020086e <free_pages>
    
    p0=alloc_pages(1024);
ffffffffc0200d16:	40000513          	li	a0,1024
ffffffffc0200d1a:	b11ff0ef          	jal	ra,ffffffffc020082a <alloc_pages>
ffffffffc0200d1e:	8a2a                	mv	s4,a0
    cprintf("p0 %p\n",p0);
ffffffffc0200d20:	85aa                	mv	a1,a0
ffffffffc0200d22:	00001517          	auipc	a0,0x1
ffffffffc0200d26:	46e50513          	addi	a0,a0,1134 # ffffffffc0202190 <commands+0x808>
ffffffffc0200d2a:	b8cff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    assert(p0 == A);
ffffffffc0200d2e:	13441863          	bne	s0,s4,ffffffffc0200e5e <buddy_check+0x204>
    //以下是根据链接中的样例测试编写的
    A=alloc_pages(70);  
ffffffffc0200d32:	04600513          	li	a0,70
ffffffffc0200d36:	af5ff0ef          	jal	ra,ffffffffc020082a <alloc_pages>
ffffffffc0200d3a:	892a                	mv	s2,a0
    B=alloc_pages(35);
ffffffffc0200d3c:	02300513          	li	a0,35
ffffffffc0200d40:	aebff0ef          	jal	ra,ffffffffc020082a <alloc_pages>
    assert(A+128==B);//检查是否相邻
ffffffffc0200d44:	6405                	lui	s0,0x1
ffffffffc0200d46:	40040793          	addi	a5,s0,1024 # 1400 <BASE_ADDRESS-0xffffffffc01fec00>
ffffffffc0200d4a:	97ca                	add	a5,a5,s2
    B=alloc_pages(35);
ffffffffc0200d4c:	84aa                	mv	s1,a0
    assert(A+128==B);//检查是否相邻
ffffffffc0200d4e:	14f51863          	bne	a0,a5,ffffffffc0200e9e <buddy_check+0x244>
    cprintf("A %p\n",A);
ffffffffc0200d52:	85ca                	mv	a1,s2
ffffffffc0200d54:	00001517          	auipc	a0,0x1
ffffffffc0200d58:	42c50513          	addi	a0,a0,1068 # ffffffffc0202180 <commands+0x7f8>
ffffffffc0200d5c:	b5aff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("B %p\n",B);
ffffffffc0200d60:	85a6                	mv	a1,s1
ffffffffc0200d62:	00001517          	auipc	a0,0x1
ffffffffc0200d66:	42650513          	addi	a0,a0,1062 # ffffffffc0202188 <commands+0x800>
ffffffffc0200d6a:	b4cff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    C=alloc_pages(80);
ffffffffc0200d6e:	05000513          	li	a0,80
ffffffffc0200d72:	ab9ff0ef          	jal	ra,ffffffffc020082a <alloc_pages>
    assert(A+256==C);//检查C有没有和A重叠
ffffffffc0200d76:	678d                	lui	a5,0x3
ffffffffc0200d78:	80078793          	addi	a5,a5,-2048 # 2800 <BASE_ADDRESS-0xffffffffc01fd800>
ffffffffc0200d7c:	97ca                	add	a5,a5,s2
    C=alloc_pages(80);
ffffffffc0200d7e:	89aa                	mv	s3,a0
    assert(A+256==C);//检查C有没有和A重叠
ffffffffc0200d80:	0ef51f63          	bne	a0,a5,ffffffffc0200e7e <buddy_check+0x224>
    cprintf("C %p\n",C);
ffffffffc0200d84:	85aa                	mv	a1,a0
ffffffffc0200d86:	00001517          	auipc	a0,0x1
ffffffffc0200d8a:	43a50513          	addi	a0,a0,1082 # ffffffffc02021c0 <commands+0x838>
ffffffffc0200d8e:	b28ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    free_pages(A,70);//释放A
ffffffffc0200d92:	854a                	mv	a0,s2
ffffffffc0200d94:	04600593          	li	a1,70
ffffffffc0200d98:	ad7ff0ef          	jal	ra,ffffffffc020086e <free_pages>
    cprintf("B %p\n",B);
ffffffffc0200d9c:	85a6                	mv	a1,s1
ffffffffc0200d9e:	00001517          	auipc	a0,0x1
ffffffffc0200da2:	3ea50513          	addi	a0,a0,1002 # ffffffffc0202188 <commands+0x800>
ffffffffc0200da6:	b10ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    D=alloc_pages(60);
ffffffffc0200daa:	03c00513          	li	a0,60
ffffffffc0200dae:	a7dff0ef          	jal	ra,ffffffffc020082a <alloc_pages>
    cprintf("D %p\n",D);
    assert(B+64==D);//检查B，D是否相邻
ffffffffc0200db2:	a0040413          	addi	s0,s0,-1536
    cprintf("D %p\n",D);
ffffffffc0200db6:	85aa                	mv	a1,a0
    D=alloc_pages(60);
ffffffffc0200db8:	892a                	mv	s2,a0
    assert(B+64==D);//检查B，D是否相邻
ffffffffc0200dba:	9426                	add	s0,s0,s1
    cprintf("D %p\n",D);
ffffffffc0200dbc:	00001517          	auipc	a0,0x1
ffffffffc0200dc0:	40c50513          	addi	a0,a0,1036 # ffffffffc02021c8 <commands+0x840>
ffffffffc0200dc4:	af2ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    assert(B+64==D);//检查B，D是否相邻
ffffffffc0200dc8:	14891b63          	bne	s2,s0,ffffffffc0200f1e <buddy_check+0x2c4>
    free_pages(B,35);
ffffffffc0200dcc:	8526                	mv	a0,s1
ffffffffc0200dce:	02300593          	li	a1,35
ffffffffc0200dd2:	a9dff0ef          	jal	ra,ffffffffc020086e <free_pages>
    cprintf("D %p\n",D);
ffffffffc0200dd6:	85ca                	mv	a1,s2
ffffffffc0200dd8:	00001517          	auipc	a0,0x1
ffffffffc0200ddc:	3f050513          	addi	a0,a0,1008 # ffffffffc02021c8 <commands+0x840>
ffffffffc0200de0:	ad6ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    free_pages(D,60);
ffffffffc0200de4:	854a                	mv	a0,s2
ffffffffc0200de6:	03c00593          	li	a1,60
ffffffffc0200dea:	a85ff0ef          	jal	ra,ffffffffc020086e <free_pages>
    cprintf("C %p\n",C);
ffffffffc0200dee:	85ce                	mv	a1,s3
ffffffffc0200df0:	00001517          	auipc	a0,0x1
ffffffffc0200df4:	3d050513          	addi	a0,a0,976 # ffffffffc02021c0 <commands+0x838>
ffffffffc0200df8:	abeff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    free_pages(C,80);
ffffffffc0200dfc:	854e                	mv	a0,s3
ffffffffc0200dfe:	05000593          	li	a1,80
ffffffffc0200e02:	a6dff0ef          	jal	ra,ffffffffc020086e <free_pages>
    free_pages(p0,1000);//全部释放
}
ffffffffc0200e06:	7402                	ld	s0,32(sp)
ffffffffc0200e08:	70a2                	ld	ra,40(sp)
ffffffffc0200e0a:	64e2                	ld	s1,24(sp)
ffffffffc0200e0c:	6942                	ld	s2,16(sp)
ffffffffc0200e0e:	69a2                	ld	s3,8(sp)
    free_pages(p0,1000);//全部释放
ffffffffc0200e10:	8552                	mv	a0,s4
}
ffffffffc0200e12:	6a02                	ld	s4,0(sp)
    free_pages(p0,1000);//全部释放
ffffffffc0200e14:	3e800593          	li	a1,1000
}
ffffffffc0200e18:	6145                	addi	sp,sp,48
    free_pages(p0,1000);//全部释放
ffffffffc0200e1a:	a55ff06f          	j	ffffffffc020086e <free_pages>
    assert(p0 != A && p0 != B && A != B);
ffffffffc0200e1e:	00001697          	auipc	a3,0x1
ffffffffc0200e22:	30268693          	addi	a3,a3,770 # ffffffffc0202120 <commands+0x798>
ffffffffc0200e26:	00001617          	auipc	a2,0x1
ffffffffc0200e2a:	3e260613          	addi	a2,a2,994 # ffffffffc0202208 <commands+0x880>
ffffffffc0200e2e:	0ff00593          	li	a1,255
ffffffffc0200e32:	00001517          	auipc	a0,0x1
ffffffffc0200e36:	3ee50513          	addi	a0,a0,1006 # ffffffffc0202220 <commands+0x898>
ffffffffc0200e3a:	b04ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(page_ref(p0) == 0 && page_ref(A) == 0 && page_ref(B) == 0);
ffffffffc0200e3e:	00001697          	auipc	a3,0x1
ffffffffc0200e42:	30268693          	addi	a3,a3,770 # ffffffffc0202140 <commands+0x7b8>
ffffffffc0200e46:	00001617          	auipc	a2,0x1
ffffffffc0200e4a:	3c260613          	addi	a2,a2,962 # ffffffffc0202208 <commands+0x880>
ffffffffc0200e4e:	10000593          	li	a1,256
ffffffffc0200e52:	00001517          	auipc	a0,0x1
ffffffffc0200e56:	3ce50513          	addi	a0,a0,974 # ffffffffc0202220 <commands+0x898>
ffffffffc0200e5a:	ae4ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(p0 == A);
ffffffffc0200e5e:	00001697          	auipc	a3,0x1
ffffffffc0200e62:	33a68693          	addi	a3,a3,826 # ffffffffc0202198 <commands+0x810>
ffffffffc0200e66:	00001617          	auipc	a2,0x1
ffffffffc0200e6a:	3a260613          	addi	a2,a2,930 # ffffffffc0202208 <commands+0x880>
ffffffffc0200e6e:	10f00593          	li	a1,271
ffffffffc0200e72:	00001517          	auipc	a0,0x1
ffffffffc0200e76:	3ae50513          	addi	a0,a0,942 # ffffffffc0202220 <commands+0x898>
ffffffffc0200e7a:	ac4ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(A+256==C);//检查C有没有和A重叠
ffffffffc0200e7e:	00001697          	auipc	a3,0x1
ffffffffc0200e82:	33268693          	addi	a3,a3,818 # ffffffffc02021b0 <commands+0x828>
ffffffffc0200e86:	00001617          	auipc	a2,0x1
ffffffffc0200e8a:	38260613          	addi	a2,a2,898 # ffffffffc0202208 <commands+0x880>
ffffffffc0200e8e:	11700593          	li	a1,279
ffffffffc0200e92:	00001517          	auipc	a0,0x1
ffffffffc0200e96:	38e50513          	addi	a0,a0,910 # ffffffffc0202220 <commands+0x898>
ffffffffc0200e9a:	aa4ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(A+128==B);//检查是否相邻
ffffffffc0200e9e:	00001697          	auipc	a3,0x1
ffffffffc0200ea2:	30268693          	addi	a3,a3,770 # ffffffffc02021a0 <commands+0x818>
ffffffffc0200ea6:	00001617          	auipc	a2,0x1
ffffffffc0200eaa:	36260613          	addi	a2,a2,866 # ffffffffc0202208 <commands+0x880>
ffffffffc0200eae:	11300593          	li	a1,275
ffffffffc0200eb2:	00001517          	auipc	a0,0x1
ffffffffc0200eb6:	36e50513          	addi	a0,a0,878 # ffffffffc0202220 <commands+0x898>
ffffffffc0200eba:	a84ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert((B = alloc_page()) != NULL);
ffffffffc0200ebe:	00001697          	auipc	a3,0x1
ffffffffc0200ec2:	24268693          	addi	a3,a3,578 # ffffffffc0202100 <commands+0x778>
ffffffffc0200ec6:	00001617          	auipc	a2,0x1
ffffffffc0200eca:	34260613          	addi	a2,a2,834 # ffffffffc0202208 <commands+0x880>
ffffffffc0200ece:	0fd00593          	li	a1,253
ffffffffc0200ed2:	00001517          	auipc	a0,0x1
ffffffffc0200ed6:	34e50513          	addi	a0,a0,846 # ffffffffc0202220 <commands+0x898>
ffffffffc0200eda:	a64ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert((A = alloc_page()) != NULL);
ffffffffc0200ede:	00001697          	auipc	a3,0x1
ffffffffc0200ee2:	20268693          	addi	a3,a3,514 # ffffffffc02020e0 <commands+0x758>
ffffffffc0200ee6:	00001617          	auipc	a2,0x1
ffffffffc0200eea:	32260613          	addi	a2,a2,802 # ffffffffc0202208 <commands+0x880>
ffffffffc0200eee:	0fc00593          	li	a1,252
ffffffffc0200ef2:	00001517          	auipc	a0,0x1
ffffffffc0200ef6:	32e50513          	addi	a0,a0,814 # ffffffffc0202220 <commands+0x898>
ffffffffc0200efa:	a44ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200efe:	00001697          	auipc	a3,0x1
ffffffffc0200f02:	1c268693          	addi	a3,a3,450 # ffffffffc02020c0 <commands+0x738>
ffffffffc0200f06:	00001617          	auipc	a2,0x1
ffffffffc0200f0a:	30260613          	addi	a2,a2,770 # ffffffffc0202208 <commands+0x880>
ffffffffc0200f0e:	0fb00593          	li	a1,251
ffffffffc0200f12:	00001517          	auipc	a0,0x1
ffffffffc0200f16:	30e50513          	addi	a0,a0,782 # ffffffffc0202220 <commands+0x898>
ffffffffc0200f1a:	a24ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(B+64==D);//检查B，D是否相邻
ffffffffc0200f1e:	00001697          	auipc	a3,0x1
ffffffffc0200f22:	2b268693          	addi	a3,a3,690 # ffffffffc02021d0 <commands+0x848>
ffffffffc0200f26:	00001617          	auipc	a2,0x1
ffffffffc0200f2a:	2e260613          	addi	a2,a2,738 # ffffffffc0202208 <commands+0x880>
ffffffffc0200f2e:	11d00593          	li	a1,285
ffffffffc0200f32:	00001517          	auipc	a0,0x1
ffffffffc0200f36:	2ee50513          	addi	a0,a0,750 # ffffffffc0202220 <commands+0x898>
ffffffffc0200f3a:	a04ff0ef          	jal	ra,ffffffffc020013e <__panic>

ffffffffc0200f3e <buddy2_new.part.2>:
  root[0].size = size;
ffffffffc0200f3e:	00005717          	auipc	a4,0x5
ffffffffc0200f42:	52a72d23          	sw	a0,1338(a4) # ffffffffc0206478 <root>
  node_size = size * 2;
ffffffffc0200f46:	0015161b          	slliw	a2,a0,0x1
  for (i = 0; i < 2 * size - 1; ++i) {//初始化每一个节点
ffffffffc0200f4a:	4705                	li	a4,1
ffffffffc0200f4c:	02c75563          	ble	a2,a4,ffffffffc0200f76 <buddy2_new.part.2+0x38>
ffffffffc0200f50:	00005717          	auipc	a4,0x5
ffffffffc0200f54:	52c70713          	addi	a4,a4,1324 # ffffffffc020647c <root+0x4>
ffffffffc0200f58:	fff6051b          	addiw	a0,a2,-1
ffffffffc0200f5c:	4781                	li	a5,0
    if (IS_POWER_OF_2(i+1))//每一行
ffffffffc0200f5e:	0017869b          	addiw	a3,a5,1
ffffffffc0200f62:	00f6f5b3          	and	a1,a3,a5
ffffffffc0200f66:	87b6                	mv	a5,a3
ffffffffc0200f68:	e199                	bnez	a1,ffffffffc0200f6e <buddy2_new.part.2+0x30>
        node_size /= 2;
ffffffffc0200f6a:	0016561b          	srliw	a2,a2,0x1
    root[i].longest = node_size;
ffffffffc0200f6e:	c310                	sw	a2,0(a4)
ffffffffc0200f70:	0721                	addi	a4,a4,8
  for (i = 0; i < 2 * size - 1; ++i) {//初始化每一个节点
ffffffffc0200f72:	fea796e3          	bne	a5,a0,ffffffffc0200f5e <buddy2_new.part.2+0x20>
}
ffffffffc0200f76:	8082                	ret

ffffffffc0200f78 <buddy_init_memmap>:
{
ffffffffc0200f78:	1141                	addi	sp,sp,-16
ffffffffc0200f7a:	e406                	sd	ra,8(sp)
    assert(n>0);
ffffffffc0200f7c:	c5f5                	beqz	a1,ffffffffc0201068 <buddy_init_memmap+0xf0>
    for(;p!=base + n;p++)
ffffffffc0200f7e:	00259613          	slli	a2,a1,0x2
ffffffffc0200f82:	962e                	add	a2,a2,a1
ffffffffc0200f84:	060e                	slli	a2,a2,0x3
ffffffffc0200f86:	962a                	add	a2,a2,a0
ffffffffc0200f88:	0aa60b63          	beq	a2,a0,ffffffffc020103e <buddy_init_memmap+0xc6>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200f8c:	651c                	ld	a5,8(a0)
        assert(PageReserved(p));
ffffffffc0200f8e:	8b85                	andi	a5,a5,1
ffffffffc0200f90:	cfc5                	beqz	a5,ffffffffc0201048 <buddy_init_memmap+0xd0>
ffffffffc0200f92:	00005697          	auipc	a3,0x5
ffffffffc0200f96:	4c668693          	addi	a3,a3,1222 # ffffffffc0206458 <free_area>
        p->property = 1;
ffffffffc0200f9a:	4885                	li	a7,1
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200f9c:	4809                	li	a6,2
ffffffffc0200f9e:	a021                	j	ffffffffc0200fa6 <buddy_init_memmap+0x2e>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200fa0:	651c                	ld	a5,8(a0)
        assert(PageReserved(p));
ffffffffc0200fa2:	8b85                	andi	a5,a5,1
ffffffffc0200fa4:	c3d5                	beqz	a5,ffffffffc0201048 <buddy_init_memmap+0xd0>
        p->flags = 0;
ffffffffc0200fa6:	00053423          	sd	zero,8(a0)
        p->property = 1;
ffffffffc0200faa:	01152823          	sw	a7,16(a0)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200fae:	00052023          	sw	zero,0(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200fb2:	00850793          	addi	a5,a0,8
ffffffffc0200fb6:	4107b02f          	amoor.d	zero,a6,(a5)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0200fba:	629c                	ld	a5,0(a3)
ffffffffc0200fbc:	01850713          	addi	a4,a0,24
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0200fc0:	00005317          	auipc	t1,0x5
ffffffffc0200fc4:	48e33c23          	sd	a4,1176(t1) # ffffffffc0206458 <free_area>
ffffffffc0200fc8:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0200fca:	f114                	sd	a3,32(a0)
    elm->prev = prev;
ffffffffc0200fcc:	ed1c                	sd	a5,24(a0)
    for(;p!=base + n;p++)
ffffffffc0200fce:	02850513          	addi	a0,a0,40
ffffffffc0200fd2:	fca617e3          	bne	a2,a0,ffffffffc0200fa0 <buddy_init_memmap+0x28>
    int allocpages=UINT32_ROUND_DOWN(n);
ffffffffc0200fd6:	0015d793          	srli	a5,a1,0x1
ffffffffc0200fda:	8fcd                	or	a5,a5,a1
ffffffffc0200fdc:	0027d713          	srli	a4,a5,0x2
ffffffffc0200fe0:	8fd9                	or	a5,a5,a4
ffffffffc0200fe2:	0047d713          	srli	a4,a5,0x4
ffffffffc0200fe6:	8f5d                	or	a4,a4,a5
ffffffffc0200fe8:	00875793          	srli	a5,a4,0x8
ffffffffc0200fec:	8f5d                	or	a4,a4,a5
    nr_free += n;
ffffffffc0200fee:	4a94                	lw	a3,16(a3)
    int allocpages=UINT32_ROUND_DOWN(n);
ffffffffc0200ff0:	01075793          	srli	a5,a4,0x10
    nr_free += n;
ffffffffc0200ff4:	0005851b          	sext.w	a0,a1
    int allocpages=UINT32_ROUND_DOWN(n);
ffffffffc0200ff8:	8fd9                	or	a5,a5,a4
ffffffffc0200ffa:	8385                	srli	a5,a5,0x1
    nr_free += n;
ffffffffc0200ffc:	00a6873b          	addw	a4,a3,a0
ffffffffc0201000:	00005697          	auipc	a3,0x5
ffffffffc0201004:	46e6a423          	sw	a4,1128(a3) # ffffffffc0206468 <free_area+0x10>
    int allocpages=UINT32_ROUND_DOWN(n);
ffffffffc0201008:	8dfd                	and	a1,a1,a5
ffffffffc020100a:	e19d                	bnez	a1,ffffffffc0201030 <buddy_init_memmap+0xb8>
  nr_block=0;
ffffffffc020100c:	00005797          	auipc	a5,0x5
ffffffffc0201010:	4607a223          	sw	zero,1124(a5) # ffffffffc0206470 <nr_block>
  if (size < 1 || !IS_POWER_OF_2(size))
ffffffffc0201014:	00a05b63          	blez	a0,ffffffffc020102a <buddy_init_memmap+0xb2>
ffffffffc0201018:	fff5079b          	addiw	a5,a0,-1
ffffffffc020101c:	8fe9                	and	a5,a5,a0
ffffffffc020101e:	2781                	sext.w	a5,a5
ffffffffc0201020:	e789                	bnez	a5,ffffffffc020102a <buddy_init_memmap+0xb2>
}
ffffffffc0201022:	60a2                	ld	ra,8(sp)
ffffffffc0201024:	0141                	addi	sp,sp,16
ffffffffc0201026:	f19ff06f          	j	ffffffffc0200f3e <buddy2_new.part.2>
ffffffffc020102a:	60a2                	ld	ra,8(sp)
ffffffffc020102c:	0141                	addi	sp,sp,16
ffffffffc020102e:	8082                	ret
    int allocpages=UINT32_ROUND_DOWN(n);
ffffffffc0201030:	fff7c713          	not	a4,a5
ffffffffc0201034:	00a777b3          	and	a5,a4,a0
ffffffffc0201038:	0007851b          	sext.w	a0,a5
ffffffffc020103c:	bfc1                	j	ffffffffc020100c <buddy_init_memmap+0x94>
ffffffffc020103e:	00005697          	auipc	a3,0x5
ffffffffc0201042:	41a68693          	addi	a3,a3,1050 # ffffffffc0206458 <free_area>
ffffffffc0201046:	bf41                	j	ffffffffc0200fd6 <buddy_init_memmap+0x5e>
        assert(PageReserved(p));
ffffffffc0201048:	00001697          	auipc	a3,0x1
ffffffffc020104c:	1f868693          	addi	a3,a3,504 # ffffffffc0202240 <commands+0x8b8>
ffffffffc0201050:	00001617          	auipc	a2,0x1
ffffffffc0201054:	1b860613          	addi	a2,a2,440 # ffffffffc0202208 <commands+0x880>
ffffffffc0201058:	05500593          	li	a1,85
ffffffffc020105c:	00001517          	auipc	a0,0x1
ffffffffc0201060:	1c450513          	addi	a0,a0,452 # ffffffffc0202220 <commands+0x898>
ffffffffc0201064:	8daff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(n>0);
ffffffffc0201068:	00001697          	auipc	a3,0x1
ffffffffc020106c:	1d068693          	addi	a3,a3,464 # ffffffffc0202238 <commands+0x8b0>
ffffffffc0201070:	00001617          	auipc	a2,0x1
ffffffffc0201074:	19860613          	addi	a2,a2,408 # ffffffffc0202208 <commands+0x880>
ffffffffc0201078:	05100593          	li	a1,81
ffffffffc020107c:	00001517          	auipc	a0,0x1
ffffffffc0201080:	1a450513          	addi	a0,a0,420 # ffffffffc0202220 <commands+0x898>
ffffffffc0201084:	8baff0ef          	jal	ra,ffffffffc020013e <__panic>

ffffffffc0201088 <buddy2_alloc>:
int buddy2_alloc(struct buddy2* self, int size) {
ffffffffc0201088:	882a                	mv	a6,a0
  if (self==NULL)//无法分配
ffffffffc020108a:	c169                	beqz	a0,ffffffffc020114c <buddy2_alloc+0xc4>
  if (size <= 0)//分配不合理
ffffffffc020108c:	4605                	li	a2,1
ffffffffc020108e:	00b05963          	blez	a1,ffffffffc02010a0 <buddy2_alloc+0x18>
  else if (!IS_POWER_OF_2(size))//不为2的幂时，取比size更大的2的n次幂
ffffffffc0201092:	fff5879b          	addiw	a5,a1,-1
ffffffffc0201096:	8fed                	and	a5,a5,a1
ffffffffc0201098:	2781                	sext.w	a5,a5
ffffffffc020109a:	0005861b          	sext.w	a2,a1
ffffffffc020109e:	ebcd                	bnez	a5,ffffffffc0201150 <buddy2_alloc+0xc8>
  if (self[index].longest < size)//可分配内存不足
ffffffffc02010a0:	00482783          	lw	a5,4(a6)
ffffffffc02010a4:	0ac7e463          	bltu	a5,a2,ffffffffc020114c <buddy2_alloc+0xc4>
  for(node_size = self->size; node_size != size; node_size /= 2 ) {
ffffffffc02010a8:	00082503          	lw	a0,0(a6)
ffffffffc02010ac:	0cc50763          	beq	a0,a2,ffffffffc020117a <buddy2_alloc+0xf2>
ffffffffc02010b0:	85aa                	mv	a1,a0
  unsigned index = 0;//节点的标号
ffffffffc02010b2:	4781                	li	a5,0
    if (self[LEFT_LEAF(index)].longest >= size)
ffffffffc02010b4:	0017989b          	slliw	a7,a5,0x1
ffffffffc02010b8:	0018879b          	addiw	a5,a7,1
ffffffffc02010bc:	02079713          	slli	a4,a5,0x20
ffffffffc02010c0:	8375                	srli	a4,a4,0x1d
ffffffffc02010c2:	9742                	add	a4,a4,a6
ffffffffc02010c4:	00472303          	lw	t1,4(a4)
ffffffffc02010c8:	0028869b          	addiw	a3,a7,2
       if(self[RIGHT_LEAF(index)].longest>=size)
ffffffffc02010cc:	02069713          	slli	a4,a3,0x20
ffffffffc02010d0:	8375                	srli	a4,a4,0x1d
ffffffffc02010d2:	9742                	add	a4,a4,a6
    if (self[LEFT_LEAF(index)].longest >= size)
ffffffffc02010d4:	00c36763          	bltu	t1,a2,ffffffffc02010e2 <buddy2_alloc+0x5a>
       if(self[RIGHT_LEAF(index)].longest>=size)
ffffffffc02010d8:	4358                	lw	a4,4(a4)
ffffffffc02010da:	00c76763          	bltu	a4,a2,ffffffffc02010e8 <buddy2_alloc+0x60>
           index=self[LEFT_LEAF(index)].longest <= self[RIGHT_LEAF(index)].longest? LEFT_LEAF(index):RIGHT_LEAF(index);
ffffffffc02010de:	00677563          	bleu	t1,a4,ffffffffc02010e8 <buddy2_alloc+0x60>
      index = RIGHT_LEAF(index);
ffffffffc02010e2:	87b6                	mv	a5,a3
    if (self[LEFT_LEAF(index)].longest >= size)
ffffffffc02010e4:	0038869b          	addiw	a3,a7,3
  for(node_size = self->size; node_size != size; node_size /= 2 ) {
ffffffffc02010e8:	0015d59b          	srliw	a1,a1,0x1
ffffffffc02010ec:	fcc594e3          	bne	a1,a2,ffffffffc02010b4 <buddy2_alloc+0x2c>
  offset = (index + 1) * node_size - self->size;//第offset个叶节点
ffffffffc02010f0:	02d586bb          	mulw	a3,a1,a3
  self[index].longest = 0;//标记节点为已使用
ffffffffc02010f4:	02079713          	slli	a4,a5,0x20
ffffffffc02010f8:	8375                	srli	a4,a4,0x1d
ffffffffc02010fa:	9742                	add	a4,a4,a6
ffffffffc02010fc:	00072223          	sw	zero,4(a4)
  while (index) {
ffffffffc0201100:	40a6853b          	subw	a0,a3,a0
ffffffffc0201104:	c7a9                	beqz	a5,ffffffffc020114e <buddy2_alloc+0xc6>
    index = PARENT(index);
ffffffffc0201106:	2785                	addiw	a5,a5,1
ffffffffc0201108:	0017d61b          	srliw	a2,a5,0x1
ffffffffc020110c:	367d                	addiw	a2,a2,-1
      MAX(self[LEFT_LEAF(index)].longest, self[RIGHT_LEAF(index)].longest);
ffffffffc020110e:	0016169b          	slliw	a3,a2,0x1
ffffffffc0201112:	ffe7f713          	andi	a4,a5,-2
ffffffffc0201116:	2685                	addiw	a3,a3,1
ffffffffc0201118:	1682                	slli	a3,a3,0x20
ffffffffc020111a:	1702                	slli	a4,a4,0x20
ffffffffc020111c:	9281                	srli	a3,a3,0x20
ffffffffc020111e:	9301                	srli	a4,a4,0x20
ffffffffc0201120:	068e                	slli	a3,a3,0x3
ffffffffc0201122:	070e                	slli	a4,a4,0x3
ffffffffc0201124:	9742                	add	a4,a4,a6
ffffffffc0201126:	96c2                	add	a3,a3,a6
ffffffffc0201128:	434c                	lw	a1,4(a4)
ffffffffc020112a:	42d4                	lw	a3,4(a3)
    self[index].longest = 
ffffffffc020112c:	02061713          	slli	a4,a2,0x20
ffffffffc0201130:	8375                	srli	a4,a4,0x1d
      MAX(self[LEFT_LEAF(index)].longest, self[RIGHT_LEAF(index)].longest);
ffffffffc0201132:	0006831b          	sext.w	t1,a3
ffffffffc0201136:	0005889b          	sext.w	a7,a1
    index = PARENT(index);
ffffffffc020113a:	0006079b          	sext.w	a5,a2
    self[index].longest = 
ffffffffc020113e:	9742                	add	a4,a4,a6
      MAX(self[LEFT_LEAF(index)].longest, self[RIGHT_LEAF(index)].longest);
ffffffffc0201140:	01137363          	bleu	a7,t1,ffffffffc0201146 <buddy2_alloc+0xbe>
ffffffffc0201144:	86ae                	mv	a3,a1
    self[index].longest = 
ffffffffc0201146:	c354                	sw	a3,4(a4)
  while (index) {
ffffffffc0201148:	ffdd                	bnez	a5,ffffffffc0201106 <buddy2_alloc+0x7e>
ffffffffc020114a:	8082                	ret
    return -1;
ffffffffc020114c:	557d                	li	a0,-1
}
ffffffffc020114e:	8082                	ret
  size |= size >> 1;
ffffffffc0201150:	0016579b          	srliw	a5,a2,0x1
ffffffffc0201154:	8e5d                	or	a2,a2,a5
ffffffffc0201156:	2601                	sext.w	a2,a2
  size |= size >> 2;
ffffffffc0201158:	0026579b          	srliw	a5,a2,0x2
ffffffffc020115c:	8e5d                	or	a2,a2,a5
ffffffffc020115e:	2601                	sext.w	a2,a2
  size |= size >> 4;
ffffffffc0201160:	0046579b          	srliw	a5,a2,0x4
ffffffffc0201164:	8e5d                	or	a2,a2,a5
ffffffffc0201166:	2601                	sext.w	a2,a2
  size |= size >> 8;
ffffffffc0201168:	0086579b          	srliw	a5,a2,0x8
ffffffffc020116c:	8e5d                	or	a2,a2,a5
ffffffffc020116e:	2601                	sext.w	a2,a2
  size |= size >> 16;
ffffffffc0201170:	0106579b          	srliw	a5,a2,0x10
ffffffffc0201174:	8e5d                	or	a2,a2,a5
  return size+1;
ffffffffc0201176:	2605                	addiw	a2,a2,1
ffffffffc0201178:	b725                	j	ffffffffc02010a0 <buddy2_alloc+0x18>
  self[index].longest = 0;//标记节点为已使用
ffffffffc020117a:	00082223          	sw	zero,4(a6)
ffffffffc020117e:	4501                	li	a0,0
ffffffffc0201180:	8082                	ret

ffffffffc0201182 <buddy_alloc_pages>:
buddy_alloc_pages(size_t n){
ffffffffc0201182:	7179                	addi	sp,sp,-48
ffffffffc0201184:	f406                	sd	ra,40(sp)
ffffffffc0201186:	f022                	sd	s0,32(sp)
ffffffffc0201188:	ec26                	sd	s1,24(sp)
ffffffffc020118a:	e84a                	sd	s2,16(sp)
ffffffffc020118c:	e44e                	sd	s3,8(sp)
ffffffffc020118e:	e052                	sd	s4,0(sp)
  assert(n>0);
ffffffffc0201190:	10050563          	beqz	a0,ffffffffc020129a <buddy_alloc_pages+0x118>
ffffffffc0201194:	892a                	mv	s2,a0
  if(n>nr_free)
ffffffffc0201196:	00005797          	auipc	a5,0x5
ffffffffc020119a:	2d27e783          	lwu	a5,722(a5) # ffffffffc0206468 <free_area+0x10>
ffffffffc020119e:	00005497          	auipc	s1,0x5
ffffffffc02011a2:	2ba48493          	addi	s1,s1,698 # ffffffffc0206458 <free_area>
   return NULL;
ffffffffc02011a6:	4501                	li	a0,0
  if(n>nr_free)
ffffffffc02011a8:	0b27e963          	bltu	a5,s2,ffffffffc020125a <buddy_alloc_pages+0xd8>
  rec[nr_block].offset=buddy2_alloc(root,n);//记录偏移量
ffffffffc02011ac:	0009041b          	sext.w	s0,s2
ffffffffc02011b0:	00005a17          	auipc	s4,0x5
ffffffffc02011b4:	2c0a0a13          	addi	s4,s4,704 # ffffffffc0206470 <nr_block>
ffffffffc02011b8:	85a2                	mv	a1,s0
ffffffffc02011ba:	00005517          	auipc	a0,0x5
ffffffffc02011be:	2be50513          	addi	a0,a0,702 # ffffffffc0206478 <root>
ffffffffc02011c2:	000a2983          	lw	s3,0(s4)
ffffffffc02011c6:	ec3ff0ef          	jal	ra,ffffffffc0201088 <buddy2_alloc>
  for(i=0;i<rec[nr_block].offset+1;i++)
ffffffffc02011ca:	000a2583          	lw	a1,0(s4)
  rec[nr_block].offset=buddy2_alloc(root,n);//记录偏移量
ffffffffc02011ce:	00199793          	slli	a5,s3,0x1
ffffffffc02011d2:	97ce                	add	a5,a5,s3
  for(i=0;i<rec[nr_block].offset+1;i++)
ffffffffc02011d4:	00159893          	slli	a7,a1,0x1
  rec[nr_block].offset=buddy2_alloc(root,n);//记录偏移量
ffffffffc02011d8:	000a1817          	auipc	a6,0xa1
ffffffffc02011dc:	6a080813          	addi	a6,a6,1696 # ffffffffc02a2878 <rec>
ffffffffc02011e0:	078e                	slli	a5,a5,0x3
  for(i=0;i<rec[nr_block].offset+1;i++)
ffffffffc02011e2:	00b88733          	add	a4,a7,a1
  rec[nr_block].offset=buddy2_alloc(root,n);//记录偏移量
ffffffffc02011e6:	97c2                	add	a5,a5,a6
  for(i=0;i<rec[nr_block].offset+1;i++)
ffffffffc02011e8:	070e                	slli	a4,a4,0x3
  rec[nr_block].offset=buddy2_alloc(root,n);//记录偏移量
ffffffffc02011ea:	c788                	sw	a0,8(a5)
  for(i=0;i<rec[nr_block].offset+1;i++)
ffffffffc02011ec:	9742                	add	a4,a4,a6
ffffffffc02011ee:	4718                	lw	a4,8(a4)
  rec[nr_block].offset=buddy2_alloc(root,n);//记录偏移量
ffffffffc02011f0:	86a2                	mv	a3,s0
  for(i=0;i<rec[nr_block].offset+1;i++)
ffffffffc02011f2:	0a074263          	bltz	a4,ffffffffc0201296 <buddy_alloc_pages+0x114>
ffffffffc02011f6:	2705                	addiw	a4,a4,1
ffffffffc02011f8:	4781                	li	a5,0
  list_entry_t *le=&free_list,*len;
ffffffffc02011fa:	8626                	mv	a2,s1
  for(i=0;i<rec[nr_block].offset+1;i++)
ffffffffc02011fc:	2785                	addiw	a5,a5,1
    return listelm->next;
ffffffffc02011fe:	6610                	ld	a2,8(a2)
ffffffffc0201200:	fef71ee3          	bne	a4,a5,ffffffffc02011fc <buddy_alloc_pages+0x7a>
  if(!IS_POWER_OF_2(n))
ffffffffc0201204:	fff90793          	addi	a5,s2,-1
ffffffffc0201208:	0127f933          	and	s2,a5,s2
  page=le2page(le,page_link);
ffffffffc020120c:	fe860513          	addi	a0,a2,-24
  if(!IS_POWER_OF_2(n))
ffffffffc0201210:	8322                	mv	t1,s0
ffffffffc0201212:	04091c63          	bnez	s2,ffffffffc020126a <buddy_alloc_pages+0xe8>
  rec[nr_block].base=page;//记录分配块首页
ffffffffc0201216:	98ae                	add	a7,a7,a1
ffffffffc0201218:	088e                	slli	a7,a7,0x3
ffffffffc020121a:	9846                	add	a6,a6,a7
  nr_block++;
ffffffffc020121c:	2585                	addiw	a1,a1,1
  rec[nr_block].base=page;//记录分配块首页
ffffffffc020121e:	00a83023          	sd	a0,0(a6)
  rec[nr_block].nr=allocpages;//记录分配的页数
ffffffffc0201222:	00d83823          	sd	a3,16(a6)
  nr_block++;
ffffffffc0201226:	00005797          	auipc	a5,0x5
ffffffffc020122a:	24b7a523          	sw	a1,586(a5) # ffffffffc0206470 <nr_block>
  for(i=0;i<allocpages;i++)
ffffffffc020122e:	87b2                	mv	a5,a2
ffffffffc0201230:	4701                	li	a4,0
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201232:	5875                	li	a6,-3
ffffffffc0201234:	00d05a63          	blez	a3,ffffffffc0201248 <buddy_alloc_pages+0xc6>
ffffffffc0201238:	678c                	ld	a1,8(a5)
ffffffffc020123a:	17c1                	addi	a5,a5,-16
ffffffffc020123c:	6107b02f          	amoand.d	zero,a6,(a5)
ffffffffc0201240:	2705                	addiw	a4,a4,1
    le=len;
ffffffffc0201242:	87ae                	mv	a5,a1
  for(i=0;i<allocpages;i++)
ffffffffc0201244:	fee69ae3          	bne	a3,a4,ffffffffc0201238 <buddy_alloc_pages+0xb6>
  nr_free-=allocpages;//减去已被分配的页数
ffffffffc0201248:	489c                	lw	a5,16(s1)
ffffffffc020124a:	406787bb          	subw	a5,a5,t1
ffffffffc020124e:	00005717          	auipc	a4,0x5
ffffffffc0201252:	20f72d23          	sw	a5,538(a4) # ffffffffc0206468 <free_area+0x10>
  page->property=n;
ffffffffc0201256:	fe862c23          	sw	s0,-8(a2)
}
ffffffffc020125a:	70a2                	ld	ra,40(sp)
ffffffffc020125c:	7402                	ld	s0,32(sp)
ffffffffc020125e:	64e2                	ld	s1,24(sp)
ffffffffc0201260:	6942                	ld	s2,16(sp)
ffffffffc0201262:	69a2                	ld	s3,8(sp)
ffffffffc0201264:	6a02                	ld	s4,0(sp)
ffffffffc0201266:	6145                	addi	sp,sp,48
ffffffffc0201268:	8082                	ret
  size |= size >> 1;
ffffffffc020126a:	0014569b          	srliw	a3,s0,0x1
ffffffffc020126e:	8ec1                	or	a3,a3,s0
ffffffffc0201270:	2681                	sext.w	a3,a3
  size |= size >> 2;
ffffffffc0201272:	0026d79b          	srliw	a5,a3,0x2
ffffffffc0201276:	8edd                	or	a3,a3,a5
ffffffffc0201278:	2681                	sext.w	a3,a3
  size |= size >> 4;
ffffffffc020127a:	0046d79b          	srliw	a5,a3,0x4
ffffffffc020127e:	8edd                	or	a3,a3,a5
ffffffffc0201280:	2681                	sext.w	a3,a3
  size |= size >> 8;
ffffffffc0201282:	0086d79b          	srliw	a5,a3,0x8
ffffffffc0201286:	8edd                	or	a3,a3,a5
ffffffffc0201288:	2681                	sext.w	a3,a3
  size |= size >> 16;
ffffffffc020128a:	0106d79b          	srliw	a5,a3,0x10
ffffffffc020128e:	8edd                	or	a3,a3,a5
  return size+1;
ffffffffc0201290:	2685                	addiw	a3,a3,1
   allocpages=fixsize(n);
ffffffffc0201292:	8336                	mv	t1,a3
ffffffffc0201294:	b749                	j	ffffffffc0201216 <buddy_alloc_pages+0x94>
  list_entry_t *le=&free_list,*len;
ffffffffc0201296:	8626                	mv	a2,s1
ffffffffc0201298:	b7b5                	j	ffffffffc0201204 <buddy_alloc_pages+0x82>
  assert(n>0);
ffffffffc020129a:	00001697          	auipc	a3,0x1
ffffffffc020129e:	f9e68693          	addi	a3,a3,-98 # ffffffffc0202238 <commands+0x8b0>
ffffffffc02012a2:	00001617          	auipc	a2,0x1
ffffffffc02012a6:	f6660613          	addi	a2,a2,-154 # ffffffffc0202208 <commands+0x880>
ffffffffc02012aa:	08f00593          	li	a1,143
ffffffffc02012ae:	00001517          	auipc	a0,0x1
ffffffffc02012b2:	f7250513          	addi	a0,a0,-142 # ffffffffc0202220 <commands+0x898>
ffffffffc02012b6:	e89fe0ef          	jal	ra,ffffffffc020013e <__panic>

ffffffffc02012ba <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc02012ba:	c185                	beqz	a1,ffffffffc02012da <strnlen+0x20>
ffffffffc02012bc:	00054783          	lbu	a5,0(a0)
ffffffffc02012c0:	cf89                	beqz	a5,ffffffffc02012da <strnlen+0x20>
    size_t cnt = 0;
ffffffffc02012c2:	4781                	li	a5,0
ffffffffc02012c4:	a021                	j	ffffffffc02012cc <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc02012c6:	00074703          	lbu	a4,0(a4)
ffffffffc02012ca:	c711                	beqz	a4,ffffffffc02012d6 <strnlen+0x1c>
        cnt ++;
ffffffffc02012cc:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02012ce:	00f50733          	add	a4,a0,a5
ffffffffc02012d2:	fef59ae3          	bne	a1,a5,ffffffffc02012c6 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc02012d6:	853e                	mv	a0,a5
ffffffffc02012d8:	8082                	ret
    size_t cnt = 0;
ffffffffc02012da:	4781                	li	a5,0
}
ffffffffc02012dc:	853e                	mv	a0,a5
ffffffffc02012de:	8082                	ret

ffffffffc02012e0 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02012e0:	00054783          	lbu	a5,0(a0)
ffffffffc02012e4:	0005c703          	lbu	a4,0(a1)
ffffffffc02012e8:	cb91                	beqz	a5,ffffffffc02012fc <strcmp+0x1c>
ffffffffc02012ea:	00e79c63          	bne	a5,a4,ffffffffc0201302 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc02012ee:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02012f0:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc02012f4:	0585                	addi	a1,a1,1
ffffffffc02012f6:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02012fa:	fbe5                	bnez	a5,ffffffffc02012ea <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02012fc:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02012fe:	9d19                	subw	a0,a0,a4
ffffffffc0201300:	8082                	ret
ffffffffc0201302:	0007851b          	sext.w	a0,a5
ffffffffc0201306:	9d19                	subw	a0,a0,a4
ffffffffc0201308:	8082                	ret

ffffffffc020130a <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc020130a:	00054783          	lbu	a5,0(a0)
ffffffffc020130e:	cb91                	beqz	a5,ffffffffc0201322 <strchr+0x18>
        if (*s == c) {
ffffffffc0201310:	00b79563          	bne	a5,a1,ffffffffc020131a <strchr+0x10>
ffffffffc0201314:	a809                	j	ffffffffc0201326 <strchr+0x1c>
ffffffffc0201316:	00b78763          	beq	a5,a1,ffffffffc0201324 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc020131a:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc020131c:	00054783          	lbu	a5,0(a0)
ffffffffc0201320:	fbfd                	bnez	a5,ffffffffc0201316 <strchr+0xc>
    }
    return NULL;
ffffffffc0201322:	4501                	li	a0,0
}
ffffffffc0201324:	8082                	ret
ffffffffc0201326:	8082                	ret

ffffffffc0201328 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201328:	ca01                	beqz	a2,ffffffffc0201338 <memset+0x10>
ffffffffc020132a:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc020132c:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc020132e:	0785                	addi	a5,a5,1
ffffffffc0201330:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201334:	fec79de3          	bne	a5,a2,ffffffffc020132e <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201338:	8082                	ret

ffffffffc020133a <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc020133a:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020133e:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0201340:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201344:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201346:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020134a:	f022                	sd	s0,32(sp)
ffffffffc020134c:	ec26                	sd	s1,24(sp)
ffffffffc020134e:	e84a                	sd	s2,16(sp)
ffffffffc0201350:	f406                	sd	ra,40(sp)
ffffffffc0201352:	e44e                	sd	s3,8(sp)
ffffffffc0201354:	84aa                	mv	s1,a0
ffffffffc0201356:	892e                	mv	s2,a1
ffffffffc0201358:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc020135c:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc020135e:	03067e63          	bleu	a6,a2,ffffffffc020139a <printnum+0x60>
ffffffffc0201362:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0201364:	00805763          	blez	s0,ffffffffc0201372 <printnum+0x38>
ffffffffc0201368:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc020136a:	85ca                	mv	a1,s2
ffffffffc020136c:	854e                	mv	a0,s3
ffffffffc020136e:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0201370:	fc65                	bnez	s0,ffffffffc0201368 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201372:	1a02                	slli	s4,s4,0x20
ffffffffc0201374:	020a5a13          	srli	s4,s4,0x20
ffffffffc0201378:	00001797          	auipc	a5,0x1
ffffffffc020137c:	0b878793          	addi	a5,a5,184 # ffffffffc0202430 <error_string+0x38>
ffffffffc0201380:	9a3e                	add	s4,s4,a5
}
ffffffffc0201382:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201384:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0201388:	70a2                	ld	ra,40(sp)
ffffffffc020138a:	69a2                	ld	s3,8(sp)
ffffffffc020138c:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020138e:	85ca                	mv	a1,s2
ffffffffc0201390:	8326                	mv	t1,s1
}
ffffffffc0201392:	6942                	ld	s2,16(sp)
ffffffffc0201394:	64e2                	ld	s1,24(sp)
ffffffffc0201396:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201398:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc020139a:	03065633          	divu	a2,a2,a6
ffffffffc020139e:	8722                	mv	a4,s0
ffffffffc02013a0:	f9bff0ef          	jal	ra,ffffffffc020133a <printnum>
ffffffffc02013a4:	b7f9                	j	ffffffffc0201372 <printnum+0x38>

ffffffffc02013a6 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02013a6:	7119                	addi	sp,sp,-128
ffffffffc02013a8:	f4a6                	sd	s1,104(sp)
ffffffffc02013aa:	f0ca                	sd	s2,96(sp)
ffffffffc02013ac:	e8d2                	sd	s4,80(sp)
ffffffffc02013ae:	e4d6                	sd	s5,72(sp)
ffffffffc02013b0:	e0da                	sd	s6,64(sp)
ffffffffc02013b2:	fc5e                	sd	s7,56(sp)
ffffffffc02013b4:	f862                	sd	s8,48(sp)
ffffffffc02013b6:	f06a                	sd	s10,32(sp)
ffffffffc02013b8:	fc86                	sd	ra,120(sp)
ffffffffc02013ba:	f8a2                	sd	s0,112(sp)
ffffffffc02013bc:	ecce                	sd	s3,88(sp)
ffffffffc02013be:	f466                	sd	s9,40(sp)
ffffffffc02013c0:	ec6e                	sd	s11,24(sp)
ffffffffc02013c2:	892a                	mv	s2,a0
ffffffffc02013c4:	84ae                	mv	s1,a1
ffffffffc02013c6:	8d32                	mv	s10,a2
ffffffffc02013c8:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02013ca:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02013cc:	00001a17          	auipc	s4,0x1
ffffffffc02013d0:	ed0a0a13          	addi	s4,s4,-304 # ffffffffc020229c <buddy_pmm_manager+0x4c>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02013d4:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02013d8:	00001c17          	auipc	s8,0x1
ffffffffc02013dc:	020c0c13          	addi	s8,s8,32 # ffffffffc02023f8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02013e0:	000d4503          	lbu	a0,0(s10)
ffffffffc02013e4:	02500793          	li	a5,37
ffffffffc02013e8:	001d0413          	addi	s0,s10,1
ffffffffc02013ec:	00f50e63          	beq	a0,a5,ffffffffc0201408 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc02013f0:	c521                	beqz	a0,ffffffffc0201438 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02013f2:	02500993          	li	s3,37
ffffffffc02013f6:	a011                	j	ffffffffc02013fa <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc02013f8:	c121                	beqz	a0,ffffffffc0201438 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc02013fa:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02013fc:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02013fe:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201400:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201404:	ff351ae3          	bne	a0,s3,ffffffffc02013f8 <vprintfmt+0x52>
ffffffffc0201408:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc020140c:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0201410:	4981                	li	s3,0
ffffffffc0201412:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0201414:	5cfd                	li	s9,-1
ffffffffc0201416:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201418:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc020141c:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020141e:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0201422:	0ff6f693          	andi	a3,a3,255
ffffffffc0201426:	00140d13          	addi	s10,s0,1
ffffffffc020142a:	20d5e563          	bltu	a1,a3,ffffffffc0201634 <vprintfmt+0x28e>
ffffffffc020142e:	068a                	slli	a3,a3,0x2
ffffffffc0201430:	96d2                	add	a3,a3,s4
ffffffffc0201432:	4294                	lw	a3,0(a3)
ffffffffc0201434:	96d2                	add	a3,a3,s4
ffffffffc0201436:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201438:	70e6                	ld	ra,120(sp)
ffffffffc020143a:	7446                	ld	s0,112(sp)
ffffffffc020143c:	74a6                	ld	s1,104(sp)
ffffffffc020143e:	7906                	ld	s2,96(sp)
ffffffffc0201440:	69e6                	ld	s3,88(sp)
ffffffffc0201442:	6a46                	ld	s4,80(sp)
ffffffffc0201444:	6aa6                	ld	s5,72(sp)
ffffffffc0201446:	6b06                	ld	s6,64(sp)
ffffffffc0201448:	7be2                	ld	s7,56(sp)
ffffffffc020144a:	7c42                	ld	s8,48(sp)
ffffffffc020144c:	7ca2                	ld	s9,40(sp)
ffffffffc020144e:	7d02                	ld	s10,32(sp)
ffffffffc0201450:	6de2                	ld	s11,24(sp)
ffffffffc0201452:	6109                	addi	sp,sp,128
ffffffffc0201454:	8082                	ret
    if (lflag >= 2) {
ffffffffc0201456:	4705                	li	a4,1
ffffffffc0201458:	008a8593          	addi	a1,s5,8
ffffffffc020145c:	01074463          	blt	a4,a6,ffffffffc0201464 <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc0201460:	26080363          	beqz	a6,ffffffffc02016c6 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc0201464:	000ab603          	ld	a2,0(s5)
ffffffffc0201468:	46c1                	li	a3,16
ffffffffc020146a:	8aae                	mv	s5,a1
ffffffffc020146c:	a06d                	j	ffffffffc0201516 <vprintfmt+0x170>
            goto reswitch;
ffffffffc020146e:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0201472:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201474:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201476:	b765                	j	ffffffffc020141e <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc0201478:	000aa503          	lw	a0,0(s5)
ffffffffc020147c:	85a6                	mv	a1,s1
ffffffffc020147e:	0aa1                	addi	s5,s5,8
ffffffffc0201480:	9902                	jalr	s2
            break;
ffffffffc0201482:	bfb9                	j	ffffffffc02013e0 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201484:	4705                	li	a4,1
ffffffffc0201486:	008a8993          	addi	s3,s5,8
ffffffffc020148a:	01074463          	blt	a4,a6,ffffffffc0201492 <vprintfmt+0xec>
    else if (lflag) {
ffffffffc020148e:	22080463          	beqz	a6,ffffffffc02016b6 <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc0201492:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc0201496:	24044463          	bltz	s0,ffffffffc02016de <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc020149a:	8622                	mv	a2,s0
ffffffffc020149c:	8ace                	mv	s5,s3
ffffffffc020149e:	46a9                	li	a3,10
ffffffffc02014a0:	a89d                	j	ffffffffc0201516 <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc02014a2:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02014a6:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02014a8:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc02014aa:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02014ae:	8fb5                	xor	a5,a5,a3
ffffffffc02014b0:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02014b4:	1ad74363          	blt	a4,a3,ffffffffc020165a <vprintfmt+0x2b4>
ffffffffc02014b8:	00369793          	slli	a5,a3,0x3
ffffffffc02014bc:	97e2                	add	a5,a5,s8
ffffffffc02014be:	639c                	ld	a5,0(a5)
ffffffffc02014c0:	18078d63          	beqz	a5,ffffffffc020165a <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc02014c4:	86be                	mv	a3,a5
ffffffffc02014c6:	00001617          	auipc	a2,0x1
ffffffffc02014ca:	01a60613          	addi	a2,a2,26 # ffffffffc02024e0 <error_string+0xe8>
ffffffffc02014ce:	85a6                	mv	a1,s1
ffffffffc02014d0:	854a                	mv	a0,s2
ffffffffc02014d2:	240000ef          	jal	ra,ffffffffc0201712 <printfmt>
ffffffffc02014d6:	b729                	j	ffffffffc02013e0 <vprintfmt+0x3a>
            lflag ++;
ffffffffc02014d8:	00144603          	lbu	a2,1(s0)
ffffffffc02014dc:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02014de:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02014e0:	bf3d                	j	ffffffffc020141e <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc02014e2:	4705                	li	a4,1
ffffffffc02014e4:	008a8593          	addi	a1,s5,8
ffffffffc02014e8:	01074463          	blt	a4,a6,ffffffffc02014f0 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc02014ec:	1e080263          	beqz	a6,ffffffffc02016d0 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc02014f0:	000ab603          	ld	a2,0(s5)
ffffffffc02014f4:	46a1                	li	a3,8
ffffffffc02014f6:	8aae                	mv	s5,a1
ffffffffc02014f8:	a839                	j	ffffffffc0201516 <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc02014fa:	03000513          	li	a0,48
ffffffffc02014fe:	85a6                	mv	a1,s1
ffffffffc0201500:	e03e                	sd	a5,0(sp)
ffffffffc0201502:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201504:	85a6                	mv	a1,s1
ffffffffc0201506:	07800513          	li	a0,120
ffffffffc020150a:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020150c:	0aa1                	addi	s5,s5,8
ffffffffc020150e:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0201512:	6782                	ld	a5,0(sp)
ffffffffc0201514:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201516:	876e                	mv	a4,s11
ffffffffc0201518:	85a6                	mv	a1,s1
ffffffffc020151a:	854a                	mv	a0,s2
ffffffffc020151c:	e1fff0ef          	jal	ra,ffffffffc020133a <printnum>
            break;
ffffffffc0201520:	b5c1                	j	ffffffffc02013e0 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201522:	000ab603          	ld	a2,0(s5)
ffffffffc0201526:	0aa1                	addi	s5,s5,8
ffffffffc0201528:	1c060663          	beqz	a2,ffffffffc02016f4 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc020152c:	00160413          	addi	s0,a2,1
ffffffffc0201530:	17b05c63          	blez	s11,ffffffffc02016a8 <vprintfmt+0x302>
ffffffffc0201534:	02d00593          	li	a1,45
ffffffffc0201538:	14b79263          	bne	a5,a1,ffffffffc020167c <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020153c:	00064783          	lbu	a5,0(a2)
ffffffffc0201540:	0007851b          	sext.w	a0,a5
ffffffffc0201544:	c905                	beqz	a0,ffffffffc0201574 <vprintfmt+0x1ce>
ffffffffc0201546:	000cc563          	bltz	s9,ffffffffc0201550 <vprintfmt+0x1aa>
ffffffffc020154a:	3cfd                	addiw	s9,s9,-1
ffffffffc020154c:	036c8263          	beq	s9,s6,ffffffffc0201570 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc0201550:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201552:	18098463          	beqz	s3,ffffffffc02016da <vprintfmt+0x334>
ffffffffc0201556:	3781                	addiw	a5,a5,-32
ffffffffc0201558:	18fbf163          	bleu	a5,s7,ffffffffc02016da <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc020155c:	03f00513          	li	a0,63
ffffffffc0201560:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201562:	0405                	addi	s0,s0,1
ffffffffc0201564:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201568:	3dfd                	addiw	s11,s11,-1
ffffffffc020156a:	0007851b          	sext.w	a0,a5
ffffffffc020156e:	fd61                	bnez	a0,ffffffffc0201546 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc0201570:	e7b058e3          	blez	s11,ffffffffc02013e0 <vprintfmt+0x3a>
ffffffffc0201574:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201576:	85a6                	mv	a1,s1
ffffffffc0201578:	02000513          	li	a0,32
ffffffffc020157c:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020157e:	e60d81e3          	beqz	s11,ffffffffc02013e0 <vprintfmt+0x3a>
ffffffffc0201582:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201584:	85a6                	mv	a1,s1
ffffffffc0201586:	02000513          	li	a0,32
ffffffffc020158a:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020158c:	fe0d94e3          	bnez	s11,ffffffffc0201574 <vprintfmt+0x1ce>
ffffffffc0201590:	bd81                	j	ffffffffc02013e0 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201592:	4705                	li	a4,1
ffffffffc0201594:	008a8593          	addi	a1,s5,8
ffffffffc0201598:	01074463          	blt	a4,a6,ffffffffc02015a0 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc020159c:	12080063          	beqz	a6,ffffffffc02016bc <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc02015a0:	000ab603          	ld	a2,0(s5)
ffffffffc02015a4:	46a9                	li	a3,10
ffffffffc02015a6:	8aae                	mv	s5,a1
ffffffffc02015a8:	b7bd                	j	ffffffffc0201516 <vprintfmt+0x170>
ffffffffc02015aa:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc02015ae:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015b2:	846a                	mv	s0,s10
ffffffffc02015b4:	b5ad                	j	ffffffffc020141e <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc02015b6:	85a6                	mv	a1,s1
ffffffffc02015b8:	02500513          	li	a0,37
ffffffffc02015bc:	9902                	jalr	s2
            break;
ffffffffc02015be:	b50d                	j	ffffffffc02013e0 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc02015c0:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc02015c4:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02015c8:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015ca:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc02015cc:	e40dd9e3          	bgez	s11,ffffffffc020141e <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc02015d0:	8de6                	mv	s11,s9
ffffffffc02015d2:	5cfd                	li	s9,-1
ffffffffc02015d4:	b5a9                	j	ffffffffc020141e <vprintfmt+0x78>
            goto reswitch;
ffffffffc02015d6:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc02015da:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015de:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02015e0:	bd3d                	j	ffffffffc020141e <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc02015e2:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc02015e6:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015ea:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02015ec:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02015f0:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc02015f4:	fcd56ce3          	bltu	a0,a3,ffffffffc02015cc <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc02015f8:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02015fa:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc02015fe:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201602:	0196873b          	addw	a4,a3,s9
ffffffffc0201606:	0017171b          	slliw	a4,a4,0x1
ffffffffc020160a:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc020160e:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0201612:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0201616:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc020161a:	fcd57fe3          	bleu	a3,a0,ffffffffc02015f8 <vprintfmt+0x252>
ffffffffc020161e:	b77d                	j	ffffffffc02015cc <vprintfmt+0x226>
            if (width < 0)
ffffffffc0201620:	fffdc693          	not	a3,s11
ffffffffc0201624:	96fd                	srai	a3,a3,0x3f
ffffffffc0201626:	00ddfdb3          	and	s11,s11,a3
ffffffffc020162a:	00144603          	lbu	a2,1(s0)
ffffffffc020162e:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201630:	846a                	mv	s0,s10
ffffffffc0201632:	b3f5                	j	ffffffffc020141e <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc0201634:	85a6                	mv	a1,s1
ffffffffc0201636:	02500513          	li	a0,37
ffffffffc020163a:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc020163c:	fff44703          	lbu	a4,-1(s0)
ffffffffc0201640:	02500793          	li	a5,37
ffffffffc0201644:	8d22                	mv	s10,s0
ffffffffc0201646:	d8f70de3          	beq	a4,a5,ffffffffc02013e0 <vprintfmt+0x3a>
ffffffffc020164a:	02500713          	li	a4,37
ffffffffc020164e:	1d7d                	addi	s10,s10,-1
ffffffffc0201650:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0201654:	fee79de3          	bne	a5,a4,ffffffffc020164e <vprintfmt+0x2a8>
ffffffffc0201658:	b361                	j	ffffffffc02013e0 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020165a:	00001617          	auipc	a2,0x1
ffffffffc020165e:	e7660613          	addi	a2,a2,-394 # ffffffffc02024d0 <error_string+0xd8>
ffffffffc0201662:	85a6                	mv	a1,s1
ffffffffc0201664:	854a                	mv	a0,s2
ffffffffc0201666:	0ac000ef          	jal	ra,ffffffffc0201712 <printfmt>
ffffffffc020166a:	bb9d                	j	ffffffffc02013e0 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc020166c:	00001617          	auipc	a2,0x1
ffffffffc0201670:	e5c60613          	addi	a2,a2,-420 # ffffffffc02024c8 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc0201674:	00001417          	auipc	s0,0x1
ffffffffc0201678:	e5540413          	addi	s0,s0,-427 # ffffffffc02024c9 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020167c:	8532                	mv	a0,a2
ffffffffc020167e:	85e6                	mv	a1,s9
ffffffffc0201680:	e032                	sd	a2,0(sp)
ffffffffc0201682:	e43e                	sd	a5,8(sp)
ffffffffc0201684:	c37ff0ef          	jal	ra,ffffffffc02012ba <strnlen>
ffffffffc0201688:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020168c:	6602                	ld	a2,0(sp)
ffffffffc020168e:	01b05d63          	blez	s11,ffffffffc02016a8 <vprintfmt+0x302>
ffffffffc0201692:	67a2                	ld	a5,8(sp)
ffffffffc0201694:	2781                	sext.w	a5,a5
ffffffffc0201696:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc0201698:	6522                	ld	a0,8(sp)
ffffffffc020169a:	85a6                	mv	a1,s1
ffffffffc020169c:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020169e:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02016a0:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02016a2:	6602                	ld	a2,0(sp)
ffffffffc02016a4:	fe0d9ae3          	bnez	s11,ffffffffc0201698 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02016a8:	00064783          	lbu	a5,0(a2)
ffffffffc02016ac:	0007851b          	sext.w	a0,a5
ffffffffc02016b0:	e8051be3          	bnez	a0,ffffffffc0201546 <vprintfmt+0x1a0>
ffffffffc02016b4:	b335                	j	ffffffffc02013e0 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc02016b6:	000aa403          	lw	s0,0(s5)
ffffffffc02016ba:	bbf1                	j	ffffffffc0201496 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc02016bc:	000ae603          	lwu	a2,0(s5)
ffffffffc02016c0:	46a9                	li	a3,10
ffffffffc02016c2:	8aae                	mv	s5,a1
ffffffffc02016c4:	bd89                	j	ffffffffc0201516 <vprintfmt+0x170>
ffffffffc02016c6:	000ae603          	lwu	a2,0(s5)
ffffffffc02016ca:	46c1                	li	a3,16
ffffffffc02016cc:	8aae                	mv	s5,a1
ffffffffc02016ce:	b5a1                	j	ffffffffc0201516 <vprintfmt+0x170>
ffffffffc02016d0:	000ae603          	lwu	a2,0(s5)
ffffffffc02016d4:	46a1                	li	a3,8
ffffffffc02016d6:	8aae                	mv	s5,a1
ffffffffc02016d8:	bd3d                	j	ffffffffc0201516 <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc02016da:	9902                	jalr	s2
ffffffffc02016dc:	b559                	j	ffffffffc0201562 <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc02016de:	85a6                	mv	a1,s1
ffffffffc02016e0:	02d00513          	li	a0,45
ffffffffc02016e4:	e03e                	sd	a5,0(sp)
ffffffffc02016e6:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02016e8:	8ace                	mv	s5,s3
ffffffffc02016ea:	40800633          	neg	a2,s0
ffffffffc02016ee:	46a9                	li	a3,10
ffffffffc02016f0:	6782                	ld	a5,0(sp)
ffffffffc02016f2:	b515                	j	ffffffffc0201516 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc02016f4:	01b05663          	blez	s11,ffffffffc0201700 <vprintfmt+0x35a>
ffffffffc02016f8:	02d00693          	li	a3,45
ffffffffc02016fc:	f6d798e3          	bne	a5,a3,ffffffffc020166c <vprintfmt+0x2c6>
ffffffffc0201700:	00001417          	auipc	s0,0x1
ffffffffc0201704:	dc940413          	addi	s0,s0,-567 # ffffffffc02024c9 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201708:	02800513          	li	a0,40
ffffffffc020170c:	02800793          	li	a5,40
ffffffffc0201710:	bd1d                	j	ffffffffc0201546 <vprintfmt+0x1a0>

ffffffffc0201712 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201712:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201714:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201718:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020171a:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020171c:	ec06                	sd	ra,24(sp)
ffffffffc020171e:	f83a                	sd	a4,48(sp)
ffffffffc0201720:	fc3e                	sd	a5,56(sp)
ffffffffc0201722:	e0c2                	sd	a6,64(sp)
ffffffffc0201724:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201726:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201728:	c7fff0ef          	jal	ra,ffffffffc02013a6 <vprintfmt>
}
ffffffffc020172c:	60e2                	ld	ra,24(sp)
ffffffffc020172e:	6161                	addi	sp,sp,80
ffffffffc0201730:	8082                	ret

ffffffffc0201732 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201732:	715d                	addi	sp,sp,-80
ffffffffc0201734:	e486                	sd	ra,72(sp)
ffffffffc0201736:	e0a2                	sd	s0,64(sp)
ffffffffc0201738:	fc26                	sd	s1,56(sp)
ffffffffc020173a:	f84a                	sd	s2,48(sp)
ffffffffc020173c:	f44e                	sd	s3,40(sp)
ffffffffc020173e:	f052                	sd	s4,32(sp)
ffffffffc0201740:	ec56                	sd	s5,24(sp)
ffffffffc0201742:	e85a                	sd	s6,16(sp)
ffffffffc0201744:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc0201746:	c901                	beqz	a0,ffffffffc0201756 <readline+0x24>
        cprintf("%s", prompt);
ffffffffc0201748:	85aa                	mv	a1,a0
ffffffffc020174a:	00001517          	auipc	a0,0x1
ffffffffc020174e:	d9650513          	addi	a0,a0,-618 # ffffffffc02024e0 <error_string+0xe8>
ffffffffc0201752:	965fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
readline(const char *prompt) {
ffffffffc0201756:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201758:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc020175a:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc020175c:	4aa9                	li	s5,10
ffffffffc020175e:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201760:	00005b97          	auipc	s7,0x5
ffffffffc0201764:	8b0b8b93          	addi	s7,s7,-1872 # ffffffffc0206010 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201768:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc020176c:	9c3fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc0201770:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201772:	00054b63          	bltz	a0,ffffffffc0201788 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201776:	00a95b63          	ble	a0,s2,ffffffffc020178c <readline+0x5a>
ffffffffc020177a:	029a5463          	ble	s1,s4,ffffffffc02017a2 <readline+0x70>
        c = getchar();
ffffffffc020177e:	9b1fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc0201782:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201784:	fe0559e3          	bgez	a0,ffffffffc0201776 <readline+0x44>
            return NULL;
ffffffffc0201788:	4501                	li	a0,0
ffffffffc020178a:	a099                	j	ffffffffc02017d0 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc020178c:	03341463          	bne	s0,s3,ffffffffc02017b4 <readline+0x82>
ffffffffc0201790:	e8b9                	bnez	s1,ffffffffc02017e6 <readline+0xb4>
        c = getchar();
ffffffffc0201792:	99dfe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc0201796:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201798:	fe0548e3          	bltz	a0,ffffffffc0201788 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020179c:	fea958e3          	ble	a0,s2,ffffffffc020178c <readline+0x5a>
ffffffffc02017a0:	4481                	li	s1,0
            cputchar(c);
ffffffffc02017a2:	8522                	mv	a0,s0
ffffffffc02017a4:	947fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i ++] = c;
ffffffffc02017a8:	009b87b3          	add	a5,s7,s1
ffffffffc02017ac:	00878023          	sb	s0,0(a5)
ffffffffc02017b0:	2485                	addiw	s1,s1,1
ffffffffc02017b2:	bf6d                	j	ffffffffc020176c <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc02017b4:	01540463          	beq	s0,s5,ffffffffc02017bc <readline+0x8a>
ffffffffc02017b8:	fb641ae3          	bne	s0,s6,ffffffffc020176c <readline+0x3a>
            cputchar(c);
ffffffffc02017bc:	8522                	mv	a0,s0
ffffffffc02017be:	92dfe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i] = '\0';
ffffffffc02017c2:	00005517          	auipc	a0,0x5
ffffffffc02017c6:	84e50513          	addi	a0,a0,-1970 # ffffffffc0206010 <edata>
ffffffffc02017ca:	94aa                	add	s1,s1,a0
ffffffffc02017cc:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02017d0:	60a6                	ld	ra,72(sp)
ffffffffc02017d2:	6406                	ld	s0,64(sp)
ffffffffc02017d4:	74e2                	ld	s1,56(sp)
ffffffffc02017d6:	7942                	ld	s2,48(sp)
ffffffffc02017d8:	79a2                	ld	s3,40(sp)
ffffffffc02017da:	7a02                	ld	s4,32(sp)
ffffffffc02017dc:	6ae2                	ld	s5,24(sp)
ffffffffc02017de:	6b42                	ld	s6,16(sp)
ffffffffc02017e0:	6ba2                	ld	s7,8(sp)
ffffffffc02017e2:	6161                	addi	sp,sp,80
ffffffffc02017e4:	8082                	ret
            cputchar(c);
ffffffffc02017e6:	4521                	li	a0,8
ffffffffc02017e8:	903fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            i --;
ffffffffc02017ec:	34fd                	addiw	s1,s1,-1
ffffffffc02017ee:	bfbd                	j	ffffffffc020176c <readline+0x3a>

ffffffffc02017f0 <sbi_console_putchar>:
    );
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
ffffffffc02017f0:	00005797          	auipc	a5,0x5
ffffffffc02017f4:	81878793          	addi	a5,a5,-2024 # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
    __asm__ volatile (
ffffffffc02017f8:	6398                	ld	a4,0(a5)
ffffffffc02017fa:	4781                	li	a5,0
ffffffffc02017fc:	88ba                	mv	a7,a4
ffffffffc02017fe:	852a                	mv	a0,a0
ffffffffc0201800:	85be                	mv	a1,a5
ffffffffc0201802:	863e                	mv	a2,a5
ffffffffc0201804:	00000073          	ecall
ffffffffc0201808:	87aa                	mv	a5,a0
}
ffffffffc020180a:	8082                	ret

ffffffffc020180c <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
ffffffffc020180c:	00005797          	auipc	a5,0x5
ffffffffc0201810:	c1c78793          	addi	a5,a5,-996 # ffffffffc0206428 <SBI_SET_TIMER>
    __asm__ volatile (
ffffffffc0201814:	6398                	ld	a4,0(a5)
ffffffffc0201816:	4781                	li	a5,0
ffffffffc0201818:	88ba                	mv	a7,a4
ffffffffc020181a:	852a                	mv	a0,a0
ffffffffc020181c:	85be                	mv	a1,a5
ffffffffc020181e:	863e                	mv	a2,a5
ffffffffc0201820:	00000073          	ecall
ffffffffc0201824:	87aa                	mv	a5,a0
}
ffffffffc0201826:	8082                	ret

ffffffffc0201828 <sbi_console_getchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201828:	00004797          	auipc	a5,0x4
ffffffffc020182c:	7d878793          	addi	a5,a5,2008 # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
    __asm__ volatile (
ffffffffc0201830:	639c                	ld	a5,0(a5)
ffffffffc0201832:	4501                	li	a0,0
ffffffffc0201834:	88be                	mv	a7,a5
ffffffffc0201836:	852a                	mv	a0,a0
ffffffffc0201838:	85aa                	mv	a1,a0
ffffffffc020183a:	862a                	mv	a2,a0
ffffffffc020183c:	00000073          	ecall
ffffffffc0201840:	852a                	mv	a0,a0
ffffffffc0201842:	2501                	sext.w	a0,a0
ffffffffc0201844:	8082                	ret
