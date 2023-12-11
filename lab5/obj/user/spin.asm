
obj/__user_spin.out:     file format elf64-littleriscv


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
  800032:	62a50513          	addi	a0,a0,1578 # 800658 <main+0xcc>
__panic(const char *file, int line, const char *fmt, ...) {
  800036:	ec06                	sd	ra,24(sp)
  800038:	f436                	sd	a3,40(sp)
  80003a:	f83a                	sd	a4,48(sp)
  80003c:	e0c2                	sd	a6,64(sp)
  80003e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800040:	e43e                	sd	a5,8(sp)
    cprintf("user panic at %s:%d:\n    ", file, line);
  800042:	0ec000ef          	jal	ra,80012e <cprintf>
    vcprintf(fmt, ap);
  800046:	65a2                	ld	a1,8(sp)
  800048:	8522                	mv	a0,s0
  80004a:	0c4000ef          	jal	ra,80010e <vcprintf>
    cprintf("\n");
  80004e:	00000517          	auipc	a0,0x0
  800052:	62a50513          	addi	a0,a0,1578 # 800678 <main+0xec>
  800056:	0d8000ef          	jal	ra,80012e <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  80005a:	5559                	li	a0,-10
  80005c:	06c000ef          	jal	ra,8000c8 <exit>

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

00000000008000c0 <sys_putc>:
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
    return syscall(SYS_putc, c);
  8000c0:	85aa                	mv	a1,a0
  8000c2:	4579                	li	a0,30
  8000c4:	f9dff06f          	j	800060 <syscall>

00000000008000c8 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8000c8:	1141                	addi	sp,sp,-16
  8000ca:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  8000cc:	fcfff0ef          	jal	ra,80009a <sys_exit>
    cprintf("BUG: exit failed.\n");
  8000d0:	00000517          	auipc	a0,0x0
  8000d4:	5b050513          	addi	a0,a0,1456 # 800680 <main+0xf4>
  8000d8:	056000ef          	jal	ra,80012e <cprintf>
    while (1);
  8000dc:	a001                	j	8000dc <exit+0x14>

00000000008000de <fork>:
}

int
fork(void) {
    return sys_fork();
  8000de:	fc5ff06f          	j	8000a2 <sys_fork>

00000000008000e2 <waitpid>:
    return sys_wait(0, NULL);
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

00000000008000ea <kill>:
}

int
kill(int pid) {
    return sys_kill(pid);
  8000ea:	fcfff06f          	j	8000b8 <sys_kill>

00000000008000ee <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  8000ee:	074000ef          	jal	ra,800162 <umain>
1:  j 1b
  8000f2:	a001                	j	8000f2 <_start+0x4>

00000000008000f4 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  8000f4:	1141                	addi	sp,sp,-16
  8000f6:	e022                	sd	s0,0(sp)
  8000f8:	e406                	sd	ra,8(sp)
  8000fa:	842e                	mv	s0,a1
    sys_putc(c);
  8000fc:	fc5ff0ef          	jal	ra,8000c0 <sys_putc>
    (*cnt) ++;
  800100:	401c                	lw	a5,0(s0)
}
  800102:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
  800104:	2785                	addiw	a5,a5,1
  800106:	c01c                	sw	a5,0(s0)
}
  800108:	6402                	ld	s0,0(sp)
  80010a:	0141                	addi	sp,sp,16
  80010c:	8082                	ret

000000000080010e <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  80010e:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800110:	86ae                	mv	a3,a1
  800112:	862a                	mv	a2,a0
  800114:	006c                	addi	a1,sp,12
  800116:	00000517          	auipc	a0,0x0
  80011a:	fde50513          	addi	a0,a0,-34 # 8000f4 <cputch>
vcprintf(const char *fmt, va_list ap) {
  80011e:	ec06                	sd	ra,24(sp)
    int cnt = 0;
  800120:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800122:	0de000ef          	jal	ra,800200 <vprintfmt>
    return cnt;
}
  800126:	60e2                	ld	ra,24(sp)
  800128:	4532                	lw	a0,12(sp)
  80012a:	6105                	addi	sp,sp,32
  80012c:	8082                	ret

000000000080012e <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  80012e:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  800130:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  800134:	f42e                	sd	a1,40(sp)
  800136:	f832                	sd	a2,48(sp)
  800138:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  80013a:	862a                	mv	a2,a0
  80013c:	004c                	addi	a1,sp,4
  80013e:	00000517          	auipc	a0,0x0
  800142:	fb650513          	addi	a0,a0,-74 # 8000f4 <cputch>
  800146:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
  800148:	ec06                	sd	ra,24(sp)
  80014a:	e0ba                	sd	a4,64(sp)
  80014c:	e4be                	sd	a5,72(sp)
  80014e:	e8c2                	sd	a6,80(sp)
  800150:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
  800152:	e41a                	sd	t1,8(sp)
    int cnt = 0;
  800154:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800156:	0aa000ef          	jal	ra,800200 <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  80015a:	60e2                	ld	ra,24(sp)
  80015c:	4512                	lw	a0,4(sp)
  80015e:	6125                	addi	sp,sp,96
  800160:	8082                	ret

0000000000800162 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  800162:	1141                	addi	sp,sp,-16
  800164:	e406                	sd	ra,8(sp)
    int ret = main();
  800166:	426000ef          	jal	ra,80058c <main>
    exit(ret);
  80016a:	f5fff0ef          	jal	ra,8000c8 <exit>

000000000080016e <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  80016e:	c185                	beqz	a1,80018e <strnlen+0x20>
  800170:	00054783          	lbu	a5,0(a0)
  800174:	cf89                	beqz	a5,80018e <strnlen+0x20>
    size_t cnt = 0;
  800176:	4781                	li	a5,0
  800178:	a021                	j	800180 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
  80017a:	00074703          	lbu	a4,0(a4)
  80017e:	c711                	beqz	a4,80018a <strnlen+0x1c>
        cnt ++;
  800180:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800182:	00f50733          	add	a4,a0,a5
  800186:	fef59ae3          	bne	a1,a5,80017a <strnlen+0xc>
    }
    return cnt;
}
  80018a:	853e                	mv	a0,a5
  80018c:	8082                	ret
    size_t cnt = 0;
  80018e:	4781                	li	a5,0
}
  800190:	853e                	mv	a0,a5
  800192:	8082                	ret

0000000000800194 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800194:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800198:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  80019a:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80019e:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  8001a0:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  8001a4:	f022                	sd	s0,32(sp)
  8001a6:	ec26                	sd	s1,24(sp)
  8001a8:	e84a                	sd	s2,16(sp)
  8001aa:	f406                	sd	ra,40(sp)
  8001ac:	e44e                	sd	s3,8(sp)
  8001ae:	84aa                	mv	s1,a0
  8001b0:	892e                	mv	s2,a1
  8001b2:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  8001b6:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  8001b8:	03067e63          	bleu	a6,a2,8001f4 <printnum+0x60>
  8001bc:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  8001be:	00805763          	blez	s0,8001cc <printnum+0x38>
  8001c2:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  8001c4:	85ca                	mv	a1,s2
  8001c6:	854e                	mv	a0,s3
  8001c8:	9482                	jalr	s1
        while (-- width > 0)
  8001ca:	fc65                	bnez	s0,8001c2 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  8001cc:	1a02                	slli	s4,s4,0x20
  8001ce:	020a5a13          	srli	s4,s4,0x20
  8001d2:	00000797          	auipc	a5,0x0
  8001d6:	6e678793          	addi	a5,a5,1766 # 8008b8 <error_string+0xc8>
  8001da:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001dc:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001de:	000a4503          	lbu	a0,0(s4)
}
  8001e2:	70a2                	ld	ra,40(sp)
  8001e4:	69a2                	ld	s3,8(sp)
  8001e6:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001e8:	85ca                	mv	a1,s2
  8001ea:	8326                	mv	t1,s1
}
  8001ec:	6942                	ld	s2,16(sp)
  8001ee:	64e2                	ld	s1,24(sp)
  8001f0:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001f2:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
  8001f4:	03065633          	divu	a2,a2,a6
  8001f8:	8722                	mv	a4,s0
  8001fa:	f9bff0ef          	jal	ra,800194 <printnum>
  8001fe:	b7f9                	j	8001cc <printnum+0x38>

0000000000800200 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  800200:	7119                	addi	sp,sp,-128
  800202:	f4a6                	sd	s1,104(sp)
  800204:	f0ca                	sd	s2,96(sp)
  800206:	e8d2                	sd	s4,80(sp)
  800208:	e4d6                	sd	s5,72(sp)
  80020a:	e0da                	sd	s6,64(sp)
  80020c:	fc5e                	sd	s7,56(sp)
  80020e:	f862                	sd	s8,48(sp)
  800210:	f06a                	sd	s10,32(sp)
  800212:	fc86                	sd	ra,120(sp)
  800214:	f8a2                	sd	s0,112(sp)
  800216:	ecce                	sd	s3,88(sp)
  800218:	f466                	sd	s9,40(sp)
  80021a:	ec6e                	sd	s11,24(sp)
  80021c:	892a                	mv	s2,a0
  80021e:	84ae                	mv	s1,a1
  800220:	8d32                	mv	s10,a2
  800222:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  800224:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  800226:	00000a17          	auipc	s4,0x0
  80022a:	46ea0a13          	addi	s4,s4,1134 # 800694 <main+0x108>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
  80022e:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800232:	00000c17          	auipc	s8,0x0
  800236:	5bec0c13          	addi	s8,s8,1470 # 8007f0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80023a:	000d4503          	lbu	a0,0(s10)
  80023e:	02500793          	li	a5,37
  800242:	001d0413          	addi	s0,s10,1
  800246:	00f50e63          	beq	a0,a5,800262 <vprintfmt+0x62>
            if (ch == '\0') {
  80024a:	c521                	beqz	a0,800292 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80024c:	02500993          	li	s3,37
  800250:	a011                	j	800254 <vprintfmt+0x54>
            if (ch == '\0') {
  800252:	c121                	beqz	a0,800292 <vprintfmt+0x92>
            putch(ch, putdat);
  800254:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800256:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  800258:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80025a:	fff44503          	lbu	a0,-1(s0)
  80025e:	ff351ae3          	bne	a0,s3,800252 <vprintfmt+0x52>
  800262:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  800266:	02000793          	li	a5,32
        lflag = altflag = 0;
  80026a:	4981                	li	s3,0
  80026c:	4801                	li	a6,0
        width = precision = -1;
  80026e:	5cfd                	li	s9,-1
  800270:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
  800272:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
  800276:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
  800278:	fdd6069b          	addiw	a3,a2,-35
  80027c:	0ff6f693          	andi	a3,a3,255
  800280:	00140d13          	addi	s10,s0,1
  800284:	20d5e563          	bltu	a1,a3,80048e <vprintfmt+0x28e>
  800288:	068a                	slli	a3,a3,0x2
  80028a:	96d2                	add	a3,a3,s4
  80028c:	4294                	lw	a3,0(a3)
  80028e:	96d2                	add	a3,a3,s4
  800290:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  800292:	70e6                	ld	ra,120(sp)
  800294:	7446                	ld	s0,112(sp)
  800296:	74a6                	ld	s1,104(sp)
  800298:	7906                	ld	s2,96(sp)
  80029a:	69e6                	ld	s3,88(sp)
  80029c:	6a46                	ld	s4,80(sp)
  80029e:	6aa6                	ld	s5,72(sp)
  8002a0:	6b06                	ld	s6,64(sp)
  8002a2:	7be2                	ld	s7,56(sp)
  8002a4:	7c42                	ld	s8,48(sp)
  8002a6:	7ca2                	ld	s9,40(sp)
  8002a8:	7d02                	ld	s10,32(sp)
  8002aa:	6de2                	ld	s11,24(sp)
  8002ac:	6109                	addi	sp,sp,128
  8002ae:	8082                	ret
    if (lflag >= 2) {
  8002b0:	4705                	li	a4,1
  8002b2:	008a8593          	addi	a1,s5,8
  8002b6:	01074463          	blt	a4,a6,8002be <vprintfmt+0xbe>
    else if (lflag) {
  8002ba:	26080363          	beqz	a6,800520 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
  8002be:	000ab603          	ld	a2,0(s5)
  8002c2:	46c1                	li	a3,16
  8002c4:	8aae                	mv	s5,a1
  8002c6:	a06d                	j	800370 <vprintfmt+0x170>
            goto reswitch;
  8002c8:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  8002cc:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
  8002ce:	846a                	mv	s0,s10
            goto reswitch;
  8002d0:	b765                	j	800278 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
  8002d2:	000aa503          	lw	a0,0(s5)
  8002d6:	85a6                	mv	a1,s1
  8002d8:	0aa1                	addi	s5,s5,8
  8002da:	9902                	jalr	s2
            break;
  8002dc:	bfb9                	j	80023a <vprintfmt+0x3a>
    if (lflag >= 2) {
  8002de:	4705                	li	a4,1
  8002e0:	008a8993          	addi	s3,s5,8
  8002e4:	01074463          	blt	a4,a6,8002ec <vprintfmt+0xec>
    else if (lflag) {
  8002e8:	22080463          	beqz	a6,800510 <vprintfmt+0x310>
        return va_arg(*ap, long);
  8002ec:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
  8002f0:	24044463          	bltz	s0,800538 <vprintfmt+0x338>
            num = getint(&ap, lflag);
  8002f4:	8622                	mv	a2,s0
  8002f6:	8ace                	mv	s5,s3
  8002f8:	46a9                	li	a3,10
  8002fa:	a89d                	j	800370 <vprintfmt+0x170>
            err = va_arg(ap, int);
  8002fc:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800300:	4761                	li	a4,24
            err = va_arg(ap, int);
  800302:	0aa1                	addi	s5,s5,8
            if (err < 0) {
  800304:	41f7d69b          	sraiw	a3,a5,0x1f
  800308:	8fb5                	xor	a5,a5,a3
  80030a:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80030e:	1ad74363          	blt	a4,a3,8004b4 <vprintfmt+0x2b4>
  800312:	00369793          	slli	a5,a3,0x3
  800316:	97e2                	add	a5,a5,s8
  800318:	639c                	ld	a5,0(a5)
  80031a:	18078d63          	beqz	a5,8004b4 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
  80031e:	86be                	mv	a3,a5
  800320:	00000617          	auipc	a2,0x0
  800324:	68860613          	addi	a2,a2,1672 # 8009a8 <error_string+0x1b8>
  800328:	85a6                	mv	a1,s1
  80032a:	854a                	mv	a0,s2
  80032c:	240000ef          	jal	ra,80056c <printfmt>
  800330:	b729                	j	80023a <vprintfmt+0x3a>
            lflag ++;
  800332:	00144603          	lbu	a2,1(s0)
  800336:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
  800338:	846a                	mv	s0,s10
            goto reswitch;
  80033a:	bf3d                	j	800278 <vprintfmt+0x78>
    if (lflag >= 2) {
  80033c:	4705                	li	a4,1
  80033e:	008a8593          	addi	a1,s5,8
  800342:	01074463          	blt	a4,a6,80034a <vprintfmt+0x14a>
    else if (lflag) {
  800346:	1e080263          	beqz	a6,80052a <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
  80034a:	000ab603          	ld	a2,0(s5)
  80034e:	46a1                	li	a3,8
  800350:	8aae                	mv	s5,a1
  800352:	a839                	j	800370 <vprintfmt+0x170>
            putch('0', putdat);
  800354:	03000513          	li	a0,48
  800358:	85a6                	mv	a1,s1
  80035a:	e03e                	sd	a5,0(sp)
  80035c:	9902                	jalr	s2
            putch('x', putdat);
  80035e:	85a6                	mv	a1,s1
  800360:	07800513          	li	a0,120
  800364:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800366:	0aa1                	addi	s5,s5,8
  800368:	ff8ab603          	ld	a2,-8(s5)
            goto number;
  80036c:	6782                	ld	a5,0(sp)
  80036e:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
  800370:	876e                	mv	a4,s11
  800372:	85a6                	mv	a1,s1
  800374:	854a                	mv	a0,s2
  800376:	e1fff0ef          	jal	ra,800194 <printnum>
            break;
  80037a:	b5c1                	j	80023a <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
  80037c:	000ab603          	ld	a2,0(s5)
  800380:	0aa1                	addi	s5,s5,8
  800382:	1c060663          	beqz	a2,80054e <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
  800386:	00160413          	addi	s0,a2,1
  80038a:	17b05c63          	blez	s11,800502 <vprintfmt+0x302>
  80038e:	02d00593          	li	a1,45
  800392:	14b79263          	bne	a5,a1,8004d6 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800396:	00064783          	lbu	a5,0(a2)
  80039a:	0007851b          	sext.w	a0,a5
  80039e:	c905                	beqz	a0,8003ce <vprintfmt+0x1ce>
  8003a0:	000cc563          	bltz	s9,8003aa <vprintfmt+0x1aa>
  8003a4:	3cfd                	addiw	s9,s9,-1
  8003a6:	036c8263          	beq	s9,s6,8003ca <vprintfmt+0x1ca>
                    putch('?', putdat);
  8003aa:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  8003ac:	18098463          	beqz	s3,800534 <vprintfmt+0x334>
  8003b0:	3781                	addiw	a5,a5,-32
  8003b2:	18fbf163          	bleu	a5,s7,800534 <vprintfmt+0x334>
                    putch('?', putdat);
  8003b6:	03f00513          	li	a0,63
  8003ba:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003bc:	0405                	addi	s0,s0,1
  8003be:	fff44783          	lbu	a5,-1(s0)
  8003c2:	3dfd                	addiw	s11,s11,-1
  8003c4:	0007851b          	sext.w	a0,a5
  8003c8:	fd61                	bnez	a0,8003a0 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
  8003ca:	e7b058e3          	blez	s11,80023a <vprintfmt+0x3a>
  8003ce:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003d0:	85a6                	mv	a1,s1
  8003d2:	02000513          	li	a0,32
  8003d6:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003d8:	e60d81e3          	beqz	s11,80023a <vprintfmt+0x3a>
  8003dc:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003de:	85a6                	mv	a1,s1
  8003e0:	02000513          	li	a0,32
  8003e4:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003e6:	fe0d94e3          	bnez	s11,8003ce <vprintfmt+0x1ce>
  8003ea:	bd81                	j	80023a <vprintfmt+0x3a>
    if (lflag >= 2) {
  8003ec:	4705                	li	a4,1
  8003ee:	008a8593          	addi	a1,s5,8
  8003f2:	01074463          	blt	a4,a6,8003fa <vprintfmt+0x1fa>
    else if (lflag) {
  8003f6:	12080063          	beqz	a6,800516 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
  8003fa:	000ab603          	ld	a2,0(s5)
  8003fe:	46a9                	li	a3,10
  800400:	8aae                	mv	s5,a1
  800402:	b7bd                	j	800370 <vprintfmt+0x170>
  800404:	00144603          	lbu	a2,1(s0)
            padc = '-';
  800408:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
  80040c:	846a                	mv	s0,s10
  80040e:	b5ad                	j	800278 <vprintfmt+0x78>
            putch(ch, putdat);
  800410:	85a6                	mv	a1,s1
  800412:	02500513          	li	a0,37
  800416:	9902                	jalr	s2
            break;
  800418:	b50d                	j	80023a <vprintfmt+0x3a>
            precision = va_arg(ap, int);
  80041a:	000aac83          	lw	s9,0(s5)
            goto process_precision;
  80041e:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  800422:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
  800424:	846a                	mv	s0,s10
            if (width < 0)
  800426:	e40dd9e3          	bgez	s11,800278 <vprintfmt+0x78>
                width = precision, precision = -1;
  80042a:	8de6                	mv	s11,s9
  80042c:	5cfd                	li	s9,-1
  80042e:	b5a9                	j	800278 <vprintfmt+0x78>
            goto reswitch;
  800430:	00144603          	lbu	a2,1(s0)
            padc = '0';
  800434:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
  800438:	846a                	mv	s0,s10
            goto reswitch;
  80043a:	bd3d                	j	800278 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
  80043c:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
  800440:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  800444:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  800446:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  80044a:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  80044e:	fcd56ce3          	bltu	a0,a3,800426 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
  800452:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  800454:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
  800458:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
  80045c:	0196873b          	addw	a4,a3,s9
  800460:	0017171b          	slliw	a4,a4,0x1
  800464:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
  800468:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
  80046c:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  800470:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  800474:	fcd57fe3          	bleu	a3,a0,800452 <vprintfmt+0x252>
  800478:	b77d                	j	800426 <vprintfmt+0x226>
            if (width < 0)
  80047a:	fffdc693          	not	a3,s11
  80047e:	96fd                	srai	a3,a3,0x3f
  800480:	00ddfdb3          	and	s11,s11,a3
  800484:	00144603          	lbu	a2,1(s0)
  800488:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
  80048a:	846a                	mv	s0,s10
  80048c:	b3f5                	j	800278 <vprintfmt+0x78>
            putch('%', putdat);
  80048e:	85a6                	mv	a1,s1
  800490:	02500513          	li	a0,37
  800494:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  800496:	fff44703          	lbu	a4,-1(s0)
  80049a:	02500793          	li	a5,37
  80049e:	8d22                	mv	s10,s0
  8004a0:	d8f70de3          	beq	a4,a5,80023a <vprintfmt+0x3a>
  8004a4:	02500713          	li	a4,37
  8004a8:	1d7d                	addi	s10,s10,-1
  8004aa:	fffd4783          	lbu	a5,-1(s10)
  8004ae:	fee79de3          	bne	a5,a4,8004a8 <vprintfmt+0x2a8>
  8004b2:	b361                	j	80023a <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  8004b4:	00000617          	auipc	a2,0x0
  8004b8:	4e460613          	addi	a2,a2,1252 # 800998 <error_string+0x1a8>
  8004bc:	85a6                	mv	a1,s1
  8004be:	854a                	mv	a0,s2
  8004c0:	0ac000ef          	jal	ra,80056c <printfmt>
  8004c4:	bb9d                	j	80023a <vprintfmt+0x3a>
                p = "(null)";
  8004c6:	00000617          	auipc	a2,0x0
  8004ca:	4ca60613          	addi	a2,a2,1226 # 800990 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
  8004ce:	00000417          	auipc	s0,0x0
  8004d2:	4c340413          	addi	s0,s0,1219 # 800991 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004d6:	8532                	mv	a0,a2
  8004d8:	85e6                	mv	a1,s9
  8004da:	e032                	sd	a2,0(sp)
  8004dc:	e43e                	sd	a5,8(sp)
  8004de:	c91ff0ef          	jal	ra,80016e <strnlen>
  8004e2:	40ad8dbb          	subw	s11,s11,a0
  8004e6:	6602                	ld	a2,0(sp)
  8004e8:	01b05d63          	blez	s11,800502 <vprintfmt+0x302>
  8004ec:	67a2                	ld	a5,8(sp)
  8004ee:	2781                	sext.w	a5,a5
  8004f0:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
  8004f2:	6522                	ld	a0,8(sp)
  8004f4:	85a6                	mv	a1,s1
  8004f6:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004f8:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  8004fa:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004fc:	6602                	ld	a2,0(sp)
  8004fe:	fe0d9ae3          	bnez	s11,8004f2 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800502:	00064783          	lbu	a5,0(a2)
  800506:	0007851b          	sext.w	a0,a5
  80050a:	e8051be3          	bnez	a0,8003a0 <vprintfmt+0x1a0>
  80050e:	b335                	j	80023a <vprintfmt+0x3a>
        return va_arg(*ap, int);
  800510:	000aa403          	lw	s0,0(s5)
  800514:	bbf1                	j	8002f0 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
  800516:	000ae603          	lwu	a2,0(s5)
  80051a:	46a9                	li	a3,10
  80051c:	8aae                	mv	s5,a1
  80051e:	bd89                	j	800370 <vprintfmt+0x170>
  800520:	000ae603          	lwu	a2,0(s5)
  800524:	46c1                	li	a3,16
  800526:	8aae                	mv	s5,a1
  800528:	b5a1                	j	800370 <vprintfmt+0x170>
  80052a:	000ae603          	lwu	a2,0(s5)
  80052e:	46a1                	li	a3,8
  800530:	8aae                	mv	s5,a1
  800532:	bd3d                	j	800370 <vprintfmt+0x170>
                    putch(ch, putdat);
  800534:	9902                	jalr	s2
  800536:	b559                	j	8003bc <vprintfmt+0x1bc>
                putch('-', putdat);
  800538:	85a6                	mv	a1,s1
  80053a:	02d00513          	li	a0,45
  80053e:	e03e                	sd	a5,0(sp)
  800540:	9902                	jalr	s2
                num = -(long long)num;
  800542:	8ace                	mv	s5,s3
  800544:	40800633          	neg	a2,s0
  800548:	46a9                	li	a3,10
  80054a:	6782                	ld	a5,0(sp)
  80054c:	b515                	j	800370 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
  80054e:	01b05663          	blez	s11,80055a <vprintfmt+0x35a>
  800552:	02d00693          	li	a3,45
  800556:	f6d798e3          	bne	a5,a3,8004c6 <vprintfmt+0x2c6>
  80055a:	00000417          	auipc	s0,0x0
  80055e:	43740413          	addi	s0,s0,1079 # 800991 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800562:	02800513          	li	a0,40
  800566:	02800793          	li	a5,40
  80056a:	bd1d                	j	8003a0 <vprintfmt+0x1a0>

000000000080056c <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80056c:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  80056e:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800572:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800574:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800576:	ec06                	sd	ra,24(sp)
  800578:	f83a                	sd	a4,48(sp)
  80057a:	fc3e                	sd	a5,56(sp)
  80057c:	e0c2                	sd	a6,64(sp)
  80057e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800580:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800582:	c7fff0ef          	jal	ra,800200 <vprintfmt>
}
  800586:	60e2                	ld	ra,24(sp)
  800588:	6161                	addi	sp,sp,80
  80058a:	8082                	ret

000000000080058c <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
  80058c:	1141                	addi	sp,sp,-16
    int pid, ret;
    cprintf("I am the parent. Forking the child...\n");
  80058e:	00000517          	auipc	a0,0x0
  800592:	42250513          	addi	a0,a0,1058 # 8009b0 <error_string+0x1c0>
main(void) {
  800596:	e406                	sd	ra,8(sp)
  800598:	e022                	sd	s0,0(sp)
    cprintf("I am the parent. Forking the child...\n");
  80059a:	b95ff0ef          	jal	ra,80012e <cprintf>
    if ((pid = fork()) == 0) {
  80059e:	b41ff0ef          	jal	ra,8000de <fork>
  8005a2:	e901                	bnez	a0,8005b2 <main+0x26>
        cprintf("I am the child. spinning ...\n");
  8005a4:	00000517          	auipc	a0,0x0
  8005a8:	43450513          	addi	a0,a0,1076 # 8009d8 <error_string+0x1e8>
  8005ac:	b83ff0ef          	jal	ra,80012e <cprintf>
        while (1);
  8005b0:	a001                	j	8005b0 <main+0x24>
    }
    cprintf("I am the parent. Running the child...\n");
  8005b2:	842a                	mv	s0,a0
  8005b4:	00000517          	auipc	a0,0x0
  8005b8:	44450513          	addi	a0,a0,1092 # 8009f8 <error_string+0x208>
  8005bc:	b73ff0ef          	jal	ra,80012e <cprintf>

    yield();
  8005c0:	b27ff0ef          	jal	ra,8000e6 <yield>
    yield();
  8005c4:	b23ff0ef          	jal	ra,8000e6 <yield>
    yield();
  8005c8:	b1fff0ef          	jal	ra,8000e6 <yield>

    cprintf("I am the parent.  Killing the child...\n");
  8005cc:	00000517          	auipc	a0,0x0
  8005d0:	45450513          	addi	a0,a0,1108 # 800a20 <error_string+0x230>
  8005d4:	b5bff0ef          	jal	ra,80012e <cprintf>

    assert((ret = kill(pid)) == 0);
  8005d8:	8522                	mv	a0,s0
  8005da:	b11ff0ef          	jal	ra,8000ea <kill>
  8005de:	ed31                	bnez	a0,80063a <main+0xae>
    cprintf("kill returns %d\n", ret);
  8005e0:	4581                	li	a1,0
  8005e2:	00000517          	auipc	a0,0x0
  8005e6:	4a650513          	addi	a0,a0,1190 # 800a88 <error_string+0x298>
  8005ea:	b45ff0ef          	jal	ra,80012e <cprintf>

    assert((ret = waitpid(pid, NULL)) == 0);
  8005ee:	4581                	li	a1,0
  8005f0:	8522                	mv	a0,s0
  8005f2:	af1ff0ef          	jal	ra,8000e2 <waitpid>
  8005f6:	e11d                	bnez	a0,80061c <main+0x90>
    cprintf("wait returns %d\n", ret);
  8005f8:	4581                	li	a1,0
  8005fa:	00000517          	auipc	a0,0x0
  8005fe:	4c650513          	addi	a0,a0,1222 # 800ac0 <error_string+0x2d0>
  800602:	b2dff0ef          	jal	ra,80012e <cprintf>

    cprintf("spin may pass.\n");
  800606:	00000517          	auipc	a0,0x0
  80060a:	4d250513          	addi	a0,a0,1234 # 800ad8 <error_string+0x2e8>
  80060e:	b21ff0ef          	jal	ra,80012e <cprintf>
    return 0;
}
  800612:	60a2                	ld	ra,8(sp)
  800614:	6402                	ld	s0,0(sp)
  800616:	4501                	li	a0,0
  800618:	0141                	addi	sp,sp,16
  80061a:	8082                	ret
    assert((ret = waitpid(pid, NULL)) == 0);
  80061c:	00000697          	auipc	a3,0x0
  800620:	48468693          	addi	a3,a3,1156 # 800aa0 <error_string+0x2b0>
  800624:	00000617          	auipc	a2,0x0
  800628:	43c60613          	addi	a2,a2,1084 # 800a60 <error_string+0x270>
  80062c:	45dd                	li	a1,23
  80062e:	00000517          	auipc	a0,0x0
  800632:	44a50513          	addi	a0,a0,1098 # 800a78 <error_string+0x288>
  800636:	9ebff0ef          	jal	ra,800020 <__panic>
    assert((ret = kill(pid)) == 0);
  80063a:	00000697          	auipc	a3,0x0
  80063e:	40e68693          	addi	a3,a3,1038 # 800a48 <error_string+0x258>
  800642:	00000617          	auipc	a2,0x0
  800646:	41e60613          	addi	a2,a2,1054 # 800a60 <error_string+0x270>
  80064a:	45d1                	li	a1,20
  80064c:	00000517          	auipc	a0,0x0
  800650:	42c50513          	addi	a0,a0,1068 # 800a78 <error_string+0x288>
  800654:	9cdff0ef          	jal	ra,800020 <__panic>
