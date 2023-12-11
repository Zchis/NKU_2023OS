
obj/__user_yield.out:     file format elf64-littleriscv


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

0000000000800062 <sys_yield>:
    return syscall(SYS_wait, pid, store);
}

int
sys_yield(void) {
    return syscall(SYS_yield);
  800062:	4529                	li	a0,10
  800064:	fbdff06f          	j	800020 <syscall>

0000000000800068 <sys_getpid>:
    return syscall(SYS_kill, pid);
}

int
sys_getpid(void) {
    return syscall(SYS_getpid);
  800068:	4549                	li	a0,18
  80006a:	fb7ff06f          	j	800020 <syscall>

000000000080006e <sys_putc>:
}

int
sys_putc(int64_t c) {
    return syscall(SYS_putc, c);
  80006e:	85aa                	mv	a1,a0
  800070:	4579                	li	a0,30
  800072:	fafff06f          	j	800020 <syscall>

0000000000800076 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  800076:	1141                	addi	sp,sp,-16
  800078:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  80007a:	fe1ff0ef          	jal	ra,80005a <sys_exit>
    cprintf("BUG: exit failed.\n");
  80007e:	00000517          	auipc	a0,0x0
  800082:	50250513          	addi	a0,a0,1282 # 800580 <main+0x6e>
  800086:	02e000ef          	jal	ra,8000b4 <cprintf>
    while (1);
  80008a:	a001                	j	80008a <exit+0x14>

000000000080008c <yield>:
    return sys_wait(pid, store);
}

void
yield(void) {
    sys_yield();
  80008c:	fd7ff06f          	j	800062 <sys_yield>

0000000000800090 <getpid>:
    return sys_kill(pid);
}

int
getpid(void) {
    return sys_getpid();
  800090:	fd9ff06f          	j	800068 <sys_getpid>

0000000000800094 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800094:	054000ef          	jal	ra,8000e8 <umain>
1:  j 1b
  800098:	a001                	j	800098 <_start+0x4>

000000000080009a <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  80009a:	1141                	addi	sp,sp,-16
  80009c:	e022                	sd	s0,0(sp)
  80009e:	e406                	sd	ra,8(sp)
  8000a0:	842e                	mv	s0,a1
    sys_putc(c);
  8000a2:	fcdff0ef          	jal	ra,80006e <sys_putc>
    (*cnt) ++;
  8000a6:	401c                	lw	a5,0(s0)
}
  8000a8:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
  8000aa:	2785                	addiw	a5,a5,1
  8000ac:	c01c                	sw	a5,0(s0)
}
  8000ae:	6402                	ld	s0,0(sp)
  8000b0:	0141                	addi	sp,sp,16
  8000b2:	8082                	ret

00000000008000b4 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  8000b4:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  8000b6:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  8000ba:	f42e                	sd	a1,40(sp)
  8000bc:	f832                	sd	a2,48(sp)
  8000be:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000c0:	862a                	mv	a2,a0
  8000c2:	004c                	addi	a1,sp,4
  8000c4:	00000517          	auipc	a0,0x0
  8000c8:	fd650513          	addi	a0,a0,-42 # 80009a <cputch>
  8000cc:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
  8000ce:	ec06                	sd	ra,24(sp)
  8000d0:	e0ba                	sd	a4,64(sp)
  8000d2:	e4be                	sd	a5,72(sp)
  8000d4:	e8c2                	sd	a6,80(sp)
  8000d6:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
  8000d8:	e41a                	sd	t1,8(sp)
    int cnt = 0;
  8000da:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000dc:	0aa000ef          	jal	ra,800186 <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  8000e0:	60e2                	ld	ra,24(sp)
  8000e2:	4512                	lw	a0,4(sp)
  8000e4:	6125                	addi	sp,sp,96
  8000e6:	8082                	ret

00000000008000e8 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  8000e8:	1141                	addi	sp,sp,-16
  8000ea:	e406                	sd	ra,8(sp)
    int ret = main();
  8000ec:	426000ef          	jal	ra,800512 <main>
    exit(ret);
  8000f0:	f87ff0ef          	jal	ra,800076 <exit>

00000000008000f4 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  8000f4:	c185                	beqz	a1,800114 <strnlen+0x20>
  8000f6:	00054783          	lbu	a5,0(a0)
  8000fa:	cf89                	beqz	a5,800114 <strnlen+0x20>
    size_t cnt = 0;
  8000fc:	4781                	li	a5,0
  8000fe:	a021                	j	800106 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
  800100:	00074703          	lbu	a4,0(a4)
  800104:	c711                	beqz	a4,800110 <strnlen+0x1c>
        cnt ++;
  800106:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800108:	00f50733          	add	a4,a0,a5
  80010c:	fef59ae3          	bne	a1,a5,800100 <strnlen+0xc>
    }
    return cnt;
}
  800110:	853e                	mv	a0,a5
  800112:	8082                	ret
    size_t cnt = 0;
  800114:	4781                	li	a5,0
}
  800116:	853e                	mv	a0,a5
  800118:	8082                	ret

000000000080011a <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  80011a:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80011e:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  800120:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800124:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  800126:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  80012a:	f022                	sd	s0,32(sp)
  80012c:	ec26                	sd	s1,24(sp)
  80012e:	e84a                	sd	s2,16(sp)
  800130:	f406                	sd	ra,40(sp)
  800132:	e44e                	sd	s3,8(sp)
  800134:	84aa                	mv	s1,a0
  800136:	892e                	mv	s2,a1
  800138:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  80013c:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  80013e:	03067e63          	bleu	a6,a2,80017a <printnum+0x60>
  800142:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800144:	00805763          	blez	s0,800152 <printnum+0x38>
  800148:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  80014a:	85ca                	mv	a1,s2
  80014c:	854e                	mv	a0,s3
  80014e:	9482                	jalr	s1
        while (-- width > 0)
  800150:	fc65                	bnez	s0,800148 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800152:	1a02                	slli	s4,s4,0x20
  800154:	020a5a13          	srli	s4,s4,0x20
  800158:	00000797          	auipc	a5,0x0
  80015c:	66078793          	addi	a5,a5,1632 # 8007b8 <error_string+0xc8>
  800160:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  800162:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  800164:	000a4503          	lbu	a0,0(s4)
}
  800168:	70a2                	ld	ra,40(sp)
  80016a:	69a2                	ld	s3,8(sp)
  80016c:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  80016e:	85ca                	mv	a1,s2
  800170:	8326                	mv	t1,s1
}
  800172:	6942                	ld	s2,16(sp)
  800174:	64e2                	ld	s1,24(sp)
  800176:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  800178:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
  80017a:	03065633          	divu	a2,a2,a6
  80017e:	8722                	mv	a4,s0
  800180:	f9bff0ef          	jal	ra,80011a <printnum>
  800184:	b7f9                	j	800152 <printnum+0x38>

0000000000800186 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  800186:	7119                	addi	sp,sp,-128
  800188:	f4a6                	sd	s1,104(sp)
  80018a:	f0ca                	sd	s2,96(sp)
  80018c:	e8d2                	sd	s4,80(sp)
  80018e:	e4d6                	sd	s5,72(sp)
  800190:	e0da                	sd	s6,64(sp)
  800192:	fc5e                	sd	s7,56(sp)
  800194:	f862                	sd	s8,48(sp)
  800196:	f06a                	sd	s10,32(sp)
  800198:	fc86                	sd	ra,120(sp)
  80019a:	f8a2                	sd	s0,112(sp)
  80019c:	ecce                	sd	s3,88(sp)
  80019e:	f466                	sd	s9,40(sp)
  8001a0:	ec6e                	sd	s11,24(sp)
  8001a2:	892a                	mv	s2,a0
  8001a4:	84ae                	mv	s1,a1
  8001a6:	8d32                	mv	s10,a2
  8001a8:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  8001aa:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  8001ac:	00000a17          	auipc	s4,0x0
  8001b0:	3e8a0a13          	addi	s4,s4,1000 # 800594 <main+0x82>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
  8001b4:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8001b8:	00000c17          	auipc	s8,0x0
  8001bc:	538c0c13          	addi	s8,s8,1336 # 8006f0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001c0:	000d4503          	lbu	a0,0(s10)
  8001c4:	02500793          	li	a5,37
  8001c8:	001d0413          	addi	s0,s10,1
  8001cc:	00f50e63          	beq	a0,a5,8001e8 <vprintfmt+0x62>
            if (ch == '\0') {
  8001d0:	c521                	beqz	a0,800218 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001d2:	02500993          	li	s3,37
  8001d6:	a011                	j	8001da <vprintfmt+0x54>
            if (ch == '\0') {
  8001d8:	c121                	beqz	a0,800218 <vprintfmt+0x92>
            putch(ch, putdat);
  8001da:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001dc:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  8001de:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001e0:	fff44503          	lbu	a0,-1(s0)
  8001e4:	ff351ae3          	bne	a0,s3,8001d8 <vprintfmt+0x52>
  8001e8:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  8001ec:	02000793          	li	a5,32
        lflag = altflag = 0;
  8001f0:	4981                	li	s3,0
  8001f2:	4801                	li	a6,0
        width = precision = -1;
  8001f4:	5cfd                	li	s9,-1
  8001f6:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
  8001f8:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
  8001fc:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
  8001fe:	fdd6069b          	addiw	a3,a2,-35
  800202:	0ff6f693          	andi	a3,a3,255
  800206:	00140d13          	addi	s10,s0,1
  80020a:	20d5e563          	bltu	a1,a3,800414 <vprintfmt+0x28e>
  80020e:	068a                	slli	a3,a3,0x2
  800210:	96d2                	add	a3,a3,s4
  800212:	4294                	lw	a3,0(a3)
  800214:	96d2                	add	a3,a3,s4
  800216:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  800218:	70e6                	ld	ra,120(sp)
  80021a:	7446                	ld	s0,112(sp)
  80021c:	74a6                	ld	s1,104(sp)
  80021e:	7906                	ld	s2,96(sp)
  800220:	69e6                	ld	s3,88(sp)
  800222:	6a46                	ld	s4,80(sp)
  800224:	6aa6                	ld	s5,72(sp)
  800226:	6b06                	ld	s6,64(sp)
  800228:	7be2                	ld	s7,56(sp)
  80022a:	7c42                	ld	s8,48(sp)
  80022c:	7ca2                	ld	s9,40(sp)
  80022e:	7d02                	ld	s10,32(sp)
  800230:	6de2                	ld	s11,24(sp)
  800232:	6109                	addi	sp,sp,128
  800234:	8082                	ret
    if (lflag >= 2) {
  800236:	4705                	li	a4,1
  800238:	008a8593          	addi	a1,s5,8
  80023c:	01074463          	blt	a4,a6,800244 <vprintfmt+0xbe>
    else if (lflag) {
  800240:	26080363          	beqz	a6,8004a6 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
  800244:	000ab603          	ld	a2,0(s5)
  800248:	46c1                	li	a3,16
  80024a:	8aae                	mv	s5,a1
  80024c:	a06d                	j	8002f6 <vprintfmt+0x170>
            goto reswitch;
  80024e:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  800252:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
  800254:	846a                	mv	s0,s10
            goto reswitch;
  800256:	b765                	j	8001fe <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
  800258:	000aa503          	lw	a0,0(s5)
  80025c:	85a6                	mv	a1,s1
  80025e:	0aa1                	addi	s5,s5,8
  800260:	9902                	jalr	s2
            break;
  800262:	bfb9                	j	8001c0 <vprintfmt+0x3a>
    if (lflag >= 2) {
  800264:	4705                	li	a4,1
  800266:	008a8993          	addi	s3,s5,8
  80026a:	01074463          	blt	a4,a6,800272 <vprintfmt+0xec>
    else if (lflag) {
  80026e:	22080463          	beqz	a6,800496 <vprintfmt+0x310>
        return va_arg(*ap, long);
  800272:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
  800276:	24044463          	bltz	s0,8004be <vprintfmt+0x338>
            num = getint(&ap, lflag);
  80027a:	8622                	mv	a2,s0
  80027c:	8ace                	mv	s5,s3
  80027e:	46a9                	li	a3,10
  800280:	a89d                	j	8002f6 <vprintfmt+0x170>
            err = va_arg(ap, int);
  800282:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800286:	4761                	li	a4,24
            err = va_arg(ap, int);
  800288:	0aa1                	addi	s5,s5,8
            if (err < 0) {
  80028a:	41f7d69b          	sraiw	a3,a5,0x1f
  80028e:	8fb5                	xor	a5,a5,a3
  800290:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800294:	1ad74363          	blt	a4,a3,80043a <vprintfmt+0x2b4>
  800298:	00369793          	slli	a5,a3,0x3
  80029c:	97e2                	add	a5,a5,s8
  80029e:	639c                	ld	a5,0(a5)
  8002a0:	18078d63          	beqz	a5,80043a <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
  8002a4:	86be                	mv	a3,a5
  8002a6:	00000617          	auipc	a2,0x0
  8002aa:	60260613          	addi	a2,a2,1538 # 8008a8 <error_string+0x1b8>
  8002ae:	85a6                	mv	a1,s1
  8002b0:	854a                	mv	a0,s2
  8002b2:	240000ef          	jal	ra,8004f2 <printfmt>
  8002b6:	b729                	j	8001c0 <vprintfmt+0x3a>
            lflag ++;
  8002b8:	00144603          	lbu	a2,1(s0)
  8002bc:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
  8002be:	846a                	mv	s0,s10
            goto reswitch;
  8002c0:	bf3d                	j	8001fe <vprintfmt+0x78>
    if (lflag >= 2) {
  8002c2:	4705                	li	a4,1
  8002c4:	008a8593          	addi	a1,s5,8
  8002c8:	01074463          	blt	a4,a6,8002d0 <vprintfmt+0x14a>
    else if (lflag) {
  8002cc:	1e080263          	beqz	a6,8004b0 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
  8002d0:	000ab603          	ld	a2,0(s5)
  8002d4:	46a1                	li	a3,8
  8002d6:	8aae                	mv	s5,a1
  8002d8:	a839                	j	8002f6 <vprintfmt+0x170>
            putch('0', putdat);
  8002da:	03000513          	li	a0,48
  8002de:	85a6                	mv	a1,s1
  8002e0:	e03e                	sd	a5,0(sp)
  8002e2:	9902                	jalr	s2
            putch('x', putdat);
  8002e4:	85a6                	mv	a1,s1
  8002e6:	07800513          	li	a0,120
  8002ea:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8002ec:	0aa1                	addi	s5,s5,8
  8002ee:	ff8ab603          	ld	a2,-8(s5)
            goto number;
  8002f2:	6782                	ld	a5,0(sp)
  8002f4:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
  8002f6:	876e                	mv	a4,s11
  8002f8:	85a6                	mv	a1,s1
  8002fa:	854a                	mv	a0,s2
  8002fc:	e1fff0ef          	jal	ra,80011a <printnum>
            break;
  800300:	b5c1                	j	8001c0 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
  800302:	000ab603          	ld	a2,0(s5)
  800306:	0aa1                	addi	s5,s5,8
  800308:	1c060663          	beqz	a2,8004d4 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
  80030c:	00160413          	addi	s0,a2,1
  800310:	17b05c63          	blez	s11,800488 <vprintfmt+0x302>
  800314:	02d00593          	li	a1,45
  800318:	14b79263          	bne	a5,a1,80045c <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80031c:	00064783          	lbu	a5,0(a2)
  800320:	0007851b          	sext.w	a0,a5
  800324:	c905                	beqz	a0,800354 <vprintfmt+0x1ce>
  800326:	000cc563          	bltz	s9,800330 <vprintfmt+0x1aa>
  80032a:	3cfd                	addiw	s9,s9,-1
  80032c:	036c8263          	beq	s9,s6,800350 <vprintfmt+0x1ca>
                    putch('?', putdat);
  800330:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  800332:	18098463          	beqz	s3,8004ba <vprintfmt+0x334>
  800336:	3781                	addiw	a5,a5,-32
  800338:	18fbf163          	bleu	a5,s7,8004ba <vprintfmt+0x334>
                    putch('?', putdat);
  80033c:	03f00513          	li	a0,63
  800340:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800342:	0405                	addi	s0,s0,1
  800344:	fff44783          	lbu	a5,-1(s0)
  800348:	3dfd                	addiw	s11,s11,-1
  80034a:	0007851b          	sext.w	a0,a5
  80034e:	fd61                	bnez	a0,800326 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
  800350:	e7b058e3          	blez	s11,8001c0 <vprintfmt+0x3a>
  800354:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  800356:	85a6                	mv	a1,s1
  800358:	02000513          	li	a0,32
  80035c:	9902                	jalr	s2
            for (; width > 0; width --) {
  80035e:	e60d81e3          	beqz	s11,8001c0 <vprintfmt+0x3a>
  800362:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  800364:	85a6                	mv	a1,s1
  800366:	02000513          	li	a0,32
  80036a:	9902                	jalr	s2
            for (; width > 0; width --) {
  80036c:	fe0d94e3          	bnez	s11,800354 <vprintfmt+0x1ce>
  800370:	bd81                	j	8001c0 <vprintfmt+0x3a>
    if (lflag >= 2) {
  800372:	4705                	li	a4,1
  800374:	008a8593          	addi	a1,s5,8
  800378:	01074463          	blt	a4,a6,800380 <vprintfmt+0x1fa>
    else if (lflag) {
  80037c:	12080063          	beqz	a6,80049c <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
  800380:	000ab603          	ld	a2,0(s5)
  800384:	46a9                	li	a3,10
  800386:	8aae                	mv	s5,a1
  800388:	b7bd                	j	8002f6 <vprintfmt+0x170>
  80038a:	00144603          	lbu	a2,1(s0)
            padc = '-';
  80038e:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
  800392:	846a                	mv	s0,s10
  800394:	b5ad                	j	8001fe <vprintfmt+0x78>
            putch(ch, putdat);
  800396:	85a6                	mv	a1,s1
  800398:	02500513          	li	a0,37
  80039c:	9902                	jalr	s2
            break;
  80039e:	b50d                	j	8001c0 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
  8003a0:	000aac83          	lw	s9,0(s5)
            goto process_precision;
  8003a4:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  8003a8:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
  8003aa:	846a                	mv	s0,s10
            if (width < 0)
  8003ac:	e40dd9e3          	bgez	s11,8001fe <vprintfmt+0x78>
                width = precision, precision = -1;
  8003b0:	8de6                	mv	s11,s9
  8003b2:	5cfd                	li	s9,-1
  8003b4:	b5a9                	j	8001fe <vprintfmt+0x78>
            goto reswitch;
  8003b6:	00144603          	lbu	a2,1(s0)
            padc = '0';
  8003ba:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
  8003be:	846a                	mv	s0,s10
            goto reswitch;
  8003c0:	bd3d                	j	8001fe <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
  8003c2:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
  8003c6:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  8003ca:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  8003cc:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  8003d0:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  8003d4:	fcd56ce3          	bltu	a0,a3,8003ac <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
  8003d8:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8003da:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
  8003de:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
  8003e2:	0196873b          	addw	a4,a3,s9
  8003e6:	0017171b          	slliw	a4,a4,0x1
  8003ea:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
  8003ee:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
  8003f2:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  8003f6:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  8003fa:	fcd57fe3          	bleu	a3,a0,8003d8 <vprintfmt+0x252>
  8003fe:	b77d                	j	8003ac <vprintfmt+0x226>
            if (width < 0)
  800400:	fffdc693          	not	a3,s11
  800404:	96fd                	srai	a3,a3,0x3f
  800406:	00ddfdb3          	and	s11,s11,a3
  80040a:	00144603          	lbu	a2,1(s0)
  80040e:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
  800410:	846a                	mv	s0,s10
  800412:	b3f5                	j	8001fe <vprintfmt+0x78>
            putch('%', putdat);
  800414:	85a6                	mv	a1,s1
  800416:	02500513          	li	a0,37
  80041a:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  80041c:	fff44703          	lbu	a4,-1(s0)
  800420:	02500793          	li	a5,37
  800424:	8d22                	mv	s10,s0
  800426:	d8f70de3          	beq	a4,a5,8001c0 <vprintfmt+0x3a>
  80042a:	02500713          	li	a4,37
  80042e:	1d7d                	addi	s10,s10,-1
  800430:	fffd4783          	lbu	a5,-1(s10)
  800434:	fee79de3          	bne	a5,a4,80042e <vprintfmt+0x2a8>
  800438:	b361                	j	8001c0 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  80043a:	00000617          	auipc	a2,0x0
  80043e:	45e60613          	addi	a2,a2,1118 # 800898 <error_string+0x1a8>
  800442:	85a6                	mv	a1,s1
  800444:	854a                	mv	a0,s2
  800446:	0ac000ef          	jal	ra,8004f2 <printfmt>
  80044a:	bb9d                	j	8001c0 <vprintfmt+0x3a>
                p = "(null)";
  80044c:	00000617          	auipc	a2,0x0
  800450:	44460613          	addi	a2,a2,1092 # 800890 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
  800454:	00000417          	auipc	s0,0x0
  800458:	43d40413          	addi	s0,s0,1085 # 800891 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  80045c:	8532                	mv	a0,a2
  80045e:	85e6                	mv	a1,s9
  800460:	e032                	sd	a2,0(sp)
  800462:	e43e                	sd	a5,8(sp)
  800464:	c91ff0ef          	jal	ra,8000f4 <strnlen>
  800468:	40ad8dbb          	subw	s11,s11,a0
  80046c:	6602                	ld	a2,0(sp)
  80046e:	01b05d63          	blez	s11,800488 <vprintfmt+0x302>
  800472:	67a2                	ld	a5,8(sp)
  800474:	2781                	sext.w	a5,a5
  800476:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
  800478:	6522                	ld	a0,8(sp)
  80047a:	85a6                	mv	a1,s1
  80047c:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  80047e:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  800480:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  800482:	6602                	ld	a2,0(sp)
  800484:	fe0d9ae3          	bnez	s11,800478 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800488:	00064783          	lbu	a5,0(a2)
  80048c:	0007851b          	sext.w	a0,a5
  800490:	e8051be3          	bnez	a0,800326 <vprintfmt+0x1a0>
  800494:	b335                	j	8001c0 <vprintfmt+0x3a>
        return va_arg(*ap, int);
  800496:	000aa403          	lw	s0,0(s5)
  80049a:	bbf1                	j	800276 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
  80049c:	000ae603          	lwu	a2,0(s5)
  8004a0:	46a9                	li	a3,10
  8004a2:	8aae                	mv	s5,a1
  8004a4:	bd89                	j	8002f6 <vprintfmt+0x170>
  8004a6:	000ae603          	lwu	a2,0(s5)
  8004aa:	46c1                	li	a3,16
  8004ac:	8aae                	mv	s5,a1
  8004ae:	b5a1                	j	8002f6 <vprintfmt+0x170>
  8004b0:	000ae603          	lwu	a2,0(s5)
  8004b4:	46a1                	li	a3,8
  8004b6:	8aae                	mv	s5,a1
  8004b8:	bd3d                	j	8002f6 <vprintfmt+0x170>
                    putch(ch, putdat);
  8004ba:	9902                	jalr	s2
  8004bc:	b559                	j	800342 <vprintfmt+0x1bc>
                putch('-', putdat);
  8004be:	85a6                	mv	a1,s1
  8004c0:	02d00513          	li	a0,45
  8004c4:	e03e                	sd	a5,0(sp)
  8004c6:	9902                	jalr	s2
                num = -(long long)num;
  8004c8:	8ace                	mv	s5,s3
  8004ca:	40800633          	neg	a2,s0
  8004ce:	46a9                	li	a3,10
  8004d0:	6782                	ld	a5,0(sp)
  8004d2:	b515                	j	8002f6 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
  8004d4:	01b05663          	blez	s11,8004e0 <vprintfmt+0x35a>
  8004d8:	02d00693          	li	a3,45
  8004dc:	f6d798e3          	bne	a5,a3,80044c <vprintfmt+0x2c6>
  8004e0:	00000417          	auipc	s0,0x0
  8004e4:	3b140413          	addi	s0,s0,945 # 800891 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004e8:	02800513          	li	a0,40
  8004ec:	02800793          	li	a5,40
  8004f0:	bd1d                	j	800326 <vprintfmt+0x1a0>

00000000008004f2 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004f2:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  8004f4:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004f8:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004fa:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004fc:	ec06                	sd	ra,24(sp)
  8004fe:	f83a                	sd	a4,48(sp)
  800500:	fc3e                	sd	a5,56(sp)
  800502:	e0c2                	sd	a6,64(sp)
  800504:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800506:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800508:	c7fff0ef          	jal	ra,800186 <vprintfmt>
}
  80050c:	60e2                	ld	ra,24(sp)
  80050e:	6161                	addi	sp,sp,80
  800510:	8082                	ret

0000000000800512 <main>:
#include <ulib.h>
#include <stdio.h>

int
main(void) {
  800512:	1101                	addi	sp,sp,-32
  800514:	ec06                	sd	ra,24(sp)
  800516:	e822                	sd	s0,16(sp)
  800518:	e426                	sd	s1,8(sp)
  80051a:	e04a                	sd	s2,0(sp)
    int i;
    cprintf("Hello, I am process %d.\n", getpid());
  80051c:	b75ff0ef          	jal	ra,800090 <getpid>
  800520:	85aa                	mv	a1,a0
  800522:	00000517          	auipc	a0,0x0
  800526:	38e50513          	addi	a0,a0,910 # 8008b0 <error_string+0x1c0>
  80052a:	b8bff0ef          	jal	ra,8000b4 <cprintf>
    for (i = 0; i < 5; i ++) {
  80052e:	4401                	li	s0,0
        yield();
        cprintf("Back in process %d, iteration %d.\n", getpid(), i);
  800530:	00000917          	auipc	s2,0x0
  800534:	3a090913          	addi	s2,s2,928 # 8008d0 <error_string+0x1e0>
    for (i = 0; i < 5; i ++) {
  800538:	4495                	li	s1,5
        yield();
  80053a:	b53ff0ef          	jal	ra,80008c <yield>
        cprintf("Back in process %d, iteration %d.\n", getpid(), i);
  80053e:	b53ff0ef          	jal	ra,800090 <getpid>
  800542:	8622                	mv	a2,s0
  800544:	85aa                	mv	a1,a0
    for (i = 0; i < 5; i ++) {
  800546:	2405                	addiw	s0,s0,1
        cprintf("Back in process %d, iteration %d.\n", getpid(), i);
  800548:	854a                	mv	a0,s2
  80054a:	b6bff0ef          	jal	ra,8000b4 <cprintf>
    for (i = 0; i < 5; i ++) {
  80054e:	fe9416e3          	bne	s0,s1,80053a <main+0x28>
    }
    cprintf("All done in process %d.\n", getpid());
  800552:	b3fff0ef          	jal	ra,800090 <getpid>
  800556:	85aa                	mv	a1,a0
  800558:	00000517          	auipc	a0,0x0
  80055c:	3a050513          	addi	a0,a0,928 # 8008f8 <error_string+0x208>
  800560:	b55ff0ef          	jal	ra,8000b4 <cprintf>
    cprintf("yield pass.\n");
  800564:	00000517          	auipc	a0,0x0
  800568:	3b450513          	addi	a0,a0,948 # 800918 <error_string+0x228>
  80056c:	b49ff0ef          	jal	ra,8000b4 <cprintf>
    return 0;
}
  800570:	60e2                	ld	ra,24(sp)
  800572:	6442                	ld	s0,16(sp)
  800574:	64a2                	ld	s1,8(sp)
  800576:	6902                	ld	s2,0(sp)
  800578:	4501                	li	a0,0
  80057a:	6105                	addi	sp,sp,32
  80057c:	8082                	ret
