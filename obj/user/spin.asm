
obj/user/spin.debug:     file format elf32-i386


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
  80002c:	e8 8f 00 00 00       	call   8000c0 <libmain>
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

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	53                   	push   %ebx
  800044:	83 ec 14             	sub    $0x14,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  800047:	c7 04 24 e0 1f 80 00 	movl   $0x801fe0,(%esp)
  80004e:	e8 7c 01 00 00       	call   8001cf <cprintf>
	if ((env = fork()) == 0) {
  800053:	e8 f8 10 00 00       	call   801150 <fork>
  800058:	89 c3                	mov    %eax,%ebx
  80005a:	85 c0                	test   %eax,%eax
  80005c:	75 0e                	jne    80006c <umain+0x2c>
		cprintf("I am the child.  Spinning...\n");
  80005e:	c7 04 24 58 20 80 00 	movl   $0x802058,(%esp)
  800065:	e8 65 01 00 00       	call   8001cf <cprintf>
  80006a:	eb fe                	jmp    80006a <umain+0x2a>
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  80006c:	c7 04 24 08 20 80 00 	movl   $0x802008,(%esp)
  800073:	e8 57 01 00 00       	call   8001cf <cprintf>
	sys_yield();
  800078:	e8 e3 0c 00 00       	call   800d60 <sys_yield>
	sys_yield();
  80007d:	e8 de 0c 00 00       	call   800d60 <sys_yield>
	sys_yield();
  800082:	e8 d9 0c 00 00       	call   800d60 <sys_yield>
	sys_yield();
  800087:	e8 d4 0c 00 00       	call   800d60 <sys_yield>
	sys_yield();
  80008c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800090:	e8 cb 0c 00 00       	call   800d60 <sys_yield>
	sys_yield();
  800095:	e8 c6 0c 00 00       	call   800d60 <sys_yield>
	sys_yield();
  80009a:	e8 c1 0c 00 00       	call   800d60 <sys_yield>
	sys_yield();
  80009f:	90                   	nop
  8000a0:	e8 bb 0c 00 00       	call   800d60 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  8000a5:	c7 04 24 30 20 80 00 	movl   $0x802030,(%esp)
  8000ac:	e8 1e 01 00 00       	call   8001cf <cprintf>
	sys_env_destroy(env);
  8000b1:	89 1c 24             	mov    %ebx,(%esp)
  8000b4:	e8 08 0c 00 00       	call   800cc1 <sys_env_destroy>
}
  8000b9:	83 c4 14             	add    $0x14,%esp
  8000bc:	5b                   	pop    %ebx
  8000bd:	5d                   	pop    %ebp
  8000be:	c3                   	ret    
  8000bf:	90                   	nop

008000c0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	83 ec 18             	sub    $0x18,%esp
  8000c6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8000c9:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000cc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000cf:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;

	thisenv = &envs[ENVX(sys_getenvid())];
  8000d2:	e8 50 0c 00 00       	call   800d27 <sys_getenvid>
  8000d7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000dc:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000df:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e4:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e9:	85 db                	test   %ebx,%ebx
  8000eb:	7e 07                	jle    8000f4 <libmain+0x34>
		binaryname = argv[0];
  8000ed:	8b 06                	mov    (%esi),%eax
  8000ef:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000f8:	89 1c 24             	mov    %ebx,(%esp)
  8000fb:	e8 40 ff ff ff       	call   800040 <umain>

	// exit gracefully
	exit();
  800100:	e8 0b 00 00 00       	call   800110 <exit>
}
  800105:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800108:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80010b:	89 ec                	mov    %ebp,%esp
  80010d:	5d                   	pop    %ebp
  80010e:	c3                   	ret    
  80010f:	90                   	nop

00800110 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800116:	e8 d8 13 00 00       	call   8014f3 <close_all>
	sys_env_destroy(0);
  80011b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800122:	e8 9a 0b 00 00       	call   800cc1 <sys_env_destroy>
}
  800127:	c9                   	leave  
  800128:	c3                   	ret    
  800129:	66 90                	xchg   %ax,%ax
  80012b:	90                   	nop

0080012c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
  80012f:	53                   	push   %ebx
  800130:	83 ec 14             	sub    $0x14,%esp
  800133:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800136:	8b 03                	mov    (%ebx),%eax
  800138:	8b 55 08             	mov    0x8(%ebp),%edx
  80013b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80013f:	83 c0 01             	add    $0x1,%eax
  800142:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800144:	3d ff 00 00 00       	cmp    $0xff,%eax
  800149:	75 19                	jne    800164 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80014b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800152:	00 
  800153:	8d 43 08             	lea    0x8(%ebx),%eax
  800156:	89 04 24             	mov    %eax,(%esp)
  800159:	e8 f2 0a 00 00       	call   800c50 <sys_cputs>
		b->idx = 0;
  80015e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800164:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800168:	83 c4 14             	add    $0x14,%esp
  80016b:	5b                   	pop    %ebx
  80016c:	5d                   	pop    %ebp
  80016d:	c3                   	ret    

0080016e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80016e:	55                   	push   %ebp
  80016f:	89 e5                	mov    %esp,%ebp
  800171:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800177:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80017e:	00 00 00 
	b.cnt = 0;
  800181:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800188:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80018b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80018e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800192:	8b 45 08             	mov    0x8(%ebp),%eax
  800195:	89 44 24 08          	mov    %eax,0x8(%esp)
  800199:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80019f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a3:	c7 04 24 2c 01 80 00 	movl   $0x80012c,(%esp)
  8001aa:	e8 b3 01 00 00       	call   800362 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001af:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001bf:	89 04 24             	mov    %eax,(%esp)
  8001c2:	e8 89 0a 00 00       	call   800c50 <sys_cputs>

	return b.cnt;
}
  8001c7:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001cd:	c9                   	leave  
  8001ce:	c3                   	ret    

008001cf <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001cf:	55                   	push   %ebp
  8001d0:	89 e5                	mov    %esp,%ebp
  8001d2:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001d5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8001df:	89 04 24             	mov    %eax,(%esp)
  8001e2:	e8 87 ff ff ff       	call   80016e <vcprintf>
	va_end(ap);

	return cnt;
}
  8001e7:	c9                   	leave  
  8001e8:	c3                   	ret    
  8001e9:	66 90                	xchg   %ax,%ax
  8001eb:	66 90                	xchg   %ax,%ax
  8001ed:	66 90                	xchg   %ax,%ax
  8001ef:	90                   	nop

008001f0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001f0:	55                   	push   %ebp
  8001f1:	89 e5                	mov    %esp,%ebp
  8001f3:	57                   	push   %edi
  8001f4:	56                   	push   %esi
  8001f5:	53                   	push   %ebx
  8001f6:	83 ec 4c             	sub    $0x4c,%esp
  8001f9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8001fc:	89 d7                	mov    %edx,%edi
  8001fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800201:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800204:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800207:	89 5d dc             	mov    %ebx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80020a:	b8 00 00 00 00       	mov    $0x0,%eax
  80020f:	39 d8                	cmp    %ebx,%eax
  800211:	72 17                	jb     80022a <printnum+0x3a>
  800213:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800216:	39 5d 10             	cmp    %ebx,0x10(%ebp)
  800219:	76 0f                	jbe    80022a <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80021b:	8b 75 14             	mov    0x14(%ebp),%esi
  80021e:	83 ee 01             	sub    $0x1,%esi
  800221:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800224:	85 f6                	test   %esi,%esi
  800226:	7f 63                	jg     80028b <printnum+0x9b>
  800228:	eb 75                	jmp    80029f <printnum+0xaf>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80022a:	8b 5d 18             	mov    0x18(%ebp),%ebx
  80022d:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800231:	8b 45 14             	mov    0x14(%ebp),%eax
  800234:	83 e8 01             	sub    $0x1,%eax
  800237:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80023b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80023e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800242:	8b 44 24 08          	mov    0x8(%esp),%eax
  800246:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80024a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80024d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800250:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800257:	00 
  800258:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  80025b:	89 1c 24             	mov    %ebx,(%esp)
  80025e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800261:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800265:	e8 86 1a 00 00       	call   801cf0 <__udivdi3>
  80026a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80026d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800270:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800274:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800278:	89 04 24             	mov    %eax,(%esp)
  80027b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80027f:	89 fa                	mov    %edi,%edx
  800281:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800284:	e8 67 ff ff ff       	call   8001f0 <printnum>
  800289:	eb 14                	jmp    80029f <printnum+0xaf>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80028b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80028f:	8b 45 18             	mov    0x18(%ebp),%eax
  800292:	89 04 24             	mov    %eax,(%esp)
  800295:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800297:	83 ee 01             	sub    $0x1,%esi
  80029a:	75 ef                	jne    80028b <printnum+0x9b>
  80029c:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80029f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002a3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002a7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002aa:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002ae:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002b5:	00 
  8002b6:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8002b9:	89 1c 24             	mov    %ebx,(%esp)
  8002bc:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002bf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002c3:	e8 78 1b 00 00       	call   801e40 <__umoddi3>
  8002c8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002cc:	0f be 80 80 20 80 00 	movsbl 0x802080(%eax),%eax
  8002d3:	89 04 24             	mov    %eax,(%esp)
  8002d6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002d9:	ff d0                	call   *%eax
}
  8002db:	83 c4 4c             	add    $0x4c,%esp
  8002de:	5b                   	pop    %ebx
  8002df:	5e                   	pop    %esi
  8002e0:	5f                   	pop    %edi
  8002e1:	5d                   	pop    %ebp
  8002e2:	c3                   	ret    

008002e3 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002e3:	55                   	push   %ebp
  8002e4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002e6:	83 fa 01             	cmp    $0x1,%edx
  8002e9:	7e 0e                	jle    8002f9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002eb:	8b 10                	mov    (%eax),%edx
  8002ed:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002f0:	89 08                	mov    %ecx,(%eax)
  8002f2:	8b 02                	mov    (%edx),%eax
  8002f4:	8b 52 04             	mov    0x4(%edx),%edx
  8002f7:	eb 22                	jmp    80031b <getuint+0x38>
	else if (lflag)
  8002f9:	85 d2                	test   %edx,%edx
  8002fb:	74 10                	je     80030d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002fd:	8b 10                	mov    (%eax),%edx
  8002ff:	8d 4a 04             	lea    0x4(%edx),%ecx
  800302:	89 08                	mov    %ecx,(%eax)
  800304:	8b 02                	mov    (%edx),%eax
  800306:	ba 00 00 00 00       	mov    $0x0,%edx
  80030b:	eb 0e                	jmp    80031b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80030d:	8b 10                	mov    (%eax),%edx
  80030f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800312:	89 08                	mov    %ecx,(%eax)
  800314:	8b 02                	mov    (%edx),%eax
  800316:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80031b:	5d                   	pop    %ebp
  80031c:	c3                   	ret    

0080031d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80031d:	55                   	push   %ebp
  80031e:	89 e5                	mov    %esp,%ebp
  800320:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800323:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800327:	8b 10                	mov    (%eax),%edx
  800329:	3b 50 04             	cmp    0x4(%eax),%edx
  80032c:	73 0a                	jae    800338 <sprintputch+0x1b>
		*b->buf++ = ch;
  80032e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800331:	88 0a                	mov    %cl,(%edx)
  800333:	83 c2 01             	add    $0x1,%edx
  800336:	89 10                	mov    %edx,(%eax)
}
  800338:	5d                   	pop    %ebp
  800339:	c3                   	ret    

0080033a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80033a:	55                   	push   %ebp
  80033b:	89 e5                	mov    %esp,%ebp
  80033d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800340:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800343:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800347:	8b 45 10             	mov    0x10(%ebp),%eax
  80034a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80034e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800351:	89 44 24 04          	mov    %eax,0x4(%esp)
  800355:	8b 45 08             	mov    0x8(%ebp),%eax
  800358:	89 04 24             	mov    %eax,(%esp)
  80035b:	e8 02 00 00 00       	call   800362 <vprintfmt>
	va_end(ap);
}
  800360:	c9                   	leave  
  800361:	c3                   	ret    

00800362 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800362:	55                   	push   %ebp
  800363:	89 e5                	mov    %esp,%ebp
  800365:	57                   	push   %edi
  800366:	56                   	push   %esi
  800367:	53                   	push   %ebx
  800368:	83 ec 4c             	sub    $0x4c,%esp
  80036b:	8b 75 08             	mov    0x8(%ebp),%esi
  80036e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800371:	8b 7d 10             	mov    0x10(%ebp),%edi
  800374:	eb 11                	jmp    800387 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800376:	85 c0                	test   %eax,%eax
  800378:	0f 84 db 03 00 00    	je     800759 <vprintfmt+0x3f7>
				return;
			putch(ch, putdat);
  80037e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800382:	89 04 24             	mov    %eax,(%esp)
  800385:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800387:	0f b6 07             	movzbl (%edi),%eax
  80038a:	83 c7 01             	add    $0x1,%edi
  80038d:	83 f8 25             	cmp    $0x25,%eax
  800390:	75 e4                	jne    800376 <vprintfmt+0x14>
  800392:	c6 45 e4 20          	movb   $0x20,-0x1c(%ebp)
  800396:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80039d:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8003a4:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b0:	eb 2b                	jmp    8003dd <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b2:	8b 7d e0             	mov    -0x20(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003b5:	c6 45 e4 2d          	movb   $0x2d,-0x1c(%ebp)
  8003b9:	eb 22                	jmp    8003dd <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bb:	8b 7d e0             	mov    -0x20(%ebp),%edi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003be:	c6 45 e4 30          	movb   $0x30,-0x1c(%ebp)
  8003c2:	eb 19                	jmp    8003dd <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c4:	8b 7d e0             	mov    -0x20(%ebp),%edi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003c7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003ce:	eb 0d                	jmp    8003dd <vprintfmt+0x7b>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003d0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003d6:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003dd:	0f b6 0f             	movzbl (%edi),%ecx
  8003e0:	8d 47 01             	lea    0x1(%edi),%eax
  8003e3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003e6:	0f b6 07             	movzbl (%edi),%eax
  8003e9:	83 e8 23             	sub    $0x23,%eax
  8003ec:	3c 55                	cmp    $0x55,%al
  8003ee:	0f 87 40 03 00 00    	ja     800734 <vprintfmt+0x3d2>
  8003f4:	0f b6 c0             	movzbl %al,%eax
  8003f7:	ff 24 85 c0 21 80 00 	jmp    *0x8021c0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003fe:	83 e9 30             	sub    $0x30,%ecx
  800401:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				ch = *fmt;
  800404:	0f be 47 01          	movsbl 0x1(%edi),%eax
				if (ch < '0' || ch > '9')
  800408:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80040b:	83 f9 09             	cmp    $0x9,%ecx
  80040e:	77 57                	ja     800467 <vprintfmt+0x105>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800410:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800413:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800416:	8b 55 dc             	mov    -0x24(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800419:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80041c:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80041f:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800423:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  800426:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800429:	83 f9 09             	cmp    $0x9,%ecx
  80042c:	76 eb                	jbe    800419 <vprintfmt+0xb7>
  80042e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800431:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800434:	eb 34                	jmp    80046a <vprintfmt+0x108>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800436:	8b 45 14             	mov    0x14(%ebp),%eax
  800439:	8d 48 04             	lea    0x4(%eax),%ecx
  80043c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80043f:	8b 00                	mov    (%eax),%eax
  800441:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800444:	8b 7d e0             	mov    -0x20(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800447:	eb 21                	jmp    80046a <vprintfmt+0x108>

		case '.':
			if (width < 0)
  800449:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80044d:	0f 88 71 ff ff ff    	js     8003c4 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800453:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800456:	eb 85                	jmp    8003dd <vprintfmt+0x7b>
  800458:	8b 7d e0             	mov    -0x20(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80045b:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  800462:	e9 76 ff ff ff       	jmp    8003dd <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800467:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80046a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80046e:	0f 89 69 ff ff ff    	jns    8003dd <vprintfmt+0x7b>
  800474:	e9 57 ff ff ff       	jmp    8003d0 <vprintfmt+0x6e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800479:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80047f:	e9 59 ff ff ff       	jmp    8003dd <vprintfmt+0x7b>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800484:	8b 45 14             	mov    0x14(%ebp),%eax
  800487:	8d 50 04             	lea    0x4(%eax),%edx
  80048a:	89 55 14             	mov    %edx,0x14(%ebp)
  80048d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800491:	8b 00                	mov    (%eax),%eax
  800493:	89 04 24             	mov    %eax,(%esp)
  800496:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800498:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80049b:	e9 e7 fe ff ff       	jmp    800387 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a3:	8d 50 04             	lea    0x4(%eax),%edx
  8004a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a9:	8b 00                	mov    (%eax),%eax
  8004ab:	89 c2                	mov    %eax,%edx
  8004ad:	c1 fa 1f             	sar    $0x1f,%edx
  8004b0:	31 d0                	xor    %edx,%eax
  8004b2:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004b4:	83 f8 0f             	cmp    $0xf,%eax
  8004b7:	7f 0b                	jg     8004c4 <vprintfmt+0x162>
  8004b9:	8b 14 85 20 23 80 00 	mov    0x802320(,%eax,4),%edx
  8004c0:	85 d2                	test   %edx,%edx
  8004c2:	75 20                	jne    8004e4 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  8004c4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004c8:	c7 44 24 08 98 20 80 	movl   $0x802098,0x8(%esp)
  8004cf:	00 
  8004d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004d4:	89 34 24             	mov    %esi,(%esp)
  8004d7:	e8 5e fe ff ff       	call   80033a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004dc:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004df:	e9 a3 fe ff ff       	jmp    800387 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  8004e4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004e8:	c7 44 24 08 a1 20 80 	movl   $0x8020a1,0x8(%esp)
  8004ef:	00 
  8004f0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004f4:	89 34 24             	mov    %esi,(%esp)
  8004f7:	e8 3e fe ff ff       	call   80033a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fc:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8004ff:	e9 83 fe ff ff       	jmp    800387 <vprintfmt+0x25>
  800504:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800507:	8b 7d d8             	mov    -0x28(%ebp),%edi
  80050a:	89 7d cc             	mov    %edi,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80050d:	8b 45 14             	mov    0x14(%ebp),%eax
  800510:	8d 50 04             	lea    0x4(%eax),%edx
  800513:	89 55 14             	mov    %edx,0x14(%ebp)
  800516:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800518:	85 ff                	test   %edi,%edi
  80051a:	b8 91 20 80 00       	mov    $0x802091,%eax
  80051f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800522:	80 7d e4 2d          	cmpb   $0x2d,-0x1c(%ebp)
  800526:	74 06                	je     80052e <vprintfmt+0x1cc>
  800528:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80052c:	7f 16                	jg     800544 <vprintfmt+0x1e2>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80052e:	0f b6 17             	movzbl (%edi),%edx
  800531:	0f be c2             	movsbl %dl,%eax
  800534:	83 c7 01             	add    $0x1,%edi
  800537:	85 c0                	test   %eax,%eax
  800539:	0f 85 9f 00 00 00    	jne    8005de <vprintfmt+0x27c>
  80053f:	e9 8b 00 00 00       	jmp    8005cf <vprintfmt+0x26d>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800544:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800548:	89 3c 24             	mov    %edi,(%esp)
  80054b:	e8 c2 02 00 00       	call   800812 <strnlen>
  800550:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800553:	29 c2                	sub    %eax,%edx
  800555:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800558:	85 d2                	test   %edx,%edx
  80055a:	7e d2                	jle    80052e <vprintfmt+0x1cc>
					putch(padc, putdat);
  80055c:	0f be 4d e4          	movsbl -0x1c(%ebp),%ecx
  800560:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800563:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800566:	89 d7                	mov    %edx,%edi
  800568:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80056c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80056f:	89 04 24             	mov    %eax,(%esp)
  800572:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800574:	83 ef 01             	sub    $0x1,%edi
  800577:	75 ef                	jne    800568 <vprintfmt+0x206>
  800579:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80057c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80057f:	eb ad                	jmp    80052e <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800581:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800585:	74 20                	je     8005a7 <vprintfmt+0x245>
  800587:	0f be d2             	movsbl %dl,%edx
  80058a:	83 ea 20             	sub    $0x20,%edx
  80058d:	83 fa 5e             	cmp    $0x5e,%edx
  800590:	76 15                	jbe    8005a7 <vprintfmt+0x245>
					putch('?', putdat);
  800592:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800595:	89 54 24 04          	mov    %edx,0x4(%esp)
  800599:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005a0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005a3:	ff d1                	call   *%ecx
  8005a5:	eb 0f                	jmp    8005b6 <vprintfmt+0x254>
				else
					putch(ch, putdat);
  8005a7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005aa:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005ae:	89 04 24             	mov    %eax,(%esp)
  8005b1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005b4:	ff d1                	call   *%ecx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b6:	83 eb 01             	sub    $0x1,%ebx
  8005b9:	0f b6 17             	movzbl (%edi),%edx
  8005bc:	0f be c2             	movsbl %dl,%eax
  8005bf:	83 c7 01             	add    $0x1,%edi
  8005c2:	85 c0                	test   %eax,%eax
  8005c4:	75 24                	jne    8005ea <vprintfmt+0x288>
  8005c6:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8005c9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8005cc:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005cf:	8b 7d e0             	mov    -0x20(%ebp),%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005d2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005d6:	0f 8e ab fd ff ff    	jle    800387 <vprintfmt+0x25>
  8005dc:	eb 20                	jmp    8005fe <vprintfmt+0x29c>
  8005de:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  8005e1:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8005e4:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8005e7:	8b 5d d8             	mov    -0x28(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ea:	85 f6                	test   %esi,%esi
  8005ec:	78 93                	js     800581 <vprintfmt+0x21f>
  8005ee:	83 ee 01             	sub    $0x1,%esi
  8005f1:	79 8e                	jns    800581 <vprintfmt+0x21f>
  8005f3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8005f6:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8005f9:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8005fc:	eb d1                	jmp    8005cf <vprintfmt+0x26d>
  8005fe:	8b 7d d8             	mov    -0x28(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800601:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800605:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80060c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80060e:	83 ef 01             	sub    $0x1,%edi
  800611:	75 ee                	jne    800601 <vprintfmt+0x29f>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800613:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800616:	e9 6c fd ff ff       	jmp    800387 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80061b:	83 fa 01             	cmp    $0x1,%edx
  80061e:	66 90                	xchg   %ax,%ax
  800620:	7e 16                	jle    800638 <vprintfmt+0x2d6>
		return va_arg(*ap, long long);
  800622:	8b 45 14             	mov    0x14(%ebp),%eax
  800625:	8d 50 08             	lea    0x8(%eax),%edx
  800628:	89 55 14             	mov    %edx,0x14(%ebp)
  80062b:	8b 10                	mov    (%eax),%edx
  80062d:	8b 48 04             	mov    0x4(%eax),%ecx
  800630:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800633:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800636:	eb 32                	jmp    80066a <vprintfmt+0x308>
	else if (lflag)
  800638:	85 d2                	test   %edx,%edx
  80063a:	74 18                	je     800654 <vprintfmt+0x2f2>
		return va_arg(*ap, long);
  80063c:	8b 45 14             	mov    0x14(%ebp),%eax
  80063f:	8d 50 04             	lea    0x4(%eax),%edx
  800642:	89 55 14             	mov    %edx,0x14(%ebp)
  800645:	8b 00                	mov    (%eax),%eax
  800647:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80064a:	89 c1                	mov    %eax,%ecx
  80064c:	c1 f9 1f             	sar    $0x1f,%ecx
  80064f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800652:	eb 16                	jmp    80066a <vprintfmt+0x308>
	else
		return va_arg(*ap, int);
  800654:	8b 45 14             	mov    0x14(%ebp),%eax
  800657:	8d 50 04             	lea    0x4(%eax),%edx
  80065a:	89 55 14             	mov    %edx,0x14(%ebp)
  80065d:	8b 00                	mov    (%eax),%eax
  80065f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800662:	89 c7                	mov    %eax,%edi
  800664:	c1 ff 1f             	sar    $0x1f,%edi
  800667:	89 7d d4             	mov    %edi,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80066a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80066d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800670:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800675:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800679:	79 7d                	jns    8006f8 <vprintfmt+0x396>
				putch('-', putdat);
  80067b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80067f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800686:	ff d6                	call   *%esi
				num = -(long long) num;
  800688:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80068b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80068e:	f7 d8                	neg    %eax
  800690:	83 d2 00             	adc    $0x0,%edx
  800693:	f7 da                	neg    %edx
			}
			base = 10;
  800695:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80069a:	eb 5c                	jmp    8006f8 <vprintfmt+0x396>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80069c:	8d 45 14             	lea    0x14(%ebp),%eax
  80069f:	e8 3f fc ff ff       	call   8002e3 <getuint>
			base = 10;
  8006a4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006a9:	eb 4d                	jmp    8006f8 <vprintfmt+0x396>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006ab:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ae:	e8 30 fc ff ff       	call   8002e3 <getuint>
			base = 8;
  8006b3:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8006b8:	eb 3e                	jmp    8006f8 <vprintfmt+0x396>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8006ba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006be:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006c5:	ff d6                	call   *%esi
			putch('x', putdat);
  8006c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006cb:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006d2:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d7:	8d 50 04             	lea    0x4(%eax),%edx
  8006da:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006dd:	8b 00                	mov    (%eax),%eax
  8006df:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006e4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006e9:	eb 0d                	jmp    8006f8 <vprintfmt+0x396>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006eb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ee:	e8 f0 fb ff ff       	call   8002e3 <getuint>
			base = 16;
  8006f3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006f8:	0f be 7d e4          	movsbl -0x1c(%ebp),%edi
  8006fc:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800700:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800703:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800707:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80070b:	89 04 24             	mov    %eax,(%esp)
  80070e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800712:	89 da                	mov    %ebx,%edx
  800714:	89 f0                	mov    %esi,%eax
  800716:	e8 d5 fa ff ff       	call   8001f0 <printnum>
			break;
  80071b:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80071e:	e9 64 fc ff ff       	jmp    800387 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800723:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800727:	89 0c 24             	mov    %ecx,(%esp)
  80072a:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80072c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80072f:	e9 53 fc ff ff       	jmp    800387 <vprintfmt+0x25>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800734:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800738:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80073f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800741:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800745:	0f 84 3c fc ff ff    	je     800387 <vprintfmt+0x25>
  80074b:	83 ef 01             	sub    $0x1,%edi
  80074e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800752:	75 f7                	jne    80074b <vprintfmt+0x3e9>
  800754:	e9 2e fc ff ff       	jmp    800387 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800759:	83 c4 4c             	add    $0x4c,%esp
  80075c:	5b                   	pop    %ebx
  80075d:	5e                   	pop    %esi
  80075e:	5f                   	pop    %edi
  80075f:	5d                   	pop    %ebp
  800760:	c3                   	ret    

00800761 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800761:	55                   	push   %ebp
  800762:	89 e5                	mov    %esp,%ebp
  800764:	83 ec 28             	sub    $0x28,%esp
  800767:	8b 45 08             	mov    0x8(%ebp),%eax
  80076a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80076d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800770:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800774:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800777:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80077e:	85 d2                	test   %edx,%edx
  800780:	7e 30                	jle    8007b2 <vsnprintf+0x51>
  800782:	85 c0                	test   %eax,%eax
  800784:	74 2c                	je     8007b2 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800786:	8b 45 14             	mov    0x14(%ebp),%eax
  800789:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80078d:	8b 45 10             	mov    0x10(%ebp),%eax
  800790:	89 44 24 08          	mov    %eax,0x8(%esp)
  800794:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800797:	89 44 24 04          	mov    %eax,0x4(%esp)
  80079b:	c7 04 24 1d 03 80 00 	movl   $0x80031d,(%esp)
  8007a2:	e8 bb fb ff ff       	call   800362 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007aa:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007b0:	eb 05                	jmp    8007b7 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007b2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007b7:	c9                   	leave  
  8007b8:	c3                   	ret    

008007b9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007b9:	55                   	push   %ebp
  8007ba:	89 e5                	mov    %esp,%ebp
  8007bc:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007bf:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007c6:	8b 45 10             	mov    0x10(%ebp),%eax
  8007c9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d7:	89 04 24             	mov    %eax,(%esp)
  8007da:	e8 82 ff ff ff       	call   800761 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007df:	c9                   	leave  
  8007e0:	c3                   	ret    
  8007e1:	66 90                	xchg   %ax,%ax
  8007e3:	66 90                	xchg   %ax,%ax
  8007e5:	66 90                	xchg   %ax,%ax
  8007e7:	66 90                	xchg   %ax,%ax
  8007e9:	66 90                	xchg   %ax,%ax
  8007eb:	66 90                	xchg   %ax,%ax
  8007ed:	66 90                	xchg   %ax,%ax
  8007ef:	90                   	nop

008007f0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f6:	80 3a 00             	cmpb   $0x0,(%edx)
  8007f9:	74 10                	je     80080b <strlen+0x1b>
  8007fb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800800:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800803:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800807:	75 f7                	jne    800800 <strlen+0x10>
  800809:	eb 05                	jmp    800810 <strlen+0x20>
  80080b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800810:	5d                   	pop    %ebp
  800811:	c3                   	ret    

00800812 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	53                   	push   %ebx
  800816:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800819:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80081c:	85 c9                	test   %ecx,%ecx
  80081e:	74 1c                	je     80083c <strnlen+0x2a>
  800820:	80 3b 00             	cmpb   $0x0,(%ebx)
  800823:	74 1e                	je     800843 <strnlen+0x31>
  800825:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  80082a:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80082c:	39 ca                	cmp    %ecx,%edx
  80082e:	74 18                	je     800848 <strnlen+0x36>
  800830:	83 c2 01             	add    $0x1,%edx
  800833:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800838:	75 f0                	jne    80082a <strnlen+0x18>
  80083a:	eb 0c                	jmp    800848 <strnlen+0x36>
  80083c:	b8 00 00 00 00       	mov    $0x0,%eax
  800841:	eb 05                	jmp    800848 <strnlen+0x36>
  800843:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800848:	5b                   	pop    %ebx
  800849:	5d                   	pop    %ebp
  80084a:	c3                   	ret    

0080084b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	53                   	push   %ebx
  80084f:	8b 45 08             	mov    0x8(%ebp),%eax
  800852:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800855:	89 c2                	mov    %eax,%edx
  800857:	0f b6 19             	movzbl (%ecx),%ebx
  80085a:	88 1a                	mov    %bl,(%edx)
  80085c:	83 c2 01             	add    $0x1,%edx
  80085f:	83 c1 01             	add    $0x1,%ecx
  800862:	84 db                	test   %bl,%bl
  800864:	75 f1                	jne    800857 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800866:	5b                   	pop    %ebx
  800867:	5d                   	pop    %ebp
  800868:	c3                   	ret    

00800869 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800869:	55                   	push   %ebp
  80086a:	89 e5                	mov    %esp,%ebp
  80086c:	53                   	push   %ebx
  80086d:	83 ec 08             	sub    $0x8,%esp
  800870:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800873:	89 1c 24             	mov    %ebx,(%esp)
  800876:	e8 75 ff ff ff       	call   8007f0 <strlen>
	strcpy(dst + len, src);
  80087b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80087e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800882:	01 d8                	add    %ebx,%eax
  800884:	89 04 24             	mov    %eax,(%esp)
  800887:	e8 bf ff ff ff       	call   80084b <strcpy>
	return dst;
}
  80088c:	89 d8                	mov    %ebx,%eax
  80088e:	83 c4 08             	add    $0x8,%esp
  800891:	5b                   	pop    %ebx
  800892:	5d                   	pop    %ebp
  800893:	c3                   	ret    

00800894 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	56                   	push   %esi
  800898:	53                   	push   %ebx
  800899:	8b 75 08             	mov    0x8(%ebp),%esi
  80089c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008a2:	85 db                	test   %ebx,%ebx
  8008a4:	74 16                	je     8008bc <strncpy+0x28>
	strcpy(dst + len, src);
	return dst;
}

char *
strncpy(char *dst, const char *src, size_t size) {
  8008a6:	01 f3                	add    %esi,%ebx
  8008a8:	89 f1                	mov    %esi,%ecx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  8008aa:	0f b6 02             	movzbl (%edx),%eax
  8008ad:	88 01                	mov    %al,(%ecx)
  8008af:	83 c1 01             	add    $0x1,%ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008b2:	80 3a 01             	cmpb   $0x1,(%edx)
  8008b5:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008b8:	39 d9                	cmp    %ebx,%ecx
  8008ba:	75 ee                	jne    8008aa <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008bc:	89 f0                	mov    %esi,%eax
  8008be:	5b                   	pop    %ebx
  8008bf:	5e                   	pop    %esi
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	57                   	push   %edi
  8008c6:	56                   	push   %esi
  8008c7:	53                   	push   %ebx
  8008c8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008ce:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008d1:	89 f8                	mov    %edi,%eax
  8008d3:	85 f6                	test   %esi,%esi
  8008d5:	74 33                	je     80090a <strlcpy+0x48>
		while (--size > 0 && *src != '\0')
  8008d7:	83 fe 01             	cmp    $0x1,%esi
  8008da:	74 25                	je     800901 <strlcpy+0x3f>
  8008dc:	0f b6 0b             	movzbl (%ebx),%ecx
  8008df:	84 c9                	test   %cl,%cl
  8008e1:	74 22                	je     800905 <strlcpy+0x43>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8008e3:	83 ee 02             	sub    $0x2,%esi
  8008e6:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008eb:	88 08                	mov    %cl,(%eax)
  8008ed:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008f0:	39 f2                	cmp    %esi,%edx
  8008f2:	74 13                	je     800907 <strlcpy+0x45>
  8008f4:	83 c2 01             	add    $0x1,%edx
  8008f7:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8008fb:	84 c9                	test   %cl,%cl
  8008fd:	75 ec                	jne    8008eb <strlcpy+0x29>
  8008ff:	eb 06                	jmp    800907 <strlcpy+0x45>
  800901:	89 f8                	mov    %edi,%eax
  800903:	eb 02                	jmp    800907 <strlcpy+0x45>
  800905:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800907:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80090a:	29 f8                	sub    %edi,%eax
}
  80090c:	5b                   	pop    %ebx
  80090d:	5e                   	pop    %esi
  80090e:	5f                   	pop    %edi
  80090f:	5d                   	pop    %ebp
  800910:	c3                   	ret    

00800911 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800911:	55                   	push   %ebp
  800912:	89 e5                	mov    %esp,%ebp
  800914:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800917:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80091a:	0f b6 01             	movzbl (%ecx),%eax
  80091d:	84 c0                	test   %al,%al
  80091f:	74 15                	je     800936 <strcmp+0x25>
  800921:	3a 02                	cmp    (%edx),%al
  800923:	75 11                	jne    800936 <strcmp+0x25>
		p++, q++;
  800925:	83 c1 01             	add    $0x1,%ecx
  800928:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80092b:	0f b6 01             	movzbl (%ecx),%eax
  80092e:	84 c0                	test   %al,%al
  800930:	74 04                	je     800936 <strcmp+0x25>
  800932:	3a 02                	cmp    (%edx),%al
  800934:	74 ef                	je     800925 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800936:	0f b6 c0             	movzbl %al,%eax
  800939:	0f b6 12             	movzbl (%edx),%edx
  80093c:	29 d0                	sub    %edx,%eax
}
  80093e:	5d                   	pop    %ebp
  80093f:	c3                   	ret    

00800940 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	56                   	push   %esi
  800944:	53                   	push   %ebx
  800945:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800948:	8b 55 0c             	mov    0xc(%ebp),%edx
  80094b:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  80094e:	85 f6                	test   %esi,%esi
  800950:	74 29                	je     80097b <strncmp+0x3b>
  800952:	0f b6 03             	movzbl (%ebx),%eax
  800955:	84 c0                	test   %al,%al
  800957:	74 30                	je     800989 <strncmp+0x49>
  800959:	3a 02                	cmp    (%edx),%al
  80095b:	75 2c                	jne    800989 <strncmp+0x49>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}

int
strncmp(const char *p, const char *q, size_t n)
  80095d:	8d 43 01             	lea    0x1(%ebx),%eax
  800960:	01 de                	add    %ebx,%esi
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800962:	89 c3                	mov    %eax,%ebx
  800964:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800967:	39 f0                	cmp    %esi,%eax
  800969:	74 17                	je     800982 <strncmp+0x42>
  80096b:	0f b6 08             	movzbl (%eax),%ecx
  80096e:	84 c9                	test   %cl,%cl
  800970:	74 17                	je     800989 <strncmp+0x49>
  800972:	83 c0 01             	add    $0x1,%eax
  800975:	3a 0a                	cmp    (%edx),%cl
  800977:	74 e9                	je     800962 <strncmp+0x22>
  800979:	eb 0e                	jmp    800989 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  80097b:	b8 00 00 00 00       	mov    $0x0,%eax
  800980:	eb 0f                	jmp    800991 <strncmp+0x51>
  800982:	b8 00 00 00 00       	mov    $0x0,%eax
  800987:	eb 08                	jmp    800991 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800989:	0f b6 03             	movzbl (%ebx),%eax
  80098c:	0f b6 12             	movzbl (%edx),%edx
  80098f:	29 d0                	sub    %edx,%eax
}
  800991:	5b                   	pop    %ebx
  800992:	5e                   	pop    %esi
  800993:	5d                   	pop    %ebp
  800994:	c3                   	ret    

00800995 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800995:	55                   	push   %ebp
  800996:	89 e5                	mov    %esp,%ebp
  800998:	53                   	push   %ebx
  800999:	8b 45 08             	mov    0x8(%ebp),%eax
  80099c:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  80099f:	0f b6 18             	movzbl (%eax),%ebx
  8009a2:	84 db                	test   %bl,%bl
  8009a4:	74 1d                	je     8009c3 <strchr+0x2e>
  8009a6:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  8009a8:	38 d3                	cmp    %dl,%bl
  8009aa:	75 06                	jne    8009b2 <strchr+0x1d>
  8009ac:	eb 1a                	jmp    8009c8 <strchr+0x33>
  8009ae:	38 ca                	cmp    %cl,%dl
  8009b0:	74 16                	je     8009c8 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009b2:	83 c0 01             	add    $0x1,%eax
  8009b5:	0f b6 10             	movzbl (%eax),%edx
  8009b8:	84 d2                	test   %dl,%dl
  8009ba:	75 f2                	jne    8009ae <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  8009bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c1:	eb 05                	jmp    8009c8 <strchr+0x33>
  8009c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c8:	5b                   	pop    %ebx
  8009c9:	5d                   	pop    %ebp
  8009ca:	c3                   	ret    

008009cb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	53                   	push   %ebx
  8009cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d2:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  8009d5:	0f b6 18             	movzbl (%eax),%ebx
  8009d8:	84 db                	test   %bl,%bl
  8009da:	74 16                	je     8009f2 <strfind+0x27>
  8009dc:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  8009de:	38 d3                	cmp    %dl,%bl
  8009e0:	75 06                	jne    8009e8 <strfind+0x1d>
  8009e2:	eb 0e                	jmp    8009f2 <strfind+0x27>
  8009e4:	38 ca                	cmp    %cl,%dl
  8009e6:	74 0a                	je     8009f2 <strfind+0x27>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009e8:	83 c0 01             	add    $0x1,%eax
  8009eb:	0f b6 10             	movzbl (%eax),%edx
  8009ee:	84 d2                	test   %dl,%dl
  8009f0:	75 f2                	jne    8009e4 <strfind+0x19>
		if (*s == c)
			break;
	return (char *) s;
}
  8009f2:	5b                   	pop    %ebx
  8009f3:	5d                   	pop    %ebp
  8009f4:	c3                   	ret    

008009f5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009f5:	55                   	push   %ebp
  8009f6:	89 e5                	mov    %esp,%ebp
  8009f8:	83 ec 0c             	sub    $0xc,%esp
  8009fb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8009fe:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800a01:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800a04:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a07:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a0a:	85 c9                	test   %ecx,%ecx
  800a0c:	74 36                	je     800a44 <memset+0x4f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a0e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a14:	75 28                	jne    800a3e <memset+0x49>
  800a16:	f6 c1 03             	test   $0x3,%cl
  800a19:	75 23                	jne    800a3e <memset+0x49>
		c &= 0xFF;
  800a1b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a1f:	89 d3                	mov    %edx,%ebx
  800a21:	c1 e3 08             	shl    $0x8,%ebx
  800a24:	89 d6                	mov    %edx,%esi
  800a26:	c1 e6 18             	shl    $0x18,%esi
  800a29:	89 d0                	mov    %edx,%eax
  800a2b:	c1 e0 10             	shl    $0x10,%eax
  800a2e:	09 f0                	or     %esi,%eax
  800a30:	09 c2                	or     %eax,%edx
  800a32:	89 d0                	mov    %edx,%eax
  800a34:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a36:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a39:	fc                   	cld    
  800a3a:	f3 ab                	rep stos %eax,%es:(%edi)
  800a3c:	eb 06                	jmp    800a44 <memset+0x4f>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a3e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a41:	fc                   	cld    
  800a42:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");

	return v;
}
  800a44:	89 f8                	mov    %edi,%eax
  800a46:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800a49:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800a4c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800a4f:	89 ec                	mov    %ebp,%esp
  800a51:	5d                   	pop    %ebp
  800a52:	c3                   	ret    

00800a53 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a53:	55                   	push   %ebp
  800a54:	89 e5                	mov    %esp,%ebp
  800a56:	83 ec 08             	sub    $0x8,%esp
  800a59:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800a5c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800a5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a62:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a65:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a68:	39 c6                	cmp    %eax,%esi
  800a6a:	73 36                	jae    800aa2 <memmove+0x4f>
  800a6c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a6f:	39 d0                	cmp    %edx,%eax
  800a71:	73 2f                	jae    800aa2 <memmove+0x4f>
		s += n;
		d += n;
  800a73:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a76:	f6 c2 03             	test   $0x3,%dl
  800a79:	75 1b                	jne    800a96 <memmove+0x43>
  800a7b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a81:	75 13                	jne    800a96 <memmove+0x43>
  800a83:	f6 c1 03             	test   $0x3,%cl
  800a86:	75 0e                	jne    800a96 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a88:	83 ef 04             	sub    $0x4,%edi
  800a8b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a8e:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a91:	fd                   	std    
  800a92:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a94:	eb 09                	jmp    800a9f <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a96:	83 ef 01             	sub    $0x1,%edi
  800a99:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a9c:	fd                   	std    
  800a9d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a9f:	fc                   	cld    
  800aa0:	eb 20                	jmp    800ac2 <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aa8:	75 13                	jne    800abd <memmove+0x6a>
  800aaa:	a8 03                	test   $0x3,%al
  800aac:	75 0f                	jne    800abd <memmove+0x6a>
  800aae:	f6 c1 03             	test   $0x3,%cl
  800ab1:	75 0a                	jne    800abd <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ab3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800ab6:	89 c7                	mov    %eax,%edi
  800ab8:	fc                   	cld    
  800ab9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800abb:	eb 05                	jmp    800ac2 <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800abd:	89 c7                	mov    %eax,%edi
  800abf:	fc                   	cld    
  800ac0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ac2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ac5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ac8:	89 ec                	mov    %ebp,%esp
  800aca:	5d                   	pop    %ebp
  800acb:	c3                   	ret    

00800acc <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800acc:	55                   	push   %ebp
  800acd:	89 e5                	mov    %esp,%ebp
  800acf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ad2:	8b 45 10             	mov    0x10(%ebp),%eax
  800ad5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ad9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800adc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ae0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae3:	89 04 24             	mov    %eax,(%esp)
  800ae6:	e8 68 ff ff ff       	call   800a53 <memmove>
}
  800aeb:	c9                   	leave  
  800aec:	c3                   	ret    

00800aed <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aed:	55                   	push   %ebp
  800aee:	89 e5                	mov    %esp,%ebp
  800af0:	57                   	push   %edi
  800af1:	56                   	push   %esi
  800af2:	53                   	push   %ebx
  800af3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800af6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800af9:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800afc:	8d 78 ff             	lea    -0x1(%eax),%edi
  800aff:	85 c0                	test   %eax,%eax
  800b01:	74 36                	je     800b39 <memcmp+0x4c>
		if (*s1 != *s2)
  800b03:	0f b6 03             	movzbl (%ebx),%eax
  800b06:	0f b6 0e             	movzbl (%esi),%ecx
  800b09:	38 c8                	cmp    %cl,%al
  800b0b:	75 17                	jne    800b24 <memcmp+0x37>
  800b0d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b12:	eb 1a                	jmp    800b2e <memcmp+0x41>
  800b14:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800b19:	83 c2 01             	add    $0x1,%edx
  800b1c:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800b20:	38 c8                	cmp    %cl,%al
  800b22:	74 0a                	je     800b2e <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800b24:	0f b6 c0             	movzbl %al,%eax
  800b27:	0f b6 c9             	movzbl %cl,%ecx
  800b2a:	29 c8                	sub    %ecx,%eax
  800b2c:	eb 10                	jmp    800b3e <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b2e:	39 fa                	cmp    %edi,%edx
  800b30:	75 e2                	jne    800b14 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b32:	b8 00 00 00 00       	mov    $0x0,%eax
  800b37:	eb 05                	jmp    800b3e <memcmp+0x51>
  800b39:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b3e:	5b                   	pop    %ebx
  800b3f:	5e                   	pop    %esi
  800b40:	5f                   	pop    %edi
  800b41:	5d                   	pop    %ebp
  800b42:	c3                   	ret    

00800b43 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b43:	55                   	push   %ebp
  800b44:	89 e5                	mov    %esp,%ebp
  800b46:	53                   	push   %ebx
  800b47:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800b4d:	89 c2                	mov    %eax,%edx
  800b4f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b52:	39 d0                	cmp    %edx,%eax
  800b54:	73 13                	jae    800b69 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b56:	89 d9                	mov    %ebx,%ecx
  800b58:	38 18                	cmp    %bl,(%eax)
  800b5a:	75 06                	jne    800b62 <memfind+0x1f>
  800b5c:	eb 0b                	jmp    800b69 <memfind+0x26>
  800b5e:	38 08                	cmp    %cl,(%eax)
  800b60:	74 07                	je     800b69 <memfind+0x26>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b62:	83 c0 01             	add    $0x1,%eax
  800b65:	39 d0                	cmp    %edx,%eax
  800b67:	75 f5                	jne    800b5e <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b69:	5b                   	pop    %ebx
  800b6a:	5d                   	pop    %ebp
  800b6b:	c3                   	ret    

00800b6c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	57                   	push   %edi
  800b70:	56                   	push   %esi
  800b71:	53                   	push   %ebx
  800b72:	83 ec 04             	sub    $0x4,%esp
  800b75:	8b 55 08             	mov    0x8(%ebp),%edx
  800b78:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b7b:	0f b6 02             	movzbl (%edx),%eax
  800b7e:	3c 09                	cmp    $0x9,%al
  800b80:	74 04                	je     800b86 <strtol+0x1a>
  800b82:	3c 20                	cmp    $0x20,%al
  800b84:	75 0e                	jne    800b94 <strtol+0x28>
		s++;
  800b86:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b89:	0f b6 02             	movzbl (%edx),%eax
  800b8c:	3c 09                	cmp    $0x9,%al
  800b8e:	74 f6                	je     800b86 <strtol+0x1a>
  800b90:	3c 20                	cmp    $0x20,%al
  800b92:	74 f2                	je     800b86 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b94:	3c 2b                	cmp    $0x2b,%al
  800b96:	75 0a                	jne    800ba2 <strtol+0x36>
		s++;
  800b98:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b9b:	bf 00 00 00 00       	mov    $0x0,%edi
  800ba0:	eb 10                	jmp    800bb2 <strtol+0x46>
  800ba2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ba7:	3c 2d                	cmp    $0x2d,%al
  800ba9:	75 07                	jne    800bb2 <strtol+0x46>
		s++, neg = 1;
  800bab:	83 c2 01             	add    $0x1,%edx
  800bae:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bb2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bb8:	75 15                	jne    800bcf <strtol+0x63>
  800bba:	80 3a 30             	cmpb   $0x30,(%edx)
  800bbd:	75 10                	jne    800bcf <strtol+0x63>
  800bbf:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bc3:	75 0a                	jne    800bcf <strtol+0x63>
		s += 2, base = 16;
  800bc5:	83 c2 02             	add    $0x2,%edx
  800bc8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bcd:	eb 10                	jmp    800bdf <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800bcf:	85 db                	test   %ebx,%ebx
  800bd1:	75 0c                	jne    800bdf <strtol+0x73>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bd3:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bd5:	80 3a 30             	cmpb   $0x30,(%edx)
  800bd8:	75 05                	jne    800bdf <strtol+0x73>
		s++, base = 8;
  800bda:	83 c2 01             	add    $0x1,%edx
  800bdd:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800bdf:	b8 00 00 00 00       	mov    $0x0,%eax
  800be4:	89 5d f0             	mov    %ebx,-0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800be7:	0f b6 0a             	movzbl (%edx),%ecx
  800bea:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800bed:	89 f3                	mov    %esi,%ebx
  800bef:	80 fb 09             	cmp    $0x9,%bl
  800bf2:	77 08                	ja     800bfc <strtol+0x90>
			dig = *s - '0';
  800bf4:	0f be c9             	movsbl %cl,%ecx
  800bf7:	83 e9 30             	sub    $0x30,%ecx
  800bfa:	eb 22                	jmp    800c1e <strtol+0xb2>
		else if (*s >= 'a' && *s <= 'z')
  800bfc:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800bff:	89 f3                	mov    %esi,%ebx
  800c01:	80 fb 19             	cmp    $0x19,%bl
  800c04:	77 08                	ja     800c0e <strtol+0xa2>
			dig = *s - 'a' + 10;
  800c06:	0f be c9             	movsbl %cl,%ecx
  800c09:	83 e9 57             	sub    $0x57,%ecx
  800c0c:	eb 10                	jmp    800c1e <strtol+0xb2>
		else if (*s >= 'A' && *s <= 'Z')
  800c0e:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800c11:	89 f3                	mov    %esi,%ebx
  800c13:	80 fb 19             	cmp    $0x19,%bl
  800c16:	77 16                	ja     800c2e <strtol+0xc2>
			dig = *s - 'A' + 10;
  800c18:	0f be c9             	movsbl %cl,%ecx
  800c1b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c1e:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800c21:	7d 0f                	jge    800c32 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800c23:	83 c2 01             	add    $0x1,%edx
  800c26:	0f af 45 f0          	imul   -0x10(%ebp),%eax
  800c2a:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800c2c:	eb b9                	jmp    800be7 <strtol+0x7b>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c2e:	89 c1                	mov    %eax,%ecx
  800c30:	eb 02                	jmp    800c34 <strtol+0xc8>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c32:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c34:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c38:	74 05                	je     800c3f <strtol+0xd3>
		*endptr = (char *) s;
  800c3a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c3d:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c3f:	89 ca                	mov    %ecx,%edx
  800c41:	f7 da                	neg    %edx
  800c43:	85 ff                	test   %edi,%edi
  800c45:	0f 45 c2             	cmovne %edx,%eax
}
  800c48:	83 c4 04             	add    $0x4,%esp
  800c4b:	5b                   	pop    %ebx
  800c4c:	5e                   	pop    %esi
  800c4d:	5f                   	pop    %edi
  800c4e:	5d                   	pop    %ebp
  800c4f:	c3                   	ret    

00800c50 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c50:	55                   	push   %ebp
  800c51:	89 e5                	mov    %esp,%ebp
  800c53:	83 ec 0c             	sub    $0xc,%esp
  800c56:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c59:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c5c:	89 7d fc             	mov    %edi,-0x4(%ebp)
static inline uint32_t

get_cpu_features(void)
{
	uint32_t feature;
	__asm __volatile(" movl $1, %%eax\n\t"
  800c5f:	b8 01 00 00 00       	mov    $0x1,%eax
  800c64:	0f a2                	cpuid  
  800c66:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c68:	b8 00 00 00 00       	mov    $0x0,%eax
  800c6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c70:	8b 55 08             	mov    0x8(%ebp),%edx
  800c73:	89 c3                	mov    %eax,%ebx
  800c75:	89 c7                	mov    %eax,%edi
  800c77:	89 c6                	mov    %eax,%esi
  800c79:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c7b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c7e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c81:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c84:	89 ec                	mov    %ebp,%esp
  800c86:	5d                   	pop    %ebp
  800c87:	c3                   	ret    

00800c88 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c88:	55                   	push   %ebp
  800c89:	89 e5                	mov    %esp,%ebp
  800c8b:	83 ec 0c             	sub    $0xc,%esp
  800c8e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c91:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c94:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800c97:	b8 01 00 00 00       	mov    $0x1,%eax
  800c9c:	0f a2                	cpuid  
  800c9e:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca5:	b8 01 00 00 00       	mov    $0x1,%eax
  800caa:	89 d1                	mov    %edx,%ecx
  800cac:	89 d3                	mov    %edx,%ebx
  800cae:	89 d7                	mov    %edx,%edi
  800cb0:	89 d6                	mov    %edx,%esi
  800cb2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cb4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cb7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cba:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cbd:	89 ec                	mov    %ebp,%esp
  800cbf:	5d                   	pop    %ebp
  800cc0:	c3                   	ret    

00800cc1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	83 ec 38             	sub    $0x38,%esp
  800cc7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cca:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ccd:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800cd0:	b8 01 00 00 00       	mov    $0x1,%eax
  800cd5:	0f a2                	cpuid  
  800cd7:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cde:	b8 03 00 00 00       	mov    $0x3,%eax
  800ce3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce6:	89 cb                	mov    %ecx,%ebx
  800ce8:	89 cf                	mov    %ecx,%edi
  800cea:	89 ce                	mov    %ecx,%esi
  800cec:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cee:	85 c0                	test   %eax,%eax
  800cf0:	7e 28                	jle    800d1a <sys_env_destroy+0x59>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cf6:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800cfd:	00 
  800cfe:	c7 44 24 08 7f 23 80 	movl   $0x80237f,0x8(%esp)
  800d05:	00 
  800d06:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800d0d:	00 
  800d0e:	c7 04 24 9c 23 80 00 	movl   $0x80239c,(%esp)
  800d15:	e8 d6 0d 00 00       	call   801af0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d1a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d1d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d20:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d23:	89 ec                	mov    %ebp,%esp
  800d25:	5d                   	pop    %ebp
  800d26:	c3                   	ret    

00800d27 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d27:	55                   	push   %ebp
  800d28:	89 e5                	mov    %esp,%ebp
  800d2a:	83 ec 0c             	sub    $0xc,%esp
  800d2d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d30:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d33:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d36:	b8 01 00 00 00       	mov    $0x1,%eax
  800d3b:	0f a2                	cpuid  
  800d3d:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3f:	ba 00 00 00 00       	mov    $0x0,%edx
  800d44:	b8 02 00 00 00       	mov    $0x2,%eax
  800d49:	89 d1                	mov    %edx,%ecx
  800d4b:	89 d3                	mov    %edx,%ebx
  800d4d:	89 d7                	mov    %edx,%edi
  800d4f:	89 d6                	mov    %edx,%esi
  800d51:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d53:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d56:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d59:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d5c:	89 ec                	mov    %ebp,%esp
  800d5e:	5d                   	pop    %ebp
  800d5f:	c3                   	ret    

00800d60 <sys_yield>:

void
sys_yield(void)
{
  800d60:	55                   	push   %ebp
  800d61:	89 e5                	mov    %esp,%ebp
  800d63:	83 ec 0c             	sub    $0xc,%esp
  800d66:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d69:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d6c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d6f:	b8 01 00 00 00       	mov    $0x1,%eax
  800d74:	0f a2                	cpuid  
  800d76:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d78:	ba 00 00 00 00       	mov    $0x0,%edx
  800d7d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d82:	89 d1                	mov    %edx,%ecx
  800d84:	89 d3                	mov    %edx,%ebx
  800d86:	89 d7                	mov    %edx,%edi
  800d88:	89 d6                	mov    %edx,%esi
  800d8a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d8c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d8f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d92:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d95:	89 ec                	mov    %ebp,%esp
  800d97:	5d                   	pop    %ebp
  800d98:	c3                   	ret    

00800d99 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d99:	55                   	push   %ebp
  800d9a:	89 e5                	mov    %esp,%ebp
  800d9c:	83 ec 38             	sub    $0x38,%esp
  800d9f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800da2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800da5:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800da8:	b8 01 00 00 00       	mov    $0x1,%eax
  800dad:	0f a2                	cpuid  
  800daf:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db1:	be 00 00 00 00       	mov    $0x0,%esi
  800db6:	b8 04 00 00 00       	mov    $0x4,%eax
  800dbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dc4:	89 f7                	mov    %esi,%edi
  800dc6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dc8:	85 c0                	test   %eax,%eax
  800dca:	7e 28                	jle    800df4 <sys_page_alloc+0x5b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dcc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dd0:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800dd7:	00 
  800dd8:	c7 44 24 08 7f 23 80 	movl   $0x80237f,0x8(%esp)
  800ddf:	00 
  800de0:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800de7:	00 
  800de8:	c7 04 24 9c 23 80 00 	movl   $0x80239c,(%esp)
  800def:	e8 fc 0c 00 00       	call   801af0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800df4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800df7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dfa:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dfd:	89 ec                	mov    %ebp,%esp
  800dff:	5d                   	pop    %ebp
  800e00:	c3                   	ret    

00800e01 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e01:	55                   	push   %ebp
  800e02:	89 e5                	mov    %esp,%ebp
  800e04:	83 ec 38             	sub    $0x38,%esp
  800e07:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e0a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e0d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e10:	b8 01 00 00 00       	mov    $0x1,%eax
  800e15:	0f a2                	cpuid  
  800e17:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e19:	b8 05 00 00 00       	mov    $0x5,%eax
  800e1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e21:	8b 55 08             	mov    0x8(%ebp),%edx
  800e24:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e27:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e2a:	8b 75 18             	mov    0x18(%ebp),%esi
  800e2d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e2f:	85 c0                	test   %eax,%eax
  800e31:	7e 28                	jle    800e5b <sys_page_map+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e33:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e37:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e3e:	00 
  800e3f:	c7 44 24 08 7f 23 80 	movl   $0x80237f,0x8(%esp)
  800e46:	00 
  800e47:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800e4e:	00 
  800e4f:	c7 04 24 9c 23 80 00 	movl   $0x80239c,(%esp)
  800e56:	e8 95 0c 00 00       	call   801af0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e5b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e5e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e61:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e64:	89 ec                	mov    %ebp,%esp
  800e66:	5d                   	pop    %ebp
  800e67:	c3                   	ret    

00800e68 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e68:	55                   	push   %ebp
  800e69:	89 e5                	mov    %esp,%ebp
  800e6b:	83 ec 38             	sub    $0x38,%esp
  800e6e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e71:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e74:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e77:	b8 01 00 00 00       	mov    $0x1,%eax
  800e7c:	0f a2                	cpuid  
  800e7e:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e80:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e85:	b8 06 00 00 00       	mov    $0x6,%eax
  800e8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e90:	89 df                	mov    %ebx,%edi
  800e92:	89 de                	mov    %ebx,%esi
  800e94:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e96:	85 c0                	test   %eax,%eax
  800e98:	7e 28                	jle    800ec2 <sys_page_unmap+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e9a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e9e:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800ea5:	00 
  800ea6:	c7 44 24 08 7f 23 80 	movl   $0x80237f,0x8(%esp)
  800ead:	00 
  800eae:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800eb5:	00 
  800eb6:	c7 04 24 9c 23 80 00 	movl   $0x80239c,(%esp)
  800ebd:	e8 2e 0c 00 00       	call   801af0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ec2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ec5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ec8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ecb:	89 ec                	mov    %ebp,%esp
  800ecd:	5d                   	pop    %ebp
  800ece:	c3                   	ret    

00800ecf <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ecf:	55                   	push   %ebp
  800ed0:	89 e5                	mov    %esp,%ebp
  800ed2:	83 ec 38             	sub    $0x38,%esp
  800ed5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ed8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800edb:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800ede:	b8 01 00 00 00       	mov    $0x1,%eax
  800ee3:	0f a2                	cpuid  
  800ee5:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ee7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eec:	b8 08 00 00 00       	mov    $0x8,%eax
  800ef1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef7:	89 df                	mov    %ebx,%edi
  800ef9:	89 de                	mov    %ebx,%esi
  800efb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800efd:	85 c0                	test   %eax,%eax
  800eff:	7e 28                	jle    800f29 <sys_env_set_status+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f01:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f05:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800f0c:	00 
  800f0d:	c7 44 24 08 7f 23 80 	movl   $0x80237f,0x8(%esp)
  800f14:	00 
  800f15:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800f1c:	00 
  800f1d:	c7 04 24 9c 23 80 00 	movl   $0x80239c,(%esp)
  800f24:	e8 c7 0b 00 00       	call   801af0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f29:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f2c:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f2f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f32:	89 ec                	mov    %ebp,%esp
  800f34:	5d                   	pop    %ebp
  800f35:	c3                   	ret    

00800f36 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f36:	55                   	push   %ebp
  800f37:	89 e5                	mov    %esp,%ebp
  800f39:	83 ec 38             	sub    $0x38,%esp
  800f3c:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f3f:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f42:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800f45:	b8 01 00 00 00       	mov    $0x1,%eax
  800f4a:	0f a2                	cpuid  
  800f4c:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f4e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f53:	b8 09 00 00 00       	mov    $0x9,%eax
  800f58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f5e:	89 df                	mov    %ebx,%edi
  800f60:	89 de                	mov    %ebx,%esi
  800f62:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f64:	85 c0                	test   %eax,%eax
  800f66:	7e 28                	jle    800f90 <sys_env_set_trapframe+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f68:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f6c:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f73:	00 
  800f74:	c7 44 24 08 7f 23 80 	movl   $0x80237f,0x8(%esp)
  800f7b:	00 
  800f7c:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800f83:	00 
  800f84:	c7 04 24 9c 23 80 00 	movl   $0x80239c,(%esp)
  800f8b:	e8 60 0b 00 00       	call   801af0 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f90:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f93:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f96:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f99:	89 ec                	mov    %ebp,%esp
  800f9b:	5d                   	pop    %ebp
  800f9c:	c3                   	ret    

00800f9d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f9d:	55                   	push   %ebp
  800f9e:	89 e5                	mov    %esp,%ebp
  800fa0:	83 ec 38             	sub    $0x38,%esp
  800fa3:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fa6:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fa9:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800fac:	b8 01 00 00 00       	mov    $0x1,%eax
  800fb1:	0f a2                	cpuid  
  800fb3:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fb5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fba:	b8 0a 00 00 00       	mov    $0xa,%eax
  800fbf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc5:	89 df                	mov    %ebx,%edi
  800fc7:	89 de                	mov    %ebx,%esi
  800fc9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fcb:	85 c0                	test   %eax,%eax
  800fcd:	7e 28                	jle    800ff7 <sys_env_set_pgfault_upcall+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fcf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fd3:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800fda:	00 
  800fdb:	c7 44 24 08 7f 23 80 	movl   $0x80237f,0x8(%esp)
  800fe2:	00 
  800fe3:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800fea:	00 
  800feb:	c7 04 24 9c 23 80 00 	movl   $0x80239c,(%esp)
  800ff2:	e8 f9 0a 00 00       	call   801af0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ff7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ffa:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ffd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801000:	89 ec                	mov    %ebp,%esp
  801002:	5d                   	pop    %ebp
  801003:	c3                   	ret    

00801004 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801004:	55                   	push   %ebp
  801005:	89 e5                	mov    %esp,%ebp
  801007:	83 ec 0c             	sub    $0xc,%esp
  80100a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80100d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801010:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801013:	b8 01 00 00 00       	mov    $0x1,%eax
  801018:	0f a2                	cpuid  
  80101a:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80101c:	be 00 00 00 00       	mov    $0x0,%esi
  801021:	b8 0c 00 00 00       	mov    $0xc,%eax
  801026:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801029:	8b 55 08             	mov    0x8(%ebp),%edx
  80102c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80102f:	8b 7d 14             	mov    0x14(%ebp),%edi
  801032:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801034:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801037:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80103a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80103d:	89 ec                	mov    %ebp,%esp
  80103f:	5d                   	pop    %ebp
  801040:	c3                   	ret    

00801041 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801041:	55                   	push   %ebp
  801042:	89 e5                	mov    %esp,%ebp
  801044:	83 ec 38             	sub    $0x38,%esp
  801047:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80104a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80104d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801050:	b8 01 00 00 00       	mov    $0x1,%eax
  801055:	0f a2                	cpuid  
  801057:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801059:	b9 00 00 00 00       	mov    $0x0,%ecx
  80105e:	b8 0d 00 00 00       	mov    $0xd,%eax
  801063:	8b 55 08             	mov    0x8(%ebp),%edx
  801066:	89 cb                	mov    %ecx,%ebx
  801068:	89 cf                	mov    %ecx,%edi
  80106a:	89 ce                	mov    %ecx,%esi
  80106c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80106e:	85 c0                	test   %eax,%eax
  801070:	7e 28                	jle    80109a <sys_ipc_recv+0x59>
		panic("syscall %d returned %d (> 0)", num, ret);
  801072:	89 44 24 10          	mov    %eax,0x10(%esp)
  801076:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  80107d:	00 
  80107e:	c7 44 24 08 7f 23 80 	movl   $0x80237f,0x8(%esp)
  801085:	00 
  801086:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  80108d:	00 
  80108e:	c7 04 24 9c 23 80 00 	movl   $0x80239c,(%esp)
  801095:	e8 56 0a 00 00       	call   801af0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80109a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80109d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010a0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010a3:	89 ec                	mov    %ebp,%esp
  8010a5:	5d                   	pop    %ebp
  8010a6:	c3                   	ret    
  8010a7:	90                   	nop

008010a8 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8010a8:	55                   	push   %ebp
  8010a9:	89 e5                	mov    %esp,%ebp
  8010ab:	56                   	push   %esi
  8010ac:	53                   	push   %ebx
  8010ad:	83 ec 20             	sub    $0x20,%esp
  8010b0:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8010b3:	8b 30                	mov    (%eax),%esi
	// Hint:
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	pde_t pde = vpt[PGNUM(addr)];
  8010b5:	89 f2                	mov    %esi,%edx
  8010b7:	c1 ea 0c             	shr    $0xc,%edx
  8010ba:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx

	if(!((err & FEC_WR) && (pde &PTE_COW) ))
  8010c1:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8010c5:	74 05                	je     8010cc <pgfault+0x24>
  8010c7:	f6 c6 08             	test   $0x8,%dh
  8010ca:	75 20                	jne    8010ec <pgfault+0x44>
		panic("Unrecoverable page fault at address[0x%x]!\n", addr);
  8010cc:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8010d0:	c7 44 24 08 ac 23 80 	movl   $0x8023ac,0x8(%esp)
  8010d7:	00 
  8010d8:	c7 44 24 04 1f 00 00 	movl   $0x1f,0x4(%esp)
  8010df:	00 
  8010e0:	c7 04 24 f9 23 80 00 	movl   $0x8023f9,(%esp)
  8010e7:	e8 04 0a 00 00       	call   801af0 <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	envid_t thisenv_id = sys_getenvid();
  8010ec:	e8 36 fc ff ff       	call   800d27 <sys_getenvid>
  8010f1:	89 c3                	mov    %eax,%ebx
	sys_page_alloc(thisenv_id, PFTEMP, PTE_P|PTE_W|PTE_U);
  8010f3:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8010fa:	00 
  8010fb:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801102:	00 
  801103:	89 04 24             	mov    %eax,(%esp)
  801106:	e8 8e fc ff ff       	call   800d99 <sys_page_alloc>
	memmove((void*)PFTEMP, (void*)ROUNDDOWN(addr, PGSIZE), PGSIZE);
  80110b:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  801111:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801118:	00 
  801119:	89 74 24 04          	mov    %esi,0x4(%esp)
  80111d:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801124:	e8 2a f9 ff ff       	call   800a53 <memmove>
	sys_page_map(thisenv_id, (void*)PFTEMP, thisenv_id,(void*)ROUNDDOWN(addr, PGSIZE), 
  801129:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801130:	00 
  801131:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801135:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801139:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801140:	00 
  801141:	89 1c 24             	mov    %ebx,(%esp)
  801144:	e8 b8 fc ff ff       	call   800e01 <sys_page_map>
		PTE_U|PTE_W|PTE_P);
	//panic("pgfault not implemented");
}
  801149:	83 c4 20             	add    $0x20,%esp
  80114c:	5b                   	pop    %ebx
  80114d:	5e                   	pop    %esi
  80114e:	5d                   	pop    %ebp
  80114f:	c3                   	ret    

00801150 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801150:	55                   	push   %ebp
  801151:	89 e5                	mov    %esp,%ebp
  801153:	57                   	push   %edi
  801154:	56                   	push   %esi
  801155:	53                   	push   %ebx
  801156:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	envid_t child_id;
	uint32_t pg_cow_ptr;
	int r;

	set_pgfault_handler(pgfault);
  801159:	c7 04 24 a8 10 80 00 	movl   $0x8010a8,(%esp)
  801160:	e8 e3 09 00 00       	call   801b48 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801165:	ba 07 00 00 00       	mov    $0x7,%edx
  80116a:	89 d0                	mov    %edx,%eax
  80116c:	cd 30                	int    $0x30
  80116e:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801171:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if((child_id = sys_exofork()) < 0)
  801174:	85 c0                	test   %eax,%eax
  801176:	79 1c                	jns    801194 <fork+0x44>
		panic("Fork error\n");
  801178:	c7 44 24 08 04 24 80 	movl   $0x802404,0x8(%esp)
  80117f:	00 
  801180:	c7 44 24 04 6e 00 00 	movl   $0x6e,0x4(%esp)
  801187:	00 
  801188:	c7 04 24 f9 23 80 00 	movl   $0x8023f9,(%esp)
  80118f:	e8 5c 09 00 00       	call   801af0 <_panic>
	if(child_id == 0){
  801194:	bb 00 00 80 00       	mov    $0x800000,%ebx
  801199:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80119d:	75 1c                	jne    8011bb <fork+0x6b>
		thisenv = &envs[ENVX(sys_getenvid())];
  80119f:	e8 83 fb ff ff       	call   800d27 <sys_getenvid>
  8011a4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8011a9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011ac:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011b1:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  8011b6:	e9 00 01 00 00       	jmp    8012bb <fork+0x16b>
	}
	for(pg_cow_ptr = UTEXT; pg_cow_ptr < UXSTACKTOP - PGSIZE; pg_cow_ptr += PGSIZE){
		if ((vpd[PDX(pg_cow_ptr)]&PTE_P) && (vpt[PGNUM(pg_cow_ptr)]&(PTE_P|PTE_U)))
  8011bb:	89 d8                	mov    %ebx,%eax
  8011bd:	c1 e8 16             	shr    $0x16,%eax
  8011c0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011c7:	a8 01                	test   $0x1,%al
  8011c9:	74 79                	je     801244 <fork+0xf4>
  8011cb:	89 de                	mov    %ebx,%esi
  8011cd:	c1 ee 0c             	shr    $0xc,%esi
  8011d0:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011d7:	a8 05                	test   $0x5,%al
  8011d9:	74 69                	je     801244 <fork+0xf4>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	// LAB 4: Your code here.
	int map_sz = pn*PGSIZE;
  8011db:	89 f7                	mov    %esi,%edi
  8011dd:	c1 e7 0c             	shl    $0xc,%edi
	envid_t thisenv_id = sys_getenvid();
  8011e0:	e8 42 fb ff ff       	call   800d27 <sys_getenvid>
  8011e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	int perm = vpt[pn]&PTE_SYSCALL;
  8011e8:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011ef:	89 c6                	mov    %eax,%esi
  8011f1:	81 e6 07 0e 00 00    	and    $0xe07,%esi

	if(perm & PTE_COW || perm & PTE_W){
  8011f7:	a9 02 08 00 00       	test   $0x802,%eax
  8011fc:	74 09                	je     801207 <fork+0xb7>
		perm |= PTE_COW;
  8011fe:	81 ce 00 08 00 00    	or     $0x800,%esi
		perm &= ~PTE_W;
  801204:	83 e6 fd             	and    $0xfffffffd,%esi
	}
	//cprintf("thisenv_id[%p]\n", thisenv_id);

	if((r = sys_page_map(thisenv_id, (void*)map_sz, envid, (void*)map_sz, perm)) < 0)
  801207:	89 74 24 10          	mov    %esi,0x10(%esp)
  80120b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80120f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801212:	89 44 24 08          	mov    %eax,0x8(%esp)
  801216:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80121a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80121d:	89 04 24             	mov    %eax,(%esp)
  801220:	e8 dc fb ff ff       	call   800e01 <sys_page_map>
  801225:	85 c0                	test   %eax,%eax
  801227:	78 1b                	js     801244 <fork+0xf4>
		return r;
	if((r = sys_page_map(thisenv_id, (void*)map_sz, thisenv_id, (void*)map_sz, perm)) < 0)
  801229:	89 74 24 10          	mov    %esi,0x10(%esp)
  80122d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801231:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801234:	89 44 24 08          	mov    %eax,0x8(%esp)
  801238:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80123c:	89 04 24             	mov    %eax,(%esp)
  80123f:	e8 bd fb ff ff       	call   800e01 <sys_page_map>
		panic("Fork error\n");
	if(child_id == 0){
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	for(pg_cow_ptr = UTEXT; pg_cow_ptr < UXSTACKTOP - PGSIZE; pg_cow_ptr += PGSIZE){
  801244:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80124a:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801250:	0f 85 65 ff ff ff    	jne    8011bb <fork+0x6b>
		if ((vpd[PDX(pg_cow_ptr)]&PTE_P) && (vpt[PGNUM(pg_cow_ptr)]&(PTE_P|PTE_U)))
			duppage(child_id, PGNUM(pg_cow_ptr));
	}
	if((r = sys_page_alloc(child_id, (void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_P|PTE_W)))
  801256:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80125d:	00 
  80125e:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801265:	ee 
  801266:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801269:	89 04 24             	mov    %eax,(%esp)
  80126c:	e8 28 fb ff ff       	call   800d99 <sys_page_alloc>
  801271:	85 c0                	test   %eax,%eax
  801273:	74 20                	je     801295 <fork+0x145>
		panic("Alloc exception stack error: %e\n", r);
  801275:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801279:	c7 44 24 08 d8 23 80 	movl   $0x8023d8,0x8(%esp)
  801280:	00 
  801281:	c7 44 24 04 78 00 00 	movl   $0x78,0x4(%esp)
  801288:	00 
  801289:	c7 04 24 f9 23 80 00 	movl   $0x8023f9,(%esp)
  801290:	e8 5b 08 00 00       	call   801af0 <_panic>

	extern void _pgfault_upcall(void);
	sys_env_set_pgfault_upcall(child_id, _pgfault_upcall);
  801295:	c7 44 24 04 b8 1b 80 	movl   $0x801bb8,0x4(%esp)
  80129c:	00 
  80129d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012a0:	89 04 24             	mov    %eax,(%esp)
  8012a3:	e8 f5 fc ff ff       	call   800f9d <sys_env_set_pgfault_upcall>

	sys_env_set_status(child_id, ENV_RUNNABLE);
  8012a8:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8012af:	00 
  8012b0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012b3:	89 04 24             	mov    %eax,(%esp)
  8012b6:	e8 14 fc ff ff       	call   800ecf <sys_env_set_status>
	return child_id;
	//panic("fork not implemented");
}
  8012bb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012be:	83 c4 3c             	add    $0x3c,%esp
  8012c1:	5b                   	pop    %ebx
  8012c2:	5e                   	pop    %esi
  8012c3:	5f                   	pop    %edi
  8012c4:	5d                   	pop    %ebp
  8012c5:	c3                   	ret    

008012c6 <sfork>:

// Challenge!
int
sfork(void)
{
  8012c6:	55                   	push   %ebp
  8012c7:	89 e5                	mov    %esp,%ebp
  8012c9:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8012cc:	c7 44 24 08 10 24 80 	movl   $0x802410,0x8(%esp)
  8012d3:	00 
  8012d4:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  8012db:	00 
  8012dc:	c7 04 24 f9 23 80 00 	movl   $0x8023f9,(%esp)
  8012e3:	e8 08 08 00 00       	call   801af0 <_panic>
  8012e8:	66 90                	xchg   %ax,%ax
  8012ea:	66 90                	xchg   %ax,%ax
  8012ec:	66 90                	xchg   %ax,%ax
  8012ee:	66 90                	xchg   %ax,%ax

008012f0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012f0:	55                   	push   %ebp
  8012f1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8012f6:	05 00 00 00 30       	add    $0x30000000,%eax
  8012fb:	c1 e8 0c             	shr    $0xc,%eax
}
  8012fe:	5d                   	pop    %ebp
  8012ff:	c3                   	ret    

00801300 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801300:	55                   	push   %ebp
  801301:	89 e5                	mov    %esp,%ebp
  801303:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801306:	8b 45 08             	mov    0x8(%ebp),%eax
  801309:	89 04 24             	mov    %eax,(%esp)
  80130c:	e8 df ff ff ff       	call   8012f0 <fd2num>
  801311:	c1 e0 0c             	shl    $0xc,%eax
  801314:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801319:	c9                   	leave  
  80131a:	c3                   	ret    

0080131b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80131b:	55                   	push   %ebp
  80131c:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  80131e:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801323:	a8 01                	test   $0x1,%al
  801325:	74 34                	je     80135b <fd_alloc+0x40>
  801327:	a1 00 00 74 ef       	mov    0xef740000,%eax
  80132c:	a8 01                	test   $0x1,%al
  80132e:	74 32                	je     801362 <fd_alloc+0x47>
  801330:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801335:	89 c1                	mov    %eax,%ecx
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801337:	89 c2                	mov    %eax,%edx
  801339:	c1 ea 16             	shr    $0x16,%edx
  80133c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801343:	f6 c2 01             	test   $0x1,%dl
  801346:	74 1f                	je     801367 <fd_alloc+0x4c>
  801348:	89 c2                	mov    %eax,%edx
  80134a:	c1 ea 0c             	shr    $0xc,%edx
  80134d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801354:	f6 c2 01             	test   $0x1,%dl
  801357:	75 1a                	jne    801373 <fd_alloc+0x58>
  801359:	eb 0c                	jmp    801367 <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80135b:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801360:	eb 05                	jmp    801367 <fd_alloc+0x4c>
  801362:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  801367:	8b 45 08             	mov    0x8(%ebp),%eax
  80136a:	89 08                	mov    %ecx,(%eax)
			return 0;
  80136c:	b8 00 00 00 00       	mov    $0x0,%eax
  801371:	eb 1a                	jmp    80138d <fd_alloc+0x72>
  801373:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801378:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80137d:	75 b6                	jne    801335 <fd_alloc+0x1a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80137f:	8b 45 08             	mov    0x8(%ebp),%eax
  801382:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801388:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80138d:	5d                   	pop    %ebp
  80138e:	c3                   	ret    

0080138f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80138f:	55                   	push   %ebp
  801390:	89 e5                	mov    %esp,%ebp
  801392:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801395:	83 f8 1f             	cmp    $0x1f,%eax
  801398:	77 36                	ja     8013d0 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80139a:	c1 e0 0c             	shl    $0xc,%eax
  80139d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  8013a2:	89 c2                	mov    %eax,%edx
  8013a4:	c1 ea 16             	shr    $0x16,%edx
  8013a7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013ae:	f6 c2 01             	test   $0x1,%dl
  8013b1:	74 24                	je     8013d7 <fd_lookup+0x48>
  8013b3:	89 c2                	mov    %eax,%edx
  8013b5:	c1 ea 0c             	shr    $0xc,%edx
  8013b8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013bf:	f6 c2 01             	test   $0x1,%dl
  8013c2:	74 1a                	je     8013de <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8013c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013c7:	89 02                	mov    %eax,(%edx)
	return 0;
  8013c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8013ce:	eb 13                	jmp    8013e3 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  8013d0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013d5:	eb 0c                	jmp    8013e3 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  8013d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013dc:	eb 05                	jmp    8013e3 <fd_lookup+0x54>
  8013de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8013e3:	5d                   	pop    %ebp
  8013e4:	c3                   	ret    

008013e5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013e5:	55                   	push   %ebp
  8013e6:	89 e5                	mov    %esp,%ebp
  8013e8:	83 ec 18             	sub    $0x18,%esp
  8013eb:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8013ee:	39 05 04 30 80 00    	cmp    %eax,0x803004
  8013f4:	75 10                	jne    801406 <dev_lookup+0x21>
			*dev = devtab[i];
  8013f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013f9:	c7 00 04 30 80 00    	movl   $0x803004,(%eax)
			return 0;
  8013ff:	b8 00 00 00 00       	mov    $0x0,%eax
  801404:	eb 2b                	jmp    801431 <dev_lookup+0x4c>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801406:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80140c:	8b 52 48             	mov    0x48(%edx),%edx
  80140f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801413:	89 54 24 04          	mov    %edx,0x4(%esp)
  801417:	c7 04 24 28 24 80 00 	movl   $0x802428,(%esp)
  80141e:	e8 ac ed ff ff       	call   8001cf <cprintf>
	*dev = 0;
  801423:	8b 55 0c             	mov    0xc(%ebp),%edx
  801426:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	return -E_INVAL;
  80142c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801431:	c9                   	leave  
  801432:	c3                   	ret    

00801433 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801433:	55                   	push   %ebp
  801434:	89 e5                	mov    %esp,%ebp
  801436:	83 ec 38             	sub    $0x38,%esp
  801439:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80143c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80143f:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801442:	8b 7d 08             	mov    0x8(%ebp),%edi
  801445:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801448:	89 3c 24             	mov    %edi,(%esp)
  80144b:	e8 a0 fe ff ff       	call   8012f0 <fd2num>
  801450:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  801453:	89 54 24 04          	mov    %edx,0x4(%esp)
  801457:	89 04 24             	mov    %eax,(%esp)
  80145a:	e8 30 ff ff ff       	call   80138f <fd_lookup>
  80145f:	89 c3                	mov    %eax,%ebx
  801461:	85 c0                	test   %eax,%eax
  801463:	78 05                	js     80146a <fd_close+0x37>
	    || fd != fd2)
  801465:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  801468:	74 0c                	je     801476 <fd_close+0x43>
		return (must_exist ? r : 0);
  80146a:	85 f6                	test   %esi,%esi
  80146c:	b8 00 00 00 00       	mov    $0x0,%eax
  801471:	0f 44 d8             	cmove  %eax,%ebx
  801474:	eb 3d                	jmp    8014b3 <fd_close+0x80>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801476:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801479:	89 44 24 04          	mov    %eax,0x4(%esp)
  80147d:	8b 07                	mov    (%edi),%eax
  80147f:	89 04 24             	mov    %eax,(%esp)
  801482:	e8 5e ff ff ff       	call   8013e5 <dev_lookup>
  801487:	89 c3                	mov    %eax,%ebx
  801489:	85 c0                	test   %eax,%eax
  80148b:	78 16                	js     8014a3 <fd_close+0x70>
		if (dev->dev_close)
  80148d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801490:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801493:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801498:	85 c0                	test   %eax,%eax
  80149a:	74 07                	je     8014a3 <fd_close+0x70>
			r = (*dev->dev_close)(fd);
  80149c:	89 3c 24             	mov    %edi,(%esp)
  80149f:	ff d0                	call   *%eax
  8014a1:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8014a3:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8014a7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014ae:	e8 b5 f9 ff ff       	call   800e68 <sys_page_unmap>
	return r;
}
  8014b3:	89 d8                	mov    %ebx,%eax
  8014b5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8014b8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8014bb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8014be:	89 ec                	mov    %ebp,%esp
  8014c0:	5d                   	pop    %ebp
  8014c1:	c3                   	ret    

008014c2 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8014c2:	55                   	push   %ebp
  8014c3:	89 e5                	mov    %esp,%ebp
  8014c5:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d2:	89 04 24             	mov    %eax,(%esp)
  8014d5:	e8 b5 fe ff ff       	call   80138f <fd_lookup>
  8014da:	85 c0                	test   %eax,%eax
  8014dc:	78 13                	js     8014f1 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8014de:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8014e5:	00 
  8014e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014e9:	89 04 24             	mov    %eax,(%esp)
  8014ec:	e8 42 ff ff ff       	call   801433 <fd_close>
}
  8014f1:	c9                   	leave  
  8014f2:	c3                   	ret    

008014f3 <close_all>:

void
close_all(void)
{
  8014f3:	55                   	push   %ebp
  8014f4:	89 e5                	mov    %esp,%ebp
  8014f6:	53                   	push   %ebx
  8014f7:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014fa:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014ff:	89 1c 24             	mov    %ebx,(%esp)
  801502:	e8 bb ff ff ff       	call   8014c2 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801507:	83 c3 01             	add    $0x1,%ebx
  80150a:	83 fb 20             	cmp    $0x20,%ebx
  80150d:	75 f0                	jne    8014ff <close_all+0xc>
		close(i);
}
  80150f:	83 c4 14             	add    $0x14,%esp
  801512:	5b                   	pop    %ebx
  801513:	5d                   	pop    %ebp
  801514:	c3                   	ret    

00801515 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801515:	55                   	push   %ebp
  801516:	89 e5                	mov    %esp,%ebp
  801518:	83 ec 58             	sub    $0x58,%esp
  80151b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80151e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801521:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801524:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801527:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80152a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80152e:	8b 45 08             	mov    0x8(%ebp),%eax
  801531:	89 04 24             	mov    %eax,(%esp)
  801534:	e8 56 fe ff ff       	call   80138f <fd_lookup>
  801539:	85 c0                	test   %eax,%eax
  80153b:	0f 88 e3 00 00 00    	js     801624 <dup+0x10f>
		return r;
	close(newfdnum);
  801541:	89 1c 24             	mov    %ebx,(%esp)
  801544:	e8 79 ff ff ff       	call   8014c2 <close>

	newfd = INDEX2FD(newfdnum);
  801549:	89 de                	mov    %ebx,%esi
  80154b:	c1 e6 0c             	shl    $0xc,%esi
  80154e:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801554:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801557:	89 04 24             	mov    %eax,(%esp)
  80155a:	e8 a1 fd ff ff       	call   801300 <fd2data>
  80155f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801561:	89 34 24             	mov    %esi,(%esp)
  801564:	e8 97 fd ff ff       	call   801300 <fd2data>
  801569:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  80156c:	89 f8                	mov    %edi,%eax
  80156e:	c1 e8 16             	shr    $0x16,%eax
  801571:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801578:	a8 01                	test   $0x1,%al
  80157a:	74 46                	je     8015c2 <dup+0xad>
  80157c:	89 f8                	mov    %edi,%eax
  80157e:	c1 e8 0c             	shr    $0xc,%eax
  801581:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801588:	f6 c2 01             	test   $0x1,%dl
  80158b:	74 35                	je     8015c2 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80158d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801594:	25 07 0e 00 00       	and    $0xe07,%eax
  801599:	89 44 24 10          	mov    %eax,0x10(%esp)
  80159d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8015a0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015a4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015ab:	00 
  8015ac:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8015b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015b7:	e8 45 f8 ff ff       	call   800e01 <sys_page_map>
  8015bc:	89 c7                	mov    %eax,%edi
  8015be:	85 c0                	test   %eax,%eax
  8015c0:	78 3b                	js     8015fd <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015c5:	89 c2                	mov    %eax,%edx
  8015c7:	c1 ea 0c             	shr    $0xc,%edx
  8015ca:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8015d1:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8015d7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8015db:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8015df:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015e6:	00 
  8015e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015f2:	e8 0a f8 ff ff       	call   800e01 <sys_page_map>
  8015f7:	89 c7                	mov    %eax,%edi
  8015f9:	85 c0                	test   %eax,%eax
  8015fb:	79 29                	jns    801626 <dup+0x111>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8015fd:	89 74 24 04          	mov    %esi,0x4(%esp)
  801601:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801608:	e8 5b f8 ff ff       	call   800e68 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80160d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801610:	89 44 24 04          	mov    %eax,0x4(%esp)
  801614:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80161b:	e8 48 f8 ff ff       	call   800e68 <sys_page_unmap>
	return r;
  801620:	89 fb                	mov    %edi,%ebx
  801622:	eb 02                	jmp    801626 <dup+0x111>
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
		return r;
  801624:	89 c3                	mov    %eax,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801626:	89 d8                	mov    %ebx,%eax
  801628:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80162b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80162e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801631:	89 ec                	mov    %ebp,%esp
  801633:	5d                   	pop    %ebp
  801634:	c3                   	ret    

00801635 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801635:	55                   	push   %ebp
  801636:	89 e5                	mov    %esp,%ebp
  801638:	53                   	push   %ebx
  801639:	83 ec 24             	sub    $0x24,%esp
  80163c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80163f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801642:	89 44 24 04          	mov    %eax,0x4(%esp)
  801646:	89 1c 24             	mov    %ebx,(%esp)
  801649:	e8 41 fd ff ff       	call   80138f <fd_lookup>
  80164e:	85 c0                	test   %eax,%eax
  801650:	78 6d                	js     8016bf <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801652:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801655:	89 44 24 04          	mov    %eax,0x4(%esp)
  801659:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80165c:	8b 00                	mov    (%eax),%eax
  80165e:	89 04 24             	mov    %eax,(%esp)
  801661:	e8 7f fd ff ff       	call   8013e5 <dev_lookup>
  801666:	85 c0                	test   %eax,%eax
  801668:	78 55                	js     8016bf <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80166a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80166d:	8b 50 08             	mov    0x8(%eax),%edx
  801670:	83 e2 03             	and    $0x3,%edx
  801673:	83 fa 01             	cmp    $0x1,%edx
  801676:	75 23                	jne    80169b <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801678:	a1 04 40 80 00       	mov    0x804004,%eax
  80167d:	8b 40 48             	mov    0x48(%eax),%eax
  801680:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801684:	89 44 24 04          	mov    %eax,0x4(%esp)
  801688:	c7 04 24 69 24 80 00 	movl   $0x802469,(%esp)
  80168f:	e8 3b eb ff ff       	call   8001cf <cprintf>
		return -E_INVAL;
  801694:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801699:	eb 24                	jmp    8016bf <read+0x8a>
	}
	if (!dev->dev_read)
  80169b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80169e:	8b 52 08             	mov    0x8(%edx),%edx
  8016a1:	85 d2                	test   %edx,%edx
  8016a3:	74 15                	je     8016ba <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8016a5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8016a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8016ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016af:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8016b3:	89 04 24             	mov    %eax,(%esp)
  8016b6:	ff d2                	call   *%edx
  8016b8:	eb 05                	jmp    8016bf <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8016ba:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8016bf:	83 c4 24             	add    $0x24,%esp
  8016c2:	5b                   	pop    %ebx
  8016c3:	5d                   	pop    %ebp
  8016c4:	c3                   	ret    

008016c5 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8016c5:	55                   	push   %ebp
  8016c6:	89 e5                	mov    %esp,%ebp
  8016c8:	57                   	push   %edi
  8016c9:	56                   	push   %esi
  8016ca:	53                   	push   %ebx
  8016cb:	83 ec 1c             	sub    $0x1c,%esp
  8016ce:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016d1:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016d4:	85 f6                	test   %esi,%esi
  8016d6:	74 33                	je     80170b <readn+0x46>
  8016d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8016dd:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016e2:	89 f2                	mov    %esi,%edx
  8016e4:	29 c2                	sub    %eax,%edx
  8016e6:	89 54 24 08          	mov    %edx,0x8(%esp)
  8016ea:	03 45 0c             	add    0xc(%ebp),%eax
  8016ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016f1:	89 3c 24             	mov    %edi,(%esp)
  8016f4:	e8 3c ff ff ff       	call   801635 <read>
		if (m < 0)
  8016f9:	85 c0                	test   %eax,%eax
  8016fb:	78 17                	js     801714 <readn+0x4f>
			return m;
		if (m == 0)
  8016fd:	85 c0                	test   %eax,%eax
  8016ff:	74 11                	je     801712 <readn+0x4d>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801701:	01 c3                	add    %eax,%ebx
  801703:	89 d8                	mov    %ebx,%eax
  801705:	39 f3                	cmp    %esi,%ebx
  801707:	72 d9                	jb     8016e2 <readn+0x1d>
  801709:	eb 09                	jmp    801714 <readn+0x4f>
  80170b:	b8 00 00 00 00       	mov    $0x0,%eax
  801710:	eb 02                	jmp    801714 <readn+0x4f>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801712:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801714:	83 c4 1c             	add    $0x1c,%esp
  801717:	5b                   	pop    %ebx
  801718:	5e                   	pop    %esi
  801719:	5f                   	pop    %edi
  80171a:	5d                   	pop    %ebp
  80171b:	c3                   	ret    

0080171c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80171c:	55                   	push   %ebp
  80171d:	89 e5                	mov    %esp,%ebp
  80171f:	53                   	push   %ebx
  801720:	83 ec 24             	sub    $0x24,%esp
  801723:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801726:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801729:	89 44 24 04          	mov    %eax,0x4(%esp)
  80172d:	89 1c 24             	mov    %ebx,(%esp)
  801730:	e8 5a fc ff ff       	call   80138f <fd_lookup>
  801735:	85 c0                	test   %eax,%eax
  801737:	78 68                	js     8017a1 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801739:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80173c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801740:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801743:	8b 00                	mov    (%eax),%eax
  801745:	89 04 24             	mov    %eax,(%esp)
  801748:	e8 98 fc ff ff       	call   8013e5 <dev_lookup>
  80174d:	85 c0                	test   %eax,%eax
  80174f:	78 50                	js     8017a1 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801751:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801754:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801758:	75 23                	jne    80177d <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80175a:	a1 04 40 80 00       	mov    0x804004,%eax
  80175f:	8b 40 48             	mov    0x48(%eax),%eax
  801762:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801766:	89 44 24 04          	mov    %eax,0x4(%esp)
  80176a:	c7 04 24 85 24 80 00 	movl   $0x802485,(%esp)
  801771:	e8 59 ea ff ff       	call   8001cf <cprintf>
		return -E_INVAL;
  801776:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80177b:	eb 24                	jmp    8017a1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80177d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801780:	8b 52 0c             	mov    0xc(%edx),%edx
  801783:	85 d2                	test   %edx,%edx
  801785:	74 15                	je     80179c <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801787:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80178a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80178e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801791:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801795:	89 04 24             	mov    %eax,(%esp)
  801798:	ff d2                	call   *%edx
  80179a:	eb 05                	jmp    8017a1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80179c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8017a1:	83 c4 24             	add    $0x24,%esp
  8017a4:	5b                   	pop    %ebx
  8017a5:	5d                   	pop    %ebp
  8017a6:	c3                   	ret    

008017a7 <seek>:

int
seek(int fdnum, off_t offset)
{
  8017a7:	55                   	push   %ebp
  8017a8:	89 e5                	mov    %esp,%ebp
  8017aa:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017ad:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b7:	89 04 24             	mov    %eax,(%esp)
  8017ba:	e8 d0 fb ff ff       	call   80138f <fd_lookup>
  8017bf:	85 c0                	test   %eax,%eax
  8017c1:	78 0e                	js     8017d1 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8017c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8017c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017c9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8017cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017d1:	c9                   	leave  
  8017d2:	c3                   	ret    

008017d3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8017d3:	55                   	push   %ebp
  8017d4:	89 e5                	mov    %esp,%ebp
  8017d6:	53                   	push   %ebx
  8017d7:	83 ec 24             	sub    $0x24,%esp
  8017da:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017e4:	89 1c 24             	mov    %ebx,(%esp)
  8017e7:	e8 a3 fb ff ff       	call   80138f <fd_lookup>
  8017ec:	85 c0                	test   %eax,%eax
  8017ee:	78 61                	js     801851 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017fa:	8b 00                	mov    (%eax),%eax
  8017fc:	89 04 24             	mov    %eax,(%esp)
  8017ff:	e8 e1 fb ff ff       	call   8013e5 <dev_lookup>
  801804:	85 c0                	test   %eax,%eax
  801806:	78 49                	js     801851 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801808:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80180b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80180f:	75 23                	jne    801834 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801811:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801816:	8b 40 48             	mov    0x48(%eax),%eax
  801819:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80181d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801821:	c7 04 24 48 24 80 00 	movl   $0x802448,(%esp)
  801828:	e8 a2 e9 ff ff       	call   8001cf <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80182d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801832:	eb 1d                	jmp    801851 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801834:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801837:	8b 52 18             	mov    0x18(%edx),%edx
  80183a:	85 d2                	test   %edx,%edx
  80183c:	74 0e                	je     80184c <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80183e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801841:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801845:	89 04 24             	mov    %eax,(%esp)
  801848:	ff d2                	call   *%edx
  80184a:	eb 05                	jmp    801851 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80184c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801851:	83 c4 24             	add    $0x24,%esp
  801854:	5b                   	pop    %ebx
  801855:	5d                   	pop    %ebp
  801856:	c3                   	ret    

00801857 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801857:	55                   	push   %ebp
  801858:	89 e5                	mov    %esp,%ebp
  80185a:	53                   	push   %ebx
  80185b:	83 ec 24             	sub    $0x24,%esp
  80185e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801861:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801864:	89 44 24 04          	mov    %eax,0x4(%esp)
  801868:	8b 45 08             	mov    0x8(%ebp),%eax
  80186b:	89 04 24             	mov    %eax,(%esp)
  80186e:	e8 1c fb ff ff       	call   80138f <fd_lookup>
  801873:	85 c0                	test   %eax,%eax
  801875:	78 52                	js     8018c9 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801877:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80187a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80187e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801881:	8b 00                	mov    (%eax),%eax
  801883:	89 04 24             	mov    %eax,(%esp)
  801886:	e8 5a fb ff ff       	call   8013e5 <dev_lookup>
  80188b:	85 c0                	test   %eax,%eax
  80188d:	78 3a                	js     8018c9 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  80188f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801892:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801896:	74 2c                	je     8018c4 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801898:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80189b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018a2:	00 00 00 
	stat->st_isdir = 0;
  8018a5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018ac:	00 00 00 
	stat->st_dev = dev;
  8018af:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018b5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018b9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8018bc:	89 14 24             	mov    %edx,(%esp)
  8018bf:	ff 50 14             	call   *0x14(%eax)
  8018c2:	eb 05                	jmp    8018c9 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8018c4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8018c9:	83 c4 24             	add    $0x24,%esp
  8018cc:	5b                   	pop    %ebx
  8018cd:	5d                   	pop    %ebp
  8018ce:	c3                   	ret    

008018cf <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8018cf:	55                   	push   %ebp
  8018d0:	89 e5                	mov    %esp,%ebp
  8018d2:	83 ec 18             	sub    $0x18,%esp
  8018d5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8018d8:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8018db:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8018e2:	00 
  8018e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e6:	89 04 24             	mov    %eax,(%esp)
  8018e9:	e8 84 01 00 00       	call   801a72 <open>
  8018ee:	89 c3                	mov    %eax,%ebx
  8018f0:	85 c0                	test   %eax,%eax
  8018f2:	78 1b                	js     80190f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  8018f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018fb:	89 1c 24             	mov    %ebx,(%esp)
  8018fe:	e8 54 ff ff ff       	call   801857 <fstat>
  801903:	89 c6                	mov    %eax,%esi
	close(fd);
  801905:	89 1c 24             	mov    %ebx,(%esp)
  801908:	e8 b5 fb ff ff       	call   8014c2 <close>
	return r;
  80190d:	89 f3                	mov    %esi,%ebx
}
  80190f:	89 d8                	mov    %ebx,%eax
  801911:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801914:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801917:	89 ec                	mov    %ebp,%esp
  801919:	5d                   	pop    %ebp
  80191a:	c3                   	ret    
  80191b:	90                   	nop

0080191c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80191c:	55                   	push   %ebp
  80191d:	89 e5                	mov    %esp,%ebp
  80191f:	83 ec 18             	sub    $0x18,%esp
  801922:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801925:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801928:	89 c6                	mov    %eax,%esi
  80192a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80192c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801933:	75 11                	jne    801946 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801935:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  80193c:	e8 62 03 00 00       	call   801ca3 <ipc_find_env>
  801941:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801946:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80194d:	00 
  80194e:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801955:	00 
  801956:	89 74 24 04          	mov    %esi,0x4(%esp)
  80195a:	a1 00 40 80 00       	mov    0x804000,%eax
  80195f:	89 04 24             	mov    %eax,(%esp)
  801962:	e8 d1 02 00 00       	call   801c38 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801967:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80196e:	00 
  80196f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801973:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80197a:	e8 61 02 00 00       	call   801be0 <ipc_recv>
}
  80197f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801982:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801985:	89 ec                	mov    %ebp,%esp
  801987:	5d                   	pop    %ebp
  801988:	c3                   	ret    

00801989 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801989:	55                   	push   %ebp
  80198a:	89 e5                	mov    %esp,%ebp
  80198c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80198f:	8b 45 08             	mov    0x8(%ebp),%eax
  801992:	8b 40 0c             	mov    0xc(%eax),%eax
  801995:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80199a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80199d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8019a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8019a7:	b8 02 00 00 00       	mov    $0x2,%eax
  8019ac:	e8 6b ff ff ff       	call   80191c <fsipc>
}
  8019b1:	c9                   	leave  
  8019b2:	c3                   	ret    

008019b3 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8019b3:	55                   	push   %ebp
  8019b4:	89 e5                	mov    %esp,%ebp
  8019b6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8019b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8019bc:	8b 40 0c             	mov    0xc(%eax),%eax
  8019bf:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8019c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8019c9:	b8 06 00 00 00       	mov    $0x6,%eax
  8019ce:	e8 49 ff ff ff       	call   80191c <fsipc>
}
  8019d3:	c9                   	leave  
  8019d4:	c3                   	ret    

008019d5 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8019d5:	55                   	push   %ebp
  8019d6:	89 e5                	mov    %esp,%ebp
  8019d8:	53                   	push   %ebx
  8019d9:	83 ec 14             	sub    $0x14,%esp
  8019dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8019df:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e2:	8b 40 0c             	mov    0xc(%eax),%eax
  8019e5:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8019ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8019ef:	b8 05 00 00 00       	mov    $0x5,%eax
  8019f4:	e8 23 ff ff ff       	call   80191c <fsipc>
  8019f9:	85 c0                	test   %eax,%eax
  8019fb:	78 2b                	js     801a28 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8019fd:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801a04:	00 
  801a05:	89 1c 24             	mov    %ebx,(%esp)
  801a08:	e8 3e ee ff ff       	call   80084b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a0d:	a1 80 50 80 00       	mov    0x805080,%eax
  801a12:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a18:	a1 84 50 80 00       	mov    0x805084,%eax
  801a1d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a23:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a28:	83 c4 14             	add    $0x14,%esp
  801a2b:	5b                   	pop    %ebx
  801a2c:	5d                   	pop    %ebp
  801a2d:	c3                   	ret    

00801a2e <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a2e:	55                   	push   %ebp
  801a2f:	89 e5                	mov    %esp,%ebp
  801a31:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801a34:	c7 44 24 08 a2 24 80 	movl   $0x8024a2,0x8(%esp)
  801a3b:	00 
  801a3c:	c7 44 24 04 77 00 00 	movl   $0x77,0x4(%esp)
  801a43:	00 
  801a44:	c7 04 24 c0 24 80 00 	movl   $0x8024c0,(%esp)
  801a4b:	e8 a0 00 00 00       	call   801af0 <_panic>

00801a50 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a50:	55                   	push   %ebp
  801a51:	89 e5                	mov    %esp,%ebp
  801a53:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_READ request to the file system server after
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
	panic("devfile_read not implemented");
  801a56:	c7 44 24 08 cb 24 80 	movl   $0x8024cb,0x8(%esp)
  801a5d:	00 
  801a5e:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
  801a65:	00 
  801a66:	c7 04 24 c0 24 80 00 	movl   $0x8024c0,(%esp)
  801a6d:	e8 7e 00 00 00       	call   801af0 <_panic>

00801a72 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a72:	55                   	push   %ebp
  801a73:	89 e5                	mov    %esp,%ebp
  801a75:	83 ec 18             	sub    $0x18,%esp
	// Return the file descriptor index.
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
	panic("open not implemented");
  801a78:	c7 44 24 08 e8 24 80 	movl   $0x8024e8,0x8(%esp)
  801a7f:	00 
  801a80:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  801a87:	00 
  801a88:	c7 04 24 c0 24 80 00 	movl   $0x8024c0,(%esp)
  801a8f:	e8 5c 00 00 00       	call   801af0 <_panic>

00801a94 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801a94:	55                   	push   %ebp
  801a95:	89 e5                	mov    %esp,%ebp
  801a97:	53                   	push   %ebx
  801a98:	83 ec 14             	sub    $0x14,%esp
  801a9b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801a9e:	89 1c 24             	mov    %ebx,(%esp)
  801aa1:	e8 4a ed ff ff       	call   8007f0 <strlen>
  801aa6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801aab:	7f 21                	jg     801ace <remove+0x3a>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801aad:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ab1:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801ab8:	e8 8e ed ff ff       	call   80084b <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801abd:	ba 00 00 00 00       	mov    $0x0,%edx
  801ac2:	b8 07 00 00 00       	mov    $0x7,%eax
  801ac7:	e8 50 fe ff ff       	call   80191c <fsipc>
  801acc:	eb 05                	jmp    801ad3 <remove+0x3f>
// Delete a file
int
remove(const char *path)
{
	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801ace:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
	strcpy(fsipcbuf.remove.req_path, path);
	return fsipc(FSREQ_REMOVE, NULL);
}
  801ad3:	83 c4 14             	add    $0x14,%esp
  801ad6:	5b                   	pop    %ebx
  801ad7:	5d                   	pop    %ebp
  801ad8:	c3                   	ret    

00801ad9 <sync>:

// Synchronize disk with buffer cache
int
sync(void)
{
  801ad9:	55                   	push   %ebp
  801ada:	89 e5                	mov    %esp,%ebp
  801adc:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801adf:	ba 00 00 00 00       	mov    $0x0,%edx
  801ae4:	b8 08 00 00 00       	mov    $0x8,%eax
  801ae9:	e8 2e fe ff ff       	call   80191c <fsipc>
}
  801aee:	c9                   	leave  
  801aef:	c3                   	ret    

00801af0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801af0:	55                   	push   %ebp
  801af1:	89 e5                	mov    %esp,%ebp
  801af3:	56                   	push   %esi
  801af4:	53                   	push   %ebx
  801af5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801af8:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801afb:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801b01:	e8 21 f2 ff ff       	call   800d27 <sys_getenvid>
  801b06:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b09:	89 54 24 10          	mov    %edx,0x10(%esp)
  801b0d:	8b 55 08             	mov    0x8(%ebp),%edx
  801b10:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801b14:	89 74 24 08          	mov    %esi,0x8(%esp)
  801b18:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b1c:	c7 04 24 00 25 80 00 	movl   $0x802500,(%esp)
  801b23:	e8 a7 e6 ff ff       	call   8001cf <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801b28:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b2c:	8b 45 10             	mov    0x10(%ebp),%eax
  801b2f:	89 04 24             	mov    %eax,(%esp)
  801b32:	e8 37 e6 ff ff       	call   80016e <vcprintf>
	cprintf("\n");
  801b37:	c7 04 24 74 20 80 00 	movl   $0x802074,(%esp)
  801b3e:	e8 8c e6 ff ff       	call   8001cf <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801b43:	cc                   	int3   
  801b44:	eb fd                	jmp    801b43 <_panic+0x53>
  801b46:	66 90                	xchg   %ax,%ax

00801b48 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801b48:	55                   	push   %ebp
  801b49:	89 e5                	mov    %esp,%ebp
  801b4b:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801b4e:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801b55:	75 54                	jne    801bab <set_pgfault_handler+0x63>
		// First time through!
		// LAB 4: Your code here.
		if((r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U|PTE_P|PTE_W)))
  801b57:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801b5e:	00 
  801b5f:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801b66:	ee 
  801b67:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b6e:	e8 26 f2 ff ff       	call   800d99 <sys_page_alloc>
  801b73:	85 c0                	test   %eax,%eax
  801b75:	74 20                	je     801b97 <set_pgfault_handler+0x4f>
			panic("sys_page_alloc() failed in set_pgfault_handler()[%e]\n", r);
  801b77:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b7b:	c7 44 24 08 24 25 80 	movl   $0x802524,0x8(%esp)
  801b82:	00 
  801b83:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  801b8a:	00 
  801b8b:	c7 04 24 5c 25 80 00 	movl   $0x80255c,(%esp)
  801b92:	e8 59 ff ff ff       	call   801af0 <_panic>
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801b97:	c7 44 24 04 b8 1b 80 	movl   $0x801bb8,0x4(%esp)
  801b9e:	00 
  801b9f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ba6:	e8 f2 f3 ff ff       	call   800f9d <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801bab:	8b 45 08             	mov    0x8(%ebp),%eax
  801bae:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801bb3:	c9                   	leave  
  801bb4:	c3                   	ret    
  801bb5:	66 90                	xchg   %ax,%ax
  801bb7:	90                   	nop

00801bb8 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801bb8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801bb9:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801bbe:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801bc0:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	// @yuhangj: get reserved place under old esp
	addl $0x08, %esp;
  801bc3:	83 c4 08             	add    $0x8,%esp

	movl 0x28(%esp), %eax;
  801bc6:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x04, %eax;
  801bca:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x28(%esp);
  801bcd:	89 44 24 28          	mov    %eax,0x28(%esp)

    // @yuhangj: store old eip into the reserved place under old esp
	movl 0x20(%esp), %ebx;
  801bd1:	8b 5c 24 20          	mov    0x20(%esp),%ebx
	movl %ebx, (%eax);
  801bd5:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  801bd7:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp;
  801bd8:	83 c4 04             	add    $0x4,%esp
	popfl
  801bdb:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  801bdc:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  801bdd:	c3                   	ret    
  801bde:	66 90                	xchg   %ax,%ax

00801be0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801be0:	55                   	push   %ebp
  801be1:	89 e5                	mov    %esp,%ebp
  801be3:	56                   	push   %esi
  801be4:	53                   	push   %ebx
  801be5:	83 ec 10             	sub    $0x10,%esp
  801be8:	8b 75 08             	mov    0x8(%ebp),%esi
  801beb:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	// 	return thisenv->env_ipc_value;
	// }
	int r;
	if(pg == NULL)
		pg = (void *)~0x0;
  801bee:	85 db                	test   %ebx,%ebx
  801bf0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801bf5:	0f 44 d8             	cmove  %eax,%ebx
	//else
	if((r = sys_ipc_recv(pg)) < 0)
  801bf8:	89 1c 24             	mov    %ebx,(%esp)
  801bfb:	e8 41 f4 ff ff       	call   801041 <sys_ipc_recv>
  801c00:	85 c0                	test   %eax,%eax
  801c02:	78 2d                	js     801c31 <ipc_recv+0x51>
		return r;
	//volatile struct Env *curenv = (struct Env*)envs+ENVX(sys_getenvid());

	if(from_env_store)
  801c04:	85 f6                	test   %esi,%esi
  801c06:	74 0a                	je     801c12 <ipc_recv+0x32>
		*from_env_store = thisenv -> env_ipc_from;
  801c08:	a1 04 40 80 00       	mov    0x804004,%eax
  801c0d:	8b 40 74             	mov    0x74(%eax),%eax
  801c10:	89 06                	mov    %eax,(%esi)
	if(pg && perm_store)
  801c12:	85 db                	test   %ebx,%ebx
  801c14:	74 13                	je     801c29 <ipc_recv+0x49>
  801c16:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c1a:	74 0d                	je     801c29 <ipc_recv+0x49>
		*perm_store = thisenv -> env_ipc_perm;
  801c1c:	a1 04 40 80 00       	mov    0x804004,%eax
  801c21:	8b 40 78             	mov    0x78(%eax),%eax
  801c24:	8b 55 10             	mov    0x10(%ebp),%edx
  801c27:	89 02                	mov    %eax,(%edx)
	else if(perm_store)
		perm_store = (int *)0;
	return thisenv->env_ipc_value;
  801c29:	a1 04 40 80 00       	mov    0x804004,%eax
  801c2e:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  801c31:	83 c4 10             	add    $0x10,%esp
  801c34:	5b                   	pop    %ebx
  801c35:	5e                   	pop    %esi
  801c36:	5d                   	pop    %ebp
  801c37:	c3                   	ret    

00801c38 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c38:	55                   	push   %ebp
  801c39:	89 e5                	mov    %esp,%ebp
  801c3b:	57                   	push   %edi
  801c3c:	56                   	push   %esi
  801c3d:	53                   	push   %ebx
  801c3e:	83 ec 1c             	sub    $0x1c,%esp
  801c41:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c44:	8b 75 0c             	mov    0xc(%ebp),%esi
  801c47:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

	if(pg == NULL)
  801c4a:	85 db                	test   %ebx,%ebx
		pg = (void *)~0x0;
  801c4c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801c51:	0f 44 d8             	cmove  %eax,%ebx
  801c54:	eb 2a                	jmp    801c80 <ipc_send+0x48>
	while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0){
		if(r != -E_IPC_NOT_RECV)
  801c56:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c59:	74 20                	je     801c7b <ipc_send+0x43>
            panic("Send message error %e\n",r);
  801c5b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c5f:	c7 44 24 08 6a 25 80 	movl   $0x80256a,0x8(%esp)
  801c66:	00 
  801c67:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  801c6e:	00 
  801c6f:	c7 04 24 81 25 80 00 	movl   $0x802581,(%esp)
  801c76:	e8 75 fe ff ff       	call   801af0 <_panic>
		sys_yield();
  801c7b:	e8 e0 f0 ff ff       	call   800d60 <sys_yield>
	// LAB 4: Your code here.
	int r;

	if(pg == NULL)
		pg = (void *)~0x0;
	while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0){
  801c80:	8b 45 14             	mov    0x14(%ebp),%eax
  801c83:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c87:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c8b:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c8f:	89 3c 24             	mov    %edi,(%esp)
  801c92:	e8 6d f3 ff ff       	call   801004 <sys_ipc_try_send>
  801c97:	85 c0                	test   %eax,%eax
  801c99:	78 bb                	js     801c56 <ipc_send+0x1e>
            panic("Send message error %e\n",r);
		sys_yield();
	}

	//panic("ipc_send not implemented");
}
  801c9b:	83 c4 1c             	add    $0x1c,%esp
  801c9e:	5b                   	pop    %ebx
  801c9f:	5e                   	pop    %esi
  801ca0:	5f                   	pop    %edi
  801ca1:	5d                   	pop    %ebp
  801ca2:	c3                   	ret    

00801ca3 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ca3:	55                   	push   %ebp
  801ca4:	89 e5                	mov    %esp,%ebp
  801ca6:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801ca9:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801cae:	39 c8                	cmp    %ecx,%eax
  801cb0:	74 17                	je     801cc9 <ipc_find_env+0x26>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801cb2:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801cb7:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801cba:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801cc0:	8b 52 50             	mov    0x50(%edx),%edx
  801cc3:	39 ca                	cmp    %ecx,%edx
  801cc5:	75 14                	jne    801cdb <ipc_find_env+0x38>
  801cc7:	eb 05                	jmp    801cce <ipc_find_env+0x2b>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801cc9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801cce:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801cd1:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801cd6:	8b 40 40             	mov    0x40(%eax),%eax
  801cd9:	eb 0e                	jmp    801ce9 <ipc_find_env+0x46>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801cdb:	83 c0 01             	add    $0x1,%eax
  801cde:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ce3:	75 d2                	jne    801cb7 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ce5:	66 b8 00 00          	mov    $0x0,%ax
}
  801ce9:	5d                   	pop    %ebp
  801cea:	c3                   	ret    
  801ceb:	66 90                	xchg   %ax,%ax
  801ced:	66 90                	xchg   %ax,%ax
  801cef:	90                   	nop

00801cf0 <__udivdi3>:
  801cf0:	83 ec 1c             	sub    $0x1c,%esp
  801cf3:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801cf7:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801cfb:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801cff:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801d03:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801d07:	8b 6c 24 24          	mov    0x24(%esp),%ebp
  801d0b:	85 c0                	test   %eax,%eax
  801d0d:	89 74 24 10          	mov    %esi,0x10(%esp)
  801d11:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801d15:	89 ea                	mov    %ebp,%edx
  801d17:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801d1b:	75 33                	jne    801d50 <__udivdi3+0x60>
  801d1d:	39 e9                	cmp    %ebp,%ecx
  801d1f:	77 6f                	ja     801d90 <__udivdi3+0xa0>
  801d21:	85 c9                	test   %ecx,%ecx
  801d23:	89 ce                	mov    %ecx,%esi
  801d25:	75 0b                	jne    801d32 <__udivdi3+0x42>
  801d27:	b8 01 00 00 00       	mov    $0x1,%eax
  801d2c:	31 d2                	xor    %edx,%edx
  801d2e:	f7 f1                	div    %ecx
  801d30:	89 c6                	mov    %eax,%esi
  801d32:	31 d2                	xor    %edx,%edx
  801d34:	89 e8                	mov    %ebp,%eax
  801d36:	f7 f6                	div    %esi
  801d38:	89 c5                	mov    %eax,%ebp
  801d3a:	89 f8                	mov    %edi,%eax
  801d3c:	f7 f6                	div    %esi
  801d3e:	89 ea                	mov    %ebp,%edx
  801d40:	8b 74 24 10          	mov    0x10(%esp),%esi
  801d44:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801d48:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801d4c:	83 c4 1c             	add    $0x1c,%esp
  801d4f:	c3                   	ret    
  801d50:	39 e8                	cmp    %ebp,%eax
  801d52:	77 24                	ja     801d78 <__udivdi3+0x88>
  801d54:	0f bd c8             	bsr    %eax,%ecx
  801d57:	83 f1 1f             	xor    $0x1f,%ecx
  801d5a:	89 0c 24             	mov    %ecx,(%esp)
  801d5d:	75 49                	jne    801da8 <__udivdi3+0xb8>
  801d5f:	8b 74 24 08          	mov    0x8(%esp),%esi
  801d63:	39 74 24 04          	cmp    %esi,0x4(%esp)
  801d67:	0f 86 ab 00 00 00    	jbe    801e18 <__udivdi3+0x128>
  801d6d:	39 e8                	cmp    %ebp,%eax
  801d6f:	0f 82 a3 00 00 00    	jb     801e18 <__udivdi3+0x128>
  801d75:	8d 76 00             	lea    0x0(%esi),%esi
  801d78:	31 d2                	xor    %edx,%edx
  801d7a:	31 c0                	xor    %eax,%eax
  801d7c:	8b 74 24 10          	mov    0x10(%esp),%esi
  801d80:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801d84:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801d88:	83 c4 1c             	add    $0x1c,%esp
  801d8b:	c3                   	ret    
  801d8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d90:	89 f8                	mov    %edi,%eax
  801d92:	f7 f1                	div    %ecx
  801d94:	31 d2                	xor    %edx,%edx
  801d96:	8b 74 24 10          	mov    0x10(%esp),%esi
  801d9a:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801d9e:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801da2:	83 c4 1c             	add    $0x1c,%esp
  801da5:	c3                   	ret    
  801da6:	66 90                	xchg   %ax,%ax
  801da8:	0f b6 0c 24          	movzbl (%esp),%ecx
  801dac:	89 c6                	mov    %eax,%esi
  801dae:	b8 20 00 00 00       	mov    $0x20,%eax
  801db3:	8b 6c 24 04          	mov    0x4(%esp),%ebp
  801db7:	2b 04 24             	sub    (%esp),%eax
  801dba:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801dbe:	d3 e6                	shl    %cl,%esi
  801dc0:	89 c1                	mov    %eax,%ecx
  801dc2:	d3 ed                	shr    %cl,%ebp
  801dc4:	0f b6 0c 24          	movzbl (%esp),%ecx
  801dc8:	09 f5                	or     %esi,%ebp
  801dca:	8b 74 24 04          	mov    0x4(%esp),%esi
  801dce:	d3 e6                	shl    %cl,%esi
  801dd0:	89 c1                	mov    %eax,%ecx
  801dd2:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dd6:	89 d6                	mov    %edx,%esi
  801dd8:	d3 ee                	shr    %cl,%esi
  801dda:	0f b6 0c 24          	movzbl (%esp),%ecx
  801dde:	d3 e2                	shl    %cl,%edx
  801de0:	89 c1                	mov    %eax,%ecx
  801de2:	d3 ef                	shr    %cl,%edi
  801de4:	09 d7                	or     %edx,%edi
  801de6:	89 f2                	mov    %esi,%edx
  801de8:	89 f8                	mov    %edi,%eax
  801dea:	f7 f5                	div    %ebp
  801dec:	89 d6                	mov    %edx,%esi
  801dee:	89 c7                	mov    %eax,%edi
  801df0:	f7 64 24 04          	mull   0x4(%esp)
  801df4:	39 d6                	cmp    %edx,%esi
  801df6:	72 30                	jb     801e28 <__udivdi3+0x138>
  801df8:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801dfc:	0f b6 0c 24          	movzbl (%esp),%ecx
  801e00:	d3 e5                	shl    %cl,%ebp
  801e02:	39 c5                	cmp    %eax,%ebp
  801e04:	73 04                	jae    801e0a <__udivdi3+0x11a>
  801e06:	39 d6                	cmp    %edx,%esi
  801e08:	74 1e                	je     801e28 <__udivdi3+0x138>
  801e0a:	89 f8                	mov    %edi,%eax
  801e0c:	31 d2                	xor    %edx,%edx
  801e0e:	e9 69 ff ff ff       	jmp    801d7c <__udivdi3+0x8c>
  801e13:	90                   	nop
  801e14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e18:	31 d2                	xor    %edx,%edx
  801e1a:	b8 01 00 00 00       	mov    $0x1,%eax
  801e1f:	e9 58 ff ff ff       	jmp    801d7c <__udivdi3+0x8c>
  801e24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e28:	8d 47 ff             	lea    -0x1(%edi),%eax
  801e2b:	31 d2                	xor    %edx,%edx
  801e2d:	8b 74 24 10          	mov    0x10(%esp),%esi
  801e31:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801e35:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801e39:	83 c4 1c             	add    $0x1c,%esp
  801e3c:	c3                   	ret    
  801e3d:	66 90                	xchg   %ax,%ax
  801e3f:	90                   	nop

00801e40 <__umoddi3>:
  801e40:	83 ec 2c             	sub    $0x2c,%esp
  801e43:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801e47:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801e4b:	89 74 24 20          	mov    %esi,0x20(%esp)
  801e4f:	8b 74 24 38          	mov    0x38(%esp),%esi
  801e53:	89 7c 24 24          	mov    %edi,0x24(%esp)
  801e57:	8b 7c 24 34          	mov    0x34(%esp),%edi
  801e5b:	85 c0                	test   %eax,%eax
  801e5d:	89 c2                	mov    %eax,%edx
  801e5f:	89 6c 24 28          	mov    %ebp,0x28(%esp)
  801e63:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801e67:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801e6b:	89 74 24 10          	mov    %esi,0x10(%esp)
  801e6f:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801e73:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801e77:	75 1f                	jne    801e98 <__umoddi3+0x58>
  801e79:	39 fe                	cmp    %edi,%esi
  801e7b:	76 63                	jbe    801ee0 <__umoddi3+0xa0>
  801e7d:	89 c8                	mov    %ecx,%eax
  801e7f:	89 fa                	mov    %edi,%edx
  801e81:	f7 f6                	div    %esi
  801e83:	89 d0                	mov    %edx,%eax
  801e85:	31 d2                	xor    %edx,%edx
  801e87:	8b 74 24 20          	mov    0x20(%esp),%esi
  801e8b:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801e8f:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801e93:	83 c4 2c             	add    $0x2c,%esp
  801e96:	c3                   	ret    
  801e97:	90                   	nop
  801e98:	39 f8                	cmp    %edi,%eax
  801e9a:	77 64                	ja     801f00 <__umoddi3+0xc0>
  801e9c:	0f bd e8             	bsr    %eax,%ebp
  801e9f:	83 f5 1f             	xor    $0x1f,%ebp
  801ea2:	75 74                	jne    801f18 <__umoddi3+0xd8>
  801ea4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801ea8:	39 7c 24 10          	cmp    %edi,0x10(%esp)
  801eac:	0f 87 0e 01 00 00    	ja     801fc0 <__umoddi3+0x180>
  801eb2:	8b 7c 24 0c          	mov    0xc(%esp),%edi
  801eb6:	29 f1                	sub    %esi,%ecx
  801eb8:	19 c7                	sbb    %eax,%edi
  801eba:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801ebe:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801ec2:	8b 44 24 14          	mov    0x14(%esp),%eax
  801ec6:	8b 54 24 18          	mov    0x18(%esp),%edx
  801eca:	8b 74 24 20          	mov    0x20(%esp),%esi
  801ece:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801ed2:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801ed6:	83 c4 2c             	add    $0x2c,%esp
  801ed9:	c3                   	ret    
  801eda:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ee0:	85 f6                	test   %esi,%esi
  801ee2:	89 f5                	mov    %esi,%ebp
  801ee4:	75 0b                	jne    801ef1 <__umoddi3+0xb1>
  801ee6:	b8 01 00 00 00       	mov    $0x1,%eax
  801eeb:	31 d2                	xor    %edx,%edx
  801eed:	f7 f6                	div    %esi
  801eef:	89 c5                	mov    %eax,%ebp
  801ef1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801ef5:	31 d2                	xor    %edx,%edx
  801ef7:	f7 f5                	div    %ebp
  801ef9:	89 c8                	mov    %ecx,%eax
  801efb:	f7 f5                	div    %ebp
  801efd:	eb 84                	jmp    801e83 <__umoddi3+0x43>
  801eff:	90                   	nop
  801f00:	89 c8                	mov    %ecx,%eax
  801f02:	89 fa                	mov    %edi,%edx
  801f04:	8b 74 24 20          	mov    0x20(%esp),%esi
  801f08:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801f0c:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801f10:	83 c4 2c             	add    $0x2c,%esp
  801f13:	c3                   	ret    
  801f14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f18:	8b 44 24 10          	mov    0x10(%esp),%eax
  801f1c:	be 20 00 00 00       	mov    $0x20,%esi
  801f21:	89 e9                	mov    %ebp,%ecx
  801f23:	29 ee                	sub    %ebp,%esi
  801f25:	d3 e2                	shl    %cl,%edx
  801f27:	89 f1                	mov    %esi,%ecx
  801f29:	d3 e8                	shr    %cl,%eax
  801f2b:	89 e9                	mov    %ebp,%ecx
  801f2d:	09 d0                	or     %edx,%eax
  801f2f:	89 fa                	mov    %edi,%edx
  801f31:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f35:	8b 44 24 10          	mov    0x10(%esp),%eax
  801f39:	d3 e0                	shl    %cl,%eax
  801f3b:	89 f1                	mov    %esi,%ecx
  801f3d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801f41:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801f45:	d3 ea                	shr    %cl,%edx
  801f47:	89 e9                	mov    %ebp,%ecx
  801f49:	d3 e7                	shl    %cl,%edi
  801f4b:	89 f1                	mov    %esi,%ecx
  801f4d:	d3 e8                	shr    %cl,%eax
  801f4f:	89 e9                	mov    %ebp,%ecx
  801f51:	09 f8                	or     %edi,%eax
  801f53:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801f57:	f7 74 24 0c          	divl   0xc(%esp)
  801f5b:	d3 e7                	shl    %cl,%edi
  801f5d:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801f61:	89 d7                	mov    %edx,%edi
  801f63:	f7 64 24 10          	mull   0x10(%esp)
  801f67:	39 d7                	cmp    %edx,%edi
  801f69:	89 c1                	mov    %eax,%ecx
  801f6b:	89 54 24 14          	mov    %edx,0x14(%esp)
  801f6f:	72 3b                	jb     801fac <__umoddi3+0x16c>
  801f71:	39 44 24 18          	cmp    %eax,0x18(%esp)
  801f75:	72 31                	jb     801fa8 <__umoddi3+0x168>
  801f77:	8b 44 24 18          	mov    0x18(%esp),%eax
  801f7b:	29 c8                	sub    %ecx,%eax
  801f7d:	19 d7                	sbb    %edx,%edi
  801f7f:	89 e9                	mov    %ebp,%ecx
  801f81:	89 fa                	mov    %edi,%edx
  801f83:	d3 e8                	shr    %cl,%eax
  801f85:	89 f1                	mov    %esi,%ecx
  801f87:	d3 e2                	shl    %cl,%edx
  801f89:	89 e9                	mov    %ebp,%ecx
  801f8b:	09 d0                	or     %edx,%eax
  801f8d:	89 fa                	mov    %edi,%edx
  801f8f:	d3 ea                	shr    %cl,%edx
  801f91:	8b 74 24 20          	mov    0x20(%esp),%esi
  801f95:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801f99:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801f9d:	83 c4 2c             	add    $0x2c,%esp
  801fa0:	c3                   	ret    
  801fa1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fa8:	39 d7                	cmp    %edx,%edi
  801faa:	75 cb                	jne    801f77 <__umoddi3+0x137>
  801fac:	8b 54 24 14          	mov    0x14(%esp),%edx
  801fb0:	89 c1                	mov    %eax,%ecx
  801fb2:	2b 4c 24 10          	sub    0x10(%esp),%ecx
  801fb6:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  801fba:	eb bb                	jmp    801f77 <__umoddi3+0x137>
  801fbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fc0:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801fc4:	0f 82 e8 fe ff ff    	jb     801eb2 <__umoddi3+0x72>
  801fca:	e9 f3 fe ff ff       	jmp    801ec2 <__umoddi3+0x82>
