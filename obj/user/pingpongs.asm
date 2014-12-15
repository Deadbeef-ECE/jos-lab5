
obj/user/pingpongs.debug:     file format elf32-i386


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
  80002c:	e8 1b 01 00 00       	call   80014c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	90                   	nop

00800034 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 4c             	sub    $0x4c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003d:	e8 14 13 00 00       	call   801356 <sfork>
  800042:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800045:	85 c0                	test   %eax,%eax
  800047:	74 5e                	je     8000a7 <umain+0x73>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800049:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  80004f:	e8 63 0d 00 00       	call   800db7 <sys_getenvid>
  800054:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800058:	89 44 24 04          	mov    %eax,0x4(%esp)
  80005c:	c7 04 24 60 20 80 00 	movl   $0x802060,(%esp)
  800063:	e8 f3 01 00 00       	call   80025b <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800068:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80006b:	e8 47 0d 00 00       	call   800db7 <sys_getenvid>
  800070:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800074:	89 44 24 04          	mov    %eax,0x4(%esp)
  800078:	c7 04 24 7a 20 80 00 	movl   $0x80207a,(%esp)
  80007f:	e8 d7 01 00 00       	call   80025b <cprintf>
		ipc_send(who, 0, 0, 0);
  800084:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80008b:	00 
  80008c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800093:	00 
  800094:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80009b:	00 
  80009c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80009f:	89 04 24             	mov    %eax,(%esp)
  8000a2:	e8 29 13 00 00       	call   8013d0 <ipc_send>
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  8000a7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000ae:	00 
  8000af:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b6:	00 
  8000b7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8000ba:	89 04 24             	mov    %eax,(%esp)
  8000bd:	e8 b6 12 00 00       	call   801378 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  8000c2:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  8000c8:	8b 7b 48             	mov    0x48(%ebx),%edi
  8000cb:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000ce:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8000d4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8000d7:	e8 db 0c 00 00       	call   800db7 <sys_getenvid>
  8000dc:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8000e0:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8000e4:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8000e8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8000eb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000f3:	c7 04 24 90 20 80 00 	movl   $0x802090,(%esp)
  8000fa:	e8 5c 01 00 00       	call   80025b <cprintf>
		if (val == 10)
  8000ff:	a1 04 40 80 00       	mov    0x804004,%eax
  800104:	83 f8 0a             	cmp    $0xa,%eax
  800107:	74 38                	je     800141 <umain+0x10d>
			return;
		++val;
  800109:	83 c0 01             	add    $0x1,%eax
  80010c:	a3 04 40 80 00       	mov    %eax,0x804004
		ipc_send(who, 0, 0, 0);
  800111:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800118:	00 
  800119:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800120:	00 
  800121:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800128:	00 
  800129:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80012c:	89 04 24             	mov    %eax,(%esp)
  80012f:	e8 9c 12 00 00       	call   8013d0 <ipc_send>
		if (val == 10)
  800134:	83 3d 04 40 80 00 0a 	cmpl   $0xa,0x804004
  80013b:	0f 85 66 ff ff ff    	jne    8000a7 <umain+0x73>
			return;
	}

}
  800141:	83 c4 4c             	add    $0x4c,%esp
  800144:	5b                   	pop    %ebx
  800145:	5e                   	pop    %esi
  800146:	5f                   	pop    %edi
  800147:	5d                   	pop    %ebp
  800148:	c3                   	ret    
  800149:	66 90                	xchg   %ax,%ax
  80014b:	90                   	nop

0080014c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	83 ec 18             	sub    $0x18,%esp
  800152:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800155:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800158:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80015b:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;

	thisenv = &envs[ENVX(sys_getenvid())];
  80015e:	e8 54 0c 00 00       	call   800db7 <sys_getenvid>
  800163:	25 ff 03 00 00       	and    $0x3ff,%eax
  800168:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80016b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800170:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800175:	85 db                	test   %ebx,%ebx
  800177:	7e 07                	jle    800180 <libmain+0x34>
		binaryname = argv[0];
  800179:	8b 06                	mov    (%esi),%eax
  80017b:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800180:	89 74 24 04          	mov    %esi,0x4(%esp)
  800184:	89 1c 24             	mov    %ebx,(%esp)
  800187:	e8 a8 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80018c:	e8 0b 00 00 00       	call   80019c <exit>
}
  800191:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800194:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800197:	89 ec                	mov    %ebp,%esp
  800199:	5d                   	pop    %ebp
  80019a:	c3                   	ret    
  80019b:	90                   	nop

0080019c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80019c:	55                   	push   %ebp
  80019d:	89 e5                	mov    %esp,%ebp
  80019f:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8001a2:	e8 ec 14 00 00       	call   801693 <close_all>
	sys_env_destroy(0);
  8001a7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001ae:	e8 9e 0b 00 00       	call   800d51 <sys_env_destroy>
}
  8001b3:	c9                   	leave  
  8001b4:	c3                   	ret    
  8001b5:	66 90                	xchg   %ax,%ax
  8001b7:	90                   	nop

008001b8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	53                   	push   %ebx
  8001bc:	83 ec 14             	sub    $0x14,%esp
  8001bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001c2:	8b 03                	mov    (%ebx),%eax
  8001c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001cb:	83 c0 01             	add    $0x1,%eax
  8001ce:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001d0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001d5:	75 19                	jne    8001f0 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001d7:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001de:	00 
  8001df:	8d 43 08             	lea    0x8(%ebx),%eax
  8001e2:	89 04 24             	mov    %eax,(%esp)
  8001e5:	e8 f6 0a 00 00       	call   800ce0 <sys_cputs>
		b->idx = 0;
  8001ea:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001f0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001f4:	83 c4 14             	add    $0x14,%esp
  8001f7:	5b                   	pop    %ebx
  8001f8:	5d                   	pop    %ebp
  8001f9:	c3                   	ret    

008001fa <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001fa:	55                   	push   %ebp
  8001fb:	89 e5                	mov    %esp,%ebp
  8001fd:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800203:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80020a:	00 00 00 
	b.cnt = 0;
  80020d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800214:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800217:	8b 45 0c             	mov    0xc(%ebp),%eax
  80021a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80021e:	8b 45 08             	mov    0x8(%ebp),%eax
  800221:	89 44 24 08          	mov    %eax,0x8(%esp)
  800225:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80022b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022f:	c7 04 24 b8 01 80 00 	movl   $0x8001b8,(%esp)
  800236:	e8 b7 01 00 00       	call   8003f2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80023b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800241:	89 44 24 04          	mov    %eax,0x4(%esp)
  800245:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80024b:	89 04 24             	mov    %eax,(%esp)
  80024e:	e8 8d 0a 00 00       	call   800ce0 <sys_cputs>

	return b.cnt;
}
  800253:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800259:	c9                   	leave  
  80025a:	c3                   	ret    

0080025b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80025b:	55                   	push   %ebp
  80025c:	89 e5                	mov    %esp,%ebp
  80025e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800261:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800264:	89 44 24 04          	mov    %eax,0x4(%esp)
  800268:	8b 45 08             	mov    0x8(%ebp),%eax
  80026b:	89 04 24             	mov    %eax,(%esp)
  80026e:	e8 87 ff ff ff       	call   8001fa <vcprintf>
	va_end(ap);

	return cnt;
}
  800273:	c9                   	leave  
  800274:	c3                   	ret    
  800275:	66 90                	xchg   %ax,%ax
  800277:	66 90                	xchg   %ax,%ax
  800279:	66 90                	xchg   %ax,%ax
  80027b:	66 90                	xchg   %ax,%ax
  80027d:	66 90                	xchg   %ax,%ax
  80027f:	90                   	nop

00800280 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	57                   	push   %edi
  800284:	56                   	push   %esi
  800285:	53                   	push   %ebx
  800286:	83 ec 4c             	sub    $0x4c,%esp
  800289:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80028c:	89 d7                	mov    %edx,%edi
  80028e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800291:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800294:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800297:	89 5d dc             	mov    %ebx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80029a:	b8 00 00 00 00       	mov    $0x0,%eax
  80029f:	39 d8                	cmp    %ebx,%eax
  8002a1:	72 17                	jb     8002ba <printnum+0x3a>
  8002a3:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8002a6:	39 5d 10             	cmp    %ebx,0x10(%ebp)
  8002a9:	76 0f                	jbe    8002ba <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002ab:	8b 75 14             	mov    0x14(%ebp),%esi
  8002ae:	83 ee 01             	sub    $0x1,%esi
  8002b1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8002b4:	85 f6                	test   %esi,%esi
  8002b6:	7f 63                	jg     80031b <printnum+0x9b>
  8002b8:	eb 75                	jmp    80032f <printnum+0xaf>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002ba:	8b 5d 18             	mov    0x18(%ebp),%ebx
  8002bd:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8002c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8002c4:	83 e8 01             	sub    $0x1,%eax
  8002c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002cb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002d2:	8b 44 24 08          	mov    0x8(%esp),%eax
  8002d6:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002da:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002dd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8002e0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002e7:	00 
  8002e8:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8002eb:	89 1c 24             	mov    %ebx,(%esp)
  8002ee:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002f1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002f5:	e8 86 1a 00 00       	call   801d80 <__udivdi3>
  8002fa:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8002fd:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800300:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800304:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800308:	89 04 24             	mov    %eax,(%esp)
  80030b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80030f:	89 fa                	mov    %edi,%edx
  800311:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800314:	e8 67 ff ff ff       	call   800280 <printnum>
  800319:	eb 14                	jmp    80032f <printnum+0xaf>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80031b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80031f:	8b 45 18             	mov    0x18(%ebp),%eax
  800322:	89 04 24             	mov    %eax,(%esp)
  800325:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800327:	83 ee 01             	sub    $0x1,%esi
  80032a:	75 ef                	jne    80031b <printnum+0x9b>
  80032c:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80032f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800333:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800337:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80033a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80033e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800345:	00 
  800346:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800349:	89 1c 24             	mov    %ebx,(%esp)
  80034c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80034f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800353:	e8 78 1b 00 00       	call   801ed0 <__umoddi3>
  800358:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80035c:	0f be 80 c0 20 80 00 	movsbl 0x8020c0(%eax),%eax
  800363:	89 04 24             	mov    %eax,(%esp)
  800366:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800369:	ff d0                	call   *%eax
}
  80036b:	83 c4 4c             	add    $0x4c,%esp
  80036e:	5b                   	pop    %ebx
  80036f:	5e                   	pop    %esi
  800370:	5f                   	pop    %edi
  800371:	5d                   	pop    %ebp
  800372:	c3                   	ret    

00800373 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800373:	55                   	push   %ebp
  800374:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800376:	83 fa 01             	cmp    $0x1,%edx
  800379:	7e 0e                	jle    800389 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80037b:	8b 10                	mov    (%eax),%edx
  80037d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800380:	89 08                	mov    %ecx,(%eax)
  800382:	8b 02                	mov    (%edx),%eax
  800384:	8b 52 04             	mov    0x4(%edx),%edx
  800387:	eb 22                	jmp    8003ab <getuint+0x38>
	else if (lflag)
  800389:	85 d2                	test   %edx,%edx
  80038b:	74 10                	je     80039d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80038d:	8b 10                	mov    (%eax),%edx
  80038f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800392:	89 08                	mov    %ecx,(%eax)
  800394:	8b 02                	mov    (%edx),%eax
  800396:	ba 00 00 00 00       	mov    $0x0,%edx
  80039b:	eb 0e                	jmp    8003ab <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80039d:	8b 10                	mov    (%eax),%edx
  80039f:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a2:	89 08                	mov    %ecx,(%eax)
  8003a4:	8b 02                	mov    (%edx),%eax
  8003a6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003ab:	5d                   	pop    %ebp
  8003ac:	c3                   	ret    

008003ad <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003ad:	55                   	push   %ebp
  8003ae:	89 e5                	mov    %esp,%ebp
  8003b0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003b3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003b7:	8b 10                	mov    (%eax),%edx
  8003b9:	3b 50 04             	cmp    0x4(%eax),%edx
  8003bc:	73 0a                	jae    8003c8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003be:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003c1:	88 0a                	mov    %cl,(%edx)
  8003c3:	83 c2 01             	add    $0x1,%edx
  8003c6:	89 10                	mov    %edx,(%eax)
}
  8003c8:	5d                   	pop    %ebp
  8003c9:	c3                   	ret    

008003ca <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
  8003cd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003d0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003d7:	8b 45 10             	mov    0x10(%ebp),%eax
  8003da:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e8:	89 04 24             	mov    %eax,(%esp)
  8003eb:	e8 02 00 00 00       	call   8003f2 <vprintfmt>
	va_end(ap);
}
  8003f0:	c9                   	leave  
  8003f1:	c3                   	ret    

008003f2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003f2:	55                   	push   %ebp
  8003f3:	89 e5                	mov    %esp,%ebp
  8003f5:	57                   	push   %edi
  8003f6:	56                   	push   %esi
  8003f7:	53                   	push   %ebx
  8003f8:	83 ec 4c             	sub    $0x4c,%esp
  8003fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8003fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800401:	8b 7d 10             	mov    0x10(%ebp),%edi
  800404:	eb 11                	jmp    800417 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800406:	85 c0                	test   %eax,%eax
  800408:	0f 84 db 03 00 00    	je     8007e9 <vprintfmt+0x3f7>
				return;
			putch(ch, putdat);
  80040e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800412:	89 04 24             	mov    %eax,(%esp)
  800415:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800417:	0f b6 07             	movzbl (%edi),%eax
  80041a:	83 c7 01             	add    $0x1,%edi
  80041d:	83 f8 25             	cmp    $0x25,%eax
  800420:	75 e4                	jne    800406 <vprintfmt+0x14>
  800422:	c6 45 e4 20          	movb   $0x20,-0x1c(%ebp)
  800426:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80042d:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800434:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80043b:	ba 00 00 00 00       	mov    $0x0,%edx
  800440:	eb 2b                	jmp    80046d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800442:	8b 7d e0             	mov    -0x20(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800445:	c6 45 e4 2d          	movb   $0x2d,-0x1c(%ebp)
  800449:	eb 22                	jmp    80046d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044b:	8b 7d e0             	mov    -0x20(%ebp),%edi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80044e:	c6 45 e4 30          	movb   $0x30,-0x1c(%ebp)
  800452:	eb 19                	jmp    80046d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800454:	8b 7d e0             	mov    -0x20(%ebp),%edi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800457:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80045e:	eb 0d                	jmp    80046d <vprintfmt+0x7b>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800460:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800463:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800466:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046d:	0f b6 0f             	movzbl (%edi),%ecx
  800470:	8d 47 01             	lea    0x1(%edi),%eax
  800473:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800476:	0f b6 07             	movzbl (%edi),%eax
  800479:	83 e8 23             	sub    $0x23,%eax
  80047c:	3c 55                	cmp    $0x55,%al
  80047e:	0f 87 40 03 00 00    	ja     8007c4 <vprintfmt+0x3d2>
  800484:	0f b6 c0             	movzbl %al,%eax
  800487:	ff 24 85 00 22 80 00 	jmp    *0x802200(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80048e:	83 e9 30             	sub    $0x30,%ecx
  800491:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				ch = *fmt;
  800494:	0f be 47 01          	movsbl 0x1(%edi),%eax
				if (ch < '0' || ch > '9')
  800498:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80049b:	83 f9 09             	cmp    $0x9,%ecx
  80049e:	77 57                	ja     8004f7 <vprintfmt+0x105>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a0:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8004a3:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004a6:	8b 55 dc             	mov    -0x24(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004a9:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8004ac:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8004af:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8004b3:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8004b6:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8004b9:	83 f9 09             	cmp    $0x9,%ecx
  8004bc:	76 eb                	jbe    8004a9 <vprintfmt+0xb7>
  8004be:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004c1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004c4:	eb 34                	jmp    8004fa <vprintfmt+0x108>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c9:	8d 48 04             	lea    0x4(%eax),%ecx
  8004cc:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004cf:	8b 00                	mov    (%eax),%eax
  8004d1:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d4:	8b 7d e0             	mov    -0x20(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004d7:	eb 21                	jmp    8004fa <vprintfmt+0x108>

		case '.':
			if (width < 0)
  8004d9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004dd:	0f 88 71 ff ff ff    	js     800454 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e3:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8004e6:	eb 85                	jmp    80046d <vprintfmt+0x7b>
  8004e8:	8b 7d e0             	mov    -0x20(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004eb:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  8004f2:	e9 76 ff ff ff       	jmp    80046d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f7:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8004fa:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004fe:	0f 89 69 ff ff ff    	jns    80046d <vprintfmt+0x7b>
  800504:	e9 57 ff ff ff       	jmp    800460 <vprintfmt+0x6e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800509:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80050f:	e9 59 ff ff ff       	jmp    80046d <vprintfmt+0x7b>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800514:	8b 45 14             	mov    0x14(%ebp),%eax
  800517:	8d 50 04             	lea    0x4(%eax),%edx
  80051a:	89 55 14             	mov    %edx,0x14(%ebp)
  80051d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800521:	8b 00                	mov    (%eax),%eax
  800523:	89 04 24             	mov    %eax,(%esp)
  800526:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800528:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80052b:	e9 e7 fe ff ff       	jmp    800417 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800530:	8b 45 14             	mov    0x14(%ebp),%eax
  800533:	8d 50 04             	lea    0x4(%eax),%edx
  800536:	89 55 14             	mov    %edx,0x14(%ebp)
  800539:	8b 00                	mov    (%eax),%eax
  80053b:	89 c2                	mov    %eax,%edx
  80053d:	c1 fa 1f             	sar    $0x1f,%edx
  800540:	31 d0                	xor    %edx,%eax
  800542:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800544:	83 f8 0f             	cmp    $0xf,%eax
  800547:	7f 0b                	jg     800554 <vprintfmt+0x162>
  800549:	8b 14 85 60 23 80 00 	mov    0x802360(,%eax,4),%edx
  800550:	85 d2                	test   %edx,%edx
  800552:	75 20                	jne    800574 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  800554:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800558:	c7 44 24 08 d8 20 80 	movl   $0x8020d8,0x8(%esp)
  80055f:	00 
  800560:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800564:	89 34 24             	mov    %esi,(%esp)
  800567:	e8 5e fe ff ff       	call   8003ca <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056c:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80056f:	e9 a3 fe ff ff       	jmp    800417 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800574:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800578:	c7 44 24 08 e1 20 80 	movl   $0x8020e1,0x8(%esp)
  80057f:	00 
  800580:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800584:	89 34 24             	mov    %esi,(%esp)
  800587:	e8 3e fe ff ff       	call   8003ca <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058c:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80058f:	e9 83 fe ff ff       	jmp    800417 <vprintfmt+0x25>
  800594:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800597:	8b 7d d8             	mov    -0x28(%ebp),%edi
  80059a:	89 7d cc             	mov    %edi,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80059d:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a0:	8d 50 04             	lea    0x4(%eax),%edx
  8005a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005a8:	85 ff                	test   %edi,%edi
  8005aa:	b8 d1 20 80 00       	mov    $0x8020d1,%eax
  8005af:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005b2:	80 7d e4 2d          	cmpb   $0x2d,-0x1c(%ebp)
  8005b6:	74 06                	je     8005be <vprintfmt+0x1cc>
  8005b8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8005bc:	7f 16                	jg     8005d4 <vprintfmt+0x1e2>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005be:	0f b6 17             	movzbl (%edi),%edx
  8005c1:	0f be c2             	movsbl %dl,%eax
  8005c4:	83 c7 01             	add    $0x1,%edi
  8005c7:	85 c0                	test   %eax,%eax
  8005c9:	0f 85 9f 00 00 00    	jne    80066e <vprintfmt+0x27c>
  8005cf:	e9 8b 00 00 00       	jmp    80065f <vprintfmt+0x26d>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005d8:	89 3c 24             	mov    %edi,(%esp)
  8005db:	e8 c2 02 00 00       	call   8008a2 <strnlen>
  8005e0:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8005e3:	29 c2                	sub    %eax,%edx
  8005e5:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8005e8:	85 d2                	test   %edx,%edx
  8005ea:	7e d2                	jle    8005be <vprintfmt+0x1cc>
					putch(padc, putdat);
  8005ec:	0f be 4d e4          	movsbl -0x1c(%ebp),%ecx
  8005f0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8005f3:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8005f6:	89 d7                	mov    %edx,%edi
  8005f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005ff:	89 04 24             	mov    %eax,(%esp)
  800602:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800604:	83 ef 01             	sub    $0x1,%edi
  800607:	75 ef                	jne    8005f8 <vprintfmt+0x206>
  800609:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80060c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80060f:	eb ad                	jmp    8005be <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800611:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800615:	74 20                	je     800637 <vprintfmt+0x245>
  800617:	0f be d2             	movsbl %dl,%edx
  80061a:	83 ea 20             	sub    $0x20,%edx
  80061d:	83 fa 5e             	cmp    $0x5e,%edx
  800620:	76 15                	jbe    800637 <vprintfmt+0x245>
					putch('?', putdat);
  800622:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800625:	89 54 24 04          	mov    %edx,0x4(%esp)
  800629:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800630:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800633:	ff d1                	call   *%ecx
  800635:	eb 0f                	jmp    800646 <vprintfmt+0x254>
				else
					putch(ch, putdat);
  800637:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80063a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80063e:	89 04 24             	mov    %eax,(%esp)
  800641:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800644:	ff d1                	call   *%ecx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800646:	83 eb 01             	sub    $0x1,%ebx
  800649:	0f b6 17             	movzbl (%edi),%edx
  80064c:	0f be c2             	movsbl %dl,%eax
  80064f:	83 c7 01             	add    $0x1,%edi
  800652:	85 c0                	test   %eax,%eax
  800654:	75 24                	jne    80067a <vprintfmt+0x288>
  800656:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800659:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80065c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065f:	8b 7d e0             	mov    -0x20(%ebp),%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800662:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800666:	0f 8e ab fd ff ff    	jle    800417 <vprintfmt+0x25>
  80066c:	eb 20                	jmp    80068e <vprintfmt+0x29c>
  80066e:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800671:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800674:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  800677:	8b 5d d8             	mov    -0x28(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80067a:	85 f6                	test   %esi,%esi
  80067c:	78 93                	js     800611 <vprintfmt+0x21f>
  80067e:	83 ee 01             	sub    $0x1,%esi
  800681:	79 8e                	jns    800611 <vprintfmt+0x21f>
  800683:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800686:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800689:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80068c:	eb d1                	jmp    80065f <vprintfmt+0x26d>
  80068e:	8b 7d d8             	mov    -0x28(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800691:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800695:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80069c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80069e:	83 ef 01             	sub    $0x1,%edi
  8006a1:	75 ee                	jne    800691 <vprintfmt+0x29f>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a3:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8006a6:	e9 6c fd ff ff       	jmp    800417 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006ab:	83 fa 01             	cmp    $0x1,%edx
  8006ae:	66 90                	xchg   %ax,%ax
  8006b0:	7e 16                	jle    8006c8 <vprintfmt+0x2d6>
		return va_arg(*ap, long long);
  8006b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b5:	8d 50 08             	lea    0x8(%eax),%edx
  8006b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006bb:	8b 10                	mov    (%eax),%edx
  8006bd:	8b 48 04             	mov    0x4(%eax),%ecx
  8006c0:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8006c3:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8006c6:	eb 32                	jmp    8006fa <vprintfmt+0x308>
	else if (lflag)
  8006c8:	85 d2                	test   %edx,%edx
  8006ca:	74 18                	je     8006e4 <vprintfmt+0x2f2>
		return va_arg(*ap, long);
  8006cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cf:	8d 50 04             	lea    0x4(%eax),%edx
  8006d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d5:	8b 00                	mov    (%eax),%eax
  8006d7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006da:	89 c1                	mov    %eax,%ecx
  8006dc:	c1 f9 1f             	sar    $0x1f,%ecx
  8006df:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8006e2:	eb 16                	jmp    8006fa <vprintfmt+0x308>
	else
		return va_arg(*ap, int);
  8006e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e7:	8d 50 04             	lea    0x4(%eax),%edx
  8006ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ed:	8b 00                	mov    (%eax),%eax
  8006ef:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006f2:	89 c7                	mov    %eax,%edi
  8006f4:	c1 ff 1f             	sar    $0x1f,%edi
  8006f7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006fa:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8006fd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800700:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800705:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800709:	79 7d                	jns    800788 <vprintfmt+0x396>
				putch('-', putdat);
  80070b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80070f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800716:	ff d6                	call   *%esi
				num = -(long long) num;
  800718:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80071b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80071e:	f7 d8                	neg    %eax
  800720:	83 d2 00             	adc    $0x0,%edx
  800723:	f7 da                	neg    %edx
			}
			base = 10;
  800725:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80072a:	eb 5c                	jmp    800788 <vprintfmt+0x396>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80072c:	8d 45 14             	lea    0x14(%ebp),%eax
  80072f:	e8 3f fc ff ff       	call   800373 <getuint>
			base = 10;
  800734:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800739:	eb 4d                	jmp    800788 <vprintfmt+0x396>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80073b:	8d 45 14             	lea    0x14(%ebp),%eax
  80073e:	e8 30 fc ff ff       	call   800373 <getuint>
			base = 8;
  800743:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800748:	eb 3e                	jmp    800788 <vprintfmt+0x396>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80074a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80074e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800755:	ff d6                	call   *%esi
			putch('x', putdat);
  800757:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80075b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800762:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800764:	8b 45 14             	mov    0x14(%ebp),%eax
  800767:	8d 50 04             	lea    0x4(%eax),%edx
  80076a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80076d:	8b 00                	mov    (%eax),%eax
  80076f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800774:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800779:	eb 0d                	jmp    800788 <vprintfmt+0x396>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80077b:	8d 45 14             	lea    0x14(%ebp),%eax
  80077e:	e8 f0 fb ff ff       	call   800373 <getuint>
			base = 16;
  800783:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800788:	0f be 7d e4          	movsbl -0x1c(%ebp),%edi
  80078c:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800790:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800793:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800797:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80079b:	89 04 24             	mov    %eax,(%esp)
  80079e:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007a2:	89 da                	mov    %ebx,%edx
  8007a4:	89 f0                	mov    %esi,%eax
  8007a6:	e8 d5 fa ff ff       	call   800280 <printnum>
			break;
  8007ab:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8007ae:	e9 64 fc ff ff       	jmp    800417 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007b3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007b7:	89 0c 24             	mov    %ecx,(%esp)
  8007ba:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007bc:	8b 7d e0             	mov    -0x20(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007bf:	e9 53 fc ff ff       	jmp    800417 <vprintfmt+0x25>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007c8:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007cf:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007d1:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007d5:	0f 84 3c fc ff ff    	je     800417 <vprintfmt+0x25>
  8007db:	83 ef 01             	sub    $0x1,%edi
  8007de:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007e2:	75 f7                	jne    8007db <vprintfmt+0x3e9>
  8007e4:	e9 2e fc ff ff       	jmp    800417 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8007e9:	83 c4 4c             	add    $0x4c,%esp
  8007ec:	5b                   	pop    %ebx
  8007ed:	5e                   	pop    %esi
  8007ee:	5f                   	pop    %edi
  8007ef:	5d                   	pop    %ebp
  8007f0:	c3                   	ret    

008007f1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007f1:	55                   	push   %ebp
  8007f2:	89 e5                	mov    %esp,%ebp
  8007f4:	83 ec 28             	sub    $0x28,%esp
  8007f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fa:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007fd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800800:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800804:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800807:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80080e:	85 d2                	test   %edx,%edx
  800810:	7e 30                	jle    800842 <vsnprintf+0x51>
  800812:	85 c0                	test   %eax,%eax
  800814:	74 2c                	je     800842 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800816:	8b 45 14             	mov    0x14(%ebp),%eax
  800819:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80081d:	8b 45 10             	mov    0x10(%ebp),%eax
  800820:	89 44 24 08          	mov    %eax,0x8(%esp)
  800824:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800827:	89 44 24 04          	mov    %eax,0x4(%esp)
  80082b:	c7 04 24 ad 03 80 00 	movl   $0x8003ad,(%esp)
  800832:	e8 bb fb ff ff       	call   8003f2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800837:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80083a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80083d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800840:	eb 05                	jmp    800847 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800842:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800847:	c9                   	leave  
  800848:	c3                   	ret    

00800849 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800849:	55                   	push   %ebp
  80084a:	89 e5                	mov    %esp,%ebp
  80084c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80084f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800852:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800856:	8b 45 10             	mov    0x10(%ebp),%eax
  800859:	89 44 24 08          	mov    %eax,0x8(%esp)
  80085d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800860:	89 44 24 04          	mov    %eax,0x4(%esp)
  800864:	8b 45 08             	mov    0x8(%ebp),%eax
  800867:	89 04 24             	mov    %eax,(%esp)
  80086a:	e8 82 ff ff ff       	call   8007f1 <vsnprintf>
	va_end(ap);

	return rc;
}
  80086f:	c9                   	leave  
  800870:	c3                   	ret    
  800871:	66 90                	xchg   %ax,%ax
  800873:	66 90                	xchg   %ax,%ax
  800875:	66 90                	xchg   %ax,%ax
  800877:	66 90                	xchg   %ax,%ax
  800879:	66 90                	xchg   %ax,%ax
  80087b:	66 90                	xchg   %ax,%ax
  80087d:	66 90                	xchg   %ax,%ax
  80087f:	90                   	nop

00800880 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800886:	80 3a 00             	cmpb   $0x0,(%edx)
  800889:	74 10                	je     80089b <strlen+0x1b>
  80088b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800890:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800893:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800897:	75 f7                	jne    800890 <strlen+0x10>
  800899:	eb 05                	jmp    8008a0 <strlen+0x20>
  80089b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8008a0:	5d                   	pop    %ebp
  8008a1:	c3                   	ret    

008008a2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	53                   	push   %ebx
  8008a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008ac:	85 c9                	test   %ecx,%ecx
  8008ae:	74 1c                	je     8008cc <strnlen+0x2a>
  8008b0:	80 3b 00             	cmpb   $0x0,(%ebx)
  8008b3:	74 1e                	je     8008d3 <strnlen+0x31>
  8008b5:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8008ba:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008bc:	39 ca                	cmp    %ecx,%edx
  8008be:	74 18                	je     8008d8 <strnlen+0x36>
  8008c0:	83 c2 01             	add    $0x1,%edx
  8008c3:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8008c8:	75 f0                	jne    8008ba <strnlen+0x18>
  8008ca:	eb 0c                	jmp    8008d8 <strnlen+0x36>
  8008cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d1:	eb 05                	jmp    8008d8 <strnlen+0x36>
  8008d3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8008d8:	5b                   	pop    %ebx
  8008d9:	5d                   	pop    %ebp
  8008da:	c3                   	ret    

008008db <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	53                   	push   %ebx
  8008df:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008e5:	89 c2                	mov    %eax,%edx
  8008e7:	0f b6 19             	movzbl (%ecx),%ebx
  8008ea:	88 1a                	mov    %bl,(%edx)
  8008ec:	83 c2 01             	add    $0x1,%edx
  8008ef:	83 c1 01             	add    $0x1,%ecx
  8008f2:	84 db                	test   %bl,%bl
  8008f4:	75 f1                	jne    8008e7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008f6:	5b                   	pop    %ebx
  8008f7:	5d                   	pop    %ebp
  8008f8:	c3                   	ret    

008008f9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008f9:	55                   	push   %ebp
  8008fa:	89 e5                	mov    %esp,%ebp
  8008fc:	53                   	push   %ebx
  8008fd:	83 ec 08             	sub    $0x8,%esp
  800900:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800903:	89 1c 24             	mov    %ebx,(%esp)
  800906:	e8 75 ff ff ff       	call   800880 <strlen>
	strcpy(dst + len, src);
  80090b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80090e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800912:	01 d8                	add    %ebx,%eax
  800914:	89 04 24             	mov    %eax,(%esp)
  800917:	e8 bf ff ff ff       	call   8008db <strcpy>
	return dst;
}
  80091c:	89 d8                	mov    %ebx,%eax
  80091e:	83 c4 08             	add    $0x8,%esp
  800921:	5b                   	pop    %ebx
  800922:	5d                   	pop    %ebp
  800923:	c3                   	ret    

00800924 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800924:	55                   	push   %ebp
  800925:	89 e5                	mov    %esp,%ebp
  800927:	56                   	push   %esi
  800928:	53                   	push   %ebx
  800929:	8b 75 08             	mov    0x8(%ebp),%esi
  80092c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80092f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800932:	85 db                	test   %ebx,%ebx
  800934:	74 16                	je     80094c <strncpy+0x28>
	strcpy(dst + len, src);
	return dst;
}

char *
strncpy(char *dst, const char *src, size_t size) {
  800936:	01 f3                	add    %esi,%ebx
  800938:	89 f1                	mov    %esi,%ecx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  80093a:	0f b6 02             	movzbl (%edx),%eax
  80093d:	88 01                	mov    %al,(%ecx)
  80093f:	83 c1 01             	add    $0x1,%ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800942:	80 3a 01             	cmpb   $0x1,(%edx)
  800945:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800948:	39 d9                	cmp    %ebx,%ecx
  80094a:	75 ee                	jne    80093a <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80094c:	89 f0                	mov    %esi,%eax
  80094e:	5b                   	pop    %ebx
  80094f:	5e                   	pop    %esi
  800950:	5d                   	pop    %ebp
  800951:	c3                   	ret    

00800952 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800952:	55                   	push   %ebp
  800953:	89 e5                	mov    %esp,%ebp
  800955:	57                   	push   %edi
  800956:	56                   	push   %esi
  800957:	53                   	push   %ebx
  800958:	8b 7d 08             	mov    0x8(%ebp),%edi
  80095b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80095e:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800961:	89 f8                	mov    %edi,%eax
  800963:	85 f6                	test   %esi,%esi
  800965:	74 33                	je     80099a <strlcpy+0x48>
		while (--size > 0 && *src != '\0')
  800967:	83 fe 01             	cmp    $0x1,%esi
  80096a:	74 25                	je     800991 <strlcpy+0x3f>
  80096c:	0f b6 0b             	movzbl (%ebx),%ecx
  80096f:	84 c9                	test   %cl,%cl
  800971:	74 22                	je     800995 <strlcpy+0x43>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800973:	83 ee 02             	sub    $0x2,%esi
  800976:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80097b:	88 08                	mov    %cl,(%eax)
  80097d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800980:	39 f2                	cmp    %esi,%edx
  800982:	74 13                	je     800997 <strlcpy+0x45>
  800984:	83 c2 01             	add    $0x1,%edx
  800987:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80098b:	84 c9                	test   %cl,%cl
  80098d:	75 ec                	jne    80097b <strlcpy+0x29>
  80098f:	eb 06                	jmp    800997 <strlcpy+0x45>
  800991:	89 f8                	mov    %edi,%eax
  800993:	eb 02                	jmp    800997 <strlcpy+0x45>
  800995:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800997:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80099a:	29 f8                	sub    %edi,%eax
}
  80099c:	5b                   	pop    %ebx
  80099d:	5e                   	pop    %esi
  80099e:	5f                   	pop    %edi
  80099f:	5d                   	pop    %ebp
  8009a0:	c3                   	ret    

008009a1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009aa:	0f b6 01             	movzbl (%ecx),%eax
  8009ad:	84 c0                	test   %al,%al
  8009af:	74 15                	je     8009c6 <strcmp+0x25>
  8009b1:	3a 02                	cmp    (%edx),%al
  8009b3:	75 11                	jne    8009c6 <strcmp+0x25>
		p++, q++;
  8009b5:	83 c1 01             	add    $0x1,%ecx
  8009b8:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009bb:	0f b6 01             	movzbl (%ecx),%eax
  8009be:	84 c0                	test   %al,%al
  8009c0:	74 04                	je     8009c6 <strcmp+0x25>
  8009c2:	3a 02                	cmp    (%edx),%al
  8009c4:	74 ef                	je     8009b5 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009c6:	0f b6 c0             	movzbl %al,%eax
  8009c9:	0f b6 12             	movzbl (%edx),%edx
  8009cc:	29 d0                	sub    %edx,%eax
}
  8009ce:	5d                   	pop    %ebp
  8009cf:	c3                   	ret    

008009d0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009d0:	55                   	push   %ebp
  8009d1:	89 e5                	mov    %esp,%ebp
  8009d3:	56                   	push   %esi
  8009d4:	53                   	push   %ebx
  8009d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009db:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  8009de:	85 f6                	test   %esi,%esi
  8009e0:	74 29                	je     800a0b <strncmp+0x3b>
  8009e2:	0f b6 03             	movzbl (%ebx),%eax
  8009e5:	84 c0                	test   %al,%al
  8009e7:	74 30                	je     800a19 <strncmp+0x49>
  8009e9:	3a 02                	cmp    (%edx),%al
  8009eb:	75 2c                	jne    800a19 <strncmp+0x49>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}

int
strncmp(const char *p, const char *q, size_t n)
  8009ed:	8d 43 01             	lea    0x1(%ebx),%eax
  8009f0:	01 de                	add    %ebx,%esi
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  8009f2:	89 c3                	mov    %eax,%ebx
  8009f4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009f7:	39 f0                	cmp    %esi,%eax
  8009f9:	74 17                	je     800a12 <strncmp+0x42>
  8009fb:	0f b6 08             	movzbl (%eax),%ecx
  8009fe:	84 c9                	test   %cl,%cl
  800a00:	74 17                	je     800a19 <strncmp+0x49>
  800a02:	83 c0 01             	add    $0x1,%eax
  800a05:	3a 0a                	cmp    (%edx),%cl
  800a07:	74 e9                	je     8009f2 <strncmp+0x22>
  800a09:	eb 0e                	jmp    800a19 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a0b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a10:	eb 0f                	jmp    800a21 <strncmp+0x51>
  800a12:	b8 00 00 00 00       	mov    $0x0,%eax
  800a17:	eb 08                	jmp    800a21 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a19:	0f b6 03             	movzbl (%ebx),%eax
  800a1c:	0f b6 12             	movzbl (%edx),%edx
  800a1f:	29 d0                	sub    %edx,%eax
}
  800a21:	5b                   	pop    %ebx
  800a22:	5e                   	pop    %esi
  800a23:	5d                   	pop    %ebp
  800a24:	c3                   	ret    

00800a25 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a25:	55                   	push   %ebp
  800a26:	89 e5                	mov    %esp,%ebp
  800a28:	53                   	push   %ebx
  800a29:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2c:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800a2f:	0f b6 18             	movzbl (%eax),%ebx
  800a32:	84 db                	test   %bl,%bl
  800a34:	74 1d                	je     800a53 <strchr+0x2e>
  800a36:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800a38:	38 d3                	cmp    %dl,%bl
  800a3a:	75 06                	jne    800a42 <strchr+0x1d>
  800a3c:	eb 1a                	jmp    800a58 <strchr+0x33>
  800a3e:	38 ca                	cmp    %cl,%dl
  800a40:	74 16                	je     800a58 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a42:	83 c0 01             	add    $0x1,%eax
  800a45:	0f b6 10             	movzbl (%eax),%edx
  800a48:	84 d2                	test   %dl,%dl
  800a4a:	75 f2                	jne    800a3e <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800a4c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a51:	eb 05                	jmp    800a58 <strchr+0x33>
  800a53:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a58:	5b                   	pop    %ebx
  800a59:	5d                   	pop    %ebp
  800a5a:	c3                   	ret    

00800a5b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	53                   	push   %ebx
  800a5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a62:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800a65:	0f b6 18             	movzbl (%eax),%ebx
  800a68:	84 db                	test   %bl,%bl
  800a6a:	74 16                	je     800a82 <strfind+0x27>
  800a6c:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800a6e:	38 d3                	cmp    %dl,%bl
  800a70:	75 06                	jne    800a78 <strfind+0x1d>
  800a72:	eb 0e                	jmp    800a82 <strfind+0x27>
  800a74:	38 ca                	cmp    %cl,%dl
  800a76:	74 0a                	je     800a82 <strfind+0x27>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a78:	83 c0 01             	add    $0x1,%eax
  800a7b:	0f b6 10             	movzbl (%eax),%edx
  800a7e:	84 d2                	test   %dl,%dl
  800a80:	75 f2                	jne    800a74 <strfind+0x19>
		if (*s == c)
			break;
	return (char *) s;
}
  800a82:	5b                   	pop    %ebx
  800a83:	5d                   	pop    %ebp
  800a84:	c3                   	ret    

00800a85 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a85:	55                   	push   %ebp
  800a86:	89 e5                	mov    %esp,%ebp
  800a88:	83 ec 0c             	sub    $0xc,%esp
  800a8b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800a8e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800a91:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800a94:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a97:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a9a:	85 c9                	test   %ecx,%ecx
  800a9c:	74 36                	je     800ad4 <memset+0x4f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a9e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aa4:	75 28                	jne    800ace <memset+0x49>
  800aa6:	f6 c1 03             	test   $0x3,%cl
  800aa9:	75 23                	jne    800ace <memset+0x49>
		c &= 0xFF;
  800aab:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800aaf:	89 d3                	mov    %edx,%ebx
  800ab1:	c1 e3 08             	shl    $0x8,%ebx
  800ab4:	89 d6                	mov    %edx,%esi
  800ab6:	c1 e6 18             	shl    $0x18,%esi
  800ab9:	89 d0                	mov    %edx,%eax
  800abb:	c1 e0 10             	shl    $0x10,%eax
  800abe:	09 f0                	or     %esi,%eax
  800ac0:	09 c2                	or     %eax,%edx
  800ac2:	89 d0                	mov    %edx,%eax
  800ac4:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ac6:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ac9:	fc                   	cld    
  800aca:	f3 ab                	rep stos %eax,%es:(%edi)
  800acc:	eb 06                	jmp    800ad4 <memset+0x4f>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ace:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad1:	fc                   	cld    
  800ad2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");

	return v;
}
  800ad4:	89 f8                	mov    %edi,%eax
  800ad6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ad9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800adc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800adf:	89 ec                	mov    %ebp,%esp
  800ae1:	5d                   	pop    %ebp
  800ae2:	c3                   	ret    

00800ae3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ae3:	55                   	push   %ebp
  800ae4:	89 e5                	mov    %esp,%ebp
  800ae6:	83 ec 08             	sub    $0x8,%esp
  800ae9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800aec:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800aef:	8b 45 08             	mov    0x8(%ebp),%eax
  800af2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800af5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800af8:	39 c6                	cmp    %eax,%esi
  800afa:	73 36                	jae    800b32 <memmove+0x4f>
  800afc:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800aff:	39 d0                	cmp    %edx,%eax
  800b01:	73 2f                	jae    800b32 <memmove+0x4f>
		s += n;
		d += n;
  800b03:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b06:	f6 c2 03             	test   $0x3,%dl
  800b09:	75 1b                	jne    800b26 <memmove+0x43>
  800b0b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b11:	75 13                	jne    800b26 <memmove+0x43>
  800b13:	f6 c1 03             	test   $0x3,%cl
  800b16:	75 0e                	jne    800b26 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b18:	83 ef 04             	sub    $0x4,%edi
  800b1b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b1e:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b21:	fd                   	std    
  800b22:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b24:	eb 09                	jmp    800b2f <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b26:	83 ef 01             	sub    $0x1,%edi
  800b29:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b2c:	fd                   	std    
  800b2d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b2f:	fc                   	cld    
  800b30:	eb 20                	jmp    800b52 <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b32:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b38:	75 13                	jne    800b4d <memmove+0x6a>
  800b3a:	a8 03                	test   $0x3,%al
  800b3c:	75 0f                	jne    800b4d <memmove+0x6a>
  800b3e:	f6 c1 03             	test   $0x3,%cl
  800b41:	75 0a                	jne    800b4d <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b43:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b46:	89 c7                	mov    %eax,%edi
  800b48:	fc                   	cld    
  800b49:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b4b:	eb 05                	jmp    800b52 <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b4d:	89 c7                	mov    %eax,%edi
  800b4f:	fc                   	cld    
  800b50:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b52:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b55:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b58:	89 ec                	mov    %ebp,%esp
  800b5a:	5d                   	pop    %ebp
  800b5b:	c3                   	ret    

00800b5c <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b62:	8b 45 10             	mov    0x10(%ebp),%eax
  800b65:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b69:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b6c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b70:	8b 45 08             	mov    0x8(%ebp),%eax
  800b73:	89 04 24             	mov    %eax,(%esp)
  800b76:	e8 68 ff ff ff       	call   800ae3 <memmove>
}
  800b7b:	c9                   	leave  
  800b7c:	c3                   	ret    

00800b7d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	57                   	push   %edi
  800b81:	56                   	push   %esi
  800b82:	53                   	push   %ebx
  800b83:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b86:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b89:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b8c:	8d 78 ff             	lea    -0x1(%eax),%edi
  800b8f:	85 c0                	test   %eax,%eax
  800b91:	74 36                	je     800bc9 <memcmp+0x4c>
		if (*s1 != *s2)
  800b93:	0f b6 03             	movzbl (%ebx),%eax
  800b96:	0f b6 0e             	movzbl (%esi),%ecx
  800b99:	38 c8                	cmp    %cl,%al
  800b9b:	75 17                	jne    800bb4 <memcmp+0x37>
  800b9d:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba2:	eb 1a                	jmp    800bbe <memcmp+0x41>
  800ba4:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800ba9:	83 c2 01             	add    $0x1,%edx
  800bac:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800bb0:	38 c8                	cmp    %cl,%al
  800bb2:	74 0a                	je     800bbe <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800bb4:	0f b6 c0             	movzbl %al,%eax
  800bb7:	0f b6 c9             	movzbl %cl,%ecx
  800bba:	29 c8                	sub    %ecx,%eax
  800bbc:	eb 10                	jmp    800bce <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bbe:	39 fa                	cmp    %edi,%edx
  800bc0:	75 e2                	jne    800ba4 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bc2:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc7:	eb 05                	jmp    800bce <memcmp+0x51>
  800bc9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bce:	5b                   	pop    %ebx
  800bcf:	5e                   	pop    %esi
  800bd0:	5f                   	pop    %edi
  800bd1:	5d                   	pop    %ebp
  800bd2:	c3                   	ret    

00800bd3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bd3:	55                   	push   %ebp
  800bd4:	89 e5                	mov    %esp,%ebp
  800bd6:	53                   	push   %ebx
  800bd7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bda:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800bdd:	89 c2                	mov    %eax,%edx
  800bdf:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800be2:	39 d0                	cmp    %edx,%eax
  800be4:	73 13                	jae    800bf9 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800be6:	89 d9                	mov    %ebx,%ecx
  800be8:	38 18                	cmp    %bl,(%eax)
  800bea:	75 06                	jne    800bf2 <memfind+0x1f>
  800bec:	eb 0b                	jmp    800bf9 <memfind+0x26>
  800bee:	38 08                	cmp    %cl,(%eax)
  800bf0:	74 07                	je     800bf9 <memfind+0x26>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bf2:	83 c0 01             	add    $0x1,%eax
  800bf5:	39 d0                	cmp    %edx,%eax
  800bf7:	75 f5                	jne    800bee <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bf9:	5b                   	pop    %ebx
  800bfa:	5d                   	pop    %ebp
  800bfb:	c3                   	ret    

00800bfc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	57                   	push   %edi
  800c00:	56                   	push   %esi
  800c01:	53                   	push   %ebx
  800c02:	83 ec 04             	sub    $0x4,%esp
  800c05:	8b 55 08             	mov    0x8(%ebp),%edx
  800c08:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c0b:	0f b6 02             	movzbl (%edx),%eax
  800c0e:	3c 09                	cmp    $0x9,%al
  800c10:	74 04                	je     800c16 <strtol+0x1a>
  800c12:	3c 20                	cmp    $0x20,%al
  800c14:	75 0e                	jne    800c24 <strtol+0x28>
		s++;
  800c16:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c19:	0f b6 02             	movzbl (%edx),%eax
  800c1c:	3c 09                	cmp    $0x9,%al
  800c1e:	74 f6                	je     800c16 <strtol+0x1a>
  800c20:	3c 20                	cmp    $0x20,%al
  800c22:	74 f2                	je     800c16 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c24:	3c 2b                	cmp    $0x2b,%al
  800c26:	75 0a                	jne    800c32 <strtol+0x36>
		s++;
  800c28:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c2b:	bf 00 00 00 00       	mov    $0x0,%edi
  800c30:	eb 10                	jmp    800c42 <strtol+0x46>
  800c32:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c37:	3c 2d                	cmp    $0x2d,%al
  800c39:	75 07                	jne    800c42 <strtol+0x46>
		s++, neg = 1;
  800c3b:	83 c2 01             	add    $0x1,%edx
  800c3e:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c42:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c48:	75 15                	jne    800c5f <strtol+0x63>
  800c4a:	80 3a 30             	cmpb   $0x30,(%edx)
  800c4d:	75 10                	jne    800c5f <strtol+0x63>
  800c4f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c53:	75 0a                	jne    800c5f <strtol+0x63>
		s += 2, base = 16;
  800c55:	83 c2 02             	add    $0x2,%edx
  800c58:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c5d:	eb 10                	jmp    800c6f <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800c5f:	85 db                	test   %ebx,%ebx
  800c61:	75 0c                	jne    800c6f <strtol+0x73>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c63:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c65:	80 3a 30             	cmpb   $0x30,(%edx)
  800c68:	75 05                	jne    800c6f <strtol+0x73>
		s++, base = 8;
  800c6a:	83 c2 01             	add    $0x1,%edx
  800c6d:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800c6f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c74:	89 5d f0             	mov    %ebx,-0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c77:	0f b6 0a             	movzbl (%edx),%ecx
  800c7a:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800c7d:	89 f3                	mov    %esi,%ebx
  800c7f:	80 fb 09             	cmp    $0x9,%bl
  800c82:	77 08                	ja     800c8c <strtol+0x90>
			dig = *s - '0';
  800c84:	0f be c9             	movsbl %cl,%ecx
  800c87:	83 e9 30             	sub    $0x30,%ecx
  800c8a:	eb 22                	jmp    800cae <strtol+0xb2>
		else if (*s >= 'a' && *s <= 'z')
  800c8c:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800c8f:	89 f3                	mov    %esi,%ebx
  800c91:	80 fb 19             	cmp    $0x19,%bl
  800c94:	77 08                	ja     800c9e <strtol+0xa2>
			dig = *s - 'a' + 10;
  800c96:	0f be c9             	movsbl %cl,%ecx
  800c99:	83 e9 57             	sub    $0x57,%ecx
  800c9c:	eb 10                	jmp    800cae <strtol+0xb2>
		else if (*s >= 'A' && *s <= 'Z')
  800c9e:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800ca1:	89 f3                	mov    %esi,%ebx
  800ca3:	80 fb 19             	cmp    $0x19,%bl
  800ca6:	77 16                	ja     800cbe <strtol+0xc2>
			dig = *s - 'A' + 10;
  800ca8:	0f be c9             	movsbl %cl,%ecx
  800cab:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800cae:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800cb1:	7d 0f                	jge    800cc2 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800cb3:	83 c2 01             	add    $0x1,%edx
  800cb6:	0f af 45 f0          	imul   -0x10(%ebp),%eax
  800cba:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800cbc:	eb b9                	jmp    800c77 <strtol+0x7b>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800cbe:	89 c1                	mov    %eax,%ecx
  800cc0:	eb 02                	jmp    800cc4 <strtol+0xc8>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800cc2:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800cc4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cc8:	74 05                	je     800ccf <strtol+0xd3>
		*endptr = (char *) s;
  800cca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ccd:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ccf:	89 ca                	mov    %ecx,%edx
  800cd1:	f7 da                	neg    %edx
  800cd3:	85 ff                	test   %edi,%edi
  800cd5:	0f 45 c2             	cmovne %edx,%eax
}
  800cd8:	83 c4 04             	add    $0x4,%esp
  800cdb:	5b                   	pop    %ebx
  800cdc:	5e                   	pop    %esi
  800cdd:	5f                   	pop    %edi
  800cde:	5d                   	pop    %ebp
  800cdf:	c3                   	ret    

00800ce0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ce0:	55                   	push   %ebp
  800ce1:	89 e5                	mov    %esp,%ebp
  800ce3:	83 ec 0c             	sub    $0xc,%esp
  800ce6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ce9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cec:	89 7d fc             	mov    %edi,-0x4(%ebp)
static inline uint32_t

get_cpu_features(void)
{
	uint32_t feature;
	__asm __volatile(" movl $1, %%eax\n\t"
  800cef:	b8 01 00 00 00       	mov    $0x1,%eax
  800cf4:	0f a2                	cpuid  
  800cf6:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf8:	b8 00 00 00 00       	mov    $0x0,%eax
  800cfd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d00:	8b 55 08             	mov    0x8(%ebp),%edx
  800d03:	89 c3                	mov    %eax,%ebx
  800d05:	89 c7                	mov    %eax,%edi
  800d07:	89 c6                	mov    %eax,%esi
  800d09:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d0b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d0e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d11:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d14:	89 ec                	mov    %ebp,%esp
  800d16:	5d                   	pop    %ebp
  800d17:	c3                   	ret    

00800d18 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d18:	55                   	push   %ebp
  800d19:	89 e5                	mov    %esp,%ebp
  800d1b:	83 ec 0c             	sub    $0xc,%esp
  800d1e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d21:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d24:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d27:	b8 01 00 00 00       	mov    $0x1,%eax
  800d2c:	0f a2                	cpuid  
  800d2e:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d30:	ba 00 00 00 00       	mov    $0x0,%edx
  800d35:	b8 01 00 00 00       	mov    $0x1,%eax
  800d3a:	89 d1                	mov    %edx,%ecx
  800d3c:	89 d3                	mov    %edx,%ebx
  800d3e:	89 d7                	mov    %edx,%edi
  800d40:	89 d6                	mov    %edx,%esi
  800d42:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d44:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d47:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d4a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d4d:	89 ec                	mov    %ebp,%esp
  800d4f:	5d                   	pop    %ebp
  800d50:	c3                   	ret    

00800d51 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d51:	55                   	push   %ebp
  800d52:	89 e5                	mov    %esp,%ebp
  800d54:	83 ec 38             	sub    $0x38,%esp
  800d57:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d5a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d5d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d60:	b8 01 00 00 00       	mov    $0x1,%eax
  800d65:	0f a2                	cpuid  
  800d67:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d69:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d6e:	b8 03 00 00 00       	mov    $0x3,%eax
  800d73:	8b 55 08             	mov    0x8(%ebp),%edx
  800d76:	89 cb                	mov    %ecx,%ebx
  800d78:	89 cf                	mov    %ecx,%edi
  800d7a:	89 ce                	mov    %ecx,%esi
  800d7c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d7e:	85 c0                	test   %eax,%eax
  800d80:	7e 28                	jle    800daa <sys_env_destroy+0x59>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d82:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d86:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800d8d:	00 
  800d8e:	c7 44 24 08 bf 23 80 	movl   $0x8023bf,0x8(%esp)
  800d95:	00 
  800d96:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800d9d:	00 
  800d9e:	c7 04 24 dc 23 80 00 	movl   $0x8023dc,(%esp)
  800da5:	e8 e6 0e 00 00       	call   801c90 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800daa:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dad:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800db0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800db3:	89 ec                	mov    %ebp,%esp
  800db5:	5d                   	pop    %ebp
  800db6:	c3                   	ret    

00800db7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800db7:	55                   	push   %ebp
  800db8:	89 e5                	mov    %esp,%ebp
  800dba:	83 ec 0c             	sub    $0xc,%esp
  800dbd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dc0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dc3:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800dc6:	b8 01 00 00 00       	mov    $0x1,%eax
  800dcb:	0f a2                	cpuid  
  800dcd:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcf:	ba 00 00 00 00       	mov    $0x0,%edx
  800dd4:	b8 02 00 00 00       	mov    $0x2,%eax
  800dd9:	89 d1                	mov    %edx,%ecx
  800ddb:	89 d3                	mov    %edx,%ebx
  800ddd:	89 d7                	mov    %edx,%edi
  800ddf:	89 d6                	mov    %edx,%esi
  800de1:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800de3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800de6:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800de9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dec:	89 ec                	mov    %ebp,%esp
  800dee:	5d                   	pop    %ebp
  800def:	c3                   	ret    

00800df0 <sys_yield>:

void
sys_yield(void)
{
  800df0:	55                   	push   %ebp
  800df1:	89 e5                	mov    %esp,%ebp
  800df3:	83 ec 0c             	sub    $0xc,%esp
  800df6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800df9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dfc:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800dff:	b8 01 00 00 00       	mov    $0x1,%eax
  800e04:	0f a2                	cpuid  
  800e06:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e08:	ba 00 00 00 00       	mov    $0x0,%edx
  800e0d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e12:	89 d1                	mov    %edx,%ecx
  800e14:	89 d3                	mov    %edx,%ebx
  800e16:	89 d7                	mov    %edx,%edi
  800e18:	89 d6                	mov    %edx,%esi
  800e1a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e1c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e1f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e22:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e25:	89 ec                	mov    %ebp,%esp
  800e27:	5d                   	pop    %ebp
  800e28:	c3                   	ret    

00800e29 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	83 ec 38             	sub    $0x38,%esp
  800e2f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e32:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e35:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e38:	b8 01 00 00 00       	mov    $0x1,%eax
  800e3d:	0f a2                	cpuid  
  800e3f:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e41:	be 00 00 00 00       	mov    $0x0,%esi
  800e46:	b8 04 00 00 00       	mov    $0x4,%eax
  800e4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e51:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e54:	89 f7                	mov    %esi,%edi
  800e56:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e58:	85 c0                	test   %eax,%eax
  800e5a:	7e 28                	jle    800e84 <sys_page_alloc+0x5b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e5c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e60:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800e67:	00 
  800e68:	c7 44 24 08 bf 23 80 	movl   $0x8023bf,0x8(%esp)
  800e6f:	00 
  800e70:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800e77:	00 
  800e78:	c7 04 24 dc 23 80 00 	movl   $0x8023dc,(%esp)
  800e7f:	e8 0c 0e 00 00       	call   801c90 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e84:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e87:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e8a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e8d:	89 ec                	mov    %ebp,%esp
  800e8f:	5d                   	pop    %ebp
  800e90:	c3                   	ret    

00800e91 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e91:	55                   	push   %ebp
  800e92:	89 e5                	mov    %esp,%ebp
  800e94:	83 ec 38             	sub    $0x38,%esp
  800e97:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e9a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e9d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800ea0:	b8 01 00 00 00       	mov    $0x1,%eax
  800ea5:	0f a2                	cpuid  
  800ea7:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea9:	b8 05 00 00 00       	mov    $0x5,%eax
  800eae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb1:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eb7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800eba:	8b 75 18             	mov    0x18(%ebp),%esi
  800ebd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ebf:	85 c0                	test   %eax,%eax
  800ec1:	7e 28                	jle    800eeb <sys_page_map+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ec7:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800ece:	00 
  800ecf:	c7 44 24 08 bf 23 80 	movl   $0x8023bf,0x8(%esp)
  800ed6:	00 
  800ed7:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800ede:	00 
  800edf:	c7 04 24 dc 23 80 00 	movl   $0x8023dc,(%esp)
  800ee6:	e8 a5 0d 00 00       	call   801c90 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800eeb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800eee:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ef1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ef4:	89 ec                	mov    %ebp,%esp
  800ef6:	5d                   	pop    %ebp
  800ef7:	c3                   	ret    

00800ef8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ef8:	55                   	push   %ebp
  800ef9:	89 e5                	mov    %esp,%ebp
  800efb:	83 ec 38             	sub    $0x38,%esp
  800efe:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f01:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f04:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800f07:	b8 01 00 00 00       	mov    $0x1,%eax
  800f0c:	0f a2                	cpuid  
  800f0e:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f10:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f15:	b8 06 00 00 00       	mov    $0x6,%eax
  800f1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f20:	89 df                	mov    %ebx,%edi
  800f22:	89 de                	mov    %ebx,%esi
  800f24:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f26:	85 c0                	test   %eax,%eax
  800f28:	7e 28                	jle    800f52 <sys_page_unmap+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f2a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f2e:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f35:	00 
  800f36:	c7 44 24 08 bf 23 80 	movl   $0x8023bf,0x8(%esp)
  800f3d:	00 
  800f3e:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800f45:	00 
  800f46:	c7 04 24 dc 23 80 00 	movl   $0x8023dc,(%esp)
  800f4d:	e8 3e 0d 00 00       	call   801c90 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f52:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f55:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f58:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f5b:	89 ec                	mov    %ebp,%esp
  800f5d:	5d                   	pop    %ebp
  800f5e:	c3                   	ret    

00800f5f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f5f:	55                   	push   %ebp
  800f60:	89 e5                	mov    %esp,%ebp
  800f62:	83 ec 38             	sub    $0x38,%esp
  800f65:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f68:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f6b:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800f6e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f73:	0f a2                	cpuid  
  800f75:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f77:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f7c:	b8 08 00 00 00       	mov    $0x8,%eax
  800f81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f84:	8b 55 08             	mov    0x8(%ebp),%edx
  800f87:	89 df                	mov    %ebx,%edi
  800f89:	89 de                	mov    %ebx,%esi
  800f8b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f8d:	85 c0                	test   %eax,%eax
  800f8f:	7e 28                	jle    800fb9 <sys_env_set_status+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f91:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f95:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800f9c:	00 
  800f9d:	c7 44 24 08 bf 23 80 	movl   $0x8023bf,0x8(%esp)
  800fa4:	00 
  800fa5:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800fac:	00 
  800fad:	c7 04 24 dc 23 80 00 	movl   $0x8023dc,(%esp)
  800fb4:	e8 d7 0c 00 00       	call   801c90 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800fb9:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fbc:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fbf:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fc2:	89 ec                	mov    %ebp,%esp
  800fc4:	5d                   	pop    %ebp
  800fc5:	c3                   	ret    

00800fc6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800fc6:	55                   	push   %ebp
  800fc7:	89 e5                	mov    %esp,%ebp
  800fc9:	83 ec 38             	sub    $0x38,%esp
  800fcc:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fcf:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fd2:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800fd5:	b8 01 00 00 00       	mov    $0x1,%eax
  800fda:	0f a2                	cpuid  
  800fdc:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fde:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fe3:	b8 09 00 00 00       	mov    $0x9,%eax
  800fe8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800feb:	8b 55 08             	mov    0x8(%ebp),%edx
  800fee:	89 df                	mov    %ebx,%edi
  800ff0:	89 de                	mov    %ebx,%esi
  800ff2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ff4:	85 c0                	test   %eax,%eax
  800ff6:	7e 28                	jle    801020 <sys_env_set_trapframe+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ff8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ffc:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801003:	00 
  801004:	c7 44 24 08 bf 23 80 	movl   $0x8023bf,0x8(%esp)
  80100b:	00 
  80100c:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  801013:	00 
  801014:	c7 04 24 dc 23 80 00 	movl   $0x8023dc,(%esp)
  80101b:	e8 70 0c 00 00       	call   801c90 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801020:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801023:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801026:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801029:	89 ec                	mov    %ebp,%esp
  80102b:	5d                   	pop    %ebp
  80102c:	c3                   	ret    

0080102d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80102d:	55                   	push   %ebp
  80102e:	89 e5                	mov    %esp,%ebp
  801030:	83 ec 38             	sub    $0x38,%esp
  801033:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801036:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801039:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80103c:	b8 01 00 00 00       	mov    $0x1,%eax
  801041:	0f a2                	cpuid  
  801043:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801045:	bb 00 00 00 00       	mov    $0x0,%ebx
  80104a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80104f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801052:	8b 55 08             	mov    0x8(%ebp),%edx
  801055:	89 df                	mov    %ebx,%edi
  801057:	89 de                	mov    %ebx,%esi
  801059:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80105b:	85 c0                	test   %eax,%eax
  80105d:	7e 28                	jle    801087 <sys_env_set_pgfault_upcall+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80105f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801063:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80106a:	00 
  80106b:	c7 44 24 08 bf 23 80 	movl   $0x8023bf,0x8(%esp)
  801072:	00 
  801073:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  80107a:	00 
  80107b:	c7 04 24 dc 23 80 00 	movl   $0x8023dc,(%esp)
  801082:	e8 09 0c 00 00       	call   801c90 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801087:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80108a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80108d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801090:	89 ec                	mov    %ebp,%esp
  801092:	5d                   	pop    %ebp
  801093:	c3                   	ret    

00801094 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801094:	55                   	push   %ebp
  801095:	89 e5                	mov    %esp,%ebp
  801097:	83 ec 0c             	sub    $0xc,%esp
  80109a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80109d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010a0:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8010a3:	b8 01 00 00 00       	mov    $0x1,%eax
  8010a8:	0f a2                	cpuid  
  8010aa:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010ac:	be 00 00 00 00       	mov    $0x0,%esi
  8010b1:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8010bc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010bf:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010c2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010c4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010c7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010ca:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010cd:	89 ec                	mov    %ebp,%esp
  8010cf:	5d                   	pop    %ebp
  8010d0:	c3                   	ret    

008010d1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010d1:	55                   	push   %ebp
  8010d2:	89 e5                	mov    %esp,%ebp
  8010d4:	83 ec 38             	sub    $0x38,%esp
  8010d7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010da:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010dd:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8010e0:	b8 01 00 00 00       	mov    $0x1,%eax
  8010e5:	0f a2                	cpuid  
  8010e7:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010e9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010ee:	b8 0d 00 00 00       	mov    $0xd,%eax
  8010f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f6:	89 cb                	mov    %ecx,%ebx
  8010f8:	89 cf                	mov    %ecx,%edi
  8010fa:	89 ce                	mov    %ecx,%esi
  8010fc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010fe:	85 c0                	test   %eax,%eax
  801100:	7e 28                	jle    80112a <sys_ipc_recv+0x59>
		panic("syscall %d returned %d (> 0)", num, ret);
  801102:	89 44 24 10          	mov    %eax,0x10(%esp)
  801106:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  80110d:	00 
  80110e:	c7 44 24 08 bf 23 80 	movl   $0x8023bf,0x8(%esp)
  801115:	00 
  801116:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  80111d:	00 
  80111e:	c7 04 24 dc 23 80 00 	movl   $0x8023dc,(%esp)
  801125:	e8 66 0b 00 00       	call   801c90 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80112a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80112d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801130:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801133:	89 ec                	mov    %ebp,%esp
  801135:	5d                   	pop    %ebp
  801136:	c3                   	ret    
  801137:	90                   	nop

00801138 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801138:	55                   	push   %ebp
  801139:	89 e5                	mov    %esp,%ebp
  80113b:	56                   	push   %esi
  80113c:	53                   	push   %ebx
  80113d:	83 ec 20             	sub    $0x20,%esp
  801140:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801143:	8b 30                	mov    (%eax),%esi
	// Hint:
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	pde_t pde = vpt[PGNUM(addr)];
  801145:	89 f2                	mov    %esi,%edx
  801147:	c1 ea 0c             	shr    $0xc,%edx
  80114a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx

	if(!((err & FEC_WR) && (pde &PTE_COW) ))
  801151:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801155:	74 05                	je     80115c <pgfault+0x24>
  801157:	f6 c6 08             	test   $0x8,%dh
  80115a:	75 20                	jne    80117c <pgfault+0x44>
		panic("Unrecoverable page fault at address[0x%x]!\n", addr);
  80115c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801160:	c7 44 24 08 ec 23 80 	movl   $0x8023ec,0x8(%esp)
  801167:	00 
  801168:	c7 44 24 04 1f 00 00 	movl   $0x1f,0x4(%esp)
  80116f:	00 
  801170:	c7 04 24 39 24 80 00 	movl   $0x802439,(%esp)
  801177:	e8 14 0b 00 00       	call   801c90 <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	envid_t thisenv_id = sys_getenvid();
  80117c:	e8 36 fc ff ff       	call   800db7 <sys_getenvid>
  801181:	89 c3                	mov    %eax,%ebx
	sys_page_alloc(thisenv_id, PFTEMP, PTE_P|PTE_W|PTE_U);
  801183:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80118a:	00 
  80118b:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801192:	00 
  801193:	89 04 24             	mov    %eax,(%esp)
  801196:	e8 8e fc ff ff       	call   800e29 <sys_page_alloc>
	memmove((void*)PFTEMP, (void*)ROUNDDOWN(addr, PGSIZE), PGSIZE);
  80119b:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  8011a1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8011a8:	00 
  8011a9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011ad:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8011b4:	e8 2a f9 ff ff       	call   800ae3 <memmove>
	sys_page_map(thisenv_id, (void*)PFTEMP, thisenv_id,(void*)ROUNDDOWN(addr, PGSIZE), 
  8011b9:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8011c0:	00 
  8011c1:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8011c5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8011c9:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8011d0:	00 
  8011d1:	89 1c 24             	mov    %ebx,(%esp)
  8011d4:	e8 b8 fc ff ff       	call   800e91 <sys_page_map>
		PTE_U|PTE_W|PTE_P);
	//panic("pgfault not implemented");
}
  8011d9:	83 c4 20             	add    $0x20,%esp
  8011dc:	5b                   	pop    %ebx
  8011dd:	5e                   	pop    %esi
  8011de:	5d                   	pop    %ebp
  8011df:	c3                   	ret    

008011e0 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8011e0:	55                   	push   %ebp
  8011e1:	89 e5                	mov    %esp,%ebp
  8011e3:	57                   	push   %edi
  8011e4:	56                   	push   %esi
  8011e5:	53                   	push   %ebx
  8011e6:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	envid_t child_id;
	uint32_t pg_cow_ptr;
	int r;

	set_pgfault_handler(pgfault);
  8011e9:	c7 04 24 38 11 80 00 	movl   $0x801138,(%esp)
  8011f0:	e8 f3 0a 00 00       	call   801ce8 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8011f5:	ba 07 00 00 00       	mov    $0x7,%edx
  8011fa:	89 d0                	mov    %edx,%eax
  8011fc:	cd 30                	int    $0x30
  8011fe:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801201:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if((child_id = sys_exofork()) < 0)
  801204:	85 c0                	test   %eax,%eax
  801206:	79 1c                	jns    801224 <fork+0x44>
		panic("Fork error\n");
  801208:	c7 44 24 08 44 24 80 	movl   $0x802444,0x8(%esp)
  80120f:	00 
  801210:	c7 44 24 04 6e 00 00 	movl   $0x6e,0x4(%esp)
  801217:	00 
  801218:	c7 04 24 39 24 80 00 	movl   $0x802439,(%esp)
  80121f:	e8 6c 0a 00 00       	call   801c90 <_panic>
	if(child_id == 0){
  801224:	bb 00 00 80 00       	mov    $0x800000,%ebx
  801229:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80122d:	75 1c                	jne    80124b <fork+0x6b>
		thisenv = &envs[ENVX(sys_getenvid())];
  80122f:	e8 83 fb ff ff       	call   800db7 <sys_getenvid>
  801234:	25 ff 03 00 00       	and    $0x3ff,%eax
  801239:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80123c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801241:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  801246:	e9 00 01 00 00       	jmp    80134b <fork+0x16b>
	}
	for(pg_cow_ptr = UTEXT; pg_cow_ptr < UXSTACKTOP - PGSIZE; pg_cow_ptr += PGSIZE){
		if ((vpd[PDX(pg_cow_ptr)]&PTE_P) && (vpt[PGNUM(pg_cow_ptr)]&(PTE_P|PTE_U)))
  80124b:	89 d8                	mov    %ebx,%eax
  80124d:	c1 e8 16             	shr    $0x16,%eax
  801250:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801257:	a8 01                	test   $0x1,%al
  801259:	74 79                	je     8012d4 <fork+0xf4>
  80125b:	89 de                	mov    %ebx,%esi
  80125d:	c1 ee 0c             	shr    $0xc,%esi
  801260:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801267:	a8 05                	test   $0x5,%al
  801269:	74 69                	je     8012d4 <fork+0xf4>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	// LAB 4: Your code here.
	int map_sz = pn*PGSIZE;
  80126b:	89 f7                	mov    %esi,%edi
  80126d:	c1 e7 0c             	shl    $0xc,%edi
	envid_t thisenv_id = sys_getenvid();
  801270:	e8 42 fb ff ff       	call   800db7 <sys_getenvid>
  801275:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	int perm = vpt[pn]&PTE_SYSCALL;
  801278:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80127f:	89 c6                	mov    %eax,%esi
  801281:	81 e6 07 0e 00 00    	and    $0xe07,%esi

	if(perm & PTE_COW || perm & PTE_W){
  801287:	a9 02 08 00 00       	test   $0x802,%eax
  80128c:	74 09                	je     801297 <fork+0xb7>
		perm |= PTE_COW;
  80128e:	81 ce 00 08 00 00    	or     $0x800,%esi
		perm &= ~PTE_W;
  801294:	83 e6 fd             	and    $0xfffffffd,%esi
	}
	//cprintf("thisenv_id[%p]\n", thisenv_id);

	if((r = sys_page_map(thisenv_id, (void*)map_sz, envid, (void*)map_sz, perm)) < 0)
  801297:	89 74 24 10          	mov    %esi,0x10(%esp)
  80129b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80129f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012a2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012a6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012ad:	89 04 24             	mov    %eax,(%esp)
  8012b0:	e8 dc fb ff ff       	call   800e91 <sys_page_map>
  8012b5:	85 c0                	test   %eax,%eax
  8012b7:	78 1b                	js     8012d4 <fork+0xf4>
		return r;
	if((r = sys_page_map(thisenv_id, (void*)map_sz, thisenv_id, (void*)map_sz, perm)) < 0)
  8012b9:	89 74 24 10          	mov    %esi,0x10(%esp)
  8012bd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012c8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012cc:	89 04 24             	mov    %eax,(%esp)
  8012cf:	e8 bd fb ff ff       	call   800e91 <sys_page_map>
		panic("Fork error\n");
	if(child_id == 0){
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	for(pg_cow_ptr = UTEXT; pg_cow_ptr < UXSTACKTOP - PGSIZE; pg_cow_ptr += PGSIZE){
  8012d4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8012da:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8012e0:	0f 85 65 ff ff ff    	jne    80124b <fork+0x6b>
		if ((vpd[PDX(pg_cow_ptr)]&PTE_P) && (vpt[PGNUM(pg_cow_ptr)]&(PTE_P|PTE_U)))
			duppage(child_id, PGNUM(pg_cow_ptr));
	}
	if((r = sys_page_alloc(child_id, (void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_P|PTE_W)))
  8012e6:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8012ed:	00 
  8012ee:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8012f5:	ee 
  8012f6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012f9:	89 04 24             	mov    %eax,(%esp)
  8012fc:	e8 28 fb ff ff       	call   800e29 <sys_page_alloc>
  801301:	85 c0                	test   %eax,%eax
  801303:	74 20                	je     801325 <fork+0x145>
		panic("Alloc exception stack error: %e\n", r);
  801305:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801309:	c7 44 24 08 18 24 80 	movl   $0x802418,0x8(%esp)
  801310:	00 
  801311:	c7 44 24 04 78 00 00 	movl   $0x78,0x4(%esp)
  801318:	00 
  801319:	c7 04 24 39 24 80 00 	movl   $0x802439,(%esp)
  801320:	e8 6b 09 00 00       	call   801c90 <_panic>

	extern void _pgfault_upcall(void);
	sys_env_set_pgfault_upcall(child_id, _pgfault_upcall);
  801325:	c7 44 24 04 58 1d 80 	movl   $0x801d58,0x4(%esp)
  80132c:	00 
  80132d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801330:	89 04 24             	mov    %eax,(%esp)
  801333:	e8 f5 fc ff ff       	call   80102d <sys_env_set_pgfault_upcall>

	sys_env_set_status(child_id, ENV_RUNNABLE);
  801338:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80133f:	00 
  801340:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801343:	89 04 24             	mov    %eax,(%esp)
  801346:	e8 14 fc ff ff       	call   800f5f <sys_env_set_status>
	return child_id;
	//panic("fork not implemented");
}
  80134b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80134e:	83 c4 3c             	add    $0x3c,%esp
  801351:	5b                   	pop    %ebx
  801352:	5e                   	pop    %esi
  801353:	5f                   	pop    %edi
  801354:	5d                   	pop    %ebp
  801355:	c3                   	ret    

00801356 <sfork>:

// Challenge!
int
sfork(void)
{
  801356:	55                   	push   %ebp
  801357:	89 e5                	mov    %esp,%ebp
  801359:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  80135c:	c7 44 24 08 50 24 80 	movl   $0x802450,0x8(%esp)
  801363:	00 
  801364:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  80136b:	00 
  80136c:	c7 04 24 39 24 80 00 	movl   $0x802439,(%esp)
  801373:	e8 18 09 00 00       	call   801c90 <_panic>

00801378 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801378:	55                   	push   %ebp
  801379:	89 e5                	mov    %esp,%ebp
  80137b:	56                   	push   %esi
  80137c:	53                   	push   %ebx
  80137d:	83 ec 10             	sub    $0x10,%esp
  801380:	8b 75 08             	mov    0x8(%ebp),%esi
  801383:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	// 	return thisenv->env_ipc_value;
	// }
	int r;
	if(pg == NULL)
		pg = (void *)~0x0;
  801386:	85 db                	test   %ebx,%ebx
  801388:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80138d:	0f 44 d8             	cmove  %eax,%ebx
	//else
	if((r = sys_ipc_recv(pg)) < 0)
  801390:	89 1c 24             	mov    %ebx,(%esp)
  801393:	e8 39 fd ff ff       	call   8010d1 <sys_ipc_recv>
  801398:	85 c0                	test   %eax,%eax
  80139a:	78 2d                	js     8013c9 <ipc_recv+0x51>
		return r;
	//volatile struct Env *curenv = (struct Env*)envs+ENVX(sys_getenvid());

	if(from_env_store)
  80139c:	85 f6                	test   %esi,%esi
  80139e:	74 0a                	je     8013aa <ipc_recv+0x32>
		*from_env_store = thisenv -> env_ipc_from;
  8013a0:	a1 08 40 80 00       	mov    0x804008,%eax
  8013a5:	8b 40 74             	mov    0x74(%eax),%eax
  8013a8:	89 06                	mov    %eax,(%esi)
	if(pg && perm_store)
  8013aa:	85 db                	test   %ebx,%ebx
  8013ac:	74 13                	je     8013c1 <ipc_recv+0x49>
  8013ae:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013b2:	74 0d                	je     8013c1 <ipc_recv+0x49>
		*perm_store = thisenv -> env_ipc_perm;
  8013b4:	a1 08 40 80 00       	mov    0x804008,%eax
  8013b9:	8b 40 78             	mov    0x78(%eax),%eax
  8013bc:	8b 55 10             	mov    0x10(%ebp),%edx
  8013bf:	89 02                	mov    %eax,(%edx)
	else if(perm_store)
		perm_store = (int *)0;
	return thisenv->env_ipc_value;
  8013c1:	a1 08 40 80 00       	mov    0x804008,%eax
  8013c6:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  8013c9:	83 c4 10             	add    $0x10,%esp
  8013cc:	5b                   	pop    %ebx
  8013cd:	5e                   	pop    %esi
  8013ce:	5d                   	pop    %ebp
  8013cf:	c3                   	ret    

008013d0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8013d0:	55                   	push   %ebp
  8013d1:	89 e5                	mov    %esp,%ebp
  8013d3:	57                   	push   %edi
  8013d4:	56                   	push   %esi
  8013d5:	53                   	push   %ebx
  8013d6:	83 ec 1c             	sub    $0x1c,%esp
  8013d9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013dc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013df:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

	if(pg == NULL)
  8013e2:	85 db                	test   %ebx,%ebx
		pg = (void *)~0x0;
  8013e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8013e9:	0f 44 d8             	cmove  %eax,%ebx
  8013ec:	eb 2a                	jmp    801418 <ipc_send+0x48>
	while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0){
		if(r != -E_IPC_NOT_RECV)
  8013ee:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8013f1:	74 20                	je     801413 <ipc_send+0x43>
            panic("Send message error %e\n",r);
  8013f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013f7:	c7 44 24 08 66 24 80 	movl   $0x802466,0x8(%esp)
  8013fe:	00 
  8013ff:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  801406:	00 
  801407:	c7 04 24 7d 24 80 00 	movl   $0x80247d,(%esp)
  80140e:	e8 7d 08 00 00       	call   801c90 <_panic>
		sys_yield();
  801413:	e8 d8 f9 ff ff       	call   800df0 <sys_yield>
	// LAB 4: Your code here.
	int r;

	if(pg == NULL)
		pg = (void *)~0x0;
	while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0){
  801418:	8b 45 14             	mov    0x14(%ebp),%eax
  80141b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80141f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801423:	89 74 24 04          	mov    %esi,0x4(%esp)
  801427:	89 3c 24             	mov    %edi,(%esp)
  80142a:	e8 65 fc ff ff       	call   801094 <sys_ipc_try_send>
  80142f:	85 c0                	test   %eax,%eax
  801431:	78 bb                	js     8013ee <ipc_send+0x1e>
            panic("Send message error %e\n",r);
		sys_yield();
	}

	//panic("ipc_send not implemented");
}
  801433:	83 c4 1c             	add    $0x1c,%esp
  801436:	5b                   	pop    %ebx
  801437:	5e                   	pop    %esi
  801438:	5f                   	pop    %edi
  801439:	5d                   	pop    %ebp
  80143a:	c3                   	ret    

0080143b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80143b:	55                   	push   %ebp
  80143c:	89 e5                	mov    %esp,%ebp
  80143e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801441:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801446:	39 c8                	cmp    %ecx,%eax
  801448:	74 17                	je     801461 <ipc_find_env+0x26>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80144a:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  80144f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801452:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801458:	8b 52 50             	mov    0x50(%edx),%edx
  80145b:	39 ca                	cmp    %ecx,%edx
  80145d:	75 14                	jne    801473 <ipc_find_env+0x38>
  80145f:	eb 05                	jmp    801466 <ipc_find_env+0x2b>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801461:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801466:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801469:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  80146e:	8b 40 40             	mov    0x40(%eax),%eax
  801471:	eb 0e                	jmp    801481 <ipc_find_env+0x46>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801473:	83 c0 01             	add    $0x1,%eax
  801476:	3d 00 04 00 00       	cmp    $0x400,%eax
  80147b:	75 d2                	jne    80144f <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80147d:	66 b8 00 00          	mov    $0x0,%ax
}
  801481:	5d                   	pop    %ebp
  801482:	c3                   	ret    
  801483:	66 90                	xchg   %ax,%ax
  801485:	66 90                	xchg   %ax,%ax
  801487:	66 90                	xchg   %ax,%ax
  801489:	66 90                	xchg   %ax,%ax
  80148b:	66 90                	xchg   %ax,%ax
  80148d:	66 90                	xchg   %ax,%ax
  80148f:	90                   	nop

00801490 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801490:	55                   	push   %ebp
  801491:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801493:	8b 45 08             	mov    0x8(%ebp),%eax
  801496:	05 00 00 00 30       	add    $0x30000000,%eax
  80149b:	c1 e8 0c             	shr    $0xc,%eax
}
  80149e:	5d                   	pop    %ebp
  80149f:	c3                   	ret    

008014a0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8014a0:	55                   	push   %ebp
  8014a1:	89 e5                	mov    %esp,%ebp
  8014a3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8014a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a9:	89 04 24             	mov    %eax,(%esp)
  8014ac:	e8 df ff ff ff       	call   801490 <fd2num>
  8014b1:	c1 e0 0c             	shl    $0xc,%eax
  8014b4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8014b9:	c9                   	leave  
  8014ba:	c3                   	ret    

008014bb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8014bb:	55                   	push   %ebp
  8014bc:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8014be:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8014c3:	a8 01                	test   $0x1,%al
  8014c5:	74 34                	je     8014fb <fd_alloc+0x40>
  8014c7:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8014cc:	a8 01                	test   $0x1,%al
  8014ce:	74 32                	je     801502 <fd_alloc+0x47>
  8014d0:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8014d5:	89 c1                	mov    %eax,%ecx
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8014d7:	89 c2                	mov    %eax,%edx
  8014d9:	c1 ea 16             	shr    $0x16,%edx
  8014dc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014e3:	f6 c2 01             	test   $0x1,%dl
  8014e6:	74 1f                	je     801507 <fd_alloc+0x4c>
  8014e8:	89 c2                	mov    %eax,%edx
  8014ea:	c1 ea 0c             	shr    $0xc,%edx
  8014ed:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014f4:	f6 c2 01             	test   $0x1,%dl
  8014f7:	75 1a                	jne    801513 <fd_alloc+0x58>
  8014f9:	eb 0c                	jmp    801507 <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8014fb:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801500:	eb 05                	jmp    801507 <fd_alloc+0x4c>
  801502:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  801507:	8b 45 08             	mov    0x8(%ebp),%eax
  80150a:	89 08                	mov    %ecx,(%eax)
			return 0;
  80150c:	b8 00 00 00 00       	mov    $0x0,%eax
  801511:	eb 1a                	jmp    80152d <fd_alloc+0x72>
  801513:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801518:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80151d:	75 b6                	jne    8014d5 <fd_alloc+0x1a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80151f:	8b 45 08             	mov    0x8(%ebp),%eax
  801522:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801528:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80152d:	5d                   	pop    %ebp
  80152e:	c3                   	ret    

0080152f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80152f:	55                   	push   %ebp
  801530:	89 e5                	mov    %esp,%ebp
  801532:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801535:	83 f8 1f             	cmp    $0x1f,%eax
  801538:	77 36                	ja     801570 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80153a:	c1 e0 0c             	shl    $0xc,%eax
  80153d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801542:	89 c2                	mov    %eax,%edx
  801544:	c1 ea 16             	shr    $0x16,%edx
  801547:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80154e:	f6 c2 01             	test   $0x1,%dl
  801551:	74 24                	je     801577 <fd_lookup+0x48>
  801553:	89 c2                	mov    %eax,%edx
  801555:	c1 ea 0c             	shr    $0xc,%edx
  801558:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80155f:	f6 c2 01             	test   $0x1,%dl
  801562:	74 1a                	je     80157e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801564:	8b 55 0c             	mov    0xc(%ebp),%edx
  801567:	89 02                	mov    %eax,(%edx)
	return 0;
  801569:	b8 00 00 00 00       	mov    $0x0,%eax
  80156e:	eb 13                	jmp    801583 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  801570:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801575:	eb 0c                	jmp    801583 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  801577:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80157c:	eb 05                	jmp    801583 <fd_lookup+0x54>
  80157e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801583:	5d                   	pop    %ebp
  801584:	c3                   	ret    

00801585 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801585:	55                   	push   %ebp
  801586:	89 e5                	mov    %esp,%ebp
  801588:	83 ec 18             	sub    $0x18,%esp
  80158b:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80158e:	39 05 04 30 80 00    	cmp    %eax,0x803004
  801594:	75 10                	jne    8015a6 <dev_lookup+0x21>
			*dev = devtab[i];
  801596:	8b 45 0c             	mov    0xc(%ebp),%eax
  801599:	c7 00 04 30 80 00    	movl   $0x803004,(%eax)
			return 0;
  80159f:	b8 00 00 00 00       	mov    $0x0,%eax
  8015a4:	eb 2b                	jmp    8015d1 <dev_lookup+0x4c>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8015a6:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8015ac:	8b 52 48             	mov    0x48(%edx),%edx
  8015af:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8015b7:	c7 04 24 88 24 80 00 	movl   $0x802488,(%esp)
  8015be:	e8 98 ec ff ff       	call   80025b <cprintf>
	*dev = 0;
  8015c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015c6:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	return -E_INVAL;
  8015cc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8015d1:	c9                   	leave  
  8015d2:	c3                   	ret    

008015d3 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8015d3:	55                   	push   %ebp
  8015d4:	89 e5                	mov    %esp,%ebp
  8015d6:	83 ec 38             	sub    $0x38,%esp
  8015d9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8015dc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8015df:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8015e2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015e5:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8015e8:	89 3c 24             	mov    %edi,(%esp)
  8015eb:	e8 a0 fe ff ff       	call   801490 <fd2num>
  8015f0:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8015f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8015f7:	89 04 24             	mov    %eax,(%esp)
  8015fa:	e8 30 ff ff ff       	call   80152f <fd_lookup>
  8015ff:	89 c3                	mov    %eax,%ebx
  801601:	85 c0                	test   %eax,%eax
  801603:	78 05                	js     80160a <fd_close+0x37>
	    || fd != fd2)
  801605:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  801608:	74 0c                	je     801616 <fd_close+0x43>
		return (must_exist ? r : 0);
  80160a:	85 f6                	test   %esi,%esi
  80160c:	b8 00 00 00 00       	mov    $0x0,%eax
  801611:	0f 44 d8             	cmove  %eax,%ebx
  801614:	eb 3d                	jmp    801653 <fd_close+0x80>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801616:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801619:	89 44 24 04          	mov    %eax,0x4(%esp)
  80161d:	8b 07                	mov    (%edi),%eax
  80161f:	89 04 24             	mov    %eax,(%esp)
  801622:	e8 5e ff ff ff       	call   801585 <dev_lookup>
  801627:	89 c3                	mov    %eax,%ebx
  801629:	85 c0                	test   %eax,%eax
  80162b:	78 16                	js     801643 <fd_close+0x70>
		if (dev->dev_close)
  80162d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801630:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801633:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801638:	85 c0                	test   %eax,%eax
  80163a:	74 07                	je     801643 <fd_close+0x70>
			r = (*dev->dev_close)(fd);
  80163c:	89 3c 24             	mov    %edi,(%esp)
  80163f:	ff d0                	call   *%eax
  801641:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801643:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801647:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80164e:	e8 a5 f8 ff ff       	call   800ef8 <sys_page_unmap>
	return r;
}
  801653:	89 d8                	mov    %ebx,%eax
  801655:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801658:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80165b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80165e:	89 ec                	mov    %ebp,%esp
  801660:	5d                   	pop    %ebp
  801661:	c3                   	ret    

00801662 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801662:	55                   	push   %ebp
  801663:	89 e5                	mov    %esp,%ebp
  801665:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801668:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80166b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80166f:	8b 45 08             	mov    0x8(%ebp),%eax
  801672:	89 04 24             	mov    %eax,(%esp)
  801675:	e8 b5 fe ff ff       	call   80152f <fd_lookup>
  80167a:	85 c0                	test   %eax,%eax
  80167c:	78 13                	js     801691 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80167e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801685:	00 
  801686:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801689:	89 04 24             	mov    %eax,(%esp)
  80168c:	e8 42 ff ff ff       	call   8015d3 <fd_close>
}
  801691:	c9                   	leave  
  801692:	c3                   	ret    

00801693 <close_all>:

void
close_all(void)
{
  801693:	55                   	push   %ebp
  801694:	89 e5                	mov    %esp,%ebp
  801696:	53                   	push   %ebx
  801697:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80169a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80169f:	89 1c 24             	mov    %ebx,(%esp)
  8016a2:	e8 bb ff ff ff       	call   801662 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8016a7:	83 c3 01             	add    $0x1,%ebx
  8016aa:	83 fb 20             	cmp    $0x20,%ebx
  8016ad:	75 f0                	jne    80169f <close_all+0xc>
		close(i);
}
  8016af:	83 c4 14             	add    $0x14,%esp
  8016b2:	5b                   	pop    %ebx
  8016b3:	5d                   	pop    %ebp
  8016b4:	c3                   	ret    

008016b5 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8016b5:	55                   	push   %ebp
  8016b6:	89 e5                	mov    %esp,%ebp
  8016b8:	83 ec 58             	sub    $0x58,%esp
  8016bb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8016be:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8016c1:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8016c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8016c7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8016ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d1:	89 04 24             	mov    %eax,(%esp)
  8016d4:	e8 56 fe ff ff       	call   80152f <fd_lookup>
  8016d9:	85 c0                	test   %eax,%eax
  8016db:	0f 88 e3 00 00 00    	js     8017c4 <dup+0x10f>
		return r;
	close(newfdnum);
  8016e1:	89 1c 24             	mov    %ebx,(%esp)
  8016e4:	e8 79 ff ff ff       	call   801662 <close>

	newfd = INDEX2FD(newfdnum);
  8016e9:	89 de                	mov    %ebx,%esi
  8016eb:	c1 e6 0c             	shl    $0xc,%esi
  8016ee:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8016f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016f7:	89 04 24             	mov    %eax,(%esp)
  8016fa:	e8 a1 fd ff ff       	call   8014a0 <fd2data>
  8016ff:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801701:	89 34 24             	mov    %esi,(%esp)
  801704:	e8 97 fd ff ff       	call   8014a0 <fd2data>
  801709:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  80170c:	89 f8                	mov    %edi,%eax
  80170e:	c1 e8 16             	shr    $0x16,%eax
  801711:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801718:	a8 01                	test   $0x1,%al
  80171a:	74 46                	je     801762 <dup+0xad>
  80171c:	89 f8                	mov    %edi,%eax
  80171e:	c1 e8 0c             	shr    $0xc,%eax
  801721:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801728:	f6 c2 01             	test   $0x1,%dl
  80172b:	74 35                	je     801762 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80172d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801734:	25 07 0e 00 00       	and    $0xe07,%eax
  801739:	89 44 24 10          	mov    %eax,0x10(%esp)
  80173d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801740:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801744:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80174b:	00 
  80174c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801750:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801757:	e8 35 f7 ff ff       	call   800e91 <sys_page_map>
  80175c:	89 c7                	mov    %eax,%edi
  80175e:	85 c0                	test   %eax,%eax
  801760:	78 3b                	js     80179d <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801762:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801765:	89 c2                	mov    %eax,%edx
  801767:	c1 ea 0c             	shr    $0xc,%edx
  80176a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801771:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801777:	89 54 24 10          	mov    %edx,0x10(%esp)
  80177b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80177f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801786:	00 
  801787:	89 44 24 04          	mov    %eax,0x4(%esp)
  80178b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801792:	e8 fa f6 ff ff       	call   800e91 <sys_page_map>
  801797:	89 c7                	mov    %eax,%edi
  801799:	85 c0                	test   %eax,%eax
  80179b:	79 29                	jns    8017c6 <dup+0x111>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80179d:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017a8:	e8 4b f7 ff ff       	call   800ef8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8017ad:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8017b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017bb:	e8 38 f7 ff ff       	call   800ef8 <sys_page_unmap>
	return r;
  8017c0:	89 fb                	mov    %edi,%ebx
  8017c2:	eb 02                	jmp    8017c6 <dup+0x111>
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
		return r;
  8017c4:	89 c3                	mov    %eax,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8017c6:	89 d8                	mov    %ebx,%eax
  8017c8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8017cb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8017ce:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8017d1:	89 ec                	mov    %ebp,%esp
  8017d3:	5d                   	pop    %ebp
  8017d4:	c3                   	ret    

008017d5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8017d5:	55                   	push   %ebp
  8017d6:	89 e5                	mov    %esp,%ebp
  8017d8:	53                   	push   %ebx
  8017d9:	83 ec 24             	sub    $0x24,%esp
  8017dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017df:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017e6:	89 1c 24             	mov    %ebx,(%esp)
  8017e9:	e8 41 fd ff ff       	call   80152f <fd_lookup>
  8017ee:	85 c0                	test   %eax,%eax
  8017f0:	78 6d                	js     80185f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017fc:	8b 00                	mov    (%eax),%eax
  8017fe:	89 04 24             	mov    %eax,(%esp)
  801801:	e8 7f fd ff ff       	call   801585 <dev_lookup>
  801806:	85 c0                	test   %eax,%eax
  801808:	78 55                	js     80185f <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80180a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80180d:	8b 50 08             	mov    0x8(%eax),%edx
  801810:	83 e2 03             	and    $0x3,%edx
  801813:	83 fa 01             	cmp    $0x1,%edx
  801816:	75 23                	jne    80183b <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801818:	a1 08 40 80 00       	mov    0x804008,%eax
  80181d:	8b 40 48             	mov    0x48(%eax),%eax
  801820:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801824:	89 44 24 04          	mov    %eax,0x4(%esp)
  801828:	c7 04 24 c9 24 80 00 	movl   $0x8024c9,(%esp)
  80182f:	e8 27 ea ff ff       	call   80025b <cprintf>
		return -E_INVAL;
  801834:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801839:	eb 24                	jmp    80185f <read+0x8a>
	}
	if (!dev->dev_read)
  80183b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80183e:	8b 52 08             	mov    0x8(%edx),%edx
  801841:	85 d2                	test   %edx,%edx
  801843:	74 15                	je     80185a <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801845:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801848:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80184c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80184f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801853:	89 04 24             	mov    %eax,(%esp)
  801856:	ff d2                	call   *%edx
  801858:	eb 05                	jmp    80185f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80185a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80185f:	83 c4 24             	add    $0x24,%esp
  801862:	5b                   	pop    %ebx
  801863:	5d                   	pop    %ebp
  801864:	c3                   	ret    

00801865 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801865:	55                   	push   %ebp
  801866:	89 e5                	mov    %esp,%ebp
  801868:	57                   	push   %edi
  801869:	56                   	push   %esi
  80186a:	53                   	push   %ebx
  80186b:	83 ec 1c             	sub    $0x1c,%esp
  80186e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801871:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801874:	85 f6                	test   %esi,%esi
  801876:	74 33                	je     8018ab <readn+0x46>
  801878:	b8 00 00 00 00       	mov    $0x0,%eax
  80187d:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801882:	89 f2                	mov    %esi,%edx
  801884:	29 c2                	sub    %eax,%edx
  801886:	89 54 24 08          	mov    %edx,0x8(%esp)
  80188a:	03 45 0c             	add    0xc(%ebp),%eax
  80188d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801891:	89 3c 24             	mov    %edi,(%esp)
  801894:	e8 3c ff ff ff       	call   8017d5 <read>
		if (m < 0)
  801899:	85 c0                	test   %eax,%eax
  80189b:	78 17                	js     8018b4 <readn+0x4f>
			return m;
		if (m == 0)
  80189d:	85 c0                	test   %eax,%eax
  80189f:	74 11                	je     8018b2 <readn+0x4d>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8018a1:	01 c3                	add    %eax,%ebx
  8018a3:	89 d8                	mov    %ebx,%eax
  8018a5:	39 f3                	cmp    %esi,%ebx
  8018a7:	72 d9                	jb     801882 <readn+0x1d>
  8018a9:	eb 09                	jmp    8018b4 <readn+0x4f>
  8018ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8018b0:	eb 02                	jmp    8018b4 <readn+0x4f>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8018b2:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8018b4:	83 c4 1c             	add    $0x1c,%esp
  8018b7:	5b                   	pop    %ebx
  8018b8:	5e                   	pop    %esi
  8018b9:	5f                   	pop    %edi
  8018ba:	5d                   	pop    %ebp
  8018bb:	c3                   	ret    

008018bc <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8018bc:	55                   	push   %ebp
  8018bd:	89 e5                	mov    %esp,%ebp
  8018bf:	53                   	push   %ebx
  8018c0:	83 ec 24             	sub    $0x24,%esp
  8018c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018cd:	89 1c 24             	mov    %ebx,(%esp)
  8018d0:	e8 5a fc ff ff       	call   80152f <fd_lookup>
  8018d5:	85 c0                	test   %eax,%eax
  8018d7:	78 68                	js     801941 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018e3:	8b 00                	mov    (%eax),%eax
  8018e5:	89 04 24             	mov    %eax,(%esp)
  8018e8:	e8 98 fc ff ff       	call   801585 <dev_lookup>
  8018ed:	85 c0                	test   %eax,%eax
  8018ef:	78 50                	js     801941 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018f4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018f8:	75 23                	jne    80191d <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8018fa:	a1 08 40 80 00       	mov    0x804008,%eax
  8018ff:	8b 40 48             	mov    0x48(%eax),%eax
  801902:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801906:	89 44 24 04          	mov    %eax,0x4(%esp)
  80190a:	c7 04 24 e5 24 80 00 	movl   $0x8024e5,(%esp)
  801911:	e8 45 e9 ff ff       	call   80025b <cprintf>
		return -E_INVAL;
  801916:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80191b:	eb 24                	jmp    801941 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80191d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801920:	8b 52 0c             	mov    0xc(%edx),%edx
  801923:	85 d2                	test   %edx,%edx
  801925:	74 15                	je     80193c <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801927:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80192a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80192e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801931:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801935:	89 04 24             	mov    %eax,(%esp)
  801938:	ff d2                	call   *%edx
  80193a:	eb 05                	jmp    801941 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80193c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801941:	83 c4 24             	add    $0x24,%esp
  801944:	5b                   	pop    %ebx
  801945:	5d                   	pop    %ebp
  801946:	c3                   	ret    

00801947 <seek>:

int
seek(int fdnum, off_t offset)
{
  801947:	55                   	push   %ebp
  801948:	89 e5                	mov    %esp,%ebp
  80194a:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80194d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801950:	89 44 24 04          	mov    %eax,0x4(%esp)
  801954:	8b 45 08             	mov    0x8(%ebp),%eax
  801957:	89 04 24             	mov    %eax,(%esp)
  80195a:	e8 d0 fb ff ff       	call   80152f <fd_lookup>
  80195f:	85 c0                	test   %eax,%eax
  801961:	78 0e                	js     801971 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801963:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801966:	8b 55 0c             	mov    0xc(%ebp),%edx
  801969:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80196c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801971:	c9                   	leave  
  801972:	c3                   	ret    

00801973 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801973:	55                   	push   %ebp
  801974:	89 e5                	mov    %esp,%ebp
  801976:	53                   	push   %ebx
  801977:	83 ec 24             	sub    $0x24,%esp
  80197a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80197d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801980:	89 44 24 04          	mov    %eax,0x4(%esp)
  801984:	89 1c 24             	mov    %ebx,(%esp)
  801987:	e8 a3 fb ff ff       	call   80152f <fd_lookup>
  80198c:	85 c0                	test   %eax,%eax
  80198e:	78 61                	js     8019f1 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801990:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801993:	89 44 24 04          	mov    %eax,0x4(%esp)
  801997:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80199a:	8b 00                	mov    (%eax),%eax
  80199c:	89 04 24             	mov    %eax,(%esp)
  80199f:	e8 e1 fb ff ff       	call   801585 <dev_lookup>
  8019a4:	85 c0                	test   %eax,%eax
  8019a6:	78 49                	js     8019f1 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8019a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019ab:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8019af:	75 23                	jne    8019d4 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8019b1:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8019b6:	8b 40 48             	mov    0x48(%eax),%eax
  8019b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019c1:	c7 04 24 a8 24 80 00 	movl   $0x8024a8,(%esp)
  8019c8:	e8 8e e8 ff ff       	call   80025b <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8019cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019d2:	eb 1d                	jmp    8019f1 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8019d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019d7:	8b 52 18             	mov    0x18(%edx),%edx
  8019da:	85 d2                	test   %edx,%edx
  8019dc:	74 0e                	je     8019ec <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8019de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019e1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8019e5:	89 04 24             	mov    %eax,(%esp)
  8019e8:	ff d2                	call   *%edx
  8019ea:	eb 05                	jmp    8019f1 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8019ec:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8019f1:	83 c4 24             	add    $0x24,%esp
  8019f4:	5b                   	pop    %ebx
  8019f5:	5d                   	pop    %ebp
  8019f6:	c3                   	ret    

008019f7 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8019f7:	55                   	push   %ebp
  8019f8:	89 e5                	mov    %esp,%ebp
  8019fa:	53                   	push   %ebx
  8019fb:	83 ec 24             	sub    $0x24,%esp
  8019fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a01:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a04:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a08:	8b 45 08             	mov    0x8(%ebp),%eax
  801a0b:	89 04 24             	mov    %eax,(%esp)
  801a0e:	e8 1c fb ff ff       	call   80152f <fd_lookup>
  801a13:	85 c0                	test   %eax,%eax
  801a15:	78 52                	js     801a69 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a17:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a1a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a21:	8b 00                	mov    (%eax),%eax
  801a23:	89 04 24             	mov    %eax,(%esp)
  801a26:	e8 5a fb ff ff       	call   801585 <dev_lookup>
  801a2b:	85 c0                	test   %eax,%eax
  801a2d:	78 3a                	js     801a69 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801a2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a32:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801a36:	74 2c                	je     801a64 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801a38:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801a3b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801a42:	00 00 00 
	stat->st_isdir = 0;
  801a45:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a4c:	00 00 00 
	stat->st_dev = dev;
  801a4f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a55:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a59:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a5c:	89 14 24             	mov    %edx,(%esp)
  801a5f:	ff 50 14             	call   *0x14(%eax)
  801a62:	eb 05                	jmp    801a69 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801a64:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801a69:	83 c4 24             	add    $0x24,%esp
  801a6c:	5b                   	pop    %ebx
  801a6d:	5d                   	pop    %ebp
  801a6e:	c3                   	ret    

00801a6f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a6f:	55                   	push   %ebp
  801a70:	89 e5                	mov    %esp,%ebp
  801a72:	83 ec 18             	sub    $0x18,%esp
  801a75:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801a78:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a7b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a82:	00 
  801a83:	8b 45 08             	mov    0x8(%ebp),%eax
  801a86:	89 04 24             	mov    %eax,(%esp)
  801a89:	e8 84 01 00 00       	call   801c12 <open>
  801a8e:	89 c3                	mov    %eax,%ebx
  801a90:	85 c0                	test   %eax,%eax
  801a92:	78 1b                	js     801aaf <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801a94:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a97:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a9b:	89 1c 24             	mov    %ebx,(%esp)
  801a9e:	e8 54 ff ff ff       	call   8019f7 <fstat>
  801aa3:	89 c6                	mov    %eax,%esi
	close(fd);
  801aa5:	89 1c 24             	mov    %ebx,(%esp)
  801aa8:	e8 b5 fb ff ff       	call   801662 <close>
	return r;
  801aad:	89 f3                	mov    %esi,%ebx
}
  801aaf:	89 d8                	mov    %ebx,%eax
  801ab1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801ab4:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801ab7:	89 ec                	mov    %ebp,%esp
  801ab9:	5d                   	pop    %ebp
  801aba:	c3                   	ret    
  801abb:	90                   	nop

00801abc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801abc:	55                   	push   %ebp
  801abd:	89 e5                	mov    %esp,%ebp
  801abf:	83 ec 18             	sub    $0x18,%esp
  801ac2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801ac5:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801ac8:	89 c6                	mov    %eax,%esi
  801aca:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801acc:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801ad3:	75 11                	jne    801ae6 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801ad5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801adc:	e8 5a f9 ff ff       	call   80143b <ipc_find_env>
  801ae1:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801ae6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801aed:	00 
  801aee:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801af5:	00 
  801af6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801afa:	a1 00 40 80 00       	mov    0x804000,%eax
  801aff:	89 04 24             	mov    %eax,(%esp)
  801b02:	e8 c9 f8 ff ff       	call   8013d0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801b07:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b0e:	00 
  801b0f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b13:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b1a:	e8 59 f8 ff ff       	call   801378 <ipc_recv>
}
  801b1f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801b22:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801b25:	89 ec                	mov    %ebp,%esp
  801b27:	5d                   	pop    %ebp
  801b28:	c3                   	ret    

00801b29 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801b29:	55                   	push   %ebp
  801b2a:	89 e5                	mov    %esp,%ebp
  801b2c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801b2f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b32:	8b 40 0c             	mov    0xc(%eax),%eax
  801b35:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801b3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b3d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801b42:	ba 00 00 00 00       	mov    $0x0,%edx
  801b47:	b8 02 00 00 00       	mov    $0x2,%eax
  801b4c:	e8 6b ff ff ff       	call   801abc <fsipc>
}
  801b51:	c9                   	leave  
  801b52:	c3                   	ret    

00801b53 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801b53:	55                   	push   %ebp
  801b54:	89 e5                	mov    %esp,%ebp
  801b56:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801b59:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5c:	8b 40 0c             	mov    0xc(%eax),%eax
  801b5f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801b64:	ba 00 00 00 00       	mov    $0x0,%edx
  801b69:	b8 06 00 00 00       	mov    $0x6,%eax
  801b6e:	e8 49 ff ff ff       	call   801abc <fsipc>
}
  801b73:	c9                   	leave  
  801b74:	c3                   	ret    

00801b75 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801b75:	55                   	push   %ebp
  801b76:	89 e5                	mov    %esp,%ebp
  801b78:	53                   	push   %ebx
  801b79:	83 ec 14             	sub    $0x14,%esp
  801b7c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b7f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b82:	8b 40 0c             	mov    0xc(%eax),%eax
  801b85:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b8a:	ba 00 00 00 00       	mov    $0x0,%edx
  801b8f:	b8 05 00 00 00       	mov    $0x5,%eax
  801b94:	e8 23 ff ff ff       	call   801abc <fsipc>
  801b99:	85 c0                	test   %eax,%eax
  801b9b:	78 2b                	js     801bc8 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b9d:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801ba4:	00 
  801ba5:	89 1c 24             	mov    %ebx,(%esp)
  801ba8:	e8 2e ed ff ff       	call   8008db <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801bad:	a1 80 50 80 00       	mov    0x805080,%eax
  801bb2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801bb8:	a1 84 50 80 00       	mov    0x805084,%eax
  801bbd:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801bc3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bc8:	83 c4 14             	add    $0x14,%esp
  801bcb:	5b                   	pop    %ebx
  801bcc:	5d                   	pop    %ebp
  801bcd:	c3                   	ret    

00801bce <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801bce:	55                   	push   %ebp
  801bcf:	89 e5                	mov    %esp,%ebp
  801bd1:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801bd4:	c7 44 24 08 02 25 80 	movl   $0x802502,0x8(%esp)
  801bdb:	00 
  801bdc:	c7 44 24 04 77 00 00 	movl   $0x77,0x4(%esp)
  801be3:	00 
  801be4:	c7 04 24 20 25 80 00 	movl   $0x802520,(%esp)
  801beb:	e8 a0 00 00 00       	call   801c90 <_panic>

00801bf0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801bf0:	55                   	push   %ebp
  801bf1:	89 e5                	mov    %esp,%ebp
  801bf3:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_READ request to the file system server after
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
	panic("devfile_read not implemented");
  801bf6:	c7 44 24 08 2b 25 80 	movl   $0x80252b,0x8(%esp)
  801bfd:	00 
  801bfe:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
  801c05:	00 
  801c06:	c7 04 24 20 25 80 00 	movl   $0x802520,(%esp)
  801c0d:	e8 7e 00 00 00       	call   801c90 <_panic>

00801c12 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801c12:	55                   	push   %ebp
  801c13:	89 e5                	mov    %esp,%ebp
  801c15:	83 ec 18             	sub    $0x18,%esp
	// Return the file descriptor index.
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
	panic("open not implemented");
  801c18:	c7 44 24 08 48 25 80 	movl   $0x802548,0x8(%esp)
  801c1f:	00 
  801c20:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  801c27:	00 
  801c28:	c7 04 24 20 25 80 00 	movl   $0x802520,(%esp)
  801c2f:	e8 5c 00 00 00       	call   801c90 <_panic>

00801c34 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801c34:	55                   	push   %ebp
  801c35:	89 e5                	mov    %esp,%ebp
  801c37:	53                   	push   %ebx
  801c38:	83 ec 14             	sub    $0x14,%esp
  801c3b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801c3e:	89 1c 24             	mov    %ebx,(%esp)
  801c41:	e8 3a ec ff ff       	call   800880 <strlen>
  801c46:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c4b:	7f 21                	jg     801c6e <remove+0x3a>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801c4d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c51:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801c58:	e8 7e ec ff ff       	call   8008db <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801c5d:	ba 00 00 00 00       	mov    $0x0,%edx
  801c62:	b8 07 00 00 00       	mov    $0x7,%eax
  801c67:	e8 50 fe ff ff       	call   801abc <fsipc>
  801c6c:	eb 05                	jmp    801c73 <remove+0x3f>
// Delete a file
int
remove(const char *path)
{
	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c6e:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
	strcpy(fsipcbuf.remove.req_path, path);
	return fsipc(FSREQ_REMOVE, NULL);
}
  801c73:	83 c4 14             	add    $0x14,%esp
  801c76:	5b                   	pop    %ebx
  801c77:	5d                   	pop    %ebp
  801c78:	c3                   	ret    

00801c79 <sync>:

// Synchronize disk with buffer cache
int
sync(void)
{
  801c79:	55                   	push   %ebp
  801c7a:	89 e5                	mov    %esp,%ebp
  801c7c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c7f:	ba 00 00 00 00       	mov    $0x0,%edx
  801c84:	b8 08 00 00 00       	mov    $0x8,%eax
  801c89:	e8 2e fe ff ff       	call   801abc <fsipc>
}
  801c8e:	c9                   	leave  
  801c8f:	c3                   	ret    

00801c90 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801c90:	55                   	push   %ebp
  801c91:	89 e5                	mov    %esp,%ebp
  801c93:	56                   	push   %esi
  801c94:	53                   	push   %ebx
  801c95:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801c98:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801c9b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801ca1:	e8 11 f1 ff ff       	call   800db7 <sys_getenvid>
  801ca6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ca9:	89 54 24 10          	mov    %edx,0x10(%esp)
  801cad:	8b 55 08             	mov    0x8(%ebp),%edx
  801cb0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801cb4:	89 74 24 08          	mov    %esi,0x8(%esp)
  801cb8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cbc:	c7 04 24 60 25 80 00 	movl   $0x802560,(%esp)
  801cc3:	e8 93 e5 ff ff       	call   80025b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801cc8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ccc:	8b 45 10             	mov    0x10(%ebp),%eax
  801ccf:	89 04 24             	mov    %eax,(%esp)
  801cd2:	e8 23 e5 ff ff       	call   8001fa <vcprintf>
	cprintf("\n");
  801cd7:	c7 04 24 7b 24 80 00 	movl   $0x80247b,(%esp)
  801cde:	e8 78 e5 ff ff       	call   80025b <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ce3:	cc                   	int3   
  801ce4:	eb fd                	jmp    801ce3 <_panic+0x53>
  801ce6:	66 90                	xchg   %ax,%ax

00801ce8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ce8:	55                   	push   %ebp
  801ce9:	89 e5                	mov    %esp,%ebp
  801ceb:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801cee:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801cf5:	75 54                	jne    801d4b <set_pgfault_handler+0x63>
		// First time through!
		// LAB 4: Your code here.
		if((r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U|PTE_P|PTE_W)))
  801cf7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801cfe:	00 
  801cff:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801d06:	ee 
  801d07:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d0e:	e8 16 f1 ff ff       	call   800e29 <sys_page_alloc>
  801d13:	85 c0                	test   %eax,%eax
  801d15:	74 20                	je     801d37 <set_pgfault_handler+0x4f>
			panic("sys_page_alloc() failed in set_pgfault_handler()[%e]\n", r);
  801d17:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d1b:	c7 44 24 08 84 25 80 	movl   $0x802584,0x8(%esp)
  801d22:	00 
  801d23:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  801d2a:	00 
  801d2b:	c7 04 24 bc 25 80 00 	movl   $0x8025bc,(%esp)
  801d32:	e8 59 ff ff ff       	call   801c90 <_panic>
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801d37:	c7 44 24 04 58 1d 80 	movl   $0x801d58,0x4(%esp)
  801d3e:	00 
  801d3f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d46:	e8 e2 f2 ff ff       	call   80102d <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801d4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d4e:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801d53:	c9                   	leave  
  801d54:	c3                   	ret    
  801d55:	66 90                	xchg   %ax,%ax
  801d57:	90                   	nop

00801d58 <_pgfault_upcall>:
  801d58:	54                   	push   %esp
  801d59:	a1 00 60 80 00       	mov    0x806000,%eax
  801d5e:	ff d0                	call   *%eax
  801d60:	83 c4 04             	add    $0x4,%esp
  801d63:	83 c4 08             	add    $0x8,%esp
  801d66:	8b 44 24 28          	mov    0x28(%esp),%eax
  801d6a:	83 e8 04             	sub    $0x4,%eax
  801d6d:	89 44 24 28          	mov    %eax,0x28(%esp)
  801d71:	8b 5c 24 20          	mov    0x20(%esp),%ebx
  801d75:	89 18                	mov    %ebx,(%eax)
  801d77:	61                   	popa   
  801d78:	83 c4 04             	add    $0x4,%esp
  801d7b:	9d                   	popf   
  801d7c:	5c                   	pop    %esp
  801d7d:	c3                   	ret    
  801d7e:	66 90                	xchg   %ax,%ax

00801d80 <__udivdi3>:
  801d80:	83 ec 1c             	sub    $0x1c,%esp
  801d83:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801d87:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801d8b:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801d8f:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801d93:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801d97:	8b 6c 24 24          	mov    0x24(%esp),%ebp
  801d9b:	85 c0                	test   %eax,%eax
  801d9d:	89 74 24 10          	mov    %esi,0x10(%esp)
  801da1:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801da5:	89 ea                	mov    %ebp,%edx
  801da7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801dab:	75 33                	jne    801de0 <__udivdi3+0x60>
  801dad:	39 e9                	cmp    %ebp,%ecx
  801daf:	77 6f                	ja     801e20 <__udivdi3+0xa0>
  801db1:	85 c9                	test   %ecx,%ecx
  801db3:	89 ce                	mov    %ecx,%esi
  801db5:	75 0b                	jne    801dc2 <__udivdi3+0x42>
  801db7:	b8 01 00 00 00       	mov    $0x1,%eax
  801dbc:	31 d2                	xor    %edx,%edx
  801dbe:	f7 f1                	div    %ecx
  801dc0:	89 c6                	mov    %eax,%esi
  801dc2:	31 d2                	xor    %edx,%edx
  801dc4:	89 e8                	mov    %ebp,%eax
  801dc6:	f7 f6                	div    %esi
  801dc8:	89 c5                	mov    %eax,%ebp
  801dca:	89 f8                	mov    %edi,%eax
  801dcc:	f7 f6                	div    %esi
  801dce:	89 ea                	mov    %ebp,%edx
  801dd0:	8b 74 24 10          	mov    0x10(%esp),%esi
  801dd4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801dd8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801ddc:	83 c4 1c             	add    $0x1c,%esp
  801ddf:	c3                   	ret    
  801de0:	39 e8                	cmp    %ebp,%eax
  801de2:	77 24                	ja     801e08 <__udivdi3+0x88>
  801de4:	0f bd c8             	bsr    %eax,%ecx
  801de7:	83 f1 1f             	xor    $0x1f,%ecx
  801dea:	89 0c 24             	mov    %ecx,(%esp)
  801ded:	75 49                	jne    801e38 <__udivdi3+0xb8>
  801def:	8b 74 24 08          	mov    0x8(%esp),%esi
  801df3:	39 74 24 04          	cmp    %esi,0x4(%esp)
  801df7:	0f 86 ab 00 00 00    	jbe    801ea8 <__udivdi3+0x128>
  801dfd:	39 e8                	cmp    %ebp,%eax
  801dff:	0f 82 a3 00 00 00    	jb     801ea8 <__udivdi3+0x128>
  801e05:	8d 76 00             	lea    0x0(%esi),%esi
  801e08:	31 d2                	xor    %edx,%edx
  801e0a:	31 c0                	xor    %eax,%eax
  801e0c:	8b 74 24 10          	mov    0x10(%esp),%esi
  801e10:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801e14:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801e18:	83 c4 1c             	add    $0x1c,%esp
  801e1b:	c3                   	ret    
  801e1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e20:	89 f8                	mov    %edi,%eax
  801e22:	f7 f1                	div    %ecx
  801e24:	31 d2                	xor    %edx,%edx
  801e26:	8b 74 24 10          	mov    0x10(%esp),%esi
  801e2a:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801e2e:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801e32:	83 c4 1c             	add    $0x1c,%esp
  801e35:	c3                   	ret    
  801e36:	66 90                	xchg   %ax,%ax
  801e38:	0f b6 0c 24          	movzbl (%esp),%ecx
  801e3c:	89 c6                	mov    %eax,%esi
  801e3e:	b8 20 00 00 00       	mov    $0x20,%eax
  801e43:	8b 6c 24 04          	mov    0x4(%esp),%ebp
  801e47:	2b 04 24             	sub    (%esp),%eax
  801e4a:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801e4e:	d3 e6                	shl    %cl,%esi
  801e50:	89 c1                	mov    %eax,%ecx
  801e52:	d3 ed                	shr    %cl,%ebp
  801e54:	0f b6 0c 24          	movzbl (%esp),%ecx
  801e58:	09 f5                	or     %esi,%ebp
  801e5a:	8b 74 24 04          	mov    0x4(%esp),%esi
  801e5e:	d3 e6                	shl    %cl,%esi
  801e60:	89 c1                	mov    %eax,%ecx
  801e62:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e66:	89 d6                	mov    %edx,%esi
  801e68:	d3 ee                	shr    %cl,%esi
  801e6a:	0f b6 0c 24          	movzbl (%esp),%ecx
  801e6e:	d3 e2                	shl    %cl,%edx
  801e70:	89 c1                	mov    %eax,%ecx
  801e72:	d3 ef                	shr    %cl,%edi
  801e74:	09 d7                	or     %edx,%edi
  801e76:	89 f2                	mov    %esi,%edx
  801e78:	89 f8                	mov    %edi,%eax
  801e7a:	f7 f5                	div    %ebp
  801e7c:	89 d6                	mov    %edx,%esi
  801e7e:	89 c7                	mov    %eax,%edi
  801e80:	f7 64 24 04          	mull   0x4(%esp)
  801e84:	39 d6                	cmp    %edx,%esi
  801e86:	72 30                	jb     801eb8 <__udivdi3+0x138>
  801e88:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801e8c:	0f b6 0c 24          	movzbl (%esp),%ecx
  801e90:	d3 e5                	shl    %cl,%ebp
  801e92:	39 c5                	cmp    %eax,%ebp
  801e94:	73 04                	jae    801e9a <__udivdi3+0x11a>
  801e96:	39 d6                	cmp    %edx,%esi
  801e98:	74 1e                	je     801eb8 <__udivdi3+0x138>
  801e9a:	89 f8                	mov    %edi,%eax
  801e9c:	31 d2                	xor    %edx,%edx
  801e9e:	e9 69 ff ff ff       	jmp    801e0c <__udivdi3+0x8c>
  801ea3:	90                   	nop
  801ea4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ea8:	31 d2                	xor    %edx,%edx
  801eaa:	b8 01 00 00 00       	mov    $0x1,%eax
  801eaf:	e9 58 ff ff ff       	jmp    801e0c <__udivdi3+0x8c>
  801eb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801eb8:	8d 47 ff             	lea    -0x1(%edi),%eax
  801ebb:	31 d2                	xor    %edx,%edx
  801ebd:	8b 74 24 10          	mov    0x10(%esp),%esi
  801ec1:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801ec5:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801ec9:	83 c4 1c             	add    $0x1c,%esp
  801ecc:	c3                   	ret    
  801ecd:	66 90                	xchg   %ax,%ax
  801ecf:	90                   	nop

00801ed0 <__umoddi3>:
  801ed0:	83 ec 2c             	sub    $0x2c,%esp
  801ed3:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801ed7:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801edb:	89 74 24 20          	mov    %esi,0x20(%esp)
  801edf:	8b 74 24 38          	mov    0x38(%esp),%esi
  801ee3:	89 7c 24 24          	mov    %edi,0x24(%esp)
  801ee7:	8b 7c 24 34          	mov    0x34(%esp),%edi
  801eeb:	85 c0                	test   %eax,%eax
  801eed:	89 c2                	mov    %eax,%edx
  801eef:	89 6c 24 28          	mov    %ebp,0x28(%esp)
  801ef3:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801ef7:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801efb:	89 74 24 10          	mov    %esi,0x10(%esp)
  801eff:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801f03:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801f07:	75 1f                	jne    801f28 <__umoddi3+0x58>
  801f09:	39 fe                	cmp    %edi,%esi
  801f0b:	76 63                	jbe    801f70 <__umoddi3+0xa0>
  801f0d:	89 c8                	mov    %ecx,%eax
  801f0f:	89 fa                	mov    %edi,%edx
  801f11:	f7 f6                	div    %esi
  801f13:	89 d0                	mov    %edx,%eax
  801f15:	31 d2                	xor    %edx,%edx
  801f17:	8b 74 24 20          	mov    0x20(%esp),%esi
  801f1b:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801f1f:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801f23:	83 c4 2c             	add    $0x2c,%esp
  801f26:	c3                   	ret    
  801f27:	90                   	nop
  801f28:	39 f8                	cmp    %edi,%eax
  801f2a:	77 64                	ja     801f90 <__umoddi3+0xc0>
  801f2c:	0f bd e8             	bsr    %eax,%ebp
  801f2f:	83 f5 1f             	xor    $0x1f,%ebp
  801f32:	75 74                	jne    801fa8 <__umoddi3+0xd8>
  801f34:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801f38:	39 7c 24 10          	cmp    %edi,0x10(%esp)
  801f3c:	0f 87 0e 01 00 00    	ja     802050 <__umoddi3+0x180>
  801f42:	8b 7c 24 0c          	mov    0xc(%esp),%edi
  801f46:	29 f1                	sub    %esi,%ecx
  801f48:	19 c7                	sbb    %eax,%edi
  801f4a:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801f4e:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801f52:	8b 44 24 14          	mov    0x14(%esp),%eax
  801f56:	8b 54 24 18          	mov    0x18(%esp),%edx
  801f5a:	8b 74 24 20          	mov    0x20(%esp),%esi
  801f5e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801f62:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801f66:	83 c4 2c             	add    $0x2c,%esp
  801f69:	c3                   	ret    
  801f6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f70:	85 f6                	test   %esi,%esi
  801f72:	89 f5                	mov    %esi,%ebp
  801f74:	75 0b                	jne    801f81 <__umoddi3+0xb1>
  801f76:	b8 01 00 00 00       	mov    $0x1,%eax
  801f7b:	31 d2                	xor    %edx,%edx
  801f7d:	f7 f6                	div    %esi
  801f7f:	89 c5                	mov    %eax,%ebp
  801f81:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801f85:	31 d2                	xor    %edx,%edx
  801f87:	f7 f5                	div    %ebp
  801f89:	89 c8                	mov    %ecx,%eax
  801f8b:	f7 f5                	div    %ebp
  801f8d:	eb 84                	jmp    801f13 <__umoddi3+0x43>
  801f8f:	90                   	nop
  801f90:	89 c8                	mov    %ecx,%eax
  801f92:	89 fa                	mov    %edi,%edx
  801f94:	8b 74 24 20          	mov    0x20(%esp),%esi
  801f98:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801f9c:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801fa0:	83 c4 2c             	add    $0x2c,%esp
  801fa3:	c3                   	ret    
  801fa4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fa8:	8b 44 24 10          	mov    0x10(%esp),%eax
  801fac:	be 20 00 00 00       	mov    $0x20,%esi
  801fb1:	89 e9                	mov    %ebp,%ecx
  801fb3:	29 ee                	sub    %ebp,%esi
  801fb5:	d3 e2                	shl    %cl,%edx
  801fb7:	89 f1                	mov    %esi,%ecx
  801fb9:	d3 e8                	shr    %cl,%eax
  801fbb:	89 e9                	mov    %ebp,%ecx
  801fbd:	09 d0                	or     %edx,%eax
  801fbf:	89 fa                	mov    %edi,%edx
  801fc1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fc5:	8b 44 24 10          	mov    0x10(%esp),%eax
  801fc9:	d3 e0                	shl    %cl,%eax
  801fcb:	89 f1                	mov    %esi,%ecx
  801fcd:	89 44 24 10          	mov    %eax,0x10(%esp)
  801fd1:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801fd5:	d3 ea                	shr    %cl,%edx
  801fd7:	89 e9                	mov    %ebp,%ecx
  801fd9:	d3 e7                	shl    %cl,%edi
  801fdb:	89 f1                	mov    %esi,%ecx
  801fdd:	d3 e8                	shr    %cl,%eax
  801fdf:	89 e9                	mov    %ebp,%ecx
  801fe1:	09 f8                	or     %edi,%eax
  801fe3:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801fe7:	f7 74 24 0c          	divl   0xc(%esp)
  801feb:	d3 e7                	shl    %cl,%edi
  801fed:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801ff1:	89 d7                	mov    %edx,%edi
  801ff3:	f7 64 24 10          	mull   0x10(%esp)
  801ff7:	39 d7                	cmp    %edx,%edi
  801ff9:	89 c1                	mov    %eax,%ecx
  801ffb:	89 54 24 14          	mov    %edx,0x14(%esp)
  801fff:	72 3b                	jb     80203c <__umoddi3+0x16c>
  802001:	39 44 24 18          	cmp    %eax,0x18(%esp)
  802005:	72 31                	jb     802038 <__umoddi3+0x168>
  802007:	8b 44 24 18          	mov    0x18(%esp),%eax
  80200b:	29 c8                	sub    %ecx,%eax
  80200d:	19 d7                	sbb    %edx,%edi
  80200f:	89 e9                	mov    %ebp,%ecx
  802011:	89 fa                	mov    %edi,%edx
  802013:	d3 e8                	shr    %cl,%eax
  802015:	89 f1                	mov    %esi,%ecx
  802017:	d3 e2                	shl    %cl,%edx
  802019:	89 e9                	mov    %ebp,%ecx
  80201b:	09 d0                	or     %edx,%eax
  80201d:	89 fa                	mov    %edi,%edx
  80201f:	d3 ea                	shr    %cl,%edx
  802021:	8b 74 24 20          	mov    0x20(%esp),%esi
  802025:	8b 7c 24 24          	mov    0x24(%esp),%edi
  802029:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  80202d:	83 c4 2c             	add    $0x2c,%esp
  802030:	c3                   	ret    
  802031:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802038:	39 d7                	cmp    %edx,%edi
  80203a:	75 cb                	jne    802007 <__umoddi3+0x137>
  80203c:	8b 54 24 14          	mov    0x14(%esp),%edx
  802040:	89 c1                	mov    %eax,%ecx
  802042:	2b 4c 24 10          	sub    0x10(%esp),%ecx
  802046:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  80204a:	eb bb                	jmp    802007 <__umoddi3+0x137>
  80204c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802050:	3b 44 24 18          	cmp    0x18(%esp),%eax
  802054:	0f 82 e8 fe ff ff    	jb     801f42 <__umoddi3+0x72>
  80205a:	e9 f3 fe ff ff       	jmp    801f52 <__umoddi3+0x82>
