
obj/__user_hello.out:     file format elf64-littleriscv


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

0000000000800062 <sys_getpid>:
    return syscall(SYS_kill, pid);
}

int
sys_getpid(void) {
    return syscall(SYS_getpid);
  800062:	4549                	li	a0,18
  800064:	fbdff06f          	j	800020 <syscall>

0000000000800068 <sys_putc>:
}

int
sys_putc(int64_t c) {
    return syscall(SYS_putc, c);
  800068:	85aa                	mv	a1,a0
  80006a:	4579                	li	a0,30
  80006c:	fb5ff06f          	j	800020 <syscall>

0000000000800070 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  800070:	1141                	addi	sp,sp,-16
  800072:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  800074:	fe7ff0ef          	jal	ra,80005a <sys_exit>
    cprintf("BUG: exit failed.\n");
  800078:	00000517          	auipc	a0,0x0
  80007c:	4c850513          	addi	a0,a0,1224 # 800540 <main+0x38>
  800080:	02a000ef          	jal	ra,8000aa <cprintf>
    while (1);
  800084:	a001                	j	800084 <exit+0x14>

0000000000800086 <getpid>:
    return sys_kill(pid);
}

int
getpid(void) {
    return sys_getpid();
  800086:	fddff06f          	j	800062 <sys_getpid>

000000000080008a <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  80008a:	054000ef          	jal	ra,8000de <umain>
1:  j 1b
  80008e:	a001                	j	80008e <_start+0x4>

0000000000800090 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  800090:	1141                	addi	sp,sp,-16
  800092:	e022                	sd	s0,0(sp)
  800094:	e406                	sd	ra,8(sp)
  800096:	842e                	mv	s0,a1
    sys_putc(c);
  800098:	fd1ff0ef          	jal	ra,800068 <sys_putc>
    (*cnt) ++;
  80009c:	401c                	lw	a5,0(s0)
}
  80009e:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
  8000a0:	2785                	addiw	a5,a5,1
  8000a2:	c01c                	sw	a5,0(s0)
}
  8000a4:	6402                	ld	s0,0(sp)
  8000a6:	0141                	addi	sp,sp,16
  8000a8:	8082                	ret

00000000008000aa <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  8000aa:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  8000ac:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  8000b0:	f42e                	sd	a1,40(sp)
  8000b2:	f832                	sd	a2,48(sp)
  8000b4:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000b6:	862a                	mv	a2,a0
  8000b8:	004c                	addi	a1,sp,4
  8000ba:	00000517          	auipc	a0,0x0
  8000be:	fd650513          	addi	a0,a0,-42 # 800090 <cputch>
  8000c2:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
  8000c4:	ec06                	sd	ra,24(sp)
  8000c6:	e0ba                	sd	a4,64(sp)
  8000c8:	e4be                	sd	a5,72(sp)
  8000ca:	e8c2                	sd	a6,80(sp)
  8000cc:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
  8000ce:	e41a                	sd	t1,8(sp)
    int cnt = 0;
  8000d0:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000d2:	0aa000ef          	jal	ra,80017c <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  8000d6:	60e2                	ld	ra,24(sp)
  8000d8:	4512                	lw	a0,4(sp)
  8000da:	6125                	addi	sp,sp,96
  8000dc:	8082                	ret

00000000008000de <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  8000de:	1141                	addi	sp,sp,-16
  8000e0:	e406                	sd	ra,8(sp)
    int ret = main();
  8000e2:	426000ef          	jal	ra,800508 <main>
    exit(ret);
  8000e6:	f8bff0ef          	jal	ra,800070 <exit>

00000000008000ea <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  8000ea:	c185                	beqz	a1,80010a <strnlen+0x20>
  8000ec:	00054783          	lbu	a5,0(a0)
  8000f0:	cf89                	beqz	a5,80010a <strnlen+0x20>
    size_t cnt = 0;
  8000f2:	4781                	li	a5,0
  8000f4:	a021                	j	8000fc <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
  8000f6:	00074703          	lbu	a4,0(a4)
  8000fa:	c711                	beqz	a4,800106 <strnlen+0x1c>
        cnt ++;
  8000fc:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  8000fe:	00f50733          	add	a4,a0,a5
  800102:	fef59ae3          	bne	a1,a5,8000f6 <strnlen+0xc>
    }
    return cnt;
}
  800106:	853e                	mv	a0,a5
  800108:	8082                	ret
    size_t cnt = 0;
  80010a:	4781                	li	a5,0
}
  80010c:	853e                	mv	a0,a5
  80010e:	8082                	ret

0000000000800110 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800110:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800114:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  800116:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80011a:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  80011c:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  800120:	f022                	sd	s0,32(sp)
  800122:	ec26                	sd	s1,24(sp)
  800124:	e84a                	sd	s2,16(sp)
  800126:	f406                	sd	ra,40(sp)
  800128:	e44e                	sd	s3,8(sp)
  80012a:	84aa                	mv	s1,a0
  80012c:	892e                	mv	s2,a1
  80012e:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  800132:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  800134:	03067e63          	bleu	a6,a2,800170 <printnum+0x60>
  800138:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  80013a:	00805763          	blez	s0,800148 <printnum+0x38>
  80013e:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800140:	85ca                	mv	a1,s2
  800142:	854e                	mv	a0,s3
  800144:	9482                	jalr	s1
        while (-- width > 0)
  800146:	fc65                	bnez	s0,80013e <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800148:	1a02                	slli	s4,s4,0x20
  80014a:	020a5a13          	srli	s4,s4,0x20
  80014e:	00000797          	auipc	a5,0x0
  800152:	62a78793          	addi	a5,a5,1578 # 800778 <error_string+0xc8>
  800156:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  800158:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  80015a:	000a4503          	lbu	a0,0(s4)
}
  80015e:	70a2                	ld	ra,40(sp)
  800160:	69a2                	ld	s3,8(sp)
  800162:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  800164:	85ca                	mv	a1,s2
  800166:	8326                	mv	t1,s1
}
  800168:	6942                	ld	s2,16(sp)
  80016a:	64e2                	ld	s1,24(sp)
  80016c:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  80016e:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
  800170:	03065633          	divu	a2,a2,a6
  800174:	8722                	mv	a4,s0
  800176:	f9bff0ef          	jal	ra,800110 <printnum>
  80017a:	b7f9                	j	800148 <printnum+0x38>

000000000080017c <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  80017c:	7119                	addi	sp,sp,-128
  80017e:	f4a6                	sd	s1,104(sp)
  800180:	f0ca                	sd	s2,96(sp)
  800182:	e8d2                	sd	s4,80(sp)
  800184:	e4d6                	sd	s5,72(sp)
  800186:	e0da                	sd	s6,64(sp)
  800188:	fc5e                	sd	s7,56(sp)
  80018a:	f862                	sd	s8,48(sp)
  80018c:	f06a                	sd	s10,32(sp)
  80018e:	fc86                	sd	ra,120(sp)
  800190:	f8a2                	sd	s0,112(sp)
  800192:	ecce                	sd	s3,88(sp)
  800194:	f466                	sd	s9,40(sp)
  800196:	ec6e                	sd	s11,24(sp)
  800198:	892a                	mv	s2,a0
  80019a:	84ae                	mv	s1,a1
  80019c:	8d32                	mv	s10,a2
  80019e:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  8001a0:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  8001a2:	00000a17          	auipc	s4,0x0
  8001a6:	3b2a0a13          	addi	s4,s4,946 # 800554 <main+0x4c>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
  8001aa:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8001ae:	00000c17          	auipc	s8,0x0
  8001b2:	502c0c13          	addi	s8,s8,1282 # 8006b0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001b6:	000d4503          	lbu	a0,0(s10)
  8001ba:	02500793          	li	a5,37
  8001be:	001d0413          	addi	s0,s10,1
  8001c2:	00f50e63          	beq	a0,a5,8001de <vprintfmt+0x62>
            if (ch == '\0') {
  8001c6:	c521                	beqz	a0,80020e <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001c8:	02500993          	li	s3,37
  8001cc:	a011                	j	8001d0 <vprintfmt+0x54>
            if (ch == '\0') {
  8001ce:	c121                	beqz	a0,80020e <vprintfmt+0x92>
            putch(ch, putdat);
  8001d0:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001d2:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  8001d4:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001d6:	fff44503          	lbu	a0,-1(s0)
  8001da:	ff351ae3          	bne	a0,s3,8001ce <vprintfmt+0x52>
  8001de:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  8001e2:	02000793          	li	a5,32
        lflag = altflag = 0;
  8001e6:	4981                	li	s3,0
  8001e8:	4801                	li	a6,0
        width = precision = -1;
  8001ea:	5cfd                	li	s9,-1
  8001ec:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
  8001ee:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
  8001f2:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
  8001f4:	fdd6069b          	addiw	a3,a2,-35
  8001f8:	0ff6f693          	andi	a3,a3,255
  8001fc:	00140d13          	addi	s10,s0,1
  800200:	20d5e563          	bltu	a1,a3,80040a <vprintfmt+0x28e>
  800204:	068a                	slli	a3,a3,0x2
  800206:	96d2                	add	a3,a3,s4
  800208:	4294                	lw	a3,0(a3)
  80020a:	96d2                	add	a3,a3,s4
  80020c:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  80020e:	70e6                	ld	ra,120(sp)
  800210:	7446                	ld	s0,112(sp)
  800212:	74a6                	ld	s1,104(sp)
  800214:	7906                	ld	s2,96(sp)
  800216:	69e6                	ld	s3,88(sp)
  800218:	6a46                	ld	s4,80(sp)
  80021a:	6aa6                	ld	s5,72(sp)
  80021c:	6b06                	ld	s6,64(sp)
  80021e:	7be2                	ld	s7,56(sp)
  800220:	7c42                	ld	s8,48(sp)
  800222:	7ca2                	ld	s9,40(sp)
  800224:	7d02                	ld	s10,32(sp)
  800226:	6de2                	ld	s11,24(sp)
  800228:	6109                	addi	sp,sp,128
  80022a:	8082                	ret
    if (lflag >= 2) {
  80022c:	4705                	li	a4,1
  80022e:	008a8593          	addi	a1,s5,8
  800232:	01074463          	blt	a4,a6,80023a <vprintfmt+0xbe>
    else if (lflag) {
  800236:	26080363          	beqz	a6,80049c <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
  80023a:	000ab603          	ld	a2,0(s5)
  80023e:	46c1                	li	a3,16
  800240:	8aae                	mv	s5,a1
  800242:	a06d                	j	8002ec <vprintfmt+0x170>
            goto reswitch;
  800244:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  800248:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
  80024a:	846a                	mv	s0,s10
            goto reswitch;
  80024c:	b765                	j	8001f4 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
  80024e:	000aa503          	lw	a0,0(s5)
  800252:	85a6                	mv	a1,s1
  800254:	0aa1                	addi	s5,s5,8
  800256:	9902                	jalr	s2
            break;
  800258:	bfb9                	j	8001b6 <vprintfmt+0x3a>
    if (lflag >= 2) {
  80025a:	4705                	li	a4,1
  80025c:	008a8993          	addi	s3,s5,8
  800260:	01074463          	blt	a4,a6,800268 <vprintfmt+0xec>
    else if (lflag) {
  800264:	22080463          	beqz	a6,80048c <vprintfmt+0x310>
        return va_arg(*ap, long);
  800268:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
  80026c:	24044463          	bltz	s0,8004b4 <vprintfmt+0x338>
            num = getint(&ap, lflag);
  800270:	8622                	mv	a2,s0
  800272:	8ace                	mv	s5,s3
  800274:	46a9                	li	a3,10
  800276:	a89d                	j	8002ec <vprintfmt+0x170>
            err = va_arg(ap, int);
  800278:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80027c:	4761                	li	a4,24
            err = va_arg(ap, int);
  80027e:	0aa1                	addi	s5,s5,8
            if (err < 0) {
  800280:	41f7d69b          	sraiw	a3,a5,0x1f
  800284:	8fb5                	xor	a5,a5,a3
  800286:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80028a:	1ad74363          	blt	a4,a3,800430 <vprintfmt+0x2b4>
  80028e:	00369793          	slli	a5,a3,0x3
  800292:	97e2                	add	a5,a5,s8
  800294:	639c                	ld	a5,0(a5)
  800296:	18078d63          	beqz	a5,800430 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
  80029a:	86be                	mv	a3,a5
  80029c:	00000617          	auipc	a2,0x0
  8002a0:	5cc60613          	addi	a2,a2,1484 # 800868 <error_string+0x1b8>
  8002a4:	85a6                	mv	a1,s1
  8002a6:	854a                	mv	a0,s2
  8002a8:	240000ef          	jal	ra,8004e8 <printfmt>
  8002ac:	b729                	j	8001b6 <vprintfmt+0x3a>
            lflag ++;
  8002ae:	00144603          	lbu	a2,1(s0)
  8002b2:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
  8002b4:	846a                	mv	s0,s10
            goto reswitch;
  8002b6:	bf3d                	j	8001f4 <vprintfmt+0x78>
    if (lflag >= 2) {
  8002b8:	4705                	li	a4,1
  8002ba:	008a8593          	addi	a1,s5,8
  8002be:	01074463          	blt	a4,a6,8002c6 <vprintfmt+0x14a>
    else if (lflag) {
  8002c2:	1e080263          	beqz	a6,8004a6 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
  8002c6:	000ab603          	ld	a2,0(s5)
  8002ca:	46a1                	li	a3,8
  8002cc:	8aae                	mv	s5,a1
  8002ce:	a839                	j	8002ec <vprintfmt+0x170>
            putch('0', putdat);
  8002d0:	03000513          	li	a0,48
  8002d4:	85a6                	mv	a1,s1
  8002d6:	e03e                	sd	a5,0(sp)
  8002d8:	9902                	jalr	s2
            putch('x', putdat);
  8002da:	85a6                	mv	a1,s1
  8002dc:	07800513          	li	a0,120
  8002e0:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8002e2:	0aa1                	addi	s5,s5,8
  8002e4:	ff8ab603          	ld	a2,-8(s5)
            goto number;
  8002e8:	6782                	ld	a5,0(sp)
  8002ea:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
  8002ec:	876e                	mv	a4,s11
  8002ee:	85a6                	mv	a1,s1
  8002f0:	854a                	mv	a0,s2
  8002f2:	e1fff0ef          	jal	ra,800110 <printnum>
            break;
  8002f6:	b5c1                	j	8001b6 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
  8002f8:	000ab603          	ld	a2,0(s5)
  8002fc:	0aa1                	addi	s5,s5,8
  8002fe:	1c060663          	beqz	a2,8004ca <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
  800302:	00160413          	addi	s0,a2,1
  800306:	17b05c63          	blez	s11,80047e <vprintfmt+0x302>
  80030a:	02d00593          	li	a1,45
  80030e:	14b79263          	bne	a5,a1,800452 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800312:	00064783          	lbu	a5,0(a2)
  800316:	0007851b          	sext.w	a0,a5
  80031a:	c905                	beqz	a0,80034a <vprintfmt+0x1ce>
  80031c:	000cc563          	bltz	s9,800326 <vprintfmt+0x1aa>
  800320:	3cfd                	addiw	s9,s9,-1
  800322:	036c8263          	beq	s9,s6,800346 <vprintfmt+0x1ca>
                    putch('?', putdat);
  800326:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  800328:	18098463          	beqz	s3,8004b0 <vprintfmt+0x334>
  80032c:	3781                	addiw	a5,a5,-32
  80032e:	18fbf163          	bleu	a5,s7,8004b0 <vprintfmt+0x334>
                    putch('?', putdat);
  800332:	03f00513          	li	a0,63
  800336:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800338:	0405                	addi	s0,s0,1
  80033a:	fff44783          	lbu	a5,-1(s0)
  80033e:	3dfd                	addiw	s11,s11,-1
  800340:	0007851b          	sext.w	a0,a5
  800344:	fd61                	bnez	a0,80031c <vprintfmt+0x1a0>
            for (; width > 0; width --) {
  800346:	e7b058e3          	blez	s11,8001b6 <vprintfmt+0x3a>
  80034a:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  80034c:	85a6                	mv	a1,s1
  80034e:	02000513          	li	a0,32
  800352:	9902                	jalr	s2
            for (; width > 0; width --) {
  800354:	e60d81e3          	beqz	s11,8001b6 <vprintfmt+0x3a>
  800358:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  80035a:	85a6                	mv	a1,s1
  80035c:	02000513          	li	a0,32
  800360:	9902                	jalr	s2
            for (; width > 0; width --) {
  800362:	fe0d94e3          	bnez	s11,80034a <vprintfmt+0x1ce>
  800366:	bd81                	j	8001b6 <vprintfmt+0x3a>
    if (lflag >= 2) {
  800368:	4705                	li	a4,1
  80036a:	008a8593          	addi	a1,s5,8
  80036e:	01074463          	blt	a4,a6,800376 <vprintfmt+0x1fa>
    else if (lflag) {
  800372:	12080063          	beqz	a6,800492 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
  800376:	000ab603          	ld	a2,0(s5)
  80037a:	46a9                	li	a3,10
  80037c:	8aae                	mv	s5,a1
  80037e:	b7bd                	j	8002ec <vprintfmt+0x170>
  800380:	00144603          	lbu	a2,1(s0)
            padc = '-';
  800384:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
  800388:	846a                	mv	s0,s10
  80038a:	b5ad                	j	8001f4 <vprintfmt+0x78>
            putch(ch, putdat);
  80038c:	85a6                	mv	a1,s1
  80038e:	02500513          	li	a0,37
  800392:	9902                	jalr	s2
            break;
  800394:	b50d                	j	8001b6 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
  800396:	000aac83          	lw	s9,0(s5)
            goto process_precision;
  80039a:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  80039e:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
  8003a0:	846a                	mv	s0,s10
            if (width < 0)
  8003a2:	e40dd9e3          	bgez	s11,8001f4 <vprintfmt+0x78>
                width = precision, precision = -1;
  8003a6:	8de6                	mv	s11,s9
  8003a8:	5cfd                	li	s9,-1
  8003aa:	b5a9                	j	8001f4 <vprintfmt+0x78>
            goto reswitch;
  8003ac:	00144603          	lbu	a2,1(s0)
            padc = '0';
  8003b0:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
  8003b4:	846a                	mv	s0,s10
            goto reswitch;
  8003b6:	bd3d                	j	8001f4 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
  8003b8:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
  8003bc:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  8003c0:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  8003c2:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  8003c6:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  8003ca:	fcd56ce3          	bltu	a0,a3,8003a2 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
  8003ce:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8003d0:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
  8003d4:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
  8003d8:	0196873b          	addw	a4,a3,s9
  8003dc:	0017171b          	slliw	a4,a4,0x1
  8003e0:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
  8003e4:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
  8003e8:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  8003ec:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  8003f0:	fcd57fe3          	bleu	a3,a0,8003ce <vprintfmt+0x252>
  8003f4:	b77d                	j	8003a2 <vprintfmt+0x226>
            if (width < 0)
  8003f6:	fffdc693          	not	a3,s11
  8003fa:	96fd                	srai	a3,a3,0x3f
  8003fc:	00ddfdb3          	and	s11,s11,a3
  800400:	00144603          	lbu	a2,1(s0)
  800404:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
  800406:	846a                	mv	s0,s10
  800408:	b3f5                	j	8001f4 <vprintfmt+0x78>
            putch('%', putdat);
  80040a:	85a6                	mv	a1,s1
  80040c:	02500513          	li	a0,37
  800410:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  800412:	fff44703          	lbu	a4,-1(s0)
  800416:	02500793          	li	a5,37
  80041a:	8d22                	mv	s10,s0
  80041c:	d8f70de3          	beq	a4,a5,8001b6 <vprintfmt+0x3a>
  800420:	02500713          	li	a4,37
  800424:	1d7d                	addi	s10,s10,-1
  800426:	fffd4783          	lbu	a5,-1(s10)
  80042a:	fee79de3          	bne	a5,a4,800424 <vprintfmt+0x2a8>
  80042e:	b361                	j	8001b6 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  800430:	00000617          	auipc	a2,0x0
  800434:	42860613          	addi	a2,a2,1064 # 800858 <error_string+0x1a8>
  800438:	85a6                	mv	a1,s1
  80043a:	854a                	mv	a0,s2
  80043c:	0ac000ef          	jal	ra,8004e8 <printfmt>
  800440:	bb9d                	j	8001b6 <vprintfmt+0x3a>
                p = "(null)";
  800442:	00000617          	auipc	a2,0x0
  800446:	40e60613          	addi	a2,a2,1038 # 800850 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
  80044a:	00000417          	auipc	s0,0x0
  80044e:	40740413          	addi	s0,s0,1031 # 800851 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800452:	8532                	mv	a0,a2
  800454:	85e6                	mv	a1,s9
  800456:	e032                	sd	a2,0(sp)
  800458:	e43e                	sd	a5,8(sp)
  80045a:	c91ff0ef          	jal	ra,8000ea <strnlen>
  80045e:	40ad8dbb          	subw	s11,s11,a0
  800462:	6602                	ld	a2,0(sp)
  800464:	01b05d63          	blez	s11,80047e <vprintfmt+0x302>
  800468:	67a2                	ld	a5,8(sp)
  80046a:	2781                	sext.w	a5,a5
  80046c:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
  80046e:	6522                	ld	a0,8(sp)
  800470:	85a6                	mv	a1,s1
  800472:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  800474:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  800476:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  800478:	6602                	ld	a2,0(sp)
  80047a:	fe0d9ae3          	bnez	s11,80046e <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80047e:	00064783          	lbu	a5,0(a2)
  800482:	0007851b          	sext.w	a0,a5
  800486:	e8051be3          	bnez	a0,80031c <vprintfmt+0x1a0>
  80048a:	b335                	j	8001b6 <vprintfmt+0x3a>
        return va_arg(*ap, int);
  80048c:	000aa403          	lw	s0,0(s5)
  800490:	bbf1                	j	80026c <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
  800492:	000ae603          	lwu	a2,0(s5)
  800496:	46a9                	li	a3,10
  800498:	8aae                	mv	s5,a1
  80049a:	bd89                	j	8002ec <vprintfmt+0x170>
  80049c:	000ae603          	lwu	a2,0(s5)
  8004a0:	46c1                	li	a3,16
  8004a2:	8aae                	mv	s5,a1
  8004a4:	b5a1                	j	8002ec <vprintfmt+0x170>
  8004a6:	000ae603          	lwu	a2,0(s5)
  8004aa:	46a1                	li	a3,8
  8004ac:	8aae                	mv	s5,a1
  8004ae:	bd3d                	j	8002ec <vprintfmt+0x170>
                    putch(ch, putdat);
  8004b0:	9902                	jalr	s2
  8004b2:	b559                	j	800338 <vprintfmt+0x1bc>
                putch('-', putdat);
  8004b4:	85a6                	mv	a1,s1
  8004b6:	02d00513          	li	a0,45
  8004ba:	e03e                	sd	a5,0(sp)
  8004bc:	9902                	jalr	s2
                num = -(long long)num;
  8004be:	8ace                	mv	s5,s3
  8004c0:	40800633          	neg	a2,s0
  8004c4:	46a9                	li	a3,10
  8004c6:	6782                	ld	a5,0(sp)
  8004c8:	b515                	j	8002ec <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
  8004ca:	01b05663          	blez	s11,8004d6 <vprintfmt+0x35a>
  8004ce:	02d00693          	li	a3,45
  8004d2:	f6d798e3          	bne	a5,a3,800442 <vprintfmt+0x2c6>
  8004d6:	00000417          	auipc	s0,0x0
  8004da:	37b40413          	addi	s0,s0,891 # 800851 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004de:	02800513          	li	a0,40
  8004e2:	02800793          	li	a5,40
  8004e6:	bd1d                	j	80031c <vprintfmt+0x1a0>

00000000008004e8 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004e8:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  8004ea:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004ee:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004f0:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004f2:	ec06                	sd	ra,24(sp)
  8004f4:	f83a                	sd	a4,48(sp)
  8004f6:	fc3e                	sd	a5,56(sp)
  8004f8:	e0c2                	sd	a6,64(sp)
  8004fa:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  8004fc:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004fe:	c7fff0ef          	jal	ra,80017c <vprintfmt>
}
  800502:	60e2                	ld	ra,24(sp)
  800504:	6161                	addi	sp,sp,80
  800506:	8082                	ret

0000000000800508 <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
  800508:	1141                	addi	sp,sp,-16
    cprintf("Hello world!!.\n");
  80050a:	00000517          	auipc	a0,0x0
  80050e:	36650513          	addi	a0,a0,870 # 800870 <error_string+0x1c0>
main(void) {
  800512:	e406                	sd	ra,8(sp)
    cprintf("Hello world!!.\n");
  800514:	b97ff0ef          	jal	ra,8000aa <cprintf>
    cprintf("I am process %d.\n", getpid());
  800518:	b6fff0ef          	jal	ra,800086 <getpid>
  80051c:	85aa                	mv	a1,a0
  80051e:	00000517          	auipc	a0,0x0
  800522:	36250513          	addi	a0,a0,866 # 800880 <error_string+0x1d0>
  800526:	b85ff0ef          	jal	ra,8000aa <cprintf>
    cprintf("hello pass.\n");
  80052a:	00000517          	auipc	a0,0x0
  80052e:	36e50513          	addi	a0,a0,878 # 800898 <error_string+0x1e8>
  800532:	b79ff0ef          	jal	ra,8000aa <cprintf>
    return 0;
}
  800536:	60a2                	ld	ra,8(sp)
  800538:	4501                	li	a0,0
  80053a:	0141                	addi	sp,sp,16
  80053c:	8082                	ret
