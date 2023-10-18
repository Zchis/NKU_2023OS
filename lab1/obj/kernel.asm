
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080200000 <kern_entry>:
#include <memlayout.h>

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    la sp, bootstacktop
    80200000:	00004117          	auipc	sp,0x4
    80200004:	00010113          	mv	sp,sp

    tail kern_init
    80200008:	0040006f          	j	8020000c <kern_init>

000000008020000c <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
    8020000c:	00004517          	auipc	a0,0x4
    80200010:	00450513          	addi	a0,a0,4 # 80204010 <edata>
    80200014:	00004617          	auipc	a2,0x4
    80200018:	01460613          	addi	a2,a2,20 # 80204028 <end>
int kern_init(void) {
    8020001c:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
    8020001e:	8e09                	sub	a2,a2,a0
    80200020:	4581                	li	a1,0
int kern_init(void) {
    80200022:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
    80200024:	5d8000ef          	jal	ra,802005fc <memset>

    cons_init();  // init the console
    80200028:	150000ef          	jal	ra,80200178 <cons_init>

    const char *message = "(THU.CST) os is loading ...\n";
    cprintf("%s\n\n", message);
    8020002c:	00001597          	auipc	a1,0x1
    80200030:	a3458593          	addi	a1,a1,-1484 # 80200a60 <etext+0x6>
    80200034:	00001517          	auipc	a0,0x1
    80200038:	a4c50513          	addi	a0,a0,-1460 # 80200a80 <etext+0x26>
    8020003c:	034000ef          	jal	ra,80200070 <cprintf>
    
    print_kerninfo();
    80200040:	064000ef          	jal	ra,802000a4 <print_kerninfo>
    

    // grade_backtrace();

    idt_init();  // init interrupt descriptor table
    80200044:	144000ef          	jal	ra,80200188 <idt_init>
    80200048:	0000                	unimp
    8020004a:	0000                	unimp

    //asm volatile("ebreak");
    asm volatile(".word 0x00000000");   

    // rdtime in mbare mode crashes
    clock_init();  // init clock interrupt
    8020004c:	0e8000ef          	jal	ra,80200134 <clock_init>

    intr_enable();  // enable irq interrupt
    80200050:	132000ef          	jal	ra,80200182 <intr_enable>
    
    while (1)
        ;
    80200054:	a001                	j	80200054 <kern_init+0x48>

0000000080200056 <cputch>:

/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void cputch(int c, int *cnt) {
    80200056:	1141                	addi	sp,sp,-16
    80200058:	e022                	sd	s0,0(sp)
    8020005a:	e406                	sd	ra,8(sp)
    8020005c:	842e                	mv	s0,a1
    cons_putc(c);
    8020005e:	11c000ef          	jal	ra,8020017a <cons_putc>
    (*cnt)++;
    80200062:	401c                	lw	a5,0(s0)
}
    80200064:	60a2                	ld	ra,8(sp)
    (*cnt)++;
    80200066:	2785                	addiw	a5,a5,1
    80200068:	c01c                	sw	a5,0(s0)
}
    8020006a:	6402                	ld	s0,0(sp)
    8020006c:	0141                	addi	sp,sp,16
    8020006e:	8082                	ret

0000000080200070 <cprintf>:
 * cprintf - formats a string and writes it to stdout
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...) {
    80200070:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
    80200072:	02810313          	addi	t1,sp,40 # 80204028 <end>
int cprintf(const char *fmt, ...) {
    80200076:	f42e                	sd	a1,40(sp)
    80200078:	f832                	sd	a2,48(sp)
    8020007a:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    8020007c:	862a                	mv	a2,a0
    8020007e:	004c                	addi	a1,sp,4
    80200080:	00000517          	auipc	a0,0x0
    80200084:	fd650513          	addi	a0,a0,-42 # 80200056 <cputch>
    80200088:	869a                	mv	a3,t1
int cprintf(const char *fmt, ...) {
    8020008a:	ec06                	sd	ra,24(sp)
    8020008c:	e0ba                	sd	a4,64(sp)
    8020008e:	e4be                	sd	a5,72(sp)
    80200090:	e8c2                	sd	a6,80(sp)
    80200092:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
    80200094:	e41a                	sd	t1,8(sp)
    int cnt = 0;
    80200096:	c202                	sw	zero,4(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200098:	5e2000ef          	jal	ra,8020067a <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
    8020009c:	60e2                	ld	ra,24(sp)
    8020009e:	4512                	lw	a0,4(sp)
    802000a0:	6125                	addi	sp,sp,96
    802000a2:	8082                	ret

00000000802000a4 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
    802000a4:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
    802000a6:	00001517          	auipc	a0,0x1
    802000aa:	9e250513          	addi	a0,a0,-1566 # 80200a88 <etext+0x2e>
void print_kerninfo(void) {
    802000ae:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
    802000b0:	fc1ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  entry  0x%016x (virtual)\n", kern_init);
    802000b4:	00000597          	auipc	a1,0x0
    802000b8:	f5858593          	addi	a1,a1,-168 # 8020000c <kern_init>
    802000bc:	00001517          	auipc	a0,0x1
    802000c0:	9ec50513          	addi	a0,a0,-1556 # 80200aa8 <etext+0x4e>
    802000c4:	fadff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  etext  0x%016x (virtual)\n", etext);
    802000c8:	00001597          	auipc	a1,0x1
    802000cc:	99258593          	addi	a1,a1,-1646 # 80200a5a <etext>
    802000d0:	00001517          	auipc	a0,0x1
    802000d4:	9f850513          	addi	a0,a0,-1544 # 80200ac8 <etext+0x6e>
    802000d8:	f99ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  edata  0x%016x (virtual)\n", edata);
    802000dc:	00004597          	auipc	a1,0x4
    802000e0:	f3458593          	addi	a1,a1,-204 # 80204010 <edata>
    802000e4:	00001517          	auipc	a0,0x1
    802000e8:	a0450513          	addi	a0,a0,-1532 # 80200ae8 <etext+0x8e>
    802000ec:	f85ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  end    0x%016x (virtual)\n", end);
    802000f0:	00004597          	auipc	a1,0x4
    802000f4:	f3858593          	addi	a1,a1,-200 # 80204028 <end>
    802000f8:	00001517          	auipc	a0,0x1
    802000fc:	a1050513          	addi	a0,a0,-1520 # 80200b08 <etext+0xae>
    80200100:	f71ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
    80200104:	00004597          	auipc	a1,0x4
    80200108:	32358593          	addi	a1,a1,803 # 80204427 <end+0x3ff>
    8020010c:	00000797          	auipc	a5,0x0
    80200110:	f0078793          	addi	a5,a5,-256 # 8020000c <kern_init>
    80200114:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200118:	43f7d593          	srai	a1,a5,0x3f
}
    8020011c:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020011e:	3ff5f593          	andi	a1,a1,1023
    80200122:	95be                	add	a1,a1,a5
    80200124:	85a9                	srai	a1,a1,0xa
    80200126:	00001517          	auipc	a0,0x1
    8020012a:	a0250513          	addi	a0,a0,-1534 # 80200b28 <etext+0xce>
}
    8020012e:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200130:	f41ff06f          	j	80200070 <cprintf>

0000000080200134 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    80200134:	1141                	addi	sp,sp,-16
    80200136:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
    80200138:	02000793          	li	a5,32
    8020013c:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    80200140:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    80200144:	67e1                	lui	a5,0x18
    80200146:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0x801e7960>
    8020014a:	953e                	add	a0,a0,a5
    8020014c:	0d7000ef          	jal	ra,80200a22 <sbi_set_timer>
}
    80200150:	60a2                	ld	ra,8(sp)
    ticks = 0;
    80200152:	00004797          	auipc	a5,0x4
    80200156:	ec07b723          	sd	zero,-306(a5) # 80204020 <ticks>
    cprintf("++ setup timer interrupts\n");
    8020015a:	00001517          	auipc	a0,0x1
    8020015e:	9fe50513          	addi	a0,a0,-1538 # 80200b58 <etext+0xfe>
}
    80200162:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
    80200164:	f0dff06f          	j	80200070 <cprintf>

0000000080200168 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    80200168:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    8020016c:	67e1                	lui	a5,0x18
    8020016e:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0x801e7960>
    80200172:	953e                	add	a0,a0,a5
    80200174:	0af0006f          	j	80200a22 <sbi_set_timer>

0000000080200178 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
    80200178:	8082                	ret

000000008020017a <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
    8020017a:	0ff57513          	andi	a0,a0,255
    8020017e:	0890006f          	j	80200a06 <sbi_console_putchar>

0000000080200182 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
    80200182:	100167f3          	csrrsi	a5,sstatus,2
    80200186:	8082                	ret

0000000080200188 <idt_init>:
 */
void idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
    80200188:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
    8020018c:	00000797          	auipc	a5,0x0
    80200190:	39478793          	addi	a5,a5,916 # 80200520 <__alltraps>
    80200194:	10579073          	csrw	stvec,a5
}
    80200198:	8082                	ret

000000008020019a <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
    8020019a:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
    8020019c:	1141                	addi	sp,sp,-16
    8020019e:	e022                	sd	s0,0(sp)
    802001a0:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001a2:	00001517          	auipc	a0,0x1
    802001a6:	b0650513          	addi	a0,a0,-1274 # 80200ca8 <etext+0x24e>
void print_regs(struct pushregs *gpr) {
    802001aa:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001ac:	ec5ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
    802001b0:	640c                	ld	a1,8(s0)
    802001b2:	00001517          	auipc	a0,0x1
    802001b6:	b0e50513          	addi	a0,a0,-1266 # 80200cc0 <etext+0x266>
    802001ba:	eb7ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
    802001be:	680c                	ld	a1,16(s0)
    802001c0:	00001517          	auipc	a0,0x1
    802001c4:	b1850513          	addi	a0,a0,-1256 # 80200cd8 <etext+0x27e>
    802001c8:	ea9ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
    802001cc:	6c0c                	ld	a1,24(s0)
    802001ce:	00001517          	auipc	a0,0x1
    802001d2:	b2250513          	addi	a0,a0,-1246 # 80200cf0 <etext+0x296>
    802001d6:	e9bff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
    802001da:	700c                	ld	a1,32(s0)
    802001dc:	00001517          	auipc	a0,0x1
    802001e0:	b2c50513          	addi	a0,a0,-1236 # 80200d08 <etext+0x2ae>
    802001e4:	e8dff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
    802001e8:	740c                	ld	a1,40(s0)
    802001ea:	00001517          	auipc	a0,0x1
    802001ee:	b3650513          	addi	a0,a0,-1226 # 80200d20 <etext+0x2c6>
    802001f2:	e7fff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
    802001f6:	780c                	ld	a1,48(s0)
    802001f8:	00001517          	auipc	a0,0x1
    802001fc:	b4050513          	addi	a0,a0,-1216 # 80200d38 <etext+0x2de>
    80200200:	e71ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
    80200204:	7c0c                	ld	a1,56(s0)
    80200206:	00001517          	auipc	a0,0x1
    8020020a:	b4a50513          	addi	a0,a0,-1206 # 80200d50 <etext+0x2f6>
    8020020e:	e63ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
    80200212:	602c                	ld	a1,64(s0)
    80200214:	00001517          	auipc	a0,0x1
    80200218:	b5450513          	addi	a0,a0,-1196 # 80200d68 <etext+0x30e>
    8020021c:	e55ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
    80200220:	642c                	ld	a1,72(s0)
    80200222:	00001517          	auipc	a0,0x1
    80200226:	b5e50513          	addi	a0,a0,-1186 # 80200d80 <etext+0x326>
    8020022a:	e47ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
    8020022e:	682c                	ld	a1,80(s0)
    80200230:	00001517          	auipc	a0,0x1
    80200234:	b6850513          	addi	a0,a0,-1176 # 80200d98 <etext+0x33e>
    80200238:	e39ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
    8020023c:	6c2c                	ld	a1,88(s0)
    8020023e:	00001517          	auipc	a0,0x1
    80200242:	b7250513          	addi	a0,a0,-1166 # 80200db0 <etext+0x356>
    80200246:	e2bff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
    8020024a:	702c                	ld	a1,96(s0)
    8020024c:	00001517          	auipc	a0,0x1
    80200250:	b7c50513          	addi	a0,a0,-1156 # 80200dc8 <etext+0x36e>
    80200254:	e1dff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
    80200258:	742c                	ld	a1,104(s0)
    8020025a:	00001517          	auipc	a0,0x1
    8020025e:	b8650513          	addi	a0,a0,-1146 # 80200de0 <etext+0x386>
    80200262:	e0fff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
    80200266:	782c                	ld	a1,112(s0)
    80200268:	00001517          	auipc	a0,0x1
    8020026c:	b9050513          	addi	a0,a0,-1136 # 80200df8 <etext+0x39e>
    80200270:	e01ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
    80200274:	7c2c                	ld	a1,120(s0)
    80200276:	00001517          	auipc	a0,0x1
    8020027a:	b9a50513          	addi	a0,a0,-1126 # 80200e10 <etext+0x3b6>
    8020027e:	df3ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
    80200282:	604c                	ld	a1,128(s0)
    80200284:	00001517          	auipc	a0,0x1
    80200288:	ba450513          	addi	a0,a0,-1116 # 80200e28 <etext+0x3ce>
    8020028c:	de5ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
    80200290:	644c                	ld	a1,136(s0)
    80200292:	00001517          	auipc	a0,0x1
    80200296:	bae50513          	addi	a0,a0,-1106 # 80200e40 <etext+0x3e6>
    8020029a:	dd7ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
    8020029e:	684c                	ld	a1,144(s0)
    802002a0:	00001517          	auipc	a0,0x1
    802002a4:	bb850513          	addi	a0,a0,-1096 # 80200e58 <etext+0x3fe>
    802002a8:	dc9ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
    802002ac:	6c4c                	ld	a1,152(s0)
    802002ae:	00001517          	auipc	a0,0x1
    802002b2:	bc250513          	addi	a0,a0,-1086 # 80200e70 <etext+0x416>
    802002b6:	dbbff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
    802002ba:	704c                	ld	a1,160(s0)
    802002bc:	00001517          	auipc	a0,0x1
    802002c0:	bcc50513          	addi	a0,a0,-1076 # 80200e88 <etext+0x42e>
    802002c4:	dadff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
    802002c8:	744c                	ld	a1,168(s0)
    802002ca:	00001517          	auipc	a0,0x1
    802002ce:	bd650513          	addi	a0,a0,-1066 # 80200ea0 <etext+0x446>
    802002d2:	d9fff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
    802002d6:	784c                	ld	a1,176(s0)
    802002d8:	00001517          	auipc	a0,0x1
    802002dc:	be050513          	addi	a0,a0,-1056 # 80200eb8 <etext+0x45e>
    802002e0:	d91ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
    802002e4:	7c4c                	ld	a1,184(s0)
    802002e6:	00001517          	auipc	a0,0x1
    802002ea:	bea50513          	addi	a0,a0,-1046 # 80200ed0 <etext+0x476>
    802002ee:	d83ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
    802002f2:	606c                	ld	a1,192(s0)
    802002f4:	00001517          	auipc	a0,0x1
    802002f8:	bf450513          	addi	a0,a0,-1036 # 80200ee8 <etext+0x48e>
    802002fc:	d75ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
    80200300:	646c                	ld	a1,200(s0)
    80200302:	00001517          	auipc	a0,0x1
    80200306:	bfe50513          	addi	a0,a0,-1026 # 80200f00 <etext+0x4a6>
    8020030a:	d67ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
    8020030e:	686c                	ld	a1,208(s0)
    80200310:	00001517          	auipc	a0,0x1
    80200314:	c0850513          	addi	a0,a0,-1016 # 80200f18 <etext+0x4be>
    80200318:	d59ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
    8020031c:	6c6c                	ld	a1,216(s0)
    8020031e:	00001517          	auipc	a0,0x1
    80200322:	c1250513          	addi	a0,a0,-1006 # 80200f30 <etext+0x4d6>
    80200326:	d4bff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
    8020032a:	706c                	ld	a1,224(s0)
    8020032c:	00001517          	auipc	a0,0x1
    80200330:	c1c50513          	addi	a0,a0,-996 # 80200f48 <etext+0x4ee>
    80200334:	d3dff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
    80200338:	746c                	ld	a1,232(s0)
    8020033a:	00001517          	auipc	a0,0x1
    8020033e:	c2650513          	addi	a0,a0,-986 # 80200f60 <etext+0x506>
    80200342:	d2fff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
    80200346:	786c                	ld	a1,240(s0)
    80200348:	00001517          	auipc	a0,0x1
    8020034c:	c3050513          	addi	a0,a0,-976 # 80200f78 <etext+0x51e>
    80200350:	d21ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200354:	7c6c                	ld	a1,248(s0)
}
    80200356:	6402                	ld	s0,0(sp)
    80200358:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
    8020035a:	00001517          	auipc	a0,0x1
    8020035e:	c3650513          	addi	a0,a0,-970 # 80200f90 <etext+0x536>
}
    80200362:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200364:	d0dff06f          	j	80200070 <cprintf>

0000000080200368 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
    80200368:	1141                	addi	sp,sp,-16
    8020036a:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
    8020036c:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
    8020036e:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
    80200370:	00001517          	auipc	a0,0x1
    80200374:	c3850513          	addi	a0,a0,-968 # 80200fa8 <etext+0x54e>
void print_trapframe(struct trapframe *tf) {
    80200378:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
    8020037a:	cf7ff0ef          	jal	ra,80200070 <cprintf>
    print_regs(&tf->gpr);
    8020037e:	8522                	mv	a0,s0
    80200380:	e1bff0ef          	jal	ra,8020019a <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
    80200384:	10043583          	ld	a1,256(s0)
    80200388:	00001517          	auipc	a0,0x1
    8020038c:	c3850513          	addi	a0,a0,-968 # 80200fc0 <etext+0x566>
    80200390:	ce1ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
    80200394:	10843583          	ld	a1,264(s0)
    80200398:	00001517          	auipc	a0,0x1
    8020039c:	c4050513          	addi	a0,a0,-960 # 80200fd8 <etext+0x57e>
    802003a0:	cd1ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    802003a4:	11043583          	ld	a1,272(s0)
    802003a8:	00001517          	auipc	a0,0x1
    802003ac:	c4850513          	addi	a0,a0,-952 # 80200ff0 <etext+0x596>
    802003b0:	cc1ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
    802003b4:	11843583          	ld	a1,280(s0)
}
    802003b8:	6402                	ld	s0,0(sp)
    802003ba:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
    802003bc:	00001517          	auipc	a0,0x1
    802003c0:	c4c50513          	addi	a0,a0,-948 # 80201008 <etext+0x5ae>
}
    802003c4:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
    802003c6:	cabff06f          	j	80200070 <cprintf>

00000000802003ca <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    802003ca:	11853783          	ld	a5,280(a0)
    802003ce:	577d                	li	a4,-1
    802003d0:	8305                	srli	a4,a4,0x1
    802003d2:	8ff9                	and	a5,a5,a4
    switch (cause) {
    802003d4:	472d                	li	a4,11
    802003d6:	08f76963          	bltu	a4,a5,80200468 <interrupt_handler+0x9e>
    802003da:	00000717          	auipc	a4,0x0
    802003de:	79a70713          	addi	a4,a4,1946 # 80200b74 <etext+0x11a>
    802003e2:	078a                	slli	a5,a5,0x2
    802003e4:	97ba                	add	a5,a5,a4
    802003e6:	439c                	lw	a5,0(a5)
    802003e8:	97ba                	add	a5,a5,a4
    802003ea:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
    802003ec:	00001517          	auipc	a0,0x1
    802003f0:	86c50513          	addi	a0,a0,-1940 # 80200c58 <etext+0x1fe>
    802003f4:	c7dff06f          	j	80200070 <cprintf>
            cprintf("Hypervisor software interrupt\n");
    802003f8:	00001517          	auipc	a0,0x1
    802003fc:	84050513          	addi	a0,a0,-1984 # 80200c38 <etext+0x1de>
    80200400:	c71ff06f          	j	80200070 <cprintf>
            cprintf("User software interrupt\n");
    80200404:	00000517          	auipc	a0,0x0
    80200408:	7f450513          	addi	a0,a0,2036 # 80200bf8 <etext+0x19e>
    8020040c:	c65ff06f          	j	80200070 <cprintf>
            cprintf("Supervisor software interrupt\n");
    80200410:	00001517          	auipc	a0,0x1
    80200414:	80850513          	addi	a0,a0,-2040 # 80200c18 <etext+0x1be>
    80200418:	c59ff06f          	j	80200070 <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
    8020041c:	00001517          	auipc	a0,0x1
    80200420:	86c50513          	addi	a0,a0,-1940 # 80200c88 <etext+0x22e>
    80200424:	c4dff06f          	j	80200070 <cprintf>
void interrupt_handler(struct trapframe *tf) {
    80200428:	1141                	addi	sp,sp,-16
    8020042a:	e022                	sd	s0,0(sp)
    8020042c:	e406                	sd	ra,8(sp)
            clock_set_next_event();
    8020042e:	d3bff0ef          	jal	ra,80200168 <clock_set_next_event>
            ticks++;
    80200432:	00004717          	auipc	a4,0x4
    80200436:	bee70713          	addi	a4,a4,-1042 # 80204020 <ticks>
    8020043a:	631c                	ld	a5,0(a4)
            if(ticks == 100){
    8020043c:	06400693          	li	a3,100
    80200440:	00004417          	auipc	s0,0x4
    80200444:	bd040413          	addi	s0,s0,-1072 # 80204010 <edata>
            ticks++;
    80200448:	0785                	addi	a5,a5,1
    8020044a:	00004617          	auipc	a2,0x4
    8020044e:	bcf63b23          	sd	a5,-1066(a2) # 80204020 <ticks>
            if(ticks == 100){
    80200452:	631c                	ld	a5,0(a4)
    80200454:	00d78c63          	beq	a5,a3,8020046c <interrupt_handler+0xa2>
            if(num == 10){
    80200458:	6018                	ld	a4,0(s0)
    8020045a:	47a9                	li	a5,10
    8020045c:	02f70963          	beq	a4,a5,8020048e <interrupt_handler+0xc4>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    80200460:	60a2                	ld	ra,8(sp)
    80200462:	6402                	ld	s0,0(sp)
    80200464:	0141                	addi	sp,sp,16
    80200466:	8082                	ret
            print_trapframe(tf);
    80200468:	f01ff06f          	j	80200368 <print_trapframe>
            	cprintf("100ticks\n");
    8020046c:	00001517          	auipc	a0,0x1
    80200470:	80c50513          	addi	a0,a0,-2036 # 80200c78 <etext+0x21e>
    80200474:	bfdff0ef          	jal	ra,80200070 <cprintf>
            	num++;
    80200478:	601c                	ld	a5,0(s0)
    8020047a:	0785                	addi	a5,a5,1
    8020047c:	00004717          	auipc	a4,0x4
    80200480:	b8f73a23          	sd	a5,-1132(a4) # 80204010 <edata>
            	ticks = 0;
    80200484:	00004797          	auipc	a5,0x4
    80200488:	b807be23          	sd	zero,-1124(a5) # 80204020 <ticks>
    8020048c:	b7f1                	j	80200458 <interrupt_handler+0x8e>
            	sbi_shutdown();
    8020048e:	5b0000ef          	jal	ra,80200a3e <sbi_shutdown>
            	num = 0;
    80200492:	00004797          	auipc	a5,0x4
    80200496:	b607bf23          	sd	zero,-1154(a5) # 80204010 <edata>
    8020049a:	b7d9                	j	80200460 <interrupt_handler+0x96>

000000008020049c <exception_handler>:

void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
    8020049c:	11853783          	ld	a5,280(a0)
    802004a0:	472d                	li	a4,11
    802004a2:	02f76863          	bltu	a4,a5,802004d2 <exception_handler+0x36>
    802004a6:	4705                	li	a4,1
    802004a8:	00f71733          	sll	a4,a4,a5
    802004ac:	6785                	lui	a5,0x1
    802004ae:	17cd                	addi	a5,a5,-13
    802004b0:	8ff9                	and	a5,a5,a4
    802004b2:	ef99                	bnez	a5,802004d0 <exception_handler+0x34>
void exception_handler(struct trapframe *tf) {
    802004b4:	1141                	addi	sp,sp,-16
    802004b6:	e022                	sd	s0,0(sp)
    802004b8:	e406                	sd	ra,8(sp)
    802004ba:	00877793          	andi	a5,a4,8
    802004be:	842a                	mv	s0,a0
    802004c0:	e3b1                	bnez	a5,80200504 <exception_handler+0x68>
    802004c2:	8b11                	andi	a4,a4,4
    802004c4:	eb09                	bnez	a4,802004d6 <exception_handler+0x3a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    802004c6:	6402                	ld	s0,0(sp)
    802004c8:	60a2                	ld	ra,8(sp)
    802004ca:	0141                	addi	sp,sp,16
            print_trapframe(tf);
    802004cc:	e9dff06f          	j	80200368 <print_trapframe>
    802004d0:	8082                	ret
    802004d2:	e97ff06f          	j	80200368 <print_trapframe>
            cprintf("Exception type:Illegal instruction\n");
    802004d6:	00000517          	auipc	a0,0x0
    802004da:	6d250513          	addi	a0,a0,1746 # 80200ba8 <etext+0x14e>
            cprintf("Breakpoint exception\n");
    802004de:	b93ff0ef          	jal	ra,80200070 <cprintf>
            cprintf("EPC: 0x%08x\n", tf->epc);
    802004e2:	10843583          	ld	a1,264(s0)
    802004e6:	00000517          	auipc	a0,0x0
    802004ea:	6ea50513          	addi	a0,a0,1770 # 80200bd0 <etext+0x176>
    802004ee:	b83ff0ef          	jal	ra,80200070 <cprintf>
            tf->epc += 4;
    802004f2:	10843783          	ld	a5,264(s0)
}
    802004f6:	60a2                	ld	ra,8(sp)
            tf->epc += 4;
    802004f8:	0791                	addi	a5,a5,4
    802004fa:	10f43423          	sd	a5,264(s0)
}
    802004fe:	6402                	ld	s0,0(sp)
    80200500:	0141                	addi	sp,sp,16
    80200502:	8082                	ret
            cprintf("Breakpoint exception\n");
    80200504:	00000517          	auipc	a0,0x0
    80200508:	6dc50513          	addi	a0,a0,1756 # 80200be0 <etext+0x186>
    8020050c:	bfc9                	j	802004de <exception_handler+0x42>

000000008020050e <trap>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
    8020050e:	11853783          	ld	a5,280(a0)
    80200512:	0007c463          	bltz	a5,8020051a <trap+0xc>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
    80200516:	f87ff06f          	j	8020049c <exception_handler>
        interrupt_handler(tf);
    8020051a:	eb1ff06f          	j	802003ca <interrupt_handler>
	...

0000000080200520 <__alltraps>:
    .endm

    .globl __alltraps
.align(2)
__alltraps:
    SAVE_ALL
    80200520:	14011073          	csrw	sscratch,sp
    80200524:	712d                	addi	sp,sp,-288
    80200526:	e002                	sd	zero,0(sp)
    80200528:	e406                	sd	ra,8(sp)
    8020052a:	ec0e                	sd	gp,24(sp)
    8020052c:	f012                	sd	tp,32(sp)
    8020052e:	f416                	sd	t0,40(sp)
    80200530:	f81a                	sd	t1,48(sp)
    80200532:	fc1e                	sd	t2,56(sp)
    80200534:	e0a2                	sd	s0,64(sp)
    80200536:	e4a6                	sd	s1,72(sp)
    80200538:	e8aa                	sd	a0,80(sp)
    8020053a:	ecae                	sd	a1,88(sp)
    8020053c:	f0b2                	sd	a2,96(sp)
    8020053e:	f4b6                	sd	a3,104(sp)
    80200540:	f8ba                	sd	a4,112(sp)
    80200542:	fcbe                	sd	a5,120(sp)
    80200544:	e142                	sd	a6,128(sp)
    80200546:	e546                	sd	a7,136(sp)
    80200548:	e94a                	sd	s2,144(sp)
    8020054a:	ed4e                	sd	s3,152(sp)
    8020054c:	f152                	sd	s4,160(sp)
    8020054e:	f556                	sd	s5,168(sp)
    80200550:	f95a                	sd	s6,176(sp)
    80200552:	fd5e                	sd	s7,184(sp)
    80200554:	e1e2                	sd	s8,192(sp)
    80200556:	e5e6                	sd	s9,200(sp)
    80200558:	e9ea                	sd	s10,208(sp)
    8020055a:	edee                	sd	s11,216(sp)
    8020055c:	f1f2                	sd	t3,224(sp)
    8020055e:	f5f6                	sd	t4,232(sp)
    80200560:	f9fa                	sd	t5,240(sp)
    80200562:	fdfe                	sd	t6,248(sp)
    80200564:	14001473          	csrrw	s0,sscratch,zero
    80200568:	100024f3          	csrr	s1,sstatus
    8020056c:	14102973          	csrr	s2,sepc
    80200570:	143029f3          	csrr	s3,stval
    80200574:	14202a73          	csrr	s4,scause
    80200578:	e822                	sd	s0,16(sp)
    8020057a:	e226                	sd	s1,256(sp)
    8020057c:	e64a                	sd	s2,264(sp)
    8020057e:	ea4e                	sd	s3,272(sp)
    80200580:	ee52                	sd	s4,280(sp)

    move  a0, sp
    80200582:	850a                	mv	a0,sp
    jal trap
    80200584:	f8bff0ef          	jal	ra,8020050e <trap>

0000000080200588 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
    80200588:	6492                	ld	s1,256(sp)
    8020058a:	6932                	ld	s2,264(sp)
    8020058c:	10049073          	csrw	sstatus,s1
    80200590:	14191073          	csrw	sepc,s2
    80200594:	60a2                	ld	ra,8(sp)
    80200596:	61e2                	ld	gp,24(sp)
    80200598:	7202                	ld	tp,32(sp)
    8020059a:	72a2                	ld	t0,40(sp)
    8020059c:	7342                	ld	t1,48(sp)
    8020059e:	73e2                	ld	t2,56(sp)
    802005a0:	6406                	ld	s0,64(sp)
    802005a2:	64a6                	ld	s1,72(sp)
    802005a4:	6546                	ld	a0,80(sp)
    802005a6:	65e6                	ld	a1,88(sp)
    802005a8:	7606                	ld	a2,96(sp)
    802005aa:	76a6                	ld	a3,104(sp)
    802005ac:	7746                	ld	a4,112(sp)
    802005ae:	77e6                	ld	a5,120(sp)
    802005b0:	680a                	ld	a6,128(sp)
    802005b2:	68aa                	ld	a7,136(sp)
    802005b4:	694a                	ld	s2,144(sp)
    802005b6:	69ea                	ld	s3,152(sp)
    802005b8:	7a0a                	ld	s4,160(sp)
    802005ba:	7aaa                	ld	s5,168(sp)
    802005bc:	7b4a                	ld	s6,176(sp)
    802005be:	7bea                	ld	s7,184(sp)
    802005c0:	6c0e                	ld	s8,192(sp)
    802005c2:	6cae                	ld	s9,200(sp)
    802005c4:	6d4e                	ld	s10,208(sp)
    802005c6:	6dee                	ld	s11,216(sp)
    802005c8:	7e0e                	ld	t3,224(sp)
    802005ca:	7eae                	ld	t4,232(sp)
    802005cc:	7f4e                	ld	t5,240(sp)
    802005ce:	7fee                	ld	t6,248(sp)
    802005d0:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
    802005d2:	10200073          	sret

00000000802005d6 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
    802005d6:	c185                	beqz	a1,802005f6 <strnlen+0x20>
    802005d8:	00054783          	lbu	a5,0(a0)
    802005dc:	cf89                	beqz	a5,802005f6 <strnlen+0x20>
    size_t cnt = 0;
    802005de:	4781                	li	a5,0
    802005e0:	a021                	j	802005e8 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
    802005e2:	00074703          	lbu	a4,0(a4)
    802005e6:	c711                	beqz	a4,802005f2 <strnlen+0x1c>
        cnt ++;
    802005e8:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
    802005ea:	00f50733          	add	a4,a0,a5
    802005ee:	fef59ae3          	bne	a1,a5,802005e2 <strnlen+0xc>
    }
    return cnt;
}
    802005f2:	853e                	mv	a0,a5
    802005f4:	8082                	ret
    size_t cnt = 0;
    802005f6:	4781                	li	a5,0
}
    802005f8:	853e                	mv	a0,a5
    802005fa:	8082                	ret

00000000802005fc <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
    802005fc:	ca01                	beqz	a2,8020060c <memset+0x10>
    802005fe:	962a                	add	a2,a2,a0
    char *p = s;
    80200600:	87aa                	mv	a5,a0
        *p ++ = c;
    80200602:	0785                	addi	a5,a5,1
    80200604:	feb78fa3          	sb	a1,-1(a5) # fff <BASE_ADDRESS-0x801ff001>
    while (n -- > 0) {
    80200608:	fec79de3          	bne	a5,a2,80200602 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
    8020060c:	8082                	ret

000000008020060e <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
    8020060e:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    80200612:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
    80200614:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    80200618:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
    8020061a:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
    8020061e:	f022                	sd	s0,32(sp)
    80200620:	ec26                	sd	s1,24(sp)
    80200622:	e84a                	sd	s2,16(sp)
    80200624:	f406                	sd	ra,40(sp)
    80200626:	e44e                	sd	s3,8(sp)
    80200628:	84aa                	mv	s1,a0
    8020062a:	892e                	mv	s2,a1
    8020062c:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
    80200630:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
    80200632:	03067e63          	bleu	a6,a2,8020066e <printnum+0x60>
    80200636:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
    80200638:	00805763          	blez	s0,80200646 <printnum+0x38>
    8020063c:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
    8020063e:	85ca                	mv	a1,s2
    80200640:	854e                	mv	a0,s3
    80200642:	9482                	jalr	s1
        while (-- width > 0)
    80200644:	fc65                	bnez	s0,8020063c <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
    80200646:	1a02                	slli	s4,s4,0x20
    80200648:	020a5a13          	srli	s4,s4,0x20
    8020064c:	00001797          	auipc	a5,0x1
    80200650:	b6478793          	addi	a5,a5,-1180 # 802011b0 <error_string+0x38>
    80200654:	9a3e                	add	s4,s4,a5
}
    80200656:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
    80200658:	000a4503          	lbu	a0,0(s4)
}
    8020065c:	70a2                	ld	ra,40(sp)
    8020065e:	69a2                	ld	s3,8(sp)
    80200660:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
    80200662:	85ca                	mv	a1,s2
    80200664:	8326                	mv	t1,s1
}
    80200666:	6942                	ld	s2,16(sp)
    80200668:	64e2                	ld	s1,24(sp)
    8020066a:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
    8020066c:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
    8020066e:	03065633          	divu	a2,a2,a6
    80200672:	8722                	mv	a4,s0
    80200674:	f9bff0ef          	jal	ra,8020060e <printnum>
    80200678:	b7f9                	j	80200646 <printnum+0x38>

000000008020067a <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
    8020067a:	7119                	addi	sp,sp,-128
    8020067c:	f4a6                	sd	s1,104(sp)
    8020067e:	f0ca                	sd	s2,96(sp)
    80200680:	e8d2                	sd	s4,80(sp)
    80200682:	e4d6                	sd	s5,72(sp)
    80200684:	e0da                	sd	s6,64(sp)
    80200686:	fc5e                	sd	s7,56(sp)
    80200688:	f862                	sd	s8,48(sp)
    8020068a:	f06a                	sd	s10,32(sp)
    8020068c:	fc86                	sd	ra,120(sp)
    8020068e:	f8a2                	sd	s0,112(sp)
    80200690:	ecce                	sd	s3,88(sp)
    80200692:	f466                	sd	s9,40(sp)
    80200694:	ec6e                	sd	s11,24(sp)
    80200696:	892a                	mv	s2,a0
    80200698:	84ae                	mv	s1,a1
    8020069a:	8d32                	mv	s10,a2
    8020069c:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
    8020069e:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
    802006a0:	00001a17          	auipc	s4,0x1
    802006a4:	97ca0a13          	addi	s4,s4,-1668 # 8020101c <etext+0x5c2>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
    802006a8:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    802006ac:	00001c17          	auipc	s8,0x1
    802006b0:	accc0c13          	addi	s8,s8,-1332 # 80201178 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802006b4:	000d4503          	lbu	a0,0(s10)
    802006b8:	02500793          	li	a5,37
    802006bc:	001d0413          	addi	s0,s10,1
    802006c0:	00f50e63          	beq	a0,a5,802006dc <vprintfmt+0x62>
            if (ch == '\0') {
    802006c4:	c521                	beqz	a0,8020070c <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802006c6:	02500993          	li	s3,37
    802006ca:	a011                	j	802006ce <vprintfmt+0x54>
            if (ch == '\0') {
    802006cc:	c121                	beqz	a0,8020070c <vprintfmt+0x92>
            putch(ch, putdat);
    802006ce:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802006d0:	0405                	addi	s0,s0,1
            putch(ch, putdat);
    802006d2:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802006d4:	fff44503          	lbu	a0,-1(s0)
    802006d8:	ff351ae3          	bne	a0,s3,802006cc <vprintfmt+0x52>
    802006dc:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
    802006e0:	02000793          	li	a5,32
        lflag = altflag = 0;
    802006e4:	4981                	li	s3,0
    802006e6:	4801                	li	a6,0
        width = precision = -1;
    802006e8:	5cfd                	li	s9,-1
    802006ea:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
    802006ec:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
    802006f0:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
    802006f2:	fdd6069b          	addiw	a3,a2,-35
    802006f6:	0ff6f693          	andi	a3,a3,255
    802006fa:	00140d13          	addi	s10,s0,1
    802006fe:	20d5e563          	bltu	a1,a3,80200908 <vprintfmt+0x28e>
    80200702:	068a                	slli	a3,a3,0x2
    80200704:	96d2                	add	a3,a3,s4
    80200706:	4294                	lw	a3,0(a3)
    80200708:	96d2                	add	a3,a3,s4
    8020070a:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
    8020070c:	70e6                	ld	ra,120(sp)
    8020070e:	7446                	ld	s0,112(sp)
    80200710:	74a6                	ld	s1,104(sp)
    80200712:	7906                	ld	s2,96(sp)
    80200714:	69e6                	ld	s3,88(sp)
    80200716:	6a46                	ld	s4,80(sp)
    80200718:	6aa6                	ld	s5,72(sp)
    8020071a:	6b06                	ld	s6,64(sp)
    8020071c:	7be2                	ld	s7,56(sp)
    8020071e:	7c42                	ld	s8,48(sp)
    80200720:	7ca2                	ld	s9,40(sp)
    80200722:	7d02                	ld	s10,32(sp)
    80200724:	6de2                	ld	s11,24(sp)
    80200726:	6109                	addi	sp,sp,128
    80200728:	8082                	ret
    if (lflag >= 2) {
    8020072a:	4705                	li	a4,1
    8020072c:	008a8593          	addi	a1,s5,8
    80200730:	01074463          	blt	a4,a6,80200738 <vprintfmt+0xbe>
    else if (lflag) {
    80200734:	26080363          	beqz	a6,8020099a <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
    80200738:	000ab603          	ld	a2,0(s5)
    8020073c:	46c1                	li	a3,16
    8020073e:	8aae                	mv	s5,a1
    80200740:	a06d                	j	802007ea <vprintfmt+0x170>
            goto reswitch;
    80200742:	00144603          	lbu	a2,1(s0)
            altflag = 1;
    80200746:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
    80200748:	846a                	mv	s0,s10
            goto reswitch;
    8020074a:	b765                	j	802006f2 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
    8020074c:	000aa503          	lw	a0,0(s5)
    80200750:	85a6                	mv	a1,s1
    80200752:	0aa1                	addi	s5,s5,8
    80200754:	9902                	jalr	s2
            break;
    80200756:	bfb9                	j	802006b4 <vprintfmt+0x3a>
    if (lflag >= 2) {
    80200758:	4705                	li	a4,1
    8020075a:	008a8993          	addi	s3,s5,8
    8020075e:	01074463          	blt	a4,a6,80200766 <vprintfmt+0xec>
    else if (lflag) {
    80200762:	22080463          	beqz	a6,8020098a <vprintfmt+0x310>
        return va_arg(*ap, long);
    80200766:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
    8020076a:	24044463          	bltz	s0,802009b2 <vprintfmt+0x338>
            num = getint(&ap, lflag);
    8020076e:	8622                	mv	a2,s0
    80200770:	8ace                	mv	s5,s3
    80200772:	46a9                	li	a3,10
    80200774:	a89d                	j	802007ea <vprintfmt+0x170>
            err = va_arg(ap, int);
    80200776:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    8020077a:	4719                	li	a4,6
            err = va_arg(ap, int);
    8020077c:	0aa1                	addi	s5,s5,8
            if (err < 0) {
    8020077e:	41f7d69b          	sraiw	a3,a5,0x1f
    80200782:	8fb5                	xor	a5,a5,a3
    80200784:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200788:	1ad74363          	blt	a4,a3,8020092e <vprintfmt+0x2b4>
    8020078c:	00369793          	slli	a5,a3,0x3
    80200790:	97e2                	add	a5,a5,s8
    80200792:	639c                	ld	a5,0(a5)
    80200794:	18078d63          	beqz	a5,8020092e <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
    80200798:	86be                	mv	a3,a5
    8020079a:	00001617          	auipc	a2,0x1
    8020079e:	ac660613          	addi	a2,a2,-1338 # 80201260 <error_string+0xe8>
    802007a2:	85a6                	mv	a1,s1
    802007a4:	854a                	mv	a0,s2
    802007a6:	240000ef          	jal	ra,802009e6 <printfmt>
    802007aa:	b729                	j	802006b4 <vprintfmt+0x3a>
            lflag ++;
    802007ac:	00144603          	lbu	a2,1(s0)
    802007b0:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
    802007b2:	846a                	mv	s0,s10
            goto reswitch;
    802007b4:	bf3d                	j	802006f2 <vprintfmt+0x78>
    if (lflag >= 2) {
    802007b6:	4705                	li	a4,1
    802007b8:	008a8593          	addi	a1,s5,8
    802007bc:	01074463          	blt	a4,a6,802007c4 <vprintfmt+0x14a>
    else if (lflag) {
    802007c0:	1e080263          	beqz	a6,802009a4 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
    802007c4:	000ab603          	ld	a2,0(s5)
    802007c8:	46a1                	li	a3,8
    802007ca:	8aae                	mv	s5,a1
    802007cc:	a839                	j	802007ea <vprintfmt+0x170>
            putch('0', putdat);
    802007ce:	03000513          	li	a0,48
    802007d2:	85a6                	mv	a1,s1
    802007d4:	e03e                	sd	a5,0(sp)
    802007d6:	9902                	jalr	s2
            putch('x', putdat);
    802007d8:	85a6                	mv	a1,s1
    802007da:	07800513          	li	a0,120
    802007de:	9902                	jalr	s2
            num = (unsigned long long)va_arg(ap, void *);
    802007e0:	0aa1                	addi	s5,s5,8
    802007e2:	ff8ab603          	ld	a2,-8(s5)
            goto number;
    802007e6:	6782                	ld	a5,0(sp)
    802007e8:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
    802007ea:	876e                	mv	a4,s11
    802007ec:	85a6                	mv	a1,s1
    802007ee:	854a                	mv	a0,s2
    802007f0:	e1fff0ef          	jal	ra,8020060e <printnum>
            break;
    802007f4:	b5c1                	j	802006b4 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
    802007f6:	000ab603          	ld	a2,0(s5)
    802007fa:	0aa1                	addi	s5,s5,8
    802007fc:	1c060663          	beqz	a2,802009c8 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
    80200800:	00160413          	addi	s0,a2,1
    80200804:	17b05c63          	blez	s11,8020097c <vprintfmt+0x302>
    80200808:	02d00593          	li	a1,45
    8020080c:	14b79263          	bne	a5,a1,80200950 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200810:	00064783          	lbu	a5,0(a2)
    80200814:	0007851b          	sext.w	a0,a5
    80200818:	c905                	beqz	a0,80200848 <vprintfmt+0x1ce>
    8020081a:	000cc563          	bltz	s9,80200824 <vprintfmt+0x1aa>
    8020081e:	3cfd                	addiw	s9,s9,-1
    80200820:	036c8263          	beq	s9,s6,80200844 <vprintfmt+0x1ca>
                    putch('?', putdat);
    80200824:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
    80200826:	18098463          	beqz	s3,802009ae <vprintfmt+0x334>
    8020082a:	3781                	addiw	a5,a5,-32
    8020082c:	18fbf163          	bleu	a5,s7,802009ae <vprintfmt+0x334>
                    putch('?', putdat);
    80200830:	03f00513          	li	a0,63
    80200834:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200836:	0405                	addi	s0,s0,1
    80200838:	fff44783          	lbu	a5,-1(s0)
    8020083c:	3dfd                	addiw	s11,s11,-1
    8020083e:	0007851b          	sext.w	a0,a5
    80200842:	fd61                	bnez	a0,8020081a <vprintfmt+0x1a0>
            for (; width > 0; width --) {
    80200844:	e7b058e3          	blez	s11,802006b4 <vprintfmt+0x3a>
    80200848:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    8020084a:	85a6                	mv	a1,s1
    8020084c:	02000513          	li	a0,32
    80200850:	9902                	jalr	s2
            for (; width > 0; width --) {
    80200852:	e60d81e3          	beqz	s11,802006b4 <vprintfmt+0x3a>
    80200856:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    80200858:	85a6                	mv	a1,s1
    8020085a:	02000513          	li	a0,32
    8020085e:	9902                	jalr	s2
            for (; width > 0; width --) {
    80200860:	fe0d94e3          	bnez	s11,80200848 <vprintfmt+0x1ce>
    80200864:	bd81                	j	802006b4 <vprintfmt+0x3a>
    if (lflag >= 2) {
    80200866:	4705                	li	a4,1
    80200868:	008a8593          	addi	a1,s5,8
    8020086c:	01074463          	blt	a4,a6,80200874 <vprintfmt+0x1fa>
    else if (lflag) {
    80200870:	12080063          	beqz	a6,80200990 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
    80200874:	000ab603          	ld	a2,0(s5)
    80200878:	46a9                	li	a3,10
    8020087a:	8aae                	mv	s5,a1
    8020087c:	b7bd                	j	802007ea <vprintfmt+0x170>
    8020087e:	00144603          	lbu	a2,1(s0)
            padc = '-';
    80200882:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
    80200886:	846a                	mv	s0,s10
    80200888:	b5ad                	j	802006f2 <vprintfmt+0x78>
            putch(ch, putdat);
    8020088a:	85a6                	mv	a1,s1
    8020088c:	02500513          	li	a0,37
    80200890:	9902                	jalr	s2
            break;
    80200892:	b50d                	j	802006b4 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
    80200894:	000aac83          	lw	s9,0(s5)
            goto process_precision;
    80200898:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
    8020089c:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
    8020089e:	846a                	mv	s0,s10
            if (width < 0)
    802008a0:	e40dd9e3          	bgez	s11,802006f2 <vprintfmt+0x78>
                width = precision, precision = -1;
    802008a4:	8de6                	mv	s11,s9
    802008a6:	5cfd                	li	s9,-1
    802008a8:	b5a9                	j	802006f2 <vprintfmt+0x78>
            goto reswitch;
    802008aa:	00144603          	lbu	a2,1(s0)
            padc = '0';
    802008ae:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
    802008b2:	846a                	mv	s0,s10
            goto reswitch;
    802008b4:	bd3d                	j	802006f2 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
    802008b6:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
    802008ba:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    802008be:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
    802008c0:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
    802008c4:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
    802008c8:	fcd56ce3          	bltu	a0,a3,802008a0 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
    802008cc:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
    802008ce:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
    802008d2:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
    802008d6:	0196873b          	addw	a4,a3,s9
    802008da:	0017171b          	slliw	a4,a4,0x1
    802008de:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
    802008e2:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
    802008e6:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
    802008ea:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
    802008ee:	fcd57fe3          	bleu	a3,a0,802008cc <vprintfmt+0x252>
    802008f2:	b77d                	j	802008a0 <vprintfmt+0x226>
            if (width < 0)
    802008f4:	fffdc693          	not	a3,s11
    802008f8:	96fd                	srai	a3,a3,0x3f
    802008fa:	00ddfdb3          	and	s11,s11,a3
    802008fe:	00144603          	lbu	a2,1(s0)
    80200902:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
    80200904:	846a                	mv	s0,s10
    80200906:	b3f5                	j	802006f2 <vprintfmt+0x78>
            putch('%', putdat);
    80200908:	85a6                	mv	a1,s1
    8020090a:	02500513          	li	a0,37
    8020090e:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
    80200910:	fff44703          	lbu	a4,-1(s0)
    80200914:	02500793          	li	a5,37
    80200918:	8d22                	mv	s10,s0
    8020091a:	d8f70de3          	beq	a4,a5,802006b4 <vprintfmt+0x3a>
    8020091e:	02500713          	li	a4,37
    80200922:	1d7d                	addi	s10,s10,-1
    80200924:	fffd4783          	lbu	a5,-1(s10)
    80200928:	fee79de3          	bne	a5,a4,80200922 <vprintfmt+0x2a8>
    8020092c:	b361                	j	802006b4 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
    8020092e:	00001617          	auipc	a2,0x1
    80200932:	92260613          	addi	a2,a2,-1758 # 80201250 <error_string+0xd8>
    80200936:	85a6                	mv	a1,s1
    80200938:	854a                	mv	a0,s2
    8020093a:	0ac000ef          	jal	ra,802009e6 <printfmt>
    8020093e:	bb9d                	j	802006b4 <vprintfmt+0x3a>
                p = "(null)";
    80200940:	00001617          	auipc	a2,0x1
    80200944:	90860613          	addi	a2,a2,-1784 # 80201248 <error_string+0xd0>
            if (width > 0 && padc != '-') {
    80200948:	00001417          	auipc	s0,0x1
    8020094c:	90140413          	addi	s0,s0,-1791 # 80201249 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200950:	8532                	mv	a0,a2
    80200952:	85e6                	mv	a1,s9
    80200954:	e032                	sd	a2,0(sp)
    80200956:	e43e                	sd	a5,8(sp)
    80200958:	c7fff0ef          	jal	ra,802005d6 <strnlen>
    8020095c:	40ad8dbb          	subw	s11,s11,a0
    80200960:	6602                	ld	a2,0(sp)
    80200962:	01b05d63          	blez	s11,8020097c <vprintfmt+0x302>
    80200966:	67a2                	ld	a5,8(sp)
    80200968:	2781                	sext.w	a5,a5
    8020096a:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
    8020096c:	6522                	ld	a0,8(sp)
    8020096e:	85a6                	mv	a1,s1
    80200970:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200972:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
    80200974:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200976:	6602                	ld	a2,0(sp)
    80200978:	fe0d9ae3          	bnez	s11,8020096c <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    8020097c:	00064783          	lbu	a5,0(a2)
    80200980:	0007851b          	sext.w	a0,a5
    80200984:	e8051be3          	bnez	a0,8020081a <vprintfmt+0x1a0>
    80200988:	b335                	j	802006b4 <vprintfmt+0x3a>
        return va_arg(*ap, int);
    8020098a:	000aa403          	lw	s0,0(s5)
    8020098e:	bbf1                	j	8020076a <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
    80200990:	000ae603          	lwu	a2,0(s5)
    80200994:	46a9                	li	a3,10
    80200996:	8aae                	mv	s5,a1
    80200998:	bd89                	j	802007ea <vprintfmt+0x170>
    8020099a:	000ae603          	lwu	a2,0(s5)
    8020099e:	46c1                	li	a3,16
    802009a0:	8aae                	mv	s5,a1
    802009a2:	b5a1                	j	802007ea <vprintfmt+0x170>
    802009a4:	000ae603          	lwu	a2,0(s5)
    802009a8:	46a1                	li	a3,8
    802009aa:	8aae                	mv	s5,a1
    802009ac:	bd3d                	j	802007ea <vprintfmt+0x170>
                    putch(ch, putdat);
    802009ae:	9902                	jalr	s2
    802009b0:	b559                	j	80200836 <vprintfmt+0x1bc>
                putch('-', putdat);
    802009b2:	85a6                	mv	a1,s1
    802009b4:	02d00513          	li	a0,45
    802009b8:	e03e                	sd	a5,0(sp)
    802009ba:	9902                	jalr	s2
                num = -(long long)num;
    802009bc:	8ace                	mv	s5,s3
    802009be:	40800633          	neg	a2,s0
    802009c2:	46a9                	li	a3,10
    802009c4:	6782                	ld	a5,0(sp)
    802009c6:	b515                	j	802007ea <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
    802009c8:	01b05663          	blez	s11,802009d4 <vprintfmt+0x35a>
    802009cc:	02d00693          	li	a3,45
    802009d0:	f6d798e3          	bne	a5,a3,80200940 <vprintfmt+0x2c6>
    802009d4:	00001417          	auipc	s0,0x1
    802009d8:	87540413          	addi	s0,s0,-1931 # 80201249 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802009dc:	02800513          	li	a0,40
    802009e0:	02800793          	li	a5,40
    802009e4:	bd1d                	j	8020081a <vprintfmt+0x1a0>

00000000802009e6 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802009e6:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
    802009e8:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802009ec:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
    802009ee:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802009f0:	ec06                	sd	ra,24(sp)
    802009f2:	f83a                	sd	a4,48(sp)
    802009f4:	fc3e                	sd	a5,56(sp)
    802009f6:	e0c2                	sd	a6,64(sp)
    802009f8:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
    802009fa:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
    802009fc:	c7fff0ef          	jal	ra,8020067a <vprintfmt>
}
    80200a00:	60e2                	ld	ra,24(sp)
    80200a02:	6161                	addi	sp,sp,80
    80200a04:	8082                	ret

0000000080200a06 <sbi_console_putchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
    80200a06:	00003797          	auipc	a5,0x3
    80200a0a:	5fa78793          	addi	a5,a5,1530 # 80204000 <bootstacktop>
    __asm__ volatile (
    80200a0e:	6398                	ld	a4,0(a5)
    80200a10:	4781                	li	a5,0
    80200a12:	88ba                	mv	a7,a4
    80200a14:	852a                	mv	a0,a0
    80200a16:	85be                	mv	a1,a5
    80200a18:	863e                	mv	a2,a5
    80200a1a:	00000073          	ecall
    80200a1e:	87aa                	mv	a5,a0
}
    80200a20:	8082                	ret

0000000080200a22 <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
    80200a22:	00003797          	auipc	a5,0x3
    80200a26:	5f678793          	addi	a5,a5,1526 # 80204018 <SBI_SET_TIMER>
    __asm__ volatile (
    80200a2a:	6398                	ld	a4,0(a5)
    80200a2c:	4781                	li	a5,0
    80200a2e:	88ba                	mv	a7,a4
    80200a30:	852a                	mv	a0,a0
    80200a32:	85be                	mv	a1,a5
    80200a34:	863e                	mv	a2,a5
    80200a36:	00000073          	ecall
    80200a3a:	87aa                	mv	a5,a0
}
    80200a3c:	8082                	ret

0000000080200a3e <sbi_shutdown>:


void sbi_shutdown(void)
{
    sbi_call(SBI_SHUTDOWN,0,0,0);
    80200a3e:	00003797          	auipc	a5,0x3
    80200a42:	5ca78793          	addi	a5,a5,1482 # 80204008 <SBI_SHUTDOWN>
    __asm__ volatile (
    80200a46:	6398                	ld	a4,0(a5)
    80200a48:	4781                	li	a5,0
    80200a4a:	88ba                	mv	a7,a4
    80200a4c:	853e                	mv	a0,a5
    80200a4e:	85be                	mv	a1,a5
    80200a50:	863e                	mv	a2,a5
    80200a52:	00000073          	ecall
    80200a56:	87aa                	mv	a5,a0
    80200a58:	8082                	ret
