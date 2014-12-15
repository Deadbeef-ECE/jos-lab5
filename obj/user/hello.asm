
obj/user/hello.debug:     file format elf32-i386


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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	90                   	nop

00800034 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	cprintf("hello, world\n");
  80003a:	c7 04 24 a0 1c 80 00 	movl   $0x801ca0,(%esp)
  800041:	e8 29 01 00 00       	call   80016f <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800046:	a1 04 40 80 00       	mov    0x804004,%eax
  80004b:	8b 40 48             	mov    0x48(%eax),%eax
  80004e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800052:	c7 04 24 ae 1c 80 00 	movl   $0x801cae,(%esp)
  800059:	e8 11 01 00 00       	call   80016f <cprintf>
}
  80005e:	c9                   	leave  
  80005f:	c3                   	ret    

00800060 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	83 ec 18             	sub    $0x18,%esp
  800066:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800069:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80006c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80006f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;

	thisenv = &envs[ENVX(sys_getenvid())];
  800072:	e8 50 0c 00 00       	call   800cc7 <sys_getenvid>
  800077:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80007f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800084:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800089:	85 db                	test   %ebx,%ebx
  80008b:	7e 07                	jle    800094 <libmain+0x34>
		binaryname = argv[0];
  80008d:	8b 06                	mov    (%esi),%eax
  80008f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800094:	89 74 24 04          	mov    %esi,0x4(%esp)
  800098:	89 1c 24             	mov    %ebx,(%esp)
  80009b:	e8 94 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a0:	e8 0b 00 00 00       	call   8000b0 <exit>
}
  8000a5:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000a8:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000ab:	89 ec                	mov    %ebp,%esp
  8000ad:	5d                   	pop    %ebp
  8000ae:	c3                   	ret    
  8000af:	90                   	nop

008000b0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000b6:	e8 98 11 00 00       	call   801253 <close_all>
	sys_env_destroy(0);
  8000bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000c2:	e8 9a 0b 00 00       	call   800c61 <sys_env_destroy>
}
  8000c7:	c9                   	leave  
  8000c8:	c3                   	ret    
  8000c9:	66 90                	xchg   %ax,%ax
  8000cb:	90                   	nop

008000cc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	53                   	push   %ebx
  8000d0:	83 ec 14             	sub    $0x14,%esp
  8000d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000d6:	8b 03                	mov    (%ebx),%eax
  8000d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000db:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000df:	83 c0 01             	add    $0x1,%eax
  8000e2:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000e4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000e9:	75 19                	jne    800104 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8000eb:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000f2:	00 
  8000f3:	8d 43 08             	lea    0x8(%ebx),%eax
  8000f6:	89 04 24             	mov    %eax,(%esp)
  8000f9:	e8 f2 0a 00 00       	call   800bf0 <sys_cputs>
		b->idx = 0;
  8000fe:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800104:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800108:	83 c4 14             	add    $0x14,%esp
  80010b:	5b                   	pop    %ebx
  80010c:	5d                   	pop    %ebp
  80010d:	c3                   	ret    

0080010e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80010e:	55                   	push   %ebp
  80010f:	89 e5                	mov    %esp,%ebp
  800111:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800117:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80011e:	00 00 00 
	b.cnt = 0;
  800121:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800128:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80012b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80012e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800132:	8b 45 08             	mov    0x8(%ebp),%eax
  800135:	89 44 24 08          	mov    %eax,0x8(%esp)
  800139:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80013f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800143:	c7 04 24 cc 00 80 00 	movl   $0x8000cc,(%esp)
  80014a:	e8 b3 01 00 00       	call   800302 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80014f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800155:	89 44 24 04          	mov    %eax,0x4(%esp)
  800159:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80015f:	89 04 24             	mov    %eax,(%esp)
  800162:	e8 89 0a 00 00       	call   800bf0 <sys_cputs>

	return b.cnt;
}
  800167:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80016d:	c9                   	leave  
  80016e:	c3                   	ret    

0080016f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80016f:	55                   	push   %ebp
  800170:	89 e5                	mov    %esp,%ebp
  800172:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800175:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800178:	89 44 24 04          	mov    %eax,0x4(%esp)
  80017c:	8b 45 08             	mov    0x8(%ebp),%eax
  80017f:	89 04 24             	mov    %eax,(%esp)
  800182:	e8 87 ff ff ff       	call   80010e <vcprintf>
	va_end(ap);

	return cnt;
}
  800187:	c9                   	leave  
  800188:	c3                   	ret    
  800189:	66 90                	xchg   %ax,%ax
  80018b:	66 90                	xchg   %ax,%ax
  80018d:	66 90                	xchg   %ax,%ax
  80018f:	90                   	nop

00800190 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	57                   	push   %edi
  800194:	56                   	push   %esi
  800195:	53                   	push   %ebx
  800196:	83 ec 4c             	sub    $0x4c,%esp
  800199:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80019c:	89 d7                	mov    %edx,%edi
  80019e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001a1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8001a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8001a7:	89 5d dc             	mov    %ebx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8001af:	39 d8                	cmp    %ebx,%eax
  8001b1:	72 17                	jb     8001ca <printnum+0x3a>
  8001b3:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8001b6:	39 5d 10             	cmp    %ebx,0x10(%ebp)
  8001b9:	76 0f                	jbe    8001ca <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001bb:	8b 75 14             	mov    0x14(%ebp),%esi
  8001be:	83 ee 01             	sub    $0x1,%esi
  8001c1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8001c4:	85 f6                	test   %esi,%esi
  8001c6:	7f 63                	jg     80022b <printnum+0x9b>
  8001c8:	eb 75                	jmp    80023f <printnum+0xaf>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ca:	8b 5d 18             	mov    0x18(%ebp),%ebx
  8001cd:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8001d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8001d4:	83 e8 01             	sub    $0x1,%eax
  8001d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001db:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001e2:	8b 44 24 08          	mov    0x8(%esp),%eax
  8001e6:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8001ea:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001ed:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8001f0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001f7:	00 
  8001f8:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8001fb:	89 1c 24             	mov    %ebx,(%esp)
  8001fe:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800201:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800205:	e8 b6 17 00 00       	call   8019c0 <__udivdi3>
  80020a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80020d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800210:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800214:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800218:	89 04 24             	mov    %eax,(%esp)
  80021b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80021f:	89 fa                	mov    %edi,%edx
  800221:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800224:	e8 67 ff ff ff       	call   800190 <printnum>
  800229:	eb 14                	jmp    80023f <printnum+0xaf>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80022b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80022f:	8b 45 18             	mov    0x18(%ebp),%eax
  800232:	89 04 24             	mov    %eax,(%esp)
  800235:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800237:	83 ee 01             	sub    $0x1,%esi
  80023a:	75 ef                	jne    80022b <printnum+0x9b>
  80023c:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80023f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800243:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800247:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80024a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80024e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800255:	00 
  800256:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800259:	89 1c 24             	mov    %ebx,(%esp)
  80025c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80025f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800263:	e8 a8 18 00 00       	call   801b10 <__umoddi3>
  800268:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80026c:	0f be 80 cf 1c 80 00 	movsbl 0x801ccf(%eax),%eax
  800273:	89 04 24             	mov    %eax,(%esp)
  800276:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800279:	ff d0                	call   *%eax
}
  80027b:	83 c4 4c             	add    $0x4c,%esp
  80027e:	5b                   	pop    %ebx
  80027f:	5e                   	pop    %esi
  800280:	5f                   	pop    %edi
  800281:	5d                   	pop    %ebp
  800282:	c3                   	ret    

00800283 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800283:	55                   	push   %ebp
  800284:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800286:	83 fa 01             	cmp    $0x1,%edx
  800289:	7e 0e                	jle    800299 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80028b:	8b 10                	mov    (%eax),%edx
  80028d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800290:	89 08                	mov    %ecx,(%eax)
  800292:	8b 02                	mov    (%edx),%eax
  800294:	8b 52 04             	mov    0x4(%edx),%edx
  800297:	eb 22                	jmp    8002bb <getuint+0x38>
	else if (lflag)
  800299:	85 d2                	test   %edx,%edx
  80029b:	74 10                	je     8002ad <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80029d:	8b 10                	mov    (%eax),%edx
  80029f:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a2:	89 08                	mov    %ecx,(%eax)
  8002a4:	8b 02                	mov    (%edx),%eax
  8002a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ab:	eb 0e                	jmp    8002bb <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002ad:	8b 10                	mov    (%eax),%edx
  8002af:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b2:	89 08                	mov    %ecx,(%eax)
  8002b4:	8b 02                	mov    (%edx),%eax
  8002b6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002bb:	5d                   	pop    %ebp
  8002bc:	c3                   	ret    

008002bd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002bd:	55                   	push   %ebp
  8002be:	89 e5                	mov    %esp,%ebp
  8002c0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002c3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002c7:	8b 10                	mov    (%eax),%edx
  8002c9:	3b 50 04             	cmp    0x4(%eax),%edx
  8002cc:	73 0a                	jae    8002d8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002d1:	88 0a                	mov    %cl,(%edx)
  8002d3:	83 c2 01             	add    $0x1,%edx
  8002d6:	89 10                	mov    %edx,(%eax)
}
  8002d8:	5d                   	pop    %ebp
  8002d9:	c3                   	ret    

008002da <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002da:	55                   	push   %ebp
  8002db:	89 e5                	mov    %esp,%ebp
  8002dd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002e0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002e3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002e7:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ea:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f8:	89 04 24             	mov    %eax,(%esp)
  8002fb:	e8 02 00 00 00       	call   800302 <vprintfmt>
	va_end(ap);
}
  800300:	c9                   	leave  
  800301:	c3                   	ret    

00800302 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800302:	55                   	push   %ebp
  800303:	89 e5                	mov    %esp,%ebp
  800305:	57                   	push   %edi
  800306:	56                   	push   %esi
  800307:	53                   	push   %ebx
  800308:	83 ec 4c             	sub    $0x4c,%esp
  80030b:	8b 75 08             	mov    0x8(%ebp),%esi
  80030e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800311:	8b 7d 10             	mov    0x10(%ebp),%edi
  800314:	eb 11                	jmp    800327 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800316:	85 c0                	test   %eax,%eax
  800318:	0f 84 db 03 00 00    	je     8006f9 <vprintfmt+0x3f7>
				return;
			putch(ch, putdat);
  80031e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800322:	89 04 24             	mov    %eax,(%esp)
  800325:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800327:	0f b6 07             	movzbl (%edi),%eax
  80032a:	83 c7 01             	add    $0x1,%edi
  80032d:	83 f8 25             	cmp    $0x25,%eax
  800330:	75 e4                	jne    800316 <vprintfmt+0x14>
  800332:	c6 45 e4 20          	movb   $0x20,-0x1c(%ebp)
  800336:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80033d:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800344:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80034b:	ba 00 00 00 00       	mov    $0x0,%edx
  800350:	eb 2b                	jmp    80037d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800352:	8b 7d e0             	mov    -0x20(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800355:	c6 45 e4 2d          	movb   $0x2d,-0x1c(%ebp)
  800359:	eb 22                	jmp    80037d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035b:	8b 7d e0             	mov    -0x20(%ebp),%edi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80035e:	c6 45 e4 30          	movb   $0x30,-0x1c(%ebp)
  800362:	eb 19                	jmp    80037d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800364:	8b 7d e0             	mov    -0x20(%ebp),%edi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800367:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80036e:	eb 0d                	jmp    80037d <vprintfmt+0x7b>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800370:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800373:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800376:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037d:	0f b6 0f             	movzbl (%edi),%ecx
  800380:	8d 47 01             	lea    0x1(%edi),%eax
  800383:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800386:	0f b6 07             	movzbl (%edi),%eax
  800389:	83 e8 23             	sub    $0x23,%eax
  80038c:	3c 55                	cmp    $0x55,%al
  80038e:	0f 87 40 03 00 00    	ja     8006d4 <vprintfmt+0x3d2>
  800394:	0f b6 c0             	movzbl %al,%eax
  800397:	ff 24 85 20 1e 80 00 	jmp    *0x801e20(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80039e:	83 e9 30             	sub    $0x30,%ecx
  8003a1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				ch = *fmt;
  8003a4:	0f be 47 01          	movsbl 0x1(%edi),%eax
				if (ch < '0' || ch > '9')
  8003a8:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8003ab:	83 f9 09             	cmp    $0x9,%ecx
  8003ae:	77 57                	ja     800407 <vprintfmt+0x105>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b0:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8003b3:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8003b6:	8b 55 dc             	mov    -0x24(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003b9:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003bc:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8003bf:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8003c3:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8003c6:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8003c9:	83 f9 09             	cmp    $0x9,%ecx
  8003cc:	76 eb                	jbe    8003b9 <vprintfmt+0xb7>
  8003ce:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8003d1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003d4:	eb 34                	jmp    80040a <vprintfmt+0x108>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d9:	8d 48 04             	lea    0x4(%eax),%ecx
  8003dc:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003df:	8b 00                	mov    (%eax),%eax
  8003e1:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e4:	8b 7d e0             	mov    -0x20(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003e7:	eb 21                	jmp    80040a <vprintfmt+0x108>

		case '.':
			if (width < 0)
  8003e9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8003ed:	0f 88 71 ff ff ff    	js     800364 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f3:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8003f6:	eb 85                	jmp    80037d <vprintfmt+0x7b>
  8003f8:	8b 7d e0             	mov    -0x20(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003fb:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  800402:	e9 76 ff ff ff       	jmp    80037d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800407:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80040a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80040e:	0f 89 69 ff ff ff    	jns    80037d <vprintfmt+0x7b>
  800414:	e9 57 ff ff ff       	jmp    800370 <vprintfmt+0x6e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800419:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80041f:	e9 59 ff ff ff       	jmp    80037d <vprintfmt+0x7b>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800424:	8b 45 14             	mov    0x14(%ebp),%eax
  800427:	8d 50 04             	lea    0x4(%eax),%edx
  80042a:	89 55 14             	mov    %edx,0x14(%ebp)
  80042d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800431:	8b 00                	mov    (%eax),%eax
  800433:	89 04 24             	mov    %eax,(%esp)
  800436:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800438:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80043b:	e9 e7 fe ff ff       	jmp    800327 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800440:	8b 45 14             	mov    0x14(%ebp),%eax
  800443:	8d 50 04             	lea    0x4(%eax),%edx
  800446:	89 55 14             	mov    %edx,0x14(%ebp)
  800449:	8b 00                	mov    (%eax),%eax
  80044b:	89 c2                	mov    %eax,%edx
  80044d:	c1 fa 1f             	sar    $0x1f,%edx
  800450:	31 d0                	xor    %edx,%eax
  800452:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800454:	83 f8 0f             	cmp    $0xf,%eax
  800457:	7f 0b                	jg     800464 <vprintfmt+0x162>
  800459:	8b 14 85 80 1f 80 00 	mov    0x801f80(,%eax,4),%edx
  800460:	85 d2                	test   %edx,%edx
  800462:	75 20                	jne    800484 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  800464:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800468:	c7 44 24 08 e7 1c 80 	movl   $0x801ce7,0x8(%esp)
  80046f:	00 
  800470:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800474:	89 34 24             	mov    %esi,(%esp)
  800477:	e8 5e fe ff ff       	call   8002da <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047c:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80047f:	e9 a3 fe ff ff       	jmp    800327 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800484:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800488:	c7 44 24 08 f0 1c 80 	movl   $0x801cf0,0x8(%esp)
  80048f:	00 
  800490:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800494:	89 34 24             	mov    %esi,(%esp)
  800497:	e8 3e fe ff ff       	call   8002da <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049c:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80049f:	e9 83 fe ff ff       	jmp    800327 <vprintfmt+0x25>
  8004a4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004a7:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8004aa:	89 7d cc             	mov    %edi,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b0:	8d 50 04             	lea    0x4(%eax),%edx
  8004b3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004b8:	85 ff                	test   %edi,%edi
  8004ba:	b8 e0 1c 80 00       	mov    $0x801ce0,%eax
  8004bf:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004c2:	80 7d e4 2d          	cmpb   $0x2d,-0x1c(%ebp)
  8004c6:	74 06                	je     8004ce <vprintfmt+0x1cc>
  8004c8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004cc:	7f 16                	jg     8004e4 <vprintfmt+0x1e2>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ce:	0f b6 17             	movzbl (%edi),%edx
  8004d1:	0f be c2             	movsbl %dl,%eax
  8004d4:	83 c7 01             	add    $0x1,%edi
  8004d7:	85 c0                	test   %eax,%eax
  8004d9:	0f 85 9f 00 00 00    	jne    80057e <vprintfmt+0x27c>
  8004df:	e9 8b 00 00 00       	jmp    80056f <vprintfmt+0x26d>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004e8:	89 3c 24             	mov    %edi,(%esp)
  8004eb:	e8 c2 02 00 00       	call   8007b2 <strnlen>
  8004f0:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8004f3:	29 c2                	sub    %eax,%edx
  8004f5:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8004f8:	85 d2                	test   %edx,%edx
  8004fa:	7e d2                	jle    8004ce <vprintfmt+0x1cc>
					putch(padc, putdat);
  8004fc:	0f be 4d e4          	movsbl -0x1c(%ebp),%ecx
  800500:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800503:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800506:	89 d7                	mov    %edx,%edi
  800508:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80050c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80050f:	89 04 24             	mov    %eax,(%esp)
  800512:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800514:	83 ef 01             	sub    $0x1,%edi
  800517:	75 ef                	jne    800508 <vprintfmt+0x206>
  800519:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80051c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80051f:	eb ad                	jmp    8004ce <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800521:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800525:	74 20                	je     800547 <vprintfmt+0x245>
  800527:	0f be d2             	movsbl %dl,%edx
  80052a:	83 ea 20             	sub    $0x20,%edx
  80052d:	83 fa 5e             	cmp    $0x5e,%edx
  800530:	76 15                	jbe    800547 <vprintfmt+0x245>
					putch('?', putdat);
  800532:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800535:	89 54 24 04          	mov    %edx,0x4(%esp)
  800539:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800540:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800543:	ff d1                	call   *%ecx
  800545:	eb 0f                	jmp    800556 <vprintfmt+0x254>
				else
					putch(ch, putdat);
  800547:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80054a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80054e:	89 04 24             	mov    %eax,(%esp)
  800551:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800554:	ff d1                	call   *%ecx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800556:	83 eb 01             	sub    $0x1,%ebx
  800559:	0f b6 17             	movzbl (%edi),%edx
  80055c:	0f be c2             	movsbl %dl,%eax
  80055f:	83 c7 01             	add    $0x1,%edi
  800562:	85 c0                	test   %eax,%eax
  800564:	75 24                	jne    80058a <vprintfmt+0x288>
  800566:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800569:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80056c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056f:	8b 7d e0             	mov    -0x20(%ebp),%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800572:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800576:	0f 8e ab fd ff ff    	jle    800327 <vprintfmt+0x25>
  80057c:	eb 20                	jmp    80059e <vprintfmt+0x29c>
  80057e:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800581:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800584:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  800587:	8b 5d d8             	mov    -0x28(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80058a:	85 f6                	test   %esi,%esi
  80058c:	78 93                	js     800521 <vprintfmt+0x21f>
  80058e:	83 ee 01             	sub    $0x1,%esi
  800591:	79 8e                	jns    800521 <vprintfmt+0x21f>
  800593:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800596:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800599:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80059c:	eb d1                	jmp    80056f <vprintfmt+0x26d>
  80059e:	8b 7d d8             	mov    -0x28(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005a1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005ac:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005ae:	83 ef 01             	sub    $0x1,%edi
  8005b1:	75 ee                	jne    8005a1 <vprintfmt+0x29f>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b3:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005b6:	e9 6c fd ff ff       	jmp    800327 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005bb:	83 fa 01             	cmp    $0x1,%edx
  8005be:	66 90                	xchg   %ax,%ax
  8005c0:	7e 16                	jle    8005d8 <vprintfmt+0x2d6>
		return va_arg(*ap, long long);
  8005c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c5:	8d 50 08             	lea    0x8(%eax),%edx
  8005c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005cb:	8b 10                	mov    (%eax),%edx
  8005cd:	8b 48 04             	mov    0x4(%eax),%ecx
  8005d0:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8005d3:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8005d6:	eb 32                	jmp    80060a <vprintfmt+0x308>
	else if (lflag)
  8005d8:	85 d2                	test   %edx,%edx
  8005da:	74 18                	je     8005f4 <vprintfmt+0x2f2>
		return va_arg(*ap, long);
  8005dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005df:	8d 50 04             	lea    0x4(%eax),%edx
  8005e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e5:	8b 00                	mov    (%eax),%eax
  8005e7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005ea:	89 c1                	mov    %eax,%ecx
  8005ec:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ef:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8005f2:	eb 16                	jmp    80060a <vprintfmt+0x308>
	else
		return va_arg(*ap, int);
  8005f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f7:	8d 50 04             	lea    0x4(%eax),%edx
  8005fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fd:	8b 00                	mov    (%eax),%eax
  8005ff:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800602:	89 c7                	mov    %eax,%edi
  800604:	c1 ff 1f             	sar    $0x1f,%edi
  800607:	89 7d d4             	mov    %edi,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80060a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80060d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800610:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800615:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800619:	79 7d                	jns    800698 <vprintfmt+0x396>
				putch('-', putdat);
  80061b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80061f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800626:	ff d6                	call   *%esi
				num = -(long long) num;
  800628:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80062b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80062e:	f7 d8                	neg    %eax
  800630:	83 d2 00             	adc    $0x0,%edx
  800633:	f7 da                	neg    %edx
			}
			base = 10;
  800635:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80063a:	eb 5c                	jmp    800698 <vprintfmt+0x396>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80063c:	8d 45 14             	lea    0x14(%ebp),%eax
  80063f:	e8 3f fc ff ff       	call   800283 <getuint>
			base = 10;
  800644:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800649:	eb 4d                	jmp    800698 <vprintfmt+0x396>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80064b:	8d 45 14             	lea    0x14(%ebp),%eax
  80064e:	e8 30 fc ff ff       	call   800283 <getuint>
			base = 8;
  800653:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800658:	eb 3e                	jmp    800698 <vprintfmt+0x396>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80065a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80065e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800665:	ff d6                	call   *%esi
			putch('x', putdat);
  800667:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80066b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800672:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800674:	8b 45 14             	mov    0x14(%ebp),%eax
  800677:	8d 50 04             	lea    0x4(%eax),%edx
  80067a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80067d:	8b 00                	mov    (%eax),%eax
  80067f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800684:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800689:	eb 0d                	jmp    800698 <vprintfmt+0x396>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80068b:	8d 45 14             	lea    0x14(%ebp),%eax
  80068e:	e8 f0 fb ff ff       	call   800283 <getuint>
			base = 16;
  800693:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800698:	0f be 7d e4          	movsbl -0x1c(%ebp),%edi
  80069c:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8006a0:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8006a3:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8006a7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8006ab:	89 04 24             	mov    %eax,(%esp)
  8006ae:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006b2:	89 da                	mov    %ebx,%edx
  8006b4:	89 f0                	mov    %esi,%eax
  8006b6:	e8 d5 fa ff ff       	call   800190 <printnum>
			break;
  8006bb:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8006be:	e9 64 fc ff ff       	jmp    800327 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006c3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c7:	89 0c 24             	mov    %ecx,(%esp)
  8006ca:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006cc:	8b 7d e0             	mov    -0x20(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006cf:	e9 53 fc ff ff       	jmp    800327 <vprintfmt+0x25>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006d4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006d8:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006df:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006e1:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006e5:	0f 84 3c fc ff ff    	je     800327 <vprintfmt+0x25>
  8006eb:	83 ef 01             	sub    $0x1,%edi
  8006ee:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006f2:	75 f7                	jne    8006eb <vprintfmt+0x3e9>
  8006f4:	e9 2e fc ff ff       	jmp    800327 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8006f9:	83 c4 4c             	add    $0x4c,%esp
  8006fc:	5b                   	pop    %ebx
  8006fd:	5e                   	pop    %esi
  8006fe:	5f                   	pop    %edi
  8006ff:	5d                   	pop    %ebp
  800700:	c3                   	ret    

00800701 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800701:	55                   	push   %ebp
  800702:	89 e5                	mov    %esp,%ebp
  800704:	83 ec 28             	sub    $0x28,%esp
  800707:	8b 45 08             	mov    0x8(%ebp),%eax
  80070a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80070d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800710:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800714:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800717:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80071e:	85 d2                	test   %edx,%edx
  800720:	7e 30                	jle    800752 <vsnprintf+0x51>
  800722:	85 c0                	test   %eax,%eax
  800724:	74 2c                	je     800752 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800726:	8b 45 14             	mov    0x14(%ebp),%eax
  800729:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80072d:	8b 45 10             	mov    0x10(%ebp),%eax
  800730:	89 44 24 08          	mov    %eax,0x8(%esp)
  800734:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800737:	89 44 24 04          	mov    %eax,0x4(%esp)
  80073b:	c7 04 24 bd 02 80 00 	movl   $0x8002bd,(%esp)
  800742:	e8 bb fb ff ff       	call   800302 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800747:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80074a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80074d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800750:	eb 05                	jmp    800757 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800752:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800757:	c9                   	leave  
  800758:	c3                   	ret    

00800759 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800759:	55                   	push   %ebp
  80075a:	89 e5                	mov    %esp,%ebp
  80075c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80075f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800762:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800766:	8b 45 10             	mov    0x10(%ebp),%eax
  800769:	89 44 24 08          	mov    %eax,0x8(%esp)
  80076d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800770:	89 44 24 04          	mov    %eax,0x4(%esp)
  800774:	8b 45 08             	mov    0x8(%ebp),%eax
  800777:	89 04 24             	mov    %eax,(%esp)
  80077a:	e8 82 ff ff ff       	call   800701 <vsnprintf>
	va_end(ap);

	return rc;
}
  80077f:	c9                   	leave  
  800780:	c3                   	ret    
  800781:	66 90                	xchg   %ax,%ax
  800783:	66 90                	xchg   %ax,%ax
  800785:	66 90                	xchg   %ax,%ax
  800787:	66 90                	xchg   %ax,%ax
  800789:	66 90                	xchg   %ax,%ax
  80078b:	66 90                	xchg   %ax,%ax
  80078d:	66 90                	xchg   %ax,%ax
  80078f:	90                   	nop

00800790 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800790:	55                   	push   %ebp
  800791:	89 e5                	mov    %esp,%ebp
  800793:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800796:	80 3a 00             	cmpb   $0x0,(%edx)
  800799:	74 10                	je     8007ab <strlen+0x1b>
  80079b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007a0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007a7:	75 f7                	jne    8007a0 <strlen+0x10>
  8007a9:	eb 05                	jmp    8007b0 <strlen+0x20>
  8007ab:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007b0:	5d                   	pop    %ebp
  8007b1:	c3                   	ret    

008007b2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	53                   	push   %ebx
  8007b6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007bc:	85 c9                	test   %ecx,%ecx
  8007be:	74 1c                	je     8007dc <strnlen+0x2a>
  8007c0:	80 3b 00             	cmpb   $0x0,(%ebx)
  8007c3:	74 1e                	je     8007e3 <strnlen+0x31>
  8007c5:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8007ca:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007cc:	39 ca                	cmp    %ecx,%edx
  8007ce:	74 18                	je     8007e8 <strnlen+0x36>
  8007d0:	83 c2 01             	add    $0x1,%edx
  8007d3:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8007d8:	75 f0                	jne    8007ca <strnlen+0x18>
  8007da:	eb 0c                	jmp    8007e8 <strnlen+0x36>
  8007dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e1:	eb 05                	jmp    8007e8 <strnlen+0x36>
  8007e3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007e8:	5b                   	pop    %ebx
  8007e9:	5d                   	pop    %ebp
  8007ea:	c3                   	ret    

008007eb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007eb:	55                   	push   %ebp
  8007ec:	89 e5                	mov    %esp,%ebp
  8007ee:	53                   	push   %ebx
  8007ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007f5:	89 c2                	mov    %eax,%edx
  8007f7:	0f b6 19             	movzbl (%ecx),%ebx
  8007fa:	88 1a                	mov    %bl,(%edx)
  8007fc:	83 c2 01             	add    $0x1,%edx
  8007ff:	83 c1 01             	add    $0x1,%ecx
  800802:	84 db                	test   %bl,%bl
  800804:	75 f1                	jne    8007f7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800806:	5b                   	pop    %ebx
  800807:	5d                   	pop    %ebp
  800808:	c3                   	ret    

00800809 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800809:	55                   	push   %ebp
  80080a:	89 e5                	mov    %esp,%ebp
  80080c:	53                   	push   %ebx
  80080d:	83 ec 08             	sub    $0x8,%esp
  800810:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800813:	89 1c 24             	mov    %ebx,(%esp)
  800816:	e8 75 ff ff ff       	call   800790 <strlen>
	strcpy(dst + len, src);
  80081b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80081e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800822:	01 d8                	add    %ebx,%eax
  800824:	89 04 24             	mov    %eax,(%esp)
  800827:	e8 bf ff ff ff       	call   8007eb <strcpy>
	return dst;
}
  80082c:	89 d8                	mov    %ebx,%eax
  80082e:	83 c4 08             	add    $0x8,%esp
  800831:	5b                   	pop    %ebx
  800832:	5d                   	pop    %ebp
  800833:	c3                   	ret    

00800834 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800834:	55                   	push   %ebp
  800835:	89 e5                	mov    %esp,%ebp
  800837:	56                   	push   %esi
  800838:	53                   	push   %ebx
  800839:	8b 75 08             	mov    0x8(%ebp),%esi
  80083c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80083f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800842:	85 db                	test   %ebx,%ebx
  800844:	74 16                	je     80085c <strncpy+0x28>
	strcpy(dst + len, src);
	return dst;
}

char *
strncpy(char *dst, const char *src, size_t size) {
  800846:	01 f3                	add    %esi,%ebx
  800848:	89 f1                	mov    %esi,%ecx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  80084a:	0f b6 02             	movzbl (%edx),%eax
  80084d:	88 01                	mov    %al,(%ecx)
  80084f:	83 c1 01             	add    $0x1,%ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800852:	80 3a 01             	cmpb   $0x1,(%edx)
  800855:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800858:	39 d9                	cmp    %ebx,%ecx
  80085a:	75 ee                	jne    80084a <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80085c:	89 f0                	mov    %esi,%eax
  80085e:	5b                   	pop    %ebx
  80085f:	5e                   	pop    %esi
  800860:	5d                   	pop    %ebp
  800861:	c3                   	ret    

00800862 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	57                   	push   %edi
  800866:	56                   	push   %esi
  800867:	53                   	push   %ebx
  800868:	8b 7d 08             	mov    0x8(%ebp),%edi
  80086b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80086e:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800871:	89 f8                	mov    %edi,%eax
  800873:	85 f6                	test   %esi,%esi
  800875:	74 33                	je     8008aa <strlcpy+0x48>
		while (--size > 0 && *src != '\0')
  800877:	83 fe 01             	cmp    $0x1,%esi
  80087a:	74 25                	je     8008a1 <strlcpy+0x3f>
  80087c:	0f b6 0b             	movzbl (%ebx),%ecx
  80087f:	84 c9                	test   %cl,%cl
  800881:	74 22                	je     8008a5 <strlcpy+0x43>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800883:	83 ee 02             	sub    $0x2,%esi
  800886:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80088b:	88 08                	mov    %cl,(%eax)
  80088d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800890:	39 f2                	cmp    %esi,%edx
  800892:	74 13                	je     8008a7 <strlcpy+0x45>
  800894:	83 c2 01             	add    $0x1,%edx
  800897:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80089b:	84 c9                	test   %cl,%cl
  80089d:	75 ec                	jne    80088b <strlcpy+0x29>
  80089f:	eb 06                	jmp    8008a7 <strlcpy+0x45>
  8008a1:	89 f8                	mov    %edi,%eax
  8008a3:	eb 02                	jmp    8008a7 <strlcpy+0x45>
  8008a5:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008a7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008aa:	29 f8                	sub    %edi,%eax
}
  8008ac:	5b                   	pop    %ebx
  8008ad:	5e                   	pop    %esi
  8008ae:	5f                   	pop    %edi
  8008af:	5d                   	pop    %ebp
  8008b0:	c3                   	ret    

008008b1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008b1:	55                   	push   %ebp
  8008b2:	89 e5                	mov    %esp,%ebp
  8008b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008ba:	0f b6 01             	movzbl (%ecx),%eax
  8008bd:	84 c0                	test   %al,%al
  8008bf:	74 15                	je     8008d6 <strcmp+0x25>
  8008c1:	3a 02                	cmp    (%edx),%al
  8008c3:	75 11                	jne    8008d6 <strcmp+0x25>
		p++, q++;
  8008c5:	83 c1 01             	add    $0x1,%ecx
  8008c8:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008cb:	0f b6 01             	movzbl (%ecx),%eax
  8008ce:	84 c0                	test   %al,%al
  8008d0:	74 04                	je     8008d6 <strcmp+0x25>
  8008d2:	3a 02                	cmp    (%edx),%al
  8008d4:	74 ef                	je     8008c5 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d6:	0f b6 c0             	movzbl %al,%eax
  8008d9:	0f b6 12             	movzbl (%edx),%edx
  8008dc:	29 d0                	sub    %edx,%eax
}
  8008de:	5d                   	pop    %ebp
  8008df:	c3                   	ret    

008008e0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	56                   	push   %esi
  8008e4:	53                   	push   %ebx
  8008e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008eb:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  8008ee:	85 f6                	test   %esi,%esi
  8008f0:	74 29                	je     80091b <strncmp+0x3b>
  8008f2:	0f b6 03             	movzbl (%ebx),%eax
  8008f5:	84 c0                	test   %al,%al
  8008f7:	74 30                	je     800929 <strncmp+0x49>
  8008f9:	3a 02                	cmp    (%edx),%al
  8008fb:	75 2c                	jne    800929 <strncmp+0x49>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}

int
strncmp(const char *p, const char *q, size_t n)
  8008fd:	8d 43 01             	lea    0x1(%ebx),%eax
  800900:	01 de                	add    %ebx,%esi
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800902:	89 c3                	mov    %eax,%ebx
  800904:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800907:	39 f0                	cmp    %esi,%eax
  800909:	74 17                	je     800922 <strncmp+0x42>
  80090b:	0f b6 08             	movzbl (%eax),%ecx
  80090e:	84 c9                	test   %cl,%cl
  800910:	74 17                	je     800929 <strncmp+0x49>
  800912:	83 c0 01             	add    $0x1,%eax
  800915:	3a 0a                	cmp    (%edx),%cl
  800917:	74 e9                	je     800902 <strncmp+0x22>
  800919:	eb 0e                	jmp    800929 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  80091b:	b8 00 00 00 00       	mov    $0x0,%eax
  800920:	eb 0f                	jmp    800931 <strncmp+0x51>
  800922:	b8 00 00 00 00       	mov    $0x0,%eax
  800927:	eb 08                	jmp    800931 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800929:	0f b6 03             	movzbl (%ebx),%eax
  80092c:	0f b6 12             	movzbl (%edx),%edx
  80092f:	29 d0                	sub    %edx,%eax
}
  800931:	5b                   	pop    %ebx
  800932:	5e                   	pop    %esi
  800933:	5d                   	pop    %ebp
  800934:	c3                   	ret    

00800935 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800935:	55                   	push   %ebp
  800936:	89 e5                	mov    %esp,%ebp
  800938:	53                   	push   %ebx
  800939:	8b 45 08             	mov    0x8(%ebp),%eax
  80093c:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  80093f:	0f b6 18             	movzbl (%eax),%ebx
  800942:	84 db                	test   %bl,%bl
  800944:	74 1d                	je     800963 <strchr+0x2e>
  800946:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800948:	38 d3                	cmp    %dl,%bl
  80094a:	75 06                	jne    800952 <strchr+0x1d>
  80094c:	eb 1a                	jmp    800968 <strchr+0x33>
  80094e:	38 ca                	cmp    %cl,%dl
  800950:	74 16                	je     800968 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800952:	83 c0 01             	add    $0x1,%eax
  800955:	0f b6 10             	movzbl (%eax),%edx
  800958:	84 d2                	test   %dl,%dl
  80095a:	75 f2                	jne    80094e <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  80095c:	b8 00 00 00 00       	mov    $0x0,%eax
  800961:	eb 05                	jmp    800968 <strchr+0x33>
  800963:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800968:	5b                   	pop    %ebx
  800969:	5d                   	pop    %ebp
  80096a:	c3                   	ret    

0080096b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	53                   	push   %ebx
  80096f:	8b 45 08             	mov    0x8(%ebp),%eax
  800972:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800975:	0f b6 18             	movzbl (%eax),%ebx
  800978:	84 db                	test   %bl,%bl
  80097a:	74 16                	je     800992 <strfind+0x27>
  80097c:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  80097e:	38 d3                	cmp    %dl,%bl
  800980:	75 06                	jne    800988 <strfind+0x1d>
  800982:	eb 0e                	jmp    800992 <strfind+0x27>
  800984:	38 ca                	cmp    %cl,%dl
  800986:	74 0a                	je     800992 <strfind+0x27>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800988:	83 c0 01             	add    $0x1,%eax
  80098b:	0f b6 10             	movzbl (%eax),%edx
  80098e:	84 d2                	test   %dl,%dl
  800990:	75 f2                	jne    800984 <strfind+0x19>
		if (*s == c)
			break;
	return (char *) s;
}
  800992:	5b                   	pop    %ebx
  800993:	5d                   	pop    %ebp
  800994:	c3                   	ret    

00800995 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800995:	55                   	push   %ebp
  800996:	89 e5                	mov    %esp,%ebp
  800998:	83 ec 0c             	sub    $0xc,%esp
  80099b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80099e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8009a1:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8009a4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009a7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009aa:	85 c9                	test   %ecx,%ecx
  8009ac:	74 36                	je     8009e4 <memset+0x4f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009ae:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009b4:	75 28                	jne    8009de <memset+0x49>
  8009b6:	f6 c1 03             	test   $0x3,%cl
  8009b9:	75 23                	jne    8009de <memset+0x49>
		c &= 0xFF;
  8009bb:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009bf:	89 d3                	mov    %edx,%ebx
  8009c1:	c1 e3 08             	shl    $0x8,%ebx
  8009c4:	89 d6                	mov    %edx,%esi
  8009c6:	c1 e6 18             	shl    $0x18,%esi
  8009c9:	89 d0                	mov    %edx,%eax
  8009cb:	c1 e0 10             	shl    $0x10,%eax
  8009ce:	09 f0                	or     %esi,%eax
  8009d0:	09 c2                	or     %eax,%edx
  8009d2:	89 d0                	mov    %edx,%eax
  8009d4:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009d6:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009d9:	fc                   	cld    
  8009da:	f3 ab                	rep stos %eax,%es:(%edi)
  8009dc:	eb 06                	jmp    8009e4 <memset+0x4f>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e1:	fc                   	cld    
  8009e2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");

	return v;
}
  8009e4:	89 f8                	mov    %edi,%eax
  8009e6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8009e9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8009ec:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8009ef:	89 ec                	mov    %ebp,%esp
  8009f1:	5d                   	pop    %ebp
  8009f2:	c3                   	ret    

008009f3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	83 ec 08             	sub    $0x8,%esp
  8009f9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8009fc:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8009ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800a02:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a05:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a08:	39 c6                	cmp    %eax,%esi
  800a0a:	73 36                	jae    800a42 <memmove+0x4f>
  800a0c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a0f:	39 d0                	cmp    %edx,%eax
  800a11:	73 2f                	jae    800a42 <memmove+0x4f>
		s += n;
		d += n;
  800a13:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a16:	f6 c2 03             	test   $0x3,%dl
  800a19:	75 1b                	jne    800a36 <memmove+0x43>
  800a1b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a21:	75 13                	jne    800a36 <memmove+0x43>
  800a23:	f6 c1 03             	test   $0x3,%cl
  800a26:	75 0e                	jne    800a36 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a28:	83 ef 04             	sub    $0x4,%edi
  800a2b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a2e:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a31:	fd                   	std    
  800a32:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a34:	eb 09                	jmp    800a3f <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a36:	83 ef 01             	sub    $0x1,%edi
  800a39:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a3c:	fd                   	std    
  800a3d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a3f:	fc                   	cld    
  800a40:	eb 20                	jmp    800a62 <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a42:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a48:	75 13                	jne    800a5d <memmove+0x6a>
  800a4a:	a8 03                	test   $0x3,%al
  800a4c:	75 0f                	jne    800a5d <memmove+0x6a>
  800a4e:	f6 c1 03             	test   $0x3,%cl
  800a51:	75 0a                	jne    800a5d <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a53:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a56:	89 c7                	mov    %eax,%edi
  800a58:	fc                   	cld    
  800a59:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a5b:	eb 05                	jmp    800a62 <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a5d:	89 c7                	mov    %eax,%edi
  800a5f:	fc                   	cld    
  800a60:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a62:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800a65:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800a68:	89 ec                	mov    %ebp,%esp
  800a6a:	5d                   	pop    %ebp
  800a6b:	c3                   	ret    

00800a6c <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a72:	8b 45 10             	mov    0x10(%ebp),%eax
  800a75:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a79:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a7c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a80:	8b 45 08             	mov    0x8(%ebp),%eax
  800a83:	89 04 24             	mov    %eax,(%esp)
  800a86:	e8 68 ff ff ff       	call   8009f3 <memmove>
}
  800a8b:	c9                   	leave  
  800a8c:	c3                   	ret    

00800a8d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a8d:	55                   	push   %ebp
  800a8e:	89 e5                	mov    %esp,%ebp
  800a90:	57                   	push   %edi
  800a91:	56                   	push   %esi
  800a92:	53                   	push   %ebx
  800a93:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a96:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a99:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a9c:	8d 78 ff             	lea    -0x1(%eax),%edi
  800a9f:	85 c0                	test   %eax,%eax
  800aa1:	74 36                	je     800ad9 <memcmp+0x4c>
		if (*s1 != *s2)
  800aa3:	0f b6 03             	movzbl (%ebx),%eax
  800aa6:	0f b6 0e             	movzbl (%esi),%ecx
  800aa9:	38 c8                	cmp    %cl,%al
  800aab:	75 17                	jne    800ac4 <memcmp+0x37>
  800aad:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab2:	eb 1a                	jmp    800ace <memcmp+0x41>
  800ab4:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800ab9:	83 c2 01             	add    $0x1,%edx
  800abc:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800ac0:	38 c8                	cmp    %cl,%al
  800ac2:	74 0a                	je     800ace <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800ac4:	0f b6 c0             	movzbl %al,%eax
  800ac7:	0f b6 c9             	movzbl %cl,%ecx
  800aca:	29 c8                	sub    %ecx,%eax
  800acc:	eb 10                	jmp    800ade <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ace:	39 fa                	cmp    %edi,%edx
  800ad0:	75 e2                	jne    800ab4 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ad2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad7:	eb 05                	jmp    800ade <memcmp+0x51>
  800ad9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ade:	5b                   	pop    %ebx
  800adf:	5e                   	pop    %esi
  800ae0:	5f                   	pop    %edi
  800ae1:	5d                   	pop    %ebp
  800ae2:	c3                   	ret    

00800ae3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ae3:	55                   	push   %ebp
  800ae4:	89 e5                	mov    %esp,%ebp
  800ae6:	53                   	push   %ebx
  800ae7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800aed:	89 c2                	mov    %eax,%edx
  800aef:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800af2:	39 d0                	cmp    %edx,%eax
  800af4:	73 13                	jae    800b09 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800af6:	89 d9                	mov    %ebx,%ecx
  800af8:	38 18                	cmp    %bl,(%eax)
  800afa:	75 06                	jne    800b02 <memfind+0x1f>
  800afc:	eb 0b                	jmp    800b09 <memfind+0x26>
  800afe:	38 08                	cmp    %cl,(%eax)
  800b00:	74 07                	je     800b09 <memfind+0x26>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b02:	83 c0 01             	add    $0x1,%eax
  800b05:	39 d0                	cmp    %edx,%eax
  800b07:	75 f5                	jne    800afe <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b09:	5b                   	pop    %ebx
  800b0a:	5d                   	pop    %ebp
  800b0b:	c3                   	ret    

00800b0c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	57                   	push   %edi
  800b10:	56                   	push   %esi
  800b11:	53                   	push   %ebx
  800b12:	83 ec 04             	sub    $0x4,%esp
  800b15:	8b 55 08             	mov    0x8(%ebp),%edx
  800b18:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b1b:	0f b6 02             	movzbl (%edx),%eax
  800b1e:	3c 09                	cmp    $0x9,%al
  800b20:	74 04                	je     800b26 <strtol+0x1a>
  800b22:	3c 20                	cmp    $0x20,%al
  800b24:	75 0e                	jne    800b34 <strtol+0x28>
		s++;
  800b26:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b29:	0f b6 02             	movzbl (%edx),%eax
  800b2c:	3c 09                	cmp    $0x9,%al
  800b2e:	74 f6                	je     800b26 <strtol+0x1a>
  800b30:	3c 20                	cmp    $0x20,%al
  800b32:	74 f2                	je     800b26 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b34:	3c 2b                	cmp    $0x2b,%al
  800b36:	75 0a                	jne    800b42 <strtol+0x36>
		s++;
  800b38:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b3b:	bf 00 00 00 00       	mov    $0x0,%edi
  800b40:	eb 10                	jmp    800b52 <strtol+0x46>
  800b42:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b47:	3c 2d                	cmp    $0x2d,%al
  800b49:	75 07                	jne    800b52 <strtol+0x46>
		s++, neg = 1;
  800b4b:	83 c2 01             	add    $0x1,%edx
  800b4e:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b52:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b58:	75 15                	jne    800b6f <strtol+0x63>
  800b5a:	80 3a 30             	cmpb   $0x30,(%edx)
  800b5d:	75 10                	jne    800b6f <strtol+0x63>
  800b5f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b63:	75 0a                	jne    800b6f <strtol+0x63>
		s += 2, base = 16;
  800b65:	83 c2 02             	add    $0x2,%edx
  800b68:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b6d:	eb 10                	jmp    800b7f <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800b6f:	85 db                	test   %ebx,%ebx
  800b71:	75 0c                	jne    800b7f <strtol+0x73>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b73:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b75:	80 3a 30             	cmpb   $0x30,(%edx)
  800b78:	75 05                	jne    800b7f <strtol+0x73>
		s++, base = 8;
  800b7a:	83 c2 01             	add    $0x1,%edx
  800b7d:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800b7f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b84:	89 5d f0             	mov    %ebx,-0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b87:	0f b6 0a             	movzbl (%edx),%ecx
  800b8a:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800b8d:	89 f3                	mov    %esi,%ebx
  800b8f:	80 fb 09             	cmp    $0x9,%bl
  800b92:	77 08                	ja     800b9c <strtol+0x90>
			dig = *s - '0';
  800b94:	0f be c9             	movsbl %cl,%ecx
  800b97:	83 e9 30             	sub    $0x30,%ecx
  800b9a:	eb 22                	jmp    800bbe <strtol+0xb2>
		else if (*s >= 'a' && *s <= 'z')
  800b9c:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800b9f:	89 f3                	mov    %esi,%ebx
  800ba1:	80 fb 19             	cmp    $0x19,%bl
  800ba4:	77 08                	ja     800bae <strtol+0xa2>
			dig = *s - 'a' + 10;
  800ba6:	0f be c9             	movsbl %cl,%ecx
  800ba9:	83 e9 57             	sub    $0x57,%ecx
  800bac:	eb 10                	jmp    800bbe <strtol+0xb2>
		else if (*s >= 'A' && *s <= 'Z')
  800bae:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800bb1:	89 f3                	mov    %esi,%ebx
  800bb3:	80 fb 19             	cmp    $0x19,%bl
  800bb6:	77 16                	ja     800bce <strtol+0xc2>
			dig = *s - 'A' + 10;
  800bb8:	0f be c9             	movsbl %cl,%ecx
  800bbb:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bbe:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800bc1:	7d 0f                	jge    800bd2 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800bc3:	83 c2 01             	add    $0x1,%edx
  800bc6:	0f af 45 f0          	imul   -0x10(%ebp),%eax
  800bca:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800bcc:	eb b9                	jmp    800b87 <strtol+0x7b>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800bce:	89 c1                	mov    %eax,%ecx
  800bd0:	eb 02                	jmp    800bd4 <strtol+0xc8>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bd2:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800bd4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bd8:	74 05                	je     800bdf <strtol+0xd3>
		*endptr = (char *) s;
  800bda:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bdd:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800bdf:	89 ca                	mov    %ecx,%edx
  800be1:	f7 da                	neg    %edx
  800be3:	85 ff                	test   %edi,%edi
  800be5:	0f 45 c2             	cmovne %edx,%eax
}
  800be8:	83 c4 04             	add    $0x4,%esp
  800beb:	5b                   	pop    %ebx
  800bec:	5e                   	pop    %esi
  800bed:	5f                   	pop    %edi
  800bee:	5d                   	pop    %ebp
  800bef:	c3                   	ret    

00800bf0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bf0:	55                   	push   %ebp
  800bf1:	89 e5                	mov    %esp,%ebp
  800bf3:	83 ec 0c             	sub    $0xc,%esp
  800bf6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800bf9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800bfc:	89 7d fc             	mov    %edi,-0x4(%ebp)
static inline uint32_t

get_cpu_features(void)
{
	uint32_t feature;
	__asm __volatile(" movl $1, %%eax\n\t"
  800bff:	b8 01 00 00 00       	mov    $0x1,%eax
  800c04:	0f a2                	cpuid  
  800c06:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c08:	b8 00 00 00 00       	mov    $0x0,%eax
  800c0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c10:	8b 55 08             	mov    0x8(%ebp),%edx
  800c13:	89 c3                	mov    %eax,%ebx
  800c15:	89 c7                	mov    %eax,%edi
  800c17:	89 c6                	mov    %eax,%esi
  800c19:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c1b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c1e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c21:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c24:	89 ec                	mov    %ebp,%esp
  800c26:	5d                   	pop    %ebp
  800c27:	c3                   	ret    

00800c28 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c28:	55                   	push   %ebp
  800c29:	89 e5                	mov    %esp,%ebp
  800c2b:	83 ec 0c             	sub    $0xc,%esp
  800c2e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c31:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c34:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800c37:	b8 01 00 00 00       	mov    $0x1,%eax
  800c3c:	0f a2                	cpuid  
  800c3e:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c40:	ba 00 00 00 00       	mov    $0x0,%edx
  800c45:	b8 01 00 00 00       	mov    $0x1,%eax
  800c4a:	89 d1                	mov    %edx,%ecx
  800c4c:	89 d3                	mov    %edx,%ebx
  800c4e:	89 d7                	mov    %edx,%edi
  800c50:	89 d6                	mov    %edx,%esi
  800c52:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c54:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c57:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c5a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c5d:	89 ec                	mov    %ebp,%esp
  800c5f:	5d                   	pop    %ebp
  800c60:	c3                   	ret    

00800c61 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c61:	55                   	push   %ebp
  800c62:	89 e5                	mov    %esp,%ebp
  800c64:	83 ec 38             	sub    $0x38,%esp
  800c67:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c6a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c6d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800c70:	b8 01 00 00 00       	mov    $0x1,%eax
  800c75:	0f a2                	cpuid  
  800c77:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c79:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c7e:	b8 03 00 00 00       	mov    $0x3,%eax
  800c83:	8b 55 08             	mov    0x8(%ebp),%edx
  800c86:	89 cb                	mov    %ecx,%ebx
  800c88:	89 cf                	mov    %ecx,%edi
  800c8a:	89 ce                	mov    %ecx,%esi
  800c8c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c8e:	85 c0                	test   %eax,%eax
  800c90:	7e 28                	jle    800cba <sys_env_destroy+0x59>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c92:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c96:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c9d:	00 
  800c9e:	c7 44 24 08 df 1f 80 	movl   $0x801fdf,0x8(%esp)
  800ca5:	00 
  800ca6:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800cad:	00 
  800cae:	c7 04 24 fc 1f 80 00 	movl   $0x801ffc,(%esp)
  800cb5:	e8 96 0b 00 00       	call   801850 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cba:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cbd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cc0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cc3:	89 ec                	mov    %ebp,%esp
  800cc5:	5d                   	pop    %ebp
  800cc6:	c3                   	ret    

00800cc7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cc7:	55                   	push   %ebp
  800cc8:	89 e5                	mov    %esp,%ebp
  800cca:	83 ec 0c             	sub    $0xc,%esp
  800ccd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cd0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cd3:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800cd6:	b8 01 00 00 00       	mov    $0x1,%eax
  800cdb:	0f a2                	cpuid  
  800cdd:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cdf:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce4:	b8 02 00 00 00       	mov    $0x2,%eax
  800ce9:	89 d1                	mov    %edx,%ecx
  800ceb:	89 d3                	mov    %edx,%ebx
  800ced:	89 d7                	mov    %edx,%edi
  800cef:	89 d6                	mov    %edx,%esi
  800cf1:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cf3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cf6:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cf9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cfc:	89 ec                	mov    %ebp,%esp
  800cfe:	5d                   	pop    %ebp
  800cff:	c3                   	ret    

00800d00 <sys_yield>:

void
sys_yield(void)
{
  800d00:	55                   	push   %ebp
  800d01:	89 e5                	mov    %esp,%ebp
  800d03:	83 ec 0c             	sub    $0xc,%esp
  800d06:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d09:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d0c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d0f:	b8 01 00 00 00       	mov    $0x1,%eax
  800d14:	0f a2                	cpuid  
  800d16:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d18:	ba 00 00 00 00       	mov    $0x0,%edx
  800d1d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d22:	89 d1                	mov    %edx,%ecx
  800d24:	89 d3                	mov    %edx,%ebx
  800d26:	89 d7                	mov    %edx,%edi
  800d28:	89 d6                	mov    %edx,%esi
  800d2a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d2c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d2f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d32:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d35:	89 ec                	mov    %ebp,%esp
  800d37:	5d                   	pop    %ebp
  800d38:	c3                   	ret    

00800d39 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d39:	55                   	push   %ebp
  800d3a:	89 e5                	mov    %esp,%ebp
  800d3c:	83 ec 38             	sub    $0x38,%esp
  800d3f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d42:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d45:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d48:	b8 01 00 00 00       	mov    $0x1,%eax
  800d4d:	0f a2                	cpuid  
  800d4f:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d51:	be 00 00 00 00       	mov    $0x0,%esi
  800d56:	b8 04 00 00 00       	mov    $0x4,%eax
  800d5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d61:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d64:	89 f7                	mov    %esi,%edi
  800d66:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d68:	85 c0                	test   %eax,%eax
  800d6a:	7e 28                	jle    800d94 <sys_page_alloc+0x5b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d70:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d77:	00 
  800d78:	c7 44 24 08 df 1f 80 	movl   $0x801fdf,0x8(%esp)
  800d7f:	00 
  800d80:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800d87:	00 
  800d88:	c7 04 24 fc 1f 80 00 	movl   $0x801ffc,(%esp)
  800d8f:	e8 bc 0a 00 00       	call   801850 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d94:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d97:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d9a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d9d:	89 ec                	mov    %ebp,%esp
  800d9f:	5d                   	pop    %ebp
  800da0:	c3                   	ret    

00800da1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800da1:	55                   	push   %ebp
  800da2:	89 e5                	mov    %esp,%ebp
  800da4:	83 ec 38             	sub    $0x38,%esp
  800da7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800daa:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dad:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800db0:	b8 01 00 00 00       	mov    $0x1,%eax
  800db5:	0f a2                	cpuid  
  800db7:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db9:	b8 05 00 00 00       	mov    $0x5,%eax
  800dbe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc1:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dc7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dca:	8b 75 18             	mov    0x18(%ebp),%esi
  800dcd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dcf:	85 c0                	test   %eax,%eax
  800dd1:	7e 28                	jle    800dfb <sys_page_map+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dd7:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800dde:	00 
  800ddf:	c7 44 24 08 df 1f 80 	movl   $0x801fdf,0x8(%esp)
  800de6:	00 
  800de7:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800dee:	00 
  800def:	c7 04 24 fc 1f 80 00 	movl   $0x801ffc,(%esp)
  800df6:	e8 55 0a 00 00       	call   801850 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800dfb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dfe:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e01:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e04:	89 ec                	mov    %ebp,%esp
  800e06:	5d                   	pop    %ebp
  800e07:	c3                   	ret    

00800e08 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e08:	55                   	push   %ebp
  800e09:	89 e5                	mov    %esp,%ebp
  800e0b:	83 ec 38             	sub    $0x38,%esp
  800e0e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e11:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e14:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e17:	b8 01 00 00 00       	mov    $0x1,%eax
  800e1c:	0f a2                	cpuid  
  800e1e:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e20:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e25:	b8 06 00 00 00       	mov    $0x6,%eax
  800e2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e30:	89 df                	mov    %ebx,%edi
  800e32:	89 de                	mov    %ebx,%esi
  800e34:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e36:	85 c0                	test   %eax,%eax
  800e38:	7e 28                	jle    800e62 <sys_page_unmap+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e3a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e3e:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e45:	00 
  800e46:	c7 44 24 08 df 1f 80 	movl   $0x801fdf,0x8(%esp)
  800e4d:	00 
  800e4e:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800e55:	00 
  800e56:	c7 04 24 fc 1f 80 00 	movl   $0x801ffc,(%esp)
  800e5d:	e8 ee 09 00 00       	call   801850 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e62:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e65:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e68:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e6b:	89 ec                	mov    %ebp,%esp
  800e6d:	5d                   	pop    %ebp
  800e6e:	c3                   	ret    

00800e6f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e6f:	55                   	push   %ebp
  800e70:	89 e5                	mov    %esp,%ebp
  800e72:	83 ec 38             	sub    $0x38,%esp
  800e75:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e78:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e7b:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e7e:	b8 01 00 00 00       	mov    $0x1,%eax
  800e83:	0f a2                	cpuid  
  800e85:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e87:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e8c:	b8 08 00 00 00       	mov    $0x8,%eax
  800e91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e94:	8b 55 08             	mov    0x8(%ebp),%edx
  800e97:	89 df                	mov    %ebx,%edi
  800e99:	89 de                	mov    %ebx,%esi
  800e9b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e9d:	85 c0                	test   %eax,%eax
  800e9f:	7e 28                	jle    800ec9 <sys_env_set_status+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ea5:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800eac:	00 
  800ead:	c7 44 24 08 df 1f 80 	movl   $0x801fdf,0x8(%esp)
  800eb4:	00 
  800eb5:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800ebc:	00 
  800ebd:	c7 04 24 fc 1f 80 00 	movl   $0x801ffc,(%esp)
  800ec4:	e8 87 09 00 00       	call   801850 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ec9:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ecc:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ecf:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ed2:	89 ec                	mov    %ebp,%esp
  800ed4:	5d                   	pop    %ebp
  800ed5:	c3                   	ret    

00800ed6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ed6:	55                   	push   %ebp
  800ed7:	89 e5                	mov    %esp,%ebp
  800ed9:	83 ec 38             	sub    $0x38,%esp
  800edc:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800edf:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ee2:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800ee5:	b8 01 00 00 00       	mov    $0x1,%eax
  800eea:	0f a2                	cpuid  
  800eec:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eee:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ef3:	b8 09 00 00 00       	mov    $0x9,%eax
  800ef8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800efb:	8b 55 08             	mov    0x8(%ebp),%edx
  800efe:	89 df                	mov    %ebx,%edi
  800f00:	89 de                	mov    %ebx,%esi
  800f02:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f04:	85 c0                	test   %eax,%eax
  800f06:	7e 28                	jle    800f30 <sys_env_set_trapframe+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f08:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f0c:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f13:	00 
  800f14:	c7 44 24 08 df 1f 80 	movl   $0x801fdf,0x8(%esp)
  800f1b:	00 
  800f1c:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800f23:	00 
  800f24:	c7 04 24 fc 1f 80 00 	movl   $0x801ffc,(%esp)
  800f2b:	e8 20 09 00 00       	call   801850 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f30:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f33:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f36:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f39:	89 ec                	mov    %ebp,%esp
  800f3b:	5d                   	pop    %ebp
  800f3c:	c3                   	ret    

00800f3d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f3d:	55                   	push   %ebp
  800f3e:	89 e5                	mov    %esp,%ebp
  800f40:	83 ec 38             	sub    $0x38,%esp
  800f43:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f46:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f49:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800f4c:	b8 01 00 00 00       	mov    $0x1,%eax
  800f51:	0f a2                	cpuid  
  800f53:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f55:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f5a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f62:	8b 55 08             	mov    0x8(%ebp),%edx
  800f65:	89 df                	mov    %ebx,%edi
  800f67:	89 de                	mov    %ebx,%esi
  800f69:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f6b:	85 c0                	test   %eax,%eax
  800f6d:	7e 28                	jle    800f97 <sys_env_set_pgfault_upcall+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f6f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f73:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800f7a:	00 
  800f7b:	c7 44 24 08 df 1f 80 	movl   $0x801fdf,0x8(%esp)
  800f82:	00 
  800f83:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800f8a:	00 
  800f8b:	c7 04 24 fc 1f 80 00 	movl   $0x801ffc,(%esp)
  800f92:	e8 b9 08 00 00       	call   801850 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f97:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f9a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f9d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fa0:	89 ec                	mov    %ebp,%esp
  800fa2:	5d                   	pop    %ebp
  800fa3:	c3                   	ret    

00800fa4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fa4:	55                   	push   %ebp
  800fa5:	89 e5                	mov    %esp,%ebp
  800fa7:	83 ec 0c             	sub    $0xc,%esp
  800faa:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fad:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fb0:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800fb3:	b8 01 00 00 00       	mov    $0x1,%eax
  800fb8:	0f a2                	cpuid  
  800fba:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fbc:	be 00 00 00 00       	mov    $0x0,%esi
  800fc1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fc6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc9:	8b 55 08             	mov    0x8(%ebp),%edx
  800fcc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fcf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fd2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800fd4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fd7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fda:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fdd:	89 ec                	mov    %ebp,%esp
  800fdf:	5d                   	pop    %ebp
  800fe0:	c3                   	ret    

00800fe1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800fe1:	55                   	push   %ebp
  800fe2:	89 e5                	mov    %esp,%ebp
  800fe4:	83 ec 38             	sub    $0x38,%esp
  800fe7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fea:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fed:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800ff0:	b8 01 00 00 00       	mov    $0x1,%eax
  800ff5:	0f a2                	cpuid  
  800ff7:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ff9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ffe:	b8 0d 00 00 00       	mov    $0xd,%eax
  801003:	8b 55 08             	mov    0x8(%ebp),%edx
  801006:	89 cb                	mov    %ecx,%ebx
  801008:	89 cf                	mov    %ecx,%edi
  80100a:	89 ce                	mov    %ecx,%esi
  80100c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80100e:	85 c0                	test   %eax,%eax
  801010:	7e 28                	jle    80103a <sys_ipc_recv+0x59>
		panic("syscall %d returned %d (> 0)", num, ret);
  801012:	89 44 24 10          	mov    %eax,0x10(%esp)
  801016:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  80101d:	00 
  80101e:	c7 44 24 08 df 1f 80 	movl   $0x801fdf,0x8(%esp)
  801025:	00 
  801026:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  80102d:	00 
  80102e:	c7 04 24 fc 1f 80 00 	movl   $0x801ffc,(%esp)
  801035:	e8 16 08 00 00       	call   801850 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80103a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80103d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801040:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801043:	89 ec                	mov    %ebp,%esp
  801045:	5d                   	pop    %ebp
  801046:	c3                   	ret    
  801047:	66 90                	xchg   %ax,%ax
  801049:	66 90                	xchg   %ax,%ax
  80104b:	66 90                	xchg   %ax,%ax
  80104d:	66 90                	xchg   %ax,%ax
  80104f:	90                   	nop

00801050 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801050:	55                   	push   %ebp
  801051:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801053:	8b 45 08             	mov    0x8(%ebp),%eax
  801056:	05 00 00 00 30       	add    $0x30000000,%eax
  80105b:	c1 e8 0c             	shr    $0xc,%eax
}
  80105e:	5d                   	pop    %ebp
  80105f:	c3                   	ret    

00801060 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801060:	55                   	push   %ebp
  801061:	89 e5                	mov    %esp,%ebp
  801063:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801066:	8b 45 08             	mov    0x8(%ebp),%eax
  801069:	89 04 24             	mov    %eax,(%esp)
  80106c:	e8 df ff ff ff       	call   801050 <fd2num>
  801071:	c1 e0 0c             	shl    $0xc,%eax
  801074:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801079:	c9                   	leave  
  80107a:	c3                   	ret    

0080107b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80107b:	55                   	push   %ebp
  80107c:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  80107e:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801083:	a8 01                	test   $0x1,%al
  801085:	74 34                	je     8010bb <fd_alloc+0x40>
  801087:	a1 00 00 74 ef       	mov    0xef740000,%eax
  80108c:	a8 01                	test   $0x1,%al
  80108e:	74 32                	je     8010c2 <fd_alloc+0x47>
  801090:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801095:	89 c1                	mov    %eax,%ecx
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801097:	89 c2                	mov    %eax,%edx
  801099:	c1 ea 16             	shr    $0x16,%edx
  80109c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010a3:	f6 c2 01             	test   $0x1,%dl
  8010a6:	74 1f                	je     8010c7 <fd_alloc+0x4c>
  8010a8:	89 c2                	mov    %eax,%edx
  8010aa:	c1 ea 0c             	shr    $0xc,%edx
  8010ad:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010b4:	f6 c2 01             	test   $0x1,%dl
  8010b7:	75 1a                	jne    8010d3 <fd_alloc+0x58>
  8010b9:	eb 0c                	jmp    8010c7 <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8010bb:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8010c0:	eb 05                	jmp    8010c7 <fd_alloc+0x4c>
  8010c2:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8010c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ca:	89 08                	mov    %ecx,(%eax)
			return 0;
  8010cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8010d1:	eb 1a                	jmp    8010ed <fd_alloc+0x72>
  8010d3:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010d8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010dd:	75 b6                	jne    801095 <fd_alloc+0x1a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010df:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  8010e8:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010ed:	5d                   	pop    %ebp
  8010ee:	c3                   	ret    

008010ef <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010ef:	55                   	push   %ebp
  8010f0:	89 e5                	mov    %esp,%ebp
  8010f2:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010f5:	83 f8 1f             	cmp    $0x1f,%eax
  8010f8:	77 36                	ja     801130 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010fa:	c1 e0 0c             	shl    $0xc,%eax
  8010fd:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801102:	89 c2                	mov    %eax,%edx
  801104:	c1 ea 16             	shr    $0x16,%edx
  801107:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80110e:	f6 c2 01             	test   $0x1,%dl
  801111:	74 24                	je     801137 <fd_lookup+0x48>
  801113:	89 c2                	mov    %eax,%edx
  801115:	c1 ea 0c             	shr    $0xc,%edx
  801118:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80111f:	f6 c2 01             	test   $0x1,%dl
  801122:	74 1a                	je     80113e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801124:	8b 55 0c             	mov    0xc(%ebp),%edx
  801127:	89 02                	mov    %eax,(%edx)
	return 0;
  801129:	b8 00 00 00 00       	mov    $0x0,%eax
  80112e:	eb 13                	jmp    801143 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  801130:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801135:	eb 0c                	jmp    801143 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  801137:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80113c:	eb 05                	jmp    801143 <fd_lookup+0x54>
  80113e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801143:	5d                   	pop    %ebp
  801144:	c3                   	ret    

00801145 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801145:	55                   	push   %ebp
  801146:	89 e5                	mov    %esp,%ebp
  801148:	83 ec 18             	sub    $0x18,%esp
  80114b:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80114e:	39 05 04 30 80 00    	cmp    %eax,0x803004
  801154:	75 10                	jne    801166 <dev_lookup+0x21>
			*dev = devtab[i];
  801156:	8b 45 0c             	mov    0xc(%ebp),%eax
  801159:	c7 00 04 30 80 00    	movl   $0x803004,(%eax)
			return 0;
  80115f:	b8 00 00 00 00       	mov    $0x0,%eax
  801164:	eb 2b                	jmp    801191 <dev_lookup+0x4c>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801166:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80116c:	8b 52 48             	mov    0x48(%edx),%edx
  80116f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801173:	89 54 24 04          	mov    %edx,0x4(%esp)
  801177:	c7 04 24 0c 20 80 00 	movl   $0x80200c,(%esp)
  80117e:	e8 ec ef ff ff       	call   80016f <cprintf>
	*dev = 0;
  801183:	8b 55 0c             	mov    0xc(%ebp),%edx
  801186:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	return -E_INVAL;
  80118c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801191:	c9                   	leave  
  801192:	c3                   	ret    

00801193 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801193:	55                   	push   %ebp
  801194:	89 e5                	mov    %esp,%ebp
  801196:	83 ec 38             	sub    $0x38,%esp
  801199:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80119c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80119f:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8011a2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011a5:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011a8:	89 3c 24             	mov    %edi,(%esp)
  8011ab:	e8 a0 fe ff ff       	call   801050 <fd2num>
  8011b0:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8011b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8011b7:	89 04 24             	mov    %eax,(%esp)
  8011ba:	e8 30 ff ff ff       	call   8010ef <fd_lookup>
  8011bf:	89 c3                	mov    %eax,%ebx
  8011c1:	85 c0                	test   %eax,%eax
  8011c3:	78 05                	js     8011ca <fd_close+0x37>
	    || fd != fd2)
  8011c5:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  8011c8:	74 0c                	je     8011d6 <fd_close+0x43>
		return (must_exist ? r : 0);
  8011ca:	85 f6                	test   %esi,%esi
  8011cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8011d1:	0f 44 d8             	cmove  %eax,%ebx
  8011d4:	eb 3d                	jmp    801213 <fd_close+0x80>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011d6:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8011d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011dd:	8b 07                	mov    (%edi),%eax
  8011df:	89 04 24             	mov    %eax,(%esp)
  8011e2:	e8 5e ff ff ff       	call   801145 <dev_lookup>
  8011e7:	89 c3                	mov    %eax,%ebx
  8011e9:	85 c0                	test   %eax,%eax
  8011eb:	78 16                	js     801203 <fd_close+0x70>
		if (dev->dev_close)
  8011ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8011f0:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8011f3:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8011f8:	85 c0                	test   %eax,%eax
  8011fa:	74 07                	je     801203 <fd_close+0x70>
			r = (*dev->dev_close)(fd);
  8011fc:	89 3c 24             	mov    %edi,(%esp)
  8011ff:	ff d0                	call   *%eax
  801201:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801203:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801207:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80120e:	e8 f5 fb ff ff       	call   800e08 <sys_page_unmap>
	return r;
}
  801213:	89 d8                	mov    %ebx,%eax
  801215:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801218:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80121b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80121e:	89 ec                	mov    %ebp,%esp
  801220:	5d                   	pop    %ebp
  801221:	c3                   	ret    

00801222 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801222:	55                   	push   %ebp
  801223:	89 e5                	mov    %esp,%ebp
  801225:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801228:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80122b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80122f:	8b 45 08             	mov    0x8(%ebp),%eax
  801232:	89 04 24             	mov    %eax,(%esp)
  801235:	e8 b5 fe ff ff       	call   8010ef <fd_lookup>
  80123a:	85 c0                	test   %eax,%eax
  80123c:	78 13                	js     801251 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80123e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801245:	00 
  801246:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801249:	89 04 24             	mov    %eax,(%esp)
  80124c:	e8 42 ff ff ff       	call   801193 <fd_close>
}
  801251:	c9                   	leave  
  801252:	c3                   	ret    

00801253 <close_all>:

void
close_all(void)
{
  801253:	55                   	push   %ebp
  801254:	89 e5                	mov    %esp,%ebp
  801256:	53                   	push   %ebx
  801257:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80125a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80125f:	89 1c 24             	mov    %ebx,(%esp)
  801262:	e8 bb ff ff ff       	call   801222 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801267:	83 c3 01             	add    $0x1,%ebx
  80126a:	83 fb 20             	cmp    $0x20,%ebx
  80126d:	75 f0                	jne    80125f <close_all+0xc>
		close(i);
}
  80126f:	83 c4 14             	add    $0x14,%esp
  801272:	5b                   	pop    %ebx
  801273:	5d                   	pop    %ebp
  801274:	c3                   	ret    

00801275 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801275:	55                   	push   %ebp
  801276:	89 e5                	mov    %esp,%ebp
  801278:	83 ec 58             	sub    $0x58,%esp
  80127b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80127e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801281:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801284:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801287:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80128a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80128e:	8b 45 08             	mov    0x8(%ebp),%eax
  801291:	89 04 24             	mov    %eax,(%esp)
  801294:	e8 56 fe ff ff       	call   8010ef <fd_lookup>
  801299:	85 c0                	test   %eax,%eax
  80129b:	0f 88 e3 00 00 00    	js     801384 <dup+0x10f>
		return r;
	close(newfdnum);
  8012a1:	89 1c 24             	mov    %ebx,(%esp)
  8012a4:	e8 79 ff ff ff       	call   801222 <close>

	newfd = INDEX2FD(newfdnum);
  8012a9:	89 de                	mov    %ebx,%esi
  8012ab:	c1 e6 0c             	shl    $0xc,%esi
  8012ae:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8012b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012b7:	89 04 24             	mov    %eax,(%esp)
  8012ba:	e8 a1 fd ff ff       	call   801060 <fd2data>
  8012bf:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8012c1:	89 34 24             	mov    %esi,(%esp)
  8012c4:	e8 97 fd ff ff       	call   801060 <fd2data>
  8012c9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  8012cc:	89 f8                	mov    %edi,%eax
  8012ce:	c1 e8 16             	shr    $0x16,%eax
  8012d1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012d8:	a8 01                	test   $0x1,%al
  8012da:	74 46                	je     801322 <dup+0xad>
  8012dc:	89 f8                	mov    %edi,%eax
  8012de:	c1 e8 0c             	shr    $0xc,%eax
  8012e1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012e8:	f6 c2 01             	test   $0x1,%dl
  8012eb:	74 35                	je     801322 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012ed:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012f4:	25 07 0e 00 00       	and    $0xe07,%eax
  8012f9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012fd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801300:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801304:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80130b:	00 
  80130c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801310:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801317:	e8 85 fa ff ff       	call   800da1 <sys_page_map>
  80131c:	89 c7                	mov    %eax,%edi
  80131e:	85 c0                	test   %eax,%eax
  801320:	78 3b                	js     80135d <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801322:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801325:	89 c2                	mov    %eax,%edx
  801327:	c1 ea 0c             	shr    $0xc,%edx
  80132a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801331:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801337:	89 54 24 10          	mov    %edx,0x10(%esp)
  80133b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80133f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801346:	00 
  801347:	89 44 24 04          	mov    %eax,0x4(%esp)
  80134b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801352:	e8 4a fa ff ff       	call   800da1 <sys_page_map>
  801357:	89 c7                	mov    %eax,%edi
  801359:	85 c0                	test   %eax,%eax
  80135b:	79 29                	jns    801386 <dup+0x111>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80135d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801361:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801368:	e8 9b fa ff ff       	call   800e08 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80136d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801370:	89 44 24 04          	mov    %eax,0x4(%esp)
  801374:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80137b:	e8 88 fa ff ff       	call   800e08 <sys_page_unmap>
	return r;
  801380:	89 fb                	mov    %edi,%ebx
  801382:	eb 02                	jmp    801386 <dup+0x111>
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
		return r;
  801384:	89 c3                	mov    %eax,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801386:	89 d8                	mov    %ebx,%eax
  801388:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80138b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80138e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801391:	89 ec                	mov    %ebp,%esp
  801393:	5d                   	pop    %ebp
  801394:	c3                   	ret    

00801395 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801395:	55                   	push   %ebp
  801396:	89 e5                	mov    %esp,%ebp
  801398:	53                   	push   %ebx
  801399:	83 ec 24             	sub    $0x24,%esp
  80139c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80139f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013a6:	89 1c 24             	mov    %ebx,(%esp)
  8013a9:	e8 41 fd ff ff       	call   8010ef <fd_lookup>
  8013ae:	85 c0                	test   %eax,%eax
  8013b0:	78 6d                	js     80141f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013bc:	8b 00                	mov    (%eax),%eax
  8013be:	89 04 24             	mov    %eax,(%esp)
  8013c1:	e8 7f fd ff ff       	call   801145 <dev_lookup>
  8013c6:	85 c0                	test   %eax,%eax
  8013c8:	78 55                	js     80141f <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013cd:	8b 50 08             	mov    0x8(%eax),%edx
  8013d0:	83 e2 03             	and    $0x3,%edx
  8013d3:	83 fa 01             	cmp    $0x1,%edx
  8013d6:	75 23                	jne    8013fb <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013d8:	a1 04 40 80 00       	mov    0x804004,%eax
  8013dd:	8b 40 48             	mov    0x48(%eax),%eax
  8013e0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013e8:	c7 04 24 4d 20 80 00 	movl   $0x80204d,(%esp)
  8013ef:	e8 7b ed ff ff       	call   80016f <cprintf>
		return -E_INVAL;
  8013f4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013f9:	eb 24                	jmp    80141f <read+0x8a>
	}
	if (!dev->dev_read)
  8013fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013fe:	8b 52 08             	mov    0x8(%edx),%edx
  801401:	85 d2                	test   %edx,%edx
  801403:	74 15                	je     80141a <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801405:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801408:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80140c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80140f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801413:	89 04 24             	mov    %eax,(%esp)
  801416:	ff d2                	call   *%edx
  801418:	eb 05                	jmp    80141f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80141a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80141f:	83 c4 24             	add    $0x24,%esp
  801422:	5b                   	pop    %ebx
  801423:	5d                   	pop    %ebp
  801424:	c3                   	ret    

00801425 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801425:	55                   	push   %ebp
  801426:	89 e5                	mov    %esp,%ebp
  801428:	57                   	push   %edi
  801429:	56                   	push   %esi
  80142a:	53                   	push   %ebx
  80142b:	83 ec 1c             	sub    $0x1c,%esp
  80142e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801431:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801434:	85 f6                	test   %esi,%esi
  801436:	74 33                	je     80146b <readn+0x46>
  801438:	b8 00 00 00 00       	mov    $0x0,%eax
  80143d:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801442:	89 f2                	mov    %esi,%edx
  801444:	29 c2                	sub    %eax,%edx
  801446:	89 54 24 08          	mov    %edx,0x8(%esp)
  80144a:	03 45 0c             	add    0xc(%ebp),%eax
  80144d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801451:	89 3c 24             	mov    %edi,(%esp)
  801454:	e8 3c ff ff ff       	call   801395 <read>
		if (m < 0)
  801459:	85 c0                	test   %eax,%eax
  80145b:	78 17                	js     801474 <readn+0x4f>
			return m;
		if (m == 0)
  80145d:	85 c0                	test   %eax,%eax
  80145f:	74 11                	je     801472 <readn+0x4d>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801461:	01 c3                	add    %eax,%ebx
  801463:	89 d8                	mov    %ebx,%eax
  801465:	39 f3                	cmp    %esi,%ebx
  801467:	72 d9                	jb     801442 <readn+0x1d>
  801469:	eb 09                	jmp    801474 <readn+0x4f>
  80146b:	b8 00 00 00 00       	mov    $0x0,%eax
  801470:	eb 02                	jmp    801474 <readn+0x4f>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801472:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801474:	83 c4 1c             	add    $0x1c,%esp
  801477:	5b                   	pop    %ebx
  801478:	5e                   	pop    %esi
  801479:	5f                   	pop    %edi
  80147a:	5d                   	pop    %ebp
  80147b:	c3                   	ret    

0080147c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80147c:	55                   	push   %ebp
  80147d:	89 e5                	mov    %esp,%ebp
  80147f:	53                   	push   %ebx
  801480:	83 ec 24             	sub    $0x24,%esp
  801483:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801486:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801489:	89 44 24 04          	mov    %eax,0x4(%esp)
  80148d:	89 1c 24             	mov    %ebx,(%esp)
  801490:	e8 5a fc ff ff       	call   8010ef <fd_lookup>
  801495:	85 c0                	test   %eax,%eax
  801497:	78 68                	js     801501 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801499:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80149c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014a3:	8b 00                	mov    (%eax),%eax
  8014a5:	89 04 24             	mov    %eax,(%esp)
  8014a8:	e8 98 fc ff ff       	call   801145 <dev_lookup>
  8014ad:	85 c0                	test   %eax,%eax
  8014af:	78 50                	js     801501 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014b4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014b8:	75 23                	jne    8014dd <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014ba:	a1 04 40 80 00       	mov    0x804004,%eax
  8014bf:	8b 40 48             	mov    0x48(%eax),%eax
  8014c2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014ca:	c7 04 24 69 20 80 00 	movl   $0x802069,(%esp)
  8014d1:	e8 99 ec ff ff       	call   80016f <cprintf>
		return -E_INVAL;
  8014d6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014db:	eb 24                	jmp    801501 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014e0:	8b 52 0c             	mov    0xc(%edx),%edx
  8014e3:	85 d2                	test   %edx,%edx
  8014e5:	74 15                	je     8014fc <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014e7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8014ea:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014f1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8014f5:	89 04 24             	mov    %eax,(%esp)
  8014f8:	ff d2                	call   *%edx
  8014fa:	eb 05                	jmp    801501 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014fc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801501:	83 c4 24             	add    $0x24,%esp
  801504:	5b                   	pop    %ebx
  801505:	5d                   	pop    %ebp
  801506:	c3                   	ret    

00801507 <seek>:

int
seek(int fdnum, off_t offset)
{
  801507:	55                   	push   %ebp
  801508:	89 e5                	mov    %esp,%ebp
  80150a:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80150d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801510:	89 44 24 04          	mov    %eax,0x4(%esp)
  801514:	8b 45 08             	mov    0x8(%ebp),%eax
  801517:	89 04 24             	mov    %eax,(%esp)
  80151a:	e8 d0 fb ff ff       	call   8010ef <fd_lookup>
  80151f:	85 c0                	test   %eax,%eax
  801521:	78 0e                	js     801531 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801523:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801526:	8b 55 0c             	mov    0xc(%ebp),%edx
  801529:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80152c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801531:	c9                   	leave  
  801532:	c3                   	ret    

00801533 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801533:	55                   	push   %ebp
  801534:	89 e5                	mov    %esp,%ebp
  801536:	53                   	push   %ebx
  801537:	83 ec 24             	sub    $0x24,%esp
  80153a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80153d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801540:	89 44 24 04          	mov    %eax,0x4(%esp)
  801544:	89 1c 24             	mov    %ebx,(%esp)
  801547:	e8 a3 fb ff ff       	call   8010ef <fd_lookup>
  80154c:	85 c0                	test   %eax,%eax
  80154e:	78 61                	js     8015b1 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801550:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801553:	89 44 24 04          	mov    %eax,0x4(%esp)
  801557:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80155a:	8b 00                	mov    (%eax),%eax
  80155c:	89 04 24             	mov    %eax,(%esp)
  80155f:	e8 e1 fb ff ff       	call   801145 <dev_lookup>
  801564:	85 c0                	test   %eax,%eax
  801566:	78 49                	js     8015b1 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801568:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80156b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80156f:	75 23                	jne    801594 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801571:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801576:	8b 40 48             	mov    0x48(%eax),%eax
  801579:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80157d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801581:	c7 04 24 2c 20 80 00 	movl   $0x80202c,(%esp)
  801588:	e8 e2 eb ff ff       	call   80016f <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80158d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801592:	eb 1d                	jmp    8015b1 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801594:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801597:	8b 52 18             	mov    0x18(%edx),%edx
  80159a:	85 d2                	test   %edx,%edx
  80159c:	74 0e                	je     8015ac <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80159e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015a1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8015a5:	89 04 24             	mov    %eax,(%esp)
  8015a8:	ff d2                	call   *%edx
  8015aa:	eb 05                	jmp    8015b1 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015ac:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8015b1:	83 c4 24             	add    $0x24,%esp
  8015b4:	5b                   	pop    %ebx
  8015b5:	5d                   	pop    %ebp
  8015b6:	c3                   	ret    

008015b7 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015b7:	55                   	push   %ebp
  8015b8:	89 e5                	mov    %esp,%ebp
  8015ba:	53                   	push   %ebx
  8015bb:	83 ec 24             	sub    $0x24,%esp
  8015be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015c1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8015cb:	89 04 24             	mov    %eax,(%esp)
  8015ce:	e8 1c fb ff ff       	call   8010ef <fd_lookup>
  8015d3:	85 c0                	test   %eax,%eax
  8015d5:	78 52                	js     801629 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e1:	8b 00                	mov    (%eax),%eax
  8015e3:	89 04 24             	mov    %eax,(%esp)
  8015e6:	e8 5a fb ff ff       	call   801145 <dev_lookup>
  8015eb:	85 c0                	test   %eax,%eax
  8015ed:	78 3a                	js     801629 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8015ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015f2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015f6:	74 2c                	je     801624 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015f8:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015fb:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801602:	00 00 00 
	stat->st_isdir = 0;
  801605:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80160c:	00 00 00 
	stat->st_dev = dev;
  80160f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801615:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801619:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80161c:	89 14 24             	mov    %edx,(%esp)
  80161f:	ff 50 14             	call   *0x14(%eax)
  801622:	eb 05                	jmp    801629 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801624:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801629:	83 c4 24             	add    $0x24,%esp
  80162c:	5b                   	pop    %ebx
  80162d:	5d                   	pop    %ebp
  80162e:	c3                   	ret    

0080162f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80162f:	55                   	push   %ebp
  801630:	89 e5                	mov    %esp,%ebp
  801632:	83 ec 18             	sub    $0x18,%esp
  801635:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801638:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80163b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801642:	00 
  801643:	8b 45 08             	mov    0x8(%ebp),%eax
  801646:	89 04 24             	mov    %eax,(%esp)
  801649:	e8 84 01 00 00       	call   8017d2 <open>
  80164e:	89 c3                	mov    %eax,%ebx
  801650:	85 c0                	test   %eax,%eax
  801652:	78 1b                	js     80166f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801654:	8b 45 0c             	mov    0xc(%ebp),%eax
  801657:	89 44 24 04          	mov    %eax,0x4(%esp)
  80165b:	89 1c 24             	mov    %ebx,(%esp)
  80165e:	e8 54 ff ff ff       	call   8015b7 <fstat>
  801663:	89 c6                	mov    %eax,%esi
	close(fd);
  801665:	89 1c 24             	mov    %ebx,(%esp)
  801668:	e8 b5 fb ff ff       	call   801222 <close>
	return r;
  80166d:	89 f3                	mov    %esi,%ebx
}
  80166f:	89 d8                	mov    %ebx,%eax
  801671:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801674:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801677:	89 ec                	mov    %ebp,%esp
  801679:	5d                   	pop    %ebp
  80167a:	c3                   	ret    
  80167b:	90                   	nop

0080167c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80167c:	55                   	push   %ebp
  80167d:	89 e5                	mov    %esp,%ebp
  80167f:	83 ec 18             	sub    $0x18,%esp
  801682:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801685:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801688:	89 c6                	mov    %eax,%esi
  80168a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80168c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801693:	75 11                	jne    8016a6 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801695:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  80169c:	e8 ca 02 00 00       	call   80196b <ipc_find_env>
  8016a1:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016a6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8016ad:	00 
  8016ae:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8016b5:	00 
  8016b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016ba:	a1 00 40 80 00       	mov    0x804000,%eax
  8016bf:	89 04 24             	mov    %eax,(%esp)
  8016c2:	e8 39 02 00 00       	call   801900 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016c7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016ce:	00 
  8016cf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016d3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016da:	e8 c9 01 00 00       	call   8018a8 <ipc_recv>
}
  8016df:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8016e2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8016e5:	89 ec                	mov    %ebp,%esp
  8016e7:	5d                   	pop    %ebp
  8016e8:	c3                   	ret    

008016e9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016e9:	55                   	push   %ebp
  8016ea:	89 e5                	mov    %esp,%ebp
  8016ec:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f2:	8b 40 0c             	mov    0xc(%eax),%eax
  8016f5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016fd:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801702:	ba 00 00 00 00       	mov    $0x0,%edx
  801707:	b8 02 00 00 00       	mov    $0x2,%eax
  80170c:	e8 6b ff ff ff       	call   80167c <fsipc>
}
  801711:	c9                   	leave  
  801712:	c3                   	ret    

00801713 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801713:	55                   	push   %ebp
  801714:	89 e5                	mov    %esp,%ebp
  801716:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801719:	8b 45 08             	mov    0x8(%ebp),%eax
  80171c:	8b 40 0c             	mov    0xc(%eax),%eax
  80171f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801724:	ba 00 00 00 00       	mov    $0x0,%edx
  801729:	b8 06 00 00 00       	mov    $0x6,%eax
  80172e:	e8 49 ff ff ff       	call   80167c <fsipc>
}
  801733:	c9                   	leave  
  801734:	c3                   	ret    

00801735 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801735:	55                   	push   %ebp
  801736:	89 e5                	mov    %esp,%ebp
  801738:	53                   	push   %ebx
  801739:	83 ec 14             	sub    $0x14,%esp
  80173c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80173f:	8b 45 08             	mov    0x8(%ebp),%eax
  801742:	8b 40 0c             	mov    0xc(%eax),%eax
  801745:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80174a:	ba 00 00 00 00       	mov    $0x0,%edx
  80174f:	b8 05 00 00 00       	mov    $0x5,%eax
  801754:	e8 23 ff ff ff       	call   80167c <fsipc>
  801759:	85 c0                	test   %eax,%eax
  80175b:	78 2b                	js     801788 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80175d:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801764:	00 
  801765:	89 1c 24             	mov    %ebx,(%esp)
  801768:	e8 7e f0 ff ff       	call   8007eb <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80176d:	a1 80 50 80 00       	mov    0x805080,%eax
  801772:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801778:	a1 84 50 80 00       	mov    0x805084,%eax
  80177d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801783:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801788:	83 c4 14             	add    $0x14,%esp
  80178b:	5b                   	pop    %ebx
  80178c:	5d                   	pop    %ebp
  80178d:	c3                   	ret    

0080178e <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80178e:	55                   	push   %ebp
  80178f:	89 e5                	mov    %esp,%ebp
  801791:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801794:	c7 44 24 08 86 20 80 	movl   $0x802086,0x8(%esp)
  80179b:	00 
  80179c:	c7 44 24 04 77 00 00 	movl   $0x77,0x4(%esp)
  8017a3:	00 
  8017a4:	c7 04 24 a4 20 80 00 	movl   $0x8020a4,(%esp)
  8017ab:	e8 a0 00 00 00       	call   801850 <_panic>

008017b0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017b0:	55                   	push   %ebp
  8017b1:	89 e5                	mov    %esp,%ebp
  8017b3:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_READ request to the file system server after
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
	panic("devfile_read not implemented");
  8017b6:	c7 44 24 08 af 20 80 	movl   $0x8020af,0x8(%esp)
  8017bd:	00 
  8017be:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
  8017c5:	00 
  8017c6:	c7 04 24 a4 20 80 00 	movl   $0x8020a4,(%esp)
  8017cd:	e8 7e 00 00 00       	call   801850 <_panic>

008017d2 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017d2:	55                   	push   %ebp
  8017d3:	89 e5                	mov    %esp,%ebp
  8017d5:	83 ec 18             	sub    $0x18,%esp
	// Return the file descriptor index.
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
	panic("open not implemented");
  8017d8:	c7 44 24 08 cc 20 80 	movl   $0x8020cc,0x8(%esp)
  8017df:	00 
  8017e0:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  8017e7:	00 
  8017e8:	c7 04 24 a4 20 80 00 	movl   $0x8020a4,(%esp)
  8017ef:	e8 5c 00 00 00       	call   801850 <_panic>

008017f4 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  8017f4:	55                   	push   %ebp
  8017f5:	89 e5                	mov    %esp,%ebp
  8017f7:	53                   	push   %ebx
  8017f8:	83 ec 14             	sub    $0x14,%esp
  8017fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  8017fe:	89 1c 24             	mov    %ebx,(%esp)
  801801:	e8 8a ef ff ff       	call   800790 <strlen>
  801806:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80180b:	7f 21                	jg     80182e <remove+0x3a>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  80180d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801811:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801818:	e8 ce ef ff ff       	call   8007eb <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  80181d:	ba 00 00 00 00       	mov    $0x0,%edx
  801822:	b8 07 00 00 00       	mov    $0x7,%eax
  801827:	e8 50 fe ff ff       	call   80167c <fsipc>
  80182c:	eb 05                	jmp    801833 <remove+0x3f>
// Delete a file
int
remove(const char *path)
{
	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80182e:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
	strcpy(fsipcbuf.remove.req_path, path);
	return fsipc(FSREQ_REMOVE, NULL);
}
  801833:	83 c4 14             	add    $0x14,%esp
  801836:	5b                   	pop    %ebx
  801837:	5d                   	pop    %ebp
  801838:	c3                   	ret    

00801839 <sync>:

// Synchronize disk with buffer cache
int
sync(void)
{
  801839:	55                   	push   %ebp
  80183a:	89 e5                	mov    %esp,%ebp
  80183c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80183f:	ba 00 00 00 00       	mov    $0x0,%edx
  801844:	b8 08 00 00 00       	mov    $0x8,%eax
  801849:	e8 2e fe ff ff       	call   80167c <fsipc>
}
  80184e:	c9                   	leave  
  80184f:	c3                   	ret    

00801850 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801850:	55                   	push   %ebp
  801851:	89 e5                	mov    %esp,%ebp
  801853:	56                   	push   %esi
  801854:	53                   	push   %ebx
  801855:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801858:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80185b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801861:	e8 61 f4 ff ff       	call   800cc7 <sys_getenvid>
  801866:	8b 55 0c             	mov    0xc(%ebp),%edx
  801869:	89 54 24 10          	mov    %edx,0x10(%esp)
  80186d:	8b 55 08             	mov    0x8(%ebp),%edx
  801870:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801874:	89 74 24 08          	mov    %esi,0x8(%esp)
  801878:	89 44 24 04          	mov    %eax,0x4(%esp)
  80187c:	c7 04 24 e4 20 80 00 	movl   $0x8020e4,(%esp)
  801883:	e8 e7 e8 ff ff       	call   80016f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801888:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80188c:	8b 45 10             	mov    0x10(%ebp),%eax
  80188f:	89 04 24             	mov    %eax,(%esp)
  801892:	e8 77 e8 ff ff       	call   80010e <vcprintf>
	cprintf("\n");
  801897:	c7 04 24 ac 1c 80 00 	movl   $0x801cac,(%esp)
  80189e:	e8 cc e8 ff ff       	call   80016f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8018a3:	cc                   	int3   
  8018a4:	eb fd                	jmp    8018a3 <_panic+0x53>
  8018a6:	66 90                	xchg   %ax,%ax

008018a8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8018a8:	55                   	push   %ebp
  8018a9:	89 e5                	mov    %esp,%ebp
  8018ab:	56                   	push   %esi
  8018ac:	53                   	push   %ebx
  8018ad:	83 ec 10             	sub    $0x10,%esp
  8018b0:	8b 75 08             	mov    0x8(%ebp),%esi
  8018b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	// 	return thisenv->env_ipc_value;
	// }
	int r;
	if(pg == NULL)
		pg = (void *)~0x0;
  8018b6:	85 db                	test   %ebx,%ebx
  8018b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8018bd:	0f 44 d8             	cmove  %eax,%ebx
	//else
	if((r = sys_ipc_recv(pg)) < 0)
  8018c0:	89 1c 24             	mov    %ebx,(%esp)
  8018c3:	e8 19 f7 ff ff       	call   800fe1 <sys_ipc_recv>
  8018c8:	85 c0                	test   %eax,%eax
  8018ca:	78 2d                	js     8018f9 <ipc_recv+0x51>
		return r;
	//volatile struct Env *curenv = (struct Env*)envs+ENVX(sys_getenvid());

	if(from_env_store)
  8018cc:	85 f6                	test   %esi,%esi
  8018ce:	74 0a                	je     8018da <ipc_recv+0x32>
		*from_env_store = thisenv -> env_ipc_from;
  8018d0:	a1 04 40 80 00       	mov    0x804004,%eax
  8018d5:	8b 40 74             	mov    0x74(%eax),%eax
  8018d8:	89 06                	mov    %eax,(%esi)
	if(pg && perm_store)
  8018da:	85 db                	test   %ebx,%ebx
  8018dc:	74 13                	je     8018f1 <ipc_recv+0x49>
  8018de:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018e2:	74 0d                	je     8018f1 <ipc_recv+0x49>
		*perm_store = thisenv -> env_ipc_perm;
  8018e4:	a1 04 40 80 00       	mov    0x804004,%eax
  8018e9:	8b 40 78             	mov    0x78(%eax),%eax
  8018ec:	8b 55 10             	mov    0x10(%ebp),%edx
  8018ef:	89 02                	mov    %eax,(%edx)
	else if(perm_store)
		perm_store = (int *)0;
	return thisenv->env_ipc_value;
  8018f1:	a1 04 40 80 00       	mov    0x804004,%eax
  8018f6:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  8018f9:	83 c4 10             	add    $0x10,%esp
  8018fc:	5b                   	pop    %ebx
  8018fd:	5e                   	pop    %esi
  8018fe:	5d                   	pop    %ebp
  8018ff:	c3                   	ret    

00801900 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801900:	55                   	push   %ebp
  801901:	89 e5                	mov    %esp,%ebp
  801903:	57                   	push   %edi
  801904:	56                   	push   %esi
  801905:	53                   	push   %ebx
  801906:	83 ec 1c             	sub    $0x1c,%esp
  801909:	8b 7d 08             	mov    0x8(%ebp),%edi
  80190c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80190f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

	if(pg == NULL)
  801912:	85 db                	test   %ebx,%ebx
		pg = (void *)~0x0;
  801914:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801919:	0f 44 d8             	cmove  %eax,%ebx
  80191c:	eb 2a                	jmp    801948 <ipc_send+0x48>
	while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0){
		if(r != -E_IPC_NOT_RECV)
  80191e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801921:	74 20                	je     801943 <ipc_send+0x43>
            panic("Send message error %e\n",r);
  801923:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801927:	c7 44 24 08 08 21 80 	movl   $0x802108,0x8(%esp)
  80192e:	00 
  80192f:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  801936:	00 
  801937:	c7 04 24 1f 21 80 00 	movl   $0x80211f,(%esp)
  80193e:	e8 0d ff ff ff       	call   801850 <_panic>
		sys_yield();
  801943:	e8 b8 f3 ff ff       	call   800d00 <sys_yield>
	// LAB 4: Your code here.
	int r;

	if(pg == NULL)
		pg = (void *)~0x0;
	while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0){
  801948:	8b 45 14             	mov    0x14(%ebp),%eax
  80194b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80194f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801953:	89 74 24 04          	mov    %esi,0x4(%esp)
  801957:	89 3c 24             	mov    %edi,(%esp)
  80195a:	e8 45 f6 ff ff       	call   800fa4 <sys_ipc_try_send>
  80195f:	85 c0                	test   %eax,%eax
  801961:	78 bb                	js     80191e <ipc_send+0x1e>
            panic("Send message error %e\n",r);
		sys_yield();
	}

	//panic("ipc_send not implemented");
}
  801963:	83 c4 1c             	add    $0x1c,%esp
  801966:	5b                   	pop    %ebx
  801967:	5e                   	pop    %esi
  801968:	5f                   	pop    %edi
  801969:	5d                   	pop    %ebp
  80196a:	c3                   	ret    

0080196b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80196b:	55                   	push   %ebp
  80196c:	89 e5                	mov    %esp,%ebp
  80196e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801971:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801976:	39 c8                	cmp    %ecx,%eax
  801978:	74 17                	je     801991 <ipc_find_env+0x26>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80197a:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  80197f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801982:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801988:	8b 52 50             	mov    0x50(%edx),%edx
  80198b:	39 ca                	cmp    %ecx,%edx
  80198d:	75 14                	jne    8019a3 <ipc_find_env+0x38>
  80198f:	eb 05                	jmp    801996 <ipc_find_env+0x2b>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801991:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801996:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801999:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  80199e:	8b 40 40             	mov    0x40(%eax),%eax
  8019a1:	eb 0e                	jmp    8019b1 <ipc_find_env+0x46>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8019a3:	83 c0 01             	add    $0x1,%eax
  8019a6:	3d 00 04 00 00       	cmp    $0x400,%eax
  8019ab:	75 d2                	jne    80197f <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8019ad:	66 b8 00 00          	mov    $0x0,%ax
}
  8019b1:	5d                   	pop    %ebp
  8019b2:	c3                   	ret    
  8019b3:	66 90                	xchg   %ax,%ax
  8019b5:	66 90                	xchg   %ax,%ax
  8019b7:	66 90                	xchg   %ax,%ax
  8019b9:	66 90                	xchg   %ax,%ax
  8019bb:	66 90                	xchg   %ax,%ax
  8019bd:	66 90                	xchg   %ax,%ax
  8019bf:	90                   	nop

008019c0 <__udivdi3>:
  8019c0:	83 ec 1c             	sub    $0x1c,%esp
  8019c3:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  8019c7:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8019cb:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8019cf:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8019d3:	8b 7c 24 20          	mov    0x20(%esp),%edi
  8019d7:	8b 6c 24 24          	mov    0x24(%esp),%ebp
  8019db:	85 c0                	test   %eax,%eax
  8019dd:	89 74 24 10          	mov    %esi,0x10(%esp)
  8019e1:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8019e5:	89 ea                	mov    %ebp,%edx
  8019e7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8019eb:	75 33                	jne    801a20 <__udivdi3+0x60>
  8019ed:	39 e9                	cmp    %ebp,%ecx
  8019ef:	77 6f                	ja     801a60 <__udivdi3+0xa0>
  8019f1:	85 c9                	test   %ecx,%ecx
  8019f3:	89 ce                	mov    %ecx,%esi
  8019f5:	75 0b                	jne    801a02 <__udivdi3+0x42>
  8019f7:	b8 01 00 00 00       	mov    $0x1,%eax
  8019fc:	31 d2                	xor    %edx,%edx
  8019fe:	f7 f1                	div    %ecx
  801a00:	89 c6                	mov    %eax,%esi
  801a02:	31 d2                	xor    %edx,%edx
  801a04:	89 e8                	mov    %ebp,%eax
  801a06:	f7 f6                	div    %esi
  801a08:	89 c5                	mov    %eax,%ebp
  801a0a:	89 f8                	mov    %edi,%eax
  801a0c:	f7 f6                	div    %esi
  801a0e:	89 ea                	mov    %ebp,%edx
  801a10:	8b 74 24 10          	mov    0x10(%esp),%esi
  801a14:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801a18:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801a1c:	83 c4 1c             	add    $0x1c,%esp
  801a1f:	c3                   	ret    
  801a20:	39 e8                	cmp    %ebp,%eax
  801a22:	77 24                	ja     801a48 <__udivdi3+0x88>
  801a24:	0f bd c8             	bsr    %eax,%ecx
  801a27:	83 f1 1f             	xor    $0x1f,%ecx
  801a2a:	89 0c 24             	mov    %ecx,(%esp)
  801a2d:	75 49                	jne    801a78 <__udivdi3+0xb8>
  801a2f:	8b 74 24 08          	mov    0x8(%esp),%esi
  801a33:	39 74 24 04          	cmp    %esi,0x4(%esp)
  801a37:	0f 86 ab 00 00 00    	jbe    801ae8 <__udivdi3+0x128>
  801a3d:	39 e8                	cmp    %ebp,%eax
  801a3f:	0f 82 a3 00 00 00    	jb     801ae8 <__udivdi3+0x128>
  801a45:	8d 76 00             	lea    0x0(%esi),%esi
  801a48:	31 d2                	xor    %edx,%edx
  801a4a:	31 c0                	xor    %eax,%eax
  801a4c:	8b 74 24 10          	mov    0x10(%esp),%esi
  801a50:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801a54:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801a58:	83 c4 1c             	add    $0x1c,%esp
  801a5b:	c3                   	ret    
  801a5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801a60:	89 f8                	mov    %edi,%eax
  801a62:	f7 f1                	div    %ecx
  801a64:	31 d2                	xor    %edx,%edx
  801a66:	8b 74 24 10          	mov    0x10(%esp),%esi
  801a6a:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801a6e:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801a72:	83 c4 1c             	add    $0x1c,%esp
  801a75:	c3                   	ret    
  801a76:	66 90                	xchg   %ax,%ax
  801a78:	0f b6 0c 24          	movzbl (%esp),%ecx
  801a7c:	89 c6                	mov    %eax,%esi
  801a7e:	b8 20 00 00 00       	mov    $0x20,%eax
  801a83:	8b 6c 24 04          	mov    0x4(%esp),%ebp
  801a87:	2b 04 24             	sub    (%esp),%eax
  801a8a:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801a8e:	d3 e6                	shl    %cl,%esi
  801a90:	89 c1                	mov    %eax,%ecx
  801a92:	d3 ed                	shr    %cl,%ebp
  801a94:	0f b6 0c 24          	movzbl (%esp),%ecx
  801a98:	09 f5                	or     %esi,%ebp
  801a9a:	8b 74 24 04          	mov    0x4(%esp),%esi
  801a9e:	d3 e6                	shl    %cl,%esi
  801aa0:	89 c1                	mov    %eax,%ecx
  801aa2:	89 74 24 04          	mov    %esi,0x4(%esp)
  801aa6:	89 d6                	mov    %edx,%esi
  801aa8:	d3 ee                	shr    %cl,%esi
  801aaa:	0f b6 0c 24          	movzbl (%esp),%ecx
  801aae:	d3 e2                	shl    %cl,%edx
  801ab0:	89 c1                	mov    %eax,%ecx
  801ab2:	d3 ef                	shr    %cl,%edi
  801ab4:	09 d7                	or     %edx,%edi
  801ab6:	89 f2                	mov    %esi,%edx
  801ab8:	89 f8                	mov    %edi,%eax
  801aba:	f7 f5                	div    %ebp
  801abc:	89 d6                	mov    %edx,%esi
  801abe:	89 c7                	mov    %eax,%edi
  801ac0:	f7 64 24 04          	mull   0x4(%esp)
  801ac4:	39 d6                	cmp    %edx,%esi
  801ac6:	72 30                	jb     801af8 <__udivdi3+0x138>
  801ac8:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801acc:	0f b6 0c 24          	movzbl (%esp),%ecx
  801ad0:	d3 e5                	shl    %cl,%ebp
  801ad2:	39 c5                	cmp    %eax,%ebp
  801ad4:	73 04                	jae    801ada <__udivdi3+0x11a>
  801ad6:	39 d6                	cmp    %edx,%esi
  801ad8:	74 1e                	je     801af8 <__udivdi3+0x138>
  801ada:	89 f8                	mov    %edi,%eax
  801adc:	31 d2                	xor    %edx,%edx
  801ade:	e9 69 ff ff ff       	jmp    801a4c <__udivdi3+0x8c>
  801ae3:	90                   	nop
  801ae4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ae8:	31 d2                	xor    %edx,%edx
  801aea:	b8 01 00 00 00       	mov    $0x1,%eax
  801aef:	e9 58 ff ff ff       	jmp    801a4c <__udivdi3+0x8c>
  801af4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801af8:	8d 47 ff             	lea    -0x1(%edi),%eax
  801afb:	31 d2                	xor    %edx,%edx
  801afd:	8b 74 24 10          	mov    0x10(%esp),%esi
  801b01:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801b05:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801b09:	83 c4 1c             	add    $0x1c,%esp
  801b0c:	c3                   	ret    
  801b0d:	66 90                	xchg   %ax,%ax
  801b0f:	90                   	nop

00801b10 <__umoddi3>:
  801b10:	83 ec 2c             	sub    $0x2c,%esp
  801b13:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801b17:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801b1b:	89 74 24 20          	mov    %esi,0x20(%esp)
  801b1f:	8b 74 24 38          	mov    0x38(%esp),%esi
  801b23:	89 7c 24 24          	mov    %edi,0x24(%esp)
  801b27:	8b 7c 24 34          	mov    0x34(%esp),%edi
  801b2b:	85 c0                	test   %eax,%eax
  801b2d:	89 c2                	mov    %eax,%edx
  801b2f:	89 6c 24 28          	mov    %ebp,0x28(%esp)
  801b33:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801b37:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801b3b:	89 74 24 10          	mov    %esi,0x10(%esp)
  801b3f:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801b43:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801b47:	75 1f                	jne    801b68 <__umoddi3+0x58>
  801b49:	39 fe                	cmp    %edi,%esi
  801b4b:	76 63                	jbe    801bb0 <__umoddi3+0xa0>
  801b4d:	89 c8                	mov    %ecx,%eax
  801b4f:	89 fa                	mov    %edi,%edx
  801b51:	f7 f6                	div    %esi
  801b53:	89 d0                	mov    %edx,%eax
  801b55:	31 d2                	xor    %edx,%edx
  801b57:	8b 74 24 20          	mov    0x20(%esp),%esi
  801b5b:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801b5f:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801b63:	83 c4 2c             	add    $0x2c,%esp
  801b66:	c3                   	ret    
  801b67:	90                   	nop
  801b68:	39 f8                	cmp    %edi,%eax
  801b6a:	77 64                	ja     801bd0 <__umoddi3+0xc0>
  801b6c:	0f bd e8             	bsr    %eax,%ebp
  801b6f:	83 f5 1f             	xor    $0x1f,%ebp
  801b72:	75 74                	jne    801be8 <__umoddi3+0xd8>
  801b74:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801b78:	39 7c 24 10          	cmp    %edi,0x10(%esp)
  801b7c:	0f 87 0e 01 00 00    	ja     801c90 <__umoddi3+0x180>
  801b82:	8b 7c 24 0c          	mov    0xc(%esp),%edi
  801b86:	29 f1                	sub    %esi,%ecx
  801b88:	19 c7                	sbb    %eax,%edi
  801b8a:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801b8e:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801b92:	8b 44 24 14          	mov    0x14(%esp),%eax
  801b96:	8b 54 24 18          	mov    0x18(%esp),%edx
  801b9a:	8b 74 24 20          	mov    0x20(%esp),%esi
  801b9e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801ba2:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801ba6:	83 c4 2c             	add    $0x2c,%esp
  801ba9:	c3                   	ret    
  801baa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801bb0:	85 f6                	test   %esi,%esi
  801bb2:	89 f5                	mov    %esi,%ebp
  801bb4:	75 0b                	jne    801bc1 <__umoddi3+0xb1>
  801bb6:	b8 01 00 00 00       	mov    $0x1,%eax
  801bbb:	31 d2                	xor    %edx,%edx
  801bbd:	f7 f6                	div    %esi
  801bbf:	89 c5                	mov    %eax,%ebp
  801bc1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801bc5:	31 d2                	xor    %edx,%edx
  801bc7:	f7 f5                	div    %ebp
  801bc9:	89 c8                	mov    %ecx,%eax
  801bcb:	f7 f5                	div    %ebp
  801bcd:	eb 84                	jmp    801b53 <__umoddi3+0x43>
  801bcf:	90                   	nop
  801bd0:	89 c8                	mov    %ecx,%eax
  801bd2:	89 fa                	mov    %edi,%edx
  801bd4:	8b 74 24 20          	mov    0x20(%esp),%esi
  801bd8:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801bdc:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801be0:	83 c4 2c             	add    $0x2c,%esp
  801be3:	c3                   	ret    
  801be4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801be8:	8b 44 24 10          	mov    0x10(%esp),%eax
  801bec:	be 20 00 00 00       	mov    $0x20,%esi
  801bf1:	89 e9                	mov    %ebp,%ecx
  801bf3:	29 ee                	sub    %ebp,%esi
  801bf5:	d3 e2                	shl    %cl,%edx
  801bf7:	89 f1                	mov    %esi,%ecx
  801bf9:	d3 e8                	shr    %cl,%eax
  801bfb:	89 e9                	mov    %ebp,%ecx
  801bfd:	09 d0                	or     %edx,%eax
  801bff:	89 fa                	mov    %edi,%edx
  801c01:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c05:	8b 44 24 10          	mov    0x10(%esp),%eax
  801c09:	d3 e0                	shl    %cl,%eax
  801c0b:	89 f1                	mov    %esi,%ecx
  801c0d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801c11:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801c15:	d3 ea                	shr    %cl,%edx
  801c17:	89 e9                	mov    %ebp,%ecx
  801c19:	d3 e7                	shl    %cl,%edi
  801c1b:	89 f1                	mov    %esi,%ecx
  801c1d:	d3 e8                	shr    %cl,%eax
  801c1f:	89 e9                	mov    %ebp,%ecx
  801c21:	09 f8                	or     %edi,%eax
  801c23:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801c27:	f7 74 24 0c          	divl   0xc(%esp)
  801c2b:	d3 e7                	shl    %cl,%edi
  801c2d:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801c31:	89 d7                	mov    %edx,%edi
  801c33:	f7 64 24 10          	mull   0x10(%esp)
  801c37:	39 d7                	cmp    %edx,%edi
  801c39:	89 c1                	mov    %eax,%ecx
  801c3b:	89 54 24 14          	mov    %edx,0x14(%esp)
  801c3f:	72 3b                	jb     801c7c <__umoddi3+0x16c>
  801c41:	39 44 24 18          	cmp    %eax,0x18(%esp)
  801c45:	72 31                	jb     801c78 <__umoddi3+0x168>
  801c47:	8b 44 24 18          	mov    0x18(%esp),%eax
  801c4b:	29 c8                	sub    %ecx,%eax
  801c4d:	19 d7                	sbb    %edx,%edi
  801c4f:	89 e9                	mov    %ebp,%ecx
  801c51:	89 fa                	mov    %edi,%edx
  801c53:	d3 e8                	shr    %cl,%eax
  801c55:	89 f1                	mov    %esi,%ecx
  801c57:	d3 e2                	shl    %cl,%edx
  801c59:	89 e9                	mov    %ebp,%ecx
  801c5b:	09 d0                	or     %edx,%eax
  801c5d:	89 fa                	mov    %edi,%edx
  801c5f:	d3 ea                	shr    %cl,%edx
  801c61:	8b 74 24 20          	mov    0x20(%esp),%esi
  801c65:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801c69:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801c6d:	83 c4 2c             	add    $0x2c,%esp
  801c70:	c3                   	ret    
  801c71:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c78:	39 d7                	cmp    %edx,%edi
  801c7a:	75 cb                	jne    801c47 <__umoddi3+0x137>
  801c7c:	8b 54 24 14          	mov    0x14(%esp),%edx
  801c80:	89 c1                	mov    %eax,%ecx
  801c82:	2b 4c 24 10          	sub    0x10(%esp),%ecx
  801c86:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  801c8a:	eb bb                	jmp    801c47 <__umoddi3+0x137>
  801c8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c90:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801c94:	0f 82 e8 fe ff ff    	jb     801b82 <__umoddi3+0x72>
  801c9a:	e9 f3 fe ff ff       	jmp    801b92 <__umoddi3+0x82>
