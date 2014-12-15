
obj/user/pingpong.debug:     file format elf32-i386


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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
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
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003d:	e8 4e 11 00 00       	call   801190 <fork>
  800042:	89 c3                	mov    %eax,%ebx
  800044:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800047:	85 c0                	test   %eax,%eax
  800049:	74 3c                	je     800087 <umain+0x53>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004b:	e8 17 0d 00 00       	call   800d67 <sys_getenvid>
  800050:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800054:	89 44 24 04          	mov    %eax,0x4(%esp)
  800058:	c7 04 24 20 20 80 00 	movl   $0x802020,(%esp)
  80005f:	e8 a3 01 00 00       	call   800207 <cprintf>
		ipc_send(who, 0, 0, 0);
  800064:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80006b:	00 
  80006c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800073:	00 
  800074:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80007b:	00 
  80007c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80007f:	89 04 24             	mov    %eax,(%esp)
  800082:	e8 f9 12 00 00       	call   801380 <ipc_send>
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  800087:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80008a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800091:	00 
  800092:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800099:	00 
  80009a:	89 34 24             	mov    %esi,(%esp)
  80009d:	e8 86 12 00 00       	call   801328 <ipc_recv>
  8000a2:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  8000a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8000a7:	e8 bb 0c 00 00       	call   800d67 <sys_getenvid>
  8000ac:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8000b0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b8:	c7 04 24 36 20 80 00 	movl   $0x802036,(%esp)
  8000bf:	e8 43 01 00 00       	call   800207 <cprintf>
		if (i == 10)
  8000c4:	83 fb 0a             	cmp    $0xa,%ebx
  8000c7:	74 27                	je     8000f0 <umain+0xbc>
			return;
		i++;
  8000c9:	83 c3 01             	add    $0x1,%ebx
		ipc_send(who, i, 0, 0);
  8000cc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000d3:	00 
  8000d4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000db:	00 
  8000dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000e3:	89 04 24             	mov    %eax,(%esp)
  8000e6:	e8 95 12 00 00       	call   801380 <ipc_send>
		if (i == 10)
  8000eb:	83 fb 0a             	cmp    $0xa,%ebx
  8000ee:	75 9a                	jne    80008a <umain+0x56>
			return;
	}

}
  8000f0:	83 c4 2c             	add    $0x2c,%esp
  8000f3:	5b                   	pop    %ebx
  8000f4:	5e                   	pop    %esi
  8000f5:	5f                   	pop    %edi
  8000f6:	5d                   	pop    %ebp
  8000f7:	c3                   	ret    

008000f8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	83 ec 18             	sub    $0x18,%esp
  8000fe:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800101:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800104:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800107:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;

	thisenv = &envs[ENVX(sys_getenvid())];
  80010a:	e8 58 0c 00 00       	call   800d67 <sys_getenvid>
  80010f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800114:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800117:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011c:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800121:	85 db                	test   %ebx,%ebx
  800123:	7e 07                	jle    80012c <libmain+0x34>
		binaryname = argv[0];
  800125:	8b 06                	mov    (%esi),%eax
  800127:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80012c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800130:	89 1c 24             	mov    %ebx,(%esp)
  800133:	e8 fc fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800138:	e8 0b 00 00 00       	call   800148 <exit>
}
  80013d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800140:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800143:	89 ec                	mov    %ebp,%esp
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    
  800147:	90                   	nop

00800148 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80014e:	e8 f0 14 00 00       	call   801643 <close_all>
	sys_env_destroy(0);
  800153:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80015a:	e8 a2 0b 00 00       	call   800d01 <sys_env_destroy>
}
  80015f:	c9                   	leave  
  800160:	c3                   	ret    
  800161:	66 90                	xchg   %ax,%ax
  800163:	90                   	nop

00800164 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	53                   	push   %ebx
  800168:	83 ec 14             	sub    $0x14,%esp
  80016b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80016e:	8b 03                	mov    (%ebx),%eax
  800170:	8b 55 08             	mov    0x8(%ebp),%edx
  800173:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800177:	83 c0 01             	add    $0x1,%eax
  80017a:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80017c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800181:	75 19                	jne    80019c <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800183:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80018a:	00 
  80018b:	8d 43 08             	lea    0x8(%ebx),%eax
  80018e:	89 04 24             	mov    %eax,(%esp)
  800191:	e8 fa 0a 00 00       	call   800c90 <sys_cputs>
		b->idx = 0;
  800196:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80019c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001a0:	83 c4 14             	add    $0x14,%esp
  8001a3:	5b                   	pop    %ebx
  8001a4:	5d                   	pop    %ebp
  8001a5:	c3                   	ret    

008001a6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001af:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b6:	00 00 00 
	b.cnt = 0;
  8001b9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001c6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8001cd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001d1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001db:	c7 04 24 64 01 80 00 	movl   $0x800164,(%esp)
  8001e2:	e8 bb 01 00 00       	call   8003a2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e7:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f7:	89 04 24             	mov    %eax,(%esp)
  8001fa:	e8 91 0a 00 00       	call   800c90 <sys_cputs>

	return b.cnt;
}
  8001ff:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800205:	c9                   	leave  
  800206:	c3                   	ret    

00800207 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800207:	55                   	push   %ebp
  800208:	89 e5                	mov    %esp,%ebp
  80020a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80020d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800210:	89 44 24 04          	mov    %eax,0x4(%esp)
  800214:	8b 45 08             	mov    0x8(%ebp),%eax
  800217:	89 04 24             	mov    %eax,(%esp)
  80021a:	e8 87 ff ff ff       	call   8001a6 <vcprintf>
	va_end(ap);

	return cnt;
}
  80021f:	c9                   	leave  
  800220:	c3                   	ret    
  800221:	66 90                	xchg   %ax,%ax
  800223:	66 90                	xchg   %ax,%ax
  800225:	66 90                	xchg   %ax,%ax
  800227:	66 90                	xchg   %ax,%ax
  800229:	66 90                	xchg   %ax,%ax
  80022b:	66 90                	xchg   %ax,%ax
  80022d:	66 90                	xchg   %ax,%ax
  80022f:	90                   	nop

00800230 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800230:	55                   	push   %ebp
  800231:	89 e5                	mov    %esp,%ebp
  800233:	57                   	push   %edi
  800234:	56                   	push   %esi
  800235:	53                   	push   %ebx
  800236:	83 ec 4c             	sub    $0x4c,%esp
  800239:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80023c:	89 d7                	mov    %edx,%edi
  80023e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800241:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800244:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800247:	89 5d dc             	mov    %ebx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80024a:	b8 00 00 00 00       	mov    $0x0,%eax
  80024f:	39 d8                	cmp    %ebx,%eax
  800251:	72 17                	jb     80026a <printnum+0x3a>
  800253:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800256:	39 5d 10             	cmp    %ebx,0x10(%ebp)
  800259:	76 0f                	jbe    80026a <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80025b:	8b 75 14             	mov    0x14(%ebp),%esi
  80025e:	83 ee 01             	sub    $0x1,%esi
  800261:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800264:	85 f6                	test   %esi,%esi
  800266:	7f 63                	jg     8002cb <printnum+0x9b>
  800268:	eb 75                	jmp    8002df <printnum+0xaf>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80026a:	8b 5d 18             	mov    0x18(%ebp),%ebx
  80026d:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800271:	8b 45 14             	mov    0x14(%ebp),%eax
  800274:	83 e8 01             	sub    $0x1,%eax
  800277:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80027b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80027e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800282:	8b 44 24 08          	mov    0x8(%esp),%eax
  800286:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80028a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80028d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800290:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800297:	00 
  800298:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  80029b:	89 1c 24             	mov    %ebx,(%esp)
  80029e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002a1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002a5:	e8 86 1a 00 00       	call   801d30 <__udivdi3>
  8002aa:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8002ad:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8002b0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002b4:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002b8:	89 04 24             	mov    %eax,(%esp)
  8002bb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002bf:	89 fa                	mov    %edi,%edx
  8002c1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002c4:	e8 67 ff ff ff       	call   800230 <printnum>
  8002c9:	eb 14                	jmp    8002df <printnum+0xaf>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002cb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002cf:	8b 45 18             	mov    0x18(%ebp),%eax
  8002d2:	89 04 24             	mov    %eax,(%esp)
  8002d5:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002d7:	83 ee 01             	sub    $0x1,%esi
  8002da:	75 ef                	jne    8002cb <printnum+0x9b>
  8002dc:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002df:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002e3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002e7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002ea:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002ee:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002f5:	00 
  8002f6:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8002f9:	89 1c 24             	mov    %ebx,(%esp)
  8002fc:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002ff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800303:	e8 78 1b 00 00       	call   801e80 <__umoddi3>
  800308:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80030c:	0f be 80 53 20 80 00 	movsbl 0x802053(%eax),%eax
  800313:	89 04 24             	mov    %eax,(%esp)
  800316:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800319:	ff d0                	call   *%eax
}
  80031b:	83 c4 4c             	add    $0x4c,%esp
  80031e:	5b                   	pop    %ebx
  80031f:	5e                   	pop    %esi
  800320:	5f                   	pop    %edi
  800321:	5d                   	pop    %ebp
  800322:	c3                   	ret    

00800323 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800323:	55                   	push   %ebp
  800324:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800326:	83 fa 01             	cmp    $0x1,%edx
  800329:	7e 0e                	jle    800339 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80032b:	8b 10                	mov    (%eax),%edx
  80032d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800330:	89 08                	mov    %ecx,(%eax)
  800332:	8b 02                	mov    (%edx),%eax
  800334:	8b 52 04             	mov    0x4(%edx),%edx
  800337:	eb 22                	jmp    80035b <getuint+0x38>
	else if (lflag)
  800339:	85 d2                	test   %edx,%edx
  80033b:	74 10                	je     80034d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80033d:	8b 10                	mov    (%eax),%edx
  80033f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800342:	89 08                	mov    %ecx,(%eax)
  800344:	8b 02                	mov    (%edx),%eax
  800346:	ba 00 00 00 00       	mov    $0x0,%edx
  80034b:	eb 0e                	jmp    80035b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80034d:	8b 10                	mov    (%eax),%edx
  80034f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800352:	89 08                	mov    %ecx,(%eax)
  800354:	8b 02                	mov    (%edx),%eax
  800356:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80035b:	5d                   	pop    %ebp
  80035c:	c3                   	ret    

0080035d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80035d:	55                   	push   %ebp
  80035e:	89 e5                	mov    %esp,%ebp
  800360:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800363:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800367:	8b 10                	mov    (%eax),%edx
  800369:	3b 50 04             	cmp    0x4(%eax),%edx
  80036c:	73 0a                	jae    800378 <sprintputch+0x1b>
		*b->buf++ = ch;
  80036e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800371:	88 0a                	mov    %cl,(%edx)
  800373:	83 c2 01             	add    $0x1,%edx
  800376:	89 10                	mov    %edx,(%eax)
}
  800378:	5d                   	pop    %ebp
  800379:	c3                   	ret    

0080037a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80037a:	55                   	push   %ebp
  80037b:	89 e5                	mov    %esp,%ebp
  80037d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800380:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800383:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800387:	8b 45 10             	mov    0x10(%ebp),%eax
  80038a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80038e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800391:	89 44 24 04          	mov    %eax,0x4(%esp)
  800395:	8b 45 08             	mov    0x8(%ebp),%eax
  800398:	89 04 24             	mov    %eax,(%esp)
  80039b:	e8 02 00 00 00       	call   8003a2 <vprintfmt>
	va_end(ap);
}
  8003a0:	c9                   	leave  
  8003a1:	c3                   	ret    

008003a2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003a2:	55                   	push   %ebp
  8003a3:	89 e5                	mov    %esp,%ebp
  8003a5:	57                   	push   %edi
  8003a6:	56                   	push   %esi
  8003a7:	53                   	push   %ebx
  8003a8:	83 ec 4c             	sub    $0x4c,%esp
  8003ab:	8b 75 08             	mov    0x8(%ebp),%esi
  8003ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003b1:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003b4:	eb 11                	jmp    8003c7 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003b6:	85 c0                	test   %eax,%eax
  8003b8:	0f 84 db 03 00 00    	je     800799 <vprintfmt+0x3f7>
				return;
			putch(ch, putdat);
  8003be:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003c2:	89 04 24             	mov    %eax,(%esp)
  8003c5:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003c7:	0f b6 07             	movzbl (%edi),%eax
  8003ca:	83 c7 01             	add    $0x1,%edi
  8003cd:	83 f8 25             	cmp    $0x25,%eax
  8003d0:	75 e4                	jne    8003b6 <vprintfmt+0x14>
  8003d2:	c6 45 e4 20          	movb   $0x20,-0x1c(%ebp)
  8003d6:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8003dd:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8003e4:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f0:	eb 2b                	jmp    80041d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f2:	8b 7d e0             	mov    -0x20(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003f5:	c6 45 e4 2d          	movb   $0x2d,-0x1c(%ebp)
  8003f9:	eb 22                	jmp    80041d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fb:	8b 7d e0             	mov    -0x20(%ebp),%edi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003fe:	c6 45 e4 30          	movb   $0x30,-0x1c(%ebp)
  800402:	eb 19                	jmp    80041d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800404:	8b 7d e0             	mov    -0x20(%ebp),%edi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800407:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80040e:	eb 0d                	jmp    80041d <vprintfmt+0x7b>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800410:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800413:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800416:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041d:	0f b6 0f             	movzbl (%edi),%ecx
  800420:	8d 47 01             	lea    0x1(%edi),%eax
  800423:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800426:	0f b6 07             	movzbl (%edi),%eax
  800429:	83 e8 23             	sub    $0x23,%eax
  80042c:	3c 55                	cmp    $0x55,%al
  80042e:	0f 87 40 03 00 00    	ja     800774 <vprintfmt+0x3d2>
  800434:	0f b6 c0             	movzbl %al,%eax
  800437:	ff 24 85 a0 21 80 00 	jmp    *0x8021a0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80043e:	83 e9 30             	sub    $0x30,%ecx
  800441:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				ch = *fmt;
  800444:	0f be 47 01          	movsbl 0x1(%edi),%eax
				if (ch < '0' || ch > '9')
  800448:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80044b:	83 f9 09             	cmp    $0x9,%ecx
  80044e:	77 57                	ja     8004a7 <vprintfmt+0x105>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800450:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800453:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800456:	8b 55 dc             	mov    -0x24(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800459:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80045c:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80045f:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800463:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  800466:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800469:	83 f9 09             	cmp    $0x9,%ecx
  80046c:	76 eb                	jbe    800459 <vprintfmt+0xb7>
  80046e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800471:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800474:	eb 34                	jmp    8004aa <vprintfmt+0x108>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800476:	8b 45 14             	mov    0x14(%ebp),%eax
  800479:	8d 48 04             	lea    0x4(%eax),%ecx
  80047c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80047f:	8b 00                	mov    (%eax),%eax
  800481:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800484:	8b 7d e0             	mov    -0x20(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800487:	eb 21                	jmp    8004aa <vprintfmt+0x108>

		case '.':
			if (width < 0)
  800489:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80048d:	0f 88 71 ff ff ff    	js     800404 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800493:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800496:	eb 85                	jmp    80041d <vprintfmt+0x7b>
  800498:	8b 7d e0             	mov    -0x20(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80049b:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  8004a2:	e9 76 ff ff ff       	jmp    80041d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a7:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8004aa:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004ae:	0f 89 69 ff ff ff    	jns    80041d <vprintfmt+0x7b>
  8004b4:	e9 57 ff ff ff       	jmp    800410 <vprintfmt+0x6e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004b9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bc:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004bf:	e9 59 ff ff ff       	jmp    80041d <vprintfmt+0x7b>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c7:	8d 50 04             	lea    0x4(%eax),%edx
  8004ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8004cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004d1:	8b 00                	mov    (%eax),%eax
  8004d3:	89 04 24             	mov    %eax,(%esp)
  8004d6:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d8:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004db:	e9 e7 fe ff ff       	jmp    8003c7 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e3:	8d 50 04             	lea    0x4(%eax),%edx
  8004e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e9:	8b 00                	mov    (%eax),%eax
  8004eb:	89 c2                	mov    %eax,%edx
  8004ed:	c1 fa 1f             	sar    $0x1f,%edx
  8004f0:	31 d0                	xor    %edx,%eax
  8004f2:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004f4:	83 f8 0f             	cmp    $0xf,%eax
  8004f7:	7f 0b                	jg     800504 <vprintfmt+0x162>
  8004f9:	8b 14 85 00 23 80 00 	mov    0x802300(,%eax,4),%edx
  800500:	85 d2                	test   %edx,%edx
  800502:	75 20                	jne    800524 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  800504:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800508:	c7 44 24 08 6b 20 80 	movl   $0x80206b,0x8(%esp)
  80050f:	00 
  800510:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800514:	89 34 24             	mov    %esi,(%esp)
  800517:	e8 5e fe ff ff       	call   80037a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051c:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80051f:	e9 a3 fe ff ff       	jmp    8003c7 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800524:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800528:	c7 44 24 08 74 20 80 	movl   $0x802074,0x8(%esp)
  80052f:	00 
  800530:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800534:	89 34 24             	mov    %esi,(%esp)
  800537:	e8 3e fe ff ff       	call   80037a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053c:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80053f:	e9 83 fe ff ff       	jmp    8003c7 <vprintfmt+0x25>
  800544:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800547:	8b 7d d8             	mov    -0x28(%ebp),%edi
  80054a:	89 7d cc             	mov    %edi,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80054d:	8b 45 14             	mov    0x14(%ebp),%eax
  800550:	8d 50 04             	lea    0x4(%eax),%edx
  800553:	89 55 14             	mov    %edx,0x14(%ebp)
  800556:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800558:	85 ff                	test   %edi,%edi
  80055a:	b8 64 20 80 00       	mov    $0x802064,%eax
  80055f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800562:	80 7d e4 2d          	cmpb   $0x2d,-0x1c(%ebp)
  800566:	74 06                	je     80056e <vprintfmt+0x1cc>
  800568:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80056c:	7f 16                	jg     800584 <vprintfmt+0x1e2>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80056e:	0f b6 17             	movzbl (%edi),%edx
  800571:	0f be c2             	movsbl %dl,%eax
  800574:	83 c7 01             	add    $0x1,%edi
  800577:	85 c0                	test   %eax,%eax
  800579:	0f 85 9f 00 00 00    	jne    80061e <vprintfmt+0x27c>
  80057f:	e9 8b 00 00 00       	jmp    80060f <vprintfmt+0x26d>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800584:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800588:	89 3c 24             	mov    %edi,(%esp)
  80058b:	e8 c2 02 00 00       	call   800852 <strnlen>
  800590:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800593:	29 c2                	sub    %eax,%edx
  800595:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800598:	85 d2                	test   %edx,%edx
  80059a:	7e d2                	jle    80056e <vprintfmt+0x1cc>
					putch(padc, putdat);
  80059c:	0f be 4d e4          	movsbl -0x1c(%ebp),%ecx
  8005a0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8005a3:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8005a6:	89 d7                	mov    %edx,%edi
  8005a8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005af:	89 04 24             	mov    %eax,(%esp)
  8005b2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b4:	83 ef 01             	sub    $0x1,%edi
  8005b7:	75 ef                	jne    8005a8 <vprintfmt+0x206>
  8005b9:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8005bc:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005bf:	eb ad                	jmp    80056e <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005c1:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8005c5:	74 20                	je     8005e7 <vprintfmt+0x245>
  8005c7:	0f be d2             	movsbl %dl,%edx
  8005ca:	83 ea 20             	sub    $0x20,%edx
  8005cd:	83 fa 5e             	cmp    $0x5e,%edx
  8005d0:	76 15                	jbe    8005e7 <vprintfmt+0x245>
					putch('?', putdat);
  8005d2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005d5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005d9:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005e0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005e3:	ff d1                	call   *%ecx
  8005e5:	eb 0f                	jmp    8005f6 <vprintfmt+0x254>
				else
					putch(ch, putdat);
  8005e7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005ea:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005ee:	89 04 24             	mov    %eax,(%esp)
  8005f1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005f4:	ff d1                	call   *%ecx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005f6:	83 eb 01             	sub    $0x1,%ebx
  8005f9:	0f b6 17             	movzbl (%edi),%edx
  8005fc:	0f be c2             	movsbl %dl,%eax
  8005ff:	83 c7 01             	add    $0x1,%edi
  800602:	85 c0                	test   %eax,%eax
  800604:	75 24                	jne    80062a <vprintfmt+0x288>
  800606:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800609:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80060c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060f:	8b 7d e0             	mov    -0x20(%ebp),%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800612:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800616:	0f 8e ab fd ff ff    	jle    8003c7 <vprintfmt+0x25>
  80061c:	eb 20                	jmp    80063e <vprintfmt+0x29c>
  80061e:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800621:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800624:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  800627:	8b 5d d8             	mov    -0x28(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80062a:	85 f6                	test   %esi,%esi
  80062c:	78 93                	js     8005c1 <vprintfmt+0x21f>
  80062e:	83 ee 01             	sub    $0x1,%esi
  800631:	79 8e                	jns    8005c1 <vprintfmt+0x21f>
  800633:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800636:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800639:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80063c:	eb d1                	jmp    80060f <vprintfmt+0x26d>
  80063e:	8b 7d d8             	mov    -0x28(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800641:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800645:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80064c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80064e:	83 ef 01             	sub    $0x1,%edi
  800651:	75 ee                	jne    800641 <vprintfmt+0x29f>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800653:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800656:	e9 6c fd ff ff       	jmp    8003c7 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80065b:	83 fa 01             	cmp    $0x1,%edx
  80065e:	66 90                	xchg   %ax,%ax
  800660:	7e 16                	jle    800678 <vprintfmt+0x2d6>
		return va_arg(*ap, long long);
  800662:	8b 45 14             	mov    0x14(%ebp),%eax
  800665:	8d 50 08             	lea    0x8(%eax),%edx
  800668:	89 55 14             	mov    %edx,0x14(%ebp)
  80066b:	8b 10                	mov    (%eax),%edx
  80066d:	8b 48 04             	mov    0x4(%eax),%ecx
  800670:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800673:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800676:	eb 32                	jmp    8006aa <vprintfmt+0x308>
	else if (lflag)
  800678:	85 d2                	test   %edx,%edx
  80067a:	74 18                	je     800694 <vprintfmt+0x2f2>
		return va_arg(*ap, long);
  80067c:	8b 45 14             	mov    0x14(%ebp),%eax
  80067f:	8d 50 04             	lea    0x4(%eax),%edx
  800682:	89 55 14             	mov    %edx,0x14(%ebp)
  800685:	8b 00                	mov    (%eax),%eax
  800687:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80068a:	89 c1                	mov    %eax,%ecx
  80068c:	c1 f9 1f             	sar    $0x1f,%ecx
  80068f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800692:	eb 16                	jmp    8006aa <vprintfmt+0x308>
	else
		return va_arg(*ap, int);
  800694:	8b 45 14             	mov    0x14(%ebp),%eax
  800697:	8d 50 04             	lea    0x4(%eax),%edx
  80069a:	89 55 14             	mov    %edx,0x14(%ebp)
  80069d:	8b 00                	mov    (%eax),%eax
  80069f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006a2:	89 c7                	mov    %eax,%edi
  8006a4:	c1 ff 1f             	sar    $0x1f,%edi
  8006a7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006aa:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8006ad:	8b 55 d4             	mov    -0x2c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006b0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006b5:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8006b9:	79 7d                	jns    800738 <vprintfmt+0x396>
				putch('-', putdat);
  8006bb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006bf:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006c6:	ff d6                	call   *%esi
				num = -(long long) num;
  8006c8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8006cb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8006ce:	f7 d8                	neg    %eax
  8006d0:	83 d2 00             	adc    $0x0,%edx
  8006d3:	f7 da                	neg    %edx
			}
			base = 10;
  8006d5:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006da:	eb 5c                	jmp    800738 <vprintfmt+0x396>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006dc:	8d 45 14             	lea    0x14(%ebp),%eax
  8006df:	e8 3f fc ff ff       	call   800323 <getuint>
			base = 10;
  8006e4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006e9:	eb 4d                	jmp    800738 <vprintfmt+0x396>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006eb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ee:	e8 30 fc ff ff       	call   800323 <getuint>
			base = 8;
  8006f3:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8006f8:	eb 3e                	jmp    800738 <vprintfmt+0x396>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8006fa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006fe:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800705:	ff d6                	call   *%esi
			putch('x', putdat);
  800707:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80070b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800712:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800714:	8b 45 14             	mov    0x14(%ebp),%eax
  800717:	8d 50 04             	lea    0x4(%eax),%edx
  80071a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80071d:	8b 00                	mov    (%eax),%eax
  80071f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800724:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800729:	eb 0d                	jmp    800738 <vprintfmt+0x396>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80072b:	8d 45 14             	lea    0x14(%ebp),%eax
  80072e:	e8 f0 fb ff ff       	call   800323 <getuint>
			base = 16;
  800733:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800738:	0f be 7d e4          	movsbl -0x1c(%ebp),%edi
  80073c:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800740:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800743:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800747:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80074b:	89 04 24             	mov    %eax,(%esp)
  80074e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800752:	89 da                	mov    %ebx,%edx
  800754:	89 f0                	mov    %esi,%eax
  800756:	e8 d5 fa ff ff       	call   800230 <printnum>
			break;
  80075b:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80075e:	e9 64 fc ff ff       	jmp    8003c7 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800763:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800767:	89 0c 24             	mov    %ecx,(%esp)
  80076a:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80076c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80076f:	e9 53 fc ff ff       	jmp    8003c7 <vprintfmt+0x25>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800774:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800778:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80077f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800781:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800785:	0f 84 3c fc ff ff    	je     8003c7 <vprintfmt+0x25>
  80078b:	83 ef 01             	sub    $0x1,%edi
  80078e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800792:	75 f7                	jne    80078b <vprintfmt+0x3e9>
  800794:	e9 2e fc ff ff       	jmp    8003c7 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800799:	83 c4 4c             	add    $0x4c,%esp
  80079c:	5b                   	pop    %ebx
  80079d:	5e                   	pop    %esi
  80079e:	5f                   	pop    %edi
  80079f:	5d                   	pop    %ebp
  8007a0:	c3                   	ret    

008007a1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007a1:	55                   	push   %ebp
  8007a2:	89 e5                	mov    %esp,%ebp
  8007a4:	83 ec 28             	sub    $0x28,%esp
  8007a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007aa:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007ad:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007b0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007b4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007b7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007be:	85 d2                	test   %edx,%edx
  8007c0:	7e 30                	jle    8007f2 <vsnprintf+0x51>
  8007c2:	85 c0                	test   %eax,%eax
  8007c4:	74 2c                	je     8007f2 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007cd:	8b 45 10             	mov    0x10(%ebp),%eax
  8007d0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007d4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007db:	c7 04 24 5d 03 80 00 	movl   $0x80035d,(%esp)
  8007e2:	e8 bb fb ff ff       	call   8003a2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007ea:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007f0:	eb 05                	jmp    8007f7 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007f2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007f7:	c9                   	leave  
  8007f8:	c3                   	ret    

008007f9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007f9:	55                   	push   %ebp
  8007fa:	89 e5                	mov    %esp,%ebp
  8007fc:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007ff:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800802:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800806:	8b 45 10             	mov    0x10(%ebp),%eax
  800809:	89 44 24 08          	mov    %eax,0x8(%esp)
  80080d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800810:	89 44 24 04          	mov    %eax,0x4(%esp)
  800814:	8b 45 08             	mov    0x8(%ebp),%eax
  800817:	89 04 24             	mov    %eax,(%esp)
  80081a:	e8 82 ff ff ff       	call   8007a1 <vsnprintf>
	va_end(ap);

	return rc;
}
  80081f:	c9                   	leave  
  800820:	c3                   	ret    
  800821:	66 90                	xchg   %ax,%ax
  800823:	66 90                	xchg   %ax,%ax
  800825:	66 90                	xchg   %ax,%ax
  800827:	66 90                	xchg   %ax,%ax
  800829:	66 90                	xchg   %ax,%ax
  80082b:	66 90                	xchg   %ax,%ax
  80082d:	66 90                	xchg   %ax,%ax
  80082f:	90                   	nop

00800830 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
  800833:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800836:	80 3a 00             	cmpb   $0x0,(%edx)
  800839:	74 10                	je     80084b <strlen+0x1b>
  80083b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800840:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800843:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800847:	75 f7                	jne    800840 <strlen+0x10>
  800849:	eb 05                	jmp    800850 <strlen+0x20>
  80084b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800850:	5d                   	pop    %ebp
  800851:	c3                   	ret    

00800852 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	53                   	push   %ebx
  800856:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800859:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80085c:	85 c9                	test   %ecx,%ecx
  80085e:	74 1c                	je     80087c <strnlen+0x2a>
  800860:	80 3b 00             	cmpb   $0x0,(%ebx)
  800863:	74 1e                	je     800883 <strnlen+0x31>
  800865:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  80086a:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80086c:	39 ca                	cmp    %ecx,%edx
  80086e:	74 18                	je     800888 <strnlen+0x36>
  800870:	83 c2 01             	add    $0x1,%edx
  800873:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800878:	75 f0                	jne    80086a <strnlen+0x18>
  80087a:	eb 0c                	jmp    800888 <strnlen+0x36>
  80087c:	b8 00 00 00 00       	mov    $0x0,%eax
  800881:	eb 05                	jmp    800888 <strnlen+0x36>
  800883:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800888:	5b                   	pop    %ebx
  800889:	5d                   	pop    %ebp
  80088a:	c3                   	ret    

0080088b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80088b:	55                   	push   %ebp
  80088c:	89 e5                	mov    %esp,%ebp
  80088e:	53                   	push   %ebx
  80088f:	8b 45 08             	mov    0x8(%ebp),%eax
  800892:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800895:	89 c2                	mov    %eax,%edx
  800897:	0f b6 19             	movzbl (%ecx),%ebx
  80089a:	88 1a                	mov    %bl,(%edx)
  80089c:	83 c2 01             	add    $0x1,%edx
  80089f:	83 c1 01             	add    $0x1,%ecx
  8008a2:	84 db                	test   %bl,%bl
  8008a4:	75 f1                	jne    800897 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008a6:	5b                   	pop    %ebx
  8008a7:	5d                   	pop    %ebp
  8008a8:	c3                   	ret    

008008a9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008a9:	55                   	push   %ebp
  8008aa:	89 e5                	mov    %esp,%ebp
  8008ac:	53                   	push   %ebx
  8008ad:	83 ec 08             	sub    $0x8,%esp
  8008b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008b3:	89 1c 24             	mov    %ebx,(%esp)
  8008b6:	e8 75 ff ff ff       	call   800830 <strlen>
	strcpy(dst + len, src);
  8008bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008be:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008c2:	01 d8                	add    %ebx,%eax
  8008c4:	89 04 24             	mov    %eax,(%esp)
  8008c7:	e8 bf ff ff ff       	call   80088b <strcpy>
	return dst;
}
  8008cc:	89 d8                	mov    %ebx,%eax
  8008ce:	83 c4 08             	add    $0x8,%esp
  8008d1:	5b                   	pop    %ebx
  8008d2:	5d                   	pop    %ebp
  8008d3:	c3                   	ret    

008008d4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	56                   	push   %esi
  8008d8:	53                   	push   %ebx
  8008d9:	8b 75 08             	mov    0x8(%ebp),%esi
  8008dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008df:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008e2:	85 db                	test   %ebx,%ebx
  8008e4:	74 16                	je     8008fc <strncpy+0x28>
	strcpy(dst + len, src);
	return dst;
}

char *
strncpy(char *dst, const char *src, size_t size) {
  8008e6:	01 f3                	add    %esi,%ebx
  8008e8:	89 f1                	mov    %esi,%ecx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  8008ea:	0f b6 02             	movzbl (%edx),%eax
  8008ed:	88 01                	mov    %al,(%ecx)
  8008ef:	83 c1 01             	add    $0x1,%ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008f2:	80 3a 01             	cmpb   $0x1,(%edx)
  8008f5:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f8:	39 d9                	cmp    %ebx,%ecx
  8008fa:	75 ee                	jne    8008ea <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008fc:	89 f0                	mov    %esi,%eax
  8008fe:	5b                   	pop    %ebx
  8008ff:	5e                   	pop    %esi
  800900:	5d                   	pop    %ebp
  800901:	c3                   	ret    

00800902 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
  800905:	57                   	push   %edi
  800906:	56                   	push   %esi
  800907:	53                   	push   %ebx
  800908:	8b 7d 08             	mov    0x8(%ebp),%edi
  80090b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80090e:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800911:	89 f8                	mov    %edi,%eax
  800913:	85 f6                	test   %esi,%esi
  800915:	74 33                	je     80094a <strlcpy+0x48>
		while (--size > 0 && *src != '\0')
  800917:	83 fe 01             	cmp    $0x1,%esi
  80091a:	74 25                	je     800941 <strlcpy+0x3f>
  80091c:	0f b6 0b             	movzbl (%ebx),%ecx
  80091f:	84 c9                	test   %cl,%cl
  800921:	74 22                	je     800945 <strlcpy+0x43>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800923:	83 ee 02             	sub    $0x2,%esi
  800926:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80092b:	88 08                	mov    %cl,(%eax)
  80092d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800930:	39 f2                	cmp    %esi,%edx
  800932:	74 13                	je     800947 <strlcpy+0x45>
  800934:	83 c2 01             	add    $0x1,%edx
  800937:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80093b:	84 c9                	test   %cl,%cl
  80093d:	75 ec                	jne    80092b <strlcpy+0x29>
  80093f:	eb 06                	jmp    800947 <strlcpy+0x45>
  800941:	89 f8                	mov    %edi,%eax
  800943:	eb 02                	jmp    800947 <strlcpy+0x45>
  800945:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800947:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80094a:	29 f8                	sub    %edi,%eax
}
  80094c:	5b                   	pop    %ebx
  80094d:	5e                   	pop    %esi
  80094e:	5f                   	pop    %edi
  80094f:	5d                   	pop    %ebp
  800950:	c3                   	ret    

00800951 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800951:	55                   	push   %ebp
  800952:	89 e5                	mov    %esp,%ebp
  800954:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800957:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80095a:	0f b6 01             	movzbl (%ecx),%eax
  80095d:	84 c0                	test   %al,%al
  80095f:	74 15                	je     800976 <strcmp+0x25>
  800961:	3a 02                	cmp    (%edx),%al
  800963:	75 11                	jne    800976 <strcmp+0x25>
		p++, q++;
  800965:	83 c1 01             	add    $0x1,%ecx
  800968:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80096b:	0f b6 01             	movzbl (%ecx),%eax
  80096e:	84 c0                	test   %al,%al
  800970:	74 04                	je     800976 <strcmp+0x25>
  800972:	3a 02                	cmp    (%edx),%al
  800974:	74 ef                	je     800965 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800976:	0f b6 c0             	movzbl %al,%eax
  800979:	0f b6 12             	movzbl (%edx),%edx
  80097c:	29 d0                	sub    %edx,%eax
}
  80097e:	5d                   	pop    %ebp
  80097f:	c3                   	ret    

00800980 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	56                   	push   %esi
  800984:	53                   	push   %ebx
  800985:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800988:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098b:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  80098e:	85 f6                	test   %esi,%esi
  800990:	74 29                	je     8009bb <strncmp+0x3b>
  800992:	0f b6 03             	movzbl (%ebx),%eax
  800995:	84 c0                	test   %al,%al
  800997:	74 30                	je     8009c9 <strncmp+0x49>
  800999:	3a 02                	cmp    (%edx),%al
  80099b:	75 2c                	jne    8009c9 <strncmp+0x49>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}

int
strncmp(const char *p, const char *q, size_t n)
  80099d:	8d 43 01             	lea    0x1(%ebx),%eax
  8009a0:	01 de                	add    %ebx,%esi
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  8009a2:	89 c3                	mov    %eax,%ebx
  8009a4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009a7:	39 f0                	cmp    %esi,%eax
  8009a9:	74 17                	je     8009c2 <strncmp+0x42>
  8009ab:	0f b6 08             	movzbl (%eax),%ecx
  8009ae:	84 c9                	test   %cl,%cl
  8009b0:	74 17                	je     8009c9 <strncmp+0x49>
  8009b2:	83 c0 01             	add    $0x1,%eax
  8009b5:	3a 0a                	cmp    (%edx),%cl
  8009b7:	74 e9                	je     8009a2 <strncmp+0x22>
  8009b9:	eb 0e                	jmp    8009c9 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c0:	eb 0f                	jmp    8009d1 <strncmp+0x51>
  8009c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c7:	eb 08                	jmp    8009d1 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009c9:	0f b6 03             	movzbl (%ebx),%eax
  8009cc:	0f b6 12             	movzbl (%edx),%edx
  8009cf:	29 d0                	sub    %edx,%eax
}
  8009d1:	5b                   	pop    %ebx
  8009d2:	5e                   	pop    %esi
  8009d3:	5d                   	pop    %ebp
  8009d4:	c3                   	ret    

008009d5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009d5:	55                   	push   %ebp
  8009d6:	89 e5                	mov    %esp,%ebp
  8009d8:	53                   	push   %ebx
  8009d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009dc:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  8009df:	0f b6 18             	movzbl (%eax),%ebx
  8009e2:	84 db                	test   %bl,%bl
  8009e4:	74 1d                	je     800a03 <strchr+0x2e>
  8009e6:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  8009e8:	38 d3                	cmp    %dl,%bl
  8009ea:	75 06                	jne    8009f2 <strchr+0x1d>
  8009ec:	eb 1a                	jmp    800a08 <strchr+0x33>
  8009ee:	38 ca                	cmp    %cl,%dl
  8009f0:	74 16                	je     800a08 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009f2:	83 c0 01             	add    $0x1,%eax
  8009f5:	0f b6 10             	movzbl (%eax),%edx
  8009f8:	84 d2                	test   %dl,%dl
  8009fa:	75 f2                	jne    8009ee <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  8009fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800a01:	eb 05                	jmp    800a08 <strchr+0x33>
  800a03:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a08:	5b                   	pop    %ebx
  800a09:	5d                   	pop    %ebp
  800a0a:	c3                   	ret    

00800a0b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	53                   	push   %ebx
  800a0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a12:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800a15:	0f b6 18             	movzbl (%eax),%ebx
  800a18:	84 db                	test   %bl,%bl
  800a1a:	74 16                	je     800a32 <strfind+0x27>
  800a1c:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800a1e:	38 d3                	cmp    %dl,%bl
  800a20:	75 06                	jne    800a28 <strfind+0x1d>
  800a22:	eb 0e                	jmp    800a32 <strfind+0x27>
  800a24:	38 ca                	cmp    %cl,%dl
  800a26:	74 0a                	je     800a32 <strfind+0x27>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a28:	83 c0 01             	add    $0x1,%eax
  800a2b:	0f b6 10             	movzbl (%eax),%edx
  800a2e:	84 d2                	test   %dl,%dl
  800a30:	75 f2                	jne    800a24 <strfind+0x19>
		if (*s == c)
			break;
	return (char *) s;
}
  800a32:	5b                   	pop    %ebx
  800a33:	5d                   	pop    %ebp
  800a34:	c3                   	ret    

00800a35 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a35:	55                   	push   %ebp
  800a36:	89 e5                	mov    %esp,%ebp
  800a38:	83 ec 0c             	sub    $0xc,%esp
  800a3b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800a3e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800a41:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800a44:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a47:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a4a:	85 c9                	test   %ecx,%ecx
  800a4c:	74 36                	je     800a84 <memset+0x4f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a4e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a54:	75 28                	jne    800a7e <memset+0x49>
  800a56:	f6 c1 03             	test   $0x3,%cl
  800a59:	75 23                	jne    800a7e <memset+0x49>
		c &= 0xFF;
  800a5b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a5f:	89 d3                	mov    %edx,%ebx
  800a61:	c1 e3 08             	shl    $0x8,%ebx
  800a64:	89 d6                	mov    %edx,%esi
  800a66:	c1 e6 18             	shl    $0x18,%esi
  800a69:	89 d0                	mov    %edx,%eax
  800a6b:	c1 e0 10             	shl    $0x10,%eax
  800a6e:	09 f0                	or     %esi,%eax
  800a70:	09 c2                	or     %eax,%edx
  800a72:	89 d0                	mov    %edx,%eax
  800a74:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a76:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a79:	fc                   	cld    
  800a7a:	f3 ab                	rep stos %eax,%es:(%edi)
  800a7c:	eb 06                	jmp    800a84 <memset+0x4f>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a81:	fc                   	cld    
  800a82:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");

	return v;
}
  800a84:	89 f8                	mov    %edi,%eax
  800a86:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800a89:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800a8c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800a8f:	89 ec                	mov    %ebp,%esp
  800a91:	5d                   	pop    %ebp
  800a92:	c3                   	ret    

00800a93 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a93:	55                   	push   %ebp
  800a94:	89 e5                	mov    %esp,%ebp
  800a96:	83 ec 08             	sub    $0x8,%esp
  800a99:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800a9c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800a9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800aa8:	39 c6                	cmp    %eax,%esi
  800aaa:	73 36                	jae    800ae2 <memmove+0x4f>
  800aac:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800aaf:	39 d0                	cmp    %edx,%eax
  800ab1:	73 2f                	jae    800ae2 <memmove+0x4f>
		s += n;
		d += n;
  800ab3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ab6:	f6 c2 03             	test   $0x3,%dl
  800ab9:	75 1b                	jne    800ad6 <memmove+0x43>
  800abb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ac1:	75 13                	jne    800ad6 <memmove+0x43>
  800ac3:	f6 c1 03             	test   $0x3,%cl
  800ac6:	75 0e                	jne    800ad6 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ac8:	83 ef 04             	sub    $0x4,%edi
  800acb:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ace:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800ad1:	fd                   	std    
  800ad2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ad4:	eb 09                	jmp    800adf <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ad6:	83 ef 01             	sub    $0x1,%edi
  800ad9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800adc:	fd                   	std    
  800add:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800adf:	fc                   	cld    
  800ae0:	eb 20                	jmp    800b02 <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ae2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ae8:	75 13                	jne    800afd <memmove+0x6a>
  800aea:	a8 03                	test   $0x3,%al
  800aec:	75 0f                	jne    800afd <memmove+0x6a>
  800aee:	f6 c1 03             	test   $0x3,%cl
  800af1:	75 0a                	jne    800afd <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800af3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800af6:	89 c7                	mov    %eax,%edi
  800af8:	fc                   	cld    
  800af9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800afb:	eb 05                	jmp    800b02 <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800afd:	89 c7                	mov    %eax,%edi
  800aff:	fc                   	cld    
  800b00:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b02:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b05:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b08:	89 ec                	mov    %ebp,%esp
  800b0a:	5d                   	pop    %ebp
  800b0b:	c3                   	ret    

00800b0c <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b12:	8b 45 10             	mov    0x10(%ebp),%eax
  800b15:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b19:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b1c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b20:	8b 45 08             	mov    0x8(%ebp),%eax
  800b23:	89 04 24             	mov    %eax,(%esp)
  800b26:	e8 68 ff ff ff       	call   800a93 <memmove>
}
  800b2b:	c9                   	leave  
  800b2c:	c3                   	ret    

00800b2d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b2d:	55                   	push   %ebp
  800b2e:	89 e5                	mov    %esp,%ebp
  800b30:	57                   	push   %edi
  800b31:	56                   	push   %esi
  800b32:	53                   	push   %ebx
  800b33:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b36:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b39:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b3c:	8d 78 ff             	lea    -0x1(%eax),%edi
  800b3f:	85 c0                	test   %eax,%eax
  800b41:	74 36                	je     800b79 <memcmp+0x4c>
		if (*s1 != *s2)
  800b43:	0f b6 03             	movzbl (%ebx),%eax
  800b46:	0f b6 0e             	movzbl (%esi),%ecx
  800b49:	38 c8                	cmp    %cl,%al
  800b4b:	75 17                	jne    800b64 <memcmp+0x37>
  800b4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b52:	eb 1a                	jmp    800b6e <memcmp+0x41>
  800b54:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800b59:	83 c2 01             	add    $0x1,%edx
  800b5c:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800b60:	38 c8                	cmp    %cl,%al
  800b62:	74 0a                	je     800b6e <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800b64:	0f b6 c0             	movzbl %al,%eax
  800b67:	0f b6 c9             	movzbl %cl,%ecx
  800b6a:	29 c8                	sub    %ecx,%eax
  800b6c:	eb 10                	jmp    800b7e <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b6e:	39 fa                	cmp    %edi,%edx
  800b70:	75 e2                	jne    800b54 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b72:	b8 00 00 00 00       	mov    $0x0,%eax
  800b77:	eb 05                	jmp    800b7e <memcmp+0x51>
  800b79:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b7e:	5b                   	pop    %ebx
  800b7f:	5e                   	pop    %esi
  800b80:	5f                   	pop    %edi
  800b81:	5d                   	pop    %ebp
  800b82:	c3                   	ret    

00800b83 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b83:	55                   	push   %ebp
  800b84:	89 e5                	mov    %esp,%ebp
  800b86:	53                   	push   %ebx
  800b87:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800b8d:	89 c2                	mov    %eax,%edx
  800b8f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b92:	39 d0                	cmp    %edx,%eax
  800b94:	73 13                	jae    800ba9 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b96:	89 d9                	mov    %ebx,%ecx
  800b98:	38 18                	cmp    %bl,(%eax)
  800b9a:	75 06                	jne    800ba2 <memfind+0x1f>
  800b9c:	eb 0b                	jmp    800ba9 <memfind+0x26>
  800b9e:	38 08                	cmp    %cl,(%eax)
  800ba0:	74 07                	je     800ba9 <memfind+0x26>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ba2:	83 c0 01             	add    $0x1,%eax
  800ba5:	39 d0                	cmp    %edx,%eax
  800ba7:	75 f5                	jne    800b9e <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ba9:	5b                   	pop    %ebx
  800baa:	5d                   	pop    %ebp
  800bab:	c3                   	ret    

00800bac <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bac:	55                   	push   %ebp
  800bad:	89 e5                	mov    %esp,%ebp
  800baf:	57                   	push   %edi
  800bb0:	56                   	push   %esi
  800bb1:	53                   	push   %ebx
  800bb2:	83 ec 04             	sub    $0x4,%esp
  800bb5:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bbb:	0f b6 02             	movzbl (%edx),%eax
  800bbe:	3c 09                	cmp    $0x9,%al
  800bc0:	74 04                	je     800bc6 <strtol+0x1a>
  800bc2:	3c 20                	cmp    $0x20,%al
  800bc4:	75 0e                	jne    800bd4 <strtol+0x28>
		s++;
  800bc6:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bc9:	0f b6 02             	movzbl (%edx),%eax
  800bcc:	3c 09                	cmp    $0x9,%al
  800bce:	74 f6                	je     800bc6 <strtol+0x1a>
  800bd0:	3c 20                	cmp    $0x20,%al
  800bd2:	74 f2                	je     800bc6 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bd4:	3c 2b                	cmp    $0x2b,%al
  800bd6:	75 0a                	jne    800be2 <strtol+0x36>
		s++;
  800bd8:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bdb:	bf 00 00 00 00       	mov    $0x0,%edi
  800be0:	eb 10                	jmp    800bf2 <strtol+0x46>
  800be2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800be7:	3c 2d                	cmp    $0x2d,%al
  800be9:	75 07                	jne    800bf2 <strtol+0x46>
		s++, neg = 1;
  800beb:	83 c2 01             	add    $0x1,%edx
  800bee:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bf2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bf8:	75 15                	jne    800c0f <strtol+0x63>
  800bfa:	80 3a 30             	cmpb   $0x30,(%edx)
  800bfd:	75 10                	jne    800c0f <strtol+0x63>
  800bff:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c03:	75 0a                	jne    800c0f <strtol+0x63>
		s += 2, base = 16;
  800c05:	83 c2 02             	add    $0x2,%edx
  800c08:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c0d:	eb 10                	jmp    800c1f <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800c0f:	85 db                	test   %ebx,%ebx
  800c11:	75 0c                	jne    800c1f <strtol+0x73>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c13:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c15:	80 3a 30             	cmpb   $0x30,(%edx)
  800c18:	75 05                	jne    800c1f <strtol+0x73>
		s++, base = 8;
  800c1a:	83 c2 01             	add    $0x1,%edx
  800c1d:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800c1f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c24:	89 5d f0             	mov    %ebx,-0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c27:	0f b6 0a             	movzbl (%edx),%ecx
  800c2a:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800c2d:	89 f3                	mov    %esi,%ebx
  800c2f:	80 fb 09             	cmp    $0x9,%bl
  800c32:	77 08                	ja     800c3c <strtol+0x90>
			dig = *s - '0';
  800c34:	0f be c9             	movsbl %cl,%ecx
  800c37:	83 e9 30             	sub    $0x30,%ecx
  800c3a:	eb 22                	jmp    800c5e <strtol+0xb2>
		else if (*s >= 'a' && *s <= 'z')
  800c3c:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800c3f:	89 f3                	mov    %esi,%ebx
  800c41:	80 fb 19             	cmp    $0x19,%bl
  800c44:	77 08                	ja     800c4e <strtol+0xa2>
			dig = *s - 'a' + 10;
  800c46:	0f be c9             	movsbl %cl,%ecx
  800c49:	83 e9 57             	sub    $0x57,%ecx
  800c4c:	eb 10                	jmp    800c5e <strtol+0xb2>
		else if (*s >= 'A' && *s <= 'Z')
  800c4e:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800c51:	89 f3                	mov    %esi,%ebx
  800c53:	80 fb 19             	cmp    $0x19,%bl
  800c56:	77 16                	ja     800c6e <strtol+0xc2>
			dig = *s - 'A' + 10;
  800c58:	0f be c9             	movsbl %cl,%ecx
  800c5b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c5e:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800c61:	7d 0f                	jge    800c72 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800c63:	83 c2 01             	add    $0x1,%edx
  800c66:	0f af 45 f0          	imul   -0x10(%ebp),%eax
  800c6a:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800c6c:	eb b9                	jmp    800c27 <strtol+0x7b>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c6e:	89 c1                	mov    %eax,%ecx
  800c70:	eb 02                	jmp    800c74 <strtol+0xc8>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c72:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c74:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c78:	74 05                	je     800c7f <strtol+0xd3>
		*endptr = (char *) s;
  800c7a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c7d:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c7f:	89 ca                	mov    %ecx,%edx
  800c81:	f7 da                	neg    %edx
  800c83:	85 ff                	test   %edi,%edi
  800c85:	0f 45 c2             	cmovne %edx,%eax
}
  800c88:	83 c4 04             	add    $0x4,%esp
  800c8b:	5b                   	pop    %ebx
  800c8c:	5e                   	pop    %esi
  800c8d:	5f                   	pop    %edi
  800c8e:	5d                   	pop    %ebp
  800c8f:	c3                   	ret    

00800c90 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c90:	55                   	push   %ebp
  800c91:	89 e5                	mov    %esp,%ebp
  800c93:	83 ec 0c             	sub    $0xc,%esp
  800c96:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c99:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c9c:	89 7d fc             	mov    %edi,-0x4(%ebp)
static inline uint32_t

get_cpu_features(void)
{
	uint32_t feature;
	__asm __volatile(" movl $1, %%eax\n\t"
  800c9f:	b8 01 00 00 00       	mov    $0x1,%eax
  800ca4:	0f a2                	cpuid  
  800ca6:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca8:	b8 00 00 00 00       	mov    $0x0,%eax
  800cad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb3:	89 c3                	mov    %eax,%ebx
  800cb5:	89 c7                	mov    %eax,%edi
  800cb7:	89 c6                	mov    %eax,%esi
  800cb9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cbb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cbe:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cc1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cc4:	89 ec                	mov    %ebp,%esp
  800cc6:	5d                   	pop    %ebp
  800cc7:	c3                   	ret    

00800cc8 <sys_cgetc>:

int
sys_cgetc(void)
{
  800cc8:	55                   	push   %ebp
  800cc9:	89 e5                	mov    %esp,%ebp
  800ccb:	83 ec 0c             	sub    $0xc,%esp
  800cce:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cd1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cd4:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800cd7:	b8 01 00 00 00       	mov    $0x1,%eax
  800cdc:	0f a2                	cpuid  
  800cde:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce5:	b8 01 00 00 00       	mov    $0x1,%eax
  800cea:	89 d1                	mov    %edx,%ecx
  800cec:	89 d3                	mov    %edx,%ebx
  800cee:	89 d7                	mov    %edx,%edi
  800cf0:	89 d6                	mov    %edx,%esi
  800cf2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cf4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cf7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cfa:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cfd:	89 ec                	mov    %ebp,%esp
  800cff:	5d                   	pop    %ebp
  800d00:	c3                   	ret    

00800d01 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d01:	55                   	push   %ebp
  800d02:	89 e5                	mov    %esp,%ebp
  800d04:	83 ec 38             	sub    $0x38,%esp
  800d07:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d0a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d0d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d10:	b8 01 00 00 00       	mov    $0x1,%eax
  800d15:	0f a2                	cpuid  
  800d17:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d19:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d1e:	b8 03 00 00 00       	mov    $0x3,%eax
  800d23:	8b 55 08             	mov    0x8(%ebp),%edx
  800d26:	89 cb                	mov    %ecx,%ebx
  800d28:	89 cf                	mov    %ecx,%edi
  800d2a:	89 ce                	mov    %ecx,%esi
  800d2c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d2e:	85 c0                	test   %eax,%eax
  800d30:	7e 28                	jle    800d5a <sys_env_destroy+0x59>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d32:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d36:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800d3d:	00 
  800d3e:	c7 44 24 08 5f 23 80 	movl   $0x80235f,0x8(%esp)
  800d45:	00 
  800d46:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800d4d:	00 
  800d4e:	c7 04 24 7c 23 80 00 	movl   $0x80237c,(%esp)
  800d55:	e8 e6 0e 00 00       	call   801c40 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d5a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d5d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d60:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d63:	89 ec                	mov    %ebp,%esp
  800d65:	5d                   	pop    %ebp
  800d66:	c3                   	ret    

00800d67 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d67:	55                   	push   %ebp
  800d68:	89 e5                	mov    %esp,%ebp
  800d6a:	83 ec 0c             	sub    $0xc,%esp
  800d6d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d70:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d73:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d76:	b8 01 00 00 00       	mov    $0x1,%eax
  800d7b:	0f a2                	cpuid  
  800d7d:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7f:	ba 00 00 00 00       	mov    $0x0,%edx
  800d84:	b8 02 00 00 00       	mov    $0x2,%eax
  800d89:	89 d1                	mov    %edx,%ecx
  800d8b:	89 d3                	mov    %edx,%ebx
  800d8d:	89 d7                	mov    %edx,%edi
  800d8f:	89 d6                	mov    %edx,%esi
  800d91:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d93:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d96:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d99:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d9c:	89 ec                	mov    %ebp,%esp
  800d9e:	5d                   	pop    %ebp
  800d9f:	c3                   	ret    

00800da0 <sys_yield>:

void
sys_yield(void)
{
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	83 ec 0c             	sub    $0xc,%esp
  800da6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800da9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dac:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800daf:	b8 01 00 00 00       	mov    $0x1,%eax
  800db4:	0f a2                	cpuid  
  800db6:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db8:	ba 00 00 00 00       	mov    $0x0,%edx
  800dbd:	b8 0b 00 00 00       	mov    $0xb,%eax
  800dc2:	89 d1                	mov    %edx,%ecx
  800dc4:	89 d3                	mov    %edx,%ebx
  800dc6:	89 d7                	mov    %edx,%edi
  800dc8:	89 d6                	mov    %edx,%esi
  800dca:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800dcc:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dcf:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dd2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dd5:	89 ec                	mov    %ebp,%esp
  800dd7:	5d                   	pop    %ebp
  800dd8:	c3                   	ret    

00800dd9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800dd9:	55                   	push   %ebp
  800dda:	89 e5                	mov    %esp,%ebp
  800ddc:	83 ec 38             	sub    $0x38,%esp
  800ddf:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800de2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800de5:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800de8:	b8 01 00 00 00       	mov    $0x1,%eax
  800ded:	0f a2                	cpuid  
  800def:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df1:	be 00 00 00 00       	mov    $0x0,%esi
  800df6:	b8 04 00 00 00       	mov    $0x4,%eax
  800dfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800e01:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e04:	89 f7                	mov    %esi,%edi
  800e06:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e08:	85 c0                	test   %eax,%eax
  800e0a:	7e 28                	jle    800e34 <sys_page_alloc+0x5b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e10:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800e17:	00 
  800e18:	c7 44 24 08 5f 23 80 	movl   $0x80235f,0x8(%esp)
  800e1f:	00 
  800e20:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800e27:	00 
  800e28:	c7 04 24 7c 23 80 00 	movl   $0x80237c,(%esp)
  800e2f:	e8 0c 0e 00 00       	call   801c40 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e34:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e37:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e3a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e3d:	89 ec                	mov    %ebp,%esp
  800e3f:	5d                   	pop    %ebp
  800e40:	c3                   	ret    

00800e41 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e41:	55                   	push   %ebp
  800e42:	89 e5                	mov    %esp,%ebp
  800e44:	83 ec 38             	sub    $0x38,%esp
  800e47:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e4a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e4d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e50:	b8 01 00 00 00       	mov    $0x1,%eax
  800e55:	0f a2                	cpuid  
  800e57:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e59:	b8 05 00 00 00       	mov    $0x5,%eax
  800e5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e61:	8b 55 08             	mov    0x8(%ebp),%edx
  800e64:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e67:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e6a:	8b 75 18             	mov    0x18(%ebp),%esi
  800e6d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e6f:	85 c0                	test   %eax,%eax
  800e71:	7e 28                	jle    800e9b <sys_page_map+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e73:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e77:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e7e:	00 
  800e7f:	c7 44 24 08 5f 23 80 	movl   $0x80235f,0x8(%esp)
  800e86:	00 
  800e87:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800e8e:	00 
  800e8f:	c7 04 24 7c 23 80 00 	movl   $0x80237c,(%esp)
  800e96:	e8 a5 0d 00 00       	call   801c40 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e9b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e9e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ea1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ea4:	89 ec                	mov    %ebp,%esp
  800ea6:	5d                   	pop    %ebp
  800ea7:	c3                   	ret    

00800ea8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ea8:	55                   	push   %ebp
  800ea9:	89 e5                	mov    %esp,%ebp
  800eab:	83 ec 38             	sub    $0x38,%esp
  800eae:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800eb1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800eb4:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800eb7:	b8 01 00 00 00       	mov    $0x1,%eax
  800ebc:	0f a2                	cpuid  
  800ebe:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ec0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ec5:	b8 06 00 00 00       	mov    $0x6,%eax
  800eca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ecd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed0:	89 df                	mov    %ebx,%edi
  800ed2:	89 de                	mov    %ebx,%esi
  800ed4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ed6:	85 c0                	test   %eax,%eax
  800ed8:	7e 28                	jle    800f02 <sys_page_unmap+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eda:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ede:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800ee5:	00 
  800ee6:	c7 44 24 08 5f 23 80 	movl   $0x80235f,0x8(%esp)
  800eed:	00 
  800eee:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800ef5:	00 
  800ef6:	c7 04 24 7c 23 80 00 	movl   $0x80237c,(%esp)
  800efd:	e8 3e 0d 00 00       	call   801c40 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f02:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f05:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f08:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f0b:	89 ec                	mov    %ebp,%esp
  800f0d:	5d                   	pop    %ebp
  800f0e:	c3                   	ret    

00800f0f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f0f:	55                   	push   %ebp
  800f10:	89 e5                	mov    %esp,%ebp
  800f12:	83 ec 38             	sub    $0x38,%esp
  800f15:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f18:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f1b:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800f1e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f23:	0f a2                	cpuid  
  800f25:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f27:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f2c:	b8 08 00 00 00       	mov    $0x8,%eax
  800f31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f34:	8b 55 08             	mov    0x8(%ebp),%edx
  800f37:	89 df                	mov    %ebx,%edi
  800f39:	89 de                	mov    %ebx,%esi
  800f3b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f3d:	85 c0                	test   %eax,%eax
  800f3f:	7e 28                	jle    800f69 <sys_env_set_status+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f41:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f45:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800f4c:	00 
  800f4d:	c7 44 24 08 5f 23 80 	movl   $0x80235f,0x8(%esp)
  800f54:	00 
  800f55:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800f5c:	00 
  800f5d:	c7 04 24 7c 23 80 00 	movl   $0x80237c,(%esp)
  800f64:	e8 d7 0c 00 00       	call   801c40 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f69:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f6c:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f6f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f72:	89 ec                	mov    %ebp,%esp
  800f74:	5d                   	pop    %ebp
  800f75:	c3                   	ret    

00800f76 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f76:	55                   	push   %ebp
  800f77:	89 e5                	mov    %esp,%ebp
  800f79:	83 ec 38             	sub    $0x38,%esp
  800f7c:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f7f:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f82:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800f85:	b8 01 00 00 00       	mov    $0x1,%eax
  800f8a:	0f a2                	cpuid  
  800f8c:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f8e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f93:	b8 09 00 00 00       	mov    $0x9,%eax
  800f98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f9e:	89 df                	mov    %ebx,%edi
  800fa0:	89 de                	mov    %ebx,%esi
  800fa2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fa4:	85 c0                	test   %eax,%eax
  800fa6:	7e 28                	jle    800fd0 <sys_env_set_trapframe+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fa8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fac:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800fb3:	00 
  800fb4:	c7 44 24 08 5f 23 80 	movl   $0x80235f,0x8(%esp)
  800fbb:	00 
  800fbc:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800fc3:	00 
  800fc4:	c7 04 24 7c 23 80 00 	movl   $0x80237c,(%esp)
  800fcb:	e8 70 0c 00 00       	call   801c40 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800fd0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fd3:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fd6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fd9:	89 ec                	mov    %ebp,%esp
  800fdb:	5d                   	pop    %ebp
  800fdc:	c3                   	ret    

00800fdd <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800fdd:	55                   	push   %ebp
  800fde:	89 e5                	mov    %esp,%ebp
  800fe0:	83 ec 38             	sub    $0x38,%esp
  800fe3:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fe6:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fe9:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800fec:	b8 01 00 00 00       	mov    $0x1,%eax
  800ff1:	0f a2                	cpuid  
  800ff3:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ff5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ffa:	b8 0a 00 00 00       	mov    $0xa,%eax
  800fff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801002:	8b 55 08             	mov    0x8(%ebp),%edx
  801005:	89 df                	mov    %ebx,%edi
  801007:	89 de                	mov    %ebx,%esi
  801009:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80100b:	85 c0                	test   %eax,%eax
  80100d:	7e 28                	jle    801037 <sys_env_set_pgfault_upcall+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80100f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801013:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80101a:	00 
  80101b:	c7 44 24 08 5f 23 80 	movl   $0x80235f,0x8(%esp)
  801022:	00 
  801023:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  80102a:	00 
  80102b:	c7 04 24 7c 23 80 00 	movl   $0x80237c,(%esp)
  801032:	e8 09 0c 00 00       	call   801c40 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801037:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80103a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80103d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801040:	89 ec                	mov    %ebp,%esp
  801042:	5d                   	pop    %ebp
  801043:	c3                   	ret    

00801044 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801044:	55                   	push   %ebp
  801045:	89 e5                	mov    %esp,%ebp
  801047:	83 ec 0c             	sub    $0xc,%esp
  80104a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80104d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801050:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801053:	b8 01 00 00 00       	mov    $0x1,%eax
  801058:	0f a2                	cpuid  
  80105a:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80105c:	be 00 00 00 00       	mov    $0x0,%esi
  801061:	b8 0c 00 00 00       	mov    $0xc,%eax
  801066:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801069:	8b 55 08             	mov    0x8(%ebp),%edx
  80106c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80106f:	8b 7d 14             	mov    0x14(%ebp),%edi
  801072:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801074:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801077:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80107a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80107d:	89 ec                	mov    %ebp,%esp
  80107f:	5d                   	pop    %ebp
  801080:	c3                   	ret    

00801081 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801081:	55                   	push   %ebp
  801082:	89 e5                	mov    %esp,%ebp
  801084:	83 ec 38             	sub    $0x38,%esp
  801087:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80108a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80108d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801090:	b8 01 00 00 00       	mov    $0x1,%eax
  801095:	0f a2                	cpuid  
  801097:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801099:	b9 00 00 00 00       	mov    $0x0,%ecx
  80109e:	b8 0d 00 00 00       	mov    $0xd,%eax
  8010a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a6:	89 cb                	mov    %ecx,%ebx
  8010a8:	89 cf                	mov    %ecx,%edi
  8010aa:	89 ce                	mov    %ecx,%esi
  8010ac:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010ae:	85 c0                	test   %eax,%eax
  8010b0:	7e 28                	jle    8010da <sys_ipc_recv+0x59>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010b2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010b6:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8010bd:	00 
  8010be:	c7 44 24 08 5f 23 80 	movl   $0x80235f,0x8(%esp)
  8010c5:	00 
  8010c6:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  8010cd:	00 
  8010ce:	c7 04 24 7c 23 80 00 	movl   $0x80237c,(%esp)
  8010d5:	e8 66 0b 00 00       	call   801c40 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8010da:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010dd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010e0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010e3:	89 ec                	mov    %ebp,%esp
  8010e5:	5d                   	pop    %ebp
  8010e6:	c3                   	ret    
  8010e7:	90                   	nop

008010e8 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8010e8:	55                   	push   %ebp
  8010e9:	89 e5                	mov    %esp,%ebp
  8010eb:	56                   	push   %esi
  8010ec:	53                   	push   %ebx
  8010ed:	83 ec 20             	sub    $0x20,%esp
  8010f0:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8010f3:	8b 30                	mov    (%eax),%esi
	// Hint:
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	pde_t pde = vpt[PGNUM(addr)];
  8010f5:	89 f2                	mov    %esi,%edx
  8010f7:	c1 ea 0c             	shr    $0xc,%edx
  8010fa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx

	if(!((err & FEC_WR) && (pde &PTE_COW) ))
  801101:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801105:	74 05                	je     80110c <pgfault+0x24>
  801107:	f6 c6 08             	test   $0x8,%dh
  80110a:	75 20                	jne    80112c <pgfault+0x44>
		panic("Unrecoverable page fault at address[0x%x]!\n", addr);
  80110c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801110:	c7 44 24 08 8c 23 80 	movl   $0x80238c,0x8(%esp)
  801117:	00 
  801118:	c7 44 24 04 1f 00 00 	movl   $0x1f,0x4(%esp)
  80111f:	00 
  801120:	c7 04 24 d9 23 80 00 	movl   $0x8023d9,(%esp)
  801127:	e8 14 0b 00 00       	call   801c40 <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	envid_t thisenv_id = sys_getenvid();
  80112c:	e8 36 fc ff ff       	call   800d67 <sys_getenvid>
  801131:	89 c3                	mov    %eax,%ebx
	sys_page_alloc(thisenv_id, PFTEMP, PTE_P|PTE_W|PTE_U);
  801133:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80113a:	00 
  80113b:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801142:	00 
  801143:	89 04 24             	mov    %eax,(%esp)
  801146:	e8 8e fc ff ff       	call   800dd9 <sys_page_alloc>
	memmove((void*)PFTEMP, (void*)ROUNDDOWN(addr, PGSIZE), PGSIZE);
  80114b:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  801151:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801158:	00 
  801159:	89 74 24 04          	mov    %esi,0x4(%esp)
  80115d:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801164:	e8 2a f9 ff ff       	call   800a93 <memmove>
	sys_page_map(thisenv_id, (void*)PFTEMP, thisenv_id,(void*)ROUNDDOWN(addr, PGSIZE), 
  801169:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801170:	00 
  801171:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801175:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801179:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801180:	00 
  801181:	89 1c 24             	mov    %ebx,(%esp)
  801184:	e8 b8 fc ff ff       	call   800e41 <sys_page_map>
		PTE_U|PTE_W|PTE_P);
	//panic("pgfault not implemented");
}
  801189:	83 c4 20             	add    $0x20,%esp
  80118c:	5b                   	pop    %ebx
  80118d:	5e                   	pop    %esi
  80118e:	5d                   	pop    %ebp
  80118f:	c3                   	ret    

00801190 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801190:	55                   	push   %ebp
  801191:	89 e5                	mov    %esp,%ebp
  801193:	57                   	push   %edi
  801194:	56                   	push   %esi
  801195:	53                   	push   %ebx
  801196:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	envid_t child_id;
	uint32_t pg_cow_ptr;
	int r;

	set_pgfault_handler(pgfault);
  801199:	c7 04 24 e8 10 80 00 	movl   $0x8010e8,(%esp)
  8011a0:	e8 f3 0a 00 00       	call   801c98 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8011a5:	ba 07 00 00 00       	mov    $0x7,%edx
  8011aa:	89 d0                	mov    %edx,%eax
  8011ac:	cd 30                	int    $0x30
  8011ae:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8011b1:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if((child_id = sys_exofork()) < 0)
  8011b4:	85 c0                	test   %eax,%eax
  8011b6:	79 1c                	jns    8011d4 <fork+0x44>
		panic("Fork error\n");
  8011b8:	c7 44 24 08 e4 23 80 	movl   $0x8023e4,0x8(%esp)
  8011bf:	00 
  8011c0:	c7 44 24 04 6e 00 00 	movl   $0x6e,0x4(%esp)
  8011c7:	00 
  8011c8:	c7 04 24 d9 23 80 00 	movl   $0x8023d9,(%esp)
  8011cf:	e8 6c 0a 00 00       	call   801c40 <_panic>
	if(child_id == 0){
  8011d4:	bb 00 00 80 00       	mov    $0x800000,%ebx
  8011d9:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8011dd:	75 1c                	jne    8011fb <fork+0x6b>
		thisenv = &envs[ENVX(sys_getenvid())];
  8011df:	e8 83 fb ff ff       	call   800d67 <sys_getenvid>
  8011e4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8011e9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011ec:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011f1:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  8011f6:	e9 00 01 00 00       	jmp    8012fb <fork+0x16b>
	}
	for(pg_cow_ptr = UTEXT; pg_cow_ptr < UXSTACKTOP - PGSIZE; pg_cow_ptr += PGSIZE){
		if ((vpd[PDX(pg_cow_ptr)]&PTE_P) && (vpt[PGNUM(pg_cow_ptr)]&(PTE_P|PTE_U)))
  8011fb:	89 d8                	mov    %ebx,%eax
  8011fd:	c1 e8 16             	shr    $0x16,%eax
  801200:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801207:	a8 01                	test   $0x1,%al
  801209:	74 79                	je     801284 <fork+0xf4>
  80120b:	89 de                	mov    %ebx,%esi
  80120d:	c1 ee 0c             	shr    $0xc,%esi
  801210:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801217:	a8 05                	test   $0x5,%al
  801219:	74 69                	je     801284 <fork+0xf4>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	// LAB 4: Your code here.
	int map_sz = pn*PGSIZE;
  80121b:	89 f7                	mov    %esi,%edi
  80121d:	c1 e7 0c             	shl    $0xc,%edi
	envid_t thisenv_id = sys_getenvid();
  801220:	e8 42 fb ff ff       	call   800d67 <sys_getenvid>
  801225:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	int perm = vpt[pn]&PTE_SYSCALL;
  801228:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80122f:	89 c6                	mov    %eax,%esi
  801231:	81 e6 07 0e 00 00    	and    $0xe07,%esi

	if(perm & PTE_COW || perm & PTE_W){
  801237:	a9 02 08 00 00       	test   $0x802,%eax
  80123c:	74 09                	je     801247 <fork+0xb7>
		perm |= PTE_COW;
  80123e:	81 ce 00 08 00 00    	or     $0x800,%esi
		perm &= ~PTE_W;
  801244:	83 e6 fd             	and    $0xfffffffd,%esi
	}
	//cprintf("thisenv_id[%p]\n", thisenv_id);

	if((r = sys_page_map(thisenv_id, (void*)map_sz, envid, (void*)map_sz, perm)) < 0)
  801247:	89 74 24 10          	mov    %esi,0x10(%esp)
  80124b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80124f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801252:	89 44 24 08          	mov    %eax,0x8(%esp)
  801256:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80125a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80125d:	89 04 24             	mov    %eax,(%esp)
  801260:	e8 dc fb ff ff       	call   800e41 <sys_page_map>
  801265:	85 c0                	test   %eax,%eax
  801267:	78 1b                	js     801284 <fork+0xf4>
		return r;
	if((r = sys_page_map(thisenv_id, (void*)map_sz, thisenv_id, (void*)map_sz, perm)) < 0)
  801269:	89 74 24 10          	mov    %esi,0x10(%esp)
  80126d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801271:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801274:	89 44 24 08          	mov    %eax,0x8(%esp)
  801278:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80127c:	89 04 24             	mov    %eax,(%esp)
  80127f:	e8 bd fb ff ff       	call   800e41 <sys_page_map>
		panic("Fork error\n");
	if(child_id == 0){
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	for(pg_cow_ptr = UTEXT; pg_cow_ptr < UXSTACKTOP - PGSIZE; pg_cow_ptr += PGSIZE){
  801284:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80128a:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801290:	0f 85 65 ff ff ff    	jne    8011fb <fork+0x6b>
		if ((vpd[PDX(pg_cow_ptr)]&PTE_P) && (vpt[PGNUM(pg_cow_ptr)]&(PTE_P|PTE_U)))
			duppage(child_id, PGNUM(pg_cow_ptr));
	}
	if((r = sys_page_alloc(child_id, (void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_P|PTE_W)))
  801296:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80129d:	00 
  80129e:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8012a5:	ee 
  8012a6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012a9:	89 04 24             	mov    %eax,(%esp)
  8012ac:	e8 28 fb ff ff       	call   800dd9 <sys_page_alloc>
  8012b1:	85 c0                	test   %eax,%eax
  8012b3:	74 20                	je     8012d5 <fork+0x145>
		panic("Alloc exception stack error: %e\n", r);
  8012b5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012b9:	c7 44 24 08 b8 23 80 	movl   $0x8023b8,0x8(%esp)
  8012c0:	00 
  8012c1:	c7 44 24 04 78 00 00 	movl   $0x78,0x4(%esp)
  8012c8:	00 
  8012c9:	c7 04 24 d9 23 80 00 	movl   $0x8023d9,(%esp)
  8012d0:	e8 6b 09 00 00       	call   801c40 <_panic>

	extern void _pgfault_upcall(void);
	sys_env_set_pgfault_upcall(child_id, _pgfault_upcall);
  8012d5:	c7 44 24 04 08 1d 80 	movl   $0x801d08,0x4(%esp)
  8012dc:	00 
  8012dd:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012e0:	89 04 24             	mov    %eax,(%esp)
  8012e3:	e8 f5 fc ff ff       	call   800fdd <sys_env_set_pgfault_upcall>

	sys_env_set_status(child_id, ENV_RUNNABLE);
  8012e8:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8012ef:	00 
  8012f0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012f3:	89 04 24             	mov    %eax,(%esp)
  8012f6:	e8 14 fc ff ff       	call   800f0f <sys_env_set_status>
	return child_id;
	//panic("fork not implemented");
}
  8012fb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012fe:	83 c4 3c             	add    $0x3c,%esp
  801301:	5b                   	pop    %ebx
  801302:	5e                   	pop    %esi
  801303:	5f                   	pop    %edi
  801304:	5d                   	pop    %ebp
  801305:	c3                   	ret    

00801306 <sfork>:

// Challenge!
int
sfork(void)
{
  801306:	55                   	push   %ebp
  801307:	89 e5                	mov    %esp,%ebp
  801309:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  80130c:	c7 44 24 08 f0 23 80 	movl   $0x8023f0,0x8(%esp)
  801313:	00 
  801314:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  80131b:	00 
  80131c:	c7 04 24 d9 23 80 00 	movl   $0x8023d9,(%esp)
  801323:	e8 18 09 00 00       	call   801c40 <_panic>

00801328 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801328:	55                   	push   %ebp
  801329:	89 e5                	mov    %esp,%ebp
  80132b:	56                   	push   %esi
  80132c:	53                   	push   %ebx
  80132d:	83 ec 10             	sub    $0x10,%esp
  801330:	8b 75 08             	mov    0x8(%ebp),%esi
  801333:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	// 	return thisenv->env_ipc_value;
	// }
	int r;
	if(pg == NULL)
		pg = (void *)~0x0;
  801336:	85 db                	test   %ebx,%ebx
  801338:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80133d:	0f 44 d8             	cmove  %eax,%ebx
	//else
	if((r = sys_ipc_recv(pg)) < 0)
  801340:	89 1c 24             	mov    %ebx,(%esp)
  801343:	e8 39 fd ff ff       	call   801081 <sys_ipc_recv>
  801348:	85 c0                	test   %eax,%eax
  80134a:	78 2d                	js     801379 <ipc_recv+0x51>
		return r;
	//volatile struct Env *curenv = (struct Env*)envs+ENVX(sys_getenvid());

	if(from_env_store)
  80134c:	85 f6                	test   %esi,%esi
  80134e:	74 0a                	je     80135a <ipc_recv+0x32>
		*from_env_store = thisenv -> env_ipc_from;
  801350:	a1 04 40 80 00       	mov    0x804004,%eax
  801355:	8b 40 74             	mov    0x74(%eax),%eax
  801358:	89 06                	mov    %eax,(%esi)
	if(pg && perm_store)
  80135a:	85 db                	test   %ebx,%ebx
  80135c:	74 13                	je     801371 <ipc_recv+0x49>
  80135e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801362:	74 0d                	je     801371 <ipc_recv+0x49>
		*perm_store = thisenv -> env_ipc_perm;
  801364:	a1 04 40 80 00       	mov    0x804004,%eax
  801369:	8b 40 78             	mov    0x78(%eax),%eax
  80136c:	8b 55 10             	mov    0x10(%ebp),%edx
  80136f:	89 02                	mov    %eax,(%edx)
	else if(perm_store)
		perm_store = (int *)0;
	return thisenv->env_ipc_value;
  801371:	a1 04 40 80 00       	mov    0x804004,%eax
  801376:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  801379:	83 c4 10             	add    $0x10,%esp
  80137c:	5b                   	pop    %ebx
  80137d:	5e                   	pop    %esi
  80137e:	5d                   	pop    %ebp
  80137f:	c3                   	ret    

00801380 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801380:	55                   	push   %ebp
  801381:	89 e5                	mov    %esp,%ebp
  801383:	57                   	push   %edi
  801384:	56                   	push   %esi
  801385:	53                   	push   %ebx
  801386:	83 ec 1c             	sub    $0x1c,%esp
  801389:	8b 7d 08             	mov    0x8(%ebp),%edi
  80138c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80138f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

	if(pg == NULL)
  801392:	85 db                	test   %ebx,%ebx
		pg = (void *)~0x0;
  801394:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801399:	0f 44 d8             	cmove  %eax,%ebx
  80139c:	eb 2a                	jmp    8013c8 <ipc_send+0x48>
	while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0){
		if(r != -E_IPC_NOT_RECV)
  80139e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8013a1:	74 20                	je     8013c3 <ipc_send+0x43>
            panic("Send message error %e\n",r);
  8013a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013a7:	c7 44 24 08 06 24 80 	movl   $0x802406,0x8(%esp)
  8013ae:	00 
  8013af:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8013b6:	00 
  8013b7:	c7 04 24 1d 24 80 00 	movl   $0x80241d,(%esp)
  8013be:	e8 7d 08 00 00       	call   801c40 <_panic>
		sys_yield();
  8013c3:	e8 d8 f9 ff ff       	call   800da0 <sys_yield>
	// LAB 4: Your code here.
	int r;

	if(pg == NULL)
		pg = (void *)~0x0;
	while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0){
  8013c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8013cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013cf:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013d3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013d7:	89 3c 24             	mov    %edi,(%esp)
  8013da:	e8 65 fc ff ff       	call   801044 <sys_ipc_try_send>
  8013df:	85 c0                	test   %eax,%eax
  8013e1:	78 bb                	js     80139e <ipc_send+0x1e>
            panic("Send message error %e\n",r);
		sys_yield();
	}

	//panic("ipc_send not implemented");
}
  8013e3:	83 c4 1c             	add    $0x1c,%esp
  8013e6:	5b                   	pop    %ebx
  8013e7:	5e                   	pop    %esi
  8013e8:	5f                   	pop    %edi
  8013e9:	5d                   	pop    %ebp
  8013ea:	c3                   	ret    

008013eb <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8013eb:	55                   	push   %ebp
  8013ec:	89 e5                	mov    %esp,%ebp
  8013ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8013f1:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  8013f6:	39 c8                	cmp    %ecx,%eax
  8013f8:	74 17                	je     801411 <ipc_find_env+0x26>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8013fa:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  8013ff:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801402:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801408:	8b 52 50             	mov    0x50(%edx),%edx
  80140b:	39 ca                	cmp    %ecx,%edx
  80140d:	75 14                	jne    801423 <ipc_find_env+0x38>
  80140f:	eb 05                	jmp    801416 <ipc_find_env+0x2b>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801411:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801416:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801419:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  80141e:	8b 40 40             	mov    0x40(%eax),%eax
  801421:	eb 0e                	jmp    801431 <ipc_find_env+0x46>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801423:	83 c0 01             	add    $0x1,%eax
  801426:	3d 00 04 00 00       	cmp    $0x400,%eax
  80142b:	75 d2                	jne    8013ff <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80142d:	66 b8 00 00          	mov    $0x0,%ax
}
  801431:	5d                   	pop    %ebp
  801432:	c3                   	ret    
  801433:	66 90                	xchg   %ax,%ax
  801435:	66 90                	xchg   %ax,%ax
  801437:	66 90                	xchg   %ax,%ax
  801439:	66 90                	xchg   %ax,%ax
  80143b:	66 90                	xchg   %ax,%ax
  80143d:	66 90                	xchg   %ax,%ax
  80143f:	90                   	nop

00801440 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801440:	55                   	push   %ebp
  801441:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801443:	8b 45 08             	mov    0x8(%ebp),%eax
  801446:	05 00 00 00 30       	add    $0x30000000,%eax
  80144b:	c1 e8 0c             	shr    $0xc,%eax
}
  80144e:	5d                   	pop    %ebp
  80144f:	c3                   	ret    

00801450 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801450:	55                   	push   %ebp
  801451:	89 e5                	mov    %esp,%ebp
  801453:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801456:	8b 45 08             	mov    0x8(%ebp),%eax
  801459:	89 04 24             	mov    %eax,(%esp)
  80145c:	e8 df ff ff ff       	call   801440 <fd2num>
  801461:	c1 e0 0c             	shl    $0xc,%eax
  801464:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801469:	c9                   	leave  
  80146a:	c3                   	ret    

0080146b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80146b:	55                   	push   %ebp
  80146c:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  80146e:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801473:	a8 01                	test   $0x1,%al
  801475:	74 34                	je     8014ab <fd_alloc+0x40>
  801477:	a1 00 00 74 ef       	mov    0xef740000,%eax
  80147c:	a8 01                	test   $0x1,%al
  80147e:	74 32                	je     8014b2 <fd_alloc+0x47>
  801480:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801485:	89 c1                	mov    %eax,%ecx
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801487:	89 c2                	mov    %eax,%edx
  801489:	c1 ea 16             	shr    $0x16,%edx
  80148c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801493:	f6 c2 01             	test   $0x1,%dl
  801496:	74 1f                	je     8014b7 <fd_alloc+0x4c>
  801498:	89 c2                	mov    %eax,%edx
  80149a:	c1 ea 0c             	shr    $0xc,%edx
  80149d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014a4:	f6 c2 01             	test   $0x1,%dl
  8014a7:	75 1a                	jne    8014c3 <fd_alloc+0x58>
  8014a9:	eb 0c                	jmp    8014b7 <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8014ab:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8014b0:	eb 05                	jmp    8014b7 <fd_alloc+0x4c>
  8014b2:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8014b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ba:	89 08                	mov    %ecx,(%eax)
			return 0;
  8014bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8014c1:	eb 1a                	jmp    8014dd <fd_alloc+0x72>
  8014c3:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8014c8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8014cd:	75 b6                	jne    801485 <fd_alloc+0x1a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8014cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  8014d8:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8014dd:	5d                   	pop    %ebp
  8014de:	c3                   	ret    

008014df <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8014df:	55                   	push   %ebp
  8014e0:	89 e5                	mov    %esp,%ebp
  8014e2:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8014e5:	83 f8 1f             	cmp    $0x1f,%eax
  8014e8:	77 36                	ja     801520 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8014ea:	c1 e0 0c             	shl    $0xc,%eax
  8014ed:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  8014f2:	89 c2                	mov    %eax,%edx
  8014f4:	c1 ea 16             	shr    $0x16,%edx
  8014f7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014fe:	f6 c2 01             	test   $0x1,%dl
  801501:	74 24                	je     801527 <fd_lookup+0x48>
  801503:	89 c2                	mov    %eax,%edx
  801505:	c1 ea 0c             	shr    $0xc,%edx
  801508:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80150f:	f6 c2 01             	test   $0x1,%dl
  801512:	74 1a                	je     80152e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801514:	8b 55 0c             	mov    0xc(%ebp),%edx
  801517:	89 02                	mov    %eax,(%edx)
	return 0;
  801519:	b8 00 00 00 00       	mov    $0x0,%eax
  80151e:	eb 13                	jmp    801533 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  801520:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801525:	eb 0c                	jmp    801533 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  801527:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80152c:	eb 05                	jmp    801533 <fd_lookup+0x54>
  80152e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801533:	5d                   	pop    %ebp
  801534:	c3                   	ret    

00801535 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801535:	55                   	push   %ebp
  801536:	89 e5                	mov    %esp,%ebp
  801538:	83 ec 18             	sub    $0x18,%esp
  80153b:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80153e:	39 05 04 30 80 00    	cmp    %eax,0x803004
  801544:	75 10                	jne    801556 <dev_lookup+0x21>
			*dev = devtab[i];
  801546:	8b 45 0c             	mov    0xc(%ebp),%eax
  801549:	c7 00 04 30 80 00    	movl   $0x803004,(%eax)
			return 0;
  80154f:	b8 00 00 00 00       	mov    $0x0,%eax
  801554:	eb 2b                	jmp    801581 <dev_lookup+0x4c>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801556:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80155c:	8b 52 48             	mov    0x48(%edx),%edx
  80155f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801563:	89 54 24 04          	mov    %edx,0x4(%esp)
  801567:	c7 04 24 28 24 80 00 	movl   $0x802428,(%esp)
  80156e:	e8 94 ec ff ff       	call   800207 <cprintf>
	*dev = 0;
  801573:	8b 55 0c             	mov    0xc(%ebp),%edx
  801576:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	return -E_INVAL;
  80157c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801581:	c9                   	leave  
  801582:	c3                   	ret    

00801583 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801583:	55                   	push   %ebp
  801584:	89 e5                	mov    %esp,%ebp
  801586:	83 ec 38             	sub    $0x38,%esp
  801589:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80158c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80158f:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801592:	8b 7d 08             	mov    0x8(%ebp),%edi
  801595:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801598:	89 3c 24             	mov    %edi,(%esp)
  80159b:	e8 a0 fe ff ff       	call   801440 <fd2num>
  8015a0:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8015a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8015a7:	89 04 24             	mov    %eax,(%esp)
  8015aa:	e8 30 ff ff ff       	call   8014df <fd_lookup>
  8015af:	89 c3                	mov    %eax,%ebx
  8015b1:	85 c0                	test   %eax,%eax
  8015b3:	78 05                	js     8015ba <fd_close+0x37>
	    || fd != fd2)
  8015b5:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  8015b8:	74 0c                	je     8015c6 <fd_close+0x43>
		return (must_exist ? r : 0);
  8015ba:	85 f6                	test   %esi,%esi
  8015bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8015c1:	0f 44 d8             	cmove  %eax,%ebx
  8015c4:	eb 3d                	jmp    801603 <fd_close+0x80>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8015c6:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8015c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015cd:	8b 07                	mov    (%edi),%eax
  8015cf:	89 04 24             	mov    %eax,(%esp)
  8015d2:	e8 5e ff ff ff       	call   801535 <dev_lookup>
  8015d7:	89 c3                	mov    %eax,%ebx
  8015d9:	85 c0                	test   %eax,%eax
  8015db:	78 16                	js     8015f3 <fd_close+0x70>
		if (dev->dev_close)
  8015dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8015e0:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8015e3:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8015e8:	85 c0                	test   %eax,%eax
  8015ea:	74 07                	je     8015f3 <fd_close+0x70>
			r = (*dev->dev_close)(fd);
  8015ec:	89 3c 24             	mov    %edi,(%esp)
  8015ef:	ff d0                	call   *%eax
  8015f1:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8015f3:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8015f7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015fe:	e8 a5 f8 ff ff       	call   800ea8 <sys_page_unmap>
	return r;
}
  801603:	89 d8                	mov    %ebx,%eax
  801605:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801608:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80160b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80160e:	89 ec                	mov    %ebp,%esp
  801610:	5d                   	pop    %ebp
  801611:	c3                   	ret    

00801612 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801612:	55                   	push   %ebp
  801613:	89 e5                	mov    %esp,%ebp
  801615:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801618:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80161b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80161f:	8b 45 08             	mov    0x8(%ebp),%eax
  801622:	89 04 24             	mov    %eax,(%esp)
  801625:	e8 b5 fe ff ff       	call   8014df <fd_lookup>
  80162a:	85 c0                	test   %eax,%eax
  80162c:	78 13                	js     801641 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80162e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801635:	00 
  801636:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801639:	89 04 24             	mov    %eax,(%esp)
  80163c:	e8 42 ff ff ff       	call   801583 <fd_close>
}
  801641:	c9                   	leave  
  801642:	c3                   	ret    

00801643 <close_all>:

void
close_all(void)
{
  801643:	55                   	push   %ebp
  801644:	89 e5                	mov    %esp,%ebp
  801646:	53                   	push   %ebx
  801647:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80164a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80164f:	89 1c 24             	mov    %ebx,(%esp)
  801652:	e8 bb ff ff ff       	call   801612 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801657:	83 c3 01             	add    $0x1,%ebx
  80165a:	83 fb 20             	cmp    $0x20,%ebx
  80165d:	75 f0                	jne    80164f <close_all+0xc>
		close(i);
}
  80165f:	83 c4 14             	add    $0x14,%esp
  801662:	5b                   	pop    %ebx
  801663:	5d                   	pop    %ebp
  801664:	c3                   	ret    

00801665 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801665:	55                   	push   %ebp
  801666:	89 e5                	mov    %esp,%ebp
  801668:	83 ec 58             	sub    $0x58,%esp
  80166b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80166e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801671:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801674:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801677:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80167a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80167e:	8b 45 08             	mov    0x8(%ebp),%eax
  801681:	89 04 24             	mov    %eax,(%esp)
  801684:	e8 56 fe ff ff       	call   8014df <fd_lookup>
  801689:	85 c0                	test   %eax,%eax
  80168b:	0f 88 e3 00 00 00    	js     801774 <dup+0x10f>
		return r;
	close(newfdnum);
  801691:	89 1c 24             	mov    %ebx,(%esp)
  801694:	e8 79 ff ff ff       	call   801612 <close>

	newfd = INDEX2FD(newfdnum);
  801699:	89 de                	mov    %ebx,%esi
  80169b:	c1 e6 0c             	shl    $0xc,%esi
  80169e:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8016a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016a7:	89 04 24             	mov    %eax,(%esp)
  8016aa:	e8 a1 fd ff ff       	call   801450 <fd2data>
  8016af:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8016b1:	89 34 24             	mov    %esi,(%esp)
  8016b4:	e8 97 fd ff ff       	call   801450 <fd2data>
  8016b9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  8016bc:	89 f8                	mov    %edi,%eax
  8016be:	c1 e8 16             	shr    $0x16,%eax
  8016c1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8016c8:	a8 01                	test   $0x1,%al
  8016ca:	74 46                	je     801712 <dup+0xad>
  8016cc:	89 f8                	mov    %edi,%eax
  8016ce:	c1 e8 0c             	shr    $0xc,%eax
  8016d1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8016d8:	f6 c2 01             	test   $0x1,%dl
  8016db:	74 35                	je     801712 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8016dd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016e4:	25 07 0e 00 00       	and    $0xe07,%eax
  8016e9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8016ed:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8016f0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8016f4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016fb:	00 
  8016fc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801700:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801707:	e8 35 f7 ff ff       	call   800e41 <sys_page_map>
  80170c:	89 c7                	mov    %eax,%edi
  80170e:	85 c0                	test   %eax,%eax
  801710:	78 3b                	js     80174d <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801712:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801715:	89 c2                	mov    %eax,%edx
  801717:	c1 ea 0c             	shr    $0xc,%edx
  80171a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801721:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801727:	89 54 24 10          	mov    %edx,0x10(%esp)
  80172b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80172f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801736:	00 
  801737:	89 44 24 04          	mov    %eax,0x4(%esp)
  80173b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801742:	e8 fa f6 ff ff       	call   800e41 <sys_page_map>
  801747:	89 c7                	mov    %eax,%edi
  801749:	85 c0                	test   %eax,%eax
  80174b:	79 29                	jns    801776 <dup+0x111>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80174d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801751:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801758:	e8 4b f7 ff ff       	call   800ea8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80175d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801760:	89 44 24 04          	mov    %eax,0x4(%esp)
  801764:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80176b:	e8 38 f7 ff ff       	call   800ea8 <sys_page_unmap>
	return r;
  801770:	89 fb                	mov    %edi,%ebx
  801772:	eb 02                	jmp    801776 <dup+0x111>
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
		return r;
  801774:	89 c3                	mov    %eax,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801776:	89 d8                	mov    %ebx,%eax
  801778:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80177b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80177e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801781:	89 ec                	mov    %ebp,%esp
  801783:	5d                   	pop    %ebp
  801784:	c3                   	ret    

00801785 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801785:	55                   	push   %ebp
  801786:	89 e5                	mov    %esp,%ebp
  801788:	53                   	push   %ebx
  801789:	83 ec 24             	sub    $0x24,%esp
  80178c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80178f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801792:	89 44 24 04          	mov    %eax,0x4(%esp)
  801796:	89 1c 24             	mov    %ebx,(%esp)
  801799:	e8 41 fd ff ff       	call   8014df <fd_lookup>
  80179e:	85 c0                	test   %eax,%eax
  8017a0:	78 6d                	js     80180f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ac:	8b 00                	mov    (%eax),%eax
  8017ae:	89 04 24             	mov    %eax,(%esp)
  8017b1:	e8 7f fd ff ff       	call   801535 <dev_lookup>
  8017b6:	85 c0                	test   %eax,%eax
  8017b8:	78 55                	js     80180f <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8017ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017bd:	8b 50 08             	mov    0x8(%eax),%edx
  8017c0:	83 e2 03             	and    $0x3,%edx
  8017c3:	83 fa 01             	cmp    $0x1,%edx
  8017c6:	75 23                	jne    8017eb <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8017c8:	a1 04 40 80 00       	mov    0x804004,%eax
  8017cd:	8b 40 48             	mov    0x48(%eax),%eax
  8017d0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017d8:	c7 04 24 69 24 80 00 	movl   $0x802469,(%esp)
  8017df:	e8 23 ea ff ff       	call   800207 <cprintf>
		return -E_INVAL;
  8017e4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017e9:	eb 24                	jmp    80180f <read+0x8a>
	}
	if (!dev->dev_read)
  8017eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017ee:	8b 52 08             	mov    0x8(%edx),%edx
  8017f1:	85 d2                	test   %edx,%edx
  8017f3:	74 15                	je     80180a <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8017f5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8017f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017ff:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801803:	89 04 24             	mov    %eax,(%esp)
  801806:	ff d2                	call   *%edx
  801808:	eb 05                	jmp    80180f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80180a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80180f:	83 c4 24             	add    $0x24,%esp
  801812:	5b                   	pop    %ebx
  801813:	5d                   	pop    %ebp
  801814:	c3                   	ret    

00801815 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801815:	55                   	push   %ebp
  801816:	89 e5                	mov    %esp,%ebp
  801818:	57                   	push   %edi
  801819:	56                   	push   %esi
  80181a:	53                   	push   %ebx
  80181b:	83 ec 1c             	sub    $0x1c,%esp
  80181e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801821:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801824:	85 f6                	test   %esi,%esi
  801826:	74 33                	je     80185b <readn+0x46>
  801828:	b8 00 00 00 00       	mov    $0x0,%eax
  80182d:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801832:	89 f2                	mov    %esi,%edx
  801834:	29 c2                	sub    %eax,%edx
  801836:	89 54 24 08          	mov    %edx,0x8(%esp)
  80183a:	03 45 0c             	add    0xc(%ebp),%eax
  80183d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801841:	89 3c 24             	mov    %edi,(%esp)
  801844:	e8 3c ff ff ff       	call   801785 <read>
		if (m < 0)
  801849:	85 c0                	test   %eax,%eax
  80184b:	78 17                	js     801864 <readn+0x4f>
			return m;
		if (m == 0)
  80184d:	85 c0                	test   %eax,%eax
  80184f:	74 11                	je     801862 <readn+0x4d>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801851:	01 c3                	add    %eax,%ebx
  801853:	89 d8                	mov    %ebx,%eax
  801855:	39 f3                	cmp    %esi,%ebx
  801857:	72 d9                	jb     801832 <readn+0x1d>
  801859:	eb 09                	jmp    801864 <readn+0x4f>
  80185b:	b8 00 00 00 00       	mov    $0x0,%eax
  801860:	eb 02                	jmp    801864 <readn+0x4f>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801862:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801864:	83 c4 1c             	add    $0x1c,%esp
  801867:	5b                   	pop    %ebx
  801868:	5e                   	pop    %esi
  801869:	5f                   	pop    %edi
  80186a:	5d                   	pop    %ebp
  80186b:	c3                   	ret    

0080186c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80186c:	55                   	push   %ebp
  80186d:	89 e5                	mov    %esp,%ebp
  80186f:	53                   	push   %ebx
  801870:	83 ec 24             	sub    $0x24,%esp
  801873:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801876:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801879:	89 44 24 04          	mov    %eax,0x4(%esp)
  80187d:	89 1c 24             	mov    %ebx,(%esp)
  801880:	e8 5a fc ff ff       	call   8014df <fd_lookup>
  801885:	85 c0                	test   %eax,%eax
  801887:	78 68                	js     8018f1 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801889:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80188c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801890:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801893:	8b 00                	mov    (%eax),%eax
  801895:	89 04 24             	mov    %eax,(%esp)
  801898:	e8 98 fc ff ff       	call   801535 <dev_lookup>
  80189d:	85 c0                	test   %eax,%eax
  80189f:	78 50                	js     8018f1 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018a4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018a8:	75 23                	jne    8018cd <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8018aa:	a1 04 40 80 00       	mov    0x804004,%eax
  8018af:	8b 40 48             	mov    0x48(%eax),%eax
  8018b2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ba:	c7 04 24 85 24 80 00 	movl   $0x802485,(%esp)
  8018c1:	e8 41 e9 ff ff       	call   800207 <cprintf>
		return -E_INVAL;
  8018c6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018cb:	eb 24                	jmp    8018f1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8018cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018d0:	8b 52 0c             	mov    0xc(%edx),%edx
  8018d3:	85 d2                	test   %edx,%edx
  8018d5:	74 15                	je     8018ec <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8018d7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8018da:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8018de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018e1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8018e5:	89 04 24             	mov    %eax,(%esp)
  8018e8:	ff d2                	call   *%edx
  8018ea:	eb 05                	jmp    8018f1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8018ec:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8018f1:	83 c4 24             	add    $0x24,%esp
  8018f4:	5b                   	pop    %ebx
  8018f5:	5d                   	pop    %ebp
  8018f6:	c3                   	ret    

008018f7 <seek>:

int
seek(int fdnum, off_t offset)
{
  8018f7:	55                   	push   %ebp
  8018f8:	89 e5                	mov    %esp,%ebp
  8018fa:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018fd:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801900:	89 44 24 04          	mov    %eax,0x4(%esp)
  801904:	8b 45 08             	mov    0x8(%ebp),%eax
  801907:	89 04 24             	mov    %eax,(%esp)
  80190a:	e8 d0 fb ff ff       	call   8014df <fd_lookup>
  80190f:	85 c0                	test   %eax,%eax
  801911:	78 0e                	js     801921 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801913:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801916:	8b 55 0c             	mov    0xc(%ebp),%edx
  801919:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80191c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801921:	c9                   	leave  
  801922:	c3                   	ret    

00801923 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801923:	55                   	push   %ebp
  801924:	89 e5                	mov    %esp,%ebp
  801926:	53                   	push   %ebx
  801927:	83 ec 24             	sub    $0x24,%esp
  80192a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80192d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801930:	89 44 24 04          	mov    %eax,0x4(%esp)
  801934:	89 1c 24             	mov    %ebx,(%esp)
  801937:	e8 a3 fb ff ff       	call   8014df <fd_lookup>
  80193c:	85 c0                	test   %eax,%eax
  80193e:	78 61                	js     8019a1 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801940:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801943:	89 44 24 04          	mov    %eax,0x4(%esp)
  801947:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80194a:	8b 00                	mov    (%eax),%eax
  80194c:	89 04 24             	mov    %eax,(%esp)
  80194f:	e8 e1 fb ff ff       	call   801535 <dev_lookup>
  801954:	85 c0                	test   %eax,%eax
  801956:	78 49                	js     8019a1 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801958:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80195b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80195f:	75 23                	jne    801984 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801961:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801966:	8b 40 48             	mov    0x48(%eax),%eax
  801969:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80196d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801971:	c7 04 24 48 24 80 00 	movl   $0x802448,(%esp)
  801978:	e8 8a e8 ff ff       	call   800207 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80197d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801982:	eb 1d                	jmp    8019a1 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801984:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801987:	8b 52 18             	mov    0x18(%edx),%edx
  80198a:	85 d2                	test   %edx,%edx
  80198c:	74 0e                	je     80199c <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80198e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801991:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801995:	89 04 24             	mov    %eax,(%esp)
  801998:	ff d2                	call   *%edx
  80199a:	eb 05                	jmp    8019a1 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80199c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8019a1:	83 c4 24             	add    $0x24,%esp
  8019a4:	5b                   	pop    %ebx
  8019a5:	5d                   	pop    %ebp
  8019a6:	c3                   	ret    

008019a7 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8019a7:	55                   	push   %ebp
  8019a8:	89 e5                	mov    %esp,%ebp
  8019aa:	53                   	push   %ebx
  8019ab:	83 ec 24             	sub    $0x24,%esp
  8019ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019b1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019bb:	89 04 24             	mov    %eax,(%esp)
  8019be:	e8 1c fb ff ff       	call   8014df <fd_lookup>
  8019c3:	85 c0                	test   %eax,%eax
  8019c5:	78 52                	js     801a19 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019c7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019d1:	8b 00                	mov    (%eax),%eax
  8019d3:	89 04 24             	mov    %eax,(%esp)
  8019d6:	e8 5a fb ff ff       	call   801535 <dev_lookup>
  8019db:	85 c0                	test   %eax,%eax
  8019dd:	78 3a                	js     801a19 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8019df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019e2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8019e6:	74 2c                	je     801a14 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8019e8:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8019eb:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8019f2:	00 00 00 
	stat->st_isdir = 0;
  8019f5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019fc:	00 00 00 
	stat->st_dev = dev;
  8019ff:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a05:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a09:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a0c:	89 14 24             	mov    %edx,(%esp)
  801a0f:	ff 50 14             	call   *0x14(%eax)
  801a12:	eb 05                	jmp    801a19 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801a14:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801a19:	83 c4 24             	add    $0x24,%esp
  801a1c:	5b                   	pop    %ebx
  801a1d:	5d                   	pop    %ebp
  801a1e:	c3                   	ret    

00801a1f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a1f:	55                   	push   %ebp
  801a20:	89 e5                	mov    %esp,%ebp
  801a22:	83 ec 18             	sub    $0x18,%esp
  801a25:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801a28:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a2b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a32:	00 
  801a33:	8b 45 08             	mov    0x8(%ebp),%eax
  801a36:	89 04 24             	mov    %eax,(%esp)
  801a39:	e8 84 01 00 00       	call   801bc2 <open>
  801a3e:	89 c3                	mov    %eax,%ebx
  801a40:	85 c0                	test   %eax,%eax
  801a42:	78 1b                	js     801a5f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801a44:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a47:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a4b:	89 1c 24             	mov    %ebx,(%esp)
  801a4e:	e8 54 ff ff ff       	call   8019a7 <fstat>
  801a53:	89 c6                	mov    %eax,%esi
	close(fd);
  801a55:	89 1c 24             	mov    %ebx,(%esp)
  801a58:	e8 b5 fb ff ff       	call   801612 <close>
	return r;
  801a5d:	89 f3                	mov    %esi,%ebx
}
  801a5f:	89 d8                	mov    %ebx,%eax
  801a61:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801a64:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801a67:	89 ec                	mov    %ebp,%esp
  801a69:	5d                   	pop    %ebp
  801a6a:	c3                   	ret    
  801a6b:	90                   	nop

00801a6c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a6c:	55                   	push   %ebp
  801a6d:	89 e5                	mov    %esp,%ebp
  801a6f:	83 ec 18             	sub    $0x18,%esp
  801a72:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801a75:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801a78:	89 c6                	mov    %eax,%esi
  801a7a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801a7c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801a83:	75 11                	jne    801a96 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a85:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801a8c:	e8 5a f9 ff ff       	call   8013eb <ipc_find_env>
  801a91:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a96:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801a9d:	00 
  801a9e:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801aa5:	00 
  801aa6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801aaa:	a1 00 40 80 00       	mov    0x804000,%eax
  801aaf:	89 04 24             	mov    %eax,(%esp)
  801ab2:	e8 c9 f8 ff ff       	call   801380 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801ab7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801abe:	00 
  801abf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ac3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801aca:	e8 59 f8 ff ff       	call   801328 <ipc_recv>
}
  801acf:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801ad2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801ad5:	89 ec                	mov    %ebp,%esp
  801ad7:	5d                   	pop    %ebp
  801ad8:	c3                   	ret    

00801ad9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801ad9:	55                   	push   %ebp
  801ada:	89 e5                	mov    %esp,%ebp
  801adc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801adf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae2:	8b 40 0c             	mov    0xc(%eax),%eax
  801ae5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801aea:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aed:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801af2:	ba 00 00 00 00       	mov    $0x0,%edx
  801af7:	b8 02 00 00 00       	mov    $0x2,%eax
  801afc:	e8 6b ff ff ff       	call   801a6c <fsipc>
}
  801b01:	c9                   	leave  
  801b02:	c3                   	ret    

00801b03 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801b03:	55                   	push   %ebp
  801b04:	89 e5                	mov    %esp,%ebp
  801b06:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801b09:	8b 45 08             	mov    0x8(%ebp),%eax
  801b0c:	8b 40 0c             	mov    0xc(%eax),%eax
  801b0f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801b14:	ba 00 00 00 00       	mov    $0x0,%edx
  801b19:	b8 06 00 00 00       	mov    $0x6,%eax
  801b1e:	e8 49 ff ff ff       	call   801a6c <fsipc>
}
  801b23:	c9                   	leave  
  801b24:	c3                   	ret    

00801b25 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801b25:	55                   	push   %ebp
  801b26:	89 e5                	mov    %esp,%ebp
  801b28:	53                   	push   %ebx
  801b29:	83 ec 14             	sub    $0x14,%esp
  801b2c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b2f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b32:	8b 40 0c             	mov    0xc(%eax),%eax
  801b35:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b3a:	ba 00 00 00 00       	mov    $0x0,%edx
  801b3f:	b8 05 00 00 00       	mov    $0x5,%eax
  801b44:	e8 23 ff ff ff       	call   801a6c <fsipc>
  801b49:	85 c0                	test   %eax,%eax
  801b4b:	78 2b                	js     801b78 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b4d:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801b54:	00 
  801b55:	89 1c 24             	mov    %ebx,(%esp)
  801b58:	e8 2e ed ff ff       	call   80088b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b5d:	a1 80 50 80 00       	mov    0x805080,%eax
  801b62:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b68:	a1 84 50 80 00       	mov    0x805084,%eax
  801b6d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b73:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b78:	83 c4 14             	add    $0x14,%esp
  801b7b:	5b                   	pop    %ebx
  801b7c:	5d                   	pop    %ebp
  801b7d:	c3                   	ret    

00801b7e <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801b7e:	55                   	push   %ebp
  801b7f:	89 e5                	mov    %esp,%ebp
  801b81:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801b84:	c7 44 24 08 a2 24 80 	movl   $0x8024a2,0x8(%esp)
  801b8b:	00 
  801b8c:	c7 44 24 04 77 00 00 	movl   $0x77,0x4(%esp)
  801b93:	00 
  801b94:	c7 04 24 c0 24 80 00 	movl   $0x8024c0,(%esp)
  801b9b:	e8 a0 00 00 00       	call   801c40 <_panic>

00801ba0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801ba0:	55                   	push   %ebp
  801ba1:	89 e5                	mov    %esp,%ebp
  801ba3:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_READ request to the file system server after
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
	panic("devfile_read not implemented");
  801ba6:	c7 44 24 08 cb 24 80 	movl   $0x8024cb,0x8(%esp)
  801bad:	00 
  801bae:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
  801bb5:	00 
  801bb6:	c7 04 24 c0 24 80 00 	movl   $0x8024c0,(%esp)
  801bbd:	e8 7e 00 00 00       	call   801c40 <_panic>

00801bc2 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801bc2:	55                   	push   %ebp
  801bc3:	89 e5                	mov    %esp,%ebp
  801bc5:	83 ec 18             	sub    $0x18,%esp
	// Return the file descriptor index.
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
	panic("open not implemented");
  801bc8:	c7 44 24 08 e8 24 80 	movl   $0x8024e8,0x8(%esp)
  801bcf:	00 
  801bd0:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  801bd7:	00 
  801bd8:	c7 04 24 c0 24 80 00 	movl   $0x8024c0,(%esp)
  801bdf:	e8 5c 00 00 00       	call   801c40 <_panic>

00801be4 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801be4:	55                   	push   %ebp
  801be5:	89 e5                	mov    %esp,%ebp
  801be7:	53                   	push   %ebx
  801be8:	83 ec 14             	sub    $0x14,%esp
  801beb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801bee:	89 1c 24             	mov    %ebx,(%esp)
  801bf1:	e8 3a ec ff ff       	call   800830 <strlen>
  801bf6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801bfb:	7f 21                	jg     801c1e <remove+0x3a>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801bfd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c01:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801c08:	e8 7e ec ff ff       	call   80088b <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801c0d:	ba 00 00 00 00       	mov    $0x0,%edx
  801c12:	b8 07 00 00 00       	mov    $0x7,%eax
  801c17:	e8 50 fe ff ff       	call   801a6c <fsipc>
  801c1c:	eb 05                	jmp    801c23 <remove+0x3f>
// Delete a file
int
remove(const char *path)
{
	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c1e:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
	strcpy(fsipcbuf.remove.req_path, path);
	return fsipc(FSREQ_REMOVE, NULL);
}
  801c23:	83 c4 14             	add    $0x14,%esp
  801c26:	5b                   	pop    %ebx
  801c27:	5d                   	pop    %ebp
  801c28:	c3                   	ret    

00801c29 <sync>:

// Synchronize disk with buffer cache
int
sync(void)
{
  801c29:	55                   	push   %ebp
  801c2a:	89 e5                	mov    %esp,%ebp
  801c2c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c2f:	ba 00 00 00 00       	mov    $0x0,%edx
  801c34:	b8 08 00 00 00       	mov    $0x8,%eax
  801c39:	e8 2e fe ff ff       	call   801a6c <fsipc>
}
  801c3e:	c9                   	leave  
  801c3f:	c3                   	ret    

00801c40 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801c40:	55                   	push   %ebp
  801c41:	89 e5                	mov    %esp,%ebp
  801c43:	56                   	push   %esi
  801c44:	53                   	push   %ebx
  801c45:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801c48:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801c4b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801c51:	e8 11 f1 ff ff       	call   800d67 <sys_getenvid>
  801c56:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c59:	89 54 24 10          	mov    %edx,0x10(%esp)
  801c5d:	8b 55 08             	mov    0x8(%ebp),%edx
  801c60:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801c64:	89 74 24 08          	mov    %esi,0x8(%esp)
  801c68:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c6c:	c7 04 24 00 25 80 00 	movl   $0x802500,(%esp)
  801c73:	e8 8f e5 ff ff       	call   800207 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801c78:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c7c:	8b 45 10             	mov    0x10(%ebp),%eax
  801c7f:	89 04 24             	mov    %eax,(%esp)
  801c82:	e8 1f e5 ff ff       	call   8001a6 <vcprintf>
	cprintf("\n");
  801c87:	c7 04 24 1b 24 80 00 	movl   $0x80241b,(%esp)
  801c8e:	e8 74 e5 ff ff       	call   800207 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801c93:	cc                   	int3   
  801c94:	eb fd                	jmp    801c93 <_panic+0x53>
  801c96:	66 90                	xchg   %ax,%ax

00801c98 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801c98:	55                   	push   %ebp
  801c99:	89 e5                	mov    %esp,%ebp
  801c9b:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801c9e:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801ca5:	75 54                	jne    801cfb <set_pgfault_handler+0x63>
		// First time through!
		// LAB 4: Your code here.
		if((r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U|PTE_P|PTE_W)))
  801ca7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801cae:	00 
  801caf:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801cb6:	ee 
  801cb7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cbe:	e8 16 f1 ff ff       	call   800dd9 <sys_page_alloc>
  801cc3:	85 c0                	test   %eax,%eax
  801cc5:	74 20                	je     801ce7 <set_pgfault_handler+0x4f>
			panic("sys_page_alloc() failed in set_pgfault_handler()[%e]\n", r);
  801cc7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ccb:	c7 44 24 08 24 25 80 	movl   $0x802524,0x8(%esp)
  801cd2:	00 
  801cd3:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  801cda:	00 
  801cdb:	c7 04 24 5c 25 80 00 	movl   $0x80255c,(%esp)
  801ce2:	e8 59 ff ff ff       	call   801c40 <_panic>
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801ce7:	c7 44 24 04 08 1d 80 	movl   $0x801d08,0x4(%esp)
  801cee:	00 
  801cef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cf6:	e8 e2 f2 ff ff       	call   800fdd <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801cfb:	8b 45 08             	mov    0x8(%ebp),%eax
  801cfe:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801d03:	c9                   	leave  
  801d04:	c3                   	ret    
  801d05:	66 90                	xchg   %ax,%ax
  801d07:	90                   	nop

00801d08 <_pgfault_upcall>:
  801d08:	54                   	push   %esp
  801d09:	a1 00 60 80 00       	mov    0x806000,%eax
  801d0e:	ff d0                	call   *%eax
  801d10:	83 c4 04             	add    $0x4,%esp
  801d13:	83 c4 08             	add    $0x8,%esp
  801d16:	8b 44 24 28          	mov    0x28(%esp),%eax
  801d1a:	83 e8 04             	sub    $0x4,%eax
  801d1d:	89 44 24 28          	mov    %eax,0x28(%esp)
  801d21:	8b 5c 24 20          	mov    0x20(%esp),%ebx
  801d25:	89 18                	mov    %ebx,(%eax)
  801d27:	61                   	popa   
  801d28:	83 c4 04             	add    $0x4,%esp
  801d2b:	9d                   	popf   
  801d2c:	5c                   	pop    %esp
  801d2d:	c3                   	ret    
  801d2e:	66 90                	xchg   %ax,%ax

00801d30 <__udivdi3>:
  801d30:	83 ec 1c             	sub    $0x1c,%esp
  801d33:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801d37:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801d3b:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801d3f:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801d43:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801d47:	8b 6c 24 24          	mov    0x24(%esp),%ebp
  801d4b:	85 c0                	test   %eax,%eax
  801d4d:	89 74 24 10          	mov    %esi,0x10(%esp)
  801d51:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801d55:	89 ea                	mov    %ebp,%edx
  801d57:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801d5b:	75 33                	jne    801d90 <__udivdi3+0x60>
  801d5d:	39 e9                	cmp    %ebp,%ecx
  801d5f:	77 6f                	ja     801dd0 <__udivdi3+0xa0>
  801d61:	85 c9                	test   %ecx,%ecx
  801d63:	89 ce                	mov    %ecx,%esi
  801d65:	75 0b                	jne    801d72 <__udivdi3+0x42>
  801d67:	b8 01 00 00 00       	mov    $0x1,%eax
  801d6c:	31 d2                	xor    %edx,%edx
  801d6e:	f7 f1                	div    %ecx
  801d70:	89 c6                	mov    %eax,%esi
  801d72:	31 d2                	xor    %edx,%edx
  801d74:	89 e8                	mov    %ebp,%eax
  801d76:	f7 f6                	div    %esi
  801d78:	89 c5                	mov    %eax,%ebp
  801d7a:	89 f8                	mov    %edi,%eax
  801d7c:	f7 f6                	div    %esi
  801d7e:	89 ea                	mov    %ebp,%edx
  801d80:	8b 74 24 10          	mov    0x10(%esp),%esi
  801d84:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801d88:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801d8c:	83 c4 1c             	add    $0x1c,%esp
  801d8f:	c3                   	ret    
  801d90:	39 e8                	cmp    %ebp,%eax
  801d92:	77 24                	ja     801db8 <__udivdi3+0x88>
  801d94:	0f bd c8             	bsr    %eax,%ecx
  801d97:	83 f1 1f             	xor    $0x1f,%ecx
  801d9a:	89 0c 24             	mov    %ecx,(%esp)
  801d9d:	75 49                	jne    801de8 <__udivdi3+0xb8>
  801d9f:	8b 74 24 08          	mov    0x8(%esp),%esi
  801da3:	39 74 24 04          	cmp    %esi,0x4(%esp)
  801da7:	0f 86 ab 00 00 00    	jbe    801e58 <__udivdi3+0x128>
  801dad:	39 e8                	cmp    %ebp,%eax
  801daf:	0f 82 a3 00 00 00    	jb     801e58 <__udivdi3+0x128>
  801db5:	8d 76 00             	lea    0x0(%esi),%esi
  801db8:	31 d2                	xor    %edx,%edx
  801dba:	31 c0                	xor    %eax,%eax
  801dbc:	8b 74 24 10          	mov    0x10(%esp),%esi
  801dc0:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801dc4:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801dc8:	83 c4 1c             	add    $0x1c,%esp
  801dcb:	c3                   	ret    
  801dcc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801dd0:	89 f8                	mov    %edi,%eax
  801dd2:	f7 f1                	div    %ecx
  801dd4:	31 d2                	xor    %edx,%edx
  801dd6:	8b 74 24 10          	mov    0x10(%esp),%esi
  801dda:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801dde:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801de2:	83 c4 1c             	add    $0x1c,%esp
  801de5:	c3                   	ret    
  801de6:	66 90                	xchg   %ax,%ax
  801de8:	0f b6 0c 24          	movzbl (%esp),%ecx
  801dec:	89 c6                	mov    %eax,%esi
  801dee:	b8 20 00 00 00       	mov    $0x20,%eax
  801df3:	8b 6c 24 04          	mov    0x4(%esp),%ebp
  801df7:	2b 04 24             	sub    (%esp),%eax
  801dfa:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801dfe:	d3 e6                	shl    %cl,%esi
  801e00:	89 c1                	mov    %eax,%ecx
  801e02:	d3 ed                	shr    %cl,%ebp
  801e04:	0f b6 0c 24          	movzbl (%esp),%ecx
  801e08:	09 f5                	or     %esi,%ebp
  801e0a:	8b 74 24 04          	mov    0x4(%esp),%esi
  801e0e:	d3 e6                	shl    %cl,%esi
  801e10:	89 c1                	mov    %eax,%ecx
  801e12:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e16:	89 d6                	mov    %edx,%esi
  801e18:	d3 ee                	shr    %cl,%esi
  801e1a:	0f b6 0c 24          	movzbl (%esp),%ecx
  801e1e:	d3 e2                	shl    %cl,%edx
  801e20:	89 c1                	mov    %eax,%ecx
  801e22:	d3 ef                	shr    %cl,%edi
  801e24:	09 d7                	or     %edx,%edi
  801e26:	89 f2                	mov    %esi,%edx
  801e28:	89 f8                	mov    %edi,%eax
  801e2a:	f7 f5                	div    %ebp
  801e2c:	89 d6                	mov    %edx,%esi
  801e2e:	89 c7                	mov    %eax,%edi
  801e30:	f7 64 24 04          	mull   0x4(%esp)
  801e34:	39 d6                	cmp    %edx,%esi
  801e36:	72 30                	jb     801e68 <__udivdi3+0x138>
  801e38:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801e3c:	0f b6 0c 24          	movzbl (%esp),%ecx
  801e40:	d3 e5                	shl    %cl,%ebp
  801e42:	39 c5                	cmp    %eax,%ebp
  801e44:	73 04                	jae    801e4a <__udivdi3+0x11a>
  801e46:	39 d6                	cmp    %edx,%esi
  801e48:	74 1e                	je     801e68 <__udivdi3+0x138>
  801e4a:	89 f8                	mov    %edi,%eax
  801e4c:	31 d2                	xor    %edx,%edx
  801e4e:	e9 69 ff ff ff       	jmp    801dbc <__udivdi3+0x8c>
  801e53:	90                   	nop
  801e54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e58:	31 d2                	xor    %edx,%edx
  801e5a:	b8 01 00 00 00       	mov    $0x1,%eax
  801e5f:	e9 58 ff ff ff       	jmp    801dbc <__udivdi3+0x8c>
  801e64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e68:	8d 47 ff             	lea    -0x1(%edi),%eax
  801e6b:	31 d2                	xor    %edx,%edx
  801e6d:	8b 74 24 10          	mov    0x10(%esp),%esi
  801e71:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801e75:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801e79:	83 c4 1c             	add    $0x1c,%esp
  801e7c:	c3                   	ret    
  801e7d:	66 90                	xchg   %ax,%ax
  801e7f:	90                   	nop

00801e80 <__umoddi3>:
  801e80:	83 ec 2c             	sub    $0x2c,%esp
  801e83:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801e87:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801e8b:	89 74 24 20          	mov    %esi,0x20(%esp)
  801e8f:	8b 74 24 38          	mov    0x38(%esp),%esi
  801e93:	89 7c 24 24          	mov    %edi,0x24(%esp)
  801e97:	8b 7c 24 34          	mov    0x34(%esp),%edi
  801e9b:	85 c0                	test   %eax,%eax
  801e9d:	89 c2                	mov    %eax,%edx
  801e9f:	89 6c 24 28          	mov    %ebp,0x28(%esp)
  801ea3:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801ea7:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801eab:	89 74 24 10          	mov    %esi,0x10(%esp)
  801eaf:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801eb3:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801eb7:	75 1f                	jne    801ed8 <__umoddi3+0x58>
  801eb9:	39 fe                	cmp    %edi,%esi
  801ebb:	76 63                	jbe    801f20 <__umoddi3+0xa0>
  801ebd:	89 c8                	mov    %ecx,%eax
  801ebf:	89 fa                	mov    %edi,%edx
  801ec1:	f7 f6                	div    %esi
  801ec3:	89 d0                	mov    %edx,%eax
  801ec5:	31 d2                	xor    %edx,%edx
  801ec7:	8b 74 24 20          	mov    0x20(%esp),%esi
  801ecb:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801ecf:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801ed3:	83 c4 2c             	add    $0x2c,%esp
  801ed6:	c3                   	ret    
  801ed7:	90                   	nop
  801ed8:	39 f8                	cmp    %edi,%eax
  801eda:	77 64                	ja     801f40 <__umoddi3+0xc0>
  801edc:	0f bd e8             	bsr    %eax,%ebp
  801edf:	83 f5 1f             	xor    $0x1f,%ebp
  801ee2:	75 74                	jne    801f58 <__umoddi3+0xd8>
  801ee4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801ee8:	39 7c 24 10          	cmp    %edi,0x10(%esp)
  801eec:	0f 87 0e 01 00 00    	ja     802000 <__umoddi3+0x180>
  801ef2:	8b 7c 24 0c          	mov    0xc(%esp),%edi
  801ef6:	29 f1                	sub    %esi,%ecx
  801ef8:	19 c7                	sbb    %eax,%edi
  801efa:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801efe:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801f02:	8b 44 24 14          	mov    0x14(%esp),%eax
  801f06:	8b 54 24 18          	mov    0x18(%esp),%edx
  801f0a:	8b 74 24 20          	mov    0x20(%esp),%esi
  801f0e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801f12:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801f16:	83 c4 2c             	add    $0x2c,%esp
  801f19:	c3                   	ret    
  801f1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f20:	85 f6                	test   %esi,%esi
  801f22:	89 f5                	mov    %esi,%ebp
  801f24:	75 0b                	jne    801f31 <__umoddi3+0xb1>
  801f26:	b8 01 00 00 00       	mov    $0x1,%eax
  801f2b:	31 d2                	xor    %edx,%edx
  801f2d:	f7 f6                	div    %esi
  801f2f:	89 c5                	mov    %eax,%ebp
  801f31:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801f35:	31 d2                	xor    %edx,%edx
  801f37:	f7 f5                	div    %ebp
  801f39:	89 c8                	mov    %ecx,%eax
  801f3b:	f7 f5                	div    %ebp
  801f3d:	eb 84                	jmp    801ec3 <__umoddi3+0x43>
  801f3f:	90                   	nop
  801f40:	89 c8                	mov    %ecx,%eax
  801f42:	89 fa                	mov    %edi,%edx
  801f44:	8b 74 24 20          	mov    0x20(%esp),%esi
  801f48:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801f4c:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801f50:	83 c4 2c             	add    $0x2c,%esp
  801f53:	c3                   	ret    
  801f54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f58:	8b 44 24 10          	mov    0x10(%esp),%eax
  801f5c:	be 20 00 00 00       	mov    $0x20,%esi
  801f61:	89 e9                	mov    %ebp,%ecx
  801f63:	29 ee                	sub    %ebp,%esi
  801f65:	d3 e2                	shl    %cl,%edx
  801f67:	89 f1                	mov    %esi,%ecx
  801f69:	d3 e8                	shr    %cl,%eax
  801f6b:	89 e9                	mov    %ebp,%ecx
  801f6d:	09 d0                	or     %edx,%eax
  801f6f:	89 fa                	mov    %edi,%edx
  801f71:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f75:	8b 44 24 10          	mov    0x10(%esp),%eax
  801f79:	d3 e0                	shl    %cl,%eax
  801f7b:	89 f1                	mov    %esi,%ecx
  801f7d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801f81:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801f85:	d3 ea                	shr    %cl,%edx
  801f87:	89 e9                	mov    %ebp,%ecx
  801f89:	d3 e7                	shl    %cl,%edi
  801f8b:	89 f1                	mov    %esi,%ecx
  801f8d:	d3 e8                	shr    %cl,%eax
  801f8f:	89 e9                	mov    %ebp,%ecx
  801f91:	09 f8                	or     %edi,%eax
  801f93:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801f97:	f7 74 24 0c          	divl   0xc(%esp)
  801f9b:	d3 e7                	shl    %cl,%edi
  801f9d:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801fa1:	89 d7                	mov    %edx,%edi
  801fa3:	f7 64 24 10          	mull   0x10(%esp)
  801fa7:	39 d7                	cmp    %edx,%edi
  801fa9:	89 c1                	mov    %eax,%ecx
  801fab:	89 54 24 14          	mov    %edx,0x14(%esp)
  801faf:	72 3b                	jb     801fec <__umoddi3+0x16c>
  801fb1:	39 44 24 18          	cmp    %eax,0x18(%esp)
  801fb5:	72 31                	jb     801fe8 <__umoddi3+0x168>
  801fb7:	8b 44 24 18          	mov    0x18(%esp),%eax
  801fbb:	29 c8                	sub    %ecx,%eax
  801fbd:	19 d7                	sbb    %edx,%edi
  801fbf:	89 e9                	mov    %ebp,%ecx
  801fc1:	89 fa                	mov    %edi,%edx
  801fc3:	d3 e8                	shr    %cl,%eax
  801fc5:	89 f1                	mov    %esi,%ecx
  801fc7:	d3 e2                	shl    %cl,%edx
  801fc9:	89 e9                	mov    %ebp,%ecx
  801fcb:	09 d0                	or     %edx,%eax
  801fcd:	89 fa                	mov    %edi,%edx
  801fcf:	d3 ea                	shr    %cl,%edx
  801fd1:	8b 74 24 20          	mov    0x20(%esp),%esi
  801fd5:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801fd9:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801fdd:	83 c4 2c             	add    $0x2c,%esp
  801fe0:	c3                   	ret    
  801fe1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fe8:	39 d7                	cmp    %edx,%edi
  801fea:	75 cb                	jne    801fb7 <__umoddi3+0x137>
  801fec:	8b 54 24 14          	mov    0x14(%esp),%edx
  801ff0:	89 c1                	mov    %eax,%ecx
  801ff2:	2b 4c 24 10          	sub    0x10(%esp),%ecx
  801ff6:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  801ffa:	eb bb                	jmp    801fb7 <__umoddi3+0x137>
  801ffc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802000:	3b 44 24 18          	cmp    0x18(%esp),%eax
  802004:	0f 82 e8 fe ff ff    	jb     801ef2 <__umoddi3+0x72>
  80200a:	e9 f3 fe ff ff       	jmp    801f02 <__umoddi3+0x82>
