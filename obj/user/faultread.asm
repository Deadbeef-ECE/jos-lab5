
obj/user/faultread.debug:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	90                   	nop

00800034 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	cprintf("I read %08x from location 0!\n", *(unsigned*)0);
  80003a:	a1 00 00 00 00       	mov    0x0,%eax
  80003f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800043:	c7 04 24 a0 1c 80 00 	movl   $0x801ca0,(%esp)
  80004a:	e8 14 01 00 00       	call   800163 <cprintf>
}
  80004f:	c9                   	leave  
  800050:	c3                   	ret    
  800051:	66 90                	xchg   %ax,%ax
  800053:	90                   	nop

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	83 ec 18             	sub    $0x18,%esp
  80005a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80005d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800060:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800063:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;

	thisenv = &envs[ENVX(sys_getenvid())];
  800066:	e8 4c 0c 00 00       	call   800cb7 <sys_getenvid>
  80006b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800070:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800073:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800078:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007d:	85 db                	test   %ebx,%ebx
  80007f:	7e 07                	jle    800088 <libmain+0x34>
		binaryname = argv[0];
  800081:	8b 06                	mov    (%esi),%eax
  800083:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800088:	89 74 24 04          	mov    %esi,0x4(%esp)
  80008c:	89 1c 24             	mov    %ebx,(%esp)
  80008f:	e8 a0 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800094:	e8 0b 00 00 00       	call   8000a4 <exit>
}
  800099:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80009c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80009f:	89 ec                	mov    %ebp,%esp
  8000a1:	5d                   	pop    %ebp
  8000a2:	c3                   	ret    
  8000a3:	90                   	nop

008000a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000aa:	e8 94 11 00 00       	call   801243 <close_all>
	sys_env_destroy(0);
  8000af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b6:	e8 96 0b 00 00       	call   800c51 <sys_env_destroy>
}
  8000bb:	c9                   	leave  
  8000bc:	c3                   	ret    
  8000bd:	66 90                	xchg   %ax,%ax
  8000bf:	90                   	nop

008000c0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	53                   	push   %ebx
  8000c4:	83 ec 14             	sub    $0x14,%esp
  8000c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ca:	8b 03                	mov    (%ebx),%eax
  8000cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000cf:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000d3:	83 c0 01             	add    $0x1,%eax
  8000d6:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000d8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000dd:	75 19                	jne    8000f8 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8000df:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000e6:	00 
  8000e7:	8d 43 08             	lea    0x8(%ebx),%eax
  8000ea:	89 04 24             	mov    %eax,(%esp)
  8000ed:	e8 ee 0a 00 00       	call   800be0 <sys_cputs>
		b->idx = 0;
  8000f2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8000f8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000fc:	83 c4 14             	add    $0x14,%esp
  8000ff:	5b                   	pop    %ebx
  800100:	5d                   	pop    %ebp
  800101:	c3                   	ret    

00800102 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800102:	55                   	push   %ebp
  800103:	89 e5                	mov    %esp,%ebp
  800105:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80010b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800112:	00 00 00 
	b.cnt = 0;
  800115:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80011c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80011f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800122:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800126:	8b 45 08             	mov    0x8(%ebp),%eax
  800129:	89 44 24 08          	mov    %eax,0x8(%esp)
  80012d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800133:	89 44 24 04          	mov    %eax,0x4(%esp)
  800137:	c7 04 24 c0 00 80 00 	movl   $0x8000c0,(%esp)
  80013e:	e8 af 01 00 00       	call   8002f2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800143:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800149:	89 44 24 04          	mov    %eax,0x4(%esp)
  80014d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800153:	89 04 24             	mov    %eax,(%esp)
  800156:	e8 85 0a 00 00       	call   800be0 <sys_cputs>

	return b.cnt;
}
  80015b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800161:	c9                   	leave  
  800162:	c3                   	ret    

00800163 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800169:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80016c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800170:	8b 45 08             	mov    0x8(%ebp),%eax
  800173:	89 04 24             	mov    %eax,(%esp)
  800176:	e8 87 ff ff ff       	call   800102 <vcprintf>
	va_end(ap);

	return cnt;
}
  80017b:	c9                   	leave  
  80017c:	c3                   	ret    
  80017d:	66 90                	xchg   %ax,%ax
  80017f:	90                   	nop

00800180 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	57                   	push   %edi
  800184:	56                   	push   %esi
  800185:	53                   	push   %ebx
  800186:	83 ec 4c             	sub    $0x4c,%esp
  800189:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80018c:	89 d7                	mov    %edx,%edi
  80018e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800191:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800194:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800197:	89 5d dc             	mov    %ebx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80019a:	b8 00 00 00 00       	mov    $0x0,%eax
  80019f:	39 d8                	cmp    %ebx,%eax
  8001a1:	72 17                	jb     8001ba <printnum+0x3a>
  8001a3:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8001a6:	39 5d 10             	cmp    %ebx,0x10(%ebp)
  8001a9:	76 0f                	jbe    8001ba <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001ab:	8b 75 14             	mov    0x14(%ebp),%esi
  8001ae:	83 ee 01             	sub    $0x1,%esi
  8001b1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8001b4:	85 f6                	test   %esi,%esi
  8001b6:	7f 63                	jg     80021b <printnum+0x9b>
  8001b8:	eb 75                	jmp    80022f <printnum+0xaf>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ba:	8b 5d 18             	mov    0x18(%ebp),%ebx
  8001bd:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8001c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8001c4:	83 e8 01             	sub    $0x1,%eax
  8001c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001cb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001d2:	8b 44 24 08          	mov    0x8(%esp),%eax
  8001d6:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8001da:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001dd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8001e0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001e7:	00 
  8001e8:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8001eb:	89 1c 24             	mov    %ebx,(%esp)
  8001ee:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8001f1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001f5:	e8 b6 17 00 00       	call   8019b0 <__udivdi3>
  8001fa:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8001fd:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800200:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800204:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800208:	89 04 24             	mov    %eax,(%esp)
  80020b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80020f:	89 fa                	mov    %edi,%edx
  800211:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800214:	e8 67 ff ff ff       	call   800180 <printnum>
  800219:	eb 14                	jmp    80022f <printnum+0xaf>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80021b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80021f:	8b 45 18             	mov    0x18(%ebp),%eax
  800222:	89 04 24             	mov    %eax,(%esp)
  800225:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800227:	83 ee 01             	sub    $0x1,%esi
  80022a:	75 ef                	jne    80021b <printnum+0x9b>
  80022c:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80022f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800233:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800237:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80023a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80023e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800245:	00 
  800246:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800249:	89 1c 24             	mov    %ebx,(%esp)
  80024c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80024f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800253:	e8 a8 18 00 00       	call   801b00 <__umoddi3>
  800258:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80025c:	0f be 80 c8 1c 80 00 	movsbl 0x801cc8(%eax),%eax
  800263:	89 04 24             	mov    %eax,(%esp)
  800266:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800269:	ff d0                	call   *%eax
}
  80026b:	83 c4 4c             	add    $0x4c,%esp
  80026e:	5b                   	pop    %ebx
  80026f:	5e                   	pop    %esi
  800270:	5f                   	pop    %edi
  800271:	5d                   	pop    %ebp
  800272:	c3                   	ret    

00800273 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800273:	55                   	push   %ebp
  800274:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800276:	83 fa 01             	cmp    $0x1,%edx
  800279:	7e 0e                	jle    800289 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80027b:	8b 10                	mov    (%eax),%edx
  80027d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800280:	89 08                	mov    %ecx,(%eax)
  800282:	8b 02                	mov    (%edx),%eax
  800284:	8b 52 04             	mov    0x4(%edx),%edx
  800287:	eb 22                	jmp    8002ab <getuint+0x38>
	else if (lflag)
  800289:	85 d2                	test   %edx,%edx
  80028b:	74 10                	je     80029d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80028d:	8b 10                	mov    (%eax),%edx
  80028f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800292:	89 08                	mov    %ecx,(%eax)
  800294:	8b 02                	mov    (%edx),%eax
  800296:	ba 00 00 00 00       	mov    $0x0,%edx
  80029b:	eb 0e                	jmp    8002ab <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80029d:	8b 10                	mov    (%eax),%edx
  80029f:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a2:	89 08                	mov    %ecx,(%eax)
  8002a4:	8b 02                	mov    (%edx),%eax
  8002a6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ab:	5d                   	pop    %ebp
  8002ac:	c3                   	ret    

008002ad <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ad:	55                   	push   %ebp
  8002ae:	89 e5                	mov    %esp,%ebp
  8002b0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002b7:	8b 10                	mov    (%eax),%edx
  8002b9:	3b 50 04             	cmp    0x4(%eax),%edx
  8002bc:	73 0a                	jae    8002c8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002be:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002c1:	88 0a                	mov    %cl,(%edx)
  8002c3:	83 c2 01             	add    $0x1,%edx
  8002c6:	89 10                	mov    %edx,(%eax)
}
  8002c8:	5d                   	pop    %ebp
  8002c9:	c3                   	ret    

008002ca <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ca:	55                   	push   %ebp
  8002cb:	89 e5                	mov    %esp,%ebp
  8002cd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002d0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002d7:	8b 45 10             	mov    0x10(%ebp),%eax
  8002da:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e8:	89 04 24             	mov    %eax,(%esp)
  8002eb:	e8 02 00 00 00       	call   8002f2 <vprintfmt>
	va_end(ap);
}
  8002f0:	c9                   	leave  
  8002f1:	c3                   	ret    

008002f2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002f2:	55                   	push   %ebp
  8002f3:	89 e5                	mov    %esp,%ebp
  8002f5:	57                   	push   %edi
  8002f6:	56                   	push   %esi
  8002f7:	53                   	push   %ebx
  8002f8:	83 ec 4c             	sub    $0x4c,%esp
  8002fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8002fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800301:	8b 7d 10             	mov    0x10(%ebp),%edi
  800304:	eb 11                	jmp    800317 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800306:	85 c0                	test   %eax,%eax
  800308:	0f 84 db 03 00 00    	je     8006e9 <vprintfmt+0x3f7>
				return;
			putch(ch, putdat);
  80030e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800312:	89 04 24             	mov    %eax,(%esp)
  800315:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800317:	0f b6 07             	movzbl (%edi),%eax
  80031a:	83 c7 01             	add    $0x1,%edi
  80031d:	83 f8 25             	cmp    $0x25,%eax
  800320:	75 e4                	jne    800306 <vprintfmt+0x14>
  800322:	c6 45 e4 20          	movb   $0x20,-0x1c(%ebp)
  800326:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80032d:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800334:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80033b:	ba 00 00 00 00       	mov    $0x0,%edx
  800340:	eb 2b                	jmp    80036d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800342:	8b 7d e0             	mov    -0x20(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800345:	c6 45 e4 2d          	movb   $0x2d,-0x1c(%ebp)
  800349:	eb 22                	jmp    80036d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034b:	8b 7d e0             	mov    -0x20(%ebp),%edi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80034e:	c6 45 e4 30          	movb   $0x30,-0x1c(%ebp)
  800352:	eb 19                	jmp    80036d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800354:	8b 7d e0             	mov    -0x20(%ebp),%edi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800357:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80035e:	eb 0d                	jmp    80036d <vprintfmt+0x7b>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800360:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800363:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800366:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036d:	0f b6 0f             	movzbl (%edi),%ecx
  800370:	8d 47 01             	lea    0x1(%edi),%eax
  800373:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800376:	0f b6 07             	movzbl (%edi),%eax
  800379:	83 e8 23             	sub    $0x23,%eax
  80037c:	3c 55                	cmp    $0x55,%al
  80037e:	0f 87 40 03 00 00    	ja     8006c4 <vprintfmt+0x3d2>
  800384:	0f b6 c0             	movzbl %al,%eax
  800387:	ff 24 85 00 1e 80 00 	jmp    *0x801e00(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80038e:	83 e9 30             	sub    $0x30,%ecx
  800391:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				ch = *fmt;
  800394:	0f be 47 01          	movsbl 0x1(%edi),%eax
				if (ch < '0' || ch > '9')
  800398:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80039b:	83 f9 09             	cmp    $0x9,%ecx
  80039e:	77 57                	ja     8003f7 <vprintfmt+0x105>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a0:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8003a3:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8003a6:	8b 55 dc             	mov    -0x24(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003a9:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003ac:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8003af:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8003b3:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8003b6:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8003b9:	83 f9 09             	cmp    $0x9,%ecx
  8003bc:	76 eb                	jbe    8003a9 <vprintfmt+0xb7>
  8003be:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8003c1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003c4:	eb 34                	jmp    8003fa <vprintfmt+0x108>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c9:	8d 48 04             	lea    0x4(%eax),%ecx
  8003cc:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003cf:	8b 00                	mov    (%eax),%eax
  8003d1:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d4:	8b 7d e0             	mov    -0x20(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003d7:	eb 21                	jmp    8003fa <vprintfmt+0x108>

		case '.':
			if (width < 0)
  8003d9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8003dd:	0f 88 71 ff ff ff    	js     800354 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e3:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8003e6:	eb 85                	jmp    80036d <vprintfmt+0x7b>
  8003e8:	8b 7d e0             	mov    -0x20(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003eb:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  8003f2:	e9 76 ff ff ff       	jmp    80036d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f7:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003fa:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8003fe:	0f 89 69 ff ff ff    	jns    80036d <vprintfmt+0x7b>
  800404:	e9 57 ff ff ff       	jmp    800360 <vprintfmt+0x6e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800409:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80040f:	e9 59 ff ff ff       	jmp    80036d <vprintfmt+0x7b>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800414:	8b 45 14             	mov    0x14(%ebp),%eax
  800417:	8d 50 04             	lea    0x4(%eax),%edx
  80041a:	89 55 14             	mov    %edx,0x14(%ebp)
  80041d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800421:	8b 00                	mov    (%eax),%eax
  800423:	89 04 24             	mov    %eax,(%esp)
  800426:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800428:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80042b:	e9 e7 fe ff ff       	jmp    800317 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800430:	8b 45 14             	mov    0x14(%ebp),%eax
  800433:	8d 50 04             	lea    0x4(%eax),%edx
  800436:	89 55 14             	mov    %edx,0x14(%ebp)
  800439:	8b 00                	mov    (%eax),%eax
  80043b:	89 c2                	mov    %eax,%edx
  80043d:	c1 fa 1f             	sar    $0x1f,%edx
  800440:	31 d0                	xor    %edx,%eax
  800442:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800444:	83 f8 0f             	cmp    $0xf,%eax
  800447:	7f 0b                	jg     800454 <vprintfmt+0x162>
  800449:	8b 14 85 60 1f 80 00 	mov    0x801f60(,%eax,4),%edx
  800450:	85 d2                	test   %edx,%edx
  800452:	75 20                	jne    800474 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  800454:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800458:	c7 44 24 08 e0 1c 80 	movl   $0x801ce0,0x8(%esp)
  80045f:	00 
  800460:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800464:	89 34 24             	mov    %esi,(%esp)
  800467:	e8 5e fe ff ff       	call   8002ca <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046c:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80046f:	e9 a3 fe ff ff       	jmp    800317 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800474:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800478:	c7 44 24 08 e9 1c 80 	movl   $0x801ce9,0x8(%esp)
  80047f:	00 
  800480:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800484:	89 34 24             	mov    %esi,(%esp)
  800487:	e8 3e fe ff ff       	call   8002ca <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048c:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80048f:	e9 83 fe ff ff       	jmp    800317 <vprintfmt+0x25>
  800494:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800497:	8b 7d d8             	mov    -0x28(%ebp),%edi
  80049a:	89 7d cc             	mov    %edi,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80049d:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a0:	8d 50 04             	lea    0x4(%eax),%edx
  8004a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004a8:	85 ff                	test   %edi,%edi
  8004aa:	b8 d9 1c 80 00       	mov    $0x801cd9,%eax
  8004af:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004b2:	80 7d e4 2d          	cmpb   $0x2d,-0x1c(%ebp)
  8004b6:	74 06                	je     8004be <vprintfmt+0x1cc>
  8004b8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004bc:	7f 16                	jg     8004d4 <vprintfmt+0x1e2>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004be:	0f b6 17             	movzbl (%edi),%edx
  8004c1:	0f be c2             	movsbl %dl,%eax
  8004c4:	83 c7 01             	add    $0x1,%edi
  8004c7:	85 c0                	test   %eax,%eax
  8004c9:	0f 85 9f 00 00 00    	jne    80056e <vprintfmt+0x27c>
  8004cf:	e9 8b 00 00 00       	jmp    80055f <vprintfmt+0x26d>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004d8:	89 3c 24             	mov    %edi,(%esp)
  8004db:	e8 c2 02 00 00       	call   8007a2 <strnlen>
  8004e0:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8004e3:	29 c2                	sub    %eax,%edx
  8004e5:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8004e8:	85 d2                	test   %edx,%edx
  8004ea:	7e d2                	jle    8004be <vprintfmt+0x1cc>
					putch(padc, putdat);
  8004ec:	0f be 4d e4          	movsbl -0x1c(%ebp),%ecx
  8004f0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8004f3:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8004f6:	89 d7                	mov    %edx,%edi
  8004f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004ff:	89 04 24             	mov    %eax,(%esp)
  800502:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800504:	83 ef 01             	sub    $0x1,%edi
  800507:	75 ef                	jne    8004f8 <vprintfmt+0x206>
  800509:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80050c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80050f:	eb ad                	jmp    8004be <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800511:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800515:	74 20                	je     800537 <vprintfmt+0x245>
  800517:	0f be d2             	movsbl %dl,%edx
  80051a:	83 ea 20             	sub    $0x20,%edx
  80051d:	83 fa 5e             	cmp    $0x5e,%edx
  800520:	76 15                	jbe    800537 <vprintfmt+0x245>
					putch('?', putdat);
  800522:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800525:	89 54 24 04          	mov    %edx,0x4(%esp)
  800529:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800530:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800533:	ff d1                	call   *%ecx
  800535:	eb 0f                	jmp    800546 <vprintfmt+0x254>
				else
					putch(ch, putdat);
  800537:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80053a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80053e:	89 04 24             	mov    %eax,(%esp)
  800541:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800544:	ff d1                	call   *%ecx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800546:	83 eb 01             	sub    $0x1,%ebx
  800549:	0f b6 17             	movzbl (%edi),%edx
  80054c:	0f be c2             	movsbl %dl,%eax
  80054f:	83 c7 01             	add    $0x1,%edi
  800552:	85 c0                	test   %eax,%eax
  800554:	75 24                	jne    80057a <vprintfmt+0x288>
  800556:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800559:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80055c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055f:	8b 7d e0             	mov    -0x20(%ebp),%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800562:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800566:	0f 8e ab fd ff ff    	jle    800317 <vprintfmt+0x25>
  80056c:	eb 20                	jmp    80058e <vprintfmt+0x29c>
  80056e:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800571:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800574:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  800577:	8b 5d d8             	mov    -0x28(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80057a:	85 f6                	test   %esi,%esi
  80057c:	78 93                	js     800511 <vprintfmt+0x21f>
  80057e:	83 ee 01             	sub    $0x1,%esi
  800581:	79 8e                	jns    800511 <vprintfmt+0x21f>
  800583:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800586:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800589:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80058c:	eb d1                	jmp    80055f <vprintfmt+0x26d>
  80058e:	8b 7d d8             	mov    -0x28(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800591:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800595:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80059c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80059e:	83 ef 01             	sub    $0x1,%edi
  8005a1:	75 ee                	jne    800591 <vprintfmt+0x29f>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a3:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005a6:	e9 6c fd ff ff       	jmp    800317 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ab:	83 fa 01             	cmp    $0x1,%edx
  8005ae:	66 90                	xchg   %ax,%ax
  8005b0:	7e 16                	jle    8005c8 <vprintfmt+0x2d6>
		return va_arg(*ap, long long);
  8005b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b5:	8d 50 08             	lea    0x8(%eax),%edx
  8005b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005bb:	8b 10                	mov    (%eax),%edx
  8005bd:	8b 48 04             	mov    0x4(%eax),%ecx
  8005c0:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8005c3:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8005c6:	eb 32                	jmp    8005fa <vprintfmt+0x308>
	else if (lflag)
  8005c8:	85 d2                	test   %edx,%edx
  8005ca:	74 18                	je     8005e4 <vprintfmt+0x2f2>
		return va_arg(*ap, long);
  8005cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cf:	8d 50 04             	lea    0x4(%eax),%edx
  8005d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d5:	8b 00                	mov    (%eax),%eax
  8005d7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005da:	89 c1                	mov    %eax,%ecx
  8005dc:	c1 f9 1f             	sar    $0x1f,%ecx
  8005df:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8005e2:	eb 16                	jmp    8005fa <vprintfmt+0x308>
	else
		return va_arg(*ap, int);
  8005e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e7:	8d 50 04             	lea    0x4(%eax),%edx
  8005ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ed:	8b 00                	mov    (%eax),%eax
  8005ef:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005f2:	89 c7                	mov    %eax,%edi
  8005f4:	c1 ff 1f             	sar    $0x1f,%edi
  8005f7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005fa:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005fd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800600:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800605:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800609:	79 7d                	jns    800688 <vprintfmt+0x396>
				putch('-', putdat);
  80060b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80060f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800616:	ff d6                	call   *%esi
				num = -(long long) num;
  800618:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80061b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80061e:	f7 d8                	neg    %eax
  800620:	83 d2 00             	adc    $0x0,%edx
  800623:	f7 da                	neg    %edx
			}
			base = 10;
  800625:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80062a:	eb 5c                	jmp    800688 <vprintfmt+0x396>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80062c:	8d 45 14             	lea    0x14(%ebp),%eax
  80062f:	e8 3f fc ff ff       	call   800273 <getuint>
			base = 10;
  800634:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800639:	eb 4d                	jmp    800688 <vprintfmt+0x396>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80063b:	8d 45 14             	lea    0x14(%ebp),%eax
  80063e:	e8 30 fc ff ff       	call   800273 <getuint>
			base = 8;
  800643:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800648:	eb 3e                	jmp    800688 <vprintfmt+0x396>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80064a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80064e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800655:	ff d6                	call   *%esi
			putch('x', putdat);
  800657:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80065b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800662:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800664:	8b 45 14             	mov    0x14(%ebp),%eax
  800667:	8d 50 04             	lea    0x4(%eax),%edx
  80066a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80066d:	8b 00                	mov    (%eax),%eax
  80066f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800674:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800679:	eb 0d                	jmp    800688 <vprintfmt+0x396>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80067b:	8d 45 14             	lea    0x14(%ebp),%eax
  80067e:	e8 f0 fb ff ff       	call   800273 <getuint>
			base = 16;
  800683:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800688:	0f be 7d e4          	movsbl -0x1c(%ebp),%edi
  80068c:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800690:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800693:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800697:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80069b:	89 04 24             	mov    %eax,(%esp)
  80069e:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006a2:	89 da                	mov    %ebx,%edx
  8006a4:	89 f0                	mov    %esi,%eax
  8006a6:	e8 d5 fa ff ff       	call   800180 <printnum>
			break;
  8006ab:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8006ae:	e9 64 fc ff ff       	jmp    800317 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006b3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b7:	89 0c 24             	mov    %ecx,(%esp)
  8006ba:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006bc:	8b 7d e0             	mov    -0x20(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006bf:	e9 53 fc ff ff       	jmp    800317 <vprintfmt+0x25>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c8:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006cf:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006d1:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006d5:	0f 84 3c fc ff ff    	je     800317 <vprintfmt+0x25>
  8006db:	83 ef 01             	sub    $0x1,%edi
  8006de:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006e2:	75 f7                	jne    8006db <vprintfmt+0x3e9>
  8006e4:	e9 2e fc ff ff       	jmp    800317 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8006e9:	83 c4 4c             	add    $0x4c,%esp
  8006ec:	5b                   	pop    %ebx
  8006ed:	5e                   	pop    %esi
  8006ee:	5f                   	pop    %edi
  8006ef:	5d                   	pop    %ebp
  8006f0:	c3                   	ret    

008006f1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f1:	55                   	push   %ebp
  8006f2:	89 e5                	mov    %esp,%ebp
  8006f4:	83 ec 28             	sub    $0x28,%esp
  8006f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fa:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006fd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800700:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800704:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800707:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80070e:	85 d2                	test   %edx,%edx
  800710:	7e 30                	jle    800742 <vsnprintf+0x51>
  800712:	85 c0                	test   %eax,%eax
  800714:	74 2c                	je     800742 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800716:	8b 45 14             	mov    0x14(%ebp),%eax
  800719:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80071d:	8b 45 10             	mov    0x10(%ebp),%eax
  800720:	89 44 24 08          	mov    %eax,0x8(%esp)
  800724:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800727:	89 44 24 04          	mov    %eax,0x4(%esp)
  80072b:	c7 04 24 ad 02 80 00 	movl   $0x8002ad,(%esp)
  800732:	e8 bb fb ff ff       	call   8002f2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800737:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80073a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80073d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800740:	eb 05                	jmp    800747 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800742:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800747:	c9                   	leave  
  800748:	c3                   	ret    

00800749 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800749:	55                   	push   %ebp
  80074a:	89 e5                	mov    %esp,%ebp
  80074c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80074f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800752:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800756:	8b 45 10             	mov    0x10(%ebp),%eax
  800759:	89 44 24 08          	mov    %eax,0x8(%esp)
  80075d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800760:	89 44 24 04          	mov    %eax,0x4(%esp)
  800764:	8b 45 08             	mov    0x8(%ebp),%eax
  800767:	89 04 24             	mov    %eax,(%esp)
  80076a:	e8 82 ff ff ff       	call   8006f1 <vsnprintf>
	va_end(ap);

	return rc;
}
  80076f:	c9                   	leave  
  800770:	c3                   	ret    
  800771:	66 90                	xchg   %ax,%ax
  800773:	66 90                	xchg   %ax,%ax
  800775:	66 90                	xchg   %ax,%ax
  800777:	66 90                	xchg   %ax,%ax
  800779:	66 90                	xchg   %ax,%ax
  80077b:	66 90                	xchg   %ax,%ax
  80077d:	66 90                	xchg   %ax,%ax
  80077f:	90                   	nop

00800780 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800786:	80 3a 00             	cmpb   $0x0,(%edx)
  800789:	74 10                	je     80079b <strlen+0x1b>
  80078b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800790:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800793:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800797:	75 f7                	jne    800790 <strlen+0x10>
  800799:	eb 05                	jmp    8007a0 <strlen+0x20>
  80079b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007a0:	5d                   	pop    %ebp
  8007a1:	c3                   	ret    

008007a2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007a2:	55                   	push   %ebp
  8007a3:	89 e5                	mov    %esp,%ebp
  8007a5:	53                   	push   %ebx
  8007a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ac:	85 c9                	test   %ecx,%ecx
  8007ae:	74 1c                	je     8007cc <strnlen+0x2a>
  8007b0:	80 3b 00             	cmpb   $0x0,(%ebx)
  8007b3:	74 1e                	je     8007d3 <strnlen+0x31>
  8007b5:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8007ba:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007bc:	39 ca                	cmp    %ecx,%edx
  8007be:	74 18                	je     8007d8 <strnlen+0x36>
  8007c0:	83 c2 01             	add    $0x1,%edx
  8007c3:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8007c8:	75 f0                	jne    8007ba <strnlen+0x18>
  8007ca:	eb 0c                	jmp    8007d8 <strnlen+0x36>
  8007cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d1:	eb 05                	jmp    8007d8 <strnlen+0x36>
  8007d3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007d8:	5b                   	pop    %ebx
  8007d9:	5d                   	pop    %ebp
  8007da:	c3                   	ret    

008007db <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007db:	55                   	push   %ebp
  8007dc:	89 e5                	mov    %esp,%ebp
  8007de:	53                   	push   %ebx
  8007df:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007e5:	89 c2                	mov    %eax,%edx
  8007e7:	0f b6 19             	movzbl (%ecx),%ebx
  8007ea:	88 1a                	mov    %bl,(%edx)
  8007ec:	83 c2 01             	add    $0x1,%edx
  8007ef:	83 c1 01             	add    $0x1,%ecx
  8007f2:	84 db                	test   %bl,%bl
  8007f4:	75 f1                	jne    8007e7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007f6:	5b                   	pop    %ebx
  8007f7:	5d                   	pop    %ebp
  8007f8:	c3                   	ret    

008007f9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007f9:	55                   	push   %ebp
  8007fa:	89 e5                	mov    %esp,%ebp
  8007fc:	53                   	push   %ebx
  8007fd:	83 ec 08             	sub    $0x8,%esp
  800800:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800803:	89 1c 24             	mov    %ebx,(%esp)
  800806:	e8 75 ff ff ff       	call   800780 <strlen>
	strcpy(dst + len, src);
  80080b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80080e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800812:	01 d8                	add    %ebx,%eax
  800814:	89 04 24             	mov    %eax,(%esp)
  800817:	e8 bf ff ff ff       	call   8007db <strcpy>
	return dst;
}
  80081c:	89 d8                	mov    %ebx,%eax
  80081e:	83 c4 08             	add    $0x8,%esp
  800821:	5b                   	pop    %ebx
  800822:	5d                   	pop    %ebp
  800823:	c3                   	ret    

00800824 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
  800827:	56                   	push   %esi
  800828:	53                   	push   %ebx
  800829:	8b 75 08             	mov    0x8(%ebp),%esi
  80082c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80082f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800832:	85 db                	test   %ebx,%ebx
  800834:	74 16                	je     80084c <strncpy+0x28>
	strcpy(dst + len, src);
	return dst;
}

char *
strncpy(char *dst, const char *src, size_t size) {
  800836:	01 f3                	add    %esi,%ebx
  800838:	89 f1                	mov    %esi,%ecx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  80083a:	0f b6 02             	movzbl (%edx),%eax
  80083d:	88 01                	mov    %al,(%ecx)
  80083f:	83 c1 01             	add    $0x1,%ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800842:	80 3a 01             	cmpb   $0x1,(%edx)
  800845:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800848:	39 d9                	cmp    %ebx,%ecx
  80084a:	75 ee                	jne    80083a <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80084c:	89 f0                	mov    %esi,%eax
  80084e:	5b                   	pop    %ebx
  80084f:	5e                   	pop    %esi
  800850:	5d                   	pop    %ebp
  800851:	c3                   	ret    

00800852 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	57                   	push   %edi
  800856:	56                   	push   %esi
  800857:	53                   	push   %ebx
  800858:	8b 7d 08             	mov    0x8(%ebp),%edi
  80085b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80085e:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800861:	89 f8                	mov    %edi,%eax
  800863:	85 f6                	test   %esi,%esi
  800865:	74 33                	je     80089a <strlcpy+0x48>
		while (--size > 0 && *src != '\0')
  800867:	83 fe 01             	cmp    $0x1,%esi
  80086a:	74 25                	je     800891 <strlcpy+0x3f>
  80086c:	0f b6 0b             	movzbl (%ebx),%ecx
  80086f:	84 c9                	test   %cl,%cl
  800871:	74 22                	je     800895 <strlcpy+0x43>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800873:	83 ee 02             	sub    $0x2,%esi
  800876:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80087b:	88 08                	mov    %cl,(%eax)
  80087d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800880:	39 f2                	cmp    %esi,%edx
  800882:	74 13                	je     800897 <strlcpy+0x45>
  800884:	83 c2 01             	add    $0x1,%edx
  800887:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80088b:	84 c9                	test   %cl,%cl
  80088d:	75 ec                	jne    80087b <strlcpy+0x29>
  80088f:	eb 06                	jmp    800897 <strlcpy+0x45>
  800891:	89 f8                	mov    %edi,%eax
  800893:	eb 02                	jmp    800897 <strlcpy+0x45>
  800895:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800897:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80089a:	29 f8                	sub    %edi,%eax
}
  80089c:	5b                   	pop    %ebx
  80089d:	5e                   	pop    %esi
  80089e:	5f                   	pop    %edi
  80089f:	5d                   	pop    %ebp
  8008a0:	c3                   	ret    

008008a1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008a1:	55                   	push   %ebp
  8008a2:	89 e5                	mov    %esp,%ebp
  8008a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008aa:	0f b6 01             	movzbl (%ecx),%eax
  8008ad:	84 c0                	test   %al,%al
  8008af:	74 15                	je     8008c6 <strcmp+0x25>
  8008b1:	3a 02                	cmp    (%edx),%al
  8008b3:	75 11                	jne    8008c6 <strcmp+0x25>
		p++, q++;
  8008b5:	83 c1 01             	add    $0x1,%ecx
  8008b8:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008bb:	0f b6 01             	movzbl (%ecx),%eax
  8008be:	84 c0                	test   %al,%al
  8008c0:	74 04                	je     8008c6 <strcmp+0x25>
  8008c2:	3a 02                	cmp    (%edx),%al
  8008c4:	74 ef                	je     8008b5 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c6:	0f b6 c0             	movzbl %al,%eax
  8008c9:	0f b6 12             	movzbl (%edx),%edx
  8008cc:	29 d0                	sub    %edx,%eax
}
  8008ce:	5d                   	pop    %ebp
  8008cf:	c3                   	ret    

008008d0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
  8008d3:	56                   	push   %esi
  8008d4:	53                   	push   %ebx
  8008d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008db:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  8008de:	85 f6                	test   %esi,%esi
  8008e0:	74 29                	je     80090b <strncmp+0x3b>
  8008e2:	0f b6 03             	movzbl (%ebx),%eax
  8008e5:	84 c0                	test   %al,%al
  8008e7:	74 30                	je     800919 <strncmp+0x49>
  8008e9:	3a 02                	cmp    (%edx),%al
  8008eb:	75 2c                	jne    800919 <strncmp+0x49>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}

int
strncmp(const char *p, const char *q, size_t n)
  8008ed:	8d 43 01             	lea    0x1(%ebx),%eax
  8008f0:	01 de                	add    %ebx,%esi
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  8008f2:	89 c3                	mov    %eax,%ebx
  8008f4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008f7:	39 f0                	cmp    %esi,%eax
  8008f9:	74 17                	je     800912 <strncmp+0x42>
  8008fb:	0f b6 08             	movzbl (%eax),%ecx
  8008fe:	84 c9                	test   %cl,%cl
  800900:	74 17                	je     800919 <strncmp+0x49>
  800902:	83 c0 01             	add    $0x1,%eax
  800905:	3a 0a                	cmp    (%edx),%cl
  800907:	74 e9                	je     8008f2 <strncmp+0x22>
  800909:	eb 0e                	jmp    800919 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  80090b:	b8 00 00 00 00       	mov    $0x0,%eax
  800910:	eb 0f                	jmp    800921 <strncmp+0x51>
  800912:	b8 00 00 00 00       	mov    $0x0,%eax
  800917:	eb 08                	jmp    800921 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800919:	0f b6 03             	movzbl (%ebx),%eax
  80091c:	0f b6 12             	movzbl (%edx),%edx
  80091f:	29 d0                	sub    %edx,%eax
}
  800921:	5b                   	pop    %ebx
  800922:	5e                   	pop    %esi
  800923:	5d                   	pop    %ebp
  800924:	c3                   	ret    

00800925 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800925:	55                   	push   %ebp
  800926:	89 e5                	mov    %esp,%ebp
  800928:	53                   	push   %ebx
  800929:	8b 45 08             	mov    0x8(%ebp),%eax
  80092c:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  80092f:	0f b6 18             	movzbl (%eax),%ebx
  800932:	84 db                	test   %bl,%bl
  800934:	74 1d                	je     800953 <strchr+0x2e>
  800936:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800938:	38 d3                	cmp    %dl,%bl
  80093a:	75 06                	jne    800942 <strchr+0x1d>
  80093c:	eb 1a                	jmp    800958 <strchr+0x33>
  80093e:	38 ca                	cmp    %cl,%dl
  800940:	74 16                	je     800958 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800942:	83 c0 01             	add    $0x1,%eax
  800945:	0f b6 10             	movzbl (%eax),%edx
  800948:	84 d2                	test   %dl,%dl
  80094a:	75 f2                	jne    80093e <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  80094c:	b8 00 00 00 00       	mov    $0x0,%eax
  800951:	eb 05                	jmp    800958 <strchr+0x33>
  800953:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800958:	5b                   	pop    %ebx
  800959:	5d                   	pop    %ebp
  80095a:	c3                   	ret    

0080095b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	53                   	push   %ebx
  80095f:	8b 45 08             	mov    0x8(%ebp),%eax
  800962:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800965:	0f b6 18             	movzbl (%eax),%ebx
  800968:	84 db                	test   %bl,%bl
  80096a:	74 16                	je     800982 <strfind+0x27>
  80096c:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  80096e:	38 d3                	cmp    %dl,%bl
  800970:	75 06                	jne    800978 <strfind+0x1d>
  800972:	eb 0e                	jmp    800982 <strfind+0x27>
  800974:	38 ca                	cmp    %cl,%dl
  800976:	74 0a                	je     800982 <strfind+0x27>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800978:	83 c0 01             	add    $0x1,%eax
  80097b:	0f b6 10             	movzbl (%eax),%edx
  80097e:	84 d2                	test   %dl,%dl
  800980:	75 f2                	jne    800974 <strfind+0x19>
		if (*s == c)
			break;
	return (char *) s;
}
  800982:	5b                   	pop    %ebx
  800983:	5d                   	pop    %ebp
  800984:	c3                   	ret    

00800985 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800985:	55                   	push   %ebp
  800986:	89 e5                	mov    %esp,%ebp
  800988:	83 ec 0c             	sub    $0xc,%esp
  80098b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80098e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800991:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800994:	8b 7d 08             	mov    0x8(%ebp),%edi
  800997:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80099a:	85 c9                	test   %ecx,%ecx
  80099c:	74 36                	je     8009d4 <memset+0x4f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80099e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009a4:	75 28                	jne    8009ce <memset+0x49>
  8009a6:	f6 c1 03             	test   $0x3,%cl
  8009a9:	75 23                	jne    8009ce <memset+0x49>
		c &= 0xFF;
  8009ab:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009af:	89 d3                	mov    %edx,%ebx
  8009b1:	c1 e3 08             	shl    $0x8,%ebx
  8009b4:	89 d6                	mov    %edx,%esi
  8009b6:	c1 e6 18             	shl    $0x18,%esi
  8009b9:	89 d0                	mov    %edx,%eax
  8009bb:	c1 e0 10             	shl    $0x10,%eax
  8009be:	09 f0                	or     %esi,%eax
  8009c0:	09 c2                	or     %eax,%edx
  8009c2:	89 d0                	mov    %edx,%eax
  8009c4:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009c6:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009c9:	fc                   	cld    
  8009ca:	f3 ab                	rep stos %eax,%es:(%edi)
  8009cc:	eb 06                	jmp    8009d4 <memset+0x4f>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d1:	fc                   	cld    
  8009d2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");

	return v;
}
  8009d4:	89 f8                	mov    %edi,%eax
  8009d6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8009d9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8009dc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8009df:	89 ec                	mov    %ebp,%esp
  8009e1:	5d                   	pop    %ebp
  8009e2:	c3                   	ret    

008009e3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009e3:	55                   	push   %ebp
  8009e4:	89 e5                	mov    %esp,%ebp
  8009e6:	83 ec 08             	sub    $0x8,%esp
  8009e9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8009ec:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8009ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009f5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009f8:	39 c6                	cmp    %eax,%esi
  8009fa:	73 36                	jae    800a32 <memmove+0x4f>
  8009fc:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009ff:	39 d0                	cmp    %edx,%eax
  800a01:	73 2f                	jae    800a32 <memmove+0x4f>
		s += n;
		d += n;
  800a03:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a06:	f6 c2 03             	test   $0x3,%dl
  800a09:	75 1b                	jne    800a26 <memmove+0x43>
  800a0b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a11:	75 13                	jne    800a26 <memmove+0x43>
  800a13:	f6 c1 03             	test   $0x3,%cl
  800a16:	75 0e                	jne    800a26 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a18:	83 ef 04             	sub    $0x4,%edi
  800a1b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a1e:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a21:	fd                   	std    
  800a22:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a24:	eb 09                	jmp    800a2f <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a26:	83 ef 01             	sub    $0x1,%edi
  800a29:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a2c:	fd                   	std    
  800a2d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a2f:	fc                   	cld    
  800a30:	eb 20                	jmp    800a52 <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a32:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a38:	75 13                	jne    800a4d <memmove+0x6a>
  800a3a:	a8 03                	test   $0x3,%al
  800a3c:	75 0f                	jne    800a4d <memmove+0x6a>
  800a3e:	f6 c1 03             	test   $0x3,%cl
  800a41:	75 0a                	jne    800a4d <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a43:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a46:	89 c7                	mov    %eax,%edi
  800a48:	fc                   	cld    
  800a49:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a4b:	eb 05                	jmp    800a52 <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a4d:	89 c7                	mov    %eax,%edi
  800a4f:	fc                   	cld    
  800a50:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a52:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800a55:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800a58:	89 ec                	mov    %ebp,%esp
  800a5a:	5d                   	pop    %ebp
  800a5b:	c3                   	ret    

00800a5c <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800a5c:	55                   	push   %ebp
  800a5d:	89 e5                	mov    %esp,%ebp
  800a5f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a62:	8b 45 10             	mov    0x10(%ebp),%eax
  800a65:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a69:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a6c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a70:	8b 45 08             	mov    0x8(%ebp),%eax
  800a73:	89 04 24             	mov    %eax,(%esp)
  800a76:	e8 68 ff ff ff       	call   8009e3 <memmove>
}
  800a7b:	c9                   	leave  
  800a7c:	c3                   	ret    

00800a7d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a7d:	55                   	push   %ebp
  800a7e:	89 e5                	mov    %esp,%ebp
  800a80:	57                   	push   %edi
  800a81:	56                   	push   %esi
  800a82:	53                   	push   %ebx
  800a83:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a86:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a89:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a8c:	8d 78 ff             	lea    -0x1(%eax),%edi
  800a8f:	85 c0                	test   %eax,%eax
  800a91:	74 36                	je     800ac9 <memcmp+0x4c>
		if (*s1 != *s2)
  800a93:	0f b6 03             	movzbl (%ebx),%eax
  800a96:	0f b6 0e             	movzbl (%esi),%ecx
  800a99:	38 c8                	cmp    %cl,%al
  800a9b:	75 17                	jne    800ab4 <memcmp+0x37>
  800a9d:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa2:	eb 1a                	jmp    800abe <memcmp+0x41>
  800aa4:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800aa9:	83 c2 01             	add    $0x1,%edx
  800aac:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800ab0:	38 c8                	cmp    %cl,%al
  800ab2:	74 0a                	je     800abe <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800ab4:	0f b6 c0             	movzbl %al,%eax
  800ab7:	0f b6 c9             	movzbl %cl,%ecx
  800aba:	29 c8                	sub    %ecx,%eax
  800abc:	eb 10                	jmp    800ace <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800abe:	39 fa                	cmp    %edi,%edx
  800ac0:	75 e2                	jne    800aa4 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ac2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac7:	eb 05                	jmp    800ace <memcmp+0x51>
  800ac9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ace:	5b                   	pop    %ebx
  800acf:	5e                   	pop    %esi
  800ad0:	5f                   	pop    %edi
  800ad1:	5d                   	pop    %ebp
  800ad2:	c3                   	ret    

00800ad3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ad3:	55                   	push   %ebp
  800ad4:	89 e5                	mov    %esp,%ebp
  800ad6:	53                   	push   %ebx
  800ad7:	8b 45 08             	mov    0x8(%ebp),%eax
  800ada:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800add:	89 c2                	mov    %eax,%edx
  800adf:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ae2:	39 d0                	cmp    %edx,%eax
  800ae4:	73 13                	jae    800af9 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ae6:	89 d9                	mov    %ebx,%ecx
  800ae8:	38 18                	cmp    %bl,(%eax)
  800aea:	75 06                	jne    800af2 <memfind+0x1f>
  800aec:	eb 0b                	jmp    800af9 <memfind+0x26>
  800aee:	38 08                	cmp    %cl,(%eax)
  800af0:	74 07                	je     800af9 <memfind+0x26>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800af2:	83 c0 01             	add    $0x1,%eax
  800af5:	39 d0                	cmp    %edx,%eax
  800af7:	75 f5                	jne    800aee <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800af9:	5b                   	pop    %ebx
  800afa:	5d                   	pop    %ebp
  800afb:	c3                   	ret    

00800afc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800afc:	55                   	push   %ebp
  800afd:	89 e5                	mov    %esp,%ebp
  800aff:	57                   	push   %edi
  800b00:	56                   	push   %esi
  800b01:	53                   	push   %ebx
  800b02:	83 ec 04             	sub    $0x4,%esp
  800b05:	8b 55 08             	mov    0x8(%ebp),%edx
  800b08:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b0b:	0f b6 02             	movzbl (%edx),%eax
  800b0e:	3c 09                	cmp    $0x9,%al
  800b10:	74 04                	je     800b16 <strtol+0x1a>
  800b12:	3c 20                	cmp    $0x20,%al
  800b14:	75 0e                	jne    800b24 <strtol+0x28>
		s++;
  800b16:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b19:	0f b6 02             	movzbl (%edx),%eax
  800b1c:	3c 09                	cmp    $0x9,%al
  800b1e:	74 f6                	je     800b16 <strtol+0x1a>
  800b20:	3c 20                	cmp    $0x20,%al
  800b22:	74 f2                	je     800b16 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b24:	3c 2b                	cmp    $0x2b,%al
  800b26:	75 0a                	jne    800b32 <strtol+0x36>
		s++;
  800b28:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b2b:	bf 00 00 00 00       	mov    $0x0,%edi
  800b30:	eb 10                	jmp    800b42 <strtol+0x46>
  800b32:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b37:	3c 2d                	cmp    $0x2d,%al
  800b39:	75 07                	jne    800b42 <strtol+0x46>
		s++, neg = 1;
  800b3b:	83 c2 01             	add    $0x1,%edx
  800b3e:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b42:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b48:	75 15                	jne    800b5f <strtol+0x63>
  800b4a:	80 3a 30             	cmpb   $0x30,(%edx)
  800b4d:	75 10                	jne    800b5f <strtol+0x63>
  800b4f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b53:	75 0a                	jne    800b5f <strtol+0x63>
		s += 2, base = 16;
  800b55:	83 c2 02             	add    $0x2,%edx
  800b58:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b5d:	eb 10                	jmp    800b6f <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800b5f:	85 db                	test   %ebx,%ebx
  800b61:	75 0c                	jne    800b6f <strtol+0x73>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b63:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b65:	80 3a 30             	cmpb   $0x30,(%edx)
  800b68:	75 05                	jne    800b6f <strtol+0x73>
		s++, base = 8;
  800b6a:	83 c2 01             	add    $0x1,%edx
  800b6d:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800b6f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b74:	89 5d f0             	mov    %ebx,-0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b77:	0f b6 0a             	movzbl (%edx),%ecx
  800b7a:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800b7d:	89 f3                	mov    %esi,%ebx
  800b7f:	80 fb 09             	cmp    $0x9,%bl
  800b82:	77 08                	ja     800b8c <strtol+0x90>
			dig = *s - '0';
  800b84:	0f be c9             	movsbl %cl,%ecx
  800b87:	83 e9 30             	sub    $0x30,%ecx
  800b8a:	eb 22                	jmp    800bae <strtol+0xb2>
		else if (*s >= 'a' && *s <= 'z')
  800b8c:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800b8f:	89 f3                	mov    %esi,%ebx
  800b91:	80 fb 19             	cmp    $0x19,%bl
  800b94:	77 08                	ja     800b9e <strtol+0xa2>
			dig = *s - 'a' + 10;
  800b96:	0f be c9             	movsbl %cl,%ecx
  800b99:	83 e9 57             	sub    $0x57,%ecx
  800b9c:	eb 10                	jmp    800bae <strtol+0xb2>
		else if (*s >= 'A' && *s <= 'Z')
  800b9e:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800ba1:	89 f3                	mov    %esi,%ebx
  800ba3:	80 fb 19             	cmp    $0x19,%bl
  800ba6:	77 16                	ja     800bbe <strtol+0xc2>
			dig = *s - 'A' + 10;
  800ba8:	0f be c9             	movsbl %cl,%ecx
  800bab:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bae:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800bb1:	7d 0f                	jge    800bc2 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800bb3:	83 c2 01             	add    $0x1,%edx
  800bb6:	0f af 45 f0          	imul   -0x10(%ebp),%eax
  800bba:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800bbc:	eb b9                	jmp    800b77 <strtol+0x7b>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800bbe:	89 c1                	mov    %eax,%ecx
  800bc0:	eb 02                	jmp    800bc4 <strtol+0xc8>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bc2:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800bc4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bc8:	74 05                	je     800bcf <strtol+0xd3>
		*endptr = (char *) s;
  800bca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bcd:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800bcf:	89 ca                	mov    %ecx,%edx
  800bd1:	f7 da                	neg    %edx
  800bd3:	85 ff                	test   %edi,%edi
  800bd5:	0f 45 c2             	cmovne %edx,%eax
}
  800bd8:	83 c4 04             	add    $0x4,%esp
  800bdb:	5b                   	pop    %ebx
  800bdc:	5e                   	pop    %esi
  800bdd:	5f                   	pop    %edi
  800bde:	5d                   	pop    %ebp
  800bdf:	c3                   	ret    

00800be0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800be0:	55                   	push   %ebp
  800be1:	89 e5                	mov    %esp,%ebp
  800be3:	83 ec 0c             	sub    $0xc,%esp
  800be6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800be9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800bec:	89 7d fc             	mov    %edi,-0x4(%ebp)
static inline uint32_t

get_cpu_features(void)
{
	uint32_t feature;
	__asm __volatile(" movl $1, %%eax\n\t"
  800bef:	b8 01 00 00 00       	mov    $0x1,%eax
  800bf4:	0f a2                	cpuid  
  800bf6:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf8:	b8 00 00 00 00       	mov    $0x0,%eax
  800bfd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c00:	8b 55 08             	mov    0x8(%ebp),%edx
  800c03:	89 c3                	mov    %eax,%ebx
  800c05:	89 c7                	mov    %eax,%edi
  800c07:	89 c6                	mov    %eax,%esi
  800c09:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c0b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c0e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c11:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c14:	89 ec                	mov    %ebp,%esp
  800c16:	5d                   	pop    %ebp
  800c17:	c3                   	ret    

00800c18 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c18:	55                   	push   %ebp
  800c19:	89 e5                	mov    %esp,%ebp
  800c1b:	83 ec 0c             	sub    $0xc,%esp
  800c1e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c21:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c24:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800c27:	b8 01 00 00 00       	mov    $0x1,%eax
  800c2c:	0f a2                	cpuid  
  800c2e:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c30:	ba 00 00 00 00       	mov    $0x0,%edx
  800c35:	b8 01 00 00 00       	mov    $0x1,%eax
  800c3a:	89 d1                	mov    %edx,%ecx
  800c3c:	89 d3                	mov    %edx,%ebx
  800c3e:	89 d7                	mov    %edx,%edi
  800c40:	89 d6                	mov    %edx,%esi
  800c42:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c44:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c47:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c4a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c4d:	89 ec                	mov    %ebp,%esp
  800c4f:	5d                   	pop    %ebp
  800c50:	c3                   	ret    

00800c51 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c51:	55                   	push   %ebp
  800c52:	89 e5                	mov    %esp,%ebp
  800c54:	83 ec 38             	sub    $0x38,%esp
  800c57:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c5a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c5d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800c60:	b8 01 00 00 00       	mov    $0x1,%eax
  800c65:	0f a2                	cpuid  
  800c67:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c69:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c6e:	b8 03 00 00 00       	mov    $0x3,%eax
  800c73:	8b 55 08             	mov    0x8(%ebp),%edx
  800c76:	89 cb                	mov    %ecx,%ebx
  800c78:	89 cf                	mov    %ecx,%edi
  800c7a:	89 ce                	mov    %ecx,%esi
  800c7c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c7e:	85 c0                	test   %eax,%eax
  800c80:	7e 28                	jle    800caa <sys_env_destroy+0x59>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c82:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c86:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c8d:	00 
  800c8e:	c7 44 24 08 bf 1f 80 	movl   $0x801fbf,0x8(%esp)
  800c95:	00 
  800c96:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800c9d:	00 
  800c9e:	c7 04 24 dc 1f 80 00 	movl   $0x801fdc,(%esp)
  800ca5:	e8 96 0b 00 00       	call   801840 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800caa:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cad:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cb0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cb3:	89 ec                	mov    %ebp,%esp
  800cb5:	5d                   	pop    %ebp
  800cb6:	c3                   	ret    

00800cb7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cb7:	55                   	push   %ebp
  800cb8:	89 e5                	mov    %esp,%ebp
  800cba:	83 ec 0c             	sub    $0xc,%esp
  800cbd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cc0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cc3:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800cc6:	b8 01 00 00 00       	mov    $0x1,%eax
  800ccb:	0f a2                	cpuid  
  800ccd:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccf:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd4:	b8 02 00 00 00       	mov    $0x2,%eax
  800cd9:	89 d1                	mov    %edx,%ecx
  800cdb:	89 d3                	mov    %edx,%ebx
  800cdd:	89 d7                	mov    %edx,%edi
  800cdf:	89 d6                	mov    %edx,%esi
  800ce1:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ce3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ce6:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ce9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cec:	89 ec                	mov    %ebp,%esp
  800cee:	5d                   	pop    %ebp
  800cef:	c3                   	ret    

00800cf0 <sys_yield>:

void
sys_yield(void)
{
  800cf0:	55                   	push   %ebp
  800cf1:	89 e5                	mov    %esp,%ebp
  800cf3:	83 ec 0c             	sub    $0xc,%esp
  800cf6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cf9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cfc:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800cff:	b8 01 00 00 00       	mov    $0x1,%eax
  800d04:	0f a2                	cpuid  
  800d06:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d08:	ba 00 00 00 00       	mov    $0x0,%edx
  800d0d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d12:	89 d1                	mov    %edx,%ecx
  800d14:	89 d3                	mov    %edx,%ebx
  800d16:	89 d7                	mov    %edx,%edi
  800d18:	89 d6                	mov    %edx,%esi
  800d1a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d1c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d1f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d22:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d25:	89 ec                	mov    %ebp,%esp
  800d27:	5d                   	pop    %ebp
  800d28:	c3                   	ret    

00800d29 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d29:	55                   	push   %ebp
  800d2a:	89 e5                	mov    %esp,%ebp
  800d2c:	83 ec 38             	sub    $0x38,%esp
  800d2f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d32:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d35:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d38:	b8 01 00 00 00       	mov    $0x1,%eax
  800d3d:	0f a2                	cpuid  
  800d3f:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d41:	be 00 00 00 00       	mov    $0x0,%esi
  800d46:	b8 04 00 00 00       	mov    $0x4,%eax
  800d4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d51:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d54:	89 f7                	mov    %esi,%edi
  800d56:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d58:	85 c0                	test   %eax,%eax
  800d5a:	7e 28                	jle    800d84 <sys_page_alloc+0x5b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d60:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d67:	00 
  800d68:	c7 44 24 08 bf 1f 80 	movl   $0x801fbf,0x8(%esp)
  800d6f:	00 
  800d70:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800d77:	00 
  800d78:	c7 04 24 dc 1f 80 00 	movl   $0x801fdc,(%esp)
  800d7f:	e8 bc 0a 00 00       	call   801840 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d84:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d87:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d8a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d8d:	89 ec                	mov    %ebp,%esp
  800d8f:	5d                   	pop    %ebp
  800d90:	c3                   	ret    

00800d91 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d91:	55                   	push   %ebp
  800d92:	89 e5                	mov    %esp,%ebp
  800d94:	83 ec 38             	sub    $0x38,%esp
  800d97:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d9a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d9d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800da0:	b8 01 00 00 00       	mov    $0x1,%eax
  800da5:	0f a2                	cpuid  
  800da7:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da9:	b8 05 00 00 00       	mov    $0x5,%eax
  800dae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db1:	8b 55 08             	mov    0x8(%ebp),%edx
  800db4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800db7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dba:	8b 75 18             	mov    0x18(%ebp),%esi
  800dbd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dbf:	85 c0                	test   %eax,%eax
  800dc1:	7e 28                	jle    800deb <sys_page_map+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dc7:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800dce:	00 
  800dcf:	c7 44 24 08 bf 1f 80 	movl   $0x801fbf,0x8(%esp)
  800dd6:	00 
  800dd7:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800dde:	00 
  800ddf:	c7 04 24 dc 1f 80 00 	movl   $0x801fdc,(%esp)
  800de6:	e8 55 0a 00 00       	call   801840 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800deb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dee:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800df1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800df4:	89 ec                	mov    %ebp,%esp
  800df6:	5d                   	pop    %ebp
  800df7:	c3                   	ret    

00800df8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800df8:	55                   	push   %ebp
  800df9:	89 e5                	mov    %esp,%ebp
  800dfb:	83 ec 38             	sub    $0x38,%esp
  800dfe:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e01:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e04:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e07:	b8 01 00 00 00       	mov    $0x1,%eax
  800e0c:	0f a2                	cpuid  
  800e0e:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e10:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e15:	b8 06 00 00 00       	mov    $0x6,%eax
  800e1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e20:	89 df                	mov    %ebx,%edi
  800e22:	89 de                	mov    %ebx,%esi
  800e24:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e26:	85 c0                	test   %eax,%eax
  800e28:	7e 28                	jle    800e52 <sys_page_unmap+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e2e:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e35:	00 
  800e36:	c7 44 24 08 bf 1f 80 	movl   $0x801fbf,0x8(%esp)
  800e3d:	00 
  800e3e:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800e45:	00 
  800e46:	c7 04 24 dc 1f 80 00 	movl   $0x801fdc,(%esp)
  800e4d:	e8 ee 09 00 00       	call   801840 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e52:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e55:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e58:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e5b:	89 ec                	mov    %ebp,%esp
  800e5d:	5d                   	pop    %ebp
  800e5e:	c3                   	ret    

00800e5f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e5f:	55                   	push   %ebp
  800e60:	89 e5                	mov    %esp,%ebp
  800e62:	83 ec 38             	sub    $0x38,%esp
  800e65:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e68:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e6b:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e6e:	b8 01 00 00 00       	mov    $0x1,%eax
  800e73:	0f a2                	cpuid  
  800e75:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e77:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e7c:	b8 08 00 00 00       	mov    $0x8,%eax
  800e81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e84:	8b 55 08             	mov    0x8(%ebp),%edx
  800e87:	89 df                	mov    %ebx,%edi
  800e89:	89 de                	mov    %ebx,%esi
  800e8b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e8d:	85 c0                	test   %eax,%eax
  800e8f:	7e 28                	jle    800eb9 <sys_env_set_status+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e91:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e95:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e9c:	00 
  800e9d:	c7 44 24 08 bf 1f 80 	movl   $0x801fbf,0x8(%esp)
  800ea4:	00 
  800ea5:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800eac:	00 
  800ead:	c7 04 24 dc 1f 80 00 	movl   $0x801fdc,(%esp)
  800eb4:	e8 87 09 00 00       	call   801840 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800eb9:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ebc:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ebf:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ec2:	89 ec                	mov    %ebp,%esp
  800ec4:	5d                   	pop    %ebp
  800ec5:	c3                   	ret    

00800ec6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ec6:	55                   	push   %ebp
  800ec7:	89 e5                	mov    %esp,%ebp
  800ec9:	83 ec 38             	sub    $0x38,%esp
  800ecc:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ecf:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ed2:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800ed5:	b8 01 00 00 00       	mov    $0x1,%eax
  800eda:	0f a2                	cpuid  
  800edc:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ede:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ee3:	b8 09 00 00 00       	mov    $0x9,%eax
  800ee8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eeb:	8b 55 08             	mov    0x8(%ebp),%edx
  800eee:	89 df                	mov    %ebx,%edi
  800ef0:	89 de                	mov    %ebx,%esi
  800ef2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ef4:	85 c0                	test   %eax,%eax
  800ef6:	7e 28                	jle    800f20 <sys_env_set_trapframe+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ef8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800efc:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f03:	00 
  800f04:	c7 44 24 08 bf 1f 80 	movl   $0x801fbf,0x8(%esp)
  800f0b:	00 
  800f0c:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800f13:	00 
  800f14:	c7 04 24 dc 1f 80 00 	movl   $0x801fdc,(%esp)
  800f1b:	e8 20 09 00 00       	call   801840 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f20:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f23:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f26:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f29:	89 ec                	mov    %ebp,%esp
  800f2b:	5d                   	pop    %ebp
  800f2c:	c3                   	ret    

00800f2d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f2d:	55                   	push   %ebp
  800f2e:	89 e5                	mov    %esp,%ebp
  800f30:	83 ec 38             	sub    $0x38,%esp
  800f33:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f36:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f39:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800f3c:	b8 01 00 00 00       	mov    $0x1,%eax
  800f41:	0f a2                	cpuid  
  800f43:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f45:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f4a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f52:	8b 55 08             	mov    0x8(%ebp),%edx
  800f55:	89 df                	mov    %ebx,%edi
  800f57:	89 de                	mov    %ebx,%esi
  800f59:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f5b:	85 c0                	test   %eax,%eax
  800f5d:	7e 28                	jle    800f87 <sys_env_set_pgfault_upcall+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f5f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f63:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800f6a:	00 
  800f6b:	c7 44 24 08 bf 1f 80 	movl   $0x801fbf,0x8(%esp)
  800f72:	00 
  800f73:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800f7a:	00 
  800f7b:	c7 04 24 dc 1f 80 00 	movl   $0x801fdc,(%esp)
  800f82:	e8 b9 08 00 00       	call   801840 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f87:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f8a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f8d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f90:	89 ec                	mov    %ebp,%esp
  800f92:	5d                   	pop    %ebp
  800f93:	c3                   	ret    

00800f94 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f94:	55                   	push   %ebp
  800f95:	89 e5                	mov    %esp,%ebp
  800f97:	83 ec 0c             	sub    $0xc,%esp
  800f9a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f9d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fa0:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800fa3:	b8 01 00 00 00       	mov    $0x1,%eax
  800fa8:	0f a2                	cpuid  
  800faa:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fac:	be 00 00 00 00       	mov    $0x0,%esi
  800fb1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800fbc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fbf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fc2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800fc4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fc7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fca:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fcd:	89 ec                	mov    %ebp,%esp
  800fcf:	5d                   	pop    %ebp
  800fd0:	c3                   	ret    

00800fd1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800fd1:	55                   	push   %ebp
  800fd2:	89 e5                	mov    %esp,%ebp
  800fd4:	83 ec 38             	sub    $0x38,%esp
  800fd7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fda:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fdd:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800fe0:	b8 01 00 00 00       	mov    $0x1,%eax
  800fe5:	0f a2                	cpuid  
  800fe7:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fe9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fee:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ff3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff6:	89 cb                	mov    %ecx,%ebx
  800ff8:	89 cf                	mov    %ecx,%edi
  800ffa:	89 ce                	mov    %ecx,%esi
  800ffc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ffe:	85 c0                	test   %eax,%eax
  801000:	7e 28                	jle    80102a <sys_ipc_recv+0x59>
		panic("syscall %d returned %d (> 0)", num, ret);
  801002:	89 44 24 10          	mov    %eax,0x10(%esp)
  801006:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  80100d:	00 
  80100e:	c7 44 24 08 bf 1f 80 	movl   $0x801fbf,0x8(%esp)
  801015:	00 
  801016:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  80101d:	00 
  80101e:	c7 04 24 dc 1f 80 00 	movl   $0x801fdc,(%esp)
  801025:	e8 16 08 00 00       	call   801840 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80102a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80102d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801030:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801033:	89 ec                	mov    %ebp,%esp
  801035:	5d                   	pop    %ebp
  801036:	c3                   	ret    
  801037:	66 90                	xchg   %ax,%ax
  801039:	66 90                	xchg   %ax,%ax
  80103b:	66 90                	xchg   %ax,%ax
  80103d:	66 90                	xchg   %ax,%ax
  80103f:	90                   	nop

00801040 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801040:	55                   	push   %ebp
  801041:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801043:	8b 45 08             	mov    0x8(%ebp),%eax
  801046:	05 00 00 00 30       	add    $0x30000000,%eax
  80104b:	c1 e8 0c             	shr    $0xc,%eax
}
  80104e:	5d                   	pop    %ebp
  80104f:	c3                   	ret    

00801050 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801050:	55                   	push   %ebp
  801051:	89 e5                	mov    %esp,%ebp
  801053:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801056:	8b 45 08             	mov    0x8(%ebp),%eax
  801059:	89 04 24             	mov    %eax,(%esp)
  80105c:	e8 df ff ff ff       	call   801040 <fd2num>
  801061:	c1 e0 0c             	shl    $0xc,%eax
  801064:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801069:	c9                   	leave  
  80106a:	c3                   	ret    

0080106b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80106b:	55                   	push   %ebp
  80106c:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  80106e:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801073:	a8 01                	test   $0x1,%al
  801075:	74 34                	je     8010ab <fd_alloc+0x40>
  801077:	a1 00 00 74 ef       	mov    0xef740000,%eax
  80107c:	a8 01                	test   $0x1,%al
  80107e:	74 32                	je     8010b2 <fd_alloc+0x47>
  801080:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801085:	89 c1                	mov    %eax,%ecx
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801087:	89 c2                	mov    %eax,%edx
  801089:	c1 ea 16             	shr    $0x16,%edx
  80108c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801093:	f6 c2 01             	test   $0x1,%dl
  801096:	74 1f                	je     8010b7 <fd_alloc+0x4c>
  801098:	89 c2                	mov    %eax,%edx
  80109a:	c1 ea 0c             	shr    $0xc,%edx
  80109d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010a4:	f6 c2 01             	test   $0x1,%dl
  8010a7:	75 1a                	jne    8010c3 <fd_alloc+0x58>
  8010a9:	eb 0c                	jmp    8010b7 <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8010ab:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8010b0:	eb 05                	jmp    8010b7 <fd_alloc+0x4c>
  8010b2:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8010b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ba:	89 08                	mov    %ecx,(%eax)
			return 0;
  8010bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8010c1:	eb 1a                	jmp    8010dd <fd_alloc+0x72>
  8010c3:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010c8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010cd:	75 b6                	jne    801085 <fd_alloc+0x1a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  8010d8:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010dd:	5d                   	pop    %ebp
  8010de:	c3                   	ret    

008010df <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010df:	55                   	push   %ebp
  8010e0:	89 e5                	mov    %esp,%ebp
  8010e2:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010e5:	83 f8 1f             	cmp    $0x1f,%eax
  8010e8:	77 36                	ja     801120 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010ea:	c1 e0 0c             	shl    $0xc,%eax
  8010ed:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  8010f2:	89 c2                	mov    %eax,%edx
  8010f4:	c1 ea 16             	shr    $0x16,%edx
  8010f7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010fe:	f6 c2 01             	test   $0x1,%dl
  801101:	74 24                	je     801127 <fd_lookup+0x48>
  801103:	89 c2                	mov    %eax,%edx
  801105:	c1 ea 0c             	shr    $0xc,%edx
  801108:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80110f:	f6 c2 01             	test   $0x1,%dl
  801112:	74 1a                	je     80112e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801114:	8b 55 0c             	mov    0xc(%ebp),%edx
  801117:	89 02                	mov    %eax,(%edx)
	return 0;
  801119:	b8 00 00 00 00       	mov    $0x0,%eax
  80111e:	eb 13                	jmp    801133 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  801120:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801125:	eb 0c                	jmp    801133 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  801127:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80112c:	eb 05                	jmp    801133 <fd_lookup+0x54>
  80112e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801133:	5d                   	pop    %ebp
  801134:	c3                   	ret    

00801135 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801135:	55                   	push   %ebp
  801136:	89 e5                	mov    %esp,%ebp
  801138:	83 ec 18             	sub    $0x18,%esp
  80113b:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80113e:	39 05 04 30 80 00    	cmp    %eax,0x803004
  801144:	75 10                	jne    801156 <dev_lookup+0x21>
			*dev = devtab[i];
  801146:	8b 45 0c             	mov    0xc(%ebp),%eax
  801149:	c7 00 04 30 80 00    	movl   $0x803004,(%eax)
			return 0;
  80114f:	b8 00 00 00 00       	mov    $0x0,%eax
  801154:	eb 2b                	jmp    801181 <dev_lookup+0x4c>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801156:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80115c:	8b 52 48             	mov    0x48(%edx),%edx
  80115f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801163:	89 54 24 04          	mov    %edx,0x4(%esp)
  801167:	c7 04 24 ec 1f 80 00 	movl   $0x801fec,(%esp)
  80116e:	e8 f0 ef ff ff       	call   800163 <cprintf>
	*dev = 0;
  801173:	8b 55 0c             	mov    0xc(%ebp),%edx
  801176:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	return -E_INVAL;
  80117c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801181:	c9                   	leave  
  801182:	c3                   	ret    

00801183 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801183:	55                   	push   %ebp
  801184:	89 e5                	mov    %esp,%ebp
  801186:	83 ec 38             	sub    $0x38,%esp
  801189:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80118c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80118f:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801192:	8b 7d 08             	mov    0x8(%ebp),%edi
  801195:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801198:	89 3c 24             	mov    %edi,(%esp)
  80119b:	e8 a0 fe ff ff       	call   801040 <fd2num>
  8011a0:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8011a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8011a7:	89 04 24             	mov    %eax,(%esp)
  8011aa:	e8 30 ff ff ff       	call   8010df <fd_lookup>
  8011af:	89 c3                	mov    %eax,%ebx
  8011b1:	85 c0                	test   %eax,%eax
  8011b3:	78 05                	js     8011ba <fd_close+0x37>
	    || fd != fd2)
  8011b5:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  8011b8:	74 0c                	je     8011c6 <fd_close+0x43>
		return (must_exist ? r : 0);
  8011ba:	85 f6                	test   %esi,%esi
  8011bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8011c1:	0f 44 d8             	cmove  %eax,%ebx
  8011c4:	eb 3d                	jmp    801203 <fd_close+0x80>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011c6:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8011c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011cd:	8b 07                	mov    (%edi),%eax
  8011cf:	89 04 24             	mov    %eax,(%esp)
  8011d2:	e8 5e ff ff ff       	call   801135 <dev_lookup>
  8011d7:	89 c3                	mov    %eax,%ebx
  8011d9:	85 c0                	test   %eax,%eax
  8011db:	78 16                	js     8011f3 <fd_close+0x70>
		if (dev->dev_close)
  8011dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8011e0:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8011e3:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8011e8:	85 c0                	test   %eax,%eax
  8011ea:	74 07                	je     8011f3 <fd_close+0x70>
			r = (*dev->dev_close)(fd);
  8011ec:	89 3c 24             	mov    %edi,(%esp)
  8011ef:	ff d0                	call   *%eax
  8011f1:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011f3:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011f7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011fe:	e8 f5 fb ff ff       	call   800df8 <sys_page_unmap>
	return r;
}
  801203:	89 d8                	mov    %ebx,%eax
  801205:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801208:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80120b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80120e:	89 ec                	mov    %ebp,%esp
  801210:	5d                   	pop    %ebp
  801211:	c3                   	ret    

00801212 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801212:	55                   	push   %ebp
  801213:	89 e5                	mov    %esp,%ebp
  801215:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801218:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80121b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80121f:	8b 45 08             	mov    0x8(%ebp),%eax
  801222:	89 04 24             	mov    %eax,(%esp)
  801225:	e8 b5 fe ff ff       	call   8010df <fd_lookup>
  80122a:	85 c0                	test   %eax,%eax
  80122c:	78 13                	js     801241 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80122e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801235:	00 
  801236:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801239:	89 04 24             	mov    %eax,(%esp)
  80123c:	e8 42 ff ff ff       	call   801183 <fd_close>
}
  801241:	c9                   	leave  
  801242:	c3                   	ret    

00801243 <close_all>:

void
close_all(void)
{
  801243:	55                   	push   %ebp
  801244:	89 e5                	mov    %esp,%ebp
  801246:	53                   	push   %ebx
  801247:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80124a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80124f:	89 1c 24             	mov    %ebx,(%esp)
  801252:	e8 bb ff ff ff       	call   801212 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801257:	83 c3 01             	add    $0x1,%ebx
  80125a:	83 fb 20             	cmp    $0x20,%ebx
  80125d:	75 f0                	jne    80124f <close_all+0xc>
		close(i);
}
  80125f:	83 c4 14             	add    $0x14,%esp
  801262:	5b                   	pop    %ebx
  801263:	5d                   	pop    %ebp
  801264:	c3                   	ret    

00801265 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801265:	55                   	push   %ebp
  801266:	89 e5                	mov    %esp,%ebp
  801268:	83 ec 58             	sub    $0x58,%esp
  80126b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80126e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801271:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801274:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801277:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80127a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80127e:	8b 45 08             	mov    0x8(%ebp),%eax
  801281:	89 04 24             	mov    %eax,(%esp)
  801284:	e8 56 fe ff ff       	call   8010df <fd_lookup>
  801289:	85 c0                	test   %eax,%eax
  80128b:	0f 88 e3 00 00 00    	js     801374 <dup+0x10f>
		return r;
	close(newfdnum);
  801291:	89 1c 24             	mov    %ebx,(%esp)
  801294:	e8 79 ff ff ff       	call   801212 <close>

	newfd = INDEX2FD(newfdnum);
  801299:	89 de                	mov    %ebx,%esi
  80129b:	c1 e6 0c             	shl    $0xc,%esi
  80129e:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8012a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012a7:	89 04 24             	mov    %eax,(%esp)
  8012aa:	e8 a1 fd ff ff       	call   801050 <fd2data>
  8012af:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8012b1:	89 34 24             	mov    %esi,(%esp)
  8012b4:	e8 97 fd ff ff       	call   801050 <fd2data>
  8012b9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  8012bc:	89 f8                	mov    %edi,%eax
  8012be:	c1 e8 16             	shr    $0x16,%eax
  8012c1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012c8:	a8 01                	test   $0x1,%al
  8012ca:	74 46                	je     801312 <dup+0xad>
  8012cc:	89 f8                	mov    %edi,%eax
  8012ce:	c1 e8 0c             	shr    $0xc,%eax
  8012d1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012d8:	f6 c2 01             	test   $0x1,%dl
  8012db:	74 35                	je     801312 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012dd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012e4:	25 07 0e 00 00       	and    $0xe07,%eax
  8012e9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012ed:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8012f0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012f4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012fb:	00 
  8012fc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801300:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801307:	e8 85 fa ff ff       	call   800d91 <sys_page_map>
  80130c:	89 c7                	mov    %eax,%edi
  80130e:	85 c0                	test   %eax,%eax
  801310:	78 3b                	js     80134d <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801312:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801315:	89 c2                	mov    %eax,%edx
  801317:	c1 ea 0c             	shr    $0xc,%edx
  80131a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801321:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801327:	89 54 24 10          	mov    %edx,0x10(%esp)
  80132b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80132f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801336:	00 
  801337:	89 44 24 04          	mov    %eax,0x4(%esp)
  80133b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801342:	e8 4a fa ff ff       	call   800d91 <sys_page_map>
  801347:	89 c7                	mov    %eax,%edi
  801349:	85 c0                	test   %eax,%eax
  80134b:	79 29                	jns    801376 <dup+0x111>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80134d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801351:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801358:	e8 9b fa ff ff       	call   800df8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80135d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801360:	89 44 24 04          	mov    %eax,0x4(%esp)
  801364:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80136b:	e8 88 fa ff ff       	call   800df8 <sys_page_unmap>
	return r;
  801370:	89 fb                	mov    %edi,%ebx
  801372:	eb 02                	jmp    801376 <dup+0x111>
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
		return r;
  801374:	89 c3                	mov    %eax,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801376:	89 d8                	mov    %ebx,%eax
  801378:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80137b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80137e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801381:	89 ec                	mov    %ebp,%esp
  801383:	5d                   	pop    %ebp
  801384:	c3                   	ret    

00801385 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801385:	55                   	push   %ebp
  801386:	89 e5                	mov    %esp,%ebp
  801388:	53                   	push   %ebx
  801389:	83 ec 24             	sub    $0x24,%esp
  80138c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80138f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801392:	89 44 24 04          	mov    %eax,0x4(%esp)
  801396:	89 1c 24             	mov    %ebx,(%esp)
  801399:	e8 41 fd ff ff       	call   8010df <fd_lookup>
  80139e:	85 c0                	test   %eax,%eax
  8013a0:	78 6d                	js     80140f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ac:	8b 00                	mov    (%eax),%eax
  8013ae:	89 04 24             	mov    %eax,(%esp)
  8013b1:	e8 7f fd ff ff       	call   801135 <dev_lookup>
  8013b6:	85 c0                	test   %eax,%eax
  8013b8:	78 55                	js     80140f <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013bd:	8b 50 08             	mov    0x8(%eax),%edx
  8013c0:	83 e2 03             	and    $0x3,%edx
  8013c3:	83 fa 01             	cmp    $0x1,%edx
  8013c6:	75 23                	jne    8013eb <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013c8:	a1 04 40 80 00       	mov    0x804004,%eax
  8013cd:	8b 40 48             	mov    0x48(%eax),%eax
  8013d0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d8:	c7 04 24 2d 20 80 00 	movl   $0x80202d,(%esp)
  8013df:	e8 7f ed ff ff       	call   800163 <cprintf>
		return -E_INVAL;
  8013e4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013e9:	eb 24                	jmp    80140f <read+0x8a>
	}
	if (!dev->dev_read)
  8013eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013ee:	8b 52 08             	mov    0x8(%edx),%edx
  8013f1:	85 d2                	test   %edx,%edx
  8013f3:	74 15                	je     80140a <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013f5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8013f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013ff:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801403:	89 04 24             	mov    %eax,(%esp)
  801406:	ff d2                	call   *%edx
  801408:	eb 05                	jmp    80140f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80140a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80140f:	83 c4 24             	add    $0x24,%esp
  801412:	5b                   	pop    %ebx
  801413:	5d                   	pop    %ebp
  801414:	c3                   	ret    

00801415 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801415:	55                   	push   %ebp
  801416:	89 e5                	mov    %esp,%ebp
  801418:	57                   	push   %edi
  801419:	56                   	push   %esi
  80141a:	53                   	push   %ebx
  80141b:	83 ec 1c             	sub    $0x1c,%esp
  80141e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801421:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801424:	85 f6                	test   %esi,%esi
  801426:	74 33                	je     80145b <readn+0x46>
  801428:	b8 00 00 00 00       	mov    $0x0,%eax
  80142d:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801432:	89 f2                	mov    %esi,%edx
  801434:	29 c2                	sub    %eax,%edx
  801436:	89 54 24 08          	mov    %edx,0x8(%esp)
  80143a:	03 45 0c             	add    0xc(%ebp),%eax
  80143d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801441:	89 3c 24             	mov    %edi,(%esp)
  801444:	e8 3c ff ff ff       	call   801385 <read>
		if (m < 0)
  801449:	85 c0                	test   %eax,%eax
  80144b:	78 17                	js     801464 <readn+0x4f>
			return m;
		if (m == 0)
  80144d:	85 c0                	test   %eax,%eax
  80144f:	74 11                	je     801462 <readn+0x4d>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801451:	01 c3                	add    %eax,%ebx
  801453:	89 d8                	mov    %ebx,%eax
  801455:	39 f3                	cmp    %esi,%ebx
  801457:	72 d9                	jb     801432 <readn+0x1d>
  801459:	eb 09                	jmp    801464 <readn+0x4f>
  80145b:	b8 00 00 00 00       	mov    $0x0,%eax
  801460:	eb 02                	jmp    801464 <readn+0x4f>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801462:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801464:	83 c4 1c             	add    $0x1c,%esp
  801467:	5b                   	pop    %ebx
  801468:	5e                   	pop    %esi
  801469:	5f                   	pop    %edi
  80146a:	5d                   	pop    %ebp
  80146b:	c3                   	ret    

0080146c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80146c:	55                   	push   %ebp
  80146d:	89 e5                	mov    %esp,%ebp
  80146f:	53                   	push   %ebx
  801470:	83 ec 24             	sub    $0x24,%esp
  801473:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801476:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801479:	89 44 24 04          	mov    %eax,0x4(%esp)
  80147d:	89 1c 24             	mov    %ebx,(%esp)
  801480:	e8 5a fc ff ff       	call   8010df <fd_lookup>
  801485:	85 c0                	test   %eax,%eax
  801487:	78 68                	js     8014f1 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801489:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80148c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801490:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801493:	8b 00                	mov    (%eax),%eax
  801495:	89 04 24             	mov    %eax,(%esp)
  801498:	e8 98 fc ff ff       	call   801135 <dev_lookup>
  80149d:	85 c0                	test   %eax,%eax
  80149f:	78 50                	js     8014f1 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014a4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014a8:	75 23                	jne    8014cd <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014aa:	a1 04 40 80 00       	mov    0x804004,%eax
  8014af:	8b 40 48             	mov    0x48(%eax),%eax
  8014b2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014ba:	c7 04 24 49 20 80 00 	movl   $0x802049,(%esp)
  8014c1:	e8 9d ec ff ff       	call   800163 <cprintf>
		return -E_INVAL;
  8014c6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014cb:	eb 24                	jmp    8014f1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014d0:	8b 52 0c             	mov    0xc(%edx),%edx
  8014d3:	85 d2                	test   %edx,%edx
  8014d5:	74 15                	je     8014ec <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014d7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8014da:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014e1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8014e5:	89 04 24             	mov    %eax,(%esp)
  8014e8:	ff d2                	call   *%edx
  8014ea:	eb 05                	jmp    8014f1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014ec:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8014f1:	83 c4 24             	add    $0x24,%esp
  8014f4:	5b                   	pop    %ebx
  8014f5:	5d                   	pop    %ebp
  8014f6:	c3                   	ret    

008014f7 <seek>:

int
seek(int fdnum, off_t offset)
{
  8014f7:	55                   	push   %ebp
  8014f8:	89 e5                	mov    %esp,%ebp
  8014fa:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014fd:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801500:	89 44 24 04          	mov    %eax,0x4(%esp)
  801504:	8b 45 08             	mov    0x8(%ebp),%eax
  801507:	89 04 24             	mov    %eax,(%esp)
  80150a:	e8 d0 fb ff ff       	call   8010df <fd_lookup>
  80150f:	85 c0                	test   %eax,%eax
  801511:	78 0e                	js     801521 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801513:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801516:	8b 55 0c             	mov    0xc(%ebp),%edx
  801519:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80151c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801521:	c9                   	leave  
  801522:	c3                   	ret    

00801523 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801523:	55                   	push   %ebp
  801524:	89 e5                	mov    %esp,%ebp
  801526:	53                   	push   %ebx
  801527:	83 ec 24             	sub    $0x24,%esp
  80152a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80152d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801530:	89 44 24 04          	mov    %eax,0x4(%esp)
  801534:	89 1c 24             	mov    %ebx,(%esp)
  801537:	e8 a3 fb ff ff       	call   8010df <fd_lookup>
  80153c:	85 c0                	test   %eax,%eax
  80153e:	78 61                	js     8015a1 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801540:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801543:	89 44 24 04          	mov    %eax,0x4(%esp)
  801547:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80154a:	8b 00                	mov    (%eax),%eax
  80154c:	89 04 24             	mov    %eax,(%esp)
  80154f:	e8 e1 fb ff ff       	call   801135 <dev_lookup>
  801554:	85 c0                	test   %eax,%eax
  801556:	78 49                	js     8015a1 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801558:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80155b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80155f:	75 23                	jne    801584 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801561:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801566:	8b 40 48             	mov    0x48(%eax),%eax
  801569:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80156d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801571:	c7 04 24 0c 20 80 00 	movl   $0x80200c,(%esp)
  801578:	e8 e6 eb ff ff       	call   800163 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80157d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801582:	eb 1d                	jmp    8015a1 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801584:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801587:	8b 52 18             	mov    0x18(%edx),%edx
  80158a:	85 d2                	test   %edx,%edx
  80158c:	74 0e                	je     80159c <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80158e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801591:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801595:	89 04 24             	mov    %eax,(%esp)
  801598:	ff d2                	call   *%edx
  80159a:	eb 05                	jmp    8015a1 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80159c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8015a1:	83 c4 24             	add    $0x24,%esp
  8015a4:	5b                   	pop    %ebx
  8015a5:	5d                   	pop    %ebp
  8015a6:	c3                   	ret    

008015a7 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015a7:	55                   	push   %ebp
  8015a8:	89 e5                	mov    %esp,%ebp
  8015aa:	53                   	push   %ebx
  8015ab:	83 ec 24             	sub    $0x24,%esp
  8015ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015b1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8015bb:	89 04 24             	mov    %eax,(%esp)
  8015be:	e8 1c fb ff ff       	call   8010df <fd_lookup>
  8015c3:	85 c0                	test   %eax,%eax
  8015c5:	78 52                	js     801619 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015c7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d1:	8b 00                	mov    (%eax),%eax
  8015d3:	89 04 24             	mov    %eax,(%esp)
  8015d6:	e8 5a fb ff ff       	call   801135 <dev_lookup>
  8015db:	85 c0                	test   %eax,%eax
  8015dd:	78 3a                	js     801619 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8015df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015e2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015e6:	74 2c                	je     801614 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015e8:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015eb:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015f2:	00 00 00 
	stat->st_isdir = 0;
  8015f5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015fc:	00 00 00 
	stat->st_dev = dev;
  8015ff:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801605:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801609:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80160c:	89 14 24             	mov    %edx,(%esp)
  80160f:	ff 50 14             	call   *0x14(%eax)
  801612:	eb 05                	jmp    801619 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801614:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801619:	83 c4 24             	add    $0x24,%esp
  80161c:	5b                   	pop    %ebx
  80161d:	5d                   	pop    %ebp
  80161e:	c3                   	ret    

0080161f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80161f:	55                   	push   %ebp
  801620:	89 e5                	mov    %esp,%ebp
  801622:	83 ec 18             	sub    $0x18,%esp
  801625:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801628:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80162b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801632:	00 
  801633:	8b 45 08             	mov    0x8(%ebp),%eax
  801636:	89 04 24             	mov    %eax,(%esp)
  801639:	e8 84 01 00 00       	call   8017c2 <open>
  80163e:	89 c3                	mov    %eax,%ebx
  801640:	85 c0                	test   %eax,%eax
  801642:	78 1b                	js     80165f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801644:	8b 45 0c             	mov    0xc(%ebp),%eax
  801647:	89 44 24 04          	mov    %eax,0x4(%esp)
  80164b:	89 1c 24             	mov    %ebx,(%esp)
  80164e:	e8 54 ff ff ff       	call   8015a7 <fstat>
  801653:	89 c6                	mov    %eax,%esi
	close(fd);
  801655:	89 1c 24             	mov    %ebx,(%esp)
  801658:	e8 b5 fb ff ff       	call   801212 <close>
	return r;
  80165d:	89 f3                	mov    %esi,%ebx
}
  80165f:	89 d8                	mov    %ebx,%eax
  801661:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801664:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801667:	89 ec                	mov    %ebp,%esp
  801669:	5d                   	pop    %ebp
  80166a:	c3                   	ret    
  80166b:	90                   	nop

0080166c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80166c:	55                   	push   %ebp
  80166d:	89 e5                	mov    %esp,%ebp
  80166f:	83 ec 18             	sub    $0x18,%esp
  801672:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801675:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801678:	89 c6                	mov    %eax,%esi
  80167a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80167c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801683:	75 11                	jne    801696 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801685:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  80168c:	e8 ca 02 00 00       	call   80195b <ipc_find_env>
  801691:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801696:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80169d:	00 
  80169e:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8016a5:	00 
  8016a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016aa:	a1 00 40 80 00       	mov    0x804000,%eax
  8016af:	89 04 24             	mov    %eax,(%esp)
  8016b2:	e8 39 02 00 00       	call   8018f0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016b7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016be:	00 
  8016bf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016c3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016ca:	e8 c9 01 00 00       	call   801898 <ipc_recv>
}
  8016cf:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8016d2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8016d5:	89 ec                	mov    %ebp,%esp
  8016d7:	5d                   	pop    %ebp
  8016d8:	c3                   	ret    

008016d9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016d9:	55                   	push   %ebp
  8016da:	89 e5                	mov    %esp,%ebp
  8016dc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016df:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e2:	8b 40 0c             	mov    0xc(%eax),%eax
  8016e5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016ed:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8016f7:	b8 02 00 00 00       	mov    $0x2,%eax
  8016fc:	e8 6b ff ff ff       	call   80166c <fsipc>
}
  801701:	c9                   	leave  
  801702:	c3                   	ret    

00801703 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801703:	55                   	push   %ebp
  801704:	89 e5                	mov    %esp,%ebp
  801706:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801709:	8b 45 08             	mov    0x8(%ebp),%eax
  80170c:	8b 40 0c             	mov    0xc(%eax),%eax
  80170f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801714:	ba 00 00 00 00       	mov    $0x0,%edx
  801719:	b8 06 00 00 00       	mov    $0x6,%eax
  80171e:	e8 49 ff ff ff       	call   80166c <fsipc>
}
  801723:	c9                   	leave  
  801724:	c3                   	ret    

00801725 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801725:	55                   	push   %ebp
  801726:	89 e5                	mov    %esp,%ebp
  801728:	53                   	push   %ebx
  801729:	83 ec 14             	sub    $0x14,%esp
  80172c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80172f:	8b 45 08             	mov    0x8(%ebp),%eax
  801732:	8b 40 0c             	mov    0xc(%eax),%eax
  801735:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80173a:	ba 00 00 00 00       	mov    $0x0,%edx
  80173f:	b8 05 00 00 00       	mov    $0x5,%eax
  801744:	e8 23 ff ff ff       	call   80166c <fsipc>
  801749:	85 c0                	test   %eax,%eax
  80174b:	78 2b                	js     801778 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80174d:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801754:	00 
  801755:	89 1c 24             	mov    %ebx,(%esp)
  801758:	e8 7e f0 ff ff       	call   8007db <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80175d:	a1 80 50 80 00       	mov    0x805080,%eax
  801762:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801768:	a1 84 50 80 00       	mov    0x805084,%eax
  80176d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801773:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801778:	83 c4 14             	add    $0x14,%esp
  80177b:	5b                   	pop    %ebx
  80177c:	5d                   	pop    %ebp
  80177d:	c3                   	ret    

0080177e <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80177e:	55                   	push   %ebp
  80177f:	89 e5                	mov    %esp,%ebp
  801781:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801784:	c7 44 24 08 66 20 80 	movl   $0x802066,0x8(%esp)
  80178b:	00 
  80178c:	c7 44 24 04 77 00 00 	movl   $0x77,0x4(%esp)
  801793:	00 
  801794:	c7 04 24 84 20 80 00 	movl   $0x802084,(%esp)
  80179b:	e8 a0 00 00 00       	call   801840 <_panic>

008017a0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017a0:	55                   	push   %ebp
  8017a1:	89 e5                	mov    %esp,%ebp
  8017a3:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_READ request to the file system server after
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
	panic("devfile_read not implemented");
  8017a6:	c7 44 24 08 8f 20 80 	movl   $0x80208f,0x8(%esp)
  8017ad:	00 
  8017ae:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
  8017b5:	00 
  8017b6:	c7 04 24 84 20 80 00 	movl   $0x802084,(%esp)
  8017bd:	e8 7e 00 00 00       	call   801840 <_panic>

008017c2 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017c2:	55                   	push   %ebp
  8017c3:	89 e5                	mov    %esp,%ebp
  8017c5:	83 ec 18             	sub    $0x18,%esp
	// Return the file descriptor index.
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
	panic("open not implemented");
  8017c8:	c7 44 24 08 ac 20 80 	movl   $0x8020ac,0x8(%esp)
  8017cf:	00 
  8017d0:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  8017d7:	00 
  8017d8:	c7 04 24 84 20 80 00 	movl   $0x802084,(%esp)
  8017df:	e8 5c 00 00 00       	call   801840 <_panic>

008017e4 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  8017e4:	55                   	push   %ebp
  8017e5:	89 e5                	mov    %esp,%ebp
  8017e7:	53                   	push   %ebx
  8017e8:	83 ec 14             	sub    $0x14,%esp
  8017eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  8017ee:	89 1c 24             	mov    %ebx,(%esp)
  8017f1:	e8 8a ef ff ff       	call   800780 <strlen>
  8017f6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017fb:	7f 21                	jg     80181e <remove+0x3a>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  8017fd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801801:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801808:	e8 ce ef ff ff       	call   8007db <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  80180d:	ba 00 00 00 00       	mov    $0x0,%edx
  801812:	b8 07 00 00 00       	mov    $0x7,%eax
  801817:	e8 50 fe ff ff       	call   80166c <fsipc>
  80181c:	eb 05                	jmp    801823 <remove+0x3f>
// Delete a file
int
remove(const char *path)
{
	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80181e:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
	strcpy(fsipcbuf.remove.req_path, path);
	return fsipc(FSREQ_REMOVE, NULL);
}
  801823:	83 c4 14             	add    $0x14,%esp
  801826:	5b                   	pop    %ebx
  801827:	5d                   	pop    %ebp
  801828:	c3                   	ret    

00801829 <sync>:

// Synchronize disk with buffer cache
int
sync(void)
{
  801829:	55                   	push   %ebp
  80182a:	89 e5                	mov    %esp,%ebp
  80182c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80182f:	ba 00 00 00 00       	mov    $0x0,%edx
  801834:	b8 08 00 00 00       	mov    $0x8,%eax
  801839:	e8 2e fe ff ff       	call   80166c <fsipc>
}
  80183e:	c9                   	leave  
  80183f:	c3                   	ret    

00801840 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801840:	55                   	push   %ebp
  801841:	89 e5                	mov    %esp,%ebp
  801843:	56                   	push   %esi
  801844:	53                   	push   %ebx
  801845:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801848:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80184b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801851:	e8 61 f4 ff ff       	call   800cb7 <sys_getenvid>
  801856:	8b 55 0c             	mov    0xc(%ebp),%edx
  801859:	89 54 24 10          	mov    %edx,0x10(%esp)
  80185d:	8b 55 08             	mov    0x8(%ebp),%edx
  801860:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801864:	89 74 24 08          	mov    %esi,0x8(%esp)
  801868:	89 44 24 04          	mov    %eax,0x4(%esp)
  80186c:	c7 04 24 c4 20 80 00 	movl   $0x8020c4,(%esp)
  801873:	e8 eb e8 ff ff       	call   800163 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801878:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80187c:	8b 45 10             	mov    0x10(%ebp),%eax
  80187f:	89 04 24             	mov    %eax,(%esp)
  801882:	e8 7b e8 ff ff       	call   800102 <vcprintf>
	cprintf("\n");
  801887:	c7 04 24 bc 1c 80 00 	movl   $0x801cbc,(%esp)
  80188e:	e8 d0 e8 ff ff       	call   800163 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801893:	cc                   	int3   
  801894:	eb fd                	jmp    801893 <_panic+0x53>
  801896:	66 90                	xchg   %ax,%ax

00801898 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801898:	55                   	push   %ebp
  801899:	89 e5                	mov    %esp,%ebp
  80189b:	56                   	push   %esi
  80189c:	53                   	push   %ebx
  80189d:	83 ec 10             	sub    $0x10,%esp
  8018a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8018a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	// 	return thisenv->env_ipc_value;
	// }
	int r;
	if(pg == NULL)
		pg = (void *)~0x0;
  8018a6:	85 db                	test   %ebx,%ebx
  8018a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8018ad:	0f 44 d8             	cmove  %eax,%ebx
	//else
	if((r = sys_ipc_recv(pg)) < 0)
  8018b0:	89 1c 24             	mov    %ebx,(%esp)
  8018b3:	e8 19 f7 ff ff       	call   800fd1 <sys_ipc_recv>
  8018b8:	85 c0                	test   %eax,%eax
  8018ba:	78 2d                	js     8018e9 <ipc_recv+0x51>
		return r;
	//volatile struct Env *curenv = (struct Env*)envs+ENVX(sys_getenvid());

	if(from_env_store)
  8018bc:	85 f6                	test   %esi,%esi
  8018be:	74 0a                	je     8018ca <ipc_recv+0x32>
		*from_env_store = thisenv -> env_ipc_from;
  8018c0:	a1 04 40 80 00       	mov    0x804004,%eax
  8018c5:	8b 40 74             	mov    0x74(%eax),%eax
  8018c8:	89 06                	mov    %eax,(%esi)
	if(pg && perm_store)
  8018ca:	85 db                	test   %ebx,%ebx
  8018cc:	74 13                	je     8018e1 <ipc_recv+0x49>
  8018ce:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018d2:	74 0d                	je     8018e1 <ipc_recv+0x49>
		*perm_store = thisenv -> env_ipc_perm;
  8018d4:	a1 04 40 80 00       	mov    0x804004,%eax
  8018d9:	8b 40 78             	mov    0x78(%eax),%eax
  8018dc:	8b 55 10             	mov    0x10(%ebp),%edx
  8018df:	89 02                	mov    %eax,(%edx)
	else if(perm_store)
		perm_store = (int *)0;
	return thisenv->env_ipc_value;
  8018e1:	a1 04 40 80 00       	mov    0x804004,%eax
  8018e6:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  8018e9:	83 c4 10             	add    $0x10,%esp
  8018ec:	5b                   	pop    %ebx
  8018ed:	5e                   	pop    %esi
  8018ee:	5d                   	pop    %ebp
  8018ef:	c3                   	ret    

008018f0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8018f0:	55                   	push   %ebp
  8018f1:	89 e5                	mov    %esp,%ebp
  8018f3:	57                   	push   %edi
  8018f4:	56                   	push   %esi
  8018f5:	53                   	push   %ebx
  8018f6:	83 ec 1c             	sub    $0x1c,%esp
  8018f9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8018fc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018ff:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

	if(pg == NULL)
  801902:	85 db                	test   %ebx,%ebx
		pg = (void *)~0x0;
  801904:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801909:	0f 44 d8             	cmove  %eax,%ebx
  80190c:	eb 2a                	jmp    801938 <ipc_send+0x48>
	while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0){
		if(r != -E_IPC_NOT_RECV)
  80190e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801911:	74 20                	je     801933 <ipc_send+0x43>
            panic("Send message error %e\n",r);
  801913:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801917:	c7 44 24 08 e8 20 80 	movl   $0x8020e8,0x8(%esp)
  80191e:	00 
  80191f:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  801926:	00 
  801927:	c7 04 24 ff 20 80 00 	movl   $0x8020ff,(%esp)
  80192e:	e8 0d ff ff ff       	call   801840 <_panic>
		sys_yield();
  801933:	e8 b8 f3 ff ff       	call   800cf0 <sys_yield>
	// LAB 4: Your code here.
	int r;

	if(pg == NULL)
		pg = (void *)~0x0;
	while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0){
  801938:	8b 45 14             	mov    0x14(%ebp),%eax
  80193b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80193f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801943:	89 74 24 04          	mov    %esi,0x4(%esp)
  801947:	89 3c 24             	mov    %edi,(%esp)
  80194a:	e8 45 f6 ff ff       	call   800f94 <sys_ipc_try_send>
  80194f:	85 c0                	test   %eax,%eax
  801951:	78 bb                	js     80190e <ipc_send+0x1e>
            panic("Send message error %e\n",r);
		sys_yield();
	}

	//panic("ipc_send not implemented");
}
  801953:	83 c4 1c             	add    $0x1c,%esp
  801956:	5b                   	pop    %ebx
  801957:	5e                   	pop    %esi
  801958:	5f                   	pop    %edi
  801959:	5d                   	pop    %ebp
  80195a:	c3                   	ret    

0080195b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80195b:	55                   	push   %ebp
  80195c:	89 e5                	mov    %esp,%ebp
  80195e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801961:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801966:	39 c8                	cmp    %ecx,%eax
  801968:	74 17                	je     801981 <ipc_find_env+0x26>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80196a:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  80196f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801972:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801978:	8b 52 50             	mov    0x50(%edx),%edx
  80197b:	39 ca                	cmp    %ecx,%edx
  80197d:	75 14                	jne    801993 <ipc_find_env+0x38>
  80197f:	eb 05                	jmp    801986 <ipc_find_env+0x2b>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801981:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801986:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801989:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  80198e:	8b 40 40             	mov    0x40(%eax),%eax
  801991:	eb 0e                	jmp    8019a1 <ipc_find_env+0x46>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801993:	83 c0 01             	add    $0x1,%eax
  801996:	3d 00 04 00 00       	cmp    $0x400,%eax
  80199b:	75 d2                	jne    80196f <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80199d:	66 b8 00 00          	mov    $0x0,%ax
}
  8019a1:	5d                   	pop    %ebp
  8019a2:	c3                   	ret    
  8019a3:	66 90                	xchg   %ax,%ax
  8019a5:	66 90                	xchg   %ax,%ax
  8019a7:	66 90                	xchg   %ax,%ax
  8019a9:	66 90                	xchg   %ax,%ax
  8019ab:	66 90                	xchg   %ax,%ax
  8019ad:	66 90                	xchg   %ax,%ax
  8019af:	90                   	nop

008019b0 <__udivdi3>:
  8019b0:	83 ec 1c             	sub    $0x1c,%esp
  8019b3:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  8019b7:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8019bb:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8019bf:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8019c3:	8b 7c 24 20          	mov    0x20(%esp),%edi
  8019c7:	8b 6c 24 24          	mov    0x24(%esp),%ebp
  8019cb:	85 c0                	test   %eax,%eax
  8019cd:	89 74 24 10          	mov    %esi,0x10(%esp)
  8019d1:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8019d5:	89 ea                	mov    %ebp,%edx
  8019d7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8019db:	75 33                	jne    801a10 <__udivdi3+0x60>
  8019dd:	39 e9                	cmp    %ebp,%ecx
  8019df:	77 6f                	ja     801a50 <__udivdi3+0xa0>
  8019e1:	85 c9                	test   %ecx,%ecx
  8019e3:	89 ce                	mov    %ecx,%esi
  8019e5:	75 0b                	jne    8019f2 <__udivdi3+0x42>
  8019e7:	b8 01 00 00 00       	mov    $0x1,%eax
  8019ec:	31 d2                	xor    %edx,%edx
  8019ee:	f7 f1                	div    %ecx
  8019f0:	89 c6                	mov    %eax,%esi
  8019f2:	31 d2                	xor    %edx,%edx
  8019f4:	89 e8                	mov    %ebp,%eax
  8019f6:	f7 f6                	div    %esi
  8019f8:	89 c5                	mov    %eax,%ebp
  8019fa:	89 f8                	mov    %edi,%eax
  8019fc:	f7 f6                	div    %esi
  8019fe:	89 ea                	mov    %ebp,%edx
  801a00:	8b 74 24 10          	mov    0x10(%esp),%esi
  801a04:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801a08:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801a0c:	83 c4 1c             	add    $0x1c,%esp
  801a0f:	c3                   	ret    
  801a10:	39 e8                	cmp    %ebp,%eax
  801a12:	77 24                	ja     801a38 <__udivdi3+0x88>
  801a14:	0f bd c8             	bsr    %eax,%ecx
  801a17:	83 f1 1f             	xor    $0x1f,%ecx
  801a1a:	89 0c 24             	mov    %ecx,(%esp)
  801a1d:	75 49                	jne    801a68 <__udivdi3+0xb8>
  801a1f:	8b 74 24 08          	mov    0x8(%esp),%esi
  801a23:	39 74 24 04          	cmp    %esi,0x4(%esp)
  801a27:	0f 86 ab 00 00 00    	jbe    801ad8 <__udivdi3+0x128>
  801a2d:	39 e8                	cmp    %ebp,%eax
  801a2f:	0f 82 a3 00 00 00    	jb     801ad8 <__udivdi3+0x128>
  801a35:	8d 76 00             	lea    0x0(%esi),%esi
  801a38:	31 d2                	xor    %edx,%edx
  801a3a:	31 c0                	xor    %eax,%eax
  801a3c:	8b 74 24 10          	mov    0x10(%esp),%esi
  801a40:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801a44:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801a48:	83 c4 1c             	add    $0x1c,%esp
  801a4b:	c3                   	ret    
  801a4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801a50:	89 f8                	mov    %edi,%eax
  801a52:	f7 f1                	div    %ecx
  801a54:	31 d2                	xor    %edx,%edx
  801a56:	8b 74 24 10          	mov    0x10(%esp),%esi
  801a5a:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801a5e:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801a62:	83 c4 1c             	add    $0x1c,%esp
  801a65:	c3                   	ret    
  801a66:	66 90                	xchg   %ax,%ax
  801a68:	0f b6 0c 24          	movzbl (%esp),%ecx
  801a6c:	89 c6                	mov    %eax,%esi
  801a6e:	b8 20 00 00 00       	mov    $0x20,%eax
  801a73:	8b 6c 24 04          	mov    0x4(%esp),%ebp
  801a77:	2b 04 24             	sub    (%esp),%eax
  801a7a:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801a7e:	d3 e6                	shl    %cl,%esi
  801a80:	89 c1                	mov    %eax,%ecx
  801a82:	d3 ed                	shr    %cl,%ebp
  801a84:	0f b6 0c 24          	movzbl (%esp),%ecx
  801a88:	09 f5                	or     %esi,%ebp
  801a8a:	8b 74 24 04          	mov    0x4(%esp),%esi
  801a8e:	d3 e6                	shl    %cl,%esi
  801a90:	89 c1                	mov    %eax,%ecx
  801a92:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a96:	89 d6                	mov    %edx,%esi
  801a98:	d3 ee                	shr    %cl,%esi
  801a9a:	0f b6 0c 24          	movzbl (%esp),%ecx
  801a9e:	d3 e2                	shl    %cl,%edx
  801aa0:	89 c1                	mov    %eax,%ecx
  801aa2:	d3 ef                	shr    %cl,%edi
  801aa4:	09 d7                	or     %edx,%edi
  801aa6:	89 f2                	mov    %esi,%edx
  801aa8:	89 f8                	mov    %edi,%eax
  801aaa:	f7 f5                	div    %ebp
  801aac:	89 d6                	mov    %edx,%esi
  801aae:	89 c7                	mov    %eax,%edi
  801ab0:	f7 64 24 04          	mull   0x4(%esp)
  801ab4:	39 d6                	cmp    %edx,%esi
  801ab6:	72 30                	jb     801ae8 <__udivdi3+0x138>
  801ab8:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801abc:	0f b6 0c 24          	movzbl (%esp),%ecx
  801ac0:	d3 e5                	shl    %cl,%ebp
  801ac2:	39 c5                	cmp    %eax,%ebp
  801ac4:	73 04                	jae    801aca <__udivdi3+0x11a>
  801ac6:	39 d6                	cmp    %edx,%esi
  801ac8:	74 1e                	je     801ae8 <__udivdi3+0x138>
  801aca:	89 f8                	mov    %edi,%eax
  801acc:	31 d2                	xor    %edx,%edx
  801ace:	e9 69 ff ff ff       	jmp    801a3c <__udivdi3+0x8c>
  801ad3:	90                   	nop
  801ad4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ad8:	31 d2                	xor    %edx,%edx
  801ada:	b8 01 00 00 00       	mov    $0x1,%eax
  801adf:	e9 58 ff ff ff       	jmp    801a3c <__udivdi3+0x8c>
  801ae4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ae8:	8d 47 ff             	lea    -0x1(%edi),%eax
  801aeb:	31 d2                	xor    %edx,%edx
  801aed:	8b 74 24 10          	mov    0x10(%esp),%esi
  801af1:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801af5:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801af9:	83 c4 1c             	add    $0x1c,%esp
  801afc:	c3                   	ret    
  801afd:	66 90                	xchg   %ax,%ax
  801aff:	90                   	nop

00801b00 <__umoddi3>:
  801b00:	83 ec 2c             	sub    $0x2c,%esp
  801b03:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801b07:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801b0b:	89 74 24 20          	mov    %esi,0x20(%esp)
  801b0f:	8b 74 24 38          	mov    0x38(%esp),%esi
  801b13:	89 7c 24 24          	mov    %edi,0x24(%esp)
  801b17:	8b 7c 24 34          	mov    0x34(%esp),%edi
  801b1b:	85 c0                	test   %eax,%eax
  801b1d:	89 c2                	mov    %eax,%edx
  801b1f:	89 6c 24 28          	mov    %ebp,0x28(%esp)
  801b23:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801b27:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801b2b:	89 74 24 10          	mov    %esi,0x10(%esp)
  801b2f:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801b33:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801b37:	75 1f                	jne    801b58 <__umoddi3+0x58>
  801b39:	39 fe                	cmp    %edi,%esi
  801b3b:	76 63                	jbe    801ba0 <__umoddi3+0xa0>
  801b3d:	89 c8                	mov    %ecx,%eax
  801b3f:	89 fa                	mov    %edi,%edx
  801b41:	f7 f6                	div    %esi
  801b43:	89 d0                	mov    %edx,%eax
  801b45:	31 d2                	xor    %edx,%edx
  801b47:	8b 74 24 20          	mov    0x20(%esp),%esi
  801b4b:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801b4f:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801b53:	83 c4 2c             	add    $0x2c,%esp
  801b56:	c3                   	ret    
  801b57:	90                   	nop
  801b58:	39 f8                	cmp    %edi,%eax
  801b5a:	77 64                	ja     801bc0 <__umoddi3+0xc0>
  801b5c:	0f bd e8             	bsr    %eax,%ebp
  801b5f:	83 f5 1f             	xor    $0x1f,%ebp
  801b62:	75 74                	jne    801bd8 <__umoddi3+0xd8>
  801b64:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801b68:	39 7c 24 10          	cmp    %edi,0x10(%esp)
  801b6c:	0f 87 0e 01 00 00    	ja     801c80 <__umoddi3+0x180>
  801b72:	8b 7c 24 0c          	mov    0xc(%esp),%edi
  801b76:	29 f1                	sub    %esi,%ecx
  801b78:	19 c7                	sbb    %eax,%edi
  801b7a:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801b7e:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801b82:	8b 44 24 14          	mov    0x14(%esp),%eax
  801b86:	8b 54 24 18          	mov    0x18(%esp),%edx
  801b8a:	8b 74 24 20          	mov    0x20(%esp),%esi
  801b8e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801b92:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801b96:	83 c4 2c             	add    $0x2c,%esp
  801b99:	c3                   	ret    
  801b9a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ba0:	85 f6                	test   %esi,%esi
  801ba2:	89 f5                	mov    %esi,%ebp
  801ba4:	75 0b                	jne    801bb1 <__umoddi3+0xb1>
  801ba6:	b8 01 00 00 00       	mov    $0x1,%eax
  801bab:	31 d2                	xor    %edx,%edx
  801bad:	f7 f6                	div    %esi
  801baf:	89 c5                	mov    %eax,%ebp
  801bb1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801bb5:	31 d2                	xor    %edx,%edx
  801bb7:	f7 f5                	div    %ebp
  801bb9:	89 c8                	mov    %ecx,%eax
  801bbb:	f7 f5                	div    %ebp
  801bbd:	eb 84                	jmp    801b43 <__umoddi3+0x43>
  801bbf:	90                   	nop
  801bc0:	89 c8                	mov    %ecx,%eax
  801bc2:	89 fa                	mov    %edi,%edx
  801bc4:	8b 74 24 20          	mov    0x20(%esp),%esi
  801bc8:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801bcc:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801bd0:	83 c4 2c             	add    $0x2c,%esp
  801bd3:	c3                   	ret    
  801bd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801bd8:	8b 44 24 10          	mov    0x10(%esp),%eax
  801bdc:	be 20 00 00 00       	mov    $0x20,%esi
  801be1:	89 e9                	mov    %ebp,%ecx
  801be3:	29 ee                	sub    %ebp,%esi
  801be5:	d3 e2                	shl    %cl,%edx
  801be7:	89 f1                	mov    %esi,%ecx
  801be9:	d3 e8                	shr    %cl,%eax
  801beb:	89 e9                	mov    %ebp,%ecx
  801bed:	09 d0                	or     %edx,%eax
  801bef:	89 fa                	mov    %edi,%edx
  801bf1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bf5:	8b 44 24 10          	mov    0x10(%esp),%eax
  801bf9:	d3 e0                	shl    %cl,%eax
  801bfb:	89 f1                	mov    %esi,%ecx
  801bfd:	89 44 24 10          	mov    %eax,0x10(%esp)
  801c01:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801c05:	d3 ea                	shr    %cl,%edx
  801c07:	89 e9                	mov    %ebp,%ecx
  801c09:	d3 e7                	shl    %cl,%edi
  801c0b:	89 f1                	mov    %esi,%ecx
  801c0d:	d3 e8                	shr    %cl,%eax
  801c0f:	89 e9                	mov    %ebp,%ecx
  801c11:	09 f8                	or     %edi,%eax
  801c13:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801c17:	f7 74 24 0c          	divl   0xc(%esp)
  801c1b:	d3 e7                	shl    %cl,%edi
  801c1d:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801c21:	89 d7                	mov    %edx,%edi
  801c23:	f7 64 24 10          	mull   0x10(%esp)
  801c27:	39 d7                	cmp    %edx,%edi
  801c29:	89 c1                	mov    %eax,%ecx
  801c2b:	89 54 24 14          	mov    %edx,0x14(%esp)
  801c2f:	72 3b                	jb     801c6c <__umoddi3+0x16c>
  801c31:	39 44 24 18          	cmp    %eax,0x18(%esp)
  801c35:	72 31                	jb     801c68 <__umoddi3+0x168>
  801c37:	8b 44 24 18          	mov    0x18(%esp),%eax
  801c3b:	29 c8                	sub    %ecx,%eax
  801c3d:	19 d7                	sbb    %edx,%edi
  801c3f:	89 e9                	mov    %ebp,%ecx
  801c41:	89 fa                	mov    %edi,%edx
  801c43:	d3 e8                	shr    %cl,%eax
  801c45:	89 f1                	mov    %esi,%ecx
  801c47:	d3 e2                	shl    %cl,%edx
  801c49:	89 e9                	mov    %ebp,%ecx
  801c4b:	09 d0                	or     %edx,%eax
  801c4d:	89 fa                	mov    %edi,%edx
  801c4f:	d3 ea                	shr    %cl,%edx
  801c51:	8b 74 24 20          	mov    0x20(%esp),%esi
  801c55:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801c59:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801c5d:	83 c4 2c             	add    $0x2c,%esp
  801c60:	c3                   	ret    
  801c61:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c68:	39 d7                	cmp    %edx,%edi
  801c6a:	75 cb                	jne    801c37 <__umoddi3+0x137>
  801c6c:	8b 54 24 14          	mov    0x14(%esp),%edx
  801c70:	89 c1                	mov    %eax,%ecx
  801c72:	2b 4c 24 10          	sub    0x10(%esp),%ecx
  801c76:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  801c7a:	eb bb                	jmp    801c37 <__umoddi3+0x137>
  801c7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c80:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801c84:	0f 82 e8 fe ff ff    	jb     801b72 <__umoddi3+0x72>
  801c8a:	e9 f3 fe ff ff       	jmp    801b82 <__umoddi3+0x82>
