
obj/user/yield.debug:     file format elf32-i386


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
  80002c:	e8 6f 00 00 00       	call   8000a0 <libmain>
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
  800037:	53                   	push   %ebx
  800038:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003b:	a1 04 40 80 00       	mov    0x804004,%eax
  800040:	8b 40 48             	mov    0x48(%eax),%eax
  800043:	89 44 24 04          	mov    %eax,0x4(%esp)
  800047:	c7 04 24 e0 1c 80 00 	movl   $0x801ce0,(%esp)
  80004e:	e8 5c 01 00 00       	call   8001af <cprintf>
	for (i = 0; i < 5; i++) {
  800053:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800058:	e8 e3 0c 00 00       	call   800d40 <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005d:	a1 04 40 80 00       	mov    0x804004,%eax
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
  800062:	8b 40 48             	mov    0x48(%eax),%eax
  800065:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800069:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006d:	c7 04 24 00 1d 80 00 	movl   $0x801d00,(%esp)
  800074:	e8 36 01 00 00       	call   8001af <cprintf>
umain(int argc, char **argv)
{
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
  800079:	83 c3 01             	add    $0x1,%ebx
  80007c:	83 fb 05             	cmp    $0x5,%ebx
  80007f:	75 d7                	jne    800058 <umain+0x24>
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  800081:	a1 04 40 80 00       	mov    0x804004,%eax
  800086:	8b 40 48             	mov    0x48(%eax),%eax
  800089:	89 44 24 04          	mov    %eax,0x4(%esp)
  80008d:	c7 04 24 2c 1d 80 00 	movl   $0x801d2c,(%esp)
  800094:	e8 16 01 00 00       	call   8001af <cprintf>
}
  800099:	83 c4 14             	add    $0x14,%esp
  80009c:	5b                   	pop    %ebx
  80009d:	5d                   	pop    %ebp
  80009e:	c3                   	ret    
  80009f:	90                   	nop

008000a0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	83 ec 18             	sub    $0x18,%esp
  8000a6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8000a9:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000af:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;

	thisenv = &envs[ENVX(sys_getenvid())];
  8000b2:	e8 50 0c 00 00       	call   800d07 <sys_getenvid>
  8000b7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000bc:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000bf:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000c4:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c9:	85 db                	test   %ebx,%ebx
  8000cb:	7e 07                	jle    8000d4 <libmain+0x34>
		binaryname = argv[0];
  8000cd:	8b 06                	mov    (%esi),%eax
  8000cf:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000d8:	89 1c 24             	mov    %ebx,(%esp)
  8000db:	e8 54 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000e0:	e8 0b 00 00 00       	call   8000f0 <exit>
}
  8000e5:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000e8:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000eb:	89 ec                	mov    %ebp,%esp
  8000ed:	5d                   	pop    %ebp
  8000ee:	c3                   	ret    
  8000ef:	90                   	nop

008000f0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000f0:	55                   	push   %ebp
  8000f1:	89 e5                	mov    %esp,%ebp
  8000f3:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000f6:	e8 98 11 00 00       	call   801293 <close_all>
	sys_env_destroy(0);
  8000fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800102:	e8 9a 0b 00 00       	call   800ca1 <sys_env_destroy>
}
  800107:	c9                   	leave  
  800108:	c3                   	ret    
  800109:	66 90                	xchg   %ax,%ax
  80010b:	90                   	nop

0080010c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80010c:	55                   	push   %ebp
  80010d:	89 e5                	mov    %esp,%ebp
  80010f:	53                   	push   %ebx
  800110:	83 ec 14             	sub    $0x14,%esp
  800113:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800116:	8b 03                	mov    (%ebx),%eax
  800118:	8b 55 08             	mov    0x8(%ebp),%edx
  80011b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80011f:	83 c0 01             	add    $0x1,%eax
  800122:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800124:	3d ff 00 00 00       	cmp    $0xff,%eax
  800129:	75 19                	jne    800144 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80012b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800132:	00 
  800133:	8d 43 08             	lea    0x8(%ebx),%eax
  800136:	89 04 24             	mov    %eax,(%esp)
  800139:	e8 f2 0a 00 00       	call   800c30 <sys_cputs>
		b->idx = 0;
  80013e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800144:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800148:	83 c4 14             	add    $0x14,%esp
  80014b:	5b                   	pop    %ebx
  80014c:	5d                   	pop    %ebp
  80014d:	c3                   	ret    

0080014e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80014e:	55                   	push   %ebp
  80014f:	89 e5                	mov    %esp,%ebp
  800151:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800157:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80015e:	00 00 00 
	b.cnt = 0;
  800161:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800168:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80016b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80016e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800172:	8b 45 08             	mov    0x8(%ebp),%eax
  800175:	89 44 24 08          	mov    %eax,0x8(%esp)
  800179:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80017f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800183:	c7 04 24 0c 01 80 00 	movl   $0x80010c,(%esp)
  80018a:	e8 b3 01 00 00       	call   800342 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80018f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800195:	89 44 24 04          	mov    %eax,0x4(%esp)
  800199:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80019f:	89 04 24             	mov    %eax,(%esp)
  8001a2:	e8 89 0a 00 00       	call   800c30 <sys_cputs>

	return b.cnt;
}
  8001a7:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ad:	c9                   	leave  
  8001ae:	c3                   	ret    

008001af <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001af:	55                   	push   %ebp
  8001b0:	89 e5                	mov    %esp,%ebp
  8001b2:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001b5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8001bf:	89 04 24             	mov    %eax,(%esp)
  8001c2:	e8 87 ff ff ff       	call   80014e <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c7:	c9                   	leave  
  8001c8:	c3                   	ret    
  8001c9:	66 90                	xchg   %ax,%ax
  8001cb:	66 90                	xchg   %ax,%ax
  8001cd:	66 90                	xchg   %ax,%ax
  8001cf:	90                   	nop

008001d0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	57                   	push   %edi
  8001d4:	56                   	push   %esi
  8001d5:	53                   	push   %ebx
  8001d6:	83 ec 4c             	sub    $0x4c,%esp
  8001d9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8001dc:	89 d7                	mov    %edx,%edi
  8001de:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001e1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8001e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8001e7:	89 5d dc             	mov    %ebx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8001ef:	39 d8                	cmp    %ebx,%eax
  8001f1:	72 17                	jb     80020a <printnum+0x3a>
  8001f3:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8001f6:	39 5d 10             	cmp    %ebx,0x10(%ebp)
  8001f9:	76 0f                	jbe    80020a <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001fb:	8b 75 14             	mov    0x14(%ebp),%esi
  8001fe:	83 ee 01             	sub    $0x1,%esi
  800201:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800204:	85 f6                	test   %esi,%esi
  800206:	7f 63                	jg     80026b <printnum+0x9b>
  800208:	eb 75                	jmp    80027f <printnum+0xaf>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80020a:	8b 5d 18             	mov    0x18(%ebp),%ebx
  80020d:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800211:	8b 45 14             	mov    0x14(%ebp),%eax
  800214:	83 e8 01             	sub    $0x1,%eax
  800217:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80021b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80021e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800222:	8b 44 24 08          	mov    0x8(%esp),%eax
  800226:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80022a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80022d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800230:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800237:	00 
  800238:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  80023b:	89 1c 24             	mov    %ebx,(%esp)
  80023e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800241:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800245:	e8 b6 17 00 00       	call   801a00 <__udivdi3>
  80024a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80024d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800250:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800254:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800258:	89 04 24             	mov    %eax,(%esp)
  80025b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80025f:	89 fa                	mov    %edi,%edx
  800261:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800264:	e8 67 ff ff ff       	call   8001d0 <printnum>
  800269:	eb 14                	jmp    80027f <printnum+0xaf>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80026b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80026f:	8b 45 18             	mov    0x18(%ebp),%eax
  800272:	89 04 24             	mov    %eax,(%esp)
  800275:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800277:	83 ee 01             	sub    $0x1,%esi
  80027a:	75 ef                	jne    80026b <printnum+0x9b>
  80027c:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80027f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800283:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800287:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80028a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80028e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800295:	00 
  800296:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800299:	89 1c 24             	mov    %ebx,(%esp)
  80029c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80029f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002a3:	e8 a8 18 00 00       	call   801b50 <__umoddi3>
  8002a8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002ac:	0f be 80 55 1d 80 00 	movsbl 0x801d55(%eax),%eax
  8002b3:	89 04 24             	mov    %eax,(%esp)
  8002b6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002b9:	ff d0                	call   *%eax
}
  8002bb:	83 c4 4c             	add    $0x4c,%esp
  8002be:	5b                   	pop    %ebx
  8002bf:	5e                   	pop    %esi
  8002c0:	5f                   	pop    %edi
  8002c1:	5d                   	pop    %ebp
  8002c2:	c3                   	ret    

008002c3 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002c3:	55                   	push   %ebp
  8002c4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002c6:	83 fa 01             	cmp    $0x1,%edx
  8002c9:	7e 0e                	jle    8002d9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002cb:	8b 10                	mov    (%eax),%edx
  8002cd:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002d0:	89 08                	mov    %ecx,(%eax)
  8002d2:	8b 02                	mov    (%edx),%eax
  8002d4:	8b 52 04             	mov    0x4(%edx),%edx
  8002d7:	eb 22                	jmp    8002fb <getuint+0x38>
	else if (lflag)
  8002d9:	85 d2                	test   %edx,%edx
  8002db:	74 10                	je     8002ed <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002dd:	8b 10                	mov    (%eax),%edx
  8002df:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e2:	89 08                	mov    %ecx,(%eax)
  8002e4:	8b 02                	mov    (%edx),%eax
  8002e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8002eb:	eb 0e                	jmp    8002fb <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002ed:	8b 10                	mov    (%eax),%edx
  8002ef:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f2:	89 08                	mov    %ecx,(%eax)
  8002f4:	8b 02                	mov    (%edx),%eax
  8002f6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002fb:	5d                   	pop    %ebp
  8002fc:	c3                   	ret    

008002fd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800303:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800307:	8b 10                	mov    (%eax),%edx
  800309:	3b 50 04             	cmp    0x4(%eax),%edx
  80030c:	73 0a                	jae    800318 <sprintputch+0x1b>
		*b->buf++ = ch;
  80030e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800311:	88 0a                	mov    %cl,(%edx)
  800313:	83 c2 01             	add    $0x1,%edx
  800316:	89 10                	mov    %edx,(%eax)
}
  800318:	5d                   	pop    %ebp
  800319:	c3                   	ret    

0080031a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80031a:	55                   	push   %ebp
  80031b:	89 e5                	mov    %esp,%ebp
  80031d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800320:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800323:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800327:	8b 45 10             	mov    0x10(%ebp),%eax
  80032a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80032e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800331:	89 44 24 04          	mov    %eax,0x4(%esp)
  800335:	8b 45 08             	mov    0x8(%ebp),%eax
  800338:	89 04 24             	mov    %eax,(%esp)
  80033b:	e8 02 00 00 00       	call   800342 <vprintfmt>
	va_end(ap);
}
  800340:	c9                   	leave  
  800341:	c3                   	ret    

00800342 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800342:	55                   	push   %ebp
  800343:	89 e5                	mov    %esp,%ebp
  800345:	57                   	push   %edi
  800346:	56                   	push   %esi
  800347:	53                   	push   %ebx
  800348:	83 ec 4c             	sub    $0x4c,%esp
  80034b:	8b 75 08             	mov    0x8(%ebp),%esi
  80034e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800351:	8b 7d 10             	mov    0x10(%ebp),%edi
  800354:	eb 11                	jmp    800367 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800356:	85 c0                	test   %eax,%eax
  800358:	0f 84 db 03 00 00    	je     800739 <vprintfmt+0x3f7>
				return;
			putch(ch, putdat);
  80035e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800362:	89 04 24             	mov    %eax,(%esp)
  800365:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800367:	0f b6 07             	movzbl (%edi),%eax
  80036a:	83 c7 01             	add    $0x1,%edi
  80036d:	83 f8 25             	cmp    $0x25,%eax
  800370:	75 e4                	jne    800356 <vprintfmt+0x14>
  800372:	c6 45 e4 20          	movb   $0x20,-0x1c(%ebp)
  800376:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80037d:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800384:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80038b:	ba 00 00 00 00       	mov    $0x0,%edx
  800390:	eb 2b                	jmp    8003bd <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800392:	8b 7d e0             	mov    -0x20(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800395:	c6 45 e4 2d          	movb   $0x2d,-0x1c(%ebp)
  800399:	eb 22                	jmp    8003bd <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039b:	8b 7d e0             	mov    -0x20(%ebp),%edi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80039e:	c6 45 e4 30          	movb   $0x30,-0x1c(%ebp)
  8003a2:	eb 19                	jmp    8003bd <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a4:	8b 7d e0             	mov    -0x20(%ebp),%edi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003a7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003ae:	eb 0d                	jmp    8003bd <vprintfmt+0x7b>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003b0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003b6:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bd:	0f b6 0f             	movzbl (%edi),%ecx
  8003c0:	8d 47 01             	lea    0x1(%edi),%eax
  8003c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003c6:	0f b6 07             	movzbl (%edi),%eax
  8003c9:	83 e8 23             	sub    $0x23,%eax
  8003cc:	3c 55                	cmp    $0x55,%al
  8003ce:	0f 87 40 03 00 00    	ja     800714 <vprintfmt+0x3d2>
  8003d4:	0f b6 c0             	movzbl %al,%eax
  8003d7:	ff 24 85 a0 1e 80 00 	jmp    *0x801ea0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003de:	83 e9 30             	sub    $0x30,%ecx
  8003e1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				ch = *fmt;
  8003e4:	0f be 47 01          	movsbl 0x1(%edi),%eax
				if (ch < '0' || ch > '9')
  8003e8:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8003eb:	83 f9 09             	cmp    $0x9,%ecx
  8003ee:	77 57                	ja     800447 <vprintfmt+0x105>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f0:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8003f3:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8003f6:	8b 55 dc             	mov    -0x24(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003f9:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003fc:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8003ff:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800403:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  800406:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800409:	83 f9 09             	cmp    $0x9,%ecx
  80040c:	76 eb                	jbe    8003f9 <vprintfmt+0xb7>
  80040e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800411:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800414:	eb 34                	jmp    80044a <vprintfmt+0x108>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800416:	8b 45 14             	mov    0x14(%ebp),%eax
  800419:	8d 48 04             	lea    0x4(%eax),%ecx
  80041c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80041f:	8b 00                	mov    (%eax),%eax
  800421:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800424:	8b 7d e0             	mov    -0x20(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800427:	eb 21                	jmp    80044a <vprintfmt+0x108>

		case '.':
			if (width < 0)
  800429:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80042d:	0f 88 71 ff ff ff    	js     8003a4 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800433:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800436:	eb 85                	jmp    8003bd <vprintfmt+0x7b>
  800438:	8b 7d e0             	mov    -0x20(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80043b:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  800442:	e9 76 ff ff ff       	jmp    8003bd <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800447:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80044a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80044e:	0f 89 69 ff ff ff    	jns    8003bd <vprintfmt+0x7b>
  800454:	e9 57 ff ff ff       	jmp    8003b0 <vprintfmt+0x6e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800459:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80045f:	e9 59 ff ff ff       	jmp    8003bd <vprintfmt+0x7b>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800464:	8b 45 14             	mov    0x14(%ebp),%eax
  800467:	8d 50 04             	lea    0x4(%eax),%edx
  80046a:	89 55 14             	mov    %edx,0x14(%ebp)
  80046d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800471:	8b 00                	mov    (%eax),%eax
  800473:	89 04 24             	mov    %eax,(%esp)
  800476:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800478:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80047b:	e9 e7 fe ff ff       	jmp    800367 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800480:	8b 45 14             	mov    0x14(%ebp),%eax
  800483:	8d 50 04             	lea    0x4(%eax),%edx
  800486:	89 55 14             	mov    %edx,0x14(%ebp)
  800489:	8b 00                	mov    (%eax),%eax
  80048b:	89 c2                	mov    %eax,%edx
  80048d:	c1 fa 1f             	sar    $0x1f,%edx
  800490:	31 d0                	xor    %edx,%eax
  800492:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800494:	83 f8 0f             	cmp    $0xf,%eax
  800497:	7f 0b                	jg     8004a4 <vprintfmt+0x162>
  800499:	8b 14 85 00 20 80 00 	mov    0x802000(,%eax,4),%edx
  8004a0:	85 d2                	test   %edx,%edx
  8004a2:	75 20                	jne    8004c4 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  8004a4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004a8:	c7 44 24 08 6d 1d 80 	movl   $0x801d6d,0x8(%esp)
  8004af:	00 
  8004b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004b4:	89 34 24             	mov    %esi,(%esp)
  8004b7:	e8 5e fe ff ff       	call   80031a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bc:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004bf:	e9 a3 fe ff ff       	jmp    800367 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  8004c4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004c8:	c7 44 24 08 76 1d 80 	movl   $0x801d76,0x8(%esp)
  8004cf:	00 
  8004d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004d4:	89 34 24             	mov    %esi,(%esp)
  8004d7:	e8 3e fe ff ff       	call   80031a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004dc:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8004df:	e9 83 fe ff ff       	jmp    800367 <vprintfmt+0x25>
  8004e4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004e7:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8004ea:	89 7d cc             	mov    %edi,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f0:	8d 50 04             	lea    0x4(%eax),%edx
  8004f3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004f8:	85 ff                	test   %edi,%edi
  8004fa:	b8 66 1d 80 00       	mov    $0x801d66,%eax
  8004ff:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800502:	80 7d e4 2d          	cmpb   $0x2d,-0x1c(%ebp)
  800506:	74 06                	je     80050e <vprintfmt+0x1cc>
  800508:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80050c:	7f 16                	jg     800524 <vprintfmt+0x1e2>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80050e:	0f b6 17             	movzbl (%edi),%edx
  800511:	0f be c2             	movsbl %dl,%eax
  800514:	83 c7 01             	add    $0x1,%edi
  800517:	85 c0                	test   %eax,%eax
  800519:	0f 85 9f 00 00 00    	jne    8005be <vprintfmt+0x27c>
  80051f:	e9 8b 00 00 00       	jmp    8005af <vprintfmt+0x26d>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800524:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800528:	89 3c 24             	mov    %edi,(%esp)
  80052b:	e8 c2 02 00 00       	call   8007f2 <strnlen>
  800530:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800533:	29 c2                	sub    %eax,%edx
  800535:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800538:	85 d2                	test   %edx,%edx
  80053a:	7e d2                	jle    80050e <vprintfmt+0x1cc>
					putch(padc, putdat);
  80053c:	0f be 4d e4          	movsbl -0x1c(%ebp),%ecx
  800540:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800543:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800546:	89 d7                	mov    %edx,%edi
  800548:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80054c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80054f:	89 04 24             	mov    %eax,(%esp)
  800552:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800554:	83 ef 01             	sub    $0x1,%edi
  800557:	75 ef                	jne    800548 <vprintfmt+0x206>
  800559:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80055c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80055f:	eb ad                	jmp    80050e <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800561:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800565:	74 20                	je     800587 <vprintfmt+0x245>
  800567:	0f be d2             	movsbl %dl,%edx
  80056a:	83 ea 20             	sub    $0x20,%edx
  80056d:	83 fa 5e             	cmp    $0x5e,%edx
  800570:	76 15                	jbe    800587 <vprintfmt+0x245>
					putch('?', putdat);
  800572:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800575:	89 54 24 04          	mov    %edx,0x4(%esp)
  800579:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800580:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800583:	ff d1                	call   *%ecx
  800585:	eb 0f                	jmp    800596 <vprintfmt+0x254>
				else
					putch(ch, putdat);
  800587:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80058a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80058e:	89 04 24             	mov    %eax,(%esp)
  800591:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800594:	ff d1                	call   *%ecx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800596:	83 eb 01             	sub    $0x1,%ebx
  800599:	0f b6 17             	movzbl (%edi),%edx
  80059c:	0f be c2             	movsbl %dl,%eax
  80059f:	83 c7 01             	add    $0x1,%edi
  8005a2:	85 c0                	test   %eax,%eax
  8005a4:	75 24                	jne    8005ca <vprintfmt+0x288>
  8005a6:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8005a9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8005ac:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005af:	8b 7d e0             	mov    -0x20(%ebp),%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005b2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005b6:	0f 8e ab fd ff ff    	jle    800367 <vprintfmt+0x25>
  8005bc:	eb 20                	jmp    8005de <vprintfmt+0x29c>
  8005be:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  8005c1:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8005c4:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8005c7:	8b 5d d8             	mov    -0x28(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ca:	85 f6                	test   %esi,%esi
  8005cc:	78 93                	js     800561 <vprintfmt+0x21f>
  8005ce:	83 ee 01             	sub    $0x1,%esi
  8005d1:	79 8e                	jns    800561 <vprintfmt+0x21f>
  8005d3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8005d6:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8005d9:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8005dc:	eb d1                	jmp    8005af <vprintfmt+0x26d>
  8005de:	8b 7d d8             	mov    -0x28(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005e1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005e5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005ec:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005ee:	83 ef 01             	sub    $0x1,%edi
  8005f1:	75 ee                	jne    8005e1 <vprintfmt+0x29f>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f3:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005f6:	e9 6c fd ff ff       	jmp    800367 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005fb:	83 fa 01             	cmp    $0x1,%edx
  8005fe:	66 90                	xchg   %ax,%ax
  800600:	7e 16                	jle    800618 <vprintfmt+0x2d6>
		return va_arg(*ap, long long);
  800602:	8b 45 14             	mov    0x14(%ebp),%eax
  800605:	8d 50 08             	lea    0x8(%eax),%edx
  800608:	89 55 14             	mov    %edx,0x14(%ebp)
  80060b:	8b 10                	mov    (%eax),%edx
  80060d:	8b 48 04             	mov    0x4(%eax),%ecx
  800610:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800613:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800616:	eb 32                	jmp    80064a <vprintfmt+0x308>
	else if (lflag)
  800618:	85 d2                	test   %edx,%edx
  80061a:	74 18                	je     800634 <vprintfmt+0x2f2>
		return va_arg(*ap, long);
  80061c:	8b 45 14             	mov    0x14(%ebp),%eax
  80061f:	8d 50 04             	lea    0x4(%eax),%edx
  800622:	89 55 14             	mov    %edx,0x14(%ebp)
  800625:	8b 00                	mov    (%eax),%eax
  800627:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80062a:	89 c1                	mov    %eax,%ecx
  80062c:	c1 f9 1f             	sar    $0x1f,%ecx
  80062f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800632:	eb 16                	jmp    80064a <vprintfmt+0x308>
	else
		return va_arg(*ap, int);
  800634:	8b 45 14             	mov    0x14(%ebp),%eax
  800637:	8d 50 04             	lea    0x4(%eax),%edx
  80063a:	89 55 14             	mov    %edx,0x14(%ebp)
  80063d:	8b 00                	mov    (%eax),%eax
  80063f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800642:	89 c7                	mov    %eax,%edi
  800644:	c1 ff 1f             	sar    $0x1f,%edi
  800647:	89 7d d4             	mov    %edi,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80064a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80064d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800650:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800655:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800659:	79 7d                	jns    8006d8 <vprintfmt+0x396>
				putch('-', putdat);
  80065b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80065f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800666:	ff d6                	call   *%esi
				num = -(long long) num;
  800668:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80066b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80066e:	f7 d8                	neg    %eax
  800670:	83 d2 00             	adc    $0x0,%edx
  800673:	f7 da                	neg    %edx
			}
			base = 10;
  800675:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80067a:	eb 5c                	jmp    8006d8 <vprintfmt+0x396>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80067c:	8d 45 14             	lea    0x14(%ebp),%eax
  80067f:	e8 3f fc ff ff       	call   8002c3 <getuint>
			base = 10;
  800684:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800689:	eb 4d                	jmp    8006d8 <vprintfmt+0x396>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80068b:	8d 45 14             	lea    0x14(%ebp),%eax
  80068e:	e8 30 fc ff ff       	call   8002c3 <getuint>
			base = 8;
  800693:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800698:	eb 3e                	jmp    8006d8 <vprintfmt+0x396>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80069a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80069e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006a5:	ff d6                	call   *%esi
			putch('x', putdat);
  8006a7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ab:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006b2:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b7:	8d 50 04             	lea    0x4(%eax),%edx
  8006ba:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006bd:	8b 00                	mov    (%eax),%eax
  8006bf:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006c4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006c9:	eb 0d                	jmp    8006d8 <vprintfmt+0x396>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006cb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ce:	e8 f0 fb ff ff       	call   8002c3 <getuint>
			base = 16;
  8006d3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006d8:	0f be 7d e4          	movsbl -0x1c(%ebp),%edi
  8006dc:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8006e0:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8006e3:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8006e7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8006eb:	89 04 24             	mov    %eax,(%esp)
  8006ee:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006f2:	89 da                	mov    %ebx,%edx
  8006f4:	89 f0                	mov    %esi,%eax
  8006f6:	e8 d5 fa ff ff       	call   8001d0 <printnum>
			break;
  8006fb:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8006fe:	e9 64 fc ff ff       	jmp    800367 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800703:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800707:	89 0c 24             	mov    %ecx,(%esp)
  80070a:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80070f:	e9 53 fc ff ff       	jmp    800367 <vprintfmt+0x25>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800714:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800718:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80071f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800721:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800725:	0f 84 3c fc ff ff    	je     800367 <vprintfmt+0x25>
  80072b:	83 ef 01             	sub    $0x1,%edi
  80072e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800732:	75 f7                	jne    80072b <vprintfmt+0x3e9>
  800734:	e9 2e fc ff ff       	jmp    800367 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800739:	83 c4 4c             	add    $0x4c,%esp
  80073c:	5b                   	pop    %ebx
  80073d:	5e                   	pop    %esi
  80073e:	5f                   	pop    %edi
  80073f:	5d                   	pop    %ebp
  800740:	c3                   	ret    

00800741 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800741:	55                   	push   %ebp
  800742:	89 e5                	mov    %esp,%ebp
  800744:	83 ec 28             	sub    $0x28,%esp
  800747:	8b 45 08             	mov    0x8(%ebp),%eax
  80074a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80074d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800750:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800754:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800757:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80075e:	85 d2                	test   %edx,%edx
  800760:	7e 30                	jle    800792 <vsnprintf+0x51>
  800762:	85 c0                	test   %eax,%eax
  800764:	74 2c                	je     800792 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800766:	8b 45 14             	mov    0x14(%ebp),%eax
  800769:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80076d:	8b 45 10             	mov    0x10(%ebp),%eax
  800770:	89 44 24 08          	mov    %eax,0x8(%esp)
  800774:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800777:	89 44 24 04          	mov    %eax,0x4(%esp)
  80077b:	c7 04 24 fd 02 80 00 	movl   $0x8002fd,(%esp)
  800782:	e8 bb fb ff ff       	call   800342 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800787:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80078a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80078d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800790:	eb 05                	jmp    800797 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800792:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800797:	c9                   	leave  
  800798:	c3                   	ret    

00800799 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800799:	55                   	push   %ebp
  80079a:	89 e5                	mov    %esp,%ebp
  80079c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80079f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007a6:	8b 45 10             	mov    0x10(%ebp),%eax
  8007a9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b7:	89 04 24             	mov    %eax,(%esp)
  8007ba:	e8 82 ff ff ff       	call   800741 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007bf:	c9                   	leave  
  8007c0:	c3                   	ret    
  8007c1:	66 90                	xchg   %ax,%ax
  8007c3:	66 90                	xchg   %ax,%ax
  8007c5:	66 90                	xchg   %ax,%ax
  8007c7:	66 90                	xchg   %ax,%ax
  8007c9:	66 90                	xchg   %ax,%ax
  8007cb:	66 90                	xchg   %ax,%ax
  8007cd:	66 90                	xchg   %ax,%ax
  8007cf:	90                   	nop

008007d0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
  8007d3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d6:	80 3a 00             	cmpb   $0x0,(%edx)
  8007d9:	74 10                	je     8007eb <strlen+0x1b>
  8007db:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007e0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007e7:	75 f7                	jne    8007e0 <strlen+0x10>
  8007e9:	eb 05                	jmp    8007f0 <strlen+0x20>
  8007eb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007f0:	5d                   	pop    %ebp
  8007f1:	c3                   	ret    

008007f2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	53                   	push   %ebx
  8007f6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007fc:	85 c9                	test   %ecx,%ecx
  8007fe:	74 1c                	je     80081c <strnlen+0x2a>
  800800:	80 3b 00             	cmpb   $0x0,(%ebx)
  800803:	74 1e                	je     800823 <strnlen+0x31>
  800805:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  80080a:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80080c:	39 ca                	cmp    %ecx,%edx
  80080e:	74 18                	je     800828 <strnlen+0x36>
  800810:	83 c2 01             	add    $0x1,%edx
  800813:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800818:	75 f0                	jne    80080a <strnlen+0x18>
  80081a:	eb 0c                	jmp    800828 <strnlen+0x36>
  80081c:	b8 00 00 00 00       	mov    $0x0,%eax
  800821:	eb 05                	jmp    800828 <strnlen+0x36>
  800823:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800828:	5b                   	pop    %ebx
  800829:	5d                   	pop    %ebp
  80082a:	c3                   	ret    

0080082b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80082b:	55                   	push   %ebp
  80082c:	89 e5                	mov    %esp,%ebp
  80082e:	53                   	push   %ebx
  80082f:	8b 45 08             	mov    0x8(%ebp),%eax
  800832:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800835:	89 c2                	mov    %eax,%edx
  800837:	0f b6 19             	movzbl (%ecx),%ebx
  80083a:	88 1a                	mov    %bl,(%edx)
  80083c:	83 c2 01             	add    $0x1,%edx
  80083f:	83 c1 01             	add    $0x1,%ecx
  800842:	84 db                	test   %bl,%bl
  800844:	75 f1                	jne    800837 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800846:	5b                   	pop    %ebx
  800847:	5d                   	pop    %ebp
  800848:	c3                   	ret    

00800849 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800849:	55                   	push   %ebp
  80084a:	89 e5                	mov    %esp,%ebp
  80084c:	53                   	push   %ebx
  80084d:	83 ec 08             	sub    $0x8,%esp
  800850:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800853:	89 1c 24             	mov    %ebx,(%esp)
  800856:	e8 75 ff ff ff       	call   8007d0 <strlen>
	strcpy(dst + len, src);
  80085b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800862:	01 d8                	add    %ebx,%eax
  800864:	89 04 24             	mov    %eax,(%esp)
  800867:	e8 bf ff ff ff       	call   80082b <strcpy>
	return dst;
}
  80086c:	89 d8                	mov    %ebx,%eax
  80086e:	83 c4 08             	add    $0x8,%esp
  800871:	5b                   	pop    %ebx
  800872:	5d                   	pop    %ebp
  800873:	c3                   	ret    

00800874 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800874:	55                   	push   %ebp
  800875:	89 e5                	mov    %esp,%ebp
  800877:	56                   	push   %esi
  800878:	53                   	push   %ebx
  800879:	8b 75 08             	mov    0x8(%ebp),%esi
  80087c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80087f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800882:	85 db                	test   %ebx,%ebx
  800884:	74 16                	je     80089c <strncpy+0x28>
	strcpy(dst + len, src);
	return dst;
}

char *
strncpy(char *dst, const char *src, size_t size) {
  800886:	01 f3                	add    %esi,%ebx
  800888:	89 f1                	mov    %esi,%ecx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  80088a:	0f b6 02             	movzbl (%edx),%eax
  80088d:	88 01                	mov    %al,(%ecx)
  80088f:	83 c1 01             	add    $0x1,%ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800892:	80 3a 01             	cmpb   $0x1,(%edx)
  800895:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800898:	39 d9                	cmp    %ebx,%ecx
  80089a:	75 ee                	jne    80088a <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80089c:	89 f0                	mov    %esi,%eax
  80089e:	5b                   	pop    %ebx
  80089f:	5e                   	pop    %esi
  8008a0:	5d                   	pop    %ebp
  8008a1:	c3                   	ret    

008008a2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	57                   	push   %edi
  8008a6:	56                   	push   %esi
  8008a7:	53                   	push   %ebx
  8008a8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008ae:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008b1:	89 f8                	mov    %edi,%eax
  8008b3:	85 f6                	test   %esi,%esi
  8008b5:	74 33                	je     8008ea <strlcpy+0x48>
		while (--size > 0 && *src != '\0')
  8008b7:	83 fe 01             	cmp    $0x1,%esi
  8008ba:	74 25                	je     8008e1 <strlcpy+0x3f>
  8008bc:	0f b6 0b             	movzbl (%ebx),%ecx
  8008bf:	84 c9                	test   %cl,%cl
  8008c1:	74 22                	je     8008e5 <strlcpy+0x43>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8008c3:	83 ee 02             	sub    $0x2,%esi
  8008c6:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008cb:	88 08                	mov    %cl,(%eax)
  8008cd:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008d0:	39 f2                	cmp    %esi,%edx
  8008d2:	74 13                	je     8008e7 <strlcpy+0x45>
  8008d4:	83 c2 01             	add    $0x1,%edx
  8008d7:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8008db:	84 c9                	test   %cl,%cl
  8008dd:	75 ec                	jne    8008cb <strlcpy+0x29>
  8008df:	eb 06                	jmp    8008e7 <strlcpy+0x45>
  8008e1:	89 f8                	mov    %edi,%eax
  8008e3:	eb 02                	jmp    8008e7 <strlcpy+0x45>
  8008e5:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008e7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008ea:	29 f8                	sub    %edi,%eax
}
  8008ec:	5b                   	pop    %ebx
  8008ed:	5e                   	pop    %esi
  8008ee:	5f                   	pop    %edi
  8008ef:	5d                   	pop    %ebp
  8008f0:	c3                   	ret    

008008f1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008f1:	55                   	push   %ebp
  8008f2:	89 e5                	mov    %esp,%ebp
  8008f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008f7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008fa:	0f b6 01             	movzbl (%ecx),%eax
  8008fd:	84 c0                	test   %al,%al
  8008ff:	74 15                	je     800916 <strcmp+0x25>
  800901:	3a 02                	cmp    (%edx),%al
  800903:	75 11                	jne    800916 <strcmp+0x25>
		p++, q++;
  800905:	83 c1 01             	add    $0x1,%ecx
  800908:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80090b:	0f b6 01             	movzbl (%ecx),%eax
  80090e:	84 c0                	test   %al,%al
  800910:	74 04                	je     800916 <strcmp+0x25>
  800912:	3a 02                	cmp    (%edx),%al
  800914:	74 ef                	je     800905 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800916:	0f b6 c0             	movzbl %al,%eax
  800919:	0f b6 12             	movzbl (%edx),%edx
  80091c:	29 d0                	sub    %edx,%eax
}
  80091e:	5d                   	pop    %ebp
  80091f:	c3                   	ret    

00800920 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800920:	55                   	push   %ebp
  800921:	89 e5                	mov    %esp,%ebp
  800923:	56                   	push   %esi
  800924:	53                   	push   %ebx
  800925:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800928:	8b 55 0c             	mov    0xc(%ebp),%edx
  80092b:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  80092e:	85 f6                	test   %esi,%esi
  800930:	74 29                	je     80095b <strncmp+0x3b>
  800932:	0f b6 03             	movzbl (%ebx),%eax
  800935:	84 c0                	test   %al,%al
  800937:	74 30                	je     800969 <strncmp+0x49>
  800939:	3a 02                	cmp    (%edx),%al
  80093b:	75 2c                	jne    800969 <strncmp+0x49>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}

int
strncmp(const char *p, const char *q, size_t n)
  80093d:	8d 43 01             	lea    0x1(%ebx),%eax
  800940:	01 de                	add    %ebx,%esi
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800942:	89 c3                	mov    %eax,%ebx
  800944:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800947:	39 f0                	cmp    %esi,%eax
  800949:	74 17                	je     800962 <strncmp+0x42>
  80094b:	0f b6 08             	movzbl (%eax),%ecx
  80094e:	84 c9                	test   %cl,%cl
  800950:	74 17                	je     800969 <strncmp+0x49>
  800952:	83 c0 01             	add    $0x1,%eax
  800955:	3a 0a                	cmp    (%edx),%cl
  800957:	74 e9                	je     800942 <strncmp+0x22>
  800959:	eb 0e                	jmp    800969 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  80095b:	b8 00 00 00 00       	mov    $0x0,%eax
  800960:	eb 0f                	jmp    800971 <strncmp+0x51>
  800962:	b8 00 00 00 00       	mov    $0x0,%eax
  800967:	eb 08                	jmp    800971 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800969:	0f b6 03             	movzbl (%ebx),%eax
  80096c:	0f b6 12             	movzbl (%edx),%edx
  80096f:	29 d0                	sub    %edx,%eax
}
  800971:	5b                   	pop    %ebx
  800972:	5e                   	pop    %esi
  800973:	5d                   	pop    %ebp
  800974:	c3                   	ret    

00800975 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800975:	55                   	push   %ebp
  800976:	89 e5                	mov    %esp,%ebp
  800978:	53                   	push   %ebx
  800979:	8b 45 08             	mov    0x8(%ebp),%eax
  80097c:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  80097f:	0f b6 18             	movzbl (%eax),%ebx
  800982:	84 db                	test   %bl,%bl
  800984:	74 1d                	je     8009a3 <strchr+0x2e>
  800986:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800988:	38 d3                	cmp    %dl,%bl
  80098a:	75 06                	jne    800992 <strchr+0x1d>
  80098c:	eb 1a                	jmp    8009a8 <strchr+0x33>
  80098e:	38 ca                	cmp    %cl,%dl
  800990:	74 16                	je     8009a8 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800992:	83 c0 01             	add    $0x1,%eax
  800995:	0f b6 10             	movzbl (%eax),%edx
  800998:	84 d2                	test   %dl,%dl
  80099a:	75 f2                	jne    80098e <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  80099c:	b8 00 00 00 00       	mov    $0x0,%eax
  8009a1:	eb 05                	jmp    8009a8 <strchr+0x33>
  8009a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009a8:	5b                   	pop    %ebx
  8009a9:	5d                   	pop    %ebp
  8009aa:	c3                   	ret    

008009ab <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	53                   	push   %ebx
  8009af:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b2:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  8009b5:	0f b6 18             	movzbl (%eax),%ebx
  8009b8:	84 db                	test   %bl,%bl
  8009ba:	74 16                	je     8009d2 <strfind+0x27>
  8009bc:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  8009be:	38 d3                	cmp    %dl,%bl
  8009c0:	75 06                	jne    8009c8 <strfind+0x1d>
  8009c2:	eb 0e                	jmp    8009d2 <strfind+0x27>
  8009c4:	38 ca                	cmp    %cl,%dl
  8009c6:	74 0a                	je     8009d2 <strfind+0x27>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009c8:	83 c0 01             	add    $0x1,%eax
  8009cb:	0f b6 10             	movzbl (%eax),%edx
  8009ce:	84 d2                	test   %dl,%dl
  8009d0:	75 f2                	jne    8009c4 <strfind+0x19>
		if (*s == c)
			break;
	return (char *) s;
}
  8009d2:	5b                   	pop    %ebx
  8009d3:	5d                   	pop    %ebp
  8009d4:	c3                   	ret    

008009d5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009d5:	55                   	push   %ebp
  8009d6:	89 e5                	mov    %esp,%ebp
  8009d8:	83 ec 0c             	sub    $0xc,%esp
  8009db:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8009de:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8009e1:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8009e4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009e7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009ea:	85 c9                	test   %ecx,%ecx
  8009ec:	74 36                	je     800a24 <memset+0x4f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009ee:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009f4:	75 28                	jne    800a1e <memset+0x49>
  8009f6:	f6 c1 03             	test   $0x3,%cl
  8009f9:	75 23                	jne    800a1e <memset+0x49>
		c &= 0xFF;
  8009fb:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009ff:	89 d3                	mov    %edx,%ebx
  800a01:	c1 e3 08             	shl    $0x8,%ebx
  800a04:	89 d6                	mov    %edx,%esi
  800a06:	c1 e6 18             	shl    $0x18,%esi
  800a09:	89 d0                	mov    %edx,%eax
  800a0b:	c1 e0 10             	shl    $0x10,%eax
  800a0e:	09 f0                	or     %esi,%eax
  800a10:	09 c2                	or     %eax,%edx
  800a12:	89 d0                	mov    %edx,%eax
  800a14:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a16:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a19:	fc                   	cld    
  800a1a:	f3 ab                	rep stos %eax,%es:(%edi)
  800a1c:	eb 06                	jmp    800a24 <memset+0x4f>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a21:	fc                   	cld    
  800a22:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");

	return v;
}
  800a24:	89 f8                	mov    %edi,%eax
  800a26:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800a29:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800a2c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800a2f:	89 ec                	mov    %ebp,%esp
  800a31:	5d                   	pop    %ebp
  800a32:	c3                   	ret    

00800a33 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a33:	55                   	push   %ebp
  800a34:	89 e5                	mov    %esp,%ebp
  800a36:	83 ec 08             	sub    $0x8,%esp
  800a39:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800a3c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800a3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a42:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a45:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a48:	39 c6                	cmp    %eax,%esi
  800a4a:	73 36                	jae    800a82 <memmove+0x4f>
  800a4c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a4f:	39 d0                	cmp    %edx,%eax
  800a51:	73 2f                	jae    800a82 <memmove+0x4f>
		s += n;
		d += n;
  800a53:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a56:	f6 c2 03             	test   $0x3,%dl
  800a59:	75 1b                	jne    800a76 <memmove+0x43>
  800a5b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a61:	75 13                	jne    800a76 <memmove+0x43>
  800a63:	f6 c1 03             	test   $0x3,%cl
  800a66:	75 0e                	jne    800a76 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a68:	83 ef 04             	sub    $0x4,%edi
  800a6b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a6e:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a71:	fd                   	std    
  800a72:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a74:	eb 09                	jmp    800a7f <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a76:	83 ef 01             	sub    $0x1,%edi
  800a79:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a7c:	fd                   	std    
  800a7d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a7f:	fc                   	cld    
  800a80:	eb 20                	jmp    800aa2 <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a82:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a88:	75 13                	jne    800a9d <memmove+0x6a>
  800a8a:	a8 03                	test   $0x3,%al
  800a8c:	75 0f                	jne    800a9d <memmove+0x6a>
  800a8e:	f6 c1 03             	test   $0x3,%cl
  800a91:	75 0a                	jne    800a9d <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a93:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a96:	89 c7                	mov    %eax,%edi
  800a98:	fc                   	cld    
  800a99:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a9b:	eb 05                	jmp    800aa2 <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a9d:	89 c7                	mov    %eax,%edi
  800a9f:	fc                   	cld    
  800aa0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aa2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800aa5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800aa8:	89 ec                	mov    %ebp,%esp
  800aaa:	5d                   	pop    %ebp
  800aab:	c3                   	ret    

00800aac <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800aac:	55                   	push   %ebp
  800aad:	89 e5                	mov    %esp,%ebp
  800aaf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ab2:	8b 45 10             	mov    0x10(%ebp),%eax
  800ab5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ab9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800abc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ac0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac3:	89 04 24             	mov    %eax,(%esp)
  800ac6:	e8 68 ff ff ff       	call   800a33 <memmove>
}
  800acb:	c9                   	leave  
  800acc:	c3                   	ret    

00800acd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800acd:	55                   	push   %ebp
  800ace:	89 e5                	mov    %esp,%ebp
  800ad0:	57                   	push   %edi
  800ad1:	56                   	push   %esi
  800ad2:	53                   	push   %ebx
  800ad3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ad6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ad9:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800adc:	8d 78 ff             	lea    -0x1(%eax),%edi
  800adf:	85 c0                	test   %eax,%eax
  800ae1:	74 36                	je     800b19 <memcmp+0x4c>
		if (*s1 != *s2)
  800ae3:	0f b6 03             	movzbl (%ebx),%eax
  800ae6:	0f b6 0e             	movzbl (%esi),%ecx
  800ae9:	38 c8                	cmp    %cl,%al
  800aeb:	75 17                	jne    800b04 <memcmp+0x37>
  800aed:	ba 00 00 00 00       	mov    $0x0,%edx
  800af2:	eb 1a                	jmp    800b0e <memcmp+0x41>
  800af4:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800af9:	83 c2 01             	add    $0x1,%edx
  800afc:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800b00:	38 c8                	cmp    %cl,%al
  800b02:	74 0a                	je     800b0e <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800b04:	0f b6 c0             	movzbl %al,%eax
  800b07:	0f b6 c9             	movzbl %cl,%ecx
  800b0a:	29 c8                	sub    %ecx,%eax
  800b0c:	eb 10                	jmp    800b1e <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b0e:	39 fa                	cmp    %edi,%edx
  800b10:	75 e2                	jne    800af4 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b12:	b8 00 00 00 00       	mov    $0x0,%eax
  800b17:	eb 05                	jmp    800b1e <memcmp+0x51>
  800b19:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b1e:	5b                   	pop    %ebx
  800b1f:	5e                   	pop    %esi
  800b20:	5f                   	pop    %edi
  800b21:	5d                   	pop    %ebp
  800b22:	c3                   	ret    

00800b23 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b23:	55                   	push   %ebp
  800b24:	89 e5                	mov    %esp,%ebp
  800b26:	53                   	push   %ebx
  800b27:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800b2d:	89 c2                	mov    %eax,%edx
  800b2f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b32:	39 d0                	cmp    %edx,%eax
  800b34:	73 13                	jae    800b49 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b36:	89 d9                	mov    %ebx,%ecx
  800b38:	38 18                	cmp    %bl,(%eax)
  800b3a:	75 06                	jne    800b42 <memfind+0x1f>
  800b3c:	eb 0b                	jmp    800b49 <memfind+0x26>
  800b3e:	38 08                	cmp    %cl,(%eax)
  800b40:	74 07                	je     800b49 <memfind+0x26>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b42:	83 c0 01             	add    $0x1,%eax
  800b45:	39 d0                	cmp    %edx,%eax
  800b47:	75 f5                	jne    800b3e <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b49:	5b                   	pop    %ebx
  800b4a:	5d                   	pop    %ebp
  800b4b:	c3                   	ret    

00800b4c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b4c:	55                   	push   %ebp
  800b4d:	89 e5                	mov    %esp,%ebp
  800b4f:	57                   	push   %edi
  800b50:	56                   	push   %esi
  800b51:	53                   	push   %ebx
  800b52:	83 ec 04             	sub    $0x4,%esp
  800b55:	8b 55 08             	mov    0x8(%ebp),%edx
  800b58:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b5b:	0f b6 02             	movzbl (%edx),%eax
  800b5e:	3c 09                	cmp    $0x9,%al
  800b60:	74 04                	je     800b66 <strtol+0x1a>
  800b62:	3c 20                	cmp    $0x20,%al
  800b64:	75 0e                	jne    800b74 <strtol+0x28>
		s++;
  800b66:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b69:	0f b6 02             	movzbl (%edx),%eax
  800b6c:	3c 09                	cmp    $0x9,%al
  800b6e:	74 f6                	je     800b66 <strtol+0x1a>
  800b70:	3c 20                	cmp    $0x20,%al
  800b72:	74 f2                	je     800b66 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b74:	3c 2b                	cmp    $0x2b,%al
  800b76:	75 0a                	jne    800b82 <strtol+0x36>
		s++;
  800b78:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b7b:	bf 00 00 00 00       	mov    $0x0,%edi
  800b80:	eb 10                	jmp    800b92 <strtol+0x46>
  800b82:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b87:	3c 2d                	cmp    $0x2d,%al
  800b89:	75 07                	jne    800b92 <strtol+0x46>
		s++, neg = 1;
  800b8b:	83 c2 01             	add    $0x1,%edx
  800b8e:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b92:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b98:	75 15                	jne    800baf <strtol+0x63>
  800b9a:	80 3a 30             	cmpb   $0x30,(%edx)
  800b9d:	75 10                	jne    800baf <strtol+0x63>
  800b9f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ba3:	75 0a                	jne    800baf <strtol+0x63>
		s += 2, base = 16;
  800ba5:	83 c2 02             	add    $0x2,%edx
  800ba8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bad:	eb 10                	jmp    800bbf <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800baf:	85 db                	test   %ebx,%ebx
  800bb1:	75 0c                	jne    800bbf <strtol+0x73>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bb3:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bb5:	80 3a 30             	cmpb   $0x30,(%edx)
  800bb8:	75 05                	jne    800bbf <strtol+0x73>
		s++, base = 8;
  800bba:	83 c2 01             	add    $0x1,%edx
  800bbd:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800bbf:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc4:	89 5d f0             	mov    %ebx,-0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bc7:	0f b6 0a             	movzbl (%edx),%ecx
  800bca:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800bcd:	89 f3                	mov    %esi,%ebx
  800bcf:	80 fb 09             	cmp    $0x9,%bl
  800bd2:	77 08                	ja     800bdc <strtol+0x90>
			dig = *s - '0';
  800bd4:	0f be c9             	movsbl %cl,%ecx
  800bd7:	83 e9 30             	sub    $0x30,%ecx
  800bda:	eb 22                	jmp    800bfe <strtol+0xb2>
		else if (*s >= 'a' && *s <= 'z')
  800bdc:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800bdf:	89 f3                	mov    %esi,%ebx
  800be1:	80 fb 19             	cmp    $0x19,%bl
  800be4:	77 08                	ja     800bee <strtol+0xa2>
			dig = *s - 'a' + 10;
  800be6:	0f be c9             	movsbl %cl,%ecx
  800be9:	83 e9 57             	sub    $0x57,%ecx
  800bec:	eb 10                	jmp    800bfe <strtol+0xb2>
		else if (*s >= 'A' && *s <= 'Z')
  800bee:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800bf1:	89 f3                	mov    %esi,%ebx
  800bf3:	80 fb 19             	cmp    $0x19,%bl
  800bf6:	77 16                	ja     800c0e <strtol+0xc2>
			dig = *s - 'A' + 10;
  800bf8:	0f be c9             	movsbl %cl,%ecx
  800bfb:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bfe:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800c01:	7d 0f                	jge    800c12 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800c03:	83 c2 01             	add    $0x1,%edx
  800c06:	0f af 45 f0          	imul   -0x10(%ebp),%eax
  800c0a:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800c0c:	eb b9                	jmp    800bc7 <strtol+0x7b>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c0e:	89 c1                	mov    %eax,%ecx
  800c10:	eb 02                	jmp    800c14 <strtol+0xc8>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c12:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c14:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c18:	74 05                	je     800c1f <strtol+0xd3>
		*endptr = (char *) s;
  800c1a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c1d:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c1f:	89 ca                	mov    %ecx,%edx
  800c21:	f7 da                	neg    %edx
  800c23:	85 ff                	test   %edi,%edi
  800c25:	0f 45 c2             	cmovne %edx,%eax
}
  800c28:	83 c4 04             	add    $0x4,%esp
  800c2b:	5b                   	pop    %ebx
  800c2c:	5e                   	pop    %esi
  800c2d:	5f                   	pop    %edi
  800c2e:	5d                   	pop    %ebp
  800c2f:	c3                   	ret    

00800c30 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c30:	55                   	push   %ebp
  800c31:	89 e5                	mov    %esp,%ebp
  800c33:	83 ec 0c             	sub    $0xc,%esp
  800c36:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c39:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c3c:	89 7d fc             	mov    %edi,-0x4(%ebp)
static inline uint32_t

get_cpu_features(void)
{
	uint32_t feature;
	__asm __volatile(" movl $1, %%eax\n\t"
  800c3f:	b8 01 00 00 00       	mov    $0x1,%eax
  800c44:	0f a2                	cpuid  
  800c46:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c48:	b8 00 00 00 00       	mov    $0x0,%eax
  800c4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c50:	8b 55 08             	mov    0x8(%ebp),%edx
  800c53:	89 c3                	mov    %eax,%ebx
  800c55:	89 c7                	mov    %eax,%edi
  800c57:	89 c6                	mov    %eax,%esi
  800c59:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c5b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c5e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c61:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c64:	89 ec                	mov    %ebp,%esp
  800c66:	5d                   	pop    %ebp
  800c67:	c3                   	ret    

00800c68 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c68:	55                   	push   %ebp
  800c69:	89 e5                	mov    %esp,%ebp
  800c6b:	83 ec 0c             	sub    $0xc,%esp
  800c6e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c71:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c74:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800c77:	b8 01 00 00 00       	mov    $0x1,%eax
  800c7c:	0f a2                	cpuid  
  800c7e:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c80:	ba 00 00 00 00       	mov    $0x0,%edx
  800c85:	b8 01 00 00 00       	mov    $0x1,%eax
  800c8a:	89 d1                	mov    %edx,%ecx
  800c8c:	89 d3                	mov    %edx,%ebx
  800c8e:	89 d7                	mov    %edx,%edi
  800c90:	89 d6                	mov    %edx,%esi
  800c92:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c94:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c97:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c9a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c9d:	89 ec                	mov    %ebp,%esp
  800c9f:	5d                   	pop    %ebp
  800ca0:	c3                   	ret    

00800ca1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ca1:	55                   	push   %ebp
  800ca2:	89 e5                	mov    %esp,%ebp
  800ca4:	83 ec 38             	sub    $0x38,%esp
  800ca7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800caa:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cad:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800cb0:	b8 01 00 00 00       	mov    $0x1,%eax
  800cb5:	0f a2                	cpuid  
  800cb7:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cbe:	b8 03 00 00 00       	mov    $0x3,%eax
  800cc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc6:	89 cb                	mov    %ecx,%ebx
  800cc8:	89 cf                	mov    %ecx,%edi
  800cca:	89 ce                	mov    %ecx,%esi
  800ccc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cce:	85 c0                	test   %eax,%eax
  800cd0:	7e 28                	jle    800cfa <sys_env_destroy+0x59>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cd6:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800cdd:	00 
  800cde:	c7 44 24 08 5f 20 80 	movl   $0x80205f,0x8(%esp)
  800ce5:	00 
  800ce6:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800ced:	00 
  800cee:	c7 04 24 7c 20 80 00 	movl   $0x80207c,(%esp)
  800cf5:	e8 96 0b 00 00       	call   801890 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cfa:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cfd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d00:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d03:	89 ec                	mov    %ebp,%esp
  800d05:	5d                   	pop    %ebp
  800d06:	c3                   	ret    

00800d07 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d07:	55                   	push   %ebp
  800d08:	89 e5                	mov    %esp,%ebp
  800d0a:	83 ec 0c             	sub    $0xc,%esp
  800d0d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d10:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d13:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d16:	b8 01 00 00 00       	mov    $0x1,%eax
  800d1b:	0f a2                	cpuid  
  800d1d:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1f:	ba 00 00 00 00       	mov    $0x0,%edx
  800d24:	b8 02 00 00 00       	mov    $0x2,%eax
  800d29:	89 d1                	mov    %edx,%ecx
  800d2b:	89 d3                	mov    %edx,%ebx
  800d2d:	89 d7                	mov    %edx,%edi
  800d2f:	89 d6                	mov    %edx,%esi
  800d31:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d33:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d36:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d39:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d3c:	89 ec                	mov    %ebp,%esp
  800d3e:	5d                   	pop    %ebp
  800d3f:	c3                   	ret    

00800d40 <sys_yield>:

void
sys_yield(void)
{
  800d40:	55                   	push   %ebp
  800d41:	89 e5                	mov    %esp,%ebp
  800d43:	83 ec 0c             	sub    $0xc,%esp
  800d46:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d49:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d4c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d4f:	b8 01 00 00 00       	mov    $0x1,%eax
  800d54:	0f a2                	cpuid  
  800d56:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d58:	ba 00 00 00 00       	mov    $0x0,%edx
  800d5d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d62:	89 d1                	mov    %edx,%ecx
  800d64:	89 d3                	mov    %edx,%ebx
  800d66:	89 d7                	mov    %edx,%edi
  800d68:	89 d6                	mov    %edx,%esi
  800d6a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d6c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d6f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d72:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d75:	89 ec                	mov    %ebp,%esp
  800d77:	5d                   	pop    %ebp
  800d78:	c3                   	ret    

00800d79 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d79:	55                   	push   %ebp
  800d7a:	89 e5                	mov    %esp,%ebp
  800d7c:	83 ec 38             	sub    $0x38,%esp
  800d7f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d82:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d85:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d88:	b8 01 00 00 00       	mov    $0x1,%eax
  800d8d:	0f a2                	cpuid  
  800d8f:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d91:	be 00 00 00 00       	mov    $0x0,%esi
  800d96:	b8 04 00 00 00       	mov    $0x4,%eax
  800d9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800da1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800da4:	89 f7                	mov    %esi,%edi
  800da6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800da8:	85 c0                	test   %eax,%eax
  800daa:	7e 28                	jle    800dd4 <sys_page_alloc+0x5b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dac:	89 44 24 10          	mov    %eax,0x10(%esp)
  800db0:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800db7:	00 
  800db8:	c7 44 24 08 5f 20 80 	movl   $0x80205f,0x8(%esp)
  800dbf:	00 
  800dc0:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800dc7:	00 
  800dc8:	c7 04 24 7c 20 80 00 	movl   $0x80207c,(%esp)
  800dcf:	e8 bc 0a 00 00       	call   801890 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800dd4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dd7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dda:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ddd:	89 ec                	mov    %ebp,%esp
  800ddf:	5d                   	pop    %ebp
  800de0:	c3                   	ret    

00800de1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800de1:	55                   	push   %ebp
  800de2:	89 e5                	mov    %esp,%ebp
  800de4:	83 ec 38             	sub    $0x38,%esp
  800de7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dea:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ded:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800df0:	b8 01 00 00 00       	mov    $0x1,%eax
  800df5:	0f a2                	cpuid  
  800df7:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df9:	b8 05 00 00 00       	mov    $0x5,%eax
  800dfe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e01:	8b 55 08             	mov    0x8(%ebp),%edx
  800e04:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e07:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e0a:	8b 75 18             	mov    0x18(%ebp),%esi
  800e0d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e0f:	85 c0                	test   %eax,%eax
  800e11:	7e 28                	jle    800e3b <sys_page_map+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e13:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e17:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e1e:	00 
  800e1f:	c7 44 24 08 5f 20 80 	movl   $0x80205f,0x8(%esp)
  800e26:	00 
  800e27:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800e2e:	00 
  800e2f:	c7 04 24 7c 20 80 00 	movl   $0x80207c,(%esp)
  800e36:	e8 55 0a 00 00       	call   801890 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e3b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e3e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e41:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e44:	89 ec                	mov    %ebp,%esp
  800e46:	5d                   	pop    %ebp
  800e47:	c3                   	ret    

00800e48 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e48:	55                   	push   %ebp
  800e49:	89 e5                	mov    %esp,%ebp
  800e4b:	83 ec 38             	sub    $0x38,%esp
  800e4e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e51:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e54:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e57:	b8 01 00 00 00       	mov    $0x1,%eax
  800e5c:	0f a2                	cpuid  
  800e5e:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e60:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e65:	b8 06 00 00 00       	mov    $0x6,%eax
  800e6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e70:	89 df                	mov    %ebx,%edi
  800e72:	89 de                	mov    %ebx,%esi
  800e74:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e76:	85 c0                	test   %eax,%eax
  800e78:	7e 28                	jle    800ea2 <sys_page_unmap+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e7a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e7e:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e85:	00 
  800e86:	c7 44 24 08 5f 20 80 	movl   $0x80205f,0x8(%esp)
  800e8d:	00 
  800e8e:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800e95:	00 
  800e96:	c7 04 24 7c 20 80 00 	movl   $0x80207c,(%esp)
  800e9d:	e8 ee 09 00 00       	call   801890 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ea2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ea5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ea8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800eab:	89 ec                	mov    %ebp,%esp
  800ead:	5d                   	pop    %ebp
  800eae:	c3                   	ret    

00800eaf <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800eaf:	55                   	push   %ebp
  800eb0:	89 e5                	mov    %esp,%ebp
  800eb2:	83 ec 38             	sub    $0x38,%esp
  800eb5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800eb8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ebb:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800ebe:	b8 01 00 00 00       	mov    $0x1,%eax
  800ec3:	0f a2                	cpuid  
  800ec5:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ec7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ecc:	b8 08 00 00 00       	mov    $0x8,%eax
  800ed1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed7:	89 df                	mov    %ebx,%edi
  800ed9:	89 de                	mov    %ebx,%esi
  800edb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800edd:	85 c0                	test   %eax,%eax
  800edf:	7e 28                	jle    800f09 <sys_env_set_status+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ee5:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800eec:	00 
  800eed:	c7 44 24 08 5f 20 80 	movl   $0x80205f,0x8(%esp)
  800ef4:	00 
  800ef5:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800efc:	00 
  800efd:	c7 04 24 7c 20 80 00 	movl   $0x80207c,(%esp)
  800f04:	e8 87 09 00 00       	call   801890 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f09:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f0c:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f0f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f12:	89 ec                	mov    %ebp,%esp
  800f14:	5d                   	pop    %ebp
  800f15:	c3                   	ret    

00800f16 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f16:	55                   	push   %ebp
  800f17:	89 e5                	mov    %esp,%ebp
  800f19:	83 ec 38             	sub    $0x38,%esp
  800f1c:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f1f:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f22:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800f25:	b8 01 00 00 00       	mov    $0x1,%eax
  800f2a:	0f a2                	cpuid  
  800f2c:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f2e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f33:	b8 09 00 00 00       	mov    $0x9,%eax
  800f38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f3e:	89 df                	mov    %ebx,%edi
  800f40:	89 de                	mov    %ebx,%esi
  800f42:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f44:	85 c0                	test   %eax,%eax
  800f46:	7e 28                	jle    800f70 <sys_env_set_trapframe+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f48:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f4c:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f53:	00 
  800f54:	c7 44 24 08 5f 20 80 	movl   $0x80205f,0x8(%esp)
  800f5b:	00 
  800f5c:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800f63:	00 
  800f64:	c7 04 24 7c 20 80 00 	movl   $0x80207c,(%esp)
  800f6b:	e8 20 09 00 00       	call   801890 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f70:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f73:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f76:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f79:	89 ec                	mov    %ebp,%esp
  800f7b:	5d                   	pop    %ebp
  800f7c:	c3                   	ret    

00800f7d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f7d:	55                   	push   %ebp
  800f7e:	89 e5                	mov    %esp,%ebp
  800f80:	83 ec 38             	sub    $0x38,%esp
  800f83:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f86:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f89:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800f8c:	b8 01 00 00 00       	mov    $0x1,%eax
  800f91:	0f a2                	cpuid  
  800f93:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f95:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f9a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fa2:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa5:	89 df                	mov    %ebx,%edi
  800fa7:	89 de                	mov    %ebx,%esi
  800fa9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fab:	85 c0                	test   %eax,%eax
  800fad:	7e 28                	jle    800fd7 <sys_env_set_pgfault_upcall+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800faf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fb3:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800fba:	00 
  800fbb:	c7 44 24 08 5f 20 80 	movl   $0x80205f,0x8(%esp)
  800fc2:	00 
  800fc3:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800fca:	00 
  800fcb:	c7 04 24 7c 20 80 00 	movl   $0x80207c,(%esp)
  800fd2:	e8 b9 08 00 00       	call   801890 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800fd7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fda:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fdd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fe0:	89 ec                	mov    %ebp,%esp
  800fe2:	5d                   	pop    %ebp
  800fe3:	c3                   	ret    

00800fe4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fe4:	55                   	push   %ebp
  800fe5:	89 e5                	mov    %esp,%ebp
  800fe7:	83 ec 0c             	sub    $0xc,%esp
  800fea:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fed:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ff0:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800ff3:	b8 01 00 00 00       	mov    $0x1,%eax
  800ff8:	0f a2                	cpuid  
  800ffa:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ffc:	be 00 00 00 00       	mov    $0x0,%esi
  801001:	b8 0c 00 00 00       	mov    $0xc,%eax
  801006:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801009:	8b 55 08             	mov    0x8(%ebp),%edx
  80100c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80100f:	8b 7d 14             	mov    0x14(%ebp),%edi
  801012:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801014:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801017:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80101a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80101d:	89 ec                	mov    %ebp,%esp
  80101f:	5d                   	pop    %ebp
  801020:	c3                   	ret    

00801021 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801021:	55                   	push   %ebp
  801022:	89 e5                	mov    %esp,%ebp
  801024:	83 ec 38             	sub    $0x38,%esp
  801027:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80102a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80102d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801030:	b8 01 00 00 00       	mov    $0x1,%eax
  801035:	0f a2                	cpuid  
  801037:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801039:	b9 00 00 00 00       	mov    $0x0,%ecx
  80103e:	b8 0d 00 00 00       	mov    $0xd,%eax
  801043:	8b 55 08             	mov    0x8(%ebp),%edx
  801046:	89 cb                	mov    %ecx,%ebx
  801048:	89 cf                	mov    %ecx,%edi
  80104a:	89 ce                	mov    %ecx,%esi
  80104c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80104e:	85 c0                	test   %eax,%eax
  801050:	7e 28                	jle    80107a <sys_ipc_recv+0x59>
		panic("syscall %d returned %d (> 0)", num, ret);
  801052:	89 44 24 10          	mov    %eax,0x10(%esp)
  801056:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  80105d:	00 
  80105e:	c7 44 24 08 5f 20 80 	movl   $0x80205f,0x8(%esp)
  801065:	00 
  801066:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  80106d:	00 
  80106e:	c7 04 24 7c 20 80 00 	movl   $0x80207c,(%esp)
  801075:	e8 16 08 00 00       	call   801890 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80107a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80107d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801080:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801083:	89 ec                	mov    %ebp,%esp
  801085:	5d                   	pop    %ebp
  801086:	c3                   	ret    
  801087:	66 90                	xchg   %ax,%ax
  801089:	66 90                	xchg   %ax,%ax
  80108b:	66 90                	xchg   %ax,%ax
  80108d:	66 90                	xchg   %ax,%ax
  80108f:	90                   	nop

00801090 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801090:	55                   	push   %ebp
  801091:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801093:	8b 45 08             	mov    0x8(%ebp),%eax
  801096:	05 00 00 00 30       	add    $0x30000000,%eax
  80109b:	c1 e8 0c             	shr    $0xc,%eax
}
  80109e:	5d                   	pop    %ebp
  80109f:	c3                   	ret    

008010a0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010a0:	55                   	push   %ebp
  8010a1:	89 e5                	mov    %esp,%ebp
  8010a3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8010a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a9:	89 04 24             	mov    %eax,(%esp)
  8010ac:	e8 df ff ff ff       	call   801090 <fd2num>
  8010b1:	c1 e0 0c             	shl    $0xc,%eax
  8010b4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010b9:	c9                   	leave  
  8010ba:	c3                   	ret    

008010bb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010bb:	55                   	push   %ebp
  8010bc:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8010be:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8010c3:	a8 01                	test   $0x1,%al
  8010c5:	74 34                	je     8010fb <fd_alloc+0x40>
  8010c7:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8010cc:	a8 01                	test   $0x1,%al
  8010ce:	74 32                	je     801102 <fd_alloc+0x47>
  8010d0:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8010d5:	89 c1                	mov    %eax,%ecx
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8010d7:	89 c2                	mov    %eax,%edx
  8010d9:	c1 ea 16             	shr    $0x16,%edx
  8010dc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010e3:	f6 c2 01             	test   $0x1,%dl
  8010e6:	74 1f                	je     801107 <fd_alloc+0x4c>
  8010e8:	89 c2                	mov    %eax,%edx
  8010ea:	c1 ea 0c             	shr    $0xc,%edx
  8010ed:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010f4:	f6 c2 01             	test   $0x1,%dl
  8010f7:	75 1a                	jne    801113 <fd_alloc+0x58>
  8010f9:	eb 0c                	jmp    801107 <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8010fb:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801100:	eb 05                	jmp    801107 <fd_alloc+0x4c>
  801102:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  801107:	8b 45 08             	mov    0x8(%ebp),%eax
  80110a:	89 08                	mov    %ecx,(%eax)
			return 0;
  80110c:	b8 00 00 00 00       	mov    $0x0,%eax
  801111:	eb 1a                	jmp    80112d <fd_alloc+0x72>
  801113:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801118:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80111d:	75 b6                	jne    8010d5 <fd_alloc+0x1a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80111f:	8b 45 08             	mov    0x8(%ebp),%eax
  801122:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801128:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80112d:	5d                   	pop    %ebp
  80112e:	c3                   	ret    

0080112f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80112f:	55                   	push   %ebp
  801130:	89 e5                	mov    %esp,%ebp
  801132:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801135:	83 f8 1f             	cmp    $0x1f,%eax
  801138:	77 36                	ja     801170 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80113a:	c1 e0 0c             	shl    $0xc,%eax
  80113d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801142:	89 c2                	mov    %eax,%edx
  801144:	c1 ea 16             	shr    $0x16,%edx
  801147:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80114e:	f6 c2 01             	test   $0x1,%dl
  801151:	74 24                	je     801177 <fd_lookup+0x48>
  801153:	89 c2                	mov    %eax,%edx
  801155:	c1 ea 0c             	shr    $0xc,%edx
  801158:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80115f:	f6 c2 01             	test   $0x1,%dl
  801162:	74 1a                	je     80117e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801164:	8b 55 0c             	mov    0xc(%ebp),%edx
  801167:	89 02                	mov    %eax,(%edx)
	return 0;
  801169:	b8 00 00 00 00       	mov    $0x0,%eax
  80116e:	eb 13                	jmp    801183 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  801170:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801175:	eb 0c                	jmp    801183 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  801177:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80117c:	eb 05                	jmp    801183 <fd_lookup+0x54>
  80117e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801183:	5d                   	pop    %ebp
  801184:	c3                   	ret    

00801185 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801185:	55                   	push   %ebp
  801186:	89 e5                	mov    %esp,%ebp
  801188:	83 ec 18             	sub    $0x18,%esp
  80118b:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80118e:	39 05 04 30 80 00    	cmp    %eax,0x803004
  801194:	75 10                	jne    8011a6 <dev_lookup+0x21>
			*dev = devtab[i];
  801196:	8b 45 0c             	mov    0xc(%ebp),%eax
  801199:	c7 00 04 30 80 00    	movl   $0x803004,(%eax)
			return 0;
  80119f:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a4:	eb 2b                	jmp    8011d1 <dev_lookup+0x4c>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011a6:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8011ac:	8b 52 48             	mov    0x48(%edx),%edx
  8011af:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8011b7:	c7 04 24 8c 20 80 00 	movl   $0x80208c,(%esp)
  8011be:	e8 ec ef ff ff       	call   8001af <cprintf>
	*dev = 0;
  8011c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011c6:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	return -E_INVAL;
  8011cc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011d1:	c9                   	leave  
  8011d2:	c3                   	ret    

008011d3 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011d3:	55                   	push   %ebp
  8011d4:	89 e5                	mov    %esp,%ebp
  8011d6:	83 ec 38             	sub    $0x38,%esp
  8011d9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8011dc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8011df:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8011e2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011e5:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011e8:	89 3c 24             	mov    %edi,(%esp)
  8011eb:	e8 a0 fe ff ff       	call   801090 <fd2num>
  8011f0:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8011f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8011f7:	89 04 24             	mov    %eax,(%esp)
  8011fa:	e8 30 ff ff ff       	call   80112f <fd_lookup>
  8011ff:	89 c3                	mov    %eax,%ebx
  801201:	85 c0                	test   %eax,%eax
  801203:	78 05                	js     80120a <fd_close+0x37>
	    || fd != fd2)
  801205:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  801208:	74 0c                	je     801216 <fd_close+0x43>
		return (must_exist ? r : 0);
  80120a:	85 f6                	test   %esi,%esi
  80120c:	b8 00 00 00 00       	mov    $0x0,%eax
  801211:	0f 44 d8             	cmove  %eax,%ebx
  801214:	eb 3d                	jmp    801253 <fd_close+0x80>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801216:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801219:	89 44 24 04          	mov    %eax,0x4(%esp)
  80121d:	8b 07                	mov    (%edi),%eax
  80121f:	89 04 24             	mov    %eax,(%esp)
  801222:	e8 5e ff ff ff       	call   801185 <dev_lookup>
  801227:	89 c3                	mov    %eax,%ebx
  801229:	85 c0                	test   %eax,%eax
  80122b:	78 16                	js     801243 <fd_close+0x70>
		if (dev->dev_close)
  80122d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801230:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801233:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801238:	85 c0                	test   %eax,%eax
  80123a:	74 07                	je     801243 <fd_close+0x70>
			r = (*dev->dev_close)(fd);
  80123c:	89 3c 24             	mov    %edi,(%esp)
  80123f:	ff d0                	call   *%eax
  801241:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801243:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801247:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80124e:	e8 f5 fb ff ff       	call   800e48 <sys_page_unmap>
	return r;
}
  801253:	89 d8                	mov    %ebx,%eax
  801255:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801258:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80125b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80125e:	89 ec                	mov    %ebp,%esp
  801260:	5d                   	pop    %ebp
  801261:	c3                   	ret    

00801262 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801262:	55                   	push   %ebp
  801263:	89 e5                	mov    %esp,%ebp
  801265:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801268:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80126b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80126f:	8b 45 08             	mov    0x8(%ebp),%eax
  801272:	89 04 24             	mov    %eax,(%esp)
  801275:	e8 b5 fe ff ff       	call   80112f <fd_lookup>
  80127a:	85 c0                	test   %eax,%eax
  80127c:	78 13                	js     801291 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80127e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801285:	00 
  801286:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801289:	89 04 24             	mov    %eax,(%esp)
  80128c:	e8 42 ff ff ff       	call   8011d3 <fd_close>
}
  801291:	c9                   	leave  
  801292:	c3                   	ret    

00801293 <close_all>:

void
close_all(void)
{
  801293:	55                   	push   %ebp
  801294:	89 e5                	mov    %esp,%ebp
  801296:	53                   	push   %ebx
  801297:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80129a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80129f:	89 1c 24             	mov    %ebx,(%esp)
  8012a2:	e8 bb ff ff ff       	call   801262 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012a7:	83 c3 01             	add    $0x1,%ebx
  8012aa:	83 fb 20             	cmp    $0x20,%ebx
  8012ad:	75 f0                	jne    80129f <close_all+0xc>
		close(i);
}
  8012af:	83 c4 14             	add    $0x14,%esp
  8012b2:	5b                   	pop    %ebx
  8012b3:	5d                   	pop    %ebp
  8012b4:	c3                   	ret    

008012b5 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012b5:	55                   	push   %ebp
  8012b6:	89 e5                	mov    %esp,%ebp
  8012b8:	83 ec 58             	sub    $0x58,%esp
  8012bb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8012be:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8012c1:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8012c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012c7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8012d1:	89 04 24             	mov    %eax,(%esp)
  8012d4:	e8 56 fe ff ff       	call   80112f <fd_lookup>
  8012d9:	85 c0                	test   %eax,%eax
  8012db:	0f 88 e3 00 00 00    	js     8013c4 <dup+0x10f>
		return r;
	close(newfdnum);
  8012e1:	89 1c 24             	mov    %ebx,(%esp)
  8012e4:	e8 79 ff ff ff       	call   801262 <close>

	newfd = INDEX2FD(newfdnum);
  8012e9:	89 de                	mov    %ebx,%esi
  8012eb:	c1 e6 0c             	shl    $0xc,%esi
  8012ee:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8012f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012f7:	89 04 24             	mov    %eax,(%esp)
  8012fa:	e8 a1 fd ff ff       	call   8010a0 <fd2data>
  8012ff:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801301:	89 34 24             	mov    %esi,(%esp)
  801304:	e8 97 fd ff ff       	call   8010a0 <fd2data>
  801309:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  80130c:	89 f8                	mov    %edi,%eax
  80130e:	c1 e8 16             	shr    $0x16,%eax
  801311:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801318:	a8 01                	test   $0x1,%al
  80131a:	74 46                	je     801362 <dup+0xad>
  80131c:	89 f8                	mov    %edi,%eax
  80131e:	c1 e8 0c             	shr    $0xc,%eax
  801321:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801328:	f6 c2 01             	test   $0x1,%dl
  80132b:	74 35                	je     801362 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80132d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801334:	25 07 0e 00 00       	and    $0xe07,%eax
  801339:	89 44 24 10          	mov    %eax,0x10(%esp)
  80133d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801340:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801344:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80134b:	00 
  80134c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801350:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801357:	e8 85 fa ff ff       	call   800de1 <sys_page_map>
  80135c:	89 c7                	mov    %eax,%edi
  80135e:	85 c0                	test   %eax,%eax
  801360:	78 3b                	js     80139d <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801362:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801365:	89 c2                	mov    %eax,%edx
  801367:	c1 ea 0c             	shr    $0xc,%edx
  80136a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801371:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801377:	89 54 24 10          	mov    %edx,0x10(%esp)
  80137b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80137f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801386:	00 
  801387:	89 44 24 04          	mov    %eax,0x4(%esp)
  80138b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801392:	e8 4a fa ff ff       	call   800de1 <sys_page_map>
  801397:	89 c7                	mov    %eax,%edi
  801399:	85 c0                	test   %eax,%eax
  80139b:	79 29                	jns    8013c6 <dup+0x111>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80139d:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013a8:	e8 9b fa ff ff       	call   800e48 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013ad:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8013b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013bb:	e8 88 fa ff ff       	call   800e48 <sys_page_unmap>
	return r;
  8013c0:	89 fb                	mov    %edi,%ebx
  8013c2:	eb 02                	jmp    8013c6 <dup+0x111>
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
		return r;
  8013c4:	89 c3                	mov    %eax,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8013c6:	89 d8                	mov    %ebx,%eax
  8013c8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8013cb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8013ce:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8013d1:	89 ec                	mov    %ebp,%esp
  8013d3:	5d                   	pop    %ebp
  8013d4:	c3                   	ret    

008013d5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013d5:	55                   	push   %ebp
  8013d6:	89 e5                	mov    %esp,%ebp
  8013d8:	53                   	push   %ebx
  8013d9:	83 ec 24             	sub    $0x24,%esp
  8013dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013df:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013e6:	89 1c 24             	mov    %ebx,(%esp)
  8013e9:	e8 41 fd ff ff       	call   80112f <fd_lookup>
  8013ee:	85 c0                	test   %eax,%eax
  8013f0:	78 6d                	js     80145f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013fc:	8b 00                	mov    (%eax),%eax
  8013fe:	89 04 24             	mov    %eax,(%esp)
  801401:	e8 7f fd ff ff       	call   801185 <dev_lookup>
  801406:	85 c0                	test   %eax,%eax
  801408:	78 55                	js     80145f <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80140a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80140d:	8b 50 08             	mov    0x8(%eax),%edx
  801410:	83 e2 03             	and    $0x3,%edx
  801413:	83 fa 01             	cmp    $0x1,%edx
  801416:	75 23                	jne    80143b <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801418:	a1 04 40 80 00       	mov    0x804004,%eax
  80141d:	8b 40 48             	mov    0x48(%eax),%eax
  801420:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801424:	89 44 24 04          	mov    %eax,0x4(%esp)
  801428:	c7 04 24 cd 20 80 00 	movl   $0x8020cd,(%esp)
  80142f:	e8 7b ed ff ff       	call   8001af <cprintf>
		return -E_INVAL;
  801434:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801439:	eb 24                	jmp    80145f <read+0x8a>
	}
	if (!dev->dev_read)
  80143b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80143e:	8b 52 08             	mov    0x8(%edx),%edx
  801441:	85 d2                	test   %edx,%edx
  801443:	74 15                	je     80145a <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801445:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801448:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80144c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80144f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801453:	89 04 24             	mov    %eax,(%esp)
  801456:	ff d2                	call   *%edx
  801458:	eb 05                	jmp    80145f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80145a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80145f:	83 c4 24             	add    $0x24,%esp
  801462:	5b                   	pop    %ebx
  801463:	5d                   	pop    %ebp
  801464:	c3                   	ret    

00801465 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801465:	55                   	push   %ebp
  801466:	89 e5                	mov    %esp,%ebp
  801468:	57                   	push   %edi
  801469:	56                   	push   %esi
  80146a:	53                   	push   %ebx
  80146b:	83 ec 1c             	sub    $0x1c,%esp
  80146e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801471:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801474:	85 f6                	test   %esi,%esi
  801476:	74 33                	je     8014ab <readn+0x46>
  801478:	b8 00 00 00 00       	mov    $0x0,%eax
  80147d:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801482:	89 f2                	mov    %esi,%edx
  801484:	29 c2                	sub    %eax,%edx
  801486:	89 54 24 08          	mov    %edx,0x8(%esp)
  80148a:	03 45 0c             	add    0xc(%ebp),%eax
  80148d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801491:	89 3c 24             	mov    %edi,(%esp)
  801494:	e8 3c ff ff ff       	call   8013d5 <read>
		if (m < 0)
  801499:	85 c0                	test   %eax,%eax
  80149b:	78 17                	js     8014b4 <readn+0x4f>
			return m;
		if (m == 0)
  80149d:	85 c0                	test   %eax,%eax
  80149f:	74 11                	je     8014b2 <readn+0x4d>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014a1:	01 c3                	add    %eax,%ebx
  8014a3:	89 d8                	mov    %ebx,%eax
  8014a5:	39 f3                	cmp    %esi,%ebx
  8014a7:	72 d9                	jb     801482 <readn+0x1d>
  8014a9:	eb 09                	jmp    8014b4 <readn+0x4f>
  8014ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8014b0:	eb 02                	jmp    8014b4 <readn+0x4f>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8014b2:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8014b4:	83 c4 1c             	add    $0x1c,%esp
  8014b7:	5b                   	pop    %ebx
  8014b8:	5e                   	pop    %esi
  8014b9:	5f                   	pop    %edi
  8014ba:	5d                   	pop    %ebp
  8014bb:	c3                   	ret    

008014bc <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014bc:	55                   	push   %ebp
  8014bd:	89 e5                	mov    %esp,%ebp
  8014bf:	53                   	push   %ebx
  8014c0:	83 ec 24             	sub    $0x24,%esp
  8014c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014cd:	89 1c 24             	mov    %ebx,(%esp)
  8014d0:	e8 5a fc ff ff       	call   80112f <fd_lookup>
  8014d5:	85 c0                	test   %eax,%eax
  8014d7:	78 68                	js     801541 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014e3:	8b 00                	mov    (%eax),%eax
  8014e5:	89 04 24             	mov    %eax,(%esp)
  8014e8:	e8 98 fc ff ff       	call   801185 <dev_lookup>
  8014ed:	85 c0                	test   %eax,%eax
  8014ef:	78 50                	js     801541 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014f4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014f8:	75 23                	jne    80151d <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014fa:	a1 04 40 80 00       	mov    0x804004,%eax
  8014ff:	8b 40 48             	mov    0x48(%eax),%eax
  801502:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801506:	89 44 24 04          	mov    %eax,0x4(%esp)
  80150a:	c7 04 24 e9 20 80 00 	movl   $0x8020e9,(%esp)
  801511:	e8 99 ec ff ff       	call   8001af <cprintf>
		return -E_INVAL;
  801516:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80151b:	eb 24                	jmp    801541 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80151d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801520:	8b 52 0c             	mov    0xc(%edx),%edx
  801523:	85 d2                	test   %edx,%edx
  801525:	74 15                	je     80153c <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801527:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80152a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80152e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801531:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801535:	89 04 24             	mov    %eax,(%esp)
  801538:	ff d2                	call   *%edx
  80153a:	eb 05                	jmp    801541 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80153c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801541:	83 c4 24             	add    $0x24,%esp
  801544:	5b                   	pop    %ebx
  801545:	5d                   	pop    %ebp
  801546:	c3                   	ret    

00801547 <seek>:

int
seek(int fdnum, off_t offset)
{
  801547:	55                   	push   %ebp
  801548:	89 e5                	mov    %esp,%ebp
  80154a:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80154d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801550:	89 44 24 04          	mov    %eax,0x4(%esp)
  801554:	8b 45 08             	mov    0x8(%ebp),%eax
  801557:	89 04 24             	mov    %eax,(%esp)
  80155a:	e8 d0 fb ff ff       	call   80112f <fd_lookup>
  80155f:	85 c0                	test   %eax,%eax
  801561:	78 0e                	js     801571 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801563:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801566:	8b 55 0c             	mov    0xc(%ebp),%edx
  801569:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80156c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801571:	c9                   	leave  
  801572:	c3                   	ret    

00801573 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801573:	55                   	push   %ebp
  801574:	89 e5                	mov    %esp,%ebp
  801576:	53                   	push   %ebx
  801577:	83 ec 24             	sub    $0x24,%esp
  80157a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80157d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801580:	89 44 24 04          	mov    %eax,0x4(%esp)
  801584:	89 1c 24             	mov    %ebx,(%esp)
  801587:	e8 a3 fb ff ff       	call   80112f <fd_lookup>
  80158c:	85 c0                	test   %eax,%eax
  80158e:	78 61                	js     8015f1 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801590:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801593:	89 44 24 04          	mov    %eax,0x4(%esp)
  801597:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80159a:	8b 00                	mov    (%eax),%eax
  80159c:	89 04 24             	mov    %eax,(%esp)
  80159f:	e8 e1 fb ff ff       	call   801185 <dev_lookup>
  8015a4:	85 c0                	test   %eax,%eax
  8015a6:	78 49                	js     8015f1 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ab:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015af:	75 23                	jne    8015d4 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015b1:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015b6:	8b 40 48             	mov    0x48(%eax),%eax
  8015b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8015bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015c1:	c7 04 24 ac 20 80 00 	movl   $0x8020ac,(%esp)
  8015c8:	e8 e2 eb ff ff       	call   8001af <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015d2:	eb 1d                	jmp    8015f1 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8015d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015d7:	8b 52 18             	mov    0x18(%edx),%edx
  8015da:	85 d2                	test   %edx,%edx
  8015dc:	74 0e                	je     8015ec <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015e1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8015e5:	89 04 24             	mov    %eax,(%esp)
  8015e8:	ff d2                	call   *%edx
  8015ea:	eb 05                	jmp    8015f1 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015ec:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8015f1:	83 c4 24             	add    $0x24,%esp
  8015f4:	5b                   	pop    %ebx
  8015f5:	5d                   	pop    %ebp
  8015f6:	c3                   	ret    

008015f7 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015f7:	55                   	push   %ebp
  8015f8:	89 e5                	mov    %esp,%ebp
  8015fa:	53                   	push   %ebx
  8015fb:	83 ec 24             	sub    $0x24,%esp
  8015fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801601:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801604:	89 44 24 04          	mov    %eax,0x4(%esp)
  801608:	8b 45 08             	mov    0x8(%ebp),%eax
  80160b:	89 04 24             	mov    %eax,(%esp)
  80160e:	e8 1c fb ff ff       	call   80112f <fd_lookup>
  801613:	85 c0                	test   %eax,%eax
  801615:	78 52                	js     801669 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801617:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80161a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80161e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801621:	8b 00                	mov    (%eax),%eax
  801623:	89 04 24             	mov    %eax,(%esp)
  801626:	e8 5a fb ff ff       	call   801185 <dev_lookup>
  80162b:	85 c0                	test   %eax,%eax
  80162d:	78 3a                	js     801669 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  80162f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801632:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801636:	74 2c                	je     801664 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801638:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80163b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801642:	00 00 00 
	stat->st_isdir = 0;
  801645:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80164c:	00 00 00 
	stat->st_dev = dev;
  80164f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801655:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801659:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80165c:	89 14 24             	mov    %edx,(%esp)
  80165f:	ff 50 14             	call   *0x14(%eax)
  801662:	eb 05                	jmp    801669 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801664:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801669:	83 c4 24             	add    $0x24,%esp
  80166c:	5b                   	pop    %ebx
  80166d:	5d                   	pop    %ebp
  80166e:	c3                   	ret    

0080166f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80166f:	55                   	push   %ebp
  801670:	89 e5                	mov    %esp,%ebp
  801672:	83 ec 18             	sub    $0x18,%esp
  801675:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801678:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80167b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801682:	00 
  801683:	8b 45 08             	mov    0x8(%ebp),%eax
  801686:	89 04 24             	mov    %eax,(%esp)
  801689:	e8 84 01 00 00       	call   801812 <open>
  80168e:	89 c3                	mov    %eax,%ebx
  801690:	85 c0                	test   %eax,%eax
  801692:	78 1b                	js     8016af <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801694:	8b 45 0c             	mov    0xc(%ebp),%eax
  801697:	89 44 24 04          	mov    %eax,0x4(%esp)
  80169b:	89 1c 24             	mov    %ebx,(%esp)
  80169e:	e8 54 ff ff ff       	call   8015f7 <fstat>
  8016a3:	89 c6                	mov    %eax,%esi
	close(fd);
  8016a5:	89 1c 24             	mov    %ebx,(%esp)
  8016a8:	e8 b5 fb ff ff       	call   801262 <close>
	return r;
  8016ad:	89 f3                	mov    %esi,%ebx
}
  8016af:	89 d8                	mov    %ebx,%eax
  8016b1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8016b4:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8016b7:	89 ec                	mov    %ebp,%esp
  8016b9:	5d                   	pop    %ebp
  8016ba:	c3                   	ret    
  8016bb:	90                   	nop

008016bc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016bc:	55                   	push   %ebp
  8016bd:	89 e5                	mov    %esp,%ebp
  8016bf:	83 ec 18             	sub    $0x18,%esp
  8016c2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8016c5:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8016c8:	89 c6                	mov    %eax,%esi
  8016ca:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016cc:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016d3:	75 11                	jne    8016e6 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016d5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8016dc:	e8 ca 02 00 00       	call   8019ab <ipc_find_env>
  8016e1:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016e6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8016ed:	00 
  8016ee:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8016f5:	00 
  8016f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016fa:	a1 00 40 80 00       	mov    0x804000,%eax
  8016ff:	89 04 24             	mov    %eax,(%esp)
  801702:	e8 39 02 00 00       	call   801940 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801707:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80170e:	00 
  80170f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801713:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80171a:	e8 c9 01 00 00       	call   8018e8 <ipc_recv>
}
  80171f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801722:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801725:	89 ec                	mov    %ebp,%esp
  801727:	5d                   	pop    %ebp
  801728:	c3                   	ret    

00801729 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801729:	55                   	push   %ebp
  80172a:	89 e5                	mov    %esp,%ebp
  80172c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80172f:	8b 45 08             	mov    0x8(%ebp),%eax
  801732:	8b 40 0c             	mov    0xc(%eax),%eax
  801735:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80173a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80173d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801742:	ba 00 00 00 00       	mov    $0x0,%edx
  801747:	b8 02 00 00 00       	mov    $0x2,%eax
  80174c:	e8 6b ff ff ff       	call   8016bc <fsipc>
}
  801751:	c9                   	leave  
  801752:	c3                   	ret    

00801753 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801753:	55                   	push   %ebp
  801754:	89 e5                	mov    %esp,%ebp
  801756:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801759:	8b 45 08             	mov    0x8(%ebp),%eax
  80175c:	8b 40 0c             	mov    0xc(%eax),%eax
  80175f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801764:	ba 00 00 00 00       	mov    $0x0,%edx
  801769:	b8 06 00 00 00       	mov    $0x6,%eax
  80176e:	e8 49 ff ff ff       	call   8016bc <fsipc>
}
  801773:	c9                   	leave  
  801774:	c3                   	ret    

00801775 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801775:	55                   	push   %ebp
  801776:	89 e5                	mov    %esp,%ebp
  801778:	53                   	push   %ebx
  801779:	83 ec 14             	sub    $0x14,%esp
  80177c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80177f:	8b 45 08             	mov    0x8(%ebp),%eax
  801782:	8b 40 0c             	mov    0xc(%eax),%eax
  801785:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80178a:	ba 00 00 00 00       	mov    $0x0,%edx
  80178f:	b8 05 00 00 00       	mov    $0x5,%eax
  801794:	e8 23 ff ff ff       	call   8016bc <fsipc>
  801799:	85 c0                	test   %eax,%eax
  80179b:	78 2b                	js     8017c8 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80179d:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8017a4:	00 
  8017a5:	89 1c 24             	mov    %ebx,(%esp)
  8017a8:	e8 7e f0 ff ff       	call   80082b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017ad:	a1 80 50 80 00       	mov    0x805080,%eax
  8017b2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017b8:	a1 84 50 80 00       	mov    0x805084,%eax
  8017bd:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017c8:	83 c4 14             	add    $0x14,%esp
  8017cb:	5b                   	pop    %ebx
  8017cc:	5d                   	pop    %ebp
  8017cd:	c3                   	ret    

008017ce <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017ce:	55                   	push   %ebp
  8017cf:	89 e5                	mov    %esp,%ebp
  8017d1:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8017d4:	c7 44 24 08 06 21 80 	movl   $0x802106,0x8(%esp)
  8017db:	00 
  8017dc:	c7 44 24 04 77 00 00 	movl   $0x77,0x4(%esp)
  8017e3:	00 
  8017e4:	c7 04 24 24 21 80 00 	movl   $0x802124,(%esp)
  8017eb:	e8 a0 00 00 00       	call   801890 <_panic>

008017f0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017f0:	55                   	push   %ebp
  8017f1:	89 e5                	mov    %esp,%ebp
  8017f3:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_READ request to the file system server after
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
	panic("devfile_read not implemented");
  8017f6:	c7 44 24 08 2f 21 80 	movl   $0x80212f,0x8(%esp)
  8017fd:	00 
  8017fe:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
  801805:	00 
  801806:	c7 04 24 24 21 80 00 	movl   $0x802124,(%esp)
  80180d:	e8 7e 00 00 00       	call   801890 <_panic>

00801812 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801812:	55                   	push   %ebp
  801813:	89 e5                	mov    %esp,%ebp
  801815:	83 ec 18             	sub    $0x18,%esp
	// Return the file descriptor index.
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
	panic("open not implemented");
  801818:	c7 44 24 08 4c 21 80 	movl   $0x80214c,0x8(%esp)
  80181f:	00 
  801820:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  801827:	00 
  801828:	c7 04 24 24 21 80 00 	movl   $0x802124,(%esp)
  80182f:	e8 5c 00 00 00       	call   801890 <_panic>

00801834 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801834:	55                   	push   %ebp
  801835:	89 e5                	mov    %esp,%ebp
  801837:	53                   	push   %ebx
  801838:	83 ec 14             	sub    $0x14,%esp
  80183b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  80183e:	89 1c 24             	mov    %ebx,(%esp)
  801841:	e8 8a ef ff ff       	call   8007d0 <strlen>
  801846:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80184b:	7f 21                	jg     80186e <remove+0x3a>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  80184d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801851:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801858:	e8 ce ef ff ff       	call   80082b <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  80185d:	ba 00 00 00 00       	mov    $0x0,%edx
  801862:	b8 07 00 00 00       	mov    $0x7,%eax
  801867:	e8 50 fe ff ff       	call   8016bc <fsipc>
  80186c:	eb 05                	jmp    801873 <remove+0x3f>
// Delete a file
int
remove(const char *path)
{
	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80186e:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
	strcpy(fsipcbuf.remove.req_path, path);
	return fsipc(FSREQ_REMOVE, NULL);
}
  801873:	83 c4 14             	add    $0x14,%esp
  801876:	5b                   	pop    %ebx
  801877:	5d                   	pop    %ebp
  801878:	c3                   	ret    

00801879 <sync>:

// Synchronize disk with buffer cache
int
sync(void)
{
  801879:	55                   	push   %ebp
  80187a:	89 e5                	mov    %esp,%ebp
  80187c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80187f:	ba 00 00 00 00       	mov    $0x0,%edx
  801884:	b8 08 00 00 00       	mov    $0x8,%eax
  801889:	e8 2e fe ff ff       	call   8016bc <fsipc>
}
  80188e:	c9                   	leave  
  80188f:	c3                   	ret    

00801890 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801890:	55                   	push   %ebp
  801891:	89 e5                	mov    %esp,%ebp
  801893:	56                   	push   %esi
  801894:	53                   	push   %ebx
  801895:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801898:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80189b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8018a1:	e8 61 f4 ff ff       	call   800d07 <sys_getenvid>
  8018a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018a9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8018ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8018b0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8018b4:	89 74 24 08          	mov    %esi,0x8(%esp)
  8018b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018bc:	c7 04 24 64 21 80 00 	movl   $0x802164,(%esp)
  8018c3:	e8 e7 e8 ff ff       	call   8001af <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8018c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018cc:	8b 45 10             	mov    0x10(%ebp),%eax
  8018cf:	89 04 24             	mov    %eax,(%esp)
  8018d2:	e8 77 e8 ff ff       	call   80014e <vcprintf>
	cprintf("\n");
  8018d7:	c7 04 24 9d 21 80 00 	movl   $0x80219d,(%esp)
  8018de:	e8 cc e8 ff ff       	call   8001af <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8018e3:	cc                   	int3   
  8018e4:	eb fd                	jmp    8018e3 <_panic+0x53>
  8018e6:	66 90                	xchg   %ax,%ax

008018e8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8018e8:	55                   	push   %ebp
  8018e9:	89 e5                	mov    %esp,%ebp
  8018eb:	56                   	push   %esi
  8018ec:	53                   	push   %ebx
  8018ed:	83 ec 10             	sub    $0x10,%esp
  8018f0:	8b 75 08             	mov    0x8(%ebp),%esi
  8018f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	// 	return thisenv->env_ipc_value;
	// }
	int r;
	if(pg == NULL)
		pg = (void *)~0x0;
  8018f6:	85 db                	test   %ebx,%ebx
  8018f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8018fd:	0f 44 d8             	cmove  %eax,%ebx
	//else
	if((r = sys_ipc_recv(pg)) < 0)
  801900:	89 1c 24             	mov    %ebx,(%esp)
  801903:	e8 19 f7 ff ff       	call   801021 <sys_ipc_recv>
  801908:	85 c0                	test   %eax,%eax
  80190a:	78 2d                	js     801939 <ipc_recv+0x51>
		return r;
	//volatile struct Env *curenv = (struct Env*)envs+ENVX(sys_getenvid());

	if(from_env_store)
  80190c:	85 f6                	test   %esi,%esi
  80190e:	74 0a                	je     80191a <ipc_recv+0x32>
		*from_env_store = thisenv -> env_ipc_from;
  801910:	a1 04 40 80 00       	mov    0x804004,%eax
  801915:	8b 40 74             	mov    0x74(%eax),%eax
  801918:	89 06                	mov    %eax,(%esi)
	if(pg && perm_store)
  80191a:	85 db                	test   %ebx,%ebx
  80191c:	74 13                	je     801931 <ipc_recv+0x49>
  80191e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801922:	74 0d                	je     801931 <ipc_recv+0x49>
		*perm_store = thisenv -> env_ipc_perm;
  801924:	a1 04 40 80 00       	mov    0x804004,%eax
  801929:	8b 40 78             	mov    0x78(%eax),%eax
  80192c:	8b 55 10             	mov    0x10(%ebp),%edx
  80192f:	89 02                	mov    %eax,(%edx)
	else if(perm_store)
		perm_store = (int *)0;
	return thisenv->env_ipc_value;
  801931:	a1 04 40 80 00       	mov    0x804004,%eax
  801936:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  801939:	83 c4 10             	add    $0x10,%esp
  80193c:	5b                   	pop    %ebx
  80193d:	5e                   	pop    %esi
  80193e:	5d                   	pop    %ebp
  80193f:	c3                   	ret    

00801940 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801940:	55                   	push   %ebp
  801941:	89 e5                	mov    %esp,%ebp
  801943:	57                   	push   %edi
  801944:	56                   	push   %esi
  801945:	53                   	push   %ebx
  801946:	83 ec 1c             	sub    $0x1c,%esp
  801949:	8b 7d 08             	mov    0x8(%ebp),%edi
  80194c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80194f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

	if(pg == NULL)
  801952:	85 db                	test   %ebx,%ebx
		pg = (void *)~0x0;
  801954:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801959:	0f 44 d8             	cmove  %eax,%ebx
  80195c:	eb 2a                	jmp    801988 <ipc_send+0x48>
	while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0){
		if(r != -E_IPC_NOT_RECV)
  80195e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801961:	74 20                	je     801983 <ipc_send+0x43>
            panic("Send message error %e\n",r);
  801963:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801967:	c7 44 24 08 88 21 80 	movl   $0x802188,0x8(%esp)
  80196e:	00 
  80196f:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  801976:	00 
  801977:	c7 04 24 9f 21 80 00 	movl   $0x80219f,(%esp)
  80197e:	e8 0d ff ff ff       	call   801890 <_panic>
		sys_yield();
  801983:	e8 b8 f3 ff ff       	call   800d40 <sys_yield>
	// LAB 4: Your code here.
	int r;

	if(pg == NULL)
		pg = (void *)~0x0;
	while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0){
  801988:	8b 45 14             	mov    0x14(%ebp),%eax
  80198b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80198f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801993:	89 74 24 04          	mov    %esi,0x4(%esp)
  801997:	89 3c 24             	mov    %edi,(%esp)
  80199a:	e8 45 f6 ff ff       	call   800fe4 <sys_ipc_try_send>
  80199f:	85 c0                	test   %eax,%eax
  8019a1:	78 bb                	js     80195e <ipc_send+0x1e>
            panic("Send message error %e\n",r);
		sys_yield();
	}

	//panic("ipc_send not implemented");
}
  8019a3:	83 c4 1c             	add    $0x1c,%esp
  8019a6:	5b                   	pop    %ebx
  8019a7:	5e                   	pop    %esi
  8019a8:	5f                   	pop    %edi
  8019a9:	5d                   	pop    %ebp
  8019aa:	c3                   	ret    

008019ab <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8019ab:	55                   	push   %ebp
  8019ac:	89 e5                	mov    %esp,%ebp
  8019ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8019b1:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  8019b6:	39 c8                	cmp    %ecx,%eax
  8019b8:	74 17                	je     8019d1 <ipc_find_env+0x26>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8019ba:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  8019bf:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8019c2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8019c8:	8b 52 50             	mov    0x50(%edx),%edx
  8019cb:	39 ca                	cmp    %ecx,%edx
  8019cd:	75 14                	jne    8019e3 <ipc_find_env+0x38>
  8019cf:	eb 05                	jmp    8019d6 <ipc_find_env+0x2b>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8019d1:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  8019d6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8019d9:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8019de:	8b 40 40             	mov    0x40(%eax),%eax
  8019e1:	eb 0e                	jmp    8019f1 <ipc_find_env+0x46>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8019e3:	83 c0 01             	add    $0x1,%eax
  8019e6:	3d 00 04 00 00       	cmp    $0x400,%eax
  8019eb:	75 d2                	jne    8019bf <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8019ed:	66 b8 00 00          	mov    $0x0,%ax
}
  8019f1:	5d                   	pop    %ebp
  8019f2:	c3                   	ret    
  8019f3:	66 90                	xchg   %ax,%ax
  8019f5:	66 90                	xchg   %ax,%ax
  8019f7:	66 90                	xchg   %ax,%ax
  8019f9:	66 90                	xchg   %ax,%ax
  8019fb:	66 90                	xchg   %ax,%ax
  8019fd:	66 90                	xchg   %ax,%ax
  8019ff:	90                   	nop

00801a00 <__udivdi3>:
  801a00:	83 ec 1c             	sub    $0x1c,%esp
  801a03:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801a07:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801a0b:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801a0f:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801a13:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801a17:	8b 6c 24 24          	mov    0x24(%esp),%ebp
  801a1b:	85 c0                	test   %eax,%eax
  801a1d:	89 74 24 10          	mov    %esi,0x10(%esp)
  801a21:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801a25:	89 ea                	mov    %ebp,%edx
  801a27:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801a2b:	75 33                	jne    801a60 <__udivdi3+0x60>
  801a2d:	39 e9                	cmp    %ebp,%ecx
  801a2f:	77 6f                	ja     801aa0 <__udivdi3+0xa0>
  801a31:	85 c9                	test   %ecx,%ecx
  801a33:	89 ce                	mov    %ecx,%esi
  801a35:	75 0b                	jne    801a42 <__udivdi3+0x42>
  801a37:	b8 01 00 00 00       	mov    $0x1,%eax
  801a3c:	31 d2                	xor    %edx,%edx
  801a3e:	f7 f1                	div    %ecx
  801a40:	89 c6                	mov    %eax,%esi
  801a42:	31 d2                	xor    %edx,%edx
  801a44:	89 e8                	mov    %ebp,%eax
  801a46:	f7 f6                	div    %esi
  801a48:	89 c5                	mov    %eax,%ebp
  801a4a:	89 f8                	mov    %edi,%eax
  801a4c:	f7 f6                	div    %esi
  801a4e:	89 ea                	mov    %ebp,%edx
  801a50:	8b 74 24 10          	mov    0x10(%esp),%esi
  801a54:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801a58:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801a5c:	83 c4 1c             	add    $0x1c,%esp
  801a5f:	c3                   	ret    
  801a60:	39 e8                	cmp    %ebp,%eax
  801a62:	77 24                	ja     801a88 <__udivdi3+0x88>
  801a64:	0f bd c8             	bsr    %eax,%ecx
  801a67:	83 f1 1f             	xor    $0x1f,%ecx
  801a6a:	89 0c 24             	mov    %ecx,(%esp)
  801a6d:	75 49                	jne    801ab8 <__udivdi3+0xb8>
  801a6f:	8b 74 24 08          	mov    0x8(%esp),%esi
  801a73:	39 74 24 04          	cmp    %esi,0x4(%esp)
  801a77:	0f 86 ab 00 00 00    	jbe    801b28 <__udivdi3+0x128>
  801a7d:	39 e8                	cmp    %ebp,%eax
  801a7f:	0f 82 a3 00 00 00    	jb     801b28 <__udivdi3+0x128>
  801a85:	8d 76 00             	lea    0x0(%esi),%esi
  801a88:	31 d2                	xor    %edx,%edx
  801a8a:	31 c0                	xor    %eax,%eax
  801a8c:	8b 74 24 10          	mov    0x10(%esp),%esi
  801a90:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801a94:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801a98:	83 c4 1c             	add    $0x1c,%esp
  801a9b:	c3                   	ret    
  801a9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801aa0:	89 f8                	mov    %edi,%eax
  801aa2:	f7 f1                	div    %ecx
  801aa4:	31 d2                	xor    %edx,%edx
  801aa6:	8b 74 24 10          	mov    0x10(%esp),%esi
  801aaa:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801aae:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801ab2:	83 c4 1c             	add    $0x1c,%esp
  801ab5:	c3                   	ret    
  801ab6:	66 90                	xchg   %ax,%ax
  801ab8:	0f b6 0c 24          	movzbl (%esp),%ecx
  801abc:	89 c6                	mov    %eax,%esi
  801abe:	b8 20 00 00 00       	mov    $0x20,%eax
  801ac3:	8b 6c 24 04          	mov    0x4(%esp),%ebp
  801ac7:	2b 04 24             	sub    (%esp),%eax
  801aca:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801ace:	d3 e6                	shl    %cl,%esi
  801ad0:	89 c1                	mov    %eax,%ecx
  801ad2:	d3 ed                	shr    %cl,%ebp
  801ad4:	0f b6 0c 24          	movzbl (%esp),%ecx
  801ad8:	09 f5                	or     %esi,%ebp
  801ada:	8b 74 24 04          	mov    0x4(%esp),%esi
  801ade:	d3 e6                	shl    %cl,%esi
  801ae0:	89 c1                	mov    %eax,%ecx
  801ae2:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ae6:	89 d6                	mov    %edx,%esi
  801ae8:	d3 ee                	shr    %cl,%esi
  801aea:	0f b6 0c 24          	movzbl (%esp),%ecx
  801aee:	d3 e2                	shl    %cl,%edx
  801af0:	89 c1                	mov    %eax,%ecx
  801af2:	d3 ef                	shr    %cl,%edi
  801af4:	09 d7                	or     %edx,%edi
  801af6:	89 f2                	mov    %esi,%edx
  801af8:	89 f8                	mov    %edi,%eax
  801afa:	f7 f5                	div    %ebp
  801afc:	89 d6                	mov    %edx,%esi
  801afe:	89 c7                	mov    %eax,%edi
  801b00:	f7 64 24 04          	mull   0x4(%esp)
  801b04:	39 d6                	cmp    %edx,%esi
  801b06:	72 30                	jb     801b38 <__udivdi3+0x138>
  801b08:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801b0c:	0f b6 0c 24          	movzbl (%esp),%ecx
  801b10:	d3 e5                	shl    %cl,%ebp
  801b12:	39 c5                	cmp    %eax,%ebp
  801b14:	73 04                	jae    801b1a <__udivdi3+0x11a>
  801b16:	39 d6                	cmp    %edx,%esi
  801b18:	74 1e                	je     801b38 <__udivdi3+0x138>
  801b1a:	89 f8                	mov    %edi,%eax
  801b1c:	31 d2                	xor    %edx,%edx
  801b1e:	e9 69 ff ff ff       	jmp    801a8c <__udivdi3+0x8c>
  801b23:	90                   	nop
  801b24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801b28:	31 d2                	xor    %edx,%edx
  801b2a:	b8 01 00 00 00       	mov    $0x1,%eax
  801b2f:	e9 58 ff ff ff       	jmp    801a8c <__udivdi3+0x8c>
  801b34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801b38:	8d 47 ff             	lea    -0x1(%edi),%eax
  801b3b:	31 d2                	xor    %edx,%edx
  801b3d:	8b 74 24 10          	mov    0x10(%esp),%esi
  801b41:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801b45:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801b49:	83 c4 1c             	add    $0x1c,%esp
  801b4c:	c3                   	ret    
  801b4d:	66 90                	xchg   %ax,%ax
  801b4f:	90                   	nop

00801b50 <__umoddi3>:
  801b50:	83 ec 2c             	sub    $0x2c,%esp
  801b53:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801b57:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801b5b:	89 74 24 20          	mov    %esi,0x20(%esp)
  801b5f:	8b 74 24 38          	mov    0x38(%esp),%esi
  801b63:	89 7c 24 24          	mov    %edi,0x24(%esp)
  801b67:	8b 7c 24 34          	mov    0x34(%esp),%edi
  801b6b:	85 c0                	test   %eax,%eax
  801b6d:	89 c2                	mov    %eax,%edx
  801b6f:	89 6c 24 28          	mov    %ebp,0x28(%esp)
  801b73:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801b77:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801b7b:	89 74 24 10          	mov    %esi,0x10(%esp)
  801b7f:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801b83:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801b87:	75 1f                	jne    801ba8 <__umoddi3+0x58>
  801b89:	39 fe                	cmp    %edi,%esi
  801b8b:	76 63                	jbe    801bf0 <__umoddi3+0xa0>
  801b8d:	89 c8                	mov    %ecx,%eax
  801b8f:	89 fa                	mov    %edi,%edx
  801b91:	f7 f6                	div    %esi
  801b93:	89 d0                	mov    %edx,%eax
  801b95:	31 d2                	xor    %edx,%edx
  801b97:	8b 74 24 20          	mov    0x20(%esp),%esi
  801b9b:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801b9f:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801ba3:	83 c4 2c             	add    $0x2c,%esp
  801ba6:	c3                   	ret    
  801ba7:	90                   	nop
  801ba8:	39 f8                	cmp    %edi,%eax
  801baa:	77 64                	ja     801c10 <__umoddi3+0xc0>
  801bac:	0f bd e8             	bsr    %eax,%ebp
  801baf:	83 f5 1f             	xor    $0x1f,%ebp
  801bb2:	75 74                	jne    801c28 <__umoddi3+0xd8>
  801bb4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801bb8:	39 7c 24 10          	cmp    %edi,0x10(%esp)
  801bbc:	0f 87 0e 01 00 00    	ja     801cd0 <__umoddi3+0x180>
  801bc2:	8b 7c 24 0c          	mov    0xc(%esp),%edi
  801bc6:	29 f1                	sub    %esi,%ecx
  801bc8:	19 c7                	sbb    %eax,%edi
  801bca:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801bce:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801bd2:	8b 44 24 14          	mov    0x14(%esp),%eax
  801bd6:	8b 54 24 18          	mov    0x18(%esp),%edx
  801bda:	8b 74 24 20          	mov    0x20(%esp),%esi
  801bde:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801be2:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801be6:	83 c4 2c             	add    $0x2c,%esp
  801be9:	c3                   	ret    
  801bea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801bf0:	85 f6                	test   %esi,%esi
  801bf2:	89 f5                	mov    %esi,%ebp
  801bf4:	75 0b                	jne    801c01 <__umoddi3+0xb1>
  801bf6:	b8 01 00 00 00       	mov    $0x1,%eax
  801bfb:	31 d2                	xor    %edx,%edx
  801bfd:	f7 f6                	div    %esi
  801bff:	89 c5                	mov    %eax,%ebp
  801c01:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801c05:	31 d2                	xor    %edx,%edx
  801c07:	f7 f5                	div    %ebp
  801c09:	89 c8                	mov    %ecx,%eax
  801c0b:	f7 f5                	div    %ebp
  801c0d:	eb 84                	jmp    801b93 <__umoddi3+0x43>
  801c0f:	90                   	nop
  801c10:	89 c8                	mov    %ecx,%eax
  801c12:	89 fa                	mov    %edi,%edx
  801c14:	8b 74 24 20          	mov    0x20(%esp),%esi
  801c18:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801c1c:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801c20:	83 c4 2c             	add    $0x2c,%esp
  801c23:	c3                   	ret    
  801c24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c28:	8b 44 24 10          	mov    0x10(%esp),%eax
  801c2c:	be 20 00 00 00       	mov    $0x20,%esi
  801c31:	89 e9                	mov    %ebp,%ecx
  801c33:	29 ee                	sub    %ebp,%esi
  801c35:	d3 e2                	shl    %cl,%edx
  801c37:	89 f1                	mov    %esi,%ecx
  801c39:	d3 e8                	shr    %cl,%eax
  801c3b:	89 e9                	mov    %ebp,%ecx
  801c3d:	09 d0                	or     %edx,%eax
  801c3f:	89 fa                	mov    %edi,%edx
  801c41:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c45:	8b 44 24 10          	mov    0x10(%esp),%eax
  801c49:	d3 e0                	shl    %cl,%eax
  801c4b:	89 f1                	mov    %esi,%ecx
  801c4d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801c51:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801c55:	d3 ea                	shr    %cl,%edx
  801c57:	89 e9                	mov    %ebp,%ecx
  801c59:	d3 e7                	shl    %cl,%edi
  801c5b:	89 f1                	mov    %esi,%ecx
  801c5d:	d3 e8                	shr    %cl,%eax
  801c5f:	89 e9                	mov    %ebp,%ecx
  801c61:	09 f8                	or     %edi,%eax
  801c63:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801c67:	f7 74 24 0c          	divl   0xc(%esp)
  801c6b:	d3 e7                	shl    %cl,%edi
  801c6d:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801c71:	89 d7                	mov    %edx,%edi
  801c73:	f7 64 24 10          	mull   0x10(%esp)
  801c77:	39 d7                	cmp    %edx,%edi
  801c79:	89 c1                	mov    %eax,%ecx
  801c7b:	89 54 24 14          	mov    %edx,0x14(%esp)
  801c7f:	72 3b                	jb     801cbc <__umoddi3+0x16c>
  801c81:	39 44 24 18          	cmp    %eax,0x18(%esp)
  801c85:	72 31                	jb     801cb8 <__umoddi3+0x168>
  801c87:	8b 44 24 18          	mov    0x18(%esp),%eax
  801c8b:	29 c8                	sub    %ecx,%eax
  801c8d:	19 d7                	sbb    %edx,%edi
  801c8f:	89 e9                	mov    %ebp,%ecx
  801c91:	89 fa                	mov    %edi,%edx
  801c93:	d3 e8                	shr    %cl,%eax
  801c95:	89 f1                	mov    %esi,%ecx
  801c97:	d3 e2                	shl    %cl,%edx
  801c99:	89 e9                	mov    %ebp,%ecx
  801c9b:	09 d0                	or     %edx,%eax
  801c9d:	89 fa                	mov    %edi,%edx
  801c9f:	d3 ea                	shr    %cl,%edx
  801ca1:	8b 74 24 20          	mov    0x20(%esp),%esi
  801ca5:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801ca9:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801cad:	83 c4 2c             	add    $0x2c,%esp
  801cb0:	c3                   	ret    
  801cb1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cb8:	39 d7                	cmp    %edx,%edi
  801cba:	75 cb                	jne    801c87 <__umoddi3+0x137>
  801cbc:	8b 54 24 14          	mov    0x14(%esp),%edx
  801cc0:	89 c1                	mov    %eax,%ecx
  801cc2:	2b 4c 24 10          	sub    0x10(%esp),%ecx
  801cc6:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  801cca:	eb bb                	jmp    801c87 <__umoddi3+0x137>
  801ccc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cd0:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801cd4:	0f 82 e8 fe ff ff    	jb     801bc2 <__umoddi3+0x72>
  801cda:	e9 f3 fe ff ff       	jmp    801bd2 <__umoddi3+0x82>
