
obj/user/stresssched.debug:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 f7 00 00 00       	call   800128 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	66 90                	xchg   %ax,%ax
  800035:	66 90                	xchg   %ax,%ax
  800037:	66 90                	xchg   %ax,%ax
  800039:	66 90                	xchg   %ax,%ax
  80003b:	66 90                	xchg   %ax,%ax
  80003d:	66 90                	xchg   %ax,%ax
  80003f:	90                   	nop

00800040 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	56                   	push   %esi
  800044:	53                   	push   %ebx
  800045:	83 ec 10             	sub    $0x10,%esp
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  800048:	e8 9a 0d 00 00       	call   800de7 <sys_getenvid>
  80004d:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  80004f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800054:	e8 b7 11 00 00       	call   801210 <fork>
  800059:	85 c0                	test   %eax,%eax
  80005b:	74 0a                	je     800067 <umain+0x27>
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();

	// Fork several environments
	for (i = 0; i < 20; i++)
  80005d:	83 c3 01             	add    $0x1,%ebx
  800060:	83 fb 14             	cmp    $0x14,%ebx
  800063:	75 ef                	jne    800054 <umain+0x14>
  800065:	eb 23                	jmp    80008a <umain+0x4a>
		if (fork() == 0)
			break;
	if (i == 20) {
  800067:	83 fb 14             	cmp    $0x14,%ebx
  80006a:	74 1e                	je     80008a <umain+0x4a>
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80006c:	89 f0                	mov    %esi,%eax
  80006e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800073:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800076:	81 c2 04 00 c0 ee    	add    $0xeec00004,%edx
  80007c:	8b 52 50             	mov    0x50(%edx),%edx
  80007f:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800084:	85 d2                	test   %edx,%edx
  800086:	74 24                	je     8000ac <umain+0x6c>
  800088:	eb 0b                	jmp    800095 <umain+0x55>
	// Fork several environments
	for (i = 0; i < 20; i++)
		if (fork() == 0)
			break;
	if (i == 20) {
		sys_yield();
  80008a:	e8 91 0d 00 00       	call   800e20 <sys_yield>
		return;
  80008f:	90                   	nop
  800090:	e9 8a 00 00 00       	jmp    80011f <umain+0xdf>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  800095:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800098:	8d 90 04 00 c0 ee    	lea    -0x113ffffc(%eax),%edx
		asm volatile("pause");
  80009e:	f3 90                	pause  
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  8000a0:	8b 42 50             	mov    0x50(%edx),%eax
  8000a3:	85 c0                	test   %eax,%eax
  8000a5:	75 f7                	jne    80009e <umain+0x5e>
  8000a7:	bb 0a 00 00 00       	mov    $0xa,%ebx
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  8000ac:	e8 6f 0d 00 00       	call   800e20 <sys_yield>
  8000b1:	b8 10 27 00 00       	mov    $0x2710,%eax
		for (j = 0; j < 10000; j++)
			counter++;
  8000b6:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8000bc:	83 c2 01             	add    $0x1,%edx
  8000bf:	89 15 04 40 80 00    	mov    %edx,0x804004
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
		for (j = 0; j < 10000; j++)
  8000c5:	83 e8 01             	sub    $0x1,%eax
  8000c8:	75 ec                	jne    8000b6 <umain+0x76>
	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
  8000ca:	83 eb 01             	sub    $0x1,%ebx
  8000cd:	75 dd                	jne    8000ac <umain+0x6c>
		sys_yield();
		for (j = 0; j < 10000; j++)
			counter++;
	}

	if (counter != 10*10000)
  8000cf:	a1 04 40 80 00       	mov    0x804004,%eax
  8000d4:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000d9:	74 25                	je     800100 <umain+0xc0>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000db:	a1 04 40 80 00       	mov    0x804004,%eax
  8000e0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000e4:	c7 44 24 08 40 20 80 	movl   $0x802040,0x8(%esp)
  8000eb:	00 
  8000ec:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8000f3:	00 
  8000f4:	c7 04 24 68 20 80 00 	movl   $0x802068,(%esp)
  8000fb:	e8 94 00 00 00       	call   800194 <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  800100:	a1 08 40 80 00       	mov    0x804008,%eax
  800105:	8b 50 5c             	mov    0x5c(%eax),%edx
  800108:	8b 40 48             	mov    0x48(%eax),%eax
  80010b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80010f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800113:	c7 04 24 7b 20 80 00 	movl   $0x80207b,(%esp)
  80011a:	e8 70 01 00 00       	call   80028f <cprintf>

}
  80011f:	83 c4 10             	add    $0x10,%esp
  800122:	5b                   	pop    %ebx
  800123:	5e                   	pop    %esi
  800124:	5d                   	pop    %ebp
  800125:	c3                   	ret    
  800126:	66 90                	xchg   %ax,%ax

00800128 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	83 ec 18             	sub    $0x18,%esp
  80012e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800131:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800134:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800137:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;

	thisenv = &envs[ENVX(sys_getenvid())];
  80013a:	e8 a8 0c 00 00       	call   800de7 <sys_getenvid>
  80013f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800144:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800147:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80014c:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800151:	85 db                	test   %ebx,%ebx
  800153:	7e 07                	jle    80015c <libmain+0x34>
		binaryname = argv[0];
  800155:	8b 06                	mov    (%esi),%eax
  800157:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80015c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800160:	89 1c 24             	mov    %ebx,(%esp)
  800163:	e8 d8 fe ff ff       	call   800040 <umain>

	// exit gracefully
	exit();
  800168:	e8 0b 00 00 00       	call   800178 <exit>
}
  80016d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800170:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800173:	89 ec                	mov    %ebp,%esp
  800175:	5d                   	pop    %ebp
  800176:	c3                   	ret    
  800177:	90                   	nop

00800178 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80017e:	e8 30 14 00 00       	call   8015b3 <close_all>
	sys_env_destroy(0);
  800183:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80018a:	e8 f2 0b 00 00       	call   800d81 <sys_env_destroy>
}
  80018f:	c9                   	leave  
  800190:	c3                   	ret    
  800191:	66 90                	xchg   %ax,%ax
  800193:	90                   	nop

00800194 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	56                   	push   %esi
  800198:	53                   	push   %ebx
  800199:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80019c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80019f:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001a5:	e8 3d 0c 00 00       	call   800de7 <sys_getenvid>
  8001aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001ad:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001b8:	89 74 24 08          	mov    %esi,0x8(%esp)
  8001bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c0:	c7 04 24 a4 20 80 00 	movl   $0x8020a4,(%esp)
  8001c7:	e8 c3 00 00 00       	call   80028f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001d0:	8b 45 10             	mov    0x10(%ebp),%eax
  8001d3:	89 04 24             	mov    %eax,(%esp)
  8001d6:	e8 53 00 00 00       	call   80022e <vcprintf>
	cprintf("\n");
  8001db:	c7 04 24 97 20 80 00 	movl   $0x802097,(%esp)
  8001e2:	e8 a8 00 00 00       	call   80028f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001e7:	cc                   	int3   
  8001e8:	eb fd                	jmp    8001e7 <_panic+0x53>
  8001ea:	66 90                	xchg   %ax,%ax

008001ec <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001ec:	55                   	push   %ebp
  8001ed:	89 e5                	mov    %esp,%ebp
  8001ef:	53                   	push   %ebx
  8001f0:	83 ec 14             	sub    $0x14,%esp
  8001f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001f6:	8b 03                	mov    (%ebx),%eax
  8001f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001ff:	83 c0 01             	add    $0x1,%eax
  800202:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800204:	3d ff 00 00 00       	cmp    $0xff,%eax
  800209:	75 19                	jne    800224 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80020b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800212:	00 
  800213:	8d 43 08             	lea    0x8(%ebx),%eax
  800216:	89 04 24             	mov    %eax,(%esp)
  800219:	e8 f2 0a 00 00       	call   800d10 <sys_cputs>
		b->idx = 0;
  80021e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800224:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800228:	83 c4 14             	add    $0x14,%esp
  80022b:	5b                   	pop    %ebx
  80022c:	5d                   	pop    %ebp
  80022d:	c3                   	ret    

0080022e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80022e:	55                   	push   %ebp
  80022f:	89 e5                	mov    %esp,%ebp
  800231:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800237:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80023e:	00 00 00 
	b.cnt = 0;
  800241:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800248:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80024b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80024e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800252:	8b 45 08             	mov    0x8(%ebp),%eax
  800255:	89 44 24 08          	mov    %eax,0x8(%esp)
  800259:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80025f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800263:	c7 04 24 ec 01 80 00 	movl   $0x8001ec,(%esp)
  80026a:	e8 b3 01 00 00       	call   800422 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80026f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800275:	89 44 24 04          	mov    %eax,0x4(%esp)
  800279:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80027f:	89 04 24             	mov    %eax,(%esp)
  800282:	e8 89 0a 00 00       	call   800d10 <sys_cputs>

	return b.cnt;
}
  800287:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80028d:	c9                   	leave  
  80028e:	c3                   	ret    

0080028f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80028f:	55                   	push   %ebp
  800290:	89 e5                	mov    %esp,%ebp
  800292:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800295:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800298:	89 44 24 04          	mov    %eax,0x4(%esp)
  80029c:	8b 45 08             	mov    0x8(%ebp),%eax
  80029f:	89 04 24             	mov    %eax,(%esp)
  8002a2:	e8 87 ff ff ff       	call   80022e <vcprintf>
	va_end(ap);

	return cnt;
}
  8002a7:	c9                   	leave  
  8002a8:	c3                   	ret    
  8002a9:	66 90                	xchg   %ax,%ax
  8002ab:	66 90                	xchg   %ax,%ax
  8002ad:	66 90                	xchg   %ax,%ax
  8002af:	90                   	nop

008002b0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	57                   	push   %edi
  8002b4:	56                   	push   %esi
  8002b5:	53                   	push   %ebx
  8002b6:	83 ec 4c             	sub    $0x4c,%esp
  8002b9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8002bc:	89 d7                	mov    %edx,%edi
  8002be:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002c1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8002c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002c7:	89 5d dc             	mov    %ebx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8002cf:	39 d8                	cmp    %ebx,%eax
  8002d1:	72 17                	jb     8002ea <printnum+0x3a>
  8002d3:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8002d6:	39 5d 10             	cmp    %ebx,0x10(%ebp)
  8002d9:	76 0f                	jbe    8002ea <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002db:	8b 75 14             	mov    0x14(%ebp),%esi
  8002de:	83 ee 01             	sub    $0x1,%esi
  8002e1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8002e4:	85 f6                	test   %esi,%esi
  8002e6:	7f 63                	jg     80034b <printnum+0x9b>
  8002e8:	eb 75                	jmp    80035f <printnum+0xaf>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002ea:	8b 5d 18             	mov    0x18(%ebp),%ebx
  8002ed:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8002f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8002f4:	83 e8 01             	sub    $0x1,%eax
  8002f7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002fb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800302:	8b 44 24 08          	mov    0x8(%esp),%eax
  800306:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80030a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80030d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800310:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800317:	00 
  800318:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  80031b:	89 1c 24             	mov    %ebx,(%esp)
  80031e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800321:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800325:	e8 36 1a 00 00       	call   801d60 <__udivdi3>
  80032a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80032d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800330:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800334:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800338:	89 04 24             	mov    %eax,(%esp)
  80033b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80033f:	89 fa                	mov    %edi,%edx
  800341:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800344:	e8 67 ff ff ff       	call   8002b0 <printnum>
  800349:	eb 14                	jmp    80035f <printnum+0xaf>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80034b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80034f:	8b 45 18             	mov    0x18(%ebp),%eax
  800352:	89 04 24             	mov    %eax,(%esp)
  800355:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800357:	83 ee 01             	sub    $0x1,%esi
  80035a:	75 ef                	jne    80034b <printnum+0x9b>
  80035c:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80035f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800363:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800367:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80036a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80036e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800375:	00 
  800376:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800379:	89 1c 24             	mov    %ebx,(%esp)
  80037c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80037f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800383:	e8 28 1b 00 00       	call   801eb0 <__umoddi3>
  800388:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80038c:	0f be 80 c7 20 80 00 	movsbl 0x8020c7(%eax),%eax
  800393:	89 04 24             	mov    %eax,(%esp)
  800396:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800399:	ff d0                	call   *%eax
}
  80039b:	83 c4 4c             	add    $0x4c,%esp
  80039e:	5b                   	pop    %ebx
  80039f:	5e                   	pop    %esi
  8003a0:	5f                   	pop    %edi
  8003a1:	5d                   	pop    %ebp
  8003a2:	c3                   	ret    

008003a3 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003a3:	55                   	push   %ebp
  8003a4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003a6:	83 fa 01             	cmp    $0x1,%edx
  8003a9:	7e 0e                	jle    8003b9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003ab:	8b 10                	mov    (%eax),%edx
  8003ad:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003b0:	89 08                	mov    %ecx,(%eax)
  8003b2:	8b 02                	mov    (%edx),%eax
  8003b4:	8b 52 04             	mov    0x4(%edx),%edx
  8003b7:	eb 22                	jmp    8003db <getuint+0x38>
	else if (lflag)
  8003b9:	85 d2                	test   %edx,%edx
  8003bb:	74 10                	je     8003cd <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003bd:	8b 10                	mov    (%eax),%edx
  8003bf:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003c2:	89 08                	mov    %ecx,(%eax)
  8003c4:	8b 02                	mov    (%edx),%eax
  8003c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8003cb:	eb 0e                	jmp    8003db <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003cd:	8b 10                	mov    (%eax),%edx
  8003cf:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003d2:	89 08                	mov    %ecx,(%eax)
  8003d4:	8b 02                	mov    (%edx),%eax
  8003d6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003db:	5d                   	pop    %ebp
  8003dc:	c3                   	ret    

008003dd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003dd:	55                   	push   %ebp
  8003de:	89 e5                	mov    %esp,%ebp
  8003e0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003e3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003e7:	8b 10                	mov    (%eax),%edx
  8003e9:	3b 50 04             	cmp    0x4(%eax),%edx
  8003ec:	73 0a                	jae    8003f8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003f1:	88 0a                	mov    %cl,(%edx)
  8003f3:	83 c2 01             	add    $0x1,%edx
  8003f6:	89 10                	mov    %edx,(%eax)
}
  8003f8:	5d                   	pop    %ebp
  8003f9:	c3                   	ret    

008003fa <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003fa:	55                   	push   %ebp
  8003fb:	89 e5                	mov    %esp,%ebp
  8003fd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800400:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800403:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800407:	8b 45 10             	mov    0x10(%ebp),%eax
  80040a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80040e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800411:	89 44 24 04          	mov    %eax,0x4(%esp)
  800415:	8b 45 08             	mov    0x8(%ebp),%eax
  800418:	89 04 24             	mov    %eax,(%esp)
  80041b:	e8 02 00 00 00       	call   800422 <vprintfmt>
	va_end(ap);
}
  800420:	c9                   	leave  
  800421:	c3                   	ret    

00800422 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800422:	55                   	push   %ebp
  800423:	89 e5                	mov    %esp,%ebp
  800425:	57                   	push   %edi
  800426:	56                   	push   %esi
  800427:	53                   	push   %ebx
  800428:	83 ec 4c             	sub    $0x4c,%esp
  80042b:	8b 75 08             	mov    0x8(%ebp),%esi
  80042e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800431:	8b 7d 10             	mov    0x10(%ebp),%edi
  800434:	eb 11                	jmp    800447 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800436:	85 c0                	test   %eax,%eax
  800438:	0f 84 db 03 00 00    	je     800819 <vprintfmt+0x3f7>
				return;
			putch(ch, putdat);
  80043e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800442:	89 04 24             	mov    %eax,(%esp)
  800445:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800447:	0f b6 07             	movzbl (%edi),%eax
  80044a:	83 c7 01             	add    $0x1,%edi
  80044d:	83 f8 25             	cmp    $0x25,%eax
  800450:	75 e4                	jne    800436 <vprintfmt+0x14>
  800452:	c6 45 e4 20          	movb   $0x20,-0x1c(%ebp)
  800456:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80045d:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800464:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80046b:	ba 00 00 00 00       	mov    $0x0,%edx
  800470:	eb 2b                	jmp    80049d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800472:	8b 7d e0             	mov    -0x20(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800475:	c6 45 e4 2d          	movb   $0x2d,-0x1c(%ebp)
  800479:	eb 22                	jmp    80049d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047b:	8b 7d e0             	mov    -0x20(%ebp),%edi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80047e:	c6 45 e4 30          	movb   $0x30,-0x1c(%ebp)
  800482:	eb 19                	jmp    80049d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800484:	8b 7d e0             	mov    -0x20(%ebp),%edi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800487:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80048e:	eb 0d                	jmp    80049d <vprintfmt+0x7b>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800490:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800493:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800496:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049d:	0f b6 0f             	movzbl (%edi),%ecx
  8004a0:	8d 47 01             	lea    0x1(%edi),%eax
  8004a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a6:	0f b6 07             	movzbl (%edi),%eax
  8004a9:	83 e8 23             	sub    $0x23,%eax
  8004ac:	3c 55                	cmp    $0x55,%al
  8004ae:	0f 87 40 03 00 00    	ja     8007f4 <vprintfmt+0x3d2>
  8004b4:	0f b6 c0             	movzbl %al,%eax
  8004b7:	ff 24 85 00 22 80 00 	jmp    *0x802200(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004be:	83 e9 30             	sub    $0x30,%ecx
  8004c1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				ch = *fmt;
  8004c4:	0f be 47 01          	movsbl 0x1(%edi),%eax
				if (ch < '0' || ch > '9')
  8004c8:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8004cb:	83 f9 09             	cmp    $0x9,%ecx
  8004ce:	77 57                	ja     800527 <vprintfmt+0x105>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d0:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8004d3:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004d6:	8b 55 dc             	mov    -0x24(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004d9:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8004dc:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8004df:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8004e3:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8004e6:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8004e9:	83 f9 09             	cmp    $0x9,%ecx
  8004ec:	76 eb                	jbe    8004d9 <vprintfmt+0xb7>
  8004ee:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004f1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004f4:	eb 34                	jmp    80052a <vprintfmt+0x108>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f9:	8d 48 04             	lea    0x4(%eax),%ecx
  8004fc:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004ff:	8b 00                	mov    (%eax),%eax
  800501:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800504:	8b 7d e0             	mov    -0x20(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800507:	eb 21                	jmp    80052a <vprintfmt+0x108>

		case '.':
			if (width < 0)
  800509:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80050d:	0f 88 71 ff ff ff    	js     800484 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800513:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800516:	eb 85                	jmp    80049d <vprintfmt+0x7b>
  800518:	8b 7d e0             	mov    -0x20(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80051b:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  800522:	e9 76 ff ff ff       	jmp    80049d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800527:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80052a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80052e:	0f 89 69 ff ff ff    	jns    80049d <vprintfmt+0x7b>
  800534:	e9 57 ff ff ff       	jmp    800490 <vprintfmt+0x6e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800539:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80053f:	e9 59 ff ff ff       	jmp    80049d <vprintfmt+0x7b>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800544:	8b 45 14             	mov    0x14(%ebp),%eax
  800547:	8d 50 04             	lea    0x4(%eax),%edx
  80054a:	89 55 14             	mov    %edx,0x14(%ebp)
  80054d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800551:	8b 00                	mov    (%eax),%eax
  800553:	89 04 24             	mov    %eax,(%esp)
  800556:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800558:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80055b:	e9 e7 fe ff ff       	jmp    800447 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800560:	8b 45 14             	mov    0x14(%ebp),%eax
  800563:	8d 50 04             	lea    0x4(%eax),%edx
  800566:	89 55 14             	mov    %edx,0x14(%ebp)
  800569:	8b 00                	mov    (%eax),%eax
  80056b:	89 c2                	mov    %eax,%edx
  80056d:	c1 fa 1f             	sar    $0x1f,%edx
  800570:	31 d0                	xor    %edx,%eax
  800572:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800574:	83 f8 0f             	cmp    $0xf,%eax
  800577:	7f 0b                	jg     800584 <vprintfmt+0x162>
  800579:	8b 14 85 60 23 80 00 	mov    0x802360(,%eax,4),%edx
  800580:	85 d2                	test   %edx,%edx
  800582:	75 20                	jne    8005a4 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  800584:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800588:	c7 44 24 08 df 20 80 	movl   $0x8020df,0x8(%esp)
  80058f:	00 
  800590:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800594:	89 34 24             	mov    %esi,(%esp)
  800597:	e8 5e fe ff ff       	call   8003fa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059c:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80059f:	e9 a3 fe ff ff       	jmp    800447 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  8005a4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005a8:	c7 44 24 08 e8 20 80 	movl   $0x8020e8,0x8(%esp)
  8005af:	00 
  8005b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b4:	89 34 24             	mov    %esi,(%esp)
  8005b7:	e8 3e fe ff ff       	call   8003fa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bc:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005bf:	e9 83 fe ff ff       	jmp    800447 <vprintfmt+0x25>
  8005c4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005c7:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8005ca:	89 7d cc             	mov    %edi,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d0:	8d 50 04             	lea    0x4(%eax),%edx
  8005d3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005d8:	85 ff                	test   %edi,%edi
  8005da:	b8 d8 20 80 00       	mov    $0x8020d8,%eax
  8005df:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005e2:	80 7d e4 2d          	cmpb   $0x2d,-0x1c(%ebp)
  8005e6:	74 06                	je     8005ee <vprintfmt+0x1cc>
  8005e8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8005ec:	7f 16                	jg     800604 <vprintfmt+0x1e2>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ee:	0f b6 17             	movzbl (%edi),%edx
  8005f1:	0f be c2             	movsbl %dl,%eax
  8005f4:	83 c7 01             	add    $0x1,%edi
  8005f7:	85 c0                	test   %eax,%eax
  8005f9:	0f 85 9f 00 00 00    	jne    80069e <vprintfmt+0x27c>
  8005ff:	e9 8b 00 00 00       	jmp    80068f <vprintfmt+0x26d>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800604:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800608:	89 3c 24             	mov    %edi,(%esp)
  80060b:	e8 c2 02 00 00       	call   8008d2 <strnlen>
  800610:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800613:	29 c2                	sub    %eax,%edx
  800615:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800618:	85 d2                	test   %edx,%edx
  80061a:	7e d2                	jle    8005ee <vprintfmt+0x1cc>
					putch(padc, putdat);
  80061c:	0f be 4d e4          	movsbl -0x1c(%ebp),%ecx
  800620:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800623:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800626:	89 d7                	mov    %edx,%edi
  800628:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80062c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80062f:	89 04 24             	mov    %eax,(%esp)
  800632:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800634:	83 ef 01             	sub    $0x1,%edi
  800637:	75 ef                	jne    800628 <vprintfmt+0x206>
  800639:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80063c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80063f:	eb ad                	jmp    8005ee <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800641:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800645:	74 20                	je     800667 <vprintfmt+0x245>
  800647:	0f be d2             	movsbl %dl,%edx
  80064a:	83 ea 20             	sub    $0x20,%edx
  80064d:	83 fa 5e             	cmp    $0x5e,%edx
  800650:	76 15                	jbe    800667 <vprintfmt+0x245>
					putch('?', putdat);
  800652:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800655:	89 54 24 04          	mov    %edx,0x4(%esp)
  800659:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800660:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800663:	ff d1                	call   *%ecx
  800665:	eb 0f                	jmp    800676 <vprintfmt+0x254>
				else
					putch(ch, putdat);
  800667:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80066a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80066e:	89 04 24             	mov    %eax,(%esp)
  800671:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800674:	ff d1                	call   *%ecx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800676:	83 eb 01             	sub    $0x1,%ebx
  800679:	0f b6 17             	movzbl (%edi),%edx
  80067c:	0f be c2             	movsbl %dl,%eax
  80067f:	83 c7 01             	add    $0x1,%edi
  800682:	85 c0                	test   %eax,%eax
  800684:	75 24                	jne    8006aa <vprintfmt+0x288>
  800686:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800689:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80068c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068f:	8b 7d e0             	mov    -0x20(%ebp),%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800692:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800696:	0f 8e ab fd ff ff    	jle    800447 <vprintfmt+0x25>
  80069c:	eb 20                	jmp    8006be <vprintfmt+0x29c>
  80069e:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  8006a1:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8006a4:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8006a7:	8b 5d d8             	mov    -0x28(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006aa:	85 f6                	test   %esi,%esi
  8006ac:	78 93                	js     800641 <vprintfmt+0x21f>
  8006ae:	83 ee 01             	sub    $0x1,%esi
  8006b1:	79 8e                	jns    800641 <vprintfmt+0x21f>
  8006b3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8006b6:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8006b9:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8006bc:	eb d1                	jmp    80068f <vprintfmt+0x26d>
  8006be:	8b 7d d8             	mov    -0x28(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006c1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006cc:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006ce:	83 ef 01             	sub    $0x1,%edi
  8006d1:	75 ee                	jne    8006c1 <vprintfmt+0x29f>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d3:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8006d6:	e9 6c fd ff ff       	jmp    800447 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006db:	83 fa 01             	cmp    $0x1,%edx
  8006de:	66 90                	xchg   %ax,%ax
  8006e0:	7e 16                	jle    8006f8 <vprintfmt+0x2d6>
		return va_arg(*ap, long long);
  8006e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e5:	8d 50 08             	lea    0x8(%eax),%edx
  8006e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006eb:	8b 10                	mov    (%eax),%edx
  8006ed:	8b 48 04             	mov    0x4(%eax),%ecx
  8006f0:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8006f3:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8006f6:	eb 32                	jmp    80072a <vprintfmt+0x308>
	else if (lflag)
  8006f8:	85 d2                	test   %edx,%edx
  8006fa:	74 18                	je     800714 <vprintfmt+0x2f2>
		return va_arg(*ap, long);
  8006fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ff:	8d 50 04             	lea    0x4(%eax),%edx
  800702:	89 55 14             	mov    %edx,0x14(%ebp)
  800705:	8b 00                	mov    (%eax),%eax
  800707:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80070a:	89 c1                	mov    %eax,%ecx
  80070c:	c1 f9 1f             	sar    $0x1f,%ecx
  80070f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800712:	eb 16                	jmp    80072a <vprintfmt+0x308>
	else
		return va_arg(*ap, int);
  800714:	8b 45 14             	mov    0x14(%ebp),%eax
  800717:	8d 50 04             	lea    0x4(%eax),%edx
  80071a:	89 55 14             	mov    %edx,0x14(%ebp)
  80071d:	8b 00                	mov    (%eax),%eax
  80071f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800722:	89 c7                	mov    %eax,%edi
  800724:	c1 ff 1f             	sar    $0x1f,%edi
  800727:	89 7d d4             	mov    %edi,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80072a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80072d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800730:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800735:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800739:	79 7d                	jns    8007b8 <vprintfmt+0x396>
				putch('-', putdat);
  80073b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80073f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800746:	ff d6                	call   *%esi
				num = -(long long) num;
  800748:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80074b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80074e:	f7 d8                	neg    %eax
  800750:	83 d2 00             	adc    $0x0,%edx
  800753:	f7 da                	neg    %edx
			}
			base = 10;
  800755:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80075a:	eb 5c                	jmp    8007b8 <vprintfmt+0x396>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80075c:	8d 45 14             	lea    0x14(%ebp),%eax
  80075f:	e8 3f fc ff ff       	call   8003a3 <getuint>
			base = 10;
  800764:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800769:	eb 4d                	jmp    8007b8 <vprintfmt+0x396>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80076b:	8d 45 14             	lea    0x14(%ebp),%eax
  80076e:	e8 30 fc ff ff       	call   8003a3 <getuint>
			base = 8;
  800773:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800778:	eb 3e                	jmp    8007b8 <vprintfmt+0x396>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80077a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80077e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800785:	ff d6                	call   *%esi
			putch('x', putdat);
  800787:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80078b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800792:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800794:	8b 45 14             	mov    0x14(%ebp),%eax
  800797:	8d 50 04             	lea    0x4(%eax),%edx
  80079a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80079d:	8b 00                	mov    (%eax),%eax
  80079f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007a4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007a9:	eb 0d                	jmp    8007b8 <vprintfmt+0x396>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007ab:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ae:	e8 f0 fb ff ff       	call   8003a3 <getuint>
			base = 16;
  8007b3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007b8:	0f be 7d e4          	movsbl -0x1c(%ebp),%edi
  8007bc:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8007c0:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8007c3:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8007c7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8007cb:	89 04 24             	mov    %eax,(%esp)
  8007ce:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007d2:	89 da                	mov    %ebx,%edx
  8007d4:	89 f0                	mov    %esi,%eax
  8007d6:	e8 d5 fa ff ff       	call   8002b0 <printnum>
			break;
  8007db:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8007de:	e9 64 fc ff ff       	jmp    800447 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007e3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e7:	89 0c 24             	mov    %ecx,(%esp)
  8007ea:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ec:	8b 7d e0             	mov    -0x20(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007ef:	e9 53 fc ff ff       	jmp    800447 <vprintfmt+0x25>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007f8:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007ff:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800801:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800805:	0f 84 3c fc ff ff    	je     800447 <vprintfmt+0x25>
  80080b:	83 ef 01             	sub    $0x1,%edi
  80080e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800812:	75 f7                	jne    80080b <vprintfmt+0x3e9>
  800814:	e9 2e fc ff ff       	jmp    800447 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800819:	83 c4 4c             	add    $0x4c,%esp
  80081c:	5b                   	pop    %ebx
  80081d:	5e                   	pop    %esi
  80081e:	5f                   	pop    %edi
  80081f:	5d                   	pop    %ebp
  800820:	c3                   	ret    

00800821 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800821:	55                   	push   %ebp
  800822:	89 e5                	mov    %esp,%ebp
  800824:	83 ec 28             	sub    $0x28,%esp
  800827:	8b 45 08             	mov    0x8(%ebp),%eax
  80082a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80082d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800830:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800834:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800837:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80083e:	85 d2                	test   %edx,%edx
  800840:	7e 30                	jle    800872 <vsnprintf+0x51>
  800842:	85 c0                	test   %eax,%eax
  800844:	74 2c                	je     800872 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800846:	8b 45 14             	mov    0x14(%ebp),%eax
  800849:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80084d:	8b 45 10             	mov    0x10(%ebp),%eax
  800850:	89 44 24 08          	mov    %eax,0x8(%esp)
  800854:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800857:	89 44 24 04          	mov    %eax,0x4(%esp)
  80085b:	c7 04 24 dd 03 80 00 	movl   $0x8003dd,(%esp)
  800862:	e8 bb fb ff ff       	call   800422 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800867:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80086a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80086d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800870:	eb 05                	jmp    800877 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800872:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800877:	c9                   	leave  
  800878:	c3                   	ret    

00800879 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800879:	55                   	push   %ebp
  80087a:	89 e5                	mov    %esp,%ebp
  80087c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80087f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800882:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800886:	8b 45 10             	mov    0x10(%ebp),%eax
  800889:	89 44 24 08          	mov    %eax,0x8(%esp)
  80088d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800890:	89 44 24 04          	mov    %eax,0x4(%esp)
  800894:	8b 45 08             	mov    0x8(%ebp),%eax
  800897:	89 04 24             	mov    %eax,(%esp)
  80089a:	e8 82 ff ff ff       	call   800821 <vsnprintf>
	va_end(ap);

	return rc;
}
  80089f:	c9                   	leave  
  8008a0:	c3                   	ret    
  8008a1:	66 90                	xchg   %ax,%ax
  8008a3:	66 90                	xchg   %ax,%ax
  8008a5:	66 90                	xchg   %ax,%ax
  8008a7:	66 90                	xchg   %ax,%ax
  8008a9:	66 90                	xchg   %ax,%ax
  8008ab:	66 90                	xchg   %ax,%ax
  8008ad:	66 90                	xchg   %ax,%ax
  8008af:	90                   	nop

008008b0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008b0:	55                   	push   %ebp
  8008b1:	89 e5                	mov    %esp,%ebp
  8008b3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008b6:	80 3a 00             	cmpb   $0x0,(%edx)
  8008b9:	74 10                	je     8008cb <strlen+0x1b>
  8008bb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8008c0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008c3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008c7:	75 f7                	jne    8008c0 <strlen+0x10>
  8008c9:	eb 05                	jmp    8008d0 <strlen+0x20>
  8008cb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8008d0:	5d                   	pop    %ebp
  8008d1:	c3                   	ret    

008008d2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008d2:	55                   	push   %ebp
  8008d3:	89 e5                	mov    %esp,%ebp
  8008d5:	53                   	push   %ebx
  8008d6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008dc:	85 c9                	test   %ecx,%ecx
  8008de:	74 1c                	je     8008fc <strnlen+0x2a>
  8008e0:	80 3b 00             	cmpb   $0x0,(%ebx)
  8008e3:	74 1e                	je     800903 <strnlen+0x31>
  8008e5:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8008ea:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008ec:	39 ca                	cmp    %ecx,%edx
  8008ee:	74 18                	je     800908 <strnlen+0x36>
  8008f0:	83 c2 01             	add    $0x1,%edx
  8008f3:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8008f8:	75 f0                	jne    8008ea <strnlen+0x18>
  8008fa:	eb 0c                	jmp    800908 <strnlen+0x36>
  8008fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800901:	eb 05                	jmp    800908 <strnlen+0x36>
  800903:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800908:	5b                   	pop    %ebx
  800909:	5d                   	pop    %ebp
  80090a:	c3                   	ret    

0080090b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80090b:	55                   	push   %ebp
  80090c:	89 e5                	mov    %esp,%ebp
  80090e:	53                   	push   %ebx
  80090f:	8b 45 08             	mov    0x8(%ebp),%eax
  800912:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800915:	89 c2                	mov    %eax,%edx
  800917:	0f b6 19             	movzbl (%ecx),%ebx
  80091a:	88 1a                	mov    %bl,(%edx)
  80091c:	83 c2 01             	add    $0x1,%edx
  80091f:	83 c1 01             	add    $0x1,%ecx
  800922:	84 db                	test   %bl,%bl
  800924:	75 f1                	jne    800917 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800926:	5b                   	pop    %ebx
  800927:	5d                   	pop    %ebp
  800928:	c3                   	ret    

00800929 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800929:	55                   	push   %ebp
  80092a:	89 e5                	mov    %esp,%ebp
  80092c:	53                   	push   %ebx
  80092d:	83 ec 08             	sub    $0x8,%esp
  800930:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800933:	89 1c 24             	mov    %ebx,(%esp)
  800936:	e8 75 ff ff ff       	call   8008b0 <strlen>
	strcpy(dst + len, src);
  80093b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80093e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800942:	01 d8                	add    %ebx,%eax
  800944:	89 04 24             	mov    %eax,(%esp)
  800947:	e8 bf ff ff ff       	call   80090b <strcpy>
	return dst;
}
  80094c:	89 d8                	mov    %ebx,%eax
  80094e:	83 c4 08             	add    $0x8,%esp
  800951:	5b                   	pop    %ebx
  800952:	5d                   	pop    %ebp
  800953:	c3                   	ret    

00800954 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800954:	55                   	push   %ebp
  800955:	89 e5                	mov    %esp,%ebp
  800957:	56                   	push   %esi
  800958:	53                   	push   %ebx
  800959:	8b 75 08             	mov    0x8(%ebp),%esi
  80095c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80095f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800962:	85 db                	test   %ebx,%ebx
  800964:	74 16                	je     80097c <strncpy+0x28>
	strcpy(dst + len, src);
	return dst;
}

char *
strncpy(char *dst, const char *src, size_t size) {
  800966:	01 f3                	add    %esi,%ebx
  800968:	89 f1                	mov    %esi,%ecx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  80096a:	0f b6 02             	movzbl (%edx),%eax
  80096d:	88 01                	mov    %al,(%ecx)
  80096f:	83 c1 01             	add    $0x1,%ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800972:	80 3a 01             	cmpb   $0x1,(%edx)
  800975:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800978:	39 d9                	cmp    %ebx,%ecx
  80097a:	75 ee                	jne    80096a <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80097c:	89 f0                	mov    %esi,%eax
  80097e:	5b                   	pop    %ebx
  80097f:	5e                   	pop    %esi
  800980:	5d                   	pop    %ebp
  800981:	c3                   	ret    

00800982 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	57                   	push   %edi
  800986:	56                   	push   %esi
  800987:	53                   	push   %ebx
  800988:	8b 7d 08             	mov    0x8(%ebp),%edi
  80098b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80098e:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800991:	89 f8                	mov    %edi,%eax
  800993:	85 f6                	test   %esi,%esi
  800995:	74 33                	je     8009ca <strlcpy+0x48>
		while (--size > 0 && *src != '\0')
  800997:	83 fe 01             	cmp    $0x1,%esi
  80099a:	74 25                	je     8009c1 <strlcpy+0x3f>
  80099c:	0f b6 0b             	movzbl (%ebx),%ecx
  80099f:	84 c9                	test   %cl,%cl
  8009a1:	74 22                	je     8009c5 <strlcpy+0x43>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8009a3:	83 ee 02             	sub    $0x2,%esi
  8009a6:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009ab:	88 08                	mov    %cl,(%eax)
  8009ad:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009b0:	39 f2                	cmp    %esi,%edx
  8009b2:	74 13                	je     8009c7 <strlcpy+0x45>
  8009b4:	83 c2 01             	add    $0x1,%edx
  8009b7:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8009bb:	84 c9                	test   %cl,%cl
  8009bd:	75 ec                	jne    8009ab <strlcpy+0x29>
  8009bf:	eb 06                	jmp    8009c7 <strlcpy+0x45>
  8009c1:	89 f8                	mov    %edi,%eax
  8009c3:	eb 02                	jmp    8009c7 <strlcpy+0x45>
  8009c5:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009c7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009ca:	29 f8                	sub    %edi,%eax
}
  8009cc:	5b                   	pop    %ebx
  8009cd:	5e                   	pop    %esi
  8009ce:	5f                   	pop    %edi
  8009cf:	5d                   	pop    %ebp
  8009d0:	c3                   	ret    

008009d1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009d1:	55                   	push   %ebp
  8009d2:	89 e5                	mov    %esp,%ebp
  8009d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009d7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009da:	0f b6 01             	movzbl (%ecx),%eax
  8009dd:	84 c0                	test   %al,%al
  8009df:	74 15                	je     8009f6 <strcmp+0x25>
  8009e1:	3a 02                	cmp    (%edx),%al
  8009e3:	75 11                	jne    8009f6 <strcmp+0x25>
		p++, q++;
  8009e5:	83 c1 01             	add    $0x1,%ecx
  8009e8:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009eb:	0f b6 01             	movzbl (%ecx),%eax
  8009ee:	84 c0                	test   %al,%al
  8009f0:	74 04                	je     8009f6 <strcmp+0x25>
  8009f2:	3a 02                	cmp    (%edx),%al
  8009f4:	74 ef                	je     8009e5 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009f6:	0f b6 c0             	movzbl %al,%eax
  8009f9:	0f b6 12             	movzbl (%edx),%edx
  8009fc:	29 d0                	sub    %edx,%eax
}
  8009fe:	5d                   	pop    %ebp
  8009ff:	c3                   	ret    

00800a00 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	56                   	push   %esi
  800a04:	53                   	push   %ebx
  800a05:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a08:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a0b:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800a0e:	85 f6                	test   %esi,%esi
  800a10:	74 29                	je     800a3b <strncmp+0x3b>
  800a12:	0f b6 03             	movzbl (%ebx),%eax
  800a15:	84 c0                	test   %al,%al
  800a17:	74 30                	je     800a49 <strncmp+0x49>
  800a19:	3a 02                	cmp    (%edx),%al
  800a1b:	75 2c                	jne    800a49 <strncmp+0x49>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}

int
strncmp(const char *p, const char *q, size_t n)
  800a1d:	8d 43 01             	lea    0x1(%ebx),%eax
  800a20:	01 de                	add    %ebx,%esi
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800a22:	89 c3                	mov    %eax,%ebx
  800a24:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a27:	39 f0                	cmp    %esi,%eax
  800a29:	74 17                	je     800a42 <strncmp+0x42>
  800a2b:	0f b6 08             	movzbl (%eax),%ecx
  800a2e:	84 c9                	test   %cl,%cl
  800a30:	74 17                	je     800a49 <strncmp+0x49>
  800a32:	83 c0 01             	add    $0x1,%eax
  800a35:	3a 0a                	cmp    (%edx),%cl
  800a37:	74 e9                	je     800a22 <strncmp+0x22>
  800a39:	eb 0e                	jmp    800a49 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a3b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a40:	eb 0f                	jmp    800a51 <strncmp+0x51>
  800a42:	b8 00 00 00 00       	mov    $0x0,%eax
  800a47:	eb 08                	jmp    800a51 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a49:	0f b6 03             	movzbl (%ebx),%eax
  800a4c:	0f b6 12             	movzbl (%edx),%edx
  800a4f:	29 d0                	sub    %edx,%eax
}
  800a51:	5b                   	pop    %ebx
  800a52:	5e                   	pop    %esi
  800a53:	5d                   	pop    %ebp
  800a54:	c3                   	ret    

00800a55 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a55:	55                   	push   %ebp
  800a56:	89 e5                	mov    %esp,%ebp
  800a58:	53                   	push   %ebx
  800a59:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5c:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800a5f:	0f b6 18             	movzbl (%eax),%ebx
  800a62:	84 db                	test   %bl,%bl
  800a64:	74 1d                	je     800a83 <strchr+0x2e>
  800a66:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800a68:	38 d3                	cmp    %dl,%bl
  800a6a:	75 06                	jne    800a72 <strchr+0x1d>
  800a6c:	eb 1a                	jmp    800a88 <strchr+0x33>
  800a6e:	38 ca                	cmp    %cl,%dl
  800a70:	74 16                	je     800a88 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a72:	83 c0 01             	add    $0x1,%eax
  800a75:	0f b6 10             	movzbl (%eax),%edx
  800a78:	84 d2                	test   %dl,%dl
  800a7a:	75 f2                	jne    800a6e <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800a7c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a81:	eb 05                	jmp    800a88 <strchr+0x33>
  800a83:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a88:	5b                   	pop    %ebx
  800a89:	5d                   	pop    %ebp
  800a8a:	c3                   	ret    

00800a8b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	53                   	push   %ebx
  800a8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a92:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800a95:	0f b6 18             	movzbl (%eax),%ebx
  800a98:	84 db                	test   %bl,%bl
  800a9a:	74 16                	je     800ab2 <strfind+0x27>
  800a9c:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800a9e:	38 d3                	cmp    %dl,%bl
  800aa0:	75 06                	jne    800aa8 <strfind+0x1d>
  800aa2:	eb 0e                	jmp    800ab2 <strfind+0x27>
  800aa4:	38 ca                	cmp    %cl,%dl
  800aa6:	74 0a                	je     800ab2 <strfind+0x27>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800aa8:	83 c0 01             	add    $0x1,%eax
  800aab:	0f b6 10             	movzbl (%eax),%edx
  800aae:	84 d2                	test   %dl,%dl
  800ab0:	75 f2                	jne    800aa4 <strfind+0x19>
		if (*s == c)
			break;
	return (char *) s;
}
  800ab2:	5b                   	pop    %ebx
  800ab3:	5d                   	pop    %ebp
  800ab4:	c3                   	ret    

00800ab5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ab5:	55                   	push   %ebp
  800ab6:	89 e5                	mov    %esp,%ebp
  800ab8:	83 ec 0c             	sub    $0xc,%esp
  800abb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800abe:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ac1:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800ac4:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ac7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800aca:	85 c9                	test   %ecx,%ecx
  800acc:	74 36                	je     800b04 <memset+0x4f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ace:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ad4:	75 28                	jne    800afe <memset+0x49>
  800ad6:	f6 c1 03             	test   $0x3,%cl
  800ad9:	75 23                	jne    800afe <memset+0x49>
		c &= 0xFF;
  800adb:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800adf:	89 d3                	mov    %edx,%ebx
  800ae1:	c1 e3 08             	shl    $0x8,%ebx
  800ae4:	89 d6                	mov    %edx,%esi
  800ae6:	c1 e6 18             	shl    $0x18,%esi
  800ae9:	89 d0                	mov    %edx,%eax
  800aeb:	c1 e0 10             	shl    $0x10,%eax
  800aee:	09 f0                	or     %esi,%eax
  800af0:	09 c2                	or     %eax,%edx
  800af2:	89 d0                	mov    %edx,%eax
  800af4:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800af6:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800af9:	fc                   	cld    
  800afa:	f3 ab                	rep stos %eax,%es:(%edi)
  800afc:	eb 06                	jmp    800b04 <memset+0x4f>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800afe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b01:	fc                   	cld    
  800b02:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");

	return v;
}
  800b04:	89 f8                	mov    %edi,%eax
  800b06:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800b09:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b0c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b0f:	89 ec                	mov    %ebp,%esp
  800b11:	5d                   	pop    %ebp
  800b12:	c3                   	ret    

00800b13 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b13:	55                   	push   %ebp
  800b14:	89 e5                	mov    %esp,%ebp
  800b16:	83 ec 08             	sub    $0x8,%esp
  800b19:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b1c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800b1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b22:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b25:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b28:	39 c6                	cmp    %eax,%esi
  800b2a:	73 36                	jae    800b62 <memmove+0x4f>
  800b2c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b2f:	39 d0                	cmp    %edx,%eax
  800b31:	73 2f                	jae    800b62 <memmove+0x4f>
		s += n;
		d += n;
  800b33:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b36:	f6 c2 03             	test   $0x3,%dl
  800b39:	75 1b                	jne    800b56 <memmove+0x43>
  800b3b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b41:	75 13                	jne    800b56 <memmove+0x43>
  800b43:	f6 c1 03             	test   $0x3,%cl
  800b46:	75 0e                	jne    800b56 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b48:	83 ef 04             	sub    $0x4,%edi
  800b4b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b4e:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b51:	fd                   	std    
  800b52:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b54:	eb 09                	jmp    800b5f <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b56:	83 ef 01             	sub    $0x1,%edi
  800b59:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b5c:	fd                   	std    
  800b5d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b5f:	fc                   	cld    
  800b60:	eb 20                	jmp    800b82 <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b62:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b68:	75 13                	jne    800b7d <memmove+0x6a>
  800b6a:	a8 03                	test   $0x3,%al
  800b6c:	75 0f                	jne    800b7d <memmove+0x6a>
  800b6e:	f6 c1 03             	test   $0x3,%cl
  800b71:	75 0a                	jne    800b7d <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b73:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b76:	89 c7                	mov    %eax,%edi
  800b78:	fc                   	cld    
  800b79:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b7b:	eb 05                	jmp    800b82 <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b7d:	89 c7                	mov    %eax,%edi
  800b7f:	fc                   	cld    
  800b80:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b82:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b85:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b88:	89 ec                	mov    %ebp,%esp
  800b8a:	5d                   	pop    %ebp
  800b8b:	c3                   	ret    

00800b8c <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800b8c:	55                   	push   %ebp
  800b8d:	89 e5                	mov    %esp,%ebp
  800b8f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b92:	8b 45 10             	mov    0x10(%ebp),%eax
  800b95:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b99:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b9c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ba0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba3:	89 04 24             	mov    %eax,(%esp)
  800ba6:	e8 68 ff ff ff       	call   800b13 <memmove>
}
  800bab:	c9                   	leave  
  800bac:	c3                   	ret    

00800bad <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bad:	55                   	push   %ebp
  800bae:	89 e5                	mov    %esp,%ebp
  800bb0:	57                   	push   %edi
  800bb1:	56                   	push   %esi
  800bb2:	53                   	push   %ebx
  800bb3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800bb6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bb9:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bbc:	8d 78 ff             	lea    -0x1(%eax),%edi
  800bbf:	85 c0                	test   %eax,%eax
  800bc1:	74 36                	je     800bf9 <memcmp+0x4c>
		if (*s1 != *s2)
  800bc3:	0f b6 03             	movzbl (%ebx),%eax
  800bc6:	0f b6 0e             	movzbl (%esi),%ecx
  800bc9:	38 c8                	cmp    %cl,%al
  800bcb:	75 17                	jne    800be4 <memcmp+0x37>
  800bcd:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd2:	eb 1a                	jmp    800bee <memcmp+0x41>
  800bd4:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800bd9:	83 c2 01             	add    $0x1,%edx
  800bdc:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800be0:	38 c8                	cmp    %cl,%al
  800be2:	74 0a                	je     800bee <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800be4:	0f b6 c0             	movzbl %al,%eax
  800be7:	0f b6 c9             	movzbl %cl,%ecx
  800bea:	29 c8                	sub    %ecx,%eax
  800bec:	eb 10                	jmp    800bfe <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bee:	39 fa                	cmp    %edi,%edx
  800bf0:	75 e2                	jne    800bd4 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bf2:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf7:	eb 05                	jmp    800bfe <memcmp+0x51>
  800bf9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bfe:	5b                   	pop    %ebx
  800bff:	5e                   	pop    %esi
  800c00:	5f                   	pop    %edi
  800c01:	5d                   	pop    %ebp
  800c02:	c3                   	ret    

00800c03 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c03:	55                   	push   %ebp
  800c04:	89 e5                	mov    %esp,%ebp
  800c06:	53                   	push   %ebx
  800c07:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800c0d:	89 c2                	mov    %eax,%edx
  800c0f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c12:	39 d0                	cmp    %edx,%eax
  800c14:	73 13                	jae    800c29 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c16:	89 d9                	mov    %ebx,%ecx
  800c18:	38 18                	cmp    %bl,(%eax)
  800c1a:	75 06                	jne    800c22 <memfind+0x1f>
  800c1c:	eb 0b                	jmp    800c29 <memfind+0x26>
  800c1e:	38 08                	cmp    %cl,(%eax)
  800c20:	74 07                	je     800c29 <memfind+0x26>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c22:	83 c0 01             	add    $0x1,%eax
  800c25:	39 d0                	cmp    %edx,%eax
  800c27:	75 f5                	jne    800c1e <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c29:	5b                   	pop    %ebx
  800c2a:	5d                   	pop    %ebp
  800c2b:	c3                   	ret    

00800c2c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c2c:	55                   	push   %ebp
  800c2d:	89 e5                	mov    %esp,%ebp
  800c2f:	57                   	push   %edi
  800c30:	56                   	push   %esi
  800c31:	53                   	push   %ebx
  800c32:	83 ec 04             	sub    $0x4,%esp
  800c35:	8b 55 08             	mov    0x8(%ebp),%edx
  800c38:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c3b:	0f b6 02             	movzbl (%edx),%eax
  800c3e:	3c 09                	cmp    $0x9,%al
  800c40:	74 04                	je     800c46 <strtol+0x1a>
  800c42:	3c 20                	cmp    $0x20,%al
  800c44:	75 0e                	jne    800c54 <strtol+0x28>
		s++;
  800c46:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c49:	0f b6 02             	movzbl (%edx),%eax
  800c4c:	3c 09                	cmp    $0x9,%al
  800c4e:	74 f6                	je     800c46 <strtol+0x1a>
  800c50:	3c 20                	cmp    $0x20,%al
  800c52:	74 f2                	je     800c46 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c54:	3c 2b                	cmp    $0x2b,%al
  800c56:	75 0a                	jne    800c62 <strtol+0x36>
		s++;
  800c58:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c5b:	bf 00 00 00 00       	mov    $0x0,%edi
  800c60:	eb 10                	jmp    800c72 <strtol+0x46>
  800c62:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c67:	3c 2d                	cmp    $0x2d,%al
  800c69:	75 07                	jne    800c72 <strtol+0x46>
		s++, neg = 1;
  800c6b:	83 c2 01             	add    $0x1,%edx
  800c6e:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c72:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c78:	75 15                	jne    800c8f <strtol+0x63>
  800c7a:	80 3a 30             	cmpb   $0x30,(%edx)
  800c7d:	75 10                	jne    800c8f <strtol+0x63>
  800c7f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c83:	75 0a                	jne    800c8f <strtol+0x63>
		s += 2, base = 16;
  800c85:	83 c2 02             	add    $0x2,%edx
  800c88:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c8d:	eb 10                	jmp    800c9f <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800c8f:	85 db                	test   %ebx,%ebx
  800c91:	75 0c                	jne    800c9f <strtol+0x73>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c93:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c95:	80 3a 30             	cmpb   $0x30,(%edx)
  800c98:	75 05                	jne    800c9f <strtol+0x73>
		s++, base = 8;
  800c9a:	83 c2 01             	add    $0x1,%edx
  800c9d:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800c9f:	b8 00 00 00 00       	mov    $0x0,%eax
  800ca4:	89 5d f0             	mov    %ebx,-0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ca7:	0f b6 0a             	movzbl (%edx),%ecx
  800caa:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800cad:	89 f3                	mov    %esi,%ebx
  800caf:	80 fb 09             	cmp    $0x9,%bl
  800cb2:	77 08                	ja     800cbc <strtol+0x90>
			dig = *s - '0';
  800cb4:	0f be c9             	movsbl %cl,%ecx
  800cb7:	83 e9 30             	sub    $0x30,%ecx
  800cba:	eb 22                	jmp    800cde <strtol+0xb2>
		else if (*s >= 'a' && *s <= 'z')
  800cbc:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800cbf:	89 f3                	mov    %esi,%ebx
  800cc1:	80 fb 19             	cmp    $0x19,%bl
  800cc4:	77 08                	ja     800cce <strtol+0xa2>
			dig = *s - 'a' + 10;
  800cc6:	0f be c9             	movsbl %cl,%ecx
  800cc9:	83 e9 57             	sub    $0x57,%ecx
  800ccc:	eb 10                	jmp    800cde <strtol+0xb2>
		else if (*s >= 'A' && *s <= 'Z')
  800cce:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800cd1:	89 f3                	mov    %esi,%ebx
  800cd3:	80 fb 19             	cmp    $0x19,%bl
  800cd6:	77 16                	ja     800cee <strtol+0xc2>
			dig = *s - 'A' + 10;
  800cd8:	0f be c9             	movsbl %cl,%ecx
  800cdb:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800cde:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800ce1:	7d 0f                	jge    800cf2 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800ce3:	83 c2 01             	add    $0x1,%edx
  800ce6:	0f af 45 f0          	imul   -0x10(%ebp),%eax
  800cea:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800cec:	eb b9                	jmp    800ca7 <strtol+0x7b>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800cee:	89 c1                	mov    %eax,%ecx
  800cf0:	eb 02                	jmp    800cf4 <strtol+0xc8>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800cf2:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800cf4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cf8:	74 05                	je     800cff <strtol+0xd3>
		*endptr = (char *) s;
  800cfa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800cfd:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800cff:	89 ca                	mov    %ecx,%edx
  800d01:	f7 da                	neg    %edx
  800d03:	85 ff                	test   %edi,%edi
  800d05:	0f 45 c2             	cmovne %edx,%eax
}
  800d08:	83 c4 04             	add    $0x4,%esp
  800d0b:	5b                   	pop    %ebx
  800d0c:	5e                   	pop    %esi
  800d0d:	5f                   	pop    %edi
  800d0e:	5d                   	pop    %ebp
  800d0f:	c3                   	ret    

00800d10 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d10:	55                   	push   %ebp
  800d11:	89 e5                	mov    %esp,%ebp
  800d13:	83 ec 0c             	sub    $0xc,%esp
  800d16:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d19:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d1c:	89 7d fc             	mov    %edi,-0x4(%ebp)
static inline uint32_t

get_cpu_features(void)
{
	uint32_t feature;
	__asm __volatile(" movl $1, %%eax\n\t"
  800d1f:	b8 01 00 00 00       	mov    $0x1,%eax
  800d24:	0f a2                	cpuid  
  800d26:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d28:	b8 00 00 00 00       	mov    $0x0,%eax
  800d2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d30:	8b 55 08             	mov    0x8(%ebp),%edx
  800d33:	89 c3                	mov    %eax,%ebx
  800d35:	89 c7                	mov    %eax,%edi
  800d37:	89 c6                	mov    %eax,%esi
  800d39:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d3b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d3e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d41:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d44:	89 ec                	mov    %ebp,%esp
  800d46:	5d                   	pop    %ebp
  800d47:	c3                   	ret    

00800d48 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d48:	55                   	push   %ebp
  800d49:	89 e5                	mov    %esp,%ebp
  800d4b:	83 ec 0c             	sub    $0xc,%esp
  800d4e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d51:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d54:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d57:	b8 01 00 00 00       	mov    $0x1,%eax
  800d5c:	0f a2                	cpuid  
  800d5e:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d60:	ba 00 00 00 00       	mov    $0x0,%edx
  800d65:	b8 01 00 00 00       	mov    $0x1,%eax
  800d6a:	89 d1                	mov    %edx,%ecx
  800d6c:	89 d3                	mov    %edx,%ebx
  800d6e:	89 d7                	mov    %edx,%edi
  800d70:	89 d6                	mov    %edx,%esi
  800d72:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d74:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d77:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d7a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d7d:	89 ec                	mov    %ebp,%esp
  800d7f:	5d                   	pop    %ebp
  800d80:	c3                   	ret    

00800d81 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d81:	55                   	push   %ebp
  800d82:	89 e5                	mov    %esp,%ebp
  800d84:	83 ec 38             	sub    $0x38,%esp
  800d87:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d8a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d8d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d90:	b8 01 00 00 00       	mov    $0x1,%eax
  800d95:	0f a2                	cpuid  
  800d97:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d99:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d9e:	b8 03 00 00 00       	mov    $0x3,%eax
  800da3:	8b 55 08             	mov    0x8(%ebp),%edx
  800da6:	89 cb                	mov    %ecx,%ebx
  800da8:	89 cf                	mov    %ecx,%edi
  800daa:	89 ce                	mov    %ecx,%esi
  800dac:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dae:	85 c0                	test   %eax,%eax
  800db0:	7e 28                	jle    800dda <sys_env_destroy+0x59>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800db6:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800dbd:	00 
  800dbe:	c7 44 24 08 bf 23 80 	movl   $0x8023bf,0x8(%esp)
  800dc5:	00 
  800dc6:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800dcd:	00 
  800dce:	c7 04 24 dc 23 80 00 	movl   $0x8023dc,(%esp)
  800dd5:	e8 ba f3 ff ff       	call   800194 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800dda:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ddd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800de0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800de3:	89 ec                	mov    %ebp,%esp
  800de5:	5d                   	pop    %ebp
  800de6:	c3                   	ret    

00800de7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800de7:	55                   	push   %ebp
  800de8:	89 e5                	mov    %esp,%ebp
  800dea:	83 ec 0c             	sub    $0xc,%esp
  800ded:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800df0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800df3:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800df6:	b8 01 00 00 00       	mov    $0x1,%eax
  800dfb:	0f a2                	cpuid  
  800dfd:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dff:	ba 00 00 00 00       	mov    $0x0,%edx
  800e04:	b8 02 00 00 00       	mov    $0x2,%eax
  800e09:	89 d1                	mov    %edx,%ecx
  800e0b:	89 d3                	mov    %edx,%ebx
  800e0d:	89 d7                	mov    %edx,%edi
  800e0f:	89 d6                	mov    %edx,%esi
  800e11:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e13:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e16:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e19:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e1c:	89 ec                	mov    %ebp,%esp
  800e1e:	5d                   	pop    %ebp
  800e1f:	c3                   	ret    

00800e20 <sys_yield>:

void
sys_yield(void)
{
  800e20:	55                   	push   %ebp
  800e21:	89 e5                	mov    %esp,%ebp
  800e23:	83 ec 0c             	sub    $0xc,%esp
  800e26:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e29:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e2c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e2f:	b8 01 00 00 00       	mov    $0x1,%eax
  800e34:	0f a2                	cpuid  
  800e36:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e38:	ba 00 00 00 00       	mov    $0x0,%edx
  800e3d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e42:	89 d1                	mov    %edx,%ecx
  800e44:	89 d3                	mov    %edx,%ebx
  800e46:	89 d7                	mov    %edx,%edi
  800e48:	89 d6                	mov    %edx,%esi
  800e4a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e4c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e4f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e52:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e55:	89 ec                	mov    %ebp,%esp
  800e57:	5d                   	pop    %ebp
  800e58:	c3                   	ret    

00800e59 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e59:	55                   	push   %ebp
  800e5a:	89 e5                	mov    %esp,%ebp
  800e5c:	83 ec 38             	sub    $0x38,%esp
  800e5f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e62:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e65:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e68:	b8 01 00 00 00       	mov    $0x1,%eax
  800e6d:	0f a2                	cpuid  
  800e6f:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e71:	be 00 00 00 00       	mov    $0x0,%esi
  800e76:	b8 04 00 00 00       	mov    $0x4,%eax
  800e7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e81:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e84:	89 f7                	mov    %esi,%edi
  800e86:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e88:	85 c0                	test   %eax,%eax
  800e8a:	7e 28                	jle    800eb4 <sys_page_alloc+0x5b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e8c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e90:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800e97:	00 
  800e98:	c7 44 24 08 bf 23 80 	movl   $0x8023bf,0x8(%esp)
  800e9f:	00 
  800ea0:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800ea7:	00 
  800ea8:	c7 04 24 dc 23 80 00 	movl   $0x8023dc,(%esp)
  800eaf:	e8 e0 f2 ff ff       	call   800194 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800eb4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800eb7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800eba:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ebd:	89 ec                	mov    %ebp,%esp
  800ebf:	5d                   	pop    %ebp
  800ec0:	c3                   	ret    

00800ec1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ec1:	55                   	push   %ebp
  800ec2:	89 e5                	mov    %esp,%ebp
  800ec4:	83 ec 38             	sub    $0x38,%esp
  800ec7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800eca:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ecd:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800ed0:	b8 01 00 00 00       	mov    $0x1,%eax
  800ed5:	0f a2                	cpuid  
  800ed7:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed9:	b8 05 00 00 00       	mov    $0x5,%eax
  800ede:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ee7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800eea:	8b 75 18             	mov    0x18(%ebp),%esi
  800eed:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eef:	85 c0                	test   %eax,%eax
  800ef1:	7e 28                	jle    800f1b <sys_page_map+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ef3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ef7:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800efe:	00 
  800eff:	c7 44 24 08 bf 23 80 	movl   $0x8023bf,0x8(%esp)
  800f06:	00 
  800f07:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800f0e:	00 
  800f0f:	c7 04 24 dc 23 80 00 	movl   $0x8023dc,(%esp)
  800f16:	e8 79 f2 ff ff       	call   800194 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f1b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f1e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f21:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f24:	89 ec                	mov    %ebp,%esp
  800f26:	5d                   	pop    %ebp
  800f27:	c3                   	ret    

00800f28 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f28:	55                   	push   %ebp
  800f29:	89 e5                	mov    %esp,%ebp
  800f2b:	83 ec 38             	sub    $0x38,%esp
  800f2e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f31:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f34:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800f37:	b8 01 00 00 00       	mov    $0x1,%eax
  800f3c:	0f a2                	cpuid  
  800f3e:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f40:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f45:	b8 06 00 00 00       	mov    $0x6,%eax
  800f4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f50:	89 df                	mov    %ebx,%edi
  800f52:	89 de                	mov    %ebx,%esi
  800f54:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f56:	85 c0                	test   %eax,%eax
  800f58:	7e 28                	jle    800f82 <sys_page_unmap+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f5a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f5e:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f65:	00 
  800f66:	c7 44 24 08 bf 23 80 	movl   $0x8023bf,0x8(%esp)
  800f6d:	00 
  800f6e:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800f75:	00 
  800f76:	c7 04 24 dc 23 80 00 	movl   $0x8023dc,(%esp)
  800f7d:	e8 12 f2 ff ff       	call   800194 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f82:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f85:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f88:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f8b:	89 ec                	mov    %ebp,%esp
  800f8d:	5d                   	pop    %ebp
  800f8e:	c3                   	ret    

00800f8f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f8f:	55                   	push   %ebp
  800f90:	89 e5                	mov    %esp,%ebp
  800f92:	83 ec 38             	sub    $0x38,%esp
  800f95:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f98:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f9b:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800f9e:	b8 01 00 00 00       	mov    $0x1,%eax
  800fa3:	0f a2                	cpuid  
  800fa5:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fa7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fac:	b8 08 00 00 00       	mov    $0x8,%eax
  800fb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb7:	89 df                	mov    %ebx,%edi
  800fb9:	89 de                	mov    %ebx,%esi
  800fbb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fbd:	85 c0                	test   %eax,%eax
  800fbf:	7e 28                	jle    800fe9 <sys_env_set_status+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fc1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fc5:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800fcc:	00 
  800fcd:	c7 44 24 08 bf 23 80 	movl   $0x8023bf,0x8(%esp)
  800fd4:	00 
  800fd5:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800fdc:	00 
  800fdd:	c7 04 24 dc 23 80 00 	movl   $0x8023dc,(%esp)
  800fe4:	e8 ab f1 ff ff       	call   800194 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800fe9:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fec:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fef:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ff2:	89 ec                	mov    %ebp,%esp
  800ff4:	5d                   	pop    %ebp
  800ff5:	c3                   	ret    

00800ff6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ff6:	55                   	push   %ebp
  800ff7:	89 e5                	mov    %esp,%ebp
  800ff9:	83 ec 38             	sub    $0x38,%esp
  800ffc:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fff:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801002:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801005:	b8 01 00 00 00       	mov    $0x1,%eax
  80100a:	0f a2                	cpuid  
  80100c:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80100e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801013:	b8 09 00 00 00       	mov    $0x9,%eax
  801018:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80101b:	8b 55 08             	mov    0x8(%ebp),%edx
  80101e:	89 df                	mov    %ebx,%edi
  801020:	89 de                	mov    %ebx,%esi
  801022:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801024:	85 c0                	test   %eax,%eax
  801026:	7e 28                	jle    801050 <sys_env_set_trapframe+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801028:	89 44 24 10          	mov    %eax,0x10(%esp)
  80102c:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801033:	00 
  801034:	c7 44 24 08 bf 23 80 	movl   $0x8023bf,0x8(%esp)
  80103b:	00 
  80103c:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  801043:	00 
  801044:	c7 04 24 dc 23 80 00 	movl   $0x8023dc,(%esp)
  80104b:	e8 44 f1 ff ff       	call   800194 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801050:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801053:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801056:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801059:	89 ec                	mov    %ebp,%esp
  80105b:	5d                   	pop    %ebp
  80105c:	c3                   	ret    

0080105d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80105d:	55                   	push   %ebp
  80105e:	89 e5                	mov    %esp,%ebp
  801060:	83 ec 38             	sub    $0x38,%esp
  801063:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801066:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801069:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80106c:	b8 01 00 00 00       	mov    $0x1,%eax
  801071:	0f a2                	cpuid  
  801073:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801075:	bb 00 00 00 00       	mov    $0x0,%ebx
  80107a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80107f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801082:	8b 55 08             	mov    0x8(%ebp),%edx
  801085:	89 df                	mov    %ebx,%edi
  801087:	89 de                	mov    %ebx,%esi
  801089:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80108b:	85 c0                	test   %eax,%eax
  80108d:	7e 28                	jle    8010b7 <sys_env_set_pgfault_upcall+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80108f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801093:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80109a:	00 
  80109b:	c7 44 24 08 bf 23 80 	movl   $0x8023bf,0x8(%esp)
  8010a2:	00 
  8010a3:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  8010aa:	00 
  8010ab:	c7 04 24 dc 23 80 00 	movl   $0x8023dc,(%esp)
  8010b2:	e8 dd f0 ff ff       	call   800194 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010b7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010ba:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010bd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010c0:	89 ec                	mov    %ebp,%esp
  8010c2:	5d                   	pop    %ebp
  8010c3:	c3                   	ret    

008010c4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010c4:	55                   	push   %ebp
  8010c5:	89 e5                	mov    %esp,%ebp
  8010c7:	83 ec 0c             	sub    $0xc,%esp
  8010ca:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010cd:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010d0:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8010d3:	b8 01 00 00 00       	mov    $0x1,%eax
  8010d8:	0f a2                	cpuid  
  8010da:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010dc:	be 00 00 00 00       	mov    $0x0,%esi
  8010e1:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ec:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010ef:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010f2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010f4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010f7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010fa:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010fd:	89 ec                	mov    %ebp,%esp
  8010ff:	5d                   	pop    %ebp
  801100:	c3                   	ret    

00801101 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801101:	55                   	push   %ebp
  801102:	89 e5                	mov    %esp,%ebp
  801104:	83 ec 38             	sub    $0x38,%esp
  801107:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80110a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80110d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801110:	b8 01 00 00 00       	mov    $0x1,%eax
  801115:	0f a2                	cpuid  
  801117:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801119:	b9 00 00 00 00       	mov    $0x0,%ecx
  80111e:	b8 0d 00 00 00       	mov    $0xd,%eax
  801123:	8b 55 08             	mov    0x8(%ebp),%edx
  801126:	89 cb                	mov    %ecx,%ebx
  801128:	89 cf                	mov    %ecx,%edi
  80112a:	89 ce                	mov    %ecx,%esi
  80112c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80112e:	85 c0                	test   %eax,%eax
  801130:	7e 28                	jle    80115a <sys_ipc_recv+0x59>
		panic("syscall %d returned %d (> 0)", num, ret);
  801132:	89 44 24 10          	mov    %eax,0x10(%esp)
  801136:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  80113d:	00 
  80113e:	c7 44 24 08 bf 23 80 	movl   $0x8023bf,0x8(%esp)
  801145:	00 
  801146:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  80114d:	00 
  80114e:	c7 04 24 dc 23 80 00 	movl   $0x8023dc,(%esp)
  801155:	e8 3a f0 ff ff       	call   800194 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80115a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80115d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801160:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801163:	89 ec                	mov    %ebp,%esp
  801165:	5d                   	pop    %ebp
  801166:	c3                   	ret    
  801167:	90                   	nop

00801168 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801168:	55                   	push   %ebp
  801169:	89 e5                	mov    %esp,%ebp
  80116b:	56                   	push   %esi
  80116c:	53                   	push   %ebx
  80116d:	83 ec 20             	sub    $0x20,%esp
  801170:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801173:	8b 30                	mov    (%eax),%esi
	// Hint:
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	pde_t pde = vpt[PGNUM(addr)];
  801175:	89 f2                	mov    %esi,%edx
  801177:	c1 ea 0c             	shr    $0xc,%edx
  80117a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx

	if(!((err & FEC_WR) && (pde &PTE_COW) ))
  801181:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801185:	74 05                	je     80118c <pgfault+0x24>
  801187:	f6 c6 08             	test   $0x8,%dh
  80118a:	75 20                	jne    8011ac <pgfault+0x44>
		panic("Unrecoverable page fault at address[0x%x]!\n", addr);
  80118c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801190:	c7 44 24 08 ec 23 80 	movl   $0x8023ec,0x8(%esp)
  801197:	00 
  801198:	c7 44 24 04 1f 00 00 	movl   $0x1f,0x4(%esp)
  80119f:	00 
  8011a0:	c7 04 24 39 24 80 00 	movl   $0x802439,(%esp)
  8011a7:	e8 e8 ef ff ff       	call   800194 <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	envid_t thisenv_id = sys_getenvid();
  8011ac:	e8 36 fc ff ff       	call   800de7 <sys_getenvid>
  8011b1:	89 c3                	mov    %eax,%ebx
	sys_page_alloc(thisenv_id, PFTEMP, PTE_P|PTE_W|PTE_U);
  8011b3:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8011ba:	00 
  8011bb:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8011c2:	00 
  8011c3:	89 04 24             	mov    %eax,(%esp)
  8011c6:	e8 8e fc ff ff       	call   800e59 <sys_page_alloc>
	memmove((void*)PFTEMP, (void*)ROUNDDOWN(addr, PGSIZE), PGSIZE);
  8011cb:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  8011d1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8011d8:	00 
  8011d9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011dd:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8011e4:	e8 2a f9 ff ff       	call   800b13 <memmove>
	sys_page_map(thisenv_id, (void*)PFTEMP, thisenv_id,(void*)ROUNDDOWN(addr, PGSIZE), 
  8011e9:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8011f0:	00 
  8011f1:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8011f5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8011f9:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801200:	00 
  801201:	89 1c 24             	mov    %ebx,(%esp)
  801204:	e8 b8 fc ff ff       	call   800ec1 <sys_page_map>
		PTE_U|PTE_W|PTE_P);
	//panic("pgfault not implemented");
}
  801209:	83 c4 20             	add    $0x20,%esp
  80120c:	5b                   	pop    %ebx
  80120d:	5e                   	pop    %esi
  80120e:	5d                   	pop    %ebp
  80120f:	c3                   	ret    

00801210 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801210:	55                   	push   %ebp
  801211:	89 e5                	mov    %esp,%ebp
  801213:	57                   	push   %edi
  801214:	56                   	push   %esi
  801215:	53                   	push   %ebx
  801216:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	envid_t child_id;
	uint32_t pg_cow_ptr;
	int r;

	set_pgfault_handler(pgfault);
  801219:	c7 04 24 68 11 80 00 	movl   $0x801168,(%esp)
  801220:	e8 8b 09 00 00       	call   801bb0 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801225:	ba 07 00 00 00       	mov    $0x7,%edx
  80122a:	89 d0                	mov    %edx,%eax
  80122c:	cd 30                	int    $0x30
  80122e:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801231:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if((child_id = sys_exofork()) < 0)
  801234:	85 c0                	test   %eax,%eax
  801236:	79 1c                	jns    801254 <fork+0x44>
		panic("Fork error\n");
  801238:	c7 44 24 08 44 24 80 	movl   $0x802444,0x8(%esp)
  80123f:	00 
  801240:	c7 44 24 04 6e 00 00 	movl   $0x6e,0x4(%esp)
  801247:	00 
  801248:	c7 04 24 39 24 80 00 	movl   $0x802439,(%esp)
  80124f:	e8 40 ef ff ff       	call   800194 <_panic>
	if(child_id == 0){
  801254:	bb 00 00 80 00       	mov    $0x800000,%ebx
  801259:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80125d:	75 1c                	jne    80127b <fork+0x6b>
		thisenv = &envs[ENVX(sys_getenvid())];
  80125f:	e8 83 fb ff ff       	call   800de7 <sys_getenvid>
  801264:	25 ff 03 00 00       	and    $0x3ff,%eax
  801269:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80126c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801271:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  801276:	e9 00 01 00 00       	jmp    80137b <fork+0x16b>
	}
	for(pg_cow_ptr = UTEXT; pg_cow_ptr < UXSTACKTOP - PGSIZE; pg_cow_ptr += PGSIZE){
		if ((vpd[PDX(pg_cow_ptr)]&PTE_P) && (vpt[PGNUM(pg_cow_ptr)]&(PTE_P|PTE_U)))
  80127b:	89 d8                	mov    %ebx,%eax
  80127d:	c1 e8 16             	shr    $0x16,%eax
  801280:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801287:	a8 01                	test   $0x1,%al
  801289:	74 79                	je     801304 <fork+0xf4>
  80128b:	89 de                	mov    %ebx,%esi
  80128d:	c1 ee 0c             	shr    $0xc,%esi
  801290:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801297:	a8 05                	test   $0x5,%al
  801299:	74 69                	je     801304 <fork+0xf4>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	// LAB 4: Your code here.
	int map_sz = pn*PGSIZE;
  80129b:	89 f7                	mov    %esi,%edi
  80129d:	c1 e7 0c             	shl    $0xc,%edi
	envid_t thisenv_id = sys_getenvid();
  8012a0:	e8 42 fb ff ff       	call   800de7 <sys_getenvid>
  8012a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	int perm = vpt[pn]&PTE_SYSCALL;
  8012a8:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8012af:	89 c6                	mov    %eax,%esi
  8012b1:	81 e6 07 0e 00 00    	and    $0xe07,%esi

	if(perm & PTE_COW || perm & PTE_W){
  8012b7:	a9 02 08 00 00       	test   $0x802,%eax
  8012bc:	74 09                	je     8012c7 <fork+0xb7>
		perm |= PTE_COW;
  8012be:	81 ce 00 08 00 00    	or     $0x800,%esi
		perm &= ~PTE_W;
  8012c4:	83 e6 fd             	and    $0xfffffffd,%esi
	}
	//cprintf("thisenv_id[%p]\n", thisenv_id);

	if((r = sys_page_map(thisenv_id, (void*)map_sz, envid, (void*)map_sz, perm)) < 0)
  8012c7:	89 74 24 10          	mov    %esi,0x10(%esp)
  8012cb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012d2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012d6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012da:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012dd:	89 04 24             	mov    %eax,(%esp)
  8012e0:	e8 dc fb ff ff       	call   800ec1 <sys_page_map>
  8012e5:	85 c0                	test   %eax,%eax
  8012e7:	78 1b                	js     801304 <fork+0xf4>
		return r;
	if((r = sys_page_map(thisenv_id, (void*)map_sz, thisenv_id, (void*)map_sz, perm)) < 0)
  8012e9:	89 74 24 10          	mov    %esi,0x10(%esp)
  8012ed:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012f1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012f4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012f8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012fc:	89 04 24             	mov    %eax,(%esp)
  8012ff:	e8 bd fb ff ff       	call   800ec1 <sys_page_map>
		panic("Fork error\n");
	if(child_id == 0){
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	for(pg_cow_ptr = UTEXT; pg_cow_ptr < UXSTACKTOP - PGSIZE; pg_cow_ptr += PGSIZE){
  801304:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80130a:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801310:	0f 85 65 ff ff ff    	jne    80127b <fork+0x6b>
		if ((vpd[PDX(pg_cow_ptr)]&PTE_P) && (vpt[PGNUM(pg_cow_ptr)]&(PTE_P|PTE_U)))
			duppage(child_id, PGNUM(pg_cow_ptr));
	}
	if((r = sys_page_alloc(child_id, (void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_P|PTE_W)))
  801316:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80131d:	00 
  80131e:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801325:	ee 
  801326:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801329:	89 04 24             	mov    %eax,(%esp)
  80132c:	e8 28 fb ff ff       	call   800e59 <sys_page_alloc>
  801331:	85 c0                	test   %eax,%eax
  801333:	74 20                	je     801355 <fork+0x145>
		panic("Alloc exception stack error: %e\n", r);
  801335:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801339:	c7 44 24 08 18 24 80 	movl   $0x802418,0x8(%esp)
  801340:	00 
  801341:	c7 44 24 04 78 00 00 	movl   $0x78,0x4(%esp)
  801348:	00 
  801349:	c7 04 24 39 24 80 00 	movl   $0x802439,(%esp)
  801350:	e8 3f ee ff ff       	call   800194 <_panic>

	extern void _pgfault_upcall(void);
	sys_env_set_pgfault_upcall(child_id, _pgfault_upcall);
  801355:	c7 44 24 04 20 1c 80 	movl   $0x801c20,0x4(%esp)
  80135c:	00 
  80135d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801360:	89 04 24             	mov    %eax,(%esp)
  801363:	e8 f5 fc ff ff       	call   80105d <sys_env_set_pgfault_upcall>

	sys_env_set_status(child_id, ENV_RUNNABLE);
  801368:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80136f:	00 
  801370:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801373:	89 04 24             	mov    %eax,(%esp)
  801376:	e8 14 fc ff ff       	call   800f8f <sys_env_set_status>
	return child_id;
	//panic("fork not implemented");
}
  80137b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80137e:	83 c4 3c             	add    $0x3c,%esp
  801381:	5b                   	pop    %ebx
  801382:	5e                   	pop    %esi
  801383:	5f                   	pop    %edi
  801384:	5d                   	pop    %ebp
  801385:	c3                   	ret    

00801386 <sfork>:

// Challenge!
int
sfork(void)
{
  801386:	55                   	push   %ebp
  801387:	89 e5                	mov    %esp,%ebp
  801389:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  80138c:	c7 44 24 08 50 24 80 	movl   $0x802450,0x8(%esp)
  801393:	00 
  801394:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  80139b:	00 
  80139c:	c7 04 24 39 24 80 00 	movl   $0x802439,(%esp)
  8013a3:	e8 ec ed ff ff       	call   800194 <_panic>
  8013a8:	66 90                	xchg   %ax,%ax
  8013aa:	66 90                	xchg   %ax,%ax
  8013ac:	66 90                	xchg   %ax,%ax
  8013ae:	66 90                	xchg   %ax,%ax

008013b0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013b0:	55                   	push   %ebp
  8013b1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b6:	05 00 00 00 30       	add    $0x30000000,%eax
  8013bb:	c1 e8 0c             	shr    $0xc,%eax
}
  8013be:	5d                   	pop    %ebp
  8013bf:	c3                   	ret    

008013c0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013c0:	55                   	push   %ebp
  8013c1:	89 e5                	mov    %esp,%ebp
  8013c3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8013c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c9:	89 04 24             	mov    %eax,(%esp)
  8013cc:	e8 df ff ff ff       	call   8013b0 <fd2num>
  8013d1:	c1 e0 0c             	shl    $0xc,%eax
  8013d4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8013d9:	c9                   	leave  
  8013da:	c3                   	ret    

008013db <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8013db:	55                   	push   %ebp
  8013dc:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8013de:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8013e3:	a8 01                	test   $0x1,%al
  8013e5:	74 34                	je     80141b <fd_alloc+0x40>
  8013e7:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8013ec:	a8 01                	test   $0x1,%al
  8013ee:	74 32                	je     801422 <fd_alloc+0x47>
  8013f0:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8013f5:	89 c1                	mov    %eax,%ecx
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8013f7:	89 c2                	mov    %eax,%edx
  8013f9:	c1 ea 16             	shr    $0x16,%edx
  8013fc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801403:	f6 c2 01             	test   $0x1,%dl
  801406:	74 1f                	je     801427 <fd_alloc+0x4c>
  801408:	89 c2                	mov    %eax,%edx
  80140a:	c1 ea 0c             	shr    $0xc,%edx
  80140d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801414:	f6 c2 01             	test   $0x1,%dl
  801417:	75 1a                	jne    801433 <fd_alloc+0x58>
  801419:	eb 0c                	jmp    801427 <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80141b:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801420:	eb 05                	jmp    801427 <fd_alloc+0x4c>
  801422:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  801427:	8b 45 08             	mov    0x8(%ebp),%eax
  80142a:	89 08                	mov    %ecx,(%eax)
			return 0;
  80142c:	b8 00 00 00 00       	mov    $0x0,%eax
  801431:	eb 1a                	jmp    80144d <fd_alloc+0x72>
  801433:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801438:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80143d:	75 b6                	jne    8013f5 <fd_alloc+0x1a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80143f:	8b 45 08             	mov    0x8(%ebp),%eax
  801442:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801448:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80144d:	5d                   	pop    %ebp
  80144e:	c3                   	ret    

0080144f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80144f:	55                   	push   %ebp
  801450:	89 e5                	mov    %esp,%ebp
  801452:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801455:	83 f8 1f             	cmp    $0x1f,%eax
  801458:	77 36                	ja     801490 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80145a:	c1 e0 0c             	shl    $0xc,%eax
  80145d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801462:	89 c2                	mov    %eax,%edx
  801464:	c1 ea 16             	shr    $0x16,%edx
  801467:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80146e:	f6 c2 01             	test   $0x1,%dl
  801471:	74 24                	je     801497 <fd_lookup+0x48>
  801473:	89 c2                	mov    %eax,%edx
  801475:	c1 ea 0c             	shr    $0xc,%edx
  801478:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80147f:	f6 c2 01             	test   $0x1,%dl
  801482:	74 1a                	je     80149e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801484:	8b 55 0c             	mov    0xc(%ebp),%edx
  801487:	89 02                	mov    %eax,(%edx)
	return 0;
  801489:	b8 00 00 00 00       	mov    $0x0,%eax
  80148e:	eb 13                	jmp    8014a3 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  801490:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801495:	eb 0c                	jmp    8014a3 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  801497:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80149c:	eb 05                	jmp    8014a3 <fd_lookup+0x54>
  80149e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8014a3:	5d                   	pop    %ebp
  8014a4:	c3                   	ret    

008014a5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8014a5:	55                   	push   %ebp
  8014a6:	89 e5                	mov    %esp,%ebp
  8014a8:	83 ec 18             	sub    $0x18,%esp
  8014ab:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8014ae:	39 05 04 30 80 00    	cmp    %eax,0x803004
  8014b4:	75 10                	jne    8014c6 <dev_lookup+0x21>
			*dev = devtab[i];
  8014b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014b9:	c7 00 04 30 80 00    	movl   $0x803004,(%eax)
			return 0;
  8014bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8014c4:	eb 2b                	jmp    8014f1 <dev_lookup+0x4c>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8014c6:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8014cc:	8b 52 48             	mov    0x48(%edx),%edx
  8014cf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8014d7:	c7 04 24 68 24 80 00 	movl   $0x802468,(%esp)
  8014de:	e8 ac ed ff ff       	call   80028f <cprintf>
	*dev = 0;
  8014e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014e6:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	return -E_INVAL;
  8014ec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014f1:	c9                   	leave  
  8014f2:	c3                   	ret    

008014f3 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8014f3:	55                   	push   %ebp
  8014f4:	89 e5                	mov    %esp,%ebp
  8014f6:	83 ec 38             	sub    $0x38,%esp
  8014f9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8014fc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8014ff:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801502:	8b 7d 08             	mov    0x8(%ebp),%edi
  801505:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801508:	89 3c 24             	mov    %edi,(%esp)
  80150b:	e8 a0 fe ff ff       	call   8013b0 <fd2num>
  801510:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  801513:	89 54 24 04          	mov    %edx,0x4(%esp)
  801517:	89 04 24             	mov    %eax,(%esp)
  80151a:	e8 30 ff ff ff       	call   80144f <fd_lookup>
  80151f:	89 c3                	mov    %eax,%ebx
  801521:	85 c0                	test   %eax,%eax
  801523:	78 05                	js     80152a <fd_close+0x37>
	    || fd != fd2)
  801525:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  801528:	74 0c                	je     801536 <fd_close+0x43>
		return (must_exist ? r : 0);
  80152a:	85 f6                	test   %esi,%esi
  80152c:	b8 00 00 00 00       	mov    $0x0,%eax
  801531:	0f 44 d8             	cmove  %eax,%ebx
  801534:	eb 3d                	jmp    801573 <fd_close+0x80>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801536:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801539:	89 44 24 04          	mov    %eax,0x4(%esp)
  80153d:	8b 07                	mov    (%edi),%eax
  80153f:	89 04 24             	mov    %eax,(%esp)
  801542:	e8 5e ff ff ff       	call   8014a5 <dev_lookup>
  801547:	89 c3                	mov    %eax,%ebx
  801549:	85 c0                	test   %eax,%eax
  80154b:	78 16                	js     801563 <fd_close+0x70>
		if (dev->dev_close)
  80154d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801550:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801553:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801558:	85 c0                	test   %eax,%eax
  80155a:	74 07                	je     801563 <fd_close+0x70>
			r = (*dev->dev_close)(fd);
  80155c:	89 3c 24             	mov    %edi,(%esp)
  80155f:	ff d0                	call   *%eax
  801561:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801563:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801567:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80156e:	e8 b5 f9 ff ff       	call   800f28 <sys_page_unmap>
	return r;
}
  801573:	89 d8                	mov    %ebx,%eax
  801575:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801578:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80157b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80157e:	89 ec                	mov    %ebp,%esp
  801580:	5d                   	pop    %ebp
  801581:	c3                   	ret    

00801582 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801582:	55                   	push   %ebp
  801583:	89 e5                	mov    %esp,%ebp
  801585:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801588:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80158b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80158f:	8b 45 08             	mov    0x8(%ebp),%eax
  801592:	89 04 24             	mov    %eax,(%esp)
  801595:	e8 b5 fe ff ff       	call   80144f <fd_lookup>
  80159a:	85 c0                	test   %eax,%eax
  80159c:	78 13                	js     8015b1 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80159e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8015a5:	00 
  8015a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015a9:	89 04 24             	mov    %eax,(%esp)
  8015ac:	e8 42 ff ff ff       	call   8014f3 <fd_close>
}
  8015b1:	c9                   	leave  
  8015b2:	c3                   	ret    

008015b3 <close_all>:

void
close_all(void)
{
  8015b3:	55                   	push   %ebp
  8015b4:	89 e5                	mov    %esp,%ebp
  8015b6:	53                   	push   %ebx
  8015b7:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8015ba:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8015bf:	89 1c 24             	mov    %ebx,(%esp)
  8015c2:	e8 bb ff ff ff       	call   801582 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8015c7:	83 c3 01             	add    $0x1,%ebx
  8015ca:	83 fb 20             	cmp    $0x20,%ebx
  8015cd:	75 f0                	jne    8015bf <close_all+0xc>
		close(i);
}
  8015cf:	83 c4 14             	add    $0x14,%esp
  8015d2:	5b                   	pop    %ebx
  8015d3:	5d                   	pop    %ebp
  8015d4:	c3                   	ret    

008015d5 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015d5:	55                   	push   %ebp
  8015d6:	89 e5                	mov    %esp,%ebp
  8015d8:	83 ec 58             	sub    $0x58,%esp
  8015db:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8015de:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8015e1:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8015e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015e7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8015f1:	89 04 24             	mov    %eax,(%esp)
  8015f4:	e8 56 fe ff ff       	call   80144f <fd_lookup>
  8015f9:	85 c0                	test   %eax,%eax
  8015fb:	0f 88 e3 00 00 00    	js     8016e4 <dup+0x10f>
		return r;
	close(newfdnum);
  801601:	89 1c 24             	mov    %ebx,(%esp)
  801604:	e8 79 ff ff ff       	call   801582 <close>

	newfd = INDEX2FD(newfdnum);
  801609:	89 de                	mov    %ebx,%esi
  80160b:	c1 e6 0c             	shl    $0xc,%esi
  80160e:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801614:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801617:	89 04 24             	mov    %eax,(%esp)
  80161a:	e8 a1 fd ff ff       	call   8013c0 <fd2data>
  80161f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801621:	89 34 24             	mov    %esi,(%esp)
  801624:	e8 97 fd ff ff       	call   8013c0 <fd2data>
  801629:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  80162c:	89 f8                	mov    %edi,%eax
  80162e:	c1 e8 16             	shr    $0x16,%eax
  801631:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801638:	a8 01                	test   $0x1,%al
  80163a:	74 46                	je     801682 <dup+0xad>
  80163c:	89 f8                	mov    %edi,%eax
  80163e:	c1 e8 0c             	shr    $0xc,%eax
  801641:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801648:	f6 c2 01             	test   $0x1,%dl
  80164b:	74 35                	je     801682 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80164d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801654:	25 07 0e 00 00       	and    $0xe07,%eax
  801659:	89 44 24 10          	mov    %eax,0x10(%esp)
  80165d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801660:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801664:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80166b:	00 
  80166c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801670:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801677:	e8 45 f8 ff ff       	call   800ec1 <sys_page_map>
  80167c:	89 c7                	mov    %eax,%edi
  80167e:	85 c0                	test   %eax,%eax
  801680:	78 3b                	js     8016bd <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801682:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801685:	89 c2                	mov    %eax,%edx
  801687:	c1 ea 0c             	shr    $0xc,%edx
  80168a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801691:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801697:	89 54 24 10          	mov    %edx,0x10(%esp)
  80169b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80169f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016a6:	00 
  8016a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016b2:	e8 0a f8 ff ff       	call   800ec1 <sys_page_map>
  8016b7:	89 c7                	mov    %eax,%edi
  8016b9:	85 c0                	test   %eax,%eax
  8016bb:	79 29                	jns    8016e6 <dup+0x111>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8016bd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016c8:	e8 5b f8 ff ff       	call   800f28 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016cd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8016d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016d4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016db:	e8 48 f8 ff ff       	call   800f28 <sys_page_unmap>
	return r;
  8016e0:	89 fb                	mov    %edi,%ebx
  8016e2:	eb 02                	jmp    8016e6 <dup+0x111>
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
		return r;
  8016e4:	89 c3                	mov    %eax,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8016e6:	89 d8                	mov    %ebx,%eax
  8016e8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8016eb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8016ee:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8016f1:	89 ec                	mov    %ebp,%esp
  8016f3:	5d                   	pop    %ebp
  8016f4:	c3                   	ret    

008016f5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016f5:	55                   	push   %ebp
  8016f6:	89 e5                	mov    %esp,%ebp
  8016f8:	53                   	push   %ebx
  8016f9:	83 ec 24             	sub    $0x24,%esp
  8016fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016ff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801702:	89 44 24 04          	mov    %eax,0x4(%esp)
  801706:	89 1c 24             	mov    %ebx,(%esp)
  801709:	e8 41 fd ff ff       	call   80144f <fd_lookup>
  80170e:	85 c0                	test   %eax,%eax
  801710:	78 6d                	js     80177f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801712:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801715:	89 44 24 04          	mov    %eax,0x4(%esp)
  801719:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80171c:	8b 00                	mov    (%eax),%eax
  80171e:	89 04 24             	mov    %eax,(%esp)
  801721:	e8 7f fd ff ff       	call   8014a5 <dev_lookup>
  801726:	85 c0                	test   %eax,%eax
  801728:	78 55                	js     80177f <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80172a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80172d:	8b 50 08             	mov    0x8(%eax),%edx
  801730:	83 e2 03             	and    $0x3,%edx
  801733:	83 fa 01             	cmp    $0x1,%edx
  801736:	75 23                	jne    80175b <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801738:	a1 08 40 80 00       	mov    0x804008,%eax
  80173d:	8b 40 48             	mov    0x48(%eax),%eax
  801740:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801744:	89 44 24 04          	mov    %eax,0x4(%esp)
  801748:	c7 04 24 a9 24 80 00 	movl   $0x8024a9,(%esp)
  80174f:	e8 3b eb ff ff       	call   80028f <cprintf>
		return -E_INVAL;
  801754:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801759:	eb 24                	jmp    80177f <read+0x8a>
	}
	if (!dev->dev_read)
  80175b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80175e:	8b 52 08             	mov    0x8(%edx),%edx
  801761:	85 d2                	test   %edx,%edx
  801763:	74 15                	je     80177a <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801765:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801768:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80176c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80176f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801773:	89 04 24             	mov    %eax,(%esp)
  801776:	ff d2                	call   *%edx
  801778:	eb 05                	jmp    80177f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80177a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80177f:	83 c4 24             	add    $0x24,%esp
  801782:	5b                   	pop    %ebx
  801783:	5d                   	pop    %ebp
  801784:	c3                   	ret    

00801785 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801785:	55                   	push   %ebp
  801786:	89 e5                	mov    %esp,%ebp
  801788:	57                   	push   %edi
  801789:	56                   	push   %esi
  80178a:	53                   	push   %ebx
  80178b:	83 ec 1c             	sub    $0x1c,%esp
  80178e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801791:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801794:	85 f6                	test   %esi,%esi
  801796:	74 33                	je     8017cb <readn+0x46>
  801798:	b8 00 00 00 00       	mov    $0x0,%eax
  80179d:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017a2:	89 f2                	mov    %esi,%edx
  8017a4:	29 c2                	sub    %eax,%edx
  8017a6:	89 54 24 08          	mov    %edx,0x8(%esp)
  8017aa:	03 45 0c             	add    0xc(%ebp),%eax
  8017ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b1:	89 3c 24             	mov    %edi,(%esp)
  8017b4:	e8 3c ff ff ff       	call   8016f5 <read>
		if (m < 0)
  8017b9:	85 c0                	test   %eax,%eax
  8017bb:	78 17                	js     8017d4 <readn+0x4f>
			return m;
		if (m == 0)
  8017bd:	85 c0                	test   %eax,%eax
  8017bf:	74 11                	je     8017d2 <readn+0x4d>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017c1:	01 c3                	add    %eax,%ebx
  8017c3:	89 d8                	mov    %ebx,%eax
  8017c5:	39 f3                	cmp    %esi,%ebx
  8017c7:	72 d9                	jb     8017a2 <readn+0x1d>
  8017c9:	eb 09                	jmp    8017d4 <readn+0x4f>
  8017cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8017d0:	eb 02                	jmp    8017d4 <readn+0x4f>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8017d2:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8017d4:	83 c4 1c             	add    $0x1c,%esp
  8017d7:	5b                   	pop    %ebx
  8017d8:	5e                   	pop    %esi
  8017d9:	5f                   	pop    %edi
  8017da:	5d                   	pop    %ebp
  8017db:	c3                   	ret    

008017dc <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017dc:	55                   	push   %ebp
  8017dd:	89 e5                	mov    %esp,%ebp
  8017df:	53                   	push   %ebx
  8017e0:	83 ec 24             	sub    $0x24,%esp
  8017e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017e6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ed:	89 1c 24             	mov    %ebx,(%esp)
  8017f0:	e8 5a fc ff ff       	call   80144f <fd_lookup>
  8017f5:	85 c0                	test   %eax,%eax
  8017f7:	78 68                	js     801861 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801800:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801803:	8b 00                	mov    (%eax),%eax
  801805:	89 04 24             	mov    %eax,(%esp)
  801808:	e8 98 fc ff ff       	call   8014a5 <dev_lookup>
  80180d:	85 c0                	test   %eax,%eax
  80180f:	78 50                	js     801861 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801811:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801814:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801818:	75 23                	jne    80183d <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80181a:	a1 08 40 80 00       	mov    0x804008,%eax
  80181f:	8b 40 48             	mov    0x48(%eax),%eax
  801822:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801826:	89 44 24 04          	mov    %eax,0x4(%esp)
  80182a:	c7 04 24 c5 24 80 00 	movl   $0x8024c5,(%esp)
  801831:	e8 59 ea ff ff       	call   80028f <cprintf>
		return -E_INVAL;
  801836:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80183b:	eb 24                	jmp    801861 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80183d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801840:	8b 52 0c             	mov    0xc(%edx),%edx
  801843:	85 d2                	test   %edx,%edx
  801845:	74 15                	je     80185c <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801847:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80184a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80184e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801851:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801855:	89 04 24             	mov    %eax,(%esp)
  801858:	ff d2                	call   *%edx
  80185a:	eb 05                	jmp    801861 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80185c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801861:	83 c4 24             	add    $0x24,%esp
  801864:	5b                   	pop    %ebx
  801865:	5d                   	pop    %ebp
  801866:	c3                   	ret    

00801867 <seek>:

int
seek(int fdnum, off_t offset)
{
  801867:	55                   	push   %ebp
  801868:	89 e5                	mov    %esp,%ebp
  80186a:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80186d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801870:	89 44 24 04          	mov    %eax,0x4(%esp)
  801874:	8b 45 08             	mov    0x8(%ebp),%eax
  801877:	89 04 24             	mov    %eax,(%esp)
  80187a:	e8 d0 fb ff ff       	call   80144f <fd_lookup>
  80187f:	85 c0                	test   %eax,%eax
  801881:	78 0e                	js     801891 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801883:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801886:	8b 55 0c             	mov    0xc(%ebp),%edx
  801889:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80188c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801891:	c9                   	leave  
  801892:	c3                   	ret    

00801893 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801893:	55                   	push   %ebp
  801894:	89 e5                	mov    %esp,%ebp
  801896:	53                   	push   %ebx
  801897:	83 ec 24             	sub    $0x24,%esp
  80189a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80189d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a4:	89 1c 24             	mov    %ebx,(%esp)
  8018a7:	e8 a3 fb ff ff       	call   80144f <fd_lookup>
  8018ac:	85 c0                	test   %eax,%eax
  8018ae:	78 61                	js     801911 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018ba:	8b 00                	mov    (%eax),%eax
  8018bc:	89 04 24             	mov    %eax,(%esp)
  8018bf:	e8 e1 fb ff ff       	call   8014a5 <dev_lookup>
  8018c4:	85 c0                	test   %eax,%eax
  8018c6:	78 49                	js     801911 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018cb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018cf:	75 23                	jne    8018f4 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8018d1:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018d6:	8b 40 48             	mov    0x48(%eax),%eax
  8018d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018e1:	c7 04 24 88 24 80 00 	movl   $0x802488,(%esp)
  8018e8:	e8 a2 e9 ff ff       	call   80028f <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8018ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018f2:	eb 1d                	jmp    801911 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8018f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018f7:	8b 52 18             	mov    0x18(%edx),%edx
  8018fa:	85 d2                	test   %edx,%edx
  8018fc:	74 0e                	je     80190c <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801901:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801905:	89 04 24             	mov    %eax,(%esp)
  801908:	ff d2                	call   *%edx
  80190a:	eb 05                	jmp    801911 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80190c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801911:	83 c4 24             	add    $0x24,%esp
  801914:	5b                   	pop    %ebx
  801915:	5d                   	pop    %ebp
  801916:	c3                   	ret    

00801917 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801917:	55                   	push   %ebp
  801918:	89 e5                	mov    %esp,%ebp
  80191a:	53                   	push   %ebx
  80191b:	83 ec 24             	sub    $0x24,%esp
  80191e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801921:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801924:	89 44 24 04          	mov    %eax,0x4(%esp)
  801928:	8b 45 08             	mov    0x8(%ebp),%eax
  80192b:	89 04 24             	mov    %eax,(%esp)
  80192e:	e8 1c fb ff ff       	call   80144f <fd_lookup>
  801933:	85 c0                	test   %eax,%eax
  801935:	78 52                	js     801989 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801937:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80193a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80193e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801941:	8b 00                	mov    (%eax),%eax
  801943:	89 04 24             	mov    %eax,(%esp)
  801946:	e8 5a fb ff ff       	call   8014a5 <dev_lookup>
  80194b:	85 c0                	test   %eax,%eax
  80194d:	78 3a                	js     801989 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  80194f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801952:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801956:	74 2c                	je     801984 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801958:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80195b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801962:	00 00 00 
	stat->st_isdir = 0;
  801965:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80196c:	00 00 00 
	stat->st_dev = dev;
  80196f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801975:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801979:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80197c:	89 14 24             	mov    %edx,(%esp)
  80197f:	ff 50 14             	call   *0x14(%eax)
  801982:	eb 05                	jmp    801989 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801984:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801989:	83 c4 24             	add    $0x24,%esp
  80198c:	5b                   	pop    %ebx
  80198d:	5d                   	pop    %ebp
  80198e:	c3                   	ret    

0080198f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80198f:	55                   	push   %ebp
  801990:	89 e5                	mov    %esp,%ebp
  801992:	83 ec 18             	sub    $0x18,%esp
  801995:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801998:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80199b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8019a2:	00 
  8019a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a6:	89 04 24             	mov    %eax,(%esp)
  8019a9:	e8 84 01 00 00       	call   801b32 <open>
  8019ae:	89 c3                	mov    %eax,%ebx
  8019b0:	85 c0                	test   %eax,%eax
  8019b2:	78 1b                	js     8019cf <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  8019b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019bb:	89 1c 24             	mov    %ebx,(%esp)
  8019be:	e8 54 ff ff ff       	call   801917 <fstat>
  8019c3:	89 c6                	mov    %eax,%esi
	close(fd);
  8019c5:	89 1c 24             	mov    %ebx,(%esp)
  8019c8:	e8 b5 fb ff ff       	call   801582 <close>
	return r;
  8019cd:	89 f3                	mov    %esi,%ebx
}
  8019cf:	89 d8                	mov    %ebx,%eax
  8019d1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8019d4:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8019d7:	89 ec                	mov    %ebp,%esp
  8019d9:	5d                   	pop    %ebp
  8019da:	c3                   	ret    
  8019db:	90                   	nop

008019dc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8019dc:	55                   	push   %ebp
  8019dd:	89 e5                	mov    %esp,%ebp
  8019df:	83 ec 18             	sub    $0x18,%esp
  8019e2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8019e5:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8019e8:	89 c6                	mov    %eax,%esi
  8019ea:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8019ec:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8019f3:	75 11                	jne    801a06 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019f5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8019fc:	e8 0a 03 00 00       	call   801d0b <ipc_find_env>
  801a01:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a06:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801a0d:	00 
  801a0e:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801a15:	00 
  801a16:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a1a:	a1 00 40 80 00       	mov    0x804000,%eax
  801a1f:	89 04 24             	mov    %eax,(%esp)
  801a22:	e8 79 02 00 00       	call   801ca0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a27:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a2e:	00 
  801a2f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a33:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a3a:	e8 09 02 00 00       	call   801c48 <ipc_recv>
}
  801a3f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801a42:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801a45:	89 ec                	mov    %ebp,%esp
  801a47:	5d                   	pop    %ebp
  801a48:	c3                   	ret    

00801a49 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a49:	55                   	push   %ebp
  801a4a:	89 e5                	mov    %esp,%ebp
  801a4c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a4f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a52:	8b 40 0c             	mov    0xc(%eax),%eax
  801a55:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801a5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a5d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a62:	ba 00 00 00 00       	mov    $0x0,%edx
  801a67:	b8 02 00 00 00       	mov    $0x2,%eax
  801a6c:	e8 6b ff ff ff       	call   8019dc <fsipc>
}
  801a71:	c9                   	leave  
  801a72:	c3                   	ret    

00801a73 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a73:	55                   	push   %ebp
  801a74:	89 e5                	mov    %esp,%ebp
  801a76:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a79:	8b 45 08             	mov    0x8(%ebp),%eax
  801a7c:	8b 40 0c             	mov    0xc(%eax),%eax
  801a7f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a84:	ba 00 00 00 00       	mov    $0x0,%edx
  801a89:	b8 06 00 00 00       	mov    $0x6,%eax
  801a8e:	e8 49 ff ff ff       	call   8019dc <fsipc>
}
  801a93:	c9                   	leave  
  801a94:	c3                   	ret    

00801a95 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a95:	55                   	push   %ebp
  801a96:	89 e5                	mov    %esp,%ebp
  801a98:	53                   	push   %ebx
  801a99:	83 ec 14             	sub    $0x14,%esp
  801a9c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a9f:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa2:	8b 40 0c             	mov    0xc(%eax),%eax
  801aa5:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801aaa:	ba 00 00 00 00       	mov    $0x0,%edx
  801aaf:	b8 05 00 00 00       	mov    $0x5,%eax
  801ab4:	e8 23 ff ff ff       	call   8019dc <fsipc>
  801ab9:	85 c0                	test   %eax,%eax
  801abb:	78 2b                	js     801ae8 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801abd:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801ac4:	00 
  801ac5:	89 1c 24             	mov    %ebx,(%esp)
  801ac8:	e8 3e ee ff ff       	call   80090b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801acd:	a1 80 50 80 00       	mov    0x805080,%eax
  801ad2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801ad8:	a1 84 50 80 00       	mov    0x805084,%eax
  801add:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801ae3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ae8:	83 c4 14             	add    $0x14,%esp
  801aeb:	5b                   	pop    %ebx
  801aec:	5d                   	pop    %ebp
  801aed:	c3                   	ret    

00801aee <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801aee:	55                   	push   %ebp
  801aef:	89 e5                	mov    %esp,%ebp
  801af1:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801af4:	c7 44 24 08 e2 24 80 	movl   $0x8024e2,0x8(%esp)
  801afb:	00 
  801afc:	c7 44 24 04 77 00 00 	movl   $0x77,0x4(%esp)
  801b03:	00 
  801b04:	c7 04 24 00 25 80 00 	movl   $0x802500,(%esp)
  801b0b:	e8 84 e6 ff ff       	call   800194 <_panic>

00801b10 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b10:	55                   	push   %ebp
  801b11:	89 e5                	mov    %esp,%ebp
  801b13:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_READ request to the file system server after
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
	panic("devfile_read not implemented");
  801b16:	c7 44 24 08 0b 25 80 	movl   $0x80250b,0x8(%esp)
  801b1d:	00 
  801b1e:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
  801b25:	00 
  801b26:	c7 04 24 00 25 80 00 	movl   $0x802500,(%esp)
  801b2d:	e8 62 e6 ff ff       	call   800194 <_panic>

00801b32 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b32:	55                   	push   %ebp
  801b33:	89 e5                	mov    %esp,%ebp
  801b35:	83 ec 18             	sub    $0x18,%esp
	// Return the file descriptor index.
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
	panic("open not implemented");
  801b38:	c7 44 24 08 28 25 80 	movl   $0x802528,0x8(%esp)
  801b3f:	00 
  801b40:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  801b47:	00 
  801b48:	c7 04 24 00 25 80 00 	movl   $0x802500,(%esp)
  801b4f:	e8 40 e6 ff ff       	call   800194 <_panic>

00801b54 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801b54:	55                   	push   %ebp
  801b55:	89 e5                	mov    %esp,%ebp
  801b57:	53                   	push   %ebx
  801b58:	83 ec 14             	sub    $0x14,%esp
  801b5b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801b5e:	89 1c 24             	mov    %ebx,(%esp)
  801b61:	e8 4a ed ff ff       	call   8008b0 <strlen>
  801b66:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b6b:	7f 21                	jg     801b8e <remove+0x3a>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801b6d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b71:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801b78:	e8 8e ed ff ff       	call   80090b <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801b7d:	ba 00 00 00 00       	mov    $0x0,%edx
  801b82:	b8 07 00 00 00       	mov    $0x7,%eax
  801b87:	e8 50 fe ff ff       	call   8019dc <fsipc>
  801b8c:	eb 05                	jmp    801b93 <remove+0x3f>
// Delete a file
int
remove(const char *path)
{
	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b8e:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
	strcpy(fsipcbuf.remove.req_path, path);
	return fsipc(FSREQ_REMOVE, NULL);
}
  801b93:	83 c4 14             	add    $0x14,%esp
  801b96:	5b                   	pop    %ebx
  801b97:	5d                   	pop    %ebp
  801b98:	c3                   	ret    

00801b99 <sync>:

// Synchronize disk with buffer cache
int
sync(void)
{
  801b99:	55                   	push   %ebp
  801b9a:	89 e5                	mov    %esp,%ebp
  801b9c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b9f:	ba 00 00 00 00       	mov    $0x0,%edx
  801ba4:	b8 08 00 00 00       	mov    $0x8,%eax
  801ba9:	e8 2e fe ff ff       	call   8019dc <fsipc>
}
  801bae:	c9                   	leave  
  801baf:	c3                   	ret    

00801bb0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801bb0:	55                   	push   %ebp
  801bb1:	89 e5                	mov    %esp,%ebp
  801bb3:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801bb6:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801bbd:	75 54                	jne    801c13 <set_pgfault_handler+0x63>
		// First time through!
		// LAB 4: Your code here.
		if((r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U|PTE_P|PTE_W)))
  801bbf:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801bc6:	00 
  801bc7:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801bce:	ee 
  801bcf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bd6:	e8 7e f2 ff ff       	call   800e59 <sys_page_alloc>
  801bdb:	85 c0                	test   %eax,%eax
  801bdd:	74 20                	je     801bff <set_pgfault_handler+0x4f>
			panic("sys_page_alloc() failed in set_pgfault_handler()[%e]\n", r);
  801bdf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801be3:	c7 44 24 08 40 25 80 	movl   $0x802540,0x8(%esp)
  801bea:	00 
  801beb:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  801bf2:	00 
  801bf3:	c7 04 24 78 25 80 00 	movl   $0x802578,(%esp)
  801bfa:	e8 95 e5 ff ff       	call   800194 <_panic>
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801bff:	c7 44 24 04 20 1c 80 	movl   $0x801c20,0x4(%esp)
  801c06:	00 
  801c07:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c0e:	e8 4a f4 ff ff       	call   80105d <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801c13:	8b 45 08             	mov    0x8(%ebp),%eax
  801c16:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801c1b:	c9                   	leave  
  801c1c:	c3                   	ret    
  801c1d:	66 90                	xchg   %ax,%ax
  801c1f:	90                   	nop

00801c20 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801c20:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801c21:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801c26:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801c28:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	// @yuhangj: get reserved place under old esp
	addl $0x08, %esp;
  801c2b:	83 c4 08             	add    $0x8,%esp

	movl 0x28(%esp), %eax;
  801c2e:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x04, %eax;
  801c32:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x28(%esp);
  801c35:	89 44 24 28          	mov    %eax,0x28(%esp)

    // @yuhangj: store old eip into the reserved place under old esp
	movl 0x20(%esp), %ebx;
  801c39:	8b 5c 24 20          	mov    0x20(%esp),%ebx
	movl %ebx, (%eax);
  801c3d:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  801c3f:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp;
  801c40:	83 c4 04             	add    $0x4,%esp
	popfl
  801c43:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  801c44:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  801c45:	c3                   	ret    
  801c46:	66 90                	xchg   %ax,%ax

00801c48 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801c48:	55                   	push   %ebp
  801c49:	89 e5                	mov    %esp,%ebp
  801c4b:	56                   	push   %esi
  801c4c:	53                   	push   %ebx
  801c4d:	83 ec 10             	sub    $0x10,%esp
  801c50:	8b 75 08             	mov    0x8(%ebp),%esi
  801c53:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	// 	return thisenv->env_ipc_value;
	// }
	int r;
	if(pg == NULL)
		pg = (void *)~0x0;
  801c56:	85 db                	test   %ebx,%ebx
  801c58:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801c5d:	0f 44 d8             	cmove  %eax,%ebx
	//else
	if((r = sys_ipc_recv(pg)) < 0)
  801c60:	89 1c 24             	mov    %ebx,(%esp)
  801c63:	e8 99 f4 ff ff       	call   801101 <sys_ipc_recv>
  801c68:	85 c0                	test   %eax,%eax
  801c6a:	78 2d                	js     801c99 <ipc_recv+0x51>
		return r;
	//volatile struct Env *curenv = (struct Env*)envs+ENVX(sys_getenvid());

	if(from_env_store)
  801c6c:	85 f6                	test   %esi,%esi
  801c6e:	74 0a                	je     801c7a <ipc_recv+0x32>
		*from_env_store = thisenv -> env_ipc_from;
  801c70:	a1 08 40 80 00       	mov    0x804008,%eax
  801c75:	8b 40 74             	mov    0x74(%eax),%eax
  801c78:	89 06                	mov    %eax,(%esi)
	if(pg && perm_store)
  801c7a:	85 db                	test   %ebx,%ebx
  801c7c:	74 13                	je     801c91 <ipc_recv+0x49>
  801c7e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c82:	74 0d                	je     801c91 <ipc_recv+0x49>
		*perm_store = thisenv -> env_ipc_perm;
  801c84:	a1 08 40 80 00       	mov    0x804008,%eax
  801c89:	8b 40 78             	mov    0x78(%eax),%eax
  801c8c:	8b 55 10             	mov    0x10(%ebp),%edx
  801c8f:	89 02                	mov    %eax,(%edx)
	else if(perm_store)
		perm_store = (int *)0;
	return thisenv->env_ipc_value;
  801c91:	a1 08 40 80 00       	mov    0x804008,%eax
  801c96:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  801c99:	83 c4 10             	add    $0x10,%esp
  801c9c:	5b                   	pop    %ebx
  801c9d:	5e                   	pop    %esi
  801c9e:	5d                   	pop    %ebp
  801c9f:	c3                   	ret    

00801ca0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ca0:	55                   	push   %ebp
  801ca1:	89 e5                	mov    %esp,%ebp
  801ca3:	57                   	push   %edi
  801ca4:	56                   	push   %esi
  801ca5:	53                   	push   %ebx
  801ca6:	83 ec 1c             	sub    $0x1c,%esp
  801ca9:	8b 7d 08             	mov    0x8(%ebp),%edi
  801cac:	8b 75 0c             	mov    0xc(%ebp),%esi
  801caf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

	if(pg == NULL)
  801cb2:	85 db                	test   %ebx,%ebx
		pg = (void *)~0x0;
  801cb4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801cb9:	0f 44 d8             	cmove  %eax,%ebx
  801cbc:	eb 2a                	jmp    801ce8 <ipc_send+0x48>
	while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0){
		if(r != -E_IPC_NOT_RECV)
  801cbe:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801cc1:	74 20                	je     801ce3 <ipc_send+0x43>
            panic("Send message error %e\n",r);
  801cc3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801cc7:	c7 44 24 08 86 25 80 	movl   $0x802586,0x8(%esp)
  801cce:	00 
  801ccf:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  801cd6:	00 
  801cd7:	c7 04 24 9d 25 80 00 	movl   $0x80259d,(%esp)
  801cde:	e8 b1 e4 ff ff       	call   800194 <_panic>
		sys_yield();
  801ce3:	e8 38 f1 ff ff       	call   800e20 <sys_yield>
	// LAB 4: Your code here.
	int r;

	if(pg == NULL)
		pg = (void *)~0x0;
	while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0){
  801ce8:	8b 45 14             	mov    0x14(%ebp),%eax
  801ceb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801cef:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801cf3:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cf7:	89 3c 24             	mov    %edi,(%esp)
  801cfa:	e8 c5 f3 ff ff       	call   8010c4 <sys_ipc_try_send>
  801cff:	85 c0                	test   %eax,%eax
  801d01:	78 bb                	js     801cbe <ipc_send+0x1e>
            panic("Send message error %e\n",r);
		sys_yield();
	}

	//panic("ipc_send not implemented");
}
  801d03:	83 c4 1c             	add    $0x1c,%esp
  801d06:	5b                   	pop    %ebx
  801d07:	5e                   	pop    %esi
  801d08:	5f                   	pop    %edi
  801d09:	5d                   	pop    %ebp
  801d0a:	c3                   	ret    

00801d0b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801d0b:	55                   	push   %ebp
  801d0c:	89 e5                	mov    %esp,%ebp
  801d0e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801d11:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801d16:	39 c8                	cmp    %ecx,%eax
  801d18:	74 17                	je     801d31 <ipc_find_env+0x26>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d1a:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801d1f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801d22:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801d28:	8b 52 50             	mov    0x50(%edx),%edx
  801d2b:	39 ca                	cmp    %ecx,%edx
  801d2d:	75 14                	jne    801d43 <ipc_find_env+0x38>
  801d2f:	eb 05                	jmp    801d36 <ipc_find_env+0x2b>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d31:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801d36:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801d39:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801d3e:	8b 40 40             	mov    0x40(%eax),%eax
  801d41:	eb 0e                	jmp    801d51 <ipc_find_env+0x46>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d43:	83 c0 01             	add    $0x1,%eax
  801d46:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d4b:	75 d2                	jne    801d1f <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801d4d:	66 b8 00 00          	mov    $0x0,%ax
}
  801d51:	5d                   	pop    %ebp
  801d52:	c3                   	ret    
  801d53:	66 90                	xchg   %ax,%ax
  801d55:	66 90                	xchg   %ax,%ax
  801d57:	66 90                	xchg   %ax,%ax
  801d59:	66 90                	xchg   %ax,%ax
  801d5b:	66 90                	xchg   %ax,%ax
  801d5d:	66 90                	xchg   %ax,%ax
  801d5f:	90                   	nop

00801d60 <__udivdi3>:
  801d60:	83 ec 1c             	sub    $0x1c,%esp
  801d63:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801d67:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801d6b:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801d6f:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801d73:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801d77:	8b 6c 24 24          	mov    0x24(%esp),%ebp
  801d7b:	85 c0                	test   %eax,%eax
  801d7d:	89 74 24 10          	mov    %esi,0x10(%esp)
  801d81:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801d85:	89 ea                	mov    %ebp,%edx
  801d87:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801d8b:	75 33                	jne    801dc0 <__udivdi3+0x60>
  801d8d:	39 e9                	cmp    %ebp,%ecx
  801d8f:	77 6f                	ja     801e00 <__udivdi3+0xa0>
  801d91:	85 c9                	test   %ecx,%ecx
  801d93:	89 ce                	mov    %ecx,%esi
  801d95:	75 0b                	jne    801da2 <__udivdi3+0x42>
  801d97:	b8 01 00 00 00       	mov    $0x1,%eax
  801d9c:	31 d2                	xor    %edx,%edx
  801d9e:	f7 f1                	div    %ecx
  801da0:	89 c6                	mov    %eax,%esi
  801da2:	31 d2                	xor    %edx,%edx
  801da4:	89 e8                	mov    %ebp,%eax
  801da6:	f7 f6                	div    %esi
  801da8:	89 c5                	mov    %eax,%ebp
  801daa:	89 f8                	mov    %edi,%eax
  801dac:	f7 f6                	div    %esi
  801dae:	89 ea                	mov    %ebp,%edx
  801db0:	8b 74 24 10          	mov    0x10(%esp),%esi
  801db4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801db8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801dbc:	83 c4 1c             	add    $0x1c,%esp
  801dbf:	c3                   	ret    
  801dc0:	39 e8                	cmp    %ebp,%eax
  801dc2:	77 24                	ja     801de8 <__udivdi3+0x88>
  801dc4:	0f bd c8             	bsr    %eax,%ecx
  801dc7:	83 f1 1f             	xor    $0x1f,%ecx
  801dca:	89 0c 24             	mov    %ecx,(%esp)
  801dcd:	75 49                	jne    801e18 <__udivdi3+0xb8>
  801dcf:	8b 74 24 08          	mov    0x8(%esp),%esi
  801dd3:	39 74 24 04          	cmp    %esi,0x4(%esp)
  801dd7:	0f 86 ab 00 00 00    	jbe    801e88 <__udivdi3+0x128>
  801ddd:	39 e8                	cmp    %ebp,%eax
  801ddf:	0f 82 a3 00 00 00    	jb     801e88 <__udivdi3+0x128>
  801de5:	8d 76 00             	lea    0x0(%esi),%esi
  801de8:	31 d2                	xor    %edx,%edx
  801dea:	31 c0                	xor    %eax,%eax
  801dec:	8b 74 24 10          	mov    0x10(%esp),%esi
  801df0:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801df4:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801df8:	83 c4 1c             	add    $0x1c,%esp
  801dfb:	c3                   	ret    
  801dfc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e00:	89 f8                	mov    %edi,%eax
  801e02:	f7 f1                	div    %ecx
  801e04:	31 d2                	xor    %edx,%edx
  801e06:	8b 74 24 10          	mov    0x10(%esp),%esi
  801e0a:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801e0e:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801e12:	83 c4 1c             	add    $0x1c,%esp
  801e15:	c3                   	ret    
  801e16:	66 90                	xchg   %ax,%ax
  801e18:	0f b6 0c 24          	movzbl (%esp),%ecx
  801e1c:	89 c6                	mov    %eax,%esi
  801e1e:	b8 20 00 00 00       	mov    $0x20,%eax
  801e23:	8b 6c 24 04          	mov    0x4(%esp),%ebp
  801e27:	2b 04 24             	sub    (%esp),%eax
  801e2a:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801e2e:	d3 e6                	shl    %cl,%esi
  801e30:	89 c1                	mov    %eax,%ecx
  801e32:	d3 ed                	shr    %cl,%ebp
  801e34:	0f b6 0c 24          	movzbl (%esp),%ecx
  801e38:	09 f5                	or     %esi,%ebp
  801e3a:	8b 74 24 04          	mov    0x4(%esp),%esi
  801e3e:	d3 e6                	shl    %cl,%esi
  801e40:	89 c1                	mov    %eax,%ecx
  801e42:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e46:	89 d6                	mov    %edx,%esi
  801e48:	d3 ee                	shr    %cl,%esi
  801e4a:	0f b6 0c 24          	movzbl (%esp),%ecx
  801e4e:	d3 e2                	shl    %cl,%edx
  801e50:	89 c1                	mov    %eax,%ecx
  801e52:	d3 ef                	shr    %cl,%edi
  801e54:	09 d7                	or     %edx,%edi
  801e56:	89 f2                	mov    %esi,%edx
  801e58:	89 f8                	mov    %edi,%eax
  801e5a:	f7 f5                	div    %ebp
  801e5c:	89 d6                	mov    %edx,%esi
  801e5e:	89 c7                	mov    %eax,%edi
  801e60:	f7 64 24 04          	mull   0x4(%esp)
  801e64:	39 d6                	cmp    %edx,%esi
  801e66:	72 30                	jb     801e98 <__udivdi3+0x138>
  801e68:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801e6c:	0f b6 0c 24          	movzbl (%esp),%ecx
  801e70:	d3 e5                	shl    %cl,%ebp
  801e72:	39 c5                	cmp    %eax,%ebp
  801e74:	73 04                	jae    801e7a <__udivdi3+0x11a>
  801e76:	39 d6                	cmp    %edx,%esi
  801e78:	74 1e                	je     801e98 <__udivdi3+0x138>
  801e7a:	89 f8                	mov    %edi,%eax
  801e7c:	31 d2                	xor    %edx,%edx
  801e7e:	e9 69 ff ff ff       	jmp    801dec <__udivdi3+0x8c>
  801e83:	90                   	nop
  801e84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e88:	31 d2                	xor    %edx,%edx
  801e8a:	b8 01 00 00 00       	mov    $0x1,%eax
  801e8f:	e9 58 ff ff ff       	jmp    801dec <__udivdi3+0x8c>
  801e94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e98:	8d 47 ff             	lea    -0x1(%edi),%eax
  801e9b:	31 d2                	xor    %edx,%edx
  801e9d:	8b 74 24 10          	mov    0x10(%esp),%esi
  801ea1:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801ea5:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801ea9:	83 c4 1c             	add    $0x1c,%esp
  801eac:	c3                   	ret    
  801ead:	66 90                	xchg   %ax,%ax
  801eaf:	90                   	nop

00801eb0 <__umoddi3>:
  801eb0:	83 ec 2c             	sub    $0x2c,%esp
  801eb3:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801eb7:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801ebb:	89 74 24 20          	mov    %esi,0x20(%esp)
  801ebf:	8b 74 24 38          	mov    0x38(%esp),%esi
  801ec3:	89 7c 24 24          	mov    %edi,0x24(%esp)
  801ec7:	8b 7c 24 34          	mov    0x34(%esp),%edi
  801ecb:	85 c0                	test   %eax,%eax
  801ecd:	89 c2                	mov    %eax,%edx
  801ecf:	89 6c 24 28          	mov    %ebp,0x28(%esp)
  801ed3:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801ed7:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801edb:	89 74 24 10          	mov    %esi,0x10(%esp)
  801edf:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801ee3:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801ee7:	75 1f                	jne    801f08 <__umoddi3+0x58>
  801ee9:	39 fe                	cmp    %edi,%esi
  801eeb:	76 63                	jbe    801f50 <__umoddi3+0xa0>
  801eed:	89 c8                	mov    %ecx,%eax
  801eef:	89 fa                	mov    %edi,%edx
  801ef1:	f7 f6                	div    %esi
  801ef3:	89 d0                	mov    %edx,%eax
  801ef5:	31 d2                	xor    %edx,%edx
  801ef7:	8b 74 24 20          	mov    0x20(%esp),%esi
  801efb:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801eff:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801f03:	83 c4 2c             	add    $0x2c,%esp
  801f06:	c3                   	ret    
  801f07:	90                   	nop
  801f08:	39 f8                	cmp    %edi,%eax
  801f0a:	77 64                	ja     801f70 <__umoddi3+0xc0>
  801f0c:	0f bd e8             	bsr    %eax,%ebp
  801f0f:	83 f5 1f             	xor    $0x1f,%ebp
  801f12:	75 74                	jne    801f88 <__umoddi3+0xd8>
  801f14:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801f18:	39 7c 24 10          	cmp    %edi,0x10(%esp)
  801f1c:	0f 87 0e 01 00 00    	ja     802030 <__umoddi3+0x180>
  801f22:	8b 7c 24 0c          	mov    0xc(%esp),%edi
  801f26:	29 f1                	sub    %esi,%ecx
  801f28:	19 c7                	sbb    %eax,%edi
  801f2a:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801f2e:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801f32:	8b 44 24 14          	mov    0x14(%esp),%eax
  801f36:	8b 54 24 18          	mov    0x18(%esp),%edx
  801f3a:	8b 74 24 20          	mov    0x20(%esp),%esi
  801f3e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801f42:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801f46:	83 c4 2c             	add    $0x2c,%esp
  801f49:	c3                   	ret    
  801f4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f50:	85 f6                	test   %esi,%esi
  801f52:	89 f5                	mov    %esi,%ebp
  801f54:	75 0b                	jne    801f61 <__umoddi3+0xb1>
  801f56:	b8 01 00 00 00       	mov    $0x1,%eax
  801f5b:	31 d2                	xor    %edx,%edx
  801f5d:	f7 f6                	div    %esi
  801f5f:	89 c5                	mov    %eax,%ebp
  801f61:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801f65:	31 d2                	xor    %edx,%edx
  801f67:	f7 f5                	div    %ebp
  801f69:	89 c8                	mov    %ecx,%eax
  801f6b:	f7 f5                	div    %ebp
  801f6d:	eb 84                	jmp    801ef3 <__umoddi3+0x43>
  801f6f:	90                   	nop
  801f70:	89 c8                	mov    %ecx,%eax
  801f72:	89 fa                	mov    %edi,%edx
  801f74:	8b 74 24 20          	mov    0x20(%esp),%esi
  801f78:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801f7c:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801f80:	83 c4 2c             	add    $0x2c,%esp
  801f83:	c3                   	ret    
  801f84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f88:	8b 44 24 10          	mov    0x10(%esp),%eax
  801f8c:	be 20 00 00 00       	mov    $0x20,%esi
  801f91:	89 e9                	mov    %ebp,%ecx
  801f93:	29 ee                	sub    %ebp,%esi
  801f95:	d3 e2                	shl    %cl,%edx
  801f97:	89 f1                	mov    %esi,%ecx
  801f99:	d3 e8                	shr    %cl,%eax
  801f9b:	89 e9                	mov    %ebp,%ecx
  801f9d:	09 d0                	or     %edx,%eax
  801f9f:	89 fa                	mov    %edi,%edx
  801fa1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fa5:	8b 44 24 10          	mov    0x10(%esp),%eax
  801fa9:	d3 e0                	shl    %cl,%eax
  801fab:	89 f1                	mov    %esi,%ecx
  801fad:	89 44 24 10          	mov    %eax,0x10(%esp)
  801fb1:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801fb5:	d3 ea                	shr    %cl,%edx
  801fb7:	89 e9                	mov    %ebp,%ecx
  801fb9:	d3 e7                	shl    %cl,%edi
  801fbb:	89 f1                	mov    %esi,%ecx
  801fbd:	d3 e8                	shr    %cl,%eax
  801fbf:	89 e9                	mov    %ebp,%ecx
  801fc1:	09 f8                	or     %edi,%eax
  801fc3:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801fc7:	f7 74 24 0c          	divl   0xc(%esp)
  801fcb:	d3 e7                	shl    %cl,%edi
  801fcd:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801fd1:	89 d7                	mov    %edx,%edi
  801fd3:	f7 64 24 10          	mull   0x10(%esp)
  801fd7:	39 d7                	cmp    %edx,%edi
  801fd9:	89 c1                	mov    %eax,%ecx
  801fdb:	89 54 24 14          	mov    %edx,0x14(%esp)
  801fdf:	72 3b                	jb     80201c <__umoddi3+0x16c>
  801fe1:	39 44 24 18          	cmp    %eax,0x18(%esp)
  801fe5:	72 31                	jb     802018 <__umoddi3+0x168>
  801fe7:	8b 44 24 18          	mov    0x18(%esp),%eax
  801feb:	29 c8                	sub    %ecx,%eax
  801fed:	19 d7                	sbb    %edx,%edi
  801fef:	89 e9                	mov    %ebp,%ecx
  801ff1:	89 fa                	mov    %edi,%edx
  801ff3:	d3 e8                	shr    %cl,%eax
  801ff5:	89 f1                	mov    %esi,%ecx
  801ff7:	d3 e2                	shl    %cl,%edx
  801ff9:	89 e9                	mov    %ebp,%ecx
  801ffb:	09 d0                	or     %edx,%eax
  801ffd:	89 fa                	mov    %edi,%edx
  801fff:	d3 ea                	shr    %cl,%edx
  802001:	8b 74 24 20          	mov    0x20(%esp),%esi
  802005:	8b 7c 24 24          	mov    0x24(%esp),%edi
  802009:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  80200d:	83 c4 2c             	add    $0x2c,%esp
  802010:	c3                   	ret    
  802011:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802018:	39 d7                	cmp    %edx,%edi
  80201a:	75 cb                	jne    801fe7 <__umoddi3+0x137>
  80201c:	8b 54 24 14          	mov    0x14(%esp),%edx
  802020:	89 c1                	mov    %eax,%ecx
  802022:	2b 4c 24 10          	sub    0x10(%esp),%ecx
  802026:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  80202a:	eb bb                	jmp    801fe7 <__umoddi3+0x137>
  80202c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802030:	3b 44 24 18          	cmp    0x18(%esp),%eax
  802034:	0f 82 e8 fe ff ff    	jb     801f22 <__umoddi3+0x72>
  80203a:	e9 f3 fe ff ff       	jmp    801f32 <__umoddi3+0x82>
