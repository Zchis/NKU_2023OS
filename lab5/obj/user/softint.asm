
obj/__user_softint.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <syscall>:
#include <syscall.h>

#define MAX_ARGS            5

static inline int
syscall(int64_t num, ...) {
  800020:	7175                	addi	sp,sp,-144
  800022:	f8ba                	sd	a4,112(sp)
    va_list ap;
    va_start(ap, num);
    uint64_t a[MAX_ARGS];
    int i, ret;
    for (i = 0; i < MAX_ARGS; i ++) {
        a[i] = va_arg(ap, uint64_t);
  800024:	e0ba                	sd	a4,64(sp)
  800026:	0118                	addi	a4,sp,128
syscall(int64_t num, ...) {
  800028:	e42a                	sd	a0,8(sp)
  80002a:	ecae                	sd	a1,88(sp)
  80002c:	f0b2                	sd	a2,96(sp)
  80002e:	f4b6                	sd	a3,104(sp)
  800030:	fcbe                	sd	a5,120(sp)
  800032:	e142                	sd	a6,128(sp)
  800034:	e546                	sd	a7,136(sp)
        a[i] = va_arg(ap, uint64_t);
  800036:	f42e                	sd	a1,40(sp)
  800038:	f832                	sd	a2,48(sp)
  80003a:	fc36                	sd	a3,56(sp)
  80003c:	f03a                	sd	a4,32(sp)
  80003e:	e4be                	sd	a5,72(sp)
    }
    va_end(ap);

    asm volatile (
  800040:	6522                	ld	a0,8(sp)
  800042:	75a2                	ld	a1,40(sp)
  800044:	7642                	ld	a2,48(sp)
  800046:	76e2                	ld	a3,56(sp)
  800048:	6706                	ld	a4,64(sp)
  80004a:	67a6                	ld	a5,72(sp)
  80004c:	00000073          	ecall
  800050:	00a13e23          	sd	a0,28(sp)
        "sd a0, %0"
        : "=m" (ret)
        : "m"(num), "m"(a[0]), "m"(a[1]), "m"(a[2]), "m"(a[3]), "m"(a[4])
        :"memory");
    return ret;
}
  800054:	4572                	lw	a0,28(sp)
  800056:	6149                	addi	sp,sp,144
  800058:	8082                	ret

000000000080005a <sys_exit>:

int
sys_exit(int64_t error_code) {
    return syscall(SYS_exit, error_code);
  80005a:	85aa                	mv	a1,a0
  80005c:	4505                	li	a0,1
  80005e:	fc3ff06f          	j	800020 <syscall>

0000000000800062 <sys_putc>:
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
    return syscall(SYS_putc, c);
  800062:	85aa                	mv	a1,a0
  800064:	4579                	li	a0,30
  800066:	fbbff06f          	j	800020 <syscall>

000000000080006a <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  80006a:	1141                	addi	sp,sp,-16
  80006c:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  80006e:	fedff0ef          	jal	ra,80005a <sys_exit>
    cprintf("BUG: exit failed.\n");
  800072:	00000517          	auipc	a0,0x0
  800076:	49650513          	addi	a0,a0,1174 # 800508 <main+0xa>
  80007a:	026000ef          	jal	ra,8000a0 <cprintf>
    while (1);
  80007e:	a001                	j	80007e <exit+0x14>

0000000000800080 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800080:	054000ef          	jal	ra,8000d4 <umain>
1:  j 1b
  800084:	a001                	j	800084 <_start+0x4>

0000000000800086 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  800086:	1141                	addi	sp,sp,-16
  800088:	e022                	sd	s0,0(sp)
  80008a:	e406                	sd	ra,8(sp)
  80008c:	842e                	mv	s0,a1
    sys_putc(c);
  80008e:	fd5ff0ef          	jal	ra,800062 <sys_putc>
    (*cnt) ++;
  800092:	401c                	lw	a5,0(s0)
}
  800094:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
  800096:	2785                	addiw	a5,a5,1
  800098:	c01c                	sw	a5,0(s0)
}
  80009a:	6402                	ld	s0,0(sp)
  80009c:	0141                	addi	sp,sp,16
  80009e:	8082                	ret

00000000008000a0 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  8000a0:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  8000a2:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  8000a6:	f42e                	sd	a1,40(sp)
  8000a8:	f832                	sd	a2,48(sp)
  8000aa:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000ac:	862a                	mv	a2,a0
  8000ae:	004c                	addi	a1,sp,4
  8000b0:	00000517          	auipc	a0,0x0
  8000b4:	fd650513          	addi	a0,a0,-42 # 800086 <cputch>
  8000b8:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
  8000ba:	ec06                	sd	ra,24(sp)
  8000bc:	e0ba                	sd	a4,64(sp)
  8000be:	e4be                	sd	a5,72(sp)
  8000c0:	e8c2                	sd	a6,80(sp)
  8000c2:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
  8000c4:	e41a                	sd	t1,8(sp)
    int cnt = 0;
  8000c6:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000c8:	0aa000ef          	jal	ra,800172 <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  8000cc:	60e2                	ld	ra,24(sp)
  8000ce:	4512                	lw	a0,4(sp)
  8000d0:	6125                	addi	sp,sp,96
  8000d2:	8082                	ret

00000000008000d4 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  8000d4:	1141                	addi	sp,sp,-16
  8000d6:	e406                	sd	ra,8(sp)
    int ret = main();
  8000d8:	426000ef          	jal	ra,8004fe <main>
    exit(ret);
  8000dc:	f8fff0ef          	jal	ra,80006a <exit>

00000000008000e0 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  8000e0:	c185                	beqz	a1,800100 <strnlen+0x20>
  8000e2:	00054783          	lbu	a5,0(a0)
  8000e6:	cf89                	beqz	a5,800100 <strnlen+0x20>
    size_t cnt = 0;
  8000e8:	4781                	li	a5,0
  8000ea:	a021                	j	8000f2 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
  8000ec:	00074703          	lbu	a4,0(a4)
  8000f0:	c711                	beqz	a4,8000fc <strnlen+0x1c>
        cnt ++;
  8000f2:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  8000f4:	00f50733          	add	a4,a0,a5
  8000f8:	fef59ae3          	bne	a1,a5,8000ec <strnlen+0xc>
    }
    return cnt;
}
  8000fc:	853e                	mv	a0,a5
  8000fe:	8082                	ret
    size_t cnt = 0;
  800100:	4781                	li	a5,0
}
  800102:	853e                	mv	a0,a5
  800104:	8082                	ret

0000000000800106 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800106:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80010a:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  80010c:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800110:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  800112:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  800116:	f022                	sd	s0,32(sp)
  800118:	ec26                	sd	s1,24(sp)
  80011a:	e84a                	sd	s2,16(sp)
  80011c:	f406                	sd	ra,40(sp)
  80011e:	e44e                	sd	s3,8(sp)
  800120:	84aa                	mv	s1,a0
  800122:	892e                	mv	s2,a1
  800124:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  800128:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  80012a:	03067e63          	bleu	a6,a2,800166 <printnum+0x60>
  80012e:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800130:	00805763          	blez	s0,80013e <printnum+0x38>
  800134:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800136:	85ca                	mv	a1,s2
  800138:	854e                	mv	a0,s3
  80013a:	9482                	jalr	s1
        while (-- width > 0)
  80013c:	fc65                	bnez	s0,800134 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  80013e:	1a02                	slli	s4,s4,0x20
  800140:	020a5a13          	srli	s4,s4,0x20
  800144:	00000797          	auipc	a5,0x0
  800148:	5fc78793          	addi	a5,a5,1532 # 800740 <error_string+0xc8>
  80014c:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  80014e:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  800150:	000a4503          	lbu	a0,0(s4)
}
  800154:	70a2                	ld	ra,40(sp)
  800156:	69a2                	ld	s3,8(sp)
  800158:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  80015a:	85ca                	mv	a1,s2
  80015c:	8326                	mv	t1,s1
}
  80015e:	6942                	ld	s2,16(sp)
  800160:	64e2                	ld	s1,24(sp)
  800162:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  800164:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
  800166:	03065633          	divu	a2,a2,a6
  80016a:	8722                	mv	a4,s0
  80016c:	f9bff0ef          	jal	ra,800106 <printnum>
  800170:	b7f9                	j	80013e <printnum+0x38>

0000000000800172 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  800172:	7119                	addi	sp,sp,-128
  800174:	f4a6                	sd	s1,104(sp)
  800176:	f0ca                	sd	s2,96(sp)
  800178:	e8d2                	sd	s4,80(sp)
  80017a:	e4d6                	sd	s5,72(sp)
  80017c:	e0da                	sd	s6,64(sp)
  80017e:	fc5e                	sd	s7,56(sp)
  800180:	f862                	sd	s8,48(sp)
  800182:	f06a                	sd	s10,32(sp)
  800184:	fc86                	sd	ra,120(sp)
  800186:	f8a2                	sd	s0,112(sp)
  800188:	ecce                	sd	s3,88(sp)
  80018a:	f466                	sd	s9,40(sp)
  80018c:	ec6e                	sd	s11,24(sp)
  80018e:	892a                	mv	s2,a0
  800190:	84ae                	mv	s1,a1
  800192:	8d32                	mv	s10,a2
  800194:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  800196:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  800198:	00000a17          	auipc	s4,0x0
  80019c:	384a0a13          	addi	s4,s4,900 # 80051c <main+0x1e>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
  8001a0:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8001a4:	00000c17          	auipc	s8,0x0
  8001a8:	4d4c0c13          	addi	s8,s8,1236 # 800678 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001ac:	000d4503          	lbu	a0,0(s10)
  8001b0:	02500793          	li	a5,37
  8001b4:	001d0413          	addi	s0,s10,1
  8001b8:	00f50e63          	beq	a0,a5,8001d4 <vprintfmt+0x62>
            if (ch == '\0') {
  8001bc:	c521                	beqz	a0,800204 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001be:	02500993          	li	s3,37
  8001c2:	a011                	j	8001c6 <vprintfmt+0x54>
            if (ch == '\0') {
  8001c4:	c121                	beqz	a0,800204 <vprintfmt+0x92>
            putch(ch, putdat);
  8001c6:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001c8:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  8001ca:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001cc:	fff44503          	lbu	a0,-1(s0)
  8001d0:	ff351ae3          	bne	a0,s3,8001c4 <vprintfmt+0x52>
  8001d4:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  8001d8:	02000793          	li	a5,32
        lflag = altflag = 0;
  8001dc:	4981                	li	s3,0
  8001de:	4801                	li	a6,0
        width = precision = -1;
  8001e0:	5cfd                	li	s9,-1
  8001e2:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
  8001e4:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
  8001e8:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
  8001ea:	fdd6069b          	addiw	a3,a2,-35
  8001ee:	0ff6f693          	andi	a3,a3,255
  8001f2:	00140d13          	addi	s10,s0,1
  8001f6:	20d5e563          	bltu	a1,a3,800400 <vprintfmt+0x28e>
  8001fa:	068a                	slli	a3,a3,0x2
  8001fc:	96d2                	add	a3,a3,s4
  8001fe:	4294                	lw	a3,0(a3)
  800200:	96d2                	add	a3,a3,s4
  800202:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  800204:	70e6                	ld	ra,120(sp)
  800206:	7446                	ld	s0,112(sp)
  800208:	74a6                	ld	s1,104(sp)
  80020a:	7906                	ld	s2,96(sp)
  80020c:	69e6                	ld	s3,88(sp)
  80020e:	6a46                	ld	s4,80(sp)
  800210:	6aa6                	ld	s5,72(sp)
  800212:	6b06                	ld	s6,64(sp)
  800214:	7be2                	ld	s7,56(sp)
  800216:	7c42                	ld	s8,48(sp)
  800218:	7ca2                	ld	s9,40(sp)
  80021a:	7d02                	ld	s10,32(sp)
  80021c:	6de2                	ld	s11,24(sp)
  80021e:	6109                	addi	sp,sp,128
  800220:	8082                	ret
    if (lflag >= 2) {
  800222:	4705                	li	a4,1
  800224:	008a8593          	addi	a1,s5,8
  800228:	01074463          	blt	a4,a6,800230 <vprintfmt+0xbe>
    else if (lflag) {
  80022c:	26080363          	beqz	a6,800492 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
  800230:	000ab603          	ld	a2,0(s5)
  800234:	46c1                	li	a3,16
  800236:	8aae                	mv	s5,a1
  800238:	a06d                	j	8002e2 <vprintfmt+0x170>
            goto reswitch;
  80023a:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  80023e:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
  800240:	846a                	mv	s0,s10
            goto reswitch;
  800242:	b765                	j	8001ea <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
  800244:	000aa503          	lw	a0,0(s5)
  800248:	85a6                	mv	a1,s1
  80024a:	0aa1                	addi	s5,s5,8
  80024c:	9902                	jalr	s2
            break;
  80024e:	bfb9                	j	8001ac <vprintfmt+0x3a>
    if (lflag >= 2) {
  800250:	4705                	li	a4,1
  800252:	008a8993          	addi	s3,s5,8
  800256:	01074463          	blt	a4,a6,80025e <vprintfmt+0xec>
    else if (lflag) {
  80025a:	22080463          	beqz	a6,800482 <vprintfmt+0x310>
        return va_arg(*ap, long);
  80025e:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
  800262:	24044463          	bltz	s0,8004aa <vprintfmt+0x338>
            num = getint(&ap, lflag);
  800266:	8622                	mv	a2,s0
  800268:	8ace                	mv	s5,s3
  80026a:	46a9                	li	a3,10
  80026c:	a89d                	j	8002e2 <vprintfmt+0x170>
            err = va_arg(ap, int);
  80026e:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800272:	4761                	li	a4,24
            err = va_arg(ap, int);
  800274:	0aa1                	addi	s5,s5,8
            if (err < 0) {
  800276:	41f7d69b          	sraiw	a3,a5,0x1f
  80027a:	8fb5                	xor	a5,a5,a3
  80027c:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800280:	1ad74363          	blt	a4,a3,800426 <vprintfmt+0x2b4>
  800284:	00369793          	slli	a5,a3,0x3
  800288:	97e2                	add	a5,a5,s8
  80028a:	639c                	ld	a5,0(a5)
  80028c:	18078d63          	beqz	a5,800426 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
  800290:	86be                	mv	a3,a5
  800292:	00000617          	auipc	a2,0x0
  800296:	59e60613          	addi	a2,a2,1438 # 800830 <error_string+0x1b8>
  80029a:	85a6                	mv	a1,s1
  80029c:	854a                	mv	a0,s2
  80029e:	240000ef          	jal	ra,8004de <printfmt>
  8002a2:	b729                	j	8001ac <vprintfmt+0x3a>
            lflag ++;
  8002a4:	00144603          	lbu	a2,1(s0)
  8002a8:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
  8002aa:	846a                	mv	s0,s10
            goto reswitch;
  8002ac:	bf3d                	j	8001ea <vprintfmt+0x78>
    if (lflag >= 2) {
  8002ae:	4705                	li	a4,1
  8002b0:	008a8593          	addi	a1,s5,8
  8002b4:	01074463          	blt	a4,a6,8002bc <vprintfmt+0x14a>
    else if (lflag) {
  8002b8:	1e080263          	beqz	a6,80049c <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
  8002bc:	000ab603          	ld	a2,0(s5)
  8002c0:	46a1                	li	a3,8
  8002c2:	8aae                	mv	s5,a1
  8002c4:	a839                	j	8002e2 <vprintfmt+0x170>
            putch('0', putdat);
  8002c6:	03000513          	li	a0,48
  8002ca:	85a6                	mv	a1,s1
  8002cc:	e03e                	sd	a5,0(sp)
  8002ce:	9902                	jalr	s2
            putch('x', putdat);
  8002d0:	85a6                	mv	a1,s1
  8002d2:	07800513          	li	a0,120
  8002d6:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8002d8:	0aa1                	addi	s5,s5,8
  8002da:	ff8ab603          	ld	a2,-8(s5)
            goto number;
  8002de:	6782                	ld	a5,0(sp)
  8002e0:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
  8002e2:	876e                	mv	a4,s11
  8002e4:	85a6                	mv	a1,s1
  8002e6:	854a                	mv	a0,s2
  8002e8:	e1fff0ef          	jal	ra,800106 <printnum>
            break;
  8002ec:	b5c1                	j	8001ac <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
  8002ee:	000ab603          	ld	a2,0(s5)
  8002f2:	0aa1                	addi	s5,s5,8
  8002f4:	1c060663          	beqz	a2,8004c0 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
  8002f8:	00160413          	addi	s0,a2,1
  8002fc:	17b05c63          	blez	s11,800474 <vprintfmt+0x302>
  800300:	02d00593          	li	a1,45
  800304:	14b79263          	bne	a5,a1,800448 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800308:	00064783          	lbu	a5,0(a2)
  80030c:	0007851b          	sext.w	a0,a5
  800310:	c905                	beqz	a0,800340 <vprintfmt+0x1ce>
  800312:	000cc563          	bltz	s9,80031c <vprintfmt+0x1aa>
  800316:	3cfd                	addiw	s9,s9,-1
  800318:	036c8263          	beq	s9,s6,80033c <vprintfmt+0x1ca>
                    putch('?', putdat);
  80031c:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  80031e:	18098463          	beqz	s3,8004a6 <vprintfmt+0x334>
  800322:	3781                	addiw	a5,a5,-32
  800324:	18fbf163          	bleu	a5,s7,8004a6 <vprintfmt+0x334>
                    putch('?', putdat);
  800328:	03f00513          	li	a0,63
  80032c:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80032e:	0405                	addi	s0,s0,1
  800330:	fff44783          	lbu	a5,-1(s0)
  800334:	3dfd                	addiw	s11,s11,-1
  800336:	0007851b          	sext.w	a0,a5
  80033a:	fd61                	bnez	a0,800312 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
  80033c:	e7b058e3          	blez	s11,8001ac <vprintfmt+0x3a>
  800340:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  800342:	85a6                	mv	a1,s1
  800344:	02000513          	li	a0,32
  800348:	9902                	jalr	s2
            for (; width > 0; width --) {
  80034a:	e60d81e3          	beqz	s11,8001ac <vprintfmt+0x3a>
  80034e:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  800350:	85a6                	mv	a1,s1
  800352:	02000513          	li	a0,32
  800356:	9902                	jalr	s2
            for (; width > 0; width --) {
  800358:	fe0d94e3          	bnez	s11,800340 <vprintfmt+0x1ce>
  80035c:	bd81                	j	8001ac <vprintfmt+0x3a>
    if (lflag >= 2) {
  80035e:	4705                	li	a4,1
  800360:	008a8593          	addi	a1,s5,8
  800364:	01074463          	blt	a4,a6,80036c <vprintfmt+0x1fa>
    else if (lflag) {
  800368:	12080063          	beqz	a6,800488 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
  80036c:	000ab603          	ld	a2,0(s5)
  800370:	46a9                	li	a3,10
  800372:	8aae                	mv	s5,a1
  800374:	b7bd                	j	8002e2 <vprintfmt+0x170>
  800376:	00144603          	lbu	a2,1(s0)
            padc = '-';
  80037a:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
  80037e:	846a                	mv	s0,s10
  800380:	b5ad                	j	8001ea <vprintfmt+0x78>
            putch(ch, putdat);
  800382:	85a6                	mv	a1,s1
  800384:	02500513          	li	a0,37
  800388:	9902                	jalr	s2
            break;
  80038a:	b50d                	j	8001ac <vprintfmt+0x3a>
            precision = va_arg(ap, int);
  80038c:	000aac83          	lw	s9,0(s5)
            goto process_precision;
  800390:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  800394:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
  800396:	846a                	mv	s0,s10
            if (width < 0)
  800398:	e40dd9e3          	bgez	s11,8001ea <vprintfmt+0x78>
                width = precision, precision = -1;
  80039c:	8de6                	mv	s11,s9
  80039e:	5cfd                	li	s9,-1
  8003a0:	b5a9                	j	8001ea <vprintfmt+0x78>
            goto reswitch;
  8003a2:	00144603          	lbu	a2,1(s0)
            padc = '0';
  8003a6:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
  8003aa:	846a                	mv	s0,s10
            goto reswitch;
  8003ac:	bd3d                	j	8001ea <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
  8003ae:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
  8003b2:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  8003b6:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  8003b8:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  8003bc:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  8003c0:	fcd56ce3          	bltu	a0,a3,800398 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
  8003c4:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8003c6:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
  8003ca:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
  8003ce:	0196873b          	addw	a4,a3,s9
  8003d2:	0017171b          	slliw	a4,a4,0x1
  8003d6:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
  8003da:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
  8003de:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  8003e2:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  8003e6:	fcd57fe3          	bleu	a3,a0,8003c4 <vprintfmt+0x252>
  8003ea:	b77d                	j	800398 <vprintfmt+0x226>
            if (width < 0)
  8003ec:	fffdc693          	not	a3,s11
  8003f0:	96fd                	srai	a3,a3,0x3f
  8003f2:	00ddfdb3          	and	s11,s11,a3
  8003f6:	00144603          	lbu	a2,1(s0)
  8003fa:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
  8003fc:	846a                	mv	s0,s10
  8003fe:	b3f5                	j	8001ea <vprintfmt+0x78>
            putch('%', putdat);
  800400:	85a6                	mv	a1,s1
  800402:	02500513          	li	a0,37
  800406:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  800408:	fff44703          	lbu	a4,-1(s0)
  80040c:	02500793          	li	a5,37
  800410:	8d22                	mv	s10,s0
  800412:	d8f70de3          	beq	a4,a5,8001ac <vprintfmt+0x3a>
  800416:	02500713          	li	a4,37
  80041a:	1d7d                	addi	s10,s10,-1
  80041c:	fffd4783          	lbu	a5,-1(s10)
  800420:	fee79de3          	bne	a5,a4,80041a <vprintfmt+0x2a8>
  800424:	b361                	j	8001ac <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  800426:	00000617          	auipc	a2,0x0
  80042a:	3fa60613          	addi	a2,a2,1018 # 800820 <error_string+0x1a8>
  80042e:	85a6                	mv	a1,s1
  800430:	854a                	mv	a0,s2
  800432:	0ac000ef          	jal	ra,8004de <printfmt>
  800436:	bb9d                	j	8001ac <vprintfmt+0x3a>
                p = "(null)";
  800438:	00000617          	auipc	a2,0x0
  80043c:	3e060613          	addi	a2,a2,992 # 800818 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
  800440:	00000417          	auipc	s0,0x0
  800444:	3d940413          	addi	s0,s0,985 # 800819 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800448:	8532                	mv	a0,a2
  80044a:	85e6                	mv	a1,s9
  80044c:	e032                	sd	a2,0(sp)
  80044e:	e43e                	sd	a5,8(sp)
  800450:	c91ff0ef          	jal	ra,8000e0 <strnlen>
  800454:	40ad8dbb          	subw	s11,s11,a0
  800458:	6602                	ld	a2,0(sp)
  80045a:	01b05d63          	blez	s11,800474 <vprintfmt+0x302>
  80045e:	67a2                	ld	a5,8(sp)
  800460:	2781                	sext.w	a5,a5
  800462:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
  800464:	6522                	ld	a0,8(sp)
  800466:	85a6                	mv	a1,s1
  800468:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  80046a:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  80046c:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  80046e:	6602                	ld	a2,0(sp)
  800470:	fe0d9ae3          	bnez	s11,800464 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800474:	00064783          	lbu	a5,0(a2)
  800478:	0007851b          	sext.w	a0,a5
  80047c:	e8051be3          	bnez	a0,800312 <vprintfmt+0x1a0>
  800480:	b335                	j	8001ac <vprintfmt+0x3a>
        return va_arg(*ap, int);
  800482:	000aa403          	lw	s0,0(s5)
  800486:	bbf1                	j	800262 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
  800488:	000ae603          	lwu	a2,0(s5)
  80048c:	46a9                	li	a3,10
  80048e:	8aae                	mv	s5,a1
  800490:	bd89                	j	8002e2 <vprintfmt+0x170>
  800492:	000ae603          	lwu	a2,0(s5)
  800496:	46c1                	li	a3,16
  800498:	8aae                	mv	s5,a1
  80049a:	b5a1                	j	8002e2 <vprintfmt+0x170>
  80049c:	000ae603          	lwu	a2,0(s5)
  8004a0:	46a1                	li	a3,8
  8004a2:	8aae                	mv	s5,a1
  8004a4:	bd3d                	j	8002e2 <vprintfmt+0x170>
                    putch(ch, putdat);
  8004a6:	9902                	jalr	s2
  8004a8:	b559                	j	80032e <vprintfmt+0x1bc>
                putch('-', putdat);
  8004aa:	85a6                	mv	a1,s1
  8004ac:	02d00513          	li	a0,45
  8004b0:	e03e                	sd	a5,0(sp)
  8004b2:	9902                	jalr	s2
                num = -(long long)num;
  8004b4:	8ace                	mv	s5,s3
  8004b6:	40800633          	neg	a2,s0
  8004ba:	46a9                	li	a3,10
  8004bc:	6782                	ld	a5,0(sp)
  8004be:	b515                	j	8002e2 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
  8004c0:	01b05663          	blez	s11,8004cc <vprintfmt+0x35a>
  8004c4:	02d00693          	li	a3,45
  8004c8:	f6d798e3          	bne	a5,a3,800438 <vprintfmt+0x2c6>
  8004cc:	00000417          	auipc	s0,0x0
  8004d0:	34d40413          	addi	s0,s0,845 # 800819 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004d4:	02800513          	li	a0,40
  8004d8:	02800793          	li	a5,40
  8004dc:	bd1d                	j	800312 <vprintfmt+0x1a0>

00000000008004de <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004de:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  8004e0:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004e4:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004e6:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004e8:	ec06                	sd	ra,24(sp)
  8004ea:	f83a                	sd	a4,48(sp)
  8004ec:	fc3e                	sd	a5,56(sp)
  8004ee:	e0c2                	sd	a6,64(sp)
  8004f0:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  8004f2:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004f4:	c7fff0ef          	jal	ra,800172 <vprintfmt>
}
  8004f8:	60e2                	ld	ra,24(sp)
  8004fa:	6161                	addi	sp,sp,80
  8004fc:	8082                	ret

00000000008004fe <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
  8004fe:	1141                	addi	sp,sp,-16
	// Never mind
    // asm volatile("int $14");
    exit(0);
  800500:	4501                	li	a0,0
main(void) {
  800502:	e406                	sd	ra,8(sp)
    exit(0);
  800504:	b67ff0ef          	jal	ra,80006a <exit>
