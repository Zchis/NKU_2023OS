
obj/__user_divzero.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <__panic>:
#include <stdio.h>
#include <ulib.h>
#include <error.h>

void
__panic(const char *file, int line, const char *fmt, ...) {
  800020:	715d                	addi	sp,sp,-80
  800022:	e822                	sd	s0,16(sp)
  800024:	fc3e                	sd	a5,56(sp)
  800026:	8432                	mv	s0,a2
    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  800028:	103c                	addi	a5,sp,40
    cprintf("user panic at %s:%d:\n    ", file, line);
  80002a:	862e                	mv	a2,a1
  80002c:	85aa                	mv	a1,a0
  80002e:	00000517          	auipc	a0,0x0
  800032:	56a50513          	addi	a0,a0,1386 # 800598 <main+0x3a>
__panic(const char *file, int line, const char *fmt, ...) {
  800036:	ec06                	sd	ra,24(sp)
  800038:	f436                	sd	a3,40(sp)
  80003a:	f83a                	sd	a4,48(sp)
  80003c:	e0c2                	sd	a6,64(sp)
  80003e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800040:	e43e                	sd	a5,8(sp)
    cprintf("user panic at %s:%d:\n    ", file, line);
  800042:	0be000ef          	jal	ra,800100 <cprintf>
    vcprintf(fmt, ap);
  800046:	65a2                	ld	a1,8(sp)
  800048:	8522                	mv	a0,s0
  80004a:	096000ef          	jal	ra,8000e0 <vcprintf>
    cprintf("\n");
  80004e:	00000517          	auipc	a0,0x0
  800052:	56a50513          	addi	a0,a0,1386 # 8005b8 <main+0x5a>
  800056:	0aa000ef          	jal	ra,800100 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  80005a:	5559                	li	a0,-10
  80005c:	04e000ef          	jal	ra,8000aa <exit>

0000000000800060 <syscall>:
#include <syscall.h>

#define MAX_ARGS            5

static inline int
syscall(int64_t num, ...) {
  800060:	7175                	addi	sp,sp,-144
  800062:	f8ba                	sd	a4,112(sp)
    va_list ap;
    va_start(ap, num);
    uint64_t a[MAX_ARGS];
    int i, ret;
    for (i = 0; i < MAX_ARGS; i ++) {
        a[i] = va_arg(ap, uint64_t);
  800064:	e0ba                	sd	a4,64(sp)
  800066:	0118                	addi	a4,sp,128
syscall(int64_t num, ...) {
  800068:	e42a                	sd	a0,8(sp)
  80006a:	ecae                	sd	a1,88(sp)
  80006c:	f0b2                	sd	a2,96(sp)
  80006e:	f4b6                	sd	a3,104(sp)
  800070:	fcbe                	sd	a5,120(sp)
  800072:	e142                	sd	a6,128(sp)
  800074:	e546                	sd	a7,136(sp)
        a[i] = va_arg(ap, uint64_t);
  800076:	f42e                	sd	a1,40(sp)
  800078:	f832                	sd	a2,48(sp)
  80007a:	fc36                	sd	a3,56(sp)
  80007c:	f03a                	sd	a4,32(sp)
  80007e:	e4be                	sd	a5,72(sp)
    }
    va_end(ap);

    asm volatile (
  800080:	6522                	ld	a0,8(sp)
  800082:	75a2                	ld	a1,40(sp)
  800084:	7642                	ld	a2,48(sp)
  800086:	76e2                	ld	a3,56(sp)
  800088:	6706                	ld	a4,64(sp)
  80008a:	67a6                	ld	a5,72(sp)
  80008c:	00000073          	ecall
  800090:	00a13e23          	sd	a0,28(sp)
        "sd a0, %0"
        : "=m" (ret)
        : "m"(num), "m"(a[0]), "m"(a[1]), "m"(a[2]), "m"(a[3]), "m"(a[4])
        :"memory");
    return ret;
}
  800094:	4572                	lw	a0,28(sp)
  800096:	6149                	addi	sp,sp,144
  800098:	8082                	ret

000000000080009a <sys_exit>:

int
sys_exit(int64_t error_code) {
    return syscall(SYS_exit, error_code);
  80009a:	85aa                	mv	a1,a0
  80009c:	4505                	li	a0,1
  80009e:	fc3ff06f          	j	800060 <syscall>

00000000008000a2 <sys_putc>:
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
    return syscall(SYS_putc, c);
  8000a2:	85aa                	mv	a1,a0
  8000a4:	4579                	li	a0,30
  8000a6:	fbbff06f          	j	800060 <syscall>

00000000008000aa <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8000aa:	1141                	addi	sp,sp,-16
  8000ac:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  8000ae:	fedff0ef          	jal	ra,80009a <sys_exit>
    cprintf("BUG: exit failed.\n");
  8000b2:	00000517          	auipc	a0,0x0
  8000b6:	50e50513          	addi	a0,a0,1294 # 8005c0 <main+0x62>
  8000ba:	046000ef          	jal	ra,800100 <cprintf>
    while (1);
  8000be:	a001                	j	8000be <exit+0x14>

00000000008000c0 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  8000c0:	074000ef          	jal	ra,800134 <umain>
1:  j 1b
  8000c4:	a001                	j	8000c4 <_start+0x4>

00000000008000c6 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  8000c6:	1141                	addi	sp,sp,-16
  8000c8:	e022                	sd	s0,0(sp)
  8000ca:	e406                	sd	ra,8(sp)
  8000cc:	842e                	mv	s0,a1
    sys_putc(c);
  8000ce:	fd5ff0ef          	jal	ra,8000a2 <sys_putc>
    (*cnt) ++;
  8000d2:	401c                	lw	a5,0(s0)
}
  8000d4:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
  8000d6:	2785                	addiw	a5,a5,1
  8000d8:	c01c                	sw	a5,0(s0)
}
  8000da:	6402                	ld	s0,0(sp)
  8000dc:	0141                	addi	sp,sp,16
  8000de:	8082                	ret

00000000008000e0 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  8000e0:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000e2:	86ae                	mv	a3,a1
  8000e4:	862a                	mv	a2,a0
  8000e6:	006c                	addi	a1,sp,12
  8000e8:	00000517          	auipc	a0,0x0
  8000ec:	fde50513          	addi	a0,a0,-34 # 8000c6 <cputch>
vcprintf(const char *fmt, va_list ap) {
  8000f0:	ec06                	sd	ra,24(sp)
    int cnt = 0;
  8000f2:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000f4:	0de000ef          	jal	ra,8001d2 <vprintfmt>
    return cnt;
}
  8000f8:	60e2                	ld	ra,24(sp)
  8000fa:	4532                	lw	a0,12(sp)
  8000fc:	6105                	addi	sp,sp,32
  8000fe:	8082                	ret

0000000000800100 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  800100:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  800102:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  800106:	f42e                	sd	a1,40(sp)
  800108:	f832                	sd	a2,48(sp)
  80010a:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  80010c:	862a                	mv	a2,a0
  80010e:	004c                	addi	a1,sp,4
  800110:	00000517          	auipc	a0,0x0
  800114:	fb650513          	addi	a0,a0,-74 # 8000c6 <cputch>
  800118:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
  80011a:	ec06                	sd	ra,24(sp)
  80011c:	e0ba                	sd	a4,64(sp)
  80011e:	e4be                	sd	a5,72(sp)
  800120:	e8c2                	sd	a6,80(sp)
  800122:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
  800124:	e41a                	sd	t1,8(sp)
    int cnt = 0;
  800126:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800128:	0aa000ef          	jal	ra,8001d2 <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  80012c:	60e2                	ld	ra,24(sp)
  80012e:	4512                	lw	a0,4(sp)
  800130:	6125                	addi	sp,sp,96
  800132:	8082                	ret

0000000000800134 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  800134:	1141                	addi	sp,sp,-16
  800136:	e406                	sd	ra,8(sp)
    int ret = main();
  800138:	426000ef          	jal	ra,80055e <main>
    exit(ret);
  80013c:	f6fff0ef          	jal	ra,8000aa <exit>

0000000000800140 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  800140:	c185                	beqz	a1,800160 <strnlen+0x20>
  800142:	00054783          	lbu	a5,0(a0)
  800146:	cf89                	beqz	a5,800160 <strnlen+0x20>
    size_t cnt = 0;
  800148:	4781                	li	a5,0
  80014a:	a021                	j	800152 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
  80014c:	00074703          	lbu	a4,0(a4)
  800150:	c711                	beqz	a4,80015c <strnlen+0x1c>
        cnt ++;
  800152:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800154:	00f50733          	add	a4,a0,a5
  800158:	fef59ae3          	bne	a1,a5,80014c <strnlen+0xc>
    }
    return cnt;
}
  80015c:	853e                	mv	a0,a5
  80015e:	8082                	ret
    size_t cnt = 0;
  800160:	4781                	li	a5,0
}
  800162:	853e                	mv	a0,a5
  800164:	8082                	ret

0000000000800166 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800166:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80016a:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  80016c:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800170:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  800172:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  800176:	f022                	sd	s0,32(sp)
  800178:	ec26                	sd	s1,24(sp)
  80017a:	e84a                	sd	s2,16(sp)
  80017c:	f406                	sd	ra,40(sp)
  80017e:	e44e                	sd	s3,8(sp)
  800180:	84aa                	mv	s1,a0
  800182:	892e                	mv	s2,a1
  800184:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  800188:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  80018a:	03067e63          	bleu	a6,a2,8001c6 <printnum+0x60>
  80018e:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800190:	00805763          	blez	s0,80019e <printnum+0x38>
  800194:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800196:	85ca                	mv	a1,s2
  800198:	854e                	mv	a0,s3
  80019a:	9482                	jalr	s1
        while (-- width > 0)
  80019c:	fc65                	bnez	s0,800194 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  80019e:	1a02                	slli	s4,s4,0x20
  8001a0:	020a5a13          	srli	s4,s4,0x20
  8001a4:	00000797          	auipc	a5,0x0
  8001a8:	65478793          	addi	a5,a5,1620 # 8007f8 <error_string+0xc8>
  8001ac:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001ae:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001b0:	000a4503          	lbu	a0,0(s4)
}
  8001b4:	70a2                	ld	ra,40(sp)
  8001b6:	69a2                	ld	s3,8(sp)
  8001b8:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001ba:	85ca                	mv	a1,s2
  8001bc:	8326                	mv	t1,s1
}
  8001be:	6942                	ld	s2,16(sp)
  8001c0:	64e2                	ld	s1,24(sp)
  8001c2:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001c4:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
  8001c6:	03065633          	divu	a2,a2,a6
  8001ca:	8722                	mv	a4,s0
  8001cc:	f9bff0ef          	jal	ra,800166 <printnum>
  8001d0:	b7f9                	j	80019e <printnum+0x38>

00000000008001d2 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001d2:	7119                	addi	sp,sp,-128
  8001d4:	f4a6                	sd	s1,104(sp)
  8001d6:	f0ca                	sd	s2,96(sp)
  8001d8:	e8d2                	sd	s4,80(sp)
  8001da:	e4d6                	sd	s5,72(sp)
  8001dc:	e0da                	sd	s6,64(sp)
  8001de:	fc5e                	sd	s7,56(sp)
  8001e0:	f862                	sd	s8,48(sp)
  8001e2:	f06a                	sd	s10,32(sp)
  8001e4:	fc86                	sd	ra,120(sp)
  8001e6:	f8a2                	sd	s0,112(sp)
  8001e8:	ecce                	sd	s3,88(sp)
  8001ea:	f466                	sd	s9,40(sp)
  8001ec:	ec6e                	sd	s11,24(sp)
  8001ee:	892a                	mv	s2,a0
  8001f0:	84ae                	mv	s1,a1
  8001f2:	8d32                	mv	s10,a2
  8001f4:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  8001f6:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  8001f8:	00000a17          	auipc	s4,0x0
  8001fc:	3dca0a13          	addi	s4,s4,988 # 8005d4 <main+0x76>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
  800200:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800204:	00000c17          	auipc	s8,0x0
  800208:	52cc0c13          	addi	s8,s8,1324 # 800730 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80020c:	000d4503          	lbu	a0,0(s10)
  800210:	02500793          	li	a5,37
  800214:	001d0413          	addi	s0,s10,1
  800218:	00f50e63          	beq	a0,a5,800234 <vprintfmt+0x62>
            if (ch == '\0') {
  80021c:	c521                	beqz	a0,800264 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80021e:	02500993          	li	s3,37
  800222:	a011                	j	800226 <vprintfmt+0x54>
            if (ch == '\0') {
  800224:	c121                	beqz	a0,800264 <vprintfmt+0x92>
            putch(ch, putdat);
  800226:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800228:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  80022a:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80022c:	fff44503          	lbu	a0,-1(s0)
  800230:	ff351ae3          	bne	a0,s3,800224 <vprintfmt+0x52>
  800234:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  800238:	02000793          	li	a5,32
        lflag = altflag = 0;
  80023c:	4981                	li	s3,0
  80023e:	4801                	li	a6,0
        width = precision = -1;
  800240:	5cfd                	li	s9,-1
  800242:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
  800244:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
  800248:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
  80024a:	fdd6069b          	addiw	a3,a2,-35
  80024e:	0ff6f693          	andi	a3,a3,255
  800252:	00140d13          	addi	s10,s0,1
  800256:	20d5e563          	bltu	a1,a3,800460 <vprintfmt+0x28e>
  80025a:	068a                	slli	a3,a3,0x2
  80025c:	96d2                	add	a3,a3,s4
  80025e:	4294                	lw	a3,0(a3)
  800260:	96d2                	add	a3,a3,s4
  800262:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  800264:	70e6                	ld	ra,120(sp)
  800266:	7446                	ld	s0,112(sp)
  800268:	74a6                	ld	s1,104(sp)
  80026a:	7906                	ld	s2,96(sp)
  80026c:	69e6                	ld	s3,88(sp)
  80026e:	6a46                	ld	s4,80(sp)
  800270:	6aa6                	ld	s5,72(sp)
  800272:	6b06                	ld	s6,64(sp)
  800274:	7be2                	ld	s7,56(sp)
  800276:	7c42                	ld	s8,48(sp)
  800278:	7ca2                	ld	s9,40(sp)
  80027a:	7d02                	ld	s10,32(sp)
  80027c:	6de2                	ld	s11,24(sp)
  80027e:	6109                	addi	sp,sp,128
  800280:	8082                	ret
    if (lflag >= 2) {
  800282:	4705                	li	a4,1
  800284:	008a8593          	addi	a1,s5,8
  800288:	01074463          	blt	a4,a6,800290 <vprintfmt+0xbe>
    else if (lflag) {
  80028c:	26080363          	beqz	a6,8004f2 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
  800290:	000ab603          	ld	a2,0(s5)
  800294:	46c1                	li	a3,16
  800296:	8aae                	mv	s5,a1
  800298:	a06d                	j	800342 <vprintfmt+0x170>
            goto reswitch;
  80029a:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  80029e:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
  8002a0:	846a                	mv	s0,s10
            goto reswitch;
  8002a2:	b765                	j	80024a <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
  8002a4:	000aa503          	lw	a0,0(s5)
  8002a8:	85a6                	mv	a1,s1
  8002aa:	0aa1                	addi	s5,s5,8
  8002ac:	9902                	jalr	s2
            break;
  8002ae:	bfb9                	j	80020c <vprintfmt+0x3a>
    if (lflag >= 2) {
  8002b0:	4705                	li	a4,1
  8002b2:	008a8993          	addi	s3,s5,8
  8002b6:	01074463          	blt	a4,a6,8002be <vprintfmt+0xec>
    else if (lflag) {
  8002ba:	22080463          	beqz	a6,8004e2 <vprintfmt+0x310>
        return va_arg(*ap, long);
  8002be:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
  8002c2:	24044463          	bltz	s0,80050a <vprintfmt+0x338>
            num = getint(&ap, lflag);
  8002c6:	8622                	mv	a2,s0
  8002c8:	8ace                	mv	s5,s3
  8002ca:	46a9                	li	a3,10
  8002cc:	a89d                	j	800342 <vprintfmt+0x170>
            err = va_arg(ap, int);
  8002ce:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8002d2:	4761                	li	a4,24
            err = va_arg(ap, int);
  8002d4:	0aa1                	addi	s5,s5,8
            if (err < 0) {
  8002d6:	41f7d69b          	sraiw	a3,a5,0x1f
  8002da:	8fb5                	xor	a5,a5,a3
  8002dc:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8002e0:	1ad74363          	blt	a4,a3,800486 <vprintfmt+0x2b4>
  8002e4:	00369793          	slli	a5,a3,0x3
  8002e8:	97e2                	add	a5,a5,s8
  8002ea:	639c                	ld	a5,0(a5)
  8002ec:	18078d63          	beqz	a5,800486 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
  8002f0:	86be                	mv	a3,a5
  8002f2:	00000617          	auipc	a2,0x0
  8002f6:	5f660613          	addi	a2,a2,1526 # 8008e8 <error_string+0x1b8>
  8002fa:	85a6                	mv	a1,s1
  8002fc:	854a                	mv	a0,s2
  8002fe:	240000ef          	jal	ra,80053e <printfmt>
  800302:	b729                	j	80020c <vprintfmt+0x3a>
            lflag ++;
  800304:	00144603          	lbu	a2,1(s0)
  800308:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
  80030a:	846a                	mv	s0,s10
            goto reswitch;
  80030c:	bf3d                	j	80024a <vprintfmt+0x78>
    if (lflag >= 2) {
  80030e:	4705                	li	a4,1
  800310:	008a8593          	addi	a1,s5,8
  800314:	01074463          	blt	a4,a6,80031c <vprintfmt+0x14a>
    else if (lflag) {
  800318:	1e080263          	beqz	a6,8004fc <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
  80031c:	000ab603          	ld	a2,0(s5)
  800320:	46a1                	li	a3,8
  800322:	8aae                	mv	s5,a1
  800324:	a839                	j	800342 <vprintfmt+0x170>
            putch('0', putdat);
  800326:	03000513          	li	a0,48
  80032a:	85a6                	mv	a1,s1
  80032c:	e03e                	sd	a5,0(sp)
  80032e:	9902                	jalr	s2
            putch('x', putdat);
  800330:	85a6                	mv	a1,s1
  800332:	07800513          	li	a0,120
  800336:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800338:	0aa1                	addi	s5,s5,8
  80033a:	ff8ab603          	ld	a2,-8(s5)
            goto number;
  80033e:	6782                	ld	a5,0(sp)
  800340:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
  800342:	876e                	mv	a4,s11
  800344:	85a6                	mv	a1,s1
  800346:	854a                	mv	a0,s2
  800348:	e1fff0ef          	jal	ra,800166 <printnum>
            break;
  80034c:	b5c1                	j	80020c <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
  80034e:	000ab603          	ld	a2,0(s5)
  800352:	0aa1                	addi	s5,s5,8
  800354:	1c060663          	beqz	a2,800520 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
  800358:	00160413          	addi	s0,a2,1
  80035c:	17b05c63          	blez	s11,8004d4 <vprintfmt+0x302>
  800360:	02d00593          	li	a1,45
  800364:	14b79263          	bne	a5,a1,8004a8 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800368:	00064783          	lbu	a5,0(a2)
  80036c:	0007851b          	sext.w	a0,a5
  800370:	c905                	beqz	a0,8003a0 <vprintfmt+0x1ce>
  800372:	000cc563          	bltz	s9,80037c <vprintfmt+0x1aa>
  800376:	3cfd                	addiw	s9,s9,-1
  800378:	036c8263          	beq	s9,s6,80039c <vprintfmt+0x1ca>
                    putch('?', putdat);
  80037c:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  80037e:	18098463          	beqz	s3,800506 <vprintfmt+0x334>
  800382:	3781                	addiw	a5,a5,-32
  800384:	18fbf163          	bleu	a5,s7,800506 <vprintfmt+0x334>
                    putch('?', putdat);
  800388:	03f00513          	li	a0,63
  80038c:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80038e:	0405                	addi	s0,s0,1
  800390:	fff44783          	lbu	a5,-1(s0)
  800394:	3dfd                	addiw	s11,s11,-1
  800396:	0007851b          	sext.w	a0,a5
  80039a:	fd61                	bnez	a0,800372 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
  80039c:	e7b058e3          	blez	s11,80020c <vprintfmt+0x3a>
  8003a0:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003a2:	85a6                	mv	a1,s1
  8003a4:	02000513          	li	a0,32
  8003a8:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003aa:	e60d81e3          	beqz	s11,80020c <vprintfmt+0x3a>
  8003ae:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003b0:	85a6                	mv	a1,s1
  8003b2:	02000513          	li	a0,32
  8003b6:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003b8:	fe0d94e3          	bnez	s11,8003a0 <vprintfmt+0x1ce>
  8003bc:	bd81                	j	80020c <vprintfmt+0x3a>
    if (lflag >= 2) {
  8003be:	4705                	li	a4,1
  8003c0:	008a8593          	addi	a1,s5,8
  8003c4:	01074463          	blt	a4,a6,8003cc <vprintfmt+0x1fa>
    else if (lflag) {
  8003c8:	12080063          	beqz	a6,8004e8 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
  8003cc:	000ab603          	ld	a2,0(s5)
  8003d0:	46a9                	li	a3,10
  8003d2:	8aae                	mv	s5,a1
  8003d4:	b7bd                	j	800342 <vprintfmt+0x170>
  8003d6:	00144603          	lbu	a2,1(s0)
            padc = '-';
  8003da:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
  8003de:	846a                	mv	s0,s10
  8003e0:	b5ad                	j	80024a <vprintfmt+0x78>
            putch(ch, putdat);
  8003e2:	85a6                	mv	a1,s1
  8003e4:	02500513          	li	a0,37
  8003e8:	9902                	jalr	s2
            break;
  8003ea:	b50d                	j	80020c <vprintfmt+0x3a>
            precision = va_arg(ap, int);
  8003ec:	000aac83          	lw	s9,0(s5)
            goto process_precision;
  8003f0:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  8003f4:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
  8003f6:	846a                	mv	s0,s10
            if (width < 0)
  8003f8:	e40dd9e3          	bgez	s11,80024a <vprintfmt+0x78>
                width = precision, precision = -1;
  8003fc:	8de6                	mv	s11,s9
  8003fe:	5cfd                	li	s9,-1
  800400:	b5a9                	j	80024a <vprintfmt+0x78>
            goto reswitch;
  800402:	00144603          	lbu	a2,1(s0)
            padc = '0';
  800406:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
  80040a:	846a                	mv	s0,s10
            goto reswitch;
  80040c:	bd3d                	j	80024a <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
  80040e:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
  800412:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  800416:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  800418:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  80041c:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  800420:	fcd56ce3          	bltu	a0,a3,8003f8 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
  800424:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  800426:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
  80042a:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
  80042e:	0196873b          	addw	a4,a3,s9
  800432:	0017171b          	slliw	a4,a4,0x1
  800436:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
  80043a:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
  80043e:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  800442:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  800446:	fcd57fe3          	bleu	a3,a0,800424 <vprintfmt+0x252>
  80044a:	b77d                	j	8003f8 <vprintfmt+0x226>
            if (width < 0)
  80044c:	fffdc693          	not	a3,s11
  800450:	96fd                	srai	a3,a3,0x3f
  800452:	00ddfdb3          	and	s11,s11,a3
  800456:	00144603          	lbu	a2,1(s0)
  80045a:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
  80045c:	846a                	mv	s0,s10
  80045e:	b3f5                	j	80024a <vprintfmt+0x78>
            putch('%', putdat);
  800460:	85a6                	mv	a1,s1
  800462:	02500513          	li	a0,37
  800466:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  800468:	fff44703          	lbu	a4,-1(s0)
  80046c:	02500793          	li	a5,37
  800470:	8d22                	mv	s10,s0
  800472:	d8f70de3          	beq	a4,a5,80020c <vprintfmt+0x3a>
  800476:	02500713          	li	a4,37
  80047a:	1d7d                	addi	s10,s10,-1
  80047c:	fffd4783          	lbu	a5,-1(s10)
  800480:	fee79de3          	bne	a5,a4,80047a <vprintfmt+0x2a8>
  800484:	b361                	j	80020c <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  800486:	00000617          	auipc	a2,0x0
  80048a:	45260613          	addi	a2,a2,1106 # 8008d8 <error_string+0x1a8>
  80048e:	85a6                	mv	a1,s1
  800490:	854a                	mv	a0,s2
  800492:	0ac000ef          	jal	ra,80053e <printfmt>
  800496:	bb9d                	j	80020c <vprintfmt+0x3a>
                p = "(null)";
  800498:	00000617          	auipc	a2,0x0
  80049c:	43860613          	addi	a2,a2,1080 # 8008d0 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
  8004a0:	00000417          	auipc	s0,0x0
  8004a4:	43140413          	addi	s0,s0,1073 # 8008d1 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004a8:	8532                	mv	a0,a2
  8004aa:	85e6                	mv	a1,s9
  8004ac:	e032                	sd	a2,0(sp)
  8004ae:	e43e                	sd	a5,8(sp)
  8004b0:	c91ff0ef          	jal	ra,800140 <strnlen>
  8004b4:	40ad8dbb          	subw	s11,s11,a0
  8004b8:	6602                	ld	a2,0(sp)
  8004ba:	01b05d63          	blez	s11,8004d4 <vprintfmt+0x302>
  8004be:	67a2                	ld	a5,8(sp)
  8004c0:	2781                	sext.w	a5,a5
  8004c2:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
  8004c4:	6522                	ld	a0,8(sp)
  8004c6:	85a6                	mv	a1,s1
  8004c8:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004ca:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  8004cc:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004ce:	6602                	ld	a2,0(sp)
  8004d0:	fe0d9ae3          	bnez	s11,8004c4 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004d4:	00064783          	lbu	a5,0(a2)
  8004d8:	0007851b          	sext.w	a0,a5
  8004dc:	e8051be3          	bnez	a0,800372 <vprintfmt+0x1a0>
  8004e0:	b335                	j	80020c <vprintfmt+0x3a>
        return va_arg(*ap, int);
  8004e2:	000aa403          	lw	s0,0(s5)
  8004e6:	bbf1                	j	8002c2 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
  8004e8:	000ae603          	lwu	a2,0(s5)
  8004ec:	46a9                	li	a3,10
  8004ee:	8aae                	mv	s5,a1
  8004f0:	bd89                	j	800342 <vprintfmt+0x170>
  8004f2:	000ae603          	lwu	a2,0(s5)
  8004f6:	46c1                	li	a3,16
  8004f8:	8aae                	mv	s5,a1
  8004fa:	b5a1                	j	800342 <vprintfmt+0x170>
  8004fc:	000ae603          	lwu	a2,0(s5)
  800500:	46a1                	li	a3,8
  800502:	8aae                	mv	s5,a1
  800504:	bd3d                	j	800342 <vprintfmt+0x170>
                    putch(ch, putdat);
  800506:	9902                	jalr	s2
  800508:	b559                	j	80038e <vprintfmt+0x1bc>
                putch('-', putdat);
  80050a:	85a6                	mv	a1,s1
  80050c:	02d00513          	li	a0,45
  800510:	e03e                	sd	a5,0(sp)
  800512:	9902                	jalr	s2
                num = -(long long)num;
  800514:	8ace                	mv	s5,s3
  800516:	40800633          	neg	a2,s0
  80051a:	46a9                	li	a3,10
  80051c:	6782                	ld	a5,0(sp)
  80051e:	b515                	j	800342 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
  800520:	01b05663          	blez	s11,80052c <vprintfmt+0x35a>
  800524:	02d00693          	li	a3,45
  800528:	f6d798e3          	bne	a5,a3,800498 <vprintfmt+0x2c6>
  80052c:	00000417          	auipc	s0,0x0
  800530:	3a540413          	addi	s0,s0,933 # 8008d1 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800534:	02800513          	li	a0,40
  800538:	02800793          	li	a5,40
  80053c:	bd1d                	j	800372 <vprintfmt+0x1a0>

000000000080053e <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80053e:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  800540:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800544:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800546:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800548:	ec06                	sd	ra,24(sp)
  80054a:	f83a                	sd	a4,48(sp)
  80054c:	fc3e                	sd	a5,56(sp)
  80054e:	e0c2                	sd	a6,64(sp)
  800550:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800552:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800554:	c7fff0ef          	jal	ra,8001d2 <vprintfmt>
}
  800558:	60e2                	ld	ra,24(sp)
  80055a:	6161                	addi	sp,sp,80
  80055c:	8082                	ret

000000000080055e <main>:

int zero;

int
main(void) {
    cprintf("value is %d.\n", 1 / zero);
  80055e:	00001797          	auipc	a5,0x1
  800562:	aa278793          	addi	a5,a5,-1374 # 801000 <zero>
  800566:	439c                	lw	a5,0(a5)
  800568:	4585                	li	a1,1
main(void) {
  80056a:	1141                	addi	sp,sp,-16
    cprintf("value is %d.\n", 1 / zero);
  80056c:	02f5c5bb          	divw	a1,a1,a5
  800570:	00000517          	auipc	a0,0x0
  800574:	38050513          	addi	a0,a0,896 # 8008f0 <error_string+0x1c0>
main(void) {
  800578:	e406                	sd	ra,8(sp)
    cprintf("value is %d.\n", 1 / zero);
  80057a:	b87ff0ef          	jal	ra,800100 <cprintf>
    panic("FAIL: T.T\n");
  80057e:	00000617          	auipc	a2,0x0
  800582:	38260613          	addi	a2,a2,898 # 800900 <error_string+0x1d0>
  800586:	45a5                	li	a1,9
  800588:	00000517          	auipc	a0,0x0
  80058c:	38850513          	addi	a0,a0,904 # 800910 <error_string+0x1e0>
  800590:	a91ff0ef          	jal	ra,800020 <__panic>
