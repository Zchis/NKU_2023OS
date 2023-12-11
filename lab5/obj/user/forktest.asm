
obj/__user_forktest.out:     file format elf64-littleriscv


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
  800032:	5fa50513          	addi	a0,a0,1530 # 800628 <main+0xae>
__panic(const char *file, int line, const char *fmt, ...) {
  800036:	ec06                	sd	ra,24(sp)
  800038:	f436                	sd	a3,40(sp)
  80003a:	f83a                	sd	a4,48(sp)
  80003c:	e0c2                	sd	a6,64(sp)
  80003e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800040:	e43e                	sd	a5,8(sp)
    cprintf("user panic at %s:%d:\n    ", file, line);
  800042:	0da000ef          	jal	ra,80011c <cprintf>
    vcprintf(fmt, ap);
  800046:	65a2                	ld	a1,8(sp)
  800048:	8522                	mv	a0,s0
  80004a:	0b2000ef          	jal	ra,8000fc <vcprintf>
    cprintf("\n");
  80004e:	00000517          	auipc	a0,0x0
  800052:	5fa50513          	addi	a0,a0,1530 # 800648 <main+0xce>
  800056:	0c6000ef          	jal	ra,80011c <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  80005a:	5559                	li	a0,-10
  80005c:	05e000ef          	jal	ra,8000ba <exit>

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

00000000008000a2 <sys_fork>:
}

int
sys_fork(void) {
    return syscall(SYS_fork);
  8000a2:	4509                	li	a0,2
  8000a4:	fbdff06f          	j	800060 <syscall>

00000000008000a8 <sys_wait>:
}

int
sys_wait(int64_t pid, int *store) {
    return syscall(SYS_wait, pid, store);
  8000a8:	862e                	mv	a2,a1
  8000aa:	85aa                	mv	a1,a0
  8000ac:	450d                	li	a0,3
  8000ae:	fb3ff06f          	j	800060 <syscall>

00000000008000b2 <sys_putc>:
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
    return syscall(SYS_putc, c);
  8000b2:	85aa                	mv	a1,a0
  8000b4:	4579                	li	a0,30
  8000b6:	fabff06f          	j	800060 <syscall>

00000000008000ba <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8000ba:	1141                	addi	sp,sp,-16
  8000bc:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  8000be:	fddff0ef          	jal	ra,80009a <sys_exit>
    cprintf("BUG: exit failed.\n");
  8000c2:	00000517          	auipc	a0,0x0
  8000c6:	58e50513          	addi	a0,a0,1422 # 800650 <main+0xd6>
  8000ca:	052000ef          	jal	ra,80011c <cprintf>
    while (1);
  8000ce:	a001                	j	8000ce <exit+0x14>

00000000008000d0 <fork>:
}

int
fork(void) {
    return sys_fork();
  8000d0:	fd3ff06f          	j	8000a2 <sys_fork>

00000000008000d4 <wait>:
}

int
wait(void) {
    return sys_wait(0, NULL);
  8000d4:	4581                	li	a1,0
  8000d6:	4501                	li	a0,0
  8000d8:	fd1ff06f          	j	8000a8 <sys_wait>

00000000008000dc <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  8000dc:	074000ef          	jal	ra,800150 <umain>
1:  j 1b
  8000e0:	a001                	j	8000e0 <_start+0x4>

00000000008000e2 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  8000e2:	1141                	addi	sp,sp,-16
  8000e4:	e022                	sd	s0,0(sp)
  8000e6:	e406                	sd	ra,8(sp)
  8000e8:	842e                	mv	s0,a1
    sys_putc(c);
  8000ea:	fc9ff0ef          	jal	ra,8000b2 <sys_putc>
    (*cnt) ++;
  8000ee:	401c                	lw	a5,0(s0)
}
  8000f0:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
  8000f2:	2785                	addiw	a5,a5,1
  8000f4:	c01c                	sw	a5,0(s0)
}
  8000f6:	6402                	ld	s0,0(sp)
  8000f8:	0141                	addi	sp,sp,16
  8000fa:	8082                	ret

00000000008000fc <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  8000fc:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000fe:	86ae                	mv	a3,a1
  800100:	862a                	mv	a2,a0
  800102:	006c                	addi	a1,sp,12
  800104:	00000517          	auipc	a0,0x0
  800108:	fde50513          	addi	a0,a0,-34 # 8000e2 <cputch>
vcprintf(const char *fmt, va_list ap) {
  80010c:	ec06                	sd	ra,24(sp)
    int cnt = 0;
  80010e:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800110:	0de000ef          	jal	ra,8001ee <vprintfmt>
    return cnt;
}
  800114:	60e2                	ld	ra,24(sp)
  800116:	4532                	lw	a0,12(sp)
  800118:	6105                	addi	sp,sp,32
  80011a:	8082                	ret

000000000080011c <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  80011c:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  80011e:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  800122:	f42e                	sd	a1,40(sp)
  800124:	f832                	sd	a2,48(sp)
  800126:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800128:	862a                	mv	a2,a0
  80012a:	004c                	addi	a1,sp,4
  80012c:	00000517          	auipc	a0,0x0
  800130:	fb650513          	addi	a0,a0,-74 # 8000e2 <cputch>
  800134:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
  800136:	ec06                	sd	ra,24(sp)
  800138:	e0ba                	sd	a4,64(sp)
  80013a:	e4be                	sd	a5,72(sp)
  80013c:	e8c2                	sd	a6,80(sp)
  80013e:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
  800140:	e41a                	sd	t1,8(sp)
    int cnt = 0;
  800142:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800144:	0aa000ef          	jal	ra,8001ee <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  800148:	60e2                	ld	ra,24(sp)
  80014a:	4512                	lw	a0,4(sp)
  80014c:	6125                	addi	sp,sp,96
  80014e:	8082                	ret

0000000000800150 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  800150:	1141                	addi	sp,sp,-16
  800152:	e406                	sd	ra,8(sp)
    int ret = main();
  800154:	426000ef          	jal	ra,80057a <main>
    exit(ret);
  800158:	f63ff0ef          	jal	ra,8000ba <exit>

000000000080015c <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  80015c:	c185                	beqz	a1,80017c <strnlen+0x20>
  80015e:	00054783          	lbu	a5,0(a0)
  800162:	cf89                	beqz	a5,80017c <strnlen+0x20>
    size_t cnt = 0;
  800164:	4781                	li	a5,0
  800166:	a021                	j	80016e <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
  800168:	00074703          	lbu	a4,0(a4)
  80016c:	c711                	beqz	a4,800178 <strnlen+0x1c>
        cnt ++;
  80016e:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800170:	00f50733          	add	a4,a0,a5
  800174:	fef59ae3          	bne	a1,a5,800168 <strnlen+0xc>
    }
    return cnt;
}
  800178:	853e                	mv	a0,a5
  80017a:	8082                	ret
    size_t cnt = 0;
  80017c:	4781                	li	a5,0
}
  80017e:	853e                	mv	a0,a5
  800180:	8082                	ret

0000000000800182 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800182:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800186:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  800188:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80018c:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  80018e:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  800192:	f022                	sd	s0,32(sp)
  800194:	ec26                	sd	s1,24(sp)
  800196:	e84a                	sd	s2,16(sp)
  800198:	f406                	sd	ra,40(sp)
  80019a:	e44e                	sd	s3,8(sp)
  80019c:	84aa                	mv	s1,a0
  80019e:	892e                	mv	s2,a1
  8001a0:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  8001a4:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  8001a6:	03067e63          	bleu	a6,a2,8001e2 <printnum+0x60>
  8001aa:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  8001ac:	00805763          	blez	s0,8001ba <printnum+0x38>
  8001b0:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  8001b2:	85ca                	mv	a1,s2
  8001b4:	854e                	mv	a0,s3
  8001b6:	9482                	jalr	s1
        while (-- width > 0)
  8001b8:	fc65                	bnez	s0,8001b0 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  8001ba:	1a02                	slli	s4,s4,0x20
  8001bc:	020a5a13          	srli	s4,s4,0x20
  8001c0:	00000797          	auipc	a5,0x0
  8001c4:	6c878793          	addi	a5,a5,1736 # 800888 <error_string+0xc8>
  8001c8:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001ca:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001cc:	000a4503          	lbu	a0,0(s4)
}
  8001d0:	70a2                	ld	ra,40(sp)
  8001d2:	69a2                	ld	s3,8(sp)
  8001d4:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001d6:	85ca                	mv	a1,s2
  8001d8:	8326                	mv	t1,s1
}
  8001da:	6942                	ld	s2,16(sp)
  8001dc:	64e2                	ld	s1,24(sp)
  8001de:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001e0:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
  8001e2:	03065633          	divu	a2,a2,a6
  8001e6:	8722                	mv	a4,s0
  8001e8:	f9bff0ef          	jal	ra,800182 <printnum>
  8001ec:	b7f9                	j	8001ba <printnum+0x38>

00000000008001ee <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001ee:	7119                	addi	sp,sp,-128
  8001f0:	f4a6                	sd	s1,104(sp)
  8001f2:	f0ca                	sd	s2,96(sp)
  8001f4:	e8d2                	sd	s4,80(sp)
  8001f6:	e4d6                	sd	s5,72(sp)
  8001f8:	e0da                	sd	s6,64(sp)
  8001fa:	fc5e                	sd	s7,56(sp)
  8001fc:	f862                	sd	s8,48(sp)
  8001fe:	f06a                	sd	s10,32(sp)
  800200:	fc86                	sd	ra,120(sp)
  800202:	f8a2                	sd	s0,112(sp)
  800204:	ecce                	sd	s3,88(sp)
  800206:	f466                	sd	s9,40(sp)
  800208:	ec6e                	sd	s11,24(sp)
  80020a:	892a                	mv	s2,a0
  80020c:	84ae                	mv	s1,a1
  80020e:	8d32                	mv	s10,a2
  800210:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  800212:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  800214:	00000a17          	auipc	s4,0x0
  800218:	450a0a13          	addi	s4,s4,1104 # 800664 <main+0xea>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
  80021c:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800220:	00000c17          	auipc	s8,0x0
  800224:	5a0c0c13          	addi	s8,s8,1440 # 8007c0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800228:	000d4503          	lbu	a0,0(s10)
  80022c:	02500793          	li	a5,37
  800230:	001d0413          	addi	s0,s10,1
  800234:	00f50e63          	beq	a0,a5,800250 <vprintfmt+0x62>
            if (ch == '\0') {
  800238:	c521                	beqz	a0,800280 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80023a:	02500993          	li	s3,37
  80023e:	a011                	j	800242 <vprintfmt+0x54>
            if (ch == '\0') {
  800240:	c121                	beqz	a0,800280 <vprintfmt+0x92>
            putch(ch, putdat);
  800242:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800244:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  800246:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800248:	fff44503          	lbu	a0,-1(s0)
  80024c:	ff351ae3          	bne	a0,s3,800240 <vprintfmt+0x52>
  800250:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  800254:	02000793          	li	a5,32
        lflag = altflag = 0;
  800258:	4981                	li	s3,0
  80025a:	4801                	li	a6,0
        width = precision = -1;
  80025c:	5cfd                	li	s9,-1
  80025e:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
  800260:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
  800264:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
  800266:	fdd6069b          	addiw	a3,a2,-35
  80026a:	0ff6f693          	andi	a3,a3,255
  80026e:	00140d13          	addi	s10,s0,1
  800272:	20d5e563          	bltu	a1,a3,80047c <vprintfmt+0x28e>
  800276:	068a                	slli	a3,a3,0x2
  800278:	96d2                	add	a3,a3,s4
  80027a:	4294                	lw	a3,0(a3)
  80027c:	96d2                	add	a3,a3,s4
  80027e:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  800280:	70e6                	ld	ra,120(sp)
  800282:	7446                	ld	s0,112(sp)
  800284:	74a6                	ld	s1,104(sp)
  800286:	7906                	ld	s2,96(sp)
  800288:	69e6                	ld	s3,88(sp)
  80028a:	6a46                	ld	s4,80(sp)
  80028c:	6aa6                	ld	s5,72(sp)
  80028e:	6b06                	ld	s6,64(sp)
  800290:	7be2                	ld	s7,56(sp)
  800292:	7c42                	ld	s8,48(sp)
  800294:	7ca2                	ld	s9,40(sp)
  800296:	7d02                	ld	s10,32(sp)
  800298:	6de2                	ld	s11,24(sp)
  80029a:	6109                	addi	sp,sp,128
  80029c:	8082                	ret
    if (lflag >= 2) {
  80029e:	4705                	li	a4,1
  8002a0:	008a8593          	addi	a1,s5,8
  8002a4:	01074463          	blt	a4,a6,8002ac <vprintfmt+0xbe>
    else if (lflag) {
  8002a8:	26080363          	beqz	a6,80050e <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
  8002ac:	000ab603          	ld	a2,0(s5)
  8002b0:	46c1                	li	a3,16
  8002b2:	8aae                	mv	s5,a1
  8002b4:	a06d                	j	80035e <vprintfmt+0x170>
            goto reswitch;
  8002b6:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  8002ba:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
  8002bc:	846a                	mv	s0,s10
            goto reswitch;
  8002be:	b765                	j	800266 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
  8002c0:	000aa503          	lw	a0,0(s5)
  8002c4:	85a6                	mv	a1,s1
  8002c6:	0aa1                	addi	s5,s5,8
  8002c8:	9902                	jalr	s2
            break;
  8002ca:	bfb9                	j	800228 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8002cc:	4705                	li	a4,1
  8002ce:	008a8993          	addi	s3,s5,8
  8002d2:	01074463          	blt	a4,a6,8002da <vprintfmt+0xec>
    else if (lflag) {
  8002d6:	22080463          	beqz	a6,8004fe <vprintfmt+0x310>
        return va_arg(*ap, long);
  8002da:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
  8002de:	24044463          	bltz	s0,800526 <vprintfmt+0x338>
            num = getint(&ap, lflag);
  8002e2:	8622                	mv	a2,s0
  8002e4:	8ace                	mv	s5,s3
  8002e6:	46a9                	li	a3,10
  8002e8:	a89d                	j	80035e <vprintfmt+0x170>
            err = va_arg(ap, int);
  8002ea:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8002ee:	4761                	li	a4,24
            err = va_arg(ap, int);
  8002f0:	0aa1                	addi	s5,s5,8
            if (err < 0) {
  8002f2:	41f7d69b          	sraiw	a3,a5,0x1f
  8002f6:	8fb5                	xor	a5,a5,a3
  8002f8:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8002fc:	1ad74363          	blt	a4,a3,8004a2 <vprintfmt+0x2b4>
  800300:	00369793          	slli	a5,a3,0x3
  800304:	97e2                	add	a5,a5,s8
  800306:	639c                	ld	a5,0(a5)
  800308:	18078d63          	beqz	a5,8004a2 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
  80030c:	86be                	mv	a3,a5
  80030e:	00000617          	auipc	a2,0x0
  800312:	66a60613          	addi	a2,a2,1642 # 800978 <error_string+0x1b8>
  800316:	85a6                	mv	a1,s1
  800318:	854a                	mv	a0,s2
  80031a:	240000ef          	jal	ra,80055a <printfmt>
  80031e:	b729                	j	800228 <vprintfmt+0x3a>
            lflag ++;
  800320:	00144603          	lbu	a2,1(s0)
  800324:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
  800326:	846a                	mv	s0,s10
            goto reswitch;
  800328:	bf3d                	j	800266 <vprintfmt+0x78>
    if (lflag >= 2) {
  80032a:	4705                	li	a4,1
  80032c:	008a8593          	addi	a1,s5,8
  800330:	01074463          	blt	a4,a6,800338 <vprintfmt+0x14a>
    else if (lflag) {
  800334:	1e080263          	beqz	a6,800518 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
  800338:	000ab603          	ld	a2,0(s5)
  80033c:	46a1                	li	a3,8
  80033e:	8aae                	mv	s5,a1
  800340:	a839                	j	80035e <vprintfmt+0x170>
            putch('0', putdat);
  800342:	03000513          	li	a0,48
  800346:	85a6                	mv	a1,s1
  800348:	e03e                	sd	a5,0(sp)
  80034a:	9902                	jalr	s2
            putch('x', putdat);
  80034c:	85a6                	mv	a1,s1
  80034e:	07800513          	li	a0,120
  800352:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800354:	0aa1                	addi	s5,s5,8
  800356:	ff8ab603          	ld	a2,-8(s5)
            goto number;
  80035a:	6782                	ld	a5,0(sp)
  80035c:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
  80035e:	876e                	mv	a4,s11
  800360:	85a6                	mv	a1,s1
  800362:	854a                	mv	a0,s2
  800364:	e1fff0ef          	jal	ra,800182 <printnum>
            break;
  800368:	b5c1                	j	800228 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
  80036a:	000ab603          	ld	a2,0(s5)
  80036e:	0aa1                	addi	s5,s5,8
  800370:	1c060663          	beqz	a2,80053c <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
  800374:	00160413          	addi	s0,a2,1
  800378:	17b05c63          	blez	s11,8004f0 <vprintfmt+0x302>
  80037c:	02d00593          	li	a1,45
  800380:	14b79263          	bne	a5,a1,8004c4 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800384:	00064783          	lbu	a5,0(a2)
  800388:	0007851b          	sext.w	a0,a5
  80038c:	c905                	beqz	a0,8003bc <vprintfmt+0x1ce>
  80038e:	000cc563          	bltz	s9,800398 <vprintfmt+0x1aa>
  800392:	3cfd                	addiw	s9,s9,-1
  800394:	036c8263          	beq	s9,s6,8003b8 <vprintfmt+0x1ca>
                    putch('?', putdat);
  800398:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  80039a:	18098463          	beqz	s3,800522 <vprintfmt+0x334>
  80039e:	3781                	addiw	a5,a5,-32
  8003a0:	18fbf163          	bleu	a5,s7,800522 <vprintfmt+0x334>
                    putch('?', putdat);
  8003a4:	03f00513          	li	a0,63
  8003a8:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003aa:	0405                	addi	s0,s0,1
  8003ac:	fff44783          	lbu	a5,-1(s0)
  8003b0:	3dfd                	addiw	s11,s11,-1
  8003b2:	0007851b          	sext.w	a0,a5
  8003b6:	fd61                	bnez	a0,80038e <vprintfmt+0x1a0>
            for (; width > 0; width --) {
  8003b8:	e7b058e3          	blez	s11,800228 <vprintfmt+0x3a>
  8003bc:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003be:	85a6                	mv	a1,s1
  8003c0:	02000513          	li	a0,32
  8003c4:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003c6:	e60d81e3          	beqz	s11,800228 <vprintfmt+0x3a>
  8003ca:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003cc:	85a6                	mv	a1,s1
  8003ce:	02000513          	li	a0,32
  8003d2:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003d4:	fe0d94e3          	bnez	s11,8003bc <vprintfmt+0x1ce>
  8003d8:	bd81                	j	800228 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8003da:	4705                	li	a4,1
  8003dc:	008a8593          	addi	a1,s5,8
  8003e0:	01074463          	blt	a4,a6,8003e8 <vprintfmt+0x1fa>
    else if (lflag) {
  8003e4:	12080063          	beqz	a6,800504 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
  8003e8:	000ab603          	ld	a2,0(s5)
  8003ec:	46a9                	li	a3,10
  8003ee:	8aae                	mv	s5,a1
  8003f0:	b7bd                	j	80035e <vprintfmt+0x170>
  8003f2:	00144603          	lbu	a2,1(s0)
            padc = '-';
  8003f6:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
  8003fa:	846a                	mv	s0,s10
  8003fc:	b5ad                	j	800266 <vprintfmt+0x78>
            putch(ch, putdat);
  8003fe:	85a6                	mv	a1,s1
  800400:	02500513          	li	a0,37
  800404:	9902                	jalr	s2
            break;
  800406:	b50d                	j	800228 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
  800408:	000aac83          	lw	s9,0(s5)
            goto process_precision;
  80040c:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  800410:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
  800412:	846a                	mv	s0,s10
            if (width < 0)
  800414:	e40dd9e3          	bgez	s11,800266 <vprintfmt+0x78>
                width = precision, precision = -1;
  800418:	8de6                	mv	s11,s9
  80041a:	5cfd                	li	s9,-1
  80041c:	b5a9                	j	800266 <vprintfmt+0x78>
            goto reswitch;
  80041e:	00144603          	lbu	a2,1(s0)
            padc = '0';
  800422:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
  800426:	846a                	mv	s0,s10
            goto reswitch;
  800428:	bd3d                	j	800266 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
  80042a:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
  80042e:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  800432:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  800434:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  800438:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  80043c:	fcd56ce3          	bltu	a0,a3,800414 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
  800440:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  800442:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
  800446:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
  80044a:	0196873b          	addw	a4,a3,s9
  80044e:	0017171b          	slliw	a4,a4,0x1
  800452:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
  800456:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
  80045a:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  80045e:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  800462:	fcd57fe3          	bleu	a3,a0,800440 <vprintfmt+0x252>
  800466:	b77d                	j	800414 <vprintfmt+0x226>
            if (width < 0)
  800468:	fffdc693          	not	a3,s11
  80046c:	96fd                	srai	a3,a3,0x3f
  80046e:	00ddfdb3          	and	s11,s11,a3
  800472:	00144603          	lbu	a2,1(s0)
  800476:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
  800478:	846a                	mv	s0,s10
  80047a:	b3f5                	j	800266 <vprintfmt+0x78>
            putch('%', putdat);
  80047c:	85a6                	mv	a1,s1
  80047e:	02500513          	li	a0,37
  800482:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  800484:	fff44703          	lbu	a4,-1(s0)
  800488:	02500793          	li	a5,37
  80048c:	8d22                	mv	s10,s0
  80048e:	d8f70de3          	beq	a4,a5,800228 <vprintfmt+0x3a>
  800492:	02500713          	li	a4,37
  800496:	1d7d                	addi	s10,s10,-1
  800498:	fffd4783          	lbu	a5,-1(s10)
  80049c:	fee79de3          	bne	a5,a4,800496 <vprintfmt+0x2a8>
  8004a0:	b361                	j	800228 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  8004a2:	00000617          	auipc	a2,0x0
  8004a6:	4c660613          	addi	a2,a2,1222 # 800968 <error_string+0x1a8>
  8004aa:	85a6                	mv	a1,s1
  8004ac:	854a                	mv	a0,s2
  8004ae:	0ac000ef          	jal	ra,80055a <printfmt>
  8004b2:	bb9d                	j	800228 <vprintfmt+0x3a>
                p = "(null)";
  8004b4:	00000617          	auipc	a2,0x0
  8004b8:	4ac60613          	addi	a2,a2,1196 # 800960 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
  8004bc:	00000417          	auipc	s0,0x0
  8004c0:	4a540413          	addi	s0,s0,1189 # 800961 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004c4:	8532                	mv	a0,a2
  8004c6:	85e6                	mv	a1,s9
  8004c8:	e032                	sd	a2,0(sp)
  8004ca:	e43e                	sd	a5,8(sp)
  8004cc:	c91ff0ef          	jal	ra,80015c <strnlen>
  8004d0:	40ad8dbb          	subw	s11,s11,a0
  8004d4:	6602                	ld	a2,0(sp)
  8004d6:	01b05d63          	blez	s11,8004f0 <vprintfmt+0x302>
  8004da:	67a2                	ld	a5,8(sp)
  8004dc:	2781                	sext.w	a5,a5
  8004de:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
  8004e0:	6522                	ld	a0,8(sp)
  8004e2:	85a6                	mv	a1,s1
  8004e4:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004e6:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  8004e8:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004ea:	6602                	ld	a2,0(sp)
  8004ec:	fe0d9ae3          	bnez	s11,8004e0 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004f0:	00064783          	lbu	a5,0(a2)
  8004f4:	0007851b          	sext.w	a0,a5
  8004f8:	e8051be3          	bnez	a0,80038e <vprintfmt+0x1a0>
  8004fc:	b335                	j	800228 <vprintfmt+0x3a>
        return va_arg(*ap, int);
  8004fe:	000aa403          	lw	s0,0(s5)
  800502:	bbf1                	j	8002de <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
  800504:	000ae603          	lwu	a2,0(s5)
  800508:	46a9                	li	a3,10
  80050a:	8aae                	mv	s5,a1
  80050c:	bd89                	j	80035e <vprintfmt+0x170>
  80050e:	000ae603          	lwu	a2,0(s5)
  800512:	46c1                	li	a3,16
  800514:	8aae                	mv	s5,a1
  800516:	b5a1                	j	80035e <vprintfmt+0x170>
  800518:	000ae603          	lwu	a2,0(s5)
  80051c:	46a1                	li	a3,8
  80051e:	8aae                	mv	s5,a1
  800520:	bd3d                	j	80035e <vprintfmt+0x170>
                    putch(ch, putdat);
  800522:	9902                	jalr	s2
  800524:	b559                	j	8003aa <vprintfmt+0x1bc>
                putch('-', putdat);
  800526:	85a6                	mv	a1,s1
  800528:	02d00513          	li	a0,45
  80052c:	e03e                	sd	a5,0(sp)
  80052e:	9902                	jalr	s2
                num = -(long long)num;
  800530:	8ace                	mv	s5,s3
  800532:	40800633          	neg	a2,s0
  800536:	46a9                	li	a3,10
  800538:	6782                	ld	a5,0(sp)
  80053a:	b515                	j	80035e <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
  80053c:	01b05663          	blez	s11,800548 <vprintfmt+0x35a>
  800540:	02d00693          	li	a3,45
  800544:	f6d798e3          	bne	a5,a3,8004b4 <vprintfmt+0x2c6>
  800548:	00000417          	auipc	s0,0x0
  80054c:	41940413          	addi	s0,s0,1049 # 800961 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800550:	02800513          	li	a0,40
  800554:	02800793          	li	a5,40
  800558:	bd1d                	j	80038e <vprintfmt+0x1a0>

000000000080055a <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80055a:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  80055c:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800560:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800562:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800564:	ec06                	sd	ra,24(sp)
  800566:	f83a                	sd	a4,48(sp)
  800568:	fc3e                	sd	a5,56(sp)
  80056a:	e0c2                	sd	a6,64(sp)
  80056c:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  80056e:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800570:	c7fff0ef          	jal	ra,8001ee <vprintfmt>
}
  800574:	60e2                	ld	ra,24(sp)
  800576:	6161                	addi	sp,sp,80
  800578:	8082                	ret

000000000080057a <main>:
#include <stdio.h>

const int max_child = 32;

int
main(void) {
  80057a:	1101                	addi	sp,sp,-32
  80057c:	e822                	sd	s0,16(sp)
  80057e:	e426                	sd	s1,8(sp)
  800580:	ec06                	sd	ra,24(sp)
    int n, pid;
    for (n = 0; n < max_child; n ++) {
  800582:	4401                	li	s0,0
  800584:	02000493          	li	s1,32
        if ((pid = fork()) == 0) {
  800588:	b49ff0ef          	jal	ra,8000d0 <fork>
  80058c:	cd05                	beqz	a0,8005c4 <main+0x4a>
            cprintf("I am child %d\n", n);
            exit(0);
        }
        assert(pid > 0);
  80058e:	06a05063          	blez	a0,8005ee <main+0x74>
    for (n = 0; n < max_child; n ++) {
  800592:	2405                	addiw	s0,s0,1
  800594:	fe941ae3          	bne	s0,s1,800588 <main+0xe>
  800598:	02000413          	li	s0,32
    if (n > max_child) {
        panic("fork claimed to work %d times!\n", n);
    }

    for (; n > 0; n --) {
        if (wait() != 0) {
  80059c:	b39ff0ef          	jal	ra,8000d4 <wait>
  8005a0:	ed05                	bnez	a0,8005d8 <main+0x5e>
  8005a2:	347d                	addiw	s0,s0,-1
    for (; n > 0; n --) {
  8005a4:	fc65                	bnez	s0,80059c <main+0x22>
            panic("wait stopped early\n");
        }
    }

    if (wait() == 0) {
  8005a6:	b2fff0ef          	jal	ra,8000d4 <wait>
  8005aa:	c12d                	beqz	a0,80060c <main+0x92>
        panic("wait got too many\n");
    }

    cprintf("forktest pass.\n");
  8005ac:	00000517          	auipc	a0,0x0
  8005b0:	44450513          	addi	a0,a0,1092 # 8009f0 <error_string+0x230>
  8005b4:	b69ff0ef          	jal	ra,80011c <cprintf>
    return 0;
}
  8005b8:	60e2                	ld	ra,24(sp)
  8005ba:	6442                	ld	s0,16(sp)
  8005bc:	64a2                	ld	s1,8(sp)
  8005be:	4501                	li	a0,0
  8005c0:	6105                	addi	sp,sp,32
  8005c2:	8082                	ret
            cprintf("I am child %d\n", n);
  8005c4:	85a2                	mv	a1,s0
  8005c6:	00000517          	auipc	a0,0x0
  8005ca:	3ba50513          	addi	a0,a0,954 # 800980 <error_string+0x1c0>
  8005ce:	b4fff0ef          	jal	ra,80011c <cprintf>
            exit(0);
  8005d2:	4501                	li	a0,0
  8005d4:	ae7ff0ef          	jal	ra,8000ba <exit>
            panic("wait stopped early\n");
  8005d8:	00000617          	auipc	a2,0x0
  8005dc:	3e860613          	addi	a2,a2,1000 # 8009c0 <error_string+0x200>
  8005e0:	45dd                	li	a1,23
  8005e2:	00000517          	auipc	a0,0x0
  8005e6:	3ce50513          	addi	a0,a0,974 # 8009b0 <error_string+0x1f0>
  8005ea:	a37ff0ef          	jal	ra,800020 <__panic>
        assert(pid > 0);
  8005ee:	00000697          	auipc	a3,0x0
  8005f2:	3a268693          	addi	a3,a3,930 # 800990 <error_string+0x1d0>
  8005f6:	00000617          	auipc	a2,0x0
  8005fa:	3a260613          	addi	a2,a2,930 # 800998 <error_string+0x1d8>
  8005fe:	45b9                	li	a1,14
  800600:	00000517          	auipc	a0,0x0
  800604:	3b050513          	addi	a0,a0,944 # 8009b0 <error_string+0x1f0>
  800608:	a19ff0ef          	jal	ra,800020 <__panic>
        panic("wait got too many\n");
  80060c:	00000617          	auipc	a2,0x0
  800610:	3cc60613          	addi	a2,a2,972 # 8009d8 <error_string+0x218>
  800614:	45f1                	li	a1,28
  800616:	00000517          	auipc	a0,0x0
  80061a:	39a50513          	addi	a0,a0,922 # 8009b0 <error_string+0x1f0>
  80061e:	a03ff0ef          	jal	ra,800020 <__panic>
