
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c020a2b7          	lui	t0,0xc020a
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
ffffffffc0200028:	c020a137          	lui	sp,0xc020a

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

int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	0000b517          	auipc	a0,0xb
ffffffffc020003a:	02a50513          	addi	a0,a0,42 # ffffffffc020b060 <edata>
ffffffffc020003e:	00016617          	auipc	a2,0x16
ffffffffc0200042:	5c260613          	addi	a2,a2,1474 # ffffffffc0216600 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	273040ef          	jal	ra,ffffffffc0204ac0 <memset>

    cons_init();                // init the console
ffffffffc0200052:	4e8000ef          	jal	ra,ffffffffc020053a <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200056:	00005597          	auipc	a1,0x5
ffffffffc020005a:	eda58593          	addi	a1,a1,-294 # ffffffffc0204f30 <etext+0x6>
ffffffffc020005e:	00005517          	auipc	a0,0x5
ffffffffc0200062:	ef250513          	addi	a0,a0,-270 # ffffffffc0204f50 <etext+0x26>
ffffffffc0200066:	06a000ef          	jal	ra,ffffffffc02000d0 <cprintf>

    print_kerninfo();
ffffffffc020006a:	1cc000ef          	jal	ra,ffffffffc0200236 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006e:	40a030ef          	jal	ra,ffffffffc0203478 <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc0200072:	53c000ef          	jal	ra,ffffffffc02005ae <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200076:	5b8000ef          	jal	ra,ffffffffc020062e <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020007a:	4d9000ef          	jal	ra,ffffffffc0200d52 <vmm_init>
    proc_init();                // init process table
ffffffffc020007e:	5f6040ef          	jal	ra,ffffffffc0204674 <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc0200082:	42e000ef          	jal	ra,ffffffffc02004b0 <ide_init>
    swap_init();                // init swap
ffffffffc0200086:	2f6010ef          	jal	ra,ffffffffc020137c <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020008a:	45a000ef          	jal	ra,ffffffffc02004e4 <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008e:	522000ef          	jal	ra,ffffffffc02005b0 <intr_enable>

    cpu_idle();                 // run idle process
ffffffffc0200092:	5ba040ef          	jal	ra,ffffffffc020464c <cpu_idle>

ffffffffc0200096 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200096:	1141                	addi	sp,sp,-16
ffffffffc0200098:	e022                	sd	s0,0(sp)
ffffffffc020009a:	e406                	sd	ra,8(sp)
ffffffffc020009c:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020009e:	49e000ef          	jal	ra,ffffffffc020053c <cons_putc>
    (*cnt) ++;
ffffffffc02000a2:	401c                	lw	a5,0(s0)
}
ffffffffc02000a4:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc02000a6:	2785                	addiw	a5,a5,1
ffffffffc02000a8:	c01c                	sw	a5,0(s0)
}
ffffffffc02000aa:	6402                	ld	s0,0(sp)
ffffffffc02000ac:	0141                	addi	sp,sp,16
ffffffffc02000ae:	8082                	ret

ffffffffc02000b0 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000b0:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000b2:	86ae                	mv	a3,a1
ffffffffc02000b4:	862a                	mv	a2,a0
ffffffffc02000b6:	006c                	addi	a1,sp,12
ffffffffc02000b8:	00000517          	auipc	a0,0x0
ffffffffc02000bc:	fde50513          	addi	a0,a0,-34 # ffffffffc0200096 <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000c0:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000c2:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c4:	2c3040ef          	jal	ra,ffffffffc0204b86 <vprintfmt>
    return cnt;
}
ffffffffc02000c8:	60e2                	ld	ra,24(sp)
ffffffffc02000ca:	4532                	lw	a0,12(sp)
ffffffffc02000cc:	6105                	addi	sp,sp,32
ffffffffc02000ce:	8082                	ret

ffffffffc02000d0 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000d0:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000d2:	02810313          	addi	t1,sp,40 # ffffffffc020a028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000d6:	f42e                	sd	a1,40(sp)
ffffffffc02000d8:	f832                	sd	a2,48(sp)
ffffffffc02000da:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000dc:	862a                	mv	a2,a0
ffffffffc02000de:	004c                	addi	a1,sp,4
ffffffffc02000e0:	00000517          	auipc	a0,0x0
ffffffffc02000e4:	fb650513          	addi	a0,a0,-74 # ffffffffc0200096 <cputch>
ffffffffc02000e8:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000ea:	ec06                	sd	ra,24(sp)
ffffffffc02000ec:	e0ba                	sd	a4,64(sp)
ffffffffc02000ee:	e4be                	sd	a5,72(sp)
ffffffffc02000f0:	e8c2                	sd	a6,80(sp)
ffffffffc02000f2:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000f4:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000f6:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000f8:	28f040ef          	jal	ra,ffffffffc0204b86 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000fc:	60e2                	ld	ra,24(sp)
ffffffffc02000fe:	4512                	lw	a0,4(sp)
ffffffffc0200100:	6125                	addi	sp,sp,96
ffffffffc0200102:	8082                	ret

ffffffffc0200104 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc0200104:	4380006f          	j	ffffffffc020053c <cons_putc>

ffffffffc0200108 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc0200108:	1141                	addi	sp,sp,-16
ffffffffc020010a:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020010c:	466000ef          	jal	ra,ffffffffc0200572 <cons_getc>
ffffffffc0200110:	dd75                	beqz	a0,ffffffffc020010c <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200112:	60a2                	ld	ra,8(sp)
ffffffffc0200114:	0141                	addi	sp,sp,16
ffffffffc0200116:	8082                	ret

ffffffffc0200118 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0200118:	715d                	addi	sp,sp,-80
ffffffffc020011a:	e486                	sd	ra,72(sp)
ffffffffc020011c:	e0a2                	sd	s0,64(sp)
ffffffffc020011e:	fc26                	sd	s1,56(sp)
ffffffffc0200120:	f84a                	sd	s2,48(sp)
ffffffffc0200122:	f44e                	sd	s3,40(sp)
ffffffffc0200124:	f052                	sd	s4,32(sp)
ffffffffc0200126:	ec56                	sd	s5,24(sp)
ffffffffc0200128:	e85a                	sd	s6,16(sp)
ffffffffc020012a:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc020012c:	c901                	beqz	a0,ffffffffc020013c <readline+0x24>
        cprintf("%s", prompt);
ffffffffc020012e:	85aa                	mv	a1,a0
ffffffffc0200130:	00005517          	auipc	a0,0x5
ffffffffc0200134:	e2850513          	addi	a0,a0,-472 # ffffffffc0204f58 <etext+0x2e>
ffffffffc0200138:	f99ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
readline(const char *prompt) {
ffffffffc020013c:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020013e:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0200140:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0200142:	4aa9                	li	s5,10
ffffffffc0200144:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0200146:	0000bb97          	auipc	s7,0xb
ffffffffc020014a:	f1ab8b93          	addi	s7,s7,-230 # ffffffffc020b060 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020014e:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0200152:	fb7ff0ef          	jal	ra,ffffffffc0200108 <getchar>
ffffffffc0200156:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0200158:	00054b63          	bltz	a0,ffffffffc020016e <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020015c:	00a95b63          	ble	a0,s2,ffffffffc0200172 <readline+0x5a>
ffffffffc0200160:	029a5463          	ble	s1,s4,ffffffffc0200188 <readline+0x70>
        c = getchar();
ffffffffc0200164:	fa5ff0ef          	jal	ra,ffffffffc0200108 <getchar>
ffffffffc0200168:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc020016a:	fe0559e3          	bgez	a0,ffffffffc020015c <readline+0x44>
            return NULL;
ffffffffc020016e:	4501                	li	a0,0
ffffffffc0200170:	a099                	j	ffffffffc02001b6 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc0200172:	03341463          	bne	s0,s3,ffffffffc020019a <readline+0x82>
ffffffffc0200176:	e8b9                	bnez	s1,ffffffffc02001cc <readline+0xb4>
        c = getchar();
ffffffffc0200178:	f91ff0ef          	jal	ra,ffffffffc0200108 <getchar>
ffffffffc020017c:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc020017e:	fe0548e3          	bltz	a0,ffffffffc020016e <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200182:	fea958e3          	ble	a0,s2,ffffffffc0200172 <readline+0x5a>
ffffffffc0200186:	4481                	li	s1,0
            cputchar(c);
ffffffffc0200188:	8522                	mv	a0,s0
ffffffffc020018a:	f7bff0ef          	jal	ra,ffffffffc0200104 <cputchar>
            buf[i ++] = c;
ffffffffc020018e:	009b87b3          	add	a5,s7,s1
ffffffffc0200192:	00878023          	sb	s0,0(a5)
ffffffffc0200196:	2485                	addiw	s1,s1,1
ffffffffc0200198:	bf6d                	j	ffffffffc0200152 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc020019a:	01540463          	beq	s0,s5,ffffffffc02001a2 <readline+0x8a>
ffffffffc020019e:	fb641ae3          	bne	s0,s6,ffffffffc0200152 <readline+0x3a>
            cputchar(c);
ffffffffc02001a2:	8522                	mv	a0,s0
ffffffffc02001a4:	f61ff0ef          	jal	ra,ffffffffc0200104 <cputchar>
            buf[i] = '\0';
ffffffffc02001a8:	0000b517          	auipc	a0,0xb
ffffffffc02001ac:	eb850513          	addi	a0,a0,-328 # ffffffffc020b060 <edata>
ffffffffc02001b0:	94aa                	add	s1,s1,a0
ffffffffc02001b2:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02001b6:	60a6                	ld	ra,72(sp)
ffffffffc02001b8:	6406                	ld	s0,64(sp)
ffffffffc02001ba:	74e2                	ld	s1,56(sp)
ffffffffc02001bc:	7942                	ld	s2,48(sp)
ffffffffc02001be:	79a2                	ld	s3,40(sp)
ffffffffc02001c0:	7a02                	ld	s4,32(sp)
ffffffffc02001c2:	6ae2                	ld	s5,24(sp)
ffffffffc02001c4:	6b42                	ld	s6,16(sp)
ffffffffc02001c6:	6ba2                	ld	s7,8(sp)
ffffffffc02001c8:	6161                	addi	sp,sp,80
ffffffffc02001ca:	8082                	ret
            cputchar(c);
ffffffffc02001cc:	4521                	li	a0,8
ffffffffc02001ce:	f37ff0ef          	jal	ra,ffffffffc0200104 <cputchar>
            i --;
ffffffffc02001d2:	34fd                	addiw	s1,s1,-1
ffffffffc02001d4:	bfbd                	j	ffffffffc0200152 <readline+0x3a>

ffffffffc02001d6 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02001d6:	00016317          	auipc	t1,0x16
ffffffffc02001da:	29a30313          	addi	t1,t1,666 # ffffffffc0216470 <is_panic>
ffffffffc02001de:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02001e2:	715d                	addi	sp,sp,-80
ffffffffc02001e4:	ec06                	sd	ra,24(sp)
ffffffffc02001e6:	e822                	sd	s0,16(sp)
ffffffffc02001e8:	f436                	sd	a3,40(sp)
ffffffffc02001ea:	f83a                	sd	a4,48(sp)
ffffffffc02001ec:	fc3e                	sd	a5,56(sp)
ffffffffc02001ee:	e0c2                	sd	a6,64(sp)
ffffffffc02001f0:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02001f2:	02031c63          	bnez	t1,ffffffffc020022a <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02001f6:	4785                	li	a5,1
ffffffffc02001f8:	8432                	mv	s0,a2
ffffffffc02001fa:	00016717          	auipc	a4,0x16
ffffffffc02001fe:	26f72b23          	sw	a5,630(a4) # ffffffffc0216470 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200202:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc0200204:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200206:	85aa                	mv	a1,a0
ffffffffc0200208:	00005517          	auipc	a0,0x5
ffffffffc020020c:	d5850513          	addi	a0,a0,-680 # ffffffffc0204f60 <etext+0x36>
    va_start(ap, fmt);
ffffffffc0200210:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200212:	ebfff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200216:	65a2                	ld	a1,8(sp)
ffffffffc0200218:	8522                	mv	a0,s0
ffffffffc020021a:	e97ff0ef          	jal	ra,ffffffffc02000b0 <vcprintf>
    cprintf("\n");
ffffffffc020021e:	00007517          	auipc	a0,0x7
ffffffffc0200222:	cba50513          	addi	a0,a0,-838 # ffffffffc0206ed8 <default_pmm_manager+0x8c0>
ffffffffc0200226:	eabff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc020022a:	38c000ef          	jal	ra,ffffffffc02005b6 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc020022e:	4501                	li	a0,0
ffffffffc0200230:	132000ef          	jal	ra,ffffffffc0200362 <kmonitor>
ffffffffc0200234:	bfed                	j	ffffffffc020022e <__panic+0x58>

ffffffffc0200236 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200236:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200238:	00005517          	auipc	a0,0x5
ffffffffc020023c:	d7850513          	addi	a0,a0,-648 # ffffffffc0204fb0 <etext+0x86>
void print_kerninfo(void) {
ffffffffc0200240:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200242:	e8fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200246:	00000597          	auipc	a1,0x0
ffffffffc020024a:	df058593          	addi	a1,a1,-528 # ffffffffc0200036 <kern_init>
ffffffffc020024e:	00005517          	auipc	a0,0x5
ffffffffc0200252:	d8250513          	addi	a0,a0,-638 # ffffffffc0204fd0 <etext+0xa6>
ffffffffc0200256:	e7bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc020025a:	00005597          	auipc	a1,0x5
ffffffffc020025e:	cd058593          	addi	a1,a1,-816 # ffffffffc0204f2a <etext>
ffffffffc0200262:	00005517          	auipc	a0,0x5
ffffffffc0200266:	d8e50513          	addi	a0,a0,-626 # ffffffffc0204ff0 <etext+0xc6>
ffffffffc020026a:	e67ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020026e:	0000b597          	auipc	a1,0xb
ffffffffc0200272:	df258593          	addi	a1,a1,-526 # ffffffffc020b060 <edata>
ffffffffc0200276:	00005517          	auipc	a0,0x5
ffffffffc020027a:	d9a50513          	addi	a0,a0,-614 # ffffffffc0205010 <etext+0xe6>
ffffffffc020027e:	e53ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200282:	00016597          	auipc	a1,0x16
ffffffffc0200286:	37e58593          	addi	a1,a1,894 # ffffffffc0216600 <end>
ffffffffc020028a:	00005517          	auipc	a0,0x5
ffffffffc020028e:	da650513          	addi	a0,a0,-602 # ffffffffc0205030 <etext+0x106>
ffffffffc0200292:	e3fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200296:	00016597          	auipc	a1,0x16
ffffffffc020029a:	76958593          	addi	a1,a1,1897 # ffffffffc02169ff <end+0x3ff>
ffffffffc020029e:	00000797          	auipc	a5,0x0
ffffffffc02002a2:	d9878793          	addi	a5,a5,-616 # ffffffffc0200036 <kern_init>
ffffffffc02002a6:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02002aa:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02002ae:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02002b0:	3ff5f593          	andi	a1,a1,1023
ffffffffc02002b4:	95be                	add	a1,a1,a5
ffffffffc02002b6:	85a9                	srai	a1,a1,0xa
ffffffffc02002b8:	00005517          	auipc	a0,0x5
ffffffffc02002bc:	d9850513          	addi	a0,a0,-616 # ffffffffc0205050 <etext+0x126>
}
ffffffffc02002c0:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02002c2:	e0fff06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc02002c6 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02002c6:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc02002c8:	00005617          	auipc	a2,0x5
ffffffffc02002cc:	cb860613          	addi	a2,a2,-840 # ffffffffc0204f80 <etext+0x56>
ffffffffc02002d0:	04d00593          	li	a1,77
ffffffffc02002d4:	00005517          	auipc	a0,0x5
ffffffffc02002d8:	cc450513          	addi	a0,a0,-828 # ffffffffc0204f98 <etext+0x6e>
void print_stackframe(void) {
ffffffffc02002dc:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02002de:	ef9ff0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc02002e2 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002e2:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002e4:	00005617          	auipc	a2,0x5
ffffffffc02002e8:	e7c60613          	addi	a2,a2,-388 # ffffffffc0205160 <commands+0xe0>
ffffffffc02002ec:	00005597          	auipc	a1,0x5
ffffffffc02002f0:	e9458593          	addi	a1,a1,-364 # ffffffffc0205180 <commands+0x100>
ffffffffc02002f4:	00005517          	auipc	a0,0x5
ffffffffc02002f8:	e9450513          	addi	a0,a0,-364 # ffffffffc0205188 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002fc:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002fe:	dd3ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc0200302:	00005617          	auipc	a2,0x5
ffffffffc0200306:	e9660613          	addi	a2,a2,-362 # ffffffffc0205198 <commands+0x118>
ffffffffc020030a:	00005597          	auipc	a1,0x5
ffffffffc020030e:	eb658593          	addi	a1,a1,-330 # ffffffffc02051c0 <commands+0x140>
ffffffffc0200312:	00005517          	auipc	a0,0x5
ffffffffc0200316:	e7650513          	addi	a0,a0,-394 # ffffffffc0205188 <commands+0x108>
ffffffffc020031a:	db7ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc020031e:	00005617          	auipc	a2,0x5
ffffffffc0200322:	eb260613          	addi	a2,a2,-334 # ffffffffc02051d0 <commands+0x150>
ffffffffc0200326:	00005597          	auipc	a1,0x5
ffffffffc020032a:	eca58593          	addi	a1,a1,-310 # ffffffffc02051f0 <commands+0x170>
ffffffffc020032e:	00005517          	auipc	a0,0x5
ffffffffc0200332:	e5a50513          	addi	a0,a0,-422 # ffffffffc0205188 <commands+0x108>
ffffffffc0200336:	d9bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    }
    return 0;
}
ffffffffc020033a:	60a2                	ld	ra,8(sp)
ffffffffc020033c:	4501                	li	a0,0
ffffffffc020033e:	0141                	addi	sp,sp,16
ffffffffc0200340:	8082                	ret

ffffffffc0200342 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200342:	1141                	addi	sp,sp,-16
ffffffffc0200344:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200346:	ef1ff0ef          	jal	ra,ffffffffc0200236 <print_kerninfo>
    return 0;
}
ffffffffc020034a:	60a2                	ld	ra,8(sp)
ffffffffc020034c:	4501                	li	a0,0
ffffffffc020034e:	0141                	addi	sp,sp,16
ffffffffc0200350:	8082                	ret

ffffffffc0200352 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200352:	1141                	addi	sp,sp,-16
ffffffffc0200354:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200356:	f71ff0ef          	jal	ra,ffffffffc02002c6 <print_stackframe>
    return 0;
}
ffffffffc020035a:	60a2                	ld	ra,8(sp)
ffffffffc020035c:	4501                	li	a0,0
ffffffffc020035e:	0141                	addi	sp,sp,16
ffffffffc0200360:	8082                	ret

ffffffffc0200362 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200362:	7115                	addi	sp,sp,-224
ffffffffc0200364:	e962                	sd	s8,144(sp)
ffffffffc0200366:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200368:	00005517          	auipc	a0,0x5
ffffffffc020036c:	d6050513          	addi	a0,a0,-672 # ffffffffc02050c8 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc0200370:	ed86                	sd	ra,216(sp)
ffffffffc0200372:	e9a2                	sd	s0,208(sp)
ffffffffc0200374:	e5a6                	sd	s1,200(sp)
ffffffffc0200376:	e1ca                	sd	s2,192(sp)
ffffffffc0200378:	fd4e                	sd	s3,184(sp)
ffffffffc020037a:	f952                	sd	s4,176(sp)
ffffffffc020037c:	f556                	sd	s5,168(sp)
ffffffffc020037e:	f15a                	sd	s6,160(sp)
ffffffffc0200380:	ed5e                	sd	s7,152(sp)
ffffffffc0200382:	e566                	sd	s9,136(sp)
ffffffffc0200384:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200386:	d4bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020038a:	00005517          	auipc	a0,0x5
ffffffffc020038e:	d6650513          	addi	a0,a0,-666 # ffffffffc02050f0 <commands+0x70>
ffffffffc0200392:	d3fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    if (tf != NULL) {
ffffffffc0200396:	000c0563          	beqz	s8,ffffffffc02003a0 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020039a:	8562                	mv	a0,s8
ffffffffc020039c:	47a000ef          	jal	ra,ffffffffc0200816 <print_trapframe>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc02003a0:	4501                	li	a0,0
ffffffffc02003a2:	4581                	li	a1,0
ffffffffc02003a4:	4601                	li	a2,0
ffffffffc02003a6:	48a1                	li	a7,8
ffffffffc02003a8:	00000073          	ecall
ffffffffc02003ac:	00005c97          	auipc	s9,0x5
ffffffffc02003b0:	cd4c8c93          	addi	s9,s9,-812 # ffffffffc0205080 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02003b4:	00005997          	auipc	s3,0x5
ffffffffc02003b8:	d6498993          	addi	s3,s3,-668 # ffffffffc0205118 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003bc:	00005917          	auipc	s2,0x5
ffffffffc02003c0:	d6490913          	addi	s2,s2,-668 # ffffffffc0205120 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc02003c4:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02003c6:	00005b17          	auipc	s6,0x5
ffffffffc02003ca:	d62b0b13          	addi	s6,s6,-670 # ffffffffc0205128 <commands+0xa8>
    if (argc == 0) {
ffffffffc02003ce:	00005a97          	auipc	s5,0x5
ffffffffc02003d2:	db2a8a93          	addi	s5,s5,-590 # ffffffffc0205180 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003d6:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02003d8:	854e                	mv	a0,s3
ffffffffc02003da:	d3fff0ef          	jal	ra,ffffffffc0200118 <readline>
ffffffffc02003de:	842a                	mv	s0,a0
ffffffffc02003e0:	dd65                	beqz	a0,ffffffffc02003d8 <kmonitor+0x76>
ffffffffc02003e2:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02003e6:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003e8:	c999                	beqz	a1,ffffffffc02003fe <kmonitor+0x9c>
ffffffffc02003ea:	854a                	mv	a0,s2
ffffffffc02003ec:	6b6040ef          	jal	ra,ffffffffc0204aa2 <strchr>
ffffffffc02003f0:	c925                	beqz	a0,ffffffffc0200460 <kmonitor+0xfe>
            *buf ++ = '\0';
ffffffffc02003f2:	00144583          	lbu	a1,1(s0)
ffffffffc02003f6:	00040023          	sb	zero,0(s0)
ffffffffc02003fa:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003fc:	f5fd                	bnez	a1,ffffffffc02003ea <kmonitor+0x88>
    if (argc == 0) {
ffffffffc02003fe:	dce9                	beqz	s1,ffffffffc02003d8 <kmonitor+0x76>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200400:	6582                	ld	a1,0(sp)
ffffffffc0200402:	00005d17          	auipc	s10,0x5
ffffffffc0200406:	c7ed0d13          	addi	s10,s10,-898 # ffffffffc0205080 <commands>
    if (argc == 0) {
ffffffffc020040a:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020040c:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020040e:	0d61                	addi	s10,s10,24
ffffffffc0200410:	668040ef          	jal	ra,ffffffffc0204a78 <strcmp>
ffffffffc0200414:	c919                	beqz	a0,ffffffffc020042a <kmonitor+0xc8>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200416:	2405                	addiw	s0,s0,1
ffffffffc0200418:	09740463          	beq	s0,s7,ffffffffc02004a0 <kmonitor+0x13e>
ffffffffc020041c:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200420:	6582                	ld	a1,0(sp)
ffffffffc0200422:	0d61                	addi	s10,s10,24
ffffffffc0200424:	654040ef          	jal	ra,ffffffffc0204a78 <strcmp>
ffffffffc0200428:	f57d                	bnez	a0,ffffffffc0200416 <kmonitor+0xb4>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc020042a:	00141793          	slli	a5,s0,0x1
ffffffffc020042e:	97a2                	add	a5,a5,s0
ffffffffc0200430:	078e                	slli	a5,a5,0x3
ffffffffc0200432:	97e6                	add	a5,a5,s9
ffffffffc0200434:	6b9c                	ld	a5,16(a5)
ffffffffc0200436:	8662                	mv	a2,s8
ffffffffc0200438:	002c                	addi	a1,sp,8
ffffffffc020043a:	fff4851b          	addiw	a0,s1,-1
ffffffffc020043e:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200440:	f8055ce3          	bgez	a0,ffffffffc02003d8 <kmonitor+0x76>
}
ffffffffc0200444:	60ee                	ld	ra,216(sp)
ffffffffc0200446:	644e                	ld	s0,208(sp)
ffffffffc0200448:	64ae                	ld	s1,200(sp)
ffffffffc020044a:	690e                	ld	s2,192(sp)
ffffffffc020044c:	79ea                	ld	s3,184(sp)
ffffffffc020044e:	7a4a                	ld	s4,176(sp)
ffffffffc0200450:	7aaa                	ld	s5,168(sp)
ffffffffc0200452:	7b0a                	ld	s6,160(sp)
ffffffffc0200454:	6bea                	ld	s7,152(sp)
ffffffffc0200456:	6c4a                	ld	s8,144(sp)
ffffffffc0200458:	6caa                	ld	s9,136(sp)
ffffffffc020045a:	6d0a                	ld	s10,128(sp)
ffffffffc020045c:	612d                	addi	sp,sp,224
ffffffffc020045e:	8082                	ret
        if (*buf == '\0') {
ffffffffc0200460:	00044783          	lbu	a5,0(s0)
ffffffffc0200464:	dfc9                	beqz	a5,ffffffffc02003fe <kmonitor+0x9c>
        if (argc == MAXARGS - 1) {
ffffffffc0200466:	03448863          	beq	s1,s4,ffffffffc0200496 <kmonitor+0x134>
        argv[argc ++] = buf;
ffffffffc020046a:	00349793          	slli	a5,s1,0x3
ffffffffc020046e:	0118                	addi	a4,sp,128
ffffffffc0200470:	97ba                	add	a5,a5,a4
ffffffffc0200472:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200476:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc020047a:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020047c:	e591                	bnez	a1,ffffffffc0200488 <kmonitor+0x126>
ffffffffc020047e:	b749                	j	ffffffffc0200400 <kmonitor+0x9e>
            buf ++;
ffffffffc0200480:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200482:	00044583          	lbu	a1,0(s0)
ffffffffc0200486:	ddad                	beqz	a1,ffffffffc0200400 <kmonitor+0x9e>
ffffffffc0200488:	854a                	mv	a0,s2
ffffffffc020048a:	618040ef          	jal	ra,ffffffffc0204aa2 <strchr>
ffffffffc020048e:	d96d                	beqz	a0,ffffffffc0200480 <kmonitor+0x11e>
ffffffffc0200490:	00044583          	lbu	a1,0(s0)
ffffffffc0200494:	bf91                	j	ffffffffc02003e8 <kmonitor+0x86>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200496:	45c1                	li	a1,16
ffffffffc0200498:	855a                	mv	a0,s6
ffffffffc020049a:	c37ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc020049e:	b7f1                	j	ffffffffc020046a <kmonitor+0x108>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc02004a0:	6582                	ld	a1,0(sp)
ffffffffc02004a2:	00005517          	auipc	a0,0x5
ffffffffc02004a6:	ca650513          	addi	a0,a0,-858 # ffffffffc0205148 <commands+0xc8>
ffffffffc02004aa:	c27ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    return 0;
ffffffffc02004ae:	b72d                	j	ffffffffc02003d8 <kmonitor+0x76>

ffffffffc02004b0 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc02004b0:	8082                	ret

ffffffffc02004b2 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc02004b2:	00253513          	sltiu	a0,a0,2
ffffffffc02004b6:	8082                	ret

ffffffffc02004b8 <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc02004b8:	03800513          	li	a0,56
ffffffffc02004bc:	8082                	ret

ffffffffc02004be <ide_write_secs>:
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
    return 0;
}

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
ffffffffc02004be:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004c0:	0095979b          	slliw	a5,a1,0x9
ffffffffc02004c4:	0000b517          	auipc	a0,0xb
ffffffffc02004c8:	f9c50513          	addi	a0,a0,-100 # ffffffffc020b460 <ide>
                   size_t nsecs) {
ffffffffc02004cc:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004ce:	00969613          	slli	a2,a3,0x9
ffffffffc02004d2:	85ba                	mv	a1,a4
ffffffffc02004d4:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc02004d6:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004d8:	5fa040ef          	jal	ra,ffffffffc0204ad2 <memcpy>
    return 0;
}
ffffffffc02004dc:	60a2                	ld	ra,8(sp)
ffffffffc02004de:	4501                	li	a0,0
ffffffffc02004e0:	0141                	addi	sp,sp,16
ffffffffc02004e2:	8082                	ret

ffffffffc02004e4 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc02004e4:	67e1                	lui	a5,0x18
ffffffffc02004e6:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc02004ea:	00016717          	auipc	a4,0x16
ffffffffc02004ee:	f8f73723          	sd	a5,-114(a4) # ffffffffc0216478 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02004f2:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc02004f6:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02004f8:	953e                	add	a0,a0,a5
ffffffffc02004fa:	4601                	li	a2,0
ffffffffc02004fc:	4881                	li	a7,0
ffffffffc02004fe:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc0200502:	02000793          	li	a5,32
ffffffffc0200506:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc020050a:	00005517          	auipc	a0,0x5
ffffffffc020050e:	cf650513          	addi	a0,a0,-778 # ffffffffc0205200 <commands+0x180>
    ticks = 0;
ffffffffc0200512:	00016797          	auipc	a5,0x16
ffffffffc0200516:	fa07bf23          	sd	zero,-66(a5) # ffffffffc02164d0 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020051a:	bb7ff06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc020051e <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020051e:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200522:	00016797          	auipc	a5,0x16
ffffffffc0200526:	f5678793          	addi	a5,a5,-170 # ffffffffc0216478 <timebase>
ffffffffc020052a:	639c                	ld	a5,0(a5)
ffffffffc020052c:	4581                	li	a1,0
ffffffffc020052e:	4601                	li	a2,0
ffffffffc0200530:	953e                	add	a0,a0,a5
ffffffffc0200532:	4881                	li	a7,0
ffffffffc0200534:	00000073          	ecall
ffffffffc0200538:	8082                	ret

ffffffffc020053a <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc020053a:	8082                	ret

ffffffffc020053c <cons_putc>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020053c:	100027f3          	csrr	a5,sstatus
ffffffffc0200540:	8b89                	andi	a5,a5,2
ffffffffc0200542:	0ff57513          	andi	a0,a0,255
ffffffffc0200546:	e799                	bnez	a5,ffffffffc0200554 <cons_putc+0x18>
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200548:	4581                	li	a1,0
ffffffffc020054a:	4601                	li	a2,0
ffffffffc020054c:	4885                	li	a7,1
ffffffffc020054e:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc0200552:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc0200554:	1101                	addi	sp,sp,-32
ffffffffc0200556:	ec06                	sd	ra,24(sp)
ffffffffc0200558:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020055a:	05c000ef          	jal	ra,ffffffffc02005b6 <intr_disable>
ffffffffc020055e:	6522                	ld	a0,8(sp)
ffffffffc0200560:	4581                	li	a1,0
ffffffffc0200562:	4601                	li	a2,0
ffffffffc0200564:	4885                	li	a7,1
ffffffffc0200566:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc020056a:	60e2                	ld	ra,24(sp)
ffffffffc020056c:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020056e:	0420006f          	j	ffffffffc02005b0 <intr_enable>

ffffffffc0200572 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200572:	100027f3          	csrr	a5,sstatus
ffffffffc0200576:	8b89                	andi	a5,a5,2
ffffffffc0200578:	eb89                	bnez	a5,ffffffffc020058a <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc020057a:	4501                	li	a0,0
ffffffffc020057c:	4581                	li	a1,0
ffffffffc020057e:	4601                	li	a2,0
ffffffffc0200580:	4889                	li	a7,2
ffffffffc0200582:	00000073          	ecall
ffffffffc0200586:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc0200588:	8082                	ret
int cons_getc(void) {
ffffffffc020058a:	1101                	addi	sp,sp,-32
ffffffffc020058c:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc020058e:	028000ef          	jal	ra,ffffffffc02005b6 <intr_disable>
ffffffffc0200592:	4501                	li	a0,0
ffffffffc0200594:	4581                	li	a1,0
ffffffffc0200596:	4601                	li	a2,0
ffffffffc0200598:	4889                	li	a7,2
ffffffffc020059a:	00000073          	ecall
ffffffffc020059e:	2501                	sext.w	a0,a0
ffffffffc02005a0:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02005a2:	00e000ef          	jal	ra,ffffffffc02005b0 <intr_enable>
}
ffffffffc02005a6:	60e2                	ld	ra,24(sp)
ffffffffc02005a8:	6522                	ld	a0,8(sp)
ffffffffc02005aa:	6105                	addi	sp,sp,32
ffffffffc02005ac:	8082                	ret

ffffffffc02005ae <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc02005ae:	8082                	ret

ffffffffc02005b0 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02005b0:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02005b4:	8082                	ret

ffffffffc02005b6 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02005b6:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02005ba:	8082                	ret

ffffffffc02005bc <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02005bc:	10053783          	ld	a5,256(a0)
    cprintf("page falut at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc02005c0:	1141                	addi	sp,sp,-16
ffffffffc02005c2:	e022                	sd	s0,0(sp)
ffffffffc02005c4:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02005c6:	1007f793          	andi	a5,a5,256
static int pgfault_handler(struct trapframe *tf) {
ffffffffc02005ca:	842a                	mv	s0,a0
    cprintf("page falut at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc02005cc:	11053583          	ld	a1,272(a0)
ffffffffc02005d0:	05500613          	li	a2,85
ffffffffc02005d4:	c399                	beqz	a5,ffffffffc02005da <pgfault_handler+0x1e>
ffffffffc02005d6:	04b00613          	li	a2,75
ffffffffc02005da:	11843703          	ld	a4,280(s0)
ffffffffc02005de:	47bd                	li	a5,15
ffffffffc02005e0:	05700693          	li	a3,87
ffffffffc02005e4:	00f70463          	beq	a4,a5,ffffffffc02005ec <pgfault_handler+0x30>
ffffffffc02005e8:	05200693          	li	a3,82
ffffffffc02005ec:	00005517          	auipc	a0,0x5
ffffffffc02005f0:	f0c50513          	addi	a0,a0,-244 # ffffffffc02054f8 <commands+0x478>
ffffffffc02005f4:	addff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc02005f8:	00016797          	auipc	a5,0x16
ffffffffc02005fc:	ee078793          	addi	a5,a5,-288 # ffffffffc02164d8 <check_mm_struct>
ffffffffc0200600:	6388                	ld	a0,0(a5)
ffffffffc0200602:	c911                	beqz	a0,ffffffffc0200616 <pgfault_handler+0x5a>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200604:	11043603          	ld	a2,272(s0)
ffffffffc0200608:	11842583          	lw	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc020060c:	6402                	ld	s0,0(sp)
ffffffffc020060e:	60a2                	ld	ra,8(sp)
ffffffffc0200610:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200612:	4870006f          	j	ffffffffc0201298 <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc0200616:	00005617          	auipc	a2,0x5
ffffffffc020061a:	f0260613          	addi	a2,a2,-254 # ffffffffc0205518 <commands+0x498>
ffffffffc020061e:	06200593          	li	a1,98
ffffffffc0200622:	00005517          	auipc	a0,0x5
ffffffffc0200626:	f0e50513          	addi	a0,a0,-242 # ffffffffc0205530 <commands+0x4b0>
ffffffffc020062a:	badff0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc020062e <idt_init>:
    write_csr(sscratch, 0);
ffffffffc020062e:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc0200632:	00000797          	auipc	a5,0x0
ffffffffc0200636:	48e78793          	addi	a5,a5,1166 # ffffffffc0200ac0 <__alltraps>
ffffffffc020063a:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc020063e:	000407b7          	lui	a5,0x40
ffffffffc0200642:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200646:	8082                	ret

ffffffffc0200648 <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200648:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc020064a:	1141                	addi	sp,sp,-16
ffffffffc020064c:	e022                	sd	s0,0(sp)
ffffffffc020064e:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200650:	00005517          	auipc	a0,0x5
ffffffffc0200654:	ef850513          	addi	a0,a0,-264 # ffffffffc0205548 <commands+0x4c8>
void print_regs(struct pushregs *gpr) {
ffffffffc0200658:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020065a:	a77ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020065e:	640c                	ld	a1,8(s0)
ffffffffc0200660:	00005517          	auipc	a0,0x5
ffffffffc0200664:	f0050513          	addi	a0,a0,-256 # ffffffffc0205560 <commands+0x4e0>
ffffffffc0200668:	a69ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020066c:	680c                	ld	a1,16(s0)
ffffffffc020066e:	00005517          	auipc	a0,0x5
ffffffffc0200672:	f0a50513          	addi	a0,a0,-246 # ffffffffc0205578 <commands+0x4f8>
ffffffffc0200676:	a5bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc020067a:	6c0c                	ld	a1,24(s0)
ffffffffc020067c:	00005517          	auipc	a0,0x5
ffffffffc0200680:	f1450513          	addi	a0,a0,-236 # ffffffffc0205590 <commands+0x510>
ffffffffc0200684:	a4dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc0200688:	700c                	ld	a1,32(s0)
ffffffffc020068a:	00005517          	auipc	a0,0x5
ffffffffc020068e:	f1e50513          	addi	a0,a0,-226 # ffffffffc02055a8 <commands+0x528>
ffffffffc0200692:	a3fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc0200696:	740c                	ld	a1,40(s0)
ffffffffc0200698:	00005517          	auipc	a0,0x5
ffffffffc020069c:	f2850513          	addi	a0,a0,-216 # ffffffffc02055c0 <commands+0x540>
ffffffffc02006a0:	a31ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006a4:	780c                	ld	a1,48(s0)
ffffffffc02006a6:	00005517          	auipc	a0,0x5
ffffffffc02006aa:	f3250513          	addi	a0,a0,-206 # ffffffffc02055d8 <commands+0x558>
ffffffffc02006ae:	a23ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006b2:	7c0c                	ld	a1,56(s0)
ffffffffc02006b4:	00005517          	auipc	a0,0x5
ffffffffc02006b8:	f3c50513          	addi	a0,a0,-196 # ffffffffc02055f0 <commands+0x570>
ffffffffc02006bc:	a15ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006c0:	602c                	ld	a1,64(s0)
ffffffffc02006c2:	00005517          	auipc	a0,0x5
ffffffffc02006c6:	f4650513          	addi	a0,a0,-186 # ffffffffc0205608 <commands+0x588>
ffffffffc02006ca:	a07ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006ce:	642c                	ld	a1,72(s0)
ffffffffc02006d0:	00005517          	auipc	a0,0x5
ffffffffc02006d4:	f5050513          	addi	a0,a0,-176 # ffffffffc0205620 <commands+0x5a0>
ffffffffc02006d8:	9f9ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02006dc:	682c                	ld	a1,80(s0)
ffffffffc02006de:	00005517          	auipc	a0,0x5
ffffffffc02006e2:	f5a50513          	addi	a0,a0,-166 # ffffffffc0205638 <commands+0x5b8>
ffffffffc02006e6:	9ebff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc02006ea:	6c2c                	ld	a1,88(s0)
ffffffffc02006ec:	00005517          	auipc	a0,0x5
ffffffffc02006f0:	f6450513          	addi	a0,a0,-156 # ffffffffc0205650 <commands+0x5d0>
ffffffffc02006f4:	9ddff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc02006f8:	702c                	ld	a1,96(s0)
ffffffffc02006fa:	00005517          	auipc	a0,0x5
ffffffffc02006fe:	f6e50513          	addi	a0,a0,-146 # ffffffffc0205668 <commands+0x5e8>
ffffffffc0200702:	9cfff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200706:	742c                	ld	a1,104(s0)
ffffffffc0200708:	00005517          	auipc	a0,0x5
ffffffffc020070c:	f7850513          	addi	a0,a0,-136 # ffffffffc0205680 <commands+0x600>
ffffffffc0200710:	9c1ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200714:	782c                	ld	a1,112(s0)
ffffffffc0200716:	00005517          	auipc	a0,0x5
ffffffffc020071a:	f8250513          	addi	a0,a0,-126 # ffffffffc0205698 <commands+0x618>
ffffffffc020071e:	9b3ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200722:	7c2c                	ld	a1,120(s0)
ffffffffc0200724:	00005517          	auipc	a0,0x5
ffffffffc0200728:	f8c50513          	addi	a0,a0,-116 # ffffffffc02056b0 <commands+0x630>
ffffffffc020072c:	9a5ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200730:	604c                	ld	a1,128(s0)
ffffffffc0200732:	00005517          	auipc	a0,0x5
ffffffffc0200736:	f9650513          	addi	a0,a0,-106 # ffffffffc02056c8 <commands+0x648>
ffffffffc020073a:	997ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020073e:	644c                	ld	a1,136(s0)
ffffffffc0200740:	00005517          	auipc	a0,0x5
ffffffffc0200744:	fa050513          	addi	a0,a0,-96 # ffffffffc02056e0 <commands+0x660>
ffffffffc0200748:	989ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020074c:	684c                	ld	a1,144(s0)
ffffffffc020074e:	00005517          	auipc	a0,0x5
ffffffffc0200752:	faa50513          	addi	a0,a0,-86 # ffffffffc02056f8 <commands+0x678>
ffffffffc0200756:	97bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020075a:	6c4c                	ld	a1,152(s0)
ffffffffc020075c:	00005517          	auipc	a0,0x5
ffffffffc0200760:	fb450513          	addi	a0,a0,-76 # ffffffffc0205710 <commands+0x690>
ffffffffc0200764:	96dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200768:	704c                	ld	a1,160(s0)
ffffffffc020076a:	00005517          	auipc	a0,0x5
ffffffffc020076e:	fbe50513          	addi	a0,a0,-66 # ffffffffc0205728 <commands+0x6a8>
ffffffffc0200772:	95fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200776:	744c                	ld	a1,168(s0)
ffffffffc0200778:	00005517          	auipc	a0,0x5
ffffffffc020077c:	fc850513          	addi	a0,a0,-56 # ffffffffc0205740 <commands+0x6c0>
ffffffffc0200780:	951ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc0200784:	784c                	ld	a1,176(s0)
ffffffffc0200786:	00005517          	auipc	a0,0x5
ffffffffc020078a:	fd250513          	addi	a0,a0,-46 # ffffffffc0205758 <commands+0x6d8>
ffffffffc020078e:	943ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc0200792:	7c4c                	ld	a1,184(s0)
ffffffffc0200794:	00005517          	auipc	a0,0x5
ffffffffc0200798:	fdc50513          	addi	a0,a0,-36 # ffffffffc0205770 <commands+0x6f0>
ffffffffc020079c:	935ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007a0:	606c                	ld	a1,192(s0)
ffffffffc02007a2:	00005517          	auipc	a0,0x5
ffffffffc02007a6:	fe650513          	addi	a0,a0,-26 # ffffffffc0205788 <commands+0x708>
ffffffffc02007aa:	927ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007ae:	646c                	ld	a1,200(s0)
ffffffffc02007b0:	00005517          	auipc	a0,0x5
ffffffffc02007b4:	ff050513          	addi	a0,a0,-16 # ffffffffc02057a0 <commands+0x720>
ffffffffc02007b8:	919ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007bc:	686c                	ld	a1,208(s0)
ffffffffc02007be:	00005517          	auipc	a0,0x5
ffffffffc02007c2:	ffa50513          	addi	a0,a0,-6 # ffffffffc02057b8 <commands+0x738>
ffffffffc02007c6:	90bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007ca:	6c6c                	ld	a1,216(s0)
ffffffffc02007cc:	00005517          	auipc	a0,0x5
ffffffffc02007d0:	00450513          	addi	a0,a0,4 # ffffffffc02057d0 <commands+0x750>
ffffffffc02007d4:	8fdff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02007d8:	706c                	ld	a1,224(s0)
ffffffffc02007da:	00005517          	auipc	a0,0x5
ffffffffc02007de:	00e50513          	addi	a0,a0,14 # ffffffffc02057e8 <commands+0x768>
ffffffffc02007e2:	8efff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc02007e6:	746c                	ld	a1,232(s0)
ffffffffc02007e8:	00005517          	auipc	a0,0x5
ffffffffc02007ec:	01850513          	addi	a0,a0,24 # ffffffffc0205800 <commands+0x780>
ffffffffc02007f0:	8e1ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc02007f4:	786c                	ld	a1,240(s0)
ffffffffc02007f6:	00005517          	auipc	a0,0x5
ffffffffc02007fa:	02250513          	addi	a0,a0,34 # ffffffffc0205818 <commands+0x798>
ffffffffc02007fe:	8d3ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200802:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200804:	6402                	ld	s0,0(sp)
ffffffffc0200806:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200808:	00005517          	auipc	a0,0x5
ffffffffc020080c:	02850513          	addi	a0,a0,40 # ffffffffc0205830 <commands+0x7b0>
}
ffffffffc0200810:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200812:	8bfff06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc0200816 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200816:	1141                	addi	sp,sp,-16
ffffffffc0200818:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020081a:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc020081c:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020081e:	00005517          	auipc	a0,0x5
ffffffffc0200822:	02a50513          	addi	a0,a0,42 # ffffffffc0205848 <commands+0x7c8>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200826:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200828:	8a9ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    print_regs(&tf->gpr);
ffffffffc020082c:	8522                	mv	a0,s0
ffffffffc020082e:	e1bff0ef          	jal	ra,ffffffffc0200648 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200832:	10043583          	ld	a1,256(s0)
ffffffffc0200836:	00005517          	auipc	a0,0x5
ffffffffc020083a:	02a50513          	addi	a0,a0,42 # ffffffffc0205860 <commands+0x7e0>
ffffffffc020083e:	893ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200842:	10843583          	ld	a1,264(s0)
ffffffffc0200846:	00005517          	auipc	a0,0x5
ffffffffc020084a:	03250513          	addi	a0,a0,50 # ffffffffc0205878 <commands+0x7f8>
ffffffffc020084e:	883ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200852:	11043583          	ld	a1,272(s0)
ffffffffc0200856:	00005517          	auipc	a0,0x5
ffffffffc020085a:	03a50513          	addi	a0,a0,58 # ffffffffc0205890 <commands+0x810>
ffffffffc020085e:	873ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200862:	11843583          	ld	a1,280(s0)
}
ffffffffc0200866:	6402                	ld	s0,0(sp)
ffffffffc0200868:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020086a:	00005517          	auipc	a0,0x5
ffffffffc020086e:	03e50513          	addi	a0,a0,62 # ffffffffc02058a8 <commands+0x828>
}
ffffffffc0200872:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200874:	85dff06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc0200878 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc0200878:	11853783          	ld	a5,280(a0)
ffffffffc020087c:	577d                	li	a4,-1
ffffffffc020087e:	8305                	srli	a4,a4,0x1
ffffffffc0200880:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc0200882:	472d                	li	a4,11
ffffffffc0200884:	06f76f63          	bltu	a4,a5,ffffffffc0200902 <interrupt_handler+0x8a>
ffffffffc0200888:	00005717          	auipc	a4,0x5
ffffffffc020088c:	99470713          	addi	a4,a4,-1644 # ffffffffc020521c <commands+0x19c>
ffffffffc0200890:	078a                	slli	a5,a5,0x2
ffffffffc0200892:	97ba                	add	a5,a5,a4
ffffffffc0200894:	439c                	lw	a5,0(a5)
ffffffffc0200896:	97ba                	add	a5,a5,a4
ffffffffc0200898:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc020089a:	00005517          	auipc	a0,0x5
ffffffffc020089e:	c0e50513          	addi	a0,a0,-1010 # ffffffffc02054a8 <commands+0x428>
ffffffffc02008a2:	82fff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02008a6:	00005517          	auipc	a0,0x5
ffffffffc02008aa:	be250513          	addi	a0,a0,-1054 # ffffffffc0205488 <commands+0x408>
ffffffffc02008ae:	823ff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02008b2:	00005517          	auipc	a0,0x5
ffffffffc02008b6:	b9650513          	addi	a0,a0,-1130 # ffffffffc0205448 <commands+0x3c8>
ffffffffc02008ba:	817ff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02008be:	00005517          	auipc	a0,0x5
ffffffffc02008c2:	baa50513          	addi	a0,a0,-1110 # ffffffffc0205468 <commands+0x3e8>
ffffffffc02008c6:	80bff06f          	j	ffffffffc02000d0 <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc02008ca:	00005517          	auipc	a0,0x5
ffffffffc02008ce:	c0e50513          	addi	a0,a0,-1010 # ffffffffc02054d8 <commands+0x458>
ffffffffc02008d2:	ffeff06f          	j	ffffffffc02000d0 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02008d6:	1141                	addi	sp,sp,-16
ffffffffc02008d8:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc02008da:	c45ff0ef          	jal	ra,ffffffffc020051e <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc02008de:	00016797          	auipc	a5,0x16
ffffffffc02008e2:	bf278793          	addi	a5,a5,-1038 # ffffffffc02164d0 <ticks>
ffffffffc02008e6:	639c                	ld	a5,0(a5)
ffffffffc02008e8:	06400713          	li	a4,100
ffffffffc02008ec:	0785                	addi	a5,a5,1
ffffffffc02008ee:	02e7f733          	remu	a4,a5,a4
ffffffffc02008f2:	00016697          	auipc	a3,0x16
ffffffffc02008f6:	bcf6bf23          	sd	a5,-1058(a3) # ffffffffc02164d0 <ticks>
ffffffffc02008fa:	c711                	beqz	a4,ffffffffc0200906 <interrupt_handler+0x8e>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc02008fc:	60a2                	ld	ra,8(sp)
ffffffffc02008fe:	0141                	addi	sp,sp,16
ffffffffc0200900:	8082                	ret
            print_trapframe(tf);
ffffffffc0200902:	f15ff06f          	j	ffffffffc0200816 <print_trapframe>
}
ffffffffc0200906:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200908:	06400593          	li	a1,100
ffffffffc020090c:	00005517          	auipc	a0,0x5
ffffffffc0200910:	bbc50513          	addi	a0,a0,-1092 # ffffffffc02054c8 <commands+0x448>
}
ffffffffc0200914:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200916:	fbaff06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc020091a <exception_handler>:

void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc020091a:	11853783          	ld	a5,280(a0)
ffffffffc020091e:	473d                	li	a4,15
ffffffffc0200920:	16f76563          	bltu	a4,a5,ffffffffc0200a8a <exception_handler+0x170>
ffffffffc0200924:	00005717          	auipc	a4,0x5
ffffffffc0200928:	92870713          	addi	a4,a4,-1752 # ffffffffc020524c <commands+0x1cc>
ffffffffc020092c:	078a                	slli	a5,a5,0x2
ffffffffc020092e:	97ba                	add	a5,a5,a4
ffffffffc0200930:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc0200932:	1101                	addi	sp,sp,-32
ffffffffc0200934:	e822                	sd	s0,16(sp)
ffffffffc0200936:	ec06                	sd	ra,24(sp)
ffffffffc0200938:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc020093a:	97ba                	add	a5,a5,a4
ffffffffc020093c:	842a                	mv	s0,a0
ffffffffc020093e:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc0200940:	00005517          	auipc	a0,0x5
ffffffffc0200944:	af050513          	addi	a0,a0,-1296 # ffffffffc0205430 <commands+0x3b0>
ffffffffc0200948:	f88ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc020094c:	8522                	mv	a0,s0
ffffffffc020094e:	c6fff0ef          	jal	ra,ffffffffc02005bc <pgfault_handler>
ffffffffc0200952:	84aa                	mv	s1,a0
ffffffffc0200954:	12051d63          	bnez	a0,ffffffffc0200a8e <exception_handler+0x174>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200958:	60e2                	ld	ra,24(sp)
ffffffffc020095a:	6442                	ld	s0,16(sp)
ffffffffc020095c:	64a2                	ld	s1,8(sp)
ffffffffc020095e:	6105                	addi	sp,sp,32
ffffffffc0200960:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc0200962:	00005517          	auipc	a0,0x5
ffffffffc0200966:	92e50513          	addi	a0,a0,-1746 # ffffffffc0205290 <commands+0x210>
}
ffffffffc020096a:	6442                	ld	s0,16(sp)
ffffffffc020096c:	60e2                	ld	ra,24(sp)
ffffffffc020096e:	64a2                	ld	s1,8(sp)
ffffffffc0200970:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200972:	f5eff06f          	j	ffffffffc02000d0 <cprintf>
ffffffffc0200976:	00005517          	auipc	a0,0x5
ffffffffc020097a:	93a50513          	addi	a0,a0,-1734 # ffffffffc02052b0 <commands+0x230>
ffffffffc020097e:	b7f5                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200980:	00005517          	auipc	a0,0x5
ffffffffc0200984:	95050513          	addi	a0,a0,-1712 # ffffffffc02052d0 <commands+0x250>
ffffffffc0200988:	b7cd                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc020098a:	00005517          	auipc	a0,0x5
ffffffffc020098e:	95e50513          	addi	a0,a0,-1698 # ffffffffc02052e8 <commands+0x268>
ffffffffc0200992:	bfe1                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Load address misaligned\n");
ffffffffc0200994:	00005517          	auipc	a0,0x5
ffffffffc0200998:	96450513          	addi	a0,a0,-1692 # ffffffffc02052f8 <commands+0x278>
ffffffffc020099c:	b7f9                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc020099e:	00005517          	auipc	a0,0x5
ffffffffc02009a2:	97a50513          	addi	a0,a0,-1670 # ffffffffc0205318 <commands+0x298>
ffffffffc02009a6:	f2aff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02009aa:	8522                	mv	a0,s0
ffffffffc02009ac:	c11ff0ef          	jal	ra,ffffffffc02005bc <pgfault_handler>
ffffffffc02009b0:	84aa                	mv	s1,a0
ffffffffc02009b2:	d15d                	beqz	a0,ffffffffc0200958 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02009b4:	8522                	mv	a0,s0
ffffffffc02009b6:	e61ff0ef          	jal	ra,ffffffffc0200816 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009ba:	86a6                	mv	a3,s1
ffffffffc02009bc:	00005617          	auipc	a2,0x5
ffffffffc02009c0:	97460613          	addi	a2,a2,-1676 # ffffffffc0205330 <commands+0x2b0>
ffffffffc02009c4:	0b300593          	li	a1,179
ffffffffc02009c8:	00005517          	auipc	a0,0x5
ffffffffc02009cc:	b6850513          	addi	a0,a0,-1176 # ffffffffc0205530 <commands+0x4b0>
ffffffffc02009d0:	807ff0ef          	jal	ra,ffffffffc02001d6 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc02009d4:	00005517          	auipc	a0,0x5
ffffffffc02009d8:	97c50513          	addi	a0,a0,-1668 # ffffffffc0205350 <commands+0x2d0>
ffffffffc02009dc:	b779                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc02009de:	00005517          	auipc	a0,0x5
ffffffffc02009e2:	98a50513          	addi	a0,a0,-1654 # ffffffffc0205368 <commands+0x2e8>
ffffffffc02009e6:	eeaff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02009ea:	8522                	mv	a0,s0
ffffffffc02009ec:	bd1ff0ef          	jal	ra,ffffffffc02005bc <pgfault_handler>
ffffffffc02009f0:	84aa                	mv	s1,a0
ffffffffc02009f2:	d13d                	beqz	a0,ffffffffc0200958 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02009f4:	8522                	mv	a0,s0
ffffffffc02009f6:	e21ff0ef          	jal	ra,ffffffffc0200816 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009fa:	86a6                	mv	a3,s1
ffffffffc02009fc:	00005617          	auipc	a2,0x5
ffffffffc0200a00:	93460613          	addi	a2,a2,-1740 # ffffffffc0205330 <commands+0x2b0>
ffffffffc0200a04:	0bd00593          	li	a1,189
ffffffffc0200a08:	00005517          	auipc	a0,0x5
ffffffffc0200a0c:	b2850513          	addi	a0,a0,-1240 # ffffffffc0205530 <commands+0x4b0>
ffffffffc0200a10:	fc6ff0ef          	jal	ra,ffffffffc02001d6 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc0200a14:	00005517          	auipc	a0,0x5
ffffffffc0200a18:	96c50513          	addi	a0,a0,-1684 # ffffffffc0205380 <commands+0x300>
ffffffffc0200a1c:	b7b9                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc0200a1e:	00005517          	auipc	a0,0x5
ffffffffc0200a22:	98250513          	addi	a0,a0,-1662 # ffffffffc02053a0 <commands+0x320>
ffffffffc0200a26:	b791                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc0200a28:	00005517          	auipc	a0,0x5
ffffffffc0200a2c:	99850513          	addi	a0,a0,-1640 # ffffffffc02053c0 <commands+0x340>
ffffffffc0200a30:	bf2d                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc0200a32:	00005517          	auipc	a0,0x5
ffffffffc0200a36:	9ae50513          	addi	a0,a0,-1618 # ffffffffc02053e0 <commands+0x360>
ffffffffc0200a3a:	bf05                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200a3c:	00005517          	auipc	a0,0x5
ffffffffc0200a40:	9c450513          	addi	a0,a0,-1596 # ffffffffc0205400 <commands+0x380>
ffffffffc0200a44:	b71d                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200a46:	00005517          	auipc	a0,0x5
ffffffffc0200a4a:	9d250513          	addi	a0,a0,-1582 # ffffffffc0205418 <commands+0x398>
ffffffffc0200a4e:	e82ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200a52:	8522                	mv	a0,s0
ffffffffc0200a54:	b69ff0ef          	jal	ra,ffffffffc02005bc <pgfault_handler>
ffffffffc0200a58:	84aa                	mv	s1,a0
ffffffffc0200a5a:	ee050fe3          	beqz	a0,ffffffffc0200958 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200a5e:	8522                	mv	a0,s0
ffffffffc0200a60:	db7ff0ef          	jal	ra,ffffffffc0200816 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a64:	86a6                	mv	a3,s1
ffffffffc0200a66:	00005617          	auipc	a2,0x5
ffffffffc0200a6a:	8ca60613          	addi	a2,a2,-1846 # ffffffffc0205330 <commands+0x2b0>
ffffffffc0200a6e:	0d300593          	li	a1,211
ffffffffc0200a72:	00005517          	auipc	a0,0x5
ffffffffc0200a76:	abe50513          	addi	a0,a0,-1346 # ffffffffc0205530 <commands+0x4b0>
ffffffffc0200a7a:	f5cff0ef          	jal	ra,ffffffffc02001d6 <__panic>
}
ffffffffc0200a7e:	6442                	ld	s0,16(sp)
ffffffffc0200a80:	60e2                	ld	ra,24(sp)
ffffffffc0200a82:	64a2                	ld	s1,8(sp)
ffffffffc0200a84:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200a86:	d91ff06f          	j	ffffffffc0200816 <print_trapframe>
ffffffffc0200a8a:	d8dff06f          	j	ffffffffc0200816 <print_trapframe>
                print_trapframe(tf);
ffffffffc0200a8e:	8522                	mv	a0,s0
ffffffffc0200a90:	d87ff0ef          	jal	ra,ffffffffc0200816 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a94:	86a6                	mv	a3,s1
ffffffffc0200a96:	00005617          	auipc	a2,0x5
ffffffffc0200a9a:	89a60613          	addi	a2,a2,-1894 # ffffffffc0205330 <commands+0x2b0>
ffffffffc0200a9e:	0da00593          	li	a1,218
ffffffffc0200aa2:	00005517          	auipc	a0,0x5
ffffffffc0200aa6:	a8e50513          	addi	a0,a0,-1394 # ffffffffc0205530 <commands+0x4b0>
ffffffffc0200aaa:	f2cff0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc0200aae <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200aae:	11853783          	ld	a5,280(a0)
ffffffffc0200ab2:	0007c463          	bltz	a5,ffffffffc0200aba <trap+0xc>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc0200ab6:	e65ff06f          	j	ffffffffc020091a <exception_handler>
        interrupt_handler(tf);
ffffffffc0200aba:	dbfff06f          	j	ffffffffc0200878 <interrupt_handler>
	...

ffffffffc0200ac0 <__alltraps>:
    LOAD  x2,2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200ac0:	14011073          	csrw	sscratch,sp
ffffffffc0200ac4:	712d                	addi	sp,sp,-288
ffffffffc0200ac6:	e406                	sd	ra,8(sp)
ffffffffc0200ac8:	ec0e                	sd	gp,24(sp)
ffffffffc0200aca:	f012                	sd	tp,32(sp)
ffffffffc0200acc:	f416                	sd	t0,40(sp)
ffffffffc0200ace:	f81a                	sd	t1,48(sp)
ffffffffc0200ad0:	fc1e                	sd	t2,56(sp)
ffffffffc0200ad2:	e0a2                	sd	s0,64(sp)
ffffffffc0200ad4:	e4a6                	sd	s1,72(sp)
ffffffffc0200ad6:	e8aa                	sd	a0,80(sp)
ffffffffc0200ad8:	ecae                	sd	a1,88(sp)
ffffffffc0200ada:	f0b2                	sd	a2,96(sp)
ffffffffc0200adc:	f4b6                	sd	a3,104(sp)
ffffffffc0200ade:	f8ba                	sd	a4,112(sp)
ffffffffc0200ae0:	fcbe                	sd	a5,120(sp)
ffffffffc0200ae2:	e142                	sd	a6,128(sp)
ffffffffc0200ae4:	e546                	sd	a7,136(sp)
ffffffffc0200ae6:	e94a                	sd	s2,144(sp)
ffffffffc0200ae8:	ed4e                	sd	s3,152(sp)
ffffffffc0200aea:	f152                	sd	s4,160(sp)
ffffffffc0200aec:	f556                	sd	s5,168(sp)
ffffffffc0200aee:	f95a                	sd	s6,176(sp)
ffffffffc0200af0:	fd5e                	sd	s7,184(sp)
ffffffffc0200af2:	e1e2                	sd	s8,192(sp)
ffffffffc0200af4:	e5e6                	sd	s9,200(sp)
ffffffffc0200af6:	e9ea                	sd	s10,208(sp)
ffffffffc0200af8:	edee                	sd	s11,216(sp)
ffffffffc0200afa:	f1f2                	sd	t3,224(sp)
ffffffffc0200afc:	f5f6                	sd	t4,232(sp)
ffffffffc0200afe:	f9fa                	sd	t5,240(sp)
ffffffffc0200b00:	fdfe                	sd	t6,248(sp)
ffffffffc0200b02:	14002473          	csrr	s0,sscratch
ffffffffc0200b06:	100024f3          	csrr	s1,sstatus
ffffffffc0200b0a:	14102973          	csrr	s2,sepc
ffffffffc0200b0e:	143029f3          	csrr	s3,stval
ffffffffc0200b12:	14202a73          	csrr	s4,scause
ffffffffc0200b16:	e822                	sd	s0,16(sp)
ffffffffc0200b18:	e226                	sd	s1,256(sp)
ffffffffc0200b1a:	e64a                	sd	s2,264(sp)
ffffffffc0200b1c:	ea4e                	sd	s3,272(sp)
ffffffffc0200b1e:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200b20:	850a                	mv	a0,sp
    jal trap
ffffffffc0200b22:	f8dff0ef          	jal	ra,ffffffffc0200aae <trap>

ffffffffc0200b26 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200b26:	6492                	ld	s1,256(sp)
ffffffffc0200b28:	6932                	ld	s2,264(sp)
ffffffffc0200b2a:	10049073          	csrw	sstatus,s1
ffffffffc0200b2e:	14191073          	csrw	sepc,s2
ffffffffc0200b32:	60a2                	ld	ra,8(sp)
ffffffffc0200b34:	61e2                	ld	gp,24(sp)
ffffffffc0200b36:	7202                	ld	tp,32(sp)
ffffffffc0200b38:	72a2                	ld	t0,40(sp)
ffffffffc0200b3a:	7342                	ld	t1,48(sp)
ffffffffc0200b3c:	73e2                	ld	t2,56(sp)
ffffffffc0200b3e:	6406                	ld	s0,64(sp)
ffffffffc0200b40:	64a6                	ld	s1,72(sp)
ffffffffc0200b42:	6546                	ld	a0,80(sp)
ffffffffc0200b44:	65e6                	ld	a1,88(sp)
ffffffffc0200b46:	7606                	ld	a2,96(sp)
ffffffffc0200b48:	76a6                	ld	a3,104(sp)
ffffffffc0200b4a:	7746                	ld	a4,112(sp)
ffffffffc0200b4c:	77e6                	ld	a5,120(sp)
ffffffffc0200b4e:	680a                	ld	a6,128(sp)
ffffffffc0200b50:	68aa                	ld	a7,136(sp)
ffffffffc0200b52:	694a                	ld	s2,144(sp)
ffffffffc0200b54:	69ea                	ld	s3,152(sp)
ffffffffc0200b56:	7a0a                	ld	s4,160(sp)
ffffffffc0200b58:	7aaa                	ld	s5,168(sp)
ffffffffc0200b5a:	7b4a                	ld	s6,176(sp)
ffffffffc0200b5c:	7bea                	ld	s7,184(sp)
ffffffffc0200b5e:	6c0e                	ld	s8,192(sp)
ffffffffc0200b60:	6cae                	ld	s9,200(sp)
ffffffffc0200b62:	6d4e                	ld	s10,208(sp)
ffffffffc0200b64:	6dee                	ld	s11,216(sp)
ffffffffc0200b66:	7e0e                	ld	t3,224(sp)
ffffffffc0200b68:	7eae                	ld	t4,232(sp)
ffffffffc0200b6a:	7f4e                	ld	t5,240(sp)
ffffffffc0200b6c:	7fee                	ld	t6,248(sp)
ffffffffc0200b6e:	6142                	ld	sp,16(sp)
    # go back from supervisor call
    sret
ffffffffc0200b70:	10200073          	sret

ffffffffc0200b74 <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200b74:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200b76:	bf45                	j	ffffffffc0200b26 <__trapret>
	...

ffffffffc0200b7a <check_vma_overlap.isra.0.part.1>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0200b7a:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0200b7c:	00005697          	auipc	a3,0x5
ffffffffc0200b80:	d4468693          	addi	a3,a3,-700 # ffffffffc02058c0 <commands+0x840>
ffffffffc0200b84:	00005617          	auipc	a2,0x5
ffffffffc0200b88:	d5c60613          	addi	a2,a2,-676 # ffffffffc02058e0 <commands+0x860>
ffffffffc0200b8c:	07e00593          	li	a1,126
ffffffffc0200b90:	00005517          	auipc	a0,0x5
ffffffffc0200b94:	d6850513          	addi	a0,a0,-664 # ffffffffc02058f8 <commands+0x878>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0200b98:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0200b9a:	e3cff0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc0200b9e <mm_create>:
mm_create(void) {
ffffffffc0200b9e:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200ba0:	03000513          	li	a0,48
mm_create(void) {
ffffffffc0200ba4:	e022                	sd	s0,0(sp)
ffffffffc0200ba6:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200ba8:	32a010ef          	jal	ra,ffffffffc0201ed2 <kmalloc>
ffffffffc0200bac:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0200bae:	c115                	beqz	a0,ffffffffc0200bd2 <mm_create+0x34>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200bb0:	00016797          	auipc	a5,0x16
ffffffffc0200bb4:	8e078793          	addi	a5,a5,-1824 # ffffffffc0216490 <swap_init_ok>
ffffffffc0200bb8:	439c                	lw	a5,0(a5)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200bba:	e408                	sd	a0,8(s0)
ffffffffc0200bbc:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0200bbe:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0200bc2:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0200bc6:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200bca:	2781                	sext.w	a5,a5
ffffffffc0200bcc:	eb81                	bnez	a5,ffffffffc0200bdc <mm_create+0x3e>
        else mm->sm_priv = NULL;
ffffffffc0200bce:	02053423          	sd	zero,40(a0)
}
ffffffffc0200bd2:	8522                	mv	a0,s0
ffffffffc0200bd4:	60a2                	ld	ra,8(sp)
ffffffffc0200bd6:	6402                	ld	s0,0(sp)
ffffffffc0200bd8:	0141                	addi	sp,sp,16
ffffffffc0200bda:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200bdc:	715000ef          	jal	ra,ffffffffc0201af0 <swap_init_mm>
}
ffffffffc0200be0:	8522                	mv	a0,s0
ffffffffc0200be2:	60a2                	ld	ra,8(sp)
ffffffffc0200be4:	6402                	ld	s0,0(sp)
ffffffffc0200be6:	0141                	addi	sp,sp,16
ffffffffc0200be8:	8082                	ret

ffffffffc0200bea <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0200bea:	1101                	addi	sp,sp,-32
ffffffffc0200bec:	e04a                	sd	s2,0(sp)
ffffffffc0200bee:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200bf0:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0200bf4:	e822                	sd	s0,16(sp)
ffffffffc0200bf6:	e426                	sd	s1,8(sp)
ffffffffc0200bf8:	ec06                	sd	ra,24(sp)
ffffffffc0200bfa:	84ae                	mv	s1,a1
ffffffffc0200bfc:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200bfe:	2d4010ef          	jal	ra,ffffffffc0201ed2 <kmalloc>
    if (vma != NULL) {
ffffffffc0200c02:	c509                	beqz	a0,ffffffffc0200c0c <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0200c04:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0200c08:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0200c0a:	cd00                	sw	s0,24(a0)
}
ffffffffc0200c0c:	60e2                	ld	ra,24(sp)
ffffffffc0200c0e:	6442                	ld	s0,16(sp)
ffffffffc0200c10:	64a2                	ld	s1,8(sp)
ffffffffc0200c12:	6902                	ld	s2,0(sp)
ffffffffc0200c14:	6105                	addi	sp,sp,32
ffffffffc0200c16:	8082                	ret

ffffffffc0200c18 <find_vma>:
    if (mm != NULL) {
ffffffffc0200c18:	c51d                	beqz	a0,ffffffffc0200c46 <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc0200c1a:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0200c1c:	c781                	beqz	a5,ffffffffc0200c24 <find_vma+0xc>
ffffffffc0200c1e:	6798                	ld	a4,8(a5)
ffffffffc0200c20:	02e5f663          	bleu	a4,a1,ffffffffc0200c4c <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc0200c24:	87aa                	mv	a5,a0
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200c26:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0200c28:	00f50f63          	beq	a0,a5,ffffffffc0200c46 <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0200c2c:	fe87b703          	ld	a4,-24(a5)
ffffffffc0200c30:	fee5ebe3          	bltu	a1,a4,ffffffffc0200c26 <find_vma+0xe>
ffffffffc0200c34:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200c38:	fee5f7e3          	bleu	a4,a1,ffffffffc0200c26 <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc0200c3c:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc0200c3e:	c781                	beqz	a5,ffffffffc0200c46 <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc0200c40:	e91c                	sd	a5,16(a0)
}
ffffffffc0200c42:	853e                	mv	a0,a5
ffffffffc0200c44:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc0200c46:	4781                	li	a5,0
}
ffffffffc0200c48:	853e                	mv	a0,a5
ffffffffc0200c4a:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0200c4c:	6b98                	ld	a4,16(a5)
ffffffffc0200c4e:	fce5fbe3          	bleu	a4,a1,ffffffffc0200c24 <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc0200c52:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc0200c54:	b7fd                	j	ffffffffc0200c42 <find_vma+0x2a>

ffffffffc0200c56 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200c56:	6590                	ld	a2,8(a1)
ffffffffc0200c58:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0200c5c:	1141                	addi	sp,sp,-16
ffffffffc0200c5e:	e406                	sd	ra,8(sp)
ffffffffc0200c60:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200c62:	01066863          	bltu	a2,a6,ffffffffc0200c72 <insert_vma_struct+0x1c>
ffffffffc0200c66:	a8b9                	j	ffffffffc0200cc4 <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0200c68:	fe87b683          	ld	a3,-24(a5)
ffffffffc0200c6c:	04d66763          	bltu	a2,a3,ffffffffc0200cba <insert_vma_struct+0x64>
ffffffffc0200c70:	873e                	mv	a4,a5
ffffffffc0200c72:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc0200c74:	fef51ae3          	bne	a0,a5,ffffffffc0200c68 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0200c78:	02a70463          	beq	a4,a0,ffffffffc0200ca0 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0200c7c:	ff073683          	ld	a3,-16(a4)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0200c80:	fe873883          	ld	a7,-24(a4)
ffffffffc0200c84:	08d8f063          	bleu	a3,a7,ffffffffc0200d04 <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200c88:	04d66e63          	bltu	a2,a3,ffffffffc0200ce4 <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc0200c8c:	00f50a63          	beq	a0,a5,ffffffffc0200ca0 <insert_vma_struct+0x4a>
ffffffffc0200c90:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200c94:	0506e863          	bltu	a3,a6,ffffffffc0200ce4 <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc0200c98:	ff07b603          	ld	a2,-16(a5)
ffffffffc0200c9c:	02c6f263          	bleu	a2,a3,ffffffffc0200cc0 <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0200ca0:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc0200ca2:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0200ca4:	02058613          	addi	a2,a1,32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0200ca8:	e390                	sd	a2,0(a5)
ffffffffc0200caa:	e710                	sd	a2,8(a4)
}
ffffffffc0200cac:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0200cae:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0200cb0:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc0200cb2:	2685                	addiw	a3,a3,1
ffffffffc0200cb4:	d114                	sw	a3,32(a0)
}
ffffffffc0200cb6:	0141                	addi	sp,sp,16
ffffffffc0200cb8:	8082                	ret
    if (le_prev != list) {
ffffffffc0200cba:	fca711e3          	bne	a4,a0,ffffffffc0200c7c <insert_vma_struct+0x26>
ffffffffc0200cbe:	bfd9                	j	ffffffffc0200c94 <insert_vma_struct+0x3e>
ffffffffc0200cc0:	ebbff0ef          	jal	ra,ffffffffc0200b7a <check_vma_overlap.isra.0.part.1>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200cc4:	00005697          	auipc	a3,0x5
ffffffffc0200cc8:	d2c68693          	addi	a3,a3,-724 # ffffffffc02059f0 <commands+0x970>
ffffffffc0200ccc:	00005617          	auipc	a2,0x5
ffffffffc0200cd0:	c1460613          	addi	a2,a2,-1004 # ffffffffc02058e0 <commands+0x860>
ffffffffc0200cd4:	08500593          	li	a1,133
ffffffffc0200cd8:	00005517          	auipc	a0,0x5
ffffffffc0200cdc:	c2050513          	addi	a0,a0,-992 # ffffffffc02058f8 <commands+0x878>
ffffffffc0200ce0:	cf6ff0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200ce4:	00005697          	auipc	a3,0x5
ffffffffc0200ce8:	d4c68693          	addi	a3,a3,-692 # ffffffffc0205a30 <commands+0x9b0>
ffffffffc0200cec:	00005617          	auipc	a2,0x5
ffffffffc0200cf0:	bf460613          	addi	a2,a2,-1036 # ffffffffc02058e0 <commands+0x860>
ffffffffc0200cf4:	07d00593          	li	a1,125
ffffffffc0200cf8:	00005517          	auipc	a0,0x5
ffffffffc0200cfc:	c0050513          	addi	a0,a0,-1024 # ffffffffc02058f8 <commands+0x878>
ffffffffc0200d00:	cd6ff0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0200d04:	00005697          	auipc	a3,0x5
ffffffffc0200d08:	d0c68693          	addi	a3,a3,-756 # ffffffffc0205a10 <commands+0x990>
ffffffffc0200d0c:	00005617          	auipc	a2,0x5
ffffffffc0200d10:	bd460613          	addi	a2,a2,-1068 # ffffffffc02058e0 <commands+0x860>
ffffffffc0200d14:	07c00593          	li	a1,124
ffffffffc0200d18:	00005517          	auipc	a0,0x5
ffffffffc0200d1c:	be050513          	addi	a0,a0,-1056 # ffffffffc02058f8 <commands+0x878>
ffffffffc0200d20:	cb6ff0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc0200d24 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc0200d24:	1141                	addi	sp,sp,-16
ffffffffc0200d26:	e022                	sd	s0,0(sp)
ffffffffc0200d28:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0200d2a:	6508                	ld	a0,8(a0)
ffffffffc0200d2c:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0200d2e:	00a40c63          	beq	s0,a0,ffffffffc0200d46 <mm_destroy+0x22>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200d32:	6118                	ld	a4,0(a0)
ffffffffc0200d34:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0200d36:	1501                	addi	a0,a0,-32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200d38:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200d3a:	e398                	sd	a4,0(a5)
ffffffffc0200d3c:	252010ef          	jal	ra,ffffffffc0201f8e <kfree>
    return listelm->next;
ffffffffc0200d40:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0200d42:	fea418e3          	bne	s0,a0,ffffffffc0200d32 <mm_destroy+0xe>
    }
    kfree(mm); //kfree mm
ffffffffc0200d46:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0200d48:	6402                	ld	s0,0(sp)
ffffffffc0200d4a:	60a2                	ld	ra,8(sp)
ffffffffc0200d4c:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc0200d4e:	2400106f          	j	ffffffffc0201f8e <kfree>

ffffffffc0200d52 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0200d52:	7139                	addi	sp,sp,-64
ffffffffc0200d54:	f822                	sd	s0,48(sp)
ffffffffc0200d56:	f426                	sd	s1,40(sp)
ffffffffc0200d58:	fc06                	sd	ra,56(sp)
ffffffffc0200d5a:	f04a                	sd	s2,32(sp)
ffffffffc0200d5c:	ec4e                	sd	s3,24(sp)
ffffffffc0200d5e:	e852                	sd	s4,16(sp)
ffffffffc0200d60:	e456                	sd	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    struct mm_struct *mm = mm_create();
ffffffffc0200d62:	e3dff0ef          	jal	ra,ffffffffc0200b9e <mm_create>
    assert(mm != NULL);
ffffffffc0200d66:	842a                	mv	s0,a0
ffffffffc0200d68:	03200493          	li	s1,50
ffffffffc0200d6c:	e919                	bnez	a0,ffffffffc0200d82 <vmm_init+0x30>
ffffffffc0200d6e:	a989                	j	ffffffffc02011c0 <vmm_init+0x46e>
        vma->vm_start = vm_start;
ffffffffc0200d70:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0200d72:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0200d74:	00052c23          	sw	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0200d78:	14ed                	addi	s1,s1,-5
ffffffffc0200d7a:	8522                	mv	a0,s0
ffffffffc0200d7c:	edbff0ef          	jal	ra,ffffffffc0200c56 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0200d80:	c88d                	beqz	s1,ffffffffc0200db2 <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200d82:	03000513          	li	a0,48
ffffffffc0200d86:	14c010ef          	jal	ra,ffffffffc0201ed2 <kmalloc>
ffffffffc0200d8a:	85aa                	mv	a1,a0
ffffffffc0200d8c:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0200d90:	f165                	bnez	a0,ffffffffc0200d70 <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc0200d92:	00005697          	auipc	a3,0x5
ffffffffc0200d96:	f3e68693          	addi	a3,a3,-194 # ffffffffc0205cd0 <commands+0xc50>
ffffffffc0200d9a:	00005617          	auipc	a2,0x5
ffffffffc0200d9e:	b4660613          	addi	a2,a2,-1210 # ffffffffc02058e0 <commands+0x860>
ffffffffc0200da2:	0c900593          	li	a1,201
ffffffffc0200da6:	00005517          	auipc	a0,0x5
ffffffffc0200daa:	b5250513          	addi	a0,a0,-1198 # ffffffffc02058f8 <commands+0x878>
ffffffffc0200dae:	c28ff0ef          	jal	ra,ffffffffc02001d6 <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc0200db2:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0200db6:	1f900913          	li	s2,505
ffffffffc0200dba:	a819                	j	ffffffffc0200dd0 <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc0200dbc:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0200dbe:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0200dc0:	00052c23          	sw	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0200dc4:	0495                	addi	s1,s1,5
ffffffffc0200dc6:	8522                	mv	a0,s0
ffffffffc0200dc8:	e8fff0ef          	jal	ra,ffffffffc0200c56 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0200dcc:	03248a63          	beq	s1,s2,ffffffffc0200e00 <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200dd0:	03000513          	li	a0,48
ffffffffc0200dd4:	0fe010ef          	jal	ra,ffffffffc0201ed2 <kmalloc>
ffffffffc0200dd8:	85aa                	mv	a1,a0
ffffffffc0200dda:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0200dde:	fd79                	bnez	a0,ffffffffc0200dbc <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc0200de0:	00005697          	auipc	a3,0x5
ffffffffc0200de4:	ef068693          	addi	a3,a3,-272 # ffffffffc0205cd0 <commands+0xc50>
ffffffffc0200de8:	00005617          	auipc	a2,0x5
ffffffffc0200dec:	af860613          	addi	a2,a2,-1288 # ffffffffc02058e0 <commands+0x860>
ffffffffc0200df0:	0cf00593          	li	a1,207
ffffffffc0200df4:	00005517          	auipc	a0,0x5
ffffffffc0200df8:	b0450513          	addi	a0,a0,-1276 # ffffffffc02058f8 <commands+0x878>
ffffffffc0200dfc:	bdaff0ef          	jal	ra,ffffffffc02001d6 <__panic>
ffffffffc0200e00:	6418                	ld	a4,8(s0)
ffffffffc0200e02:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0200e04:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0200e08:	2ee40063          	beq	s0,a4,ffffffffc02010e8 <vmm_init+0x396>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0200e0c:	fe873603          	ld	a2,-24(a4)
ffffffffc0200e10:	ffe78693          	addi	a3,a5,-2
ffffffffc0200e14:	24d61a63          	bne	a2,a3,ffffffffc0201068 <vmm_init+0x316>
ffffffffc0200e18:	ff073683          	ld	a3,-16(a4)
ffffffffc0200e1c:	24f69663          	bne	a3,a5,ffffffffc0201068 <vmm_init+0x316>
ffffffffc0200e20:	0795                	addi	a5,a5,5
ffffffffc0200e22:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc0200e24:	feb792e3          	bne	a5,a1,ffffffffc0200e08 <vmm_init+0xb6>
ffffffffc0200e28:	491d                	li	s2,7
ffffffffc0200e2a:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0200e2c:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0200e30:	85a6                	mv	a1,s1
ffffffffc0200e32:	8522                	mv	a0,s0
ffffffffc0200e34:	de5ff0ef          	jal	ra,ffffffffc0200c18 <find_vma>
ffffffffc0200e38:	8a2a                	mv	s4,a0
        assert(vma1 != NULL);
ffffffffc0200e3a:	30050763          	beqz	a0,ffffffffc0201148 <vmm_init+0x3f6>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0200e3e:	00148593          	addi	a1,s1,1
ffffffffc0200e42:	8522                	mv	a0,s0
ffffffffc0200e44:	dd5ff0ef          	jal	ra,ffffffffc0200c18 <find_vma>
ffffffffc0200e48:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0200e4a:	2c050f63          	beqz	a0,ffffffffc0201128 <vmm_init+0x3d6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0200e4e:	85ca                	mv	a1,s2
ffffffffc0200e50:	8522                	mv	a0,s0
ffffffffc0200e52:	dc7ff0ef          	jal	ra,ffffffffc0200c18 <find_vma>
        assert(vma3 == NULL);
ffffffffc0200e56:	2a051963          	bnez	a0,ffffffffc0201108 <vmm_init+0x3b6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0200e5a:	00348593          	addi	a1,s1,3
ffffffffc0200e5e:	8522                	mv	a0,s0
ffffffffc0200e60:	db9ff0ef          	jal	ra,ffffffffc0200c18 <find_vma>
        assert(vma4 == NULL);
ffffffffc0200e64:	32051263          	bnez	a0,ffffffffc0201188 <vmm_init+0x436>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0200e68:	00448593          	addi	a1,s1,4
ffffffffc0200e6c:	8522                	mv	a0,s0
ffffffffc0200e6e:	dabff0ef          	jal	ra,ffffffffc0200c18 <find_vma>
        assert(vma5 == NULL);
ffffffffc0200e72:	2e051b63          	bnez	a0,ffffffffc0201168 <vmm_init+0x416>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0200e76:	008a3783          	ld	a5,8(s4)
ffffffffc0200e7a:	20979763          	bne	a5,s1,ffffffffc0201088 <vmm_init+0x336>
ffffffffc0200e7e:	010a3783          	ld	a5,16(s4)
ffffffffc0200e82:	21279363          	bne	a5,s2,ffffffffc0201088 <vmm_init+0x336>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0200e86:	0089b783          	ld	a5,8(s3)
ffffffffc0200e8a:	20979f63          	bne	a5,s1,ffffffffc02010a8 <vmm_init+0x356>
ffffffffc0200e8e:	0109b783          	ld	a5,16(s3)
ffffffffc0200e92:	21279b63          	bne	a5,s2,ffffffffc02010a8 <vmm_init+0x356>
ffffffffc0200e96:	0495                	addi	s1,s1,5
ffffffffc0200e98:	0915                	addi	s2,s2,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0200e9a:	f9549be3          	bne	s1,s5,ffffffffc0200e30 <vmm_init+0xde>
ffffffffc0200e9e:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0200ea0:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0200ea2:	85a6                	mv	a1,s1
ffffffffc0200ea4:	8522                	mv	a0,s0
ffffffffc0200ea6:	d73ff0ef          	jal	ra,ffffffffc0200c18 <find_vma>
ffffffffc0200eaa:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc0200eae:	c90d                	beqz	a0,ffffffffc0200ee0 <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0200eb0:	6914                	ld	a3,16(a0)
ffffffffc0200eb2:	6510                	ld	a2,8(a0)
ffffffffc0200eb4:	00005517          	auipc	a0,0x5
ffffffffc0200eb8:	cac50513          	addi	a0,a0,-852 # ffffffffc0205b60 <commands+0xae0>
ffffffffc0200ebc:	a14ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0200ec0:	00005697          	auipc	a3,0x5
ffffffffc0200ec4:	cc868693          	addi	a3,a3,-824 # ffffffffc0205b88 <commands+0xb08>
ffffffffc0200ec8:	00005617          	auipc	a2,0x5
ffffffffc0200ecc:	a1860613          	addi	a2,a2,-1512 # ffffffffc02058e0 <commands+0x860>
ffffffffc0200ed0:	0f100593          	li	a1,241
ffffffffc0200ed4:	00005517          	auipc	a0,0x5
ffffffffc0200ed8:	a2450513          	addi	a0,a0,-1500 # ffffffffc02058f8 <commands+0x878>
ffffffffc0200edc:	afaff0ef          	jal	ra,ffffffffc02001d6 <__panic>
ffffffffc0200ee0:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc0200ee2:	fd2490e3          	bne	s1,s2,ffffffffc0200ea2 <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc0200ee6:	8522                	mv	a0,s0
ffffffffc0200ee8:	e3dff0ef          	jal	ra,ffffffffc0200d24 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0200eec:	00005517          	auipc	a0,0x5
ffffffffc0200ef0:	cb450513          	addi	a0,a0,-844 # ffffffffc0205ba0 <commands+0xb20>
ffffffffc0200ef4:	9dcff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0200ef8:	1da020ef          	jal	ra,ffffffffc02030d2 <nr_free_pages>
ffffffffc0200efc:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc0200efe:	ca1ff0ef          	jal	ra,ffffffffc0200b9e <mm_create>
ffffffffc0200f02:	00015797          	auipc	a5,0x15
ffffffffc0200f06:	5ca7bb23          	sd	a0,1494(a5) # ffffffffc02164d8 <check_mm_struct>
ffffffffc0200f0a:	84aa                	mv	s1,a0
    assert(check_mm_struct != NULL);
ffffffffc0200f0c:	36050663          	beqz	a0,ffffffffc0201278 <vmm_init+0x526>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0200f10:	00015797          	auipc	a5,0x15
ffffffffc0200f14:	59078793          	addi	a5,a5,1424 # ffffffffc02164a0 <boot_pgdir>
ffffffffc0200f18:	0007b903          	ld	s2,0(a5)
    assert(pgdir[0] == 0);
ffffffffc0200f1c:	00093783          	ld	a5,0(s2)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0200f20:	01253c23          	sd	s2,24(a0)
    assert(pgdir[0] == 0);
ffffffffc0200f24:	2c079e63          	bnez	a5,ffffffffc0201200 <vmm_init+0x4ae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200f28:	03000513          	li	a0,48
ffffffffc0200f2c:	7a7000ef          	jal	ra,ffffffffc0201ed2 <kmalloc>
ffffffffc0200f30:	842a                	mv	s0,a0
    if (vma != NULL) {
ffffffffc0200f32:	18050b63          	beqz	a0,ffffffffc02010c8 <vmm_init+0x376>
        vma->vm_end = vm_end;
ffffffffc0200f36:	002007b7          	lui	a5,0x200
ffffffffc0200f3a:	e81c                	sd	a5,16(s0)
        vma->vm_flags = vm_flags;
ffffffffc0200f3c:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0200f3e:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0200f40:	cc1c                	sw	a5,24(s0)
    insert_vma_struct(mm, vma);
ffffffffc0200f42:	8526                	mv	a0,s1
        vma->vm_start = vm_start;
ffffffffc0200f44:	00043423          	sd	zero,8(s0)
    insert_vma_struct(mm, vma);
ffffffffc0200f48:	d0fff0ef          	jal	ra,ffffffffc0200c56 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0200f4c:	10000593          	li	a1,256
ffffffffc0200f50:	8526                	mv	a0,s1
ffffffffc0200f52:	cc7ff0ef          	jal	ra,ffffffffc0200c18 <find_vma>
ffffffffc0200f56:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc0200f5a:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0200f5e:	2ca41163          	bne	s0,a0,ffffffffc0201220 <vmm_init+0x4ce>
        *(char *)(addr + i) = i;
ffffffffc0200f62:	00f78023          	sb	a5,0(a5) # 200000 <BASE_ADDRESS-0xffffffffc0000000>
        sum += i;
ffffffffc0200f66:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc0200f68:	fee79de3          	bne	a5,a4,ffffffffc0200f62 <vmm_init+0x210>
        sum += i;
ffffffffc0200f6c:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc0200f6e:	10000793          	li	a5,256
        sum += i;
ffffffffc0200f72:	35670713          	addi	a4,a4,854 # 1356 <BASE_ADDRESS-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0200f76:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0200f7a:	0007c683          	lbu	a3,0(a5)
ffffffffc0200f7e:	0785                	addi	a5,a5,1
ffffffffc0200f80:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0200f82:	fec79ce3          	bne	a5,a2,ffffffffc0200f7a <vmm_init+0x228>
    }
    assert(sum == 0);
ffffffffc0200f86:	2c071963          	bnez	a4,ffffffffc0201258 <vmm_init+0x506>
    return pa2page(PTE_ADDR(pte));
}

static inline struct Page *
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
ffffffffc0200f8a:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0200f8e:	00015a97          	auipc	s5,0x15
ffffffffc0200f92:	51aa8a93          	addi	s5,s5,1306 # ffffffffc02164a8 <npage>
ffffffffc0200f96:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0200f9a:	078a                	slli	a5,a5,0x2
ffffffffc0200f9c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0200f9e:	20e7f563          	bleu	a4,a5,ffffffffc02011a8 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0200fa2:	00006697          	auipc	a3,0x6
ffffffffc0200fa6:	27e68693          	addi	a3,a3,638 # ffffffffc0207220 <nbase>
ffffffffc0200faa:	0006ba03          	ld	s4,0(a3)
ffffffffc0200fae:	414786b3          	sub	a3,a5,s4
ffffffffc0200fb2:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0200fb4:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0200fb6:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc0200fb8:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc0200fba:	83b1                	srli	a5,a5,0xc
ffffffffc0200fbc:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0200fbe:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0200fc0:	28e7f063          	bleu	a4,a5,ffffffffc0201240 <vmm_init+0x4ee>
ffffffffc0200fc4:	00015797          	auipc	a5,0x15
ffffffffc0200fc8:	61478793          	addi	a5,a5,1556 # ffffffffc02165d8 <va_pa_offset>
ffffffffc0200fcc:	6380                	ld	s0,0(a5)

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0200fce:	4581                	li	a1,0
ffffffffc0200fd0:	854a                	mv	a0,s2
ffffffffc0200fd2:	9436                	add	s0,s0,a3
ffffffffc0200fd4:	372020ef          	jal	ra,ffffffffc0203346 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc0200fd8:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0200fda:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0200fde:	078a                	slli	a5,a5,0x2
ffffffffc0200fe0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0200fe2:	1ce7f363          	bleu	a4,a5,ffffffffc02011a8 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0200fe6:	00015417          	auipc	s0,0x15
ffffffffc0200fea:	60240413          	addi	s0,s0,1538 # ffffffffc02165e8 <pages>
ffffffffc0200fee:	6008                	ld	a0,0(s0)
ffffffffc0200ff0:	414787b3          	sub	a5,a5,s4
ffffffffc0200ff4:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0200ff6:	953e                	add	a0,a0,a5
ffffffffc0200ff8:	4585                	li	a1,1
ffffffffc0200ffa:	092020ef          	jal	ra,ffffffffc020308c <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0200ffe:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0201002:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201006:	078a                	slli	a5,a5,0x2
ffffffffc0201008:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020100a:	18e7ff63          	bleu	a4,a5,ffffffffc02011a8 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc020100e:	6008                	ld	a0,0(s0)
ffffffffc0201010:	414787b3          	sub	a5,a5,s4
ffffffffc0201014:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0201016:	4585                	li	a1,1
ffffffffc0201018:	953e                	add	a0,a0,a5
ffffffffc020101a:	072020ef          	jal	ra,ffffffffc020308c <free_pages>
    pgdir[0] = 0;
ffffffffc020101e:	00093023          	sd	zero,0(s2)
    page->ref -= 1;
    return page->ref;
}

static inline void flush_tlb() {
  asm volatile("sfence.vma");
ffffffffc0201022:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
ffffffffc0201026:	0004bc23          	sd	zero,24(s1)
    mm_destroy(mm);
ffffffffc020102a:	8526                	mv	a0,s1
ffffffffc020102c:	cf9ff0ef          	jal	ra,ffffffffc0200d24 <mm_destroy>
    check_mm_struct = NULL;
ffffffffc0201030:	00015797          	auipc	a5,0x15
ffffffffc0201034:	4a07b423          	sd	zero,1192(a5) # ffffffffc02164d8 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0201038:	09a020ef          	jal	ra,ffffffffc02030d2 <nr_free_pages>
ffffffffc020103c:	1aa99263          	bne	s3,a0,ffffffffc02011e0 <vmm_init+0x48e>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0201040:	00005517          	auipc	a0,0x5
ffffffffc0201044:	c5850513          	addi	a0,a0,-936 # ffffffffc0205c98 <commands+0xc18>
ffffffffc0201048:	888ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
}
ffffffffc020104c:	7442                	ld	s0,48(sp)
ffffffffc020104e:	70e2                	ld	ra,56(sp)
ffffffffc0201050:	74a2                	ld	s1,40(sp)
ffffffffc0201052:	7902                	ld	s2,32(sp)
ffffffffc0201054:	69e2                	ld	s3,24(sp)
ffffffffc0201056:	6a42                	ld	s4,16(sp)
ffffffffc0201058:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc020105a:	00005517          	auipc	a0,0x5
ffffffffc020105e:	c5e50513          	addi	a0,a0,-930 # ffffffffc0205cb8 <commands+0xc38>
}
ffffffffc0201062:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0201064:	86cff06f          	j	ffffffffc02000d0 <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0201068:	00005697          	auipc	a3,0x5
ffffffffc020106c:	a1068693          	addi	a3,a3,-1520 # ffffffffc0205a78 <commands+0x9f8>
ffffffffc0201070:	00005617          	auipc	a2,0x5
ffffffffc0201074:	87060613          	addi	a2,a2,-1936 # ffffffffc02058e0 <commands+0x860>
ffffffffc0201078:	0d800593          	li	a1,216
ffffffffc020107c:	00005517          	auipc	a0,0x5
ffffffffc0201080:	87c50513          	addi	a0,a0,-1924 # ffffffffc02058f8 <commands+0x878>
ffffffffc0201084:	952ff0ef          	jal	ra,ffffffffc02001d6 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0201088:	00005697          	auipc	a3,0x5
ffffffffc020108c:	a7868693          	addi	a3,a3,-1416 # ffffffffc0205b00 <commands+0xa80>
ffffffffc0201090:	00005617          	auipc	a2,0x5
ffffffffc0201094:	85060613          	addi	a2,a2,-1968 # ffffffffc02058e0 <commands+0x860>
ffffffffc0201098:	0e800593          	li	a1,232
ffffffffc020109c:	00005517          	auipc	a0,0x5
ffffffffc02010a0:	85c50513          	addi	a0,a0,-1956 # ffffffffc02058f8 <commands+0x878>
ffffffffc02010a4:	932ff0ef          	jal	ra,ffffffffc02001d6 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02010a8:	00005697          	auipc	a3,0x5
ffffffffc02010ac:	a8868693          	addi	a3,a3,-1400 # ffffffffc0205b30 <commands+0xab0>
ffffffffc02010b0:	00005617          	auipc	a2,0x5
ffffffffc02010b4:	83060613          	addi	a2,a2,-2000 # ffffffffc02058e0 <commands+0x860>
ffffffffc02010b8:	0e900593          	li	a1,233
ffffffffc02010bc:	00005517          	auipc	a0,0x5
ffffffffc02010c0:	83c50513          	addi	a0,a0,-1988 # ffffffffc02058f8 <commands+0x878>
ffffffffc02010c4:	912ff0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(vma != NULL);
ffffffffc02010c8:	00005697          	auipc	a3,0x5
ffffffffc02010cc:	c0868693          	addi	a3,a3,-1016 # ffffffffc0205cd0 <commands+0xc50>
ffffffffc02010d0:	00005617          	auipc	a2,0x5
ffffffffc02010d4:	81060613          	addi	a2,a2,-2032 # ffffffffc02058e0 <commands+0x860>
ffffffffc02010d8:	10800593          	li	a1,264
ffffffffc02010dc:	00005517          	auipc	a0,0x5
ffffffffc02010e0:	81c50513          	addi	a0,a0,-2020 # ffffffffc02058f8 <commands+0x878>
ffffffffc02010e4:	8f2ff0ef          	jal	ra,ffffffffc02001d6 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc02010e8:	00005697          	auipc	a3,0x5
ffffffffc02010ec:	97868693          	addi	a3,a3,-1672 # ffffffffc0205a60 <commands+0x9e0>
ffffffffc02010f0:	00004617          	auipc	a2,0x4
ffffffffc02010f4:	7f060613          	addi	a2,a2,2032 # ffffffffc02058e0 <commands+0x860>
ffffffffc02010f8:	0d600593          	li	a1,214
ffffffffc02010fc:	00004517          	auipc	a0,0x4
ffffffffc0201100:	7fc50513          	addi	a0,a0,2044 # ffffffffc02058f8 <commands+0x878>
ffffffffc0201104:	8d2ff0ef          	jal	ra,ffffffffc02001d6 <__panic>
        assert(vma3 == NULL);
ffffffffc0201108:	00005697          	auipc	a3,0x5
ffffffffc020110c:	9c868693          	addi	a3,a3,-1592 # ffffffffc0205ad0 <commands+0xa50>
ffffffffc0201110:	00004617          	auipc	a2,0x4
ffffffffc0201114:	7d060613          	addi	a2,a2,2000 # ffffffffc02058e0 <commands+0x860>
ffffffffc0201118:	0e200593          	li	a1,226
ffffffffc020111c:	00004517          	auipc	a0,0x4
ffffffffc0201120:	7dc50513          	addi	a0,a0,2012 # ffffffffc02058f8 <commands+0x878>
ffffffffc0201124:	8b2ff0ef          	jal	ra,ffffffffc02001d6 <__panic>
        assert(vma2 != NULL);
ffffffffc0201128:	00005697          	auipc	a3,0x5
ffffffffc020112c:	99868693          	addi	a3,a3,-1640 # ffffffffc0205ac0 <commands+0xa40>
ffffffffc0201130:	00004617          	auipc	a2,0x4
ffffffffc0201134:	7b060613          	addi	a2,a2,1968 # ffffffffc02058e0 <commands+0x860>
ffffffffc0201138:	0e000593          	li	a1,224
ffffffffc020113c:	00004517          	auipc	a0,0x4
ffffffffc0201140:	7bc50513          	addi	a0,a0,1980 # ffffffffc02058f8 <commands+0x878>
ffffffffc0201144:	892ff0ef          	jal	ra,ffffffffc02001d6 <__panic>
        assert(vma1 != NULL);
ffffffffc0201148:	00005697          	auipc	a3,0x5
ffffffffc020114c:	96868693          	addi	a3,a3,-1688 # ffffffffc0205ab0 <commands+0xa30>
ffffffffc0201150:	00004617          	auipc	a2,0x4
ffffffffc0201154:	79060613          	addi	a2,a2,1936 # ffffffffc02058e0 <commands+0x860>
ffffffffc0201158:	0de00593          	li	a1,222
ffffffffc020115c:	00004517          	auipc	a0,0x4
ffffffffc0201160:	79c50513          	addi	a0,a0,1948 # ffffffffc02058f8 <commands+0x878>
ffffffffc0201164:	872ff0ef          	jal	ra,ffffffffc02001d6 <__panic>
        assert(vma5 == NULL);
ffffffffc0201168:	00005697          	auipc	a3,0x5
ffffffffc020116c:	98868693          	addi	a3,a3,-1656 # ffffffffc0205af0 <commands+0xa70>
ffffffffc0201170:	00004617          	auipc	a2,0x4
ffffffffc0201174:	77060613          	addi	a2,a2,1904 # ffffffffc02058e0 <commands+0x860>
ffffffffc0201178:	0e600593          	li	a1,230
ffffffffc020117c:	00004517          	auipc	a0,0x4
ffffffffc0201180:	77c50513          	addi	a0,a0,1916 # ffffffffc02058f8 <commands+0x878>
ffffffffc0201184:	852ff0ef          	jal	ra,ffffffffc02001d6 <__panic>
        assert(vma4 == NULL);
ffffffffc0201188:	00005697          	auipc	a3,0x5
ffffffffc020118c:	95868693          	addi	a3,a3,-1704 # ffffffffc0205ae0 <commands+0xa60>
ffffffffc0201190:	00004617          	auipc	a2,0x4
ffffffffc0201194:	75060613          	addi	a2,a2,1872 # ffffffffc02058e0 <commands+0x860>
ffffffffc0201198:	0e400593          	li	a1,228
ffffffffc020119c:	00004517          	auipc	a0,0x4
ffffffffc02011a0:	75c50513          	addi	a0,a0,1884 # ffffffffc02058f8 <commands+0x878>
ffffffffc02011a4:	832ff0ef          	jal	ra,ffffffffc02001d6 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02011a8:	00005617          	auipc	a2,0x5
ffffffffc02011ac:	a7060613          	addi	a2,a2,-1424 # ffffffffc0205c18 <commands+0xb98>
ffffffffc02011b0:	06200593          	li	a1,98
ffffffffc02011b4:	00005517          	auipc	a0,0x5
ffffffffc02011b8:	a8450513          	addi	a0,a0,-1404 # ffffffffc0205c38 <commands+0xbb8>
ffffffffc02011bc:	81aff0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(mm != NULL);
ffffffffc02011c0:	00005697          	auipc	a3,0x5
ffffffffc02011c4:	89068693          	addi	a3,a3,-1904 # ffffffffc0205a50 <commands+0x9d0>
ffffffffc02011c8:	00004617          	auipc	a2,0x4
ffffffffc02011cc:	71860613          	addi	a2,a2,1816 # ffffffffc02058e0 <commands+0x860>
ffffffffc02011d0:	0c200593          	li	a1,194
ffffffffc02011d4:	00004517          	auipc	a0,0x4
ffffffffc02011d8:	72450513          	addi	a0,a0,1828 # ffffffffc02058f8 <commands+0x878>
ffffffffc02011dc:	ffbfe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02011e0:	00005697          	auipc	a3,0x5
ffffffffc02011e4:	a9068693          	addi	a3,a3,-1392 # ffffffffc0205c70 <commands+0xbf0>
ffffffffc02011e8:	00004617          	auipc	a2,0x4
ffffffffc02011ec:	6f860613          	addi	a2,a2,1784 # ffffffffc02058e0 <commands+0x860>
ffffffffc02011f0:	12400593          	li	a1,292
ffffffffc02011f4:	00004517          	auipc	a0,0x4
ffffffffc02011f8:	70450513          	addi	a0,a0,1796 # ffffffffc02058f8 <commands+0x878>
ffffffffc02011fc:	fdbfe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0201200:	00005697          	auipc	a3,0x5
ffffffffc0201204:	9d868693          	addi	a3,a3,-1576 # ffffffffc0205bd8 <commands+0xb58>
ffffffffc0201208:	00004617          	auipc	a2,0x4
ffffffffc020120c:	6d860613          	addi	a2,a2,1752 # ffffffffc02058e0 <commands+0x860>
ffffffffc0201210:	10500593          	li	a1,261
ffffffffc0201214:	00004517          	auipc	a0,0x4
ffffffffc0201218:	6e450513          	addi	a0,a0,1764 # ffffffffc02058f8 <commands+0x878>
ffffffffc020121c:	fbbfe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0201220:	00005697          	auipc	a3,0x5
ffffffffc0201224:	9c868693          	addi	a3,a3,-1592 # ffffffffc0205be8 <commands+0xb68>
ffffffffc0201228:	00004617          	auipc	a2,0x4
ffffffffc020122c:	6b860613          	addi	a2,a2,1720 # ffffffffc02058e0 <commands+0x860>
ffffffffc0201230:	10d00593          	li	a1,269
ffffffffc0201234:	00004517          	auipc	a0,0x4
ffffffffc0201238:	6c450513          	addi	a0,a0,1732 # ffffffffc02058f8 <commands+0x878>
ffffffffc020123c:	f9bfe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    return KADDR(page2pa(page));
ffffffffc0201240:	00005617          	auipc	a2,0x5
ffffffffc0201244:	a0860613          	addi	a2,a2,-1528 # ffffffffc0205c48 <commands+0xbc8>
ffffffffc0201248:	06900593          	li	a1,105
ffffffffc020124c:	00005517          	auipc	a0,0x5
ffffffffc0201250:	9ec50513          	addi	a0,a0,-1556 # ffffffffc0205c38 <commands+0xbb8>
ffffffffc0201254:	f83fe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(sum == 0);
ffffffffc0201258:	00005697          	auipc	a3,0x5
ffffffffc020125c:	9b068693          	addi	a3,a3,-1616 # ffffffffc0205c08 <commands+0xb88>
ffffffffc0201260:	00004617          	auipc	a2,0x4
ffffffffc0201264:	68060613          	addi	a2,a2,1664 # ffffffffc02058e0 <commands+0x860>
ffffffffc0201268:	11700593          	li	a1,279
ffffffffc020126c:	00004517          	auipc	a0,0x4
ffffffffc0201270:	68c50513          	addi	a0,a0,1676 # ffffffffc02058f8 <commands+0x878>
ffffffffc0201274:	f63fe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0201278:	00005697          	auipc	a3,0x5
ffffffffc020127c:	94868693          	addi	a3,a3,-1720 # ffffffffc0205bc0 <commands+0xb40>
ffffffffc0201280:	00004617          	auipc	a2,0x4
ffffffffc0201284:	66060613          	addi	a2,a2,1632 # ffffffffc02058e0 <commands+0x860>
ffffffffc0201288:	10100593          	li	a1,257
ffffffffc020128c:	00004517          	auipc	a0,0x4
ffffffffc0201290:	66c50513          	addi	a0,a0,1644 # ffffffffc02058f8 <commands+0x878>
ffffffffc0201294:	f43fe0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc0201298 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc0201298:	1101                	addi	sp,sp,-32
    cprintf("THIS MY:do_pgfault begin, addr = %x !\n", addr);
ffffffffc020129a:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc020129c:	e04a                	sd	s2,0(sp)
ffffffffc020129e:	892a                	mv	s2,a0
    cprintf("THIS MY:do_pgfault begin, addr = %x !\n", addr);
ffffffffc02012a0:	00004517          	auipc	a0,0x4
ffffffffc02012a4:	66850513          	addi	a0,a0,1640 # ffffffffc0205908 <commands+0x888>
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc02012a8:	ec06                	sd	ra,24(sp)
ffffffffc02012aa:	e822                	sd	s0,16(sp)
ffffffffc02012ac:	e426                	sd	s1,8(sp)
ffffffffc02012ae:	8432                	mv	s0,a2
    cprintf("THIS MY:do_pgfault begin, addr = %x !\n", addr);
ffffffffc02012b0:	e21fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02012b4:	85a2                	mv	a1,s0
ffffffffc02012b6:	854a                	mv	a0,s2
ffffffffc02012b8:	961ff0ef          	jal	ra,ffffffffc0200c18 <find_vma>

    pgfault_num++;
ffffffffc02012bc:	00015797          	auipc	a5,0x15
ffffffffc02012c0:	1c478793          	addi	a5,a5,452 # ffffffffc0216480 <pgfault_num>
ffffffffc02012c4:	439c                	lw	a5,0(a5)
ffffffffc02012c6:	2785                	addiw	a5,a5,1
ffffffffc02012c8:	00015717          	auipc	a4,0x15
ffffffffc02012cc:	1af72c23          	sw	a5,440(a4) # ffffffffc0216480 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc02012d0:	c52d                	beqz	a0,ffffffffc020133a <do_pgfault+0xa2>
ffffffffc02012d2:	651c                	ld	a5,8(a0)
ffffffffc02012d4:	84aa                	mv	s1,a0
ffffffffc02012d6:	06f46263          	bltu	s0,a5,ffffffffc020133a <do_pgfault+0xa2>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);// 为什么没有找到
        goto failed;
    }
    cprintf("THIS MY:do_pgfault find !\n");
ffffffffc02012da:	00004517          	auipc	a0,0x4
ffffffffc02012de:	68650513          	addi	a0,a0,1670 # ffffffffc0205960 <commands+0x8e0>
ffffffffc02012e2:	deffe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc02012e6:	4c9c                	lw	a5,24(s1)
    uint32_t perm = PTE_U;
ffffffffc02012e8:	44c1                	li	s1,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc02012ea:	8b89                	andi	a5,a5,2
ffffffffc02012ec:	e795                	bnez	a5,ffffffffc0201318 <do_pgfault+0x80>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02012ee:	77fd                	lui	a5,0xfffff

    pte_t *ptep=NULL;
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc02012f0:	01893503          	ld	a0,24(s2)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02012f4:	8c7d                	and	s0,s0,a5
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc02012f6:	4605                	li	a2,1
ffffffffc02012f8:	85a2                	mv	a1,s0
ffffffffc02012fa:	619010ef          	jal	ra,ffffffffc0203112 <get_pte>
ffffffffc02012fe:	cd39                	beqz	a0,ffffffffc020135c <do_pgfault+0xc4>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc0201300:	610c                	ld	a1,0(a0)
ffffffffc0201302:	cd89                	beqz	a1,ffffffffc020131c <do_pgfault+0x84>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0201304:	00015797          	auipc	a5,0x15
ffffffffc0201308:	18c78793          	addi	a5,a5,396 # ffffffffc0216490 <swap_init_ok>
ffffffffc020130c:	439c                	lw	a5,0(a5)
ffffffffc020130e:	2781                	sext.w	a5,a5
ffffffffc0201310:	cf95                	beqz	a5,ffffffffc020134c <do_pgfault+0xb4>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            page->pra_vaddr = addr;
ffffffffc0201312:	02003c23          	sd	zero,56(zero) # 38 <BASE_ADDRESS-0xffffffffc01fffc8>
ffffffffc0201316:	9002                	ebreak
        perm |= READ_WRITE;
ffffffffc0201318:	44dd                	li	s1,23
ffffffffc020131a:	bfd1                	j	ffffffffc02012ee <do_pgfault+0x56>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc020131c:	01893503          	ld	a0,24(s2)
ffffffffc0201320:	8626                	mv	a2,s1
ffffffffc0201322:	85a2                	mv	a1,s0
ffffffffc0201324:	3e5020ef          	jal	ra,ffffffffc0203f08 <pgdir_alloc_page>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
ffffffffc0201328:	4781                	li	a5,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc020132a:	c129                	beqz	a0,ffffffffc020136c <do_pgfault+0xd4>
failed:
    return ret;
}
ffffffffc020132c:	60e2                	ld	ra,24(sp)
ffffffffc020132e:	6442                	ld	s0,16(sp)
ffffffffc0201330:	64a2                	ld	s1,8(sp)
ffffffffc0201332:	6902                	ld	s2,0(sp)
ffffffffc0201334:	853e                	mv	a0,a5
ffffffffc0201336:	6105                	addi	sp,sp,32
ffffffffc0201338:	8082                	ret
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);// 为什么没有找到
ffffffffc020133a:	85a2                	mv	a1,s0
ffffffffc020133c:	00004517          	auipc	a0,0x4
ffffffffc0201340:	5f450513          	addi	a0,a0,1524 # ffffffffc0205930 <commands+0x8b0>
ffffffffc0201344:	d8dfe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    int ret = -E_INVAL;
ffffffffc0201348:	57f5                	li	a5,-3
        goto failed;
ffffffffc020134a:	b7cd                	j	ffffffffc020132c <do_pgfault+0x94>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc020134c:	00004517          	auipc	a0,0x4
ffffffffc0201350:	67c50513          	addi	a0,a0,1660 # ffffffffc02059c8 <commands+0x948>
ffffffffc0201354:	d7dfe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0201358:	57f1                	li	a5,-4
            goto failed;
ffffffffc020135a:	bfc9                	j	ffffffffc020132c <do_pgfault+0x94>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc020135c:	00004517          	auipc	a0,0x4
ffffffffc0201360:	62450513          	addi	a0,a0,1572 # ffffffffc0205980 <commands+0x900>
ffffffffc0201364:	d6dfe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0201368:	57f1                	li	a5,-4
        goto failed;
ffffffffc020136a:	b7c9                	j	ffffffffc020132c <do_pgfault+0x94>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc020136c:	00004517          	auipc	a0,0x4
ffffffffc0201370:	63450513          	addi	a0,a0,1588 # ffffffffc02059a0 <commands+0x920>
ffffffffc0201374:	d5dfe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0201378:	57f1                	li	a5,-4
            goto failed;
ffffffffc020137a:	bf4d                	j	ffffffffc020132c <do_pgfault+0x94>

ffffffffc020137c <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc020137c:	7135                	addi	sp,sp,-160
ffffffffc020137e:	ed06                	sd	ra,152(sp)
ffffffffc0201380:	e922                	sd	s0,144(sp)
ffffffffc0201382:	e526                	sd	s1,136(sp)
ffffffffc0201384:	e14a                	sd	s2,128(sp)
ffffffffc0201386:	fcce                	sd	s3,120(sp)
ffffffffc0201388:	f8d2                	sd	s4,112(sp)
ffffffffc020138a:	f4d6                	sd	s5,104(sp)
ffffffffc020138c:	f0da                	sd	s6,96(sp)
ffffffffc020138e:	ecde                	sd	s7,88(sp)
ffffffffc0201390:	e8e2                	sd	s8,80(sp)
ffffffffc0201392:	e4e6                	sd	s9,72(sp)
ffffffffc0201394:	e0ea                	sd	s10,64(sp)
ffffffffc0201396:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0201398:	403020ef          	jal	ra,ffffffffc0203f9a <swapfs_init>
     // if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
     // {
     //      panic("bad max_swap_offset %08x.\n", max_swap_offset);
     // }
     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc020139c:	00015797          	auipc	a5,0x15
ffffffffc02013a0:	1cc78793          	addi	a5,a5,460 # ffffffffc0216568 <max_swap_offset>
ffffffffc02013a4:	6394                	ld	a3,0(a5)
ffffffffc02013a6:	010007b7          	lui	a5,0x1000
ffffffffc02013aa:	17e1                	addi	a5,a5,-8
ffffffffc02013ac:	ff968713          	addi	a4,a3,-7
ffffffffc02013b0:	4ae7e863          	bltu	a5,a4,ffffffffc0201860 <swap_init+0x4e4>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_fifo;
ffffffffc02013b4:	0000a797          	auipc	a5,0xa
ffffffffc02013b8:	c5c78793          	addi	a5,a5,-932 # ffffffffc020b010 <swap_manager_fifo>
     int r = sm->init();
ffffffffc02013bc:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc02013be:	00015697          	auipc	a3,0x15
ffffffffc02013c2:	0cf6b523          	sd	a5,202(a3) # ffffffffc0216488 <sm>
     int r = sm->init();
ffffffffc02013c6:	9702                	jalr	a4
ffffffffc02013c8:	8aaa                	mv	s5,a0
     
     if (r == 0)
ffffffffc02013ca:	c10d                	beqz	a0,ffffffffc02013ec <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc02013cc:	60ea                	ld	ra,152(sp)
ffffffffc02013ce:	644a                	ld	s0,144(sp)
ffffffffc02013d0:	8556                	mv	a0,s5
ffffffffc02013d2:	64aa                	ld	s1,136(sp)
ffffffffc02013d4:	690a                	ld	s2,128(sp)
ffffffffc02013d6:	79e6                	ld	s3,120(sp)
ffffffffc02013d8:	7a46                	ld	s4,112(sp)
ffffffffc02013da:	7aa6                	ld	s5,104(sp)
ffffffffc02013dc:	7b06                	ld	s6,96(sp)
ffffffffc02013de:	6be6                	ld	s7,88(sp)
ffffffffc02013e0:	6c46                	ld	s8,80(sp)
ffffffffc02013e2:	6ca6                	ld	s9,72(sp)
ffffffffc02013e4:	6d06                	ld	s10,64(sp)
ffffffffc02013e6:	7de2                	ld	s11,56(sp)
ffffffffc02013e8:	610d                	addi	sp,sp,160
ffffffffc02013ea:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02013ec:	00015797          	auipc	a5,0x15
ffffffffc02013f0:	09c78793          	addi	a5,a5,156 # ffffffffc0216488 <sm>
ffffffffc02013f4:	639c                	ld	a5,0(a5)
ffffffffc02013f6:	00005517          	auipc	a0,0x5
ffffffffc02013fa:	91a50513          	addi	a0,a0,-1766 # ffffffffc0205d10 <commands+0xc90>
ffffffffc02013fe:	00015417          	auipc	s0,0x15
ffffffffc0201402:	1ba40413          	addi	s0,s0,442 # ffffffffc02165b8 <free_area>
ffffffffc0201406:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0201408:	4785                	li	a5,1
ffffffffc020140a:	00015717          	auipc	a4,0x15
ffffffffc020140e:	08f72323          	sw	a5,134(a4) # ffffffffc0216490 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0201412:	cbffe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc0201416:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201418:	36878863          	beq	a5,s0,ffffffffc0201788 <swap_init+0x40c>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020141c:	ff07b703          	ld	a4,-16(a5)
ffffffffc0201420:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0201422:	8b05                	andi	a4,a4,1
ffffffffc0201424:	36070663          	beqz	a4,ffffffffc0201790 <swap_init+0x414>
     int ret, count = 0, total = 0, i;
ffffffffc0201428:	4481                	li	s1,0
ffffffffc020142a:	4901                	li	s2,0
ffffffffc020142c:	a031                	j	ffffffffc0201438 <swap_init+0xbc>
ffffffffc020142e:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0201432:	8b09                	andi	a4,a4,2
ffffffffc0201434:	34070e63          	beqz	a4,ffffffffc0201790 <swap_init+0x414>
        count ++, total += p->property;
ffffffffc0201438:	ff87a703          	lw	a4,-8(a5)
ffffffffc020143c:	679c                	ld	a5,8(a5)
ffffffffc020143e:	2905                	addiw	s2,s2,1
ffffffffc0201440:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201442:	fe8796e3          	bne	a5,s0,ffffffffc020142e <swap_init+0xb2>
ffffffffc0201446:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc0201448:	48b010ef          	jal	ra,ffffffffc02030d2 <nr_free_pages>
ffffffffc020144c:	69351263          	bne	a0,s3,ffffffffc0201ad0 <swap_init+0x754>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0201450:	8626                	mv	a2,s1
ffffffffc0201452:	85ca                	mv	a1,s2
ffffffffc0201454:	00005517          	auipc	a0,0x5
ffffffffc0201458:	90450513          	addi	a0,a0,-1788 # ffffffffc0205d58 <commands+0xcd8>
ffffffffc020145c:	c75fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0201460:	f3eff0ef          	jal	ra,ffffffffc0200b9e <mm_create>
ffffffffc0201464:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc0201466:	60050563          	beqz	a0,ffffffffc0201a70 <swap_init+0x6f4>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc020146a:	00015797          	auipc	a5,0x15
ffffffffc020146e:	06e78793          	addi	a5,a5,110 # ffffffffc02164d8 <check_mm_struct>
ffffffffc0201472:	639c                	ld	a5,0(a5)
ffffffffc0201474:	60079e63          	bnez	a5,ffffffffc0201a90 <swap_init+0x714>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0201478:	00015797          	auipc	a5,0x15
ffffffffc020147c:	02878793          	addi	a5,a5,40 # ffffffffc02164a0 <boot_pgdir>
ffffffffc0201480:	0007bb03          	ld	s6,0(a5)
     check_mm_struct = mm;
ffffffffc0201484:	00015797          	auipc	a5,0x15
ffffffffc0201488:	04a7ba23          	sd	a0,84(a5) # ffffffffc02164d8 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc020148c:	000b3783          	ld	a5,0(s6)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0201490:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0201494:	4e079263          	bnez	a5,ffffffffc0201978 <swap_init+0x5fc>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0201498:	6599                	lui	a1,0x6
ffffffffc020149a:	460d                	li	a2,3
ffffffffc020149c:	6505                	lui	a0,0x1
ffffffffc020149e:	f4cff0ef          	jal	ra,ffffffffc0200bea <vma_create>
ffffffffc02014a2:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc02014a4:	4e050a63          	beqz	a0,ffffffffc0201998 <swap_init+0x61c>

     insert_vma_struct(mm, vma);
ffffffffc02014a8:	855e                	mv	a0,s7
ffffffffc02014aa:	facff0ef          	jal	ra,ffffffffc0200c56 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc02014ae:	00005517          	auipc	a0,0x5
ffffffffc02014b2:	8ea50513          	addi	a0,a0,-1814 # ffffffffc0205d98 <commands+0xd18>
ffffffffc02014b6:	c1bfe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc02014ba:	018bb503          	ld	a0,24(s7)
ffffffffc02014be:	4605                	li	a2,1
ffffffffc02014c0:	6585                	lui	a1,0x1
ffffffffc02014c2:	451010ef          	jal	ra,ffffffffc0203112 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc02014c6:	4e050963          	beqz	a0,ffffffffc02019b8 <swap_init+0x63c>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02014ca:	00005517          	auipc	a0,0x5
ffffffffc02014ce:	91e50513          	addi	a0,a0,-1762 # ffffffffc0205de8 <commands+0xd68>
ffffffffc02014d2:	00015997          	auipc	s3,0x15
ffffffffc02014d6:	00e98993          	addi	s3,s3,14 # ffffffffc02164e0 <check_rp>
ffffffffc02014da:	bf7fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02014de:	00015a17          	auipc	s4,0x15
ffffffffc02014e2:	022a0a13          	addi	s4,s4,34 # ffffffffc0216500 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02014e6:	8c4e                	mv	s8,s3
          check_rp[i] = alloc_page();
ffffffffc02014e8:	4505                	li	a0,1
ffffffffc02014ea:	31b010ef          	jal	ra,ffffffffc0203004 <alloc_pages>
ffffffffc02014ee:	00ac3023          	sd	a0,0(s8)
          assert(check_rp[i] != NULL );
ffffffffc02014f2:	32050763          	beqz	a0,ffffffffc0201820 <swap_init+0x4a4>
ffffffffc02014f6:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc02014f8:	8b89                	andi	a5,a5,2
ffffffffc02014fa:	30079363          	bnez	a5,ffffffffc0201800 <swap_init+0x484>
ffffffffc02014fe:	0c21                	addi	s8,s8,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201500:	ff4c14e3          	bne	s8,s4,ffffffffc02014e8 <swap_init+0x16c>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0201504:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0201506:	00015c17          	auipc	s8,0x15
ffffffffc020150a:	fdac0c13          	addi	s8,s8,-38 # ffffffffc02164e0 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc020150e:	ec3e                	sd	a5,24(sp)
ffffffffc0201510:	641c                	ld	a5,8(s0)
ffffffffc0201512:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0201514:	481c                	lw	a5,16(s0)
ffffffffc0201516:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc0201518:	00015797          	auipc	a5,0x15
ffffffffc020151c:	0a87b423          	sd	s0,168(a5) # ffffffffc02165c0 <free_area+0x8>
ffffffffc0201520:	00015797          	auipc	a5,0x15
ffffffffc0201524:	0887bc23          	sd	s0,152(a5) # ffffffffc02165b8 <free_area>
     nr_free = 0;
ffffffffc0201528:	00015797          	auipc	a5,0x15
ffffffffc020152c:	0a07a023          	sw	zero,160(a5) # ffffffffc02165c8 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0201530:	000c3503          	ld	a0,0(s8)
ffffffffc0201534:	4585                	li	a1,1
ffffffffc0201536:	0c21                	addi	s8,s8,8
ffffffffc0201538:	355010ef          	jal	ra,ffffffffc020308c <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020153c:	ff4c1ae3          	bne	s8,s4,ffffffffc0201530 <swap_init+0x1b4>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0201540:	01042c03          	lw	s8,16(s0)
ffffffffc0201544:	4791                	li	a5,4
ffffffffc0201546:	50fc1563          	bne	s8,a5,ffffffffc0201a50 <swap_init+0x6d4>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc020154a:	00005517          	auipc	a0,0x5
ffffffffc020154e:	92650513          	addi	a0,a0,-1754 # ffffffffc0205e70 <commands+0xdf0>
ffffffffc0201552:	b7ffe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201556:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0201558:	00015797          	auipc	a5,0x15
ffffffffc020155c:	f207a423          	sw	zero,-216(a5) # ffffffffc0216480 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201560:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc0201562:	00015797          	auipc	a5,0x15
ffffffffc0201566:	f1e78793          	addi	a5,a5,-226 # ffffffffc0216480 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc020156a:	00c68023          	sb	a2,0(a3) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc020156e:	4398                	lw	a4,0(a5)
ffffffffc0201570:	4585                	li	a1,1
ffffffffc0201572:	2701                	sext.w	a4,a4
ffffffffc0201574:	38b71263          	bne	a4,a1,ffffffffc02018f8 <swap_init+0x57c>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0201578:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc020157c:	4394                	lw	a3,0(a5)
ffffffffc020157e:	2681                	sext.w	a3,a3
ffffffffc0201580:	38e69c63          	bne	a3,a4,ffffffffc0201918 <swap_init+0x59c>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0201584:	6689                	lui	a3,0x2
ffffffffc0201586:	462d                	li	a2,11
ffffffffc0201588:	00c68023          	sb	a2,0(a3) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc020158c:	4398                	lw	a4,0(a5)
ffffffffc020158e:	4589                	li	a1,2
ffffffffc0201590:	2701                	sext.w	a4,a4
ffffffffc0201592:	2eb71363          	bne	a4,a1,ffffffffc0201878 <swap_init+0x4fc>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0201596:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc020159a:	4394                	lw	a3,0(a5)
ffffffffc020159c:	2681                	sext.w	a3,a3
ffffffffc020159e:	2ee69d63          	bne	a3,a4,ffffffffc0201898 <swap_init+0x51c>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc02015a2:	668d                	lui	a3,0x3
ffffffffc02015a4:	4631                	li	a2,12
ffffffffc02015a6:	00c68023          	sb	a2,0(a3) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc02015aa:	4398                	lw	a4,0(a5)
ffffffffc02015ac:	458d                	li	a1,3
ffffffffc02015ae:	2701                	sext.w	a4,a4
ffffffffc02015b0:	30b71463          	bne	a4,a1,ffffffffc02018b8 <swap_init+0x53c>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc02015b4:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc02015b8:	4394                	lw	a3,0(a5)
ffffffffc02015ba:	2681                	sext.w	a3,a3
ffffffffc02015bc:	30e69e63          	bne	a3,a4,ffffffffc02018d8 <swap_init+0x55c>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc02015c0:	6691                	lui	a3,0x4
ffffffffc02015c2:	4635                	li	a2,13
ffffffffc02015c4:	00c68023          	sb	a2,0(a3) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc02015c8:	4398                	lw	a4,0(a5)
ffffffffc02015ca:	2701                	sext.w	a4,a4
ffffffffc02015cc:	37871663          	bne	a4,s8,ffffffffc0201938 <swap_init+0x5bc>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc02015d0:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc02015d4:	439c                	lw	a5,0(a5)
ffffffffc02015d6:	2781                	sext.w	a5,a5
ffffffffc02015d8:	38e79063          	bne	a5,a4,ffffffffc0201958 <swap_init+0x5dc>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc02015dc:	481c                	lw	a5,16(s0)
ffffffffc02015de:	3e079d63          	bnez	a5,ffffffffc02019d8 <swap_init+0x65c>
ffffffffc02015e2:	00015797          	auipc	a5,0x15
ffffffffc02015e6:	f1e78793          	addi	a5,a5,-226 # ffffffffc0216500 <swap_in_seq_no>
ffffffffc02015ea:	00015717          	auipc	a4,0x15
ffffffffc02015ee:	f3e70713          	addi	a4,a4,-194 # ffffffffc0216528 <swap_out_seq_no>
ffffffffc02015f2:	00015617          	auipc	a2,0x15
ffffffffc02015f6:	f3660613          	addi	a2,a2,-202 # ffffffffc0216528 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc02015fa:	56fd                	li	a3,-1
ffffffffc02015fc:	c394                	sw	a3,0(a5)
ffffffffc02015fe:	c314                	sw	a3,0(a4)
ffffffffc0201600:	0791                	addi	a5,a5,4
ffffffffc0201602:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0201604:	fef61ce3          	bne	a2,a5,ffffffffc02015fc <swap_init+0x280>
ffffffffc0201608:	00015697          	auipc	a3,0x15
ffffffffc020160c:	f8068693          	addi	a3,a3,-128 # ffffffffc0216588 <check_ptep>
ffffffffc0201610:	00015817          	auipc	a6,0x15
ffffffffc0201614:	ed080813          	addi	a6,a6,-304 # ffffffffc02164e0 <check_rp>
ffffffffc0201618:	6d05                	lui	s10,0x1
    if (PPN(pa) >= npage) {
ffffffffc020161a:	00015c97          	auipc	s9,0x15
ffffffffc020161e:	e8ec8c93          	addi	s9,s9,-370 # ffffffffc02164a8 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0201622:	00006d97          	auipc	s11,0x6
ffffffffc0201626:	bfed8d93          	addi	s11,s11,-1026 # ffffffffc0207220 <nbase>
ffffffffc020162a:	00015c17          	auipc	s8,0x15
ffffffffc020162e:	fbec0c13          	addi	s8,s8,-66 # ffffffffc02165e8 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0201632:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0201636:	4601                	li	a2,0
ffffffffc0201638:	85ea                	mv	a1,s10
ffffffffc020163a:	855a                	mv	a0,s6
ffffffffc020163c:	e842                	sd	a6,16(sp)
         check_ptep[i]=0;
ffffffffc020163e:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0201640:	2d3010ef          	jal	ra,ffffffffc0203112 <get_pte>
ffffffffc0201644:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0201646:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0201648:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc020164a:	1e050b63          	beqz	a0,ffffffffc0201840 <swap_init+0x4c4>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc020164e:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201650:	0017f613          	andi	a2,a5,1
ffffffffc0201654:	18060a63          	beqz	a2,ffffffffc02017e8 <swap_init+0x46c>
    if (PPN(pa) >= npage) {
ffffffffc0201658:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc020165c:	078a                	slli	a5,a5,0x2
ffffffffc020165e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201660:	14c7f863          	bleu	a2,a5,ffffffffc02017b0 <swap_init+0x434>
    return &pages[PPN(pa) - nbase];
ffffffffc0201664:	000db703          	ld	a4,0(s11)
ffffffffc0201668:	000c3603          	ld	a2,0(s8)
ffffffffc020166c:	00083583          	ld	a1,0(a6)
ffffffffc0201670:	8f99                	sub	a5,a5,a4
ffffffffc0201672:	079a                	slli	a5,a5,0x6
ffffffffc0201674:	e43a                	sd	a4,8(sp)
ffffffffc0201676:	97b2                	add	a5,a5,a2
ffffffffc0201678:	14f59863          	bne	a1,a5,ffffffffc02017c8 <swap_init+0x44c>
ffffffffc020167c:	6785                	lui	a5,0x1
ffffffffc020167e:	9d3e                	add	s10,s10,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201680:	6795                	lui	a5,0x5
ffffffffc0201682:	06a1                	addi	a3,a3,8
ffffffffc0201684:	0821                	addi	a6,a6,8
ffffffffc0201686:	fafd16e3          	bne	s10,a5,ffffffffc0201632 <swap_init+0x2b6>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc020168a:	00005517          	auipc	a0,0x5
ffffffffc020168e:	8c650513          	addi	a0,a0,-1850 # ffffffffc0205f50 <commands+0xed0>
ffffffffc0201692:	a3ffe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    int ret = sm->check_swap();
ffffffffc0201696:	00015797          	auipc	a5,0x15
ffffffffc020169a:	df278793          	addi	a5,a5,-526 # ffffffffc0216488 <sm>
ffffffffc020169e:	639c                	ld	a5,0(a5)
ffffffffc02016a0:	7f9c                	ld	a5,56(a5)
ffffffffc02016a2:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc02016a4:	40051663          	bnez	a0,ffffffffc0201ab0 <swap_init+0x734>

     nr_free = nr_free_store;
ffffffffc02016a8:	77a2                	ld	a5,40(sp)
ffffffffc02016aa:	00015717          	auipc	a4,0x15
ffffffffc02016ae:	f0f72f23          	sw	a5,-226(a4) # ffffffffc02165c8 <free_area+0x10>
     free_list = free_list_store;
ffffffffc02016b2:	67e2                	ld	a5,24(sp)
ffffffffc02016b4:	00015717          	auipc	a4,0x15
ffffffffc02016b8:	f0f73223          	sd	a5,-252(a4) # ffffffffc02165b8 <free_area>
ffffffffc02016bc:	7782                	ld	a5,32(sp)
ffffffffc02016be:	00015717          	auipc	a4,0x15
ffffffffc02016c2:	f0f73123          	sd	a5,-254(a4) # ffffffffc02165c0 <free_area+0x8>

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc02016c6:	0009b503          	ld	a0,0(s3)
ffffffffc02016ca:	4585                	li	a1,1
ffffffffc02016cc:	09a1                	addi	s3,s3,8
ffffffffc02016ce:	1bf010ef          	jal	ra,ffffffffc020308c <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02016d2:	ff499ae3          	bne	s3,s4,ffffffffc02016c6 <swap_init+0x34a>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc02016d6:	855e                	mv	a0,s7
ffffffffc02016d8:	e4cff0ef          	jal	ra,ffffffffc0200d24 <mm_destroy>

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc02016dc:	00015797          	auipc	a5,0x15
ffffffffc02016e0:	dc478793          	addi	a5,a5,-572 # ffffffffc02164a0 <boot_pgdir>
ffffffffc02016e4:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc02016e6:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc02016ea:	6394                	ld	a3,0(a5)
ffffffffc02016ec:	068a                	slli	a3,a3,0x2
ffffffffc02016ee:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc02016f0:	0ce6f063          	bleu	a4,a3,ffffffffc02017b0 <swap_init+0x434>
    return &pages[PPN(pa) - nbase];
ffffffffc02016f4:	67a2                	ld	a5,8(sp)
ffffffffc02016f6:	000c3503          	ld	a0,0(s8)
ffffffffc02016fa:	8e9d                	sub	a3,a3,a5
ffffffffc02016fc:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc02016fe:	8699                	srai	a3,a3,0x6
ffffffffc0201700:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0201702:	57fd                	li	a5,-1
ffffffffc0201704:	83b1                	srli	a5,a5,0xc
ffffffffc0201706:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0201708:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020170a:	2ee7f763          	bleu	a4,a5,ffffffffc02019f8 <swap_init+0x67c>
     free_page(pde2page(pd0[0]));
ffffffffc020170e:	00015797          	auipc	a5,0x15
ffffffffc0201712:	eca78793          	addi	a5,a5,-310 # ffffffffc02165d8 <va_pa_offset>
ffffffffc0201716:	639c                	ld	a5,0(a5)
ffffffffc0201718:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc020171a:	629c                	ld	a5,0(a3)
ffffffffc020171c:	078a                	slli	a5,a5,0x2
ffffffffc020171e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201720:	08e7f863          	bleu	a4,a5,ffffffffc02017b0 <swap_init+0x434>
    return &pages[PPN(pa) - nbase];
ffffffffc0201724:	69a2                	ld	s3,8(sp)
ffffffffc0201726:	4585                	li	a1,1
ffffffffc0201728:	413787b3          	sub	a5,a5,s3
ffffffffc020172c:	079a                	slli	a5,a5,0x6
ffffffffc020172e:	953e                	add	a0,a0,a5
ffffffffc0201730:	15d010ef          	jal	ra,ffffffffc020308c <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201734:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0201738:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc020173c:	078a                	slli	a5,a5,0x2
ffffffffc020173e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201740:	06e7f863          	bleu	a4,a5,ffffffffc02017b0 <swap_init+0x434>
    return &pages[PPN(pa) - nbase];
ffffffffc0201744:	000c3503          	ld	a0,0(s8)
ffffffffc0201748:	413787b3          	sub	a5,a5,s3
ffffffffc020174c:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc020174e:	4585                	li	a1,1
ffffffffc0201750:	953e                	add	a0,a0,a5
ffffffffc0201752:	13b010ef          	jal	ra,ffffffffc020308c <free_pages>
     pgdir[0] = 0;
ffffffffc0201756:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc020175a:	12000073          	sfence.vma
    return listelm->next;
ffffffffc020175e:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201760:	00878963          	beq	a5,s0,ffffffffc0201772 <swap_init+0x3f6>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0201764:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201768:	679c                	ld	a5,8(a5)
ffffffffc020176a:	397d                	addiw	s2,s2,-1
ffffffffc020176c:	9c99                	subw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc020176e:	fe879be3          	bne	a5,s0,ffffffffc0201764 <swap_init+0x3e8>
     }
     assert(count==0);
ffffffffc0201772:	28091f63          	bnez	s2,ffffffffc0201a10 <swap_init+0x694>
     assert(total==0);
ffffffffc0201776:	2a049d63          	bnez	s1,ffffffffc0201a30 <swap_init+0x6b4>

     cprintf("check_swap() succeeded!\n");
ffffffffc020177a:	00005517          	auipc	a0,0x5
ffffffffc020177e:	82650513          	addi	a0,a0,-2010 # ffffffffc0205fa0 <commands+0xf20>
ffffffffc0201782:	94ffe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc0201786:	b199                	j	ffffffffc02013cc <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc0201788:	4481                	li	s1,0
ffffffffc020178a:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc020178c:	4981                	li	s3,0
ffffffffc020178e:	b96d                	j	ffffffffc0201448 <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc0201790:	00004697          	auipc	a3,0x4
ffffffffc0201794:	59868693          	addi	a3,a3,1432 # ffffffffc0205d28 <commands+0xca8>
ffffffffc0201798:	00004617          	auipc	a2,0x4
ffffffffc020179c:	14860613          	addi	a2,a2,328 # ffffffffc02058e0 <commands+0x860>
ffffffffc02017a0:	0bd00593          	li	a1,189
ffffffffc02017a4:	00004517          	auipc	a0,0x4
ffffffffc02017a8:	55c50513          	addi	a0,a0,1372 # ffffffffc0205d00 <commands+0xc80>
ffffffffc02017ac:	a2bfe0ef          	jal	ra,ffffffffc02001d6 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02017b0:	00004617          	auipc	a2,0x4
ffffffffc02017b4:	46860613          	addi	a2,a2,1128 # ffffffffc0205c18 <commands+0xb98>
ffffffffc02017b8:	06200593          	li	a1,98
ffffffffc02017bc:	00004517          	auipc	a0,0x4
ffffffffc02017c0:	47c50513          	addi	a0,a0,1148 # ffffffffc0205c38 <commands+0xbb8>
ffffffffc02017c4:	a13fe0ef          	jal	ra,ffffffffc02001d6 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc02017c8:	00004697          	auipc	a3,0x4
ffffffffc02017cc:	76068693          	addi	a3,a3,1888 # ffffffffc0205f28 <commands+0xea8>
ffffffffc02017d0:	00004617          	auipc	a2,0x4
ffffffffc02017d4:	11060613          	addi	a2,a2,272 # ffffffffc02058e0 <commands+0x860>
ffffffffc02017d8:	0fd00593          	li	a1,253
ffffffffc02017dc:	00004517          	auipc	a0,0x4
ffffffffc02017e0:	52450513          	addi	a0,a0,1316 # ffffffffc0205d00 <commands+0xc80>
ffffffffc02017e4:	9f3fe0ef          	jal	ra,ffffffffc02001d6 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02017e8:	00004617          	auipc	a2,0x4
ffffffffc02017ec:	71860613          	addi	a2,a2,1816 # ffffffffc0205f00 <commands+0xe80>
ffffffffc02017f0:	07400593          	li	a1,116
ffffffffc02017f4:	00004517          	auipc	a0,0x4
ffffffffc02017f8:	44450513          	addi	a0,a0,1092 # ffffffffc0205c38 <commands+0xbb8>
ffffffffc02017fc:	9dbfe0ef          	jal	ra,ffffffffc02001d6 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0201800:	00004697          	auipc	a3,0x4
ffffffffc0201804:	62868693          	addi	a3,a3,1576 # ffffffffc0205e28 <commands+0xda8>
ffffffffc0201808:	00004617          	auipc	a2,0x4
ffffffffc020180c:	0d860613          	addi	a2,a2,216 # ffffffffc02058e0 <commands+0x860>
ffffffffc0201810:	0de00593          	li	a1,222
ffffffffc0201814:	00004517          	auipc	a0,0x4
ffffffffc0201818:	4ec50513          	addi	a0,a0,1260 # ffffffffc0205d00 <commands+0xc80>
ffffffffc020181c:	9bbfe0ef          	jal	ra,ffffffffc02001d6 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0201820:	00004697          	auipc	a3,0x4
ffffffffc0201824:	5f068693          	addi	a3,a3,1520 # ffffffffc0205e10 <commands+0xd90>
ffffffffc0201828:	00004617          	auipc	a2,0x4
ffffffffc020182c:	0b860613          	addi	a2,a2,184 # ffffffffc02058e0 <commands+0x860>
ffffffffc0201830:	0dd00593          	li	a1,221
ffffffffc0201834:	00004517          	auipc	a0,0x4
ffffffffc0201838:	4cc50513          	addi	a0,a0,1228 # ffffffffc0205d00 <commands+0xc80>
ffffffffc020183c:	99bfe0ef          	jal	ra,ffffffffc02001d6 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0201840:	00004697          	auipc	a3,0x4
ffffffffc0201844:	6a868693          	addi	a3,a3,1704 # ffffffffc0205ee8 <commands+0xe68>
ffffffffc0201848:	00004617          	auipc	a2,0x4
ffffffffc020184c:	09860613          	addi	a2,a2,152 # ffffffffc02058e0 <commands+0x860>
ffffffffc0201850:	0fc00593          	li	a1,252
ffffffffc0201854:	00004517          	auipc	a0,0x4
ffffffffc0201858:	4ac50513          	addi	a0,a0,1196 # ffffffffc0205d00 <commands+0xc80>
ffffffffc020185c:	97bfe0ef          	jal	ra,ffffffffc02001d6 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0201860:	00004617          	auipc	a2,0x4
ffffffffc0201864:	48060613          	addi	a2,a2,1152 # ffffffffc0205ce0 <commands+0xc60>
ffffffffc0201868:	02a00593          	li	a1,42
ffffffffc020186c:	00004517          	auipc	a0,0x4
ffffffffc0201870:	49450513          	addi	a0,a0,1172 # ffffffffc0205d00 <commands+0xc80>
ffffffffc0201874:	963fe0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert(pgfault_num==2);
ffffffffc0201878:	00004697          	auipc	a3,0x4
ffffffffc020187c:	63068693          	addi	a3,a3,1584 # ffffffffc0205ea8 <commands+0xe28>
ffffffffc0201880:	00004617          	auipc	a2,0x4
ffffffffc0201884:	06060613          	addi	a2,a2,96 # ffffffffc02058e0 <commands+0x860>
ffffffffc0201888:	09800593          	li	a1,152
ffffffffc020188c:	00004517          	auipc	a0,0x4
ffffffffc0201890:	47450513          	addi	a0,a0,1140 # ffffffffc0205d00 <commands+0xc80>
ffffffffc0201894:	943fe0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert(pgfault_num==2);
ffffffffc0201898:	00004697          	auipc	a3,0x4
ffffffffc020189c:	61068693          	addi	a3,a3,1552 # ffffffffc0205ea8 <commands+0xe28>
ffffffffc02018a0:	00004617          	auipc	a2,0x4
ffffffffc02018a4:	04060613          	addi	a2,a2,64 # ffffffffc02058e0 <commands+0x860>
ffffffffc02018a8:	09a00593          	li	a1,154
ffffffffc02018ac:	00004517          	auipc	a0,0x4
ffffffffc02018b0:	45450513          	addi	a0,a0,1108 # ffffffffc0205d00 <commands+0xc80>
ffffffffc02018b4:	923fe0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert(pgfault_num==3);
ffffffffc02018b8:	00004697          	auipc	a3,0x4
ffffffffc02018bc:	60068693          	addi	a3,a3,1536 # ffffffffc0205eb8 <commands+0xe38>
ffffffffc02018c0:	00004617          	auipc	a2,0x4
ffffffffc02018c4:	02060613          	addi	a2,a2,32 # ffffffffc02058e0 <commands+0x860>
ffffffffc02018c8:	09c00593          	li	a1,156
ffffffffc02018cc:	00004517          	auipc	a0,0x4
ffffffffc02018d0:	43450513          	addi	a0,a0,1076 # ffffffffc0205d00 <commands+0xc80>
ffffffffc02018d4:	903fe0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert(pgfault_num==3);
ffffffffc02018d8:	00004697          	auipc	a3,0x4
ffffffffc02018dc:	5e068693          	addi	a3,a3,1504 # ffffffffc0205eb8 <commands+0xe38>
ffffffffc02018e0:	00004617          	auipc	a2,0x4
ffffffffc02018e4:	00060613          	mv	a2,a2
ffffffffc02018e8:	09e00593          	li	a1,158
ffffffffc02018ec:	00004517          	auipc	a0,0x4
ffffffffc02018f0:	41450513          	addi	a0,a0,1044 # ffffffffc0205d00 <commands+0xc80>
ffffffffc02018f4:	8e3fe0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert(pgfault_num==1);
ffffffffc02018f8:	00004697          	auipc	a3,0x4
ffffffffc02018fc:	5a068693          	addi	a3,a3,1440 # ffffffffc0205e98 <commands+0xe18>
ffffffffc0201900:	00004617          	auipc	a2,0x4
ffffffffc0201904:	fe060613          	addi	a2,a2,-32 # ffffffffc02058e0 <commands+0x860>
ffffffffc0201908:	09400593          	li	a1,148
ffffffffc020190c:	00004517          	auipc	a0,0x4
ffffffffc0201910:	3f450513          	addi	a0,a0,1012 # ffffffffc0205d00 <commands+0xc80>
ffffffffc0201914:	8c3fe0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert(pgfault_num==1);
ffffffffc0201918:	00004697          	auipc	a3,0x4
ffffffffc020191c:	58068693          	addi	a3,a3,1408 # ffffffffc0205e98 <commands+0xe18>
ffffffffc0201920:	00004617          	auipc	a2,0x4
ffffffffc0201924:	fc060613          	addi	a2,a2,-64 # ffffffffc02058e0 <commands+0x860>
ffffffffc0201928:	09600593          	li	a1,150
ffffffffc020192c:	00004517          	auipc	a0,0x4
ffffffffc0201930:	3d450513          	addi	a0,a0,980 # ffffffffc0205d00 <commands+0xc80>
ffffffffc0201934:	8a3fe0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert(pgfault_num==4);
ffffffffc0201938:	00004697          	auipc	a3,0x4
ffffffffc020193c:	59068693          	addi	a3,a3,1424 # ffffffffc0205ec8 <commands+0xe48>
ffffffffc0201940:	00004617          	auipc	a2,0x4
ffffffffc0201944:	fa060613          	addi	a2,a2,-96 # ffffffffc02058e0 <commands+0x860>
ffffffffc0201948:	0a000593          	li	a1,160
ffffffffc020194c:	00004517          	auipc	a0,0x4
ffffffffc0201950:	3b450513          	addi	a0,a0,948 # ffffffffc0205d00 <commands+0xc80>
ffffffffc0201954:	883fe0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert(pgfault_num==4);
ffffffffc0201958:	00004697          	auipc	a3,0x4
ffffffffc020195c:	57068693          	addi	a3,a3,1392 # ffffffffc0205ec8 <commands+0xe48>
ffffffffc0201960:	00004617          	auipc	a2,0x4
ffffffffc0201964:	f8060613          	addi	a2,a2,-128 # ffffffffc02058e0 <commands+0x860>
ffffffffc0201968:	0a200593          	li	a1,162
ffffffffc020196c:	00004517          	auipc	a0,0x4
ffffffffc0201970:	39450513          	addi	a0,a0,916 # ffffffffc0205d00 <commands+0xc80>
ffffffffc0201974:	863fe0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0201978:	00004697          	auipc	a3,0x4
ffffffffc020197c:	26068693          	addi	a3,a3,608 # ffffffffc0205bd8 <commands+0xb58>
ffffffffc0201980:	00004617          	auipc	a2,0x4
ffffffffc0201984:	f6060613          	addi	a2,a2,-160 # ffffffffc02058e0 <commands+0x860>
ffffffffc0201988:	0cd00593          	li	a1,205
ffffffffc020198c:	00004517          	auipc	a0,0x4
ffffffffc0201990:	37450513          	addi	a0,a0,884 # ffffffffc0205d00 <commands+0xc80>
ffffffffc0201994:	843fe0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert(vma != NULL);
ffffffffc0201998:	00004697          	auipc	a3,0x4
ffffffffc020199c:	33868693          	addi	a3,a3,824 # ffffffffc0205cd0 <commands+0xc50>
ffffffffc02019a0:	00004617          	auipc	a2,0x4
ffffffffc02019a4:	f4060613          	addi	a2,a2,-192 # ffffffffc02058e0 <commands+0x860>
ffffffffc02019a8:	0d000593          	li	a1,208
ffffffffc02019ac:	00004517          	auipc	a0,0x4
ffffffffc02019b0:	35450513          	addi	a0,a0,852 # ffffffffc0205d00 <commands+0xc80>
ffffffffc02019b4:	823fe0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc02019b8:	00004697          	auipc	a3,0x4
ffffffffc02019bc:	41868693          	addi	a3,a3,1048 # ffffffffc0205dd0 <commands+0xd50>
ffffffffc02019c0:	00004617          	auipc	a2,0x4
ffffffffc02019c4:	f2060613          	addi	a2,a2,-224 # ffffffffc02058e0 <commands+0x860>
ffffffffc02019c8:	0d800593          	li	a1,216
ffffffffc02019cc:	00004517          	auipc	a0,0x4
ffffffffc02019d0:	33450513          	addi	a0,a0,820 # ffffffffc0205d00 <commands+0xc80>
ffffffffc02019d4:	803fe0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert( nr_free == 0);         
ffffffffc02019d8:	00004697          	auipc	a3,0x4
ffffffffc02019dc:	50068693          	addi	a3,a3,1280 # ffffffffc0205ed8 <commands+0xe58>
ffffffffc02019e0:	00004617          	auipc	a2,0x4
ffffffffc02019e4:	f0060613          	addi	a2,a2,-256 # ffffffffc02058e0 <commands+0x860>
ffffffffc02019e8:	0f400593          	li	a1,244
ffffffffc02019ec:	00004517          	auipc	a0,0x4
ffffffffc02019f0:	31450513          	addi	a0,a0,788 # ffffffffc0205d00 <commands+0xc80>
ffffffffc02019f4:	fe2fe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    return KADDR(page2pa(page));
ffffffffc02019f8:	00004617          	auipc	a2,0x4
ffffffffc02019fc:	25060613          	addi	a2,a2,592 # ffffffffc0205c48 <commands+0xbc8>
ffffffffc0201a00:	06900593          	li	a1,105
ffffffffc0201a04:	00004517          	auipc	a0,0x4
ffffffffc0201a08:	23450513          	addi	a0,a0,564 # ffffffffc0205c38 <commands+0xbb8>
ffffffffc0201a0c:	fcafe0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert(count==0);
ffffffffc0201a10:	00004697          	auipc	a3,0x4
ffffffffc0201a14:	57068693          	addi	a3,a3,1392 # ffffffffc0205f80 <commands+0xf00>
ffffffffc0201a18:	00004617          	auipc	a2,0x4
ffffffffc0201a1c:	ec860613          	addi	a2,a2,-312 # ffffffffc02058e0 <commands+0x860>
ffffffffc0201a20:	11c00593          	li	a1,284
ffffffffc0201a24:	00004517          	auipc	a0,0x4
ffffffffc0201a28:	2dc50513          	addi	a0,a0,732 # ffffffffc0205d00 <commands+0xc80>
ffffffffc0201a2c:	faafe0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert(total==0);
ffffffffc0201a30:	00004697          	auipc	a3,0x4
ffffffffc0201a34:	56068693          	addi	a3,a3,1376 # ffffffffc0205f90 <commands+0xf10>
ffffffffc0201a38:	00004617          	auipc	a2,0x4
ffffffffc0201a3c:	ea860613          	addi	a2,a2,-344 # ffffffffc02058e0 <commands+0x860>
ffffffffc0201a40:	11d00593          	li	a1,285
ffffffffc0201a44:	00004517          	auipc	a0,0x4
ffffffffc0201a48:	2bc50513          	addi	a0,a0,700 # ffffffffc0205d00 <commands+0xc80>
ffffffffc0201a4c:	f8afe0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0201a50:	00004697          	auipc	a3,0x4
ffffffffc0201a54:	3f868693          	addi	a3,a3,1016 # ffffffffc0205e48 <commands+0xdc8>
ffffffffc0201a58:	00004617          	auipc	a2,0x4
ffffffffc0201a5c:	e8860613          	addi	a2,a2,-376 # ffffffffc02058e0 <commands+0x860>
ffffffffc0201a60:	0eb00593          	li	a1,235
ffffffffc0201a64:	00004517          	auipc	a0,0x4
ffffffffc0201a68:	29c50513          	addi	a0,a0,668 # ffffffffc0205d00 <commands+0xc80>
ffffffffc0201a6c:	f6afe0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert(mm != NULL);
ffffffffc0201a70:	00004697          	auipc	a3,0x4
ffffffffc0201a74:	fe068693          	addi	a3,a3,-32 # ffffffffc0205a50 <commands+0x9d0>
ffffffffc0201a78:	00004617          	auipc	a2,0x4
ffffffffc0201a7c:	e6860613          	addi	a2,a2,-408 # ffffffffc02058e0 <commands+0x860>
ffffffffc0201a80:	0c500593          	li	a1,197
ffffffffc0201a84:	00004517          	auipc	a0,0x4
ffffffffc0201a88:	27c50513          	addi	a0,a0,636 # ffffffffc0205d00 <commands+0xc80>
ffffffffc0201a8c:	f4afe0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0201a90:	00004697          	auipc	a3,0x4
ffffffffc0201a94:	2f068693          	addi	a3,a3,752 # ffffffffc0205d80 <commands+0xd00>
ffffffffc0201a98:	00004617          	auipc	a2,0x4
ffffffffc0201a9c:	e4860613          	addi	a2,a2,-440 # ffffffffc02058e0 <commands+0x860>
ffffffffc0201aa0:	0c800593          	li	a1,200
ffffffffc0201aa4:	00004517          	auipc	a0,0x4
ffffffffc0201aa8:	25c50513          	addi	a0,a0,604 # ffffffffc0205d00 <commands+0xc80>
ffffffffc0201aac:	f2afe0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert(ret==0);
ffffffffc0201ab0:	00004697          	auipc	a3,0x4
ffffffffc0201ab4:	4c868693          	addi	a3,a3,1224 # ffffffffc0205f78 <commands+0xef8>
ffffffffc0201ab8:	00004617          	auipc	a2,0x4
ffffffffc0201abc:	e2860613          	addi	a2,a2,-472 # ffffffffc02058e0 <commands+0x860>
ffffffffc0201ac0:	10300593          	li	a1,259
ffffffffc0201ac4:	00004517          	auipc	a0,0x4
ffffffffc0201ac8:	23c50513          	addi	a0,a0,572 # ffffffffc0205d00 <commands+0xc80>
ffffffffc0201acc:	f0afe0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert(total == nr_free_pages());
ffffffffc0201ad0:	00004697          	auipc	a3,0x4
ffffffffc0201ad4:	26868693          	addi	a3,a3,616 # ffffffffc0205d38 <commands+0xcb8>
ffffffffc0201ad8:	00004617          	auipc	a2,0x4
ffffffffc0201adc:	e0860613          	addi	a2,a2,-504 # ffffffffc02058e0 <commands+0x860>
ffffffffc0201ae0:	0c000593          	li	a1,192
ffffffffc0201ae4:	00004517          	auipc	a0,0x4
ffffffffc0201ae8:	21c50513          	addi	a0,a0,540 # ffffffffc0205d00 <commands+0xc80>
ffffffffc0201aec:	eeafe0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc0201af0 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0201af0:	00015797          	auipc	a5,0x15
ffffffffc0201af4:	99878793          	addi	a5,a5,-1640 # ffffffffc0216488 <sm>
ffffffffc0201af8:	639c                	ld	a5,0(a5)
ffffffffc0201afa:	0107b303          	ld	t1,16(a5)
ffffffffc0201afe:	8302                	jr	t1

ffffffffc0201b00 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0201b00:	00015797          	auipc	a5,0x15
ffffffffc0201b04:	98878793          	addi	a5,a5,-1656 # ffffffffc0216488 <sm>
ffffffffc0201b08:	639c                	ld	a5,0(a5)
ffffffffc0201b0a:	0207b303          	ld	t1,32(a5)
ffffffffc0201b0e:	8302                	jr	t1

ffffffffc0201b10 <swap_out>:
{
ffffffffc0201b10:	711d                	addi	sp,sp,-96
ffffffffc0201b12:	ec86                	sd	ra,88(sp)
ffffffffc0201b14:	e8a2                	sd	s0,80(sp)
ffffffffc0201b16:	e4a6                	sd	s1,72(sp)
ffffffffc0201b18:	e0ca                	sd	s2,64(sp)
ffffffffc0201b1a:	fc4e                	sd	s3,56(sp)
ffffffffc0201b1c:	f852                	sd	s4,48(sp)
ffffffffc0201b1e:	f456                	sd	s5,40(sp)
ffffffffc0201b20:	f05a                	sd	s6,32(sp)
ffffffffc0201b22:	ec5e                	sd	s7,24(sp)
ffffffffc0201b24:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0201b26:	cde9                	beqz	a1,ffffffffc0201c00 <swap_out+0xf0>
ffffffffc0201b28:	8ab2                	mv	s5,a2
ffffffffc0201b2a:	892a                	mv	s2,a0
ffffffffc0201b2c:	8a2e                	mv	s4,a1
ffffffffc0201b2e:	4401                	li	s0,0
ffffffffc0201b30:	00015997          	auipc	s3,0x15
ffffffffc0201b34:	95898993          	addi	s3,s3,-1704 # ffffffffc0216488 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0201b38:	00004b17          	auipc	s6,0x4
ffffffffc0201b3c:	4e8b0b13          	addi	s6,s6,1256 # ffffffffc0206020 <commands+0xfa0>
                    cprintf("SWAP: failed to save\n");
ffffffffc0201b40:	00004b97          	auipc	s7,0x4
ffffffffc0201b44:	4c8b8b93          	addi	s7,s7,1224 # ffffffffc0206008 <commands+0xf88>
ffffffffc0201b48:	a825                	j	ffffffffc0201b80 <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0201b4a:	67a2                	ld	a5,8(sp)
ffffffffc0201b4c:	8626                	mv	a2,s1
ffffffffc0201b4e:	85a2                	mv	a1,s0
ffffffffc0201b50:	7f94                	ld	a3,56(a5)
ffffffffc0201b52:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0201b54:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0201b56:	82b1                	srli	a3,a3,0xc
ffffffffc0201b58:	0685                	addi	a3,a3,1
ffffffffc0201b5a:	d76fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0201b5e:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0201b60:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0201b62:	7d1c                	ld	a5,56(a0)
ffffffffc0201b64:	83b1                	srli	a5,a5,0xc
ffffffffc0201b66:	0785                	addi	a5,a5,1
ffffffffc0201b68:	07a2                	slli	a5,a5,0x8
ffffffffc0201b6a:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0201b6e:	51e010ef          	jal	ra,ffffffffc020308c <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0201b72:	01893503          	ld	a0,24(s2)
ffffffffc0201b76:	85a6                	mv	a1,s1
ffffffffc0201b78:	38a020ef          	jal	ra,ffffffffc0203f02 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0201b7c:	048a0d63          	beq	s4,s0,ffffffffc0201bd6 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0201b80:	0009b783          	ld	a5,0(s3)
ffffffffc0201b84:	8656                	mv	a2,s5
ffffffffc0201b86:	002c                	addi	a1,sp,8
ffffffffc0201b88:	7b9c                	ld	a5,48(a5)
ffffffffc0201b8a:	854a                	mv	a0,s2
ffffffffc0201b8c:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0201b8e:	e12d                	bnez	a0,ffffffffc0201bf0 <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0201b90:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0201b92:	01893503          	ld	a0,24(s2)
ffffffffc0201b96:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0201b98:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0201b9a:	85a6                	mv	a1,s1
ffffffffc0201b9c:	576010ef          	jal	ra,ffffffffc0203112 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0201ba0:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0201ba2:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0201ba4:	8b85                	andi	a5,a5,1
ffffffffc0201ba6:	cfb9                	beqz	a5,ffffffffc0201c04 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0201ba8:	65a2                	ld	a1,8(sp)
ffffffffc0201baa:	7d9c                	ld	a5,56(a1)
ffffffffc0201bac:	83b1                	srli	a5,a5,0xc
ffffffffc0201bae:	00178513          	addi	a0,a5,1
ffffffffc0201bb2:	0522                	slli	a0,a0,0x8
ffffffffc0201bb4:	41e020ef          	jal	ra,ffffffffc0203fd2 <swapfs_write>
ffffffffc0201bb8:	d949                	beqz	a0,ffffffffc0201b4a <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0201bba:	855e                	mv	a0,s7
ffffffffc0201bbc:	d14fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0201bc0:	0009b783          	ld	a5,0(s3)
ffffffffc0201bc4:	6622                	ld	a2,8(sp)
ffffffffc0201bc6:	4681                	li	a3,0
ffffffffc0201bc8:	739c                	ld	a5,32(a5)
ffffffffc0201bca:	85a6                	mv	a1,s1
ffffffffc0201bcc:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0201bce:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0201bd0:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0201bd2:	fa8a17e3          	bne	s4,s0,ffffffffc0201b80 <swap_out+0x70>
}
ffffffffc0201bd6:	8522                	mv	a0,s0
ffffffffc0201bd8:	60e6                	ld	ra,88(sp)
ffffffffc0201bda:	6446                	ld	s0,80(sp)
ffffffffc0201bdc:	64a6                	ld	s1,72(sp)
ffffffffc0201bde:	6906                	ld	s2,64(sp)
ffffffffc0201be0:	79e2                	ld	s3,56(sp)
ffffffffc0201be2:	7a42                	ld	s4,48(sp)
ffffffffc0201be4:	7aa2                	ld	s5,40(sp)
ffffffffc0201be6:	7b02                	ld	s6,32(sp)
ffffffffc0201be8:	6be2                	ld	s7,24(sp)
ffffffffc0201bea:	6c42                	ld	s8,16(sp)
ffffffffc0201bec:	6125                	addi	sp,sp,96
ffffffffc0201bee:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0201bf0:	85a2                	mv	a1,s0
ffffffffc0201bf2:	00004517          	auipc	a0,0x4
ffffffffc0201bf6:	3ce50513          	addi	a0,a0,974 # ffffffffc0205fc0 <commands+0xf40>
ffffffffc0201bfa:	cd6fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
                  break;
ffffffffc0201bfe:	bfe1                	j	ffffffffc0201bd6 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0201c00:	4401                	li	s0,0
ffffffffc0201c02:	bfd1                	j	ffffffffc0201bd6 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0201c04:	00004697          	auipc	a3,0x4
ffffffffc0201c08:	3ec68693          	addi	a3,a3,1004 # ffffffffc0205ff0 <commands+0xf70>
ffffffffc0201c0c:	00004617          	auipc	a2,0x4
ffffffffc0201c10:	cd460613          	addi	a2,a2,-812 # ffffffffc02058e0 <commands+0x860>
ffffffffc0201c14:	06900593          	li	a1,105
ffffffffc0201c18:	00004517          	auipc	a0,0x4
ffffffffc0201c1c:	0e850513          	addi	a0,a0,232 # ffffffffc0205d00 <commands+0xc80>
ffffffffc0201c20:	db6fe0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc0201c24 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc0201c24:	c125                	beqz	a0,ffffffffc0201c84 <slob_free+0x60>
		return;

	if (size)
ffffffffc0201c26:	e1a5                	bnez	a1,ffffffffc0201c86 <slob_free+0x62>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c28:	100027f3          	csrr	a5,sstatus
ffffffffc0201c2c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201c2e:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c30:	e3bd                	bnez	a5,ffffffffc0201c96 <slob_free+0x72>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201c32:	00009797          	auipc	a5,0x9
ffffffffc0201c36:	41e78793          	addi	a5,a5,1054 # ffffffffc020b050 <slobfree>
ffffffffc0201c3a:	639c                	ld	a5,0(a5)
		if (cur >= cur->next && (b > cur || b < cur->next))// 环形链表
ffffffffc0201c3c:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201c3e:	00a7fa63          	bleu	a0,a5,ffffffffc0201c52 <slob_free+0x2e>
ffffffffc0201c42:	00e56c63          	bltu	a0,a4,ffffffffc0201c5a <slob_free+0x36>
		if (cur >= cur->next && (b > cur || b < cur->next))// 环形链表
ffffffffc0201c46:	00e7fa63          	bleu	a4,a5,ffffffffc0201c5a <slob_free+0x36>
    return 0;
ffffffffc0201c4a:	87ba                	mv	a5,a4
ffffffffc0201c4c:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201c4e:	fea7eae3          	bltu	a5,a0,ffffffffc0201c42 <slob_free+0x1e>
		if (cur >= cur->next && (b > cur || b < cur->next))// 环形链表
ffffffffc0201c52:	fee7ece3          	bltu	a5,a4,ffffffffc0201c4a <slob_free+0x26>
ffffffffc0201c56:	fee57ae3          	bleu	a4,a0,ffffffffc0201c4a <slob_free+0x26>
			break;

	if (b + b->units == cur->next) {// 相邻则合并，不相邻就直接连接
ffffffffc0201c5a:	4110                	lw	a2,0(a0)
ffffffffc0201c5c:	00461693          	slli	a3,a2,0x4
ffffffffc0201c60:	96aa                	add	a3,a3,a0
ffffffffc0201c62:	08d70b63          	beq	a4,a3,ffffffffc0201cf8 <slob_free+0xd4>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc0201c66:	4394                	lw	a3,0(a5)
		b->next = cur->next;
ffffffffc0201c68:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0201c6a:	00469713          	slli	a4,a3,0x4
ffffffffc0201c6e:	973e                	add	a4,a4,a5
ffffffffc0201c70:	08e50f63          	beq	a0,a4,ffffffffc0201d0e <slob_free+0xea>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc0201c74:	e788                	sd	a0,8(a5)

	slobfree = cur;
ffffffffc0201c76:	00009717          	auipc	a4,0x9
ffffffffc0201c7a:	3cf73d23          	sd	a5,986(a4) # ffffffffc020b050 <slobfree>
    if (flag) {
ffffffffc0201c7e:	c199                	beqz	a1,ffffffffc0201c84 <slob_free+0x60>
        intr_enable();
ffffffffc0201c80:	931fe06f          	j	ffffffffc02005b0 <intr_enable>
ffffffffc0201c84:	8082                	ret
		b->units = SLOB_UNITS(size);
ffffffffc0201c86:	05bd                	addi	a1,a1,15
ffffffffc0201c88:	8191                	srli	a1,a1,0x4
ffffffffc0201c8a:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c8c:	100027f3          	csrr	a5,sstatus
ffffffffc0201c90:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201c92:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c94:	dfd9                	beqz	a5,ffffffffc0201c32 <slob_free+0xe>
{
ffffffffc0201c96:	1101                	addi	sp,sp,-32
ffffffffc0201c98:	e42a                	sd	a0,8(sp)
ffffffffc0201c9a:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0201c9c:	91bfe0ef          	jal	ra,ffffffffc02005b6 <intr_disable>
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201ca0:	00009797          	auipc	a5,0x9
ffffffffc0201ca4:	3b078793          	addi	a5,a5,944 # ffffffffc020b050 <slobfree>
ffffffffc0201ca8:	639c                	ld	a5,0(a5)
        return 1;
ffffffffc0201caa:	6522                	ld	a0,8(sp)
ffffffffc0201cac:	4585                	li	a1,1
		if (cur >= cur->next && (b > cur || b < cur->next))// 环形链表
ffffffffc0201cae:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201cb0:	00a7fa63          	bleu	a0,a5,ffffffffc0201cc4 <slob_free+0xa0>
ffffffffc0201cb4:	00e56c63          	bltu	a0,a4,ffffffffc0201ccc <slob_free+0xa8>
		if (cur >= cur->next && (b > cur || b < cur->next))// 环形链表
ffffffffc0201cb8:	00e7fa63          	bleu	a4,a5,ffffffffc0201ccc <slob_free+0xa8>
    return 0;
ffffffffc0201cbc:	87ba                	mv	a5,a4
ffffffffc0201cbe:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201cc0:	fea7eae3          	bltu	a5,a0,ffffffffc0201cb4 <slob_free+0x90>
		if (cur >= cur->next && (b > cur || b < cur->next))// 环形链表
ffffffffc0201cc4:	fee7ece3          	bltu	a5,a4,ffffffffc0201cbc <slob_free+0x98>
ffffffffc0201cc8:	fee57ae3          	bleu	a4,a0,ffffffffc0201cbc <slob_free+0x98>
	if (b + b->units == cur->next) {// 相邻则合并，不相邻就直接连接
ffffffffc0201ccc:	4110                	lw	a2,0(a0)
ffffffffc0201cce:	00461693          	slli	a3,a2,0x4
ffffffffc0201cd2:	96aa                	add	a3,a3,a0
ffffffffc0201cd4:	04d70763          	beq	a4,a3,ffffffffc0201d22 <slob_free+0xfe>
		b->next = cur->next;
ffffffffc0201cd8:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0201cda:	4394                	lw	a3,0(a5)
ffffffffc0201cdc:	00469713          	slli	a4,a3,0x4
ffffffffc0201ce0:	973e                	add	a4,a4,a5
ffffffffc0201ce2:	04e50663          	beq	a0,a4,ffffffffc0201d2e <slob_free+0x10a>
		cur->next = b;
ffffffffc0201ce6:	e788                	sd	a0,8(a5)
	slobfree = cur;
ffffffffc0201ce8:	00009717          	auipc	a4,0x9
ffffffffc0201cec:	36f73423          	sd	a5,872(a4) # ffffffffc020b050 <slobfree>
    if (flag) {
ffffffffc0201cf0:	e58d                	bnez	a1,ffffffffc0201d1a <slob_free+0xf6>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0201cf2:	60e2                	ld	ra,24(sp)
ffffffffc0201cf4:	6105                	addi	sp,sp,32
ffffffffc0201cf6:	8082                	ret
		b->units += cur->next->units;
ffffffffc0201cf8:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201cfa:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0201cfc:	9e35                	addw	a2,a2,a3
ffffffffc0201cfe:	c110                	sw	a2,0(a0)
	if (cur + cur->units == b) {
ffffffffc0201d00:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0201d02:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0201d04:	00469713          	slli	a4,a3,0x4
ffffffffc0201d08:	973e                	add	a4,a4,a5
ffffffffc0201d0a:	f6e515e3          	bne	a0,a4,ffffffffc0201c74 <slob_free+0x50>
		cur->units += b->units;
ffffffffc0201d0e:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc0201d10:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0201d12:	9eb9                	addw	a3,a3,a4
ffffffffc0201d14:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0201d16:	e790                	sd	a2,8(a5)
ffffffffc0201d18:	bfb9                	j	ffffffffc0201c76 <slob_free+0x52>
}
ffffffffc0201d1a:	60e2                	ld	ra,24(sp)
ffffffffc0201d1c:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201d1e:	893fe06f          	j	ffffffffc02005b0 <intr_enable>
		b->units += cur->next->units;
ffffffffc0201d22:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201d24:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0201d26:	9e35                	addw	a2,a2,a3
ffffffffc0201d28:	c110                	sw	a2,0(a0)
		b->next = cur->next->next;
ffffffffc0201d2a:	e518                	sd	a4,8(a0)
ffffffffc0201d2c:	b77d                	j	ffffffffc0201cda <slob_free+0xb6>
		cur->units += b->units;
ffffffffc0201d2e:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc0201d30:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0201d32:	9eb9                	addw	a3,a3,a4
ffffffffc0201d34:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0201d36:	e790                	sd	a2,8(a5)
ffffffffc0201d38:	bf45                	j	ffffffffc0201ce8 <slob_free+0xc4>

ffffffffc0201d3a <__slob_get_free_pages.isra.0>:
  struct Page * page = alloc_pages(1 << order);// 分配连续的物理页， 2 的 order 次方
ffffffffc0201d3a:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201d3c:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);// 分配连续的物理页， 2 的 order 次方
ffffffffc0201d3e:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201d42:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);// 分配连续的物理页， 2 的 order 次方
ffffffffc0201d44:	2c0010ef          	jal	ra,ffffffffc0203004 <alloc_pages>
  if(!page)
ffffffffc0201d48:	c139                	beqz	a0,ffffffffc0201d8e <__slob_get_free_pages.isra.0+0x54>
    return page - pages + nbase;
ffffffffc0201d4a:	00015797          	auipc	a5,0x15
ffffffffc0201d4e:	89e78793          	addi	a5,a5,-1890 # ffffffffc02165e8 <pages>
ffffffffc0201d52:	6394                	ld	a3,0(a5)
ffffffffc0201d54:	00005797          	auipc	a5,0x5
ffffffffc0201d58:	4cc78793          	addi	a5,a5,1228 # ffffffffc0207220 <nbase>
    return KADDR(page2pa(page));
ffffffffc0201d5c:	00014717          	auipc	a4,0x14
ffffffffc0201d60:	74c70713          	addi	a4,a4,1868 # ffffffffc02164a8 <npage>
    return page - pages + nbase;
ffffffffc0201d64:	40d506b3          	sub	a3,a0,a3
ffffffffc0201d68:	6388                	ld	a0,0(a5)
ffffffffc0201d6a:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0201d6c:	57fd                	li	a5,-1
ffffffffc0201d6e:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc0201d70:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc0201d72:	83b1                	srli	a5,a5,0xc
ffffffffc0201d74:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0201d76:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201d78:	00e7ff63          	bleu	a4,a5,ffffffffc0201d96 <__slob_get_free_pages.isra.0+0x5c>
ffffffffc0201d7c:	00015797          	auipc	a5,0x15
ffffffffc0201d80:	85c78793          	addi	a5,a5,-1956 # ffffffffc02165d8 <va_pa_offset>
ffffffffc0201d84:	6388                	ld	a0,0(a5)
}
ffffffffc0201d86:	60a2                	ld	ra,8(sp)
ffffffffc0201d88:	9536                	add	a0,a0,a3
ffffffffc0201d8a:	0141                	addi	sp,sp,16
ffffffffc0201d8c:	8082                	ret
ffffffffc0201d8e:	60a2                	ld	ra,8(sp)
    return NULL;
ffffffffc0201d90:	4501                	li	a0,0
}
ffffffffc0201d92:	0141                	addi	sp,sp,16
ffffffffc0201d94:	8082                	ret
ffffffffc0201d96:	00004617          	auipc	a2,0x4
ffffffffc0201d9a:	eb260613          	addi	a2,a2,-334 # ffffffffc0205c48 <commands+0xbc8>
ffffffffc0201d9e:	06900593          	li	a1,105
ffffffffc0201da2:	00004517          	auipc	a0,0x4
ffffffffc0201da6:	e9650513          	addi	a0,a0,-362 # ffffffffc0205c38 <commands+0xbb8>
ffffffffc0201daa:	c2cfe0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc0201dae <slob_alloc.isra.1.constprop.3>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0201dae:	7179                	addi	sp,sp,-48
ffffffffc0201db0:	f406                	sd	ra,40(sp)
ffffffffc0201db2:	f022                	sd	s0,32(sp)
ffffffffc0201db4:	ec26                	sd	s1,24(sp)
	assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201db6:	01050713          	addi	a4,a0,16
ffffffffc0201dba:	6785                	lui	a5,0x1
ffffffffc0201dbc:	0cf77b63          	bleu	a5,a4,ffffffffc0201e92 <slob_alloc.isra.1.constprop.3+0xe4>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0201dc0:	00f50413          	addi	s0,a0,15
ffffffffc0201dc4:	8011                	srli	s0,s0,0x4
ffffffffc0201dc6:	2401                	sext.w	s0,s0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201dc8:	10002673          	csrr	a2,sstatus
ffffffffc0201dcc:	8a09                	andi	a2,a2,2
ffffffffc0201dce:	ea5d                	bnez	a2,ffffffffc0201e84 <slob_alloc.isra.1.constprop.3+0xd6>
	prev = slobfree;
ffffffffc0201dd0:	00009497          	auipc	s1,0x9
ffffffffc0201dd4:	28048493          	addi	s1,s1,640 # ffffffffc020b050 <slobfree>
ffffffffc0201dd8:	6094                	ld	a3,0(s1)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201dda:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201ddc:	4398                	lw	a4,0(a5)
ffffffffc0201dde:	0a875763          	ble	s0,a4,ffffffffc0201e8c <slob_alloc.isra.1.constprop.3+0xde>
		if (cur == slobfree) {// 如果遍历完没找到，请求一页来分配，内存池的大小得到了扩充
ffffffffc0201de2:	00f68a63          	beq	a3,a5,ffffffffc0201df6 <slob_alloc.isra.1.constprop.3+0x48>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201de6:	6788                	ld	a0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201de8:	4118                	lw	a4,0(a0)
ffffffffc0201dea:	02875763          	ble	s0,a4,ffffffffc0201e18 <slob_alloc.isra.1.constprop.3+0x6a>
ffffffffc0201dee:	6094                	ld	a3,0(s1)
ffffffffc0201df0:	87aa                	mv	a5,a0
		if (cur == slobfree) {// 如果遍历完没找到，请求一页来分配，内存池的大小得到了扩充
ffffffffc0201df2:	fef69ae3          	bne	a3,a5,ffffffffc0201de6 <slob_alloc.isra.1.constprop.3+0x38>
    if (flag) {
ffffffffc0201df6:	ea39                	bnez	a2,ffffffffc0201e4c <slob_alloc.isra.1.constprop.3+0x9e>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201df8:	4501                	li	a0,0
ffffffffc0201dfa:	f41ff0ef          	jal	ra,ffffffffc0201d3a <__slob_get_free_pages.isra.0>
			if (!cur)// 如果申请不到就直接返回
ffffffffc0201dfe:	cd29                	beqz	a0,ffffffffc0201e58 <slob_alloc.isra.1.constprop.3+0xaa>
			slob_free(cur, PAGE_SIZE);
ffffffffc0201e00:	6585                	lui	a1,0x1
ffffffffc0201e02:	e23ff0ef          	jal	ra,ffffffffc0201c24 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201e06:	10002673          	csrr	a2,sstatus
ffffffffc0201e0a:	8a09                	andi	a2,a2,2
ffffffffc0201e0c:	ea1d                	bnez	a2,ffffffffc0201e42 <slob_alloc.isra.1.constprop.3+0x94>
			cur = slobfree;
ffffffffc0201e0e:	609c                	ld	a5,0(s1)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201e10:	6788                	ld	a0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201e12:	4118                	lw	a4,0(a0)
ffffffffc0201e14:	fc874de3          	blt	a4,s0,ffffffffc0201dee <slob_alloc.isra.1.constprop.3+0x40>
			if (cur->units == units) /* exact fit? */ // 如果找到的块大小与请求的大小相等，将其从链表中分离。
ffffffffc0201e18:	04e40663          	beq	s0,a4,ffffffffc0201e64 <slob_alloc.isra.1.constprop.3+0xb6>
				prev->next = cur + units;
ffffffffc0201e1c:	00441693          	slli	a3,s0,0x4
ffffffffc0201e20:	96aa                	add	a3,a3,a0
ffffffffc0201e22:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0201e24:	650c                	ld	a1,8(a0)
				prev->next->units = cur->units - units;
ffffffffc0201e26:	9f01                	subw	a4,a4,s0
ffffffffc0201e28:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0201e2a:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0201e2c:	c100                	sw	s0,0(a0)
			slobfree = prev;
ffffffffc0201e2e:	00009717          	auipc	a4,0x9
ffffffffc0201e32:	22f73123          	sd	a5,546(a4) # ffffffffc020b050 <slobfree>
    if (flag) {
ffffffffc0201e36:	ee15                	bnez	a2,ffffffffc0201e72 <slob_alloc.isra.1.constprop.3+0xc4>
}
ffffffffc0201e38:	70a2                	ld	ra,40(sp)
ffffffffc0201e3a:	7402                	ld	s0,32(sp)
ffffffffc0201e3c:	64e2                	ld	s1,24(sp)
ffffffffc0201e3e:	6145                	addi	sp,sp,48
ffffffffc0201e40:	8082                	ret
        intr_disable();
ffffffffc0201e42:	f74fe0ef          	jal	ra,ffffffffc02005b6 <intr_disable>
ffffffffc0201e46:	4605                	li	a2,1
			cur = slobfree;
ffffffffc0201e48:	609c                	ld	a5,0(s1)
ffffffffc0201e4a:	b7d9                	j	ffffffffc0201e10 <slob_alloc.isra.1.constprop.3+0x62>
        intr_enable();
ffffffffc0201e4c:	f64fe0ef          	jal	ra,ffffffffc02005b0 <intr_enable>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201e50:	4501                	li	a0,0
ffffffffc0201e52:	ee9ff0ef          	jal	ra,ffffffffc0201d3a <__slob_get_free_pages.isra.0>
			if (!cur)// 如果申请不到就直接返回
ffffffffc0201e56:	f54d                	bnez	a0,ffffffffc0201e00 <slob_alloc.isra.1.constprop.3+0x52>
}
ffffffffc0201e58:	70a2                	ld	ra,40(sp)
ffffffffc0201e5a:	7402                	ld	s0,32(sp)
ffffffffc0201e5c:	64e2                	ld	s1,24(sp)
				return 0;
ffffffffc0201e5e:	4501                	li	a0,0
}
ffffffffc0201e60:	6145                	addi	sp,sp,48
ffffffffc0201e62:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0201e64:	6518                	ld	a4,8(a0)
ffffffffc0201e66:	e798                	sd	a4,8(a5)
			slobfree = prev;
ffffffffc0201e68:	00009717          	auipc	a4,0x9
ffffffffc0201e6c:	1ef73423          	sd	a5,488(a4) # ffffffffc020b050 <slobfree>
    if (flag) {
ffffffffc0201e70:	d661                	beqz	a2,ffffffffc0201e38 <slob_alloc.isra.1.constprop.3+0x8a>
ffffffffc0201e72:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201e74:	f3cfe0ef          	jal	ra,ffffffffc02005b0 <intr_enable>
}
ffffffffc0201e78:	70a2                	ld	ra,40(sp)
ffffffffc0201e7a:	7402                	ld	s0,32(sp)
ffffffffc0201e7c:	6522                	ld	a0,8(sp)
ffffffffc0201e7e:	64e2                	ld	s1,24(sp)
ffffffffc0201e80:	6145                	addi	sp,sp,48
ffffffffc0201e82:	8082                	ret
        intr_disable();
ffffffffc0201e84:	f32fe0ef          	jal	ra,ffffffffc02005b6 <intr_disable>
ffffffffc0201e88:	4605                	li	a2,1
ffffffffc0201e8a:	b799                	j	ffffffffc0201dd0 <slob_alloc.isra.1.constprop.3+0x22>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201e8c:	853e                	mv	a0,a5
ffffffffc0201e8e:	87b6                	mv	a5,a3
ffffffffc0201e90:	b761                	j	ffffffffc0201e18 <slob_alloc.isra.1.constprop.3+0x6a>
	assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201e92:	00004697          	auipc	a3,0x4
ffffffffc0201e96:	21668693          	addi	a3,a3,534 # ffffffffc02060a8 <commands+0x1028>
ffffffffc0201e9a:	00004617          	auipc	a2,0x4
ffffffffc0201e9e:	a4660613          	addi	a2,a2,-1466 # ffffffffc02058e0 <commands+0x860>
ffffffffc0201ea2:	06f00593          	li	a1,111
ffffffffc0201ea6:	00004517          	auipc	a0,0x4
ffffffffc0201eaa:	22250513          	addi	a0,a0,546 # ffffffffc02060c8 <commands+0x1048>
ffffffffc0201eae:	b28fe0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc0201eb2 <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc0201eb2:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc0201eb4:	00004517          	auipc	a0,0x4
ffffffffc0201eb8:	22c50513          	addi	a0,a0,556 # ffffffffc02060e0 <commands+0x1060>
kmalloc_init(void) {
ffffffffc0201ebc:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc0201ebe:	a12fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201ec2:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201ec4:	00004517          	auipc	a0,0x4
ffffffffc0201ec8:	1c450513          	addi	a0,a0,452 # ffffffffc0206088 <commands+0x1008>
}
ffffffffc0201ecc:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201ece:	a02fe06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc0201ed2 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201ed2:	1101                	addi	sp,sp,-32
ffffffffc0201ed4:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {// 小块管理结构
ffffffffc0201ed6:	6905                	lui	s2,0x1
{
ffffffffc0201ed8:	e822                	sd	s0,16(sp)
ffffffffc0201eda:	ec06                	sd	ra,24(sp)
ffffffffc0201edc:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {// 小块管理结构
ffffffffc0201ede:	fef90793          	addi	a5,s2,-17 # fef <BASE_ADDRESS-0xffffffffc01ff011>
{
ffffffffc0201ee2:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {// 小块管理结构
ffffffffc0201ee4:	04a7fc63          	bleu	a0,a5,ffffffffc0201f3c <kmalloc+0x6a>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);// 否则大块管理结构
ffffffffc0201ee8:	4561                	li	a0,24
ffffffffc0201eea:	ec5ff0ef          	jal	ra,ffffffffc0201dae <slob_alloc.isra.1.constprop.3>
ffffffffc0201eee:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0201ef0:	cd21                	beqz	a0,ffffffffc0201f48 <kmalloc+0x76>
	bb->order = find_order(size);
ffffffffc0201ef2:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0201ef6:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201ef8:	00f95763          	ble	a5,s2,ffffffffc0201f06 <kmalloc+0x34>
ffffffffc0201efc:	6705                	lui	a4,0x1
ffffffffc0201efe:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0201f00:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201f02:	fef74ee3          	blt	a4,a5,ffffffffc0201efe <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0201f06:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);// 实际的虚拟内存地址入口
ffffffffc0201f08:	e33ff0ef          	jal	ra,ffffffffc0201d3a <__slob_get_free_pages.isra.0>
ffffffffc0201f0c:	e488                	sd	a0,8(s1)
ffffffffc0201f0e:	842a                	mv	s0,a0
	if (bb->pages) {// 插入链表
ffffffffc0201f10:	c935                	beqz	a0,ffffffffc0201f84 <kmalloc+0xb2>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201f12:	100027f3          	csrr	a5,sstatus
ffffffffc0201f16:	8b89                	andi	a5,a5,2
ffffffffc0201f18:	e3a1                	bnez	a5,ffffffffc0201f58 <kmalloc+0x86>
		bb->next = bigblocks;
ffffffffc0201f1a:	00014797          	auipc	a5,0x14
ffffffffc0201f1e:	57e78793          	addi	a5,a5,1406 # ffffffffc0216498 <bigblocks>
ffffffffc0201f22:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0201f24:	00014717          	auipc	a4,0x14
ffffffffc0201f28:	56973a23          	sd	s1,1396(a4) # ffffffffc0216498 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201f2c:	e89c                	sd	a5,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc0201f2e:	8522                	mv	a0,s0
ffffffffc0201f30:	60e2                	ld	ra,24(sp)
ffffffffc0201f32:	6442                	ld	s0,16(sp)
ffffffffc0201f34:	64a2                	ld	s1,8(sp)
ffffffffc0201f36:	6902                	ld	s2,0(sp)
ffffffffc0201f38:	6105                	addi	sp,sp,32
ffffffffc0201f3a:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201f3c:	0541                	addi	a0,a0,16
ffffffffc0201f3e:	e71ff0ef          	jal	ra,ffffffffc0201dae <slob_alloc.isra.1.constprop.3>
		return m ? (void *)(m + 1) : 0;
ffffffffc0201f42:	01050413          	addi	s0,a0,16
ffffffffc0201f46:	f565                	bnez	a0,ffffffffc0201f2e <kmalloc+0x5c>
ffffffffc0201f48:	4401                	li	s0,0
}
ffffffffc0201f4a:	8522                	mv	a0,s0
ffffffffc0201f4c:	60e2                	ld	ra,24(sp)
ffffffffc0201f4e:	6442                	ld	s0,16(sp)
ffffffffc0201f50:	64a2                	ld	s1,8(sp)
ffffffffc0201f52:	6902                	ld	s2,0(sp)
ffffffffc0201f54:	6105                	addi	sp,sp,32
ffffffffc0201f56:	8082                	ret
        intr_disable();
ffffffffc0201f58:	e5efe0ef          	jal	ra,ffffffffc02005b6 <intr_disable>
		bb->next = bigblocks;
ffffffffc0201f5c:	00014797          	auipc	a5,0x14
ffffffffc0201f60:	53c78793          	addi	a5,a5,1340 # ffffffffc0216498 <bigblocks>
ffffffffc0201f64:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0201f66:	00014717          	auipc	a4,0x14
ffffffffc0201f6a:	52973923          	sd	s1,1330(a4) # ffffffffc0216498 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201f6e:	e89c                	sd	a5,16(s1)
        intr_enable();
ffffffffc0201f70:	e40fe0ef          	jal	ra,ffffffffc02005b0 <intr_enable>
ffffffffc0201f74:	6480                	ld	s0,8(s1)
}
ffffffffc0201f76:	60e2                	ld	ra,24(sp)
ffffffffc0201f78:	64a2                	ld	s1,8(sp)
ffffffffc0201f7a:	8522                	mv	a0,s0
ffffffffc0201f7c:	6442                	ld	s0,16(sp)
ffffffffc0201f7e:	6902                	ld	s2,0(sp)
ffffffffc0201f80:	6105                	addi	sp,sp,32
ffffffffc0201f82:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201f84:	45e1                	li	a1,24
ffffffffc0201f86:	8526                	mv	a0,s1
ffffffffc0201f88:	c9dff0ef          	jal	ra,ffffffffc0201c24 <slob_free>
  return __kmalloc(size, 0);
ffffffffc0201f8c:	b74d                	j	ffffffffc0201f2e <kmalloc+0x5c>

ffffffffc0201f8e <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201f8e:	c175                	beqz	a0,ffffffffc0202072 <kfree+0xe4>
{
ffffffffc0201f90:	1101                	addi	sp,sp,-32
ffffffffc0201f92:	e426                	sd	s1,8(sp)
ffffffffc0201f94:	ec06                	sd	ra,24(sp)
ffffffffc0201f96:	e822                	sd	s0,16(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {// 首先在大块链表中寻找并释放
ffffffffc0201f98:	03451793          	slli	a5,a0,0x34
ffffffffc0201f9c:	84aa                	mv	s1,a0
ffffffffc0201f9e:	eb8d                	bnez	a5,ffffffffc0201fd0 <kfree+0x42>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201fa0:	100027f3          	csrr	a5,sstatus
ffffffffc0201fa4:	8b89                	andi	a5,a5,2
ffffffffc0201fa6:	efc9                	bnez	a5,ffffffffc0202040 <kfree+0xb2>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201fa8:	00014797          	auipc	a5,0x14
ffffffffc0201fac:	4f078793          	addi	a5,a5,1264 # ffffffffc0216498 <bigblocks>
ffffffffc0201fb0:	6394                	ld	a3,0(a5)
ffffffffc0201fb2:	ce99                	beqz	a3,ffffffffc0201fd0 <kfree+0x42>
			if (bb->pages == block) {
ffffffffc0201fb4:	669c                	ld	a5,8(a3)
ffffffffc0201fb6:	6a80                	ld	s0,16(a3)
ffffffffc0201fb8:	0af50e63          	beq	a0,a5,ffffffffc0202074 <kfree+0xe6>
    return 0;
ffffffffc0201fbc:	4601                	li	a2,0
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201fbe:	c801                	beqz	s0,ffffffffc0201fce <kfree+0x40>
			if (bb->pages == block) {
ffffffffc0201fc0:	6418                	ld	a4,8(s0)
ffffffffc0201fc2:	681c                	ld	a5,16(s0)
ffffffffc0201fc4:	00970f63          	beq	a4,s1,ffffffffc0201fe2 <kfree+0x54>
ffffffffc0201fc8:	86a2                	mv	a3,s0
ffffffffc0201fca:	843e                	mv	s0,a5
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201fcc:	f875                	bnez	s0,ffffffffc0201fc0 <kfree+0x32>
    if (flag) {
ffffffffc0201fce:	e659                	bnez	a2,ffffffffc020205c <kfree+0xce>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);// 小块链表就寻找并释放
	return;
}
ffffffffc0201fd0:	6442                	ld	s0,16(sp)
ffffffffc0201fd2:	60e2                	ld	ra,24(sp)
	slob_free((slob_t *)block - 1, 0);// 小块链表就寻找并释放
ffffffffc0201fd4:	ff048513          	addi	a0,s1,-16
}
ffffffffc0201fd8:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);// 小块链表就寻找并释放
ffffffffc0201fda:	4581                	li	a1,0
}
ffffffffc0201fdc:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);// 小块链表就寻找并释放
ffffffffc0201fde:	c47ff06f          	j	ffffffffc0201c24 <slob_free>
				*last = bb->next;
ffffffffc0201fe2:	ea9c                	sd	a5,16(a3)
ffffffffc0201fe4:	e641                	bnez	a2,ffffffffc020206c <kfree+0xde>
    return pa2page(PADDR(kva));
ffffffffc0201fe6:	c02007b7          	lui	a5,0xc0200
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0201fea:	4018                	lw	a4,0(s0)
ffffffffc0201fec:	08f4ea63          	bltu	s1,a5,ffffffffc0202080 <kfree+0xf2>
ffffffffc0201ff0:	00014797          	auipc	a5,0x14
ffffffffc0201ff4:	5e878793          	addi	a5,a5,1512 # ffffffffc02165d8 <va_pa_offset>
ffffffffc0201ff8:	6394                	ld	a3,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0201ffa:	00014797          	auipc	a5,0x14
ffffffffc0201ffe:	4ae78793          	addi	a5,a5,1198 # ffffffffc02164a8 <npage>
ffffffffc0202002:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0202004:	8c95                	sub	s1,s1,a3
    if (PPN(pa) >= npage) {
ffffffffc0202006:	80b1                	srli	s1,s1,0xc
ffffffffc0202008:	08f4f963          	bleu	a5,s1,ffffffffc020209a <kfree+0x10c>
    return &pages[PPN(pa) - nbase];
ffffffffc020200c:	00005797          	auipc	a5,0x5
ffffffffc0202010:	21478793          	addi	a5,a5,532 # ffffffffc0207220 <nbase>
ffffffffc0202014:	639c                	ld	a5,0(a5)
ffffffffc0202016:	00014697          	auipc	a3,0x14
ffffffffc020201a:	5d268693          	addi	a3,a3,1490 # ffffffffc02165e8 <pages>
ffffffffc020201e:	6288                	ld	a0,0(a3)
ffffffffc0202020:	8c9d                	sub	s1,s1,a5
ffffffffc0202022:	049a                	slli	s1,s1,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc0202024:	4585                	li	a1,1
ffffffffc0202026:	9526                	add	a0,a0,s1
ffffffffc0202028:	00e595bb          	sllw	a1,a1,a4
ffffffffc020202c:	060010ef          	jal	ra,ffffffffc020308c <free_pages>
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0202030:	8522                	mv	a0,s0
}
ffffffffc0202032:	6442                	ld	s0,16(sp)
ffffffffc0202034:	60e2                	ld	ra,24(sp)
ffffffffc0202036:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0202038:	45e1                	li	a1,24
}
ffffffffc020203a:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);// 小块链表就寻找并释放
ffffffffc020203c:	be9ff06f          	j	ffffffffc0201c24 <slob_free>
        intr_disable();
ffffffffc0202040:	d76fe0ef          	jal	ra,ffffffffc02005b6 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0202044:	00014797          	auipc	a5,0x14
ffffffffc0202048:	45478793          	addi	a5,a5,1108 # ffffffffc0216498 <bigblocks>
ffffffffc020204c:	6394                	ld	a3,0(a5)
ffffffffc020204e:	c699                	beqz	a3,ffffffffc020205c <kfree+0xce>
			if (bb->pages == block) {
ffffffffc0202050:	669c                	ld	a5,8(a3)
ffffffffc0202052:	6a80                	ld	s0,16(a3)
ffffffffc0202054:	00f48763          	beq	s1,a5,ffffffffc0202062 <kfree+0xd4>
        return 1;
ffffffffc0202058:	4605                	li	a2,1
ffffffffc020205a:	b795                	j	ffffffffc0201fbe <kfree+0x30>
        intr_enable();
ffffffffc020205c:	d54fe0ef          	jal	ra,ffffffffc02005b0 <intr_enable>
ffffffffc0202060:	bf85                	j	ffffffffc0201fd0 <kfree+0x42>
				*last = bb->next;
ffffffffc0202062:	00014797          	auipc	a5,0x14
ffffffffc0202066:	4287bb23          	sd	s0,1078(a5) # ffffffffc0216498 <bigblocks>
ffffffffc020206a:	8436                	mv	s0,a3
ffffffffc020206c:	d44fe0ef          	jal	ra,ffffffffc02005b0 <intr_enable>
ffffffffc0202070:	bf9d                	j	ffffffffc0201fe6 <kfree+0x58>
ffffffffc0202072:	8082                	ret
ffffffffc0202074:	00014797          	auipc	a5,0x14
ffffffffc0202078:	4287b223          	sd	s0,1060(a5) # ffffffffc0216498 <bigblocks>
ffffffffc020207c:	8436                	mv	s0,a3
ffffffffc020207e:	b7a5                	j	ffffffffc0201fe6 <kfree+0x58>
    return pa2page(PADDR(kva));
ffffffffc0202080:	86a6                	mv	a3,s1
ffffffffc0202082:	00004617          	auipc	a2,0x4
ffffffffc0202086:	fde60613          	addi	a2,a2,-34 # ffffffffc0206060 <commands+0xfe0>
ffffffffc020208a:	06e00593          	li	a1,110
ffffffffc020208e:	00004517          	auipc	a0,0x4
ffffffffc0202092:	baa50513          	addi	a0,a0,-1110 # ffffffffc0205c38 <commands+0xbb8>
ffffffffc0202096:	940fe0ef          	jal	ra,ffffffffc02001d6 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020209a:	00004617          	auipc	a2,0x4
ffffffffc020209e:	b7e60613          	addi	a2,a2,-1154 # ffffffffc0205c18 <commands+0xb98>
ffffffffc02020a2:	06200593          	li	a1,98
ffffffffc02020a6:	00004517          	auipc	a0,0x4
ffffffffc02020aa:	b9250513          	addi	a0,a0,-1134 # ffffffffc0205c38 <commands+0xbb8>
ffffffffc02020ae:	928fe0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc02020b2 <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc02020b2:	00014797          	auipc	a5,0x14
ffffffffc02020b6:	4f678793          	addi	a5,a5,1270 # ffffffffc02165a8 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc02020ba:	f51c                	sd	a5,40(a0)
ffffffffc02020bc:	e79c                	sd	a5,8(a5)
ffffffffc02020be:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc02020c0:	4501                	li	a0,0
ffffffffc02020c2:	8082                	ret

ffffffffc02020c4 <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc02020c4:	4501                	li	a0,0
ffffffffc02020c6:	8082                	ret

ffffffffc02020c8 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc02020c8:	4501                	li	a0,0
ffffffffc02020ca:	8082                	ret

ffffffffc02020cc <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc02020cc:	4501                	li	a0,0
ffffffffc02020ce:	8082                	ret

ffffffffc02020d0 <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc02020d0:	711d                	addi	sp,sp,-96
ffffffffc02020d2:	fc4e                	sd	s3,56(sp)
ffffffffc02020d4:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc02020d6:	00004517          	auipc	a0,0x4
ffffffffc02020da:	02250513          	addi	a0,a0,34 # ffffffffc02060f8 <commands+0x1078>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02020de:	698d                	lui	s3,0x3
ffffffffc02020e0:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc02020e2:	e8a2                	sd	s0,80(sp)
ffffffffc02020e4:	e4a6                	sd	s1,72(sp)
ffffffffc02020e6:	ec86                	sd	ra,88(sp)
ffffffffc02020e8:	e0ca                	sd	s2,64(sp)
ffffffffc02020ea:	f456                	sd	s5,40(sp)
ffffffffc02020ec:	f05a                	sd	s6,32(sp)
ffffffffc02020ee:	ec5e                	sd	s7,24(sp)
ffffffffc02020f0:	e862                	sd	s8,16(sp)
ffffffffc02020f2:	e466                	sd	s9,8(sp)
    assert(pgfault_num==4);
ffffffffc02020f4:	00014417          	auipc	s0,0x14
ffffffffc02020f8:	38c40413          	addi	s0,s0,908 # ffffffffc0216480 <pgfault_num>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc02020fc:	fd5fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202100:	01498023          	sb	s4,0(s3) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc0202104:	4004                	lw	s1,0(s0)
ffffffffc0202106:	4791                	li	a5,4
ffffffffc0202108:	2481                	sext.w	s1,s1
ffffffffc020210a:	14f49963          	bne	s1,a5,ffffffffc020225c <_fifo_check_swap+0x18c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc020210e:	00004517          	auipc	a0,0x4
ffffffffc0202112:	02a50513          	addi	a0,a0,42 # ffffffffc0206138 <commands+0x10b8>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202116:	6a85                	lui	s5,0x1
ffffffffc0202118:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc020211a:	fb7fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc020211e:	016a8023          	sb	s6,0(s5) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc0202122:	00042903          	lw	s2,0(s0)
ffffffffc0202126:	2901                	sext.w	s2,s2
ffffffffc0202128:	2a991a63          	bne	s2,s1,ffffffffc02023dc <_fifo_check_swap+0x30c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc020212c:	00004517          	auipc	a0,0x4
ffffffffc0202130:	03450513          	addi	a0,a0,52 # ffffffffc0206160 <commands+0x10e0>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202134:	6b91                	lui	s7,0x4
ffffffffc0202136:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0202138:	f99fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc020213c:	018b8023          	sb	s8,0(s7) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc0202140:	4004                	lw	s1,0(s0)
ffffffffc0202142:	2481                	sext.w	s1,s1
ffffffffc0202144:	27249c63          	bne	s1,s2,ffffffffc02023bc <_fifo_check_swap+0x2ec>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0202148:	00004517          	auipc	a0,0x4
ffffffffc020214c:	04050513          	addi	a0,a0,64 # ffffffffc0206188 <commands+0x1108>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202150:	6909                	lui	s2,0x2
ffffffffc0202152:	4cad                	li	s9,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0202154:	f7dfd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202158:	01990023          	sb	s9,0(s2) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc020215c:	401c                	lw	a5,0(s0)
ffffffffc020215e:	2781                	sext.w	a5,a5
ffffffffc0202160:	22979e63          	bne	a5,s1,ffffffffc020239c <_fifo_check_swap+0x2cc>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0202164:	00004517          	auipc	a0,0x4
ffffffffc0202168:	04c50513          	addi	a0,a0,76 # ffffffffc02061b0 <commands+0x1130>
ffffffffc020216c:	f65fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0202170:	6795                	lui	a5,0x5
ffffffffc0202172:	4739                	li	a4,14
ffffffffc0202174:	00e78023          	sb	a4,0(a5) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc0202178:	4004                	lw	s1,0(s0)
ffffffffc020217a:	4795                	li	a5,5
ffffffffc020217c:	2481                	sext.w	s1,s1
ffffffffc020217e:	1ef49f63          	bne	s1,a5,ffffffffc020237c <_fifo_check_swap+0x2ac>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0202182:	00004517          	auipc	a0,0x4
ffffffffc0202186:	00650513          	addi	a0,a0,6 # ffffffffc0206188 <commands+0x1108>
ffffffffc020218a:	f47fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc020218e:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==5);
ffffffffc0202192:	401c                	lw	a5,0(s0)
ffffffffc0202194:	2781                	sext.w	a5,a5
ffffffffc0202196:	1c979363          	bne	a5,s1,ffffffffc020235c <_fifo_check_swap+0x28c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc020219a:	00004517          	auipc	a0,0x4
ffffffffc020219e:	f9e50513          	addi	a0,a0,-98 # ffffffffc0206138 <commands+0x10b8>
ffffffffc02021a2:	f2ffd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02021a6:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc02021aa:	401c                	lw	a5,0(s0)
ffffffffc02021ac:	4719                	li	a4,6
ffffffffc02021ae:	2781                	sext.w	a5,a5
ffffffffc02021b0:	18e79663          	bne	a5,a4,ffffffffc020233c <_fifo_check_swap+0x26c>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc02021b4:	00004517          	auipc	a0,0x4
ffffffffc02021b8:	fd450513          	addi	a0,a0,-44 # ffffffffc0206188 <commands+0x1108>
ffffffffc02021bc:	f15fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02021c0:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==7);
ffffffffc02021c4:	401c                	lw	a5,0(s0)
ffffffffc02021c6:	471d                	li	a4,7
ffffffffc02021c8:	2781                	sext.w	a5,a5
ffffffffc02021ca:	14e79963          	bne	a5,a4,ffffffffc020231c <_fifo_check_swap+0x24c>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc02021ce:	00004517          	auipc	a0,0x4
ffffffffc02021d2:	f2a50513          	addi	a0,a0,-214 # ffffffffc02060f8 <commands+0x1078>
ffffffffc02021d6:	efbfd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02021da:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc02021de:	401c                	lw	a5,0(s0)
ffffffffc02021e0:	4721                	li	a4,8
ffffffffc02021e2:	2781                	sext.w	a5,a5
ffffffffc02021e4:	10e79c63          	bne	a5,a4,ffffffffc02022fc <_fifo_check_swap+0x22c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc02021e8:	00004517          	auipc	a0,0x4
ffffffffc02021ec:	f7850513          	addi	a0,a0,-136 # ffffffffc0206160 <commands+0x10e0>
ffffffffc02021f0:	ee1fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02021f4:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc02021f8:	401c                	lw	a5,0(s0)
ffffffffc02021fa:	4725                	li	a4,9
ffffffffc02021fc:	2781                	sext.w	a5,a5
ffffffffc02021fe:	0ce79f63          	bne	a5,a4,ffffffffc02022dc <_fifo_check_swap+0x20c>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0202202:	00004517          	auipc	a0,0x4
ffffffffc0202206:	fae50513          	addi	a0,a0,-82 # ffffffffc02061b0 <commands+0x1130>
ffffffffc020220a:	ec7fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc020220e:	6795                	lui	a5,0x5
ffffffffc0202210:	4739                	li	a4,14
ffffffffc0202212:	00e78023          	sb	a4,0(a5) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==10);
ffffffffc0202216:	4004                	lw	s1,0(s0)
ffffffffc0202218:	47a9                	li	a5,10
ffffffffc020221a:	2481                	sext.w	s1,s1
ffffffffc020221c:	0af49063          	bne	s1,a5,ffffffffc02022bc <_fifo_check_swap+0x1ec>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0202220:	00004517          	auipc	a0,0x4
ffffffffc0202224:	f1850513          	addi	a0,a0,-232 # ffffffffc0206138 <commands+0x10b8>
ffffffffc0202228:	ea9fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc020222c:	6785                	lui	a5,0x1
ffffffffc020222e:	0007c783          	lbu	a5,0(a5) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc0202232:	06979563          	bne	a5,s1,ffffffffc020229c <_fifo_check_swap+0x1cc>
    assert(pgfault_num==11);
ffffffffc0202236:	401c                	lw	a5,0(s0)
ffffffffc0202238:	472d                	li	a4,11
ffffffffc020223a:	2781                	sext.w	a5,a5
ffffffffc020223c:	04e79063          	bne	a5,a4,ffffffffc020227c <_fifo_check_swap+0x1ac>
}
ffffffffc0202240:	60e6                	ld	ra,88(sp)
ffffffffc0202242:	6446                	ld	s0,80(sp)
ffffffffc0202244:	64a6                	ld	s1,72(sp)
ffffffffc0202246:	6906                	ld	s2,64(sp)
ffffffffc0202248:	79e2                	ld	s3,56(sp)
ffffffffc020224a:	7a42                	ld	s4,48(sp)
ffffffffc020224c:	7aa2                	ld	s5,40(sp)
ffffffffc020224e:	7b02                	ld	s6,32(sp)
ffffffffc0202250:	6be2                	ld	s7,24(sp)
ffffffffc0202252:	6c42                	ld	s8,16(sp)
ffffffffc0202254:	6ca2                	ld	s9,8(sp)
ffffffffc0202256:	4501                	li	a0,0
ffffffffc0202258:	6125                	addi	sp,sp,96
ffffffffc020225a:	8082                	ret
    assert(pgfault_num==4);
ffffffffc020225c:	00004697          	auipc	a3,0x4
ffffffffc0202260:	c6c68693          	addi	a3,a3,-916 # ffffffffc0205ec8 <commands+0xe48>
ffffffffc0202264:	00003617          	auipc	a2,0x3
ffffffffc0202268:	67c60613          	addi	a2,a2,1660 # ffffffffc02058e0 <commands+0x860>
ffffffffc020226c:	05100593          	li	a1,81
ffffffffc0202270:	00004517          	auipc	a0,0x4
ffffffffc0202274:	eb050513          	addi	a0,a0,-336 # ffffffffc0206120 <commands+0x10a0>
ffffffffc0202278:	f5ffd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(pgfault_num==11);
ffffffffc020227c:	00004697          	auipc	a3,0x4
ffffffffc0202280:	fe468693          	addi	a3,a3,-28 # ffffffffc0206260 <commands+0x11e0>
ffffffffc0202284:	00003617          	auipc	a2,0x3
ffffffffc0202288:	65c60613          	addi	a2,a2,1628 # ffffffffc02058e0 <commands+0x860>
ffffffffc020228c:	07300593          	li	a1,115
ffffffffc0202290:	00004517          	auipc	a0,0x4
ffffffffc0202294:	e9050513          	addi	a0,a0,-368 # ffffffffc0206120 <commands+0x10a0>
ffffffffc0202298:	f3ffd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc020229c:	00004697          	auipc	a3,0x4
ffffffffc02022a0:	f9c68693          	addi	a3,a3,-100 # ffffffffc0206238 <commands+0x11b8>
ffffffffc02022a4:	00003617          	auipc	a2,0x3
ffffffffc02022a8:	63c60613          	addi	a2,a2,1596 # ffffffffc02058e0 <commands+0x860>
ffffffffc02022ac:	07100593          	li	a1,113
ffffffffc02022b0:	00004517          	auipc	a0,0x4
ffffffffc02022b4:	e7050513          	addi	a0,a0,-400 # ffffffffc0206120 <commands+0x10a0>
ffffffffc02022b8:	f1ffd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(pgfault_num==10);
ffffffffc02022bc:	00004697          	auipc	a3,0x4
ffffffffc02022c0:	f6c68693          	addi	a3,a3,-148 # ffffffffc0206228 <commands+0x11a8>
ffffffffc02022c4:	00003617          	auipc	a2,0x3
ffffffffc02022c8:	61c60613          	addi	a2,a2,1564 # ffffffffc02058e0 <commands+0x860>
ffffffffc02022cc:	06f00593          	li	a1,111
ffffffffc02022d0:	00004517          	auipc	a0,0x4
ffffffffc02022d4:	e5050513          	addi	a0,a0,-432 # ffffffffc0206120 <commands+0x10a0>
ffffffffc02022d8:	efffd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(pgfault_num==9);
ffffffffc02022dc:	00004697          	auipc	a3,0x4
ffffffffc02022e0:	f3c68693          	addi	a3,a3,-196 # ffffffffc0206218 <commands+0x1198>
ffffffffc02022e4:	00003617          	auipc	a2,0x3
ffffffffc02022e8:	5fc60613          	addi	a2,a2,1532 # ffffffffc02058e0 <commands+0x860>
ffffffffc02022ec:	06c00593          	li	a1,108
ffffffffc02022f0:	00004517          	auipc	a0,0x4
ffffffffc02022f4:	e3050513          	addi	a0,a0,-464 # ffffffffc0206120 <commands+0x10a0>
ffffffffc02022f8:	edffd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(pgfault_num==8);
ffffffffc02022fc:	00004697          	auipc	a3,0x4
ffffffffc0202300:	f0c68693          	addi	a3,a3,-244 # ffffffffc0206208 <commands+0x1188>
ffffffffc0202304:	00003617          	auipc	a2,0x3
ffffffffc0202308:	5dc60613          	addi	a2,a2,1500 # ffffffffc02058e0 <commands+0x860>
ffffffffc020230c:	06900593          	li	a1,105
ffffffffc0202310:	00004517          	auipc	a0,0x4
ffffffffc0202314:	e1050513          	addi	a0,a0,-496 # ffffffffc0206120 <commands+0x10a0>
ffffffffc0202318:	ebffd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(pgfault_num==7);
ffffffffc020231c:	00004697          	auipc	a3,0x4
ffffffffc0202320:	edc68693          	addi	a3,a3,-292 # ffffffffc02061f8 <commands+0x1178>
ffffffffc0202324:	00003617          	auipc	a2,0x3
ffffffffc0202328:	5bc60613          	addi	a2,a2,1468 # ffffffffc02058e0 <commands+0x860>
ffffffffc020232c:	06600593          	li	a1,102
ffffffffc0202330:	00004517          	auipc	a0,0x4
ffffffffc0202334:	df050513          	addi	a0,a0,-528 # ffffffffc0206120 <commands+0x10a0>
ffffffffc0202338:	e9ffd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(pgfault_num==6);
ffffffffc020233c:	00004697          	auipc	a3,0x4
ffffffffc0202340:	eac68693          	addi	a3,a3,-340 # ffffffffc02061e8 <commands+0x1168>
ffffffffc0202344:	00003617          	auipc	a2,0x3
ffffffffc0202348:	59c60613          	addi	a2,a2,1436 # ffffffffc02058e0 <commands+0x860>
ffffffffc020234c:	06300593          	li	a1,99
ffffffffc0202350:	00004517          	auipc	a0,0x4
ffffffffc0202354:	dd050513          	addi	a0,a0,-560 # ffffffffc0206120 <commands+0x10a0>
ffffffffc0202358:	e7ffd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(pgfault_num==5);
ffffffffc020235c:	00004697          	auipc	a3,0x4
ffffffffc0202360:	e7c68693          	addi	a3,a3,-388 # ffffffffc02061d8 <commands+0x1158>
ffffffffc0202364:	00003617          	auipc	a2,0x3
ffffffffc0202368:	57c60613          	addi	a2,a2,1404 # ffffffffc02058e0 <commands+0x860>
ffffffffc020236c:	06000593          	li	a1,96
ffffffffc0202370:	00004517          	auipc	a0,0x4
ffffffffc0202374:	db050513          	addi	a0,a0,-592 # ffffffffc0206120 <commands+0x10a0>
ffffffffc0202378:	e5ffd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(pgfault_num==5);
ffffffffc020237c:	00004697          	auipc	a3,0x4
ffffffffc0202380:	e5c68693          	addi	a3,a3,-420 # ffffffffc02061d8 <commands+0x1158>
ffffffffc0202384:	00003617          	auipc	a2,0x3
ffffffffc0202388:	55c60613          	addi	a2,a2,1372 # ffffffffc02058e0 <commands+0x860>
ffffffffc020238c:	05d00593          	li	a1,93
ffffffffc0202390:	00004517          	auipc	a0,0x4
ffffffffc0202394:	d9050513          	addi	a0,a0,-624 # ffffffffc0206120 <commands+0x10a0>
ffffffffc0202398:	e3ffd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(pgfault_num==4);
ffffffffc020239c:	00004697          	auipc	a3,0x4
ffffffffc02023a0:	b2c68693          	addi	a3,a3,-1236 # ffffffffc0205ec8 <commands+0xe48>
ffffffffc02023a4:	00003617          	auipc	a2,0x3
ffffffffc02023a8:	53c60613          	addi	a2,a2,1340 # ffffffffc02058e0 <commands+0x860>
ffffffffc02023ac:	05a00593          	li	a1,90
ffffffffc02023b0:	00004517          	auipc	a0,0x4
ffffffffc02023b4:	d7050513          	addi	a0,a0,-656 # ffffffffc0206120 <commands+0x10a0>
ffffffffc02023b8:	e1ffd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(pgfault_num==4);
ffffffffc02023bc:	00004697          	auipc	a3,0x4
ffffffffc02023c0:	b0c68693          	addi	a3,a3,-1268 # ffffffffc0205ec8 <commands+0xe48>
ffffffffc02023c4:	00003617          	auipc	a2,0x3
ffffffffc02023c8:	51c60613          	addi	a2,a2,1308 # ffffffffc02058e0 <commands+0x860>
ffffffffc02023cc:	05700593          	li	a1,87
ffffffffc02023d0:	00004517          	auipc	a0,0x4
ffffffffc02023d4:	d5050513          	addi	a0,a0,-688 # ffffffffc0206120 <commands+0x10a0>
ffffffffc02023d8:	dfffd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(pgfault_num==4);
ffffffffc02023dc:	00004697          	auipc	a3,0x4
ffffffffc02023e0:	aec68693          	addi	a3,a3,-1300 # ffffffffc0205ec8 <commands+0xe48>
ffffffffc02023e4:	00003617          	auipc	a2,0x3
ffffffffc02023e8:	4fc60613          	addi	a2,a2,1276 # ffffffffc02058e0 <commands+0x860>
ffffffffc02023ec:	05400593          	li	a1,84
ffffffffc02023f0:	00004517          	auipc	a0,0x4
ffffffffc02023f4:	d3050513          	addi	a0,a0,-720 # ffffffffc0206120 <commands+0x10a0>
ffffffffc02023f8:	ddffd0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc02023fc <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc02023fc:	751c                	ld	a5,40(a0)
{
ffffffffc02023fe:	1141                	addi	sp,sp,-16
ffffffffc0202400:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc0202402:	cf91                	beqz	a5,ffffffffc020241e <_fifo_swap_out_victim+0x22>
     assert(in_tick==0);
ffffffffc0202404:	ee0d                	bnez	a2,ffffffffc020243e <_fifo_swap_out_victim+0x42>
    return listelm->next;
ffffffffc0202406:	679c                	ld	a5,8(a5)
}
ffffffffc0202408:	60a2                	ld	ra,8(sp)
ffffffffc020240a:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc020240c:	6394                	ld	a3,0(a5)
ffffffffc020240e:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc0202410:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc0202414:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0202416:	e314                	sd	a3,0(a4)
ffffffffc0202418:	e19c                	sd	a5,0(a1)
}
ffffffffc020241a:	0141                	addi	sp,sp,16
ffffffffc020241c:	8082                	ret
         assert(head != NULL);
ffffffffc020241e:	00004697          	auipc	a3,0x4
ffffffffc0202422:	e7268693          	addi	a3,a3,-398 # ffffffffc0206290 <commands+0x1210>
ffffffffc0202426:	00003617          	auipc	a2,0x3
ffffffffc020242a:	4ba60613          	addi	a2,a2,1210 # ffffffffc02058e0 <commands+0x860>
ffffffffc020242e:	04100593          	li	a1,65
ffffffffc0202432:	00004517          	auipc	a0,0x4
ffffffffc0202436:	cee50513          	addi	a0,a0,-786 # ffffffffc0206120 <commands+0x10a0>
ffffffffc020243a:	d9dfd0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert(in_tick==0);
ffffffffc020243e:	00004697          	auipc	a3,0x4
ffffffffc0202442:	e6268693          	addi	a3,a3,-414 # ffffffffc02062a0 <commands+0x1220>
ffffffffc0202446:	00003617          	auipc	a2,0x3
ffffffffc020244a:	49a60613          	addi	a2,a2,1178 # ffffffffc02058e0 <commands+0x860>
ffffffffc020244e:	04200593          	li	a1,66
ffffffffc0202452:	00004517          	auipc	a0,0x4
ffffffffc0202456:	cce50513          	addi	a0,a0,-818 # ffffffffc0206120 <commands+0x10a0>
ffffffffc020245a:	d7dfd0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc020245e <_fifo_map_swappable>:
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc020245e:	02860713          	addi	a4,a2,40
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0202462:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc0202464:	cb09                	beqz	a4,ffffffffc0202476 <_fifo_map_swappable+0x18>
ffffffffc0202466:	cb81                	beqz	a5,ffffffffc0202476 <_fifo_map_swappable+0x18>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0202468:	6394                	ld	a3,0(a5)
    prev->next = next->prev = elm;
ffffffffc020246a:	e398                	sd	a4,0(a5)
}
ffffffffc020246c:	4501                	li	a0,0
ffffffffc020246e:	e698                	sd	a4,8(a3)
    elm->next = next;
ffffffffc0202470:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc0202472:	f614                	sd	a3,40(a2)
ffffffffc0202474:	8082                	ret
{
ffffffffc0202476:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0202478:	00004697          	auipc	a3,0x4
ffffffffc020247c:	df868693          	addi	a3,a3,-520 # ffffffffc0206270 <commands+0x11f0>
ffffffffc0202480:	00003617          	auipc	a2,0x3
ffffffffc0202484:	46060613          	addi	a2,a2,1120 # ffffffffc02058e0 <commands+0x860>
ffffffffc0202488:	03200593          	li	a1,50
ffffffffc020248c:	00004517          	auipc	a0,0x4
ffffffffc0202490:	c9450513          	addi	a0,a0,-876 # ffffffffc0206120 <commands+0x10a0>
{
ffffffffc0202494:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc0202496:	d41fd0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc020249a <default_init>:
    elm->prev = elm->next = elm;
ffffffffc020249a:	00014797          	auipc	a5,0x14
ffffffffc020249e:	11e78793          	addi	a5,a5,286 # ffffffffc02165b8 <free_area>
ffffffffc02024a2:	e79c                	sd	a5,8(a5)
ffffffffc02024a4:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc02024a6:	0007a823          	sw	zero,16(a5)
}
ffffffffc02024aa:	8082                	ret

ffffffffc02024ac <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc02024ac:	00014517          	auipc	a0,0x14
ffffffffc02024b0:	11c56503          	lwu	a0,284(a0) # ffffffffc02165c8 <free_area+0x10>
ffffffffc02024b4:	8082                	ret

ffffffffc02024b6 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc02024b6:	715d                	addi	sp,sp,-80
ffffffffc02024b8:	f84a                	sd	s2,48(sp)
    return listelm->next;
ffffffffc02024ba:	00014917          	auipc	s2,0x14
ffffffffc02024be:	0fe90913          	addi	s2,s2,254 # ffffffffc02165b8 <free_area>
ffffffffc02024c2:	00893783          	ld	a5,8(s2)
ffffffffc02024c6:	e486                	sd	ra,72(sp)
ffffffffc02024c8:	e0a2                	sd	s0,64(sp)
ffffffffc02024ca:	fc26                	sd	s1,56(sp)
ffffffffc02024cc:	f44e                	sd	s3,40(sp)
ffffffffc02024ce:	f052                	sd	s4,32(sp)
ffffffffc02024d0:	ec56                	sd	s5,24(sp)
ffffffffc02024d2:	e85a                	sd	s6,16(sp)
ffffffffc02024d4:	e45e                	sd	s7,8(sp)
ffffffffc02024d6:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc02024d8:	31278463          	beq	a5,s2,ffffffffc02027e0 <default_check+0x32a>
ffffffffc02024dc:	ff07b703          	ld	a4,-16(a5)
ffffffffc02024e0:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc02024e2:	8b05                	andi	a4,a4,1
ffffffffc02024e4:	30070263          	beqz	a4,ffffffffc02027e8 <default_check+0x332>
    int count = 0, total = 0;
ffffffffc02024e8:	4401                	li	s0,0
ffffffffc02024ea:	4481                	li	s1,0
ffffffffc02024ec:	a031                	j	ffffffffc02024f8 <default_check+0x42>
ffffffffc02024ee:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc02024f2:	8b09                	andi	a4,a4,2
ffffffffc02024f4:	2e070a63          	beqz	a4,ffffffffc02027e8 <default_check+0x332>
        count ++, total += p->property;
ffffffffc02024f8:	ff87a703          	lw	a4,-8(a5)
ffffffffc02024fc:	679c                	ld	a5,8(a5)
ffffffffc02024fe:	2485                	addiw	s1,s1,1
ffffffffc0202500:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202502:	ff2796e3          	bne	a5,s2,ffffffffc02024ee <default_check+0x38>
ffffffffc0202506:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0202508:	3cb000ef          	jal	ra,ffffffffc02030d2 <nr_free_pages>
ffffffffc020250c:	73351e63          	bne	a0,s3,ffffffffc0202c48 <default_check+0x792>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202510:	4505                	li	a0,1
ffffffffc0202512:	2f3000ef          	jal	ra,ffffffffc0203004 <alloc_pages>
ffffffffc0202516:	8a2a                	mv	s4,a0
ffffffffc0202518:	46050863          	beqz	a0,ffffffffc0202988 <default_check+0x4d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020251c:	4505                	li	a0,1
ffffffffc020251e:	2e7000ef          	jal	ra,ffffffffc0203004 <alloc_pages>
ffffffffc0202522:	89aa                	mv	s3,a0
ffffffffc0202524:	74050263          	beqz	a0,ffffffffc0202c68 <default_check+0x7b2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202528:	4505                	li	a0,1
ffffffffc020252a:	2db000ef          	jal	ra,ffffffffc0203004 <alloc_pages>
ffffffffc020252e:	8aaa                	mv	s5,a0
ffffffffc0202530:	4c050c63          	beqz	a0,ffffffffc0202a08 <default_check+0x552>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0202534:	2d3a0a63          	beq	s4,s3,ffffffffc0202808 <default_check+0x352>
ffffffffc0202538:	2caa0863          	beq	s4,a0,ffffffffc0202808 <default_check+0x352>
ffffffffc020253c:	2ca98663          	beq	s3,a0,ffffffffc0202808 <default_check+0x352>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0202540:	000a2783          	lw	a5,0(s4)
ffffffffc0202544:	2e079263          	bnez	a5,ffffffffc0202828 <default_check+0x372>
ffffffffc0202548:	0009a783          	lw	a5,0(s3)
ffffffffc020254c:	2c079e63          	bnez	a5,ffffffffc0202828 <default_check+0x372>
ffffffffc0202550:	411c                	lw	a5,0(a0)
ffffffffc0202552:	2c079b63          	bnez	a5,ffffffffc0202828 <default_check+0x372>
    return page - pages + nbase;
ffffffffc0202556:	00014797          	auipc	a5,0x14
ffffffffc020255a:	09278793          	addi	a5,a5,146 # ffffffffc02165e8 <pages>
ffffffffc020255e:	639c                	ld	a5,0(a5)
ffffffffc0202560:	00005717          	auipc	a4,0x5
ffffffffc0202564:	cc070713          	addi	a4,a4,-832 # ffffffffc0207220 <nbase>
ffffffffc0202568:	6310                	ld	a2,0(a4)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc020256a:	00014717          	auipc	a4,0x14
ffffffffc020256e:	f3e70713          	addi	a4,a4,-194 # ffffffffc02164a8 <npage>
ffffffffc0202572:	6314                	ld	a3,0(a4)
ffffffffc0202574:	40fa0733          	sub	a4,s4,a5
ffffffffc0202578:	8719                	srai	a4,a4,0x6
ffffffffc020257a:	9732                	add	a4,a4,a2
ffffffffc020257c:	06b2                	slli	a3,a3,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020257e:	0732                	slli	a4,a4,0xc
ffffffffc0202580:	2cd77463          	bleu	a3,a4,ffffffffc0202848 <default_check+0x392>
    return page - pages + nbase;
ffffffffc0202584:	40f98733          	sub	a4,s3,a5
ffffffffc0202588:	8719                	srai	a4,a4,0x6
ffffffffc020258a:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc020258c:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc020258e:	4ed77d63          	bleu	a3,a4,ffffffffc0202a88 <default_check+0x5d2>
    return page - pages + nbase;
ffffffffc0202592:	40f507b3          	sub	a5,a0,a5
ffffffffc0202596:	8799                	srai	a5,a5,0x6
ffffffffc0202598:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc020259a:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc020259c:	34d7f663          	bleu	a3,a5,ffffffffc02028e8 <default_check+0x432>
    assert(alloc_page() == NULL);
ffffffffc02025a0:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02025a2:	00093c03          	ld	s8,0(s2)
ffffffffc02025a6:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc02025aa:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc02025ae:	00014797          	auipc	a5,0x14
ffffffffc02025b2:	0127b923          	sd	s2,18(a5) # ffffffffc02165c0 <free_area+0x8>
ffffffffc02025b6:	00014797          	auipc	a5,0x14
ffffffffc02025ba:	0127b123          	sd	s2,2(a5) # ffffffffc02165b8 <free_area>
    nr_free = 0;
ffffffffc02025be:	00014797          	auipc	a5,0x14
ffffffffc02025c2:	0007a523          	sw	zero,10(a5) # ffffffffc02165c8 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc02025c6:	23f000ef          	jal	ra,ffffffffc0203004 <alloc_pages>
ffffffffc02025ca:	2e051f63          	bnez	a0,ffffffffc02028c8 <default_check+0x412>
    free_page(p0);
ffffffffc02025ce:	4585                	li	a1,1
ffffffffc02025d0:	8552                	mv	a0,s4
ffffffffc02025d2:	2bb000ef          	jal	ra,ffffffffc020308c <free_pages>
    free_page(p1);
ffffffffc02025d6:	4585                	li	a1,1
ffffffffc02025d8:	854e                	mv	a0,s3
ffffffffc02025da:	2b3000ef          	jal	ra,ffffffffc020308c <free_pages>
    free_page(p2);
ffffffffc02025de:	4585                	li	a1,1
ffffffffc02025e0:	8556                	mv	a0,s5
ffffffffc02025e2:	2ab000ef          	jal	ra,ffffffffc020308c <free_pages>
    assert(nr_free == 3);
ffffffffc02025e6:	01092703          	lw	a4,16(s2)
ffffffffc02025ea:	478d                	li	a5,3
ffffffffc02025ec:	2af71e63          	bne	a4,a5,ffffffffc02028a8 <default_check+0x3f2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02025f0:	4505                	li	a0,1
ffffffffc02025f2:	213000ef          	jal	ra,ffffffffc0203004 <alloc_pages>
ffffffffc02025f6:	89aa                	mv	s3,a0
ffffffffc02025f8:	28050863          	beqz	a0,ffffffffc0202888 <default_check+0x3d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02025fc:	4505                	li	a0,1
ffffffffc02025fe:	207000ef          	jal	ra,ffffffffc0203004 <alloc_pages>
ffffffffc0202602:	8aaa                	mv	s5,a0
ffffffffc0202604:	3e050263          	beqz	a0,ffffffffc02029e8 <default_check+0x532>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202608:	4505                	li	a0,1
ffffffffc020260a:	1fb000ef          	jal	ra,ffffffffc0203004 <alloc_pages>
ffffffffc020260e:	8a2a                	mv	s4,a0
ffffffffc0202610:	3a050c63          	beqz	a0,ffffffffc02029c8 <default_check+0x512>
    assert(alloc_page() == NULL);
ffffffffc0202614:	4505                	li	a0,1
ffffffffc0202616:	1ef000ef          	jal	ra,ffffffffc0203004 <alloc_pages>
ffffffffc020261a:	38051763          	bnez	a0,ffffffffc02029a8 <default_check+0x4f2>
    free_page(p0);
ffffffffc020261e:	4585                	li	a1,1
ffffffffc0202620:	854e                	mv	a0,s3
ffffffffc0202622:	26b000ef          	jal	ra,ffffffffc020308c <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0202626:	00893783          	ld	a5,8(s2)
ffffffffc020262a:	23278f63          	beq	a5,s2,ffffffffc0202868 <default_check+0x3b2>
    assert((p = alloc_page()) == p0);
ffffffffc020262e:	4505                	li	a0,1
ffffffffc0202630:	1d5000ef          	jal	ra,ffffffffc0203004 <alloc_pages>
ffffffffc0202634:	32a99a63          	bne	s3,a0,ffffffffc0202968 <default_check+0x4b2>
    assert(alloc_page() == NULL);
ffffffffc0202638:	4505                	li	a0,1
ffffffffc020263a:	1cb000ef          	jal	ra,ffffffffc0203004 <alloc_pages>
ffffffffc020263e:	30051563          	bnez	a0,ffffffffc0202948 <default_check+0x492>
    assert(nr_free == 0);
ffffffffc0202642:	01092783          	lw	a5,16(s2)
ffffffffc0202646:	2e079163          	bnez	a5,ffffffffc0202928 <default_check+0x472>
    free_page(p);
ffffffffc020264a:	854e                	mv	a0,s3
ffffffffc020264c:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc020264e:	00014797          	auipc	a5,0x14
ffffffffc0202652:	f787b523          	sd	s8,-150(a5) # ffffffffc02165b8 <free_area>
ffffffffc0202656:	00014797          	auipc	a5,0x14
ffffffffc020265a:	f777b523          	sd	s7,-150(a5) # ffffffffc02165c0 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc020265e:	00014797          	auipc	a5,0x14
ffffffffc0202662:	f767a523          	sw	s6,-150(a5) # ffffffffc02165c8 <free_area+0x10>
    free_page(p);
ffffffffc0202666:	227000ef          	jal	ra,ffffffffc020308c <free_pages>
    free_page(p1);
ffffffffc020266a:	4585                	li	a1,1
ffffffffc020266c:	8556                	mv	a0,s5
ffffffffc020266e:	21f000ef          	jal	ra,ffffffffc020308c <free_pages>
    free_page(p2);
ffffffffc0202672:	4585                	li	a1,1
ffffffffc0202674:	8552                	mv	a0,s4
ffffffffc0202676:	217000ef          	jal	ra,ffffffffc020308c <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc020267a:	4515                	li	a0,5
ffffffffc020267c:	189000ef          	jal	ra,ffffffffc0203004 <alloc_pages>
ffffffffc0202680:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0202682:	28050363          	beqz	a0,ffffffffc0202908 <default_check+0x452>
ffffffffc0202686:	651c                	ld	a5,8(a0)
ffffffffc0202688:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc020268a:	8b85                	andi	a5,a5,1
ffffffffc020268c:	54079e63          	bnez	a5,ffffffffc0202be8 <default_check+0x732>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0202690:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0202692:	00093b03          	ld	s6,0(s2)
ffffffffc0202696:	00893a83          	ld	s5,8(s2)
ffffffffc020269a:	00014797          	auipc	a5,0x14
ffffffffc020269e:	f127bf23          	sd	s2,-226(a5) # ffffffffc02165b8 <free_area>
ffffffffc02026a2:	00014797          	auipc	a5,0x14
ffffffffc02026a6:	f127bf23          	sd	s2,-226(a5) # ffffffffc02165c0 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc02026aa:	15b000ef          	jal	ra,ffffffffc0203004 <alloc_pages>
ffffffffc02026ae:	50051d63          	bnez	a0,ffffffffc0202bc8 <default_check+0x712>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc02026b2:	08098a13          	addi	s4,s3,128
ffffffffc02026b6:	8552                	mv	a0,s4
ffffffffc02026b8:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc02026ba:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc02026be:	00014797          	auipc	a5,0x14
ffffffffc02026c2:	f007a523          	sw	zero,-246(a5) # ffffffffc02165c8 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc02026c6:	1c7000ef          	jal	ra,ffffffffc020308c <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc02026ca:	4511                	li	a0,4
ffffffffc02026cc:	139000ef          	jal	ra,ffffffffc0203004 <alloc_pages>
ffffffffc02026d0:	4c051c63          	bnez	a0,ffffffffc0202ba8 <default_check+0x6f2>
ffffffffc02026d4:	0889b783          	ld	a5,136(s3)
ffffffffc02026d8:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02026da:	8b85                	andi	a5,a5,1
ffffffffc02026dc:	4a078663          	beqz	a5,ffffffffc0202b88 <default_check+0x6d2>
ffffffffc02026e0:	0909a703          	lw	a4,144(s3)
ffffffffc02026e4:	478d                	li	a5,3
ffffffffc02026e6:	4af71163          	bne	a4,a5,ffffffffc0202b88 <default_check+0x6d2>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02026ea:	450d                	li	a0,3
ffffffffc02026ec:	119000ef          	jal	ra,ffffffffc0203004 <alloc_pages>
ffffffffc02026f0:	8c2a                	mv	s8,a0
ffffffffc02026f2:	46050b63          	beqz	a0,ffffffffc0202b68 <default_check+0x6b2>
    assert(alloc_page() == NULL);
ffffffffc02026f6:	4505                	li	a0,1
ffffffffc02026f8:	10d000ef          	jal	ra,ffffffffc0203004 <alloc_pages>
ffffffffc02026fc:	44051663          	bnez	a0,ffffffffc0202b48 <default_check+0x692>
    assert(p0 + 2 == p1);
ffffffffc0202700:	438a1463          	bne	s4,s8,ffffffffc0202b28 <default_check+0x672>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0202704:	4585                	li	a1,1
ffffffffc0202706:	854e                	mv	a0,s3
ffffffffc0202708:	185000ef          	jal	ra,ffffffffc020308c <free_pages>
    free_pages(p1, 3);
ffffffffc020270c:	458d                	li	a1,3
ffffffffc020270e:	8552                	mv	a0,s4
ffffffffc0202710:	17d000ef          	jal	ra,ffffffffc020308c <free_pages>
ffffffffc0202714:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0202718:	04098c13          	addi	s8,s3,64
ffffffffc020271c:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc020271e:	8b85                	andi	a5,a5,1
ffffffffc0202720:	3e078463          	beqz	a5,ffffffffc0202b08 <default_check+0x652>
ffffffffc0202724:	0109a703          	lw	a4,16(s3)
ffffffffc0202728:	4785                	li	a5,1
ffffffffc020272a:	3cf71f63          	bne	a4,a5,ffffffffc0202b08 <default_check+0x652>
ffffffffc020272e:	008a3783          	ld	a5,8(s4)
ffffffffc0202732:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0202734:	8b85                	andi	a5,a5,1
ffffffffc0202736:	3a078963          	beqz	a5,ffffffffc0202ae8 <default_check+0x632>
ffffffffc020273a:	010a2703          	lw	a4,16(s4)
ffffffffc020273e:	478d                	li	a5,3
ffffffffc0202740:	3af71463          	bne	a4,a5,ffffffffc0202ae8 <default_check+0x632>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0202744:	4505                	li	a0,1
ffffffffc0202746:	0bf000ef          	jal	ra,ffffffffc0203004 <alloc_pages>
ffffffffc020274a:	36a99f63          	bne	s3,a0,ffffffffc0202ac8 <default_check+0x612>
    free_page(p0);
ffffffffc020274e:	4585                	li	a1,1
ffffffffc0202750:	13d000ef          	jal	ra,ffffffffc020308c <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0202754:	4509                	li	a0,2
ffffffffc0202756:	0af000ef          	jal	ra,ffffffffc0203004 <alloc_pages>
ffffffffc020275a:	34aa1763          	bne	s4,a0,ffffffffc0202aa8 <default_check+0x5f2>

    free_pages(p0, 2);
ffffffffc020275e:	4589                	li	a1,2
ffffffffc0202760:	12d000ef          	jal	ra,ffffffffc020308c <free_pages>
    free_page(p2);
ffffffffc0202764:	4585                	li	a1,1
ffffffffc0202766:	8562                	mv	a0,s8
ffffffffc0202768:	125000ef          	jal	ra,ffffffffc020308c <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc020276c:	4515                	li	a0,5
ffffffffc020276e:	097000ef          	jal	ra,ffffffffc0203004 <alloc_pages>
ffffffffc0202772:	89aa                	mv	s3,a0
ffffffffc0202774:	48050a63          	beqz	a0,ffffffffc0202c08 <default_check+0x752>
    assert(alloc_page() == NULL);
ffffffffc0202778:	4505                	li	a0,1
ffffffffc020277a:	08b000ef          	jal	ra,ffffffffc0203004 <alloc_pages>
ffffffffc020277e:	2e051563          	bnez	a0,ffffffffc0202a68 <default_check+0x5b2>

    assert(nr_free == 0);
ffffffffc0202782:	01092783          	lw	a5,16(s2)
ffffffffc0202786:	2c079163          	bnez	a5,ffffffffc0202a48 <default_check+0x592>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc020278a:	4595                	li	a1,5
ffffffffc020278c:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc020278e:	00014797          	auipc	a5,0x14
ffffffffc0202792:	e377ad23          	sw	s7,-454(a5) # ffffffffc02165c8 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0202796:	00014797          	auipc	a5,0x14
ffffffffc020279a:	e367b123          	sd	s6,-478(a5) # ffffffffc02165b8 <free_area>
ffffffffc020279e:	00014797          	auipc	a5,0x14
ffffffffc02027a2:	e357b123          	sd	s5,-478(a5) # ffffffffc02165c0 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc02027a6:	0e7000ef          	jal	ra,ffffffffc020308c <free_pages>
    return listelm->next;
ffffffffc02027aa:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc02027ae:	01278963          	beq	a5,s2,ffffffffc02027c0 <default_check+0x30a>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc02027b2:	ff87a703          	lw	a4,-8(a5)
ffffffffc02027b6:	679c                	ld	a5,8(a5)
ffffffffc02027b8:	34fd                	addiw	s1,s1,-1
ffffffffc02027ba:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc02027bc:	ff279be3          	bne	a5,s2,ffffffffc02027b2 <default_check+0x2fc>
    }
    assert(count == 0);
ffffffffc02027c0:	26049463          	bnez	s1,ffffffffc0202a28 <default_check+0x572>
    assert(total == 0);
ffffffffc02027c4:	46041263          	bnez	s0,ffffffffc0202c28 <default_check+0x772>
}
ffffffffc02027c8:	60a6                	ld	ra,72(sp)
ffffffffc02027ca:	6406                	ld	s0,64(sp)
ffffffffc02027cc:	74e2                	ld	s1,56(sp)
ffffffffc02027ce:	7942                	ld	s2,48(sp)
ffffffffc02027d0:	79a2                	ld	s3,40(sp)
ffffffffc02027d2:	7a02                	ld	s4,32(sp)
ffffffffc02027d4:	6ae2                	ld	s5,24(sp)
ffffffffc02027d6:	6b42                	ld	s6,16(sp)
ffffffffc02027d8:	6ba2                	ld	s7,8(sp)
ffffffffc02027da:	6c02                	ld	s8,0(sp)
ffffffffc02027dc:	6161                	addi	sp,sp,80
ffffffffc02027de:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc02027e0:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc02027e2:	4401                	li	s0,0
ffffffffc02027e4:	4481                	li	s1,0
ffffffffc02027e6:	b30d                	j	ffffffffc0202508 <default_check+0x52>
        assert(PageProperty(p));
ffffffffc02027e8:	00003697          	auipc	a3,0x3
ffffffffc02027ec:	54068693          	addi	a3,a3,1344 # ffffffffc0205d28 <commands+0xca8>
ffffffffc02027f0:	00003617          	auipc	a2,0x3
ffffffffc02027f4:	0f060613          	addi	a2,a2,240 # ffffffffc02058e0 <commands+0x860>
ffffffffc02027f8:	0f000593          	li	a1,240
ffffffffc02027fc:	00004517          	auipc	a0,0x4
ffffffffc0202800:	acc50513          	addi	a0,a0,-1332 # ffffffffc02062c8 <commands+0x1248>
ffffffffc0202804:	9d3fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0202808:	00004697          	auipc	a3,0x4
ffffffffc020280c:	b3868693          	addi	a3,a3,-1224 # ffffffffc0206340 <commands+0x12c0>
ffffffffc0202810:	00003617          	auipc	a2,0x3
ffffffffc0202814:	0d060613          	addi	a2,a2,208 # ffffffffc02058e0 <commands+0x860>
ffffffffc0202818:	0bd00593          	li	a1,189
ffffffffc020281c:	00004517          	auipc	a0,0x4
ffffffffc0202820:	aac50513          	addi	a0,a0,-1364 # ffffffffc02062c8 <commands+0x1248>
ffffffffc0202824:	9b3fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0202828:	00004697          	auipc	a3,0x4
ffffffffc020282c:	b4068693          	addi	a3,a3,-1216 # ffffffffc0206368 <commands+0x12e8>
ffffffffc0202830:	00003617          	auipc	a2,0x3
ffffffffc0202834:	0b060613          	addi	a2,a2,176 # ffffffffc02058e0 <commands+0x860>
ffffffffc0202838:	0be00593          	li	a1,190
ffffffffc020283c:	00004517          	auipc	a0,0x4
ffffffffc0202840:	a8c50513          	addi	a0,a0,-1396 # ffffffffc02062c8 <commands+0x1248>
ffffffffc0202844:	993fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0202848:	00004697          	auipc	a3,0x4
ffffffffc020284c:	b6068693          	addi	a3,a3,-1184 # ffffffffc02063a8 <commands+0x1328>
ffffffffc0202850:	00003617          	auipc	a2,0x3
ffffffffc0202854:	09060613          	addi	a2,a2,144 # ffffffffc02058e0 <commands+0x860>
ffffffffc0202858:	0c000593          	li	a1,192
ffffffffc020285c:	00004517          	auipc	a0,0x4
ffffffffc0202860:	a6c50513          	addi	a0,a0,-1428 # ffffffffc02062c8 <commands+0x1248>
ffffffffc0202864:	973fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0202868:	00004697          	auipc	a3,0x4
ffffffffc020286c:	bc868693          	addi	a3,a3,-1080 # ffffffffc0206430 <commands+0x13b0>
ffffffffc0202870:	00003617          	auipc	a2,0x3
ffffffffc0202874:	07060613          	addi	a2,a2,112 # ffffffffc02058e0 <commands+0x860>
ffffffffc0202878:	0d900593          	li	a1,217
ffffffffc020287c:	00004517          	auipc	a0,0x4
ffffffffc0202880:	a4c50513          	addi	a0,a0,-1460 # ffffffffc02062c8 <commands+0x1248>
ffffffffc0202884:	953fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202888:	00004697          	auipc	a3,0x4
ffffffffc020288c:	a5868693          	addi	a3,a3,-1448 # ffffffffc02062e0 <commands+0x1260>
ffffffffc0202890:	00003617          	auipc	a2,0x3
ffffffffc0202894:	05060613          	addi	a2,a2,80 # ffffffffc02058e0 <commands+0x860>
ffffffffc0202898:	0d200593          	li	a1,210
ffffffffc020289c:	00004517          	auipc	a0,0x4
ffffffffc02028a0:	a2c50513          	addi	a0,a0,-1492 # ffffffffc02062c8 <commands+0x1248>
ffffffffc02028a4:	933fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(nr_free == 3);
ffffffffc02028a8:	00004697          	auipc	a3,0x4
ffffffffc02028ac:	b7868693          	addi	a3,a3,-1160 # ffffffffc0206420 <commands+0x13a0>
ffffffffc02028b0:	00003617          	auipc	a2,0x3
ffffffffc02028b4:	03060613          	addi	a2,a2,48 # ffffffffc02058e0 <commands+0x860>
ffffffffc02028b8:	0d000593          	li	a1,208
ffffffffc02028bc:	00004517          	auipc	a0,0x4
ffffffffc02028c0:	a0c50513          	addi	a0,a0,-1524 # ffffffffc02062c8 <commands+0x1248>
ffffffffc02028c4:	913fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02028c8:	00004697          	auipc	a3,0x4
ffffffffc02028cc:	b4068693          	addi	a3,a3,-1216 # ffffffffc0206408 <commands+0x1388>
ffffffffc02028d0:	00003617          	auipc	a2,0x3
ffffffffc02028d4:	01060613          	addi	a2,a2,16 # ffffffffc02058e0 <commands+0x860>
ffffffffc02028d8:	0cb00593          	li	a1,203
ffffffffc02028dc:	00004517          	auipc	a0,0x4
ffffffffc02028e0:	9ec50513          	addi	a0,a0,-1556 # ffffffffc02062c8 <commands+0x1248>
ffffffffc02028e4:	8f3fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02028e8:	00004697          	auipc	a3,0x4
ffffffffc02028ec:	b0068693          	addi	a3,a3,-1280 # ffffffffc02063e8 <commands+0x1368>
ffffffffc02028f0:	00003617          	auipc	a2,0x3
ffffffffc02028f4:	ff060613          	addi	a2,a2,-16 # ffffffffc02058e0 <commands+0x860>
ffffffffc02028f8:	0c200593          	li	a1,194
ffffffffc02028fc:	00004517          	auipc	a0,0x4
ffffffffc0202900:	9cc50513          	addi	a0,a0,-1588 # ffffffffc02062c8 <commands+0x1248>
ffffffffc0202904:	8d3fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(p0 != NULL);
ffffffffc0202908:	00004697          	auipc	a3,0x4
ffffffffc020290c:	b6068693          	addi	a3,a3,-1184 # ffffffffc0206468 <commands+0x13e8>
ffffffffc0202910:	00003617          	auipc	a2,0x3
ffffffffc0202914:	fd060613          	addi	a2,a2,-48 # ffffffffc02058e0 <commands+0x860>
ffffffffc0202918:	0f800593          	li	a1,248
ffffffffc020291c:	00004517          	auipc	a0,0x4
ffffffffc0202920:	9ac50513          	addi	a0,a0,-1620 # ffffffffc02062c8 <commands+0x1248>
ffffffffc0202924:	8b3fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(nr_free == 0);
ffffffffc0202928:	00003697          	auipc	a3,0x3
ffffffffc020292c:	5b068693          	addi	a3,a3,1456 # ffffffffc0205ed8 <commands+0xe58>
ffffffffc0202930:	00003617          	auipc	a2,0x3
ffffffffc0202934:	fb060613          	addi	a2,a2,-80 # ffffffffc02058e0 <commands+0x860>
ffffffffc0202938:	0df00593          	li	a1,223
ffffffffc020293c:	00004517          	auipc	a0,0x4
ffffffffc0202940:	98c50513          	addi	a0,a0,-1652 # ffffffffc02062c8 <commands+0x1248>
ffffffffc0202944:	893fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202948:	00004697          	auipc	a3,0x4
ffffffffc020294c:	ac068693          	addi	a3,a3,-1344 # ffffffffc0206408 <commands+0x1388>
ffffffffc0202950:	00003617          	auipc	a2,0x3
ffffffffc0202954:	f9060613          	addi	a2,a2,-112 # ffffffffc02058e0 <commands+0x860>
ffffffffc0202958:	0dd00593          	li	a1,221
ffffffffc020295c:	00004517          	auipc	a0,0x4
ffffffffc0202960:	96c50513          	addi	a0,a0,-1684 # ffffffffc02062c8 <commands+0x1248>
ffffffffc0202964:	873fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0202968:	00004697          	auipc	a3,0x4
ffffffffc020296c:	ae068693          	addi	a3,a3,-1312 # ffffffffc0206448 <commands+0x13c8>
ffffffffc0202970:	00003617          	auipc	a2,0x3
ffffffffc0202974:	f7060613          	addi	a2,a2,-144 # ffffffffc02058e0 <commands+0x860>
ffffffffc0202978:	0dc00593          	li	a1,220
ffffffffc020297c:	00004517          	auipc	a0,0x4
ffffffffc0202980:	94c50513          	addi	a0,a0,-1716 # ffffffffc02062c8 <commands+0x1248>
ffffffffc0202984:	853fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202988:	00004697          	auipc	a3,0x4
ffffffffc020298c:	95868693          	addi	a3,a3,-1704 # ffffffffc02062e0 <commands+0x1260>
ffffffffc0202990:	00003617          	auipc	a2,0x3
ffffffffc0202994:	f5060613          	addi	a2,a2,-176 # ffffffffc02058e0 <commands+0x860>
ffffffffc0202998:	0b900593          	li	a1,185
ffffffffc020299c:	00004517          	auipc	a0,0x4
ffffffffc02029a0:	92c50513          	addi	a0,a0,-1748 # ffffffffc02062c8 <commands+0x1248>
ffffffffc02029a4:	833fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02029a8:	00004697          	auipc	a3,0x4
ffffffffc02029ac:	a6068693          	addi	a3,a3,-1440 # ffffffffc0206408 <commands+0x1388>
ffffffffc02029b0:	00003617          	auipc	a2,0x3
ffffffffc02029b4:	f3060613          	addi	a2,a2,-208 # ffffffffc02058e0 <commands+0x860>
ffffffffc02029b8:	0d600593          	li	a1,214
ffffffffc02029bc:	00004517          	auipc	a0,0x4
ffffffffc02029c0:	90c50513          	addi	a0,a0,-1780 # ffffffffc02062c8 <commands+0x1248>
ffffffffc02029c4:	813fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02029c8:	00004697          	auipc	a3,0x4
ffffffffc02029cc:	95868693          	addi	a3,a3,-1704 # ffffffffc0206320 <commands+0x12a0>
ffffffffc02029d0:	00003617          	auipc	a2,0x3
ffffffffc02029d4:	f1060613          	addi	a2,a2,-240 # ffffffffc02058e0 <commands+0x860>
ffffffffc02029d8:	0d400593          	li	a1,212
ffffffffc02029dc:	00004517          	auipc	a0,0x4
ffffffffc02029e0:	8ec50513          	addi	a0,a0,-1812 # ffffffffc02062c8 <commands+0x1248>
ffffffffc02029e4:	ff2fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02029e8:	00004697          	auipc	a3,0x4
ffffffffc02029ec:	91868693          	addi	a3,a3,-1768 # ffffffffc0206300 <commands+0x1280>
ffffffffc02029f0:	00003617          	auipc	a2,0x3
ffffffffc02029f4:	ef060613          	addi	a2,a2,-272 # ffffffffc02058e0 <commands+0x860>
ffffffffc02029f8:	0d300593          	li	a1,211
ffffffffc02029fc:	00004517          	auipc	a0,0x4
ffffffffc0202a00:	8cc50513          	addi	a0,a0,-1844 # ffffffffc02062c8 <commands+0x1248>
ffffffffc0202a04:	fd2fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202a08:	00004697          	auipc	a3,0x4
ffffffffc0202a0c:	91868693          	addi	a3,a3,-1768 # ffffffffc0206320 <commands+0x12a0>
ffffffffc0202a10:	00003617          	auipc	a2,0x3
ffffffffc0202a14:	ed060613          	addi	a2,a2,-304 # ffffffffc02058e0 <commands+0x860>
ffffffffc0202a18:	0bb00593          	li	a1,187
ffffffffc0202a1c:	00004517          	auipc	a0,0x4
ffffffffc0202a20:	8ac50513          	addi	a0,a0,-1876 # ffffffffc02062c8 <commands+0x1248>
ffffffffc0202a24:	fb2fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(count == 0);
ffffffffc0202a28:	00004697          	auipc	a3,0x4
ffffffffc0202a2c:	b9068693          	addi	a3,a3,-1136 # ffffffffc02065b8 <commands+0x1538>
ffffffffc0202a30:	00003617          	auipc	a2,0x3
ffffffffc0202a34:	eb060613          	addi	a2,a2,-336 # ffffffffc02058e0 <commands+0x860>
ffffffffc0202a38:	12500593          	li	a1,293
ffffffffc0202a3c:	00004517          	auipc	a0,0x4
ffffffffc0202a40:	88c50513          	addi	a0,a0,-1908 # ffffffffc02062c8 <commands+0x1248>
ffffffffc0202a44:	f92fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(nr_free == 0);
ffffffffc0202a48:	00003697          	auipc	a3,0x3
ffffffffc0202a4c:	49068693          	addi	a3,a3,1168 # ffffffffc0205ed8 <commands+0xe58>
ffffffffc0202a50:	00003617          	auipc	a2,0x3
ffffffffc0202a54:	e9060613          	addi	a2,a2,-368 # ffffffffc02058e0 <commands+0x860>
ffffffffc0202a58:	11a00593          	li	a1,282
ffffffffc0202a5c:	00004517          	auipc	a0,0x4
ffffffffc0202a60:	86c50513          	addi	a0,a0,-1940 # ffffffffc02062c8 <commands+0x1248>
ffffffffc0202a64:	f72fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202a68:	00004697          	auipc	a3,0x4
ffffffffc0202a6c:	9a068693          	addi	a3,a3,-1632 # ffffffffc0206408 <commands+0x1388>
ffffffffc0202a70:	00003617          	auipc	a2,0x3
ffffffffc0202a74:	e7060613          	addi	a2,a2,-400 # ffffffffc02058e0 <commands+0x860>
ffffffffc0202a78:	11800593          	li	a1,280
ffffffffc0202a7c:	00004517          	auipc	a0,0x4
ffffffffc0202a80:	84c50513          	addi	a0,a0,-1972 # ffffffffc02062c8 <commands+0x1248>
ffffffffc0202a84:	f52fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0202a88:	00004697          	auipc	a3,0x4
ffffffffc0202a8c:	94068693          	addi	a3,a3,-1728 # ffffffffc02063c8 <commands+0x1348>
ffffffffc0202a90:	00003617          	auipc	a2,0x3
ffffffffc0202a94:	e5060613          	addi	a2,a2,-432 # ffffffffc02058e0 <commands+0x860>
ffffffffc0202a98:	0c100593          	li	a1,193
ffffffffc0202a9c:	00004517          	auipc	a0,0x4
ffffffffc0202aa0:	82c50513          	addi	a0,a0,-2004 # ffffffffc02062c8 <commands+0x1248>
ffffffffc0202aa4:	f32fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0202aa8:	00004697          	auipc	a3,0x4
ffffffffc0202aac:	ad068693          	addi	a3,a3,-1328 # ffffffffc0206578 <commands+0x14f8>
ffffffffc0202ab0:	00003617          	auipc	a2,0x3
ffffffffc0202ab4:	e3060613          	addi	a2,a2,-464 # ffffffffc02058e0 <commands+0x860>
ffffffffc0202ab8:	11200593          	li	a1,274
ffffffffc0202abc:	00004517          	auipc	a0,0x4
ffffffffc0202ac0:	80c50513          	addi	a0,a0,-2036 # ffffffffc02062c8 <commands+0x1248>
ffffffffc0202ac4:	f12fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0202ac8:	00004697          	auipc	a3,0x4
ffffffffc0202acc:	a9068693          	addi	a3,a3,-1392 # ffffffffc0206558 <commands+0x14d8>
ffffffffc0202ad0:	00003617          	auipc	a2,0x3
ffffffffc0202ad4:	e1060613          	addi	a2,a2,-496 # ffffffffc02058e0 <commands+0x860>
ffffffffc0202ad8:	11000593          	li	a1,272
ffffffffc0202adc:	00003517          	auipc	a0,0x3
ffffffffc0202ae0:	7ec50513          	addi	a0,a0,2028 # ffffffffc02062c8 <commands+0x1248>
ffffffffc0202ae4:	ef2fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0202ae8:	00004697          	auipc	a3,0x4
ffffffffc0202aec:	a4868693          	addi	a3,a3,-1464 # ffffffffc0206530 <commands+0x14b0>
ffffffffc0202af0:	00003617          	auipc	a2,0x3
ffffffffc0202af4:	df060613          	addi	a2,a2,-528 # ffffffffc02058e0 <commands+0x860>
ffffffffc0202af8:	10e00593          	li	a1,270
ffffffffc0202afc:	00003517          	auipc	a0,0x3
ffffffffc0202b00:	7cc50513          	addi	a0,a0,1996 # ffffffffc02062c8 <commands+0x1248>
ffffffffc0202b04:	ed2fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0202b08:	00004697          	auipc	a3,0x4
ffffffffc0202b0c:	a0068693          	addi	a3,a3,-1536 # ffffffffc0206508 <commands+0x1488>
ffffffffc0202b10:	00003617          	auipc	a2,0x3
ffffffffc0202b14:	dd060613          	addi	a2,a2,-560 # ffffffffc02058e0 <commands+0x860>
ffffffffc0202b18:	10d00593          	li	a1,269
ffffffffc0202b1c:	00003517          	auipc	a0,0x3
ffffffffc0202b20:	7ac50513          	addi	a0,a0,1964 # ffffffffc02062c8 <commands+0x1248>
ffffffffc0202b24:	eb2fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0202b28:	00004697          	auipc	a3,0x4
ffffffffc0202b2c:	9d068693          	addi	a3,a3,-1584 # ffffffffc02064f8 <commands+0x1478>
ffffffffc0202b30:	00003617          	auipc	a2,0x3
ffffffffc0202b34:	db060613          	addi	a2,a2,-592 # ffffffffc02058e0 <commands+0x860>
ffffffffc0202b38:	10800593          	li	a1,264
ffffffffc0202b3c:	00003517          	auipc	a0,0x3
ffffffffc0202b40:	78c50513          	addi	a0,a0,1932 # ffffffffc02062c8 <commands+0x1248>
ffffffffc0202b44:	e92fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202b48:	00004697          	auipc	a3,0x4
ffffffffc0202b4c:	8c068693          	addi	a3,a3,-1856 # ffffffffc0206408 <commands+0x1388>
ffffffffc0202b50:	00003617          	auipc	a2,0x3
ffffffffc0202b54:	d9060613          	addi	a2,a2,-624 # ffffffffc02058e0 <commands+0x860>
ffffffffc0202b58:	10700593          	li	a1,263
ffffffffc0202b5c:	00003517          	auipc	a0,0x3
ffffffffc0202b60:	76c50513          	addi	a0,a0,1900 # ffffffffc02062c8 <commands+0x1248>
ffffffffc0202b64:	e72fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0202b68:	00004697          	auipc	a3,0x4
ffffffffc0202b6c:	97068693          	addi	a3,a3,-1680 # ffffffffc02064d8 <commands+0x1458>
ffffffffc0202b70:	00003617          	auipc	a2,0x3
ffffffffc0202b74:	d7060613          	addi	a2,a2,-656 # ffffffffc02058e0 <commands+0x860>
ffffffffc0202b78:	10600593          	li	a1,262
ffffffffc0202b7c:	00003517          	auipc	a0,0x3
ffffffffc0202b80:	74c50513          	addi	a0,a0,1868 # ffffffffc02062c8 <commands+0x1248>
ffffffffc0202b84:	e52fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0202b88:	00004697          	auipc	a3,0x4
ffffffffc0202b8c:	92068693          	addi	a3,a3,-1760 # ffffffffc02064a8 <commands+0x1428>
ffffffffc0202b90:	00003617          	auipc	a2,0x3
ffffffffc0202b94:	d5060613          	addi	a2,a2,-688 # ffffffffc02058e0 <commands+0x860>
ffffffffc0202b98:	10500593          	li	a1,261
ffffffffc0202b9c:	00003517          	auipc	a0,0x3
ffffffffc0202ba0:	72c50513          	addi	a0,a0,1836 # ffffffffc02062c8 <commands+0x1248>
ffffffffc0202ba4:	e32fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0202ba8:	00004697          	auipc	a3,0x4
ffffffffc0202bac:	8e868693          	addi	a3,a3,-1816 # ffffffffc0206490 <commands+0x1410>
ffffffffc0202bb0:	00003617          	auipc	a2,0x3
ffffffffc0202bb4:	d3060613          	addi	a2,a2,-720 # ffffffffc02058e0 <commands+0x860>
ffffffffc0202bb8:	10400593          	li	a1,260
ffffffffc0202bbc:	00003517          	auipc	a0,0x3
ffffffffc0202bc0:	70c50513          	addi	a0,a0,1804 # ffffffffc02062c8 <commands+0x1248>
ffffffffc0202bc4:	e12fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202bc8:	00004697          	auipc	a3,0x4
ffffffffc0202bcc:	84068693          	addi	a3,a3,-1984 # ffffffffc0206408 <commands+0x1388>
ffffffffc0202bd0:	00003617          	auipc	a2,0x3
ffffffffc0202bd4:	d1060613          	addi	a2,a2,-752 # ffffffffc02058e0 <commands+0x860>
ffffffffc0202bd8:	0fe00593          	li	a1,254
ffffffffc0202bdc:	00003517          	auipc	a0,0x3
ffffffffc0202be0:	6ec50513          	addi	a0,a0,1772 # ffffffffc02062c8 <commands+0x1248>
ffffffffc0202be4:	df2fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(!PageProperty(p0));
ffffffffc0202be8:	00004697          	auipc	a3,0x4
ffffffffc0202bec:	89068693          	addi	a3,a3,-1904 # ffffffffc0206478 <commands+0x13f8>
ffffffffc0202bf0:	00003617          	auipc	a2,0x3
ffffffffc0202bf4:	cf060613          	addi	a2,a2,-784 # ffffffffc02058e0 <commands+0x860>
ffffffffc0202bf8:	0f900593          	li	a1,249
ffffffffc0202bfc:	00003517          	auipc	a0,0x3
ffffffffc0202c00:	6cc50513          	addi	a0,a0,1740 # ffffffffc02062c8 <commands+0x1248>
ffffffffc0202c04:	dd2fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0202c08:	00004697          	auipc	a3,0x4
ffffffffc0202c0c:	99068693          	addi	a3,a3,-1648 # ffffffffc0206598 <commands+0x1518>
ffffffffc0202c10:	00003617          	auipc	a2,0x3
ffffffffc0202c14:	cd060613          	addi	a2,a2,-816 # ffffffffc02058e0 <commands+0x860>
ffffffffc0202c18:	11700593          	li	a1,279
ffffffffc0202c1c:	00003517          	auipc	a0,0x3
ffffffffc0202c20:	6ac50513          	addi	a0,a0,1708 # ffffffffc02062c8 <commands+0x1248>
ffffffffc0202c24:	db2fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(total == 0);
ffffffffc0202c28:	00004697          	auipc	a3,0x4
ffffffffc0202c2c:	9a068693          	addi	a3,a3,-1632 # ffffffffc02065c8 <commands+0x1548>
ffffffffc0202c30:	00003617          	auipc	a2,0x3
ffffffffc0202c34:	cb060613          	addi	a2,a2,-848 # ffffffffc02058e0 <commands+0x860>
ffffffffc0202c38:	12600593          	li	a1,294
ffffffffc0202c3c:	00003517          	auipc	a0,0x3
ffffffffc0202c40:	68c50513          	addi	a0,a0,1676 # ffffffffc02062c8 <commands+0x1248>
ffffffffc0202c44:	d92fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(total == nr_free_pages());
ffffffffc0202c48:	00003697          	auipc	a3,0x3
ffffffffc0202c4c:	0f068693          	addi	a3,a3,240 # ffffffffc0205d38 <commands+0xcb8>
ffffffffc0202c50:	00003617          	auipc	a2,0x3
ffffffffc0202c54:	c9060613          	addi	a2,a2,-880 # ffffffffc02058e0 <commands+0x860>
ffffffffc0202c58:	0f300593          	li	a1,243
ffffffffc0202c5c:	00003517          	auipc	a0,0x3
ffffffffc0202c60:	66c50513          	addi	a0,a0,1644 # ffffffffc02062c8 <commands+0x1248>
ffffffffc0202c64:	d72fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202c68:	00003697          	auipc	a3,0x3
ffffffffc0202c6c:	69868693          	addi	a3,a3,1688 # ffffffffc0206300 <commands+0x1280>
ffffffffc0202c70:	00003617          	auipc	a2,0x3
ffffffffc0202c74:	c7060613          	addi	a2,a2,-912 # ffffffffc02058e0 <commands+0x860>
ffffffffc0202c78:	0ba00593          	li	a1,186
ffffffffc0202c7c:	00003517          	auipc	a0,0x3
ffffffffc0202c80:	64c50513          	addi	a0,a0,1612 # ffffffffc02062c8 <commands+0x1248>
ffffffffc0202c84:	d52fd0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc0202c88 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0202c88:	1141                	addi	sp,sp,-16
ffffffffc0202c8a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0202c8c:	16058e63          	beqz	a1,ffffffffc0202e08 <default_free_pages+0x180>
    for (; p != base + n; p ++) {
ffffffffc0202c90:	00659693          	slli	a3,a1,0x6
ffffffffc0202c94:	96aa                	add	a3,a3,a0
ffffffffc0202c96:	02d50d63          	beq	a0,a3,ffffffffc0202cd0 <default_free_pages+0x48>
ffffffffc0202c9a:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0202c9c:	8b85                	andi	a5,a5,1
ffffffffc0202c9e:	14079563          	bnez	a5,ffffffffc0202de8 <default_free_pages+0x160>
ffffffffc0202ca2:	651c                	ld	a5,8(a0)
ffffffffc0202ca4:	8385                	srli	a5,a5,0x1
ffffffffc0202ca6:	8b85                	andi	a5,a5,1
ffffffffc0202ca8:	14079063          	bnez	a5,ffffffffc0202de8 <default_free_pages+0x160>
ffffffffc0202cac:	87aa                	mv	a5,a0
ffffffffc0202cae:	a809                	j	ffffffffc0202cc0 <default_free_pages+0x38>
ffffffffc0202cb0:	6798                	ld	a4,8(a5)
ffffffffc0202cb2:	8b05                	andi	a4,a4,1
ffffffffc0202cb4:	12071a63          	bnez	a4,ffffffffc0202de8 <default_free_pages+0x160>
ffffffffc0202cb8:	6798                	ld	a4,8(a5)
ffffffffc0202cba:	8b09                	andi	a4,a4,2
ffffffffc0202cbc:	12071663          	bnez	a4,ffffffffc0202de8 <default_free_pages+0x160>
        p->flags = 0;
ffffffffc0202cc0:	0007b423          	sd	zero,8(a5)
    page->ref = val;
ffffffffc0202cc4:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0202cc8:	04078793          	addi	a5,a5,64
ffffffffc0202ccc:	fed792e3          	bne	a5,a3,ffffffffc0202cb0 <default_free_pages+0x28>
    base->property = n;
ffffffffc0202cd0:	2581                	sext.w	a1,a1
ffffffffc0202cd2:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0202cd4:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0202cd8:	4789                	li	a5,2
ffffffffc0202cda:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0202cde:	00014697          	auipc	a3,0x14
ffffffffc0202ce2:	8da68693          	addi	a3,a3,-1830 # ffffffffc02165b8 <free_area>
ffffffffc0202ce6:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0202ce8:	669c                	ld	a5,8(a3)
ffffffffc0202cea:	9db9                	addw	a1,a1,a4
ffffffffc0202cec:	00014717          	auipc	a4,0x14
ffffffffc0202cf0:	8cb72e23          	sw	a1,-1828(a4) # ffffffffc02165c8 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0202cf4:	0cd78163          	beq	a5,a3,ffffffffc0202db6 <default_free_pages+0x12e>
            struct Page* page = le2page(le, page_link);
ffffffffc0202cf8:	fe878713          	addi	a4,a5,-24
ffffffffc0202cfc:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0202cfe:	4801                	li	a6,0
ffffffffc0202d00:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0202d04:	00e56a63          	bltu	a0,a4,ffffffffc0202d18 <default_free_pages+0x90>
    return listelm->next;
ffffffffc0202d08:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0202d0a:	04d70f63          	beq	a4,a3,ffffffffc0202d68 <default_free_pages+0xe0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0202d0e:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0202d10:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0202d14:	fee57ae3          	bleu	a4,a0,ffffffffc0202d08 <default_free_pages+0x80>
ffffffffc0202d18:	00080663          	beqz	a6,ffffffffc0202d24 <default_free_pages+0x9c>
ffffffffc0202d1c:	00014817          	auipc	a6,0x14
ffffffffc0202d20:	88b83e23          	sd	a1,-1892(a6) # ffffffffc02165b8 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0202d24:	638c                	ld	a1,0(a5)
    prev->next = next->prev = elm;
ffffffffc0202d26:	e390                	sd	a2,0(a5)
ffffffffc0202d28:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc0202d2a:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0202d2c:	ed0c                	sd	a1,24(a0)
    if (le != &free_list) {
ffffffffc0202d2e:	06d58a63          	beq	a1,a3,ffffffffc0202da2 <default_free_pages+0x11a>
        if (p + p->property == base) {
ffffffffc0202d32:	ff85a603          	lw	a2,-8(a1) # ff8 <BASE_ADDRESS-0xffffffffc01ff008>
        p = le2page(le, page_link);
ffffffffc0202d36:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc0202d3a:	02061793          	slli	a5,a2,0x20
ffffffffc0202d3e:	83e9                	srli	a5,a5,0x1a
ffffffffc0202d40:	97ba                	add	a5,a5,a4
ffffffffc0202d42:	04f51b63          	bne	a0,a5,ffffffffc0202d98 <default_free_pages+0x110>
            p->property += base->property;
ffffffffc0202d46:	491c                	lw	a5,16(a0)
ffffffffc0202d48:	9e3d                	addw	a2,a2,a5
ffffffffc0202d4a:	fec5ac23          	sw	a2,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0202d4e:	57f5                	li	a5,-3
ffffffffc0202d50:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0202d54:	01853803          	ld	a6,24(a0)
ffffffffc0202d58:	7110                	ld	a2,32(a0)
            base = p;
ffffffffc0202d5a:	853a                	mv	a0,a4
    prev->next = next;
ffffffffc0202d5c:	00c83423          	sd	a2,8(a6)
    next->prev = prev;
ffffffffc0202d60:	659c                	ld	a5,8(a1)
ffffffffc0202d62:	01063023          	sd	a6,0(a2)
ffffffffc0202d66:	a815                	j	ffffffffc0202d9a <default_free_pages+0x112>
    prev->next = next->prev = elm;
ffffffffc0202d68:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0202d6a:	f114                	sd	a3,32(a0)
ffffffffc0202d6c:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0202d6e:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0202d70:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0202d72:	00d70563          	beq	a4,a3,ffffffffc0202d7c <default_free_pages+0xf4>
ffffffffc0202d76:	4805                	li	a6,1
ffffffffc0202d78:	87ba                	mv	a5,a4
ffffffffc0202d7a:	bf59                	j	ffffffffc0202d10 <default_free_pages+0x88>
ffffffffc0202d7c:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc0202d7e:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc0202d80:	00d78d63          	beq	a5,a3,ffffffffc0202d9a <default_free_pages+0x112>
        if (p + p->property == base) {
ffffffffc0202d84:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc0202d88:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc0202d8c:	02061793          	slli	a5,a2,0x20
ffffffffc0202d90:	83e9                	srli	a5,a5,0x1a
ffffffffc0202d92:	97ba                	add	a5,a5,a4
ffffffffc0202d94:	faf509e3          	beq	a0,a5,ffffffffc0202d46 <default_free_pages+0xbe>
ffffffffc0202d98:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc0202d9a:	fe878713          	addi	a4,a5,-24
ffffffffc0202d9e:	00d78963          	beq	a5,a3,ffffffffc0202db0 <default_free_pages+0x128>
        if (base + base->property == p) {
ffffffffc0202da2:	4910                	lw	a2,16(a0)
ffffffffc0202da4:	02061693          	slli	a3,a2,0x20
ffffffffc0202da8:	82e9                	srli	a3,a3,0x1a
ffffffffc0202daa:	96aa                	add	a3,a3,a0
ffffffffc0202dac:	00d70e63          	beq	a4,a3,ffffffffc0202dc8 <default_free_pages+0x140>
}
ffffffffc0202db0:	60a2                	ld	ra,8(sp)
ffffffffc0202db2:	0141                	addi	sp,sp,16
ffffffffc0202db4:	8082                	ret
ffffffffc0202db6:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0202db8:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0202dbc:	e398                	sd	a4,0(a5)
ffffffffc0202dbe:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0202dc0:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0202dc2:	ed1c                	sd	a5,24(a0)
}
ffffffffc0202dc4:	0141                	addi	sp,sp,16
ffffffffc0202dc6:	8082                	ret
            base->property += p->property;
ffffffffc0202dc8:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202dcc:	ff078693          	addi	a3,a5,-16
ffffffffc0202dd0:	9e39                	addw	a2,a2,a4
ffffffffc0202dd2:	c910                	sw	a2,16(a0)
ffffffffc0202dd4:	5775                	li	a4,-3
ffffffffc0202dd6:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0202dda:	6398                	ld	a4,0(a5)
ffffffffc0202ddc:	679c                	ld	a5,8(a5)
}
ffffffffc0202dde:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0202de0:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0202de2:	e398                	sd	a4,0(a5)
ffffffffc0202de4:	0141                	addi	sp,sp,16
ffffffffc0202de6:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0202de8:	00003697          	auipc	a3,0x3
ffffffffc0202dec:	7f068693          	addi	a3,a3,2032 # ffffffffc02065d8 <commands+0x1558>
ffffffffc0202df0:	00003617          	auipc	a2,0x3
ffffffffc0202df4:	af060613          	addi	a2,a2,-1296 # ffffffffc02058e0 <commands+0x860>
ffffffffc0202df8:	08300593          	li	a1,131
ffffffffc0202dfc:	00003517          	auipc	a0,0x3
ffffffffc0202e00:	4cc50513          	addi	a0,a0,1228 # ffffffffc02062c8 <commands+0x1248>
ffffffffc0202e04:	bd2fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(n > 0);
ffffffffc0202e08:	00003697          	auipc	a3,0x3
ffffffffc0202e0c:	7f868693          	addi	a3,a3,2040 # ffffffffc0206600 <commands+0x1580>
ffffffffc0202e10:	00003617          	auipc	a2,0x3
ffffffffc0202e14:	ad060613          	addi	a2,a2,-1328 # ffffffffc02058e0 <commands+0x860>
ffffffffc0202e18:	08000593          	li	a1,128
ffffffffc0202e1c:	00003517          	auipc	a0,0x3
ffffffffc0202e20:	4ac50513          	addi	a0,a0,1196 # ffffffffc02062c8 <commands+0x1248>
ffffffffc0202e24:	bb2fd0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc0202e28 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0202e28:	c959                	beqz	a0,ffffffffc0202ebe <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc0202e2a:	00013597          	auipc	a1,0x13
ffffffffc0202e2e:	78e58593          	addi	a1,a1,1934 # ffffffffc02165b8 <free_area>
ffffffffc0202e32:	0105a803          	lw	a6,16(a1)
ffffffffc0202e36:	862a                	mv	a2,a0
ffffffffc0202e38:	02081793          	slli	a5,a6,0x20
ffffffffc0202e3c:	9381                	srli	a5,a5,0x20
ffffffffc0202e3e:	00a7ee63          	bltu	a5,a0,ffffffffc0202e5a <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0202e42:	87ae                	mv	a5,a1
ffffffffc0202e44:	a801                	j	ffffffffc0202e54 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0202e46:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202e4a:	02071693          	slli	a3,a4,0x20
ffffffffc0202e4e:	9281                	srli	a3,a3,0x20
ffffffffc0202e50:	00c6f763          	bleu	a2,a3,ffffffffc0202e5e <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0202e54:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202e56:	feb798e3          	bne	a5,a1,ffffffffc0202e46 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc0202e5a:	4501                	li	a0,0
}
ffffffffc0202e5c:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc0202e5e:	fe878513          	addi	a0,a5,-24
    if (page != NULL) {
ffffffffc0202e62:	dd6d                	beqz	a0,ffffffffc0202e5c <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc0202e64:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0202e68:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc0202e6c:	00060e1b          	sext.w	t3,a2
ffffffffc0202e70:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0202e74:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0202e78:	02d67863          	bleu	a3,a2,ffffffffc0202ea8 <default_alloc_pages+0x80>
            struct Page *p = page + n;
ffffffffc0202e7c:	061a                	slli	a2,a2,0x6
ffffffffc0202e7e:	962a                	add	a2,a2,a0
            p->property = page->property - n;
ffffffffc0202e80:	41c7073b          	subw	a4,a4,t3
ffffffffc0202e84:	ca18                	sw	a4,16(a2)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0202e86:	00860693          	addi	a3,a2,8
ffffffffc0202e8a:	4709                	li	a4,2
ffffffffc0202e8c:	40e6b02f          	amoor.d	zero,a4,(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc0202e90:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0202e94:	01860693          	addi	a3,a2,24
    prev->next = next->prev = elm;
ffffffffc0202e98:	0105a803          	lw	a6,16(a1)
ffffffffc0202e9c:	e314                	sd	a3,0(a4)
ffffffffc0202e9e:	00d8b423          	sd	a3,8(a7)
    elm->next = next;
ffffffffc0202ea2:	f218                	sd	a4,32(a2)
    elm->prev = prev;
ffffffffc0202ea4:	01163c23          	sd	a7,24(a2)
        nr_free -= n;
ffffffffc0202ea8:	41c8083b          	subw	a6,a6,t3
ffffffffc0202eac:	00013717          	auipc	a4,0x13
ffffffffc0202eb0:	71072e23          	sw	a6,1820(a4) # ffffffffc02165c8 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0202eb4:	5775                	li	a4,-3
ffffffffc0202eb6:	17c1                	addi	a5,a5,-16
ffffffffc0202eb8:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc0202ebc:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0202ebe:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0202ec0:	00003697          	auipc	a3,0x3
ffffffffc0202ec4:	74068693          	addi	a3,a3,1856 # ffffffffc0206600 <commands+0x1580>
ffffffffc0202ec8:	00003617          	auipc	a2,0x3
ffffffffc0202ecc:	a1860613          	addi	a2,a2,-1512 # ffffffffc02058e0 <commands+0x860>
ffffffffc0202ed0:	06200593          	li	a1,98
ffffffffc0202ed4:	00003517          	auipc	a0,0x3
ffffffffc0202ed8:	3f450513          	addi	a0,a0,1012 # ffffffffc02062c8 <commands+0x1248>
default_alloc_pages(size_t n) {
ffffffffc0202edc:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0202ede:	af8fd0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc0202ee2 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0202ee2:	1141                	addi	sp,sp,-16
ffffffffc0202ee4:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0202ee6:	c1ed                	beqz	a1,ffffffffc0202fc8 <default_init_memmap+0xe6>
    for (; p != base + n; p ++) {
ffffffffc0202ee8:	00659693          	slli	a3,a1,0x6
ffffffffc0202eec:	96aa                	add	a3,a3,a0
ffffffffc0202eee:	02d50463          	beq	a0,a3,ffffffffc0202f16 <default_init_memmap+0x34>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0202ef2:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc0202ef4:	87aa                	mv	a5,a0
ffffffffc0202ef6:	8b05                	andi	a4,a4,1
ffffffffc0202ef8:	e709                	bnez	a4,ffffffffc0202f02 <default_init_memmap+0x20>
ffffffffc0202efa:	a07d                	j	ffffffffc0202fa8 <default_init_memmap+0xc6>
ffffffffc0202efc:	6798                	ld	a4,8(a5)
ffffffffc0202efe:	8b05                	andi	a4,a4,1
ffffffffc0202f00:	c745                	beqz	a4,ffffffffc0202fa8 <default_init_memmap+0xc6>
        p->flags = p->property = 0;
ffffffffc0202f02:	0007a823          	sw	zero,16(a5)
ffffffffc0202f06:	0007b423          	sd	zero,8(a5)
ffffffffc0202f0a:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0202f0e:	04078793          	addi	a5,a5,64
ffffffffc0202f12:	fed795e3          	bne	a5,a3,ffffffffc0202efc <default_init_memmap+0x1a>
    base->property = n;
ffffffffc0202f16:	2581                	sext.w	a1,a1
ffffffffc0202f18:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0202f1a:	4789                	li	a5,2
ffffffffc0202f1c:	00850713          	addi	a4,a0,8
ffffffffc0202f20:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0202f24:	00013697          	auipc	a3,0x13
ffffffffc0202f28:	69468693          	addi	a3,a3,1684 # ffffffffc02165b8 <free_area>
ffffffffc0202f2c:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0202f2e:	669c                	ld	a5,8(a3)
ffffffffc0202f30:	9db9                	addw	a1,a1,a4
ffffffffc0202f32:	00013717          	auipc	a4,0x13
ffffffffc0202f36:	68b72b23          	sw	a1,1686(a4) # ffffffffc02165c8 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0202f3a:	04d78a63          	beq	a5,a3,ffffffffc0202f8e <default_init_memmap+0xac>
            struct Page* page = le2page(le, page_link);
ffffffffc0202f3e:	fe878713          	addi	a4,a5,-24
ffffffffc0202f42:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0202f44:	4801                	li	a6,0
ffffffffc0202f46:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0202f4a:	00e56a63          	bltu	a0,a4,ffffffffc0202f5e <default_init_memmap+0x7c>
    return listelm->next;
ffffffffc0202f4e:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0202f50:	02d70563          	beq	a4,a3,ffffffffc0202f7a <default_init_memmap+0x98>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0202f54:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0202f56:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0202f5a:	fee57ae3          	bleu	a4,a0,ffffffffc0202f4e <default_init_memmap+0x6c>
ffffffffc0202f5e:	00080663          	beqz	a6,ffffffffc0202f6a <default_init_memmap+0x88>
ffffffffc0202f62:	00013717          	auipc	a4,0x13
ffffffffc0202f66:	64b73b23          	sd	a1,1622(a4) # ffffffffc02165b8 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0202f6a:	6398                	ld	a4,0(a5)
}
ffffffffc0202f6c:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0202f6e:	e390                	sd	a2,0(a5)
ffffffffc0202f70:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0202f72:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0202f74:	ed18                	sd	a4,24(a0)
ffffffffc0202f76:	0141                	addi	sp,sp,16
ffffffffc0202f78:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0202f7a:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0202f7c:	f114                	sd	a3,32(a0)
ffffffffc0202f7e:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0202f80:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0202f82:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0202f84:	00d70e63          	beq	a4,a3,ffffffffc0202fa0 <default_init_memmap+0xbe>
ffffffffc0202f88:	4805                	li	a6,1
ffffffffc0202f8a:	87ba                	mv	a5,a4
ffffffffc0202f8c:	b7e9                	j	ffffffffc0202f56 <default_init_memmap+0x74>
}
ffffffffc0202f8e:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0202f90:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0202f94:	e398                	sd	a4,0(a5)
ffffffffc0202f96:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0202f98:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0202f9a:	ed1c                	sd	a5,24(a0)
}
ffffffffc0202f9c:	0141                	addi	sp,sp,16
ffffffffc0202f9e:	8082                	ret
ffffffffc0202fa0:	60a2                	ld	ra,8(sp)
ffffffffc0202fa2:	e290                	sd	a2,0(a3)
ffffffffc0202fa4:	0141                	addi	sp,sp,16
ffffffffc0202fa6:	8082                	ret
        assert(PageReserved(p));
ffffffffc0202fa8:	00003697          	auipc	a3,0x3
ffffffffc0202fac:	66068693          	addi	a3,a3,1632 # ffffffffc0206608 <commands+0x1588>
ffffffffc0202fb0:	00003617          	auipc	a2,0x3
ffffffffc0202fb4:	93060613          	addi	a2,a2,-1744 # ffffffffc02058e0 <commands+0x860>
ffffffffc0202fb8:	04900593          	li	a1,73
ffffffffc0202fbc:	00003517          	auipc	a0,0x3
ffffffffc0202fc0:	30c50513          	addi	a0,a0,780 # ffffffffc02062c8 <commands+0x1248>
ffffffffc0202fc4:	a12fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(n > 0);
ffffffffc0202fc8:	00003697          	auipc	a3,0x3
ffffffffc0202fcc:	63868693          	addi	a3,a3,1592 # ffffffffc0206600 <commands+0x1580>
ffffffffc0202fd0:	00003617          	auipc	a2,0x3
ffffffffc0202fd4:	91060613          	addi	a2,a2,-1776 # ffffffffc02058e0 <commands+0x860>
ffffffffc0202fd8:	04600593          	li	a1,70
ffffffffc0202fdc:	00003517          	auipc	a0,0x3
ffffffffc0202fe0:	2ec50513          	addi	a0,a0,748 # ffffffffc02062c8 <commands+0x1248>
ffffffffc0202fe4:	9f2fd0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc0202fe8 <pa2page.part.4>:
pa2page(uintptr_t pa) {
ffffffffc0202fe8:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0202fea:	00003617          	auipc	a2,0x3
ffffffffc0202fee:	c2e60613          	addi	a2,a2,-978 # ffffffffc0205c18 <commands+0xb98>
ffffffffc0202ff2:	06200593          	li	a1,98
ffffffffc0202ff6:	00003517          	auipc	a0,0x3
ffffffffc0202ffa:	c4250513          	addi	a0,a0,-958 # ffffffffc0205c38 <commands+0xbb8>
pa2page(uintptr_t pa) {
ffffffffc0202ffe:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0203000:	9d6fd0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc0203004 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0203004:	715d                	addi	sp,sp,-80
ffffffffc0203006:	e0a2                	sd	s0,64(sp)
ffffffffc0203008:	fc26                	sd	s1,56(sp)
ffffffffc020300a:	f84a                	sd	s2,48(sp)
ffffffffc020300c:	f44e                	sd	s3,40(sp)
ffffffffc020300e:	f052                	sd	s4,32(sp)
ffffffffc0203010:	ec56                	sd	s5,24(sp)
ffffffffc0203012:	e486                	sd	ra,72(sp)
ffffffffc0203014:	842a                	mv	s0,a0
ffffffffc0203016:	00013497          	auipc	s1,0x13
ffffffffc020301a:	5ba48493          	addi	s1,s1,1466 # ffffffffc02165d0 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc020301e:	4985                	li	s3,1
ffffffffc0203020:	00013a17          	auipc	s4,0x13
ffffffffc0203024:	470a0a13          	addi	s4,s4,1136 # ffffffffc0216490 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0203028:	0005091b          	sext.w	s2,a0
ffffffffc020302c:	00013a97          	auipc	s5,0x13
ffffffffc0203030:	4aca8a93          	addi	s5,s5,1196 # ffffffffc02164d8 <check_mm_struct>
ffffffffc0203034:	a00d                	j	ffffffffc0203056 <alloc_pages+0x52>
            page = pmm_manager->alloc_pages(n);
ffffffffc0203036:	609c                	ld	a5,0(s1)
ffffffffc0203038:	6f9c                	ld	a5,24(a5)
ffffffffc020303a:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc020303c:	4601                	li	a2,0
ffffffffc020303e:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0203040:	ed0d                	bnez	a0,ffffffffc020307a <alloc_pages+0x76>
ffffffffc0203042:	0289ec63          	bltu	s3,s0,ffffffffc020307a <alloc_pages+0x76>
ffffffffc0203046:	000a2783          	lw	a5,0(s4)
ffffffffc020304a:	2781                	sext.w	a5,a5
ffffffffc020304c:	c79d                	beqz	a5,ffffffffc020307a <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc020304e:	000ab503          	ld	a0,0(s5)
ffffffffc0203052:	abffe0ef          	jal	ra,ffffffffc0201b10 <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203056:	100027f3          	csrr	a5,sstatus
ffffffffc020305a:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc020305c:	8522                	mv	a0,s0
ffffffffc020305e:	dfe1                	beqz	a5,ffffffffc0203036 <alloc_pages+0x32>
        intr_disable();
ffffffffc0203060:	d56fd0ef          	jal	ra,ffffffffc02005b6 <intr_disable>
ffffffffc0203064:	609c                	ld	a5,0(s1)
ffffffffc0203066:	8522                	mv	a0,s0
ffffffffc0203068:	6f9c                	ld	a5,24(a5)
ffffffffc020306a:	9782                	jalr	a5
ffffffffc020306c:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc020306e:	d42fd0ef          	jal	ra,ffffffffc02005b0 <intr_enable>
ffffffffc0203072:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc0203074:	4601                	li	a2,0
ffffffffc0203076:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0203078:	d569                	beqz	a0,ffffffffc0203042 <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc020307a:	60a6                	ld	ra,72(sp)
ffffffffc020307c:	6406                	ld	s0,64(sp)
ffffffffc020307e:	74e2                	ld	s1,56(sp)
ffffffffc0203080:	7942                	ld	s2,48(sp)
ffffffffc0203082:	79a2                	ld	s3,40(sp)
ffffffffc0203084:	7a02                	ld	s4,32(sp)
ffffffffc0203086:	6ae2                	ld	s5,24(sp)
ffffffffc0203088:	6161                	addi	sp,sp,80
ffffffffc020308a:	8082                	ret

ffffffffc020308c <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020308c:	100027f3          	csrr	a5,sstatus
ffffffffc0203090:	8b89                	andi	a5,a5,2
ffffffffc0203092:	eb89                	bnez	a5,ffffffffc02030a4 <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0203094:	00013797          	auipc	a5,0x13
ffffffffc0203098:	53c78793          	addi	a5,a5,1340 # ffffffffc02165d0 <pmm_manager>
ffffffffc020309c:	639c                	ld	a5,0(a5)
ffffffffc020309e:	0207b303          	ld	t1,32(a5)
ffffffffc02030a2:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc02030a4:	1101                	addi	sp,sp,-32
ffffffffc02030a6:	ec06                	sd	ra,24(sp)
ffffffffc02030a8:	e822                	sd	s0,16(sp)
ffffffffc02030aa:	e426                	sd	s1,8(sp)
ffffffffc02030ac:	842a                	mv	s0,a0
ffffffffc02030ae:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc02030b0:	d06fd0ef          	jal	ra,ffffffffc02005b6 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02030b4:	00013797          	auipc	a5,0x13
ffffffffc02030b8:	51c78793          	addi	a5,a5,1308 # ffffffffc02165d0 <pmm_manager>
ffffffffc02030bc:	639c                	ld	a5,0(a5)
ffffffffc02030be:	85a6                	mv	a1,s1
ffffffffc02030c0:	8522                	mv	a0,s0
ffffffffc02030c2:	739c                	ld	a5,32(a5)
ffffffffc02030c4:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc02030c6:	6442                	ld	s0,16(sp)
ffffffffc02030c8:	60e2                	ld	ra,24(sp)
ffffffffc02030ca:	64a2                	ld	s1,8(sp)
ffffffffc02030cc:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02030ce:	ce2fd06f          	j	ffffffffc02005b0 <intr_enable>

ffffffffc02030d2 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02030d2:	100027f3          	csrr	a5,sstatus
ffffffffc02030d6:	8b89                	andi	a5,a5,2
ffffffffc02030d8:	eb89                	bnez	a5,ffffffffc02030ea <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc02030da:	00013797          	auipc	a5,0x13
ffffffffc02030de:	4f678793          	addi	a5,a5,1270 # ffffffffc02165d0 <pmm_manager>
ffffffffc02030e2:	639c                	ld	a5,0(a5)
ffffffffc02030e4:	0287b303          	ld	t1,40(a5)
ffffffffc02030e8:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc02030ea:	1141                	addi	sp,sp,-16
ffffffffc02030ec:	e406                	sd	ra,8(sp)
ffffffffc02030ee:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc02030f0:	cc6fd0ef          	jal	ra,ffffffffc02005b6 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc02030f4:	00013797          	auipc	a5,0x13
ffffffffc02030f8:	4dc78793          	addi	a5,a5,1244 # ffffffffc02165d0 <pmm_manager>
ffffffffc02030fc:	639c                	ld	a5,0(a5)
ffffffffc02030fe:	779c                	ld	a5,40(a5)
ffffffffc0203100:	9782                	jalr	a5
ffffffffc0203102:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0203104:	cacfd0ef          	jal	ra,ffffffffc02005b0 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0203108:	8522                	mv	a0,s0
ffffffffc020310a:	60a2                	ld	ra,8(sp)
ffffffffc020310c:	6402                	ld	s0,0(sp)
ffffffffc020310e:	0141                	addi	sp,sp,16
ffffffffc0203110:	8082                	ret

ffffffffc0203112 <get_pte>:
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0203112:	7139                	addi	sp,sp,-64
ffffffffc0203114:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0203116:	01e5d493          	srli	s1,a1,0x1e
ffffffffc020311a:	1ff4f493          	andi	s1,s1,511
ffffffffc020311e:	048e                	slli	s1,s1,0x3
ffffffffc0203120:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V)) {
ffffffffc0203122:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0203124:	f04a                	sd	s2,32(sp)
ffffffffc0203126:	ec4e                	sd	s3,24(sp)
ffffffffc0203128:	e852                	sd	s4,16(sp)
ffffffffc020312a:	fc06                	sd	ra,56(sp)
ffffffffc020312c:	f822                	sd	s0,48(sp)
ffffffffc020312e:	e456                	sd	s5,8(sp)
ffffffffc0203130:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0203132:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0203136:	892e                	mv	s2,a1
ffffffffc0203138:	8a32                	mv	s4,a2
ffffffffc020313a:	00013997          	auipc	s3,0x13
ffffffffc020313e:	36e98993          	addi	s3,s3,878 # ffffffffc02164a8 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0203142:	e7bd                	bnez	a5,ffffffffc02031b0 <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0203144:	12060c63          	beqz	a2,ffffffffc020327c <get_pte+0x16a>
ffffffffc0203148:	4505                	li	a0,1
ffffffffc020314a:	ebbff0ef          	jal	ra,ffffffffc0203004 <alloc_pages>
ffffffffc020314e:	842a                	mv	s0,a0
ffffffffc0203150:	12050663          	beqz	a0,ffffffffc020327c <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0203154:	00013b17          	auipc	s6,0x13
ffffffffc0203158:	494b0b13          	addi	s6,s6,1172 # ffffffffc02165e8 <pages>
ffffffffc020315c:	000b3503          	ld	a0,0(s6)
    page->ref = val;
ffffffffc0203160:	4785                	li	a5,1
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0203162:	00013997          	auipc	s3,0x13
ffffffffc0203166:	34698993          	addi	s3,s3,838 # ffffffffc02164a8 <npage>
    return page - pages + nbase;
ffffffffc020316a:	40a40533          	sub	a0,s0,a0
ffffffffc020316e:	00080ab7          	lui	s5,0x80
ffffffffc0203172:	8519                	srai	a0,a0,0x6
ffffffffc0203174:	0009b703          	ld	a4,0(s3)
    page->ref = val;
ffffffffc0203178:	c01c                	sw	a5,0(s0)
ffffffffc020317a:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc020317c:	9556                	add	a0,a0,s5
ffffffffc020317e:	83b1                	srli	a5,a5,0xc
ffffffffc0203180:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0203182:	0532                	slli	a0,a0,0xc
ffffffffc0203184:	14e7f363          	bleu	a4,a5,ffffffffc02032ca <get_pte+0x1b8>
ffffffffc0203188:	00013797          	auipc	a5,0x13
ffffffffc020318c:	45078793          	addi	a5,a5,1104 # ffffffffc02165d8 <va_pa_offset>
ffffffffc0203190:	639c                	ld	a5,0(a5)
ffffffffc0203192:	6605                	lui	a2,0x1
ffffffffc0203194:	4581                	li	a1,0
ffffffffc0203196:	953e                	add	a0,a0,a5
ffffffffc0203198:	129010ef          	jal	ra,ffffffffc0204ac0 <memset>
    return page - pages + nbase;
ffffffffc020319c:	000b3683          	ld	a3,0(s6)
ffffffffc02031a0:	40d406b3          	sub	a3,s0,a3
ffffffffc02031a4:	8699                	srai	a3,a3,0x6
ffffffffc02031a6:	96d6                	add	a3,a3,s5
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02031a8:	06aa                	slli	a3,a3,0xa
ffffffffc02031aa:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc02031ae:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02031b0:	77fd                	lui	a5,0xfffff
ffffffffc02031b2:	068a                	slli	a3,a3,0x2
ffffffffc02031b4:	0009b703          	ld	a4,0(s3)
ffffffffc02031b8:	8efd                	and	a3,a3,a5
ffffffffc02031ba:	00c6d793          	srli	a5,a3,0xc
ffffffffc02031be:	0ce7f163          	bleu	a4,a5,ffffffffc0203280 <get_pte+0x16e>
ffffffffc02031c2:	00013a97          	auipc	s5,0x13
ffffffffc02031c6:	416a8a93          	addi	s5,s5,1046 # ffffffffc02165d8 <va_pa_offset>
ffffffffc02031ca:	000ab403          	ld	s0,0(s5)
ffffffffc02031ce:	01595793          	srli	a5,s2,0x15
ffffffffc02031d2:	1ff7f793          	andi	a5,a5,511
ffffffffc02031d6:	96a2                	add	a3,a3,s0
ffffffffc02031d8:	00379413          	slli	s0,a5,0x3
ffffffffc02031dc:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc02031de:	6014                	ld	a3,0(s0)
ffffffffc02031e0:	0016f793          	andi	a5,a3,1
ffffffffc02031e4:	e3ad                	bnez	a5,ffffffffc0203246 <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc02031e6:	080a0b63          	beqz	s4,ffffffffc020327c <get_pte+0x16a>
ffffffffc02031ea:	4505                	li	a0,1
ffffffffc02031ec:	e19ff0ef          	jal	ra,ffffffffc0203004 <alloc_pages>
ffffffffc02031f0:	84aa                	mv	s1,a0
ffffffffc02031f2:	c549                	beqz	a0,ffffffffc020327c <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc02031f4:	00013b17          	auipc	s6,0x13
ffffffffc02031f8:	3f4b0b13          	addi	s6,s6,1012 # ffffffffc02165e8 <pages>
ffffffffc02031fc:	000b3503          	ld	a0,0(s6)
    page->ref = val;
ffffffffc0203200:	4785                	li	a5,1
    return page - pages + nbase;
ffffffffc0203202:	00080a37          	lui	s4,0x80
ffffffffc0203206:	40a48533          	sub	a0,s1,a0
ffffffffc020320a:	8519                	srai	a0,a0,0x6
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc020320c:	0009b703          	ld	a4,0(s3)
    page->ref = val;
ffffffffc0203210:	c09c                	sw	a5,0(s1)
ffffffffc0203212:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc0203214:	9552                	add	a0,a0,s4
ffffffffc0203216:	83b1                	srli	a5,a5,0xc
ffffffffc0203218:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc020321a:	0532                	slli	a0,a0,0xc
ffffffffc020321c:	08e7fa63          	bleu	a4,a5,ffffffffc02032b0 <get_pte+0x19e>
ffffffffc0203220:	000ab783          	ld	a5,0(s5)
ffffffffc0203224:	6605                	lui	a2,0x1
ffffffffc0203226:	4581                	li	a1,0
ffffffffc0203228:	953e                	add	a0,a0,a5
ffffffffc020322a:	097010ef          	jal	ra,ffffffffc0204ac0 <memset>
    return page - pages + nbase;
ffffffffc020322e:	000b3683          	ld	a3,0(s6)
ffffffffc0203232:	40d486b3          	sub	a3,s1,a3
ffffffffc0203236:	8699                	srai	a3,a3,0x6
ffffffffc0203238:	96d2                	add	a3,a3,s4
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc020323a:	06aa                	slli	a3,a3,0xa
ffffffffc020323c:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0203240:	e014                	sd	a3,0(s0)
ffffffffc0203242:	0009b703          	ld	a4,0(s3)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0203246:	068a                	slli	a3,a3,0x2
ffffffffc0203248:	757d                	lui	a0,0xfffff
ffffffffc020324a:	8ee9                	and	a3,a3,a0
ffffffffc020324c:	00c6d793          	srli	a5,a3,0xc
ffffffffc0203250:	04e7f463          	bleu	a4,a5,ffffffffc0203298 <get_pte+0x186>
ffffffffc0203254:	000ab503          	ld	a0,0(s5)
ffffffffc0203258:	00c95793          	srli	a5,s2,0xc
ffffffffc020325c:	1ff7f793          	andi	a5,a5,511
ffffffffc0203260:	96aa                	add	a3,a3,a0
ffffffffc0203262:	00379513          	slli	a0,a5,0x3
ffffffffc0203266:	9536                	add	a0,a0,a3
}
ffffffffc0203268:	70e2                	ld	ra,56(sp)
ffffffffc020326a:	7442                	ld	s0,48(sp)
ffffffffc020326c:	74a2                	ld	s1,40(sp)
ffffffffc020326e:	7902                	ld	s2,32(sp)
ffffffffc0203270:	69e2                	ld	s3,24(sp)
ffffffffc0203272:	6a42                	ld	s4,16(sp)
ffffffffc0203274:	6aa2                	ld	s5,8(sp)
ffffffffc0203276:	6b02                	ld	s6,0(sp)
ffffffffc0203278:	6121                	addi	sp,sp,64
ffffffffc020327a:	8082                	ret
            return NULL;
ffffffffc020327c:	4501                	li	a0,0
ffffffffc020327e:	b7ed                	j	ffffffffc0203268 <get_pte+0x156>
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0203280:	00003617          	auipc	a2,0x3
ffffffffc0203284:	9c860613          	addi	a2,a2,-1592 # ffffffffc0205c48 <commands+0xbc8>
ffffffffc0203288:	0e400593          	li	a1,228
ffffffffc020328c:	00003517          	auipc	a0,0x3
ffffffffc0203290:	3dc50513          	addi	a0,a0,988 # ffffffffc0206668 <default_pmm_manager+0x50>
ffffffffc0203294:	f43fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0203298:	00003617          	auipc	a2,0x3
ffffffffc020329c:	9b060613          	addi	a2,a2,-1616 # ffffffffc0205c48 <commands+0xbc8>
ffffffffc02032a0:	0ef00593          	li	a1,239
ffffffffc02032a4:	00003517          	auipc	a0,0x3
ffffffffc02032a8:	3c450513          	addi	a0,a0,964 # ffffffffc0206668 <default_pmm_manager+0x50>
ffffffffc02032ac:	f2bfc0ef          	jal	ra,ffffffffc02001d6 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02032b0:	86aa                	mv	a3,a0
ffffffffc02032b2:	00003617          	auipc	a2,0x3
ffffffffc02032b6:	99660613          	addi	a2,a2,-1642 # ffffffffc0205c48 <commands+0xbc8>
ffffffffc02032ba:	0ec00593          	li	a1,236
ffffffffc02032be:	00003517          	auipc	a0,0x3
ffffffffc02032c2:	3aa50513          	addi	a0,a0,938 # ffffffffc0206668 <default_pmm_manager+0x50>
ffffffffc02032c6:	f11fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02032ca:	86aa                	mv	a3,a0
ffffffffc02032cc:	00003617          	auipc	a2,0x3
ffffffffc02032d0:	97c60613          	addi	a2,a2,-1668 # ffffffffc0205c48 <commands+0xbc8>
ffffffffc02032d4:	0e100593          	li	a1,225
ffffffffc02032d8:	00003517          	auipc	a0,0x3
ffffffffc02032dc:	39050513          	addi	a0,a0,912 # ffffffffc0206668 <default_pmm_manager+0x50>
ffffffffc02032e0:	ef7fc0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc02032e4 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc02032e4:	1141                	addi	sp,sp,-16
ffffffffc02032e6:	e022                	sd	s0,0(sp)
ffffffffc02032e8:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02032ea:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc02032ec:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02032ee:	e25ff0ef          	jal	ra,ffffffffc0203112 <get_pte>
    if (ptep_store != NULL) {
ffffffffc02032f2:	c011                	beqz	s0,ffffffffc02032f6 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc02032f4:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc02032f6:	c129                	beqz	a0,ffffffffc0203338 <get_page+0x54>
ffffffffc02032f8:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc02032fa:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc02032fc:	0017f713          	andi	a4,a5,1
ffffffffc0203300:	e709                	bnez	a4,ffffffffc020330a <get_page+0x26>
}
ffffffffc0203302:	60a2                	ld	ra,8(sp)
ffffffffc0203304:	6402                	ld	s0,0(sp)
ffffffffc0203306:	0141                	addi	sp,sp,16
ffffffffc0203308:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc020330a:	00013717          	auipc	a4,0x13
ffffffffc020330e:	19e70713          	addi	a4,a4,414 # ffffffffc02164a8 <npage>
ffffffffc0203312:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203314:	078a                	slli	a5,a5,0x2
ffffffffc0203316:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203318:	02e7f563          	bleu	a4,a5,ffffffffc0203342 <get_page+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc020331c:	00013717          	auipc	a4,0x13
ffffffffc0203320:	2cc70713          	addi	a4,a4,716 # ffffffffc02165e8 <pages>
ffffffffc0203324:	6308                	ld	a0,0(a4)
ffffffffc0203326:	60a2                	ld	ra,8(sp)
ffffffffc0203328:	6402                	ld	s0,0(sp)
ffffffffc020332a:	fff80737          	lui	a4,0xfff80
ffffffffc020332e:	97ba                	add	a5,a5,a4
ffffffffc0203330:	079a                	slli	a5,a5,0x6
ffffffffc0203332:	953e                	add	a0,a0,a5
ffffffffc0203334:	0141                	addi	sp,sp,16
ffffffffc0203336:	8082                	ret
ffffffffc0203338:	60a2                	ld	ra,8(sp)
ffffffffc020333a:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc020333c:	4501                	li	a0,0
}
ffffffffc020333e:	0141                	addi	sp,sp,16
ffffffffc0203340:	8082                	ret
ffffffffc0203342:	ca7ff0ef          	jal	ra,ffffffffc0202fe8 <pa2page.part.4>

ffffffffc0203346 <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0203346:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0203348:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc020334a:	e426                	sd	s1,8(sp)
ffffffffc020334c:	ec06                	sd	ra,24(sp)
ffffffffc020334e:	e822                	sd	s0,16(sp)
ffffffffc0203350:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0203352:	dc1ff0ef          	jal	ra,ffffffffc0203112 <get_pte>
    if (ptep != NULL) {
ffffffffc0203356:	c511                	beqz	a0,ffffffffc0203362 <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0203358:	611c                	ld	a5,0(a0)
ffffffffc020335a:	842a                	mv	s0,a0
ffffffffc020335c:	0017f713          	andi	a4,a5,1
ffffffffc0203360:	e711                	bnez	a4,ffffffffc020336c <page_remove+0x26>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0203362:	60e2                	ld	ra,24(sp)
ffffffffc0203364:	6442                	ld	s0,16(sp)
ffffffffc0203366:	64a2                	ld	s1,8(sp)
ffffffffc0203368:	6105                	addi	sp,sp,32
ffffffffc020336a:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc020336c:	00013717          	auipc	a4,0x13
ffffffffc0203370:	13c70713          	addi	a4,a4,316 # ffffffffc02164a8 <npage>
ffffffffc0203374:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203376:	078a                	slli	a5,a5,0x2
ffffffffc0203378:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020337a:	02e7fe63          	bleu	a4,a5,ffffffffc02033b6 <page_remove+0x70>
    return &pages[PPN(pa) - nbase];
ffffffffc020337e:	00013717          	auipc	a4,0x13
ffffffffc0203382:	26a70713          	addi	a4,a4,618 # ffffffffc02165e8 <pages>
ffffffffc0203386:	6308                	ld	a0,0(a4)
ffffffffc0203388:	fff80737          	lui	a4,0xfff80
ffffffffc020338c:	97ba                	add	a5,a5,a4
ffffffffc020338e:	079a                	slli	a5,a5,0x6
ffffffffc0203390:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0203392:	411c                	lw	a5,0(a0)
ffffffffc0203394:	fff7871b          	addiw	a4,a5,-1
ffffffffc0203398:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc020339a:	cb11                	beqz	a4,ffffffffc02033ae <page_remove+0x68>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc020339c:	00043023          	sd	zero,0(s0)
// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    // flush_tlb();
    // The flush_tlb flush the entire TLB, is there any better way?
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02033a0:	12048073          	sfence.vma	s1
}
ffffffffc02033a4:	60e2                	ld	ra,24(sp)
ffffffffc02033a6:	6442                	ld	s0,16(sp)
ffffffffc02033a8:	64a2                	ld	s1,8(sp)
ffffffffc02033aa:	6105                	addi	sp,sp,32
ffffffffc02033ac:	8082                	ret
            free_page(page);
ffffffffc02033ae:	4585                	li	a1,1
ffffffffc02033b0:	cddff0ef          	jal	ra,ffffffffc020308c <free_pages>
ffffffffc02033b4:	b7e5                	j	ffffffffc020339c <page_remove+0x56>
ffffffffc02033b6:	c33ff0ef          	jal	ra,ffffffffc0202fe8 <pa2page.part.4>

ffffffffc02033ba <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc02033ba:	7179                	addi	sp,sp,-48
ffffffffc02033bc:	e44e                	sd	s3,8(sp)
ffffffffc02033be:	89b2                	mv	s3,a2
ffffffffc02033c0:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02033c2:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc02033c4:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02033c6:	85ce                	mv	a1,s3
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc02033c8:	ec26                	sd	s1,24(sp)
ffffffffc02033ca:	f406                	sd	ra,40(sp)
ffffffffc02033cc:	e84a                	sd	s2,16(sp)
ffffffffc02033ce:	e052                	sd	s4,0(sp)
ffffffffc02033d0:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02033d2:	d41ff0ef          	jal	ra,ffffffffc0203112 <get_pte>
    if (ptep == NULL) {
ffffffffc02033d6:	cd49                	beqz	a0,ffffffffc0203470 <page_insert+0xb6>
    page->ref += 1;
ffffffffc02033d8:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc02033da:	611c                	ld	a5,0(a0)
ffffffffc02033dc:	892a                	mv	s2,a0
ffffffffc02033de:	0016871b          	addiw	a4,a3,1
ffffffffc02033e2:	c018                	sw	a4,0(s0)
ffffffffc02033e4:	0017f713          	andi	a4,a5,1
ffffffffc02033e8:	ef05                	bnez	a4,ffffffffc0203420 <page_insert+0x66>
ffffffffc02033ea:	00013797          	auipc	a5,0x13
ffffffffc02033ee:	1fe78793          	addi	a5,a5,510 # ffffffffc02165e8 <pages>
ffffffffc02033f2:	6398                	ld	a4,0(a5)
    return page - pages + nbase;
ffffffffc02033f4:	8c19                	sub	s0,s0,a4
ffffffffc02033f6:	000806b7          	lui	a3,0x80
ffffffffc02033fa:	8419                	srai	s0,s0,0x6
ffffffffc02033fc:	9436                	add	s0,s0,a3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02033fe:	042a                	slli	s0,s0,0xa
ffffffffc0203400:	8c45                	or	s0,s0,s1
ffffffffc0203402:	00146413          	ori	s0,s0,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0203406:	00893023          	sd	s0,0(s2)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020340a:	12098073          	sfence.vma	s3
    return 0;
ffffffffc020340e:	4501                	li	a0,0
}
ffffffffc0203410:	70a2                	ld	ra,40(sp)
ffffffffc0203412:	7402                	ld	s0,32(sp)
ffffffffc0203414:	64e2                	ld	s1,24(sp)
ffffffffc0203416:	6942                	ld	s2,16(sp)
ffffffffc0203418:	69a2                	ld	s3,8(sp)
ffffffffc020341a:	6a02                	ld	s4,0(sp)
ffffffffc020341c:	6145                	addi	sp,sp,48
ffffffffc020341e:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0203420:	00013717          	auipc	a4,0x13
ffffffffc0203424:	08870713          	addi	a4,a4,136 # ffffffffc02164a8 <npage>
ffffffffc0203428:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc020342a:	078a                	slli	a5,a5,0x2
ffffffffc020342c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020342e:	04e7f363          	bleu	a4,a5,ffffffffc0203474 <page_insert+0xba>
    return &pages[PPN(pa) - nbase];
ffffffffc0203432:	00013a17          	auipc	s4,0x13
ffffffffc0203436:	1b6a0a13          	addi	s4,s4,438 # ffffffffc02165e8 <pages>
ffffffffc020343a:	000a3703          	ld	a4,0(s4)
ffffffffc020343e:	fff80537          	lui	a0,0xfff80
ffffffffc0203442:	953e                	add	a0,a0,a5
ffffffffc0203444:	051a                	slli	a0,a0,0x6
ffffffffc0203446:	953a                	add	a0,a0,a4
        if (p == page) {
ffffffffc0203448:	00a40a63          	beq	s0,a0,ffffffffc020345c <page_insert+0xa2>
    page->ref -= 1;
ffffffffc020344c:	411c                	lw	a5,0(a0)
ffffffffc020344e:	fff7869b          	addiw	a3,a5,-1
ffffffffc0203452:	c114                	sw	a3,0(a0)
        if (page_ref(page) ==
ffffffffc0203454:	c691                	beqz	a3,ffffffffc0203460 <page_insert+0xa6>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203456:	12098073          	sfence.vma	s3
ffffffffc020345a:	bf69                	j	ffffffffc02033f4 <page_insert+0x3a>
ffffffffc020345c:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc020345e:	bf59                	j	ffffffffc02033f4 <page_insert+0x3a>
            free_page(page);
ffffffffc0203460:	4585                	li	a1,1
ffffffffc0203462:	c2bff0ef          	jal	ra,ffffffffc020308c <free_pages>
ffffffffc0203466:	000a3703          	ld	a4,0(s4)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020346a:	12098073          	sfence.vma	s3
ffffffffc020346e:	b759                	j	ffffffffc02033f4 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc0203470:	5571                	li	a0,-4
ffffffffc0203472:	bf79                	j	ffffffffc0203410 <page_insert+0x56>
ffffffffc0203474:	b75ff0ef          	jal	ra,ffffffffc0202fe8 <pa2page.part.4>

ffffffffc0203478 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0203478:	00003797          	auipc	a5,0x3
ffffffffc020347c:	1a078793          	addi	a5,a5,416 # ffffffffc0206618 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0203480:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0203482:	715d                	addi	sp,sp,-80
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0203484:	00003517          	auipc	a0,0x3
ffffffffc0203488:	20c50513          	addi	a0,a0,524 # ffffffffc0206690 <default_pmm_manager+0x78>
void pmm_init(void) {
ffffffffc020348c:	e486                	sd	ra,72(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc020348e:	00013717          	auipc	a4,0x13
ffffffffc0203492:	14f73123          	sd	a5,322(a4) # ffffffffc02165d0 <pmm_manager>
void pmm_init(void) {
ffffffffc0203496:	e0a2                	sd	s0,64(sp)
ffffffffc0203498:	fc26                	sd	s1,56(sp)
ffffffffc020349a:	f84a                	sd	s2,48(sp)
ffffffffc020349c:	f44e                	sd	s3,40(sp)
ffffffffc020349e:	f052                	sd	s4,32(sp)
ffffffffc02034a0:	ec56                	sd	s5,24(sp)
ffffffffc02034a2:	e85a                	sd	s6,16(sp)
ffffffffc02034a4:	e45e                	sd	s7,8(sp)
ffffffffc02034a6:	e062                	sd	s8,0(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc02034a8:	00013417          	auipc	s0,0x13
ffffffffc02034ac:	12840413          	addi	s0,s0,296 # ffffffffc02165d0 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02034b0:	c21fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    pmm_manager->init();
ffffffffc02034b4:	601c                	ld	a5,0(s0)
ffffffffc02034b6:	00013497          	auipc	s1,0x13
ffffffffc02034ba:	ff248493          	addi	s1,s1,-14 # ffffffffc02164a8 <npage>
ffffffffc02034be:	00013917          	auipc	s2,0x13
ffffffffc02034c2:	12a90913          	addi	s2,s2,298 # ffffffffc02165e8 <pages>
ffffffffc02034c6:	679c                	ld	a5,8(a5)
ffffffffc02034c8:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc02034ca:	57f5                	li	a5,-3
ffffffffc02034cc:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc02034ce:	00003517          	auipc	a0,0x3
ffffffffc02034d2:	1da50513          	addi	a0,a0,474 # ffffffffc02066a8 <default_pmm_manager+0x90>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc02034d6:	00013717          	auipc	a4,0x13
ffffffffc02034da:	10f73123          	sd	a5,258(a4) # ffffffffc02165d8 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc02034de:	bf3fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc02034e2:	46c5                	li	a3,17
ffffffffc02034e4:	06ee                	slli	a3,a3,0x1b
ffffffffc02034e6:	40100613          	li	a2,1025
ffffffffc02034ea:	16fd                	addi	a3,a3,-1
ffffffffc02034ec:	0656                	slli	a2,a2,0x15
ffffffffc02034ee:	07e005b7          	lui	a1,0x7e00
ffffffffc02034f2:	00003517          	auipc	a0,0x3
ffffffffc02034f6:	1ce50513          	addi	a0,a0,462 # ffffffffc02066c0 <default_pmm_manager+0xa8>
ffffffffc02034fa:	bd7fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02034fe:	777d                	lui	a4,0xfffff
ffffffffc0203500:	00014797          	auipc	a5,0x14
ffffffffc0203504:	0ff78793          	addi	a5,a5,255 # ffffffffc02175ff <end+0xfff>
ffffffffc0203508:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc020350a:	00088737          	lui	a4,0x88
ffffffffc020350e:	00013697          	auipc	a3,0x13
ffffffffc0203512:	f8e6bd23          	sd	a4,-102(a3) # ffffffffc02164a8 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0203516:	00013717          	auipc	a4,0x13
ffffffffc020351a:	0cf73923          	sd	a5,210(a4) # ffffffffc02165e8 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020351e:	4701                	li	a4,0
ffffffffc0203520:	4685                	li	a3,1
ffffffffc0203522:	fff80837          	lui	a6,0xfff80
ffffffffc0203526:	a019                	j	ffffffffc020352c <pmm_init+0xb4>
ffffffffc0203528:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc020352c:	00671613          	slli	a2,a4,0x6
ffffffffc0203530:	97b2                	add	a5,a5,a2
ffffffffc0203532:	07a1                	addi	a5,a5,8
ffffffffc0203534:	40d7b02f          	amoor.d	zero,a3,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0203538:	6090                	ld	a2,0(s1)
ffffffffc020353a:	0705                	addi	a4,a4,1
ffffffffc020353c:	010607b3          	add	a5,a2,a6
ffffffffc0203540:	fef764e3          	bltu	a4,a5,ffffffffc0203528 <pmm_init+0xb0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203544:	00093503          	ld	a0,0(s2)
ffffffffc0203548:	fe0007b7          	lui	a5,0xfe000
ffffffffc020354c:	00661693          	slli	a3,a2,0x6
ffffffffc0203550:	97aa                	add	a5,a5,a0
ffffffffc0203552:	96be                	add	a3,a3,a5
ffffffffc0203554:	c02007b7          	lui	a5,0xc0200
ffffffffc0203558:	7af6ed63          	bltu	a3,a5,ffffffffc0203d12 <pmm_init+0x89a>
ffffffffc020355c:	00013997          	auipc	s3,0x13
ffffffffc0203560:	07c98993          	addi	s3,s3,124 # ffffffffc02165d8 <va_pa_offset>
ffffffffc0203564:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc0203568:	47c5                	li	a5,17
ffffffffc020356a:	07ee                	slli	a5,a5,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020356c:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc020356e:	02f6f763          	bleu	a5,a3,ffffffffc020359c <pmm_init+0x124>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0203572:	6585                	lui	a1,0x1
ffffffffc0203574:	15fd                	addi	a1,a1,-1
ffffffffc0203576:	96ae                	add	a3,a3,a1
    if (PPN(pa) >= npage) {
ffffffffc0203578:	00c6d713          	srli	a4,a3,0xc
ffffffffc020357c:	48c77a63          	bleu	a2,a4,ffffffffc0203a10 <pmm_init+0x598>
    pmm_manager->init_memmap(base, n);
ffffffffc0203580:	6010                	ld	a2,0(s0)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0203582:	75fd                	lui	a1,0xfffff
ffffffffc0203584:	8eed                	and	a3,a3,a1
    return &pages[PPN(pa) - nbase];
ffffffffc0203586:	9742                	add	a4,a4,a6
    pmm_manager->init_memmap(base, n);
ffffffffc0203588:	6a10                	ld	a2,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc020358a:	40d786b3          	sub	a3,a5,a3
ffffffffc020358e:	071a                	slli	a4,a4,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc0203590:	00c6d593          	srli	a1,a3,0xc
ffffffffc0203594:	953a                	add	a0,a0,a4
ffffffffc0203596:	9602                	jalr	a2
ffffffffc0203598:	0009b583          	ld	a1,0(s3)
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc020359c:	00003517          	auipc	a0,0x3
ffffffffc02035a0:	14c50513          	addi	a0,a0,332 # ffffffffc02066e8 <default_pmm_manager+0xd0>
ffffffffc02035a4:	b2dfc0ef          	jal	ra,ffffffffc02000d0 <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc02035a8:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc02035aa:	00013417          	auipc	s0,0x13
ffffffffc02035ae:	ef640413          	addi	s0,s0,-266 # ffffffffc02164a0 <boot_pgdir>
    pmm_manager->check();
ffffffffc02035b2:	7b9c                	ld	a5,48(a5)
ffffffffc02035b4:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02035b6:	00003517          	auipc	a0,0x3
ffffffffc02035ba:	14a50513          	addi	a0,a0,330 # ffffffffc0206700 <default_pmm_manager+0xe8>
ffffffffc02035be:	b13fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc02035c2:	00007697          	auipc	a3,0x7
ffffffffc02035c6:	a3e68693          	addi	a3,a3,-1474 # ffffffffc020a000 <boot_page_table_sv39>
ffffffffc02035ca:	00013797          	auipc	a5,0x13
ffffffffc02035ce:	ecd7bb23          	sd	a3,-298(a5) # ffffffffc02164a0 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc02035d2:	c02007b7          	lui	a5,0xc0200
ffffffffc02035d6:	10f6eae3          	bltu	a3,a5,ffffffffc0203eea <pmm_init+0xa72>
ffffffffc02035da:	0009b783          	ld	a5,0(s3)
ffffffffc02035de:	8e9d                	sub	a3,a3,a5
ffffffffc02035e0:	00013797          	auipc	a5,0x13
ffffffffc02035e4:	00d7b023          	sd	a3,0(a5) # ffffffffc02165e0 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc02035e8:	aebff0ef          	jal	ra,ffffffffc02030d2 <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02035ec:	6098                	ld	a4,0(s1)
ffffffffc02035ee:	c80007b7          	lui	a5,0xc8000
ffffffffc02035f2:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc02035f4:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02035f6:	0ce7eae3          	bltu	a5,a4,ffffffffc0203eca <pmm_init+0xa52>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02035fa:	6008                	ld	a0,0(s0)
ffffffffc02035fc:	44050463          	beqz	a0,ffffffffc0203a44 <pmm_init+0x5cc>
ffffffffc0203600:	6785                	lui	a5,0x1
ffffffffc0203602:	17fd                	addi	a5,a5,-1
ffffffffc0203604:	8fe9                	and	a5,a5,a0
ffffffffc0203606:	2781                	sext.w	a5,a5
ffffffffc0203608:	42079e63          	bnez	a5,ffffffffc0203a44 <pmm_init+0x5cc>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc020360c:	4601                	li	a2,0
ffffffffc020360e:	4581                	li	a1,0
ffffffffc0203610:	cd5ff0ef          	jal	ra,ffffffffc02032e4 <get_page>
ffffffffc0203614:	78051b63          	bnez	a0,ffffffffc0203daa <pmm_init+0x932>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0203618:	4505                	li	a0,1
ffffffffc020361a:	9ebff0ef          	jal	ra,ffffffffc0203004 <alloc_pages>
ffffffffc020361e:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0203620:	6008                	ld	a0,0(s0)
ffffffffc0203622:	4681                	li	a3,0
ffffffffc0203624:	4601                	li	a2,0
ffffffffc0203626:	85d6                	mv	a1,s5
ffffffffc0203628:	d93ff0ef          	jal	ra,ffffffffc02033ba <page_insert>
ffffffffc020362c:	7a051f63          	bnez	a0,ffffffffc0203dea <pmm_init+0x972>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0203630:	6008                	ld	a0,0(s0)
ffffffffc0203632:	4601                	li	a2,0
ffffffffc0203634:	4581                	li	a1,0
ffffffffc0203636:	addff0ef          	jal	ra,ffffffffc0203112 <get_pte>
ffffffffc020363a:	78050863          	beqz	a0,ffffffffc0203dca <pmm_init+0x952>
    assert(pte2page(*ptep) == p1);
ffffffffc020363e:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0203640:	0017f713          	andi	a4,a5,1
ffffffffc0203644:	3e070463          	beqz	a4,ffffffffc0203a2c <pmm_init+0x5b4>
    if (PPN(pa) >= npage) {
ffffffffc0203648:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc020364a:	078a                	slli	a5,a5,0x2
ffffffffc020364c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020364e:	3ce7f163          	bleu	a4,a5,ffffffffc0203a10 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0203652:	00093683          	ld	a3,0(s2)
ffffffffc0203656:	fff80637          	lui	a2,0xfff80
ffffffffc020365a:	97b2                	add	a5,a5,a2
ffffffffc020365c:	079a                	slli	a5,a5,0x6
ffffffffc020365e:	97b6                	add	a5,a5,a3
ffffffffc0203660:	72fa9563          	bne	s5,a5,ffffffffc0203d8a <pmm_init+0x912>
    assert(page_ref(p1) == 1);
ffffffffc0203664:	000aab83          	lw	s7,0(s5)
ffffffffc0203668:	4785                	li	a5,1
ffffffffc020366a:	70fb9063          	bne	s7,a5,ffffffffc0203d6a <pmm_init+0x8f2>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc020366e:	6008                	ld	a0,0(s0)
ffffffffc0203670:	76fd                	lui	a3,0xfffff
ffffffffc0203672:	611c                	ld	a5,0(a0)
ffffffffc0203674:	078a                	slli	a5,a5,0x2
ffffffffc0203676:	8ff5                	and	a5,a5,a3
ffffffffc0203678:	00c7d613          	srli	a2,a5,0xc
ffffffffc020367c:	66e67e63          	bleu	a4,a2,ffffffffc0203cf8 <pmm_init+0x880>
ffffffffc0203680:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203684:	97e2                	add	a5,a5,s8
ffffffffc0203686:	0007bb03          	ld	s6,0(a5) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc020368a:	0b0a                	slli	s6,s6,0x2
ffffffffc020368c:	00db7b33          	and	s6,s6,a3
ffffffffc0203690:	00cb5793          	srli	a5,s6,0xc
ffffffffc0203694:	56e7f863          	bleu	a4,a5,ffffffffc0203c04 <pmm_init+0x78c>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0203698:	4601                	li	a2,0
ffffffffc020369a:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020369c:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020369e:	a75ff0ef          	jal	ra,ffffffffc0203112 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02036a2:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02036a4:	55651063          	bne	a0,s6,ffffffffc0203be4 <pmm_init+0x76c>

    p2 = alloc_page();
ffffffffc02036a8:	4505                	li	a0,1
ffffffffc02036aa:	95bff0ef          	jal	ra,ffffffffc0203004 <alloc_pages>
ffffffffc02036ae:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02036b0:	6008                	ld	a0,0(s0)
ffffffffc02036b2:	46d1                	li	a3,20
ffffffffc02036b4:	6605                	lui	a2,0x1
ffffffffc02036b6:	85da                	mv	a1,s6
ffffffffc02036b8:	d03ff0ef          	jal	ra,ffffffffc02033ba <page_insert>
ffffffffc02036bc:	50051463          	bnez	a0,ffffffffc0203bc4 <pmm_init+0x74c>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02036c0:	6008                	ld	a0,0(s0)
ffffffffc02036c2:	4601                	li	a2,0
ffffffffc02036c4:	6585                	lui	a1,0x1
ffffffffc02036c6:	a4dff0ef          	jal	ra,ffffffffc0203112 <get_pte>
ffffffffc02036ca:	4c050d63          	beqz	a0,ffffffffc0203ba4 <pmm_init+0x72c>
    assert(*ptep & PTE_U);
ffffffffc02036ce:	611c                	ld	a5,0(a0)
ffffffffc02036d0:	0107f713          	andi	a4,a5,16
ffffffffc02036d4:	4a070863          	beqz	a4,ffffffffc0203b84 <pmm_init+0x70c>
    assert(*ptep & PTE_W);
ffffffffc02036d8:	8b91                	andi	a5,a5,4
ffffffffc02036da:	48078563          	beqz	a5,ffffffffc0203b64 <pmm_init+0x6ec>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02036de:	6008                	ld	a0,0(s0)
ffffffffc02036e0:	611c                	ld	a5,0(a0)
ffffffffc02036e2:	8bc1                	andi	a5,a5,16
ffffffffc02036e4:	46078063          	beqz	a5,ffffffffc0203b44 <pmm_init+0x6cc>
    assert(page_ref(p2) == 1);
ffffffffc02036e8:	000b2783          	lw	a5,0(s6)
ffffffffc02036ec:	43779c63          	bne	a5,s7,ffffffffc0203b24 <pmm_init+0x6ac>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02036f0:	4681                	li	a3,0
ffffffffc02036f2:	6605                	lui	a2,0x1
ffffffffc02036f4:	85d6                	mv	a1,s5
ffffffffc02036f6:	cc5ff0ef          	jal	ra,ffffffffc02033ba <page_insert>
ffffffffc02036fa:	40051563          	bnez	a0,ffffffffc0203b04 <pmm_init+0x68c>
    assert(page_ref(p1) == 2);
ffffffffc02036fe:	000aa703          	lw	a4,0(s5)
ffffffffc0203702:	4789                	li	a5,2
ffffffffc0203704:	3ef71063          	bne	a4,a5,ffffffffc0203ae4 <pmm_init+0x66c>
    assert(page_ref(p2) == 0);
ffffffffc0203708:	000b2783          	lw	a5,0(s6)
ffffffffc020370c:	3a079c63          	bnez	a5,ffffffffc0203ac4 <pmm_init+0x64c>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0203710:	6008                	ld	a0,0(s0)
ffffffffc0203712:	4601                	li	a2,0
ffffffffc0203714:	6585                	lui	a1,0x1
ffffffffc0203716:	9fdff0ef          	jal	ra,ffffffffc0203112 <get_pte>
ffffffffc020371a:	38050563          	beqz	a0,ffffffffc0203aa4 <pmm_init+0x62c>
    assert(pte2page(*ptep) == p1);
ffffffffc020371e:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0203720:	00177793          	andi	a5,a4,1
ffffffffc0203724:	30078463          	beqz	a5,ffffffffc0203a2c <pmm_init+0x5b4>
    if (PPN(pa) >= npage) {
ffffffffc0203728:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc020372a:	00271793          	slli	a5,a4,0x2
ffffffffc020372e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203730:	2ed7f063          	bleu	a3,a5,ffffffffc0203a10 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0203734:	00093683          	ld	a3,0(s2)
ffffffffc0203738:	fff80637          	lui	a2,0xfff80
ffffffffc020373c:	97b2                	add	a5,a5,a2
ffffffffc020373e:	079a                	slli	a5,a5,0x6
ffffffffc0203740:	97b6                	add	a5,a5,a3
ffffffffc0203742:	32fa9163          	bne	s5,a5,ffffffffc0203a64 <pmm_init+0x5ec>
    assert((*ptep & PTE_U) == 0);
ffffffffc0203746:	8b41                	andi	a4,a4,16
ffffffffc0203748:	70071163          	bnez	a4,ffffffffc0203e4a <pmm_init+0x9d2>

    page_remove(boot_pgdir, 0x0);
ffffffffc020374c:	6008                	ld	a0,0(s0)
ffffffffc020374e:	4581                	li	a1,0
ffffffffc0203750:	bf7ff0ef          	jal	ra,ffffffffc0203346 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0203754:	000aa703          	lw	a4,0(s5)
ffffffffc0203758:	4785                	li	a5,1
ffffffffc020375a:	6cf71863          	bne	a4,a5,ffffffffc0203e2a <pmm_init+0x9b2>
    assert(page_ref(p2) == 0);
ffffffffc020375e:	000b2783          	lw	a5,0(s6)
ffffffffc0203762:	6a079463          	bnez	a5,ffffffffc0203e0a <pmm_init+0x992>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0203766:	6008                	ld	a0,0(s0)
ffffffffc0203768:	6585                	lui	a1,0x1
ffffffffc020376a:	bddff0ef          	jal	ra,ffffffffc0203346 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc020376e:	000aa783          	lw	a5,0(s5)
ffffffffc0203772:	50079363          	bnez	a5,ffffffffc0203c78 <pmm_init+0x800>
    assert(page_ref(p2) == 0);
ffffffffc0203776:	000b2783          	lw	a5,0(s6)
ffffffffc020377a:	4c079f63          	bnez	a5,ffffffffc0203c58 <pmm_init+0x7e0>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc020377e:	00043a83          	ld	s5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0203782:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203784:	000ab783          	ld	a5,0(s5)
ffffffffc0203788:	078a                	slli	a5,a5,0x2
ffffffffc020378a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020378c:	28c7f263          	bleu	a2,a5,ffffffffc0203a10 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0203790:	fff80737          	lui	a4,0xfff80
ffffffffc0203794:	00093503          	ld	a0,0(s2)
ffffffffc0203798:	97ba                	add	a5,a5,a4
ffffffffc020379a:	079a                	slli	a5,a5,0x6
ffffffffc020379c:	00f50733          	add	a4,a0,a5
ffffffffc02037a0:	4314                	lw	a3,0(a4)
ffffffffc02037a2:	4705                	li	a4,1
ffffffffc02037a4:	48e69a63          	bne	a3,a4,ffffffffc0203c38 <pmm_init+0x7c0>
    return page - pages + nbase;
ffffffffc02037a8:	8799                	srai	a5,a5,0x6
ffffffffc02037aa:	00080b37          	lui	s6,0x80
    return KADDR(page2pa(page));
ffffffffc02037ae:	577d                	li	a4,-1
    return page - pages + nbase;
ffffffffc02037b0:	97da                	add	a5,a5,s6
    return KADDR(page2pa(page));
ffffffffc02037b2:	8331                	srli	a4,a4,0xc
ffffffffc02037b4:	8f7d                	and	a4,a4,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc02037b6:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc02037b8:	46c77363          	bleu	a2,a4,ffffffffc0203c1e <pmm_init+0x7a6>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc02037bc:	0009b683          	ld	a3,0(s3)
ffffffffc02037c0:	97b6                	add	a5,a5,a3
    return pa2page(PDE_ADDR(pde));
ffffffffc02037c2:	639c                	ld	a5,0(a5)
ffffffffc02037c4:	078a                	slli	a5,a5,0x2
ffffffffc02037c6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02037c8:	24c7f463          	bleu	a2,a5,ffffffffc0203a10 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02037cc:	416787b3          	sub	a5,a5,s6
ffffffffc02037d0:	079a                	slli	a5,a5,0x6
ffffffffc02037d2:	953e                	add	a0,a0,a5
ffffffffc02037d4:	4585                	li	a1,1
ffffffffc02037d6:	8b7ff0ef          	jal	ra,ffffffffc020308c <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02037da:	000ab783          	ld	a5,0(s5)
    if (PPN(pa) >= npage) {
ffffffffc02037de:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02037e0:	078a                	slli	a5,a5,0x2
ffffffffc02037e2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02037e4:	22e7f663          	bleu	a4,a5,ffffffffc0203a10 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02037e8:	00093503          	ld	a0,0(s2)
ffffffffc02037ec:	416787b3          	sub	a5,a5,s6
ffffffffc02037f0:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc02037f2:	953e                	add	a0,a0,a5
ffffffffc02037f4:	4585                	li	a1,1
ffffffffc02037f6:	897ff0ef          	jal	ra,ffffffffc020308c <free_pages>
    boot_pgdir[0] = 0;
ffffffffc02037fa:	601c                	ld	a5,0(s0)
ffffffffc02037fc:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc0203800:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0203804:	8cfff0ef          	jal	ra,ffffffffc02030d2 <nr_free_pages>
ffffffffc0203808:	68aa1163          	bne	s4,a0,ffffffffc0203e8a <pmm_init+0xa12>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc020380c:	00003517          	auipc	a0,0x3
ffffffffc0203810:	1dc50513          	addi	a0,a0,476 # ffffffffc02069e8 <default_pmm_manager+0x3d0>
ffffffffc0203814:	8bdfc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc0203818:	8bbff0ef          	jal	ra,ffffffffc02030d2 <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020381c:	6098                	ld	a4,0(s1)
ffffffffc020381e:	c02007b7          	lui	a5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc0203822:	8a2a                	mv	s4,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0203824:	00c71693          	slli	a3,a4,0xc
ffffffffc0203828:	18d7f563          	bleu	a3,a5,ffffffffc02039b2 <pmm_init+0x53a>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020382c:	83b1                	srli	a5,a5,0xc
ffffffffc020382e:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0203830:	c0200ab7          	lui	s5,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0203834:	1ae7f163          	bleu	a4,a5,ffffffffc02039d6 <pmm_init+0x55e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0203838:	7bfd                	lui	s7,0xfffff
ffffffffc020383a:	6b05                	lui	s6,0x1
ffffffffc020383c:	a029                	j	ffffffffc0203846 <pmm_init+0x3ce>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020383e:	00cad713          	srli	a4,s5,0xc
ffffffffc0203842:	18f77a63          	bleu	a5,a4,ffffffffc02039d6 <pmm_init+0x55e>
ffffffffc0203846:	0009b583          	ld	a1,0(s3)
ffffffffc020384a:	4601                	li	a2,0
ffffffffc020384c:	95d6                	add	a1,a1,s5
ffffffffc020384e:	8c5ff0ef          	jal	ra,ffffffffc0203112 <get_pte>
ffffffffc0203852:	16050263          	beqz	a0,ffffffffc02039b6 <pmm_init+0x53e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0203856:	611c                	ld	a5,0(a0)
ffffffffc0203858:	078a                	slli	a5,a5,0x2
ffffffffc020385a:	0177f7b3          	and	a5,a5,s7
ffffffffc020385e:	19579963          	bne	a5,s5,ffffffffc02039f0 <pmm_init+0x578>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0203862:	609c                	ld	a5,0(s1)
ffffffffc0203864:	9ada                	add	s5,s5,s6
ffffffffc0203866:	6008                	ld	a0,0(s0)
ffffffffc0203868:	00c79713          	slli	a4,a5,0xc
ffffffffc020386c:	fceae9e3          	bltu	s5,a4,ffffffffc020383e <pmm_init+0x3c6>
    }

    assert(boot_pgdir[0] == 0);
ffffffffc0203870:	611c                	ld	a5,0(a0)
ffffffffc0203872:	62079c63          	bnez	a5,ffffffffc0203eaa <pmm_init+0xa32>

    struct Page *p;
    p = alloc_page();
ffffffffc0203876:	4505                	li	a0,1
ffffffffc0203878:	f8cff0ef          	jal	ra,ffffffffc0203004 <alloc_pages>
ffffffffc020387c:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc020387e:	6008                	ld	a0,0(s0)
ffffffffc0203880:	4699                	li	a3,6
ffffffffc0203882:	10000613          	li	a2,256
ffffffffc0203886:	85d6                	mv	a1,s5
ffffffffc0203888:	b33ff0ef          	jal	ra,ffffffffc02033ba <page_insert>
ffffffffc020388c:	1e051c63          	bnez	a0,ffffffffc0203a84 <pmm_init+0x60c>
    assert(page_ref(p) == 1);
ffffffffc0203890:	000aa703          	lw	a4,0(s5) # ffffffffc0200000 <kern_entry>
ffffffffc0203894:	4785                	li	a5,1
ffffffffc0203896:	44f71163          	bne	a4,a5,ffffffffc0203cd8 <pmm_init+0x860>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc020389a:	6008                	ld	a0,0(s0)
ffffffffc020389c:	6b05                	lui	s6,0x1
ffffffffc020389e:	4699                	li	a3,6
ffffffffc02038a0:	100b0613          	addi	a2,s6,256 # 1100 <BASE_ADDRESS-0xffffffffc01fef00>
ffffffffc02038a4:	85d6                	mv	a1,s5
ffffffffc02038a6:	b15ff0ef          	jal	ra,ffffffffc02033ba <page_insert>
ffffffffc02038aa:	40051763          	bnez	a0,ffffffffc0203cb8 <pmm_init+0x840>
    assert(page_ref(p) == 2);
ffffffffc02038ae:	000aa703          	lw	a4,0(s5)
ffffffffc02038b2:	4789                	li	a5,2
ffffffffc02038b4:	3ef71263          	bne	a4,a5,ffffffffc0203c98 <pmm_init+0x820>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc02038b8:	00003597          	auipc	a1,0x3
ffffffffc02038bc:	26858593          	addi	a1,a1,616 # ffffffffc0206b20 <default_pmm_manager+0x508>
ffffffffc02038c0:	10000513          	li	a0,256
ffffffffc02038c4:	1a2010ef          	jal	ra,ffffffffc0204a66 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02038c8:	100b0593          	addi	a1,s6,256
ffffffffc02038cc:	10000513          	li	a0,256
ffffffffc02038d0:	1a8010ef          	jal	ra,ffffffffc0204a78 <strcmp>
ffffffffc02038d4:	44051b63          	bnez	a0,ffffffffc0203d2a <pmm_init+0x8b2>
    return page - pages + nbase;
ffffffffc02038d8:	00093683          	ld	a3,0(s2)
ffffffffc02038dc:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc02038e0:	5b7d                	li	s6,-1
    return page - pages + nbase;
ffffffffc02038e2:	40da86b3          	sub	a3,s5,a3
ffffffffc02038e6:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02038e8:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc02038ea:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc02038ec:	00cb5b13          	srli	s6,s6,0xc
ffffffffc02038f0:	0166f733          	and	a4,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc02038f4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02038f6:	10f77f63          	bleu	a5,a4,ffffffffc0203a14 <pmm_init+0x59c>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc02038fa:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc02038fe:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0203902:	96be                	add	a3,a3,a5
ffffffffc0203904:	10068023          	sb	zero,256(a3) # fffffffffffff100 <end+0x3fde8b00>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203908:	11a010ef          	jal	ra,ffffffffc0204a22 <strlen>
ffffffffc020390c:	54051f63          	bnez	a0,ffffffffc0203e6a <pmm_init+0x9f2>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0203910:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0203914:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203916:	000bb683          	ld	a3,0(s7) # fffffffffffff000 <end+0x3fde8a00>
ffffffffc020391a:	068a                	slli	a3,a3,0x2
ffffffffc020391c:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc020391e:	0ef6f963          	bleu	a5,a3,ffffffffc0203a10 <pmm_init+0x598>
    return KADDR(page2pa(page));
ffffffffc0203922:	0166fb33          	and	s6,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0203926:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203928:	0efb7663          	bleu	a5,s6,ffffffffc0203a14 <pmm_init+0x59c>
ffffffffc020392c:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc0203930:	4585                	li	a1,1
ffffffffc0203932:	8556                	mv	a0,s5
ffffffffc0203934:	99b6                	add	s3,s3,a3
ffffffffc0203936:	f56ff0ef          	jal	ra,ffffffffc020308c <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc020393a:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc020393e:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203940:	078a                	slli	a5,a5,0x2
ffffffffc0203942:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203944:	0ce7f663          	bleu	a4,a5,ffffffffc0203a10 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0203948:	00093503          	ld	a0,0(s2)
ffffffffc020394c:	fff809b7          	lui	s3,0xfff80
ffffffffc0203950:	97ce                	add	a5,a5,s3
ffffffffc0203952:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0203954:	953e                	add	a0,a0,a5
ffffffffc0203956:	4585                	li	a1,1
ffffffffc0203958:	f34ff0ef          	jal	ra,ffffffffc020308c <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc020395c:	000bb783          	ld	a5,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc0203960:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203962:	078a                	slli	a5,a5,0x2
ffffffffc0203964:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203966:	0ae7f563          	bleu	a4,a5,ffffffffc0203a10 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc020396a:	00093503          	ld	a0,0(s2)
ffffffffc020396e:	97ce                	add	a5,a5,s3
ffffffffc0203970:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0203972:	953e                	add	a0,a0,a5
ffffffffc0203974:	4585                	li	a1,1
ffffffffc0203976:	f16ff0ef          	jal	ra,ffffffffc020308c <free_pages>
    boot_pgdir[0] = 0;
ffffffffc020397a:	601c                	ld	a5,0(s0)
ffffffffc020397c:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>
  asm volatile("sfence.vma");
ffffffffc0203980:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0203984:	f4eff0ef          	jal	ra,ffffffffc02030d2 <nr_free_pages>
ffffffffc0203988:	3caa1163          	bne	s4,a0,ffffffffc0203d4a <pmm_init+0x8d2>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc020398c:	00003517          	auipc	a0,0x3
ffffffffc0203990:	20c50513          	addi	a0,a0,524 # ffffffffc0206b98 <default_pmm_manager+0x580>
ffffffffc0203994:	f3cfc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
}
ffffffffc0203998:	6406                	ld	s0,64(sp)
ffffffffc020399a:	60a6                	ld	ra,72(sp)
ffffffffc020399c:	74e2                	ld	s1,56(sp)
ffffffffc020399e:	7942                	ld	s2,48(sp)
ffffffffc02039a0:	79a2                	ld	s3,40(sp)
ffffffffc02039a2:	7a02                	ld	s4,32(sp)
ffffffffc02039a4:	6ae2                	ld	s5,24(sp)
ffffffffc02039a6:	6b42                	ld	s6,16(sp)
ffffffffc02039a8:	6ba2                	ld	s7,8(sp)
ffffffffc02039aa:	6c02                	ld	s8,0(sp)
ffffffffc02039ac:	6161                	addi	sp,sp,80
    kmalloc_init();
ffffffffc02039ae:	d04fe06f          	j	ffffffffc0201eb2 <kmalloc_init>
ffffffffc02039b2:	6008                	ld	a0,0(s0)
ffffffffc02039b4:	bd75                	j	ffffffffc0203870 <pmm_init+0x3f8>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02039b6:	00003697          	auipc	a3,0x3
ffffffffc02039ba:	05268693          	addi	a3,a3,82 # ffffffffc0206a08 <default_pmm_manager+0x3f0>
ffffffffc02039be:	00002617          	auipc	a2,0x2
ffffffffc02039c2:	f2260613          	addi	a2,a2,-222 # ffffffffc02058e0 <commands+0x860>
ffffffffc02039c6:	19d00593          	li	a1,413
ffffffffc02039ca:	00003517          	auipc	a0,0x3
ffffffffc02039ce:	c9e50513          	addi	a0,a0,-866 # ffffffffc0206668 <default_pmm_manager+0x50>
ffffffffc02039d2:	805fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
ffffffffc02039d6:	86d6                	mv	a3,s5
ffffffffc02039d8:	00002617          	auipc	a2,0x2
ffffffffc02039dc:	27060613          	addi	a2,a2,624 # ffffffffc0205c48 <commands+0xbc8>
ffffffffc02039e0:	19d00593          	li	a1,413
ffffffffc02039e4:	00003517          	auipc	a0,0x3
ffffffffc02039e8:	c8450513          	addi	a0,a0,-892 # ffffffffc0206668 <default_pmm_manager+0x50>
ffffffffc02039ec:	feafc0ef          	jal	ra,ffffffffc02001d6 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02039f0:	00003697          	auipc	a3,0x3
ffffffffc02039f4:	05868693          	addi	a3,a3,88 # ffffffffc0206a48 <default_pmm_manager+0x430>
ffffffffc02039f8:	00002617          	auipc	a2,0x2
ffffffffc02039fc:	ee860613          	addi	a2,a2,-280 # ffffffffc02058e0 <commands+0x860>
ffffffffc0203a00:	19e00593          	li	a1,414
ffffffffc0203a04:	00003517          	auipc	a0,0x3
ffffffffc0203a08:	c6450513          	addi	a0,a0,-924 # ffffffffc0206668 <default_pmm_manager+0x50>
ffffffffc0203a0c:	fcafc0ef          	jal	ra,ffffffffc02001d6 <__panic>
ffffffffc0203a10:	dd8ff0ef          	jal	ra,ffffffffc0202fe8 <pa2page.part.4>
    return KADDR(page2pa(page));
ffffffffc0203a14:	00002617          	auipc	a2,0x2
ffffffffc0203a18:	23460613          	addi	a2,a2,564 # ffffffffc0205c48 <commands+0xbc8>
ffffffffc0203a1c:	06900593          	li	a1,105
ffffffffc0203a20:	00002517          	auipc	a0,0x2
ffffffffc0203a24:	21850513          	addi	a0,a0,536 # ffffffffc0205c38 <commands+0xbb8>
ffffffffc0203a28:	faefc0ef          	jal	ra,ffffffffc02001d6 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0203a2c:	00002617          	auipc	a2,0x2
ffffffffc0203a30:	4d460613          	addi	a2,a2,1236 # ffffffffc0205f00 <commands+0xe80>
ffffffffc0203a34:	07400593          	li	a1,116
ffffffffc0203a38:	00002517          	auipc	a0,0x2
ffffffffc0203a3c:	20050513          	addi	a0,a0,512 # ffffffffc0205c38 <commands+0xbb8>
ffffffffc0203a40:	f96fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0203a44:	00003697          	auipc	a3,0x3
ffffffffc0203a48:	cfc68693          	addi	a3,a3,-772 # ffffffffc0206740 <default_pmm_manager+0x128>
ffffffffc0203a4c:	00002617          	auipc	a2,0x2
ffffffffc0203a50:	e9460613          	addi	a2,a2,-364 # ffffffffc02058e0 <commands+0x860>
ffffffffc0203a54:	16100593          	li	a1,353
ffffffffc0203a58:	00003517          	auipc	a0,0x3
ffffffffc0203a5c:	c1050513          	addi	a0,a0,-1008 # ffffffffc0206668 <default_pmm_manager+0x50>
ffffffffc0203a60:	f76fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203a64:	00003697          	auipc	a3,0x3
ffffffffc0203a68:	d9c68693          	addi	a3,a3,-612 # ffffffffc0206800 <default_pmm_manager+0x1e8>
ffffffffc0203a6c:	00002617          	auipc	a2,0x2
ffffffffc0203a70:	e7460613          	addi	a2,a2,-396 # ffffffffc02058e0 <commands+0x860>
ffffffffc0203a74:	17d00593          	li	a1,381
ffffffffc0203a78:	00003517          	auipc	a0,0x3
ffffffffc0203a7c:	bf050513          	addi	a0,a0,-1040 # ffffffffc0206668 <default_pmm_manager+0x50>
ffffffffc0203a80:	f56fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0203a84:	00003697          	auipc	a3,0x3
ffffffffc0203a88:	ff468693          	addi	a3,a3,-12 # ffffffffc0206a78 <default_pmm_manager+0x460>
ffffffffc0203a8c:	00002617          	auipc	a2,0x2
ffffffffc0203a90:	e5460613          	addi	a2,a2,-428 # ffffffffc02058e0 <commands+0x860>
ffffffffc0203a94:	1a500593          	li	a1,421
ffffffffc0203a98:	00003517          	auipc	a0,0x3
ffffffffc0203a9c:	bd050513          	addi	a0,a0,-1072 # ffffffffc0206668 <default_pmm_manager+0x50>
ffffffffc0203aa0:	f36fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0203aa4:	00003697          	auipc	a3,0x3
ffffffffc0203aa8:	dec68693          	addi	a3,a3,-532 # ffffffffc0206890 <default_pmm_manager+0x278>
ffffffffc0203aac:	00002617          	auipc	a2,0x2
ffffffffc0203ab0:	e3460613          	addi	a2,a2,-460 # ffffffffc02058e0 <commands+0x860>
ffffffffc0203ab4:	17c00593          	li	a1,380
ffffffffc0203ab8:	00003517          	auipc	a0,0x3
ffffffffc0203abc:	bb050513          	addi	a0,a0,-1104 # ffffffffc0206668 <default_pmm_manager+0x50>
ffffffffc0203ac0:	f16fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203ac4:	00003697          	auipc	a3,0x3
ffffffffc0203ac8:	e9468693          	addi	a3,a3,-364 # ffffffffc0206958 <default_pmm_manager+0x340>
ffffffffc0203acc:	00002617          	auipc	a2,0x2
ffffffffc0203ad0:	e1460613          	addi	a2,a2,-492 # ffffffffc02058e0 <commands+0x860>
ffffffffc0203ad4:	17b00593          	li	a1,379
ffffffffc0203ad8:	00003517          	auipc	a0,0x3
ffffffffc0203adc:	b9050513          	addi	a0,a0,-1136 # ffffffffc0206668 <default_pmm_manager+0x50>
ffffffffc0203ae0:	ef6fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0203ae4:	00003697          	auipc	a3,0x3
ffffffffc0203ae8:	e5c68693          	addi	a3,a3,-420 # ffffffffc0206940 <default_pmm_manager+0x328>
ffffffffc0203aec:	00002617          	auipc	a2,0x2
ffffffffc0203af0:	df460613          	addi	a2,a2,-524 # ffffffffc02058e0 <commands+0x860>
ffffffffc0203af4:	17a00593          	li	a1,378
ffffffffc0203af8:	00003517          	auipc	a0,0x3
ffffffffc0203afc:	b7050513          	addi	a0,a0,-1168 # ffffffffc0206668 <default_pmm_manager+0x50>
ffffffffc0203b00:	ed6fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0203b04:	00003697          	auipc	a3,0x3
ffffffffc0203b08:	e0c68693          	addi	a3,a3,-500 # ffffffffc0206910 <default_pmm_manager+0x2f8>
ffffffffc0203b0c:	00002617          	auipc	a2,0x2
ffffffffc0203b10:	dd460613          	addi	a2,a2,-556 # ffffffffc02058e0 <commands+0x860>
ffffffffc0203b14:	17900593          	li	a1,377
ffffffffc0203b18:	00003517          	auipc	a0,0x3
ffffffffc0203b1c:	b5050513          	addi	a0,a0,-1200 # ffffffffc0206668 <default_pmm_manager+0x50>
ffffffffc0203b20:	eb6fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0203b24:	00003697          	auipc	a3,0x3
ffffffffc0203b28:	dd468693          	addi	a3,a3,-556 # ffffffffc02068f8 <default_pmm_manager+0x2e0>
ffffffffc0203b2c:	00002617          	auipc	a2,0x2
ffffffffc0203b30:	db460613          	addi	a2,a2,-588 # ffffffffc02058e0 <commands+0x860>
ffffffffc0203b34:	17700593          	li	a1,375
ffffffffc0203b38:	00003517          	auipc	a0,0x3
ffffffffc0203b3c:	b3050513          	addi	a0,a0,-1232 # ffffffffc0206668 <default_pmm_manager+0x50>
ffffffffc0203b40:	e96fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0203b44:	00003697          	auipc	a3,0x3
ffffffffc0203b48:	d9c68693          	addi	a3,a3,-612 # ffffffffc02068e0 <default_pmm_manager+0x2c8>
ffffffffc0203b4c:	00002617          	auipc	a2,0x2
ffffffffc0203b50:	d9460613          	addi	a2,a2,-620 # ffffffffc02058e0 <commands+0x860>
ffffffffc0203b54:	17600593          	li	a1,374
ffffffffc0203b58:	00003517          	auipc	a0,0x3
ffffffffc0203b5c:	b1050513          	addi	a0,a0,-1264 # ffffffffc0206668 <default_pmm_manager+0x50>
ffffffffc0203b60:	e76fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0203b64:	00003697          	auipc	a3,0x3
ffffffffc0203b68:	d6c68693          	addi	a3,a3,-660 # ffffffffc02068d0 <default_pmm_manager+0x2b8>
ffffffffc0203b6c:	00002617          	auipc	a2,0x2
ffffffffc0203b70:	d7460613          	addi	a2,a2,-652 # ffffffffc02058e0 <commands+0x860>
ffffffffc0203b74:	17500593          	li	a1,373
ffffffffc0203b78:	00003517          	auipc	a0,0x3
ffffffffc0203b7c:	af050513          	addi	a0,a0,-1296 # ffffffffc0206668 <default_pmm_manager+0x50>
ffffffffc0203b80:	e56fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0203b84:	00003697          	auipc	a3,0x3
ffffffffc0203b88:	d3c68693          	addi	a3,a3,-708 # ffffffffc02068c0 <default_pmm_manager+0x2a8>
ffffffffc0203b8c:	00002617          	auipc	a2,0x2
ffffffffc0203b90:	d5460613          	addi	a2,a2,-684 # ffffffffc02058e0 <commands+0x860>
ffffffffc0203b94:	17400593          	li	a1,372
ffffffffc0203b98:	00003517          	auipc	a0,0x3
ffffffffc0203b9c:	ad050513          	addi	a0,a0,-1328 # ffffffffc0206668 <default_pmm_manager+0x50>
ffffffffc0203ba0:	e36fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0203ba4:	00003697          	auipc	a3,0x3
ffffffffc0203ba8:	cec68693          	addi	a3,a3,-788 # ffffffffc0206890 <default_pmm_manager+0x278>
ffffffffc0203bac:	00002617          	auipc	a2,0x2
ffffffffc0203bb0:	d3460613          	addi	a2,a2,-716 # ffffffffc02058e0 <commands+0x860>
ffffffffc0203bb4:	17300593          	li	a1,371
ffffffffc0203bb8:	00003517          	auipc	a0,0x3
ffffffffc0203bbc:	ab050513          	addi	a0,a0,-1360 # ffffffffc0206668 <default_pmm_manager+0x50>
ffffffffc0203bc0:	e16fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0203bc4:	00003697          	auipc	a3,0x3
ffffffffc0203bc8:	c9468693          	addi	a3,a3,-876 # ffffffffc0206858 <default_pmm_manager+0x240>
ffffffffc0203bcc:	00002617          	auipc	a2,0x2
ffffffffc0203bd0:	d1460613          	addi	a2,a2,-748 # ffffffffc02058e0 <commands+0x860>
ffffffffc0203bd4:	17200593          	li	a1,370
ffffffffc0203bd8:	00003517          	auipc	a0,0x3
ffffffffc0203bdc:	a9050513          	addi	a0,a0,-1392 # ffffffffc0206668 <default_pmm_manager+0x50>
ffffffffc0203be0:	df6fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0203be4:	00003697          	auipc	a3,0x3
ffffffffc0203be8:	c4c68693          	addi	a3,a3,-948 # ffffffffc0206830 <default_pmm_manager+0x218>
ffffffffc0203bec:	00002617          	auipc	a2,0x2
ffffffffc0203bf0:	cf460613          	addi	a2,a2,-780 # ffffffffc02058e0 <commands+0x860>
ffffffffc0203bf4:	16f00593          	li	a1,367
ffffffffc0203bf8:	00003517          	auipc	a0,0x3
ffffffffc0203bfc:	a7050513          	addi	a0,a0,-1424 # ffffffffc0206668 <default_pmm_manager+0x50>
ffffffffc0203c00:	dd6fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203c04:	86da                	mv	a3,s6
ffffffffc0203c06:	00002617          	auipc	a2,0x2
ffffffffc0203c0a:	04260613          	addi	a2,a2,66 # ffffffffc0205c48 <commands+0xbc8>
ffffffffc0203c0e:	16e00593          	li	a1,366
ffffffffc0203c12:	00003517          	auipc	a0,0x3
ffffffffc0203c16:	a5650513          	addi	a0,a0,-1450 # ffffffffc0206668 <default_pmm_manager+0x50>
ffffffffc0203c1a:	dbcfc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    return KADDR(page2pa(page));
ffffffffc0203c1e:	86be                	mv	a3,a5
ffffffffc0203c20:	00002617          	auipc	a2,0x2
ffffffffc0203c24:	02860613          	addi	a2,a2,40 # ffffffffc0205c48 <commands+0xbc8>
ffffffffc0203c28:	06900593          	li	a1,105
ffffffffc0203c2c:	00002517          	auipc	a0,0x2
ffffffffc0203c30:	00c50513          	addi	a0,a0,12 # ffffffffc0205c38 <commands+0xbb8>
ffffffffc0203c34:	da2fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0203c38:	00003697          	auipc	a3,0x3
ffffffffc0203c3c:	d6868693          	addi	a3,a3,-664 # ffffffffc02069a0 <default_pmm_manager+0x388>
ffffffffc0203c40:	00002617          	auipc	a2,0x2
ffffffffc0203c44:	ca060613          	addi	a2,a2,-864 # ffffffffc02058e0 <commands+0x860>
ffffffffc0203c48:	18800593          	li	a1,392
ffffffffc0203c4c:	00003517          	auipc	a0,0x3
ffffffffc0203c50:	a1c50513          	addi	a0,a0,-1508 # ffffffffc0206668 <default_pmm_manager+0x50>
ffffffffc0203c54:	d82fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203c58:	00003697          	auipc	a3,0x3
ffffffffc0203c5c:	d0068693          	addi	a3,a3,-768 # ffffffffc0206958 <default_pmm_manager+0x340>
ffffffffc0203c60:	00002617          	auipc	a2,0x2
ffffffffc0203c64:	c8060613          	addi	a2,a2,-896 # ffffffffc02058e0 <commands+0x860>
ffffffffc0203c68:	18600593          	li	a1,390
ffffffffc0203c6c:	00003517          	auipc	a0,0x3
ffffffffc0203c70:	9fc50513          	addi	a0,a0,-1540 # ffffffffc0206668 <default_pmm_manager+0x50>
ffffffffc0203c74:	d62fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0203c78:	00003697          	auipc	a3,0x3
ffffffffc0203c7c:	d1068693          	addi	a3,a3,-752 # ffffffffc0206988 <default_pmm_manager+0x370>
ffffffffc0203c80:	00002617          	auipc	a2,0x2
ffffffffc0203c84:	c6060613          	addi	a2,a2,-928 # ffffffffc02058e0 <commands+0x860>
ffffffffc0203c88:	18500593          	li	a1,389
ffffffffc0203c8c:	00003517          	auipc	a0,0x3
ffffffffc0203c90:	9dc50513          	addi	a0,a0,-1572 # ffffffffc0206668 <default_pmm_manager+0x50>
ffffffffc0203c94:	d42fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0203c98:	00003697          	auipc	a3,0x3
ffffffffc0203c9c:	e7068693          	addi	a3,a3,-400 # ffffffffc0206b08 <default_pmm_manager+0x4f0>
ffffffffc0203ca0:	00002617          	auipc	a2,0x2
ffffffffc0203ca4:	c4060613          	addi	a2,a2,-960 # ffffffffc02058e0 <commands+0x860>
ffffffffc0203ca8:	1a800593          	li	a1,424
ffffffffc0203cac:	00003517          	auipc	a0,0x3
ffffffffc0203cb0:	9bc50513          	addi	a0,a0,-1604 # ffffffffc0206668 <default_pmm_manager+0x50>
ffffffffc0203cb4:	d22fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0203cb8:	00003697          	auipc	a3,0x3
ffffffffc0203cbc:	e1068693          	addi	a3,a3,-496 # ffffffffc0206ac8 <default_pmm_manager+0x4b0>
ffffffffc0203cc0:	00002617          	auipc	a2,0x2
ffffffffc0203cc4:	c2060613          	addi	a2,a2,-992 # ffffffffc02058e0 <commands+0x860>
ffffffffc0203cc8:	1a700593          	li	a1,423
ffffffffc0203ccc:	00003517          	auipc	a0,0x3
ffffffffc0203cd0:	99c50513          	addi	a0,a0,-1636 # ffffffffc0206668 <default_pmm_manager+0x50>
ffffffffc0203cd4:	d02fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0203cd8:	00003697          	auipc	a3,0x3
ffffffffc0203cdc:	dd868693          	addi	a3,a3,-552 # ffffffffc0206ab0 <default_pmm_manager+0x498>
ffffffffc0203ce0:	00002617          	auipc	a2,0x2
ffffffffc0203ce4:	c0060613          	addi	a2,a2,-1024 # ffffffffc02058e0 <commands+0x860>
ffffffffc0203ce8:	1a600593          	li	a1,422
ffffffffc0203cec:	00003517          	auipc	a0,0x3
ffffffffc0203cf0:	97c50513          	addi	a0,a0,-1668 # ffffffffc0206668 <default_pmm_manager+0x50>
ffffffffc0203cf4:	ce2fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0203cf8:	86be                	mv	a3,a5
ffffffffc0203cfa:	00002617          	auipc	a2,0x2
ffffffffc0203cfe:	f4e60613          	addi	a2,a2,-178 # ffffffffc0205c48 <commands+0xbc8>
ffffffffc0203d02:	16d00593          	li	a1,365
ffffffffc0203d06:	00003517          	auipc	a0,0x3
ffffffffc0203d0a:	96250513          	addi	a0,a0,-1694 # ffffffffc0206668 <default_pmm_manager+0x50>
ffffffffc0203d0e:	cc8fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203d12:	00002617          	auipc	a2,0x2
ffffffffc0203d16:	34e60613          	addi	a2,a2,846 # ffffffffc0206060 <commands+0xfe0>
ffffffffc0203d1a:	07f00593          	li	a1,127
ffffffffc0203d1e:	00003517          	auipc	a0,0x3
ffffffffc0203d22:	94a50513          	addi	a0,a0,-1718 # ffffffffc0206668 <default_pmm_manager+0x50>
ffffffffc0203d26:	cb0fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0203d2a:	00003697          	auipc	a3,0x3
ffffffffc0203d2e:	e0e68693          	addi	a3,a3,-498 # ffffffffc0206b38 <default_pmm_manager+0x520>
ffffffffc0203d32:	00002617          	auipc	a2,0x2
ffffffffc0203d36:	bae60613          	addi	a2,a2,-1106 # ffffffffc02058e0 <commands+0x860>
ffffffffc0203d3a:	1ac00593          	li	a1,428
ffffffffc0203d3e:	00003517          	auipc	a0,0x3
ffffffffc0203d42:	92a50513          	addi	a0,a0,-1750 # ffffffffc0206668 <default_pmm_manager+0x50>
ffffffffc0203d46:	c90fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0203d4a:	00003697          	auipc	a3,0x3
ffffffffc0203d4e:	c7e68693          	addi	a3,a3,-898 # ffffffffc02069c8 <default_pmm_manager+0x3b0>
ffffffffc0203d52:	00002617          	auipc	a2,0x2
ffffffffc0203d56:	b8e60613          	addi	a2,a2,-1138 # ffffffffc02058e0 <commands+0x860>
ffffffffc0203d5a:	1b800593          	li	a1,440
ffffffffc0203d5e:	00003517          	auipc	a0,0x3
ffffffffc0203d62:	90a50513          	addi	a0,a0,-1782 # ffffffffc0206668 <default_pmm_manager+0x50>
ffffffffc0203d66:	c70fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203d6a:	00003697          	auipc	a3,0x3
ffffffffc0203d6e:	aae68693          	addi	a3,a3,-1362 # ffffffffc0206818 <default_pmm_manager+0x200>
ffffffffc0203d72:	00002617          	auipc	a2,0x2
ffffffffc0203d76:	b6e60613          	addi	a2,a2,-1170 # ffffffffc02058e0 <commands+0x860>
ffffffffc0203d7a:	16b00593          	li	a1,363
ffffffffc0203d7e:	00003517          	auipc	a0,0x3
ffffffffc0203d82:	8ea50513          	addi	a0,a0,-1814 # ffffffffc0206668 <default_pmm_manager+0x50>
ffffffffc0203d86:	c50fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203d8a:	00003697          	auipc	a3,0x3
ffffffffc0203d8e:	a7668693          	addi	a3,a3,-1418 # ffffffffc0206800 <default_pmm_manager+0x1e8>
ffffffffc0203d92:	00002617          	auipc	a2,0x2
ffffffffc0203d96:	b4e60613          	addi	a2,a2,-1202 # ffffffffc02058e0 <commands+0x860>
ffffffffc0203d9a:	16a00593          	li	a1,362
ffffffffc0203d9e:	00003517          	auipc	a0,0x3
ffffffffc0203da2:	8ca50513          	addi	a0,a0,-1846 # ffffffffc0206668 <default_pmm_manager+0x50>
ffffffffc0203da6:	c30fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0203daa:	00003697          	auipc	a3,0x3
ffffffffc0203dae:	9ce68693          	addi	a3,a3,-1586 # ffffffffc0206778 <default_pmm_manager+0x160>
ffffffffc0203db2:	00002617          	auipc	a2,0x2
ffffffffc0203db6:	b2e60613          	addi	a2,a2,-1234 # ffffffffc02058e0 <commands+0x860>
ffffffffc0203dba:	16200593          	li	a1,354
ffffffffc0203dbe:	00003517          	auipc	a0,0x3
ffffffffc0203dc2:	8aa50513          	addi	a0,a0,-1878 # ffffffffc0206668 <default_pmm_manager+0x50>
ffffffffc0203dc6:	c10fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0203dca:	00003697          	auipc	a3,0x3
ffffffffc0203dce:	a0668693          	addi	a3,a3,-1530 # ffffffffc02067d0 <default_pmm_manager+0x1b8>
ffffffffc0203dd2:	00002617          	auipc	a2,0x2
ffffffffc0203dd6:	b0e60613          	addi	a2,a2,-1266 # ffffffffc02058e0 <commands+0x860>
ffffffffc0203dda:	16900593          	li	a1,361
ffffffffc0203dde:	00003517          	auipc	a0,0x3
ffffffffc0203de2:	88a50513          	addi	a0,a0,-1910 # ffffffffc0206668 <default_pmm_manager+0x50>
ffffffffc0203de6:	bf0fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0203dea:	00003697          	auipc	a3,0x3
ffffffffc0203dee:	9b668693          	addi	a3,a3,-1610 # ffffffffc02067a0 <default_pmm_manager+0x188>
ffffffffc0203df2:	00002617          	auipc	a2,0x2
ffffffffc0203df6:	aee60613          	addi	a2,a2,-1298 # ffffffffc02058e0 <commands+0x860>
ffffffffc0203dfa:	16600593          	li	a1,358
ffffffffc0203dfe:	00003517          	auipc	a0,0x3
ffffffffc0203e02:	86a50513          	addi	a0,a0,-1942 # ffffffffc0206668 <default_pmm_manager+0x50>
ffffffffc0203e06:	bd0fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203e0a:	00003697          	auipc	a3,0x3
ffffffffc0203e0e:	b4e68693          	addi	a3,a3,-1202 # ffffffffc0206958 <default_pmm_manager+0x340>
ffffffffc0203e12:	00002617          	auipc	a2,0x2
ffffffffc0203e16:	ace60613          	addi	a2,a2,-1330 # ffffffffc02058e0 <commands+0x860>
ffffffffc0203e1a:	18200593          	li	a1,386
ffffffffc0203e1e:	00003517          	auipc	a0,0x3
ffffffffc0203e22:	84a50513          	addi	a0,a0,-1974 # ffffffffc0206668 <default_pmm_manager+0x50>
ffffffffc0203e26:	bb0fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203e2a:	00003697          	auipc	a3,0x3
ffffffffc0203e2e:	9ee68693          	addi	a3,a3,-1554 # ffffffffc0206818 <default_pmm_manager+0x200>
ffffffffc0203e32:	00002617          	auipc	a2,0x2
ffffffffc0203e36:	aae60613          	addi	a2,a2,-1362 # ffffffffc02058e0 <commands+0x860>
ffffffffc0203e3a:	18100593          	li	a1,385
ffffffffc0203e3e:	00003517          	auipc	a0,0x3
ffffffffc0203e42:	82a50513          	addi	a0,a0,-2006 # ffffffffc0206668 <default_pmm_manager+0x50>
ffffffffc0203e46:	b90fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0203e4a:	00003697          	auipc	a3,0x3
ffffffffc0203e4e:	b2668693          	addi	a3,a3,-1242 # ffffffffc0206970 <default_pmm_manager+0x358>
ffffffffc0203e52:	00002617          	auipc	a2,0x2
ffffffffc0203e56:	a8e60613          	addi	a2,a2,-1394 # ffffffffc02058e0 <commands+0x860>
ffffffffc0203e5a:	17e00593          	li	a1,382
ffffffffc0203e5e:	00003517          	auipc	a0,0x3
ffffffffc0203e62:	80a50513          	addi	a0,a0,-2038 # ffffffffc0206668 <default_pmm_manager+0x50>
ffffffffc0203e66:	b70fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203e6a:	00003697          	auipc	a3,0x3
ffffffffc0203e6e:	d0668693          	addi	a3,a3,-762 # ffffffffc0206b70 <default_pmm_manager+0x558>
ffffffffc0203e72:	00002617          	auipc	a2,0x2
ffffffffc0203e76:	a6e60613          	addi	a2,a2,-1426 # ffffffffc02058e0 <commands+0x860>
ffffffffc0203e7a:	1af00593          	li	a1,431
ffffffffc0203e7e:	00002517          	auipc	a0,0x2
ffffffffc0203e82:	7ea50513          	addi	a0,a0,2026 # ffffffffc0206668 <default_pmm_manager+0x50>
ffffffffc0203e86:	b50fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0203e8a:	00003697          	auipc	a3,0x3
ffffffffc0203e8e:	b3e68693          	addi	a3,a3,-1218 # ffffffffc02069c8 <default_pmm_manager+0x3b0>
ffffffffc0203e92:	00002617          	auipc	a2,0x2
ffffffffc0203e96:	a4e60613          	addi	a2,a2,-1458 # ffffffffc02058e0 <commands+0x860>
ffffffffc0203e9a:	19000593          	li	a1,400
ffffffffc0203e9e:	00002517          	auipc	a0,0x2
ffffffffc0203ea2:	7ca50513          	addi	a0,a0,1994 # ffffffffc0206668 <default_pmm_manager+0x50>
ffffffffc0203ea6:	b30fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0203eaa:	00003697          	auipc	a3,0x3
ffffffffc0203eae:	bb668693          	addi	a3,a3,-1098 # ffffffffc0206a60 <default_pmm_manager+0x448>
ffffffffc0203eb2:	00002617          	auipc	a2,0x2
ffffffffc0203eb6:	a2e60613          	addi	a2,a2,-1490 # ffffffffc02058e0 <commands+0x860>
ffffffffc0203eba:	1a100593          	li	a1,417
ffffffffc0203ebe:	00002517          	auipc	a0,0x2
ffffffffc0203ec2:	7aa50513          	addi	a0,a0,1962 # ffffffffc0206668 <default_pmm_manager+0x50>
ffffffffc0203ec6:	b10fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0203eca:	00003697          	auipc	a3,0x3
ffffffffc0203ece:	85668693          	addi	a3,a3,-1962 # ffffffffc0206720 <default_pmm_manager+0x108>
ffffffffc0203ed2:	00002617          	auipc	a2,0x2
ffffffffc0203ed6:	a0e60613          	addi	a2,a2,-1522 # ffffffffc02058e0 <commands+0x860>
ffffffffc0203eda:	16000593          	li	a1,352
ffffffffc0203ede:	00002517          	auipc	a0,0x2
ffffffffc0203ee2:	78a50513          	addi	a0,a0,1930 # ffffffffc0206668 <default_pmm_manager+0x50>
ffffffffc0203ee6:	af0fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0203eea:	00002617          	auipc	a2,0x2
ffffffffc0203eee:	17660613          	addi	a2,a2,374 # ffffffffc0206060 <commands+0xfe0>
ffffffffc0203ef2:	0c300593          	li	a1,195
ffffffffc0203ef6:	00002517          	auipc	a0,0x2
ffffffffc0203efa:	77250513          	addi	a0,a0,1906 # ffffffffc0206668 <default_pmm_manager+0x50>
ffffffffc0203efe:	ad8fc0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc0203f02 <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203f02:	12058073          	sfence.vma	a1
}
ffffffffc0203f06:	8082                	ret

ffffffffc0203f08 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0203f08:	7179                	addi	sp,sp,-48
ffffffffc0203f0a:	e84a                	sd	s2,16(sp)
ffffffffc0203f0c:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0203f0e:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0203f10:	f022                	sd	s0,32(sp)
ffffffffc0203f12:	ec26                	sd	s1,24(sp)
ffffffffc0203f14:	e44e                	sd	s3,8(sp)
ffffffffc0203f16:	f406                	sd	ra,40(sp)
ffffffffc0203f18:	84ae                	mv	s1,a1
ffffffffc0203f1a:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0203f1c:	8e8ff0ef          	jal	ra,ffffffffc0203004 <alloc_pages>
ffffffffc0203f20:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0203f22:	cd19                	beqz	a0,ffffffffc0203f40 <pgdir_alloc_page+0x38>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0203f24:	85aa                	mv	a1,a0
ffffffffc0203f26:	86ce                	mv	a3,s3
ffffffffc0203f28:	8626                	mv	a2,s1
ffffffffc0203f2a:	854a                	mv	a0,s2
ffffffffc0203f2c:	c8eff0ef          	jal	ra,ffffffffc02033ba <page_insert>
ffffffffc0203f30:	ed39                	bnez	a0,ffffffffc0203f8e <pgdir_alloc_page+0x86>
        if (swap_init_ok) {
ffffffffc0203f32:	00012797          	auipc	a5,0x12
ffffffffc0203f36:	55e78793          	addi	a5,a5,1374 # ffffffffc0216490 <swap_init_ok>
ffffffffc0203f3a:	439c                	lw	a5,0(a5)
ffffffffc0203f3c:	2781                	sext.w	a5,a5
ffffffffc0203f3e:	eb89                	bnez	a5,ffffffffc0203f50 <pgdir_alloc_page+0x48>
}
ffffffffc0203f40:	8522                	mv	a0,s0
ffffffffc0203f42:	70a2                	ld	ra,40(sp)
ffffffffc0203f44:	7402                	ld	s0,32(sp)
ffffffffc0203f46:	64e2                	ld	s1,24(sp)
ffffffffc0203f48:	6942                	ld	s2,16(sp)
ffffffffc0203f4a:	69a2                	ld	s3,8(sp)
ffffffffc0203f4c:	6145                	addi	sp,sp,48
ffffffffc0203f4e:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0203f50:	00012797          	auipc	a5,0x12
ffffffffc0203f54:	58878793          	addi	a5,a5,1416 # ffffffffc02164d8 <check_mm_struct>
ffffffffc0203f58:	6388                	ld	a0,0(a5)
ffffffffc0203f5a:	4681                	li	a3,0
ffffffffc0203f5c:	8622                	mv	a2,s0
ffffffffc0203f5e:	85a6                	mv	a1,s1
ffffffffc0203f60:	ba1fd0ef          	jal	ra,ffffffffc0201b00 <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0203f64:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0203f66:	fc04                	sd	s1,56(s0)
            assert(page_ref(page) == 1);
ffffffffc0203f68:	4785                	li	a5,1
ffffffffc0203f6a:	fcf70be3          	beq	a4,a5,ffffffffc0203f40 <pgdir_alloc_page+0x38>
ffffffffc0203f6e:	00002697          	auipc	a3,0x2
ffffffffc0203f72:	70a68693          	addi	a3,a3,1802 # ffffffffc0206678 <default_pmm_manager+0x60>
ffffffffc0203f76:	00002617          	auipc	a2,0x2
ffffffffc0203f7a:	96a60613          	addi	a2,a2,-1686 # ffffffffc02058e0 <commands+0x860>
ffffffffc0203f7e:	14800593          	li	a1,328
ffffffffc0203f82:	00002517          	auipc	a0,0x2
ffffffffc0203f86:	6e650513          	addi	a0,a0,1766 # ffffffffc0206668 <default_pmm_manager+0x50>
ffffffffc0203f8a:	a4cfc0ef          	jal	ra,ffffffffc02001d6 <__panic>
            free_page(page);
ffffffffc0203f8e:	8522                	mv	a0,s0
ffffffffc0203f90:	4585                	li	a1,1
ffffffffc0203f92:	8faff0ef          	jal	ra,ffffffffc020308c <free_pages>
            return NULL;
ffffffffc0203f96:	4401                	li	s0,0
ffffffffc0203f98:	b765                	j	ffffffffc0203f40 <pgdir_alloc_page+0x38>

ffffffffc0203f9a <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0203f9a:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203f9c:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0203f9e:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203fa0:	d12fc0ef          	jal	ra,ffffffffc02004b2 <ide_device_valid>
ffffffffc0203fa4:	cd01                	beqz	a0,ffffffffc0203fbc <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203fa6:	4505                	li	a0,1
ffffffffc0203fa8:	d10fc0ef          	jal	ra,ffffffffc02004b8 <ide_device_size>
}
ffffffffc0203fac:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203fae:	810d                	srli	a0,a0,0x3
ffffffffc0203fb0:	00012797          	auipc	a5,0x12
ffffffffc0203fb4:	5aa7bc23          	sd	a0,1464(a5) # ffffffffc0216568 <max_swap_offset>
}
ffffffffc0203fb8:	0141                	addi	sp,sp,16
ffffffffc0203fba:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0203fbc:	00003617          	auipc	a2,0x3
ffffffffc0203fc0:	bfc60613          	addi	a2,a2,-1028 # ffffffffc0206bb8 <default_pmm_manager+0x5a0>
ffffffffc0203fc4:	45b5                	li	a1,13
ffffffffc0203fc6:	00003517          	auipc	a0,0x3
ffffffffc0203fca:	c1250513          	addi	a0,a0,-1006 # ffffffffc0206bd8 <default_pmm_manager+0x5c0>
ffffffffc0203fce:	a08fc0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc0203fd2 <swapfs_write>:
swapfs_read(swap_entry_t entry, struct Page *page) {
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
}

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0203fd2:	1141                	addi	sp,sp,-16
ffffffffc0203fd4:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203fd6:	00855793          	srli	a5,a0,0x8
ffffffffc0203fda:	cfb9                	beqz	a5,ffffffffc0204038 <swapfs_write+0x66>
ffffffffc0203fdc:	00012717          	auipc	a4,0x12
ffffffffc0203fe0:	58c70713          	addi	a4,a4,1420 # ffffffffc0216568 <max_swap_offset>
ffffffffc0203fe4:	6318                	ld	a4,0(a4)
ffffffffc0203fe6:	04e7f963          	bleu	a4,a5,ffffffffc0204038 <swapfs_write+0x66>
    return page - pages + nbase;
ffffffffc0203fea:	00012717          	auipc	a4,0x12
ffffffffc0203fee:	5fe70713          	addi	a4,a4,1534 # ffffffffc02165e8 <pages>
ffffffffc0203ff2:	6310                	ld	a2,0(a4)
ffffffffc0203ff4:	00003717          	auipc	a4,0x3
ffffffffc0203ff8:	22c70713          	addi	a4,a4,556 # ffffffffc0207220 <nbase>
    return KADDR(page2pa(page));
ffffffffc0203ffc:	00012697          	auipc	a3,0x12
ffffffffc0204000:	4ac68693          	addi	a3,a3,1196 # ffffffffc02164a8 <npage>
    return page - pages + nbase;
ffffffffc0204004:	40c58633          	sub	a2,a1,a2
ffffffffc0204008:	630c                	ld	a1,0(a4)
ffffffffc020400a:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc020400c:	577d                	li	a4,-1
ffffffffc020400e:	6294                	ld	a3,0(a3)
    return page - pages + nbase;
ffffffffc0204010:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc0204012:	8331                	srli	a4,a4,0xc
ffffffffc0204014:	8f71                	and	a4,a4,a2
ffffffffc0204016:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc020401a:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc020401c:	02d77a63          	bleu	a3,a4,ffffffffc0204050 <swapfs_write+0x7e>
ffffffffc0204020:	00012797          	auipc	a5,0x12
ffffffffc0204024:	5b878793          	addi	a5,a5,1464 # ffffffffc02165d8 <va_pa_offset>
ffffffffc0204028:	639c                	ld	a5,0(a5)
}
ffffffffc020402a:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc020402c:	46a1                	li	a3,8
ffffffffc020402e:	963e                	add	a2,a2,a5
ffffffffc0204030:	4505                	li	a0,1
}
ffffffffc0204032:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204034:	c8afc06f          	j	ffffffffc02004be <ide_write_secs>
ffffffffc0204038:	86aa                	mv	a3,a0
ffffffffc020403a:	00003617          	auipc	a2,0x3
ffffffffc020403e:	bb660613          	addi	a2,a2,-1098 # ffffffffc0206bf0 <default_pmm_manager+0x5d8>
ffffffffc0204042:	45e5                	li	a1,25
ffffffffc0204044:	00003517          	auipc	a0,0x3
ffffffffc0204048:	b9450513          	addi	a0,a0,-1132 # ffffffffc0206bd8 <default_pmm_manager+0x5c0>
ffffffffc020404c:	98afc0ef          	jal	ra,ffffffffc02001d6 <__panic>
ffffffffc0204050:	86b2                	mv	a3,a2
ffffffffc0204052:	06900593          	li	a1,105
ffffffffc0204056:	00002617          	auipc	a2,0x2
ffffffffc020405a:	bf260613          	addi	a2,a2,-1038 # ffffffffc0205c48 <commands+0xbc8>
ffffffffc020405e:	00002517          	auipc	a0,0x2
ffffffffc0204062:	bda50513          	addi	a0,a0,-1062 # ffffffffc0205c38 <commands+0xbb8>
ffffffffc0204066:	970fc0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc020406a <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc020406a:	8526                	mv	a0,s1
	jalr s0
ffffffffc020406c:	9402                	jalr	s0

	jal do_exit
ffffffffc020406e:	5c2000ef          	jal	ra,ffffffffc0204630 <do_exit>

ffffffffc0204072 <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0204072:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0204076:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc020407a:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc020407c:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc020407e:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0204082:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0204086:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc020408a:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc020408e:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0204092:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0204096:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc020409a:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc020409e:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc02040a2:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc02040a6:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc02040aa:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc02040ae:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc02040b0:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc02040b2:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc02040b6:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc02040ba:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc02040be:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc02040c2:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc02040c6:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc02040ca:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc02040ce:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc02040d2:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc02040d6:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc02040da:	8082                	ret

ffffffffc02040dc <alloc_proc>:
//     list_entry_t hash_link;                     // Process hash list
// };

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc02040dc:	1141                	addi	sp,sp,-16
    //cprintf("alloc_proc begin!\n");
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));// 分配空间
ffffffffc02040de:	0e800513          	li	a0,232
alloc_proc(void) {
ffffffffc02040e2:	e022                	sd	s0,0(sp)
ffffffffc02040e4:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));// 分配空间
ffffffffc02040e6:	dedfd0ef          	jal	ra,ffffffffc0201ed2 <kmalloc>
ffffffffc02040ea:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc02040ec:	c529                	beqz	a0,ffffffffc0204136 <alloc_proc+0x5a>
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */
        // 初始化进程状态为 PROC_UNINIT，设置进程为“初始”态
        proc->state = PROC_UNINIT;
ffffffffc02040ee:	57fd                	li	a5,-1
ffffffffc02040f0:	1782                	slli	a5,a5,0x20
ffffffffc02040f2:	e11c                	sd	a5,0(a0)
        // 初始化父进程指针为 NULL
        proc->parent = NULL;
        // 初始化内存管理结构为 NULL
        proc->mm = NULL;
        // 初始化上下文结构
        memset(&proc->context, 0, sizeof(struct context));
ffffffffc02040f4:	07000613          	li	a2,112
ffffffffc02040f8:	4581                	li	a1,0
        proc->runs = 0;
ffffffffc02040fa:	00052423          	sw	zero,8(a0)
        proc->kstack = 0;
ffffffffc02040fe:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;
ffffffffc0204102:	00052c23          	sw	zero,24(a0)
        proc->parent = NULL;
ffffffffc0204106:	02053023          	sd	zero,32(a0)
        proc->mm = NULL;
ffffffffc020410a:	02053423          	sd	zero,40(a0)
        memset(&proc->context, 0, sizeof(struct context));
ffffffffc020410e:	03050513          	addi	a0,a0,48
ffffffffc0204112:	1af000ef          	jal	ra,ffffffffc0204ac0 <memset>
        // 初始化中断帧指针为 NULL
        proc->tf = NULL;
        // 初始化 CR3 寄存器值为 boot_cr3?
        proc->cr3 = boot_cr3;
ffffffffc0204116:	00012797          	auipc	a5,0x12
ffffffffc020411a:	4ca78793          	addi	a5,a5,1226 # ffffffffc02165e0 <boot_cr3>
ffffffffc020411e:	639c                	ld	a5,0(a5)
        proc->tf = NULL;
ffffffffc0204120:	0a043023          	sd	zero,160(s0)
        // 初始化进程标志位为 0
        proc->flags = 0;
ffffffffc0204124:	0a042823          	sw	zero,176(s0)
        proc->cr3 = boot_cr3;
ffffffffc0204128:	f45c                	sd	a5,168(s0)
        // 初始化进程名字为空字符串，set_proc_name中以实现
        memset(proc->name, 0, PROC_NAME_LEN);
ffffffffc020412a:	463d                	li	a2,15
ffffffffc020412c:	4581                	li	a1,0
ffffffffc020412e:	0b440513          	addi	a0,s0,180
ffffffffc0204132:	18f000ef          	jal	ra,ffffffffc0204ac0 <memset>
    }
    return proc;
}
ffffffffc0204136:	8522                	mv	a0,s0
ffffffffc0204138:	60a2                	ld	ra,8(sp)
ffffffffc020413a:	6402                	ld	s0,0(sp)
ffffffffc020413c:	0141                	addi	sp,sp,16
ffffffffc020413e:	8082                	ret

ffffffffc0204140 <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);// 恢复当前进程的上下文
ffffffffc0204140:	00012797          	auipc	a5,0x12
ffffffffc0204144:	37078793          	addi	a5,a5,880 # ffffffffc02164b0 <current>
ffffffffc0204148:	639c                	ld	a5,0(a5)
ffffffffc020414a:	73c8                	ld	a0,160(a5)
ffffffffc020414c:	a29fc06f          	j	ffffffffc0200b74 <forkrets>

ffffffffc0204150 <set_proc_name>:
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204150:	1101                	addi	sp,sp,-32
ffffffffc0204152:	e822                	sd	s0,16(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204154:	0b450413          	addi	s0,a0,180
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204158:	e426                	sd	s1,8(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020415a:	4641                	li	a2,16
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc020415c:	84ae                	mv	s1,a1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020415e:	8522                	mv	a0,s0
ffffffffc0204160:	4581                	li	a1,0
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204162:	ec06                	sd	ra,24(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204164:	15d000ef          	jal	ra,ffffffffc0204ac0 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204168:	8522                	mv	a0,s0
}
ffffffffc020416a:	6442                	ld	s0,16(sp)
ffffffffc020416c:	60e2                	ld	ra,24(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc020416e:	85a6                	mv	a1,s1
}
ffffffffc0204170:	64a2                	ld	s1,8(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204172:	463d                	li	a2,15
}
ffffffffc0204174:	6105                	addi	sp,sp,32
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204176:	15d0006f          	j	ffffffffc0204ad2 <memcpy>

ffffffffc020417a <get_proc_name>:
get_proc_name(struct proc_struct *proc) {
ffffffffc020417a:	1101                	addi	sp,sp,-32
ffffffffc020417c:	e822                	sd	s0,16(sp)
    memset(name, 0, sizeof(name));
ffffffffc020417e:	00012417          	auipc	s0,0x12
ffffffffc0204182:	2e240413          	addi	s0,s0,738 # ffffffffc0216460 <name.1565>
get_proc_name(struct proc_struct *proc) {
ffffffffc0204186:	e426                	sd	s1,8(sp)
    memset(name, 0, sizeof(name));
ffffffffc0204188:	4641                	li	a2,16
get_proc_name(struct proc_struct *proc) {
ffffffffc020418a:	84aa                	mv	s1,a0
    memset(name, 0, sizeof(name));
ffffffffc020418c:	4581                	li	a1,0
ffffffffc020418e:	8522                	mv	a0,s0
get_proc_name(struct proc_struct *proc) {
ffffffffc0204190:	ec06                	sd	ra,24(sp)
    memset(name, 0, sizeof(name));
ffffffffc0204192:	12f000ef          	jal	ra,ffffffffc0204ac0 <memset>
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc0204196:	8522                	mv	a0,s0
}
ffffffffc0204198:	6442                	ld	s0,16(sp)
ffffffffc020419a:	60e2                	ld	ra,24(sp)
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc020419c:	0b448593          	addi	a1,s1,180
}
ffffffffc02041a0:	64a2                	ld	s1,8(sp)
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc02041a2:	463d                	li	a2,15
}
ffffffffc02041a4:	6105                	addi	sp,sp,32
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc02041a6:	12d0006f          	j	ffffffffc0204ad2 <memcpy>

ffffffffc02041aa <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc02041aa:	00012797          	auipc	a5,0x12
ffffffffc02041ae:	30678793          	addi	a5,a5,774 # ffffffffc02164b0 <current>
ffffffffc02041b2:	639c                	ld	a5,0(a5)
init_main(void *arg) {
ffffffffc02041b4:	1101                	addi	sp,sp,-32
ffffffffc02041b6:	e426                	sd	s1,8(sp)
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc02041b8:	43c4                	lw	s1,4(a5)
init_main(void *arg) {
ffffffffc02041ba:	e822                	sd	s0,16(sp)
ffffffffc02041bc:	842a                	mv	s0,a0
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc02041be:	853e                	mv	a0,a5
init_main(void *arg) {
ffffffffc02041c0:	ec06                	sd	ra,24(sp)
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc02041c2:	fb9ff0ef          	jal	ra,ffffffffc020417a <get_proc_name>
ffffffffc02041c6:	862a                	mv	a2,a0
ffffffffc02041c8:	85a6                	mv	a1,s1
ffffffffc02041ca:	00003517          	auipc	a0,0x3
ffffffffc02041ce:	b0650513          	addi	a0,a0,-1274 # ffffffffc0206cd0 <default_pmm_manager+0x6b8>
ffffffffc02041d2:	efffb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("To U: \"%s\".\n", (const char *)arg);
ffffffffc02041d6:	85a2                	mv	a1,s0
ffffffffc02041d8:	00003517          	auipc	a0,0x3
ffffffffc02041dc:	b2050513          	addi	a0,a0,-1248 # ffffffffc0206cf8 <default_pmm_manager+0x6e0>
ffffffffc02041e0:	ef1fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
ffffffffc02041e4:	00003517          	auipc	a0,0x3
ffffffffc02041e8:	b2450513          	addi	a0,a0,-1244 # ffffffffc0206d08 <default_pmm_manager+0x6f0>
ffffffffc02041ec:	ee5fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    return 0;
}
ffffffffc02041f0:	60e2                	ld	ra,24(sp)
ffffffffc02041f2:	6442                	ld	s0,16(sp)
ffffffffc02041f4:	64a2                	ld	s1,8(sp)
ffffffffc02041f6:	4501                	li	a0,0
ffffffffc02041f8:	6105                	addi	sp,sp,32
ffffffffc02041fa:	8082                	ret

ffffffffc02041fc <proc_run>:
void proc_run(struct proc_struct *proc) {
ffffffffc02041fc:	1101                	addi	sp,sp,-32
    if (proc != current) {
ffffffffc02041fe:	00012797          	auipc	a5,0x12
ffffffffc0204202:	2b278793          	addi	a5,a5,690 # ffffffffc02164b0 <current>
void proc_run(struct proc_struct *proc) {
ffffffffc0204206:	e426                	sd	s1,8(sp)
    if (proc != current) {
ffffffffc0204208:	6384                	ld	s1,0(a5)
void proc_run(struct proc_struct *proc) {
ffffffffc020420a:	ec06                	sd	ra,24(sp)
ffffffffc020420c:	e822                	sd	s0,16(sp)
ffffffffc020420e:	e04a                	sd	s2,0(sp)
    if (proc != current) {
ffffffffc0204210:	02a48c63          	beq	s1,a0,ffffffffc0204248 <proc_run+0x4c>
ffffffffc0204214:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204216:	100027f3          	csrr	a5,sstatus
ffffffffc020421a:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020421c:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020421e:	e3b1                	bnez	a5,ffffffffc0204262 <proc_run+0x66>
            lcr3(next->cr3);
ffffffffc0204220:	745c                	ld	a5,168(s0)
            current = proc;
ffffffffc0204222:	00012717          	auipc	a4,0x12
ffffffffc0204226:	28873723          	sd	s0,654(a4) # ffffffffc02164b0 <current>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned int cr3) {
    write_csr(sptbr, SATP32_MODE | (cr3 >> RISCV_PGSHIFT));
ffffffffc020422a:	80000737          	lui	a4,0x80000
ffffffffc020422e:	00c7d79b          	srliw	a5,a5,0xc
ffffffffc0204232:	8fd9                	or	a5,a5,a4
ffffffffc0204234:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(next->context));
ffffffffc0204238:	03040593          	addi	a1,s0,48
ffffffffc020423c:	03048513          	addi	a0,s1,48
ffffffffc0204240:	e33ff0ef          	jal	ra,ffffffffc0204072 <switch_to>
    if (flag) {
ffffffffc0204244:	00091863          	bnez	s2,ffffffffc0204254 <proc_run+0x58>
}
ffffffffc0204248:	60e2                	ld	ra,24(sp)
ffffffffc020424a:	6442                	ld	s0,16(sp)
ffffffffc020424c:	64a2                	ld	s1,8(sp)
ffffffffc020424e:	6902                	ld	s2,0(sp)
ffffffffc0204250:	6105                	addi	sp,sp,32
ffffffffc0204252:	8082                	ret
ffffffffc0204254:	6442                	ld	s0,16(sp)
ffffffffc0204256:	60e2                	ld	ra,24(sp)
ffffffffc0204258:	64a2                	ld	s1,8(sp)
ffffffffc020425a:	6902                	ld	s2,0(sp)
ffffffffc020425c:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020425e:	b52fc06f          	j	ffffffffc02005b0 <intr_enable>
        intr_disable();
ffffffffc0204262:	b54fc0ef          	jal	ra,ffffffffc02005b6 <intr_disable>
        return 1;
ffffffffc0204266:	4905                	li	s2,1
ffffffffc0204268:	bf65                	j	ffffffffc0204220 <proc_run+0x24>

ffffffffc020426a <find_proc>:
    if (0 < pid && pid < MAX_PID) {
ffffffffc020426a:	0005071b          	sext.w	a4,a0
ffffffffc020426e:	6789                	lui	a5,0x2
ffffffffc0204270:	fff7069b          	addiw	a3,a4,-1
ffffffffc0204274:	17f9                	addi	a5,a5,-2
ffffffffc0204276:	04d7e063          	bltu	a5,a3,ffffffffc02042b6 <find_proc+0x4c>
find_proc(int pid) {// 哈希查找
ffffffffc020427a:	1141                	addi	sp,sp,-16
ffffffffc020427c:	e022                	sd	s0,0(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc020427e:	45a9                	li	a1,10
ffffffffc0204280:	842a                	mv	s0,a0
ffffffffc0204282:	853a                	mv	a0,a4
find_proc(int pid) {// 哈希查找
ffffffffc0204284:	e406                	sd	ra,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204286:	48d000ef          	jal	ra,ffffffffc0204f12 <hash32>
ffffffffc020428a:	02051693          	slli	a3,a0,0x20
ffffffffc020428e:	82f1                	srli	a3,a3,0x1c
ffffffffc0204290:	0000e517          	auipc	a0,0xe
ffffffffc0204294:	1d050513          	addi	a0,a0,464 # ffffffffc0212460 <hash_list>
ffffffffc0204298:	96aa                	add	a3,a3,a0
ffffffffc020429a:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc020429c:	a029                	j	ffffffffc02042a6 <find_proc+0x3c>
            if (proc->pid == pid) {
ffffffffc020429e:	f2c7a703          	lw	a4,-212(a5) # 1f2c <BASE_ADDRESS-0xffffffffc01fe0d4>
ffffffffc02042a2:	00870c63          	beq	a4,s0,ffffffffc02042ba <find_proc+0x50>
    return listelm->next;
ffffffffc02042a6:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc02042a8:	fef69be3          	bne	a3,a5,ffffffffc020429e <find_proc+0x34>
}
ffffffffc02042ac:	60a2                	ld	ra,8(sp)
ffffffffc02042ae:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc02042b0:	4501                	li	a0,0
}
ffffffffc02042b2:	0141                	addi	sp,sp,16
ffffffffc02042b4:	8082                	ret
    return NULL;
ffffffffc02042b6:	4501                	li	a0,0
}
ffffffffc02042b8:	8082                	ret
ffffffffc02042ba:	60a2                	ld	ra,8(sp)
ffffffffc02042bc:	6402                	ld	s0,0(sp)
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc02042be:	f2878513          	addi	a0,a5,-216
}
ffffffffc02042c2:	0141                	addi	sp,sp,16
ffffffffc02042c4:	8082                	ret

ffffffffc02042c6 <do_fork>:
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc02042c6:	7179                	addi	sp,sp,-48
    cprintf("THIS MY: do_fork begin! \n");
ffffffffc02042c8:	00003517          	auipc	a0,0x3
ffffffffc02042cc:	97850513          	addi	a0,a0,-1672 # ffffffffc0206c40 <default_pmm_manager+0x628>
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc02042d0:	ec26                	sd	s1,24(sp)
ffffffffc02042d2:	e84a                	sd	s2,16(sp)
ffffffffc02042d4:	e44e                	sd	s3,8(sp)
ffffffffc02042d6:	f406                	sd	ra,40(sp)
ffffffffc02042d8:	f022                	sd	s0,32(sp)
    if (nr_process >= MAX_PROCESS) {// 进程数达到最大
ffffffffc02042da:	00012917          	auipc	s2,0x12
ffffffffc02042de:	1ee90913          	addi	s2,s2,494 # ffffffffc02164c8 <nr_process>
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc02042e2:	89ae                	mv	s3,a1
ffffffffc02042e4:	84b2                	mv	s1,a2
    cprintf("THIS MY: do_fork begin! \n");
ffffffffc02042e6:	debfb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    if (nr_process >= MAX_PROCESS) {// 进程数达到最大
ffffffffc02042ea:	00092703          	lw	a4,0(s2)
ffffffffc02042ee:	6785                	lui	a5,0x1
ffffffffc02042f0:	26f75c63          	ble	a5,a4,ffffffffc0204568 <do_fork+0x2a2>
    if ((proc = alloc_proc()) == NULL) {
ffffffffc02042f4:	de9ff0ef          	jal	ra,ffffffffc02040dc <alloc_proc>
ffffffffc02042f8:	842a                	mv	s0,a0
ffffffffc02042fa:	26050263          	beqz	a0,ffffffffc020455e <do_fork+0x298>
    struct Page *page = alloc_pages(KSTACKPAGE);// 分配内存页作为内核栈
ffffffffc02042fe:	4509                	li	a0,2
ffffffffc0204300:	d05fe0ef          	jal	ra,ffffffffc0203004 <alloc_pages>
    if (page != NULL) {
ffffffffc0204304:	20050963          	beqz	a0,ffffffffc0204516 <do_fork+0x250>
    return page - pages + nbase;
ffffffffc0204308:	00012797          	auipc	a5,0x12
ffffffffc020430c:	2e078793          	addi	a5,a5,736 # ffffffffc02165e8 <pages>
ffffffffc0204310:	6394                	ld	a3,0(a5)
ffffffffc0204312:	00003797          	auipc	a5,0x3
ffffffffc0204316:	f0e78793          	addi	a5,a5,-242 # ffffffffc0207220 <nbase>
    return KADDR(page2pa(page));
ffffffffc020431a:	00012717          	auipc	a4,0x12
ffffffffc020431e:	18e70713          	addi	a4,a4,398 # ffffffffc02164a8 <npage>
    return page - pages + nbase;
ffffffffc0204322:	40d506b3          	sub	a3,a0,a3
ffffffffc0204326:	6388                	ld	a0,0(a5)
ffffffffc0204328:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc020432a:	57fd                	li	a5,-1
ffffffffc020432c:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc020432e:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc0204330:	83b1                	srli	a5,a5,0xc
ffffffffc0204332:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204334:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204336:	24e7fb63          	bleu	a4,a5,ffffffffc020458c <do_fork+0x2c6>
    assert(current->mm == NULL);
ffffffffc020433a:	00012797          	auipc	a5,0x12
ffffffffc020433e:	17678793          	addi	a5,a5,374 # ffffffffc02164b0 <current>
ffffffffc0204342:	639c                	ld	a5,0(a5)
ffffffffc0204344:	00012717          	auipc	a4,0x12
ffffffffc0204348:	29470713          	addi	a4,a4,660 # ffffffffc02165d8 <va_pa_offset>
ffffffffc020434c:	6318                	ld	a4,0(a4)
ffffffffc020434e:	779c                	ld	a5,40(a5)
ffffffffc0204350:	96ba                	add	a3,a3,a4
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0204352:	e814                	sd	a3,16(s0)
    assert(current->mm == NULL);
ffffffffc0204354:	20079c63          	bnez	a5,ffffffffc020456c <do_fork+0x2a6>
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));// 指向新进程的tf，被放置在内核栈的顶部
ffffffffc0204358:	6789                	lui	a5,0x2
ffffffffc020435a:	ee078793          	addi	a5,a5,-288 # 1ee0 <BASE_ADDRESS-0xffffffffc01fe120>
ffffffffc020435e:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;// 传递
ffffffffc0204360:	8626                	mv	a2,s1
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));// 指向新进程的tf，被放置在内核栈的顶部
ffffffffc0204362:	f054                	sd	a3,160(s0)
    *(proc->tf) = *tf;// 传递
ffffffffc0204364:	87b6                	mv	a5,a3
ffffffffc0204366:	12048893          	addi	a7,s1,288
ffffffffc020436a:	00063803          	ld	a6,0(a2)
ffffffffc020436e:	6608                	ld	a0,8(a2)
ffffffffc0204370:	6a0c                	ld	a1,16(a2)
ffffffffc0204372:	6e18                	ld	a4,24(a2)
ffffffffc0204374:	0107b023          	sd	a6,0(a5)
ffffffffc0204378:	e788                	sd	a0,8(a5)
ffffffffc020437a:	eb8c                	sd	a1,16(a5)
ffffffffc020437c:	ef98                	sd	a4,24(a5)
ffffffffc020437e:	02060613          	addi	a2,a2,32
ffffffffc0204382:	02078793          	addi	a5,a5,32
ffffffffc0204386:	ff1612e3          	bne	a2,a7,ffffffffc020436a <do_fork+0xa4>
    proc->tf->gpr.a0 = 0;// 子进程
ffffffffc020438a:	0406b823          	sd	zero,80(a3)
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;// 是否使用esp，子进程栈顶
ffffffffc020438e:	12098563          	beqz	s3,ffffffffc02044b8 <do_fork+0x1f2>
ffffffffc0204392:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;// 返回用户态
ffffffffc0204396:	00000797          	auipc	a5,0x0
ffffffffc020439a:	daa78793          	addi	a5,a5,-598 # ffffffffc0204140 <forkret>
ffffffffc020439e:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc02043a0:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02043a2:	100027f3          	csrr	a5,sstatus
ffffffffc02043a6:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02043a8:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02043aa:	12079663          	bnez	a5,ffffffffc02044d6 <do_fork+0x210>
    if (++ last_pid >= MAX_PID) {
ffffffffc02043ae:	00007797          	auipc	a5,0x7
ffffffffc02043b2:	caa78793          	addi	a5,a5,-854 # ffffffffc020b058 <last_pid.1575>
ffffffffc02043b6:	439c                	lw	a5,0(a5)
ffffffffc02043b8:	6709                	lui	a4,0x2
ffffffffc02043ba:	0017851b          	addiw	a0,a5,1
ffffffffc02043be:	00007697          	auipc	a3,0x7
ffffffffc02043c2:	c8a6ad23          	sw	a0,-870(a3) # ffffffffc020b058 <last_pid.1575>
ffffffffc02043c6:	12e55963          	ble	a4,a0,ffffffffc02044f8 <do_fork+0x232>
    if (last_pid >= next_safe) {
ffffffffc02043ca:	00007797          	auipc	a5,0x7
ffffffffc02043ce:	c9278793          	addi	a5,a5,-878 # ffffffffc020b05c <next_safe.1574>
ffffffffc02043d2:	439c                	lw	a5,0(a5)
ffffffffc02043d4:	00012497          	auipc	s1,0x12
ffffffffc02043d8:	21c48493          	addi	s1,s1,540 # ffffffffc02165f0 <proc_list>
ffffffffc02043dc:	06f54063          	blt	a0,a5,ffffffffc020443c <do_fork+0x176>
        next_safe = MAX_PID;
ffffffffc02043e0:	6789                	lui	a5,0x2
ffffffffc02043e2:	00007717          	auipc	a4,0x7
ffffffffc02043e6:	c6f72d23          	sw	a5,-902(a4) # ffffffffc020b05c <next_safe.1574>
ffffffffc02043ea:	4581                	li	a1,0
ffffffffc02043ec:	87aa                	mv	a5,a0
ffffffffc02043ee:	00012497          	auipc	s1,0x12
ffffffffc02043f2:	20248493          	addi	s1,s1,514 # ffffffffc02165f0 <proc_list>
    repeat:
ffffffffc02043f6:	6889                	lui	a7,0x2
ffffffffc02043f8:	882e                	mv	a6,a1
ffffffffc02043fa:	6609                	lui	a2,0x2
        le = list;
ffffffffc02043fc:	00012697          	auipc	a3,0x12
ffffffffc0204400:	1f468693          	addi	a3,a3,500 # ffffffffc02165f0 <proc_list>
ffffffffc0204404:	6694                	ld	a3,8(a3)
        while ((le = list_next(le)) != list) {
ffffffffc0204406:	00968f63          	beq	a3,s1,ffffffffc0204424 <do_fork+0x15e>
            if (proc->pid == last_pid) {
ffffffffc020440a:	f3c6a703          	lw	a4,-196(a3)
ffffffffc020440e:	0ae78063          	beq	a5,a4,ffffffffc02044ae <do_fork+0x1e8>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc0204412:	fee7d9e3          	ble	a4,a5,ffffffffc0204404 <do_fork+0x13e>
ffffffffc0204416:	fec757e3          	ble	a2,a4,ffffffffc0204404 <do_fork+0x13e>
ffffffffc020441a:	6694                	ld	a3,8(a3)
ffffffffc020441c:	863a                	mv	a2,a4
ffffffffc020441e:	4805                	li	a6,1
        while ((le = list_next(le)) != list) {
ffffffffc0204420:	fe9695e3          	bne	a3,s1,ffffffffc020440a <do_fork+0x144>
ffffffffc0204424:	c591                	beqz	a1,ffffffffc0204430 <do_fork+0x16a>
ffffffffc0204426:	00007717          	auipc	a4,0x7
ffffffffc020442a:	c2f72923          	sw	a5,-974(a4) # ffffffffc020b058 <last_pid.1575>
ffffffffc020442e:	853e                	mv	a0,a5
ffffffffc0204430:	00080663          	beqz	a6,ffffffffc020443c <do_fork+0x176>
ffffffffc0204434:	00007797          	auipc	a5,0x7
ffffffffc0204438:	c2c7a423          	sw	a2,-984(a5) # ffffffffc020b05c <next_safe.1574>
        proc->pid = get_pid();
ffffffffc020443c:	c048                	sw	a0,4(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc020443e:	45a9                	li	a1,10
ffffffffc0204440:	2501                	sext.w	a0,a0
ffffffffc0204442:	2d1000ef          	jal	ra,ffffffffc0204f12 <hash32>
ffffffffc0204446:	1502                	slli	a0,a0,0x20
ffffffffc0204448:	0000e797          	auipc	a5,0xe
ffffffffc020444c:	01878793          	addi	a5,a5,24 # ffffffffc0212460 <hash_list>
ffffffffc0204450:	8171                	srli	a0,a0,0x1c
ffffffffc0204452:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc0204454:	6510                	ld	a2,8(a0)
ffffffffc0204456:	0d840793          	addi	a5,s0,216
ffffffffc020445a:	6494                	ld	a3,8(s1)
        nr_process ++;
ffffffffc020445c:	00092703          	lw	a4,0(s2)
    prev->next = next->prev = elm;
ffffffffc0204460:	e21c                	sd	a5,0(a2)
ffffffffc0204462:	e51c                	sd	a5,8(a0)
    elm->next = next;
ffffffffc0204464:	f070                	sd	a2,224(s0)
        list_add(&proc_list, &(proc->list_link));
ffffffffc0204466:	0c840793          	addi	a5,s0,200
    elm->prev = prev;
ffffffffc020446a:	ec68                	sd	a0,216(s0)
    prev->next = next->prev = elm;
ffffffffc020446c:	e29c                	sd	a5,0(a3)
        nr_process ++;
ffffffffc020446e:	2705                	addiw	a4,a4,1
ffffffffc0204470:	00012617          	auipc	a2,0x12
ffffffffc0204474:	18f63423          	sd	a5,392(a2) # ffffffffc02165f8 <proc_list+0x8>
    elm->next = next;
ffffffffc0204478:	e874                	sd	a3,208(s0)
    elm->prev = prev;
ffffffffc020447a:	e464                	sd	s1,200(s0)
ffffffffc020447c:	00012797          	auipc	a5,0x12
ffffffffc0204480:	04e7a623          	sw	a4,76(a5) # ffffffffc02164c8 <nr_process>
    if (flag) {
ffffffffc0204484:	08099163          	bnez	s3,ffffffffc0204506 <do_fork+0x240>
    wakeup_proc(proc);// PROC_RUNNABLE
ffffffffc0204488:	8522                	mv	a0,s0
ffffffffc020448a:	4aa000ef          	jal	ra,ffffffffc0204934 <wakeup_proc>
    cprintf("THIS MY: do_fork proc create over thread: %d! isNULL:%d \n", proc->pid, proc == NULL);
ffffffffc020448e:	404c                	lw	a1,4(s0)
ffffffffc0204490:	4601                	li	a2,0
ffffffffc0204492:	00002517          	auipc	a0,0x2
ffffffffc0204496:	7fe50513          	addi	a0,a0,2046 # ffffffffc0206c90 <default_pmm_manager+0x678>
ffffffffc020449a:	c37fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    ret = proc->pid;
ffffffffc020449e:	4048                	lw	a0,4(s0)
}
ffffffffc02044a0:	70a2                	ld	ra,40(sp)
ffffffffc02044a2:	7402                	ld	s0,32(sp)
ffffffffc02044a4:	64e2                	ld	s1,24(sp)
ffffffffc02044a6:	6942                	ld	s2,16(sp)
ffffffffc02044a8:	69a2                	ld	s3,8(sp)
ffffffffc02044aa:	6145                	addi	sp,sp,48
ffffffffc02044ac:	8082                	ret
                if (++ last_pid >= next_safe) {
ffffffffc02044ae:	2785                	addiw	a5,a5,1
ffffffffc02044b0:	04c7de63          	ble	a2,a5,ffffffffc020450c <do_fork+0x246>
ffffffffc02044b4:	4585                	li	a1,1
ffffffffc02044b6:	b7b9                	j	ffffffffc0204404 <do_fork+0x13e>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;// 是否使用esp，子进程栈顶
ffffffffc02044b8:	89b6                	mv	s3,a3
ffffffffc02044ba:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;// 返回用户态
ffffffffc02044be:	00000797          	auipc	a5,0x0
ffffffffc02044c2:	c8278793          	addi	a5,a5,-894 # ffffffffc0204140 <forkret>
ffffffffc02044c6:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc02044c8:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02044ca:	100027f3          	csrr	a5,sstatus
ffffffffc02044ce:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02044d0:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02044d2:	ec078ee3          	beqz	a5,ffffffffc02043ae <do_fork+0xe8>
        intr_disable();
ffffffffc02044d6:	8e0fc0ef          	jal	ra,ffffffffc02005b6 <intr_disable>
    if (++ last_pid >= MAX_PID) {
ffffffffc02044da:	00007797          	auipc	a5,0x7
ffffffffc02044de:	b7e78793          	addi	a5,a5,-1154 # ffffffffc020b058 <last_pid.1575>
ffffffffc02044e2:	439c                	lw	a5,0(a5)
ffffffffc02044e4:	6709                	lui	a4,0x2
        return 1;
ffffffffc02044e6:	4985                	li	s3,1
ffffffffc02044e8:	0017851b          	addiw	a0,a5,1
ffffffffc02044ec:	00007697          	auipc	a3,0x7
ffffffffc02044f0:	b6a6a623          	sw	a0,-1172(a3) # ffffffffc020b058 <last_pid.1575>
ffffffffc02044f4:	ece54be3          	blt	a0,a4,ffffffffc02043ca <do_fork+0x104>
        last_pid = 1;
ffffffffc02044f8:	4785                	li	a5,1
ffffffffc02044fa:	00007717          	auipc	a4,0x7
ffffffffc02044fe:	b4f72f23          	sw	a5,-1186(a4) # ffffffffc020b058 <last_pid.1575>
ffffffffc0204502:	4505                	li	a0,1
ffffffffc0204504:	bdf1                	j	ffffffffc02043e0 <do_fork+0x11a>
        intr_enable();
ffffffffc0204506:	8aafc0ef          	jal	ra,ffffffffc02005b0 <intr_enable>
ffffffffc020450a:	bfbd                	j	ffffffffc0204488 <do_fork+0x1c2>
                    if (last_pid >= MAX_PID) {
ffffffffc020450c:	0117c363          	blt	a5,a7,ffffffffc0204512 <do_fork+0x24c>
                        last_pid = 1;
ffffffffc0204510:	4785                	li	a5,1
                    goto repeat;
ffffffffc0204512:	4585                	li	a1,1
ffffffffc0204514:	b5d5                	j	ffffffffc02043f8 <do_fork+0x132>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0204516:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc0204518:	c02007b7          	lui	a5,0xc0200
ffffffffc020451c:	0af6e063          	bltu	a3,a5,ffffffffc02045bc <do_fork+0x2f6>
ffffffffc0204520:	00012797          	auipc	a5,0x12
ffffffffc0204524:	0b878793          	addi	a5,a5,184 # ffffffffc02165d8 <va_pa_offset>
ffffffffc0204528:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc020452a:	00012717          	auipc	a4,0x12
ffffffffc020452e:	f7e70713          	addi	a4,a4,-130 # ffffffffc02164a8 <npage>
ffffffffc0204532:	6318                	ld	a4,0(a4)
    return pa2page(PADDR(kva));
ffffffffc0204534:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc0204538:	83b1                	srli	a5,a5,0xc
ffffffffc020453a:	06e7f563          	bleu	a4,a5,ffffffffc02045a4 <do_fork+0x2de>
    return &pages[PPN(pa) - nbase];
ffffffffc020453e:	00003717          	auipc	a4,0x3
ffffffffc0204542:	ce270713          	addi	a4,a4,-798 # ffffffffc0207220 <nbase>
ffffffffc0204546:	6318                	ld	a4,0(a4)
ffffffffc0204548:	00012697          	auipc	a3,0x12
ffffffffc020454c:	0a068693          	addi	a3,a3,160 # ffffffffc02165e8 <pages>
ffffffffc0204550:	6288                	ld	a0,0(a3)
ffffffffc0204552:	8f99                	sub	a5,a5,a4
ffffffffc0204554:	079a                	slli	a5,a5,0x6
ffffffffc0204556:	4589                	li	a1,2
ffffffffc0204558:	953e                	add	a0,a0,a5
ffffffffc020455a:	b33fe0ef          	jal	ra,ffffffffc020308c <free_pages>
    kfree(proc);
ffffffffc020455e:	8522                	mv	a0,s0
ffffffffc0204560:	a2ffd0ef          	jal	ra,ffffffffc0201f8e <kfree>
    ret = -E_NO_MEM;
ffffffffc0204564:	5571                	li	a0,-4
    return ret;
ffffffffc0204566:	bf2d                	j	ffffffffc02044a0 <do_fork+0x1da>
    int ret = -E_NO_FREE_PROC;
ffffffffc0204568:	556d                	li	a0,-5
ffffffffc020456a:	bf1d                	j	ffffffffc02044a0 <do_fork+0x1da>
    assert(current->mm == NULL);
ffffffffc020456c:	00002697          	auipc	a3,0x2
ffffffffc0204570:	6f468693          	addi	a3,a3,1780 # ffffffffc0206c60 <default_pmm_manager+0x648>
ffffffffc0204574:	00001617          	auipc	a2,0x1
ffffffffc0204578:	36c60613          	addi	a2,a2,876 # ffffffffc02058e0 <commands+0x860>
ffffffffc020457c:	14f00593          	li	a1,335
ffffffffc0204580:	00002517          	auipc	a0,0x2
ffffffffc0204584:	6f850513          	addi	a0,a0,1784 # ffffffffc0206c78 <default_pmm_manager+0x660>
ffffffffc0204588:	c4ffb0ef          	jal	ra,ffffffffc02001d6 <__panic>
    return KADDR(page2pa(page));
ffffffffc020458c:	00001617          	auipc	a2,0x1
ffffffffc0204590:	6bc60613          	addi	a2,a2,1724 # ffffffffc0205c48 <commands+0xbc8>
ffffffffc0204594:	06900593          	li	a1,105
ffffffffc0204598:	00001517          	auipc	a0,0x1
ffffffffc020459c:	6a050513          	addi	a0,a0,1696 # ffffffffc0205c38 <commands+0xbb8>
ffffffffc02045a0:	c37fb0ef          	jal	ra,ffffffffc02001d6 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02045a4:	00001617          	auipc	a2,0x1
ffffffffc02045a8:	67460613          	addi	a2,a2,1652 # ffffffffc0205c18 <commands+0xb98>
ffffffffc02045ac:	06200593          	li	a1,98
ffffffffc02045b0:	00001517          	auipc	a0,0x1
ffffffffc02045b4:	68850513          	addi	a0,a0,1672 # ffffffffc0205c38 <commands+0xbb8>
ffffffffc02045b8:	c1ffb0ef          	jal	ra,ffffffffc02001d6 <__panic>
    return pa2page(PADDR(kva));
ffffffffc02045bc:	00002617          	auipc	a2,0x2
ffffffffc02045c0:	aa460613          	addi	a2,a2,-1372 # ffffffffc0206060 <commands+0xfe0>
ffffffffc02045c4:	06e00593          	li	a1,110
ffffffffc02045c8:	00001517          	auipc	a0,0x1
ffffffffc02045cc:	67050513          	addi	a0,a0,1648 # ffffffffc0205c38 <commands+0xbb8>
ffffffffc02045d0:	c07fb0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc02045d4 <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02045d4:	7129                	addi	sp,sp,-320
ffffffffc02045d6:	f24a                	sd	s2,288(sp)
ffffffffc02045d8:	892a                	mv	s2,a0
    cprintf("THIS MY: kernel_thread bigin!\n");
ffffffffc02045da:	00002517          	auipc	a0,0x2
ffffffffc02045de:	74e50513          	addi	a0,a0,1870 # ffffffffc0206d28 <default_pmm_manager+0x710>
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02045e2:	fe06                	sd	ra,312(sp)
ffffffffc02045e4:	fa22                	sd	s0,304(sp)
ffffffffc02045e6:	f626                	sd	s1,296(sp)
ffffffffc02045e8:	8432                	mv	s0,a2
ffffffffc02045ea:	84ae                	mv	s1,a1
    cprintf("THIS MY: kernel_thread bigin!\n");
ffffffffc02045ec:	ae5fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02045f0:	12000613          	li	a2,288
ffffffffc02045f4:	4581                	li	a1,0
ffffffffc02045f6:	850a                	mv	a0,sp
ffffffffc02045f8:	4c8000ef          	jal	ra,ffffffffc0204ac0 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc02045fc:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc02045fe:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;// 确保内核线程在 Supervisor 模式下运行，允许中断响应但不响应中断。
ffffffffc0204600:	100027f3          	csrr	a5,sstatus
ffffffffc0204604:	edd7f793          	andi	a5,a5,-291
ffffffffc0204608:	1207e793          	ori	a5,a5,288
ffffffffc020460c:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020460e:	860a                	mv	a2,sp
ffffffffc0204610:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0204614:	00000797          	auipc	a5,0x0
ffffffffc0204618:	a5678793          	addi	a5,a5,-1450 # ffffffffc020406a <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020461c:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc020461e:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0204620:	ca7ff0ef          	jal	ra,ffffffffc02042c6 <do_fork>
}
ffffffffc0204624:	70f2                	ld	ra,312(sp)
ffffffffc0204626:	7452                	ld	s0,304(sp)
ffffffffc0204628:	74b2                	ld	s1,296(sp)
ffffffffc020462a:	7912                	ld	s2,288(sp)
ffffffffc020462c:	6131                	addi	sp,sp,320
ffffffffc020462e:	8082                	ret

ffffffffc0204630 <do_exit>:
do_exit(int error_code) {
ffffffffc0204630:	1141                	addi	sp,sp,-16
    panic("process exit!!.\n");
ffffffffc0204632:	00002617          	auipc	a2,0x2
ffffffffc0204636:	5f660613          	addi	a2,a2,1526 # ffffffffc0206c28 <default_pmm_manager+0x610>
ffffffffc020463a:	1ca00593          	li	a1,458
ffffffffc020463e:	00002517          	auipc	a0,0x2
ffffffffc0204642:	63a50513          	addi	a0,a0,1594 # ffffffffc0206c78 <default_pmm_manager+0x660>
do_exit(int error_code) {
ffffffffc0204646:	e406                	sd	ra,8(sp)
    panic("process exit!!.\n");
ffffffffc0204648:	b8ffb0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc020464c <cpu_idle>:
    cpu_idle();
}

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {// 不断调用schedule
ffffffffc020464c:	1141                	addi	sp,sp,-16
    cprintf("cpu_idle begin! \n");
ffffffffc020464e:	00002517          	auipc	a0,0x2
ffffffffc0204652:	5c250513          	addi	a0,a0,1474 # ffffffffc0206c10 <default_pmm_manager+0x5f8>
cpu_idle(void) {// 不断调用schedule
ffffffffc0204656:	e022                	sd	s0,0(sp)
ffffffffc0204658:	e406                	sd	ra,8(sp)
ffffffffc020465a:	00012417          	auipc	s0,0x12
ffffffffc020465e:	e5640413          	addi	s0,s0,-426 # ffffffffc02164b0 <current>
    cprintf("cpu_idle begin! \n");
ffffffffc0204662:	a6ffb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    while (1) {
        if (current->need_resched) {
ffffffffc0204666:	6018                	ld	a4,0(s0)
ffffffffc0204668:	4f1c                	lw	a5,24(a4)
ffffffffc020466a:	2781                	sext.w	a5,a5
ffffffffc020466c:	dff5                	beqz	a5,ffffffffc0204668 <cpu_idle+0x1c>
            schedule();
ffffffffc020466e:	2f8000ef          	jal	ra,ffffffffc0204966 <schedule>
ffffffffc0204672:	bfd5                	j	ffffffffc0204666 <cpu_idle+0x1a>

ffffffffc0204674 <proc_init>:
proc_init(void) {
ffffffffc0204674:	715d                	addi	sp,sp,-80
    cprintf("proc_init begin! \n");
ffffffffc0204676:	00002517          	auipc	a0,0x2
ffffffffc020467a:	6d250513          	addi	a0,a0,1746 # ffffffffc0206d48 <default_pmm_manager+0x730>
proc_init(void) {
ffffffffc020467e:	e486                	sd	ra,72(sp)
ffffffffc0204680:	e0a2                	sd	s0,64(sp)
ffffffffc0204682:	fc26                	sd	s1,56(sp)
ffffffffc0204684:	f84a                	sd	s2,48(sp)
    cprintf("proc_init begin! \n");
ffffffffc0204686:	a4bfb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    elm->prev = elm->next = elm;
ffffffffc020468a:	00012797          	auipc	a5,0x12
ffffffffc020468e:	f6678793          	addi	a5,a5,-154 # ffffffffc02165f0 <proc_list>
ffffffffc0204692:	00012717          	auipc	a4,0x12
ffffffffc0204696:	f6f73323          	sd	a5,-154(a4) # ffffffffc02165f8 <proc_list+0x8>
ffffffffc020469a:	00012717          	auipc	a4,0x12
ffffffffc020469e:	f4f73b23          	sd	a5,-170(a4) # ffffffffc02165f0 <proc_list>
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc02046a2:	00012717          	auipc	a4,0x12
ffffffffc02046a6:	dbe70713          	addi	a4,a4,-578 # ffffffffc0216460 <name.1565>
ffffffffc02046aa:	0000e797          	auipc	a5,0xe
ffffffffc02046ae:	db678793          	addi	a5,a5,-586 # ffffffffc0212460 <hash_list>
ffffffffc02046b2:	e79c                	sd	a5,8(a5)
ffffffffc02046b4:	e39c                	sd	a5,0(a5)
ffffffffc02046b6:	07c1                	addi	a5,a5,16
ffffffffc02046b8:	fee79de3          	bne	a5,a4,ffffffffc02046b2 <proc_init+0x3e>
    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc02046bc:	a21ff0ef          	jal	ra,ffffffffc02040dc <alloc_proc>
ffffffffc02046c0:	00012797          	auipc	a5,0x12
ffffffffc02046c4:	dea7bc23          	sd	a0,-520(a5) # ffffffffc02164b8 <idleproc>
ffffffffc02046c8:	00012417          	auipc	s0,0x12
ffffffffc02046cc:	df040413          	addi	s0,s0,-528 # ffffffffc02164b8 <idleproc>
ffffffffc02046d0:	1e050263          	beqz	a0,ffffffffc02048b4 <proc_init+0x240>
    int *context_mem = (int*) kmalloc(sizeof(struct context));
ffffffffc02046d4:	07000513          	li	a0,112
ffffffffc02046d8:	ffafd0ef          	jal	ra,ffffffffc0201ed2 <kmalloc>
    memset(context_mem, 0, sizeof(struct context));
ffffffffc02046dc:	07000613          	li	a2,112
ffffffffc02046e0:	4581                	li	a1,0
    int *context_mem = (int*) kmalloc(sizeof(struct context));
ffffffffc02046e2:	84aa                	mv	s1,a0
    memset(context_mem, 0, sizeof(struct context));
ffffffffc02046e4:	3dc000ef          	jal	ra,ffffffffc0204ac0 <memset>
    int context_init_flag = memcmp(&(idleproc->context), context_mem, sizeof(struct context));
ffffffffc02046e8:	6008                	ld	a0,0(s0)
ffffffffc02046ea:	85a6                	mv	a1,s1
ffffffffc02046ec:	07000613          	li	a2,112
ffffffffc02046f0:	03050513          	addi	a0,a0,48
ffffffffc02046f4:	3f6000ef          	jal	ra,ffffffffc0204aea <memcmp>
ffffffffc02046f8:	84aa                	mv	s1,a0
    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);
ffffffffc02046fa:	453d                	li	a0,15
ffffffffc02046fc:	fd6fd0ef          	jal	ra,ffffffffc0201ed2 <kmalloc>
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc0204700:	463d                	li	a2,15
ffffffffc0204702:	4581                	li	a1,0
    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);
ffffffffc0204704:	892a                	mv	s2,a0
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc0204706:	3ba000ef          	jal	ra,ffffffffc0204ac0 <memset>
    int proc_name_flag = memcmp(&(idleproc->name), proc_name_mem, PROC_NAME_LEN);
ffffffffc020470a:	6008                	ld	a0,0(s0)
ffffffffc020470c:	463d                	li	a2,15
ffffffffc020470e:	85ca                	mv	a1,s2
ffffffffc0204710:	0b450513          	addi	a0,a0,180
ffffffffc0204714:	3d6000ef          	jal	ra,ffffffffc0204aea <memcmp>
    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
ffffffffc0204718:	00043303          	ld	t1,0(s0)
ffffffffc020471c:	00012797          	auipc	a5,0x12
ffffffffc0204720:	ec478793          	addi	a5,a5,-316 # ffffffffc02165e0 <boot_cr3>
ffffffffc0204724:	6394                	ld	a3,0(a5)
ffffffffc0204726:	0a833583          	ld	a1,168(t1)
ffffffffc020472a:	0a033603          	ld	a2,160(t1)
ffffffffc020472e:	00d59463          	bne	a1,a3,ffffffffc0204736 <proc_init+0xc2>
ffffffffc0204732:	18060d63          	beqz	a2,ffffffffc02048cc <proc_init+0x258>
ffffffffc0204736:	00832783          	lw	a5,8(t1)
ffffffffc020473a:	01033883          	ld	a7,16(t1)
        cprintf("proc_init idleproc structure init wrong! cr3:%d, tf:%d, context_init_flag:%d, \
ffffffffc020473e:	00153813          	seqz	a6,a0
ffffffffc0204742:	00432e03          	lw	t3,4(t1)
        , idleproc->kstack == 0 , idleproc->need_resched == 0 , idleproc->parent == NULL 
ffffffffc0204746:	01832503          	lw	a0,24(t1)
        cprintf("proc_init idleproc structure init wrong! cr3:%d, tf:%d, context_init_flag:%d, \
ffffffffc020474a:	00032703          	lw	a4,0(t1)
ffffffffc020474e:	f042                	sd	a6,32(sp)
ffffffffc0204750:	0b032e83          	lw	t4,176(t1)
ffffffffc0204754:	0007881b          	sext.w	a6,a5
        , idleproc->kstack == 0 , idleproc->need_resched == 0 , idleproc->parent == NULL 
ffffffffc0204758:	2501                	sext.w	a0,a0
        cprintf("proc_init idleproc structure init wrong! cr3:%d, tf:%d, context_init_flag:%d, \
ffffffffc020475a:	001eb793          	seqz	a5,t4
ffffffffc020475e:	ec3e                	sd	a5,24(sp)
ffffffffc0204760:	02833e83          	ld	t4,40(t1)
ffffffffc0204764:	001e0793          	addi	a5,t3,1
ffffffffc0204768:	00153513          	seqz	a0,a0
ffffffffc020476c:	001ebe13          	seqz	t3,t4
ffffffffc0204770:	e872                	sd	t3,16(sp)
ffffffffc0204772:	02033303          	ld	t1,32(t1)
ffffffffc0204776:	8d95                	sub	a1,a1,a3
ffffffffc0204778:	e02a                	sd	a0,0(sp)
ffffffffc020477a:	00133513          	seqz	a0,t1
ffffffffc020477e:	e42a                	sd	a0,8(sp)
ffffffffc0204780:	0018b893          	seqz	a7,a7
ffffffffc0204784:	00183813          	seqz	a6,a6
ffffffffc0204788:	0017b793          	seqz	a5,a5
ffffffffc020478c:	00173713          	seqz	a4,a4
ffffffffc0204790:	0014b693          	seqz	a3,s1
ffffffffc0204794:	00163613          	seqz	a2,a2
ffffffffc0204798:	0015b593          	seqz	a1,a1
ffffffffc020479c:	00002517          	auipc	a0,0x2
ffffffffc02047a0:	5f450513          	addi	a0,a0,1524 # ffffffffc0206d90 <default_pmm_manager+0x778>
ffffffffc02047a4:	92dfb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    idleproc->pid = 0;
ffffffffc02047a8:	6008                	ld	a0,0(s0)
    idleproc->state = PROC_RUNNABLE;
ffffffffc02047aa:	4789                	li	a5,2
    set_proc_name(idleproc, "idle");
ffffffffc02047ac:	00002597          	auipc	a1,0x2
ffffffffc02047b0:	6ac58593          	addi	a1,a1,1708 # ffffffffc0206e58 <default_pmm_manager+0x840>
    idleproc->state = PROC_RUNNABLE;
ffffffffc02047b4:	e11c                	sd	a5,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc02047b6:	00004797          	auipc	a5,0x4
ffffffffc02047ba:	84a78793          	addi	a5,a5,-1974 # ffffffffc0208000 <bootstack>
ffffffffc02047be:	e91c                	sd	a5,16(a0)
    idleproc->need_resched = 1;
ffffffffc02047c0:	4785                	li	a5,1
ffffffffc02047c2:	cd1c                	sw	a5,24(a0)
    set_proc_name(idleproc, "idle");
ffffffffc02047c4:	98dff0ef          	jal	ra,ffffffffc0204150 <set_proc_name>
    nr_process ++;
ffffffffc02047c8:	00012797          	auipc	a5,0x12
ffffffffc02047cc:	d0078793          	addi	a5,a5,-768 # ffffffffc02164c8 <nr_process>
ffffffffc02047d0:	439c                	lw	a5,0(a5)
    current = idleproc;// 
ffffffffc02047d2:	6018                	ld	a4,0(s0)
    int pid = kernel_thread(init_main, "Hello world!!", 0);// 创建线程并返回pid
ffffffffc02047d4:	4601                	li	a2,0
    nr_process ++;
ffffffffc02047d6:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, "Hello world!!", 0);// 创建线程并返回pid
ffffffffc02047d8:	00002597          	auipc	a1,0x2
ffffffffc02047dc:	68858593          	addi	a1,a1,1672 # ffffffffc0206e60 <default_pmm_manager+0x848>
ffffffffc02047e0:	00000517          	auipc	a0,0x0
ffffffffc02047e4:	9ca50513          	addi	a0,a0,-1590 # ffffffffc02041aa <init_main>
    nr_process ++;
ffffffffc02047e8:	00012697          	auipc	a3,0x12
ffffffffc02047ec:	cef6a023          	sw	a5,-800(a3) # ffffffffc02164c8 <nr_process>
    current = idleproc;// 
ffffffffc02047f0:	00012797          	auipc	a5,0x12
ffffffffc02047f4:	cce7b023          	sd	a4,-832(a5) # ffffffffc02164b0 <current>
    int pid = kernel_thread(init_main, "Hello world!!", 0);// 创建线程并返回pid
ffffffffc02047f8:	dddff0ef          	jal	ra,ffffffffc02045d4 <kernel_thread>
ffffffffc02047fc:	84aa                	mv	s1,a0
    if (pid <= 0) {
ffffffffc02047fe:	06a05f63          	blez	a0,ffffffffc020487c <proc_init+0x208>
    cprintf("proc_init created thread: %d! \n", pid);
ffffffffc0204802:	85aa                	mv	a1,a0
ffffffffc0204804:	00002517          	auipc	a0,0x2
ffffffffc0204808:	68c50513          	addi	a0,a0,1676 # ffffffffc0206e90 <default_pmm_manager+0x878>
ffffffffc020480c:	8c5fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    initproc = find_proc(pid);
ffffffffc0204810:	8526                	mv	a0,s1
ffffffffc0204812:	a59ff0ef          	jal	ra,ffffffffc020426a <find_proc>
ffffffffc0204816:	87aa                	mv	a5,a0
    cprintf("proc_init find thread: %d, isnull?= %d! \n", pid, initproc == NULL);
ffffffffc0204818:	00153613          	seqz	a2,a0
ffffffffc020481c:	85a6                	mv	a1,s1
ffffffffc020481e:	00002517          	auipc	a0,0x2
ffffffffc0204822:	69250513          	addi	a0,a0,1682 # ffffffffc0206eb0 <default_pmm_manager+0x898>
    initproc = find_proc(pid);
ffffffffc0204826:	00012717          	auipc	a4,0x12
ffffffffc020482a:	c8f73d23          	sd	a5,-870(a4) # ffffffffc02164c0 <initproc>
ffffffffc020482e:	00012497          	auipc	s1,0x12
ffffffffc0204832:	c9248493          	addi	s1,s1,-878 # ffffffffc02164c0 <initproc>
    cprintf("proc_init find thread: %d, isnull?= %d! \n", pid, initproc == NULL);
ffffffffc0204836:	89bfb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    set_proc_name(initproc, "init");
ffffffffc020483a:	6088                	ld	a0,0(s1)
ffffffffc020483c:	00002597          	auipc	a1,0x2
ffffffffc0204840:	6a458593          	addi	a1,a1,1700 # ffffffffc0206ee0 <default_pmm_manager+0x8c8>
ffffffffc0204844:	90dff0ef          	jal	ra,ffffffffc0204150 <set_proc_name>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0204848:	601c                	ld	a5,0(s0)
ffffffffc020484a:	c7a9                	beqz	a5,ffffffffc0204894 <proc_init+0x220>
ffffffffc020484c:	43dc                	lw	a5,4(a5)
ffffffffc020484e:	e3b9                	bnez	a5,ffffffffc0204894 <proc_init+0x220>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0204850:	609c                	ld	a5,0(s1)
ffffffffc0204852:	c789                	beqz	a5,ffffffffc020485c <proc_init+0x1e8>
ffffffffc0204854:	43d8                	lw	a4,4(a5)
ffffffffc0204856:	4785                	li	a5,1
ffffffffc0204858:	0cf70663          	beq	a4,a5,ffffffffc0204924 <proc_init+0x2b0>
ffffffffc020485c:	00002697          	auipc	a3,0x2
ffffffffc0204860:	6b468693          	addi	a3,a3,1716 # ffffffffc0206f10 <default_pmm_manager+0x8f8>
ffffffffc0204864:	00001617          	auipc	a2,0x1
ffffffffc0204868:	07c60613          	addi	a2,a2,124 # ffffffffc02058e0 <commands+0x860>
ffffffffc020486c:	21500593          	li	a1,533
ffffffffc0204870:	00002517          	auipc	a0,0x2
ffffffffc0204874:	40850513          	addi	a0,a0,1032 # ffffffffc0206c78 <default_pmm_manager+0x660>
ffffffffc0204878:	95ffb0ef          	jal	ra,ffffffffc02001d6 <__panic>
        panic("create init_main failed.\n");
ffffffffc020487c:	00002617          	auipc	a2,0x2
ffffffffc0204880:	5f460613          	addi	a2,a2,1524 # ffffffffc0206e70 <default_pmm_manager+0x858>
ffffffffc0204884:	20d00593          	li	a1,525
ffffffffc0204888:	00002517          	auipc	a0,0x2
ffffffffc020488c:	3f050513          	addi	a0,a0,1008 # ffffffffc0206c78 <default_pmm_manager+0x660>
ffffffffc0204890:	947fb0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0204894:	00002697          	auipc	a3,0x2
ffffffffc0204898:	65468693          	addi	a3,a3,1620 # ffffffffc0206ee8 <default_pmm_manager+0x8d0>
ffffffffc020489c:	00001617          	auipc	a2,0x1
ffffffffc02048a0:	04460613          	addi	a2,a2,68 # ffffffffc02058e0 <commands+0x860>
ffffffffc02048a4:	21400593          	li	a1,532
ffffffffc02048a8:	00002517          	auipc	a0,0x2
ffffffffc02048ac:	3d050513          	addi	a0,a0,976 # ffffffffc0206c78 <default_pmm_manager+0x660>
ffffffffc02048b0:	927fb0ef          	jal	ra,ffffffffc02001d6 <__panic>
        panic("cannot alloc idleproc.\n");
ffffffffc02048b4:	00002617          	auipc	a2,0x2
ffffffffc02048b8:	4ac60613          	addi	a2,a2,1196 # ffffffffc0206d60 <default_pmm_manager+0x748>
ffffffffc02048bc:	1e500593          	li	a1,485
ffffffffc02048c0:	00002517          	auipc	a0,0x2
ffffffffc02048c4:	3b850513          	addi	a0,a0,952 # ffffffffc0206c78 <default_pmm_manager+0x660>
ffffffffc02048c8:	90ffb0ef          	jal	ra,ffffffffc02001d6 <__panic>
    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
ffffffffc02048cc:	e60495e3          	bnez	s1,ffffffffc0204736 <proc_init+0xc2>
        && idleproc->state == PROC_UNINIT && idleproc->pid == -1 && idleproc->runs == 0
ffffffffc02048d0:	00033703          	ld	a4,0(t1)
ffffffffc02048d4:	57fd                	li	a5,-1
ffffffffc02048d6:	1782                	slli	a5,a5,0x20
ffffffffc02048d8:	e4f71fe3          	bne	a4,a5,ffffffffc0204736 <proc_init+0xc2>
ffffffffc02048dc:	00832783          	lw	a5,8(t1)
        && idleproc->kstack == 0 && idleproc->need_resched == 0 && idleproc->parent == NULL 
ffffffffc02048e0:	01033883          	ld	a7,16(t1)
        && idleproc->state == PROC_UNINIT && idleproc->pid == -1 && idleproc->runs == 0
ffffffffc02048e4:	0007871b          	sext.w	a4,a5
ffffffffc02048e8:	e4071be3          	bnez	a4,ffffffffc020473e <proc_init+0xca>
        && idleproc->kstack == 0 && idleproc->need_resched == 0 && idleproc->parent == NULL 
ffffffffc02048ec:	e40899e3          	bnez	a7,ffffffffc020473e <proc_init+0xca>
ffffffffc02048f0:	01832703          	lw	a4,24(t1)
ffffffffc02048f4:	2701                	sext.w	a4,a4
ffffffffc02048f6:	e40714e3          	bnez	a4,ffffffffc020473e <proc_init+0xca>
ffffffffc02048fa:	02033703          	ld	a4,32(t1)
ffffffffc02048fe:	e40710e3          	bnez	a4,ffffffffc020473e <proc_init+0xca>
        && idleproc->mm == NULL && idleproc->flags == 0 && !proc_name_flag
ffffffffc0204902:	02833703          	ld	a4,40(t1)
ffffffffc0204906:	e2071ce3          	bnez	a4,ffffffffc020473e <proc_init+0xca>
ffffffffc020490a:	0b032703          	lw	a4,176(t1)
ffffffffc020490e:	8f49                	or	a4,a4,a0
ffffffffc0204910:	2701                	sext.w	a4,a4
ffffffffc0204912:	e20716e3          	bnez	a4,ffffffffc020473e <proc_init+0xca>
        cprintf("alloc_proc() correct!\n");
ffffffffc0204916:	00002517          	auipc	a0,0x2
ffffffffc020491a:	46250513          	addi	a0,a0,1122 # ffffffffc0206d78 <default_pmm_manager+0x760>
ffffffffc020491e:	fb2fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc0204922:	b559                	j	ffffffffc02047a8 <proc_init+0x134>
    cprintf("proc_init end! \n");
ffffffffc0204924:	00002517          	auipc	a0,0x2
ffffffffc0204928:	61450513          	addi	a0,a0,1556 # ffffffffc0206f38 <default_pmm_manager+0x920>
ffffffffc020492c:	fa4fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cpu_idle();
ffffffffc0204930:	d1dff0ef          	jal	ra,ffffffffc020464c <cpu_idle>

ffffffffc0204934 <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc0204934:	411c                	lw	a5,0(a0)
ffffffffc0204936:	4705                	li	a4,1
ffffffffc0204938:	37f9                	addiw	a5,a5,-2
ffffffffc020493a:	00f77563          	bleu	a5,a4,ffffffffc0204944 <wakeup_proc+0x10>
    proc->state = PROC_RUNNABLE;
ffffffffc020493e:	4789                	li	a5,2
ffffffffc0204940:	c11c                	sw	a5,0(a0)
ffffffffc0204942:	8082                	ret
wakeup_proc(struct proc_struct *proc) {
ffffffffc0204944:	1141                	addi	sp,sp,-16
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc0204946:	00002697          	auipc	a3,0x2
ffffffffc020494a:	64268693          	addi	a3,a3,1602 # ffffffffc0206f88 <default_pmm_manager+0x970>
ffffffffc020494e:	00001617          	auipc	a2,0x1
ffffffffc0204952:	f9260613          	addi	a2,a2,-110 # ffffffffc02058e0 <commands+0x860>
ffffffffc0204956:	45a5                	li	a1,9
ffffffffc0204958:	00002517          	auipc	a0,0x2
ffffffffc020495c:	67050513          	addi	a0,a0,1648 # ffffffffc0206fc8 <default_pmm_manager+0x9b0>
wakeup_proc(struct proc_struct *proc) {
ffffffffc0204960:	e406                	sd	ra,8(sp)
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc0204962:	875fb0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc0204966 <schedule>:
}

void
schedule(void) {
ffffffffc0204966:	1101                	addi	sp,sp,-32
    cprintf("schedule begin! \n");
ffffffffc0204968:	00002517          	auipc	a0,0x2
ffffffffc020496c:	5e850513          	addi	a0,a0,1512 # ffffffffc0206f50 <default_pmm_manager+0x938>
schedule(void) {
ffffffffc0204970:	ec06                	sd	ra,24(sp)
ffffffffc0204972:	e822                	sd	s0,16(sp)
ffffffffc0204974:	e426                	sd	s1,8(sp)
    cprintf("schedule begin! \n");
ffffffffc0204976:	f5afb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020497a:	100027f3          	csrr	a5,sstatus
ffffffffc020497e:	8b89                	andi	a5,a5,2
ffffffffc0204980:	4481                	li	s1,0
ffffffffc0204982:	efc1                	bnez	a5,ffffffffc0204a1a <schedule+0xb4>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc0204984:	00012797          	auipc	a5,0x12
ffffffffc0204988:	b2c78793          	addi	a5,a5,-1236 # ffffffffc02164b0 <current>
ffffffffc020498c:	0007b803          	ld	a6,0(a5)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0204990:	00012797          	auipc	a5,0x12
ffffffffc0204994:	b2878793          	addi	a5,a5,-1240 # ffffffffc02164b8 <idleproc>
ffffffffc0204998:	6380                	ld	s0,0(a5)
        current->need_resched = 0;
ffffffffc020499a:	00082c23          	sw	zero,24(a6) # fffffffffff80018 <end+0x3fd69a18>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc020499e:	06880863          	beq	a6,s0,ffffffffc0204a0e <schedule+0xa8>
ffffffffc02049a2:	0c880693          	addi	a3,a6,200
ffffffffc02049a6:	00012617          	auipc	a2,0x12
ffffffffc02049aa:	c4a60613          	addi	a2,a2,-950 # ffffffffc02165f0 <proc_list>
        le = last;
ffffffffc02049ae:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc02049b0:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc02049b2:	4509                	li	a0,2
    return listelm->next;
ffffffffc02049b4:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc02049b6:	00c78863          	beq	a5,a2,ffffffffc02049c6 <schedule+0x60>
                if (next->state == PROC_RUNNABLE) {
ffffffffc02049ba:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc02049be:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc02049c2:	00a70463          	beq	a4,a0,ffffffffc02049ca <schedule+0x64>
                    break;
                }
            }
        } while (le != last);
ffffffffc02049c6:	fef697e3          	bne	a3,a5,ffffffffc02049b4 <schedule+0x4e>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc02049ca:	c589                	beqz	a1,ffffffffc02049d4 <schedule+0x6e>
ffffffffc02049cc:	4198                	lw	a4,0(a1)
ffffffffc02049ce:	4789                	li	a5,2
ffffffffc02049d0:	02f70763          	beq	a4,a5,ffffffffc02049fe <schedule+0x98>
            next = idleproc;
        }
        next->runs ++;
ffffffffc02049d4:	441c                	lw	a5,8(s0)
ffffffffc02049d6:	2785                	addiw	a5,a5,1
ffffffffc02049d8:	c41c                	sw	a5,8(s0)
        if (next != current) {
ffffffffc02049da:	00880c63          	beq	a6,s0,ffffffffc02049f2 <schedule+0x8c>
            cprintf("schedule next pid is : %d! \n", next->pid);
ffffffffc02049de:	404c                	lw	a1,4(s0)
ffffffffc02049e0:	00002517          	auipc	a0,0x2
ffffffffc02049e4:	58850513          	addi	a0,a0,1416 # ffffffffc0206f68 <default_pmm_manager+0x950>
ffffffffc02049e8:	ee8fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            proc_run(next);
ffffffffc02049ec:	8522                	mv	a0,s0
ffffffffc02049ee:	80fff0ef          	jal	ra,ffffffffc02041fc <proc_run>
    if (flag) {
ffffffffc02049f2:	e881                	bnez	s1,ffffffffc0204a02 <schedule+0x9c>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc02049f4:	60e2                	ld	ra,24(sp)
ffffffffc02049f6:	6442                	ld	s0,16(sp)
ffffffffc02049f8:	64a2                	ld	s1,8(sp)
ffffffffc02049fa:	6105                	addi	sp,sp,32
ffffffffc02049fc:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc02049fe:	842e                	mv	s0,a1
ffffffffc0204a00:	bfd1                	j	ffffffffc02049d4 <schedule+0x6e>
}
ffffffffc0204a02:	6442                	ld	s0,16(sp)
ffffffffc0204a04:	60e2                	ld	ra,24(sp)
ffffffffc0204a06:	64a2                	ld	s1,8(sp)
ffffffffc0204a08:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0204a0a:	ba7fb06f          	j	ffffffffc02005b0 <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0204a0e:	00012617          	auipc	a2,0x12
ffffffffc0204a12:	be260613          	addi	a2,a2,-1054 # ffffffffc02165f0 <proc_list>
ffffffffc0204a16:	86b2                	mv	a3,a2
ffffffffc0204a18:	bf59                	j	ffffffffc02049ae <schedule+0x48>
        intr_disable();
ffffffffc0204a1a:	b9dfb0ef          	jal	ra,ffffffffc02005b6 <intr_disable>
        return 1;
ffffffffc0204a1e:	4485                	li	s1,1
ffffffffc0204a20:	b795                	j	ffffffffc0204984 <schedule+0x1e>

ffffffffc0204a22 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0204a22:	00054783          	lbu	a5,0(a0)
ffffffffc0204a26:	cb91                	beqz	a5,ffffffffc0204a3a <strlen+0x18>
    size_t cnt = 0;
ffffffffc0204a28:	4781                	li	a5,0
        cnt ++;
ffffffffc0204a2a:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc0204a2c:	00f50733          	add	a4,a0,a5
ffffffffc0204a30:	00074703          	lbu	a4,0(a4)
ffffffffc0204a34:	fb7d                	bnez	a4,ffffffffc0204a2a <strlen+0x8>
    }
    return cnt;
}
ffffffffc0204a36:	853e                	mv	a0,a5
ffffffffc0204a38:	8082                	ret
    size_t cnt = 0;
ffffffffc0204a3a:	4781                	li	a5,0
}
ffffffffc0204a3c:	853e                	mv	a0,a5
ffffffffc0204a3e:	8082                	ret

ffffffffc0204a40 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204a40:	c185                	beqz	a1,ffffffffc0204a60 <strnlen+0x20>
ffffffffc0204a42:	00054783          	lbu	a5,0(a0)
ffffffffc0204a46:	cf89                	beqz	a5,ffffffffc0204a60 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0204a48:	4781                	li	a5,0
ffffffffc0204a4a:	a021                	j	ffffffffc0204a52 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204a4c:	00074703          	lbu	a4,0(a4)
ffffffffc0204a50:	c711                	beqz	a4,ffffffffc0204a5c <strnlen+0x1c>
        cnt ++;
ffffffffc0204a52:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204a54:	00f50733          	add	a4,a0,a5
ffffffffc0204a58:	fef59ae3          	bne	a1,a5,ffffffffc0204a4c <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0204a5c:	853e                	mv	a0,a5
ffffffffc0204a5e:	8082                	ret
    size_t cnt = 0;
ffffffffc0204a60:	4781                	li	a5,0
}
ffffffffc0204a62:	853e                	mv	a0,a5
ffffffffc0204a64:	8082                	ret

ffffffffc0204a66 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0204a66:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0204a68:	0585                	addi	a1,a1,1
ffffffffc0204a6a:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0204a6e:	0785                	addi	a5,a5,1
ffffffffc0204a70:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0204a74:	fb75                	bnez	a4,ffffffffc0204a68 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0204a76:	8082                	ret

ffffffffc0204a78 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204a78:	00054783          	lbu	a5,0(a0)
ffffffffc0204a7c:	0005c703          	lbu	a4,0(a1)
ffffffffc0204a80:	cb91                	beqz	a5,ffffffffc0204a94 <strcmp+0x1c>
ffffffffc0204a82:	00e79c63          	bne	a5,a4,ffffffffc0204a9a <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0204a86:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204a88:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0204a8c:	0585                	addi	a1,a1,1
ffffffffc0204a8e:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204a92:	fbe5                	bnez	a5,ffffffffc0204a82 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0204a94:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0204a96:	9d19                	subw	a0,a0,a4
ffffffffc0204a98:	8082                	ret
ffffffffc0204a9a:	0007851b          	sext.w	a0,a5
ffffffffc0204a9e:	9d19                	subw	a0,a0,a4
ffffffffc0204aa0:	8082                	ret

ffffffffc0204aa2 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0204aa2:	00054783          	lbu	a5,0(a0)
ffffffffc0204aa6:	cb91                	beqz	a5,ffffffffc0204aba <strchr+0x18>
        if (*s == c) {
ffffffffc0204aa8:	00b79563          	bne	a5,a1,ffffffffc0204ab2 <strchr+0x10>
ffffffffc0204aac:	a809                	j	ffffffffc0204abe <strchr+0x1c>
ffffffffc0204aae:	00b78763          	beq	a5,a1,ffffffffc0204abc <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0204ab2:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0204ab4:	00054783          	lbu	a5,0(a0)
ffffffffc0204ab8:	fbfd                	bnez	a5,ffffffffc0204aae <strchr+0xc>
    }
    return NULL;
ffffffffc0204aba:	4501                	li	a0,0
}
ffffffffc0204abc:	8082                	ret
ffffffffc0204abe:	8082                	ret

ffffffffc0204ac0 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0204ac0:	ca01                	beqz	a2,ffffffffc0204ad0 <memset+0x10>
ffffffffc0204ac2:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0204ac4:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0204ac6:	0785                	addi	a5,a5,1
ffffffffc0204ac8:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0204acc:	fec79de3          	bne	a5,a2,ffffffffc0204ac6 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0204ad0:	8082                	ret

ffffffffc0204ad2 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0204ad2:	ca19                	beqz	a2,ffffffffc0204ae8 <memcpy+0x16>
ffffffffc0204ad4:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0204ad6:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0204ad8:	0585                	addi	a1,a1,1
ffffffffc0204ada:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0204ade:	0785                	addi	a5,a5,1
ffffffffc0204ae0:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0204ae4:	fec59ae3          	bne	a1,a2,ffffffffc0204ad8 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0204ae8:	8082                	ret

ffffffffc0204aea <memcmp>:
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
ffffffffc0204aea:	c21d                	beqz	a2,ffffffffc0204b10 <memcmp+0x26>
        if (*s1 != *s2) {
ffffffffc0204aec:	00054783          	lbu	a5,0(a0)
ffffffffc0204af0:	0005c703          	lbu	a4,0(a1)
ffffffffc0204af4:	962a                	add	a2,a2,a0
ffffffffc0204af6:	00f70963          	beq	a4,a5,ffffffffc0204b08 <memcmp+0x1e>
ffffffffc0204afa:	a829                	j	ffffffffc0204b14 <memcmp+0x2a>
ffffffffc0204afc:	00054783          	lbu	a5,0(a0)
ffffffffc0204b00:	0005c703          	lbu	a4,0(a1)
ffffffffc0204b04:	00e79863          	bne	a5,a4,ffffffffc0204b14 <memcmp+0x2a>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
ffffffffc0204b08:	0505                	addi	a0,a0,1
ffffffffc0204b0a:	0585                	addi	a1,a1,1
    while (n -- > 0) {
ffffffffc0204b0c:	fea618e3          	bne	a2,a0,ffffffffc0204afc <memcmp+0x12>
    }
    return 0;
ffffffffc0204b10:	4501                	li	a0,0
}
ffffffffc0204b12:	8082                	ret
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0204b14:	40e7853b          	subw	a0,a5,a4
ffffffffc0204b18:	8082                	ret

ffffffffc0204b1a <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0204b1a:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204b1e:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0204b20:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204b24:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0204b26:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204b2a:	f022                	sd	s0,32(sp)
ffffffffc0204b2c:	ec26                	sd	s1,24(sp)
ffffffffc0204b2e:	e84a                	sd	s2,16(sp)
ffffffffc0204b30:	f406                	sd	ra,40(sp)
ffffffffc0204b32:	e44e                	sd	s3,8(sp)
ffffffffc0204b34:	84aa                	mv	s1,a0
ffffffffc0204b36:	892e                	mv	s2,a1
ffffffffc0204b38:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0204b3c:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0204b3e:	03067e63          	bleu	a6,a2,ffffffffc0204b7a <printnum+0x60>
ffffffffc0204b42:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0204b44:	00805763          	blez	s0,ffffffffc0204b52 <printnum+0x38>
ffffffffc0204b48:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0204b4a:	85ca                	mv	a1,s2
ffffffffc0204b4c:	854e                	mv	a0,s3
ffffffffc0204b4e:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0204b50:	fc65                	bnez	s0,ffffffffc0204b48 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204b52:	1a02                	slli	s4,s4,0x20
ffffffffc0204b54:	020a5a13          	srli	s4,s4,0x20
ffffffffc0204b58:	00002797          	auipc	a5,0x2
ffffffffc0204b5c:	61878793          	addi	a5,a5,1560 # ffffffffc0207170 <error_string+0x38>
ffffffffc0204b60:	9a3e                	add	s4,s4,a5
}
ffffffffc0204b62:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204b64:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0204b68:	70a2                	ld	ra,40(sp)
ffffffffc0204b6a:	69a2                	ld	s3,8(sp)
ffffffffc0204b6c:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204b6e:	85ca                	mv	a1,s2
ffffffffc0204b70:	8326                	mv	t1,s1
}
ffffffffc0204b72:	6942                	ld	s2,16(sp)
ffffffffc0204b74:	64e2                	ld	s1,24(sp)
ffffffffc0204b76:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204b78:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0204b7a:	03065633          	divu	a2,a2,a6
ffffffffc0204b7e:	8722                	mv	a4,s0
ffffffffc0204b80:	f9bff0ef          	jal	ra,ffffffffc0204b1a <printnum>
ffffffffc0204b84:	b7f9                	j	ffffffffc0204b52 <printnum+0x38>

ffffffffc0204b86 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0204b86:	7119                	addi	sp,sp,-128
ffffffffc0204b88:	f4a6                	sd	s1,104(sp)
ffffffffc0204b8a:	f0ca                	sd	s2,96(sp)
ffffffffc0204b8c:	e8d2                	sd	s4,80(sp)
ffffffffc0204b8e:	e4d6                	sd	s5,72(sp)
ffffffffc0204b90:	e0da                	sd	s6,64(sp)
ffffffffc0204b92:	fc5e                	sd	s7,56(sp)
ffffffffc0204b94:	f862                	sd	s8,48(sp)
ffffffffc0204b96:	f06a                	sd	s10,32(sp)
ffffffffc0204b98:	fc86                	sd	ra,120(sp)
ffffffffc0204b9a:	f8a2                	sd	s0,112(sp)
ffffffffc0204b9c:	ecce                	sd	s3,88(sp)
ffffffffc0204b9e:	f466                	sd	s9,40(sp)
ffffffffc0204ba0:	ec6e                	sd	s11,24(sp)
ffffffffc0204ba2:	892a                	mv	s2,a0
ffffffffc0204ba4:	84ae                	mv	s1,a1
ffffffffc0204ba6:	8d32                	mv	s10,a2
ffffffffc0204ba8:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0204baa:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204bac:	00002a17          	auipc	s4,0x2
ffffffffc0204bb0:	434a0a13          	addi	s4,s4,1076 # ffffffffc0206fe0 <default_pmm_manager+0x9c8>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204bb4:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204bb8:	00002c17          	auipc	s8,0x2
ffffffffc0204bbc:	580c0c13          	addi	s8,s8,1408 # ffffffffc0207138 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204bc0:	000d4503          	lbu	a0,0(s10) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc0204bc4:	02500793          	li	a5,37
ffffffffc0204bc8:	001d0413          	addi	s0,s10,1
ffffffffc0204bcc:	00f50e63          	beq	a0,a5,ffffffffc0204be8 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0204bd0:	c521                	beqz	a0,ffffffffc0204c18 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204bd2:	02500993          	li	s3,37
ffffffffc0204bd6:	a011                	j	ffffffffc0204bda <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0204bd8:	c121                	beqz	a0,ffffffffc0204c18 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0204bda:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204bdc:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0204bde:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204be0:	fff44503          	lbu	a0,-1(s0)
ffffffffc0204be4:	ff351ae3          	bne	a0,s3,ffffffffc0204bd8 <vprintfmt+0x52>
ffffffffc0204be8:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0204bec:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0204bf0:	4981                	li	s3,0
ffffffffc0204bf2:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0204bf4:	5cfd                	li	s9,-1
ffffffffc0204bf6:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204bf8:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0204bfc:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204bfe:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0204c02:	0ff6f693          	andi	a3,a3,255
ffffffffc0204c06:	00140d13          	addi	s10,s0,1
ffffffffc0204c0a:	20d5e563          	bltu	a1,a3,ffffffffc0204e14 <vprintfmt+0x28e>
ffffffffc0204c0e:	068a                	slli	a3,a3,0x2
ffffffffc0204c10:	96d2                	add	a3,a3,s4
ffffffffc0204c12:	4294                	lw	a3,0(a3)
ffffffffc0204c14:	96d2                	add	a3,a3,s4
ffffffffc0204c16:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0204c18:	70e6                	ld	ra,120(sp)
ffffffffc0204c1a:	7446                	ld	s0,112(sp)
ffffffffc0204c1c:	74a6                	ld	s1,104(sp)
ffffffffc0204c1e:	7906                	ld	s2,96(sp)
ffffffffc0204c20:	69e6                	ld	s3,88(sp)
ffffffffc0204c22:	6a46                	ld	s4,80(sp)
ffffffffc0204c24:	6aa6                	ld	s5,72(sp)
ffffffffc0204c26:	6b06                	ld	s6,64(sp)
ffffffffc0204c28:	7be2                	ld	s7,56(sp)
ffffffffc0204c2a:	7c42                	ld	s8,48(sp)
ffffffffc0204c2c:	7ca2                	ld	s9,40(sp)
ffffffffc0204c2e:	7d02                	ld	s10,32(sp)
ffffffffc0204c30:	6de2                	ld	s11,24(sp)
ffffffffc0204c32:	6109                	addi	sp,sp,128
ffffffffc0204c34:	8082                	ret
    if (lflag >= 2) {
ffffffffc0204c36:	4705                	li	a4,1
ffffffffc0204c38:	008a8593          	addi	a1,s5,8
ffffffffc0204c3c:	01074463          	blt	a4,a6,ffffffffc0204c44 <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc0204c40:	26080363          	beqz	a6,ffffffffc0204ea6 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc0204c44:	000ab603          	ld	a2,0(s5)
ffffffffc0204c48:	46c1                	li	a3,16
ffffffffc0204c4a:	8aae                	mv	s5,a1
ffffffffc0204c4c:	a06d                	j	ffffffffc0204cf6 <vprintfmt+0x170>
            goto reswitch;
ffffffffc0204c4e:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0204c52:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204c54:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204c56:	b765                	j	ffffffffc0204bfe <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc0204c58:	000aa503          	lw	a0,0(s5)
ffffffffc0204c5c:	85a6                	mv	a1,s1
ffffffffc0204c5e:	0aa1                	addi	s5,s5,8
ffffffffc0204c60:	9902                	jalr	s2
            break;
ffffffffc0204c62:	bfb9                	j	ffffffffc0204bc0 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204c64:	4705                	li	a4,1
ffffffffc0204c66:	008a8993          	addi	s3,s5,8
ffffffffc0204c6a:	01074463          	blt	a4,a6,ffffffffc0204c72 <vprintfmt+0xec>
    else if (lflag) {
ffffffffc0204c6e:	22080463          	beqz	a6,ffffffffc0204e96 <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc0204c72:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc0204c76:	24044463          	bltz	s0,ffffffffc0204ebe <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc0204c7a:	8622                	mv	a2,s0
ffffffffc0204c7c:	8ace                	mv	s5,s3
ffffffffc0204c7e:	46a9                	li	a3,10
ffffffffc0204c80:	a89d                	j	ffffffffc0204cf6 <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc0204c82:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204c86:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0204c88:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc0204c8a:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0204c8e:	8fb5                	xor	a5,a5,a3
ffffffffc0204c90:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204c94:	1ad74363          	blt	a4,a3,ffffffffc0204e3a <vprintfmt+0x2b4>
ffffffffc0204c98:	00369793          	slli	a5,a3,0x3
ffffffffc0204c9c:	97e2                	add	a5,a5,s8
ffffffffc0204c9e:	639c                	ld	a5,0(a5)
ffffffffc0204ca0:	18078d63          	beqz	a5,ffffffffc0204e3a <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc0204ca4:	86be                	mv	a3,a5
ffffffffc0204ca6:	00000617          	auipc	a2,0x0
ffffffffc0204caa:	2b260613          	addi	a2,a2,690 # ffffffffc0204f58 <etext+0x2e>
ffffffffc0204cae:	85a6                	mv	a1,s1
ffffffffc0204cb0:	854a                	mv	a0,s2
ffffffffc0204cb2:	240000ef          	jal	ra,ffffffffc0204ef2 <printfmt>
ffffffffc0204cb6:	b729                	j	ffffffffc0204bc0 <vprintfmt+0x3a>
            lflag ++;
ffffffffc0204cb8:	00144603          	lbu	a2,1(s0)
ffffffffc0204cbc:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204cbe:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204cc0:	bf3d                	j	ffffffffc0204bfe <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0204cc2:	4705                	li	a4,1
ffffffffc0204cc4:	008a8593          	addi	a1,s5,8
ffffffffc0204cc8:	01074463          	blt	a4,a6,ffffffffc0204cd0 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0204ccc:	1e080263          	beqz	a6,ffffffffc0204eb0 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc0204cd0:	000ab603          	ld	a2,0(s5)
ffffffffc0204cd4:	46a1                	li	a3,8
ffffffffc0204cd6:	8aae                	mv	s5,a1
ffffffffc0204cd8:	a839                	j	ffffffffc0204cf6 <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc0204cda:	03000513          	li	a0,48
ffffffffc0204cde:	85a6                	mv	a1,s1
ffffffffc0204ce0:	e03e                	sd	a5,0(sp)
ffffffffc0204ce2:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0204ce4:	85a6                	mv	a1,s1
ffffffffc0204ce6:	07800513          	li	a0,120
ffffffffc0204cea:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0204cec:	0aa1                	addi	s5,s5,8
ffffffffc0204cee:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0204cf2:	6782                	ld	a5,0(sp)
ffffffffc0204cf4:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0204cf6:	876e                	mv	a4,s11
ffffffffc0204cf8:	85a6                	mv	a1,s1
ffffffffc0204cfa:	854a                	mv	a0,s2
ffffffffc0204cfc:	e1fff0ef          	jal	ra,ffffffffc0204b1a <printnum>
            break;
ffffffffc0204d00:	b5c1                	j	ffffffffc0204bc0 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204d02:	000ab603          	ld	a2,0(s5)
ffffffffc0204d06:	0aa1                	addi	s5,s5,8
ffffffffc0204d08:	1c060663          	beqz	a2,ffffffffc0204ed4 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc0204d0c:	00160413          	addi	s0,a2,1
ffffffffc0204d10:	17b05c63          	blez	s11,ffffffffc0204e88 <vprintfmt+0x302>
ffffffffc0204d14:	02d00593          	li	a1,45
ffffffffc0204d18:	14b79263          	bne	a5,a1,ffffffffc0204e5c <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204d1c:	00064783          	lbu	a5,0(a2)
ffffffffc0204d20:	0007851b          	sext.w	a0,a5
ffffffffc0204d24:	c905                	beqz	a0,ffffffffc0204d54 <vprintfmt+0x1ce>
ffffffffc0204d26:	000cc563          	bltz	s9,ffffffffc0204d30 <vprintfmt+0x1aa>
ffffffffc0204d2a:	3cfd                	addiw	s9,s9,-1
ffffffffc0204d2c:	036c8263          	beq	s9,s6,ffffffffc0204d50 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc0204d30:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204d32:	18098463          	beqz	s3,ffffffffc0204eba <vprintfmt+0x334>
ffffffffc0204d36:	3781                	addiw	a5,a5,-32
ffffffffc0204d38:	18fbf163          	bleu	a5,s7,ffffffffc0204eba <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc0204d3c:	03f00513          	li	a0,63
ffffffffc0204d40:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204d42:	0405                	addi	s0,s0,1
ffffffffc0204d44:	fff44783          	lbu	a5,-1(s0)
ffffffffc0204d48:	3dfd                	addiw	s11,s11,-1
ffffffffc0204d4a:	0007851b          	sext.w	a0,a5
ffffffffc0204d4e:	fd61                	bnez	a0,ffffffffc0204d26 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc0204d50:	e7b058e3          	blez	s11,ffffffffc0204bc0 <vprintfmt+0x3a>
ffffffffc0204d54:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204d56:	85a6                	mv	a1,s1
ffffffffc0204d58:	02000513          	li	a0,32
ffffffffc0204d5c:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204d5e:	e60d81e3          	beqz	s11,ffffffffc0204bc0 <vprintfmt+0x3a>
ffffffffc0204d62:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204d64:	85a6                	mv	a1,s1
ffffffffc0204d66:	02000513          	li	a0,32
ffffffffc0204d6a:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204d6c:	fe0d94e3          	bnez	s11,ffffffffc0204d54 <vprintfmt+0x1ce>
ffffffffc0204d70:	bd81                	j	ffffffffc0204bc0 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204d72:	4705                	li	a4,1
ffffffffc0204d74:	008a8593          	addi	a1,s5,8
ffffffffc0204d78:	01074463          	blt	a4,a6,ffffffffc0204d80 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc0204d7c:	12080063          	beqz	a6,ffffffffc0204e9c <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc0204d80:	000ab603          	ld	a2,0(s5)
ffffffffc0204d84:	46a9                	li	a3,10
ffffffffc0204d86:	8aae                	mv	s5,a1
ffffffffc0204d88:	b7bd                	j	ffffffffc0204cf6 <vprintfmt+0x170>
ffffffffc0204d8a:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc0204d8e:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204d92:	846a                	mv	s0,s10
ffffffffc0204d94:	b5ad                	j	ffffffffc0204bfe <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc0204d96:	85a6                	mv	a1,s1
ffffffffc0204d98:	02500513          	li	a0,37
ffffffffc0204d9c:	9902                	jalr	s2
            break;
ffffffffc0204d9e:	b50d                	j	ffffffffc0204bc0 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc0204da0:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0204da4:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0204da8:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204daa:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0204dac:	e40dd9e3          	bgez	s11,ffffffffc0204bfe <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0204db0:	8de6                	mv	s11,s9
ffffffffc0204db2:	5cfd                	li	s9,-1
ffffffffc0204db4:	b5a9                	j	ffffffffc0204bfe <vprintfmt+0x78>
            goto reswitch;
ffffffffc0204db6:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc0204dba:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204dbe:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204dc0:	bd3d                	j	ffffffffc0204bfe <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc0204dc2:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0204dc6:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204dca:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0204dcc:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0204dd0:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204dd4:	fcd56ce3          	bltu	a0,a3,ffffffffc0204dac <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc0204dd8:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0204dda:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0204dde:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0204de2:	0196873b          	addw	a4,a3,s9
ffffffffc0204de6:	0017171b          	slliw	a4,a4,0x1
ffffffffc0204dea:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0204dee:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0204df2:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0204df6:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204dfa:	fcd57fe3          	bleu	a3,a0,ffffffffc0204dd8 <vprintfmt+0x252>
ffffffffc0204dfe:	b77d                	j	ffffffffc0204dac <vprintfmt+0x226>
            if (width < 0)
ffffffffc0204e00:	fffdc693          	not	a3,s11
ffffffffc0204e04:	96fd                	srai	a3,a3,0x3f
ffffffffc0204e06:	00ddfdb3          	and	s11,s11,a3
ffffffffc0204e0a:	00144603          	lbu	a2,1(s0)
ffffffffc0204e0e:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204e10:	846a                	mv	s0,s10
ffffffffc0204e12:	b3f5                	j	ffffffffc0204bfe <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc0204e14:	85a6                	mv	a1,s1
ffffffffc0204e16:	02500513          	li	a0,37
ffffffffc0204e1a:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0204e1c:	fff44703          	lbu	a4,-1(s0)
ffffffffc0204e20:	02500793          	li	a5,37
ffffffffc0204e24:	8d22                	mv	s10,s0
ffffffffc0204e26:	d8f70de3          	beq	a4,a5,ffffffffc0204bc0 <vprintfmt+0x3a>
ffffffffc0204e2a:	02500713          	li	a4,37
ffffffffc0204e2e:	1d7d                	addi	s10,s10,-1
ffffffffc0204e30:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0204e34:	fee79de3          	bne	a5,a4,ffffffffc0204e2e <vprintfmt+0x2a8>
ffffffffc0204e38:	b361                	j	ffffffffc0204bc0 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0204e3a:	00002617          	auipc	a2,0x2
ffffffffc0204e3e:	3d660613          	addi	a2,a2,982 # ffffffffc0207210 <error_string+0xd8>
ffffffffc0204e42:	85a6                	mv	a1,s1
ffffffffc0204e44:	854a                	mv	a0,s2
ffffffffc0204e46:	0ac000ef          	jal	ra,ffffffffc0204ef2 <printfmt>
ffffffffc0204e4a:	bb9d                	j	ffffffffc0204bc0 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0204e4c:	00002617          	auipc	a2,0x2
ffffffffc0204e50:	3bc60613          	addi	a2,a2,956 # ffffffffc0207208 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc0204e54:	00002417          	auipc	s0,0x2
ffffffffc0204e58:	3b540413          	addi	s0,s0,949 # ffffffffc0207209 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204e5c:	8532                	mv	a0,a2
ffffffffc0204e5e:	85e6                	mv	a1,s9
ffffffffc0204e60:	e032                	sd	a2,0(sp)
ffffffffc0204e62:	e43e                	sd	a5,8(sp)
ffffffffc0204e64:	bddff0ef          	jal	ra,ffffffffc0204a40 <strnlen>
ffffffffc0204e68:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0204e6c:	6602                	ld	a2,0(sp)
ffffffffc0204e6e:	01b05d63          	blez	s11,ffffffffc0204e88 <vprintfmt+0x302>
ffffffffc0204e72:	67a2                	ld	a5,8(sp)
ffffffffc0204e74:	2781                	sext.w	a5,a5
ffffffffc0204e76:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc0204e78:	6522                	ld	a0,8(sp)
ffffffffc0204e7a:	85a6                	mv	a1,s1
ffffffffc0204e7c:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204e7e:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0204e80:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204e82:	6602                	ld	a2,0(sp)
ffffffffc0204e84:	fe0d9ae3          	bnez	s11,ffffffffc0204e78 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204e88:	00064783          	lbu	a5,0(a2)
ffffffffc0204e8c:	0007851b          	sext.w	a0,a5
ffffffffc0204e90:	e8051be3          	bnez	a0,ffffffffc0204d26 <vprintfmt+0x1a0>
ffffffffc0204e94:	b335                	j	ffffffffc0204bc0 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc0204e96:	000aa403          	lw	s0,0(s5)
ffffffffc0204e9a:	bbf1                	j	ffffffffc0204c76 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc0204e9c:	000ae603          	lwu	a2,0(s5)
ffffffffc0204ea0:	46a9                	li	a3,10
ffffffffc0204ea2:	8aae                	mv	s5,a1
ffffffffc0204ea4:	bd89                	j	ffffffffc0204cf6 <vprintfmt+0x170>
ffffffffc0204ea6:	000ae603          	lwu	a2,0(s5)
ffffffffc0204eaa:	46c1                	li	a3,16
ffffffffc0204eac:	8aae                	mv	s5,a1
ffffffffc0204eae:	b5a1                	j	ffffffffc0204cf6 <vprintfmt+0x170>
ffffffffc0204eb0:	000ae603          	lwu	a2,0(s5)
ffffffffc0204eb4:	46a1                	li	a3,8
ffffffffc0204eb6:	8aae                	mv	s5,a1
ffffffffc0204eb8:	bd3d                	j	ffffffffc0204cf6 <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc0204eba:	9902                	jalr	s2
ffffffffc0204ebc:	b559                	j	ffffffffc0204d42 <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc0204ebe:	85a6                	mv	a1,s1
ffffffffc0204ec0:	02d00513          	li	a0,45
ffffffffc0204ec4:	e03e                	sd	a5,0(sp)
ffffffffc0204ec6:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0204ec8:	8ace                	mv	s5,s3
ffffffffc0204eca:	40800633          	neg	a2,s0
ffffffffc0204ece:	46a9                	li	a3,10
ffffffffc0204ed0:	6782                	ld	a5,0(sp)
ffffffffc0204ed2:	b515                	j	ffffffffc0204cf6 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc0204ed4:	01b05663          	blez	s11,ffffffffc0204ee0 <vprintfmt+0x35a>
ffffffffc0204ed8:	02d00693          	li	a3,45
ffffffffc0204edc:	f6d798e3          	bne	a5,a3,ffffffffc0204e4c <vprintfmt+0x2c6>
ffffffffc0204ee0:	00002417          	auipc	s0,0x2
ffffffffc0204ee4:	32940413          	addi	s0,s0,809 # ffffffffc0207209 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204ee8:	02800513          	li	a0,40
ffffffffc0204eec:	02800793          	li	a5,40
ffffffffc0204ef0:	bd1d                	j	ffffffffc0204d26 <vprintfmt+0x1a0>

ffffffffc0204ef2 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204ef2:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0204ef4:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204ef8:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204efa:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204efc:	ec06                	sd	ra,24(sp)
ffffffffc0204efe:	f83a                	sd	a4,48(sp)
ffffffffc0204f00:	fc3e                	sd	a5,56(sp)
ffffffffc0204f02:	e0c2                	sd	a6,64(sp)
ffffffffc0204f04:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0204f06:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204f08:	c7fff0ef          	jal	ra,ffffffffc0204b86 <vprintfmt>
}
ffffffffc0204f0c:	60e2                	ld	ra,24(sp)
ffffffffc0204f0e:	6161                	addi	sp,sp,80
ffffffffc0204f10:	8082                	ret

ffffffffc0204f12 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc0204f12:	9e3707b7          	lui	a5,0x9e370
ffffffffc0204f16:	2785                	addiw	a5,a5,1
ffffffffc0204f18:	02f5053b          	mulw	a0,a0,a5
    return (hash >> (32 - bits));
ffffffffc0204f1c:	02000793          	li	a5,32
ffffffffc0204f20:	40b785bb          	subw	a1,a5,a1
}
ffffffffc0204f24:	00b5553b          	srlw	a0,a0,a1
ffffffffc0204f28:	8082                	ret
