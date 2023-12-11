
obj/__user_exit.out:     file format elf64-littleriscv


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
  800032:	67250513          	addi	a0,a0,1650 # 8006a0 <main+0x118>
__panic(const char *file, int line, const char *fmt, ...) {
  800036:	ec06                	sd	ra,24(sp)
  800038:	f436                	sd	a3,40(sp)
  80003a:	f83a                	sd	a4,48(sp)
  80003c:	e0c2                	sd	a6,64(sp)
  80003e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800040:	e43e                	sd	a5,8(sp)
    cprintf("user panic at %s:%d:\n    ", file, line);
  800042:	0e8000ef          	jal	ra,80012a <cprintf>
    vcprintf(fmt, ap);
  800046:	65a2                	ld	a1,8(sp)
  800048:	8522                	mv	a0,s0
  80004a:	0c0000ef          	jal	ra,80010a <vcprintf>
    cprintf("\n");
  80004e:	00001517          	auipc	a0,0x1
  800052:	a0250513          	addi	a0,a0,-1534 # 800a50 <error_string+0x220>
  800056:	0d4000ef          	jal	ra,80012a <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  80005a:	5559                	li	a0,-10
  80005c:	064000ef          	jal	ra,8000c0 <exit>

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

00000000008000b2 <sys_yield>:
}

int
sys_yield(void) {
    return syscall(SYS_yield);
  8000b2:	4529                	li	a0,10
  8000b4:	fadff06f          	j	800060 <syscall>

00000000008000b8 <sys_putc>:
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
    return syscall(SYS_putc, c);
  8000b8:	85aa                	mv	a1,a0
  8000ba:	4579                	li	a0,30
  8000bc:	fa5ff06f          	j	800060 <syscall>

00000000008000c0 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8000c0:	1141                	addi	sp,sp,-16
  8000c2:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  8000c4:	fd7ff0ef          	jal	ra,80009a <sys_exit>
    cprintf("BUG: exit failed.\n");
  8000c8:	00000517          	auipc	a0,0x0
  8000cc:	5f850513          	addi	a0,a0,1528 # 8006c0 <main+0x138>
  8000d0:	05a000ef          	jal	ra,80012a <cprintf>
    while (1);
  8000d4:	a001                	j	8000d4 <exit+0x14>

00000000008000d6 <fork>:
}

int
fork(void) {
    return sys_fork();
  8000d6:	fcdff06f          	j	8000a2 <sys_fork>

00000000008000da <wait>:
}

int
wait(void) {
    return sys_wait(0, NULL);
  8000da:	4581                	li	a1,0
  8000dc:	4501                	li	a0,0
  8000de:	fcbff06f          	j	8000a8 <sys_wait>

00000000008000e2 <waitpid>:
}

int
waitpid(int pid, int *store) {
    return sys_wait(pid, store);
  8000e2:	fc7ff06f          	j	8000a8 <sys_wait>

00000000008000e6 <yield>:
}

void
yield(void) {
    sys_yield();
  8000e6:	fcdff06f          	j	8000b2 <sys_yield>

00000000008000ea <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  8000ea:	074000ef          	jal	ra,80015e <umain>
1:  j 1b
  8000ee:	a001                	j	8000ee <_start+0x4>

00000000008000f0 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  8000f0:	1141                	addi	sp,sp,-16
  8000f2:	e022                	sd	s0,0(sp)
  8000f4:	e406                	sd	ra,8(sp)
  8000f6:	842e                	mv	s0,a1
    sys_putc(c);
  8000f8:	fc1ff0ef          	jal	ra,8000b8 <sys_putc>
    (*cnt) ++;
  8000fc:	401c                	lw	a5,0(s0)
}
  8000fe:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
  800100:	2785                	addiw	a5,a5,1
  800102:	c01c                	sw	a5,0(s0)
}
  800104:	6402                	ld	s0,0(sp)
  800106:	0141                	addi	sp,sp,16
  800108:	8082                	ret

000000000080010a <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  80010a:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  80010c:	86ae                	mv	a3,a1
  80010e:	862a                	mv	a2,a0
  800110:	006c                	addi	a1,sp,12
  800112:	00000517          	auipc	a0,0x0
  800116:	fde50513          	addi	a0,a0,-34 # 8000f0 <cputch>
vcprintf(const char *fmt, va_list ap) {
  80011a:	ec06                	sd	ra,24(sp)
    int cnt = 0;
  80011c:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  80011e:	0de000ef          	jal	ra,8001fc <vprintfmt>
    return cnt;
}
  800122:	60e2                	ld	ra,24(sp)
  800124:	4532                	lw	a0,12(sp)
  800126:	6105                	addi	sp,sp,32
  800128:	8082                	ret

000000000080012a <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  80012a:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  80012c:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  800130:	f42e                	sd	a1,40(sp)
  800132:	f832                	sd	a2,48(sp)
  800134:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800136:	862a                	mv	a2,a0
  800138:	004c                	addi	a1,sp,4
  80013a:	00000517          	auipc	a0,0x0
  80013e:	fb650513          	addi	a0,a0,-74 # 8000f0 <cputch>
  800142:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
  800144:	ec06                	sd	ra,24(sp)
  800146:	e0ba                	sd	a4,64(sp)
  800148:	e4be                	sd	a5,72(sp)
  80014a:	e8c2                	sd	a6,80(sp)
  80014c:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
  80014e:	e41a                	sd	t1,8(sp)
    int cnt = 0;
  800150:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800152:	0aa000ef          	jal	ra,8001fc <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  800156:	60e2                	ld	ra,24(sp)
  800158:	4512                	lw	a0,4(sp)
  80015a:	6125                	addi	sp,sp,96
  80015c:	8082                	ret

000000000080015e <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  80015e:	1141                	addi	sp,sp,-16
  800160:	e406                	sd	ra,8(sp)
    int ret = main();
  800162:	426000ef          	jal	ra,800588 <main>
    exit(ret);
  800166:	f5bff0ef          	jal	ra,8000c0 <exit>

000000000080016a <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  80016a:	c185                	beqz	a1,80018a <strnlen+0x20>
  80016c:	00054783          	lbu	a5,0(a0)
  800170:	cf89                	beqz	a5,80018a <strnlen+0x20>
    size_t cnt = 0;
  800172:	4781                	li	a5,0
  800174:	a021                	j	80017c <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
  800176:	00074703          	lbu	a4,0(a4)
  80017a:	c711                	beqz	a4,800186 <strnlen+0x1c>
        cnt ++;
  80017c:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  80017e:	00f50733          	add	a4,a0,a5
  800182:	fef59ae3          	bne	a1,a5,800176 <strnlen+0xc>
    }
    return cnt;
}
  800186:	853e                	mv	a0,a5
  800188:	8082                	ret
    size_t cnt = 0;
  80018a:	4781                	li	a5,0
}
  80018c:	853e                	mv	a0,a5
  80018e:	8082                	ret

0000000000800190 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800190:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800194:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  800196:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80019a:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  80019c:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  8001a0:	f022                	sd	s0,32(sp)
  8001a2:	ec26                	sd	s1,24(sp)
  8001a4:	e84a                	sd	s2,16(sp)
  8001a6:	f406                	sd	ra,40(sp)
  8001a8:	e44e                	sd	s3,8(sp)
  8001aa:	84aa                	mv	s1,a0
  8001ac:	892e                	mv	s2,a1
  8001ae:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  8001b2:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  8001b4:	03067e63          	bleu	a6,a2,8001f0 <printnum+0x60>
  8001b8:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  8001ba:	00805763          	blez	s0,8001c8 <printnum+0x38>
  8001be:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  8001c0:	85ca                	mv	a1,s2
  8001c2:	854e                	mv	a0,s3
  8001c4:	9482                	jalr	s1
        while (-- width > 0)
  8001c6:	fc65                	bnez	s0,8001be <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  8001c8:	1a02                	slli	s4,s4,0x20
  8001ca:	020a5a13          	srli	s4,s4,0x20
  8001ce:	00000797          	auipc	a5,0x0
  8001d2:	72a78793          	addi	a5,a5,1834 # 8008f8 <error_string+0xc8>
  8001d6:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001d8:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001da:	000a4503          	lbu	a0,0(s4)
}
  8001de:	70a2                	ld	ra,40(sp)
  8001e0:	69a2                	ld	s3,8(sp)
  8001e2:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001e4:	85ca                	mv	a1,s2
  8001e6:	8326                	mv	t1,s1
}
  8001e8:	6942                	ld	s2,16(sp)
  8001ea:	64e2                	ld	s1,24(sp)
  8001ec:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001ee:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
  8001f0:	03065633          	divu	a2,a2,a6
  8001f4:	8722                	mv	a4,s0
  8001f6:	f9bff0ef          	jal	ra,800190 <printnum>
  8001fa:	b7f9                	j	8001c8 <printnum+0x38>

00000000008001fc <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001fc:	7119                	addi	sp,sp,-128
  8001fe:	f4a6                	sd	s1,104(sp)
  800200:	f0ca                	sd	s2,96(sp)
  800202:	e8d2                	sd	s4,80(sp)
  800204:	e4d6                	sd	s5,72(sp)
  800206:	e0da                	sd	s6,64(sp)
  800208:	fc5e                	sd	s7,56(sp)
  80020a:	f862                	sd	s8,48(sp)
  80020c:	f06a                	sd	s10,32(sp)
  80020e:	fc86                	sd	ra,120(sp)
  800210:	f8a2                	sd	s0,112(sp)
  800212:	ecce                	sd	s3,88(sp)
  800214:	f466                	sd	s9,40(sp)
  800216:	ec6e                	sd	s11,24(sp)
  800218:	892a                	mv	s2,a0
  80021a:	84ae                	mv	s1,a1
  80021c:	8d32                	mv	s10,a2
  80021e:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  800220:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  800222:	00000a17          	auipc	s4,0x0
  800226:	4b2a0a13          	addi	s4,s4,1202 # 8006d4 <main+0x14c>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
  80022a:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80022e:	00000c17          	auipc	s8,0x0
  800232:	602c0c13          	addi	s8,s8,1538 # 800830 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800236:	000d4503          	lbu	a0,0(s10)
  80023a:	02500793          	li	a5,37
  80023e:	001d0413          	addi	s0,s10,1
  800242:	00f50e63          	beq	a0,a5,80025e <vprintfmt+0x62>
            if (ch == '\0') {
  800246:	c521                	beqz	a0,80028e <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800248:	02500993          	li	s3,37
  80024c:	a011                	j	800250 <vprintfmt+0x54>
            if (ch == '\0') {
  80024e:	c121                	beqz	a0,80028e <vprintfmt+0x92>
            putch(ch, putdat);
  800250:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800252:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  800254:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800256:	fff44503          	lbu	a0,-1(s0)
  80025a:	ff351ae3          	bne	a0,s3,80024e <vprintfmt+0x52>
  80025e:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  800262:	02000793          	li	a5,32
        lflag = altflag = 0;
  800266:	4981                	li	s3,0
  800268:	4801                	li	a6,0
        width = precision = -1;
  80026a:	5cfd                	li	s9,-1
  80026c:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
  80026e:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
  800272:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
  800274:	fdd6069b          	addiw	a3,a2,-35
  800278:	0ff6f693          	andi	a3,a3,255
  80027c:	00140d13          	addi	s10,s0,1
  800280:	20d5e563          	bltu	a1,a3,80048a <vprintfmt+0x28e>
  800284:	068a                	slli	a3,a3,0x2
  800286:	96d2                	add	a3,a3,s4
  800288:	4294                	lw	a3,0(a3)
  80028a:	96d2                	add	a3,a3,s4
  80028c:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  80028e:	70e6                	ld	ra,120(sp)
  800290:	7446                	ld	s0,112(sp)
  800292:	74a6                	ld	s1,104(sp)
  800294:	7906                	ld	s2,96(sp)
  800296:	69e6                	ld	s3,88(sp)
  800298:	6a46                	ld	s4,80(sp)
  80029a:	6aa6                	ld	s5,72(sp)
  80029c:	6b06                	ld	s6,64(sp)
  80029e:	7be2                	ld	s7,56(sp)
  8002a0:	7c42                	ld	s8,48(sp)
  8002a2:	7ca2                	ld	s9,40(sp)
  8002a4:	7d02                	ld	s10,32(sp)
  8002a6:	6de2                	ld	s11,24(sp)
  8002a8:	6109                	addi	sp,sp,128
  8002aa:	8082                	ret
    if (lflag >= 2) {
  8002ac:	4705                	li	a4,1
  8002ae:	008a8593          	addi	a1,s5,8
  8002b2:	01074463          	blt	a4,a6,8002ba <vprintfmt+0xbe>
    else if (lflag) {
  8002b6:	26080363          	beqz	a6,80051c <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
  8002ba:	000ab603          	ld	a2,0(s5)
  8002be:	46c1                	li	a3,16
  8002c0:	8aae                	mv	s5,a1
  8002c2:	a06d                	j	80036c <vprintfmt+0x170>
            goto reswitch;
  8002c4:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  8002c8:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
  8002ca:	846a                	mv	s0,s10
            goto reswitch;
  8002cc:	b765                	j	800274 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
  8002ce:	000aa503          	lw	a0,0(s5)
  8002d2:	85a6                	mv	a1,s1
  8002d4:	0aa1                	addi	s5,s5,8
  8002d6:	9902                	jalr	s2
            break;
  8002d8:	bfb9                	j	800236 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8002da:	4705                	li	a4,1
  8002dc:	008a8993          	addi	s3,s5,8
  8002e0:	01074463          	blt	a4,a6,8002e8 <vprintfmt+0xec>
    else if (lflag) {
  8002e4:	22080463          	beqz	a6,80050c <vprintfmt+0x310>
        return va_arg(*ap, long);
  8002e8:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
  8002ec:	24044463          	bltz	s0,800534 <vprintfmt+0x338>
            num = getint(&ap, lflag);
  8002f0:	8622                	mv	a2,s0
  8002f2:	8ace                	mv	s5,s3
  8002f4:	46a9                	li	a3,10
  8002f6:	a89d                	j	80036c <vprintfmt+0x170>
            err = va_arg(ap, int);
  8002f8:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8002fc:	4761                	li	a4,24
            err = va_arg(ap, int);
  8002fe:	0aa1                	addi	s5,s5,8
            if (err < 0) {
  800300:	41f7d69b          	sraiw	a3,a5,0x1f
  800304:	8fb5                	xor	a5,a5,a3
  800306:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80030a:	1ad74363          	blt	a4,a3,8004b0 <vprintfmt+0x2b4>
  80030e:	00369793          	slli	a5,a3,0x3
  800312:	97e2                	add	a5,a5,s8
  800314:	639c                	ld	a5,0(a5)
  800316:	18078d63          	beqz	a5,8004b0 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
  80031a:	86be                	mv	a3,a5
  80031c:	00000617          	auipc	a2,0x0
  800320:	6cc60613          	addi	a2,a2,1740 # 8009e8 <error_string+0x1b8>
  800324:	85a6                	mv	a1,s1
  800326:	854a                	mv	a0,s2
  800328:	240000ef          	jal	ra,800568 <printfmt>
  80032c:	b729                	j	800236 <vprintfmt+0x3a>
            lflag ++;
  80032e:	00144603          	lbu	a2,1(s0)
  800332:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
  800334:	846a                	mv	s0,s10
            goto reswitch;
  800336:	bf3d                	j	800274 <vprintfmt+0x78>
    if (lflag >= 2) {
  800338:	4705                	li	a4,1
  80033a:	008a8593          	addi	a1,s5,8
  80033e:	01074463          	blt	a4,a6,800346 <vprintfmt+0x14a>
    else if (lflag) {
  800342:	1e080263          	beqz	a6,800526 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
  800346:	000ab603          	ld	a2,0(s5)
  80034a:	46a1                	li	a3,8
  80034c:	8aae                	mv	s5,a1
  80034e:	a839                	j	80036c <vprintfmt+0x170>
            putch('0', putdat);
  800350:	03000513          	li	a0,48
  800354:	85a6                	mv	a1,s1
  800356:	e03e                	sd	a5,0(sp)
  800358:	9902                	jalr	s2
            putch('x', putdat);
  80035a:	85a6                	mv	a1,s1
  80035c:	07800513          	li	a0,120
  800360:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800362:	0aa1                	addi	s5,s5,8
  800364:	ff8ab603          	ld	a2,-8(s5)
            goto number;
  800368:	6782                	ld	a5,0(sp)
  80036a:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
  80036c:	876e                	mv	a4,s11
  80036e:	85a6                	mv	a1,s1
  800370:	854a                	mv	a0,s2
  800372:	e1fff0ef          	jal	ra,800190 <printnum>
            break;
  800376:	b5c1                	j	800236 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
  800378:	000ab603          	ld	a2,0(s5)
  80037c:	0aa1                	addi	s5,s5,8
  80037e:	1c060663          	beqz	a2,80054a <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
  800382:	00160413          	addi	s0,a2,1
  800386:	17b05c63          	blez	s11,8004fe <vprintfmt+0x302>
  80038a:	02d00593          	li	a1,45
  80038e:	14b79263          	bne	a5,a1,8004d2 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800392:	00064783          	lbu	a5,0(a2)
  800396:	0007851b          	sext.w	a0,a5
  80039a:	c905                	beqz	a0,8003ca <vprintfmt+0x1ce>
  80039c:	000cc563          	bltz	s9,8003a6 <vprintfmt+0x1aa>
  8003a0:	3cfd                	addiw	s9,s9,-1
  8003a2:	036c8263          	beq	s9,s6,8003c6 <vprintfmt+0x1ca>
                    putch('?', putdat);
  8003a6:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  8003a8:	18098463          	beqz	s3,800530 <vprintfmt+0x334>
  8003ac:	3781                	addiw	a5,a5,-32
  8003ae:	18fbf163          	bleu	a5,s7,800530 <vprintfmt+0x334>
                    putch('?', putdat);
  8003b2:	03f00513          	li	a0,63
  8003b6:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003b8:	0405                	addi	s0,s0,1
  8003ba:	fff44783          	lbu	a5,-1(s0)
  8003be:	3dfd                	addiw	s11,s11,-1
  8003c0:	0007851b          	sext.w	a0,a5
  8003c4:	fd61                	bnez	a0,80039c <vprintfmt+0x1a0>
            for (; width > 0; width --) {
  8003c6:	e7b058e3          	blez	s11,800236 <vprintfmt+0x3a>
  8003ca:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003cc:	85a6                	mv	a1,s1
  8003ce:	02000513          	li	a0,32
  8003d2:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003d4:	e60d81e3          	beqz	s11,800236 <vprintfmt+0x3a>
  8003d8:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003da:	85a6                	mv	a1,s1
  8003dc:	02000513          	li	a0,32
  8003e0:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003e2:	fe0d94e3          	bnez	s11,8003ca <vprintfmt+0x1ce>
  8003e6:	bd81                	j	800236 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8003e8:	4705                	li	a4,1
  8003ea:	008a8593          	addi	a1,s5,8
  8003ee:	01074463          	blt	a4,a6,8003f6 <vprintfmt+0x1fa>
    else if (lflag) {
  8003f2:	12080063          	beqz	a6,800512 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
  8003f6:	000ab603          	ld	a2,0(s5)
  8003fa:	46a9                	li	a3,10
  8003fc:	8aae                	mv	s5,a1
  8003fe:	b7bd                	j	80036c <vprintfmt+0x170>
  800400:	00144603          	lbu	a2,1(s0)
            padc = '-';
  800404:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
  800408:	846a                	mv	s0,s10
  80040a:	b5ad                	j	800274 <vprintfmt+0x78>
            putch(ch, putdat);
  80040c:	85a6                	mv	a1,s1
  80040e:	02500513          	li	a0,37
  800412:	9902                	jalr	s2
            break;
  800414:	b50d                	j	800236 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
  800416:	000aac83          	lw	s9,0(s5)
            goto process_precision;
  80041a:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  80041e:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
  800420:	846a                	mv	s0,s10
            if (width < 0)
  800422:	e40dd9e3          	bgez	s11,800274 <vprintfmt+0x78>
                width = precision, precision = -1;
  800426:	8de6                	mv	s11,s9
  800428:	5cfd                	li	s9,-1
  80042a:	b5a9                	j	800274 <vprintfmt+0x78>
            goto reswitch;
  80042c:	00144603          	lbu	a2,1(s0)
            padc = '0';
  800430:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
  800434:	846a                	mv	s0,s10
            goto reswitch;
  800436:	bd3d                	j	800274 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
  800438:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
  80043c:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  800440:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  800442:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  800446:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  80044a:	fcd56ce3          	bltu	a0,a3,800422 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
  80044e:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  800450:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
  800454:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
  800458:	0196873b          	addw	a4,a3,s9
  80045c:	0017171b          	slliw	a4,a4,0x1
  800460:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
  800464:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
  800468:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  80046c:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  800470:	fcd57fe3          	bleu	a3,a0,80044e <vprintfmt+0x252>
  800474:	b77d                	j	800422 <vprintfmt+0x226>
            if (width < 0)
  800476:	fffdc693          	not	a3,s11
  80047a:	96fd                	srai	a3,a3,0x3f
  80047c:	00ddfdb3          	and	s11,s11,a3
  800480:	00144603          	lbu	a2,1(s0)
  800484:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
  800486:	846a                	mv	s0,s10
  800488:	b3f5                	j	800274 <vprintfmt+0x78>
            putch('%', putdat);
  80048a:	85a6                	mv	a1,s1
  80048c:	02500513          	li	a0,37
  800490:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  800492:	fff44703          	lbu	a4,-1(s0)
  800496:	02500793          	li	a5,37
  80049a:	8d22                	mv	s10,s0
  80049c:	d8f70de3          	beq	a4,a5,800236 <vprintfmt+0x3a>
  8004a0:	02500713          	li	a4,37
  8004a4:	1d7d                	addi	s10,s10,-1
  8004a6:	fffd4783          	lbu	a5,-1(s10)
  8004aa:	fee79de3          	bne	a5,a4,8004a4 <vprintfmt+0x2a8>
  8004ae:	b361                	j	800236 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  8004b0:	00000617          	auipc	a2,0x0
  8004b4:	52860613          	addi	a2,a2,1320 # 8009d8 <error_string+0x1a8>
  8004b8:	85a6                	mv	a1,s1
  8004ba:	854a                	mv	a0,s2
  8004bc:	0ac000ef          	jal	ra,800568 <printfmt>
  8004c0:	bb9d                	j	800236 <vprintfmt+0x3a>
                p = "(null)";
  8004c2:	00000617          	auipc	a2,0x0
  8004c6:	50e60613          	addi	a2,a2,1294 # 8009d0 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
  8004ca:	00000417          	auipc	s0,0x0
  8004ce:	50740413          	addi	s0,s0,1287 # 8009d1 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004d2:	8532                	mv	a0,a2
  8004d4:	85e6                	mv	a1,s9
  8004d6:	e032                	sd	a2,0(sp)
  8004d8:	e43e                	sd	a5,8(sp)
  8004da:	c91ff0ef          	jal	ra,80016a <strnlen>
  8004de:	40ad8dbb          	subw	s11,s11,a0
  8004e2:	6602                	ld	a2,0(sp)
  8004e4:	01b05d63          	blez	s11,8004fe <vprintfmt+0x302>
  8004e8:	67a2                	ld	a5,8(sp)
  8004ea:	2781                	sext.w	a5,a5
  8004ec:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
  8004ee:	6522                	ld	a0,8(sp)
  8004f0:	85a6                	mv	a1,s1
  8004f2:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004f4:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  8004f6:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004f8:	6602                	ld	a2,0(sp)
  8004fa:	fe0d9ae3          	bnez	s11,8004ee <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004fe:	00064783          	lbu	a5,0(a2)
  800502:	0007851b          	sext.w	a0,a5
  800506:	e8051be3          	bnez	a0,80039c <vprintfmt+0x1a0>
  80050a:	b335                	j	800236 <vprintfmt+0x3a>
        return va_arg(*ap, int);
  80050c:	000aa403          	lw	s0,0(s5)
  800510:	bbf1                	j	8002ec <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
  800512:	000ae603          	lwu	a2,0(s5)
  800516:	46a9                	li	a3,10
  800518:	8aae                	mv	s5,a1
  80051a:	bd89                	j	80036c <vprintfmt+0x170>
  80051c:	000ae603          	lwu	a2,0(s5)
  800520:	46c1                	li	a3,16
  800522:	8aae                	mv	s5,a1
  800524:	b5a1                	j	80036c <vprintfmt+0x170>
  800526:	000ae603          	lwu	a2,0(s5)
  80052a:	46a1                	li	a3,8
  80052c:	8aae                	mv	s5,a1
  80052e:	bd3d                	j	80036c <vprintfmt+0x170>
                    putch(ch, putdat);
  800530:	9902                	jalr	s2
  800532:	b559                	j	8003b8 <vprintfmt+0x1bc>
                putch('-', putdat);
  800534:	85a6                	mv	a1,s1
  800536:	02d00513          	li	a0,45
  80053a:	e03e                	sd	a5,0(sp)
  80053c:	9902                	jalr	s2
                num = -(long long)num;
  80053e:	8ace                	mv	s5,s3
  800540:	40800633          	neg	a2,s0
  800544:	46a9                	li	a3,10
  800546:	6782                	ld	a5,0(sp)
  800548:	b515                	j	80036c <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
  80054a:	01b05663          	blez	s11,800556 <vprintfmt+0x35a>
  80054e:	02d00693          	li	a3,45
  800552:	f6d798e3          	bne	a5,a3,8004c2 <vprintfmt+0x2c6>
  800556:	00000417          	auipc	s0,0x0
  80055a:	47b40413          	addi	s0,s0,1147 # 8009d1 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80055e:	02800513          	li	a0,40
  800562:	02800793          	li	a5,40
  800566:	bd1d                	j	80039c <vprintfmt+0x1a0>

0000000000800568 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800568:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  80056a:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80056e:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800570:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800572:	ec06                	sd	ra,24(sp)
  800574:	f83a                	sd	a4,48(sp)
  800576:	fc3e                	sd	a5,56(sp)
  800578:	e0c2                	sd	a6,64(sp)
  80057a:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  80057c:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80057e:	c7fff0ef          	jal	ra,8001fc <vprintfmt>
}
  800582:	60e2                	ld	ra,24(sp)
  800584:	6161                	addi	sp,sp,80
  800586:	8082                	ret

0000000000800588 <main>:
#include <ulib.h>

int magic = -0x10384;

int
main(void) {
  800588:	1101                	addi	sp,sp,-32
    int pid, code;
    cprintf("I am the parent. Forking the child...\n");
  80058a:	00000517          	auipc	a0,0x0
  80058e:	46650513          	addi	a0,a0,1126 # 8009f0 <error_string+0x1c0>
main(void) {
  800592:	ec06                	sd	ra,24(sp)
  800594:	e822                	sd	s0,16(sp)
    cprintf("I am the parent. Forking the child...\n");
  800596:	b95ff0ef          	jal	ra,80012a <cprintf>
    if ((pid = fork()) == 0) {
  80059a:	b3dff0ef          	jal	ra,8000d6 <fork>
  80059e:	c569                	beqz	a0,800668 <main+0xe0>
  8005a0:	842a                	mv	s0,a0
        yield();
        yield();
        exit(magic);
    }
    else {
        cprintf("I am parent, fork a child pid %d\n",pid);
  8005a2:	85aa                	mv	a1,a0
  8005a4:	00000517          	auipc	a0,0x0
  8005a8:	48c50513          	addi	a0,a0,1164 # 800a30 <error_string+0x200>
  8005ac:	b7fff0ef          	jal	ra,80012a <cprintf>
    }
    assert(pid > 0);
  8005b0:	08805d63          	blez	s0,80064a <main+0xc2>
    cprintf("I am the parent, waiting now..\n");
  8005b4:	00000517          	auipc	a0,0x0
  8005b8:	4d450513          	addi	a0,a0,1236 # 800a88 <error_string+0x258>
  8005bc:	b6fff0ef          	jal	ra,80012a <cprintf>

    assert(waitpid(pid, &code) == 0 && code == magic);
  8005c0:	006c                	addi	a1,sp,12
  8005c2:	8522                	mv	a0,s0
  8005c4:	b1fff0ef          	jal	ra,8000e2 <waitpid>
  8005c8:	e139                	bnez	a0,80060e <main+0x86>
  8005ca:	00001797          	auipc	a5,0x1
  8005ce:	a3678793          	addi	a5,a5,-1482 # 801000 <magic>
  8005d2:	4732                	lw	a4,12(sp)
  8005d4:	439c                	lw	a5,0(a5)
  8005d6:	02f71c63          	bne	a4,a5,80060e <main+0x86>
    assert(waitpid(pid, &code) != 0 && wait() != 0);
  8005da:	006c                	addi	a1,sp,12
  8005dc:	8522                	mv	a0,s0
  8005de:	b05ff0ef          	jal	ra,8000e2 <waitpid>
  8005e2:	c529                	beqz	a0,80062c <main+0xa4>
  8005e4:	af7ff0ef          	jal	ra,8000da <wait>
  8005e8:	c131                	beqz	a0,80062c <main+0xa4>
    cprintf("waitpid %d ok.\n", pid);
  8005ea:	85a2                	mv	a1,s0
  8005ec:	00000517          	auipc	a0,0x0
  8005f0:	51450513          	addi	a0,a0,1300 # 800b00 <error_string+0x2d0>
  8005f4:	b37ff0ef          	jal	ra,80012a <cprintf>

    cprintf("exit pass.\n");
  8005f8:	00000517          	auipc	a0,0x0
  8005fc:	51850513          	addi	a0,a0,1304 # 800b10 <error_string+0x2e0>
  800600:	b2bff0ef          	jal	ra,80012a <cprintf>
    return 0;
}
  800604:	60e2                	ld	ra,24(sp)
  800606:	6442                	ld	s0,16(sp)
  800608:	4501                	li	a0,0
  80060a:	6105                	addi	sp,sp,32
  80060c:	8082                	ret
    assert(waitpid(pid, &code) == 0 && code == magic);
  80060e:	00000697          	auipc	a3,0x0
  800612:	49a68693          	addi	a3,a3,1178 # 800aa8 <error_string+0x278>
  800616:	00000617          	auipc	a2,0x0
  80061a:	44a60613          	addi	a2,a2,1098 # 800a60 <error_string+0x230>
  80061e:	45ed                	li	a1,27
  800620:	00000517          	auipc	a0,0x0
  800624:	45850513          	addi	a0,a0,1112 # 800a78 <error_string+0x248>
  800628:	9f9ff0ef          	jal	ra,800020 <__panic>
    assert(waitpid(pid, &code) != 0 && wait() != 0);
  80062c:	00000697          	auipc	a3,0x0
  800630:	4ac68693          	addi	a3,a3,1196 # 800ad8 <error_string+0x2a8>
  800634:	00000617          	auipc	a2,0x0
  800638:	42c60613          	addi	a2,a2,1068 # 800a60 <error_string+0x230>
  80063c:	45f1                	li	a1,28
  80063e:	00000517          	auipc	a0,0x0
  800642:	43a50513          	addi	a0,a0,1082 # 800a78 <error_string+0x248>
  800646:	9dbff0ef          	jal	ra,800020 <__panic>
    assert(pid > 0);
  80064a:	00000697          	auipc	a3,0x0
  80064e:	40e68693          	addi	a3,a3,1038 # 800a58 <error_string+0x228>
  800652:	00000617          	auipc	a2,0x0
  800656:	40e60613          	addi	a2,a2,1038 # 800a60 <error_string+0x230>
  80065a:	45e1                	li	a1,24
  80065c:	00000517          	auipc	a0,0x0
  800660:	41c50513          	addi	a0,a0,1052 # 800a78 <error_string+0x248>
  800664:	9bdff0ef          	jal	ra,800020 <__panic>
        cprintf("I am the child.\n");
  800668:	00000517          	auipc	a0,0x0
  80066c:	3b050513          	addi	a0,a0,944 # 800a18 <error_string+0x1e8>
  800670:	abbff0ef          	jal	ra,80012a <cprintf>
        yield();
  800674:	a73ff0ef          	jal	ra,8000e6 <yield>
        yield();
  800678:	a6fff0ef          	jal	ra,8000e6 <yield>
        yield();
  80067c:	a6bff0ef          	jal	ra,8000e6 <yield>
        yield();
  800680:	a67ff0ef          	jal	ra,8000e6 <yield>
        yield();
  800684:	a63ff0ef          	jal	ra,8000e6 <yield>
        yield();
  800688:	a5fff0ef          	jal	ra,8000e6 <yield>
        yield();
  80068c:	a5bff0ef          	jal	ra,8000e6 <yield>
        exit(magic);
  800690:	00001797          	auipc	a5,0x1
  800694:	97078793          	addi	a5,a5,-1680 # 801000 <magic>
  800698:	4388                	lw	a0,0(a5)
  80069a:	a27ff0ef          	jal	ra,8000c0 <exit>
