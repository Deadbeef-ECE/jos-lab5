
obj/user/faultalloc.debug:     file format elf32-i386


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

00800034 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 24             	sub    $0x24,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003b:	8b 45 08             	mov    0x8(%ebp),%eax
  80003e:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  800040:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800044:	c7 04 24 c0 1d 80 00 	movl   $0x801dc0,(%esp)
  80004b:	e8 0f 02 00 00       	call   80025f <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  800050:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800057:	00 
  800058:	89 d8                	mov    %ebx,%eax
  80005a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800063:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80006a:	e8 ba 0d 00 00       	call   800e29 <sys_page_alloc>
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 24                	jns    800097 <handler+0x63>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800073:	89 44 24 10          	mov    %eax,0x10(%esp)
  800077:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80007b:	c7 44 24 08 e0 1d 80 	movl   $0x801de0,0x8(%esp)
  800082:	00 
  800083:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
  80008a:	00 
  80008b:	c7 04 24 ca 1d 80 00 	movl   $0x801dca,(%esp)
  800092:	e8 cd 00 00 00       	call   800164 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800097:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80009b:	c7 44 24 08 0c 1e 80 	movl   $0x801e0c,0x8(%esp)
  8000a2:	00 
  8000a3:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000aa:	00 
  8000ab:	89 1c 24             	mov    %ebx,(%esp)
  8000ae:	e8 96 07 00 00       	call   800849 <snprintf>
}
  8000b3:	83 c4 24             	add    $0x24,%esp
  8000b6:	5b                   	pop    %ebx
  8000b7:	5d                   	pop    %ebp
  8000b8:	c3                   	ret    

008000b9 <umain>:

void
umain(int argc, char **argv)
{
  8000b9:	55                   	push   %ebp
  8000ba:	89 e5                	mov    %esp,%ebp
  8000bc:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  8000bf:	c7 04 24 34 00 80 00 	movl   $0x800034,(%esp)
  8000c6:	e8 6d 10 00 00       	call   801138 <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000cb:	c7 44 24 04 ef be ad 	movl   $0xdeadbeef,0x4(%esp)
  8000d2:	de 
  8000d3:	c7 04 24 dc 1d 80 00 	movl   $0x801ddc,(%esp)
  8000da:	e8 80 01 00 00       	call   80025f <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000df:	c7 44 24 04 fe bf fe 	movl   $0xcafebffe,0x4(%esp)
  8000e6:	ca 
  8000e7:	c7 04 24 dc 1d 80 00 	movl   $0x801ddc,(%esp)
  8000ee:	e8 6c 01 00 00       	call   80025f <cprintf>
}
  8000f3:	c9                   	leave  
  8000f4:	c3                   	ret    
  8000f5:	66 90                	xchg   %ax,%ax
  8000f7:	90                   	nop

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
  80010a:	e8 a8 0c 00 00       	call   800db7 <sys_getenvid>
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
  800133:	e8 81 ff ff ff       	call   8000b9 <umain>

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
  80014e:	e8 80 12 00 00       	call   8013d3 <close_all>
	sys_env_destroy(0);
  800153:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80015a:	e8 f2 0b 00 00       	call   800d51 <sys_env_destroy>
}
  80015f:	c9                   	leave  
  800160:	c3                   	ret    
  800161:	66 90                	xchg   %ax,%ax
  800163:	90                   	nop

00800164 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	56                   	push   %esi
  800168:	53                   	push   %ebx
  800169:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80016c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80016f:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800175:	e8 3d 0c 00 00       	call   800db7 <sys_getenvid>
  80017a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80017d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800181:	8b 55 08             	mov    0x8(%ebp),%edx
  800184:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800188:	89 74 24 08          	mov    %esi,0x8(%esp)
  80018c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800190:	c7 04 24 38 1e 80 00 	movl   $0x801e38,(%esp)
  800197:	e8 c3 00 00 00       	call   80025f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80019c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001a0:	8b 45 10             	mov    0x10(%ebp),%eax
  8001a3:	89 04 24             	mov    %eax,(%esp)
  8001a6:	e8 53 00 00 00       	call   8001fe <vcprintf>
	cprintf("\n");
  8001ab:	c7 04 24 bd 22 80 00 	movl   $0x8022bd,(%esp)
  8001b2:	e8 a8 00 00 00       	call   80025f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001b7:	cc                   	int3   
  8001b8:	eb fd                	jmp    8001b7 <_panic+0x53>
  8001ba:	66 90                	xchg   %ax,%ax

008001bc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	53                   	push   %ebx
  8001c0:	83 ec 14             	sub    $0x14,%esp
  8001c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001c6:	8b 03                	mov    (%ebx),%eax
  8001c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001cb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001cf:	83 c0 01             	add    $0x1,%eax
  8001d2:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001d4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001d9:	75 19                	jne    8001f4 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001db:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001e2:	00 
  8001e3:	8d 43 08             	lea    0x8(%ebx),%eax
  8001e6:	89 04 24             	mov    %eax,(%esp)
  8001e9:	e8 f2 0a 00 00       	call   800ce0 <sys_cputs>
		b->idx = 0;
  8001ee:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001f4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001f8:	83 c4 14             	add    $0x14,%esp
  8001fb:	5b                   	pop    %ebx
  8001fc:	5d                   	pop    %ebp
  8001fd:	c3                   	ret    

008001fe <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001fe:	55                   	push   %ebp
  8001ff:	89 e5                	mov    %esp,%ebp
  800201:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800207:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80020e:	00 00 00 
	b.cnt = 0;
  800211:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800218:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80021b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80021e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800222:	8b 45 08             	mov    0x8(%ebp),%eax
  800225:	89 44 24 08          	mov    %eax,0x8(%esp)
  800229:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80022f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800233:	c7 04 24 bc 01 80 00 	movl   $0x8001bc,(%esp)
  80023a:	e8 b3 01 00 00       	call   8003f2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80023f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800245:	89 44 24 04          	mov    %eax,0x4(%esp)
  800249:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80024f:	89 04 24             	mov    %eax,(%esp)
  800252:	e8 89 0a 00 00       	call   800ce0 <sys_cputs>

	return b.cnt;
}
  800257:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80025d:	c9                   	leave  
  80025e:	c3                   	ret    

0080025f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80025f:	55                   	push   %ebp
  800260:	89 e5                	mov    %esp,%ebp
  800262:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800265:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800268:	89 44 24 04          	mov    %eax,0x4(%esp)
  80026c:	8b 45 08             	mov    0x8(%ebp),%eax
  80026f:	89 04 24             	mov    %eax,(%esp)
  800272:	e8 87 ff ff ff       	call   8001fe <vcprintf>
	va_end(ap);

	return cnt;
}
  800277:	c9                   	leave  
  800278:	c3                   	ret    
  800279:	66 90                	xchg   %ax,%ax
  80027b:	66 90                	xchg   %ax,%ax
  80027d:	66 90                	xchg   %ax,%ax
  80027f:	90                   	nop

00800280 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	57                   	push   %edi
  800284:	56                   	push   %esi
  800285:	53                   	push   %ebx
  800286:	83 ec 4c             	sub    $0x4c,%esp
  800289:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80028c:	89 d7                	mov    %edx,%edi
  80028e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800291:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800294:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800297:	89 5d dc             	mov    %ebx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80029a:	b8 00 00 00 00       	mov    $0x0,%eax
  80029f:	39 d8                	cmp    %ebx,%eax
  8002a1:	72 17                	jb     8002ba <printnum+0x3a>
  8002a3:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8002a6:	39 5d 10             	cmp    %ebx,0x10(%ebp)
  8002a9:	76 0f                	jbe    8002ba <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002ab:	8b 75 14             	mov    0x14(%ebp),%esi
  8002ae:	83 ee 01             	sub    $0x1,%esi
  8002b1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8002b4:	85 f6                	test   %esi,%esi
  8002b6:	7f 63                	jg     80031b <printnum+0x9b>
  8002b8:	eb 75                	jmp    80032f <printnum+0xaf>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002ba:	8b 5d 18             	mov    0x18(%ebp),%ebx
  8002bd:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8002c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8002c4:	83 e8 01             	sub    $0x1,%eax
  8002c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002cb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002d2:	8b 44 24 08          	mov    0x8(%esp),%eax
  8002d6:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002da:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002dd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8002e0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002e7:	00 
  8002e8:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8002eb:	89 1c 24             	mov    %ebx,(%esp)
  8002ee:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002f1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002f5:	e8 e6 17 00 00       	call   801ae0 <__udivdi3>
  8002fa:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8002fd:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800300:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800304:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800308:	89 04 24             	mov    %eax,(%esp)
  80030b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80030f:	89 fa                	mov    %edi,%edx
  800311:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800314:	e8 67 ff ff ff       	call   800280 <printnum>
  800319:	eb 14                	jmp    80032f <printnum+0xaf>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80031b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80031f:	8b 45 18             	mov    0x18(%ebp),%eax
  800322:	89 04 24             	mov    %eax,(%esp)
  800325:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800327:	83 ee 01             	sub    $0x1,%esi
  80032a:	75 ef                	jne    80031b <printnum+0x9b>
  80032c:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80032f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800333:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800337:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80033a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80033e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800345:	00 
  800346:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800349:	89 1c 24             	mov    %ebx,(%esp)
  80034c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80034f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800353:	e8 d8 18 00 00       	call   801c30 <__umoddi3>
  800358:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80035c:	0f be 80 5b 1e 80 00 	movsbl 0x801e5b(%eax),%eax
  800363:	89 04 24             	mov    %eax,(%esp)
  800366:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800369:	ff d0                	call   *%eax
}
  80036b:	83 c4 4c             	add    $0x4c,%esp
  80036e:	5b                   	pop    %ebx
  80036f:	5e                   	pop    %esi
  800370:	5f                   	pop    %edi
  800371:	5d                   	pop    %ebp
  800372:	c3                   	ret    

00800373 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800373:	55                   	push   %ebp
  800374:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800376:	83 fa 01             	cmp    $0x1,%edx
  800379:	7e 0e                	jle    800389 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80037b:	8b 10                	mov    (%eax),%edx
  80037d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800380:	89 08                	mov    %ecx,(%eax)
  800382:	8b 02                	mov    (%edx),%eax
  800384:	8b 52 04             	mov    0x4(%edx),%edx
  800387:	eb 22                	jmp    8003ab <getuint+0x38>
	else if (lflag)
  800389:	85 d2                	test   %edx,%edx
  80038b:	74 10                	je     80039d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80038d:	8b 10                	mov    (%eax),%edx
  80038f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800392:	89 08                	mov    %ecx,(%eax)
  800394:	8b 02                	mov    (%edx),%eax
  800396:	ba 00 00 00 00       	mov    $0x0,%edx
  80039b:	eb 0e                	jmp    8003ab <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80039d:	8b 10                	mov    (%eax),%edx
  80039f:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a2:	89 08                	mov    %ecx,(%eax)
  8003a4:	8b 02                	mov    (%edx),%eax
  8003a6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003ab:	5d                   	pop    %ebp
  8003ac:	c3                   	ret    

008003ad <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003ad:	55                   	push   %ebp
  8003ae:	89 e5                	mov    %esp,%ebp
  8003b0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003b3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003b7:	8b 10                	mov    (%eax),%edx
  8003b9:	3b 50 04             	cmp    0x4(%eax),%edx
  8003bc:	73 0a                	jae    8003c8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003be:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003c1:	88 0a                	mov    %cl,(%edx)
  8003c3:	83 c2 01             	add    $0x1,%edx
  8003c6:	89 10                	mov    %edx,(%eax)
}
  8003c8:	5d                   	pop    %ebp
  8003c9:	c3                   	ret    

008003ca <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
  8003cd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003d0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003d7:	8b 45 10             	mov    0x10(%ebp),%eax
  8003da:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e8:	89 04 24             	mov    %eax,(%esp)
  8003eb:	e8 02 00 00 00       	call   8003f2 <vprintfmt>
	va_end(ap);
}
  8003f0:	c9                   	leave  
  8003f1:	c3                   	ret    

008003f2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003f2:	55                   	push   %ebp
  8003f3:	89 e5                	mov    %esp,%ebp
  8003f5:	57                   	push   %edi
  8003f6:	56                   	push   %esi
  8003f7:	53                   	push   %ebx
  8003f8:	83 ec 4c             	sub    $0x4c,%esp
  8003fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8003fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800401:	8b 7d 10             	mov    0x10(%ebp),%edi
  800404:	eb 11                	jmp    800417 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800406:	85 c0                	test   %eax,%eax
  800408:	0f 84 db 03 00 00    	je     8007e9 <vprintfmt+0x3f7>
				return;
			putch(ch, putdat);
  80040e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800412:	89 04 24             	mov    %eax,(%esp)
  800415:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800417:	0f b6 07             	movzbl (%edi),%eax
  80041a:	83 c7 01             	add    $0x1,%edi
  80041d:	83 f8 25             	cmp    $0x25,%eax
  800420:	75 e4                	jne    800406 <vprintfmt+0x14>
  800422:	c6 45 e4 20          	movb   $0x20,-0x1c(%ebp)
  800426:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80042d:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800434:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80043b:	ba 00 00 00 00       	mov    $0x0,%edx
  800440:	eb 2b                	jmp    80046d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800442:	8b 7d e0             	mov    -0x20(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800445:	c6 45 e4 2d          	movb   $0x2d,-0x1c(%ebp)
  800449:	eb 22                	jmp    80046d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044b:	8b 7d e0             	mov    -0x20(%ebp),%edi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80044e:	c6 45 e4 30          	movb   $0x30,-0x1c(%ebp)
  800452:	eb 19                	jmp    80046d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800454:	8b 7d e0             	mov    -0x20(%ebp),%edi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800457:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80045e:	eb 0d                	jmp    80046d <vprintfmt+0x7b>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800460:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800463:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800466:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046d:	0f b6 0f             	movzbl (%edi),%ecx
  800470:	8d 47 01             	lea    0x1(%edi),%eax
  800473:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800476:	0f b6 07             	movzbl (%edi),%eax
  800479:	83 e8 23             	sub    $0x23,%eax
  80047c:	3c 55                	cmp    $0x55,%al
  80047e:	0f 87 40 03 00 00    	ja     8007c4 <vprintfmt+0x3d2>
  800484:	0f b6 c0             	movzbl %al,%eax
  800487:	ff 24 85 a0 1f 80 00 	jmp    *0x801fa0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80048e:	83 e9 30             	sub    $0x30,%ecx
  800491:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				ch = *fmt;
  800494:	0f be 47 01          	movsbl 0x1(%edi),%eax
				if (ch < '0' || ch > '9')
  800498:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80049b:	83 f9 09             	cmp    $0x9,%ecx
  80049e:	77 57                	ja     8004f7 <vprintfmt+0x105>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a0:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8004a3:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004a6:	8b 55 dc             	mov    -0x24(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004a9:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8004ac:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8004af:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8004b3:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8004b6:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8004b9:	83 f9 09             	cmp    $0x9,%ecx
  8004bc:	76 eb                	jbe    8004a9 <vprintfmt+0xb7>
  8004be:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004c1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004c4:	eb 34                	jmp    8004fa <vprintfmt+0x108>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c9:	8d 48 04             	lea    0x4(%eax),%ecx
  8004cc:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004cf:	8b 00                	mov    (%eax),%eax
  8004d1:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d4:	8b 7d e0             	mov    -0x20(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004d7:	eb 21                	jmp    8004fa <vprintfmt+0x108>

		case '.':
			if (width < 0)
  8004d9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004dd:	0f 88 71 ff ff ff    	js     800454 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e3:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8004e6:	eb 85                	jmp    80046d <vprintfmt+0x7b>
  8004e8:	8b 7d e0             	mov    -0x20(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004eb:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  8004f2:	e9 76 ff ff ff       	jmp    80046d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f7:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8004fa:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004fe:	0f 89 69 ff ff ff    	jns    80046d <vprintfmt+0x7b>
  800504:	e9 57 ff ff ff       	jmp    800460 <vprintfmt+0x6e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800509:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80050f:	e9 59 ff ff ff       	jmp    80046d <vprintfmt+0x7b>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800514:	8b 45 14             	mov    0x14(%ebp),%eax
  800517:	8d 50 04             	lea    0x4(%eax),%edx
  80051a:	89 55 14             	mov    %edx,0x14(%ebp)
  80051d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800521:	8b 00                	mov    (%eax),%eax
  800523:	89 04 24             	mov    %eax,(%esp)
  800526:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800528:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80052b:	e9 e7 fe ff ff       	jmp    800417 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800530:	8b 45 14             	mov    0x14(%ebp),%eax
  800533:	8d 50 04             	lea    0x4(%eax),%edx
  800536:	89 55 14             	mov    %edx,0x14(%ebp)
  800539:	8b 00                	mov    (%eax),%eax
  80053b:	89 c2                	mov    %eax,%edx
  80053d:	c1 fa 1f             	sar    $0x1f,%edx
  800540:	31 d0                	xor    %edx,%eax
  800542:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800544:	83 f8 0f             	cmp    $0xf,%eax
  800547:	7f 0b                	jg     800554 <vprintfmt+0x162>
  800549:	8b 14 85 00 21 80 00 	mov    0x802100(,%eax,4),%edx
  800550:	85 d2                	test   %edx,%edx
  800552:	75 20                	jne    800574 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  800554:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800558:	c7 44 24 08 73 1e 80 	movl   $0x801e73,0x8(%esp)
  80055f:	00 
  800560:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800564:	89 34 24             	mov    %esi,(%esp)
  800567:	e8 5e fe ff ff       	call   8003ca <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056c:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80056f:	e9 a3 fe ff ff       	jmp    800417 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800574:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800578:	c7 44 24 08 7c 1e 80 	movl   $0x801e7c,0x8(%esp)
  80057f:	00 
  800580:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800584:	89 34 24             	mov    %esi,(%esp)
  800587:	e8 3e fe ff ff       	call   8003ca <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058c:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80058f:	e9 83 fe ff ff       	jmp    800417 <vprintfmt+0x25>
  800594:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800597:	8b 7d d8             	mov    -0x28(%ebp),%edi
  80059a:	89 7d cc             	mov    %edi,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80059d:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a0:	8d 50 04             	lea    0x4(%eax),%edx
  8005a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005a8:	85 ff                	test   %edi,%edi
  8005aa:	b8 6c 1e 80 00       	mov    $0x801e6c,%eax
  8005af:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005b2:	80 7d e4 2d          	cmpb   $0x2d,-0x1c(%ebp)
  8005b6:	74 06                	je     8005be <vprintfmt+0x1cc>
  8005b8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8005bc:	7f 16                	jg     8005d4 <vprintfmt+0x1e2>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005be:	0f b6 17             	movzbl (%edi),%edx
  8005c1:	0f be c2             	movsbl %dl,%eax
  8005c4:	83 c7 01             	add    $0x1,%edi
  8005c7:	85 c0                	test   %eax,%eax
  8005c9:	0f 85 9f 00 00 00    	jne    80066e <vprintfmt+0x27c>
  8005cf:	e9 8b 00 00 00       	jmp    80065f <vprintfmt+0x26d>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005d8:	89 3c 24             	mov    %edi,(%esp)
  8005db:	e8 c2 02 00 00       	call   8008a2 <strnlen>
  8005e0:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8005e3:	29 c2                	sub    %eax,%edx
  8005e5:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8005e8:	85 d2                	test   %edx,%edx
  8005ea:	7e d2                	jle    8005be <vprintfmt+0x1cc>
					putch(padc, putdat);
  8005ec:	0f be 4d e4          	movsbl -0x1c(%ebp),%ecx
  8005f0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8005f3:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8005f6:	89 d7                	mov    %edx,%edi
  8005f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005ff:	89 04 24             	mov    %eax,(%esp)
  800602:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800604:	83 ef 01             	sub    $0x1,%edi
  800607:	75 ef                	jne    8005f8 <vprintfmt+0x206>
  800609:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80060c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80060f:	eb ad                	jmp    8005be <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800611:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800615:	74 20                	je     800637 <vprintfmt+0x245>
  800617:	0f be d2             	movsbl %dl,%edx
  80061a:	83 ea 20             	sub    $0x20,%edx
  80061d:	83 fa 5e             	cmp    $0x5e,%edx
  800620:	76 15                	jbe    800637 <vprintfmt+0x245>
					putch('?', putdat);
  800622:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800625:	89 54 24 04          	mov    %edx,0x4(%esp)
  800629:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800630:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800633:	ff d1                	call   *%ecx
  800635:	eb 0f                	jmp    800646 <vprintfmt+0x254>
				else
					putch(ch, putdat);
  800637:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80063a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80063e:	89 04 24             	mov    %eax,(%esp)
  800641:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800644:	ff d1                	call   *%ecx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800646:	83 eb 01             	sub    $0x1,%ebx
  800649:	0f b6 17             	movzbl (%edi),%edx
  80064c:	0f be c2             	movsbl %dl,%eax
  80064f:	83 c7 01             	add    $0x1,%edi
  800652:	85 c0                	test   %eax,%eax
  800654:	75 24                	jne    80067a <vprintfmt+0x288>
  800656:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800659:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80065c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065f:	8b 7d e0             	mov    -0x20(%ebp),%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800662:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800666:	0f 8e ab fd ff ff    	jle    800417 <vprintfmt+0x25>
  80066c:	eb 20                	jmp    80068e <vprintfmt+0x29c>
  80066e:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800671:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800674:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  800677:	8b 5d d8             	mov    -0x28(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80067a:	85 f6                	test   %esi,%esi
  80067c:	78 93                	js     800611 <vprintfmt+0x21f>
  80067e:	83 ee 01             	sub    $0x1,%esi
  800681:	79 8e                	jns    800611 <vprintfmt+0x21f>
  800683:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800686:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800689:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80068c:	eb d1                	jmp    80065f <vprintfmt+0x26d>
  80068e:	8b 7d d8             	mov    -0x28(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800691:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800695:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80069c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80069e:	83 ef 01             	sub    $0x1,%edi
  8006a1:	75 ee                	jne    800691 <vprintfmt+0x29f>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a3:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8006a6:	e9 6c fd ff ff       	jmp    800417 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006ab:	83 fa 01             	cmp    $0x1,%edx
  8006ae:	66 90                	xchg   %ax,%ax
  8006b0:	7e 16                	jle    8006c8 <vprintfmt+0x2d6>
		return va_arg(*ap, long long);
  8006b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b5:	8d 50 08             	lea    0x8(%eax),%edx
  8006b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006bb:	8b 10                	mov    (%eax),%edx
  8006bd:	8b 48 04             	mov    0x4(%eax),%ecx
  8006c0:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8006c3:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8006c6:	eb 32                	jmp    8006fa <vprintfmt+0x308>
	else if (lflag)
  8006c8:	85 d2                	test   %edx,%edx
  8006ca:	74 18                	je     8006e4 <vprintfmt+0x2f2>
		return va_arg(*ap, long);
  8006cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cf:	8d 50 04             	lea    0x4(%eax),%edx
  8006d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d5:	8b 00                	mov    (%eax),%eax
  8006d7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006da:	89 c1                	mov    %eax,%ecx
  8006dc:	c1 f9 1f             	sar    $0x1f,%ecx
  8006df:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8006e2:	eb 16                	jmp    8006fa <vprintfmt+0x308>
	else
		return va_arg(*ap, int);
  8006e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e7:	8d 50 04             	lea    0x4(%eax),%edx
  8006ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ed:	8b 00                	mov    (%eax),%eax
  8006ef:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006f2:	89 c7                	mov    %eax,%edi
  8006f4:	c1 ff 1f             	sar    $0x1f,%edi
  8006f7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006fa:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8006fd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800700:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800705:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800709:	79 7d                	jns    800788 <vprintfmt+0x396>
				putch('-', putdat);
  80070b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80070f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800716:	ff d6                	call   *%esi
				num = -(long long) num;
  800718:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80071b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80071e:	f7 d8                	neg    %eax
  800720:	83 d2 00             	adc    $0x0,%edx
  800723:	f7 da                	neg    %edx
			}
			base = 10;
  800725:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80072a:	eb 5c                	jmp    800788 <vprintfmt+0x396>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80072c:	8d 45 14             	lea    0x14(%ebp),%eax
  80072f:	e8 3f fc ff ff       	call   800373 <getuint>
			base = 10;
  800734:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800739:	eb 4d                	jmp    800788 <vprintfmt+0x396>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80073b:	8d 45 14             	lea    0x14(%ebp),%eax
  80073e:	e8 30 fc ff ff       	call   800373 <getuint>
			base = 8;
  800743:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800748:	eb 3e                	jmp    800788 <vprintfmt+0x396>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80074a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80074e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800755:	ff d6                	call   *%esi
			putch('x', putdat);
  800757:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80075b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800762:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800764:	8b 45 14             	mov    0x14(%ebp),%eax
  800767:	8d 50 04             	lea    0x4(%eax),%edx
  80076a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80076d:	8b 00                	mov    (%eax),%eax
  80076f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800774:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800779:	eb 0d                	jmp    800788 <vprintfmt+0x396>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80077b:	8d 45 14             	lea    0x14(%ebp),%eax
  80077e:	e8 f0 fb ff ff       	call   800373 <getuint>
			base = 16;
  800783:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800788:	0f be 7d e4          	movsbl -0x1c(%ebp),%edi
  80078c:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800790:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800793:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800797:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80079b:	89 04 24             	mov    %eax,(%esp)
  80079e:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007a2:	89 da                	mov    %ebx,%edx
  8007a4:	89 f0                	mov    %esi,%eax
  8007a6:	e8 d5 fa ff ff       	call   800280 <printnum>
			break;
  8007ab:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8007ae:	e9 64 fc ff ff       	jmp    800417 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007b3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007b7:	89 0c 24             	mov    %ecx,(%esp)
  8007ba:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007bc:	8b 7d e0             	mov    -0x20(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007bf:	e9 53 fc ff ff       	jmp    800417 <vprintfmt+0x25>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007c8:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007cf:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007d1:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007d5:	0f 84 3c fc ff ff    	je     800417 <vprintfmt+0x25>
  8007db:	83 ef 01             	sub    $0x1,%edi
  8007de:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007e2:	75 f7                	jne    8007db <vprintfmt+0x3e9>
  8007e4:	e9 2e fc ff ff       	jmp    800417 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8007e9:	83 c4 4c             	add    $0x4c,%esp
  8007ec:	5b                   	pop    %ebx
  8007ed:	5e                   	pop    %esi
  8007ee:	5f                   	pop    %edi
  8007ef:	5d                   	pop    %ebp
  8007f0:	c3                   	ret    

008007f1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007f1:	55                   	push   %ebp
  8007f2:	89 e5                	mov    %esp,%ebp
  8007f4:	83 ec 28             	sub    $0x28,%esp
  8007f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fa:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007fd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800800:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800804:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800807:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80080e:	85 d2                	test   %edx,%edx
  800810:	7e 30                	jle    800842 <vsnprintf+0x51>
  800812:	85 c0                	test   %eax,%eax
  800814:	74 2c                	je     800842 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800816:	8b 45 14             	mov    0x14(%ebp),%eax
  800819:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80081d:	8b 45 10             	mov    0x10(%ebp),%eax
  800820:	89 44 24 08          	mov    %eax,0x8(%esp)
  800824:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800827:	89 44 24 04          	mov    %eax,0x4(%esp)
  80082b:	c7 04 24 ad 03 80 00 	movl   $0x8003ad,(%esp)
  800832:	e8 bb fb ff ff       	call   8003f2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800837:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80083a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80083d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800840:	eb 05                	jmp    800847 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800842:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800847:	c9                   	leave  
  800848:	c3                   	ret    

00800849 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800849:	55                   	push   %ebp
  80084a:	89 e5                	mov    %esp,%ebp
  80084c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80084f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800852:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800856:	8b 45 10             	mov    0x10(%ebp),%eax
  800859:	89 44 24 08          	mov    %eax,0x8(%esp)
  80085d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800860:	89 44 24 04          	mov    %eax,0x4(%esp)
  800864:	8b 45 08             	mov    0x8(%ebp),%eax
  800867:	89 04 24             	mov    %eax,(%esp)
  80086a:	e8 82 ff ff ff       	call   8007f1 <vsnprintf>
	va_end(ap);

	return rc;
}
  80086f:	c9                   	leave  
  800870:	c3                   	ret    
  800871:	66 90                	xchg   %ax,%ax
  800873:	66 90                	xchg   %ax,%ax
  800875:	66 90                	xchg   %ax,%ax
  800877:	66 90                	xchg   %ax,%ax
  800879:	66 90                	xchg   %ax,%ax
  80087b:	66 90                	xchg   %ax,%ax
  80087d:	66 90                	xchg   %ax,%ax
  80087f:	90                   	nop

00800880 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800886:	80 3a 00             	cmpb   $0x0,(%edx)
  800889:	74 10                	je     80089b <strlen+0x1b>
  80088b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800890:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800893:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800897:	75 f7                	jne    800890 <strlen+0x10>
  800899:	eb 05                	jmp    8008a0 <strlen+0x20>
  80089b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8008a0:	5d                   	pop    %ebp
  8008a1:	c3                   	ret    

008008a2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	53                   	push   %ebx
  8008a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008ac:	85 c9                	test   %ecx,%ecx
  8008ae:	74 1c                	je     8008cc <strnlen+0x2a>
  8008b0:	80 3b 00             	cmpb   $0x0,(%ebx)
  8008b3:	74 1e                	je     8008d3 <strnlen+0x31>
  8008b5:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8008ba:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008bc:	39 ca                	cmp    %ecx,%edx
  8008be:	74 18                	je     8008d8 <strnlen+0x36>
  8008c0:	83 c2 01             	add    $0x1,%edx
  8008c3:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8008c8:	75 f0                	jne    8008ba <strnlen+0x18>
  8008ca:	eb 0c                	jmp    8008d8 <strnlen+0x36>
  8008cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d1:	eb 05                	jmp    8008d8 <strnlen+0x36>
  8008d3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8008d8:	5b                   	pop    %ebx
  8008d9:	5d                   	pop    %ebp
  8008da:	c3                   	ret    

008008db <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	53                   	push   %ebx
  8008df:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008e5:	89 c2                	mov    %eax,%edx
  8008e7:	0f b6 19             	movzbl (%ecx),%ebx
  8008ea:	88 1a                	mov    %bl,(%edx)
  8008ec:	83 c2 01             	add    $0x1,%edx
  8008ef:	83 c1 01             	add    $0x1,%ecx
  8008f2:	84 db                	test   %bl,%bl
  8008f4:	75 f1                	jne    8008e7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008f6:	5b                   	pop    %ebx
  8008f7:	5d                   	pop    %ebp
  8008f8:	c3                   	ret    

008008f9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008f9:	55                   	push   %ebp
  8008fa:	89 e5                	mov    %esp,%ebp
  8008fc:	53                   	push   %ebx
  8008fd:	83 ec 08             	sub    $0x8,%esp
  800900:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800903:	89 1c 24             	mov    %ebx,(%esp)
  800906:	e8 75 ff ff ff       	call   800880 <strlen>
	strcpy(dst + len, src);
  80090b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80090e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800912:	01 d8                	add    %ebx,%eax
  800914:	89 04 24             	mov    %eax,(%esp)
  800917:	e8 bf ff ff ff       	call   8008db <strcpy>
	return dst;
}
  80091c:	89 d8                	mov    %ebx,%eax
  80091e:	83 c4 08             	add    $0x8,%esp
  800921:	5b                   	pop    %ebx
  800922:	5d                   	pop    %ebp
  800923:	c3                   	ret    

00800924 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800924:	55                   	push   %ebp
  800925:	89 e5                	mov    %esp,%ebp
  800927:	56                   	push   %esi
  800928:	53                   	push   %ebx
  800929:	8b 75 08             	mov    0x8(%ebp),%esi
  80092c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80092f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800932:	85 db                	test   %ebx,%ebx
  800934:	74 16                	je     80094c <strncpy+0x28>
	strcpy(dst + len, src);
	return dst;
}

char *
strncpy(char *dst, const char *src, size_t size) {
  800936:	01 f3                	add    %esi,%ebx
  800938:	89 f1                	mov    %esi,%ecx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  80093a:	0f b6 02             	movzbl (%edx),%eax
  80093d:	88 01                	mov    %al,(%ecx)
  80093f:	83 c1 01             	add    $0x1,%ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800942:	80 3a 01             	cmpb   $0x1,(%edx)
  800945:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800948:	39 d9                	cmp    %ebx,%ecx
  80094a:	75 ee                	jne    80093a <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80094c:	89 f0                	mov    %esi,%eax
  80094e:	5b                   	pop    %ebx
  80094f:	5e                   	pop    %esi
  800950:	5d                   	pop    %ebp
  800951:	c3                   	ret    

00800952 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800952:	55                   	push   %ebp
  800953:	89 e5                	mov    %esp,%ebp
  800955:	57                   	push   %edi
  800956:	56                   	push   %esi
  800957:	53                   	push   %ebx
  800958:	8b 7d 08             	mov    0x8(%ebp),%edi
  80095b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80095e:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800961:	89 f8                	mov    %edi,%eax
  800963:	85 f6                	test   %esi,%esi
  800965:	74 33                	je     80099a <strlcpy+0x48>
		while (--size > 0 && *src != '\0')
  800967:	83 fe 01             	cmp    $0x1,%esi
  80096a:	74 25                	je     800991 <strlcpy+0x3f>
  80096c:	0f b6 0b             	movzbl (%ebx),%ecx
  80096f:	84 c9                	test   %cl,%cl
  800971:	74 22                	je     800995 <strlcpy+0x43>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800973:	83 ee 02             	sub    $0x2,%esi
  800976:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80097b:	88 08                	mov    %cl,(%eax)
  80097d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800980:	39 f2                	cmp    %esi,%edx
  800982:	74 13                	je     800997 <strlcpy+0x45>
  800984:	83 c2 01             	add    $0x1,%edx
  800987:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80098b:	84 c9                	test   %cl,%cl
  80098d:	75 ec                	jne    80097b <strlcpy+0x29>
  80098f:	eb 06                	jmp    800997 <strlcpy+0x45>
  800991:	89 f8                	mov    %edi,%eax
  800993:	eb 02                	jmp    800997 <strlcpy+0x45>
  800995:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800997:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80099a:	29 f8                	sub    %edi,%eax
}
  80099c:	5b                   	pop    %ebx
  80099d:	5e                   	pop    %esi
  80099e:	5f                   	pop    %edi
  80099f:	5d                   	pop    %ebp
  8009a0:	c3                   	ret    

008009a1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009aa:	0f b6 01             	movzbl (%ecx),%eax
  8009ad:	84 c0                	test   %al,%al
  8009af:	74 15                	je     8009c6 <strcmp+0x25>
  8009b1:	3a 02                	cmp    (%edx),%al
  8009b3:	75 11                	jne    8009c6 <strcmp+0x25>
		p++, q++;
  8009b5:	83 c1 01             	add    $0x1,%ecx
  8009b8:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009bb:	0f b6 01             	movzbl (%ecx),%eax
  8009be:	84 c0                	test   %al,%al
  8009c0:	74 04                	je     8009c6 <strcmp+0x25>
  8009c2:	3a 02                	cmp    (%edx),%al
  8009c4:	74 ef                	je     8009b5 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009c6:	0f b6 c0             	movzbl %al,%eax
  8009c9:	0f b6 12             	movzbl (%edx),%edx
  8009cc:	29 d0                	sub    %edx,%eax
}
  8009ce:	5d                   	pop    %ebp
  8009cf:	c3                   	ret    

008009d0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009d0:	55                   	push   %ebp
  8009d1:	89 e5                	mov    %esp,%ebp
  8009d3:	56                   	push   %esi
  8009d4:	53                   	push   %ebx
  8009d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009db:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  8009de:	85 f6                	test   %esi,%esi
  8009e0:	74 29                	je     800a0b <strncmp+0x3b>
  8009e2:	0f b6 03             	movzbl (%ebx),%eax
  8009e5:	84 c0                	test   %al,%al
  8009e7:	74 30                	je     800a19 <strncmp+0x49>
  8009e9:	3a 02                	cmp    (%edx),%al
  8009eb:	75 2c                	jne    800a19 <strncmp+0x49>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}

int
strncmp(const char *p, const char *q, size_t n)
  8009ed:	8d 43 01             	lea    0x1(%ebx),%eax
  8009f0:	01 de                	add    %ebx,%esi
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  8009f2:	89 c3                	mov    %eax,%ebx
  8009f4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009f7:	39 f0                	cmp    %esi,%eax
  8009f9:	74 17                	je     800a12 <strncmp+0x42>
  8009fb:	0f b6 08             	movzbl (%eax),%ecx
  8009fe:	84 c9                	test   %cl,%cl
  800a00:	74 17                	je     800a19 <strncmp+0x49>
  800a02:	83 c0 01             	add    $0x1,%eax
  800a05:	3a 0a                	cmp    (%edx),%cl
  800a07:	74 e9                	je     8009f2 <strncmp+0x22>
  800a09:	eb 0e                	jmp    800a19 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a0b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a10:	eb 0f                	jmp    800a21 <strncmp+0x51>
  800a12:	b8 00 00 00 00       	mov    $0x0,%eax
  800a17:	eb 08                	jmp    800a21 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a19:	0f b6 03             	movzbl (%ebx),%eax
  800a1c:	0f b6 12             	movzbl (%edx),%edx
  800a1f:	29 d0                	sub    %edx,%eax
}
  800a21:	5b                   	pop    %ebx
  800a22:	5e                   	pop    %esi
  800a23:	5d                   	pop    %ebp
  800a24:	c3                   	ret    

00800a25 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a25:	55                   	push   %ebp
  800a26:	89 e5                	mov    %esp,%ebp
  800a28:	53                   	push   %ebx
  800a29:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2c:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800a2f:	0f b6 18             	movzbl (%eax),%ebx
  800a32:	84 db                	test   %bl,%bl
  800a34:	74 1d                	je     800a53 <strchr+0x2e>
  800a36:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800a38:	38 d3                	cmp    %dl,%bl
  800a3a:	75 06                	jne    800a42 <strchr+0x1d>
  800a3c:	eb 1a                	jmp    800a58 <strchr+0x33>
  800a3e:	38 ca                	cmp    %cl,%dl
  800a40:	74 16                	je     800a58 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a42:	83 c0 01             	add    $0x1,%eax
  800a45:	0f b6 10             	movzbl (%eax),%edx
  800a48:	84 d2                	test   %dl,%dl
  800a4a:	75 f2                	jne    800a3e <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800a4c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a51:	eb 05                	jmp    800a58 <strchr+0x33>
  800a53:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a58:	5b                   	pop    %ebx
  800a59:	5d                   	pop    %ebp
  800a5a:	c3                   	ret    

00800a5b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	53                   	push   %ebx
  800a5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a62:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800a65:	0f b6 18             	movzbl (%eax),%ebx
  800a68:	84 db                	test   %bl,%bl
  800a6a:	74 16                	je     800a82 <strfind+0x27>
  800a6c:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800a6e:	38 d3                	cmp    %dl,%bl
  800a70:	75 06                	jne    800a78 <strfind+0x1d>
  800a72:	eb 0e                	jmp    800a82 <strfind+0x27>
  800a74:	38 ca                	cmp    %cl,%dl
  800a76:	74 0a                	je     800a82 <strfind+0x27>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a78:	83 c0 01             	add    $0x1,%eax
  800a7b:	0f b6 10             	movzbl (%eax),%edx
  800a7e:	84 d2                	test   %dl,%dl
  800a80:	75 f2                	jne    800a74 <strfind+0x19>
		if (*s == c)
			break;
	return (char *) s;
}
  800a82:	5b                   	pop    %ebx
  800a83:	5d                   	pop    %ebp
  800a84:	c3                   	ret    

00800a85 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a85:	55                   	push   %ebp
  800a86:	89 e5                	mov    %esp,%ebp
  800a88:	83 ec 0c             	sub    $0xc,%esp
  800a8b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800a8e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800a91:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800a94:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a97:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a9a:	85 c9                	test   %ecx,%ecx
  800a9c:	74 36                	je     800ad4 <memset+0x4f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a9e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aa4:	75 28                	jne    800ace <memset+0x49>
  800aa6:	f6 c1 03             	test   $0x3,%cl
  800aa9:	75 23                	jne    800ace <memset+0x49>
		c &= 0xFF;
  800aab:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800aaf:	89 d3                	mov    %edx,%ebx
  800ab1:	c1 e3 08             	shl    $0x8,%ebx
  800ab4:	89 d6                	mov    %edx,%esi
  800ab6:	c1 e6 18             	shl    $0x18,%esi
  800ab9:	89 d0                	mov    %edx,%eax
  800abb:	c1 e0 10             	shl    $0x10,%eax
  800abe:	09 f0                	or     %esi,%eax
  800ac0:	09 c2                	or     %eax,%edx
  800ac2:	89 d0                	mov    %edx,%eax
  800ac4:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ac6:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ac9:	fc                   	cld    
  800aca:	f3 ab                	rep stos %eax,%es:(%edi)
  800acc:	eb 06                	jmp    800ad4 <memset+0x4f>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ace:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad1:	fc                   	cld    
  800ad2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");

	return v;
}
  800ad4:	89 f8                	mov    %edi,%eax
  800ad6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ad9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800adc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800adf:	89 ec                	mov    %ebp,%esp
  800ae1:	5d                   	pop    %ebp
  800ae2:	c3                   	ret    

00800ae3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ae3:	55                   	push   %ebp
  800ae4:	89 e5                	mov    %esp,%ebp
  800ae6:	83 ec 08             	sub    $0x8,%esp
  800ae9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800aec:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800aef:	8b 45 08             	mov    0x8(%ebp),%eax
  800af2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800af5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800af8:	39 c6                	cmp    %eax,%esi
  800afa:	73 36                	jae    800b32 <memmove+0x4f>
  800afc:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800aff:	39 d0                	cmp    %edx,%eax
  800b01:	73 2f                	jae    800b32 <memmove+0x4f>
		s += n;
		d += n;
  800b03:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b06:	f6 c2 03             	test   $0x3,%dl
  800b09:	75 1b                	jne    800b26 <memmove+0x43>
  800b0b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b11:	75 13                	jne    800b26 <memmove+0x43>
  800b13:	f6 c1 03             	test   $0x3,%cl
  800b16:	75 0e                	jne    800b26 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b18:	83 ef 04             	sub    $0x4,%edi
  800b1b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b1e:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b21:	fd                   	std    
  800b22:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b24:	eb 09                	jmp    800b2f <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b26:	83 ef 01             	sub    $0x1,%edi
  800b29:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b2c:	fd                   	std    
  800b2d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b2f:	fc                   	cld    
  800b30:	eb 20                	jmp    800b52 <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b32:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b38:	75 13                	jne    800b4d <memmove+0x6a>
  800b3a:	a8 03                	test   $0x3,%al
  800b3c:	75 0f                	jne    800b4d <memmove+0x6a>
  800b3e:	f6 c1 03             	test   $0x3,%cl
  800b41:	75 0a                	jne    800b4d <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b43:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b46:	89 c7                	mov    %eax,%edi
  800b48:	fc                   	cld    
  800b49:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b4b:	eb 05                	jmp    800b52 <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b4d:	89 c7                	mov    %eax,%edi
  800b4f:	fc                   	cld    
  800b50:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b52:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b55:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b58:	89 ec                	mov    %ebp,%esp
  800b5a:	5d                   	pop    %ebp
  800b5b:	c3                   	ret    

00800b5c <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b62:	8b 45 10             	mov    0x10(%ebp),%eax
  800b65:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b69:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b6c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b70:	8b 45 08             	mov    0x8(%ebp),%eax
  800b73:	89 04 24             	mov    %eax,(%esp)
  800b76:	e8 68 ff ff ff       	call   800ae3 <memmove>
}
  800b7b:	c9                   	leave  
  800b7c:	c3                   	ret    

00800b7d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	57                   	push   %edi
  800b81:	56                   	push   %esi
  800b82:	53                   	push   %ebx
  800b83:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b86:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b89:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b8c:	8d 78 ff             	lea    -0x1(%eax),%edi
  800b8f:	85 c0                	test   %eax,%eax
  800b91:	74 36                	je     800bc9 <memcmp+0x4c>
		if (*s1 != *s2)
  800b93:	0f b6 03             	movzbl (%ebx),%eax
  800b96:	0f b6 0e             	movzbl (%esi),%ecx
  800b99:	38 c8                	cmp    %cl,%al
  800b9b:	75 17                	jne    800bb4 <memcmp+0x37>
  800b9d:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba2:	eb 1a                	jmp    800bbe <memcmp+0x41>
  800ba4:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800ba9:	83 c2 01             	add    $0x1,%edx
  800bac:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800bb0:	38 c8                	cmp    %cl,%al
  800bb2:	74 0a                	je     800bbe <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800bb4:	0f b6 c0             	movzbl %al,%eax
  800bb7:	0f b6 c9             	movzbl %cl,%ecx
  800bba:	29 c8                	sub    %ecx,%eax
  800bbc:	eb 10                	jmp    800bce <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bbe:	39 fa                	cmp    %edi,%edx
  800bc0:	75 e2                	jne    800ba4 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bc2:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc7:	eb 05                	jmp    800bce <memcmp+0x51>
  800bc9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bce:	5b                   	pop    %ebx
  800bcf:	5e                   	pop    %esi
  800bd0:	5f                   	pop    %edi
  800bd1:	5d                   	pop    %ebp
  800bd2:	c3                   	ret    

00800bd3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bd3:	55                   	push   %ebp
  800bd4:	89 e5                	mov    %esp,%ebp
  800bd6:	53                   	push   %ebx
  800bd7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bda:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800bdd:	89 c2                	mov    %eax,%edx
  800bdf:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800be2:	39 d0                	cmp    %edx,%eax
  800be4:	73 13                	jae    800bf9 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800be6:	89 d9                	mov    %ebx,%ecx
  800be8:	38 18                	cmp    %bl,(%eax)
  800bea:	75 06                	jne    800bf2 <memfind+0x1f>
  800bec:	eb 0b                	jmp    800bf9 <memfind+0x26>
  800bee:	38 08                	cmp    %cl,(%eax)
  800bf0:	74 07                	je     800bf9 <memfind+0x26>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bf2:	83 c0 01             	add    $0x1,%eax
  800bf5:	39 d0                	cmp    %edx,%eax
  800bf7:	75 f5                	jne    800bee <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bf9:	5b                   	pop    %ebx
  800bfa:	5d                   	pop    %ebp
  800bfb:	c3                   	ret    

00800bfc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	57                   	push   %edi
  800c00:	56                   	push   %esi
  800c01:	53                   	push   %ebx
  800c02:	83 ec 04             	sub    $0x4,%esp
  800c05:	8b 55 08             	mov    0x8(%ebp),%edx
  800c08:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c0b:	0f b6 02             	movzbl (%edx),%eax
  800c0e:	3c 09                	cmp    $0x9,%al
  800c10:	74 04                	je     800c16 <strtol+0x1a>
  800c12:	3c 20                	cmp    $0x20,%al
  800c14:	75 0e                	jne    800c24 <strtol+0x28>
		s++;
  800c16:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c19:	0f b6 02             	movzbl (%edx),%eax
  800c1c:	3c 09                	cmp    $0x9,%al
  800c1e:	74 f6                	je     800c16 <strtol+0x1a>
  800c20:	3c 20                	cmp    $0x20,%al
  800c22:	74 f2                	je     800c16 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c24:	3c 2b                	cmp    $0x2b,%al
  800c26:	75 0a                	jne    800c32 <strtol+0x36>
		s++;
  800c28:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c2b:	bf 00 00 00 00       	mov    $0x0,%edi
  800c30:	eb 10                	jmp    800c42 <strtol+0x46>
  800c32:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c37:	3c 2d                	cmp    $0x2d,%al
  800c39:	75 07                	jne    800c42 <strtol+0x46>
		s++, neg = 1;
  800c3b:	83 c2 01             	add    $0x1,%edx
  800c3e:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c42:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c48:	75 15                	jne    800c5f <strtol+0x63>
  800c4a:	80 3a 30             	cmpb   $0x30,(%edx)
  800c4d:	75 10                	jne    800c5f <strtol+0x63>
  800c4f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c53:	75 0a                	jne    800c5f <strtol+0x63>
		s += 2, base = 16;
  800c55:	83 c2 02             	add    $0x2,%edx
  800c58:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c5d:	eb 10                	jmp    800c6f <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800c5f:	85 db                	test   %ebx,%ebx
  800c61:	75 0c                	jne    800c6f <strtol+0x73>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c63:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c65:	80 3a 30             	cmpb   $0x30,(%edx)
  800c68:	75 05                	jne    800c6f <strtol+0x73>
		s++, base = 8;
  800c6a:	83 c2 01             	add    $0x1,%edx
  800c6d:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800c6f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c74:	89 5d f0             	mov    %ebx,-0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c77:	0f b6 0a             	movzbl (%edx),%ecx
  800c7a:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800c7d:	89 f3                	mov    %esi,%ebx
  800c7f:	80 fb 09             	cmp    $0x9,%bl
  800c82:	77 08                	ja     800c8c <strtol+0x90>
			dig = *s - '0';
  800c84:	0f be c9             	movsbl %cl,%ecx
  800c87:	83 e9 30             	sub    $0x30,%ecx
  800c8a:	eb 22                	jmp    800cae <strtol+0xb2>
		else if (*s >= 'a' && *s <= 'z')
  800c8c:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800c8f:	89 f3                	mov    %esi,%ebx
  800c91:	80 fb 19             	cmp    $0x19,%bl
  800c94:	77 08                	ja     800c9e <strtol+0xa2>
			dig = *s - 'a' + 10;
  800c96:	0f be c9             	movsbl %cl,%ecx
  800c99:	83 e9 57             	sub    $0x57,%ecx
  800c9c:	eb 10                	jmp    800cae <strtol+0xb2>
		else if (*s >= 'A' && *s <= 'Z')
  800c9e:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800ca1:	89 f3                	mov    %esi,%ebx
  800ca3:	80 fb 19             	cmp    $0x19,%bl
  800ca6:	77 16                	ja     800cbe <strtol+0xc2>
			dig = *s - 'A' + 10;
  800ca8:	0f be c9             	movsbl %cl,%ecx
  800cab:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800cae:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800cb1:	7d 0f                	jge    800cc2 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800cb3:	83 c2 01             	add    $0x1,%edx
  800cb6:	0f af 45 f0          	imul   -0x10(%ebp),%eax
  800cba:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800cbc:	eb b9                	jmp    800c77 <strtol+0x7b>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800cbe:	89 c1                	mov    %eax,%ecx
  800cc0:	eb 02                	jmp    800cc4 <strtol+0xc8>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800cc2:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800cc4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cc8:	74 05                	je     800ccf <strtol+0xd3>
		*endptr = (char *) s;
  800cca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ccd:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ccf:	89 ca                	mov    %ecx,%edx
  800cd1:	f7 da                	neg    %edx
  800cd3:	85 ff                	test   %edi,%edi
  800cd5:	0f 45 c2             	cmovne %edx,%eax
}
  800cd8:	83 c4 04             	add    $0x4,%esp
  800cdb:	5b                   	pop    %ebx
  800cdc:	5e                   	pop    %esi
  800cdd:	5f                   	pop    %edi
  800cde:	5d                   	pop    %ebp
  800cdf:	c3                   	ret    

00800ce0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ce0:	55                   	push   %ebp
  800ce1:	89 e5                	mov    %esp,%ebp
  800ce3:	83 ec 0c             	sub    $0xc,%esp
  800ce6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ce9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cec:	89 7d fc             	mov    %edi,-0x4(%ebp)
static inline uint32_t

get_cpu_features(void)
{
	uint32_t feature;
	__asm __volatile(" movl $1, %%eax\n\t"
  800cef:	b8 01 00 00 00       	mov    $0x1,%eax
  800cf4:	0f a2                	cpuid  
  800cf6:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf8:	b8 00 00 00 00       	mov    $0x0,%eax
  800cfd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d00:	8b 55 08             	mov    0x8(%ebp),%edx
  800d03:	89 c3                	mov    %eax,%ebx
  800d05:	89 c7                	mov    %eax,%edi
  800d07:	89 c6                	mov    %eax,%esi
  800d09:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d0b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d0e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d11:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d14:	89 ec                	mov    %ebp,%esp
  800d16:	5d                   	pop    %ebp
  800d17:	c3                   	ret    

00800d18 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d18:	55                   	push   %ebp
  800d19:	89 e5                	mov    %esp,%ebp
  800d1b:	83 ec 0c             	sub    $0xc,%esp
  800d1e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d21:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d24:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d27:	b8 01 00 00 00       	mov    $0x1,%eax
  800d2c:	0f a2                	cpuid  
  800d2e:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d30:	ba 00 00 00 00       	mov    $0x0,%edx
  800d35:	b8 01 00 00 00       	mov    $0x1,%eax
  800d3a:	89 d1                	mov    %edx,%ecx
  800d3c:	89 d3                	mov    %edx,%ebx
  800d3e:	89 d7                	mov    %edx,%edi
  800d40:	89 d6                	mov    %edx,%esi
  800d42:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d44:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d47:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d4a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d4d:	89 ec                	mov    %ebp,%esp
  800d4f:	5d                   	pop    %ebp
  800d50:	c3                   	ret    

00800d51 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d51:	55                   	push   %ebp
  800d52:	89 e5                	mov    %esp,%ebp
  800d54:	83 ec 38             	sub    $0x38,%esp
  800d57:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d5a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d5d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d60:	b8 01 00 00 00       	mov    $0x1,%eax
  800d65:	0f a2                	cpuid  
  800d67:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d69:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d6e:	b8 03 00 00 00       	mov    $0x3,%eax
  800d73:	8b 55 08             	mov    0x8(%ebp),%edx
  800d76:	89 cb                	mov    %ecx,%ebx
  800d78:	89 cf                	mov    %ecx,%edi
  800d7a:	89 ce                	mov    %ecx,%esi
  800d7c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d7e:	85 c0                	test   %eax,%eax
  800d80:	7e 28                	jle    800daa <sys_env_destroy+0x59>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d82:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d86:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800d8d:	00 
  800d8e:	c7 44 24 08 5f 21 80 	movl   $0x80215f,0x8(%esp)
  800d95:	00 
  800d96:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800d9d:	00 
  800d9e:	c7 04 24 7c 21 80 00 	movl   $0x80217c,(%esp)
  800da5:	e8 ba f3 ff ff       	call   800164 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800daa:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dad:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800db0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800db3:	89 ec                	mov    %ebp,%esp
  800db5:	5d                   	pop    %ebp
  800db6:	c3                   	ret    

00800db7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800db7:	55                   	push   %ebp
  800db8:	89 e5                	mov    %esp,%ebp
  800dba:	83 ec 0c             	sub    $0xc,%esp
  800dbd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dc0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dc3:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800dc6:	b8 01 00 00 00       	mov    $0x1,%eax
  800dcb:	0f a2                	cpuid  
  800dcd:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcf:	ba 00 00 00 00       	mov    $0x0,%edx
  800dd4:	b8 02 00 00 00       	mov    $0x2,%eax
  800dd9:	89 d1                	mov    %edx,%ecx
  800ddb:	89 d3                	mov    %edx,%ebx
  800ddd:	89 d7                	mov    %edx,%edi
  800ddf:	89 d6                	mov    %edx,%esi
  800de1:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800de3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800de6:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800de9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dec:	89 ec                	mov    %ebp,%esp
  800dee:	5d                   	pop    %ebp
  800def:	c3                   	ret    

00800df0 <sys_yield>:

void
sys_yield(void)
{
  800df0:	55                   	push   %ebp
  800df1:	89 e5                	mov    %esp,%ebp
  800df3:	83 ec 0c             	sub    $0xc,%esp
  800df6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800df9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dfc:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800dff:	b8 01 00 00 00       	mov    $0x1,%eax
  800e04:	0f a2                	cpuid  
  800e06:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e08:	ba 00 00 00 00       	mov    $0x0,%edx
  800e0d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e12:	89 d1                	mov    %edx,%ecx
  800e14:	89 d3                	mov    %edx,%ebx
  800e16:	89 d7                	mov    %edx,%edi
  800e18:	89 d6                	mov    %edx,%esi
  800e1a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e1c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e1f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e22:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e25:	89 ec                	mov    %ebp,%esp
  800e27:	5d                   	pop    %ebp
  800e28:	c3                   	ret    

00800e29 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	83 ec 38             	sub    $0x38,%esp
  800e2f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e32:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e35:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e38:	b8 01 00 00 00       	mov    $0x1,%eax
  800e3d:	0f a2                	cpuid  
  800e3f:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e41:	be 00 00 00 00       	mov    $0x0,%esi
  800e46:	b8 04 00 00 00       	mov    $0x4,%eax
  800e4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e51:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e54:	89 f7                	mov    %esi,%edi
  800e56:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e58:	85 c0                	test   %eax,%eax
  800e5a:	7e 28                	jle    800e84 <sys_page_alloc+0x5b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e5c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e60:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800e67:	00 
  800e68:	c7 44 24 08 5f 21 80 	movl   $0x80215f,0x8(%esp)
  800e6f:	00 
  800e70:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800e77:	00 
  800e78:	c7 04 24 7c 21 80 00 	movl   $0x80217c,(%esp)
  800e7f:	e8 e0 f2 ff ff       	call   800164 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e84:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e87:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e8a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e8d:	89 ec                	mov    %ebp,%esp
  800e8f:	5d                   	pop    %ebp
  800e90:	c3                   	ret    

00800e91 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e91:	55                   	push   %ebp
  800e92:	89 e5                	mov    %esp,%ebp
  800e94:	83 ec 38             	sub    $0x38,%esp
  800e97:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e9a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e9d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800ea0:	b8 01 00 00 00       	mov    $0x1,%eax
  800ea5:	0f a2                	cpuid  
  800ea7:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea9:	b8 05 00 00 00       	mov    $0x5,%eax
  800eae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb1:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eb7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800eba:	8b 75 18             	mov    0x18(%ebp),%esi
  800ebd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ebf:	85 c0                	test   %eax,%eax
  800ec1:	7e 28                	jle    800eeb <sys_page_map+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ec7:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800ece:	00 
  800ecf:	c7 44 24 08 5f 21 80 	movl   $0x80215f,0x8(%esp)
  800ed6:	00 
  800ed7:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800ede:	00 
  800edf:	c7 04 24 7c 21 80 00 	movl   $0x80217c,(%esp)
  800ee6:	e8 79 f2 ff ff       	call   800164 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800eeb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800eee:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ef1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ef4:	89 ec                	mov    %ebp,%esp
  800ef6:	5d                   	pop    %ebp
  800ef7:	c3                   	ret    

00800ef8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ef8:	55                   	push   %ebp
  800ef9:	89 e5                	mov    %esp,%ebp
  800efb:	83 ec 38             	sub    $0x38,%esp
  800efe:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f01:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f04:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800f07:	b8 01 00 00 00       	mov    $0x1,%eax
  800f0c:	0f a2                	cpuid  
  800f0e:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f10:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f15:	b8 06 00 00 00       	mov    $0x6,%eax
  800f1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f20:	89 df                	mov    %ebx,%edi
  800f22:	89 de                	mov    %ebx,%esi
  800f24:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f26:	85 c0                	test   %eax,%eax
  800f28:	7e 28                	jle    800f52 <sys_page_unmap+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f2a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f2e:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f35:	00 
  800f36:	c7 44 24 08 5f 21 80 	movl   $0x80215f,0x8(%esp)
  800f3d:	00 
  800f3e:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800f45:	00 
  800f46:	c7 04 24 7c 21 80 00 	movl   $0x80217c,(%esp)
  800f4d:	e8 12 f2 ff ff       	call   800164 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f52:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f55:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f58:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f5b:	89 ec                	mov    %ebp,%esp
  800f5d:	5d                   	pop    %ebp
  800f5e:	c3                   	ret    

00800f5f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f5f:	55                   	push   %ebp
  800f60:	89 e5                	mov    %esp,%ebp
  800f62:	83 ec 38             	sub    $0x38,%esp
  800f65:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f68:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f6b:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800f6e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f73:	0f a2                	cpuid  
  800f75:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f77:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f7c:	b8 08 00 00 00       	mov    $0x8,%eax
  800f81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f84:	8b 55 08             	mov    0x8(%ebp),%edx
  800f87:	89 df                	mov    %ebx,%edi
  800f89:	89 de                	mov    %ebx,%esi
  800f8b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f8d:	85 c0                	test   %eax,%eax
  800f8f:	7e 28                	jle    800fb9 <sys_env_set_status+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f91:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f95:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800f9c:	00 
  800f9d:	c7 44 24 08 5f 21 80 	movl   $0x80215f,0x8(%esp)
  800fa4:	00 
  800fa5:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800fac:	00 
  800fad:	c7 04 24 7c 21 80 00 	movl   $0x80217c,(%esp)
  800fb4:	e8 ab f1 ff ff       	call   800164 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800fb9:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fbc:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fbf:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fc2:	89 ec                	mov    %ebp,%esp
  800fc4:	5d                   	pop    %ebp
  800fc5:	c3                   	ret    

00800fc6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800fc6:	55                   	push   %ebp
  800fc7:	89 e5                	mov    %esp,%ebp
  800fc9:	83 ec 38             	sub    $0x38,%esp
  800fcc:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fcf:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fd2:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800fd5:	b8 01 00 00 00       	mov    $0x1,%eax
  800fda:	0f a2                	cpuid  
  800fdc:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fde:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fe3:	b8 09 00 00 00       	mov    $0x9,%eax
  800fe8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800feb:	8b 55 08             	mov    0x8(%ebp),%edx
  800fee:	89 df                	mov    %ebx,%edi
  800ff0:	89 de                	mov    %ebx,%esi
  800ff2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ff4:	85 c0                	test   %eax,%eax
  800ff6:	7e 28                	jle    801020 <sys_env_set_trapframe+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ff8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ffc:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801003:	00 
  801004:	c7 44 24 08 5f 21 80 	movl   $0x80215f,0x8(%esp)
  80100b:	00 
  80100c:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  801013:	00 
  801014:	c7 04 24 7c 21 80 00 	movl   $0x80217c,(%esp)
  80101b:	e8 44 f1 ff ff       	call   800164 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801020:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801023:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801026:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801029:	89 ec                	mov    %ebp,%esp
  80102b:	5d                   	pop    %ebp
  80102c:	c3                   	ret    

0080102d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80102d:	55                   	push   %ebp
  80102e:	89 e5                	mov    %esp,%ebp
  801030:	83 ec 38             	sub    $0x38,%esp
  801033:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801036:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801039:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80103c:	b8 01 00 00 00       	mov    $0x1,%eax
  801041:	0f a2                	cpuid  
  801043:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801045:	bb 00 00 00 00       	mov    $0x0,%ebx
  80104a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80104f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801052:	8b 55 08             	mov    0x8(%ebp),%edx
  801055:	89 df                	mov    %ebx,%edi
  801057:	89 de                	mov    %ebx,%esi
  801059:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80105b:	85 c0                	test   %eax,%eax
  80105d:	7e 28                	jle    801087 <sys_env_set_pgfault_upcall+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80105f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801063:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80106a:	00 
  80106b:	c7 44 24 08 5f 21 80 	movl   $0x80215f,0x8(%esp)
  801072:	00 
  801073:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  80107a:	00 
  80107b:	c7 04 24 7c 21 80 00 	movl   $0x80217c,(%esp)
  801082:	e8 dd f0 ff ff       	call   800164 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801087:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80108a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80108d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801090:	89 ec                	mov    %ebp,%esp
  801092:	5d                   	pop    %ebp
  801093:	c3                   	ret    

00801094 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801094:	55                   	push   %ebp
  801095:	89 e5                	mov    %esp,%ebp
  801097:	83 ec 0c             	sub    $0xc,%esp
  80109a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80109d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010a0:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8010a3:	b8 01 00 00 00       	mov    $0x1,%eax
  8010a8:	0f a2                	cpuid  
  8010aa:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010ac:	be 00 00 00 00       	mov    $0x0,%esi
  8010b1:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8010bc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010bf:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010c2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010c4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010c7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010ca:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010cd:	89 ec                	mov    %ebp,%esp
  8010cf:	5d                   	pop    %ebp
  8010d0:	c3                   	ret    

008010d1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010d1:	55                   	push   %ebp
  8010d2:	89 e5                	mov    %esp,%ebp
  8010d4:	83 ec 38             	sub    $0x38,%esp
  8010d7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010da:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010dd:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8010e0:	b8 01 00 00 00       	mov    $0x1,%eax
  8010e5:	0f a2                	cpuid  
  8010e7:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010e9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010ee:	b8 0d 00 00 00       	mov    $0xd,%eax
  8010f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f6:	89 cb                	mov    %ecx,%ebx
  8010f8:	89 cf                	mov    %ecx,%edi
  8010fa:	89 ce                	mov    %ecx,%esi
  8010fc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010fe:	85 c0                	test   %eax,%eax
  801100:	7e 28                	jle    80112a <sys_ipc_recv+0x59>
		panic("syscall %d returned %d (> 0)", num, ret);
  801102:	89 44 24 10          	mov    %eax,0x10(%esp)
  801106:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  80110d:	00 
  80110e:	c7 44 24 08 5f 21 80 	movl   $0x80215f,0x8(%esp)
  801115:	00 
  801116:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  80111d:	00 
  80111e:	c7 04 24 7c 21 80 00 	movl   $0x80217c,(%esp)
  801125:	e8 3a f0 ff ff       	call   800164 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80112a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80112d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801130:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801133:	89 ec                	mov    %ebp,%esp
  801135:	5d                   	pop    %ebp
  801136:	c3                   	ret    
  801137:	90                   	nop

00801138 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801138:	55                   	push   %ebp
  801139:	89 e5                	mov    %esp,%ebp
  80113b:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80113e:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  801145:	75 54                	jne    80119b <set_pgfault_handler+0x63>
		// First time through!
		// LAB 4: Your code here.
		if((r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U|PTE_P|PTE_W)))
  801147:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80114e:	00 
  80114f:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801156:	ee 
  801157:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80115e:	e8 c6 fc ff ff       	call   800e29 <sys_page_alloc>
  801163:	85 c0                	test   %eax,%eax
  801165:	74 20                	je     801187 <set_pgfault_handler+0x4f>
			panic("sys_page_alloc() failed in set_pgfault_handler()[%e]\n", r);
  801167:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80116b:	c7 44 24 08 8c 21 80 	movl   $0x80218c,0x8(%esp)
  801172:	00 
  801173:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  80117a:	00 
  80117b:	c7 04 24 c2 21 80 00 	movl   $0x8021c2,(%esp)
  801182:	e8 dd ef ff ff       	call   800164 <_panic>
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801187:	c7 44 24 04 a8 11 80 	movl   $0x8011a8,0x4(%esp)
  80118e:	00 
  80118f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801196:	e8 92 fe ff ff       	call   80102d <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80119b:	8b 45 08             	mov    0x8(%ebp),%eax
  80119e:	a3 08 40 80 00       	mov    %eax,0x804008
}
  8011a3:	c9                   	leave  
  8011a4:	c3                   	ret    
  8011a5:	66 90                	xchg   %ax,%ax
  8011a7:	90                   	nop

008011a8 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8011a8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8011a9:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  8011ae:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8011b0:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	// @yuhangj: get reserved place under old esp
	addl $0x08, %esp;
  8011b3:	83 c4 08             	add    $0x8,%esp

	movl 0x28(%esp), %eax;
  8011b6:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x04, %eax;
  8011ba:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x28(%esp);
  8011bd:	89 44 24 28          	mov    %eax,0x28(%esp)

    // @yuhangj: store old eip into the reserved place under old esp
	movl 0x20(%esp), %ebx;
  8011c1:	8b 5c 24 20          	mov    0x20(%esp),%ebx
	movl %ebx, (%eax);
  8011c5:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  8011c7:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp;
  8011c8:	83 c4 04             	add    $0x4,%esp
	popfl
  8011cb:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  8011cc:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  8011cd:	c3                   	ret    
  8011ce:	66 90                	xchg   %ax,%ax

008011d0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011d0:	55                   	push   %ebp
  8011d1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d6:	05 00 00 00 30       	add    $0x30000000,%eax
  8011db:	c1 e8 0c             	shr    $0xc,%eax
}
  8011de:	5d                   	pop    %ebp
  8011df:	c3                   	ret    

008011e0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011e0:	55                   	push   %ebp
  8011e1:	89 e5                	mov    %esp,%ebp
  8011e3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8011e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e9:	89 04 24             	mov    %eax,(%esp)
  8011ec:	e8 df ff ff ff       	call   8011d0 <fd2num>
  8011f1:	c1 e0 0c             	shl    $0xc,%eax
  8011f4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011f9:	c9                   	leave  
  8011fa:	c3                   	ret    

008011fb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011fb:	55                   	push   %ebp
  8011fc:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8011fe:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801203:	a8 01                	test   $0x1,%al
  801205:	74 34                	je     80123b <fd_alloc+0x40>
  801207:	a1 00 00 74 ef       	mov    0xef740000,%eax
  80120c:	a8 01                	test   $0x1,%al
  80120e:	74 32                	je     801242 <fd_alloc+0x47>
  801210:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801215:	89 c1                	mov    %eax,%ecx
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801217:	89 c2                	mov    %eax,%edx
  801219:	c1 ea 16             	shr    $0x16,%edx
  80121c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801223:	f6 c2 01             	test   $0x1,%dl
  801226:	74 1f                	je     801247 <fd_alloc+0x4c>
  801228:	89 c2                	mov    %eax,%edx
  80122a:	c1 ea 0c             	shr    $0xc,%edx
  80122d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801234:	f6 c2 01             	test   $0x1,%dl
  801237:	75 1a                	jne    801253 <fd_alloc+0x58>
  801239:	eb 0c                	jmp    801247 <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80123b:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801240:	eb 05                	jmp    801247 <fd_alloc+0x4c>
  801242:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  801247:	8b 45 08             	mov    0x8(%ebp),%eax
  80124a:	89 08                	mov    %ecx,(%eax)
			return 0;
  80124c:	b8 00 00 00 00       	mov    $0x0,%eax
  801251:	eb 1a                	jmp    80126d <fd_alloc+0x72>
  801253:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801258:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80125d:	75 b6                	jne    801215 <fd_alloc+0x1a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80125f:	8b 45 08             	mov    0x8(%ebp),%eax
  801262:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801268:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80126d:	5d                   	pop    %ebp
  80126e:	c3                   	ret    

0080126f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80126f:	55                   	push   %ebp
  801270:	89 e5                	mov    %esp,%ebp
  801272:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801275:	83 f8 1f             	cmp    $0x1f,%eax
  801278:	77 36                	ja     8012b0 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80127a:	c1 e0 0c             	shl    $0xc,%eax
  80127d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801282:	89 c2                	mov    %eax,%edx
  801284:	c1 ea 16             	shr    $0x16,%edx
  801287:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80128e:	f6 c2 01             	test   $0x1,%dl
  801291:	74 24                	je     8012b7 <fd_lookup+0x48>
  801293:	89 c2                	mov    %eax,%edx
  801295:	c1 ea 0c             	shr    $0xc,%edx
  801298:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80129f:	f6 c2 01             	test   $0x1,%dl
  8012a2:	74 1a                	je     8012be <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012a7:	89 02                	mov    %eax,(%edx)
	return 0;
  8012a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ae:	eb 13                	jmp    8012c3 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  8012b0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012b5:	eb 0c                	jmp    8012c3 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  8012b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012bc:	eb 05                	jmp    8012c3 <fd_lookup+0x54>
  8012be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012c3:	5d                   	pop    %ebp
  8012c4:	c3                   	ret    

008012c5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012c5:	55                   	push   %ebp
  8012c6:	89 e5                	mov    %esp,%ebp
  8012c8:	83 ec 18             	sub    $0x18,%esp
  8012cb:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8012ce:	39 05 04 30 80 00    	cmp    %eax,0x803004
  8012d4:	75 10                	jne    8012e6 <dev_lookup+0x21>
			*dev = devtab[i];
  8012d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012d9:	c7 00 04 30 80 00    	movl   $0x803004,(%eax)
			return 0;
  8012df:	b8 00 00 00 00       	mov    $0x0,%eax
  8012e4:	eb 2b                	jmp    801311 <dev_lookup+0x4c>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012e6:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8012ec:	8b 52 48             	mov    0x48(%edx),%edx
  8012ef:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8012f7:	c7 04 24 d0 21 80 00 	movl   $0x8021d0,(%esp)
  8012fe:	e8 5c ef ff ff       	call   80025f <cprintf>
	*dev = 0;
  801303:	8b 55 0c             	mov    0xc(%ebp),%edx
  801306:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	return -E_INVAL;
  80130c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801311:	c9                   	leave  
  801312:	c3                   	ret    

00801313 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801313:	55                   	push   %ebp
  801314:	89 e5                	mov    %esp,%ebp
  801316:	83 ec 38             	sub    $0x38,%esp
  801319:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80131c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80131f:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801322:	8b 7d 08             	mov    0x8(%ebp),%edi
  801325:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801328:	89 3c 24             	mov    %edi,(%esp)
  80132b:	e8 a0 fe ff ff       	call   8011d0 <fd2num>
  801330:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  801333:	89 54 24 04          	mov    %edx,0x4(%esp)
  801337:	89 04 24             	mov    %eax,(%esp)
  80133a:	e8 30 ff ff ff       	call   80126f <fd_lookup>
  80133f:	89 c3                	mov    %eax,%ebx
  801341:	85 c0                	test   %eax,%eax
  801343:	78 05                	js     80134a <fd_close+0x37>
	    || fd != fd2)
  801345:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  801348:	74 0c                	je     801356 <fd_close+0x43>
		return (must_exist ? r : 0);
  80134a:	85 f6                	test   %esi,%esi
  80134c:	b8 00 00 00 00       	mov    $0x0,%eax
  801351:	0f 44 d8             	cmove  %eax,%ebx
  801354:	eb 3d                	jmp    801393 <fd_close+0x80>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801356:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801359:	89 44 24 04          	mov    %eax,0x4(%esp)
  80135d:	8b 07                	mov    (%edi),%eax
  80135f:	89 04 24             	mov    %eax,(%esp)
  801362:	e8 5e ff ff ff       	call   8012c5 <dev_lookup>
  801367:	89 c3                	mov    %eax,%ebx
  801369:	85 c0                	test   %eax,%eax
  80136b:	78 16                	js     801383 <fd_close+0x70>
		if (dev->dev_close)
  80136d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801370:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801373:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801378:	85 c0                	test   %eax,%eax
  80137a:	74 07                	je     801383 <fd_close+0x70>
			r = (*dev->dev_close)(fd);
  80137c:	89 3c 24             	mov    %edi,(%esp)
  80137f:	ff d0                	call   *%eax
  801381:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801383:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801387:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80138e:	e8 65 fb ff ff       	call   800ef8 <sys_page_unmap>
	return r;
}
  801393:	89 d8                	mov    %ebx,%eax
  801395:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801398:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80139b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80139e:	89 ec                	mov    %ebp,%esp
  8013a0:	5d                   	pop    %ebp
  8013a1:	c3                   	ret    

008013a2 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013a2:	55                   	push   %ebp
  8013a3:	89 e5                	mov    %esp,%ebp
  8013a5:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013af:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b2:	89 04 24             	mov    %eax,(%esp)
  8013b5:	e8 b5 fe ff ff       	call   80126f <fd_lookup>
  8013ba:	85 c0                	test   %eax,%eax
  8013bc:	78 13                	js     8013d1 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8013be:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8013c5:	00 
  8013c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013c9:	89 04 24             	mov    %eax,(%esp)
  8013cc:	e8 42 ff ff ff       	call   801313 <fd_close>
}
  8013d1:	c9                   	leave  
  8013d2:	c3                   	ret    

008013d3 <close_all>:

void
close_all(void)
{
  8013d3:	55                   	push   %ebp
  8013d4:	89 e5                	mov    %esp,%ebp
  8013d6:	53                   	push   %ebx
  8013d7:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013da:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013df:	89 1c 24             	mov    %ebx,(%esp)
  8013e2:	e8 bb ff ff ff       	call   8013a2 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013e7:	83 c3 01             	add    $0x1,%ebx
  8013ea:	83 fb 20             	cmp    $0x20,%ebx
  8013ed:	75 f0                	jne    8013df <close_all+0xc>
		close(i);
}
  8013ef:	83 c4 14             	add    $0x14,%esp
  8013f2:	5b                   	pop    %ebx
  8013f3:	5d                   	pop    %ebp
  8013f4:	c3                   	ret    

008013f5 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013f5:	55                   	push   %ebp
  8013f6:	89 e5                	mov    %esp,%ebp
  8013f8:	83 ec 58             	sub    $0x58,%esp
  8013fb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8013fe:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801401:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801404:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801407:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80140a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80140e:	8b 45 08             	mov    0x8(%ebp),%eax
  801411:	89 04 24             	mov    %eax,(%esp)
  801414:	e8 56 fe ff ff       	call   80126f <fd_lookup>
  801419:	85 c0                	test   %eax,%eax
  80141b:	0f 88 e3 00 00 00    	js     801504 <dup+0x10f>
		return r;
	close(newfdnum);
  801421:	89 1c 24             	mov    %ebx,(%esp)
  801424:	e8 79 ff ff ff       	call   8013a2 <close>

	newfd = INDEX2FD(newfdnum);
  801429:	89 de                	mov    %ebx,%esi
  80142b:	c1 e6 0c             	shl    $0xc,%esi
  80142e:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801434:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801437:	89 04 24             	mov    %eax,(%esp)
  80143a:	e8 a1 fd ff ff       	call   8011e0 <fd2data>
  80143f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801441:	89 34 24             	mov    %esi,(%esp)
  801444:	e8 97 fd ff ff       	call   8011e0 <fd2data>
  801449:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  80144c:	89 f8                	mov    %edi,%eax
  80144e:	c1 e8 16             	shr    $0x16,%eax
  801451:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801458:	a8 01                	test   $0x1,%al
  80145a:	74 46                	je     8014a2 <dup+0xad>
  80145c:	89 f8                	mov    %edi,%eax
  80145e:	c1 e8 0c             	shr    $0xc,%eax
  801461:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801468:	f6 c2 01             	test   $0x1,%dl
  80146b:	74 35                	je     8014a2 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80146d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801474:	25 07 0e 00 00       	and    $0xe07,%eax
  801479:	89 44 24 10          	mov    %eax,0x10(%esp)
  80147d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801480:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801484:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80148b:	00 
  80148c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801490:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801497:	e8 f5 f9 ff ff       	call   800e91 <sys_page_map>
  80149c:	89 c7                	mov    %eax,%edi
  80149e:	85 c0                	test   %eax,%eax
  8014a0:	78 3b                	js     8014dd <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014a5:	89 c2                	mov    %eax,%edx
  8014a7:	c1 ea 0c             	shr    $0xc,%edx
  8014aa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014b1:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8014b7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8014bb:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8014bf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014c6:	00 
  8014c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014d2:	e8 ba f9 ff ff       	call   800e91 <sys_page_map>
  8014d7:	89 c7                	mov    %eax,%edi
  8014d9:	85 c0                	test   %eax,%eax
  8014db:	79 29                	jns    801506 <dup+0x111>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014dd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014e8:	e8 0b fa ff ff       	call   800ef8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014ed:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8014f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014f4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014fb:	e8 f8 f9 ff ff       	call   800ef8 <sys_page_unmap>
	return r;
  801500:	89 fb                	mov    %edi,%ebx
  801502:	eb 02                	jmp    801506 <dup+0x111>
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
		return r;
  801504:	89 c3                	mov    %eax,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801506:	89 d8                	mov    %ebx,%eax
  801508:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80150b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80150e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801511:	89 ec                	mov    %ebp,%esp
  801513:	5d                   	pop    %ebp
  801514:	c3                   	ret    

00801515 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801515:	55                   	push   %ebp
  801516:	89 e5                	mov    %esp,%ebp
  801518:	53                   	push   %ebx
  801519:	83 ec 24             	sub    $0x24,%esp
  80151c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80151f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801522:	89 44 24 04          	mov    %eax,0x4(%esp)
  801526:	89 1c 24             	mov    %ebx,(%esp)
  801529:	e8 41 fd ff ff       	call   80126f <fd_lookup>
  80152e:	85 c0                	test   %eax,%eax
  801530:	78 6d                	js     80159f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801532:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801535:	89 44 24 04          	mov    %eax,0x4(%esp)
  801539:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80153c:	8b 00                	mov    (%eax),%eax
  80153e:	89 04 24             	mov    %eax,(%esp)
  801541:	e8 7f fd ff ff       	call   8012c5 <dev_lookup>
  801546:	85 c0                	test   %eax,%eax
  801548:	78 55                	js     80159f <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80154a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80154d:	8b 50 08             	mov    0x8(%eax),%edx
  801550:	83 e2 03             	and    $0x3,%edx
  801553:	83 fa 01             	cmp    $0x1,%edx
  801556:	75 23                	jne    80157b <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801558:	a1 04 40 80 00       	mov    0x804004,%eax
  80155d:	8b 40 48             	mov    0x48(%eax),%eax
  801560:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801564:	89 44 24 04          	mov    %eax,0x4(%esp)
  801568:	c7 04 24 14 22 80 00 	movl   $0x802214,(%esp)
  80156f:	e8 eb ec ff ff       	call   80025f <cprintf>
		return -E_INVAL;
  801574:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801579:	eb 24                	jmp    80159f <read+0x8a>
	}
	if (!dev->dev_read)
  80157b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80157e:	8b 52 08             	mov    0x8(%edx),%edx
  801581:	85 d2                	test   %edx,%edx
  801583:	74 15                	je     80159a <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801585:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801588:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80158c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80158f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801593:	89 04 24             	mov    %eax,(%esp)
  801596:	ff d2                	call   *%edx
  801598:	eb 05                	jmp    80159f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80159a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80159f:	83 c4 24             	add    $0x24,%esp
  8015a2:	5b                   	pop    %ebx
  8015a3:	5d                   	pop    %ebp
  8015a4:	c3                   	ret    

008015a5 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015a5:	55                   	push   %ebp
  8015a6:	89 e5                	mov    %esp,%ebp
  8015a8:	57                   	push   %edi
  8015a9:	56                   	push   %esi
  8015aa:	53                   	push   %ebx
  8015ab:	83 ec 1c             	sub    $0x1c,%esp
  8015ae:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015b1:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015b4:	85 f6                	test   %esi,%esi
  8015b6:	74 33                	je     8015eb <readn+0x46>
  8015b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8015bd:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015c2:	89 f2                	mov    %esi,%edx
  8015c4:	29 c2                	sub    %eax,%edx
  8015c6:	89 54 24 08          	mov    %edx,0x8(%esp)
  8015ca:	03 45 0c             	add    0xc(%ebp),%eax
  8015cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015d1:	89 3c 24             	mov    %edi,(%esp)
  8015d4:	e8 3c ff ff ff       	call   801515 <read>
		if (m < 0)
  8015d9:	85 c0                	test   %eax,%eax
  8015db:	78 17                	js     8015f4 <readn+0x4f>
			return m;
		if (m == 0)
  8015dd:	85 c0                	test   %eax,%eax
  8015df:	74 11                	je     8015f2 <readn+0x4d>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015e1:	01 c3                	add    %eax,%ebx
  8015e3:	89 d8                	mov    %ebx,%eax
  8015e5:	39 f3                	cmp    %esi,%ebx
  8015e7:	72 d9                	jb     8015c2 <readn+0x1d>
  8015e9:	eb 09                	jmp    8015f4 <readn+0x4f>
  8015eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8015f0:	eb 02                	jmp    8015f4 <readn+0x4f>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8015f2:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8015f4:	83 c4 1c             	add    $0x1c,%esp
  8015f7:	5b                   	pop    %ebx
  8015f8:	5e                   	pop    %esi
  8015f9:	5f                   	pop    %edi
  8015fa:	5d                   	pop    %ebp
  8015fb:	c3                   	ret    

008015fc <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015fc:	55                   	push   %ebp
  8015fd:	89 e5                	mov    %esp,%ebp
  8015ff:	53                   	push   %ebx
  801600:	83 ec 24             	sub    $0x24,%esp
  801603:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801606:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801609:	89 44 24 04          	mov    %eax,0x4(%esp)
  80160d:	89 1c 24             	mov    %ebx,(%esp)
  801610:	e8 5a fc ff ff       	call   80126f <fd_lookup>
  801615:	85 c0                	test   %eax,%eax
  801617:	78 68                	js     801681 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801619:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80161c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801620:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801623:	8b 00                	mov    (%eax),%eax
  801625:	89 04 24             	mov    %eax,(%esp)
  801628:	e8 98 fc ff ff       	call   8012c5 <dev_lookup>
  80162d:	85 c0                	test   %eax,%eax
  80162f:	78 50                	js     801681 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801631:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801634:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801638:	75 23                	jne    80165d <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80163a:	a1 04 40 80 00       	mov    0x804004,%eax
  80163f:	8b 40 48             	mov    0x48(%eax),%eax
  801642:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801646:	89 44 24 04          	mov    %eax,0x4(%esp)
  80164a:	c7 04 24 30 22 80 00 	movl   $0x802230,(%esp)
  801651:	e8 09 ec ff ff       	call   80025f <cprintf>
		return -E_INVAL;
  801656:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80165b:	eb 24                	jmp    801681 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80165d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801660:	8b 52 0c             	mov    0xc(%edx),%edx
  801663:	85 d2                	test   %edx,%edx
  801665:	74 15                	je     80167c <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801667:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80166a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80166e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801671:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801675:	89 04 24             	mov    %eax,(%esp)
  801678:	ff d2                	call   *%edx
  80167a:	eb 05                	jmp    801681 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80167c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801681:	83 c4 24             	add    $0x24,%esp
  801684:	5b                   	pop    %ebx
  801685:	5d                   	pop    %ebp
  801686:	c3                   	ret    

00801687 <seek>:

int
seek(int fdnum, off_t offset)
{
  801687:	55                   	push   %ebp
  801688:	89 e5                	mov    %esp,%ebp
  80168a:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80168d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801690:	89 44 24 04          	mov    %eax,0x4(%esp)
  801694:	8b 45 08             	mov    0x8(%ebp),%eax
  801697:	89 04 24             	mov    %eax,(%esp)
  80169a:	e8 d0 fb ff ff       	call   80126f <fd_lookup>
  80169f:	85 c0                	test   %eax,%eax
  8016a1:	78 0e                	js     8016b1 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8016a3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016a9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016b1:	c9                   	leave  
  8016b2:	c3                   	ret    

008016b3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016b3:	55                   	push   %ebp
  8016b4:	89 e5                	mov    %esp,%ebp
  8016b6:	53                   	push   %ebx
  8016b7:	83 ec 24             	sub    $0x24,%esp
  8016ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016bd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016c4:	89 1c 24             	mov    %ebx,(%esp)
  8016c7:	e8 a3 fb ff ff       	call   80126f <fd_lookup>
  8016cc:	85 c0                	test   %eax,%eax
  8016ce:	78 61                	js     801731 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016da:	8b 00                	mov    (%eax),%eax
  8016dc:	89 04 24             	mov    %eax,(%esp)
  8016df:	e8 e1 fb ff ff       	call   8012c5 <dev_lookup>
  8016e4:	85 c0                	test   %eax,%eax
  8016e6:	78 49                	js     801731 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016eb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016ef:	75 23                	jne    801714 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016f1:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016f6:	8b 40 48             	mov    0x48(%eax),%eax
  8016f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8016fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801701:	c7 04 24 f0 21 80 00 	movl   $0x8021f0,(%esp)
  801708:	e8 52 eb ff ff       	call   80025f <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80170d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801712:	eb 1d                	jmp    801731 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801714:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801717:	8b 52 18             	mov    0x18(%edx),%edx
  80171a:	85 d2                	test   %edx,%edx
  80171c:	74 0e                	je     80172c <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80171e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801721:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801725:	89 04 24             	mov    %eax,(%esp)
  801728:	ff d2                	call   *%edx
  80172a:	eb 05                	jmp    801731 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80172c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801731:	83 c4 24             	add    $0x24,%esp
  801734:	5b                   	pop    %ebx
  801735:	5d                   	pop    %ebp
  801736:	c3                   	ret    

00801737 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801737:	55                   	push   %ebp
  801738:	89 e5                	mov    %esp,%ebp
  80173a:	53                   	push   %ebx
  80173b:	83 ec 24             	sub    $0x24,%esp
  80173e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801741:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801744:	89 44 24 04          	mov    %eax,0x4(%esp)
  801748:	8b 45 08             	mov    0x8(%ebp),%eax
  80174b:	89 04 24             	mov    %eax,(%esp)
  80174e:	e8 1c fb ff ff       	call   80126f <fd_lookup>
  801753:	85 c0                	test   %eax,%eax
  801755:	78 52                	js     8017a9 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801757:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80175a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80175e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801761:	8b 00                	mov    (%eax),%eax
  801763:	89 04 24             	mov    %eax,(%esp)
  801766:	e8 5a fb ff ff       	call   8012c5 <dev_lookup>
  80176b:	85 c0                	test   %eax,%eax
  80176d:	78 3a                	js     8017a9 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  80176f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801772:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801776:	74 2c                	je     8017a4 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801778:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80177b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801782:	00 00 00 
	stat->st_isdir = 0;
  801785:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80178c:	00 00 00 
	stat->st_dev = dev;
  80178f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801795:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801799:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80179c:	89 14 24             	mov    %edx,(%esp)
  80179f:	ff 50 14             	call   *0x14(%eax)
  8017a2:	eb 05                	jmp    8017a9 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017a4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017a9:	83 c4 24             	add    $0x24,%esp
  8017ac:	5b                   	pop    %ebx
  8017ad:	5d                   	pop    %ebp
  8017ae:	c3                   	ret    

008017af <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017af:	55                   	push   %ebp
  8017b0:	89 e5                	mov    %esp,%ebp
  8017b2:	83 ec 18             	sub    $0x18,%esp
  8017b5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8017b8:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017bb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8017c2:	00 
  8017c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c6:	89 04 24             	mov    %eax,(%esp)
  8017c9:	e8 84 01 00 00       	call   801952 <open>
  8017ce:	89 c3                	mov    %eax,%ebx
  8017d0:	85 c0                	test   %eax,%eax
  8017d2:	78 1b                	js     8017ef <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  8017d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017db:	89 1c 24             	mov    %ebx,(%esp)
  8017de:	e8 54 ff ff ff       	call   801737 <fstat>
  8017e3:	89 c6                	mov    %eax,%esi
	close(fd);
  8017e5:	89 1c 24             	mov    %ebx,(%esp)
  8017e8:	e8 b5 fb ff ff       	call   8013a2 <close>
	return r;
  8017ed:	89 f3                	mov    %esi,%ebx
}
  8017ef:	89 d8                	mov    %ebx,%eax
  8017f1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8017f4:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8017f7:	89 ec                	mov    %ebp,%esp
  8017f9:	5d                   	pop    %ebp
  8017fa:	c3                   	ret    
  8017fb:	90                   	nop

008017fc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017fc:	55                   	push   %ebp
  8017fd:	89 e5                	mov    %esp,%ebp
  8017ff:	83 ec 18             	sub    $0x18,%esp
  801802:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801805:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801808:	89 c6                	mov    %eax,%esi
  80180a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80180c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801813:	75 11                	jne    801826 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801815:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  80181c:	e8 72 02 00 00       	call   801a93 <ipc_find_env>
  801821:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801826:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80182d:	00 
  80182e:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801835:	00 
  801836:	89 74 24 04          	mov    %esi,0x4(%esp)
  80183a:	a1 00 40 80 00       	mov    0x804000,%eax
  80183f:	89 04 24             	mov    %eax,(%esp)
  801842:	e8 e1 01 00 00       	call   801a28 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801847:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80184e:	00 
  80184f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801853:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80185a:	e8 71 01 00 00       	call   8019d0 <ipc_recv>
}
  80185f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801862:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801865:	89 ec                	mov    %ebp,%esp
  801867:	5d                   	pop    %ebp
  801868:	c3                   	ret    

00801869 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801869:	55                   	push   %ebp
  80186a:	89 e5                	mov    %esp,%ebp
  80186c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80186f:	8b 45 08             	mov    0x8(%ebp),%eax
  801872:	8b 40 0c             	mov    0xc(%eax),%eax
  801875:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80187a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80187d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801882:	ba 00 00 00 00       	mov    $0x0,%edx
  801887:	b8 02 00 00 00       	mov    $0x2,%eax
  80188c:	e8 6b ff ff ff       	call   8017fc <fsipc>
}
  801891:	c9                   	leave  
  801892:	c3                   	ret    

00801893 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801893:	55                   	push   %ebp
  801894:	89 e5                	mov    %esp,%ebp
  801896:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801899:	8b 45 08             	mov    0x8(%ebp),%eax
  80189c:	8b 40 0c             	mov    0xc(%eax),%eax
  80189f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a9:	b8 06 00 00 00       	mov    $0x6,%eax
  8018ae:	e8 49 ff ff ff       	call   8017fc <fsipc>
}
  8018b3:	c9                   	leave  
  8018b4:	c3                   	ret    

008018b5 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018b5:	55                   	push   %ebp
  8018b6:	89 e5                	mov    %esp,%ebp
  8018b8:	53                   	push   %ebx
  8018b9:	83 ec 14             	sub    $0x14,%esp
  8018bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c2:	8b 40 0c             	mov    0xc(%eax),%eax
  8018c5:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8018cf:	b8 05 00 00 00       	mov    $0x5,%eax
  8018d4:	e8 23 ff ff ff       	call   8017fc <fsipc>
  8018d9:	85 c0                	test   %eax,%eax
  8018db:	78 2b                	js     801908 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018dd:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8018e4:	00 
  8018e5:	89 1c 24             	mov    %ebx,(%esp)
  8018e8:	e8 ee ef ff ff       	call   8008db <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018ed:	a1 80 50 80 00       	mov    0x805080,%eax
  8018f2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018f8:	a1 84 50 80 00       	mov    0x805084,%eax
  8018fd:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801903:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801908:	83 c4 14             	add    $0x14,%esp
  80190b:	5b                   	pop    %ebx
  80190c:	5d                   	pop    %ebp
  80190d:	c3                   	ret    

0080190e <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80190e:	55                   	push   %ebp
  80190f:	89 e5                	mov    %esp,%ebp
  801911:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801914:	c7 44 24 08 4d 22 80 	movl   $0x80224d,0x8(%esp)
  80191b:	00 
  80191c:	c7 44 24 04 77 00 00 	movl   $0x77,0x4(%esp)
  801923:	00 
  801924:	c7 04 24 6b 22 80 00 	movl   $0x80226b,(%esp)
  80192b:	e8 34 e8 ff ff       	call   800164 <_panic>

00801930 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801930:	55                   	push   %ebp
  801931:	89 e5                	mov    %esp,%ebp
  801933:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_READ request to the file system server after
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
	panic("devfile_read not implemented");
  801936:	c7 44 24 08 76 22 80 	movl   $0x802276,0x8(%esp)
  80193d:	00 
  80193e:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
  801945:	00 
  801946:	c7 04 24 6b 22 80 00 	movl   $0x80226b,(%esp)
  80194d:	e8 12 e8 ff ff       	call   800164 <_panic>

00801952 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801952:	55                   	push   %ebp
  801953:	89 e5                	mov    %esp,%ebp
  801955:	83 ec 18             	sub    $0x18,%esp
	// Return the file descriptor index.
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
	panic("open not implemented");
  801958:	c7 44 24 08 93 22 80 	movl   $0x802293,0x8(%esp)
  80195f:	00 
  801960:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  801967:	00 
  801968:	c7 04 24 6b 22 80 00 	movl   $0x80226b,(%esp)
  80196f:	e8 f0 e7 ff ff       	call   800164 <_panic>

00801974 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801974:	55                   	push   %ebp
  801975:	89 e5                	mov    %esp,%ebp
  801977:	53                   	push   %ebx
  801978:	83 ec 14             	sub    $0x14,%esp
  80197b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  80197e:	89 1c 24             	mov    %ebx,(%esp)
  801981:	e8 fa ee ff ff       	call   800880 <strlen>
  801986:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80198b:	7f 21                	jg     8019ae <remove+0x3a>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  80198d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801991:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801998:	e8 3e ef ff ff       	call   8008db <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  80199d:	ba 00 00 00 00       	mov    $0x0,%edx
  8019a2:	b8 07 00 00 00       	mov    $0x7,%eax
  8019a7:	e8 50 fe ff ff       	call   8017fc <fsipc>
  8019ac:	eb 05                	jmp    8019b3 <remove+0x3f>
// Delete a file
int
remove(const char *path)
{
	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019ae:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
	strcpy(fsipcbuf.remove.req_path, path);
	return fsipc(FSREQ_REMOVE, NULL);
}
  8019b3:	83 c4 14             	add    $0x14,%esp
  8019b6:	5b                   	pop    %ebx
  8019b7:	5d                   	pop    %ebp
  8019b8:	c3                   	ret    

008019b9 <sync>:

// Synchronize disk with buffer cache
int
sync(void)
{
  8019b9:	55                   	push   %ebp
  8019ba:	89 e5                	mov    %esp,%ebp
  8019bc:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8019c4:	b8 08 00 00 00       	mov    $0x8,%eax
  8019c9:	e8 2e fe ff ff       	call   8017fc <fsipc>
}
  8019ce:	c9                   	leave  
  8019cf:	c3                   	ret    

008019d0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019d0:	55                   	push   %ebp
  8019d1:	89 e5                	mov    %esp,%ebp
  8019d3:	56                   	push   %esi
  8019d4:	53                   	push   %ebx
  8019d5:	83 ec 10             	sub    $0x10,%esp
  8019d8:	8b 75 08             	mov    0x8(%ebp),%esi
  8019db:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	// 	return thisenv->env_ipc_value;
	// }
	int r;
	if(pg == NULL)
		pg = (void *)~0x0;
  8019de:	85 db                	test   %ebx,%ebx
  8019e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8019e5:	0f 44 d8             	cmove  %eax,%ebx
	//else
	if((r = sys_ipc_recv(pg)) < 0)
  8019e8:	89 1c 24             	mov    %ebx,(%esp)
  8019eb:	e8 e1 f6 ff ff       	call   8010d1 <sys_ipc_recv>
  8019f0:	85 c0                	test   %eax,%eax
  8019f2:	78 2d                	js     801a21 <ipc_recv+0x51>
		return r;
	//volatile struct Env *curenv = (struct Env*)envs+ENVX(sys_getenvid());

	if(from_env_store)
  8019f4:	85 f6                	test   %esi,%esi
  8019f6:	74 0a                	je     801a02 <ipc_recv+0x32>
		*from_env_store = thisenv -> env_ipc_from;
  8019f8:	a1 04 40 80 00       	mov    0x804004,%eax
  8019fd:	8b 40 74             	mov    0x74(%eax),%eax
  801a00:	89 06                	mov    %eax,(%esi)
	if(pg && perm_store)
  801a02:	85 db                	test   %ebx,%ebx
  801a04:	74 13                	je     801a19 <ipc_recv+0x49>
  801a06:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a0a:	74 0d                	je     801a19 <ipc_recv+0x49>
		*perm_store = thisenv -> env_ipc_perm;
  801a0c:	a1 04 40 80 00       	mov    0x804004,%eax
  801a11:	8b 40 78             	mov    0x78(%eax),%eax
  801a14:	8b 55 10             	mov    0x10(%ebp),%edx
  801a17:	89 02                	mov    %eax,(%edx)
	else if(perm_store)
		perm_store = (int *)0;
	return thisenv->env_ipc_value;
  801a19:	a1 04 40 80 00       	mov    0x804004,%eax
  801a1e:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  801a21:	83 c4 10             	add    $0x10,%esp
  801a24:	5b                   	pop    %ebx
  801a25:	5e                   	pop    %esi
  801a26:	5d                   	pop    %ebp
  801a27:	c3                   	ret    

00801a28 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a28:	55                   	push   %ebp
  801a29:	89 e5                	mov    %esp,%ebp
  801a2b:	57                   	push   %edi
  801a2c:	56                   	push   %esi
  801a2d:	53                   	push   %ebx
  801a2e:	83 ec 1c             	sub    $0x1c,%esp
  801a31:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a34:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a37:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

	if(pg == NULL)
  801a3a:	85 db                	test   %ebx,%ebx
		pg = (void *)~0x0;
  801a3c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801a41:	0f 44 d8             	cmove  %eax,%ebx
  801a44:	eb 2a                	jmp    801a70 <ipc_send+0x48>
	while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0){
		if(r != -E_IPC_NOT_RECV)
  801a46:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a49:	74 20                	je     801a6b <ipc_send+0x43>
            panic("Send message error %e\n",r);
  801a4b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a4f:	c7 44 24 08 a8 22 80 	movl   $0x8022a8,0x8(%esp)
  801a56:	00 
  801a57:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  801a5e:	00 
  801a5f:	c7 04 24 bf 22 80 00 	movl   $0x8022bf,(%esp)
  801a66:	e8 f9 e6 ff ff       	call   800164 <_panic>
		sys_yield();
  801a6b:	e8 80 f3 ff ff       	call   800df0 <sys_yield>
	// LAB 4: Your code here.
	int r;

	if(pg == NULL)
		pg = (void *)~0x0;
	while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0){
  801a70:	8b 45 14             	mov    0x14(%ebp),%eax
  801a73:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a77:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a7b:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a7f:	89 3c 24             	mov    %edi,(%esp)
  801a82:	e8 0d f6 ff ff       	call   801094 <sys_ipc_try_send>
  801a87:	85 c0                	test   %eax,%eax
  801a89:	78 bb                	js     801a46 <ipc_send+0x1e>
            panic("Send message error %e\n",r);
		sys_yield();
	}

	//panic("ipc_send not implemented");
}
  801a8b:	83 c4 1c             	add    $0x1c,%esp
  801a8e:	5b                   	pop    %ebx
  801a8f:	5e                   	pop    %esi
  801a90:	5f                   	pop    %edi
  801a91:	5d                   	pop    %ebp
  801a92:	c3                   	ret    

00801a93 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801a93:	55                   	push   %ebp
  801a94:	89 e5                	mov    %esp,%ebp
  801a96:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801a99:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801a9e:	39 c8                	cmp    %ecx,%eax
  801aa0:	74 17                	je     801ab9 <ipc_find_env+0x26>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801aa2:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801aa7:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801aaa:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ab0:	8b 52 50             	mov    0x50(%edx),%edx
  801ab3:	39 ca                	cmp    %ecx,%edx
  801ab5:	75 14                	jne    801acb <ipc_find_env+0x38>
  801ab7:	eb 05                	jmp    801abe <ipc_find_env+0x2b>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ab9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801abe:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ac1:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801ac6:	8b 40 40             	mov    0x40(%eax),%eax
  801ac9:	eb 0e                	jmp    801ad9 <ipc_find_env+0x46>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801acb:	83 c0 01             	add    $0x1,%eax
  801ace:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ad3:	75 d2                	jne    801aa7 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ad5:	66 b8 00 00          	mov    $0x0,%ax
}
  801ad9:	5d                   	pop    %ebp
  801ada:	c3                   	ret    
  801adb:	66 90                	xchg   %ax,%ax
  801add:	66 90                	xchg   %ax,%ax
  801adf:	90                   	nop

00801ae0 <__udivdi3>:
  801ae0:	83 ec 1c             	sub    $0x1c,%esp
  801ae3:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801ae7:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801aeb:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801aef:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801af3:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801af7:	8b 6c 24 24          	mov    0x24(%esp),%ebp
  801afb:	85 c0                	test   %eax,%eax
  801afd:	89 74 24 10          	mov    %esi,0x10(%esp)
  801b01:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801b05:	89 ea                	mov    %ebp,%edx
  801b07:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801b0b:	75 33                	jne    801b40 <__udivdi3+0x60>
  801b0d:	39 e9                	cmp    %ebp,%ecx
  801b0f:	77 6f                	ja     801b80 <__udivdi3+0xa0>
  801b11:	85 c9                	test   %ecx,%ecx
  801b13:	89 ce                	mov    %ecx,%esi
  801b15:	75 0b                	jne    801b22 <__udivdi3+0x42>
  801b17:	b8 01 00 00 00       	mov    $0x1,%eax
  801b1c:	31 d2                	xor    %edx,%edx
  801b1e:	f7 f1                	div    %ecx
  801b20:	89 c6                	mov    %eax,%esi
  801b22:	31 d2                	xor    %edx,%edx
  801b24:	89 e8                	mov    %ebp,%eax
  801b26:	f7 f6                	div    %esi
  801b28:	89 c5                	mov    %eax,%ebp
  801b2a:	89 f8                	mov    %edi,%eax
  801b2c:	f7 f6                	div    %esi
  801b2e:	89 ea                	mov    %ebp,%edx
  801b30:	8b 74 24 10          	mov    0x10(%esp),%esi
  801b34:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801b38:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801b3c:	83 c4 1c             	add    $0x1c,%esp
  801b3f:	c3                   	ret    
  801b40:	39 e8                	cmp    %ebp,%eax
  801b42:	77 24                	ja     801b68 <__udivdi3+0x88>
  801b44:	0f bd c8             	bsr    %eax,%ecx
  801b47:	83 f1 1f             	xor    $0x1f,%ecx
  801b4a:	89 0c 24             	mov    %ecx,(%esp)
  801b4d:	75 49                	jne    801b98 <__udivdi3+0xb8>
  801b4f:	8b 74 24 08          	mov    0x8(%esp),%esi
  801b53:	39 74 24 04          	cmp    %esi,0x4(%esp)
  801b57:	0f 86 ab 00 00 00    	jbe    801c08 <__udivdi3+0x128>
  801b5d:	39 e8                	cmp    %ebp,%eax
  801b5f:	0f 82 a3 00 00 00    	jb     801c08 <__udivdi3+0x128>
  801b65:	8d 76 00             	lea    0x0(%esi),%esi
  801b68:	31 d2                	xor    %edx,%edx
  801b6a:	31 c0                	xor    %eax,%eax
  801b6c:	8b 74 24 10          	mov    0x10(%esp),%esi
  801b70:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801b74:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801b78:	83 c4 1c             	add    $0x1c,%esp
  801b7b:	c3                   	ret    
  801b7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801b80:	89 f8                	mov    %edi,%eax
  801b82:	f7 f1                	div    %ecx
  801b84:	31 d2                	xor    %edx,%edx
  801b86:	8b 74 24 10          	mov    0x10(%esp),%esi
  801b8a:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801b8e:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801b92:	83 c4 1c             	add    $0x1c,%esp
  801b95:	c3                   	ret    
  801b96:	66 90                	xchg   %ax,%ax
  801b98:	0f b6 0c 24          	movzbl (%esp),%ecx
  801b9c:	89 c6                	mov    %eax,%esi
  801b9e:	b8 20 00 00 00       	mov    $0x20,%eax
  801ba3:	8b 6c 24 04          	mov    0x4(%esp),%ebp
  801ba7:	2b 04 24             	sub    (%esp),%eax
  801baa:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801bae:	d3 e6                	shl    %cl,%esi
  801bb0:	89 c1                	mov    %eax,%ecx
  801bb2:	d3 ed                	shr    %cl,%ebp
  801bb4:	0f b6 0c 24          	movzbl (%esp),%ecx
  801bb8:	09 f5                	or     %esi,%ebp
  801bba:	8b 74 24 04          	mov    0x4(%esp),%esi
  801bbe:	d3 e6                	shl    %cl,%esi
  801bc0:	89 c1                	mov    %eax,%ecx
  801bc2:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bc6:	89 d6                	mov    %edx,%esi
  801bc8:	d3 ee                	shr    %cl,%esi
  801bca:	0f b6 0c 24          	movzbl (%esp),%ecx
  801bce:	d3 e2                	shl    %cl,%edx
  801bd0:	89 c1                	mov    %eax,%ecx
  801bd2:	d3 ef                	shr    %cl,%edi
  801bd4:	09 d7                	or     %edx,%edi
  801bd6:	89 f2                	mov    %esi,%edx
  801bd8:	89 f8                	mov    %edi,%eax
  801bda:	f7 f5                	div    %ebp
  801bdc:	89 d6                	mov    %edx,%esi
  801bde:	89 c7                	mov    %eax,%edi
  801be0:	f7 64 24 04          	mull   0x4(%esp)
  801be4:	39 d6                	cmp    %edx,%esi
  801be6:	72 30                	jb     801c18 <__udivdi3+0x138>
  801be8:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801bec:	0f b6 0c 24          	movzbl (%esp),%ecx
  801bf0:	d3 e5                	shl    %cl,%ebp
  801bf2:	39 c5                	cmp    %eax,%ebp
  801bf4:	73 04                	jae    801bfa <__udivdi3+0x11a>
  801bf6:	39 d6                	cmp    %edx,%esi
  801bf8:	74 1e                	je     801c18 <__udivdi3+0x138>
  801bfa:	89 f8                	mov    %edi,%eax
  801bfc:	31 d2                	xor    %edx,%edx
  801bfe:	e9 69 ff ff ff       	jmp    801b6c <__udivdi3+0x8c>
  801c03:	90                   	nop
  801c04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c08:	31 d2                	xor    %edx,%edx
  801c0a:	b8 01 00 00 00       	mov    $0x1,%eax
  801c0f:	e9 58 ff ff ff       	jmp    801b6c <__udivdi3+0x8c>
  801c14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c18:	8d 47 ff             	lea    -0x1(%edi),%eax
  801c1b:	31 d2                	xor    %edx,%edx
  801c1d:	8b 74 24 10          	mov    0x10(%esp),%esi
  801c21:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801c25:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801c29:	83 c4 1c             	add    $0x1c,%esp
  801c2c:	c3                   	ret    
  801c2d:	66 90                	xchg   %ax,%ax
  801c2f:	90                   	nop

00801c30 <__umoddi3>:
  801c30:	83 ec 2c             	sub    $0x2c,%esp
  801c33:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801c37:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801c3b:	89 74 24 20          	mov    %esi,0x20(%esp)
  801c3f:	8b 74 24 38          	mov    0x38(%esp),%esi
  801c43:	89 7c 24 24          	mov    %edi,0x24(%esp)
  801c47:	8b 7c 24 34          	mov    0x34(%esp),%edi
  801c4b:	85 c0                	test   %eax,%eax
  801c4d:	89 c2                	mov    %eax,%edx
  801c4f:	89 6c 24 28          	mov    %ebp,0x28(%esp)
  801c53:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801c57:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801c5b:	89 74 24 10          	mov    %esi,0x10(%esp)
  801c5f:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801c63:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801c67:	75 1f                	jne    801c88 <__umoddi3+0x58>
  801c69:	39 fe                	cmp    %edi,%esi
  801c6b:	76 63                	jbe    801cd0 <__umoddi3+0xa0>
  801c6d:	89 c8                	mov    %ecx,%eax
  801c6f:	89 fa                	mov    %edi,%edx
  801c71:	f7 f6                	div    %esi
  801c73:	89 d0                	mov    %edx,%eax
  801c75:	31 d2                	xor    %edx,%edx
  801c77:	8b 74 24 20          	mov    0x20(%esp),%esi
  801c7b:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801c7f:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801c83:	83 c4 2c             	add    $0x2c,%esp
  801c86:	c3                   	ret    
  801c87:	90                   	nop
  801c88:	39 f8                	cmp    %edi,%eax
  801c8a:	77 64                	ja     801cf0 <__umoddi3+0xc0>
  801c8c:	0f bd e8             	bsr    %eax,%ebp
  801c8f:	83 f5 1f             	xor    $0x1f,%ebp
  801c92:	75 74                	jne    801d08 <__umoddi3+0xd8>
  801c94:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801c98:	39 7c 24 10          	cmp    %edi,0x10(%esp)
  801c9c:	0f 87 0e 01 00 00    	ja     801db0 <__umoddi3+0x180>
  801ca2:	8b 7c 24 0c          	mov    0xc(%esp),%edi
  801ca6:	29 f1                	sub    %esi,%ecx
  801ca8:	19 c7                	sbb    %eax,%edi
  801caa:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801cae:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801cb2:	8b 44 24 14          	mov    0x14(%esp),%eax
  801cb6:	8b 54 24 18          	mov    0x18(%esp),%edx
  801cba:	8b 74 24 20          	mov    0x20(%esp),%esi
  801cbe:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801cc2:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801cc6:	83 c4 2c             	add    $0x2c,%esp
  801cc9:	c3                   	ret    
  801cca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cd0:	85 f6                	test   %esi,%esi
  801cd2:	89 f5                	mov    %esi,%ebp
  801cd4:	75 0b                	jne    801ce1 <__umoddi3+0xb1>
  801cd6:	b8 01 00 00 00       	mov    $0x1,%eax
  801cdb:	31 d2                	xor    %edx,%edx
  801cdd:	f7 f6                	div    %esi
  801cdf:	89 c5                	mov    %eax,%ebp
  801ce1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801ce5:	31 d2                	xor    %edx,%edx
  801ce7:	f7 f5                	div    %ebp
  801ce9:	89 c8                	mov    %ecx,%eax
  801ceb:	f7 f5                	div    %ebp
  801ced:	eb 84                	jmp    801c73 <__umoddi3+0x43>
  801cef:	90                   	nop
  801cf0:	89 c8                	mov    %ecx,%eax
  801cf2:	89 fa                	mov    %edi,%edx
  801cf4:	8b 74 24 20          	mov    0x20(%esp),%esi
  801cf8:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801cfc:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801d00:	83 c4 2c             	add    $0x2c,%esp
  801d03:	c3                   	ret    
  801d04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d08:	8b 44 24 10          	mov    0x10(%esp),%eax
  801d0c:	be 20 00 00 00       	mov    $0x20,%esi
  801d11:	89 e9                	mov    %ebp,%ecx
  801d13:	29 ee                	sub    %ebp,%esi
  801d15:	d3 e2                	shl    %cl,%edx
  801d17:	89 f1                	mov    %esi,%ecx
  801d19:	d3 e8                	shr    %cl,%eax
  801d1b:	89 e9                	mov    %ebp,%ecx
  801d1d:	09 d0                	or     %edx,%eax
  801d1f:	89 fa                	mov    %edi,%edx
  801d21:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d25:	8b 44 24 10          	mov    0x10(%esp),%eax
  801d29:	d3 e0                	shl    %cl,%eax
  801d2b:	89 f1                	mov    %esi,%ecx
  801d2d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801d31:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801d35:	d3 ea                	shr    %cl,%edx
  801d37:	89 e9                	mov    %ebp,%ecx
  801d39:	d3 e7                	shl    %cl,%edi
  801d3b:	89 f1                	mov    %esi,%ecx
  801d3d:	d3 e8                	shr    %cl,%eax
  801d3f:	89 e9                	mov    %ebp,%ecx
  801d41:	09 f8                	or     %edi,%eax
  801d43:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801d47:	f7 74 24 0c          	divl   0xc(%esp)
  801d4b:	d3 e7                	shl    %cl,%edi
  801d4d:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801d51:	89 d7                	mov    %edx,%edi
  801d53:	f7 64 24 10          	mull   0x10(%esp)
  801d57:	39 d7                	cmp    %edx,%edi
  801d59:	89 c1                	mov    %eax,%ecx
  801d5b:	89 54 24 14          	mov    %edx,0x14(%esp)
  801d5f:	72 3b                	jb     801d9c <__umoddi3+0x16c>
  801d61:	39 44 24 18          	cmp    %eax,0x18(%esp)
  801d65:	72 31                	jb     801d98 <__umoddi3+0x168>
  801d67:	8b 44 24 18          	mov    0x18(%esp),%eax
  801d6b:	29 c8                	sub    %ecx,%eax
  801d6d:	19 d7                	sbb    %edx,%edi
  801d6f:	89 e9                	mov    %ebp,%ecx
  801d71:	89 fa                	mov    %edi,%edx
  801d73:	d3 e8                	shr    %cl,%eax
  801d75:	89 f1                	mov    %esi,%ecx
  801d77:	d3 e2                	shl    %cl,%edx
  801d79:	89 e9                	mov    %ebp,%ecx
  801d7b:	09 d0                	or     %edx,%eax
  801d7d:	89 fa                	mov    %edi,%edx
  801d7f:	d3 ea                	shr    %cl,%edx
  801d81:	8b 74 24 20          	mov    0x20(%esp),%esi
  801d85:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801d89:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801d8d:	83 c4 2c             	add    $0x2c,%esp
  801d90:	c3                   	ret    
  801d91:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d98:	39 d7                	cmp    %edx,%edi
  801d9a:	75 cb                	jne    801d67 <__umoddi3+0x137>
  801d9c:	8b 54 24 14          	mov    0x14(%esp),%edx
  801da0:	89 c1                	mov    %eax,%ecx
  801da2:	2b 4c 24 10          	sub    0x10(%esp),%ecx
  801da6:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  801daa:	eb bb                	jmp    801d67 <__umoddi3+0x137>
  801dac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801db0:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801db4:	0f 82 e8 fe ff ff    	jb     801ca2 <__umoddi3+0x72>
  801dba:	e9 f3 fe ff ff       	jmp    801cb2 <__umoddi3+0x82>
