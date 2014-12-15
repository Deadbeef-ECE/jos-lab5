
obj/user/divzero.debug:     file format elf32-i386


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
  80002c:	e8 37 00 00 00       	call   800068 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	90                   	nop

00800034 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	zero = 0;
  80003a:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  800041:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800044:	b8 01 00 00 00       	mov    $0x1,%eax
  800049:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004e:	89 c2                	mov    %eax,%edx
  800050:	c1 fa 1f             	sar    $0x1f,%edx
  800053:	f7 f9                	idiv   %ecx
  800055:	89 44 24 04          	mov    %eax,0x4(%esp)
  800059:	c7 04 24 c0 1c 80 00 	movl   $0x801cc0,(%esp)
  800060:	e8 12 01 00 00       	call   800177 <cprintf>
}
  800065:	c9                   	leave  
  800066:	c3                   	ret    
  800067:	90                   	nop

00800068 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800068:	55                   	push   %ebp
  800069:	89 e5                	mov    %esp,%ebp
  80006b:	83 ec 18             	sub    $0x18,%esp
  80006e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800071:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800074:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800077:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;

	thisenv = &envs[ENVX(sys_getenvid())];
  80007a:	e8 58 0c 00 00       	call   800cd7 <sys_getenvid>
  80007f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800084:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800087:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008c:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800091:	85 db                	test   %ebx,%ebx
  800093:	7e 07                	jle    80009c <libmain+0x34>
		binaryname = argv[0];
  800095:	8b 06                	mov    (%esi),%eax
  800097:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80009c:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000a0:	89 1c 24             	mov    %ebx,(%esp)
  8000a3:	e8 8c ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a8:	e8 0b 00 00 00       	call   8000b8 <exit>
}
  8000ad:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000b0:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000b3:	89 ec                	mov    %ebp,%esp
  8000b5:	5d                   	pop    %ebp
  8000b6:	c3                   	ret    
  8000b7:	90                   	nop

008000b8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000be:	e8 a0 11 00 00       	call   801263 <close_all>
	sys_env_destroy(0);
  8000c3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ca:	e8 a2 0b 00 00       	call   800c71 <sys_env_destroy>
}
  8000cf:	c9                   	leave  
  8000d0:	c3                   	ret    
  8000d1:	66 90                	xchg   %ax,%ax
  8000d3:	90                   	nop

008000d4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000d4:	55                   	push   %ebp
  8000d5:	89 e5                	mov    %esp,%ebp
  8000d7:	53                   	push   %ebx
  8000d8:	83 ec 14             	sub    $0x14,%esp
  8000db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000de:	8b 03                	mov    (%ebx),%eax
  8000e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000e7:	83 c0 01             	add    $0x1,%eax
  8000ea:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000ec:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000f1:	75 19                	jne    80010c <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8000f3:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000fa:	00 
  8000fb:	8d 43 08             	lea    0x8(%ebx),%eax
  8000fe:	89 04 24             	mov    %eax,(%esp)
  800101:	e8 fa 0a 00 00       	call   800c00 <sys_cputs>
		b->idx = 0;
  800106:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80010c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800110:	83 c4 14             	add    $0x14,%esp
  800113:	5b                   	pop    %ebx
  800114:	5d                   	pop    %ebp
  800115:	c3                   	ret    

00800116 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800116:	55                   	push   %ebp
  800117:	89 e5                	mov    %esp,%ebp
  800119:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80011f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800126:	00 00 00 
	b.cnt = 0;
  800129:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800130:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800133:	8b 45 0c             	mov    0xc(%ebp),%eax
  800136:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80013a:	8b 45 08             	mov    0x8(%ebp),%eax
  80013d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800141:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800147:	89 44 24 04          	mov    %eax,0x4(%esp)
  80014b:	c7 04 24 d4 00 80 00 	movl   $0x8000d4,(%esp)
  800152:	e8 bb 01 00 00       	call   800312 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800157:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80015d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800161:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800167:	89 04 24             	mov    %eax,(%esp)
  80016a:	e8 91 0a 00 00       	call   800c00 <sys_cputs>

	return b.cnt;
}
  80016f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800175:	c9                   	leave  
  800176:	c3                   	ret    

00800177 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800177:	55                   	push   %ebp
  800178:	89 e5                	mov    %esp,%ebp
  80017a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80017d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800180:	89 44 24 04          	mov    %eax,0x4(%esp)
  800184:	8b 45 08             	mov    0x8(%ebp),%eax
  800187:	89 04 24             	mov    %eax,(%esp)
  80018a:	e8 87 ff ff ff       	call   800116 <vcprintf>
	va_end(ap);

	return cnt;
}
  80018f:	c9                   	leave  
  800190:	c3                   	ret    
  800191:	66 90                	xchg   %ax,%ax
  800193:	66 90                	xchg   %ax,%ax
  800195:	66 90                	xchg   %ax,%ax
  800197:	66 90                	xchg   %ax,%ax
  800199:	66 90                	xchg   %ax,%ax
  80019b:	66 90                	xchg   %ax,%ax
  80019d:	66 90                	xchg   %ax,%ax
  80019f:	90                   	nop

008001a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	57                   	push   %edi
  8001a4:	56                   	push   %esi
  8001a5:	53                   	push   %ebx
  8001a6:	83 ec 4c             	sub    $0x4c,%esp
  8001a9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8001ac:	89 d7                	mov    %edx,%edi
  8001ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001b1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8001b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8001b7:	89 5d dc             	mov    %ebx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8001bf:	39 d8                	cmp    %ebx,%eax
  8001c1:	72 17                	jb     8001da <printnum+0x3a>
  8001c3:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8001c6:	39 5d 10             	cmp    %ebx,0x10(%ebp)
  8001c9:	76 0f                	jbe    8001da <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001cb:	8b 75 14             	mov    0x14(%ebp),%esi
  8001ce:	83 ee 01             	sub    $0x1,%esi
  8001d1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8001d4:	85 f6                	test   %esi,%esi
  8001d6:	7f 63                	jg     80023b <printnum+0x9b>
  8001d8:	eb 75                	jmp    80024f <printnum+0xaf>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001da:	8b 5d 18             	mov    0x18(%ebp),%ebx
  8001dd:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8001e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8001e4:	83 e8 01             	sub    $0x1,%eax
  8001e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001eb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001f2:	8b 44 24 08          	mov    0x8(%esp),%eax
  8001f6:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8001fa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001fd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800200:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800207:	00 
  800208:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  80020b:	89 1c 24             	mov    %ebx,(%esp)
  80020e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800211:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800215:	e8 b6 17 00 00       	call   8019d0 <__udivdi3>
  80021a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80021d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800220:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800224:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800228:	89 04 24             	mov    %eax,(%esp)
  80022b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80022f:	89 fa                	mov    %edi,%edx
  800231:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800234:	e8 67 ff ff ff       	call   8001a0 <printnum>
  800239:	eb 14                	jmp    80024f <printnum+0xaf>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80023b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80023f:	8b 45 18             	mov    0x18(%ebp),%eax
  800242:	89 04 24             	mov    %eax,(%esp)
  800245:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800247:	83 ee 01             	sub    $0x1,%esi
  80024a:	75 ef                	jne    80023b <printnum+0x9b>
  80024c:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80024f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800253:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800257:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80025a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80025e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800265:	00 
  800266:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800269:	89 1c 24             	mov    %ebx,(%esp)
  80026c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80026f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800273:	e8 a8 18 00 00       	call   801b20 <__umoddi3>
  800278:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80027c:	0f be 80 d8 1c 80 00 	movsbl 0x801cd8(%eax),%eax
  800283:	89 04 24             	mov    %eax,(%esp)
  800286:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800289:	ff d0                	call   *%eax
}
  80028b:	83 c4 4c             	add    $0x4c,%esp
  80028e:	5b                   	pop    %ebx
  80028f:	5e                   	pop    %esi
  800290:	5f                   	pop    %edi
  800291:	5d                   	pop    %ebp
  800292:	c3                   	ret    

00800293 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800293:	55                   	push   %ebp
  800294:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800296:	83 fa 01             	cmp    $0x1,%edx
  800299:	7e 0e                	jle    8002a9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80029b:	8b 10                	mov    (%eax),%edx
  80029d:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002a0:	89 08                	mov    %ecx,(%eax)
  8002a2:	8b 02                	mov    (%edx),%eax
  8002a4:	8b 52 04             	mov    0x4(%edx),%edx
  8002a7:	eb 22                	jmp    8002cb <getuint+0x38>
	else if (lflag)
  8002a9:	85 d2                	test   %edx,%edx
  8002ab:	74 10                	je     8002bd <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002ad:	8b 10                	mov    (%eax),%edx
  8002af:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b2:	89 08                	mov    %ecx,(%eax)
  8002b4:	8b 02                	mov    (%edx),%eax
  8002b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8002bb:	eb 0e                	jmp    8002cb <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002bd:	8b 10                	mov    (%eax),%edx
  8002bf:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c2:	89 08                	mov    %ecx,(%eax)
  8002c4:	8b 02                	mov    (%edx),%eax
  8002c6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002cb:	5d                   	pop    %ebp
  8002cc:	c3                   	ret    

008002cd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002cd:	55                   	push   %ebp
  8002ce:	89 e5                	mov    %esp,%ebp
  8002d0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002d3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002d7:	8b 10                	mov    (%eax),%edx
  8002d9:	3b 50 04             	cmp    0x4(%eax),%edx
  8002dc:	73 0a                	jae    8002e8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002e1:	88 0a                	mov    %cl,(%edx)
  8002e3:	83 c2 01             	add    $0x1,%edx
  8002e6:	89 10                	mov    %edx,(%eax)
}
  8002e8:	5d                   	pop    %ebp
  8002e9:	c3                   	ret    

008002ea <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ea:	55                   	push   %ebp
  8002eb:	89 e5                	mov    %esp,%ebp
  8002ed:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002f0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002f7:	8b 45 10             	mov    0x10(%ebp),%eax
  8002fa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800301:	89 44 24 04          	mov    %eax,0x4(%esp)
  800305:	8b 45 08             	mov    0x8(%ebp),%eax
  800308:	89 04 24             	mov    %eax,(%esp)
  80030b:	e8 02 00 00 00       	call   800312 <vprintfmt>
	va_end(ap);
}
  800310:	c9                   	leave  
  800311:	c3                   	ret    

00800312 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	57                   	push   %edi
  800316:	56                   	push   %esi
  800317:	53                   	push   %ebx
  800318:	83 ec 4c             	sub    $0x4c,%esp
  80031b:	8b 75 08             	mov    0x8(%ebp),%esi
  80031e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800321:	8b 7d 10             	mov    0x10(%ebp),%edi
  800324:	eb 11                	jmp    800337 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800326:	85 c0                	test   %eax,%eax
  800328:	0f 84 db 03 00 00    	je     800709 <vprintfmt+0x3f7>
				return;
			putch(ch, putdat);
  80032e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800332:	89 04 24             	mov    %eax,(%esp)
  800335:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800337:	0f b6 07             	movzbl (%edi),%eax
  80033a:	83 c7 01             	add    $0x1,%edi
  80033d:	83 f8 25             	cmp    $0x25,%eax
  800340:	75 e4                	jne    800326 <vprintfmt+0x14>
  800342:	c6 45 e4 20          	movb   $0x20,-0x1c(%ebp)
  800346:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80034d:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800354:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80035b:	ba 00 00 00 00       	mov    $0x0,%edx
  800360:	eb 2b                	jmp    80038d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800362:	8b 7d e0             	mov    -0x20(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800365:	c6 45 e4 2d          	movb   $0x2d,-0x1c(%ebp)
  800369:	eb 22                	jmp    80038d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036b:	8b 7d e0             	mov    -0x20(%ebp),%edi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80036e:	c6 45 e4 30          	movb   $0x30,-0x1c(%ebp)
  800372:	eb 19                	jmp    80038d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800374:	8b 7d e0             	mov    -0x20(%ebp),%edi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800377:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80037e:	eb 0d                	jmp    80038d <vprintfmt+0x7b>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800380:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800383:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800386:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038d:	0f b6 0f             	movzbl (%edi),%ecx
  800390:	8d 47 01             	lea    0x1(%edi),%eax
  800393:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800396:	0f b6 07             	movzbl (%edi),%eax
  800399:	83 e8 23             	sub    $0x23,%eax
  80039c:	3c 55                	cmp    $0x55,%al
  80039e:	0f 87 40 03 00 00    	ja     8006e4 <vprintfmt+0x3d2>
  8003a4:	0f b6 c0             	movzbl %al,%eax
  8003a7:	ff 24 85 20 1e 80 00 	jmp    *0x801e20(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003ae:	83 e9 30             	sub    $0x30,%ecx
  8003b1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				ch = *fmt;
  8003b4:	0f be 47 01          	movsbl 0x1(%edi),%eax
				if (ch < '0' || ch > '9')
  8003b8:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8003bb:	83 f9 09             	cmp    $0x9,%ecx
  8003be:	77 57                	ja     800417 <vprintfmt+0x105>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c0:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8003c3:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8003c6:	8b 55 dc             	mov    -0x24(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003c9:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003cc:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8003cf:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8003d3:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8003d6:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8003d9:	83 f9 09             	cmp    $0x9,%ecx
  8003dc:	76 eb                	jbe    8003c9 <vprintfmt+0xb7>
  8003de:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8003e1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003e4:	eb 34                	jmp    80041a <vprintfmt+0x108>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e9:	8d 48 04             	lea    0x4(%eax),%ecx
  8003ec:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003ef:	8b 00                	mov    (%eax),%eax
  8003f1:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f4:	8b 7d e0             	mov    -0x20(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003f7:	eb 21                	jmp    80041a <vprintfmt+0x108>

		case '.':
			if (width < 0)
  8003f9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8003fd:	0f 88 71 ff ff ff    	js     800374 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800403:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800406:	eb 85                	jmp    80038d <vprintfmt+0x7b>
  800408:	8b 7d e0             	mov    -0x20(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80040b:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  800412:	e9 76 ff ff ff       	jmp    80038d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800417:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80041a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80041e:	0f 89 69 ff ff ff    	jns    80038d <vprintfmt+0x7b>
  800424:	e9 57 ff ff ff       	jmp    800380 <vprintfmt+0x6e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800429:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80042f:	e9 59 ff ff ff       	jmp    80038d <vprintfmt+0x7b>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800434:	8b 45 14             	mov    0x14(%ebp),%eax
  800437:	8d 50 04             	lea    0x4(%eax),%edx
  80043a:	89 55 14             	mov    %edx,0x14(%ebp)
  80043d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800441:	8b 00                	mov    (%eax),%eax
  800443:	89 04 24             	mov    %eax,(%esp)
  800446:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800448:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80044b:	e9 e7 fe ff ff       	jmp    800337 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800450:	8b 45 14             	mov    0x14(%ebp),%eax
  800453:	8d 50 04             	lea    0x4(%eax),%edx
  800456:	89 55 14             	mov    %edx,0x14(%ebp)
  800459:	8b 00                	mov    (%eax),%eax
  80045b:	89 c2                	mov    %eax,%edx
  80045d:	c1 fa 1f             	sar    $0x1f,%edx
  800460:	31 d0                	xor    %edx,%eax
  800462:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800464:	83 f8 0f             	cmp    $0xf,%eax
  800467:	7f 0b                	jg     800474 <vprintfmt+0x162>
  800469:	8b 14 85 80 1f 80 00 	mov    0x801f80(,%eax,4),%edx
  800470:	85 d2                	test   %edx,%edx
  800472:	75 20                	jne    800494 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  800474:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800478:	c7 44 24 08 f0 1c 80 	movl   $0x801cf0,0x8(%esp)
  80047f:	00 
  800480:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800484:	89 34 24             	mov    %esi,(%esp)
  800487:	e8 5e fe ff ff       	call   8002ea <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048c:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80048f:	e9 a3 fe ff ff       	jmp    800337 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800494:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800498:	c7 44 24 08 f9 1c 80 	movl   $0x801cf9,0x8(%esp)
  80049f:	00 
  8004a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004a4:	89 34 24             	mov    %esi,(%esp)
  8004a7:	e8 3e fe ff ff       	call   8002ea <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ac:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8004af:	e9 83 fe ff ff       	jmp    800337 <vprintfmt+0x25>
  8004b4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004b7:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8004ba:	89 7d cc             	mov    %edi,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c0:	8d 50 04             	lea    0x4(%eax),%edx
  8004c3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004c8:	85 ff                	test   %edi,%edi
  8004ca:	b8 e9 1c 80 00       	mov    $0x801ce9,%eax
  8004cf:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004d2:	80 7d e4 2d          	cmpb   $0x2d,-0x1c(%ebp)
  8004d6:	74 06                	je     8004de <vprintfmt+0x1cc>
  8004d8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004dc:	7f 16                	jg     8004f4 <vprintfmt+0x1e2>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004de:	0f b6 17             	movzbl (%edi),%edx
  8004e1:	0f be c2             	movsbl %dl,%eax
  8004e4:	83 c7 01             	add    $0x1,%edi
  8004e7:	85 c0                	test   %eax,%eax
  8004e9:	0f 85 9f 00 00 00    	jne    80058e <vprintfmt+0x27c>
  8004ef:	e9 8b 00 00 00       	jmp    80057f <vprintfmt+0x26d>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004f8:	89 3c 24             	mov    %edi,(%esp)
  8004fb:	e8 c2 02 00 00       	call   8007c2 <strnlen>
  800500:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800503:	29 c2                	sub    %eax,%edx
  800505:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800508:	85 d2                	test   %edx,%edx
  80050a:	7e d2                	jle    8004de <vprintfmt+0x1cc>
					putch(padc, putdat);
  80050c:	0f be 4d e4          	movsbl -0x1c(%ebp),%ecx
  800510:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800513:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800516:	89 d7                	mov    %edx,%edi
  800518:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80051c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80051f:	89 04 24             	mov    %eax,(%esp)
  800522:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800524:	83 ef 01             	sub    $0x1,%edi
  800527:	75 ef                	jne    800518 <vprintfmt+0x206>
  800529:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80052c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80052f:	eb ad                	jmp    8004de <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800531:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800535:	74 20                	je     800557 <vprintfmt+0x245>
  800537:	0f be d2             	movsbl %dl,%edx
  80053a:	83 ea 20             	sub    $0x20,%edx
  80053d:	83 fa 5e             	cmp    $0x5e,%edx
  800540:	76 15                	jbe    800557 <vprintfmt+0x245>
					putch('?', putdat);
  800542:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800545:	89 54 24 04          	mov    %edx,0x4(%esp)
  800549:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800550:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800553:	ff d1                	call   *%ecx
  800555:	eb 0f                	jmp    800566 <vprintfmt+0x254>
				else
					putch(ch, putdat);
  800557:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80055a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80055e:	89 04 24             	mov    %eax,(%esp)
  800561:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800564:	ff d1                	call   *%ecx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800566:	83 eb 01             	sub    $0x1,%ebx
  800569:	0f b6 17             	movzbl (%edi),%edx
  80056c:	0f be c2             	movsbl %dl,%eax
  80056f:	83 c7 01             	add    $0x1,%edi
  800572:	85 c0                	test   %eax,%eax
  800574:	75 24                	jne    80059a <vprintfmt+0x288>
  800576:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800579:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80057c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057f:	8b 7d e0             	mov    -0x20(%ebp),%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800582:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800586:	0f 8e ab fd ff ff    	jle    800337 <vprintfmt+0x25>
  80058c:	eb 20                	jmp    8005ae <vprintfmt+0x29c>
  80058e:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800591:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800594:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  800597:	8b 5d d8             	mov    -0x28(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80059a:	85 f6                	test   %esi,%esi
  80059c:	78 93                	js     800531 <vprintfmt+0x21f>
  80059e:	83 ee 01             	sub    $0x1,%esi
  8005a1:	79 8e                	jns    800531 <vprintfmt+0x21f>
  8005a3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8005a6:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8005a9:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8005ac:	eb d1                	jmp    80057f <vprintfmt+0x26d>
  8005ae:	8b 7d d8             	mov    -0x28(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005b1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005bc:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005be:	83 ef 01             	sub    $0x1,%edi
  8005c1:	75 ee                	jne    8005b1 <vprintfmt+0x29f>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c3:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005c6:	e9 6c fd ff ff       	jmp    800337 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005cb:	83 fa 01             	cmp    $0x1,%edx
  8005ce:	66 90                	xchg   %ax,%ax
  8005d0:	7e 16                	jle    8005e8 <vprintfmt+0x2d6>
		return va_arg(*ap, long long);
  8005d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d5:	8d 50 08             	lea    0x8(%eax),%edx
  8005d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005db:	8b 10                	mov    (%eax),%edx
  8005dd:	8b 48 04             	mov    0x4(%eax),%ecx
  8005e0:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8005e3:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8005e6:	eb 32                	jmp    80061a <vprintfmt+0x308>
	else if (lflag)
  8005e8:	85 d2                	test   %edx,%edx
  8005ea:	74 18                	je     800604 <vprintfmt+0x2f2>
		return va_arg(*ap, long);
  8005ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ef:	8d 50 04             	lea    0x4(%eax),%edx
  8005f2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f5:	8b 00                	mov    (%eax),%eax
  8005f7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005fa:	89 c1                	mov    %eax,%ecx
  8005fc:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ff:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800602:	eb 16                	jmp    80061a <vprintfmt+0x308>
	else
		return va_arg(*ap, int);
  800604:	8b 45 14             	mov    0x14(%ebp),%eax
  800607:	8d 50 04             	lea    0x4(%eax),%edx
  80060a:	89 55 14             	mov    %edx,0x14(%ebp)
  80060d:	8b 00                	mov    (%eax),%eax
  80060f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800612:	89 c7                	mov    %eax,%edi
  800614:	c1 ff 1f             	sar    $0x1f,%edi
  800617:	89 7d d4             	mov    %edi,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80061a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80061d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800620:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800625:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800629:	79 7d                	jns    8006a8 <vprintfmt+0x396>
				putch('-', putdat);
  80062b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80062f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800636:	ff d6                	call   *%esi
				num = -(long long) num;
  800638:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80063b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80063e:	f7 d8                	neg    %eax
  800640:	83 d2 00             	adc    $0x0,%edx
  800643:	f7 da                	neg    %edx
			}
			base = 10;
  800645:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80064a:	eb 5c                	jmp    8006a8 <vprintfmt+0x396>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80064c:	8d 45 14             	lea    0x14(%ebp),%eax
  80064f:	e8 3f fc ff ff       	call   800293 <getuint>
			base = 10;
  800654:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800659:	eb 4d                	jmp    8006a8 <vprintfmt+0x396>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80065b:	8d 45 14             	lea    0x14(%ebp),%eax
  80065e:	e8 30 fc ff ff       	call   800293 <getuint>
			base = 8;
  800663:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800668:	eb 3e                	jmp    8006a8 <vprintfmt+0x396>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80066a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80066e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800675:	ff d6                	call   *%esi
			putch('x', putdat);
  800677:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80067b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800682:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800684:	8b 45 14             	mov    0x14(%ebp),%eax
  800687:	8d 50 04             	lea    0x4(%eax),%edx
  80068a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80068d:	8b 00                	mov    (%eax),%eax
  80068f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800694:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800699:	eb 0d                	jmp    8006a8 <vprintfmt+0x396>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80069b:	8d 45 14             	lea    0x14(%ebp),%eax
  80069e:	e8 f0 fb ff ff       	call   800293 <getuint>
			base = 16;
  8006a3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006a8:	0f be 7d e4          	movsbl -0x1c(%ebp),%edi
  8006ac:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8006b0:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8006b3:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8006b7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8006bb:	89 04 24             	mov    %eax,(%esp)
  8006be:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006c2:	89 da                	mov    %ebx,%edx
  8006c4:	89 f0                	mov    %esi,%eax
  8006c6:	e8 d5 fa ff ff       	call   8001a0 <printnum>
			break;
  8006cb:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8006ce:	e9 64 fc ff ff       	jmp    800337 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006d3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006d7:	89 0c 24             	mov    %ecx,(%esp)
  8006da:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006dc:	8b 7d e0             	mov    -0x20(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006df:	e9 53 fc ff ff       	jmp    800337 <vprintfmt+0x25>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006e4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006e8:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006ef:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006f1:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006f5:	0f 84 3c fc ff ff    	je     800337 <vprintfmt+0x25>
  8006fb:	83 ef 01             	sub    $0x1,%edi
  8006fe:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800702:	75 f7                	jne    8006fb <vprintfmt+0x3e9>
  800704:	e9 2e fc ff ff       	jmp    800337 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800709:	83 c4 4c             	add    $0x4c,%esp
  80070c:	5b                   	pop    %ebx
  80070d:	5e                   	pop    %esi
  80070e:	5f                   	pop    %edi
  80070f:	5d                   	pop    %ebp
  800710:	c3                   	ret    

00800711 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800711:	55                   	push   %ebp
  800712:	89 e5                	mov    %esp,%ebp
  800714:	83 ec 28             	sub    $0x28,%esp
  800717:	8b 45 08             	mov    0x8(%ebp),%eax
  80071a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80071d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800720:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800724:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800727:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80072e:	85 d2                	test   %edx,%edx
  800730:	7e 30                	jle    800762 <vsnprintf+0x51>
  800732:	85 c0                	test   %eax,%eax
  800734:	74 2c                	je     800762 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800736:	8b 45 14             	mov    0x14(%ebp),%eax
  800739:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80073d:	8b 45 10             	mov    0x10(%ebp),%eax
  800740:	89 44 24 08          	mov    %eax,0x8(%esp)
  800744:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800747:	89 44 24 04          	mov    %eax,0x4(%esp)
  80074b:	c7 04 24 cd 02 80 00 	movl   $0x8002cd,(%esp)
  800752:	e8 bb fb ff ff       	call   800312 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800757:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80075a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80075d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800760:	eb 05                	jmp    800767 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800762:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800767:	c9                   	leave  
  800768:	c3                   	ret    

00800769 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800769:	55                   	push   %ebp
  80076a:	89 e5                	mov    %esp,%ebp
  80076c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80076f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800772:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800776:	8b 45 10             	mov    0x10(%ebp),%eax
  800779:	89 44 24 08          	mov    %eax,0x8(%esp)
  80077d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800780:	89 44 24 04          	mov    %eax,0x4(%esp)
  800784:	8b 45 08             	mov    0x8(%ebp),%eax
  800787:	89 04 24             	mov    %eax,(%esp)
  80078a:	e8 82 ff ff ff       	call   800711 <vsnprintf>
	va_end(ap);

	return rc;
}
  80078f:	c9                   	leave  
  800790:	c3                   	ret    
  800791:	66 90                	xchg   %ax,%ax
  800793:	66 90                	xchg   %ax,%ax
  800795:	66 90                	xchg   %ax,%ax
  800797:	66 90                	xchg   %ax,%ax
  800799:	66 90                	xchg   %ax,%ax
  80079b:	66 90                	xchg   %ax,%ax
  80079d:	66 90                	xchg   %ax,%ax
  80079f:	90                   	nop

008007a0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007a0:	55                   	push   %ebp
  8007a1:	89 e5                	mov    %esp,%ebp
  8007a3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a6:	80 3a 00             	cmpb   $0x0,(%edx)
  8007a9:	74 10                	je     8007bb <strlen+0x1b>
  8007ab:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007b0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007b7:	75 f7                	jne    8007b0 <strlen+0x10>
  8007b9:	eb 05                	jmp    8007c0 <strlen+0x20>
  8007bb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007c0:	5d                   	pop    %ebp
  8007c1:	c3                   	ret    

008007c2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	53                   	push   %ebx
  8007c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007cc:	85 c9                	test   %ecx,%ecx
  8007ce:	74 1c                	je     8007ec <strnlen+0x2a>
  8007d0:	80 3b 00             	cmpb   $0x0,(%ebx)
  8007d3:	74 1e                	je     8007f3 <strnlen+0x31>
  8007d5:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8007da:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007dc:	39 ca                	cmp    %ecx,%edx
  8007de:	74 18                	je     8007f8 <strnlen+0x36>
  8007e0:	83 c2 01             	add    $0x1,%edx
  8007e3:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8007e8:	75 f0                	jne    8007da <strnlen+0x18>
  8007ea:	eb 0c                	jmp    8007f8 <strnlen+0x36>
  8007ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f1:	eb 05                	jmp    8007f8 <strnlen+0x36>
  8007f3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007f8:	5b                   	pop    %ebx
  8007f9:	5d                   	pop    %ebp
  8007fa:	c3                   	ret    

008007fb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	53                   	push   %ebx
  8007ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800802:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800805:	89 c2                	mov    %eax,%edx
  800807:	0f b6 19             	movzbl (%ecx),%ebx
  80080a:	88 1a                	mov    %bl,(%edx)
  80080c:	83 c2 01             	add    $0x1,%edx
  80080f:	83 c1 01             	add    $0x1,%ecx
  800812:	84 db                	test   %bl,%bl
  800814:	75 f1                	jne    800807 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800816:	5b                   	pop    %ebx
  800817:	5d                   	pop    %ebp
  800818:	c3                   	ret    

00800819 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800819:	55                   	push   %ebp
  80081a:	89 e5                	mov    %esp,%ebp
  80081c:	53                   	push   %ebx
  80081d:	83 ec 08             	sub    $0x8,%esp
  800820:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800823:	89 1c 24             	mov    %ebx,(%esp)
  800826:	e8 75 ff ff ff       	call   8007a0 <strlen>
	strcpy(dst + len, src);
  80082b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80082e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800832:	01 d8                	add    %ebx,%eax
  800834:	89 04 24             	mov    %eax,(%esp)
  800837:	e8 bf ff ff ff       	call   8007fb <strcpy>
	return dst;
}
  80083c:	89 d8                	mov    %ebx,%eax
  80083e:	83 c4 08             	add    $0x8,%esp
  800841:	5b                   	pop    %ebx
  800842:	5d                   	pop    %ebp
  800843:	c3                   	ret    

00800844 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800844:	55                   	push   %ebp
  800845:	89 e5                	mov    %esp,%ebp
  800847:	56                   	push   %esi
  800848:	53                   	push   %ebx
  800849:	8b 75 08             	mov    0x8(%ebp),%esi
  80084c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800852:	85 db                	test   %ebx,%ebx
  800854:	74 16                	je     80086c <strncpy+0x28>
	strcpy(dst + len, src);
	return dst;
}

char *
strncpy(char *dst, const char *src, size_t size) {
  800856:	01 f3                	add    %esi,%ebx
  800858:	89 f1                	mov    %esi,%ecx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  80085a:	0f b6 02             	movzbl (%edx),%eax
  80085d:	88 01                	mov    %al,(%ecx)
  80085f:	83 c1 01             	add    $0x1,%ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800862:	80 3a 01             	cmpb   $0x1,(%edx)
  800865:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800868:	39 d9                	cmp    %ebx,%ecx
  80086a:	75 ee                	jne    80085a <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80086c:	89 f0                	mov    %esi,%eax
  80086e:	5b                   	pop    %ebx
  80086f:	5e                   	pop    %esi
  800870:	5d                   	pop    %ebp
  800871:	c3                   	ret    

00800872 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	57                   	push   %edi
  800876:	56                   	push   %esi
  800877:	53                   	push   %ebx
  800878:	8b 7d 08             	mov    0x8(%ebp),%edi
  80087b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80087e:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800881:	89 f8                	mov    %edi,%eax
  800883:	85 f6                	test   %esi,%esi
  800885:	74 33                	je     8008ba <strlcpy+0x48>
		while (--size > 0 && *src != '\0')
  800887:	83 fe 01             	cmp    $0x1,%esi
  80088a:	74 25                	je     8008b1 <strlcpy+0x3f>
  80088c:	0f b6 0b             	movzbl (%ebx),%ecx
  80088f:	84 c9                	test   %cl,%cl
  800891:	74 22                	je     8008b5 <strlcpy+0x43>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800893:	83 ee 02             	sub    $0x2,%esi
  800896:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80089b:	88 08                	mov    %cl,(%eax)
  80089d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008a0:	39 f2                	cmp    %esi,%edx
  8008a2:	74 13                	je     8008b7 <strlcpy+0x45>
  8008a4:	83 c2 01             	add    $0x1,%edx
  8008a7:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8008ab:	84 c9                	test   %cl,%cl
  8008ad:	75 ec                	jne    80089b <strlcpy+0x29>
  8008af:	eb 06                	jmp    8008b7 <strlcpy+0x45>
  8008b1:	89 f8                	mov    %edi,%eax
  8008b3:	eb 02                	jmp    8008b7 <strlcpy+0x45>
  8008b5:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008b7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008ba:	29 f8                	sub    %edi,%eax
}
  8008bc:	5b                   	pop    %ebx
  8008bd:	5e                   	pop    %esi
  8008be:	5f                   	pop    %edi
  8008bf:	5d                   	pop    %ebp
  8008c0:	c3                   	ret    

008008c1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008c1:	55                   	push   %ebp
  8008c2:	89 e5                	mov    %esp,%ebp
  8008c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008ca:	0f b6 01             	movzbl (%ecx),%eax
  8008cd:	84 c0                	test   %al,%al
  8008cf:	74 15                	je     8008e6 <strcmp+0x25>
  8008d1:	3a 02                	cmp    (%edx),%al
  8008d3:	75 11                	jne    8008e6 <strcmp+0x25>
		p++, q++;
  8008d5:	83 c1 01             	add    $0x1,%ecx
  8008d8:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008db:	0f b6 01             	movzbl (%ecx),%eax
  8008de:	84 c0                	test   %al,%al
  8008e0:	74 04                	je     8008e6 <strcmp+0x25>
  8008e2:	3a 02                	cmp    (%edx),%al
  8008e4:	74 ef                	je     8008d5 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e6:	0f b6 c0             	movzbl %al,%eax
  8008e9:	0f b6 12             	movzbl (%edx),%edx
  8008ec:	29 d0                	sub    %edx,%eax
}
  8008ee:	5d                   	pop    %ebp
  8008ef:	c3                   	ret    

008008f0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008f0:	55                   	push   %ebp
  8008f1:	89 e5                	mov    %esp,%ebp
  8008f3:	56                   	push   %esi
  8008f4:	53                   	push   %ebx
  8008f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008fb:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  8008fe:	85 f6                	test   %esi,%esi
  800900:	74 29                	je     80092b <strncmp+0x3b>
  800902:	0f b6 03             	movzbl (%ebx),%eax
  800905:	84 c0                	test   %al,%al
  800907:	74 30                	je     800939 <strncmp+0x49>
  800909:	3a 02                	cmp    (%edx),%al
  80090b:	75 2c                	jne    800939 <strncmp+0x49>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}

int
strncmp(const char *p, const char *q, size_t n)
  80090d:	8d 43 01             	lea    0x1(%ebx),%eax
  800910:	01 de                	add    %ebx,%esi
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800912:	89 c3                	mov    %eax,%ebx
  800914:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800917:	39 f0                	cmp    %esi,%eax
  800919:	74 17                	je     800932 <strncmp+0x42>
  80091b:	0f b6 08             	movzbl (%eax),%ecx
  80091e:	84 c9                	test   %cl,%cl
  800920:	74 17                	je     800939 <strncmp+0x49>
  800922:	83 c0 01             	add    $0x1,%eax
  800925:	3a 0a                	cmp    (%edx),%cl
  800927:	74 e9                	je     800912 <strncmp+0x22>
  800929:	eb 0e                	jmp    800939 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  80092b:	b8 00 00 00 00       	mov    $0x0,%eax
  800930:	eb 0f                	jmp    800941 <strncmp+0x51>
  800932:	b8 00 00 00 00       	mov    $0x0,%eax
  800937:	eb 08                	jmp    800941 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800939:	0f b6 03             	movzbl (%ebx),%eax
  80093c:	0f b6 12             	movzbl (%edx),%edx
  80093f:	29 d0                	sub    %edx,%eax
}
  800941:	5b                   	pop    %ebx
  800942:	5e                   	pop    %esi
  800943:	5d                   	pop    %ebp
  800944:	c3                   	ret    

00800945 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800945:	55                   	push   %ebp
  800946:	89 e5                	mov    %esp,%ebp
  800948:	53                   	push   %ebx
  800949:	8b 45 08             	mov    0x8(%ebp),%eax
  80094c:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  80094f:	0f b6 18             	movzbl (%eax),%ebx
  800952:	84 db                	test   %bl,%bl
  800954:	74 1d                	je     800973 <strchr+0x2e>
  800956:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800958:	38 d3                	cmp    %dl,%bl
  80095a:	75 06                	jne    800962 <strchr+0x1d>
  80095c:	eb 1a                	jmp    800978 <strchr+0x33>
  80095e:	38 ca                	cmp    %cl,%dl
  800960:	74 16                	je     800978 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800962:	83 c0 01             	add    $0x1,%eax
  800965:	0f b6 10             	movzbl (%eax),%edx
  800968:	84 d2                	test   %dl,%dl
  80096a:	75 f2                	jne    80095e <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  80096c:	b8 00 00 00 00       	mov    $0x0,%eax
  800971:	eb 05                	jmp    800978 <strchr+0x33>
  800973:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800978:	5b                   	pop    %ebx
  800979:	5d                   	pop    %ebp
  80097a:	c3                   	ret    

0080097b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	53                   	push   %ebx
  80097f:	8b 45 08             	mov    0x8(%ebp),%eax
  800982:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800985:	0f b6 18             	movzbl (%eax),%ebx
  800988:	84 db                	test   %bl,%bl
  80098a:	74 16                	je     8009a2 <strfind+0x27>
  80098c:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  80098e:	38 d3                	cmp    %dl,%bl
  800990:	75 06                	jne    800998 <strfind+0x1d>
  800992:	eb 0e                	jmp    8009a2 <strfind+0x27>
  800994:	38 ca                	cmp    %cl,%dl
  800996:	74 0a                	je     8009a2 <strfind+0x27>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800998:	83 c0 01             	add    $0x1,%eax
  80099b:	0f b6 10             	movzbl (%eax),%edx
  80099e:	84 d2                	test   %dl,%dl
  8009a0:	75 f2                	jne    800994 <strfind+0x19>
		if (*s == c)
			break;
	return (char *) s;
}
  8009a2:	5b                   	pop    %ebx
  8009a3:	5d                   	pop    %ebp
  8009a4:	c3                   	ret    

008009a5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009a5:	55                   	push   %ebp
  8009a6:	89 e5                	mov    %esp,%ebp
  8009a8:	83 ec 0c             	sub    $0xc,%esp
  8009ab:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8009ae:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8009b1:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8009b4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009b7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009ba:	85 c9                	test   %ecx,%ecx
  8009bc:	74 36                	je     8009f4 <memset+0x4f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009be:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009c4:	75 28                	jne    8009ee <memset+0x49>
  8009c6:	f6 c1 03             	test   $0x3,%cl
  8009c9:	75 23                	jne    8009ee <memset+0x49>
		c &= 0xFF;
  8009cb:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009cf:	89 d3                	mov    %edx,%ebx
  8009d1:	c1 e3 08             	shl    $0x8,%ebx
  8009d4:	89 d6                	mov    %edx,%esi
  8009d6:	c1 e6 18             	shl    $0x18,%esi
  8009d9:	89 d0                	mov    %edx,%eax
  8009db:	c1 e0 10             	shl    $0x10,%eax
  8009de:	09 f0                	or     %esi,%eax
  8009e0:	09 c2                	or     %eax,%edx
  8009e2:	89 d0                	mov    %edx,%eax
  8009e4:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009e6:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009e9:	fc                   	cld    
  8009ea:	f3 ab                	rep stos %eax,%es:(%edi)
  8009ec:	eb 06                	jmp    8009f4 <memset+0x4f>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f1:	fc                   	cld    
  8009f2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");

	return v;
}
  8009f4:	89 f8                	mov    %edi,%eax
  8009f6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8009f9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8009fc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8009ff:	89 ec                	mov    %ebp,%esp
  800a01:	5d                   	pop    %ebp
  800a02:	c3                   	ret    

00800a03 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a03:	55                   	push   %ebp
  800a04:	89 e5                	mov    %esp,%ebp
  800a06:	83 ec 08             	sub    $0x8,%esp
  800a09:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800a0c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800a0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a12:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a15:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a18:	39 c6                	cmp    %eax,%esi
  800a1a:	73 36                	jae    800a52 <memmove+0x4f>
  800a1c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a1f:	39 d0                	cmp    %edx,%eax
  800a21:	73 2f                	jae    800a52 <memmove+0x4f>
		s += n;
		d += n;
  800a23:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a26:	f6 c2 03             	test   $0x3,%dl
  800a29:	75 1b                	jne    800a46 <memmove+0x43>
  800a2b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a31:	75 13                	jne    800a46 <memmove+0x43>
  800a33:	f6 c1 03             	test   $0x3,%cl
  800a36:	75 0e                	jne    800a46 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a38:	83 ef 04             	sub    $0x4,%edi
  800a3b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a3e:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a41:	fd                   	std    
  800a42:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a44:	eb 09                	jmp    800a4f <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a46:	83 ef 01             	sub    $0x1,%edi
  800a49:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a4c:	fd                   	std    
  800a4d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a4f:	fc                   	cld    
  800a50:	eb 20                	jmp    800a72 <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a52:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a58:	75 13                	jne    800a6d <memmove+0x6a>
  800a5a:	a8 03                	test   $0x3,%al
  800a5c:	75 0f                	jne    800a6d <memmove+0x6a>
  800a5e:	f6 c1 03             	test   $0x3,%cl
  800a61:	75 0a                	jne    800a6d <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a63:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a66:	89 c7                	mov    %eax,%edi
  800a68:	fc                   	cld    
  800a69:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a6b:	eb 05                	jmp    800a72 <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a6d:	89 c7                	mov    %eax,%edi
  800a6f:	fc                   	cld    
  800a70:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a72:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800a75:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800a78:	89 ec                	mov    %ebp,%esp
  800a7a:	5d                   	pop    %ebp
  800a7b:	c3                   	ret    

00800a7c <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a82:	8b 45 10             	mov    0x10(%ebp),%eax
  800a85:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a89:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a8c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a90:	8b 45 08             	mov    0x8(%ebp),%eax
  800a93:	89 04 24             	mov    %eax,(%esp)
  800a96:	e8 68 ff ff ff       	call   800a03 <memmove>
}
  800a9b:	c9                   	leave  
  800a9c:	c3                   	ret    

00800a9d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a9d:	55                   	push   %ebp
  800a9e:	89 e5                	mov    %esp,%ebp
  800aa0:	57                   	push   %edi
  800aa1:	56                   	push   %esi
  800aa2:	53                   	push   %ebx
  800aa3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800aa6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa9:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aac:	8d 78 ff             	lea    -0x1(%eax),%edi
  800aaf:	85 c0                	test   %eax,%eax
  800ab1:	74 36                	je     800ae9 <memcmp+0x4c>
		if (*s1 != *s2)
  800ab3:	0f b6 03             	movzbl (%ebx),%eax
  800ab6:	0f b6 0e             	movzbl (%esi),%ecx
  800ab9:	38 c8                	cmp    %cl,%al
  800abb:	75 17                	jne    800ad4 <memcmp+0x37>
  800abd:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac2:	eb 1a                	jmp    800ade <memcmp+0x41>
  800ac4:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800ac9:	83 c2 01             	add    $0x1,%edx
  800acc:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800ad0:	38 c8                	cmp    %cl,%al
  800ad2:	74 0a                	je     800ade <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800ad4:	0f b6 c0             	movzbl %al,%eax
  800ad7:	0f b6 c9             	movzbl %cl,%ecx
  800ada:	29 c8                	sub    %ecx,%eax
  800adc:	eb 10                	jmp    800aee <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ade:	39 fa                	cmp    %edi,%edx
  800ae0:	75 e2                	jne    800ac4 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ae2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae7:	eb 05                	jmp    800aee <memcmp+0x51>
  800ae9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aee:	5b                   	pop    %ebx
  800aef:	5e                   	pop    %esi
  800af0:	5f                   	pop    %edi
  800af1:	5d                   	pop    %ebp
  800af2:	c3                   	ret    

00800af3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	53                   	push   %ebx
  800af7:	8b 45 08             	mov    0x8(%ebp),%eax
  800afa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800afd:	89 c2                	mov    %eax,%edx
  800aff:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b02:	39 d0                	cmp    %edx,%eax
  800b04:	73 13                	jae    800b19 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b06:	89 d9                	mov    %ebx,%ecx
  800b08:	38 18                	cmp    %bl,(%eax)
  800b0a:	75 06                	jne    800b12 <memfind+0x1f>
  800b0c:	eb 0b                	jmp    800b19 <memfind+0x26>
  800b0e:	38 08                	cmp    %cl,(%eax)
  800b10:	74 07                	je     800b19 <memfind+0x26>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b12:	83 c0 01             	add    $0x1,%eax
  800b15:	39 d0                	cmp    %edx,%eax
  800b17:	75 f5                	jne    800b0e <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b19:	5b                   	pop    %ebx
  800b1a:	5d                   	pop    %ebp
  800b1b:	c3                   	ret    

00800b1c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b1c:	55                   	push   %ebp
  800b1d:	89 e5                	mov    %esp,%ebp
  800b1f:	57                   	push   %edi
  800b20:	56                   	push   %esi
  800b21:	53                   	push   %ebx
  800b22:	83 ec 04             	sub    $0x4,%esp
  800b25:	8b 55 08             	mov    0x8(%ebp),%edx
  800b28:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b2b:	0f b6 02             	movzbl (%edx),%eax
  800b2e:	3c 09                	cmp    $0x9,%al
  800b30:	74 04                	je     800b36 <strtol+0x1a>
  800b32:	3c 20                	cmp    $0x20,%al
  800b34:	75 0e                	jne    800b44 <strtol+0x28>
		s++;
  800b36:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b39:	0f b6 02             	movzbl (%edx),%eax
  800b3c:	3c 09                	cmp    $0x9,%al
  800b3e:	74 f6                	je     800b36 <strtol+0x1a>
  800b40:	3c 20                	cmp    $0x20,%al
  800b42:	74 f2                	je     800b36 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b44:	3c 2b                	cmp    $0x2b,%al
  800b46:	75 0a                	jne    800b52 <strtol+0x36>
		s++;
  800b48:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b4b:	bf 00 00 00 00       	mov    $0x0,%edi
  800b50:	eb 10                	jmp    800b62 <strtol+0x46>
  800b52:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b57:	3c 2d                	cmp    $0x2d,%al
  800b59:	75 07                	jne    800b62 <strtol+0x46>
		s++, neg = 1;
  800b5b:	83 c2 01             	add    $0x1,%edx
  800b5e:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b62:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b68:	75 15                	jne    800b7f <strtol+0x63>
  800b6a:	80 3a 30             	cmpb   $0x30,(%edx)
  800b6d:	75 10                	jne    800b7f <strtol+0x63>
  800b6f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b73:	75 0a                	jne    800b7f <strtol+0x63>
		s += 2, base = 16;
  800b75:	83 c2 02             	add    $0x2,%edx
  800b78:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b7d:	eb 10                	jmp    800b8f <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800b7f:	85 db                	test   %ebx,%ebx
  800b81:	75 0c                	jne    800b8f <strtol+0x73>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b83:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b85:	80 3a 30             	cmpb   $0x30,(%edx)
  800b88:	75 05                	jne    800b8f <strtol+0x73>
		s++, base = 8;
  800b8a:	83 c2 01             	add    $0x1,%edx
  800b8d:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800b8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b94:	89 5d f0             	mov    %ebx,-0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b97:	0f b6 0a             	movzbl (%edx),%ecx
  800b9a:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800b9d:	89 f3                	mov    %esi,%ebx
  800b9f:	80 fb 09             	cmp    $0x9,%bl
  800ba2:	77 08                	ja     800bac <strtol+0x90>
			dig = *s - '0';
  800ba4:	0f be c9             	movsbl %cl,%ecx
  800ba7:	83 e9 30             	sub    $0x30,%ecx
  800baa:	eb 22                	jmp    800bce <strtol+0xb2>
		else if (*s >= 'a' && *s <= 'z')
  800bac:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800baf:	89 f3                	mov    %esi,%ebx
  800bb1:	80 fb 19             	cmp    $0x19,%bl
  800bb4:	77 08                	ja     800bbe <strtol+0xa2>
			dig = *s - 'a' + 10;
  800bb6:	0f be c9             	movsbl %cl,%ecx
  800bb9:	83 e9 57             	sub    $0x57,%ecx
  800bbc:	eb 10                	jmp    800bce <strtol+0xb2>
		else if (*s >= 'A' && *s <= 'Z')
  800bbe:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800bc1:	89 f3                	mov    %esi,%ebx
  800bc3:	80 fb 19             	cmp    $0x19,%bl
  800bc6:	77 16                	ja     800bde <strtol+0xc2>
			dig = *s - 'A' + 10;
  800bc8:	0f be c9             	movsbl %cl,%ecx
  800bcb:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bce:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800bd1:	7d 0f                	jge    800be2 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800bd3:	83 c2 01             	add    $0x1,%edx
  800bd6:	0f af 45 f0          	imul   -0x10(%ebp),%eax
  800bda:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800bdc:	eb b9                	jmp    800b97 <strtol+0x7b>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800bde:	89 c1                	mov    %eax,%ecx
  800be0:	eb 02                	jmp    800be4 <strtol+0xc8>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800be2:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800be4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800be8:	74 05                	je     800bef <strtol+0xd3>
		*endptr = (char *) s;
  800bea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bed:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800bef:	89 ca                	mov    %ecx,%edx
  800bf1:	f7 da                	neg    %edx
  800bf3:	85 ff                	test   %edi,%edi
  800bf5:	0f 45 c2             	cmovne %edx,%eax
}
  800bf8:	83 c4 04             	add    $0x4,%esp
  800bfb:	5b                   	pop    %ebx
  800bfc:	5e                   	pop    %esi
  800bfd:	5f                   	pop    %edi
  800bfe:	5d                   	pop    %ebp
  800bff:	c3                   	ret    

00800c00 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c00:	55                   	push   %ebp
  800c01:	89 e5                	mov    %esp,%ebp
  800c03:	83 ec 0c             	sub    $0xc,%esp
  800c06:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c09:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c0c:	89 7d fc             	mov    %edi,-0x4(%ebp)
static inline uint32_t

get_cpu_features(void)
{
	uint32_t feature;
	__asm __volatile(" movl $1, %%eax\n\t"
  800c0f:	b8 01 00 00 00       	mov    $0x1,%eax
  800c14:	0f a2                	cpuid  
  800c16:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c18:	b8 00 00 00 00       	mov    $0x0,%eax
  800c1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c20:	8b 55 08             	mov    0x8(%ebp),%edx
  800c23:	89 c3                	mov    %eax,%ebx
  800c25:	89 c7                	mov    %eax,%edi
  800c27:	89 c6                	mov    %eax,%esi
  800c29:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c2b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c2e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c31:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c34:	89 ec                	mov    %ebp,%esp
  800c36:	5d                   	pop    %ebp
  800c37:	c3                   	ret    

00800c38 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c38:	55                   	push   %ebp
  800c39:	89 e5                	mov    %esp,%ebp
  800c3b:	83 ec 0c             	sub    $0xc,%esp
  800c3e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c41:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c44:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800c47:	b8 01 00 00 00       	mov    $0x1,%eax
  800c4c:	0f a2                	cpuid  
  800c4e:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c50:	ba 00 00 00 00       	mov    $0x0,%edx
  800c55:	b8 01 00 00 00       	mov    $0x1,%eax
  800c5a:	89 d1                	mov    %edx,%ecx
  800c5c:	89 d3                	mov    %edx,%ebx
  800c5e:	89 d7                	mov    %edx,%edi
  800c60:	89 d6                	mov    %edx,%esi
  800c62:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c64:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c67:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c6a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c6d:	89 ec                	mov    %ebp,%esp
  800c6f:	5d                   	pop    %ebp
  800c70:	c3                   	ret    

00800c71 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c71:	55                   	push   %ebp
  800c72:	89 e5                	mov    %esp,%ebp
  800c74:	83 ec 38             	sub    $0x38,%esp
  800c77:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c7a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c7d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800c80:	b8 01 00 00 00       	mov    $0x1,%eax
  800c85:	0f a2                	cpuid  
  800c87:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c89:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c8e:	b8 03 00 00 00       	mov    $0x3,%eax
  800c93:	8b 55 08             	mov    0x8(%ebp),%edx
  800c96:	89 cb                	mov    %ecx,%ebx
  800c98:	89 cf                	mov    %ecx,%edi
  800c9a:	89 ce                	mov    %ecx,%esi
  800c9c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c9e:	85 c0                	test   %eax,%eax
  800ca0:	7e 28                	jle    800cca <sys_env_destroy+0x59>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ca6:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800cad:	00 
  800cae:	c7 44 24 08 df 1f 80 	movl   $0x801fdf,0x8(%esp)
  800cb5:	00 
  800cb6:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800cbd:	00 
  800cbe:	c7 04 24 fc 1f 80 00 	movl   $0x801ffc,(%esp)
  800cc5:	e8 96 0b 00 00       	call   801860 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cca:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ccd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cd0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cd3:	89 ec                	mov    %ebp,%esp
  800cd5:	5d                   	pop    %ebp
  800cd6:	c3                   	ret    

00800cd7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cd7:	55                   	push   %ebp
  800cd8:	89 e5                	mov    %esp,%ebp
  800cda:	83 ec 0c             	sub    $0xc,%esp
  800cdd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ce0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ce3:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800ce6:	b8 01 00 00 00       	mov    $0x1,%eax
  800ceb:	0f a2                	cpuid  
  800ced:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cef:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf4:	b8 02 00 00 00       	mov    $0x2,%eax
  800cf9:	89 d1                	mov    %edx,%ecx
  800cfb:	89 d3                	mov    %edx,%ebx
  800cfd:	89 d7                	mov    %edx,%edi
  800cff:	89 d6                	mov    %edx,%esi
  800d01:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d03:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d06:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d09:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d0c:	89 ec                	mov    %ebp,%esp
  800d0e:	5d                   	pop    %ebp
  800d0f:	c3                   	ret    

00800d10 <sys_yield>:

void
sys_yield(void)
{
  800d10:	55                   	push   %ebp
  800d11:	89 e5                	mov    %esp,%ebp
  800d13:	83 ec 0c             	sub    $0xc,%esp
  800d16:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d19:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d1c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d1f:	b8 01 00 00 00       	mov    $0x1,%eax
  800d24:	0f a2                	cpuid  
  800d26:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d28:	ba 00 00 00 00       	mov    $0x0,%edx
  800d2d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d32:	89 d1                	mov    %edx,%ecx
  800d34:	89 d3                	mov    %edx,%ebx
  800d36:	89 d7                	mov    %edx,%edi
  800d38:	89 d6                	mov    %edx,%esi
  800d3a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d3c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d3f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d42:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d45:	89 ec                	mov    %ebp,%esp
  800d47:	5d                   	pop    %ebp
  800d48:	c3                   	ret    

00800d49 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d49:	55                   	push   %ebp
  800d4a:	89 e5                	mov    %esp,%ebp
  800d4c:	83 ec 38             	sub    $0x38,%esp
  800d4f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d52:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d55:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d58:	b8 01 00 00 00       	mov    $0x1,%eax
  800d5d:	0f a2                	cpuid  
  800d5f:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d61:	be 00 00 00 00       	mov    $0x0,%esi
  800d66:	b8 04 00 00 00       	mov    $0x4,%eax
  800d6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d71:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d74:	89 f7                	mov    %esi,%edi
  800d76:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d78:	85 c0                	test   %eax,%eax
  800d7a:	7e 28                	jle    800da4 <sys_page_alloc+0x5b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d80:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d87:	00 
  800d88:	c7 44 24 08 df 1f 80 	movl   $0x801fdf,0x8(%esp)
  800d8f:	00 
  800d90:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800d97:	00 
  800d98:	c7 04 24 fc 1f 80 00 	movl   $0x801ffc,(%esp)
  800d9f:	e8 bc 0a 00 00       	call   801860 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800da4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800da7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800daa:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dad:	89 ec                	mov    %ebp,%esp
  800daf:	5d                   	pop    %ebp
  800db0:	c3                   	ret    

00800db1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800db1:	55                   	push   %ebp
  800db2:	89 e5                	mov    %esp,%ebp
  800db4:	83 ec 38             	sub    $0x38,%esp
  800db7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dba:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dbd:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800dc0:	b8 01 00 00 00       	mov    $0x1,%eax
  800dc5:	0f a2                	cpuid  
  800dc7:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc9:	b8 05 00 00 00       	mov    $0x5,%eax
  800dce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd1:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dd7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dda:	8b 75 18             	mov    0x18(%ebp),%esi
  800ddd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ddf:	85 c0                	test   %eax,%eax
  800de1:	7e 28                	jle    800e0b <sys_page_map+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800de7:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800dee:	00 
  800def:	c7 44 24 08 df 1f 80 	movl   $0x801fdf,0x8(%esp)
  800df6:	00 
  800df7:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800dfe:	00 
  800dff:	c7 04 24 fc 1f 80 00 	movl   $0x801ffc,(%esp)
  800e06:	e8 55 0a 00 00       	call   801860 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e0b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e0e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e11:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e14:	89 ec                	mov    %ebp,%esp
  800e16:	5d                   	pop    %ebp
  800e17:	c3                   	ret    

00800e18 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e18:	55                   	push   %ebp
  800e19:	89 e5                	mov    %esp,%ebp
  800e1b:	83 ec 38             	sub    $0x38,%esp
  800e1e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e21:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e24:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e27:	b8 01 00 00 00       	mov    $0x1,%eax
  800e2c:	0f a2                	cpuid  
  800e2e:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e30:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e35:	b8 06 00 00 00       	mov    $0x6,%eax
  800e3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e40:	89 df                	mov    %ebx,%edi
  800e42:	89 de                	mov    %ebx,%esi
  800e44:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e46:	85 c0                	test   %eax,%eax
  800e48:	7e 28                	jle    800e72 <sys_page_unmap+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e4a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e4e:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e55:	00 
  800e56:	c7 44 24 08 df 1f 80 	movl   $0x801fdf,0x8(%esp)
  800e5d:	00 
  800e5e:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800e65:	00 
  800e66:	c7 04 24 fc 1f 80 00 	movl   $0x801ffc,(%esp)
  800e6d:	e8 ee 09 00 00       	call   801860 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e72:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e75:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e78:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e7b:	89 ec                	mov    %ebp,%esp
  800e7d:	5d                   	pop    %ebp
  800e7e:	c3                   	ret    

00800e7f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e7f:	55                   	push   %ebp
  800e80:	89 e5                	mov    %esp,%ebp
  800e82:	83 ec 38             	sub    $0x38,%esp
  800e85:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e88:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e8b:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e8e:	b8 01 00 00 00       	mov    $0x1,%eax
  800e93:	0f a2                	cpuid  
  800e95:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e97:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e9c:	b8 08 00 00 00       	mov    $0x8,%eax
  800ea1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea7:	89 df                	mov    %ebx,%edi
  800ea9:	89 de                	mov    %ebx,%esi
  800eab:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ead:	85 c0                	test   %eax,%eax
  800eaf:	7e 28                	jle    800ed9 <sys_env_set_status+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eb5:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800ebc:	00 
  800ebd:	c7 44 24 08 df 1f 80 	movl   $0x801fdf,0x8(%esp)
  800ec4:	00 
  800ec5:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800ecc:	00 
  800ecd:	c7 04 24 fc 1f 80 00 	movl   $0x801ffc,(%esp)
  800ed4:	e8 87 09 00 00       	call   801860 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ed9:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800edc:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800edf:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ee2:	89 ec                	mov    %ebp,%esp
  800ee4:	5d                   	pop    %ebp
  800ee5:	c3                   	ret    

00800ee6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ee6:	55                   	push   %ebp
  800ee7:	89 e5                	mov    %esp,%ebp
  800ee9:	83 ec 38             	sub    $0x38,%esp
  800eec:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800eef:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ef2:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800ef5:	b8 01 00 00 00       	mov    $0x1,%eax
  800efa:	0f a2                	cpuid  
  800efc:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800efe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f03:	b8 09 00 00 00       	mov    $0x9,%eax
  800f08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f0e:	89 df                	mov    %ebx,%edi
  800f10:	89 de                	mov    %ebx,%esi
  800f12:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f14:	85 c0                	test   %eax,%eax
  800f16:	7e 28                	jle    800f40 <sys_env_set_trapframe+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f18:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f1c:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f23:	00 
  800f24:	c7 44 24 08 df 1f 80 	movl   $0x801fdf,0x8(%esp)
  800f2b:	00 
  800f2c:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800f33:	00 
  800f34:	c7 04 24 fc 1f 80 00 	movl   $0x801ffc,(%esp)
  800f3b:	e8 20 09 00 00       	call   801860 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f40:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f43:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f46:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f49:	89 ec                	mov    %ebp,%esp
  800f4b:	5d                   	pop    %ebp
  800f4c:	c3                   	ret    

00800f4d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f4d:	55                   	push   %ebp
  800f4e:	89 e5                	mov    %esp,%ebp
  800f50:	83 ec 38             	sub    $0x38,%esp
  800f53:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f56:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f59:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800f5c:	b8 01 00 00 00       	mov    $0x1,%eax
  800f61:	0f a2                	cpuid  
  800f63:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f65:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f6a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f72:	8b 55 08             	mov    0x8(%ebp),%edx
  800f75:	89 df                	mov    %ebx,%edi
  800f77:	89 de                	mov    %ebx,%esi
  800f79:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f7b:	85 c0                	test   %eax,%eax
  800f7d:	7e 28                	jle    800fa7 <sys_env_set_pgfault_upcall+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f7f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f83:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800f8a:	00 
  800f8b:	c7 44 24 08 df 1f 80 	movl   $0x801fdf,0x8(%esp)
  800f92:	00 
  800f93:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800f9a:	00 
  800f9b:	c7 04 24 fc 1f 80 00 	movl   $0x801ffc,(%esp)
  800fa2:	e8 b9 08 00 00       	call   801860 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800fa7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800faa:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fad:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fb0:	89 ec                	mov    %ebp,%esp
  800fb2:	5d                   	pop    %ebp
  800fb3:	c3                   	ret    

00800fb4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fb4:	55                   	push   %ebp
  800fb5:	89 e5                	mov    %esp,%ebp
  800fb7:	83 ec 0c             	sub    $0xc,%esp
  800fba:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fbd:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fc0:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800fc3:	b8 01 00 00 00       	mov    $0x1,%eax
  800fc8:	0f a2                	cpuid  
  800fca:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fcc:	be 00 00 00 00       	mov    $0x0,%esi
  800fd1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800fdc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fdf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fe2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800fe4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fe7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fea:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fed:	89 ec                	mov    %ebp,%esp
  800fef:	5d                   	pop    %ebp
  800ff0:	c3                   	ret    

00800ff1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ff1:	55                   	push   %ebp
  800ff2:	89 e5                	mov    %esp,%ebp
  800ff4:	83 ec 38             	sub    $0x38,%esp
  800ff7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ffa:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ffd:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801000:	b8 01 00 00 00       	mov    $0x1,%eax
  801005:	0f a2                	cpuid  
  801007:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801009:	b9 00 00 00 00       	mov    $0x0,%ecx
  80100e:	b8 0d 00 00 00       	mov    $0xd,%eax
  801013:	8b 55 08             	mov    0x8(%ebp),%edx
  801016:	89 cb                	mov    %ecx,%ebx
  801018:	89 cf                	mov    %ecx,%edi
  80101a:	89 ce                	mov    %ecx,%esi
  80101c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80101e:	85 c0                	test   %eax,%eax
  801020:	7e 28                	jle    80104a <sys_ipc_recv+0x59>
		panic("syscall %d returned %d (> 0)", num, ret);
  801022:	89 44 24 10          	mov    %eax,0x10(%esp)
  801026:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  80102d:	00 
  80102e:	c7 44 24 08 df 1f 80 	movl   $0x801fdf,0x8(%esp)
  801035:	00 
  801036:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  80103d:	00 
  80103e:	c7 04 24 fc 1f 80 00 	movl   $0x801ffc,(%esp)
  801045:	e8 16 08 00 00       	call   801860 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80104a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80104d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801050:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801053:	89 ec                	mov    %ebp,%esp
  801055:	5d                   	pop    %ebp
  801056:	c3                   	ret    
  801057:	66 90                	xchg   %ax,%ax
  801059:	66 90                	xchg   %ax,%ax
  80105b:	66 90                	xchg   %ax,%ax
  80105d:	66 90                	xchg   %ax,%ax
  80105f:	90                   	nop

00801060 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801060:	55                   	push   %ebp
  801061:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801063:	8b 45 08             	mov    0x8(%ebp),%eax
  801066:	05 00 00 00 30       	add    $0x30000000,%eax
  80106b:	c1 e8 0c             	shr    $0xc,%eax
}
  80106e:	5d                   	pop    %ebp
  80106f:	c3                   	ret    

00801070 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801070:	55                   	push   %ebp
  801071:	89 e5                	mov    %esp,%ebp
  801073:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801076:	8b 45 08             	mov    0x8(%ebp),%eax
  801079:	89 04 24             	mov    %eax,(%esp)
  80107c:	e8 df ff ff ff       	call   801060 <fd2num>
  801081:	c1 e0 0c             	shl    $0xc,%eax
  801084:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801089:	c9                   	leave  
  80108a:	c3                   	ret    

0080108b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80108b:	55                   	push   %ebp
  80108c:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  80108e:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801093:	a8 01                	test   $0x1,%al
  801095:	74 34                	je     8010cb <fd_alloc+0x40>
  801097:	a1 00 00 74 ef       	mov    0xef740000,%eax
  80109c:	a8 01                	test   $0x1,%al
  80109e:	74 32                	je     8010d2 <fd_alloc+0x47>
  8010a0:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8010a5:	89 c1                	mov    %eax,%ecx
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8010a7:	89 c2                	mov    %eax,%edx
  8010a9:	c1 ea 16             	shr    $0x16,%edx
  8010ac:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010b3:	f6 c2 01             	test   $0x1,%dl
  8010b6:	74 1f                	je     8010d7 <fd_alloc+0x4c>
  8010b8:	89 c2                	mov    %eax,%edx
  8010ba:	c1 ea 0c             	shr    $0xc,%edx
  8010bd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010c4:	f6 c2 01             	test   $0x1,%dl
  8010c7:	75 1a                	jne    8010e3 <fd_alloc+0x58>
  8010c9:	eb 0c                	jmp    8010d7 <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8010cb:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8010d0:	eb 05                	jmp    8010d7 <fd_alloc+0x4c>
  8010d2:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8010d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8010da:	89 08                	mov    %ecx,(%eax)
			return 0;
  8010dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8010e1:	eb 1a                	jmp    8010fd <fd_alloc+0x72>
  8010e3:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010e8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010ed:	75 b6                	jne    8010a5 <fd_alloc+0x1a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  8010f8:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010fd:	5d                   	pop    %ebp
  8010fe:	c3                   	ret    

008010ff <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010ff:	55                   	push   %ebp
  801100:	89 e5                	mov    %esp,%ebp
  801102:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801105:	83 f8 1f             	cmp    $0x1f,%eax
  801108:	77 36                	ja     801140 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80110a:	c1 e0 0c             	shl    $0xc,%eax
  80110d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801112:	89 c2                	mov    %eax,%edx
  801114:	c1 ea 16             	shr    $0x16,%edx
  801117:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80111e:	f6 c2 01             	test   $0x1,%dl
  801121:	74 24                	je     801147 <fd_lookup+0x48>
  801123:	89 c2                	mov    %eax,%edx
  801125:	c1 ea 0c             	shr    $0xc,%edx
  801128:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80112f:	f6 c2 01             	test   $0x1,%dl
  801132:	74 1a                	je     80114e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801134:	8b 55 0c             	mov    0xc(%ebp),%edx
  801137:	89 02                	mov    %eax,(%edx)
	return 0;
  801139:	b8 00 00 00 00       	mov    $0x0,%eax
  80113e:	eb 13                	jmp    801153 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  801140:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801145:	eb 0c                	jmp    801153 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  801147:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80114c:	eb 05                	jmp    801153 <fd_lookup+0x54>
  80114e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801153:	5d                   	pop    %ebp
  801154:	c3                   	ret    

00801155 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801155:	55                   	push   %ebp
  801156:	89 e5                	mov    %esp,%ebp
  801158:	83 ec 18             	sub    $0x18,%esp
  80115b:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80115e:	39 05 04 30 80 00    	cmp    %eax,0x803004
  801164:	75 10                	jne    801176 <dev_lookup+0x21>
			*dev = devtab[i];
  801166:	8b 45 0c             	mov    0xc(%ebp),%eax
  801169:	c7 00 04 30 80 00    	movl   $0x803004,(%eax)
			return 0;
  80116f:	b8 00 00 00 00       	mov    $0x0,%eax
  801174:	eb 2b                	jmp    8011a1 <dev_lookup+0x4c>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801176:	8b 15 08 40 80 00    	mov    0x804008,%edx
  80117c:	8b 52 48             	mov    0x48(%edx),%edx
  80117f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801183:	89 54 24 04          	mov    %edx,0x4(%esp)
  801187:	c7 04 24 0c 20 80 00 	movl   $0x80200c,(%esp)
  80118e:	e8 e4 ef ff ff       	call   800177 <cprintf>
	*dev = 0;
  801193:	8b 55 0c             	mov    0xc(%ebp),%edx
  801196:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	return -E_INVAL;
  80119c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011a1:	c9                   	leave  
  8011a2:	c3                   	ret    

008011a3 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011a3:	55                   	push   %ebp
  8011a4:	89 e5                	mov    %esp,%ebp
  8011a6:	83 ec 38             	sub    $0x38,%esp
  8011a9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8011ac:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8011af:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8011b2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011b5:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011b8:	89 3c 24             	mov    %edi,(%esp)
  8011bb:	e8 a0 fe ff ff       	call   801060 <fd2num>
  8011c0:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8011c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8011c7:	89 04 24             	mov    %eax,(%esp)
  8011ca:	e8 30 ff ff ff       	call   8010ff <fd_lookup>
  8011cf:	89 c3                	mov    %eax,%ebx
  8011d1:	85 c0                	test   %eax,%eax
  8011d3:	78 05                	js     8011da <fd_close+0x37>
	    || fd != fd2)
  8011d5:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  8011d8:	74 0c                	je     8011e6 <fd_close+0x43>
		return (must_exist ? r : 0);
  8011da:	85 f6                	test   %esi,%esi
  8011dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8011e1:	0f 44 d8             	cmove  %eax,%ebx
  8011e4:	eb 3d                	jmp    801223 <fd_close+0x80>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011e6:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8011e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011ed:	8b 07                	mov    (%edi),%eax
  8011ef:	89 04 24             	mov    %eax,(%esp)
  8011f2:	e8 5e ff ff ff       	call   801155 <dev_lookup>
  8011f7:	89 c3                	mov    %eax,%ebx
  8011f9:	85 c0                	test   %eax,%eax
  8011fb:	78 16                	js     801213 <fd_close+0x70>
		if (dev->dev_close)
  8011fd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801200:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801203:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801208:	85 c0                	test   %eax,%eax
  80120a:	74 07                	je     801213 <fd_close+0x70>
			r = (*dev->dev_close)(fd);
  80120c:	89 3c 24             	mov    %edi,(%esp)
  80120f:	ff d0                	call   *%eax
  801211:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801213:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801217:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80121e:	e8 f5 fb ff ff       	call   800e18 <sys_page_unmap>
	return r;
}
  801223:	89 d8                	mov    %ebx,%eax
  801225:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801228:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80122b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80122e:	89 ec                	mov    %ebp,%esp
  801230:	5d                   	pop    %ebp
  801231:	c3                   	ret    

00801232 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801232:	55                   	push   %ebp
  801233:	89 e5                	mov    %esp,%ebp
  801235:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801238:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80123b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80123f:	8b 45 08             	mov    0x8(%ebp),%eax
  801242:	89 04 24             	mov    %eax,(%esp)
  801245:	e8 b5 fe ff ff       	call   8010ff <fd_lookup>
  80124a:	85 c0                	test   %eax,%eax
  80124c:	78 13                	js     801261 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80124e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801255:	00 
  801256:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801259:	89 04 24             	mov    %eax,(%esp)
  80125c:	e8 42 ff ff ff       	call   8011a3 <fd_close>
}
  801261:	c9                   	leave  
  801262:	c3                   	ret    

00801263 <close_all>:

void
close_all(void)
{
  801263:	55                   	push   %ebp
  801264:	89 e5                	mov    %esp,%ebp
  801266:	53                   	push   %ebx
  801267:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80126a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80126f:	89 1c 24             	mov    %ebx,(%esp)
  801272:	e8 bb ff ff ff       	call   801232 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801277:	83 c3 01             	add    $0x1,%ebx
  80127a:	83 fb 20             	cmp    $0x20,%ebx
  80127d:	75 f0                	jne    80126f <close_all+0xc>
		close(i);
}
  80127f:	83 c4 14             	add    $0x14,%esp
  801282:	5b                   	pop    %ebx
  801283:	5d                   	pop    %ebp
  801284:	c3                   	ret    

00801285 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801285:	55                   	push   %ebp
  801286:	89 e5                	mov    %esp,%ebp
  801288:	83 ec 58             	sub    $0x58,%esp
  80128b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80128e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801291:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801294:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801297:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80129a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80129e:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a1:	89 04 24             	mov    %eax,(%esp)
  8012a4:	e8 56 fe ff ff       	call   8010ff <fd_lookup>
  8012a9:	85 c0                	test   %eax,%eax
  8012ab:	0f 88 e3 00 00 00    	js     801394 <dup+0x10f>
		return r;
	close(newfdnum);
  8012b1:	89 1c 24             	mov    %ebx,(%esp)
  8012b4:	e8 79 ff ff ff       	call   801232 <close>

	newfd = INDEX2FD(newfdnum);
  8012b9:	89 de                	mov    %ebx,%esi
  8012bb:	c1 e6 0c             	shl    $0xc,%esi
  8012be:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8012c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012c7:	89 04 24             	mov    %eax,(%esp)
  8012ca:	e8 a1 fd ff ff       	call   801070 <fd2data>
  8012cf:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8012d1:	89 34 24             	mov    %esi,(%esp)
  8012d4:	e8 97 fd ff ff       	call   801070 <fd2data>
  8012d9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  8012dc:	89 f8                	mov    %edi,%eax
  8012de:	c1 e8 16             	shr    $0x16,%eax
  8012e1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012e8:	a8 01                	test   $0x1,%al
  8012ea:	74 46                	je     801332 <dup+0xad>
  8012ec:	89 f8                	mov    %edi,%eax
  8012ee:	c1 e8 0c             	shr    $0xc,%eax
  8012f1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012f8:	f6 c2 01             	test   $0x1,%dl
  8012fb:	74 35                	je     801332 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012fd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801304:	25 07 0e 00 00       	and    $0xe07,%eax
  801309:	89 44 24 10          	mov    %eax,0x10(%esp)
  80130d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801310:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801314:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80131b:	00 
  80131c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801320:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801327:	e8 85 fa ff ff       	call   800db1 <sys_page_map>
  80132c:	89 c7                	mov    %eax,%edi
  80132e:	85 c0                	test   %eax,%eax
  801330:	78 3b                	js     80136d <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801332:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801335:	89 c2                	mov    %eax,%edx
  801337:	c1 ea 0c             	shr    $0xc,%edx
  80133a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801341:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801347:	89 54 24 10          	mov    %edx,0x10(%esp)
  80134b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80134f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801356:	00 
  801357:	89 44 24 04          	mov    %eax,0x4(%esp)
  80135b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801362:	e8 4a fa ff ff       	call   800db1 <sys_page_map>
  801367:	89 c7                	mov    %eax,%edi
  801369:	85 c0                	test   %eax,%eax
  80136b:	79 29                	jns    801396 <dup+0x111>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80136d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801371:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801378:	e8 9b fa ff ff       	call   800e18 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80137d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801380:	89 44 24 04          	mov    %eax,0x4(%esp)
  801384:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80138b:	e8 88 fa ff ff       	call   800e18 <sys_page_unmap>
	return r;
  801390:	89 fb                	mov    %edi,%ebx
  801392:	eb 02                	jmp    801396 <dup+0x111>
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
		return r;
  801394:	89 c3                	mov    %eax,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801396:	89 d8                	mov    %ebx,%eax
  801398:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80139b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80139e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8013a1:	89 ec                	mov    %ebp,%esp
  8013a3:	5d                   	pop    %ebp
  8013a4:	c3                   	ret    

008013a5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013a5:	55                   	push   %ebp
  8013a6:	89 e5                	mov    %esp,%ebp
  8013a8:	53                   	push   %ebx
  8013a9:	83 ec 24             	sub    $0x24,%esp
  8013ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013af:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b6:	89 1c 24             	mov    %ebx,(%esp)
  8013b9:	e8 41 fd ff ff       	call   8010ff <fd_lookup>
  8013be:	85 c0                	test   %eax,%eax
  8013c0:	78 6d                	js     80142f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013cc:	8b 00                	mov    (%eax),%eax
  8013ce:	89 04 24             	mov    %eax,(%esp)
  8013d1:	e8 7f fd ff ff       	call   801155 <dev_lookup>
  8013d6:	85 c0                	test   %eax,%eax
  8013d8:	78 55                	js     80142f <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013dd:	8b 50 08             	mov    0x8(%eax),%edx
  8013e0:	83 e2 03             	and    $0x3,%edx
  8013e3:	83 fa 01             	cmp    $0x1,%edx
  8013e6:	75 23                	jne    80140b <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013e8:	a1 08 40 80 00       	mov    0x804008,%eax
  8013ed:	8b 40 48             	mov    0x48(%eax),%eax
  8013f0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013f8:	c7 04 24 4d 20 80 00 	movl   $0x80204d,(%esp)
  8013ff:	e8 73 ed ff ff       	call   800177 <cprintf>
		return -E_INVAL;
  801404:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801409:	eb 24                	jmp    80142f <read+0x8a>
	}
	if (!dev->dev_read)
  80140b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80140e:	8b 52 08             	mov    0x8(%edx),%edx
  801411:	85 d2                	test   %edx,%edx
  801413:	74 15                	je     80142a <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801415:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801418:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80141c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80141f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801423:	89 04 24             	mov    %eax,(%esp)
  801426:	ff d2                	call   *%edx
  801428:	eb 05                	jmp    80142f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80142a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80142f:	83 c4 24             	add    $0x24,%esp
  801432:	5b                   	pop    %ebx
  801433:	5d                   	pop    %ebp
  801434:	c3                   	ret    

00801435 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801435:	55                   	push   %ebp
  801436:	89 e5                	mov    %esp,%ebp
  801438:	57                   	push   %edi
  801439:	56                   	push   %esi
  80143a:	53                   	push   %ebx
  80143b:	83 ec 1c             	sub    $0x1c,%esp
  80143e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801441:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801444:	85 f6                	test   %esi,%esi
  801446:	74 33                	je     80147b <readn+0x46>
  801448:	b8 00 00 00 00       	mov    $0x0,%eax
  80144d:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801452:	89 f2                	mov    %esi,%edx
  801454:	29 c2                	sub    %eax,%edx
  801456:	89 54 24 08          	mov    %edx,0x8(%esp)
  80145a:	03 45 0c             	add    0xc(%ebp),%eax
  80145d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801461:	89 3c 24             	mov    %edi,(%esp)
  801464:	e8 3c ff ff ff       	call   8013a5 <read>
		if (m < 0)
  801469:	85 c0                	test   %eax,%eax
  80146b:	78 17                	js     801484 <readn+0x4f>
			return m;
		if (m == 0)
  80146d:	85 c0                	test   %eax,%eax
  80146f:	74 11                	je     801482 <readn+0x4d>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801471:	01 c3                	add    %eax,%ebx
  801473:	89 d8                	mov    %ebx,%eax
  801475:	39 f3                	cmp    %esi,%ebx
  801477:	72 d9                	jb     801452 <readn+0x1d>
  801479:	eb 09                	jmp    801484 <readn+0x4f>
  80147b:	b8 00 00 00 00       	mov    $0x0,%eax
  801480:	eb 02                	jmp    801484 <readn+0x4f>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801482:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801484:	83 c4 1c             	add    $0x1c,%esp
  801487:	5b                   	pop    %ebx
  801488:	5e                   	pop    %esi
  801489:	5f                   	pop    %edi
  80148a:	5d                   	pop    %ebp
  80148b:	c3                   	ret    

0080148c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80148c:	55                   	push   %ebp
  80148d:	89 e5                	mov    %esp,%ebp
  80148f:	53                   	push   %ebx
  801490:	83 ec 24             	sub    $0x24,%esp
  801493:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801496:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801499:	89 44 24 04          	mov    %eax,0x4(%esp)
  80149d:	89 1c 24             	mov    %ebx,(%esp)
  8014a0:	e8 5a fc ff ff       	call   8010ff <fd_lookup>
  8014a5:	85 c0                	test   %eax,%eax
  8014a7:	78 68                	js     801511 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014b3:	8b 00                	mov    (%eax),%eax
  8014b5:	89 04 24             	mov    %eax,(%esp)
  8014b8:	e8 98 fc ff ff       	call   801155 <dev_lookup>
  8014bd:	85 c0                	test   %eax,%eax
  8014bf:	78 50                	js     801511 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014c4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014c8:	75 23                	jne    8014ed <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014ca:	a1 08 40 80 00       	mov    0x804008,%eax
  8014cf:	8b 40 48             	mov    0x48(%eax),%eax
  8014d2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014da:	c7 04 24 69 20 80 00 	movl   $0x802069,(%esp)
  8014e1:	e8 91 ec ff ff       	call   800177 <cprintf>
		return -E_INVAL;
  8014e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014eb:	eb 24                	jmp    801511 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014f0:	8b 52 0c             	mov    0xc(%edx),%edx
  8014f3:	85 d2                	test   %edx,%edx
  8014f5:	74 15                	je     80150c <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014f7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8014fa:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801501:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801505:	89 04 24             	mov    %eax,(%esp)
  801508:	ff d2                	call   *%edx
  80150a:	eb 05                	jmp    801511 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80150c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801511:	83 c4 24             	add    $0x24,%esp
  801514:	5b                   	pop    %ebx
  801515:	5d                   	pop    %ebp
  801516:	c3                   	ret    

00801517 <seek>:

int
seek(int fdnum, off_t offset)
{
  801517:	55                   	push   %ebp
  801518:	89 e5                	mov    %esp,%ebp
  80151a:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80151d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801520:	89 44 24 04          	mov    %eax,0x4(%esp)
  801524:	8b 45 08             	mov    0x8(%ebp),%eax
  801527:	89 04 24             	mov    %eax,(%esp)
  80152a:	e8 d0 fb ff ff       	call   8010ff <fd_lookup>
  80152f:	85 c0                	test   %eax,%eax
  801531:	78 0e                	js     801541 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801533:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801536:	8b 55 0c             	mov    0xc(%ebp),%edx
  801539:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80153c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801541:	c9                   	leave  
  801542:	c3                   	ret    

00801543 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801543:	55                   	push   %ebp
  801544:	89 e5                	mov    %esp,%ebp
  801546:	53                   	push   %ebx
  801547:	83 ec 24             	sub    $0x24,%esp
  80154a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80154d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801550:	89 44 24 04          	mov    %eax,0x4(%esp)
  801554:	89 1c 24             	mov    %ebx,(%esp)
  801557:	e8 a3 fb ff ff       	call   8010ff <fd_lookup>
  80155c:	85 c0                	test   %eax,%eax
  80155e:	78 61                	js     8015c1 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801560:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801563:	89 44 24 04          	mov    %eax,0x4(%esp)
  801567:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80156a:	8b 00                	mov    (%eax),%eax
  80156c:	89 04 24             	mov    %eax,(%esp)
  80156f:	e8 e1 fb ff ff       	call   801155 <dev_lookup>
  801574:	85 c0                	test   %eax,%eax
  801576:	78 49                	js     8015c1 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801578:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80157b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80157f:	75 23                	jne    8015a4 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801581:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801586:	8b 40 48             	mov    0x48(%eax),%eax
  801589:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80158d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801591:	c7 04 24 2c 20 80 00 	movl   $0x80202c,(%esp)
  801598:	e8 da eb ff ff       	call   800177 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80159d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015a2:	eb 1d                	jmp    8015c1 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8015a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015a7:	8b 52 18             	mov    0x18(%edx),%edx
  8015aa:	85 d2                	test   %edx,%edx
  8015ac:	74 0e                	je     8015bc <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015b1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8015b5:	89 04 24             	mov    %eax,(%esp)
  8015b8:	ff d2                	call   *%edx
  8015ba:	eb 05                	jmp    8015c1 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015bc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8015c1:	83 c4 24             	add    $0x24,%esp
  8015c4:	5b                   	pop    %ebx
  8015c5:	5d                   	pop    %ebp
  8015c6:	c3                   	ret    

008015c7 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015c7:	55                   	push   %ebp
  8015c8:	89 e5                	mov    %esp,%ebp
  8015ca:	53                   	push   %ebx
  8015cb:	83 ec 24             	sub    $0x24,%esp
  8015ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015d1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8015db:	89 04 24             	mov    %eax,(%esp)
  8015de:	e8 1c fb ff ff       	call   8010ff <fd_lookup>
  8015e3:	85 c0                	test   %eax,%eax
  8015e5:	78 52                	js     801639 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f1:	8b 00                	mov    (%eax),%eax
  8015f3:	89 04 24             	mov    %eax,(%esp)
  8015f6:	e8 5a fb ff ff       	call   801155 <dev_lookup>
  8015fb:	85 c0                	test   %eax,%eax
  8015fd:	78 3a                	js     801639 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8015ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801602:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801606:	74 2c                	je     801634 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801608:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80160b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801612:	00 00 00 
	stat->st_isdir = 0;
  801615:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80161c:	00 00 00 
	stat->st_dev = dev;
  80161f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801625:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801629:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80162c:	89 14 24             	mov    %edx,(%esp)
  80162f:	ff 50 14             	call   *0x14(%eax)
  801632:	eb 05                	jmp    801639 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801634:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801639:	83 c4 24             	add    $0x24,%esp
  80163c:	5b                   	pop    %ebx
  80163d:	5d                   	pop    %ebp
  80163e:	c3                   	ret    

0080163f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80163f:	55                   	push   %ebp
  801640:	89 e5                	mov    %esp,%ebp
  801642:	83 ec 18             	sub    $0x18,%esp
  801645:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801648:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80164b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801652:	00 
  801653:	8b 45 08             	mov    0x8(%ebp),%eax
  801656:	89 04 24             	mov    %eax,(%esp)
  801659:	e8 84 01 00 00       	call   8017e2 <open>
  80165e:	89 c3                	mov    %eax,%ebx
  801660:	85 c0                	test   %eax,%eax
  801662:	78 1b                	js     80167f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801664:	8b 45 0c             	mov    0xc(%ebp),%eax
  801667:	89 44 24 04          	mov    %eax,0x4(%esp)
  80166b:	89 1c 24             	mov    %ebx,(%esp)
  80166e:	e8 54 ff ff ff       	call   8015c7 <fstat>
  801673:	89 c6                	mov    %eax,%esi
	close(fd);
  801675:	89 1c 24             	mov    %ebx,(%esp)
  801678:	e8 b5 fb ff ff       	call   801232 <close>
	return r;
  80167d:	89 f3                	mov    %esi,%ebx
}
  80167f:	89 d8                	mov    %ebx,%eax
  801681:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801684:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801687:	89 ec                	mov    %ebp,%esp
  801689:	5d                   	pop    %ebp
  80168a:	c3                   	ret    
  80168b:	90                   	nop

0080168c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80168c:	55                   	push   %ebp
  80168d:	89 e5                	mov    %esp,%ebp
  80168f:	83 ec 18             	sub    $0x18,%esp
  801692:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801695:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801698:	89 c6                	mov    %eax,%esi
  80169a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80169c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016a3:	75 11                	jne    8016b6 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016a5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8016ac:	e8 ca 02 00 00       	call   80197b <ipc_find_env>
  8016b1:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016b6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8016bd:	00 
  8016be:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8016c5:	00 
  8016c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016ca:	a1 00 40 80 00       	mov    0x804000,%eax
  8016cf:	89 04 24             	mov    %eax,(%esp)
  8016d2:	e8 39 02 00 00       	call   801910 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016d7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016de:	00 
  8016df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016ea:	e8 c9 01 00 00       	call   8018b8 <ipc_recv>
}
  8016ef:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8016f2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8016f5:	89 ec                	mov    %ebp,%esp
  8016f7:	5d                   	pop    %ebp
  8016f8:	c3                   	ret    

008016f9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016f9:	55                   	push   %ebp
  8016fa:	89 e5                	mov    %esp,%ebp
  8016fc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801702:	8b 40 0c             	mov    0xc(%eax),%eax
  801705:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80170a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80170d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801712:	ba 00 00 00 00       	mov    $0x0,%edx
  801717:	b8 02 00 00 00       	mov    $0x2,%eax
  80171c:	e8 6b ff ff ff       	call   80168c <fsipc>
}
  801721:	c9                   	leave  
  801722:	c3                   	ret    

00801723 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801723:	55                   	push   %ebp
  801724:	89 e5                	mov    %esp,%ebp
  801726:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801729:	8b 45 08             	mov    0x8(%ebp),%eax
  80172c:	8b 40 0c             	mov    0xc(%eax),%eax
  80172f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801734:	ba 00 00 00 00       	mov    $0x0,%edx
  801739:	b8 06 00 00 00       	mov    $0x6,%eax
  80173e:	e8 49 ff ff ff       	call   80168c <fsipc>
}
  801743:	c9                   	leave  
  801744:	c3                   	ret    

00801745 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801745:	55                   	push   %ebp
  801746:	89 e5                	mov    %esp,%ebp
  801748:	53                   	push   %ebx
  801749:	83 ec 14             	sub    $0x14,%esp
  80174c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80174f:	8b 45 08             	mov    0x8(%ebp),%eax
  801752:	8b 40 0c             	mov    0xc(%eax),%eax
  801755:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80175a:	ba 00 00 00 00       	mov    $0x0,%edx
  80175f:	b8 05 00 00 00       	mov    $0x5,%eax
  801764:	e8 23 ff ff ff       	call   80168c <fsipc>
  801769:	85 c0                	test   %eax,%eax
  80176b:	78 2b                	js     801798 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80176d:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801774:	00 
  801775:	89 1c 24             	mov    %ebx,(%esp)
  801778:	e8 7e f0 ff ff       	call   8007fb <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80177d:	a1 80 50 80 00       	mov    0x805080,%eax
  801782:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801788:	a1 84 50 80 00       	mov    0x805084,%eax
  80178d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801793:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801798:	83 c4 14             	add    $0x14,%esp
  80179b:	5b                   	pop    %ebx
  80179c:	5d                   	pop    %ebp
  80179d:	c3                   	ret    

0080179e <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80179e:	55                   	push   %ebp
  80179f:	89 e5                	mov    %esp,%ebp
  8017a1:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8017a4:	c7 44 24 08 86 20 80 	movl   $0x802086,0x8(%esp)
  8017ab:	00 
  8017ac:	c7 44 24 04 77 00 00 	movl   $0x77,0x4(%esp)
  8017b3:	00 
  8017b4:	c7 04 24 a4 20 80 00 	movl   $0x8020a4,(%esp)
  8017bb:	e8 a0 00 00 00       	call   801860 <_panic>

008017c0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017c0:	55                   	push   %ebp
  8017c1:	89 e5                	mov    %esp,%ebp
  8017c3:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_READ request to the file system server after
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
	panic("devfile_read not implemented");
  8017c6:	c7 44 24 08 af 20 80 	movl   $0x8020af,0x8(%esp)
  8017cd:	00 
  8017ce:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
  8017d5:	00 
  8017d6:	c7 04 24 a4 20 80 00 	movl   $0x8020a4,(%esp)
  8017dd:	e8 7e 00 00 00       	call   801860 <_panic>

008017e2 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017e2:	55                   	push   %ebp
  8017e3:	89 e5                	mov    %esp,%ebp
  8017e5:	83 ec 18             	sub    $0x18,%esp
	// Return the file descriptor index.
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
	panic("open not implemented");
  8017e8:	c7 44 24 08 cc 20 80 	movl   $0x8020cc,0x8(%esp)
  8017ef:	00 
  8017f0:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  8017f7:	00 
  8017f8:	c7 04 24 a4 20 80 00 	movl   $0x8020a4,(%esp)
  8017ff:	e8 5c 00 00 00       	call   801860 <_panic>

00801804 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801804:	55                   	push   %ebp
  801805:	89 e5                	mov    %esp,%ebp
  801807:	53                   	push   %ebx
  801808:	83 ec 14             	sub    $0x14,%esp
  80180b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  80180e:	89 1c 24             	mov    %ebx,(%esp)
  801811:	e8 8a ef ff ff       	call   8007a0 <strlen>
  801816:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80181b:	7f 21                	jg     80183e <remove+0x3a>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  80181d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801821:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801828:	e8 ce ef ff ff       	call   8007fb <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  80182d:	ba 00 00 00 00       	mov    $0x0,%edx
  801832:	b8 07 00 00 00       	mov    $0x7,%eax
  801837:	e8 50 fe ff ff       	call   80168c <fsipc>
  80183c:	eb 05                	jmp    801843 <remove+0x3f>
// Delete a file
int
remove(const char *path)
{
	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80183e:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
	strcpy(fsipcbuf.remove.req_path, path);
	return fsipc(FSREQ_REMOVE, NULL);
}
  801843:	83 c4 14             	add    $0x14,%esp
  801846:	5b                   	pop    %ebx
  801847:	5d                   	pop    %ebp
  801848:	c3                   	ret    

00801849 <sync>:

// Synchronize disk with buffer cache
int
sync(void)
{
  801849:	55                   	push   %ebp
  80184a:	89 e5                	mov    %esp,%ebp
  80184c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80184f:	ba 00 00 00 00       	mov    $0x0,%edx
  801854:	b8 08 00 00 00       	mov    $0x8,%eax
  801859:	e8 2e fe ff ff       	call   80168c <fsipc>
}
  80185e:	c9                   	leave  
  80185f:	c3                   	ret    

00801860 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801860:	55                   	push   %ebp
  801861:	89 e5                	mov    %esp,%ebp
  801863:	56                   	push   %esi
  801864:	53                   	push   %ebx
  801865:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801868:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80186b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801871:	e8 61 f4 ff ff       	call   800cd7 <sys_getenvid>
  801876:	8b 55 0c             	mov    0xc(%ebp),%edx
  801879:	89 54 24 10          	mov    %edx,0x10(%esp)
  80187d:	8b 55 08             	mov    0x8(%ebp),%edx
  801880:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801884:	89 74 24 08          	mov    %esi,0x8(%esp)
  801888:	89 44 24 04          	mov    %eax,0x4(%esp)
  80188c:	c7 04 24 e4 20 80 00 	movl   $0x8020e4,(%esp)
  801893:	e8 df e8 ff ff       	call   800177 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801898:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80189c:	8b 45 10             	mov    0x10(%ebp),%eax
  80189f:	89 04 24             	mov    %eax,(%esp)
  8018a2:	e8 6f e8 ff ff       	call   800116 <vcprintf>
	cprintf("\n");
  8018a7:	c7 04 24 cc 1c 80 00 	movl   $0x801ccc,(%esp)
  8018ae:	e8 c4 e8 ff ff       	call   800177 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8018b3:	cc                   	int3   
  8018b4:	eb fd                	jmp    8018b3 <_panic+0x53>
  8018b6:	66 90                	xchg   %ax,%ax

008018b8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8018b8:	55                   	push   %ebp
  8018b9:	89 e5                	mov    %esp,%ebp
  8018bb:	56                   	push   %esi
  8018bc:	53                   	push   %ebx
  8018bd:	83 ec 10             	sub    $0x10,%esp
  8018c0:	8b 75 08             	mov    0x8(%ebp),%esi
  8018c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	// 	return thisenv->env_ipc_value;
	// }
	int r;
	if(pg == NULL)
		pg = (void *)~0x0;
  8018c6:	85 db                	test   %ebx,%ebx
  8018c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8018cd:	0f 44 d8             	cmove  %eax,%ebx
	//else
	if((r = sys_ipc_recv(pg)) < 0)
  8018d0:	89 1c 24             	mov    %ebx,(%esp)
  8018d3:	e8 19 f7 ff ff       	call   800ff1 <sys_ipc_recv>
  8018d8:	85 c0                	test   %eax,%eax
  8018da:	78 2d                	js     801909 <ipc_recv+0x51>
		return r;
	//volatile struct Env *curenv = (struct Env*)envs+ENVX(sys_getenvid());

	if(from_env_store)
  8018dc:	85 f6                	test   %esi,%esi
  8018de:	74 0a                	je     8018ea <ipc_recv+0x32>
		*from_env_store = thisenv -> env_ipc_from;
  8018e0:	a1 08 40 80 00       	mov    0x804008,%eax
  8018e5:	8b 40 74             	mov    0x74(%eax),%eax
  8018e8:	89 06                	mov    %eax,(%esi)
	if(pg && perm_store)
  8018ea:	85 db                	test   %ebx,%ebx
  8018ec:	74 13                	je     801901 <ipc_recv+0x49>
  8018ee:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018f2:	74 0d                	je     801901 <ipc_recv+0x49>
		*perm_store = thisenv -> env_ipc_perm;
  8018f4:	a1 08 40 80 00       	mov    0x804008,%eax
  8018f9:	8b 40 78             	mov    0x78(%eax),%eax
  8018fc:	8b 55 10             	mov    0x10(%ebp),%edx
  8018ff:	89 02                	mov    %eax,(%edx)
	else if(perm_store)
		perm_store = (int *)0;
	return thisenv->env_ipc_value;
  801901:	a1 08 40 80 00       	mov    0x804008,%eax
  801906:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  801909:	83 c4 10             	add    $0x10,%esp
  80190c:	5b                   	pop    %ebx
  80190d:	5e                   	pop    %esi
  80190e:	5d                   	pop    %ebp
  80190f:	c3                   	ret    

00801910 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801910:	55                   	push   %ebp
  801911:	89 e5                	mov    %esp,%ebp
  801913:	57                   	push   %edi
  801914:	56                   	push   %esi
  801915:	53                   	push   %ebx
  801916:	83 ec 1c             	sub    $0x1c,%esp
  801919:	8b 7d 08             	mov    0x8(%ebp),%edi
  80191c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80191f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

	if(pg == NULL)
  801922:	85 db                	test   %ebx,%ebx
		pg = (void *)~0x0;
  801924:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801929:	0f 44 d8             	cmove  %eax,%ebx
  80192c:	eb 2a                	jmp    801958 <ipc_send+0x48>
	while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0){
		if(r != -E_IPC_NOT_RECV)
  80192e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801931:	74 20                	je     801953 <ipc_send+0x43>
            panic("Send message error %e\n",r);
  801933:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801937:	c7 44 24 08 08 21 80 	movl   $0x802108,0x8(%esp)
  80193e:	00 
  80193f:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  801946:	00 
  801947:	c7 04 24 1f 21 80 00 	movl   $0x80211f,(%esp)
  80194e:	e8 0d ff ff ff       	call   801860 <_panic>
		sys_yield();
  801953:	e8 b8 f3 ff ff       	call   800d10 <sys_yield>
	// LAB 4: Your code here.
	int r;

	if(pg == NULL)
		pg = (void *)~0x0;
	while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0){
  801958:	8b 45 14             	mov    0x14(%ebp),%eax
  80195b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80195f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801963:	89 74 24 04          	mov    %esi,0x4(%esp)
  801967:	89 3c 24             	mov    %edi,(%esp)
  80196a:	e8 45 f6 ff ff       	call   800fb4 <sys_ipc_try_send>
  80196f:	85 c0                	test   %eax,%eax
  801971:	78 bb                	js     80192e <ipc_send+0x1e>
            panic("Send message error %e\n",r);
		sys_yield();
	}

	//panic("ipc_send not implemented");
}
  801973:	83 c4 1c             	add    $0x1c,%esp
  801976:	5b                   	pop    %ebx
  801977:	5e                   	pop    %esi
  801978:	5f                   	pop    %edi
  801979:	5d                   	pop    %ebp
  80197a:	c3                   	ret    

0080197b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80197b:	55                   	push   %ebp
  80197c:	89 e5                	mov    %esp,%ebp
  80197e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801981:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801986:	39 c8                	cmp    %ecx,%eax
  801988:	74 17                	je     8019a1 <ipc_find_env+0x26>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80198a:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  80198f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801992:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801998:	8b 52 50             	mov    0x50(%edx),%edx
  80199b:	39 ca                	cmp    %ecx,%edx
  80199d:	75 14                	jne    8019b3 <ipc_find_env+0x38>
  80199f:	eb 05                	jmp    8019a6 <ipc_find_env+0x2b>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8019a1:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  8019a6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8019a9:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8019ae:	8b 40 40             	mov    0x40(%eax),%eax
  8019b1:	eb 0e                	jmp    8019c1 <ipc_find_env+0x46>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8019b3:	83 c0 01             	add    $0x1,%eax
  8019b6:	3d 00 04 00 00       	cmp    $0x400,%eax
  8019bb:	75 d2                	jne    80198f <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8019bd:	66 b8 00 00          	mov    $0x0,%ax
}
  8019c1:	5d                   	pop    %ebp
  8019c2:	c3                   	ret    
  8019c3:	66 90                	xchg   %ax,%ax
  8019c5:	66 90                	xchg   %ax,%ax
  8019c7:	66 90                	xchg   %ax,%ax
  8019c9:	66 90                	xchg   %ax,%ax
  8019cb:	66 90                	xchg   %ax,%ax
  8019cd:	66 90                	xchg   %ax,%ax
  8019cf:	90                   	nop

008019d0 <__udivdi3>:
  8019d0:	83 ec 1c             	sub    $0x1c,%esp
  8019d3:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  8019d7:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8019db:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8019df:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8019e3:	8b 7c 24 20          	mov    0x20(%esp),%edi
  8019e7:	8b 6c 24 24          	mov    0x24(%esp),%ebp
  8019eb:	85 c0                	test   %eax,%eax
  8019ed:	89 74 24 10          	mov    %esi,0x10(%esp)
  8019f1:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8019f5:	89 ea                	mov    %ebp,%edx
  8019f7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8019fb:	75 33                	jne    801a30 <__udivdi3+0x60>
  8019fd:	39 e9                	cmp    %ebp,%ecx
  8019ff:	77 6f                	ja     801a70 <__udivdi3+0xa0>
  801a01:	85 c9                	test   %ecx,%ecx
  801a03:	89 ce                	mov    %ecx,%esi
  801a05:	75 0b                	jne    801a12 <__udivdi3+0x42>
  801a07:	b8 01 00 00 00       	mov    $0x1,%eax
  801a0c:	31 d2                	xor    %edx,%edx
  801a0e:	f7 f1                	div    %ecx
  801a10:	89 c6                	mov    %eax,%esi
  801a12:	31 d2                	xor    %edx,%edx
  801a14:	89 e8                	mov    %ebp,%eax
  801a16:	f7 f6                	div    %esi
  801a18:	89 c5                	mov    %eax,%ebp
  801a1a:	89 f8                	mov    %edi,%eax
  801a1c:	f7 f6                	div    %esi
  801a1e:	89 ea                	mov    %ebp,%edx
  801a20:	8b 74 24 10          	mov    0x10(%esp),%esi
  801a24:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801a28:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801a2c:	83 c4 1c             	add    $0x1c,%esp
  801a2f:	c3                   	ret    
  801a30:	39 e8                	cmp    %ebp,%eax
  801a32:	77 24                	ja     801a58 <__udivdi3+0x88>
  801a34:	0f bd c8             	bsr    %eax,%ecx
  801a37:	83 f1 1f             	xor    $0x1f,%ecx
  801a3a:	89 0c 24             	mov    %ecx,(%esp)
  801a3d:	75 49                	jne    801a88 <__udivdi3+0xb8>
  801a3f:	8b 74 24 08          	mov    0x8(%esp),%esi
  801a43:	39 74 24 04          	cmp    %esi,0x4(%esp)
  801a47:	0f 86 ab 00 00 00    	jbe    801af8 <__udivdi3+0x128>
  801a4d:	39 e8                	cmp    %ebp,%eax
  801a4f:	0f 82 a3 00 00 00    	jb     801af8 <__udivdi3+0x128>
  801a55:	8d 76 00             	lea    0x0(%esi),%esi
  801a58:	31 d2                	xor    %edx,%edx
  801a5a:	31 c0                	xor    %eax,%eax
  801a5c:	8b 74 24 10          	mov    0x10(%esp),%esi
  801a60:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801a64:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801a68:	83 c4 1c             	add    $0x1c,%esp
  801a6b:	c3                   	ret    
  801a6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801a70:	89 f8                	mov    %edi,%eax
  801a72:	f7 f1                	div    %ecx
  801a74:	31 d2                	xor    %edx,%edx
  801a76:	8b 74 24 10          	mov    0x10(%esp),%esi
  801a7a:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801a7e:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801a82:	83 c4 1c             	add    $0x1c,%esp
  801a85:	c3                   	ret    
  801a86:	66 90                	xchg   %ax,%ax
  801a88:	0f b6 0c 24          	movzbl (%esp),%ecx
  801a8c:	89 c6                	mov    %eax,%esi
  801a8e:	b8 20 00 00 00       	mov    $0x20,%eax
  801a93:	8b 6c 24 04          	mov    0x4(%esp),%ebp
  801a97:	2b 04 24             	sub    (%esp),%eax
  801a9a:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801a9e:	d3 e6                	shl    %cl,%esi
  801aa0:	89 c1                	mov    %eax,%ecx
  801aa2:	d3 ed                	shr    %cl,%ebp
  801aa4:	0f b6 0c 24          	movzbl (%esp),%ecx
  801aa8:	09 f5                	or     %esi,%ebp
  801aaa:	8b 74 24 04          	mov    0x4(%esp),%esi
  801aae:	d3 e6                	shl    %cl,%esi
  801ab0:	89 c1                	mov    %eax,%ecx
  801ab2:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ab6:	89 d6                	mov    %edx,%esi
  801ab8:	d3 ee                	shr    %cl,%esi
  801aba:	0f b6 0c 24          	movzbl (%esp),%ecx
  801abe:	d3 e2                	shl    %cl,%edx
  801ac0:	89 c1                	mov    %eax,%ecx
  801ac2:	d3 ef                	shr    %cl,%edi
  801ac4:	09 d7                	or     %edx,%edi
  801ac6:	89 f2                	mov    %esi,%edx
  801ac8:	89 f8                	mov    %edi,%eax
  801aca:	f7 f5                	div    %ebp
  801acc:	89 d6                	mov    %edx,%esi
  801ace:	89 c7                	mov    %eax,%edi
  801ad0:	f7 64 24 04          	mull   0x4(%esp)
  801ad4:	39 d6                	cmp    %edx,%esi
  801ad6:	72 30                	jb     801b08 <__udivdi3+0x138>
  801ad8:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801adc:	0f b6 0c 24          	movzbl (%esp),%ecx
  801ae0:	d3 e5                	shl    %cl,%ebp
  801ae2:	39 c5                	cmp    %eax,%ebp
  801ae4:	73 04                	jae    801aea <__udivdi3+0x11a>
  801ae6:	39 d6                	cmp    %edx,%esi
  801ae8:	74 1e                	je     801b08 <__udivdi3+0x138>
  801aea:	89 f8                	mov    %edi,%eax
  801aec:	31 d2                	xor    %edx,%edx
  801aee:	e9 69 ff ff ff       	jmp    801a5c <__udivdi3+0x8c>
  801af3:	90                   	nop
  801af4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801af8:	31 d2                	xor    %edx,%edx
  801afa:	b8 01 00 00 00       	mov    $0x1,%eax
  801aff:	e9 58 ff ff ff       	jmp    801a5c <__udivdi3+0x8c>
  801b04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801b08:	8d 47 ff             	lea    -0x1(%edi),%eax
  801b0b:	31 d2                	xor    %edx,%edx
  801b0d:	8b 74 24 10          	mov    0x10(%esp),%esi
  801b11:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801b15:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801b19:	83 c4 1c             	add    $0x1c,%esp
  801b1c:	c3                   	ret    
  801b1d:	66 90                	xchg   %ax,%ax
  801b1f:	90                   	nop

00801b20 <__umoddi3>:
  801b20:	83 ec 2c             	sub    $0x2c,%esp
  801b23:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801b27:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801b2b:	89 74 24 20          	mov    %esi,0x20(%esp)
  801b2f:	8b 74 24 38          	mov    0x38(%esp),%esi
  801b33:	89 7c 24 24          	mov    %edi,0x24(%esp)
  801b37:	8b 7c 24 34          	mov    0x34(%esp),%edi
  801b3b:	85 c0                	test   %eax,%eax
  801b3d:	89 c2                	mov    %eax,%edx
  801b3f:	89 6c 24 28          	mov    %ebp,0x28(%esp)
  801b43:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801b47:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801b4b:	89 74 24 10          	mov    %esi,0x10(%esp)
  801b4f:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801b53:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801b57:	75 1f                	jne    801b78 <__umoddi3+0x58>
  801b59:	39 fe                	cmp    %edi,%esi
  801b5b:	76 63                	jbe    801bc0 <__umoddi3+0xa0>
  801b5d:	89 c8                	mov    %ecx,%eax
  801b5f:	89 fa                	mov    %edi,%edx
  801b61:	f7 f6                	div    %esi
  801b63:	89 d0                	mov    %edx,%eax
  801b65:	31 d2                	xor    %edx,%edx
  801b67:	8b 74 24 20          	mov    0x20(%esp),%esi
  801b6b:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801b6f:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801b73:	83 c4 2c             	add    $0x2c,%esp
  801b76:	c3                   	ret    
  801b77:	90                   	nop
  801b78:	39 f8                	cmp    %edi,%eax
  801b7a:	77 64                	ja     801be0 <__umoddi3+0xc0>
  801b7c:	0f bd e8             	bsr    %eax,%ebp
  801b7f:	83 f5 1f             	xor    $0x1f,%ebp
  801b82:	75 74                	jne    801bf8 <__umoddi3+0xd8>
  801b84:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801b88:	39 7c 24 10          	cmp    %edi,0x10(%esp)
  801b8c:	0f 87 0e 01 00 00    	ja     801ca0 <__umoddi3+0x180>
  801b92:	8b 7c 24 0c          	mov    0xc(%esp),%edi
  801b96:	29 f1                	sub    %esi,%ecx
  801b98:	19 c7                	sbb    %eax,%edi
  801b9a:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801b9e:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801ba2:	8b 44 24 14          	mov    0x14(%esp),%eax
  801ba6:	8b 54 24 18          	mov    0x18(%esp),%edx
  801baa:	8b 74 24 20          	mov    0x20(%esp),%esi
  801bae:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801bb2:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801bb6:	83 c4 2c             	add    $0x2c,%esp
  801bb9:	c3                   	ret    
  801bba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801bc0:	85 f6                	test   %esi,%esi
  801bc2:	89 f5                	mov    %esi,%ebp
  801bc4:	75 0b                	jne    801bd1 <__umoddi3+0xb1>
  801bc6:	b8 01 00 00 00       	mov    $0x1,%eax
  801bcb:	31 d2                	xor    %edx,%edx
  801bcd:	f7 f6                	div    %esi
  801bcf:	89 c5                	mov    %eax,%ebp
  801bd1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801bd5:	31 d2                	xor    %edx,%edx
  801bd7:	f7 f5                	div    %ebp
  801bd9:	89 c8                	mov    %ecx,%eax
  801bdb:	f7 f5                	div    %ebp
  801bdd:	eb 84                	jmp    801b63 <__umoddi3+0x43>
  801bdf:	90                   	nop
  801be0:	89 c8                	mov    %ecx,%eax
  801be2:	89 fa                	mov    %edi,%edx
  801be4:	8b 74 24 20          	mov    0x20(%esp),%esi
  801be8:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801bec:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801bf0:	83 c4 2c             	add    $0x2c,%esp
  801bf3:	c3                   	ret    
  801bf4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801bf8:	8b 44 24 10          	mov    0x10(%esp),%eax
  801bfc:	be 20 00 00 00       	mov    $0x20,%esi
  801c01:	89 e9                	mov    %ebp,%ecx
  801c03:	29 ee                	sub    %ebp,%esi
  801c05:	d3 e2                	shl    %cl,%edx
  801c07:	89 f1                	mov    %esi,%ecx
  801c09:	d3 e8                	shr    %cl,%eax
  801c0b:	89 e9                	mov    %ebp,%ecx
  801c0d:	09 d0                	or     %edx,%eax
  801c0f:	89 fa                	mov    %edi,%edx
  801c11:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c15:	8b 44 24 10          	mov    0x10(%esp),%eax
  801c19:	d3 e0                	shl    %cl,%eax
  801c1b:	89 f1                	mov    %esi,%ecx
  801c1d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801c21:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801c25:	d3 ea                	shr    %cl,%edx
  801c27:	89 e9                	mov    %ebp,%ecx
  801c29:	d3 e7                	shl    %cl,%edi
  801c2b:	89 f1                	mov    %esi,%ecx
  801c2d:	d3 e8                	shr    %cl,%eax
  801c2f:	89 e9                	mov    %ebp,%ecx
  801c31:	09 f8                	or     %edi,%eax
  801c33:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801c37:	f7 74 24 0c          	divl   0xc(%esp)
  801c3b:	d3 e7                	shl    %cl,%edi
  801c3d:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801c41:	89 d7                	mov    %edx,%edi
  801c43:	f7 64 24 10          	mull   0x10(%esp)
  801c47:	39 d7                	cmp    %edx,%edi
  801c49:	89 c1                	mov    %eax,%ecx
  801c4b:	89 54 24 14          	mov    %edx,0x14(%esp)
  801c4f:	72 3b                	jb     801c8c <__umoddi3+0x16c>
  801c51:	39 44 24 18          	cmp    %eax,0x18(%esp)
  801c55:	72 31                	jb     801c88 <__umoddi3+0x168>
  801c57:	8b 44 24 18          	mov    0x18(%esp),%eax
  801c5b:	29 c8                	sub    %ecx,%eax
  801c5d:	19 d7                	sbb    %edx,%edi
  801c5f:	89 e9                	mov    %ebp,%ecx
  801c61:	89 fa                	mov    %edi,%edx
  801c63:	d3 e8                	shr    %cl,%eax
  801c65:	89 f1                	mov    %esi,%ecx
  801c67:	d3 e2                	shl    %cl,%edx
  801c69:	89 e9                	mov    %ebp,%ecx
  801c6b:	09 d0                	or     %edx,%eax
  801c6d:	89 fa                	mov    %edi,%edx
  801c6f:	d3 ea                	shr    %cl,%edx
  801c71:	8b 74 24 20          	mov    0x20(%esp),%esi
  801c75:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801c79:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801c7d:	83 c4 2c             	add    $0x2c,%esp
  801c80:	c3                   	ret    
  801c81:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c88:	39 d7                	cmp    %edx,%edi
  801c8a:	75 cb                	jne    801c57 <__umoddi3+0x137>
  801c8c:	8b 54 24 14          	mov    0x14(%esp),%edx
  801c90:	89 c1                	mov    %eax,%ecx
  801c92:	2b 4c 24 10          	sub    0x10(%esp),%ecx
  801c96:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  801c9a:	eb bb                	jmp    801c57 <__umoddi3+0x137>
  801c9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ca0:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801ca4:	0f 82 e8 fe ff ff    	jb     801b92 <__umoddi3+0x72>
  801caa:	e9 f3 fe ff ff       	jmp    801ba2 <__umoddi3+0x82>
