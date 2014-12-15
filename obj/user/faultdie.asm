
obj/user/faultdie.debug:     file format elf32-i386


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
  80002c:	e8 63 00 00 00       	call   800094 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	66 90                	xchg   %ax,%ax
  800035:	66 90                	xchg   %ax,%ax
  800037:	66 90                	xchg   %ax,%ax
  800039:	66 90                	xchg   %ax,%ax
  80003b:	66 90                	xchg   %ax,%ax
  80003d:	66 90                	xchg   %ax,%ax
  80003f:	90                   	nop

00800040 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	83 ec 18             	sub    $0x18,%esp
  800046:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  800049:	8b 50 04             	mov    0x4(%eax),%edx
  80004c:	83 e2 07             	and    $0x7,%edx
  80004f:	89 54 24 08          	mov    %edx,0x8(%esp)
  800053:	8b 00                	mov    (%eax),%eax
  800055:	89 44 24 04          	mov    %eax,0x4(%esp)
  800059:	c7 04 24 60 1d 80 00 	movl   $0x801d60,(%esp)
  800060:	e8 3e 01 00 00       	call   8001a3 <cprintf>
	sys_env_destroy(sys_getenvid());
  800065:	e8 8d 0c 00 00       	call   800cf7 <sys_getenvid>
  80006a:	89 04 24             	mov    %eax,(%esp)
  80006d:	e8 1f 0c 00 00       	call   800c91 <sys_env_destroy>
}
  800072:	c9                   	leave  
  800073:	c3                   	ret    

00800074 <umain>:

void
umain(int argc, char **argv)
{
  800074:	55                   	push   %ebp
  800075:	89 e5                	mov    %esp,%ebp
  800077:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  80007a:	c7 04 24 40 00 80 00 	movl   $0x800040,(%esp)
  800081:	e8 f2 0f 00 00       	call   801078 <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800086:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  80008d:	00 00 00 
}
  800090:	c9                   	leave  
  800091:	c3                   	ret    
  800092:	66 90                	xchg   %ax,%ax

00800094 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 18             	sub    $0x18,%esp
  80009a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80009d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000a0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a3:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;

	thisenv = &envs[ENVX(sys_getenvid())];
  8000a6:	e8 4c 0c 00 00       	call   800cf7 <sys_getenvid>
  8000ab:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000b3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000b8:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000bd:	85 db                	test   %ebx,%ebx
  8000bf:	7e 07                	jle    8000c8 <libmain+0x34>
		binaryname = argv[0];
  8000c1:	8b 06                	mov    (%esi),%eax
  8000c3:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000c8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000cc:	89 1c 24             	mov    %ebx,(%esp)
  8000cf:	e8 a0 ff ff ff       	call   800074 <umain>

	// exit gracefully
	exit();
  8000d4:	e8 0b 00 00 00       	call   8000e4 <exit>
}
  8000d9:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000dc:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000df:	89 ec                	mov    %ebp,%esp
  8000e1:	5d                   	pop    %ebp
  8000e2:	c3                   	ret    
  8000e3:	90                   	nop

008000e4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000ea:	e8 24 12 00 00       	call   801313 <close_all>
	sys_env_destroy(0);
  8000ef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000f6:	e8 96 0b 00 00       	call   800c91 <sys_env_destroy>
}
  8000fb:	c9                   	leave  
  8000fc:	c3                   	ret    
  8000fd:	66 90                	xchg   %ax,%ax
  8000ff:	90                   	nop

00800100 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800100:	55                   	push   %ebp
  800101:	89 e5                	mov    %esp,%ebp
  800103:	53                   	push   %ebx
  800104:	83 ec 14             	sub    $0x14,%esp
  800107:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80010a:	8b 03                	mov    (%ebx),%eax
  80010c:	8b 55 08             	mov    0x8(%ebp),%edx
  80010f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800113:	83 c0 01             	add    $0x1,%eax
  800116:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800118:	3d ff 00 00 00       	cmp    $0xff,%eax
  80011d:	75 19                	jne    800138 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80011f:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800126:	00 
  800127:	8d 43 08             	lea    0x8(%ebx),%eax
  80012a:	89 04 24             	mov    %eax,(%esp)
  80012d:	e8 ee 0a 00 00       	call   800c20 <sys_cputs>
		b->idx = 0;
  800132:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800138:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80013c:	83 c4 14             	add    $0x14,%esp
  80013f:	5b                   	pop    %ebx
  800140:	5d                   	pop    %ebp
  800141:	c3                   	ret    

00800142 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800142:	55                   	push   %ebp
  800143:	89 e5                	mov    %esp,%ebp
  800145:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80014b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800152:	00 00 00 
	b.cnt = 0;
  800155:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80015c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80015f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800162:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800166:	8b 45 08             	mov    0x8(%ebp),%eax
  800169:	89 44 24 08          	mov    %eax,0x8(%esp)
  80016d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800173:	89 44 24 04          	mov    %eax,0x4(%esp)
  800177:	c7 04 24 00 01 80 00 	movl   $0x800100,(%esp)
  80017e:	e8 af 01 00 00       	call   800332 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800183:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800189:	89 44 24 04          	mov    %eax,0x4(%esp)
  80018d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800193:	89 04 24             	mov    %eax,(%esp)
  800196:	e8 85 0a 00 00       	call   800c20 <sys_cputs>

	return b.cnt;
}
  80019b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a1:	c9                   	leave  
  8001a2:	c3                   	ret    

008001a3 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a3:	55                   	push   %ebp
  8001a4:	89 e5                	mov    %esp,%ebp
  8001a6:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001a9:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b3:	89 04 24             	mov    %eax,(%esp)
  8001b6:	e8 87 ff ff ff       	call   800142 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001bb:	c9                   	leave  
  8001bc:	c3                   	ret    
  8001bd:	66 90                	xchg   %ax,%ax
  8001bf:	90                   	nop

008001c0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	57                   	push   %edi
  8001c4:	56                   	push   %esi
  8001c5:	53                   	push   %ebx
  8001c6:	83 ec 4c             	sub    $0x4c,%esp
  8001c9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8001cc:	89 d7                	mov    %edx,%edi
  8001ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001d1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8001d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8001d7:	89 5d dc             	mov    %ebx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001da:	b8 00 00 00 00       	mov    $0x0,%eax
  8001df:	39 d8                	cmp    %ebx,%eax
  8001e1:	72 17                	jb     8001fa <printnum+0x3a>
  8001e3:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8001e6:	39 5d 10             	cmp    %ebx,0x10(%ebp)
  8001e9:	76 0f                	jbe    8001fa <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001eb:	8b 75 14             	mov    0x14(%ebp),%esi
  8001ee:	83 ee 01             	sub    $0x1,%esi
  8001f1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8001f4:	85 f6                	test   %esi,%esi
  8001f6:	7f 63                	jg     80025b <printnum+0x9b>
  8001f8:	eb 75                	jmp    80026f <printnum+0xaf>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001fa:	8b 5d 18             	mov    0x18(%ebp),%ebx
  8001fd:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800201:	8b 45 14             	mov    0x14(%ebp),%eax
  800204:	83 e8 01             	sub    $0x1,%eax
  800207:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80020b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80020e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800212:	8b 44 24 08          	mov    0x8(%esp),%eax
  800216:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80021a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80021d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800220:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800227:	00 
  800228:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  80022b:	89 1c 24             	mov    %ebx,(%esp)
  80022e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800231:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800235:	e8 46 18 00 00       	call   801a80 <__udivdi3>
  80023a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80023d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800240:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800244:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800248:	89 04 24             	mov    %eax,(%esp)
  80024b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80024f:	89 fa                	mov    %edi,%edx
  800251:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800254:	e8 67 ff ff ff       	call   8001c0 <printnum>
  800259:	eb 14                	jmp    80026f <printnum+0xaf>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80025b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80025f:	8b 45 18             	mov    0x18(%ebp),%eax
  800262:	89 04 24             	mov    %eax,(%esp)
  800265:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800267:	83 ee 01             	sub    $0x1,%esi
  80026a:	75 ef                	jne    80025b <printnum+0x9b>
  80026c:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80026f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800273:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800277:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80027a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80027e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800285:	00 
  800286:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800289:	89 1c 24             	mov    %ebx,(%esp)
  80028c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80028f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800293:	e8 38 19 00 00       	call   801bd0 <__umoddi3>
  800298:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80029c:	0f be 80 86 1d 80 00 	movsbl 0x801d86(%eax),%eax
  8002a3:	89 04 24             	mov    %eax,(%esp)
  8002a6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002a9:	ff d0                	call   *%eax
}
  8002ab:	83 c4 4c             	add    $0x4c,%esp
  8002ae:	5b                   	pop    %ebx
  8002af:	5e                   	pop    %esi
  8002b0:	5f                   	pop    %edi
  8002b1:	5d                   	pop    %ebp
  8002b2:	c3                   	ret    

008002b3 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002b3:	55                   	push   %ebp
  8002b4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002b6:	83 fa 01             	cmp    $0x1,%edx
  8002b9:	7e 0e                	jle    8002c9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002bb:	8b 10                	mov    (%eax),%edx
  8002bd:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002c0:	89 08                	mov    %ecx,(%eax)
  8002c2:	8b 02                	mov    (%edx),%eax
  8002c4:	8b 52 04             	mov    0x4(%edx),%edx
  8002c7:	eb 22                	jmp    8002eb <getuint+0x38>
	else if (lflag)
  8002c9:	85 d2                	test   %edx,%edx
  8002cb:	74 10                	je     8002dd <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002cd:	8b 10                	mov    (%eax),%edx
  8002cf:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d2:	89 08                	mov    %ecx,(%eax)
  8002d4:	8b 02                	mov    (%edx),%eax
  8002d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8002db:	eb 0e                	jmp    8002eb <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002dd:	8b 10                	mov    (%eax),%edx
  8002df:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e2:	89 08                	mov    %ecx,(%eax)
  8002e4:	8b 02                	mov    (%edx),%eax
  8002e6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002eb:	5d                   	pop    %ebp
  8002ec:	c3                   	ret    

008002ed <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ed:	55                   	push   %ebp
  8002ee:	89 e5                	mov    %esp,%ebp
  8002f0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002f3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f7:	8b 10                	mov    (%eax),%edx
  8002f9:	3b 50 04             	cmp    0x4(%eax),%edx
  8002fc:	73 0a                	jae    800308 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800301:	88 0a                	mov    %cl,(%edx)
  800303:	83 c2 01             	add    $0x1,%edx
  800306:	89 10                	mov    %edx,(%eax)
}
  800308:	5d                   	pop    %ebp
  800309:	c3                   	ret    

0080030a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800310:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800313:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800317:	8b 45 10             	mov    0x10(%ebp),%eax
  80031a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80031e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800321:	89 44 24 04          	mov    %eax,0x4(%esp)
  800325:	8b 45 08             	mov    0x8(%ebp),%eax
  800328:	89 04 24             	mov    %eax,(%esp)
  80032b:	e8 02 00 00 00       	call   800332 <vprintfmt>
	va_end(ap);
}
  800330:	c9                   	leave  
  800331:	c3                   	ret    

00800332 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800332:	55                   	push   %ebp
  800333:	89 e5                	mov    %esp,%ebp
  800335:	57                   	push   %edi
  800336:	56                   	push   %esi
  800337:	53                   	push   %ebx
  800338:	83 ec 4c             	sub    $0x4c,%esp
  80033b:	8b 75 08             	mov    0x8(%ebp),%esi
  80033e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800341:	8b 7d 10             	mov    0x10(%ebp),%edi
  800344:	eb 11                	jmp    800357 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800346:	85 c0                	test   %eax,%eax
  800348:	0f 84 db 03 00 00    	je     800729 <vprintfmt+0x3f7>
				return;
			putch(ch, putdat);
  80034e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800352:	89 04 24             	mov    %eax,(%esp)
  800355:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800357:	0f b6 07             	movzbl (%edi),%eax
  80035a:	83 c7 01             	add    $0x1,%edi
  80035d:	83 f8 25             	cmp    $0x25,%eax
  800360:	75 e4                	jne    800346 <vprintfmt+0x14>
  800362:	c6 45 e4 20          	movb   $0x20,-0x1c(%ebp)
  800366:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80036d:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800374:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80037b:	ba 00 00 00 00       	mov    $0x0,%edx
  800380:	eb 2b                	jmp    8003ad <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800382:	8b 7d e0             	mov    -0x20(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800385:	c6 45 e4 2d          	movb   $0x2d,-0x1c(%ebp)
  800389:	eb 22                	jmp    8003ad <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038b:	8b 7d e0             	mov    -0x20(%ebp),%edi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80038e:	c6 45 e4 30          	movb   $0x30,-0x1c(%ebp)
  800392:	eb 19                	jmp    8003ad <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800394:	8b 7d e0             	mov    -0x20(%ebp),%edi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800397:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80039e:	eb 0d                	jmp    8003ad <vprintfmt+0x7b>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003a0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003a6:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ad:	0f b6 0f             	movzbl (%edi),%ecx
  8003b0:	8d 47 01             	lea    0x1(%edi),%eax
  8003b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003b6:	0f b6 07             	movzbl (%edi),%eax
  8003b9:	83 e8 23             	sub    $0x23,%eax
  8003bc:	3c 55                	cmp    $0x55,%al
  8003be:	0f 87 40 03 00 00    	ja     800704 <vprintfmt+0x3d2>
  8003c4:	0f b6 c0             	movzbl %al,%eax
  8003c7:	ff 24 85 c0 1e 80 00 	jmp    *0x801ec0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003ce:	83 e9 30             	sub    $0x30,%ecx
  8003d1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				ch = *fmt;
  8003d4:	0f be 47 01          	movsbl 0x1(%edi),%eax
				if (ch < '0' || ch > '9')
  8003d8:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8003db:	83 f9 09             	cmp    $0x9,%ecx
  8003de:	77 57                	ja     800437 <vprintfmt+0x105>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e0:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8003e3:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8003e6:	8b 55 dc             	mov    -0x24(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003e9:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003ec:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8003ef:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8003f3:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8003f6:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8003f9:	83 f9 09             	cmp    $0x9,%ecx
  8003fc:	76 eb                	jbe    8003e9 <vprintfmt+0xb7>
  8003fe:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800401:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800404:	eb 34                	jmp    80043a <vprintfmt+0x108>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800406:	8b 45 14             	mov    0x14(%ebp),%eax
  800409:	8d 48 04             	lea    0x4(%eax),%ecx
  80040c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80040f:	8b 00                	mov    (%eax),%eax
  800411:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800414:	8b 7d e0             	mov    -0x20(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800417:	eb 21                	jmp    80043a <vprintfmt+0x108>

		case '.':
			if (width < 0)
  800419:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80041d:	0f 88 71 ff ff ff    	js     800394 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800423:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800426:	eb 85                	jmp    8003ad <vprintfmt+0x7b>
  800428:	8b 7d e0             	mov    -0x20(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80042b:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  800432:	e9 76 ff ff ff       	jmp    8003ad <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800437:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80043a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80043e:	0f 89 69 ff ff ff    	jns    8003ad <vprintfmt+0x7b>
  800444:	e9 57 ff ff ff       	jmp    8003a0 <vprintfmt+0x6e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800449:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80044f:	e9 59 ff ff ff       	jmp    8003ad <vprintfmt+0x7b>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800454:	8b 45 14             	mov    0x14(%ebp),%eax
  800457:	8d 50 04             	lea    0x4(%eax),%edx
  80045a:	89 55 14             	mov    %edx,0x14(%ebp)
  80045d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800461:	8b 00                	mov    (%eax),%eax
  800463:	89 04 24             	mov    %eax,(%esp)
  800466:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800468:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80046b:	e9 e7 fe ff ff       	jmp    800357 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800470:	8b 45 14             	mov    0x14(%ebp),%eax
  800473:	8d 50 04             	lea    0x4(%eax),%edx
  800476:	89 55 14             	mov    %edx,0x14(%ebp)
  800479:	8b 00                	mov    (%eax),%eax
  80047b:	89 c2                	mov    %eax,%edx
  80047d:	c1 fa 1f             	sar    $0x1f,%edx
  800480:	31 d0                	xor    %edx,%eax
  800482:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800484:	83 f8 0f             	cmp    $0xf,%eax
  800487:	7f 0b                	jg     800494 <vprintfmt+0x162>
  800489:	8b 14 85 20 20 80 00 	mov    0x802020(,%eax,4),%edx
  800490:	85 d2                	test   %edx,%edx
  800492:	75 20                	jne    8004b4 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  800494:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800498:	c7 44 24 08 9e 1d 80 	movl   $0x801d9e,0x8(%esp)
  80049f:	00 
  8004a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004a4:	89 34 24             	mov    %esi,(%esp)
  8004a7:	e8 5e fe ff ff       	call   80030a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ac:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004af:	e9 a3 fe ff ff       	jmp    800357 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  8004b4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004b8:	c7 44 24 08 a7 1d 80 	movl   $0x801da7,0x8(%esp)
  8004bf:	00 
  8004c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004c4:	89 34 24             	mov    %esi,(%esp)
  8004c7:	e8 3e fe ff ff       	call   80030a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cc:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8004cf:	e9 83 fe ff ff       	jmp    800357 <vprintfmt+0x25>
  8004d4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004d7:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8004da:	89 7d cc             	mov    %edi,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e0:	8d 50 04             	lea    0x4(%eax),%edx
  8004e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004e8:	85 ff                	test   %edi,%edi
  8004ea:	b8 97 1d 80 00       	mov    $0x801d97,%eax
  8004ef:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004f2:	80 7d e4 2d          	cmpb   $0x2d,-0x1c(%ebp)
  8004f6:	74 06                	je     8004fe <vprintfmt+0x1cc>
  8004f8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004fc:	7f 16                	jg     800514 <vprintfmt+0x1e2>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004fe:	0f b6 17             	movzbl (%edi),%edx
  800501:	0f be c2             	movsbl %dl,%eax
  800504:	83 c7 01             	add    $0x1,%edi
  800507:	85 c0                	test   %eax,%eax
  800509:	0f 85 9f 00 00 00    	jne    8005ae <vprintfmt+0x27c>
  80050f:	e9 8b 00 00 00       	jmp    80059f <vprintfmt+0x26d>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800514:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800518:	89 3c 24             	mov    %edi,(%esp)
  80051b:	e8 c2 02 00 00       	call   8007e2 <strnlen>
  800520:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800523:	29 c2                	sub    %eax,%edx
  800525:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800528:	85 d2                	test   %edx,%edx
  80052a:	7e d2                	jle    8004fe <vprintfmt+0x1cc>
					putch(padc, putdat);
  80052c:	0f be 4d e4          	movsbl -0x1c(%ebp),%ecx
  800530:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800533:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800536:	89 d7                	mov    %edx,%edi
  800538:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80053c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80053f:	89 04 24             	mov    %eax,(%esp)
  800542:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800544:	83 ef 01             	sub    $0x1,%edi
  800547:	75 ef                	jne    800538 <vprintfmt+0x206>
  800549:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80054c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80054f:	eb ad                	jmp    8004fe <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800551:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800555:	74 20                	je     800577 <vprintfmt+0x245>
  800557:	0f be d2             	movsbl %dl,%edx
  80055a:	83 ea 20             	sub    $0x20,%edx
  80055d:	83 fa 5e             	cmp    $0x5e,%edx
  800560:	76 15                	jbe    800577 <vprintfmt+0x245>
					putch('?', putdat);
  800562:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800565:	89 54 24 04          	mov    %edx,0x4(%esp)
  800569:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800570:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800573:	ff d1                	call   *%ecx
  800575:	eb 0f                	jmp    800586 <vprintfmt+0x254>
				else
					putch(ch, putdat);
  800577:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80057a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80057e:	89 04 24             	mov    %eax,(%esp)
  800581:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800584:	ff d1                	call   *%ecx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800586:	83 eb 01             	sub    $0x1,%ebx
  800589:	0f b6 17             	movzbl (%edi),%edx
  80058c:	0f be c2             	movsbl %dl,%eax
  80058f:	83 c7 01             	add    $0x1,%edi
  800592:	85 c0                	test   %eax,%eax
  800594:	75 24                	jne    8005ba <vprintfmt+0x288>
  800596:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800599:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80059c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059f:	8b 7d e0             	mov    -0x20(%ebp),%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005a2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005a6:	0f 8e ab fd ff ff    	jle    800357 <vprintfmt+0x25>
  8005ac:	eb 20                	jmp    8005ce <vprintfmt+0x29c>
  8005ae:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  8005b1:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8005b4:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8005b7:	8b 5d d8             	mov    -0x28(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ba:	85 f6                	test   %esi,%esi
  8005bc:	78 93                	js     800551 <vprintfmt+0x21f>
  8005be:	83 ee 01             	sub    $0x1,%esi
  8005c1:	79 8e                	jns    800551 <vprintfmt+0x21f>
  8005c3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8005c6:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8005c9:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8005cc:	eb d1                	jmp    80059f <vprintfmt+0x26d>
  8005ce:	8b 7d d8             	mov    -0x28(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005d1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005dc:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005de:	83 ef 01             	sub    $0x1,%edi
  8005e1:	75 ee                	jne    8005d1 <vprintfmt+0x29f>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e3:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005e6:	e9 6c fd ff ff       	jmp    800357 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005eb:	83 fa 01             	cmp    $0x1,%edx
  8005ee:	66 90                	xchg   %ax,%ax
  8005f0:	7e 16                	jle    800608 <vprintfmt+0x2d6>
		return va_arg(*ap, long long);
  8005f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f5:	8d 50 08             	lea    0x8(%eax),%edx
  8005f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fb:	8b 10                	mov    (%eax),%edx
  8005fd:	8b 48 04             	mov    0x4(%eax),%ecx
  800600:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800603:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800606:	eb 32                	jmp    80063a <vprintfmt+0x308>
	else if (lflag)
  800608:	85 d2                	test   %edx,%edx
  80060a:	74 18                	je     800624 <vprintfmt+0x2f2>
		return va_arg(*ap, long);
  80060c:	8b 45 14             	mov    0x14(%ebp),%eax
  80060f:	8d 50 04             	lea    0x4(%eax),%edx
  800612:	89 55 14             	mov    %edx,0x14(%ebp)
  800615:	8b 00                	mov    (%eax),%eax
  800617:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80061a:	89 c1                	mov    %eax,%ecx
  80061c:	c1 f9 1f             	sar    $0x1f,%ecx
  80061f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800622:	eb 16                	jmp    80063a <vprintfmt+0x308>
	else
		return va_arg(*ap, int);
  800624:	8b 45 14             	mov    0x14(%ebp),%eax
  800627:	8d 50 04             	lea    0x4(%eax),%edx
  80062a:	89 55 14             	mov    %edx,0x14(%ebp)
  80062d:	8b 00                	mov    (%eax),%eax
  80062f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800632:	89 c7                	mov    %eax,%edi
  800634:	c1 ff 1f             	sar    $0x1f,%edi
  800637:	89 7d d4             	mov    %edi,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80063a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80063d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800640:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800645:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800649:	79 7d                	jns    8006c8 <vprintfmt+0x396>
				putch('-', putdat);
  80064b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80064f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800656:	ff d6                	call   *%esi
				num = -(long long) num;
  800658:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80065b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80065e:	f7 d8                	neg    %eax
  800660:	83 d2 00             	adc    $0x0,%edx
  800663:	f7 da                	neg    %edx
			}
			base = 10;
  800665:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80066a:	eb 5c                	jmp    8006c8 <vprintfmt+0x396>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80066c:	8d 45 14             	lea    0x14(%ebp),%eax
  80066f:	e8 3f fc ff ff       	call   8002b3 <getuint>
			base = 10;
  800674:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800679:	eb 4d                	jmp    8006c8 <vprintfmt+0x396>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80067b:	8d 45 14             	lea    0x14(%ebp),%eax
  80067e:	e8 30 fc ff ff       	call   8002b3 <getuint>
			base = 8;
  800683:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800688:	eb 3e                	jmp    8006c8 <vprintfmt+0x396>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80068a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80068e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800695:	ff d6                	call   *%esi
			putch('x', putdat);
  800697:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80069b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006a2:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a7:	8d 50 04             	lea    0x4(%eax),%edx
  8006aa:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006ad:	8b 00                	mov    (%eax),%eax
  8006af:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006b4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006b9:	eb 0d                	jmp    8006c8 <vprintfmt+0x396>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006bb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006be:	e8 f0 fb ff ff       	call   8002b3 <getuint>
			base = 16;
  8006c3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006c8:	0f be 7d e4          	movsbl -0x1c(%ebp),%edi
  8006cc:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8006d0:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8006d3:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8006d7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8006db:	89 04 24             	mov    %eax,(%esp)
  8006de:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006e2:	89 da                	mov    %ebx,%edx
  8006e4:	89 f0                	mov    %esi,%eax
  8006e6:	e8 d5 fa ff ff       	call   8001c0 <printnum>
			break;
  8006eb:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8006ee:	e9 64 fc ff ff       	jmp    800357 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006f3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f7:	89 0c 24             	mov    %ecx,(%esp)
  8006fa:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006fc:	8b 7d e0             	mov    -0x20(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006ff:	e9 53 fc ff ff       	jmp    800357 <vprintfmt+0x25>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800704:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800708:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80070f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800711:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800715:	0f 84 3c fc ff ff    	je     800357 <vprintfmt+0x25>
  80071b:	83 ef 01             	sub    $0x1,%edi
  80071e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800722:	75 f7                	jne    80071b <vprintfmt+0x3e9>
  800724:	e9 2e fc ff ff       	jmp    800357 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800729:	83 c4 4c             	add    $0x4c,%esp
  80072c:	5b                   	pop    %ebx
  80072d:	5e                   	pop    %esi
  80072e:	5f                   	pop    %edi
  80072f:	5d                   	pop    %ebp
  800730:	c3                   	ret    

00800731 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800731:	55                   	push   %ebp
  800732:	89 e5                	mov    %esp,%ebp
  800734:	83 ec 28             	sub    $0x28,%esp
  800737:	8b 45 08             	mov    0x8(%ebp),%eax
  80073a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80073d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800740:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800744:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800747:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80074e:	85 d2                	test   %edx,%edx
  800750:	7e 30                	jle    800782 <vsnprintf+0x51>
  800752:	85 c0                	test   %eax,%eax
  800754:	74 2c                	je     800782 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800756:	8b 45 14             	mov    0x14(%ebp),%eax
  800759:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80075d:	8b 45 10             	mov    0x10(%ebp),%eax
  800760:	89 44 24 08          	mov    %eax,0x8(%esp)
  800764:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800767:	89 44 24 04          	mov    %eax,0x4(%esp)
  80076b:	c7 04 24 ed 02 80 00 	movl   $0x8002ed,(%esp)
  800772:	e8 bb fb ff ff       	call   800332 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800777:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80077a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80077d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800780:	eb 05                	jmp    800787 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800782:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800787:	c9                   	leave  
  800788:	c3                   	ret    

00800789 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800789:	55                   	push   %ebp
  80078a:	89 e5                	mov    %esp,%ebp
  80078c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80078f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800792:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800796:	8b 45 10             	mov    0x10(%ebp),%eax
  800799:	89 44 24 08          	mov    %eax,0x8(%esp)
  80079d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a7:	89 04 24             	mov    %eax,(%esp)
  8007aa:	e8 82 ff ff ff       	call   800731 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007af:	c9                   	leave  
  8007b0:	c3                   	ret    
  8007b1:	66 90                	xchg   %ax,%ax
  8007b3:	66 90                	xchg   %ax,%ax
  8007b5:	66 90                	xchg   %ax,%ax
  8007b7:	66 90                	xchg   %ax,%ax
  8007b9:	66 90                	xchg   %ax,%ax
  8007bb:	66 90                	xchg   %ax,%ax
  8007bd:	66 90                	xchg   %ax,%ax
  8007bf:	90                   	nop

008007c0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c6:	80 3a 00             	cmpb   $0x0,(%edx)
  8007c9:	74 10                	je     8007db <strlen+0x1b>
  8007cb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007d0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007d7:	75 f7                	jne    8007d0 <strlen+0x10>
  8007d9:	eb 05                	jmp    8007e0 <strlen+0x20>
  8007db:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007e0:	5d                   	pop    %ebp
  8007e1:	c3                   	ret    

008007e2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007e2:	55                   	push   %ebp
  8007e3:	89 e5                	mov    %esp,%ebp
  8007e5:	53                   	push   %ebx
  8007e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ec:	85 c9                	test   %ecx,%ecx
  8007ee:	74 1c                	je     80080c <strnlen+0x2a>
  8007f0:	80 3b 00             	cmpb   $0x0,(%ebx)
  8007f3:	74 1e                	je     800813 <strnlen+0x31>
  8007f5:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8007fa:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007fc:	39 ca                	cmp    %ecx,%edx
  8007fe:	74 18                	je     800818 <strnlen+0x36>
  800800:	83 c2 01             	add    $0x1,%edx
  800803:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800808:	75 f0                	jne    8007fa <strnlen+0x18>
  80080a:	eb 0c                	jmp    800818 <strnlen+0x36>
  80080c:	b8 00 00 00 00       	mov    $0x0,%eax
  800811:	eb 05                	jmp    800818 <strnlen+0x36>
  800813:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800818:	5b                   	pop    %ebx
  800819:	5d                   	pop    %ebp
  80081a:	c3                   	ret    

0080081b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	53                   	push   %ebx
  80081f:	8b 45 08             	mov    0x8(%ebp),%eax
  800822:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800825:	89 c2                	mov    %eax,%edx
  800827:	0f b6 19             	movzbl (%ecx),%ebx
  80082a:	88 1a                	mov    %bl,(%edx)
  80082c:	83 c2 01             	add    $0x1,%edx
  80082f:	83 c1 01             	add    $0x1,%ecx
  800832:	84 db                	test   %bl,%bl
  800834:	75 f1                	jne    800827 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800836:	5b                   	pop    %ebx
  800837:	5d                   	pop    %ebp
  800838:	c3                   	ret    

00800839 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800839:	55                   	push   %ebp
  80083a:	89 e5                	mov    %esp,%ebp
  80083c:	53                   	push   %ebx
  80083d:	83 ec 08             	sub    $0x8,%esp
  800840:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800843:	89 1c 24             	mov    %ebx,(%esp)
  800846:	e8 75 ff ff ff       	call   8007c0 <strlen>
	strcpy(dst + len, src);
  80084b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800852:	01 d8                	add    %ebx,%eax
  800854:	89 04 24             	mov    %eax,(%esp)
  800857:	e8 bf ff ff ff       	call   80081b <strcpy>
	return dst;
}
  80085c:	89 d8                	mov    %ebx,%eax
  80085e:	83 c4 08             	add    $0x8,%esp
  800861:	5b                   	pop    %ebx
  800862:	5d                   	pop    %ebp
  800863:	c3                   	ret    

00800864 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800864:	55                   	push   %ebp
  800865:	89 e5                	mov    %esp,%ebp
  800867:	56                   	push   %esi
  800868:	53                   	push   %ebx
  800869:	8b 75 08             	mov    0x8(%ebp),%esi
  80086c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80086f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800872:	85 db                	test   %ebx,%ebx
  800874:	74 16                	je     80088c <strncpy+0x28>
	strcpy(dst + len, src);
	return dst;
}

char *
strncpy(char *dst, const char *src, size_t size) {
  800876:	01 f3                	add    %esi,%ebx
  800878:	89 f1                	mov    %esi,%ecx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  80087a:	0f b6 02             	movzbl (%edx),%eax
  80087d:	88 01                	mov    %al,(%ecx)
  80087f:	83 c1 01             	add    $0x1,%ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800882:	80 3a 01             	cmpb   $0x1,(%edx)
  800885:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800888:	39 d9                	cmp    %ebx,%ecx
  80088a:	75 ee                	jne    80087a <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80088c:	89 f0                	mov    %esi,%eax
  80088e:	5b                   	pop    %ebx
  80088f:	5e                   	pop    %esi
  800890:	5d                   	pop    %ebp
  800891:	c3                   	ret    

00800892 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800892:	55                   	push   %ebp
  800893:	89 e5                	mov    %esp,%ebp
  800895:	57                   	push   %edi
  800896:	56                   	push   %esi
  800897:	53                   	push   %ebx
  800898:	8b 7d 08             	mov    0x8(%ebp),%edi
  80089b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80089e:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008a1:	89 f8                	mov    %edi,%eax
  8008a3:	85 f6                	test   %esi,%esi
  8008a5:	74 33                	je     8008da <strlcpy+0x48>
		while (--size > 0 && *src != '\0')
  8008a7:	83 fe 01             	cmp    $0x1,%esi
  8008aa:	74 25                	je     8008d1 <strlcpy+0x3f>
  8008ac:	0f b6 0b             	movzbl (%ebx),%ecx
  8008af:	84 c9                	test   %cl,%cl
  8008b1:	74 22                	je     8008d5 <strlcpy+0x43>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8008b3:	83 ee 02             	sub    $0x2,%esi
  8008b6:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008bb:	88 08                	mov    %cl,(%eax)
  8008bd:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008c0:	39 f2                	cmp    %esi,%edx
  8008c2:	74 13                	je     8008d7 <strlcpy+0x45>
  8008c4:	83 c2 01             	add    $0x1,%edx
  8008c7:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8008cb:	84 c9                	test   %cl,%cl
  8008cd:	75 ec                	jne    8008bb <strlcpy+0x29>
  8008cf:	eb 06                	jmp    8008d7 <strlcpy+0x45>
  8008d1:	89 f8                	mov    %edi,%eax
  8008d3:	eb 02                	jmp    8008d7 <strlcpy+0x45>
  8008d5:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008d7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008da:	29 f8                	sub    %edi,%eax
}
  8008dc:	5b                   	pop    %ebx
  8008dd:	5e                   	pop    %esi
  8008de:	5f                   	pop    %edi
  8008df:	5d                   	pop    %ebp
  8008e0:	c3                   	ret    

008008e1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008e1:	55                   	push   %ebp
  8008e2:	89 e5                	mov    %esp,%ebp
  8008e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008e7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008ea:	0f b6 01             	movzbl (%ecx),%eax
  8008ed:	84 c0                	test   %al,%al
  8008ef:	74 15                	je     800906 <strcmp+0x25>
  8008f1:	3a 02                	cmp    (%edx),%al
  8008f3:	75 11                	jne    800906 <strcmp+0x25>
		p++, q++;
  8008f5:	83 c1 01             	add    $0x1,%ecx
  8008f8:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008fb:	0f b6 01             	movzbl (%ecx),%eax
  8008fe:	84 c0                	test   %al,%al
  800900:	74 04                	je     800906 <strcmp+0x25>
  800902:	3a 02                	cmp    (%edx),%al
  800904:	74 ef                	je     8008f5 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800906:	0f b6 c0             	movzbl %al,%eax
  800909:	0f b6 12             	movzbl (%edx),%edx
  80090c:	29 d0                	sub    %edx,%eax
}
  80090e:	5d                   	pop    %ebp
  80090f:	c3                   	ret    

00800910 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800910:	55                   	push   %ebp
  800911:	89 e5                	mov    %esp,%ebp
  800913:	56                   	push   %esi
  800914:	53                   	push   %ebx
  800915:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800918:	8b 55 0c             	mov    0xc(%ebp),%edx
  80091b:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  80091e:	85 f6                	test   %esi,%esi
  800920:	74 29                	je     80094b <strncmp+0x3b>
  800922:	0f b6 03             	movzbl (%ebx),%eax
  800925:	84 c0                	test   %al,%al
  800927:	74 30                	je     800959 <strncmp+0x49>
  800929:	3a 02                	cmp    (%edx),%al
  80092b:	75 2c                	jne    800959 <strncmp+0x49>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}

int
strncmp(const char *p, const char *q, size_t n)
  80092d:	8d 43 01             	lea    0x1(%ebx),%eax
  800930:	01 de                	add    %ebx,%esi
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800932:	89 c3                	mov    %eax,%ebx
  800934:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800937:	39 f0                	cmp    %esi,%eax
  800939:	74 17                	je     800952 <strncmp+0x42>
  80093b:	0f b6 08             	movzbl (%eax),%ecx
  80093e:	84 c9                	test   %cl,%cl
  800940:	74 17                	je     800959 <strncmp+0x49>
  800942:	83 c0 01             	add    $0x1,%eax
  800945:	3a 0a                	cmp    (%edx),%cl
  800947:	74 e9                	je     800932 <strncmp+0x22>
  800949:	eb 0e                	jmp    800959 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  80094b:	b8 00 00 00 00       	mov    $0x0,%eax
  800950:	eb 0f                	jmp    800961 <strncmp+0x51>
  800952:	b8 00 00 00 00       	mov    $0x0,%eax
  800957:	eb 08                	jmp    800961 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800959:	0f b6 03             	movzbl (%ebx),%eax
  80095c:	0f b6 12             	movzbl (%edx),%edx
  80095f:	29 d0                	sub    %edx,%eax
}
  800961:	5b                   	pop    %ebx
  800962:	5e                   	pop    %esi
  800963:	5d                   	pop    %ebp
  800964:	c3                   	ret    

00800965 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800965:	55                   	push   %ebp
  800966:	89 e5                	mov    %esp,%ebp
  800968:	53                   	push   %ebx
  800969:	8b 45 08             	mov    0x8(%ebp),%eax
  80096c:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  80096f:	0f b6 18             	movzbl (%eax),%ebx
  800972:	84 db                	test   %bl,%bl
  800974:	74 1d                	je     800993 <strchr+0x2e>
  800976:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800978:	38 d3                	cmp    %dl,%bl
  80097a:	75 06                	jne    800982 <strchr+0x1d>
  80097c:	eb 1a                	jmp    800998 <strchr+0x33>
  80097e:	38 ca                	cmp    %cl,%dl
  800980:	74 16                	je     800998 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800982:	83 c0 01             	add    $0x1,%eax
  800985:	0f b6 10             	movzbl (%eax),%edx
  800988:	84 d2                	test   %dl,%dl
  80098a:	75 f2                	jne    80097e <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  80098c:	b8 00 00 00 00       	mov    $0x0,%eax
  800991:	eb 05                	jmp    800998 <strchr+0x33>
  800993:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800998:	5b                   	pop    %ebx
  800999:	5d                   	pop    %ebp
  80099a:	c3                   	ret    

0080099b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	53                   	push   %ebx
  80099f:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a2:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  8009a5:	0f b6 18             	movzbl (%eax),%ebx
  8009a8:	84 db                	test   %bl,%bl
  8009aa:	74 16                	je     8009c2 <strfind+0x27>
  8009ac:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  8009ae:	38 d3                	cmp    %dl,%bl
  8009b0:	75 06                	jne    8009b8 <strfind+0x1d>
  8009b2:	eb 0e                	jmp    8009c2 <strfind+0x27>
  8009b4:	38 ca                	cmp    %cl,%dl
  8009b6:	74 0a                	je     8009c2 <strfind+0x27>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009b8:	83 c0 01             	add    $0x1,%eax
  8009bb:	0f b6 10             	movzbl (%eax),%edx
  8009be:	84 d2                	test   %dl,%dl
  8009c0:	75 f2                	jne    8009b4 <strfind+0x19>
		if (*s == c)
			break;
	return (char *) s;
}
  8009c2:	5b                   	pop    %ebx
  8009c3:	5d                   	pop    %ebp
  8009c4:	c3                   	ret    

008009c5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009c5:	55                   	push   %ebp
  8009c6:	89 e5                	mov    %esp,%ebp
  8009c8:	83 ec 0c             	sub    $0xc,%esp
  8009cb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8009ce:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8009d1:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8009d4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009d7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009da:	85 c9                	test   %ecx,%ecx
  8009dc:	74 36                	je     800a14 <memset+0x4f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009de:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009e4:	75 28                	jne    800a0e <memset+0x49>
  8009e6:	f6 c1 03             	test   $0x3,%cl
  8009e9:	75 23                	jne    800a0e <memset+0x49>
		c &= 0xFF;
  8009eb:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009ef:	89 d3                	mov    %edx,%ebx
  8009f1:	c1 e3 08             	shl    $0x8,%ebx
  8009f4:	89 d6                	mov    %edx,%esi
  8009f6:	c1 e6 18             	shl    $0x18,%esi
  8009f9:	89 d0                	mov    %edx,%eax
  8009fb:	c1 e0 10             	shl    $0x10,%eax
  8009fe:	09 f0                	or     %esi,%eax
  800a00:	09 c2                	or     %eax,%edx
  800a02:	89 d0                	mov    %edx,%eax
  800a04:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a06:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a09:	fc                   	cld    
  800a0a:	f3 ab                	rep stos %eax,%es:(%edi)
  800a0c:	eb 06                	jmp    800a14 <memset+0x4f>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a11:	fc                   	cld    
  800a12:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");

	return v;
}
  800a14:	89 f8                	mov    %edi,%eax
  800a16:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800a19:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800a1c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800a1f:	89 ec                	mov    %ebp,%esp
  800a21:	5d                   	pop    %ebp
  800a22:	c3                   	ret    

00800a23 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a23:	55                   	push   %ebp
  800a24:	89 e5                	mov    %esp,%ebp
  800a26:	83 ec 08             	sub    $0x8,%esp
  800a29:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800a2c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800a2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a32:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a35:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a38:	39 c6                	cmp    %eax,%esi
  800a3a:	73 36                	jae    800a72 <memmove+0x4f>
  800a3c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a3f:	39 d0                	cmp    %edx,%eax
  800a41:	73 2f                	jae    800a72 <memmove+0x4f>
		s += n;
		d += n;
  800a43:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a46:	f6 c2 03             	test   $0x3,%dl
  800a49:	75 1b                	jne    800a66 <memmove+0x43>
  800a4b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a51:	75 13                	jne    800a66 <memmove+0x43>
  800a53:	f6 c1 03             	test   $0x3,%cl
  800a56:	75 0e                	jne    800a66 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a58:	83 ef 04             	sub    $0x4,%edi
  800a5b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a5e:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a61:	fd                   	std    
  800a62:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a64:	eb 09                	jmp    800a6f <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a66:	83 ef 01             	sub    $0x1,%edi
  800a69:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a6c:	fd                   	std    
  800a6d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a6f:	fc                   	cld    
  800a70:	eb 20                	jmp    800a92 <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a72:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a78:	75 13                	jne    800a8d <memmove+0x6a>
  800a7a:	a8 03                	test   $0x3,%al
  800a7c:	75 0f                	jne    800a8d <memmove+0x6a>
  800a7e:	f6 c1 03             	test   $0x3,%cl
  800a81:	75 0a                	jne    800a8d <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a83:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a86:	89 c7                	mov    %eax,%edi
  800a88:	fc                   	cld    
  800a89:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a8b:	eb 05                	jmp    800a92 <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a8d:	89 c7                	mov    %eax,%edi
  800a8f:	fc                   	cld    
  800a90:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a92:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800a95:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800a98:	89 ec                	mov    %ebp,%esp
  800a9a:	5d                   	pop    %ebp
  800a9b:	c3                   	ret    

00800a9c <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800a9c:	55                   	push   %ebp
  800a9d:	89 e5                	mov    %esp,%ebp
  800a9f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800aa2:	8b 45 10             	mov    0x10(%ebp),%eax
  800aa5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aa9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aac:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ab0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab3:	89 04 24             	mov    %eax,(%esp)
  800ab6:	e8 68 ff ff ff       	call   800a23 <memmove>
}
  800abb:	c9                   	leave  
  800abc:	c3                   	ret    

00800abd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800abd:	55                   	push   %ebp
  800abe:	89 e5                	mov    %esp,%ebp
  800ac0:	57                   	push   %edi
  800ac1:	56                   	push   %esi
  800ac2:	53                   	push   %ebx
  800ac3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ac6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac9:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800acc:	8d 78 ff             	lea    -0x1(%eax),%edi
  800acf:	85 c0                	test   %eax,%eax
  800ad1:	74 36                	je     800b09 <memcmp+0x4c>
		if (*s1 != *s2)
  800ad3:	0f b6 03             	movzbl (%ebx),%eax
  800ad6:	0f b6 0e             	movzbl (%esi),%ecx
  800ad9:	38 c8                	cmp    %cl,%al
  800adb:	75 17                	jne    800af4 <memcmp+0x37>
  800add:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae2:	eb 1a                	jmp    800afe <memcmp+0x41>
  800ae4:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800ae9:	83 c2 01             	add    $0x1,%edx
  800aec:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800af0:	38 c8                	cmp    %cl,%al
  800af2:	74 0a                	je     800afe <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800af4:	0f b6 c0             	movzbl %al,%eax
  800af7:	0f b6 c9             	movzbl %cl,%ecx
  800afa:	29 c8                	sub    %ecx,%eax
  800afc:	eb 10                	jmp    800b0e <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800afe:	39 fa                	cmp    %edi,%edx
  800b00:	75 e2                	jne    800ae4 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b02:	b8 00 00 00 00       	mov    $0x0,%eax
  800b07:	eb 05                	jmp    800b0e <memcmp+0x51>
  800b09:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b0e:	5b                   	pop    %ebx
  800b0f:	5e                   	pop    %esi
  800b10:	5f                   	pop    %edi
  800b11:	5d                   	pop    %ebp
  800b12:	c3                   	ret    

00800b13 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b13:	55                   	push   %ebp
  800b14:	89 e5                	mov    %esp,%ebp
  800b16:	53                   	push   %ebx
  800b17:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800b1d:	89 c2                	mov    %eax,%edx
  800b1f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b22:	39 d0                	cmp    %edx,%eax
  800b24:	73 13                	jae    800b39 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b26:	89 d9                	mov    %ebx,%ecx
  800b28:	38 18                	cmp    %bl,(%eax)
  800b2a:	75 06                	jne    800b32 <memfind+0x1f>
  800b2c:	eb 0b                	jmp    800b39 <memfind+0x26>
  800b2e:	38 08                	cmp    %cl,(%eax)
  800b30:	74 07                	je     800b39 <memfind+0x26>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b32:	83 c0 01             	add    $0x1,%eax
  800b35:	39 d0                	cmp    %edx,%eax
  800b37:	75 f5                	jne    800b2e <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b39:	5b                   	pop    %ebx
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    

00800b3c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	57                   	push   %edi
  800b40:	56                   	push   %esi
  800b41:	53                   	push   %ebx
  800b42:	83 ec 04             	sub    $0x4,%esp
  800b45:	8b 55 08             	mov    0x8(%ebp),%edx
  800b48:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b4b:	0f b6 02             	movzbl (%edx),%eax
  800b4e:	3c 09                	cmp    $0x9,%al
  800b50:	74 04                	je     800b56 <strtol+0x1a>
  800b52:	3c 20                	cmp    $0x20,%al
  800b54:	75 0e                	jne    800b64 <strtol+0x28>
		s++;
  800b56:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b59:	0f b6 02             	movzbl (%edx),%eax
  800b5c:	3c 09                	cmp    $0x9,%al
  800b5e:	74 f6                	je     800b56 <strtol+0x1a>
  800b60:	3c 20                	cmp    $0x20,%al
  800b62:	74 f2                	je     800b56 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b64:	3c 2b                	cmp    $0x2b,%al
  800b66:	75 0a                	jne    800b72 <strtol+0x36>
		s++;
  800b68:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b6b:	bf 00 00 00 00       	mov    $0x0,%edi
  800b70:	eb 10                	jmp    800b82 <strtol+0x46>
  800b72:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b77:	3c 2d                	cmp    $0x2d,%al
  800b79:	75 07                	jne    800b82 <strtol+0x46>
		s++, neg = 1;
  800b7b:	83 c2 01             	add    $0x1,%edx
  800b7e:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b82:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b88:	75 15                	jne    800b9f <strtol+0x63>
  800b8a:	80 3a 30             	cmpb   $0x30,(%edx)
  800b8d:	75 10                	jne    800b9f <strtol+0x63>
  800b8f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b93:	75 0a                	jne    800b9f <strtol+0x63>
		s += 2, base = 16;
  800b95:	83 c2 02             	add    $0x2,%edx
  800b98:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b9d:	eb 10                	jmp    800baf <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800b9f:	85 db                	test   %ebx,%ebx
  800ba1:	75 0c                	jne    800baf <strtol+0x73>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ba3:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ba5:	80 3a 30             	cmpb   $0x30,(%edx)
  800ba8:	75 05                	jne    800baf <strtol+0x73>
		s++, base = 8;
  800baa:	83 c2 01             	add    $0x1,%edx
  800bad:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800baf:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb4:	89 5d f0             	mov    %ebx,-0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bb7:	0f b6 0a             	movzbl (%edx),%ecx
  800bba:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800bbd:	89 f3                	mov    %esi,%ebx
  800bbf:	80 fb 09             	cmp    $0x9,%bl
  800bc2:	77 08                	ja     800bcc <strtol+0x90>
			dig = *s - '0';
  800bc4:	0f be c9             	movsbl %cl,%ecx
  800bc7:	83 e9 30             	sub    $0x30,%ecx
  800bca:	eb 22                	jmp    800bee <strtol+0xb2>
		else if (*s >= 'a' && *s <= 'z')
  800bcc:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800bcf:	89 f3                	mov    %esi,%ebx
  800bd1:	80 fb 19             	cmp    $0x19,%bl
  800bd4:	77 08                	ja     800bde <strtol+0xa2>
			dig = *s - 'a' + 10;
  800bd6:	0f be c9             	movsbl %cl,%ecx
  800bd9:	83 e9 57             	sub    $0x57,%ecx
  800bdc:	eb 10                	jmp    800bee <strtol+0xb2>
		else if (*s >= 'A' && *s <= 'Z')
  800bde:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800be1:	89 f3                	mov    %esi,%ebx
  800be3:	80 fb 19             	cmp    $0x19,%bl
  800be6:	77 16                	ja     800bfe <strtol+0xc2>
			dig = *s - 'A' + 10;
  800be8:	0f be c9             	movsbl %cl,%ecx
  800beb:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bee:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800bf1:	7d 0f                	jge    800c02 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800bf3:	83 c2 01             	add    $0x1,%edx
  800bf6:	0f af 45 f0          	imul   -0x10(%ebp),%eax
  800bfa:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800bfc:	eb b9                	jmp    800bb7 <strtol+0x7b>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800bfe:	89 c1                	mov    %eax,%ecx
  800c00:	eb 02                	jmp    800c04 <strtol+0xc8>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c02:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c04:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c08:	74 05                	je     800c0f <strtol+0xd3>
		*endptr = (char *) s;
  800c0a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c0d:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c0f:	89 ca                	mov    %ecx,%edx
  800c11:	f7 da                	neg    %edx
  800c13:	85 ff                	test   %edi,%edi
  800c15:	0f 45 c2             	cmovne %edx,%eax
}
  800c18:	83 c4 04             	add    $0x4,%esp
  800c1b:	5b                   	pop    %ebx
  800c1c:	5e                   	pop    %esi
  800c1d:	5f                   	pop    %edi
  800c1e:	5d                   	pop    %ebp
  800c1f:	c3                   	ret    

00800c20 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c20:	55                   	push   %ebp
  800c21:	89 e5                	mov    %esp,%ebp
  800c23:	83 ec 0c             	sub    $0xc,%esp
  800c26:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c29:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c2c:	89 7d fc             	mov    %edi,-0x4(%ebp)
static inline uint32_t

get_cpu_features(void)
{
	uint32_t feature;
	__asm __volatile(" movl $1, %%eax\n\t"
  800c2f:	b8 01 00 00 00       	mov    $0x1,%eax
  800c34:	0f a2                	cpuid  
  800c36:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c38:	b8 00 00 00 00       	mov    $0x0,%eax
  800c3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c40:	8b 55 08             	mov    0x8(%ebp),%edx
  800c43:	89 c3                	mov    %eax,%ebx
  800c45:	89 c7                	mov    %eax,%edi
  800c47:	89 c6                	mov    %eax,%esi
  800c49:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c4b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c4e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c51:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c54:	89 ec                	mov    %ebp,%esp
  800c56:	5d                   	pop    %ebp
  800c57:	c3                   	ret    

00800c58 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c58:	55                   	push   %ebp
  800c59:	89 e5                	mov    %esp,%ebp
  800c5b:	83 ec 0c             	sub    $0xc,%esp
  800c5e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c61:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c64:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800c67:	b8 01 00 00 00       	mov    $0x1,%eax
  800c6c:	0f a2                	cpuid  
  800c6e:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c70:	ba 00 00 00 00       	mov    $0x0,%edx
  800c75:	b8 01 00 00 00       	mov    $0x1,%eax
  800c7a:	89 d1                	mov    %edx,%ecx
  800c7c:	89 d3                	mov    %edx,%ebx
  800c7e:	89 d7                	mov    %edx,%edi
  800c80:	89 d6                	mov    %edx,%esi
  800c82:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c84:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c87:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c8a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c8d:	89 ec                	mov    %ebp,%esp
  800c8f:	5d                   	pop    %ebp
  800c90:	c3                   	ret    

00800c91 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c91:	55                   	push   %ebp
  800c92:	89 e5                	mov    %esp,%ebp
  800c94:	83 ec 38             	sub    $0x38,%esp
  800c97:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c9a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c9d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800ca0:	b8 01 00 00 00       	mov    $0x1,%eax
  800ca5:	0f a2                	cpuid  
  800ca7:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cae:	b8 03 00 00 00       	mov    $0x3,%eax
  800cb3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb6:	89 cb                	mov    %ecx,%ebx
  800cb8:	89 cf                	mov    %ecx,%edi
  800cba:	89 ce                	mov    %ecx,%esi
  800cbc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cbe:	85 c0                	test   %eax,%eax
  800cc0:	7e 28                	jle    800cea <sys_env_destroy+0x59>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cc6:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800ccd:	00 
  800cce:	c7 44 24 08 7f 20 80 	movl   $0x80207f,0x8(%esp)
  800cd5:	00 
  800cd6:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800cdd:	00 
  800cde:	c7 04 24 9c 20 80 00 	movl   $0x80209c,(%esp)
  800ce5:	e8 26 0c 00 00       	call   801910 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cea:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ced:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cf0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cf3:	89 ec                	mov    %ebp,%esp
  800cf5:	5d                   	pop    %ebp
  800cf6:	c3                   	ret    

00800cf7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cf7:	55                   	push   %ebp
  800cf8:	89 e5                	mov    %esp,%ebp
  800cfa:	83 ec 0c             	sub    $0xc,%esp
  800cfd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d00:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d03:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d06:	b8 01 00 00 00       	mov    $0x1,%eax
  800d0b:	0f a2                	cpuid  
  800d0d:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0f:	ba 00 00 00 00       	mov    $0x0,%edx
  800d14:	b8 02 00 00 00       	mov    $0x2,%eax
  800d19:	89 d1                	mov    %edx,%ecx
  800d1b:	89 d3                	mov    %edx,%ebx
  800d1d:	89 d7                	mov    %edx,%edi
  800d1f:	89 d6                	mov    %edx,%esi
  800d21:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d23:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d26:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d29:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d2c:	89 ec                	mov    %ebp,%esp
  800d2e:	5d                   	pop    %ebp
  800d2f:	c3                   	ret    

00800d30 <sys_yield>:

void
sys_yield(void)
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	83 ec 0c             	sub    $0xc,%esp
  800d36:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d39:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d3c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d3f:	b8 01 00 00 00       	mov    $0x1,%eax
  800d44:	0f a2                	cpuid  
  800d46:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d48:	ba 00 00 00 00       	mov    $0x0,%edx
  800d4d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d52:	89 d1                	mov    %edx,%ecx
  800d54:	89 d3                	mov    %edx,%ebx
  800d56:	89 d7                	mov    %edx,%edi
  800d58:	89 d6                	mov    %edx,%esi
  800d5a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d5c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d5f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d62:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d65:	89 ec                	mov    %ebp,%esp
  800d67:	5d                   	pop    %ebp
  800d68:	c3                   	ret    

00800d69 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d69:	55                   	push   %ebp
  800d6a:	89 e5                	mov    %esp,%ebp
  800d6c:	83 ec 38             	sub    $0x38,%esp
  800d6f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d72:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d75:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d78:	b8 01 00 00 00       	mov    $0x1,%eax
  800d7d:	0f a2                	cpuid  
  800d7f:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d81:	be 00 00 00 00       	mov    $0x0,%esi
  800d86:	b8 04 00 00 00       	mov    $0x4,%eax
  800d8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d91:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d94:	89 f7                	mov    %esi,%edi
  800d96:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d98:	85 c0                	test   %eax,%eax
  800d9a:	7e 28                	jle    800dc4 <sys_page_alloc+0x5b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d9c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800da0:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800da7:	00 
  800da8:	c7 44 24 08 7f 20 80 	movl   $0x80207f,0x8(%esp)
  800daf:	00 
  800db0:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800db7:	00 
  800db8:	c7 04 24 9c 20 80 00 	movl   $0x80209c,(%esp)
  800dbf:	e8 4c 0b 00 00       	call   801910 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800dc4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dc7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dca:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dcd:	89 ec                	mov    %ebp,%esp
  800dcf:	5d                   	pop    %ebp
  800dd0:	c3                   	ret    

00800dd1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800dd1:	55                   	push   %ebp
  800dd2:	89 e5                	mov    %esp,%ebp
  800dd4:	83 ec 38             	sub    $0x38,%esp
  800dd7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dda:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ddd:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800de0:	b8 01 00 00 00       	mov    $0x1,%eax
  800de5:	0f a2                	cpuid  
  800de7:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de9:	b8 05 00 00 00       	mov    $0x5,%eax
  800dee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df1:	8b 55 08             	mov    0x8(%ebp),%edx
  800df4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800df7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dfa:	8b 75 18             	mov    0x18(%ebp),%esi
  800dfd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dff:	85 c0                	test   %eax,%eax
  800e01:	7e 28                	jle    800e2b <sys_page_map+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e03:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e07:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e0e:	00 
  800e0f:	c7 44 24 08 7f 20 80 	movl   $0x80207f,0x8(%esp)
  800e16:	00 
  800e17:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800e1e:	00 
  800e1f:	c7 04 24 9c 20 80 00 	movl   $0x80209c,(%esp)
  800e26:	e8 e5 0a 00 00       	call   801910 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e2b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e2e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e31:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e34:	89 ec                	mov    %ebp,%esp
  800e36:	5d                   	pop    %ebp
  800e37:	c3                   	ret    

00800e38 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e38:	55                   	push   %ebp
  800e39:	89 e5                	mov    %esp,%ebp
  800e3b:	83 ec 38             	sub    $0x38,%esp
  800e3e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e41:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e44:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e47:	b8 01 00 00 00       	mov    $0x1,%eax
  800e4c:	0f a2                	cpuid  
  800e4e:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e50:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e55:	b8 06 00 00 00       	mov    $0x6,%eax
  800e5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e60:	89 df                	mov    %ebx,%edi
  800e62:	89 de                	mov    %ebx,%esi
  800e64:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e66:	85 c0                	test   %eax,%eax
  800e68:	7e 28                	jle    800e92 <sys_page_unmap+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e6e:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e75:	00 
  800e76:	c7 44 24 08 7f 20 80 	movl   $0x80207f,0x8(%esp)
  800e7d:	00 
  800e7e:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800e85:	00 
  800e86:	c7 04 24 9c 20 80 00 	movl   $0x80209c,(%esp)
  800e8d:	e8 7e 0a 00 00       	call   801910 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e92:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e95:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e98:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e9b:	89 ec                	mov    %ebp,%esp
  800e9d:	5d                   	pop    %ebp
  800e9e:	c3                   	ret    

00800e9f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e9f:	55                   	push   %ebp
  800ea0:	89 e5                	mov    %esp,%ebp
  800ea2:	83 ec 38             	sub    $0x38,%esp
  800ea5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ea8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800eab:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800eae:	b8 01 00 00 00       	mov    $0x1,%eax
  800eb3:	0f a2                	cpuid  
  800eb5:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ebc:	b8 08 00 00 00       	mov    $0x8,%eax
  800ec1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec7:	89 df                	mov    %ebx,%edi
  800ec9:	89 de                	mov    %ebx,%esi
  800ecb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ecd:	85 c0                	test   %eax,%eax
  800ecf:	7e 28                	jle    800ef9 <sys_env_set_status+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ed5:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800edc:	00 
  800edd:	c7 44 24 08 7f 20 80 	movl   $0x80207f,0x8(%esp)
  800ee4:	00 
  800ee5:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800eec:	00 
  800eed:	c7 04 24 9c 20 80 00 	movl   $0x80209c,(%esp)
  800ef4:	e8 17 0a 00 00       	call   801910 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ef9:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800efc:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800eff:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f02:	89 ec                	mov    %ebp,%esp
  800f04:	5d                   	pop    %ebp
  800f05:	c3                   	ret    

00800f06 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f06:	55                   	push   %ebp
  800f07:	89 e5                	mov    %esp,%ebp
  800f09:	83 ec 38             	sub    $0x38,%esp
  800f0c:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f0f:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f12:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800f15:	b8 01 00 00 00       	mov    $0x1,%eax
  800f1a:	0f a2                	cpuid  
  800f1c:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f1e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f23:	b8 09 00 00 00       	mov    $0x9,%eax
  800f28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f2e:	89 df                	mov    %ebx,%edi
  800f30:	89 de                	mov    %ebx,%esi
  800f32:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f34:	85 c0                	test   %eax,%eax
  800f36:	7e 28                	jle    800f60 <sys_env_set_trapframe+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f38:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f3c:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f43:	00 
  800f44:	c7 44 24 08 7f 20 80 	movl   $0x80207f,0x8(%esp)
  800f4b:	00 
  800f4c:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800f53:	00 
  800f54:	c7 04 24 9c 20 80 00 	movl   $0x80209c,(%esp)
  800f5b:	e8 b0 09 00 00       	call   801910 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f60:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f63:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f66:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f69:	89 ec                	mov    %ebp,%esp
  800f6b:	5d                   	pop    %ebp
  800f6c:	c3                   	ret    

00800f6d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f6d:	55                   	push   %ebp
  800f6e:	89 e5                	mov    %esp,%ebp
  800f70:	83 ec 38             	sub    $0x38,%esp
  800f73:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f76:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f79:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800f7c:	b8 01 00 00 00       	mov    $0x1,%eax
  800f81:	0f a2                	cpuid  
  800f83:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f85:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f8a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f92:	8b 55 08             	mov    0x8(%ebp),%edx
  800f95:	89 df                	mov    %ebx,%edi
  800f97:	89 de                	mov    %ebx,%esi
  800f99:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f9b:	85 c0                	test   %eax,%eax
  800f9d:	7e 28                	jle    800fc7 <sys_env_set_pgfault_upcall+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f9f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fa3:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800faa:	00 
  800fab:	c7 44 24 08 7f 20 80 	movl   $0x80207f,0x8(%esp)
  800fb2:	00 
  800fb3:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800fba:	00 
  800fbb:	c7 04 24 9c 20 80 00 	movl   $0x80209c,(%esp)
  800fc2:	e8 49 09 00 00       	call   801910 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800fc7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fca:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fcd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fd0:	89 ec                	mov    %ebp,%esp
  800fd2:	5d                   	pop    %ebp
  800fd3:	c3                   	ret    

00800fd4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fd4:	55                   	push   %ebp
  800fd5:	89 e5                	mov    %esp,%ebp
  800fd7:	83 ec 0c             	sub    $0xc,%esp
  800fda:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fdd:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fe0:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800fe3:	b8 01 00 00 00       	mov    $0x1,%eax
  800fe8:	0f a2                	cpuid  
  800fea:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fec:	be 00 00 00 00       	mov    $0x0,%esi
  800ff1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ff6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ff9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ffc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fff:	8b 7d 14             	mov    0x14(%ebp),%edi
  801002:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801004:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801007:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80100a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80100d:	89 ec                	mov    %ebp,%esp
  80100f:	5d                   	pop    %ebp
  801010:	c3                   	ret    

00801011 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801011:	55                   	push   %ebp
  801012:	89 e5                	mov    %esp,%ebp
  801014:	83 ec 38             	sub    $0x38,%esp
  801017:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80101a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80101d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801020:	b8 01 00 00 00       	mov    $0x1,%eax
  801025:	0f a2                	cpuid  
  801027:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801029:	b9 00 00 00 00       	mov    $0x0,%ecx
  80102e:	b8 0d 00 00 00       	mov    $0xd,%eax
  801033:	8b 55 08             	mov    0x8(%ebp),%edx
  801036:	89 cb                	mov    %ecx,%ebx
  801038:	89 cf                	mov    %ecx,%edi
  80103a:	89 ce                	mov    %ecx,%esi
  80103c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80103e:	85 c0                	test   %eax,%eax
  801040:	7e 28                	jle    80106a <sys_ipc_recv+0x59>
		panic("syscall %d returned %d (> 0)", num, ret);
  801042:	89 44 24 10          	mov    %eax,0x10(%esp)
  801046:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  80104d:	00 
  80104e:	c7 44 24 08 7f 20 80 	movl   $0x80207f,0x8(%esp)
  801055:	00 
  801056:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  80105d:	00 
  80105e:	c7 04 24 9c 20 80 00 	movl   $0x80209c,(%esp)
  801065:	e8 a6 08 00 00       	call   801910 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80106a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80106d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801070:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801073:	89 ec                	mov    %ebp,%esp
  801075:	5d                   	pop    %ebp
  801076:	c3                   	ret    
  801077:	90                   	nop

00801078 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801078:	55                   	push   %ebp
  801079:	89 e5                	mov    %esp,%ebp
  80107b:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80107e:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  801085:	75 54                	jne    8010db <set_pgfault_handler+0x63>
		// First time through!
		// LAB 4: Your code here.
		if((r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U|PTE_P|PTE_W)))
  801087:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80108e:	00 
  80108f:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801096:	ee 
  801097:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80109e:	e8 c6 fc ff ff       	call   800d69 <sys_page_alloc>
  8010a3:	85 c0                	test   %eax,%eax
  8010a5:	74 20                	je     8010c7 <set_pgfault_handler+0x4f>
			panic("sys_page_alloc() failed in set_pgfault_handler()[%e]\n", r);
  8010a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010ab:	c7 44 24 08 ac 20 80 	movl   $0x8020ac,0x8(%esp)
  8010b2:	00 
  8010b3:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8010ba:	00 
  8010bb:	c7 04 24 e2 20 80 00 	movl   $0x8020e2,(%esp)
  8010c2:	e8 49 08 00 00       	call   801910 <_panic>
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  8010c7:	c7 44 24 04 e8 10 80 	movl   $0x8010e8,0x4(%esp)
  8010ce:	00 
  8010cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010d6:	e8 92 fe ff ff       	call   800f6d <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8010db:	8b 45 08             	mov    0x8(%ebp),%eax
  8010de:	a3 08 40 80 00       	mov    %eax,0x804008
}
  8010e3:	c9                   	leave  
  8010e4:	c3                   	ret    
  8010e5:	66 90                	xchg   %ax,%ax
  8010e7:	90                   	nop

008010e8 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8010e8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8010e9:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  8010ee:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8010f0:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	// @yuhangj: get reserved place under old esp
	addl $0x08, %esp;
  8010f3:	83 c4 08             	add    $0x8,%esp

	movl 0x28(%esp), %eax;
  8010f6:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x04, %eax;
  8010fa:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x28(%esp);
  8010fd:	89 44 24 28          	mov    %eax,0x28(%esp)

    // @yuhangj: store old eip into the reserved place under old esp
	movl 0x20(%esp), %ebx;
  801101:	8b 5c 24 20          	mov    0x20(%esp),%ebx
	movl %ebx, (%eax);
  801105:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  801107:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp;
  801108:	83 c4 04             	add    $0x4,%esp
	popfl
  80110b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  80110c:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  80110d:	c3                   	ret    
  80110e:	66 90                	xchg   %ax,%ax

00801110 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801110:	55                   	push   %ebp
  801111:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801113:	8b 45 08             	mov    0x8(%ebp),%eax
  801116:	05 00 00 00 30       	add    $0x30000000,%eax
  80111b:	c1 e8 0c             	shr    $0xc,%eax
}
  80111e:	5d                   	pop    %ebp
  80111f:	c3                   	ret    

00801120 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801120:	55                   	push   %ebp
  801121:	89 e5                	mov    %esp,%ebp
  801123:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801126:	8b 45 08             	mov    0x8(%ebp),%eax
  801129:	89 04 24             	mov    %eax,(%esp)
  80112c:	e8 df ff ff ff       	call   801110 <fd2num>
  801131:	c1 e0 0c             	shl    $0xc,%eax
  801134:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801139:	c9                   	leave  
  80113a:	c3                   	ret    

0080113b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80113b:	55                   	push   %ebp
  80113c:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  80113e:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801143:	a8 01                	test   $0x1,%al
  801145:	74 34                	je     80117b <fd_alloc+0x40>
  801147:	a1 00 00 74 ef       	mov    0xef740000,%eax
  80114c:	a8 01                	test   $0x1,%al
  80114e:	74 32                	je     801182 <fd_alloc+0x47>
  801150:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801155:	89 c1                	mov    %eax,%ecx
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801157:	89 c2                	mov    %eax,%edx
  801159:	c1 ea 16             	shr    $0x16,%edx
  80115c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801163:	f6 c2 01             	test   $0x1,%dl
  801166:	74 1f                	je     801187 <fd_alloc+0x4c>
  801168:	89 c2                	mov    %eax,%edx
  80116a:	c1 ea 0c             	shr    $0xc,%edx
  80116d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801174:	f6 c2 01             	test   $0x1,%dl
  801177:	75 1a                	jne    801193 <fd_alloc+0x58>
  801179:	eb 0c                	jmp    801187 <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80117b:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801180:	eb 05                	jmp    801187 <fd_alloc+0x4c>
  801182:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  801187:	8b 45 08             	mov    0x8(%ebp),%eax
  80118a:	89 08                	mov    %ecx,(%eax)
			return 0;
  80118c:	b8 00 00 00 00       	mov    $0x0,%eax
  801191:	eb 1a                	jmp    8011ad <fd_alloc+0x72>
  801193:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801198:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80119d:	75 b6                	jne    801155 <fd_alloc+0x1a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80119f:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  8011a8:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011ad:	5d                   	pop    %ebp
  8011ae:	c3                   	ret    

008011af <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011af:	55                   	push   %ebp
  8011b0:	89 e5                	mov    %esp,%ebp
  8011b2:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011b5:	83 f8 1f             	cmp    $0x1f,%eax
  8011b8:	77 36                	ja     8011f0 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011ba:	c1 e0 0c             	shl    $0xc,%eax
  8011bd:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  8011c2:	89 c2                	mov    %eax,%edx
  8011c4:	c1 ea 16             	shr    $0x16,%edx
  8011c7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011ce:	f6 c2 01             	test   $0x1,%dl
  8011d1:	74 24                	je     8011f7 <fd_lookup+0x48>
  8011d3:	89 c2                	mov    %eax,%edx
  8011d5:	c1 ea 0c             	shr    $0xc,%edx
  8011d8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011df:	f6 c2 01             	test   $0x1,%dl
  8011e2:	74 1a                	je     8011fe <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011e7:	89 02                	mov    %eax,(%edx)
	return 0;
  8011e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ee:	eb 13                	jmp    801203 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  8011f0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011f5:	eb 0c                	jmp    801203 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  8011f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011fc:	eb 05                	jmp    801203 <fd_lookup+0x54>
  8011fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801203:	5d                   	pop    %ebp
  801204:	c3                   	ret    

00801205 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801205:	55                   	push   %ebp
  801206:	89 e5                	mov    %esp,%ebp
  801208:	83 ec 18             	sub    $0x18,%esp
  80120b:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80120e:	39 05 04 30 80 00    	cmp    %eax,0x803004
  801214:	75 10                	jne    801226 <dev_lookup+0x21>
			*dev = devtab[i];
  801216:	8b 45 0c             	mov    0xc(%ebp),%eax
  801219:	c7 00 04 30 80 00    	movl   $0x803004,(%eax)
			return 0;
  80121f:	b8 00 00 00 00       	mov    $0x0,%eax
  801224:	eb 2b                	jmp    801251 <dev_lookup+0x4c>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801226:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80122c:	8b 52 48             	mov    0x48(%edx),%edx
  80122f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801233:	89 54 24 04          	mov    %edx,0x4(%esp)
  801237:	c7 04 24 f0 20 80 00 	movl   $0x8020f0,(%esp)
  80123e:	e8 60 ef ff ff       	call   8001a3 <cprintf>
	*dev = 0;
  801243:	8b 55 0c             	mov    0xc(%ebp),%edx
  801246:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	return -E_INVAL;
  80124c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801251:	c9                   	leave  
  801252:	c3                   	ret    

00801253 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801253:	55                   	push   %ebp
  801254:	89 e5                	mov    %esp,%ebp
  801256:	83 ec 38             	sub    $0x38,%esp
  801259:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80125c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80125f:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801262:	8b 7d 08             	mov    0x8(%ebp),%edi
  801265:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801268:	89 3c 24             	mov    %edi,(%esp)
  80126b:	e8 a0 fe ff ff       	call   801110 <fd2num>
  801270:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  801273:	89 54 24 04          	mov    %edx,0x4(%esp)
  801277:	89 04 24             	mov    %eax,(%esp)
  80127a:	e8 30 ff ff ff       	call   8011af <fd_lookup>
  80127f:	89 c3                	mov    %eax,%ebx
  801281:	85 c0                	test   %eax,%eax
  801283:	78 05                	js     80128a <fd_close+0x37>
	    || fd != fd2)
  801285:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  801288:	74 0c                	je     801296 <fd_close+0x43>
		return (must_exist ? r : 0);
  80128a:	85 f6                	test   %esi,%esi
  80128c:	b8 00 00 00 00       	mov    $0x0,%eax
  801291:	0f 44 d8             	cmove  %eax,%ebx
  801294:	eb 3d                	jmp    8012d3 <fd_close+0x80>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801296:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801299:	89 44 24 04          	mov    %eax,0x4(%esp)
  80129d:	8b 07                	mov    (%edi),%eax
  80129f:	89 04 24             	mov    %eax,(%esp)
  8012a2:	e8 5e ff ff ff       	call   801205 <dev_lookup>
  8012a7:	89 c3                	mov    %eax,%ebx
  8012a9:	85 c0                	test   %eax,%eax
  8012ab:	78 16                	js     8012c3 <fd_close+0x70>
		if (dev->dev_close)
  8012ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012b0:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012b3:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012b8:	85 c0                	test   %eax,%eax
  8012ba:	74 07                	je     8012c3 <fd_close+0x70>
			r = (*dev->dev_close)(fd);
  8012bc:	89 3c 24             	mov    %edi,(%esp)
  8012bf:	ff d0                	call   *%eax
  8012c1:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012c3:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012ce:	e8 65 fb ff ff       	call   800e38 <sys_page_unmap>
	return r;
}
  8012d3:	89 d8                	mov    %ebx,%eax
  8012d5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8012d8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8012db:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012de:	89 ec                	mov    %ebp,%esp
  8012e0:	5d                   	pop    %ebp
  8012e1:	c3                   	ret    

008012e2 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012e2:	55                   	push   %ebp
  8012e3:	89 e5                	mov    %esp,%ebp
  8012e5:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8012f2:	89 04 24             	mov    %eax,(%esp)
  8012f5:	e8 b5 fe ff ff       	call   8011af <fd_lookup>
  8012fa:	85 c0                	test   %eax,%eax
  8012fc:	78 13                	js     801311 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8012fe:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801305:	00 
  801306:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801309:	89 04 24             	mov    %eax,(%esp)
  80130c:	e8 42 ff ff ff       	call   801253 <fd_close>
}
  801311:	c9                   	leave  
  801312:	c3                   	ret    

00801313 <close_all>:

void
close_all(void)
{
  801313:	55                   	push   %ebp
  801314:	89 e5                	mov    %esp,%ebp
  801316:	53                   	push   %ebx
  801317:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80131a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80131f:	89 1c 24             	mov    %ebx,(%esp)
  801322:	e8 bb ff ff ff       	call   8012e2 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801327:	83 c3 01             	add    $0x1,%ebx
  80132a:	83 fb 20             	cmp    $0x20,%ebx
  80132d:	75 f0                	jne    80131f <close_all+0xc>
		close(i);
}
  80132f:	83 c4 14             	add    $0x14,%esp
  801332:	5b                   	pop    %ebx
  801333:	5d                   	pop    %ebp
  801334:	c3                   	ret    

00801335 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801335:	55                   	push   %ebp
  801336:	89 e5                	mov    %esp,%ebp
  801338:	83 ec 58             	sub    $0x58,%esp
  80133b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80133e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801341:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801344:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801347:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80134a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80134e:	8b 45 08             	mov    0x8(%ebp),%eax
  801351:	89 04 24             	mov    %eax,(%esp)
  801354:	e8 56 fe ff ff       	call   8011af <fd_lookup>
  801359:	85 c0                	test   %eax,%eax
  80135b:	0f 88 e3 00 00 00    	js     801444 <dup+0x10f>
		return r;
	close(newfdnum);
  801361:	89 1c 24             	mov    %ebx,(%esp)
  801364:	e8 79 ff ff ff       	call   8012e2 <close>

	newfd = INDEX2FD(newfdnum);
  801369:	89 de                	mov    %ebx,%esi
  80136b:	c1 e6 0c             	shl    $0xc,%esi
  80136e:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801374:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801377:	89 04 24             	mov    %eax,(%esp)
  80137a:	e8 a1 fd ff ff       	call   801120 <fd2data>
  80137f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801381:	89 34 24             	mov    %esi,(%esp)
  801384:	e8 97 fd ff ff       	call   801120 <fd2data>
  801389:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  80138c:	89 f8                	mov    %edi,%eax
  80138e:	c1 e8 16             	shr    $0x16,%eax
  801391:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801398:	a8 01                	test   $0x1,%al
  80139a:	74 46                	je     8013e2 <dup+0xad>
  80139c:	89 f8                	mov    %edi,%eax
  80139e:	c1 e8 0c             	shr    $0xc,%eax
  8013a1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013a8:	f6 c2 01             	test   $0x1,%dl
  8013ab:	74 35                	je     8013e2 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013ad:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013b4:	25 07 0e 00 00       	and    $0xe07,%eax
  8013b9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013bd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8013c0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013c4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8013cb:	00 
  8013cc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013d0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013d7:	e8 f5 f9 ff ff       	call   800dd1 <sys_page_map>
  8013dc:	89 c7                	mov    %eax,%edi
  8013de:	85 c0                	test   %eax,%eax
  8013e0:	78 3b                	js     80141d <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013e5:	89 c2                	mov    %eax,%edx
  8013e7:	c1 ea 0c             	shr    $0xc,%edx
  8013ea:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013f1:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8013f7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8013fb:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8013ff:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801406:	00 
  801407:	89 44 24 04          	mov    %eax,0x4(%esp)
  80140b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801412:	e8 ba f9 ff ff       	call   800dd1 <sys_page_map>
  801417:	89 c7                	mov    %eax,%edi
  801419:	85 c0                	test   %eax,%eax
  80141b:	79 29                	jns    801446 <dup+0x111>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80141d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801421:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801428:	e8 0b fa ff ff       	call   800e38 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80142d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801430:	89 44 24 04          	mov    %eax,0x4(%esp)
  801434:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80143b:	e8 f8 f9 ff ff       	call   800e38 <sys_page_unmap>
	return r;
  801440:	89 fb                	mov    %edi,%ebx
  801442:	eb 02                	jmp    801446 <dup+0x111>
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
		return r;
  801444:	89 c3                	mov    %eax,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801446:	89 d8                	mov    %ebx,%eax
  801448:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80144b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80144e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801451:	89 ec                	mov    %ebp,%esp
  801453:	5d                   	pop    %ebp
  801454:	c3                   	ret    

00801455 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801455:	55                   	push   %ebp
  801456:	89 e5                	mov    %esp,%ebp
  801458:	53                   	push   %ebx
  801459:	83 ec 24             	sub    $0x24,%esp
  80145c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80145f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801462:	89 44 24 04          	mov    %eax,0x4(%esp)
  801466:	89 1c 24             	mov    %ebx,(%esp)
  801469:	e8 41 fd ff ff       	call   8011af <fd_lookup>
  80146e:	85 c0                	test   %eax,%eax
  801470:	78 6d                	js     8014df <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801472:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801475:	89 44 24 04          	mov    %eax,0x4(%esp)
  801479:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80147c:	8b 00                	mov    (%eax),%eax
  80147e:	89 04 24             	mov    %eax,(%esp)
  801481:	e8 7f fd ff ff       	call   801205 <dev_lookup>
  801486:	85 c0                	test   %eax,%eax
  801488:	78 55                	js     8014df <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80148a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80148d:	8b 50 08             	mov    0x8(%eax),%edx
  801490:	83 e2 03             	and    $0x3,%edx
  801493:	83 fa 01             	cmp    $0x1,%edx
  801496:	75 23                	jne    8014bb <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801498:	a1 04 40 80 00       	mov    0x804004,%eax
  80149d:	8b 40 48             	mov    0x48(%eax),%eax
  8014a0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014a8:	c7 04 24 31 21 80 00 	movl   $0x802131,(%esp)
  8014af:	e8 ef ec ff ff       	call   8001a3 <cprintf>
		return -E_INVAL;
  8014b4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014b9:	eb 24                	jmp    8014df <read+0x8a>
	}
	if (!dev->dev_read)
  8014bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014be:	8b 52 08             	mov    0x8(%edx),%edx
  8014c1:	85 d2                	test   %edx,%edx
  8014c3:	74 15                	je     8014da <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014c5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8014c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014cf:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8014d3:	89 04 24             	mov    %eax,(%esp)
  8014d6:	ff d2                	call   *%edx
  8014d8:	eb 05                	jmp    8014df <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014da:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8014df:	83 c4 24             	add    $0x24,%esp
  8014e2:	5b                   	pop    %ebx
  8014e3:	5d                   	pop    %ebp
  8014e4:	c3                   	ret    

008014e5 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014e5:	55                   	push   %ebp
  8014e6:	89 e5                	mov    %esp,%ebp
  8014e8:	57                   	push   %edi
  8014e9:	56                   	push   %esi
  8014ea:	53                   	push   %ebx
  8014eb:	83 ec 1c             	sub    $0x1c,%esp
  8014ee:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014f1:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014f4:	85 f6                	test   %esi,%esi
  8014f6:	74 33                	je     80152b <readn+0x46>
  8014f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8014fd:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801502:	89 f2                	mov    %esi,%edx
  801504:	29 c2                	sub    %eax,%edx
  801506:	89 54 24 08          	mov    %edx,0x8(%esp)
  80150a:	03 45 0c             	add    0xc(%ebp),%eax
  80150d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801511:	89 3c 24             	mov    %edi,(%esp)
  801514:	e8 3c ff ff ff       	call   801455 <read>
		if (m < 0)
  801519:	85 c0                	test   %eax,%eax
  80151b:	78 17                	js     801534 <readn+0x4f>
			return m;
		if (m == 0)
  80151d:	85 c0                	test   %eax,%eax
  80151f:	74 11                	je     801532 <readn+0x4d>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801521:	01 c3                	add    %eax,%ebx
  801523:	89 d8                	mov    %ebx,%eax
  801525:	39 f3                	cmp    %esi,%ebx
  801527:	72 d9                	jb     801502 <readn+0x1d>
  801529:	eb 09                	jmp    801534 <readn+0x4f>
  80152b:	b8 00 00 00 00       	mov    $0x0,%eax
  801530:	eb 02                	jmp    801534 <readn+0x4f>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801532:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801534:	83 c4 1c             	add    $0x1c,%esp
  801537:	5b                   	pop    %ebx
  801538:	5e                   	pop    %esi
  801539:	5f                   	pop    %edi
  80153a:	5d                   	pop    %ebp
  80153b:	c3                   	ret    

0080153c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80153c:	55                   	push   %ebp
  80153d:	89 e5                	mov    %esp,%ebp
  80153f:	53                   	push   %ebx
  801540:	83 ec 24             	sub    $0x24,%esp
  801543:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801546:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801549:	89 44 24 04          	mov    %eax,0x4(%esp)
  80154d:	89 1c 24             	mov    %ebx,(%esp)
  801550:	e8 5a fc ff ff       	call   8011af <fd_lookup>
  801555:	85 c0                	test   %eax,%eax
  801557:	78 68                	js     8015c1 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801559:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80155c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801560:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801563:	8b 00                	mov    (%eax),%eax
  801565:	89 04 24             	mov    %eax,(%esp)
  801568:	e8 98 fc ff ff       	call   801205 <dev_lookup>
  80156d:	85 c0                	test   %eax,%eax
  80156f:	78 50                	js     8015c1 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801571:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801574:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801578:	75 23                	jne    80159d <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80157a:	a1 04 40 80 00       	mov    0x804004,%eax
  80157f:	8b 40 48             	mov    0x48(%eax),%eax
  801582:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801586:	89 44 24 04          	mov    %eax,0x4(%esp)
  80158a:	c7 04 24 4d 21 80 00 	movl   $0x80214d,(%esp)
  801591:	e8 0d ec ff ff       	call   8001a3 <cprintf>
		return -E_INVAL;
  801596:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80159b:	eb 24                	jmp    8015c1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80159d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015a0:	8b 52 0c             	mov    0xc(%edx),%edx
  8015a3:	85 d2                	test   %edx,%edx
  8015a5:	74 15                	je     8015bc <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015a7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015aa:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015b1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8015b5:	89 04 24             	mov    %eax,(%esp)
  8015b8:	ff d2                	call   *%edx
  8015ba:	eb 05                	jmp    8015c1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015bc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8015c1:	83 c4 24             	add    $0x24,%esp
  8015c4:	5b                   	pop    %ebx
  8015c5:	5d                   	pop    %ebp
  8015c6:	c3                   	ret    

008015c7 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015c7:	55                   	push   %ebp
  8015c8:	89 e5                	mov    %esp,%ebp
  8015ca:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015cd:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8015d7:	89 04 24             	mov    %eax,(%esp)
  8015da:	e8 d0 fb ff ff       	call   8011af <fd_lookup>
  8015df:	85 c0                	test   %eax,%eax
  8015e1:	78 0e                	js     8015f1 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8015e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015e9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015f1:	c9                   	leave  
  8015f2:	c3                   	ret    

008015f3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015f3:	55                   	push   %ebp
  8015f4:	89 e5                	mov    %esp,%ebp
  8015f6:	53                   	push   %ebx
  8015f7:	83 ec 24             	sub    $0x24,%esp
  8015fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015fd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801600:	89 44 24 04          	mov    %eax,0x4(%esp)
  801604:	89 1c 24             	mov    %ebx,(%esp)
  801607:	e8 a3 fb ff ff       	call   8011af <fd_lookup>
  80160c:	85 c0                	test   %eax,%eax
  80160e:	78 61                	js     801671 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801610:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801613:	89 44 24 04          	mov    %eax,0x4(%esp)
  801617:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80161a:	8b 00                	mov    (%eax),%eax
  80161c:	89 04 24             	mov    %eax,(%esp)
  80161f:	e8 e1 fb ff ff       	call   801205 <dev_lookup>
  801624:	85 c0                	test   %eax,%eax
  801626:	78 49                	js     801671 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801628:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80162b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80162f:	75 23                	jne    801654 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801631:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801636:	8b 40 48             	mov    0x48(%eax),%eax
  801639:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80163d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801641:	c7 04 24 10 21 80 00 	movl   $0x802110,(%esp)
  801648:	e8 56 eb ff ff       	call   8001a3 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80164d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801652:	eb 1d                	jmp    801671 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801654:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801657:	8b 52 18             	mov    0x18(%edx),%edx
  80165a:	85 d2                	test   %edx,%edx
  80165c:	74 0e                	je     80166c <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80165e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801661:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801665:	89 04 24             	mov    %eax,(%esp)
  801668:	ff d2                	call   *%edx
  80166a:	eb 05                	jmp    801671 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80166c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801671:	83 c4 24             	add    $0x24,%esp
  801674:	5b                   	pop    %ebx
  801675:	5d                   	pop    %ebp
  801676:	c3                   	ret    

00801677 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801677:	55                   	push   %ebp
  801678:	89 e5                	mov    %esp,%ebp
  80167a:	53                   	push   %ebx
  80167b:	83 ec 24             	sub    $0x24,%esp
  80167e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801681:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801684:	89 44 24 04          	mov    %eax,0x4(%esp)
  801688:	8b 45 08             	mov    0x8(%ebp),%eax
  80168b:	89 04 24             	mov    %eax,(%esp)
  80168e:	e8 1c fb ff ff       	call   8011af <fd_lookup>
  801693:	85 c0                	test   %eax,%eax
  801695:	78 52                	js     8016e9 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801697:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80169a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80169e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016a1:	8b 00                	mov    (%eax),%eax
  8016a3:	89 04 24             	mov    %eax,(%esp)
  8016a6:	e8 5a fb ff ff       	call   801205 <dev_lookup>
  8016ab:	85 c0                	test   %eax,%eax
  8016ad:	78 3a                	js     8016e9 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8016af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016b2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016b6:	74 2c                	je     8016e4 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016b8:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016bb:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016c2:	00 00 00 
	stat->st_isdir = 0;
  8016c5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016cc:	00 00 00 
	stat->st_dev = dev;
  8016cf:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016d5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016d9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016dc:	89 14 24             	mov    %edx,(%esp)
  8016df:	ff 50 14             	call   *0x14(%eax)
  8016e2:	eb 05                	jmp    8016e9 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016e4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016e9:	83 c4 24             	add    $0x24,%esp
  8016ec:	5b                   	pop    %ebx
  8016ed:	5d                   	pop    %ebp
  8016ee:	c3                   	ret    

008016ef <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016ef:	55                   	push   %ebp
  8016f0:	89 e5                	mov    %esp,%ebp
  8016f2:	83 ec 18             	sub    $0x18,%esp
  8016f5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8016f8:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016fb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801702:	00 
  801703:	8b 45 08             	mov    0x8(%ebp),%eax
  801706:	89 04 24             	mov    %eax,(%esp)
  801709:	e8 84 01 00 00       	call   801892 <open>
  80170e:	89 c3                	mov    %eax,%ebx
  801710:	85 c0                	test   %eax,%eax
  801712:	78 1b                	js     80172f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801714:	8b 45 0c             	mov    0xc(%ebp),%eax
  801717:	89 44 24 04          	mov    %eax,0x4(%esp)
  80171b:	89 1c 24             	mov    %ebx,(%esp)
  80171e:	e8 54 ff ff ff       	call   801677 <fstat>
  801723:	89 c6                	mov    %eax,%esi
	close(fd);
  801725:	89 1c 24             	mov    %ebx,(%esp)
  801728:	e8 b5 fb ff ff       	call   8012e2 <close>
	return r;
  80172d:	89 f3                	mov    %esi,%ebx
}
  80172f:	89 d8                	mov    %ebx,%eax
  801731:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801734:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801737:	89 ec                	mov    %ebp,%esp
  801739:	5d                   	pop    %ebp
  80173a:	c3                   	ret    
  80173b:	90                   	nop

0080173c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80173c:	55                   	push   %ebp
  80173d:	89 e5                	mov    %esp,%ebp
  80173f:	83 ec 18             	sub    $0x18,%esp
  801742:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801745:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801748:	89 c6                	mov    %eax,%esi
  80174a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80174c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801753:	75 11                	jne    801766 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801755:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  80175c:	e8 ca 02 00 00       	call   801a2b <ipc_find_env>
  801761:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801766:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80176d:	00 
  80176e:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801775:	00 
  801776:	89 74 24 04          	mov    %esi,0x4(%esp)
  80177a:	a1 00 40 80 00       	mov    0x804000,%eax
  80177f:	89 04 24             	mov    %eax,(%esp)
  801782:	e8 39 02 00 00       	call   8019c0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801787:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80178e:	00 
  80178f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801793:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80179a:	e8 c9 01 00 00       	call   801968 <ipc_recv>
}
  80179f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8017a2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8017a5:	89 ec                	mov    %ebp,%esp
  8017a7:	5d                   	pop    %ebp
  8017a8:	c3                   	ret    

008017a9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017a9:	55                   	push   %ebp
  8017aa:	89 e5                	mov    %esp,%ebp
  8017ac:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017af:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b2:	8b 40 0c             	mov    0xc(%eax),%eax
  8017b5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017bd:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c7:	b8 02 00 00 00       	mov    $0x2,%eax
  8017cc:	e8 6b ff ff ff       	call   80173c <fsipc>
}
  8017d1:	c9                   	leave  
  8017d2:	c3                   	ret    

008017d3 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017d3:	55                   	push   %ebp
  8017d4:	89 e5                	mov    %esp,%ebp
  8017d6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8017dc:	8b 40 0c             	mov    0xc(%eax),%eax
  8017df:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e9:	b8 06 00 00 00       	mov    $0x6,%eax
  8017ee:	e8 49 ff ff ff       	call   80173c <fsipc>
}
  8017f3:	c9                   	leave  
  8017f4:	c3                   	ret    

008017f5 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017f5:	55                   	push   %ebp
  8017f6:	89 e5                	mov    %esp,%ebp
  8017f8:	53                   	push   %ebx
  8017f9:	83 ec 14             	sub    $0x14,%esp
  8017fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801802:	8b 40 0c             	mov    0xc(%eax),%eax
  801805:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80180a:	ba 00 00 00 00       	mov    $0x0,%edx
  80180f:	b8 05 00 00 00       	mov    $0x5,%eax
  801814:	e8 23 ff ff ff       	call   80173c <fsipc>
  801819:	85 c0                	test   %eax,%eax
  80181b:	78 2b                	js     801848 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80181d:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801824:	00 
  801825:	89 1c 24             	mov    %ebx,(%esp)
  801828:	e8 ee ef ff ff       	call   80081b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80182d:	a1 80 50 80 00       	mov    0x805080,%eax
  801832:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801838:	a1 84 50 80 00       	mov    0x805084,%eax
  80183d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801843:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801848:	83 c4 14             	add    $0x14,%esp
  80184b:	5b                   	pop    %ebx
  80184c:	5d                   	pop    %ebp
  80184d:	c3                   	ret    

0080184e <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80184e:	55                   	push   %ebp
  80184f:	89 e5                	mov    %esp,%ebp
  801851:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801854:	c7 44 24 08 6a 21 80 	movl   $0x80216a,0x8(%esp)
  80185b:	00 
  80185c:	c7 44 24 04 77 00 00 	movl   $0x77,0x4(%esp)
  801863:	00 
  801864:	c7 04 24 88 21 80 00 	movl   $0x802188,(%esp)
  80186b:	e8 a0 00 00 00       	call   801910 <_panic>

00801870 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801870:	55                   	push   %ebp
  801871:	89 e5                	mov    %esp,%ebp
  801873:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_READ request to the file system server after
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
	panic("devfile_read not implemented");
  801876:	c7 44 24 08 93 21 80 	movl   $0x802193,0x8(%esp)
  80187d:	00 
  80187e:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
  801885:	00 
  801886:	c7 04 24 88 21 80 00 	movl   $0x802188,(%esp)
  80188d:	e8 7e 00 00 00       	call   801910 <_panic>

00801892 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801892:	55                   	push   %ebp
  801893:	89 e5                	mov    %esp,%ebp
  801895:	83 ec 18             	sub    $0x18,%esp
	// Return the file descriptor index.
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
	panic("open not implemented");
  801898:	c7 44 24 08 b0 21 80 	movl   $0x8021b0,0x8(%esp)
  80189f:	00 
  8018a0:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  8018a7:	00 
  8018a8:	c7 04 24 88 21 80 00 	movl   $0x802188,(%esp)
  8018af:	e8 5c 00 00 00       	call   801910 <_panic>

008018b4 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  8018b4:	55                   	push   %ebp
  8018b5:	89 e5                	mov    %esp,%ebp
  8018b7:	53                   	push   %ebx
  8018b8:	83 ec 14             	sub    $0x14,%esp
  8018bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  8018be:	89 1c 24             	mov    %ebx,(%esp)
  8018c1:	e8 fa ee ff ff       	call   8007c0 <strlen>
  8018c6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018cb:	7f 21                	jg     8018ee <remove+0x3a>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  8018cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018d1:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8018d8:	e8 3e ef ff ff       	call   80081b <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  8018dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e2:	b8 07 00 00 00       	mov    $0x7,%eax
  8018e7:	e8 50 fe ff ff       	call   80173c <fsipc>
  8018ec:	eb 05                	jmp    8018f3 <remove+0x3f>
// Delete a file
int
remove(const char *path)
{
	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018ee:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
	strcpy(fsipcbuf.remove.req_path, path);
	return fsipc(FSREQ_REMOVE, NULL);
}
  8018f3:	83 c4 14             	add    $0x14,%esp
  8018f6:	5b                   	pop    %ebx
  8018f7:	5d                   	pop    %ebp
  8018f8:	c3                   	ret    

008018f9 <sync>:

// Synchronize disk with buffer cache
int
sync(void)
{
  8018f9:	55                   	push   %ebp
  8018fa:	89 e5                	mov    %esp,%ebp
  8018fc:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801904:	b8 08 00 00 00       	mov    $0x8,%eax
  801909:	e8 2e fe ff ff       	call   80173c <fsipc>
}
  80190e:	c9                   	leave  
  80190f:	c3                   	ret    

00801910 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801910:	55                   	push   %ebp
  801911:	89 e5                	mov    %esp,%ebp
  801913:	56                   	push   %esi
  801914:	53                   	push   %ebx
  801915:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801918:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80191b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801921:	e8 d1 f3 ff ff       	call   800cf7 <sys_getenvid>
  801926:	8b 55 0c             	mov    0xc(%ebp),%edx
  801929:	89 54 24 10          	mov    %edx,0x10(%esp)
  80192d:	8b 55 08             	mov    0x8(%ebp),%edx
  801930:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801934:	89 74 24 08          	mov    %esi,0x8(%esp)
  801938:	89 44 24 04          	mov    %eax,0x4(%esp)
  80193c:	c7 04 24 c8 21 80 00 	movl   $0x8021c8,(%esp)
  801943:	e8 5b e8 ff ff       	call   8001a3 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801948:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80194c:	8b 45 10             	mov    0x10(%ebp),%eax
  80194f:	89 04 24             	mov    %eax,(%esp)
  801952:	e8 eb e7 ff ff       	call   800142 <vcprintf>
	cprintf("\n");
  801957:	c7 04 24 01 22 80 00 	movl   $0x802201,(%esp)
  80195e:	e8 40 e8 ff ff       	call   8001a3 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801963:	cc                   	int3   
  801964:	eb fd                	jmp    801963 <_panic+0x53>
  801966:	66 90                	xchg   %ax,%ax

00801968 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801968:	55                   	push   %ebp
  801969:	89 e5                	mov    %esp,%ebp
  80196b:	56                   	push   %esi
  80196c:	53                   	push   %ebx
  80196d:	83 ec 10             	sub    $0x10,%esp
  801970:	8b 75 08             	mov    0x8(%ebp),%esi
  801973:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	// 	return thisenv->env_ipc_value;
	// }
	int r;
	if(pg == NULL)
		pg = (void *)~0x0;
  801976:	85 db                	test   %ebx,%ebx
  801978:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80197d:	0f 44 d8             	cmove  %eax,%ebx
	//else
	if((r = sys_ipc_recv(pg)) < 0)
  801980:	89 1c 24             	mov    %ebx,(%esp)
  801983:	e8 89 f6 ff ff       	call   801011 <sys_ipc_recv>
  801988:	85 c0                	test   %eax,%eax
  80198a:	78 2d                	js     8019b9 <ipc_recv+0x51>
		return r;
	//volatile struct Env *curenv = (struct Env*)envs+ENVX(sys_getenvid());

	if(from_env_store)
  80198c:	85 f6                	test   %esi,%esi
  80198e:	74 0a                	je     80199a <ipc_recv+0x32>
		*from_env_store = thisenv -> env_ipc_from;
  801990:	a1 04 40 80 00       	mov    0x804004,%eax
  801995:	8b 40 74             	mov    0x74(%eax),%eax
  801998:	89 06                	mov    %eax,(%esi)
	if(pg && perm_store)
  80199a:	85 db                	test   %ebx,%ebx
  80199c:	74 13                	je     8019b1 <ipc_recv+0x49>
  80199e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019a2:	74 0d                	je     8019b1 <ipc_recv+0x49>
		*perm_store = thisenv -> env_ipc_perm;
  8019a4:	a1 04 40 80 00       	mov    0x804004,%eax
  8019a9:	8b 40 78             	mov    0x78(%eax),%eax
  8019ac:	8b 55 10             	mov    0x10(%ebp),%edx
  8019af:	89 02                	mov    %eax,(%edx)
	else if(perm_store)
		perm_store = (int *)0;
	return thisenv->env_ipc_value;
  8019b1:	a1 04 40 80 00       	mov    0x804004,%eax
  8019b6:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  8019b9:	83 c4 10             	add    $0x10,%esp
  8019bc:	5b                   	pop    %ebx
  8019bd:	5e                   	pop    %esi
  8019be:	5d                   	pop    %ebp
  8019bf:	c3                   	ret    

008019c0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8019c0:	55                   	push   %ebp
  8019c1:	89 e5                	mov    %esp,%ebp
  8019c3:	57                   	push   %edi
  8019c4:	56                   	push   %esi
  8019c5:	53                   	push   %ebx
  8019c6:	83 ec 1c             	sub    $0x1c,%esp
  8019c9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8019cc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019cf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

	if(pg == NULL)
  8019d2:	85 db                	test   %ebx,%ebx
		pg = (void *)~0x0;
  8019d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8019d9:	0f 44 d8             	cmove  %eax,%ebx
  8019dc:	eb 2a                	jmp    801a08 <ipc_send+0x48>
	while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0){
		if(r != -E_IPC_NOT_RECV)
  8019de:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8019e1:	74 20                	je     801a03 <ipc_send+0x43>
            panic("Send message error %e\n",r);
  8019e3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019e7:	c7 44 24 08 ec 21 80 	movl   $0x8021ec,0x8(%esp)
  8019ee:	00 
  8019ef:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8019f6:	00 
  8019f7:	c7 04 24 03 22 80 00 	movl   $0x802203,(%esp)
  8019fe:	e8 0d ff ff ff       	call   801910 <_panic>
		sys_yield();
  801a03:	e8 28 f3 ff ff       	call   800d30 <sys_yield>
	// LAB 4: Your code here.
	int r;

	if(pg == NULL)
		pg = (void *)~0x0;
	while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0){
  801a08:	8b 45 14             	mov    0x14(%ebp),%eax
  801a0b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a0f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a13:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a17:	89 3c 24             	mov    %edi,(%esp)
  801a1a:	e8 b5 f5 ff ff       	call   800fd4 <sys_ipc_try_send>
  801a1f:	85 c0                	test   %eax,%eax
  801a21:	78 bb                	js     8019de <ipc_send+0x1e>
            panic("Send message error %e\n",r);
		sys_yield();
	}

	//panic("ipc_send not implemented");
}
  801a23:	83 c4 1c             	add    $0x1c,%esp
  801a26:	5b                   	pop    %ebx
  801a27:	5e                   	pop    %esi
  801a28:	5f                   	pop    %edi
  801a29:	5d                   	pop    %ebp
  801a2a:	c3                   	ret    

00801a2b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801a2b:	55                   	push   %ebp
  801a2c:	89 e5                	mov    %esp,%ebp
  801a2e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801a31:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801a36:	39 c8                	cmp    %ecx,%eax
  801a38:	74 17                	je     801a51 <ipc_find_env+0x26>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801a3a:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801a3f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801a42:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801a48:	8b 52 50             	mov    0x50(%edx),%edx
  801a4b:	39 ca                	cmp    %ecx,%edx
  801a4d:	75 14                	jne    801a63 <ipc_find_env+0x38>
  801a4f:	eb 05                	jmp    801a56 <ipc_find_env+0x2b>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801a51:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801a56:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801a59:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801a5e:	8b 40 40             	mov    0x40(%eax),%eax
  801a61:	eb 0e                	jmp    801a71 <ipc_find_env+0x46>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801a63:	83 c0 01             	add    $0x1,%eax
  801a66:	3d 00 04 00 00       	cmp    $0x400,%eax
  801a6b:	75 d2                	jne    801a3f <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801a6d:	66 b8 00 00          	mov    $0x0,%ax
}
  801a71:	5d                   	pop    %ebp
  801a72:	c3                   	ret    
  801a73:	66 90                	xchg   %ax,%ax
  801a75:	66 90                	xchg   %ax,%ax
  801a77:	66 90                	xchg   %ax,%ax
  801a79:	66 90                	xchg   %ax,%ax
  801a7b:	66 90                	xchg   %ax,%ax
  801a7d:	66 90                	xchg   %ax,%ax
  801a7f:	90                   	nop

00801a80 <__udivdi3>:
  801a80:	83 ec 1c             	sub    $0x1c,%esp
  801a83:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801a87:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801a8b:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801a8f:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801a93:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801a97:	8b 6c 24 24          	mov    0x24(%esp),%ebp
  801a9b:	85 c0                	test   %eax,%eax
  801a9d:	89 74 24 10          	mov    %esi,0x10(%esp)
  801aa1:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801aa5:	89 ea                	mov    %ebp,%edx
  801aa7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801aab:	75 33                	jne    801ae0 <__udivdi3+0x60>
  801aad:	39 e9                	cmp    %ebp,%ecx
  801aaf:	77 6f                	ja     801b20 <__udivdi3+0xa0>
  801ab1:	85 c9                	test   %ecx,%ecx
  801ab3:	89 ce                	mov    %ecx,%esi
  801ab5:	75 0b                	jne    801ac2 <__udivdi3+0x42>
  801ab7:	b8 01 00 00 00       	mov    $0x1,%eax
  801abc:	31 d2                	xor    %edx,%edx
  801abe:	f7 f1                	div    %ecx
  801ac0:	89 c6                	mov    %eax,%esi
  801ac2:	31 d2                	xor    %edx,%edx
  801ac4:	89 e8                	mov    %ebp,%eax
  801ac6:	f7 f6                	div    %esi
  801ac8:	89 c5                	mov    %eax,%ebp
  801aca:	89 f8                	mov    %edi,%eax
  801acc:	f7 f6                	div    %esi
  801ace:	89 ea                	mov    %ebp,%edx
  801ad0:	8b 74 24 10          	mov    0x10(%esp),%esi
  801ad4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801ad8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801adc:	83 c4 1c             	add    $0x1c,%esp
  801adf:	c3                   	ret    
  801ae0:	39 e8                	cmp    %ebp,%eax
  801ae2:	77 24                	ja     801b08 <__udivdi3+0x88>
  801ae4:	0f bd c8             	bsr    %eax,%ecx
  801ae7:	83 f1 1f             	xor    $0x1f,%ecx
  801aea:	89 0c 24             	mov    %ecx,(%esp)
  801aed:	75 49                	jne    801b38 <__udivdi3+0xb8>
  801aef:	8b 74 24 08          	mov    0x8(%esp),%esi
  801af3:	39 74 24 04          	cmp    %esi,0x4(%esp)
  801af7:	0f 86 ab 00 00 00    	jbe    801ba8 <__udivdi3+0x128>
  801afd:	39 e8                	cmp    %ebp,%eax
  801aff:	0f 82 a3 00 00 00    	jb     801ba8 <__udivdi3+0x128>
  801b05:	8d 76 00             	lea    0x0(%esi),%esi
  801b08:	31 d2                	xor    %edx,%edx
  801b0a:	31 c0                	xor    %eax,%eax
  801b0c:	8b 74 24 10          	mov    0x10(%esp),%esi
  801b10:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801b14:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801b18:	83 c4 1c             	add    $0x1c,%esp
  801b1b:	c3                   	ret    
  801b1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801b20:	89 f8                	mov    %edi,%eax
  801b22:	f7 f1                	div    %ecx
  801b24:	31 d2                	xor    %edx,%edx
  801b26:	8b 74 24 10          	mov    0x10(%esp),%esi
  801b2a:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801b2e:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801b32:	83 c4 1c             	add    $0x1c,%esp
  801b35:	c3                   	ret    
  801b36:	66 90                	xchg   %ax,%ax
  801b38:	0f b6 0c 24          	movzbl (%esp),%ecx
  801b3c:	89 c6                	mov    %eax,%esi
  801b3e:	b8 20 00 00 00       	mov    $0x20,%eax
  801b43:	8b 6c 24 04          	mov    0x4(%esp),%ebp
  801b47:	2b 04 24             	sub    (%esp),%eax
  801b4a:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801b4e:	d3 e6                	shl    %cl,%esi
  801b50:	89 c1                	mov    %eax,%ecx
  801b52:	d3 ed                	shr    %cl,%ebp
  801b54:	0f b6 0c 24          	movzbl (%esp),%ecx
  801b58:	09 f5                	or     %esi,%ebp
  801b5a:	8b 74 24 04          	mov    0x4(%esp),%esi
  801b5e:	d3 e6                	shl    %cl,%esi
  801b60:	89 c1                	mov    %eax,%ecx
  801b62:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b66:	89 d6                	mov    %edx,%esi
  801b68:	d3 ee                	shr    %cl,%esi
  801b6a:	0f b6 0c 24          	movzbl (%esp),%ecx
  801b6e:	d3 e2                	shl    %cl,%edx
  801b70:	89 c1                	mov    %eax,%ecx
  801b72:	d3 ef                	shr    %cl,%edi
  801b74:	09 d7                	or     %edx,%edi
  801b76:	89 f2                	mov    %esi,%edx
  801b78:	89 f8                	mov    %edi,%eax
  801b7a:	f7 f5                	div    %ebp
  801b7c:	89 d6                	mov    %edx,%esi
  801b7e:	89 c7                	mov    %eax,%edi
  801b80:	f7 64 24 04          	mull   0x4(%esp)
  801b84:	39 d6                	cmp    %edx,%esi
  801b86:	72 30                	jb     801bb8 <__udivdi3+0x138>
  801b88:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801b8c:	0f b6 0c 24          	movzbl (%esp),%ecx
  801b90:	d3 e5                	shl    %cl,%ebp
  801b92:	39 c5                	cmp    %eax,%ebp
  801b94:	73 04                	jae    801b9a <__udivdi3+0x11a>
  801b96:	39 d6                	cmp    %edx,%esi
  801b98:	74 1e                	je     801bb8 <__udivdi3+0x138>
  801b9a:	89 f8                	mov    %edi,%eax
  801b9c:	31 d2                	xor    %edx,%edx
  801b9e:	e9 69 ff ff ff       	jmp    801b0c <__udivdi3+0x8c>
  801ba3:	90                   	nop
  801ba4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ba8:	31 d2                	xor    %edx,%edx
  801baa:	b8 01 00 00 00       	mov    $0x1,%eax
  801baf:	e9 58 ff ff ff       	jmp    801b0c <__udivdi3+0x8c>
  801bb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801bb8:	8d 47 ff             	lea    -0x1(%edi),%eax
  801bbb:	31 d2                	xor    %edx,%edx
  801bbd:	8b 74 24 10          	mov    0x10(%esp),%esi
  801bc1:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801bc5:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801bc9:	83 c4 1c             	add    $0x1c,%esp
  801bcc:	c3                   	ret    
  801bcd:	66 90                	xchg   %ax,%ax
  801bcf:	90                   	nop

00801bd0 <__umoddi3>:
  801bd0:	83 ec 2c             	sub    $0x2c,%esp
  801bd3:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801bd7:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801bdb:	89 74 24 20          	mov    %esi,0x20(%esp)
  801bdf:	8b 74 24 38          	mov    0x38(%esp),%esi
  801be3:	89 7c 24 24          	mov    %edi,0x24(%esp)
  801be7:	8b 7c 24 34          	mov    0x34(%esp),%edi
  801beb:	85 c0                	test   %eax,%eax
  801bed:	89 c2                	mov    %eax,%edx
  801bef:	89 6c 24 28          	mov    %ebp,0x28(%esp)
  801bf3:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801bf7:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801bfb:	89 74 24 10          	mov    %esi,0x10(%esp)
  801bff:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801c03:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801c07:	75 1f                	jne    801c28 <__umoddi3+0x58>
  801c09:	39 fe                	cmp    %edi,%esi
  801c0b:	76 63                	jbe    801c70 <__umoddi3+0xa0>
  801c0d:	89 c8                	mov    %ecx,%eax
  801c0f:	89 fa                	mov    %edi,%edx
  801c11:	f7 f6                	div    %esi
  801c13:	89 d0                	mov    %edx,%eax
  801c15:	31 d2                	xor    %edx,%edx
  801c17:	8b 74 24 20          	mov    0x20(%esp),%esi
  801c1b:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801c1f:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801c23:	83 c4 2c             	add    $0x2c,%esp
  801c26:	c3                   	ret    
  801c27:	90                   	nop
  801c28:	39 f8                	cmp    %edi,%eax
  801c2a:	77 64                	ja     801c90 <__umoddi3+0xc0>
  801c2c:	0f bd e8             	bsr    %eax,%ebp
  801c2f:	83 f5 1f             	xor    $0x1f,%ebp
  801c32:	75 74                	jne    801ca8 <__umoddi3+0xd8>
  801c34:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801c38:	39 7c 24 10          	cmp    %edi,0x10(%esp)
  801c3c:	0f 87 0e 01 00 00    	ja     801d50 <__umoddi3+0x180>
  801c42:	8b 7c 24 0c          	mov    0xc(%esp),%edi
  801c46:	29 f1                	sub    %esi,%ecx
  801c48:	19 c7                	sbb    %eax,%edi
  801c4a:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801c4e:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801c52:	8b 44 24 14          	mov    0x14(%esp),%eax
  801c56:	8b 54 24 18          	mov    0x18(%esp),%edx
  801c5a:	8b 74 24 20          	mov    0x20(%esp),%esi
  801c5e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801c62:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801c66:	83 c4 2c             	add    $0x2c,%esp
  801c69:	c3                   	ret    
  801c6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c70:	85 f6                	test   %esi,%esi
  801c72:	89 f5                	mov    %esi,%ebp
  801c74:	75 0b                	jne    801c81 <__umoddi3+0xb1>
  801c76:	b8 01 00 00 00       	mov    $0x1,%eax
  801c7b:	31 d2                	xor    %edx,%edx
  801c7d:	f7 f6                	div    %esi
  801c7f:	89 c5                	mov    %eax,%ebp
  801c81:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801c85:	31 d2                	xor    %edx,%edx
  801c87:	f7 f5                	div    %ebp
  801c89:	89 c8                	mov    %ecx,%eax
  801c8b:	f7 f5                	div    %ebp
  801c8d:	eb 84                	jmp    801c13 <__umoddi3+0x43>
  801c8f:	90                   	nop
  801c90:	89 c8                	mov    %ecx,%eax
  801c92:	89 fa                	mov    %edi,%edx
  801c94:	8b 74 24 20          	mov    0x20(%esp),%esi
  801c98:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801c9c:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801ca0:	83 c4 2c             	add    $0x2c,%esp
  801ca3:	c3                   	ret    
  801ca4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ca8:	8b 44 24 10          	mov    0x10(%esp),%eax
  801cac:	be 20 00 00 00       	mov    $0x20,%esi
  801cb1:	89 e9                	mov    %ebp,%ecx
  801cb3:	29 ee                	sub    %ebp,%esi
  801cb5:	d3 e2                	shl    %cl,%edx
  801cb7:	89 f1                	mov    %esi,%ecx
  801cb9:	d3 e8                	shr    %cl,%eax
  801cbb:	89 e9                	mov    %ebp,%ecx
  801cbd:	09 d0                	or     %edx,%eax
  801cbf:	89 fa                	mov    %edi,%edx
  801cc1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801cc5:	8b 44 24 10          	mov    0x10(%esp),%eax
  801cc9:	d3 e0                	shl    %cl,%eax
  801ccb:	89 f1                	mov    %esi,%ecx
  801ccd:	89 44 24 10          	mov    %eax,0x10(%esp)
  801cd1:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801cd5:	d3 ea                	shr    %cl,%edx
  801cd7:	89 e9                	mov    %ebp,%ecx
  801cd9:	d3 e7                	shl    %cl,%edi
  801cdb:	89 f1                	mov    %esi,%ecx
  801cdd:	d3 e8                	shr    %cl,%eax
  801cdf:	89 e9                	mov    %ebp,%ecx
  801ce1:	09 f8                	or     %edi,%eax
  801ce3:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801ce7:	f7 74 24 0c          	divl   0xc(%esp)
  801ceb:	d3 e7                	shl    %cl,%edi
  801ced:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801cf1:	89 d7                	mov    %edx,%edi
  801cf3:	f7 64 24 10          	mull   0x10(%esp)
  801cf7:	39 d7                	cmp    %edx,%edi
  801cf9:	89 c1                	mov    %eax,%ecx
  801cfb:	89 54 24 14          	mov    %edx,0x14(%esp)
  801cff:	72 3b                	jb     801d3c <__umoddi3+0x16c>
  801d01:	39 44 24 18          	cmp    %eax,0x18(%esp)
  801d05:	72 31                	jb     801d38 <__umoddi3+0x168>
  801d07:	8b 44 24 18          	mov    0x18(%esp),%eax
  801d0b:	29 c8                	sub    %ecx,%eax
  801d0d:	19 d7                	sbb    %edx,%edi
  801d0f:	89 e9                	mov    %ebp,%ecx
  801d11:	89 fa                	mov    %edi,%edx
  801d13:	d3 e8                	shr    %cl,%eax
  801d15:	89 f1                	mov    %esi,%ecx
  801d17:	d3 e2                	shl    %cl,%edx
  801d19:	89 e9                	mov    %ebp,%ecx
  801d1b:	09 d0                	or     %edx,%eax
  801d1d:	89 fa                	mov    %edi,%edx
  801d1f:	d3 ea                	shr    %cl,%edx
  801d21:	8b 74 24 20          	mov    0x20(%esp),%esi
  801d25:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801d29:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801d2d:	83 c4 2c             	add    $0x2c,%esp
  801d30:	c3                   	ret    
  801d31:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d38:	39 d7                	cmp    %edx,%edi
  801d3a:	75 cb                	jne    801d07 <__umoddi3+0x137>
  801d3c:	8b 54 24 14          	mov    0x14(%esp),%edx
  801d40:	89 c1                	mov    %eax,%ecx
  801d42:	2b 4c 24 10          	sub    0x10(%esp),%ecx
  801d46:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  801d4a:	eb bb                	jmp    801d07 <__umoddi3+0x137>
  801d4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d50:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801d54:	0f 82 e8 fe ff ff    	jb     801c42 <__umoddi3+0x72>
  801d5a:	e9 f3 fe ff ff       	jmp    801c52 <__umoddi3+0x82>
