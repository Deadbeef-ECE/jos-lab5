
obj/user/testbss.debug:     file format elf32-i386


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
  80002c:	e8 ef 00 00 00       	call   800120 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	90                   	nop

00800034 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  80003a:	c7 04 24 60 1d 80 00 	movl   $0x801d60,(%esp)
  800041:	e8 41 02 00 00       	call   800287 <cprintf>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
  800046:	83 3d 20 40 80 00 00 	cmpl   $0x0,0x804020
  80004d:	75 11                	jne    800060 <umain+0x2c>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  80004f:	b8 01 00 00 00       	mov    $0x1,%eax
		if (bigarray[i] != 0)
  800054:	83 3c 85 20 40 80 00 	cmpl   $0x0,0x804020(,%eax,4)
  80005b:	00 
  80005c:	74 27                	je     800085 <umain+0x51>
  80005e:	eb 05                	jmp    800065 <umain+0x31>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800060:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
  800065:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800069:	c7 44 24 08 db 1d 80 	movl   $0x801ddb,0x8(%esp)
  800070:	00 
  800071:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800078:	00 
  800079:	c7 04 24 f8 1d 80 00 	movl   $0x801df8,(%esp)
  800080:	e8 07 01 00 00       	call   80018c <_panic>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800085:	83 c0 01             	add    $0x1,%eax
  800088:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80008d:	75 c5                	jne    800054 <umain+0x20>
  80008f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
  800094:	89 04 85 20 40 80 00 	mov    %eax,0x804020(,%eax,4)

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  80009b:	83 c0 01             	add    $0x1,%eax
  80009e:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000a3:	75 ef                	jne    800094 <umain+0x60>
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != i)
  8000a5:	83 3d 20 40 80 00 00 	cmpl   $0x0,0x804020
  8000ac:	75 10                	jne    8000be <umain+0x8a>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000ae:	b8 01 00 00 00       	mov    $0x1,%eax
		if (bigarray[i] != i)
  8000b3:	3b 04 85 20 40 80 00 	cmp    0x804020(,%eax,4),%eax
  8000ba:	74 27                	je     8000e3 <umain+0xaf>
  8000bc:	eb 05                	jmp    8000c3 <umain+0x8f>
  8000be:	b8 00 00 00 00       	mov    $0x0,%eax
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000c7:	c7 44 24 08 80 1d 80 	movl   $0x801d80,0x8(%esp)
  8000ce:	00 
  8000cf:	c7 44 24 04 16 00 00 	movl   $0x16,0x4(%esp)
  8000d6:	00 
  8000d7:	c7 04 24 f8 1d 80 00 	movl   $0x801df8,(%esp)
  8000de:	e8 a9 00 00 00       	call   80018c <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000e3:	83 c0 01             	add    $0x1,%eax
  8000e6:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000eb:	75 c6                	jne    8000b3 <umain+0x7f>
		if (bigarray[i] != i)
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000ed:	c7 04 24 a8 1d 80 00 	movl   $0x801da8,(%esp)
  8000f4:	e8 8e 01 00 00       	call   800287 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000f9:	c7 05 20 50 c0 00 00 	movl   $0x0,0xc05020
  800100:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  800103:	c7 44 24 08 07 1e 80 	movl   $0x801e07,0x8(%esp)
  80010a:	00 
  80010b:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800112:	00 
  800113:	c7 04 24 f8 1d 80 00 	movl   $0x801df8,(%esp)
  80011a:	e8 6d 00 00 00       	call   80018c <_panic>
  80011f:	90                   	nop

00800120 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	83 ec 18             	sub    $0x18,%esp
  800126:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800129:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80012c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80012f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;

	thisenv = &envs[ENVX(sys_getenvid())];
  800132:	e8 b0 0c 00 00       	call   800de7 <sys_getenvid>
  800137:	25 ff 03 00 00       	and    $0x3ff,%eax
  80013c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80013f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800144:	a3 20 40 c0 00       	mov    %eax,0xc04020
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800149:	85 db                	test   %ebx,%ebx
  80014b:	7e 07                	jle    800154 <libmain+0x34>
		binaryname = argv[0];
  80014d:	8b 06                	mov    (%esi),%eax
  80014f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800154:	89 74 24 04          	mov    %esi,0x4(%esp)
  800158:	89 1c 24             	mov    %ebx,(%esp)
  80015b:	e8 d4 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800160:	e8 0b 00 00 00       	call   800170 <exit>
}
  800165:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800168:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80016b:	89 ec                	mov    %ebp,%esp
  80016d:	5d                   	pop    %ebp
  80016e:	c3                   	ret    
  80016f:	90                   	nop

00800170 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800176:	e8 f8 11 00 00       	call   801373 <close_all>
	sys_env_destroy(0);
  80017b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800182:	e8 fa 0b 00 00       	call   800d81 <sys_env_destroy>
}
  800187:	c9                   	leave  
  800188:	c3                   	ret    
  800189:	66 90                	xchg   %ax,%ax
  80018b:	90                   	nop

0080018c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	56                   	push   %esi
  800190:	53                   	push   %ebx
  800191:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800194:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800197:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80019d:	e8 45 0c 00 00       	call   800de7 <sys_getenvid>
  8001a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001a5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ac:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001b0:	89 74 24 08          	mov    %esi,0x8(%esp)
  8001b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b8:	c7 04 24 28 1e 80 00 	movl   $0x801e28,(%esp)
  8001bf:	e8 c3 00 00 00       	call   800287 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001c8:	8b 45 10             	mov    0x10(%ebp),%eax
  8001cb:	89 04 24             	mov    %eax,(%esp)
  8001ce:	e8 53 00 00 00       	call   800226 <vcprintf>
	cprintf("\n");
  8001d3:	c7 04 24 f6 1d 80 00 	movl   $0x801df6,(%esp)
  8001da:	e8 a8 00 00 00       	call   800287 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001df:	cc                   	int3   
  8001e0:	eb fd                	jmp    8001df <_panic+0x53>
  8001e2:	66 90                	xchg   %ax,%ax

008001e4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001e4:	55                   	push   %ebp
  8001e5:	89 e5                	mov    %esp,%ebp
  8001e7:	53                   	push   %ebx
  8001e8:	83 ec 14             	sub    $0x14,%esp
  8001eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001ee:	8b 03                	mov    (%ebx),%eax
  8001f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001f7:	83 c0 01             	add    $0x1,%eax
  8001fa:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001fc:	3d ff 00 00 00       	cmp    $0xff,%eax
  800201:	75 19                	jne    80021c <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800203:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80020a:	00 
  80020b:	8d 43 08             	lea    0x8(%ebx),%eax
  80020e:	89 04 24             	mov    %eax,(%esp)
  800211:	e8 fa 0a 00 00       	call   800d10 <sys_cputs>
		b->idx = 0;
  800216:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80021c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800220:	83 c4 14             	add    $0x14,%esp
  800223:	5b                   	pop    %ebx
  800224:	5d                   	pop    %ebp
  800225:	c3                   	ret    

00800226 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800226:	55                   	push   %ebp
  800227:	89 e5                	mov    %esp,%ebp
  800229:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80022f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800236:	00 00 00 
	b.cnt = 0;
  800239:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800240:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800243:	8b 45 0c             	mov    0xc(%ebp),%eax
  800246:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80024a:	8b 45 08             	mov    0x8(%ebp),%eax
  80024d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800251:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800257:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025b:	c7 04 24 e4 01 80 00 	movl   $0x8001e4,(%esp)
  800262:	e8 bb 01 00 00       	call   800422 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800267:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80026d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800271:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800277:	89 04 24             	mov    %eax,(%esp)
  80027a:	e8 91 0a 00 00       	call   800d10 <sys_cputs>

	return b.cnt;
}
  80027f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800285:	c9                   	leave  
  800286:	c3                   	ret    

00800287 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800287:	55                   	push   %ebp
  800288:	89 e5                	mov    %esp,%ebp
  80028a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80028d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800290:	89 44 24 04          	mov    %eax,0x4(%esp)
  800294:	8b 45 08             	mov    0x8(%ebp),%eax
  800297:	89 04 24             	mov    %eax,(%esp)
  80029a:	e8 87 ff ff ff       	call   800226 <vcprintf>
	va_end(ap);

	return cnt;
}
  80029f:	c9                   	leave  
  8002a0:	c3                   	ret    
  8002a1:	66 90                	xchg   %ax,%ax
  8002a3:	66 90                	xchg   %ax,%ax
  8002a5:	66 90                	xchg   %ax,%ax
  8002a7:	66 90                	xchg   %ax,%ax
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
  800325:	e8 56 17 00 00       	call   801a80 <__udivdi3>
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
  800383:	e8 48 18 00 00       	call   801bd0 <__umoddi3>
  800388:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80038c:	0f be 80 4b 1e 80 00 	movsbl 0x801e4b(%eax),%eax
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
  8004b7:	ff 24 85 a0 1f 80 00 	jmp    *0x801fa0(,%eax,4)
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
  800579:	8b 14 85 00 21 80 00 	mov    0x802100(,%eax,4),%edx
  800580:	85 d2                	test   %edx,%edx
  800582:	75 20                	jne    8005a4 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  800584:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800588:	c7 44 24 08 63 1e 80 	movl   $0x801e63,0x8(%esp)
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
  8005a8:	c7 44 24 08 6c 1e 80 	movl   $0x801e6c,0x8(%esp)
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
  8005da:	b8 5c 1e 80 00       	mov    $0x801e5c,%eax
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
  800dbe:	c7 44 24 08 5f 21 80 	movl   $0x80215f,0x8(%esp)
  800dc5:	00 
  800dc6:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800dcd:	00 
  800dce:	c7 04 24 7c 21 80 00 	movl   $0x80217c,(%esp)
  800dd5:	e8 b2 f3 ff ff       	call   80018c <_panic>

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
  800e98:	c7 44 24 08 5f 21 80 	movl   $0x80215f,0x8(%esp)
  800e9f:	00 
  800ea0:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800ea7:	00 
  800ea8:	c7 04 24 7c 21 80 00 	movl   $0x80217c,(%esp)
  800eaf:	e8 d8 f2 ff ff       	call   80018c <_panic>

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
  800eff:	c7 44 24 08 5f 21 80 	movl   $0x80215f,0x8(%esp)
  800f06:	00 
  800f07:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800f0e:	00 
  800f0f:	c7 04 24 7c 21 80 00 	movl   $0x80217c,(%esp)
  800f16:	e8 71 f2 ff ff       	call   80018c <_panic>

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
  800f66:	c7 44 24 08 5f 21 80 	movl   $0x80215f,0x8(%esp)
  800f6d:	00 
  800f6e:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800f75:	00 
  800f76:	c7 04 24 7c 21 80 00 	movl   $0x80217c,(%esp)
  800f7d:	e8 0a f2 ff ff       	call   80018c <_panic>

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
  800fcd:	c7 44 24 08 5f 21 80 	movl   $0x80215f,0x8(%esp)
  800fd4:	00 
  800fd5:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800fdc:	00 
  800fdd:	c7 04 24 7c 21 80 00 	movl   $0x80217c,(%esp)
  800fe4:	e8 a3 f1 ff ff       	call   80018c <_panic>

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
  801034:	c7 44 24 08 5f 21 80 	movl   $0x80215f,0x8(%esp)
  80103b:	00 
  80103c:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  801043:	00 
  801044:	c7 04 24 7c 21 80 00 	movl   $0x80217c,(%esp)
  80104b:	e8 3c f1 ff ff       	call   80018c <_panic>

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
  80109b:	c7 44 24 08 5f 21 80 	movl   $0x80215f,0x8(%esp)
  8010a2:	00 
  8010a3:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  8010aa:	00 
  8010ab:	c7 04 24 7c 21 80 00 	movl   $0x80217c,(%esp)
  8010b2:	e8 d5 f0 ff ff       	call   80018c <_panic>

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
  80113e:	c7 44 24 08 5f 21 80 	movl   $0x80215f,0x8(%esp)
  801145:	00 
  801146:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  80114d:	00 
  80114e:	c7 04 24 7c 21 80 00 	movl   $0x80217c,(%esp)
  801155:	e8 32 f0 ff ff       	call   80018c <_panic>

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
  801167:	66 90                	xchg   %ax,%ax
  801169:	66 90                	xchg   %ax,%ax
  80116b:	66 90                	xchg   %ax,%ax
  80116d:	66 90                	xchg   %ax,%ax
  80116f:	90                   	nop

00801170 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801170:	55                   	push   %ebp
  801171:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801173:	8b 45 08             	mov    0x8(%ebp),%eax
  801176:	05 00 00 00 30       	add    $0x30000000,%eax
  80117b:	c1 e8 0c             	shr    $0xc,%eax
}
  80117e:	5d                   	pop    %ebp
  80117f:	c3                   	ret    

00801180 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801180:	55                   	push   %ebp
  801181:	89 e5                	mov    %esp,%ebp
  801183:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801186:	8b 45 08             	mov    0x8(%ebp),%eax
  801189:	89 04 24             	mov    %eax,(%esp)
  80118c:	e8 df ff ff ff       	call   801170 <fd2num>
  801191:	c1 e0 0c             	shl    $0xc,%eax
  801194:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801199:	c9                   	leave  
  80119a:	c3                   	ret    

0080119b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80119b:	55                   	push   %ebp
  80119c:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  80119e:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8011a3:	a8 01                	test   $0x1,%al
  8011a5:	74 34                	je     8011db <fd_alloc+0x40>
  8011a7:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8011ac:	a8 01                	test   $0x1,%al
  8011ae:	74 32                	je     8011e2 <fd_alloc+0x47>
  8011b0:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8011b5:	89 c1                	mov    %eax,%ecx
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8011b7:	89 c2                	mov    %eax,%edx
  8011b9:	c1 ea 16             	shr    $0x16,%edx
  8011bc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011c3:	f6 c2 01             	test   $0x1,%dl
  8011c6:	74 1f                	je     8011e7 <fd_alloc+0x4c>
  8011c8:	89 c2                	mov    %eax,%edx
  8011ca:	c1 ea 0c             	shr    $0xc,%edx
  8011cd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011d4:	f6 c2 01             	test   $0x1,%dl
  8011d7:	75 1a                	jne    8011f3 <fd_alloc+0x58>
  8011d9:	eb 0c                	jmp    8011e7 <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8011db:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8011e0:	eb 05                	jmp    8011e7 <fd_alloc+0x4c>
  8011e2:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8011e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ea:	89 08                	mov    %ecx,(%eax)
			return 0;
  8011ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8011f1:	eb 1a                	jmp    80120d <fd_alloc+0x72>
  8011f3:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011f8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011fd:	75 b6                	jne    8011b5 <fd_alloc+0x1a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801202:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801208:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80120d:	5d                   	pop    %ebp
  80120e:	c3                   	ret    

0080120f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80120f:	55                   	push   %ebp
  801210:	89 e5                	mov    %esp,%ebp
  801212:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801215:	83 f8 1f             	cmp    $0x1f,%eax
  801218:	77 36                	ja     801250 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80121a:	c1 e0 0c             	shl    $0xc,%eax
  80121d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801222:	89 c2                	mov    %eax,%edx
  801224:	c1 ea 16             	shr    $0x16,%edx
  801227:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80122e:	f6 c2 01             	test   $0x1,%dl
  801231:	74 24                	je     801257 <fd_lookup+0x48>
  801233:	89 c2                	mov    %eax,%edx
  801235:	c1 ea 0c             	shr    $0xc,%edx
  801238:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80123f:	f6 c2 01             	test   $0x1,%dl
  801242:	74 1a                	je     80125e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801244:	8b 55 0c             	mov    0xc(%ebp),%edx
  801247:	89 02                	mov    %eax,(%edx)
	return 0;
  801249:	b8 00 00 00 00       	mov    $0x0,%eax
  80124e:	eb 13                	jmp    801263 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  801250:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801255:	eb 0c                	jmp    801263 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  801257:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80125c:	eb 05                	jmp    801263 <fd_lookup+0x54>
  80125e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801263:	5d                   	pop    %ebp
  801264:	c3                   	ret    

00801265 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801265:	55                   	push   %ebp
  801266:	89 e5                	mov    %esp,%ebp
  801268:	83 ec 18             	sub    $0x18,%esp
  80126b:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80126e:	39 05 04 30 80 00    	cmp    %eax,0x803004
  801274:	75 10                	jne    801286 <dev_lookup+0x21>
			*dev = devtab[i];
  801276:	8b 45 0c             	mov    0xc(%ebp),%eax
  801279:	c7 00 04 30 80 00    	movl   $0x803004,(%eax)
			return 0;
  80127f:	b8 00 00 00 00       	mov    $0x0,%eax
  801284:	eb 2b                	jmp    8012b1 <dev_lookup+0x4c>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801286:	8b 15 20 40 c0 00    	mov    0xc04020,%edx
  80128c:	8b 52 48             	mov    0x48(%edx),%edx
  80128f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801293:	89 54 24 04          	mov    %edx,0x4(%esp)
  801297:	c7 04 24 8c 21 80 00 	movl   $0x80218c,(%esp)
  80129e:	e8 e4 ef ff ff       	call   800287 <cprintf>
	*dev = 0;
  8012a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012a6:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	return -E_INVAL;
  8012ac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012b1:	c9                   	leave  
  8012b2:	c3                   	ret    

008012b3 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012b3:	55                   	push   %ebp
  8012b4:	89 e5                	mov    %esp,%ebp
  8012b6:	83 ec 38             	sub    $0x38,%esp
  8012b9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8012bc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8012bf:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8012c2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012c5:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012c8:	89 3c 24             	mov    %edi,(%esp)
  8012cb:	e8 a0 fe ff ff       	call   801170 <fd2num>
  8012d0:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8012d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8012d7:	89 04 24             	mov    %eax,(%esp)
  8012da:	e8 30 ff ff ff       	call   80120f <fd_lookup>
  8012df:	89 c3                	mov    %eax,%ebx
  8012e1:	85 c0                	test   %eax,%eax
  8012e3:	78 05                	js     8012ea <fd_close+0x37>
	    || fd != fd2)
  8012e5:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  8012e8:	74 0c                	je     8012f6 <fd_close+0x43>
		return (must_exist ? r : 0);
  8012ea:	85 f6                	test   %esi,%esi
  8012ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8012f1:	0f 44 d8             	cmove  %eax,%ebx
  8012f4:	eb 3d                	jmp    801333 <fd_close+0x80>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012f6:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8012f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012fd:	8b 07                	mov    (%edi),%eax
  8012ff:	89 04 24             	mov    %eax,(%esp)
  801302:	e8 5e ff ff ff       	call   801265 <dev_lookup>
  801307:	89 c3                	mov    %eax,%ebx
  801309:	85 c0                	test   %eax,%eax
  80130b:	78 16                	js     801323 <fd_close+0x70>
		if (dev->dev_close)
  80130d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801310:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801313:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801318:	85 c0                	test   %eax,%eax
  80131a:	74 07                	je     801323 <fd_close+0x70>
			r = (*dev->dev_close)(fd);
  80131c:	89 3c 24             	mov    %edi,(%esp)
  80131f:	ff d0                	call   *%eax
  801321:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801323:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801327:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80132e:	e8 f5 fb ff ff       	call   800f28 <sys_page_unmap>
	return r;
}
  801333:	89 d8                	mov    %ebx,%eax
  801335:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801338:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80133b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80133e:	89 ec                	mov    %ebp,%esp
  801340:	5d                   	pop    %ebp
  801341:	c3                   	ret    

00801342 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801342:	55                   	push   %ebp
  801343:	89 e5                	mov    %esp,%ebp
  801345:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801348:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80134b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80134f:	8b 45 08             	mov    0x8(%ebp),%eax
  801352:	89 04 24             	mov    %eax,(%esp)
  801355:	e8 b5 fe ff ff       	call   80120f <fd_lookup>
  80135a:	85 c0                	test   %eax,%eax
  80135c:	78 13                	js     801371 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80135e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801365:	00 
  801366:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801369:	89 04 24             	mov    %eax,(%esp)
  80136c:	e8 42 ff ff ff       	call   8012b3 <fd_close>
}
  801371:	c9                   	leave  
  801372:	c3                   	ret    

00801373 <close_all>:

void
close_all(void)
{
  801373:	55                   	push   %ebp
  801374:	89 e5                	mov    %esp,%ebp
  801376:	53                   	push   %ebx
  801377:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80137a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80137f:	89 1c 24             	mov    %ebx,(%esp)
  801382:	e8 bb ff ff ff       	call   801342 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801387:	83 c3 01             	add    $0x1,%ebx
  80138a:	83 fb 20             	cmp    $0x20,%ebx
  80138d:	75 f0                	jne    80137f <close_all+0xc>
		close(i);
}
  80138f:	83 c4 14             	add    $0x14,%esp
  801392:	5b                   	pop    %ebx
  801393:	5d                   	pop    %ebp
  801394:	c3                   	ret    

00801395 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801395:	55                   	push   %ebp
  801396:	89 e5                	mov    %esp,%ebp
  801398:	83 ec 58             	sub    $0x58,%esp
  80139b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80139e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8013a1:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8013a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013a7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b1:	89 04 24             	mov    %eax,(%esp)
  8013b4:	e8 56 fe ff ff       	call   80120f <fd_lookup>
  8013b9:	85 c0                	test   %eax,%eax
  8013bb:	0f 88 e3 00 00 00    	js     8014a4 <dup+0x10f>
		return r;
	close(newfdnum);
  8013c1:	89 1c 24             	mov    %ebx,(%esp)
  8013c4:	e8 79 ff ff ff       	call   801342 <close>

	newfd = INDEX2FD(newfdnum);
  8013c9:	89 de                	mov    %ebx,%esi
  8013cb:	c1 e6 0c             	shl    $0xc,%esi
  8013ce:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8013d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013d7:	89 04 24             	mov    %eax,(%esp)
  8013da:	e8 a1 fd ff ff       	call   801180 <fd2data>
  8013df:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013e1:	89 34 24             	mov    %esi,(%esp)
  8013e4:	e8 97 fd ff ff       	call   801180 <fd2data>
  8013e9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  8013ec:	89 f8                	mov    %edi,%eax
  8013ee:	c1 e8 16             	shr    $0x16,%eax
  8013f1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013f8:	a8 01                	test   $0x1,%al
  8013fa:	74 46                	je     801442 <dup+0xad>
  8013fc:	89 f8                	mov    %edi,%eax
  8013fe:	c1 e8 0c             	shr    $0xc,%eax
  801401:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801408:	f6 c2 01             	test   $0x1,%dl
  80140b:	74 35                	je     801442 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80140d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801414:	25 07 0e 00 00       	and    $0xe07,%eax
  801419:	89 44 24 10          	mov    %eax,0x10(%esp)
  80141d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801420:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801424:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80142b:	00 
  80142c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801430:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801437:	e8 85 fa ff ff       	call   800ec1 <sys_page_map>
  80143c:	89 c7                	mov    %eax,%edi
  80143e:	85 c0                	test   %eax,%eax
  801440:	78 3b                	js     80147d <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801442:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801445:	89 c2                	mov    %eax,%edx
  801447:	c1 ea 0c             	shr    $0xc,%edx
  80144a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801451:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801457:	89 54 24 10          	mov    %edx,0x10(%esp)
  80145b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80145f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801466:	00 
  801467:	89 44 24 04          	mov    %eax,0x4(%esp)
  80146b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801472:	e8 4a fa ff ff       	call   800ec1 <sys_page_map>
  801477:	89 c7                	mov    %eax,%edi
  801479:	85 c0                	test   %eax,%eax
  80147b:	79 29                	jns    8014a6 <dup+0x111>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80147d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801481:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801488:	e8 9b fa ff ff       	call   800f28 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80148d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801490:	89 44 24 04          	mov    %eax,0x4(%esp)
  801494:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80149b:	e8 88 fa ff ff       	call   800f28 <sys_page_unmap>
	return r;
  8014a0:	89 fb                	mov    %edi,%ebx
  8014a2:	eb 02                	jmp    8014a6 <dup+0x111>
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
		return r;
  8014a4:	89 c3                	mov    %eax,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8014a6:	89 d8                	mov    %ebx,%eax
  8014a8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8014ab:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8014ae:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8014b1:	89 ec                	mov    %ebp,%esp
  8014b3:	5d                   	pop    %ebp
  8014b4:	c3                   	ret    

008014b5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014b5:	55                   	push   %ebp
  8014b6:	89 e5                	mov    %esp,%ebp
  8014b8:	53                   	push   %ebx
  8014b9:	83 ec 24             	sub    $0x24,%esp
  8014bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014bf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014c6:	89 1c 24             	mov    %ebx,(%esp)
  8014c9:	e8 41 fd ff ff       	call   80120f <fd_lookup>
  8014ce:	85 c0                	test   %eax,%eax
  8014d0:	78 6d                	js     80153f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014dc:	8b 00                	mov    (%eax),%eax
  8014de:	89 04 24             	mov    %eax,(%esp)
  8014e1:	e8 7f fd ff ff       	call   801265 <dev_lookup>
  8014e6:	85 c0                	test   %eax,%eax
  8014e8:	78 55                	js     80153f <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ed:	8b 50 08             	mov    0x8(%eax),%edx
  8014f0:	83 e2 03             	and    $0x3,%edx
  8014f3:	83 fa 01             	cmp    $0x1,%edx
  8014f6:	75 23                	jne    80151b <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014f8:	a1 20 40 c0 00       	mov    0xc04020,%eax
  8014fd:	8b 40 48             	mov    0x48(%eax),%eax
  801500:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801504:	89 44 24 04          	mov    %eax,0x4(%esp)
  801508:	c7 04 24 d0 21 80 00 	movl   $0x8021d0,(%esp)
  80150f:	e8 73 ed ff ff       	call   800287 <cprintf>
		return -E_INVAL;
  801514:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801519:	eb 24                	jmp    80153f <read+0x8a>
	}
	if (!dev->dev_read)
  80151b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80151e:	8b 52 08             	mov    0x8(%edx),%edx
  801521:	85 d2                	test   %edx,%edx
  801523:	74 15                	je     80153a <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801525:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801528:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80152c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80152f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801533:	89 04 24             	mov    %eax,(%esp)
  801536:	ff d2                	call   *%edx
  801538:	eb 05                	jmp    80153f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80153a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80153f:	83 c4 24             	add    $0x24,%esp
  801542:	5b                   	pop    %ebx
  801543:	5d                   	pop    %ebp
  801544:	c3                   	ret    

00801545 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801545:	55                   	push   %ebp
  801546:	89 e5                	mov    %esp,%ebp
  801548:	57                   	push   %edi
  801549:	56                   	push   %esi
  80154a:	53                   	push   %ebx
  80154b:	83 ec 1c             	sub    $0x1c,%esp
  80154e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801551:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801554:	85 f6                	test   %esi,%esi
  801556:	74 33                	je     80158b <readn+0x46>
  801558:	b8 00 00 00 00       	mov    $0x0,%eax
  80155d:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801562:	89 f2                	mov    %esi,%edx
  801564:	29 c2                	sub    %eax,%edx
  801566:	89 54 24 08          	mov    %edx,0x8(%esp)
  80156a:	03 45 0c             	add    0xc(%ebp),%eax
  80156d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801571:	89 3c 24             	mov    %edi,(%esp)
  801574:	e8 3c ff ff ff       	call   8014b5 <read>
		if (m < 0)
  801579:	85 c0                	test   %eax,%eax
  80157b:	78 17                	js     801594 <readn+0x4f>
			return m;
		if (m == 0)
  80157d:	85 c0                	test   %eax,%eax
  80157f:	74 11                	je     801592 <readn+0x4d>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801581:	01 c3                	add    %eax,%ebx
  801583:	89 d8                	mov    %ebx,%eax
  801585:	39 f3                	cmp    %esi,%ebx
  801587:	72 d9                	jb     801562 <readn+0x1d>
  801589:	eb 09                	jmp    801594 <readn+0x4f>
  80158b:	b8 00 00 00 00       	mov    $0x0,%eax
  801590:	eb 02                	jmp    801594 <readn+0x4f>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801592:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801594:	83 c4 1c             	add    $0x1c,%esp
  801597:	5b                   	pop    %ebx
  801598:	5e                   	pop    %esi
  801599:	5f                   	pop    %edi
  80159a:	5d                   	pop    %ebp
  80159b:	c3                   	ret    

0080159c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80159c:	55                   	push   %ebp
  80159d:	89 e5                	mov    %esp,%ebp
  80159f:	53                   	push   %ebx
  8015a0:	83 ec 24             	sub    $0x24,%esp
  8015a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015ad:	89 1c 24             	mov    %ebx,(%esp)
  8015b0:	e8 5a fc ff ff       	call   80120f <fd_lookup>
  8015b5:	85 c0                	test   %eax,%eax
  8015b7:	78 68                	js     801621 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c3:	8b 00                	mov    (%eax),%eax
  8015c5:	89 04 24             	mov    %eax,(%esp)
  8015c8:	e8 98 fc ff ff       	call   801265 <dev_lookup>
  8015cd:	85 c0                	test   %eax,%eax
  8015cf:	78 50                	js     801621 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015d8:	75 23                	jne    8015fd <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015da:	a1 20 40 c0 00       	mov    0xc04020,%eax
  8015df:	8b 40 48             	mov    0x48(%eax),%eax
  8015e2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8015e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015ea:	c7 04 24 ec 21 80 00 	movl   $0x8021ec,(%esp)
  8015f1:	e8 91 ec ff ff       	call   800287 <cprintf>
		return -E_INVAL;
  8015f6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015fb:	eb 24                	jmp    801621 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801600:	8b 52 0c             	mov    0xc(%edx),%edx
  801603:	85 d2                	test   %edx,%edx
  801605:	74 15                	je     80161c <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801607:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80160a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80160e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801611:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801615:	89 04 24             	mov    %eax,(%esp)
  801618:	ff d2                	call   *%edx
  80161a:	eb 05                	jmp    801621 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80161c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801621:	83 c4 24             	add    $0x24,%esp
  801624:	5b                   	pop    %ebx
  801625:	5d                   	pop    %ebp
  801626:	c3                   	ret    

00801627 <seek>:

int
seek(int fdnum, off_t offset)
{
  801627:	55                   	push   %ebp
  801628:	89 e5                	mov    %esp,%ebp
  80162a:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80162d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801630:	89 44 24 04          	mov    %eax,0x4(%esp)
  801634:	8b 45 08             	mov    0x8(%ebp),%eax
  801637:	89 04 24             	mov    %eax,(%esp)
  80163a:	e8 d0 fb ff ff       	call   80120f <fd_lookup>
  80163f:	85 c0                	test   %eax,%eax
  801641:	78 0e                	js     801651 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801643:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801646:	8b 55 0c             	mov    0xc(%ebp),%edx
  801649:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80164c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801651:	c9                   	leave  
  801652:	c3                   	ret    

00801653 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801653:	55                   	push   %ebp
  801654:	89 e5                	mov    %esp,%ebp
  801656:	53                   	push   %ebx
  801657:	83 ec 24             	sub    $0x24,%esp
  80165a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80165d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801660:	89 44 24 04          	mov    %eax,0x4(%esp)
  801664:	89 1c 24             	mov    %ebx,(%esp)
  801667:	e8 a3 fb ff ff       	call   80120f <fd_lookup>
  80166c:	85 c0                	test   %eax,%eax
  80166e:	78 61                	js     8016d1 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801670:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801673:	89 44 24 04          	mov    %eax,0x4(%esp)
  801677:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80167a:	8b 00                	mov    (%eax),%eax
  80167c:	89 04 24             	mov    %eax,(%esp)
  80167f:	e8 e1 fb ff ff       	call   801265 <dev_lookup>
  801684:	85 c0                	test   %eax,%eax
  801686:	78 49                	js     8016d1 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801688:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80168b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80168f:	75 23                	jne    8016b4 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801691:	a1 20 40 c0 00       	mov    0xc04020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801696:	8b 40 48             	mov    0x48(%eax),%eax
  801699:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80169d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016a1:	c7 04 24 ac 21 80 00 	movl   $0x8021ac,(%esp)
  8016a8:	e8 da eb ff ff       	call   800287 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016b2:	eb 1d                	jmp    8016d1 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8016b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016b7:	8b 52 18             	mov    0x18(%edx),%edx
  8016ba:	85 d2                	test   %edx,%edx
  8016bc:	74 0e                	je     8016cc <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016c1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8016c5:	89 04 24             	mov    %eax,(%esp)
  8016c8:	ff d2                	call   *%edx
  8016ca:	eb 05                	jmp    8016d1 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016cc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8016d1:	83 c4 24             	add    $0x24,%esp
  8016d4:	5b                   	pop    %ebx
  8016d5:	5d                   	pop    %ebp
  8016d6:	c3                   	ret    

008016d7 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016d7:	55                   	push   %ebp
  8016d8:	89 e5                	mov    %esp,%ebp
  8016da:	53                   	push   %ebx
  8016db:	83 ec 24             	sub    $0x24,%esp
  8016de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016e1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8016eb:	89 04 24             	mov    %eax,(%esp)
  8016ee:	e8 1c fb ff ff       	call   80120f <fd_lookup>
  8016f3:	85 c0                	test   %eax,%eax
  8016f5:	78 52                	js     801749 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801701:	8b 00                	mov    (%eax),%eax
  801703:	89 04 24             	mov    %eax,(%esp)
  801706:	e8 5a fb ff ff       	call   801265 <dev_lookup>
  80170b:	85 c0                	test   %eax,%eax
  80170d:	78 3a                	js     801749 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  80170f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801712:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801716:	74 2c                	je     801744 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801718:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80171b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801722:	00 00 00 
	stat->st_isdir = 0;
  801725:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80172c:	00 00 00 
	stat->st_dev = dev;
  80172f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801735:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801739:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80173c:	89 14 24             	mov    %edx,(%esp)
  80173f:	ff 50 14             	call   *0x14(%eax)
  801742:	eb 05                	jmp    801749 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801744:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801749:	83 c4 24             	add    $0x24,%esp
  80174c:	5b                   	pop    %ebx
  80174d:	5d                   	pop    %ebp
  80174e:	c3                   	ret    

0080174f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80174f:	55                   	push   %ebp
  801750:	89 e5                	mov    %esp,%ebp
  801752:	83 ec 18             	sub    $0x18,%esp
  801755:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801758:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80175b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801762:	00 
  801763:	8b 45 08             	mov    0x8(%ebp),%eax
  801766:	89 04 24             	mov    %eax,(%esp)
  801769:	e8 84 01 00 00       	call   8018f2 <open>
  80176e:	89 c3                	mov    %eax,%ebx
  801770:	85 c0                	test   %eax,%eax
  801772:	78 1b                	js     80178f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801774:	8b 45 0c             	mov    0xc(%ebp),%eax
  801777:	89 44 24 04          	mov    %eax,0x4(%esp)
  80177b:	89 1c 24             	mov    %ebx,(%esp)
  80177e:	e8 54 ff ff ff       	call   8016d7 <fstat>
  801783:	89 c6                	mov    %eax,%esi
	close(fd);
  801785:	89 1c 24             	mov    %ebx,(%esp)
  801788:	e8 b5 fb ff ff       	call   801342 <close>
	return r;
  80178d:	89 f3                	mov    %esi,%ebx
}
  80178f:	89 d8                	mov    %ebx,%eax
  801791:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801794:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801797:	89 ec                	mov    %ebp,%esp
  801799:	5d                   	pop    %ebp
  80179a:	c3                   	ret    
  80179b:	90                   	nop

0080179c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80179c:	55                   	push   %ebp
  80179d:	89 e5                	mov    %esp,%ebp
  80179f:	83 ec 18             	sub    $0x18,%esp
  8017a2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8017a5:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8017a8:	89 c6                	mov    %eax,%esi
  8017aa:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017ac:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017b3:	75 11                	jne    8017c6 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017b5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8017bc:	e8 72 02 00 00       	call   801a33 <ipc_find_env>
  8017c1:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017c6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8017cd:	00 
  8017ce:	c7 44 24 08 00 50 c0 	movl   $0xc05000,0x8(%esp)
  8017d5:	00 
  8017d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017da:	a1 00 40 80 00       	mov    0x804000,%eax
  8017df:	89 04 24             	mov    %eax,(%esp)
  8017e2:	e8 e1 01 00 00       	call   8019c8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017e7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017ee:	00 
  8017ef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017f3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017fa:	e8 71 01 00 00       	call   801970 <ipc_recv>
}
  8017ff:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801802:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801805:	89 ec                	mov    %ebp,%esp
  801807:	5d                   	pop    %ebp
  801808:	c3                   	ret    

00801809 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801809:	55                   	push   %ebp
  80180a:	89 e5                	mov    %esp,%ebp
  80180c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80180f:	8b 45 08             	mov    0x8(%ebp),%eax
  801812:	8b 40 0c             	mov    0xc(%eax),%eax
  801815:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.set_size.req_size = newsize;
  80181a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80181d:	a3 04 50 c0 00       	mov    %eax,0xc05004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801822:	ba 00 00 00 00       	mov    $0x0,%edx
  801827:	b8 02 00 00 00       	mov    $0x2,%eax
  80182c:	e8 6b ff ff ff       	call   80179c <fsipc>
}
  801831:	c9                   	leave  
  801832:	c3                   	ret    

00801833 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801833:	55                   	push   %ebp
  801834:	89 e5                	mov    %esp,%ebp
  801836:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801839:	8b 45 08             	mov    0x8(%ebp),%eax
  80183c:	8b 40 0c             	mov    0xc(%eax),%eax
  80183f:	a3 00 50 c0 00       	mov    %eax,0xc05000
	return fsipc(FSREQ_FLUSH, NULL);
  801844:	ba 00 00 00 00       	mov    $0x0,%edx
  801849:	b8 06 00 00 00       	mov    $0x6,%eax
  80184e:	e8 49 ff ff ff       	call   80179c <fsipc>
}
  801853:	c9                   	leave  
  801854:	c3                   	ret    

00801855 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801855:	55                   	push   %ebp
  801856:	89 e5                	mov    %esp,%ebp
  801858:	53                   	push   %ebx
  801859:	83 ec 14             	sub    $0x14,%esp
  80185c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80185f:	8b 45 08             	mov    0x8(%ebp),%eax
  801862:	8b 40 0c             	mov    0xc(%eax),%eax
  801865:	a3 00 50 c0 00       	mov    %eax,0xc05000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80186a:	ba 00 00 00 00       	mov    $0x0,%edx
  80186f:	b8 05 00 00 00       	mov    $0x5,%eax
  801874:	e8 23 ff ff ff       	call   80179c <fsipc>
  801879:	85 c0                	test   %eax,%eax
  80187b:	78 2b                	js     8018a8 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80187d:	c7 44 24 04 00 50 c0 	movl   $0xc05000,0x4(%esp)
  801884:	00 
  801885:	89 1c 24             	mov    %ebx,(%esp)
  801888:	e8 7e f0 ff ff       	call   80090b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80188d:	a1 80 50 c0 00       	mov    0xc05080,%eax
  801892:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801898:	a1 84 50 c0 00       	mov    0xc05084,%eax
  80189d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018a8:	83 c4 14             	add    $0x14,%esp
  8018ab:	5b                   	pop    %ebx
  8018ac:	5d                   	pop    %ebp
  8018ad:	c3                   	ret    

008018ae <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018ae:	55                   	push   %ebp
  8018af:	89 e5                	mov    %esp,%ebp
  8018b1:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8018b4:	c7 44 24 08 09 22 80 	movl   $0x802209,0x8(%esp)
  8018bb:	00 
  8018bc:	c7 44 24 04 77 00 00 	movl   $0x77,0x4(%esp)
  8018c3:	00 
  8018c4:	c7 04 24 27 22 80 00 	movl   $0x802227,(%esp)
  8018cb:	e8 bc e8 ff ff       	call   80018c <_panic>

008018d0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018d0:	55                   	push   %ebp
  8018d1:	89 e5                	mov    %esp,%ebp
  8018d3:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_READ request to the file system server after
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
	panic("devfile_read not implemented");
  8018d6:	c7 44 24 08 32 22 80 	movl   $0x802232,0x8(%esp)
  8018dd:	00 
  8018de:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
  8018e5:	00 
  8018e6:	c7 04 24 27 22 80 00 	movl   $0x802227,(%esp)
  8018ed:	e8 9a e8 ff ff       	call   80018c <_panic>

008018f2 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018f2:	55                   	push   %ebp
  8018f3:	89 e5                	mov    %esp,%ebp
  8018f5:	83 ec 18             	sub    $0x18,%esp
	// Return the file descriptor index.
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
	panic("open not implemented");
  8018f8:	c7 44 24 08 4f 22 80 	movl   $0x80224f,0x8(%esp)
  8018ff:	00 
  801900:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  801907:	00 
  801908:	c7 04 24 27 22 80 00 	movl   $0x802227,(%esp)
  80190f:	e8 78 e8 ff ff       	call   80018c <_panic>

00801914 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801914:	55                   	push   %ebp
  801915:	89 e5                	mov    %esp,%ebp
  801917:	53                   	push   %ebx
  801918:	83 ec 14             	sub    $0x14,%esp
  80191b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  80191e:	89 1c 24             	mov    %ebx,(%esp)
  801921:	e8 8a ef ff ff       	call   8008b0 <strlen>
  801926:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80192b:	7f 21                	jg     80194e <remove+0x3a>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  80192d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801931:	c7 04 24 00 50 c0 00 	movl   $0xc05000,(%esp)
  801938:	e8 ce ef ff ff       	call   80090b <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  80193d:	ba 00 00 00 00       	mov    $0x0,%edx
  801942:	b8 07 00 00 00       	mov    $0x7,%eax
  801947:	e8 50 fe ff ff       	call   80179c <fsipc>
  80194c:	eb 05                	jmp    801953 <remove+0x3f>
// Delete a file
int
remove(const char *path)
{
	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80194e:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
	strcpy(fsipcbuf.remove.req_path, path);
	return fsipc(FSREQ_REMOVE, NULL);
}
  801953:	83 c4 14             	add    $0x14,%esp
  801956:	5b                   	pop    %ebx
  801957:	5d                   	pop    %ebp
  801958:	c3                   	ret    

00801959 <sync>:

// Synchronize disk with buffer cache
int
sync(void)
{
  801959:	55                   	push   %ebp
  80195a:	89 e5                	mov    %esp,%ebp
  80195c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80195f:	ba 00 00 00 00       	mov    $0x0,%edx
  801964:	b8 08 00 00 00       	mov    $0x8,%eax
  801969:	e8 2e fe ff ff       	call   80179c <fsipc>
}
  80196e:	c9                   	leave  
  80196f:	c3                   	ret    

00801970 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801970:	55                   	push   %ebp
  801971:	89 e5                	mov    %esp,%ebp
  801973:	56                   	push   %esi
  801974:	53                   	push   %ebx
  801975:	83 ec 10             	sub    $0x10,%esp
  801978:	8b 75 08             	mov    0x8(%ebp),%esi
  80197b:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	// 	return thisenv->env_ipc_value;
	// }
	int r;
	if(pg == NULL)
		pg = (void *)~0x0;
  80197e:	85 db                	test   %ebx,%ebx
  801980:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801985:	0f 44 d8             	cmove  %eax,%ebx
	//else
	if((r = sys_ipc_recv(pg)) < 0)
  801988:	89 1c 24             	mov    %ebx,(%esp)
  80198b:	e8 71 f7 ff ff       	call   801101 <sys_ipc_recv>
  801990:	85 c0                	test   %eax,%eax
  801992:	78 2d                	js     8019c1 <ipc_recv+0x51>
		return r;
	//volatile struct Env *curenv = (struct Env*)envs+ENVX(sys_getenvid());

	if(from_env_store)
  801994:	85 f6                	test   %esi,%esi
  801996:	74 0a                	je     8019a2 <ipc_recv+0x32>
		*from_env_store = thisenv -> env_ipc_from;
  801998:	a1 20 40 c0 00       	mov    0xc04020,%eax
  80199d:	8b 40 74             	mov    0x74(%eax),%eax
  8019a0:	89 06                	mov    %eax,(%esi)
	if(pg && perm_store)
  8019a2:	85 db                	test   %ebx,%ebx
  8019a4:	74 13                	je     8019b9 <ipc_recv+0x49>
  8019a6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019aa:	74 0d                	je     8019b9 <ipc_recv+0x49>
		*perm_store = thisenv -> env_ipc_perm;
  8019ac:	a1 20 40 c0 00       	mov    0xc04020,%eax
  8019b1:	8b 40 78             	mov    0x78(%eax),%eax
  8019b4:	8b 55 10             	mov    0x10(%ebp),%edx
  8019b7:	89 02                	mov    %eax,(%edx)
	else if(perm_store)
		perm_store = (int *)0;
	return thisenv->env_ipc_value;
  8019b9:	a1 20 40 c0 00       	mov    0xc04020,%eax
  8019be:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  8019c1:	83 c4 10             	add    $0x10,%esp
  8019c4:	5b                   	pop    %ebx
  8019c5:	5e                   	pop    %esi
  8019c6:	5d                   	pop    %ebp
  8019c7:	c3                   	ret    

008019c8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8019c8:	55                   	push   %ebp
  8019c9:	89 e5                	mov    %esp,%ebp
  8019cb:	57                   	push   %edi
  8019cc:	56                   	push   %esi
  8019cd:	53                   	push   %ebx
  8019ce:	83 ec 1c             	sub    $0x1c,%esp
  8019d1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8019d4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019d7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

	if(pg == NULL)
  8019da:	85 db                	test   %ebx,%ebx
		pg = (void *)~0x0;
  8019dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8019e1:	0f 44 d8             	cmove  %eax,%ebx
  8019e4:	eb 2a                	jmp    801a10 <ipc_send+0x48>
	while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0){
		if(r != -E_IPC_NOT_RECV)
  8019e6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8019e9:	74 20                	je     801a0b <ipc_send+0x43>
            panic("Send message error %e\n",r);
  8019eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019ef:	c7 44 24 08 64 22 80 	movl   $0x802264,0x8(%esp)
  8019f6:	00 
  8019f7:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8019fe:	00 
  8019ff:	c7 04 24 7b 22 80 00 	movl   $0x80227b,(%esp)
  801a06:	e8 81 e7 ff ff       	call   80018c <_panic>
		sys_yield();
  801a0b:	e8 10 f4 ff ff       	call   800e20 <sys_yield>
	// LAB 4: Your code here.
	int r;

	if(pg == NULL)
		pg = (void *)~0x0;
	while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0){
  801a10:	8b 45 14             	mov    0x14(%ebp),%eax
  801a13:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a17:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a1b:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a1f:	89 3c 24             	mov    %edi,(%esp)
  801a22:	e8 9d f6 ff ff       	call   8010c4 <sys_ipc_try_send>
  801a27:	85 c0                	test   %eax,%eax
  801a29:	78 bb                	js     8019e6 <ipc_send+0x1e>
            panic("Send message error %e\n",r);
		sys_yield();
	}

	//panic("ipc_send not implemented");
}
  801a2b:	83 c4 1c             	add    $0x1c,%esp
  801a2e:	5b                   	pop    %ebx
  801a2f:	5e                   	pop    %esi
  801a30:	5f                   	pop    %edi
  801a31:	5d                   	pop    %ebp
  801a32:	c3                   	ret    

00801a33 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801a33:	55                   	push   %ebp
  801a34:	89 e5                	mov    %esp,%ebp
  801a36:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801a39:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801a3e:	39 c8                	cmp    %ecx,%eax
  801a40:	74 17                	je     801a59 <ipc_find_env+0x26>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801a42:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801a47:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801a4a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801a50:	8b 52 50             	mov    0x50(%edx),%edx
  801a53:	39 ca                	cmp    %ecx,%edx
  801a55:	75 14                	jne    801a6b <ipc_find_env+0x38>
  801a57:	eb 05                	jmp    801a5e <ipc_find_env+0x2b>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801a59:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801a5e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801a61:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801a66:	8b 40 40             	mov    0x40(%eax),%eax
  801a69:	eb 0e                	jmp    801a79 <ipc_find_env+0x46>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801a6b:	83 c0 01             	add    $0x1,%eax
  801a6e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801a73:	75 d2                	jne    801a47 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801a75:	66 b8 00 00          	mov    $0x0,%ax
}
  801a79:	5d                   	pop    %ebp
  801a7a:	c3                   	ret    
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
