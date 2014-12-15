
obj/user/faultallocbad.debug:     file format elf32-i386


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
  80002c:	e8 b3 00 00 00       	call   8000e4 <libmain>
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
  80004b:	e8 fb 01 00 00       	call   80024b <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  800050:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800057:	00 
  800058:	89 d8                	mov    %ebx,%eax
  80005a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800063:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80006a:	e8 aa 0d 00 00       	call   800e19 <sys_page_alloc>
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 24                	jns    800097 <handler+0x63>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800073:	89 44 24 10          	mov    %eax,0x10(%esp)
  800077:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80007b:	c7 44 24 08 e0 1d 80 	movl   $0x801de0,0x8(%esp)
  800082:	00 
  800083:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  80008a:	00 
  80008b:	c7 04 24 ca 1d 80 00 	movl   $0x801dca,(%esp)
  800092:	e8 b9 00 00 00       	call   800150 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800097:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80009b:	c7 44 24 08 0c 1e 80 	movl   $0x801e0c,0x8(%esp)
  8000a2:	00 
  8000a3:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000aa:	00 
  8000ab:	89 1c 24             	mov    %ebx,(%esp)
  8000ae:	e8 86 07 00 00       	call   800839 <snprintf>
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
  8000c6:	e8 5d 10 00 00       	call   801128 <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000cb:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  8000d2:	00 
  8000d3:	c7 04 24 ef be ad de 	movl   $0xdeadbeef,(%esp)
  8000da:	e8 f1 0b 00 00       	call   800cd0 <sys_cputs>
}
  8000df:	c9                   	leave  
  8000e0:	c3                   	ret    
  8000e1:	66 90                	xchg   %ax,%ax
  8000e3:	90                   	nop

008000e4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	83 ec 18             	sub    $0x18,%esp
  8000ea:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8000ed:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000f3:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;

	thisenv = &envs[ENVX(sys_getenvid())];
  8000f6:	e8 ac 0c 00 00       	call   800da7 <sys_getenvid>
  8000fb:	25 ff 03 00 00       	and    $0x3ff,%eax
  800100:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800103:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800108:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80010d:	85 db                	test   %ebx,%ebx
  80010f:	7e 07                	jle    800118 <libmain+0x34>
		binaryname = argv[0];
  800111:	8b 06                	mov    (%esi),%eax
  800113:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800118:	89 74 24 04          	mov    %esi,0x4(%esp)
  80011c:	89 1c 24             	mov    %ebx,(%esp)
  80011f:	e8 95 ff ff ff       	call   8000b9 <umain>

	// exit gracefully
	exit();
  800124:	e8 0b 00 00 00       	call   800134 <exit>
}
  800129:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80012c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80012f:	89 ec                	mov    %ebp,%esp
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    
  800133:	90                   	nop

00800134 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80013a:	e8 84 12 00 00       	call   8013c3 <close_all>
	sys_env_destroy(0);
  80013f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800146:	e8 f6 0b 00 00       	call   800d41 <sys_env_destroy>
}
  80014b:	c9                   	leave  
  80014c:	c3                   	ret    
  80014d:	66 90                	xchg   %ax,%ax
  80014f:	90                   	nop

00800150 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	56                   	push   %esi
  800154:	53                   	push   %ebx
  800155:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800158:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80015b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800161:	e8 41 0c 00 00       	call   800da7 <sys_getenvid>
  800166:	8b 55 0c             	mov    0xc(%ebp),%edx
  800169:	89 54 24 10          	mov    %edx,0x10(%esp)
  80016d:	8b 55 08             	mov    0x8(%ebp),%edx
  800170:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800174:	89 74 24 08          	mov    %esi,0x8(%esp)
  800178:	89 44 24 04          	mov    %eax,0x4(%esp)
  80017c:	c7 04 24 38 1e 80 00 	movl   $0x801e38,(%esp)
  800183:	e8 c3 00 00 00       	call   80024b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800188:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80018c:	8b 45 10             	mov    0x10(%ebp),%eax
  80018f:	89 04 24             	mov    %eax,(%esp)
  800192:	e8 53 00 00 00       	call   8001ea <vcprintf>
	cprintf("\n");
  800197:	c7 04 24 bd 22 80 00 	movl   $0x8022bd,(%esp)
  80019e:	e8 a8 00 00 00       	call   80024b <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001a3:	cc                   	int3   
  8001a4:	eb fd                	jmp    8001a3 <_panic+0x53>
  8001a6:	66 90                	xchg   %ax,%ax

008001a8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	53                   	push   %ebx
  8001ac:	83 ec 14             	sub    $0x14,%esp
  8001af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001b2:	8b 03                	mov    (%ebx),%eax
  8001b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001bb:	83 c0 01             	add    $0x1,%eax
  8001be:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001c0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001c5:	75 19                	jne    8001e0 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001c7:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001ce:	00 
  8001cf:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d2:	89 04 24             	mov    %eax,(%esp)
  8001d5:	e8 f6 0a 00 00       	call   800cd0 <sys_cputs>
		b->idx = 0;
  8001da:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001e0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001e4:	83 c4 14             	add    $0x14,%esp
  8001e7:	5b                   	pop    %ebx
  8001e8:	5d                   	pop    %ebp
  8001e9:	c3                   	ret    

008001ea <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001ea:	55                   	push   %ebp
  8001eb:	89 e5                	mov    %esp,%ebp
  8001ed:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001f3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001fa:	00 00 00 
	b.cnt = 0;
  8001fd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800204:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800207:	8b 45 0c             	mov    0xc(%ebp),%eax
  80020a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80020e:	8b 45 08             	mov    0x8(%ebp),%eax
  800211:	89 44 24 08          	mov    %eax,0x8(%esp)
  800215:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80021b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80021f:	c7 04 24 a8 01 80 00 	movl   $0x8001a8,(%esp)
  800226:	e8 b7 01 00 00       	call   8003e2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80022b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800231:	89 44 24 04          	mov    %eax,0x4(%esp)
  800235:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80023b:	89 04 24             	mov    %eax,(%esp)
  80023e:	e8 8d 0a 00 00       	call   800cd0 <sys_cputs>

	return b.cnt;
}
  800243:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800249:	c9                   	leave  
  80024a:	c3                   	ret    

0080024b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80024b:	55                   	push   %ebp
  80024c:	89 e5                	mov    %esp,%ebp
  80024e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800251:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800254:	89 44 24 04          	mov    %eax,0x4(%esp)
  800258:	8b 45 08             	mov    0x8(%ebp),%eax
  80025b:	89 04 24             	mov    %eax,(%esp)
  80025e:	e8 87 ff ff ff       	call   8001ea <vcprintf>
	va_end(ap);

	return cnt;
}
  800263:	c9                   	leave  
  800264:	c3                   	ret    
  800265:	66 90                	xchg   %ax,%ax
  800267:	66 90                	xchg   %ax,%ax
  800269:	66 90                	xchg   %ax,%ax
  80026b:	66 90                	xchg   %ax,%ax
  80026d:	66 90                	xchg   %ax,%ax
  80026f:	90                   	nop

00800270 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	57                   	push   %edi
  800274:	56                   	push   %esi
  800275:	53                   	push   %ebx
  800276:	83 ec 4c             	sub    $0x4c,%esp
  800279:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80027c:	89 d7                	mov    %edx,%edi
  80027e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800281:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800284:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800287:	89 5d dc             	mov    %ebx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80028a:	b8 00 00 00 00       	mov    $0x0,%eax
  80028f:	39 d8                	cmp    %ebx,%eax
  800291:	72 17                	jb     8002aa <printnum+0x3a>
  800293:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800296:	39 5d 10             	cmp    %ebx,0x10(%ebp)
  800299:	76 0f                	jbe    8002aa <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80029b:	8b 75 14             	mov    0x14(%ebp),%esi
  80029e:	83 ee 01             	sub    $0x1,%esi
  8002a1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8002a4:	85 f6                	test   %esi,%esi
  8002a6:	7f 63                	jg     80030b <printnum+0x9b>
  8002a8:	eb 75                	jmp    80031f <printnum+0xaf>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002aa:	8b 5d 18             	mov    0x18(%ebp),%ebx
  8002ad:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8002b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8002b4:	83 e8 01             	sub    $0x1,%eax
  8002b7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002bb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002c2:	8b 44 24 08          	mov    0x8(%esp),%eax
  8002c6:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002ca:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002cd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8002d0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002d7:	00 
  8002d8:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8002db:	89 1c 24             	mov    %ebx,(%esp)
  8002de:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002e1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002e5:	e8 e6 17 00 00       	call   801ad0 <__udivdi3>
  8002ea:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8002ed:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8002f0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002f4:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002f8:	89 04 24             	mov    %eax,(%esp)
  8002fb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002ff:	89 fa                	mov    %edi,%edx
  800301:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800304:	e8 67 ff ff ff       	call   800270 <printnum>
  800309:	eb 14                	jmp    80031f <printnum+0xaf>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80030b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80030f:	8b 45 18             	mov    0x18(%ebp),%eax
  800312:	89 04 24             	mov    %eax,(%esp)
  800315:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800317:	83 ee 01             	sub    $0x1,%esi
  80031a:	75 ef                	jne    80030b <printnum+0x9b>
  80031c:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80031f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800323:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800327:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80032a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80032e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800335:	00 
  800336:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800339:	89 1c 24             	mov    %ebx,(%esp)
  80033c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80033f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800343:	e8 d8 18 00 00       	call   801c20 <__umoddi3>
  800348:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80034c:	0f be 80 5b 1e 80 00 	movsbl 0x801e5b(%eax),%eax
  800353:	89 04 24             	mov    %eax,(%esp)
  800356:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800359:	ff d0                	call   *%eax
}
  80035b:	83 c4 4c             	add    $0x4c,%esp
  80035e:	5b                   	pop    %ebx
  80035f:	5e                   	pop    %esi
  800360:	5f                   	pop    %edi
  800361:	5d                   	pop    %ebp
  800362:	c3                   	ret    

00800363 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800363:	55                   	push   %ebp
  800364:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800366:	83 fa 01             	cmp    $0x1,%edx
  800369:	7e 0e                	jle    800379 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80036b:	8b 10                	mov    (%eax),%edx
  80036d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800370:	89 08                	mov    %ecx,(%eax)
  800372:	8b 02                	mov    (%edx),%eax
  800374:	8b 52 04             	mov    0x4(%edx),%edx
  800377:	eb 22                	jmp    80039b <getuint+0x38>
	else if (lflag)
  800379:	85 d2                	test   %edx,%edx
  80037b:	74 10                	je     80038d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80037d:	8b 10                	mov    (%eax),%edx
  80037f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800382:	89 08                	mov    %ecx,(%eax)
  800384:	8b 02                	mov    (%edx),%eax
  800386:	ba 00 00 00 00       	mov    $0x0,%edx
  80038b:	eb 0e                	jmp    80039b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80038d:	8b 10                	mov    (%eax),%edx
  80038f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800392:	89 08                	mov    %ecx,(%eax)
  800394:	8b 02                	mov    (%edx),%eax
  800396:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80039b:	5d                   	pop    %ebp
  80039c:	c3                   	ret    

0080039d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80039d:	55                   	push   %ebp
  80039e:	89 e5                	mov    %esp,%ebp
  8003a0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003a3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003a7:	8b 10                	mov    (%eax),%edx
  8003a9:	3b 50 04             	cmp    0x4(%eax),%edx
  8003ac:	73 0a                	jae    8003b8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003b1:	88 0a                	mov    %cl,(%edx)
  8003b3:	83 c2 01             	add    $0x1,%edx
  8003b6:	89 10                	mov    %edx,(%eax)
}
  8003b8:	5d                   	pop    %ebp
  8003b9:	c3                   	ret    

008003ba <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003ba:	55                   	push   %ebp
  8003bb:	89 e5                	mov    %esp,%ebp
  8003bd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003c0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003c7:	8b 45 10             	mov    0x10(%ebp),%eax
  8003ca:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d8:	89 04 24             	mov    %eax,(%esp)
  8003db:	e8 02 00 00 00       	call   8003e2 <vprintfmt>
	va_end(ap);
}
  8003e0:	c9                   	leave  
  8003e1:	c3                   	ret    

008003e2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003e2:	55                   	push   %ebp
  8003e3:	89 e5                	mov    %esp,%ebp
  8003e5:	57                   	push   %edi
  8003e6:	56                   	push   %esi
  8003e7:	53                   	push   %ebx
  8003e8:	83 ec 4c             	sub    $0x4c,%esp
  8003eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8003ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003f1:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003f4:	eb 11                	jmp    800407 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003f6:	85 c0                	test   %eax,%eax
  8003f8:	0f 84 db 03 00 00    	je     8007d9 <vprintfmt+0x3f7>
				return;
			putch(ch, putdat);
  8003fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800402:	89 04 24             	mov    %eax,(%esp)
  800405:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800407:	0f b6 07             	movzbl (%edi),%eax
  80040a:	83 c7 01             	add    $0x1,%edi
  80040d:	83 f8 25             	cmp    $0x25,%eax
  800410:	75 e4                	jne    8003f6 <vprintfmt+0x14>
  800412:	c6 45 e4 20          	movb   $0x20,-0x1c(%ebp)
  800416:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80041d:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800424:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80042b:	ba 00 00 00 00       	mov    $0x0,%edx
  800430:	eb 2b                	jmp    80045d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800432:	8b 7d e0             	mov    -0x20(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800435:	c6 45 e4 2d          	movb   $0x2d,-0x1c(%ebp)
  800439:	eb 22                	jmp    80045d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043b:	8b 7d e0             	mov    -0x20(%ebp),%edi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80043e:	c6 45 e4 30          	movb   $0x30,-0x1c(%ebp)
  800442:	eb 19                	jmp    80045d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800444:	8b 7d e0             	mov    -0x20(%ebp),%edi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800447:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80044e:	eb 0d                	jmp    80045d <vprintfmt+0x7b>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800450:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800453:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800456:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045d:	0f b6 0f             	movzbl (%edi),%ecx
  800460:	8d 47 01             	lea    0x1(%edi),%eax
  800463:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800466:	0f b6 07             	movzbl (%edi),%eax
  800469:	83 e8 23             	sub    $0x23,%eax
  80046c:	3c 55                	cmp    $0x55,%al
  80046e:	0f 87 40 03 00 00    	ja     8007b4 <vprintfmt+0x3d2>
  800474:	0f b6 c0             	movzbl %al,%eax
  800477:	ff 24 85 a0 1f 80 00 	jmp    *0x801fa0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80047e:	83 e9 30             	sub    $0x30,%ecx
  800481:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				ch = *fmt;
  800484:	0f be 47 01          	movsbl 0x1(%edi),%eax
				if (ch < '0' || ch > '9')
  800488:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80048b:	83 f9 09             	cmp    $0x9,%ecx
  80048e:	77 57                	ja     8004e7 <vprintfmt+0x105>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800490:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800493:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800496:	8b 55 dc             	mov    -0x24(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800499:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80049c:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80049f:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8004a3:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8004a6:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8004a9:	83 f9 09             	cmp    $0x9,%ecx
  8004ac:	76 eb                	jbe    800499 <vprintfmt+0xb7>
  8004ae:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004b1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004b4:	eb 34                	jmp    8004ea <vprintfmt+0x108>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b9:	8d 48 04             	lea    0x4(%eax),%ecx
  8004bc:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004bf:	8b 00                	mov    (%eax),%eax
  8004c1:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c4:	8b 7d e0             	mov    -0x20(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004c7:	eb 21                	jmp    8004ea <vprintfmt+0x108>

		case '.':
			if (width < 0)
  8004c9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004cd:	0f 88 71 ff ff ff    	js     800444 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d3:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8004d6:	eb 85                	jmp    80045d <vprintfmt+0x7b>
  8004d8:	8b 7d e0             	mov    -0x20(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004db:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  8004e2:	e9 76 ff ff ff       	jmp    80045d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e7:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8004ea:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004ee:	0f 89 69 ff ff ff    	jns    80045d <vprintfmt+0x7b>
  8004f4:	e9 57 ff ff ff       	jmp    800450 <vprintfmt+0x6e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004f9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fc:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004ff:	e9 59 ff ff ff       	jmp    80045d <vprintfmt+0x7b>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800504:	8b 45 14             	mov    0x14(%ebp),%eax
  800507:	8d 50 04             	lea    0x4(%eax),%edx
  80050a:	89 55 14             	mov    %edx,0x14(%ebp)
  80050d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800511:	8b 00                	mov    (%eax),%eax
  800513:	89 04 24             	mov    %eax,(%esp)
  800516:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800518:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80051b:	e9 e7 fe ff ff       	jmp    800407 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800520:	8b 45 14             	mov    0x14(%ebp),%eax
  800523:	8d 50 04             	lea    0x4(%eax),%edx
  800526:	89 55 14             	mov    %edx,0x14(%ebp)
  800529:	8b 00                	mov    (%eax),%eax
  80052b:	89 c2                	mov    %eax,%edx
  80052d:	c1 fa 1f             	sar    $0x1f,%edx
  800530:	31 d0                	xor    %edx,%eax
  800532:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800534:	83 f8 0f             	cmp    $0xf,%eax
  800537:	7f 0b                	jg     800544 <vprintfmt+0x162>
  800539:	8b 14 85 00 21 80 00 	mov    0x802100(,%eax,4),%edx
  800540:	85 d2                	test   %edx,%edx
  800542:	75 20                	jne    800564 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  800544:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800548:	c7 44 24 08 73 1e 80 	movl   $0x801e73,0x8(%esp)
  80054f:	00 
  800550:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800554:	89 34 24             	mov    %esi,(%esp)
  800557:	e8 5e fe ff ff       	call   8003ba <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055c:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80055f:	e9 a3 fe ff ff       	jmp    800407 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800564:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800568:	c7 44 24 08 7c 1e 80 	movl   $0x801e7c,0x8(%esp)
  80056f:	00 
  800570:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800574:	89 34 24             	mov    %esi,(%esp)
  800577:	e8 3e fe ff ff       	call   8003ba <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057c:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80057f:	e9 83 fe ff ff       	jmp    800407 <vprintfmt+0x25>
  800584:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800587:	8b 7d d8             	mov    -0x28(%ebp),%edi
  80058a:	89 7d cc             	mov    %edi,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80058d:	8b 45 14             	mov    0x14(%ebp),%eax
  800590:	8d 50 04             	lea    0x4(%eax),%edx
  800593:	89 55 14             	mov    %edx,0x14(%ebp)
  800596:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800598:	85 ff                	test   %edi,%edi
  80059a:	b8 6c 1e 80 00       	mov    $0x801e6c,%eax
  80059f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005a2:	80 7d e4 2d          	cmpb   $0x2d,-0x1c(%ebp)
  8005a6:	74 06                	je     8005ae <vprintfmt+0x1cc>
  8005a8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8005ac:	7f 16                	jg     8005c4 <vprintfmt+0x1e2>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ae:	0f b6 17             	movzbl (%edi),%edx
  8005b1:	0f be c2             	movsbl %dl,%eax
  8005b4:	83 c7 01             	add    $0x1,%edi
  8005b7:	85 c0                	test   %eax,%eax
  8005b9:	0f 85 9f 00 00 00    	jne    80065e <vprintfmt+0x27c>
  8005bf:	e9 8b 00 00 00       	jmp    80064f <vprintfmt+0x26d>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005c8:	89 3c 24             	mov    %edi,(%esp)
  8005cb:	e8 c2 02 00 00       	call   800892 <strnlen>
  8005d0:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8005d3:	29 c2                	sub    %eax,%edx
  8005d5:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8005d8:	85 d2                	test   %edx,%edx
  8005da:	7e d2                	jle    8005ae <vprintfmt+0x1cc>
					putch(padc, putdat);
  8005dc:	0f be 4d e4          	movsbl -0x1c(%ebp),%ecx
  8005e0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8005e3:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8005e6:	89 d7                	mov    %edx,%edi
  8005e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005ef:	89 04 24             	mov    %eax,(%esp)
  8005f2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f4:	83 ef 01             	sub    $0x1,%edi
  8005f7:	75 ef                	jne    8005e8 <vprintfmt+0x206>
  8005f9:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8005fc:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005ff:	eb ad                	jmp    8005ae <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800601:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800605:	74 20                	je     800627 <vprintfmt+0x245>
  800607:	0f be d2             	movsbl %dl,%edx
  80060a:	83 ea 20             	sub    $0x20,%edx
  80060d:	83 fa 5e             	cmp    $0x5e,%edx
  800610:	76 15                	jbe    800627 <vprintfmt+0x245>
					putch('?', putdat);
  800612:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800615:	89 54 24 04          	mov    %edx,0x4(%esp)
  800619:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800620:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800623:	ff d1                	call   *%ecx
  800625:	eb 0f                	jmp    800636 <vprintfmt+0x254>
				else
					putch(ch, putdat);
  800627:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80062a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80062e:	89 04 24             	mov    %eax,(%esp)
  800631:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800634:	ff d1                	call   *%ecx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800636:	83 eb 01             	sub    $0x1,%ebx
  800639:	0f b6 17             	movzbl (%edi),%edx
  80063c:	0f be c2             	movsbl %dl,%eax
  80063f:	83 c7 01             	add    $0x1,%edi
  800642:	85 c0                	test   %eax,%eax
  800644:	75 24                	jne    80066a <vprintfmt+0x288>
  800646:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800649:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80064c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064f:	8b 7d e0             	mov    -0x20(%ebp),%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800652:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800656:	0f 8e ab fd ff ff    	jle    800407 <vprintfmt+0x25>
  80065c:	eb 20                	jmp    80067e <vprintfmt+0x29c>
  80065e:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800661:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800664:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  800667:	8b 5d d8             	mov    -0x28(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80066a:	85 f6                	test   %esi,%esi
  80066c:	78 93                	js     800601 <vprintfmt+0x21f>
  80066e:	83 ee 01             	sub    $0x1,%esi
  800671:	79 8e                	jns    800601 <vprintfmt+0x21f>
  800673:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800676:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800679:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80067c:	eb d1                	jmp    80064f <vprintfmt+0x26d>
  80067e:	8b 7d d8             	mov    -0x28(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800681:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800685:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80068c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80068e:	83 ef 01             	sub    $0x1,%edi
  800691:	75 ee                	jne    800681 <vprintfmt+0x29f>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800693:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800696:	e9 6c fd ff ff       	jmp    800407 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80069b:	83 fa 01             	cmp    $0x1,%edx
  80069e:	66 90                	xchg   %ax,%ax
  8006a0:	7e 16                	jle    8006b8 <vprintfmt+0x2d6>
		return va_arg(*ap, long long);
  8006a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a5:	8d 50 08             	lea    0x8(%eax),%edx
  8006a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ab:	8b 10                	mov    (%eax),%edx
  8006ad:	8b 48 04             	mov    0x4(%eax),%ecx
  8006b0:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8006b3:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8006b6:	eb 32                	jmp    8006ea <vprintfmt+0x308>
	else if (lflag)
  8006b8:	85 d2                	test   %edx,%edx
  8006ba:	74 18                	je     8006d4 <vprintfmt+0x2f2>
		return va_arg(*ap, long);
  8006bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bf:	8d 50 04             	lea    0x4(%eax),%edx
  8006c2:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c5:	8b 00                	mov    (%eax),%eax
  8006c7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006ca:	89 c1                	mov    %eax,%ecx
  8006cc:	c1 f9 1f             	sar    $0x1f,%ecx
  8006cf:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8006d2:	eb 16                	jmp    8006ea <vprintfmt+0x308>
	else
		return va_arg(*ap, int);
  8006d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d7:	8d 50 04             	lea    0x4(%eax),%edx
  8006da:	89 55 14             	mov    %edx,0x14(%ebp)
  8006dd:	8b 00                	mov    (%eax),%eax
  8006df:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006e2:	89 c7                	mov    %eax,%edi
  8006e4:	c1 ff 1f             	sar    $0x1f,%edi
  8006e7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006ea:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8006ed:	8b 55 d4             	mov    -0x2c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006f0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006f5:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8006f9:	79 7d                	jns    800778 <vprintfmt+0x396>
				putch('-', putdat);
  8006fb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ff:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800706:	ff d6                	call   *%esi
				num = -(long long) num;
  800708:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80070b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80070e:	f7 d8                	neg    %eax
  800710:	83 d2 00             	adc    $0x0,%edx
  800713:	f7 da                	neg    %edx
			}
			base = 10;
  800715:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80071a:	eb 5c                	jmp    800778 <vprintfmt+0x396>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80071c:	8d 45 14             	lea    0x14(%ebp),%eax
  80071f:	e8 3f fc ff ff       	call   800363 <getuint>
			base = 10;
  800724:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800729:	eb 4d                	jmp    800778 <vprintfmt+0x396>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80072b:	8d 45 14             	lea    0x14(%ebp),%eax
  80072e:	e8 30 fc ff ff       	call   800363 <getuint>
			base = 8;
  800733:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800738:	eb 3e                	jmp    800778 <vprintfmt+0x396>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80073a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80073e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800745:	ff d6                	call   *%esi
			putch('x', putdat);
  800747:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80074b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800752:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800754:	8b 45 14             	mov    0x14(%ebp),%eax
  800757:	8d 50 04             	lea    0x4(%eax),%edx
  80075a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80075d:	8b 00                	mov    (%eax),%eax
  80075f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800764:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800769:	eb 0d                	jmp    800778 <vprintfmt+0x396>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80076b:	8d 45 14             	lea    0x14(%ebp),%eax
  80076e:	e8 f0 fb ff ff       	call   800363 <getuint>
			base = 16;
  800773:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800778:	0f be 7d e4          	movsbl -0x1c(%ebp),%edi
  80077c:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800780:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800783:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800787:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80078b:	89 04 24             	mov    %eax,(%esp)
  80078e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800792:	89 da                	mov    %ebx,%edx
  800794:	89 f0                	mov    %esi,%eax
  800796:	e8 d5 fa ff ff       	call   800270 <printnum>
			break;
  80079b:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80079e:	e9 64 fc ff ff       	jmp    800407 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007a3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007a7:	89 0c 24             	mov    %ecx,(%esp)
  8007aa:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ac:	8b 7d e0             	mov    -0x20(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007af:	e9 53 fc ff ff       	jmp    800407 <vprintfmt+0x25>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007b4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007b8:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007bf:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007c1:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007c5:	0f 84 3c fc ff ff    	je     800407 <vprintfmt+0x25>
  8007cb:	83 ef 01             	sub    $0x1,%edi
  8007ce:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007d2:	75 f7                	jne    8007cb <vprintfmt+0x3e9>
  8007d4:	e9 2e fc ff ff       	jmp    800407 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8007d9:	83 c4 4c             	add    $0x4c,%esp
  8007dc:	5b                   	pop    %ebx
  8007dd:	5e                   	pop    %esi
  8007de:	5f                   	pop    %edi
  8007df:	5d                   	pop    %ebp
  8007e0:	c3                   	ret    

008007e1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007e1:	55                   	push   %ebp
  8007e2:	89 e5                	mov    %esp,%ebp
  8007e4:	83 ec 28             	sub    $0x28,%esp
  8007e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ea:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007ed:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007f0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007f4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007f7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007fe:	85 d2                	test   %edx,%edx
  800800:	7e 30                	jle    800832 <vsnprintf+0x51>
  800802:	85 c0                	test   %eax,%eax
  800804:	74 2c                	je     800832 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800806:	8b 45 14             	mov    0x14(%ebp),%eax
  800809:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80080d:	8b 45 10             	mov    0x10(%ebp),%eax
  800810:	89 44 24 08          	mov    %eax,0x8(%esp)
  800814:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800817:	89 44 24 04          	mov    %eax,0x4(%esp)
  80081b:	c7 04 24 9d 03 80 00 	movl   $0x80039d,(%esp)
  800822:	e8 bb fb ff ff       	call   8003e2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800827:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80082a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80082d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800830:	eb 05                	jmp    800837 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800832:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800837:	c9                   	leave  
  800838:	c3                   	ret    

00800839 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800839:	55                   	push   %ebp
  80083a:	89 e5                	mov    %esp,%ebp
  80083c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80083f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800842:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800846:	8b 45 10             	mov    0x10(%ebp),%eax
  800849:	89 44 24 08          	mov    %eax,0x8(%esp)
  80084d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800850:	89 44 24 04          	mov    %eax,0x4(%esp)
  800854:	8b 45 08             	mov    0x8(%ebp),%eax
  800857:	89 04 24             	mov    %eax,(%esp)
  80085a:	e8 82 ff ff ff       	call   8007e1 <vsnprintf>
	va_end(ap);

	return rc;
}
  80085f:	c9                   	leave  
  800860:	c3                   	ret    
  800861:	66 90                	xchg   %ax,%ax
  800863:	66 90                	xchg   %ax,%ax
  800865:	66 90                	xchg   %ax,%ax
  800867:	66 90                	xchg   %ax,%ax
  800869:	66 90                	xchg   %ax,%ax
  80086b:	66 90                	xchg   %ax,%ax
  80086d:	66 90                	xchg   %ax,%ax
  80086f:	90                   	nop

00800870 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800870:	55                   	push   %ebp
  800871:	89 e5                	mov    %esp,%ebp
  800873:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800876:	80 3a 00             	cmpb   $0x0,(%edx)
  800879:	74 10                	je     80088b <strlen+0x1b>
  80087b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800880:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800883:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800887:	75 f7                	jne    800880 <strlen+0x10>
  800889:	eb 05                	jmp    800890 <strlen+0x20>
  80088b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800890:	5d                   	pop    %ebp
  800891:	c3                   	ret    

00800892 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800892:	55                   	push   %ebp
  800893:	89 e5                	mov    %esp,%ebp
  800895:	53                   	push   %ebx
  800896:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800899:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80089c:	85 c9                	test   %ecx,%ecx
  80089e:	74 1c                	je     8008bc <strnlen+0x2a>
  8008a0:	80 3b 00             	cmpb   $0x0,(%ebx)
  8008a3:	74 1e                	je     8008c3 <strnlen+0x31>
  8008a5:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8008aa:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008ac:	39 ca                	cmp    %ecx,%edx
  8008ae:	74 18                	je     8008c8 <strnlen+0x36>
  8008b0:	83 c2 01             	add    $0x1,%edx
  8008b3:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8008b8:	75 f0                	jne    8008aa <strnlen+0x18>
  8008ba:	eb 0c                	jmp    8008c8 <strnlen+0x36>
  8008bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c1:	eb 05                	jmp    8008c8 <strnlen+0x36>
  8008c3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8008c8:	5b                   	pop    %ebx
  8008c9:	5d                   	pop    %ebp
  8008ca:	c3                   	ret    

008008cb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008cb:	55                   	push   %ebp
  8008cc:	89 e5                	mov    %esp,%ebp
  8008ce:	53                   	push   %ebx
  8008cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008d5:	89 c2                	mov    %eax,%edx
  8008d7:	0f b6 19             	movzbl (%ecx),%ebx
  8008da:	88 1a                	mov    %bl,(%edx)
  8008dc:	83 c2 01             	add    $0x1,%edx
  8008df:	83 c1 01             	add    $0x1,%ecx
  8008e2:	84 db                	test   %bl,%bl
  8008e4:	75 f1                	jne    8008d7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008e6:	5b                   	pop    %ebx
  8008e7:	5d                   	pop    %ebp
  8008e8:	c3                   	ret    

008008e9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008e9:	55                   	push   %ebp
  8008ea:	89 e5                	mov    %esp,%ebp
  8008ec:	53                   	push   %ebx
  8008ed:	83 ec 08             	sub    $0x8,%esp
  8008f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008f3:	89 1c 24             	mov    %ebx,(%esp)
  8008f6:	e8 75 ff ff ff       	call   800870 <strlen>
	strcpy(dst + len, src);
  8008fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008fe:	89 54 24 04          	mov    %edx,0x4(%esp)
  800902:	01 d8                	add    %ebx,%eax
  800904:	89 04 24             	mov    %eax,(%esp)
  800907:	e8 bf ff ff ff       	call   8008cb <strcpy>
	return dst;
}
  80090c:	89 d8                	mov    %ebx,%eax
  80090e:	83 c4 08             	add    $0x8,%esp
  800911:	5b                   	pop    %ebx
  800912:	5d                   	pop    %ebp
  800913:	c3                   	ret    

00800914 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800914:	55                   	push   %ebp
  800915:	89 e5                	mov    %esp,%ebp
  800917:	56                   	push   %esi
  800918:	53                   	push   %ebx
  800919:	8b 75 08             	mov    0x8(%ebp),%esi
  80091c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80091f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800922:	85 db                	test   %ebx,%ebx
  800924:	74 16                	je     80093c <strncpy+0x28>
	strcpy(dst + len, src);
	return dst;
}

char *
strncpy(char *dst, const char *src, size_t size) {
  800926:	01 f3                	add    %esi,%ebx
  800928:	89 f1                	mov    %esi,%ecx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  80092a:	0f b6 02             	movzbl (%edx),%eax
  80092d:	88 01                	mov    %al,(%ecx)
  80092f:	83 c1 01             	add    $0x1,%ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800932:	80 3a 01             	cmpb   $0x1,(%edx)
  800935:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800938:	39 d9                	cmp    %ebx,%ecx
  80093a:	75 ee                	jne    80092a <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80093c:	89 f0                	mov    %esi,%eax
  80093e:	5b                   	pop    %ebx
  80093f:	5e                   	pop    %esi
  800940:	5d                   	pop    %ebp
  800941:	c3                   	ret    

00800942 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800942:	55                   	push   %ebp
  800943:	89 e5                	mov    %esp,%ebp
  800945:	57                   	push   %edi
  800946:	56                   	push   %esi
  800947:	53                   	push   %ebx
  800948:	8b 7d 08             	mov    0x8(%ebp),%edi
  80094b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80094e:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800951:	89 f8                	mov    %edi,%eax
  800953:	85 f6                	test   %esi,%esi
  800955:	74 33                	je     80098a <strlcpy+0x48>
		while (--size > 0 && *src != '\0')
  800957:	83 fe 01             	cmp    $0x1,%esi
  80095a:	74 25                	je     800981 <strlcpy+0x3f>
  80095c:	0f b6 0b             	movzbl (%ebx),%ecx
  80095f:	84 c9                	test   %cl,%cl
  800961:	74 22                	je     800985 <strlcpy+0x43>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800963:	83 ee 02             	sub    $0x2,%esi
  800966:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80096b:	88 08                	mov    %cl,(%eax)
  80096d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800970:	39 f2                	cmp    %esi,%edx
  800972:	74 13                	je     800987 <strlcpy+0x45>
  800974:	83 c2 01             	add    $0x1,%edx
  800977:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80097b:	84 c9                	test   %cl,%cl
  80097d:	75 ec                	jne    80096b <strlcpy+0x29>
  80097f:	eb 06                	jmp    800987 <strlcpy+0x45>
  800981:	89 f8                	mov    %edi,%eax
  800983:	eb 02                	jmp    800987 <strlcpy+0x45>
  800985:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800987:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80098a:	29 f8                	sub    %edi,%eax
}
  80098c:	5b                   	pop    %ebx
  80098d:	5e                   	pop    %esi
  80098e:	5f                   	pop    %edi
  80098f:	5d                   	pop    %ebp
  800990:	c3                   	ret    

00800991 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800991:	55                   	push   %ebp
  800992:	89 e5                	mov    %esp,%ebp
  800994:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800997:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80099a:	0f b6 01             	movzbl (%ecx),%eax
  80099d:	84 c0                	test   %al,%al
  80099f:	74 15                	je     8009b6 <strcmp+0x25>
  8009a1:	3a 02                	cmp    (%edx),%al
  8009a3:	75 11                	jne    8009b6 <strcmp+0x25>
		p++, q++;
  8009a5:	83 c1 01             	add    $0x1,%ecx
  8009a8:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009ab:	0f b6 01             	movzbl (%ecx),%eax
  8009ae:	84 c0                	test   %al,%al
  8009b0:	74 04                	je     8009b6 <strcmp+0x25>
  8009b2:	3a 02                	cmp    (%edx),%al
  8009b4:	74 ef                	je     8009a5 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b6:	0f b6 c0             	movzbl %al,%eax
  8009b9:	0f b6 12             	movzbl (%edx),%edx
  8009bc:	29 d0                	sub    %edx,%eax
}
  8009be:	5d                   	pop    %ebp
  8009bf:	c3                   	ret    

008009c0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
  8009c3:	56                   	push   %esi
  8009c4:	53                   	push   %ebx
  8009c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009c8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009cb:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  8009ce:	85 f6                	test   %esi,%esi
  8009d0:	74 29                	je     8009fb <strncmp+0x3b>
  8009d2:	0f b6 03             	movzbl (%ebx),%eax
  8009d5:	84 c0                	test   %al,%al
  8009d7:	74 30                	je     800a09 <strncmp+0x49>
  8009d9:	3a 02                	cmp    (%edx),%al
  8009db:	75 2c                	jne    800a09 <strncmp+0x49>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}

int
strncmp(const char *p, const char *q, size_t n)
  8009dd:	8d 43 01             	lea    0x1(%ebx),%eax
  8009e0:	01 de                	add    %ebx,%esi
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  8009e2:	89 c3                	mov    %eax,%ebx
  8009e4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009e7:	39 f0                	cmp    %esi,%eax
  8009e9:	74 17                	je     800a02 <strncmp+0x42>
  8009eb:	0f b6 08             	movzbl (%eax),%ecx
  8009ee:	84 c9                	test   %cl,%cl
  8009f0:	74 17                	je     800a09 <strncmp+0x49>
  8009f2:	83 c0 01             	add    $0x1,%eax
  8009f5:	3a 0a                	cmp    (%edx),%cl
  8009f7:	74 e9                	je     8009e2 <strncmp+0x22>
  8009f9:	eb 0e                	jmp    800a09 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800a00:	eb 0f                	jmp    800a11 <strncmp+0x51>
  800a02:	b8 00 00 00 00       	mov    $0x0,%eax
  800a07:	eb 08                	jmp    800a11 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a09:	0f b6 03             	movzbl (%ebx),%eax
  800a0c:	0f b6 12             	movzbl (%edx),%edx
  800a0f:	29 d0                	sub    %edx,%eax
}
  800a11:	5b                   	pop    %ebx
  800a12:	5e                   	pop    %esi
  800a13:	5d                   	pop    %ebp
  800a14:	c3                   	ret    

00800a15 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	53                   	push   %ebx
  800a19:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1c:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800a1f:	0f b6 18             	movzbl (%eax),%ebx
  800a22:	84 db                	test   %bl,%bl
  800a24:	74 1d                	je     800a43 <strchr+0x2e>
  800a26:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800a28:	38 d3                	cmp    %dl,%bl
  800a2a:	75 06                	jne    800a32 <strchr+0x1d>
  800a2c:	eb 1a                	jmp    800a48 <strchr+0x33>
  800a2e:	38 ca                	cmp    %cl,%dl
  800a30:	74 16                	je     800a48 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a32:	83 c0 01             	add    $0x1,%eax
  800a35:	0f b6 10             	movzbl (%eax),%edx
  800a38:	84 d2                	test   %dl,%dl
  800a3a:	75 f2                	jne    800a2e <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800a3c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a41:	eb 05                	jmp    800a48 <strchr+0x33>
  800a43:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a48:	5b                   	pop    %ebx
  800a49:	5d                   	pop    %ebp
  800a4a:	c3                   	ret    

00800a4b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a4b:	55                   	push   %ebp
  800a4c:	89 e5                	mov    %esp,%ebp
  800a4e:	53                   	push   %ebx
  800a4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a52:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800a55:	0f b6 18             	movzbl (%eax),%ebx
  800a58:	84 db                	test   %bl,%bl
  800a5a:	74 16                	je     800a72 <strfind+0x27>
  800a5c:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800a5e:	38 d3                	cmp    %dl,%bl
  800a60:	75 06                	jne    800a68 <strfind+0x1d>
  800a62:	eb 0e                	jmp    800a72 <strfind+0x27>
  800a64:	38 ca                	cmp    %cl,%dl
  800a66:	74 0a                	je     800a72 <strfind+0x27>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a68:	83 c0 01             	add    $0x1,%eax
  800a6b:	0f b6 10             	movzbl (%eax),%edx
  800a6e:	84 d2                	test   %dl,%dl
  800a70:	75 f2                	jne    800a64 <strfind+0x19>
		if (*s == c)
			break;
	return (char *) s;
}
  800a72:	5b                   	pop    %ebx
  800a73:	5d                   	pop    %ebp
  800a74:	c3                   	ret    

00800a75 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a75:	55                   	push   %ebp
  800a76:	89 e5                	mov    %esp,%ebp
  800a78:	83 ec 0c             	sub    $0xc,%esp
  800a7b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800a7e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800a81:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800a84:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a87:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a8a:	85 c9                	test   %ecx,%ecx
  800a8c:	74 36                	je     800ac4 <memset+0x4f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a8e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a94:	75 28                	jne    800abe <memset+0x49>
  800a96:	f6 c1 03             	test   $0x3,%cl
  800a99:	75 23                	jne    800abe <memset+0x49>
		c &= 0xFF;
  800a9b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a9f:	89 d3                	mov    %edx,%ebx
  800aa1:	c1 e3 08             	shl    $0x8,%ebx
  800aa4:	89 d6                	mov    %edx,%esi
  800aa6:	c1 e6 18             	shl    $0x18,%esi
  800aa9:	89 d0                	mov    %edx,%eax
  800aab:	c1 e0 10             	shl    $0x10,%eax
  800aae:	09 f0                	or     %esi,%eax
  800ab0:	09 c2                	or     %eax,%edx
  800ab2:	89 d0                	mov    %edx,%eax
  800ab4:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ab6:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ab9:	fc                   	cld    
  800aba:	f3 ab                	rep stos %eax,%es:(%edi)
  800abc:	eb 06                	jmp    800ac4 <memset+0x4f>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800abe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac1:	fc                   	cld    
  800ac2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");

	return v;
}
  800ac4:	89 f8                	mov    %edi,%eax
  800ac6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ac9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800acc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800acf:	89 ec                	mov    %ebp,%esp
  800ad1:	5d                   	pop    %ebp
  800ad2:	c3                   	ret    

00800ad3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ad3:	55                   	push   %ebp
  800ad4:	89 e5                	mov    %esp,%ebp
  800ad6:	83 ec 08             	sub    $0x8,%esp
  800ad9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800adc:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800adf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ae5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ae8:	39 c6                	cmp    %eax,%esi
  800aea:	73 36                	jae    800b22 <memmove+0x4f>
  800aec:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800aef:	39 d0                	cmp    %edx,%eax
  800af1:	73 2f                	jae    800b22 <memmove+0x4f>
		s += n;
		d += n;
  800af3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800af6:	f6 c2 03             	test   $0x3,%dl
  800af9:	75 1b                	jne    800b16 <memmove+0x43>
  800afb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b01:	75 13                	jne    800b16 <memmove+0x43>
  800b03:	f6 c1 03             	test   $0x3,%cl
  800b06:	75 0e                	jne    800b16 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b08:	83 ef 04             	sub    $0x4,%edi
  800b0b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b0e:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b11:	fd                   	std    
  800b12:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b14:	eb 09                	jmp    800b1f <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b16:	83 ef 01             	sub    $0x1,%edi
  800b19:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b1c:	fd                   	std    
  800b1d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b1f:	fc                   	cld    
  800b20:	eb 20                	jmp    800b42 <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b22:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b28:	75 13                	jne    800b3d <memmove+0x6a>
  800b2a:	a8 03                	test   $0x3,%al
  800b2c:	75 0f                	jne    800b3d <memmove+0x6a>
  800b2e:	f6 c1 03             	test   $0x3,%cl
  800b31:	75 0a                	jne    800b3d <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b33:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b36:	89 c7                	mov    %eax,%edi
  800b38:	fc                   	cld    
  800b39:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b3b:	eb 05                	jmp    800b42 <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b3d:	89 c7                	mov    %eax,%edi
  800b3f:	fc                   	cld    
  800b40:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b42:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b45:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b48:	89 ec                	mov    %ebp,%esp
  800b4a:	5d                   	pop    %ebp
  800b4b:	c3                   	ret    

00800b4c <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800b4c:	55                   	push   %ebp
  800b4d:	89 e5                	mov    %esp,%ebp
  800b4f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b52:	8b 45 10             	mov    0x10(%ebp),%eax
  800b55:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b59:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b5c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b60:	8b 45 08             	mov    0x8(%ebp),%eax
  800b63:	89 04 24             	mov    %eax,(%esp)
  800b66:	e8 68 ff ff ff       	call   800ad3 <memmove>
}
  800b6b:	c9                   	leave  
  800b6c:	c3                   	ret    

00800b6d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b6d:	55                   	push   %ebp
  800b6e:	89 e5                	mov    %esp,%ebp
  800b70:	57                   	push   %edi
  800b71:	56                   	push   %esi
  800b72:	53                   	push   %ebx
  800b73:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b76:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b79:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b7c:	8d 78 ff             	lea    -0x1(%eax),%edi
  800b7f:	85 c0                	test   %eax,%eax
  800b81:	74 36                	je     800bb9 <memcmp+0x4c>
		if (*s1 != *s2)
  800b83:	0f b6 03             	movzbl (%ebx),%eax
  800b86:	0f b6 0e             	movzbl (%esi),%ecx
  800b89:	38 c8                	cmp    %cl,%al
  800b8b:	75 17                	jne    800ba4 <memcmp+0x37>
  800b8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b92:	eb 1a                	jmp    800bae <memcmp+0x41>
  800b94:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800b99:	83 c2 01             	add    $0x1,%edx
  800b9c:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800ba0:	38 c8                	cmp    %cl,%al
  800ba2:	74 0a                	je     800bae <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800ba4:	0f b6 c0             	movzbl %al,%eax
  800ba7:	0f b6 c9             	movzbl %cl,%ecx
  800baa:	29 c8                	sub    %ecx,%eax
  800bac:	eb 10                	jmp    800bbe <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bae:	39 fa                	cmp    %edi,%edx
  800bb0:	75 e2                	jne    800b94 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bb2:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb7:	eb 05                	jmp    800bbe <memcmp+0x51>
  800bb9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bbe:	5b                   	pop    %ebx
  800bbf:	5e                   	pop    %esi
  800bc0:	5f                   	pop    %edi
  800bc1:	5d                   	pop    %ebp
  800bc2:	c3                   	ret    

00800bc3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bc3:	55                   	push   %ebp
  800bc4:	89 e5                	mov    %esp,%ebp
  800bc6:	53                   	push   %ebx
  800bc7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800bcd:	89 c2                	mov    %eax,%edx
  800bcf:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bd2:	39 d0                	cmp    %edx,%eax
  800bd4:	73 13                	jae    800be9 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bd6:	89 d9                	mov    %ebx,%ecx
  800bd8:	38 18                	cmp    %bl,(%eax)
  800bda:	75 06                	jne    800be2 <memfind+0x1f>
  800bdc:	eb 0b                	jmp    800be9 <memfind+0x26>
  800bde:	38 08                	cmp    %cl,(%eax)
  800be0:	74 07                	je     800be9 <memfind+0x26>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800be2:	83 c0 01             	add    $0x1,%eax
  800be5:	39 d0                	cmp    %edx,%eax
  800be7:	75 f5                	jne    800bde <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800be9:	5b                   	pop    %ebx
  800bea:	5d                   	pop    %ebp
  800beb:	c3                   	ret    

00800bec <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	57                   	push   %edi
  800bf0:	56                   	push   %esi
  800bf1:	53                   	push   %ebx
  800bf2:	83 ec 04             	sub    $0x4,%esp
  800bf5:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bfb:	0f b6 02             	movzbl (%edx),%eax
  800bfe:	3c 09                	cmp    $0x9,%al
  800c00:	74 04                	je     800c06 <strtol+0x1a>
  800c02:	3c 20                	cmp    $0x20,%al
  800c04:	75 0e                	jne    800c14 <strtol+0x28>
		s++;
  800c06:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c09:	0f b6 02             	movzbl (%edx),%eax
  800c0c:	3c 09                	cmp    $0x9,%al
  800c0e:	74 f6                	je     800c06 <strtol+0x1a>
  800c10:	3c 20                	cmp    $0x20,%al
  800c12:	74 f2                	je     800c06 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c14:	3c 2b                	cmp    $0x2b,%al
  800c16:	75 0a                	jne    800c22 <strtol+0x36>
		s++;
  800c18:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c1b:	bf 00 00 00 00       	mov    $0x0,%edi
  800c20:	eb 10                	jmp    800c32 <strtol+0x46>
  800c22:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c27:	3c 2d                	cmp    $0x2d,%al
  800c29:	75 07                	jne    800c32 <strtol+0x46>
		s++, neg = 1;
  800c2b:	83 c2 01             	add    $0x1,%edx
  800c2e:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c32:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c38:	75 15                	jne    800c4f <strtol+0x63>
  800c3a:	80 3a 30             	cmpb   $0x30,(%edx)
  800c3d:	75 10                	jne    800c4f <strtol+0x63>
  800c3f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c43:	75 0a                	jne    800c4f <strtol+0x63>
		s += 2, base = 16;
  800c45:	83 c2 02             	add    $0x2,%edx
  800c48:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c4d:	eb 10                	jmp    800c5f <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800c4f:	85 db                	test   %ebx,%ebx
  800c51:	75 0c                	jne    800c5f <strtol+0x73>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c53:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c55:	80 3a 30             	cmpb   $0x30,(%edx)
  800c58:	75 05                	jne    800c5f <strtol+0x73>
		s++, base = 8;
  800c5a:	83 c2 01             	add    $0x1,%edx
  800c5d:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800c5f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c64:	89 5d f0             	mov    %ebx,-0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c67:	0f b6 0a             	movzbl (%edx),%ecx
  800c6a:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800c6d:	89 f3                	mov    %esi,%ebx
  800c6f:	80 fb 09             	cmp    $0x9,%bl
  800c72:	77 08                	ja     800c7c <strtol+0x90>
			dig = *s - '0';
  800c74:	0f be c9             	movsbl %cl,%ecx
  800c77:	83 e9 30             	sub    $0x30,%ecx
  800c7a:	eb 22                	jmp    800c9e <strtol+0xb2>
		else if (*s >= 'a' && *s <= 'z')
  800c7c:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800c7f:	89 f3                	mov    %esi,%ebx
  800c81:	80 fb 19             	cmp    $0x19,%bl
  800c84:	77 08                	ja     800c8e <strtol+0xa2>
			dig = *s - 'a' + 10;
  800c86:	0f be c9             	movsbl %cl,%ecx
  800c89:	83 e9 57             	sub    $0x57,%ecx
  800c8c:	eb 10                	jmp    800c9e <strtol+0xb2>
		else if (*s >= 'A' && *s <= 'Z')
  800c8e:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800c91:	89 f3                	mov    %esi,%ebx
  800c93:	80 fb 19             	cmp    $0x19,%bl
  800c96:	77 16                	ja     800cae <strtol+0xc2>
			dig = *s - 'A' + 10;
  800c98:	0f be c9             	movsbl %cl,%ecx
  800c9b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c9e:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800ca1:	7d 0f                	jge    800cb2 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800ca3:	83 c2 01             	add    $0x1,%edx
  800ca6:	0f af 45 f0          	imul   -0x10(%ebp),%eax
  800caa:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800cac:	eb b9                	jmp    800c67 <strtol+0x7b>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800cae:	89 c1                	mov    %eax,%ecx
  800cb0:	eb 02                	jmp    800cb4 <strtol+0xc8>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800cb2:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800cb4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cb8:	74 05                	je     800cbf <strtol+0xd3>
		*endptr = (char *) s;
  800cba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800cbd:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800cbf:	89 ca                	mov    %ecx,%edx
  800cc1:	f7 da                	neg    %edx
  800cc3:	85 ff                	test   %edi,%edi
  800cc5:	0f 45 c2             	cmovne %edx,%eax
}
  800cc8:	83 c4 04             	add    $0x4,%esp
  800ccb:	5b                   	pop    %ebx
  800ccc:	5e                   	pop    %esi
  800ccd:	5f                   	pop    %edi
  800cce:	5d                   	pop    %ebp
  800ccf:	c3                   	ret    

00800cd0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cd0:	55                   	push   %ebp
  800cd1:	89 e5                	mov    %esp,%ebp
  800cd3:	83 ec 0c             	sub    $0xc,%esp
  800cd6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cd9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cdc:	89 7d fc             	mov    %edi,-0x4(%ebp)
static inline uint32_t

get_cpu_features(void)
{
	uint32_t feature;
	__asm __volatile(" movl $1, %%eax\n\t"
  800cdf:	b8 01 00 00 00       	mov    $0x1,%eax
  800ce4:	0f a2                	cpuid  
  800ce6:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce8:	b8 00 00 00 00       	mov    $0x0,%eax
  800ced:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf3:	89 c3                	mov    %eax,%ebx
  800cf5:	89 c7                	mov    %eax,%edi
  800cf7:	89 c6                	mov    %eax,%esi
  800cf9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cfb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cfe:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d01:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d04:	89 ec                	mov    %ebp,%esp
  800d06:	5d                   	pop    %ebp
  800d07:	c3                   	ret    

00800d08 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d08:	55                   	push   %ebp
  800d09:	89 e5                	mov    %esp,%ebp
  800d0b:	83 ec 0c             	sub    $0xc,%esp
  800d0e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d11:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d14:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d17:	b8 01 00 00 00       	mov    $0x1,%eax
  800d1c:	0f a2                	cpuid  
  800d1e:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d20:	ba 00 00 00 00       	mov    $0x0,%edx
  800d25:	b8 01 00 00 00       	mov    $0x1,%eax
  800d2a:	89 d1                	mov    %edx,%ecx
  800d2c:	89 d3                	mov    %edx,%ebx
  800d2e:	89 d7                	mov    %edx,%edi
  800d30:	89 d6                	mov    %edx,%esi
  800d32:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d34:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d37:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d3a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d3d:	89 ec                	mov    %ebp,%esp
  800d3f:	5d                   	pop    %ebp
  800d40:	c3                   	ret    

00800d41 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d41:	55                   	push   %ebp
  800d42:	89 e5                	mov    %esp,%ebp
  800d44:	83 ec 38             	sub    $0x38,%esp
  800d47:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d4a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d4d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d50:	b8 01 00 00 00       	mov    $0x1,%eax
  800d55:	0f a2                	cpuid  
  800d57:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d59:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d5e:	b8 03 00 00 00       	mov    $0x3,%eax
  800d63:	8b 55 08             	mov    0x8(%ebp),%edx
  800d66:	89 cb                	mov    %ecx,%ebx
  800d68:	89 cf                	mov    %ecx,%edi
  800d6a:	89 ce                	mov    %ecx,%esi
  800d6c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d6e:	85 c0                	test   %eax,%eax
  800d70:	7e 28                	jle    800d9a <sys_env_destroy+0x59>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d72:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d76:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800d7d:	00 
  800d7e:	c7 44 24 08 5f 21 80 	movl   $0x80215f,0x8(%esp)
  800d85:	00 
  800d86:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800d8d:	00 
  800d8e:	c7 04 24 7c 21 80 00 	movl   $0x80217c,(%esp)
  800d95:	e8 b6 f3 ff ff       	call   800150 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d9a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d9d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800da0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800da3:	89 ec                	mov    %ebp,%esp
  800da5:	5d                   	pop    %ebp
  800da6:	c3                   	ret    

00800da7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800da7:	55                   	push   %ebp
  800da8:	89 e5                	mov    %esp,%ebp
  800daa:	83 ec 0c             	sub    $0xc,%esp
  800dad:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800db0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800db3:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800db6:	b8 01 00 00 00       	mov    $0x1,%eax
  800dbb:	0f a2                	cpuid  
  800dbd:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dbf:	ba 00 00 00 00       	mov    $0x0,%edx
  800dc4:	b8 02 00 00 00       	mov    $0x2,%eax
  800dc9:	89 d1                	mov    %edx,%ecx
  800dcb:	89 d3                	mov    %edx,%ebx
  800dcd:	89 d7                	mov    %edx,%edi
  800dcf:	89 d6                	mov    %edx,%esi
  800dd1:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800dd3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dd6:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dd9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ddc:	89 ec                	mov    %ebp,%esp
  800dde:	5d                   	pop    %ebp
  800ddf:	c3                   	ret    

00800de0 <sys_yield>:

void
sys_yield(void)
{
  800de0:	55                   	push   %ebp
  800de1:	89 e5                	mov    %esp,%ebp
  800de3:	83 ec 0c             	sub    $0xc,%esp
  800de6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800de9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dec:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800def:	b8 01 00 00 00       	mov    $0x1,%eax
  800df4:	0f a2                	cpuid  
  800df6:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df8:	ba 00 00 00 00       	mov    $0x0,%edx
  800dfd:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e02:	89 d1                	mov    %edx,%ecx
  800e04:	89 d3                	mov    %edx,%ebx
  800e06:	89 d7                	mov    %edx,%edi
  800e08:	89 d6                	mov    %edx,%esi
  800e0a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e0c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e0f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e12:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e15:	89 ec                	mov    %ebp,%esp
  800e17:	5d                   	pop    %ebp
  800e18:	c3                   	ret    

00800e19 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e19:	55                   	push   %ebp
  800e1a:	89 e5                	mov    %esp,%ebp
  800e1c:	83 ec 38             	sub    $0x38,%esp
  800e1f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e22:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e25:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e28:	b8 01 00 00 00       	mov    $0x1,%eax
  800e2d:	0f a2                	cpuid  
  800e2f:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e31:	be 00 00 00 00       	mov    $0x0,%esi
  800e36:	b8 04 00 00 00       	mov    $0x4,%eax
  800e3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e41:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e44:	89 f7                	mov    %esi,%edi
  800e46:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e48:	85 c0                	test   %eax,%eax
  800e4a:	7e 28                	jle    800e74 <sys_page_alloc+0x5b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e4c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e50:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800e57:	00 
  800e58:	c7 44 24 08 5f 21 80 	movl   $0x80215f,0x8(%esp)
  800e5f:	00 
  800e60:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800e67:	00 
  800e68:	c7 04 24 7c 21 80 00 	movl   $0x80217c,(%esp)
  800e6f:	e8 dc f2 ff ff       	call   800150 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e74:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e77:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e7a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e7d:	89 ec                	mov    %ebp,%esp
  800e7f:	5d                   	pop    %ebp
  800e80:	c3                   	ret    

00800e81 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e81:	55                   	push   %ebp
  800e82:	89 e5                	mov    %esp,%ebp
  800e84:	83 ec 38             	sub    $0x38,%esp
  800e87:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e8a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e8d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e90:	b8 01 00 00 00       	mov    $0x1,%eax
  800e95:	0f a2                	cpuid  
  800e97:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e99:	b8 05 00 00 00       	mov    $0x5,%eax
  800e9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ea7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800eaa:	8b 75 18             	mov    0x18(%ebp),%esi
  800ead:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eaf:	85 c0                	test   %eax,%eax
  800eb1:	7e 28                	jle    800edb <sys_page_map+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eb7:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800ebe:	00 
  800ebf:	c7 44 24 08 5f 21 80 	movl   $0x80215f,0x8(%esp)
  800ec6:	00 
  800ec7:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800ece:	00 
  800ecf:	c7 04 24 7c 21 80 00 	movl   $0x80217c,(%esp)
  800ed6:	e8 75 f2 ff ff       	call   800150 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800edb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ede:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ee1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ee4:	89 ec                	mov    %ebp,%esp
  800ee6:	5d                   	pop    %ebp
  800ee7:	c3                   	ret    

00800ee8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ee8:	55                   	push   %ebp
  800ee9:	89 e5                	mov    %esp,%ebp
  800eeb:	83 ec 38             	sub    $0x38,%esp
  800eee:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ef1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ef4:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800ef7:	b8 01 00 00 00       	mov    $0x1,%eax
  800efc:	0f a2                	cpuid  
  800efe:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f00:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f05:	b8 06 00 00 00       	mov    $0x6,%eax
  800f0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f10:	89 df                	mov    %ebx,%edi
  800f12:	89 de                	mov    %ebx,%esi
  800f14:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f16:	85 c0                	test   %eax,%eax
  800f18:	7e 28                	jle    800f42 <sys_page_unmap+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f1a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f1e:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f25:	00 
  800f26:	c7 44 24 08 5f 21 80 	movl   $0x80215f,0x8(%esp)
  800f2d:	00 
  800f2e:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800f35:	00 
  800f36:	c7 04 24 7c 21 80 00 	movl   $0x80217c,(%esp)
  800f3d:	e8 0e f2 ff ff       	call   800150 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f42:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f45:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f48:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f4b:	89 ec                	mov    %ebp,%esp
  800f4d:	5d                   	pop    %ebp
  800f4e:	c3                   	ret    

00800f4f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f4f:	55                   	push   %ebp
  800f50:	89 e5                	mov    %esp,%ebp
  800f52:	83 ec 38             	sub    $0x38,%esp
  800f55:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f58:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f5b:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800f5e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f63:	0f a2                	cpuid  
  800f65:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f67:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f6c:	b8 08 00 00 00       	mov    $0x8,%eax
  800f71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f74:	8b 55 08             	mov    0x8(%ebp),%edx
  800f77:	89 df                	mov    %ebx,%edi
  800f79:	89 de                	mov    %ebx,%esi
  800f7b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f7d:	85 c0                	test   %eax,%eax
  800f7f:	7e 28                	jle    800fa9 <sys_env_set_status+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f81:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f85:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800f8c:	00 
  800f8d:	c7 44 24 08 5f 21 80 	movl   $0x80215f,0x8(%esp)
  800f94:	00 
  800f95:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800f9c:	00 
  800f9d:	c7 04 24 7c 21 80 00 	movl   $0x80217c,(%esp)
  800fa4:	e8 a7 f1 ff ff       	call   800150 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800fa9:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fac:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800faf:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fb2:	89 ec                	mov    %ebp,%esp
  800fb4:	5d                   	pop    %ebp
  800fb5:	c3                   	ret    

00800fb6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800fb6:	55                   	push   %ebp
  800fb7:	89 e5                	mov    %esp,%ebp
  800fb9:	83 ec 38             	sub    $0x38,%esp
  800fbc:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fbf:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fc2:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800fc5:	b8 01 00 00 00       	mov    $0x1,%eax
  800fca:	0f a2                	cpuid  
  800fcc:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fce:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fd3:	b8 09 00 00 00       	mov    $0x9,%eax
  800fd8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fdb:	8b 55 08             	mov    0x8(%ebp),%edx
  800fde:	89 df                	mov    %ebx,%edi
  800fe0:	89 de                	mov    %ebx,%esi
  800fe2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fe4:	85 c0                	test   %eax,%eax
  800fe6:	7e 28                	jle    801010 <sys_env_set_trapframe+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fe8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fec:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ff3:	00 
  800ff4:	c7 44 24 08 5f 21 80 	movl   $0x80215f,0x8(%esp)
  800ffb:	00 
  800ffc:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  801003:	00 
  801004:	c7 04 24 7c 21 80 00 	movl   $0x80217c,(%esp)
  80100b:	e8 40 f1 ff ff       	call   800150 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801010:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801013:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801016:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801019:	89 ec                	mov    %ebp,%esp
  80101b:	5d                   	pop    %ebp
  80101c:	c3                   	ret    

0080101d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80101d:	55                   	push   %ebp
  80101e:	89 e5                	mov    %esp,%ebp
  801020:	83 ec 38             	sub    $0x38,%esp
  801023:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801026:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801029:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80102c:	b8 01 00 00 00       	mov    $0x1,%eax
  801031:	0f a2                	cpuid  
  801033:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801035:	bb 00 00 00 00       	mov    $0x0,%ebx
  80103a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80103f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801042:	8b 55 08             	mov    0x8(%ebp),%edx
  801045:	89 df                	mov    %ebx,%edi
  801047:	89 de                	mov    %ebx,%esi
  801049:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80104b:	85 c0                	test   %eax,%eax
  80104d:	7e 28                	jle    801077 <sys_env_set_pgfault_upcall+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80104f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801053:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80105a:	00 
  80105b:	c7 44 24 08 5f 21 80 	movl   $0x80215f,0x8(%esp)
  801062:	00 
  801063:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  80106a:	00 
  80106b:	c7 04 24 7c 21 80 00 	movl   $0x80217c,(%esp)
  801072:	e8 d9 f0 ff ff       	call   800150 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801077:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80107a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80107d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801080:	89 ec                	mov    %ebp,%esp
  801082:	5d                   	pop    %ebp
  801083:	c3                   	ret    

00801084 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801084:	55                   	push   %ebp
  801085:	89 e5                	mov    %esp,%ebp
  801087:	83 ec 0c             	sub    $0xc,%esp
  80108a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80108d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801090:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801093:	b8 01 00 00 00       	mov    $0x1,%eax
  801098:	0f a2                	cpuid  
  80109a:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80109c:	be 00 00 00 00       	mov    $0x0,%esi
  8010a1:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010af:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010b2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010b4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010b7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010ba:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010bd:	89 ec                	mov    %ebp,%esp
  8010bf:	5d                   	pop    %ebp
  8010c0:	c3                   	ret    

008010c1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010c1:	55                   	push   %ebp
  8010c2:	89 e5                	mov    %esp,%ebp
  8010c4:	83 ec 38             	sub    $0x38,%esp
  8010c7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010ca:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010cd:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8010d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8010d5:	0f a2                	cpuid  
  8010d7:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010d9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010de:	b8 0d 00 00 00       	mov    $0xd,%eax
  8010e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8010e6:	89 cb                	mov    %ecx,%ebx
  8010e8:	89 cf                	mov    %ecx,%edi
  8010ea:	89 ce                	mov    %ecx,%esi
  8010ec:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010ee:	85 c0                	test   %eax,%eax
  8010f0:	7e 28                	jle    80111a <sys_ipc_recv+0x59>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010f2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010f6:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8010fd:	00 
  8010fe:	c7 44 24 08 5f 21 80 	movl   $0x80215f,0x8(%esp)
  801105:	00 
  801106:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  80110d:	00 
  80110e:	c7 04 24 7c 21 80 00 	movl   $0x80217c,(%esp)
  801115:	e8 36 f0 ff ff       	call   800150 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80111a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80111d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801120:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801123:	89 ec                	mov    %ebp,%esp
  801125:	5d                   	pop    %ebp
  801126:	c3                   	ret    
  801127:	90                   	nop

00801128 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801128:	55                   	push   %ebp
  801129:	89 e5                	mov    %esp,%ebp
  80112b:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80112e:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  801135:	75 54                	jne    80118b <set_pgfault_handler+0x63>
		// First time through!
		// LAB 4: Your code here.
		if((r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U|PTE_P|PTE_W)))
  801137:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80113e:	00 
  80113f:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801146:	ee 
  801147:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80114e:	e8 c6 fc ff ff       	call   800e19 <sys_page_alloc>
  801153:	85 c0                	test   %eax,%eax
  801155:	74 20                	je     801177 <set_pgfault_handler+0x4f>
			panic("sys_page_alloc() failed in set_pgfault_handler()[%e]\n", r);
  801157:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80115b:	c7 44 24 08 8c 21 80 	movl   $0x80218c,0x8(%esp)
  801162:	00 
  801163:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  80116a:	00 
  80116b:	c7 04 24 c2 21 80 00 	movl   $0x8021c2,(%esp)
  801172:	e8 d9 ef ff ff       	call   800150 <_panic>
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801177:	c7 44 24 04 98 11 80 	movl   $0x801198,0x4(%esp)
  80117e:	00 
  80117f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801186:	e8 92 fe ff ff       	call   80101d <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80118b:	8b 45 08             	mov    0x8(%ebp),%eax
  80118e:	a3 08 40 80 00       	mov    %eax,0x804008
}
  801193:	c9                   	leave  
  801194:	c3                   	ret    
  801195:	66 90                	xchg   %ax,%ax
  801197:	90                   	nop

00801198 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801198:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801199:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  80119e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8011a0:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	// @yuhangj: get reserved place under old esp
	addl $0x08, %esp;
  8011a3:	83 c4 08             	add    $0x8,%esp

	movl 0x28(%esp), %eax;
  8011a6:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x04, %eax;
  8011aa:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x28(%esp);
  8011ad:	89 44 24 28          	mov    %eax,0x28(%esp)

    // @yuhangj: store old eip into the reserved place under old esp
	movl 0x20(%esp), %ebx;
  8011b1:	8b 5c 24 20          	mov    0x20(%esp),%ebx
	movl %ebx, (%eax);
  8011b5:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  8011b7:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp;
  8011b8:	83 c4 04             	add    $0x4,%esp
	popfl
  8011bb:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  8011bc:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  8011bd:	c3                   	ret    
  8011be:	66 90                	xchg   %ax,%ax

008011c0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011c0:	55                   	push   %ebp
  8011c1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c6:	05 00 00 00 30       	add    $0x30000000,%eax
  8011cb:	c1 e8 0c             	shr    $0xc,%eax
}
  8011ce:	5d                   	pop    %ebp
  8011cf:	c3                   	ret    

008011d0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011d0:	55                   	push   %ebp
  8011d1:	89 e5                	mov    %esp,%ebp
  8011d3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8011d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d9:	89 04 24             	mov    %eax,(%esp)
  8011dc:	e8 df ff ff ff       	call   8011c0 <fd2num>
  8011e1:	c1 e0 0c             	shl    $0xc,%eax
  8011e4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011e9:	c9                   	leave  
  8011ea:	c3                   	ret    

008011eb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011eb:	55                   	push   %ebp
  8011ec:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8011ee:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8011f3:	a8 01                	test   $0x1,%al
  8011f5:	74 34                	je     80122b <fd_alloc+0x40>
  8011f7:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8011fc:	a8 01                	test   $0x1,%al
  8011fe:	74 32                	je     801232 <fd_alloc+0x47>
  801200:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801205:	89 c1                	mov    %eax,%ecx
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801207:	89 c2                	mov    %eax,%edx
  801209:	c1 ea 16             	shr    $0x16,%edx
  80120c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801213:	f6 c2 01             	test   $0x1,%dl
  801216:	74 1f                	je     801237 <fd_alloc+0x4c>
  801218:	89 c2                	mov    %eax,%edx
  80121a:	c1 ea 0c             	shr    $0xc,%edx
  80121d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801224:	f6 c2 01             	test   $0x1,%dl
  801227:	75 1a                	jne    801243 <fd_alloc+0x58>
  801229:	eb 0c                	jmp    801237 <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80122b:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801230:	eb 05                	jmp    801237 <fd_alloc+0x4c>
  801232:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  801237:	8b 45 08             	mov    0x8(%ebp),%eax
  80123a:	89 08                	mov    %ecx,(%eax)
			return 0;
  80123c:	b8 00 00 00 00       	mov    $0x0,%eax
  801241:	eb 1a                	jmp    80125d <fd_alloc+0x72>
  801243:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801248:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80124d:	75 b6                	jne    801205 <fd_alloc+0x1a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80124f:	8b 45 08             	mov    0x8(%ebp),%eax
  801252:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801258:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80125d:	5d                   	pop    %ebp
  80125e:	c3                   	ret    

0080125f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80125f:	55                   	push   %ebp
  801260:	89 e5                	mov    %esp,%ebp
  801262:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801265:	83 f8 1f             	cmp    $0x1f,%eax
  801268:	77 36                	ja     8012a0 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80126a:	c1 e0 0c             	shl    $0xc,%eax
  80126d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801272:	89 c2                	mov    %eax,%edx
  801274:	c1 ea 16             	shr    $0x16,%edx
  801277:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80127e:	f6 c2 01             	test   $0x1,%dl
  801281:	74 24                	je     8012a7 <fd_lookup+0x48>
  801283:	89 c2                	mov    %eax,%edx
  801285:	c1 ea 0c             	shr    $0xc,%edx
  801288:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80128f:	f6 c2 01             	test   $0x1,%dl
  801292:	74 1a                	je     8012ae <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801294:	8b 55 0c             	mov    0xc(%ebp),%edx
  801297:	89 02                	mov    %eax,(%edx)
	return 0;
  801299:	b8 00 00 00 00       	mov    $0x0,%eax
  80129e:	eb 13                	jmp    8012b3 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  8012a0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012a5:	eb 0c                	jmp    8012b3 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  8012a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012ac:	eb 05                	jmp    8012b3 <fd_lookup+0x54>
  8012ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012b3:	5d                   	pop    %ebp
  8012b4:	c3                   	ret    

008012b5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012b5:	55                   	push   %ebp
  8012b6:	89 e5                	mov    %esp,%ebp
  8012b8:	83 ec 18             	sub    $0x18,%esp
  8012bb:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8012be:	39 05 04 30 80 00    	cmp    %eax,0x803004
  8012c4:	75 10                	jne    8012d6 <dev_lookup+0x21>
			*dev = devtab[i];
  8012c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012c9:	c7 00 04 30 80 00    	movl   $0x803004,(%eax)
			return 0;
  8012cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8012d4:	eb 2b                	jmp    801301 <dev_lookup+0x4c>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012d6:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8012dc:	8b 52 48             	mov    0x48(%edx),%edx
  8012df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8012e7:	c7 04 24 d0 21 80 00 	movl   $0x8021d0,(%esp)
  8012ee:	e8 58 ef ff ff       	call   80024b <cprintf>
	*dev = 0;
  8012f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012f6:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	return -E_INVAL;
  8012fc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801301:	c9                   	leave  
  801302:	c3                   	ret    

00801303 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801303:	55                   	push   %ebp
  801304:	89 e5                	mov    %esp,%ebp
  801306:	83 ec 38             	sub    $0x38,%esp
  801309:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80130c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80130f:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801312:	8b 7d 08             	mov    0x8(%ebp),%edi
  801315:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801318:	89 3c 24             	mov    %edi,(%esp)
  80131b:	e8 a0 fe ff ff       	call   8011c0 <fd2num>
  801320:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  801323:	89 54 24 04          	mov    %edx,0x4(%esp)
  801327:	89 04 24             	mov    %eax,(%esp)
  80132a:	e8 30 ff ff ff       	call   80125f <fd_lookup>
  80132f:	89 c3                	mov    %eax,%ebx
  801331:	85 c0                	test   %eax,%eax
  801333:	78 05                	js     80133a <fd_close+0x37>
	    || fd != fd2)
  801335:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  801338:	74 0c                	je     801346 <fd_close+0x43>
		return (must_exist ? r : 0);
  80133a:	85 f6                	test   %esi,%esi
  80133c:	b8 00 00 00 00       	mov    $0x0,%eax
  801341:	0f 44 d8             	cmove  %eax,%ebx
  801344:	eb 3d                	jmp    801383 <fd_close+0x80>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801346:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801349:	89 44 24 04          	mov    %eax,0x4(%esp)
  80134d:	8b 07                	mov    (%edi),%eax
  80134f:	89 04 24             	mov    %eax,(%esp)
  801352:	e8 5e ff ff ff       	call   8012b5 <dev_lookup>
  801357:	89 c3                	mov    %eax,%ebx
  801359:	85 c0                	test   %eax,%eax
  80135b:	78 16                	js     801373 <fd_close+0x70>
		if (dev->dev_close)
  80135d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801360:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801363:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801368:	85 c0                	test   %eax,%eax
  80136a:	74 07                	je     801373 <fd_close+0x70>
			r = (*dev->dev_close)(fd);
  80136c:	89 3c 24             	mov    %edi,(%esp)
  80136f:	ff d0                	call   *%eax
  801371:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801373:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801377:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80137e:	e8 65 fb ff ff       	call   800ee8 <sys_page_unmap>
	return r;
}
  801383:	89 d8                	mov    %ebx,%eax
  801385:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801388:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80138b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80138e:	89 ec                	mov    %ebp,%esp
  801390:	5d                   	pop    %ebp
  801391:	c3                   	ret    

00801392 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801392:	55                   	push   %ebp
  801393:	89 e5                	mov    %esp,%ebp
  801395:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801398:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80139b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80139f:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a2:	89 04 24             	mov    %eax,(%esp)
  8013a5:	e8 b5 fe ff ff       	call   80125f <fd_lookup>
  8013aa:	85 c0                	test   %eax,%eax
  8013ac:	78 13                	js     8013c1 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8013ae:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8013b5:	00 
  8013b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013b9:	89 04 24             	mov    %eax,(%esp)
  8013bc:	e8 42 ff ff ff       	call   801303 <fd_close>
}
  8013c1:	c9                   	leave  
  8013c2:	c3                   	ret    

008013c3 <close_all>:

void
close_all(void)
{
  8013c3:	55                   	push   %ebp
  8013c4:	89 e5                	mov    %esp,%ebp
  8013c6:	53                   	push   %ebx
  8013c7:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013ca:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013cf:	89 1c 24             	mov    %ebx,(%esp)
  8013d2:	e8 bb ff ff ff       	call   801392 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013d7:	83 c3 01             	add    $0x1,%ebx
  8013da:	83 fb 20             	cmp    $0x20,%ebx
  8013dd:	75 f0                	jne    8013cf <close_all+0xc>
		close(i);
}
  8013df:	83 c4 14             	add    $0x14,%esp
  8013e2:	5b                   	pop    %ebx
  8013e3:	5d                   	pop    %ebp
  8013e4:	c3                   	ret    

008013e5 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013e5:	55                   	push   %ebp
  8013e6:	89 e5                	mov    %esp,%ebp
  8013e8:	83 ec 58             	sub    $0x58,%esp
  8013eb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8013ee:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8013f1:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8013f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013f7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801401:	89 04 24             	mov    %eax,(%esp)
  801404:	e8 56 fe ff ff       	call   80125f <fd_lookup>
  801409:	85 c0                	test   %eax,%eax
  80140b:	0f 88 e3 00 00 00    	js     8014f4 <dup+0x10f>
		return r;
	close(newfdnum);
  801411:	89 1c 24             	mov    %ebx,(%esp)
  801414:	e8 79 ff ff ff       	call   801392 <close>

	newfd = INDEX2FD(newfdnum);
  801419:	89 de                	mov    %ebx,%esi
  80141b:	c1 e6 0c             	shl    $0xc,%esi
  80141e:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801424:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801427:	89 04 24             	mov    %eax,(%esp)
  80142a:	e8 a1 fd ff ff       	call   8011d0 <fd2data>
  80142f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801431:	89 34 24             	mov    %esi,(%esp)
  801434:	e8 97 fd ff ff       	call   8011d0 <fd2data>
  801439:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  80143c:	89 f8                	mov    %edi,%eax
  80143e:	c1 e8 16             	shr    $0x16,%eax
  801441:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801448:	a8 01                	test   $0x1,%al
  80144a:	74 46                	je     801492 <dup+0xad>
  80144c:	89 f8                	mov    %edi,%eax
  80144e:	c1 e8 0c             	shr    $0xc,%eax
  801451:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801458:	f6 c2 01             	test   $0x1,%dl
  80145b:	74 35                	je     801492 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80145d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801464:	25 07 0e 00 00       	and    $0xe07,%eax
  801469:	89 44 24 10          	mov    %eax,0x10(%esp)
  80146d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801470:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801474:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80147b:	00 
  80147c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801480:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801487:	e8 f5 f9 ff ff       	call   800e81 <sys_page_map>
  80148c:	89 c7                	mov    %eax,%edi
  80148e:	85 c0                	test   %eax,%eax
  801490:	78 3b                	js     8014cd <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801492:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801495:	89 c2                	mov    %eax,%edx
  801497:	c1 ea 0c             	shr    $0xc,%edx
  80149a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014a1:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8014a7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8014ab:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8014af:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014b6:	00 
  8014b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014c2:	e8 ba f9 ff ff       	call   800e81 <sys_page_map>
  8014c7:	89 c7                	mov    %eax,%edi
  8014c9:	85 c0                	test   %eax,%eax
  8014cb:	79 29                	jns    8014f6 <dup+0x111>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014cd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014d8:	e8 0b fa ff ff       	call   800ee8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014dd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8014e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014eb:	e8 f8 f9 ff ff       	call   800ee8 <sys_page_unmap>
	return r;
  8014f0:	89 fb                	mov    %edi,%ebx
  8014f2:	eb 02                	jmp    8014f6 <dup+0x111>
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
		return r;
  8014f4:	89 c3                	mov    %eax,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8014f6:	89 d8                	mov    %ebx,%eax
  8014f8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8014fb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8014fe:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801501:	89 ec                	mov    %ebp,%esp
  801503:	5d                   	pop    %ebp
  801504:	c3                   	ret    

00801505 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801505:	55                   	push   %ebp
  801506:	89 e5                	mov    %esp,%ebp
  801508:	53                   	push   %ebx
  801509:	83 ec 24             	sub    $0x24,%esp
  80150c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80150f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801512:	89 44 24 04          	mov    %eax,0x4(%esp)
  801516:	89 1c 24             	mov    %ebx,(%esp)
  801519:	e8 41 fd ff ff       	call   80125f <fd_lookup>
  80151e:	85 c0                	test   %eax,%eax
  801520:	78 6d                	js     80158f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801522:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801525:	89 44 24 04          	mov    %eax,0x4(%esp)
  801529:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80152c:	8b 00                	mov    (%eax),%eax
  80152e:	89 04 24             	mov    %eax,(%esp)
  801531:	e8 7f fd ff ff       	call   8012b5 <dev_lookup>
  801536:	85 c0                	test   %eax,%eax
  801538:	78 55                	js     80158f <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80153a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80153d:	8b 50 08             	mov    0x8(%eax),%edx
  801540:	83 e2 03             	and    $0x3,%edx
  801543:	83 fa 01             	cmp    $0x1,%edx
  801546:	75 23                	jne    80156b <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801548:	a1 04 40 80 00       	mov    0x804004,%eax
  80154d:	8b 40 48             	mov    0x48(%eax),%eax
  801550:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801554:	89 44 24 04          	mov    %eax,0x4(%esp)
  801558:	c7 04 24 14 22 80 00 	movl   $0x802214,(%esp)
  80155f:	e8 e7 ec ff ff       	call   80024b <cprintf>
		return -E_INVAL;
  801564:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801569:	eb 24                	jmp    80158f <read+0x8a>
	}
	if (!dev->dev_read)
  80156b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80156e:	8b 52 08             	mov    0x8(%edx),%edx
  801571:	85 d2                	test   %edx,%edx
  801573:	74 15                	je     80158a <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801575:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801578:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80157c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80157f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801583:	89 04 24             	mov    %eax,(%esp)
  801586:	ff d2                	call   *%edx
  801588:	eb 05                	jmp    80158f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80158a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80158f:	83 c4 24             	add    $0x24,%esp
  801592:	5b                   	pop    %ebx
  801593:	5d                   	pop    %ebp
  801594:	c3                   	ret    

00801595 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801595:	55                   	push   %ebp
  801596:	89 e5                	mov    %esp,%ebp
  801598:	57                   	push   %edi
  801599:	56                   	push   %esi
  80159a:	53                   	push   %ebx
  80159b:	83 ec 1c             	sub    $0x1c,%esp
  80159e:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015a1:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015a4:	85 f6                	test   %esi,%esi
  8015a6:	74 33                	je     8015db <readn+0x46>
  8015a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8015ad:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015b2:	89 f2                	mov    %esi,%edx
  8015b4:	29 c2                	sub    %eax,%edx
  8015b6:	89 54 24 08          	mov    %edx,0x8(%esp)
  8015ba:	03 45 0c             	add    0xc(%ebp),%eax
  8015bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015c1:	89 3c 24             	mov    %edi,(%esp)
  8015c4:	e8 3c ff ff ff       	call   801505 <read>
		if (m < 0)
  8015c9:	85 c0                	test   %eax,%eax
  8015cb:	78 17                	js     8015e4 <readn+0x4f>
			return m;
		if (m == 0)
  8015cd:	85 c0                	test   %eax,%eax
  8015cf:	74 11                	je     8015e2 <readn+0x4d>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015d1:	01 c3                	add    %eax,%ebx
  8015d3:	89 d8                	mov    %ebx,%eax
  8015d5:	39 f3                	cmp    %esi,%ebx
  8015d7:	72 d9                	jb     8015b2 <readn+0x1d>
  8015d9:	eb 09                	jmp    8015e4 <readn+0x4f>
  8015db:	b8 00 00 00 00       	mov    $0x0,%eax
  8015e0:	eb 02                	jmp    8015e4 <readn+0x4f>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8015e2:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8015e4:	83 c4 1c             	add    $0x1c,%esp
  8015e7:	5b                   	pop    %ebx
  8015e8:	5e                   	pop    %esi
  8015e9:	5f                   	pop    %edi
  8015ea:	5d                   	pop    %ebp
  8015eb:	c3                   	ret    

008015ec <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015ec:	55                   	push   %ebp
  8015ed:	89 e5                	mov    %esp,%ebp
  8015ef:	53                   	push   %ebx
  8015f0:	83 ec 24             	sub    $0x24,%esp
  8015f3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015f6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015fd:	89 1c 24             	mov    %ebx,(%esp)
  801600:	e8 5a fc ff ff       	call   80125f <fd_lookup>
  801605:	85 c0                	test   %eax,%eax
  801607:	78 68                	js     801671 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801609:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80160c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801610:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801613:	8b 00                	mov    (%eax),%eax
  801615:	89 04 24             	mov    %eax,(%esp)
  801618:	e8 98 fc ff ff       	call   8012b5 <dev_lookup>
  80161d:	85 c0                	test   %eax,%eax
  80161f:	78 50                	js     801671 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801621:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801624:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801628:	75 23                	jne    80164d <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80162a:	a1 04 40 80 00       	mov    0x804004,%eax
  80162f:	8b 40 48             	mov    0x48(%eax),%eax
  801632:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801636:	89 44 24 04          	mov    %eax,0x4(%esp)
  80163a:	c7 04 24 30 22 80 00 	movl   $0x802230,(%esp)
  801641:	e8 05 ec ff ff       	call   80024b <cprintf>
		return -E_INVAL;
  801646:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80164b:	eb 24                	jmp    801671 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80164d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801650:	8b 52 0c             	mov    0xc(%edx),%edx
  801653:	85 d2                	test   %edx,%edx
  801655:	74 15                	je     80166c <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801657:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80165a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80165e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801661:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801665:	89 04 24             	mov    %eax,(%esp)
  801668:	ff d2                	call   *%edx
  80166a:	eb 05                	jmp    801671 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80166c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801671:	83 c4 24             	add    $0x24,%esp
  801674:	5b                   	pop    %ebx
  801675:	5d                   	pop    %ebp
  801676:	c3                   	ret    

00801677 <seek>:

int
seek(int fdnum, off_t offset)
{
  801677:	55                   	push   %ebp
  801678:	89 e5                	mov    %esp,%ebp
  80167a:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80167d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801680:	89 44 24 04          	mov    %eax,0x4(%esp)
  801684:	8b 45 08             	mov    0x8(%ebp),%eax
  801687:	89 04 24             	mov    %eax,(%esp)
  80168a:	e8 d0 fb ff ff       	call   80125f <fd_lookup>
  80168f:	85 c0                	test   %eax,%eax
  801691:	78 0e                	js     8016a1 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801693:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801696:	8b 55 0c             	mov    0xc(%ebp),%edx
  801699:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80169c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016a1:	c9                   	leave  
  8016a2:	c3                   	ret    

008016a3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016a3:	55                   	push   %ebp
  8016a4:	89 e5                	mov    %esp,%ebp
  8016a6:	53                   	push   %ebx
  8016a7:	83 ec 24             	sub    $0x24,%esp
  8016aa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016ad:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016b4:	89 1c 24             	mov    %ebx,(%esp)
  8016b7:	e8 a3 fb ff ff       	call   80125f <fd_lookup>
  8016bc:	85 c0                	test   %eax,%eax
  8016be:	78 61                	js     801721 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ca:	8b 00                	mov    (%eax),%eax
  8016cc:	89 04 24             	mov    %eax,(%esp)
  8016cf:	e8 e1 fb ff ff       	call   8012b5 <dev_lookup>
  8016d4:	85 c0                	test   %eax,%eax
  8016d6:	78 49                	js     801721 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016db:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016df:	75 23                	jne    801704 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016e1:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016e6:	8b 40 48             	mov    0x48(%eax),%eax
  8016e9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8016ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016f1:	c7 04 24 f0 21 80 00 	movl   $0x8021f0,(%esp)
  8016f8:	e8 4e eb ff ff       	call   80024b <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016fd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801702:	eb 1d                	jmp    801721 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801704:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801707:	8b 52 18             	mov    0x18(%edx),%edx
  80170a:	85 d2                	test   %edx,%edx
  80170c:	74 0e                	je     80171c <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80170e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801711:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801715:	89 04 24             	mov    %eax,(%esp)
  801718:	ff d2                	call   *%edx
  80171a:	eb 05                	jmp    801721 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80171c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801721:	83 c4 24             	add    $0x24,%esp
  801724:	5b                   	pop    %ebx
  801725:	5d                   	pop    %ebp
  801726:	c3                   	ret    

00801727 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801727:	55                   	push   %ebp
  801728:	89 e5                	mov    %esp,%ebp
  80172a:	53                   	push   %ebx
  80172b:	83 ec 24             	sub    $0x24,%esp
  80172e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801731:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801734:	89 44 24 04          	mov    %eax,0x4(%esp)
  801738:	8b 45 08             	mov    0x8(%ebp),%eax
  80173b:	89 04 24             	mov    %eax,(%esp)
  80173e:	e8 1c fb ff ff       	call   80125f <fd_lookup>
  801743:	85 c0                	test   %eax,%eax
  801745:	78 52                	js     801799 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801747:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80174a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80174e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801751:	8b 00                	mov    (%eax),%eax
  801753:	89 04 24             	mov    %eax,(%esp)
  801756:	e8 5a fb ff ff       	call   8012b5 <dev_lookup>
  80175b:	85 c0                	test   %eax,%eax
  80175d:	78 3a                	js     801799 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  80175f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801762:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801766:	74 2c                	je     801794 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801768:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80176b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801772:	00 00 00 
	stat->st_isdir = 0;
  801775:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80177c:	00 00 00 
	stat->st_dev = dev;
  80177f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801785:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801789:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80178c:	89 14 24             	mov    %edx,(%esp)
  80178f:	ff 50 14             	call   *0x14(%eax)
  801792:	eb 05                	jmp    801799 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801794:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801799:	83 c4 24             	add    $0x24,%esp
  80179c:	5b                   	pop    %ebx
  80179d:	5d                   	pop    %ebp
  80179e:	c3                   	ret    

0080179f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80179f:	55                   	push   %ebp
  8017a0:	89 e5                	mov    %esp,%ebp
  8017a2:	83 ec 18             	sub    $0x18,%esp
  8017a5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8017a8:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017ab:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8017b2:	00 
  8017b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b6:	89 04 24             	mov    %eax,(%esp)
  8017b9:	e8 84 01 00 00       	call   801942 <open>
  8017be:	89 c3                	mov    %eax,%ebx
  8017c0:	85 c0                	test   %eax,%eax
  8017c2:	78 1b                	js     8017df <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  8017c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017cb:	89 1c 24             	mov    %ebx,(%esp)
  8017ce:	e8 54 ff ff ff       	call   801727 <fstat>
  8017d3:	89 c6                	mov    %eax,%esi
	close(fd);
  8017d5:	89 1c 24             	mov    %ebx,(%esp)
  8017d8:	e8 b5 fb ff ff       	call   801392 <close>
	return r;
  8017dd:	89 f3                	mov    %esi,%ebx
}
  8017df:	89 d8                	mov    %ebx,%eax
  8017e1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8017e4:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8017e7:	89 ec                	mov    %ebp,%esp
  8017e9:	5d                   	pop    %ebp
  8017ea:	c3                   	ret    
  8017eb:	90                   	nop

008017ec <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017ec:	55                   	push   %ebp
  8017ed:	89 e5                	mov    %esp,%ebp
  8017ef:	83 ec 18             	sub    $0x18,%esp
  8017f2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8017f5:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8017f8:	89 c6                	mov    %eax,%esi
  8017fa:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017fc:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801803:	75 11                	jne    801816 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801805:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  80180c:	e8 72 02 00 00       	call   801a83 <ipc_find_env>
  801811:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801816:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80181d:	00 
  80181e:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801825:	00 
  801826:	89 74 24 04          	mov    %esi,0x4(%esp)
  80182a:	a1 00 40 80 00       	mov    0x804000,%eax
  80182f:	89 04 24             	mov    %eax,(%esp)
  801832:	e8 e1 01 00 00       	call   801a18 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801837:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80183e:	00 
  80183f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801843:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80184a:	e8 71 01 00 00       	call   8019c0 <ipc_recv>
}
  80184f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801852:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801855:	89 ec                	mov    %ebp,%esp
  801857:	5d                   	pop    %ebp
  801858:	c3                   	ret    

00801859 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801859:	55                   	push   %ebp
  80185a:	89 e5                	mov    %esp,%ebp
  80185c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80185f:	8b 45 08             	mov    0x8(%ebp),%eax
  801862:	8b 40 0c             	mov    0xc(%eax),%eax
  801865:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80186a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80186d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801872:	ba 00 00 00 00       	mov    $0x0,%edx
  801877:	b8 02 00 00 00       	mov    $0x2,%eax
  80187c:	e8 6b ff ff ff       	call   8017ec <fsipc>
}
  801881:	c9                   	leave  
  801882:	c3                   	ret    

00801883 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801883:	55                   	push   %ebp
  801884:	89 e5                	mov    %esp,%ebp
  801886:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801889:	8b 45 08             	mov    0x8(%ebp),%eax
  80188c:	8b 40 0c             	mov    0xc(%eax),%eax
  80188f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801894:	ba 00 00 00 00       	mov    $0x0,%edx
  801899:	b8 06 00 00 00       	mov    $0x6,%eax
  80189e:	e8 49 ff ff ff       	call   8017ec <fsipc>
}
  8018a3:	c9                   	leave  
  8018a4:	c3                   	ret    

008018a5 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018a5:	55                   	push   %ebp
  8018a6:	89 e5                	mov    %esp,%ebp
  8018a8:	53                   	push   %ebx
  8018a9:	83 ec 14             	sub    $0x14,%esp
  8018ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018af:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b2:	8b 40 0c             	mov    0xc(%eax),%eax
  8018b5:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8018bf:	b8 05 00 00 00       	mov    $0x5,%eax
  8018c4:	e8 23 ff ff ff       	call   8017ec <fsipc>
  8018c9:	85 c0                	test   %eax,%eax
  8018cb:	78 2b                	js     8018f8 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018cd:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8018d4:	00 
  8018d5:	89 1c 24             	mov    %ebx,(%esp)
  8018d8:	e8 ee ef ff ff       	call   8008cb <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018dd:	a1 80 50 80 00       	mov    0x805080,%eax
  8018e2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018e8:	a1 84 50 80 00       	mov    0x805084,%eax
  8018ed:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018f8:	83 c4 14             	add    $0x14,%esp
  8018fb:	5b                   	pop    %ebx
  8018fc:	5d                   	pop    %ebp
  8018fd:	c3                   	ret    

008018fe <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018fe:	55                   	push   %ebp
  8018ff:	89 e5                	mov    %esp,%ebp
  801901:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801904:	c7 44 24 08 4d 22 80 	movl   $0x80224d,0x8(%esp)
  80190b:	00 
  80190c:	c7 44 24 04 77 00 00 	movl   $0x77,0x4(%esp)
  801913:	00 
  801914:	c7 04 24 6b 22 80 00 	movl   $0x80226b,(%esp)
  80191b:	e8 30 e8 ff ff       	call   800150 <_panic>

00801920 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801920:	55                   	push   %ebp
  801921:	89 e5                	mov    %esp,%ebp
  801923:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_READ request to the file system server after
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
	panic("devfile_read not implemented");
  801926:	c7 44 24 08 76 22 80 	movl   $0x802276,0x8(%esp)
  80192d:	00 
  80192e:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
  801935:	00 
  801936:	c7 04 24 6b 22 80 00 	movl   $0x80226b,(%esp)
  80193d:	e8 0e e8 ff ff       	call   800150 <_panic>

00801942 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801942:	55                   	push   %ebp
  801943:	89 e5                	mov    %esp,%ebp
  801945:	83 ec 18             	sub    $0x18,%esp
	// Return the file descriptor index.
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
	panic("open not implemented");
  801948:	c7 44 24 08 93 22 80 	movl   $0x802293,0x8(%esp)
  80194f:	00 
  801950:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  801957:	00 
  801958:	c7 04 24 6b 22 80 00 	movl   $0x80226b,(%esp)
  80195f:	e8 ec e7 ff ff       	call   800150 <_panic>

00801964 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801964:	55                   	push   %ebp
  801965:	89 e5                	mov    %esp,%ebp
  801967:	53                   	push   %ebx
  801968:	83 ec 14             	sub    $0x14,%esp
  80196b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  80196e:	89 1c 24             	mov    %ebx,(%esp)
  801971:	e8 fa ee ff ff       	call   800870 <strlen>
  801976:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80197b:	7f 21                	jg     80199e <remove+0x3a>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  80197d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801981:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801988:	e8 3e ef ff ff       	call   8008cb <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  80198d:	ba 00 00 00 00       	mov    $0x0,%edx
  801992:	b8 07 00 00 00       	mov    $0x7,%eax
  801997:	e8 50 fe ff ff       	call   8017ec <fsipc>
  80199c:	eb 05                	jmp    8019a3 <remove+0x3f>
// Delete a file
int
remove(const char *path)
{
	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80199e:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
	strcpy(fsipcbuf.remove.req_path, path);
	return fsipc(FSREQ_REMOVE, NULL);
}
  8019a3:	83 c4 14             	add    $0x14,%esp
  8019a6:	5b                   	pop    %ebx
  8019a7:	5d                   	pop    %ebp
  8019a8:	c3                   	ret    

008019a9 <sync>:

// Synchronize disk with buffer cache
int
sync(void)
{
  8019a9:	55                   	push   %ebp
  8019aa:	89 e5                	mov    %esp,%ebp
  8019ac:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019af:	ba 00 00 00 00       	mov    $0x0,%edx
  8019b4:	b8 08 00 00 00       	mov    $0x8,%eax
  8019b9:	e8 2e fe ff ff       	call   8017ec <fsipc>
}
  8019be:	c9                   	leave  
  8019bf:	c3                   	ret    

008019c0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019c0:	55                   	push   %ebp
  8019c1:	89 e5                	mov    %esp,%ebp
  8019c3:	56                   	push   %esi
  8019c4:	53                   	push   %ebx
  8019c5:	83 ec 10             	sub    $0x10,%esp
  8019c8:	8b 75 08             	mov    0x8(%ebp),%esi
  8019cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	// 	return thisenv->env_ipc_value;
	// }
	int r;
	if(pg == NULL)
		pg = (void *)~0x0;
  8019ce:	85 db                	test   %ebx,%ebx
  8019d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8019d5:	0f 44 d8             	cmove  %eax,%ebx
	//else
	if((r = sys_ipc_recv(pg)) < 0)
  8019d8:	89 1c 24             	mov    %ebx,(%esp)
  8019db:	e8 e1 f6 ff ff       	call   8010c1 <sys_ipc_recv>
  8019e0:	85 c0                	test   %eax,%eax
  8019e2:	78 2d                	js     801a11 <ipc_recv+0x51>
		return r;
	//volatile struct Env *curenv = (struct Env*)envs+ENVX(sys_getenvid());

	if(from_env_store)
  8019e4:	85 f6                	test   %esi,%esi
  8019e6:	74 0a                	je     8019f2 <ipc_recv+0x32>
		*from_env_store = thisenv -> env_ipc_from;
  8019e8:	a1 04 40 80 00       	mov    0x804004,%eax
  8019ed:	8b 40 74             	mov    0x74(%eax),%eax
  8019f0:	89 06                	mov    %eax,(%esi)
	if(pg && perm_store)
  8019f2:	85 db                	test   %ebx,%ebx
  8019f4:	74 13                	je     801a09 <ipc_recv+0x49>
  8019f6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019fa:	74 0d                	je     801a09 <ipc_recv+0x49>
		*perm_store = thisenv -> env_ipc_perm;
  8019fc:	a1 04 40 80 00       	mov    0x804004,%eax
  801a01:	8b 40 78             	mov    0x78(%eax),%eax
  801a04:	8b 55 10             	mov    0x10(%ebp),%edx
  801a07:	89 02                	mov    %eax,(%edx)
	else if(perm_store)
		perm_store = (int *)0;
	return thisenv->env_ipc_value;
  801a09:	a1 04 40 80 00       	mov    0x804004,%eax
  801a0e:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  801a11:	83 c4 10             	add    $0x10,%esp
  801a14:	5b                   	pop    %ebx
  801a15:	5e                   	pop    %esi
  801a16:	5d                   	pop    %ebp
  801a17:	c3                   	ret    

00801a18 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a18:	55                   	push   %ebp
  801a19:	89 e5                	mov    %esp,%ebp
  801a1b:	57                   	push   %edi
  801a1c:	56                   	push   %esi
  801a1d:	53                   	push   %ebx
  801a1e:	83 ec 1c             	sub    $0x1c,%esp
  801a21:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a24:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a27:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

	if(pg == NULL)
  801a2a:	85 db                	test   %ebx,%ebx
		pg = (void *)~0x0;
  801a2c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801a31:	0f 44 d8             	cmove  %eax,%ebx
  801a34:	eb 2a                	jmp    801a60 <ipc_send+0x48>
	while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0){
		if(r != -E_IPC_NOT_RECV)
  801a36:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a39:	74 20                	je     801a5b <ipc_send+0x43>
            panic("Send message error %e\n",r);
  801a3b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a3f:	c7 44 24 08 a8 22 80 	movl   $0x8022a8,0x8(%esp)
  801a46:	00 
  801a47:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  801a4e:	00 
  801a4f:	c7 04 24 bf 22 80 00 	movl   $0x8022bf,(%esp)
  801a56:	e8 f5 e6 ff ff       	call   800150 <_panic>
		sys_yield();
  801a5b:	e8 80 f3 ff ff       	call   800de0 <sys_yield>
	// LAB 4: Your code here.
	int r;

	if(pg == NULL)
		pg = (void *)~0x0;
	while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0){
  801a60:	8b 45 14             	mov    0x14(%ebp),%eax
  801a63:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a67:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a6b:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a6f:	89 3c 24             	mov    %edi,(%esp)
  801a72:	e8 0d f6 ff ff       	call   801084 <sys_ipc_try_send>
  801a77:	85 c0                	test   %eax,%eax
  801a79:	78 bb                	js     801a36 <ipc_send+0x1e>
            panic("Send message error %e\n",r);
		sys_yield();
	}

	//panic("ipc_send not implemented");
}
  801a7b:	83 c4 1c             	add    $0x1c,%esp
  801a7e:	5b                   	pop    %ebx
  801a7f:	5e                   	pop    %esi
  801a80:	5f                   	pop    %edi
  801a81:	5d                   	pop    %ebp
  801a82:	c3                   	ret    

00801a83 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801a83:	55                   	push   %ebp
  801a84:	89 e5                	mov    %esp,%ebp
  801a86:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801a89:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801a8e:	39 c8                	cmp    %ecx,%eax
  801a90:	74 17                	je     801aa9 <ipc_find_env+0x26>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801a92:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801a97:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801a9a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801aa0:	8b 52 50             	mov    0x50(%edx),%edx
  801aa3:	39 ca                	cmp    %ecx,%edx
  801aa5:	75 14                	jne    801abb <ipc_find_env+0x38>
  801aa7:	eb 05                	jmp    801aae <ipc_find_env+0x2b>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801aa9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801aae:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ab1:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801ab6:	8b 40 40             	mov    0x40(%eax),%eax
  801ab9:	eb 0e                	jmp    801ac9 <ipc_find_env+0x46>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801abb:	83 c0 01             	add    $0x1,%eax
  801abe:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ac3:	75 d2                	jne    801a97 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ac5:	66 b8 00 00          	mov    $0x0,%ax
}
  801ac9:	5d                   	pop    %ebp
  801aca:	c3                   	ret    
  801acb:	66 90                	xchg   %ax,%ax
  801acd:	66 90                	xchg   %ax,%ax
  801acf:	90                   	nop

00801ad0 <__udivdi3>:
  801ad0:	83 ec 1c             	sub    $0x1c,%esp
  801ad3:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801ad7:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801adb:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801adf:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801ae3:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801ae7:	8b 6c 24 24          	mov    0x24(%esp),%ebp
  801aeb:	85 c0                	test   %eax,%eax
  801aed:	89 74 24 10          	mov    %esi,0x10(%esp)
  801af1:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801af5:	89 ea                	mov    %ebp,%edx
  801af7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801afb:	75 33                	jne    801b30 <__udivdi3+0x60>
  801afd:	39 e9                	cmp    %ebp,%ecx
  801aff:	77 6f                	ja     801b70 <__udivdi3+0xa0>
  801b01:	85 c9                	test   %ecx,%ecx
  801b03:	89 ce                	mov    %ecx,%esi
  801b05:	75 0b                	jne    801b12 <__udivdi3+0x42>
  801b07:	b8 01 00 00 00       	mov    $0x1,%eax
  801b0c:	31 d2                	xor    %edx,%edx
  801b0e:	f7 f1                	div    %ecx
  801b10:	89 c6                	mov    %eax,%esi
  801b12:	31 d2                	xor    %edx,%edx
  801b14:	89 e8                	mov    %ebp,%eax
  801b16:	f7 f6                	div    %esi
  801b18:	89 c5                	mov    %eax,%ebp
  801b1a:	89 f8                	mov    %edi,%eax
  801b1c:	f7 f6                	div    %esi
  801b1e:	89 ea                	mov    %ebp,%edx
  801b20:	8b 74 24 10          	mov    0x10(%esp),%esi
  801b24:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801b28:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801b2c:	83 c4 1c             	add    $0x1c,%esp
  801b2f:	c3                   	ret    
  801b30:	39 e8                	cmp    %ebp,%eax
  801b32:	77 24                	ja     801b58 <__udivdi3+0x88>
  801b34:	0f bd c8             	bsr    %eax,%ecx
  801b37:	83 f1 1f             	xor    $0x1f,%ecx
  801b3a:	89 0c 24             	mov    %ecx,(%esp)
  801b3d:	75 49                	jne    801b88 <__udivdi3+0xb8>
  801b3f:	8b 74 24 08          	mov    0x8(%esp),%esi
  801b43:	39 74 24 04          	cmp    %esi,0x4(%esp)
  801b47:	0f 86 ab 00 00 00    	jbe    801bf8 <__udivdi3+0x128>
  801b4d:	39 e8                	cmp    %ebp,%eax
  801b4f:	0f 82 a3 00 00 00    	jb     801bf8 <__udivdi3+0x128>
  801b55:	8d 76 00             	lea    0x0(%esi),%esi
  801b58:	31 d2                	xor    %edx,%edx
  801b5a:	31 c0                	xor    %eax,%eax
  801b5c:	8b 74 24 10          	mov    0x10(%esp),%esi
  801b60:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801b64:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801b68:	83 c4 1c             	add    $0x1c,%esp
  801b6b:	c3                   	ret    
  801b6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801b70:	89 f8                	mov    %edi,%eax
  801b72:	f7 f1                	div    %ecx
  801b74:	31 d2                	xor    %edx,%edx
  801b76:	8b 74 24 10          	mov    0x10(%esp),%esi
  801b7a:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801b7e:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801b82:	83 c4 1c             	add    $0x1c,%esp
  801b85:	c3                   	ret    
  801b86:	66 90                	xchg   %ax,%ax
  801b88:	0f b6 0c 24          	movzbl (%esp),%ecx
  801b8c:	89 c6                	mov    %eax,%esi
  801b8e:	b8 20 00 00 00       	mov    $0x20,%eax
  801b93:	8b 6c 24 04          	mov    0x4(%esp),%ebp
  801b97:	2b 04 24             	sub    (%esp),%eax
  801b9a:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801b9e:	d3 e6                	shl    %cl,%esi
  801ba0:	89 c1                	mov    %eax,%ecx
  801ba2:	d3 ed                	shr    %cl,%ebp
  801ba4:	0f b6 0c 24          	movzbl (%esp),%ecx
  801ba8:	09 f5                	or     %esi,%ebp
  801baa:	8b 74 24 04          	mov    0x4(%esp),%esi
  801bae:	d3 e6                	shl    %cl,%esi
  801bb0:	89 c1                	mov    %eax,%ecx
  801bb2:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bb6:	89 d6                	mov    %edx,%esi
  801bb8:	d3 ee                	shr    %cl,%esi
  801bba:	0f b6 0c 24          	movzbl (%esp),%ecx
  801bbe:	d3 e2                	shl    %cl,%edx
  801bc0:	89 c1                	mov    %eax,%ecx
  801bc2:	d3 ef                	shr    %cl,%edi
  801bc4:	09 d7                	or     %edx,%edi
  801bc6:	89 f2                	mov    %esi,%edx
  801bc8:	89 f8                	mov    %edi,%eax
  801bca:	f7 f5                	div    %ebp
  801bcc:	89 d6                	mov    %edx,%esi
  801bce:	89 c7                	mov    %eax,%edi
  801bd0:	f7 64 24 04          	mull   0x4(%esp)
  801bd4:	39 d6                	cmp    %edx,%esi
  801bd6:	72 30                	jb     801c08 <__udivdi3+0x138>
  801bd8:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801bdc:	0f b6 0c 24          	movzbl (%esp),%ecx
  801be0:	d3 e5                	shl    %cl,%ebp
  801be2:	39 c5                	cmp    %eax,%ebp
  801be4:	73 04                	jae    801bea <__udivdi3+0x11a>
  801be6:	39 d6                	cmp    %edx,%esi
  801be8:	74 1e                	je     801c08 <__udivdi3+0x138>
  801bea:	89 f8                	mov    %edi,%eax
  801bec:	31 d2                	xor    %edx,%edx
  801bee:	e9 69 ff ff ff       	jmp    801b5c <__udivdi3+0x8c>
  801bf3:	90                   	nop
  801bf4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801bf8:	31 d2                	xor    %edx,%edx
  801bfa:	b8 01 00 00 00       	mov    $0x1,%eax
  801bff:	e9 58 ff ff ff       	jmp    801b5c <__udivdi3+0x8c>
  801c04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c08:	8d 47 ff             	lea    -0x1(%edi),%eax
  801c0b:	31 d2                	xor    %edx,%edx
  801c0d:	8b 74 24 10          	mov    0x10(%esp),%esi
  801c11:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801c15:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801c19:	83 c4 1c             	add    $0x1c,%esp
  801c1c:	c3                   	ret    
  801c1d:	66 90                	xchg   %ax,%ax
  801c1f:	90                   	nop

00801c20 <__umoddi3>:
  801c20:	83 ec 2c             	sub    $0x2c,%esp
  801c23:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801c27:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801c2b:	89 74 24 20          	mov    %esi,0x20(%esp)
  801c2f:	8b 74 24 38          	mov    0x38(%esp),%esi
  801c33:	89 7c 24 24          	mov    %edi,0x24(%esp)
  801c37:	8b 7c 24 34          	mov    0x34(%esp),%edi
  801c3b:	85 c0                	test   %eax,%eax
  801c3d:	89 c2                	mov    %eax,%edx
  801c3f:	89 6c 24 28          	mov    %ebp,0x28(%esp)
  801c43:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801c47:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801c4b:	89 74 24 10          	mov    %esi,0x10(%esp)
  801c4f:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801c53:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801c57:	75 1f                	jne    801c78 <__umoddi3+0x58>
  801c59:	39 fe                	cmp    %edi,%esi
  801c5b:	76 63                	jbe    801cc0 <__umoddi3+0xa0>
  801c5d:	89 c8                	mov    %ecx,%eax
  801c5f:	89 fa                	mov    %edi,%edx
  801c61:	f7 f6                	div    %esi
  801c63:	89 d0                	mov    %edx,%eax
  801c65:	31 d2                	xor    %edx,%edx
  801c67:	8b 74 24 20          	mov    0x20(%esp),%esi
  801c6b:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801c6f:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801c73:	83 c4 2c             	add    $0x2c,%esp
  801c76:	c3                   	ret    
  801c77:	90                   	nop
  801c78:	39 f8                	cmp    %edi,%eax
  801c7a:	77 64                	ja     801ce0 <__umoddi3+0xc0>
  801c7c:	0f bd e8             	bsr    %eax,%ebp
  801c7f:	83 f5 1f             	xor    $0x1f,%ebp
  801c82:	75 74                	jne    801cf8 <__umoddi3+0xd8>
  801c84:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801c88:	39 7c 24 10          	cmp    %edi,0x10(%esp)
  801c8c:	0f 87 0e 01 00 00    	ja     801da0 <__umoddi3+0x180>
  801c92:	8b 7c 24 0c          	mov    0xc(%esp),%edi
  801c96:	29 f1                	sub    %esi,%ecx
  801c98:	19 c7                	sbb    %eax,%edi
  801c9a:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801c9e:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801ca2:	8b 44 24 14          	mov    0x14(%esp),%eax
  801ca6:	8b 54 24 18          	mov    0x18(%esp),%edx
  801caa:	8b 74 24 20          	mov    0x20(%esp),%esi
  801cae:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801cb2:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801cb6:	83 c4 2c             	add    $0x2c,%esp
  801cb9:	c3                   	ret    
  801cba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cc0:	85 f6                	test   %esi,%esi
  801cc2:	89 f5                	mov    %esi,%ebp
  801cc4:	75 0b                	jne    801cd1 <__umoddi3+0xb1>
  801cc6:	b8 01 00 00 00       	mov    $0x1,%eax
  801ccb:	31 d2                	xor    %edx,%edx
  801ccd:	f7 f6                	div    %esi
  801ccf:	89 c5                	mov    %eax,%ebp
  801cd1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801cd5:	31 d2                	xor    %edx,%edx
  801cd7:	f7 f5                	div    %ebp
  801cd9:	89 c8                	mov    %ecx,%eax
  801cdb:	f7 f5                	div    %ebp
  801cdd:	eb 84                	jmp    801c63 <__umoddi3+0x43>
  801cdf:	90                   	nop
  801ce0:	89 c8                	mov    %ecx,%eax
  801ce2:	89 fa                	mov    %edi,%edx
  801ce4:	8b 74 24 20          	mov    0x20(%esp),%esi
  801ce8:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801cec:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801cf0:	83 c4 2c             	add    $0x2c,%esp
  801cf3:	c3                   	ret    
  801cf4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cf8:	8b 44 24 10          	mov    0x10(%esp),%eax
  801cfc:	be 20 00 00 00       	mov    $0x20,%esi
  801d01:	89 e9                	mov    %ebp,%ecx
  801d03:	29 ee                	sub    %ebp,%esi
  801d05:	d3 e2                	shl    %cl,%edx
  801d07:	89 f1                	mov    %esi,%ecx
  801d09:	d3 e8                	shr    %cl,%eax
  801d0b:	89 e9                	mov    %ebp,%ecx
  801d0d:	09 d0                	or     %edx,%eax
  801d0f:	89 fa                	mov    %edi,%edx
  801d11:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d15:	8b 44 24 10          	mov    0x10(%esp),%eax
  801d19:	d3 e0                	shl    %cl,%eax
  801d1b:	89 f1                	mov    %esi,%ecx
  801d1d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801d21:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801d25:	d3 ea                	shr    %cl,%edx
  801d27:	89 e9                	mov    %ebp,%ecx
  801d29:	d3 e7                	shl    %cl,%edi
  801d2b:	89 f1                	mov    %esi,%ecx
  801d2d:	d3 e8                	shr    %cl,%eax
  801d2f:	89 e9                	mov    %ebp,%ecx
  801d31:	09 f8                	or     %edi,%eax
  801d33:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801d37:	f7 74 24 0c          	divl   0xc(%esp)
  801d3b:	d3 e7                	shl    %cl,%edi
  801d3d:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801d41:	89 d7                	mov    %edx,%edi
  801d43:	f7 64 24 10          	mull   0x10(%esp)
  801d47:	39 d7                	cmp    %edx,%edi
  801d49:	89 c1                	mov    %eax,%ecx
  801d4b:	89 54 24 14          	mov    %edx,0x14(%esp)
  801d4f:	72 3b                	jb     801d8c <__umoddi3+0x16c>
  801d51:	39 44 24 18          	cmp    %eax,0x18(%esp)
  801d55:	72 31                	jb     801d88 <__umoddi3+0x168>
  801d57:	8b 44 24 18          	mov    0x18(%esp),%eax
  801d5b:	29 c8                	sub    %ecx,%eax
  801d5d:	19 d7                	sbb    %edx,%edi
  801d5f:	89 e9                	mov    %ebp,%ecx
  801d61:	89 fa                	mov    %edi,%edx
  801d63:	d3 e8                	shr    %cl,%eax
  801d65:	89 f1                	mov    %esi,%ecx
  801d67:	d3 e2                	shl    %cl,%edx
  801d69:	89 e9                	mov    %ebp,%ecx
  801d6b:	09 d0                	or     %edx,%eax
  801d6d:	89 fa                	mov    %edi,%edx
  801d6f:	d3 ea                	shr    %cl,%edx
  801d71:	8b 74 24 20          	mov    0x20(%esp),%esi
  801d75:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801d79:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801d7d:	83 c4 2c             	add    $0x2c,%esp
  801d80:	c3                   	ret    
  801d81:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d88:	39 d7                	cmp    %edx,%edi
  801d8a:	75 cb                	jne    801d57 <__umoddi3+0x137>
  801d8c:	8b 54 24 14          	mov    0x14(%esp),%edx
  801d90:	89 c1                	mov    %eax,%ecx
  801d92:	2b 4c 24 10          	sub    0x10(%esp),%ecx
  801d96:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  801d9a:	eb bb                	jmp    801d57 <__umoddi3+0x137>
  801d9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801da0:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801da4:	0f 82 e8 fe ff ff    	jb     801c92 <__umoddi3+0x72>
  801daa:	e9 f3 fe ff ff       	jmp    801ca2 <__umoddi3+0x82>
