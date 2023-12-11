
obj/__user_forktree.out:     file format elf64-littleriscv


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

0000000000800062 <sys_fork>:
}

int
sys_fork(void) {
    return syscall(SYS_fork);
  800062:	4509                	li	a0,2
  800064:	fbdff06f          	j	800020 <syscall>

0000000000800068 <sys_yield>:
    return syscall(SYS_wait, pid, store);
}

int
sys_yield(void) {
    return syscall(SYS_yield);
  800068:	4529                	li	a0,10
  80006a:	fb7ff06f          	j	800020 <syscall>

000000000080006e <sys_getpid>:
    return syscall(SYS_kill, pid);
}

int
sys_getpid(void) {
    return syscall(SYS_getpid);
  80006e:	4549                	li	a0,18
  800070:	fb1ff06f          	j	800020 <syscall>

0000000000800074 <sys_putc>:
}

int
sys_putc(int64_t c) {
    return syscall(SYS_putc, c);
  800074:	85aa                	mv	a1,a0
  800076:	4579                	li	a0,30
  800078:	fa9ff06f          	j	800020 <syscall>

000000000080007c <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  80007c:	1141                	addi	sp,sp,-16
  80007e:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  800080:	fdbff0ef          	jal	ra,80005a <sys_exit>
    cprintf("BUG: exit failed.\n");
  800084:	00000517          	auipc	a0,0x0
  800088:	5bc50513          	addi	a0,a0,1468 # 800640 <main+0x18>
  80008c:	032000ef          	jal	ra,8000be <cprintf>
    while (1);
  800090:	a001                	j	800090 <exit+0x14>

0000000000800092 <fork>:
}

int
fork(void) {
    return sys_fork();
  800092:	fd1ff06f          	j	800062 <sys_fork>

0000000000800096 <yield>:
    return sys_wait(pid, store);
}

void
yield(void) {
    sys_yield();
  800096:	fd3ff06f          	j	800068 <sys_yield>

000000000080009a <getpid>:
    return sys_kill(pid);
}

int
getpid(void) {
    return sys_getpid();
  80009a:	fd5ff06f          	j	80006e <sys_getpid>

000000000080009e <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  80009e:	054000ef          	jal	ra,8000f2 <umain>
1:  j 1b
  8000a2:	a001                	j	8000a2 <_start+0x4>

00000000008000a4 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  8000a4:	1141                	addi	sp,sp,-16
  8000a6:	e022                	sd	s0,0(sp)
  8000a8:	e406                	sd	ra,8(sp)
  8000aa:	842e                	mv	s0,a1
    sys_putc(c);
  8000ac:	fc9ff0ef          	jal	ra,800074 <sys_putc>
    (*cnt) ++;
  8000b0:	401c                	lw	a5,0(s0)
}
  8000b2:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
  8000b4:	2785                	addiw	a5,a5,1
  8000b6:	c01c                	sw	a5,0(s0)
}
  8000b8:	6402                	ld	s0,0(sp)
  8000ba:	0141                	addi	sp,sp,16
  8000bc:	8082                	ret

00000000008000be <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  8000be:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  8000c0:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  8000c4:	f42e                	sd	a1,40(sp)
  8000c6:	f832                	sd	a2,48(sp)
  8000c8:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000ca:	862a                	mv	a2,a0
  8000cc:	004c                	addi	a1,sp,4
  8000ce:	00000517          	auipc	a0,0x0
  8000d2:	fd650513          	addi	a0,a0,-42 # 8000a4 <cputch>
  8000d6:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
  8000d8:	ec06                	sd	ra,24(sp)
  8000da:	e0ba                	sd	a4,64(sp)
  8000dc:	e4be                	sd	a5,72(sp)
  8000de:	e8c2                	sd	a6,80(sp)
  8000e0:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
  8000e2:	e41a                	sd	t1,8(sp)
    int cnt = 0;
  8000e4:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000e6:	0e2000ef          	jal	ra,8001c8 <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  8000ea:	60e2                	ld	ra,24(sp)
  8000ec:	4512                	lw	a0,4(sp)
  8000ee:	6125                	addi	sp,sp,96
  8000f0:	8082                	ret

00000000008000f2 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  8000f2:	1141                	addi	sp,sp,-16
  8000f4:	e406                	sd	ra,8(sp)
    int ret = main();
  8000f6:	532000ef          	jal	ra,800628 <main>
    exit(ret);
  8000fa:	f83ff0ef          	jal	ra,80007c <exit>

00000000008000fe <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
  8000fe:	00054783          	lbu	a5,0(a0)
  800102:	cb91                	beqz	a5,800116 <strlen+0x18>
    size_t cnt = 0;
  800104:	4781                	li	a5,0
        cnt ++;
  800106:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
  800108:	00f50733          	add	a4,a0,a5
  80010c:	00074703          	lbu	a4,0(a4)
  800110:	fb7d                	bnez	a4,800106 <strlen+0x8>
    }
    return cnt;
}
  800112:	853e                	mv	a0,a5
  800114:	8082                	ret
    size_t cnt = 0;
  800116:	4781                	li	a5,0
}
  800118:	853e                	mv	a0,a5
  80011a:	8082                	ret

000000000080011c <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  80011c:	c185                	beqz	a1,80013c <strnlen+0x20>
  80011e:	00054783          	lbu	a5,0(a0)
  800122:	cf89                	beqz	a5,80013c <strnlen+0x20>
    size_t cnt = 0;
  800124:	4781                	li	a5,0
  800126:	a021                	j	80012e <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
  800128:	00074703          	lbu	a4,0(a4)
  80012c:	c711                	beqz	a4,800138 <strnlen+0x1c>
        cnt ++;
  80012e:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800130:	00f50733          	add	a4,a0,a5
  800134:	fef59ae3          	bne	a1,a5,800128 <strnlen+0xc>
    }
    return cnt;
}
  800138:	853e                	mv	a0,a5
  80013a:	8082                	ret
    size_t cnt = 0;
  80013c:	4781                	li	a5,0
}
  80013e:	853e                	mv	a0,a5
  800140:	8082                	ret

0000000000800142 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800142:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800146:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  800148:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80014c:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  80014e:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  800152:	f022                	sd	s0,32(sp)
  800154:	ec26                	sd	s1,24(sp)
  800156:	e84a                	sd	s2,16(sp)
  800158:	f406                	sd	ra,40(sp)
  80015a:	e44e                	sd	s3,8(sp)
  80015c:	84aa                	mv	s1,a0
  80015e:	892e                	mv	s2,a1
  800160:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  800164:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  800166:	03067e63          	bleu	a6,a2,8001a2 <printnum+0x60>
  80016a:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  80016c:	00805763          	blez	s0,80017a <printnum+0x38>
  800170:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800172:	85ca                	mv	a1,s2
  800174:	854e                	mv	a0,s3
  800176:	9482                	jalr	s1
        while (-- width > 0)
  800178:	fc65                	bnez	s0,800170 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  80017a:	1a02                	slli	s4,s4,0x20
  80017c:	020a5a13          	srli	s4,s4,0x20
  800180:	00000797          	auipc	a5,0x0
  800184:	6f878793          	addi	a5,a5,1784 # 800878 <error_string+0xc8>
  800188:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  80018a:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  80018c:	000a4503          	lbu	a0,0(s4)
}
  800190:	70a2                	ld	ra,40(sp)
  800192:	69a2                	ld	s3,8(sp)
  800194:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  800196:	85ca                	mv	a1,s2
  800198:	8326                	mv	t1,s1
}
  80019a:	6942                	ld	s2,16(sp)
  80019c:	64e2                	ld	s1,24(sp)
  80019e:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001a0:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
  8001a2:	03065633          	divu	a2,a2,a6
  8001a6:	8722                	mv	a4,s0
  8001a8:	f9bff0ef          	jal	ra,800142 <printnum>
  8001ac:	b7f9                	j	80017a <printnum+0x38>

00000000008001ae <sprintputch>:
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
    b->cnt ++;
  8001ae:	499c                	lw	a5,16(a1)
    if (b->buf < b->ebuf) {
  8001b0:	6198                	ld	a4,0(a1)
  8001b2:	6594                	ld	a3,8(a1)
    b->cnt ++;
  8001b4:	2785                	addiw	a5,a5,1
  8001b6:	c99c                	sw	a5,16(a1)
    if (b->buf < b->ebuf) {
  8001b8:	00d77763          	bleu	a3,a4,8001c6 <sprintputch+0x18>
        *b->buf ++ = ch;
  8001bc:	00170793          	addi	a5,a4,1
  8001c0:	e19c                	sd	a5,0(a1)
  8001c2:	00a70023          	sb	a0,0(a4)
    }
}
  8001c6:	8082                	ret

00000000008001c8 <vprintfmt>:
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001c8:	7119                	addi	sp,sp,-128
  8001ca:	f4a6                	sd	s1,104(sp)
  8001cc:	f0ca                	sd	s2,96(sp)
  8001ce:	e8d2                	sd	s4,80(sp)
  8001d0:	e4d6                	sd	s5,72(sp)
  8001d2:	e0da                	sd	s6,64(sp)
  8001d4:	fc5e                	sd	s7,56(sp)
  8001d6:	f862                	sd	s8,48(sp)
  8001d8:	f06a                	sd	s10,32(sp)
  8001da:	fc86                	sd	ra,120(sp)
  8001dc:	f8a2                	sd	s0,112(sp)
  8001de:	ecce                	sd	s3,88(sp)
  8001e0:	f466                	sd	s9,40(sp)
  8001e2:	ec6e                	sd	s11,24(sp)
  8001e4:	892a                	mv	s2,a0
  8001e6:	84ae                	mv	s1,a1
  8001e8:	8d32                	mv	s10,a2
  8001ea:	8ab6                	mv	s5,a3
        width = precision = -1;
  8001ec:	5b7d                	li	s6,-1
        switch (ch = *(unsigned char *)fmt ++) {
  8001ee:	00000a17          	auipc	s4,0x0
  8001f2:	466a0a13          	addi	s4,s4,1126 # 800654 <main+0x2c>
                if (altflag && (ch < ' ' || ch > '~')) {
  8001f6:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8001fa:	00000c17          	auipc	s8,0x0
  8001fe:	5b6c0c13          	addi	s8,s8,1462 # 8007b0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800202:	000d4503          	lbu	a0,0(s10)
  800206:	02500793          	li	a5,37
  80020a:	001d0413          	addi	s0,s10,1
  80020e:	00f50e63          	beq	a0,a5,80022a <vprintfmt+0x62>
            if (ch == '\0') {
  800212:	c521                	beqz	a0,80025a <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800214:	02500993          	li	s3,37
  800218:	a011                	j	80021c <vprintfmt+0x54>
            if (ch == '\0') {
  80021a:	c121                	beqz	a0,80025a <vprintfmt+0x92>
            putch(ch, putdat);
  80021c:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80021e:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  800220:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800222:	fff44503          	lbu	a0,-1(s0)
  800226:	ff351ae3          	bne	a0,s3,80021a <vprintfmt+0x52>
  80022a:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  80022e:	02000793          	li	a5,32
        lflag = altflag = 0;
  800232:	4981                	li	s3,0
  800234:	4801                	li	a6,0
        width = precision = -1;
  800236:	5cfd                	li	s9,-1
  800238:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
  80023a:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
  80023e:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
  800240:	fdd6069b          	addiw	a3,a2,-35
  800244:	0ff6f693          	andi	a3,a3,255
  800248:	00140d13          	addi	s10,s0,1
  80024c:	20d5e563          	bltu	a1,a3,800456 <vprintfmt+0x28e>
  800250:	068a                	slli	a3,a3,0x2
  800252:	96d2                	add	a3,a3,s4
  800254:	4294                	lw	a3,0(a3)
  800256:	96d2                	add	a3,a3,s4
  800258:	8682                	jr	a3
}
  80025a:	70e6                	ld	ra,120(sp)
  80025c:	7446                	ld	s0,112(sp)
  80025e:	74a6                	ld	s1,104(sp)
  800260:	7906                	ld	s2,96(sp)
  800262:	69e6                	ld	s3,88(sp)
  800264:	6a46                	ld	s4,80(sp)
  800266:	6aa6                	ld	s5,72(sp)
  800268:	6b06                	ld	s6,64(sp)
  80026a:	7be2                	ld	s7,56(sp)
  80026c:	7c42                	ld	s8,48(sp)
  80026e:	7ca2                	ld	s9,40(sp)
  800270:	7d02                	ld	s10,32(sp)
  800272:	6de2                	ld	s11,24(sp)
  800274:	6109                	addi	sp,sp,128
  800276:	8082                	ret
    if (lflag >= 2) {
  800278:	4705                	li	a4,1
  80027a:	008a8593          	addi	a1,s5,8
  80027e:	01074463          	blt	a4,a6,800286 <vprintfmt+0xbe>
    else if (lflag) {
  800282:	26080363          	beqz	a6,8004e8 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
  800286:	000ab603          	ld	a2,0(s5)
  80028a:	46c1                	li	a3,16
  80028c:	8aae                	mv	s5,a1
  80028e:	a06d                	j	800338 <vprintfmt+0x170>
            goto reswitch;
  800290:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  800294:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
  800296:	846a                	mv	s0,s10
            goto reswitch;
  800298:	b765                	j	800240 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
  80029a:	000aa503          	lw	a0,0(s5)
  80029e:	85a6                	mv	a1,s1
  8002a0:	0aa1                	addi	s5,s5,8
  8002a2:	9902                	jalr	s2
            break;
  8002a4:	bfb9                	j	800202 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8002a6:	4705                	li	a4,1
  8002a8:	008a8993          	addi	s3,s5,8
  8002ac:	01074463          	blt	a4,a6,8002b4 <vprintfmt+0xec>
    else if (lflag) {
  8002b0:	22080463          	beqz	a6,8004d8 <vprintfmt+0x310>
        return va_arg(*ap, long);
  8002b4:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
  8002b8:	24044463          	bltz	s0,800500 <vprintfmt+0x338>
            num = getint(&ap, lflag);
  8002bc:	8622                	mv	a2,s0
  8002be:	8ace                	mv	s5,s3
  8002c0:	46a9                	li	a3,10
  8002c2:	a89d                	j	800338 <vprintfmt+0x170>
            err = va_arg(ap, int);
  8002c4:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8002c8:	4761                	li	a4,24
            err = va_arg(ap, int);
  8002ca:	0aa1                	addi	s5,s5,8
            if (err < 0) {
  8002cc:	41f7d69b          	sraiw	a3,a5,0x1f
  8002d0:	8fb5                	xor	a5,a5,a3
  8002d2:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8002d6:	1ad74363          	blt	a4,a3,80047c <vprintfmt+0x2b4>
  8002da:	00369793          	slli	a5,a3,0x3
  8002de:	97e2                	add	a5,a5,s8
  8002e0:	639c                	ld	a5,0(a5)
  8002e2:	18078d63          	beqz	a5,80047c <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
  8002e6:	86be                	mv	a3,a5
  8002e8:	00000617          	auipc	a2,0x0
  8002ec:	68060613          	addi	a2,a2,1664 # 800968 <error_string+0x1b8>
  8002f0:	85a6                	mv	a1,s1
  8002f2:	854a                	mv	a0,s2
  8002f4:	240000ef          	jal	ra,800534 <printfmt>
  8002f8:	b729                	j	800202 <vprintfmt+0x3a>
            lflag ++;
  8002fa:	00144603          	lbu	a2,1(s0)
  8002fe:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
  800300:	846a                	mv	s0,s10
            goto reswitch;
  800302:	bf3d                	j	800240 <vprintfmt+0x78>
    if (lflag >= 2) {
  800304:	4705                	li	a4,1
  800306:	008a8593          	addi	a1,s5,8
  80030a:	01074463          	blt	a4,a6,800312 <vprintfmt+0x14a>
    else if (lflag) {
  80030e:	1e080263          	beqz	a6,8004f2 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
  800312:	000ab603          	ld	a2,0(s5)
  800316:	46a1                	li	a3,8
  800318:	8aae                	mv	s5,a1
  80031a:	a839                	j	800338 <vprintfmt+0x170>
            putch('0', putdat);
  80031c:	03000513          	li	a0,48
  800320:	85a6                	mv	a1,s1
  800322:	e03e                	sd	a5,0(sp)
  800324:	9902                	jalr	s2
            putch('x', putdat);
  800326:	85a6                	mv	a1,s1
  800328:	07800513          	li	a0,120
  80032c:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80032e:	0aa1                	addi	s5,s5,8
  800330:	ff8ab603          	ld	a2,-8(s5)
            goto number;
  800334:	6782                	ld	a5,0(sp)
  800336:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
  800338:	876e                	mv	a4,s11
  80033a:	85a6                	mv	a1,s1
  80033c:	854a                	mv	a0,s2
  80033e:	e05ff0ef          	jal	ra,800142 <printnum>
            break;
  800342:	b5c1                	j	800202 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
  800344:	000ab603          	ld	a2,0(s5)
  800348:	0aa1                	addi	s5,s5,8
  80034a:	1c060663          	beqz	a2,800516 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
  80034e:	00160413          	addi	s0,a2,1
  800352:	17b05c63          	blez	s11,8004ca <vprintfmt+0x302>
  800356:	02d00593          	li	a1,45
  80035a:	14b79263          	bne	a5,a1,80049e <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80035e:	00064783          	lbu	a5,0(a2)
  800362:	0007851b          	sext.w	a0,a5
  800366:	c905                	beqz	a0,800396 <vprintfmt+0x1ce>
  800368:	000cc563          	bltz	s9,800372 <vprintfmt+0x1aa>
  80036c:	3cfd                	addiw	s9,s9,-1
  80036e:	036c8263          	beq	s9,s6,800392 <vprintfmt+0x1ca>
                    putch('?', putdat);
  800372:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  800374:	18098463          	beqz	s3,8004fc <vprintfmt+0x334>
  800378:	3781                	addiw	a5,a5,-32
  80037a:	18fbf163          	bleu	a5,s7,8004fc <vprintfmt+0x334>
                    putch('?', putdat);
  80037e:	03f00513          	li	a0,63
  800382:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800384:	0405                	addi	s0,s0,1
  800386:	fff44783          	lbu	a5,-1(s0)
  80038a:	3dfd                	addiw	s11,s11,-1
  80038c:	0007851b          	sext.w	a0,a5
  800390:	fd61                	bnez	a0,800368 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
  800392:	e7b058e3          	blez	s11,800202 <vprintfmt+0x3a>
  800396:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  800398:	85a6                	mv	a1,s1
  80039a:	02000513          	li	a0,32
  80039e:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003a0:	e60d81e3          	beqz	s11,800202 <vprintfmt+0x3a>
  8003a4:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003a6:	85a6                	mv	a1,s1
  8003a8:	02000513          	li	a0,32
  8003ac:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003ae:	fe0d94e3          	bnez	s11,800396 <vprintfmt+0x1ce>
  8003b2:	bd81                	j	800202 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8003b4:	4705                	li	a4,1
  8003b6:	008a8593          	addi	a1,s5,8
  8003ba:	01074463          	blt	a4,a6,8003c2 <vprintfmt+0x1fa>
    else if (lflag) {
  8003be:	12080063          	beqz	a6,8004de <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
  8003c2:	000ab603          	ld	a2,0(s5)
  8003c6:	46a9                	li	a3,10
  8003c8:	8aae                	mv	s5,a1
  8003ca:	b7bd                	j	800338 <vprintfmt+0x170>
  8003cc:	00144603          	lbu	a2,1(s0)
            padc = '-';
  8003d0:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
  8003d4:	846a                	mv	s0,s10
  8003d6:	b5ad                	j	800240 <vprintfmt+0x78>
            putch(ch, putdat);
  8003d8:	85a6                	mv	a1,s1
  8003da:	02500513          	li	a0,37
  8003de:	9902                	jalr	s2
            break;
  8003e0:	b50d                	j	800202 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
  8003e2:	000aac83          	lw	s9,0(s5)
            goto process_precision;
  8003e6:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  8003ea:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
  8003ec:	846a                	mv	s0,s10
            if (width < 0)
  8003ee:	e40dd9e3          	bgez	s11,800240 <vprintfmt+0x78>
                width = precision, precision = -1;
  8003f2:	8de6                	mv	s11,s9
  8003f4:	5cfd                	li	s9,-1
  8003f6:	b5a9                	j	800240 <vprintfmt+0x78>
            goto reswitch;
  8003f8:	00144603          	lbu	a2,1(s0)
            padc = '0';
  8003fc:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
  800400:	846a                	mv	s0,s10
            goto reswitch;
  800402:	bd3d                	j	800240 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
  800404:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
  800408:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  80040c:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  80040e:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  800412:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  800416:	fcd56ce3          	bltu	a0,a3,8003ee <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
  80041a:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  80041c:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
  800420:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
  800424:	0196873b          	addw	a4,a3,s9
  800428:	0017171b          	slliw	a4,a4,0x1
  80042c:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
  800430:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
  800434:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  800438:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  80043c:	fcd57fe3          	bleu	a3,a0,80041a <vprintfmt+0x252>
  800440:	b77d                	j	8003ee <vprintfmt+0x226>
            if (width < 0)
  800442:	fffdc693          	not	a3,s11
  800446:	96fd                	srai	a3,a3,0x3f
  800448:	00ddfdb3          	and	s11,s11,a3
  80044c:	00144603          	lbu	a2,1(s0)
  800450:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
  800452:	846a                	mv	s0,s10
  800454:	b3f5                	j	800240 <vprintfmt+0x78>
            putch('%', putdat);
  800456:	85a6                	mv	a1,s1
  800458:	02500513          	li	a0,37
  80045c:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  80045e:	fff44703          	lbu	a4,-1(s0)
  800462:	02500793          	li	a5,37
  800466:	8d22                	mv	s10,s0
  800468:	d8f70de3          	beq	a4,a5,800202 <vprintfmt+0x3a>
  80046c:	02500713          	li	a4,37
  800470:	1d7d                	addi	s10,s10,-1
  800472:	fffd4783          	lbu	a5,-1(s10)
  800476:	fee79de3          	bne	a5,a4,800470 <vprintfmt+0x2a8>
  80047a:	b361                	j	800202 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  80047c:	00000617          	auipc	a2,0x0
  800480:	4dc60613          	addi	a2,a2,1244 # 800958 <error_string+0x1a8>
  800484:	85a6                	mv	a1,s1
  800486:	854a                	mv	a0,s2
  800488:	0ac000ef          	jal	ra,800534 <printfmt>
  80048c:	bb9d                	j	800202 <vprintfmt+0x3a>
                p = "(null)";
  80048e:	00000617          	auipc	a2,0x0
  800492:	4c260613          	addi	a2,a2,1218 # 800950 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
  800496:	00000417          	auipc	s0,0x0
  80049a:	4bb40413          	addi	s0,s0,1211 # 800951 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  80049e:	8532                	mv	a0,a2
  8004a0:	85e6                	mv	a1,s9
  8004a2:	e032                	sd	a2,0(sp)
  8004a4:	e43e                	sd	a5,8(sp)
  8004a6:	c77ff0ef          	jal	ra,80011c <strnlen>
  8004aa:	40ad8dbb          	subw	s11,s11,a0
  8004ae:	6602                	ld	a2,0(sp)
  8004b0:	01b05d63          	blez	s11,8004ca <vprintfmt+0x302>
  8004b4:	67a2                	ld	a5,8(sp)
  8004b6:	2781                	sext.w	a5,a5
  8004b8:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
  8004ba:	6522                	ld	a0,8(sp)
  8004bc:	85a6                	mv	a1,s1
  8004be:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004c0:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  8004c2:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004c4:	6602                	ld	a2,0(sp)
  8004c6:	fe0d9ae3          	bnez	s11,8004ba <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004ca:	00064783          	lbu	a5,0(a2)
  8004ce:	0007851b          	sext.w	a0,a5
  8004d2:	e8051be3          	bnez	a0,800368 <vprintfmt+0x1a0>
  8004d6:	b335                	j	800202 <vprintfmt+0x3a>
        return va_arg(*ap, int);
  8004d8:	000aa403          	lw	s0,0(s5)
  8004dc:	bbf1                	j	8002b8 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
  8004de:	000ae603          	lwu	a2,0(s5)
  8004e2:	46a9                	li	a3,10
  8004e4:	8aae                	mv	s5,a1
  8004e6:	bd89                	j	800338 <vprintfmt+0x170>
  8004e8:	000ae603          	lwu	a2,0(s5)
  8004ec:	46c1                	li	a3,16
  8004ee:	8aae                	mv	s5,a1
  8004f0:	b5a1                	j	800338 <vprintfmt+0x170>
  8004f2:	000ae603          	lwu	a2,0(s5)
  8004f6:	46a1                	li	a3,8
  8004f8:	8aae                	mv	s5,a1
  8004fa:	bd3d                	j	800338 <vprintfmt+0x170>
                    putch(ch, putdat);
  8004fc:	9902                	jalr	s2
  8004fe:	b559                	j	800384 <vprintfmt+0x1bc>
                putch('-', putdat);
  800500:	85a6                	mv	a1,s1
  800502:	02d00513          	li	a0,45
  800506:	e03e                	sd	a5,0(sp)
  800508:	9902                	jalr	s2
                num = -(long long)num;
  80050a:	8ace                	mv	s5,s3
  80050c:	40800633          	neg	a2,s0
  800510:	46a9                	li	a3,10
  800512:	6782                	ld	a5,0(sp)
  800514:	b515                	j	800338 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
  800516:	01b05663          	blez	s11,800522 <vprintfmt+0x35a>
  80051a:	02d00693          	li	a3,45
  80051e:	f6d798e3          	bne	a5,a3,80048e <vprintfmt+0x2c6>
  800522:	00000417          	auipc	s0,0x0
  800526:	42f40413          	addi	s0,s0,1071 # 800951 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80052a:	02800513          	li	a0,40
  80052e:	02800793          	li	a5,40
  800532:	bd1d                	j	800368 <vprintfmt+0x1a0>

0000000000800534 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800534:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  800536:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80053a:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80053c:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80053e:	ec06                	sd	ra,24(sp)
  800540:	f83a                	sd	a4,48(sp)
  800542:	fc3e                	sd	a5,56(sp)
  800544:	e0c2                	sd	a6,64(sp)
  800546:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800548:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80054a:	c7fff0ef          	jal	ra,8001c8 <vprintfmt>
}
  80054e:	60e2                	ld	ra,24(sp)
  800550:	6161                	addi	sp,sp,80
  800552:	8082                	ret

0000000000800554 <vsnprintf>:
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
    struct sprintbuf b = {str, str + size - 1, 0};
  800554:	15fd                	addi	a1,a1,-1
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  800556:	7179                	addi	sp,sp,-48
    struct sprintbuf b = {str, str + size - 1, 0};
  800558:	95aa                	add	a1,a1,a0
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  80055a:	f406                	sd	ra,40(sp)
    struct sprintbuf b = {str, str + size - 1, 0};
  80055c:	e42a                	sd	a0,8(sp)
  80055e:	e82e                	sd	a1,16(sp)
  800560:	cc02                	sw	zero,24(sp)
    if (str == NULL || b.buf > b.ebuf) {
  800562:	c10d                	beqz	a0,800584 <vsnprintf+0x30>
  800564:	02a5e063          	bltu	a1,a0,800584 <vsnprintf+0x30>
        return -E_INVAL;
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  800568:	00000517          	auipc	a0,0x0
  80056c:	c4650513          	addi	a0,a0,-954 # 8001ae <sprintputch>
  800570:	002c                	addi	a1,sp,8
  800572:	c57ff0ef          	jal	ra,8001c8 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  800576:	67a2                	ld	a5,8(sp)
  800578:	00078023          	sb	zero,0(a5)
    return b.cnt;
  80057c:	4562                	lw	a0,24(sp)
}
  80057e:	70a2                	ld	ra,40(sp)
  800580:	6145                	addi	sp,sp,48
  800582:	8082                	ret
        return -E_INVAL;
  800584:	5575                	li	a0,-3
  800586:	bfe5                	j	80057e <vsnprintf+0x2a>

0000000000800588 <snprintf>:
snprintf(char *str, size_t size, const char *fmt, ...) {
  800588:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  80058a:	02810313          	addi	t1,sp,40
snprintf(char *str, size_t size, const char *fmt, ...) {
  80058e:	f436                	sd	a3,40(sp)
    cnt = vsnprintf(str, size, fmt, ap);
  800590:	869a                	mv	a3,t1
snprintf(char *str, size_t size, const char *fmt, ...) {
  800592:	ec06                	sd	ra,24(sp)
  800594:	f83a                	sd	a4,48(sp)
  800596:	fc3e                	sd	a5,56(sp)
  800598:	e0c2                	sd	a6,64(sp)
  80059a:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  80059c:	e41a                	sd	t1,8(sp)
    cnt = vsnprintf(str, size, fmt, ap);
  80059e:	fb7ff0ef          	jal	ra,800554 <vsnprintf>
}
  8005a2:	60e2                	ld	ra,24(sp)
  8005a4:	6161                	addi	sp,sp,80
  8005a6:	8082                	ret

00000000008005a8 <forktree>:
        exit(0);
    }
}

void
forktree(const char *cur) {
  8005a8:	1141                	addi	sp,sp,-16
  8005aa:	e406                	sd	ra,8(sp)
  8005ac:	e022                	sd	s0,0(sp)
  8005ae:	842a                	mv	s0,a0
    cprintf("%04x: I am '%s'\n", getpid(), cur);
  8005b0:	aebff0ef          	jal	ra,80009a <getpid>
  8005b4:	8622                	mv	a2,s0
  8005b6:	85aa                	mv	a1,a0
  8005b8:	00000517          	auipc	a0,0x0
  8005bc:	3c050513          	addi	a0,a0,960 # 800978 <error_string+0x1c8>
  8005c0:	affff0ef          	jal	ra,8000be <cprintf>

    forkchild(cur, '0');
  8005c4:	8522                	mv	a0,s0
  8005c6:	03000593          	li	a1,48
  8005ca:	014000ef          	jal	ra,8005de <forkchild>
    forkchild(cur, '1');
  8005ce:	8522                	mv	a0,s0
}
  8005d0:	6402                	ld	s0,0(sp)
  8005d2:	60a2                	ld	ra,8(sp)
    forkchild(cur, '1');
  8005d4:	03100593          	li	a1,49
}
  8005d8:	0141                	addi	sp,sp,16
    forkchild(cur, '1');
  8005da:	0040006f          	j	8005de <forkchild>

00000000008005de <forkchild>:
forkchild(const char *cur, char branch) {
  8005de:	7179                	addi	sp,sp,-48
  8005e0:	f022                	sd	s0,32(sp)
  8005e2:	ec26                	sd	s1,24(sp)
  8005e4:	f406                	sd	ra,40(sp)
  8005e6:	842a                	mv	s0,a0
  8005e8:	84ae                	mv	s1,a1
    if (strlen(cur) >= DEPTH)
  8005ea:	b15ff0ef          	jal	ra,8000fe <strlen>
  8005ee:	478d                	li	a5,3
  8005f0:	00a7f763          	bleu	a0,a5,8005fe <forkchild+0x20>
}
  8005f4:	70a2                	ld	ra,40(sp)
  8005f6:	7402                	ld	s0,32(sp)
  8005f8:	64e2                	ld	s1,24(sp)
  8005fa:	6145                	addi	sp,sp,48
  8005fc:	8082                	ret
    snprintf(nxt, DEPTH + 1, "%s%c", cur, branch);
  8005fe:	8726                	mv	a4,s1
  800600:	86a2                	mv	a3,s0
  800602:	00000617          	auipc	a2,0x0
  800606:	36e60613          	addi	a2,a2,878 # 800970 <error_string+0x1c0>
  80060a:	4595                	li	a1,5
  80060c:	0028                	addi	a0,sp,8
  80060e:	f7bff0ef          	jal	ra,800588 <snprintf>
    if (fork() == 0) {
  800612:	a81ff0ef          	jal	ra,800092 <fork>
  800616:	fd79                	bnez	a0,8005f4 <forkchild+0x16>
        forktree(nxt);
  800618:	0028                	addi	a0,sp,8
  80061a:	f8fff0ef          	jal	ra,8005a8 <forktree>
        yield();
  80061e:	a79ff0ef          	jal	ra,800096 <yield>
        exit(0);
  800622:	4501                	li	a0,0
  800624:	a59ff0ef          	jal	ra,80007c <exit>

0000000000800628 <main>:

int
main(void) {
  800628:	1141                	addi	sp,sp,-16
    forktree("");
  80062a:	00000517          	auipc	a0,0x0
  80062e:	35e50513          	addi	a0,a0,862 # 800988 <error_string+0x1d8>
main(void) {
  800632:	e406                	sd	ra,8(sp)
    forktree("");
  800634:	f75ff0ef          	jal	ra,8005a8 <forktree>
    return 0;
}
  800638:	60a2                	ld	ra,8(sp)
  80063a:	4501                	li	a0,0
  80063c:	0141                	addi	sp,sp,16
  80063e:	8082                	ret
