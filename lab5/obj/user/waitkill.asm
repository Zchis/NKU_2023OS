
obj/__user_waitkill.out:     file format elf64-littleriscv


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
  800032:	6aa50513          	addi	a0,a0,1706 # 8006d8 <main+0xb4>
__panic(const char *file, int line, const char *fmt, ...) {
  800036:	ec06                	sd	ra,24(sp)
  800038:	f436                	sd	a3,40(sp)
  80003a:	f83a                	sd	a4,48(sp)
  80003c:	e0c2                	sd	a6,64(sp)
  80003e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800040:	e43e                	sd	a5,8(sp)
    cprintf("user panic at %s:%d:\n    ", file, line);
  800042:	0f6000ef          	jal	ra,800138 <cprintf>
    vcprintf(fmt, ap);
  800046:	65a2                	ld	a1,8(sp)
  800048:	8522                	mv	a0,s0
  80004a:	0ce000ef          	jal	ra,800118 <vcprintf>
    cprintf("\n");
  80004e:	00001517          	auipc	a0,0x1
  800052:	9e250513          	addi	a0,a0,-1566 # 800a30 <error_string+0x1c8>
  800056:	0e2000ef          	jal	ra,800138 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  80005a:	5559                	li	a0,-10
  80005c:	072000ef          	jal	ra,8000ce <exit>

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

00000000008000b8 <sys_kill>:
}

int
sys_kill(int64_t pid) {
    return syscall(SYS_kill, pid);
  8000b8:	85aa                	mv	a1,a0
  8000ba:	4531                	li	a0,12
  8000bc:	fa5ff06f          	j	800060 <syscall>

00000000008000c0 <sys_getpid>:
}

int
sys_getpid(void) {
    return syscall(SYS_getpid);
  8000c0:	4549                	li	a0,18
  8000c2:	f9fff06f          	j	800060 <syscall>

00000000008000c6 <sys_putc>:
}

int
sys_putc(int64_t c) {
    return syscall(SYS_putc, c);
  8000c6:	85aa                	mv	a1,a0
  8000c8:	4579                	li	a0,30
  8000ca:	f97ff06f          	j	800060 <syscall>

00000000008000ce <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8000ce:	1141                	addi	sp,sp,-16
  8000d0:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  8000d2:	fc9ff0ef          	jal	ra,80009a <sys_exit>
    cprintf("BUG: exit failed.\n");
  8000d6:	00000517          	auipc	a0,0x0
  8000da:	62250513          	addi	a0,a0,1570 # 8006f8 <main+0xd4>
  8000de:	05a000ef          	jal	ra,800138 <cprintf>
    while (1);
  8000e2:	a001                	j	8000e2 <exit+0x14>

00000000008000e4 <fork>:
}

int
fork(void) {
    return sys_fork();
  8000e4:	fbfff06f          	j	8000a2 <sys_fork>

00000000008000e8 <waitpid>:
    return sys_wait(0, NULL);
}

int
waitpid(int pid, int *store) {
    return sys_wait(pid, store);
  8000e8:	fc1ff06f          	j	8000a8 <sys_wait>

00000000008000ec <yield>:
}

void
yield(void) {
    sys_yield();
  8000ec:	fc7ff06f          	j	8000b2 <sys_yield>

00000000008000f0 <kill>:
}

int
kill(int pid) {
    return sys_kill(pid);
  8000f0:	fc9ff06f          	j	8000b8 <sys_kill>

00000000008000f4 <getpid>:
}

int
getpid(void) {
    return sys_getpid();
  8000f4:	fcdff06f          	j	8000c0 <sys_getpid>

00000000008000f8 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  8000f8:	074000ef          	jal	ra,80016c <umain>
1:  j 1b
  8000fc:	a001                	j	8000fc <_start+0x4>

00000000008000fe <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  8000fe:	1141                	addi	sp,sp,-16
  800100:	e022                	sd	s0,0(sp)
  800102:	e406                	sd	ra,8(sp)
  800104:	842e                	mv	s0,a1
    sys_putc(c);
  800106:	fc1ff0ef          	jal	ra,8000c6 <sys_putc>
    (*cnt) ++;
  80010a:	401c                	lw	a5,0(s0)
}
  80010c:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
  80010e:	2785                	addiw	a5,a5,1
  800110:	c01c                	sw	a5,0(s0)
}
  800112:	6402                	ld	s0,0(sp)
  800114:	0141                	addi	sp,sp,16
  800116:	8082                	ret

0000000000800118 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  800118:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  80011a:	86ae                	mv	a3,a1
  80011c:	862a                	mv	a2,a0
  80011e:	006c                	addi	a1,sp,12
  800120:	00000517          	auipc	a0,0x0
  800124:	fde50513          	addi	a0,a0,-34 # 8000fe <cputch>
vcprintf(const char *fmt, va_list ap) {
  800128:	ec06                	sd	ra,24(sp)
    int cnt = 0;
  80012a:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  80012c:	0de000ef          	jal	ra,80020a <vprintfmt>
    return cnt;
}
  800130:	60e2                	ld	ra,24(sp)
  800132:	4532                	lw	a0,12(sp)
  800134:	6105                	addi	sp,sp,32
  800136:	8082                	ret

0000000000800138 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  800138:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  80013a:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  80013e:	f42e                	sd	a1,40(sp)
  800140:	f832                	sd	a2,48(sp)
  800142:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800144:	862a                	mv	a2,a0
  800146:	004c                	addi	a1,sp,4
  800148:	00000517          	auipc	a0,0x0
  80014c:	fb650513          	addi	a0,a0,-74 # 8000fe <cputch>
  800150:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
  800152:	ec06                	sd	ra,24(sp)
  800154:	e0ba                	sd	a4,64(sp)
  800156:	e4be                	sd	a5,72(sp)
  800158:	e8c2                	sd	a6,80(sp)
  80015a:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
  80015c:	e41a                	sd	t1,8(sp)
    int cnt = 0;
  80015e:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800160:	0aa000ef          	jal	ra,80020a <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  800164:	60e2                	ld	ra,24(sp)
  800166:	4512                	lw	a0,4(sp)
  800168:	6125                	addi	sp,sp,96
  80016a:	8082                	ret

000000000080016c <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  80016c:	1141                	addi	sp,sp,-16
  80016e:	e406                	sd	ra,8(sp)
    int ret = main();
  800170:	4b4000ef          	jal	ra,800624 <main>
    exit(ret);
  800174:	f5bff0ef          	jal	ra,8000ce <exit>

0000000000800178 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  800178:	c185                	beqz	a1,800198 <strnlen+0x20>
  80017a:	00054783          	lbu	a5,0(a0)
  80017e:	cf89                	beqz	a5,800198 <strnlen+0x20>
    size_t cnt = 0;
  800180:	4781                	li	a5,0
  800182:	a021                	j	80018a <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
  800184:	00074703          	lbu	a4,0(a4)
  800188:	c711                	beqz	a4,800194 <strnlen+0x1c>
        cnt ++;
  80018a:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  80018c:	00f50733          	add	a4,a0,a5
  800190:	fef59ae3          	bne	a1,a5,800184 <strnlen+0xc>
    }
    return cnt;
}
  800194:	853e                	mv	a0,a5
  800196:	8082                	ret
    size_t cnt = 0;
  800198:	4781                	li	a5,0
}
  80019a:	853e                	mv	a0,a5
  80019c:	8082                	ret

000000000080019e <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  80019e:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8001a2:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  8001a4:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8001a8:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  8001aa:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  8001ae:	f022                	sd	s0,32(sp)
  8001b0:	ec26                	sd	s1,24(sp)
  8001b2:	e84a                	sd	s2,16(sp)
  8001b4:	f406                	sd	ra,40(sp)
  8001b6:	e44e                	sd	s3,8(sp)
  8001b8:	84aa                	mv	s1,a0
  8001ba:	892e                	mv	s2,a1
  8001bc:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  8001c0:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  8001c2:	03067e63          	bleu	a6,a2,8001fe <printnum+0x60>
  8001c6:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  8001c8:	00805763          	blez	s0,8001d6 <printnum+0x38>
  8001cc:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  8001ce:	85ca                	mv	a1,s2
  8001d0:	854e                	mv	a0,s3
  8001d2:	9482                	jalr	s1
        while (-- width > 0)
  8001d4:	fc65                	bnez	s0,8001cc <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  8001d6:	1a02                	slli	s4,s4,0x20
  8001d8:	020a5a13          	srli	s4,s4,0x20
  8001dc:	00000797          	auipc	a5,0x0
  8001e0:	75478793          	addi	a5,a5,1876 # 800930 <error_string+0xc8>
  8001e4:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001e6:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001e8:	000a4503          	lbu	a0,0(s4)
}
  8001ec:	70a2                	ld	ra,40(sp)
  8001ee:	69a2                	ld	s3,8(sp)
  8001f0:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001f2:	85ca                	mv	a1,s2
  8001f4:	8326                	mv	t1,s1
}
  8001f6:	6942                	ld	s2,16(sp)
  8001f8:	64e2                	ld	s1,24(sp)
  8001fa:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001fc:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
  8001fe:	03065633          	divu	a2,a2,a6
  800202:	8722                	mv	a4,s0
  800204:	f9bff0ef          	jal	ra,80019e <printnum>
  800208:	b7f9                	j	8001d6 <printnum+0x38>

000000000080020a <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  80020a:	7119                	addi	sp,sp,-128
  80020c:	f4a6                	sd	s1,104(sp)
  80020e:	f0ca                	sd	s2,96(sp)
  800210:	e8d2                	sd	s4,80(sp)
  800212:	e4d6                	sd	s5,72(sp)
  800214:	e0da                	sd	s6,64(sp)
  800216:	fc5e                	sd	s7,56(sp)
  800218:	f862                	sd	s8,48(sp)
  80021a:	f06a                	sd	s10,32(sp)
  80021c:	fc86                	sd	ra,120(sp)
  80021e:	f8a2                	sd	s0,112(sp)
  800220:	ecce                	sd	s3,88(sp)
  800222:	f466                	sd	s9,40(sp)
  800224:	ec6e                	sd	s11,24(sp)
  800226:	892a                	mv	s2,a0
  800228:	84ae                	mv	s1,a1
  80022a:	8d32                	mv	s10,a2
  80022c:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  80022e:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  800230:	00000a17          	auipc	s4,0x0
  800234:	4dca0a13          	addi	s4,s4,1244 # 80070c <main+0xe8>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
  800238:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80023c:	00000c17          	auipc	s8,0x0
  800240:	62cc0c13          	addi	s8,s8,1580 # 800868 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800244:	000d4503          	lbu	a0,0(s10)
  800248:	02500793          	li	a5,37
  80024c:	001d0413          	addi	s0,s10,1
  800250:	00f50e63          	beq	a0,a5,80026c <vprintfmt+0x62>
            if (ch == '\0') {
  800254:	c521                	beqz	a0,80029c <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800256:	02500993          	li	s3,37
  80025a:	a011                	j	80025e <vprintfmt+0x54>
            if (ch == '\0') {
  80025c:	c121                	beqz	a0,80029c <vprintfmt+0x92>
            putch(ch, putdat);
  80025e:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800260:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  800262:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800264:	fff44503          	lbu	a0,-1(s0)
  800268:	ff351ae3          	bne	a0,s3,80025c <vprintfmt+0x52>
  80026c:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  800270:	02000793          	li	a5,32
        lflag = altflag = 0;
  800274:	4981                	li	s3,0
  800276:	4801                	li	a6,0
        width = precision = -1;
  800278:	5cfd                	li	s9,-1
  80027a:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
  80027c:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
  800280:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
  800282:	fdd6069b          	addiw	a3,a2,-35
  800286:	0ff6f693          	andi	a3,a3,255
  80028a:	00140d13          	addi	s10,s0,1
  80028e:	20d5e563          	bltu	a1,a3,800498 <vprintfmt+0x28e>
  800292:	068a                	slli	a3,a3,0x2
  800294:	96d2                	add	a3,a3,s4
  800296:	4294                	lw	a3,0(a3)
  800298:	96d2                	add	a3,a3,s4
  80029a:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  80029c:	70e6                	ld	ra,120(sp)
  80029e:	7446                	ld	s0,112(sp)
  8002a0:	74a6                	ld	s1,104(sp)
  8002a2:	7906                	ld	s2,96(sp)
  8002a4:	69e6                	ld	s3,88(sp)
  8002a6:	6a46                	ld	s4,80(sp)
  8002a8:	6aa6                	ld	s5,72(sp)
  8002aa:	6b06                	ld	s6,64(sp)
  8002ac:	7be2                	ld	s7,56(sp)
  8002ae:	7c42                	ld	s8,48(sp)
  8002b0:	7ca2                	ld	s9,40(sp)
  8002b2:	7d02                	ld	s10,32(sp)
  8002b4:	6de2                	ld	s11,24(sp)
  8002b6:	6109                	addi	sp,sp,128
  8002b8:	8082                	ret
    if (lflag >= 2) {
  8002ba:	4705                	li	a4,1
  8002bc:	008a8593          	addi	a1,s5,8
  8002c0:	01074463          	blt	a4,a6,8002c8 <vprintfmt+0xbe>
    else if (lflag) {
  8002c4:	26080363          	beqz	a6,80052a <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
  8002c8:	000ab603          	ld	a2,0(s5)
  8002cc:	46c1                	li	a3,16
  8002ce:	8aae                	mv	s5,a1
  8002d0:	a06d                	j	80037a <vprintfmt+0x170>
            goto reswitch;
  8002d2:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  8002d6:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
  8002d8:	846a                	mv	s0,s10
            goto reswitch;
  8002da:	b765                	j	800282 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
  8002dc:	000aa503          	lw	a0,0(s5)
  8002e0:	85a6                	mv	a1,s1
  8002e2:	0aa1                	addi	s5,s5,8
  8002e4:	9902                	jalr	s2
            break;
  8002e6:	bfb9                	j	800244 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8002e8:	4705                	li	a4,1
  8002ea:	008a8993          	addi	s3,s5,8
  8002ee:	01074463          	blt	a4,a6,8002f6 <vprintfmt+0xec>
    else if (lflag) {
  8002f2:	22080463          	beqz	a6,80051a <vprintfmt+0x310>
        return va_arg(*ap, long);
  8002f6:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
  8002fa:	24044463          	bltz	s0,800542 <vprintfmt+0x338>
            num = getint(&ap, lflag);
  8002fe:	8622                	mv	a2,s0
  800300:	8ace                	mv	s5,s3
  800302:	46a9                	li	a3,10
  800304:	a89d                	j	80037a <vprintfmt+0x170>
            err = va_arg(ap, int);
  800306:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80030a:	4761                	li	a4,24
            err = va_arg(ap, int);
  80030c:	0aa1                	addi	s5,s5,8
            if (err < 0) {
  80030e:	41f7d69b          	sraiw	a3,a5,0x1f
  800312:	8fb5                	xor	a5,a5,a3
  800314:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800318:	1ad74363          	blt	a4,a3,8004be <vprintfmt+0x2b4>
  80031c:	00369793          	slli	a5,a3,0x3
  800320:	97e2                	add	a5,a5,s8
  800322:	639c                	ld	a5,0(a5)
  800324:	18078d63          	beqz	a5,8004be <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
  800328:	86be                	mv	a3,a5
  80032a:	00000617          	auipc	a2,0x0
  80032e:	6f660613          	addi	a2,a2,1782 # 800a20 <error_string+0x1b8>
  800332:	85a6                	mv	a1,s1
  800334:	854a                	mv	a0,s2
  800336:	240000ef          	jal	ra,800576 <printfmt>
  80033a:	b729                	j	800244 <vprintfmt+0x3a>
            lflag ++;
  80033c:	00144603          	lbu	a2,1(s0)
  800340:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
  800342:	846a                	mv	s0,s10
            goto reswitch;
  800344:	bf3d                	j	800282 <vprintfmt+0x78>
    if (lflag >= 2) {
  800346:	4705                	li	a4,1
  800348:	008a8593          	addi	a1,s5,8
  80034c:	01074463          	blt	a4,a6,800354 <vprintfmt+0x14a>
    else if (lflag) {
  800350:	1e080263          	beqz	a6,800534 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
  800354:	000ab603          	ld	a2,0(s5)
  800358:	46a1                	li	a3,8
  80035a:	8aae                	mv	s5,a1
  80035c:	a839                	j	80037a <vprintfmt+0x170>
            putch('0', putdat);
  80035e:	03000513          	li	a0,48
  800362:	85a6                	mv	a1,s1
  800364:	e03e                	sd	a5,0(sp)
  800366:	9902                	jalr	s2
            putch('x', putdat);
  800368:	85a6                	mv	a1,s1
  80036a:	07800513          	li	a0,120
  80036e:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800370:	0aa1                	addi	s5,s5,8
  800372:	ff8ab603          	ld	a2,-8(s5)
            goto number;
  800376:	6782                	ld	a5,0(sp)
  800378:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
  80037a:	876e                	mv	a4,s11
  80037c:	85a6                	mv	a1,s1
  80037e:	854a                	mv	a0,s2
  800380:	e1fff0ef          	jal	ra,80019e <printnum>
            break;
  800384:	b5c1                	j	800244 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
  800386:	000ab603          	ld	a2,0(s5)
  80038a:	0aa1                	addi	s5,s5,8
  80038c:	1c060663          	beqz	a2,800558 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
  800390:	00160413          	addi	s0,a2,1
  800394:	17b05c63          	blez	s11,80050c <vprintfmt+0x302>
  800398:	02d00593          	li	a1,45
  80039c:	14b79263          	bne	a5,a1,8004e0 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003a0:	00064783          	lbu	a5,0(a2)
  8003a4:	0007851b          	sext.w	a0,a5
  8003a8:	c905                	beqz	a0,8003d8 <vprintfmt+0x1ce>
  8003aa:	000cc563          	bltz	s9,8003b4 <vprintfmt+0x1aa>
  8003ae:	3cfd                	addiw	s9,s9,-1
  8003b0:	036c8263          	beq	s9,s6,8003d4 <vprintfmt+0x1ca>
                    putch('?', putdat);
  8003b4:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  8003b6:	18098463          	beqz	s3,80053e <vprintfmt+0x334>
  8003ba:	3781                	addiw	a5,a5,-32
  8003bc:	18fbf163          	bleu	a5,s7,80053e <vprintfmt+0x334>
                    putch('?', putdat);
  8003c0:	03f00513          	li	a0,63
  8003c4:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003c6:	0405                	addi	s0,s0,1
  8003c8:	fff44783          	lbu	a5,-1(s0)
  8003cc:	3dfd                	addiw	s11,s11,-1
  8003ce:	0007851b          	sext.w	a0,a5
  8003d2:	fd61                	bnez	a0,8003aa <vprintfmt+0x1a0>
            for (; width > 0; width --) {
  8003d4:	e7b058e3          	blez	s11,800244 <vprintfmt+0x3a>
  8003d8:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003da:	85a6                	mv	a1,s1
  8003dc:	02000513          	li	a0,32
  8003e0:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003e2:	e60d81e3          	beqz	s11,800244 <vprintfmt+0x3a>
  8003e6:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003e8:	85a6                	mv	a1,s1
  8003ea:	02000513          	li	a0,32
  8003ee:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003f0:	fe0d94e3          	bnez	s11,8003d8 <vprintfmt+0x1ce>
  8003f4:	bd81                	j	800244 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8003f6:	4705                	li	a4,1
  8003f8:	008a8593          	addi	a1,s5,8
  8003fc:	01074463          	blt	a4,a6,800404 <vprintfmt+0x1fa>
    else if (lflag) {
  800400:	12080063          	beqz	a6,800520 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
  800404:	000ab603          	ld	a2,0(s5)
  800408:	46a9                	li	a3,10
  80040a:	8aae                	mv	s5,a1
  80040c:	b7bd                	j	80037a <vprintfmt+0x170>
  80040e:	00144603          	lbu	a2,1(s0)
            padc = '-';
  800412:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
  800416:	846a                	mv	s0,s10
  800418:	b5ad                	j	800282 <vprintfmt+0x78>
            putch(ch, putdat);
  80041a:	85a6                	mv	a1,s1
  80041c:	02500513          	li	a0,37
  800420:	9902                	jalr	s2
            break;
  800422:	b50d                	j	800244 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
  800424:	000aac83          	lw	s9,0(s5)
            goto process_precision;
  800428:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  80042c:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
  80042e:	846a                	mv	s0,s10
            if (width < 0)
  800430:	e40dd9e3          	bgez	s11,800282 <vprintfmt+0x78>
                width = precision, precision = -1;
  800434:	8de6                	mv	s11,s9
  800436:	5cfd                	li	s9,-1
  800438:	b5a9                	j	800282 <vprintfmt+0x78>
            goto reswitch;
  80043a:	00144603          	lbu	a2,1(s0)
            padc = '0';
  80043e:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
  800442:	846a                	mv	s0,s10
            goto reswitch;
  800444:	bd3d                	j	800282 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
  800446:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
  80044a:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  80044e:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  800450:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  800454:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  800458:	fcd56ce3          	bltu	a0,a3,800430 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
  80045c:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  80045e:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
  800462:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
  800466:	0196873b          	addw	a4,a3,s9
  80046a:	0017171b          	slliw	a4,a4,0x1
  80046e:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
  800472:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
  800476:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  80047a:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  80047e:	fcd57fe3          	bleu	a3,a0,80045c <vprintfmt+0x252>
  800482:	b77d                	j	800430 <vprintfmt+0x226>
            if (width < 0)
  800484:	fffdc693          	not	a3,s11
  800488:	96fd                	srai	a3,a3,0x3f
  80048a:	00ddfdb3          	and	s11,s11,a3
  80048e:	00144603          	lbu	a2,1(s0)
  800492:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
  800494:	846a                	mv	s0,s10
  800496:	b3f5                	j	800282 <vprintfmt+0x78>
            putch('%', putdat);
  800498:	85a6                	mv	a1,s1
  80049a:	02500513          	li	a0,37
  80049e:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  8004a0:	fff44703          	lbu	a4,-1(s0)
  8004a4:	02500793          	li	a5,37
  8004a8:	8d22                	mv	s10,s0
  8004aa:	d8f70de3          	beq	a4,a5,800244 <vprintfmt+0x3a>
  8004ae:	02500713          	li	a4,37
  8004b2:	1d7d                	addi	s10,s10,-1
  8004b4:	fffd4783          	lbu	a5,-1(s10)
  8004b8:	fee79de3          	bne	a5,a4,8004b2 <vprintfmt+0x2a8>
  8004bc:	b361                	j	800244 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  8004be:	00000617          	auipc	a2,0x0
  8004c2:	55260613          	addi	a2,a2,1362 # 800a10 <error_string+0x1a8>
  8004c6:	85a6                	mv	a1,s1
  8004c8:	854a                	mv	a0,s2
  8004ca:	0ac000ef          	jal	ra,800576 <printfmt>
  8004ce:	bb9d                	j	800244 <vprintfmt+0x3a>
                p = "(null)";
  8004d0:	00000617          	auipc	a2,0x0
  8004d4:	53860613          	addi	a2,a2,1336 # 800a08 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
  8004d8:	00000417          	auipc	s0,0x0
  8004dc:	53140413          	addi	s0,s0,1329 # 800a09 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004e0:	8532                	mv	a0,a2
  8004e2:	85e6                	mv	a1,s9
  8004e4:	e032                	sd	a2,0(sp)
  8004e6:	e43e                	sd	a5,8(sp)
  8004e8:	c91ff0ef          	jal	ra,800178 <strnlen>
  8004ec:	40ad8dbb          	subw	s11,s11,a0
  8004f0:	6602                	ld	a2,0(sp)
  8004f2:	01b05d63          	blez	s11,80050c <vprintfmt+0x302>
  8004f6:	67a2                	ld	a5,8(sp)
  8004f8:	2781                	sext.w	a5,a5
  8004fa:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
  8004fc:	6522                	ld	a0,8(sp)
  8004fe:	85a6                	mv	a1,s1
  800500:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  800502:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  800504:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  800506:	6602                	ld	a2,0(sp)
  800508:	fe0d9ae3          	bnez	s11,8004fc <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80050c:	00064783          	lbu	a5,0(a2)
  800510:	0007851b          	sext.w	a0,a5
  800514:	e8051be3          	bnez	a0,8003aa <vprintfmt+0x1a0>
  800518:	b335                	j	800244 <vprintfmt+0x3a>
        return va_arg(*ap, int);
  80051a:	000aa403          	lw	s0,0(s5)
  80051e:	bbf1                	j	8002fa <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
  800520:	000ae603          	lwu	a2,0(s5)
  800524:	46a9                	li	a3,10
  800526:	8aae                	mv	s5,a1
  800528:	bd89                	j	80037a <vprintfmt+0x170>
  80052a:	000ae603          	lwu	a2,0(s5)
  80052e:	46c1                	li	a3,16
  800530:	8aae                	mv	s5,a1
  800532:	b5a1                	j	80037a <vprintfmt+0x170>
  800534:	000ae603          	lwu	a2,0(s5)
  800538:	46a1                	li	a3,8
  80053a:	8aae                	mv	s5,a1
  80053c:	bd3d                	j	80037a <vprintfmt+0x170>
                    putch(ch, putdat);
  80053e:	9902                	jalr	s2
  800540:	b559                	j	8003c6 <vprintfmt+0x1bc>
                putch('-', putdat);
  800542:	85a6                	mv	a1,s1
  800544:	02d00513          	li	a0,45
  800548:	e03e                	sd	a5,0(sp)
  80054a:	9902                	jalr	s2
                num = -(long long)num;
  80054c:	8ace                	mv	s5,s3
  80054e:	40800633          	neg	a2,s0
  800552:	46a9                	li	a3,10
  800554:	6782                	ld	a5,0(sp)
  800556:	b515                	j	80037a <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
  800558:	01b05663          	blez	s11,800564 <vprintfmt+0x35a>
  80055c:	02d00693          	li	a3,45
  800560:	f6d798e3          	bne	a5,a3,8004d0 <vprintfmt+0x2c6>
  800564:	00000417          	auipc	s0,0x0
  800568:	4a540413          	addi	s0,s0,1189 # 800a09 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80056c:	02800513          	li	a0,40
  800570:	02800793          	li	a5,40
  800574:	bd1d                	j	8003aa <vprintfmt+0x1a0>

0000000000800576 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800576:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  800578:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80057c:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80057e:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800580:	ec06                	sd	ra,24(sp)
  800582:	f83a                	sd	a4,48(sp)
  800584:	fc3e                	sd	a5,56(sp)
  800586:	e0c2                	sd	a6,64(sp)
  800588:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  80058a:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80058c:	c7fff0ef          	jal	ra,80020a <vprintfmt>
}
  800590:	60e2                	ld	ra,24(sp)
  800592:	6161                	addi	sp,sp,80
  800594:	8082                	ret

0000000000800596 <do_yield>:
#include <ulib.h>
#include <stdio.h>

void
do_yield(void) {
  800596:	1141                	addi	sp,sp,-16
  800598:	e406                	sd	ra,8(sp)
    yield();
  80059a:	b53ff0ef          	jal	ra,8000ec <yield>
    yield();
  80059e:	b4fff0ef          	jal	ra,8000ec <yield>
    yield();
  8005a2:	b4bff0ef          	jal	ra,8000ec <yield>
    yield();
  8005a6:	b47ff0ef          	jal	ra,8000ec <yield>
    yield();
  8005aa:	b43ff0ef          	jal	ra,8000ec <yield>
    yield();
}
  8005ae:	60a2                	ld	ra,8(sp)
  8005b0:	0141                	addi	sp,sp,16
    yield();
  8005b2:	b3bff06f          	j	8000ec <yield>

00000000008005b6 <loop>:

int parent, pid1, pid2;

void
loop(void) {
  8005b6:	1141                	addi	sp,sp,-16
    cprintf("child 1.\n");
  8005b8:	00000517          	auipc	a0,0x0
  8005bc:	47050513          	addi	a0,a0,1136 # 800a28 <error_string+0x1c0>
loop(void) {
  8005c0:	e406                	sd	ra,8(sp)
    cprintf("child 1.\n");
  8005c2:	b77ff0ef          	jal	ra,800138 <cprintf>
    while (1);
  8005c6:	a001                	j	8005c6 <loop+0x10>

00000000008005c8 <work>:
}

void
work(void) {
  8005c8:	1141                	addi	sp,sp,-16
    cprintf("child 2.\n");
  8005ca:	00000517          	auipc	a0,0x0
  8005ce:	4de50513          	addi	a0,a0,1246 # 800aa8 <error_string+0x240>
work(void) {
  8005d2:	e406                	sd	ra,8(sp)
    cprintf("child 2.\n");
  8005d4:	b65ff0ef          	jal	ra,800138 <cprintf>
    do_yield();
  8005d8:	fbfff0ef          	jal	ra,800596 <do_yield>
    if (kill(parent) == 0) {
  8005dc:	00001797          	auipc	a5,0x1
  8005e0:	a2478793          	addi	a5,a5,-1500 # 801000 <parent>
  8005e4:	4388                	lw	a0,0(a5)
  8005e6:	b0bff0ef          	jal	ra,8000f0 <kill>
  8005ea:	e10d                	bnez	a0,80060c <work+0x44>
        cprintf("kill parent ok.\n");
  8005ec:	00000517          	auipc	a0,0x0
  8005f0:	4cc50513          	addi	a0,a0,1228 # 800ab8 <error_string+0x250>
  8005f4:	b45ff0ef          	jal	ra,800138 <cprintf>
        do_yield();
  8005f8:	f9fff0ef          	jal	ra,800596 <do_yield>
        if (kill(pid1) == 0) {
  8005fc:	00001797          	auipc	a5,0x1
  800600:	a0c78793          	addi	a5,a5,-1524 # 801008 <pid1>
  800604:	4388                	lw	a0,0(a5)
  800606:	aebff0ef          	jal	ra,8000f0 <kill>
  80060a:	c501                	beqz	a0,800612 <work+0x4a>
            cprintf("kill child1 ok.\n");
            exit(0);
        }
    }
    exit(-1);
  80060c:	557d                	li	a0,-1
  80060e:	ac1ff0ef          	jal	ra,8000ce <exit>
            cprintf("kill child1 ok.\n");
  800612:	00000517          	auipc	a0,0x0
  800616:	4be50513          	addi	a0,a0,1214 # 800ad0 <error_string+0x268>
  80061a:	b1fff0ef          	jal	ra,800138 <cprintf>
            exit(0);
  80061e:	4501                	li	a0,0
  800620:	aafff0ef          	jal	ra,8000ce <exit>

0000000000800624 <main>:
}

int
main(void) {
  800624:	1141                	addi	sp,sp,-16
  800626:	e406                	sd	ra,8(sp)
  800628:	e022                	sd	s0,0(sp)
    parent = getpid();
  80062a:	acbff0ef          	jal	ra,8000f4 <getpid>
  80062e:	00001797          	auipc	a5,0x1
  800632:	9ca7a923          	sw	a0,-1582(a5) # 801000 <parent>
    if ((pid1 = fork()) == 0) {
  800636:	aafff0ef          	jal	ra,8000e4 <fork>
  80063a:	00001797          	auipc	a5,0x1
  80063e:	9ca7a723          	sw	a0,-1586(a5) # 801008 <pid1>
  800642:	c53d                	beqz	a0,8006b0 <main+0x8c>
        loop();
    }

    assert(pid1 > 0);
  800644:	04a05663          	blez	a0,800690 <main+0x6c>

    if ((pid2 = fork()) == 0) {
  800648:	a9dff0ef          	jal	ra,8000e4 <fork>
  80064c:	00001797          	auipc	a5,0x1
  800650:	9aa7ac23          	sw	a0,-1608(a5) # 801004 <pid2>
  800654:	cd3d                	beqz	a0,8006d2 <main+0xae>
  800656:	00001417          	auipc	s0,0x1
  80065a:	9b240413          	addi	s0,s0,-1614 # 801008 <pid1>
        work();
    }
    if (pid2 > 0) {
  80065e:	04a05b63          	blez	a0,8006b4 <main+0x90>
        cprintf("wait child 1.\n");
  800662:	00000517          	auipc	a0,0x0
  800666:	40e50513          	addi	a0,a0,1038 # 800a70 <error_string+0x208>
  80066a:	acfff0ef          	jal	ra,800138 <cprintf>
        waitpid(pid1, NULL);
  80066e:	4008                	lw	a0,0(s0)
  800670:	4581                	li	a1,0
  800672:	a77ff0ef          	jal	ra,8000e8 <waitpid>
        panic("waitpid %d returns\n", pid1);
  800676:	4014                	lw	a3,0(s0)
  800678:	00000617          	auipc	a2,0x0
  80067c:	40860613          	addi	a2,a2,1032 # 800a80 <error_string+0x218>
  800680:	03400593          	li	a1,52
  800684:	00000517          	auipc	a0,0x0
  800688:	3dc50513          	addi	a0,a0,988 # 800a60 <error_string+0x1f8>
  80068c:	995ff0ef          	jal	ra,800020 <__panic>
    assert(pid1 > 0);
  800690:	00000697          	auipc	a3,0x0
  800694:	3a868693          	addi	a3,a3,936 # 800a38 <error_string+0x1d0>
  800698:	00000617          	auipc	a2,0x0
  80069c:	3b060613          	addi	a2,a2,944 # 800a48 <error_string+0x1e0>
  8006a0:	02c00593          	li	a1,44
  8006a4:	00000517          	auipc	a0,0x0
  8006a8:	3bc50513          	addi	a0,a0,956 # 800a60 <error_string+0x1f8>
  8006ac:	975ff0ef          	jal	ra,800020 <__panic>
        loop();
  8006b0:	f07ff0ef          	jal	ra,8005b6 <loop>
    }
    else {
        kill(pid1);
  8006b4:	4008                	lw	a0,0(s0)
  8006b6:	a3bff0ef          	jal	ra,8000f0 <kill>
    }
    panic("FAIL: T.T\n");
  8006ba:	00000617          	auipc	a2,0x0
  8006be:	3de60613          	addi	a2,a2,990 # 800a98 <error_string+0x230>
  8006c2:	03900593          	li	a1,57
  8006c6:	00000517          	auipc	a0,0x0
  8006ca:	39a50513          	addi	a0,a0,922 # 800a60 <error_string+0x1f8>
  8006ce:	953ff0ef          	jal	ra,800020 <__panic>
        work();
  8006d2:	ef7ff0ef          	jal	ra,8005c8 <work>
