
obj/user/icode.debug:     file format elf32-i386


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
  80002c:	e8 2b 01 00 00       	call   80015c <libmain>
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
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	81 ec 30 02 00 00    	sub    $0x230,%esp
	int fd, n, r;
	char buf[512+1];

	binaryname = "icode";
  80003f:	c7 05 00 30 80 00 c0 	movl   $0x8023c0,0x803000
  800046:	23 80 00 

	cprintf("icode startup\n");
  800049:	c7 04 24 c6 23 80 00 	movl   $0x8023c6,(%esp)
  800050:	e8 6e 02 00 00       	call   8002c3 <cprintf>

	cprintf("icode: open /motd\n");
  800055:	c7 04 24 d5 23 80 00 	movl   $0x8023d5,(%esp)
  80005c:	e8 62 02 00 00       	call   8002c3 <cprintf>
	if ((fd = open("/motd", O_RDONLY)) < 0)
  800061:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800068:	00 
  800069:	c7 04 24 e8 23 80 00 	movl   $0x8023e8,(%esp)
  800070:	e8 ad 18 00 00       	call   801922 <open>
  800075:	89 c6                	mov    %eax,%esi
  800077:	85 c0                	test   %eax,%eax
  800079:	79 20                	jns    80009b <umain+0x67>
		panic("icode: open /motd: %e", fd);
  80007b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80007f:	c7 44 24 08 ee 23 80 	movl   $0x8023ee,0x8(%esp)
  800086:	00 
  800087:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  80008e:	00 
  80008f:	c7 04 24 04 24 80 00 	movl   $0x802404,(%esp)
  800096:	e8 2d 01 00 00       	call   8001c8 <_panic>

	cprintf("icode: read /motd\n");
  80009b:	c7 04 24 11 24 80 00 	movl   $0x802411,(%esp)
  8000a2:	e8 1c 02 00 00       	call   8002c3 <cprintf>
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  8000a7:	8d 9d f7 fd ff ff    	lea    -0x209(%ebp),%ebx
  8000ad:	eb 0c                	jmp    8000bb <umain+0x87>
		sys_cputs(buf, n);
  8000af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b3:	89 1c 24             	mov    %ebx,(%esp)
  8000b6:	e8 85 0c 00 00       	call   800d40 <sys_cputs>
	cprintf("icode: open /motd\n");
	if ((fd = open("/motd", O_RDONLY)) < 0)
		panic("icode: open /motd: %e", fd);

	cprintf("icode: read /motd\n");
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  8000bb:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8000c2:	00 
  8000c3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000c7:	89 34 24             	mov    %esi,(%esp)
  8000ca:	e8 16 14 00 00       	call   8014e5 <read>
  8000cf:	85 c0                	test   %eax,%eax
  8000d1:	7f dc                	jg     8000af <umain+0x7b>
		sys_cputs(buf, n);

	cprintf("icode: close /motd\n");
  8000d3:	c7 04 24 24 24 80 00 	movl   $0x802424,(%esp)
  8000da:	e8 e4 01 00 00       	call   8002c3 <cprintf>
	close(fd);
  8000df:	89 34 24             	mov    %esi,(%esp)
  8000e2:	e8 8b 12 00 00       	call   801372 <close>

	cprintf("icode: spawn /init\n");
  8000e7:	c7 04 24 38 24 80 00 	movl   $0x802438,(%esp)
  8000ee:	e8 d0 01 00 00       	call   8002c3 <cprintf>
	if ((r = spawnl("/init", "init", "initarg1", "initarg2", (char*)0)) < 0)
  8000f3:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8000fa:	00 
  8000fb:	c7 44 24 0c 4c 24 80 	movl   $0x80244c,0xc(%esp)
  800102:	00 
  800103:	c7 44 24 08 55 24 80 	movl   $0x802455,0x8(%esp)
  80010a:	00 
  80010b:	c7 44 24 04 5f 24 80 	movl   $0x80245f,0x4(%esp)
  800112:	00 
  800113:	c7 04 24 5e 24 80 00 	movl   $0x80245e,(%esp)
  80011a:	e8 06 1e 00 00       	call   801f25 <spawnl>
  80011f:	85 c0                	test   %eax,%eax
  800121:	79 20                	jns    800143 <umain+0x10f>
		panic("icode: spawn /init: %e", r);
  800123:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800127:	c7 44 24 08 64 24 80 	movl   $0x802464,0x8(%esp)
  80012e:	00 
  80012f:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800136:	00 
  800137:	c7 04 24 04 24 80 00 	movl   $0x802404,(%esp)
  80013e:	e8 85 00 00 00       	call   8001c8 <_panic>

	cprintf("icode: exiting\n");
  800143:	c7 04 24 7b 24 80 00 	movl   $0x80247b,(%esp)
  80014a:	e8 74 01 00 00       	call   8002c3 <cprintf>
}
  80014f:	81 c4 30 02 00 00    	add    $0x230,%esp
  800155:	5b                   	pop    %ebx
  800156:	5e                   	pop    %esi
  800157:	5d                   	pop    %ebp
  800158:	c3                   	ret    
  800159:	66 90                	xchg   %ax,%ax
  80015b:	90                   	nop

0080015c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	83 ec 18             	sub    $0x18,%esp
  800162:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800165:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800168:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80016b:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;

	thisenv = &envs[ENVX(sys_getenvid())];
  80016e:	e8 a4 0c 00 00       	call   800e17 <sys_getenvid>
  800173:	25 ff 03 00 00       	and    $0x3ff,%eax
  800178:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80017b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800180:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800185:	85 db                	test   %ebx,%ebx
  800187:	7e 07                	jle    800190 <libmain+0x34>
		binaryname = argv[0];
  800189:	8b 06                	mov    (%esi),%eax
  80018b:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800190:	89 74 24 04          	mov    %esi,0x4(%esp)
  800194:	89 1c 24             	mov    %ebx,(%esp)
  800197:	e8 98 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80019c:	e8 0b 00 00 00       	call   8001ac <exit>
}
  8001a1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8001a4:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8001a7:	89 ec                	mov    %ebp,%esp
  8001a9:	5d                   	pop    %ebp
  8001aa:	c3                   	ret    
  8001ab:	90                   	nop

008001ac <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8001b2:	e8 ec 11 00 00       	call   8013a3 <close_all>
	sys_env_destroy(0);
  8001b7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001be:	e8 ee 0b 00 00       	call   800db1 <sys_env_destroy>
}
  8001c3:	c9                   	leave  
  8001c4:	c3                   	ret    
  8001c5:	66 90                	xchg   %ax,%ax
  8001c7:	90                   	nop

008001c8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001c8:	55                   	push   %ebp
  8001c9:	89 e5                	mov    %esp,%ebp
  8001cb:	56                   	push   %esi
  8001cc:	53                   	push   %ebx
  8001cd:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8001d0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001d3:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001d9:	e8 39 0c 00 00       	call   800e17 <sys_getenvid>
  8001de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001e1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001ec:	89 74 24 08          	mov    %esi,0x8(%esp)
  8001f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f4:	c7 04 24 98 24 80 00 	movl   $0x802498,(%esp)
  8001fb:	e8 c3 00 00 00       	call   8002c3 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800200:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800204:	8b 45 10             	mov    0x10(%ebp),%eax
  800207:	89 04 24             	mov    %eax,(%esp)
  80020a:	e8 53 00 00 00       	call   800262 <vcprintf>
	cprintf("\n");
  80020f:	c7 04 24 22 24 80 00 	movl   $0x802422,(%esp)
  800216:	e8 a8 00 00 00       	call   8002c3 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80021b:	cc                   	int3   
  80021c:	eb fd                	jmp    80021b <_panic+0x53>
  80021e:	66 90                	xchg   %ax,%ax

00800220 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
  800223:	53                   	push   %ebx
  800224:	83 ec 14             	sub    $0x14,%esp
  800227:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80022a:	8b 03                	mov    (%ebx),%eax
  80022c:	8b 55 08             	mov    0x8(%ebp),%edx
  80022f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800233:	83 c0 01             	add    $0x1,%eax
  800236:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800238:	3d ff 00 00 00       	cmp    $0xff,%eax
  80023d:	75 19                	jne    800258 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80023f:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800246:	00 
  800247:	8d 43 08             	lea    0x8(%ebx),%eax
  80024a:	89 04 24             	mov    %eax,(%esp)
  80024d:	e8 ee 0a 00 00       	call   800d40 <sys_cputs>
		b->idx = 0;
  800252:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800258:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80025c:	83 c4 14             	add    $0x14,%esp
  80025f:	5b                   	pop    %ebx
  800260:	5d                   	pop    %ebp
  800261:	c3                   	ret    

00800262 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800262:	55                   	push   %ebp
  800263:	89 e5                	mov    %esp,%ebp
  800265:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80026b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800272:	00 00 00 
	b.cnt = 0;
  800275:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80027c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80027f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800282:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800286:	8b 45 08             	mov    0x8(%ebp),%eax
  800289:	89 44 24 08          	mov    %eax,0x8(%esp)
  80028d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800293:	89 44 24 04          	mov    %eax,0x4(%esp)
  800297:	c7 04 24 20 02 80 00 	movl   $0x800220,(%esp)
  80029e:	e8 af 01 00 00       	call   800452 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002a3:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ad:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002b3:	89 04 24             	mov    %eax,(%esp)
  8002b6:	e8 85 0a 00 00       	call   800d40 <sys_cputs>

	return b.cnt;
}
  8002bb:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002c1:	c9                   	leave  
  8002c2:	c3                   	ret    

008002c3 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002c3:	55                   	push   %ebp
  8002c4:	89 e5                	mov    %esp,%ebp
  8002c6:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002c9:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d3:	89 04 24             	mov    %eax,(%esp)
  8002d6:	e8 87 ff ff ff       	call   800262 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002db:	c9                   	leave  
  8002dc:	c3                   	ret    
  8002dd:	66 90                	xchg   %ax,%ax
  8002df:	90                   	nop

008002e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
  8002e3:	57                   	push   %edi
  8002e4:	56                   	push   %esi
  8002e5:	53                   	push   %ebx
  8002e6:	83 ec 4c             	sub    $0x4c,%esp
  8002e9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8002ec:	89 d7                	mov    %edx,%edi
  8002ee:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002f1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8002f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002f7:	89 5d dc             	mov    %ebx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8002ff:	39 d8                	cmp    %ebx,%eax
  800301:	72 17                	jb     80031a <printnum+0x3a>
  800303:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800306:	39 5d 10             	cmp    %ebx,0x10(%ebp)
  800309:	76 0f                	jbe    80031a <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80030b:	8b 75 14             	mov    0x14(%ebp),%esi
  80030e:	83 ee 01             	sub    $0x1,%esi
  800311:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800314:	85 f6                	test   %esi,%esi
  800316:	7f 63                	jg     80037b <printnum+0x9b>
  800318:	eb 75                	jmp    80038f <printnum+0xaf>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80031a:	8b 5d 18             	mov    0x18(%ebp),%ebx
  80031d:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800321:	8b 45 14             	mov    0x14(%ebp),%eax
  800324:	83 e8 01             	sub    $0x1,%eax
  800327:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80032b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80032e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800332:	8b 44 24 08          	mov    0x8(%esp),%eax
  800336:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80033a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80033d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800340:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800347:	00 
  800348:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  80034b:	89 1c 24             	mov    %ebx,(%esp)
  80034e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800351:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800355:	e8 76 1d 00 00       	call   8020d0 <__udivdi3>
  80035a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80035d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800360:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800364:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800368:	89 04 24             	mov    %eax,(%esp)
  80036b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80036f:	89 fa                	mov    %edi,%edx
  800371:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800374:	e8 67 ff ff ff       	call   8002e0 <printnum>
  800379:	eb 14                	jmp    80038f <printnum+0xaf>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80037b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80037f:	8b 45 18             	mov    0x18(%ebp),%eax
  800382:	89 04 24             	mov    %eax,(%esp)
  800385:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800387:	83 ee 01             	sub    $0x1,%esi
  80038a:	75 ef                	jne    80037b <printnum+0x9b>
  80038c:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80038f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800393:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800397:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80039a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80039e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003a5:	00 
  8003a6:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8003a9:	89 1c 24             	mov    %ebx,(%esp)
  8003ac:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8003af:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003b3:	e8 68 1e 00 00       	call   802220 <__umoddi3>
  8003b8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003bc:	0f be 80 bb 24 80 00 	movsbl 0x8024bb(%eax),%eax
  8003c3:	89 04 24             	mov    %eax,(%esp)
  8003c6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003c9:	ff d0                	call   *%eax
}
  8003cb:	83 c4 4c             	add    $0x4c,%esp
  8003ce:	5b                   	pop    %ebx
  8003cf:	5e                   	pop    %esi
  8003d0:	5f                   	pop    %edi
  8003d1:	5d                   	pop    %ebp
  8003d2:	c3                   	ret    

008003d3 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003d3:	55                   	push   %ebp
  8003d4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003d6:	83 fa 01             	cmp    $0x1,%edx
  8003d9:	7e 0e                	jle    8003e9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003db:	8b 10                	mov    (%eax),%edx
  8003dd:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003e0:	89 08                	mov    %ecx,(%eax)
  8003e2:	8b 02                	mov    (%edx),%eax
  8003e4:	8b 52 04             	mov    0x4(%edx),%edx
  8003e7:	eb 22                	jmp    80040b <getuint+0x38>
	else if (lflag)
  8003e9:	85 d2                	test   %edx,%edx
  8003eb:	74 10                	je     8003fd <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003ed:	8b 10                	mov    (%eax),%edx
  8003ef:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f2:	89 08                	mov    %ecx,(%eax)
  8003f4:	8b 02                	mov    (%edx),%eax
  8003f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8003fb:	eb 0e                	jmp    80040b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003fd:	8b 10                	mov    (%eax),%edx
  8003ff:	8d 4a 04             	lea    0x4(%edx),%ecx
  800402:	89 08                	mov    %ecx,(%eax)
  800404:	8b 02                	mov    (%edx),%eax
  800406:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80040b:	5d                   	pop    %ebp
  80040c:	c3                   	ret    

0080040d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80040d:	55                   	push   %ebp
  80040e:	89 e5                	mov    %esp,%ebp
  800410:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800413:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800417:	8b 10                	mov    (%eax),%edx
  800419:	3b 50 04             	cmp    0x4(%eax),%edx
  80041c:	73 0a                	jae    800428 <sprintputch+0x1b>
		*b->buf++ = ch;
  80041e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800421:	88 0a                	mov    %cl,(%edx)
  800423:	83 c2 01             	add    $0x1,%edx
  800426:	89 10                	mov    %edx,(%eax)
}
  800428:	5d                   	pop    %ebp
  800429:	c3                   	ret    

0080042a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80042a:	55                   	push   %ebp
  80042b:	89 e5                	mov    %esp,%ebp
  80042d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800430:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800433:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800437:	8b 45 10             	mov    0x10(%ebp),%eax
  80043a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80043e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800441:	89 44 24 04          	mov    %eax,0x4(%esp)
  800445:	8b 45 08             	mov    0x8(%ebp),%eax
  800448:	89 04 24             	mov    %eax,(%esp)
  80044b:	e8 02 00 00 00       	call   800452 <vprintfmt>
	va_end(ap);
}
  800450:	c9                   	leave  
  800451:	c3                   	ret    

00800452 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800452:	55                   	push   %ebp
  800453:	89 e5                	mov    %esp,%ebp
  800455:	57                   	push   %edi
  800456:	56                   	push   %esi
  800457:	53                   	push   %ebx
  800458:	83 ec 4c             	sub    $0x4c,%esp
  80045b:	8b 75 08             	mov    0x8(%ebp),%esi
  80045e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800461:	8b 7d 10             	mov    0x10(%ebp),%edi
  800464:	eb 11                	jmp    800477 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800466:	85 c0                	test   %eax,%eax
  800468:	0f 84 db 03 00 00    	je     800849 <vprintfmt+0x3f7>
				return;
			putch(ch, putdat);
  80046e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800472:	89 04 24             	mov    %eax,(%esp)
  800475:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800477:	0f b6 07             	movzbl (%edi),%eax
  80047a:	83 c7 01             	add    $0x1,%edi
  80047d:	83 f8 25             	cmp    $0x25,%eax
  800480:	75 e4                	jne    800466 <vprintfmt+0x14>
  800482:	c6 45 e4 20          	movb   $0x20,-0x1c(%ebp)
  800486:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80048d:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800494:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80049b:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a0:	eb 2b                	jmp    8004cd <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a2:	8b 7d e0             	mov    -0x20(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004a5:	c6 45 e4 2d          	movb   $0x2d,-0x1c(%ebp)
  8004a9:	eb 22                	jmp    8004cd <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ab:	8b 7d e0             	mov    -0x20(%ebp),%edi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004ae:	c6 45 e4 30          	movb   $0x30,-0x1c(%ebp)
  8004b2:	eb 19                	jmp    8004cd <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b4:	8b 7d e0             	mov    -0x20(%ebp),%edi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8004b7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004be:	eb 0d                	jmp    8004cd <vprintfmt+0x7b>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004c0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004c3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004c6:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cd:	0f b6 0f             	movzbl (%edi),%ecx
  8004d0:	8d 47 01             	lea    0x1(%edi),%eax
  8004d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004d6:	0f b6 07             	movzbl (%edi),%eax
  8004d9:	83 e8 23             	sub    $0x23,%eax
  8004dc:	3c 55                	cmp    $0x55,%al
  8004de:	0f 87 40 03 00 00    	ja     800824 <vprintfmt+0x3d2>
  8004e4:	0f b6 c0             	movzbl %al,%eax
  8004e7:	ff 24 85 00 26 80 00 	jmp    *0x802600(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004ee:	83 e9 30             	sub    $0x30,%ecx
  8004f1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				ch = *fmt;
  8004f4:	0f be 47 01          	movsbl 0x1(%edi),%eax
				if (ch < '0' || ch > '9')
  8004f8:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8004fb:	83 f9 09             	cmp    $0x9,%ecx
  8004fe:	77 57                	ja     800557 <vprintfmt+0x105>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800500:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800503:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800506:	8b 55 dc             	mov    -0x24(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800509:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80050c:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80050f:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800513:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  800516:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800519:	83 f9 09             	cmp    $0x9,%ecx
  80051c:	76 eb                	jbe    800509 <vprintfmt+0xb7>
  80051e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800521:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800524:	eb 34                	jmp    80055a <vprintfmt+0x108>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800526:	8b 45 14             	mov    0x14(%ebp),%eax
  800529:	8d 48 04             	lea    0x4(%eax),%ecx
  80052c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80052f:	8b 00                	mov    (%eax),%eax
  800531:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800534:	8b 7d e0             	mov    -0x20(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800537:	eb 21                	jmp    80055a <vprintfmt+0x108>

		case '.':
			if (width < 0)
  800539:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80053d:	0f 88 71 ff ff ff    	js     8004b4 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800543:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800546:	eb 85                	jmp    8004cd <vprintfmt+0x7b>
  800548:	8b 7d e0             	mov    -0x20(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80054b:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  800552:	e9 76 ff ff ff       	jmp    8004cd <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800557:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80055a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80055e:	0f 89 69 ff ff ff    	jns    8004cd <vprintfmt+0x7b>
  800564:	e9 57 ff ff ff       	jmp    8004c0 <vprintfmt+0x6e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800569:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80056f:	e9 59 ff ff ff       	jmp    8004cd <vprintfmt+0x7b>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800574:	8b 45 14             	mov    0x14(%ebp),%eax
  800577:	8d 50 04             	lea    0x4(%eax),%edx
  80057a:	89 55 14             	mov    %edx,0x14(%ebp)
  80057d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800581:	8b 00                	mov    (%eax),%eax
  800583:	89 04 24             	mov    %eax,(%esp)
  800586:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800588:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80058b:	e9 e7 fe ff ff       	jmp    800477 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800590:	8b 45 14             	mov    0x14(%ebp),%eax
  800593:	8d 50 04             	lea    0x4(%eax),%edx
  800596:	89 55 14             	mov    %edx,0x14(%ebp)
  800599:	8b 00                	mov    (%eax),%eax
  80059b:	89 c2                	mov    %eax,%edx
  80059d:	c1 fa 1f             	sar    $0x1f,%edx
  8005a0:	31 d0                	xor    %edx,%eax
  8005a2:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005a4:	83 f8 0f             	cmp    $0xf,%eax
  8005a7:	7f 0b                	jg     8005b4 <vprintfmt+0x162>
  8005a9:	8b 14 85 60 27 80 00 	mov    0x802760(,%eax,4),%edx
  8005b0:	85 d2                	test   %edx,%edx
  8005b2:	75 20                	jne    8005d4 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  8005b4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005b8:	c7 44 24 08 d3 24 80 	movl   $0x8024d3,0x8(%esp)
  8005bf:	00 
  8005c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c4:	89 34 24             	mov    %esi,(%esp)
  8005c7:	e8 5e fe ff ff       	call   80042a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005cc:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005cf:	e9 a3 fe ff ff       	jmp    800477 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  8005d4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005d8:	c7 44 24 08 ed 28 80 	movl   $0x8028ed,0x8(%esp)
  8005df:	00 
  8005e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005e4:	89 34 24             	mov    %esi,(%esp)
  8005e7:	e8 3e fe ff ff       	call   80042a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ec:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005ef:	e9 83 fe ff ff       	jmp    800477 <vprintfmt+0x25>
  8005f4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005f7:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8005fa:	89 7d cc             	mov    %edi,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800600:	8d 50 04             	lea    0x4(%eax),%edx
  800603:	89 55 14             	mov    %edx,0x14(%ebp)
  800606:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800608:	85 ff                	test   %edi,%edi
  80060a:	b8 cc 24 80 00       	mov    $0x8024cc,%eax
  80060f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800612:	80 7d e4 2d          	cmpb   $0x2d,-0x1c(%ebp)
  800616:	74 06                	je     80061e <vprintfmt+0x1cc>
  800618:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80061c:	7f 16                	jg     800634 <vprintfmt+0x1e2>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80061e:	0f b6 17             	movzbl (%edi),%edx
  800621:	0f be c2             	movsbl %dl,%eax
  800624:	83 c7 01             	add    $0x1,%edi
  800627:	85 c0                	test   %eax,%eax
  800629:	0f 85 9f 00 00 00    	jne    8006ce <vprintfmt+0x27c>
  80062f:	e9 8b 00 00 00       	jmp    8006bf <vprintfmt+0x26d>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800634:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800638:	89 3c 24             	mov    %edi,(%esp)
  80063b:	e8 c2 02 00 00       	call   800902 <strnlen>
  800640:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800643:	29 c2                	sub    %eax,%edx
  800645:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800648:	85 d2                	test   %edx,%edx
  80064a:	7e d2                	jle    80061e <vprintfmt+0x1cc>
					putch(padc, putdat);
  80064c:	0f be 4d e4          	movsbl -0x1c(%ebp),%ecx
  800650:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800653:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800656:	89 d7                	mov    %edx,%edi
  800658:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80065c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80065f:	89 04 24             	mov    %eax,(%esp)
  800662:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800664:	83 ef 01             	sub    $0x1,%edi
  800667:	75 ef                	jne    800658 <vprintfmt+0x206>
  800669:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80066c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80066f:	eb ad                	jmp    80061e <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800671:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800675:	74 20                	je     800697 <vprintfmt+0x245>
  800677:	0f be d2             	movsbl %dl,%edx
  80067a:	83 ea 20             	sub    $0x20,%edx
  80067d:	83 fa 5e             	cmp    $0x5e,%edx
  800680:	76 15                	jbe    800697 <vprintfmt+0x245>
					putch('?', putdat);
  800682:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800685:	89 54 24 04          	mov    %edx,0x4(%esp)
  800689:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800690:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800693:	ff d1                	call   *%ecx
  800695:	eb 0f                	jmp    8006a6 <vprintfmt+0x254>
				else
					putch(ch, putdat);
  800697:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80069a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80069e:	89 04 24             	mov    %eax,(%esp)
  8006a1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8006a4:	ff d1                	call   *%ecx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006a6:	83 eb 01             	sub    $0x1,%ebx
  8006a9:	0f b6 17             	movzbl (%edi),%edx
  8006ac:	0f be c2             	movsbl %dl,%eax
  8006af:	83 c7 01             	add    $0x1,%edi
  8006b2:	85 c0                	test   %eax,%eax
  8006b4:	75 24                	jne    8006da <vprintfmt+0x288>
  8006b6:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8006b9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8006bc:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006bf:	8b 7d e0             	mov    -0x20(%ebp),%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006c2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006c6:	0f 8e ab fd ff ff    	jle    800477 <vprintfmt+0x25>
  8006cc:	eb 20                	jmp    8006ee <vprintfmt+0x29c>
  8006ce:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  8006d1:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8006d4:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8006d7:	8b 5d d8             	mov    -0x28(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006da:	85 f6                	test   %esi,%esi
  8006dc:	78 93                	js     800671 <vprintfmt+0x21f>
  8006de:	83 ee 01             	sub    $0x1,%esi
  8006e1:	79 8e                	jns    800671 <vprintfmt+0x21f>
  8006e3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8006e6:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8006e9:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8006ec:	eb d1                	jmp    8006bf <vprintfmt+0x26d>
  8006ee:	8b 7d d8             	mov    -0x28(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006f1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006fc:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006fe:	83 ef 01             	sub    $0x1,%edi
  800701:	75 ee                	jne    8006f1 <vprintfmt+0x29f>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800703:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800706:	e9 6c fd ff ff       	jmp    800477 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80070b:	83 fa 01             	cmp    $0x1,%edx
  80070e:	66 90                	xchg   %ax,%ax
  800710:	7e 16                	jle    800728 <vprintfmt+0x2d6>
		return va_arg(*ap, long long);
  800712:	8b 45 14             	mov    0x14(%ebp),%eax
  800715:	8d 50 08             	lea    0x8(%eax),%edx
  800718:	89 55 14             	mov    %edx,0x14(%ebp)
  80071b:	8b 10                	mov    (%eax),%edx
  80071d:	8b 48 04             	mov    0x4(%eax),%ecx
  800720:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800723:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800726:	eb 32                	jmp    80075a <vprintfmt+0x308>
	else if (lflag)
  800728:	85 d2                	test   %edx,%edx
  80072a:	74 18                	je     800744 <vprintfmt+0x2f2>
		return va_arg(*ap, long);
  80072c:	8b 45 14             	mov    0x14(%ebp),%eax
  80072f:	8d 50 04             	lea    0x4(%eax),%edx
  800732:	89 55 14             	mov    %edx,0x14(%ebp)
  800735:	8b 00                	mov    (%eax),%eax
  800737:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80073a:	89 c1                	mov    %eax,%ecx
  80073c:	c1 f9 1f             	sar    $0x1f,%ecx
  80073f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800742:	eb 16                	jmp    80075a <vprintfmt+0x308>
	else
		return va_arg(*ap, int);
  800744:	8b 45 14             	mov    0x14(%ebp),%eax
  800747:	8d 50 04             	lea    0x4(%eax),%edx
  80074a:	89 55 14             	mov    %edx,0x14(%ebp)
  80074d:	8b 00                	mov    (%eax),%eax
  80074f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800752:	89 c7                	mov    %eax,%edi
  800754:	c1 ff 1f             	sar    $0x1f,%edi
  800757:	89 7d d4             	mov    %edi,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80075a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80075d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800760:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800765:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800769:	79 7d                	jns    8007e8 <vprintfmt+0x396>
				putch('-', putdat);
  80076b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80076f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800776:	ff d6                	call   *%esi
				num = -(long long) num;
  800778:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80077b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80077e:	f7 d8                	neg    %eax
  800780:	83 d2 00             	adc    $0x0,%edx
  800783:	f7 da                	neg    %edx
			}
			base = 10;
  800785:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80078a:	eb 5c                	jmp    8007e8 <vprintfmt+0x396>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80078c:	8d 45 14             	lea    0x14(%ebp),%eax
  80078f:	e8 3f fc ff ff       	call   8003d3 <getuint>
			base = 10;
  800794:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800799:	eb 4d                	jmp    8007e8 <vprintfmt+0x396>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80079b:	8d 45 14             	lea    0x14(%ebp),%eax
  80079e:	e8 30 fc ff ff       	call   8003d3 <getuint>
			base = 8;
  8007a3:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8007a8:	eb 3e                	jmp    8007e8 <vprintfmt+0x396>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8007aa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ae:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007b5:	ff d6                	call   *%esi
			putch('x', putdat);
  8007b7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007bb:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007c2:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c7:	8d 50 04             	lea    0x4(%eax),%edx
  8007ca:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007cd:	8b 00                	mov    (%eax),%eax
  8007cf:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007d4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007d9:	eb 0d                	jmp    8007e8 <vprintfmt+0x396>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007db:	8d 45 14             	lea    0x14(%ebp),%eax
  8007de:	e8 f0 fb ff ff       	call   8003d3 <getuint>
			base = 16;
  8007e3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007e8:	0f be 7d e4          	movsbl -0x1c(%ebp),%edi
  8007ec:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8007f0:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8007f3:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8007f7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8007fb:	89 04 24             	mov    %eax,(%esp)
  8007fe:	89 54 24 04          	mov    %edx,0x4(%esp)
  800802:	89 da                	mov    %ebx,%edx
  800804:	89 f0                	mov    %esi,%eax
  800806:	e8 d5 fa ff ff       	call   8002e0 <printnum>
			break;
  80080b:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80080e:	e9 64 fc ff ff       	jmp    800477 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800813:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800817:	89 0c 24             	mov    %ecx,(%esp)
  80081a:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80081c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80081f:	e9 53 fc ff ff       	jmp    800477 <vprintfmt+0x25>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800824:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800828:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80082f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800831:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800835:	0f 84 3c fc ff ff    	je     800477 <vprintfmt+0x25>
  80083b:	83 ef 01             	sub    $0x1,%edi
  80083e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800842:	75 f7                	jne    80083b <vprintfmt+0x3e9>
  800844:	e9 2e fc ff ff       	jmp    800477 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800849:	83 c4 4c             	add    $0x4c,%esp
  80084c:	5b                   	pop    %ebx
  80084d:	5e                   	pop    %esi
  80084e:	5f                   	pop    %edi
  80084f:	5d                   	pop    %ebp
  800850:	c3                   	ret    

00800851 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800851:	55                   	push   %ebp
  800852:	89 e5                	mov    %esp,%ebp
  800854:	83 ec 28             	sub    $0x28,%esp
  800857:	8b 45 08             	mov    0x8(%ebp),%eax
  80085a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80085d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800860:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800864:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800867:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80086e:	85 d2                	test   %edx,%edx
  800870:	7e 30                	jle    8008a2 <vsnprintf+0x51>
  800872:	85 c0                	test   %eax,%eax
  800874:	74 2c                	je     8008a2 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800876:	8b 45 14             	mov    0x14(%ebp),%eax
  800879:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80087d:	8b 45 10             	mov    0x10(%ebp),%eax
  800880:	89 44 24 08          	mov    %eax,0x8(%esp)
  800884:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800887:	89 44 24 04          	mov    %eax,0x4(%esp)
  80088b:	c7 04 24 0d 04 80 00 	movl   $0x80040d,(%esp)
  800892:	e8 bb fb ff ff       	call   800452 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800897:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80089a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80089d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008a0:	eb 05                	jmp    8008a7 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008a7:	c9                   	leave  
  8008a8:	c3                   	ret    

008008a9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008a9:	55                   	push   %ebp
  8008aa:	89 e5                	mov    %esp,%ebp
  8008ac:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008af:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008b6:	8b 45 10             	mov    0x10(%ebp),%eax
  8008b9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c7:	89 04 24             	mov    %eax,(%esp)
  8008ca:	e8 82 ff ff ff       	call   800851 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008cf:	c9                   	leave  
  8008d0:	c3                   	ret    
  8008d1:	66 90                	xchg   %ax,%ax
  8008d3:	66 90                	xchg   %ax,%ax
  8008d5:	66 90                	xchg   %ax,%ax
  8008d7:	66 90                	xchg   %ax,%ax
  8008d9:	66 90                	xchg   %ax,%ax
  8008db:	66 90                	xchg   %ax,%ax
  8008dd:	66 90                	xchg   %ax,%ax
  8008df:	90                   	nop

008008e0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008e6:	80 3a 00             	cmpb   $0x0,(%edx)
  8008e9:	74 10                	je     8008fb <strlen+0x1b>
  8008eb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8008f0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008f3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008f7:	75 f7                	jne    8008f0 <strlen+0x10>
  8008f9:	eb 05                	jmp    800900 <strlen+0x20>
  8008fb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800900:	5d                   	pop    %ebp
  800901:	c3                   	ret    

00800902 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
  800905:	53                   	push   %ebx
  800906:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800909:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80090c:	85 c9                	test   %ecx,%ecx
  80090e:	74 1c                	je     80092c <strnlen+0x2a>
  800910:	80 3b 00             	cmpb   $0x0,(%ebx)
  800913:	74 1e                	je     800933 <strnlen+0x31>
  800915:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  80091a:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80091c:	39 ca                	cmp    %ecx,%edx
  80091e:	74 18                	je     800938 <strnlen+0x36>
  800920:	83 c2 01             	add    $0x1,%edx
  800923:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800928:	75 f0                	jne    80091a <strnlen+0x18>
  80092a:	eb 0c                	jmp    800938 <strnlen+0x36>
  80092c:	b8 00 00 00 00       	mov    $0x0,%eax
  800931:	eb 05                	jmp    800938 <strnlen+0x36>
  800933:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800938:	5b                   	pop    %ebx
  800939:	5d                   	pop    %ebp
  80093a:	c3                   	ret    

0080093b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80093b:	55                   	push   %ebp
  80093c:	89 e5                	mov    %esp,%ebp
  80093e:	53                   	push   %ebx
  80093f:	8b 45 08             	mov    0x8(%ebp),%eax
  800942:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800945:	89 c2                	mov    %eax,%edx
  800947:	0f b6 19             	movzbl (%ecx),%ebx
  80094a:	88 1a                	mov    %bl,(%edx)
  80094c:	83 c2 01             	add    $0x1,%edx
  80094f:	83 c1 01             	add    $0x1,%ecx
  800952:	84 db                	test   %bl,%bl
  800954:	75 f1                	jne    800947 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800956:	5b                   	pop    %ebx
  800957:	5d                   	pop    %ebp
  800958:	c3                   	ret    

00800959 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800959:	55                   	push   %ebp
  80095a:	89 e5                	mov    %esp,%ebp
  80095c:	53                   	push   %ebx
  80095d:	83 ec 08             	sub    $0x8,%esp
  800960:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800963:	89 1c 24             	mov    %ebx,(%esp)
  800966:	e8 75 ff ff ff       	call   8008e0 <strlen>
	strcpy(dst + len, src);
  80096b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800972:	01 d8                	add    %ebx,%eax
  800974:	89 04 24             	mov    %eax,(%esp)
  800977:	e8 bf ff ff ff       	call   80093b <strcpy>
	return dst;
}
  80097c:	89 d8                	mov    %ebx,%eax
  80097e:	83 c4 08             	add    $0x8,%esp
  800981:	5b                   	pop    %ebx
  800982:	5d                   	pop    %ebp
  800983:	c3                   	ret    

00800984 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
  800987:	56                   	push   %esi
  800988:	53                   	push   %ebx
  800989:	8b 75 08             	mov    0x8(%ebp),%esi
  80098c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800992:	85 db                	test   %ebx,%ebx
  800994:	74 16                	je     8009ac <strncpy+0x28>
	strcpy(dst + len, src);
	return dst;
}

char *
strncpy(char *dst, const char *src, size_t size) {
  800996:	01 f3                	add    %esi,%ebx
  800998:	89 f1                	mov    %esi,%ecx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  80099a:	0f b6 02             	movzbl (%edx),%eax
  80099d:	88 01                	mov    %al,(%ecx)
  80099f:	83 c1 01             	add    $0x1,%ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009a2:	80 3a 01             	cmpb   $0x1,(%edx)
  8009a5:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009a8:	39 d9                	cmp    %ebx,%ecx
  8009aa:	75 ee                	jne    80099a <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009ac:	89 f0                	mov    %esi,%eax
  8009ae:	5b                   	pop    %ebx
  8009af:	5e                   	pop    %esi
  8009b0:	5d                   	pop    %ebp
  8009b1:	c3                   	ret    

008009b2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
  8009b5:	57                   	push   %edi
  8009b6:	56                   	push   %esi
  8009b7:	53                   	push   %ebx
  8009b8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009be:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009c1:	89 f8                	mov    %edi,%eax
  8009c3:	85 f6                	test   %esi,%esi
  8009c5:	74 33                	je     8009fa <strlcpy+0x48>
		while (--size > 0 && *src != '\0')
  8009c7:	83 fe 01             	cmp    $0x1,%esi
  8009ca:	74 25                	je     8009f1 <strlcpy+0x3f>
  8009cc:	0f b6 0b             	movzbl (%ebx),%ecx
  8009cf:	84 c9                	test   %cl,%cl
  8009d1:	74 22                	je     8009f5 <strlcpy+0x43>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8009d3:	83 ee 02             	sub    $0x2,%esi
  8009d6:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009db:	88 08                	mov    %cl,(%eax)
  8009dd:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009e0:	39 f2                	cmp    %esi,%edx
  8009e2:	74 13                	je     8009f7 <strlcpy+0x45>
  8009e4:	83 c2 01             	add    $0x1,%edx
  8009e7:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8009eb:	84 c9                	test   %cl,%cl
  8009ed:	75 ec                	jne    8009db <strlcpy+0x29>
  8009ef:	eb 06                	jmp    8009f7 <strlcpy+0x45>
  8009f1:	89 f8                	mov    %edi,%eax
  8009f3:	eb 02                	jmp    8009f7 <strlcpy+0x45>
  8009f5:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009f7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009fa:	29 f8                	sub    %edi,%eax
}
  8009fc:	5b                   	pop    %ebx
  8009fd:	5e                   	pop    %esi
  8009fe:	5f                   	pop    %edi
  8009ff:	5d                   	pop    %ebp
  800a00:	c3                   	ret    

00800a01 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a01:	55                   	push   %ebp
  800a02:	89 e5                	mov    %esp,%ebp
  800a04:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a07:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a0a:	0f b6 01             	movzbl (%ecx),%eax
  800a0d:	84 c0                	test   %al,%al
  800a0f:	74 15                	je     800a26 <strcmp+0x25>
  800a11:	3a 02                	cmp    (%edx),%al
  800a13:	75 11                	jne    800a26 <strcmp+0x25>
		p++, q++;
  800a15:	83 c1 01             	add    $0x1,%ecx
  800a18:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a1b:	0f b6 01             	movzbl (%ecx),%eax
  800a1e:	84 c0                	test   %al,%al
  800a20:	74 04                	je     800a26 <strcmp+0x25>
  800a22:	3a 02                	cmp    (%edx),%al
  800a24:	74 ef                	je     800a15 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a26:	0f b6 c0             	movzbl %al,%eax
  800a29:	0f b6 12             	movzbl (%edx),%edx
  800a2c:	29 d0                	sub    %edx,%eax
}
  800a2e:	5d                   	pop    %ebp
  800a2f:	c3                   	ret    

00800a30 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
  800a33:	56                   	push   %esi
  800a34:	53                   	push   %ebx
  800a35:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a38:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a3b:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800a3e:	85 f6                	test   %esi,%esi
  800a40:	74 29                	je     800a6b <strncmp+0x3b>
  800a42:	0f b6 03             	movzbl (%ebx),%eax
  800a45:	84 c0                	test   %al,%al
  800a47:	74 30                	je     800a79 <strncmp+0x49>
  800a49:	3a 02                	cmp    (%edx),%al
  800a4b:	75 2c                	jne    800a79 <strncmp+0x49>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}

int
strncmp(const char *p, const char *q, size_t n)
  800a4d:	8d 43 01             	lea    0x1(%ebx),%eax
  800a50:	01 de                	add    %ebx,%esi
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800a52:	89 c3                	mov    %eax,%ebx
  800a54:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a57:	39 f0                	cmp    %esi,%eax
  800a59:	74 17                	je     800a72 <strncmp+0x42>
  800a5b:	0f b6 08             	movzbl (%eax),%ecx
  800a5e:	84 c9                	test   %cl,%cl
  800a60:	74 17                	je     800a79 <strncmp+0x49>
  800a62:	83 c0 01             	add    $0x1,%eax
  800a65:	3a 0a                	cmp    (%edx),%cl
  800a67:	74 e9                	je     800a52 <strncmp+0x22>
  800a69:	eb 0e                	jmp    800a79 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a6b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a70:	eb 0f                	jmp    800a81 <strncmp+0x51>
  800a72:	b8 00 00 00 00       	mov    $0x0,%eax
  800a77:	eb 08                	jmp    800a81 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a79:	0f b6 03             	movzbl (%ebx),%eax
  800a7c:	0f b6 12             	movzbl (%edx),%edx
  800a7f:	29 d0                	sub    %edx,%eax
}
  800a81:	5b                   	pop    %ebx
  800a82:	5e                   	pop    %esi
  800a83:	5d                   	pop    %ebp
  800a84:	c3                   	ret    

00800a85 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a85:	55                   	push   %ebp
  800a86:	89 e5                	mov    %esp,%ebp
  800a88:	53                   	push   %ebx
  800a89:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8c:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800a8f:	0f b6 18             	movzbl (%eax),%ebx
  800a92:	84 db                	test   %bl,%bl
  800a94:	74 1d                	je     800ab3 <strchr+0x2e>
  800a96:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800a98:	38 d3                	cmp    %dl,%bl
  800a9a:	75 06                	jne    800aa2 <strchr+0x1d>
  800a9c:	eb 1a                	jmp    800ab8 <strchr+0x33>
  800a9e:	38 ca                	cmp    %cl,%dl
  800aa0:	74 16                	je     800ab8 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800aa2:	83 c0 01             	add    $0x1,%eax
  800aa5:	0f b6 10             	movzbl (%eax),%edx
  800aa8:	84 d2                	test   %dl,%dl
  800aaa:	75 f2                	jne    800a9e <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800aac:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab1:	eb 05                	jmp    800ab8 <strchr+0x33>
  800ab3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ab8:	5b                   	pop    %ebx
  800ab9:	5d                   	pop    %ebp
  800aba:	c3                   	ret    

00800abb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800abb:	55                   	push   %ebp
  800abc:	89 e5                	mov    %esp,%ebp
  800abe:	53                   	push   %ebx
  800abf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac2:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800ac5:	0f b6 18             	movzbl (%eax),%ebx
  800ac8:	84 db                	test   %bl,%bl
  800aca:	74 16                	je     800ae2 <strfind+0x27>
  800acc:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800ace:	38 d3                	cmp    %dl,%bl
  800ad0:	75 06                	jne    800ad8 <strfind+0x1d>
  800ad2:	eb 0e                	jmp    800ae2 <strfind+0x27>
  800ad4:	38 ca                	cmp    %cl,%dl
  800ad6:	74 0a                	je     800ae2 <strfind+0x27>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800ad8:	83 c0 01             	add    $0x1,%eax
  800adb:	0f b6 10             	movzbl (%eax),%edx
  800ade:	84 d2                	test   %dl,%dl
  800ae0:	75 f2                	jne    800ad4 <strfind+0x19>
		if (*s == c)
			break;
	return (char *) s;
}
  800ae2:	5b                   	pop    %ebx
  800ae3:	5d                   	pop    %ebp
  800ae4:	c3                   	ret    

00800ae5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ae5:	55                   	push   %ebp
  800ae6:	89 e5                	mov    %esp,%ebp
  800ae8:	83 ec 0c             	sub    $0xc,%esp
  800aeb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800aee:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800af1:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800af4:	8b 7d 08             	mov    0x8(%ebp),%edi
  800af7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800afa:	85 c9                	test   %ecx,%ecx
  800afc:	74 36                	je     800b34 <memset+0x4f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800afe:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b04:	75 28                	jne    800b2e <memset+0x49>
  800b06:	f6 c1 03             	test   $0x3,%cl
  800b09:	75 23                	jne    800b2e <memset+0x49>
		c &= 0xFF;
  800b0b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b0f:	89 d3                	mov    %edx,%ebx
  800b11:	c1 e3 08             	shl    $0x8,%ebx
  800b14:	89 d6                	mov    %edx,%esi
  800b16:	c1 e6 18             	shl    $0x18,%esi
  800b19:	89 d0                	mov    %edx,%eax
  800b1b:	c1 e0 10             	shl    $0x10,%eax
  800b1e:	09 f0                	or     %esi,%eax
  800b20:	09 c2                	or     %eax,%edx
  800b22:	89 d0                	mov    %edx,%eax
  800b24:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b26:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b29:	fc                   	cld    
  800b2a:	f3 ab                	rep stos %eax,%es:(%edi)
  800b2c:	eb 06                	jmp    800b34 <memset+0x4f>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b31:	fc                   	cld    
  800b32:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");

	return v;
}
  800b34:	89 f8                	mov    %edi,%eax
  800b36:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800b39:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b3c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b3f:	89 ec                	mov    %ebp,%esp
  800b41:	5d                   	pop    %ebp
  800b42:	c3                   	ret    

00800b43 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b43:	55                   	push   %ebp
  800b44:	89 e5                	mov    %esp,%ebp
  800b46:	83 ec 08             	sub    $0x8,%esp
  800b49:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b4c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800b4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b52:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b55:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b58:	39 c6                	cmp    %eax,%esi
  800b5a:	73 36                	jae    800b92 <memmove+0x4f>
  800b5c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b5f:	39 d0                	cmp    %edx,%eax
  800b61:	73 2f                	jae    800b92 <memmove+0x4f>
		s += n;
		d += n;
  800b63:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b66:	f6 c2 03             	test   $0x3,%dl
  800b69:	75 1b                	jne    800b86 <memmove+0x43>
  800b6b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b71:	75 13                	jne    800b86 <memmove+0x43>
  800b73:	f6 c1 03             	test   $0x3,%cl
  800b76:	75 0e                	jne    800b86 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b78:	83 ef 04             	sub    $0x4,%edi
  800b7b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b7e:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b81:	fd                   	std    
  800b82:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b84:	eb 09                	jmp    800b8f <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b86:	83 ef 01             	sub    $0x1,%edi
  800b89:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b8c:	fd                   	std    
  800b8d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b8f:	fc                   	cld    
  800b90:	eb 20                	jmp    800bb2 <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b92:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b98:	75 13                	jne    800bad <memmove+0x6a>
  800b9a:	a8 03                	test   $0x3,%al
  800b9c:	75 0f                	jne    800bad <memmove+0x6a>
  800b9e:	f6 c1 03             	test   $0x3,%cl
  800ba1:	75 0a                	jne    800bad <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ba3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800ba6:	89 c7                	mov    %eax,%edi
  800ba8:	fc                   	cld    
  800ba9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bab:	eb 05                	jmp    800bb2 <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bad:	89 c7                	mov    %eax,%edi
  800baf:	fc                   	cld    
  800bb0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bb2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800bb5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800bb8:	89 ec                	mov    %ebp,%esp
  800bba:	5d                   	pop    %ebp
  800bbb:	c3                   	ret    

00800bbc <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800bbc:	55                   	push   %ebp
  800bbd:	89 e5                	mov    %esp,%ebp
  800bbf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bc2:	8b 45 10             	mov    0x10(%ebp),%eax
  800bc5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bc9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bcc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bd0:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd3:	89 04 24             	mov    %eax,(%esp)
  800bd6:	e8 68 ff ff ff       	call   800b43 <memmove>
}
  800bdb:	c9                   	leave  
  800bdc:	c3                   	ret    

00800bdd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bdd:	55                   	push   %ebp
  800bde:	89 e5                	mov    %esp,%ebp
  800be0:	57                   	push   %edi
  800be1:	56                   	push   %esi
  800be2:	53                   	push   %ebx
  800be3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800be6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800be9:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bec:	8d 78 ff             	lea    -0x1(%eax),%edi
  800bef:	85 c0                	test   %eax,%eax
  800bf1:	74 36                	je     800c29 <memcmp+0x4c>
		if (*s1 != *s2)
  800bf3:	0f b6 03             	movzbl (%ebx),%eax
  800bf6:	0f b6 0e             	movzbl (%esi),%ecx
  800bf9:	38 c8                	cmp    %cl,%al
  800bfb:	75 17                	jne    800c14 <memcmp+0x37>
  800bfd:	ba 00 00 00 00       	mov    $0x0,%edx
  800c02:	eb 1a                	jmp    800c1e <memcmp+0x41>
  800c04:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800c09:	83 c2 01             	add    $0x1,%edx
  800c0c:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800c10:	38 c8                	cmp    %cl,%al
  800c12:	74 0a                	je     800c1e <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800c14:	0f b6 c0             	movzbl %al,%eax
  800c17:	0f b6 c9             	movzbl %cl,%ecx
  800c1a:	29 c8                	sub    %ecx,%eax
  800c1c:	eb 10                	jmp    800c2e <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c1e:	39 fa                	cmp    %edi,%edx
  800c20:	75 e2                	jne    800c04 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c22:	b8 00 00 00 00       	mov    $0x0,%eax
  800c27:	eb 05                	jmp    800c2e <memcmp+0x51>
  800c29:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c2e:	5b                   	pop    %ebx
  800c2f:	5e                   	pop    %esi
  800c30:	5f                   	pop    %edi
  800c31:	5d                   	pop    %ebp
  800c32:	c3                   	ret    

00800c33 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	53                   	push   %ebx
  800c37:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800c3d:	89 c2                	mov    %eax,%edx
  800c3f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c42:	39 d0                	cmp    %edx,%eax
  800c44:	73 13                	jae    800c59 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c46:	89 d9                	mov    %ebx,%ecx
  800c48:	38 18                	cmp    %bl,(%eax)
  800c4a:	75 06                	jne    800c52 <memfind+0x1f>
  800c4c:	eb 0b                	jmp    800c59 <memfind+0x26>
  800c4e:	38 08                	cmp    %cl,(%eax)
  800c50:	74 07                	je     800c59 <memfind+0x26>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c52:	83 c0 01             	add    $0x1,%eax
  800c55:	39 d0                	cmp    %edx,%eax
  800c57:	75 f5                	jne    800c4e <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c59:	5b                   	pop    %ebx
  800c5a:	5d                   	pop    %ebp
  800c5b:	c3                   	ret    

00800c5c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c5c:	55                   	push   %ebp
  800c5d:	89 e5                	mov    %esp,%ebp
  800c5f:	57                   	push   %edi
  800c60:	56                   	push   %esi
  800c61:	53                   	push   %ebx
  800c62:	83 ec 04             	sub    $0x4,%esp
  800c65:	8b 55 08             	mov    0x8(%ebp),%edx
  800c68:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c6b:	0f b6 02             	movzbl (%edx),%eax
  800c6e:	3c 09                	cmp    $0x9,%al
  800c70:	74 04                	je     800c76 <strtol+0x1a>
  800c72:	3c 20                	cmp    $0x20,%al
  800c74:	75 0e                	jne    800c84 <strtol+0x28>
		s++;
  800c76:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c79:	0f b6 02             	movzbl (%edx),%eax
  800c7c:	3c 09                	cmp    $0x9,%al
  800c7e:	74 f6                	je     800c76 <strtol+0x1a>
  800c80:	3c 20                	cmp    $0x20,%al
  800c82:	74 f2                	je     800c76 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c84:	3c 2b                	cmp    $0x2b,%al
  800c86:	75 0a                	jne    800c92 <strtol+0x36>
		s++;
  800c88:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c8b:	bf 00 00 00 00       	mov    $0x0,%edi
  800c90:	eb 10                	jmp    800ca2 <strtol+0x46>
  800c92:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c97:	3c 2d                	cmp    $0x2d,%al
  800c99:	75 07                	jne    800ca2 <strtol+0x46>
		s++, neg = 1;
  800c9b:	83 c2 01             	add    $0x1,%edx
  800c9e:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ca2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ca8:	75 15                	jne    800cbf <strtol+0x63>
  800caa:	80 3a 30             	cmpb   $0x30,(%edx)
  800cad:	75 10                	jne    800cbf <strtol+0x63>
  800caf:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800cb3:	75 0a                	jne    800cbf <strtol+0x63>
		s += 2, base = 16;
  800cb5:	83 c2 02             	add    $0x2,%edx
  800cb8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cbd:	eb 10                	jmp    800ccf <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800cbf:	85 db                	test   %ebx,%ebx
  800cc1:	75 0c                	jne    800ccf <strtol+0x73>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800cc3:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cc5:	80 3a 30             	cmpb   $0x30,(%edx)
  800cc8:	75 05                	jne    800ccf <strtol+0x73>
		s++, base = 8;
  800cca:	83 c2 01             	add    $0x1,%edx
  800ccd:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800ccf:	b8 00 00 00 00       	mov    $0x0,%eax
  800cd4:	89 5d f0             	mov    %ebx,-0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cd7:	0f b6 0a             	movzbl (%edx),%ecx
  800cda:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800cdd:	89 f3                	mov    %esi,%ebx
  800cdf:	80 fb 09             	cmp    $0x9,%bl
  800ce2:	77 08                	ja     800cec <strtol+0x90>
			dig = *s - '0';
  800ce4:	0f be c9             	movsbl %cl,%ecx
  800ce7:	83 e9 30             	sub    $0x30,%ecx
  800cea:	eb 22                	jmp    800d0e <strtol+0xb2>
		else if (*s >= 'a' && *s <= 'z')
  800cec:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800cef:	89 f3                	mov    %esi,%ebx
  800cf1:	80 fb 19             	cmp    $0x19,%bl
  800cf4:	77 08                	ja     800cfe <strtol+0xa2>
			dig = *s - 'a' + 10;
  800cf6:	0f be c9             	movsbl %cl,%ecx
  800cf9:	83 e9 57             	sub    $0x57,%ecx
  800cfc:	eb 10                	jmp    800d0e <strtol+0xb2>
		else if (*s >= 'A' && *s <= 'Z')
  800cfe:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800d01:	89 f3                	mov    %esi,%ebx
  800d03:	80 fb 19             	cmp    $0x19,%bl
  800d06:	77 16                	ja     800d1e <strtol+0xc2>
			dig = *s - 'A' + 10;
  800d08:	0f be c9             	movsbl %cl,%ecx
  800d0b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d0e:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800d11:	7d 0f                	jge    800d22 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800d13:	83 c2 01             	add    $0x1,%edx
  800d16:	0f af 45 f0          	imul   -0x10(%ebp),%eax
  800d1a:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d1c:	eb b9                	jmp    800cd7 <strtol+0x7b>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d1e:	89 c1                	mov    %eax,%ecx
  800d20:	eb 02                	jmp    800d24 <strtol+0xc8>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d22:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d24:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d28:	74 05                	je     800d2f <strtol+0xd3>
		*endptr = (char *) s;
  800d2a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d2d:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d2f:	89 ca                	mov    %ecx,%edx
  800d31:	f7 da                	neg    %edx
  800d33:	85 ff                	test   %edi,%edi
  800d35:	0f 45 c2             	cmovne %edx,%eax
}
  800d38:	83 c4 04             	add    $0x4,%esp
  800d3b:	5b                   	pop    %ebx
  800d3c:	5e                   	pop    %esi
  800d3d:	5f                   	pop    %edi
  800d3e:	5d                   	pop    %ebp
  800d3f:	c3                   	ret    

00800d40 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d40:	55                   	push   %ebp
  800d41:	89 e5                	mov    %esp,%ebp
  800d43:	83 ec 0c             	sub    $0xc,%esp
  800d46:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d49:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d4c:	89 7d fc             	mov    %edi,-0x4(%ebp)
static inline uint32_t

get_cpu_features(void)
{
	uint32_t feature;
	__asm __volatile(" movl $1, %%eax\n\t"
  800d4f:	b8 01 00 00 00       	mov    $0x1,%eax
  800d54:	0f a2                	cpuid  
  800d56:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d58:	b8 00 00 00 00       	mov    $0x0,%eax
  800d5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d60:	8b 55 08             	mov    0x8(%ebp),%edx
  800d63:	89 c3                	mov    %eax,%ebx
  800d65:	89 c7                	mov    %eax,%edi
  800d67:	89 c6                	mov    %eax,%esi
  800d69:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d6b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d6e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d71:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d74:	89 ec                	mov    %ebp,%esp
  800d76:	5d                   	pop    %ebp
  800d77:	c3                   	ret    

00800d78 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d78:	55                   	push   %ebp
  800d79:	89 e5                	mov    %esp,%ebp
  800d7b:	83 ec 0c             	sub    $0xc,%esp
  800d7e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d81:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d84:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d87:	b8 01 00 00 00       	mov    $0x1,%eax
  800d8c:	0f a2                	cpuid  
  800d8e:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d90:	ba 00 00 00 00       	mov    $0x0,%edx
  800d95:	b8 01 00 00 00       	mov    $0x1,%eax
  800d9a:	89 d1                	mov    %edx,%ecx
  800d9c:	89 d3                	mov    %edx,%ebx
  800d9e:	89 d7                	mov    %edx,%edi
  800da0:	89 d6                	mov    %edx,%esi
  800da2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800da4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800da7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800daa:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dad:	89 ec                	mov    %ebp,%esp
  800daf:	5d                   	pop    %ebp
  800db0:	c3                   	ret    

00800db1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  800dc9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dce:	b8 03 00 00 00       	mov    $0x3,%eax
  800dd3:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd6:	89 cb                	mov    %ecx,%ebx
  800dd8:	89 cf                	mov    %ecx,%edi
  800dda:	89 ce                	mov    %ecx,%esi
  800ddc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dde:	85 c0                	test   %eax,%eax
  800de0:	7e 28                	jle    800e0a <sys_env_destroy+0x59>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800de6:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800ded:	00 
  800dee:	c7 44 24 08 bf 27 80 	movl   $0x8027bf,0x8(%esp)
  800df5:	00 
  800df6:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800dfd:	00 
  800dfe:	c7 04 24 dc 27 80 00 	movl   $0x8027dc,(%esp)
  800e05:	e8 be f3 ff ff       	call   8001c8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e0a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e0d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e10:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e13:	89 ec                	mov    %ebp,%esp
  800e15:	5d                   	pop    %ebp
  800e16:	c3                   	ret    

00800e17 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e17:	55                   	push   %ebp
  800e18:	89 e5                	mov    %esp,%ebp
  800e1a:	83 ec 0c             	sub    $0xc,%esp
  800e1d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e20:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e23:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e26:	b8 01 00 00 00       	mov    $0x1,%eax
  800e2b:	0f a2                	cpuid  
  800e2d:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2f:	ba 00 00 00 00       	mov    $0x0,%edx
  800e34:	b8 02 00 00 00       	mov    $0x2,%eax
  800e39:	89 d1                	mov    %edx,%ecx
  800e3b:	89 d3                	mov    %edx,%ebx
  800e3d:	89 d7                	mov    %edx,%edi
  800e3f:	89 d6                	mov    %edx,%esi
  800e41:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e43:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e46:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e49:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e4c:	89 ec                	mov    %ebp,%esp
  800e4e:	5d                   	pop    %ebp
  800e4f:	c3                   	ret    

00800e50 <sys_yield>:

void
sys_yield(void)
{
  800e50:	55                   	push   %ebp
  800e51:	89 e5                	mov    %esp,%ebp
  800e53:	83 ec 0c             	sub    $0xc,%esp
  800e56:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e59:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e5c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e5f:	b8 01 00 00 00       	mov    $0x1,%eax
  800e64:	0f a2                	cpuid  
  800e66:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e68:	ba 00 00 00 00       	mov    $0x0,%edx
  800e6d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e72:	89 d1                	mov    %edx,%ecx
  800e74:	89 d3                	mov    %edx,%ebx
  800e76:	89 d7                	mov    %edx,%edi
  800e78:	89 d6                	mov    %edx,%esi
  800e7a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e7c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e7f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e82:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e85:	89 ec                	mov    %ebp,%esp
  800e87:	5d                   	pop    %ebp
  800e88:	c3                   	ret    

00800e89 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e89:	55                   	push   %ebp
  800e8a:	89 e5                	mov    %esp,%ebp
  800e8c:	83 ec 38             	sub    $0x38,%esp
  800e8f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e92:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e95:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e98:	b8 01 00 00 00       	mov    $0x1,%eax
  800e9d:	0f a2                	cpuid  
  800e9f:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea1:	be 00 00 00 00       	mov    $0x0,%esi
  800ea6:	b8 04 00 00 00       	mov    $0x4,%eax
  800eab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eae:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eb4:	89 f7                	mov    %esi,%edi
  800eb6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eb8:	85 c0                	test   %eax,%eax
  800eba:	7e 28                	jle    800ee4 <sys_page_alloc+0x5b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ebc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ec0:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800ec7:	00 
  800ec8:	c7 44 24 08 bf 27 80 	movl   $0x8027bf,0x8(%esp)
  800ecf:	00 
  800ed0:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800ed7:	00 
  800ed8:	c7 04 24 dc 27 80 00 	movl   $0x8027dc,(%esp)
  800edf:	e8 e4 f2 ff ff       	call   8001c8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ee4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ee7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800eea:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800eed:	89 ec                	mov    %ebp,%esp
  800eef:	5d                   	pop    %ebp
  800ef0:	c3                   	ret    

00800ef1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ef1:	55                   	push   %ebp
  800ef2:	89 e5                	mov    %esp,%ebp
  800ef4:	83 ec 38             	sub    $0x38,%esp
  800ef7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800efa:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800efd:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800f00:	b8 01 00 00 00       	mov    $0x1,%eax
  800f05:	0f a2                	cpuid  
  800f07:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f09:	b8 05 00 00 00       	mov    $0x5,%eax
  800f0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f11:	8b 55 08             	mov    0x8(%ebp),%edx
  800f14:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f17:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f1a:	8b 75 18             	mov    0x18(%ebp),%esi
  800f1d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f1f:	85 c0                	test   %eax,%eax
  800f21:	7e 28                	jle    800f4b <sys_page_map+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f23:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f27:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f2e:	00 
  800f2f:	c7 44 24 08 bf 27 80 	movl   $0x8027bf,0x8(%esp)
  800f36:	00 
  800f37:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800f3e:	00 
  800f3f:	c7 04 24 dc 27 80 00 	movl   $0x8027dc,(%esp)
  800f46:	e8 7d f2 ff ff       	call   8001c8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f4b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f4e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f51:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f54:	89 ec                	mov    %ebp,%esp
  800f56:	5d                   	pop    %ebp
  800f57:	c3                   	ret    

00800f58 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f58:	55                   	push   %ebp
  800f59:	89 e5                	mov    %esp,%ebp
  800f5b:	83 ec 38             	sub    $0x38,%esp
  800f5e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f61:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f64:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800f67:	b8 01 00 00 00       	mov    $0x1,%eax
  800f6c:	0f a2                	cpuid  
  800f6e:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f70:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f75:	b8 06 00 00 00       	mov    $0x6,%eax
  800f7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f80:	89 df                	mov    %ebx,%edi
  800f82:	89 de                	mov    %ebx,%esi
  800f84:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f86:	85 c0                	test   %eax,%eax
  800f88:	7e 28                	jle    800fb2 <sys_page_unmap+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f8a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f8e:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f95:	00 
  800f96:	c7 44 24 08 bf 27 80 	movl   $0x8027bf,0x8(%esp)
  800f9d:	00 
  800f9e:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800fa5:	00 
  800fa6:	c7 04 24 dc 27 80 00 	movl   $0x8027dc,(%esp)
  800fad:	e8 16 f2 ff ff       	call   8001c8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800fb2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fb5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fb8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fbb:	89 ec                	mov    %ebp,%esp
  800fbd:	5d                   	pop    %ebp
  800fbe:	c3                   	ret    

00800fbf <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800fbf:	55                   	push   %ebp
  800fc0:	89 e5                	mov    %esp,%ebp
  800fc2:	83 ec 38             	sub    $0x38,%esp
  800fc5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fc8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fcb:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800fce:	b8 01 00 00 00       	mov    $0x1,%eax
  800fd3:	0f a2                	cpuid  
  800fd5:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fdc:	b8 08 00 00 00       	mov    $0x8,%eax
  800fe1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe4:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe7:	89 df                	mov    %ebx,%edi
  800fe9:	89 de                	mov    %ebx,%esi
  800feb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fed:	85 c0                	test   %eax,%eax
  800fef:	7e 28                	jle    801019 <sys_env_set_status+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ff1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ff5:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800ffc:	00 
  800ffd:	c7 44 24 08 bf 27 80 	movl   $0x8027bf,0x8(%esp)
  801004:	00 
  801005:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  80100c:	00 
  80100d:	c7 04 24 dc 27 80 00 	movl   $0x8027dc,(%esp)
  801014:	e8 af f1 ff ff       	call   8001c8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801019:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80101c:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80101f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801022:	89 ec                	mov    %ebp,%esp
  801024:	5d                   	pop    %ebp
  801025:	c3                   	ret    

00801026 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801026:	55                   	push   %ebp
  801027:	89 e5                	mov    %esp,%ebp
  801029:	83 ec 38             	sub    $0x38,%esp
  80102c:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80102f:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801032:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801035:	b8 01 00 00 00       	mov    $0x1,%eax
  80103a:	0f a2                	cpuid  
  80103c:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80103e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801043:	b8 09 00 00 00       	mov    $0x9,%eax
  801048:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80104b:	8b 55 08             	mov    0x8(%ebp),%edx
  80104e:	89 df                	mov    %ebx,%edi
  801050:	89 de                	mov    %ebx,%esi
  801052:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801054:	85 c0                	test   %eax,%eax
  801056:	7e 28                	jle    801080 <sys_env_set_trapframe+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801058:	89 44 24 10          	mov    %eax,0x10(%esp)
  80105c:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801063:	00 
  801064:	c7 44 24 08 bf 27 80 	movl   $0x8027bf,0x8(%esp)
  80106b:	00 
  80106c:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  801073:	00 
  801074:	c7 04 24 dc 27 80 00 	movl   $0x8027dc,(%esp)
  80107b:	e8 48 f1 ff ff       	call   8001c8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801080:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801083:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801086:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801089:	89 ec                	mov    %ebp,%esp
  80108b:	5d                   	pop    %ebp
  80108c:	c3                   	ret    

0080108d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80108d:	55                   	push   %ebp
  80108e:	89 e5                	mov    %esp,%ebp
  801090:	83 ec 38             	sub    $0x38,%esp
  801093:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801096:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801099:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80109c:	b8 01 00 00 00       	mov    $0x1,%eax
  8010a1:	0f a2                	cpuid  
  8010a3:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010a5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010aa:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8010b5:	89 df                	mov    %ebx,%edi
  8010b7:	89 de                	mov    %ebx,%esi
  8010b9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010bb:	85 c0                	test   %eax,%eax
  8010bd:	7e 28                	jle    8010e7 <sys_env_set_pgfault_upcall+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010bf:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010c3:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8010ca:	00 
  8010cb:	c7 44 24 08 bf 27 80 	movl   $0x8027bf,0x8(%esp)
  8010d2:	00 
  8010d3:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  8010da:	00 
  8010db:	c7 04 24 dc 27 80 00 	movl   $0x8027dc,(%esp)
  8010e2:	e8 e1 f0 ff ff       	call   8001c8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010e7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010ea:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010ed:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010f0:	89 ec                	mov    %ebp,%esp
  8010f2:	5d                   	pop    %ebp
  8010f3:	c3                   	ret    

008010f4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010f4:	55                   	push   %ebp
  8010f5:	89 e5                	mov    %esp,%ebp
  8010f7:	83 ec 0c             	sub    $0xc,%esp
  8010fa:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010fd:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801100:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801103:	b8 01 00 00 00       	mov    $0x1,%eax
  801108:	0f a2                	cpuid  
  80110a:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80110c:	be 00 00 00 00       	mov    $0x0,%esi
  801111:	b8 0c 00 00 00       	mov    $0xc,%eax
  801116:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801119:	8b 55 08             	mov    0x8(%ebp),%edx
  80111c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80111f:	8b 7d 14             	mov    0x14(%ebp),%edi
  801122:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801124:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801127:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80112a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80112d:	89 ec                	mov    %ebp,%esp
  80112f:	5d                   	pop    %ebp
  801130:	c3                   	ret    

00801131 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801131:	55                   	push   %ebp
  801132:	89 e5                	mov    %esp,%ebp
  801134:	83 ec 38             	sub    $0x38,%esp
  801137:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80113a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80113d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801140:	b8 01 00 00 00       	mov    $0x1,%eax
  801145:	0f a2                	cpuid  
  801147:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801149:	b9 00 00 00 00       	mov    $0x0,%ecx
  80114e:	b8 0d 00 00 00       	mov    $0xd,%eax
  801153:	8b 55 08             	mov    0x8(%ebp),%edx
  801156:	89 cb                	mov    %ecx,%ebx
  801158:	89 cf                	mov    %ecx,%edi
  80115a:	89 ce                	mov    %ecx,%esi
  80115c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80115e:	85 c0                	test   %eax,%eax
  801160:	7e 28                	jle    80118a <sys_ipc_recv+0x59>
		panic("syscall %d returned %d (> 0)", num, ret);
  801162:	89 44 24 10          	mov    %eax,0x10(%esp)
  801166:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  80116d:	00 
  80116e:	c7 44 24 08 bf 27 80 	movl   $0x8027bf,0x8(%esp)
  801175:	00 
  801176:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  80117d:	00 
  80117e:	c7 04 24 dc 27 80 00 	movl   $0x8027dc,(%esp)
  801185:	e8 3e f0 ff ff       	call   8001c8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80118a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80118d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801190:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801193:	89 ec                	mov    %ebp,%esp
  801195:	5d                   	pop    %ebp
  801196:	c3                   	ret    
  801197:	66 90                	xchg   %ax,%ax
  801199:	66 90                	xchg   %ax,%ax
  80119b:	66 90                	xchg   %ax,%ax
  80119d:	66 90                	xchg   %ax,%ax
  80119f:	90                   	nop

008011a0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011a0:	55                   	push   %ebp
  8011a1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a6:	05 00 00 00 30       	add    $0x30000000,%eax
  8011ab:	c1 e8 0c             	shr    $0xc,%eax
}
  8011ae:	5d                   	pop    %ebp
  8011af:	c3                   	ret    

008011b0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011b0:	55                   	push   %ebp
  8011b1:	89 e5                	mov    %esp,%ebp
  8011b3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8011b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b9:	89 04 24             	mov    %eax,(%esp)
  8011bc:	e8 df ff ff ff       	call   8011a0 <fd2num>
  8011c1:	c1 e0 0c             	shl    $0xc,%eax
  8011c4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011c9:	c9                   	leave  
  8011ca:	c3                   	ret    

008011cb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011cb:	55                   	push   %ebp
  8011cc:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8011ce:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8011d3:	a8 01                	test   $0x1,%al
  8011d5:	74 34                	je     80120b <fd_alloc+0x40>
  8011d7:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8011dc:	a8 01                	test   $0x1,%al
  8011de:	74 32                	je     801212 <fd_alloc+0x47>
  8011e0:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8011e5:	89 c1                	mov    %eax,%ecx
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8011e7:	89 c2                	mov    %eax,%edx
  8011e9:	c1 ea 16             	shr    $0x16,%edx
  8011ec:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011f3:	f6 c2 01             	test   $0x1,%dl
  8011f6:	74 1f                	je     801217 <fd_alloc+0x4c>
  8011f8:	89 c2                	mov    %eax,%edx
  8011fa:	c1 ea 0c             	shr    $0xc,%edx
  8011fd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801204:	f6 c2 01             	test   $0x1,%dl
  801207:	75 1a                	jne    801223 <fd_alloc+0x58>
  801209:	eb 0c                	jmp    801217 <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80120b:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801210:	eb 05                	jmp    801217 <fd_alloc+0x4c>
  801212:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  801217:	8b 45 08             	mov    0x8(%ebp),%eax
  80121a:	89 08                	mov    %ecx,(%eax)
			return 0;
  80121c:	b8 00 00 00 00       	mov    $0x0,%eax
  801221:	eb 1a                	jmp    80123d <fd_alloc+0x72>
  801223:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801228:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80122d:	75 b6                	jne    8011e5 <fd_alloc+0x1a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80122f:	8b 45 08             	mov    0x8(%ebp),%eax
  801232:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801238:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80123d:	5d                   	pop    %ebp
  80123e:	c3                   	ret    

0080123f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80123f:	55                   	push   %ebp
  801240:	89 e5                	mov    %esp,%ebp
  801242:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801245:	83 f8 1f             	cmp    $0x1f,%eax
  801248:	77 36                	ja     801280 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80124a:	c1 e0 0c             	shl    $0xc,%eax
  80124d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801252:	89 c2                	mov    %eax,%edx
  801254:	c1 ea 16             	shr    $0x16,%edx
  801257:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80125e:	f6 c2 01             	test   $0x1,%dl
  801261:	74 24                	je     801287 <fd_lookup+0x48>
  801263:	89 c2                	mov    %eax,%edx
  801265:	c1 ea 0c             	shr    $0xc,%edx
  801268:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80126f:	f6 c2 01             	test   $0x1,%dl
  801272:	74 1a                	je     80128e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801274:	8b 55 0c             	mov    0xc(%ebp),%edx
  801277:	89 02                	mov    %eax,(%edx)
	return 0;
  801279:	b8 00 00 00 00       	mov    $0x0,%eax
  80127e:	eb 13                	jmp    801293 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  801280:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801285:	eb 0c                	jmp    801293 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  801287:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80128c:	eb 05                	jmp    801293 <fd_lookup+0x54>
  80128e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801293:	5d                   	pop    %ebp
  801294:	c3                   	ret    

00801295 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801295:	55                   	push   %ebp
  801296:	89 e5                	mov    %esp,%ebp
  801298:	83 ec 18             	sub    $0x18,%esp
  80129b:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80129e:	39 05 04 30 80 00    	cmp    %eax,0x803004
  8012a4:	75 10                	jne    8012b6 <dev_lookup+0x21>
			*dev = devtab[i];
  8012a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012a9:	c7 00 04 30 80 00    	movl   $0x803004,(%eax)
			return 0;
  8012af:	b8 00 00 00 00       	mov    $0x0,%eax
  8012b4:	eb 2b                	jmp    8012e1 <dev_lookup+0x4c>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012b6:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8012bc:	8b 52 48             	mov    0x48(%edx),%edx
  8012bf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8012c7:	c7 04 24 ec 27 80 00 	movl   $0x8027ec,(%esp)
  8012ce:	e8 f0 ef ff ff       	call   8002c3 <cprintf>
	*dev = 0;
  8012d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012d6:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	return -E_INVAL;
  8012dc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012e1:	c9                   	leave  
  8012e2:	c3                   	ret    

008012e3 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012e3:	55                   	push   %ebp
  8012e4:	89 e5                	mov    %esp,%ebp
  8012e6:	83 ec 38             	sub    $0x38,%esp
  8012e9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8012ec:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8012ef:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8012f2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012f5:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012f8:	89 3c 24             	mov    %edi,(%esp)
  8012fb:	e8 a0 fe ff ff       	call   8011a0 <fd2num>
  801300:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  801303:	89 54 24 04          	mov    %edx,0x4(%esp)
  801307:	89 04 24             	mov    %eax,(%esp)
  80130a:	e8 30 ff ff ff       	call   80123f <fd_lookup>
  80130f:	89 c3                	mov    %eax,%ebx
  801311:	85 c0                	test   %eax,%eax
  801313:	78 05                	js     80131a <fd_close+0x37>
	    || fd != fd2)
  801315:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  801318:	74 0c                	je     801326 <fd_close+0x43>
		return (must_exist ? r : 0);
  80131a:	85 f6                	test   %esi,%esi
  80131c:	b8 00 00 00 00       	mov    $0x0,%eax
  801321:	0f 44 d8             	cmove  %eax,%ebx
  801324:	eb 3d                	jmp    801363 <fd_close+0x80>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801326:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801329:	89 44 24 04          	mov    %eax,0x4(%esp)
  80132d:	8b 07                	mov    (%edi),%eax
  80132f:	89 04 24             	mov    %eax,(%esp)
  801332:	e8 5e ff ff ff       	call   801295 <dev_lookup>
  801337:	89 c3                	mov    %eax,%ebx
  801339:	85 c0                	test   %eax,%eax
  80133b:	78 16                	js     801353 <fd_close+0x70>
		if (dev->dev_close)
  80133d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801340:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801343:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801348:	85 c0                	test   %eax,%eax
  80134a:	74 07                	je     801353 <fd_close+0x70>
			r = (*dev->dev_close)(fd);
  80134c:	89 3c 24             	mov    %edi,(%esp)
  80134f:	ff d0                	call   *%eax
  801351:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801353:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801357:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80135e:	e8 f5 fb ff ff       	call   800f58 <sys_page_unmap>
	return r;
}
  801363:	89 d8                	mov    %ebx,%eax
  801365:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801368:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80136b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80136e:	89 ec                	mov    %ebp,%esp
  801370:	5d                   	pop    %ebp
  801371:	c3                   	ret    

00801372 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801372:	55                   	push   %ebp
  801373:	89 e5                	mov    %esp,%ebp
  801375:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801378:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80137b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80137f:	8b 45 08             	mov    0x8(%ebp),%eax
  801382:	89 04 24             	mov    %eax,(%esp)
  801385:	e8 b5 fe ff ff       	call   80123f <fd_lookup>
  80138a:	85 c0                	test   %eax,%eax
  80138c:	78 13                	js     8013a1 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80138e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801395:	00 
  801396:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801399:	89 04 24             	mov    %eax,(%esp)
  80139c:	e8 42 ff ff ff       	call   8012e3 <fd_close>
}
  8013a1:	c9                   	leave  
  8013a2:	c3                   	ret    

008013a3 <close_all>:

void
close_all(void)
{
  8013a3:	55                   	push   %ebp
  8013a4:	89 e5                	mov    %esp,%ebp
  8013a6:	53                   	push   %ebx
  8013a7:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013aa:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013af:	89 1c 24             	mov    %ebx,(%esp)
  8013b2:	e8 bb ff ff ff       	call   801372 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013b7:	83 c3 01             	add    $0x1,%ebx
  8013ba:	83 fb 20             	cmp    $0x20,%ebx
  8013bd:	75 f0                	jne    8013af <close_all+0xc>
		close(i);
}
  8013bf:	83 c4 14             	add    $0x14,%esp
  8013c2:	5b                   	pop    %ebx
  8013c3:	5d                   	pop    %ebp
  8013c4:	c3                   	ret    

008013c5 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013c5:	55                   	push   %ebp
  8013c6:	89 e5                	mov    %esp,%ebp
  8013c8:	83 ec 58             	sub    $0x58,%esp
  8013cb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8013ce:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8013d1:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8013d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013d7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013de:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e1:	89 04 24             	mov    %eax,(%esp)
  8013e4:	e8 56 fe ff ff       	call   80123f <fd_lookup>
  8013e9:	85 c0                	test   %eax,%eax
  8013eb:	0f 88 e3 00 00 00    	js     8014d4 <dup+0x10f>
		return r;
	close(newfdnum);
  8013f1:	89 1c 24             	mov    %ebx,(%esp)
  8013f4:	e8 79 ff ff ff       	call   801372 <close>

	newfd = INDEX2FD(newfdnum);
  8013f9:	89 de                	mov    %ebx,%esi
  8013fb:	c1 e6 0c             	shl    $0xc,%esi
  8013fe:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801404:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801407:	89 04 24             	mov    %eax,(%esp)
  80140a:	e8 a1 fd ff ff       	call   8011b0 <fd2data>
  80140f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801411:	89 34 24             	mov    %esi,(%esp)
  801414:	e8 97 fd ff ff       	call   8011b0 <fd2data>
  801419:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  80141c:	89 f8                	mov    %edi,%eax
  80141e:	c1 e8 16             	shr    $0x16,%eax
  801421:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801428:	a8 01                	test   $0x1,%al
  80142a:	74 46                	je     801472 <dup+0xad>
  80142c:	89 f8                	mov    %edi,%eax
  80142e:	c1 e8 0c             	shr    $0xc,%eax
  801431:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801438:	f6 c2 01             	test   $0x1,%dl
  80143b:	74 35                	je     801472 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80143d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801444:	25 07 0e 00 00       	and    $0xe07,%eax
  801449:	89 44 24 10          	mov    %eax,0x10(%esp)
  80144d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801450:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801454:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80145b:	00 
  80145c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801460:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801467:	e8 85 fa ff ff       	call   800ef1 <sys_page_map>
  80146c:	89 c7                	mov    %eax,%edi
  80146e:	85 c0                	test   %eax,%eax
  801470:	78 3b                	js     8014ad <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801472:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801475:	89 c2                	mov    %eax,%edx
  801477:	c1 ea 0c             	shr    $0xc,%edx
  80147a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801481:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801487:	89 54 24 10          	mov    %edx,0x10(%esp)
  80148b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80148f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801496:	00 
  801497:	89 44 24 04          	mov    %eax,0x4(%esp)
  80149b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014a2:	e8 4a fa ff ff       	call   800ef1 <sys_page_map>
  8014a7:	89 c7                	mov    %eax,%edi
  8014a9:	85 c0                	test   %eax,%eax
  8014ab:	79 29                	jns    8014d6 <dup+0x111>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014ad:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014b8:	e8 9b fa ff ff       	call   800f58 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014bd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8014c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014c4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014cb:	e8 88 fa ff ff       	call   800f58 <sys_page_unmap>
	return r;
  8014d0:	89 fb                	mov    %edi,%ebx
  8014d2:	eb 02                	jmp    8014d6 <dup+0x111>
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
		return r;
  8014d4:	89 c3                	mov    %eax,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8014d6:	89 d8                	mov    %ebx,%eax
  8014d8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8014db:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8014de:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8014e1:	89 ec                	mov    %ebp,%esp
  8014e3:	5d                   	pop    %ebp
  8014e4:	c3                   	ret    

008014e5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014e5:	55                   	push   %ebp
  8014e6:	89 e5                	mov    %esp,%ebp
  8014e8:	53                   	push   %ebx
  8014e9:	83 ec 24             	sub    $0x24,%esp
  8014ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014f6:	89 1c 24             	mov    %ebx,(%esp)
  8014f9:	e8 41 fd ff ff       	call   80123f <fd_lookup>
  8014fe:	85 c0                	test   %eax,%eax
  801500:	78 6d                	js     80156f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801502:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801505:	89 44 24 04          	mov    %eax,0x4(%esp)
  801509:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80150c:	8b 00                	mov    (%eax),%eax
  80150e:	89 04 24             	mov    %eax,(%esp)
  801511:	e8 7f fd ff ff       	call   801295 <dev_lookup>
  801516:	85 c0                	test   %eax,%eax
  801518:	78 55                	js     80156f <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80151a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80151d:	8b 50 08             	mov    0x8(%eax),%edx
  801520:	83 e2 03             	and    $0x3,%edx
  801523:	83 fa 01             	cmp    $0x1,%edx
  801526:	75 23                	jne    80154b <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801528:	a1 04 40 80 00       	mov    0x804004,%eax
  80152d:	8b 40 48             	mov    0x48(%eax),%eax
  801530:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801534:	89 44 24 04          	mov    %eax,0x4(%esp)
  801538:	c7 04 24 2d 28 80 00 	movl   $0x80282d,(%esp)
  80153f:	e8 7f ed ff ff       	call   8002c3 <cprintf>
		return -E_INVAL;
  801544:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801549:	eb 24                	jmp    80156f <read+0x8a>
	}
	if (!dev->dev_read)
  80154b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80154e:	8b 52 08             	mov    0x8(%edx),%edx
  801551:	85 d2                	test   %edx,%edx
  801553:	74 15                	je     80156a <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801555:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801558:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80155c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80155f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801563:	89 04 24             	mov    %eax,(%esp)
  801566:	ff d2                	call   *%edx
  801568:	eb 05                	jmp    80156f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80156a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80156f:	83 c4 24             	add    $0x24,%esp
  801572:	5b                   	pop    %ebx
  801573:	5d                   	pop    %ebp
  801574:	c3                   	ret    

00801575 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801575:	55                   	push   %ebp
  801576:	89 e5                	mov    %esp,%ebp
  801578:	57                   	push   %edi
  801579:	56                   	push   %esi
  80157a:	53                   	push   %ebx
  80157b:	83 ec 1c             	sub    $0x1c,%esp
  80157e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801581:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801584:	85 f6                	test   %esi,%esi
  801586:	74 33                	je     8015bb <readn+0x46>
  801588:	b8 00 00 00 00       	mov    $0x0,%eax
  80158d:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801592:	89 f2                	mov    %esi,%edx
  801594:	29 c2                	sub    %eax,%edx
  801596:	89 54 24 08          	mov    %edx,0x8(%esp)
  80159a:	03 45 0c             	add    0xc(%ebp),%eax
  80159d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015a1:	89 3c 24             	mov    %edi,(%esp)
  8015a4:	e8 3c ff ff ff       	call   8014e5 <read>
		if (m < 0)
  8015a9:	85 c0                	test   %eax,%eax
  8015ab:	78 17                	js     8015c4 <readn+0x4f>
			return m;
		if (m == 0)
  8015ad:	85 c0                	test   %eax,%eax
  8015af:	74 11                	je     8015c2 <readn+0x4d>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015b1:	01 c3                	add    %eax,%ebx
  8015b3:	89 d8                	mov    %ebx,%eax
  8015b5:	39 f3                	cmp    %esi,%ebx
  8015b7:	72 d9                	jb     801592 <readn+0x1d>
  8015b9:	eb 09                	jmp    8015c4 <readn+0x4f>
  8015bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8015c0:	eb 02                	jmp    8015c4 <readn+0x4f>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8015c2:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8015c4:	83 c4 1c             	add    $0x1c,%esp
  8015c7:	5b                   	pop    %ebx
  8015c8:	5e                   	pop    %esi
  8015c9:	5f                   	pop    %edi
  8015ca:	5d                   	pop    %ebp
  8015cb:	c3                   	ret    

008015cc <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015cc:	55                   	push   %ebp
  8015cd:	89 e5                	mov    %esp,%ebp
  8015cf:	53                   	push   %ebx
  8015d0:	83 ec 24             	sub    $0x24,%esp
  8015d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015d6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015dd:	89 1c 24             	mov    %ebx,(%esp)
  8015e0:	e8 5a fc ff ff       	call   80123f <fd_lookup>
  8015e5:	85 c0                	test   %eax,%eax
  8015e7:	78 68                	js     801651 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f3:	8b 00                	mov    (%eax),%eax
  8015f5:	89 04 24             	mov    %eax,(%esp)
  8015f8:	e8 98 fc ff ff       	call   801295 <dev_lookup>
  8015fd:	85 c0                	test   %eax,%eax
  8015ff:	78 50                	js     801651 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801601:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801604:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801608:	75 23                	jne    80162d <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80160a:	a1 04 40 80 00       	mov    0x804004,%eax
  80160f:	8b 40 48             	mov    0x48(%eax),%eax
  801612:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801616:	89 44 24 04          	mov    %eax,0x4(%esp)
  80161a:	c7 04 24 49 28 80 00 	movl   $0x802849,(%esp)
  801621:	e8 9d ec ff ff       	call   8002c3 <cprintf>
		return -E_INVAL;
  801626:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80162b:	eb 24                	jmp    801651 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80162d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801630:	8b 52 0c             	mov    0xc(%edx),%edx
  801633:	85 d2                	test   %edx,%edx
  801635:	74 15                	je     80164c <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801637:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80163a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80163e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801641:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801645:	89 04 24             	mov    %eax,(%esp)
  801648:	ff d2                	call   *%edx
  80164a:	eb 05                	jmp    801651 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80164c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801651:	83 c4 24             	add    $0x24,%esp
  801654:	5b                   	pop    %ebx
  801655:	5d                   	pop    %ebp
  801656:	c3                   	ret    

00801657 <seek>:

int
seek(int fdnum, off_t offset)
{
  801657:	55                   	push   %ebp
  801658:	89 e5                	mov    %esp,%ebp
  80165a:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80165d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801660:	89 44 24 04          	mov    %eax,0x4(%esp)
  801664:	8b 45 08             	mov    0x8(%ebp),%eax
  801667:	89 04 24             	mov    %eax,(%esp)
  80166a:	e8 d0 fb ff ff       	call   80123f <fd_lookup>
  80166f:	85 c0                	test   %eax,%eax
  801671:	78 0e                	js     801681 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801673:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801676:	8b 55 0c             	mov    0xc(%ebp),%edx
  801679:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80167c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801681:	c9                   	leave  
  801682:	c3                   	ret    

00801683 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801683:	55                   	push   %ebp
  801684:	89 e5                	mov    %esp,%ebp
  801686:	53                   	push   %ebx
  801687:	83 ec 24             	sub    $0x24,%esp
  80168a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80168d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801690:	89 44 24 04          	mov    %eax,0x4(%esp)
  801694:	89 1c 24             	mov    %ebx,(%esp)
  801697:	e8 a3 fb ff ff       	call   80123f <fd_lookup>
  80169c:	85 c0                	test   %eax,%eax
  80169e:	78 61                	js     801701 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016aa:	8b 00                	mov    (%eax),%eax
  8016ac:	89 04 24             	mov    %eax,(%esp)
  8016af:	e8 e1 fb ff ff       	call   801295 <dev_lookup>
  8016b4:	85 c0                	test   %eax,%eax
  8016b6:	78 49                	js     801701 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016bb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016bf:	75 23                	jne    8016e4 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016c1:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016c6:	8b 40 48             	mov    0x48(%eax),%eax
  8016c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8016cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016d1:	c7 04 24 0c 28 80 00 	movl   $0x80280c,(%esp)
  8016d8:	e8 e6 eb ff ff       	call   8002c3 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016e2:	eb 1d                	jmp    801701 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8016e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016e7:	8b 52 18             	mov    0x18(%edx),%edx
  8016ea:	85 d2                	test   %edx,%edx
  8016ec:	74 0e                	je     8016fc <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016f1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8016f5:	89 04 24             	mov    %eax,(%esp)
  8016f8:	ff d2                	call   *%edx
  8016fa:	eb 05                	jmp    801701 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016fc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801701:	83 c4 24             	add    $0x24,%esp
  801704:	5b                   	pop    %ebx
  801705:	5d                   	pop    %ebp
  801706:	c3                   	ret    

00801707 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801707:	55                   	push   %ebp
  801708:	89 e5                	mov    %esp,%ebp
  80170a:	53                   	push   %ebx
  80170b:	83 ec 24             	sub    $0x24,%esp
  80170e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801711:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801714:	89 44 24 04          	mov    %eax,0x4(%esp)
  801718:	8b 45 08             	mov    0x8(%ebp),%eax
  80171b:	89 04 24             	mov    %eax,(%esp)
  80171e:	e8 1c fb ff ff       	call   80123f <fd_lookup>
  801723:	85 c0                	test   %eax,%eax
  801725:	78 52                	js     801779 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801727:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80172a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80172e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801731:	8b 00                	mov    (%eax),%eax
  801733:	89 04 24             	mov    %eax,(%esp)
  801736:	e8 5a fb ff ff       	call   801295 <dev_lookup>
  80173b:	85 c0                	test   %eax,%eax
  80173d:	78 3a                	js     801779 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  80173f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801742:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801746:	74 2c                	je     801774 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801748:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80174b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801752:	00 00 00 
	stat->st_isdir = 0;
  801755:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80175c:	00 00 00 
	stat->st_dev = dev;
  80175f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801765:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801769:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80176c:	89 14 24             	mov    %edx,(%esp)
  80176f:	ff 50 14             	call   *0x14(%eax)
  801772:	eb 05                	jmp    801779 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801774:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801779:	83 c4 24             	add    $0x24,%esp
  80177c:	5b                   	pop    %ebx
  80177d:	5d                   	pop    %ebp
  80177e:	c3                   	ret    

0080177f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80177f:	55                   	push   %ebp
  801780:	89 e5                	mov    %esp,%ebp
  801782:	83 ec 18             	sub    $0x18,%esp
  801785:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801788:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80178b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801792:	00 
  801793:	8b 45 08             	mov    0x8(%ebp),%eax
  801796:	89 04 24             	mov    %eax,(%esp)
  801799:	e8 84 01 00 00       	call   801922 <open>
  80179e:	89 c3                	mov    %eax,%ebx
  8017a0:	85 c0                	test   %eax,%eax
  8017a2:	78 1b                	js     8017bf <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  8017a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ab:	89 1c 24             	mov    %ebx,(%esp)
  8017ae:	e8 54 ff ff ff       	call   801707 <fstat>
  8017b3:	89 c6                	mov    %eax,%esi
	close(fd);
  8017b5:	89 1c 24             	mov    %ebx,(%esp)
  8017b8:	e8 b5 fb ff ff       	call   801372 <close>
	return r;
  8017bd:	89 f3                	mov    %esi,%ebx
}
  8017bf:	89 d8                	mov    %ebx,%eax
  8017c1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8017c4:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8017c7:	89 ec                	mov    %ebp,%esp
  8017c9:	5d                   	pop    %ebp
  8017ca:	c3                   	ret    
  8017cb:	90                   	nop

008017cc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017cc:	55                   	push   %ebp
  8017cd:	89 e5                	mov    %esp,%ebp
  8017cf:	83 ec 18             	sub    $0x18,%esp
  8017d2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8017d5:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8017d8:	89 c6                	mov    %eax,%esi
  8017da:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017dc:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017e3:	75 11                	jne    8017f6 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017e5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8017ec:	e8 8a 08 00 00       	call   80207b <ipc_find_env>
  8017f1:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017f6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8017fd:	00 
  8017fe:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801805:	00 
  801806:	89 74 24 04          	mov    %esi,0x4(%esp)
  80180a:	a1 00 40 80 00       	mov    0x804000,%eax
  80180f:	89 04 24             	mov    %eax,(%esp)
  801812:	e8 f9 07 00 00       	call   802010 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801817:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80181e:	00 
  80181f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801823:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80182a:	e8 89 07 00 00       	call   801fb8 <ipc_recv>
}
  80182f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801832:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801835:	89 ec                	mov    %ebp,%esp
  801837:	5d                   	pop    %ebp
  801838:	c3                   	ret    

00801839 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801839:	55                   	push   %ebp
  80183a:	89 e5                	mov    %esp,%ebp
  80183c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80183f:	8b 45 08             	mov    0x8(%ebp),%eax
  801842:	8b 40 0c             	mov    0xc(%eax),%eax
  801845:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80184a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80184d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801852:	ba 00 00 00 00       	mov    $0x0,%edx
  801857:	b8 02 00 00 00       	mov    $0x2,%eax
  80185c:	e8 6b ff ff ff       	call   8017cc <fsipc>
}
  801861:	c9                   	leave  
  801862:	c3                   	ret    

00801863 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801863:	55                   	push   %ebp
  801864:	89 e5                	mov    %esp,%ebp
  801866:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801869:	8b 45 08             	mov    0x8(%ebp),%eax
  80186c:	8b 40 0c             	mov    0xc(%eax),%eax
  80186f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801874:	ba 00 00 00 00       	mov    $0x0,%edx
  801879:	b8 06 00 00 00       	mov    $0x6,%eax
  80187e:	e8 49 ff ff ff       	call   8017cc <fsipc>
}
  801883:	c9                   	leave  
  801884:	c3                   	ret    

00801885 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801885:	55                   	push   %ebp
  801886:	89 e5                	mov    %esp,%ebp
  801888:	53                   	push   %ebx
  801889:	83 ec 14             	sub    $0x14,%esp
  80188c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80188f:	8b 45 08             	mov    0x8(%ebp),%eax
  801892:	8b 40 0c             	mov    0xc(%eax),%eax
  801895:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80189a:	ba 00 00 00 00       	mov    $0x0,%edx
  80189f:	b8 05 00 00 00       	mov    $0x5,%eax
  8018a4:	e8 23 ff ff ff       	call   8017cc <fsipc>
  8018a9:	85 c0                	test   %eax,%eax
  8018ab:	78 2b                	js     8018d8 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018ad:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8018b4:	00 
  8018b5:	89 1c 24             	mov    %ebx,(%esp)
  8018b8:	e8 7e f0 ff ff       	call   80093b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018bd:	a1 80 50 80 00       	mov    0x805080,%eax
  8018c2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018c8:	a1 84 50 80 00       	mov    0x805084,%eax
  8018cd:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018d8:	83 c4 14             	add    $0x14,%esp
  8018db:	5b                   	pop    %ebx
  8018dc:	5d                   	pop    %ebp
  8018dd:	c3                   	ret    

008018de <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018de:	55                   	push   %ebp
  8018df:	89 e5                	mov    %esp,%ebp
  8018e1:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8018e4:	c7 44 24 08 66 28 80 	movl   $0x802866,0x8(%esp)
  8018eb:	00 
  8018ec:	c7 44 24 04 77 00 00 	movl   $0x77,0x4(%esp)
  8018f3:	00 
  8018f4:	c7 04 24 84 28 80 00 	movl   $0x802884,(%esp)
  8018fb:	e8 c8 e8 ff ff       	call   8001c8 <_panic>

00801900 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801900:	55                   	push   %ebp
  801901:	89 e5                	mov    %esp,%ebp
  801903:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_READ request to the file system server after
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
	panic("devfile_read not implemented");
  801906:	c7 44 24 08 8f 28 80 	movl   $0x80288f,0x8(%esp)
  80190d:	00 
  80190e:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
  801915:	00 
  801916:	c7 04 24 84 28 80 00 	movl   $0x802884,(%esp)
  80191d:	e8 a6 e8 ff ff       	call   8001c8 <_panic>

00801922 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801922:	55                   	push   %ebp
  801923:	89 e5                	mov    %esp,%ebp
  801925:	83 ec 18             	sub    $0x18,%esp
	// Return the file descriptor index.
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
	panic("open not implemented");
  801928:	c7 44 24 08 ac 28 80 	movl   $0x8028ac,0x8(%esp)
  80192f:	00 
  801930:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  801937:	00 
  801938:	c7 04 24 84 28 80 00 	movl   $0x802884,(%esp)
  80193f:	e8 84 e8 ff ff       	call   8001c8 <_panic>

00801944 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801944:	55                   	push   %ebp
  801945:	89 e5                	mov    %esp,%ebp
  801947:	53                   	push   %ebx
  801948:	83 ec 14             	sub    $0x14,%esp
  80194b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  80194e:	89 1c 24             	mov    %ebx,(%esp)
  801951:	e8 8a ef ff ff       	call   8008e0 <strlen>
  801956:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80195b:	7f 21                	jg     80197e <remove+0x3a>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  80195d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801961:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801968:	e8 ce ef ff ff       	call   80093b <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  80196d:	ba 00 00 00 00       	mov    $0x0,%edx
  801972:	b8 07 00 00 00       	mov    $0x7,%eax
  801977:	e8 50 fe ff ff       	call   8017cc <fsipc>
  80197c:	eb 05                	jmp    801983 <remove+0x3f>
// Delete a file
int
remove(const char *path)
{
	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80197e:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
	strcpy(fsipcbuf.remove.req_path, path);
	return fsipc(FSREQ_REMOVE, NULL);
}
  801983:	83 c4 14             	add    $0x14,%esp
  801986:	5b                   	pop    %ebx
  801987:	5d                   	pop    %ebp
  801988:	c3                   	ret    

00801989 <sync>:

// Synchronize disk with buffer cache
int
sync(void)
{
  801989:	55                   	push   %ebp
  80198a:	89 e5                	mov    %esp,%ebp
  80198c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80198f:	ba 00 00 00 00       	mov    $0x0,%edx
  801994:	b8 08 00 00 00       	mov    $0x8,%eax
  801999:	e8 2e fe ff ff       	call   8017cc <fsipc>
}
  80199e:	c9                   	leave  
  80199f:	c3                   	ret    

008019a0 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8019a0:	55                   	push   %ebp
  8019a1:	89 e5                	mov    %esp,%ebp
  8019a3:	57                   	push   %edi
  8019a4:	56                   	push   %esi
  8019a5:	53                   	push   %ebx
  8019a6:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8019ac:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8019b3:	00 
  8019b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b7:	89 04 24             	mov    %eax,(%esp)
  8019ba:	e8 63 ff ff ff       	call   801922 <open>
  8019bf:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  8019c5:	85 c0                	test   %eax,%eax
  8019c7:	0f 88 f0 04 00 00    	js     801ebd <spawn+0x51d>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8019cd:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8019d4:	00 
  8019d5:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8019db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019df:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8019e5:	89 04 24             	mov    %eax,(%esp)
  8019e8:	e8 88 fb ff ff       	call   801575 <readn>
  8019ed:	3d 00 02 00 00       	cmp    $0x200,%eax
  8019f2:	75 0c                	jne    801a00 <spawn+0x60>
	    || elf->e_magic != ELF_MAGIC) {
  8019f4:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8019fb:	45 4c 46 
  8019fe:	74 36                	je     801a36 <spawn+0x96>
		close(fd);
  801a00:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801a06:	89 04 24             	mov    %eax,(%esp)
  801a09:	e8 64 f9 ff ff       	call   801372 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801a0e:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  801a15:	46 
  801a16:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  801a1c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a20:	c7 04 24 c1 28 80 00 	movl   $0x8028c1,(%esp)
  801a27:	e8 97 e8 ff ff       	call   8002c3 <cprintf>
		return -E_NOT_EXEC;
  801a2c:	bf f2 ff ff ff       	mov    $0xfffffff2,%edi
  801a31:	e9 e2 04 00 00       	jmp    801f18 <spawn+0x578>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801a36:	ba 07 00 00 00       	mov    $0x7,%edx
  801a3b:	89 d0                	mov    %edx,%eax
  801a3d:	cd 30                	int    $0x30
  801a3f:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801a45:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801a4b:	85 c0                	test   %eax,%eax
  801a4d:	0f 88 72 04 00 00    	js     801ec5 <spawn+0x525>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801a53:	89 c6                	mov    %eax,%esi
  801a55:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801a5b:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801a5e:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801a64:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801a6a:	b9 11 00 00 00       	mov    $0x11,%ecx
  801a6f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801a71:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801a77:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801a7d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a80:	8b 02                	mov    (%edx),%eax
  801a82:	85 c0                	test   %eax,%eax
  801a84:	74 37                	je     801abd <spawn+0x11d>
  801a86:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801a8b:	bf 00 00 00 00       	mov    $0x0,%edi
  801a90:	89 d6                	mov    %edx,%esi
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801a92:	89 04 24             	mov    %eax,(%esp)
  801a95:	e8 46 ee ff ff       	call   8008e0 <strlen>
  801a9a:	8d 7c 38 01          	lea    0x1(%eax,%edi,1),%edi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801a9e:	83 c3 01             	add    $0x1,%ebx
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801aa1:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801aa8:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  801aab:	85 c0                	test   %eax,%eax
  801aad:	75 e3                	jne    801a92 <spawn+0xf2>
  801aaf:	89 9d 80 fd ff ff    	mov    %ebx,-0x280(%ebp)
  801ab5:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
  801abb:	eb 1e                	jmp    801adb <spawn+0x13b>
  801abd:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  801ac4:	00 00 00 
  801ac7:	c7 85 80 fd ff ff 00 	movl   $0x0,-0x280(%ebp)
  801ace:	00 00 00 
  801ad1:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801ad6:	bf 00 00 00 00       	mov    $0x0,%edi
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801adb:	be 00 10 40 00       	mov    $0x401000,%esi
  801ae0:	29 fe                	sub    %edi,%esi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801ae2:	89 f2                	mov    %esi,%edx
  801ae4:	83 e2 fc             	and    $0xfffffffc,%edx
  801ae7:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801aee:	29 c2                	sub    %eax,%edx
  801af0:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801af6:	89 d0                	mov    %edx,%eax
  801af8:	83 e8 08             	sub    $0x8,%eax
  801afb:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801b00:	0f 86 cf 03 00 00    	jbe    801ed5 <spawn+0x535>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801b06:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801b0d:	00 
  801b0e:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801b15:	00 
  801b16:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b1d:	e8 67 f3 ff ff       	call   800e89 <sys_page_alloc>
  801b22:	89 c7                	mov    %eax,%edi
  801b24:	85 c0                	test   %eax,%eax
  801b26:	0f 88 ec 03 00 00    	js     801f18 <spawn+0x578>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801b2c:	85 db                	test   %ebx,%ebx
  801b2e:	7e 46                	jle    801b76 <spawn+0x1d6>
  801b30:	bf 00 00 00 00       	mov    $0x0,%edi
  801b35:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801b3b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
		argv_store[i] = UTEMP2USTACK(string_store);
  801b3e:	8d 86 00 d0 7f ee    	lea    -0x11803000(%esi),%eax
  801b44:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801b4a:	89 04 ba             	mov    %eax,(%edx,%edi,4)
		strcpy(string_store, argv[i]);
  801b4d:	8b 04 bb             	mov    (%ebx,%edi,4),%eax
  801b50:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b54:	89 34 24             	mov    %esi,(%esp)
  801b57:	e8 df ed ff ff       	call   80093b <strcpy>
		string_store += strlen(argv[i]) + 1;
  801b5c:	8b 04 bb             	mov    (%ebx,%edi,4),%eax
  801b5f:	89 04 24             	mov    %eax,(%esp)
  801b62:	e8 79 ed ff ff       	call   8008e0 <strlen>
  801b67:	8d 74 06 01          	lea    0x1(%esi,%eax,1),%esi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801b6b:	83 c7 01             	add    $0x1,%edi
  801b6e:	3b bd 90 fd ff ff    	cmp    -0x270(%ebp),%edi
  801b74:	75 c8                	jne    801b3e <spawn+0x19e>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801b76:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801b7c:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801b82:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801b89:	81 fe 00 10 40 00    	cmp    $0x401000,%esi
  801b8f:	74 24                	je     801bb5 <spawn+0x215>
  801b91:	c7 44 24 0c 4c 29 80 	movl   $0x80294c,0xc(%esp)
  801b98:	00 
  801b99:	c7 44 24 08 db 28 80 	movl   $0x8028db,0x8(%esp)
  801ba0:	00 
  801ba1:	c7 44 24 04 ec 00 00 	movl   $0xec,0x4(%esp)
  801ba8:	00 
  801ba9:	c7 04 24 f0 28 80 00 	movl   $0x8028f0,(%esp)
  801bb0:	e8 13 e6 ff ff       	call   8001c8 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801bb5:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801bbb:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801bc0:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801bc6:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  801bc9:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801bcf:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801bd2:	89 d0                	mov    %edx,%eax
  801bd4:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801bd9:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801bdf:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801be6:	00 
  801be7:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  801bee:	ee 
  801bef:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801bf5:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bf9:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801c00:	00 
  801c01:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c08:	e8 e4 f2 ff ff       	call   800ef1 <sys_page_map>
  801c0d:	89 c7                	mov    %eax,%edi
  801c0f:	85 c0                	test   %eax,%eax
  801c11:	0f 88 ed 02 00 00    	js     801f04 <spawn+0x564>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801c17:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801c1e:	00 
  801c1f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c26:	e8 2d f3 ff ff       	call   800f58 <sys_page_unmap>
  801c2b:	89 c7                	mov    %eax,%edi
  801c2d:	85 c0                	test   %eax,%eax
  801c2f:	0f 88 cf 02 00 00    	js     801f04 <spawn+0x564>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801c35:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801c3b:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801c42:	89 85 80 fd ff ff    	mov    %eax,-0x280(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801c48:	66 83 bd 14 fe ff ff 	cmpw   $0x0,-0x1ec(%ebp)
  801c4f:	00 
  801c50:	0f 84 e3 01 00 00    	je     801e39 <spawn+0x499>
  801c56:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  801c5d:	00 00 00 
		if (ph->p_type != ELF_PROG_LOAD)
  801c60:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  801c66:	83 3a 01             	cmpl   $0x1,(%edx)
  801c69:	0f 85 a9 01 00 00    	jne    801e18 <spawn+0x478>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801c6f:	8b 42 18             	mov    0x18(%edx),%eax
  801c72:	89 85 70 fd ff ff    	mov    %eax,-0x290(%ebp)
  801c78:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  801c7b:	83 f8 01             	cmp    $0x1,%eax
  801c7e:	19 d2                	sbb    %edx,%edx
  801c80:	83 e2 fe             	and    $0xfffffffe,%edx
  801c83:	83 c2 07             	add    $0x7,%edx
  801c86:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801c8c:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801c92:	8b 40 04             	mov    0x4(%eax),%eax
  801c95:	89 85 78 fd ff ff    	mov    %eax,-0x288(%ebp)
  801c9b:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  801ca1:	8b 7a 10             	mov    0x10(%edx),%edi
  801ca4:	8b 42 14             	mov    0x14(%edx),%eax
  801ca7:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801cad:	8b 52 08             	mov    0x8(%edx),%edx
  801cb0:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801cb6:	89 d0                	mov    %edx,%eax
  801cb8:	25 ff 0f 00 00       	and    $0xfff,%eax
  801cbd:	74 16                	je     801cd5 <spawn+0x335>
		va -= i;
  801cbf:	29 c2                	sub    %eax,%edx
  801cc1:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		memsz += i;
  801cc7:	01 85 8c fd ff ff    	add    %eax,-0x274(%ebp)
		filesz += i;
  801ccd:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801ccf:	29 85 78 fd ff ff    	sub    %eax,-0x288(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801cd5:	83 bd 8c fd ff ff 00 	cmpl   $0x0,-0x274(%ebp)
  801cdc:	0f 84 36 01 00 00    	je     801e18 <spawn+0x478>
  801ce2:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ce7:	be 00 00 00 00       	mov    $0x0,%esi
		if (i >= filesz) {
  801cec:	39 f7                	cmp    %esi,%edi
  801cee:	77 31                	ja     801d21 <spawn+0x381>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801cf0:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801cf6:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cfa:	03 b5 90 fd ff ff    	add    -0x270(%ebp),%esi
  801d00:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d04:	8b 95 84 fd ff ff    	mov    -0x27c(%ebp),%edx
  801d0a:	89 14 24             	mov    %edx,(%esp)
  801d0d:	e8 77 f1 ff ff       	call   800e89 <sys_page_alloc>
  801d12:	85 c0                	test   %eax,%eax
  801d14:	0f 89 ea 00 00 00    	jns    801e04 <spawn+0x464>
  801d1a:	89 c7                	mov    %eax,%edi
  801d1c:	e9 c5 01 00 00       	jmp    801ee6 <spawn+0x546>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801d21:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801d28:	00 
  801d29:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801d30:	00 
  801d31:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d38:	e8 4c f1 ff ff       	call   800e89 <sys_page_alloc>
  801d3d:	85 c0                	test   %eax,%eax
  801d3f:	0f 88 97 01 00 00    	js     801edc <spawn+0x53c>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801d45:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  801d4b:	01 d8                	add    %ebx,%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801d4d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d51:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801d57:	89 04 24             	mov    %eax,(%esp)
  801d5a:	e8 f8 f8 ff ff       	call   801657 <seek>
  801d5f:	85 c0                	test   %eax,%eax
  801d61:	0f 88 79 01 00 00    	js     801ee0 <spawn+0x540>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801d67:	89 f8                	mov    %edi,%eax
  801d69:	29 f0                	sub    %esi,%eax
  801d6b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801d70:	ba 00 10 00 00       	mov    $0x1000,%edx
  801d75:	0f 47 c2             	cmova  %edx,%eax
  801d78:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d7c:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801d83:	00 
  801d84:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801d8a:	89 04 24             	mov    %eax,(%esp)
  801d8d:	e8 e3 f7 ff ff       	call   801575 <readn>
  801d92:	85 c0                	test   %eax,%eax
  801d94:	0f 88 4a 01 00 00    	js     801ee4 <spawn+0x544>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801d9a:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801da0:	89 54 24 10          	mov    %edx,0x10(%esp)
  801da4:	03 b5 90 fd ff ff    	add    -0x270(%ebp),%esi
  801daa:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801dae:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801db4:	89 44 24 08          	mov    %eax,0x8(%esp)
  801db8:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801dbf:	00 
  801dc0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dc7:	e8 25 f1 ff ff       	call   800ef1 <sys_page_map>
  801dcc:	85 c0                	test   %eax,%eax
  801dce:	79 20                	jns    801df0 <spawn+0x450>
				panic("spawn: sys_page_map data: %e", r);
  801dd0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801dd4:	c7 44 24 08 fc 28 80 	movl   $0x8028fc,0x8(%esp)
  801ddb:	00 
  801ddc:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
  801de3:	00 
  801de4:	c7 04 24 f0 28 80 00 	movl   $0x8028f0,(%esp)
  801deb:	e8 d8 e3 ff ff       	call   8001c8 <_panic>
			sys_page_unmap(0, UTEMP);
  801df0:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801df7:	00 
  801df8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dff:	e8 54 f1 ff ff       	call   800f58 <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801e04:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801e0a:	89 de                	mov    %ebx,%esi
  801e0c:	3b 9d 8c fd ff ff    	cmp    -0x274(%ebp),%ebx
  801e12:	0f 82 d4 fe ff ff    	jb     801cec <spawn+0x34c>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801e18:	83 85 7c fd ff ff 01 	addl   $0x1,-0x284(%ebp)
  801e1f:	83 85 80 fd ff ff 20 	addl   $0x20,-0x280(%ebp)
  801e26:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801e2d:	3b 85 7c fd ff ff    	cmp    -0x284(%ebp),%eax
  801e33:	0f 8f 27 fe ff ff    	jg     801c60 <spawn+0x2c0>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801e39:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801e3f:	89 04 24             	mov    %eax,(%esp)
  801e42:	e8 2b f5 ff ff       	call   801372 <close>
	fd = -1;

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801e47:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801e4d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e51:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801e57:	89 04 24             	mov    %eax,(%esp)
  801e5a:	e8 c7 f1 ff ff       	call   801026 <sys_env_set_trapframe>
  801e5f:	85 c0                	test   %eax,%eax
  801e61:	79 20                	jns    801e83 <spawn+0x4e3>
		panic("sys_env_set_trapframe: %e", r);
  801e63:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e67:	c7 44 24 08 19 29 80 	movl   $0x802919,0x8(%esp)
  801e6e:	00 
  801e6f:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  801e76:	00 
  801e77:	c7 04 24 f0 28 80 00 	movl   $0x8028f0,(%esp)
  801e7e:	e8 45 e3 ff ff       	call   8001c8 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801e83:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801e8a:	00 
  801e8b:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801e91:	89 04 24             	mov    %eax,(%esp)
  801e94:	e8 26 f1 ff ff       	call   800fbf <sys_env_set_status>
  801e99:	85 c0                	test   %eax,%eax
  801e9b:	79 30                	jns    801ecd <spawn+0x52d>
		panic("sys_env_set_status: %e", r);
  801e9d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ea1:	c7 44 24 08 33 29 80 	movl   $0x802933,0x8(%esp)
  801ea8:	00 
  801ea9:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
  801eb0:	00 
  801eb1:	c7 04 24 f0 28 80 00 	movl   $0x8028f0,(%esp)
  801eb8:	e8 0b e3 ff ff       	call   8001c8 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801ebd:	8b bd 88 fd ff ff    	mov    -0x278(%ebp),%edi
  801ec3:	eb 53                	jmp    801f18 <spawn+0x578>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801ec5:	8b bd 74 fd ff ff    	mov    -0x28c(%ebp),%edi
  801ecb:	eb 4b                	jmp    801f18 <spawn+0x578>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801ecd:	8b bd 74 fd ff ff    	mov    -0x28c(%ebp),%edi
  801ed3:	eb 43                	jmp    801f18 <spawn+0x578>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801ed5:	bf fc ff ff ff       	mov    $0xfffffffc,%edi
  801eda:	eb 3c                	jmp    801f18 <spawn+0x578>
  801edc:	89 c7                	mov    %eax,%edi
  801ede:	eb 06                	jmp    801ee6 <spawn+0x546>
  801ee0:	89 c7                	mov    %eax,%edi
  801ee2:	eb 02                	jmp    801ee6 <spawn+0x546>
  801ee4:	89 c7                	mov    %eax,%edi
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801ee6:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801eec:	89 04 24             	mov    %eax,(%esp)
  801eef:	e8 bd ee ff ff       	call   800db1 <sys_env_destroy>
	close(fd);
  801ef4:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801efa:	89 04 24             	mov    %eax,(%esp)
  801efd:	e8 70 f4 ff ff       	call   801372 <close>
  801f02:	eb 14                	jmp    801f18 <spawn+0x578>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801f04:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801f0b:	00 
  801f0c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f13:	e8 40 f0 ff ff       	call   800f58 <sys_page_unmap>

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801f18:	89 f8                	mov    %edi,%eax
  801f1a:	81 c4 ac 02 00 00    	add    $0x2ac,%esp
  801f20:	5b                   	pop    %ebx
  801f21:	5e                   	pop    %esi
  801f22:	5f                   	pop    %edi
  801f23:	5d                   	pop    %ebp
  801f24:	c3                   	ret    

00801f25 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801f25:	55                   	push   %ebp
  801f26:	89 e5                	mov    %esp,%ebp
  801f28:	56                   	push   %esi
  801f29:	53                   	push   %ebx
  801f2a:	83 ec 20             	sub    $0x20,%esp
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801f2d:	8d 45 14             	lea    0x14(%ebp),%eax
  801f30:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f34:	74 69                	je     801f9f <spawnl+0x7a>
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801f36:	ba 00 00 00 00       	mov    $0x0,%edx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
		argc++;
  801f3b:	83 c2 01             	add    $0x1,%edx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801f3e:	83 c0 04             	add    $0x4,%eax
  801f41:	83 78 fc 00          	cmpl   $0x0,-0x4(%eax)
  801f45:	75 f4                	jne    801f3b <spawnl+0x16>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801f47:	8d 04 95 1a 00 00 00 	lea    0x1a(,%edx,4),%eax
  801f4e:	83 e0 f0             	and    $0xfffffff0,%eax
  801f51:	29 c4                	sub    %eax,%esp
  801f53:	8d 5c 24 0b          	lea    0xb(%esp),%ebx
  801f57:	c1 eb 02             	shr    $0x2,%ebx
  801f5a:	8d 04 9d 00 00 00 00 	lea    0x0(,%ebx,4),%eax
  801f61:	89 c1                	mov    %eax,%ecx
	argv[0] = arg0;
  801f63:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f66:	89 34 9d 00 00 00 00 	mov    %esi,0x0(,%ebx,4)
	argv[argc+1] = NULL;
  801f6d:	c7 44 90 04 00 00 00 	movl   $0x0,0x4(%eax,%edx,4)
  801f74:	00 

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801f75:	89 d3                	mov    %edx,%ebx
  801f77:	85 d2                	test   %edx,%edx
  801f79:	74 13                	je     801f8e <spawnl+0x69>
  801f7b:	b8 00 00 00 00       	mov    $0x0,%eax
		argv[i+1] = va_arg(vl, const char *);
  801f80:	83 c0 01             	add    $0x1,%eax
  801f83:	8b 54 85 0c          	mov    0xc(%ebp,%eax,4),%edx
  801f87:	89 14 81             	mov    %edx,(%ecx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801f8a:	39 d8                	cmp    %ebx,%eax
  801f8c:	75 f2                	jne    801f80 <spawnl+0x5b>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801f8e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801f92:	8b 45 08             	mov    0x8(%ebp),%eax
  801f95:	89 04 24             	mov    %eax,(%esp)
  801f98:	e8 03 fa ff ff       	call   8019a0 <spawn>
  801f9d:	eb 12                	jmp    801fb1 <spawnl+0x8c>
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
	argv[0] = arg0;
  801f9f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fa2:	89 45 f0             	mov    %eax,-0x10(%ebp)
	argv[argc+1] = NULL;
  801fa5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801fac:	8d 4d f0             	lea    -0x10(%ebp),%ecx
  801faf:	eb dd                	jmp    801f8e <spawnl+0x69>
	unsigned i;
	for(i=0;i<argc;i++)
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
}
  801fb1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fb4:	5b                   	pop    %ebx
  801fb5:	5e                   	pop    %esi
  801fb6:	5d                   	pop    %ebp
  801fb7:	c3                   	ret    

00801fb8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fb8:	55                   	push   %ebp
  801fb9:	89 e5                	mov    %esp,%ebp
  801fbb:	56                   	push   %esi
  801fbc:	53                   	push   %ebx
  801fbd:	83 ec 10             	sub    $0x10,%esp
  801fc0:	8b 75 08             	mov    0x8(%ebp),%esi
  801fc3:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	// 	return thisenv->env_ipc_value;
	// }
	int r;
	if(pg == NULL)
		pg = (void *)~0x0;
  801fc6:	85 db                	test   %ebx,%ebx
  801fc8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801fcd:	0f 44 d8             	cmove  %eax,%ebx
	//else
	if((r = sys_ipc_recv(pg)) < 0)
  801fd0:	89 1c 24             	mov    %ebx,(%esp)
  801fd3:	e8 59 f1 ff ff       	call   801131 <sys_ipc_recv>
  801fd8:	85 c0                	test   %eax,%eax
  801fda:	78 2d                	js     802009 <ipc_recv+0x51>
		return r;
	//volatile struct Env *curenv = (struct Env*)envs+ENVX(sys_getenvid());

	if(from_env_store)
  801fdc:	85 f6                	test   %esi,%esi
  801fde:	74 0a                	je     801fea <ipc_recv+0x32>
		*from_env_store = thisenv -> env_ipc_from;
  801fe0:	a1 04 40 80 00       	mov    0x804004,%eax
  801fe5:	8b 40 74             	mov    0x74(%eax),%eax
  801fe8:	89 06                	mov    %eax,(%esi)
	if(pg && perm_store)
  801fea:	85 db                	test   %ebx,%ebx
  801fec:	74 13                	je     802001 <ipc_recv+0x49>
  801fee:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ff2:	74 0d                	je     802001 <ipc_recv+0x49>
		*perm_store = thisenv -> env_ipc_perm;
  801ff4:	a1 04 40 80 00       	mov    0x804004,%eax
  801ff9:	8b 40 78             	mov    0x78(%eax),%eax
  801ffc:	8b 55 10             	mov    0x10(%ebp),%edx
  801fff:	89 02                	mov    %eax,(%edx)
	else if(perm_store)
		perm_store = (int *)0;
	return thisenv->env_ipc_value;
  802001:	a1 04 40 80 00       	mov    0x804004,%eax
  802006:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  802009:	83 c4 10             	add    $0x10,%esp
  80200c:	5b                   	pop    %ebx
  80200d:	5e                   	pop    %esi
  80200e:	5d                   	pop    %ebp
  80200f:	c3                   	ret    

00802010 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802010:	55                   	push   %ebp
  802011:	89 e5                	mov    %esp,%ebp
  802013:	57                   	push   %edi
  802014:	56                   	push   %esi
  802015:	53                   	push   %ebx
  802016:	83 ec 1c             	sub    $0x1c,%esp
  802019:	8b 7d 08             	mov    0x8(%ebp),%edi
  80201c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80201f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

	if(pg == NULL)
  802022:	85 db                	test   %ebx,%ebx
		pg = (void *)~0x0;
  802024:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  802029:	0f 44 d8             	cmove  %eax,%ebx
  80202c:	eb 2a                	jmp    802058 <ipc_send+0x48>
	while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0){
		if(r != -E_IPC_NOT_RECV)
  80202e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802031:	74 20                	je     802053 <ipc_send+0x43>
            panic("Send message error %e\n",r);
  802033:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802037:	c7 44 24 08 74 29 80 	movl   $0x802974,0x8(%esp)
  80203e:	00 
  80203f:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  802046:	00 
  802047:	c7 04 24 8b 29 80 00 	movl   $0x80298b,(%esp)
  80204e:	e8 75 e1 ff ff       	call   8001c8 <_panic>
		sys_yield();
  802053:	e8 f8 ed ff ff       	call   800e50 <sys_yield>
	// LAB 4: Your code here.
	int r;

	if(pg == NULL)
		pg = (void *)~0x0;
	while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0){
  802058:	8b 45 14             	mov    0x14(%ebp),%eax
  80205b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80205f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802063:	89 74 24 04          	mov    %esi,0x4(%esp)
  802067:	89 3c 24             	mov    %edi,(%esp)
  80206a:	e8 85 f0 ff ff       	call   8010f4 <sys_ipc_try_send>
  80206f:	85 c0                	test   %eax,%eax
  802071:	78 bb                	js     80202e <ipc_send+0x1e>
            panic("Send message error %e\n",r);
		sys_yield();
	}

	//panic("ipc_send not implemented");
}
  802073:	83 c4 1c             	add    $0x1c,%esp
  802076:	5b                   	pop    %ebx
  802077:	5e                   	pop    %esi
  802078:	5f                   	pop    %edi
  802079:	5d                   	pop    %ebp
  80207a:	c3                   	ret    

0080207b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80207b:	55                   	push   %ebp
  80207c:	89 e5                	mov    %esp,%ebp
  80207e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802081:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  802086:	39 c8                	cmp    %ecx,%eax
  802088:	74 17                	je     8020a1 <ipc_find_env+0x26>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80208a:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  80208f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802092:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802098:	8b 52 50             	mov    0x50(%edx),%edx
  80209b:	39 ca                	cmp    %ecx,%edx
  80209d:	75 14                	jne    8020b3 <ipc_find_env+0x38>
  80209f:	eb 05                	jmp    8020a6 <ipc_find_env+0x2b>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8020a1:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  8020a6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020a9:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8020ae:	8b 40 40             	mov    0x40(%eax),%eax
  8020b1:	eb 0e                	jmp    8020c1 <ipc_find_env+0x46>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8020b3:	83 c0 01             	add    $0x1,%eax
  8020b6:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020bb:	75 d2                	jne    80208f <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8020bd:	66 b8 00 00          	mov    $0x0,%ax
}
  8020c1:	5d                   	pop    %ebp
  8020c2:	c3                   	ret    
  8020c3:	66 90                	xchg   %ax,%ax
  8020c5:	66 90                	xchg   %ax,%ax
  8020c7:	66 90                	xchg   %ax,%ax
  8020c9:	66 90                	xchg   %ax,%ax
  8020cb:	66 90                	xchg   %ax,%ax
  8020cd:	66 90                	xchg   %ax,%ax
  8020cf:	90                   	nop

008020d0 <__udivdi3>:
  8020d0:	83 ec 1c             	sub    $0x1c,%esp
  8020d3:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  8020d7:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8020db:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8020df:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8020e3:	8b 7c 24 20          	mov    0x20(%esp),%edi
  8020e7:	8b 6c 24 24          	mov    0x24(%esp),%ebp
  8020eb:	85 c0                	test   %eax,%eax
  8020ed:	89 74 24 10          	mov    %esi,0x10(%esp)
  8020f1:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8020f5:	89 ea                	mov    %ebp,%edx
  8020f7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8020fb:	75 33                	jne    802130 <__udivdi3+0x60>
  8020fd:	39 e9                	cmp    %ebp,%ecx
  8020ff:	77 6f                	ja     802170 <__udivdi3+0xa0>
  802101:	85 c9                	test   %ecx,%ecx
  802103:	89 ce                	mov    %ecx,%esi
  802105:	75 0b                	jne    802112 <__udivdi3+0x42>
  802107:	b8 01 00 00 00       	mov    $0x1,%eax
  80210c:	31 d2                	xor    %edx,%edx
  80210e:	f7 f1                	div    %ecx
  802110:	89 c6                	mov    %eax,%esi
  802112:	31 d2                	xor    %edx,%edx
  802114:	89 e8                	mov    %ebp,%eax
  802116:	f7 f6                	div    %esi
  802118:	89 c5                	mov    %eax,%ebp
  80211a:	89 f8                	mov    %edi,%eax
  80211c:	f7 f6                	div    %esi
  80211e:	89 ea                	mov    %ebp,%edx
  802120:	8b 74 24 10          	mov    0x10(%esp),%esi
  802124:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802128:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80212c:	83 c4 1c             	add    $0x1c,%esp
  80212f:	c3                   	ret    
  802130:	39 e8                	cmp    %ebp,%eax
  802132:	77 24                	ja     802158 <__udivdi3+0x88>
  802134:	0f bd c8             	bsr    %eax,%ecx
  802137:	83 f1 1f             	xor    $0x1f,%ecx
  80213a:	89 0c 24             	mov    %ecx,(%esp)
  80213d:	75 49                	jne    802188 <__udivdi3+0xb8>
  80213f:	8b 74 24 08          	mov    0x8(%esp),%esi
  802143:	39 74 24 04          	cmp    %esi,0x4(%esp)
  802147:	0f 86 ab 00 00 00    	jbe    8021f8 <__udivdi3+0x128>
  80214d:	39 e8                	cmp    %ebp,%eax
  80214f:	0f 82 a3 00 00 00    	jb     8021f8 <__udivdi3+0x128>
  802155:	8d 76 00             	lea    0x0(%esi),%esi
  802158:	31 d2                	xor    %edx,%edx
  80215a:	31 c0                	xor    %eax,%eax
  80215c:	8b 74 24 10          	mov    0x10(%esp),%esi
  802160:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802164:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802168:	83 c4 1c             	add    $0x1c,%esp
  80216b:	c3                   	ret    
  80216c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802170:	89 f8                	mov    %edi,%eax
  802172:	f7 f1                	div    %ecx
  802174:	31 d2                	xor    %edx,%edx
  802176:	8b 74 24 10          	mov    0x10(%esp),%esi
  80217a:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80217e:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802182:	83 c4 1c             	add    $0x1c,%esp
  802185:	c3                   	ret    
  802186:	66 90                	xchg   %ax,%ax
  802188:	0f b6 0c 24          	movzbl (%esp),%ecx
  80218c:	89 c6                	mov    %eax,%esi
  80218e:	b8 20 00 00 00       	mov    $0x20,%eax
  802193:	8b 6c 24 04          	mov    0x4(%esp),%ebp
  802197:	2b 04 24             	sub    (%esp),%eax
  80219a:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80219e:	d3 e6                	shl    %cl,%esi
  8021a0:	89 c1                	mov    %eax,%ecx
  8021a2:	d3 ed                	shr    %cl,%ebp
  8021a4:	0f b6 0c 24          	movzbl (%esp),%ecx
  8021a8:	09 f5                	or     %esi,%ebp
  8021aa:	8b 74 24 04          	mov    0x4(%esp),%esi
  8021ae:	d3 e6                	shl    %cl,%esi
  8021b0:	89 c1                	mov    %eax,%ecx
  8021b2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021b6:	89 d6                	mov    %edx,%esi
  8021b8:	d3 ee                	shr    %cl,%esi
  8021ba:	0f b6 0c 24          	movzbl (%esp),%ecx
  8021be:	d3 e2                	shl    %cl,%edx
  8021c0:	89 c1                	mov    %eax,%ecx
  8021c2:	d3 ef                	shr    %cl,%edi
  8021c4:	09 d7                	or     %edx,%edi
  8021c6:	89 f2                	mov    %esi,%edx
  8021c8:	89 f8                	mov    %edi,%eax
  8021ca:	f7 f5                	div    %ebp
  8021cc:	89 d6                	mov    %edx,%esi
  8021ce:	89 c7                	mov    %eax,%edi
  8021d0:	f7 64 24 04          	mull   0x4(%esp)
  8021d4:	39 d6                	cmp    %edx,%esi
  8021d6:	72 30                	jb     802208 <__udivdi3+0x138>
  8021d8:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  8021dc:	0f b6 0c 24          	movzbl (%esp),%ecx
  8021e0:	d3 e5                	shl    %cl,%ebp
  8021e2:	39 c5                	cmp    %eax,%ebp
  8021e4:	73 04                	jae    8021ea <__udivdi3+0x11a>
  8021e6:	39 d6                	cmp    %edx,%esi
  8021e8:	74 1e                	je     802208 <__udivdi3+0x138>
  8021ea:	89 f8                	mov    %edi,%eax
  8021ec:	31 d2                	xor    %edx,%edx
  8021ee:	e9 69 ff ff ff       	jmp    80215c <__udivdi3+0x8c>
  8021f3:	90                   	nop
  8021f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021f8:	31 d2                	xor    %edx,%edx
  8021fa:	b8 01 00 00 00       	mov    $0x1,%eax
  8021ff:	e9 58 ff ff ff       	jmp    80215c <__udivdi3+0x8c>
  802204:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802208:	8d 47 ff             	lea    -0x1(%edi),%eax
  80220b:	31 d2                	xor    %edx,%edx
  80220d:	8b 74 24 10          	mov    0x10(%esp),%esi
  802211:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802215:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802219:	83 c4 1c             	add    $0x1c,%esp
  80221c:	c3                   	ret    
  80221d:	66 90                	xchg   %ax,%ax
  80221f:	90                   	nop

00802220 <__umoddi3>:
  802220:	83 ec 2c             	sub    $0x2c,%esp
  802223:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  802227:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80222b:	89 74 24 20          	mov    %esi,0x20(%esp)
  80222f:	8b 74 24 38          	mov    0x38(%esp),%esi
  802233:	89 7c 24 24          	mov    %edi,0x24(%esp)
  802237:	8b 7c 24 34          	mov    0x34(%esp),%edi
  80223b:	85 c0                	test   %eax,%eax
  80223d:	89 c2                	mov    %eax,%edx
  80223f:	89 6c 24 28          	mov    %ebp,0x28(%esp)
  802243:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  802247:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80224b:	89 74 24 10          	mov    %esi,0x10(%esp)
  80224f:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  802253:	89 7c 24 18          	mov    %edi,0x18(%esp)
  802257:	75 1f                	jne    802278 <__umoddi3+0x58>
  802259:	39 fe                	cmp    %edi,%esi
  80225b:	76 63                	jbe    8022c0 <__umoddi3+0xa0>
  80225d:	89 c8                	mov    %ecx,%eax
  80225f:	89 fa                	mov    %edi,%edx
  802261:	f7 f6                	div    %esi
  802263:	89 d0                	mov    %edx,%eax
  802265:	31 d2                	xor    %edx,%edx
  802267:	8b 74 24 20          	mov    0x20(%esp),%esi
  80226b:	8b 7c 24 24          	mov    0x24(%esp),%edi
  80226f:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  802273:	83 c4 2c             	add    $0x2c,%esp
  802276:	c3                   	ret    
  802277:	90                   	nop
  802278:	39 f8                	cmp    %edi,%eax
  80227a:	77 64                	ja     8022e0 <__umoddi3+0xc0>
  80227c:	0f bd e8             	bsr    %eax,%ebp
  80227f:	83 f5 1f             	xor    $0x1f,%ebp
  802282:	75 74                	jne    8022f8 <__umoddi3+0xd8>
  802284:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802288:	39 7c 24 10          	cmp    %edi,0x10(%esp)
  80228c:	0f 87 0e 01 00 00    	ja     8023a0 <__umoddi3+0x180>
  802292:	8b 7c 24 0c          	mov    0xc(%esp),%edi
  802296:	29 f1                	sub    %esi,%ecx
  802298:	19 c7                	sbb    %eax,%edi
  80229a:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80229e:	89 7c 24 18          	mov    %edi,0x18(%esp)
  8022a2:	8b 44 24 14          	mov    0x14(%esp),%eax
  8022a6:	8b 54 24 18          	mov    0x18(%esp),%edx
  8022aa:	8b 74 24 20          	mov    0x20(%esp),%esi
  8022ae:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8022b2:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  8022b6:	83 c4 2c             	add    $0x2c,%esp
  8022b9:	c3                   	ret    
  8022ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022c0:	85 f6                	test   %esi,%esi
  8022c2:	89 f5                	mov    %esi,%ebp
  8022c4:	75 0b                	jne    8022d1 <__umoddi3+0xb1>
  8022c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022cb:	31 d2                	xor    %edx,%edx
  8022cd:	f7 f6                	div    %esi
  8022cf:	89 c5                	mov    %eax,%ebp
  8022d1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8022d5:	31 d2                	xor    %edx,%edx
  8022d7:	f7 f5                	div    %ebp
  8022d9:	89 c8                	mov    %ecx,%eax
  8022db:	f7 f5                	div    %ebp
  8022dd:	eb 84                	jmp    802263 <__umoddi3+0x43>
  8022df:	90                   	nop
  8022e0:	89 c8                	mov    %ecx,%eax
  8022e2:	89 fa                	mov    %edi,%edx
  8022e4:	8b 74 24 20          	mov    0x20(%esp),%esi
  8022e8:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8022ec:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  8022f0:	83 c4 2c             	add    $0x2c,%esp
  8022f3:	c3                   	ret    
  8022f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022f8:	8b 44 24 10          	mov    0x10(%esp),%eax
  8022fc:	be 20 00 00 00       	mov    $0x20,%esi
  802301:	89 e9                	mov    %ebp,%ecx
  802303:	29 ee                	sub    %ebp,%esi
  802305:	d3 e2                	shl    %cl,%edx
  802307:	89 f1                	mov    %esi,%ecx
  802309:	d3 e8                	shr    %cl,%eax
  80230b:	89 e9                	mov    %ebp,%ecx
  80230d:	09 d0                	or     %edx,%eax
  80230f:	89 fa                	mov    %edi,%edx
  802311:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802315:	8b 44 24 10          	mov    0x10(%esp),%eax
  802319:	d3 e0                	shl    %cl,%eax
  80231b:	89 f1                	mov    %esi,%ecx
  80231d:	89 44 24 10          	mov    %eax,0x10(%esp)
  802321:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802325:	d3 ea                	shr    %cl,%edx
  802327:	89 e9                	mov    %ebp,%ecx
  802329:	d3 e7                	shl    %cl,%edi
  80232b:	89 f1                	mov    %esi,%ecx
  80232d:	d3 e8                	shr    %cl,%eax
  80232f:	89 e9                	mov    %ebp,%ecx
  802331:	09 f8                	or     %edi,%eax
  802333:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  802337:	f7 74 24 0c          	divl   0xc(%esp)
  80233b:	d3 e7                	shl    %cl,%edi
  80233d:	89 7c 24 18          	mov    %edi,0x18(%esp)
  802341:	89 d7                	mov    %edx,%edi
  802343:	f7 64 24 10          	mull   0x10(%esp)
  802347:	39 d7                	cmp    %edx,%edi
  802349:	89 c1                	mov    %eax,%ecx
  80234b:	89 54 24 14          	mov    %edx,0x14(%esp)
  80234f:	72 3b                	jb     80238c <__umoddi3+0x16c>
  802351:	39 44 24 18          	cmp    %eax,0x18(%esp)
  802355:	72 31                	jb     802388 <__umoddi3+0x168>
  802357:	8b 44 24 18          	mov    0x18(%esp),%eax
  80235b:	29 c8                	sub    %ecx,%eax
  80235d:	19 d7                	sbb    %edx,%edi
  80235f:	89 e9                	mov    %ebp,%ecx
  802361:	89 fa                	mov    %edi,%edx
  802363:	d3 e8                	shr    %cl,%eax
  802365:	89 f1                	mov    %esi,%ecx
  802367:	d3 e2                	shl    %cl,%edx
  802369:	89 e9                	mov    %ebp,%ecx
  80236b:	09 d0                	or     %edx,%eax
  80236d:	89 fa                	mov    %edi,%edx
  80236f:	d3 ea                	shr    %cl,%edx
  802371:	8b 74 24 20          	mov    0x20(%esp),%esi
  802375:	8b 7c 24 24          	mov    0x24(%esp),%edi
  802379:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  80237d:	83 c4 2c             	add    $0x2c,%esp
  802380:	c3                   	ret    
  802381:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802388:	39 d7                	cmp    %edx,%edi
  80238a:	75 cb                	jne    802357 <__umoddi3+0x137>
  80238c:	8b 54 24 14          	mov    0x14(%esp),%edx
  802390:	89 c1                	mov    %eax,%ecx
  802392:	2b 4c 24 10          	sub    0x10(%esp),%ecx
  802396:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  80239a:	eb bb                	jmp    802357 <__umoddi3+0x137>
  80239c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023a0:	3b 44 24 18          	cmp    0x18(%esp),%eax
  8023a4:	0f 82 e8 fe ff ff    	jb     802292 <__umoddi3+0x72>
  8023aa:	e9 f3 fe ff ff       	jmp    8022a2 <__umoddi3+0x82>
