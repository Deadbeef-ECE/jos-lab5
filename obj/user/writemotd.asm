
obj/user/writemotd.debug:     file format elf32-i386


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
  80002c:	e8 13 02 00 00       	call   800244 <libmain>
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
  80003a:	81 ec 2c 02 00 00    	sub    $0x22c,%esp
	int rfd, wfd;
	char buf[512];
	int n, r;

	if ((rfd = open("/newmotd", O_RDONLY)) < 0)
  800040:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800047:	00 
  800048:	c7 04 24 80 1e 80 00 	movl   $0x801e80,(%esp)
  80004f:	e8 be 19 00 00       	call   801a12 <open>
  800054:	89 85 e4 fd ff ff    	mov    %eax,-0x21c(%ebp)
  80005a:	85 c0                	test   %eax,%eax
  80005c:	79 20                	jns    80007e <umain+0x4a>
		panic("open /newmotd: %e", rfd);
  80005e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800062:	c7 44 24 08 89 1e 80 	movl   $0x801e89,0x8(%esp)
  800069:	00 
  80006a:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
  800071:	00 
  800072:	c7 04 24 9b 1e 80 00 	movl   $0x801e9b,(%esp)
  800079:	e8 32 02 00 00       	call   8002b0 <_panic>
	if ((wfd = open("/motd", O_RDWR)) < 0)
  80007e:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  800085:	00 
  800086:	c7 04 24 ac 1e 80 00 	movl   $0x801eac,(%esp)
  80008d:	e8 80 19 00 00       	call   801a12 <open>
  800092:	89 c7                	mov    %eax,%edi
  800094:	85 c0                	test   %eax,%eax
  800096:	79 20                	jns    8000b8 <umain+0x84>
		panic("open /motd: %e", wfd);
  800098:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80009c:	c7 44 24 08 b2 1e 80 	movl   $0x801eb2,0x8(%esp)
  8000a3:	00 
  8000a4:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
  8000ab:	00 
  8000ac:	c7 04 24 9b 1e 80 00 	movl   $0x801e9b,(%esp)
  8000b3:	e8 f8 01 00 00       	call   8002b0 <_panic>
	cprintf("file descriptors %d %d\n", rfd, wfd);
  8000b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000bc:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
  8000c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000c6:	c7 04 24 c1 1e 80 00 	movl   $0x801ec1,(%esp)
  8000cd:	e8 d9 02 00 00       	call   8003ab <cprintf>
	if (rfd == wfd)
  8000d2:	39 bd e4 fd ff ff    	cmp    %edi,-0x21c(%ebp)
  8000d8:	75 1c                	jne    8000f6 <umain+0xc2>
		panic("open /newmotd and /motd give same file descriptor");
  8000da:	c7 44 24 08 2c 1f 80 	movl   $0x801f2c,0x8(%esp)
  8000e1:	00 
  8000e2:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  8000e9:	00 
  8000ea:	c7 04 24 9b 1e 80 00 	movl   $0x801e9b,(%esp)
  8000f1:	e8 ba 01 00 00       	call   8002b0 <_panic>

	cprintf("OLD MOTD\n===\n");
  8000f6:	c7 04 24 d9 1e 80 00 	movl   $0x801ed9,(%esp)
  8000fd:	e8 a9 02 00 00       	call   8003ab <cprintf>
	while ((n = read(wfd, buf, sizeof buf-1)) > 0)
  800102:	8d 9d e8 fd ff ff    	lea    -0x218(%ebp),%ebx
  800108:	eb 0c                	jmp    800116 <umain+0xe2>
		sys_cputs(buf, n);
  80010a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80010e:	89 1c 24             	mov    %ebx,(%esp)
  800111:	e8 1a 0d 00 00       	call   800e30 <sys_cputs>
	cprintf("file descriptors %d %d\n", rfd, wfd);
	if (rfd == wfd)
		panic("open /newmotd and /motd give same file descriptor");

	cprintf("OLD MOTD\n===\n");
	while ((n = read(wfd, buf, sizeof buf-1)) > 0)
  800116:	c7 44 24 08 ff 01 00 	movl   $0x1ff,0x8(%esp)
  80011d:	00 
  80011e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800122:	89 3c 24             	mov    %edi,(%esp)
  800125:	e8 ab 14 00 00       	call   8015d5 <read>
  80012a:	85 c0                	test   %eax,%eax
  80012c:	7f dc                	jg     80010a <umain+0xd6>
		sys_cputs(buf, n);
	cprintf("===\n");
  80012e:	c7 04 24 e2 1e 80 00 	movl   $0x801ee2,(%esp)
  800135:	e8 71 02 00 00       	call   8003ab <cprintf>
	seek(wfd, 0);
  80013a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800141:	00 
  800142:	89 3c 24             	mov    %edi,(%esp)
  800145:	e8 fd 15 00 00       	call   801747 <seek>

	if ((r = ftruncate(wfd, 0)) < 0)
  80014a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800151:	00 
  800152:	89 3c 24             	mov    %edi,(%esp)
  800155:	e8 19 16 00 00       	call   801773 <ftruncate>
  80015a:	85 c0                	test   %eax,%eax
  80015c:	79 20                	jns    80017e <umain+0x14a>
		panic("truncate /motd: %e", r);
  80015e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800162:	c7 44 24 08 e7 1e 80 	movl   $0x801ee7,0x8(%esp)
  800169:	00 
  80016a:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
  800171:	00 
  800172:	c7 04 24 9b 1e 80 00 	movl   $0x801e9b,(%esp)
  800179:	e8 32 01 00 00       	call   8002b0 <_panic>

	cprintf("NEW MOTD\n===\n");
  80017e:	c7 04 24 fa 1e 80 00 	movl   $0x801efa,(%esp)
  800185:	e8 21 02 00 00       	call   8003ab <cprintf>
	while ((n = read(rfd, buf, sizeof buf-1)) > 0) {
  80018a:	8d b5 e8 fd ff ff    	lea    -0x218(%ebp),%esi
  800190:	eb 40                	jmp    8001d2 <umain+0x19e>
		sys_cputs(buf, n);
  800192:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800196:	89 34 24             	mov    %esi,(%esp)
  800199:	e8 92 0c 00 00       	call   800e30 <sys_cputs>
		if ((r = write(wfd, buf, n)) != n)
  80019e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001a2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001a6:	89 3c 24             	mov    %edi,(%esp)
  8001a9:	e8 0e 15 00 00       	call   8016bc <write>
  8001ae:	39 d8                	cmp    %ebx,%eax
  8001b0:	74 20                	je     8001d2 <umain+0x19e>
			panic("write /motd: %e", r);
  8001b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001b6:	c7 44 24 08 08 1f 80 	movl   $0x801f08,0x8(%esp)
  8001bd:	00 
  8001be:	c7 44 24 04 1f 00 00 	movl   $0x1f,0x4(%esp)
  8001c5:	00 
  8001c6:	c7 04 24 9b 1e 80 00 	movl   $0x801e9b,(%esp)
  8001cd:	e8 de 00 00 00       	call   8002b0 <_panic>

	if ((r = ftruncate(wfd, 0)) < 0)
		panic("truncate /motd: %e", r);

	cprintf("NEW MOTD\n===\n");
	while ((n = read(rfd, buf, sizeof buf-1)) > 0) {
  8001d2:	c7 44 24 08 ff 01 00 	movl   $0x1ff,0x8(%esp)
  8001d9:	00 
  8001da:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001de:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
  8001e4:	89 04 24             	mov    %eax,(%esp)
  8001e7:	e8 e9 13 00 00       	call   8015d5 <read>
  8001ec:	89 c3                	mov    %eax,%ebx
  8001ee:	85 c0                	test   %eax,%eax
  8001f0:	7f a0                	jg     800192 <umain+0x15e>
		sys_cputs(buf, n);
		if ((r = write(wfd, buf, n)) != n)
			panic("write /motd: %e", r);
	}
	cprintf("===\n");
  8001f2:	c7 04 24 e2 1e 80 00 	movl   $0x801ee2,(%esp)
  8001f9:	e8 ad 01 00 00       	call   8003ab <cprintf>

	if (n < 0)
  8001fe:	85 db                	test   %ebx,%ebx
  800200:	79 20                	jns    800222 <umain+0x1ee>
		panic("read /newmotd: %e", n);
  800202:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800206:	c7 44 24 08 18 1f 80 	movl   $0x801f18,0x8(%esp)
  80020d:	00 
  80020e:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  800215:	00 
  800216:	c7 04 24 9b 1e 80 00 	movl   $0x801e9b,(%esp)
  80021d:	e8 8e 00 00 00       	call   8002b0 <_panic>

	close(rfd);
  800222:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
  800228:	89 04 24             	mov    %eax,(%esp)
  80022b:	e8 32 12 00 00       	call   801462 <close>
	close(wfd);
  800230:	89 3c 24             	mov    %edi,(%esp)
  800233:	e8 2a 12 00 00       	call   801462 <close>
}
  800238:	81 c4 2c 02 00 00    	add    $0x22c,%esp
  80023e:	5b                   	pop    %ebx
  80023f:	5e                   	pop    %esi
  800240:	5f                   	pop    %edi
  800241:	5d                   	pop    %ebp
  800242:	c3                   	ret    
  800243:	90                   	nop

00800244 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	83 ec 18             	sub    $0x18,%esp
  80024a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80024d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800250:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800253:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;

	thisenv = &envs[ENVX(sys_getenvid())];
  800256:	e8 ac 0c 00 00       	call   800f07 <sys_getenvid>
  80025b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800260:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800263:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800268:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80026d:	85 db                	test   %ebx,%ebx
  80026f:	7e 07                	jle    800278 <libmain+0x34>
		binaryname = argv[0];
  800271:	8b 06                	mov    (%esi),%eax
  800273:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800278:	89 74 24 04          	mov    %esi,0x4(%esp)
  80027c:	89 1c 24             	mov    %ebx,(%esp)
  80027f:	e8 b0 fd ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800284:	e8 0b 00 00 00       	call   800294 <exit>
}
  800289:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80028c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80028f:	89 ec                	mov    %ebp,%esp
  800291:	5d                   	pop    %ebp
  800292:	c3                   	ret    
  800293:	90                   	nop

00800294 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800294:	55                   	push   %ebp
  800295:	89 e5                	mov    %esp,%ebp
  800297:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80029a:	e8 f4 11 00 00       	call   801493 <close_all>
	sys_env_destroy(0);
  80029f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002a6:	e8 f6 0b 00 00       	call   800ea1 <sys_env_destroy>
}
  8002ab:	c9                   	leave  
  8002ac:	c3                   	ret    
  8002ad:	66 90                	xchg   %ax,%ax
  8002af:	90                   	nop

008002b0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	56                   	push   %esi
  8002b4:	53                   	push   %ebx
  8002b5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8002b8:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002bb:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8002c1:	e8 41 0c 00 00       	call   800f07 <sys_getenvid>
  8002c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002c9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002d4:	89 74 24 08          	mov    %esi,0x8(%esp)
  8002d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002dc:	c7 04 24 68 1f 80 00 	movl   $0x801f68,(%esp)
  8002e3:	e8 c3 00 00 00       	call   8003ab <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002ec:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ef:	89 04 24             	mov    %eax,(%esp)
  8002f2:	e8 53 00 00 00       	call   80034a <vcprintf>
	cprintf("\n");
  8002f7:	c7 04 24 e5 1e 80 00 	movl   $0x801ee5,(%esp)
  8002fe:	e8 a8 00 00 00       	call   8003ab <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800303:	cc                   	int3   
  800304:	eb fd                	jmp    800303 <_panic+0x53>
  800306:	66 90                	xchg   %ax,%ax

00800308 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800308:	55                   	push   %ebp
  800309:	89 e5                	mov    %esp,%ebp
  80030b:	53                   	push   %ebx
  80030c:	83 ec 14             	sub    $0x14,%esp
  80030f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800312:	8b 03                	mov    (%ebx),%eax
  800314:	8b 55 08             	mov    0x8(%ebp),%edx
  800317:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80031b:	83 c0 01             	add    $0x1,%eax
  80031e:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800320:	3d ff 00 00 00       	cmp    $0xff,%eax
  800325:	75 19                	jne    800340 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800327:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80032e:	00 
  80032f:	8d 43 08             	lea    0x8(%ebx),%eax
  800332:	89 04 24             	mov    %eax,(%esp)
  800335:	e8 f6 0a 00 00       	call   800e30 <sys_cputs>
		b->idx = 0;
  80033a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800340:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800344:	83 c4 14             	add    $0x14,%esp
  800347:	5b                   	pop    %ebx
  800348:	5d                   	pop    %ebp
  800349:	c3                   	ret    

0080034a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80034a:	55                   	push   %ebp
  80034b:	89 e5                	mov    %esp,%ebp
  80034d:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800353:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80035a:	00 00 00 
	b.cnt = 0;
  80035d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800364:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800367:	8b 45 0c             	mov    0xc(%ebp),%eax
  80036a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80036e:	8b 45 08             	mov    0x8(%ebp),%eax
  800371:	89 44 24 08          	mov    %eax,0x8(%esp)
  800375:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80037b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80037f:	c7 04 24 08 03 80 00 	movl   $0x800308,(%esp)
  800386:	e8 b7 01 00 00       	call   800542 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80038b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800391:	89 44 24 04          	mov    %eax,0x4(%esp)
  800395:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80039b:	89 04 24             	mov    %eax,(%esp)
  80039e:	e8 8d 0a 00 00       	call   800e30 <sys_cputs>

	return b.cnt;
}
  8003a3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003a9:	c9                   	leave  
  8003aa:	c3                   	ret    

008003ab <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003ab:	55                   	push   %ebp
  8003ac:	89 e5                	mov    %esp,%ebp
  8003ae:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003b1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8003bb:	89 04 24             	mov    %eax,(%esp)
  8003be:	e8 87 ff ff ff       	call   80034a <vcprintf>
	va_end(ap);

	return cnt;
}
  8003c3:	c9                   	leave  
  8003c4:	c3                   	ret    
  8003c5:	66 90                	xchg   %ax,%ax
  8003c7:	66 90                	xchg   %ax,%ax
  8003c9:	66 90                	xchg   %ax,%ax
  8003cb:	66 90                	xchg   %ax,%ax
  8003cd:	66 90                	xchg   %ax,%ax
  8003cf:	90                   	nop

008003d0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003d0:	55                   	push   %ebp
  8003d1:	89 e5                	mov    %esp,%ebp
  8003d3:	57                   	push   %edi
  8003d4:	56                   	push   %esi
  8003d5:	53                   	push   %ebx
  8003d6:	83 ec 4c             	sub    $0x4c,%esp
  8003d9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8003dc:	89 d7                	mov    %edx,%edi
  8003de:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8003e1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8003e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003e7:	89 5d dc             	mov    %ebx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ef:	39 d8                	cmp    %ebx,%eax
  8003f1:	72 17                	jb     80040a <printnum+0x3a>
  8003f3:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8003f6:	39 5d 10             	cmp    %ebx,0x10(%ebp)
  8003f9:	76 0f                	jbe    80040a <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003fb:	8b 75 14             	mov    0x14(%ebp),%esi
  8003fe:	83 ee 01             	sub    $0x1,%esi
  800401:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800404:	85 f6                	test   %esi,%esi
  800406:	7f 63                	jg     80046b <printnum+0x9b>
  800408:	eb 75                	jmp    80047f <printnum+0xaf>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80040a:	8b 5d 18             	mov    0x18(%ebp),%ebx
  80040d:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800411:	8b 45 14             	mov    0x14(%ebp),%eax
  800414:	83 e8 01             	sub    $0x1,%eax
  800417:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80041b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80041e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800422:	8b 44 24 08          	mov    0x8(%esp),%eax
  800426:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80042a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80042d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800430:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800437:	00 
  800438:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  80043b:	89 1c 24             	mov    %ebx,(%esp)
  80043e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800441:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800445:	e8 56 17 00 00       	call   801ba0 <__udivdi3>
  80044a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80044d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800450:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800454:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800458:	89 04 24             	mov    %eax,(%esp)
  80045b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80045f:	89 fa                	mov    %edi,%edx
  800461:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800464:	e8 67 ff ff ff       	call   8003d0 <printnum>
  800469:	eb 14                	jmp    80047f <printnum+0xaf>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80046b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80046f:	8b 45 18             	mov    0x18(%ebp),%eax
  800472:	89 04 24             	mov    %eax,(%esp)
  800475:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800477:	83 ee 01             	sub    $0x1,%esi
  80047a:	75 ef                	jne    80046b <printnum+0x9b>
  80047c:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80047f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800483:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800487:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80048a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80048e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800495:	00 
  800496:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800499:	89 1c 24             	mov    %ebx,(%esp)
  80049c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80049f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004a3:	e8 48 18 00 00       	call   801cf0 <__umoddi3>
  8004a8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004ac:	0f be 80 8b 1f 80 00 	movsbl 0x801f8b(%eax),%eax
  8004b3:	89 04 24             	mov    %eax,(%esp)
  8004b6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8004b9:	ff d0                	call   *%eax
}
  8004bb:	83 c4 4c             	add    $0x4c,%esp
  8004be:	5b                   	pop    %ebx
  8004bf:	5e                   	pop    %esi
  8004c0:	5f                   	pop    %edi
  8004c1:	5d                   	pop    %ebp
  8004c2:	c3                   	ret    

008004c3 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004c3:	55                   	push   %ebp
  8004c4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004c6:	83 fa 01             	cmp    $0x1,%edx
  8004c9:	7e 0e                	jle    8004d9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004cb:	8b 10                	mov    (%eax),%edx
  8004cd:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004d0:	89 08                	mov    %ecx,(%eax)
  8004d2:	8b 02                	mov    (%edx),%eax
  8004d4:	8b 52 04             	mov    0x4(%edx),%edx
  8004d7:	eb 22                	jmp    8004fb <getuint+0x38>
	else if (lflag)
  8004d9:	85 d2                	test   %edx,%edx
  8004db:	74 10                	je     8004ed <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004dd:	8b 10                	mov    (%eax),%edx
  8004df:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004e2:	89 08                	mov    %ecx,(%eax)
  8004e4:	8b 02                	mov    (%edx),%eax
  8004e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8004eb:	eb 0e                	jmp    8004fb <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004ed:	8b 10                	mov    (%eax),%edx
  8004ef:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004f2:	89 08                	mov    %ecx,(%eax)
  8004f4:	8b 02                	mov    (%edx),%eax
  8004f6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004fb:	5d                   	pop    %ebp
  8004fc:	c3                   	ret    

008004fd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004fd:	55                   	push   %ebp
  8004fe:	89 e5                	mov    %esp,%ebp
  800500:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800503:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800507:	8b 10                	mov    (%eax),%edx
  800509:	3b 50 04             	cmp    0x4(%eax),%edx
  80050c:	73 0a                	jae    800518 <sprintputch+0x1b>
		*b->buf++ = ch;
  80050e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800511:	88 0a                	mov    %cl,(%edx)
  800513:	83 c2 01             	add    $0x1,%edx
  800516:	89 10                	mov    %edx,(%eax)
}
  800518:	5d                   	pop    %ebp
  800519:	c3                   	ret    

0080051a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80051a:	55                   	push   %ebp
  80051b:	89 e5                	mov    %esp,%ebp
  80051d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800520:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800523:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800527:	8b 45 10             	mov    0x10(%ebp),%eax
  80052a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80052e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800531:	89 44 24 04          	mov    %eax,0x4(%esp)
  800535:	8b 45 08             	mov    0x8(%ebp),%eax
  800538:	89 04 24             	mov    %eax,(%esp)
  80053b:	e8 02 00 00 00       	call   800542 <vprintfmt>
	va_end(ap);
}
  800540:	c9                   	leave  
  800541:	c3                   	ret    

00800542 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800542:	55                   	push   %ebp
  800543:	89 e5                	mov    %esp,%ebp
  800545:	57                   	push   %edi
  800546:	56                   	push   %esi
  800547:	53                   	push   %ebx
  800548:	83 ec 4c             	sub    $0x4c,%esp
  80054b:	8b 75 08             	mov    0x8(%ebp),%esi
  80054e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800551:	8b 7d 10             	mov    0x10(%ebp),%edi
  800554:	eb 11                	jmp    800567 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800556:	85 c0                	test   %eax,%eax
  800558:	0f 84 db 03 00 00    	je     800939 <vprintfmt+0x3f7>
				return;
			putch(ch, putdat);
  80055e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800562:	89 04 24             	mov    %eax,(%esp)
  800565:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800567:	0f b6 07             	movzbl (%edi),%eax
  80056a:	83 c7 01             	add    $0x1,%edi
  80056d:	83 f8 25             	cmp    $0x25,%eax
  800570:	75 e4                	jne    800556 <vprintfmt+0x14>
  800572:	c6 45 e4 20          	movb   $0x20,-0x1c(%ebp)
  800576:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80057d:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800584:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80058b:	ba 00 00 00 00       	mov    $0x0,%edx
  800590:	eb 2b                	jmp    8005bd <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800592:	8b 7d e0             	mov    -0x20(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800595:	c6 45 e4 2d          	movb   $0x2d,-0x1c(%ebp)
  800599:	eb 22                	jmp    8005bd <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059b:	8b 7d e0             	mov    -0x20(%ebp),%edi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80059e:	c6 45 e4 30          	movb   $0x30,-0x1c(%ebp)
  8005a2:	eb 19                	jmp    8005bd <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a4:	8b 7d e0             	mov    -0x20(%ebp),%edi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8005a7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8005ae:	eb 0d                	jmp    8005bd <vprintfmt+0x7b>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8005b0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b6:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bd:	0f b6 0f             	movzbl (%edi),%ecx
  8005c0:	8d 47 01             	lea    0x1(%edi),%eax
  8005c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005c6:	0f b6 07             	movzbl (%edi),%eax
  8005c9:	83 e8 23             	sub    $0x23,%eax
  8005cc:	3c 55                	cmp    $0x55,%al
  8005ce:	0f 87 40 03 00 00    	ja     800914 <vprintfmt+0x3d2>
  8005d4:	0f b6 c0             	movzbl %al,%eax
  8005d7:	ff 24 85 e0 20 80 00 	jmp    *0x8020e0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005de:	83 e9 30             	sub    $0x30,%ecx
  8005e1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				ch = *fmt;
  8005e4:	0f be 47 01          	movsbl 0x1(%edi),%eax
				if (ch < '0' || ch > '9')
  8005e8:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8005eb:	83 f9 09             	cmp    $0x9,%ecx
  8005ee:	77 57                	ja     800647 <vprintfmt+0x105>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f0:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005f3:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005f6:	8b 55 dc             	mov    -0x24(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005f9:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8005fc:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8005ff:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800603:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  800606:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800609:	83 f9 09             	cmp    $0x9,%ecx
  80060c:	76 eb                	jbe    8005f9 <vprintfmt+0xb7>
  80060e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800611:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800614:	eb 34                	jmp    80064a <vprintfmt+0x108>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800616:	8b 45 14             	mov    0x14(%ebp),%eax
  800619:	8d 48 04             	lea    0x4(%eax),%ecx
  80061c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80061f:	8b 00                	mov    (%eax),%eax
  800621:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800624:	8b 7d e0             	mov    -0x20(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800627:	eb 21                	jmp    80064a <vprintfmt+0x108>

		case '.':
			if (width < 0)
  800629:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80062d:	0f 88 71 ff ff ff    	js     8005a4 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800633:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800636:	eb 85                	jmp    8005bd <vprintfmt+0x7b>
  800638:	8b 7d e0             	mov    -0x20(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80063b:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  800642:	e9 76 ff ff ff       	jmp    8005bd <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800647:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80064a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80064e:	0f 89 69 ff ff ff    	jns    8005bd <vprintfmt+0x7b>
  800654:	e9 57 ff ff ff       	jmp    8005b0 <vprintfmt+0x6e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800659:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80065f:	e9 59 ff ff ff       	jmp    8005bd <vprintfmt+0x7b>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800664:	8b 45 14             	mov    0x14(%ebp),%eax
  800667:	8d 50 04             	lea    0x4(%eax),%edx
  80066a:	89 55 14             	mov    %edx,0x14(%ebp)
  80066d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800671:	8b 00                	mov    (%eax),%eax
  800673:	89 04 24             	mov    %eax,(%esp)
  800676:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800678:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80067b:	e9 e7 fe ff ff       	jmp    800567 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800680:	8b 45 14             	mov    0x14(%ebp),%eax
  800683:	8d 50 04             	lea    0x4(%eax),%edx
  800686:	89 55 14             	mov    %edx,0x14(%ebp)
  800689:	8b 00                	mov    (%eax),%eax
  80068b:	89 c2                	mov    %eax,%edx
  80068d:	c1 fa 1f             	sar    $0x1f,%edx
  800690:	31 d0                	xor    %edx,%eax
  800692:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800694:	83 f8 0f             	cmp    $0xf,%eax
  800697:	7f 0b                	jg     8006a4 <vprintfmt+0x162>
  800699:	8b 14 85 40 22 80 00 	mov    0x802240(,%eax,4),%edx
  8006a0:	85 d2                	test   %edx,%edx
  8006a2:	75 20                	jne    8006c4 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  8006a4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006a8:	c7 44 24 08 a3 1f 80 	movl   $0x801fa3,0x8(%esp)
  8006af:	00 
  8006b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b4:	89 34 24             	mov    %esi,(%esp)
  8006b7:	e8 5e fe ff ff       	call   80051a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006bc:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8006bf:	e9 a3 fe ff ff       	jmp    800567 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  8006c4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006c8:	c7 44 24 08 ac 1f 80 	movl   $0x801fac,0x8(%esp)
  8006cf:	00 
  8006d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006d4:	89 34 24             	mov    %esi,(%esp)
  8006d7:	e8 3e fe ff ff       	call   80051a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006dc:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8006df:	e9 83 fe ff ff       	jmp    800567 <vprintfmt+0x25>
  8006e4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006e7:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8006ea:	89 7d cc             	mov    %edi,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f0:	8d 50 04             	lea    0x4(%eax),%edx
  8006f3:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006f8:	85 ff                	test   %edi,%edi
  8006fa:	b8 9c 1f 80 00       	mov    $0x801f9c,%eax
  8006ff:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800702:	80 7d e4 2d          	cmpb   $0x2d,-0x1c(%ebp)
  800706:	74 06                	je     80070e <vprintfmt+0x1cc>
  800708:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80070c:	7f 16                	jg     800724 <vprintfmt+0x1e2>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80070e:	0f b6 17             	movzbl (%edi),%edx
  800711:	0f be c2             	movsbl %dl,%eax
  800714:	83 c7 01             	add    $0x1,%edi
  800717:	85 c0                	test   %eax,%eax
  800719:	0f 85 9f 00 00 00    	jne    8007be <vprintfmt+0x27c>
  80071f:	e9 8b 00 00 00       	jmp    8007af <vprintfmt+0x26d>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800724:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800728:	89 3c 24             	mov    %edi,(%esp)
  80072b:	e8 c2 02 00 00       	call   8009f2 <strnlen>
  800730:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800733:	29 c2                	sub    %eax,%edx
  800735:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800738:	85 d2                	test   %edx,%edx
  80073a:	7e d2                	jle    80070e <vprintfmt+0x1cc>
					putch(padc, putdat);
  80073c:	0f be 4d e4          	movsbl -0x1c(%ebp),%ecx
  800740:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800743:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800746:	89 d7                	mov    %edx,%edi
  800748:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80074c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80074f:	89 04 24             	mov    %eax,(%esp)
  800752:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800754:	83 ef 01             	sub    $0x1,%edi
  800757:	75 ef                	jne    800748 <vprintfmt+0x206>
  800759:	89 7d d8             	mov    %edi,-0x28(%ebp)
  80075c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80075f:	eb ad                	jmp    80070e <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800761:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800765:	74 20                	je     800787 <vprintfmt+0x245>
  800767:	0f be d2             	movsbl %dl,%edx
  80076a:	83 ea 20             	sub    $0x20,%edx
  80076d:	83 fa 5e             	cmp    $0x5e,%edx
  800770:	76 15                	jbe    800787 <vprintfmt+0x245>
					putch('?', putdat);
  800772:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800775:	89 54 24 04          	mov    %edx,0x4(%esp)
  800779:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800780:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800783:	ff d1                	call   *%ecx
  800785:	eb 0f                	jmp    800796 <vprintfmt+0x254>
				else
					putch(ch, putdat);
  800787:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80078a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80078e:	89 04 24             	mov    %eax,(%esp)
  800791:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800794:	ff d1                	call   *%ecx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800796:	83 eb 01             	sub    $0x1,%ebx
  800799:	0f b6 17             	movzbl (%edi),%edx
  80079c:	0f be c2             	movsbl %dl,%eax
  80079f:	83 c7 01             	add    $0x1,%edi
  8007a2:	85 c0                	test   %eax,%eax
  8007a4:	75 24                	jne    8007ca <vprintfmt+0x288>
  8007a6:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8007a9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8007ac:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007af:	8b 7d e0             	mov    -0x20(%ebp),%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007b2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8007b6:	0f 8e ab fd ff ff    	jle    800567 <vprintfmt+0x25>
  8007bc:	eb 20                	jmp    8007de <vprintfmt+0x29c>
  8007be:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  8007c1:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8007c4:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8007c7:	8b 5d d8             	mov    -0x28(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007ca:	85 f6                	test   %esi,%esi
  8007cc:	78 93                	js     800761 <vprintfmt+0x21f>
  8007ce:	83 ee 01             	sub    $0x1,%esi
  8007d1:	79 8e                	jns    800761 <vprintfmt+0x21f>
  8007d3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8007d6:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8007d9:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8007dc:	eb d1                	jmp    8007af <vprintfmt+0x26d>
  8007de:	8b 7d d8             	mov    -0x28(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007e1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8007ec:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007ee:	83 ef 01             	sub    $0x1,%edi
  8007f1:	75 ee                	jne    8007e1 <vprintfmt+0x29f>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007f3:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8007f6:	e9 6c fd ff ff       	jmp    800567 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007fb:	83 fa 01             	cmp    $0x1,%edx
  8007fe:	66 90                	xchg   %ax,%ax
  800800:	7e 16                	jle    800818 <vprintfmt+0x2d6>
		return va_arg(*ap, long long);
  800802:	8b 45 14             	mov    0x14(%ebp),%eax
  800805:	8d 50 08             	lea    0x8(%eax),%edx
  800808:	89 55 14             	mov    %edx,0x14(%ebp)
  80080b:	8b 10                	mov    (%eax),%edx
  80080d:	8b 48 04             	mov    0x4(%eax),%ecx
  800810:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800813:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800816:	eb 32                	jmp    80084a <vprintfmt+0x308>
	else if (lflag)
  800818:	85 d2                	test   %edx,%edx
  80081a:	74 18                	je     800834 <vprintfmt+0x2f2>
		return va_arg(*ap, long);
  80081c:	8b 45 14             	mov    0x14(%ebp),%eax
  80081f:	8d 50 04             	lea    0x4(%eax),%edx
  800822:	89 55 14             	mov    %edx,0x14(%ebp)
  800825:	8b 00                	mov    (%eax),%eax
  800827:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80082a:	89 c1                	mov    %eax,%ecx
  80082c:	c1 f9 1f             	sar    $0x1f,%ecx
  80082f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800832:	eb 16                	jmp    80084a <vprintfmt+0x308>
	else
		return va_arg(*ap, int);
  800834:	8b 45 14             	mov    0x14(%ebp),%eax
  800837:	8d 50 04             	lea    0x4(%eax),%edx
  80083a:	89 55 14             	mov    %edx,0x14(%ebp)
  80083d:	8b 00                	mov    (%eax),%eax
  80083f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800842:	89 c7                	mov    %eax,%edi
  800844:	c1 ff 1f             	sar    $0x1f,%edi
  800847:	89 7d d4             	mov    %edi,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80084a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80084d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800850:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800855:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800859:	79 7d                	jns    8008d8 <vprintfmt+0x396>
				putch('-', putdat);
  80085b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80085f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800866:	ff d6                	call   *%esi
				num = -(long long) num;
  800868:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80086b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80086e:	f7 d8                	neg    %eax
  800870:	83 d2 00             	adc    $0x0,%edx
  800873:	f7 da                	neg    %edx
			}
			base = 10;
  800875:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80087a:	eb 5c                	jmp    8008d8 <vprintfmt+0x396>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80087c:	8d 45 14             	lea    0x14(%ebp),%eax
  80087f:	e8 3f fc ff ff       	call   8004c3 <getuint>
			base = 10;
  800884:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800889:	eb 4d                	jmp    8008d8 <vprintfmt+0x396>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80088b:	8d 45 14             	lea    0x14(%ebp),%eax
  80088e:	e8 30 fc ff ff       	call   8004c3 <getuint>
			base = 8;
  800893:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800898:	eb 3e                	jmp    8008d8 <vprintfmt+0x396>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80089a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80089e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8008a5:	ff d6                	call   *%esi
			putch('x', putdat);
  8008a7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008ab:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8008b2:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b7:	8d 50 04             	lea    0x4(%eax),%edx
  8008ba:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008bd:	8b 00                	mov    (%eax),%eax
  8008bf:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008c4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8008c9:	eb 0d                	jmp    8008d8 <vprintfmt+0x396>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008cb:	8d 45 14             	lea    0x14(%ebp),%eax
  8008ce:	e8 f0 fb ff ff       	call   8004c3 <getuint>
			base = 16;
  8008d3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008d8:	0f be 7d e4          	movsbl -0x1c(%ebp),%edi
  8008dc:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8008e0:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8008e3:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8008e7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8008eb:	89 04 24             	mov    %eax,(%esp)
  8008ee:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008f2:	89 da                	mov    %ebx,%edx
  8008f4:	89 f0                	mov    %esi,%eax
  8008f6:	e8 d5 fa ff ff       	call   8003d0 <printnum>
			break;
  8008fb:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8008fe:	e9 64 fc ff ff       	jmp    800567 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800903:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800907:	89 0c 24             	mov    %ecx,(%esp)
  80090a:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80090c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80090f:	e9 53 fc ff ff       	jmp    800567 <vprintfmt+0x25>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800914:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800918:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80091f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800921:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800925:	0f 84 3c fc ff ff    	je     800567 <vprintfmt+0x25>
  80092b:	83 ef 01             	sub    $0x1,%edi
  80092e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800932:	75 f7                	jne    80092b <vprintfmt+0x3e9>
  800934:	e9 2e fc ff ff       	jmp    800567 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800939:	83 c4 4c             	add    $0x4c,%esp
  80093c:	5b                   	pop    %ebx
  80093d:	5e                   	pop    %esi
  80093e:	5f                   	pop    %edi
  80093f:	5d                   	pop    %ebp
  800940:	c3                   	ret    

00800941 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800941:	55                   	push   %ebp
  800942:	89 e5                	mov    %esp,%ebp
  800944:	83 ec 28             	sub    $0x28,%esp
  800947:	8b 45 08             	mov    0x8(%ebp),%eax
  80094a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80094d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800950:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800954:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800957:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80095e:	85 d2                	test   %edx,%edx
  800960:	7e 30                	jle    800992 <vsnprintf+0x51>
  800962:	85 c0                	test   %eax,%eax
  800964:	74 2c                	je     800992 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800966:	8b 45 14             	mov    0x14(%ebp),%eax
  800969:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80096d:	8b 45 10             	mov    0x10(%ebp),%eax
  800970:	89 44 24 08          	mov    %eax,0x8(%esp)
  800974:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800977:	89 44 24 04          	mov    %eax,0x4(%esp)
  80097b:	c7 04 24 fd 04 80 00 	movl   $0x8004fd,(%esp)
  800982:	e8 bb fb ff ff       	call   800542 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800987:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80098a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80098d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800990:	eb 05                	jmp    800997 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800992:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800997:	c9                   	leave  
  800998:	c3                   	ret    

00800999 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800999:	55                   	push   %ebp
  80099a:	89 e5                	mov    %esp,%ebp
  80099c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80099f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009a6:	8b 45 10             	mov    0x10(%ebp),%eax
  8009a9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b7:	89 04 24             	mov    %eax,(%esp)
  8009ba:	e8 82 ff ff ff       	call   800941 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009bf:	c9                   	leave  
  8009c0:	c3                   	ret    
  8009c1:	66 90                	xchg   %ax,%ax
  8009c3:	66 90                	xchg   %ax,%ax
  8009c5:	66 90                	xchg   %ax,%ax
  8009c7:	66 90                	xchg   %ax,%ax
  8009c9:	66 90                	xchg   %ax,%ax
  8009cb:	66 90                	xchg   %ax,%ax
  8009cd:	66 90                	xchg   %ax,%ax
  8009cf:	90                   	nop

008009d0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009d0:	55                   	push   %ebp
  8009d1:	89 e5                	mov    %esp,%ebp
  8009d3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009d6:	80 3a 00             	cmpb   $0x0,(%edx)
  8009d9:	74 10                	je     8009eb <strlen+0x1b>
  8009db:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8009e0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009e3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009e7:	75 f7                	jne    8009e0 <strlen+0x10>
  8009e9:	eb 05                	jmp    8009f0 <strlen+0x20>
  8009eb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8009f0:	5d                   	pop    %ebp
  8009f1:	c3                   	ret    

008009f2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009f2:	55                   	push   %ebp
  8009f3:	89 e5                	mov    %esp,%ebp
  8009f5:	53                   	push   %ebx
  8009f6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009fc:	85 c9                	test   %ecx,%ecx
  8009fe:	74 1c                	je     800a1c <strnlen+0x2a>
  800a00:	80 3b 00             	cmpb   $0x0,(%ebx)
  800a03:	74 1e                	je     800a23 <strnlen+0x31>
  800a05:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800a0a:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a0c:	39 ca                	cmp    %ecx,%edx
  800a0e:	74 18                	je     800a28 <strnlen+0x36>
  800a10:	83 c2 01             	add    $0x1,%edx
  800a13:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800a18:	75 f0                	jne    800a0a <strnlen+0x18>
  800a1a:	eb 0c                	jmp    800a28 <strnlen+0x36>
  800a1c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a21:	eb 05                	jmp    800a28 <strnlen+0x36>
  800a23:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800a28:	5b                   	pop    %ebx
  800a29:	5d                   	pop    %ebp
  800a2a:	c3                   	ret    

00800a2b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a2b:	55                   	push   %ebp
  800a2c:	89 e5                	mov    %esp,%ebp
  800a2e:	53                   	push   %ebx
  800a2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a35:	89 c2                	mov    %eax,%edx
  800a37:	0f b6 19             	movzbl (%ecx),%ebx
  800a3a:	88 1a                	mov    %bl,(%edx)
  800a3c:	83 c2 01             	add    $0x1,%edx
  800a3f:	83 c1 01             	add    $0x1,%ecx
  800a42:	84 db                	test   %bl,%bl
  800a44:	75 f1                	jne    800a37 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a46:	5b                   	pop    %ebx
  800a47:	5d                   	pop    %ebp
  800a48:	c3                   	ret    

00800a49 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a49:	55                   	push   %ebp
  800a4a:	89 e5                	mov    %esp,%ebp
  800a4c:	53                   	push   %ebx
  800a4d:	83 ec 08             	sub    $0x8,%esp
  800a50:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a53:	89 1c 24             	mov    %ebx,(%esp)
  800a56:	e8 75 ff ff ff       	call   8009d0 <strlen>
	strcpy(dst + len, src);
  800a5b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a5e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a62:	01 d8                	add    %ebx,%eax
  800a64:	89 04 24             	mov    %eax,(%esp)
  800a67:	e8 bf ff ff ff       	call   800a2b <strcpy>
	return dst;
}
  800a6c:	89 d8                	mov    %ebx,%eax
  800a6e:	83 c4 08             	add    $0x8,%esp
  800a71:	5b                   	pop    %ebx
  800a72:	5d                   	pop    %ebp
  800a73:	c3                   	ret    

00800a74 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a74:	55                   	push   %ebp
  800a75:	89 e5                	mov    %esp,%ebp
  800a77:	56                   	push   %esi
  800a78:	53                   	push   %ebx
  800a79:	8b 75 08             	mov    0x8(%ebp),%esi
  800a7c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a7f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a82:	85 db                	test   %ebx,%ebx
  800a84:	74 16                	je     800a9c <strncpy+0x28>
	strcpy(dst + len, src);
	return dst;
}

char *
strncpy(char *dst, const char *src, size_t size) {
  800a86:	01 f3                	add    %esi,%ebx
  800a88:	89 f1                	mov    %esi,%ecx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  800a8a:	0f b6 02             	movzbl (%edx),%eax
  800a8d:	88 01                	mov    %al,(%ecx)
  800a8f:	83 c1 01             	add    $0x1,%ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a92:	80 3a 01             	cmpb   $0x1,(%edx)
  800a95:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a98:	39 d9                	cmp    %ebx,%ecx
  800a9a:	75 ee                	jne    800a8a <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a9c:	89 f0                	mov    %esi,%eax
  800a9e:	5b                   	pop    %ebx
  800a9f:	5e                   	pop    %esi
  800aa0:	5d                   	pop    %ebp
  800aa1:	c3                   	ret    

00800aa2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800aa2:	55                   	push   %ebp
  800aa3:	89 e5                	mov    %esp,%ebp
  800aa5:	57                   	push   %edi
  800aa6:	56                   	push   %esi
  800aa7:	53                   	push   %ebx
  800aa8:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800aae:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ab1:	89 f8                	mov    %edi,%eax
  800ab3:	85 f6                	test   %esi,%esi
  800ab5:	74 33                	je     800aea <strlcpy+0x48>
		while (--size > 0 && *src != '\0')
  800ab7:	83 fe 01             	cmp    $0x1,%esi
  800aba:	74 25                	je     800ae1 <strlcpy+0x3f>
  800abc:	0f b6 0b             	movzbl (%ebx),%ecx
  800abf:	84 c9                	test   %cl,%cl
  800ac1:	74 22                	je     800ae5 <strlcpy+0x43>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800ac3:	83 ee 02             	sub    $0x2,%esi
  800ac6:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800acb:	88 08                	mov    %cl,(%eax)
  800acd:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ad0:	39 f2                	cmp    %esi,%edx
  800ad2:	74 13                	je     800ae7 <strlcpy+0x45>
  800ad4:	83 c2 01             	add    $0x1,%edx
  800ad7:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800adb:	84 c9                	test   %cl,%cl
  800add:	75 ec                	jne    800acb <strlcpy+0x29>
  800adf:	eb 06                	jmp    800ae7 <strlcpy+0x45>
  800ae1:	89 f8                	mov    %edi,%eax
  800ae3:	eb 02                	jmp    800ae7 <strlcpy+0x45>
  800ae5:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800ae7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800aea:	29 f8                	sub    %edi,%eax
}
  800aec:	5b                   	pop    %ebx
  800aed:	5e                   	pop    %esi
  800aee:	5f                   	pop    %edi
  800aef:	5d                   	pop    %ebp
  800af0:	c3                   	ret    

00800af1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800af1:	55                   	push   %ebp
  800af2:	89 e5                	mov    %esp,%ebp
  800af4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800af7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800afa:	0f b6 01             	movzbl (%ecx),%eax
  800afd:	84 c0                	test   %al,%al
  800aff:	74 15                	je     800b16 <strcmp+0x25>
  800b01:	3a 02                	cmp    (%edx),%al
  800b03:	75 11                	jne    800b16 <strcmp+0x25>
		p++, q++;
  800b05:	83 c1 01             	add    $0x1,%ecx
  800b08:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b0b:	0f b6 01             	movzbl (%ecx),%eax
  800b0e:	84 c0                	test   %al,%al
  800b10:	74 04                	je     800b16 <strcmp+0x25>
  800b12:	3a 02                	cmp    (%edx),%al
  800b14:	74 ef                	je     800b05 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b16:	0f b6 c0             	movzbl %al,%eax
  800b19:	0f b6 12             	movzbl (%edx),%edx
  800b1c:	29 d0                	sub    %edx,%eax
}
  800b1e:	5d                   	pop    %ebp
  800b1f:	c3                   	ret    

00800b20 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
  800b23:	56                   	push   %esi
  800b24:	53                   	push   %ebx
  800b25:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b28:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b2b:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800b2e:	85 f6                	test   %esi,%esi
  800b30:	74 29                	je     800b5b <strncmp+0x3b>
  800b32:	0f b6 03             	movzbl (%ebx),%eax
  800b35:	84 c0                	test   %al,%al
  800b37:	74 30                	je     800b69 <strncmp+0x49>
  800b39:	3a 02                	cmp    (%edx),%al
  800b3b:	75 2c                	jne    800b69 <strncmp+0x49>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}

int
strncmp(const char *p, const char *q, size_t n)
  800b3d:	8d 43 01             	lea    0x1(%ebx),%eax
  800b40:	01 de                	add    %ebx,%esi
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800b42:	89 c3                	mov    %eax,%ebx
  800b44:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b47:	39 f0                	cmp    %esi,%eax
  800b49:	74 17                	je     800b62 <strncmp+0x42>
  800b4b:	0f b6 08             	movzbl (%eax),%ecx
  800b4e:	84 c9                	test   %cl,%cl
  800b50:	74 17                	je     800b69 <strncmp+0x49>
  800b52:	83 c0 01             	add    $0x1,%eax
  800b55:	3a 0a                	cmp    (%edx),%cl
  800b57:	74 e9                	je     800b42 <strncmp+0x22>
  800b59:	eb 0e                	jmp    800b69 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b5b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b60:	eb 0f                	jmp    800b71 <strncmp+0x51>
  800b62:	b8 00 00 00 00       	mov    $0x0,%eax
  800b67:	eb 08                	jmp    800b71 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b69:	0f b6 03             	movzbl (%ebx),%eax
  800b6c:	0f b6 12             	movzbl (%edx),%edx
  800b6f:	29 d0                	sub    %edx,%eax
}
  800b71:	5b                   	pop    %ebx
  800b72:	5e                   	pop    %esi
  800b73:	5d                   	pop    %ebp
  800b74:	c3                   	ret    

00800b75 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
  800b78:	53                   	push   %ebx
  800b79:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7c:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800b7f:	0f b6 18             	movzbl (%eax),%ebx
  800b82:	84 db                	test   %bl,%bl
  800b84:	74 1d                	je     800ba3 <strchr+0x2e>
  800b86:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800b88:	38 d3                	cmp    %dl,%bl
  800b8a:	75 06                	jne    800b92 <strchr+0x1d>
  800b8c:	eb 1a                	jmp    800ba8 <strchr+0x33>
  800b8e:	38 ca                	cmp    %cl,%dl
  800b90:	74 16                	je     800ba8 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b92:	83 c0 01             	add    $0x1,%eax
  800b95:	0f b6 10             	movzbl (%eax),%edx
  800b98:	84 d2                	test   %dl,%dl
  800b9a:	75 f2                	jne    800b8e <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800b9c:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba1:	eb 05                	jmp    800ba8 <strchr+0x33>
  800ba3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ba8:	5b                   	pop    %ebx
  800ba9:	5d                   	pop    %ebp
  800baa:	c3                   	ret    

00800bab <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bab:	55                   	push   %ebp
  800bac:	89 e5                	mov    %esp,%ebp
  800bae:	53                   	push   %ebx
  800baf:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb2:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800bb5:	0f b6 18             	movzbl (%eax),%ebx
  800bb8:	84 db                	test   %bl,%bl
  800bba:	74 16                	je     800bd2 <strfind+0x27>
  800bbc:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800bbe:	38 d3                	cmp    %dl,%bl
  800bc0:	75 06                	jne    800bc8 <strfind+0x1d>
  800bc2:	eb 0e                	jmp    800bd2 <strfind+0x27>
  800bc4:	38 ca                	cmp    %cl,%dl
  800bc6:	74 0a                	je     800bd2 <strfind+0x27>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800bc8:	83 c0 01             	add    $0x1,%eax
  800bcb:	0f b6 10             	movzbl (%eax),%edx
  800bce:	84 d2                	test   %dl,%dl
  800bd0:	75 f2                	jne    800bc4 <strfind+0x19>
		if (*s == c)
			break;
	return (char *) s;
}
  800bd2:	5b                   	pop    %ebx
  800bd3:	5d                   	pop    %ebp
  800bd4:	c3                   	ret    

00800bd5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bd5:	55                   	push   %ebp
  800bd6:	89 e5                	mov    %esp,%ebp
  800bd8:	83 ec 0c             	sub    $0xc,%esp
  800bdb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800bde:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800be1:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800be4:	8b 7d 08             	mov    0x8(%ebp),%edi
  800be7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bea:	85 c9                	test   %ecx,%ecx
  800bec:	74 36                	je     800c24 <memset+0x4f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bee:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bf4:	75 28                	jne    800c1e <memset+0x49>
  800bf6:	f6 c1 03             	test   $0x3,%cl
  800bf9:	75 23                	jne    800c1e <memset+0x49>
		c &= 0xFF;
  800bfb:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bff:	89 d3                	mov    %edx,%ebx
  800c01:	c1 e3 08             	shl    $0x8,%ebx
  800c04:	89 d6                	mov    %edx,%esi
  800c06:	c1 e6 18             	shl    $0x18,%esi
  800c09:	89 d0                	mov    %edx,%eax
  800c0b:	c1 e0 10             	shl    $0x10,%eax
  800c0e:	09 f0                	or     %esi,%eax
  800c10:	09 c2                	or     %eax,%edx
  800c12:	89 d0                	mov    %edx,%eax
  800c14:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c16:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800c19:	fc                   	cld    
  800c1a:	f3 ab                	rep stos %eax,%es:(%edi)
  800c1c:	eb 06                	jmp    800c24 <memset+0x4f>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c21:	fc                   	cld    
  800c22:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");

	return v;
}
  800c24:	89 f8                	mov    %edi,%eax
  800c26:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c29:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c2c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c2f:	89 ec                	mov    %ebp,%esp
  800c31:	5d                   	pop    %ebp
  800c32:	c3                   	ret    

00800c33 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	83 ec 08             	sub    $0x8,%esp
  800c39:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c3c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800c3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c42:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c45:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c48:	39 c6                	cmp    %eax,%esi
  800c4a:	73 36                	jae    800c82 <memmove+0x4f>
  800c4c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c4f:	39 d0                	cmp    %edx,%eax
  800c51:	73 2f                	jae    800c82 <memmove+0x4f>
		s += n;
		d += n;
  800c53:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c56:	f6 c2 03             	test   $0x3,%dl
  800c59:	75 1b                	jne    800c76 <memmove+0x43>
  800c5b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c61:	75 13                	jne    800c76 <memmove+0x43>
  800c63:	f6 c1 03             	test   $0x3,%cl
  800c66:	75 0e                	jne    800c76 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c68:	83 ef 04             	sub    $0x4,%edi
  800c6b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c6e:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c71:	fd                   	std    
  800c72:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c74:	eb 09                	jmp    800c7f <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c76:	83 ef 01             	sub    $0x1,%edi
  800c79:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c7c:	fd                   	std    
  800c7d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c7f:	fc                   	cld    
  800c80:	eb 20                	jmp    800ca2 <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c82:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c88:	75 13                	jne    800c9d <memmove+0x6a>
  800c8a:	a8 03                	test   $0x3,%al
  800c8c:	75 0f                	jne    800c9d <memmove+0x6a>
  800c8e:	f6 c1 03             	test   $0x3,%cl
  800c91:	75 0a                	jne    800c9d <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c93:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c96:	89 c7                	mov    %eax,%edi
  800c98:	fc                   	cld    
  800c99:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c9b:	eb 05                	jmp    800ca2 <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c9d:	89 c7                	mov    %eax,%edi
  800c9f:	fc                   	cld    
  800ca0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ca2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ca5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ca8:	89 ec                	mov    %ebp,%esp
  800caa:	5d                   	pop    %ebp
  800cab:	c3                   	ret    

00800cac <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800cac:	55                   	push   %ebp
  800cad:	89 e5                	mov    %esp,%ebp
  800caf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800cb2:	8b 45 10             	mov    0x10(%ebp),%eax
  800cb5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cb9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cbc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cc0:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc3:	89 04 24             	mov    %eax,(%esp)
  800cc6:	e8 68 ff ff ff       	call   800c33 <memmove>
}
  800ccb:	c9                   	leave  
  800ccc:	c3                   	ret    

00800ccd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ccd:	55                   	push   %ebp
  800cce:	89 e5                	mov    %esp,%ebp
  800cd0:	57                   	push   %edi
  800cd1:	56                   	push   %esi
  800cd2:	53                   	push   %ebx
  800cd3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800cd6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cd9:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cdc:	8d 78 ff             	lea    -0x1(%eax),%edi
  800cdf:	85 c0                	test   %eax,%eax
  800ce1:	74 36                	je     800d19 <memcmp+0x4c>
		if (*s1 != *s2)
  800ce3:	0f b6 03             	movzbl (%ebx),%eax
  800ce6:	0f b6 0e             	movzbl (%esi),%ecx
  800ce9:	38 c8                	cmp    %cl,%al
  800ceb:	75 17                	jne    800d04 <memcmp+0x37>
  800ced:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf2:	eb 1a                	jmp    800d0e <memcmp+0x41>
  800cf4:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800cf9:	83 c2 01             	add    $0x1,%edx
  800cfc:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800d00:	38 c8                	cmp    %cl,%al
  800d02:	74 0a                	je     800d0e <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800d04:	0f b6 c0             	movzbl %al,%eax
  800d07:	0f b6 c9             	movzbl %cl,%ecx
  800d0a:	29 c8                	sub    %ecx,%eax
  800d0c:	eb 10                	jmp    800d1e <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d0e:	39 fa                	cmp    %edi,%edx
  800d10:	75 e2                	jne    800cf4 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d12:	b8 00 00 00 00       	mov    $0x0,%eax
  800d17:	eb 05                	jmp    800d1e <memcmp+0x51>
  800d19:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d1e:	5b                   	pop    %ebx
  800d1f:	5e                   	pop    %esi
  800d20:	5f                   	pop    %edi
  800d21:	5d                   	pop    %ebp
  800d22:	c3                   	ret    

00800d23 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d23:	55                   	push   %ebp
  800d24:	89 e5                	mov    %esp,%ebp
  800d26:	53                   	push   %ebx
  800d27:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800d2d:	89 c2                	mov    %eax,%edx
  800d2f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d32:	39 d0                	cmp    %edx,%eax
  800d34:	73 13                	jae    800d49 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d36:	89 d9                	mov    %ebx,%ecx
  800d38:	38 18                	cmp    %bl,(%eax)
  800d3a:	75 06                	jne    800d42 <memfind+0x1f>
  800d3c:	eb 0b                	jmp    800d49 <memfind+0x26>
  800d3e:	38 08                	cmp    %cl,(%eax)
  800d40:	74 07                	je     800d49 <memfind+0x26>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d42:	83 c0 01             	add    $0x1,%eax
  800d45:	39 d0                	cmp    %edx,%eax
  800d47:	75 f5                	jne    800d3e <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d49:	5b                   	pop    %ebx
  800d4a:	5d                   	pop    %ebp
  800d4b:	c3                   	ret    

00800d4c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d4c:	55                   	push   %ebp
  800d4d:	89 e5                	mov    %esp,%ebp
  800d4f:	57                   	push   %edi
  800d50:	56                   	push   %esi
  800d51:	53                   	push   %ebx
  800d52:	83 ec 04             	sub    $0x4,%esp
  800d55:	8b 55 08             	mov    0x8(%ebp),%edx
  800d58:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d5b:	0f b6 02             	movzbl (%edx),%eax
  800d5e:	3c 09                	cmp    $0x9,%al
  800d60:	74 04                	je     800d66 <strtol+0x1a>
  800d62:	3c 20                	cmp    $0x20,%al
  800d64:	75 0e                	jne    800d74 <strtol+0x28>
		s++;
  800d66:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d69:	0f b6 02             	movzbl (%edx),%eax
  800d6c:	3c 09                	cmp    $0x9,%al
  800d6e:	74 f6                	je     800d66 <strtol+0x1a>
  800d70:	3c 20                	cmp    $0x20,%al
  800d72:	74 f2                	je     800d66 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d74:	3c 2b                	cmp    $0x2b,%al
  800d76:	75 0a                	jne    800d82 <strtol+0x36>
		s++;
  800d78:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d7b:	bf 00 00 00 00       	mov    $0x0,%edi
  800d80:	eb 10                	jmp    800d92 <strtol+0x46>
  800d82:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d87:	3c 2d                	cmp    $0x2d,%al
  800d89:	75 07                	jne    800d92 <strtol+0x46>
		s++, neg = 1;
  800d8b:	83 c2 01             	add    $0x1,%edx
  800d8e:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d92:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d98:	75 15                	jne    800daf <strtol+0x63>
  800d9a:	80 3a 30             	cmpb   $0x30,(%edx)
  800d9d:	75 10                	jne    800daf <strtol+0x63>
  800d9f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800da3:	75 0a                	jne    800daf <strtol+0x63>
		s += 2, base = 16;
  800da5:	83 c2 02             	add    $0x2,%edx
  800da8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800dad:	eb 10                	jmp    800dbf <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800daf:	85 db                	test   %ebx,%ebx
  800db1:	75 0c                	jne    800dbf <strtol+0x73>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800db3:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800db5:	80 3a 30             	cmpb   $0x30,(%edx)
  800db8:	75 05                	jne    800dbf <strtol+0x73>
		s++, base = 8;
  800dba:	83 c2 01             	add    $0x1,%edx
  800dbd:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800dbf:	b8 00 00 00 00       	mov    $0x0,%eax
  800dc4:	89 5d f0             	mov    %ebx,-0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800dc7:	0f b6 0a             	movzbl (%edx),%ecx
  800dca:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800dcd:	89 f3                	mov    %esi,%ebx
  800dcf:	80 fb 09             	cmp    $0x9,%bl
  800dd2:	77 08                	ja     800ddc <strtol+0x90>
			dig = *s - '0';
  800dd4:	0f be c9             	movsbl %cl,%ecx
  800dd7:	83 e9 30             	sub    $0x30,%ecx
  800dda:	eb 22                	jmp    800dfe <strtol+0xb2>
		else if (*s >= 'a' && *s <= 'z')
  800ddc:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800ddf:	89 f3                	mov    %esi,%ebx
  800de1:	80 fb 19             	cmp    $0x19,%bl
  800de4:	77 08                	ja     800dee <strtol+0xa2>
			dig = *s - 'a' + 10;
  800de6:	0f be c9             	movsbl %cl,%ecx
  800de9:	83 e9 57             	sub    $0x57,%ecx
  800dec:	eb 10                	jmp    800dfe <strtol+0xb2>
		else if (*s >= 'A' && *s <= 'Z')
  800dee:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800df1:	89 f3                	mov    %esi,%ebx
  800df3:	80 fb 19             	cmp    $0x19,%bl
  800df6:	77 16                	ja     800e0e <strtol+0xc2>
			dig = *s - 'A' + 10;
  800df8:	0f be c9             	movsbl %cl,%ecx
  800dfb:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800dfe:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800e01:	7d 0f                	jge    800e12 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800e03:	83 c2 01             	add    $0x1,%edx
  800e06:	0f af 45 f0          	imul   -0x10(%ebp),%eax
  800e0a:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800e0c:	eb b9                	jmp    800dc7 <strtol+0x7b>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800e0e:	89 c1                	mov    %eax,%ecx
  800e10:	eb 02                	jmp    800e14 <strtol+0xc8>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800e12:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800e14:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e18:	74 05                	je     800e1f <strtol+0xd3>
		*endptr = (char *) s;
  800e1a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e1d:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800e1f:	89 ca                	mov    %ecx,%edx
  800e21:	f7 da                	neg    %edx
  800e23:	85 ff                	test   %edi,%edi
  800e25:	0f 45 c2             	cmovne %edx,%eax
}
  800e28:	83 c4 04             	add    $0x4,%esp
  800e2b:	5b                   	pop    %ebx
  800e2c:	5e                   	pop    %esi
  800e2d:	5f                   	pop    %edi
  800e2e:	5d                   	pop    %ebp
  800e2f:	c3                   	ret    

00800e30 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e30:	55                   	push   %ebp
  800e31:	89 e5                	mov    %esp,%ebp
  800e33:	83 ec 0c             	sub    $0xc,%esp
  800e36:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e39:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e3c:	89 7d fc             	mov    %edi,-0x4(%ebp)
static inline uint32_t

get_cpu_features(void)
{
	uint32_t feature;
	__asm __volatile(" movl $1, %%eax\n\t"
  800e3f:	b8 01 00 00 00       	mov    $0x1,%eax
  800e44:	0f a2                	cpuid  
  800e46:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e48:	b8 00 00 00 00       	mov    $0x0,%eax
  800e4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e50:	8b 55 08             	mov    0x8(%ebp),%edx
  800e53:	89 c3                	mov    %eax,%ebx
  800e55:	89 c7                	mov    %eax,%edi
  800e57:	89 c6                	mov    %eax,%esi
  800e59:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e5b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e5e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e61:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e64:	89 ec                	mov    %ebp,%esp
  800e66:	5d                   	pop    %ebp
  800e67:	c3                   	ret    

00800e68 <sys_cgetc>:

int
sys_cgetc(void)
{
  800e68:	55                   	push   %ebp
  800e69:	89 e5                	mov    %esp,%ebp
  800e6b:	83 ec 0c             	sub    $0xc,%esp
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
  800e80:	ba 00 00 00 00       	mov    $0x0,%edx
  800e85:	b8 01 00 00 00       	mov    $0x1,%eax
  800e8a:	89 d1                	mov    %edx,%ecx
  800e8c:	89 d3                	mov    %edx,%ebx
  800e8e:	89 d7                	mov    %edx,%edi
  800e90:	89 d6                	mov    %edx,%esi
  800e92:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e94:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e97:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e9a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e9d:	89 ec                	mov    %ebp,%esp
  800e9f:	5d                   	pop    %ebp
  800ea0:	c3                   	ret    

00800ea1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ea1:	55                   	push   %ebp
  800ea2:	89 e5                	mov    %esp,%ebp
  800ea4:	83 ec 38             	sub    $0x38,%esp
  800ea7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800eaa:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ead:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800eb0:	b8 01 00 00 00       	mov    $0x1,%eax
  800eb5:	0f a2                	cpuid  
  800eb7:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ebe:	b8 03 00 00 00       	mov    $0x3,%eax
  800ec3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec6:	89 cb                	mov    %ecx,%ebx
  800ec8:	89 cf                	mov    %ecx,%edi
  800eca:	89 ce                	mov    %ecx,%esi
  800ecc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ece:	85 c0                	test   %eax,%eax
  800ed0:	7e 28                	jle    800efa <sys_env_destroy+0x59>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ed6:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800edd:	00 
  800ede:	c7 44 24 08 9f 22 80 	movl   $0x80229f,0x8(%esp)
  800ee5:	00 
  800ee6:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800eed:	00 
  800eee:	c7 04 24 bc 22 80 00 	movl   $0x8022bc,(%esp)
  800ef5:	e8 b6 f3 ff ff       	call   8002b0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800efa:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800efd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f00:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f03:	89 ec                	mov    %ebp,%esp
  800f05:	5d                   	pop    %ebp
  800f06:	c3                   	ret    

00800f07 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f07:	55                   	push   %ebp
  800f08:	89 e5                	mov    %esp,%ebp
  800f0a:	83 ec 0c             	sub    $0xc,%esp
  800f0d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f10:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f13:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800f16:	b8 01 00 00 00       	mov    $0x1,%eax
  800f1b:	0f a2                	cpuid  
  800f1d:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f1f:	ba 00 00 00 00       	mov    $0x0,%edx
  800f24:	b8 02 00 00 00       	mov    $0x2,%eax
  800f29:	89 d1                	mov    %edx,%ecx
  800f2b:	89 d3                	mov    %edx,%ebx
  800f2d:	89 d7                	mov    %edx,%edi
  800f2f:	89 d6                	mov    %edx,%esi
  800f31:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f33:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f36:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f39:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f3c:	89 ec                	mov    %ebp,%esp
  800f3e:	5d                   	pop    %ebp
  800f3f:	c3                   	ret    

00800f40 <sys_yield>:

void
sys_yield(void)
{
  800f40:	55                   	push   %ebp
  800f41:	89 e5                	mov    %esp,%ebp
  800f43:	83 ec 0c             	sub    $0xc,%esp
  800f46:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f49:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f4c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800f4f:	b8 01 00 00 00       	mov    $0x1,%eax
  800f54:	0f a2                	cpuid  
  800f56:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f58:	ba 00 00 00 00       	mov    $0x0,%edx
  800f5d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f62:	89 d1                	mov    %edx,%ecx
  800f64:	89 d3                	mov    %edx,%ebx
  800f66:	89 d7                	mov    %edx,%edi
  800f68:	89 d6                	mov    %edx,%esi
  800f6a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f6c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f6f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f72:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f75:	89 ec                	mov    %ebp,%esp
  800f77:	5d                   	pop    %ebp
  800f78:	c3                   	ret    

00800f79 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f79:	55                   	push   %ebp
  800f7a:	89 e5                	mov    %esp,%ebp
  800f7c:	83 ec 38             	sub    $0x38,%esp
  800f7f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f82:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f85:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800f88:	b8 01 00 00 00       	mov    $0x1,%eax
  800f8d:	0f a2                	cpuid  
  800f8f:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f91:	be 00 00 00 00       	mov    $0x0,%esi
  800f96:	b8 04 00 00 00       	mov    $0x4,%eax
  800f9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fa4:	89 f7                	mov    %esi,%edi
  800fa6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fa8:	85 c0                	test   %eax,%eax
  800faa:	7e 28                	jle    800fd4 <sys_page_alloc+0x5b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fac:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fb0:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800fb7:	00 
  800fb8:	c7 44 24 08 9f 22 80 	movl   $0x80229f,0x8(%esp)
  800fbf:	00 
  800fc0:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800fc7:	00 
  800fc8:	c7 04 24 bc 22 80 00 	movl   $0x8022bc,(%esp)
  800fcf:	e8 dc f2 ff ff       	call   8002b0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800fd4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fd7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fda:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fdd:	89 ec                	mov    %ebp,%esp
  800fdf:	5d                   	pop    %ebp
  800fe0:	c3                   	ret    

00800fe1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800ff9:	b8 05 00 00 00       	mov    $0x5,%eax
  800ffe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801001:	8b 55 08             	mov    0x8(%ebp),%edx
  801004:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801007:	8b 7d 14             	mov    0x14(%ebp),%edi
  80100a:	8b 75 18             	mov    0x18(%ebp),%esi
  80100d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80100f:	85 c0                	test   %eax,%eax
  801011:	7e 28                	jle    80103b <sys_page_map+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801013:	89 44 24 10          	mov    %eax,0x10(%esp)
  801017:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80101e:	00 
  80101f:	c7 44 24 08 9f 22 80 	movl   $0x80229f,0x8(%esp)
  801026:	00 
  801027:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  80102e:	00 
  80102f:	c7 04 24 bc 22 80 00 	movl   $0x8022bc,(%esp)
  801036:	e8 75 f2 ff ff       	call   8002b0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80103b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80103e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801041:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801044:	89 ec                	mov    %ebp,%esp
  801046:	5d                   	pop    %ebp
  801047:	c3                   	ret    

00801048 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801048:	55                   	push   %ebp
  801049:	89 e5                	mov    %esp,%ebp
  80104b:	83 ec 38             	sub    $0x38,%esp
  80104e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801051:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801054:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801057:	b8 01 00 00 00       	mov    $0x1,%eax
  80105c:	0f a2                	cpuid  
  80105e:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801060:	bb 00 00 00 00       	mov    $0x0,%ebx
  801065:	b8 06 00 00 00       	mov    $0x6,%eax
  80106a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80106d:	8b 55 08             	mov    0x8(%ebp),%edx
  801070:	89 df                	mov    %ebx,%edi
  801072:	89 de                	mov    %ebx,%esi
  801074:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801076:	85 c0                	test   %eax,%eax
  801078:	7e 28                	jle    8010a2 <sys_page_unmap+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80107a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80107e:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801085:	00 
  801086:	c7 44 24 08 9f 22 80 	movl   $0x80229f,0x8(%esp)
  80108d:	00 
  80108e:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  801095:	00 
  801096:	c7 04 24 bc 22 80 00 	movl   $0x8022bc,(%esp)
  80109d:	e8 0e f2 ff ff       	call   8002b0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8010a2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010a5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010a8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010ab:	89 ec                	mov    %ebp,%esp
  8010ad:	5d                   	pop    %ebp
  8010ae:	c3                   	ret    

008010af <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8010af:	55                   	push   %ebp
  8010b0:	89 e5                	mov    %esp,%ebp
  8010b2:	83 ec 38             	sub    $0x38,%esp
  8010b5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010b8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010bb:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8010be:	b8 01 00 00 00       	mov    $0x1,%eax
  8010c3:	0f a2                	cpuid  
  8010c5:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010c7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010cc:	b8 08 00 00 00       	mov    $0x8,%eax
  8010d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8010d7:	89 df                	mov    %ebx,%edi
  8010d9:	89 de                	mov    %ebx,%esi
  8010db:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010dd:	85 c0                	test   %eax,%eax
  8010df:	7e 28                	jle    801109 <sys_env_set_status+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010e1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010e5:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8010ec:	00 
  8010ed:	c7 44 24 08 9f 22 80 	movl   $0x80229f,0x8(%esp)
  8010f4:	00 
  8010f5:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  8010fc:	00 
  8010fd:	c7 04 24 bc 22 80 00 	movl   $0x8022bc,(%esp)
  801104:	e8 a7 f1 ff ff       	call   8002b0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801109:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80110c:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80110f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801112:	89 ec                	mov    %ebp,%esp
  801114:	5d                   	pop    %ebp
  801115:	c3                   	ret    

00801116 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801116:	55                   	push   %ebp
  801117:	89 e5                	mov    %esp,%ebp
  801119:	83 ec 38             	sub    $0x38,%esp
  80111c:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80111f:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801122:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801125:	b8 01 00 00 00       	mov    $0x1,%eax
  80112a:	0f a2                	cpuid  
  80112c:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80112e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801133:	b8 09 00 00 00       	mov    $0x9,%eax
  801138:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80113b:	8b 55 08             	mov    0x8(%ebp),%edx
  80113e:	89 df                	mov    %ebx,%edi
  801140:	89 de                	mov    %ebx,%esi
  801142:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801144:	85 c0                	test   %eax,%eax
  801146:	7e 28                	jle    801170 <sys_env_set_trapframe+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801148:	89 44 24 10          	mov    %eax,0x10(%esp)
  80114c:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801153:	00 
  801154:	c7 44 24 08 9f 22 80 	movl   $0x80229f,0x8(%esp)
  80115b:	00 
  80115c:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  801163:	00 
  801164:	c7 04 24 bc 22 80 00 	movl   $0x8022bc,(%esp)
  80116b:	e8 40 f1 ff ff       	call   8002b0 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801170:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801173:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801176:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801179:	89 ec                	mov    %ebp,%esp
  80117b:	5d                   	pop    %ebp
  80117c:	c3                   	ret    

0080117d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80117d:	55                   	push   %ebp
  80117e:	89 e5                	mov    %esp,%ebp
  801180:	83 ec 38             	sub    $0x38,%esp
  801183:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801186:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801189:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80118c:	b8 01 00 00 00       	mov    $0x1,%eax
  801191:	0f a2                	cpuid  
  801193:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801195:	bb 00 00 00 00       	mov    $0x0,%ebx
  80119a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80119f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8011a5:	89 df                	mov    %ebx,%edi
  8011a7:	89 de                	mov    %ebx,%esi
  8011a9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011ab:	85 c0                	test   %eax,%eax
  8011ad:	7e 28                	jle    8011d7 <sys_env_set_pgfault_upcall+0x5a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011af:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011b3:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8011ba:	00 
  8011bb:	c7 44 24 08 9f 22 80 	movl   $0x80229f,0x8(%esp)
  8011c2:	00 
  8011c3:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  8011ca:	00 
  8011cb:	c7 04 24 bc 22 80 00 	movl   $0x8022bc,(%esp)
  8011d2:	e8 d9 f0 ff ff       	call   8002b0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8011d7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8011da:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8011dd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011e0:	89 ec                	mov    %ebp,%esp
  8011e2:	5d                   	pop    %ebp
  8011e3:	c3                   	ret    

008011e4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8011e4:	55                   	push   %ebp
  8011e5:	89 e5                	mov    %esp,%ebp
  8011e7:	83 ec 0c             	sub    $0xc,%esp
  8011ea:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8011ed:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8011f0:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8011f3:	b8 01 00 00 00       	mov    $0x1,%eax
  8011f8:	0f a2                	cpuid  
  8011fa:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011fc:	be 00 00 00 00       	mov    $0x0,%esi
  801201:	b8 0c 00 00 00       	mov    $0xc,%eax
  801206:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801209:	8b 55 08             	mov    0x8(%ebp),%edx
  80120c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80120f:	8b 7d 14             	mov    0x14(%ebp),%edi
  801212:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801214:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801217:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80121a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80121d:	89 ec                	mov    %ebp,%esp
  80121f:	5d                   	pop    %ebp
  801220:	c3                   	ret    

00801221 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801221:	55                   	push   %ebp
  801222:	89 e5                	mov    %esp,%ebp
  801224:	83 ec 38             	sub    $0x38,%esp
  801227:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80122a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80122d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801230:	b8 01 00 00 00       	mov    $0x1,%eax
  801235:	0f a2                	cpuid  
  801237:	89 d6                	mov    %edx,%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801239:	b9 00 00 00 00       	mov    $0x0,%ecx
  80123e:	b8 0d 00 00 00       	mov    $0xd,%eax
  801243:	8b 55 08             	mov    0x8(%ebp),%edx
  801246:	89 cb                	mov    %ecx,%ebx
  801248:	89 cf                	mov    %ecx,%edi
  80124a:	89 ce                	mov    %ecx,%esi
  80124c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80124e:	85 c0                	test   %eax,%eax
  801250:	7e 28                	jle    80127a <sys_ipc_recv+0x59>
		panic("syscall %d returned %d (> 0)", num, ret);
  801252:	89 44 24 10          	mov    %eax,0x10(%esp)
  801256:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  80125d:	00 
  80125e:	c7 44 24 08 9f 22 80 	movl   $0x80229f,0x8(%esp)
  801265:	00 
  801266:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  80126d:	00 
  80126e:	c7 04 24 bc 22 80 00 	movl   $0x8022bc,(%esp)
  801275:	e8 36 f0 ff ff       	call   8002b0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80127a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80127d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801280:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801283:	89 ec                	mov    %ebp,%esp
  801285:	5d                   	pop    %ebp
  801286:	c3                   	ret    
  801287:	66 90                	xchg   %ax,%ax
  801289:	66 90                	xchg   %ax,%ax
  80128b:	66 90                	xchg   %ax,%ax
  80128d:	66 90                	xchg   %ax,%ax
  80128f:	90                   	nop

00801290 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801290:	55                   	push   %ebp
  801291:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801293:	8b 45 08             	mov    0x8(%ebp),%eax
  801296:	05 00 00 00 30       	add    $0x30000000,%eax
  80129b:	c1 e8 0c             	shr    $0xc,%eax
}
  80129e:	5d                   	pop    %ebp
  80129f:	c3                   	ret    

008012a0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012a0:	55                   	push   %ebp
  8012a1:	89 e5                	mov    %esp,%ebp
  8012a3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8012a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a9:	89 04 24             	mov    %eax,(%esp)
  8012ac:	e8 df ff ff ff       	call   801290 <fd2num>
  8012b1:	c1 e0 0c             	shl    $0xc,%eax
  8012b4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012b9:	c9                   	leave  
  8012ba:	c3                   	ret    

008012bb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012bb:	55                   	push   %ebp
  8012bc:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8012be:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8012c3:	a8 01                	test   $0x1,%al
  8012c5:	74 34                	je     8012fb <fd_alloc+0x40>
  8012c7:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8012cc:	a8 01                	test   $0x1,%al
  8012ce:	74 32                	je     801302 <fd_alloc+0x47>
  8012d0:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8012d5:	89 c1                	mov    %eax,%ecx
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8012d7:	89 c2                	mov    %eax,%edx
  8012d9:	c1 ea 16             	shr    $0x16,%edx
  8012dc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012e3:	f6 c2 01             	test   $0x1,%dl
  8012e6:	74 1f                	je     801307 <fd_alloc+0x4c>
  8012e8:	89 c2                	mov    %eax,%edx
  8012ea:	c1 ea 0c             	shr    $0xc,%edx
  8012ed:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012f4:	f6 c2 01             	test   $0x1,%dl
  8012f7:	75 1a                	jne    801313 <fd_alloc+0x58>
  8012f9:	eb 0c                	jmp    801307 <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8012fb:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801300:	eb 05                	jmp    801307 <fd_alloc+0x4c>
  801302:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  801307:	8b 45 08             	mov    0x8(%ebp),%eax
  80130a:	89 08                	mov    %ecx,(%eax)
			return 0;
  80130c:	b8 00 00 00 00       	mov    $0x0,%eax
  801311:	eb 1a                	jmp    80132d <fd_alloc+0x72>
  801313:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801318:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80131d:	75 b6                	jne    8012d5 <fd_alloc+0x1a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80131f:	8b 45 08             	mov    0x8(%ebp),%eax
  801322:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801328:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80132d:	5d                   	pop    %ebp
  80132e:	c3                   	ret    

0080132f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80132f:	55                   	push   %ebp
  801330:	89 e5                	mov    %esp,%ebp
  801332:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801335:	83 f8 1f             	cmp    $0x1f,%eax
  801338:	77 36                	ja     801370 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80133a:	c1 e0 0c             	shl    $0xc,%eax
  80133d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801342:	89 c2                	mov    %eax,%edx
  801344:	c1 ea 16             	shr    $0x16,%edx
  801347:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80134e:	f6 c2 01             	test   $0x1,%dl
  801351:	74 24                	je     801377 <fd_lookup+0x48>
  801353:	89 c2                	mov    %eax,%edx
  801355:	c1 ea 0c             	shr    $0xc,%edx
  801358:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80135f:	f6 c2 01             	test   $0x1,%dl
  801362:	74 1a                	je     80137e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801364:	8b 55 0c             	mov    0xc(%ebp),%edx
  801367:	89 02                	mov    %eax,(%edx)
	return 0;
  801369:	b8 00 00 00 00       	mov    $0x0,%eax
  80136e:	eb 13                	jmp    801383 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  801370:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801375:	eb 0c                	jmp    801383 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
  801377:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80137c:	eb 05                	jmp    801383 <fd_lookup+0x54>
  80137e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801383:	5d                   	pop    %ebp
  801384:	c3                   	ret    

00801385 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801385:	55                   	push   %ebp
  801386:	89 e5                	mov    %esp,%ebp
  801388:	83 ec 18             	sub    $0x18,%esp
  80138b:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80138e:	39 05 04 30 80 00    	cmp    %eax,0x803004
  801394:	75 10                	jne    8013a6 <dev_lookup+0x21>
			*dev = devtab[i];
  801396:	8b 45 0c             	mov    0xc(%ebp),%eax
  801399:	c7 00 04 30 80 00    	movl   $0x803004,(%eax)
			return 0;
  80139f:	b8 00 00 00 00       	mov    $0x0,%eax
  8013a4:	eb 2b                	jmp    8013d1 <dev_lookup+0x4c>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013a6:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8013ac:	8b 52 48             	mov    0x48(%edx),%edx
  8013af:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8013b7:	c7 04 24 cc 22 80 00 	movl   $0x8022cc,(%esp)
  8013be:	e8 e8 ef ff ff       	call   8003ab <cprintf>
	*dev = 0;
  8013c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013c6:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	return -E_INVAL;
  8013cc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013d1:	c9                   	leave  
  8013d2:	c3                   	ret    

008013d3 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013d3:	55                   	push   %ebp
  8013d4:	89 e5                	mov    %esp,%ebp
  8013d6:	83 ec 38             	sub    $0x38,%esp
  8013d9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8013dc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8013df:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8013e2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013e5:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013e8:	89 3c 24             	mov    %edi,(%esp)
  8013eb:	e8 a0 fe ff ff       	call   801290 <fd2num>
  8013f0:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8013f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8013f7:	89 04 24             	mov    %eax,(%esp)
  8013fa:	e8 30 ff ff ff       	call   80132f <fd_lookup>
  8013ff:	89 c3                	mov    %eax,%ebx
  801401:	85 c0                	test   %eax,%eax
  801403:	78 05                	js     80140a <fd_close+0x37>
	    || fd != fd2)
  801405:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  801408:	74 0c                	je     801416 <fd_close+0x43>
		return (must_exist ? r : 0);
  80140a:	85 f6                	test   %esi,%esi
  80140c:	b8 00 00 00 00       	mov    $0x0,%eax
  801411:	0f 44 d8             	cmove  %eax,%ebx
  801414:	eb 3d                	jmp    801453 <fd_close+0x80>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801416:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801419:	89 44 24 04          	mov    %eax,0x4(%esp)
  80141d:	8b 07                	mov    (%edi),%eax
  80141f:	89 04 24             	mov    %eax,(%esp)
  801422:	e8 5e ff ff ff       	call   801385 <dev_lookup>
  801427:	89 c3                	mov    %eax,%ebx
  801429:	85 c0                	test   %eax,%eax
  80142b:	78 16                	js     801443 <fd_close+0x70>
		if (dev->dev_close)
  80142d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801430:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801433:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801438:	85 c0                	test   %eax,%eax
  80143a:	74 07                	je     801443 <fd_close+0x70>
			r = (*dev->dev_close)(fd);
  80143c:	89 3c 24             	mov    %edi,(%esp)
  80143f:	ff d0                	call   *%eax
  801441:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801443:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801447:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80144e:	e8 f5 fb ff ff       	call   801048 <sys_page_unmap>
	return r;
}
  801453:	89 d8                	mov    %ebx,%eax
  801455:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801458:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80145b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80145e:	89 ec                	mov    %ebp,%esp
  801460:	5d                   	pop    %ebp
  801461:	c3                   	ret    

00801462 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801462:	55                   	push   %ebp
  801463:	89 e5                	mov    %esp,%ebp
  801465:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801468:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80146b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80146f:	8b 45 08             	mov    0x8(%ebp),%eax
  801472:	89 04 24             	mov    %eax,(%esp)
  801475:	e8 b5 fe ff ff       	call   80132f <fd_lookup>
  80147a:	85 c0                	test   %eax,%eax
  80147c:	78 13                	js     801491 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80147e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801485:	00 
  801486:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801489:	89 04 24             	mov    %eax,(%esp)
  80148c:	e8 42 ff ff ff       	call   8013d3 <fd_close>
}
  801491:	c9                   	leave  
  801492:	c3                   	ret    

00801493 <close_all>:

void
close_all(void)
{
  801493:	55                   	push   %ebp
  801494:	89 e5                	mov    %esp,%ebp
  801496:	53                   	push   %ebx
  801497:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80149a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80149f:	89 1c 24             	mov    %ebx,(%esp)
  8014a2:	e8 bb ff ff ff       	call   801462 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014a7:	83 c3 01             	add    $0x1,%ebx
  8014aa:	83 fb 20             	cmp    $0x20,%ebx
  8014ad:	75 f0                	jne    80149f <close_all+0xc>
		close(i);
}
  8014af:	83 c4 14             	add    $0x14,%esp
  8014b2:	5b                   	pop    %ebx
  8014b3:	5d                   	pop    %ebp
  8014b4:	c3                   	ret    

008014b5 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014b5:	55                   	push   %ebp
  8014b6:	89 e5                	mov    %esp,%ebp
  8014b8:	83 ec 58             	sub    $0x58,%esp
  8014bb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8014be:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8014c1:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8014c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014c7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d1:	89 04 24             	mov    %eax,(%esp)
  8014d4:	e8 56 fe ff ff       	call   80132f <fd_lookup>
  8014d9:	85 c0                	test   %eax,%eax
  8014db:	0f 88 e3 00 00 00    	js     8015c4 <dup+0x10f>
		return r;
	close(newfdnum);
  8014e1:	89 1c 24             	mov    %ebx,(%esp)
  8014e4:	e8 79 ff ff ff       	call   801462 <close>

	newfd = INDEX2FD(newfdnum);
  8014e9:	89 de                	mov    %ebx,%esi
  8014eb:	c1 e6 0c             	shl    $0xc,%esi
  8014ee:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8014f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014f7:	89 04 24             	mov    %eax,(%esp)
  8014fa:	e8 a1 fd ff ff       	call   8012a0 <fd2data>
  8014ff:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801501:	89 34 24             	mov    %esi,(%esp)
  801504:	e8 97 fd ff ff       	call   8012a0 <fd2data>
  801509:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  80150c:	89 f8                	mov    %edi,%eax
  80150e:	c1 e8 16             	shr    $0x16,%eax
  801511:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801518:	a8 01                	test   $0x1,%al
  80151a:	74 46                	je     801562 <dup+0xad>
  80151c:	89 f8                	mov    %edi,%eax
  80151e:	c1 e8 0c             	shr    $0xc,%eax
  801521:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801528:	f6 c2 01             	test   $0x1,%dl
  80152b:	74 35                	je     801562 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80152d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801534:	25 07 0e 00 00       	and    $0xe07,%eax
  801539:	89 44 24 10          	mov    %eax,0x10(%esp)
  80153d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801540:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801544:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80154b:	00 
  80154c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801550:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801557:	e8 85 fa ff ff       	call   800fe1 <sys_page_map>
  80155c:	89 c7                	mov    %eax,%edi
  80155e:	85 c0                	test   %eax,%eax
  801560:	78 3b                	js     80159d <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801562:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801565:	89 c2                	mov    %eax,%edx
  801567:	c1 ea 0c             	shr    $0xc,%edx
  80156a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801571:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801577:	89 54 24 10          	mov    %edx,0x10(%esp)
  80157b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80157f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801586:	00 
  801587:	89 44 24 04          	mov    %eax,0x4(%esp)
  80158b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801592:	e8 4a fa ff ff       	call   800fe1 <sys_page_map>
  801597:	89 c7                	mov    %eax,%edi
  801599:	85 c0                	test   %eax,%eax
  80159b:	79 29                	jns    8015c6 <dup+0x111>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80159d:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015a8:	e8 9b fa ff ff       	call   801048 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015ad:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8015b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015bb:	e8 88 fa ff ff       	call   801048 <sys_page_unmap>
	return r;
  8015c0:	89 fb                	mov    %edi,%ebx
  8015c2:	eb 02                	jmp    8015c6 <dup+0x111>
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
		return r;
  8015c4:	89 c3                	mov    %eax,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8015c6:	89 d8                	mov    %ebx,%eax
  8015c8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8015cb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8015ce:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8015d1:	89 ec                	mov    %ebp,%esp
  8015d3:	5d                   	pop    %ebp
  8015d4:	c3                   	ret    

008015d5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015d5:	55                   	push   %ebp
  8015d6:	89 e5                	mov    %esp,%ebp
  8015d8:	53                   	push   %ebx
  8015d9:	83 ec 24             	sub    $0x24,%esp
  8015dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015df:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015e6:	89 1c 24             	mov    %ebx,(%esp)
  8015e9:	e8 41 fd ff ff       	call   80132f <fd_lookup>
  8015ee:	85 c0                	test   %eax,%eax
  8015f0:	78 6d                	js     80165f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015fc:	8b 00                	mov    (%eax),%eax
  8015fe:	89 04 24             	mov    %eax,(%esp)
  801601:	e8 7f fd ff ff       	call   801385 <dev_lookup>
  801606:	85 c0                	test   %eax,%eax
  801608:	78 55                	js     80165f <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80160a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80160d:	8b 50 08             	mov    0x8(%eax),%edx
  801610:	83 e2 03             	and    $0x3,%edx
  801613:	83 fa 01             	cmp    $0x1,%edx
  801616:	75 23                	jne    80163b <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801618:	a1 04 40 80 00       	mov    0x804004,%eax
  80161d:	8b 40 48             	mov    0x48(%eax),%eax
  801620:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801624:	89 44 24 04          	mov    %eax,0x4(%esp)
  801628:	c7 04 24 10 23 80 00 	movl   $0x802310,(%esp)
  80162f:	e8 77 ed ff ff       	call   8003ab <cprintf>
		return -E_INVAL;
  801634:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801639:	eb 24                	jmp    80165f <read+0x8a>
	}
	if (!dev->dev_read)
  80163b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80163e:	8b 52 08             	mov    0x8(%edx),%edx
  801641:	85 d2                	test   %edx,%edx
  801643:	74 15                	je     80165a <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801645:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801648:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80164c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80164f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801653:	89 04 24             	mov    %eax,(%esp)
  801656:	ff d2                	call   *%edx
  801658:	eb 05                	jmp    80165f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80165a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80165f:	83 c4 24             	add    $0x24,%esp
  801662:	5b                   	pop    %ebx
  801663:	5d                   	pop    %ebp
  801664:	c3                   	ret    

00801665 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801665:	55                   	push   %ebp
  801666:	89 e5                	mov    %esp,%ebp
  801668:	57                   	push   %edi
  801669:	56                   	push   %esi
  80166a:	53                   	push   %ebx
  80166b:	83 ec 1c             	sub    $0x1c,%esp
  80166e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801671:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801674:	85 f6                	test   %esi,%esi
  801676:	74 33                	je     8016ab <readn+0x46>
  801678:	b8 00 00 00 00       	mov    $0x0,%eax
  80167d:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801682:	89 f2                	mov    %esi,%edx
  801684:	29 c2                	sub    %eax,%edx
  801686:	89 54 24 08          	mov    %edx,0x8(%esp)
  80168a:	03 45 0c             	add    0xc(%ebp),%eax
  80168d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801691:	89 3c 24             	mov    %edi,(%esp)
  801694:	e8 3c ff ff ff       	call   8015d5 <read>
		if (m < 0)
  801699:	85 c0                	test   %eax,%eax
  80169b:	78 17                	js     8016b4 <readn+0x4f>
			return m;
		if (m == 0)
  80169d:	85 c0                	test   %eax,%eax
  80169f:	74 11                	je     8016b2 <readn+0x4d>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016a1:	01 c3                	add    %eax,%ebx
  8016a3:	89 d8                	mov    %ebx,%eax
  8016a5:	39 f3                	cmp    %esi,%ebx
  8016a7:	72 d9                	jb     801682 <readn+0x1d>
  8016a9:	eb 09                	jmp    8016b4 <readn+0x4f>
  8016ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8016b0:	eb 02                	jmp    8016b4 <readn+0x4f>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8016b2:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8016b4:	83 c4 1c             	add    $0x1c,%esp
  8016b7:	5b                   	pop    %ebx
  8016b8:	5e                   	pop    %esi
  8016b9:	5f                   	pop    %edi
  8016ba:	5d                   	pop    %ebp
  8016bb:	c3                   	ret    

008016bc <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8016bc:	55                   	push   %ebp
  8016bd:	89 e5                	mov    %esp,%ebp
  8016bf:	53                   	push   %ebx
  8016c0:	83 ec 24             	sub    $0x24,%esp
  8016c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016cd:	89 1c 24             	mov    %ebx,(%esp)
  8016d0:	e8 5a fc ff ff       	call   80132f <fd_lookup>
  8016d5:	85 c0                	test   %eax,%eax
  8016d7:	78 68                	js     801741 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016e3:	8b 00                	mov    (%eax),%eax
  8016e5:	89 04 24             	mov    %eax,(%esp)
  8016e8:	e8 98 fc ff ff       	call   801385 <dev_lookup>
  8016ed:	85 c0                	test   %eax,%eax
  8016ef:	78 50                	js     801741 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016f8:	75 23                	jne    80171d <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016fa:	a1 04 40 80 00       	mov    0x804004,%eax
  8016ff:	8b 40 48             	mov    0x48(%eax),%eax
  801702:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801706:	89 44 24 04          	mov    %eax,0x4(%esp)
  80170a:	c7 04 24 2c 23 80 00 	movl   $0x80232c,(%esp)
  801711:	e8 95 ec ff ff       	call   8003ab <cprintf>
		return -E_INVAL;
  801716:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80171b:	eb 24                	jmp    801741 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80171d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801720:	8b 52 0c             	mov    0xc(%edx),%edx
  801723:	85 d2                	test   %edx,%edx
  801725:	74 15                	je     80173c <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801727:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80172a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80172e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801731:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801735:	89 04 24             	mov    %eax,(%esp)
  801738:	ff d2                	call   *%edx
  80173a:	eb 05                	jmp    801741 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80173c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801741:	83 c4 24             	add    $0x24,%esp
  801744:	5b                   	pop    %ebx
  801745:	5d                   	pop    %ebp
  801746:	c3                   	ret    

00801747 <seek>:

int
seek(int fdnum, off_t offset)
{
  801747:	55                   	push   %ebp
  801748:	89 e5                	mov    %esp,%ebp
  80174a:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80174d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801750:	89 44 24 04          	mov    %eax,0x4(%esp)
  801754:	8b 45 08             	mov    0x8(%ebp),%eax
  801757:	89 04 24             	mov    %eax,(%esp)
  80175a:	e8 d0 fb ff ff       	call   80132f <fd_lookup>
  80175f:	85 c0                	test   %eax,%eax
  801761:	78 0e                	js     801771 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801763:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801766:	8b 55 0c             	mov    0xc(%ebp),%edx
  801769:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80176c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801771:	c9                   	leave  
  801772:	c3                   	ret    

00801773 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801773:	55                   	push   %ebp
  801774:	89 e5                	mov    %esp,%ebp
  801776:	53                   	push   %ebx
  801777:	83 ec 24             	sub    $0x24,%esp
  80177a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80177d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801780:	89 44 24 04          	mov    %eax,0x4(%esp)
  801784:	89 1c 24             	mov    %ebx,(%esp)
  801787:	e8 a3 fb ff ff       	call   80132f <fd_lookup>
  80178c:	85 c0                	test   %eax,%eax
  80178e:	78 61                	js     8017f1 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801790:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801793:	89 44 24 04          	mov    %eax,0x4(%esp)
  801797:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80179a:	8b 00                	mov    (%eax),%eax
  80179c:	89 04 24             	mov    %eax,(%esp)
  80179f:	e8 e1 fb ff ff       	call   801385 <dev_lookup>
  8017a4:	85 c0                	test   %eax,%eax
  8017a6:	78 49                	js     8017f1 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ab:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017af:	75 23                	jne    8017d4 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8017b1:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017b6:	8b 40 48             	mov    0x48(%eax),%eax
  8017b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017c1:	c7 04 24 ec 22 80 00 	movl   $0x8022ec,(%esp)
  8017c8:	e8 de eb ff ff       	call   8003ab <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8017cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017d2:	eb 1d                	jmp    8017f1 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8017d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017d7:	8b 52 18             	mov    0x18(%edx),%edx
  8017da:	85 d2                	test   %edx,%edx
  8017dc:	74 0e                	je     8017ec <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017e1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8017e5:	89 04 24             	mov    %eax,(%esp)
  8017e8:	ff d2                	call   *%edx
  8017ea:	eb 05                	jmp    8017f1 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8017ec:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8017f1:	83 c4 24             	add    $0x24,%esp
  8017f4:	5b                   	pop    %ebx
  8017f5:	5d                   	pop    %ebp
  8017f6:	c3                   	ret    

008017f7 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017f7:	55                   	push   %ebp
  8017f8:	89 e5                	mov    %esp,%ebp
  8017fa:	53                   	push   %ebx
  8017fb:	83 ec 24             	sub    $0x24,%esp
  8017fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801801:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801804:	89 44 24 04          	mov    %eax,0x4(%esp)
  801808:	8b 45 08             	mov    0x8(%ebp),%eax
  80180b:	89 04 24             	mov    %eax,(%esp)
  80180e:	e8 1c fb ff ff       	call   80132f <fd_lookup>
  801813:	85 c0                	test   %eax,%eax
  801815:	78 52                	js     801869 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801817:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80181a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80181e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801821:	8b 00                	mov    (%eax),%eax
  801823:	89 04 24             	mov    %eax,(%esp)
  801826:	e8 5a fb ff ff       	call   801385 <dev_lookup>
  80182b:	85 c0                	test   %eax,%eax
  80182d:	78 3a                	js     801869 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  80182f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801832:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801836:	74 2c                	je     801864 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801838:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80183b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801842:	00 00 00 
	stat->st_isdir = 0;
  801845:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80184c:	00 00 00 
	stat->st_dev = dev;
  80184f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801855:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801859:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80185c:	89 14 24             	mov    %edx,(%esp)
  80185f:	ff 50 14             	call   *0x14(%eax)
  801862:	eb 05                	jmp    801869 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801864:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801869:	83 c4 24             	add    $0x24,%esp
  80186c:	5b                   	pop    %ebx
  80186d:	5d                   	pop    %ebp
  80186e:	c3                   	ret    

0080186f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80186f:	55                   	push   %ebp
  801870:	89 e5                	mov    %esp,%ebp
  801872:	83 ec 18             	sub    $0x18,%esp
  801875:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801878:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80187b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801882:	00 
  801883:	8b 45 08             	mov    0x8(%ebp),%eax
  801886:	89 04 24             	mov    %eax,(%esp)
  801889:	e8 84 01 00 00       	call   801a12 <open>
  80188e:	89 c3                	mov    %eax,%ebx
  801890:	85 c0                	test   %eax,%eax
  801892:	78 1b                	js     8018af <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801894:	8b 45 0c             	mov    0xc(%ebp),%eax
  801897:	89 44 24 04          	mov    %eax,0x4(%esp)
  80189b:	89 1c 24             	mov    %ebx,(%esp)
  80189e:	e8 54 ff ff ff       	call   8017f7 <fstat>
  8018a3:	89 c6                	mov    %eax,%esi
	close(fd);
  8018a5:	89 1c 24             	mov    %ebx,(%esp)
  8018a8:	e8 b5 fb ff ff       	call   801462 <close>
	return r;
  8018ad:	89 f3                	mov    %esi,%ebx
}
  8018af:	89 d8                	mov    %ebx,%eax
  8018b1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8018b4:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8018b7:	89 ec                	mov    %ebp,%esp
  8018b9:	5d                   	pop    %ebp
  8018ba:	c3                   	ret    
  8018bb:	90                   	nop

008018bc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8018bc:	55                   	push   %ebp
  8018bd:	89 e5                	mov    %esp,%ebp
  8018bf:	83 ec 18             	sub    $0x18,%esp
  8018c2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8018c5:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8018c8:	89 c6                	mov    %eax,%esi
  8018ca:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8018cc:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8018d3:	75 11                	jne    8018e6 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018d5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8018dc:	e8 72 02 00 00       	call   801b53 <ipc_find_env>
  8018e1:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018e6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8018ed:	00 
  8018ee:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8018f5:	00 
  8018f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018fa:	a1 00 40 80 00       	mov    0x804000,%eax
  8018ff:	89 04 24             	mov    %eax,(%esp)
  801902:	e8 e1 01 00 00       	call   801ae8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801907:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80190e:	00 
  80190f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801913:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80191a:	e8 71 01 00 00       	call   801a90 <ipc_recv>
}
  80191f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801922:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801925:	89 ec                	mov    %ebp,%esp
  801927:	5d                   	pop    %ebp
  801928:	c3                   	ret    

00801929 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801929:	55                   	push   %ebp
  80192a:	89 e5                	mov    %esp,%ebp
  80192c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80192f:	8b 45 08             	mov    0x8(%ebp),%eax
  801932:	8b 40 0c             	mov    0xc(%eax),%eax
  801935:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80193a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80193d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801942:	ba 00 00 00 00       	mov    $0x0,%edx
  801947:	b8 02 00 00 00       	mov    $0x2,%eax
  80194c:	e8 6b ff ff ff       	call   8018bc <fsipc>
}
  801951:	c9                   	leave  
  801952:	c3                   	ret    

00801953 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801953:	55                   	push   %ebp
  801954:	89 e5                	mov    %esp,%ebp
  801956:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801959:	8b 45 08             	mov    0x8(%ebp),%eax
  80195c:	8b 40 0c             	mov    0xc(%eax),%eax
  80195f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801964:	ba 00 00 00 00       	mov    $0x0,%edx
  801969:	b8 06 00 00 00       	mov    $0x6,%eax
  80196e:	e8 49 ff ff ff       	call   8018bc <fsipc>
}
  801973:	c9                   	leave  
  801974:	c3                   	ret    

00801975 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801975:	55                   	push   %ebp
  801976:	89 e5                	mov    %esp,%ebp
  801978:	53                   	push   %ebx
  801979:	83 ec 14             	sub    $0x14,%esp
  80197c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80197f:	8b 45 08             	mov    0x8(%ebp),%eax
  801982:	8b 40 0c             	mov    0xc(%eax),%eax
  801985:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80198a:	ba 00 00 00 00       	mov    $0x0,%edx
  80198f:	b8 05 00 00 00       	mov    $0x5,%eax
  801994:	e8 23 ff ff ff       	call   8018bc <fsipc>
  801999:	85 c0                	test   %eax,%eax
  80199b:	78 2b                	js     8019c8 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80199d:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8019a4:	00 
  8019a5:	89 1c 24             	mov    %ebx,(%esp)
  8019a8:	e8 7e f0 ff ff       	call   800a2b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8019ad:	a1 80 50 80 00       	mov    0x805080,%eax
  8019b2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8019b8:	a1 84 50 80 00       	mov    0x805084,%eax
  8019bd:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8019c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019c8:	83 c4 14             	add    $0x14,%esp
  8019cb:	5b                   	pop    %ebx
  8019cc:	5d                   	pop    %ebp
  8019cd:	c3                   	ret    

008019ce <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8019ce:	55                   	push   %ebp
  8019cf:	89 e5                	mov    %esp,%ebp
  8019d1:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8019d4:	c7 44 24 08 49 23 80 	movl   $0x802349,0x8(%esp)
  8019db:	00 
  8019dc:	c7 44 24 04 77 00 00 	movl   $0x77,0x4(%esp)
  8019e3:	00 
  8019e4:	c7 04 24 67 23 80 00 	movl   $0x802367,(%esp)
  8019eb:	e8 c0 e8 ff ff       	call   8002b0 <_panic>

008019f0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019f0:	55                   	push   %ebp
  8019f1:	89 e5                	mov    %esp,%ebp
  8019f3:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_READ request to the file system server after
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
	panic("devfile_read not implemented");
  8019f6:	c7 44 24 08 72 23 80 	movl   $0x802372,0x8(%esp)
  8019fd:	00 
  8019fe:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
  801a05:	00 
  801a06:	c7 04 24 67 23 80 00 	movl   $0x802367,(%esp)
  801a0d:	e8 9e e8 ff ff       	call   8002b0 <_panic>

00801a12 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a12:	55                   	push   %ebp
  801a13:	89 e5                	mov    %esp,%ebp
  801a15:	83 ec 18             	sub    $0x18,%esp
	// Return the file descriptor index.
	// If any step after fd_alloc fails, use fd_close to free the
	// file descriptor.

	// LAB 5: Your code here.
	panic("open not implemented");
  801a18:	c7 44 24 08 8f 23 80 	movl   $0x80238f,0x8(%esp)
  801a1f:	00 
  801a20:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  801a27:	00 
  801a28:	c7 04 24 67 23 80 00 	movl   $0x802367,(%esp)
  801a2f:	e8 7c e8 ff ff       	call   8002b0 <_panic>

00801a34 <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801a34:	55                   	push   %ebp
  801a35:	89 e5                	mov    %esp,%ebp
  801a37:	53                   	push   %ebx
  801a38:	83 ec 14             	sub    $0x14,%esp
  801a3b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801a3e:	89 1c 24             	mov    %ebx,(%esp)
  801a41:	e8 8a ef ff ff       	call   8009d0 <strlen>
  801a46:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a4b:	7f 21                	jg     801a6e <remove+0x3a>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801a4d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a51:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801a58:	e8 ce ef ff ff       	call   800a2b <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801a5d:	ba 00 00 00 00       	mov    $0x0,%edx
  801a62:	b8 07 00 00 00       	mov    $0x7,%eax
  801a67:	e8 50 fe ff ff       	call   8018bc <fsipc>
  801a6c:	eb 05                	jmp    801a73 <remove+0x3f>
// Delete a file
int
remove(const char *path)
{
	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a6e:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
	strcpy(fsipcbuf.remove.req_path, path);
	return fsipc(FSREQ_REMOVE, NULL);
}
  801a73:	83 c4 14             	add    $0x14,%esp
  801a76:	5b                   	pop    %ebx
  801a77:	5d                   	pop    %ebp
  801a78:	c3                   	ret    

00801a79 <sync>:

// Synchronize disk with buffer cache
int
sync(void)
{
  801a79:	55                   	push   %ebp
  801a7a:	89 e5                	mov    %esp,%ebp
  801a7c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a7f:	ba 00 00 00 00       	mov    $0x0,%edx
  801a84:	b8 08 00 00 00       	mov    $0x8,%eax
  801a89:	e8 2e fe ff ff       	call   8018bc <fsipc>
}
  801a8e:	c9                   	leave  
  801a8f:	c3                   	ret    

00801a90 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a90:	55                   	push   %ebp
  801a91:	89 e5                	mov    %esp,%ebp
  801a93:	56                   	push   %esi
  801a94:	53                   	push   %ebx
  801a95:	83 ec 10             	sub    $0x10,%esp
  801a98:	8b 75 08             	mov    0x8(%ebp),%esi
  801a9b:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	// 	return thisenv->env_ipc_value;
	// }
	int r;
	if(pg == NULL)
		pg = (void *)~0x0;
  801a9e:	85 db                	test   %ebx,%ebx
  801aa0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801aa5:	0f 44 d8             	cmove  %eax,%ebx
	//else
	if((r = sys_ipc_recv(pg)) < 0)
  801aa8:	89 1c 24             	mov    %ebx,(%esp)
  801aab:	e8 71 f7 ff ff       	call   801221 <sys_ipc_recv>
  801ab0:	85 c0                	test   %eax,%eax
  801ab2:	78 2d                	js     801ae1 <ipc_recv+0x51>
		return r;
	//volatile struct Env *curenv = (struct Env*)envs+ENVX(sys_getenvid());

	if(from_env_store)
  801ab4:	85 f6                	test   %esi,%esi
  801ab6:	74 0a                	je     801ac2 <ipc_recv+0x32>
		*from_env_store = thisenv -> env_ipc_from;
  801ab8:	a1 04 40 80 00       	mov    0x804004,%eax
  801abd:	8b 40 74             	mov    0x74(%eax),%eax
  801ac0:	89 06                	mov    %eax,(%esi)
	if(pg && perm_store)
  801ac2:	85 db                	test   %ebx,%ebx
  801ac4:	74 13                	je     801ad9 <ipc_recv+0x49>
  801ac6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801aca:	74 0d                	je     801ad9 <ipc_recv+0x49>
		*perm_store = thisenv -> env_ipc_perm;
  801acc:	a1 04 40 80 00       	mov    0x804004,%eax
  801ad1:	8b 40 78             	mov    0x78(%eax),%eax
  801ad4:	8b 55 10             	mov    0x10(%ebp),%edx
  801ad7:	89 02                	mov    %eax,(%edx)
	else if(perm_store)
		perm_store = (int *)0;
	return thisenv->env_ipc_value;
  801ad9:	a1 04 40 80 00       	mov    0x804004,%eax
  801ade:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  801ae1:	83 c4 10             	add    $0x10,%esp
  801ae4:	5b                   	pop    %ebx
  801ae5:	5e                   	pop    %esi
  801ae6:	5d                   	pop    %ebp
  801ae7:	c3                   	ret    

00801ae8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ae8:	55                   	push   %ebp
  801ae9:	89 e5                	mov    %esp,%ebp
  801aeb:	57                   	push   %edi
  801aec:	56                   	push   %esi
  801aed:	53                   	push   %ebx
  801aee:	83 ec 1c             	sub    $0x1c,%esp
  801af1:	8b 7d 08             	mov    0x8(%ebp),%edi
  801af4:	8b 75 0c             	mov    0xc(%ebp),%esi
  801af7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

	if(pg == NULL)
  801afa:	85 db                	test   %ebx,%ebx
		pg = (void *)~0x0;
  801afc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801b01:	0f 44 d8             	cmove  %eax,%ebx
  801b04:	eb 2a                	jmp    801b30 <ipc_send+0x48>
	while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0){
		if(r != -E_IPC_NOT_RECV)
  801b06:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b09:	74 20                	je     801b2b <ipc_send+0x43>
            panic("Send message error %e\n",r);
  801b0b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b0f:	c7 44 24 08 a4 23 80 	movl   $0x8023a4,0x8(%esp)
  801b16:	00 
  801b17:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  801b1e:	00 
  801b1f:	c7 04 24 bb 23 80 00 	movl   $0x8023bb,(%esp)
  801b26:	e8 85 e7 ff ff       	call   8002b0 <_panic>
		sys_yield();
  801b2b:	e8 10 f4 ff ff       	call   800f40 <sys_yield>
	// LAB 4: Your code here.
	int r;

	if(pg == NULL)
		pg = (void *)~0x0;
	while((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0){
  801b30:	8b 45 14             	mov    0x14(%ebp),%eax
  801b33:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b37:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b3b:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b3f:	89 3c 24             	mov    %edi,(%esp)
  801b42:	e8 9d f6 ff ff       	call   8011e4 <sys_ipc_try_send>
  801b47:	85 c0                	test   %eax,%eax
  801b49:	78 bb                	js     801b06 <ipc_send+0x1e>
            panic("Send message error %e\n",r);
		sys_yield();
	}

	//panic("ipc_send not implemented");
}
  801b4b:	83 c4 1c             	add    $0x1c,%esp
  801b4e:	5b                   	pop    %ebx
  801b4f:	5e                   	pop    %esi
  801b50:	5f                   	pop    %edi
  801b51:	5d                   	pop    %ebp
  801b52:	c3                   	ret    

00801b53 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b53:	55                   	push   %ebp
  801b54:	89 e5                	mov    %esp,%ebp
  801b56:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801b59:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801b5e:	39 c8                	cmp    %ecx,%eax
  801b60:	74 17                	je     801b79 <ipc_find_env+0x26>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b62:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801b67:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b6a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b70:	8b 52 50             	mov    0x50(%edx),%edx
  801b73:	39 ca                	cmp    %ecx,%edx
  801b75:	75 14                	jne    801b8b <ipc_find_env+0x38>
  801b77:	eb 05                	jmp    801b7e <ipc_find_env+0x2b>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b79:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801b7e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b81:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801b86:	8b 40 40             	mov    0x40(%eax),%eax
  801b89:	eb 0e                	jmp    801b99 <ipc_find_env+0x46>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b8b:	83 c0 01             	add    $0x1,%eax
  801b8e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b93:	75 d2                	jne    801b67 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b95:	66 b8 00 00          	mov    $0x0,%ax
}
  801b99:	5d                   	pop    %ebp
  801b9a:	c3                   	ret    
  801b9b:	66 90                	xchg   %ax,%ax
  801b9d:	66 90                	xchg   %ax,%ax
  801b9f:	90                   	nop

00801ba0 <__udivdi3>:
  801ba0:	83 ec 1c             	sub    $0x1c,%esp
  801ba3:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801ba7:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801bab:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801baf:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801bb3:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801bb7:	8b 6c 24 24          	mov    0x24(%esp),%ebp
  801bbb:	85 c0                	test   %eax,%eax
  801bbd:	89 74 24 10          	mov    %esi,0x10(%esp)
  801bc1:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801bc5:	89 ea                	mov    %ebp,%edx
  801bc7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801bcb:	75 33                	jne    801c00 <__udivdi3+0x60>
  801bcd:	39 e9                	cmp    %ebp,%ecx
  801bcf:	77 6f                	ja     801c40 <__udivdi3+0xa0>
  801bd1:	85 c9                	test   %ecx,%ecx
  801bd3:	89 ce                	mov    %ecx,%esi
  801bd5:	75 0b                	jne    801be2 <__udivdi3+0x42>
  801bd7:	b8 01 00 00 00       	mov    $0x1,%eax
  801bdc:	31 d2                	xor    %edx,%edx
  801bde:	f7 f1                	div    %ecx
  801be0:	89 c6                	mov    %eax,%esi
  801be2:	31 d2                	xor    %edx,%edx
  801be4:	89 e8                	mov    %ebp,%eax
  801be6:	f7 f6                	div    %esi
  801be8:	89 c5                	mov    %eax,%ebp
  801bea:	89 f8                	mov    %edi,%eax
  801bec:	f7 f6                	div    %esi
  801bee:	89 ea                	mov    %ebp,%edx
  801bf0:	8b 74 24 10          	mov    0x10(%esp),%esi
  801bf4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801bf8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801bfc:	83 c4 1c             	add    $0x1c,%esp
  801bff:	c3                   	ret    
  801c00:	39 e8                	cmp    %ebp,%eax
  801c02:	77 24                	ja     801c28 <__udivdi3+0x88>
  801c04:	0f bd c8             	bsr    %eax,%ecx
  801c07:	83 f1 1f             	xor    $0x1f,%ecx
  801c0a:	89 0c 24             	mov    %ecx,(%esp)
  801c0d:	75 49                	jne    801c58 <__udivdi3+0xb8>
  801c0f:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c13:	39 74 24 04          	cmp    %esi,0x4(%esp)
  801c17:	0f 86 ab 00 00 00    	jbe    801cc8 <__udivdi3+0x128>
  801c1d:	39 e8                	cmp    %ebp,%eax
  801c1f:	0f 82 a3 00 00 00    	jb     801cc8 <__udivdi3+0x128>
  801c25:	8d 76 00             	lea    0x0(%esi),%esi
  801c28:	31 d2                	xor    %edx,%edx
  801c2a:	31 c0                	xor    %eax,%eax
  801c2c:	8b 74 24 10          	mov    0x10(%esp),%esi
  801c30:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801c34:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801c38:	83 c4 1c             	add    $0x1c,%esp
  801c3b:	c3                   	ret    
  801c3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c40:	89 f8                	mov    %edi,%eax
  801c42:	f7 f1                	div    %ecx
  801c44:	31 d2                	xor    %edx,%edx
  801c46:	8b 74 24 10          	mov    0x10(%esp),%esi
  801c4a:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801c4e:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801c52:	83 c4 1c             	add    $0x1c,%esp
  801c55:	c3                   	ret    
  801c56:	66 90                	xchg   %ax,%ax
  801c58:	0f b6 0c 24          	movzbl (%esp),%ecx
  801c5c:	89 c6                	mov    %eax,%esi
  801c5e:	b8 20 00 00 00       	mov    $0x20,%eax
  801c63:	8b 6c 24 04          	mov    0x4(%esp),%ebp
  801c67:	2b 04 24             	sub    (%esp),%eax
  801c6a:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801c6e:	d3 e6                	shl    %cl,%esi
  801c70:	89 c1                	mov    %eax,%ecx
  801c72:	d3 ed                	shr    %cl,%ebp
  801c74:	0f b6 0c 24          	movzbl (%esp),%ecx
  801c78:	09 f5                	or     %esi,%ebp
  801c7a:	8b 74 24 04          	mov    0x4(%esp),%esi
  801c7e:	d3 e6                	shl    %cl,%esi
  801c80:	89 c1                	mov    %eax,%ecx
  801c82:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c86:	89 d6                	mov    %edx,%esi
  801c88:	d3 ee                	shr    %cl,%esi
  801c8a:	0f b6 0c 24          	movzbl (%esp),%ecx
  801c8e:	d3 e2                	shl    %cl,%edx
  801c90:	89 c1                	mov    %eax,%ecx
  801c92:	d3 ef                	shr    %cl,%edi
  801c94:	09 d7                	or     %edx,%edi
  801c96:	89 f2                	mov    %esi,%edx
  801c98:	89 f8                	mov    %edi,%eax
  801c9a:	f7 f5                	div    %ebp
  801c9c:	89 d6                	mov    %edx,%esi
  801c9e:	89 c7                	mov    %eax,%edi
  801ca0:	f7 64 24 04          	mull   0x4(%esp)
  801ca4:	39 d6                	cmp    %edx,%esi
  801ca6:	72 30                	jb     801cd8 <__udivdi3+0x138>
  801ca8:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801cac:	0f b6 0c 24          	movzbl (%esp),%ecx
  801cb0:	d3 e5                	shl    %cl,%ebp
  801cb2:	39 c5                	cmp    %eax,%ebp
  801cb4:	73 04                	jae    801cba <__udivdi3+0x11a>
  801cb6:	39 d6                	cmp    %edx,%esi
  801cb8:	74 1e                	je     801cd8 <__udivdi3+0x138>
  801cba:	89 f8                	mov    %edi,%eax
  801cbc:	31 d2                	xor    %edx,%edx
  801cbe:	e9 69 ff ff ff       	jmp    801c2c <__udivdi3+0x8c>
  801cc3:	90                   	nop
  801cc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cc8:	31 d2                	xor    %edx,%edx
  801cca:	b8 01 00 00 00       	mov    $0x1,%eax
  801ccf:	e9 58 ff ff ff       	jmp    801c2c <__udivdi3+0x8c>
  801cd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cd8:	8d 47 ff             	lea    -0x1(%edi),%eax
  801cdb:	31 d2                	xor    %edx,%edx
  801cdd:	8b 74 24 10          	mov    0x10(%esp),%esi
  801ce1:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801ce5:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801ce9:	83 c4 1c             	add    $0x1c,%esp
  801cec:	c3                   	ret    
  801ced:	66 90                	xchg   %ax,%ax
  801cef:	90                   	nop

00801cf0 <__umoddi3>:
  801cf0:	83 ec 2c             	sub    $0x2c,%esp
  801cf3:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801cf7:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801cfb:	89 74 24 20          	mov    %esi,0x20(%esp)
  801cff:	8b 74 24 38          	mov    0x38(%esp),%esi
  801d03:	89 7c 24 24          	mov    %edi,0x24(%esp)
  801d07:	8b 7c 24 34          	mov    0x34(%esp),%edi
  801d0b:	85 c0                	test   %eax,%eax
  801d0d:	89 c2                	mov    %eax,%edx
  801d0f:	89 6c 24 28          	mov    %ebp,0x28(%esp)
  801d13:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801d17:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801d1b:	89 74 24 10          	mov    %esi,0x10(%esp)
  801d1f:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801d23:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801d27:	75 1f                	jne    801d48 <__umoddi3+0x58>
  801d29:	39 fe                	cmp    %edi,%esi
  801d2b:	76 63                	jbe    801d90 <__umoddi3+0xa0>
  801d2d:	89 c8                	mov    %ecx,%eax
  801d2f:	89 fa                	mov    %edi,%edx
  801d31:	f7 f6                	div    %esi
  801d33:	89 d0                	mov    %edx,%eax
  801d35:	31 d2                	xor    %edx,%edx
  801d37:	8b 74 24 20          	mov    0x20(%esp),%esi
  801d3b:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801d3f:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801d43:	83 c4 2c             	add    $0x2c,%esp
  801d46:	c3                   	ret    
  801d47:	90                   	nop
  801d48:	39 f8                	cmp    %edi,%eax
  801d4a:	77 64                	ja     801db0 <__umoddi3+0xc0>
  801d4c:	0f bd e8             	bsr    %eax,%ebp
  801d4f:	83 f5 1f             	xor    $0x1f,%ebp
  801d52:	75 74                	jne    801dc8 <__umoddi3+0xd8>
  801d54:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801d58:	39 7c 24 10          	cmp    %edi,0x10(%esp)
  801d5c:	0f 87 0e 01 00 00    	ja     801e70 <__umoddi3+0x180>
  801d62:	8b 7c 24 0c          	mov    0xc(%esp),%edi
  801d66:	29 f1                	sub    %esi,%ecx
  801d68:	19 c7                	sbb    %eax,%edi
  801d6a:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801d6e:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801d72:	8b 44 24 14          	mov    0x14(%esp),%eax
  801d76:	8b 54 24 18          	mov    0x18(%esp),%edx
  801d7a:	8b 74 24 20          	mov    0x20(%esp),%esi
  801d7e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801d82:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801d86:	83 c4 2c             	add    $0x2c,%esp
  801d89:	c3                   	ret    
  801d8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d90:	85 f6                	test   %esi,%esi
  801d92:	89 f5                	mov    %esi,%ebp
  801d94:	75 0b                	jne    801da1 <__umoddi3+0xb1>
  801d96:	b8 01 00 00 00       	mov    $0x1,%eax
  801d9b:	31 d2                	xor    %edx,%edx
  801d9d:	f7 f6                	div    %esi
  801d9f:	89 c5                	mov    %eax,%ebp
  801da1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801da5:	31 d2                	xor    %edx,%edx
  801da7:	f7 f5                	div    %ebp
  801da9:	89 c8                	mov    %ecx,%eax
  801dab:	f7 f5                	div    %ebp
  801dad:	eb 84                	jmp    801d33 <__umoddi3+0x43>
  801daf:	90                   	nop
  801db0:	89 c8                	mov    %ecx,%eax
  801db2:	89 fa                	mov    %edi,%edx
  801db4:	8b 74 24 20          	mov    0x20(%esp),%esi
  801db8:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801dbc:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801dc0:	83 c4 2c             	add    $0x2c,%esp
  801dc3:	c3                   	ret    
  801dc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801dc8:	8b 44 24 10          	mov    0x10(%esp),%eax
  801dcc:	be 20 00 00 00       	mov    $0x20,%esi
  801dd1:	89 e9                	mov    %ebp,%ecx
  801dd3:	29 ee                	sub    %ebp,%esi
  801dd5:	d3 e2                	shl    %cl,%edx
  801dd7:	89 f1                	mov    %esi,%ecx
  801dd9:	d3 e8                	shr    %cl,%eax
  801ddb:	89 e9                	mov    %ebp,%ecx
  801ddd:	09 d0                	or     %edx,%eax
  801ddf:	89 fa                	mov    %edi,%edx
  801de1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801de5:	8b 44 24 10          	mov    0x10(%esp),%eax
  801de9:	d3 e0                	shl    %cl,%eax
  801deb:	89 f1                	mov    %esi,%ecx
  801ded:	89 44 24 10          	mov    %eax,0x10(%esp)
  801df1:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801df5:	d3 ea                	shr    %cl,%edx
  801df7:	89 e9                	mov    %ebp,%ecx
  801df9:	d3 e7                	shl    %cl,%edi
  801dfb:	89 f1                	mov    %esi,%ecx
  801dfd:	d3 e8                	shr    %cl,%eax
  801dff:	89 e9                	mov    %ebp,%ecx
  801e01:	09 f8                	or     %edi,%eax
  801e03:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801e07:	f7 74 24 0c          	divl   0xc(%esp)
  801e0b:	d3 e7                	shl    %cl,%edi
  801e0d:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801e11:	89 d7                	mov    %edx,%edi
  801e13:	f7 64 24 10          	mull   0x10(%esp)
  801e17:	39 d7                	cmp    %edx,%edi
  801e19:	89 c1                	mov    %eax,%ecx
  801e1b:	89 54 24 14          	mov    %edx,0x14(%esp)
  801e1f:	72 3b                	jb     801e5c <__umoddi3+0x16c>
  801e21:	39 44 24 18          	cmp    %eax,0x18(%esp)
  801e25:	72 31                	jb     801e58 <__umoddi3+0x168>
  801e27:	8b 44 24 18          	mov    0x18(%esp),%eax
  801e2b:	29 c8                	sub    %ecx,%eax
  801e2d:	19 d7                	sbb    %edx,%edi
  801e2f:	89 e9                	mov    %ebp,%ecx
  801e31:	89 fa                	mov    %edi,%edx
  801e33:	d3 e8                	shr    %cl,%eax
  801e35:	89 f1                	mov    %esi,%ecx
  801e37:	d3 e2                	shl    %cl,%edx
  801e39:	89 e9                	mov    %ebp,%ecx
  801e3b:	09 d0                	or     %edx,%eax
  801e3d:	89 fa                	mov    %edi,%edx
  801e3f:	d3 ea                	shr    %cl,%edx
  801e41:	8b 74 24 20          	mov    0x20(%esp),%esi
  801e45:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801e49:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801e4d:	83 c4 2c             	add    $0x2c,%esp
  801e50:	c3                   	ret    
  801e51:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e58:	39 d7                	cmp    %edx,%edi
  801e5a:	75 cb                	jne    801e27 <__umoddi3+0x137>
  801e5c:	8b 54 24 14          	mov    0x14(%esp),%edx
  801e60:	89 c1                	mov    %eax,%ecx
  801e62:	2b 4c 24 10          	sub    0x10(%esp),%ecx
  801e66:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  801e6a:	eb bb                	jmp    801e27 <__umoddi3+0x137>
  801e6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e70:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801e74:	0f 82 e8 fe ff ff    	jb     801d62 <__umoddi3+0x72>
  801e7a:	e9 f3 fe ff ff       	jmp    801d72 <__umoddi3+0x82>
