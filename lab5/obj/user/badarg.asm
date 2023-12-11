
obj/__user_badarg.out:     file format elf64-littleriscv


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
  800032:	64250513          	addi	a0,a0,1602 # 800670 <main+0xf0>
__panic(const char *file, int line, const char *fmt, ...) {
  800036:	ec06                	sd	ra,24(sp)
  800038:	f436                	sd	a3,40(sp)
  80003a:	f83a                	sd	a4,48(sp)
  80003c:	e0c2                	sd	a6,64(sp)
  80003e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800040:	e43e                	sd	a5,8(sp)
    cprintf("user panic at %s:%d:\n    ", file, line);
  800042:	0e0000ef          	jal	ra,800122 <cprintf>
    vcprintf(fmt, ap);
  800046:	65a2                	ld	a1,8(sp)
  800048:	8522                	mv	a0,s0
  80004a:	0b8000ef          	jal	ra,800102 <vcprintf>
    cprintf("\n");
  80004e:	00001517          	auipc	a0,0x1
  800052:	97a50513          	addi	a0,a0,-1670 # 8009c8 <error_string+0x1c8>
  800056:	0cc000ef          	jal	ra,800122 <cprintf>
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
  8000cc:	5c850513          	addi	a0,a0,1480 # 800690 <main+0x110>
  8000d0:	052000ef          	jal	ra,800122 <cprintf>
    while (1);
  8000d4:	a001                	j	8000d4 <exit+0x14>

00000000008000d6 <fork>:
}

int
fork(void) {
    return sys_fork();
  8000d6:	fcdff06f          	j	8000a2 <sys_fork>

00000000008000da <waitpid>:
    return sys_wait(0, NULL);
}

int
waitpid(int pid, int *store) {
    return sys_wait(pid, store);
  8000da:	fcfff06f          	j	8000a8 <sys_wait>

00000000008000de <yield>:
}

void
yield(void) {
    sys_yield();
  8000de:	fd5ff06f          	j	8000b2 <sys_yield>

00000000008000e2 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  8000e2:	074000ef          	jal	ra,800156 <umain>
1:  j 1b
  8000e6:	a001                	j	8000e6 <_start+0x4>

00000000008000e8 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  8000e8:	1141                	addi	sp,sp,-16
  8000ea:	e022                	sd	s0,0(sp)
  8000ec:	e406                	sd	ra,8(sp)
  8000ee:	842e                	mv	s0,a1
    sys_putc(c);
  8000f0:	fc9ff0ef          	jal	ra,8000b8 <sys_putc>
    (*cnt) ++;
  8000f4:	401c                	lw	a5,0(s0)
}
  8000f6:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
  8000f8:	2785                	addiw	a5,a5,1
  8000fa:	c01c                	sw	a5,0(s0)
}
  8000fc:	6402                	ld	s0,0(sp)
  8000fe:	0141                	addi	sp,sp,16
  800100:	8082                	ret

0000000000800102 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  800102:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800104:	86ae                	mv	a3,a1
  800106:	862a                	mv	a2,a0
  800108:	006c                	addi	a1,sp,12
  80010a:	00000517          	auipc	a0,0x0
  80010e:	fde50513          	addi	a0,a0,-34 # 8000e8 <cputch>
vcprintf(const char *fmt, va_list ap) {
  800112:	ec06                	sd	ra,24(sp)
    int cnt = 0;
  800114:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800116:	0de000ef          	jal	ra,8001f4 <vprintfmt>
    return cnt;
}
  80011a:	60e2                	ld	ra,24(sp)
  80011c:	4532                	lw	a0,12(sp)
  80011e:	6105                	addi	sp,sp,32
  800120:	8082                	ret

0000000000800122 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  800122:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  800124:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  800128:	f42e                	sd	a1,40(sp)
  80012a:	f832                	sd	a2,48(sp)
  80012c:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  80012e:	862a                	mv	a2,a0
  800130:	004c                	addi	a1,sp,4
  800132:	00000517          	auipc	a0,0x0
  800136:	fb650513          	addi	a0,a0,-74 # 8000e8 <cputch>
  80013a:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
  80013c:	ec06                	sd	ra,24(sp)
  80013e:	e0ba                	sd	a4,64(sp)
  800140:	e4be                	sd	a5,72(sp)
  800142:	e8c2                	sd	a6,80(sp)
  800144:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
  800146:	e41a                	sd	t1,8(sp)
    int cnt = 0;
  800148:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  80014a:	0aa000ef          	jal	ra,8001f4 <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  80014e:	60e2                	ld	ra,24(sp)
  800150:	4512                	lw	a0,4(sp)
  800152:	6125                	addi	sp,sp,96
  800154:	8082                	ret

0000000000800156 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  800156:	1141                	addi	sp,sp,-16
  800158:	e406                	sd	ra,8(sp)
    int ret = main();
  80015a:	426000ef          	jal	ra,800580 <main>
    exit(ret);
  80015e:	f63ff0ef          	jal	ra,8000c0 <exit>

0000000000800162 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  800162:	c185                	beqz	a1,800182 <strnlen+0x20>
  800164:	00054783          	lbu	a5,0(a0)
  800168:	cf89                	beqz	a5,800182 <strnlen+0x20>
    size_t cnt = 0;
  80016a:	4781                	li	a5,0
  80016c:	a021                	j	800174 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
  80016e:	00074703          	lbu	a4,0(a4)
  800172:	c711                	beqz	a4,80017e <strnlen+0x1c>
        cnt ++;
  800174:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800176:	00f50733          	add	a4,a0,a5
  80017a:	fef59ae3          	bne	a1,a5,80016e <strnlen+0xc>
    }
    return cnt;
}
  80017e:	853e                	mv	a0,a5
  800180:	8082                	ret
    size_t cnt = 0;
  800182:	4781                	li	a5,0
}
  800184:	853e                	mv	a0,a5
  800186:	8082                	ret

0000000000800188 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800188:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80018c:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  80018e:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800192:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  800194:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  800198:	f022                	sd	s0,32(sp)
  80019a:	ec26                	sd	s1,24(sp)
  80019c:	e84a                	sd	s2,16(sp)
  80019e:	f406                	sd	ra,40(sp)
  8001a0:	e44e                	sd	s3,8(sp)
  8001a2:	84aa                	mv	s1,a0
  8001a4:	892e                	mv	s2,a1
  8001a6:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  8001aa:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  8001ac:	03067e63          	bleu	a6,a2,8001e8 <printnum+0x60>
  8001b0:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  8001b2:	00805763          	blez	s0,8001c0 <printnum+0x38>
  8001b6:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  8001b8:	85ca                	mv	a1,s2
  8001ba:	854e                	mv	a0,s3
  8001bc:	9482                	jalr	s1
        while (-- width > 0)
  8001be:	fc65                	bnez	s0,8001b6 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  8001c0:	1a02                	slli	s4,s4,0x20
  8001c2:	020a5a13          	srli	s4,s4,0x20
  8001c6:	00000797          	auipc	a5,0x0
  8001ca:	70278793          	addi	a5,a5,1794 # 8008c8 <error_string+0xc8>
  8001ce:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001d0:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001d2:	000a4503          	lbu	a0,0(s4)
}
  8001d6:	70a2                	ld	ra,40(sp)
  8001d8:	69a2                	ld	s3,8(sp)
  8001da:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001dc:	85ca                	mv	a1,s2
  8001de:	8326                	mv	t1,s1
}
  8001e0:	6942                	ld	s2,16(sp)
  8001e2:	64e2                	ld	s1,24(sp)
  8001e4:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001e6:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
  8001e8:	03065633          	divu	a2,a2,a6
  8001ec:	8722                	mv	a4,s0
  8001ee:	f9bff0ef          	jal	ra,800188 <printnum>
  8001f2:	b7f9                	j	8001c0 <printnum+0x38>

00000000008001f4 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001f4:	7119                	addi	sp,sp,-128
  8001f6:	f4a6                	sd	s1,104(sp)
  8001f8:	f0ca                	sd	s2,96(sp)
  8001fa:	e8d2                	sd	s4,80(sp)
  8001fc:	e4d6                	sd	s5,72(sp)
  8001fe:	e0da                	sd	s6,64(sp)
  800200:	fc5e                	sd	s7,56(sp)
  800202:	f862                	sd	s8,48(sp)
  800204:	f06a                	sd	s10,32(sp)
  800206:	fc86                	sd	ra,120(sp)
  800208:	f8a2                	sd	s0,112(sp)
  80020a:	ecce                	sd	s3,88(sp)
  80020c:	f466                	sd	s9,40(sp)
  80020e:	ec6e                	sd	s11,24(sp)
  800210:	892a                	mv	s2,a0
  800212:	84ae                	mv	s1,a1
  800214:	8d32                	mv	s10,a2
  800216:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  800218:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  80021a:	00000a17          	auipc	s4,0x0
  80021e:	48aa0a13          	addi	s4,s4,1162 # 8006a4 <main+0x124>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
  800222:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800226:	00000c17          	auipc	s8,0x0
  80022a:	5dac0c13          	addi	s8,s8,1498 # 800800 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80022e:	000d4503          	lbu	a0,0(s10)
  800232:	02500793          	li	a5,37
  800236:	001d0413          	addi	s0,s10,1
  80023a:	00f50e63          	beq	a0,a5,800256 <vprintfmt+0x62>
            if (ch == '\0') {
  80023e:	c521                	beqz	a0,800286 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800240:	02500993          	li	s3,37
  800244:	a011                	j	800248 <vprintfmt+0x54>
            if (ch == '\0') {
  800246:	c121                	beqz	a0,800286 <vprintfmt+0x92>
            putch(ch, putdat);
  800248:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80024a:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  80024c:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80024e:	fff44503          	lbu	a0,-1(s0)
  800252:	ff351ae3          	bne	a0,s3,800246 <vprintfmt+0x52>
  800256:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  80025a:	02000793          	li	a5,32
        lflag = altflag = 0;
  80025e:	4981                	li	s3,0
  800260:	4801                	li	a6,0
        width = precision = -1;
  800262:	5cfd                	li	s9,-1
  800264:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
  800266:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
  80026a:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
  80026c:	fdd6069b          	addiw	a3,a2,-35
  800270:	0ff6f693          	andi	a3,a3,255
  800274:	00140d13          	addi	s10,s0,1
  800278:	20d5e563          	bltu	a1,a3,800482 <vprintfmt+0x28e>
  80027c:	068a                	slli	a3,a3,0x2
  80027e:	96d2                	add	a3,a3,s4
  800280:	4294                	lw	a3,0(a3)
  800282:	96d2                	add	a3,a3,s4
  800284:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  800286:	70e6                	ld	ra,120(sp)
  800288:	7446                	ld	s0,112(sp)
  80028a:	74a6                	ld	s1,104(sp)
  80028c:	7906                	ld	s2,96(sp)
  80028e:	69e6                	ld	s3,88(sp)
  800290:	6a46                	ld	s4,80(sp)
  800292:	6aa6                	ld	s5,72(sp)
  800294:	6b06                	ld	s6,64(sp)
  800296:	7be2                	ld	s7,56(sp)
  800298:	7c42                	ld	s8,48(sp)
  80029a:	7ca2                	ld	s9,40(sp)
  80029c:	7d02                	ld	s10,32(sp)
  80029e:	6de2                	ld	s11,24(sp)
  8002a0:	6109                	addi	sp,sp,128
  8002a2:	8082                	ret
    if (lflag >= 2) {
  8002a4:	4705                	li	a4,1
  8002a6:	008a8593          	addi	a1,s5,8
  8002aa:	01074463          	blt	a4,a6,8002b2 <vprintfmt+0xbe>
    else if (lflag) {
  8002ae:	26080363          	beqz	a6,800514 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
  8002b2:	000ab603          	ld	a2,0(s5)
  8002b6:	46c1                	li	a3,16
  8002b8:	8aae                	mv	s5,a1
  8002ba:	a06d                	j	800364 <vprintfmt+0x170>
            goto reswitch;
  8002bc:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  8002c0:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
  8002c2:	846a                	mv	s0,s10
            goto reswitch;
  8002c4:	b765                	j	80026c <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
  8002c6:	000aa503          	lw	a0,0(s5)
  8002ca:	85a6                	mv	a1,s1
  8002cc:	0aa1                	addi	s5,s5,8
  8002ce:	9902                	jalr	s2
            break;
  8002d0:	bfb9                	j	80022e <vprintfmt+0x3a>
    if (lflag >= 2) {
  8002d2:	4705                	li	a4,1
  8002d4:	008a8993          	addi	s3,s5,8
  8002d8:	01074463          	blt	a4,a6,8002e0 <vprintfmt+0xec>
    else if (lflag) {
  8002dc:	22080463          	beqz	a6,800504 <vprintfmt+0x310>
        return va_arg(*ap, long);
  8002e0:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
  8002e4:	24044463          	bltz	s0,80052c <vprintfmt+0x338>
            num = getint(&ap, lflag);
  8002e8:	8622                	mv	a2,s0
  8002ea:	8ace                	mv	s5,s3
  8002ec:	46a9                	li	a3,10
  8002ee:	a89d                	j	800364 <vprintfmt+0x170>
            err = va_arg(ap, int);
  8002f0:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8002f4:	4761                	li	a4,24
            err = va_arg(ap, int);
  8002f6:	0aa1                	addi	s5,s5,8
            if (err < 0) {
  8002f8:	41f7d69b          	sraiw	a3,a5,0x1f
  8002fc:	8fb5                	xor	a5,a5,a3
  8002fe:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800302:	1ad74363          	blt	a4,a3,8004a8 <vprintfmt+0x2b4>
  800306:	00369793          	slli	a5,a3,0x3
  80030a:	97e2                	add	a5,a5,s8
  80030c:	639c                	ld	a5,0(a5)
  80030e:	18078d63          	beqz	a5,8004a8 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
  800312:	86be                	mv	a3,a5
  800314:	00000617          	auipc	a2,0x0
  800318:	6a460613          	addi	a2,a2,1700 # 8009b8 <error_string+0x1b8>
  80031c:	85a6                	mv	a1,s1
  80031e:	854a                	mv	a0,s2
  800320:	240000ef          	jal	ra,800560 <printfmt>
  800324:	b729                	j	80022e <vprintfmt+0x3a>
            lflag ++;
  800326:	00144603          	lbu	a2,1(s0)
  80032a:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
  80032c:	846a                	mv	s0,s10
            goto reswitch;
  80032e:	bf3d                	j	80026c <vprintfmt+0x78>
    if (lflag >= 2) {
  800330:	4705                	li	a4,1
  800332:	008a8593          	addi	a1,s5,8
  800336:	01074463          	blt	a4,a6,80033e <vprintfmt+0x14a>
    else if (lflag) {
  80033a:	1e080263          	beqz	a6,80051e <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
  80033e:	000ab603          	ld	a2,0(s5)
  800342:	46a1                	li	a3,8
  800344:	8aae                	mv	s5,a1
  800346:	a839                	j	800364 <vprintfmt+0x170>
            putch('0', putdat);
  800348:	03000513          	li	a0,48
  80034c:	85a6                	mv	a1,s1
  80034e:	e03e                	sd	a5,0(sp)
  800350:	9902                	jalr	s2
            putch('x', putdat);
  800352:	85a6                	mv	a1,s1
  800354:	07800513          	li	a0,120
  800358:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80035a:	0aa1                	addi	s5,s5,8
  80035c:	ff8ab603          	ld	a2,-8(s5)
            goto number;
  800360:	6782                	ld	a5,0(sp)
  800362:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
  800364:	876e                	mv	a4,s11
  800366:	85a6                	mv	a1,s1
  800368:	854a                	mv	a0,s2
  80036a:	e1fff0ef          	jal	ra,800188 <printnum>
            break;
  80036e:	b5c1                	j	80022e <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
  800370:	000ab603          	ld	a2,0(s5)
  800374:	0aa1                	addi	s5,s5,8
  800376:	1c060663          	beqz	a2,800542 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
  80037a:	00160413          	addi	s0,a2,1
  80037e:	17b05c63          	blez	s11,8004f6 <vprintfmt+0x302>
  800382:	02d00593          	li	a1,45
  800386:	14b79263          	bne	a5,a1,8004ca <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80038a:	00064783          	lbu	a5,0(a2)
  80038e:	0007851b          	sext.w	a0,a5
  800392:	c905                	beqz	a0,8003c2 <vprintfmt+0x1ce>
  800394:	000cc563          	bltz	s9,80039e <vprintfmt+0x1aa>
  800398:	3cfd                	addiw	s9,s9,-1
  80039a:	036c8263          	beq	s9,s6,8003be <vprintfmt+0x1ca>
                    putch('?', putdat);
  80039e:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  8003a0:	18098463          	beqz	s3,800528 <vprintfmt+0x334>
  8003a4:	3781                	addiw	a5,a5,-32
  8003a6:	18fbf163          	bleu	a5,s7,800528 <vprintfmt+0x334>
                    putch('?', putdat);
  8003aa:	03f00513          	li	a0,63
  8003ae:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003b0:	0405                	addi	s0,s0,1
  8003b2:	fff44783          	lbu	a5,-1(s0)
  8003b6:	3dfd                	addiw	s11,s11,-1
  8003b8:	0007851b          	sext.w	a0,a5
  8003bc:	fd61                	bnez	a0,800394 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
  8003be:	e7b058e3          	blez	s11,80022e <vprintfmt+0x3a>
  8003c2:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003c4:	85a6                	mv	a1,s1
  8003c6:	02000513          	li	a0,32
  8003ca:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003cc:	e60d81e3          	beqz	s11,80022e <vprintfmt+0x3a>
  8003d0:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003d2:	85a6                	mv	a1,s1
  8003d4:	02000513          	li	a0,32
  8003d8:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003da:	fe0d94e3          	bnez	s11,8003c2 <vprintfmt+0x1ce>
  8003de:	bd81                	j	80022e <vprintfmt+0x3a>
    if (lflag >= 2) {
  8003e0:	4705                	li	a4,1
  8003e2:	008a8593          	addi	a1,s5,8
  8003e6:	01074463          	blt	a4,a6,8003ee <vprintfmt+0x1fa>
    else if (lflag) {
  8003ea:	12080063          	beqz	a6,80050a <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
  8003ee:	000ab603          	ld	a2,0(s5)
  8003f2:	46a9                	li	a3,10
  8003f4:	8aae                	mv	s5,a1
  8003f6:	b7bd                	j	800364 <vprintfmt+0x170>
  8003f8:	00144603          	lbu	a2,1(s0)
            padc = '-';
  8003fc:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
  800400:	846a                	mv	s0,s10
  800402:	b5ad                	j	80026c <vprintfmt+0x78>
            putch(ch, putdat);
  800404:	85a6                	mv	a1,s1
  800406:	02500513          	li	a0,37
  80040a:	9902                	jalr	s2
            break;
  80040c:	b50d                	j	80022e <vprintfmt+0x3a>
            precision = va_arg(ap, int);
  80040e:	000aac83          	lw	s9,0(s5)
            goto process_precision;
  800412:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  800416:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
  800418:	846a                	mv	s0,s10
            if (width < 0)
  80041a:	e40dd9e3          	bgez	s11,80026c <vprintfmt+0x78>
                width = precision, precision = -1;
  80041e:	8de6                	mv	s11,s9
  800420:	5cfd                	li	s9,-1
  800422:	b5a9                	j	80026c <vprintfmt+0x78>
            goto reswitch;
  800424:	00144603          	lbu	a2,1(s0)
            padc = '0';
  800428:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
  80042c:	846a                	mv	s0,s10
            goto reswitch;
  80042e:	bd3d                	j	80026c <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
  800430:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
  800434:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  800438:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  80043a:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  80043e:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  800442:	fcd56ce3          	bltu	a0,a3,80041a <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
  800446:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  800448:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
  80044c:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
  800450:	0196873b          	addw	a4,a3,s9
  800454:	0017171b          	slliw	a4,a4,0x1
  800458:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
  80045c:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
  800460:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  800464:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  800468:	fcd57fe3          	bleu	a3,a0,800446 <vprintfmt+0x252>
  80046c:	b77d                	j	80041a <vprintfmt+0x226>
            if (width < 0)
  80046e:	fffdc693          	not	a3,s11
  800472:	96fd                	srai	a3,a3,0x3f
  800474:	00ddfdb3          	and	s11,s11,a3
  800478:	00144603          	lbu	a2,1(s0)
  80047c:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
  80047e:	846a                	mv	s0,s10
  800480:	b3f5                	j	80026c <vprintfmt+0x78>
            putch('%', putdat);
  800482:	85a6                	mv	a1,s1
  800484:	02500513          	li	a0,37
  800488:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  80048a:	fff44703          	lbu	a4,-1(s0)
  80048e:	02500793          	li	a5,37
  800492:	8d22                	mv	s10,s0
  800494:	d8f70de3          	beq	a4,a5,80022e <vprintfmt+0x3a>
  800498:	02500713          	li	a4,37
  80049c:	1d7d                	addi	s10,s10,-1
  80049e:	fffd4783          	lbu	a5,-1(s10)
  8004a2:	fee79de3          	bne	a5,a4,80049c <vprintfmt+0x2a8>
  8004a6:	b361                	j	80022e <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  8004a8:	00000617          	auipc	a2,0x0
  8004ac:	50060613          	addi	a2,a2,1280 # 8009a8 <error_string+0x1a8>
  8004b0:	85a6                	mv	a1,s1
  8004b2:	854a                	mv	a0,s2
  8004b4:	0ac000ef          	jal	ra,800560 <printfmt>
  8004b8:	bb9d                	j	80022e <vprintfmt+0x3a>
                p = "(null)";
  8004ba:	00000617          	auipc	a2,0x0
  8004be:	4e660613          	addi	a2,a2,1254 # 8009a0 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
  8004c2:	00000417          	auipc	s0,0x0
  8004c6:	4df40413          	addi	s0,s0,1247 # 8009a1 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004ca:	8532                	mv	a0,a2
  8004cc:	85e6                	mv	a1,s9
  8004ce:	e032                	sd	a2,0(sp)
  8004d0:	e43e                	sd	a5,8(sp)
  8004d2:	c91ff0ef          	jal	ra,800162 <strnlen>
  8004d6:	40ad8dbb          	subw	s11,s11,a0
  8004da:	6602                	ld	a2,0(sp)
  8004dc:	01b05d63          	blez	s11,8004f6 <vprintfmt+0x302>
  8004e0:	67a2                	ld	a5,8(sp)
  8004e2:	2781                	sext.w	a5,a5
  8004e4:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
  8004e6:	6522                	ld	a0,8(sp)
  8004e8:	85a6                	mv	a1,s1
  8004ea:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004ec:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  8004ee:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004f0:	6602                	ld	a2,0(sp)
  8004f2:	fe0d9ae3          	bnez	s11,8004e6 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004f6:	00064783          	lbu	a5,0(a2)
  8004fa:	0007851b          	sext.w	a0,a5
  8004fe:	e8051be3          	bnez	a0,800394 <vprintfmt+0x1a0>
  800502:	b335                	j	80022e <vprintfmt+0x3a>
        return va_arg(*ap, int);
  800504:	000aa403          	lw	s0,0(s5)
  800508:	bbf1                	j	8002e4 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
  80050a:	000ae603          	lwu	a2,0(s5)
  80050e:	46a9                	li	a3,10
  800510:	8aae                	mv	s5,a1
  800512:	bd89                	j	800364 <vprintfmt+0x170>
  800514:	000ae603          	lwu	a2,0(s5)
  800518:	46c1                	li	a3,16
  80051a:	8aae                	mv	s5,a1
  80051c:	b5a1                	j	800364 <vprintfmt+0x170>
  80051e:	000ae603          	lwu	a2,0(s5)
  800522:	46a1                	li	a3,8
  800524:	8aae                	mv	s5,a1
  800526:	bd3d                	j	800364 <vprintfmt+0x170>
                    putch(ch, putdat);
  800528:	9902                	jalr	s2
  80052a:	b559                	j	8003b0 <vprintfmt+0x1bc>
                putch('-', putdat);
  80052c:	85a6                	mv	a1,s1
  80052e:	02d00513          	li	a0,45
  800532:	e03e                	sd	a5,0(sp)
  800534:	9902                	jalr	s2
                num = -(long long)num;
  800536:	8ace                	mv	s5,s3
  800538:	40800633          	neg	a2,s0
  80053c:	46a9                	li	a3,10
  80053e:	6782                	ld	a5,0(sp)
  800540:	b515                	j	800364 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
  800542:	01b05663          	blez	s11,80054e <vprintfmt+0x35a>
  800546:	02d00693          	li	a3,45
  80054a:	f6d798e3          	bne	a5,a3,8004ba <vprintfmt+0x2c6>
  80054e:	00000417          	auipc	s0,0x0
  800552:	45340413          	addi	s0,s0,1107 # 8009a1 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800556:	02800513          	li	a0,40
  80055a:	02800793          	li	a5,40
  80055e:	bd1d                	j	800394 <vprintfmt+0x1a0>

0000000000800560 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800560:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  800562:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800566:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800568:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80056a:	ec06                	sd	ra,24(sp)
  80056c:	f83a                	sd	a4,48(sp)
  80056e:	fc3e                	sd	a5,56(sp)
  800570:	e0c2                	sd	a6,64(sp)
  800572:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800574:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800576:	c7fff0ef          	jal	ra,8001f4 <vprintfmt>
}
  80057a:	60e2                	ld	ra,24(sp)
  80057c:	6161                	addi	sp,sp,80
  80057e:	8082                	ret

0000000000800580 <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
  800580:	1101                	addi	sp,sp,-32
  800582:	ec06                	sd	ra,24(sp)
  800584:	e822                	sd	s0,16(sp)
    int pid, exit_code;
    if ((pid = fork()) == 0) {
  800586:	b51ff0ef          	jal	ra,8000d6 <fork>
  80058a:	c169                	beqz	a0,80064c <main+0xcc>
  80058c:	842a                	mv	s0,a0
        for (i = 0; i < 10; i ++) {
            yield();
        }
        exit(0xbeaf);
    }
    assert(pid > 0);
  80058e:	0aa05063          	blez	a0,80062e <main+0xae>
    assert(waitpid(-1, NULL) != 0);
  800592:	4581                	li	a1,0
  800594:	557d                	li	a0,-1
  800596:	b45ff0ef          	jal	ra,8000da <waitpid>
  80059a:	c93d                	beqz	a0,800610 <main+0x90>
    assert(waitpid(pid, (void *)0xC0000000) != 0);
  80059c:	458d                	li	a1,3
  80059e:	05fa                	slli	a1,a1,0x1e
  8005a0:	8522                	mv	a0,s0
  8005a2:	b39ff0ef          	jal	ra,8000da <waitpid>
  8005a6:	c531                	beqz	a0,8005f2 <main+0x72>
    assert(waitpid(pid, &exit_code) == 0 && exit_code == 0xbeaf);
  8005a8:	006c                	addi	a1,sp,12
  8005aa:	8522                	mv	a0,s0
  8005ac:	b2fff0ef          	jal	ra,8000da <waitpid>
  8005b0:	e115                	bnez	a0,8005d4 <main+0x54>
  8005b2:	4732                	lw	a4,12(sp)
  8005b4:	67b1                	lui	a5,0xc
  8005b6:	eaf78793          	addi	a5,a5,-337 # beaf <__panic-0x7f4171>
  8005ba:	00f71d63          	bne	a4,a5,8005d4 <main+0x54>
    cprintf("badarg pass.\n");
  8005be:	00000517          	auipc	a0,0x0
  8005c2:	4ba50513          	addi	a0,a0,1210 # 800a78 <error_string+0x278>
  8005c6:	b5dff0ef          	jal	ra,800122 <cprintf>
    return 0;
}
  8005ca:	60e2                	ld	ra,24(sp)
  8005cc:	6442                	ld	s0,16(sp)
  8005ce:	4501                	li	a0,0
  8005d0:	6105                	addi	sp,sp,32
  8005d2:	8082                	ret
    assert(waitpid(pid, &exit_code) == 0 && exit_code == 0xbeaf);
  8005d4:	00000697          	auipc	a3,0x0
  8005d8:	46c68693          	addi	a3,a3,1132 # 800a40 <error_string+0x240>
  8005dc:	00000617          	auipc	a2,0x0
  8005e0:	3fc60613          	addi	a2,a2,1020 # 8009d8 <error_string+0x1d8>
  8005e4:	45c9                	li	a1,18
  8005e6:	00000517          	auipc	a0,0x0
  8005ea:	40a50513          	addi	a0,a0,1034 # 8009f0 <error_string+0x1f0>
  8005ee:	a33ff0ef          	jal	ra,800020 <__panic>
    assert(waitpid(pid, (void *)0xC0000000) != 0);
  8005f2:	00000697          	auipc	a3,0x0
  8005f6:	42668693          	addi	a3,a3,1062 # 800a18 <error_string+0x218>
  8005fa:	00000617          	auipc	a2,0x0
  8005fe:	3de60613          	addi	a2,a2,990 # 8009d8 <error_string+0x1d8>
  800602:	45c5                	li	a1,17
  800604:	00000517          	auipc	a0,0x0
  800608:	3ec50513          	addi	a0,a0,1004 # 8009f0 <error_string+0x1f0>
  80060c:	a15ff0ef          	jal	ra,800020 <__panic>
    assert(waitpid(-1, NULL) != 0);
  800610:	00000697          	auipc	a3,0x0
  800614:	3f068693          	addi	a3,a3,1008 # 800a00 <error_string+0x200>
  800618:	00000617          	auipc	a2,0x0
  80061c:	3c060613          	addi	a2,a2,960 # 8009d8 <error_string+0x1d8>
  800620:	45c1                	li	a1,16
  800622:	00000517          	auipc	a0,0x0
  800626:	3ce50513          	addi	a0,a0,974 # 8009f0 <error_string+0x1f0>
  80062a:	9f7ff0ef          	jal	ra,800020 <__panic>
    assert(pid > 0);
  80062e:	00000697          	auipc	a3,0x0
  800632:	3a268693          	addi	a3,a3,930 # 8009d0 <error_string+0x1d0>
  800636:	00000617          	auipc	a2,0x0
  80063a:	3a260613          	addi	a2,a2,930 # 8009d8 <error_string+0x1d8>
  80063e:	45bd                	li	a1,15
  800640:	00000517          	auipc	a0,0x0
  800644:	3b050513          	addi	a0,a0,944 # 8009f0 <error_string+0x1f0>
  800648:	9d9ff0ef          	jal	ra,800020 <__panic>
        cprintf("fork ok.\n");
  80064c:	00000517          	auipc	a0,0x0
  800650:	37450513          	addi	a0,a0,884 # 8009c0 <error_string+0x1c0>
  800654:	acfff0ef          	jal	ra,800122 <cprintf>
  800658:	4429                	li	s0,10
            yield();
  80065a:	347d                	addiw	s0,s0,-1
  80065c:	a83ff0ef          	jal	ra,8000de <yield>
        for (i = 0; i < 10; i ++) {
  800660:	fc6d                	bnez	s0,80065a <main+0xda>
        exit(0xbeaf);
  800662:	6531                	lui	a0,0xc
  800664:	eaf50513          	addi	a0,a0,-337 # beaf <__panic-0x7f4171>
  800668:	a59ff0ef          	jal	ra,8000c0 <exit>
