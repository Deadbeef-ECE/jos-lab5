
obj/user/primes.debug:     file format elf32-i386


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
  80002c:	e8 1f 01 00 00       	call   800150 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	90                   	nop

00800034 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003d:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800040:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800047:	00 
  800048:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80004f:	00 
  800050:	89 34 24             	mov    %esi,(%esp)
  800053:	e8 80 13 00 00       	call   8013d8 <ipc_recv>
  800058:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80005a:	a1 04 40 80 00       	mov    0x804004,%eax
  80005f:	8b 40 5c             	mov    0x5c(%eax),%eax
  800062:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800066:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006a:	c7 04 24 80 20 80 00 	movl   $0x802080,(%esp)
  800071:	e8 41 02 00 00       	call   8002b7 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800076:	e8 c5 11 00 00       	call   801240 <fork>
  80007b:	89 c7                	mov    %eax,%edi
  80007d:	85 c0                	test   %eax,%eax
  80007f:	79 20                	jns    8000a1 <primeproc+0x6d>
		panic("fork: %e", id);
  800081:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800085:	c7 44 24 08 8c 20 80 	movl   $0x80208c,0x8(%esp)
  80008c:	00 
  80008d:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800094:	00 
  800095:	c7 04 24 95 20 80 00 	movl   $0x802095,(%esp)
  80009c:	e8 1b 01 00 00       	call   8001bc <_panic>
	if (id == 0)
  8000a1:	85 c0                	test   %eax,%eax
  8000a3:	74 9b                	je     800040 <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  8000a5:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  8000a8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000af:	00 
  8000b0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b7:	00 
  8000b8:	89 34 24             	mov    %esi,(%esp)
  8000bb:	e8 18 13 00 00       	call   8013d8 <ipc_recv>
  8000c0:	89 c1                	mov    %eax,%ecx
		if (i % p)
  8000c2:	89 c2                	mov    %eax,%edx
  8000c4:	c1 fa 1f             	sar    $0x1f,%edx
  8000c7:	f7 fb                	idiv   %ebx
  8000c9:	85 d2                	test   %edx,%edx
  8000cb:	74 db                	je     8000a8 <primeproc+0x74>
			ipc_send(id, i, 0, 0);
  8000cd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000d4:	00 
  8000d5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000dc:	00 
  8000dd:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8000e1:	89 3c 24             	mov    %edi,(%esp)
  8000e4:	e8 47 13 00 00       	call   801430 <ipc_send>
  8000e9:	eb bd                	jmp    8000a8 <primeproc+0x74>

008000eb <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	56                   	push   %esi
  8000ef:	53                   	push   %ebx
  8000f0:	83 ec 10             	sub    $0x10,%esp
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000f3:	e8 48 11 00 00       	call   801240 <fork>
  8000f8:	89 c6                	mov    %eax,%esi
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	79 20                	jns    80011e <umain+0x33>
		panic("fork: %e", id);
  8000fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800102:	c7 44 24 08 8c 20 80 	movl   $0x80208c,0x8(%esp)
  800109:	00 
  80010a:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  800111:	00 
  800112:	c7 04 24 95 20 80 00 	movl   $0x802095,(%esp)
  800119:	e8 9e 00 00 00       	call   8001bc <_panic>
	if (id == 0)
  80011e:	bb 02 00 00 00       	mov    $0x2,%ebx
  800123:	85 c0                	test   %eax,%eax
  800125:	75 05                	jne    80012c <umain+0x41>
		primeproc();
  800127:	e8 08 ff ff ff       	call   800034 <primeproc>

	// feed all the integers through
	for (i = 2; ; i++)
		ipc_send(id, i, 0, 0);
  80012c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800133:	00 
  800134:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80013b:	00 
  80013c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800140:	89 34 24             	mov    %esi,(%esp)
  800143:	e8 e8 12 00 00       	call   801430 <ipc_send>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  800148:	83 c3 01             	add    $0x1,%ebx
  80014b:	eb df                	jmp    80012c <umain+0x41>
  80014d:	66 90                	xchg   %ax,%ax
  80014f:	90                   	nop

00800150 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	83 ec 18             	sub    $0x18,%esp
  800156:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800159:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80015c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80015f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;

	thisenv = &envs[ENVX(sys_getenvid())];
  800162:	e8 b0 0c 00 00       	call   800e17 <sys_getenvid>
  800167:	25 ff 03 00 00       	and    $0x3ff,%eax
  80016c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80016f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800174:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800179:	85 db                	test   %ebx,%ebx
  80017b:	7e 07                	jle    800184 <libmain+0x34>
		binaryname = argv[0];
  80017d:	8b 06                	mov    (%esi),%eax
  80017f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800184:	89 74 24 04          	mov    %esi,0x4(%esp)
  800188:	89 1c 24             	mov    %ebx,(%esp)
  80018b:	e8 5b ff ff ff       	call   8000eb <umain>

	// exit gracefully
	exit();
  800190:	e8 0b 00 00 00       	call   8001a0 <exit>
}
  800195:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800198:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80019b:	89 ec                	mov    %ebp,%esp
  80019d:	5d                   	pop    %ebp
  80019e:	c3                   	ret    
  80019f:	90                   	nop

008001a0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8001a6:	e8 48 15 00 00       	call   8016f3 <close_all>
	sys_env_destroy(0);
  8001ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001b2:	e8 fa 0b 00 00       	call   800db1 <sys_env_destroy>
}
  8001b7:	c9                   	leave  
  8001b8:	c3                   	ret    
  8001b9:	66 90                	xchg   %ax,%ax
  8001bb:	90                   	nop

008001bc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	56                   	push   %esi
  8001c0:	53                   	push   %ebx
  8001c1:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8001c4:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001c7:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001cd:	e8 45 0c 00 00       	call   800e17 <sys_getenvid>
  8001d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001d9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001dc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001e0:	89 74 24 08          	mov    %esi,0x8(%esp)
  8001e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e8:	c7 04 24 b0 20 80 00 	movl   $0x8020b0,(%esp)
  8001ef:	e8 c3 00 00 00       	call   8002b7 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001f8:	8b 45 10             	mov    0x10(%ebp),%eax
  8001fb:	89 04 24             	mov    %eax,(%esp)
  8001fe:	e8 53 00 00 00       	call   800256 <vcprintf>
	cprintf("\n");
  800203:	c7 04 24 9b 24 80 00 	movl   $0x80249b,(%esp)
  80020a:	e8 a8 00 00 00       	call   8002b7 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80020f:	cc                   	int3   
  800210:	eb fd                	jmp    80020f <_panic+0x53>
  800212:	66 90                	xchg   %ax,%ax

00800214 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	53                   	push   %ebx
  800218:	83 ec 14             	sub    $0x14,%esp
  80021b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80021e:	8b 03                	mov    (%ebx),%eax
  800220:	8b 55 08             	mov    0x8(%ebp),%edx
  800223:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800227:	83 c0 01             	add    $0x1,%eax
  80022a:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80022c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800231:	75 19                	jne    80024c <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800233:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80023a:	00 
  80023b:	8d 43 08             	lea    0x8(%ebx),%eax
  80023e:	89 04 24             	mov    %eax,(%esp)
  800241:	e8 fa 0a 00 00       	call   800d40 <sys_cputs>
		b->idx = 0;
  800246:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80024c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800250:	83 c4 14             	add    $0x14,%esp
  800253:	5b                   	pop    %ebx
  800254:	5d                   	pop    %ebp
  800255:	c3                   	ret    

00800256 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800256:	55                   	push   %ebp
  800257:	89 e5                	mov    %esp,%ebp
  800259:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80025f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800266:	00 00 00 
	b.cnt = 0;
  800269:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800270:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800273:	8b 45 0c             	mov    0xc(%ebp),%eax
  800276:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80027a:	8b 45 08             	mov    0x8(%ebp),%eax
  80027d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800281:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800287:	89 44 24 04          	mov    %eax,0x4(%esp)
  80028b:	c7 04 24 14 02 80 00 	movl   $0x800214,(%esp)
  800292:	e8 bb 01 00 00       	call   800452 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800297:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80029d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002a1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002a7:	89 04 24             	mov    %eax,(%esp)
  8002aa:	e8 91 0a 00 00       	call   800d40 <sys_cputs>

	return b.cnt;
}
  8002af:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002b5:	c9                   	leave  
  8002b6:	c3                   	ret    

008002b7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002b7:	55                   	push   %ebp
  8002b8:	89 e5                	mov    %esp,%ebp
  8002ba:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002bd:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c7:	89 04 24             	mov    %eax,(%esp)
  8002ca:	e8 87 ff ff ff       	call   800256 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002cf:	c9                   	leave  
  8002d0:	c3                   	ret    
  8002d1:	66 90                	xchg   %ax,%ax
  8002d3:	66 90                	xchg   %ax,%ax
  8002d5:	66 90                	xchg   %ax,%ax
  8002d7:	66 90                	xchg   %ax,%ax
  8002d9:	66 90                	xchg   %ax,%ax
  8002db:	66 90                	xchg   %ax,%ax
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
  800355:	e8 36 1a 00 00       	call   801d90 <__udivdi3>
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
  8003b3:	e8 28 1b 00 00       	call   801ee0 <__umoddi3>
  8003b8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003bc:	0f be 80 d3 20 80 00 	movsbl 0x8020d3(%eax),%eax
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
  8004e7:	ff 24 85 20 22 80 00 	jmp    *0x802220(,%eax,4)
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
  8005a9:	8b 14 85 80 23 80 00 	mov    0x802380(,%eax,4),%edx
  8005b0:	85 d2                	test   %edx,%edx
  8005b2:	75 20                	jne    8005d4 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  8005b4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005b8:	c7 44 24 08 eb 20 80 	movl   $0x8020eb,0x8(%esp)
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
  8005d8:	c7 44 24 08 f4 20 80 	movl   $0x8020f4,0x8(%esp)
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
  80060a:	b8 e4 20 80 00       	mov    $0x8020e4,%eax
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
  800dee:	c7 44 24 08 df 23 80 	movl   $0x8023df,0x8(%esp)
  800df5:	00 
  800df6:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800dfd:	00 
  800dfe:	c7 04 24 fc 23 80 00 	movl   $0x8023fc,(%esp)
  800e05:	e8 b2 f3 ff ff       	call   8001bc <_panic>

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
  800ec8:	c7 44 24 08 df 23 80 	movl   $0x8023df,0x8(%esp)
  800ecf:	00 
  800ed0:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800ed7:	00 
  800ed8:	c7 04 24 fc 23 80 00 	movl   $0x8023fc,(%esp)
  800edf:	e8 d8 f2 ff ff       	call   8001bc <_panic>

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
  800f2f:	c7 44 24 08 df 23 80 	movl   $0x8023df,0x8(%esp)
  800f36:	00 
  800f37:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800f3e:	00 
  800f3f:	c7 04 24 fc 23 80 00 	movl   $0x8023fc,(%esp)
  800f46:	e8 71 f2 ff ff       	call   8001bc <_panic>

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
  800f96:	c7 44 24 08 df 23 80 	movl   $0x8023df,0x8(%esp)
  800f9d:	00 
  800f9e:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800fa5:	00 
  800fa6:	c7 04 24 fc 23 80 00 	movl   $0x8023fc,(%esp)
  800fad:	e8 0a f2 ff ff       	call   8001bc <_panic>

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
  800ffd:	c7 44 24 08 df 23 80 	movl   $0x8023df,0x8(%esp)
  801004:	00 
  801005:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  80100c:	00 
  80100d:	c7 04 24 fc 23 80 00 	movl   $0x8023fc,(%esp)
  801014:	e8 a3 f1 ff ff       	call   8001bc <_panic>

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
  801064:	c7 44 24 08 df 23 80 	movl   $0x8023df,0x8(%esp)
  80106b:	00 
  80106c:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  801073:	00 
  801074:	c7 04 24 fc 23 80 00 	movl   $0x8023fc,(%esp)
  80107b:	e8 3c f1 ff ff       	call   8001bc <_panic>

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
  8010cb:	c7 44 24 08 df 23 80 	movl   $0x8023df,0x8(%esp)
  8010d2:	00 
  8010d3:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  8010da:	00 
  8010db:	c7 04 24 fc 23 80 00 	movl   $0x8023fc,(%esp)
  8010e2:	e8 d5 f0 ff ff       	call   8001bc <_panic>

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
  80116e:	c7 44 24 08 df 23 80 	movl   $0x8023df,0x8(%esp)
  801175:	00 
  801176:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  80117d:	00 
  80117e:	c7 04 24 fc 23 80 00 	movl   $0x8023fc,(%esp)
  801185:	e8 32 f0 ff ff       	call   8001bc <_panic>

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
  801197:	90                   	nop

00801198 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801198:	55                   	push   %ebp
  801199:	89 e5                	mov    %esp,%ebp
  80119b:	56                   	push   %esi
  80119c:	53                   	push   %ebx
  80119d:	83 ec 20             	sub    $0x20,%esp
  8011a0:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8011a3:	8b 30                	mov    (%eax),%esi
	// Hint:
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	pde_t pde = vpt[PGNUM(addr)];
  8011a5:	89 f2                	mov    %esi,%edx
  8011a7:	c1 ea 0c             	shr    $0xc,%edx
  8011aa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx

	if(!((err & FEC_WR) && (pde &PTE_COW) ))
  8011b1:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8011b5:	74 05                	je     8011bc <pgfault+0x24>
  8011b7:	f6 c6 08             	test   $0x8,%dh
  8011ba:	75 20                	jne    8011dc <pgfault+0x44>
		panic("Unrecoverable page fault at address[0x%x]!\n", addr);
  8011bc:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8011c0:	c7 44 24 08 0c 24 80 	movl   $0x80240c,0x8(%esp)
  8011c7:	00 
  8011c8:	c7 44 24 04 1f 00 00 	movl   $0x1f,0x4(%esp)
  8011cf:	00 
  8011d0:	c7 04 24 59 24 80 00 	movl   $0x802459,(%esp)
  8011d7:	e8 e0 ef ff ff       	call   8001bc <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	envid_t thisenv_id = sys_getenvid();
  8011dc:	e8 36 fc ff ff       	call   800e17 <sys_getenvid>
  8011e1:	89 c3                	mov    %eax,%ebx
	sys_page_alloc(thisenv_id, PFTEMP, PTE_P|PTE_W|PTE_U);
  8011e3:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8011ea:	00 
  8011eb:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8011f2:	00 
  8011f3:	89 04 24             	mov    %eax,(%esp)
  8011f6:	e8 8e fc ff ff       	call   800e89 <sys_page_alloc>
	memmove((void*)PFTEMP, (void*)ROUNDDOWN(addr, PGSIZE), PGSIZE);
  8011fb:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  801201:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801208:	00 
  801209:	89 74 24 04          	mov    %esi,0x4(%esp)
  80120d:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801214:	e8 2a f9 ff ff       	call   800b43 <memmove>
	sys_page_map(thisenv_id, (void*)PFTEMP, thisenv_id,(void*)ROUNDDOWN(addr, PGSIZE), 
  801219:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801220:	00 
  801221:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801225:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801229:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801230:	00 
  801231:	89 1c 24             	mov    %ebx,(%esp)
  801234:	e8 b8 fc ff ff       	call   800ef1 <sys_page_map>
		PTE_U|PTE_W|PTE_P);
	//panic("pgfault not implemented");
}
  801239:	83 c4 20             	add    $0x20,%esp
  80123c:	5b                   	pop    %ebx
  80123d:	5e                   	pop    %esi
  80123e:	5d                   	pop    %ebp
  80123f:	c3                   	ret    

00801240 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801240:	55                   	push   %ebp
  801241:	89 e5                	mov    %esp,%ebp
  801243:	57                   	push   %edi
  801244:	56                   	push   %esi
  801245:	53                   	push   %ebx
  801246:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	envid_t child_id;
	uint32_t pg_cow_ptr;
	int r;

	set_pgfault_handler(pgfault);
  801249:	c7 04 24 98 11 80 00 	movl   $0x801198,(%esp)
  801250:	e8 9b 0a 00 00       	call   801cf0 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801255:	ba 07 00 00 00       	mov    $0x7,%edx
  80125a:	89 d0                	mov    %edx,%eax
  80125c:	cd 30                	int    $0x30
  80125e:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801261:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if((child_id = sys_exofork()) < 0)
  801264:	85 c0                	test   %eax,%eax
  801266:	79 1c                	jns    801284 <fork+0x44>
		panic("Fork error\n");
  801268:	c7 44 24 08 64 24 80 	movl   $0x802464,0x8(%esp)
  80126f:	00 
  801270:	c7 44 24 04 6e 00 00 	movl   $0x6e,0x4(%esp)
  801277:	00 
  801278:	c7 04 24 59 24 80 00 	movl   $0x802459,(%esp)
  80127f:	e8 38 ef ff ff       	call   8001bc <_panic>
	if(child_id == 0){
  801284:	bb 00 00 80 00       	mov    $0x800000,%ebx
  801289:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80128d:	75 1c                	jne    8012ab <fork+0x6b>
		thisenv = &envs[ENVX(sys_getenvid())];
  80128f:	e8 83 fb ff ff       	call   800e17 <sys_getenvid>
  801294:	25 ff 03 00 00       	and    $0x3ff,%eax
  801299:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80129c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8012a1:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  8012a6:	e9 00 01 00 00       	jmp    8013ab <fork+0x16b>
	}
	for(pg_cow_ptr = UTEXT; pg_cow_ptr < UXSTACKTOP - PGSIZE; pg_cow_ptr += PGSIZE){
		if ((vpd[PDX(pg_cow_ptr)]&PTE_P) && (vpt[PGNUM(pg_cow_ptr)]&(PTE_P|PTE_U)))
  8012ab:	89 d8                	mov    %ebx,%eax
  8012ad:	c1 e8 16             	shr    $0x16,%eax
  8012b0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012b7:	a8 01                	test   $0x1,%al
  8012b9:	74 79                	je     801334 <fork+0xf4>
  8012bb:	89 de                	mov    %ebx,%esi
  8012bd:	c1 ee 0c             	shr    $0xc,%esi
  8012c0:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8012c7:	a8 05                	test   $0x5,%al
  8012c9:	74 69                	je     801334 <fork+0xf4>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	// LAB 4: Your code here.
	int map_sz = pn*PGSIZE;
  8012cb:	89 f7                	mov    %esi,%edi
  8012cd:	c1 e7 0c             	shl    $0xc,%edi
	envid_t thisenv_id = sys_getenvid();
  8012d0:	e8 42 fb ff ff       	call   800e17 <sys_getenvid>
  8012d5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	int perm = vpt[pn]&PTE_SYSCALL;
  8012d8:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8012df:	89 c6                	mov    %eax,%esi
  8012e1:	81 e6 07 0e 00 00    	and    $0xe07,%esi

	if(perm & PTE_COW || perm & PTE_W){
  8012e7:	a9 02 08 00 00       	test   $0x802,%eax
  8012ec:	74 09                	je     8012f7 <fork+0xb7>
		perm |= PTE_COW;
  8012ee:	81 ce 00 08 00 00    	or     $0x800,%esi
		perm &= ~PTE_W;
  8012f4:	83 e6 fd             	and    $0xfffffffd,%esi
	}
	//cprintf("thisenv_id[%p]\n", thisenv_id);

	if((r = sys_page_map(thisenv_id, (void*)map_sz, envid, (void*)map_sz, perm)) < 0)
  8012f7:	89 74 24 10          	mov    %esi,0x10(%esp)
  8012fb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012ff:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801302:	89 44 24 08          	mov    %eax,0x8(%esp)
  801306:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80130a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80130d:	89 04 24             	mov    %eax,(%esp)
  801310:	e8 dc fb ff ff       	call   800ef1 <sys_page_map>
  801315:	85 c0                	test   %eax,%eax
  801317:	78 1b                	js     801334 <fork+0xf4>
		return r;
	if((r = sys_page_map(thisenv_id, (void*)map_sz, thisenv_id, (void*)map_sz, perm)) < 0)
  801319:	89 74 24 10          	mov    %esi,0x10(%esp)
  80131d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801321:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801324:	89 44 24 08          	mov    %eax,0x8(%esp)
  801328:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80132c:	89 04 24             	mov    %eax,(%esp)
  80132f:	e8 bd fb ff ff       	call   800ef1 <sys_page_map>
		panic("Fork error\n");
	if(child_id == 0){
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	for(pg_cow_ptr = UTEXT; pg_cow_ptr < UXSTACKTOP - PGSIZE; pg_cow_ptr += PGSIZE){
  801334:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80133a:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801340:	0f 85 65 ff ff ff    	jne    8012ab <fork+0x6b>
		if ((vpd[PDX(pg_cow_ptr)]&PTE_P) && (vpt[PGNUM(pg_cow_ptr)]&(PTE_P|PTE_U)))
			duppage(child_id, PGNUM(pg_cow_ptr));
	}
	if((r = sys_page_alloc(child_id, (void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_P|PTE_W)))
  801346:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80134d:	00 
  80134e:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801355:	ee 
  801356:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801359:	89 04 24             	mov    %eax,(%esp)
  80135c:	e8 28 fb ff ff       	call   800e89 <sys_page_alloc>
  801361:	85 c0                	test   %eax,%eax
  801363:	74 20                	je     801385 <fork+0x145>
		panic("Alloc exception stack error: %e\n", r);
  801365:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801369:	c7 44 24 08 38 24 80 	movl   $0x802438,0x8(%esp)
  801370:	00 
  801371:	c7 44 24 04 78 00 00 	movl   $0x78,0x4(%esp)
  801378:	00 
  801379:	c7 04 24 59 24 80 00 	movl   $0x802459,(%esp)
  801380:	e8 37 ee ff ff       	call   8001bc <_panic>

	extern void _pgfault_upcall(void);
	sys_env_set_pgfault_upcall(child_id, _pgfault_upcall);
  801385:	c7 44 24 04 60 1d 80 	movl   $0x801d60,0x4(%esp)
  80138c:	00 
  80138d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801390:	89 04 24             	mov    %eax,(%esp)
  801393:	e8 f5 fc ff ff       	call   80108d <sys_env_set_pgfault_upcall>

	sys_env_set_status(child_id, ENV_RUNNABLE);
  801398:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80139f:	00 
  8013a0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8013a3:	89 04 24             	mov    %eax,(%esp)
  8013a6:	e8 14 fc ff ff       	call   800fbf <sys_env_set_status>
	return child_id;
	//panic("fork not implemented");
}
  8013ab:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8013ae:	83 c4 3c             	add    $0x3c,%esp
  8013b1:	5b                   	pop    %ebx
  8013b2:	5e                   	pop    %esi
  8013b3:	5f                   	pop    %edi
  8013b4:	5d                   	pop    %ebp
  8013b5:	c3                   	ret    

008013b6 <sfork>:

// Challenge!
int
sfork(void)
{
  8013b6:	55                   	push   %ebp
  8013b7:	89 e5                	mov    %esp,%ebp
  8013b9:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8013bc:	c7 44 24 08 70 24 80 	movl   $0x802470,0x8(%esp)
  8013c3:	00 
  8013c4:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  8013cb:	00 
  8013cc:	c7 04 24 59 24 80 00 	movl   $0x802459,(%esp)
  8013d3:	e8 e4 ed ff ff       	call   8001bc <_panic>

008013d8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8013d8:	55                   	push   %ebp
  8013d9:	89 e5                	mov    %esp,%ebp
  8013db:	56                   	push   %esi
  8013dc:	53                   	push   %ebx
  8013dd:	83 ec 10             	sub    $0x10,%esp
  8013e0:	8b 75 08             	mov    0x8(%ebp),%esi
  8013e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	// 	return thisenv->env_ipc_value;
	// }
	int r;
	if(pg == NULL)
		pg = (void *)~0x0;
  8013e6:	85 db                	test   %ebx,%ebx
  8013e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8013ed:	0f 44 d8             	cmove  %eax,%ebx
	//else
	if((r = sys_ipc_recv(pg)) < 0)
  8013f0:	89 1c 24             	mov    %ebx,(%esp)
  8013f3:	e8 39 fd ff ff       	call   801131 <sys_ipc_recv>
  8013f8:	85 c0                	test   %eax,%eax
  8013fa:	78 2d                	js     801429 <ipc_recv+0x51>
		return r;
	//volatile struct Env *curenv = (struct Env*)envs+ENVX(sys_getenvid());

	if(from_env_store)
  8013fc:	85 f6                	test   %esi,%esi
  8013fe:	74 0a                	je     80140a <ipc_recv+0x32>
		*from_env_store = thisenv -> env_ipc_from;
  801400:	a1 04 40 80 00       	mov    0x804004,%eax
  801405:	8b 40 74             	mov    0x74(%eax),%eax
  801408:	89 06                	mov    %eax,(%esi)
	if(pg && perm_store)
  80140a:	85 db                	test   %ebx,%ebx
  80140c:	74 13                	je     801421 <ipc_recv+0x49>
  80140e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801412:	74 0d                	je     801421 <ipc_recv+0x49>
		*perm_store = thisenv -> env_ipc_perm;
  801414:	a1 04 40 80 00       	mov    0x804004,%eax
  801419:	8b 40 78             	mov    0x78(%eax),%eax
  80141c:	8b 55 10             	mov    0x10(%ebp),%edx
  80141f:	89 02                	mov    %eax,(%edx)
	else if(perm_store)
		perm_store = (int *)0;
	return thisenv->env_ipc_value;
  801421:	a1 04 40 80 00       	mov    0x804004,%eax
  801426:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  801429:	83 c4 10             	add    $0x10,%esp
  80142c:	5b                   	pop    %ebx
  80142d:	5e                   	pop    %esi
  80142e:	5d                   	pop    %ebp
  80142f:	c3                   	ret    

00801430 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801430:	55                   	push   %ebp
  801431:	89 e5                	mov    %esp,%ebp
  801433:	57                   	push   %edi
  801434:	56                   	push   %esi
  801435:	53                   	push   %ebx
  801436:	83 ec 1c             	sub    $0x1c,%esp
  801439:	8b 7d 08             	mov    0x8(%ebp),%edi
  80143c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80143f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

	if(pg == NULL)
  801442:	85 db                	test   %ebx,%ebx
		pg = (void *)~0x0;
  801444:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801449:	0f 44 d8             	cmove  %eax,%ebx
  80144c:	eb 2a                	jmp    801478 <ipc_send+0x48>
	while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0){
		if(r != -E_IPC_NOT_RECV)
  80144e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801451:	74 20                	je     801473 <ipc_send+0x43>
            panic("Send message error %e\n",r);
  801453:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801457:	c7 44 24 08 86 24 80 	movl   $0x802486,0x8(%esp)
  80145e:	00 
  80145f:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  801466:	00 
  801467:	c7 04 24 9d 24 80 00 	movl   $0x80249d,(%esp)
  80146e:	e8 49 ed ff ff       	call   8001bc <_panic>
		sys_yield();
  801473:	e8 d8 f9 ff ff       	call   800e50 <sys_yield>
	// LAB 4: Your code here.
	int r;

	if(pg == NULL)
		pg = (void *)~0x0;
	while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0){
  801478:	8b 45 14             	mov    0x14(%ebp),%eax
  80147b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80147f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801483:	89 74 24 04          	mov    %esi,0x4(%esp)
  801487:	89 3c 24             	mov    %edi,(%esp)
  80148a:	e8 65 fc ff ff       	call   8010f4 <sys_ipc_try_send>
  80148f:	85 c0                	test   %eax,%eax
  801491:	78 bb                	js     80144e <ipc_send+0x1e>
            panic("Send message error %e\n",r);
		sys_yield();
	}

	//panic("ipc_send not implemented");
}
  801493:	83 c4 1c             	add    $0x1c,%esp
  801496:	5b                   	pop    %ebx
  801497:	5e                   	pop    %esi
  801498:	5f                   	pop    %edi
  801499:	5d                   	pop    %ebp
  80149a:	c3                   	ret    

0080149b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80149b:	55                   	push   %ebp
  80149c:	89 e5                	mov    %esp,%ebp
  80149e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8014a1:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  8014a6:	39 c8                	cmp    %ecx,%eax
  8014a8:	74 17                	je     8014c1 <ipc_find_env+0x26>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8014aa:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  8014af:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8014b2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8014b8:	8b 52 50             	mov    0x50(%edx),%edx
  8014bb:	39 ca                	cmp    %ecx,%edx
  8014bd:	75 14                	jne    8014d3 <ipc_find_env+0x38>
  8014bf:	eb 05                	jmp    8014c6 <ipc_find_env+0x2b>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8014c1:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  8014c6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8014c9:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8014ce:	8b 40 40             	mov    0x40(%eax),%eax
  8014d1:	eb 0e                	jmp    8014e1 <ipc_find_env+0x46>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8014d3:	83 c0 01             	add    $0x1,%eax
  8014d6:	3d 00 04 00 00       	cmp    $0x400,%eax
  8014db:	75 d2                	jne    8014af <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8014dd:	66 b8 00 00          	mov    $0x0,%ax
}
  8014e1:	5d                   	pop    %ebp
  8014e2:	c3                   	ret    
  8014e3:	66 90                	xchg   %ax,%ax
  8014e5:	66 90                	xchg   %ax,%ax
  8014e7:	66 90                	xchg   %ax,%ax
  8014e9:	66 90                	xchg   %ax,%ax
  8014eb:	66 90                	xchg   %ax,%ax
  8014ed:	66 90                	xchg   %ax,%ax
  8014ef:	90                   	nop

008014f0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8014f0:	55                   	push   %ebp
  8014f1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f6:	05 00 00 00 30       	add    $0x30000000,%eax
  8014fb:	c1 e8 0c             	shr    $0xc,%eax
}
  8014fe:	5d                   	pop    %ebp
  8014ff:	c3                   	ret    

00801500 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801500:	55                   	push   %ebp
  801501:	89 e5                	mov    %esp,%ebp
  801503:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801506:	8b 45 08             	mov    0x8(%ebp),%eax
  801509:	89 04 24             	mov    %eax,(%esp)
  80150c:	e8 df ff ff ff       	call   8014f0 <fd2num>
  801511:	c1 e0 0c             	shl    $0xc,%eax
  801514:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801519:	c9                   	leave  
  80151a:	c3                   	ret    

0080151b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80151b:	55                   	push   %ebp
  80151c:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  80151e:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801523:	a8 01                	test   $0x1,%al
  801525:	74 34                	je     80155b <fd_alloc+0x40>
  801527:	a1 00 00 74 ef       	mov    0xef740000,%eax
  80152c:	a8 01                	test   $0x1,%al
  80152e:	74 32                	je     801562 <fd_alloc+0x47>
  801530:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801535:	89 c1                	mov    %eax,%ecx
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801537:	89 c2                	mov    %eax,%edx
  801539:	c1 ea 16             	shr    $0x16,%edx
  80153c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801543:	f6 c2 01             	test   $0x1,%dl
  801546:	74 1f                	je     801567 <fd_alloc+0x4c>
  801548:	89 c2                	mov    %eax,%edx
  80154a:	c1 ea 0c             	shr    $0xc,%edx
  80154d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801554:	f6 c2 01             	test   $0x1,%dl
  801557:	75 1a                	jne    801573 <fd_alloc+0x58>
  801559:	eb 0c                	jmp    801567 <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80155b:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801560:	eb 05                	jmp    801567 <fd_alloc+0x4c>
  801562:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  801567:	8b 45 08             	mov    0x8(%ebp),%eax
  80156a:	89 08                	mov    %ecx,(%eax)
			return 0;
  80156c:	b8 00 00 00 00       	mov    $0x0,%eax
  801571:	eb 1a                	jmp    80158d <fd_alloc+0x72>
  801573:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801578:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80157d:	75 b6                	jne    801535 <fd_alloc+0x1a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80157f:	8b 45 08             	mov    0x8(%ebp),%eax
  801582:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801588:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80158d:	5d                   	pop    %ebp
  80158e:	c3                   	ret    

0080158f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80158f:	55                   	push   %ebp
  801590:	89 e5                	mov    %esp,%ebp
  801592:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801595:	83 f8 1f             	cmp    $0x1f,%eax
  801598:	77 36                	ja     8015d0 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80159a:	c1 e0 0c             	shl    $0xc,%eax
  80159d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  8015a2:	89 c2                	mov    %eax,%edx
  8015a4:	c1 ea 16             	shr    $0x16,%edx
  8015a7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8015ae:	f6 c2 01             	test   $0x1,%dl
  8015b1:	74 24                	je     8015d7 <fd_lookup+0x48>
  8015b3:	89 c2                	mov    %eax,%edx
  8015b5:	c1 ea 0c             	shr    $0xc,%edx
  8015b8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8015bf:	f6 c2 01             	test   $0x1,%dl
  8015c2:	74 1a                	je     8015de <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8015c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015c7:	89 02                	mov    %eax,(%edx)
	return 0;
  8015c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8015ce:	eb 13                	jmp    8015e3 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  8015d0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015d5:	eb 0c                	jmp    8015e3 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  8015d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015dc:	eb 05                	jmp    8015e3 <fd_lookup+0x54>
  8015de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8015e3:	5d                   	pop    %ebp
  8015e4:	c3                   	ret    

008015e5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8015e5:	55                   	push   %ebp
  8015e6:	89 e5                	mov    %esp,%ebp
  8015e8:	83 ec 18             	sub    $0x18,%esp
  8015eb:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8015ee:	39 05 04 30 80 00    	cmp    %eax,0x803004
  8015f4:	75 10                	jne    801606 <dev_lookup+0x21>
			*dev = devtab[i];
  8015f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015f9:	c7 00 04 30 80 00    	movl   $0x803004,(%eax)
			return 0;
  8015ff:	b8 00 00 00 00       	mov    $0x0,%eax
  801604:	eb 2b                	jmp    801631 <dev_lookup+0x4c>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801606:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80160c:	8b 52 48             	mov    0x48(%edx),%edx
  80160f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801613:	89 54 24 04          	mov    %edx,0x4(%esp)
  801617:	c7 04 24 a8 24 80 00 	movl   $0x8024a8,(%esp)
  80161e:	e8 94 ec ff ff       	call   8002b7 <cprintf>
	*dev = 0;
  801623:	8b 55 0c             	mov    0xc(%ebp),%edx
  801626:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	return -E_INVAL;
  80162c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801631:	c9                   	leave  
  801632:	c3                   	ret    

00801633 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801633:	55                   	push   %ebp
  801634:	89 e5                	mov    %esp,%ebp
  801636:	83 ec 38             	sub    $0x38,%esp
  801639:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80163c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80163f:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801642:	8b 7d 08             	mov    0x8(%ebp),%edi
  801645:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801648:	89 3c 24             	mov    %edi,(%esp)
  80164b:	e8 a0 fe ff ff       	call   8014f0 <fd2num>
  801650:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  801653:	89 54 24 04          	mov    %edx,0x4(%esp)
  801657:	89 04 24             	mov    %eax,(%esp)
  80165a:	e8 30 ff ff ff       	call   80158f <fd_lookup>
  80165f:	89 c3                	mov    %eax,%ebx
  801661:	85 c0                	test   %eax,%eax
  801663:	78 05                	js     80166a <fd_close+0x37>
	    || fd != fd2)
  801665:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  801668:	74 0c                	je     801676 <fd_close+0x43>
		return (must_exist ? r : 0);
  80166a:	85 f6                	test   %esi,%esi
  80166c:	b8 00 00 00 00       	mov    $0x0,%eax
  801671:	0f 44 d8             	cmove  %eax,%ebx
  801674:	eb 3d                	jmp    8016b3 <fd_close+0x80>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801676:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801679:	89 44 24 04          	mov    %eax,0x4(%esp)
  80167d:	8b 07                	mov    (%edi),%eax
  80167f:	89 04 24             	mov    %eax,(%esp)
  801682:	e8 5e ff ff ff       	call   8015e5 <dev_lookup>
  801687:	89 c3                	mov    %eax,%ebx
  801689:	85 c0                	test   %eax,%eax
  80168b:	78 16                	js     8016a3 <fd_close+0x70>
		if (dev->dev_close)
  80168d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801690:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801693:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801698:	85 c0                	test   %eax,%eax
  80169a:	74 07                	je     8016a3 <fd_close+0x70>
			r = (*dev->dev_close)(fd);
  80169c:	89 3c 24             	mov    %edi,(%esp)
  80169f:	ff d0                	call   *%eax
  8016a1:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8016a3:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8016a7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016ae:	e8 a5 f8 ff ff       	call   800f58 <sys_page_unmap>
	return r;
}
  8016b3:	89 d8                	mov    %ebx,%eax
  8016b5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8016b8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8016bb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8016be:	89 ec                	mov    %ebp,%esp
  8016c0:	5d                   	pop    %ebp
  8016c1:	c3                   	ret    

008016c2 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8016c2:	55                   	push   %ebp
  8016c3:	89 e5                	mov    %esp,%ebp
  8016c5:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d2:	89 04 24             	mov    %eax,(%esp)
  8016d5:	e8 b5 fe ff ff       	call   80158f <fd_lookup>
  8016da:	85 c0                	test   %eax,%eax
  8016dc:	78 13                	js     8016f1 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8016de:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8016e5:	00 
  8016e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016e9:	89 04 24             	mov    %eax,(%esp)
  8016ec:	e8 42 ff ff ff       	call   801633 <fd_close>
}
  8016f1:	c9                   	leave  
  8016f2:	c3                   	ret    

008016f3 <close_all>:

void
close_all(void)
{
  8016f3:	55                   	push   %ebp
  8016f4:	89 e5                	mov    %esp,%ebp
  8016f6:	53                   	push   %ebx
  8016f7:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8016fa:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8016ff:	89 1c 24             	mov    %ebx,(%esp)
  801702:	e8 bb ff ff ff       	call   8016c2 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801707:	83 c3 01             	add    $0x1,%ebx
  80170a:	83 fb 20             	cmp    $0x20,%ebx
  80170d:	75 f0                	jne    8016ff <close_all+0xc>
		close(i);
}
  80170f:	83 c4 14             	add    $0x14,%esp
  801712:	5b                   	pop    %ebx
  801713:	5d                   	pop    %ebp
  801714:	c3                   	ret    

00801715 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801715:	55                   	push   %ebp
  801716:	89 e5                	mov    %esp,%ebp
  801718:	83 ec 58             	sub    $0x58,%esp
  80171b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80171e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801721:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801724:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801727:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80172a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80172e:	8b 45 08             	mov    0x8(%ebp),%eax
  801731:	89 04 24             	mov    %eax,(%esp)
  801734:	e8 56 fe ff ff       	call   80158f <fd_lookup>
  801739:	85 c0                	test   %eax,%eax
  80173b:	0f 88 e3 00 00 00    	js     801824 <dup+0x10f>
		return r;
	close(newfdnum);
  801741:	89 1c 24             	mov    %ebx,(%esp)
  801744:	e8 79 ff ff ff       	call   8016c2 <close>

	newfd = INDEX2FD(newfdnum);
  801749:	89 de                	mov    %ebx,%esi
  80174b:	c1 e6 0c             	shl    $0xc,%esi
  80174e:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801754:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801757:	89 04 24             	mov    %eax,(%esp)
  80175a:	e8 a1 fd ff ff       	call   801500 <fd2data>
  80175f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801761:	89 34 24             	mov    %esi,(%esp)
  801764:	e8 97 fd ff ff       	call   801500 <fd2data>
  801769:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  80176c:	89 f8                	mov    %edi,%eax
  80176e:	c1 e8 16             	shr    $0x16,%eax
  801771:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801778:	a8 01                	test   $0x1,%al
  80177a:	74 46                	je     8017c2 <dup+0xad>
  80177c:	89 f8                	mov    %edi,%eax
  80177e:	c1 e8 0c             	shr    $0xc,%eax
  801781:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801788:	f6 c2 01             	test   $0x1,%dl
  80178b:	74 35                	je     8017c2 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80178d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801794:	25 07 0e 00 00       	and    $0xe07,%eax
  801799:	89 44 24 10          	mov    %eax,0x10(%esp)
  80179d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8017a0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017a4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017ab:	00 
  8017ac:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8017b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017b7:	e8 35 f7 ff ff       	call   800ef1 <sys_page_map>
  8017bc:	89 c7                	mov    %eax,%edi
  8017be:	85 c0                	test   %eax,%eax
  8017c0:	78 3b                	js     8017fd <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8017c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017c5:	89 c2                	mov    %eax,%edx
  8017c7:	c1 ea 0c             	shr    $0xc,%edx
  8017ca:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8017d1:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8017d7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8017db:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8017df:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017e6:	00 
  8017e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017f2:	e8 fa f6 ff ff       	call   800ef1 <sys_page_map>
  8017f7:	89 c7                	mov    %eax,%edi
  8017f9:	85 c0                	test   %eax,%eax
  8017fb:	79 29                	jns    801826 <dup+0x111>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8017fd:	89 74 24 04          	mov    %esi,0x4(%esp)
  801801:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801808:	e8 4b f7 ff ff       	call   800f58 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80180d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801810:	89 44 24 04          	mov    %eax,0x4(%esp)
  801814:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80181b:	e8 38 f7 ff ff       	call   800f58 <sys_page_unmap>
	return r;
  801820:	89 fb                	mov    %edi,%ebx
  801822:	eb 02                	jmp    801826 <dup+0x111>
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
		return r;
  801824:	89 c3                	mov    %eax,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801826:	89 d8                	mov    %ebx,%eax
  801828:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80182b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80182e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801831:	89 ec                	mov    %ebp,%esp
  801833:	5d                   	pop    %ebp
  801834:	c3                   	ret    

00801835 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801835:	55                   	push   %ebp
  801836:	89 e5                	mov    %esp,%ebp
  801838:	53                   	push   %ebx
  801839:	83 ec 24             	sub    $0x24,%esp
  80183c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80183f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801842:	89 44 24 04          	mov    %eax,0x4(%esp)
  801846:	89 1c 24             	mov    %ebx,(%esp)
  801849:	e8 41 fd ff ff       	call   80158f <fd_lookup>
  80184e:	85 c0                	test   %eax,%eax
  801850:	78 6d                	js     8018bf <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801852:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801855:	89 44 24 04          	mov    %eax,0x4(%esp)
  801859:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80185c:	8b 00                	mov    (%eax),%eax
  80185e:	89 04 24             	mov    %eax,(%esp)
  801861:	e8 7f fd ff ff       	call   8015e5 <dev_lookup>
  801866:	85 c0                	test   %eax,%eax
  801868:	78 55                	js     8018bf <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80186a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80186d:	8b 50 08             	mov    0x8(%eax),%edx
  801870:	83 e2 03             	and    $0x3,%edx
  801873:	83 fa 01             	cmp    $0x1,%edx
  801876:	75 23                	jne    80189b <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801878:	a1 04 40 80 00       	mov    0x804004,%eax
  80187d:	8b 40 48             	mov    0x48(%eax),%eax
  801880:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801884:	89 44 24 04          	mov    %eax,0x4(%esp)
  801888:	c7 04 24 e9 24 80 00 	movl   $0x8024e9,(%esp)
  80188f:	e8 23 ea ff ff       	call   8002b7 <cprintf>
		return -E_INVAL;
  801894:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801899:	eb 24                	jmp    8018bf <read+0x8a>
	}
	if (!dev->dev_read)
  80189b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80189e:	8b 52 08             	mov    0x8(%edx),%edx
  8018a1:	85 d2                	test   %edx,%edx
  8018a3:	74 15                	je     8018ba <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8018a5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8018a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8018ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018af:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8018b3:	89 04 24             	mov    %eax,(%esp)
  8018b6:	ff d2                	call   *%edx
  8018b8:	eb 05                	jmp    8018bf <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8018ba:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8018bf:	83 c4 24             	add    $0x24,%esp
  8018c2:	5b                   	pop    %ebx
  8018c3:	5d                   	pop    %ebp
  8018c4:	c3                   	ret    

008018c5 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8018c5:	55                   	push   %ebp
  8018c6:	89 e5                	mov    %esp,%ebp
  8018c8:	57                   	push   %edi
  8018c9:	56                   	push   %esi
  8018ca:	53                   	push   %ebx
  8018cb:	83 ec 1c             	sub    $0x1c,%esp
  8018ce:	8b 7d 08             	mov    0x8(%ebp),%edi
  8018d1:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8018d4:	85 f6                	test   %esi,%esi
  8018d6:	74 33                	je     80190b <readn+0x46>
  8018d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8018dd:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8018e2:	89 f2                	mov    %esi,%edx
  8018e4:	29 c2                	sub    %eax,%edx
  8018e6:	89 54 24 08          	mov    %edx,0x8(%esp)
  8018ea:	03 45 0c             	add    0xc(%ebp),%eax
  8018ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018f1:	89 3c 24             	mov    %edi,(%esp)
  8018f4:	e8 3c ff ff ff       	call   801835 <read>
		if (m < 0)
  8018f9:	85 c0                	test   %eax,%eax
  8018fb:	78 17                	js     801914 <readn+0x4f>
			return m;
		if (m == 0)
  8018fd:	85 c0                	test   %eax,%eax
  8018ff:	74 11                	je     801912 <readn+0x4d>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801901:	01 c3                	add    %eax,%ebx
  801903:	89 d8                	mov    %ebx,%eax
  801905:	39 f3                	cmp    %esi,%ebx
  801907:	72 d9                	jb     8018e2 <readn+0x1d>
  801909:	eb 09                	jmp    801914 <readn+0x4f>
  80190b:	b8 00 00 00 00       	mov    $0x0,%eax
  801910:	eb 02                	jmp    801914 <readn+0x4f>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801912:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801914:	83 c4 1c             	add    $0x1c,%esp
  801917:	5b                   	pop    %ebx
  801918:	5e                   	pop    %esi
  801919:	5f                   	pop    %edi
  80191a:	5d                   	pop    %ebp
  80191b:	c3                   	ret    

0080191c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80191c:	55                   	push   %ebp
  80191d:	89 e5                	mov    %esp,%ebp
  80191f:	53                   	push   %ebx
  801920:	83 ec 24             	sub    $0x24,%esp
  801923:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801926:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801929:	89 44 24 04          	mov    %eax,0x4(%esp)
  80192d:	89 1c 24             	mov    %ebx,(%esp)
  801930:	e8 5a fc ff ff       	call   80158f <fd_lookup>
  801935:	85 c0                	test   %eax,%eax
  801937:	78 68                	js     8019a1 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801939:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80193c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801940:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801943:	8b 00                	mov    (%eax),%eax
  801945:	89 04 24             	mov    %eax,(%esp)
  801948:	e8 98 fc ff ff       	call   8015e5 <dev_lookup>
  80194d:	85 c0                	test   %eax,%eax
  80194f:	78 50                	js     8019a1 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801951:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801954:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801958:	75 23                	jne    80197d <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80195a:	a1 04 40 80 00       	mov    0x804004,%eax
  80195f:	8b 40 48             	mov    0x48(%eax),%eax
  801962:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801966:	89 44 24 04          	mov    %eax,0x4(%esp)
  80196a:	c7 04 24 05 25 80 00 	movl   $0x802505,(%esp)
  801971:	e8 41 e9 ff ff       	call   8002b7 <cprintf>
		return -E_INVAL;
  801976:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80197b:	eb 24                	jmp    8019a1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80197d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801980:	8b 52 0c             	mov    0xc(%edx),%edx
  801983:	85 d2                	test   %edx,%edx
  801985:	74 15                	je     80199c <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801987:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80198a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80198e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801991:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801995:	89 04 24             	mov    %eax,(%esp)
  801998:	ff d2                	call   *%edx
  80199a:	eb 05                	jmp    8019a1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80199c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8019a1:	83 c4 24             	add    $0x24,%esp
  8019a4:	5b                   	pop    %ebx
  8019a5:	5d                   	pop    %ebp
  8019a6:	c3                   	ret    

008019a7 <seek>:

int
seek(int fdnum, off_t offset)
{
  8019a7:	55                   	push   %ebp
  8019a8:	89 e5                	mov    %esp,%ebp
  8019aa:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019ad:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8019b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b7:	89 04 24             	mov    %eax,(%esp)
  8019ba:	e8 d0 fb ff ff       	call   80158f <fd_lookup>
  8019bf:	85 c0                	test   %eax,%eax
  8019c1:	78 0e                	js     8019d1 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8019c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8019c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019c9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8019cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019d1:	c9                   	leave  
  8019d2:	c3                   	ret    

008019d3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8019d3:	55                   	push   %ebp
  8019d4:	89 e5                	mov    %esp,%ebp
  8019d6:	53                   	push   %ebx
  8019d7:	83 ec 24             	sub    $0x24,%esp
  8019da:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019e4:	89 1c 24             	mov    %ebx,(%esp)
  8019e7:	e8 a3 fb ff ff       	call   80158f <fd_lookup>
  8019ec:	85 c0                	test   %eax,%eax
  8019ee:	78 61                	js     801a51 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019fa:	8b 00                	mov    (%eax),%eax
  8019fc:	89 04 24             	mov    %eax,(%esp)
  8019ff:	e8 e1 fb ff ff       	call   8015e5 <dev_lookup>
  801a04:	85 c0                	test   %eax,%eax
  801a06:	78 49                	js     801a51 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801a08:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a0b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801a0f:	75 23                	jne    801a34 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801a11:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801a16:	8b 40 48             	mov    0x48(%eax),%eax
  801a19:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a21:	c7 04 24 c8 24 80 00 	movl   $0x8024c8,(%esp)
  801a28:	e8 8a e8 ff ff       	call   8002b7 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801a2d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a32:	eb 1d                	jmp    801a51 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801a34:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a37:	8b 52 18             	mov    0x18(%edx),%edx
  801a3a:	85 d2                	test   %edx,%edx
  801a3c:	74 0e                	je     801a4c <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801a3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a41:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801a45:	89 04 24             	mov    %eax,(%esp)
  801a48:	ff d2                	call   *%edx
  801a4a:	eb 05                	jmp    801a51 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801a4c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801a51:	83 c4 24             	add    $0x24,%esp
  801a54:	5b                   	pop    %ebx
  801a55:	5d                   	pop    %ebp
  801a56:	c3                   	ret    

00801a57 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801a57:	55                   	push   %ebp
  801a58:	89 e5                	mov    %esp,%ebp
  801a5a:	53                   	push   %ebx
  801a5b:	83 ec 24             	sub    $0x24,%esp
  801a5e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a61:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a64:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a68:	8b 45 08             	mov    0x8(%ebp),%eax
  801a6b:	89 04 24             	mov    %eax,(%esp)
  801a6e:	e8 1c fb ff ff       	call   80158f <fd_lookup>
  801a73:	85 c0                	test   %eax,%eax
  801a75:	78 52                	js     801ac9 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a77:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a7a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a81:	8b 00                	mov    (%eax),%eax
  801a83:	89 04 24             	mov    %eax,(%esp)
  801a86:	e8 5a fb ff ff       	call   8015e5 <dev_lookup>
  801a8b:	85 c0                	test   %eax,%eax
  801a8d:	78 3a                	js     801ac9 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801a8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a92:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801a96:	74 2c                	je     801ac4 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801a98:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801a9b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801aa2:	00 00 00 
	stat->st_isdir = 0;
  801aa5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801aac:	00 00 00 
	stat->st_dev = dev;
  801aaf:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801ab5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ab9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801abc:	89 14 24             	mov    %edx,(%esp)
  801abf:	ff 50 14             	call   *0x14(%eax)
  801ac2:	eb 05                	jmp    801ac9 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801ac4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801ac9:	83 c4 24             	add    $0x24,%esp
  801acc:	5b                   	pop    %ebx
  801acd:	5d                   	pop    %ebp
  801ace:	c3                   	ret    

00801acf <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801acf:	55                   	push   %ebp
  801ad0:	89 e5                	mov    %esp,%ebp
  801ad2:	83 ec 18             	sub    $0x18,%esp
  801ad5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801ad8:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801adb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801ae2:	00 
  801ae3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae6:	89 04 24             	mov    %eax,(%esp)
  801ae9:	e8 84 01 00 00       	call   801c72 <open>
  801aee:	89 c3                	mov    %eax,%ebx
  801af0:	85 c0                	test   %eax,%eax
  801af2:	78 1b                	js     801b0f <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801af4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801af7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801afb:	89 1c 24             	mov    %ebx,(%esp)
  801afe:	e8 54 ff ff ff       	call   801a57 <fstat>
  801b03:	89 c6                	mov    %eax,%esi
	close(fd);
  801b05:	89 1c 24             	mov    %ebx,(%esp)
  801b08:	e8 b5 fb ff ff       	call   8016c2 <close>
	return r;
  801b0d:	89 f3                	mov    %esi,%ebx
}
  801b0f:	89 d8                	mov    %ebx,%eax
  801b11:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801b14:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801b17:	89 ec                	mov    %ebp,%esp
  801b19:	5d                   	pop    %ebp
  801b1a:	c3                   	ret    
  801b1b:	90                   	nop

00801b1c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801b1c:	55                   	push   %ebp
  801b1d:	89 e5                	mov    %esp,%ebp
  801b1f:	83 ec 18             	sub    $0x18,%esp
  801b22:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801b25:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801b28:	89 c6                	mov    %eax,%esi
  801b2a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801b2c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801b33:	75 11                	jne    801b46 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801b35:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801b3c:	e8 5a f9 ff ff       	call   80149b <ipc_find_env>
  801b41:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801b46:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801b4d:	00 
  801b4e:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801b55:	00 
  801b56:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b5a:	a1 00 40 80 00       	mov    0x804000,%eax
  801b5f:	89 04 24             	mov    %eax,(%esp)
  801b62:	e8 c9 f8 ff ff       	call   801430 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801b67:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b6e:	00 
  801b6f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b73:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b7a:	e8 59 f8 ff ff       	call   8013d8 <ipc_recv>
}
  801b7f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801b82:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801b85:	89 ec                	mov    %ebp,%esp
  801b87:	5d                   	pop    %ebp
  801b88:	c3                   	ret    

00801b89 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801b89:	55                   	push   %ebp
  801b8a:	89 e5                	mov    %esp,%ebp
  801b8c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801b8f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b92:	8b 40 0c             	mov    0xc(%eax),%eax
  801b95:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801b9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b9d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801ba2:	ba 00 00 00 00       	mov    $0x0,%edx
  801ba7:	b8 02 00 00 00       	mov    $0x2,%eax
  801bac:	e8 6b ff ff ff       	call   801b1c <fsipc>
}
  801bb1:	c9                   	leave  
  801bb2:	c3                   	ret    

00801bb3 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801bb3:	55                   	push   %ebp
  801bb4:	89 e5                	mov    %esp,%ebp
  801bb6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801bb9:	8b 45 08             	mov    0x8(%ebp),%eax
  801bbc:	8b 40 0c             	mov    0xc(%eax),%eax
  801bbf:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801bc4:	ba 00 00 00 00       	mov    $0x0,%edx
  801bc9:	b8 06 00 00 00       	mov    $0x6,%eax
  801bce:	e8 49 ff ff ff       	call   801b1c <fsipc>
}
  801bd3:	c9                   	leave  
  801bd4:	c3                   	ret    

00801bd5 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801bd5:	55                   	push   %ebp
  801bd6:	89 e5                	mov    %esp,%ebp
  801bd8:	53                   	push   %ebx
  801bd9:	83 ec 14             	sub    $0x14,%esp
  801bdc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801bdf:	8b 45 08             	mov    0x8(%ebp),%eax
  801be2:	8b 40 0c             	mov    0xc(%eax),%eax
  801be5:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801bea:	ba 00 00 00 00       	mov    $0x0,%edx
  801bef:	b8 05 00 00 00       	mov    $0x5,%eax
  801bf4:	e8 23 ff ff ff       	call   801b1c <fsipc>
  801bf9:	85 c0                	test   %eax,%eax
  801bfb:	78 2b                	js     801c28 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801bfd:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801c04:	00 
  801c05:	89 1c 24             	mov    %ebx,(%esp)
  801c08:	e8 2e ed ff ff       	call   80093b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801c0d:	a1 80 50 80 00       	mov    0x805080,%eax
  801c12:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801c18:	a1 84 50 80 00       	mov    0x805084,%eax
  801c1d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801c23:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c28:	83 c4 14             	add    $0x14,%esp
  801c2b:	5b                   	pop    %ebx
  801c2c:	5d                   	pop    %ebp
  801c2d:	c3                   	ret    

00801c2e <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801c2e:	55                   	push   %ebp
  801c2f:	89 e5                	mov    %esp,%ebp
  801c31:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801c34:	c7 44 24 08 22 25 80 	movl   $0x802522,0x8(%esp)
  801c3b:	00 
  801c3c:	c7 44 24 04 77 00 00 	movl   $0x77,0x4(%esp)
  801c43:	00 
  801c44:	c7 04 24 40 25 80 00 	movl   $0x802540,(%esp)
  801c4b:	e8 6c e5 ff ff       	call   8001bc <_panic>

00801c50 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801c50:	55                   	push   %ebp
  801c51:	89 e5                	mov    %esp,%ebp
  801c53:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_READ request to the file system server after
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
	panic("devfile_read not implemented");
  801c56:	c7 44 24 08 4b 25 80 	movl   $0x80254b,0x8(%esp)
  801c5d:	00 
  801c5e:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
  801c65:	00 
  801c66:	c7 04 24 40 25 80 00 	movl   $0x802540,(%esp)
  801c6d:	e8 4a e5 ff ff       	call   8001bc <_panic>

00801c72 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801c72:	55                   	push   %ebp
  801c73:	89 e5                	mov    %esp,%ebp
  801c75:	83 ec 18             	sub    $0x18,%esp
	// Return the file descriptor index.
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
	panic("open not implemented");
  801c78:	c7 44 24 08 68 25 80 	movl   $0x802568,0x8(%esp)
  801c7f:	00 
  801c80:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  801c87:	00 
  801c88:	c7 04 24 40 25 80 00 	movl   $0x802540,(%esp)
  801c8f:	e8 28 e5 ff ff       	call   8001bc <_panic>

00801c94 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801c94:	55                   	push   %ebp
  801c95:	89 e5                	mov    %esp,%ebp
  801c97:	53                   	push   %ebx
  801c98:	83 ec 14             	sub    $0x14,%esp
  801c9b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801c9e:	89 1c 24             	mov    %ebx,(%esp)
  801ca1:	e8 3a ec ff ff       	call   8008e0 <strlen>
  801ca6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801cab:	7f 21                	jg     801cce <remove+0x3a>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801cad:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cb1:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801cb8:	e8 7e ec ff ff       	call   80093b <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801cbd:	ba 00 00 00 00       	mov    $0x0,%edx
  801cc2:	b8 07 00 00 00       	mov    $0x7,%eax
  801cc7:	e8 50 fe ff ff       	call   801b1c <fsipc>
  801ccc:	eb 05                	jmp    801cd3 <remove+0x3f>
// Delete a file
int
remove(const char *path)
{
	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801cce:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
	strcpy(fsipcbuf.remove.req_path, path);
	return fsipc(FSREQ_REMOVE, NULL);
}
  801cd3:	83 c4 14             	add    $0x14,%esp
  801cd6:	5b                   	pop    %ebx
  801cd7:	5d                   	pop    %ebp
  801cd8:	c3                   	ret    

00801cd9 <sync>:

// Synchronize disk with buffer cache
int
sync(void)
{
  801cd9:	55                   	push   %ebp
  801cda:	89 e5                	mov    %esp,%ebp
  801cdc:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801cdf:	ba 00 00 00 00       	mov    $0x0,%edx
  801ce4:	b8 08 00 00 00       	mov    $0x8,%eax
  801ce9:	e8 2e fe ff ff       	call   801b1c <fsipc>
}
  801cee:	c9                   	leave  
  801cef:	c3                   	ret    

00801cf0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801cf0:	55                   	push   %ebp
  801cf1:	89 e5                	mov    %esp,%ebp
  801cf3:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801cf6:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801cfd:	75 54                	jne    801d53 <set_pgfault_handler+0x63>
		// First time through!
		// LAB 4: Your code here.
		if((r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U|PTE_P|PTE_W)))
  801cff:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801d06:	00 
  801d07:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801d0e:	ee 
  801d0f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d16:	e8 6e f1 ff ff       	call   800e89 <sys_page_alloc>
  801d1b:	85 c0                	test   %eax,%eax
  801d1d:	74 20                	je     801d3f <set_pgfault_handler+0x4f>
			panic("sys_page_alloc() failed in set_pgfault_handler()[%e]\n", r);
  801d1f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d23:	c7 44 24 08 80 25 80 	movl   $0x802580,0x8(%esp)
  801d2a:	00 
  801d2b:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  801d32:	00 
  801d33:	c7 04 24 b8 25 80 00 	movl   $0x8025b8,(%esp)
  801d3a:	e8 7d e4 ff ff       	call   8001bc <_panic>
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801d3f:	c7 44 24 04 60 1d 80 	movl   $0x801d60,0x4(%esp)
  801d46:	00 
  801d47:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d4e:	e8 3a f3 ff ff       	call   80108d <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801d53:	8b 45 08             	mov    0x8(%ebp),%eax
  801d56:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801d5b:	c9                   	leave  
  801d5c:	c3                   	ret    
  801d5d:	66 90                	xchg   %ax,%ax
  801d5f:	90                   	nop

00801d60 <_pgfault_upcall>:
  801d60:	54                   	push   %esp
  801d61:	a1 00 60 80 00       	mov    0x806000,%eax
  801d66:	ff d0                	call   *%eax
  801d68:	83 c4 04             	add    $0x4,%esp
  801d6b:	83 c4 08             	add    $0x8,%esp
  801d6e:	8b 44 24 28          	mov    0x28(%esp),%eax
  801d72:	83 e8 04             	sub    $0x4,%eax
  801d75:	89 44 24 28          	mov    %eax,0x28(%esp)
  801d79:	8b 5c 24 20          	mov    0x20(%esp),%ebx
  801d7d:	89 18                	mov    %ebx,(%eax)
  801d7f:	61                   	popa   
  801d80:	83 c4 04             	add    $0x4,%esp
  801d83:	9d                   	popf   
  801d84:	5c                   	pop    %esp
  801d85:	c3                   	ret    
  801d86:	66 90                	xchg   %ax,%ax
  801d88:	66 90                	xchg   %ax,%ax
  801d8a:	66 90                	xchg   %ax,%ax
  801d8c:	66 90                	xchg   %ax,%ax
  801d8e:	66 90                	xchg   %ax,%ax

00801d90 <__udivdi3>:
  801d90:	83 ec 1c             	sub    $0x1c,%esp
  801d93:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801d97:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801d9b:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801d9f:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801da3:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801da7:	8b 6c 24 24          	mov    0x24(%esp),%ebp
  801dab:	85 c0                	test   %eax,%eax
  801dad:	89 74 24 10          	mov    %esi,0x10(%esp)
  801db1:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801db5:	89 ea                	mov    %ebp,%edx
  801db7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801dbb:	75 33                	jne    801df0 <__udivdi3+0x60>
  801dbd:	39 e9                	cmp    %ebp,%ecx
  801dbf:	77 6f                	ja     801e30 <__udivdi3+0xa0>
  801dc1:	85 c9                	test   %ecx,%ecx
  801dc3:	89 ce                	mov    %ecx,%esi
  801dc5:	75 0b                	jne    801dd2 <__udivdi3+0x42>
  801dc7:	b8 01 00 00 00       	mov    $0x1,%eax
  801dcc:	31 d2                	xor    %edx,%edx
  801dce:	f7 f1                	div    %ecx
  801dd0:	89 c6                	mov    %eax,%esi
  801dd2:	31 d2                	xor    %edx,%edx
  801dd4:	89 e8                	mov    %ebp,%eax
  801dd6:	f7 f6                	div    %esi
  801dd8:	89 c5                	mov    %eax,%ebp
  801dda:	89 f8                	mov    %edi,%eax
  801ddc:	f7 f6                	div    %esi
  801dde:	89 ea                	mov    %ebp,%edx
  801de0:	8b 74 24 10          	mov    0x10(%esp),%esi
  801de4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801de8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801dec:	83 c4 1c             	add    $0x1c,%esp
  801def:	c3                   	ret    
  801df0:	39 e8                	cmp    %ebp,%eax
  801df2:	77 24                	ja     801e18 <__udivdi3+0x88>
  801df4:	0f bd c8             	bsr    %eax,%ecx
  801df7:	83 f1 1f             	xor    $0x1f,%ecx
  801dfa:	89 0c 24             	mov    %ecx,(%esp)
  801dfd:	75 49                	jne    801e48 <__udivdi3+0xb8>
  801dff:	8b 74 24 08          	mov    0x8(%esp),%esi
  801e03:	39 74 24 04          	cmp    %esi,0x4(%esp)
  801e07:	0f 86 ab 00 00 00    	jbe    801eb8 <__udivdi3+0x128>
  801e0d:	39 e8                	cmp    %ebp,%eax
  801e0f:	0f 82 a3 00 00 00    	jb     801eb8 <__udivdi3+0x128>
  801e15:	8d 76 00             	lea    0x0(%esi),%esi
  801e18:	31 d2                	xor    %edx,%edx
  801e1a:	31 c0                	xor    %eax,%eax
  801e1c:	8b 74 24 10          	mov    0x10(%esp),%esi
  801e20:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801e24:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801e28:	83 c4 1c             	add    $0x1c,%esp
  801e2b:	c3                   	ret    
  801e2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e30:	89 f8                	mov    %edi,%eax
  801e32:	f7 f1                	div    %ecx
  801e34:	31 d2                	xor    %edx,%edx
  801e36:	8b 74 24 10          	mov    0x10(%esp),%esi
  801e3a:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801e3e:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801e42:	83 c4 1c             	add    $0x1c,%esp
  801e45:	c3                   	ret    
  801e46:	66 90                	xchg   %ax,%ax
  801e48:	0f b6 0c 24          	movzbl (%esp),%ecx
  801e4c:	89 c6                	mov    %eax,%esi
  801e4e:	b8 20 00 00 00       	mov    $0x20,%eax
  801e53:	8b 6c 24 04          	mov    0x4(%esp),%ebp
  801e57:	2b 04 24             	sub    (%esp),%eax
  801e5a:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801e5e:	d3 e6                	shl    %cl,%esi
  801e60:	89 c1                	mov    %eax,%ecx
  801e62:	d3 ed                	shr    %cl,%ebp
  801e64:	0f b6 0c 24          	movzbl (%esp),%ecx
  801e68:	09 f5                	or     %esi,%ebp
  801e6a:	8b 74 24 04          	mov    0x4(%esp),%esi
  801e6e:	d3 e6                	shl    %cl,%esi
  801e70:	89 c1                	mov    %eax,%ecx
  801e72:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e76:	89 d6                	mov    %edx,%esi
  801e78:	d3 ee                	shr    %cl,%esi
  801e7a:	0f b6 0c 24          	movzbl (%esp),%ecx
  801e7e:	d3 e2                	shl    %cl,%edx
  801e80:	89 c1                	mov    %eax,%ecx
  801e82:	d3 ef                	shr    %cl,%edi
  801e84:	09 d7                	or     %edx,%edi
  801e86:	89 f2                	mov    %esi,%edx
  801e88:	89 f8                	mov    %edi,%eax
  801e8a:	f7 f5                	div    %ebp
  801e8c:	89 d6                	mov    %edx,%esi
  801e8e:	89 c7                	mov    %eax,%edi
  801e90:	f7 64 24 04          	mull   0x4(%esp)
  801e94:	39 d6                	cmp    %edx,%esi
  801e96:	72 30                	jb     801ec8 <__udivdi3+0x138>
  801e98:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801e9c:	0f b6 0c 24          	movzbl (%esp),%ecx
  801ea0:	d3 e5                	shl    %cl,%ebp
  801ea2:	39 c5                	cmp    %eax,%ebp
  801ea4:	73 04                	jae    801eaa <__udivdi3+0x11a>
  801ea6:	39 d6                	cmp    %edx,%esi
  801ea8:	74 1e                	je     801ec8 <__udivdi3+0x138>
  801eaa:	89 f8                	mov    %edi,%eax
  801eac:	31 d2                	xor    %edx,%edx
  801eae:	e9 69 ff ff ff       	jmp    801e1c <__udivdi3+0x8c>
  801eb3:	90                   	nop
  801eb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801eb8:	31 d2                	xor    %edx,%edx
  801eba:	b8 01 00 00 00       	mov    $0x1,%eax
  801ebf:	e9 58 ff ff ff       	jmp    801e1c <__udivdi3+0x8c>
  801ec4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ec8:	8d 47 ff             	lea    -0x1(%edi),%eax
  801ecb:	31 d2                	xor    %edx,%edx
  801ecd:	8b 74 24 10          	mov    0x10(%esp),%esi
  801ed1:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801ed5:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801ed9:	83 c4 1c             	add    $0x1c,%esp
  801edc:	c3                   	ret    
  801edd:	66 90                	xchg   %ax,%ax
  801edf:	90                   	nop

00801ee0 <__umoddi3>:
  801ee0:	83 ec 2c             	sub    $0x2c,%esp
  801ee3:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801ee7:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801eeb:	89 74 24 20          	mov    %esi,0x20(%esp)
  801eef:	8b 74 24 38          	mov    0x38(%esp),%esi
  801ef3:	89 7c 24 24          	mov    %edi,0x24(%esp)
  801ef7:	8b 7c 24 34          	mov    0x34(%esp),%edi
  801efb:	85 c0                	test   %eax,%eax
  801efd:	89 c2                	mov    %eax,%edx
  801eff:	89 6c 24 28          	mov    %ebp,0x28(%esp)
  801f03:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801f07:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801f0b:	89 74 24 10          	mov    %esi,0x10(%esp)
  801f0f:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801f13:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801f17:	75 1f                	jne    801f38 <__umoddi3+0x58>
  801f19:	39 fe                	cmp    %edi,%esi
  801f1b:	76 63                	jbe    801f80 <__umoddi3+0xa0>
  801f1d:	89 c8                	mov    %ecx,%eax
  801f1f:	89 fa                	mov    %edi,%edx
  801f21:	f7 f6                	div    %esi
  801f23:	89 d0                	mov    %edx,%eax
  801f25:	31 d2                	xor    %edx,%edx
  801f27:	8b 74 24 20          	mov    0x20(%esp),%esi
  801f2b:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801f2f:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801f33:	83 c4 2c             	add    $0x2c,%esp
  801f36:	c3                   	ret    
  801f37:	90                   	nop
  801f38:	39 f8                	cmp    %edi,%eax
  801f3a:	77 64                	ja     801fa0 <__umoddi3+0xc0>
  801f3c:	0f bd e8             	bsr    %eax,%ebp
  801f3f:	83 f5 1f             	xor    $0x1f,%ebp
  801f42:	75 74                	jne    801fb8 <__umoddi3+0xd8>
  801f44:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801f48:	39 7c 24 10          	cmp    %edi,0x10(%esp)
  801f4c:	0f 87 0e 01 00 00    	ja     802060 <__umoddi3+0x180>
  801f52:	8b 7c 24 0c          	mov    0xc(%esp),%edi
  801f56:	29 f1                	sub    %esi,%ecx
  801f58:	19 c7                	sbb    %eax,%edi
  801f5a:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801f5e:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801f62:	8b 44 24 14          	mov    0x14(%esp),%eax
  801f66:	8b 54 24 18          	mov    0x18(%esp),%edx
  801f6a:	8b 74 24 20          	mov    0x20(%esp),%esi
  801f6e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801f72:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801f76:	83 c4 2c             	add    $0x2c,%esp
  801f79:	c3                   	ret    
  801f7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f80:	85 f6                	test   %esi,%esi
  801f82:	89 f5                	mov    %esi,%ebp
  801f84:	75 0b                	jne    801f91 <__umoddi3+0xb1>
  801f86:	b8 01 00 00 00       	mov    $0x1,%eax
  801f8b:	31 d2                	xor    %edx,%edx
  801f8d:	f7 f6                	div    %esi
  801f8f:	89 c5                	mov    %eax,%ebp
  801f91:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801f95:	31 d2                	xor    %edx,%edx
  801f97:	f7 f5                	div    %ebp
  801f99:	89 c8                	mov    %ecx,%eax
  801f9b:	f7 f5                	div    %ebp
  801f9d:	eb 84                	jmp    801f23 <__umoddi3+0x43>
  801f9f:	90                   	nop
  801fa0:	89 c8                	mov    %ecx,%eax
  801fa2:	89 fa                	mov    %edi,%edx
  801fa4:	8b 74 24 20          	mov    0x20(%esp),%esi
  801fa8:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801fac:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801fb0:	83 c4 2c             	add    $0x2c,%esp
  801fb3:	c3                   	ret    
  801fb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fb8:	8b 44 24 10          	mov    0x10(%esp),%eax
  801fbc:	be 20 00 00 00       	mov    $0x20,%esi
  801fc1:	89 e9                	mov    %ebp,%ecx
  801fc3:	29 ee                	sub    %ebp,%esi
  801fc5:	d3 e2                	shl    %cl,%edx
  801fc7:	89 f1                	mov    %esi,%ecx
  801fc9:	d3 e8                	shr    %cl,%eax
  801fcb:	89 e9                	mov    %ebp,%ecx
  801fcd:	09 d0                	or     %edx,%eax
  801fcf:	89 fa                	mov    %edi,%edx
  801fd1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fd5:	8b 44 24 10          	mov    0x10(%esp),%eax
  801fd9:	d3 e0                	shl    %cl,%eax
  801fdb:	89 f1                	mov    %esi,%ecx
  801fdd:	89 44 24 10          	mov    %eax,0x10(%esp)
  801fe1:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801fe5:	d3 ea                	shr    %cl,%edx
  801fe7:	89 e9                	mov    %ebp,%ecx
  801fe9:	d3 e7                	shl    %cl,%edi
  801feb:	89 f1                	mov    %esi,%ecx
  801fed:	d3 e8                	shr    %cl,%eax
  801fef:	89 e9                	mov    %ebp,%ecx
  801ff1:	09 f8                	or     %edi,%eax
  801ff3:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801ff7:	f7 74 24 0c          	divl   0xc(%esp)
  801ffb:	d3 e7                	shl    %cl,%edi
  801ffd:	89 7c 24 18          	mov    %edi,0x18(%esp)
  802001:	89 d7                	mov    %edx,%edi
  802003:	f7 64 24 10          	mull   0x10(%esp)
  802007:	39 d7                	cmp    %edx,%edi
  802009:	89 c1                	mov    %eax,%ecx
  80200b:	89 54 24 14          	mov    %edx,0x14(%esp)
  80200f:	72 3b                	jb     80204c <__umoddi3+0x16c>
  802011:	39 44 24 18          	cmp    %eax,0x18(%esp)
  802015:	72 31                	jb     802048 <__umoddi3+0x168>
  802017:	8b 44 24 18          	mov    0x18(%esp),%eax
  80201b:	29 c8                	sub    %ecx,%eax
  80201d:	19 d7                	sbb    %edx,%edi
  80201f:	89 e9                	mov    %ebp,%ecx
  802021:	89 fa                	mov    %edi,%edx
  802023:	d3 e8                	shr    %cl,%eax
  802025:	89 f1                	mov    %esi,%ecx
  802027:	d3 e2                	shl    %cl,%edx
  802029:	89 e9                	mov    %ebp,%ecx
  80202b:	09 d0                	or     %edx,%eax
  80202d:	89 fa                	mov    %edi,%edx
  80202f:	d3 ea                	shr    %cl,%edx
  802031:	8b 74 24 20          	mov    0x20(%esp),%esi
  802035:	8b 7c 24 24          	mov    0x24(%esp),%edi
  802039:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  80203d:	83 c4 2c             	add    $0x2c,%esp
  802040:	c3                   	ret    
  802041:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802048:	39 d7                	cmp    %edx,%edi
  80204a:	75 cb                	jne    802017 <__umoddi3+0x137>
  80204c:	8b 54 24 14          	mov    0x14(%esp),%edx
  802050:	89 c1                	mov    %eax,%ecx
  802052:	2b 4c 24 10          	sub    0x10(%esp),%ecx
  802056:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  80205a:	eb bb                	jmp    802017 <__umoddi3+0x137>
  80205c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802060:	3b 44 24 18          	cmp    0x18(%esp),%eax
  802064:	0f 82 e8 fe ff ff    	jb     801f52 <__umoddi3+0x72>
  80206a:	e9 f3 fe ff ff       	jmp    801f62 <__umoddi3+0x82>
